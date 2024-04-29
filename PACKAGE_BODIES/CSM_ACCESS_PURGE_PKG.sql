--------------------------------------------------------
--  DDL for Package Body CSM_ACCESS_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_ACCESS_PURGE_PKG" AS
/* $Header: csmeacpb.pls 120.0.12010000.1 2008/07/28 16:12:46 appldev ship $ */

--
-- Purpose: Procedures to purge Invalid Acc Records
-- MODIFICATION HISTORY
-- Person      Date       Comments
-- TRAJASEK    28MAy07    Initial Revision
-- ---------   ------     ------------------------------------------

/*** Globals ***/
/**/
PROCEDURE DELETE_NON_ACC_MFS_TABLE
IS
 CURSOR c_csm_inv_org
 IS
 SELECT DISTINCT USER_ID
 FROM   CSM_USER_INVENTORY_ORG   ACC
 WHERE  USER_ID IS NOT NULL
 AND NOT EXISTS (SELECT 1 FROM ASG_USER AU WHERE AU.USER_ID=ACC.USER_ID
                  AND AU.ENABLED= 'Y');

 CURSOR c_csl_inv_org
 IS
 SELECT DISTINCT RESOURCE_ID
 FROM   CSL_RESOURCE_INVENTORY_ORG   ACC
 WHERE  RESOURCE_ID IS NOT NULL
 AND NOT EXISTS (SELECT 1 FROM ASG_USER AU WHERE AU.RESOURCE_ID=ACC.RESOURCE_ID
                  AND AU.ENABLED= 'Y');

TYPE USERID_TABLE_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_user_list      USERID_TABLE_TYPE;

BEGIN
  OPEN  c_csm_inv_org;
  FETCH c_csm_inv_org BULK COLLECT INTO l_user_list;
  CLOSE c_csm_inv_org;

    IF l_user_list.COUNT >0 THEN
    FOR i IN 1..l_user_list.COUNT
    LOOP
        BEGIN
            DELETE  FROM CSM_USER_INVENTORY_ORG WHERE USER_ID = l_user_list(i);
        EXCEPTION
        WHEN OTHERS THEN
          NULL;
        END;

    END LOOP;
    l_user_list.DELETE;
    END IF;

  OPEN  c_csl_inv_org;
  FETCH c_csl_inv_org BULK COLLECT INTO l_user_list;
  CLOSE c_csl_inv_org;

    IF l_user_list.COUNT >0 THEN
    FOR i IN 1..l_user_list.COUNT
    LOOP
        BEGIN
            DELETE  FROM CSL_RESOURCE_INVENTORY_ORG WHERE RESOURCE_ID = l_user_list(i);
        EXCEPTION
        WHEN OTHERS THEN
          NULL;
        END;
    END LOOP;
    l_user_list.DELETE;
    END IF;

END DELETE_NON_ACC_MFS_TABLE;

PROCEDURE DELETE_ACC_FOR_USER
( p_acc_table_name IN VARCHAR2
, p_user_id        IN NUMBER
) IS
 l_stmt    VARCHAR2(1000);
BEGIN
  l_stmt := 'DELETE ' || p_acc_table_name ||' WHERE USER_ID = :P1';

  EXECUTE IMMEDIATE l_stmt USING p_user_id;

END DELETE_ACC_FOR_USER;

PROCEDURE DELETE_ACC_FOR_RESOURCE
( p_acc_table_name IN VARCHAR2
, p_resource_id        IN NUMBER
) IS
 l_stmt    VARCHAR2(1000);
BEGIN
  l_stmt := 'DELETE ' || p_acc_table_name ||' WHERE RESOURCE_ID = :P1';

  EXECUTE IMMEDIATE l_stmt USING p_resource_id;

END DELETE_ACC_FOR_RESOURCE;

