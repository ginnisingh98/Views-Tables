--------------------------------------------------------
--  DDL for Package Body CSM_PARTY_SITE_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_PARTY_SITE_EVENT_PKG" AS
/* $Header: csmeptsb.pls 120.1 2005/07/25 00:18:18 trajasek noship $ */

g_table_name1            CONSTANT VARCHAR2(30) := 'HZ_PARTY_SITES';
g_acc_table_name1        CONSTANT VARCHAR2(30) := 'CSM_PARTY_SITES_ACC';
g_acc_sequence_name1     CONSTANT VARCHAR2(30) := 'CSM_PARTY_SITES_ACC_S';
g_publication_item_name1 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                             CSM_ACC_PKG.t_publication_item_list('CSF_M_PARTY_SITES');
g_pk1_name1              CONSTANT VARCHAR2(30) := 'PARTY_SITE_ID';
g_pk2_name1              CONSTANT VARCHAR2(30) := 'PARTY_ID';

procedure insert_party_sites_acc (p_party_site_id hz_party_sites.party_site_id%type,
								p_party_id	hz_parties.party_id%type,
  								p_user_id	fnd_user.user_id%type)
is
 l_sysdate 	date;
begin
 l_sysdate := sysdate;

	insert into csm_party_sites_acc (party_site_id,
									party_id,
									 user_id,
									created_by,
									creation_date,
									last_updated_by,
									last_update_date,
									last_update_login
									)
							values (p_party_site_id,
							        p_party_id,
									p_user_id,
									fnd_global.user_id,
									l_sysdate,
									fnd_global.user_id,
									l_sysdate,
									fnd_global.login_id
									);

  exception
     when others then
	    raise;

end insert_party_sites_acc;

PROCEDURE PARTY_SITES_ACC_I (p_party_site_id IN NUMBER,
                             p_user_id IN NUMBER,
                             p_flowtype IN VARCHAR2,
                             p_error_msg     OUT NOCOPY    VARCHAR2,
                             x_return_status IN OUT NOCOPY VARCHAR2
                             )
IS
l_party_id hz_parties.party_id%type;
l_err_msg VARCHAR2(4000);
l_ret_status VARCHAR2(4000);

cursor l_party_sites_csr(p_party_site_id hz_party_sites.party_site_id%type)
is
select party_id
from hz_party_sites
where party_site_id = p_party_site_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  p_error_msg := 'Entering CSM_PARTY_SITE_EVENT_PKG.PARTY_SITES_ACC_I' || ' for party_site_id ' || to_char(p_party_site_id);

  OPEN l_party_sites_csr(p_party_site_id);
  FETCH l_party_sites_csr into l_party_id;
  CLOSE l_party_sites_csr;

 CSM_ACC_PKG.Insert_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
      ,P_ACC_TABLE_NAME         => g_acc_table_name1
      ,P_SEQ_NAME               => g_acc_sequence_name1
      ,P_PK1_NAME               => g_pk1_name1
      ,P_PK1_NUM_VALUE          => p_party_site_id
      ,P_PK2_NAME               => g_pk2_name1
      ,P_PK2_NUM_VALUE          => l_party_id
      ,P_USER_ID                => p_user_id
     );

    --get the party info
    csm_party_event_pkg.PARTY_ACC_I(p_party_id => l_party_id,
                                  p_user_id => p_user_id,
                                  p_flowtype => p_flowtype,
                                  p_error_msg => l_err_msg,
                                  x_return_status => l_ret_status);

    IF l_ret_status <> FND_API.G_RET_STS_SUCCESS THEN
        csm_util_pkg.LOG(l_err_msg, 'CSM_PARTY_SITE_EVENT_PKG.PARTY_SITES_ACC_I', FND_LOG.LEVEL_ERROR);
    END IF;

    p_error_msg := 'Leaving CSM_PARTY_SITE_EVENT_PKG.PARTY_SITES_ACC_I' || ' for party_site_id ' || to_char(p_party_site_id);
EXCEPTION
  	WHEN others THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         p_error_msg := ' FAILED PARTY_SITES_ACC_I:' || to_char(p_party_site_id);
         CSM_UTIL_PKG.LOG( p_error_msg, 'CSM_PARTY_SITE_EVENT_PKG.PARTY_SITES_ACC_I', FND_LOG.LEVEL_EXCEPTION);
         RAISE;
END PARTY_SITES_ACC_I;

