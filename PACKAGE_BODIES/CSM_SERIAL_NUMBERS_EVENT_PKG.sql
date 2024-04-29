--------------------------------------------------------
--  DDL for Package Body CSM_SERIAL_NUMBERS_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_SERIAL_NUMBERS_EVENT_PKG" AS
/* $Header: csmeslnb.pls 120.6 2008/02/06 13:50:00 anaraman ship $*/
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

g_pub_item varchar2(30) := 'CSM_MTL_SERIAL_NUMBERS';

PROCEDURE insert_mtl_serial_numbers(p_organization_id IN number, p_last_run_date IN date, p_resource_id IN number, p_user_id IN number)
IS
TYPE inventory_items_tbl_typ IS TABLE OF mtl_serial_numbers.inventory_item_id%TYPE INDEX BY binary_integer;
TYPE serial_numbers_tbl_typ IS TABLE OF mtl_serial_numbers.serial_number%TYPE INDEX BY binary_integer;
TYPE organizations_tbl_typ IS TABLE OF mtl_serial_numbers.current_organization_id%TYPE INDEX BY binary_integer;
TYPE access_id_tbl_typ IS TABLE OF csm_mtl_serial_numbers_acc.access_id%TYPE INDEX BY binary_integer;

l_inventory_items_tbl  inventory_items_tbl_typ;
l_serial_numbers_tbl   serial_numbers_tbl_typ;
l_organizations_tbl    organizations_tbl_typ;
l_access_id_tbl        access_id_tbl_typ;
l_run_date             DATE;
l_markdirty            boolean;
l_sqlerrno             varchar2(20);
l_sqlerrmsg            varchar2(2000);

-- update counter of records that may already exist in acc table
CURSOR l_upd_mtl_serial_numbers_csr(p_organization_id in number, p_resourceid IN number, p_userid in number, p_lastrundate IN date)
IS
SELECT acc.access_id
FROM   csm_mtl_serial_numbers_acc acc
WHERE  acc.user_id = p_userid
--AND acc.current_organization_id = p_organization_id
AND   (acc.inventory_item_id, acc.serial_number, acc.current_organization_id) IN (
        SELECT inventory_item_id, serial_number, current_organization_id
    	FROM mtl_serial_numbers
    	WHERE creation_date >= NVL(p_lastrundate, creation_date)
    	AND current_status =3
    	AND (current_subinventory_code, current_organization_id) IN (
     		SELECT subinventory_code
     		,organization_id
     		FROM csp_inv_loc_assignments
     		WHERE resource_id = p_resourceid
     		AND SYSDATE BETWEEN nvl( effective_date_start, SYSDATE )
                     AND nvl( effective_date_end , SYSDATE ))
    		 );

-- get all new serial numbers that do not exist in acc table
CURSOR l_ins_mtl_serial_numbers_csr(p_organization_id in number, p_resourceid IN number, p_userid in number, p_lastrundate IN date)
IS--select  serial numbers in status 3 for both ib non ib items
 SELECT  csm_mtl_serial_numbers_acc_s.nextval, inventory_item_id, serial_number, current_organization_id
 FROM 	 mtl_serial_numbers
 WHERE   current_status =3 -- resides in stores + issued out of subinv
 AND   	 ( current_subinventory_code, current_organization_id ) IN (
       	   SELECT subinventory_code
       	   ,organization_id
       		FROM csp_inv_loc_assignments
       		WHERE resource_id = p_resourceid
       		AND SYSDATE BETWEEN nvl( effective_date_start, SYSDATE )
                     AND nvl( effective_date_end , SYSDATE ))
 AND  	 ( inventory_item_id, serial_number, current_organization_id ) NOT IN (
           SELECT inventory_item_id, serial_number, current_organization_id
       	   FROM csm_mtl_serial_numbers_acc
       	   WHERE user_id = p_userid );

CURSOR l_ins_mtl_ser_num_fornonib_csr(p_organization_id in number, p_resourceid IN number, p_userid in number, p_lastrundate IN date)
IS--select  serial numbers in status 1,4 for non ib items only
SELECT   csm_mtl_serial_numbers_acc_s.nextval,
 		 ser.inventory_item_id,
		 ser.serial_number,
  		 ser.current_organization_id
