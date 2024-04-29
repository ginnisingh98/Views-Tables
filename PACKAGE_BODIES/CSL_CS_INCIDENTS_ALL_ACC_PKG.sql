--------------------------------------------------------
--  DDL for Package Body CSL_CS_INCIDENTS_ALL_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_CS_INCIDENTS_ALL_ACC_PKG" AS
/* $Header: cslinacb.pls 120.0 2005/05/30 07:41:03 appldev noship $ */

/*** Globals ***/
g_acc_table_name        CONSTANT VARCHAR2(30) := 'CSL_CS_INCIDENTS_ALL_ACC';
g_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('CSL_CS_INCIDENTS_ALL_VL');
g_table_name            CONSTANT VARCHAR2(30) := 'CS_INCIDENTS_ALL';
g_pk1_name              CONSTANT VARCHAR2(30) := 'INCIDENT_ID';

g_debug_level           NUMBER;  -- debug level
g_replicate_pre_update  BOOLEAN; -- true when incident was replicated before the update

TYPE g_pre_update_rec IS  RECORD(
  INCIDENT_ID              NUMBER,
  CUSTOMER_ID              NUMBER,
  INCIDENT_LOCATION_ID     NUMBER,
  CUSTOMER_PRODUCT_ID      NUMBER,
  INVENTORY_ITEM_ID        NUMBER,
  INV_ORGANIZATION_ID      NUMBER,
  CONTRACT_SERVICE_ID      NUMBER
);

g_cached_rec     CSL_CS_INCIDENTS_ALL_ACC_PKG.g_pre_update_rec; --record to cache changes

/*** Function that checks if task record should be replicated. Returns TRUE if it should ***/
FUNCTION Replicate_Record
  ( p_incident_id NUMBER
  )
RETURN BOOLEAN
IS
  CURSOR c_incident (b_incident_id NUMBER) IS
   SELECT incident_id  -- Sql Performance Fix
   FROM CS_INCIDENTS_ALL_B
   WHERE incident_id = b_incident_id;
  r_incident c_incident%ROWTYPE;

BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name
    , 'Entering Replicate_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  OPEN c_incident( p_incident_id );
  FETCH c_incident INTO r_incident;
  IF c_incident%NOTFOUND THEN
    /*** could not find incident record -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( p_incident_id
      , g_table_name
      , 'Replicate_Record error: Could not find incident_id ' || p_incident_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    CLOSE c_incident;
    RETURN FALSE;
  END IF;
  CLOSE c_incident;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name
    , 'Replicate_Record returned TRUE'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /** Record matched criteria -> return true ***/
  RETURN TRUE;
END Replicate_Record;

/*** Private procedure that replicates given incident related data for resource ***/
PROCEDURE Insert_ACC_Record
  ( p_incident_id IN NUMBER
   ,p_resource_id IN NUMBER
   ,p_flow_type   IN NUMBER
  )
IS
 CURSOR c_incident (b_incident_id NUMBER) IS
    --  11.5.10 Changes - 3430663. Get based on incident_location_id not
    --  on install_site_id
   SELECT customer_id, incident_location_id, customer_product_id,
     inventory_item_id, inv_organization_id
   FROM CS_INCIDENTS_ALL_B
   WHERE incident_id = b_incident_id;
  r_incident c_incident%ROWTYPE;

  l_return         BOOLEAN;
  l_status         VARCHAR2(30);
  l_stmt           VARCHAR2(4000);
  l_cursorid       INTEGER;
  l_execute_status INTEGER;

BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name
    , 'Entering Insert_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name
    , 'Inserting ACC record for resource_id = ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /*** Insert incident ACC record ***/
  JTM_HOOK_UTIL_PKG.Insert_Acc
   ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
    ,P_ACC_TABLE_NAME         => g_acc_table_name
    ,P_RESOURCE_ID            => p_resource_id
    ,P_PK1_NAME               => g_pk1_name
    ,P_PK1_NUM_VALUE          => p_incident_id
   );

  /**************************************************************
   Call all incident related insert hook packages
   these records are no show stoppers for incidents
   hence it is not nessacary to put the in the pre_insert_child
   function
  ***************************************************************/
  OPEN c_incident( p_incident_id );
  FETCH c_incident INTO r_incident;
  IF c_incident%FOUND THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_incident_id
      , g_table_name
      , 'Inserting non-critical dependant records'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    -- PARTY
    IF r_incident.customer_id IS NOT NULL THEN
      CSL_HZ_PARTIES_ACC_PKG.INSERT_PARTY( r_incident.customer_id,
                                           p_resource_id, p_flow_type );
    END IF;

    -- PARTY_SITE
    --  11.5.10 Changes - 3430663. Get based on incident_location_id not
    --  on install_site_id
    IF r_incident.incident_location_id IS NOT NULL THEN
      CSL_HZ_PARTY_SITES_ACC_PKG.INSERT_PARTY_SITE(
                              r_incident.incident_location_id, p_resource_id );
    END IF;

    -- CONTACT POINTS
    CSL_PARTY_CONTACTS_ACC_PKG.INSERT_CS_HZ_SR_CONTACTS( p_incident_id,
                                                p_resource_id, p_flow_type );

    -- NOTES
    IF p_flow_type <> G_FLOW_HISTORY THEN
      l_return := CSL_JTF_NOTES_ACC_PKG.PRE_INSERT_CHILDREN
                                      ( P_SOURCE_OBJ_ID   => p_incident_id
    				      , P_SOURCE_OBJ_CODE => 'SR'
  				      , P_RESOURCE_ID     => p_resource_id );
    END IF;

    -- ITEM INSTANCES
    -- ER 3168446 - View ib at a location. Pass the Install Site Id
    -- 11510 3430663. Pass incident_location_id and not install_site_id anymore
    IF r_incident.CUSTOMER_PRODUCT_ID IS NOT NULL THEN
      l_return := CSL_CSI_ITEM_INSTANCES_ACC_PKG.PRE_INSERT_CHILD(
                         p_instance_id => r_incident.CUSTOMER_PRODUCT_ID
                         , p_resource_id => p_resource_id
                         , p_flow_type   => p_flow_type
                         , p_party_site_id => r_incident.incident_location_id);
     END IF;

    -- ITEMS
    IF r_incident.INVENTORY_ITEM_ID IS NOT NULL THEN
      CSL_MTL_SYSTEM_ITEMS_ACC_PKG.PRE_INSERT_CHILD(
             p_inventory_item_id => r_incident.INVENTORY_ITEM_ID
             , p_organization_id => r_incident.INV_ORGANIZATION_ID
             , p_resource_id => p_resource_id );
    END IF;

  END IF;
  CLOSE c_incident;

  --Bug 3724142.
  --ATTACHMENTS
  CSL_LOBS_ACC_PKG.DOWNLOAD_SR_ATTACHMENTS(p_incident_id);

  /*Insert contract record, use dynamic SQL because Contracts might not be
    implemented/used */

  l_cursorid := DBMS_SQL.open_cursor;
  l_stmt := 'Begin CSL_CONTRACT_HANDLING_PKG.POST_INSERT_SR_CONTRACT_ACC( :1,:2,:3 );'||
            ' Exception '||
	    '  when others then '||
	    '   null; '||
	    'end; ';
  DBMS_SQL.parse (l_cursorid, l_stmt, DBMS_SQL.v7);
  DBMS_SQL.bind_variable (l_cursorid, ':1', p_incident_id);
  DBMS_SQL.bind_variable (l_cursorid, ':2', p_resource_id);
  DBMS_SQL.bind_variable (l_cursorid, ':3', l_status);
  begin
    l_execute_status := DBMS_SQL.execute (l_cursorid);
  end;
  DBMS_SQL.close_cursor (l_cursorid);

  /*Done, all packages are called*/
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name
    , 'Leaving Insert_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

END Insert_ACC_Record;



/*** Private procedure that re-sends given incident to mobile ***/
PROCEDURE Update_ACC_Record
  ( p_incident_id            IN NUMBER
   ,p_resource_id        IN NUMBER
   ,p_acc_id             IN NUMBER
  )
IS
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name
    , 'Entering Update_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name
    , 'Updating ACC record for resource_id = ' || p_resource_id || fnd_global.local_chr(10) ||
      'access_id = ' || p_acc_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  JTM_HOOK_UTIL_PKG.Update_Acc
   ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
    ,P_ACC_TABLE_NAME         => g_acc_table_name
    ,P_RESOURCE_ID            => p_resource_id
    ,P_ACCESS_ID              => p_acc_id
   );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name
    , 'Leaving Update_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Update_ACC_Record;


