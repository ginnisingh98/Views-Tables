--------------------------------------------------------
--  DDL for Package Body CSL_CSP_REQ_LINES_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_CSP_REQ_LINES_ACC_PKG" AS
/* $Header: cslrlacb.pls 120.0 2005/05/24 17:19:34 appldev noship $ */

/*** Globals ***/
-- CSP_REQUIREMENT_HEADERS
g_acc_table_name        CONSTANT VARCHAR2(30) := 'JTM_CSP_REQ_LINES_ACC';
g_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('CSP_REQUIREMENT_LINES');
g_pk1_name              CONSTANT VARCHAR2(30) := 'REQUIREMENT_LINE_ID';

-- OE_ORDER_HEADERS_ALL
g_acc_table_name1        CONSTANT VARCHAR2(30) := 'JTM_OE_ORDER_HEADERS_ALL_ACC';
g_publication_item_name1 CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('OE_ORDER_HEADERS_ALL');
g_pk1_name1              CONSTANT VARCHAR2(30) := 'HEADER_ID';

-- OE_ORDER_LINES_ALL
g_acc_table_name2        CONSTANT VARCHAR2(30) := 'JTM_OE_ORDER_LINES_ALL_ACC';
g_publication_item_name2 CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('OE_ORDER_LINES_ALL');
g_pk1_name2              CONSTANT VARCHAR2(30) := 'LINE_ID';

g_table_name            CONSTANT VARCHAR2(30) := 'CSP_REQUIREMENT_LINES';
g_debug_level           NUMBER; -- debug level

/*** Function that checks if requirement record(s) should be replicated. Returns TRUE if it should ***/
FUNCTION Replicate_Record
  ( p_req_line_id NUMBER
  )
RETURN BOOLEAN
IS
  CURSOR c_req_resource (b_req_line_id NUMBER) IS
   SELECT RH.resource_id
   FROM   CSP_REQUIREMENT_HEADERS RH
   ,      CSP_REQUIREMENT_LINES   RL
   WHERE  RH.REQUIREMENT_HEADER_ID = RL.REQUIREMENT_HEADER_ID
   AND    RL.REQUIREMENT_LINE_ID = b_req_line_id;

/*  CURSOR c_req_task_ass( b_req_line_id NUMBER ) IS
   SELECT jta.resource_id
   FROM   jtf.jtf_task_assignments jta
   ,      csp_requirement_headers crh
   ,      csp_requirement_lines crl
   WHERE  crh.task_assignment_id = jta.task_assignment_id
   AND    jta.assignee_role = 'ASSIGNEE'
   AND    crh.requirement_header_id = crl.requirement_header_id
   AND    crl.requirement_line_id = b_req_line_id;*/

 l_resource_id NUMBER;
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_req_line_id
    , g_table_name
    , 'Entering Replicate_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  OPEN c_req_resource( p_req_line_id );
  FETCH c_req_resource INTO l_resource_id;
  IF c_req_resource%NOTFOUND THEN
--    OPEN c_req_task_ass( p_req_line_id );
--    FETCH c_req_task_ass INTO l_resource_id;
--    IF c_req_task_ass%NOTFOUND THEN
      l_resource_id := -1;
--    END IF;
--    CLOSE c_req_task_ass;
  END IF;
  CLOSE c_req_resource;

  IF l_resource_id < 0 THEN
    /*** could not find requirement record -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_req_line_id
      , g_table_name
      , 'Requirement not created for specific resource; not replicating record'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;
    RETURN FALSE;
  END IF;

  /*** is resource a mobile user? ***/
  IF NOT JTM_HOOK_UTIL_PKG.isMobileFSresource( l_resource_id ) THEN
    /*** No -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_req_line_id
      , g_table_name
      , 'Replicate_Record returned FALSE' || fnd_global.local_chr(10) ||
        'Resource_id ' || l_resource_id || ' is not a mobile user.'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    RETURN FALSE;
  END IF;


  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_req_line_id
    , g_table_name
    , 'Replicate_Record returned TRUE'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /** Record matched criteria -> return true ***/
  RETURN TRUE;
END Replicate_Record;

