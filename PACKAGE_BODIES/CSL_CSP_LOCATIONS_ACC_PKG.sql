--------------------------------------------------------
--  DDL for Package Body CSL_CSP_LOCATIONS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_CSP_LOCATIONS_ACC_PKG" AS
/* $Header: cslsaacb.pls 120.0 2005/05/25 11:02:56 appldev noship $ */

/*** Globals ***/
-- CSP_RS_CUST_RELATIONS
g_acc_table_name1        CONSTANT VARCHAR2(30) := 'JTM_CSP_RS_CUST_RELATIONS_ACC';
g_publication_item_name1 CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('CSP_RS_CUST_RELATIONS');
g_pk1_name1              CONSTANT VARCHAR2(30) := 'RS_CUST_RELATION_ID';
-- HZ_CUST_ACCT_SITES_ALL
g_acc_table_name2        CONSTANT VARCHAR2(30) := 'CSL_HZ_CUST_ACCT_SITES_ALL_ACC';
g_publication_item_name2 CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('CSL_HZ_CUST_ACCT_SITES');
g_pk1_name2              CONSTANT VARCHAR2(30) := 'CUST_ACCT_SITE_ID';
-- HZ_CUST_SITE_USES_ALL
g_acc_table_name3        CONSTANT VARCHAR2(30) := 'CSL_HZ_CUST_SITE_USES_ALL_ACC';
g_publication_item_name3 CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('CSL_HZ_CUST_SITE_USES');
g_pk1_name3              CONSTANT VARCHAR2(30) := 'SITE_USE_ID';
-- PO_LOCATION_ASSOCIATIONS_ALL
g_acc_table_name4        CONSTANT VARCHAR2(30) := 'JTM_PO_LOC_ASS_ALL_ACC';
g_publication_item_name4 CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('PO_LOC_ASS_ALL');
g_pk1_name4              CONSTANT VARCHAR2(30) := 'LOCATION_ID';

g_table_name            CONSTANT VARCHAR2(30) := 'PO_LOCATION_ASSOCIATIONS_ALL';
g_debug_level           NUMBER; -- debug level

/*** Function that checks if location record(s) should be replicated. Returns TRUE if it should ***/
FUNCTION Replicate_Record
  ( p_location_id NUMBER
  )
RETURN BOOLEAN
IS
  CURSOR c_location (b_location_id NUMBER) IS
   SELECT PLA.location_id                 LOCATION_ID
   ,      CSU.status                      STATUS
   ,      RCR.resource_id                 RESOURCE_ID
   FROM   PO_LOCATION_ASSOCIATIONS_ALL PLA
   ,      HZ_CUST_SITE_USES_ALL        CSU
   ,      HZ_CUST_ACCT_SITES_ALL       CAS
   ,      CSP_RS_CUST_RELATIONS       RCR
   ,      HZ_PARTY_SITES               HPS
   ,      HZ_LOCATIONS                 HZL
   WHERE  PLA.location_id       = b_location_id
   AND    CSU.site_use_id       = PLA.site_use_id
   AND    CSU.site_use_code     = 'SHIP_TO'
   AND    CSU.cust_acct_site_id = CAS.cust_acct_site_id
   AND    CAS.cust_account_id   = RCR.customer_id
   AND    CAS.party_site_id     = HPS.party_site_id
   AND    HPS.location_id       = HZL.location_id
   AND    PLA.LOCATION_ID       = b_location_id;
  r_location c_location%ROWTYPE;

BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_location_id
    , g_table_name
    , 'Entering Replicate_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  OPEN c_location( p_location_id );
  FETCH c_location INTO r_location;
  IF c_location%NOTFOUND THEN
    /*** could not find location record -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( p_location_id
      , g_table_name
      , 'Replicate_Record error: Could not find record associated with PO_LOCATION_ASSOCIATIONS_ALL.LOCATION_ID '
        || p_location_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
    END IF;

    CLOSE c_location;
    RETURN FALSE;
  END IF;

  CLOSE c_location;

  /*** is resource a mobile user? ***/
  IF NOT JTM_HOOK_UTIL_PKG.isMobileFSresource( r_location.resource_id ) THEN
    /*** No -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_location_id
      , g_table_name
      , 'Replicate_Record returned FALSE' || fnd_global.local_chr(10) ||
        'Resource_id ' || r_location.resource_id || ' is not a mobile user.'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    RETURN FALSE;
  END IF;


  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_location_id
    , g_table_name
    , 'Replicate_Record returned TRUE'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /** Record matched criteria -> return true ***/
  RETURN TRUE;
