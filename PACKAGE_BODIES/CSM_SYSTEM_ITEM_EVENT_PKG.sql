--------------------------------------------------------
--  DDL for Package Body CSM_SYSTEM_ITEM_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_SYSTEM_ITEM_EVENT_PKG" AS
/* $Header: csmemsib.pls 120.10.12010000.3 2009/08/06 12:23:53 saradhak ship $ */

-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below

g_table_name1            CONSTANT VARCHAR2(30) := 'MTL_SYSTEM_ITEMS_B';
g_acc_table_name1        CONSTANT VARCHAR2(30) := 'CSM_SYSTEM_ITEMS_ACC';
g_acc_sequence_name1     CONSTANT VARCHAR2(30) := 'CSM_SYSTEM_ITEMS_ACC_S';
g_publication_item_name1 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                             CSM_ACC_PKG.t_publication_item_list('CSF_M_SYSTEM_ITEMS');
g_pk1_name1              CONSTANT VARCHAR2(30) := 'INVENTORY_ITEM_ID';
g_pk2_name1              CONSTANT VARCHAR2(30) := 'ORGANIZATION_ID';
g_pub_item               CONSTANT VARCHAR2(30) := 'CSF_M_SYSTEM_ITEMS';

g_table_name2            CONSTANT VARCHAR2(30) := 'CSI_ITEM_INSTANCES';
g_acc_table_name2        CONSTANT VARCHAR2(30) := 'CSM_ITEM_INSTANCES_ACC';
g_acc_sequence_name2     CONSTANT VARCHAR2(30) := 'CSM_ITEM_INSTANCES_ACC_S';
g_publication_item_name2 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                             CSM_ACC_PKG.t_publication_item_list('CSF_M_ITEM_INSTANCES');
g_pk1_name2              CONSTANT VARCHAR2(30) := 'INSTANCE_ID';
g_pub_item2              CONSTANT VARCHAR2(30) := 'CSF_M_ITEM_INSTANCES';

