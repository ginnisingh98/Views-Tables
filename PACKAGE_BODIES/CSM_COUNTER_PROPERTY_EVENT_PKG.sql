--------------------------------------------------------
--  DDL for Package Body CSM_COUNTER_PROPERTY_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_COUNTER_PROPERTY_EVENT_PKG" AS
/* $Header: csmecptb.pls 120.0 2006/07/24 12:53:33 trajasek noship $ */

--
-- Purpose: USed to downlaod Counter properties for each counter
-- MODIFICATION HISTORY
-- Person      Date    Comments
-----------------------------------------------------------

/*** Globals ***/
g_count_prp_acc_table_name        CONSTANT VARCHAR2(30) := 'CSM_COUNTER_PROPERTIES_ACC';
g_count_prp_table_name            CONSTANT VARCHAR2(30) := 'CSI_COUNTER_PROPERTIES_B';
g_count_prp_seq_name              CONSTANT VARCHAR2(30) := 'CSM_COUNTER_PROPERTIES_ACC_S';
g_count_prp_pk1_name              CONSTANT VARCHAR2(30) := 'COUNTER_PROPERTY_ID';
g_count_prp_pubi_name             CONSTANT CSM_ACC_PKG.t_publication_item_list :=
  								 CSM_ACC_PKG.t_publication_item_list('CSM_COUNTER_PROPERTIES');


 PROCEDURE COUNTER_PROPERTY_INS( p_counter_id     NUMBER,
                           	     p_user_id 	      NUMBER,
                           		 p_error_msg      OUT NOCOPY VARCHAR2,
                           		 x_return_status  IN OUT NOCOPY VARCHAR2)
IS
--Cursor to insert counter property
--this happens if a counter is inserted
CURSOR c_property_ins(c_counter_id NUMBER,c_user_id NUMBER)
IS
SELECT
B.COUNTER_PROPERTY_ID ,
B.COUNTER_ID
FROM
CSI_COUNTER_PROPERTIES_B B,
CSM_COUNTERS_ACC		 CACC
WHERE B.COUNTER_ID    = CACC.COUNTER_ID
AND   CACC.USER_ID 	  = c_user_id
AND   CACC.COUNTER_ID = c_counter_id
AND NOT EXISTS( SELECT 1
				FROM   CSM_COUNTER_PROPERTIES_ACC PACC
				WHERE  PACC.COUNTER_PROPERTY_ID = B.COUNTER_PROPERTY_ID
				AND	   PACC.USER_ID = c_user_id);

