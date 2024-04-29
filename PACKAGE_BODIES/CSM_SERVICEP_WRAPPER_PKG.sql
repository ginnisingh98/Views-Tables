--------------------------------------------------------
--  DDL for Package Body CSM_SERVICEP_WRAPPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_SERVICEP_WRAPPER_PKG" AS
/* $Header: csmuspwb.pls 120.6.12010000.5 2009/08/22 10:21:03 trajasek ship $ */

-- MODIFICATION HISTORY
-- Anurag     06/09/02    Created
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below

/*** Globals ***/
g_debug_level           NUMBER; -- debug level
g_object_name  CONSTANT VARCHAR2(30) := 'CSM_SERVICEP_WRAPPER_PKG';
--bug4233613
g_olite_schema CONSTANT VARCHAR2(15) := 'MOBILEADMIN';


PROCEDURE GET_ALL_DEFERRED_PUB_ITEMS(p_username IN VARCHAR2,
                                    p_tranid   IN NUMBER,
                                    p_pubname IN VARCHAR2,
                                    x_pubitems_tbl OUT NOCOPY asg_apply.vc2_tbl_type,
                                    x_return_status OUT NOCOPY VARCHAR2)
IS
l_defer_count pls_integer;
l_all_pubitems_tbl asg_apply.vc2_tbl_type;
l_null_pubitems_tbl asg_apply.vc2_tbl_type;
l_return_status varchar2(1);
l_dummy number;

CURSOR c_isdeferred(p_user_name VARCHAR2, p_tran_id NUMBER, p_pubitem VARCHAR2)
IS
SELECT 1
FROM asg_deferred_traninfo
WHERE device_user_name = p_user_name
AND  deferred_tran_id = p_tranid
AND  object_name = p_pubitem
;

BEGIN
  x_return_status := FND_API.G_RET_STS_ERROR;

  /** initialize tables **/
  l_all_pubitems_tbl := l_null_pubitems_tbl;
  x_pubitems_tbl := l_null_pubitems_tbl;

  /*** retrieve names of deferred dirty SERVICEP publication items ***/
  asg_apply.get_all_pub_items(p_username,
                              p_tranid,
                              'SERVICEP',
                              l_all_pubitems_tbl,
                              l_return_status);

  /*** successfully retrieved item names? ***/
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_all_pubitems_tbl.COUNT = 0 THEN
    NULL;
  ELSE
     l_defer_count := 0;
     FOR i IN 1..l_all_pubitems_tbl.count LOOP
        OPEN c_isdeferred(p_username,p_tranid, l_all_pubitems_tbl(i));
        FETCH c_isdeferred INTO l_dummy;
        IF c_isdeferred%FOUND THEN
           l_defer_count := l_defer_count + 1;
           x_pubitems_tbl(l_defer_count) :=  l_all_pubitems_tbl(i);
        END IF;
        CLOSE c_isdeferred;
     END LOOP;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

END GET_ALL_DEFERRED_PUB_ITEMS;


/***
  This function accepts a list of publication items and a publication item name and
  returns whether the item name was found within the item list.
  When the item name was found, it will be removed from the list.
***/
FUNCTION ITEM_EXISTS
        (
          p_pubitems_tbl IN OUT nocopy asg_apply.vc2_tbl_type,
          p_item_name    IN     VARCHAR2
        )
RETURN BOOLEAN IS
  l_index BINARY_INTEGER;
BEGIN


  IF p_pubitems_tbl.COUNT <= 0 THEN
    /*** no items in list -> item name not found ***/
    RETURN FALSE;
  END IF;
  FOR l_index IN p_pubitems_tbl.FIRST..p_pubitems_tbl.LAST LOOP
    IF p_pubitems_tbl.EXISTS(l_index) THEN
      IF p_pubitems_tbl( l_index ) = p_item_name THEN
        /*** found item -> delete from array and return TRUE ***/
        p_pubitems_tbl.DELETE( l_index );

        RETURN TRUE;
      END IF;
    END IF;
  END LOOP;
  /*** item name not found ***/

  RETURN FALSE;
