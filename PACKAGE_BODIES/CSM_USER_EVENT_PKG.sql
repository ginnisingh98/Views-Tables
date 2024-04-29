--------------------------------------------------------
--  DDL for Package Body CSM_USER_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_USER_EVENT_PKG" AS
/* $Header: csmeusrb.pls 120.26.12010000.4 2009/09/03 05:11:55 trajasek ship $ */

--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date       Comments
-- ravir
-- -- ---------   ------    ------------------------------------------
   -- Enter procedure, function bodies as shown below
FUNCTION is_omfs_palm_responsibility(p_responsibility_id IN NUMBER, p_user_id IN NUMBER)RETURN BOOLEAN
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_responsibilities_csr (p_resp_id NUMBER, l_user_id IN NUMBER)
IS
SELECT 1					  --R12-Multiple Responsibility
FROM  asg_user_pub_resps aupr,
	  asg_user asu
WHERE aupr.user_name 		   = asu.user_name
AND   aupr.responsibility_id   = p_resp_id
AND   asu.user_id 			   = l_user_id
AND   aupr.pub_name			   = 'SERVICEP';

l_responsibilities_rec l_responsibilities_csr%ROWTYPE;

BEGIN
   CSM_UTIL_PKG.LOG('Entering IS_OMFS_PALM_RESPONSIBILITY for user_id: ' || p_user_id || ' and responsibility_id: '
                    || p_responsibility_id , 'CSM_USER_EVENT_PKG.IS_OMFS_PALM_RESPONSIBILITY',FND_LOG.LEVEL_PROCEDURE);

    OPEN l_responsibilities_csr (p_responsibility_id,p_user_id);
    FETCH l_responsibilities_csr INTO l_responsibilities_rec;

    IF (l_responsibilities_csr%NOTFOUND) THEN
      CLOSE l_responsibilities_csr;
      RETURN FALSE;
    END IF;
    CLOSE l_responsibilities_csr;

   CSM_UTIL_PKG.LOG('Leaving IS_OMFS_PALM_RESPONSIBILITY for user_id: ' || p_user_id || ' and responsibility_id: '
                    || p_responsibility_id , 'CSM_USER_EVENT_PKG.IS_OMFS_PALM_RESPONSIBILITY',FND_LOG.LEVEL_PROCEDURE);

   RETURN TRUE;
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  IS_OMFS_PALM_RESPONSIBILITY for for user_id: ' || p_user_id || ' and responsibility_id: '
                    || p_responsibility_id || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_USER_EVENT_PKG.IS_OMFS_PALM_RESPONSIBILITY',FND_LOG.LEVEL_EXCEPTION);
        RETURN FALSE;
END IS_OMFS_PALM_RESPONSIBILITY;