PROCEDURE PARTY_SITES_ACC_D (p_party_site_id IN NUMBER,
                             p_user_id IN NUMBER,
                             p_flowtype IN VARCHAR2,
                             p_error_msg     OUT NOCOPY    VARCHAR2,
                             x_return_status IN OUT NOCOPY VARCHAR2
                             )
IS
l_party_id hz_parties.party_id%type;
l_err_msg VARCHAR2(4000);
l_ret_status VARCHAR2(4000);

cursor l_party_sites_csr(p_party_site_id hz_party_sites.party_site_id%type)
is
select party_id
from hz_party_sites
where party_site_id = p_party_site_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  p_error_msg := 'Entering CSM_PARTY_SITE_EVENT_PKG.PARTY_SITES_ACC_D' || ' for party_site_id ' || to_char(p_party_site_id);

  OPEN l_party_sites_csr(p_party_site_id);
  FETCH l_party_sites_csr into l_party_id;
  CLOSE l_party_sites_csr;

    CSM_ACC_PKG.Delete_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
      ,P_ACC_TABLE_NAME         => g_acc_table_name1
      ,P_PK1_NAME               => g_pk1_name1
      ,P_PK1_NUM_VALUE          => p_party_site_id
      ,P_PK2_NAME               => g_pk2_name1
      ,P_PK2_NUM_VALUE          => l_party_id
      ,P_USER_ID                => p_user_id
     );

    --get the party info
    csm_party_event_pkg.PARTY_ACC_D(p_party_id => l_party_id,
                                  p_user_id => p_user_id,
                                  p_flowtype => p_flowtype,
                                  p_error_msg => l_err_msg,
                                  x_return_status => l_ret_status);

    IF l_ret_status <> FND_API.G_RET_STS_SUCCESS THEN
        csm_util_pkg.LOG(l_err_msg, 'CSM_PARTY_SITE_EVENT_PKG.PARTY_SITES_ACC_D', FND_LOG.LEVEL_ERROR);
    END IF;

    p_error_msg := 'Leaving CSM_PARTY_SITE_EVENT_PKG.PARTY_SITES_ACC_D' || ' for party_site_id ' || to_char(p_party_site_id);

 EXCEPTION
  	WHEN others THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         p_error_msg := ' FAILED PARTY_SITES_ACC_D:' || to_char(p_party_site_id);
         CSM_UTIL_PKG.LOG( p_error_msg, 'CSM_PARTY_SITE_EVENT_PKG.PARTY_SITES_ACC_D', FND_LOG.LEVEL_EXCEPTION);
         RAISE;
END PARTY_SITES_ACC_D;

PROCEDURE PARTY_SITES_ACC_U (p_party_site_id IN NUMBER,
                             p_user_id IN NUMBER,
                             p_error_msg     OUT NOCOPY    VARCHAR2,
                             x_return_status IN OUT NOCOPY VARCHAR2
                             )
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_party_site_acc_csr (p_party_site_id hz_party_sites.party_site_id%TYPE)
IS
SELECT acc.access_id, acc.user_id
FROM csm_party_sites_acc acc
WHERE party_site_id = p_party_site_id;