EXCEPTION WHEN OTHERS THEN
  CSM_UTIL_PKG.log( 'Exception occurred in CSM_SERVICEP_WRAPPER_PKG.ITEM_EXISTS:' || fnd_global.local_chr(10) || SQLERRM,
                   'CSM_SERVICEP_WRAPPER_PKG.ITEM_EXISTS',FND_LOG.LEVEL_EXCEPTION);

  RETURN FALSE;
END ITEM_EXISTS;

/***
  This procedure is called by ASG_APPLY.APPLY_CLIENT_CHANGES if a list of dirty publication items
  has been retrieved for a user/tranid combination. This procedure gets called for both
  deferred and non-deferred publication items.
***/
PROCEDURE APPLY_DIRTY_PUBITEMS
         (
           p_user_name     IN     VARCHAR2,
           p_tranid        IN     NUMBER,
           p_pubitems_tbl  IN OUT nocopy asg_apply.vc2_tbl_type,
           x_return_status IN OUT nocopy VARCHAR2
         ) IS
  l_index BINARY_INTEGER;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*** call appropriate wrapper ***/

 /*** process Deferred first***/
  IF ITEM_EXISTS( p_pubitems_tbl, 'CSM_DEFERRED_TRANSACTIONS') THEN
      CSM_DEFERRED_TXNS_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;
  --we should process undo before all PI inorder to effectively call undo

  IF ITEM_EXISTS( p_pubitems_tbl, 'CSM_CLIENT_UNDO_REQUEST') THEN
      CSM_UNDO_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;

  IF ITEM_EXISTS( p_pubitems_tbl, 'CSM_HZ_LOCATIONS') THEN
      CSM_HZ_LOCATION_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;
  /*** call incident wrapper
    We should process 'CSM_INCIDENTS_ALL' before CSM_TASKS because
    CSM_TASKS might be refering to locally created INCIDENT_ID.
  ***/
  IF ITEM_EXISTS( p_pubitems_tbl, 'CSM_INCIDENTS_ALL') THEN
      CSM_SERVICE_REQUESTS_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;

  IF ITEM_EXISTS( p_pubitems_tbl, 'CSM_TASKS') THEN
      CSM_TASKS_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;


  IF ITEM_EXISTS( p_pubitems_tbl, 'CSM_TASK_ASSIGNMENTS') THEN

      CSM_TASK_ASSIGNMENTS_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;

  IF ITEM_EXISTS( p_pubitems_tbl, 'CSF_M_COUNTER_VALUES') THEN

      CSM_COUNTER_VALUES_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;

  IF ITEM_EXISTS( p_pubitems_tbl, 'CSM_DEBRIEF_HEADERS') THEN

      CSM_DEBRIEF_HEADERS_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;

  IF ITEM_EXISTS( p_pubitems_tbl, 'CSF_M_DEBRIEF_EXPENSES') THEN

      CSM_DEBRIEF_EXPENSES_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;

  IF ITEM_EXISTS( p_pubitems_tbl, 'CSF_M_DEBRIEF_LABOR') THEN

      CSM_DEBRIEF_LABOR_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
   END IF ;

   IF ITEM_EXISTS( p_pubitems_tbl, 'CSF_M_DEBRIEF_PARTS') THEN

      CSM_DEBRIEF_PARTS_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
   END IF;

  IF ITEM_EXISTS( p_pubitems_tbl, 'CSF_M_NOTES') THEN
      CSM_NOTES_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;

   IF ITEM_EXISTS( p_pubitems_tbl, 'CSF_M_LOBS') THEN

      CSM_LOBS_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;

   IF ITEM_EXISTS( p_pubitems_tbl, 'CSF_M_MAIL_MESSAGES') THEN
      CSM_MAIL_MESSAGES_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;

   IF ITEM_EXISTS( p_pubitems_tbl, 'CSF_M_MAIL_RECIPIENTS') THEN
      CSM_MAIL_RECIPIENTS_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;

  /*** call requirements wrapper ***/
   IF ITEM_EXISTS( p_pubitems_tbl, 'CSM_REQ_LINES') THEN
      CSM_REQUIREMENTS_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;

  /*** call requirements wrapper ***/
   IF ITEM_EXISTS( p_pubitems_tbl, 'CSF_M_INVENTORY') THEN
      CSM_INVENTORY_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;

   IF ITEM_EXISTS( p_pubitems_tbl, 'CSF_M_USER') THEN
      CSM_USER_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;

  --Support for Parts Transfer
  IF ITEM_EXISTS( p_pubitems_tbl, 'CSM_MTL_MATERIAL_TXNS') THEN
      CSM_MATERIAL_TRANSACTION_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;


 IF ITEM_EXISTS( p_pubitems_tbl, 'CSM_AUTO_SYNC_NFN') THEN