/*** Private procedure that replicates given requierment related data for resource ***/
PROCEDURE Insert_ACC_Record
  ( p_req_line_id        IN NUMBER
  )
IS
  CURSOR c_req_info (b_req_line_id NUMBER) IS
   SELECT RH.resource_id
   ,      OH.HEADER_ID
   ,      OL.LINE_ID
   ,      RH.DESTINATION_ORGANIZATION_ID
   ,      RL.INVENTORY_ITEM_ID
   FROM   CSP_REQUIREMENT_HEADERS RH
   ,      CSP_REQUIREMENT_LINES   RL
   ,      OE_ORDER_LINES_ALL      OL
   ,      OE_ORDER_HEADERS_ALL    OH
   WHERE  RH.REQUIREMENT_HEADER_ID = RL.REQUIREMENT_HEADER_ID
   AND    RL.REQUIREMENT_LINE_ID   = b_req_line_id
   AND    RL.ORDER_LINE_ID         = OL.LINE_ID (+)
   AND    OL.HEADER_ID             = OH.HEADER_ID (+);

  r_req_info c_req_info%ROWTYPE;

/*  CURSOR c_req_task_ass( b_req_line_id NUMBER ) IS
   SELECT jta.resource_id
   ,      oh.header_id
   ,      ol.line_id
   FROM   jtf.jtf_task_assignments jta
   ,      csp_requirement_headers crh
   ,      csp_requirement_lines crl
   ,      oe_order_headers_all oh
   ,      oe_order_lines_all ol
   WHERE  crh.task_assignment_id = jta.task_assignment_id
   AND    jta.assignee_role = 'ASSIGNEE'
   AND    crh.requirement_header_id = crl.requirement_header_id
   AND    crl.requirement_line_id = b_req_line_id
   AND    crl.order_line_id = ol.line_id(+)
   AND    ol.header_id = oh.header_id(+);*/


--  r_req_task_ass c_req_task_ass%ROWTYPE;
  l_resource_id  NUMBER;
  l_header_id    NUMBER;
  l_line_id      NUMBER;
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_req_line_id
    , g_table_name
    , 'Entering Insert_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_req_line_id
    , g_table_name
    , 'Inserting ACC record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  OPEN c_req_info( p_req_line_id );
  FETCH c_req_info INTO r_req_info;
  IF c_req_info%NOTFOUND THEN
--    OPEN c_req_task_ass( p_req_line_id );
--    FETCH c_req_task_ass INTO r_req_task_ass;
--    IF c_req_task_ass%NOTFOUND THEN
      l_resource_id := -1;
--    ELSE
--      l_resource_id := r_req_task_ass.resource_id;
--      l_header_id := r_req_task_ass.header_id;
--      l_line_id := r_req_task_ass.line_id;
--    END IF;
--    CLOSE c_req_task_ass;
  ELSE
    l_resource_id := r_req_info.resource_id;
    l_header_id := r_req_info.header_id;
    l_line_id := r_req_info.line_id;
  END IF;

  CLOSE c_req_info;

  IF l_resource_id < 0 THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_req_line_id
      , g_table_name
      , 'Requirement not created for specific resource; not replicating record'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;
  ELSE
    /*** check if requirement has an item and organization ***/
    IF r_req_info.inventory_item_id IS NOT NULL
     AND r_req_info.destination_organization_id IS NOT NULL THEN
      /*** yes -> replicate item ***/
      csl_mtl_system_items_acc_pkg.pre_insert_child(
        r_req_info.inventory_item_id
       ,r_req_info.destination_organization_id
       ,l_resource_id);
    END IF;

    JTM_HOOK_UTIL_PKG.Insert_Acc
    (  P_PUBLICATION_ITEM_NAMES => g_publication_item_name
     , P_ACC_TABLE_NAME         => g_acc_table_name
     , P_PK1_NAME               => g_pk1_name
     , P_PK1_NUM_VALUE          => p_req_line_id
     , P_RESOURCE_ID            => l_resource_id
    );

    IF (l_header_id IS NOT NULL) THEN
      -- OE_ORDER_HEADERS_ALL
      JTM_HOOK_UTIL_PKG.Insert_Acc
      (  P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
       , P_ACC_TABLE_NAME         => g_acc_table_name1
       , P_PK1_NAME               => g_pk1_name1
       , P_PK1_NUM_VALUE          => l_header_id
       , P_RESOURCE_ID            => l_resource_id
      );
      -- OE_ORDER_LINES_ALL
      JTM_HOOK_UTIL_PKG.Insert_Acc
      (  P_PUBLICATION_ITEM_NAMES => g_publication_item_name2
       , P_ACC_TABLE_NAME         => g_acc_table_name2
       , P_PK1_NAME               => g_pk1_name2
       , P_PK1_NUM_VALUE          => l_line_id
       , P_RESOURCE_ID            => l_resource_id
      );
    END IF;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_req_line_id
    , g_table_name
    , 'Leaving Insert_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Insert_ACC_Record;

