--------------------------------------------------------
--  DDL for Package Body CSL_CS_COUNTER_VALS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_CS_COUNTER_VALS_ACC_PKG" AS
/* $Header: cslcvacb.pls 115.10 2002/11/08 14:02:58 asiegers ship $ */

/*** Globals ***/
g_counters_acc_table_name            CONSTANT VARCHAR2(30) := 'JTM_CS_COUNTERS_ACC';
g_counters_pk1_name              CONSTANT VARCHAR2(30) := 'COUNTER_ID';

g_ctr_vals_acc_table_name        CONSTANT VARCHAR2(30) := 'JTM_CS_COUNTER_VALUES_ACC';
g_ctr_vals_pubi_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('CS_COUNTER_VALUES');
g_ctr_vals_table_name            CONSTANT VARCHAR2(30) := 'CS_COUNTER_VALUES';
g_ctr_vals_pk1_name              CONSTANT VARCHAR2(30) := 'COUNTER_VALUE_ID';

g_ctr_prop_vals_acc_table_name        CONSTANT VARCHAR2(30) := 'JTM_CS_COUNTER_PROP_VALS_ACC';
g_ctr_prop_vals_pubi_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('CS_COUNTER_PROP_VALS');
g_ctr_prop_vals_table_name            CONSTANT VARCHAR2(30) := 'CS_COUNTER_PROP_VALUES';
g_ctr_prop_vals_pk1_name              CONSTANT VARCHAR2(30) := 'COUNTER_PROP_VALUE_ID';

g_debug_level           NUMBER;  -- debug level


/***
  PRIVATE Function to return the parent (counter_id)
***/
FUNCTION Get_Parent_Counter_Id(p_counter_value_id IN NUMBER)
RETURN NUMBER
IS
  CURSOR c_parent(b_counter_value_id NUMBER) IS
    SELECT COUNTER_ID
    FROM CS_COUNTER_VALUES
    WHERE COUNTER_VALUE_ID = b_counter_value_id;
  l_parent_id  NUMBER;
BEGIN
  OPEN c_parent(p_counter_value_id);
  FETCH c_parent INTO l_parent_id;
  IF c_parent%NOTFOUND THEN
    CLOSE c_parent;
    RETURN NULL;
  END IF;
  CLOSE c_parent;
  RETURN l_parent_id;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END Get_Parent_Counter_Id;

/***
  PRIVATE Function to return the parent (item_instance)
***/
FUNCTION Get_Parent_Counter_Value_Id(p_counter_prop_val_id IN NUMBER)
RETURN NUMBER
IS
  CURSOR c_parent(b_counter_prop_val_id NUMBER) IS
    SELECT COUNTER_VALUE_ID
    FROM CS_COUNTER_PROP_VALUES
    WHERE COUNTER_PROP_VALUE_ID = b_counter_prop_val_id;
  l_parent_id  NUMBER;
BEGIN
  OPEN c_parent(p_counter_prop_val_id);
  FETCH c_parent INTO l_parent_id;
  IF c_parent%NOTFOUND THEN
    CLOSE c_parent;
    RETURN NULL;
  END IF;
  CLOSE c_parent;
  RETURN l_parent_id;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END Get_Parent_Counter_Value_Id;

/***
 *** APIs directly access JTM_CS_COUNTER_PROP_VALS_ACC
 ***/
PROCEDURE INSERT_CTR_PROP_VAL_ACC_RECORD ( p_counter_prop_value_id IN NUMBER,
                              p_resource_id      IN NUMBER
                            )
IS
BEGIN
-- add debug info later.
  JTM_HOOK_UTIL_PKG.Insert_Acc
  ( P_PUBLICATION_ITEM_NAMES => g_ctr_prop_vals_pubi_name
   ,P_ACC_TABLE_NAME         => g_ctr_prop_vals_acc_table_name
   ,P_PK1_NAME               => g_ctr_prop_vals_pk1_name
   ,P_PK1_NUM_VALUE          => p_counter_prop_value_id
   ,P_RESOURCE_ID            => p_resource_id
  );
END INSERT_CTR_PROP_VAL_ACC_RECORD;

PROCEDURE DELETE_CTR_PROP_VAL_ACC_RECORD ( p_counter_prop_value_id IN NUMBER,
                              p_resource_id      IN NUMBER
                            )
