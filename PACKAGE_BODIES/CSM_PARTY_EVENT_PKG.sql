--------------------------------------------------------
--  DDL for Package Body CSM_PARTY_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_PARTY_EVENT_PKG" AS
/* $Header: csmeptyb.pls 120.1 2005/07/25 00:18:48 trajasek noship $ */

g_table_name1            CONSTANT VARCHAR2(30) := 'HZ_PARTIES';
g_acc_table_name1        CONSTANT VARCHAR2(30) := 'CSM_PARTIES_ACC';
g_acc_sequence_name1     CONSTANT VARCHAR2(30) := 'CSM_PARTIES_ACC_S';
g_publication_item_name1 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                             CSM_ACC_PKG.t_publication_item_list('CSF_M_PARTIES');
g_pk1_name1              CONSTANT VARCHAR2(30) := 'PARTY_ID';

g_pub_item CONSTANT varchar(30) := 'CSF_M_PARTIES';

g_table_name2            CONSTANT VARCHAR2(30) := 'HZ_PARTY_SITES';
g_acc_table_name2        CONSTANT VARCHAR2(30) := 'CSM_PARTY_SITES_ACC';
g_acc_sequence_name2     CONSTANT VARCHAR2(30) := 'CSM_PARTY_SITES_ACC_S';
g_publication_item_name2 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                             CSM_ACC_PKG.t_publication_item_list('CSF_M_PARTY_SITES');
g_pk1_name2              CONSTANT VARCHAR2(30) := 'PARTY_SITE_ID';
g_pk2_name2              CONSTANT VARCHAR2(30) := 'PARTY_ID';

PROCEDURE INSERT_PARTIES_ACC (p_party_id hz_parties.party_id%TYPE,
  							p_user_id	fnd_user.user_id%TYPE,
         x_access_id OUT NOCOPY number)
IS
 l_sysdate 	date;
BEGIN
 l_sysdate := SYSDATE;

	INSERT INTO csm_parties_acc (party_id,
								 user_id,
								created_by,
								creation_date,
								last_updated_by,
								last_update_date,
								last_update_login,
        access_id,
        counter
								)
						VALUES (p_party_id,
								p_user_id,
								fnd_global.user_id,
								l_sysdate,
								fnd_global.user_id,
								l_sysdate,
								fnd_global.login_id,
        csm_parties_acc_s.nextval,
        1
								)
        RETURNING access_id INTO x_access_id;

  EXCEPTION
     WHEN others THEN
	    RAISE;

END INSERT_PARTIES_ACC;

PROCEDURE PARTY_ACC_I (p_party_id IN NUMBER,
                       p_user_id IN NUMBER,
                       p_flowtype IN VARCHAR2,
                       p_error_msg     OUT NOCOPY    VARCHAR2,
                       x_return_status IN OUT NOCOPY VARCHAR2
                       )
IS
l_err_msg VARCHAR2(4000);
l_ret_status VARCHAR2(4000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  p_error_msg := 'Entering CSM_PARTY_EVENT_PKG.PARTY_ACC_I' || ' for party_id ' || to_char(p_party_id);

  CSM_ACC_PKG.Insert_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
      ,P_ACC_TABLE_NAME         => g_acc_table_name1
      ,P_SEQ_NAME               => g_acc_sequence_name1
      ,P_PK1_NAME               => g_pk1_name1
      ,P_PK1_NUM_VALUE          => p_party_id
      ,P_USER_ID                => p_user_id
     );

   -- if not history, get notes for customer
   IF NOT csm_util_pkg.is_flow_history(p_flowtype) THEN
     CSM_NOTES_EVENT_PKG.NOTES_MAKE_DIRTY_I_GRP(p_sourceobjectcode => 'PARTY',
                                                p_sourceobjectid => p_party_id,
                                                p_userid => p_user_id,
                                                p_error_msg => l_err_msg,
                                                x_return_status => l_ret_status
                                                );

     IF l_ret_status <> FND_API.G_RET_STS_SUCCESS THEN
        csm_util_pkg.LOG(l_err_msg, 'CSM_PARTY_EVENT_PKG.PARTY_ACC_I', FND_LOG.LEVEL_ERROR);
     END IF;
   END IF;

  p_error_msg := 'Leaving CSM_PARTY_EVENT_PKG.PARTY_ACC_I' || ' for party_id ' || to_char(p_party_id);
EXCEPTION
  	WHEN others THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         p_error_msg := ' FAILED PARTY_ACC_I:' || to_char(p_party_id);
         CSM_UTIL_PKG.LOG( p_error_msg, 'CSM_PARTY_EVENT_PKG.PARTY_ACC_I', FND_LOG.LEVEL_EXCEPTION);
         RAISE;

END PARTY_ACC_I;

PROCEDURE PARTY_ACC_D (p_party_id IN NUMBER,
                       p_user_id IN NUMBER,
                       p_flowtype IN VARCHAR2,
                       p_error_msg     OUT NOCOPY    VARCHAR2,
                       x_return_status IN OUT NOCOPY VARCHAR2
                       )
IS
l_err_msg VARCHAR2(4000);
l_ret_status VARCHAR2(4000);
l_ref_exists NUMBER := 0 ;

/** Check ref for given party and user*/
CURSOR l_check_party_ref(l_party_id csm_parties_acc.party_id%TYPE,
                             l_user_id csm_parties_acc.user_id%TYPE) IS
