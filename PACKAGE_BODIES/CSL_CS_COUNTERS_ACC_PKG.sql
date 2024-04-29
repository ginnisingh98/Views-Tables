--------------------------------------------------------
--  DDL for Package Body CSL_CS_COUNTERS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_CS_COUNTERS_ACC_PKG" AS
/* $Header: cslctacb.pls 115.10 2002/11/08 14:03:34 asiegers ship $ */

/*** Globals ***/
g_item_insts_acc_table_name            CONSTANT VARCHAR2(30) := 'CSL_CSI_ITEM_INSTANCES_ACC';
g_item_insts_table_name            CONSTANT VARCHAR2(30) := 'CSI_ITEM_INSTANCES';
g_item_insts_pk1_name              CONSTANT VARCHAR2(30) := 'INSTANCE_ID';

g_ctr_grps_acc_table_name        CONSTANT VARCHAR2(30) := 'JTM_CS_COUNTER_GROUPS_ACC';
g_ctr_grps_table_name            CONSTANT VARCHAR2(30) := 'CS_COUNTER_GROUPS';
g_ctr_grps_pk1_name              CONSTANT VARCHAR2(30) := 'COUNTER_GROUP_ID';
g_ctr_grps_pubi_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('CS_COUNTER_GROUPS');

g_counters_acc_table_name        CONSTANT VARCHAR2(30) := 'JTM_CS_COUNTERS_ACC';
g_counters_table_name            CONSTANT VARCHAR2(30) := 'CS_COUNTERS';
g_counters_pk1_name              CONSTANT VARCHAR2(30) := 'COUNTER_ID';
g_counters_pubi_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('CS_COUNTERS');

g_ctr_props_acc_table_name        CONSTANT VARCHAR2(30) := 'JTM_CS_COUNTER_PROPS_ACC';
g_ctr_props_table_name            CONSTANT VARCHAR2(30) := 'CS_COUNTER_PROPERTIES';
g_ctr_props_pk1_name              CONSTANT VARCHAR2(30) := 'COUNTER_PROPERTY_ID';
g_ctr_props_pubi_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('CS_COUNTER_PROPS');

g_old_resource_id       NUMBER; -- variable containing old resource_id; populated in Pre_Update hook
g_debug_level           NUMBER; -- debug level

/************* PRIVATE FUNCTIONS / PROCEDURES  *********/

/***
  PRIVATE Function to return the parent (item_instance)
***/
FUNCTION Get_Parent_Item_Instance_Id(p_counter_group_id IN NUMBER)
RETURN NUMBER
IS
  CURSOR c_parent(b_counter_group_id NUMBER) IS
    SELECT SOURCE_OBJECT_ID
    FROM CS_COUNTER_GROUPS
    WHERE SOURCE_OBJECT_CODE = 'CP' AND COUNTER_GROUP_ID = b_counter_group_id;
  l_parent_id  NUMBER;
BEGIN
  OPEN c_parent(p_counter_group_id);
  FETCH c_parent INTO l_parent_id;
  IF c_parent%NOTFOUND THEN
    CLOSE c_parent;
    RETURN NULL;
  END IF;
  CLOSE c_parent;
  RETURN l_parent_id;