/*** Private procedure that re-sends given requirement to mobile ***/
PROCEDURE Update_ACC_Record
  ( p_req_line_id        IN NUMBER
  )
IS
  CURSOR c_req_info (b_req_line_id NUMBER) IS
   SELECT RH.resource_id
   ,      OH.HEADER_ID
   ,      OL.LINE_ID
   ,      RH.DESTINATION_ORGANIZATION_ID
   ,      RL.INVENTORY_ITEM_ID
   FROM   CSP_REQUIREMENT_HEADERS RH
   ,      CSP_REQUIREMENT_LINES   RL
   ,      OE_ORDER_LINES_ALL      OL
   ,      OE_ORDER_HEADERS_ALL    OH
   WHERE  RH.REQUIREMENT_HEADER_ID = RL.REQUIREMENT_HEADER_ID
   AND    RL.REQUIREMENT_LINE_ID   = b_req_line_id
   AND    RL.ORDER_LINE_ID         = OL.LINE_ID (+)
   AND    OL.HEADER_ID             = OH.HEADER_ID (+);

  r_req_info c_req_info%ROWTYPE;

/*  CURSOR c_req_task_ass( b_req_line_id NUMBER ) IS
   SELECT jta.resource_id
   ,      oh.header_id
   ,      ol.line_id
   FROM   jtf.jtf_task_assignments jta
   ,      csp_requirement_headers crh
   ,      csp_requirement_lines crl
   ,      oe_order_headers_all oh
   ,      oe_order_lines_all ol
   WHERE  crh.task_assignment_id = jta.task_assignment_id
   AND    jta.assignee_role = 'ASSIGNEE'
   AND    crh.requirement_header_id = crl.requirement_header_id
   AND    crl.requirement_line_id = b_req_line_id
   AND    crl.order_line_id = ol.line_id(+)
   AND    ol.header_id = oh.header_id(+);*/


--  r_req_task_ass c_req_task_ass%ROWTYPE;
  l_resource_id  NUMBER;
  l_header_id    NUMBER;
  l_line_id      NUMBER;
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_req_line_id
    , g_table_name
    , 'Entering Update_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_req_line_id
    , g_table_name
    , 'Updating ACC record(s)'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  OPEN c_req_info( p_req_line_id );
  FETCH c_req_info INTO r_req_info;
  IF c_req_info%NOTFOUND THEN
--    OPEN c_req_task_ass( p_req_line_id );
--    FETCH c_req_task_ass INTO r_req_task_ass;
--    IF c_req_task_ass%NOTFOUND THEN
      l_resource_id := -1;