PROCEDURE disable_user_pub_synch(p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
  CSM_UTIL_PKG.LOG('Entering disable_user_pub_synch for user_id:' || p_user_id,
                         'CSM_USER_EVENT_PKG.disable_user_pub_synch',FND_LOG.LEVEL_PROCEDURE);

  asg_helper.disable_user_pub_synch(p_user_id, 'SERVICEP');

  CSM_UTIL_PKG.LOG('Leaving disable_user_pub_synch for user_id:' || p_user_id,
                         'CSM_USER_EVENT_PKG.disable_user_pub_synch',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  disable_user_pub_synch for for user_id: ' || p_user_id
                       || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_USER_EVENT_PKG.disable_user_pub_synch',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END disable_user_pub_synch;

FUNCTION is_first_omfs_palm_user(p_user_id IN NUMBER) RETURN BOOLEAN
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_user_csr (p_user_id NUMBER)
IS
SELECT au.user_id
FROM asg_user au,
     asg_user_pub_resps  asg_resp
WHERE au.user_id <> p_user_id
AND au.enabled = 'Y'
AND asg_resp.pub_name = 'SERVICEP'
AND asg_resp.user_name = au.user_name;

l_user_rec l_user_csr%ROWTYPE;

BEGIN
  CSM_UTIL_PKG.LOG('Entering IS_FIRST_OMFS_PALM_USER for user_id:' || p_user_id,
                         'CSM_USER_EVENT_PKG.IS_FIRST_OMFS_PALM_USER',FND_LOG.LEVEL_PROCEDURE);

  OPEN l_user_csr(p_user_id);
  FETCH l_user_csr INTO l_user_rec;
  IF (l_user_csr%FOUND) THEN
    CLOSE l_user_csr;
    RETURN FALSE;
  END IF;
  CLOSE l_user_csr;

  CSM_UTIL_PKG.LOG('Leaving IS_FIRST_OMFS_PALM_USER for user_id:' || p_user_id,
                         'CSM_USER_EVENT_PKG.IS_FIRST_OMFS_PALM_USER',FND_LOG.LEVEL_PROCEDURE);
  RETURN TRUE;

EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  IS_FIRST_OMFS_PALM_USER for for user_id: ' || p_user_id
                       || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_USER_EVENT_PKG.IS_FIRST_OMFS_PALM_USER',FND_LOG.LEVEL_EXCEPTION);
        RETURN TRUE;
END IS_FIRST_OMFS_PALM_USER;

PROCEDURE spawn_dashboard_srch_cols_ins(p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_msg VARCHAR2(4000);
l_status VARCHAR2(40);
BEGIN
   CSM_UTIL_PKG.LOG('Entering spawn_dashboard_srch_cols_ins for user_id: ' || p_user_id,
                                   'CSM_USER_EVENT_PKG.spawn_dashboard_srch_cols_ins',FND_LOG.LEVEL_PROCEDURE);

   CSM_DBOARD_SRCH_COLS_EVENT_PKG.Refresh_Acc(l_status,l_msg);

   CSM_UTIL_PKG.LOG('Leaving spawn_dashboard_srch_cols_ins for user_id: ' || p_user_id,
                                   'CSM_USER_EVENT_PKG.spawn_dashboard_srch_cols_ins',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_msg := ' Exception in  spawn_dashboard_srch_cols_ins for for user_id: ' || p_user_id
                       || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_msg, 'csm_user_event_pkg.spawn_dashboard_srch_cols_ins',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END spawn_dashboard_srch_cols_ins;

--Bug 7239431
PROCEDURE spawn_perz_ins(p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_msg VARCHAR2(4000);
l_return_status VARCHAR2(40);
BEGIN
   CSM_UTIL_PKG.LOG('Entering spawn_perz_ins for user_id: ' || p_user_id,
                                   'CSM_USER_EVENT_PKG.spawn_perz_ins',FND_LOG.LEVEL_PROCEDURE);

    CSM_UTIL_PKG.LOG('Populating PERSONALIZED CUSTOMIZATION VIEWS Access table',
                                   'CSM_USER_EVENT_PKG.spawn_perz_ins',FND_LOG.LEVEL_PROCEDURE);

   CSM_CUSTMZ_VIEWS_EVENT_PKG.REFRESH_USER(p_user_id);

   CSM_UTIL_PKG.LOG('Populating PERSONALIZED DELTA PAGE VIEWS Access table',
                                   'CSM_USER_EVENT_PKG.spawn_perz_ins',FND_LOG.LEVEL_PROCEDURE);

   CSM_PAGE_PERZ_DELTA_EVENT_PKG.REFRESH_USER(p_user_id);


   CSM_UTIL_PKG.LOG('Populating PERSONALIZED NEW MESSAGES Access table',
                                   'CSM_USER_EVENT_PKG.spawn_perz_ins',FND_LOG.LEVEL_PROCEDURE);

   CSM_NEW_MESSAGES_EVENT_PKG.REFRESH_USER(p_user_id);

   CSM_UTIL_PKG.LOG('Leaving spawn_perz_ins for user_id: ' || p_user_id,
                                   'CSM_USER_EVENT_PKG.spawn_perz_ins',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_msg := ' Exception in  spawn_perz_ins for for user_id: ' || p_user_id
                       || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_msg, 'csm_user_event_pkg.spawn_perz_ins',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END spawn_perz_ins;

PROCEDURE spawn_task_ins(p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

-- get all task_ids created by mobile user
--Bug 4924584

CURSOR l_task_csr (b_user_id number)
IS  --SELECT tasks which are open and are closed and within history days
SELECT jt.task_id
FROM   JTF_TASKS_B jt,
       jtf_task_statuses_b jts
WHERE  jt.created_by = b_user_id
AND    jts.task_status_id = jt.task_status_id
AND    ( --task which are closed and within history days
	   	 (  jt.creation_date BETWEEN SYSDATE AND (SYSDATE - csm_profile_pkg.get_task_history_days(b_user_id))
      	   AND (   NVL(jts.cancelled_flag,'N')   = 'Y' OR NVL(jts.closed_flag,'N')     = 'Y'
           	 OR NVL(jts.rejected_flag,'N') 	= 'Y' OR NVL(jts.completed_flag, 'N') = 'Y'
		   	 )
	  	 )
         OR --task which are open
         (	 NOT (NVL(jts.cancelled_flag,'N') = 'Y' OR NVL(jts.closed_flag,'N') 	  = 'Y'
           OR NVL(jts.rejected_flag,'N') 	= 'Y' OR NVL(jts.completed_flag, 'N') = 'Y'
		       )
	     )
	  )
UNION	--select tasks which are created by the user and their correspdg SR is open
SELECT jt.task_id
FROM   JTF_TASKS_B jt
WHERE  jt.created_by = b_user_id
AND	   jt.source_object_type_code ='SR'
AND   EXISTS
	  (SELECT inc.incident_id
	   FROM   cs_incidents_all_b 	  inc,
       		  cs_incident_statuses_b ists
	   WHERE  inc.INCIDENT_STATUS_ID  = ists.INCIDENT_STATUS_ID
	   AND    NVL(ists.CLOSE_FLAG,'N')= 'N'
	   AND    inc.incident_id 		  = jt.source_object_id
	  );


BEGIN
   CSM_UTIL_PKG.LOG('Entering spawn_task_ins for user_id: ' || p_user_id,
                                   'CSM_USER_EVENT_PKG.spawn_task_ins',FND_LOG.LEVEL_PROCEDURE);

    -- loop to spawn process
    FOR l_task_rec IN l_task_csr(p_user_id) LOOP
        csm_task_event_pkg.task_ins_init(p_task_id=>l_task_rec.task_id);
        END LOOP;

   CSM_UTIL_PKG.LOG('Leaving spawn_task_ins for user_id: ' || p_user_id,
                                   'CSM_USER_EVENT_PKG.spawn_task_ins',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
        WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  spawn_task_ins for for user_id: ' || p_user_id
                       || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'csm_user_event_pkg.spawn_task_ins',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END spawn_task_ins;

--12.1XB6
PROCEDURE spawn_incident_ins(p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

-- get all open incident_ids owned/created by mobile user
CURSOR l_incident_csr (b_grp_id NUMBER,b_user_id NUMBER)
IS
SELECT incident_id
FROM   cs_incidents_all_b inc,
       cs_incident_statuses_b   ists
WHERE (
       inc.owner_group_id = b_grp_id
      OR
       csm_util_pkg.get_owner(inc.created_by)=b_user_id
      )
AND    inc.INCIDENT_STATUS_ID = ists.INCIDENT_STATUS_ID
AND    inc.install_site_id IS NOT NULL
AND    NVL(ists.CLOSE_FLAG, 'N') <> 'Y';


CURSOR c_get_group(b_user_id NUMBER)
IS
SELECT GROUP_ID,USER_ID
FROM ASG_USER
WHERE USER_ID=b_user_id
AND   USER_ID=OWNER_ID;

l_group_id NUMBER;
l_user_id NUMBER;
BEGIN
   CSM_UTIL_PKG.LOG('Entering spawn_incident_ins for user_id: ' || p_user_id,
                                   'CSM_USER_EVENT_PKG.spawn_incident_ins',FND_LOG.LEVEL_PROCEDURE);

    OPEN c_get_group(p_user_id);
    FETCH c_get_group INTO l_group_id,l_user_id;
    CLOSE c_get_group;

    IF (l_group_id is not null) OR (l_user_id is not null) THEN
       -- loop to spawn process
      FOR l_incident_rec IN l_incident_csr(l_group_id,l_user_id) LOOP
        csm_sr_event_pkg.sr_ins_init(p_incident_id=>l_incident_rec.incident_id);
	  END LOOP;
	END IF;

   CSM_UTIL_PKG.LOG('Leaving spawn_incident_ins for user_id: ' || p_user_id,
                                   'CSM_USER_EVENT_PKG.spawn_incident_ins',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  spawn_incident_ins for for user_id: ' || p_user_id
                       || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'csm_user_event_pkg.spawn_incident_ins',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END spawn_incident_ins;

PROCEDURE spawn_task_assignment_ins(p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

-- get all task assignment id's for a user
CURSOR l_task_assign_csr (p_user_id NUMBER)
IS
SELECT jtf_ta.task_assignment_id  --get all the task assignments which are open and of type TASK
FROM   jtf_rs_resource_extns jtf_rs,
       jtf_task_assignments  jtf_ta,
       jtf_task_statuses_b 	 jts_jta
WHERE  jtf_rs.user_id 	   	  = p_user_id
AND    jtf_ta.resource_id 	  = jtf_rs.resource_id
AND    jts_jta.task_Status_id = jtf_ta.assignment_status_id
AND NOT( NVL(jts_jta.cancelled_flag, 'N')     = 'Y' OR NVL(jts_jta.closed_flag, 'N')  = 'Y'
     	  OR NVL(jts_jta.completed_flag, 'N') = 'Y' OR NVL(jts_jta.rejected_flag,'N') = 'Y')
AND EXISTS (

		    SELECT 1
		    FROM   jtf_tasks_b jt,
      			   jtf_task_statuses_b jts
		    WHERE 	jt.task_id = jtf_ta.task_id
			AND    jts.task_status_id = jt.task_status_id
			AND    jt.source_object_type_code ='TASK'
 			AND NOT (   NVL(jts.cancelled_flag, 'N')     = 'Y' OR NVL(jts.closed_flag, 'N')      = 'Y'
          		OR NVL(jts.completed_flag, 'N') 	  = 'Y' OR NVL(jts.rejected_flag,'N')     = 'Y'
	 			 )
 			)
UNION ALL--Select task assignments which are for open SRs
SELECT jtf_ta.task_assignment_id
FROM   jtf_rs_resource_extns jtf_rs,
       jtf_task_assignments jtf_ta,
	   JTF_TASKS_B jt
WHERE  jtf_rs.user_id 	   	  = p_user_id
AND    jt.task_id 			  = jtf_ta.task_id
AND    jtf_ta.resource_id 	  = jtf_rs.resource_id
AND    jt.source_object_type_code ='SR'
AND   EXISTS
	  (SELECT 'X'
	   FROM   cs_incidents_all_b 	  inc,
       		  cs_incident_statuses_b ists
	   WHERE  inc.INCIDENT_STATUS_ID  = ists.INCIDENT_STATUS_ID
	   AND    NVL(ists.CLOSE_FLAG,'N')= 'N'
	   AND    inc.incident_id 		  = jt.source_object_id
	  );


l_task_assign_rec l_task_assign_csr% ROWTYPE;

BEGIN
   CSM_UTIL_PKG.LOG('Entering spawn_task_assignment_ins for user_id: ' || p_user_id,
                                   'CSM_USER_EVENT_PKG.spawn_task_assignment_ins',FND_LOG.LEVEL_PROCEDURE);

    -- loop to spawn process
    FOR l_task_assign_rec IN l_task_assign_csr(p_user_id) LOOP
      csm_task_assignment_event_pkg.task_assignment_initializer(p_task_assignment_id=>l_task_assign_rec.task_assignment_id,
                                                            p_error_msg=>l_error_msg,
                                                            x_return_status=>l_return_status);
	END LOOP;

   CSM_UTIL_PKG.LOG('Leaving spawn_task_assignment_ins for user_id: ' || p_user_id,
                                   'CSM_USER_EVENT_PKG.spawn_task_assignment_ins',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  spawn_task_assignment_ins for for user_id: ' || p_user_id
                       || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'csm_user_event_pkg.spawn_task_assignment_ins',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END spawn_task_assignment_ins;

PROCEDURE items_acc_processor(p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_organization_id NUMBER;
l_category_id NUMBER;
l_category_set_id NUMBER;

BEGIN
   CSM_UTIL_PKG.LOG('Entering items_acc_processor for user_id: ' || p_user_id,
                                   'csm_user_event_pkg.items_acc_processor',FND_LOG.LEVEL_PROCEDURE);

    l_organization_id := csm_profile_pkg.get_organization_id(p_user_id);
    l_category_set_id := csm_profile_pkg.get_category_set_id(p_user_id);
    l_category_id := csm_profile_pkg.get_category_id(p_user_id);

    DELETE FROM csm_user_inventory_org WHERE user_id = p_user_id;

    INSERT INTO csm_user_inventory_org (
      user_id, organization_id, last_update_date, last_updated_by,
      creation_date, created_by, category_set_id, category_id )
    VALUES (
      p_user_id, l_organization_id, SYSDATE, 1, SYSDATE, 1,
      l_category_set_id, l_category_id );

    -- get system items for the user - labor/expense
    csm_system_item_event_pkg.get_new_user_system_items(p_user_id=>p_user_id);

    -- get all mtl_system_items for the user
    csm_mtl_system_items_event_pkg.get_new_user_mtl_system_items(p_user_id=>p_user_id, p_organization_id=>l_organization_id,
                              p_category_set_id=>l_category_set_id, p_category_id=>l_category_id);

   CSM_UTIL_PKG.LOG('Leaving items_acc_processor for user_id: ' || p_user_id,
                                   'csm_user_event_pkg.items_acc_processor',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := TO_CHAR(SQLCODE);
        l_sqlerrmsg := SUBSTR(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  items_acc_processor for user_id :'
                       || to_char(p_user_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'csm_user_event_pkg.items_acc_processor',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END items_acc_processor;

PROCEDURE spawn_inv_loc_assignment_ins(p_resource_id IN NUMBER, p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_csp_inv_loc_assignment_csr (p_resource_id NUMBER) IS
SELECT csp_inv_loc_assignment_id
FROM csp_inv_loc_assignments
WHERE resource_id = p_resource_id
AND resource_type = 'RS_EMPLOYEE'
AND SYSDATE BETWEEN nvl(effective_date_start, SYSDATE) AND nvl(effective_date_end, SYSDATE);

BEGIN
   CSM_UTIL_PKG.LOG('Entering spawn_inv_loc_assignment_ins for user_id: ' || p_user_id,
                                   'csm_user_event_pkg.spawn_inv_loc_assignment_ins',FND_LOG.LEVEL_PROCEDURE);

   IF csm_util_pkg.is_palm_resource(p_resource_id) THEN
     FOR r_csp_inv_loc_assignment_rec IN l_csp_inv_loc_assignment_csr(p_resource_id) LOOP
       CSM_INV_LOC_ASS_EVENT_PKG.INV_LOC_ASSIGNMENT_INS_INIT
          (p_csp_inv_loc_assignment_id=>r_csp_inv_loc_assignment_rec.csp_inv_loc_assignment_id);
     END LOOP;
   END IF;

   CSM_UTIL_PKG.LOG('Leaving spawn_inv_loc_assignment_ins for user_id: ' || p_user_id,
                                   'csm_user_event_pkg.spawn_inv_loc_assignment_ins',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := TO_CHAR(SQLCODE);
        l_sqlerrmsg := SUBSTR(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  spawn_inv_loc_assignment_ins for user_id :'
                       || to_char(p_user_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'csm_user_event_pkg.spawn_inv_loc_assignment_ins',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END spawn_inv_loc_assignment_ins;

PROCEDURE spawn_po_loc_ass_all_ins(p_resource_id IN NUMBER, p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_po_loc_ass_all_csr (p_resource_id IN NUMBER)
IS
SELECT pla.location_id              location_id,
       pla.site_use_id              site_use_id,
       rcr.resource_id              resource_id,
       jtrs.user_id                 user_id,
       hps.party_site_id            party_site_id
FROM   po_location_associations_all pla,
       hz_cust_site_uses_all        csu,
       hz_cust_acct_sites_all       cas,
       csp_rs_cust_relations        rcr,
       jtf_rs_resource_extns        jtrs,
       hz_party_sites               hps,
       hz_locations                 hzl
WHERE  csu.site_use_id       = pla.site_use_id
AND    csu.site_use_code     = 'SHIP_TO'
AND    csu.cust_acct_site_id = cas.cust_acct_site_id
AND    csu.status            = 'A'
AND    cas.cust_account_id   = rcr.customer_id
AND    cas.status            = 'A'
AND    cas.party_site_id     = hps.party_site_id
AND    hps.location_id       = hzl.location_id
AND    jtrs.resource_id      = rcr.resource_id
AND    jtrs.resource_id      = p_resource_id;

BEGIN
   CSM_UTIL_PKG.LOG('Entering spawn_po_loc_ass_all_ins for user_id: ' || p_user_id,
                                   'csm_user_event_pkg.spawn_po_loc_ass_all_ins',FND_LOG.LEVEL_PROCEDURE);

  IF csm_util_pkg.is_palm_resource(p_resource_id) THEN

     FOR r_po_loc_ass_all_rec IN l_po_loc_ass_all_csr(p_resource_id) LOOP
       csm_party_site_event_pkg.party_sites_acc_i
                  (p_party_site_id=>r_po_loc_ass_all_rec.party_site_id,
                   p_user_id=>r_po_loc_ass_all_rec.user_id,
                   p_flowtype=>NULL,
                   p_error_msg=>l_error_msg,
                   x_return_status=>l_return_status);

       csm_po_locations_event_pkg.csp_ship_to_addr_mdirty_i
                   (p_location_id=>r_po_loc_ass_all_rec.location_id,
                    p_site_use_id=>r_po_loc_ass_all_rec.site_use_id,
                    p_user_id=>r_po_loc_ass_all_rec.user_id);
     END LOOP;

   END IF;

   CSM_UTIL_PKG.LOG('Leaving spawn_po_loc_ass_all_ins for user_id: ' || p_user_id,
                                   'csm_user_event_pkg.spawn_po_loc_ass_all_ins',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := TO_CHAR(SQLCODE);
        l_sqlerrmsg := SUBSTR(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  spawn_po_loc_ass_all_ins for user_id :'
                       || to_char(p_user_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'csm_user_event_pkg.spawn_po_loc_ass_all_ins',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END spawn_po_loc_ass_all_ins;

PROCEDURE spawn_csp_req_headers_ins(p_resource_id IN NUMBER, p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_req_headers_csr (p_resource_id NUMBER)
IS
SELECT hdr.requirement_header_id,
       jtrs.resource_id,
       jtrs.user_id
FROM   csp_requirement_headers hdr,
       jtf_rs_resource_extns jtrs
WHERE hdr.resource_id = jtrs.resource_id
AND   jtrs.resource_id = p_resource_id
AND NOT EXISTS
(SELECT 1
 FROM csm_req_headers_acc acc
 WHERE acc.requirement_header_id = hdr.requirement_header_id
 AND acc.user_id = jtrs.user_id
 );

BEGIN
   CSM_UTIL_PKG.LOG('Entering spawn_csp_req_headers_ins for user_id: ' || p_user_id,
                                   'csm_user_event_pkg.spawn_csp_req_headers_ins',FND_LOG.LEVEL_PROCEDURE);

  IF csm_util_pkg.is_palm_resource(p_resource_id) THEN

     FOR r_req_headers_rec IN l_req_headers_csr(p_resource_id) LOOP
         csm_csp_req_headers_event_pkg.csp_req_headers_mdirty_i
                         (p_requirement_header_id=>r_req_headers_rec.requirement_header_id,
                          p_user_id=>r_req_headers_rec.user_id);
     END LOOP;

   END IF;

   CSM_UTIL_PKG.LOG('Leaving spawn_csp_req_headers_ins for user_id: ' || p_user_id,
                                   'csm_user_event_pkg.spawn_csp_req_headers_ins',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := TO_CHAR(SQLCODE);
        l_sqlerrmsg := SUBSTR(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  spawn_csp_req_headers_ins for user_id :'
                       || to_char(p_user_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'csm_user_event_pkg.spawn_csp_req_headers_ins',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END spawn_csp_req_headers_ins;

PROCEDURE spawn_csp_req_lines_ins(p_resource_id IN NUMBER, p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_req_lines_csr(p_resource_id IN NUMBER )
IS
SELECT hdr.requirement_header_id,
       hdr.resource_id,
       line.requirement_line_id,
       jtrs.user_id
FROM   csp_requirement_headers hdr,
       csp_requirement_lines line,
       jtf_rs_resource_extns jtrs
WHERE  hdr.requirement_header_id = line.requirement_header_id
AND    hdr.resource_id = jtrs.resource_id
AND    jtrs.resource_id = p_resource_id
AND NOT EXISTS
(SELECT 1
 FROM csm_req_lines_acc acc
 WHERE acc.requirement_line_id = line.requirement_line_id
 AND acc.user_id = jtrs.user_id
 );

BEGIN
   CSM_UTIL_PKG.LOG('Entering spawn_csp_req_lines_ins for user_id: ' || p_user_id,
                                   'csm_user_event_pkg.spawn_csp_req_lines_ins',FND_LOG.LEVEL_PROCEDURE);

   IF csm_util_pkg.is_palm_resource(p_resource_id) THEN

     FOR r_req_lines_rec IN l_req_lines_csr(p_resource_id) LOOP
        csm_csp_req_lines_event_pkg.csp_req_lines_mdirty_i
                            (p_requirement_line_id=>r_req_lines_rec.requirement_line_id,
                             p_user_id=>r_req_lines_rec.user_id);
     END LOOP;

   END IF;

   CSM_UTIL_PKG.LOG('Leaving spawn_csp_req_lines_ins for user_id: ' || p_user_id,
                                   'csm_user_event_pkg.spawn_csp_req_lines_ins',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := TO_CHAR(SQLCODE);
        l_sqlerrmsg := SUBSTR(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  spawn_csp_req_lines_ins for user_id :'
                       || to_char(p_user_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'csm_user_event_pkg.spawn_csp_req_lines_ins',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END spawn_csp_req_lines_ins;

PROCEDURE enable_user_pub_synch(p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
  CSM_UTIL_PKG.LOG('Entering enable_user_pub_synch for user_id:' || p_user_id,
                         'csm_user_event_pkg.enable_user_pub_synch',FND_LOG.LEVEL_PROCEDURE);

  asg_helper.enable_user_pub_synch(p_user_id, 'SERVICEP');

  CSM_UTIL_PKG.LOG('Leaving enable_user_pub_synch for user_id:' || p_user_id,
                         'csm_user_event_pkg.enable_user_pub_synch',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  enable_user_pub_synch for for user_id: ' || p_user_id
                       || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'csm_user_event_pkg.enable_user_pub_synch',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END enable_user_pub_synch;

PROCEDURE user_resp_ins_initializer (p_responsibility_id IN NUMBER, p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_code NUMBER;
l_return_status VARCHAR2(2000);
l_resource_id NUMBER;

CURSOR l_get_resource_id_csr(p_user_id IN NUMBER)
IS
SELECT resource_id
FROM asg_user
WHERE user_id = p_user_id;

BEGIN
  CSM_UTIL_PKG.LOG('Entering USER_RESP_INS_INITIALIZER for user_id:' || p_user_id,
                         'CSM_USER_EVENT_PKG.USER_RESP_INS_INITIALIZER',FND_LOG.LEVEL_PROCEDURE);

  -- check if responsibility is a MFS responsibility
  IF NOT is_omfs_palm_responsibility(p_responsibility_id=>p_responsibility_id,
                                     p_user_id=>p_user_id) THEN
     CSM_UTIL_PKG.LOG('Responsibility id: ' || p_responsibility_id || ' not a valid MFS responsibility for user_id:' || p_user_id,
                         'CSM_USER_EVENT_PKG.USER_RESP_INS_INITIALIZER',FND_LOG.LEVEL_EXCEPTION);
     RETURN;
  END IF;

  -- get resource_id of the user
  OPEN l_get_resource_id_csr(p_user_id);
  FETCH l_get_resource_id_csr INTO l_resource_id;
  CLOSE l_get_resource_id_csr;

  -- disable user sync
  csm_user_event_pkg.disable_user_pub_synch(p_user_id=>p_user_id);
  --Inserting the user into the Access table
  CSM_USER_EVENT_PKG.INSERT_ACC (p_user_id =>p_user_id
             ,x_return_status =>l_return_status
             ,x_error_message =>l_error_msg);

  -- if first user download all common lookup info
  IF is_first_omfs_palm_user(p_user_id=>p_user_id) THEN
      csm_concurrent_jobs_pkg.refresh_all_acc(x_retcode=>l_return_code,
                                              x_return_status=>l_return_status);
  END IF;

  -- download profiles info
  -- setup profile info first as they are need in other procedures
  csm_profile_event_pkg.refresh_user_acc(p_user_id=>p_user_id);

  -- Insert the user's group
  CSM_GROUP_DOWNLOAD_PVT.INSERT_MY_GROUP (p_user_id=>p_user_id
                                    ,x_return_status=>l_return_status
                                    , x_error_message => l_error_msg);

  -- spawn task ins
  csm_user_event_pkg.spawn_task_ins(p_user_id=>p_user_id);

  -- spawn incident ins
  csm_user_event_pkg.spawn_incident_ins(p_user_id=>p_user_id);

  -- spawn task assignment ins
  csm_user_event_pkg.spawn_task_assignment_ins(p_user_id=>p_user_id);

  --spawn personalizations for CSM_CUSTOMIZATION_VIEWS,CSM_NEW_MESSAGES,CSM_PAGE_PERZ_DELTA
  spawn_perz_ins(p_user_id=>p_user_id);

  --spawn CSM_DASHBOARD_SEARCH_COLS
  spawn_dashboard_srch_cols_ins(p_user_id=>p_user_id);

  --spawn CSM_FND_LOBS_ACC
  CSM_LOBS_EVENT_PKG.Insert_all_acc_records(p_user_id=>p_user_id);

  -- download resources belonging to member's group
  csm_resource_extns_event_pkg.resource_extns_acc_processor(p_resource_id=>l_resource_id,
                                                            p_user_id=>p_user_id);

  -- download notifications for user sender/recipient
  csm_notification_event_pkg.notifications_acc_processor(p_user_id=>p_user_id);

  -- download state transitions, moved to concurrent program
--  csm_state_transition_event_pkg.Refresh_Acc(p_user_id=>p_user_id);


  -- download labor,expense and other mtl_system_items
  csm_user_event_pkg.items_acc_processor(p_user_id=>p_user_id);

  -- download csp_inv_loc_assignments
  csm_user_event_pkg.spawn_inv_loc_assignment_ins(p_resource_id=>l_resource_id,
                                                  p_user_id=>p_user_id);

  -- download po_location_assignments
  csm_user_event_pkg.spawn_po_loc_ass_all_ins(p_resource_id=>l_resource_id,
                                              p_user_id=>p_user_id);

  -- download csp_req_headers
  csm_user_event_pkg.spawn_csp_req_headers_ins(p_resource_id=>l_resource_id,
                                               p_user_id=>p_user_id);

  -- download csp_req_lines
  csm_user_event_pkg.spawn_csp_req_lines_ins(p_resource_id=>l_resource_id,
                                             p_user_id=>p_user_id);

  --Bug 5048151 - spawn Parts Transfer
  spawn_mat_txn (p_user_id=>p_user_id);

    --download serial numbers
  spawn_mtl_serial_numbers(p_resource_id=>l_resource_id,
                                             p_user_id=>p_user_id);

  csm_auto_sync_nfn_pkg.auto_sync_nfn_acc_processor(p_user_id=>p_user_id);

  csm_client_nfn_log_pkg.client_nfn_log_acc_processor(p_user_id=>p_user_id);

  csm_auto_sync_log_pkg.auto_sync_log_acc_processor(p_user_id=>p_user_id);

  csm_auto_sync_pkg.auto_sync_acc_processor(p_user_id=>p_user_id);

  CSM_QUERY_EVENT_PKG.REFRESH_USER(p_user_id=>p_user_id);
  -- enable user sync
  csm_user_event_pkg.enable_user_pub_synch(p_user_id=>p_user_id);

  CSM_UTIL_PKG.LOG('Leaving USER_RESP_INS_INITIALIZER for user_id:' || p_user_id,
                         'CSM_USER_EVENT_PKG.USER_RESP_INS_INITIALIZER',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  USER_RESP_INS_INITIALIZER for for user_id: ' || p_user_id
                       || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_USER_EVENT_PKG.USER_RESP_INS_INITIALIZER',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END USER_RESP_INS_INITIALIZER;

PROCEDURE user_del_init(p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
  CSM_UTIL_PKG.LOG('Entering user_del_init for user_id:' || p_user_id,
                         'csm_user_event_pkg.user_del_init',FND_LOG.LEVEL_PROCEDURE);

  -- purge all ACC tables
  csm_user_event_pkg.purge_all_acc_tables(p_user_id=>p_user_id);

  CSM_UTIL_PKG.LOG('Leaving user_del_init for user_id:' || p_user_id,
                         'csm_user_event_pkg.user_del_init',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  user_del_init for for user_id: ' || p_user_id
                       || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'csm_user_event_pkg.user_del_init',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END user_del_init;

PROCEDURE purge_all_acc_tables(p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
  CSM_UTIL_PKG.LOG('Entering purge_all_acc_tables for user_id:' || p_user_id,
                         'csm_user_event_pkg.purge_all_acc_tables',FND_LOG.LEVEL_PROCEDURE);

     DELETE FROM CSM_DEBRIEF_LINES_ACC 	 	   WHERE user_id = p_user_id;
     DELETE FROM CSM_DEBRIEF_HEADERS_ACC 	   WHERE user_id = p_user_id;
     DELETE FROM CSM_ITEM_INSTANCES_ACC  	   WHERE user_id = p_user_id;
     DELETE FROM CSM_NOTES_ACC 			 	   WHERE user_id = p_user_id;
     DELETE FROM CSM_NOTIFICATIONS_ACC 	 	   WHERE user_id = p_user_id;

     DELETE FROM CSM_PARTIES_ACC 		 	   WHERE user_id = p_user_id;
     DELETE FROM CSM_PARTY_SITES_ACC 	 	   WHERE user_id = p_user_id;
     DELETE FROM csm_profile_option_values_acc WHERE user_id = p_user_id;

     DELETE FROM CSM_RS_RESOURCE_EXTNS_ACC 	   WHERE user_id = p_user_id;
--Bug 5236469
     csm_resource_extns_event_pkg.RESOURCE_EXTNS_ACC_CLEANUP(p_user_id);

     DELETE FROM CSM_TASK_ASSIGNMENTS_ACC 	   WHERE user_id = p_user_id;

     DELETE FROM CSM_TASKS_ACC 				   WHERE user_id = p_user_id;
     DELETE FROM CSM_INCIDENTS_ALL_ACC 		   WHERE user_id = p_user_id;
     DELETE FROM CSM_SR_CONTACTS_ACC 		   WHERE user_id = p_user_id;
     DELETE FROM CSM_CUSTOMIZATION_VIEWS_ACC   WHERE user_id = p_user_id;
     DELETE FROM CSM_PAGE_PERZ_DELTA_ACC 	   WHERE user_id = p_user_id;

     DELETE FROM CSM_NEW_MESSAGES_ACC 		   WHERE user_id = p_user_id;
     DELETE FROM CSM_STATE_TRANSITIONS_ACC 	   WHERE user_id = p_user_id;
     DELETE FROM csm_mtl_system_items_acc 	   WHERE user_id = p_user_id;
     DELETE FROM csm_mtl_serial_numbers_acc    WHERE user_id = p_user_id;
     DELETE FROM csm_mtl_material_txn_acc 	   WHERE user_id = p_user_id;

     DELETE FROM csm_mtl_txn_lot_num_acc 	   WHERE user_id = p_user_id;
     DELETE FROM csm_mtl_unit_txn_acc 		   WHERE user_id = p_user_id;
     DELETE FROM csm_inv_loc_ass_acc 		   WHERE user_id = p_user_id;
     DELETE FROM csm_po_loc_ass_all_acc 	   WHERE user_id = p_user_id;
     DELETE FROM csm_req_lines_acc 			   WHERE user_id = p_user_id;

     DELETE FROM csm_req_headers_acc 		   WHERE user_id = p_user_id;
     DELETE FROM csm_system_items_acc 		   WHERE user_id = p_user_id;
     DELETE FROM csm_mtl_item_subinv_acc 	   WHERE user_id = p_user_id;
     DELETE FROM csm_mtl_sec_inv_acc 		   WHERE user_id = p_user_id;
     DELETE FROM csm_ii_relationships_acc 	   WHERE user_id = p_user_id;

     DELETE FROM csm_contr_headers_acc 		   WHERE user_id = p_user_id;
     DELETE FROM csm_contr_buss_processes_acc  WHERE user_id = p_user_id;
     DELETE FROM csm_contr_buss_txn_types_acc  WHERE user_id = p_user_id;
     --DELETE FROM csm_unit_of_measure_tl_acc WHERE user_id = p_user_id;
     DELETE FROM csm_service_history_acc 	   WHERE user_id = p_user_id;
     DELETE FROM csm_debrief_headers_acc 	   WHERE user_id = p_user_id;

     DELETE FROM csm_counters_acc 			   WHERE user_id = p_user_id;
     DELETE FROM csm_counter_values_acc 	   WHERE user_id = p_user_id;
     DELETE FROM csm_mtl_item_locations_acc    WHERE user_id = p_user_id;
     DELETE FROM csm_mtl_secondary_locators_acc WHERE user_id = p_user_id;
     DELETE FROM csm_mtl_onhand_qty_acc 	   WHERE user_id = p_user_id;

     DELETE FROM csm_user_inventory_org 	   WHERE user_id = p_user_id;
     DELETE FROM CSM_FND_LOBS_ACC 			   WHERE user_id = p_user_id;--Bug 4938130
	 DELETE FROM CSM_HZ_CUST_ACCOUNTS_ACC      WHERE user_id = p_user_id;--Bug 5213097
	 DELETE FROM CSM_SR_TYPE_MAPPING_ACC	   WHERE user_id = p_user_id;--Bug 5213097
	 DELETE FROM CSM_CSI_ITEM_ATTR_ACC		   WHERE user_id = p_user_id;--Bug 5213097
	 DELETE FROM CSM_HZ_LOCATIONS_ACC		   WHERE user_id = p_user_id;--Bug 5213097

	 DELETE FROM CSM_HZ_CONTACT_POINTS_ACC 	   WHERE user_id = p_user_id;
	 DELETE FROM CSM_COUNTER_PROP_VALUES_ACC   WHERE user_id = p_user_id;
	 DELETE FROM CSM_COUNTER_PROPERTIES_ACC	   WHERE user_id = p_user_id;
	 DELETE FROM CSM_HZ_RELATIONSHIPS_ACC 	   WHERE user_id = p_user_id;
	 DELETE FROM CSM_PARTY_ASSIGNMENT 	   WHERE user_id = p_user_id;

   DELETE FROM CSM_CLIENT_NFN_LOG_ACC   WHERE user_id=p_user_id;
   DELETE FROM CSM_AUTO_SYNC_LOG_ACC    WHERE user_id=p_user_id;
   DELETE FROM CSM_AUTO_SYNC_ACC        WHERE user_id=p_user_id;
   DELETE FROM CSM_QUERY_ACC            WHERE user_id=p_user_id;
   DELETE FROM CSM_QUERY_VARIABLES_ACC  WHERE user_id=p_user_id;
   DELETE FROM CSM_QUERY_INSTANCES_ACC  WHERE user_id=p_user_id;
   DELETE FROM CSM_QUERY_VARIABLE_VALUES_ACC  WHERE user_id=p_user_id;
   DELETE FROM CSM_QUERY_RESULTS_ACC    WHERE user_id=p_user_id;
   DELETE FROM CSM_COV_ACTION_TIMES_ACC WHERE user_id=p_user_id;
   DELETE FROM CSM_CLIENT_UNDO_REQUEST_ACC    WHERE user_id=p_user_id;

   --Purge Auto sync tables
  CSM_NOTIFICATION_EVENT_PKG.PURGE_USER(p_user_id);

  --Delete the Group of the User
  CSM_GROUP_DOWNLOAD_PVT.DELETE_MY_GROUP (p_user_id=>p_user_id
                                    ,x_return_status=>l_return_status
                                    , x_error_message => l_error_msg);
  --Deleting User from the Access table
  CSM_USER_EVENT_PKG.DELETE_ACC (p_user_id =>p_user_id
             ,x_return_status =>l_return_status
             ,x_error_message =>l_error_msg);

  CSM_UTIL_PKG.LOG('Leaving purge_all_acc_tables for user_id:' || p_user_id,
                         'csm_user_event_pkg.purge_all_acc_tables',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  purge_all_acc_tables for for user_id: ' || p_user_id
                       || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'csm_user_event_pkg.purge_all_acc_tables',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END purge_all_acc_tables;

--Populate PIs related to parts transfer
PROCEDURE spawn_mat_txn(p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_msg VARCHAR2(4000);
l_status VARCHAR2(40);
BEGIN
   CSM_UTIL_PKG.LOG('Entering spawn_mat_txn for user_id: ' || p_user_id,
                                   'CSM_USER_EVENT_PKG.spawn_mat_txn',FND_LOG.LEVEL_PROCEDURE);

   CSM_MTL_MATERIAL_TXN_ACC_PKG.get_new_user_mat_txn(p_user_id);

   CSM_UTIL_PKG.LOG('Leaving spawn_mat_txn for user_id: ' || p_user_id,
                                   'CSM_USER_EVENT_PKG.spawn_mat_txn',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_msg := ' Exception in  spawn_perz_ins for for user_id: ' || p_user_id
                       || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_msg, 'csm_user_event_pkg.spawn_perz_ins',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END spawn_mat_txn;

--PROCEDURE TO DOWNLOAD SERIAL NUMBERS DURING USER CREATION.
PROCEDURE spawn_mtl_serial_numbers(p_resource_id IN NUMBER, p_user_id IN NUMBER)
IS
l_organization_id NUMBER;
l_sqlerrno 		  VARCHAR(20);
l_sqlerrmsg 	  VARCHAR(4000);
l_error_msg	  	  VARCHAR(4000);

BEGIN
	 CSM_UTIL_PKG.LOG('Entering spawn_mtl_serial_numbers for User_id ' || p_user_id,
	 'CSM_USER_EVENT_PKG.spawn_mtl_serial_numbers',FND_LOG.LEVEL_PROCEDURE);

	 l_organization_id := csm_profile_pkg.get_organization_id(p_user_id);

	 --get all the serial numbers for the User
	 CSM_SERIAL_NUMBERS_EVENT_PKG.insert_mtl_serial_numbers(l_organization_id,TO_DATE('1','J'),p_resource_id,p_user_id);

	 CSM_UTIL_PKG.LOG('Leaving spawn_mtl_serial_numbers for User_id ' || p_user_id,
	 'CSM_USER_EVENT_PKG.spawn_mtl_serial_numbers',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
	 WHEN OTHERS THEN
	  l_sqlerrno  := TO_CHAR(SQLCODE);
	  l_sqlerrmsg := TO_CHAR(SQLERRM);
	  l_error_msg := 'Exception in 	spawn_mtl_serial_numbers for User_id '
	  || TO_CHAR(p_user_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;

	  CSM_UTIL_PKG.LOG(l_error_msg,'CSM_USER_EVENT_PKG.spawn_mtl_serial_numbers',FND_LOG.LEVEL_EXCEPTION);
	  RAISE;
END spawn_mtl_serial_numbers;

PROCEDURE INSERT_ACC (p_user_id IN NUMBER
                                    ,x_return_status OUT NOCOPY VARCHAR2
                                    , x_error_message OUT NOCOPY VARCHAR2)
IS
l_sqlerrno 	VARCHAR(20);
l_sqlerrmsg 	VARCHAR(4000);
l_error_msg	VARCHAR(4000);
l_user_id       NUMBER;
l_owner_id      NUMBER;
l_group_id      NUMBER;
l_access_id     NUMBER;
l_markdirty     BOOLEAN;
l_tab_user_id 	asg_download.user_list;
l_tab_owner_id 	asg_download.user_list;
l_tab_access_id asg_download.access_list;
g_pub_item varchar2(30) := 'CSF_M_USER';

CURSOR c_asg_user(l_user_id NUMBER)
IS
SELECT USER_ID,OWNER_ID,GROUP_ID
FROM
ASG_USER
WHERE USER_ID=l_user_id;

CURSOR c_user_acc(l_user_id NUMBER)
IS
SELECT USER_ID
FROM
CSM_USER_ACC
WHERE USER_ID=l_user_id;

CURSOR c_group_users(l_owner_id NUMBER)
IS
SELECT USR.USER_ID,USR.OWNER_ID,ACC.ACCESS_ID
FROM   ASG_USER USR,
       CSM_USER_ACC ACC
WHERE  USR.OWNER_ID=l_owner_id
AND    USR.USER_ID = ACC.USER_ID;

BEGIN
   CSM_UTIL_PKG.LOG('Entering INSERT_ACC for User_id ' || p_user_id,
     'CSM_USER_EVENT_PKG.INSERT_ACC',FND_LOG.LEVEL_PROCEDURE);
   OPEN  c_asg_user(p_user_id);
   FETCH c_asg_user INTO l_user_id,l_owner_id,l_group_id;
   CLOSE c_asg_user;

   OPEN  c_user_acc(p_user_id);
   FETCH c_user_acc INTO l_user_id;
   IF c_user_acc%FOUND THEN
    DELETE FROM CSM_USER_ACC WHERE USER_ID =l_user_id;
   END IF;

   SELECT CSM_USER_ACC_S.NEXTVAL INTO l_access_id  FROM DUAL;

   INSERT INTO CSM_USER_ACC(ACCESS_ID,USER_ID,OWNER_ID,COUNTER,LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN)
   VALUES     (l_access_id,l_user_id,l_owner_id,1,sysdate,1,sysdate,1,1);
   CLOSE c_user_acc;

  l_markdirty := asg_download.mark_dirty(
    p_pub_item         => g_pub_item
  , p_accessid         => l_access_id
  , p_userid           => l_owner_id
  , p_dml              => 'I'
  , P_TIMESTAMP        => sysdate
  );
   CSM_UTIL_PKG.LOG('User is inserted into the Access table: User_id ' || p_user_id,
     'CSM_USER_EVENT_PKG.INSERT_ACC',FND_LOG.LEVEL_PROCEDURE);
  --If the user is a owner
   IF l_user_id = l_owner_id AND l_group_id IS NOT NULL THEN
     OPEN  c_group_users(l_owner_id);
     LOOP
      IF l_tab_user_id.COUNT > 0 THEN
        l_tab_user_id.DELETE;
      END IF;
      IF l_tab_owner_id.COUNT > 0 THEN
        l_tab_owner_id.DELETE;
      END IF;
      IF l_tab_access_id.COUNT > 0 THEN
        l_tab_access_id.DELETE;
      END IF;

     FETCH c_group_users BULK COLLECT INTO l_tab_user_id,l_tab_owner_id,l_tab_access_id LIMIT 10;
     EXIT WHEN l_tab_access_id.COUNT = 0;
        FOR i in 1..l_tab_access_id.COUNT
        LOOP
          UPDATE CSM_USER_ACC
          SET OWNER_ID     = l_tab_owner_id(i),
          LAST_UPDATE_DATE = SYSDATE
          WHERE USER_ID = l_tab_user_id(i);

          l_markdirty := asg_download.mark_dirty(
            p_pub_item         => g_pub_item
          , p_accessid         => l_tab_access_id(i)
          , p_userid           => l_tab_owner_id(i)
          , p_dml              => 'U'
          , P_TIMESTAMP        => sysdate
          );

        END LOOP;

     END LOOP;
     CLOSE c_group_users;

  END IF;
   CSM_UTIL_PKG.LOG('Leaving INSERT_ACC for User_id ' || p_user_id,
     'CSM_USER_EVENT_PKG.INSERT_ACC',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
	 WHEN OTHERS THEN
	  l_sqlerrno  := TO_CHAR(SQLCODE);
	  l_sqlerrmsg := TO_CHAR(SQLERRM);
	  l_error_msg := 'Exception in 	INSERT_ACC for User_id '
	  || TO_CHAR(p_user_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;

	  CSM_UTIL_PKG.LOG(l_error_msg,'CSM_USER_EVENT_PKG.INSERT_ACC',FND_LOG.LEVEL_EXCEPTION);
          RAISE;
END INSERT_ACC;

PROCEDURE DELETE_ACC (p_user_id IN NUMBER
                                    ,x_return_status OUT NOCOPY VARCHAR2
                                    , x_error_message OUT NOCOPY VARCHAR2)
IS
l_sqlerrno 	VARCHAR(20);
l_sqlerrmsg 	VARCHAR(4000);
l_error_msg	VARCHAR(4000);
l_user_id       NUMBER;
l_owner_id      NUMBER;
l_access_id     NUMBER;
l_markdirty     BOOLEAN;
g_pub_item varchar2(30) := 'CSF_M_USER';

CURSOR c_user_acc(l_user_id NUMBER)
IS
SELECT ACCESS_ID,USER_ID,OWNER_ID
FROM
CSM_USER_ACC
WHERE USER_ID=l_user_id;


BEGIN
   CSM_UTIL_PKG.LOG('Entering DELETE_ACC for User_id ' || p_user_id,
     'CSM_USER_EVENT_PKG.DELETE_ACC',FND_LOG.LEVEL_PROCEDURE);

   OPEN  c_user_acc(p_user_id);
   FETCH c_user_acc INTO l_access_id,l_user_id,l_owner_id;
   --Do mark dirty only for the User
   IF c_user_acc%FOUND  THEN
      IF l_user_id <> l_owner_id THEN --Do not do mark dirty for individual users and owners
          l_markdirty := asg_download.mark_dirty(
            p_pub_item         => g_pub_item
          , p_accessid         => l_access_id
          , p_userid           => l_owner_id
          , p_dml              => 'D'
          , P_TIMESTAMP        => sysdate
          );
       END IF;
      --delete for owner,member or individual user
      DELETE FROM CSM_USER_ACC WHERE USER_ID =l_user_id;

      CSM_UTIL_PKG.LOG('User is Deleted From the Access table for  User_id :' || p_user_id,
        'CSM_USER_EVENT_PKG.DELETE_ACC',FND_LOG.LEVEL_PROCEDURE);

   END IF;

   CSM_UTIL_PKG.LOG('Leaving DELETE_ACC for User_id ' || p_user_id,
     'CSM_USER_EVENT_PKG.DELETE_ACC',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
	 WHEN OTHERS THEN
	  l_sqlerrno  := TO_CHAR(SQLCODE);
	  l_sqlerrmsg := TO_CHAR(SQLERRM);
	  l_error_msg := 'Exception in 	DELETE_ACC for User_id '
	  || TO_CHAR(p_user_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;

	  CSM_UTIL_PKG.LOG(l_error_msg,'CSM_USER_EVENT_PKG.DELETE_ACC',FND_LOG.LEVEL_EXCEPTION);
          RAISE;
END DELETE_ACC;

/*
  The following two apis are used for inserting/deleting
  non-group member records in CSM_USER_ACC for the (user,owner)
*/

PROCEDURE INSERT_ACC (p_user_id IN NUMBER,p_owner_id IN NUMBER)
IS
l_sqlerrno 	VARCHAR(20);
l_sqlerrmsg 	VARCHAR(4000);
l_error_msg	VARCHAR(4000);
l_access_id     NUMBER;
l_markdirty     BOOLEAN;


g_pub_item varchar2(30) := 'CSF_M_USER';


CURSOR c_user_acc(b_user_id NUMBER,b_owner_id NUMBER)
IS
SELECT ACCESS_ID
FROM CSM_USER_ACC
WHERE USER_ID=b_user_id
AND OWNER_ID = b_owner_id;

BEGIN
   CSM_UTIL_PKG.LOG('Entering INSERT_ACC for User_id ' || p_user_id ||' and owner_id: '||p_owner_id,
     'CSM_USER_EVENT_PKG.INSERT_ACC',FND_LOG.LEVEL_PROCEDURE);

   OPEN  c_user_acc(p_user_id,p_owner_id);
   FETCH c_user_acc INTO l_access_id;
   IF c_user_acc%FOUND THEN
     CSM_UTIL_PKG.LOG('Record already there in the Access table: (User_id,owner_id) : (' || p_user_id||','||p_owner_id||')',
     'CSM_USER_EVENT_PKG.INSERT_ACC',FND_LOG.LEVEL_PROCEDURE);
     UPDATE CSM_USER_ACC SET COUNTER=COUNTER+1 ,LAST_UPDATE_DATE=sysdate WHERE ACCESS_ID=l_access_id;
     CLOSE c_user_acc;
   ELSE

     CLOSE c_user_acc;

     SELECT CSM_USER_ACC_S.NEXTVAL INTO l_access_id  FROM DUAL;

     INSERT INTO CSM_USER_ACC(ACCESS_ID,USER_ID,OWNER_ID,COUNTER,LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN)
     VALUES     (l_access_id,p_user_id,p_owner_id,1,sysdate,1,sysdate,1,1);

     CSM_UTIL_PKG.LOG('Record inserted into the Access table: (User_id,owner_id) : (' || p_user_id||','||p_owner_id||') and Marking dirty',
       'CSM_USER_EVENT_PKG.INSERT_ACC',FND_LOG.LEVEL_PROCEDURE);

     l_markdirty := asg_download.mark_dirty(
        p_pub_item         => g_pub_item
      , p_accessid         => l_access_id
      , p_userid           => p_owner_id
      , p_dml              => 'I'
      , P_TIMESTAMP        => sysdate
      );
   END IF;

   CSM_UTIL_PKG.LOG('Leaving INSERT_ACC for User_id ' || p_user_id ||' and owner_id: '||p_owner_id,'CSM_USER_EVENT_PKG.INSERT_ACC',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
	 WHEN OTHERS THEN
	  l_sqlerrno  := TO_CHAR(SQLCODE);
	  l_sqlerrmsg := TO_CHAR(SQLERRM);
	  l_error_msg := 'Exception in 	INSERT_ACC for User_id '
	  || TO_CHAR(p_user_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;

	  CSM_UTIL_PKG.LOG(l_error_msg,'CSM_USER_EVENT_PKG.INSERT_ACC',FND_LOG.LEVEL_EXCEPTION);
       RAISE;
END INSERT_ACC;

PROCEDURE DELETE_ACC (p_user_id IN NUMBER,p_owner_id IN NUMBER)
IS
l_sqlerrno 	VARCHAR(20);
l_sqlerrmsg 	VARCHAR(4000);
l_error_msg	VARCHAR(4000);
l_access_id     NUMBER;
l_markdirty     BOOLEAN;
g_pub_item varchar2(30) := 'CSF_M_USER';
l_counter NUMBER;

CURSOR c_user_acc(b_user_id NUMBER,b_owner_id NUMBER)
IS
SELECT access_id,counter
FROM CSM_USER_ACC
WHERE USER_ID=b_user_id
AND OWNER_ID = b_owner_id;

BEGIN
   CSM_UTIL_PKG.LOG('Entering DELETE_ACC for User_id ' || p_user_id ||' and owner_id: '||p_owner_id,
     'CSM_USER_EVENT_PKG.DELETE_ACC',FND_LOG.LEVEL_PROCEDURE);

   OPEN  c_user_acc(p_user_id,p_owner_id);
   FETCH c_user_acc INTO l_access_id,l_counter;

   IF c_user_acc%FOUND THEN
     IF l_counter=1 THEN
          l_markdirty := asg_download.mark_dirty(
            p_pub_item         => g_pub_item
          , p_accessid         => l_access_id
          , p_userid           => p_owner_id
          , p_dml              => 'D'
          , P_TIMESTAMP        => sysdate
          );

       DELETE FROM CSM_USER_ACC WHERE USER_ID =p_user_id
 	   AND OWNER_ID=p_owner_id;
     ELSE
       UPDATE CSM_USER_ACC SET COUNTER=COUNTER-1 ,LAST_UPDATE_DATE=sysdate WHERE USER_ID =p_user_id
       AND OWNER_ID=p_owner_id;
     END IF;
   END IF;

   CSM_UTIL_PKG.LOG('Leaving DELETE_ACC for User_id ' || p_user_id ||' and owner_id: '||p_owner_id,
     'CSM_USER_EVENT_PKG.DELETE_ACC',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
	 WHEN OTHERS THEN
	  l_sqlerrno  := TO_CHAR(SQLCODE);
	  l_sqlerrmsg := TO_CHAR(SQLERRM);
	  l_error_msg := 'Exception in 	DELETE_ACC for User_id '
	  || TO_CHAR(p_user_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;

	  CSM_UTIL_PKG.LOG(l_error_msg,'CSM_USER_EVENT_PKG.DELETE_ACC',FND_LOG.LEVEL_EXCEPTION);
          RAISE;
END DELETE_ACC;


END CSM_USER_EVENT_PKG;

/
