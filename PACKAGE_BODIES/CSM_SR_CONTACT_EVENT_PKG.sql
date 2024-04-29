--------------------------------------------------------
--  DDL for Package Body CSM_SR_CONTACT_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_SR_CONTACT_EVENT_PKG" AS
/* $Header: csmesrcb.pls 120.1 2005/07/25 00:22:12 trajasek noship $ */
/*** Globals ***/
g_srcntacts_acc_table_name        CONSTANT VARCHAR2(30) := 'CSM_SR_CONTACTS_ACC';
g_srcntacts_table_name            CONSTANT VARCHAR2(30) := 'CS_HZ_SR_CONTACT_POINTS';
g_srcntacts_seq_name              CONSTANT VARCHAR2(30) := 'CSM_SR_CONTACTS_ACC_S' ;
g_srcntacts_pk1_name              CONSTANT VARCHAR2(30) := 'SR_CONTACT_POINT_ID';
g_srcntacts_pubi_name CONSTANT CSM_ACC_PKG.t_publication_item_list :=
  CSM_ACC_PKG.t_publication_item_list('CSF_M_SR_CONTACTS');

l_markdirty_failed EXCEPTION;

PROCEDURE SR_CNTACT_MDIRTY_U_FOREACHUSER(p_sr_contact_point_id IN NUMBER)
IS
l_sr_contact_point_id cs_hz_sr_contact_points.sr_contact_point_id%type;
l_access_id      NUMBER;
l_err_msg VARCHAR2(4000);
l_user_id NUMBER;

CURSOR l_user_csr (p_sr_contact_point_id cs_hz_sr_contact_points.sr_contact_point_id%type) IS
SELECT access_id, user_id
FROM csm_sr_contacts_acc
WHERE sr_contact_point_id = p_sr_contact_point_id;

l_user_rec l_user_csr% ROWTYPE;
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);


BEGIN
--   x_return_status := FND_API.G_RET_STS_SUCCESS;
   CSM_UTIL_PKG.LOG('Entering SR_CNTACT_MDIRTY_U_FOREACHUSER for sr_contact_point_id: ' || p_sr_contact_point_id,
                         'CSM_SR_CONTACT_EVENT_PKG.SR_CNTACT_MDIRTY_U_FOREACHUSER',FND_LOG.LEVEL_PROCEDURE);


--   l_sr_contact_point_id := p_sr_contact_point_id;

      -- get users who have access to this SR_CONTACT_POINT_ID
	  FOR l_user_rec IN l_user_csr(p_sr_contact_point_id) LOOP

            -- Call Update
            CSM_ACC_PKG.Update_Acc
                ( P_PUBLICATION_ITEM_NAMES => g_srcntacts_pubi_name
                 ,P_ACC_TABLE_NAME         => g_srcntacts_acc_table_name
                 ,P_USER_ID                => l_user_rec.user_id
                 ,P_ACCESS_ID              => l_user_rec.access_id
                );
      END LOOP;

   CSM_UTIL_PKG.LOG('Leaving SR_CNTACT_MDIRTY_U_FOREACHUSER for sr_contact_point_id: ' || p_sr_contact_point_id,
                         'CSM_SR_CONTACT_EVENT_PKG.SR_CNTACT_MDIRTY_U_FOREACHUSER',FND_LOG.LEVEL_PROCEDURE);

 EXCEPTION
  	WHEN others THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  SR_CNTACT_MDIRTY_U_FOREACHUSER for sr_contact_point_id:' || to_char(p_sr_contact_point_id)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SR_CONTACT_EVENT_PKG.SR_CNTACT_MDIRTY_U_FOREACHUSER',FND_LOG.LEVEL_EXCEPTION);
     	 RAISE;
END SR_CNTACT_MDIRTY_U_FOREACHUSER;