/*** Private procedure that deletes incident for resource from acc table ***/
PROCEDURE Delete_ACC_Record
  ( p_incident_id IN NUMBER
   ,p_resource_id IN NUMBER
   ,p_flow_type   IN NUMBER
  )
IS

 -- 11510 3430663 Changes. Get incident_location_id not install_site_id
 CURSOR c_incident (b_incident_id NUMBER) IS
   SELECT customer_id, incident_location_id, customer_product_id,
     inventory_item_id, inv_organization_id
   FROM CS_INCIDENTS_ALL_B
   WHERE incident_id = b_incident_id;
  r_incident c_incident%ROWTYPE;

  l_status         VARCHAR2(30);
  l_stmt           VARCHAR2(4000);
  l_cursorid       INTEGER;
  l_execute_status INTEGER;
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name
    , 'Entering Delete_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name
    , 'Deleting ACC record for resource_id = ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /*** Delete incident ACC record ***/
  JTM_HOOK_UTIL_PKG.Delete_Acc
   ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
    ,P_ACC_TABLE_NAME         => g_acc_table_name
    ,P_PK1_NAME               => g_pk1_name
    ,P_PK1_NUM_VALUE          => p_incident_id
    ,P_RESOURCE_ID            => p_resource_id
   );

  /*Delete also the dependant records*/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name
    , 'Deleting child records'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  OPEN c_incident( p_incident_id );
  FETCH c_incident INTO r_incident;
  IF c_incident%FOUND THEN

    -- PARTY
    IF r_incident.customer_id IS NOT NULL THEN
      CSL_HZ_PARTIES_ACC_PKG.DELETE_PARTY( r_incident.customer_id,
                                           p_resource_id, p_flow_type );
    END IF;

    -- PARTY_SITE
    -- 11510 Changes 3430663. Pass incident_location_id and not install_site_id
    IF r_incident.incident_location_id IS NOT NULL THEN
      CSL_HZ_PARTY_SITES_ACC_PKG.DELETE_PARTY_SITE(
                         r_incident.incident_location_id, p_resource_id );
    END IF;

    -- CONTACT POINTS
    CSL_PARTY_CONTACTS_ACC_PKG.DELETE_CS_HZ_SR_CONTACTS( p_incident_id,
                                  p_resource_id, p_flow_type );

    -- NOTES
    IF p_flow_type <> G_FLOW_HISTORY THEN
      CSL_JTF_NOTES_ACC_PKG.POST_DELETE_CHILDREN(
                 P_SOURCE_OBJ_ID   => p_incident_id
                 , P_SOURCE_OBJ_CODE => 'SR'
                 , P_RESOURCE_ID     => p_resource_id );
    END IF;

    -- ITEM INSTANCES
    IF r_incident.CUSTOMER_PRODUCT_ID IS NOT NULL THEN
      -- ER 3168446 - View ib at a location. Pass the Install Site Id
      -- 11510 Changes 3430663. Use incident_location_id instead of
      -- install_site_id
      CSL_CSI_ITEM_INSTANCES_ACC_PKG.POST_DELETE_CHILD(
                      p_instance_id => r_incident.CUSTOMER_PRODUCT_ID
                      , p_resource_id => p_resource_id
                      , p_flow_type   => p_flow_type
                      , p_party_site_id => r_incident.incident_location_id);
    END IF;

    -- ITEMS
    IF r_incident.INVENTORY_ITEM_ID IS NOT NULL THEN
      CSL_MTL_SYSTEM_ITEMS_ACC_PKG.POST_DELETE_CHILD(
             p_inventory_item_id => r_incident.INVENTORY_ITEM_ID
             , p_organization_id => r_incident.INV_ORGANIZATION_ID
             , p_resource_id => p_resource_id );
    END IF;

  END IF;
  CLOSE c_incident;

  --Bug 3724142
  --ATTACHMENTS
  /*CSL_LOBS_ACC_PKG.DELETE_ATTACHMENTS ( p_entity_name => 'CS_INCIDENTS',
                                p_primary_key => p_incident_id,
                                p_resource_id => p_resource_id);*/


  /* Delete contract record, use dynamic SQL because Contracts might not be
     implemented/used */
  l_cursorid := DBMS_SQL.open_cursor;
  l_stmt := 'Begin CSL_CONTRACT_HANDLING_PKG.PRE_DELETE_SR_CONTRACT_ACC( :1,:2,:3 );'||
            ' Exception '||
	    '  when others then '||
	    '   null; '||
	    'end; ';
  DBMS_SQL.parse (l_cursorid, l_stmt, DBMS_SQL.v7);
  DBMS_SQL.bind_variable (l_cursorid, ':1', p_incident_id);
  DBMS_SQL.bind_variable (l_cursorid, ':2', p_resource_id);
  DBMS_SQL.bind_variable (l_cursorid, ':3', l_status);
  begin
    l_execute_status := DBMS_SQL.execute (l_cursorid);
  end;
  DBMS_SQL.close_cursor (l_cursorid);


  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name
    , 'Leaving Delete_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