FROM   	 mtl_serial_numbers ser
WHERE 	 ser.current_status IN (1,4)     --Not assigned and out of subinv
AND 	 EXISTS (
	  		   SELECT  'x'
			   FROM	   csm_mtl_onhand_qty_acc ohqacc,
			   		   mtl_system_items sys
			   WHERE   ohqacc.inventory_item_id 	 = ser.inventory_item_id
			   AND 	   ohqacc.organization_id 		 = ser.current_organization_id
			   AND	   ohqacc.user_id 				 = p_userid
			   AND     ohqacc.inventory_item_id    	 = sys.inventory_item_id
			   AND     ohqacc.ORGANIZATION_ID 		 = sys.ORGANIZATION_ID
			   AND     NVL(sys.COMMS_NL_TRACKABLE_FLAG,'N') ='N'
   			  )
AND    NOT EXISTS (
               SELECT 'x'
               FROM   csm_mtl_serial_numbers_acc sacc
       		   WHERE  user_id 					   = p_userid
      		   AND    sacc.inventory_item_id 	   = ser.inventory_item_id
      		   AND    sacc.serial_number  	 	   = ser.serial_number
      		   AND    sacc.current_organization_id = ser.current_organization_id);

BEGIN
 CSM_UTIL_PKG.LOG('Entering CSM_SERIAL_NUMBERS_EVENT_PKG.INSERT_MTL_SERIAL_NUMBERS ',
                         'CSM_SERIAL_NUMBERS_EVENT_PKG.INSERT_MTL_SERIAL_NUMBERS',FND_LOG.LEVEL_PROCEDURE);

 IF l_access_id_tbl.count > 0 THEN
    l_access_id_tbl.DELETE;
 END IF;

 l_run_date := SYSDATE;

 -- update counter of serial numbers that already exist for user in acc table
 OPEN l_upd_mtl_serial_numbers_csr(p_organization_id, p_resource_id, p_user_id, p_last_run_date);
 FETCH l_upd_mtl_serial_numbers_csr BULK COLLECT INTO l_access_id_tbl;
 CLOSE l_upd_mtl_serial_numbers_csr;

 IF l_access_id_tbl.count > 0 THEN
    FORALL i IN 1..l_access_id_tbl.count
        UPDATE csm_mtl_serial_numbers_acc
        SET    counter = counter + 1
              ,last_update_date = SYSDATE
              ,last_updated_by = fnd_global.user_id
        WHERE access_id = l_access_id_tbl(i);

   l_access_id_tbl.delete;
 END IF;

 -- BULK collect all new inserted serial numbers with STatus 3
 OPEN l_ins_mtl_serial_numbers_csr(p_organization_id, p_resource_id, p_user_id, p_last_run_date);
 FETCH l_ins_mtl_serial_numbers_csr BULK COLLECT INTO l_access_id_tbl, l_inventory_items_tbl, l_serial_numbers_tbl, l_organizations_tbl;
 CLOSE l_ins_mtl_serial_numbers_csr;

 -- bulk insert into acc tables
 IF l_access_id_tbl.count > 0 THEN
   FORALL i IN 1..l_access_id_tbl.count
      INSERT INTO csm_mtl_serial_numbers_acc(access_id, user_id, serial_number, inventory_item_id, current_organization_id,
                               counter, created_by, creation_date, last_updated_by, last_update_date, last_update_login)
                        VALUES (l_access_id_tbl(i), p_user_id, l_serial_numbers_tbl(i), l_inventory_items_tbl(i), l_organizations_tbl(i),
                                1, fnd_global.user_id, l_run_date, fnd_global.user_id, l_run_date, fnd_global.login_id);

    CSM_UTIL_PKG.LOG('Bulk inserted ' || l_access_id_tbl.count || ' records into csm_mtl_serial_numbers_acc for resource ' || p_resource_id ,
                         'CSM_SERIAL_NUMBERS_EVENT_PKG.INSERT_MTL_SERIAL_NUMBERS',FND_LOG.LEVEL_STATEMENT);

   -- make dirty calls
   FOR i IN 1..l_access_id_tbl.count LOOP
      l_markdirty := csm_util_pkg.MakeDirtyForResource(g_pub_item,
                                                       l_access_id_tbl(i),
                                                       p_resource_id,
                                                       asg_download.ins,
                                                       l_run_date);
   END LOOP;
 END IF;

 ---Insert for non ib items
 IF l_access_id_tbl.count > 0 THEN
 	l_access_id_tbl.delete;
 	l_inventory_items_tbl.delete;
 	l_serial_numbers_tbl.delete;
    l_organizations_tbl.delete;
 END IF;

  -- BULK collect all new inserted serial numbers with STatus 1 and 4 for Non ib items
 OPEN l_ins_mtl_ser_num_fornonib_csr(p_organization_id, p_resource_id, p_user_id, p_last_run_date);
 FETCH l_ins_mtl_ser_num_fornonib_csr BULK COLLECT INTO l_access_id_tbl, l_inventory_items_tbl, l_serial_numbers_tbl, l_organizations_tbl;
 CLOSE l_ins_mtl_ser_num_fornonib_csr;

 -- bulk insert into acc tables
 IF l_access_id_tbl.count > 0 THEN
   FORALL i IN 1..l_access_id_tbl.count
      INSERT INTO csm_mtl_serial_numbers_acc(access_id, user_id, serial_number, inventory_item_id, current_organization_id,
                               counter, created_by, creation_date, last_updated_by, last_update_date, last_update_login)
                        VALUES (l_access_id_tbl(i), p_user_id, l_serial_numbers_tbl(i), l_inventory_items_tbl(i), l_organizations_tbl(i),
                                1, fnd_global.user_id, l_run_date, fnd_global.user_id, l_run_date, fnd_global.login_id);

    CSM_UTIL_PKG.LOG('Bulk inserted ' || l_access_id_tbl.count || ' records into csm_mtl_serial_numbers_acc for resource ' || p_resource_id ,
                         'CSM_SERIAL_NUMBERS_EVENT_PKG.INSERT_MTL_SERIAL_NUMBERS',FND_LOG.LEVEL_STATEMENT);

   -- make dirty calls
   FOR i IN 1..l_access_id_tbl.count LOOP
      l_markdirty := csm_util_pkg.MakeDirtyForResource(g_pub_item,
                                                       l_access_id_tbl(i),
                                                       p_resource_id,
                                                       asg_download.ins,
                                                       l_run_date);
   END LOOP;
 END IF;

 CSM_UTIL_PKG.LOG('Leaving CSM_SERIAL_NUMBERS_EVENT_PKG.INSERT_MTL_SERIAL_NUMBERS ',
                         'CSM_SERIAL_NUMBERS_EVENT_PKG.INSERT_MTL_SERIAL_NUMBERS',FND_LOG.LEVEL_PROCEDURE);

 EXCEPTION
  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     CSM_UTIL_PKG.LOG('Exception in CSM_SERIAL_NUMBERS_EVENT_PKG.INSERT_MTL_SERIAL_NUMBERS: ' || l_sqlerrno || ':' || l_sqlerrmsg,
                         'CSM_SERIAL_NUMBERS_EVENT_PKG.INSERT_MTL_SERIAL_NUMBERS',FND_LOG.LEVEL_EXCEPTION);