CSM_UTIL_PKG.log('Entered CSM_AUTO_SYNC_NFN .Will apply_client_changes'  );
      CSM_AUTO_SYNC_NFN_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;

IF ITEM_EXISTS( p_pubitems_tbl, 'CSM_CLIENT_NFN_LOG') THEN
      CSM_CLIENT_NFN_LOG_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;

IF ITEM_EXISTS( p_pubitems_tbl, 'CSM_AUTO_SYNC_LOG') THEN
      CSM_AUTO_SYNC_LOG_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;


IF ITEM_EXISTS( p_pubitems_tbl, 'CSM_AUTO_SYNC') THEN
      CSM_AUTO_SYNC_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;

  IF ITEM_EXISTS( p_pubitems_tbl, 'CSM_QUERY') THEN
      CSM_MOBILE_QUERY_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;

  IF ITEM_EXISTS( p_pubitems_tbl, 'CSM_QUERY_INSTANCES') THEN
      CSM_QUERY_INSTANCE_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           'N',  --p_from_sync
           x_return_status
         );
  END IF;

  --TODO: call other wrappers for other updatable PIs


EXCEPTION WHEN OTHERS THEN
  CSM_UTIL_PKG.log('Exception occurred in CSM_SERVICEP_WRAPPER_PKG.APPLY_DIRTY_PUBITEMS:' || fnd_global.local_chr(10) || SQLERRM,
                    'CSM_SERVICEP_WRAPPER_PKG.APPLY_DIRTY_PUBITEMS',FND_LOG.LEVEL_EXCEPTION  );

END APPLY_DIRTY_PUBITEMS;

/***
  This procedure is called by ASG_APPLY.PROCESS_UPLOAD when a publication item for publication SERVICEL
  is dirty. This happens when a mobile field service device executed DML on an updatable table and did
  a fast sync. This procedure will detect which publication items got dirty and will execute the wrapper
  procedures which will insert the data that came from mobile into the backend tables using public APIs.
***/
PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name IN VARCHAR2,
           p_tranid    IN NUMBER
         ) IS
  l_pubitems_tbl  asg_apply.vc2_tbl_type;
  l_return_status VARCHAR2(1);
BEGIN

  /*** retrieve names of all dirty SERVICEP publication items ***/