END Replicate_Record;

/*** Private procedure that replicates given location related data for resource ***/
PROCEDURE Insert_ACC_Record
  ( p_location_id        IN NUMBER
  )
IS
  CURSOR c_location_ids (b_location_id NUMBER) IS
   SELECT CSU.site_use_id                 CSU_ID
   ,      CAS.cust_acct_site_id           CAS_ID
   ,      RCR.RS_CUST_RELATION_ID         RCR_ID
   ,      HPS.party_site_id               HPS_ID
   ,      RCR.RESOURCE_ID                 RESOURCE_ID
   FROM   PO_LOCATION_ASSOCIATIONS_ALL PLA
   ,      HZ_CUST_SITE_USES_ALL        CSU
   ,      HZ_CUST_ACCT_SITES_ALL       CAS
   ,      CSP_RS_CUST_RELATIONS       RCR
   ,      HZ_PARTY_SITES               HPS
   WHERE  PLA.location_id       = b_location_id
   AND    CSU.site_use_id       = PLA.site_use_id
   AND    CSU.site_use_code     = 'SHIP_TO'
   AND    CSU.cust_acct_site_id = CAS.cust_acct_site_id
   AND    CAS.cust_account_id   = RCR.customer_id
   AND    CAS.party_site_id     = HPS.party_site_id
   AND    PLA.LOCATION_ID       = b_location_id;
  r_location_ids c_location_ids%ROWTYPE;
  l_resource_id  NUMBER;
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_location_id
    , g_table_name
    , 'Entering Insert_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_location_id
    , g_table_name
    , 'Inserting ACC record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  -- get all of the primary key values, these must be inserted into the ACC tables
  OPEN c_location_ids( p_location_id );
  FETCH c_location_ids INTO r_location_ids;
  IF c_location_ids%NOTFOUND THEN
    /*** could not find location record -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( p_location_id
      , g_table_name
      , 'Insert ACC Record error: Could not find record associated with PO_LOCATION_ASSOCIATIONS_ALL.LOCATION_ID ' || p_location_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
    END IF;
  ELSE

    l_resource_id := r_location_ids.RESOURCE_ID;

    -- CSP_RS_CUST_RELATIONS
   JTM_HOOK_UTIL_PKG.Insert_Acc
      (  P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
       , P_ACC_TABLE_NAME         => g_acc_table_name1
       , P_PK1_NAME               => g_pk1_name1
       , P_PK1_NUM_VALUE          => r_location_ids.RCR_ID
       , P_RESOURCE_ID            => l_resource_id
      );
    -- HZ_CUST_ACCT_SITES_ALL
    JTM_HOOK_UTIL_PKG.Insert_Acc
    (  P_PUBLICATION_ITEM_NAMES => g_publication_item_name2
     , P_ACC_TABLE_NAME         => g_acc_table_name2
     , P_PK1_NAME               => g_pk1_name2
     , P_PK1_NUM_VALUE          => r_location_ids.CAS_ID
     , P_RESOURCE_ID            => l_resource_id
    );
    -- HZ_CUST_SITE_USES_ALL
    JTM_HOOK_UTIL_PKG.Insert_Acc
    (  P_PUBLICATION_ITEM_NAMES => g_publication_item_name3
     , P_ACC_TABLE_NAME         => g_acc_table_name3
     , P_PK1_NAME               => g_pk1_name3
     , P_PK1_NUM_VALUE          => r_location_ids.CSU_ID
     , P_RESOURCE_ID            => l_resource_id
    );
    -- PO_LOCATION_ASSOCIATIONS_ALL
    JTM_HOOK_UTIL_PKG.Insert_Acc
    (  P_PUBLICATION_ITEM_NAMES => g_publication_item_name4
     , P_ACC_TABLE_NAME         => g_acc_table_name4
     , P_PK1_NAME               => g_pk1_name4
     , P_PK1_NUM_VALUE          => p_location_id
     , P_RESOURCE_ID            => l_resource_id
    );

  -- HZ_PARTY_SITES ( ALSO HZ_LOCATIONS IS FILLED BY THIS HOOK )
    CSL_HZ_PARTY_SITES_ACC_PKG.INSERT_PARTY_SITE( r_location_ids.HPS_ID, l_resource_id );
  END IF;
  CLOSE c_location_ids;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_location_id
    , g_table_name
    , 'Leaving Insert_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Insert_ACC_Record;

/*** Private procedure that re-sends given assignment to mobile ***/
PROCEDURE Update_ACC_Record
  ( p_location_id        IN NUMBER
  )
