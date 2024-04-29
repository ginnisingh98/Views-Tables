--------------------------------------------------------
--  DDL for Package Body CSL_CSI_ITEM_INSTANCES_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_CSI_ITEM_INSTANCES_ACC_PKG" AS
/* $Header: csliiacb.pls 120.0 2005/05/25 11:05:37 appldev noship $ */

  /*** Globals ***/
  g_acc_table_name        CONSTANT VARCHAR2(30) := 'CSL_CSI_ITEM_INSTANCES_ACC';
  g_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
    JTM_HOOK_UTIL_PKG.t_publication_item_list('CSL_CSI_ITEM_INSTANCES');
  g_table_name            CONSTANT VARCHAR2(30) := 'CSI_ITEM_INSTANCES';
  g_pk1_name              CONSTANT VARCHAR2(30) := 'INSTANCE_ID';
  g_debug_level           NUMBER; -- debug level
  g_resource_id_list      dbms_sql.Number_Table; -- list of resource to which an item instance should be replicated

  -- ER 3168446
  g_ib_count               NUMBER := 0;
  g_parent_instance_id     NUMBER;

  /*** Function that checks if item instance record should be replicated.
       Returns TRUE if it should ***/
  FUNCTION Replicate_Record
    ( p_instance_id      NUMBER
    , p_resource_id      NUMBER
    )
  RETURN BOOLEAN
  IS
    CURSOR c_item_instance (b_instance_id NUMBER) IS
     SELECT null
     FROM CSI_ITEM_INSTANCES
     WHERE instance_id = b_instance_id;
    r_item_instance c_item_instance%ROWTYPE;
  BEGIN
    /*** get debug level ***/
    g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Entering Replicate_Record'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    /*** is resource a mobile user? ***/
    IF NOT JTM_HOOK_UTIL_PKG.isMobileFSresource( p_resource_id ) THEN
      /*** No -> exit ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( p_instance_id
        , g_table_name
        , 'Replicate_Record returned FALSE' || fnd_global.local_chr(10) ||
          'Resource_id ' || p_resource_id || ' is not a mobile user.'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      RETURN FALSE;
    END IF;

    /*** check if instance record exists ***/
    OPEN c_item_instance( p_instance_id );
    FETCH c_item_instance INTO r_item_instance;
    IF c_item_instance%NOTFOUND THEN
      /*** could not find item instance record -> exit ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
        jtm_message_log_pkg.Log_Msg
        ( p_instance_id
        , g_table_name
        , 'Replicate_Record error: Could not find instance_id ' || p_instance_id
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
      END IF;

      CLOSE c_item_instance;
      RETURN FALSE;
    END IF;
    CLOSE c_item_instance;

    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Replicate_Record returned TRUE'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    /** Record matched criteria -> return true ***/
    RETURN TRUE;
  END Replicate_Record;


  /*** Private procedure that replicates extended item attributes
  for a given item instance***/
  PROCEDURE CON_ITEM_ATTR( p_status OUT NOCOPY VARCHAR2,
                           p_message OUT NOCOPY VARCHAR2)
  IS

    /*** get the last run date of the concurent program ***/
    CURSOR  c_LastRundate IS
      select LAST_RUN_DATE
      from   JTM_CON_REQUEST_DATA
      where  package_name =  'CSL_CSI_ITEM_INSTANCES_ACC_PKG'
      AND    procedure_name = 'CON_ITEM_ATTR';
   r_LastRundate c_LastRundate%ROWTYPE;

   CURSOR c_insert_diffs(b_last_run_date date) IS
     SELECT ATTRIBUTE_VALUE_ID, RESOURCE_ID
     FROM CSI_IEA_VALUES civ, CSI_I_EXTENDED_ATTRIBS ciea, csl_csi_item_instances_acc acc
     WHERE civ.attribute_id = ciea.attribute_id
     AND civ.instance_id = acc.instance_id
     AND NVL(ciea.active_start_date, sysdate) <= sysdate
     AND NVL(ciea.active_end_date, sysdate) >= sysdate
     AND civ.ATTRIBUTE_VALUE_ID NOT IN (SELECT ATTRIBUTE_VALUE_ID from CSL_CSI_ITEM_ATTR_ACC)
     AND civ.last_update_date > b_last_run_date;

   r_insert_diffs c_insert_diffs%ROWTYPE;

   CURSOR c_updates(b_last_run_date date) IS
     SELECT acc.ACCESS_ID, acc.RESOURCE_ID
     FROM CSI_IEA_VALUES civ, CSI_I_EXTENDED_ATTRIBS ciea,
         csl_csi_item_instances_acc csiacc, CSL_CSI_ITEM_ATTR_ACC acc
     WHERE civ.attribute_id = ciea.attribute_id
     AND civ.instance_id = csiacc.instance_id
     AND civ.ATTRIBUTE_VALUE_ID = acc.ATTRIBUTE_VALUE_ID
     AND NVL(ciea.active_start_date, sysdate) <= sysdate
     AND NVL(ciea.active_end_date, sysdate) >= sysdate
     AND civ.last_update_date > b_last_run_date;
   r_updates c_updates%ROWTYPE;

