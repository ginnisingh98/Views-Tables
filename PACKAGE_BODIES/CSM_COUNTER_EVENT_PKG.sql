--------------------------------------------------------
--  DDL for Package Body CSM_COUNTER_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_COUNTER_EVENT_PKG" AS
/* $Header: csmecntb.pls 120.4.12010000.2 2010/02/15 05:43:09 trajasek ship $ */

--
-- Purpose: Encapsulate various operations on counter.
--          Methods willbe called by workflow engine
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- Jayan       05MAy02 Initial Revision
-- MelvinP     02Jul02 Fixed Ctr_Val_Make_Dirty_ForEachUser,
--                     Ctr_Val_MDirty_U_ForEachUser
-- ---------   ------  ------------------------------------------

/*** Globals ***/
g_counters_acc_table_name        CONSTANT VARCHAR2(30) := 'CSM_COUNTERS_ACC';
g_counters_table_name            CONSTANT VARCHAR2(30) := 'CS_COUNTERS';
g_counters_seq_name              CONSTANT VARCHAR2(30) := 'CSM_COUNTERS_ACC_S';
g_counters_pk1_name              CONSTANT VARCHAR2(30) := 'COUNTER_ID';
g_counters_pubi_name             CONSTANT CSM_ACC_PKG.t_publication_item_list :=
  CSM_ACC_PKG.t_publication_item_list('CSF_M_COUNTERS');

g_counter_val_acc_table_name     CONSTANT VARCHAR2(30) := 'CSM_COUNTER_VALUES_ACC';
g_counter_val_table_name         CONSTANT VARCHAR2(30) := 'CS_COUNTER_VALUES';
g_counter_val_seq_name              CONSTANT VARCHAR2(30) := 'CSM_COUNTER_VALUES_ACC_S';
g_counter_val_pk1_name           CONSTANT VARCHAR2(30) := 'COUNTER_VALUE_ID';
g_counter_val_pubi_name          CONSTANT CSM_ACC_PKG.t_publication_item_list :=
  CSM_ACC_PKG.t_publication_item_list('CSF_M_COUNTER_VALUES');


l_markdirty_failed EXCEPTION;

-- the below is a private proc called if the counter is deleted for all instances
PROCEDURE COUNTER_VALS_MAKE_DIRTY_D_GRP (p_counter_id IN NUMBER,
                                         p_user_id IN NUMBER,
                                         p_error_msg     OUT NOCOPY    VARCHAR2,
                                         x_return_status IN OUT NOCOPY VARCHAR2)
IS
l_err_msg VARCHAR2(4000);
l_user_id NUMBER;

CURSOR l_counter_value_csr(p_counter_id cs_counters.counter_id%TYPE, p_user_id NUMBER)
IS
SELECT cval.counter_value_id
FROM   csm_counter_values_acc acc,
       CSI_COUNTER_READINGS   cval