IS
  CURSOR c_location_ids (b_location_id NUMBER) IS
   SELECT CSU.site_use_id                 CSU_ID
   ,      CAS.cust_acct_site_id           CAS_ID
   ,      RCR.RS_CUST_RELATION_ID         RCR_ID
   ,      HPS.party_site_id               HPS_ID
   ,      HZL.location_id                 HZL_ID
   ,      RCR.resource_id                 RESOURCE_ID
   FROM   PO_LOCATION_ASSOCIATIONS_ALL PLA
   ,      HZ_CUST_SITE_USES_ALL        CSU
   ,      HZ_CUST_ACCT_SITES_ALL       CAS
   ,      CSP_RS_CUST_RELATIONS       RCR
   ,      HZ_PARTY_SITES               HPS
   ,      HZ_LOCATIONS                 HZL
   WHERE  PLA.location_id       = b_location_id
   AND    CSU.site_use_id       = PLA.site_use_id
   AND    CSU.site_use_code     = 'SHIP_TO'
   AND    CSU.cust_acct_site_id = CAS.cust_acct_site_id
   AND    CAS.cust_account_id   = RCR.customer_id
   AND    CAS.party_site_id     = HPS.party_site_id
   AND    HPS.location_id       = HZL.location_id
   AND    PLA.LOCATION_ID       = b_location_id;
  r_location_ids c_location_ids%ROWTYPE;

  l_rcr_acc_id  NUMBER;
  l_cas_acc_id  NUMBER;
  l_csu_acc_id  NUMBER;
  l_pla_acc_id  NUMBER;
  l_hps_acc_id  NUMBER;
  l_hzl_acc_id  NUMBER;
  l_resource_id NUMBER;
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_location_id
    , g_table_name
    , 'Entering Update_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_location_id
    , g_table_name
    , 'Updating ACC record(s)'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  -- get all of the primary key values, these must be inserted into the ACC tables
  OPEN c_location_ids( p_location_id );
  FETCH c_location_ids INTO r_location_ids;
  IF c_location_ids%NOTFOUND THEN
    /*** could not find location record -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( p_location_id
      , g_table_name
      , 'Update ACC Record error: Could not find record associated with PO_LOCATION_ASSOCIATIONS_ALL.LOCATION_ID '
        || p_location_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
    END IF;
  ELSE
    l_resource_id := r_location_ids.RESOURCE_ID;

    -- CSP_RS_CUST_RELATIONS
    l_rcr_acc_id := JTM_HOOK_UTIL_PKG.Get_Acc_Id(
                      P_ACC_TABLE_NAME   => g_acc_table_name1
                    , P_PK1_NAME         => g_pk1_name1
                    , P_PK1_NUM_VALUE    => r_location_ids.RCR_ID
                    , P_RESOURCE_ID      => l_resource_id);
    JTM_HOOK_UTIL_PKG.Update_Acc
     ( g_publication_item_name1
      ,g_acc_table_name1
      ,l_resource_id
      ,l_rcr_acc_id
     );
    -- HZ_CUST_ACCT_SITES_ALL
    l_cas_acc_id := JTM_HOOK_UTIL_PKG.Get_Acc_Id(
                      P_ACC_TABLE_NAME   => g_acc_table_name2
                    , P_PK1_NAME         => g_pk1_name2
                    , P_PK1_NUM_VALUE    => r_location_ids.CAS_ID
                    , P_RESOURCE_ID      => l_resource_id);
    JTM_HOOK_UTIL_PKG.Update_Acc
     ( g_publication_item_name2
      ,g_acc_table_name2
      ,l_resource_id
      ,l_cas_acc_id
     );
    -- HZ_CUST_SITE_USES_ALL
    l_csu_acc_id := JTM_HOOK_UTIL_PKG.Get_Acc_Id(
                      P_ACC_TABLE_NAME   => g_acc_table_name3
                    , P_PK1_NAME         => g_pk1_name3
                    , P_PK1_NUM_VALUE    => r_location_ids.CSU_ID
                    , P_RESOURCE_ID      => l_resource_id);
    JTM_HOOK_UTIL_PKG.Update_Acc
     ( g_publication_item_name3
      ,g_acc_table_name3
      ,l_resource_id
      ,l_csu_acc_id
     );
    -- PO_LOCATION_ASSOCIATIONS_ALL
    l_pla_acc_id := JTM_HOOK_UTIL_PKG.Get_Acc_Id(
                      P_ACC_TABLE_NAME   => g_acc_table_name4
                    , P_PK1_NAME         => g_pk1_name4
                    , P_PK1_NUM_VALUE    => p_location_id
                    , P_RESOURCE_ID      => l_resource_id);
    JTM_HOOK_UTIL_PKG.Update_Acc
     ( g_publication_item_name4
      ,g_acc_table_name4
      ,l_resource_id
      ,l_pla_acc_id
     );
    -- HZ_PARTY_SITES
    CSL_HZ_PARTY_SITES_ACC_PKG.UPDATE_PARTY_SITE( r_location_ids.HPS_ID );

    -- HZ_LOCATIONS
    CSL_HZ_LOCATIONS_ACC_PKG.UPDATE_LOCATION( r_location_ids.HZL_ID );
  END IF;

  CLOSE c_location_ids;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_location_id
    , g_table_name
    , 'Leaving Update_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Update_ACC_Record;

/*** Private procedure that deletes assignment for resource from acc table ***/
PROCEDURE Delete_ACC_Record
  ( p_location_id IN NUMBER
   ,p_resource_id IN NUMBER
  )
