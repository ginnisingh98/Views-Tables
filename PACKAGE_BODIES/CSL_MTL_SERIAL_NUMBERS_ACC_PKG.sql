--------------------------------------------------------
--  DDL for Package Body CSL_MTL_SERIAL_NUMBERS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_MTL_SERIAL_NUMBERS_ACC_PKG" AS
/* $Header: cslsnacb.pls 115.6 2004/09/30 22:10:00 appldev ship $ */

/*** Globals ***/
g_debug_level           NUMBER; -- debug level

g_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('MTL_SERIAL_NUMBERS');
g_table_name            CONSTANT VARCHAR2(30) := 'MTL_SERIAL_NUMBERS';



/**/
PROCEDURE INSERT_SERIAL_NUMBERS( p_resource_id IN NUMBER )
IS
 TYPE item_Tab   IS TABLE OF mtl_serial_numbers.inventory_item_id%TYPE INDEX BY BINARY_INTEGER;
 TYPE serial_Tab IS TABLE OF mtl_serial_numbers.serial_number%TYPE INDEX BY BINARY_INTEGER;

 sequences ASG_DOWNLOAD.ACCESS_LIST;
 resources ASG_DOWNLOAD.USER_LIST;
 items     item_Tab;
 serials   serial_Tab;

 l_dummy         BOOLEAN;