IS
BEGIN
-- add debug info later.
  JTM_HOOK_UTIL_PKG.Delete_Acc
  ( P_PUBLICATION_ITEM_NAMES => g_ctr_prop_vals_pubi_name
   ,P_ACC_TABLE_NAME         => g_ctr_prop_vals_acc_table_name
   ,P_PK1_NAME               => g_ctr_prop_vals_pk1_name
   ,P_PK1_NUM_VALUE          => p_counter_prop_value_id
   ,P_RESOURCE_ID            => p_resource_id
  );
END DELETE_CTR_PROP_VAL_ACC_RECORD;

PROCEDURE UPDATE_CTR_PROP_VAL_ACC_RECORD
  ( p_resource_id        IN NUMBER
   ,p_acc_id             IN NUMBER
  )
IS
BEGIN
  JTM_HOOK_UTIL_PKG.UPDATE_Acc
  ( P_PUBLICATION_ITEM_NAMES => g_ctr_prop_vals_pubi_name
   ,P_ACC_TABLE_NAME         => g_ctr_prop_vals_acc_table_name
   ,P_RESOURCE_ID            => p_resource_id
   ,P_ACCESS_ID              => p_acc_id
  );
END UPDATE_CTR_PROP_VAL_ACC_RECORD;

/***************************************
 *** Private procedures that directly access the JTM_CS_COUNTER_VALUES_ACC tables
 ***************************************/
-- add debug info later.

PROCEDURE INSERT_CTR_VALUE_ACC_Record
  ( p_counter_value_id   IN NUMBER
   ,p_resource_id        IN NUMBER
  )
IS
  CURSOR c_counter_prop_value (b_counter_value_id NUMBER) IS
    SELECT COUNTER_PROP_VALUE_ID
    FROM  CS_COUNTER_PROP_VALUES
    WHERE COUNTER_VALUE_ID = b_counter_value_id;
BEGIN
  JTM_HOOK_UTIL_PKG.Insert_Acc
  ( P_PUBLICATION_ITEM_NAMES => g_ctr_vals_pubi_name
   ,P_ACC_TABLE_NAME         => g_ctr_vals_acc_table_name
   ,P_PK1_NAME               => g_ctr_vals_pk1_name
   ,P_PK1_NUM_VALUE          => p_counter_value_id
   ,P_RESOURCE_ID            => p_resource_id
  );
  FOR r_counter_prop_value_id IN c_counter_prop_value( p_counter_value_id ) LOOP
    -- add debug info later
    INSERT_CTR_PROP_VAL_ACC_RECORD( r_counter_prop_value_id.COUNTER_PROP_VALUE_ID, p_resource_id );
  END LOOP;
END INSERT_CTR_VALUE_ACC_Record;

PROCEDURE Update_CTR_VALUE_ACC_Record
  ( p_resource_id        IN NUMBER
   ,p_acc_id             IN NUMBER
  )
IS
BEGIN
  JTM_HOOK_UTIL_PKG.UPDATE_Acc
  ( P_PUBLICATION_ITEM_NAMES => g_ctr_vals_pubi_name
   ,P_ACC_TABLE_NAME         => g_ctr_vals_acc_table_name
   ,P_RESOURCE_ID            => p_resource_id
   ,P_ACCESS_ID              => p_acc_id
  );
END Update_CTR_VALUE_ACC_Record;

PROCEDURE DELETE_CTR_VALUE_ACC_Record
  ( p_counter_value_id   IN NUMBER
   ,p_resource_id        IN NUMBER
  )
IS
  CURSOR c_counter_prop_value (b_counter_value_id NUMBER) IS
    SELECT COUNTER_PROP_VALUE_ID
    FROM  CS_COUNTER_PROP_VALUES
    WHERE COUNTER_VALUE_ID = b_counter_value_id;
BEGIN
  JTM_HOOK_UTIL_PKG.Delete_Acc
  ( P_PUBLICATION_ITEM_NAMES => g_ctr_vals_pubi_name
   ,P_ACC_TABLE_NAME         => g_ctr_vals_acc_table_name
   ,P_PK1_NAME               => g_ctr_vals_pk1_name
   ,P_PK1_NUM_VALUE          => p_counter_value_id
   ,P_RESOURCE_ID            => p_resource_id
  );
  FOR r_counter_prop_value_id IN c_counter_prop_value( p_counter_value_id ) LOOP
    -- add debug info later
    DELETE_CTR_PROP_VAL_ACC_RECORD( r_counter_prop_value_id.COUNTER_PROP_VALUE_ID, p_resource_id );
  END LOOP;
