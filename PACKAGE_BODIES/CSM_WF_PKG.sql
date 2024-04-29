--------------------------------------------------------
--  DDL for Package Body CSM_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_WF_PKG" AS
/* $Header: csmewfb.pls 120.12.12010000.7 2010/04/26 07:42:04 saradhak ship $ */
/*--------------------------------------------------
  Description:
    Acts as the entry point to CSM logic from user and
    vertical hooks as well as from concurrent programs.

    12/16/02 ANURAG Workflow threshold value is now restored
----------------------------------------------------*/

-- stores the old organization_id and old_subinventory_code for
-- the upd on csp_inv_loc_assignments
g_old_subinventory_code csp_inv_loc_assignments.subinventory_code%TYPE;
g_old_organization_id csp_inv_loc_assignments.organization_id%TYPE;
g_old_eff_date_start date;
g_old_eff_date_end date;
g_old_default_code csp_inv_loc_assignments.default_code%TYPE;
g_task_downloaded_to_owner BOOLEAN;

TYPE g_task_ass_pre_upd_typ IS RECORD(
 resource_id NUMBER,
 assignment_status_id NUMBER,
 task_id NUMBER
);

g_task_ass_pre_upd_rec g_task_ass_pre_upd_typ;
g_null_task_ass_pre_upd_typ g_task_ass_pre_upd_typ;

TYPE g_task_pre_upd_typ IS RECORD(
 task_status_id NUMBER,
 task_type_id NUMBER,
 scheduled_start_date DATE,
 scheduled_end_date DATE,
 task_id NUMBER
);

g_task_pre_upd_rec g_task_pre_upd_typ;
g_null_task_pre_upd_typ g_task_pre_upd_typ;

TYPE g_sr_pre_upd_typ IS  RECORD(
  INCIDENT_ID         NUMBER,
  CUSTOMER_ID         NUMBER,
  INSTALL_SITE_ID     NUMBER,
  CUSTOMER_PRODUCT_ID NUMBER,
  INVENTORY_ITEM_ID   NUMBER,
  INV_ORGANIZATION_ID NUMBER,
  CONTRACT_SERVICE_ID NUMBER,
  PARTY_ID            NUMBER,
  LOCATION_ID         NUMBER,
  INCIDENT_LOCATION_ID NUMBER,
  OWNER_GROUP_ID       NUMBER
);

g_sr_pre_upd_rec g_sr_pre_upd_typ;
g_null_sr_pre_upd_rec g_sr_pre_upd_typ;

TYPE g_debrief_line_pre_upd_typ IS RECORD(
  DEBRIEF_LINE_ID NUMBER,
  INVENTORY_ITEM_ID NUMBER,
  INSTANCE_ID NUMBER
);

g_debrief_line_pre_upd_rec g_debrief_line_pre_upd_typ;
g_null_debrief_ln_pre_upd_rec g_debrief_line_pre_upd_typ;

--
--This table will hold the contacts and contact information
--for a Service Request customer
--
TYPE contacts_rec IS RECORD (
    SR_CONTACT_POINT_ID            NUMBER            ,
    PARTY_ID                       NUMBER            ,
    CONTACT_POINT_ID               NUMBER            ,
    PRIMARY_FLAG                   VARCHAR2(1)       ,
    CONTACT_POINT_TYPE             VARCHAR2(30)      ,
    CONTACT_TYPE                   VARCHAR2(30)      ,
    LAST_UPDATE_DATE               DATE              ,
    CREATION_DATE                  DATE
);

TYPE contacts_table_typ IS TABLE OF contacts_rec INDEX BY BINARY_INTEGER;

g_sr_cont_points_pre_upd_tbl contacts_table_typ;
g_sr_cont_points_post_upd_tbl contacts_table_typ;
g_null_sr_cont_points_tbl contacts_table_typ;

/*
 * Private function
 */
/*
 * IS_TASK_STATUS_DOWNLOADABLE
 * --------------------------
 * Function to test whether the task status makes the task/task assignment to be downloaded
 * according to the criteria for Field Service / Palm.
 */

FUNCTION IS_TASK_STATUS_DOWNLOADABLE(
   p_task_id IN NUMBER,
   p_status_id IN NUMBER
) RETURN BOOLEAN
IS
CURSOR c_task_status (p_task_id in NUMBER, b_status_id NUMBER)
IS
SELECT 1
FROM jtf_tasks_b jt
WHERE jt.task_id = p_task_id
AND (jt.source_object_type_code = 'TASK'  OR jt.source_object_type_code IS NULL)
UNION
SELECT 1
FROM jtf_task_statuses_b jts
WHERE jts.task_status_id = b_status_id
AND ( jts.ASSIGNED_FLAG = 'Y'
   OR jts.COMPLETED_FLAG = 'Y'
   OR jts.CLOSED_FLAG = 'Y');

l_status_id NUMBER;
BEGIN
--  CSM_UTIL_PKG.pvt_log('Enter IS_TASK_STATUS_DOWNLOADABLE ' || p_status_id);
  OPEN c_task_status(p_task_id, p_status_id);
  FETCH c_task_status INTO l_status_id;
  IF c_task_status%FOUND THEN
    CLOSE c_task_status;
    RETURN TRUE;
  END IF;
  CLOSE c_task_status;
  RETURN FALSE;
EXCEPTION
  WHEN OTHERS THEN
    IF c_task_status%ISOPEN THEN
      CLOSE c_task_status;
    END IF;
    RETURN FALSE;
END IS_TASK_STATUS_DOWNLOADABLE;

/*
 * IS_TASK_DOWNLOADABLE
 * --------------------------
 * Function to test whether the task status, type,
 * schedule_start_date, scheduled_end_date make the task/task assignment to be downloaded
 * according to the criteria for Field Service / Palm.
 */

FUNCTION IS_TASK_DOWNLOADABLE(
   p_task_id IN NUMBER,
   p_status_id IN NUMBER,
   p_type_id IN NUMBER,
   p_schedule_start_date IN DATE,
   p_schedule_end_date IN DATE
) RETURN BOOLEAN
IS
CURSOR c_task_status (p_task_id IN NUMBER, b_status_id NUMBER) IS
SELECT 1
FROM jtf_tasks_b jt
WHERE jt.task_id = p_task_id
AND (jt.source_object_type_code = 'TASK'  OR jt.source_object_type_code IS NULL)
UNION
SELECT 1
FROM jtf_task_statuses_b jts
WHERE jts.task_status_id = b_status_id
AND ( jts.ASSIGNED_FLAG = 'Y'
   OR jts.COMPLETED_FLAG = 'Y'
   OR jts.CLOSED_FLAG = 'Y');

CURSOR c_task_type (b_type_id NUMBER) IS
SELECT 1
FROM JTF_TASK_TYPES_B
WHERE TASK_TYPE_ID = b_type_id
AND (RULE = 'DISPATCH' OR private_flag = 'Y');

l_temp      NUMBER := NULL;

BEGIN
  OPEN c_task_status(p_task_id, p_status_id);
  FETCH c_task_status INTO l_temp;
  CLOSE c_task_status;

  IF l_temp IS NULL THEN
--    CSM_UTIL_PKG.pvt_log('IS_TASK_STATUS_DOWNLOADABLE(' || p_status_id || ') = FALSE' );
    RETURN FALSE;
  END IF;

  l_temp := NULL;
  OPEN c_task_type(p_type_id);
  FETCH c_task_type INTO l_temp;
  CLOSE c_task_type;

 -- IF c_task_type%NOTFOUND THEN
   IF l_temp IS NULL THEN
--    CSM_UTIL_PKG.pvt_log('IS_TASK_TYPE_DOWNLOADABLE(' || p_type_id || ') = FALSE' );
    RETURN FALSE;
  END IF;
  IF ( p_schedule_start_date IS NULL OR p_schedule_end_date IS NULL ) THEN
--    CSM_UTIL_PKG.pvt_log('IS_TASK_SCHEDULED_DATE_DOWNLOADABLE(' || p_schedule_start_date  || ', ' || p_schedule_end_date || ') = FALSE' );
    RETURN FALSE;
  END IF;

--  CSM_UTIL_PKG.pvt_log('IS_TASK_DOWNLOADABLE = TRUE' );
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
--    CSM_UTIL_PKG.pvt_log('EXCEPTION IN IS_TASK_DOWNLOADABLE. Return FALSE' );
    RETURN FALSE;
END IS_TASK_DOWNLOADABLE;

/*
 * public functions
 */
/* Starts TASK_INS workflow, Should be called when new TASK is created */
/* If the task is an escalated task, check if it is an escalated task for existing mobile task.
   If yes, we call task upd
*/
--12.1
Procedure TASK_Post_Ins(
    x_return_status     OUT NOCOPY      VARCHAR2
)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_user_id number;
l_task_id JTF_TASKS_B.TASK_ID%TYPE;

CURSOR l_task_csr (b_task_id NUMBER) IS
SELECT jt.CREATED_BY, jtt.private_flag, jt.source_object_type_code  -- 22 means Escalation task
FROM JTF_TASKS_B jt,
     jtf_task_types_b jtt
WHERE jt.TASK_ID = b_task_id
AND jtt.task_type_id = jt.task_type_id;

l_task_rec l_task_csr%ROWTYPE;

--12.1XB7
CURSOR c_sr_grp_owner(b_task_id number) IS
 SELECT USER_ID
 FROM ASG_USER usr,
      CS_INCIDENTS_ALL_B inc,
      JTF_TASKS_B tsk
 WHERE tsk.TASK_ID=b_task_id
 AND   tsk.SOURCE_OBJECT_TYPE_CODE='SR'
 AND   tsk.SOURCE_OBJECT_ID=inc.INCIDENT_ID
 AND  (
        (inc.owner_group_id IS NOT NULL
         AND usr.GROUP_ID=inc.owner_group_id --is_mfs_grp
   	     AND usr.USER_ID=usr.OWNER_ID
         )
        OR
        ((
		  (inc.owner_group_id IS NOT NULL
           AND not exists (select 1 from asg_user where group_id=inc.owner_group_id) --is_not mfs_grp
		   )
	     OR
          (inc.owner_group_id IS NULL)
		 )
         AND usr.USER_ID=inc.created_by
        )
       );

l_PK_NAME_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
l_PK_TYPE_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
l_pk_value_list  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');

BEGIN
  l_task_id := jtf_tasks_pub.p_task_user_hooks.task_id;

  l_PK_NAME_LIST(1):='TASK_ID'; l_PK_TYPE_LIST(1):='NUMBER'; l_pk_value_list(1):= to_char(l_task_id);
  CSM_HA_EVENT_PKG.TRACK_HA_RECORD('JTF_TASKS_B',l_PK_NAME_LIST,l_PK_TYPE_LIST,l_pk_value_list,'I');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  IF CSM_SR_EVENT_PKG.is_sr_downloaded_to_owner(l_task_id) THEN
   OPEN c_sr_grp_owner(l_task_id);
   FETCH c_sr_grp_owner INTO l_user_id;
   CLOSE c_sr_grp_owner;

   csm_task_event_pkg.acc_insert(p_task_id=>l_task_id,p_user_id=>l_user_id);
  END IF;

  csm_task_event_pkg.task_ins_init(p_task_id=>l_task_id);