END INSERT_MTL_SERIAL_NUMBERS;

PROCEDURE update_mtl_serial_numbers(p_organization_id IN number, p_last_run_date IN date, p_resource_id IN number, p_user_id IN number)
IS
TYPE access_id_tbl_typ IS TABLE OF csm_mtl_serial_numbers_acc.access_id%TYPE INDEX BY binary_integer;
l_access_id_tbl        access_id_tbl_typ;
l_run_date DATE;
l_markdirty            boolean;
l_sqlerrno             varchar2(20);
l_sqlerrmsg            varchar2(2000);

-- upd serial numbers whose locations have changed within the org to locations user has access to
CURSOR l_upd_mtl_serial_numbers_csr(p_lastrundate IN date, p_resourceid IN number, p_userid IN number)
IS
SELECT access_id
FROM csm_mtl_serial_numbers_acc acc
,    mtl_serial_numbers msn
WHERE msn.inventory_item_id = acc.inventory_item_id
AND   msn.serial_number = acc.serial_number
AND   msn.current_organization_id = acc.current_organization_id
AND   msn.last_update_date  >= p_lastrundate
AND   acc.user_id = p_userid;
/*AND ( msn.current_subinventory_code, msn.current_organization_id ) IN (
     SELECT subinventory_code
     ,      organization_id
     FROM csp_inv_loc_assignments
     WHERE resource_id = p_resourceid
     AND SYSDATE BETWEEN nvl( effective_date_start, SYSDATE )
                     AND nvl( effective_date_end , SYSDATE ));*/