-- below procedure is called from csm_mtl_system_items where there is an org change
PROCEDURE delete_system_items(p_user_id IN NUMBER,
                              p_organization_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_stmt  VARCHAR2(4000);
l_markdirty BOOLEAN;
l_run_date DATE;
l_tab_access_id   ASG_DOWNLOAD.ACCESS_LIST;
l_tab_user_id ASG_DOWNLOAD.USER_LIST;

BEGIN
 CSM_UTIL_PKG.LOG('Entering DELETE_SYSTEM_ITEMS ',
                         'CSM_SYSTEM_ITEM_EVENT_PKG.DELETE_SYSTEM_ITEMS',FND_LOG.LEVEL_PROCEDURE);

 l_run_date := SYSDATE;

 l_tab_access_id.DELETE;

    l_stmt := 'UPDATE csm_system_items_acc acc';
    l_stmt :=   l_stmt || ' SET COUNTER = COUNTER - 1';
    l_stmt :=   l_stmt || '  ,   LAST_UPDATE_DATE = SYSDATE';
    l_stmt :=   l_stmt || '  ,   last_updated_by = nvl(fnd_global.user_id, 1)';
    l_stmt :=   l_stmt || '  WHERE USER_ID = :1';
    l_stmt :=   l_stmt || '  AND organization_id = :2';

    EXECUTE IMMEDIATE l_stmt USING p_user_id, p_organization_id;

    -- bulk collect all items eligible for delete
    l_tab_access_id.DELETE;
    l_tab_user_id.DELETE;

    SELECT access_id, user_id
    BULK COLLECT INTO l_tab_access_id, l_tab_user_id
    FROM csm_system_items_acc acc
    WHERE acc.counter = 0;

    IF l_tab_access_id.COUNT > 0 THEN
        -- do bulk makedirty
         l_markdirty := asg_download.mark_dirty(
                P_PUB_ITEM         => g_pub_item
              , p_accessList       => l_tab_access_id
              , p_userid_list      => l_tab_user_id
              , p_dml_type         => 'D'
              , P_TIMESTAMP        => l_run_date
              );

          FORALL i IN 1..l_tab_access_id.COUNT
                 DELETE FROM csm_system_items_acc WHERE access_id = l_tab_access_id(i);
    END IF;

 CSM_UTIL_PKG.LOG('Leaving DELETE_SYSTEM_ITEMS ',
                         'CSM_SYSTEM_ITEM_EVENT_PKG.DELETE_SYSTEM_ITEMS',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  WHEN others THEN
     l_sqlerrno := TO_CHAR(SQLCODE);
     l_sqlerrmsg := SUBSTR(SQLERRM, 1,2000);
     CSM_UTIL_PKG.LOG('Exception in delete_system_items: ' || l_sqlerrno || ':' || l_sqlerrmsg,
                         'csm_system_item_event_pkg.delete_system_items',FND_LOG.LEVEL_EXCEPTION);
     RAISE;
END delete_system_items;

/*
PROCEDURE PURGE_SYSTEM_ITEMS( p_itemtype in varchar2,
                              p_itemkey in varchar2,
		                      p_actid	in number,
		                      p_funcmode in varchar2,
                              x_result	OUT nocopy	VARCHAR2 )
IS
g_pub_item VARCHAR2(30);
l_current_run_date DATE;
l_sqlerrno varchar2(20);
l_sqlerrmsg varchar2(2000);

CURSOR l_old_system_items_csr(p_old_organization_id IN number, p_user_id IN number)
IS
--SELECT /*+ index (acc CSM_SYSTEM_ITEMS_ACC_U2) acc.user_id,
       acc.access_id
FROM  csm_system_items_acc acc
WHERE acc.user_id = p_user_id
AND   acc.organization_id = p_old_organization_id;

l_dummy BOOLEAN;
l_user_id_lst    asg_download.user_list;
l_acc_id_lst     asg_download.access_list;
l_old_organization_id mtl_system_items.organization_id%TYPE;
l_organization_id mtl_system_items.organization_id%TYPE;
l_userid		NUMBER;

BEGIN
 CSM_UTIL_PKG.LOG('Entering CSM_SYSTEM_ITEM_EVENT_PKG.PURGE_SYSTEM_ITEMS ',
                         'CSM_SYSTEM_ITEM_EVENT_PKG.PURGE_SYSTEM_ITEMS',FND_LOG.LEVEL_PROCEDURE);

 g_pub_item := 'CSF_M_SYSTEM_ITEMS';
 l_current_run_date := SYSDATE;

  IF (p_funcmode = 'RUN') THEN

   l_userid := wf_engine.GetActivityAttrNumber( p_itemtype,
                              p_itemkey,
                              p_actid,
                      						  'USER_ID'
                              );

   l_old_organization_id := wf_engine.GetItemAttrText( p_itemtype,
																														p_itemkey,
																													'OLD_PROFILE_OPTION_VALUE');

   l_organization_id := wf_engine.GetItemAttrText( p_itemtype,
    												p_itemkey,
	    											'PROFILE_OPTION_VALUE');

   IF l_old_organization_id = l_organization_id THEN
      x_result := 'Org is same - no system items purged';
   ELSE

     -- process deletes
     OPEN l_old_system_items_csr(l_old_organization_id, l_userid);
     FETCH l_old_system_items_csr BULK COLLECT INTO l_user_id_lst, l_acc_id_lst;
     CLOSE l_old_system_items_csr;

     -- post deletes to olite
     IF l_acc_id_lst.COUNT > 0 THEN
        -- do bulk makedirty
        l_dummy := asg_download.mark_dirty(
                  P_PUB_ITEM         => g_pub_item
                , p_accessList       => l_acc_id_lst
                , p_userid_list      => l_user_id_lst
                , p_dml_type         => 'D'
                , P_TIMESTAMP        => l_current_run_date
               );

         -- do a bulk delete
         FORALL i IN l_acc_id_lst.FIRST..l_acc_id_lst.LAST
                DELETE CSM_SYSTEM_ITEMS_ACC WHERE ACCESS_ID = l_acc_id_lst(i);
     END IF;

     x_result := 'System Item purge complete';
   END IF;

  END IF;

  CSM_UTIL_PKG.LOG('Leaving CSM_SYSTEM_ITEM_EVENT_PKG.PURGE_SYSTEM_ITEMS ',
                         'CSM_SYSTEM_ITEM_EVENT_PKG.PURGE_SYSTEM_ITEMS',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
    WHEN OTHERS THEN
--logm('ErrorLog' || substr(SQLERRM, 1, 250));
   	 x_result := ' FAILED PURGE_SYSTEM_ITEMS old_OrganizationId: ' || to_char(l_old_organization_id);
     CSM_UTIL_PKG.LOG(x_result,'CSM_SYSTEM_ITEM_EVENT_PKG.PURGE_SYSTEM_ITEMS',FND_LOG.LEVEL_EXCEPTION);
     wf_core.context('CSM_SYSTEM_ITEM_EVENT_PKG', 'PURGE_SYSTEM_ITEMS', p_itemtype, p_itemkey, to_char(p_actid),
                        'Organization ID: ' || to_char(l_old_organization_id), p_funcmode);
    	RAISE;

END PURGE_SYSTEM_ITEMS;

PROCEDURE GET_NEW_SYSTEM_ITEMS( p_itemtype in varchar2,
    	    	                  	p_itemkey in varchar2,
		                           p_actid	in number,
		                           p_funcmode in varchar2,
                             x_result	OUT nocopy	VARCHAR2 )
IS
g_pub_item VARCHAR2(30);
l_current_run_date DATE;
l_sqlerrno varchar2(20);
l_sqlerrmsg varchar2(2000);

CURSOR l_systemitems_ins_csr(p_new_organization_id IN number, p_user_id IN number)
IS
--SELECT /*+ INDEX (msi MTL_SYSTEM_ITEMS_B_U1)  CSM_SYSTEM_ITEMS_ACC_S.NEXTVAL,
       au.user_id,
       msi.inventory_item_id,
       msi.organization_id
FROM asg_user au,
     asg_user_pub_resps aupr,
     mtl_system_items_b msi,
     CS_BILLING_TYPE_CATEGORIES cbtc
WHERE au.user_id = p_user_id
AND  au.user_name = aupr.user_name
AND  aupr.pub_name = 'SERVICEP'
AND  msi.organization_id = p_new_organization_id
AND  msi.enabled_flag = 'Y'
AND  SYSDATE BETWEEN nvl(msi.start_date_active, SYSDATE) AND nvl(msi.end_date_active, SYSDATE)
AND  msi.material_billable_flag = cbtc.billing_type
AND  cbtc.billing_category IN ('L', 'E')
AND  SYSDATE BETWEEN nvl(cbtc.start_date_active, SYSDATE) AND nvl(cbtc.end_date_active, SYSDATE)
AND NOT EXISTS
(SELECT 1
 FROM csm_system_items_acc acc
 WHERE acc.user_id = au.user_id
 AND acc.inventory_item_id = msi.inventory_item_id
 AND acc.organization_id = msi.organization_id
 );

TYPE inv_idTab     IS TABLE OF csm_system_items_acc.inventory_item_id%TYPE INDEX BY BINARY_INTEGER;
TYPE org_idTab     IS TABLE OF csm_system_items_acc.organization_id%TYPE INDEX BY BINARY_INTEGER;

l_inv_id     inv_idTab;
l_org_id     org_idTab;
l_user_id_lst    asg_download.user_list;
l_acc_id_lst     asg_download.access_list;

l_dummy BOOLEAN;
l_old_organization_id mtl_system_items.organization_id%TYPE;
l_organization_id mtl_system_items.organization_id%TYPE;
l_user_id		NUMBER;

BEGIN
 CSM_UTIL_PKG.LOG('Entering CSM_SYSTEM_ITEM_EVENT_PKG.GET_NEW_SYSTEM_ITEMS ',
                         'CSM_SYSTEM_ITEM_EVENT_PKG.GET_NEW_SYSTEM_ITEMS',FND_LOG.LEVEL_PROCEDURE);

 g_pub_item := 'CSF_M_SYSTEM_ITEMS';
 l_current_run_date := SYSDATE;

  IF (p_funcmode = 'RUN') THEN
   l_user_id := wf_engine.GetActivityAttrNumber( p_itemtype,
                              p_itemkey,
                              p_actid,
                      						  'USER_ID'
                              );

   l_old_organization_id := wf_engine.GetItemAttrText( p_itemtype,
																														p_itemkey,
																													'OLD_PROFILE_OPTION_VALUE');

   l_organization_id := wf_engine.GetItemAttrText( p_itemtype,
																														p_itemkey,
																													'PROFILE_OPTION_VALUE');


   IF l_old_organization_id = l_organization_id THEN
      x_result := 'Org is same - no system items purged';
   ELSE

     IF l_acc_id_lst.COUNT > 0 THEN
        l_acc_id_lst.DELETE;
     END IF;
     IF l_user_id_lst.COUNT > 0 THEN
        l_user_id_lst.DELETE;
     END IF;
     IF l_inv_id.COUNT > 0 THEN
        l_inv_id.DELETE;
     END IF;
     IF l_org_id.COUNT > 0 THEN
        l_org_id.DELETE;
     END IF;

     -- process inserts
     OPEN l_systemitems_ins_csr (l_organization_id, l_user_id);
     FETCH l_systemitems_ins_csr BULK COLLECT INTO l_acc_id_lst, l_user_id_lst, l_inv_id, l_org_id;
     CLOSE l_systemitems_ins_csr;

     IF l_acc_id_lst.COUNT > 0 THEN
       FORALL i IN l_acc_id_lst.FIRST..l_acc_id_lst.LAST
          INSERT INTO CSM_SYSTEM_ITEMS_ACC (ACCESS_ID, USER_ID, INVENTORY_ITEM_ID,ORGANIZATION_ID,
          COUNTER,CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN)
          VALUES (l_acc_id_lst(i), l_user_id_lst(i), l_inv_id(i), l_org_id(i), 1, 1, l_current_run_date,1,l_current_run_date,1);

       -- do bulk makedirty
       l_dummy := asg_download.mark_dirty(
            P_PUB_ITEM         => g_pub_item
          , p_accessList       => l_acc_id_lst
          , p_userid_list      => l_user_id_lst
          , p_dml_type         => 'I'
          , P_TIMESTAMP        => l_current_run_date
          );
      END IF;

      x_result := 'Get New System Items complete';
   END IF;

  END IF;

 CSM_UTIL_PKG.LOG('Leaving CSM_SYSTEM_ITEM_EVENT_PKG.GET_NEW_SYSTEM_ITEMS ',
                         'CSM_SYSTEM_ITEM_EVENT_PKG.GET_NEW_SYSTEM_ITEMS',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
    WHEN OTHERS THEN
   	 x_result := ' FAILED GET_NEW_SYSTEM_ITEMS OrganizationId: ' || to_char(l_organization_id);
     CSM_UTIL_PKG.LOG(x_result, 'CSM_SYSTEM_ITEM_EVENT_PKG.GET_NEW_SYSTEM_ITEMS',FND_LOG.LEVEL_EXCEPTION);
     wf_core.context('CSM_SYSTEM_ITEM_EVENT_PKG', 'GET_NEW_SYSTEM_ITEMS', p_itemtype, p_itemkey, to_char(p_actid),
                        'Organization ID: ' || to_char(l_organization_id), p_funcmode);
    	RAISE;

END GET_NEW_SYSTEM_ITEMS;
*/
PROCEDURE Refresh_Acc (p_status OUT NOCOPY VARCHAR2,
                       p_message OUT NOCOPY VARCHAR2) AS
PRAGMA AUTONOMOUS_TRANSACTION;
l_last_run_date jtm_con_request_data.last_run_date%TYPE;
l_sqlerrno varchar2(20);
l_sqlerrmsg varchar2(2000);
l_current_run_date DATE;
l_max_last_update_date_b DATE;
l_max_last_update_date_tl DATE;
g_pub_item_name1 VARCHAR2(30) := 'CSF_M_SYSTEM_ITEMS';

TYPE inv_idTab     IS TABLE OF csm_system_items_acc.inventory_item_id%TYPE INDEX BY BINARY_INTEGER;
TYPE org_idTab     IS TABLE OF csm_system_items_acc.organization_id%TYPE INDEX BY BINARY_INTEGER;

l_inv_id     inv_idTab;
l_org_id     org_idTab;
l_user_id    asg_download.user_list;
l_acc_id     asg_download.access_list;

l_dummy BOOLEAN;

CURSOR l_last_run_date_csr
IS
SELECT nvl(last_run_date, (sysdate - 365*50))
FROM jtm_con_request_data
WHERE package_name = 'CSM_SYSTEM_ITEM_EVENT_PKG'
AND procedure_name = 'REFRESH_ACC';

CURSOR c_max_last_upd_date_b
IS
SELECT MAX(last_update_date) FROM mtl_system_items_b;

CURSOR c_max_last_upd_date_tl
IS
SELECT MAX(last_update_date) FROM mtl_system_items_tl;

-- insert
CURSOR l_systemitems_ins_csr
IS
SELECT /*+ INDEX (msi MTL_SYSTEM_ITEMS_B_U1) */ CSM_SYSTEM_ITEMS_ACC_S.NEXTVAL,
       au.user_id,
       msi.inventory_item_id,
       msi.organization_id
FROM asg_user au,
     asg_user_pub_resps aupr,
     csm_user_inventory_org user_org,
     mtl_system_items_b msi,
     CS_BILLING_TYPE_CATEGORIES cbtc
WHERE au.user_name = aupr.user_name
AND aupr.pub_name = 'SERVICEP'
AND user_org.user_id = au.user_id
AND  au.user_id      = au.owner_id
AND  msi.organization_id = user_org.organization_id
AND  msi.enabled_flag = 'Y'
AND  SYSDATE BETWEEN nvl(msi.start_date_active, SYSDATE) AND nvl(msi.end_date_active, SYSDATE)
AND  msi.material_billable_flag = cbtc.billing_type
AND  cbtc.billing_category IN ('L', 'E')
AND  SYSDATE BETWEEN nvl(cbtc.start_date_active, SYSDATE) AND nvl(cbtc.end_date_active, SYSDATE)
AND NOT EXISTS
(SELECT 1
 FROM csm_system_items_acc acc
 WHERE acc.user_id = au.user_id
 AND acc.inventory_item_id = msi.inventory_item_id
 AND acc.organization_id = msi.organization_id
 );

-- update
CURSOR l_systemitems_upd_b_csr(p_last_run_date DATE)
IS
SELECT /*+ INDEX (acc CSM_SYSTEM_ITEMS_ACC_U1) (msi MTL_SYSTEM_ITEMS_B_U1) */ acc.access_id,
       acc.user_id,
       msi.inventory_item_id,
       msi.organization_id
FROM  csm_system_items_acc acc,
      mtl_system_items_b msi
WHERE acc.inventory_item_id = msi.inventory_item_id
AND   acc.organization_id = msi.organization_id
AND   msi.last_update_date >= p_last_run_date
;

CURSOR l_systemitems_upd_tl_csr(p_last_run_date DATE)
IS
SELECT /*+ INDEX (acc CSM_SYSTEM_ITEMS_ACC_U1) (msi_tl MTL_SYSTEM_ITEMS_TL_U1) */ acc.access_id,
       acc.user_id,
       msi_tl.inventory_item_id,
       msi_tl.organization_id
FROM csm_system_items_acc acc,
     asg_user au,
     mtl_system_items_tl msi_tl
WHERE acc.user_id = au.user_id
AND   acc.inventory_item_id = msi_tl.inventory_item_id
AND   acc.organization_id = msi_tl.organization_id
AND   au.LANGUAGE = msi_tl.LANGUAGE
AND   msi_tl.last_update_date >= p_last_run_date;

-- delete
CURSOR l_systemitems_del_csr
IS
SELECT /*+ index (acc csm_system_items_acc_u1)*/ acc.access_id,
       acc.user_id,
       acc.inventory_item_id,
       acc.organization_id
FROM csm_system_items_acc acc
WHERE NOT EXISTS
(SELECT 1
 FROM mtl_system_items_b msi,
      CS_BILLING_TYPE_CATEGORIES cbtc
 WHERE msi.inventory_item_id = acc.inventory_item_id
 AND msi.organization_id = acc.organization_id
 AND msi.material_billable_flag = cbtc.billing_type
 AND cbtc.billing_category IN ('L', 'E')
 AND  SYSDATE BETWEEN nvl(cbtc.start_date_active, SYSDATE) AND nvl(cbtc.end_date_active, SYSDATE)
 AND  msi.enabled_flag = 'Y'
 AND  SYSDATE BETWEEN nvl(msi.start_date_active, SYSDATE) AND nvl(msi.end_date_active, SYSDATE)
 );

BEGIN
 -- set the run date
 l_current_run_date := SYSDATE;

 -- get last conc program update date
 OPEN l_last_run_date_csr;
 FETCH l_last_run_date_csr INTO l_last_run_date;
 CLOSE l_last_run_date_csr;

 -- process deletes
 OPEN l_systemitems_del_csr;
 LOOP
 -- initialise the tables
 IF l_acc_id.COUNT > 0 THEN
    l_acc_id.DELETE;
 END IF;
 IF l_user_id.COUNT > 0 THEN
    l_user_id.DELETE;
 END IF;
 IF l_inv_id.COUNT > 0 THEN
    l_inv_id.DELETE;
 END IF;
 IF l_org_id.COUNT > 0 THEN
    l_org_id.DELETE;
 END IF;

 FETCH l_systemitems_del_csr BULK COLLECT INTO l_acc_id, l_user_id, l_inv_id, l_org_id LIMIT 100;
 EXIT WHEN l_acc_id.COUNT = 0;
 -- post deletes to olite
 IF l_acc_id.COUNT > 0 THEN
    -- do bulk makedirty
    l_dummy := asg_download.mark_dirty(
            P_PUB_ITEM         => g_pub_item_name1
          , p_accessList       => l_acc_id
          , p_userid_list      => l_user_id
          , p_dml_type         => 'D'
          , P_TIMESTAMP        => l_current_run_date
          );

    -- do a bulk delete
    FORALL i IN l_acc_id.FIRST..l_acc_id.LAST
        DELETE CSM_SYSTEM_ITEMS_ACC WHERE ACCESS_ID = l_acc_id(i);
 END IF;
 END LOOP;
 CLOSE l_systemitems_del_csr;


 -- process updates

 -- initialise the tables
 IF l_acc_id.COUNT > 0 THEN
    l_acc_id.DELETE;
 END IF;
 IF l_user_id.COUNT > 0 THEN
    l_user_id.DELETE;
 END IF;
 IF l_inv_id.COUNT > 0 THEN
    l_inv_id.DELETE;
 END IF;
 IF l_org_id.COUNT > 0 THEN
    l_org_id.DELETE;
 END IF;

 /* This portion of code assumes indexes on last_update_date on MTL_SYSTEM_ITEMS_B */
 /* , MTL_SYSTEM_ITEMS_TL which were custom created */

 -- get max last_upd_date from msi
 OPEN c_max_last_upd_date_b;
 FETCH c_max_last_upd_date_b INTO l_max_last_update_date_b;
 CLOSE c_max_last_upd_date_b;

  IF( l_max_last_update_date_b < l_last_run_date) THEN
     -- get max last_upd_date from msi_tl
     OPEN c_max_last_upd_date_tl;
     FETCH c_max_last_upd_date_tl INTO l_max_last_update_date_tl;
     CLOSE c_max_last_upd_date_tl;

     IF l_max_last_update_date_tl < l_last_run_date THEN
         -- no updates
         p_status := 'FINE';
         p_message :=  'CSM_SYSTEM_ITEM_EVENT_PKG.REFRESH_SYSTEM_ITEMS Executed successfully - No updates';
         csm_util_pkg.log('No updates for csm_system_items_event_new_pkg', 'CSM_SYSTEM_ITEM_EVENT_PKG.REFRESH_SYSTEM_ITEMS ');

         -- set the program update date in jtm_con_request_data to sysdate
         UPDATE jtm_con_request_data
         SET  last_run_date = l_current_run_date
         WHERE package_name = 'CSM_SYSTEM_ITEM_EVENT_PKG'
         AND procedure_name = 'REFRESH_ACC';

         COMMIT;

         RETURN;
     ELSE
         -- open tl cursor
         OPEN l_systemitems_upd_tl_csr(l_last_run_date);
         FETCH l_systemitems_upd_tl_csr BULK COLLECT INTO l_acc_id, l_user_id, l_inv_id, l_org_id;
         CLOSE l_systemitems_upd_tl_csr;
     END IF;

  ELSE
     l_max_last_update_date_tl := l_max_last_update_date_b;
     -- open the main b cursor
     OPEN l_systemitems_upd_b_csr(l_last_run_date);
     FETCH l_systemitems_upd_b_csr BULK COLLECT INTO l_acc_id, l_user_id, l_inv_id, l_org_id;
     CLOSE l_systemitems_upd_b_csr;
  END IF;

  -- post updates to olite
  IF l_acc_id.COUNT > 0 THEN
      -- do bulk makedirty
      l_dummy := asg_download.mark_dirty(
            P_PUB_ITEM         => g_pub_item_name1
          , p_accessList       => l_acc_id
          , p_userid_list      => l_user_id
          , p_dml_type         => 'U'
          , P_TIMESTAMP        => l_current_run_date
          );
  END IF;

 -- process inserts
 OPEN l_systemitems_ins_csr;
 LOOP
 -- initialise the tables
 IF l_acc_id.COUNT > 0 THEN
    l_acc_id.DELETE;
 END IF;
 IF l_user_id.COUNT > 0 THEN
    l_user_id.DELETE;
 END IF;
 IF l_inv_id.COUNT > 0 THEN
    l_inv_id.DELETE;
 END IF;
 IF l_org_id.COUNT > 0 THEN
    l_org_id.DELETE;
 END IF;

 FETCH l_systemitems_ins_csr BULK COLLECT INTO l_acc_id, l_user_id, l_inv_id, l_org_id LIMIT 500;
 EXIT WHEN l_acc_id.COUNT = 0;

 IF l_acc_id.COUNT > 0 THEN
     FORALL i IN l_acc_id.FIRST..l_acc_id.LAST
          INSERT INTO CSM_SYSTEM_ITEMS_ACC (ACCESS_ID, USER_ID, INVENTORY_ITEM_ID,ORGANIZATION_ID,
          COUNTER,CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN)
          VALUES (l_acc_id(i), l_user_id(i), l_inv_id(i), l_org_id(i), 1, 1, l_current_run_date,1,l_current_run_date,1);

     -- do bulk makedirty
     l_dummy := asg_download.mark_dirty(
            P_PUB_ITEM         => g_pub_item_name1
          , p_accessList       => l_acc_id
          , p_userid_list      => l_user_id
          , p_dml_type         => 'I'
          , P_TIMESTAMP        => l_current_run_date
          );

  END IF;
 END LOOP;
 CLOSE l_systemitems_ins_csr;

   -- set the program update date in jtm_con_request_data to sysdate
  UPDATE jtm_con_request_data
  SET  last_run_date = l_current_run_date
  WHERE package_name = 'CSM_SYSTEM_ITEM_EVENT_PKG'
    AND procedure_name = 'REFRESH_ACC';

 COMMIT;

 p_status := 'FINE';
 p_message :=  'CSM_SYSTEM_ITEM_EVENT_PKG.REFRESH_SYSTEM_ITEMS Executed successfully';

 EXCEPTION
  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     p_status := 'ERROR';
     p_message := 'Error in CSM_SYSTEM_ITEM_EVENT_PKG.REFRESH_SYSTEM_ITEMS: ' || l_sqlerrno || ':' || l_sqlerrmsg;
     ROLLBACK;
     csm_util_pkg.log('CSM_SYSTEM_ITEM_EVENT_PKG.REFRESH_SYSTEM_ITEMS ERROR : ' || l_sqlerrno || ':' || l_sqlerrmsg);
END Refresh_Acc;

/* concurrent program that refreshes inventory */
PROCEDURE Refresh_mtl_onhand_quantity(p_status OUT NOCOPY VARCHAR2,
                                      p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
g_pub_item VARCHAR2(30) := 'CSF_M_INVENTORY';
l_last_run_date jtm_con_request_data.last_run_date%TYPE;
l_sqlerrno varchar2(20);
l_sqlerrmsg varchar2(2000);

CURSOR l_onhand_acc_seq IS
SELECT csm_mtl_onhand_qty_acc_s.NEXTVAL
FROM dual;

-- post deletes to onhand
CURSOR l_onhand_delete_csr IS
    SELECT /*+ index(ohqacc CSM_MTL_ONHAND_QTY_ACC_U2) */ ohqacc.user_id
    ,      ohqacc.inventory_item_id
    ,      ohqacc.organization_id
    ,      ohqacc.ACCESS_ID
    FROM  csm_mtl_onhand_qty_acc ohqacc
    WHERE NOT EXISTS
    (
      SELECT 1
      FROM mtl_onhand_quantities_detail ohqmv
      WHERE ohqacc.inventory_item_id = ohqmv.inventory_item_id
      AND ohqacc.organization_id = ohqmv.organization_id
      AND ohqacc.subinventory_code = ohqmv.subinventory_code
      AND ((ohqacc.locator_id IS NULL AND ohqmv.locator_id IS NULL) OR (ohqacc.locator_id = ohqmv.locator_id))
      AND ((ohqacc.lot_number IS NULL AND ohqmv.lot_number IS NULL) OR (ohqacc.lot_number = ohqmv.lot_number))
      AND ((ohqacc.revision IS NULL AND ohqmv.revision IS NULL) OR (ohqacc.revision = ohqmv.revision))
	)
	OR NOT EXISTS
	(
	  SELECT 1
      FROM csm_inv_loc_ass_acc acc,
           csp_inv_loc_assignments cila
      WHERE acc.user_id = ohqacc.user_id
      AND acc.csp_inv_loc_assignment_id = cila.csp_inv_loc_assignment_id
      AND cila.organization_id = ohqacc.organization_id
      AND cila.subinventory_code = ohqacc.subinventory_code
    );

-- get the updates to onhands for all mobile users
CURSOR l_onhand_update_csr IS
    SELECT /*+ index(ohqacc CSM_MTL_ONHAND_QTY_ACC_U2) index(ohqmv MTL_ONHAND_QUANTITIES_N4)*/ DISTINCT ohqacc.user_id
    ,      ohqmv.INVENTORY_ITEM_ID
    ,      ohqmv.ORGANIZATION_ID
    ,      ohqmv.SUBINVENTORY_CODE
    ,      ohqmv.LOCATOR_ID
    ,      ohqmv.REVISION
    ,      ohqmv.LOT_NUMBER
    ,      ohqacc.quantity
    ,      SUM(ohqmv.transaction_quantity) tot_qty
    FROM  csm_mtl_onhand_qty_acc ohqacc,
          mtl_onhand_quantities_detail ohqmv
    WHERE ohqacc.inventory_item_id = ohqmv.inventory_item_id
      AND ohqacc.organization_id = ohqmv.organization_id
      AND ohqacc.subinventory_code = ohqmv.subinventory_code
      AND ((ohqacc.locator_id IS NULL AND ohqmv.locator_id IS NULL) OR (ohqacc.locator_id = ohqmv.locator_id))
      AND ((ohqacc.lot_number IS NULL AND ohqmv.lot_number IS NULL) OR (ohqacc.lot_number = ohqmv.lot_number))
      AND ((ohqacc.revision IS NULL AND ohqmv.revision IS NULL) OR (ohqacc.revision = ohqmv.revision))
      HAVING SUM(ohqmv.transaction_quantity) <> NVL(ohqacc.quantity,0)
      GROUP BY ohqacc.user_id, ohqmv.inventory_item_id, ohqmv.organization_id, ohqmv.subinventory_code,
               ohqmv.locator_id, ohqmv.revision, ohqmv.lot_number, ohqacc.quantity
    ;

-- get the onhand details for mobile subinventories that are not present
-- for some or all the mobile users
CURSOR l_onhand_insert_csr IS
    SELECT distinct /*+ index (msi MTL_SYSTEM_ITEMS_B_U1) index (ohqmv MTL_ONHAND_QUANTITIES_N5) */ au.user_id
    ,      ohqmv.INVENTORY_ITEM_ID
    ,      ohqmv.ORGANIZATION_ID
    ,      ohqmv.SUBINVENTORY_CODE
    ,      ohqmv.LOCATOR_ID
    ,      ohqmv.REVISION
    ,      ohqmv.LOT_NUMBER
    ,      (SELECT SUM (ohqmv2.transaction_quantity)
           FROM mtl_onhand_quantities_detail ohqmv2 WHERE
    	  ohqmv.ORGANIZATION_ID=ohqmv2.ORGANIZATION_ID AND
		  ohqmv.SUBINVENTORY_CODE=ohqmv2.SUBINVENTORY_CODE AND
		  ohqmv.INVENTORY_ITEM_ID=ohqmv2.INVENTORY_ITEM_ID AND
		  nvl(ohqmv.LOCATOR_ID,-9999)=nvl(ohqmv2.LOCATOR_ID,-9999) AND
		  nvl(ohqmv.REVISION,-9999)=nvl(ohqmv2.REVISION,-9999) AND
		  nvl(ohqmv.LOT_NUMBER,-9999)=nvl(ohqmv2.LOT_NUMBER,-9999))
    FROM asg_user au,
         asg_user_pub_resps aupr,
         mtl_onhand_quantities_detail ohqmv,
         mtl_system_items_b      msi,
         CS_BILLING_TYPE_CATEGORIES cbtc
    WHERE au.user_name = aupr.user_name
    AND aupr.pub_name = 'SERVICEP'
    AND au.user_id    = au.owner_id
    AND msi.INVENTORY_ITEM_ID = ohqmv.INVENTORY_ITEM_ID
    AND msi.ORGANIZATION_ID = ohqmv.ORGANIZATION_ID
    AND msi.mtl_transactions_enabled_flag = 'Y'
    AND msi.material_billable_flag = cbtc.billing_type
    AND cbtc.billing_category = 'M'
    AND SYSDATE BETWEEN nvl(cbtc.start_date_active, SYSDATE) AND nvl(cbtc.end_date_active, SYSDATE)
    AND EXISTS
    ( SELECT 1
      FROM csm_inv_loc_ass_acc ilaacc1,
           csp_inv_loc_assignments ila1
--           csp_sec_inventories csi   --R12Not requirec as we are now downloading both the items in good and bad subinv
      WHERE ilaacc1.user_id = au.user_id
      AND ilaacc1.csp_inv_loc_assignment_id = ila1.csp_inv_loc_assignment_id
      AND ila1.subinventory_code = ohqmv.subinventory_code
      AND ila1.organization_id = ohqmv.organization_id
      AND SYSDATE BETWEEN NVL(ila1.effective_date_start, SYSDATE) AND NVL(ila1.effective_date_end, SYSDATE)
--      AND csi.secondary_inventory_name = ila1.subinventory_code
--      AND csi.organization_id = ila1.organization_id
--      AND csi.condition_type IN('G','B')   --R12-4681995
    )
    AND NOT EXISTS
    (SELECT /*index (ohqacc CSM_MTL_ONHAND_QTY_ACC_U2)*/ 1
     FROM csm_mtl_onhand_qty_acc ohqacc
     WHERE ohqacc.user_id = au.user_id
     AND (ohqacc.inventory_item_id = ohqmv.inventory_item_id )
     AND (ohqacc.organization_id = ohqmv.organization_id )
     AND (ohqacc.subinventory_code = ohqmv.subinventory_code )
     AND ((ohqacc.locator_id IS NULL AND ohqmv.locator_id IS NULL) OR (ohqacc.locator_id = ohqmv.locator_id))
     AND ((ohqacc.lot_number IS NULL AND ohqmv.lot_number IS NULL) OR (ohqacc.lot_number = ohqmv.lot_number))
     AND ((ohqacc.revision IS NULL AND ohqmv.revision IS NULL) OR (ohqacc.revision = ohqmv.revision))
    );


TYPE inv_idTab     IS TABLE OF csm_mtl_onhand_qty_acc.inventory_item_id%TYPE INDEX BY BINARY_INTEGER;
TYPE org_idTab     IS TABLE OF csm_mtl_onhand_qty_acc.organization_id%TYPE INDEX BY BINARY_INTEGER;
TYPE sub_codeTab   IS TABLE OF csm_mtl_onhand_qty_acc.subinventory_code%TYPE INDEX BY BINARY_INTEGER;
TYPE rvsionTab     IS TABLE OF csm_mtl_onhand_qty_acc.revision%TYPE INDEX BY BINARY_INTEGER;
TYPE loc_idTab     IS TABLE OF csm_mtl_onhand_qty_acc.locator_id%TYPE INDEX BY BINARY_INTEGER;
TYPE lot_numTab    IS TABLE OF csm_mtl_onhand_qty_acc.lot_number%TYPE INDEX BY BINARY_INTEGER;
TYPE tran_qtyTab IS TABLE OF mtl_onhand_quantities_detail.transaction_quantity%TYPE INDEX BY BINARY_INTEGER;
TYPE user_idTab     IS TABLE OF asg_user.user_id%TYPE INDEX BY BINARY_INTEGER;
TYPE access_idTab  IS TABLE OF csm_mtl_onhand_qty_acc.access_id%TYPE INDEX BY BINARY_INTEGER;

inv_id     inv_idTab;
org_id     org_idTab;
sub_code   sub_codeTab;
rvsion     rvsionTab;
loc_id     loc_idTab;
lot_num    lot_numTab;
qty       tran_qtyTab;
dummy_qty  tran_qtyTab;
user_id_lst     asg_download.user_list;
acc_id_lst     asg_download.access_list;

l_dummy BOOLEAN;

l_current_run_date DATE;

l_pk_tab   access_idTab;
l_dml_tab  user_idTab;
l_cnt NUMBER :=0;

BEGIN
  CSM_UTIL_PKG.LOG('Entering CSM_SYSTEM_ITEM_EVENT_PKG.REFRESH_MTL_ONHAND_QUANTITY ',
                         'CSM_SYSTEM_ITEM_EVENT_PKG.REFRESH_MTL_ONHAND_QUANTITY',FND_LOG.LEVEL_PROCEDURE);

  l_current_run_date := SYSDATE;

    --*** Push deleted records to client ***

   OPEN l_onhand_delete_csr;
   LOOP
  IF acc_id_lst.COUNT > 0 THEN
    acc_id_lst.DELETE;
  END IF;
  IF user_id_lst.COUNT > 0 THEN
    user_id_lst.DELETE;
  END IF;
  IF inv_id.COUNT > 0 THEN
    inv_id.DELETE;
  END IF;
  IF org_id.COUNT > 0 THEN
    org_id.DELETE;
  END IF;
  IF sub_code.COUNT > 0 THEN
    sub_code.DELETE;
  END IF;
  IF rvsion.COUNT > 0 THEN
    rvsion.DELETE;
  END IF;
  IF loc_id.COUNT > 0 THEN
    loc_id.DELETE;
  END IF;
  IF lot_num.COUNT > 0 THEN
    lot_num.DELETE;
  END IF;
  IF qty.COUNT > 0 THEN
    qty.DELETE;
  END IF;
  IF dummy_qty.COUNT > 0 THEN
    dummy_qty.DELETE;
  END IF;

   FETCH l_onhand_delete_csr BULK COLLECT INTO user_id_lst, inv_id, org_id, acc_id_lst LIMIT 100;
   EXIT WHEN acc_id_lst.COUNT = 0;

   IF acc_id_lst.COUNT > 0 THEN
    CSM_UTIL_PKG.LOG('Pushing ' || acc_id_lst.COUNT || 'deleted records',
                         'CSM_SYSTEM_ITEM_EVENT_PKG.REFRESH_MTL_ONHAND_QUANTITY',FND_LOG.LEVEL_STATEMENT);

      -- do bulk makedirty
      l_dummy := asg_download.mark_dirty(
            P_PUB_ITEM         => g_pub_item
          , p_accessList       => acc_id_lst
          , p_userid_list      => user_id_lst
          , p_dml_type         => 'D'
          , P_TIMESTAMP        => l_current_run_date
          );

    --  FORALL i IN acc_id_lst.FIRST..acc_id_lst.LAST
--        DELETE CSM_MTL_ONHAND_QTY_ACC  WHERE ACCESS_ID = acc_id_lst(i);

      FOR i IN 1..acc_id_lst.COUNT LOOP
        DELETE CSM_MTL_ONHAND_QTY_ACC  WHERE ACCESS_ID = acc_id_lst(i);
		CSM_ITEM_INSTANCE_EVENT_PKG.DELETE_IB_NOTIN_INV(inv_id(i),org_id(i),user_id_lst(i));
	  END LOOP;

   END IF; -- end of deletes
   END LOOP;
   CLOSE l_onhand_delete_csr;


   --*** Push updated records to client ***

   OPEN l_onhand_update_csr;
   LOOP
  IF acc_id_lst.COUNT > 0 THEN
    acc_id_lst.DELETE;
  END IF;
  IF user_id_lst.COUNT > 0 THEN
    user_id_lst.DELETE;
  END IF;
  IF inv_id.COUNT > 0 THEN
    inv_id.DELETE;
  END IF;
  IF org_id.COUNT > 0 THEN
    org_id.DELETE;
  END IF;
  IF sub_code.COUNT > 0 THEN
    sub_code.DELETE;
  END IF;
  IF rvsion.COUNT > 0 THEN
    rvsion.DELETE;
  END IF;
  IF loc_id.COUNT > 0 THEN
    loc_id.DELETE;
  END IF;
  IF lot_num.COUNT > 0 THEN
    lot_num.DELETE;
  END IF;
  IF qty.COUNT > 0 THEN
    qty.DELETE;
  END IF;
  IF dummy_qty.COUNT > 0 THEN
    dummy_qty.DELETE;
  END IF;

   FETCH l_onhand_update_csr BULK COLLECT INTO user_id_lst, inv_id, org_id, sub_code, loc_id, rvsion, lot_num, dummy_qty, qty LIMIT 100;
   EXIT WHEN user_id_lst.COUNT = 0;

   IF user_id_lst.COUNT > 0 THEN
       --*** push to oLite using asg_download ***
     CSM_UTIL_PKG.LOG('Pushing ' || user_id_lst.COUNT || 'updated records',
                         'CSM_SYSTEM_ITEM_EVENT_PKG.REFRESH_MTL_ONHAND_QUANTITY',FND_LOG.LEVEL_STATEMENT);

       FORALL i IN user_id_lst.FIRST..user_id_lst.LAST
         UPDATE CSM_MTL_ONHAND_QTY_ACC
            SET LAST_UPDATE_DATE = l_current_run_date,
                QUANTITY = qty(i)
          WHERE user_id = user_id_lst(i)
            AND inventory_item_id = inv_id(i)
            AND organization_id   = org_id(i)
            AND subinventory_code = sub_code(i)
            AND (REVISION IS NULL OR revision = rvsion(i))
            AND (LOCATOR_ID IS NULL OR LOCATOR_ID = loc_id(i))
            AND (LOT_NUMBER IS NULL OR LOT_NUMBER = lot_num(i))
            RETURNING access_id  BULK COLLECT INTO acc_id_lst;

      -- do bulk makedirty
      l_dummy := asg_download.mark_dirty(
            P_PUB_ITEM         => g_pub_item
          , p_accessList       => acc_id_lst
          , p_userid_list      => user_id_lst
          , p_dml_type         => 'U'
          , P_TIMESTAMP        => l_current_run_date
          );

     --To notify user
		FOR i in 1..acc_id_lst.COUNT
		LOOP
	       l_cnt := l_cnt +1;
           l_pk_tab(l_cnt) :=	acc_id_lst(i);
		   l_dml_tab(acc_id_lst(i)) := 2;
		END LOOP;

    END IF; -- end of updates
   END LOOP;
   CLOSE l_onhand_update_csr;

   --*** Push inserted records to client ***

   OPEN l_onhand_insert_csr;
   LOOP
  IF acc_id_lst.COUNT > 0 THEN
    acc_id_lst.DELETE;
  END IF;
  IF user_id_lst.COUNT > 0 THEN
    user_id_lst.DELETE;
  END IF;
  IF inv_id.COUNT > 0 THEN
    inv_id.DELETE;
  END IF;
  IF org_id.COUNT > 0 THEN
    org_id.DELETE;
  END IF;
  IF sub_code.COUNT > 0 THEN
    sub_code.DELETE;
  END IF;
  IF rvsion.COUNT > 0 THEN
    rvsion.DELETE;
  END IF;
  IF loc_id.COUNT > 0 THEN
    loc_id.DELETE;
  END IF;
  IF lot_num.COUNT > 0 THEN
    lot_num.DELETE;
  END IF;
  IF qty.COUNT > 0 THEN
    qty.DELETE;
  END IF;
  IF dummy_qty.COUNT > 0 THEN
    dummy_qty.DELETE;
  END IF;

   FETCH l_onhand_insert_csr BULK COLLECT INTO user_id_lst, inv_id, org_id, sub_code, loc_id, rvsion, lot_num, qty LIMIT 500;
   EXIT WHEN inv_id.COUNT = 0;

   -- check if there are any items to be downloaded
   IF inv_id.COUNT > 0 THEN
       --*** push to oLite using asg_download ***
     CSM_UTIL_PKG.LOG('Pushing ' || inv_id.COUNT || 'inserted records',
                         'CSM_SYSTEM_ITEM_EVENT_PKG.REFRESH_MTL_ONHAND_QUANTITY',FND_LOG.LEVEL_STATEMENT);

     FOR i IN inv_id.FIRST..inv_id.LAST LOOP
          SELECT csm_mtl_onhand_qty_acc_s.NEXTVAL INTO acc_id_lst(i) FROM dual;
     END LOOP;

     FORALL i IN inv_id.FIRST..inv_id.LAST
          INSERT INTO CSM_MTL_ONHAND_QTY_ACC (ACCESS_ID, user_id, INVENTORY_ITEM_ID,ORGANIZATION_ID,
          SUBINVENTORY_CODE,LOCATOR_ID,REVISION,LOT_NUMBER, LAST_UPDATE_DATE,LAST_UPDATED_BY,
          CREATION_DATE,CREATED_BY, LAST_UPDATE_LOGIN, QUANTITY, GEN_PK) VALUES (acc_id_lst(i), user_id_lst(i), inv_id(i), org_id(i), sub_code(i),
          loc_id(i), rvsion(i), lot_num(i), l_current_run_date,1,l_current_run_date,1, 1, qty(i), acc_id_lst(i));

        -- do bulk makedirty
        l_dummy := asg_download.mark_dirty(
            P_PUB_ITEM         => g_pub_item
          , p_accessList       => acc_id_lst
          , p_userid_list      => user_id_lst
          , p_dml_type         => 'I'
          , P_TIMESTAMP        => l_current_run_date
          );

     --To notify user
		FOR i in 1..acc_id_lst.COUNT
		LOOP
		 IF(NOT l_dml_tab.EXISTS(acc_id_lst(i))
		    AND NOT CSM_UTIL_PKG.is_new_mmu_user(CSM_UTIL_PKG.get_user_name(user_id_lst(i)))) THEN    -- this condition for new mmu user
	       l_cnt := l_cnt +1;
           l_pk_tab(l_cnt) :=	acc_id_lst(i);
		   l_dml_tab(acc_id_lst(i)) := 1;
  		 END IF;
		END LOOP;

    END IF;
   END LOOP;
   CLOSE l_onhand_insert_csr;

  -- set the program update date in jtm_con_request_data to sysdate
  UPDATE jtm_con_request_data
  SET last_run_date = l_current_run_date
  WHERE product_code = 'CSM'
    AND package_name = 'CSM_SYSTEM_ITEM_EVENT_PKG'
    AND procedure_name = 'REFRESH_MTL_ONHAND_QUANTITY';

  -- Notify User of inventory update
   FOR i IN 1..l_pk_tab.COUNT
   LOOP
     IF (l_dml_tab(l_pk_tab(i))=2) THEN
       CSM_WF_PKG.RAISE_START_AUTO_SYNC_EVENT('CSF_M_INVENTORY',to_char(l_pk_tab(i)),'UPDATE');
	 ELSE
       CSM_WF_PKG.RAISE_START_AUTO_SYNC_EVENT('CSF_M_INVENTORY',to_char(l_pk_tab(i)),'NEW');
 	 END IF;
   END LOOP;


  CSM_UTIL_PKG.LOG('Leaving CSM_SYSTEM_ITEM_EVENT_PKG.REFRESH_MTL_ONHAND_QUANTITY ',
                         'CSM_SYSTEM_ITEM_EVENT_PKG.REFRESH_MTL_ONHAND_QUANTITY',FND_LOG.LEVEL_PROCEDURE);

  p_status := 'FINE';
  p_message :=  'CSM_SYSTEM_ITEM_EVENT_PKG.REFRESH_MTL_ONHAND_QUANTITY Executed successfully';

  COMMIT;

 EXCEPTION
  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     p_status := 'ERROR';
     p_message := 'Error in CSM_SYSTEM_ITEM_EVENT_PKG.REFRESH_MTL_ONHAND_QUANTITY: ' || l_sqlerrno || ':' || l_sqlerrmsg;
     ROLLBACK;
     csm_util_pkg.log('CSM_SYSTEM_ITEM_EVENT_PKG.REFRESH_MTL_ONHAND_QUANTITY ERROR : ' || l_sqlerrno || ':' || l_sqlerrmsg);

END Refresh_mtl_onhand_quantity;

PROCEDURE get_new_user_system_items(p_user_id IN NUMBER)
IS
g_pub_item VARCHAR2(30);
l_current_run_date DATE;
l_sqlerrno varchar2(20);
l_sqlerrmsg varchar2(2000);

CURSOR l_systemitems_ins_csr(p_organization_id IN NUMBER, p_user_id IN NUMBER)
IS
SELECT /*+ INDEX (msi MTL_SYSTEM_ITEMS_B_U1) */ CSM_SYSTEM_ITEMS_ACC_S.NEXTVAL,
       au.user_id,
       msi.inventory_item_id,
       msi.organization_id
FROM asg_user au,
     asg_user_pub_resps aupr,
     mtl_system_items_b msi,
     CS_BILLING_TYPE_CATEGORIES cbtc
WHERE au.user_id = p_user_id
AND  au.user_name = aupr.user_name
AND  aupr.pub_name = 'SERVICEP'
AND  msi.organization_id = p_organization_id
AND  msi.enabled_flag = 'Y'
AND  SYSDATE BETWEEN nvl(msi.start_date_active, SYSDATE) AND nvl(msi.end_date_active, SYSDATE)
AND  msi.material_billable_flag = cbtc.billing_type
AND  cbtc.billing_category IN ('L', 'E')
AND  SYSDATE BETWEEN nvl(cbtc.start_date_active, SYSDATE) AND nvl(cbtc.end_date_active, SYSDATE)
AND NOT EXISTS
(SELECT 1
 FROM csm_system_items_acc acc
 WHERE acc.user_id = au.user_id
 AND acc.inventory_item_id = msi.inventory_item_id
 AND acc.organization_id = msi.organization_id
 );

TYPE inv_idTab     IS TABLE OF csm_system_items_acc.inventory_item_id%TYPE INDEX BY BINARY_INTEGER;
TYPE org_idTab     IS TABLE OF csm_system_items_acc.organization_id%TYPE INDEX BY BINARY_INTEGER;

l_inv_id     inv_idTab;
l_org_id     org_idTab;
l_user_id_lst    asg_download.user_list;
l_acc_id_lst     asg_download.access_list;

l_dummy BOOLEAN;
l_organization_id mtl_system_items.organization_id%TYPE;

BEGIN
  CSM_UTIL_PKG.LOG('Entering CSM_SYSTEM_ITEM_EVENT_PKG.get_new_user_system_items ',
                         'CSM_SYSTEM_ITEM_EVENT_PKG.get_new_user_system_items',FND_LOG.LEVEL_PROCEDURE);

  g_pub_item := 'CSF_M_SYSTEM_ITEMS';
  l_current_run_date := SYSDATE;
  l_organization_id := csm_profile_pkg.get_organization_id(p_user_id);

     -- process inserts
     OPEN l_systemitems_ins_csr (p_organization_id=>l_organization_id, p_user_id=>p_user_id);
     LOOP
         l_acc_id_lst.DELETE;
         l_user_id_lst.DELETE;
         l_inv_id.DELETE;
         l_org_id.DELETE;

     FETCH l_systemitems_ins_csr BULK COLLECT INTO l_acc_id_lst, l_user_id_lst, l_inv_id, l_org_id LIMIT 100;
     EXIT WHEN l_acc_id_lst.COUNT = 0;

     IF l_acc_id_lst.COUNT > 0 THEN
       FORALL i IN l_acc_id_lst.FIRST..l_acc_id_lst.LAST
          INSERT INTO CSM_SYSTEM_ITEMS_ACC (ACCESS_ID, USER_ID, INVENTORY_ITEM_ID,ORGANIZATION_ID,
          COUNTER,CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN)
          VALUES (l_acc_id_lst(i), l_user_id_lst(i), l_inv_id(i), l_org_id(i), 1, 1, l_current_run_date,1,l_current_run_date,1);

       -- do bulk makedirty
       l_dummy := asg_download.mark_dirty(
            P_PUB_ITEM         => g_pub_item
          , p_accessList       => l_acc_id_lst
          , p_userid_list      => l_user_id_lst
          , p_dml_type         => 'I'
          , P_TIMESTAMP        => l_current_run_date
          );
      END IF;
      END LOOP;
      CLOSE l_systemitems_ins_csr;

  CSM_UTIL_PKG.LOG('Leaving CSM_SYSTEM_ITEM_EVENT_PKG.get_new_user_system_items ',
                         'CSM_SYSTEM_ITEM_EVENT_PKG.get_new_user_system_items',FND_LOG.LEVEL_PROCEDURE);

 EXCEPTION
  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     csm_util_pkg.log('CSM_SYSTEM_ITEM_EVENT_PKG.get_new_user_system_items ERROR : ' || l_sqlerrno || ':' || l_sqlerrmsg, FND_LOG.LEVEL_EXCEPTION);
     RAISE;
END get_new_user_system_items;

PROCEDURE SYSTEM_ITEM_MDIRTY_I(p_inventory_item_id IN NUMBER,
                               p_organization_id IN NUMBER,
                               p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering SYSTEM_ITEM_MDIRTY_I for inventory_item_id: ' || p_inventory_item_id,
                     'CSM_SYSTEM_ITEM_EVENT_PKG.SYSTEM_ITEM_MDIRTY_I',FND_LOG.LEVEL_PROCEDURE);

   IF p_inventory_item_id IS NOT NULL AND p_organization_id IS NOT NULL THEN
    -- insert into csm_system_items_acc
    CSM_ACC_PKG.Insert_Acc
       ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
        ,P_ACC_TABLE_NAME         => g_acc_table_name1
        ,P_SEQ_NAME               => g_acc_sequence_name1
        ,P_PK1_NAME               => g_pk1_name1
        ,P_PK1_NUM_VALUE          => p_inventory_item_id
        ,P_PK2_NAME               => g_pk2_name1
        ,P_PK2_NUM_VALUE          => p_organization_id
        ,P_USER_ID                => p_user_id
       );
   END IF;

   CSM_UTIL_PKG.LOG('Leaving SYSTEM_ITEM_MDIRTY_I for inventory_item_id: ' || p_inventory_item_id,
                     'CSM_SYSTEM_ITEM_EVENT_PKG.SYSTEM_ITEM_MDIRTY_I',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  SYSTEM_ITEM_MDIRTY_I for inventory_item_id: ' || p_inventory_item_id
                          || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SYSTEM_ITEM_EVENT_PKG.SYSTEM_ITEM_MDIRTY_I',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END SYSTEM_ITEM_MDIRTY_I;

PROCEDURE SYSTEM_ITEM_MDIRTY_D(p_inventory_item_id IN NUMBER,
                               p_organization_id IN NUMBER,
                               p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering SYSTEM_ITEM_MDIRTY_D for inventory_item_id: ' || p_inventory_item_id,
                     'CSM_SYSTEM_ITEM_EVENT_PKG.SYSTEM_ITEM_MDIRTY_D',FND_LOG.LEVEL_PROCEDURE);

   IF p_inventory_item_id IS NOT NULL AND p_organization_id IS NOT NULL THEN
    -- delete from csm_system_items_acc
    CSM_ACC_PKG.Delete_Acc
          ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
           ,P_ACC_TABLE_NAME         => g_acc_table_name1
           ,P_PK1_NAME               => g_pk1_name1
           ,P_PK1_NUM_VALUE          => p_inventory_item_id
           ,P_PK2_NAME               => g_pk2_name1
           ,P_PK2_NUM_VALUE          => p_organization_id
           ,P_USER_ID                => p_user_id
          );
   END IF;

   CSM_UTIL_PKG.LOG('Leaving SYSTEM_ITEM_MDIRTY_D for inventory_item_id: ' || p_inventory_item_id,
                     'CSM_SYSTEM_ITEM_EVENT_PKG.SYSTEM_ITEM_MDIRTY_D',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  SYSTEM_ITEM_MDIRTY_D for inventory_item_id: ' || p_inventory_item_id
                          || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SYSTEM_ITEM_EVENT_PKG.SYSTEM_ITEM_MDIRTY_D',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END SYSTEM_ITEM_MDIRTY_D;

END CSM_SYSTEM_ITEM_EVENT_PKG;


-- End of DDL Script for Package Body APPS.CSM_SYSTEM_ITEM_EVENT_PKG

/