SELECT 1
  FROM csm_parties_acc a,
       cs_incidents_all_b b,
       csm_incidents_all_acc c
 WHERE a.party_id = l_party_id
   AND a.user_id = l_user_id
   AND a.counter = 1
   AND a.party_id = b.customer_id
   AND b.incident_id =c.incident_id
   AND c.user_id = l_user_id ;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  p_error_msg := 'Entering CSM_PARTY_EVENT_PKG.PARTY_ACC_D' || ' for party_id ' || to_char(p_party_id);

/*  OPEN l_check_party_ref(p_party_id, p_user_id) ;
  FETCH l_check_party_REF INTO l_REF_EXISTS ;
  IF l_check_party_REF%NOTFOUND THEN
     l_ref_exists := 0 ;
  END IF ;
  CLOSE l_check_party_ref ;

  IF L_REF_EXISTS <> 1  THEN
  CSM_ACC_PKG.Delete_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
      ,P_ACC_TABLE_NAME         => g_acc_table_name1
      ,P_PK1_NAME               => g_pk1_name1
      ,P_PK1_NUM_VALUE          => p_party_id
      ,P_USER_ID                => p_user_id
     );
   END IF;
*/
-- commented the above..as such cases should not occur
  CSM_ACC_PKG.Delete_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
      ,P_ACC_TABLE_NAME         => g_acc_table_name1
      ,P_PK1_NAME               => g_pk1_name1
      ,P_PK1_NUM_VALUE          => p_party_id
      ,P_USER_ID                => p_user_id
     );

   -- delete notes if flow is not history
   IF NOT (csm_util_pkg.is_flow_history(p_flowtype)) THEN
      CSM_NOTES_EVENT_PKG.NOTES_MAKE_DIRTY_D_GRP(p_sourceobjectcode => 'PARTY',
                                                p_sourceobjectid => p_party_id,
                                                p_userid => p_user_id,
                                                p_error_msg => l_err_msg,
                                                x_return_status => l_ret_status
                                                );

     IF l_ret_status <> FND_API.G_RET_STS_SUCCESS THEN
        csm_util_pkg.LOG(l_err_msg, 'CSM_PARTY_EVENT_PKG.PARTY_ACC_D', FND_LOG.LEVEL_ERROR);
     END IF;
   END IF;

  p_error_msg := 'Leaving CSM_PARTY_EVENT_PKG.PARTY_ACC_D' || ' for party_id ' || to_char(p_party_id);
EXCEPTION
  	WHEN others THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         p_error_msg := ' FAILED PARTY_ACC_D:' || to_char(p_party_id);
         CSM_UTIL_PKG.LOG( p_error_msg, 'CSM_PARTY_EVENT_PKG.PARTY_ACC_D', FND_LOG.LEVEL_EXCEPTION);
         RAISE;

END PARTY_ACC_D;

FUNCTION PARTY_ORG_UPD_WF_EVENT_SUB(p_subscription_guid IN RAW, p_event IN OUT NOCOPY WF_EVENT_T)
RETURN VARCHAR2
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

l_party_id hz_parties.party_id%TYPE;
l_party_site_id hz_party_sites.party_site_id%TYPE;

CURSOR l_parties_csr (p_party_id hz_parties.party_id%TYPE)
IS
SELECT access_id, user_id
FROM csm_parties_acc
WHERE party_id = p_party_id;

CURSOR l_party_sites_csr (p_party_id hz_parties.party_id%TYPE)
IS
SELECT access_id, user_id
FROM csm_party_sites_acc
WHERE party_id = p_party_id;

BEGIN
   CSM_UTIL_PKG.LOG('Entering PARTY_ORG_UPD_WF_EVENT_SUB',
                         'CSM_PARTY_EVENT_PKG.PARTY_ORG_UPD_WF_EVENT_SUB',FND_LOG.LEVEL_PROCEDURE);

   IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
      RETURN 'SUCCESS';
   END IF;

   l_party_id := p_event.GetValueForParameter('PARTY_ID');

   -- get users who have access to this PARTY_ID
   FOR r_parties_rec IN l_parties_csr(l_party_id) LOOP
            -- Call Update
            CSM_ACC_PKG.Update_Acc
                ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
                 ,P_ACC_TABLE_NAME         => g_acc_table_name1
                 ,P_USER_ID                => r_parties_rec.user_id
                 ,P_ACCESS_ID              => r_parties_rec.access_id
                );
   END LOOP;

  -- update party_sites pub item
   FOR r_party_sites_rec IN l_party_sites_csr(l_party_id) LOOP
        -- Call Update
        CSM_ACC_PKG.Update_Acc
             ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name2
              ,P_ACC_TABLE_NAME         => g_acc_table_name2
              ,P_USER_ID                => r_party_sites_rec.user_id
              ,P_ACCESS_ID              => r_party_sites_rec.access_id
              );
   END LOOP;

   CSM_UTIL_PKG.LOG('Leaving PARTY_ORG_UPD_WF_EVENT_SUB for party_id: ' || TO_CHAR(l_party_id),
                         'CSM_PARTY_EVENT_PKG.PARTY_ORG_UPD_WF_EVENT_SUB',FND_LOG.LEVEL_PROCEDURE);
   RETURN 'SUCCESS';
EXCEPTION
 WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  PARTY_ORG_UPD_WF_EVENT_SUB for party_id:' || to_char(l_party_id)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_PARTY_EVENT_PKG.PARTY_ORG_UPD_WF_EVENT_SUB',FND_LOG.LEVEL_EXCEPTION);
        RETURN 'ERROR';
END PARTY_ORG_UPD_WF_EVENT_SUB;

END CSM_PARTY_EVENT_PKG;

/