BEGIN
 /*** get debug level ***/
 g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Entering INSERT_SERIAL_NUMBERS'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
 END IF;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Inserting records for resource: '||p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
 END IF;

 /*Block insert every item from given subinventory/org not yet in acc table*/
 SELECT JTM_ACC_TABLE_S.NEXTVAL, INVENTORY_ITEM_ID, SERIAL_NUMBER, p_resource_id
 BULK COLLECT INTO sequences, items, serials, resources
 FROM MTL_SERIAL_NUMBERS
 WHERE CURRENT_STATUS IN (1,3)
 AND ( CURRENT_SUBINVENTORY_CODE, CURRENT_ORGANIZATION_ID ) IN (
     SELECT SUBINVENTORY_CODE
     ,      ORGANIZATION_ID
     FROM CSP_INV_LOC_ASSIGNMENTS
     WHERE RESOURCE_ID = p_resource_id
     AND RESOURCE_TYPE = 'RS_EMPLOYEE'
     AND SYSDATE BETWEEN NVL( EFFECTIVE_DATE_START, SYSDATE )
                     AND NVL( EFFECTIVE_DATE_END , SYSDATE ))
 AND ( INVENTORY_ITEM_ID, SERIAL_NUMBER ) NOT IN (
       SELECT INVENTORY_ITEM_ID, SERIAL_NUMBER
       FROM JTM_MTL_SERIAL_NUMBERS_ACC
       WHERE RESOURCE_ID = p_resource_id );

 IF sequences.COUNT > 0 THEN
  FORALL i IN sequences.FIRST..sequences.LAST
    INSERT INTO JTM_MTL_SERIAL_NUMBERS_ACC(
                ACCESS_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY
                , COUNTER, RESOURCE_ID, INVENTORY_ITEM_ID, SERIAL_NUMBER ) VALUES (
		sequences(i), sysdate, 1, sysdate, 1, 1, p_resource_id, items(i), serials(i));

  /*** 1 or more acc rows retrieved -> push to resource ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
     jtm_message_log_pkg.Log_Msg
     ( p_resource_id
      , g_table_name
      , 'Pushing ' || sequences.COUNT || ' inserted record(s) to resource: '||p_resource_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
     );
  END IF;
  l_dummy := asg_download.markdirty(
              P_PUB_ITEM     => g_publication_item_name(1)
            , P_ACCESSLIST   => sequences
            , P_RESOURCELIST => resources
            , P_DML_TYPE     => 'I'
            , P_TIMESTAMP    => SYSDATE
  );

 END IF;
 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Leaving INSERT_SERIAL_NUMBERS'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
 END IF;
EXCEPTION
 WHEN OTHERS THEN
  jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'INSERT_SERIAL_NUMBERS'||fnd_global.local_chr(10)||
      'Error: '||sqlerrm
    , JTM_HOOK_UTIL_PKG.g_debug_level_error);
  RAISE;
END INSERT_SERIAL_NUMBERS;

/**/
PROCEDURE DELETE_SERIAL_NUMBERS
IS
 l_tab_access_id   ASG_DOWNLOAD.ACCESS_LIST;
 l_tab_resource_id ASG_DOWNLOAD.USER_LIST;
 l_dummy BOOLEAN;

 /*Delete all serial numbers from acc table for which the assigned subinventory is no more,
   or for which the status has changed*/
 CURSOR c_remove IS
  /* Performance bug (3920090)fixing */
 /*
   SELECT acc.ACCESS_ID, acc.RESOURCE_ID
   FROM   JTM_MTL_SERIAL_NUMBERS_ACC acc
   ,      MTL_SERIAL_NUMBERS msn
   WHERE  msn.INVENTORY_ITEM_ID = acc.INVENTORY_ITEM_ID
   AND    msn.SERIAL_NUMBER = acc.SERIAL_NUMBER
   AND ( msn.CURRENT_SUBINVENTORY_CODE, msn.CURRENT_ORGANIZATION_ID ) NOT IN (
     SELECT SUBINVENTORY_CODE
     ,      ORGANIZATION_ID
     FROM CSP_INV_LOC_ASSIGNMENTS
     WHERE RESOURCE_ID = acc.RESOURCE_ID
     AND SYSDATE BETWEEN NVL( EFFECTIVE_DATE_START, SYSDATE )
                     AND NVL( EFFECTIVE_DATE_END , SYSDATE ))
  UNION
  SELECT acc.ACCESS_ID, acc.RESOURCE_ID
  FROM   JTM_MTL_SERIAL_NUMBERS_ACC acc
  ,      MTL_SERIAL_NUMBERS msn
  WHERE  msn.INVENTORY_ITEM_ID = acc.INVENTORY_ITEM_ID
  AND    msn.SERIAL_NUMBER = acc.SERIAL_NUMBER
  AND    msn.CURRENT_STATUS NOT IN (1,3);
*/
    SELECT /*+ INDEX (msn MTL_SERIAL_NUMBERS_U1) */
    acc.ACCESS_ID, acc.RESOURCE_ID
    FROM JTM_MTL_SERIAL_NUMBERS_ACC acc
    , MTL_SERIAL_NUMBERS msn
    WHERE msn.SERIAL_NUMBER = acc.SERIAL_NUMBER
    AND msn.INVENTORY_ITEM_ID = acc.INVENTORY_ITEM_ID
    AND (NOT EXISTS
    (SELECT 1
    FROM CSP_INV_LOC_ASSIGNMENTS cila
    WHERE cila.RESOURCE_ID = acc.RESOURCE_ID
    AND cila.organization_id = msn.current_organization_id
    AND cila.subinventory_code = msn.current_subinventory_code
    AND SYSDATE BETWEEN NVL( cila.EFFECTIVE_DATE_START, SYSDATE )
    AND NVL( cila.EFFECTIVE_DATE_END , SYSDATE)
    )
    OR msn.CURRENT_STATUS NOT IN (1,3)
    );

