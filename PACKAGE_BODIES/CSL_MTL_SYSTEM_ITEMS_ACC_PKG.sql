--------------------------------------------------------
--  DDL for Package Body CSL_MTL_SYSTEM_ITEMS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_MTL_SYSTEM_ITEMS_ACC_PKG" AS
/* $Header: cslsiacb.pls 120.0 2005/05/24 18:40:25 appldev noship $ */

/*** Globals ***/
g_acc_table_name        CONSTANT VARCHAR2(30) := 'JTM_MTL_SYSTEM_ITEMS_ACC';
g_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('MTL_SYSTEM_ITEMS_VL');

--Bug 3746689
g_explab_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('CSL_MTL_EXPENSE_LABOR_ITEM');

g_table_name            CONSTANT VARCHAR2(30) := 'MTL_SYSTEM_ITEMS_B';
g_pk1_name              CONSTANT VARCHAR2(30) := 'INVENTORY_ITEM_ID';
g_pk2_name              CONSTANT VARCHAR2(30) := 'ORGANIZATION_ID';
g_debug_level           NUMBER; -- debug level

/*** Function that checks if user should be replicated. Returns TRUE if
it should ***/
FUNCTION Replicate_Record
  ( p_organization_id NUMBER
  )
RETURN BOOLEAN
IS

BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_organization_id
    , g_table_name
    , 'Entering Replicate_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_organization_id
    , g_table_name
    , 'Replicate_Record returned TRUE'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /** Record matched criteria -> return true ***/
  RETURN TRUE;
END Replicate_Record;


  /*
    Private procedure that inserts/updates Expense/Labor items for an org
    and calls markdirty for all inserted records. Bug 3724165
  */
  PROCEDURE INSERT_ACC_REC_MARKDIRTY_EXP( p_organization_id IN NUMBER
                                          , p_resource_id     IN NUMBER
                                          , p_old_org_id IN NUMBER)
  IS

   l_tab_access_id   ASG_DOWNLOAD.ACCESS_LIST;
   l_tab_resource_id ASG_DOWNLOAD.USER_LIST;

   TYPE item_Tab  IS TABLE OF mtl_system_items_b.inventory_item_id%TYPE INDEX BY BINARY_INTEGER;
   TYPE org_Tab   IS TABLE OF mtl_system_items_b.organization_id%TYPE INDEX BY BINARY_INTEGER;
   items          item_Tab;
   organizations  org_Tab;

   l_dummy        BOOLEAN;
   l_stmt         VARCHAR2 (4000);

  BEGIN

    IF ( p_organization_id <> p_old_org_id ) THEN
      UPDATE jtm_mtl_system_items_acc
      SET counter = counter + 1
       ,   last_update_date = SYSDATE
       ,   last_updated_by = 1
       WHERE resource_id = p_resource_id
      AND (inventory_item_id, organization_id)
      IN (SELECT inventory_item_id, organization_id
          FROM mtl_system_items_b msi, cs_billing_type_categories cbtc
          WHERE organization_id = p_organization_id
          and msi.material_billable_flag = cbtc.billing_type (+)
          AND cbtc.billing_category IN ('E','L'));
    END IF;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
       jtm_message_log_pkg.Log_Msg
       ( p_organization_id
       , g_table_name
       , 'Entering INSERT_ACC_REC_MARKDIRTY_EXP'
       , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
       );
    END IF;

    /*Block insert every item from given org not yet in acc table*/
    SELECT jtm_acc_table_s.NEXTVAL, inventory_item_id, organization_id,
           p_resource_id
    BULK COLLECT INTO
           l_tab_access_id, items, organizations, l_tab_resource_id
    FROM mtl_system_items_b msi, cs_billing_type_categories cbtc
    WHERE ( inventory_item_id, organization_id ) NOT IN (
          SELECT inventory_item_id, organization_id
          FROM jtm_mtl_system_items_acc
          WHERE resource_id = p_resource_id )
    AND msi.material_billable_flag = cbtc.billing_type (+)
    AND cbtc.billing_category IN ('E', 'L')
    AND organization_id = p_organization_id;

    IF l_tab_access_id.COUNT > 0 THEN
     /*** 1 or more acc rows retrieved -> push to resource ***/
     IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( p_organization_id
         , g_table_name
         , 'Pushing ' || l_tab_access_id.COUNT ||
           ' inserted record(s) to resource: '||p_resource_id
         , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
        );
     END IF;

     FORALL i IN l_tab_access_id.FIRST..l_tab_access_id.LAST
       INSERT INTO jtm_mtl_system_items_acc(
         access_id, last_update_date, last_updated_by, creation_date,
         created_by , counter, resource_id, inventory_item_id, organization_id)
       VALUES (
   	 l_tab_access_id(i), SYSDATE, 1, SYSDATE, 1, 1, p_resource_id,
         items(i), organizations(i));

      IF l_tab_access_id.COUNT > 0 THEN -- For Expense/Labor Items
   	   l_dummy := asg_download.markdirty(
   		   P_PUB_ITEM     => g_explab_publication_item_name(1)
   		 , P_ACCESSLIST   => l_tab_access_id
   		 , P_RESOURCELIST => l_tab_resource_id
   		 , P_DML_TYPE     => 'I'
   		 , P_TIMESTAMP    => SYSDATE
   		 );
       END IF;

    END IF;  -- End of Insert of Expense and Labor items

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
       jtm_message_log_pkg.Log_Msg
       ( p_organization_id
       , g_table_name
       , 'Leaving INSERT_ACC_REC_MARKDIRTY_EXP'
       , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
       );
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      jtm_message_log_pkg.Log_Msg
        ( p_organization_id
        , g_table_name
        , 'INSERT_ACC_REC_MARKDIRTY_EXP'||fnd_global.local_chr(10)||
          'Error: '||sqlerrm
        , JTM_HOOK_UTIL_PKG.g_debug_level_error);
      RAISE;
  END INSERT_ACC_REC_MARKDIRTY_EXP;




/*** Private procedure that inserts given item related data for resource ***/
PROCEDURE Insert_ACC_Record
  ( p_inventory_item_id  IN NUMBER
  , p_organization_id    IN NUMBER
  , p_resource_id        IN NUMBER
  )
IS

 --Bug 3908277 - Static Query converted into Cursor.
 CURSOR c_billCat(b_inventory_item_id NUMBER, b_organization_id NUMBER)
 IS
  SELECT billing_category
  FROM MTL_SYSTEM_ITEMS_B msi, CS_BILLING_TYPE_CATEGORIES cbtc
  WHERE msi.material_billable_flag = cbtc.billing_type (+)
  AND   inventory_item_id = p_inventory_item_id
  AND   organization_id = p_organization_id;

 --Added by UTEKUMAL on 16-Feb-2004 to segregate the Item by Billing Category
--Bug 3746689
 l_billCat          CS_BILLING_TYPE_CATEGORIES.BILLING_CATEGORY%TYPE;

BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  THEN
    jtm_message_log_pkg.Log_Msg
    ( p_organization_id
    , g_table_name
    , 'Entering Insert_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
  THEN
    jtm_message_log_pkg.Log_Msg
    ( p_organization_id
    , g_table_name
    , 'Inserting ACC record for resource_id = ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

 --Added by UTEKUMAL on 16-Feb-2004 to segregate the Item by Billing Category
 --Bug 3908277 - Static Query converted into Cursor.
  OPEN c_billCat(p_inventory_item_id, p_organization_id);
  FETCH c_billCat into l_billCat;
  CLOSE c_billCat;

  /*** Insert item ACC record ***/
  IF l_billCat = 'E' OR l_billCat = 'L' THEN
      JTM_HOOK_UTIL_PKG.Insert_Acc
       ( P_PUBLICATION_ITEM_NAMES => g_explab_publication_item_name
        , P_ACC_TABLE_NAME         => g_acc_table_name
        , P_RESOURCE_ID            => p_resource_id
        , P_PK1_NAME               => g_pk1_name
        , P_PK1_NUM_VALUE          => p_inventory_item_id
        , P_PK2_NAME               => g_pk2_name
        , P_PK2_NUM_VALUE          => p_organization_id
        );
  ELSE
      JTM_HOOK_UTIL_PKG.Insert_Acc
       ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
        , P_ACC_TABLE_NAME         => g_acc_table_name
        , P_RESOURCE_ID            => p_resource_id
        , P_PK1_NAME               => g_pk1_name
        , P_PK1_NUM_VALUE          => p_inventory_item_id
        , P_PK2_NAME               => g_pk2_name
        , P_PK2_NUM_VALUE          => p_organization_id
        );
  END IF;

  CSL_MTL_SEC_LOCATORS_ACC_PKG.Insert_Secondary_Locators
    ( p_inventory_item_id     => p_inventory_item_id
    , p_organization_id       => p_organization_id
    , p_resource_id           => p_resource_id
    );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  THEN
    jtm_message_log_pkg.Log_Msg
      ( p_organization_id
      , g_table_name
      , 'Leaving Insert_ACC_Record'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
      );
  END IF;
END Insert_ACC_Record;

/*** Private procedure that deletes given item related data for resource ***/
PROCEDURE Delete_ACC_Record
  ( p_inventory_item_id  IN NUMBER
  , p_organization_id    IN NUMBER
  , p_resource_id        IN NUMBER
  )
IS

 --Bug 3908277 - Static Query converted into Cursor.
 CURSOR c_billCat(b_inventory_item_id NUMBER, b_organization_id NUMBER)
 IS
  SELECT billing_category
  FROM MTL_SYSTEM_ITEMS_B msi, CS_BILLING_TYPE_CATEGORIES cbtc
  WHERE msi.material_billable_flag = cbtc.billing_type (+)
  AND   inventory_item_id = p_inventory_item_id
  AND   organization_id = p_organization_id;

 --Bug 3746689
 l_billCat          CS_BILLING_TYPE_CATEGORIES.BILLING_CATEGORY%TYPE;

BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  THEN
    jtm_message_log_pkg.Log_Msg
    ( p_organization_id
    , g_table_name
    , 'Entering Delete_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
  THEN
    jtm_message_log_pkg.Log_Msg
    ( p_organization_id
    , g_table_name
    , 'Deleting ACC record for resource_id = ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
    );
  END IF;

 --Added by UTEKUMAL on 16-Feb-2004 to segregate the Item by Billing Category
 --Bug 3908277 - Static Query converted into Cursor.
  OPEN c_billCat(p_inventory_item_id, p_organization_id);
  FETCH c_billCat into l_billCat;
  CLOSE c_billCat;

    /*** Delete item ACC record ***/
  IF l_billCat = 'E' OR l_billCat = 'L' THEN
         JTM_HOOK_UTIL_PKG.Delete_Acc
       ( P_PUBLICATION_ITEM_NAMES => g_explab_publication_item_name
       , P_ACC_TABLE_NAME         => g_acc_table_name
       , P_RESOURCE_ID            => p_resource_id
       , P_PK1_NAME               => g_pk1_name
       , P_PK1_NUM_VALUE          => p_inventory_item_id
       , P_PK2_NAME               => g_pk2_name
       , P_PK2_NUM_VALUE          => p_organization_id
       );
  ELSE
         JTM_HOOK_UTIL_PKG.Delete_Acc
       ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
       , P_ACC_TABLE_NAME         => g_acc_table_name
       , P_RESOURCE_ID            => p_resource_id
       , P_PK1_NAME               => g_pk1_name
       , P_PK1_NUM_VALUE          => p_inventory_item_id
       , P_PK2_NAME               => g_pk2_name
       , P_PK2_NUM_VALUE          => p_organization_id
       );
  END IF;


  CSL_MTL_SEC_LOCATORS_ACC_PKG.Delete_Secondary_Locators
    ( p_inventory_item_id     => p_inventory_item_id
    , p_organization_id       => p_organization_id
    , p_resource_id           => p_resource_id
    );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  THEN
    jtm_message_log_pkg.Log_Msg
      ( p_organization_id
      , g_table_name
      , 'Leaving Delete_ACC_Record'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
      );
  END IF;
END Delete_ACC_Record;

/***
  Public function that gets called when a system item needs to be inserted into ACC table.
***/
PROCEDURE Pre_Insert_Child
  ( p_inventory_item_id  IN NUMBER
  , p_organization_id    IN NUMBER
  , p_resource_id        IN NUMBER
  )
IS
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  THEN
    jtm_message_log_pkg.Log_Msg
    ( p_organization_id
    , g_table_name
    , 'Entering Pre_Insert_Child'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
  END IF;

  /*** no -> does record match criteria? ***/
  IF Replicate_Record( p_organization_id )
  THEN
    /*** yes -> insert system item in acc record ***/
    Insert_ACC_Record
    ( p_inventory_item_id
    , p_organization_id
    , p_resource_id
    );
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  THEN
    jtm_message_log_pkg.Log_Msg
    ( p_organization_id
    , g_table_name
    , 'Leaving Pre_Insert_Child'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
  END IF;

END Pre_Insert_Child;

/***
     Public function that gets called when a system item needs
     to be deleted from ACC table.
***/
PROCEDURE Post_Delete_Child
  ( p_inventory_item_id  IN NUMBER
  , p_organization_id    IN NUMBER
  , p_resource_id        IN NUMBER
  )
IS
  l_acc_id           NUMBER;
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  THEN
    jtm_message_log_pkg.Log_Msg
    ( p_organization_id
    , g_table_name
    , 'Entering Post_Delete_Child'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
  END IF;

   l_acc_id := JTM_HOOK_UTIL_PKG.Get_Acc_Id
                 ( P_ACC_TABLE_NAME         => g_acc_table_name
                 , P_RESOURCE_ID            => p_resource_id
                 , P_PK1_NAME               => g_pk1_name
                 , P_PK1_NUM_VALUE          => p_inventory_item_id
                 , P_PK2_NAME               => g_pk2_name
                 , P_PK2_NUM_VALUE          => p_organization_id
                 );

  /*** is record already in ACC table? ***/
  IF l_acc_id <> -1
  THEN
    Delete_ACC_Record
    ( p_inventory_item_id
    , p_organization_id
    , p_resource_id
    );
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  THEN
    jtm_message_log_pkg.Log_Msg
    ( p_organization_id
    , g_table_name
    , 'Leaving Post_Delete_Child'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
  END IF;

END Post_Delete_Child;

/*Private procedure that retrieves inventory org and category profiles */
PROCEDURE GET_PROFILES( p_user_id           IN  NUMBER
                      , p_responsibility_id IN  NUMBER
                      , p_application_id    IN  NUMBER
                      , x_organization_id   OUT NOCOPY NUMBER
                      , x_category_set_id   OUT NOCOPY NUMBER
                      , x_category_id       OUT NOCOPY NUMBER )
IS
BEGIN
  /*Set the environment*/
  FND_GLOBAL.APPS_INITIALIZE( USER_ID      => p_user_id
                            , RESP_ID      => p_responsibility_id
                            , RESP_APPL_ID => p_application_id
                            );
  /*Get the profile values*/
  -- Bug 3724123
  x_organization_id := TO_NUMBER( fnd_profile.value('CS_INV_VALIDATION_ORG') );
  x_category_set_id := TO_NUMBER( fnd_profile.value('CSL_ITEM_CATEGORY_SET_FILTER') );
  x_category_id     := TO_NUMBER( fnd_profile.value('CSL_ITEM_CATEGORY_FILTER') );
END GET_PROFILES;

/*Private procedure that inserts a record into CSL_RESOURCE_INVENTORY_ORG*/
PROCEDURE INSERT_RESOURCE_PROFILE_REC( p_resource_id     IN NUMBER
                                     , p_organization_id IN NUMBER
                                     , p_category_set_id IN NUMBER
                                     , p_category_id     IN NUMBER )
IS
BEGIN
  INSERT INTO CSL_RESOURCE_INVENTORY_ORG ( RESOURCE_ID, ORGANIZATION_ID, LAST_UPDATE_DATE
    , LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, CATEGORY_SET_ID, CATEGORY_ID )
  VALUES ( p_resource_id, p_organization_id
         , SYSDATE, 1, SYSDATE, 1, p_category_set_id, p_category_id );
END INSERT_RESOURCE_PROFILE_REC;

/*Private procedure that updates a record in CSL_RESOURCE_INVENTORY_ORG*/
PROCEDURE UPDATE_RESOURCE_PROFILE_REC( p_resource_id     IN NUMBER
                                     , p_organization_id IN NUMBER
                                     , p_category_set_id IN NUMBER
                                     , p_category_id     IN NUMBER )
IS
BEGIN
  UPDATE CSL_RESOURCE_INVENTORY_ORG
  SET ORGANIZATION_ID = p_organization_id
  ,   CATEGORY_SET_ID = p_category_set_id
  ,   CATEGORY_ID     = p_category_id
  ,   LAST_UPDATE_DATE = SYSDATE
  WHERE RESOURCE_ID = p_resource_id;
END UPDATE_RESOURCE_PROFILE_REC;

/*Private procedure that deletes a record from CSL_RESOURCE_INVENTORY_ORG*/
PROCEDURE DELETE_RESOURCE_PROFILE_REC( p_resource_id IN NUMBER )
IS
BEGIN
  DELETE CSL_RESOURCE_INVENTORY_ORG
  WHERE RESOURCE_ID = p_resource_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
  WHEN OTHERS THEN
    RAISE;
END DELETE_RESOURCE_PROFILE_REC;

/*Delete all acc records for resource without markdirty */
PROCEDURE DELETE_ALL_ACC_RECORDS( p_resource_id IN NUMBER
                                , x_return_status OUT NOCOPY VARCHAR2 )
IS
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Entering DELETE_ALL_ACC_RECORDS'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
  END IF;

  /*Do the actual delete*/
  DELETE JTM_MTL_SYSTEM_ITEMS_ACC
  WHERE  RESOURCE_ID = p_resource_id;

  DELETE CSL_MTL_SECONDARY_LOCATORS_ACC
  WHERE  RESOURCE_ID = p_resource_id;

  /*Reduce rollback segments*/
  COMMIT;

  /*Delete the resource from CSL_RESOURCE_INVENTORY_ORG*/
  DELETE_RESOURCE_PROFILE_REC( p_resource_id => p_resource_id );

  /*Reduce rollback segments*/
  COMMIT;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Leaving DELETE_ALL_ACC_RECORDS'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
  END IF;
EXCEPTION
 WHEN OTHERS THEN
  jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'DELETE_ALL_ACC_RECORDS'||fnd_global.local_chr(10)||
      'Error: '||sqlerrm
    , JTM_HOOK_UTIL_PKG.g_debug_level_error);
  x_return_status := FND_API.G_RET_STS_ERROR;
  /*Reduce rollback segments*/
  ROLLBACK;
  RAISE;
END DELETE_ALL_ACC_RECORDS;

PROCEDURE INSERT_ALL_ACC_RECORDS( p_resource_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2 )
IS
  CURSOR c_mobile_resp ( b_resource_id NUMBER ) IS
    SELECT usr.user_id
    ,      usrresp.responsibility_id
    ,      usrresp.responsibility_application_id
    FROM  asg_pub                pub
    ,     asg_pub_responsibility pubresp
    ,     fnd_user_resp_groups   usrresp
    ,     fnd_user               usr
    ,     jtf_rs_resource_extns  res
    ,     asg_user               au
    WHERE res.resource_id = b_resource_id
    AND   pub.name = 'SERVICEL'
    AND   pub.enabled='Y'
    AND   pub.status='Y'
    AND   pub.pub_id = pubresp.pub_id
    AND   pubresp.responsibility_id = usrresp.responsibility_id
    AND   TRUNC(sysdate) BETWEEN TRUNC(NVL(usrresp.start_date,sysdate))
                             AND TRUNC(NVL(usrresp.end_date,sysdate))
    AND   usrresp.user_id = usr.user_id
    AND   TRUNC(sysdate) BETWEEN TRUNC(NVL(usr.start_date,sysdate))
                             AND TRUNC(NVL(usr.end_date,sysdate))
    AND   usr.user_id = res.user_id
    AND   TRUNC(sysdate) BETWEEN TRUNC(NVL(res.start_date_active,sysdate))
                             AND TRUNC(NVL(res.end_date_active,sysdate));
  r_mobile_resp c_mobile_resp%ROWTYPE;

  l_profile_org_id          NUMBER;
  l_profile_category_id     NUMBER;
  l_profile_category_set_id NUMBER;

  l_stmt	VARCHAR2(4000);
  l_stmt1	VARCHAR2(4000);

BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Entering INSERT_ALL_ACC_RECORDS'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
  END IF;

  /*** get user_id and mobile responsibility_id ***/
  OPEN c_mobile_resp( p_resource_id );
  FETCH c_mobile_resp INTO r_mobile_resp;
  IF c_mobile_resp%NOTFOUND THEN
    /*** no active mobile responsibility found -> log error ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( p_resource_id
      , g_table_name
      , 'Resource_id = ' || p_resource_id || ' does not have any active mobile responsibilities'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE
    /*** Found active mobile responsibility for user ***/

    /*Get inventory org and category profiles */
    GET_PROFILES( p_user_id           => r_mobile_resp.user_id
                , p_responsibility_id => r_mobile_resp.responsibility_id
                , p_application_id    => r_mobile_resp.responsibility_application_id
                , x_organization_id   => l_profile_org_id
                , x_category_set_id   => l_profile_category_set_id
                , x_category_id       => l_profile_category_id );

    /*Bug 3929942 - Removed the code to update existing SIs in the ACC table,
    as this proc is called only during user creation, and during user creation
    the ACC table will be empty for the mobile resource being created*/



    --Bug 3724165 - Get only Material Items when applying Category Set Filter.

    /*Block insert every item from given org not yet in acc table - Material*/

    --Bug 3929942 - Added Hints and use bind variables
    l_stmt := 'INSERT INTO JTM_MTL_SYSTEM_ITEMS_ACC (';
    l_stmt := l_stmt || '  access_id, last_update_date, last_updated_by, ';
    l_stmt := l_stmt || '  creation_date, created_by, counter, resource_id, ';
    l_stmt := l_stmt || '  inventory_item_id, organization_id )';
    l_stmt := l_stmt || ' SELECT /*+ index (msi MTL_SYSTEM_ITEMS_B_N4)*/ ';
    l_stmt := l_stmt || '  jtm_acc_table_s.NEXTVAL, SYSDATE, 1, ';
    l_stmt := l_stmt || '  SYSDATE, 1, 1,'||p_resource_id ||', ';
    l_stmt := l_stmt || '  inventory_item_id, organization_id ';
    l_stmt := l_stmt || ' FROM mtl_system_items_b msi,  cs_billing_type_categories cbtc';
    l_stmt := l_stmt || '    WHERE organization_id = :1 ';
    l_stmt := l_stmt || '    AND msi.material_billable_flag = cbtc.billing_type (+) ';
    l_stmt := l_stmt || '    AND NVL(cbtc.billing_category, ''M'') = ''M''';
    l_stmt := l_stmt || '    AND ( INVENTORY_ITEM_ID, ORGANIZATION_ID ) ';
    l_stmt := l_stmt || '    NOT IN (';
    l_stmt := l_stmt || '      SELECT /*+ index (acc JTM_MTL_SYSTEM_ITEMS_ACC_U1)*/ INVENTORY_ITEM_ID, ORGANIZATION_ID';
    l_stmt := l_stmt || '      FROM JTM_MTL_SYSTEM_ITEMS_ACC acc ';
    l_stmt := l_stmt || '       WHERE RESOURCE_ID = :2 )';

    IF (l_profile_category_id IS NOT NULL) THEN
    	l_stmt1 := 'itemcat.category_id = ' || l_profile_category_id;
    END IF;

    IF (l_profile_category_set_id IS NOT NULL) THEN
      IF (l_stmt1 IS NOT NULL) THEN
        l_stmt1 := l_stmt1 || 'AND itemcat.category_set_id = '
                           || l_profile_category_set_id;
      ELSE
        l_stmt1 := 'itemcat.category_set_id = ' || l_profile_category_set_id;
      END IF;
    END IF;

    IF (l_stmt1 IS NOT NULL) THEN
        l_stmt :=   l_stmt || '  AND ';
    	l_stmt :=   l_stmt || '     inventory_item_id IN';
    	l_stmt :=   l_stmt || '     (SELECT inventory_item_id';
    	l_stmt :=   l_stmt || '      FROM   mtl_item_categories itemcat';
    	l_stmt :=   l_stmt || '      WHERE ' || l_stmt1;
    	l_stmt :=   l_stmt || '      AND    itemcat.organization_id = :3 )';
    END IF;

    IF (l_stmt1 IS NOT NULL) THEN
      EXECUTE IMMEDIATE l_stmt USING l_profile_org_id, p_resource_id, l_profile_org_id;
    ELSE
      EXECUTE IMMEDIATE l_stmt USING l_profile_org_id, p_resource_id;
    END IF;


    --Bug 3724165 - Get Expense and Labor Items without applying Category
    -- Set Filter.

    /*Block insert every item from given org not yet in acc table - Expense and Labor*/

    --Bug 3929942 - Added Hints
    INSERT INTO JTM_MTL_SYSTEM_ITEMS_ACC(access_id, last_update_date, last_updated_by,
      creation_date, created_by, counter, resource_id,inventory_item_id, organization_id )
    SELECT /*+ index (msi MTL_SYSTEM_ITEMS_B_N4)*/ jtm_acc_table_s.NEXTVAL, SYSDATE, 1,
      SYSDATE, 1, 1, p_resource_id, inventory_item_id, organization_id
    FROM mtl_system_items_b msi,  cs_billing_type_categories cbtc
    WHERE organization_id = l_profile_org_id
    AND msi.material_billable_flag = cbtc.billing_type (+)
    AND cbtc.billing_category IN ('E','L')
    AND ( inventory_item_id, organization_id )
    NOT IN (
      SELECT /*+ index (acc JTM_MTL_SYSTEM_ITEMS_ACC_U1)*/ inventory_item_id,
          organization_id
        FROM jtm_mtl_system_items_acc acc
        WHERE resource_id = p_resource_id );

    /*REDUCE ROLLBACK SEGMENTS*/
    COMMIT;
    CSL_MTL_SEC_LOCATORS_ACC_PKG.POPULATE_SEC_LOCATORS_ACC;
    COMMIT;

    /*Delete any old record for resource from CSL_RESOURCE_INVENTORY_ORG*/
    DELETE_RESOURCE_PROFILE_REC( p_resource_id => p_resource_id );
    /*Insert resource org record*/
    INSERT_RESOURCE_PROFILE_REC( p_resource_id     => p_resource_id
                               , p_organization_id => l_profile_org_id
                               , p_category_set_id => l_profile_category_set_id
                               , p_category_id     => l_profile_category_id );
    COMMIT;
  END IF;
  CLOSE c_mobile_resp;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Leaving INSERT_ALL_ACC_RECORDS'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
 WHEN OTHERS THEN
  ROLLBACK;
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
      ( p_resource_id
      , g_table_name
      , 'INSERT_ALL_ACC_RECORDS'||fnd_global.local_chr(10)||
        'Error: '||sqlerrm
      , JTM_HOOK_UTIL_PKG.g_debug_level_error);
  END IF;
  x_return_status := FND_API.G_RET_STS_ERROR;
  RAISE;
END INSERT_ALL_ACC_RECORDS;

/*
  Private procedure that inserts (new) system items for an org/category
  and calls markdirty for all inserted records.
*/
PROCEDURE INSERT_ACC_REC_MARKDIRTY( p_organization_id IN NUMBER
                                  , p_category_set_id IN NUMBER
                                  , p_category_id     IN NUMBER
                                  , p_resource_id     IN NUMBER
			          , p_last_run_date   IN DATE
				  , p_changed         IN VARCHAR2
                                  , p_old_org_id  IN NUMBER )
IS

 --Bug 3724165 - To take care of this bug, this procedure will only take
 --care of Material Items. Expense and Labor items will be taken care of
 --by the procedure INSERT_ACC_REC_MARKDIRTY_EXP
 l_tab_access_id   ASG_DOWNLOAD.ACCESS_LIST;
 l_tab_resource_id ASG_DOWNLOAD.USER_LIST;

 TYPE item_Tab  IS TABLE OF mtl_system_items_b.inventory_item_id%TYPE INDEX BY BINARY_INTEGER;
 TYPE org_Tab   IS TABLE OF mtl_system_items_b.organization_id%TYPE INDEX BY BINARY_INTEGER;

 items          item_Tab;
 organizations  org_Tab;

 l_dummy        BOOLEAN;

 --Bug 3746689
 TYPE billCat_Tab IS TABLE OF cs_billing_type_categories.billing_category%TYPE INDEX BY BINARY_INTEGER;
 billCat	billCat_Tab;

 accessId_Exp_Lab_Tab   ASG_DOWNLOAD.ACCESS_LIST;
 accessId_Mat_Tab   ASG_DOWNLOAD.ACCESS_LIST;

 resourceId_Exp_Lab_Tab ASG_DOWNLOAD.USER_LIST;
 resourceId_Mat_Tab ASG_DOWNLOAD.USER_LIST;

 el_ctr		NUMBER;
 m_ctr		NUMBER;

 l_stmt		VARCHAR2(4000);
 l_stmt1	VARCHAR2(4000);

    --Bug 3929942 - Static SQL converted to cursors so as to be able to use LIMIT clause.
    -- Both category and cat set are null
    CURSOR c_items (b_resource_id NUMBER, b_organization_id NUMBER,
      b_changed VARCHAR2, b_last_run_date DATE)
    IS
      SELECT JTM_ACC_TABLE_S.NEXTVAL, INVENTORY_ITEM_ID, ORGANIZATION_ID, p_resource_id, billing_category
      BULK COLLECT INTO l_tab_access_id, items, organizations, l_tab_resource_id, billCat
      FROM MTL_SYSTEM_ITEMS_B msi, CS_BILLING_TYPE_CATEGORIES cbtc
      WHERE ( INVENTORY_ITEM_ID, ORGANIZATION_ID ) NOT IN (
        SELECT INVENTORY_ITEM_ID, ORGANIZATION_ID
        FROM JTM_MTL_SYSTEM_ITEMS_ACC
        WHERE RESOURCE_ID = b_resource_id )
      AND ORGANIZATION_ID = b_organization_id
      AND material_billable_flag = billing_type (+)
      AND NVL(cbtc.billing_category, 'M') = 'M'
      AND (b_changed = 'Y'
        OR msi.CREATION_DATE >= NVL(b_last_run_date, msi.CREATION_DATE ));


    -- Category is not null and Cat set is null
    CURSOR c_items_Cat (b_resource_id NUMBER, b_organization_id NUMBER,
      b_changed VARCHAR2, b_last_run_date DATE, b_category_id NUMBER)
    IS
      SELECT JTM_ACC_TABLE_S.NEXTVAL, INVENTORY_ITEM_ID, ORGANIZATION_ID, p_resource_id, billing_category
      BULK COLLECT INTO l_tab_access_id, items, organizations, l_tab_resource_id, billCat
      FROM MTL_SYSTEM_ITEMS_B msi, CS_BILLING_TYPE_CATEGORIES cbtc
      WHERE ( INVENTORY_ITEM_ID, ORGANIZATION_ID ) NOT IN (
        SELECT INVENTORY_ITEM_ID, ORGANIZATION_ID
        FROM JTM_MTL_SYSTEM_ITEMS_ACC
        WHERE RESOURCE_ID = b_resource_id )
      AND ORGANIZATION_ID = b_organization_id
      AND material_billable_flag = billing_type (+)
      AND NVL(cbtc.billing_category, 'M') = 'M'
      AND inventory_item_id IN
        (SELECT inventory_item_id
           FROM   mtl_item_categories itemcat
           WHERE  itemcat.category_id = b_category_id
           AND    itemcat.organization_id = b_organization_id
           AND    (b_changed = 'Y'
              OR itemcat.creation_date >= NVL(b_last_run_date, itemcat.CREATION_DATE)));


    -- Category is null and Cat Set is not null
    CURSOR c_items_Cat_Set (b_resource_id NUMBER, b_organization_id NUMBER,
      b_changed VARCHAR2, b_last_run_date DATE, b_category_set_id NUMBER)
    IS
      SELECT JTM_ACC_TABLE_S.NEXTVAL, INVENTORY_ITEM_ID, ORGANIZATION_ID,
             p_resource_id, material_billable_flag
      FROM MTL_SYSTEM_ITEMS_B msi
      WHERE NOT EXISTS (
            SELECT 1
            FROM JTM_MTL_SYSTEM_ITEMS_ACC acc
            WHERE RESOURCE_ID = b_resource_id
            AND msi.INVENTORY_ITEM_ID = acc.INVENTORY_ITEM_ID
            AND msi.ORGANIZATION_ID = acc.ORGANIZATION_ID)
      AND NVL(MATERIAL_BILLABLE_FLAG, 'M') = 'M'
      AND ORGANIZATION_ID = b_organization_id
      AND inventory_item_id IN
      (SELECT inventory_item_id
       FROM   mtl_item_categories itemcat
       WHERE  itemcat.category_set_id = b_category_set_id
       AND    itemcat.organization_id = b_organization_id
       AND    (b_changed = 'Y'
	        OR itemcat.creation_date >= NVL(b_last_run_date, itemcat.CREATION_DATE)));


    -- Both Category and Category set are null
    CURSOR c_items_Cat_Set_Cat (b_resource_id NUMBER, b_organization_id NUMBER,
      b_changed VARCHAR2, b_last_run_date DATE, b_category_id NUMBER, b_category_set_id NUMBER)
    IS
      SELECT JTM_ACC_TABLE_S.NEXTVAL, INVENTORY_ITEM_ID, ORGANIZATION_ID, p_resource_id, billing_category
      BULK COLLECT INTO l_tab_access_id, items, organizations, l_tab_resource_id, billCat
      FROM MTL_SYSTEM_ITEMS_B msi, CS_BILLING_TYPE_CATEGORIES cbtc
      WHERE ( INVENTORY_ITEM_ID, ORGANIZATION_ID ) NOT IN (
        SELECT INVENTORY_ITEM_ID, ORGANIZATION_ID
        FROM JTM_MTL_SYSTEM_ITEMS_ACC
        WHERE RESOURCE_ID = b_resource_id )
      AND ORGANIZATION_ID = b_organization_id
      AND material_billable_flag = billing_type (+)
      AND NVL(cbtc.billing_category, 'M') = 'M'
      AND inventory_item_id IN
        (SELECT inventory_item_id
         FROM   mtl_item_categories itemcat
         WHERE  itemcat.category_id = b_category_id
         AND    itemcat.category_set_id = b_category_set_id
         AND    itemcat.organization_id = b_organization_id
         AND (b_changed = 'Y'
           OR itemcat.creation_date >= NVL(b_last_run_date, itemcat.CREATION_DATE)));


BEGIN

el_ctr := 1;
m_ctr := 1;

 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_organization_id
    , g_table_name
    , 'Entering INSERT_ACC_REC_MARKDIRTY'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
 END IF;

 IF p_changed = 'Y' THEN
 /*Raise counter for items from given org already in acc table ( e.g. system item of SR )*/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
  jtm_message_log_pkg.Log_Msg
     ( p_organization_id
     , g_table_name
     , 'Updating '||g_acc_table_name
     , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

      --Bug 3724165
      --Bug 3929942 - Use Bind variables
      l_stmt := 'UPDATE jtm_mtl_system_items_acc';
      l_stmt :=   l_stmt || ' SET counter = counter + 1';
      l_stmt :=   l_stmt || '  ,   last_update_date = SYSDATE';
      l_stmt :=   l_stmt || '  ,   last_updated_by = 1';
      l_stmt :=   l_stmt || '  WHERE resource_id = :1 ';

      IF ( (p_category_id IS NULL) AND (p_category_set_id IS NULL) ) THEN
        -- Check material billable flag

        l_stmt := l_stmt || ' AND (inventory_item_id, organization_id) IN ';
        l_stmt := l_stmt || ' (SELECT inventory_item_id, organization_id ';
        l_stmt := l_stmt || ' FROM mtl_system_items_b msi, cs_billing_type_categories cbtc';
        l_stmt := l_stmt || ' WHERE organization_id = :2 ';
        l_stmt := l_stmt || ' and msi.material_billable_flag = cbtc.billing_type (+) ';
        l_stmt := l_stmt || ' AND NVL(cbtc.billing_category, ''M'') = ''M'')';

      ELSE -- category would ensure material items
        l_stmt :=   l_stmt || '  AND ORGANIZATION_ID = :2 ';
      END IF;

      IF (p_category_id IS NOT NULL) THEN
        l_stmt1 := ' itemcat.category_id = ' || p_category_id;
      END IF;

      IF (p_category_set_id IS NOT NULL) THEN
        IF (l_stmt1 IS NOT NULL) THEN
          l_stmt1 := l_stmt1 || ' AND itemcat.category_set_id = '
                     || p_category_set_id;
        ELSE
          l_stmt1 := ' itemcat.category_set_id = ' || p_category_set_id;
        END IF;
      END IF;

      IF (l_stmt1 IS NOT NULL) THEN
        l_stmt :=   l_stmt || '  AND ';
        l_stmt :=   l_stmt || '     inventory_item_id IN';
        l_stmt :=   l_stmt || '     (SELECT inventory_item_id';
        l_stmt :=   l_stmt || '      FROM   mtl_item_categories itemcat';
        l_stmt :=   l_stmt || '      WHERE ' || l_stmt1;
        l_stmt :=   l_stmt || '      AND    itemcat.organization_id = :3 )';
      END IF;

      IF (l_stmt1 IS NOT NULL) THEN
        EXECUTE IMMEDIATE l_stmt USING p_resource_id, p_organization_id, p_organization_id;
      ELSE
        EXECUTE IMMEDIATE l_stmt USING p_resource_id, p_organization_id;
      END IF;

    END IF;  -- End of Existing Items in SI ACC

 --Bug 3746689
 --Bug 3929942 - Split the Select into 4 parts. Convert to cursor and use LIMIT clause.
 -- Both category and cat set are null
    IF  (p_category_id IS NULL AND p_category_set_id IS NULL) THEN
      OPEN c_items(p_resource_id, p_organization_id, p_changed, p_last_run_date);
      LOOP
        l_tab_access_id.DELETE;
        items.DELETE;
        organizations.DELETE;
        l_tab_resource_id.DELETE;

        FETCH c_items BULK COLLECT INTO l_tab_access_id, items,
	 organizations, l_tab_resource_id, billCat LIMIT 1000;
        EXIT WHEN l_tab_access_id.COUNT = 0;

        IF l_tab_access_id.COUNT > 0 THEN

          /*** 1 or more acc rows retrieved -> push to resource ***/
          IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
            jtm_message_log_pkg.Log_Msg
             ( p_organization_id
             , g_table_name
             , 'Pushing ' || l_tab_access_id.COUNT
                || ' inserted record(s) to resource: '||p_resource_id
             , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
            );
          END IF;

          FORALL i IN l_tab_access_id.FIRST..l_tab_access_id.LAST
            INSERT INTO jtm_mtl_system_items_acc(
              access_id, last_update_date, last_updated_by, creation_date,
               created_by, counter, resource_id, inventory_item_id, organization_id )
            VALUES (
              l_tab_access_id(i), SYSDATE, 1, SYSDATE, 1, 1, p_resource_id,
              items(i), organizations(i));

          /*** push to oLite using asg_download ***/
          IF l_tab_access_id.COUNT > 0 THEN -- For Material Items
    	    l_dummy := asg_download.markdirty(
    		   P_PUB_ITEM     => g_publication_item_name(1)
   		 , P_ACCESSLIST   => l_tab_access_id
   		 , P_RESOURCELIST => l_tab_resource_id
   		 , P_DML_TYPE     => 'I'
   		 , P_TIMESTAMP    => SYSDATE
   		 );
          END IF;

        END IF;--IF l_tab_access_id.COUNT > 0

      END LOOP;
      CLOSE c_items;

    -- Category is not null and Cat set is null
    ELSIF (p_category_id IS NOT NULL AND p_category_set_id IS NULL) THEN
      OPEN c_items_Cat(p_resource_id, p_organization_id, p_changed, p_last_run_date,
        p_category_id);
      LOOP
        l_tab_access_id.DELETE;
        items.DELETE;
        organizations.DELETE;
        l_tab_resource_id.DELETE;

        FETCH c_items_Cat BULK COLLECT INTO l_tab_access_id, items,
	 organizations, l_tab_resource_id, billCat LIMIT 1000;
        EXIT WHEN l_tab_access_id.COUNT = 0;

        IF l_tab_access_id.COUNT > 0 THEN

          /*** 1 or more acc rows retrieved -> push to resource ***/
          IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
            jtm_message_log_pkg.Log_Msg
             ( p_organization_id
             , g_table_name
             , 'Pushing ' || l_tab_access_id.COUNT
                || ' inserted record(s) to resource: '||p_resource_id
             , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
            );
          END IF;

          FORALL i IN l_tab_access_id.FIRST..l_tab_access_id.LAST
            INSERT INTO jtm_mtl_system_items_acc(
              access_id, last_update_date, last_updated_by, creation_date,
               created_by, counter, resource_id, inventory_item_id, organization_id )
            VALUES (
              l_tab_access_id(i), SYSDATE, 1, SYSDATE, 1, 1, p_resource_id,
              items(i), organizations(i));

          /*** push to oLite using asg_download ***/
          IF l_tab_access_id.COUNT > 0 THEN -- For Material Items
    	    l_dummy := asg_download.markdirty(
    		   P_PUB_ITEM     => g_publication_item_name(1)
   		 , P_ACCESSLIST   => l_tab_access_id
   		 , P_RESOURCELIST => l_tab_resource_id
   		 , P_DML_TYPE     => 'I'
   		 , P_TIMESTAMP    => SYSDATE
   		 );
          END IF;

        END IF;--IF l_tab_access_id.COUNT > 0

      END LOOP;
      CLOSE c_items_Cat;

    -- Category is null and Cat Set is not null
    ELSIF (p_category_id IS NULL AND p_category_set_id IS NOT NULL) THEN
      OPEN c_items_Cat_Set(p_resource_id, p_organization_id, p_changed, p_last_run_date,
        p_category_set_id);
      LOOP
        l_tab_access_id.DELETE;
        items.DELETE;
        organizations.DELETE;
        l_tab_resource_id.DELETE;

        FETCH c_items_Cat_Set BULK COLLECT INTO l_tab_access_id, items,
	 organizations, l_tab_resource_id, billCat LIMIT 1000;
        EXIT WHEN l_tab_access_id.COUNT = 0;

        IF l_tab_access_id.COUNT > 0 THEN

          /*** 1 or more acc rows retrieved -> push to resource ***/
          IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
            jtm_message_log_pkg.Log_Msg
             ( p_organization_id
             , g_table_name
             , 'Pushing ' || l_tab_access_id.COUNT
                || ' inserted record(s) to resource: '||p_resource_id
             , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
            );
          END IF;

          FORALL i IN l_tab_access_id.FIRST..l_tab_access_id.LAST
            INSERT INTO jtm_mtl_system_items_acc(
              access_id, last_update_date, last_updated_by, creation_date,
               created_by, counter, resource_id, inventory_item_id, organization_id )
            VALUES (
              l_tab_access_id(i), SYSDATE, 1, SYSDATE, 1, 1, p_resource_id,
              items(i), organizations(i));

          /*** push to oLite using asg_download ***/
          IF l_tab_access_id.COUNT > 0 THEN -- For Material Items
    	    l_dummy := asg_download.markdirty(
    		   P_PUB_ITEM     => g_publication_item_name(1)
   		 , P_ACCESSLIST   => l_tab_access_id
   		 , P_RESOURCELIST => l_tab_resource_id
   		 , P_DML_TYPE     => 'I'
   		 , P_TIMESTAMP    => SYSDATE
   		 );
          END IF;

        END IF;--IF l_tab_access_id.COUNT > 0

      END LOOP;
      CLOSE c_items_Cat_Set;

    -- Both Category and Category set are null
    ELSIF (p_category_id IS NOT NULL AND p_category_set_id IS NOT NULL) THEN
      OPEN c_items_Cat_Set_Cat(p_resource_id, p_organization_id, p_changed, p_last_run_date,
        p_category_id, p_category_set_id);
      LOOP
        l_tab_access_id.DELETE;
        items.DELETE;
        organizations.DELETE;
        l_tab_resource_id.DELETE;

        FETCH c_items_Cat_Set_Cat BULK COLLECT INTO l_tab_access_id, items,
	 organizations, l_tab_resource_id, billCat LIMIT 1000;
        EXIT WHEN l_tab_access_id.COUNT = 0;

        IF l_tab_access_id.COUNT > 0 THEN

          /*** 1 or more acc rows retrieved -> push to resource ***/
          IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
            jtm_message_log_pkg.Log_Msg
             ( p_organization_id
             , g_table_name
             , 'Pushing ' || l_tab_access_id.COUNT
                || ' inserted record(s) to resource: '||p_resource_id
             , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
            );
          END IF;

          FORALL i IN l_tab_access_id.FIRST..l_tab_access_id.LAST
            INSERT INTO jtm_mtl_system_items_acc(
              access_id, last_update_date, last_updated_by, creation_date,
               created_by, counter, resource_id, inventory_item_id, organization_id )
            VALUES (
              l_tab_access_id(i), SYSDATE, 1, SYSDATE, 1, 1, p_resource_id,
              items(i), organizations(i));

          /*** push to oLite using asg_download ***/
          IF l_tab_access_id.COUNT > 0 THEN -- For Material Items
    	    l_dummy := asg_download.markdirty(
    		   P_PUB_ITEM     => g_publication_item_name(1)
   		 , P_ACCESSLIST   => l_tab_access_id
   		 , P_RESOURCELIST => l_tab_resource_id
   		 , P_DML_TYPE     => 'I'
   		 , P_TIMESTAMP    => SYSDATE
   		 );
          END IF;

        END IF;--IF l_tab_access_id.COUNT > 0

      END LOOP;
      CLOSE c_items_Cat_Set_Cat;

   END IF;


 INSERT_ACC_REC_MARKDIRTY_EXP(p_organization_id, p_resource_id, p_old_org_id);


IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_organization_id
    , g_table_name
    , 'Leaving INSERT_ACC_REC_MARKDIRTY'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
 END IF;
EXCEPTION
 WHEN OTHERS THEN
  jtm_message_log_pkg.Log_Msg
    ( p_organization_id
    , g_table_name
    , 'INSERT_ACC_REC_MARKDIRTY'||fnd_global.local_chr(10)||
      'Error: '||sqlerrm
    , JTM_HOOK_UTIL_PKG.g_debug_level_error);
  RAISE;
END INSERT_ACC_REC_MARKDIRTY;

/*
  Private procedure that re-pushes replicated system items
  that were updated since the last time the concurrent program ran.
*/
PROCEDURE UPDATE_ACC_REC_MARKDIRTY( p_last_run_date   IN DATE )
IS
 --Bug 3929942 - Modified the query to remove UNION
 CURSOR c_changed( b_last_date       DATE ) IS
  SELECT /*+ INDEX (acc JTM_MTL_SYSTEM_ITEMS_ACC_U1) index (msi MTL_SYSTEM_ITEMS_B_U1) */
    acc.ACCESS_ID, acc.RESOURCE_ID, cbtc.BILLING_CATEGORY
  FROM JTM_MTL_SYSTEM_ITEMS_ACC acc, MTL_SYSTEM_ITEMS_B msi
    , CS_BILLING_TYPE_CATEGORIES cbtc
  WHERE msi.INVENTORY_ITEM_ID = acc.INVENTORY_ITEM_ID
  AND   msi.ORGANIZATION_ID = acc.ORGANIZATION_ID
  AND   msi.material_billable_flag = cbtc.billing_type (+)
  AND   msi.LAST_UPDATE_DATE  >= b_last_date;

 l_tab_access_id   ASG_DOWNLOAD.ACCESS_LIST;
 l_tab_resource_id ASG_DOWNLOAD.USER_LIST;
 l_dummy BOOLEAN;

 --Bug 3746689
 TYPE billCat_Tab IS TABLE OF cs_billing_type_categories.billing_category%TYPE INDEX BY BINARY_INTEGER;
 billCat	billCat_Tab;
 l_billCat	cs_billing_type_categories.billing_category%TYPE;

 TYPE sourceType_Tab IS TABLE OF VARCHAR(1) INDEX BY BINARY_INTEGER;
 sourceType sourceType_Tab;

 accessId_Exp_Lab_Tab   ASG_DOWNLOAD.ACCESS_LIST;
 accessId_Mat_Tab   ASG_DOWNLOAD.ACCESS_LIST;

 resourceId_Exp_Lab_Tab ASG_DOWNLOAD.USER_LIST;
 resourceId_Mat_Tab ASG_DOWNLOAD.USER_LIST;

 newPI		BOOLEAN;
 el_ctr		NUMBER;
 m_ctr		NUMBER;

 --Bug 3929942
 l_max_last_update_date_b DATE;
 l_max_last_update_date_tl DATE;

BEGIN
 --Bug 3746689
 el_ctr	:= 1;
 m_ctr	:= 1;

 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'Entering UPDATE_ACC_REC_MARKDIRTY'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
 END IF;

    --Bug 3929942
    /* This portion of code assumes indexes on last_update_date on MTL_SYSTEM_ITEMS_B */
    /* , MTL_SYSTEM_ITEMS_TL which were custom created */
    SELECT MAX(LAST_UPDATE_DATE) into l_max_last_update_date_b
    FROM MTL_SYSTEM_ITEMS_B;
    IF( l_max_last_update_date_b < p_last_run_date) THEN
       SELECT MAX(LAST_UPDATE_DATE) into l_max_last_update_date_tl
       FROM MTL_SYSTEM_ITEMS_TL;
       IF(l_max_last_update_date_tl < p_last_run_date) THEN
         -- No updates
         IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
          jtm_message_log_pkg.Log_Msg
          ( 0
           , g_table_name
           , 'Leaving UPDATE_ACC_REC_MARKDIRTY'
           , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
          );
         END IF;
         RETURN;
       END IF;
    END IF;

 /*Fetch all changed system items that are in the acc table*/
 OPEN c_changed( p_last_run_date );
 --Bug 3746689
   --Bug 3929942
    LOOP
       /* Set the table to empty before each fetch */
       l_tab_access_id.DELETE;
       l_tab_resource_id.DELETE;
       billCat.DELETE;
       accessId_Exp_Lab_Tab.DELETE;
       accessId_Mat_Tab.DELETE;
       resourceId_Exp_Lab_Tab.DELETE;
       resourceId_Mat_Tab.DELETE;

      el_ctr := 1;
      m_ctr := 1;


      FETCH c_changed BULK COLLECT INTO
        l_tab_access_id, l_tab_resource_id, billCat limit 1000;
      EXIT when l_tab_access_id.COUNT = 0;

      /*Call oracle lite*/
      IF l_tab_access_id.COUNT > 0 THEN
      /*** 1 or more acc rows retrieved -> push to resource ***/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
            ( 0
            , g_table_name
            , 'Pushing ' || l_tab_access_id.COUNT || ' updated record(s)'
            , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
            );
        END IF;

        --Bug 3746689
        FOR i IN l_tab_access_id.FIRST..l_tab_access_id.LAST
        LOOP
          IF (billCat(i) = 'E' OR billCat(i) = 'L') THEN
            newPI := TRUE;
          ELSE
            newPI := FALSE;
          END IF;

          IF newPI THEN
            accessId_Exp_Lab_Tab(el_ctr) := l_tab_access_id(i);
            resourceId_Exp_Lab_Tab(el_ctr) := l_tab_resource_id(i);
            el_ctr := el_ctr + 1;
          ELSE
            accessId_Mat_Tab(m_ctr) := l_tab_access_id(i);
            resourceId_Mat_Tab(m_ctr) := l_tab_resource_id(i);
            m_ctr := m_ctr + 1;
          END IF;
        END LOOP;

        /*** push to oLite using asg_download ***/
        -- send the segregated data to their resp PIs.
        --Bug 3746689
        IF accessId_Exp_Lab_Tab.COUNT > 0 THEN
          l_dummy := asg_download.markdirty(
		   P_PUB_ITEM     => g_explab_publication_item_name(1) --New PI for Expense and Labor items
		 , P_ACCESSLIST   => accessId_Exp_Lab_Tab
		 , P_RESOURCELIST => resourceId_Exp_Lab_Tab
		 , P_DML_TYPE     => 'U'
		 , P_TIMESTAMP    => SYSDATE
		 );
        END IF;

        IF accessId_Mat_Tab.COUNT > 0 THEN
          l_dummy := asg_download.markdirty(
		   P_PUB_ITEM     => g_publication_item_name(1) --PI for Material Items
		 , P_ACCESSLIST   => accessId_Mat_Tab
		 , P_RESOURCELIST => resourceId_Mat_Tab
		 , P_DML_TYPE     => 'U'
		 , P_TIMESTAMP    => SYSDATE
		 );
        END IF;

      END IF; -- end of tab_access_id count
    END LOOP;
    CLOSE c_changed;

 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'Leaving UPDATE_ACC_REC_MARKDIRTY'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
 END IF;
EXCEPTION
 WHEN OTHERS THEN
   IF c_changed%ISOPEN THEN
     CLOSE c_changed;
   END IF;

  jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'UPDATE_ACC_REC_MARKDIRTY'||fnd_global.local_chr(10)||
      'Error: '||sqlerrm
    , JTM_HOOK_UTIL_PKG.g_debug_level_error);
  RAISE;
END UPDATE_ACC_REC_MARKDIRTY;

/*
  Private procedure that
  1) deletes system items for an old org/category from the client
     and calls markdirty for all deleted records.
  2) deletes system items from the client that are no longer present in a category

  If parameter p_changed = 'Y', then scenario (1) is performed.
  If parameter p_changed = 'N', then scenario (2) is performed.
*/
PROCEDURE DELETE_ALL_ACC_REC_MARKDIRTY( p_resource_id       IN  NUMBER
                                      , p_organization_id   IN  NUMBER
                                      , p_category_set_id   IN  NUMBER
                                      , p_category_id       IN  NUMBER
                                      , p_profile_org_id    IN  NUMBER
                                      )
IS
 l_tab_access_id   ASG_DOWNLOAD.ACCESS_LIST;
 l_tab_resource_id ASG_DOWNLOAD.USER_LIST;
 l_dummy           BOOLEAN;

 --Bug 3746689
 TYPE billCat_Tab IS TABLE OF cs_billing_type_categories.billing_category%TYPE INDEX BY BINARY_INTEGER;
 billCat	billCat_Tab;

 accessId_Exp_Lab_Tab   ASG_DOWNLOAD.ACCESS_LIST;
 accessId_Mat_Tab   ASG_DOWNLOAD.ACCESS_LIST;

 resourceId_Exp_Lab_Tab ASG_DOWNLOAD.USER_LIST;
 resourceId_Mat_Tab ASG_DOWNLOAD.USER_LIST;

 el_ctr		NUMBER;
 m_ctr		NUMBER;

 l_stmt		VARCHAR2(4000);
 l_stmt1	VARCHAR2(4000);

BEGIN

 el_ctr	:= 1;
 m_ctr := 1;

 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_organization_id
    , g_table_name
    , 'Entering DELETE_ALL_ACC_REC_MARKDIRTY'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
 END IF;

 /* Delete all records for org/category */
  --Bug 3724165
  -- Expense and Labor Items
  IF ( p_organization_id <> p_profile_org_id ) THEN
      UPDATE jtm_mtl_system_items_acc
      SET counter = counter - 1,
      last_update_date = SYSDATE
      WHERE resource_id = p_resource_id
      AND (inventory_item_id, organization_id) IN
        (SELECT inventory_item_id, organization_id
        FROM mtl_system_items_b msi, cs_billing_type_categories cbtc
        WHERE organization_id = p_organization_id
        and msi.material_billable_flag = cbtc.billing_type (+)
        AND cbtc.billing_category IN ('E','L'));
  END IF;

  --Bug 3724165
  -- Material Items
  l_stmt := 'UPDATE JTM_MTL_SYSTEM_ITEMS_ACC';
  l_stmt :=   l_stmt || ' SET COUNTER = COUNTER - 1';
  l_stmt :=   l_stmt || '  ,   LAST_UPDATE_DATE = SYSDATE';
  l_stmt :=   l_stmt || '  WHERE RESOURCE_ID = :1';

  IF ((p_category_id IS NULL) AND (p_category_set_id IS NULL)) THEN
    -- Check material billable flag
    l_stmt := l_stmt || ' AND (inventory_item_id, organization_id) IN ';
    l_stmt := l_stmt || ' (SELECT inventory_item_id, organization_id ';
    l_stmt := l_stmt || ' FROM mtl_system_items_b msi, cs_billing_type_categories cbtc';
    l_stmt := l_stmt || ' WHERE organization_id = :2';
    l_stmt := l_stmt || ' and msi.material_billable_flag = cbtc.billing_type (+) ';
    l_stmt := l_stmt || ' AND NVL(cbtc.billing_category, ''M'') = ''M'')';
  ELSE -- category would ensure material items
    l_stmt :=   l_stmt || '  AND ORGANIZATION_ID = :2 ';
  END IF;

  IF (p_category_id IS NOT NULL) then
    l_stmt1 := ' itemcat.category_id = ' || p_category_id;
  END IF;

  IF (p_category_set_id IS NOT NULL) THEN
    IF (l_stmt1 IS NOT NULL) THEN
      l_stmt1 := l_stmt1 || ' AND itemcat.category_set_id = ' || p_category_set_id;
    ELSE
      l_stmt1 := ' itemcat.category_set_id = ' || p_category_set_id;
    END IF;
  END IF;

  IF (l_stmt1 IS NOT NULL) THEN
    l_stmt :=   l_stmt || '  AND ';
    l_stmt :=   l_stmt || '     inventory_item_id IN';
    l_stmt :=   l_stmt || '     (SELECT inventory_item_id';
    l_stmt :=   l_stmt || '      FROM   mtl_item_categories itemcat';
    l_stmt :=   l_stmt || '      WHERE ' || l_stmt1;
    l_stmt :=   l_stmt || '      AND    itemcat.organization_id = :3 )';
  END IF;

  IF (l_stmt1 IS NOT NULL) THEN
    EXECUTE IMMEDIATE l_stmt USING p_resource_id, p_organization_id, p_organization_id;
  ELSE
    EXECUTE IMMEDIATE l_stmt USING p_resource_id, p_organization_id;
  END IF;


 /*Call oracle lite*/
 l_tab_access_id.DELETE;

 --Bug 3746689
 --Bug 3908277
 SELECT ACCESS_ID, p_resource_id, billing_category
 BULK COLLECT INTO l_tab_access_id, l_tab_resource_id, billCat
 FROM JTM_MTL_SYSTEM_ITEMS_ACC acc,
      MTL_SYSTEM_ITEMS_B msi,
      CS_BILLING_TYPE_CATEGORIES cbtc
 WHERE msi.INVENTORY_ITEM_ID = acc.INVENTORY_ITEM_ID
 AND   msi.ORGANIZATION_ID = acc.ORGANIZATION_ID
 AND   msi.material_billable_flag = cbtc.billing_type (+)
 AND COUNTER = 0;

 IF l_tab_access_id.COUNT > 0 THEN
  /*** 1 or more acc rows retrieved -> push to resource ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
     jtm_message_log_pkg.Log_Msg
     ( p_organization_id
      , g_table_name
      , 'Deleting ' || l_tab_access_id.COUNT || ' record(s) for resource: '||p_resource_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
     );
   END IF;

   --Bug 3746689
   FOR i IN l_tab_access_id.FIRST..l_tab_access_id.LAST
   LOOP

       IF billCat(i) = 'E' OR billCat(i) = 'L' THEN
	   accessId_Exp_Lab_Tab(el_ctr) := l_tab_access_id(i);
	   resourceId_Exp_Lab_Tab(el_ctr) := l_tab_resource_id(i);
	   el_ctr := el_ctr + 1;
       ELSE
	   accessId_Mat_Tab(m_ctr) := l_tab_access_id(i);
	   resourceId_Mat_Tab(m_ctr) := l_tab_resource_id(i);
	   m_ctr := m_ctr + 1;
       END IF;

   END LOOP;


   /*** push to oLite using asg_download ***/
   --Modified By UTEKUMAL on 13-Feb-2004 to send the segregated data to their resp PIs.
   IF accessId_Exp_Lab_Tab.COUNT > 0 THEN
	   l_dummy := asg_download.markdirty(
		   P_PUB_ITEM     => g_explab_publication_item_name(1) --New PI for Expense and Labor items
		 , P_ACCESSLIST   => accessId_Exp_Lab_Tab
		 , P_RESOURCELIST => resourceId_Exp_Lab_Tab
		 , P_DML_TYPE     => 'D'
		 , P_TIMESTAMP    => SYSDATE
		 );
   END IF;

   IF accessId_Mat_Tab.COUNT > 0 THEN
	   l_dummy := asg_download.markdirty(
		   P_PUB_ITEM     => g_publication_item_name(1) --PI for Material Items
		 , P_ACCESSLIST   => accessId_Mat_Tab
		 , P_RESOURCELIST => resourceId_Mat_Tab
		 , P_DML_TYPE     => 'D'
		 , P_TIMESTAMP    => SYSDATE
		 );
   END IF;


   /*To avoid a mismatch only delete records which are marked dirty*/
   FORALL i IN l_tab_access_id.FIRST..l_tab_access_id.LAST
     DELETE JTM_MTL_SYSTEM_ITEMS_ACC
     WHERE ACCESS_ID = l_tab_access_id(i);
 END IF;

 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_organization_id
    , g_table_name
    , 'Leaving DELETE_ALL_ACC_REC_MARKDIRTY'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
 END IF;

EXCEPTION
 WHEN OTHERS THEN
  jtm_message_log_pkg.Log_Msg
    ( p_organization_id
    , g_table_name
    , 'DELETE_ALL_ACC_REC_MARKDIRTY'||fnd_global.local_chr(10)||
      'Error: '||sqlerrm
    , JTM_HOOK_UTIL_PKG.g_debug_level_error);
  RAISE;
END DELETE_ALL_ACC_REC_MARKDIRTY;

/*Private procedure that processes system item changes for a given resource */
PROCEDURE CONCURRENT_PROCESS_USER( p_resource_id       IN  NUMBER
                                 , p_user_id           IN  NUMBER
                                 , p_responsibility_id IN  NUMBER
                                 , p_application_id    IN  NUMBER
                                 , p_last_run_date     IN  DATE )
IS
  l_status           VARCHAR2(1);
  l_profile_org_id          NUMBER;
  l_profile_category_set_id NUMBER;
  l_profile_category_id     NUMBER;
  l_pre_cat_filter          BOOLEAN; -- TRUE when category filter was active previously
  l_post_cat_filter         BOOLEAN; -- TRUE when category filter is active now
  l_cat_filter_changed      BOOLEAN; -- TRUE when category filter changed

 CURSOR c_org ( b_resource_id NUMBER ) IS
  SELECT organization_id, category_set_id, category_id
  FROM csl_resource_inventory_org
  WHERE resource_id = b_resource_id;
 r_org c_org%ROWTYPE;
BEGIN

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'Entering CONCURRENT_PROCESS_USER'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
  END IF;

  /*Get inventory org and category profiles */
  GET_PROFILES( p_user_id           => p_user_id
              , p_responsibility_id => p_responsibility_id
              , p_application_id    => p_application_id
              , x_organization_id   => l_profile_org_id
              , x_category_set_id   => l_profile_category_set_id
              , x_category_id       => l_profile_category_id );

  /*Get previous org and category profile setting*/
  OPEN c_org( p_resource_id );
  FETCH c_org INTO r_org;

  IF c_org%NOTFOUND THEN
    /*
      Record containing previous org and category not found ->
      insert all items without calling markdirty
      Note that this normally should never happen since resource org
      record should have been inserted during user creation (even
      when the profile doesn't have a value yet)
    */
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( 0
      , g_table_name
      , 'Resource profile record not found in csl_resource_inventory_org.' || fnd_global.local_chr(10)||
        'Inserting all system item records without calling markdirty.'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
      );
    END IF;

    INSERT_ALL_ACC_RECORDS( p_resource_id   => p_resource_id
                          , x_return_status => l_status );

  ELSE -- c_org%FOUND

    l_pre_cat_filter  := FALSE;
    l_post_cat_filter := FALSE;

    --AND cond changed to OR as part of fix for Bug 3724165
    IF (( r_org.category_set_id IS NOT NULL ) OR
        ( r_org.category_id IS NOT NULL)) THEN
      l_pre_cat_filter := TRUE;
    END IF;

    --AND cond changed to OR as part of fix for Bug 3724165
    IF (( l_profile_category_set_id IS NOT NULL ) OR
        ( l_profile_category_id IS NOT NULL)) THEN
      l_post_cat_filter := TRUE;
    END IF;


    /*** did category filter change from active -> inactive or vice versa ***/
    l_cat_filter_changed := FALSE;
    IF l_pre_cat_filter <> l_post_cat_filter THEN
      /*** yes -> set boolean ***/
      l_cat_filter_changed := TRUE;
    ELSE
      /*** no -> is filter active ***/
      IF l_post_cat_filter THEN
        /*** yes -> did category or category set change? ***/
        IF NVL(r_org.category_set_id, 0) <> NVL(l_profile_category_set_id, 0)
         OR NVL(r_org.category_id, 0) <> NVL(l_profile_category_id, 0) THEN
          l_cat_filter_changed := TRUE;
        END IF;
      END IF;
    END IF;

    /*** did system item org or category filter change? ***/
    IF NVL( l_profile_org_id, FND_API.G_MISS_NUM ) <>
            NVL( r_org.organization_id, FND_API.G_MISS_NUM )
     OR l_cat_filter_changed THEN
      /*
        organization or category profile changed ->
        delete all old system items and insert new items with markdirty
      */
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( 0
        , g_table_name
            , 'Inventory organization or category profiles changed.'
              || fnd_global.local_chr(10)||
              'original organization_id = ' || r_org.organization_id
              || ', new organization_id = ' || l_profile_org_id
              || fnd_global.local_chr(10)||
              'original category_set_id = ' || r_org.category_set_id
              || ', new category_set_id = ' || l_profile_category_set_id
              || fnd_global.local_chr(10)||
              'original category_id = ' || r_org.category_id
              || ', new category_id = ' || l_profile_category_id
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
        );
      END IF;

      --Bug 3841633
      IF (r_org.organization_id IS NOT NULL) THEN
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
              ( p_resource_id
              , g_table_name
              , 'Deleting records for old profile settings'
              , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;

        DELETE_ALL_ACC_REC_MARKDIRTY( p_resource_id       => p_resource_id
                                  , p_organization_id   => r_org.organization_id
                                  , p_category_set_id   => r_org.category_set_id
                                  , p_category_id       => r_org.category_id
	                          , p_profile_org_id    => l_profile_org_id
                                  );
      END IF;

      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
              ( p_resource_id
              , g_table_name
              , 'Inserting records for new profile settings'
              , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      INSERT_ACC_REC_MARKDIRTY( p_organization_id => l_profile_org_id
                              , p_category_set_id => l_profile_category_set_id
                              , p_category_id     => l_profile_category_id
                              , p_resource_id     => p_resource_id
			      , p_last_run_date   => NULL
			      , p_changed         => 'Y'
			      , p_old_org_id      => r_org.organization_id );

      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
              ( p_resource_id
              , g_table_name
              , 'Updating resource profile table with new profile settings'
              , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      UPDATE_RESOURCE_PROFILE_REC( p_resource_id     => p_resource_id
                                 , p_organization_id => l_profile_org_id
                                 , p_category_set_id => l_profile_category_set_id
                                 , p_category_id     => l_profile_category_id );
    ELSE
      /*
        organization and category profiles remained the same
        -> push any inserted items to resource (updates are pushed
           in main concurrent procedure in non-resource-specific call)
      */
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
              ( p_resource_id
              , g_table_name
              , 'Pushing inserted records for'||fnd_global.local_chr(10)||
                'organization_id = ' || l_profile_org_id||fnd_global.local_chr(10)||
                'category_set_id = ' || l_profile_category_set_id||fnd_global.local_chr(10)||
                'category_id = ' || l_profile_category_id
              , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      INSERT_ACC_REC_MARKDIRTY( p_organization_id => l_profile_org_id
                              , p_category_set_id => l_profile_category_set_id
                              , p_category_id     => l_profile_category_id
                              , p_resource_id     => p_resource_id
			      , p_last_run_date   => p_last_run_date
  			        , p_changed         => 'N'
                                , p_old_org_id      => r_org.organization_id );
    END IF;

  END IF; -- c_org%NOTFOUND
  CLOSE c_org;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'Leaving CONCURRENT_PROCESS_USER'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
  END IF;

EXCEPTION
 WHEN OTHERS THEN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
      ( 0
      , g_table_name
      , 'Caught exception in CONCURRENT_PROCESS_USER'||fnd_global.local_chr(10)||
        'Error: '||sqlerrm
      , JTM_HOOK_UTIL_PKG.g_debug_level_error);
  END IF;
  ROLLBACK;
  RAISE;
END CONCURRENT_PROCESS_USER;

/*** Public procedure that gets called when the concurrent Program run ***/
PROCEDURE CON_REQUEST_MTL_SYSTEM_ITEMS
IS
  PRAGMA AUTONOMOUS_TRANSACTION;

  /*** get the last run date of the concurent program ***/
  CURSOR  c_LastRundate
  IS
    select LAST_RUN_DATE
    from   JTM_CON_REQUEST_DATA
    where  package_name =  'CSL_MTL_SYSTEM_ITEMS_ACC_PKG'
    AND    procedure_name = 'CON_REQUEST_MTL_SYSTEM_ITEMS';
    r_LastRundate  c_LastRundate%ROWTYPE;

  /*** cursor retrieving list of resources subscribed to publication item ***/
  CURSOR c_mobile_resp
   IS
    SELECT res.resource_id
    ,      usr.user_id
    ,      usrresp.responsibility_id
    ,      usrresp.responsibility_application_id
    FROM  asg_pub                pub
    ,     asg_pub_responsibility pubresp
    ,     fnd_user_resp_groups   usrresp
    ,     fnd_user               usr
    ,     jtf_rs_resource_extns  res
    ,     asg_user               au
    WHERE res.resource_id = au.resource_id --b_resource_id
    AND   pub.name = 'SERVICEL'
    AND   pub.enabled='Y'
    AND   pub.status='Y'
    AND   pub.pub_id = pubresp.pub_id
    AND   pubresp.responsibility_id = usrresp.responsibility_id
    AND   TRUNC(sysdate) BETWEEN TRUNC(NVL(usrresp.start_date,sysdate))
                             AND TRUNC(NVL(usrresp.end_date,sysdate))
    AND   usrresp.user_id = usr.user_id
    AND   TRUNC(sysdate) BETWEEN TRUNC(NVL(usr.start_date,sysdate))
                             AND TRUNC(NVL(usr.end_date,sysdate))
    AND   usr.user_id = res.user_id
    AND   TRUNC(sysdate) BETWEEN TRUNC(NVL(res.start_date_active,sysdate))
                             AND TRUNC(NVL(res.end_date_active,sysdate));

  l_current_run_date DATE;
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'Entering CON_REQUEST_MTL_SYSTEM_ITEMS'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
  END IF;

  /*** First retrieve last run date of the conccurent program ***/
  OPEN  c_LastRundate;
  FETCH c_LastRundate  INTO r_LastRundate;
  CLOSE c_LastRundate;

  l_current_run_date := SYSDATE;

  /*** Push updated system item records to resources ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'Pushing updated records'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
    );
  END IF;
  UPDATE_ACC_REC_MARKDIRTY( p_last_run_date => r_LastRundate.last_run_date );
  COMMIT;

  /*** Get the mobile laptop resources and loop over all of them ***/
  FOR r_mobile_resp IN c_mobile_resp LOOP

    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
       jtm_message_log_pkg.Log_Msg
       ( 0
       , g_table_name
       , 'Processing resource_id = ' || r_mobile_resp.resource_id
       , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
       );
    END IF;

    CONCURRENT_PROCESS_USER( p_resource_id       => r_mobile_resp.resource_id
                           , p_user_id           => r_mobile_resp.user_id
                           , p_responsibility_id => r_mobile_resp.responsibility_id
                           , p_application_id    => r_mobile_resp.responsibility_application_id
                           , p_last_run_date     => r_LastRundate.last_run_date );
  -- YLIAO comment out, as this might cause duplicate if the conc program stop
  -- where some users processed while others not with LAST_RUN_DATE unchanged.
  -- And next time conc program re-start, the processed users will be
  -- re-processed again causing the same records with counter++.
  --  COMMIT;

  END LOOP;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
     jtm_message_log_pkg.Log_Msg
     ( 0
     , g_table_name
     , 'Updating LAST_RUN_DATE from '||r_LastRundate.LAST_RUN_DATE||' to '||l_current_run_date
     , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
     );
  END IF;

  /*Update the last run date*/
  UPDATE JTM_CON_REQUEST_DATA
  SET LAST_RUN_DATE = l_current_run_date
  WHERE package_name =  'CSL_MTL_SYSTEM_ITEMS_ACC_PKG'
  AND   procedure_name = 'CON_REQUEST_MTL_SYSTEM_ITEMS';

  COMMIT;

 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
   jtm_message_log_pkg.Log_Msg
   ( 0
   , g_table_name
   , 'Leaving CON_REQUEST_MTL_SYSTEM_ITEMS'
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
   );
 END IF;

EXCEPTION
 WHEN OTHERS THEN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
      ( 0
      , g_table_name
      , 'CON_REQUEST_MTL_SYSTEM_ITEMS'||fnd_global.local_chr(10)||
        'Error: '||sqlerrm
      , JTM_HOOK_UTIL_PKG.g_debug_level_error);
  END IF;
  ROLLBACK;
END CON_REQUEST_MTL_SYSTEM_ITEMS;

END CSL_MTL_SYSTEM_ITEMS_ACC_PKG;

/