/*** get_all_dirty and get_all_defered_pub_items is replaced by get_all_pub_items ***/
  asg_apply.get_all_pub_items(p_user_name,
    p_tranid,
    'SERVICEP',
    l_pubitems_tbl,
    l_return_status);

  FOR i IN 1..l_pubitems_tbl.count LOOP

  csm_util_pkg.log('Dirty Pub items for tranid: ' || p_tranid || ' : ' || l_pubitems_tbl(i),'CSM_SERVICEP_WRAPPER_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_PROCEDURE);
--  logm('Dirty Pub items for tranid: ' || p_tranid || ' : ' || l_pubitems_tbl(i));
  END LOOP;

  /*** successfully retrieved item names? ***/
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_pubitems_tbl.COUNT = 0 THEN
    NULL;
  ELSE
    /*** yes -> process them ***/

    APPLY_DIRTY_PUBITEMS
         ( p_user_name
         , p_tranid
         , l_pubitems_tbl
         , l_return_status
         );
  END IF;

  /*** retrieve names of deferred dirty SERVICEP publication items ***/
  /*
  get_all_deferred_pub_items(p_user_name,
                             p_tranid,
                             'SERVICEP',
                             l_pubitems_tbl,
                             l_return_status);



  IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_pubitems_tbl.COUNT = 0 THEN
    NULL;
  ELSE


    APPLY_DIRTY_PUBITEMS
         ( p_user_name
         , p_tranid
         , l_pubitems_tbl
         , l_return_status
         );
  END IF;
*/

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  CSM_UTIL_PKG.log('Exception occurred in CSM_SERVICEP_WRAPPER_PKG.Apply_Client_Changes: ' || sqlerrm
               || ' for User: ' || p_user_name ,'CSM_SERVICEP_WRAPPER_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_EXCEPTION);


END APPLY_CLIENT_CHANGES;




/**
 *  POPULATE_ACCESS_RECORDS
 *  is the bootstrap procedure called by MDG upon CSM user creation
 *  we need to iterate over the responsibilities assigned to this CSM user
 *  and call the CSM_WF_PKG.User_Resp_Post_Ins(user_id, resp_id)
 */
PROCEDURE POPULATE_ACCESS_RECORDS ( p_userid IN NUMBER)
IS
  CURSOR l_resp_csr(b_userid NUMBER) IS
    SELECT DISTINCT aupr.RESPONSIBILITY_ID AS RESPONSIBILITY_ID
    FROM   ASG_USER au
	,      asg_user_pub_resps aupr
    WHERE  au.USER_ID 		  	  = b_userid
	AND    aupr.pub_name 		  = 'SERVICEP'
	AND    au.user_name  		  = aupr.user_name;

  l_resp_rec  l_resp_csr%ROWTYPE;

BEGIN
   csm_util_pkg.log('insert called','CSM_SERVICEP_WRAPPER_PKG.POPULATE_ACCESS_RECORDS',FND_LOG.LEVEL_PROCEDURE);

   csm_util_pkg.pvt_log('insert called' || 'CSM_SERVICEP_WRAPPER_PKG.POPULATE_ACCESS_RECORDS');
  FOR l_resp_rec IN l_resp_csr(p_userid) LOOP
    csm_util_pkg.pvt_log('POPULATE_ACCESS_RECORDS: USER_ID = ' || p_userid || ' RESP_ID = ' || l_resp_rec.RESPONSIBILITY_ID);
    csm_util_pkg.log('POPULATE_ACCESS_RECORDS: USER_ID = ' || p_userid || ' RESP_ID = ' || l_resp_rec.RESPONSIBILITY_ID
                     ,FND_LOG.LEVEL_STATEMENT  );
    CSM_WF_PKG.User_Resp_Post_Ins(p_user_id => p_userid,
                                  p_responsibility_id => l_resp_rec.RESPONSIBILITY_ID );
  END LOOP;
END POPULATE_ACCESS_RECORDS;  -- end POPULATE_ACCESS_RECORDS

/**
 *  DELETE_ACCESS_RECORDS
 *  is the bootstrap procedure called by MDG upon CSM user deletion
 *  we need to iterate over the responsibilities assigned to this CSM user
 *  and call the CSM_WF_PKG.User_Resp_Post_Ins(user_id, resp_id)
 */
PROCEDURE DELETE_ACCESS_RECORDS ( p_userid in number)
IS
BEGIN
    csm_util_pkg.log('delete called','CSM_SERVICEP_WRAPPER_PKG.DELETE_ACCESS_RECORDS',FND_LOG.LEVEL_PROCEDURE);
    CSM_WF_PKG.User_Del(p_user_id => p_userid);
END DELETE_ACCESS_RECORDS;  -- end DELETE_ACCESS_RECORDS

/*
  Call back function for ASG. used for create synonyms / grant accesses in mobileadmin schema
  before running installation manager
 */
FUNCTION CHECK_OLITE_SCHEMA RETURN VARCHAR2  IS
  l_count NUMBER;
BEGIN
  SELECT count(1) INTO l_count
  FROM all_synonyms
  WHERE owner = g_olite_schema AND SYNONYM_NAME = 'FND_GLOBAL';
  IF l_count = 0 THEN
    -- csm_util_pkg.log(' synonym mobileadmin.FND_GLOBAL does not exist');
    --EXECUTE IMMEDIATE 'create synonym mobileadmin.FND_GLOBAL for FND_GLOBAL';
    EXECUTE IMMEDIATE 'create synonym '
                        ||g_olite_schema||'.FND_GLOBAL for FND_GLOBAL';
  END IF;
  SELECT count(1) INTO l_count
  FROM all_synonyms
  WHERE owner = g_olite_schema AND SYNONYM_NAME = 'CSM_PROFILE_PKG';
  IF l_count = 0 THEN
    -- csm_util_pkg.log(' synonym mobileadmin.csm_profile_pkg does not exist');
    --EXECUTE IMMEDIATE 'create synonym mobileadmin.csm_profile_pkg for csm_profile_pkg';

    EXECUTE IMMEDIATE 'create synonym '
                      ||g_olite_schema||'.csm_profile_pkg for csm_profile_pkg';
  END IF;
  SELECT count(1) INTO l_count
  FROM all_synonyms
  WHERE owner = g_olite_schema AND SYNONYM_NAME = 'CSM_UTIL_PKG';
  IF l_count = 0 THEN
    -- csm_util_pkg.log(' synonym mobileadmin.csm_profile_pkg does not exist');
    --EXECUTE IMMEDIATE 'create synonym mobileadmin.csm_util_pkg for csm_util_pkg';

    EXECUTE IMMEDIATE 'create synonym '
                       ||g_olite_schema||'.csm_util_pkg for csm_util_pkg';
  END IF;

  RETURN 'Y';

EXCEPTION
  WHEN OTHERS THEN
     RETURN 'N';
END  CHECK_OLITE_SCHEMA;

FUNCTION detect_conflict(p_user_name IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN
  CSM_UTIL_PKG.LOG('Entering CSM_SERVICEP_WRAPPER_PKG.DETECT_CONFLICT for user ' || p_user_name ,
                         'CSM_SERVICEP_WRAPPER_PKG.DETECT_CONFLICT',FND_LOG.LEVEL_PROCEDURE);

      RETURN 'Y' ;
EXCEPTION
  WHEN OTHERS THEN
     RETURN 'Y';
END ;

FUNCTION CONFLICT_RESOLUTION_METHOD (p_user_name IN VARCHAR2,
                                     p_tran_id IN NUMBER,
                                     p_sequence IN NUMBER)
RETURN VARCHAR2 IS
l_profile_value VARCHAR2(30) ;
BEGIN
  CSM_UTIL_PKG.LOG('Entering CSM_SERVICEP_WRAPPER_PKG.CONFLICT_RESOLUTION_METHOD for user ' || p_user_name ,
                         'CSM_SERVICEP_WRAPPER_PKG.CONFLICT_RESOLUTION_METHOD',FND_LOG.LEVEL_PROCEDURE);
 l_profile_value := fnd_profile.value(csm_profile_pkg.g_JTM_APPL_CONFLICT_RULE);

  if l_profile_value = 'SERVER_WINS' then
      RETURN 'S' ;
  else
      RETURN 'C' ;
  END IF ;
EXCEPTION
  WHEN OTHERS THEN
     RETURN 'C';
END ;



END CSM_SERVICEP_WRAPPER_PKG;

/