EXCEPTION
  WHEN OTHERS THEN
    jtm_message_log_pkg.Log_Msg
    ( p_counter_group_id
    , g_ctr_grps_table_name
    , 'Exception happened in Get_Parent_Item_Instance_Id for ' || p_counter_group_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    RETURN NULL;
END Get_Parent_Item_Instance_Id;

FUNCTION Get_Parent_Ctr_Grp_Id(p_counter_id IN NUMBER)
RETURN NUMBER
IS
  CURSOR c_parent(b_counter_id NUMBER) IS
    SELECT COUNTER_GROUP_ID
    FROM CS_COUNTERS
    WHERE COUNTER_ID = b_counter_id;
  l_parent_id  NUMBER;
BEGIN
  OPEN c_parent(p_counter_id);
  FETCH c_parent INTO l_parent_id;
  IF c_parent%NOTFOUND THEN
    CLOSE c_parent;
    RETURN NULL;
  END IF;
  CLOSE c_parent;
  RETURN l_parent_id;
EXCEPTION
  WHEN OTHERS THEN
    jtm_message_log_pkg.Log_Msg
    ( p_counter_id
    , g_ctr_grps_table_name
    , 'Exception happened in Get_Parent_Ctr_Grp_Id for ' || p_counter_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    RETURN NULL;
END Get_Parent_Ctr_Grp_Id;

FUNCTION Get_Parent_Counter_Id(p_ctr_prop_id IN NUMBER)
RETURN NUMBER
IS
  CURSOR c_parent(b_ctr_prop_id NUMBER) IS
    SELECT COUNTER_ID
    FROM CS_COUNTER_PROPERTIES
    WHERE COUNTER_PROPERTY_ID = b_ctr_prop_id;
  l_parent_id  NUMBER;
BEGIN
  OPEN c_parent(p_ctr_prop_id);
  FETCH c_parent INTO l_parent_id;
  IF c_parent%NOTFOUND THEN
    CLOSE c_parent;
    RETURN NULL;
  END IF;
  CLOSE c_parent;
  RETURN l_parent_id;
EXCEPTION
  WHEN OTHERS THEN
    jtm_message_log_pkg.Log_Msg
    ( p_ctr_prop_id
    , g_ctr_grps_table_name
    , 'Exception happened in Get_Parent_Counter_Id for ' || p_ctr_prop_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    RETURN NULL;
END Get_Parent_Counter_Id;

/***************************************
  Procedures for CS_COUNTER_PROPERTIES hooks
 ***************************************/

/* private procedure that replicates given counter value related data for resource
 * reading is always controlled by counter_value not counter_prop
 */
PROCEDURE INSERT_COUNTER_PROP_ACC_RECORD ( p_counter_property_id IN NUMBER,
                              p_resource_id      IN NUMBER
                            )
IS
BEGIN
-- add debug info later.
  JTM_HOOK_UTIL_PKG.Insert_Acc
  ( P_PUBLICATION_ITEM_NAMES => g_ctr_props_pubi_name
   ,P_ACC_TABLE_NAME         => g_ctr_props_acc_table_name
   ,P_PK1_NAME               => g_ctr_props_pk1_name
   ,P_PK1_NUM_VALUE          => p_counter_property_id
   ,P_RESOURCE_ID            => p_resource_id
  );
END INSERT_COUNTER_PROP_ACC_RECORD;

PROCEDURE UPDATE_COUNTER_PROP_ACC_RECORD (
                              p_resource_id    IN NUMBER,
                              p_acc_id    IN NUMBER
                            )
IS
BEGIN
-- add debug info later.
  JTM_HOOK_UTIL_PKG.UPDATE_Acc
  ( P_PUBLICATION_ITEM_NAMES => g_ctr_props_pubi_name
   ,P_ACC_TABLE_NAME         => g_ctr_props_acc_table_name
   ,P_RESOURCE_ID            => p_resource_id
   ,P_ACCESS_ID              => p_acc_id
  );
END UPDATE_COUNTER_PROP_ACC_RECORD;

PROCEDURE DELETE_COUNTER_PROP_ACC_RECORD ( p_counter_property_id IN NUMBER,
                              p_resource_id      IN NUMBER
                            )
IS
BEGIN
-- add debug info later.
  JTM_HOOK_UTIL_PKG.DELETE_Acc
  ( P_PUBLICATION_ITEM_NAMES => g_ctr_props_pubi_name
   ,P_ACC_TABLE_NAME         => g_ctr_props_acc_table_name
   ,P_PK1_NAME               => g_ctr_props_pk1_name
   ,P_PK1_NUM_VALUE          => p_counter_property_id
   ,P_RESOURCE_ID            => p_resource_id
  );
END DELETE_COUNTER_PROP_ACC_RECORD;

/***************************************
  Procedures for CS_COUNTERS hooks
 ***************************************/
/* private procedure that replicates given counters related data for resource */
PROCEDURE INSERT_COUNTER_ACC_RECORD ( p_counter_id IN NUMBER,
                              p_resource_id      IN NUMBER
                            )
IS
  CURSOR c_counter_property (b_counter_id NUMBER) IS
    SELECT COUNTER_PROPERTY_ID
    FROM  CS_COUNTER_PROPERTIES
    WHERE COUNTER_ID = b_counter_id;
  r_counter_property_id  c_counter_property%ROWTYPE;
  l_ins_ctr_val_success BOOLEAN := TRUE;
BEGIN
-- add debug info later.
  JTM_HOOK_UTIL_PKG.Insert_Acc
  ( P_PUBLICATION_ITEM_NAMES => g_counters_pubi_name
   ,P_ACC_TABLE_NAME         => g_counters_acc_table_name
   ,P_PK1_NAME               => g_counters_pk1_name
   ,P_PK1_NUM_VALUE          => p_counter_id
   ,P_RESOURCE_ID            => p_resource_id
  );

  -- add debug info later
  l_ins_ctr_val_success := CSL_CS_COUNTER_VALS_ACC_PKG.POST_INSERT_PARENT( p_counter_id, p_resource_id );
  IF NOT l_ins_ctr_val_success THEN
    RETURN;
  END IF;

  FOR r_counter_property_id IN c_counter_property( p_counter_id ) LOOP
    -- add debug info later
    INSERT_COUNTER_PROP_ACC_RECORD( r_counter_property_id.COUNTER_PROPERTY_ID, p_resource_id );
  END LOOP;
END INSERT_COUNTER_ACC_RECORD;

PROCEDURE UPDATE_COUNTER_ACC_RECORD (
                              p_resource_id    IN NUMBER,
                              p_acc_id    IN NUMBER
                            )
IS
BEGIN
-- add debug info later.
  JTM_HOOK_UTIL_PKG.Update_Acc
  ( P_PUBLICATION_ITEM_NAMES => g_counters_pubi_name
   ,P_ACC_TABLE_NAME         => g_counters_acc_table_name
   ,P_RESOURCE_ID            => p_resource_id
   ,P_ACCESS_ID              => p_acc_id
  );

END UPDATE_COUNTER_ACC_RECORD;

PROCEDURE DELETE_COUNTER_ACC_RECORD ( p_counter_id IN NUMBER,
                              p_resource_id      IN NUMBER
                            )
IS
  CURSOR c_counter_property (b_counter_id NUMBER) IS
    SELECT COUNTER_PROPERTY_ID
    FROM  CS_COUNTER_PROPERTIES
    WHERE COUNTER_ID = b_counter_id;
  r_counter_property_id  c_counter_property%ROWTYPE;
  l_del_ctr_val_success BOOLEAN := TRUE;
BEGIN
-- add debug info later.
  JTM_HOOK_UTIL_PKG.Delete_Acc
  ( P_PUBLICATION_ITEM_NAMES => g_counters_pubi_name
   ,P_ACC_TABLE_NAME         => g_counters_acc_table_name
   ,P_PK1_NAME               => g_counters_pk1_name
   ,P_PK1_NUM_VALUE          => p_counter_id
   ,P_RESOURCE_ID            => p_resource_id
  );

  -- add debug info later
  l_del_ctr_val_success := CSL_CS_COUNTER_VALS_ACC_PKG.PRE_DELETE_PARENT( p_counter_id, p_resource_id );
  IF NOT l_del_ctr_val_success THEN
    RETURN;
  END IF;
  FOR r_counter_property_id IN c_counter_property( p_counter_id ) LOOP
    -- add debug info later
    DELETE_COUNTER_PROP_ACC_RECORD( r_counter_property_id.COUNTER_PROPERTY_ID, p_resource_id );
  END LOOP;
END DELETE_COUNTER_ACC_RECORD;

/***************************************
  Procedures for CS_COUNTER_GROUPS hooks
 ***************************************/
/* private procedure that replicates given counter group related data for resource */
PROCEDURE INSERT_CTR_GRP_ACC_RECORD ( p_counter_group_id IN NUMBER,
                              p_resource_id      IN NUMBER
                            )
IS
  CURSOR c_counter (b_counter_group_id NUMBER) IS
    SELECT COUNTER_ID
    FROM  CS_COUNTERS
    WHERE COUNTER_GROUP_ID = b_counter_group_id;
BEGIN
  -- add debug info later.
  JTM_HOOK_UTIL_PKG.Insert_Acc
  ( P_PUBLICATION_ITEM_NAMES => g_ctr_grps_pubi_name
   ,P_ACC_TABLE_NAME         => g_ctr_grps_acc_table_name
   ,P_PK1_NAME               => g_ctr_grps_pk1_name
   ,P_PK1_NUM_VALUE          => p_counter_group_id
   ,P_RESOURCE_ID            => p_resource_id
  );

  FOR r_counter_id IN c_counter( p_counter_group_id ) LOOP
    -- add debug info later
    INSERT_COUNTER_ACC_RECORD( r_counter_id.COUNTER_ID, p_resource_id );
  END LOOP;
END INSERT_CTR_GRP_ACC_RECORD;

/* UPDATE_CTR_GRP_ACC_RECORD is not recurisive hierarchically */
PROCEDURE UPDATE_CTR_GRP_ACC_RECORD (
                              p_resource_id    IN NUMBER,
                              p_acc_id    IN NUMBER
                            )
IS
BEGIN
  -- add debug info later.
  JTM_HOOK_UTIL_PKG.Update_Acc
  ( P_PUBLICATION_ITEM_NAMES => g_ctr_grps_pubi_name
   ,P_ACC_TABLE_NAME         => g_ctr_grps_acc_table_name
   ,P_RESOURCE_ID            => p_resource_id
   ,P_ACCESS_ID              => p_acc_id
  );
END UPDATE_CTR_GRP_ACC_RECORD;

/* recursive delete */
PROCEDURE DELETE_CTR_GRP_ACC_RECORD ( p_counter_group_id IN NUMBER,
                              p_resource_id     IN NUMBER
                            )
IS
  CURSOR c_counter (b_counter_group_id NUMBER) IS
    SELECT COUNTER_ID
    FROM  CS_COUNTERS
    WHERE COUNTER_GROUP_ID = b_counter_group_id;
BEGIN
  -- add debug info later.
  JTM_HOOK_UTIL_PKG.Delete_Acc
  ( P_PUBLICATION_ITEM_NAMES => g_ctr_grps_pubi_name
   ,P_ACC_TABLE_NAME         => g_ctr_grps_acc_table_name
   ,P_PK1_NAME               => g_ctr_grps_pk1_name
   ,P_PK1_NUM_VALUE          => p_counter_group_id
   ,P_RESOURCE_ID            => p_resource_id
  );

  FOR r_counter_id IN c_counter( p_counter_group_id ) LOOP
    -- add debug info later
    DELETE_COUNTER_ACC_RECORD( r_counter_id.COUNTER_ID, p_resource_id );
  END LOOP;
END DELETE_CTR_GRP_ACC_RECORD;


/***
  Function that checks if a counter group record should be
  replicated. Returns TRUE if it should be replicated
  It checks if this is a valid counter_group_id.
  Then check if counter_group_id is associated with a customer_product_id replicatable.
 ***/
FUNCTION Replicate_Record
  ( p_counter_group_id NUMBER
  )
RETURN BOOLEAN
IS
  CURSOR c_counter_group ( b_counter_group_id NUMBER) IS
    SELECT null
    FROM CS_COUNTER_GROUPS
    WHERE COUNTER_GROUP_ID = b_counter_group_id;
  r_counter_group  c_counter_group%ROWTYPE;
BEGIN
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_counter_group_id
    , g_ctr_grps_table_name
    , 'Entering Replicate_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
  /* check if this is a valid counter_group_id. */
  OPEN c_counter_group(p_counter_group_id);
  FETCH c_counter_group INTO r_counter_group;
  IF c_counter_group%NOTFOUND THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( p_counter_group_id
      , g_ctr_grps_table_name
      , 'Replicate_Record error: Could not find counter_group_id ' || p_counter_group_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;
    CLOSE c_counter_group;
    RETURN FALSE;
  END IF;
  CLOSE c_counter_group;

  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    jtm_message_log_pkg.Log_Msg
    ( p_counter_group_id
    , g_ctr_grps_table_name
    , 'Exception happened in for counter_group_id ' || p_counter_group_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  RETURN FALSE;
END REPLICATE_RECORD;


/***
  Public procedure called after a parent record is inserted.
  The parent of counter group is CSI_ITEM_INSTANCE record.
  Called by CSL_CSI_ITEM_INSTANCE_ACC_PKG
***/
FUNCTION Post_Insert_Parent
  ( p_item_instance_id IN NUMBER
   ,p_resource_id        IN NUMBER
  )
RETURN BOOLEAN
IS
  CURSOR c_counter_groups (b_item_instance_id NUMBER) IS
    SELECT COUNTER_GROUP_ID
    FROM CS_COUNTER_GROUPS
    WHERE SOURCE_OBJECT_CODE = 'CP' AND SOURCE_OBJECT_ID = b_item_instance_id;
BEGIN
  FOR r_counter_group_id IN c_counter_groups(p_item_instance_id)
  LOOP
    INSERT_CTR_GRP_ACC_RECORD(r_counter_group_id.COUNTER_GROUP_ID, p_resource_id);
  END LOOP;
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
  RETURN FALSE;
END Post_Insert_Parent;

/***
  Public procedure called after a parent record is updated
  Check the new parent_id if it is in the ACC table.
  Called by CSL_CSI_ITEM_INSTANCE_ACC_PKG
***/
FUNCTION Post_Update_Parent
  ( p_item_instance_id IN NUMBER
   ,p_resource_id        IN NUMBER
  )
RETURN BOOLEAN
IS
BEGIN
  RETURN TRUE;
END Post_Update_Parent;

/***
  Public procedure that gets called before a parent record is deleted.
  Called by CSL_CSI_ITEM_INSTANCE_ACC_PKG
***/
FUNCTION Pre_Delete_Parent
  ( p_item_instance_id IN NUMBER
   ,p_resource_id        IN NUMBER
  )
RETURN BOOLEAN
IS
  CURSOR c_counter_groups (b_item_instance_id NUMBER) IS
    SELECT COUNTER_GROUP_ID
    FROM CS_COUNTER_GROUPS
    WHERE SOURCE_OBJECT_CODE = 'CP' AND SOURCE_OBJECT_ID = b_item_instance_id;
BEGIN
  FOR r_counter_group_id IN c_counter_groups(p_item_instance_id) LOOP
    DELETE_CTR_GRP_ACC_RECORD(r_counter_group_id.COUNTER_GROUP_ID, p_resource_id);
  END LOOP;
  RETURN TRUE;
END Pre_Delete_Parent;


/***
 *** The following Functions Called by VUHK of CS_COUNTERS_PUB
 ***/

/* Called before counter group Insert */
PROCEDURE PRE_INSERT_COUNTER_GROUP ( x_return_status out NOCOPY varchar2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END;

/* Called after counter group Insert */
/* Check if the counter group is associated with a replicable item instance */
PROCEDURE POST_INSERT_COUNTER_GROUP ( p_api_version           IN  NUMBER
                                    , P_Init_Msg_List         IN  VARCHAR2
                                    , P_Commit                IN  VARCHAR2
                                    , X_Return_Status         OUT NOCOPY VARCHAR2
                                    , X_Msg_Count             OUT NOCOPY NUMBER
                                    , X_Msg_Data              OUT NOCOPY VARCHAR2
                                    , p_source_object_cd      IN  VARCHAR2
                                    , p_source_object_id      IN  NUMBER
                                    , x_ctr_grp_id            IN  NUMBER
                                    , x_object_version_number OUT NOCOPY NUMBER)
IS
  l_tab_resource_id    dbms_sql.Number_Table;
  l_tab_access_id      dbms_sql.Number_Table;
  l_item_instance_id   NUMBER;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_item_instance_id := Get_Parent_Item_Instance_Id(x_ctr_grp_id);

  IF l_item_instance_id IS NULL
  THEN
    RETURN;
  END IF;

  JTM_HOOK_UTIL_PKG.Get_Resource_Acc_List
  ( p_acc_table_name   => g_item_insts_acc_table_name
   ,p_pk1_name         => g_item_insts_pk1_name
   ,p_pk1_num_value    => l_item_instance_id
   ,l_tab_resource_id  => l_tab_resource_id
   ,l_tab_access_id    => l_tab_access_id
  );

  IF l_tab_resource_id.COUNT > 0 THEN
    FOR i IN l_tab_resource_id.FIRST .. l_tab_resource_id.LAST LOOP
      INSERT_COUNTER_PROP_ACC_RECORD
      (x_ctr_grp_id
      ,l_tab_resource_id(i)
      );
    END LOOP;
  END IF;
END POST_INSERT_COUNTER_GROUP;

/* Called before counter group Update */
PROCEDURE PRE_UPDATE_COUNTER_GROUP ( x_return_status out NOCOPY varchar2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_UPDATE_COUNTER_GROUP;

/* Called after counter group Update */
PROCEDURE POST_UPDATE_COUNTER_GROUP( P_Api_Version              IN  NUMBER
                                   , P_Init_Msg_List            IN  VARCHAR2
                                   , P_Commit                   IN  VARCHAR2
                                   , X_Return_Status            OUT NOCOPY VARCHAR2
                                   , X_Msg_Count                OUT NOCOPY NUMBER
                                   , X_Msg_Data                 OUT NOCOPY VARCHAR2
                                   , p_ctr_grp_id               IN  NUMBER
                                   , p_object_version_number    IN  NUMBER
                                   , p_cascade_upd_to_instances IN  VARCHAR2
                                   , x_object_version_number    OUT NOCOPY NUMBER )
IS
  l_tab_resource_id    dbms_sql.Number_Table;
  l_tab_access_id      dbms_sql.Number_Table;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_ctr_grp_id IS NULL
  THEN
    RETURN;
  END IF;

  JTM_HOOK_UTIL_PKG.Get_Resource_Acc_List
  ( p_acc_table_name  => g_ctr_grps_acc_table_name
   ,p_pk1_name        => g_ctr_grps_pk1_name
   ,p_pk1_num_value   => p_ctr_grp_id
   ,l_tab_resource_id =>l_tab_resource_id
   ,l_tab_access_id   => l_tab_access_id
  );
  IF l_tab_resource_id.COUNT > 0 THEN
    FOR i IN l_tab_resource_id.FIRST .. l_tab_resource_id.LAST LOOP
      UPDATE_COUNTER_PROP_ACC_RECORD
      (
       l_tab_resource_id(i)
      ,l_tab_access_id(i)
      );
    END LOOP;
  END IF;
END POST_UPDATE_COUNTER_GROUP;

/* Called before counter group Delete */
PROCEDURE PRE_DELETE_COUNTER_GROUP ( x_return_status out NOCOPY varchar2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_DELETE_COUNTER_GROUP;

/* Called after counter group Delete */
PROCEDURE POST_DELETE_COUNTER_GROUP (
   p_counter_group_id IN NUMBER
  ,x_return_status out NOCOPY varchar2)
IS
  l_tab_resource_id    dbms_sql.Number_Table;
  l_tab_access_id      dbms_sql.Number_Table;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_counter_group_id IS NULL
  THEN
    RETURN;
  END IF;

  JTM_HOOK_UTIL_PKG.Get_Resource_Acc_List
  ( p_acc_table_name  => g_ctr_grps_acc_table_name
   ,p_pk1_name        => g_ctr_grps_pk1_name
   ,p_pk1_num_value   => p_counter_group_id
   ,l_tab_resource_id => l_tab_resource_id
   ,l_tab_access_id   => l_tab_access_id
  );
  IF l_tab_resource_id.COUNT > 0 THEN
    FOR i IN l_tab_resource_id.FIRST .. l_tab_resource_id.LAST LOOP
      DELETE_CTR_GRP_ACC_RECORD
      ( p_counter_group_id
      ,l_tab_access_id(i)
      );
    END LOOP;
  END IF;
END POST_DELETE_COUNTER_GROUP;

/*** counters ************/
/* Called before counter Insert */
PROCEDURE PRE_INSERT_COUNTER ( x_return_status out NOCOPY varchar2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_INSERT_COUNTER;

/* Called after counter Insert */
PROCEDURE POST_INSERT_COUNTER ( p_api_version           IN  NUMBER
                              , P_Init_Msg_List         IN  VARCHAR2
                              , P_Commit                IN  VARCHAR2
                              , X_Return_Status         OUT NOCOPY VARCHAR2
                              , X_Msg_Count             OUT NOCOPY NUMBER
                              , X_Msg_Data              OUT NOCOPY VARCHAR2
                              , x_ctr_id                IN  NUMBER
                              , x_object_version_number OUT NOCOPY NUMBER)
IS
  l_tab_resource_id    dbms_sql.Number_Table;
  l_tab_access_id      dbms_sql.Number_Table;
  l_counter_group_id NUMBER;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_counter_group_id := Get_Parent_Ctr_Grp_Id(x_ctr_id);

  IF l_counter_group_id IS NULL
  THEN
    RETURN;
  END IF;
  JTM_HOOK_UTIL_PKG.Get_Resource_Acc_List
  ( p_acc_table_name  => g_ctr_grps_acc_table_name
   ,p_pk1_name        => g_ctr_grps_pk1_name
   ,p_pk1_num_value   => l_counter_group_id
   ,l_tab_resource_id => l_tab_resource_id
   ,l_tab_access_id   => l_tab_access_id
  );
  IF l_tab_resource_id.COUNT > 0 THEN
    FOR i IN l_tab_resource_id.FIRST .. l_tab_resource_id.LAST LOOP
      INSERT_COUNTER_ACC_RECORD
      (x_ctr_id
      ,l_tab_resource_id(i)
      );
    END LOOP;
  END IF;
END POST_INSERT_COUNTER;

/* Called before counter Update */
PROCEDURE PRE_UPDATE_COUNTER ( x_return_status out NOCOPY varchar2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_UPDATE_COUNTER;

/* Called after counter Update */
PROCEDURE POST_UPDATE_COUNTER ( P_Api_Version              IN  NUMBER
                              , P_Init_Msg_List            IN  VARCHAR2
                              , P_Commit                   IN  VARCHAR2
                              , X_Return_Status            OUT NOCOPY VARCHAR2
                              , X_Msg_Count                OUT NOCOPY NUMBER
                              , X_Msg_Data                 OUT NOCOPY VARCHAR2
                              , p_ctr_id                   IN  NUMBER
                              , p_object_version_number    IN  NUMBER
                              , p_cascade_upd_to_instances IN  VARCHAR2
                              , x_object_version_number    OUT NOCOPY NUMBER )
IS
  l_tab_resource_id    dbms_sql.Number_Table;
  l_tab_access_id      dbms_sql.Number_Table;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  JTM_HOOK_UTIL_PKG.Get_Resource_Acc_List
  ( p_acc_table_name  => g_counters_acc_table_name
   ,p_pk1_name        => g_counters_pk1_name
   ,p_pk1_num_value   => p_ctr_id
   ,l_tab_resource_id => l_tab_resource_id
   ,l_tab_access_id   => l_tab_access_id
  );
  IF l_tab_resource_id.COUNT > 0 THEN
    FOR i IN l_tab_resource_id.FIRST .. l_tab_resource_id.LAST LOOP
      UPDATE_COUNTER_ACC_RECORD
      (l_tab_resource_id(i)
      ,l_tab_access_id(i)
      );
    END LOOP;
  END IF;
END POST_UPDATE_COUNTER;

/* Called before counter Delete */
PROCEDURE PRE_DELETE_COUNTER ( P_Api_Version   IN  NUMBER
                             , P_Init_Msg_List IN  VARCHAR2
                             , P_Commit        IN  VARCHAR2
                             , X_Return_Status OUT NOCOPY VARCHAR2
                             , X_Msg_Count     OUT NOCOPY NUMBER
                             , X_Msg_Data      OUT NOCOPY VARCHAR2
                             , p_ctr_id	       IN  NUMBER )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_DELETE_COUNTER;

/* Called after counter Delete */
PROCEDURE POST_DELETE_COUNTER (
   p_counter_id IN NUMBER
  ,x_return_status out NOCOPY varchar2)
IS
  l_tab_resource_id    dbms_sql.Number_Table;
  l_tab_access_id      dbms_sql.Number_Table;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  JTM_HOOK_UTIL_PKG.Get_Resource_Acc_List
  ( p_acc_table_name  => g_counters_acc_table_name
   ,p_pk1_name        => g_counters_pk1_name
   ,p_pk1_num_value   => p_counter_id
   ,l_tab_resource_id => l_tab_resource_id
   ,l_tab_access_id   => l_tab_access_id
  );
  IF l_tab_resource_id.COUNT > 0 THEN
    FOR i IN l_tab_resource_id.FIRST .. l_tab_resource_id.LAST LOOP
      DELETE_COUNTER_ACC_RECORD
      (p_counter_id
      ,l_tab_access_id(i)
      );
    END LOOP;
  END IF;
END POST_DELETE_COUNTER;


/* Called before counter property Insert */
PROCEDURE PRE_INSERT_COUNTER_PROPERTY ( x_return_status out NOCOPY varchar2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_INSERT_COUNTER_PROPERTY;

/* Called after counter property Insert */
PROCEDURE POST_INSERT_COUNTER_PROPERTY ( P_Api_Version           IN  NUMBER
                                       , P_Init_Msg_List         IN  VARCHAR2
                                       , P_Commit                IN  VARCHAR2
                                       , X_Return_Status         OUT NOCOPY VARCHAR2
                                       , X_Msg_Count             OUT NOCOPY NUMBER
                                       , X_Msg_Data              OUT NOCOPY VARCHAR2
                                       , x_ctr_prop_id           IN  NUMBER
                                       , x_object_version_number OUT NOCOPY NUMBER )
IS
  l_tab_resource_id    dbms_sql.Number_Table;
  l_tab_access_id      dbms_sql.Number_Table;
  l_counter_id         NUMBER;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_counter_id := Get_Parent_Counter_Id(x_ctr_prop_id);

  IF l_counter_id IS NULL
  THEN
    RETURN;
  END IF;

  JTM_HOOK_UTIL_PKG.Get_Resource_Acc_List
  ( p_acc_table_name  => g_counters_acc_table_name
   ,p_pk1_name        => g_counters_pk1_name
   ,p_pk1_num_value   => l_counter_id
   ,l_tab_resource_id => l_tab_resource_id
   ,l_tab_access_id   => l_tab_access_id
  );
  IF l_tab_resource_id.COUNT > 0 THEN
    FOR i IN l_tab_resource_id.FIRST .. l_tab_resource_id.LAST LOOP
      INSERT_COUNTER_PROP_ACC_RECORD
      (x_ctr_prop_id
      ,l_tab_resource_id(i)
      );
    END LOOP;
  END IF;
END POST_INSERT_COUNTER_PROPERTY;

/* Called before counter property Update */
PROCEDURE PRE_UPDATE_COUNTER_PROPERTY ( x_return_status out NOCOPY varchar2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_UPDATE_COUNTER_PROPERTY;

/* Called after counter property Update */
PROCEDURE POST_UPDATE_COUNTER_PROPERTY ( P_Api_Version              IN  NUMBER
                                       , P_Init_Msg_List            IN  VARCHAR2
                                       , P_Commit                   IN  VARCHAR2
                                       , X_Return_Status            OUT NOCOPY VARCHAR2
                                       , X_Msg_Count                OUT NOCOPY NUMBER
                                       , X_Msg_Data                 OUT NOCOPY VARCHAR2
                                       , p_ctr_prop_id              IN  NUMBER
                                       , p_object_version_number    IN  NUMBER
                                       , p_cascade_upd_to_instances IN  VARCHAR2
                                       , x_object_version_number    OUT NOCOPY NUMBER )
IS
  l_tab_resource_id    dbms_sql.Number_Table;
  l_tab_access_id      dbms_sql.Number_Table;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  JTM_HOOK_UTIL_PKG.Get_Resource_Acc_List
  ( p_acc_table_name  => g_ctr_props_acc_table_name
   ,p_pk1_name        => g_ctr_props_pk1_name
   ,p_pk1_num_value   => p_ctr_prop_id
   ,l_tab_resource_id => l_tab_resource_id
   ,l_tab_access_id   => l_tab_access_id
  );
  IF l_tab_resource_id.COUNT > 0 THEN
    FOR i IN l_tab_resource_id.FIRST .. l_tab_resource_id.LAST LOOP
      UPDATE_COUNTER_PROP_ACC_RECORD
      (l_tab_resource_id(i)
      ,l_tab_access_id(i)
      );
    END LOOP;
  END IF;
END POST_UPDATE_COUNTER_PROPERTY;

/* Called before counter property Delete */
PROCEDURE PRE_DELETE_COUNTER_PROPERTY ( P_Api_Version   IN  NUMBER
                                      , P_Init_Msg_List IN  VARCHAR2
                                      , P_Commit        IN  VARCHAR2
                                      , X_Return_Status OUT NOCOPY VARCHAR2
                                      , X_Msg_Count     OUT NOCOPY NUMBER
                                      , X_Msg_Data      OUT NOCOPY VARCHAR2
                                      , p_ctr_prop_id	IN  NUMBER )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_DELETE_COUNTER_PROPERTY;

/* Called after counter property Delete */
PROCEDURE POST_DELETE_COUNTER_PROPERTY (
   p_counter_prop_id IN NUMBER
  ,x_return_status out NOCOPY varchar2)
IS
  l_tab_resource_id    dbms_sql.Number_Table;
  l_tab_access_id      dbms_sql.Number_Table;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  JTM_HOOK_UTIL_PKG.Get_Resource_Acc_List
  ( p_acc_table_name  => g_ctr_props_acc_table_name
   ,p_pk1_name        => g_ctr_props_pk1_name
   ,p_pk1_num_value   => p_counter_prop_id
   ,l_tab_resource_id => l_tab_resource_id
   ,l_tab_access_id   => l_tab_access_id
  );
  IF l_tab_resource_id.COUNT > 0 THEN
    FOR i IN l_tab_resource_id.FIRST .. l_tab_resource_id.LAST LOOP
      DELETE_COUNTER_PROP_ACC_RECORD
      (p_counter_prop_id
      ,l_tab_access_id(i)
      );
    END LOOP;
  END IF;
END POST_DELETE_COUNTER_PROPERTY;

END CSL_CS_COUNTERS_ACC_PKG;

/