END DELETE_CTR_VALUE_ACC_Record;

/*******************************************************
 *** PUBLIC APIS accessed by JTM_CS_COUNTERS_ACC_PKG
 *******************************************************/

FUNCTION POST_INSERT_PARENT
  ( p_counter_id IN NUMBER
   ,p_resource_id        IN NUMBER
  )
RETURN BOOLEAN
IS
  CURSOR c_counter_values (b_counter_id NUMBER) IS
    SELECT COUNTER_VALUE_ID
    FROM CS_COUNTER_VALUES
    WHERE COUNTER_ID = b_counter_id;
BEGIN
  FOR r_counter_value_id IN c_counter_values(p_counter_id)
  LOOP
    INSERT_CTR_VALUE_ACC_RECORD(r_counter_value_id.COUNTER_VALUE_ID, p_resource_id);
  END LOOP;
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
  RETURN FALSE;
END Post_Insert_Parent;


FUNCTION PRE_DELETE_PARENT
  ( p_counter_id IN NUMBER
   ,p_resource_id        IN NUMBER
  )
RETURN BOOLEAN
IS
  CURSOR c_counter_values (b_counter_id NUMBER) IS
    SELECT COUNTER_VALUE_ID
    FROM CS_COUNTER_VALUES
    WHERE COUNTER_ID = b_counter_id;
BEGIN
  FOR r_counter_value_id IN c_counter_values(p_counter_id)
  LOOP
    DELETE_CTR_VALUE_ACC_RECORD(r_counter_value_id.COUNTER_VALUE_ID, p_resource_id);
  END LOOP;
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
  RETURN FALSE;
END PRE_DELETE_PARENT;

/************************************************
*** Public APIs accessed by VUHK package
************************************************/

/***
  Function that checks if counter value record should be replicated.
  Returns TRUE if it should
***/
FUNCTION Replicate_Record
  ( p_counter_value_id NUMBER
  )
RETURN BOOLEAN
IS
  CURSOR c_counter_value (b_counter_value_id NUMBER) IS
    SELECT *
    FROM CS_COUNTER_VALUES
    WHERE COUNTER_VALUE_ID = b_counter_value_id;
  CURSOR c_counter_acc (b_counter_id NUMBER) IS
    SELECT *
    FROM JTM_CS_COUNTERS_ACC
    WHERE COUNTER_ID = b_counter_id;
  r_counter_value  c_counter_value%ROWTYPE;
  r_counter_acc  c_counter_acc%ROWTYPE;
  l_counter_id CS_COUNTER_VALUES.COUNTER_ID%TYPE;
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  /*** Check if the p_counter_value_id is valid ***/
  OPEN c_counter_value( p_counter_value_id );
  FETCH c_counter_value INTO r_counter_value;
  IF c_counter_value%NOTFOUND THEN
    /*** could not find counter value record -> exit ***/
    CLOSE c_counter_value;
    RETURN FALSE;
  END IF;

  /*** Check if the counter_id is a not null ***/
  l_counter_id := r_counter_value.counter_id;
  IF l_counter_id IS NULL THEN
    /*** null counter_id -> exit ***/
    CLOSE c_counter_value;
    RETURN FALSE;
  END IF;
  CLOSE c_counter_value;

  /*** Check if the counter id is a valid counter_id in the acc table
       JTM_CS_COUNTERS_ACC ***/
  OPEN c_counter_acc( l_counter_id );
  FETCH c_counter_acc INTO r_counter_acc;
  IF c_counter_acc%NOTFOUND THEN
    /*** no -> don't replicate ***/
    RETURN FALSE;
  END IF;

  RETURN TRUE;
END Replicate_Record;

/********************************************************
  The following procedures are for VUHK of CS_COUNTER_VALUES.
 *******************************************/

/* Called before counter value Insert.
   DO NOTHING
 */
PROCEDURE PRE_INSERT_COUNTER_VALUE
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_INSERT_COUNTER_VALUE ;

/* Called after counter value Insert.
   Check if counter is mobilized. If so, do the insert.
 */