PROCEDURE PURGE_INVALID_ACC_DATA(p_status  OUT NOCOPY VARCHAR2,
                                     p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;

  CURSOR c_csm_acc_list IS
  SELECT ITEM_ID,
         ACCESS_OWNER,
         ACCESS_NAME
  FROM   ASG_PUB_ITEM
  WHERE  PUB_NAME IN ('SERVICEP','JTM_HANDHELD')
  AND    ACCESS_NAME IS NOT NULL
  AND    STATUS  = 'Y'
  AND    ENABLED = 'Y';

  CURSOR c_csl_acc_list IS
  SELECT ITEM_ID,
         ACCESS_OWNER,
         ACCESS_NAME
  FROM   ASG_PUB_ITEM
  WHERE  PUB_NAME IN ('JTM','SERVICEL')
  AND    ACCESS_NAME IS NOT NULL
  AND    STATUS  = 'Y'
  AND    ENABLED = 'Y';

 TYPE acc_table_type    IS TABLE OF c_csm_acc_list%ROWTYPE;
 TYPE USERID_TABLE_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

 acc_tab_list     ACC_TABLE_TYPE;
 l_user_list      USERID_TABLE_TYPE;
 l_sql_stmt       VARCHAR2(1000);
 l_sqlerrno 	  VARCHAR2(20);
 l_sqlerrmsg	  VARCHAR2(4000);
 l_error_msg		VARCHAR2(4000);
BEGIN

--Purge records for CSM
  OPEN   c_csm_acc_list;
  FETCH  c_csm_acc_list BULK COLLECT INTO acc_tab_list;
  CLOSE  c_csm_acc_list;
  CSM_UTIL_PKG.LOG('Entering CSM_COUNTER_EVENT_PKG.COUNTER_PURGE_DATA', 'CSM_COUNTER_EVENT_PKG.COUNTER_PURGE_DATA',FND_LOG.LEVEL_EVENT);
  FOR I IN 1..acc_tab_list.COUNT
  LOOP
      l_sql_stmt:= 'SELECT DISTINCT USER_ID FROM '||acc_tab_list(I).ACCESS_NAME ||
             ' ACC WHERE USER_ID IS NOT NULL
			       AND NOT EXISTS (SELECT 1 FROM ASG_USER AU WHERE AU.USER_ID=ACC.USER_ID AND AU.ENABLED= ''Y'')';
      BEGIN
        EXECUTE IMMEDIATE l_sql_stmt BULK COLLECT INTO l_user_list;
      EXCEPTION
      WHEN OTHERS THEN
          NULL;
      END;
      CSM_UTIL_PKG.LOG('Processing Access list', 'CSM_COUNTER_EVENT_PKG.COUNTER_PURGE_DATA',FND_LOG.LEVEL_EVENT);
      IF l_user_list.COUNT >0 THEN
          FOR J IN 1..l_user_list.COUNT
          LOOP
            DELETE_ACC_FOR_USER(acc_tab_list(I).ACCESS_NAME,l_user_list(J));
          END LOOP;
          COMMIT;
          l_user_list.DELETE;
      END IF;
  END LOOP; --Access list loop

  CSM_UTIL_PKG.LOG('Completed processing Access list', 'CSM_COUNTER_EVENT_PKG.COUNTER_PURGE_DATA',FND_LOG.LEVEL_EVENT);
  IF acc_tab_list.COUNT > 0 THEN
     acc_tab_list.DELETE;
  END IF;


--Purge records for CSL
  OPEN   c_csl_acc_list;
  FETCH  c_csl_acc_list BULK COLLECT INTO acc_tab_list;
  CLOSE  c_csl_acc_list;
  CSM_UTIL_PKG.LOG('Entering CSM_COUNTER_EVENT_PKG.COUNTER_PURGE_DATA', 'CSM_COUNTER_EVENT_PKG.COUNTER_PURGE_DATA',FND_LOG.LEVEL_EVENT);

  FOR I IN 1..acc_tab_list.COUNT
  LOOP
      l_sql_stmt:= 'SELECT DISTINCT RESOURCE_ID FROM '||acc_tab_list(I).ACCESS_NAME ||
             ' ACC WHERE RESOURCE_ID IS NOT NULL
			       AND NOT EXISTS (SELECT 1 FROM ASG_USER AU WHERE AU.RESOURCE_ID=ACC.RESOURCE_ID AND AU.ENABLED= ''Y'')';
      BEGIN
        EXECUTE IMMEDIATE l_sql_stmt BULK COLLECT INTO l_user_list;
      EXCEPTION
      WHEN OTHERS THEN
          NULL;
      END;
      CSM_UTIL_PKG.LOG('Processing Access list', 'CSM_COUNTER_EVENT_PKG.COUNTER_PURGE_DATA',FND_LOG.LEVEL_EVENT);

      IF l_user_list.COUNT >0 THEN
          FOR J IN 1..l_user_list.COUNT
          LOOP
            DELETE_ACC_FOR_RESOURCE(acc_tab_list(I).ACCESS_NAME,l_user_list(J));
          END LOOP;
          COMMIT;
          l_user_list.DELETE;
      END IF;
  END LOOP; --Access list loop

  CSM_UTIL_PKG.LOG('Completed processing Access list', 'CSM_COUNTER_EVENT_PKG.COUNTER_PURGE_DATA',FND_LOG.LEVEL_EVENT);
  IF acc_tab_list.COUNT > 0 THEN
     acc_tab_list.DELETE;
  END IF;
  --call to delete non acc mfs tables
  DELETE_NON_ACC_MFS_TABLE;

  COMMIT;

  p_status := 'SUCCESS';
  p_message :=  'CSM_ACCESS_PURGE_PKG.PURGE_INVALID_ACC_DATA Executed successfully';

EXCEPTION
  --log the error
  WHEN OTHERS THEN
  	l_sqlerrno := TO_CHAR(SQLCODE);
	l_sqlerrmsg:= SUBSTR(SQLERRM,1,2000);
    ROLLBACK;
    l_error_msg := ' Exception in  PURGE_INVALID_ACC_DATA'
                       || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
    p_status := 'ERROR';
    p_message := 'Error in CSM_ACCESS_PURGE_PKG.PURGE_INVALID_ACC_DATA: ' || l_error_msg;
    CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_ACCESS_PURGE_PKG.PURGE_INVALID_ACC_DATA',FND_LOG.LEVEL_EVENT);

END PURGE_INVALID_ACC_DATA;

END CSM_ACCESS_PURGE_PKG; -- of package csm_counter_event_pkg

/
