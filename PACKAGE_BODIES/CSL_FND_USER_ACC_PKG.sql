--------------------------------------------------------
--  DDL for Package Body CSL_FND_USER_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_FND_USER_ACC_PKG" AS
/* $Header: cslusacb.pls 115.3 2002/08/21 07:49:22 rrademak ship $ */

/*** Globals ***/
g_acc_table_name        CONSTANT VARCHAR2(30) := 'JTM_FND_USER_ACC';
g_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
   JTM_HOOK_UTIL_PKG.t_publication_item_list('FND_USER');
g_table_name            CONSTANT VARCHAR2(30) := 'FND_USER';
g_pk_name               CONSTANT VARCHAR2(30) := 'USER_ID';

g_debug_level           NUMBER;  -- debug level

/*** Function that checks if user should be replicated. Returns TRUE if it should ***/
FUNCTION Replicate_Record
  ( p_user_id NUMBER
  )
RETURN BOOLEAN
IS
  CURSOR c_user (b_user_id NUMBER) IS
   SELECT *
   FROM FND_USER
   WHERE user_id = b_user_id;
  r_user c_user%ROWTYPE;

BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_user_id
    , g_table_name
    , 'Entering Replicate_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  OPEN c_user( p_user_id );
  FETCH c_user INTO r_user;
  IF c_user%NOTFOUND THEN
    /*** could not find user record -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( p_user_id
      , g_table_name
      , 'Replicate_Record error: Could not find user_id ' || p_user_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    CLOSE c_user;
    RETURN FALSE;
  END IF;
  CLOSE c_user;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_user_id
    , g_table_name
    , 'Replicate_Record returned TRUE'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /** Record matched criteria -> return true ***/
  RETURN TRUE;
END Replicate_Record;


/*** Private procedure that replicates given user related data for resource ***/
PROCEDURE Insert_ACC_Record
  ( p_user_id             IN NUMBER
   ,p_resource_id         IN NUMBER
  )
IS
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_user_id
    , g_table_name
    , 'Entering Insert_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_user_id
    , g_table_name
    , 'Inserting ACC record for resource_id = ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /*** Insert user ACC record ***/
  JTM_HOOK_UTIL_PKG.Insert_Acc
   ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
    ,P_ACC_TABLE_NAME         => g_acc_table_name
    ,P_PK1_NAME               => g_pk_name
    ,P_PK1_NUM_VALUE          => p_user_id
    ,P_RESOURCE_ID            => p_resource_id
   );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_user_id
    , g_table_name
    , 'Leaving Insert_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Insert_ACC_Record;

/*** Private procedure that re-sends given user to mobile ***/
PROCEDURE Update_ACC_Record
  ( p_user_id            IN NUMBER
   ,p_resource_id        IN NUMBER
   ,p_acc_id             IN NUMBER
  )
IS
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_user_id
    , g_table_name
    , 'Entering Update_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_user_id
    , g_table_name
    , 'Updating ACC record for resource_id = ' || p_resource_id || fnd_global.local_chr(10) || 'access_id = ' || p_acc_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /*** Update user ACC record ***/
  JTM_HOOK_UTIL_PKG.Update_Acc
   ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
    ,P_ACC_TABLE_NAME         => g_acc_table_name
    ,P_RESOURCE_ID            => p_resource_id
    ,P_ACCESS_ID              => p_acc_id
   );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_user_id
    , g_table_name
    , 'Leaving Update_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Update_ACC_Record;

/*** Private procedure that deletes user for resource from acc table ***/
PROCEDURE Delete_ACC_Record
  ( p_user_id     IN NUMBER
   ,p_resource_id         IN NUMBER
  )
IS
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_user_id
    , g_table_name
    , 'Entering Delete_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_user_id
    , g_table_name
    , 'Deleting ACC record for resource_id = ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /*** Delete user ACC record ***/
  JTM_HOOK_UTIL_PKG.Delete_Acc
   ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
    ,P_ACC_TABLE_NAME         => g_acc_table_name
    ,P_PK1_NAME               => g_pk_name
    ,P_PK1_NUM_VALUE          => p_user_id
    ,P_RESOURCE_ID            => p_resource_id
   );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_user_id
    , g_table_name
    , 'Leaving Delete_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Delete_ACC_Record;

/***
  Public function that gets called when a user needs to be inserted into ACC table.
***/
PROCEDURE Insert_User
  ( p_user_id     IN NUMBER
   ,p_resource_id IN NUMBER
  )
IS
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_user_id
    , g_table_name
    , 'Entering Insert_User procedure'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** does record match criteria? ***/
  IF Replicate_Record( p_user_id ) THEN
    /*** yes -> insert user acc record ***/
    Insert_ACC_Record
    ( p_user_id
     ,p_resource_id
    );

  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_user_id
    , g_table_name
    , 'Leaving Insert_User procedure'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

END Insert_User;

/***
  Public procedure that gets called when a user needs to be updated from ACC table.
***/
PROCEDURE Update_User
  ( p_user_id     IN NUMBER
   ,p_resource_id IN NUMBER
  )
IS
  l_acc_id           NUMBER;
  l_success          BOOLEAN;
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_user_id
    , g_table_name
    , 'Entering Update_User'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  l_acc_id := JTM_HOOK_UTIL_PKG.Get_Acc_Id(
                   P_ACC_TABLE_NAME => g_acc_table_name
                  ,P_PK1_NAME       => g_pk_name
                  ,P_PK1_NUM_VALUE  => p_user_id
                  ,P_RESOURCE_ID    => p_resource_id);

  /*** is record already in ACC table? ***/
  IF l_acc_id <> -1 THEN
    /*** no -> does record match criteria? ***/
    IF Replicate_Record( p_user_id ) THEN
      /*** yes -> update user acc record ***/
      Update_ACC_Record
      ( p_user_id
       ,p_resource_id
       ,l_acc_id
      );

    END IF;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_user_id
    , g_table_name
    , 'Leaving Update_User'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Update_User;

/***
  Public procedure that gets called when a user needs to be deleted from ACC table.
***/
PROCEDURE Delete_User
  ( p_user_id     IN NUMBER
   ,p_resource_id IN NUMBER
  )
IS
  l_acc_id           NUMBER;
  l_success          BOOLEAN;
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_user_id
    , g_table_name
    , 'Entering Delete_User'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  l_acc_id := JTM_HOOK_UTIL_PKG.Get_Acc_Id(
                   P_ACC_TABLE_NAME => g_acc_table_name
                  ,P_PK1_NAME       => g_pk_name
                  ,P_PK1_NUM_VALUE  => p_user_id
                  ,P_RESOURCE_ID    => p_resource_id);

  /*** is record already in ACC table? ***/
  IF l_acc_id <> -1 THEN
    /*** yes -> delete user acc record ***/
    Delete_ACC_Record
    ( p_user_id
     ,p_resource_id
    );

  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_user_id
    , g_table_name
    , 'Leaving Delete_User'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Delete_User;

END CSL_FND_USER_ACC_PKG;

/