BEGIN
   CSM_UTIL_PKG.LOG('Entering PARTY_SITES_ACC_U for party_site_id: ' || p_party_site_id,
                                   'CSM_PARTY_SITE_EVENT_PKG.PARTY_SITES_ACC_U',FND_LOG.LEVEL_PROCEDURE);

   FOR r_party_site_acc_rec IN l_party_site_acc_csr(p_party_site_id) LOOP
    -- Call Update
    CSM_ACC_PKG.Update_Acc
        ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
         ,P_ACC_TABLE_NAME         => g_acc_table_name1
         ,P_USER_ID                => r_party_site_acc_rec.user_id
         ,P_ACCESS_ID              => r_party_site_acc_rec.access_id
        );
    END LOOP;

   CSM_UTIL_PKG.LOG('Leaving PARTY_SITES_ACC_U for party_site_id: ' || p_party_site_id,
                                   'CSM_PARTY_SITE_EVENT_PKG.PARTY_SITES_ACC_U',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  PARTY_SITES_ACC_U for party_site_id:'
                       || to_char(p_party_site_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_PARTY_SITE_EVENT_PKG.PARTY_SITES_ACC_U',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END PARTY_SITES_ACC_U;

FUNCTION LOCATION_UPD_WF_EVENT_SUB(p_subscription_guid IN RAW, p_event IN OUT NOCOPY WF_EVENT_T)
RETURN VARCHAR2
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

l_location_id hz_party_sites.location_id%TYPE;

CURSOR l_party_site_csr (p_location_id hz_party_sites.location_id%TYPE)
IS
SELECT acc.access_id,
       acc.user_id
FROM hz_party_sites ps,
     csm_party_sites_acc acc
WHERE ps.location_id = p_location_id
AND acc.party_site_id = ps.party_site_id;

BEGIN
   CSM_UTIL_PKG.LOG('Entering LOCATION_UPD_EVENT_SUB',
                         'CSM_PARTY_SITE_EVENT_PKG.LOCATION_UPD_WF_EVENT_SUB',FND_LOG.LEVEL_PROCEDURE);

   IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
      RETURN 'SUCCESS';
   END IF;

   l_location_id := p_event.GetValueForParameter('LOCATION_ID');

   FOR r_party_site_rec IN l_party_site_csr(l_location_id) LOOP
        -- Call Update
        CSM_ACC_PKG.Update_Acc
             ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
              ,P_ACC_TABLE_NAME         => g_acc_table_name1
              ,P_USER_ID                => r_party_site_rec.user_id
              ,P_ACCESS_ID              => r_party_site_rec.access_id
              );
   END LOOP;

   CSM_UTIL_PKG.LOG('Leaving LOCATION_UPD_EVENT_SUB for location_id: ' || TO_CHAR(l_location_id),
                         'CSM_PARTY_SITE_EVENT_PKG.LOCATION_UPD_WF_EVENT_SUB',FND_LOG.LEVEL_PROCEDURE);

   RETURN 'SUCCESS';
EXCEPTION
 WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  LOCATION_UPD_EVENT_SUB for location_id:' || to_char(l_location_id)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_PARTY_SITE_EVENT_PKG.LOCATION_UPD_WF_EVENT_SUB',FND_LOG.LEVEL_EXCEPTION);
        RETURN 'ERROR';
END LOCATION_UPD_WF_EVENT_SUB;

FUNCTION PARTY_SITE_UPD_WF_EVENT_SUB(p_subscription_guid IN RAW, p_event IN OUT NOCOPY WF_EVENT_T)
RETURN VARCHAR2
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

l_party_site_id hz_party_sites.party_site_id%TYPE;

CURSOR l_party_site_csr (p_party_site_id hz_party_sites.party_site_id%TYPE)
IS
SELECT access_id, user_id
FROM csm_party_sites_acc
WHERE party_site_id = p_party_site_id;

BEGIN
   CSM_UTIL_PKG.LOG('Entering PARTY_SITE_UPD_WF_EVENT_SUB',
                         'CSM_PARTY_SITE_EVENT_PKG.PARTY_SITE_UPD_WF_EVENT_SUB',FND_LOG.LEVEL_PROCEDURE);

   IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
      RETURN 'SUCCESS';
   END IF;

   l_party_site_id := p_event.GetValueForParameter('PARTY_SITE_ID');

   -- get users who have access to this PARTY_SITE_ID
   FOR r_party_site_rec IN l_party_site_csr(l_party_site_id) LOOP
        -- Call Update
        CSM_ACC_PKG.Update_Acc
                ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
                 ,P_ACC_TABLE_NAME         => g_acc_table_name1
                 ,P_USER_ID                => r_party_site_rec.user_id
                 ,P_ACCESS_ID              => r_party_site_rec.access_id
                );
   END LOOP;

   CSM_UTIL_PKG.LOG('Leaving PARTY_SITE_UPD_WF_EVENT_SUB for party_site_id: ' || TO_CHAR(l_party_site_id),
                         'CSM_PARTY_SITE_EVENT_PKG.PARTY_SITE_UPD_WF_EVENT_SUB',FND_LOG.LEVEL_PROCEDURE);

   RETURN 'SUCCESS';
EXCEPTION
 WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  PARTY_SITE_UPD_WF_EVENT_SUB for party_site_id:' || to_char(l_party_site_id)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_PARTY_SITE_EVENT_PKG.PARTY_SITE_UPD_WF_EVENT_SUB',FND_LOG.LEVEL_EXCEPTION);
        RETURN 'ERROR';
END PARTY_SITE_UPD_WF_EVENT_SUB;

END CSM_PARTY_SITE_EVENT_PKG;

/