-- decrement counter of serial numbers whose locations have changed within the org or that reside in a diff org
CURSOR l_del_mtl_serial_numbers_csr(p_lastrundate IN date, p_resourceid IN number, p_userid IN number)
IS
SELECT access_id
FROM csm_mtl_serial_numbers_acc acc
,    mtl_serial_numbers msn
WHERE msn.inventory_item_id = acc.inventory_item_id
AND   msn.serial_number = acc.serial_number
AND   msn.current_organization_id = acc.current_organization_id
AND   acc.user_id = p_userid
AND   msn.current_status =3
AND ( msn.current_subinventory_code, msn.current_organization_id ) NOT IN (
     SELECT subinventory_code
     ,      organization_id
     FROM csp_inv_loc_assignments
     WHERE resource_id = p_resourceid
     AND SYSDATE BETWEEN nvl( effective_date_start, SYSDATE )
                     AND nvl( effective_date_end , SYSDATE ))
UNION
SELECT access_id
FROM  csm_mtl_serial_numbers_acc acc
WHERE acc.user_id = p_user_id
AND NOT EXISTS
 	(SELECT 1
  	  FROM mtl_serial_numbers msn
  	  WHERE msn.serial_number = acc.serial_number
  	  AND  msn.inventory_item_id = acc.inventory_item_id
  	  AND msn.current_organization_id = acc.current_organization_id
  	  AND msn.CURRENT_STATUS =3
 	  )
AND NOT EXISTS
 	( SELECT 1
 	  FROM   mtl_serial_numbers ser,
 	    	 csm_mtl_onhand_qty_acc ohqacc,
	    	 mtl_system_items sys
	  WHERE  ser.current_status in (1,4)
	  AND	 ohqacc.user_id = acc.user_id
	  AND    ser.serial_number  = acc.serial_number
  	  AND	 ser.inventory_item_id =acc.inventory_item_id
	  AND	 ser.inventory_item_id =sys.inventory_item_id
	  AND    ser.CURRENT_ORGANIZATION_ID =  sys.ORGANIZATION_ID
	  AND 	 NVL(sys.COMMS_NL_TRACKABLE_FLAG,'N') ='N'
	  AND 	 ohqacc.inventory_item_id = ser.inventory_item_id
	  AND 	 ohqacc.organization_id = ser.current_organization_id

 	  );


CURSOR l_delete_serial_number_acc(p_userid IN number)
IS
SELECT access_id
FROM csm_mtl_serial_numbers_acc
WHERE user_id = p_userid
AND counter = 0;

BEGIN
 CSM_UTIL_PKG.LOG('Entering CSM_SERIAL_NUMBERS_EVENT_PKG.UPDATE_MTL_SERIAL_NUMBERS ',
                         'CSM_SERIAL_NUMBERS_EVENT_PKG.UPDATE_MTL_SERIAL_NUMBERS',FND_LOG.LEVEL_PROCEDURE);

 l_run_date := SYSDATE;

 IF l_access_id_tbl.count > 0 THEN
    l_access_id_tbl.DELETE;
 END IF;