EXCEPTION
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     l_error_msg := ' Exception in  TASK_POST_INS for task_id:'
                       || to_char(l_task_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
     CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_WF_PKG.TASK_POST_INS',FND_LOG.LEVEL_EXCEPTION);
END TASK_POST_INS;


/* Starts TASK_DEL workflow, Should be called when new SR is created */
Procedure TASK_Post_DEL(
    x_return_status     OUT NOCOPY      VARCHAR2
)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

l_task_id JTF_TASKS_B.TASK_ID%TYPE;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  l_task_id := jtf_tasks_pub.p_task_user_hooks.task_id;

  csm_task_event_pkg.task_del_init(p_task_id=>l_task_id);

EXCEPTION
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     l_error_msg := ' Exception in  TASK_POST_DEL for task_id:'
                       || to_char(l_task_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
     CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_WF_PKG.TASK_POST_DEL',FND_LOG.LEVEL_EXCEPTION);
END TASK_POST_DEL;

/* Task_Assignment_Post_Ins
 */
--12.1
Procedure Task_Assignment_Post_Ins(
    x_return_status     OUT NOCOPY      VARCHAR2
)
IS
l_task_assignment_id number(15);
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_task_id NUMBER;
l_user_id NUMBER;
l_assignee_id NUMBER;
l_owner_resource_id number;

--12.1XB7
CURSOR c_sr_grp_owner(b_task_id number) IS
 SELECT USER_ID
 FROM ASG_USER usr,
      CS_INCIDENTS_ALL_B inc,
      JTF_TASKS_B tsk
 WHERE tsk.TASK_ID=b_task_id
 AND   tsk.SOURCE_OBJECT_TYPE_CODE='SR'
 AND   tsk.SOURCE_OBJECT_ID=inc.INCIDENT_ID
 AND  (
        (inc.owner_group_id IS NOT NULL
         AND usr.GROUP_ID=inc.owner_group_id --is_mfs_grp
   	     AND usr.USER_ID=usr.OWNER_ID
         )
        OR
        ((
		  (inc.owner_group_id IS NOT NULL
           AND not exists (select 1 from asg_user where group_id=inc.owner_group_id) --is_not mfs_grp
		   )
	     OR
          (inc.owner_group_id IS NULL)
		 )
         AND usr.USER_ID=inc.created_by
        )
       );



CURSOR c_task(b_task_assignment_id NUMBER)
IS
select task_id,resource_id
from JTF_TASK_ASSIGNMENTS
where TASK_ASSIGNMENT_ID=b_task_assignment_id;



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

l_PK_NAME_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
l_PK_TYPE_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
l_pk_value_list  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');

BEGIN

  l_task_assignment_id := jtf_task_assignments_pub.p_task_assignments_user_hooks.task_assignment_id;



  l_PK_NAME_LIST(1):='TASK_ASSIGNMENT_ID'; l_PK_TYPE_LIST(1):='NUMBER'; l_pk_value_list(1):= to_char(l_task_assignment_id);
  CSM_HA_EVENT_PKG.TRACK_HA_RECORD('JTF_TASK_ALL_ASSIGNMENTS',l_PK_NAME_LIST,l_PK_TYPE_LIST,l_pk_value_list,'I');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  open c_task(l_task_assignment_id);
  fetch c_task into l_task_id,l_assignee_id;
  close c_task;

  IF CSM_SR_EVENT_PKG.is_sr_downloaded_to_owner(l_task_id) THEN
    OPEN c_sr_grp_owner(l_task_id);
    FETCH c_sr_grp_owner INTO l_user_id;
    CLOSE c_sr_grp_owner;

    csm_task_assignment_event_pkg.acc_insert(p_task_assignment_id=>l_task_assignment_id,p_user_id=>l_user_id);

  -- to download other grp's resource if required
    OPEN c_resource_id(l_user_id);
    FETCH c_resource_id INTO l_owner_resource_id;
    CLOSE c_resource_id;
    IF NOT CSM_UTIL_PKG.from_same_group(l_owner_resource_id,l_assignee_id) THEN
--assignee bug
      OPEN c_user_id(l_assignee_id);
      FETCH c_user_id INTO l_assignee_user_id;
      CLOSE c_user_id;
      IF l_assignee_user_id IS NOT NULL THEN
       CSM_USER_EVENT_PKG.INSERT_ACC(l_assignee_user_id,l_user_id);
      END IF;
    END IF;
  END IF;

  csm_task_assignment_event_pkg.task_assignment_initializer(p_task_assignment_id=>l_task_assignment_id,
                                                            p_error_msg=>l_error_msg,
                                                            x_return_status=>l_return_status);

--Notify user of Task Assignment Insert with Start Sync Event
  RAISE_START_AUTO_SYNC_EVENT('CSM_TASK_ASSIGNMENTS',to_char(l_task_assignment_id),'NEW');

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    l_error_msg := l_error_msg || '-Exception for Task_Assignment_Post_Ins :' || TO_CHAR(l_task_assignment_id)
                 || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
    CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_WF_PKG.Task_Assignment_Post_Ins',FND_LOG.LEVEL_EXCEPTION);
END Task_Assignment_Post_Ins;

/*-----------------------------------------------------------------
  Description:
    Start the TASK_ASSIGNMENT_UPD process. Called by
    JTF_TASK_ASSIGNMENTS_IUHK.update_task_assignment_pre
    We retrieve the old record by selecting from db with task_assignment_id
    Then, we compare the old resource id and new resource id for whether the resource has changed.
  Parameter(s):
    x_return_status
------------------------------------------------------------------*/
Procedure Task_Assignment_Pre_Upd(x_return_status     OUT NOCOPY      VARCHAR2)
IS
l_task_assignment_id NUMBER;
l_user_id NUMBER;
l_dummy NUMBER;
l_access_id NUMBER;
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_task_ass_pre_csr (b_task_assignment_id NUMBER) IS
SELECT RESOURCE_ID, assignment_status_id, task_id
FROM JTF_TASK_ASSIGNMENTS
WHERE TASK_ASSIGNMENT_ID = b_task_assignment_id;

CURSOR l_get_user_id(p_resource_id IN NUMBER)
IS
SELECT jtrs.user_id
FROM jtf_rs_resource_extns jtrs
WHERE jtrs.resource_id = p_resource_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  l_task_assignment_id := jtf_task_assignments_pub.p_task_assignments_user_hooks.task_assignment_id;

  -- initialize the rec
  g_task_ass_pre_upd_rec := g_null_task_ass_pre_upd_typ;

  --  retrieve the old resource_id.
  OPEN l_task_ass_pre_csr (l_task_assignment_id);
  FETCH l_task_ass_pre_csr INTO g_task_ass_pre_upd_rec;
  IF l_task_ass_pre_csr%NOTFOUND
  THEN
    close l_task_ass_pre_csr;
    return;
  END IF;
  CLOSE l_task_ass_pre_csr;

  -- if old_resource_id and new resource_id are not mobile users then return
  IF (( NOT CSM_UTIL_PKG.is_palm_resource(g_task_ass_pre_upd_rec.resource_id)) AND
      ( NOT CSM_UTIL_PKG.is_palm_resource(jtf_task_assignments_pub.p_task_assignments_user_hooks.resource_id))) THEN
      RETURN;
  END IF;

  -- And check if resource id has changed
  IF NVL(g_task_ass_pre_upd_rec.resource_id, -1) <> NVL(jtf_task_assignments_pub.p_task_assignments_user_hooks.resource_id, -1)
  THEN
    -- do the purge for the old resource in the pre-hook if its a mobile resource
    IF CSM_UTIL_PKG.is_palm_resource(g_task_ass_pre_upd_rec.resource_id) THEN
      csm_task_assignment_event_pkg.TASK_ASSIGNMENT_PURGE_INIT(p_task_assignment_id=>l_task_assignment_id,
                                                           p_error_msg=>l_error_msg,
                                                           x_return_status=>l_return_status);
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    l_error_msg := l_error_msg || '-Exception for Task_Assignment_Pre_Upd :' || TO_CHAR(l_task_assignment_id)
                 || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
    CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_WF_PKG.Task_Assignment_Pre_Upd',FND_LOG.LEVEL_EXCEPTION);
END Task_Assignment_Pre_Upd;

PROCEDURE Task_Assignment_Post_Upd(
     x_return_status     OUT NOCOPY      VARCHAR2
)
IS
l_task_assignment_id NUMBER;
l_is_resource_updated VARCHAR2(1);
l_is_assg_status_updated VARCHAR2(1);
l_dummy NUMBER;
l_dml VARCHAR2(1);
l_timestamp DATE;
l_publicationitemname VARCHAR2(50);
l_markdirty BOOLEAN;
l_access_id NUMBER;
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_task_ass_post_csr (b_task_assignment_id NUMBER)
IS
SELECT RESOURCE_ID, assignment_status_id, task_id
FROM JTF_TASK_ASSIGNMENTS
WHERE TASK_ASSIGNMENT_ID = b_task_assignment_id;

l_task_ass_post_upd_rec l_task_ass_post_csr%ROWTYPE;
l_null_task_ass_post_upd_rec l_task_ass_post_csr%ROWTYPE;

CURSOR l_check_acc_exists(p_task_assignment_id IN number)
IS
SELECT access_id
FROM csm_task_assignments_acc
WHERE task_assignment_id = p_task_assignment_id;

l_task_id NUMBER;
l_owner_id NUMBER;
l_owner_resource_id number;

--12.1XB7
CURSOR c_sr_grp_owner(b_task_id number) IS
 SELECT USER_ID
 FROM ASG_USER usr,
      CS_INCIDENTS_ALL_B inc,
      JTF_TASKS_B tsk
 WHERE tsk.TASK_ID=b_task_id
 AND   tsk.SOURCE_OBJECT_TYPE_CODE='SR'
 AND   tsk.SOURCE_OBJECT_ID=inc.INCIDENT_ID
 AND  (
        (inc.owner_group_id IS NOT NULL
         AND usr.GROUP_ID=inc.owner_group_id --is_mfs_grp
   	     AND usr.USER_ID=usr.OWNER_ID
         )
        OR
        ((
		  (inc.owner_group_id IS NOT NULL
           AND not exists (select 1 from asg_user where group_id=inc.owner_group_id) --is_not mfs_grp
		   )
	     OR
          (inc.owner_group_id IS NULL)
		 )
         AND usr.USER_ID=inc.created_by
        )
       );



CURSOR c_task(b_task_assignment_id NUMBER)
IS
select task_id
from JTF_TASK_ASSIGNMENTS
where TASK_ASSIGNMENT_ID=b_task_assignment_id;


CURSOR c_resource_id(b_user_id NUMBER) IS
SELECT RESOURCE_ID
FROM JTF_RS_RESOURCE_EXTNS
WHERE USER_ID=b_user_id;

CURSOR c_access(b_task_assignment_id NUMBER,b_user_id NUMBER)
IS
SELECT ACCESS_ID
FROM CSM_TASK_ASSIGNMENTS_ACC
WHERE TASK_ASSIGNMENT_ID=b_task_assignment_id
AND   USER_ID=b_user_id;

--assignee bug
CURSOR c_user_id(b_resource_id NUMBER) IS
SELECT USER_ID
FROM JTF_RS_RESOURCE_EXTNS
WHERE RESOURCE_ID=b_resource_id;

l_assignee_user_id NUMBER;


l_PK_NAME_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
l_PK_TYPE_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
l_pk_value_list  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
BEGIN

  l_task_assignment_id := jtf_task_assignments_pub.p_task_assignments_user_hooks.task_assignment_id;

  l_PK_NAME_LIST(1):='TASK_ASSIGNMENT_ID'; l_PK_TYPE_LIST(1):='NUMBER'; l_pk_value_list(1):= to_char(l_task_assignment_id);
  CSM_HA_EVENT_PKG.TRACK_HA_RECORD('JTF_TASK_ALL_ASSIGNMENTS',l_PK_NAME_LIST,l_PK_TYPE_LIST,l_pk_value_list,'U');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  CSM_UTIL_PKG.LOG('Entering CSM_WF_PKG.Task_Assignment_Post_Upd for task_assg_id:' || l_task_assignment_id ,
                         'CSM_WF_PKG.Task_Assignment_Post_Upd',FND_LOG.LEVEL_PROCEDURE);

  -- initialise the flags
  l_is_resource_updated := 'N';
  l_is_assg_status_updated := 'N';
  l_publicationitemname := 'CSM_TASK_ASSIGNMENTS';
  l_dml := 'U';
  l_task_ass_post_upd_rec := l_null_task_ass_post_upd_rec;

  --  retrieve the new resource_id, assignment_status_id
  OPEN l_task_ass_post_csr (l_task_assignment_id);
  FETCH l_task_ass_post_csr INTO l_task_ass_post_upd_rec;
  IF l_task_ass_post_csr%NOTFOUND
  THEN
    CLOSE l_task_ass_post_csr;
    RETURN;
  END IF;
  CLOSE l_task_ass_post_csr;

/********12.1: FOR SR GROUP OWNER - Start of PROCESSING******/
  open c_task(l_task_assignment_id);
  fetch c_task into l_task_id;
  close c_task;

  IF CSM_SR_EVENT_PKG.is_sr_downloaded_to_owner(l_task_id) THEN
    OPEN c_sr_grp_owner(l_task_id);
    FETCH c_sr_grp_owner INTO l_owner_id;
    CLOSE c_sr_grp_owner;


    IF g_task_ass_pre_upd_rec.resource_id<>l_task_ass_post_upd_rec.resource_id THEN
     --    delete old resource_id from acc if he's not in any of his grp.
      OPEN c_resource_id(l_owner_id);
      FETCH c_resource_id INTO l_owner_resource_id;
      CLOSE c_resource_id;
      --old assignee
      IF NOT CSM_UTIL_PKG.from_same_group(l_owner_resource_id,g_task_ass_pre_upd_rec.resource_id) THEN
      --assignee bug
        l_assignee_user_id:=NULL;
        OPEN c_user_id(g_task_ass_pre_upd_rec.resource_id);
        FETCH c_user_id INTO l_assignee_user_id;
        CLOSE c_user_id;
        IF l_assignee_user_id IS NOT NULL THEN
         CSM_USER_EVENT_PKG.DELETE_ACC(l_assignee_user_id,l_owner_id);
        END IF;
      END IF;

      --new assignee
      IF NOT CSM_UTIL_PKG.from_same_group(l_owner_resource_id,l_task_ass_post_upd_rec.resource_id) THEN
       --assignee bug
        l_assignee_user_id:=NULL;
        OPEN c_user_id(l_task_ass_post_upd_rec.resource_id);
        FETCH c_user_id INTO l_assignee_user_id;
        CLOSE c_user_id;
        IF l_assignee_user_id IS NOT NULL THEN
         CSM_USER_EVENT_PKG.INSERT_ACC(l_assignee_user_id,l_owner_id);
        END IF;
      END IF;

    END IF;

   OPEN  c_access(l_task_assignment_id,l_owner_id);
   FETCH c_access INTO l_access_id;
   CLOSE  c_access;

   l_markdirty:=CSM_UTIL_PKG.MakeDirtyForUser('CSM_TASK_ASSIGNMENTS',l_access_id,l_owner_id,'U',sysdate);

  END IF;

/******** FOR SR GROUP OWNER - END of PROCESSING******/


  -- if old_resource_id and new resource_id are not mobile users then return
  IF (( NOT CSM_UTIL_PKG.is_palm_resource(g_task_ass_pre_upd_rec.resource_id)) AND
      ( NOT CSM_UTIL_PKG.is_palm_resource(l_task_ass_post_upd_rec.resource_id))) THEN
     CSM_UTIL_PKG.LOG('No mobile resource for task_assg_id:' || l_task_assignment_id ,
                         'CSM_WF_PKG.Task_Assignment_Post_Upd',FND_LOG.LEVEL_PROCEDURE);
      RETURN;
  END IF;

  -- And check if resource id has changed
  IF g_task_ass_pre_upd_rec.resource_id <> l_task_ass_post_upd_rec.resource_id
  THEN
    CSM_UTIL_PKG.LOG('Resource updated for task_assg_id:' || l_task_assignment_id ,
                         'CSM_WF_PKG.Task_Assignment_Post_Upd',FND_LOG.LEVEL_PROCEDURE);

    l_is_resource_updated := 'Y';
    OPEN l_check_acc_exists(l_task_assignment_id);
    FETCH l_check_acc_exists INTO l_dummy;
    IF l_check_acc_exists%NOTFOUND THEN
--     csm_wf_pkg.Task_Assignment_Post_Ins(l_return_status);
        csm_task_assignment_event_pkg.task_assignment_initializer(p_task_assignment_id=>l_task_assignment_id,
                                                                  p_error_msg=>l_error_msg,
                                                                  x_return_status=>l_return_status);
        --call Start Sync event - Notify Client
        RAISE_START_AUTO_SYNC_EVENT('CSM_TASK_ASSIGNMENTS',to_char(l_task_assignment_id),'NEW');

       CLOSE l_check_acc_exists;

       RETURN;
    END IF;
    CLOSE l_check_acc_exists;
  ELSE
    l_is_resource_updated := 'N';
  END IF;

  -- And check if task_assignment_status has changed
  IF g_task_ass_pre_upd_rec.assignment_status_id <> l_task_ass_post_upd_rec.assignment_status_id
  THEN
    CSM_UTIL_PKG.LOG('Status updated for task_assg_id:' || l_task_assignment_id ,
                         'CSM_WF_PKG.Task_Assignment_Post_Upd',FND_LOG.LEVEL_PROCEDURE);

    l_is_assg_status_updated := 'Y';

    -- if both are not downloadable, or both are downloadable, UPDATE process
    -- if old status is not downloadable, and new status is downloadable,
        -- if l_is_resource_updated = 'N', INSERT process
        -- if l_is_resource_updated := 'Y', UPDATE process which will call INSERT process
    IF ( ( NOT IS_TASK_STATUS_DOWNLOADABLE(g_task_ass_pre_upd_rec.task_id, g_task_ass_pre_upd_rec.assignment_status_id))
        AND IS_TASK_STATUS_DOWNLOADABLE(l_task_ass_post_upd_rec.task_id, l_task_ass_post_upd_rec.assignment_status_id)
        AND l_is_resource_updated = 'N') THEN
       CSM_UTIL_PKG.LOG('Status updated to downloadable for task_assg_id:' || l_task_assignment_id ,
                         'CSM_WF_PKG.Task_Assignment_Post_Upd',FND_LOG.LEVEL_PROCEDURE);

--      Task_Assignment_Post_Ins( x_return_status );
        csm_task_assignment_event_pkg.task_assignment_initializer(p_task_assignment_id=>l_task_assignment_id,
                                                                  p_error_msg=>l_error_msg,
                                                                  x_return_status=>l_return_status);
        RAISE_START_AUTO_SYNC_EVENT('CSM_TASK_ASSIGNMENTS',to_char(l_task_assignment_id),'NEW');
      RETURN;
    END IF;

    -- if old status is downloadable, and new status NOT,
        -- if l_is_resource_updated = 'N' and l_resource_id is mobile, PURGE/DELETE process
        -- if l_is_resource_updated := 'Y', UPDATE process which will call PURGE process
    IF ( IS_TASK_STATUS_DOWNLOADABLE(g_task_ass_pre_upd_rec.task_id, g_task_ass_pre_upd_rec.assignment_status_id )
        AND (NOT IS_TASK_STATUS_DOWNLOADABLE(l_task_ass_post_upd_rec.task_id, l_task_ass_post_upd_rec.assignment_status_id))
        AND l_is_resource_updated = 'N') THEN
       CSM_UTIL_PKG.LOG('Status updated to non-downloadable for task_assg_id:' || l_task_assignment_id ,
                         'CSM_WF_PKG.Task_Assignment_Post_Upd',FND_LOG.LEVEL_PROCEDURE);

      Task_Assignment_Post_Del( x_return_status );
      RETURN;
    END IF;
  ELSE
    l_is_assg_status_updated := 'N';
  END IF;

--Bug 5182470
-- MP: If resource is not updated, then record should be there in the access table
   IF l_is_resource_updated = 'N' THEN
     OPEN l_check_acc_exists(l_task_assignment_id);
     FETCH l_check_acc_exists INTO l_access_id;
     IF l_check_acc_exists%NOTFOUND THEN
         CLOSE l_check_acc_exists;
         RETURN;
     END IF;
     CLOSE l_check_acc_exists;
     l_markdirty := csm_util_pkg.MakeDirtyForResource(l_publicationitemname,
                                                     l_access_id,
                                                     l_task_ass_post_upd_rec.resource_id,
                                                     l_dml,
                                                     sysdate);
     RAISE_START_AUTO_SYNC_EVENT('CSM_TASK_ASSIGNMENTS',to_char(l_task_assignment_id),'UPDATE');

   ELSIF l_is_resource_updated = 'Y' THEN
     -- check if the new resource is a mobile resource; if it is then do a insert
     -- the old resource is dropped in the pre-upd hook
      IF CSM_UTIL_PKG.is_palm_resource(l_task_ass_post_upd_rec.resource_id) THEN
--        csm_wf_pkg.Task_Assignment_Post_Ins(l_return_status);
        csm_task_assignment_event_pkg.task_assignment_initializer(p_task_assignment_id=>l_task_assignment_id,
                                                                  p_error_msg=>l_error_msg,
                                                                  x_return_status=>l_return_status);
        RAISE_START_AUTO_SYNC_EVENT('CSM_TASK_ASSIGNMENTS',to_char(l_task_assignment_id),'NEW');
      END IF;
   END IF;

  CSM_UTIL_PKG.LOG('Leaving CSM_WF_PKG.Task_Assignment_Post_Upd for task_assg_id:' || l_task_assignment_id ,
                         'CSM_WF_PKG.Task_Assignment_Post_Upd',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    l_error_msg := l_error_msg || '-Exception for Task_Assignment_Post_Upd :' || TO_CHAR(l_task_assignment_id)
                 || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
    CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_WF_PKG.Task_Assignment_Post_Upd',FND_LOG.LEVEL_EXCEPTION);
END Task_Assignment_Post_Upd;

/*--------------------------------------------------------
  Description:
    Start the workflow process TASK_ASSIGNMENT_PURGE.
    Invoked by JTF_TASK_ASSIGNMENTS_IUHK.delete_task_assignment_post
    and by concurrent program to purge closed task assignments
    older than specified in profile: CSF_M_HISTORY.
  Parameter(s):
    x_return_status
--------------------------------------------------------*/
PROCEDURE Task_Assignment_Post_Del(
  x_return_status     OUT NOCOPY      VARCHAR2
)
IS
-- define the primary key and assign value from the global variable
l_task_assignment_id number(15);
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

l_PK_NAME_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
l_PK_TYPE_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
l_pk_value_list  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');

BEGIN

  l_task_assignment_id := jtf_task_assignments_pub.p_task_assignments_user_hooks.task_assignment_id;

  l_PK_NAME_LIST(1):='TASK_ASSIGNMENT_ID'; l_PK_TYPE_LIST(1):='NUMBER'; l_pk_value_list(1):= to_char(l_task_assignment_id);
  CSM_HA_EVENT_PKG.TRACK_HA_RECORD('JTF_TASK_ASSIGNMENTS',l_PK_NAME_LIST,l_PK_TYPE_LIST,l_pk_value_list,'D');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  csm_task_assignment_event_pkg.TASK_ASSIGNMENT_PURGE_INIT(p_task_assignment_id=>l_task_assignment_id,
                                                           p_error_msg=>l_error_msg,
                                                           x_return_status=>l_return_status);
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    l_error_msg := l_error_msg || '-Exception for Task_Assignment_Post_Del :' || TO_CHAR(l_task_assignment_id)
                 || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
    CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_WF_PKG.Task_Assignment_Post_Del',FND_LOG.LEVEL_EXCEPTION);
END Task_Assignment_Post_Del;

/*-----------------------------------------------------------------
  Description:
    Start the workflow process TASK_UPD_USERLOOP.
    Invoked by jtf_tasks_iuhk.update_task_pre
    The global variable for IUHK is: jtf_tasks_pub.p_task_user_hooks(.task_id)

    we check all the task_assignments, whether they are mobile users.
      No - nothing
      Yes - check task_status. Whether status changed
        No - if (task_assignment_acc record exists ) do UPDATE
        Yes - check old status and new status
           old downloadable, new NOT, TASK_ASSIGNMENT_PURGE
           old new both not downloadable, do nothing
           old new both downloadable, (if acc record exists)  do UPDATE
           old NOT, new downloadable, TASK_ASSIGNMENT_INS


  Parameter(s):
    x_return_status
------------------------------------------------------------------*/
Procedure Task_Pre_Upd ( x_return_status     OUT NOCOPY      VARCHAR2)
IS
l_jtf_task_id NUMBER;
l_err_msg VARCHAR2(4000);
l_return_status VARCHAR2(4000);
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_task_pre_upd_csr(b_task_id NUMBER)
IS
SELECT TASK_STATUS_ID, TASK_TYPE_ID, SCHEDULED_START_DATE, SCHEDULED_END_DATE, task_id
FROM JTF_TASKS_B
WHERE TASK_ID = b_task_id;


BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  l_jtf_task_id  := jtf_tasks_pub.p_task_user_hooks.task_id;


--used for TASK_TYPE CHANGE
  g_task_downloaded_to_owner:=CSM_SR_EVENT_PKG.is_sr_downloaded_to_owner(l_jtf_task_id);

  -- initialize the rec
  g_task_pre_upd_rec := g_null_task_pre_upd_typ;

  --  retrieve the record prior update.
  OPEN l_task_pre_upd_csr (l_jtf_task_id);
  FETCH l_task_pre_upd_csr INTO g_task_pre_upd_rec;
  IF l_task_pre_upd_csr%NOTFOUND
  THEN
    CLOSE l_task_pre_upd_csr;
    RETURN;
  END IF;
  CLOSE l_task_pre_upd_csr;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    l_error_msg := 'Exception in Task_Pre_Upd for task_id:' || TO_CHAR(l_jtf_task_id)
                 || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
    CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_WF_PKG.Task_Pre_Upd',FND_LOG.LEVEL_EXCEPTION);
END Task_Pre_Upd;

Procedure Task_Post_Upd (
  x_return_status     OUT NOCOPY      VARCHAR2
)
IS
TYPE id_list IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_jtf_task_id NUMBER;
l_task_assignment_list    id_list;
l_user_list               id_list;
l_resource_list           id_list;
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(4000);
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);

CURSOR c_task_ass_csr (b_task_id NUMBER) IS
SELECT rs.RESOURCE_ID, rs.USER_ID, tas.TASK_ASSIGNMENT_ID
FROM JTF_TASK_ASSIGNMENTS tas, JTF_RS_RESOURCE_EXTNS rs
WHERE TASK_ID = b_task_id
AND tas.RESOURCE_ID = rs.RESOURCE_ID;

CURSOR l_task_post_upd_csr(b_task_id NUMBER)
IS
SELECT TASK_STATUS_ID, TASK_TYPE_ID, SCHEDULED_START_DATE, SCHEDULED_END_DATE, task_id
FROM JTF_TASKS_B
WHERE TASK_ID = b_task_id;

--12.1XB7
CURSOR c_sr_grp_owner(b_task_id number) IS
 SELECT USER_ID
 FROM ASG_USER usr,
      CS_INCIDENTS_ALL_B inc,
      JTF_TASKS_B tsk
 WHERE tsk.TASK_ID=b_task_id
 AND   tsk.SOURCE_OBJECT_TYPE_CODE='SR'
 AND   tsk.SOURCE_OBJECT_ID=inc.INCIDENT_ID
 AND  (
        (inc.owner_group_id IS NOT NULL
         AND usr.GROUP_ID=inc.owner_group_id --is_mfs_grp
   	     AND usr.USER_ID=usr.OWNER_ID
         )
        OR
        ((
		  (inc.owner_group_id IS NOT NULL
           AND not exists (select 1 from asg_user where group_id=inc.owner_group_id) --is_not mfs_grp
		   )
	     OR
          (inc.owner_group_id IS NULL)
		 )
         AND usr.USER_ID=inc.created_by
        )
       );


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

l_task_post_upd_rec l_task_post_upd_csr%ROWTYPE;
l_null_task_post_upd_rec l_task_post_upd_csr%ROWTYPE;
l_task_downloadable_to_owner BOOLEAN;
l_owner_id NUMBER;
l_owner_resource_id NUMBER;

l_PK_NAME_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
l_PK_TYPE_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
l_pk_value_list  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');

BEGIN
  l_jtf_task_id  := jtf_tasks_pub.p_task_user_hooks.task_id;

  l_PK_NAME_LIST(1):='TASK_ID'; l_PK_TYPE_LIST(1):='NUMBER'; l_pk_value_list(1):= to_char(l_jtf_task_id);
  CSM_HA_EVENT_PKG.TRACK_HA_RECORD('JTF_TASKS_B',l_PK_NAME_LIST,l_PK_TYPE_LIST,l_pk_value_list,'U');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  CSM_UTIL_PKG.LOG('Entering CSM_WF_PKG.Task_Post_Upd for task_id:' || l_jtf_task_id ,
                         'CSM_WF_PKG.Task_Post_Upd',FND_LOG.LEVEL_PROCEDURE);

/*12.1: TASK_TYPE CHANGE should be captured*/
  l_task_downloadable_to_owner := CSM_SR_EVENT_PKG.is_sr_downloaded_to_owner(l_jtf_task_id);

 IF (NOT g_task_downloaded_to_owner AND l_task_downloadable_to_owner) THEN

    OPEN c_sr_grp_owner(l_jtf_task_id);
    FETCH c_sr_grp_owner INTO l_owner_id;
    CLOSE c_sr_grp_owner;

    csm_task_event_pkg.acc_insert(p_task_id=>l_jtf_task_id,p_user_id=>l_owner_id);

    for assign_rec in c_task_assignments(l_jtf_task_id)
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

 ELSIF (g_task_downloaded_to_owner AND NOT l_task_downloadable_to_owner) THEN
    OPEN c_sr_grp_owner(l_jtf_task_id);
    FETCH c_sr_grp_owner INTO l_owner_id;
    CLOSE c_sr_grp_owner;

    csm_task_event_pkg.acc_delete(p_task_id=>l_jtf_task_id,p_user_id=>l_owner_id);

    for assign_rec in c_task_assignments(l_jtf_task_id)
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
 END IF;

  -- initialize the rec
  l_task_post_upd_rec := l_null_task_post_upd_rec;

  --  retrieve the record prior update.
  OPEN l_task_post_upd_csr (l_jtf_task_id);
  FETCH l_task_post_upd_csr INTO l_task_post_upd_rec;
  IF l_task_post_upd_csr%NOTFOUND
  THEN
    CLOSE l_task_post_upd_csr;
    RETURN;
  END IF;
  CLOSE l_task_post_upd_csr;

-- re-initialize the table and count
  IF l_task_assignment_list.COUNT > 0 THEN
     l_task_assignment_list.DELETE;
     l_user_list.DELETE;
     l_resource_list.DELETE;
  END IF;

  -- get the assignee's for the task
  OPEN c_task_ass_csr(l_jtf_task_id);
  FETCH c_task_ass_csr BULK COLLECT INTO l_resource_list, l_user_list, l_task_assignment_list;
  CLOSE c_task_ass_csr;

  IF ( l_task_assignment_list.COUNT > 0 ) THEN
/*
  check old data and new data
  --         old downloadable, new NOT, TASK_ASSIGNMENT_PURGE
           old new both not downloadable, do nothing
           old new both downloadable, (if acc record exists)  do UPDATE
  --         old NOT, new downloadable, TASK_ASSIGNMENT_INS
*/
--  CSM_UTIL_PKG.pvt_log('Compare old and new data');
  --  old NOT downloadable, new downloadable, TASK_ASSIGNMENT_INS
    IF (  ( NOT IS_TASK_DOWNLOADABLE(g_task_pre_upd_rec.task_id,
                   g_task_pre_upd_rec.task_status_id,
                   g_task_pre_upd_rec.task_type_id,
                   g_task_pre_upd_rec.scheduled_start_date,
                   g_task_pre_upd_rec.scheduled_end_date)
          )
        AND
          IS_TASK_DOWNLOADABLE(l_task_post_upd_rec.task_id,
                   l_task_post_upd_rec.task_status_id,
                   l_task_post_upd_rec.task_type_id,
                   l_task_post_upd_rec.scheduled_start_date,
                   l_task_post_upd_rec.scheduled_end_date)
     )
    THEN
    CSM_UTIL_PKG.LOG('old NOT downloadable, new downloadable for task_id:' || l_jtf_task_id ,
                         'CSM_WF_PKG.Task_Post_Upd',FND_LOG.LEVEL_PROCEDURE);

     FOR i IN l_task_assignment_list.FIRST..l_task_assignment_list.LAST LOOP
       IF (CSM_UTIL_PKG.is_palm_resource(l_resource_list(i))) THEN
         csm_task_assignment_event_pkg.task_assignment_initializer(p_task_assignment_id=>l_task_assignment_list(i),
                                                            p_error_msg=>l_error_msg,
                                                            x_return_status=>l_return_status);
        /*call Start Sync event - NOTIFY CLIENT*/
         RAISE_START_AUTO_SYNC_EVENT('CSM_TASK_ASSIGNMENTS',to_char(l_task_assignment_list(i)),'NEW');

        END IF;
      END LOOP;

    -- old downloadable, new NOT, TASK_ASSIGNMENT_PURGE
    ELSIF (  ( NOT IS_TASK_DOWNLOADABLE(l_task_post_upd_rec.task_id,
                   l_task_post_upd_rec.task_status_id,
                   l_task_post_upd_rec.task_type_id,
                   l_task_post_upd_rec.scheduled_start_date,
                   l_task_post_upd_rec.scheduled_end_date)
        )
        AND IS_TASK_DOWNLOADABLE(g_task_pre_upd_rec.task_id,
                   g_task_pre_upd_rec.task_status_id,
                   g_task_pre_upd_rec.task_type_id,
                   g_task_pre_upd_rec.scheduled_start_date,
                   g_task_pre_upd_rec.scheduled_end_date)
     )
    THEN
    CSM_UTIL_PKG.LOG('old downloadable, new NOT downloadable for task_id:' || l_jtf_task_id ,
                         'CSM_WF_PKG.Task_Post_Upd',FND_LOG.LEVEL_PROCEDURE);

     FOR i IN l_task_assignment_list.FIRST..l_task_assignment_list.LAST LOOP
       IF (CSM_UTIL_PKG.is_palm_resource(l_resource_list(i))) THEN
         csm_task_assignment_event_pkg.TASK_ASSIGNMENT_PURGE_INIT
                             (p_task_assignment_id=>l_task_assignment_list(i),
                              p_error_msg=>l_error_msg,
                              x_return_status=>l_return_status);
       END IF;
      END LOOP;

    END IF;
  END IF ; -- count > 0

  --do the updates for the task
   CSM_UTIL_PKG.LOG('Do updates for task_id:' || l_jtf_task_id ,
                         'CSM_WF_PKG.Task_Post_Upd',FND_LOG.LEVEL_PROCEDURE);

   csm_task_event_pkg.TASK_MAKE_DIRTY_U_FOREACHUSER(l_jtf_task_id,l_error_msg, l_return_status);
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       csm_util_pkg.LOG(l_error_msg, 'CSM_WF_PKG.Task_Pre_Upd', FND_LOG.LEVEL_ERROR);
   END IF;

   CSM_UTIL_PKG.LOG('Leaving CSM_WF_PKG.Task_Post_Upd for task_id:' || l_jtf_task_id ,
                         'CSM_WF_PKG.Task_Post_Upd',FND_LOG.LEVEL_PROCEDURE);

/*call Start Sync event - NOTIFY CLIENT*/
    RAISE_START_AUTO_SYNC_EVENT('CSM_TASKS',to_char(l_jtf_task_id),'UPDATE');


EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    l_error_msg := l_error_msg || '-' || 'Exception in Task_Post_Upd for task_id:' || l_jtf_task_id
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
    csm_util_pkg.LOG(l_error_msg,'CSM_WF_PKG.Task_Post_Upd', FND_LOG.LEVEL_EXCEPTION);
END Task_Post_Upd;

   /********************************************************
   Starts the USER_RESP_INS workflow. Should be called when new
   responsibility is assigned to a user

   Arguments:
   p_user_id: User to which responsibility has been assigned
   p_responsibility_id: The responsibility assigned
   *********************************************************/
PROCEDURE User_Resp_Post_Ins(p_user_id IN NUMBER, p_responsibility_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
  CSM_UTIL_PKG.LOG('Entering User_Resp_Post_Ins for user_id:' || p_user_id,
                         'csm_wf_pkg.User_Resp_Post_Ins',FND_LOG.LEVEL_PROCEDURE);

  csm_user_event_pkg.user_resp_ins_initializer(p_user_id=>p_user_id,
                                               p_responsibility_id=>p_responsibility_id);

  CSM_UTIL_PKG.LOG('Leaving User_Resp_Post_Ins for user_id:' || p_user_id,
                         'csm_wf_pkg.User_Resp_Post_Ins',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  WHEN OTHERS THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     l_error_msg := ' Exception in  User_Resp_Post_Ins for user_id:'
                       || to_char(p_user_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
     CSM_UTIL_PKG.LOG(l_error_msg, 'csm_wf_pkg.User_Resp_Post_Ins',FND_LOG.LEVEL_EXCEPTION);
     RAISE;
END User_Resp_Post_Ins;

--12.1XB6
/* Starts SR_INS workflow, Should be called when new SR is created */
Procedure SR_Post_Ins(
    x_return_status     OUT NOCOPY      VARCHAR2
)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_incident_id cs_incidents_all.incident_id%TYPE;
l_owner_group_id NUMBER;
l_user_id NUMBER;

CURSOR l_sr_csr(p_incident_id IN NUMBER)
IS
SELECT owner_group_id,created_by
FROM cs_incidents_all_b
WHERE incident_id = p_incident_id;

l_PK_NAME_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
l_PK_TYPE_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
l_pk_value_list  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');

BEGIN

  l_incident_id := cs_servicerequest_pvt.user_hooks_rec.request_id;

  l_PK_NAME_LIST(1):='INCIDENT_ID'; l_PK_TYPE_LIST(1):='NUMBER'; l_pk_value_list(1):= to_char(l_incident_id);
  CSM_HA_EVENT_PKG.TRACK_HA_RECORD('CS_INCIDENTS_ALL_B',l_PK_NAME_LIST,l_PK_TYPE_LIST,l_pk_value_list,'I');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;



  OPEN l_sr_csr(l_incident_id);
  FETCH l_sr_csr INTO l_owner_group_id,l_user_id;
  IF l_sr_csr%FOUND THEN
     IF ( NOT CSM_UTIL_PKG.is_mfs_group(l_owner_group_id) AND NOT CSM_UTIL_PKG.is_palm_user(l_user_id)) THEN
         CLOSE l_sr_csr;
         RETURN;
     END IF;
  END IF;
  CLOSE l_sr_csr;

  csm_sr_event_pkg.sr_ins_init(l_incident_id);

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    l_error_msg := l_error_msg || '- Exception in SR_Post_Ins for incident_id:'
            || TO_CHAR(l_incident_id) || l_sqlerrno || ':' || l_sqlerrmsg;
    CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_WF_PKG.SR_Post_Ins',FND_LOG.LEVEL_EXCEPTION);
END SR_Post_Ins;

/*
 *  The user hook interface for SR pre_update
 */
--12.1
PROCEDURE SR_Pre_Upd( x_return_status  OUT NOCOPY  VARCHAR2)
IS
l_incident_id cs_incidents_all.incident_id%TYPE;
l_rec_count NUMBER;
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_location_id JTF_TASKS_B.LOCATION_ID%TYPE;

--R12 Asset
CURSOR l_sr_pre_upd_csr (p_incident_id IN number)
IS
SELECT incident_id,
       customer_id,
       install_site_id,
       customer_product_id,
       inventory_item_id,
       inv_organization_id,
       contract_service_id,
       incident_location_id,
       customer_id,
       incident_location_id,
       owner_group_id
FROM   cs_incidents_all_b csi
WHERE  incident_id = p_incident_id;

CURSOR l_addr_id_csr (b_incident_id IN NUMBER)
IS
SELECT ADDRESS_ID
FROM JTF_TASKS_B
WHERE SOURCE_OBJECT_TYPE_CODE = 'SR'
AND SOURCE_OBJECT_ID = b_incident_id;

--R12 Asset
CURSOR l_location_id_csr (b_incident_id IN NUMBER)
IS
SELECT ADDRESS_ID,LOCATION_ID
FROM JTF_TASKS_B
WHERE SOURCE_OBJECT_TYPE_CODE = 'SR'
AND SOURCE_OBJECT_ID = b_incident_id;

-- get all the contacts for the SR; this is used in sr_post_upd
-- to verify if the contact has been updated
CURSOR l_sr_cont_pts_pre_upd_csr(p_incident_id IN number)
IS
SELECT sr_contact_point_id,
       party_id,
       contact_point_id,
       primary_flag,
       contact_point_type,
       contact_type,
       last_update_date,
       creation_date
FROM   cs_hz_sr_contact_points
WHERE  incident_id = p_incident_id;

l_sr_cont_pts_pre_upd_rec l_sr_cont_pts_pre_upd_csr%ROWTYPE;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

   l_incident_id := cs_servicerequest_pvt.user_hooks_rec.request_id;

   -- nullify the global rec
   g_sr_pre_upd_rec := g_null_sr_pre_upd_rec;

   OPEN l_sr_pre_upd_csr( l_incident_id );
   FETCH l_sr_pre_upd_csr INTO g_sr_pre_upd_rec;
   IF l_sr_pre_upd_csr%NOTFOUND THEN
      close l_sr_pre_upd_csr;
      return;
   END IF;
   CLOSE l_sr_pre_upd_csr;

   IF g_sr_pre_upd_rec.INSTALL_SITE_ID IS NULL THEN
     OPEN l_addr_id_csr(l_incident_id);
     FETCH l_addr_id_csr INTO g_sr_pre_upd_rec.INSTALL_SITE_ID;
     CLOSE l_addr_id_csr;
   END IF;

   IF g_sr_pre_upd_rec.INCIDENT_LOCATION_ID IS NULL THEN
     OPEN  l_location_id_csr(l_incident_id);
     FETCH l_location_id_csr INTO g_sr_pre_upd_rec.INCIDENT_LOCATION_ID,l_location_id;
     CLOSE l_location_id_csr;
	 IF	l_location_id IS NOT  NULL THEN--r12 Asset
	 	g_sr_pre_upd_rec.INCIDENT_LOCATION_ID := l_location_id;
	 END IF;
   END IF;

   -- nullify the global contact rec
   g_sr_cont_points_pre_upd_tbl := g_null_sr_cont_points_tbl;
   l_rec_count := 0;
   -- get all the pre-upd contacts for the SR
   OPEN l_sr_cont_pts_pre_upd_csr(l_incident_id);
   LOOP
   FETCH l_sr_cont_pts_pre_upd_csr INTO l_sr_cont_pts_pre_upd_rec;
   IF l_sr_cont_pts_pre_upd_csr%NOTFOUND THEN
      EXIT;
   ELSE
     l_rec_count := l_rec_count + 1;
     g_sr_cont_points_pre_upd_tbl(l_rec_count).SR_CONTACT_POINT_ID := l_sr_cont_pts_pre_upd_rec.sr_contact_point_id;
     g_sr_cont_points_pre_upd_tbl(l_rec_count).PARTY_ID :=  l_sr_cont_pts_pre_upd_rec.party_id;
     g_sr_cont_points_pre_upd_tbl(l_rec_count).contact_point_id := l_sr_cont_pts_pre_upd_rec.contact_point_id;
     g_sr_cont_points_pre_upd_tbl(l_rec_count).primary_flag := l_sr_cont_pts_pre_upd_rec.primary_flag;
     g_sr_cont_points_pre_upd_tbl(l_rec_count).contact_point_type := l_sr_cont_pts_pre_upd_rec.contact_point_type;
     g_sr_cont_points_pre_upd_tbl(l_rec_count).CONTACT_TYPE := l_sr_cont_pts_pre_upd_rec.contact_type;
     g_sr_cont_points_pre_upd_tbl(l_rec_count).last_update_date := l_sr_cont_pts_pre_upd_rec.last_update_date;
     g_sr_cont_points_pre_upd_tbl(l_rec_count).creation_date := l_sr_cont_pts_pre_upd_rec.creation_date;
   END IF;
   END LOOP;
   CLOSE l_sr_cont_pts_pre_upd_csr;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    l_error_msg := 'Exception in sr_pre_upd for incident_id:' || TO_CHAR(l_incident_id)
                 || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
    CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_WF_PKG.sr_pre_upd',FND_LOG.LEVEL_EXCEPTION);
END sr_pre_upd;

   /********************************************************
   Starts the SR_UPD workflow. Should be called when new
   task assignment is made

   Arguments:
   p_incident_id: INCIDENT_ID of the SR updated
   p_old_install_site_id: Old value of the INSTALL_SITE_ID
   p_is_sr_customer_updated: true, if the customer has been updated, false otherwise
   p_old_sr_customer_id: Old value of the CUSTOMER_ID
   p_is_sr_instance_updated: true, if the instance has been updated, false otherwise
   p_old_instance_id: Old value of the INSTANCE_ID
   p_is_inventory_item_updated: true, if the inventory item has been updated, false otherwise
   p_old_inventory_item_id: Old value of the INVENTORY_ITEM_ID
   *********************************************************/
--12.1
Procedure SR_Post_Upd( x_return_status  OUT NOCOPY  VARCHAR2)
IS
l_incident_id cs_incidents_all.incident_id%TYPE;
l_install_site_id cs_incidents_all_b.install_site_id%TYPE;
l_is_install_site_updated char(1);
l_sr_customer_id cs_incidents_all_b.customer_id%TYPE;
l_is_sr_customer_updated char(1);
l_inventory_item_id cs_incidents_all_b.inventory_item_id%TYPE;
l_is_inventory_item_updated char(1);
l_instance_id cs_incidents_all_b.customer_product_id%TYPE;
l_is_sr_instance_updated char(1);
l_rec_count number;
l_is_sr_contact_ins char(1);
l_is_sr_contact_upd char(1);
l_is_sr_contact_del char(1);
l_is_contr_service_id_updated char(1);
l_is_mobile_sr number :=0;
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_incident_location_id cs_incidents_all_b.incident_location_id%TYPE;
l_is_incident_location_updated char(1);
l_location_id JTF_TASKS_B.LOCATION_ID%TYPE;
l_is_owner_changed char(1);
l_old_owner NUMBER;
l_current_owner NUMBER;

CURSOR l_sr_post_upd_csr (p_incident_id IN number)
IS
SELECT incident_id,
       customer_id,
       install_site_id,
       customer_product_id,
       inventory_item_id,
       inv_organization_id,
       contract_service_id,
       incident_location_id,
       owner_group_id,
       created_by
FROM   cs_incidents_all_b
WHERE  incident_id = p_incident_id;

l_sr_post_upd_rec l_sr_post_upd_csr%ROWTYPE;

CURSOR l_addr_id_csr (b_incident_id IN NUMBER)
IS
SELECT ADDRESS_ID
FROM JTF_TASKS_B
WHERE SOURCE_OBJECT_TYPE_CODE = 'SR'
AND SOURCE_OBJECT_ID = b_incident_id;

CURSOR l_location_id_csr (b_incident_id IN NUMBER)
IS
SELECT ADDRESS_ID,LOCATION_ID
FROM JTF_TASKS_B
WHERE SOURCE_OBJECT_TYPE_CODE = 'SR'
AND SOURCE_OBJECT_ID = b_incident_id;

-- get all the post_upd contacts for the SR;
CURSOR l_sr_cont_pts_post_upd_csr(p_incident_id IN number)
IS
SELECT sr_contact_point_id,
       party_id,
       contact_point_id,
       primary_flag,
       contact_point_type,
       contact_type,
       last_update_date,
       creation_date
FROM   cs_hz_sr_contact_points
WHERE  incident_id = p_incident_id;

l_sr_cont_pts_post_upd_rec l_sr_cont_pts_post_upd_csr%ROWTYPE;

-- cursor to check if SR is owned by a mobile grp, assigned to a mobile user or
-- has a task created by a mobile user
--12.1XB6
CURSOR l_is_mobile_sr_csr(p_incident_id IN NUMBER)
IS
SELECT 1
FROM ASG_USER au,
     cs_incidents_all_b csa
WHERE csa.incident_id = p_incident_id
AND  (csa.OWNER_GROUP_ID = au.GROUP_ID AND au.USER_ID=au.OWNER_ID)
     OR
      au.USER_ID=csa.created_by
     OR
	  EXISTS(SELECT 1
	         FROM jtf_task_assignments jta,
                   jtf_tasks_b jt
             WHERE jt.source_object_id = csa.incident_id
             AND jt.source_object_type_code = 'SR'
             AND jta.task_id = jt.task_id
             AND au.resource_id = jta.resource_id)
	OR
	 EXISTS(SELECT 1
	        FROM jtf_tasks_b jt
            WHERE jt.source_object_id = csa.incident_id
            AND jt.source_object_type_code = 'SR'
			AND jt.CREATED_BY=au.USER_ID);

l_PK_NAME_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
l_PK_TYPE_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
l_pk_value_list  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');

BEGIN

  l_incident_id := cs_servicerequest_pvt.user_hooks_rec.request_id;

  l_PK_NAME_LIST(1):='INCIDENT_ID'; l_PK_TYPE_LIST(1):='NUMBER'; l_pk_value_list(1):= to_char(l_incident_id);
  CSM_HA_EVENT_PKG.TRACK_HA_RECORD('CS_INCIDENTS_ALL_B',l_PK_NAME_LIST,l_PK_TYPE_LIST,l_pk_value_list,'U');

   x_return_status := FND_API.G_RET_STS_SUCCESS;


   IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
     RETURN;
   END IF;

--owner change SHD BE CAPTURED TO DOWNLOAD ONCE THE COLUMN OWNER_GRP_ID IS ADDED
   l_is_install_site_updated := 'N';
   l_is_sr_customer_updated := 'N';
   l_is_inventory_item_updated := 'N';
   l_is_sr_instance_updated := 'N';
   l_is_contr_service_id_updated := 'N';
   l_is_incident_location_updated := 'N';

--IF OWNER_CHANGED REASSIGN

  OPEN l_sr_post_upd_csr(l_incident_id);
  FETCH l_sr_post_upd_csr INTO l_sr_post_upd_rec;

  l_old_owner :=CSM_UTIL_PKG.get_group_owner(g_sr_pre_upd_rec.owner_group_id);
  l_current_owner:=CSM_UTIL_PKG.get_group_owner(l_sr_post_upd_rec.owner_group_id);

--12.1XB6    --to avoid update if created_by and group owner are from same group
            -- and owner_group_id in SR is updated from NULL
   IF l_old_owner=-1  THEN
     l_old_owner   :=csm_util_pkg.get_owner(l_sr_post_upd_rec.created_by);
   END IF;
   IF l_current_owner = -1  THEN
    l_current_owner  :=csm_util_pkg.get_owner(l_sr_post_upd_rec.created_by);
   END IF;

  IF l_old_owner <> l_current_owner THEN
      CSM_SR_EVENT_PKG.sr_del_init(l_incident_id,l_old_owner);
	  CSM_SR_EVENT_PKG.sr_ins_init(l_incident_id);
  END IF;

   -- only start the SR upd WF if it is linked to a mobile user
      OPEN l_is_mobile_sr_csr(l_incident_id);
      FETCH l_is_mobile_sr_csr INTO l_is_mobile_sr;
      CLOSE l_is_mobile_sr_csr;

   IF (NVL(l_is_mobile_sr,0) <> 1) THEN
       RETURN;
   END IF;


  IF l_sr_post_upd_csr%NOTFOUND THEN
      CLOSE l_sr_post_upd_csr;
      RETURN;
  ELSE
     IF l_sr_post_upd_rec.INSTALL_SITE_ID IS NULL THEN
       OPEN l_addr_id_csr(l_incident_id);
       FETCH l_addr_id_csr INTO l_sr_post_upd_rec.INSTALL_SITE_ID;
       CLOSE l_addr_id_csr;
     END IF;

     IF l_sr_post_upd_rec.INCIDENT_LOCATION_ID IS NULL THEN
       OPEN  l_location_id_csr(l_incident_id);
       FETCH l_location_id_csr INTO l_sr_post_upd_rec.INCIDENT_LOCATION_ID,l_location_id;
       CLOSE l_location_id_csr;
       IF l_location_id IS NOT NULL THEN
	   	 l_sr_post_upd_rec.INCIDENT_LOCATION_ID := l_location_id;
	   END IF;

     END IF;

     IF nvl(g_sr_pre_upd_rec.install_site_id, -1) <> nvl(l_sr_post_upd_rec.install_site_id,-1) THEN
       l_is_install_site_updated := 'Y';
     END IF;

     IF nvl(g_sr_pre_upd_rec.incident_location_id, -1) <> nvl(l_sr_post_upd_rec.incident_location_id,-1) THEN
       l_is_incident_location_updated := 'Y';
     END IF;

     IF nvl(g_sr_pre_upd_rec.customer_id, -1) <> nvl(l_sr_post_upd_rec.customer_id,-1) THEN
       l_is_sr_customer_updated := 'Y';
     END IF;

     IF (nvl(g_sr_pre_upd_rec.inventory_item_id, -1) <> nvl(l_sr_post_upd_rec.inventory_item_id,-1))
        OR (nvl(g_sr_pre_upd_rec.inv_organization_id, -1) <> nvl(l_sr_post_upd_rec.inv_organization_id,-1)) THEN
       l_is_inventory_item_updated := 'Y';
     END IF;

     IF nvl(g_sr_pre_upd_rec.customer_product_id,-1) <> nvl(l_sr_post_upd_rec.customer_product_id,-1) THEN
       l_is_sr_instance_updated := 'Y';
     END IF;

     IF nvl(g_sr_pre_upd_rec.contract_service_id,-1) <> nvl(l_sr_post_upd_rec.contract_service_id,-1) THEN
       l_is_contr_service_id_updated := 'Y';
     END IF;

     -- call the sr upd
     -- pass old_install_site_id though it is not used in the called procedure
     csm_sr_event_pkg.sr_upd_init(p_incident_id=> l_incident_id,
                                  p_is_incident_location_updated=>l_is_incident_location_updated,
                                  p_old_incident_location_id=> g_sr_pre_upd_rec.incident_location_id,
                                  p_is_install_site_updated=>l_is_install_site_updated,
                                  p_old_install_site_id=>g_sr_pre_upd_rec.install_site_id,
                                  p_is_sr_customer_updated=>l_is_sr_customer_updated,
                                  p_old_sr_customer_id=>g_sr_pre_upd_rec.customer_id,
                                  p_is_sr_instance_updated=>l_is_sr_instance_updated,
                                  p_old_instance_id=>g_sr_pre_upd_rec.customer_product_id,
                                  p_is_inventory_item_updated=>l_is_inventory_item_updated,
                                  p_old_inventory_item_id=>g_sr_pre_upd_rec.inventory_item_id,
                                  p_old_organization_id=>g_sr_pre_upd_rec.inv_organization_id,
                                  p_old_party_id=>g_sr_pre_upd_rec.party_id,
                                  p_old_location_id=>g_sr_pre_upd_rec.location_id,
                                  p_is_contr_service_id_updated=>l_is_contr_service_id_updated,
                                  p_old_contr_service_id=>g_sr_pre_upd_rec.contract_service_id);
  END IF;
  CLOSE l_sr_post_upd_csr;

   -- nullify the global contact rec
   g_sr_cont_points_post_upd_tbl := g_null_sr_cont_points_tbl;
   l_rec_count := 0;

  -- check for contacts inserted, updated or deleted
  OPEN l_sr_cont_pts_post_upd_csr(l_incident_id);
  LOOP
  FETCH l_sr_cont_pts_post_upd_csr INTO l_sr_cont_pts_post_upd_rec;
  IF l_sr_cont_pts_post_upd_csr%NOTFOUND THEN
    EXIT;
  ELSE
     l_rec_count := l_rec_count + 1;
     g_sr_cont_points_post_upd_tbl(l_rec_count).SR_CONTACT_POINT_ID := l_sr_cont_pts_post_upd_rec.sr_contact_point_id;
     g_sr_cont_points_post_upd_tbl(l_rec_count).PARTY_ID :=  l_sr_cont_pts_post_upd_rec.party_id;
     g_sr_cont_points_post_upd_tbl(l_rec_count).contact_point_id := l_sr_cont_pts_post_upd_rec.contact_point_id;
     g_sr_cont_points_post_upd_tbl(l_rec_count).primary_flag := l_sr_cont_pts_post_upd_rec.primary_flag;
     g_sr_cont_points_post_upd_tbl(l_rec_count).contact_point_type := l_sr_cont_pts_post_upd_rec.contact_point_type;
     g_sr_cont_points_post_upd_tbl(l_rec_count).CONTACT_TYPE := l_sr_cont_pts_post_upd_rec.contact_type;
     g_sr_cont_points_post_upd_tbl(l_rec_count).last_update_date := l_sr_cont_pts_post_upd_rec.last_update_date;
     g_sr_cont_points_post_upd_tbl(l_rec_count).creation_date := l_sr_cont_pts_post_upd_rec.creation_date;
  END IF;
  END LOOP;
  CLOSE l_sr_cont_pts_post_upd_csr;

  -- initialize
  l_is_sr_contact_ins := 'Y';
  l_is_sr_contact_upd := 'N';
  l_is_sr_contact_del := 'Y';

  <<postupd>>
  FOR post IN 1..g_sr_cont_points_post_upd_tbl.count LOOP
    l_is_sr_contact_ins := 'Y';
    l_is_sr_contact_upd := 'N';
    <<preupd>>
    FOR pre IN 1..g_sr_cont_points_pre_upd_tbl.count LOOP
       IF g_sr_cont_points_post_upd_tbl(post).sr_contact_point_id = g_sr_cont_points_pre_upd_tbl(pre).sr_contact_point_id THEN
            -- record exists; set insert_flag to N
            l_is_sr_contact_ins := 'N';

            -- check if record is updated
            IF g_sr_cont_points_post_upd_tbl(post).last_update_date > g_sr_cont_points_pre_upd_tbl(pre).last_update_date
                 AND g_sr_cont_points_post_upd_tbl(post).creation_date = g_sr_cont_points_pre_upd_tbl(pre).creation_date THEN
               -- record has been updated
--               SR_Contact_Pre_Upd(g_sr_cont_points_pre_upd_tbl(pre).sr_contact_point_id);
               csm_sr_contact_event_pkg.sr_cntact_mdirty_u_foreachuser
                     (p_sr_contact_point_id=>g_sr_cont_points_pre_upd_tbl(pre).sr_contact_point_id);
            END IF;
       END IF;
    END LOOP; -- preupd

    -- if record does not exist insert the new SR
    IF l_is_sr_contact_ins = 'Y' THEN
        csm_sr_contact_event_pkg.spawn_userloop_sr_contact_ins
            (p_sr_contact_point_id=>g_sr_cont_points_post_upd_tbl(post).sr_contact_point_id);
--        SR_Contact_Post_Ins(g_sr_cont_points_post_upd_tbl(post).sr_contact_point_id);
    END IF;
  END LOOP; -- postupd

  -- check for sr contact point deletes
  <<predel>>
  FOR pre IN 1..g_sr_cont_points_pre_upd_tbl.count LOOP
    l_is_sr_contact_del := 'Y';
    FOR post IN 1..g_sr_cont_points_post_upd_tbl.count LOOP
       IF g_sr_cont_points_post_upd_tbl(post).sr_contact_point_id = g_sr_cont_points_pre_upd_tbl(pre).sr_contact_point_id THEN
          l_is_sr_contact_del := 'N';
       END IF;
    END LOOP;

    -- delete sr contact if not found
    IF l_is_sr_contact_del = 'Y' THEN
        csm_sr_contact_event_pkg.spawn_userloop_sr_contact_del
            (p_sr_contact_point_id=>g_sr_cont_points_pre_upd_tbl(pre).sr_contact_point_id);
    END IF;
  END LOOP;

/*call Start Sync event - NOTIFY CLIENT*/
    RAISE_START_AUTO_SYNC_EVENT('CSM_INCIDENTS_ALL',to_char(l_incident_id),'UPDATE');

EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    l_error_msg := 'Exception in sr_post_upd for incident_id:' || TO_CHAR(l_incident_id)
                 || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
    CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_WF_PKG.sr_post_upd',FND_LOG.LEVEL_EXCEPTION);
END sr_post_upd;

/*--------------------------------------------------
  Description:
    Starts the RS_GROUP_MEMBER_INS_USERLOOP workflow. Should be called when new
    group member is created.
    Invoked by JTM_RS_GROUP_MEMBER_VUHK.create_group_members_post
   Parameter(s):
    p_group_member_id,
    p_group_id,
    p_resource_id,
    x_return_status
----------------------------------------------------*/

PROCEDURE JTF_RS_Group_Member_Post_Ins(p_group_member_id IN jtf_rs_group_members.group_member_id%TYPE,
                                       p_group_id IN jtf_rs_group_members.group_id%TYPE,
                                       p_resource_id IN jtf_rs_group_members.resource_id%TYPE,
                                       x_return_status OUT nocopy VARCHAR2)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  csm_resource_extns_event_pkg.rs_group_members_ins_init(p_resource_id=>p_resource_id,
                                                         p_group_id=>p_group_id);
EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    CSM_UTIL_PKG.LOG('Exception in JTF_RS_Group_Member_Post_Ins for resource_id: '  || TO_CHAR(p_resource_id)
                      || ' and group_id: ' || TO_CHAR(p_group_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg,
                       'CSM_WF_PKG.JTF_RS_Group_Member_Post_Ins',  FND_LOG.LEVEL_EXCEPTION);
END JTF_RS_Group_Member_Post_Ins;

Procedure JTF_RS_Group_Member_Pre_Upd(p_user_id in number,
                                     p_jtf_rs_group_memb jtf_rs_group_members%rowtype)
IS
BEGIN
      null;
END;
/*
   Procedure JTF_RS_Group_Member_Post_Del(p_user_id in number,
                                     p_jtf_rs_group_memb jtf_rs_group_members%rowtype)
   IS
   BEGIN
      null;
   END;
*/
/*--------------------------------------------------
  Description:
    Starts the RS_GROUP_MEMBER_DEL_USERLOOP workflow. Should be called when new
    group resource member is deleted.
    Invoked by JTM_RS_GROUP_MEMBER_VUHK.delete_group_members_pre
   Parameter(s):
    p_group_id,
    p_resource_id,
    x_return_status
----------------------------------------------------*/

PROCEDURE JTF_RS_Group_Member_Pre_Del(p_group_id IN jtf_rs_group_members.group_id%TYPE,
                                      p_resource_id IN jtf_rs_group_members.resource_id%TYPE,
                                      x_return_status OUT nocopy VARCHAR2)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  csm_resource_extns_event_pkg.rs_group_members_del_init(p_resource_id=>p_resource_id,
                                                         p_group_id=>p_group_id);
EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    CSM_UTIL_PKG.LOG('Exception in JTF_RS_Group_Member_Pre_Del for resource_id: '  || TO_CHAR(p_resource_id)
                      || ' and group_id: ' || TO_CHAR(p_group_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg,
                       'CSM_WF_PKG.JTF_RS_Group_Member_Pre_Del',  FND_LOG.LEVEL_EXCEPTION);
END JTF_RS_Group_Member_Pre_Del;

   /********************************************************
   Starts the DEBRIEF_HEADER_INS workflow. Should be called when new
   debrief line is added on the backend

   Arguments:
   DEBRIEF_HEADER_ID of the new debrief line
   *********************************************************/

PROCEDURE CSF_Debrief_Header_Post_Ins(x_return_status  OUT NOCOPY  VARCHAR2)
IS
l_debrief_header_id csf_debrief_lines.debrief_header_id%TYPE;
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

l_PK_NAME_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
l_PK_TYPE_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
l_pk_value_list  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');

 Cursor c_exists (b_header_id NUMBER)
 IS
 SELECT 1
 FROM CSF_DEBRIEF_HEADERS
 WHERE DEBRIEF_HEADER_ID=b_header_id;

 l_e NUMBER;

BEGIN
  l_debrief_header_id := CSF_DEBRIEF_HEADERS_PKG.user_hooks_rec.debrief_header_id;

  OPEN c_exists(l_debrief_header_id);
  FETCH c_exists INTO l_e;
  CLOSE c_exists;

  IF l_e IS NOT NULL AND l_e = 1 THEN
    l_PK_NAME_LIST(1):='DEBRIEF_HEADER_ID'; l_PK_TYPE_LIST(1):='NUMBER'; l_pk_value_list(1):= to_char(l_debrief_header_id);
    CSM_HA_EVENT_PKG.TRACK_HA_RECORD('CSF_DEBRIEF_HEADERS',l_PK_NAME_LIST,l_PK_TYPE_LIST,l_pk_value_list,'I');
  ELSE
    CSM_UTIL_PKG.LOG('Got a dummy call with debrief header id: '||l_debrief_header_id, 'CSM_WF_PKG.CSF_Debrief_Header_Post_Ins',FND_LOG.LEVEL_PROCEDURE);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  csm_debrief_header_event_pkg.debrief_header_ins_init(p_debrief_header_id=>l_debrief_header_id,
                                                       p_h_user_id=>NULL,
                                                       p_flow_type=>NULL);
EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    l_error_msg := 'Exception in CSF_Debrief_Header_Post_Ins for debrief_header_id:' || TO_CHAR(l_debrief_header_id)
                 || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
    CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_WF_PKG.CSF_Debrief_Header_Post_Ins',FND_LOG.LEVEL_EXCEPTION);
END CSF_Debrief_Header_Post_Ins;

PROCEDURE CSF_Debrief_Header_Pre_Upd(x_return_status  OUT NOCOPY  VARCHAR2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END CSF_Debrief_Header_Pre_Upd;

PROCEDURE CSF_Debrief_Header_Post_Upd(x_return_status OUT NOCOPY VARCHAR2)
IS
l_debrief_header_id csf_debrief_headers.debrief_header_id%TYPE;
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_debrief_hdr_csr(p_debrief_header_id IN NUMBER )
IS
SELECT acc.debrief_header_id,
       acc.user_id
FROM  csm_debrief_headers_acc acc
WHERE acc.debrief_header_id = p_debrief_header_id;


l_PK_NAME_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
l_PK_TYPE_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
l_pk_value_list  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');


BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_debrief_header_id := CSF_DEBRIEF_Headers_PKG.user_hooks_rec.debrief_header_id;

  l_PK_NAME_LIST(1):='DEBRIEF_HEADER_ID'; l_PK_TYPE_LIST(1):='NUMBER'; l_pk_value_list(1):= to_char(l_debrief_header_id);
  CSM_HA_EVENT_PKG.TRACK_HA_RECORD('CSF_DEBRIEF_HEADERS',l_PK_NAME_LIST,l_PK_TYPE_LIST,l_pk_value_list,'U');

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  CSM_UTIL_PKG.LOG('CSM_WF_PKG.CSF_Debrief_Header_Post_Upd: IS_FIELD_SERVICE_PALM_ENABLED' );

  FOR r_debrief_hdr_rec IN l_debrief_hdr_csr(l_debrief_header_id) LOOP
    csm_debrief_header_event_pkg.debrief_header_mdirty_u(p_debrief_header_id=>l_debrief_header_id,
                                                         p_user_id=>r_debrief_hdr_rec.user_id);
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    l_error_msg := 'Exception in CSF_Debrief_Header_Post_Upd for debrief_header_id:' || TO_CHAR(l_debrief_header_id)
                 || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
    CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_WF_PKG.CSF_Debrief_Header_Post_Upd',FND_LOG.LEVEL_EXCEPTION);
END CSF_Debrief_Header_Post_Upd;

PROCEDURE CSF_Debrief_Header_Post_Del(x_return_status OUT NOCOPY VARCHAR2)
IS
l_debrief_header_id csf_debrief_headers.debrief_header_id%TYPE;
l_task_assignment_id csf_debrief_headers.task_assignment_id%type;
l_user_id fnd_user.user_id%type;
l_resource_id jtf_rs_resource_extns.resource_id%type;

CURSOR l_csm_debrfdel_csr (p_debrief_header_id csf_debrief_headers.debrief_header_id%type) IS
SELECT dhdr.task_assignment_id, jtrs.user_id, jta.resource_id
FROM  csf_debrief_headers dhdr,
  	  jtf_task_assignments jta,
      jtf_rs_resource_extns jtrs
WHERE dhdr.debrief_header_id = p_debrief_header_id
AND  jta.task_assignment_id = dhdr.task_assignment_id
AND  jtrs.resource_id = jta.resource_id
;

l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_csm_debrfHdDel_csr (p_debrief_header_id csf_debrief_headers.debrief_header_id%TYPE)
IS
SELECT dhdr.debrief_header_id, acc.user_id
FROM   csf_debrief_headers dhdr,
       csm_debrief_headers_acc acc
WHERE dhdr.debrief_header_id = p_debrief_header_id
AND  acc.debrief_header_id = dhdr.debrief_header_id;

l_csm_debrfHdDel_rec l_csm_debrfHdDel_csr%ROWTYPE;

l_PK_NAME_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
l_PK_TYPE_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
l_pk_value_list  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_debrief_header_id := CSF_DEBRIEF_HEADERS_PKG.user_hooks_rec.debrief_header_id;

  l_PK_NAME_LIST(1):='DEBRIEF_HEADER_ID'; l_PK_TYPE_LIST(1):='NUMBER'; l_pk_value_list(1):= to_char(l_debrief_header_id);
  CSM_HA_EVENT_PKG.TRACK_HA_RECORD('CSF_DEBRIEF_HEADERS',l_PK_NAME_LIST,l_PK_TYPE_LIST,l_pk_value_list,'D');

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  OPEN l_csm_debrfHdDel_csr(l_debrief_header_id);
  FETCH l_csm_debrfHdDel_csr INTO l_csm_debrfHdDel_rec;
  IF l_csm_debrfHdDel_csr%NOTFOUND THEN
      CLOSE l_csm_debrfHdDel_csr;
      RETURN;
  END IF;
  CLOSE l_csm_debrfHdDel_csr;

  csm_debrief_header_event_pkg.debrief_header_del_init(p_debrief_header_id=>l_debrief_header_id,
                                                       p_user_id=>l_csm_debrfHdDel_rec.user_id,
                                                       p_flow_type=>NULL);
EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    l_error_msg := 'Exception in CSF_Debrief_Header_Post_Del for debrief_header_id:' || TO_CHAR(l_debrief_header_id)
                 || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
    CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_WF_PKG.CSF_Debrief_Header_Post_Del',FND_LOG.LEVEL_EXCEPTION);
END CSF_Debrief_Header_Post_Del;

   /********************************************************
   Starts the DEBRIEF_LINE_INS workflow. Should be called when new
   debrief line is added on the backend

   Arguments:
   p_task_assignment_id: DEBRIEF_LINE_ID of the new debrief line
   *********************************************************/
PROCEDURE CSF_Debrief_Line_Post_Ins (x_return_status OUT NOCOPY VARCHAR2)
IS
l_debrief_line_id csf_debrief_lines.debrief_line_id%TYPE;
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

l_PK_NAME_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
l_PK_TYPE_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
l_pk_value_list  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_debrief_line_id := CSF_DEBRIEF_LINES_PKG.user_hooks_rec.debrief_line_id;

  l_PK_NAME_LIST(1):='DEBRIEF_LINE_ID'; l_PK_TYPE_LIST(1):='NUMBER'; l_pk_value_list(1):= to_char(l_debrief_line_id);
  CSM_HA_EVENT_PKG.TRACK_HA_RECORD('CSF_DEBRIEF_LINES',l_PK_NAME_LIST,l_PK_TYPE_LIST,l_pk_value_list,'I');


  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  csm_debrief_event_pkg.debrief_line_ins_init(p_debrief_line_id=>l_debrief_line_id,
                                              p_h_user_id=>NULL,
                                              p_flow_type=>NULL);

 EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    l_error_msg := 'Exception in CSF_Debrief_Line_Post_Ins for debrief_Line_id:' || TO_CHAR(l_debrief_line_id)
                 || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
    CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_WF_PKG.CSF_Debrief_Line_Post_Ins',FND_LOG.LEVEL_EXCEPTION);
END CSF_Debrief_Line_Post_Ins;

   /********************************************************
   Captures the old inventory_item_id before the upd
   Arguments:
   p_task_assignment_id: DEBRIEF_LINE_ID of the debrief line
   *********************************************************/
Procedure CSF_Debrief_Line_Pre_Upd(x_return_status OUT NOCOPY VARCHAR2)
IS
l_debrief_line_id csf_debrief_lines.debrief_line_id%TYPE;
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_debrief_line_pre_upd (p_debrief_line_id csf_debrief_lines.debrief_line_id%type)
IS
SELECT debrief_line_id,
       inventory_item_id,
       instance_id
FROM  csf_debrief_lines
WHERE debrief_line_id = p_debrief_line_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  l_debrief_line_id := CSF_DEBRIEF_LINES_PKG.user_hooks_rec.debrief_line_id;

  OPEN l_debrief_line_pre_upd(l_debrief_line_id);
  FETCH l_debrief_line_pre_upd INTO g_debrief_line_pre_upd_rec;
     IF l_debrief_line_pre_upd%NOTFOUND THEN
        CLOSE l_debrief_line_pre_upd;
        RETURN;
     END IF;
  CLOSE l_debrief_line_pre_upd;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    l_error_msg := 'Exception in CSF_Debrief_Line_Pre_Upd for debrief_Line_id:' || TO_CHAR(l_debrief_line_id)
                 || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
    CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_WF_PKG.CSF_Debrief_Line_Pre_Upd',FND_LOG.LEVEL_EXCEPTION);
END CSF_Debrief_Line_Pre_Upd;


Procedure CSF_Debrief_Line_Post_Upd(x_return_status OUT NOCOPY VARCHAR2)
IS
l_debrief_line_id csf_debrief_lines.debrief_line_id%TYPE;
l_is_inventory_item_updated varchar2(1);
l_is_debrief_instance_updated varchar2(1);
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_debrief_line_post_upd (p_debrief_line_id csf_debrief_lines.debrief_line_id%type)
IS
SELECT debrief_line_id,
       inventory_item_id,
       instance_id
FROM  csf_debrief_lines
WHERE debrief_line_id = p_debrief_line_id;

r_debrief_line_post_upd_rec l_debrief_line_post_upd%ROWTYPE;

l_PK_NAME_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
l_PK_TYPE_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
l_pk_value_list  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_debrief_line_id := CSF_DEBRIEF_LINES_PKG.user_hooks_rec.debrief_line_id;

  l_PK_NAME_LIST(1):='DEBRIEF_LINE_ID'; l_PK_TYPE_LIST(1):='NUMBER'; l_pk_value_list(1):= to_char(l_debrief_line_id);
  CSM_HA_EVENT_PKG.TRACK_HA_RECORD('CSF_DEBRIEF_LINES',l_PK_NAME_LIST,l_PK_TYPE_LIST,l_pk_value_list,'U');


  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

     l_is_inventory_item_updated := 'N';
     l_is_debrief_instance_updated := 'N';

     OPEN l_debrief_line_post_upd(l_debrief_line_id);
     FETCH l_debrief_line_post_upd INTO r_debrief_line_post_upd_rec;
     IF l_debrief_line_post_upd%NOTFOUND THEN
        CLOSE l_debrief_line_post_upd;
        RETURN;
     END IF;
     CLOSE l_debrief_line_post_upd;

     -- compare the inventory_item_id with the value in pre_upd
     IF NVL(r_debrief_line_post_upd_rec.inventory_item_id, -1) <> NVL(g_debrief_line_pre_upd_rec.inventory_item_id, -1) THEN
           l_is_inventory_item_updated := 'Y';
     END IF;

     IF NVL(r_debrief_line_post_upd_rec.instance_id, -1) <> NVL(g_debrief_line_pre_upd_rec.instance_id, -1) THEN
           l_is_debrief_instance_updated := 'Y';
     END IF;

     csm_debrief_event_pkg.debrief_line_upd_init
                                (p_debrief_line_id=>l_debrief_line_id,
                                 p_old_inventory_item_id=>g_debrief_line_pre_upd_rec.inventory_item_id,
                                 p_is_inventory_item_updated=>l_is_inventory_item_updated,
                                 p_old_instance_id=>g_debrief_line_pre_upd_rec.instance_id,
                                 p_is_instance_updated=>l_is_debrief_instance_updated);


EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    l_error_msg := 'Exception in CSF_Debrief_Line_Post_Upd for debrief_Line_id:' || TO_CHAR(l_debrief_line_id)
                 || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
    CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_WF_PKG.CSF_Debrief_Line_Post_Upd',FND_LOG.LEVEL_EXCEPTION);
END CSF_Debrief_Line_Post_Upd;


/*
 * Post Delete of CS_DEBRIEF_LINES records.
 */
Procedure CSF_Debrief_Line_Post_Del (x_return_status OUT NOCOPY VARCHAR2)
IS
l_debrief_line_id csf_debrief_lines.debrief_line_id%TYPE;
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_csm_debrfLnDel_csr (p_debrief_line_id csf_debrief_lines.debrief_line_id%TYPE)
IS
SELECT acc.user_id, dbl.debrief_line_id
FROM csf_debrief_lines dbl,
     csm_debrief_lines_acc acc
WHERE dbl.debrief_line_id = p_debrief_line_id
AND  acc.debrief_line_id = dbl.debrief_line_id;

l_csm_debrfLnDel_rec l_csm_debrfLnDel_csr%ROWTYPE;

l_PK_NAME_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
l_PK_TYPE_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
l_pk_value_list  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_debrief_line_id := CSF_DEBRIEF_LINES_PKG.user_hooks_rec.debrief_line_id;

  l_PK_NAME_LIST(1):='DEBRIEF_LINE_ID'; l_PK_TYPE_LIST(1):='NUMBER'; l_pk_value_list(1):= to_char(l_debrief_line_id);
  CSM_HA_EVENT_PKG.TRACK_HA_RECORD('CSF_DEBRIEF_LINES',l_PK_NAME_LIST,l_PK_TYPE_LIST,l_pk_value_list,'D');


  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  OPEN l_csm_debrfLnDel_csr(l_debrief_line_id);
  FETCH l_csm_debrfLnDel_csr INTO l_csm_debrfLnDel_rec;
  IF l_csm_debrfLnDel_csr%NOTFOUND THEN
      CLOSE l_csm_debrfLnDel_csr;
      RETURN;
  END IF;
  CLOSE l_csm_debrfLnDel_csr;

  csm_debrief_event_pkg.debrief_line_del_init(p_debrief_line_id=>l_debrief_line_id,
                                              p_user_id=>l_csm_debrfLnDel_rec.user_id,
                                              p_flow_type=>NULL);
EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    l_error_msg := 'Exception in CSF_Debrief_Line_Post_Del for debrief_Line_id:' || TO_CHAR(l_debrief_line_id)
                 || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
    CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_WF_PKG.CSF_Debrief_Line_Post_Del',FND_LOG.LEVEL_EXCEPTION);
END CSF_Debrief_Line_Post_Del;

PROCEDURE CSP_Inv_Loc_Assignmnt_Post_Ins(x_return_status OUT NOCOPY VARCHAR2)
IS
l_csp_inv_loc_assignment_id csp_inv_loc_assignments.csp_inv_loc_assignment_id%TYPE;
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  l_csp_inv_loc_assignment_id := CSP_INV_LOC_ASSIGNMENTS_PKG.user_hooks_rec.CSP_INV_LOC_ASSIGNMENT_ID;

  CSM_UTIL_PKG.LOG('Entering CSP_Inv_Loc_Assignmnt_Post_Ins for csp_inv_loc_assignment_id: '  || TO_CHAR(l_csp_inv_loc_assignment_id),
                    'CSM_WF_PKG.CSP_Inv_Loc_Assignmnt_Post_Ins', FND_LOG.LEVEL_PROCEDURE );

  CSM_INV_LOC_ASS_EVENT_PKG.INV_LOC_ASSIGNMENT_INS_INIT(p_csp_inv_loc_assignment_id=>l_csp_inv_loc_assignment_id);

  CSM_UTIL_PKG.LOG('Leaving CSP_Inv_Loc_Assignmnt_Post_Ins for csp_inv_loc_assignment_id: '  || TO_CHAR(l_csp_inv_loc_assignment_id),
                    'CSM_WF_PKG.CSP_Inv_Loc_Assignmnt_Post_Ins', FND_LOG.LEVEL_PROCEDURE );

EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    CSM_UTIL_PKG.LOG('Exception in CSP_Inv_Loc_Assignmnt_Post_Ins for csp_inv_loc_assignment_id: '  || TO_CHAR(l_csp_inv_loc_assignment_id)
                        || ':' || l_sqlerrno || ':' || l_sqlerrmsg,
                       'CSM_WF_PKG.CSP_Inv_Loc_Assignmnt_Post_Ins',  FND_LOG.LEVEL_EXCEPTION);
END CSP_Inv_Loc_Assignmnt_Post_Ins;

PROCEDURE CSP_Inv_Loc_Assignmnt_Pre_Upd(x_return_status OUT NOCOPY VARCHAR2)
IS
l_csp_inv_loc_assignment_id csp_inv_loc_assignments.csp_inv_loc_assignment_id%TYPE;
l_old_organization_id  csp_inv_loc_assignments.organization_id%TYPE;
l_old_subinventory_code csp_inv_loc_assignments.subinventory_code%TYPE;
l_old_eff_date_start date;
l_old_eff_date_end date;
l_old_default_code csp_inv_loc_assignments.default_code%TYPE;
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(2000);

CURSOR l_cila_pre_upd_csr(p_csp_inv_loc_assignment_id IN NUMBER)
IS
SELECT organization_id,
       subinventory_code,
       effective_date_start,
       effective_date_end,
       default_code
FROM   csp_inv_loc_assignments cila,
       asg_user au
WHERE  cila.csp_inv_loc_assignment_id = p_csp_inv_loc_assignment_id
AND    au.resource_id = cila.resource_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  l_csp_inv_loc_assignment_id := CSP_INV_LOC_ASSIGNMENTS_PKG.user_hooks_rec.CSP_INV_LOC_ASSIGNMENT_ID;

  CSM_UTIL_PKG.LOG('Entering CSP_Inv_Loc_Assignmnt_Pre_Upd for csp_inv_loc_assignment_id: '  || TO_CHAR(l_csp_inv_loc_assignment_id),
                    'CSM_WF_PKG.CSP_Inv_Loc_Assignmnt_Pre_Upd', FND_LOG.LEVEL_PROCEDURE );

  g_old_subinventory_code := NULL;
  g_old_organization_id := NULL;
  g_old_eff_date_start := NULL;
  g_old_eff_date_end := NULL;
  g_old_default_code := NULL;

  OPEN l_cila_pre_upd_csr(l_csp_inv_loc_assignment_id);
  FETCH l_cila_pre_upd_csr INTO l_old_organization_id, l_old_subinventory_code,
                                l_old_eff_date_start, l_old_eff_date_end, l_old_default_code;

  IF l_cila_pre_upd_csr%NOTFOUND THEN
        CLOSE l_cila_pre_upd_csr;
        RETURN;
  ELSE
        g_old_organization_id := l_old_organization_id;
        g_old_subinventory_code := l_old_subinventory_code;
        g_old_eff_date_start := l_old_eff_date_start;
        g_old_eff_date_end := l_old_eff_date_end;
        g_old_default_code := l_old_default_code;
  END IF;
  CLOSE l_cila_pre_upd_csr;

  CSM_UTIL_PKG.LOG('Leaving CSP_Inv_Loc_Assignmnt_Pre_Upd for csp_inv_loc_assignment_id: '  || TO_CHAR(l_csp_inv_loc_assignment_id),
                    'CSM_WF_PKG.CSP_Inv_Loc_Assignmnt_Pre_Upd', FND_LOG.LEVEL_PROCEDURE );
EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    CSM_UTIL_PKG.LOG('Exception in CSP_Inv_Loc_Assignmnt_Pre_Upd for csp_inv_loc_assignment_id: '  || TO_CHAR(l_csp_inv_loc_assignment_id)
                        || ':' || l_sqlerrno || ':' || l_sqlerrmsg,
                       'CSM_WF_PKG.CSP_Inv_Loc_Assignmnt_Pre_Upd',  FND_LOG.LEVEL_EXCEPTION);
END CSP_Inv_Loc_Assignmnt_Pre_Upd;

PROCEDURE CSP_Inv_Loc_Assignmnt_Post_Upd(x_return_status OUT NOCOPY VARCHAR2)
IS
l_csp_inv_loc_assignment_id csp_inv_loc_assignments.csp_inv_loc_assignment_id%TYPE;
l_organization_id  csp_inv_loc_assignments.organization_id%TYPE;
l_subinventory_code csp_inv_loc_assignments.subinventory_code%TYPE;
l_eff_date_start DATE;
l_eff_date_end DATE;
l_user_id fnd_user.user_id%TYPE;
l_resource_id csp_inv_loc_assignments.resource_id%TYPE;
l_default_code csp_inv_loc_assignments.default_code%TYPE;
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(2000);

CURSOR l_cila_post_upd_csr(p_csp_inv_loc_assignment_id IN NUMBER)
IS
SELECT cila.organization_id,
       cila.subinventory_code,
       cila.effective_date_start,
       cila.effective_date_end,
       cila.resource_id,
       au.user_id,
       cila.default_code
FROM   csp_inv_loc_assignments cila,
       asg_user au
WHERE  cila.csp_inv_loc_assignment_id = p_csp_inv_loc_assignment_id
AND    au.resource_id = cila.resource_id;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
        RETURN;
   END IF;

   l_csp_inv_loc_assignment_id := CSP_INV_LOC_ASSIGNMENTS_PKG.user_hooks_rec.CSP_INV_LOC_ASSIGNMENT_ID;

   OPEN l_cila_post_upd_csr(l_csp_inv_loc_assignment_id);
   FETCH l_cila_post_upd_csr INTO l_organization_id, l_subinventory_code, l_eff_date_start,
                                  l_eff_date_end, l_resource_id, l_user_id, l_default_code;
   IF l_cila_post_upd_csr%NOTFOUND THEN
      CLOSE l_cila_post_upd_csr;
      RETURN;
   END IF;
   CLOSE l_cila_post_upd_csr;

        -- spawn the del process if sysdate not between eff start date and eff end date
        IF ((SYSDATE NOT BETWEEN nvl(l_eff_date_start,sysdate) AND nvl(l_eff_date_end, sysdate)) AND
                 (SYSDATE BETWEEN nvl(g_old_eff_date_start,sysdate) AND nvl(g_old_eff_date_end, sysdate) ) AND
                 (l_organization_id = g_old_organization_id AND l_subinventory_code = g_old_subinventory_code)) THEN

               CSM_INV_LOC_ASS_EVENT_PKG.INV_LOC_ASSIGNMENT_DEL_INIT(p_csp_inv_loc_assignment_id=>l_csp_inv_loc_assignment_id);

        -- spawn the ins process if sysdate  between eff start date and eff end date
         ELSIF ((SYSDATE NOT BETWEEN nvl(g_old_eff_date_start,sysdate) AND nvl(g_old_eff_date_end, sysdate)) AND
                 (SYSDATE BETWEEN nvl(l_eff_date_start,sysdate) AND nvl(l_eff_date_end, sysdate) ) AND
                 (l_organization_id = g_old_organization_id AND l_subinventory_code = g_old_subinventory_code)) THEN

               CSM_INV_LOC_ASS_EVENT_PKG.INV_LOC_ASSIGNMENT_INS_INIT(p_csp_inv_loc_assignment_id=>l_csp_inv_loc_assignment_id);

         ELSE -- update pub item if org/subinventory/default code is updated
               CSM_INV_LOC_ASS_EVENT_PKG.INV_LOC_ASSIGNMENT_UPD_INIT(p_csp_inv_loc_assignment_id=>l_csp_inv_loc_assignment_id);
         END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    CSM_UTIL_PKG.LOG('Exception in CSP_Inv_Loc_Assignmnt_Post_Upd for csp_inv_loc_assignment_id: '  || TO_CHAR(l_csp_inv_loc_assignment_id)
                        || ':' || l_sqlerrno || ':' || l_sqlerrmsg,
                       'CSM_WF_PKG.CSP_Inv_Loc_Assignmnt_Post_Upd',  FND_LOG.LEVEL_EXCEPTION);
END CSP_Inv_Loc_Assignmnt_Post_Upd;

PROCEDURE CSP_Inv_Loc_Assg_Post_Del(x_return_status OUT NOCOPY VARCHAR2)
IS
l_csp_inv_loc_assignment_id csp_inv_loc_assignments.csp_inv_loc_assignment_id%TYPE;
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  l_csp_inv_loc_assignment_id := CSP_INV_LOC_ASSIGNMENTS_PKG.user_hooks_rec.CSP_INV_LOC_ASSIGNMENT_ID;

  CSM_UTIL_PKG.LOG('Entering CSP_Inv_Loc_Assg_Post_Del for csp_inv_loc_assignment_id: '  || TO_CHAR(l_csp_inv_loc_assignment_id),
                    'CSM_WF_PKG.CSP_Inv_Loc_Assg_Post_Del', FND_LOG.LEVEL_PROCEDURE );

  CSM_INV_LOC_ASS_EVENT_PKG.INV_LOC_ASSIGNMENT_DEL_INIT(p_csp_inv_loc_assignment_id=>l_csp_inv_loc_assignment_id);

  CSM_UTIL_PKG.LOG('Leaving CSP_Inv_Loc_Assg_Post_Del for csp_inv_loc_assignment_id: '  || TO_CHAR(l_csp_inv_loc_assignment_id),
                    'CSM_WF_PKG.CSP_Inv_Loc_Assg_Post_Del', FND_LOG.LEVEL_PROCEDURE );

EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    CSM_UTIL_PKG.LOG('Exception in CSP_Inv_Loc_Assg_Post_Del for csp_inv_loc_assignment_id: '  || TO_CHAR(l_csp_inv_loc_assignment_id)
                        || ':' || l_sqlerrno || ':' || l_sqlerrmsg,
                       'CSM_WF_PKG.CSP_Inv_Loc_Assg_Post_Del',  FND_LOG.LEVEL_EXCEPTION);
END CSP_Inv_Loc_Assg_Post_Del;


PROCEDURE CSP_SHIP_TO_ADDRESS_POST_INS(x_return_status OUT NOCOPY VARCHAR2)
IS
l_location_id       po_location_associations_all.location_id%TYPE;
l_sqlerrno varchar2(20);
l_sqlerrmsg varchar2(2000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_ship_locations_ins_csr (p_locationid NUMBER) IS
SELECT pla.location_id              location_id,
       csu.site_use_id              site_use_id,
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
WHERE  pla.location_id       = p_locationid
AND    csu.site_use_id       = pla.site_use_id
AND    csu.site_use_code     = 'SHIP_TO'
AND    csu.cust_acct_site_id = cas.cust_acct_site_id
AND    cas.cust_account_id   = rcr.customer_id
AND    jtrs.resource_id      = rcr.resource_id
AND    cas.party_site_id     = hps.party_site_id
AND    cas.status            = 'A' -- only active sites
AND    hps.location_id       = hzl.location_id
AND NOT EXISTS
(SELECT 1
 FROM csm_po_loc_ass_all_acc acc
 WHERE acc.user_id = jtrs.user_id
 AND acc.location_id = pla.location_id
 AND acc.site_use_id = csu.site_use_id);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_location_id  := csp_ship_to_address_pvt.g_inv_loc_id;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  FOR r_ship_locations_ins_rec IN l_ship_locations_ins_csr(l_location_id) LOOP
    IF csm_util_pkg.is_palm_resource(r_ship_locations_ins_rec.resource_id) THEN
       csm_party_site_event_pkg.party_sites_acc_i
                  (p_party_site_id=>r_ship_locations_ins_rec.party_site_id,
                   p_user_id=>r_ship_locations_ins_rec.user_id,
                   p_flowtype=>NULL,
                   p_error_msg=>l_error_msg,
                   x_return_status=>l_return_status);

       csm_po_locations_event_pkg.csp_ship_to_addr_mdirty_i
                   (p_location_id=>r_ship_locations_ins_rec.location_id,
                    p_site_use_id=>r_ship_locations_ins_rec.site_use_id,
                    p_user_id=>r_ship_locations_ins_rec.user_id);
    ELSE
      CSM_UTIL_PKG.LOG('Resource:' || r_ship_locations_ins_rec.resource_id || ' not a mobile resource', 'CSM_WF_PKG.CSP_SHIP_TO_ADDRESS_POST_INS',
                                              FND_LOG.LEVEL_ERROR );
    END IF;

  END LOOP;
  CSM_UTIL_PKG.LOG('Leaving CSM_WF_PKG.CSP_SHIP_TO_ADDRESS_POST_INS', 'CSM_WF_PKG.CSP_SHIP_TO_ADDRESS_POST_INS',
                                              FND_LOG.LEVEL_PROCEDURE );

EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    CSM_UTIL_PKG.LOG('Exception in CSM_WF_PKG.CSP_SHIP_TO_ADDRESS_POST_INS:' || l_sqlerrno || ':' || l_sqlerrmsg,
                                             'CSM_WF_PKG.CSP_SHIP_TO_ADDRESS_POST_INS',  FND_LOG.LEVEL_EXCEPTION);
END CSP_SHIP_TO_ADDRESS_POST_INS;

PROCEDURE CSP_SHIP_TO_ADDRESS_POST_UPD(x_return_status OUT NOCOPY varchar2)
IS
l_location_id       po_location_associations_all.location_id%TYPE;
l_sqlerrno varchar2(20);
l_sqlerrmsg varchar2(2000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_ship_locations_upd_csr (p_locationid NUMBER) IS
SELECT pla.location_id              location_id,
       csu.site_use_id              site_use_id,
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
WHERE  pla.location_id       = p_locationid
AND    csu.site_use_id       = pla.site_use_id
AND    csu.site_use_code     = 'SHIP_TO'
AND    csu.cust_acct_site_id = cas.cust_acct_site_id
AND    cas.cust_account_id   = rcr.customer_id
AND    jtrs.resource_id      = rcr.resource_id
AND    cas.party_site_id     = hps.party_site_id
AND    cas.status            = 'A' -- only active sites
AND    hps.location_id       = hzl.location_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  l_location_id  := csp_ship_to_address_pvt.g_inv_loc_id;

  CSM_UTIL_PKG.LOG('Entering CSM_WF_PKG.CSP_SHIP_TO_ADDRESS_POST_INS', 'CSM_WF_PKG.CSP_SHIP_TO_ADDRESS_POST_UPD',
                                              FND_LOG.LEVEL_PROCEDURE );

  FOR r_ship_locations_upd_rec IN l_ship_locations_upd_csr(l_location_id) LOOP
    IF csm_util_pkg.is_palm_resource(r_ship_locations_upd_rec.resource_id) THEN
       csm_party_site_event_pkg.party_sites_acc_u
                  (p_party_site_id=>r_ship_locations_upd_rec.party_site_id,
                   p_user_id=>r_ship_locations_upd_rec.user_id,
                   p_error_msg=>l_error_msg,
                   x_return_status=>l_return_status);


       csm_po_locations_event_pkg.csp_ship_to_addr_mdirty_u
                   (p_location_id=>r_ship_locations_upd_rec.location_id,
                    p_site_use_id=>r_ship_locations_upd_rec.site_use_id,
                    p_user_id=>r_ship_locations_upd_rec.user_id);
    ELSE
      CSM_UTIL_PKG.LOG('Resource:' || r_ship_locations_upd_rec.resource_id || ' not a mobile resource', 'CSM_WF_PKG.CSP_SHIP_TO_ADDRESS_POST_UPD',
                                              FND_LOG.LEVEL_ERROR );
    END IF;

  END LOOP;

  CSM_UTIL_PKG.LOG('Leaving CSM_WF_PKG.CSP_SHIP_TO_ADDRESS_POST_UPD', 'CSM_WF_PKG.CSP_SHIP_TO_ADDRESS_POST_UPD',
                                              FND_LOG.LEVEL_PROCEDURE );

EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    CSM_UTIL_PKG.LOG('Exception in CSM_WF_PKG.CSP_SHIP_TO_ADDRESS_POST_UPD:' || l_sqlerrno || ':' || l_sqlerrmsg,
                                             'CSM_WF_PKG.CSP_SHIP_TO_ADDRESS_POST_UPD',  FND_LOG.LEVEL_EXCEPTION);
END CSP_SHIP_TO_ADDRESS_POST_UPD;

PROCEDURE CSP_REQ_HEADERS_POST_INS(x_return_status OUT NOCOPY varchar2)
IS
l_req_header_id       csp_requirement_headers.requirement_header_id%TYPE;
l_sqlerrno varchar2(20);
l_sqlerrmsg varchar2(2000);

CURSOR l_req_hdr_csr(p_req_header_id IN NUMBER ) IS
SELECT hdr.resource_id,
       jtrs.user_id
FROM   csp_requirement_headers hdr,
       jtf_rs_resource_extns jtrs
WHERE  hdr.requirement_header_id = p_req_header_id
AND    jtrs.resource_id = hdr.resource_id
UNION
SELECT ta.resource_id,
       jtrs.user_id
FROM   csp_requirement_headers hdr,
       jtf_tasks_b jt,
       jtf_task_assignments ta,
       jtf_rs_resource_extns jtrs
WHERE  hdr.requirement_header_id = p_req_header_id
AND    jt.task_id = hdr.task_id
AND    ta.task_id = jt.task_id
AND    jtrs.resource_id = ta.resource_id
;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  CSM_UTIL_PKG.LOG('Entering CSM_WF_PKG.CSP_REQ_HEADERS_POST_INS', 'CSM_WF_PKG.CSP_REQ_HEADERS_POST_INS',
                                              FND_LOG.LEVEL_PROCEDURE );

  l_req_header_id  := CSP_REQUIREMENT_HEADERS_PKG.user_hooks_rec.REQUIREMENT_HEADER_ID;

  FOR r_req_hdr_rec IN l_req_hdr_csr(l_req_header_id) LOOP
    IF csm_util_pkg.is_palm_resource(r_req_hdr_rec.resource_id) THEN
        csm_csp_req_headers_event_pkg.csp_req_headers_mdirty_i(p_requirement_header_id=>l_req_header_id,
                                                               p_user_id=>r_req_hdr_rec.user_id);
    ELSE
      CSM_UTIL_PKG.LOG('Resource:' || r_req_hdr_rec.resource_id || ' not a mobile resource',
                                      'CSM_WF_PKG.CSP_REQ_HEADERS_POST_INS', FND_LOG.LEVEL_ERROR );
    END IF;

  END LOOP;
  CSM_UTIL_PKG.LOG('Leaving CSM_WF_PKG.CSP_REQ_HEADERS_POST_INS', 'CSM_WF_PKG.CSP_REQ_HEADERS_POST_INS',
                                              FND_LOG.LEVEL_PROCEDURE );

EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    CSM_UTIL_PKG.LOG('Exception in CSM_WF_PKG.CSP_REQ_HEADERS_POST_INS:' || l_sqlerrno || ':' || l_sqlerrmsg,
                                             'CSM_WF_PKG.CSP_REQ_HEADERS_POST_INS',  FND_LOG.LEVEL_EXCEPTION);
END CSP_REQ_HEADERS_POST_INS;

PROCEDURE CSP_REQ_HEADERS_POST_UPD(x_return_status OUT NOCOPY varchar2)
IS
l_req_header_id       csp_requirement_headers.requirement_header_id%TYPE;
l_sqlerrno varchar2(20);
l_sqlerrmsg varchar2(2000);

CURSOR l_req_hdr_csr(p_req_header_id IN NUMBER )
IS
SELECT acc.requirement_header_id,
       acc.user_id
FROM  csm_req_headers_acc acc
WHERE acc.requirement_header_id = p_req_header_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  CSM_UTIL_PKG.LOG('Entering CSM_WF_PKG.CSP_REQ_HEADERS_POST_UPD', 'CSM_WF_PKG.CSP_REQ_HEADERS_POST_UPD',
                                              FND_LOG.LEVEL_PROCEDURE );

  l_req_header_id  := CSP_REQUIREMENT_HEADERS_PKG.user_hooks_rec.REQUIREMENT_HEADER_ID;

  FOR r_req_hdr_rec IN l_req_hdr_csr(l_req_header_id) LOOP
        csm_csp_req_headers_event_pkg.csp_req_headers_mdirty_u(p_requirement_header_id=>l_req_header_id,
                                                               p_user_id=>r_req_hdr_rec.user_id);

  END LOOP;
  CSM_UTIL_PKG.LOG('Leaving CSM_WF_PKG.CSP_REQ_HEADERS_POST_UPD', 'CSM_WF_PKG.CSP_REQ_HEADERS_POST_UPD',
                                              FND_LOG.LEVEL_PROCEDURE );

EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    CSM_UTIL_PKG.LOG('Exception in CSM_WF_PKG.CSP_REQ_HEADERS_POST_UPD:' || l_sqlerrno || ':' || l_sqlerrmsg,
                                             'CSM_WF_PKG.CSP_REQ_HEADERS_POST_UPD',  FND_LOG.LEVEL_EXCEPTION);
END CSP_REQ_HEADERS_POST_UPD;

PROCEDURE CSP_REQ_HEADERS_POST_DEL(x_return_status OUT NOCOPY varchar2)
IS
l_req_header_id       csp_requirement_headers.requirement_header_id%TYPE;
l_sqlerrno varchar2(20);
l_sqlerrmsg varchar2(2000);

CURSOR l_req_hdr_acc_csr(p_req_header_id IN NUMBER ) IS
SELECT acc.requirement_header_id,
       acc.user_id
FROM  csm_req_headers_acc acc
WHERE acc.requirement_header_id = p_req_header_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  CSM_UTIL_PKG.LOG('Entering CSM_WF_PKG.CSP_REQ_HEADERS_POST_DEL', 'CSM_WF_PKG.CSP_REQ_HEADERS_POST_DEL',
                                              FND_LOG.LEVEL_PROCEDURE );

  l_req_header_id  := CSP_REQUIREMENT_HEADERS_PKG.user_hooks_rec.REQUIREMENT_HEADER_ID;

  FOR r_req_hdr_acc_rec IN l_req_hdr_acc_csr(l_req_header_id) LOOP
        csm_csp_req_headers_event_pkg.csp_req_headers_mdirty_d(p_requirement_header_id=>l_req_header_id,
                                                               p_user_id=>r_req_hdr_acc_rec.user_id);

  END LOOP;
  CSM_UTIL_PKG.LOG('Leaving CSM_WF_PKG.CSP_REQ_HEADERS_POST_DEL', 'CSM_WF_PKG.CSP_REQ_HEADERS_POST_DEL',
                                              FND_LOG.LEVEL_PROCEDURE );

EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    CSM_UTIL_PKG.LOG('Exception in CSM_WF_PKG.CSP_REQ_HEADERS_POST_DEL:' || l_sqlerrno || ':' || l_sqlerrmsg,
                                             'CSM_WF_PKG.CSP_REQ_HEADERS_POST_DEL',  FND_LOG.LEVEL_EXCEPTION);
END CSP_REQ_HEADERS_POST_DEL;

PROCEDURE CSP_REQ_LINES_POST_INS(x_return_status OUT NOCOPY varchar2)
IS
l_req_line_id       csp_requirement_lines.requirement_line_id%TYPE;
l_sqlerrno varchar2(20);
l_sqlerrmsg varchar2(2000);

CURSOR l_req_line_csr(p_req_line_id IN NUMBER ) IS
SELECT hdr.requirement_header_id,
       hdr.resource_id,
       jtrs.user_id
FROM   csp_requirement_headers hdr,
       csp_requirement_lines line,
       jtf_rs_resource_extns jtrs
WHERE  hdr.requirement_header_id = line.requirement_header_id
AND    line.requirement_line_id = p_req_line_id
AND    jtrs.resource_id = hdr.resource_id
UNION
SELECT hdr.requirement_header_id,
       ta.resource_id,
       jtrs.user_id
FROM   csp_requirement_headers hdr,
       csp_requirement_lines line,
       jtf_tasks_b jt,
       jtf_task_assignments ta,
       jtf_rs_resource_extns jtrs
WHERE  hdr.requirement_header_id = line.requirement_header_id
AND    line.requirement_line_id = p_req_line_id
AND    jt.task_id = hdr.task_id
AND    ta.task_id = jt.task_id
AND    jtrs.resource_id = ta.resource_id
;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  CSM_UTIL_PKG.LOG('Entering CSM_WF_PKG.CSP_REQ_LINES_POST_INS', 'CSM_WF_PKG.CSP_REQ_LINES_POST_INS',
                                              FND_LOG.LEVEL_PROCEDURE );

  l_req_line_id  := CSP_REQUIREMENT_LINES_PKG.user_hook_rec.REQUIREMENT_LINE_ID;

  FOR r_req_line_rec IN l_req_line_csr(l_req_line_id) LOOP
    IF csm_util_pkg.is_palm_resource(r_req_line_rec.resource_id) THEN
        csm_csp_req_lines_event_pkg.csp_req_lines_mdirty_i(p_requirement_line_id=>l_req_line_id,
                                                           p_user_id=>r_req_line_rec.user_id);
    ELSE
      CSM_UTIL_PKG.LOG('Resource:' || r_req_line_rec.resource_id || ' not a mobile resource',
                                      'CSM_WF_PKG.CSP_REQ_LINES_POST_INS', FND_LOG.LEVEL_ERROR );
    END IF;

  END LOOP;
  CSM_UTIL_PKG.LOG('Leaving CSM_WF_PKG.CSP_REQ_LINES_POST_INS', 'CSM_WF_PKG.CSP_REQ_LINES_POST_INS',
                                              FND_LOG.LEVEL_PROCEDURE );

EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    CSM_UTIL_PKG.LOG('Exception in CSM_WF_PKG.CSP_REQ_LINES_POST_INS:' || l_sqlerrno || ':' || l_sqlerrmsg,
                                             'CSM_WF_PKG.CSP_REQ_LINES_POST_INS',  FND_LOG.LEVEL_EXCEPTION);
END CSP_REQ_LINES_POST_INS;

PROCEDURE CSP_REQ_LINES_POST_UPD(x_return_status OUT NOCOPY varchar2)
IS
l_req_line_id       csp_requirement_lines.requirement_line_id%TYPE;
l_sqlerrno varchar2(20);
l_sqlerrmsg varchar2(2000);

CURSOR l_req_line_csr(p_req_line_id IN NUMBER ) IS
SELECT acc.requirement_line_id,
       acc.user_id
FROM  csm_req_lines_acc acc
WHERE acc.requirement_line_id = p_req_line_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  CSM_UTIL_PKG.LOG('Entering CSM_WF_PKG.CSP_REQ_LINES_POST_UPD', 'CSM_WF_PKG.CSP_REQ_LINES_POST_UPD',
                                              FND_LOG.LEVEL_PROCEDURE );

  l_req_line_id  := CSP_REQUIREMENT_LINES_PKG.user_hook_rec.REQUIREMENT_LINE_ID;

  FOR r_req_line_rec IN l_req_line_csr(l_req_line_id) LOOP
        csm_csp_req_lines_event_pkg.csp_req_lines_mdirty_u(p_requirement_line_id=>l_req_line_id,
                                                           p_user_id=>r_req_line_rec.user_id);
  END LOOP;

  CSM_UTIL_PKG.LOG('Leaving CSM_WF_PKG.CSP_REQ_LINES_POST_UPD', 'CSM_WF_PKG.CSP_REQ_LINES_POST_UPD',
                                              FND_LOG.LEVEL_PROCEDURE );

EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    CSM_UTIL_PKG.LOG('Exception in CSM_WF_PKG.CSP_REQ_LINES_POST_UPD:' || l_sqlerrno || ':' || l_sqlerrmsg,
                                             'CSM_WF_PKG.CSP_REQ_LINES_POST_UPD',  FND_LOG.LEVEL_EXCEPTION);
END CSP_REQ_LINES_POST_UPD;

PROCEDURE CSP_REQ_LINES_POST_DEL(x_return_status OUT NOCOPY varchar2)
IS
l_req_line_id       csp_requirement_lines.requirement_line_id%TYPE;
l_sqlerrno varchar2(20);
l_sqlerrmsg varchar2(2000);

CURSOR l_req_line_acc_csr(p_req_line_id IN NUMBER ) IS
SELECT acc.requirement_line_id,
       acc.user_id
FROM  csm_req_lines_acc acc
WHERE acc.requirement_line_id = p_req_line_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  CSM_UTIL_PKG.LOG('Entering CSM_WF_PKG.CSP_REQ_LINES_POST_DEL', 'CSM_WF_PKG.CSP_REQ_LINES_POST_DEL',
                                              FND_LOG.LEVEL_PROCEDURE );

  l_req_line_id  := CSP_REQUIREMENT_LINES_PKG.user_hook_rec.REQUIREMENT_LINE_ID;

  FOR r_req_line_acc_rec IN l_req_line_acc_csr(l_req_line_id) LOOP
       csm_csp_req_lines_event_pkg.csp_req_lines_mdirty_d(p_requirement_line_id=>l_req_line_id,
                                                          p_user_id=>r_req_line_acc_rec.user_id);

  END LOOP;

  CSM_UTIL_PKG.LOG('Leaving CSM_WF_PKG.CSP_REQ_LINES_POST_DEL', 'CSM_WF_PKG.CSP_REQ_LINES_POST_DEL',
                                              FND_LOG.LEVEL_PROCEDURE );
EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    CSM_UTIL_PKG.LOG('Exception in CSM_WF_PKG.CSP_REQ_LINES_POST_DEL:' || l_sqlerrno || ':' || l_sqlerrmsg,
                                             'CSM_WF_PKG.CSP_REQ_LINES_POST_DEL',  FND_LOG.LEVEL_EXCEPTION);
END CSP_REQ_LINES_POST_DEL;

PROCEDURE CSP_REQ_LINE_DETAILS_POST_INS(x_return_status OUT NOCOPY varchar2)
IS
l_req_line_id       csp_requirement_lines.requirement_line_id%TYPE;
l_req_line_detail_id csp_req_line_details.req_line_detail_id%TYPE;
l_sqlerrno varchar2(20);
l_sqlerrmsg varchar2(2000);

CURSOR l_req_line_csr(p_req_line_id IN NUMBER )
IS
SELECT acc.requirement_line_id,
       acc.user_id
FROM  csm_req_lines_acc acc
WHERE acc.requirement_line_id = p_req_line_id;

CURSOR l_req_line_id_csr(p_req_line_detail_id IN number) IS
SELECT requirement_line_id
FROM csp_req_line_details
WHERE req_line_detail_id = p_req_line_detail_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  CSM_UTIL_PKG.LOG('Entering CSM_WF_PKG.CSP_REQ_LINE_DETAILS_POST_INS', 'CSM_WF_PKG.CSP_REQ_LINE_DETAILS_POST_INS',
                                              FND_LOG.LEVEL_PROCEDURE );

  l_req_line_detail_id := CSP_REQ_LINE_DETAILS_PKG.user_hook_rec.req_line_detail_id;

  OPEN l_req_line_id_csr(l_req_line_detail_id);
  FETCH l_req_line_id_csr INTO l_req_line_id;
  CLOSE l_req_line_id_csr;

  FOR r_req_line_rec IN l_req_line_csr(l_req_line_id) LOOP
      csm_csp_req_lines_event_pkg.csp_req_lines_mdirty_u(p_requirement_line_id=>l_req_line_id,
                                                         p_user_id=>r_req_line_rec.user_id);
  END LOOP;

--Notify User of new Order placed
  RAISE_START_AUTO_SYNC_EVENT('CSM_REQ_LINE_DETAILS',to_char(l_req_line_detail_id),'NEW');

  CSM_UTIL_PKG.LOG('Leaving CSM_WF_PKG.CSP_REQ_LINE_DETAILS_POST_INS', 'CSM_WF_PKG.CSP_REQ_LINE_DETAILS_POST_INS',
                                              FND_LOG.LEVEL_PROCEDURE );

EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    CSM_UTIL_PKG.LOG('Exception in CSM_WF_PKG.CSP_REQ_LINE_DETAILS_POST_INS:' || l_sqlerrno || ':' || l_sqlerrmsg,
                                             'CSM_WF_PKG.CSP_REQ_LINE_DETAILS_POST_INS',  FND_LOG.LEVEL_EXCEPTION);
    x_return_status := FND_API.G_RET_STS_ERROR;
END CSP_REQ_LINE_DETAILS_POST_INS;

PROCEDURE CSP_REQ_LINE_DETAILS_POST_UPD(x_return_status OUT NOCOPY varchar2)
IS
l_req_line_id       csp_requirement_lines.requirement_line_id%TYPE;
l_req_line_detail_id csp_req_line_details.req_line_detail_id%TYPE;
l_sqlerrno varchar2(20);
l_sqlerrmsg varchar2(2000);

CURSOR l_req_line_csr(p_req_line_id IN NUMBER )
IS
SELECT acc.requirement_line_id,
       acc.user_id
FROM  csm_req_lines_acc acc
WHERE acc.requirement_line_id = p_req_line_id;

CURSOR l_req_line_id_csr(p_req_line_detail_id IN number) IS
SELECT requirement_line_id
FROM csp_req_line_details
WHERE req_line_detail_id = p_req_line_detail_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  CSM_UTIL_PKG.LOG('Entering CSM_WF_PKG.CSP_REQ_LINE_DETAILS_POST_UPD', 'CSM_WF_PKG.CSP_REQ_LINE_DETAILS_POST_UPD',
                                              FND_LOG.LEVEL_PROCEDURE );

  l_req_line_detail_id := CSP_REQ_LINE_DETAILS_PKG.user_hook_rec.req_line_detail_id;

  OPEN l_req_line_id_csr(l_req_line_detail_id);
  FETCH l_req_line_id_csr INTO l_req_line_id;
  CLOSE l_req_line_id_csr;

  FOR r_req_line_rec IN l_req_line_csr(l_req_line_id) LOOP
      csm_csp_req_lines_event_pkg.csp_req_lines_mdirty_u(p_requirement_line_id=>l_req_line_id,
                                                         p_user_id=>r_req_line_rec.user_id);
  END LOOP;

  CSM_UTIL_PKG.LOG('Leaving CSM_WF_PKG.CSP_REQ_LINE_DETAILS_POST_UPD', 'CSM_WF_PKG.CSP_REQ_LINE_DETAILS_POST_UPD',
                                              FND_LOG.LEVEL_PROCEDURE );

EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    CSM_UTIL_PKG.LOG('Exception in CSM_WF_PKG.CSP_REQ_LINE_DETAILS_POST_UPD:' || l_sqlerrno || ':' || l_sqlerrmsg,
                                             'CSM_WF_PKG.CSP_REQ_LINE_DETAILS_POST_UPD',  FND_LOG.LEVEL_EXCEPTION);
    x_return_status := FND_API.G_RET_STS_ERROR;
END CSP_REQ_LINE_DETAILS_POST_UPD;

PROCEDURE CSP_REQ_LINE_DETAILS_PRE_DEL(x_return_status OUT NOCOPY varchar2)
IS
l_req_line_id       csp_requirement_lines.requirement_line_id%TYPE;
l_req_line_detail_id csp_req_line_details.req_line_detail_id%TYPE;
l_sqlerrno varchar2(20);
l_sqlerrmsg varchar2(2000);

CURSOR l_req_line_csr(p_req_line_id IN NUMBER )
IS
SELECT acc.requirement_line_id,
       acc.user_id
FROM  csm_req_lines_acc acc
WHERE acc.requirement_line_id = p_req_line_id;

CURSOR l_req_line_id_csr(p_req_line_detail_id IN number) IS
SELECT requirement_line_id
FROM csp_req_line_details
WHERE req_line_detail_id = p_req_line_detail_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  CSM_UTIL_PKG.LOG('Entering CSM_WF_PKG.CSP_REQ_LINE_DETAILS_PRE_DEL', 'CSM_WF_PKG.CSP_REQ_LINE_DETAILS_PRE_DEL',
                                              FND_LOG.LEVEL_PROCEDURE );

  l_req_line_detail_id := CSP_REQ_LINE_DETAILS_PKG.user_hook_rec.req_line_detail_id;

  OPEN l_req_line_id_csr(l_req_line_detail_id);
  FETCH l_req_line_id_csr INTO l_req_line_id;
  CLOSE l_req_line_id_csr;

  FOR r_req_line_rec IN l_req_line_csr(l_req_line_id) LOOP
      csm_csp_req_lines_event_pkg.csp_req_lines_mdirty_u(p_requirement_line_id=>l_req_line_id,
                                                         p_user_id=>r_req_line_rec.user_id);
  END LOOP;

  CSM_UTIL_PKG.LOG('Leaving CSM_WF_PKG.CSP_REQ_LINE_DETAILS_PRE_DEL', 'CSM_WF_PKG.CSP_REQ_LINE_DETAILS_PRE_DEL',
                                              FND_LOG.LEVEL_PROCEDURE );

EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    CSM_UTIL_PKG.LOG('Exception in CSM_WF_PKG.CSP_REQ_LINE_DETAILS_PRE_DEL:' || l_sqlerrno || ':' || l_sqlerrmsg,
                                             'CSM_WF_PKG.CSP_REQ_LINE_DETAILS_PRE_DEL',  FND_LOG.LEVEL_EXCEPTION);
END CSP_REQ_LINE_DETAILS_PRE_DEL;

/*--------------------------------------------------
  Description:
    Starts the NOTES_INS_USERLOOP workflow. Should be called when new
    NOTE is created.
    Invoked by JTM_NOTES_VUHK.create_note_post
   Parameter(s):
                p_api_version
                , p_init_msg_list
                , p_commit
                , p_validation_level
                , x_msg_count
                , x_msg_data
                , x_return_status
                ,p_jtf_note_id
----------------------------------------------------*/
PROCEDURE JTF_Note_Post_Ins(p_api_version           IN     NUMBER
                              , p_init_msg_list       IN     VARCHAR2
                              , p_commit              IN     VARCHAR2
                              , p_validation_level    IN     NUMBER
                              , x_msg_count           OUT NOCOPY NUMBER
                              , x_msg_data            OUT NOCOPY VARCHAR2
                              , x_return_status       OUT NOCOPY VARCHAR2
                              ,p_jtf_note_id in jtf_notes_b.jtf_note_id%type)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

l_PK_NAME_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
l_PK_TYPE_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
l_pk_value_list  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  l_PK_NAME_LIST(1):='JTF_NOTE_ID'; l_PK_TYPE_LIST(1):='NUMBER'; l_pk_value_list(1):= to_char(p_jtf_note_id);

  CSM_HA_EVENT_PKG.TRACK_HA_RECORD('JTF_NOTES_B',l_PK_NAME_LIST,l_PK_TYPE_LIST,l_pk_value_list,'I');

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
     RETURN;
  END IF;

  csm_notes_event_pkg.notes_make_dirty_i_foreachuser(p_jtf_note_id,l_error_msg,l_return_status);
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      csm_util_pkg.LOG(l_error_msg, 'CSM_WF_PKG.JTF_Note_Post_Ins', FND_LOG.LEVEL_ERROR);
  END IF;

EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    l_error_msg := l_error_msg || '- Exception in JTF_Note_Post_Ins for note_id:'
            || TO_CHAR(p_jtf_note_id) || l_sqlerrno || ':' || l_sqlerrmsg;
    CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_WF_PKG.JTF_Note_Post_Ins',FND_LOG.LEVEL_EXCEPTION);
END JTF_Note_Post_Ins;

/*--------------------------------------------------
  Description:
    Starts the NOTES_UPD_USERLOOP workflow. Should be called when new
    NOTE is updated.
    Invoked by JTM_NOTES_VUHK.update_note_post
   Parameter(s):
                p_api_version
                , p_init_msg_list
                , p_commit
                , p_validation_level
                , x_msg_count
                , x_msg_data
                , x_return_status
                ,p_jtf_note_id
----------------------------------------------------*/
PROCEDURE JTF_Note_PRE_Upd(p_api_version           IN     NUMBER
                            , p_init_msg_list       IN     VARCHAR2
                            , p_commit              IN     VARCHAR2
                            , p_validation_level    IN     NUMBER
                            , x_msg_count           OUT NOCOPY NUMBER
                            , x_msg_data            OUT NOCOPY VARCHAR2
                            , x_return_status       OUT NOCOPY VARCHAR2
                            ,p_jtf_note_id in jtf_notes_b.jtf_note_id%type)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(4000);

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
     RETURN;
   END IF;

   csm_notes_event_pkg.notes_make_dirty_i_foreachuser(p_jtf_note_id, l_error_msg, l_return_status);
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       csm_util_pkg.LOG(l_error_msg, 'CSM_WF_PKG.JTF_Note_Pre_Upd', FND_LOG.LEVEL_ERROR);
   END IF;

EXCEPTION
    WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR ;
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     l_error_msg := l_error_msg || '- Exception in JTF_Note_PRE_Upd for note_id:'
            || TO_CHAR(p_jtf_note_id) || l_sqlerrno || ':' || l_sqlerrmsg;
     CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_WF_PKG.JTF_Note_PRE_Upd',FND_LOG.LEVEL_EXCEPTION);
END JTF_Note_PRE_Upd;

PROCEDURE JTF_Note_POST_Upd(p_api_version           IN     NUMBER
                            , p_init_msg_list       IN     VARCHAR2
                            , p_commit              IN     VARCHAR2
                            , p_validation_level    IN     NUMBER
                            , x_msg_count           OUT NOCOPY NUMBER
                            , x_msg_data            OUT NOCOPY VARCHAR2
                            , x_return_status       OUT NOCOPY VARCHAR2
                            ,p_jtf_note_id in jtf_notes_b.jtf_note_id%type)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(4000);
l_PK_NAME_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
l_PK_TYPE_LIST  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');
l_pk_value_list  CSM_VARCHAR_LIST:=CSM_VARCHAR_LIST('');

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_PK_NAME_LIST(1):='JTF_NOTE_ID'; l_PK_TYPE_LIST(1):='NUMBER'; l_pk_value_list(1):= to_char(p_jtf_note_id);

  CSM_HA_EVENT_PKG.TRACK_HA_RECORD('JTF_NOTES_B',l_PK_NAME_LIST,l_PK_TYPE_LIST,l_pk_value_list,'U');

   /*REST OF THIS OPERATION NOT SUPPORTED BY MFS*/

EXCEPTION
    WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR ;
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     l_error_msg := l_error_msg || '- Exception in JTF_Note_POST_Upd for note_id:'
            || TO_CHAR(p_jtf_note_id) || l_sqlerrno || ':' || l_sqlerrmsg;
     CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_WF_PKG.JTF_Note_POST_Upd',FND_LOG.LEVEL_EXCEPTION);
END JTF_Note_POST_Upd;

Procedure CSI_Item_Instance_Post_Ins(p_api_version IN     NUMBER
                              , p_init_msg_list       IN     VARCHAR2
                              , p_commit              IN     VARCHAR2
                              , p_validation_level    IN     NUMBER
                              , p_instance_id         IN     NUMBER
                              , x_return_status       OUT NOCOPY VARCHAR2
                              , x_msg_count           OUT NOCOPY NUMBER
                              , x_msg_data            OUT NOCOPY VARCHAR2)
IS
l_old_wf_threshold number;
l_itemtype varchar2(30);
l_itemkey varchar2(30);
l_seq_val	number(15);

CURSOR l_seq_val_csr IS
SELECT CSM_ACTIVITY_SEQ.nextval
FROM dual;

BEGIN
--    l_old_wf_threshold := wf_engine.threshold;
      NULL;

/*	OPEN l_seq_val_csr;
	FETCH l_seq_val_csr INTO l_seq_val;
	CLOSE l_seq_val_csr;

     --use the CSMTYPE3 itemtype
     l_itemtype := 'CSMTYPE3';
     --generate a unique itemkey
     l_itemkey := 'ITEM_I' || '_' || to_char(p_instance_id) || '_' || l_seq_val;

     --create the process
     wf_engine.CreateProcess(itemtype     => l_itemtype,
                             itemkey      => l_itemkey,
                             process      => 'ITEM_INSTANCE_INS');

     --set the activity threshold value to negatiev value, so that the
     --process gets defered to background
     wf_engine.threshold := -1;

     -- set jtf_note_id
     WF_ENGINE.SetItemAttrNumber(l_itemtype, l_itemkey, 'INSTANCE_ID',
       p_instance_id );

     wf_engine.StartProcess(l_itemtype, l_itemkey);
     wf_engine.threshold := l_old_wf_threshold;
*/
EXCEPTION
    WHEN OTHERS THEN
     csm_util_pkg.log('ERROR: CSI_ITEM_INSTANCE_POST_INS => '
        || to_char(p_instance_id));
END CSI_Item_Instance_Post_Ins;

Procedure CSI_Item_Instance_Pre_Upd(p_api_version IN     NUMBER
                              , p_init_msg_list       IN     VARCHAR2
                              , p_commit              IN     VARCHAR2
                              , p_validation_level    IN     NUMBER
                              , p_instance_id         IN     NUMBER
                              , x_return_status       OUT NOCOPY VARCHAR2
                              , x_msg_count           OUT NOCOPY NUMBER
                              , x_msg_data            OUT NOCOPY VARCHAR2)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_instance_id csi_item_instances.instance_id%TYPE;

BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

 CSM_ITEM_INSTANCE_EVENT_PKG.ITEM_INSTANCE_MDIRTY_U_ECHUSER(p_instance_id, l_error_msg, l_return_status);
 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    csm_util_pkg.LOG(l_error_msg, 'CSM_WF_PKG.CSI_Item_Instance_Pre_Upd', FND_LOG.LEVEL_ERROR);
 END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    l_error_msg := 'Exception in CSI_Item_Instance_Pre_Upd for instance_id:' || TO_CHAR(p_instance_id)
                 || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
    CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_WF_PKG.CSI_Item_Instance_Pre_Upd',FND_LOG.LEVEL_EXCEPTION);
END CSI_Item_Instance_Pre_Upd;

Procedure CS_Counter_Post_Ins(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_counter_id                 IN   NUMBER,
    x_object_version_number      OUT NOCOPY  NUMBER
   -- p_user_id in number,
   -- p_counter_id cs_counters.counter_id%type
)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  csm_counter_event_pkg.CTR_MAKE_DIRTY_I_FOREACHUSER(p_counter_id, l_error_msg, l_return_status);
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    csm_util_pkg.LOG(l_error_msg, 'CSM_WF_PKG.CS_Counter_Post_Ins', FND_LOG.LEVEL_ERROR);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    l_error_msg := 'Exception in CS_Counter_Post_Ins for counter_id:' || TO_CHAR(p_counter_id)
                 || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
    CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_WF_PKG.CS_Counter_Post_Ins',FND_LOG.LEVEL_EXCEPTION);
END CS_Counter_Post_Ins;

Procedure CS_Counter_Pre_Del(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_counter_id                 IN   NUMBER
)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  csm_counter_event_pkg.COUNTER_MDIRTY_D(p_counter_id, l_error_msg, l_return_status);
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    csm_util_pkg.LOG(l_error_msg, 'CSM_WF_PKG.CS_Counter_Pre_Del', FND_LOG.LEVEL_ERROR);
  END IF;

EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    l_error_msg := 'Exception in CS_Counter_Pre_Del for counter_id:' || TO_CHAR(p_counter_id)
                 || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
    CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_WF_PKG.CS_Counter_Pre_Del',FND_LOG.LEVEL_EXCEPTION);
END CS_Counter_Pre_Del;

PROCEDURE CS_CTR_GRP_INSTANCE_CRE_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_source_object_cd           IN   VARCHAR2,
    p_source_object_id           IN   NUMBER,
    p_ctr_grp_id                 IN   NUMBER,
    x_object_version_number      OUT NOCOPY  NUMBER
    )
IS
CURSOR l_counter_csr ( b_ctr_grp_id  NUMBER)
IS
SELECT counters.COUNTER_ID
FROM CS_COUNTERS counters
,    CS_COUNTER_GROUPS counter_groups
WHERE  counters.counter_group_id = counter_groups.counter_group_id
AND  counter_groups.counter_group_id = b_ctr_grp_id
AND counters.TYPE = 'REGULAR';

CURSOR l_acc_csr (b_source_object_cd VARCHAR2
                  ,b_source_object_id NUMBER
                  ,b_ctr_grp_id  NUMBER)
IS
SELECT COUNT(1)
FROM CS_COUNTER_GROUPS counter_groups
,    csm_item_instances_acc acc
WHERE b_source_object_cd = 'CP'
AND   counter_groups.counter_group_id = b_ctr_grp_id
AND   counter_groups.source_object_code = b_source_object_cd
AND   acc.instance_id = counter_groups.source_object_id
AND   counter_groups.source_object_id = b_source_object_id;

l_acc_cnt   NUMBER;
l_counter_rec l_counter_csr%ROWTYPE;
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  IF p_source_object_cd <> 'CP' THEN
    RETURN;
  END IF;

  -- check if the p_counter_id is belongs to a mobile item_instance.
  -- If not, return right here.
  OPEN l_acc_csr(p_source_object_cd, p_source_object_id, p_ctr_grp_id);
  FETCH l_acc_csr INTO l_acc_cnt;
    IF l_acc_cnt = 0 THEN
      CLOSE l_acc_csr;
      RETURN;
    END IF;
 CLOSE l_acc_csr;

 FOR l_counter_rec IN l_counter_csr(p_ctr_grp_id) LOOP
   CS_Counter_Post_Ins(
    P_Api_Version ,
    P_Init_Msg_List ,
    P_Commit ,
    X_Return_Status ,
    X_Msg_Count ,
    X_Msg_Data ,
    l_counter_rec.COUNTER_ID , -- p_counter_id ,
    x_object_version_number
   -- p_user_id in number,
   -- p_counter_id cs_counters.counter_id%type
  );
END LOOP;

EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    l_error_msg := 'Exception in CS_CTR_GRP_INSTANCE_CRE_POST for COUNTER_GROUP_ID:' || TO_CHAR(p_ctr_grp_id)
                 || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
    CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_WF_PKG.CS_CTR_GRP_INSTANCE_CRE_POST',FND_LOG.LEVEL_EXCEPTION);
END CS_CTR_GRP_INSTANCE_CRE_POST;

PROCEDURE CS_CTR_GRP_INSTANCE_PRE_DEL(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_source_object_cd           IN   VARCHAR2,
    p_source_object_id           IN   NUMBER
    )
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_acc_csr (b_source_object_cd VARCHAR2
                 ,b_source_object_id NUMBER)
IS
SELECT counters.counter_id
FROM CS_COUNTER_GROUPS counter_groups,
     cs_counters counters,
     csm_item_instances_acc acc
WHERE counter_groups.source_object_code = b_source_object_cd
AND   counter_groups.source_object_id = b_source_object_id
AND   acc.instance_id = counter_groups.source_object_id
AND   counters.counter_group_id = counter_groups.counter_group_id
AND   counters.TYPE = 'REGULAR';

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  IF p_source_object_cd <> 'CP' THEN
    RETURN;
  END IF;

 FOR r_acc_rec IN l_acc_csr(p_source_object_cd, p_source_object_id) LOOP
   CS_Counter_Pre_Del(
    P_Api_Version ,
    P_Init_Msg_List ,
    P_Commit ,
    X_Return_Status ,
    X_Msg_Count ,
    X_Msg_Data ,
    r_acc_rec.COUNTER_ID -- p_counter_id ,
  );
 END LOOP;

EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    l_error_msg := 'Exception in CS_CTR_GRP_INSTANCE_PRE_DEL for source_object_id:' || TO_CHAR(p_source_object_id)
                 || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
    CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_WF_PKG.CS_CTR_GRP_INSTANCE_PRE_DEL',FND_LOG.LEVEL_EXCEPTION);
END CS_CTR_GRP_INSTANCE_PRE_DEL;

PROCEDURE CS_COUNTER_GRP_Post_Upd( P_Api_Version              IN  NUMBER
                                   , P_Init_Msg_List            IN  VARCHAR2
                                   , P_Commit                   IN  VARCHAR2
                                   , X_Return_Status            OUT NOCOPY VARCHAR2
                                   , X_Msg_Count                OUT NOCOPY NUMBER
                                   , X_Msg_Data                 OUT NOCOPY VARCHAR2
                                   , p_ctr_grp_id               IN  NUMBER
                                   , p_object_version_number    IN  NUMBER
                                   , p_cascade_upd_to_instances IN  VARCHAR2
                                   , x_object_version_number    OUT NOCOPY NUMBER )
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_counter_csr ( b_ctr_grp_id  NUMBER)
IS
SELECT counters.counter_id
FROM CS_COUNTERS counters
,    CS_COUNTER_GROUPS counter_groups
,    csm_item_instances_acc acc
WHERE counter_groups.counter_group_id = b_ctr_grp_id
AND   counters.counter_group_id = counter_groups.counter_group_id
AND   counter_groups.source_object_code = 'CP'
AND   acc.instance_id = counter_groups.source_object_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  FOR r_counter_csr IN l_counter_csr(p_ctr_grp_id) LOOP
   CS_Counter_Post_Upd(
      P_Api_Version,
      P_Init_Msg_List,
      P_Commit,
      X_Return_Status,
      X_Msg_Count,
      X_Msg_Data,
      r_counter_csr.counter_id,
      p_object_version_number,
      p_cascade_upd_to_instances,
      x_object_version_number);
  END LOOP;

EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    l_error_msg := 'Exception in CS_COUNTER_GRP_Post_Upd for counter_grp_id:' || TO_CHAR(p_ctr_grp_id)
                 || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
    CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_WF_PKG.CS_COUNTER_GRP_Post_Upd',FND_LOG.LEVEL_EXCEPTION);
END CS_COUNTER_GRP_Post_Upd;

PROCEDURE CS_COUNTERS_INSTANTIATE_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_counter_group_id_template  IN   NUMBER,
    p_source_object_cd         IN  VARCHAR2,
    p_source_object_id           IN  NUMBER,
    x_ctr_grp_id_template        IN  NUMBER,
    p_ctr_grp_id                 IN  NUMBER
    )
IS
  l_object_version_number       NUMBER;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  CS_CTR_GRP_INSTANCE_CRE_POST(
    P_Api_Version,
    P_Init_Msg_List,
    P_Commit  ,
    X_Return_Status ,
    X_Msg_Count ,
    X_Msg_Data  ,
    p_source_object_cd ,
    p_source_object_id ,
    p_ctr_grp_id  ,
    l_object_version_number
  );
EXCEPTION
   --log the error
   WHEN OTHERS THEN
     csm_util_pkg.log('ERROR: COUNTER_GROUP_ID => ' || to_char(p_ctr_grp_id));
END CS_COUNTERS_INSTANTIATE_POST;



/*------------
  Check if the counter_id is a mobile valid id. If not return.
  If yes, do update
  ------------*/
Procedure CS_Counter_Pre_Upd(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_counter_id                     IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_cascade_upd_to_instances   IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_object_version_number      OUT NOCOPY  NUMBER
--  p_user_id in number,
--  p_cs_counters cs_counters%rowtype
)
IS

/*  CURSOR l_acc_del_csr(b_counter_id NUMBER) IS
    SELECT acc.user_id
    FROM CS_COUNTERS counters
    ,    CS_COUNTER_GROUPS counter_groups
    ,    csm_item_instances_acc acc
    WHERE  counters.counter_group_id = counter_groups.counter_group_id
    AND   counter_groups.source_object_code = 'CP'
    AND   SYSDATE NOT BETWEEN NVL(counters.start_date_active, SYSDATE) AND NVL(counters.end_date_active, SYSDATE)
    and   acc.instance_id = counter_groups.source_object_id
    and   counters.counter_id = b_counter_id;

  CURSOR l_acc_upd_csr(b_counter_id NUMBER) IS
    SELECT acc.user_id
    FROM CS_COUNTERS counters
    ,    CS_COUNTER_GROUPS counter_groups
    ,    csm_item_instances_acc acc
    WHERE  counters.counter_group_id = counter_groups.counter_group_id
    AND   counter_groups.source_object_code = 'CP'
    AND   SYSDATE BETWEEN NVL(counters.start_date_active, SYSDATE) AND NVL(counters.end_date_active, SYSDATE)
    and   acc.instance_id = counter_groups.source_object_id
    and   counters.counter_id = b_counter_id;

   l_acc_rec l_acc_upd_csr%ROWTYPE;
*/
	CURSOR l_seq_val_csr IS
	SELECT CSM_ACTIVITY_SEQ.nextval
	FROM dual;

BEGIN
--  csm_util_pkg.log('csm_wf_pkg.cs_counter_pre_upd eneterd');
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   EXCEPTION
   --log the error
   WHEN OTHERS THEN
     csm_util_pkg.log('ERROR: COUNTER_ID => ' || to_char(p_counter_id));
END CS_Counter_Pre_Upd;

PROCEDURE CS_Counter_Post_Upd(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_counter_id                     IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_cascade_upd_to_instances   IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_object_version_number      OUT NOCOPY  NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_acc_csr(b_counter_id NUMBER) IS
SELECT COUNT(1)
FROM CS_COUNTERS counters
,    CS_COUNTER_GROUPS counter_groups
,    csm_item_instances_acc acc
WHERE  counters.counter_group_id = counter_groups.counter_group_id
AND   counter_groups.source_object_code = 'CP'
AND   acc.instance_id = counter_groups.source_object_id
AND   counters.counter_id = b_counter_id;

l_acc_cnt NUMBER;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  -- check if the p_counter_id is belongs to a mobile item_instance.
  -- If not, return right here.
 OPEN l_acc_csr(p_counter_id);
 FETCH l_acc_csr INTO l_acc_cnt;
   IF l_acc_cnt = 0 THEN
     CLOSE l_acc_csr;
     RETURN;
   END IF;
 CLOSE l_acc_csr;

  csm_counter_event_pkg.CTR_MAKE_DIRTY_U_FOREACHUSER(p_counter_id, l_error_msg, l_return_status);
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    csm_util_pkg.LOG(l_error_msg, 'CSM_WF_PKG.CS_Counter_Post_Upd', FND_LOG.LEVEL_ERROR);
  END IF;

EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    l_error_msg := 'Exception in CS_Counter_Post_Upd for counter_id:' || TO_CHAR(p_counter_id)
                 || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
    CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_WF_PKG.CS_Counter_Post_Upd',FND_LOG.LEVEL_EXCEPTION);
END CS_Counter_Post_Upd;


 /********************************************************
   Starts the COUNTER_VALUE_INS_USERLOOP workflow. Should be called when new
   counter value is added

   Arguments:
   p_counter_value_id: COUNTER_VALUE_ID corresponding to the new counter
   value added
   *********************************************************/
Procedure CS_Counter_Value_Post_Ins(p_api_version           IN     NUMBER
                              , p_init_msg_list       IN     VARCHAR2
                              , p_commit              IN     VARCHAR2
                              , p_validation_level    IN     NUMBER
                              , p_counter_grp_log_id  IN  NUMBER
                              , x_return_status       OUT NOCOPY VARCHAR2
                              , x_msg_count           OUT NOCOPY NUMBER
                              , x_msg_data            OUT NOCOPY VARCHAR2)
IS
l_counter_grp_log_id cs_counter_grp_log.counter_grp_log_id%TYPE;
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  l_counter_grp_log_id := p_counter_grp_log_id;

  csm_counter_event_pkg.CTR_VAL_MAKE_DIRTY_FOREACHUSER(l_counter_grp_log_id, l_error_msg, l_return_status);
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    csm_util_pkg.LOG(l_error_msg, 'CSM_WF_PKG.CS_Counter_Value_Post_Ins', FND_LOG.LEVEL_ERROR);
  END IF;

EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    l_error_msg := 'Exception in CS_Counter_Value_Post_Ins for counter_grp_log_id:' || TO_CHAR(l_counter_grp_log_id)
                 || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
    CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_WF_PKG.CS_Counter_Value_Post_Ins',FND_LOG.LEVEL_EXCEPTION);
END CS_Counter_Value_Post_Ins;

   /********************************************************
   Starts the COUNTER_VALUE_UPD_USERLOOP workflow. Should be called when new
   counter value is updated

   Arguments:
   *********************************************************/
PROCEDURE CS_Counter_Value_Pre_Upd(p_api_version           IN     NUMBER
                              , p_init_msg_list       IN     VARCHAR2
                              , p_commit              IN     VARCHAR2
                              , p_validation_level    IN     NUMBER
                              , p_counter_grp_log_id    IN  NUMBER
                              , p_object_version_number IN NUMBER
                              , x_return_status       OUT NOCOPY VARCHAR2
                              , x_msg_count           OUT NOCOPY NUMBER
                              , x_msg_data            OUT NOCOPY VARCHAR2 )
IS
l_counter_grp_log_id cs_counter_grp_log.counter_grp_log_id%TYPE;
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
    RETURN;
  END IF;

  l_counter_grp_log_id := p_counter_grp_log_id;

  csm_counter_event_pkg.CTR_VAL_MAKE_DIRTY_FOREACHUSER(l_counter_grp_log_id, l_error_msg, l_return_status);
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    csm_util_pkg.LOG(l_error_msg, 'CSM_WF_PKG.CS_Counter_Value_Pre_Upd', FND_LOG.LEVEL_ERROR);
  END IF;

EXCEPTION
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    l_error_msg := 'Exception in CS_Counter_Value_Pre_Upd for counter_grp_log_id:' || TO_CHAR(l_counter_grp_log_id)
                 || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
    CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_WF_PKG.CS_Counter_Value_Pre_Upd',FND_LOG.LEVEL_EXCEPTION);
END CS_Counter_Value_Pre_Upd;

   Procedure CS_Counter_Property_Post_Ins(p_user_id in number,
                                     p_cs_counter_prop cs_counter_properties%rowtype)
   IS
   BEGIN
      null;
   END;

   Procedure CS_Counter_Property_Pre_Upd(p_user_id in number,
                                     p_cs_counter_prop cs_counter_properties%rowtype)
   IS
   BEGIN
      null;
   END;

   Procedure CS_Counter_Prop_Val_Post_Ins(p_user_id in number,
                                     p_cs_counter_prop_val cs_counter_prop_values%rowtype)
   IS
   BEGIN
      null;
   END;

   Procedure CS_Counter_Prop_Val_Pre_Upd(p_user_id in number,
                                     p_cs_counter_prop_val cs_counter_prop_values%rowtype)
   IS
   BEGIN
      null;
   END;

/*--------------------------------------------------------
  Description:
    It starts the USER_DEL workflow process.
    Called when a Field Service Palm user is deleted
  Parameter(s):
    User_ID
--------------------------------------------------------*/
Procedure User_Del(p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
  CSM_UTIL_PKG.LOG('Entering User_Del for user_id: ' || p_user_id, 'csm_wf_pkg.User_Del',FND_LOG.LEVEL_PROCEDURE);

  csm_user_event_pkg.user_del_init(p_user_id=>p_user_id);

  CSM_UTIL_PKG.LOG('Leaving User_Del for user_id: ' || p_user_id, 'csm_wf_pkg.User_Del',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  WHEN OTHERS THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     l_error_msg := ' Exception in  User_Del for user_id:'
                       || to_char(p_user_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
     CSM_UTIL_PKG.LOG(l_error_msg, 'csm_wf_pkg.User_Del',FND_LOG.LEVEL_EXCEPTION);
     RAISE;
END User_Del;

PROCEDURE RAISE_START_AUTO_SYNC_EVENT(l_entity VARCHAR2 , l_pk_value VARCHAR2, l_mode VARCHAR2)
IS
l_wf_param wf_event_t;
l_e NUMBER;

BEGIN
   IF NVL(CSM_HA_SERVICE_PUB.IS_WF_ITEM_TYPE_ENABLED('CSM_MSGS'),'Y')='N' THEN
      CSM_UTIL_PKG.LOG('AUTO SYNC EVENTS ARE CURRENTLY DISABLED BY HA SERVICE API-s',
                    'CSM_WF_PKG.RAISE_START_AUTO_SYNC_EVENT',FND_LOG.LEVEL_PROCEDURE);
      RETURN;
   END IF;


/*It happens that post_assignment_ins_init returns without inserting TA
 but Task_post_upd does the insert.
 While Processing event both get notified as NEW Insert due to time lag.*/
IF l_entity='CSM_TASK_ASSIGNMENTS' AND l_mode = 'NEW' THEN
 SELECT 1 INTO l_e FROM CSM_TASK_ASSIGNMENTS_ACC
 WHERE TASK_ASSIGNMENT_ID=to_number(l_pk_value);
END IF;


 --Notify user with Start Sync Event
    wf_event_t.initialize(l_wf_param);
    l_wf_param.AddParameterToList('ENTITY',l_entity);
    l_wf_param.AddParameterToList('PK_VALUE',l_pk_value);
    l_wf_param.AddParameterToList('MODE',l_mode);
    --      csm_notification_event_pkg.notify_user(l_wf_param);
    wf_event.raise(p_event_name=>'oracle.apps.csm.download.startsync',
                   p_event_key=>l_pk_value,p_parameters=>l_wf_param.getParameterList,
                   p_event_data=>null,p_send_date=>null);
EXCEPTION
 WHEN Others  THEN
	  NULL;
END RAISE_START_AUTO_SYNC_EVENT;

END CSM_WF_PKG;

/