IS
  CURSOR c_location_ids (b_location_id NUMBER) IS
   SELECT CSU.site_use_id                 CSU_ID
   ,      CAS.cust_acct_site_id           CAS_ID
   ,      RCR.RS_CUST_RELATION_ID         RCR_ID
   ,      HPS.party_site_id               HPS_ID
   ,      RCR.RESOURCE_ID                 RESOURCE_ID
   FROM   PO_LOCATION_ASSOCIATIONS_ALL PLA
   ,      HZ_CUST_SITE_USES_ALL        CSU
   ,      HZ_CUST_ACCT_SITES_ALL       CAS
   ,      CSP_RS_CUST_RELATIONS       RCR
   ,      HZ_PARTY_SITES               HPS
   WHERE  PLA.location_id       = b_location_id
   AND    CSU.site_use_id       = PLA.site_use_id
   AND    CSU.site_use_code     = 'SHIP_TO'
   AND    CSU.cust_acct_site_id = CAS.cust_acct_site_id
   AND    CAS.cust_account_id   = RCR.customer_id
   AND    CAS.party_site_id     = HPS.party_site_id
   AND    PLA.LOCATION_ID       = b_location_id;
  r_location_ids c_location_ids%ROWTYPE;
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_location_id
    , g_table_name
    , 'Entering Delete_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_location_id
    , g_table_name
    , 'Deleting ACC record for resource_id = ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  -- No delete of the shipment addres is possible
  -- get all of the primary key values, these must be inserted into the ACC tables
  OPEN c_location_ids( p_location_id );
  FETCH c_location_ids INTO r_location_ids;
  IF c_location_ids%NOTFOUND THEN
    /*** could not find location record -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( p_location_id
      , g_table_name
      , 'Delete ACC Record error: Could not find record for LOCATION_ID ' || p_location_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
    END IF;
  ELSE
   IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
     ( p_resource_id
      , g_table_name
      , 'Delete CSP_RS_CUST_RELATIONS acc record for user: ' || p_resource_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;
    JTM_HOOK_UTIL_PKG.Delete_Acc
     (  P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
      , P_ACC_TABLE_NAME         => g_acc_table_name1
      , P_PK1_NAME               => g_pk1_name1
      , P_PK1_NUM_VALUE          => r_location_ids.RCR_ID
      , P_RESOURCE_ID            => p_resource_id
     );

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_resource_id
      , g_table_name
      , 'Delete HZ_CUST_ACCT_SITES_ALL acc record for user: ' || p_resource_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;
    JTM_HOOK_UTIL_PKG.Delete_Acc
     (  P_PUBLICATION_ITEM_NAMES => g_publication_item_name2
      , P_ACC_TABLE_NAME         => g_acc_table_name2
      , P_PK1_NAME               => g_pk1_name2
      , P_PK1_NUM_VALUE          => r_location_ids.CAS_ID
      , P_RESOURCE_ID            => p_resource_id
     );

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_resource_id
      , g_table_name
      , 'Delete HZ_CUST_SITE_USES_ALL acc record for user: ' || p_resource_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;
    JTM_HOOK_UTIL_PKG.Delete_Acc
     (  P_PUBLICATION_ITEM_NAMES => g_publication_item_name3
      , P_ACC_TABLE_NAME         => g_acc_table_name3
      , P_PK1_NAME               => g_pk1_name3
      , P_PK1_NUM_VALUE          => r_location_ids.CSU_ID
      , P_RESOURCE_ID            => p_resource_id
     );

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_resource_id
      , g_table_name
      , 'Delete PO_LOCATION_ASSOCIATIONS_ALL acc record for user: ' || p_resource_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;
    JTM_HOOK_UTIL_PKG.Delete_Acc
     (  P_PUBLICATION_ITEM_NAMES => g_publication_item_name4
      , P_ACC_TABLE_NAME         => g_acc_table_name4
      , P_PK1_NAME               => g_pk1_name4
      , P_PK1_NUM_VALUE          => p_location_id
      , P_RESOURCE_ID            => p_resource_id
     );

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_resource_id
      , g_table_name
      , 'Calling CSL_HZ_PARTY_SITES_ACC_PKG.Delete_Party_Site'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    CSL_HZ_PARTY_SITES_ACC_PKG.Delete_Party_Site( r_location_ids.HPS_ID, p_resource_id );
  END IF;
  CLOSE c_location_ids;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_location_id
    , g_table_name
    , 'Leaving Delete_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Delete_ACC_Record;

/*** Called before location Insert ***/
PROCEDURE PRE_INSERT_SHIP_LOCATION
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_INSERT_SHIP_LOCATION;