-- bulk collect all updated serial_numbers
 OPEN l_upd_mtl_serial_numbers_csr(p_last_run_date, p_resource_id, p_user_id);
 FETCH l_upd_mtl_serial_numbers_csr BULK COLLECT INTO l_access_id_tbl;
 CLOSE l_upd_mtl_serial_numbers_csr;

 IF l_access_id_tbl.count > 0 THEN
   CSM_UTIL_PKG.LOG(l_access_id_tbl.count || ' records sent to olite for updating csm_mtl_serial_numbers for resource ' || p_resource_id ,
                         'CSM_SERIAL_NUMBERS_EVENT_PKG.UPDATE_MTL_SERIAL_NUMBERS',FND_LOG.LEVEL_STATEMENT);

   -- make dirty calls
   FOR i IN 1..l_access_id_tbl.count LOOP
      l_markdirty := csm_util_pkg.MakeDirtyForResource(g_pub_item,
                                                       l_access_id_tbl(i),
                                                       p_resource_id,
                                                       asg_download.upd,
                                                       l_run_date);
   END LOOP;

   l_access_id_tbl.DELETE;
 END IF;

 -- bulk collect all serial numbers to be deleted
 OPEN l_del_mtl_serial_numbers_csr(p_last_run_date, p_resource_id, p_user_id);
 FETCH l_del_mtl_serial_numbers_csr BULK COLLECT INTO l_access_id_tbl;
 CLOSE l_del_mtl_serial_numbers_csr;

 -- update counter for records to be deleted
 IF l_access_id_tbl.count > 0 THEN
    FORALL i IN 1..l_access_id_tbl.count
        UPDATE csm_mtl_serial_numbers_acc
        SET    counter = counter - 1
              ,last_update_date = SYSDATE
              ,last_updated_by = fnd_global.user_id
        WHERE access_id = l_access_id_tbl(i);

   l_access_id_tbl.delete;
 END IF;

 -- delete all access_id's that have counter = 0
 OPEN l_delete_serial_number_acc(p_user_id);
 FETCH l_delete_serial_number_acc BULK COLLECT INTO l_access_id_tbl;
 CLOSE l_delete_serial_number_acc;

 IF l_access_id_tbl.count > 0 THEN
   CSM_UTIL_PKG.LOG(l_access_id_tbl.count || ' records sent to olite for deleting csm_mtl_serial_numbers for resource ' || p_resource_id ,
                         'CSM_SERIAL_NUMBERS_EVENT_PKG.UPDATE_MTL_SERIAL_NUMBERS',FND_LOG.LEVEL_STATEMENT);

   -- make dirty calls
   FOR i IN 1..l_access_id_tbl.count LOOP
      l_markdirty := csm_util_pkg.MakeDirtyForResource(g_pub_item,
                                                       l_access_id_tbl(i),
                                                       p_resource_id,
                                                       asg_download.del,
                                                       l_run_date);
   END LOOP;

   FORALL i IN 1..l_access_id_tbl.count
      DELETE csm_mtl_serial_numbers_acc WHERE ACCESS_ID = l_access_id_tbl(i);

   l_access_id_tbl.DELETE;
 END IF;

 CSM_UTIL_PKG.LOG('Leaving CSM_SERIAL_NUMBERS_EVENT_PKG.UPDATE_MTL_SERIAL_NUMBERS ',
                         'CSM_SERIAL_NUMBERS_EVENT_PKG.UPDATE_MTL_SERIAL_NUMBERS',FND_LOG.LEVEL_PROCEDURE);

 EXCEPTION
  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     CSM_UTIL_PKG.LOG('Exception in CSM_SERIAL_NUMBERS_EVENT_PKG.UPDATE_MTL_SERIAL_NUMBERS: ' || l_sqlerrno || ':' || l_sqlerrmsg,
                         'CSM_SERIAL_NUMBERS_EVENT_PKG.UPDATE_MTL_SERIAL_NUMBERS',FND_LOG.LEVEL_EXCEPTION);

END UPDATE_MTL_SERIAL_NUMBERS;