WHERE  acc.user_id 			= p_user_id
AND    acc.counter_value_id = cval.counter_value_id
AND    cval.counter_id 		= p_counter_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_err_msg := 'Entering CSM_COUNTER_EVENT_PKG.COUNTER_VALS_MAKE_DIRTY_D_GRP' || ' for PK ' || to_char(p_counter_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_COUNTER_EVENT_PKG.COUNTER_VALS_MAKE_DIRTY_D_GRP', FND_LOG.LEVEL_PROCEDURE);

  l_user_id := p_user_id;

   FOR r_counter_value_rec in l_counter_value_csr(p_counter_id, l_user_id) LOOP
          --Call DELETE ACC
          CSM_ACC_PKG.Delete_Acc
                    ( P_PUBLICATION_ITEM_NAMES => g_counter_val_pubi_name
                     ,P_ACC_TABLE_NAME         => g_counter_val_acc_table_name
                     ,P_PK1_NAME               => g_counter_val_pk1_name
                     ,P_PK1_NUM_VALUE          => r_counter_value_rec.counter_value_id
                     ,P_USER_ID                => l_user_id
                    );


		 --bug 5253769 DELETE COUNTER  PROPERTY READINGS property for the user
		  CSM_CTR_PROP_READ_EVENT_PKG.CTR_PROPERTY_READ_DEL
		  			(P_COUNTER_VALUE_ID => r_counter_value_rec.counter_value_id,
					 P_USER_ID    => l_user_id,
					 P_ERROR_MSG  => p_error_msg,
					 X_RETURN_STATUS => x_return_status
					 );
	END LOOP;

  l_err_msg := 'Leaving CSM_COUNTER_EVENT_PKG.COUNTER_VALS_MAKE_DIRTY_D_GRP' || ' for PK ' || to_char(p_counter_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_COUNTER_EVENT_PKG.COUNTER_VALS_MAKE_DIRTY_D_GRP', FND_LOG.LEVEL_PROCEDURE);

  EXCEPTION
  	WHEN others THEN
       p_error_msg := ' FAILED COUNTER_VALS_MAKE_DIRTY_D_GRP:' || to_char(p_counter_id);
       x_return_status := FND_API.G_RET_STS_ERROR;
       CSM_UTIL_PKG.LOG( p_error_msg, 'CSM_COUNTER_EVENT_PKG.COUNTER_VALS_MAKE_DIRTY_D_GRP',FND_LOG.LEVEL_EXCEPTION);
--       RAISE;
END COUNTER_VALS_MAKE_DIRTY_D_GRP;

PROCEDURE COUNTER_MDIRTY_D(p_counter_id IN NUMBER,
                           p_error_msg     OUT NOCOPY    VARCHAR2,
                           x_return_status IN OUT NOCOPY VARCHAR2)
IS
l_err_msg VARCHAR2(4000);
l_user_id NUMBER;

CURSOR l_acc_csr(b_counter_id NUMBER)
IS
SELECT acc.user_id
FROM   CSI_COUNTERS_B 		    counters
  ,    CS_CSI_COUNTER_GROUPS    counter_groups
  ,    csm_item_instances_acc   acc
  ,	   CSI_COUNTER_ASSOCIATIONS ass
WHERE  counters.counter_id 	   = ass.counter_id
AND	   ass.source_object_code  = 'CP'
AND    counters.counter_type   = 'REGULAR'
AND    ass.source_object_id    = acc.instance_id
AND    counters.counter_id 	   = b_counter_id
AND    counter_groups.counter_group_id(+) = counters.group_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_err_msg := 'Entering CSM_COUNTER_EVENT_PKG.COUNTER_MDIRTY_D' || ' for PK ' || to_char(p_counter_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_COUNTER_EVENT_PKG.COUNTER_MDIRTY_D',FND_LOG.LEVEL_PROCEDURE);

  FOR r_acc_csr IN l_acc_csr(p_counter_id) LOOP
    l_user_id := r_acc_csr.user_id;

    -- delete counter for the user
    CSM_ACC_PKG.Delete_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_counters_pubi_name
      ,P_ACC_TABLE_NAME         => g_counters_acc_table_name
      ,P_PK1_NAME               => g_counters_pk1_name
      ,P_PK1_NUM_VALUE          => p_counter_id
      ,P_USER_ID                => l_user_id
     );

	--bug 5253769 DELETE COUNTER property for the user
		  CSM_COUNTER_PROPERTY_EVENT_PKG.COUNTER_PROPERTY_DEL
		  			(P_COUNTER_ID => p_counter_id,
					 P_USER_ID    => l_user_id,
					 P_ERROR_MSG  => p_error_msg,
					 X_RETURN_STATUS => x_return_status
					 );

    -- delete counter readings for the user
      csm_counter_event_pkg.COUNTER_VALS_MAKE_DIRTY_D_GRP(p_counter_id=>p_counter_id,
                                                        p_user_id=>l_user_id,
                                                        p_error_msg=>p_error_msg,
                                                        x_return_status=>x_return_status);


  	  --R12 DELETING Relationship for the counter & user
  	  CSM_CNTR_RELATION_EVENT_PKG.COUNTER_RELATION_DEL(p_counter_id,l_user_id);


  END LOOP;

  l_err_msg := 'Leaving CSM_COUNTER_EVENT_PKG.COUNTER_MDIRTY_D' || ' for PK ' || to_char(p_counter_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_COUNTER_EVENT_PKG.COUNTER_MDIRTY_D',FND_LOG.LEVEL_PROCEDURE);

  EXCEPTION
  	WHEN others THEN
       p_error_msg := ' FAILED COUNTER_MDIRTY_D:' || to_char(p_counter_id);
       x_return_status := FND_API.G_RET_STS_ERROR;
       CSM_UTIL_PKG.LOG( p_error_msg, 'CSM_COUNTER_EVENT_PKG.COUNTER_MDIRTY_D',FND_LOG.LEVEL_EXCEPTION);
       RAISE;
END COUNTER_MDIRTY_D;

PROCEDURE COUNTER_MDIRTY_D(p_counter_id IN NUMBER,
                           p_user_id IN NUMBER,
                           p_error_msg     OUT NOCOPY    VARCHAR2,
                           x_return_status IN OUT NOCOPY VARCHAR2)
IS
l_err_msg VARCHAR2(4000);
l_user_id NUMBER;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_err_msg := 'Entering CSM_COUNTER_EVENT_PKG.COUNTER_MDIRTY_D' || ' for PK ' || to_char(p_counter_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_COUNTER_EVENT_PKG.COUNTER_MDIRTY_D',FND_LOG.LEVEL_PROCEDURE);

    -- delete counter for the user
    CSM_ACC_PKG.Delete_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_counters_pubi_name
      ,P_ACC_TABLE_NAME         => g_counters_acc_table_name
      ,P_PK1_NAME               => g_counters_pk1_name
      ,P_PK1_NUM_VALUE          => p_counter_id
      ,P_USER_ID                => p_user_id
     );

	--bug 5253769 DELETE COUNTER property for the user
		  CSM_COUNTER_PROPERTY_EVENT_PKG.COUNTER_PROPERTY_DEL
		  			(P_COUNTER_ID => p_counter_id,
					 P_USER_ID    => p_user_id,
					 P_ERROR_MSG  => p_error_msg,
					 X_RETURN_STATUS => x_return_status
					 );

    --R12 DELETING Relationship for the counter & user
    CSM_CNTR_RELATION_EVENT_PKG.COUNTER_RELATION_DEL(p_counter_id,p_user_id);

  l_err_msg := 'Leaving CSM_COUNTER_EVENT_PKG.COUNTER_MDIRTY_D' || ' for PK ' || to_char(p_counter_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_COUNTER_EVENT_PKG.COUNTER_MDIRTY_D',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  	WHEN others THEN
       p_error_msg := ' FAILED COUNTER_MDIRTY_D:' || to_char(p_counter_id);
       x_return_status := FND_API.G_RET_STS_ERROR;
       CSM_UTIL_PKG.LOG( p_error_msg, 'CSM_COUNTER_EVENT_PKG.COUNTER_MDIRTY_D',FND_LOG.LEVEL_EXCEPTION);
       RAISE;
END COUNTER_MDIRTY_D;

PROCEDURE COUNTER_VALS_MAKE_DIRTY_D_GRP (p_counter_id IN NUMBER,
                                         p_instance_id IN NUMBER,
                                         p_user_id IN NUMBER,
                                         p_error_msg     OUT NOCOPY    VARCHAR2,
                                         x_return_status IN OUT NOCOPY VARCHAR2)
IS
l_err_msg VARCHAR2(4000);
l_user_id NUMBER;

CURSOR l_counter_value_csr(p_counter_id cs_counters.counter_id%TYPE, p_instance_id NUMBER,
                           p_user_id NUMBER)
IS
SELECT cval.counter_value_id
FROM   CSI_COUNTERS_B       	  cntrs,
	   CSI_COUNTER_READINGS		  cval,
	   CSI_COUNTER_ASSOCIATIONS   cas,
	   csm_item_instances_acc 	  acc
WHERE  cntrs.counter_id 		  = cas.counter_id
AND	   cas.source_object_code 	  = 'CP'
AND    cas.source_object_id 	  = p_instance_id
AND    cntrs.counter_id 		  = cval.counter_id
AND	   cas.source_object_id 	  = acc.instance_id
AND	   acc.user_id 			  	  = p_user_id
AND    cval.counter_id 			  = p_counter_id
AND 	EXISTS
(SELECT 1
 FROM 	csm_counter_values_acc vacc
 WHERE 	vacc.counter_value_id  = cval.counter_value_id
 AND 	vacc.user_id 		   = acc.user_id
 );

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_err_msg := 'Entering CSM_COUNTER_EVENT_PKG.COUNTER_VALS_MAKE_DIRTY_D_GRP' || ' for PK ' || to_char(p_counter_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_COUNTER_EVENT_PKG.COUNTER_VALS_MAKE_DIRTY_D_GRP', FND_LOG.LEVEL_PROCEDURE);

  l_user_id := p_user_id;

   FOR r_counter_value_rec in l_counter_value_csr(p_counter_id, p_instance_id, l_user_id) LOOP
          --Call DELETE ACC
          CSM_ACC_PKG.Delete_Acc
                    ( P_PUBLICATION_ITEM_NAMES => g_counter_val_pubi_name
                     ,P_ACC_TABLE_NAME         => g_counter_val_acc_table_name
                     ,P_PK1_NAME               => g_counter_val_pk1_name
                     ,P_PK1_NUM_VALUE          => r_counter_value_rec.counter_value_id
                     ,P_USER_ID                => l_user_id
                    );

			 --bug 5253769 DELETE COUNTER  PROPERTY READINGS property for the user
		  CSM_CTR_PROP_READ_EVENT_PKG.CTR_PROPERTY_READ_DEL
		  			(P_COUNTER_VALUE_ID => r_counter_value_rec.counter_value_id,
					 P_USER_ID    => l_user_id,
					 P_ERROR_MSG  => p_error_msg,
					 X_RETURN_STATUS => x_return_status
					 );

	END LOOP;

  l_err_msg := 'Leaving CSM_COUNTER_EVENT_PKG.COUNTER_VALS_MAKE_DIRTY_D_GRP' || ' for PK ' || to_char(p_counter_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_COUNTER_EVENT_PKG.COUNTER_VALS_MAKE_DIRTY_D_GRP', FND_LOG.LEVEL_PROCEDURE);

  EXCEPTION
  	WHEN others THEN
       p_error_msg := ' FAILED COUNTER_VALS_MAKE_DIRTY_D_GRP:' || to_char(p_counter_id);
       x_return_status := FND_API.G_RET_STS_ERROR;
       CSM_UTIL_PKG.LOG( p_error_msg, 'CSM_COUNTER_EVENT_PKG.COUNTER_VALS_MAKE_DIRTY_D_GRP',FND_LOG.LEVEL_EXCEPTION);
--       RAISE;
END COUNTER_VALS_MAKE_DIRTY_D_GRP;

PROCEDURE CTR_MAKE_DIRTY_U_FOREACHUSER(p_counter_id IN NUMBER,
                                       p_error_msg     OUT NOCOPY    VARCHAR2,
                                       x_return_status IN OUT NOCOPY VARCHAR2)
IS
l_err_msg VARCHAR2(4000);
l_user_id NUMBER;
l_publication_item_name VARCHAR2(30);
l_accesslist NUMBER;
l_resource_list NUMBER;
l_dmllist CHAR(1);
l_time_stamp DATE;
l_markdirty	BOOLEAN;

CURSOR l_user_ids_csr (p_counter_id cs_counters.counter_id%TYPE)
IS
SELECT acc.user_id,
       acc.access_id
FROM   csm_counters_acc acc
WHERE  acc.counter_id = p_counter_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_err_msg := 'Entering CSM_COUNTER_EVENT_PKG.CTR_MAKE_DIRTY_U_FOREACHUSER' || ' for PK ' || to_char(p_counter_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_COUNTER_EVENT_PKG.CTR_MAKE_DIRTY_U_FOREACHUSER', FND_LOG.LEVEL_PROCEDURE);

   FOR r_user_id_rec in  l_user_ids_csr(p_counter_id) LOOP

     l_publication_item_name := 'CSF_M_COUNTERS';
     l_dmllist := 'U';
     l_resource_list := r_user_id_rec.user_id;
     l_accesslist := r_user_id_rec.access_id;

      l_time_stamp := sysdate;
     --call irst wrapper  by anurag
     l_markdirty := csm_util_pkg.MakeDirtyForUser (l_publication_item_name
                                , l_accesslist
                                , l_resource_list
                                , l_dmllist
                                , l_time_stamp);

	 IF l_markdirty THEN
        --set the result. (no specific result text needed for this activity)
         p_error_msg := 'COMPLETE CTR_MAKE_DIRTY_U_FOREACHUSER:' || to_char(l_accesslist);
     END IF;

 	--bug 5253769 UPDATE COUNTER property for the user
	  CSM_COUNTER_PROPERTY_EVENT_PKG.COUNTER_PROPERTY_UPD
		  			(P_COUNTER_ID => p_counter_id,
					 P_USER_ID    => l_resource_list,
					 P_ERROR_MSG  => p_error_msg,
					 X_RETURN_STATUS => x_return_status
					 );

   END LOOP ; --end user ids cursor loop

  l_err_msg := 'Leaving CSM_COUNTER_EVENT_PKG.CTR_MAKE_DIRTY_U_FOREACHUSER' || ' for PK ' || to_char(p_counter_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_COUNTER_EVENT_PKG.CTR_MAKE_DIRTY_U_FOREACHUSER', FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
   WHEN OTHERS THEN
     if l_user_ids_csr%isopen  then
        close l_user_ids_csr;
     end if ; -- cursor

     p_error_msg := ' FAILED CTR_MAKE_DIRTY_U_FOREACHUSER:' || to_char(p_counter_id);
     x_return_status := FND_API.G_RET_STS_ERROR;
     CSM_UTIL_PKG.LOG( p_error_msg, 'CSM_COUNTER_EVENT_PKG.CTR_MAKE_DIRTY_U_FOREACHUSER',FND_LOG.LEVEL_EXCEPTION);
     RAISE;
END CTR_MAKE_DIRTY_U_FOREACHUSER;

PROCEDURE CTR_MAKE_DIRTY_I_FOREACHUSER(p_counter_id IN NUMBER,
                           p_error_msg     OUT NOCOPY    VARCHAR2,
                           x_return_status IN OUT NOCOPY VARCHAR2)
IS
l_err_msg VARCHAR2(4000);
l_user_id NUMBER;
l_publication_item_name VARCHAR2(30);
l_accesslist NUMBER;
l_resource_list NUMBER;
l_dmllist CHAR(1);
l_time_stamp DATE;
l_markdirty	BOOLEAN;

CURSOR l_user_ids_csr (p_counter_id cs_counters.counter_id%TYPE)
IS
SELECT  acc.user_id
FROM 	CSI_COUNTERS_B           ctr
   , 	CS_CSI_COUNTER_GROUPS    cgrp
   , 	csm_item_instances_acc   acc
   , 	CSI_COUNTER_ASSOCIATIONS cas
WHERE   ctr.counter_id 		    = cas.counter_id
AND	    cas.source_object_code  = 'CP'
AND     ctr.counter_type		= 'REGULAR'
AND     cgrp.counter_group_id(+)= ctr.group_id
AND     cas.source_object_id    = acc.instance_id
AND		ctr.counter_id      	= p_counter_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_err_msg := 'Entering CSM_COUNTER_EVENT_PKG.CTR_MAKE_DIRTY_I_FOREACHUSER' || ' for PK ' || to_char(p_counter_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_COUNTER_EVENT_PKG.CTR_MAKE_DIRTY_I_FOREACHUSER', FND_LOG.LEVEL_PROCEDURE);

  -- Open USER IDs loop
  FOR r_user_id_rec IN  l_user_ids_csr(p_counter_id) LOOP
      -- Call Insert ACC
      CSM_ACC_PKG.Insert_Acc
             ( P_PUBLICATION_ITEM_NAMES => g_counters_pubi_name
              ,P_ACC_TABLE_NAME         => g_counters_acc_table_name
              ,P_SEQ_NAME               => g_counters_seq_name
              ,P_PK1_NAME               => g_counters_pk1_name
              ,P_PK1_NUM_VALUE          => p_counter_id
              ,P_USER_ID                => r_user_id_rec.user_id
             );
	  --R12 Inserting Relationship for each user
	  CSM_CNTR_RELATION_EVENT_PKG.COUNTER_RELATION_INS(p_counter_id,r_user_id_rec.user_id);

	   	--bug 5253769 INSERT COUNTER property for the user
	  CSM_COUNTER_PROPERTY_EVENT_PKG.COUNTER_PROPERTY_INS
		  			(P_COUNTER_ID => p_counter_id,
					 P_USER_ID    => r_user_id_rec.user_id,
					 P_ERROR_MSG  => p_error_msg,
					 X_RETURN_STATUS => x_return_status
					 );

   END LOOP ; --End USER IDs  loop

  l_err_msg := 'Leaving CSM_COUNTER_EVENT_PKG.CTR_MAKE_DIRTY_I_FOREACHUSER' || ' for PK ' || to_char(p_counter_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_COUNTER_EVENT_PKG.CTR_MAKE_DIRTY_I_FOREACHUSER', FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  WHEN OTHERS THEN
     IF l_user_ids_csr%ISOPEN  then
        CLOSE l_user_ids_csr;
     END IF;

     p_error_msg := ' FAILED CTR_MAKE_DIRTY_I_FOREACHUSER:' || to_char(p_counter_id);
     x_return_status := FND_API.G_RET_STS_ERROR;
     CSM_UTIL_PKG.LOG( p_error_msg, 'CSM_COUNTER_EVENT_PKG.CTR_MAKE_DIRTY_I_FOREACHUSER',FND_LOG.LEVEL_EXCEPTION);
     RAISE;
END CTR_MAKE_DIRTY_I_FOREACHUSER;

PROCEDURE CTR_VAL_MAKE_DIRTY_FOREACHUSER(p_ctr_grp_log_id cs_counter_grp_log.counter_grp_log_id%type,
                           p_error_msg     OUT NOCOPY    VARCHAR2,
                           x_return_status IN OUT NOCOPY VARCHAR2)
IS
l_counter_value_id CSI_COUNTER_READINGS.counter_value_id%TYPE;
l_err_msg VARCHAR2(4000);
l_user_id NUMBER;
l_counter_id NUMBER;
l_instance_id NUMBER;
l_max_counter_readings NUMBER;

CURSOR l_user_ids_csr (p_counter_grp_log_id cs_counter_grp_log.counter_grp_log_id%TYPE)
IS
SELECT  acc.user_id,
        cval.counter_value_id,
       	ctr.counter_id,
       	acc.instance_id
FROM 	CSI_COUNTER_READINGS	 cval,
		csi_counter_associations cas,
		csi_counters_b 			 ctr,
        csm_counters_acc 		 cnt_acc,
     	csm_item_instances_acc 	 acc
WHERE 	cval.transaction_id 	= p_counter_grp_log_id
AND 	cas.source_object_code 	= 'CP'
AND 	ctr.counter_id 			= cas.counter_id
AND 	acc.instance_id 		= cas.source_object_id
AND 	cnt_acc.user_id 		= acc.user_id
AND 	cnt_acc.counter_id 		= cval.counter_id
AND 	ctr.counter_id 			= cnt_acc.counter_id
AND  	ctr.counter_type 		= 'REGULAR';



CURSOR l_max_counter_readings_csr(p_counter_id IN NUMBER, p_instance_id in NUMBER,
                                  p_user_id IN NUMBER)
IS
SELECT cval.counter_value_id,
	   cval.value_timestamp
FROM   CSI_COUNTERS_B       	  cntrs,
	   CSI_COUNTER_READINGS		  cval,
	   CSI_COUNTER_ASSOCIATIONS   cas,
	   csm_item_instances_acc 	  iacc,
	   csm_counters_acc 		  acc
WHERE  acc.user_id 			  	  = p_user_id
AND    acc.counter_id 			  = p_counter_id
AND    iacc.user_id 			  = acc.user_id
AND	   cntrs.counter_id 		  = acc.counter_id
AND	   cntrs.counter_id 		  = cas.counter_id
AND	   cas.source_object_code 	  = 'CP'
AND    cas.source_object_id 	  = p_instance_id
AND    cntrs.counter_id 		  = cval.counter_id
AND	   cas.source_object_id 	  = iacc.instance_id
AND    cval.counter_id 			  = p_counter_id
AND EXISTS
	(SELECT 1
 	FROM 	csm_counter_values_acc cv_acc
 	WHERE 	cv_acc.user_id = acc.user_id
 	AND 	cv_acc.counter_value_id = cval.counter_value_id
	)
ORDER BY cval.value_timestamp desc;

l_max_counter_readings_rec l_max_counter_readings_csr%ROWTYPE;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_err_msg := 'Entering CSM_COUNTER_EVENT_PKG.CTR_VAL_MAKE_DIRTY_FOREACHUSER' || ' for cnt_grp_log_id ' || to_char(p_ctr_grp_log_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_COUNTER_EVENT_PKG.CTR_VAL_MAKE_DIRTY_FOREACHUSER', FND_LOG.LEVEL_PROCEDURE);

  FOR r_user_id_rec IN  l_user_ids_csr(p_ctr_grp_log_id) LOOP
   l_user_id := r_user_id_rec.user_id;
   l_counter_value_id := r_user_id_rec.counter_value_id;
   l_counter_id := r_user_id_rec.counter_id;
   l_instance_id := r_user_id_rec.instance_id;
   l_max_counter_readings := NVL(csm_profile_pkg.get_max_readings_per_counter(l_user_id),0);

    -- Call Insert ACC
      CSM_ACC_PKG.Insert_Acc
                ( P_PUBLICATION_ITEM_NAMES => g_counter_val_pubi_name
                 ,P_ACC_TABLE_NAME         => g_counter_val_acc_table_name
                 ,P_SEQ_NAME               => g_counter_val_seq_name
                 ,P_PK1_NAME               => g_counter_val_pk1_name
                 ,P_PK1_NUM_VALUE          => l_counter_value_id
                 ,P_USER_ID                => l_user_id
                );

	 --bug 5253769 INSERT COUNTER  PROPERTY READINGS property for the user
	  CSM_CTR_PROP_READ_EVENT_PKG.CTR_PROPERTY_READ_INS
		  			(P_COUNTER_VALUE_ID => l_counter_value_id,
					 P_USER_ID    		=> l_user_id,
					 P_ERROR_MSG  		=> p_error_msg,
					 X_RETURN_STATUS 	=> x_return_status
					 );

    -- purge older readings so to keep the record count at the history profile
    OPEN l_max_counter_readings_csr(l_counter_id, l_instance_id, l_user_id);
    LOOP
    FETCH l_max_counter_readings_csr INTO l_max_counter_readings_rec;
      IF l_max_counter_readings_csr%NOTFOUND THEN
        EXIT;
      END IF;

      -- delete counter readings so as to keep history number of readings on the device
      IF l_max_counter_readings_csr%ROWCOUNT >  l_max_counter_readings THEN
          --Call DELETE ACC
          CSM_ACC_PKG.Delete_Acc
                    ( P_PUBLICATION_ITEM_NAMES => g_counter_val_pubi_name
                     ,P_ACC_TABLE_NAME         => g_counter_val_acc_table_name
                     ,P_PK1_NAME               => g_counter_val_pk1_name
                     ,P_PK1_NUM_VALUE          => l_max_counter_readings_rec.counter_value_id
                     ,P_USER_ID                => l_user_id
                    );
	 	--bug 5253769 DELETE COUNTER  PROPERTY READINGS property for the user
	  	 CSM_CTR_PROP_READ_EVENT_PKG.CTR_PROPERTY_READ_DEL
		  			(P_COUNTER_VALUE_ID => l_max_counter_readings_rec.counter_value_id,
					 P_USER_ID    		=> l_user_id,
					 P_ERROR_MSG  		=> p_error_msg,
					 X_RETURN_STATUS 	=> x_return_status
					 );

      END IF;
    END LOOP;
    CLOSE l_max_counter_readings_csr;

  END LOOP ; --End USER IDs cursor loop

  l_err_msg := 'Leaving CSM_COUNTER_EVENT_PKG.CTR_VAL_MAKE_DIRTY_FOREACHUSER' || ' for cnt_grp_log_id ' || to_char(p_ctr_grp_log_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_COUNTER_EVENT_PKG.CTR_VAL_MAKE_DIRTY_FOREACHUSER', FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  WHEN OTHERS THEN
     IF l_user_ids_csr%ISOPEN  THEN
        CLOSE l_user_ids_csr;
     END IF;

     IF l_max_counter_readings_csr%ISOPEN THEN
        CLOSE l_max_counter_readings_csr;
     END IF;

     p_error_msg := ' FAILED CTR_VAL_MAKE_DIRTY_FOREACHUSER ctr_grp_log_id:' || to_char(p_ctr_grp_log_id);
     x_return_status := FND_API.G_RET_STS_ERROR;
     CSM_UTIL_PKG.LOG( p_error_msg, 'CSM_COUNTER_EVENT_PKG.CTR_VAL_MAKE_DIRTY_FOREACHUSER',FND_LOG.LEVEL_EXCEPTION);
     RAISE;
END CTR_VAL_MAKE_DIRTY_FOREACHUSER;

PROCEDURE CTR_VAL_MDIRTY_U_FOREACHUSER(p_ctr_grp_log_id cs_counter_grp_log.counter_grp_log_id%type,
                           p_error_msg     OUT NOCOPY    VARCHAR2,
                           x_return_status IN OUT NOCOPY VARCHAR2)
IS
l_err_msg VARCHAR2(4000);
l_user_id NUMBER;
l_counter_value_id CSI_COUNTER_READINGS.counter_value_id%TYPE;
l_publication_item_name varchar2(30);
l_accesslist asg_download.access_list;
l_resourcelist	asg_download.user_list;
l_dmllist char(1);
l_time_stamp DATE;
l_counter_value_count NUMBER;
l_markdirty	boolean;

CURSOR l_user_ids_csr (p_counter_grp_log_id cs_counter_grp_log.counter_grp_log_id%type)
IS
SELECT acc.user_id,
       acc.access_id,
       cv.counter_value_id
FROM   csm_counter_values_acc acc,
       CSI_COUNTER_READINGS   cv
WHERE  acc.counter_value_id = cv.counter_value_id
AND    cv.transaction_id 	= p_counter_grp_log_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_err_msg := 'Entering CSM_COUNTER_EVENT_PKG.CTR_VAL_MDIRTY_U_FOREACHUSER' || ' for cnt_grp_log_id ' || to_char(p_ctr_grp_log_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_COUNTER_EVENT_PKG.CTR_VAL_MDIRTY_U_FOREACHUSER', FND_LOG.LEVEL_PROCEDURE);

   l_publication_item_name := 'CSF_M_COUNTER_VALUES';
   l_dmllist := CSM_UTIL_PKG.GetAsgDmlConstant(ASG_DOWNLOAD.UPD);
   l_counter_value_count := 0;
   l_time_stamp := SYSDATE;

   FOR r_user_id_rec IN l_user_ids_csr(l_counter_value_id) LOOP
     l_counter_value_count := l_counter_value_count + 1;
     l_resourcelist(l_counter_value_count) := r_user_id_rec.user_id;
     l_accesslist(l_counter_value_count) := r_user_id_rec.access_id;
   END LOOP;

   IF l_accesslist.count > 0 THEN
    l_markdirty := csm_util_pkg.MakeDirtyForUser (l_publication_item_name
                                , l_accesslist
                                , l_resourcelist
                                , l_dmllist
                                , l_time_stamp);

     IF  NOT l_markdirty THEN
   	     NULL;
     END IF;
   END IF;

   FOR r_user_id_rec IN l_user_ids_csr(l_counter_value_id) LOOP
   	 	--bug 5253769 DELETE COUNTER  PROPERTY READINGS property for the user
	  	 CSM_CTR_PROP_READ_EVENT_PKG.CTR_PROPERTY_READ_UPD
		  			(P_COUNTER_VALUE_ID => l_counter_value_id,
					 P_USER_ID    		=> r_user_id_rec.user_id,
					 P_ERROR_MSG  		=> p_error_msg,
					 X_RETURN_STATUS 	=> x_return_status
					 );

   END LOOP;

  l_err_msg := 'Leaving CSM_COUNTER_EVENT_PKG.CTR_VAL_MDIRTY_U_FOREACHUSER' || ' for cnt_grp_log_id ' || to_char(p_ctr_grp_log_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_COUNTER_EVENT_PKG.CTR_VAL_MDIRTY_U_FOREACHUSER', FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  WHEN OTHERS THEN
     IF l_user_ids_csr%ISOPEN  then
        CLOSE l_user_ids_csr;
     END IF;

     p_error_msg := ' FAILED CTR_VAL_MDIRTY_U_FOREACHUSER ctr_grp_log_id:' || to_char(p_ctr_grp_log_id);
     x_return_status := FND_API.G_RET_STS_ERROR;
     CSM_UTIL_PKG.LOG( p_error_msg, 'CSM_COUNTER_EVENT_PKG.CTR_VAL_MDIRTY_U_FOREACHUSER',FND_LOG.LEVEL_EXCEPTION);
     RAISE;
END CTR_VAL_MDIRTY_U_FOREACHUSER;

PROCEDURE COUNTER_MDIRTY_I(p_counter_id IN NUMBER,
                           p_user_id IN NUMBER,
                           p_error_msg     OUT NOCOPY    VARCHAR2,
                           x_return_status IN OUT NOCOPY VARCHAR2)
IS
l_err_msg VARCHAR2(4000);
l_user_id NUMBER;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_err_msg := 'Entering CSM_COUNTER_EVENT_PKG.COUNTER_MDIRTY_I' || ' for cnt_id ' || to_char(p_counter_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_COUNTER_EVENT_PKG.COUNTER_MDIRTY_I', FND_LOG.LEVEL_PROCEDURE);

  CSM_ACC_PKG.Insert_Acc
    ( P_PUBLICATION_ITEM_NAMES => g_counters_pubi_name
     ,P_ACC_TABLE_NAME         => g_counters_acc_table_name
     ,P_SEQ_NAME               => g_counters_seq_name
     ,P_PK1_NAME               => g_counters_pk1_name
     ,P_PK1_NUM_VALUE          => p_counter_id
     ,P_USER_ID                => p_user_id
    );

  --R12 Inserting Relationship for the counter & user
  CSM_CNTR_RELATION_EVENT_PKG.COUNTER_RELATION_INS(p_counter_id,p_user_id);

  --bug 5253769 INSERT COUNTER property for the user
  CSM_COUNTER_PROPERTY_EVENT_PKG.COUNTER_PROPERTY_INS
		  			(P_COUNTER_ID => p_counter_id,
					 P_USER_ID    => p_user_id,
					 P_ERROR_MSG  => p_error_msg,
					 X_RETURN_STATUS => x_return_status
					 );


  l_err_msg := 'Leaving CSM_COUNTER_EVENT_PKG.COUNTER_MDIRTY_I' || ' for cnt_id ' || to_char(p_counter_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_COUNTER_EVENT_PKG.COUNTER_MDIRTY_I', FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  WHEN others THEN
     p_error_msg := ' FAILED COUNTER_MDIRTY_I:' || to_char(p_counter_id);
     x_return_status := FND_API.G_RET_STS_ERROR;
     CSM_UTIL_PKG.LOG( p_error_msg, 'CSM_COUNTER_EVENT_PKG.COUNTER_MDIRTY_I',FND_LOG.LEVEL_EXCEPTION);
     RAISE;
END COUNTER_MDIRTY_I;

PROCEDURE COUNTER_VALS_MAKE_DIRTY_I_GRP(p_counter_id IN NUMBER,
                                        p_instance_id IN NUMBER,
                                        p_user_id IN NUMBER,
                                        p_error_msg     OUT NOCOPY    VARCHAR2,
                                        x_return_status IN OUT NOCOPY VARCHAR2)
IS
l_err_msg VARCHAR2(4000);
l_counter_value_id CSI_COUNTER_READINGS.counter_value_id%TYPE;

CURSOR l_counter_value_csr(p_counter_id cs_counters.counter_id%TYPE, p_instance_id NUMBER,
                           p_user_id NUMBER)
IS
SELECT cval.value_timestamp,
	   cval.counter_value_id
FROM   CSI_COUNTERS_B       	  cntrs,
	   CSI_COUNTER_READINGS		  cval,
	   CSI_COUNTER_ASSOCIATIONS   cas,
	   csm_counters_acc 		  cnt_acc,
	   csm_item_instances_acc 	  acc
WHERE  cntrs.counter_id 		  = cas.counter_id
AND	   cas.source_object_code 	  = 'CP'
AND    cas.source_object_id 	  = p_instance_id
AND    cntrs.counter_id 		  = cval.counter_id
AND	   cas.source_object_id 	  = acc.instance_id
AND	   acc.user_id 			  	  = p_user_id
AND	   acc.user_id 			  	  = cnt_acc.user_id
AND    cval.counter_id 			  = p_counter_id
AND    cval.counter_id 			  = cnt_acc.counter_id
ORDER  BY cval.value_timestamp desc;

r_counter_value_rec l_counter_value_csr%ROWTYPE;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_err_msg := 'Entering CSM_COUNTER_EVENT_PKG.COUNTER_VALS_MAKE_DIRTY_I_GRP' || ' for cnt_id ' || to_char(p_counter_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_COUNTER_EVENT_PKG.COUNTER_VALS_MAKE_DIRTY_I_GRP', FND_LOG.LEVEL_PROCEDURE);

  OPEN l_counter_value_csr(p_counter_id, p_instance_id, p_user_id);
  LOOP
  FETCH l_counter_value_csr INTO r_counter_value_rec;
  EXIT WHEN ((l_counter_value_csr%NOTFOUND) OR (l_counter_value_csr%ROWCOUNT > csm_profile_pkg.get_max_readings_per_counter(p_user_id)));

       l_counter_value_id := r_counter_value_rec.counter_value_id;

        --Call Insert ACC
        CSM_ACC_PKG.Insert_Acc
                ( P_PUBLICATION_ITEM_NAMES => g_counter_val_pubi_name
                 ,P_ACC_TABLE_NAME         => g_counter_val_acc_table_name
                 ,P_SEQ_NAME               => g_counter_val_seq_name
                 ,P_PK1_NAME               => g_counter_val_pk1_name
                 ,P_PK1_NUM_VALUE          => l_counter_value_id
                 ,P_USER_ID                => p_user_id
                );

  		--bug 5253769 INSERT COUNTER property Readings for the user
		  CSM_CTR_PROP_READ_EVENT_PKG.CTR_PROPERTY_READ_INS
		  			(P_COUNTER_VALUE_ID    => l_counter_value_id,
					 P_USER_ID       	   => p_user_id,
					 P_ERROR_MSG     	   => p_error_msg,
					 X_RETURN_STATUS 	   => x_return_status
					 );

  END LOOP;
  IF l_counter_value_csr%ISOPEN THEN
    CLOSE l_counter_value_csr;
  END IF;

  l_err_msg := 'Leaving CSM_COUNTER_EVENT_PKG.COUNTER_VALS_MAKE_DIRTY_I_GRP' || ' for cnt_id ' || to_char(p_counter_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_COUNTER_EVENT_PKG.COUNTER_VALS_MAKE_DIRTY_I_GRP', FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  WHEN others THEN
     IF l_counter_value_csr%ISOPEN THEN
        CLOSE l_counter_value_csr;
     END IF;
     p_error_msg := ' FAILED COUNTER_VALS_MAKE_DIRTY_I_GRP:' || to_char(p_counter_id);
     x_return_status := FND_API.G_RET_STS_ERROR;
     CSM_UTIL_PKG.LOG( p_error_msg, 'CSM_COUNTER_EVENT_PKG.COUNTER_VALS_MAKE_DIRTY_I_GRP',FND_LOG.LEVEL_EXCEPTION);
     RAISE;
END COUNTER_VALS_MAKE_DIRTY_I_GRP;

END CSM_COUNTER_EVENT_PKG; -- of package csm_counter_event_pkg

/