BEGIN
 /*** get debug level ***/
 g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'Entering DELETE_SERIAL_NUMBERS'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
 END IF;

 /*Delete not used records*/
 OPEN c_remove;
 FETCH c_remove BULK COLLECT INTO l_tab_access_id, l_tab_resource_id;
 /*Call oracle lite*/
 IF l_tab_access_id.COUNT > 0 THEN
  /*** 1 or more acc rows retrieved -> push to resource ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
     jtm_message_log_pkg.Log_Msg
     (  0
      , g_table_name
      , 'Deleting ' || l_tab_access_id.COUNT || ' invalid record(s)'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
     );
   END IF;
   /*** push to oLite using asg_download ***/
   l_dummy := asg_download.markdirty(
              P_PUB_ITEM     => g_publication_item_name(1)
            , P_ACCESSLIST   => l_tab_access_id
            , P_RESOURCELIST => l_tab_resource_id
            , P_DML_TYPE     => 'D'
            , P_TIMESTAMP    => SYSDATE
   );

   /*To avoid a mismatch only delete records which are marked dirty*/
   FORALL i IN l_tab_access_id.FIRST..l_tab_access_id.LAST
     DELETE JTM_MTL_SERIAL_NUMBERS_ACC
     WHERE ACCESS_ID = l_tab_access_id(i);
 END IF;
 CLOSE c_remove;

 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'Leaving DELETE_SERIAL_NUMBERS'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
 END IF;

EXCEPTION
 WHEN OTHERS THEN
  jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'DELETE_SERIAL_NUMBERS'||fnd_global.local_chr(10)||
      'Error: '||sqlerrm
    , JTM_HOOK_UTIL_PKG.g_debug_level_error);
  RAISE;
END DELETE_SERIAL_NUMBERS;

PROCEDURE UPDATE_SERIAL_NUMBERS( p_date IN DATE )
IS
 /*Get all existing and valid records which are changed*/
 CURSOR c_changed( b_date DATE ) IS
  SELECT acc.ACCESS_ID, acc.RESOURCE_ID
  FROM JTM_MTL_SERIAL_NUMBERS_ACC acc
  ,    MTL_SERIAL_NUMBERS msn
  WHERE msn.INVENTORY_ITEM_ID = acc.INVENTORY_ITEM_ID
  AND   msn.SERIAL_NUMBER = acc.SERIAL_NUMBER
  AND   msn.LAST_UPDATE_DATE  >= p_date
  AND ( msn.CURRENT_SUBINVENTORY_CODE, msn.CURRENT_ORGANIZATION_ID ) IN (
     SELECT SUBINVENTORY_CODE
     ,      ORGANIZATION_ID
     FROM CSP_INV_LOC_ASSIGNMENTS
     WHERE RESOURCE_ID = acc.RESOURCE_ID
     AND SYSDATE BETWEEN NVL( EFFECTIVE_DATE_START, SYSDATE )
                     AND NVL( EFFECTIVE_DATE_END , SYSDATE ));

 l_tab_access_id   ASG_DOWNLOAD.ACCESS_LIST;
 l_tab_resource_id ASG_DOWNLOAD.USER_LIST;
 l_dummy BOOLEAN;