--variable declarations
l_err_msg VARCHAR2(4000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_err_msg := 'Entering CSM_COUNTER_PROPERTY_EVENT_PKG.COUNTER_PROPERTY_INS' || ' for PK ' || to_char(p_counter_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_COUNTER_PROPERTY_EVENT_PKG.COUNTER_PROPERTY_INS', FND_LOG.LEVEL_PROCEDURE);

  -- Open USER IDs loop
  FOR r_cntr_prp_rec IN  c_property_ins(p_counter_id,p_user_id) LOOP
      -- Call Insert ACC
      CSM_ACC_PKG.Insert_Acc
             ( P_PUBLICATION_ITEM_NAMES => g_count_prp_pubi_name
              ,P_ACC_TABLE_NAME         => g_count_prp_acc_table_name
              ,P_SEQ_NAME               => g_count_prp_seq_name
              ,P_PK1_NAME               => g_count_prp_pk1_name
              ,P_PK1_NUM_VALUE          => r_cntr_prp_rec.counter_property_id
              ,P_USER_ID                => p_user_id
             );
   END LOOP ; --End USER IDs  loop

  l_err_msg := 'Leaving CSM_COUNTER_PROPERTY_EVENT_PKG.COUNTER_PROPERTY_INS' || ' for Counter ' || to_char(p_counter_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_COUNTER_PROPERTY_EVENT_PKG.COUNTER_PROPERTY_INS', FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  WHEN OTHERS THEN
     IF c_property_ins%ISOPEN  then
        CLOSE c_property_ins;
     END IF;

     p_error_msg := ' FAILED COUNTER_PROPERTY_INS:' || to_char(p_counter_id);
     x_return_status := FND_API.G_RET_STS_ERROR;
     CSM_UTIL_PKG.LOG( p_error_msg, 'CSM_COUNTER_PROPERTY_EVENT_PKG.COUNTER_PROPERTY_INS',FND_LOG.LEVEL_EXCEPTION);
     RAISE;

END COUNTER_PROPERTY_INS;


 PROCEDURE COUNTER_PROPERTY_UPD( p_counter_id IN NUMBER,
                           	     p_user_id 	 IN NUMBER,
                           		 p_error_msg     OUT NOCOPY VARCHAR2,
                           		 x_return_status IN OUT NOCOPY VARCHAR2)
IS
--Cursors to update counter property
--this is called if a counter is updated
CURSOR c_property_upd(c_counter_id NUMBER,c_user_id NUMBER)
IS
SELECT
PACC.ACCESS_ID ,
PACC.USER_ID
FROM
CSI_COUNTER_PROPERTIES_B B,
CSM_COUNTER_PROPERTIES_ACC PACC
WHERE B.COUNTER_PROPERTY_ID    = PACC.COUNTER_PROPERTY_ID
AND   PACC.USER_ID 	  = c_user_id
AND   B.COUNTER_ID 	  = c_counter_id;

--variable declarations
l_err_msg VARCHAR2(4000);
l_markdirty BOOLEAN;
l_pub_item_name VARCHAR2(240) := 'CSM_COUNTER_PROPERTIES';

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_err_msg := 'Entering CSM_COUNTER_PROPERTY_EVENT_PKG.COUNTER_PROPERTY_UPD' || ' for PK ' || to_char(p_counter_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_COUNTER_PROPERTY_EVENT_PKG.COUNTER_PROPERTY_UPD', FND_LOG.LEVEL_PROCEDURE);

  -- Open USER IDs loop
  FOR r_cntr_prp_rec IN  c_property_upd(p_counter_id,p_user_id) LOOP
      -- Call Insert ACC
     l_markdirty := csm_util_pkg.MakeDirtyForUser ( l_pub_item_name
                                				  , r_cntr_prp_rec.access_id
                                				  , r_cntr_prp_rec.user_id
                                				  , 'U'
                                				  , sysdate);
  END LOOP ; --End USER IDs  loop

  l_err_msg := 'Leaving CSM_COUNTER_PROPERTY_EVENT_PKG.COUNTER_PROPERTY_UPD' || ' for Counter ' || to_char(p_counter_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_COUNTER_PROPERTY_EVENT_PKG.COUNTER_PROPERTY_UPD', FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  WHEN OTHERS THEN
     IF c_property_upd%ISOPEN  then
        CLOSE c_property_upd;
     END IF;

     p_error_msg := ' FAILED COUNTER_PROPERTY_UPD FOR COUNTER : ' || to_char(p_counter_id);
     x_return_status := FND_API.G_RET_STS_ERROR;
     CSM_UTIL_PKG.LOG( p_error_msg, 'CSM_COUNTER_PROPERTY_EVENT_PKG.COUNTER_PROPERTY_UPD',FND_LOG.LEVEL_EXCEPTION);
     RAISE;


END COUNTER_PROPERTY_UPD;

PROCEDURE COUNTER_PROPERTY_DEL( p_counter_id IN NUMBER,
                           	     p_user_id 	 IN NUMBER,
                           		 p_error_msg     OUT NOCOPY VARCHAR2,
                           		 x_return_status IN OUT NOCOPY VARCHAR2)
IS
--Cursor to delete counter property
--this is called if a counter is Deleted for a user
CURSOR c_property_del(c_counter_id NUMBER,c_user_id NUMBER)
IS
SELECT
PACC.ACCESS_ID ,
B.COUNTER_PROPERTY_ID
FROM
CSI_COUNTER_PROPERTIES_B B,
CSM_COUNTER_PROPERTIES_ACC PACC
WHERE B.COUNTER_PROPERTY_ID    = PACC.COUNTER_PROPERTY_ID
AND   PACC.USER_ID 	  = c_user_id
AND   B.COUNTER_ID 	  = c_counter_id;

--variable declarations
l_err_msg VARCHAR2(4000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_err_msg := 'Entering CSM_COUNTER_PROPERTY_EVENT_PKG.COUNTER_PROPERTY_DEL' || ' for PK ' || to_char(p_counter_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_COUNTER_PROPERTY_EVENT_PKG.COUNTER_PROPERTY_DEL', FND_LOG.LEVEL_PROCEDURE);

  -- Open counter property id loop
  FOR r_cntr_prp_rec IN  c_property_del(p_counter_id,p_user_id) LOOP
      -- Call Delete ACC
      CSM_ACC_PKG.Delete_Acc
             ( P_PUBLICATION_ITEM_NAMES => g_count_prp_pubi_name
              ,P_ACC_TABLE_NAME         => g_count_prp_acc_table_name
              ,P_PK1_NAME               => g_count_prp_pk1_name
              ,P_PK1_NUM_VALUE          => r_cntr_prp_rec.counter_property_id
              ,P_USER_ID                => p_user_id
             );
   END LOOP ; --End USER IDs  loop

  l_err_msg := 'Leaving CSM_COUNTER_PROPERTY_EVENT_PKG.COUNTER_PROPERTY_DEL' || ' for Counter ' || to_char(p_counter_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_COUNTER_PROPERTY_EVENT_PKG.COUNTER_PROPERTY_DEL', FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  WHEN OTHERS THEN
     IF c_property_del%ISOPEN  then
        CLOSE c_property_del;
     END IF;

     p_error_msg := ' FAILED COUNTER_PROPERTY_DEL FOR COUNTER : ' || to_char(p_counter_id);
     x_return_status := FND_API.G_RET_STS_ERROR;
     CSM_UTIL_PKG.LOG( p_error_msg, 'CSM_COUNTER_PROPERTY_EVENT_PKG.COUNTER_PROPERTY_DEL',FND_LOG.LEVEL_EXCEPTION);
     RAISE;

END COUNTER_PROPERTY_DEL;

END CSM_COUNTER_PROPERTY_EVENT_PKG; -- Package spec of CSM_COUNTER_PROPERTY_EVENT_PKG

/