/*** Called after location Insert ***/
PROCEDURE POST_INSERT_SHIP_LOCATION
  ( x_return_status OUT NOCOPY varchar2
  )
IS
  l_location_id        NUMBER;
  l_enabled_flag       VARCHAR2(30);
BEGIN
  l_enabled_flag := JTM_PROFILE_UTL_PKG.GET_ENABLE_FLAG_AT_RESP( P_APP_SHORT_NAME => 'CSL');
  IF l_enabled_flag <>'Y' THEN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   RETURN;
  END IF;
  /*** get location record details from public API ***/
  l_location_id  := csp_ship_to_address_pvt.g_inv_loc_id;

  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_location_id
    , g_table_name
    , 'Entering POST_INSERT hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** Insert record if applicable ***/
  IF Replicate_Record(l_location_id) THEN
    Insert_ACC_Record(l_location_id);
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_location_id
    , g_table_name
    , 'Leaving POST_INSERT hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  RETURN;

EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( l_location_id
    , g_table_name
    , 'Caught exception in POST_INSERT hook:' || fnd_global.local_chr(10) || sqlerrm
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  fnd_msg_pub.Add_Exc_Msg('CSL_CSP_LOCATIONS_ACC_PKG','POST_INSERT_SHIP_LOCATION',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END POST_INSERT_SHIP_LOCATION;

/* Called before location Update */
PROCEDURE PRE_UPDATE_SHIP_LOCATION
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  fnd_msg_pub.Add_Exc_Msg('CSL_CSP_LOCATIONS_ACC_PKG','PRE_UPDATE_SHIP_LOCATION',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_UPDATE_SHIP_LOCATION;

/* Called after assignment Update */
PROCEDURE POST_UPDATE_SHIP_LOCATION
  ( x_return_status OUT NOCOPY varchar2
  )
IS
  l_location_id        NUMBER;
  l_enabled_flag       VARCHAR2(30);
BEGIN
  l_enabled_flag := JTM_PROFILE_UTL_PKG.GET_ENABLE_FLAG_AT_RESP( P_APP_SHORT_NAME => 'CSL');
  IF l_enabled_flag <>'Y' THEN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   RETURN;
  END IF;
  /*** get assignment record details from public API ***/
  l_location_id := csp_ship_to_address_pvt.g_inv_loc_id;

  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_location_id
    , g_table_name
    , 'Entering POST_UPDATE hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF Replicate_Record( l_location_id ) THEN
    Update_ACC_Record(l_location_id);
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_location_id
    , g_table_name
    , 'Leaving POST_UPDATE hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( l_location_id
    , g_table_name
    , 'Caught exception in POST_UPDATE hook:' || fnd_global.local_chr(10) || sqlerrm
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  fnd_msg_pub.Add_Exc_Msg('CSL_JTF_TASKS_ACC_PKG','POST_UPDATE_SHIP_LOCATION',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END POST_UPDATE_SHIP_LOCATION;

/* Called before assignment Delete */
PROCEDURE PRE_DELETE_SHIP_LOCATION
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_DELETE_SHIP_LOCATION;

/* Called after assignment Delete */
PROCEDURE POST_DELETE_SHIP_LOCATION
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  fnd_msg_pub.Add_Exc_Msg('CSL_CSP_LOCATIONS_ACC_PKG','POST_DELETE_SHIP_LOCATION',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END POST_DELETE_SHIP_LOCATION;

/* Remove all ACC resords of a mobile user */
PROCEDURE Delete_All_ACC_Records
  ( p_resource_id in NUMBER
  , x_return_status OUT NOCOPY varchar2
  )
IS
 CURSOR c_location( b_resource_id NUMBER ) IS
  SELECT PLA.LOCATION_ID
  FROM   PO_LOCATION_ASSOCIATIONS_ALL PLA
  ,      HZ_CUST_SITE_USES_ALL        CSU
  ,      HZ_CUST_ACCT_SITES_ALL       CAS
  ,      CSP_RS_CUST_RELATIONS       RCR
  ,      HZ_PARTY_SITES               HPS
  WHERE  CSU.site_use_id       = PLA.site_use_id
  AND    CSU.site_use_code     = 'SHIP_TO'
  AND    CSU.cust_acct_site_id = CAS.cust_acct_site_id
  AND    CAS.cust_account_id   = RCR.customer_id
  AND    CAS.party_site_id     = HPS.party_site_id
  AND    RCR.RESOURCE_ID       = b_resource_id;
BEGIN
 /*** get debug level ***/
 g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Entering Delete_All_ACC_Records procedure for user: ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  FOR r_location IN c_location( p_resource_id ) LOOP
    Delete_ACC_Record(r_location.location_id, p_resource_id );
  END LOOP;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Leaving Delete_All_ACC_Records procedure for user: ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  fnd_msg_pub.Add_Exc_Msg('CSL_CSP_LOCATIONS_ACC_PKG','Delete_All_ACC_Records',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END Delete_All_ACC_Records;

/* Full synch for a mobile user */
PROCEDURE Insert_All_ACC_Records
  ( p_resource_id in NUMBER
  , x_return_status OUT NOCOPY varchar2
  )
IS
 CURSOR c_location( b_resource_id NUMBER ) IS
  SELECT PLA.LOCATION_ID
  FROM   PO_LOCATION_ASSOCIATIONS_ALL PLA
  ,      HZ_CUST_SITE_USES_ALL        CSU
  ,      HZ_CUST_ACCT_SITES_ALL       CAS
  ,      CSP_RS_CUST_RELATIONS       RCR
  ,      HZ_PARTY_SITES               HPS
  WHERE  CSU.site_use_id       = PLA.site_use_id
  AND    CSU.site_use_code     = 'SHIP_TO'
  AND    CSU.cust_acct_site_id = CAS.cust_acct_site_id
  AND    CAS.cust_account_id   = RCR.customer_id
  AND    CAS.party_site_id     = HPS.party_site_id
  AND    RCR.RESOURCE_ID       = b_resource_id;

BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Entering Insert_All_ACC_Records procedure for user: ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  FOR r_location IN c_location( p_resource_id ) LOOP
    IF Replicate_Record(r_location.location_id) THEN
      Insert_ACC_Record(r_location.location_id);
    END IF;
  END LOOP;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Leaving Insert_All_ACC_Records procedure for user: ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  fnd_msg_pub.Add_Exc_Msg('CSL_CSP_LOCATIONS_ACC_PKG','Insert_All_ACC_Records',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END Insert_All_ACC_Records;

END CSL_CSP_LOCATIONS_ACC_PKG;

/
