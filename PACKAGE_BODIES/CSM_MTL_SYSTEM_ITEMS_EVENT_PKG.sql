--------------------------------------------------------
--  DDL for Package Body CSM_MTL_SYSTEM_ITEMS_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_MTL_SYSTEM_ITEMS_EVENT_PKG" AS
/* $Header: csmesib.pls 120.2.12010000.2 2009/06/17 05:15:15 trajasek ship $ */
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

g_pub_item varchar2(30) := 'CSM_MTL_SYSTEM_ITEMS';

/*** Globals ***/
g_mtl_sys_items_acc_table_name        CONSTANT VARCHAR2(30) := 'CSM_MTL_SYSTEM_ITEMS_ACC';
g_mtl_sys_items_table_name            CONSTANT VARCHAR2(30) := 'CS_MTL_SYSTEM_ITEMS';
g_mtl_sys_items_seq_name              CONSTANT VARCHAR2(30) := 'CSM_MTL_SYSTEM_ITEMS_ACC_S' ;
g_mtl_sys_items_pk1_name              CONSTANT VARCHAR2(30) := 'INVENTORY_ITEM_ID';
g_mtl_sys_items_pk2_name              CONSTANT VARCHAR2(30) := 'ORGANIZATION_ID';
g_mtl_sys_items_pubi_name CONSTANT CSM_ACC_PKG.t_publication_item_list :=
  CSM_ACC_PKG.t_publication_item_list('CSM_MTL_SYSTEM_ITEMS');

PROCEDURE insert_mtl_system_items( p_user_id     IN NUMBER,
                                   p_organization_id IN NUMBER,
                                   p_category_set_id IN NUMBER,
                                   p_category_id IN NUMBER,
                                   p_last_run_date IN DATE,
                                   p_changed IN VARCHAR2)
IS
l_run_date 		DATE;
l_sqlerrno 		VARCHAR2(20);
l_sqlerrmsg 	VARCHAR2(4000);
l_error_msg 	VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_stmt  		VARCHAR2(4000);
l_stmt1			VARCHAR2(4000);
l_markdirty 	BOOLEAN;


TYPE inventory_item_id_tbl_typ  IS TABLE OF mtl_system_items_b.inventory_item_id%TYPE INDEX BY BINARY_INTEGER;
TYPE organization_id_tbl_typ    IS TABLE OF mtl_system_items_b.organization_id%TYPE   INDEX BY BINARY_INTEGER;

l_inventory_item_id_tbl inventory_item_id_tbl_typ;
l_organization_id_tbl 	organization_id_tbl_typ;
l_tab_access_id   		ASG_DOWNLOAD.ACCESS_LIST;
l_tab_user_id 			ASG_DOWNLOAD.USER_LIST;

-- Both category and cat set are null
CURSOR c_items (b_user_id NUMBER, b_organization_id NUMBER,
      b_changed VARCHAR2, b_last_run_date DATE)
IS
SELECT csm_mtl_system_items_acc_s.NEXTVAL, inventory_item_id, organization_id, b_user_id
FROM   MTL_SYSTEM_ITEMS_B msi
WHERE  msi.organization_id = b_organization_id
AND    NOT EXISTS
	   ( SELECT 1
  	   FROM  csm_mtl_system_items_acc acc
  	   WHERE user_id = b_user_id
  	   AND 	 acc.inventory_item_id = msi.inventory_item_id
  	   AND 	 acc.organization_id   = msi.organization_id);

-- Category is not null and Cat set is null
CURSOR c_items_Cat (b_user_id NUMBER, b_organization_id NUMBER,
      b_changed VARCHAR2, b_last_run_date DATE, b_category_id NUMBER)
IS
SELECT csm_mtl_system_items_acc_s.NEXTVAL, itemcat.inventory_item_id,
      itemcat.organization_id, b_user_id
FROM   mtl_item_categories itemcat
WHERE  itemcat.category_id = b_category_id
AND    itemcat.organization_id = b_organization_id
AND    NOT EXISTS
(SELECT 1
 FROM   csm_mtl_system_items_acc acc
 WHERE  user_id = b_user_id
 AND    acc.inventory_item_id = itemcat.inventory_item_id
 AND    acc.organization_id   = itemcat.organization_id
 );

-- Category is null and Cat Set is not null
CURSOR c_items_Cat_Set (b_user_id NUMBER, b_organization_id NUMBER,
      b_changed VARCHAR2, b_last_run_date DATE, b_category_set_id NUMBER)
IS
SELECT csm_mtl_system_items_acc_s.NEXTVAL, itemcat.inventory_item_id,
       itemcat.organization_id, b_user_id
FROM   mtl_item_categories itemcat
WHERE  itemcat.category_set_id = b_category_set_id
AND    itemcat.organization_id = b_organization_id
AND    NOT EXISTS
    (SELECT 1
      FROM csm_mtl_system_items_acc acc
      WHERE user_id = b_user_id
      AND acc.inventory_item_id = itemcat.inventory_item_id
      AND acc.organization_id   = itemcat.organization_id
    );

-- Both Category and Category set are not null
CURSOR c_items_Cat_Set_Cat (b_user_id NUMBER, b_organization_id NUMBER,
       b_changed VARCHAR2, b_last_run_date DATE, b_category_id NUMBER, b_category_set_id NUMBER)
IS
SELECT csm_mtl_system_items_acc_s.NEXTVAL, itemcat.inventory_item_id,
        itemcat.organization_id, b_user_id