--    ELSE
--      l_resource_id := r_req_task_ass.resource_id;
--      l_header_id := r_req_task_ass.header_id;
--      l_line_id := r_req_task_ass.line_id;
--    END IF;
--    CLOSE c_req_task_ass;
  ELSE
    l_resource_id := r_req_info.resource_id;
    l_header_id := r_req_info.header_id;
    l_line_id := r_req_info.line_id;
  END IF;
  CLOSE c_req_info;

  IF l_resource_id < 0 THEN
    /*** could not find requirement record -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( p_req_line_id
      , g_table_name
      , 'Update ACC Record error: Could not find resource for requirement line '|| p_req_line_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
    END IF;
  ELSE
    /*** check if requirement has an item and organization ***/
    IF r_req_info.inventory_item_id IS NOT NULL
     AND r_req_info.destination_organization_id IS NOT NULL THEN
      /*** yes -> replicate item ***/
      csl_mtl_system_items_acc_pkg.pre_insert_child(
        r_req_info.inventory_item_id
       ,r_req_info.destination_organization_id
       ,l_resource_id);
    END IF;

    JTM_HOOK_UTIL_PKG.Update_Acc
     ( g_publication_item_name
      ,g_acc_table_name
      ,l_resource_id
      ,p_req_line_id
     );

    IF (l_header_id IS NOT NULL) THEN
      -- OE_ORDER_HEADERS_ALL
      JTM_HOOK_UTIL_PKG.Insert_Acc
      (  P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
       , P_ACC_TABLE_NAME         => g_acc_table_name1
       , P_PK1_NAME               => g_pk1_name1
       , P_PK1_NUM_VALUE          => l_header_id
       , P_RESOURCE_ID            => l_resource_id
      );
      -- OE_ORDER_LINES_ALL
      JTM_HOOK_UTIL_PKG.Insert_Acc
      (  P_PUBLICATION_ITEM_NAMES => g_publication_item_name2
       , P_ACC_TABLE_NAME         => g_acc_table_name2
       , P_PK1_NAME               => g_pk1_name2
       , P_PK1_NUM_VALUE          => l_line_id
       , P_RESOURCE_ID            => l_resource_id
      );
    END IF;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_req_line_id
    , g_table_name
    , 'Leaving Update_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Update_ACC_Record;

/*** Private procedure that deletes requirement for resource from acc table ***/
PROCEDURE Delete_ACC_Record
  ( p_req_line_id IN NUMBER
   ,p_resource_id        IN NUMBER
  )
IS
  CURSOR c_req_line_id (b_req_line_id NUMBER) IS
   SELECT RH.resource_id
   ,      OH.HEADER_ID
   ,      OL.LINE_ID
   FROM   CSP_REQUIREMENT_HEADERS RH
   ,      CSP_REQUIREMENT_LINES   RL
   ,      OE_ORDER_LINES_ALL      OL
   ,      OE_ORDER_HEADERS_ALL    OH
   WHERE  RH.REQUIREMENT_HEADER_ID = RL.REQUIREMENT_HEADER_ID
   AND    RL.REQUIREMENT_LINE_ID   = b_req_line_id
   AND    RL.ORDER_LINE_ID         = OL.LINE_ID (+)
   AND    OL.HEADER_ID             = OH.HEADER_ID (+);

  r_req_line_id c_req_line_id%ROWTYPE;

  l_header_id   NUMBER;
  l_line_id     NUMBER;

BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_req_line_id
    , g_table_name
    , 'Entering Delete_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  OPEN c_req_line_id( p_req_line_id );
  FETCH c_req_line_id INTO r_req_line_id;
  IF c_req_line_id%NOTFOUND THEN
    /*** could not find requirement record -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( p_req_line_id
      , g_table_name
      , 'Could not find record associated with CSP_REQUIREMENT_LINES.REQUIREMENT_LINE_ID ' || p_req_line_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
    END IF;
  ELSE
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_req_line_id
      , g_table_name
      , 'Deleting ACC record for resource_id = ' || p_resource_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    -- No delete of the requirement is possible
    JTM_HOOK_UTIL_PKG.Delete_Acc
     (  P_PUBLICATION_ITEM_NAMES => g_publication_item_name
      , P_ACC_TABLE_NAME         => g_acc_table_name
      , P_PK1_NAME               => g_pk1_name
      , P_PK1_NUM_VALUE          => p_req_line_id
      , P_RESOURCE_ID            => p_resource_id
     );

    l_header_id := r_req_line_id.HEADER_ID;
    l_line_id   := r_req_line_id.LINE_ID;
    IF (l_header_id IS NOT NULL) THEN

      IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
        jtm_message_log_pkg.Log_Msg
        ( p_resource_id
        , g_table_name
        , 'Delete Order Header acc record for user: ' || p_resource_id
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
      END IF;
      JTM_HOOK_UTIL_PKG.Delete_Acc
       (  P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
        , P_ACC_TABLE_NAME         => g_acc_table_name1
        , P_PK1_NAME               => g_pk1_name1
        , P_PK1_NUM_VALUE          => l_header_id
        , P_RESOURCE_ID            => p_resource_id
       );

      IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
        jtm_message_log_pkg.Log_Msg
        ( p_resource_id
        , g_table_name
        , 'Delete Order Line acc record for user: ' || p_resource_id
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
      END IF;
      JTM_HOOK_UTIL_PKG.Delete_Acc
       (  P_PUBLICATION_ITEM_NAMES => g_publication_item_name2
        , P_ACC_TABLE_NAME         => g_acc_table_name2
        , P_PK1_NAME               => g_pk1_name2
        , P_PK1_NUM_VALUE          => l_line_id
        , P_RESOURCE_ID            => p_resource_id
       );
    END IF;
  END IF;
  CLOSE c_req_line_id;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_req_line_id
    , g_table_name
    , 'Leaving Delete_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Delete_ACC_Record;

/*** Called before requirement Insert ***/
PROCEDURE PRE_INSERT_REQ_LINE
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_INSERT_REQ_LINE;

