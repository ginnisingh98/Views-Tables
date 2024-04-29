--------------------------------------------------------
--  DDL for Package Body CSM_PO_LOCATIONS_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_PO_LOCATIONS_EVENT_PKG" 
/* $Header: csmepolb.pls 120.1 2005/07/25 00:17:17 trajasek noship $*/
AS
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

g_table_name1            CONSTANT VARCHAR2(30) := 'PO_LOCATION_ASSOCIATIONS_ALL';
g_acc_table_name1        CONSTANT VARCHAR2(30) := 'CSM_PO_LOC_ASS_ALL_ACC';
g_acc_sequence_name1     CONSTANT VARCHAR2(30) := 'CSM_PO_LOC_ASS_ALL_ACC_S';
g_publication_item_name1 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                             CSM_ACC_PKG.t_publication_item_list('CSM_PO_LOC_ASS_ALL');
g_pk1_name1              CONSTANT VARCHAR2(30) := 'LOCATION_ID';
g_pk2_name1              CONSTANT VARCHAR2(30) := 'SITE_USE_ID';

g_pub_item CONSTANT varchar(30) := 'CSM_PO_LOC_ASS_ALL';

PROCEDURE CSP_SHIP_TO_ADDR_MDIRTY_I(p_location_id IN NUMBER,
                                    p_site_use_id IN NUMBER,
                                    p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering CSP_SHIP_TO_ADDR_MDIRTY_I for location_id: ' || p_location_id,
                                   'CSM_PO_LOCATIONS_EVENT_PKG.CSP_SHIP_TO_ADDR_MDIRTY_I',FND_LOG.LEVEL_PROCEDURE);

   CSM_ACC_PKG.Insert_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
      ,P_ACC_TABLE_NAME         => g_acc_table_name1
      ,P_SEQ_NAME               => g_acc_sequence_name1
      ,P_PK1_NAME               => g_pk1_name1
      ,P_PK1_NUM_VALUE          => p_location_id
      ,P_PK2_NAME               => g_pk2_name1
      ,P_PK2_NUM_VALUE          => p_site_use_id
      ,P_USER_ID                => p_user_id
     );

   CSM_UTIL_PKG.LOG('Leaving CSP_SHIP_TO_ADDR_MDIRTY_I for location_id: ' || p_location_id,
                                   'CSM_PO_LOCATIONS_EVENT_PKG.CSP_SHIP_TO_ADDR_MDIRTY_I',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  CSP_SHIP_TO_ADDR_MDIRTY_I for location_id:'
                       || to_char(p_location_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_PO_LOCATIONS_EVENT_PKG.CSP_SHIP_TO_ADDR_MDIRTY_I',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END CSP_SHIP_TO_ADDR_MDIRTY_I;

PROCEDURE CSP_SHIP_TO_ADDR_MDIRTY_U(p_location_id IN NUMBER,
                                    p_site_use_id IN NUMBER,
                                    p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_access_id NUMBER;

BEGIN
   CSM_UTIL_PKG.LOG('Entering CSP_SHIP_TO_ADDR_MDIRTY_U for location_id: ' || p_location_id,
                                   'CSM_PO_LOCATIONS_EVENT_PKG.CSP_SHIP_TO_ADDR_MDIRTY_U',FND_LOG.LEVEL_PROCEDURE);

   l_access_id := CSM_ACC_PKG.Get_Acc_Id
                            ( P_ACC_TABLE_NAME         => g_acc_table_name1
                             ,P_PK1_NAME               => g_pk1_name1
                             ,P_PK1_NUM_VALUE          => p_location_id
                             ,P_PK2_NAME               => g_pk2_name1
                             ,P_PK2_NUM_VALUE          => p_site_use_id
                             ,P_USER_ID                => p_user_id
                             );

    CSM_ACC_PKG.Update_Acc
       ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
        ,P_ACC_TABLE_NAME         => g_acc_table_name1
        ,P_ACCESS_ID              => l_access_id
        ,P_USER_ID                => p_user_id
        );

   CSM_UTIL_PKG.LOG('Leaving CSP_SHIP_TO_ADDR_MDIRTY_U for location_id: ' || p_location_id,
                                   'CSM_PO_LOCATIONS_EVENT_PKG.CSP_SHIP_TO_ADDR_MDIRTY_U',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  CSP_SHIP_TO_ADDR_MDIRTY_U for location_id:'
                       || to_char(p_location_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_PO_LOCATIONS_EVENT_PKG.CSP_SHIP_TO_ADDR_MDIRTY_U',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END CSP_SHIP_TO_ADDR_MDIRTY_U;

FUNCTION CUST_ACCT_SITE_UPD_WF_EVENT(p_subscription_guid IN RAW, p_event IN OUT NOCOPY WF_EVENT_T)
RETURN VARCHAR2
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

l_dummy             NUMBER;
l_cust_acct_site_id NUMBER;

CURSOR l_cust_acc_site_upd_csr(p_cust_acct_site_id IN NUMBER)
IS
SELECT PLA.LOCATION_ID,
       hps.party_site_id,
       csu.site_use_id,
       cas.status,
       rcr.resource_id,
       jtrs.user_id
FROM   po_location_associations_all pla,
       hz_cust_site_uses_all        csu,
       hz_cust_acct_sites_all       cas,
       csp_rs_cust_relations        rcr,
       hz_party_sites               hps,
       jtf_rs_resource_extns        jtrs
WHERE  csu.site_use_id       = pla.site_use_id
AND    csu.site_use_code     = 'SHIP_TO'
AND    csu.cust_acct_site_id = cas.cust_acct_site_id
AND    cas.cust_account_id   = rcr.customer_id
AND    cas.party_site_id     = hps.party_site_id
AND    cas.cust_acct_site_id = p_cust_acct_site_id
AND    jtrs.resource_id      = rcr.resource_id;

CURSOR l_location_access_csr(p_location_id IN NUMBER, p_site_use_id IN NUMBER, p_user_id IN NUMBER)
IS
SELECT 1
FROM csm_po_loc_ass_all_acc
WHERE location_id = p_location_id
AND site_use_id = p_site_use_id
AND user_id = p_user_id;

BEGIN
   CSM_UTIL_PKG.LOG('Entering CUST_ACCT_SITE_UPD_WF_EVENT',
                         'CSM_PO_LOCATIONS_EVENT_PKG.CUST_ACCT_SITE_UPD_WF_EVENT',FND_LOG.LEVEL_PROCEDURE);

   IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
      RETURN 'SUCCESS';
   END IF;

   l_cust_acct_site_id := p_event.GetValueForParameter('CUST_ACCT_SITE_ID');

   FOR r_cust_acc_site_upd_rec IN l_cust_acc_site_upd_csr(l_cust_acct_site_id) LOOP
      IF csm_util_pkg.is_palm_resource(r_cust_acc_site_upd_rec.resource_id) THEN
         OPEN l_location_access_csr(r_cust_acc_site_upd_rec.location_id, r_cust_acc_site_upd_rec.site_use_id, r_cust_acc_site_upd_rec.user_id);
         FETCH l_location_access_csr INTO l_dummy;
         IF l_location_access_csr%FOUND THEN
           IF r_cust_acc_site_upd_rec.status <> 'A' THEN

              csm_party_site_event_pkg.party_sites_acc_d(p_party_site_id => r_cust_acc_site_upd_rec.party_site_id,
                                                         p_user_id => r_cust_acc_site_upd_rec.user_id,
                                                         p_flowtype => NULL,
                                                         p_error_msg => l_error_msg,
                                                         x_return_status => l_return_status);

              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   csm_util_pkg.LOG(l_error_msg, 'CSM_PO_LOCATIONS_EVENT_PKG.SPAWN_CUST_ACCT_SITE_DEL', FND_LOG.LEVEL_ERROR);
              END IF;

            -- process delete of csm_po_loc_ass_all
            CSM_ACC_PKG.Delete_Acc
             ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
              ,P_ACC_TABLE_NAME         => g_acc_table_name1
              ,P_PK1_NAME               => g_pk1_name1
              ,P_PK1_NUM_VALUE          => r_cust_acc_site_upd_rec.location_id
              ,P_PK2_NAME               => g_pk2_name1
              ,P_PK2_NUM_VALUE          => r_cust_acc_site_upd_rec.site_use_id
              ,P_USER_ID                => r_cust_acc_site_upd_rec.user_id
             );

           END IF;
         ELSE -- not found
           IF r_cust_acc_site_upd_rec.status = 'A' THEN

             --insert into csm_party_sites_acc
             csm_party_site_event_pkg.party_sites_acc_i
                  (p_party_site_id=>r_cust_acc_site_upd_rec.party_site_id,
                   p_user_id=>r_cust_acc_site_upd_rec.user_id,
                   p_flowtype=>NULL,
                   p_error_msg=>l_error_msg,
                   x_return_status=>l_return_status);

             -- insert into csm_po_loc_ass_all_acc
             csm_po_locations_event_pkg.csp_ship_to_addr_mdirty_i
                   (p_location_id=>r_cust_acc_site_upd_rec.location_id,
                    p_site_use_id=>r_cust_acc_site_upd_rec.site_use_id,
                    p_user_id=>r_cust_acc_site_upd_rec.user_id);

           END IF;
         END IF; -- if l_location_access_csr found
         CLOSE l_location_access_csr;
      END IF; -- end of palm resource
   END LOOP;

   CSM_UTIL_PKG.LOG('Leaving CUST_ACCT_SITE_UPD_WF_EVENT for cust_acct_site_id: ' || TO_CHAR(l_cust_acct_site_id),
                         'CSM_PO_LOCATIONS_EVENT_PKG.CUST_ACCT_SITE_UPD_WF_EVENT',FND_LOG.LEVEL_PROCEDURE);

   RETURN 'SUCCESS';

EXCEPTION
 WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  CUST_ACCT_SITE_UPD_WF_EVENT for party_id:' || to_char(l_cust_acct_site_id)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_PO_LOCATIONS_EVENT_PKG.CUST_ACCT_SITE_UPD_WF_EVENT',FND_LOG.LEVEL_EXCEPTION);
        RETURN 'ERROR';
END CUST_ACCT_SITE_UPD_WF_EVENT;

END CSM_PO_LOCATIONS_EVENT_PKG;

/