PROCEDURE POST_INSERT_COUNTER_VALUE ( P_Api_Version_Number IN  NUMBER
                                    , P_Init_Msg_List      IN  VARCHAR2
                                    , P_Commit             IN  VARCHAR2
                                    , p_validation_level   IN  NUMBER
                                    , p_COUNTER_GRP_LOG_ID IN  NUMBER
                                    , X_Return_Status      OUT NOCOPY VARCHAR2
                                    , X_Msg_Count          OUT NOCOPY NUMBER
                                    , X_Msg_Data           OUT NOCOPY VARCHAR2 )
IS
  l_tab_resource_id    dbms_sql.Number_Table;
  l_tab_access_id      dbms_sql.Number_Table;
  l_counter_id   NUMBER;

CURSOR c_ctr_vals( b_grp_log_id NUMBER ) IS
  SELECT *
  FROM CS_COUNTER_VALUES
  WHERE COUNTER_GRP_LOG_ID = b_grp_log_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*Fetch all counter value records for this grp log id*/
  FOR r_ctr_vals IN c_ctr_vals( p_COUNTER_GRP_LOG_ID ) LOOP

   l_counter_id := Get_Parent_Counter_Id(r_ctr_vals.counter_value_id);

   IF l_counter_id IS NOT NULL
    THEN
    JTM_HOOK_UTIL_PKG.Get_Resource_Acc_List
    ( p_acc_table_name  => g_counters_acc_table_name
     ,p_pk1_name        => g_counters_pk1_name
     ,p_pk1_num_value   => l_counter_id
     ,l_tab_resource_id => l_tab_resource_id
     ,l_tab_access_id   => l_tab_access_id
    );

    IF l_tab_resource_id.COUNT > 0 THEN
      FOR i IN l_tab_resource_id.FIRST .. l_tab_resource_id.LAST LOOP
        INSERT_CTR_VALUE_ACC_RECORD
        (r_ctr_vals.counter_value_id
        ,l_tab_resource_id(i)
        );
      END LOOP; --l_tab_resource_id.FIRST
    END IF; --l_tab_resource_id.COUNT
   END IF; -- l_counter_id not null
  END LOOP; --c_ctr_vals
END POST_INSERT_COUNTER_VALUE ;

/* Called before counter value Update
 * DO NOTHING
 */