/*** Called after requirement Insert ***/
PROCEDURE POST_INSERT_REQ_LINE
  ( x_return_status OUT NOCOPY varchar2
  )
IS
  l_req_line_id        NUMBER;
  l_enabled_flag       VARCHAR2(30);
BEGIN
  l_enabled_flag := JTM_PROFILE_UTL_PKG.GET_ENABLE_FLAG_AT_RESP( P_APP_SHORT_NAME => 'CSL');
  IF l_enabled_flag <> 'Y' THEN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   RETURN;
  END IF;
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_req_line_id
    , g_table_name
    , 'Entering POST_INSERT hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** get location record details from public API ***/
  l_req_line_id  := CSP_REQUIREMENT_LINES_PKG.user_hook_rec.REQUIREMENT_LINE_ID;

  /*** Insert record if applicable ***/
  IF Replicate_Record(l_req_line_id) THEN
    Insert_ACC_Record(l_req_line_id);
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_req_line_id
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
    ( l_req_line_id
    , g_table_name
    , 'Caught exception in POST_INSERT hook:' || fnd_global.local_chr(10) || sqlerrm
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  fnd_msg_pub.Add_Exc_Msg('CSL_CSP_REQ_LINES_ACC_PKG','POST_INSERT_REQ_LINE',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END POST_INSERT_REQ_LINE;

/* Called before requirement Update */
PROCEDURE PRE_UPDATE_REQ_LINE
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  fnd_msg_pub.Add_Exc_Msg('CSL_CSP_REQ_LINES_ACC_PKG','PRE_UPDATE_REQ_LINE',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_UPDATE_REQ_LINE;

/* Called after requirement Update */
PROCEDURE POST_UPDATE_REQ_LINE
  ( x_return_status OUT NOCOPY varchar2
  )
IS
  l_req_line_id        NUMBER;
  l_enabled_flag       VARCHAR2(30);
BEGIN
  l_enabled_flag := JTM_PROFILE_UTL_PKG.GET_ENABLE_FLAG_AT_RESP( P_APP_SHORT_NAME => 'CSL');
  IF l_enabled_flag <> 'Y' THEN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   RETURN;
  END IF;
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_req_line_id
    , g_table_name
    , 'Entering POST_UPDATE hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** get location record details from public API ***/
  l_req_line_id  := CSP_REQUIREMENT_LINES_PKG.user_hook_rec.REQUIREMENT_LINE_ID;

  IF Replicate_Record( l_req_line_id ) THEN
    Update_ACC_Record(l_req_line_id);
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_req_line_id
    , g_table_name
    , 'Leaving POST_UPDATE hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( l_req_line_id
    , g_table_name
    , 'Caught exception in POST_UPDATE hook:' || fnd_global.local_chr(10) || sqlerrm
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  fnd_msg_pub.Add_Exc_Msg('CSL_CSP_REQ_LINES_ACC_PKG','POST_UPDATE_REQ_LINE',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END POST_UPDATE_REQ_LINE;

/* Called before req header Delete */
PROCEDURE PRE_DELETE_REQ_LINE
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_DELETE_REQ_LINE;

/* Called after req header Delete */
PROCEDURE POST_DELETE_REQ_LINE
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  fnd_msg_pub.Add_Exc_Msg('CSL_CSP_REQ_LINES_ACC_PKG','POST_DELETE_REQ_LINE',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END POST_DELETE_REQ_LINE;



/* Remove all ACC resords of a mobile user */
PROCEDURE Delete_All_ACC_Records
  ( p_resource_id in NUMBER
  , x_return_status OUT NOCOPY varchar2
  )
IS
 CURSOR c_req_resource (b_resource_id NUMBER) IS
   SELECT RL.REQUIREMENT_LINE_ID
   FROM   CSP_REQUIREMENT_HEADERS RH
   ,      CSP_REQUIREMENT_LINES   RL
   WHERE  RH.REQUIREMENT_HEADER_ID = RL.REQUIREMENT_HEADER_ID
   AND    RH.RESOURCE_ID = b_resource_id;

/*  CURSOR c_req_task_ass( b_resource_id NUMBER ) IS
   SELECT crl.requirement_line_id
   FROM   jtf.jtf_task_assignments jta
   ,      csp_requirement_headers crh
   ,      csp_requirement_lines crl
   WHERE  crh.task_assignment_id = jta.task_assignment_id
   AND    jta.assignee_role = 'ASSIGNEE'
   AND    crh.requirement_header_id = crl.requirement_header_id
   AND    jta.resource_id = b_resource_id;*/

BEGIN

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Entering Delete_All_ACC_Records procedure for user: ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*First all resource based lines */
  FOR r_req_resource IN c_req_resource( p_resource_id ) LOOP
    Delete_Acc_Record( r_req_resource.requirement_line_id, p_resource_id );
  END LOOP;

  /* Second all task assignment based lines */
--  FOR r_req_task_ass IN c_req_task_ass( p_resource_id ) LOOP
--    Delete_Acc_Record( r_req_task_ass.requirement_line_id, p_resource_id );
--  END LOOP;

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
  fnd_msg_pub.Add_Exc_Msg('CSL_CSP_REQ_LINES_ACC_PKG','Delete_All_ACC_Records',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END Delete_All_ACC_Records;

/* Full synch for a mobile user */
PROCEDURE Insert_All_ACC_Records
  ( p_resource_id in NUMBER
  , x_return_status OUT NOCOPY varchar2
  )
IS
 CURSOR c_req_resource (b_resource_id NUMBER) IS
   SELECT RL.REQUIREMENT_LINE_ID
   FROM   CSP_REQUIREMENT_HEADERS RH
   ,      CSP_REQUIREMENT_LINES   RL
   WHERE  RH.REQUIREMENT_HEADER_ID = RL.REQUIREMENT_HEADER_ID
   AND    RH.RESOURCE_ID = b_resource_id;

/*  CURSOR c_req_task_ass( b_resource_id NUMBER ) IS
   SELECT crl.requirement_line_id
   FROM   jtf.jtf_task_assignments jta
   ,      csp_requirement_headers crh
   ,      csp_requirement_lines crl
   WHERE  crh.task_assignment_id = jta.task_assignment_id
   AND    jta.assignee_role = 'ASSIGNEE'
   AND    crh.requirement_header_id = crl.requirement_header_id
   AND    jta.resource_id = b_resource_id;*/

BEGIN

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Entering Insert_All_ACC_Records procedure for user: ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*First all resource based lines*/
  FOR r_req_resource IN c_req_resource( p_resource_id ) LOOP
    IF Replicate_Record ( r_req_resource.requirement_line_id ) THEN
      Insert_Acc_Record( r_req_resource.requirement_line_id );
    END IF;
  END LOOP;

  /*Second all task assignment based lines*/
--  FOR r_req_task_ass IN c_req_task_ass( p_resource_id ) LOOP
--    IF Replicate_Record ( r_req_task_ass.requirement_line_id ) THEN
--      Insert_Acc_Record( r_req_task_ass.requirement_line_id );
--    END IF;
--  END LOOP;

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
  fnd_msg_pub.Add_Exc_Msg('CSL_CSP_REQ_LINES_ACC_PKG','Insert_All_ACC_Records',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END Insert_All_ACC_Records;

END CSL_CSP_REQ_LINES_ACC_PKG;

/