END Delete_ACC_Record;


/***
  Public function that gets called when a incident needs to be inserted into ACC table.
  Returns TRUE when record already was or has been inserted into ACC table.
***/
FUNCTION Pre_Insert_Child
  ( p_incident_id IN NUMBER
   ,p_resource_id IN NUMBER
   ,p_flow_type   IN NUMBER --DEFAULT G_FLOW_NORMAL
  )
RETURN BOOLEAN
IS
  l_acc_id  NUMBER;
  l_success BOOLEAN;
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name
    , 'Entering Pre_Insert_Child procedure'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  l_success := FALSE;
  /*Does the record match the criteria*/
  IF Replicate_Record( p_incident_id ) THEN
    /* Yes, so insert */
    Insert_ACC_Record
     ( p_incident_id
      ,p_resource_id
      ,p_flow_type
     );
     l_success := TRUE;

     /*Check if we should calculate history
       COUNT > 0 and mode = synchronous
       and flow = normal
     */

     IF p_flow_type = G_FLOW_NORMAL THEN
       IF FND_PROFILE.VALUE( 'JTM_SYNCHRONOUS_HISTORY') = 'Y' THEN
         IF CSL_SERVICE_HISTORY_PKG.GET_HISTORY_COUNT( p_resource_id ) > 0 THEN
           /*Yes create history*/
           IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
             jtm_message_log_pkg.Log_Msg
              ( p_incident_id
              , g_table_name
              , 'History should be gathered synchronously'
              , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
           END IF;
           CSL_SERVICE_HISTORY_PKG.CALCULATE_HISTORY( p_incident_id => p_incident_id
                                                    , p_resource_id => p_resource_id );
         END IF;--history count
       END IF;--synchronous history
     END IF;--p_flow_type
  END IF;--Replicate record

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name
    , 'Leaving Pre_Insert_Child procedure'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  RETURN l_success;
END Pre_Insert_Child;

/***
  Public procedure that gets called when a task needs to be deleted from ACC table.
***/
PROCEDURE Post_Delete_Child
  ( p_incident_id IN NUMBER
   ,p_resource_id IN NUMBER
   ,p_flow_type   IN NUMBER --DEFAULT G_FLOW_NORMAL
  )
IS
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name
    , 'Entering Post_Delete_Child'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF p_flow_type <> G_FLOW_HISTORY THEN
    /*Delete also the history for this SR*/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_incident_id
      , g_table_name
      , 'Delete all history records on incident id '||p_incident_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    CSL_SERVICE_HISTORY_PKG.DELETE_HISTORY( p_incident_id => p_incident_id
                                          , p_resource_id => p_resource_id );
  END IF;

  Delete_ACC_Record
   ( p_incident_id
   , p_resource_id
   , p_flow_type );


  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name
    , 'Leaving Post_Delete_Child'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Post_Delete_Child;

/* Called before incident Insert */
PROCEDURE PRE_INSERT_INCIDENT
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_INSERT_INCIDENT;

/* Called after incident Insert */
PROCEDURE POST_INSERT_INCIDENT
  ( x_return_status OUT NOCOPY varchar2
  )
IS
 CURSOR c_incident( b_incident_id NUMBER ) IS
  SELECT au.RESOURCE_ID
  FROM   ASG_USER au
  ,      CS_INCIDENTS_ALL_B inc
  WHERE  au.USER_ID = inc.CREATED_BY
  AND    inc.INCIDENT_ID = b_incident_id;
 r_incident c_incident%ROWTYPE;
 l_enabled_flag VARCHAR2(30);
 l_incident_id NUMBER;
 l_dummy BOOLEAN;
BEGIN
  l_enabled_flag := JTM_PROFILE_UTL_PKG.GET_ENABLE_FLAG_AT_RESP( P_APP_SHORT_NAME => 'CSL' );
  IF l_enabled_flag <> 'Y' THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN;
  END IF;
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_incident_id
    , g_table_name
    , 'Entering POST_INSERT_INCIDENT hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** get incident record details from public API ***/
  l_incident_id := cs_servicerequest_pvt.user_hooks_rec.request_id;
  OPEN c_incident( l_incident_id );
  FETCH c_incident INTO r_incident;
  IF c_incident%FOUND THEN
    IF JTM_HOOK_UTIL_PKG.isMobileFSresource(r_incident.RESOURCE_ID) THEN
     IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
         ( l_incident_id
         , g_table_name
         , 'SR is logged by mobile resource '||r_incident.RESOURCE_ID||' hence inserting record in acc table'
         , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
     END IF;
     l_dummy := Pre_Insert_Child( l_incident_id, r_incident.RESOURCE_ID, G_FLOW_MOBILE_SR );
    ELSE
     IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
         ( l_incident_id
         , g_table_name
         , r_incident.RESOURCE_ID||' is not a OMFS/Laptop resource'
         , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
     END IF;
    END IF;--isMobileFSresource
  ELSE
   IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
     jtm_message_log_pkg.Log_Msg
     ( l_incident_id
     , g_table_name
     , 'SR is not logged by a mobile resource'
     , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
   END IF;
  END IF;--c_incident%FOUND
  CLOSE c_incident;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_incident_id
    , g_table_name
    , 'Leaving POST_INSERT_INCIDENT hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( l_incident_id
    , g_table_name
    , 'Caught exception in POST_INSERT_INCIDENT hook:' || fnd_global.local_chr(10) || sqlerrm
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  fnd_msg_pub.Add_Exc_Msg('CSL_CS_INCIDENTS_ALL_ACC_PKG','POST_INSERT_INCIDENT',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END POST_INSERT_INCIDENT;

  /* Called before incident Update */
  PROCEDURE PRE_UPDATE_INCIDENT
    ( x_return_status OUT NOCOPY varchar2
    )
  IS
    l_incident_id NUMBER;

    -- 11510 Changes 3430663. Use incident_location_id not install_site_id
    CURSOR c_incident( b_incident_id NUMBER ) IS
      SELECT INCIDENT_ID
      ,      CUSTOMER_ID
      ,      INCIDENT_LOCATION_ID
      ,      CUSTOMER_PRODUCT_ID
      ,      INVENTORY_ITEM_ID
      ,      INV_ORGANIZATION_ID
      ,      CONTRACT_SERVICE_ID
      FROM   CS_INCIDENTS_ALL_B
      WHERE  incident_id = b_incident_id;
   l_enabled_flag VARCHAR2(30);
  BEGIN

    l_enabled_flag := JTM_PROFILE_UTL_PKG.GET_ENABLE_FLAG_AT_RESP( P_APP_SHORT_NAME => 'CSL' );
    IF l_enabled_flag <> 'Y' THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      RETURN;
    END IF;

    /*** get incident record details from public API ***/
    l_incident_id := cs_servicerequest_pvt.user_hooks_rec.request_id;

    /*** get debug level ***/
    g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( l_incident_id
      , g_table_name
      , 'Entering PRE_UPDATE hook'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    /*** Check if task before update matched criteria ***/
    g_replicate_pre_update := Replicate_Record( l_incident_id );

    /*Cache the data to check in the post to see if it changed ( hook works not fine )*/
    OPEN c_incident( l_incident_id );
    FETCH c_incident INTO g_cached_rec;
    CLOSE c_incident;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( l_incident_id
      , g_table_name
      , 'Leaving PRE_UPDATE hook'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

  EXCEPTION WHEN OTHERS THEN
    /*** hook failed -> log error ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( l_incident_id
      , g_table_name
      , 'Caught exception in PRE_UPDATE hook:' || fnd_global.local_chr(10) || sqlerrm
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
    END IF;
    fnd_msg_pub.Add_Exc_Msg('CSL_CS_INCIDENTS_ALL_ACC_PKG','PRE_UPDATE_TASK',sqlerrm);
  --  x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  END PRE_UPDATE_INCIDENT;


  /* Called after task Update */
  PROCEDURE POST_UPDATE_INCIDENT
    ( x_return_status OUT NOCOPY varchar2
    )
  IS
    CURSOR c_task( b_incident_id NUMBER )
    IS
     SELECT task_id
     FROM   jtf_tasks_b
     WHERE  source_object_id = b_incident_id
     AND    source_object_type_code = 'SR';

    r_task c_task%ROWTYPE;

     CURSOR c_incident( b_incident_id NUMBER )
     IS
      SELECT INCIDENT_ID
      ,      CUSTOMER_ID
      ,      INCIDENT_LOCATION_ID
      ,      CUSTOMER_PRODUCT_ID
      ,      INVENTORY_ITEM_ID
      ,      INV_ORGANIZATION_ID
      ,      CONTRACT_SERVICE_ID
      FROM   CS_INCIDENTS_ALL_B
      WHERE  incident_id = b_incident_id;

    r_incident c_incident%ROWTYPE;

    l_incident_id NUMBER;
    l_replicate   BOOLEAN;
    l_dummy       BOOLEAN;

    l_tab_resource_id    dbms_sql.Number_Table;
    l_tab_access_id      dbms_sql.Number_Table;
    l_enabled_flag       VARCHAR2(30);

    l_status         VARCHAR2(30);
    l_stmt           VARCHAR2(4000);
    l_cursorid       INTEGER;
    l_execute_status INTEGER;
  BEGIN
    l_enabled_flag := JTM_PROFILE_UTL_PKG.GET_ENABLE_FLAG_AT_RESP( P_APP_SHORT_NAME => 'CSL' );
    IF l_enabled_flag <> 'Y' THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      RETURN;
    END IF;

    /*** get task record details from public API ***/
    l_incident_id := cs_servicerequest_pvt.user_hooks_rec.request_id;

    /*** get debug level ***/
    g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( l_incident_id
      , g_table_name
      , 'Entering POST_UPDATE hook'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

      /*** Check if task after update matches criteria ***/
      l_replicate := Replicate_Record( l_incident_id );

      /*** replicate record after update? ***/
      IF l_replicate THEN
        /*** yes -> was record already replicated? ***/
        IF g_replicate_pre_update THEN
          /*** yes -> re-send updated task record to all resources ***/
          IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
            jtm_message_log_pkg.Log_Msg
            ( l_incident_id
            , g_table_name
            , 'Incident was replicateable before and after update. Re-sending incident record to mobile users.'
            , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
          END IF;
          /*** get list of resources to whom the record was replicated ***/
          JTM_HOOK_UTIL_PKG.Get_Resource_Acc_List
          ( P_ACC_TABLE_NAME  => g_acc_table_name
           ,P_PK1_NAME        => g_pk1_name
           ,P_PK1_NUM_VALUE   => l_incident_id
           ,L_TAB_RESOURCE_ID => l_tab_resource_id
           ,L_TAB_ACCESS_ID   => l_tab_access_id
          );

          /*** re-send rec to all resources ***/
          IF l_tab_resource_id.COUNT > 0 THEN
            FOR i IN l_tab_resource_id.FIRST .. l_tab_resource_id.LAST LOOP
  	  /*besides updating the record itself also check the dependant records*/
              Update_ACC_Record
              ( l_incident_id
               ,l_tab_resource_id(i)
               ,l_tab_access_id(i)
              );

              -- CONTACT POINTS
  	    CSL_PARTY_CONTACTS_ACC_PKG.INSERT_CS_HZ_SR_CONTACTS( l_incident_id, l_tab_resource_id(i) );

            /*Get the post update values*/
            OPEN c_incident( l_incident_id );
            FETCH c_incident INTO r_incident;
            IF c_incident%NOTFOUND THEN
             NULL;
            END IF;
            CLOSE c_incident;

            /*check if customer has changed ( not possible in the form , but maybe the API ? )*/
            IF r_incident.customer_id <> g_cached_rec.customer_id  THEN
              IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
                 jtm_message_log_pkg.Log_Msg
                 ( l_incident_id
                 , g_table_name
                 , 'Customer of the incident has changed.'
                 , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
              END IF;
              CSL_HZ_PARTIES_ACC_PKG.CHANGE_PARTY( g_cached_rec.customer_id
  	                                       , r_incident.customer_id
  					       , l_tab_resource_id(i));

            END IF;--customer check

            /*check if the installed at address is changed*/
    	  IF  NVL( r_incident.incident_location_id, FND_API.G_MISS_NUM ) <> NVL( g_cached_rec.incident_location_id, FND_API.G_MISS_NUM ) THEN
  	    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
                jtm_message_log_pkg.Log_Msg
                ( l_incident_id
                , g_table_name
                , 'Installed at address of the incident has changed.'
                , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
              END IF;
            -- 11510 Change 3430663. Use incident_location_id
  	    CSL_HZ_PARTY_SITES_ACC_PKG.CHANGE_PARTY_SITE( g_cached_rec.incident_location_id
  	                                                , r_incident.incident_location_id
  							, l_tab_resource_id(i));
    	  END IF;--install site check

  	  /*check if the customer product  is changed*/
    	  IF  NVL( r_incident.customer_product_id, FND_API.G_MISS_NUM ) <> NVL( g_cached_rec.customer_product_id, FND_API.G_MISS_NUM ) THEN
  	    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
                jtm_message_log_pkg.Log_Msg
                ( l_incident_id
                , g_table_name
                , 'Customer product of the incident has changed.'
                , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
              END IF;
              /* First delete old customer product */
              IF g_cached_rec.customer_product_id IS NOT NULL THEN
                -- ER 3168446 - View ib at a location. Pass the Install Site Id
                -- 11510 Changes 3430663. Pass incident_location_id now
                CSL_CSI_ITEM_INSTANCES_ACC_PKG.POST_DELETE_CHILD(
                        g_cached_rec.customer_product_id
    	              , l_tab_resource_id(i)
                        , p_party_site_id => r_incident.incident_location_id);
              END IF;
              /* Then create the new customer product */
              IF r_incident.customer_product_id IS NOT NULL THEN
                -- ER 3168446 - View ib at a location. Pass the Install Site Id
                -- 11510 Changes 3430663. Pass incident_location_id now
                l_dummy := CSL_CSI_ITEM_INSTANCES_ACC_PKG.Pre_Insert_Child(
                             r_incident.customer_product_id
    	                   , l_tab_resource_id(i)
                             , p_party_site_id => r_incident.incident_location_id);
              END IF;
    	  END IF;--customer product check

            /*check if the inventory item is changed*/
    	  IF  NVL( r_incident.inventory_item_id, FND_API.G_MISS_NUM ) <> NVL( g_cached_rec.inventory_item_id, FND_API.G_MISS_NUM ) THEN
  	    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
                jtm_message_log_pkg.Log_Msg
                ( l_incident_id
                , g_table_name
                , 'Inventory item of the incident has changed.'
                , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
              END IF;
              /* First delete old inventory item */
              IF g_cached_rec.inventory_item_id IS NOT NULL THEN
                CSL_MTL_SYSTEM_ITEMS_ACC_PKG.POST_DELETE_Child( g_cached_rec.inventory_item_id
    	                                                  , g_cached_rec.INV_ORGANIZATION_ID
    							  , l_tab_resource_id(i));
              END IF;
              /* Then create the new inventory item */
              IF r_incident.inventory_item_id IS NOT NULL THEN
                CSL_MTL_SYSTEM_ITEMS_ACC_PKG.Pre_Insert_Child( r_incident.inventory_item_id
    	                                                 , r_incident.INV_ORGANIZATION_ID
    							 , l_tab_resource_id(i));
              END IF;
    	  END IF;--inventory item check

  	  IF NVL(r_incident.contract_service_id, FND_API.G_MISS_NUM) <> NVL( g_cached_rec.contract_service_id, FND_API.G_MISS_NUM) THEN
  	    /*Delete contract record, use dynamic SQL because Contracts might not be implemented/used*/
  	    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
                jtm_message_log_pkg.Log_Msg
                ( l_incident_id
                , g_table_name
                , 'Contract line of the incident has changed.'
                , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
              END IF;

              l_cursorid := DBMS_SQL.open_cursor;
              l_stmt := 'Begin CSL_CONTRACT_HANDLING_PKG.POST_UPDATE_SR_CONTRACT_ACC( :1,:2,:3,:4,:5 );'||
                        ' Exception '||
                        '  when others then '||
  	              '   null; '||
  	              'end; ';
              DBMS_SQL.parse (l_cursorid, l_stmt, DBMS_SQL.v7);
              DBMS_SQL.bind_variable (l_cursorid, ':1', l_incident_id);
              DBMS_SQL.bind_variable (l_cursorid, ':2', g_cached_rec.contract_service_id);
              DBMS_SQL.bind_variable (l_cursorid, ':3', r_incident.contract_service_id);
              DBMS_SQL.bind_variable (l_cursorid, ':4', l_tab_resource_id(i));
              DBMS_SQL.bind_variable (l_cursorid, ':5', l_status);
              begin
               l_execute_status := DBMS_SQL.execute (l_cursorid);
              end;
              DBMS_SQL.close_cursor (l_cursorid);
  	  END IF;--contract check

           END LOOP;
          END IF;
       ELSE
          /***
            record was not replicated before update so we don't need it
          ***/
          IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
            jtm_message_log_pkg.Log_Msg
            ( l_incident_id
            , g_table_name
            , 'Incident was not replicated before update.'
            , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
          END IF;
        END IF;
      ELSE
        /*** record should not be replicated anymore -> was it replicated before? ***/
        IF g_replicate_pre_update THEN
          /*** yes -> delete record related data for all resources ***/
          IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
            jtm_message_log_pkg.Log_Msg
            ( l_incident_id
            , g_table_name
            , 'Incident was replicated before update, but should no longer be replicated.'
            , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
          END IF;
        END IF;
      END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( l_incident_id
      , g_table_name
      , 'Leaving POST_UPDATE hook'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

  EXCEPTION WHEN OTHERS THEN
    /*** hook failed -> log error ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( l_incident_id
      , g_table_name
      , 'Caught exception in POST_UPDATE hook:' || fnd_global.local_chr(10) || sqlerrm
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
    END IF;
    fnd_msg_pub.Add_Exc_Msg('CSL_CS_INCIDENTS_ALL_ACC_PKG','POST_UPDATE_TASK',sqlerrm);
  --  x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  END POST_UPDATE_INCIDENT;


/* Called before task Delete */
PROCEDURE PRE_DELETE_INCIDENT
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_DELETE_INCIDENT;

/* Called after task Delete */
PROCEDURE POST_DELETE_INCIDENT
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END POST_DELETE_INCIDENT;

/* Called during user creation */
PROCEDURE INSERT_ALL_ACC_RECORDS
  ( p_resource_id   IN  NUMBER
  , x_return_status OUT NOCOPY VARCHAR2 ) IS

 CURSOR c_incident( b_resource_id NUMBER ) IS
  SELECT inc.INCIDENT_ID
  FROM   ASG_USER au
  ,      CS_INCIDENTS_ALL_B inc
  WHERE  au.USER_ID = inc.CREATED_BY
  AND    au.RESOURCE_ID = b_resource_id;
 r_incident c_incident%ROWTYPE;
 l_dummy    BOOLEAN;
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Entering POST_INSERT hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** insert all SRs created by resource ***/
  FOR r_incident IN c_incident( p_resource_id ) LOOP
     l_dummy := Pre_Insert_Child( r_incident.incident_id, p_resource_id, G_FLOW_MOBILE_SR );
  END LOOP;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Leaving POST_INSERT hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
 WHEN OTHERS THEN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Caught exception in INSERT_ALL_ACC_RECORDS:' || fnd_global.local_chr(10) || sqlerrm
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  x_return_status := FND_API.G_RET_STS_ERROR;
END INSERT_ALL_ACC_RECORDS;

END CSL_CS_INCIDENTS_ALL_ACC_PKG;

/