FROM   mtl_item_categories itemcat
WHERE  itemcat.category_set_id = b_category_set_id
AND    itemcat.category_id     = b_category_id
AND    itemcat.organization_id = b_organization_id
AND    NOT EXISTS
    (SELECT 1
    FROM csm_mtl_system_items_acc acc
    WHERE user_id = b_user_id
    AND acc.inventory_item_id = itemcat.inventory_item_id
    AND acc.organization_id   = itemcat.organization_id
    );

BEGIN
  CSM_UTIL_PKG.LOG('Entering CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.INSERT_MTL_SYSTEM_ITEMS ',
                         'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.INSERT_MTL_SYSTEM_ITEMS',FND_LOG.LEVEL_PROCEDURE);

  l_run_date := SYSDATE;

  -- since profiles are changed get all inventory items that may already exist in
  -- acc due to current SR's and increment counter
  IF p_changed = 'Y' THEN

      -- changed to dynamic sql to support either category or category set
      l_stmt := 'UPDATE csm_mtl_system_items_acc';
      l_stmt :=   l_stmt || ' SET counter = counter + 1';
      l_stmt :=   l_stmt || '  ,   last_update_date = SYSDATE';
      l_stmt :=   l_stmt || '  ,   last_updated_by = 1';
      l_stmt :=   l_stmt || '  WHERE user_id = :1';
      l_stmt :=   l_stmt || '  AND organization_id = :2';

      IF (p_category_id IS NOT NULL) THEN
        l_stmt1 := ' itemcat.category_id = ' || p_category_id;
      END IF;

      IF (p_category_set_id IS NOT NULL) THEN
        IF (l_stmt1 IS NOT NULL) THEN
          l_stmt1 := l_stmt1 || ' AND itemcat.category_set_id = '
                     || p_category_set_id;
        ELSE
          l_stmt1 := ' itemcat.category_set_id = ' || p_category_set_id;
        END IF;
      END IF;

      IF (l_stmt1 IS NOT NULL) THEN
        l_stmt :=   l_stmt || '  AND ';
        l_stmt :=   l_stmt || '     inventory_item_id IN';
        l_stmt :=   l_stmt || '     (SELECT inventory_item_id';
        l_stmt :=   l_stmt || '      FROM   mtl_item_categories itemcat';
        l_stmt :=   l_stmt || '      WHERE ' || l_stmt1;
        l_stmt :=   l_stmt || '      AND    itemcat.organization_id = :3 )';
      END IF;

      IF l_stmt1 IS NOT NULL THEN
         EXECUTE IMMEDIATE l_stmt USING p_user_id, p_organization_id, p_organization_id;
      ELSE
         EXECUTE IMMEDIATE l_stmt USING p_user_id, p_organization_id;
      END IF;

  ELSE  -- if p_changed = 'N', delete items that are no longer assigned to the category/category set
      -- changed to dynamic sql to support either category or category set
      l_stmt :=  NULL;
      l_stmt := 'UPDATE csm_mtl_system_items_acc acc';
      l_stmt :=   l_stmt || ' SET counter = counter - 1';
      l_stmt :=   l_stmt || '  ,   last_update_date = SYSDATE';
      l_stmt :=   l_stmt || '  ,   last_updated_by = 1';
      l_stmt :=   l_stmt || '  WHERE user_id = :1';
      l_stmt :=   l_stmt || '  AND organization_id = :2';

      IF (p_category_id IS NOT NULL) THEN
        l_stmt1 := ' itemcat.category_id = ' || p_category_id;
      END IF;

      IF (p_category_set_id IS NOT NULL) THEN
        IF (l_stmt1 IS NOT NULL) THEN
          l_stmt1 := l_stmt1 || ' AND itemcat.category_set_id = '
                     || p_category_set_id;
        ELSE
          l_stmt1 := ' itemcat.category_set_id = ' || p_category_set_id;
        END IF;
      END IF;

      IF (l_stmt1 IS NOT NULL) THEN
        l_stmt :=   l_stmt || '  AND NOT EXISTS ';
        l_stmt :=   l_stmt || ' (SELECT 1';
        l_stmt :=   l_stmt || '  FROM   mtl_item_categories itemcat';
        l_stmt :=   l_stmt || '  WHERE ' || l_stmt1;
        l_stmt :=   l_stmt || '  AND    itemcat.organization_id = :3 ';
        l_stmt :=   l_stmt || '  AND    acc.inventory_item_id = itemcat.inventory_item_id) ';
  	    l_stmt :=   l_stmt || '  AND NOT EXISTS  ';
        l_stmt :=   l_stmt || '  (SELECT 1';
        l_stmt :=   l_stmt || '  FROM csm_incidents_all_acc sr_acc, ';
        l_stmt :=   l_stmt || '       cs_incidents_all_b sr ';
        l_stmt :=   l_stmt || '  WHERE sr_acc.incident_id = sr.incident_id ';
        l_stmt :=   l_stmt || '  AND  sr_acc.user_id = :4 ';
        l_stmt :=   l_stmt || '  AND acc.inventory_item_id = sr.inventory_item_id )';

        EXECUTE IMMEDIATE l_stmt USING p_user_id, p_organization_id, p_organization_id, p_user_id;

        -- bulk collect all items eligible for delete
        l_tab_access_id.DELETE;
        l_tab_user_id.DELETE;

        SELECT access_id, user_id
        BULK COLLECT INTO l_tab_access_id, l_tab_user_id
        FROM csm_mtl_system_items_acc acc
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
                  DELETE FROM csm_mtl_system_items_acc WHERE access_id = l_tab_access_id(i);
        END IF;
      ELSE
         -- do not decrement as category/category set profile is not changed
         l_stmt := NULL;
      END IF;
  END IF; -- end of if p_changed ='Y'

  -- download new items if not existing
  IF  (p_category_id IS NULL AND p_category_set_id IS NULL) THEN
      OPEN c_items(b_user_id=>p_user_id, b_organization_id=>p_organization_id,
                   b_changed=>p_changed, b_last_run_date=>p_last_run_date);
      LOOP
        l_tab_access_id.DELETE;
        l_inventory_item_id_tbl.DELETE;
        l_organization_id_tbl.DELETE;
        l_tab_user_id.DELETE;

      FETCH c_items BULK COLLECT INTO l_tab_access_id, l_inventory_item_id_tbl,
      	                              l_organization_id_tbl, l_tab_user_id LIMIT 1000;
      EXIT WHEN l_tab_access_id.COUNT = 0;

      IF l_tab_access_id.COUNT > 0 THEN
         CSM_UTIL_PKG.LOG('Bulk inserted ' || l_tab_access_id.count
                         || ' records into csm_mtl_system_items_acc for user ' || p_user_id ,
                         'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.INSERT_MTL_SYSTEM_ITEMS',FND_LOG.LEVEL_EVENT);

         FORALL i IN 1..l_tab_access_id.COUNT
           INSERT INTO csm_mtl_system_items_acc(access_id, user_id, inventory_item_id, organization_id, counter,
                       created_by, creation_date, last_updated_by, last_update_date, last_update_login)
                VALUES (l_tab_access_id(i), p_user_id, l_inventory_item_id_tbl(i), l_organization_id_tbl(i), 1,
                       fnd_global.user_id, l_run_date, fnd_global.user_id, l_run_date, fnd_global.login_id);

           /*** push to oLite using asg_download ***/
           -- do bulk makedirty
            l_markdirty := asg_download.mark_dirty(
                P_PUB_ITEM         => g_pub_item
              , p_accessList       => l_tab_access_id
              , p_userid_list      => l_tab_user_id
              , p_dml_type         => 'I'
              , P_TIMESTAMP        => l_run_date
              );
      END IF; -- end of l_tab_access_id.count > 0
      COMMIT;

      END LOOP;
      CLOSE c_items;

 -- Category is not null and Cat set is null
  ELSIF (p_category_id IS NOT NULL AND p_category_set_id IS NULL) THEN
     OPEN c_items_Cat(b_user_id=>p_user_id, b_organization_id=>p_organization_id,
                       b_changed=>p_changed, b_last_run_date=>p_last_run_date,
                       b_category_id=>p_category_id);
     LOOP
        l_tab_access_id.DELETE;
        l_inventory_item_id_tbl.DELETE;
        l_organization_id_tbl.DELETE;
        l_tab_user_id.DELETE;

     FETCH c_items_Cat BULK COLLECT INTO l_tab_access_id, l_inventory_item_id_tbl,
                        	                l_organization_id_tbl, l_tab_user_id LIMIT 1000;
     EXIT WHEN l_tab_access_id.COUNT = 0;

     IF l_tab_access_id.COUNT > 0 THEN
        CSM_UTIL_PKG.LOG('Bulk inserted ' || l_tab_access_id.count
                         || ' records into csm_mtl_system_items_acc for user ' || p_user_id ,
                         'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.INSERT_MTL_SYSTEM_ITEMS',FND_LOG.LEVEL_EVENT);

         FORALL i IN 1..l_tab_access_id.COUNT
           INSERT INTO csm_mtl_system_items_acc(access_id, user_id, inventory_item_id, organization_id, counter,
                       created_by, creation_date, last_updated_by, last_update_date, last_update_login)
                VALUES (l_tab_access_id(i), p_user_id, l_inventory_item_id_tbl(i), l_organization_id_tbl(i), 1,
                       fnd_global.user_id, l_run_date, fnd_global.user_id, l_run_date, fnd_global.login_id);

           /*** push to oLite using asg_download ***/
           -- do bulk makedirty
            l_markdirty := asg_download.mark_dirty(
                P_PUB_ITEM         => g_pub_item
              , p_accessList       => l_tab_access_id
              , p_userid_list      => l_tab_user_id
              , p_dml_type         => 'I'
              , P_TIMESTAMP        => l_run_date
              );

      END IF; -- end of l_tab_access_id.count > 0
      COMMIT;
      END LOOP;
      CLOSE c_items_Cat;

  -- Category is null and Cat Set is not null
  ELSIF (p_category_id IS NULL AND p_category_set_id IS NOT NULL) THEN
     OPEN c_items_Cat_Set(b_user_id=>p_user_id, b_organization_id=>p_organization_id,
                       b_changed=>p_changed, b_last_run_date=>p_last_run_date,
                       b_category_set_id=>p_category_set_id);
     LOOP
        l_tab_access_id.DELETE;
        l_inventory_item_id_tbl.DELETE;
        l_organization_id_tbl.DELETE;
        l_tab_user_id.DELETE;

     FETCH c_items_Cat_Set BULK COLLECT INTO l_tab_access_id, l_inventory_item_id_tbl,
                        	                l_organization_id_tbl, l_tab_user_id LIMIT 1000;
     EXIT WHEN l_tab_access_id.COUNT = 0;

     IF l_tab_access_id.COUNT > 0 THEN
        CSM_UTIL_PKG.LOG('Bulk inserted ' || l_tab_access_id.count
                         || ' records into csm_mtl_system_items_acc for user ' || p_user_id ,
                         'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.INSERT_MTL_SYSTEM_ITEMS',FND_LOG.LEVEL_EVENT);

         FORALL i IN 1..l_tab_access_id.COUNT
           INSERT INTO csm_mtl_system_items_acc(access_id, user_id, inventory_item_id, organization_id, counter,
                       created_by, creation_date, last_updated_by, last_update_date, last_update_login)
                VALUES (l_tab_access_id(i), p_user_id, l_inventory_item_id_tbl(i), l_organization_id_tbl(i), 1,
                       fnd_global.user_id, l_run_date, fnd_global.user_id, l_run_date, fnd_global.login_id);

           /*** push to oLite using asg_download ***/
           -- do bulk makedirty
            l_markdirty := asg_download.mark_dirty(
                P_PUB_ITEM         => g_pub_item
              , p_accessList       => l_tab_access_id
              , p_userid_list      => l_tab_user_id
              , p_dml_type         => 'I'
              , P_TIMESTAMP        => l_run_date
              );

      END IF; -- end of l_tab_access_id.count > 0
      COMMIT;
      END LOOP;
      CLOSE c_items_Cat_Set;

 -- Both Category and Category set are not null
 ELSIF (p_category_id IS NOT NULL AND p_category_set_id IS NOT NULL) THEN
    OPEN c_items_Cat_Set_Cat(b_user_id=>p_user_id, b_organization_id=>p_organization_id,
                             b_changed=>p_changed, b_last_run_date=>p_last_run_date,
                             b_category_id=>p_category_id, b_category_set_id=>p_category_set_id);
    LOOP
        l_tab_access_id.DELETE;
        l_inventory_item_id_tbl.DELETE;
        l_organization_id_tbl.DELETE;
        l_tab_user_id.DELETE;

     FETCH c_items_Cat_Set_Cat BULK COLLECT INTO l_tab_access_id, l_inventory_item_id_tbl,
            	                         l_organization_id_tbl, l_tab_user_id LIMIT 1000;
     EXIT WHEN l_tab_access_id.COUNT = 0;

     IF l_tab_access_id.COUNT > 0 THEN
        CSM_UTIL_PKG.LOG('Bulk inserted ' || l_tab_access_id.count
                         || ' records into csm_mtl_system_items_acc for user ' || p_user_id ,
                         'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.INSERT_MTL_SYSTEM_ITEMS',FND_LOG.LEVEL_EVENT);

         FORALL i IN 1..l_tab_access_id.COUNT
           INSERT INTO csm_mtl_system_items_acc(access_id, user_id, inventory_item_id, organization_id, counter,
                       created_by, creation_date, last_updated_by, last_update_date, last_update_login)
                VALUES (l_tab_access_id(i), p_user_id, l_inventory_item_id_tbl(i), l_organization_id_tbl(i), 1,
                       fnd_global.user_id, l_run_date, fnd_global.user_id, l_run_date, fnd_global.login_id);

           /*** push to oLite using asg_download ***/
           -- do bulk makedirty
            l_markdirty := asg_download.mark_dirty(
                P_PUB_ITEM         => g_pub_item
              , p_accessList       => l_tab_access_id
              , p_userid_list      => l_tab_user_id
              , p_dml_type         => 'I'
              , P_TIMESTAMP        => l_run_date
              );

      END IF; -- end of l_tab_access_id.count > 0
      COMMIT;
      END LOOP;
      CLOSE c_items_Cat_Set_Cat;

   END IF;

 CSM_UTIL_PKG.LOG('Leaving CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.INSERT_MTL_SYSTEM_ITEMS ',
                         'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.INSERT_MTL_SYSTEM_ITEMS',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  WHEN others THEN
     l_sqlerrno := TO_CHAR(SQLCODE);
     l_sqlerrmsg := SUBSTR(SQLERRM, 1,2000);
     l_error_msg := ' Exception in  INSERT_MTL_SYSTEM_ITEMS for user_id :'
                       || to_char(p_user_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
     CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.INSERT_MTL_SYSTEM_ITEMS',FND_LOG.LEVEL_EXCEPTION);
     RAISE;
END INSERT_MTL_SYSTEM_ITEMS;

PROCEDURE update_mtl_system_items(p_last_run_date IN DATE)
IS
l_sqlerrno      VARCHAR2(20);
l_sqlerrmsg 	VARCHAR2(4000);
l_error_msg     VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_run_date 		DATE;
l_tab_access_id asg_download.access_list;
l_tab_user_id 	asg_download.user_list;
l_markdirty 	BOOLEAN;
l_max_last_update_date_b  DATE;
l_max_last_update_date_tl DATE;

CURSOR c_changed( b_last_date DATE)
IS
SELECT acc.access_id, acc.user_id
FROM   csm_mtl_system_items_acc acc, mtl_system_items_b msi
WHERE  msi.inventory_item_id = acc.inventory_item_id
AND    msi.organization_id   = acc.organization_id
AND    (msi.last_update_date >= b_last_date);

BEGIN
 CSM_UTIL_PKG.LOG('Entering CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.UPDATE_MTL_SYSTEM_ITEMS ',
                         'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.UPDATE_MTL_SYSTEM_ITEMS',FND_LOG.LEVEL_PROCEDURE);

 l_run_date := SYSDATE;

    /* This portion of code assumes indexes on last_update_date on MTL_SYSTEM_ITEMS_B */
    /* , MTL_SYSTEM_ITEMS_TL which were custom created */
    SELECT MAX(last_update_date) INTO l_max_last_update_date_b
    FROM mtl_system_items_b;
    IF( l_max_last_update_date_b < p_last_run_date) THEN
       SELECT MAX(last_update_date) INTO l_max_last_update_date_tl
       FROM mtl_system_items_tl;
       IF(l_max_last_update_date_tl < p_last_run_date) THEN
            -- No updates
            CSM_UTIL_PKG.LOG('Leaving UPDATE_MTL_SYSTEM_ITEMS - No Updates ',
                         'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.UPDATE_MTL_SYSTEM_ITEMS',FND_LOG.LEVEL_PROCEDURE);
            RETURN;
       END IF;
    END IF;

    OPEN c_changed( p_last_run_date);
    LOOP
       l_tab_access_id.DELETE;
       l_tab_user_id.DELETE;

    FETCH c_changed BULK COLLECT INTO l_tab_access_id, l_tab_user_id LIMIT 1000;
    EXIT WHEN l_tab_access_id.COUNT = 0;

    IF l_tab_access_id.COUNT > 0 THEN
        CSM_UTIL_PKG.LOG(l_tab_access_id.COUNT || ' records sent to olite for updating csm_mtl_system_items',
                         'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.UPDATE_MTL_SYSTEM_ITEMS',FND_LOG.LEVEL_EVENT);

        -- do bulk makedirty
        l_markdirty := asg_download.mark_dirty(
                P_PUB_ITEM         => g_pub_item
              , p_accessList       => l_tab_access_id
              , p_userid_list      => l_tab_user_id
              , p_dml_type         => 'U'
              , P_TIMESTAMP        => l_run_date
              );
    END IF;
    COMMIT;
    END LOOP;
    CLOSE c_changed;

 CSM_UTIL_PKG.LOG('Leaving CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.UPDATE_MTL_SYSTEM_ITEMS ',
                         'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.UPDATE_MTL_SYSTEM_ITEMS',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := TO_CHAR(SQLCODE);
        l_sqlerrmsg := SUBSTR(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  UPDATE_MTL_SYSTEM_ITEMS :' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.UPDATE_MTL_SYSTEM_ITEMS',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END UPDATE_MTL_SYSTEM_ITEMS;

PROCEDURE delete_mtl_system_items(p_user_id IN NUMBER,
                                  p_organization_id IN NUMBER,
                                  p_category_set_id IN NUMBER,
                                  p_category_id IN NUMBER)
IS
l_sqlerrno 		 VARCHAR2(20);
l_sqlerrmsg 	 VARCHAR2(4000);
l_error_msg 	 VARCHAR2(4000);
l_return_status  VARCHAR2(2000);
l_stmt  		 VARCHAR2(4000);
l_stmt1			 VARCHAR2(4000);
l_markdirty 	 BOOLEAN;
l_run_date 		 DATE;
l_tab_access_id  ASG_DOWNLOAD.ACCESS_LIST;
l_tab_user_id 	 ASG_DOWNLOAD.USER_LIST;

BEGIN
 CSM_UTIL_PKG.LOG('Entering CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.DELETE_MTL_SYSTEM_ITEMS ',
                         'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.DELETE_MTL_SYSTEM_ITEMS',FND_LOG.LEVEL_PROCEDURE);

 l_run_date := SYSDATE;

 l_tab_access_id.DELETE;

    l_stmt := 'UPDATE csm_mtl_system_items_acc acc';
    l_stmt :=   l_stmt || ' SET COUNTER = COUNTER - 1';
    l_stmt :=   l_stmt || '  ,   LAST_UPDATE_DATE = SYSDATE';
    l_stmt :=   l_stmt || '  ,   last_updated_by = nvl(fnd_global.user_id, 1)';
    l_stmt :=   l_stmt || '  WHERE USER_ID = :1';
    l_stmt :=   l_stmt || '  AND organization_id = :2';

    IF (p_category_id IS NOT NULL) THEN
  	l_stmt1 := ' itemcat.category_id = ' || p_category_id;
    END IF;

    IF (p_category_set_id IS NOT NULL) THEN
  	IF (l_stmt1 IS NOT NULL) THEN
  		l_stmt1 := l_stmt1 || ' AND itemcat.category_set_id = '
                                   || p_category_set_id;
  	ELSE
  		l_stmt1 := ' itemcat.category_set_id = ' || p_category_set_id;
  	END IF;
    END IF;

    IF (l_stmt1 IS NOT NULL) THEN
      l_stmt :=   l_stmt || '  AND EXISTS (';
  	  l_stmt :=   l_stmt || '  SELECT 1 ';
  	  l_stmt :=   l_stmt || '  FROM   mtl_item_categories itemcat';
  	  l_stmt :=   l_stmt || '  WHERE ' || l_stmt1;
  	  l_stmt :=   l_stmt || '  AND    itemcat.organization_id = :3 ';
  	  l_stmt :=   l_stmt || '  AND    acc.inventory_item_id = itemcat.inventory_item_id )';
    END IF;

    IF (l_stmt1 IS NOT NULL) THEN
      EXECUTE IMMEDIATE l_stmt USING p_user_id, p_organization_id, p_organization_id;
    ELSE
      EXECUTE IMMEDIATE l_stmt USING p_user_id, p_organization_id;
    END IF;

    -- bulk collect all items eligible for delete
    l_tab_access_id.DELETE;
    l_tab_user_id.DELETE;

    SELECT access_id, user_id
    BULK COLLECT INTO l_tab_access_id, l_tab_user_id
    FROM csm_mtl_system_items_acc acc
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
                 DELETE FROM csm_mtl_system_items_acc WHERE access_id = l_tab_access_id(i);
    END IF;

 CSM_UTIL_PKG.LOG('Leaving CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.DELETE_MTL_SYSTEM_ITEMS ',
                         'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.DELETE_MTL_SYSTEM_ITEMS',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  WHEN others THEN
     l_sqlerrno := TO_CHAR(SQLCODE);
     l_sqlerrmsg := SUBSTR(SQLERRM, 1,2000);
     CSM_UTIL_PKG.LOG('Exception in CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.DELETE_MTL_SYSTEM_ITEMS: ' || l_sqlerrno || ':' || l_sqlerrmsg,
                         'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.DELETE_MTL_SYSTEM_ITEMS',FND_LOG.LEVEL_EXCEPTION);
     RAISE;
END DELETE_MTL_SYSTEM_ITEMS;

PROCEDURE concurrent_process_user(p_user_id IN NUMBER,
                                  p_organization_id IN NUMBER,
                                  p_category_set_id IN NUMBER,
                                  p_category_id IN NUMBER,
                                  p_last_run_date IN DATE)
IS
l_sqlerrno 			 VARCHAR2(20);
l_sqlerrmsg 		 VARCHAR2(4000);
l_error_msg 		 VARCHAR2(4000);
l_return_status 	 VARCHAR2(2000);
l_pre_cat_filter 	 BOOLEAN; -- TRUE when category filter was active previously
l_post_cat_filter    BOOLEAN; -- TRUE when category filter is active now
l_cat_filter_changed BOOLEAN; -- TRUE when category filter changed

CURSOR c_org(b_user_id NUMBER)
IS
SELECT organization_id, category_set_id, category_id
FROM csm_user_inventory_org
WHERE user_id = b_user_id
FOR UPDATE;

r_org c_org%ROWTYPE;

BEGIN
 CSM_UTIL_PKG.LOG('Entering CONCURRENT_PROCESS_USER for user_id: ' || TO_CHAR(p_user_id),
                         'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.CONCURRENT_PROCESS_USER',FND_LOG.LEVEL_PROCEDURE);

 /* Get old profile settings */
 OPEN c_org( p_user_id );
 FETCH c_org INTO r_org;
 IF c_org%NOTFOUND THEN -- should not occur
   CSM_UTIL_PKG.LOG('Profile record not found in csm_user_inventory_org for user_id: ' || TO_CHAR(p_user_id)
                          || ' - Inserting all mtl_system_items',
                         'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.CONCURRENT_PROCESS_USER',FND_LOG.LEVEL_PROCEDURE);
   get_new_user_mtl_system_items(p_user_id=>p_user_id, p_organization_id=>p_organization_id,
                                 p_category_set_id=>p_category_set_id, p_category_id=>p_category_id);

   INSERT INTO csm_user_inventory_org (
      user_id, organization_id, last_update_date, last_updated_by,
      creation_date, created_by, category_set_id, category_id )
   VALUES (
      p_user_id, p_organization_id, SYSDATE, 1, SYSDATE, 1,
      p_category_set_id, p_category_id );

 ELSE
      l_pre_cat_filter  := FALSE;
      l_post_cat_filter := FALSE;

      IF (( r_org.category_set_id IS NOT NULL ) OR
          ( r_org.category_id IS NOT NULL)) THEN
        l_pre_cat_filter := TRUE;
      END IF;

      IF (( p_category_set_id IS NOT NULL ) OR
          ( p_category_id IS NOT NULL)) THEN
        l_post_cat_filter := TRUE;
      END IF;

      /*** did category filter change from active -> inactive or vice versa ***/
      l_cat_filter_changed := FALSE;
      IF l_pre_cat_filter <> l_post_cat_filter THEN
        /*** yes -> set boolean ***/
        l_cat_filter_changed := TRUE;
      ELSE
        /*** no -> is filter active ***/
        IF l_post_cat_filter THEN
          /*** yes -> did category or category set change? ***/
          IF NVL(r_org.category_set_id, 0) <>  NVL(p_category_set_id, 0)
           OR NVL(r_org.category_id, 0) <> NVL(p_category_id, 0) THEN
            l_cat_filter_changed := TRUE;
          END IF;
        END IF;
      END IF;

      IF NVL(p_organization_id, -1) <>  NVL(r_org.organization_id, -1)
         OR l_cat_filter_changed THEN
           CSM_UTIL_PKG.LOG('Deleting records for old profile settings for user_id: ' || TO_CHAR(p_user_id),
                            'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.CONCURRENT_PROCESS_USER',FND_LOG.LEVEL_PROCEDURE);

           -- delete labor/expense items only and then re-insert for the new orgif org changes
           IF NVL(p_organization_id, -1) <> NVL(r_org.organization_id,-1) THEN
                  csm_system_item_event_pkg.delete_system_items(p_user_id=>p_user_id,
                                                                p_organization_id=>r_org.organization_id);

                  -- download new labor/expense items for the new org
                  csm_system_item_event_pkg.get_new_user_system_items(p_user_id=>p_user_id);
           END IF;

           delete_mtl_system_items(p_user_id=>p_user_id,
                                   p_organization_id=>r_org.organization_id,
                                   p_category_set_id=>r_org.category_set_id,
                                   p_category_id=>r_org.category_id);

           CSM_UTIL_PKG.LOG('Inserting records for new profile settings for user_id: ' || TO_CHAR(p_user_id),
                            'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.CONCURRENT_PROCESS_USER',FND_LOG.LEVEL_PROCEDURE);

           insert_mtl_system_items(p_user_id=>p_user_id,
                           p_organization_id=>p_organization_id,
                           p_category_set_id=>p_category_set_id,
                           p_category_id=>p_category_id,
                           p_last_run_date=>NULL,
                           p_changed=>'Y');

           CSM_UTIL_PKG.LOG('Update csm_user_inventory_org with new profile settings for user_id: ' || TO_CHAR(p_user_id),
                            'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.CONCURRENT_PROCESS_USER',FND_LOG.LEVEL_PROCEDURE);

           UPDATE csm_user_inventory_org
           SET organization_id = p_organization_id
           ,   category_set_id = p_category_set_id
           ,   category_id     = p_category_id
           ,   last_update_date = SYSDATE
           WHERE CURRENT OF c_org;

      ELSE
         -- profiles are the same
         -- get any new changes
           CSM_UTIL_PKG.LOG('Getting new items for same profile settings for user_id: ' || TO_CHAR(p_user_id),
                            'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.CONCURRENT_PROCESS_USER',FND_LOG.LEVEL_PROCEDURE);

           insert_mtl_system_items(p_user_id=>p_user_id,
                           p_organization_id=>p_organization_id,
                           p_category_set_id=>p_category_set_id,
                           p_category_id=>p_category_id,
                           p_last_run_date=>p_last_run_date,
                           p_changed=>'N');
      END IF;
 END IF;
 CLOSE c_org;

 CSM_UTIL_PKG.LOG('Leaving CONCURRENT_PROCESS_USER for user_id: ' || TO_CHAR(p_user_id),
                         'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.CONCURRENT_PROCESS_USER',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := TO_CHAR(SQLCODE);
        l_sqlerrmsg := SUBSTR(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  concurrent_process_user for user_id :'
                       || TO_CHAR(p_user_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'csm_mtl_system_items_event_pkg.concurrent_process_user',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END CONCURRENT_PROCESS_USER;

PROCEDURE Refresh_mtl_system_items_acc(p_status OUT NOCOPY VARCHAR2,
                                       p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_prog_update_date      jtm_con_request_data.last_run_date%TYPE;
l_all_omfs_user_list  	asg_download.user_list;
l_null_omfs_user_list 	asg_download.user_list;
l_user_id 			    fnd_user.user_id%TYPE;
l_user_organization_id  mtl_system_items.organization_id%TYPE;
l_user_category_set_id  mtl_category_sets.category_set_id%TYPE;
l_user_category_id 		mtl_categories.category_id%TYPE;
l_run_date  			DATE;
l_sqlerrno  			VARCHAR2(20);
l_sqlerrmsg 			VARCHAR2(2000);

CURSOR l_last_run_date_csr
IS
SELECT NVL(last_run_date, TO_DATE('1','J'))
FROM jtm_con_request_data
WHERE package_name = 'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG'
AND procedure_name = 'REFRESH_MTL_SYSTEM_ITEMS_ACC';

BEGIN
 CSM_UTIL_PKG.LOG('Entering CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.Refresh_mtl_system_items_acc ',
                         'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.Refresh_mtl_system_items_acc',FND_LOG.LEVEL_PROCEDURE);

 l_run_date := SYSDATE;

 -- get last conc program update date
 OPEN  l_last_run_date_csr;
 FETCH l_last_run_date_csr INTO l_prog_update_date;
 CLOSE l_last_run_date_csr;

 -- do an update for existing records
 update_mtl_system_items(p_last_run_date => l_prog_update_date);
 COMMIT;

  -- get user list of all omfs users
 l_all_omfs_user_list := l_null_omfs_user_list;
 l_all_omfs_user_list := csm_util_pkg.get_all_omfs_palm_user_list;

 FOR i IN 1..l_all_omfs_user_list.COUNT LOOP
   l_user_id := l_all_omfs_user_list(i);
   l_user_organization_id := csm_profile_pkg.get_organization_id(l_user_id);
   l_user_category_set_id := csm_profile_pkg.get_category_set_id(l_user_id);
   l_user_category_id := csm_profile_pkg.get_category_id(l_user_id);

   concurrent_process_user(p_user_id=>l_user_id,
                           p_organization_id=>l_user_organization_id,
                           p_category_set_id=>l_user_category_set_id,
                           p_category_id=>l_user_category_id,
                           p_last_run_date=>l_prog_update_date);

 END LOOP;

 -- update last_run_date
 UPDATE jtm_con_request_data
 SET last_run_date = l_run_date
 WHERE package_name = 'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG'
 AND procedure_name = 'REFRESH_MTL_SYSTEM_ITEMS_ACC';

 COMMIT;

 p_status := 'FINE';
 p_message :=  'csm_mtl_system_items_event_pkg.refresh_system_items executed successfully';

 CSM_UTIL_PKG.LOG('Leaving csm_mtl_system_items_event_pkg.Refresh_mtl_system_items_acc ',
                         'csm_mtl_system_items_event_pkg.Refresh_mtl_system_items_acc',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  WHEN others THEN
     l_sqlerrno := TO_CHAR(SQLCODE);
     l_sqlerrmsg := SUBSTR(SQLERRM, 1,2000);
     p_status := 'ERROR';
     p_message := 'Error in CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.REFRESH_MTL_SYSTEM_ITEMS_ACC: ' || l_sqlerrno || ':' || l_sqlerrmsg;
     ROLLBACK;
     csm_util_pkg.log('CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.REFRESH_MTL_SYSTEM_ITEMS_ACC ERROR : ' || l_sqlerrno || ':' || l_sqlerrmsg);
END REFRESH_MTL_SYSTEM_ITEMS_ACC;

PROCEDURE get_new_user_mtl_system_items(p_user_id IN NUMBER, p_organization_id IN NUMBER,
                                        p_category_set_id IN NUMBER, p_category_id IN NUMBER)
IS
l_sqlerrno 		VARCHAR2(20);
l_sqlerrmsg 	VARCHAR2(4000);
l_error_msg     VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
 CSM_UTIL_PKG.LOG('Entering CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.get_new_user_mtl_system_items ',
                         'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.get_new_user_mtl_system_items',FND_LOG.LEVEL_PROCEDURE);

 insert_mtl_system_items(p_user_id=>p_user_id,
                         p_organization_id=>p_organization_id,
                         p_category_set_id=>p_category_set_id,
                         p_category_id=>p_category_id,
                         p_last_run_date=>NULL,
                         p_changed=>'N'); -- new user, no profiles are changed

 CSM_UTIL_PKG.LOG('Leaving CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.get_new_user_mtl_system_items ',
                         'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.get_new_user_mtl_system_items',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  WHEN others THEN
     l_sqlerrno := TO_CHAR(SQLCODE);
     l_sqlerrmsg := SUBSTR(SQLERRM, 1,2000);
     l_error_msg := ' Exception in  get_new_user_mtl_system_items for user_id :'
                       || to_char(p_user_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
     CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.get_new_user_mtl_system_items',FND_LOG.LEVEL_EXCEPTION);
     RAISE;
END get_new_user_mtl_system_items;

PROCEDURE mtl_system_items_acc_i(p_inventory_item_id IN NUMBER,
	    	                     p_organization_id IN NUMBER,
		                         p_user_id IN NUMBER,
                                 p_error_msg     OUT NOCOPY    VARCHAR2,
                                 x_return_status IN OUT NOCOPY VARCHAR2)
IS
BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;
 CSM_UTIL_PKG.LOG('Entering CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.MTL_SYSTEM_ITEMS_ACC_I ',
                         'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.MTL_SYSTEM_ITEMS_ACC_I',FND_LOG.LEVEL_PROCEDURE);

 IF p_inventory_item_id IS NOT NULL AND p_organization_id IS NOT NULL THEN
     CSM_ACC_PKG.Insert_Acc
    ( P_PUBLICATION_ITEM_NAMES => g_mtl_sys_items_pubi_name
     ,P_ACC_TABLE_NAME         => g_mtl_sys_items_acc_table_name
     ,P_SEQ_NAME               => g_mtl_sys_items_seq_name
     ,P_PK1_NAME               => g_mtl_sys_items_pk1_name
     ,P_PK1_NUM_VALUE          => p_inventory_item_id
     ,P_PK2_NAME               => g_mtl_sys_items_pk2_name
     ,P_PK2_NUM_VALUE          => p_organization_id
     ,P_USER_ID                => p_user_id
    );

 END IF;

  p_error_msg := 'SUCCESS';
  CSM_UTIL_PKG.LOG('Leaving CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.MTL_SYSTEM_ITEMS_ACC_I ',
                         'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.MTL_SYSTEM_ITEMS_ACC_I',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN others THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       p_error_msg := ' FAILED MTL_SYSTEM_ITEMS_ACC_I INVENTORY_ITEM_ID: ' || to_char(p_inventory_item_id) || SUBSTR(SQLERRM,1,2000);
       CSM_UTIL_PKG.LOG(p_error_msg, 'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.MTL_SYSTEM_ITEMS_ACC_I',FND_LOG.LEVEL_EXCEPTION);
       RAISE;
END MTL_SYSTEM_ITEMS_ACC_I;

PROCEDURE mtl_system_items_acc_d(p_inventory_item_id IN NUMBER,
	    	                     p_organization_id IN NUMBER,
		                         p_user_id IN NUMBER,
                                 p_error_msg     OUT NOCOPY    VARCHAR2,
                                 x_return_status IN OUT NOCOPY VARCHAR2)
IS
BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;
 CSM_UTIL_PKG.LOG('Entering CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.MTL_SYSTEM_ITEMS_ACC_D',
                         'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.MTL_SYSTEM_ITEMS_ACC_D',FND_LOG.LEVEL_PROCEDURE);

 IF p_inventory_item_id IS NOT NULL AND p_organization_id IS NOT NULL THEN
    CSM_ACC_PKG.Delete_Acc
   ( P_PUBLICATION_ITEM_NAMES => g_mtl_sys_items_pubi_name
   ,P_ACC_TABLE_NAME         => g_mtl_sys_items_acc_table_name
   ,P_PK1_NAME               => g_mtl_sys_items_pk1_name
   ,P_PK1_NUM_VALUE          => p_inventory_item_id
   ,P_PK2_NAME               => g_mtl_sys_items_pk2_name
   ,P_PK2_NUM_VALUE          => p_organization_id
   ,P_USER_ID                => p_user_id
   );
 END IF;

  p_error_msg := 'SUCCESS';
  CSM_UTIL_PKG.LOG('Leaving CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.MTL_SYSTEM_ITEMS_ACC_D ',
                         'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.MTL_SYSTEM_ITEMS_ACC_D',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN others THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       p_error_msg := ' FAILED MTL_SYSTEM_ITEMS_ACC_D INVENTORY_ITEM_ID: ' || to_char(p_inventory_item_id) || SUBSTR(SQLERRM,1,2000);
       CSM_UTIL_PKG.LOG(p_error_msg, 'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG.MTL_SYSTEM_ITEMS_ACC_D',FND_LOG.LEVEL_EXCEPTION);
       RAISE;
END MTL_SYSTEM_ITEMS_ACC_D;

END CSM_MTL_SYSTEM_ITEMS_EVENT_PKG;

/