PROCEDURE refresh_mtl_serial_numbers_acc
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_prog_update_date 			   jtm_con_request_data.last_run_date%TYPE;
l_all_omfs_palm_resource_list  asg_download.user_list;
l_valid_omfs_resource_list 	   asg_download.user_list;
l_null_palm_omfs_resource_list asg_download.user_list;
l_user_palm_organization_id    mtl_system_items.organization_id%TYPE;
l_usr_list_for_serial 		   asg_download.user_list;
l_rsrc_list_for_serial 		   asg_download.user_list;
l_last_run_date 			   jtm_con_request_data.last_run_date%TYPE;
l_run_date DATE;
l_user_id  fnd_user.user_id%TYPE;
l_sqlerrno varchar2(20);
l_sqlerrmsg varchar2(2000);

CURSOR l_last_run_date_csr
IS
SELECT nvl(last_run_date, (sysdate - 365*50))
FROM jtm_con_request_data
WHERE package_name = 'CSM_SERIAL_NUMBERS_EVENT_PKG'
AND procedure_name = 'REFRESH_MTL_SERIAL_NUMBERS_ACC';

CURSOR l_user_id_csr (p_resourceid IN number)
IS
SELECT user_id
FROM asg_user
WHERE resource_id = p_resourceid;

CURSOR l_usr_rsrc_list_serial
IS
SELECT
au.resource_id,
au.user_id
FROM asg_user_pub_resps aupr,
     asg_user au
WHERE aupr.pub_name = 'SERVICEP'
AND  au.user_name = aupr.user_name
AND  au.owner_id  = au.user_id
AND  au.enabled   = 'Y';

BEGIN
 l_run_date := SYSDATE;

 CSM_UTIL_PKG.LOG('Entering CSM_SERIAL_NUMBERS_EVENT_PKG.refresh_mtl_serial_numbers_acc ',
                         'CSM_SERIAL_NUMBERS_EVENT_PKG.refresh_mtl_serial_numbers_acc',FND_LOG.LEVEL_PROCEDURE);

 -- R12 Serial Number implementation
 IF l_usr_list_for_serial.COUNT > 0 THEN
 	l_usr_list_for_serial.DELETE;
 END IF;

 IF l_rsrc_list_for_serial.COUNT > 0 THEN
 	l_rsrc_list_for_serial.DELETE;
 END IF;

 OPEN l_last_run_date_csr;
 FETCH l_last_run_date_csr INTO l_last_run_date;
 CLOSE l_last_run_date_csr;

 OPEN l_usr_rsrc_list_serial;
 FETCH l_usr_rsrc_list_serial BULK COLLECT INTO l_rsrc_list_for_serial,l_usr_list_for_serial;
 CLOSE l_usr_rsrc_list_serial;
 IF l_usr_list_for_serial.COUNT > 0 THEN
  FOR l_count in 1..l_usr_list_for_serial.COUNT LOOP
    l_user_palm_organization_id:=csm_profile_pkg.get_organization_id(l_usr_list_for_serial(l_count));
    --updating/deleting serial numbers already present in the ACC
    update_mtl_serial_numbers(l_user_palm_organization_id,l_last_run_date,l_rsrc_list_for_serial(l_count),l_usr_list_for_serial(l_count));
        --inserting new serial numbers
    insert_mtl_serial_numbers(l_user_palm_organization_id,l_last_run_date,l_rsrc_list_for_serial(l_count),l_usr_list_for_serial(l_count));

  END LOOP;
 END IF;


 -- update last_run_date
 UPDATE jtm_con_request_data
 SET last_run_date = l_run_date
 WHERE package_name = 'CSM_SERIAL_NUMBERS_EVENT_PKG'
 AND procedure_name = 'REFRESH_MTL_SERIAL_NUMBERS_ACC';

 COMMIT;

 CSM_UTIL_PKG.LOG('Leaving CSM_SERIAL_NUMBERS_EVENT_PKG.refresh_mtl_serial_numbers_acc ',
                         'CSM_SERIAL_NUMBERS_EVENT_PKG.refresh_mtl_serial_numbers_acc',FND_LOG.LEVEL_PROCEDURE);


 EXCEPTION
  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     ROLLBACK;
     CSM_UTIL_PKG.LOG('Exception in CSM_SERIAL_NUMBERS_EVENT_PKG.REFRESH_MTL_SERIAL_NUMBERS_ACC: ' || l_sqlerrno || ':' || l_sqlerrmsg,
                         'CSM_SERIAL_NUMBERS_EVENT_PKG.REFRESH_MTL_SERIAL_NUMBERS_ACC',FND_LOG.LEVEL_EXCEPTION);

