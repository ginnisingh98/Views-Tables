--------------------------------------------------------
--  DDL for Package Body CSM_CUSTOM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_CUSTOM_PKG" AS
/* $Header: csmecusb.pls 120.1 2005/07/24 22:55:50 trajasek noship $*/
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

g_object_name  CONSTANT VARCHAR2(30) := 'CSM_CUSTOM_PKG';  -- package name
g_counter_val_acc_table_name     CONSTANT VARCHAR2(30) := 'CSM_COUNTER_VALUES_ACC';
g_counter_val_pk1_name           CONSTANT VARCHAR2(30) := 'COUNTER_VALUE_ID';
g_counter_val_pubi_name          CONSTANT CSM_ACC_PKG.t_publication_item_list :=
  CSM_ACC_PKG.t_publication_item_list('CSF_M_COUNTER_VALUES');

PROCEDURE counter_values_del(p_counter_value_id IN number, x_return_status OUT NOCOPY  varchar2)
IS
l_err_msg varchar2(4000);

CURSOR l_counter_values_csr(p_counter_value_id IN number)
IS
SELECT user_id, counter_value_id
FROM csm_counter_values_acc acc
WHERE counter_value_id = p_counter_value_id;

BEGIN
   FOR r_counter_values_csr IN l_counter_values_csr(p_counter_value_id) LOOP
            CSM_ACC_PKG.Delete_Acc
                   ( P_PUBLICATION_ITEM_NAMES => g_counter_val_pubi_name
                    ,P_ACC_TABLE_NAME         => g_counter_val_acc_table_name
                    ,P_PK1_NAME               => g_counter_val_pk1_name
                    ,P_PK1_NUM_VALUE          => r_counter_values_csr.counter_value_id
                    ,P_USER_ID                => r_counter_values_csr.user_id
                   );
   END LOOP;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

 EXCEPTION
   WHEN others THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_err_msg := 'Exception occurred in ' || g_object_name || '.counter_values_del: ' || substr(SQLERRM, 1, 240)|| ' for PK ' || to_char(p_counter_value_id);
     CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_CUSTOM_PKG.COUNTER_VALUES_DEL', FND_LOG.LEVEL_EXCEPTION);
END counter_values_del;

END CSM_CUSTOM_PKG;

/