BEGIN
 /*** get debug level ***/
 g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'Entering UPDATE_SERIAL_NUMBERS'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
 END IF;

 /*Fetch all changed system items that are in the acc table*/
 OPEN c_changed(  p_date );
 FETCH c_changed BULK COLLECT INTO l_tab_access_id, l_tab_resource_id;
 /*Call oracle lite*/
 IF l_tab_access_id.COUNT > 0 THEN
  /*** 1 or more acc rows retrieved -> push to resource ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
     jtm_message_log_pkg.Log_Msg
     ( 0
      , g_table_name
      , 'Updating ' || l_tab_access_id.COUNT || ' changed record(s)'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
     );
  END IF;
  l_dummy := asg_download.markdirty(
              P_PUB_ITEM     => g_publication_item_name(1)
            , P_ACCESSLIST   => l_tab_access_id
            , P_RESOURCELIST => l_tab_resource_id
            , P_DML_TYPE     => 'U'
            , P_TIMESTAMP    => SYSDATE
  );

 END IF;
 CLOSE c_changed;

 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'Leaving UPDATE_SERIAL_NUMBERS'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
 END IF;

EXCEPTION
 WHEN OTHERS THEN
  jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'UPDATE_SERIAL_NUMBERS'||fnd_global.local_chr(10)||
      'Error: '||sqlerrm
    , JTM_HOOK_UTIL_PKG.g_debug_level_error);
  RAISE;
END UPDATE_SERIAL_NUMBERS;

/**/
PROCEDURE CON_REQUEST_SERIAL_NUMBERS
IS
 PRAGMA AUTONOMOUS_TRANSACTION;
 l_date              DATE;
 l_subinventory_code VARCHAR2(30);

 /*** cursor retrieving list of resources subscribed to publication item ***/
  CURSOR c_mobile_users
   IS
    SELECT res.resource_id
    FROM  asg_pub                pub
    ,     asg_pub_responsibility pubresp
    ,     fnd_user_resp_groups   usrresp
    ,     fnd_user               usr
    ,     jtf_rs_resource_extns  res
    ,     asg_user               au
    WHERE res.resource_id = au.resource_id
    AND   pub.name = 'SERVICEL'
    AND   pub.enabled='Y'
    AND   pub.status='Y'
    AND   pub.pub_id = pubresp.pub_id
    AND   pubresp.responsibility_id = usrresp.responsibility_id
    AND   TRUNC(sysdate) BETWEEN TRUNC(NVL(usrresp.start_date,sysdate))
                             AND TRUNC(NVL(usrresp.end_date,sysdate))
    AND   usrresp.user_id = usr.user_id
    AND   TRUNC(sysdate) BETWEEN TRUNC(NVL(usr.start_date,sysdate))
                             AND TRUNC(NVL(usr.end_date,sysdate))
    AND   usr.user_id = res.user_id
    AND   TRUNC(sysdate) BETWEEN TRUNC(NVL(res.start_date_active,sysdate))
                             AND TRUNC(NVL(res.end_date_active,sysdate));

  /*** get the last run date of the concurent program ***/
  CURSOR  c_LastRundate
  IS
    select LAST_RUN_DATE
    from   JTM_CON_REQUEST_DATA
    where  package_name =  'CSL_MTL_SERIAL_NUMBERS_ACC_PKG'
    AND    procedure_name = 'CON_REQUEST_SERIAL_NUMBERS';

BEGIN
 /*** get debug level ***/
 g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'Entering CON_REQUEST_SERIAL_NUMBERS'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
 END IF;

 /*** First retrieve last run date of the conccurent program ***/
 OPEN  c_LastRundate;
 FETCH c_LastRundate  INTO l_date;
 IF c_LastRundate%FOUND THEN
   /*Record is seeded so program should run*/
   IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( 0
      , g_table_name
      , 'Updating LAST_RUN_DATE from '||l_date||' to '||sysdate
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
      );
   END IF;

   /*Update the last run date*/
   UPDATE JTM_CON_REQUEST_DATA
   SET LAST_RUN_DATE = SYSDATE
   WHERE package_name =  'CSL_MTL_SERIAL_NUMBERS_ACC_PKG'
   AND   procedure_name = 'CON_REQUEST_SERIAL_NUMBERS';

   COMMIT;
   /*First remove all records no longer required*/
   DELETE_SERIAL_NUMBERS;
   COMMIT;
   /*Second, check for updated serial numbers*/
   UPDATE_SERIAL_NUMBERS( l_date);
   COMMIT;
   FOR r_mobile_user IN c_mobile_users LOOP
    /*Third, insert all serial numbers that are not yet in the acc table*/
    INSERT_SERIAL_NUMBERS( r_mobile_user.resource_id );
    COMMIT;
   END LOOP;
 END IF;--c_LastRundate%FOUND
 CLOSE c_LastRundate;

 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'Leaving CON_REQUEST_SERIAL_NUMBERS'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
 END IF;
 COMMIT;
EXCEPTION
 WHEN OTHERS THEN
  jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'CON_REQUEST_SERIAL_NUMBERS'||fnd_global.local_chr(10)||
      'Error: '||sqlerrm
    , JTM_HOOK_UTIL_PKG.g_debug_level_error);
  ROLLBACK;
  RETURN;
END CON_REQUEST_SERIAL_NUMBERS;

END CSL_MTL_SERIAL_NUMBERS_ACC_PKG;

/