END REFRESH_MTL_SERIAL_NUMBERS_ACC;

PROCEDURE DELETE_OLD_ORG_SERIAL_NUMBERS(p_organization_id IN number
                                        , p_user_id     IN number
                                        , p_resource_id IN number)
IS
TYPE access_id_tbl_typ  IS TABLE OF csm_mtl_serial_numbers_acc.access_id%TYPE INDEX BY BINARY_INTEGER;
l_access_id_tbl  access_id_tbl_typ;
l_mark_dirty boolean;
l_run_date date;
l_sqlerrno  varchar2(20);
l_sqlerrmsg varchar2(2000);

-- make delete dirty calls for serial numbers with counter=1; do not delete from acc
-- since delete will be done based on csp_inv_loc_assignment data
CURSOR l_del_mtl_serial_numbers_csr(p_organizationid IN number,
                                    p_userid IN number)
IS
SELECT access_id
FROM csm_mtl_serial_numbers_acc
WHERE user_id = p_userid
AND current_organization_id = p_organizationid
AND counter = 0;

BEGIN
 CSM_UTIL_PKG.LOG('Entering CSM_MTL_SERIAL_NUMBERS_EVENT_PKG.DELETE_OLD_ORG_SERIAL_NUMBERS ',
                         'CSM_MTL_SERIAL_NUMBERS_EVENT_PKG.DELETE_OLD_ORG_SERIAL_NUMBERS',FND_LOG.LEVEL_PROCEDURE);

 l_run_date := SYSDATE;


 CSM_UTIL_PKG.LOG('Leaving CSM_MTL_SERIAL_NUMBERS_EVENT_PKG.DELETE_OLD_ORG_SERIAL_NUMBERS ',
                         'CSM_MTL_SERIAL_NUMBERS_EVENT_PKG.DELETE_OLD_ORG_SERIAL_NUMBERS',FND_LOG.LEVEL_PROCEDURE);

 EXCEPTION
  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
--logm('Exception ' || l_sqlerrmsg);
     CSM_UTIL_PKG.LOG('Exception in CSM_MTL_SERIAL_NUMBERS_EVENT_PKG.DELETE_OLD_ORG_SERIAL_NUMBERS: ' || l_sqlerrno || ':' || l_sqlerrmsg,
                         'CSM_MTL_SERIAL_NUMBERS_EVENT_PKG.DELETE_OLD_ORG_SERIAL_NUMBERS',FND_LOG.LEVEL_EXCEPTION);

END DELETE_OLD_ORG_SERIAL_NUMBERS;


PROCEDURE GET_NEW_ORG_SERIAL_NUMBERS(p_organization_id IN number
                                        , p_user_id     IN number
                                        , p_resource_id IN number)
IS
TYPE access_id_tbl_typ  IS TABLE OF csm_mtl_serial_numbers_acc.access_id%TYPE INDEX BY BINARY_INTEGER;
l_access_id_tbl  access_id_tbl_typ;
l_mark_dirty boolean;
l_run_date date;
l_sqlerrno  varchar2(20);
l_sqlerrmsg varchar2(2000);

-- make insert dirty calls for serial numbers with counter=1;
-- since data with counter>1 would already be existing on the palm
CURSOR l_del_mtl_serial_numbers_csr(p_organizationid IN number,
                                    p_userid IN number)
IS
SELECT access_id
FROM csm_mtl_serial_numbers_acc
WHERE user_id = p_userid
AND current_organization_id = p_organizationid
AND counter = 1;