/*
   CURSOR c_end_dates(b_last_run_date date) IS
     SELECT ATTRIBUTE_VALUE_ID, RESOURCE_ID
     FROM CSI_IEA_VALUES civ, CSI_I_EXTENDED_ATTRIBS ciea, csl_csi_item_instances_acc acc
     WHERE civ.attribute_id = ciea.attribute_id
     AND civ.instance_id = acc.instance_id
     AND NVL(ciea.active_start_date, sysdate) <= sysdate
     AND NVL(ciea.active_end_date, sysdate) < sysdate
     AND civ.ATTRIBUTE_VALUE_ID IN (SELECT ATTRIBUTE_VALUE_ID from CSL_CSI_ITEM_ATTR_ACC)
     AND civ.last_update_date > b_last_run_date;
   r_end_dates c_end_dates%ROWTYPE;

   CURSOR c_deletes(b_last_run_date date) IS
     SELECT ATTRIBUTE_VALUE_ID, RESOURCE_ID
     from CSL_CSI_ITEM_ATTR_ACC
     where ATTRIBUTE_VALUE_ID NOT IN (SELECT ATTRIBUTE_VALUE_ID from CSI_IEA_VALUES)
*/

   l_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
	JTM_HOOK_UTIL_PKG.t_publication_item_list('CSL_CSI_ITEM_ATTR');
   l_acc_table_name        CONSTANT VARCHAR2(30) := 'CSL_CSI_ITEM_ATTR_ACC';
   l_pk1_name              CONSTANT VARCHAR2(30) := 'ATTRIBUTE_VALUE_ID';
   l_table_name        CONSTANT VARCHAR2(30) := 'CSL_CSI_ITEM_ATTR';

   l_current_run_date date;
  BEGIN

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( 0
      , l_table_name
      , 'Entering Insert_Item_Attr'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    /*** First retrieve last run date of the conccurent program ***/
    OPEN  c_LastRundate;
    FETCH c_LastRundate  INTO r_LastRundate;
    CLOSE c_LastRundate;

    l_current_run_date := SYSDATE;

    --INSERT
    FOR r_insert_diffs in c_insert_diffs(r_LastRundate.LAST_RUN_DATE)
    LOOP

      IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( 0
        , l_table_name
        , 'Inserting ACC record for resource_id = ' || r_insert_diffs.resource_id
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
      END IF;

      JTM_HOOK_UTIL_PKG.Insert_Acc
       ( P_PUBLICATION_ITEM_NAMES => l_publication_item_name
        ,P_ACC_TABLE_NAME         => l_acc_table_name
        ,P_RESOURCE_ID            => r_insert_diffs.resource_id
        ,P_PK1_NAME               => l_pk1_name
        ,P_PK1_NUM_VALUE          => r_insert_diffs.attribute_value_id
       );

    END LOOP;

    --UPDATE
    FOR r_updates in c_updates(r_LastRundate.LAST_RUN_DATE)
    LOOP

      IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( 0
        , l_table_name
        , 'Updating ACC record for resource_id = ' || r_updates.resource_id
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
      END IF;

      JTM_HOOK_UTIL_PKG.Update_Acc
       ( P_PUBLICATION_ITEM_NAMES => l_publication_item_name
        ,P_ACC_TABLE_NAME         => l_acc_table_name
        ,P_RESOURCE_ID            => r_updates.resource_id
        ,P_ACCESS_ID          => r_updates.access_id
       );

    END LOOP;

/*
    --DELETE
    FOR r_end_dates in c_end_dates(r_LastRundate.LAST_RUN_DATE)
    LOOP

      IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( 0
        , l_table_name
        , 'Updating ACC record for resource_id = ' || r_end_dates.resource_id
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
      END IF;

      JTM_HOOK_UTIL_PKG.Delete_Acc
       ( P_PUBLICATION_ITEM_NAMES => l_publication_item_name
        ,P_ACC_TABLE_NAME         => l_acc_table_name
        ,P_RESOURCE_ID            => r_end_dates.resource_id
        ,P_PK1_NAME               => l_pk1_name
        ,P_PK1_NUM_VALUE          => r_end_dates.attribute_value_id
       );

    END LOOP;
*/

    /*Update the last run date*/
    UPDATE jtm_con_request_data SET last_run_date = l_current_run_date
     WHERE package_name =  'CSL_CSI_ITEM_INSTANCES_ACC_PKG'
     AND   procedure_name = 'CON_ITEM_ATTR';

    COMMIT;


    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( 0
      , l_table_name
      , 'Leaving Con_item_Attr'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    p_status := 'FINE';
    p_message :=  'CSL_CSI_ITEM_INSTANCES_ACC_PKG.CON_ITEM_ATTR Executed successfully';

  EXCEPTION

    WHEN OTHERS THEN
        p_status := 'ERROR';
        p_message := 'Error in CSL_CSI_ITEM_INSTANCES_ACC_PKG.CON_ITEM_ATTR: ' || substr(SQLERRM, 1, 2000);
	jtm_message_log_pkg.Log_Msg
            (0,
            'CSL_CSI_ITEM_ATTR_ACC',
            'Exception occured in CON_ITEM_ATTR ',
            JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);

  END;


   --Bug 3724152
  /*** Private procedure that replicates extended item attributes
  for a given item instance***/
  PROCEDURE Insert_Item_Attr
    ( p_instance_id IN NUMBER
     ,p_resource_id IN NUMBER
     ,p_flow_type   IN NUMBER )
  IS
   CURSOR c_item_attr( b_instance_id NUMBER ) IS
     SELECT ATTRIBUTE_VALUE_ID
     FROM CSI_IEA_VALUES civ, CSI_I_EXTENDED_ATTRIBS ciea
     WHERE civ.attribute_id = ciea.attribute_id
     AND NVL(ciea.active_start_date, sysdate) <= sysdate
     AND NVL(ciea.active_end_date, sysdate) >= sysdate
     AND civ.instance_id = b_instance_id;

   r_item_attr c_item_attr%ROWTYPE;

   l_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
	JTM_HOOK_UTIL_PKG.t_publication_item_list('CSL_CSI_ITEM_ATTR');
   l_acc_table_name        CONSTANT VARCHAR2(30) := 'CSL_CSI_ITEM_ATTR_ACC';
   l_pk1_name              CONSTANT VARCHAR2(30) := 'ATTRIBUTE_VALUE_ID';
   l_table_name        CONSTANT VARCHAR2(30) := 'CSL_CSI_ITEM_ATTR';

  BEGIN

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Entering Insert_Item_Attr'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Inserting ACC record for resource_id = ' || p_resource_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    FOR r_item_attr in c_item_attr(p_instance_id)
    LOOP

      JTM_HOOK_UTIL_PKG.Insert_Acc
       ( P_PUBLICATION_ITEM_NAMES => l_publication_item_name
        ,P_ACC_TABLE_NAME         => l_acc_table_name
        ,P_RESOURCE_ID            => p_resource_id
        ,P_PK1_NAME               => l_pk1_name
        ,P_PK1_NUM_VALUE          => r_item_attr.attribute_value_id
       );

    END LOOP;


    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Leaving Insert_ACC_Record'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

  END;

   --Bug 3724152
  /*** Private procedure that deletes extended item attributes
  for a given item instance***/
  PROCEDURE Delete_Item_Attr
    ( p_instance_id IN NUMBER
     ,p_resource_id IN NUMBER
     ,p_flow_type   IN NUMBER )
  IS
   CURSOR c_item_attr( b_instance_id NUMBER ) IS
     SELECT ATTRIBUTE_VALUE_ID
     FROM CSI_IEA_VALUES
     WHERE instance_id = b_instance_id;

   r_item_attr c_item_attr%ROWTYPE;

   l_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
	JTM_HOOK_UTIL_PKG.t_publication_item_list('CSL_CSI_ITEM_ATTR');
   l_acc_table_name        CONSTANT VARCHAR2(30) := 'CSL_CSI_ITEM_ATTR_ACC';
   l_pk1_name              CONSTANT VARCHAR2(30) := 'ATTRIBUTE_VALUE_ID';
   l_table_name        CONSTANT VARCHAR2(30) := 'CSL_CSI_ITEM_ATTR';

  BEGIN

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Entering Delete_Item_Attr'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Deleting ACC record for resource_id = ' || p_resource_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    FOR r_item_attr in c_item_attr(p_instance_id)
    LOOP

      JTM_HOOK_UTIL_PKG.Delete_Acc
       ( P_PUBLICATION_ITEM_NAMES => l_publication_item_name
        ,P_ACC_TABLE_NAME         => l_acc_table_name
        ,P_RESOURCE_ID            => p_resource_id
        ,P_PK1_NAME               => l_pk1_name
        ,P_PK1_NUM_VALUE          => r_item_attr.attribute_value_id
       );

    END LOOP;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Leaving Delete_Item_Attr'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

  END;

  /*** Private procedure that replicates given item instance related data
       for resource ***/
  PROCEDURE Insert_ACC_Record
    ( p_instance_id IN NUMBER
     ,p_resource_id IN NUMBER
     ,p_flow_type   IN NUMBER )
  IS
   CURSOR c_ii( b_instance_id NUMBER ) IS
    SELECT inventory_item_id
    ,      inv_organization_id
    ,      LOCATION_ID
    ,      location_type_code
    ,      INV_MASTER_ORGANIZATION_ID
    FROM CSI_ITEM_INSTANCES
    WHERE instance_id = b_instance_id;
   r_ii c_ii%ROWTYPE;
   l_org_id NUMBER;
   l_return BOOLEAN;
  BEGIN
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Entering Insert_ACC_Record'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Inserting ACC record for resource_id = ' || p_resource_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    JTM_HOOK_UTIL_PKG.Insert_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
      ,P_ACC_TABLE_NAME         => g_acc_table_name
      ,P_RESOURCE_ID            => p_resource_id
      ,P_PK1_NAME               => g_pk1_name
      ,P_PK1_NUM_VALUE          => p_instance_id
     );

    -- ER 3168446
    g_ib_count := g_ib_count + 1;

   IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Calling Non-critical dependent hooks'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;
    -- NOTES/COUNTERS ( do not replicate notes/counters for history instances )
    IF p_flow_type <> CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_HISTORY THEN
      l_return := CSL_JTF_NOTES_ACC_PKG.PRE_INSERT_CHILDREN
                                      ( P_SOURCE_OBJ_ID   => p_instance_id
    				    , P_SOURCE_OBJ_CODE => 'CP'
    				    , P_RESOURCE_ID     => p_resource_id );

    -- COUNTERS
    l_return := CSL_CS_COUNTERS_ACC_PKG.POST_INSERT_PARENT(
                      P_ITEM_INSTANCE_ID => p_instance_id
                      , P_RESOURCE_ID      => p_resource_id );
    END IF;--p_flow_type

    -- SYSTEM ITEM
    OPEN c_ii( p_instance_id );
    FETCH c_ii INTO r_ii;
    IF c_ii%FOUND THEN
      -- l_org_id := NVL( r_ii.INV_ORGANIZATION_ID, TO_NUMBER(FND_PROFILE.VALUE('CS_INV_VALIDATION_ORG')));
      l_org_id :=  r_ii.INV_MASTER_ORGANIZATION_ID;
      CSL_MTL_SYSTEM_ITEMS_ACC_PKG.Pre_Insert_Child(
                p_inventory_item_id => r_ii.INVENTORY_ITEM_ID
                , p_organization_id   => l_org_id
                , p_resource_id       => p_resource_id );

      IF r_ii.location_type_code = 'HZ_PARTY_SITES' THEN
        CSL_HZ_PARTY_SITES_ACC_PKG.INSERT_PARTY_SITE(
                p_party_site_id => r_ii.LOCATION_ID
                ,p_resource_id => p_resource_id);

      ELSIF  r_ii.location_type_code = 'HZ_LOCATIONS' THEN
        CSL_HZ_LOCATIONS_ACC_PKG.INSERT_LOCATION(
                p_location_id => r_ii.LOCATION_ID
                ,p_resource_id => p_resource_id);
      END IF;
    END IF;
    CLOSE c_ii;

    --Bug 3724152
    Insert_Item_Attr
    ( p_instance_id => p_instance_id
     ,p_resource_id => p_resource_id
     ,p_flow_type => p_flow_type);

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Leaving Insert_ACC_Record'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;
  END Insert_ACC_Record;

  /*** Private procedure that re-sends given item instance to mobile ***/
  PROCEDURE Update_ACC_Record
    ( p_instance_id IN NUMBER
     ,p_resource_id        IN NUMBER
     ,p_acc_id             IN NUMBER
    )
  IS
  BEGIN
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Entering Update_ACC_Record'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Updating ACC record for resource_id = ' || p_resource_id
        || fnd_global.local_chr(10) || 'access_id = ' || p_acc_id
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
      ( p_instance_id
      , g_table_name
      , 'Leaving Update_ACC_Record'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;
  END Update_ACC_Record;


  /*** Private procedure that deletes item instance for resource from
       acc table ***/
  PROCEDURE Delete_ACC_Record
    ( p_instance_id IN NUMBER
     ,p_resource_id IN NUMBER
     ,p_flow_type   IN NUMBER ) --DEFAULT CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL
  IS
   CURSOR c_ii( b_instance_id NUMBER ) IS
    SELECT inventory_item_id
    ,      inv_organization_id
    ,      LOCATION_ID
    ,      location_type_code
    ,      INV_MASTER_ORGANIZATION_ID
    FROM CSI_ITEM_INSTANCES
    WHERE instance_id = b_instance_id;
   r_ii c_ii%ROWTYPE;
   l_org_id NUMBER;
   l_return BOOLEAN;
  BEGIN
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Entering Delete_ACC_Record'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Deleting ACC record for resource_id = ' || p_resource_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    /*** Delete item instance ACC record ***/
    JTM_HOOK_UTIL_PKG.Delete_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
      ,P_ACC_TABLE_NAME         => g_acc_table_name
      ,P_PK1_NAME               => g_pk1_name
      ,P_PK1_NUM_VALUE          => p_instance_id
      ,P_RESOURCE_ID            => p_resource_id
     );


    -- NOTES/COUNTERS ( notes/counters for history instances are not replicated so don't delete )
    IF p_flow_type <> CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_HISTORY THEN
      -- NOTES
      CSL_JTF_NOTES_ACC_PKG.POST_DELETE_CHILDREN
               ( P_SOURCE_OBJ_ID   => p_instance_id
                 , P_SOURCE_OBJ_CODE => 'CP'
  		 , P_RESOURCE_ID     => p_resource_id );
      -- COUNTERS
      l_return := CSL_CS_COUNTERS_ACC_PKG.PRE_DELETE_PARENT
               ( P_ITEM_INSTANCE_ID => p_instance_id
                 , P_RESOURCE_ID      => p_resource_id );
    END IF;

    -- SYSTEM ITEM
    OPEN c_ii( p_instance_id );
    FETCH c_ii INTO r_ii;
    IF c_ii%FOUND THEN
      -- l_org_id := NVL( r_ii.INV_ORGANIZATION_ID, TO_NUMBER(FND_PROFILE.VALUE('CS_INV_VALIDATION_ORG')));
      l_org_id := r_ii.INV_MASTER_ORGANIZATION_ID;
      CSL_MTL_SYSTEM_ITEMS_ACC_PKG.Post_Delete_Child
                   ( p_inventory_item_id => r_ii.INVENTORY_ITEM_ID
                     , p_organization_id   => l_org_id
                     , p_resource_id       => p_resource_id
                   );
      IF r_ii.location_type_code = 'HZ_PARTY_SITES' THEN
        CSL_HZ_PARTY_SITES_ACC_PKG.DELETE_PARTY_SITE
                  ( p_party_site_id => r_ii.LOCATION_ID
                    ,p_resource_id => p_resource_id);
      ELSIF  r_ii.location_type_code = 'HZ_LOCATIONS' THEN
        CSL_HZ_LOCATIONS_ACC_PKG.DELETE_LOCATION
                  ( p_location_id => r_ii.LOCATION_ID
                    ,p_resource_id => p_resource_id);
      END IF;
    END IF;
    CLOSE c_ii;

    --Bug 3724152
    Delete_Item_Attr
    ( p_instance_id => p_instance_id
     ,p_resource_id => p_resource_id
     ,p_flow_type => p_flow_type);

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Leaving Delete_ACC_Record'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;
  END Delete_ACC_Record;


  /** Procedure Insert Child for Child instances */
  PROCEDURE Insert_Childs
    ( p_instance_id IN NUMBER
    , p_resource_id IN NUMBER
    )
  IS
    CURSOR c_child_instance ( b_instance_id NUMBER ) IS
     SELECT     subject_id
     FROM       CSI_II_RELATIONSHIPS
     WHERE      RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
     START WITH object_id = b_instance_id
     CONNECT BY PRIOR subject_id = object_id;
    r_child_instance c_child_instance%ROWTYPE;

    l_profile_value VARCHAR2(240);
  BEGIN
    /*** get debug level ***/
    g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Entering Insert_Childs'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    l_profile_value := NVL(fnd_profile.value_specific('CSL_REPLICATE_CP_CHILDS'), 'N' );
    -- IF Replicate Childs profile set to Y THEN
    IF l_profile_value = 'Y' THEN
      -- LOOP through the child list
      FOR r_child_instance IN c_child_instance( p_instance_id ) LOOP
        -- Insert IB (child_instance_id)
        Insert_ACC_Record
           ( r_child_instance.subject_id
           , p_resource_id
  	 , CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL
           );

        IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
          jtm_message_log_pkg.Log_Msg
          ( p_instance_id
          , g_table_name
          , 'Child Instance inserted into ACC - INSTANCE_ID: ' || r_child_instance.subject_id
          , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
        END IF;
      END LOOP; -- Next child IB
    END IF;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Leaving Insert_Childs'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

  END Insert_Childs;


  /** Insert Parent Instances for this Record */
  PROCEDURE Insert_Parents
    ( p_instance_id IN NUMBER
    , p_resource_id IN NUMBER
    )
  IS
    CURSOR c_parent_instance ( b_instance_id NUMBER ) IS
     SELECT     object_id
     FROM       CSI_II_RELATIONSHIPS
     WHERE      RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
     AND        SUBJECT_ID = b_instance_id;
    r_parent_instance c_parent_instance%ROWTYPE;

    l_profile_value VARCHAR2(240);
  BEGIN
    /*** get debug level ***/
    g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Entering Insert_Parents'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    l_profile_value := NVL(fnd_profile.value_specific('CSL_REPLICATE_CP_PARENTS'), 'N' );

    -- If Replicate Parents profile set to Y THEN
    IF l_profile_value = 'Y' THEN
      -- LOOP through the parent list
      FOR r_parent_instance IN c_parent_instance( p_instance_id ) LOOP
        -- Insert IB (parent_instance_id)
        Insert_ACC_Record
           ( r_parent_instance.object_id
           , p_resource_id
  	 , CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL
           );

        IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
          jtm_message_log_pkg.Log_Msg
          ( p_instance_id
          , g_table_name
          , 'Parent Instance inserted into ACC - INSTANCE_ID: ' || r_parent_instance.object_id
          , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
        END IF;
      END LOOP; -- Next child IB
    END IF;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Leaving Insert_Parents'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

  END Insert_Parents;

  /* ER 3168446
   ** Insert IB Item, Parent and Child records */
  PROCEDURE  insert_ib_parent_child ( p_instance_id IN NUMBER
                                      , p_resource_id IN NUMBER
                                      , p_flow_type IN NUMBER) IS
  BEGIN
    IF Replicate_Record ( p_instance_id , p_resource_id) THEN

       /*Do not replicate parent for history*/
       IF p_flow_type <> CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_HISTORY THEN
         Insert_Parents ( p_instance_id ,p_resource_id );
       END IF; -- p_flow_type

       Insert_ACC_Record ( p_instance_id ,p_resource_id ,p_flow_type);

       /*Do not replicate parent/childs for history*/
       IF p_flow_type <> CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_HISTORY THEN
          Insert_Childs ( p_instance_id ,p_resource_id);
        END IF; --p_flow_type
    END IF;
  END insert_ib_parent_child;


  /***
   Public function that gets called when an item instance needs to be inserted
   into ACC table.
   Returns TRUE when record already was or has been inserted into ACC table.
   p_flow_type - DEFAULT CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL
  ***/

  FUNCTION Pre_Insert_Child
    ( p_instance_id IN NUMBER
     ,p_resource_id IN NUMBER
     ,p_flow_type   IN NUMBER
     , p_party_site_id IN NUMBER ) -- ER 3168446 INSTALL_SITE_USE_ID From SR

  RETURN BOOLEAN IS

    /** ER 3168446 - View IB at Location Fix */

    CURSOR c_ib_party ( b_party_site_id NUMBER ) IS
      SELECT party_id, location_id FROM hz_party_sites
      WHERE party_site_id = b_party_site_id;


    CURSOR c_existing_ib_at_location (
           b_resource_id   NUMBER,
           b_party_site_id NUMBER,
           b_location_id   NUMBER,
           b_party_id      NUMBER,
           b_instance_id   NUMBER,
           b_parent_instance_id NUMBER  ) IS
      SELECT acc.instance_id
        FROM CSL_CSI_ITEM_INSTANCES_ACC acc, CSI_ITEM_INSTANCES cii
          WHERE acc.instance_id = cii.instance_id
          AND acc.resource_id = b_resource_id
          AND owner_party_id = b_party_id
          AND ( ( cii.location_id = b_party_site_id
                  AND cii.location_type_code = 'HZ_PARTY_SITES'
                ) OR
                ( cii.location_id = b_location_id
                  AND  cii.location_type_code = 'HZ_LOCATIONS'
                )
              )
          AND acc.instance_id NOT IN
          (
              SELECT acc.instance_id FROM CSL_CSI_ITEM_INSTANCES_ACC acc
                 WHERE acc.resource_id = b_resource_id AND
                   acc.instance_id IN (b_instance_id, b_parent_instance_id)
              UNION
              SELECT acc.instance_id FROM CSL_CSI_ITEM_INSTANCES_ACC acc
                 WHERE acc.resource_id = b_resource_id AND
                 acc.instance_id IN
                 (
                    SELECT subject_id FROM CSI_II_RELATIONSHIPS
                      WHERE RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
                      START WITH object_id = b_instance_id
                      CONNECT BY PRIOR subject_id = object_id
                 )
         ) ;


    CURSOR c_new_ib_at_location (
           b_resource_id   NUMBER,
           b_party_site_id NUMBER,
           b_location_id   NUMBER,
           b_party_id      NUMBER  ) IS
      SELECT cii.instance_id
        FROM CSI_ITEM_INSTANCES cii, MTL_SYSTEM_ITEMS si
          WHERE si.organization_id = NVL( cii.inv_organization_id,
                                          cii.inv_master_organization_id )
          AND si.inventory_item_id = cii.inventory_item_id
          AND cii.instance_id NOT IN
             ( SELECT acc.instance_id FROM CSL_CSI_ITEM_INSTANCES_ACC acc
               WHERE acc.resource_id = b_resource_id
             )
          AND owner_party_id = b_party_id
          AND ( ( cii.location_id = b_party_site_id
                  AND cii.location_type_code = 'HZ_PARTY_SITES'
                ) OR
                ( cii.location_id = b_location_id
                  AND  cii.location_type_code = 'HZ_LOCATIONS'
                )
              )
          AND si.service_item_flag = 'N' AND  nvl(si.enabled_flag,'Y') = 'Y'
          AND si.serv_req_enabled_code = 'E';

     l_party_id          NUMBER;
     l_location_id       NUMBER;

  BEGIN
    /*** get debug level ***/
    g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Entering Pre_Insert_Child procedure'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    /*  ER 3168446 View IB at Location  Fix
     ** Get the Party of this party Site */
    OPEN c_ib_party (p_party_site_id);
    FETCH c_ib_party INTO l_party_id, l_location_id;
    CLOSE c_ib_party;

    /** Insert for SR IB */
    g_ib_count := 0;
    insert_ib_parent_child (p_instance_id, p_resource_id, p_flow_type);

    -- Increment counter for existing IB's
    FOR c_exist_ib_items IN c_existing_ib_at_location (
                              p_resource_id,
                              p_party_site_id,
                              l_location_id,
                              l_party_id,
                              p_instance_id,
                              g_parent_instance_id )
    LOOP
       Insert_ACC_Record ( p_instance_id ,p_resource_id ,p_flow_type);
    END LOOP;

    -- Greater than check for Profile IB count was reset to a lower value
    IF g_ib_count >= NVL(FND_PROFILE.VALUE (
                             'CSL_IBITEM_COUNT_AT_LOCATION'), 0) THEN
       RETURN TRUE;
    ELSE

      /** Insert For other IB's at location */
      FOR c_ib_items IN c_new_ib_at_location (
               p_resource_id, p_party_site_id , l_location_id, l_party_id )
      LOOP

        IF g_ib_count <  NVL(FND_PROFILE.VALUE (
                               'CSL_IBITEM_COUNT_AT_LOCATION'), 0) THEN
          Insert_ACC_Record ( c_ib_items.instance_id,
                                   p_resource_id, p_flow_type);
        ELSE
           EXIT;
        END IF;

      END LOOP;
    END IF;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Leaving Pre_Insert_Child procedure'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    -- ER 3168446
    g_ib_count := 0;

    /*** always return success ***/
    RETURN TRUE;
  EXCEPTION
     WHEN OTHERS THEN
       g_ib_count := 0;
       IF c_ib_party%ISOPEN THEN
           CLOSE c_ib_party;
       END IF;
       IF c_existing_ib_at_location%ISOPEN THEN
           CLOSE c_existing_ib_at_location;
       END IF;
       IF c_new_ib_at_location%ISOPEN THEN
           CLOSE c_new_ib_at_location;
       END IF;
  END Pre_Insert_Child;

  /**/
  PROCEDURE Delete_Childs
    ( p_instance_id IN NUMBER
    , p_resource_id IN NUMBER
    )
  IS
    CURSOR c_child_instance ( b_instance_id NUMBER ) IS
     SELECT     subject_id
     FROM       CSI_II_RELATIONSHIPS
     WHERE      RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
     START WITH object_id = b_instance_id
     CONNECT BY PRIOR subject_id = object_id;
    r_child_instance c_child_instance%ROWTYPE;

    l_profile_value VARCHAR2(240);
  BEGIN
    /*** get debug level ***/
    g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Entering Delete_Childs'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    l_profile_value := NVL(fnd_profile.value_specific('CSL_REPLICATE_CP_CHILDS'), 'N' );
    -- IF Replicate childs profile set to Y THEN
    IF l_profile_value = 'Y' THEN
      -- LOOP through the child list
      FOR r_child_instance IN c_child_instance( p_instance_id ) LOOP
        -- Delete IB (child_instance_id)
        Delete_ACC_Record
           ( r_child_instance.subject_id
           , p_resource_id
  	 , CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL
           );

        IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
          jtm_message_log_pkg.Log_Msg
          ( p_instance_id
          , g_table_name
          , 'Child removed from ACC - INSTANCE_ID: ' || r_child_instance.subject_id
          , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
        END IF;
      END LOOP; -- Next child IB
    END IF;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Leaving Delete_Childs'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

  END Delete_Childs;

  PROCEDURE Delete_Parents
    ( p_instance_id IN NUMBER
    , p_resource_id IN NUMBER
    )
  IS
    CURSOR c_parent_instance ( b_instance_id NUMBER ) IS
     SELECT     object_id
     FROM       CSI_II_RELATIONSHIPS
     WHERE      RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
     AND        SUBJECT_ID = b_instance_id;
    r_parent_instance c_parent_instance%ROWTYPE;

    l_profile_value VARCHAR2(240);
  BEGIN
    /*** get debug level ***/
    g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Entering Delete_Parents'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    l_profile_value := NVL(fnd_profile.value_specific('CSL_REPLICATE_CP_PARENTS'), 'N' );

    -- If Replicate Parents profile set to Y THEN
    IF l_profile_value = 'Y' THEN
      -- LOOP through the parent list
      FOR r_parent_instance IN c_parent_instance( p_instance_id ) LOOP
        -- Delete IB (child_instance_id)
        Delete_ACC_Record
           ( r_parent_instance.object_id
           , p_resource_id
  	 , CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL
           );

        IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
          jtm_message_log_pkg.Log_Msg
          ( p_instance_id
          , g_table_name
          , 'Parent removed from ACC - INSTANCE_ID: ' || r_parent_instance.object_id
          , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
        END IF;
      END LOOP; -- Next child IB
    END IF;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Leaving Delete_Parents'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

  END Delete_Parents;


  /***
    Public procedure that gets called when an item instance needs to be
    deleted from ACC table.
    p_flow_type - DEFAULT CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL
  ***/
  PROCEDURE Post_Delete_Child
    ( p_instance_id IN NUMBER
     ,p_resource_id IN NUMBER
     ,p_flow_type   IN NUMBER
     ,p_party_site_id IN NUMBER )
  IS

    /** ER 3168446 - View IB at location Fix */

    CURSOR c_ib_party ( b_party_site_id NUMBER ) IS
      SELECT party_id, location_id FROM hz_party_sites
      WHERE party_site_id = b_party_site_id;


    CURSOR c_ib_at_location (
           b_resource_id   NUMBER,
           b_party_site_id NUMBER,
           b_location_id   NUMBER,
           b_party_id      NUMBER  ) IS
      SELECT acc.instance_id
        FROM CSL_CSI_ITEM_INSTANCES_ACC acc, CSI_ITEM_INSTANCES cii
          WHERE acc.instance_id = cii.instance_id
          AND acc.resource_id = b_resource_id
          AND owner_party_id = b_party_id
          AND ( ( cii.location_id = b_party_site_id
                    AND cii.location_type_code = 'HZ_PARTY_SITES' )
                 OR ( cii.location_id = b_location_id
                      AND  cii.location_type_code = 'HZ_LOCATIONS') );

     l_party_id NUMBER;
     l_location_id NUMBER;

     l_acc_id NUMBER;
  BEGIN
    /*** get debug level ***/
    g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Entering Post_Delete_Child'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    /** ER 3168446 - View IB at Location Fix
        Delete the Instance associated with this SR and other Instances also
    */

    /** Get the Party of this party Site */
    OPEN c_ib_party (p_party_site_id);
    FETCH c_ib_party INTO l_party_id, l_location_id;
    CLOSE c_ib_party;


    FOR c_ib_items IN c_ib_at_location (
            p_resource_id, p_party_site_id, l_location_id, l_party_id )
    LOOP

      delete_acc_record ( p_instance_id, p_resource_id, p_flow_type);

    END LOOP;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Leaving Post_Delete_Child'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;
  END Post_Delete_Child;

/*Procedure that gets called from mtl_onhand_quantity acc package*/
PROCEDURE Pre_Insert_Item
  ( p_inventory_item_id IN NUMBER
  , p_organization_id   IN NUMBER
  , p_subinventory_code IN VARCHAR2
  , p_resource_id       IN NUMBER
  )
IS
  CURSOR c_item_instance( b_inventory_item_id NUMBER
                        , b_organization_id NUMBER
		        , b_subinventory_code VARCHAR2)
  IS
   SELECT instance_id,
          INV_ORGANIZATION_ID,
          INVENTORY_ITEM_ID,
          INV_MASTER_ORGANIZATION_ID
   FROM   csi_item_instances
   WHERE  inventory_item_id = b_inventory_item_id
   AND    inv_organization_id = b_organization_id
   AND    inv_subinventory_name = b_subinventory_code;

 l_org_id NUMBER;

BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Entering Pre_Insert_Item'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  FOR r_item_instance IN c_item_instance ( p_inventory_item_id, p_organization_id, p_subinventory_code ) LOOP
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( r_item_instance.instance_id
      , g_table_name
      , 'Inserting ACC record for resource_id = ' || p_resource_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    JTM_HOOK_UTIL_PKG.Insert_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
      ,P_ACC_TABLE_NAME         => g_acc_table_name
      ,P_RESOURCE_ID            => p_resource_id
      ,P_PK1_NAME               => g_pk1_name
      ,P_PK1_NUM_VALUE          => r_item_instance.instance_id
     );

    -- Add SYSTEM ITEMs
    --l_org_id := NVL( r_item_instance.INV_ORGANIZATION_ID, TO_NUMBER(FND_PROFILE.VALUE('CS_INV_VALIDATION_ORG')));
    l_org_id := r_item_instance.INV_MASTER_ORGANIZATION_ID;
    CSL_MTL_SYSTEM_ITEMS_ACC_PKG.Pre_Insert_Child( p_inventory_item_id => r_item_instance.INVENTORY_ITEM_ID
                                                 , p_organization_id   => l_org_id
                                                 , p_resource_id       => p_resource_id
                                                 );

  END LOOP;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Leaving Pre_Insert_Item'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Pre_Insert_Item;

/*Procedure that gets called from mtl_onhand_quantity acc package*/
PROCEDURE Post_Delete_Item
  ( p_inventory_item_id IN NUMBER
  , p_organization_id   IN NUMBER
  , p_subinventory_code IN VARCHAR2
  , p_resource_id       IN NUMBER
  )
IS
  CURSOR c_item_instance( b_inventory_item_id NUMBER
                        , b_organization_id NUMBER
		        , b_subinventory_code VARCHAR2)
  IS
   SELECT instance_id,
          INV_ORGANIZATION_ID,
          INVENTORY_ITEM_ID,
          INV_MASTER_ORGANIZATION_ID
   FROM   csi_item_instances
   WHERE  inventory_item_id = b_inventory_item_id
   AND    inv_organization_id = b_organization_id
   AND    inv_subinventory_name = b_subinventory_code;

  l_org_id NUMBER;

BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Entering Post_Delete_Item'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  FOR r_item_instance IN c_item_instance ( p_inventory_item_id, p_organization_id, p_subinventory_code ) LOOP
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( r_item_instance.instance_id
      , g_table_name
      , 'Deleting ACC record for resource_id = ' || p_resource_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    /*** Delete item instance ACC record ***/
    JTM_HOOK_UTIL_PKG.Delete_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
      ,P_ACC_TABLE_NAME         => g_acc_table_name
      ,P_PK1_NAME               => g_pk1_name
      ,P_PK1_NUM_VALUE          => r_item_instance.instance_id
      ,P_RESOURCE_ID            => p_resource_id
     );

    -- Delete SYSTEM ITEMs
    --l_org_id := NVL( r_item_instance.INV_ORGANIZATION_ID, TO_NUMBER(FND_PROFILE.VALUE('CS_INV_VALIDATION_ORG')));
    l_org_id := r_item_instance.INV_MASTER_ORGANIZATION_ID;
    CSL_MTL_SYSTEM_ITEMS_ACC_PKG.Post_Delete_Child( p_inventory_item_id => r_item_instance.INVENTORY_ITEM_ID
                                                 , p_organization_id   => l_org_id
                                                 , p_resource_id       => p_resource_id
                                                 );

  END LOOP;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Leaving Post_Delete_Item'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Post_Delete_Item;


/*** Called before item instance Insert ***/
PROCEDURE PRE_INSERT_ITEM_INSTANCE
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_INSERT_ITEM_INSTANCE;

/*** Called after item instance Insert ***/
PROCEDURE POST_INSERT_ITEM_INSTANCE ( p_api_version      IN  NUMBER
                                    , P_Init_Msg_List    IN  VARCHAR2
                                    , P_Commit           IN  VARCHAR2
                                    , p_validation_level IN  NUMBER
                                    , p_instance_id      IN  NUMBER
                                    , X_Return_Status    OUT NOCOPY VARCHAR2
                                    , X_Msg_Count        OUT NOCOPY NUMBER
                                    , X_Msg_Data         OUT NOCOPY VARCHAR2)
IS
  l_dummy              BOOLEAN;

  CURSOR c_is_parent( b_instance_id NUMBER ) IS
   SELECT cia.resource_id
   FROM CSL_CSI_ITEM_INSTANCES_ACC cia
   ,    CSI_II_RELATIONSHIPS cir
   WHERE cir.relationship_type_code = 'COMPONENT-OF'
   AND   cir.subject_id = cia.instance_id
   AND   cir.object_id = b_instance_id;

  CURSOR c_is_child( b_instance_id NUMBER ) IS
   SELECT cia.resource_id
   FROM CSL_CSI_ITEM_INSTANCES_ACC cia
   ,    CSI_II_RELATIONSHIPS cir
   WHERE cir.relationship_type_code = 'COMPONENT-OF'
   AND   cir.object_id = cia.instance_id
   AND   cir.subject_id = b_instance_id;


BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_instance_id
    , g_table_name
    , 'Entering POST_INSERT hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
  /*Check if this item is a parent or child of an existing instance*/

  /*** Is this a parent ? ***/
  FOR r_is_parent IN c_is_parent( p_instance_id ) LOOP
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Instance is parent for resource: '||r_is_parent.resource_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;
    Insert_ACC_Record( p_instance_id => p_instance_id
                     , p_resource_id => r_is_parent.resource_id
		     , p_flow_type   => CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL
                     );
  END LOOP;

  /*Is this a child ?*/
  FOR r_is_child IN c_is_child( p_instance_id ) LOOP
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_instance_id
      , g_table_name
      , 'Instance is child for resource: '||r_is_child.resource_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    Insert_ACC_Record( p_instance_id => p_instance_id
                     , p_resource_id => r_is_child.resource_id
		     , p_flow_type   => CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL
                     );
  END LOOP;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_instance_id
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
    ( p_instance_id
    , g_table_name
    , 'Caught exception in POST_INSERT hook:' || fnd_global.local_chr(10) || sqlerrm
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  fnd_msg_pub.Add_Exc_Msg('CSL_CSI_ITEM_INSTANCES_ACC_PKG','POST_INSERT_ITEM_INSTANCE',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END POST_INSERT_ITEM_INSTANCE;

/* Called before item instance Update */
PROCEDURE PRE_UPDATE_ITEM_INSTANCE
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_UPDATE_ITEM_INSTANCE;

/* Called after item instance Update */
PROCEDURE POST_UPDATE_ITEM_INSTANCE
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END POST_UPDATE_ITEM_INSTANCE;

/* Called before item instance Delete */
PROCEDURE PRE_DELETE_ITEM_INSTANCE
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_DELETE_ITEM_INSTANCE;

/* Called after item instance Delete */
PROCEDURE POST_DELETE_ITEM_INSTANCE
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END POST_DELETE_ITEM_INSTANCE;

PROCEDURE CONC_ITEM_INSTANCES( p_last_run_date IN DATE)
IS

  CURSOR c_changed(b_last_run_date DATE) IS
   SELECT ACCESS_ID , resource_id
   FROM csl_csi_item_instances_acc
   WHERE (instance_id in
     (SELECT instance_id
      FROM csi_item_instances
      WHERE last_update_date >= b_last_run_date));

  l_org_id        NUMBER;
  l_dummy         BOOLEAN;

  TYPE access_idTab   IS TABLE OF CSL_CSI_ITEM_INSTANCES_ACC.access_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE inst_idTab     IS TABLE OF CSL_CSI_ITEM_INSTANCES_ACC.instance_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE resource_idTab IS TABLE OF CSL_CSI_ITEM_INSTANCES_ACC.resource_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE inv_org_idTab  IS TABLE OF CSI_ITEM_INSTANCES.INV_ORGANIZATION_ID%TYPE INDEX BY BINARY_INTEGER;
  TYPE inv_itm_idTab  IS TABLE OF CSI_ITEM_INSTANCES.INVENTORY_ITEM_ID%TYPE INDEX BY BINARY_INTEGER;
  l_tab_access_id     ASG_DOWNLOAD.ACCESS_LIST;
  l_tab_resource_id   ASG_DOWNLOAD.USER_LIST;

  acc_id      access_idTab;
  inst_id     inst_idTab;
  res_id      resource_idTab;
  inv_org_id  inv_org_idTab;
  inv_itm_id  inv_itm_idTab;

BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'Entering CONC_ITEM_INSTANCES hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  --UPDATE
  /*Fetch all changed item instances that are in the acc table*/
  OPEN c_changed( p_last_run_date );
  FETCH c_changed BULK COLLECT INTO l_tab_access_id, l_tab_resource_id;

  IF (l_tab_access_id.COUNT > 0) THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
       jtm_message_log_pkg.Log_Msg
       ( 0
       , g_table_name
       , 'Update ACC record for all resources, count =  ' || l_tab_access_id.COUNT
       , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    /*** push to oLite using asg_download ***/
    l_dummy := asg_download.markdirty(
            P_PUB_ITEM     => g_publication_item_name(1)
          , P_ACCESSLIST   => l_tab_access_id
          , P_RESOURCELIST => l_tab_resource_id
          , P_DML_TYPE     => 'U'
          , P_TIMESTAMP    => SYSDATE
          );
  END IF;
  CLOSE c_changed;

  -- INSERT
  SELECT cii.INSTANCE_ID
  ,      cii.INV_ORGANIZATION_ID
  ,      cii.INVENTORY_ITEM_ID
  ,      cqa.RESOURCE_ID
  BULK COLLECT INTO inst_id, inv_org_id, inv_itm_id, res_id
  FROM   csi_item_instances cii
  ,      csl_mtl_onhand_qty_acc cqa
  ,      csi_instance_statuses iis
  WHERE  cii.inventory_item_id     = cqa.inventory_item_id
  AND    cii.inv_organization_id   = cqa.organization_id
  AND    cii.inv_subinventory_name = cqa.subinventory_code
  AND    ((cqa.LOT_NUMBER IS NULL AND cii.LOT_NUMBER IS NULL)
   OR (cqa.LOT_NUMBER = cii.LOT_NUMBER))
  AND ((cqa.LOCATOR_ID IS NULL AND cii.INV_LOCATOR_ID IS NULL)
   OR (cqa.LOCATOR_ID = cii.INV_LOCATOR_ID))
  AND ((cqa.REVISION IS NULL AND cii.INVENTORY_REVISION IS NULL)
   OR (cqa.REVISION = cii.INVENTORY_REVISION))
  AND    cii.location_type_code    = 'INVENTORY'
  AND    cii.INSTANCE_STATUS_ID    = iis.instance_status_id
  AND    NVL(iis.terminated_flag,'N') = 'N'
  AND    NOT EXISTS
  ( SELECT null
    FROM   csl_csi_item_instances_acc cia
    WHERE  cii.instance_id = cia.instance_id
    AND    cqa.resource_id = cia.resource_id
  );

  IF (inst_id.COUNT > 0) THEN
    FOR i IN inst_id.FIRST..inst_id.LAST LOOP
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
         jtm_message_log_pkg.Log_Msg
         ( inst_id(i)
         , g_table_name
         , 'Inserting ACC record for resource_id = ' || res_id(i)
         , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

     JTM_HOOK_UTIL_PKG.Insert_Acc
       ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
        ,P_ACC_TABLE_NAME         => g_acc_table_name
        ,P_RESOURCE_ID            => res_id(i)
        ,P_PK1_NAME               => g_pk1_name
        ,P_PK1_NUM_VALUE          => inst_id(i)
       );

     -- Add SYSTEM ITEMs
     CSL_MTL_SYSTEM_ITEMS_ACC_PKG.Pre_Insert_Child( p_inventory_item_id  => inv_itm_id(i)
                                                   , p_organization_id   => inv_org_id(i)
                                                   , p_resource_id       => res_id(i)
                                                   );
    END LOOP;
  END IF;

  -- DELETE
  acc_id.DELETE;
  inst_id.DELETE;
  inv_org_id.DELETE;
  inv_itm_id.DELETE;
  res_id.DELETE;

  SELECT ii.INSTANCE_ID
  ,      ii.INV_ORGANIZATION_ID
  ,      ii.INVENTORY_ITEM_ID
  ,      iiac.RESOURCE_ID
  BULK COLLECT INTO inst_id, inv_org_id, inv_itm_id, res_id
  FROM CSL_CSI_ITEM_INSTANCES_ACC iiac
  ,    CSI_ITEM_INSTANCES ii
  ,    CSI_INSTANCE_STATUSES iis
  WHERE ii.INV_ORGANIZATION_ID IS NOT NULL
  AND   ii.INV_SUBINVENTORY_NAME IS NOT NULL
  AND   ii.INVENTORY_ITEM_ID IS NOT NULL
  AND   ii.INSTANCE_ID = iiac.INSTANCE_ID
  AND   ii.INSTANCE_STATUS_ID = iis.INSTANCE_STATUS_ID
  AND   NVL(iis.TERMINATED_FLAG,'N') = 'Y'
  AND   NOT EXISTS
  ( SELECT null
    FROM   CS_INCIDENTS_ALL_B inc
    ,      CSL_CS_INCIDENTS_ALL_ACC inac
    WHERE  inc.incident_id = inac.incident_id
    AND    inc.customer_product_id = iiac.instance_id
    AND    inac.resource_id = iiac.resource_id
  );

  IF (inst_id.COUNT > 0) THEN
    FOR i IN inst_id.FIRST..inst_id.LAST LOOP
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( inst_id(i)
        , g_table_name
        , 'Deleting ACC record for resource_id = ' || res_id(i)
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      -- Delete item instance ACC record
      JTM_HOOK_UTIL_PKG.Delete_Acc
        ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
        ,P_ACC_TABLE_NAME         => g_acc_table_name
        ,P_PK1_NAME               => g_pk1_name
        ,P_PK1_NUM_VALUE          => inst_id(i)
        ,P_RESOURCE_ID            => res_id(i)
       );

      -- Delete SYSTEM ITEMs
      CSL_MTL_SYSTEM_ITEMS_ACC_PKG.Post_Delete_Child( p_inventory_item_id => inv_itm_id(i)
                                                     , p_organization_id   => inv_org_id(i)
                                                     , p_resource_id       => res_id(i)
                                                     );
    END LOOP;
  END IF;


  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'Leaving CONC_ITEM_INSTANCES hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

END CONC_ITEM_INSTANCES;

END CSL_CSI_ITEM_INSTANCES_ACC_PKG;

/