PROCEDURE SR_CNTACT_MDIRTY_I(p_sr_contact_point_id IN NUMBER, p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering SR_CNTACT_MDIRTY_I for sr_contact_point_id: ' || p_sr_contact_point_id,
                         'CSM_SR_CONTACT_EVENT_PKG.SR_CNTACT_MDIRTY_I',FND_LOG.LEVEL_PROCEDURE);

    CSM_ACC_PKG.Insert_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_srcntacts_pubi_name
      ,P_ACC_TABLE_NAME         => g_srcntacts_acc_table_name
      ,P_SEQ_NAME               => g_srcntacts_seq_name
      ,P_PK1_NAME               => g_srcntacts_pk1_name
      ,P_PK1_NUM_VALUE          => p_sr_contact_point_id
      ,P_USER_ID                => p_user_id
     );

   CSM_UTIL_PKG.LOG('Leaving SR_CNTACT_MDIRTY_I for sr_contact_point_id: ' || p_sr_contact_point_id,
                         'CSM_SR_CONTACT_EVENT_PKG.SR_CNTACT_MDIRTY_I',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  SR_CNTACT_MDIRTY_I for sr_contact_point_id:' || to_char(p_sr_contact_point_id)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SR_CONTACT_EVENT_PKG.SR_CNTACT_MDIRTY_I',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END SR_CNTACT_MDIRTY_I;

PROCEDURE SPAWN_USERLOOP_SR_CONTACT_INS(p_sr_contact_point_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_sr_contact_usr_csr (p_sr_contact_point_id cs_hz_sr_contact_points.sr_contact_point_id%TYPE)
IS
SELECT acc.incident_id,
       acc.user_id
FROM cs_hz_sr_contact_points srcp,
     csm_incidents_all_acc acc
WHERE srcp.sr_contact_point_id = p_sr_contact_point_id
AND acc.incident_id = srcp.incident_id
AND NOT EXISTS
(SELECT 1
 FROM csm_sr_contacts_acc cont_acc
 WHERE cont_acc.sr_contact_point_id = srcp.sr_contact_point_id
 AND cont_acc.user_id = acc.user_id)
;

BEGIN
   CSM_UTIL_PKG.LOG('Entering SPAWN_USERLOOP_SR_CONTACT_INS for sr_contact_point_id: ' || p_sr_contact_point_id,
                         'CSM_SR_CONTACT_EVENT_PKG.SPAWN_USERLOOP_SR_CONTACT_INS',FND_LOG.LEVEL_PROCEDURE);

   FOR r_sr_contact_usr_rec IN l_sr_contact_usr_csr(p_sr_contact_point_id) LOOP
      csm_sr_event_pkg.spawn_sr_contacts_ins(p_incident_id=>r_sr_contact_usr_rec.incident_id,
                                             p_sr_contact_point_id=>p_sr_contact_point_id,
                                             p_user_id=>r_sr_contact_usr_rec.user_id,
                                             p_flowtype=>NULL);
   END LOOP;

   CSM_UTIL_PKG.LOG('Leaving SPAWN_USERLOOP_SR_CONTACT_INS for sr_contact_point_id: ' || p_sr_contact_point_id,
                         'CSM_SR_CONTACT_EVENT_PKG.SPAWN_USERLOOP_SR_CONTACT_INS',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  SPAWN_USERLOOP_SR_CONTACT_INS for sr_contact_point_id:' || to_char(p_sr_contact_point_id)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SR_CONTACT_EVENT_PKG.SPAWN_USERLOOP_SR_CONTACT_INS',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END SPAWN_USERLOOP_SR_CONTACT_INS;

PROCEDURE SR_CNTACT_MDIRTY_D(p_sr_contact_point_id IN NUMBER, p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering SR_CNTACT_MDIRTY_D for sr_contact_point_id: ' || p_sr_contact_point_id,
                         'CSM_SR_CONTACT_EVENT_PKG.SR_CNTACT_MDIRTY_D',FND_LOG.LEVEL_PROCEDURE);

   CSM_ACC_PKG.Delete_Acc
    ( P_PUBLICATION_ITEM_NAMES => g_srcntacts_pubi_name
     ,P_ACC_TABLE_NAME         => g_srcntacts_acc_table_name
     ,P_PK1_NAME               => g_srcntacts_pk1_name
     ,P_PK1_NUM_VALUE          => p_sr_contact_point_id
     ,P_USER_ID                => p_user_id
    );

   CSM_UTIL_PKG.LOG('Leaving SR_CNTACT_MDIRTY_D for sr_contact_point_id: ' || p_sr_contact_point_id,
                         'CSM_SR_CONTACT_EVENT_PKG.SR_CNTACT_MDIRTY_D',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  SR_CNTACT_MDIRTY_D for sr_contact_point_id:' || to_char(p_sr_contact_point_id)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SR_CONTACT_EVENT_PKG.SR_CNTACT_MDIRTY_D',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END SR_CNTACT_MDIRTY_D;

PROCEDURE SPAWN_USERLOOP_SR_CONTACT_DEL(p_sr_contact_point_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_sr_contact_usr_csr (p_sr_contact_point_id cs_hz_sr_contact_points.sr_contact_point_id%TYPE)
IS
SELECT acc.incident_id,
       acc.user_id
FROM cs_hz_sr_contact_points srcp,
     csm_incidents_all_acc acc
WHERE srcp.sr_contact_point_id = p_sr_contact_point_id
AND acc.incident_id = srcp.incident_id
AND EXISTS
(SELECT 1
 FROM csm_sr_contacts_acc cont_acc
 WHERE cont_acc.sr_contact_point_id = srcp.sr_contact_point_id
 AND cont_acc.user_id = acc.user_id)
;

BEGIN
   CSM_UTIL_PKG.LOG('Entering SPAWN_USERLOOP_SR_CONTACT_DEL for sr_contact_point_id: ' || p_sr_contact_point_id,
                         'CSM_SR_CONTACT_EVENT_PKG.SPAWN_USERLOOP_SR_CONTACT_DEL',FND_LOG.LEVEL_PROCEDURE);

   FOR r_sr_contact_usr_rec IN l_sr_contact_usr_csr(p_sr_contact_point_id) LOOP
      csm_sr_event_pkg.spawn_sr_contact_del(p_incident_id=>r_sr_contact_usr_rec.incident_id,
                                            p_sr_contact_point_id=>p_sr_contact_point_id,
                                            p_user_id=>r_sr_contact_usr_rec.user_id,
                                            p_flowtype=>NULL);
   END LOOP;

   CSM_UTIL_PKG.LOG('Leaving SPAWN_USERLOOP_SR_CONTACT_DEL for sr_contact_point_id: ' || p_sr_contact_point_id,
                         'CSM_SR_CONTACT_EVENT_PKG.SPAWN_USERLOOP_SR_CONTACT_DEL',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  SPAWN_USERLOOP_SR_CONTACT_DEL for sr_contact_point_id:' || to_char(p_sr_contact_point_id)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SR_CONTACT_EVENT_PKG.SPAWN_USERLOOP_SR_CONTACT_DEL',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END SPAWN_USERLOOP_SR_CONTACT_DEL;

FUNCTION CONTACT_POINT_UPD_WF_EVENT_SUB(p_subscription_guid IN RAW, p_event IN OUT NOCOPY WF_EVENT_T)
RETURN VARCHAR2
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_contact_point_id hz_contact_points.contact_point_id%TYPE;

CURSOR l_user_csr (p_contact_point_id hz_contact_points.contact_point_id%TYPE)
IS
SELECT acc.user_id,
       acc.access_id
FROM csm_sr_contacts_acc acc,
     cs_hz_sr_contact_points pts
WHERE acc.sr_contact_point_id = pts.sr_contact_point_id
AND pts.contact_point_id = p_contact_point_id;

BEGIN
   CSM_UTIL_PKG.LOG('Entering CONTACT_POINT_UPD_WF_EVENT_SUB',
                         'CSM_SR_CONTACT_EVENT_PKG.CONTACT_POINT_UPD_WF_EVENT_SUB',FND_LOG.LEVEL_PROCEDURE);

   IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
      RETURN 'SUCCESS';
   END IF;

   l_contact_point_id := p_event.GetValueForParameter('CONTACT_POINT_ID');

      -- get users who have access to this contact_point_id and there may be more than one record for this contact_point_id
	  FOR l_user_rec IN l_user_csr(l_contact_point_id) LOOP
            -- Call Update
            CSM_ACC_PKG.Update_Acc
                ( P_PUBLICATION_ITEM_NAMES => g_srcntacts_pubi_name
                 ,P_ACC_TABLE_NAME         => g_srcntacts_acc_table_name
                 ,P_USER_ID                => l_user_rec.user_id
                 ,P_ACCESS_ID              => l_user_rec.access_id
                );
      END LOOP;

   CSM_UTIL_PKG.LOG('Leaving CONTACT_POINT_UPD_WF_EVENT_SUB for contact_point_id: ' || TO_CHAR(l_contact_point_id),
                         'CSM_SR_CONTACT_EVENT_PKG.CONTACT_POINT_UPD_WF_EVENT_SUB',FND_LOG.LEVEL_PROCEDURE);
   RETURN 'SUCCESS';
EXCEPTION
 WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  CONTACT_POINT_UPD_WF_EVENT_SUB for contact_point_id:' || to_char(l_contact_point_id)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SR_CONTACT_EVENT_PKG.CONTACT_POINT_UPD_WF_EVENT_SUB',FND_LOG.LEVEL_EXCEPTION);
        RETURN 'ERROR';
END CONTACT_POINT_UPD_WF_EVENT_SUB;

END CSM_SR_CONTACT_EVENT_PKG;

/