BEGIN
 CSM_UTIL_PKG.LOG('Entering CSM_MTL_SERIAL_NUMBERS_EVENT_PKG.GET_NEW_ORG_SERIAL_NUMBERS ',
                         'CSM_MTL_SERIAL_NUMBERS_EVENT_PKG.GET_NEW_ORG_SERIAL_NUMBERS',FND_LOG.LEVEL_PROCEDURE);

 l_run_date := SYSDATE;


 CSM_UTIL_PKG.LOG('Leaving CSM_MTL_SERIAL_NUMBERS_EVENT_PKG.GET_NEW_ORG_SERIAL_NUMBERS ',
                         'CSM_MTL_SERIAL_NUMBERS_EVENT_PKG.GET_NEW_ORG_SERIAL_NUMBERS',FND_LOG.LEVEL_PROCEDURE);

 EXCEPTION
  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     CSM_UTIL_PKG.LOG('Exception in CSM_MTL_SERIAL_NUMBERS_EVENT_PKG.GET_NEW_ORG_SERIAL_NUMBERS: ' || l_sqlerrno || ':' || l_sqlerrmsg,
                         'CSM_MTL_SERIAL_NUMBERS_EVENT_PKG.GET_NEW_ORG_SERIAL_NUMBERS',FND_LOG.LEVEL_EXCEPTION);


END GET_NEW_ORG_SERIAL_NUMBERS;

-- currently not being used as serial numbers are not downloaded
PROCEDURE INV_LOC_ASS_MSN_MAKE_DIRTY_I(p_csp_inv_loc_assignment_id IN NUMBER, p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering INV_LOC_ASS_MSN_MAKE_DIRTY_I for csp_inv_loc_assignment_id: ' || p_csp_inv_loc_assignment_id,
                                   'CSM_SERIAL_NUMBERS_EVENT_PKG.INV_LOC_ASS_MSN_MAKE_DIRTY_I',FND_LOG.LEVEL_PROCEDURE);

   CSM_UTIL_PKG.LOG('Leaving INV_LOC_ASS_MSN_MAKE_DIRTY_I for csp_inv_loc_assignment_id: ' || p_csp_inv_loc_assignment_id,
                                   'CSM_SERIAL_NUMBERS_EVENT_PKG.INV_LOC_ASS_MSN_MAKE_DIRTY_I',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  INV_LOC_ASS_MSN_MAKE_DIRTY_I for csp_inv_loc_assignment_id:'
                       || to_char(p_csp_inv_loc_assignment_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SERIAL_NUMBERS_EVENT_PKG.INV_LOC_ASS_MSN_MAKE_DIRTY_I',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END INV_LOC_ASS_MSN_MAKE_DIRTY_I;

-- currently not being used as serial numbers are not downloaded
PROCEDURE INV_LOC_ASS_MSN_MAKE_DIRTY_D(p_csp_inv_loc_assignment_id IN NUMBER,
                                       p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering INV_LOC_ASS_MSN_MAKE_DIRTY_D for csp_inv_loc_assignment_id: ' || p_csp_inv_loc_assignment_id,
                                   'CSM_SERIAL_NUMBERS_EVENT_PKG.INV_LOC_ASS_MSN_MAKE_DIRTY_D',FND_LOG.LEVEL_PROCEDURE);

   CSM_UTIL_PKG.LOG('Leaving INV_LOC_ASS_MSN_MAKE_DIRTY_D for csp_inv_loc_assignment_id: ' || p_csp_inv_loc_assignment_id,
                                   'CSM_SERIAL_NUMBERS_EVENT_PKG.INV_LOC_ASS_MSN_MAKE_DIRTY_D',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  INV_LOC_ASS_MSN_MAKE_DIRTY_D for csp_inv_loc_assignment_id:'
                       || to_char(p_csp_inv_loc_assignment_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SERIAL_NUMBERS_EVENT_PKG.INV_LOC_ASS_MSN_MAKE_DIRTY_D',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END INV_LOC_ASS_MSN_MAKE_DIRTY_D;

END CSM_SERIAL_NUMBERS_EVENT_PKG;

/