PROCEDURE PRE_UPDATE_COUNTER_VALUE ( x_return_status OUT NOCOPY varchar2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_UPDATE_COUNTER_VALUE ;

/* Called after counter value Update
 * Mark dirty
 */
PROCEDURE POST_UPDATE_COUNTER_VALUE ( P_Api_Version_Number    IN  NUMBER
                                    , P_Init_Msg_List         IN  VARCHAR2
                                    , P_Commit                IN  VARCHAR2
                                    , p_validation_level      IN  NUMBER
                                    , p_COUNTER_GRP_LOG_ID    IN  NUMBER
                                    , p_object_version_number IN  NUMBER
                                    , X_Return_Status         OUT NOCOPY VARCHAR2
                                    , X_Msg_Count             OUT NOCOPY NUMBER
                                    , X_Msg_Data              OUT NOCOPY VARCHAR2 )
IS
  l_tab_resource_id    dbms_sql.Number_Table;
  l_tab_access_id      dbms_sql.Number_Table;
CURSOR c_ctr_vals( b_grp_log_id NUMBER ) IS
  SELECT *
  FROM CS_COUNTER_VALUES
  WHERE COUNTER_GRP_LOG_ID = b_grp_log_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR r_ctr_vals IN c_ctr_vals( p_COUNTER_GRP_LOG_ID ) LOOP

    JTM_HOOK_UTIL_PKG.Get_Resource_Acc_List
    ( p_acc_table_name  => g_ctr_vals_acc_table_name
     ,p_pk1_name        => g_ctr_vals_pk1_name
     ,p_pk1_num_value   => r_ctr_vals.counter_value_id
     ,l_tab_resource_id => l_tab_resource_id
     ,l_tab_access_id   => l_tab_access_id
    );

    IF l_tab_resource_id.COUNT > 0 THEN
      FOR i IN l_tab_resource_id.FIRST .. l_tab_resource_id.LAST LOOP
        UPDATE_CTR_VALUE_ACC_RECORD
        (l_tab_resource_id(i)
         ,l_tab_access_id(i)
        );
      END LOOP;
    END IF;
  END LOOP;
END POST_UPDATE_COUNTER_VALUE;

/* Called before counter value Update
 * DO NOTHING
 */
PROCEDURE PRE_DELETE_COUNTER_VALUE ( x_return_status OUT NOCOPY varchar2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_DELETE_COUNTER_VALUE ;

/* Called after counter value Update
 * Mark dirty
 */
PROCEDURE POST_DELETE_COUNTER_VALUE (
   p_counter_value_id in NUMBER
   ,x_return_status OUT NOCOPY varchar2)
IS
  l_tab_resource_id    dbms_sql.Number_Table;
  l_tab_access_id      dbms_sql.Number_Table;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  JTM_HOOK_UTIL_PKG.Get_Resource_Acc_List
  ( p_acc_table_name  => g_ctr_vals_acc_table_name
   ,p_pk1_name        => g_ctr_vals_pk1_name
   ,p_pk1_num_value   => p_counter_value_id
   ,l_tab_resource_id => l_tab_resource_id
   ,l_tab_access_id   => l_tab_access_id
  );


  IF l_tab_resource_id.COUNT > 0 THEN
    FOR i IN l_tab_resource_id.FIRST .. l_tab_resource_id.LAST LOOP
      DELETE_CTR_VALUE_ACC_RECORD
      (p_counter_value_id
      ,l_tab_resource_id(i)
      );
    END LOOP;
  END IF;
END POST_DELETE_COUNTER_VALUE;


/****************************************************************
  The following procedures are for VUHK of CS_COUNTER_PROP_VALUES.
 ****************************************************************/

/* Called before counter prop value Insert.
   DO NOTHING
 */
PROCEDURE PRE_INSERT_COUNTER_PROP_VAL
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_INSERT_COUNTER_PROP_VAL ;

/* Called after counter Prop value Insert.
   Check if counter is mobilized. If so, do the insert.
 */
PROCEDURE POST_INSERT_COUNTER_PROP_VAL ( P_Api_Version_Number IN  NUMBER
                                       , P_Init_Msg_List      IN  VARCHAR2
                                       , P_Commit             IN  VARCHAR2
                                       , p_validation_level   IN  NUMBER
                                       , p_COUNTER_GRP_LOG_ID IN  NUMBER
                                       , X_Return_Status      OUT NOCOPY VARCHAR2
                                       , X_Msg_Count          OUT NOCOPY NUMBER
                                       , X_Msg_Data           OUT NOCOPY VARCHAR2 )
IS
  l_tab_resource_id    dbms_sql.Number_Table;
  l_tab_access_id      dbms_sql.Number_Table;

 CURSOR c_ctr_prop_val ( b_ctr_grp_log_id NUMBER ) IS
   SELECT CPV.COUNTER_PROP_VALUE_ID
   ,      CPV.COUNTER_VALUE_ID
   FROM CS_COUNTER_PROP_VALUES CPV
   ,    CS_COUNTER_VALUES CCS
   WHERE CCS.COUNTER_VALUE_ID = CPV.COUNTER_VALUE_ID
   AND   CCS.COUNTER_GRP_LOG_ID = b_ctr_grp_log_id;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR r_ctr_prop_vals IN c_ctr_prop_val( p_COUNTER_GRP_LOG_ID ) LOOP
    JTM_HOOK_UTIL_PKG.Get_Resource_Acc_List
    ( p_acc_table_name  => g_counters_acc_table_name
     ,p_pk1_name        => g_counters_pk1_name
     ,p_pk1_num_value   => r_ctr_prop_vals.COUNTER_VALUE_ID
     ,l_tab_resource_id => l_tab_resource_id
     ,l_tab_access_id   => l_tab_access_id
    );

    IF l_tab_resource_id.COUNT > 0 THEN
      FOR i IN l_tab_resource_id.FIRST .. l_tab_resource_id.LAST LOOP
        INSERT_CTR_PROP_VAL_ACC_RECORD
        (r_ctr_prop_vals.COUNTER_PROP_VALUE_ID
        ,l_tab_resource_id(i)
        );
      END LOOP; --l_tab_resource_id.FIRST
    END IF; -- l_tab_resource_id.COUNT
  END LOOP; -- FOR r_ctr_prop_vals
END POST_INSERT_COUNTER_PROP_VAL ;

/* Called before counter prop value Update
 * DO NOTHING
 */
PROCEDURE PRE_UPDATE_COUNTER_PROP_VAL ( x_return_status OUT NOCOPY varchar2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_UPDATE_COUNTER_PROP_VAL ;

/* Called after counter value Update
 * Mark dirty
 */
PROCEDURE POST_UPDATE_COUNTER_PROP_VAL ( P_Api_Version_Number    IN  NUMBER
                                       , P_Init_Msg_List         IN  VARCHAR2
                                       , P_Commit                IN  VARCHAR2
                                       , p_validation_level      IN  NUMBER
                                       , p_COUNTER_GRP_LOG_ID    IN  NUMBER
                                       , p_object_version_number IN  NUMBER
                                       , X_Return_Status         OUT NOCOPY VARCHAR2
                                       , X_Msg_Count             OUT NOCOPY NUMBER
                                       , X_Msg_Data              OUT NOCOPY VARCHAR2 )
IS
  l_tab_resource_id    dbms_sql.Number_Table;
  l_tab_access_id      dbms_sql.Number_Table;

 CURSOR c_ctr_prop_val ( b_ctr_grp_log_id NUMBER ) IS
   SELECT CPV.COUNTER_PROP_VALUE_ID
   ,      CPV.COUNTER_VALUE_ID
   FROM CS_COUNTER_PROP_VALUES CPV
   ,    CS_COUNTER_VALUES CCS
   WHERE CCS.COUNTER_VALUE_ID = CPV.COUNTER_VALUE_ID
   AND   CCS.COUNTER_GRP_LOG_ID = b_ctr_grp_log_id;


BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR r_ctr_prop_vals IN c_ctr_prop_val( p_COUNTER_GRP_LOG_ID ) LOOP
    JTM_HOOK_UTIL_PKG.Get_Resource_Acc_List
    ( p_acc_table_name  => g_ctr_prop_vals_acc_table_name
     ,p_pk1_name        => g_ctr_prop_vals_pk1_name
     ,p_pk1_num_value   => r_ctr_prop_vals.COUNTER_PROP_VALUE_ID
     ,l_tab_resource_id => l_tab_resource_id
     ,l_tab_access_id   => l_tab_access_id
    );

    IF l_tab_resource_id.COUNT > 0 THEN
      FOR i IN l_tab_resource_id.FIRST .. l_tab_resource_id.LAST LOOP
        UPDATE_CTR_PROP_VAL_ACC_RECORD
        (l_tab_resource_id(i)
         ,l_tab_access_id(i)
        );
      END LOOP;
    END IF;
  END LOOP;
END POST_UPDATE_COUNTER_PROP_VAL;

/* Called before counter value Update
 * DO NOTHING
 */
PROCEDURE PRE_DELETE_COUNTER_PROP_VAL ( x_return_status OUT NOCOPY varchar2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_DELETE_COUNTER_PROP_VAL ;

/* Called after counter prop value delete
 * Mark dirty
 */
PROCEDURE POST_DELETE_COUNTER_PROP_VAL (
   p_counter_prop_val_id in NUMBER
   ,x_return_status OUT NOCOPY varchar2)
IS
  l_tab_resource_id    dbms_sql.Number_Table;
  l_tab_access_id      dbms_sql.Number_Table;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  JTM_HOOK_UTIL_PKG.Get_Resource_Acc_List
    ( p_acc_table_name  => g_ctr_vals_acc_table_name
     ,p_pk1_name        => g_ctr_vals_pk1_name
     ,p_pk1_num_value   => p_counter_prop_val_id
     ,l_tab_resource_id => l_tab_resource_id
     ,l_tab_access_id   => l_tab_access_id
    );

  IF l_tab_resource_id.COUNT > 0 THEN
    FOR i IN l_tab_resource_id.FIRST .. l_tab_resource_id.LAST LOOP
      DELETE_CTR_VALUE_ACC_RECORD
      (p_counter_prop_val_id
      ,l_tab_resource_id(i)
      );
    END LOOP;
  END IF;
END POST_DELETE_COUNTER_PROP_VAL;

END CSL_CS_COUNTER_VALS_ACC_PKG;

/
