--------------------------------------------------------
--  DDL for Package Body EGO_INV_ITEM_CATALOG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_INV_ITEM_CATALOG_PVT" AS
/* $Header: EGOITCCB.pls 120.9.12010000.4 2009/12/18 07:05:46 snandana ship $ */

G_PKG_NAME           CONSTANT  VARCHAR2(30)  := 'EGO_INV_ITEM_CATALOG_PVT';
G_APP_NAME           CONSTANT  VARCHAR2(3)   := 'EGO';
G_PKG_NAME_TOKEN     CONSTANT  VARCHAR2(8)   := 'PKG_NAME';
G_API_NAME_TOKEN     CONSTANT  VARCHAR2(8)   := 'API_NAME';
G_SQL_ERR_MSG_TOKEN  CONSTANT  VARCHAR2(11)  := 'SQL_ERR_MSG';
G_PLSQL_ERR          CONSTANT  VARCHAR2(17)  := 'EGO_PLSQL_ERR';

-- Developer debugging
PROCEDURE code_debug (p_msg  IN  VARCHAR2) IS
BEGIN
  --sri_debug ('EGOITCCB '||p_msg);
  RETURN;
EXCEPTION
  WHEN OTHERS THEN
  NULL;
END code_debug;

------------------------------------------------------------------------------
  -- Start OF comments
  -- API name  : Get_Error_msg
  -- TYPE      : Private
  -- Pre-reqs  : None
  -- PROCEDURE : To get the error message.
  -- Remarks   : Created as a part of bug 3637854
  -----------------------------------------------------------------------------
Procedure  Get_Error_msg (p_inventory_item_id  IN  NUMBER
                         ,p_organization_id    IN  NUMBER
                         ,p_item_revision_id   IN  NUMBER
                         ,p_message_name       IN  VARCHAR2
                         ,x_return_status      OUT  NOCOPY  VARCHAR2
                         ,x_msg_count          OUT  NOCOPY  NUMBER
                         ,x_msg_data           OUT  NOCOPY  VARCHAR2
          ) IS
  l_item_number    VARCHAR2(999);
  l_org_name       VARCHAR2(999);
  l_revision       VARCHAR2(999);

  BEGIN
    -- note:
    --        revision id is passed if the error message should be revision specific
    --
    IF p_message_name IN ('EGO_ITEM_LC_PROJ_EXISTS',
                          'EGO_ITEM_PENDING_CHANGES_EXIST',
                          'EGO_ITEM_PENDING_REC_EXISTS') THEN
      --
      -- get item name
      --
      SELECT concatenated_segments
      INTO l_item_number
      FROM mtl_system_items_kfv
      WHERE inventory_item_id = p_inventory_item_id
        AND organization_id = p_organization_id;
      --
      -- get organiation name
      --
      SELECT name
      INTO l_org_name
      FROM hr_all_organization_units_vl
      WHERE organization_id = p_organization_id;
      --
      -- create the mesage
      --
      IF p_item_revision_id IS NOT NULL THEN
        --
        -- bug: 3696801  decoding the messages
        --
        IF p_message_name = 'ITEM_LC_PROJ_EXISTS' THEN
          fnd_message.set_name('EGO', 'EGO_ITEM_REV_LC_PROJ_EXISTS');
        ELSIF p_message_name = 'EGO_ITEM_PENDING_CHANGES_EXIST' THEN
          fnd_message.set_name('EGO', 'EGO_REV_PEND_CHANGES_EXIST');
        ELSIF p_message_name = 'EGO_ITEM_PENDING_REC_EXISTS' THEN
          fnd_message.set_name('EGO', 'EGO_REV_PEND_REC_EXISTS');
        END IF;
        --
        -- get revision name
        --
        SELECT revision
        INTO l_revision
        FROM mtl_item_revisions_b
        WHERE revision_id = p_item_revision_id;
        fnd_message.set_token('REVISION', l_revision);
      ELSE
        fnd_message.set_name('EGO', p_message_name);
      END IF;
      fnd_message.set_token('ITEM_NUMBER', l_item_number);
      fnd_message.set_token('ORG_NAME', l_org_name);

      /* Bug Fix 7628987: added the below code */
		   IF  p_message_name = 'EGO_ITEM_PENDING_CHANGES_EXIST' THEN
		       INV_ITEM_MSG.Add_Message (p_Msg_Name  => 'INV_ITEM_PEND_CHGS_EXIST',
		                               p_token1 =>  'ITEM_NUMBER',
		                                 p_value1 =>  l_item_number,
		                               p_token2 =>  'ORG_NAME',
		                                 p_value2 =>  l_org_name);
		   END IF;
		   /* End of Bug Fix 7628987 */
    ELSE
      fnd_message.set_name('EGO', p_message_name);
    END IF;
    x_msg_count := 1;
    x_msg_data := fnd_message.get();
    --
    -- return status as Error
    --
    x_return_status := FND_API.G_RET_STS_ERROR;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.Set_Name(G_APP_NAME, G_PLSQL_ERR);
      FND_MESSAGE.Set_Token(G_PKG_NAME_TOKEN, G_PKG_NAME);
      FND_MESSAGE.Set_Token(G_API_NAME_TOKEN, 'GET_ERROR_MSG');
      FND_MESSAGE.Set_Token(G_SQL_ERR_MSG_TOKEN, SQLERRM);
      x_msg_count := 1;
      x_msg_data := FND_MESSAGE.GET;
  END Get_Error_Msg;

------------------------------------------------------------------------------
  -- Start OF comments
  -- API name  : Sync_Item_Revisions
  -- TYPE      : Private (made as a part of bug 3637854
  -- Pre-reqs  : None
  -- PROCEDURE : Sets the LC of Item Rev to that of Item and phase to default phase
  -- Remarks   : Assumed that the same lifecycle is associated at all orgs
  --             in the org hierarchy
  -----------------------------------------------------------------------------

Procedure Sync_Item_Revisions (
        p_inventory_item_id  IN   NUMBER
       ,p_organization_id    IN   NUMBER
       ,p_lifecycle_id       IN   NUMBER
       ,p_lifecycle_phase_id IN   NUMBER
       ,p_validate_changes   IN   VARCHAR2
       ,p_new_cc_in_hier     IN   BOOLEAN := FALSE  --Bug: 4060185
       ,x_return_status      OUT  NOCOPY  VARCHAR2
       ,x_msg_count          OUT  NOCOPY  NUMBER
       ,x_msg_data           OUT  NOCOPY  VARCHAR2
) IS

  CURSOR c_get_default_phase_id (cp_lifecycle_id IN  NUMBER) IS
    SELECT pev_p.PROJ_ELEMENT_ID
      FROM PA_PROJ_ELEMENT_VERSIONS pev_l,
           PA_LIFECYCLE_USAGES plu,
           PA_PROJ_ELEMENT_VERSIONS pev_p,
           PA_PROJ_ELEMENTS PPE_P,
           PA_PROJECT_STATUSES pc
     WHERE pev_l.OBJECT_TYPE = 'PA_STRUCTURES'
       AND pev_l.PROJ_ELEMENT_ID = cp_lifecycle_id
       AND pev_l.PROJECT_ID = 0
       AND plu.USAGE_TYPE = 'PRODUCTS'
       AND plu.LIFECYCLE_ID = pev_l.PROJ_ELEMENT_ID
       AND pev_l.ELEMENT_VERSION_ID = pev_p.PARENT_STRUCTURE_VERSION_ID
       AND pev_p.PROJ_ELEMENT_ID = ppe_p.PROJ_ELEMENT_ID
       AND ppe_p.PHASE_CODE = pc.PROJECT_STATUS_CODE
       AND (pc.START_DATE_ACTIVE IS NULL OR pc.START_DATE_ACTIVE <= SYSDATE)
       AND (pc.END_DATE_ACTIVE IS NULL OR pc.END_DATE_ACTIVE >= SYSDATE)
     ORDER BY pev_p.DISPLAY_SEQUENCE;

  CURSOR c_get_item_rev_details (cp_item_id   IN   NUMBER
                                ,cp_org_id    IN   NUMBER) IS
    SELECT rowid, revision, revision_id, lifecycle_id, current_phase_id, organization_id
    FROM   mtl_item_revisions_b  item_rev
    WHERE  inventory_item_id = cp_item_id
      AND  EXISTS
             (SELECT P2.ORGANIZATION_ID
              FROM   MTL_PARAMETERS P1,
                     MTL_PARAMETERS P2
              WHERE  P1.ORGANIZATION_ID = cp_org_id
              AND    P1.MASTER_ORGANIZATION_ID = P2.MASTER_ORGANIZATION_ID
        AND    p2.organization_id = item_rev.organization_id
              )
      AND  lifecycle_id IS NOT NULL
      AND  current_phase_id IS NOT NULL;

  l_api_name                    VARCHAR2(30);
  l_item_rev_def_phase_id       NUMBER;
  l_item_rev_lifecycle_id       NUMBER;
  l_user_id                     NUMBER;
  l_login_id                    NUMBER;
  l_sysdate                     DATE;

BEGIN
  l_api_name  := 'Sync_Item_Revisions';
  code_debug(l_api_name||': Started ');
  l_item_rev_lifecycle_id := p_lifecycle_id;
  IF p_lifecycle_id IS NULL THEN
    l_item_rev_lifecycle_id := NULL;
    l_item_rev_def_phase_id := NULL;
  ELSE
    OPEN  c_get_default_phase_id (cp_lifecycle_id => p_lifecycle_id);
    FETCH c_get_default_phase_id INTO l_item_rev_def_phase_id;
    IF c_get_default_phase_id%NOTFOUND THEN
      l_item_rev_lifecycle_id := NULL;
      l_item_rev_def_phase_id := NULL;
    END IF;
    CLOSE c_get_default_phase_id;
  END IF; -- p_lifecycle_id

  l_user_id    := FND_GLOBAL.User_Id;
  l_login_id   := FND_GLOBAL.Login_Id;
  l_sysdate    := SYSDATE;

  FOR Item_Rev_Record IN c_get_item_rev_details (cp_item_id => p_inventory_item_id
                                                ,cp_org_id  => p_organization_id)
  LOOP
    code_debug(l_api_name||' Checking pending change orders for revision '|| Item_Rev_Record.revision);
    IF (FND_API.TO_BOOLEAN(p_validate_changes) AND NOT p_new_cc_in_hier) THEN --Bug: 4060185
      Check_Pending_Change_Orders
        (p_inventory_item_id   => p_inventory_item_id
        ,p_organization_id     => Item_Rev_Record.organization_id
        ,p_revision_id         => Item_Rev_Record.revision_id
        ,p_lifecycle_changed        => FND_API.G_FALSE
        ,p_lifecycle_phase_changed  => FND_API.G_TRUE
        ,p_change_id                => NULL
        ,p_change_line_id           => NULL
        ,x_return_status       => x_return_status
        ,x_msg_count           => x_msg_count
        ,x_msg_data            => x_msg_data
        );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        code_debug(l_api_name||'  returning Check_Pending_Change_Orders with status '|| x_return_status);
        RETURN;
      END IF;
    END IF;
    --
code_debug(l_api_name||': before in Sync revisions check_floating_attachments');

   EGO_DOM_UTIL_PUB.check_floating_attachments (  p_inventory_item_id  => p_inventory_item_id
                                                 ,p_revision_id        => Item_Rev_Record.revision_id
                                                 ,p_organization_id    => p_organization_id
                                                 ,p_lifecycle_id       => p_lifecycle_id
                                                 ,p_new_phase_id       => p_lifecycle_phase_id
                                                 ,x_return_status      => x_return_status
                                                 ,x_msg_count          => x_msg_count
                                                 ,x_msg_data           => x_msg_data );

code_debug(l_api_name||': check_floating_attachments' || x_return_status);
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RETURN;
   END IF;


    -- update item revision
    --
    UPDATE mtl_item_revisions_b
    SET  lifecycle_id = l_item_rev_lifecycle_id,
         current_phase_id = l_item_rev_def_phase_id,
         last_update_date = l_sysdate,
         last_updated_by = l_user_id,
         last_update_login = l_login_id
    WHERE  rowid  = Item_Rev_Record.rowid;
    --
    -- create history records
    --
    code_debug(l_api_name||': Creating Phase History Record ');
    Create_Phase_History_Record (
         p_api_version         => 1.0
        ,p_commit              => FND_API.G_FALSE
        ,p_inventory_item_id   => p_inventory_item_id
        ,p_organization_id     => Item_Rev_Record.organization_id
        ,p_revision_id         => Item_Rev_Record.Revision_id
        ,p_lifecycle_id        => l_item_rev_lifecycle_id
        ,p_lifecycle_phase_id  => l_item_rev_def_phase_id
        ,p_item_status_code    => NULL
        ,x_return_status       => x_return_status
        ,x_msg_count           => x_msg_count
        ,x_msg_data            => x_msg_data
       );
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
    END IF;
    --
    -- update item revision project
    --
    code_debug(l_api_name||': Delete project associations ');
    DELETE  EGO_ITEM_PROJECTS
    WHERE  INVENTORY_ITEM_ID = p_inventory_item_id
      AND  ORGANIZATION_ID = Item_Rev_Record.organization_id
--      AND  REVISION = Item_Rev_Record.revision
      AND  revision_id = Item_Rev_Record.revision_id
      AND  ASSOCIATION_TYPE  = 'EGO_ITEM_PROJ_ASSOC_TYPE'
      AND  ASSOCIATION_CODE  = 'LIFECYCLE_TRACKING';
  END LOOP;  -- item revision loop
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  code_debug(l_api_name||': Bye Bye ');
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF c_get_default_phase_id%ISOPEN THEN
      CLOSE c_get_default_phase_id;
    END IF;
    IF c_get_item_rev_details%ISOPEN THEN
      CLOSE c_get_item_rev_details;
    END IF;
    x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.Set_Name(G_APP_NAME, G_PLSQL_ERR);
    FND_MESSAGE.Set_Token(G_PKG_NAME_TOKEN, G_PKG_NAME);
    FND_MESSAGE.Set_Token(G_API_NAME_TOKEN, 'SYNC_ITEM_REVISIONS');
    FND_MESSAGE.Set_Token(G_SQL_ERR_MSG_TOKEN, SQLERRM);
    x_msg_count := 1;
    x_msg_data := FND_MESSAGE.GET;
    code_debug(' Exception in  Sync_Item_Revisions : ' ||x_msg_data );
END Sync_Item_Revisions;

------------------------------------------------------------------------------
  -- Start OF comments
  -- API name  : Change_Item_Lifecycle
  -- TYPE      : Public
  -- Pre-reqs  : None
  -- PROCEDURE : Changes Items lifecycle-phase-status(including child org items)
  --             Org-Status profile is not honoured.
  --             API doesnt validate the ID's passed.(Since gets ID's from UI)
------------------------------------------------------------------------------
Procedure Change_Item_Lifecycle (
  P_INVENTORY_ITEM_ID           IN   NUMBER,
  P_ORGANIZATION_ID             IN   NUMBER,
  P_NEW_CATALOG_CATEGORY_ID     IN   NUMBER,
  P_NEW_LIFECYCLE_ID            IN   NUMBER,
  P_NEW_PHASE_ID                IN   NUMBER,
  P_NEW_ITEM_STATUS_CODE        IN   VARCHAR2,
  P_COMMIT                      IN   VARCHAR2,
  X_RETURN_STATUS               OUT  NOCOPY VARCHAR2,
  X_MSG_COUNT                   OUT  NOCOPY NUMBER,
  X_MSG_DATA                    OUT  NOCOPY VARCHAR2 ) IS

  CURSOR c_get_item_details(cp_item_id IN NUMBER, cp_org_id  IN  NUMBER) IS
    SELECT rowid,
           organization_id,
           lifecycle_id,
           current_phase_id,
           inventory_item_status_code,
           item_catalog_group_id,
           description,
           concatenated_segments
    FROM   mtl_system_items_kfv item -- changed for Business Event Enh.
    WHERE  inventory_item_id = cp_item_id
      AND  EXISTS
             (SELECT P2.ORGANIZATION_ID
              FROM   MTL_PARAMETERS P1,
                     MTL_PARAMETERS P2
              WHERE  P1.ORGANIZATION_ID = cp_org_id
              AND    P1.MASTER_ORGANIZATION_ID = P2.MASTER_ORGANIZATION_ID
              AND    P2.ORGANIZATION_ID = item.ORGANIZATION_ID
              );

  CURSOR c_get_item_curr_data (cp_item_id IN NUMBER, cp_org_id  IN  NUMBER) IS
    SELECT item_catalog_group_id,
           lifecycle_id,
           current_phase_id,
     inventory_item_status_code
    FROM   mtl_system_items_b item
    WHERE  inventory_item_id = cp_item_id
      AND  organization_id = cp_org_id;

  --Return Status Variables
  l_ret_success     CONSTANT    VARCHAR2(1)  :=  FND_API.g_RET_STS_SUCCESS;     --'S'
  l_ret_error       CONSTANT    VARCHAR2(1)  :=  FND_API.g_RET_STS_ERROR;       --'E'
  l_ret_unexp_error CONSTANT    VARCHAR2(1)  :=  FND_API.g_RET_STS_UNEXP_ERROR; --'U'
  l_user_id         CONSTANT    NUMBER       :=  FND_GLOBAL.User_Id;
  l_login_id        CONSTANT    NUMBER       :=  FND_GLOBAL.Login_Id;

  l_status_rec                  BOOLEAN      := FALSE;
  l_phase_rec                   BOOLEAN      := FALSE;
  l_pending_flag                VARCHAR2(1)  := 'Y';
  l_sysdate                     DATE         := SYSDATE;
  l_implemented_date            DATE         := SYSDATE;
  l_msg_data                    VARCHAR2(1000);
  l_organization_id             NUMBER;
  l_api_name                    VARCHAR2(30);

  l_new_lifecycle_id    NUMBER;
  l_new_phase_id        NUMBER;
  l_new_cc_id           NUMBER;
  l_curr_lifecycle_id   NUMBER;
  l_curr_phase_id       NUMBER;
  l_curr_cc_id          NUMBER;
  l_curr_status_code    MTL_SYSTEM_ITEMS_B.inventory_item_status_code%TYPE;
  --Start 4105841
  l_event_ret_status    VARCHAR2(1);
  l_org_code            MTL_PARAMETERS.ORGANIZATION_CODE%TYPE;
  l_raise_event         VARCHAR2(1);
  --Start 4105841
  l_item_description    VARCHAR2(2000);  --R12
  l_item_number         VARCHAR2(2000);  --R12
  l_control_level       VARCHAR2(1);


BEGIN
   x_return_status := l_ret_error;
   l_api_name := 'Change_Item_Lifecycle';
   code_debug(l_api_name||': started with org id '||to_char(p_organization_id));
   IF FND_API.To_Boolean( p_commit ) THEN
     SAVEPOINT Change_Item_Lifecycle;
   END IF;
   code_debug(l_api_name||': Taking the null values ');
   IF p_new_catalog_category_id = -1 THEN
     l_new_cc_id := NULL;
   ELSE
     l_new_cc_id := p_new_catalog_category_id;
   END IF;
   IF p_new_lifecycle_id = -1 THEN
     l_new_lifecycle_id := NULL;
   ELSE
     l_new_lifecycle_id := p_new_lifecycle_id;
   END IF;
   IF p_new_phase_id = -1 THEN
     l_new_phase_id := NULL;
   ELSE
     l_new_phase_id := p_new_phase_id;
   END IF;

   code_debug(l_api_name||': Fetching current values ');
   OPEN c_get_item_curr_data (cp_item_id  => p_inventory_item_id
                           ,cp_org_id   => p_organization_id);
   FETCH c_get_item_curr_data INTO
      l_curr_cc_id,
      l_curr_lifecycle_id,
      l_curr_phase_id,
      l_curr_status_code;
   CLOSE c_get_item_curr_data;
   -- when calling from UI, the hierarchy check is already done
   -- if the chosen catalog category is not within the mentioned hierarchy
   -- error is flashed at the UI itself.
   code_debug(l_api_name||': Calling Validate_And_Change_Item_LC ');

code_debug(l_api_name||': check_floating_attachments');

   EGO_DOM_UTIL_PUB.check_floating_attachments (  p_inventory_item_id  => p_inventory_item_id
                                                 ,p_revision_id        => NULL
                                                 ,p_organization_id    => p_organization_id
                                                 ,p_lifecycle_id       => l_new_lifecycle_id
                                                 ,p_new_phase_id       => l_new_phase_id
                                                 ,x_return_status      => x_return_status
                                                 ,x_msg_count          => x_msg_count
                                                 ,x_msg_data           => x_msg_data );

code_debug(l_api_name||': check_floating_attachments' || x_return_status);
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF FND_API.To_Boolean( p_commit ) THEN
                ROLLBACK TO Change_Item_Lifecycle;
        END IF;
        RETURN;
   END IF;

   Validate_And_Change_Item_LC(
              p_api_version          => 1.0
             ,p_commit               => FND_API.G_FALSE
             ,p_inventory_item_id    => p_inventory_item_id
             ,p_item_revision_id     => NULL
             ,p_organization_id      => p_organization_id
             ,p_fetch_curr_values    => FND_API.G_FALSE
             ,p_curr_cc_id           => l_curr_cc_id
             ,p_new_cc_id            => l_new_cc_id
             ,p_is_new_cc_in_hier    => FND_API.G_TRUE
             ,p_curr_lc_id           => l_curr_lifecycle_id
             ,p_new_lc_id            => l_new_lifecycle_id
             ,p_curr_lcp_id          => l_curr_phase_id
             ,p_new_lcp_id           => l_new_phase_id
             ,p_change_id            => NULL
             ,p_change_line_id       => NULL
             ,x_return_status        => x_return_status
             ,x_msg_count            => x_msg_count
             ,x_msg_data             => x_msg_data
             );
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     IF FND_API.To_Boolean( p_commit ) THEN
       ROLLBACK TO Change_Item_Lifecycle;
     END IF;
     RETURN;
   END IF;

   FOR Item_Record IN c_get_item_details(cp_item_id => p_inventory_item_id
                                        ,cp_org_id  => p_organization_id  ) LOOP

      l_status_rec        := FALSE;
      l_phase_rec         := FALSE;
      l_pending_flag      := 'N';

      -- bug 3571186
      -- checking if there are any pending changes before flashing error
      code_debug(l_api_name||': curr lifecycle id'||Item_Record.lifecycle_id||' new lifecycle_id '|| p_new_lifecycle_id);
      code_debug(l_api_name||': curr phase id'||Item_Record.current_phase_id||' new phase id '|| p_new_phase_id);
      IF ( NVL(Item_Record.lifecycle_id,-1) <> NVL(p_new_lifecycle_id,-1)
           OR
           NVL(Item_Record.current_phase_id,-1) <> NVL(p_new_phase_id,-1)
          ) THEN
        --
        -- user is changing lifecycle OR lifecycle phase
        --
        --If there is a phase change, then insert a record into mtl_pending_item_status
        code_debug(l_api_name||': changing the lifecycle now ');
        l_phase_rec        := TRUE;
        l_pending_flag     := 'N';
        l_implemented_date := l_sysdate;
        l_raise_event      := 'Y';

        UPDATE mtl_system_items_b
        SET  lifecycle_id      = DECODE(p_new_lifecycle_id,-1,NULL,p_new_lifecycle_id),
             current_phase_id  = DECODE(p_new_phase_id,-1,NULL,p_new_phase_id),
             last_update_date  = l_sysdate,
             last_updated_by   = l_user_id,
             last_update_login = l_login_id
        WHERE  rowid = Item_Record.rowid;

    END IF;

      SELECT control_level into l_control_level
      from mtl_item_attributes
      where attribute_name = 'MTL_SYSTEM_ITEMS.INVENTORY_ITEM_STATUS_CODE';

      IF Item_Record.inventory_item_status_code <> p_new_item_status_code
        AND
           ( l_control_level <> '2'
             OR l_NEW_PHASE_ID IS NOT NULL
             OR l_NEW_LIFECYCLE_ID IS NOT NULL
             OR (l_NEW_PHASE_ID IS NULL AND l_NEW_LIFECYCLE_ID IS NULL
                 AND l_control_level = '2' AND Item_Record.organization_id = p_organization_id)
           ) THEN
         --If status changes insert into pending table as pending
         --Run the update item status function to set status controlled attributed
         --Update Item Status of Item in current organization only if lifeCycle and Phase are not given and control
         -- level for Item Status attribute is org controlled.
         l_status_rec       := TRUE;
         l_pending_flag     := 'Y';
         l_implemented_date := NULL;
      ELSE
         l_status_rec := FALSE;
	 -- Bug 6241605: If the phase has been changed and the same status is selected same as old then
	 -- phase record should be inserted in the pending item status table.So commenting out the nex line.
         --l_phase_rec := FALSE;
      END IF;

      IF (l_status_rec OR l_phase_rec) THEN
         code_debug(l_api_name||': creating a pending item status ');
         l_phase_rec := FALSE;
         INSERT INTO mtl_pending_item_status(
            inventory_item_id,
            organization_id,
            effective_date,
            implemented_date,
            pending_flag,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            lifecycle_id,
            phase_id,
            status_code)
         VALUES(
            p_inventory_item_id,
            Item_Record.organization_id,
            l_sysdate,
            l_implemented_date,
            l_pending_flag,
            l_sysdate,
            l_user_id,
            l_sysdate,
            l_user_id,
            DECODE(p_new_lifecycle_id,-1,NULL,p_new_lifecycle_id),
            DECODE(p_new_phase_id,-1,NULL,p_new_phase_id),
            p_new_item_status_code );
      END IF;

      IF l_pending_flag ='Y' THEN
         --
         -- change is from the status change only
         --
         code_debug(l_api_name||': implementing the pending status ');
         INV_ITEM_STATUS_PUB.Update_Pending_Status(
               p_api_version    => 1.0
              ,p_org_id         => Item_Record.organization_id
              ,p_item_id        => p_inventory_item_id
              ,p_init_msg_list  => NULL
              ,p_commit         => NULL
              ,x_return_status  => x_return_status
              ,x_msg_count      => x_msg_count
              ,x_msg_data       => x_msg_data);
         l_raise_event := 'Y';
      END IF;

      /*R12  Business Events
      Store the item number and description
      for passsing to raise event call */
      IF l_item_number IS NULL THEN
         l_item_number      := Item_Record.Concatenated_segments;
	 l_item_description := Item_Record.Description;
      END IF;
      --R12  Business Events

   END LOOP;

   --R12 Moved the code outside the loop to raise the event
   --Start 4105841
   --Raise the Item Update Event for Lifecycle,Phase or Status Change
   --If Catalog Category is also changed,then don't raise the event here
   --as it will be raised by Change Item Catalog
   IF l_raise_event = 'Y'
     AND NVL(l_curr_cc_id,-1) = NVL(p_new_catalog_category_id,-1)
   THEN
     SELECT ORGANIZATION_CODE INTO l_org_code
     FROM MTL_PARAMETERS
     WHERE ORGANIZATION_ID = p_organization_id;
     EGO_WF_WRAPPER_PVT.Raise_Item_Create_Update_Event(
                    p_event_name         =>  EGO_WF_WRAPPER_PVT.G_ITEM_UPDATE_EVENT
                   ,p_Organization_Id    =>  p_Organization_Id
                   ,p_organization_code  =>  l_org_code
                   ,p_Inventory_Item_Id  =>  p_inventory_item_id
                   ,p_item_number        =>  l_item_number
                   ,p_item_description   =>  l_item_description
                   ,x_msg_data           =>  l_msg_data
                   ,x_return_status      =>  l_event_ret_status
                    );
   END IF;
   --End 4105841 Raise events

   --Call ICX APIs
   BEGIN
      INV_ITEM_EVENTS_PVT.Invoke_ICX_APIs(
         p_entity_type       => 'ITEM'
        ,p_dml_type          => 'UPDATE'
        ,p_inventory_item_id => p_inventory_item_id
        ,p_item_number       => l_item_number
        ,p_item_description  => l_item_description
        ,p_organization_id   => p_Organization_Id
        ,p_organization_code => l_org_code );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
   END;
   --R12: Business Event Enhancement



   IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
   END IF;
   x_return_status := l_ret_success;
  code_debug(l_api_name||': Bye Bye ');
EXCEPTION
   WHEN OTHERS THEN
      IF FND_API.To_Boolean( p_commit ) THEN
        ROLLBACK TO Change_Item_Lifecycle;
      END IF;
      IF c_get_item_details%ISOPEN THEN
        CLOSE c_get_item_details;
      END IF;
      IF c_get_item_curr_data%ISOPEN THEN
        CLOSE c_get_item_curr_data;
      END IF;
      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.Set_Name(G_APP_NAME, G_PLSQL_ERR);
      FND_MESSAGE.Set_Token(G_PKG_NAME_TOKEN, G_PKG_NAME);
      FND_MESSAGE.Set_Token(G_API_NAME_TOKEN, l_api_name);
      FND_MESSAGE.Set_Token(G_SQL_ERR_MSG_TOKEN, SQLERRM);
      x_msg_count := 1;
      x_msg_data := FND_MESSAGE.GET;
      code_debug(' Exception in '||l_api_name||' : ' ||x_msg_data );
END Change_Item_Lifecycle;

------------------------------------------------------------------------------
  -- Start OF comments
  -- API name  : Change_Item_Catalog
  -- TYPE      : Public
  -- Pre-reqs  : None
  -- PROCEDURE : Changes Item(including child org item) catalog category.
  --             In effect, it will update the items lifecycle-phase-status.
  --             Org-Status profile is not honoured. Changes Items rev life
  --             cycle-phase if the current doesnt lie in new catalog heircy
  --             API doesnt validate the ID's passed.(Since gets ID's from UI)
------------------------------------------------------------------------------
Procedure Change_Item_Catalog(
  P_INVENTORY_ITEM_ID           IN   NUMBER,
  P_ORGANIZATION_ID             IN   NUMBER,
  P_CATALOG_GROUP_ID            IN   NUMBER,
  P_NEW_CATALOG_GROUP_ID        IN   NUMBER,
  P_NEW_LIFECYCLE_ID            IN   NUMBER,
  P_NEW_PHASE_ID                IN   NUMBER,
  P_NEW_ITEM_STATUS_CODE        IN   VARCHAR2,
  P_NEW_APPROVAL_STATUS         IN   VARCHAR2 DEFAULT NULL,
  P_COMMIT                      IN   VARCHAR2,
  X_RETURN_STATUS               OUT  NOCOPY VARCHAR2,
  X_MSG_COUNT                   OUT  NOCOPY NUMBER,
  X_MSG_DATA                    OUT  NOCOPY VARCHAR2 ) IS

  CURSOR c_get_item_details(cp_item_id NUMBER) IS
    SELECT rowid,
           organization_id,
           lifecycle_id,
           current_phase_id,
           inventory_item_status_code,
           concatenated_segments, --added for business events.
           description
    FROM   mtl_system_items_kfv
    WHERE  inventory_item_id = cp_item_id;

  CURSOR c_get_revisions(cp_org_id  NUMBER,
                         cp_item_id NUMBER) IS
    SELECT rowid,
           revision, --3031284
           lifecycle_id,
     current_phase_id
    FROM   mtl_item_revisions_b
    WHERE  organization_id   = cp_org_id
    AND    inventory_item_id = cp_item_id
    AND    lifecycle_id      IS NOT NULL
    FOR UPDATE OF lifecycle_id,current_phase_id;

  CURSOR c_get_master_org_details (cp_org_id IN NUMBER) IS
    SELECT organization_id
      FROM mtl_parameters
     WHERE organization_id = master_organization_id
       and organization_id = NVL(cp_org_id, organization_id);

/* Bug: 3007563
  CURSOR c_lost_catalogs(cp_old_id NUMBER,
                         cp_new_id NUMBER) IS
    SELECT item_catalog_group_id
    FROM ((SELECT  item_catalog_group_id
           FROM    mtl_item_catalog_groups_b
     CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
     START   WITH item_catalog_group_id = cp_old_id)
     MINUS
           (SELECT  item_catalog_group_id
           FROM    mtl_item_catalog_groups_b
     CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
     START   WITH item_catalog_group_id = cp_new_id));

 */

  l_ret_success     CONSTANT    VARCHAR2(1)  :=  FND_API.g_RET_STS_SUCCESS;     --'S'
  l_ret_error       CONSTANT    VARCHAR2(1)  :=  FND_API.g_RET_STS_ERROR;       --'E'
  l_ret_unexp_error CONSTANT    VARCHAR2(1)  :=  FND_API.g_RET_STS_UNEXP_ERROR; --'U'

  l_change                      BOOLEAN      := FALSE;
  l_organization_id             NUMBER;
  l_api_name                    VARCHAR2(30);
  --Start 4105841
  l_msg_data            VARCHAR2(4000);
  l_event_ret_status    VARCHAR2(1);
  l_org_code            MTL_PARAMETERS.ORGANIZATION_CODE%TYPE;
  l_item_number         mtl_system_items_kfv.CONCATENATED_SEGMENTS%TYPE;
  l_item_desc           mtl_system_items_kfv.DESCRIPTION%TYPE;
  -- End 4105841
BEGIN
  l_api_name := 'Change_Item_Catalog';
  code_debug(l_api_name||': Started ');
  code_debug(l_api_name||': p_inventory_item_id: '||to_char(p_inventory_item_id)||' p_organization_id: '||to_char(p_organization_id));
  code_debug(l_api_name||': p_catalog_group_id: '||to_char(p_catalog_group_id) ||' p_new_catalog_group_id:'|| to_char(P_NEW_CATALOG_GROUP_ID));
  code_debug(l_api_name||': p_new_lifecycle_id: '||to_char(p_new_lifecycle_id)||' p_new_phase_id: '||to_char(p_new_phase_id));
  code_debug(l_api_name||': P_NEW_ITEM_STATUS_CODE: '||P_NEW_ITEM_STATUS_CODE);

   IF FND_API.To_Boolean( p_commit ) THEN
      SAVEPOINT Change_Item_Catalog;
   END IF;
   x_return_status := l_ret_error;

   /* Commenting for the Bug 9094912
   IF NVL(p_catalog_group_id,-1) <> NVL(p_new_catalog_group_id,-1) THEN
     code_debug(l_api_name||': Changing Catalog Category ');
     l_organization_id := NULL;
   ELSE
      code_debug(l_api_name||': Changing Lifecycle ');
      l_organization_id := p_organization_id;
   END IF; */

   FOR cr in c_get_master_org_details (p_organization_id) LOOP /* Bug 9094912. Chaging l_organization_id to p_organization_id. */
      code_debug(l_api_name||': Calling Change Item Lifecycle with organization_id '||to_char(cr.organization_id));
      Change_Item_Lifecycle(
         p_inventory_item_id    => p_inventory_item_id,
         p_organization_id      => cr.organization_id,
         p_new_catalog_category_id     => p_new_catalog_group_id,
         p_new_lifecycle_id     => p_new_lifecycle_id,
         p_new_phase_id         => p_new_phase_id,
         p_new_item_status_code => p_new_item_status_code,
         p_commit               => FND_API.G_FALSE,
         x_return_status        => x_return_status,
         x_msg_data             => x_msg_data,
         x_msg_count            => x_msg_count);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RETURN;
      END IF;
   END LOOP;

   /* Bug 9094912. Changing the WHERE clause so that ICC will be changed for only one Master Organization including its Child Organizations. */
   IF NVL(p_catalog_group_id,-1) <> NVL(p_new_catalog_group_id,-1) THEN
      UPDATE mtl_system_items_b
      SET    item_catalog_group_id = DECODE(p_new_catalog_group_id,-1,NULL,p_new_catalog_group_id)
      WHERE  inventory_item_id     = p_inventory_item_id
      AND    organization_id IN (SELECT organization_id FROM mtl_parameters WHERE master_organization_id=p_organization_id);

-- Bug: 3072079 Added code to update descriptive values of new item catalog group for an item
      INVIDIT2.Match_Catalog_Descr_Elements (p_inventory_item_id, p_new_catalog_group_id);

--Bug: 3007563 Modified all the delete statements.
--      FOR catalog_record IN c_lost_catalogs(p_catalog_group_id,p_new_catalog_group_id)
--      LOOP

        --Delete AG which doesnt fall under new catalog hierarchy.
        DELETE ego_mtl_sy_items_ext_b ext
  WHERE  inventory_item_id     = p_inventory_item_id
  AND    organization_id IN (SELECT organization_id FROM mtl_parameters WHERE master_organization_id=p_organization_id) /* Changed WHERE clause for the Bug 9094912 */
  AND    EXISTS (SELECT NULL
                 FROM   ego_obj_attr_grp_assocs_v
           WHERE  attr_group_id = ext.attr_group_id
           AND    classification_code IN
                     (SELECT  to_char(item_catalog_group_id)
                                  FROM    mtl_item_catalog_groups_b
                            CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
                            START   WITH item_catalog_group_id = p_catalog_group_id))
        AND NOT EXISTS (SELECT NULL
                  FROM   ego_obj_attr_grp_assocs_v
            WHERE  attr_group_id = ext.attr_group_id
            AND    classification_code IN
                      (SELECT  to_char(item_catalog_group_id)
                                   FROM    mtl_item_catalog_groups_b
                             CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
                             START   WITH item_catalog_group_id = p_new_catalog_group_id));

        DELETE ego_mtl_sy_items_ext_tl extl
  WHERE  inventory_item_id     = p_inventory_item_id
  AND    organization_id IN (SELECT organization_id FROM mtl_parameters WHERE master_organization_id=p_organization_id) /* Changed WHERE clause for the Bug 9094912 */
  AND    EXISTS (SELECT NULL
                 FROM   ego_obj_attr_grp_assocs_v
           WHERE  attr_group_id = extl.attr_group_id
           AND    classification_code IN
                     (SELECT  to_char(item_catalog_group_id)
                                  FROM    mtl_item_catalog_groups_b
                            CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
                            START   WITH item_catalog_group_id = p_catalog_group_id))
        AND NOT EXISTS (SELECT NULL
                 FROM   ego_obj_attr_grp_assocs_v
           WHERE  attr_group_id = extl.attr_group_id
                 AND    classification_code IN
                     (SELECT  to_char(item_catalog_group_id)
                                  FROM    mtl_item_catalog_groups_b
                            CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
                            START   WITH item_catalog_group_id = p_new_catalog_group_id));

        --Update valid AG to point to new catalog group
        UPDATE ego_mtl_sy_items_ext_b
  SET    item_catalog_group_id = p_new_catalog_group_id
        WHERE  inventory_item_id     = p_inventory_item_id
	AND    organization_id IN (SELECT organization_id FROM mtl_parameters WHERE master_organization_id=p_organization_id); /* Changed WHERE clause for the Bug 9094912 */

        UPDATE ego_mtl_sy_items_ext_tl
  SET    item_catalog_group_id = p_new_catalog_group_id
        WHERE  inventory_item_id     = p_inventory_item_id
	AND    organization_id IN (SELECT organization_id FROM mtl_parameters WHERE master_organization_id=p_organization_id); /* Changed WHERE clause for the Bug 9094912 */

        --Delete attachments which doesnt fall under new catalog hierarchy.
  DELETE fnd_attached_documents docs
  WHERE  pk2_value = to_char(p_inventory_item_id)
  AND    pk1_value IN (SELECT to_Char(organization_id) FROM mtl_parameters WHERE master_organization_id=p_organization_id) /* Changed WHERE clause for the Bug 9094912 */
  AND    entity_name IN ('MTL_ITEM_REVISIONS','MTL_SYSTEM_ITEMS')
  AND    EXISTS (SELECT NULL
                 FROM   ego_objtype_attach_cats
                 WHERE  attach_category_id  = docs.category_id
           AND classification_code IN
                  (SELECT  to_char(item_catalog_group_id)
                               FROM    mtl_item_catalog_groups_b
                         CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
                         START   WITH item_catalog_group_id = p_catalog_group_id))
        AND NOT EXISTS (SELECT NULL
                 FROM   ego_objtype_attach_cats
           WHERE  attach_category_id  = docs.category_id
           AND  classification_code IN
                   (SELECT  to_char(item_catalog_group_id)
                                FROM    mtl_item_catalog_groups_b
                          CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
                          START   WITH item_catalog_group_id = p_new_catalog_group_id));

  --    END LOOP;

  --Bug 5220298 Begin
  IF P_NEW_APPROVAL_STATUS IS NOT NULL
  THEN
  --{
      UPDATE MTL_SYSTEM_ITEMS_B
      SET APPROVAL_STATUS = p_new_approval_status
      WHERE INVENTORY_ITEM_ID = p_inventory_item_id
        AND ORGANIZATION_ID = p_organization_id;
  --}
  END IF;
  --Bug 5220298 End

     --Start 4105841 Raise the event for the organizations to which item is assigned.
     --Raise only for the master item
       SELECT ORGANIZATION_CODE INTO l_org_code
       FROM MTL_PARAMETERS
       WHERE ORGANIZATION_ID = p_organization_id;
     --Added for Bug 4586769
       SELECT CONCATENATED_SEGMENTS, DESCRIPTION
         INTO l_item_number, l_item_desc
	 FROM mtl_system_items_kfv
	WHERE inventory_item_id = p_inventory_item_id
	  AND organization_id   = p_organization_id;

       EGO_WF_WRAPPER_PVT.Raise_Item_Create_Update_Event(
                       p_event_name         =>  EGO_WF_WRAPPER_PVT.G_ITEM_UPDATE_EVENT
                      ,p_Inventory_Item_Id  =>  p_inventory_item_id
                      ,p_Organization_Id    =>  p_Organization_Id
                      ,p_organization_code  =>  l_org_code
                      ,p_item_number        =>  l_item_number
                      ,p_item_description   =>  l_item_desc
                      ,x_msg_data           =>  l_msg_data
                      ,x_return_status      =>  l_event_ret_status
                       );
     --End 4105841
     --Call ICX APIs
     BEGIN
        INV_ITEM_EVENTS_PVT.Invoke_ICX_APIs(
           p_entity_type       => 'ITEM'
          ,p_dml_type          => 'UPDATE'
          ,p_inventory_item_id => p_inventory_item_id
          ,p_organization_id   => p_Organization_Id
          ,p_organization_code => l_org_code );
        EXCEPTION
           WHEN OTHERS THEN
              NULL;
     END;
     --R12: Business Event Enhancement

   END IF;

/***
   IF x_return_status = l_ret_success THEN

      FOR Item_Record IN c_get_item_details(p_inventory_item_id) LOOP
         --Update revisions lifecycle-phase to null
         --if existing lifecyle is not valid under new catalog.
         FOR revision_record IN c_get_revisions
                                 (cp_org_id  => Item_Record.organization_id,
                cp_item_id => p_inventory_item_id)
         LOOP
            l_change := INV_EGO_REVISION_VALIDATE.Check_LifeCycle
                       (p_catalog_group_id => p_new_catalog_group_id
                       ,p_lifecycle_id     => revision_record.lifecycle_id);
            IF NOT l_change THEN
         UPDATE mtl_item_revisions_b
         SET lifecycle_id     = NULL,
             current_phase_id = NULL
         WHERE rowid = revision_record.rowid;

               -- Start 3031284
               DELETE  EGO_ITEM_PROJECTS
               WHERE  INVENTORY_ITEM_ID = p_inventory_item_id
         AND    REVISION          = revision_record.revision
         AND    ORGANIZATION_ID   = Item_Record.organization_id
               AND    ASSOCIATION_TYPE  = 'EGO_ITEM_PROJ_ASSOC_TYPE'
               AND    ASSOCIATION_CODE  = 'LIFECYCLE_TRACKING' ;
         -- End 3031284

      END IF;

         END LOOP; -- revision_record

      END LOOP; --Item Record Loop

      x_return_status := l_ret_success;
   ELSE
     RETURN;
   END IF;
***/
   IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
    INV_ITEM_PVT.SYNC_IM_INDEX; --3026311 Sync iM index

     -- Call IP Intermedia Sync
    INV_ITEM_EVENTS_PVT.Sync_IP_IM_Index;

   END IF;
  code_debug(l_api_name||': Bye Bye ');
EXCEPTION
   WHEN OTHERS THEN
      IF FND_API.To_Boolean( p_commit ) THEN
         ROLLBACK TO Change_Item_Catalog;
      END IF;
      IF c_get_item_details%ISOPEN THEN
        CLOSE c_get_item_details;
      END IF;
      IF c_get_revisions%ISOPEN THEN
        CLOSE c_get_revisions;
      END IF;
      IF c_get_master_org_details%ISOPEN THEN
        CLOSE c_get_master_org_details;
      END IF;
      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.Set_Name(G_APP_NAME, G_PLSQL_ERR);
      FND_MESSAGE.Set_Token(G_PKG_NAME_TOKEN, G_PKG_NAME);
      FND_MESSAGE.Set_Token(G_API_NAME_TOKEN, l_api_name);
      FND_MESSAGE.Set_Token(G_SQL_ERR_MSG_TOKEN, SQLERRM);
      x_msg_count := 1;
      x_msg_data := FND_MESSAGE.GET;
      code_debug(' Exception in '||l_api_name||' : ' ||x_msg_data );
END Change_Item_Catalog;


------------------------------------------------------------------------------
  -- Start OF comments
  -- API name  : Validate_And_Change_Item_LC
  -- TYPE      : Public
  -- Pre-reqs  : None
  -- PROCEDURE : To validate and change the lifecycle dependencies
  -- Remarks   : Created as a part of bug 3637854
  -----------------------------------------------------------------------------
Procedure Validate_And_Change_Item_LC (
    p_api_version          IN   NUMBER
   ,p_commit               IN   VARCHAR2
   ,p_inventory_item_id    IN   NUMBER
   ,p_item_revision_id     IN   NUMBER
   ,p_organization_id      IN   NUMBER
   ,p_fetch_curr_values    IN   VARCHAR2
   ,p_curr_cc_id           IN   NUMBER
   ,p_new_cc_id            IN   NUMBER
   ,p_is_new_cc_in_hier    IN   VARCHAR2
   ,p_curr_lc_id           IN   NUMBER
   ,p_new_lc_id            IN   NUMBER
   ,p_curr_lcp_id          IN   NUMBER
   ,p_new_lcp_id           IN   NUMBER
   ,p_change_id            IN   NUMBER
   ,p_change_line_id       IN   NUMBER
   ,x_return_status      OUT  NOCOPY  VARCHAR2
   ,x_msg_count          OUT  NOCOPY  NUMBER
   ,x_msg_data           OUT  NOCOPY  VARCHAR2
) IS

  CURSOR c_get_curr_item_val (cp_item_id  IN  NUMBER
                             ,cp_org_id   IN  NUMBER) IS
  SELECT item_catalog_group_id, lifecycle_id, current_phase_id
  FROM  mtl_system_items_b
  WHERE inventory_item_id = cp_item_id
  AND organization_id = cp_org_id;

  -- bug: 3802017
  -- get curr catalog id from item and lifecycle and phase from item
  -- if not defined at revision
  CURSOR c_get_curr_rev_val (cp_item_id  IN  NUMBER
                            ,cp_org_id   IN  NUMBER
                            ,cp_rev_id   IN  NUMBER) IS
  SELECT itm.item_catalog_group_id, NVL(rev.lifecycle_id,itm.lifecycle_id) lifecycle_id,
         NVL(rev.current_phase_id,itm.current_phase_id) current_phase_id
  FROM  mtl_system_items_b itm, mtl_item_revisions_b rev
  WHERE rev.inventory_item_id = cp_item_id
  AND rev.organization_id = cp_org_id
  AND rev.revision_id = cp_rev_id
  AND itm.inventory_item_id = rev.inventory_item_id
  AND itm.organization_id = rev.organization_id;

  CURSOR c_check_cc_hier (cp_curr_cc_id  IN  NUMBER
                         ,cp_new_cc_id   IN  NUMBER) IS
  SELECT item_catalog_group_id
  FROM  mtl_item_catalog_groups
  WHERE item_catalog_group_id = cp_curr_cc_id
  AND item_catalog_group_id  IN
    (SELECT item_catalog_group_id
     FROM  mtl_item_catalog_groups
     CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
     START WITH item_catalog_group_id = cp_new_cc_id
    );

  l_api_version        NUMBER;
  l_api_name           VARCHAR2(30);
  l_null_id_value      NUMBER;
  l_dummy_id_value     NUMBER;

  l_validate           BOOLEAN;
  l_new_cc_in_hier     BOOLEAN;

  l_new_cc_id          NUMBER;
  l_curr_cc_id         NUMBER;
  l_curr_lc_id         NUMBER;
  l_curr_lcp_id        NUMBER;
  l_curr_rev_lc_id     NUMBER;
  l_curr_rev_lcp_id    NUMBER;
  l_lc_changed         VARCHAR2(30);
  l_lcp_changed        VARCHAR2(30);
  l_perform_sync_only  VARCHAR2(30);

BEGIN
  l_api_version   := 1.0;
  l_api_name      := 'Validate_And_Change_Item_LC';
  l_lc_changed    := FND_API.G_FALSE;
  l_lcp_changed   := FND_API.G_FALSE;
  l_perform_sync_only   := FND_API.G_FALSE;
  l_null_id_value := FND_API.G_MISS_NUM;

  code_debug(l_api_name||': Started with parameters ');
  code_debug('  p_api_version : '||p_api_version||' p_commit : '|| p_commit);
  code_debug('  p_inventory_item_id :'||p_inventory_item_id||' p_item_revision_id : '|| p_item_revision_id||' p_organization_id : '|| p_organization_id);
  code_debug('  p_fetch_curr_values : '||p_fetch_curr_values||' p_curr_cc_id : '|| p_curr_cc_id ||' p_new_cc_id : '|| p_new_cc_id);
  code_debug('  p_is_new_cc_in_hier : '|| p_is_new_cc_in_hier ||' p_curr_lc_id: '|| p_curr_lc_id ||' p_new_lc_id : '|| p_new_lc_id);
  code_debug('  p_curr_lcp_id : '|| p_curr_lcp_id ||' p_new_lcp_id: '|| p_new_lcp_id ||' p_change_id : '|| p_change_id);

  --Standard checks
  IF NOT FND_API.Compatible_API_Call (l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,g_pkg_name)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.To_Boolean( p_commit ) THEN
    SAVEPOINT Validate_And_Change_Item_LC_SP;
  END IF;

  IF FND_API.TO_BOOLEAN(p_fetch_curr_values) THEN
    IF p_item_revision_id IS NULL THEN
      -- fetch from item
      OPEN c_get_curr_item_val (cp_item_id => p_inventory_item_id
                               ,cp_org_id => p_organization_id
                               );
      FETCH c_get_curr_item_val INTO l_curr_cc_id, l_curr_lc_id, l_curr_lcp_id;
      CLOSE c_get_curr_item_val;
    ELSE
      -- fetch from item revision
      OPEN c_get_curr_rev_val (cp_item_id => p_inventory_item_id
                              ,cp_org_id => p_organization_id
                              ,cp_rev_id => p_item_revision_id
                              );
      FETCH c_get_curr_rev_val INTO l_curr_cc_id, l_curr_rev_lc_id, l_curr_rev_lcp_id;
      CLOSE c_get_curr_rev_val;
    END IF;  -- p_item_revision_id IS NULL
  ELSE
    l_curr_cc_id   := p_curr_cc_id;
    l_curr_lc_id   := p_curr_lc_id;
    l_curr_lcp_id  := p_curr_lcp_id;
  END IF;

  -- bug: 3802017
  IF p_new_cc_id IS NULL AND p_new_lc_id IS NOT NULL AND p_new_lcp_id IS NOT NULL AND p_item_revision_id IS NOT NULL THEN
    -- in item revision context, take the cc as that of item.
    l_new_cc_id := l_curr_cc_id;
  ELSE
    l_new_cc_id := p_new_cc_id;
  END IF;

  code_debug(l_api_name||' values obtained after fetching the old values if reqd ');
  code_debug(l_api_name||'  curr_cc_id : '|| l_curr_cc_id ||' curr_lc_id : '|| l_curr_lc_id ||' curr_lcp_id : '|| l_curr_lcp_id);
  code_debug(l_api_name||'  new_cc_id  : '|| l_new_cc_id  ||' new_lc_id  : '|| p_new_lc_id  ||' new_lcp_id  : '|| p_new_lcp_id);

  IF  NVL(l_curr_cc_id,l_null_id_value) = NVL(l_new_cc_id,l_null_id_value)
      AND
      NVL(l_curr_lc_id,l_null_id_value) = NVL(p_new_lc_id,l_null_id_value)
      AND
      NVL(l_curr_lcp_id,l_null_id_value) = NVL(p_new_lcp_id,l_null_id_value) THEN
    -- none of the value are changed
    RETURN;
  END IF;

  l_validate     := FALSE;
  IF l_curr_cc_id IS NULL THEN
    --  item does not have an existing catalog category
    --  curr_cc_id IS NULL check
    IF l_new_cc_id IS NULL THEN
      -- perform no validations.
      -- user cannot associate any lifecycles.
      NULL;
    ELSE
      -- perform validations if lc is chosen
      code_debug(l_api_name||' validate item as CC has changed from null to NOT Null ');
      IF  NVL(l_curr_lc_id,l_null_id_value) <> NVL(p_new_lc_id,l_null_id_value) THEN
        l_validate    := TRUE;
        l_lc_changed  := FND_API.G_TRUE;
        l_lcp_changed := FND_API.G_TRUE;
      ELSE
        -- perform no validations.
        -- user
        NULL;
      END IF;
    END IF;
  ELSE    -- for curr_cc_id IS NOT NULL
    --  item has an existing catalog category
    IF p_new_lc_id IS NULL THEN
      IF l_new_cc_id IS NULL THEN
        code_debug(l_api_name||' validate item as CC has changed from ' ||l_curr_cc_id || ' TO '||l_new_cc_id||' and new LC id is null ');
        l_validate    := TRUE;
        l_lc_changed  := FND_API.G_TRUE;
        l_lcp_changed := FND_API.G_TRUE;
      ELSE
        -- catalog category is changed
        -- but no LC associated.  check hierarchy
        IF p_is_new_cc_in_hier = FND_API.G_TRUE THEN
          l_new_cc_in_hier := TRUE;
        ELSIF p_is_new_cc_in_hier = FND_API.G_FALSE THEN
          l_new_cc_in_hier := FALSE;
        ELSE
          OPEN c_check_cc_hier (cp_curr_cc_id => l_curr_cc_id
                               ,cp_new_cc_id => l_new_cc_id
                                );
          FETCH c_check_cc_hier INTO l_dummy_id_value;
          IF c_check_cc_hier%FOUND THEN
            l_new_cc_in_hier := TRUE;
          ELSE
            l_new_cc_in_hier := FALSE;
          END IF;
        END IF;  -- check for hierarchy ends
        -- decide based on hierarchy
        IF l_new_cc_in_hier THEN
          -- perform only sync
          IF  NVL(l_curr_lc_id,l_null_id_value) <> NVL(p_new_lc_id,l_null_id_value) THEN
            code_debug(l_api_name||' perform only sync as the lifecycle is changed to null ');
            l_validate          := TRUE;
            l_perform_sync_only := FND_API.G_TRUE;
          END IF;
        ELSE
          code_debug(l_api_name||' validate item as CC has changed from '|| l_curr_cc_id || ' TO '||l_new_cc_id||' and new LC id is null and CC not in hier');
          IF  NVL(l_curr_lc_id,l_null_id_value) <> NVL(p_new_lc_id,l_null_id_value) THEN
            l_validate    := TRUE;
            l_lc_changed  := FND_API.G_TRUE;
            l_lcp_changed := FND_API.G_TRUE;
          END IF;
        END IF;
      END IF; -- for l_new_cc_id IS NULL check
    ELSE  -- new lifecycle is chosen.
      code_debug(l_api_name||' validate item as LC has changed from '|| l_curr_lc_id || ' TO '|| p_new_lc_id);
      -- user has changed the lifecycle and catalog category
      l_validate    := TRUE;
      IF  NVL(l_curr_cc_id,l_null_id_value) = NVL(l_new_cc_id,l_null_id_value)
          AND
          NVL(l_curr_lc_id,l_null_id_value) = NVL(p_new_lc_id,l_null_id_value)
          AND
          NVL(l_curr_lcp_id,l_null_id_value) <> NVL(p_new_lcp_id,l_null_id_value) THEN
          l_lcp_changed := FND_API.G_TRUE;
      ELSE
          l_lc_changed  := FND_API.G_TRUE;
          l_lcp_changed := FND_API.G_TRUE;
      END IF;
    END IF; -- for new lc_id IS NOT NULL
  END IF; -- for curr_cc_id check end

  IF l_validate THEN
    Change_Item_LC_Dependecies(
                   p_api_version        => p_api_version
                  ,p_inventory_item_id  => p_inventory_item_id
                  ,p_organization_id    => p_organization_id
                  ,p_item_revision_id   => p_item_revision_id
                  ,p_lifecycle_id       => p_new_lc_id
                  ,p_lifecycle_phase_id => p_new_lcp_id
                  ,p_lifecycle_changed        => l_lc_changed
                  ,p_lifecycle_phase_changed  => l_lcp_changed
                  ,p_perform_sync_only        => l_perform_sync_only
                  ,p_new_cc_in_hier     => l_new_cc_in_hier   --Bug: 4060185
                  ,x_return_status      => x_return_status
                  ,x_msg_count          => x_msg_count
                  ,x_msg_data           => x_msg_data
     );
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
    END IF;
  END IF;   -- end l_validate

  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  code_debug(l_api_name||': Bye Bye ');

EXCEPTION
  WHEN OTHERS THEN
  IF FND_API.To_Boolean( p_commit ) THEN
    ROLLBACK TO Validate_And_Change_Item_LC_SP;
  END IF;
  IF c_get_curr_item_val%ISOPEN THEN
    CLOSE c_get_curr_item_val;
  END IF;
  IF c_get_curr_rev_val%ISOPEN THEN
    CLOSE c_get_curr_rev_val;
  END IF;
  IF c_check_cc_hier%ISOPEN THEN
    CLOSE c_check_cc_hier;
  END IF;
  x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MESSAGE.Set_Name(G_APP_NAME, G_PLSQL_ERR);
  FND_MESSAGE.Set_Token(G_PKG_NAME_TOKEN, G_PKG_NAME);
  FND_MESSAGE.Set_Token(G_API_NAME_TOKEN, l_api_name);
  FND_MESSAGE.Set_Token(G_SQL_ERR_MSG_TOKEN, SQLERRM);
  x_msg_count := 1;
  x_msg_data := FND_MESSAGE.GET;
  code_debug(' Exception in  Validate_And_Change_Item_LC : ' ||x_msg_data );

END Validate_And_Change_Item_LC;

------------------------------------------------------------------------------
  -- Start OF comments
  -- API name  : Change_Item_LC_Dependecies
  -- TYPE      : Public
  -- Pre-reqs  : None
  -- PROCEDURE : To change the lifecycle dependencies
  -- Remarks   : Created as a part of bug 3637854
  -----------------------------------------------------------------------------
Procedure Change_Item_LC_Dependecies (
     p_api_version          IN   NUMBER
    ,p_inventory_item_id    IN   NUMBER
    ,p_organization_id      IN   NUMBER
    ,p_item_revision_id     IN   NUMBER
    ,p_lifecycle_id         IN   NUMBER
    ,p_lifecycle_phase_id   IN   NUMBER
    ,p_lifecycle_changed        IN VARCHAR2
    ,p_lifecycle_phase_changed  IN VARCHAR2
    ,p_perform_sync_only        IN VARCHAR2
    ,p_new_cc_in_hier           IN BOOLEAN := FALSE  --Bug: 4060185
    ,x_return_status      OUT NOCOPY VARCHAR2
    ,x_msg_count          OUT NOCOPY NUMBER
    ,x_msg_data           OUT NOCOPY VARCHAR2
    ) IS

  CURSOR  c_check_item_proj_assocs (cp_item_id  IN  NUMBER
                                   ,cp_org_id   IN NUMBER
                                   )  IS
  SELECT organization_id
    FROM ego_item_projects item_proj
   WHERE inventory_item_id = cp_item_id
     AND EXISTS
          (SELECT P2.ORGANIZATION_ID
            FROM   MTL_PARAMETERS P1, MTL_PARAMETERS P2
            WHERE  P1.ORGANIZATION_ID = cp_org_id
            AND    P1.MASTER_ORGANIZATION_ID = P2.MASTER_ORGANIZATION_ID
      AND    P2.ORGANIZATION_ID = item_proj.organization_id
           )
--      AND revision IS NULL
      AND revision_id IS NULL
      AND association_type = 'EGO_ITEM_PROJ_ASSOC_TYPE'
      AND association_code = 'LIFECYCLE_TRACKING';

  CURSOR  c_check_rev_proj_assocs (cp_item_id  IN  NUMBER
                                  ,cp_org_id   IN NUMBER
                                  ,cp_rev_id   IN NUMBER
                                   )  IS
  SELECT organization_id
    FROM ego_item_projects rev_proj
   WHERE inventory_item_id = cp_item_id
     AND EXISTS
          (SELECT P2.ORGANIZATION_ID
            FROM   MTL_PARAMETERS P1, MTL_PARAMETERS P2
            WHERE  P1.ORGANIZATION_ID = cp_org_id
            AND    P1.MASTER_ORGANIZATION_ID = P2.MASTER_ORGANIZATION_ID
      AND    P2.ORGANIZATION_ID = rev_proj.organization_id
           )
--      AND EXISTS
--          (SELECT 'X'
--             FROM mtl_item_revisions_b
--       WHERE revision_id = cp_rev_id
--         AND revision = rev_proj.revision
--          )
      AND revision_id = cp_rev_id
      AND association_type = 'EGO_ITEM_PROJ_ASSOC_TYPE'
      AND association_code = 'LIFECYCLE_TRACKING';

  CURSOR  c_pending_phase_change (cp_item_id  IN  NUMBER
                                 ,cp_org_id   IN NUMBER
                                 ,cp_rev_id   IN NUMBER
                                 )  IS
  SELECT organization_id
    FROM mtl_pending_item_status mpis
    WHERE inventory_item_id = cp_item_id
      AND EXISTS
          (SELECT P2.ORGANIZATION_ID
            FROM   MTL_PARAMETERS P1, MTL_PARAMETERS P2
            WHERE  P1.ORGANIZATION_ID = cp_org_id
            AND    P1.MASTER_ORGANIZATION_ID = P2.MASTER_ORGANIZATION_ID
      AND    P2.ORGANIZATION_ID = mpis.organization_id
           )
      AND nvl(revision_id, -1) = nvl(cp_rev_id, nvl(revision_id,-1))
      AND pending_flag = 'Y'
      AND implemented_date IS NULL
      AND phase_id IS NOT NULL;

  l_organization_id   NUMBER;
  l_api_version       NUMBER;
  l_api_name          VARCHAR2(30);

BEGIN
  l_api_name      := 'Change_Item_LC_Dependecies';
  l_api_version   := 1.0;
  code_debug(l_api_name||': Started ');
  code_debug(l_api_name||': p_inventory_item_id: '||to_char(p_inventory_item_id)||' p_organization_id: '||to_char(p_organization_id));
  code_debug(l_api_name||': p_item_revision_id: '||to_char(p_item_revision_id));
  code_debug(l_api_name||': p_lifecycle_id: '||to_char(p_lifecycle_id)||' p_lifecycle_phase_id: '||to_char(p_lifecycle_phase_id));
  code_debug(l_api_name||': p_lifecycle_changed: '||p_lifecycle_changed||' p_lifecycle_phase_changed: '||p_lifecycle_phase_changed);

  --Standard checks
  IF NOT FND_API.Compatible_API_Call (l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,g_pkg_name)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF NOT( FND_API.To_Boolean(p_lifecycle_changed)
          OR
          FND_API.To_Boolean(p_lifecycle_phase_changed)
          OR
          FND_API.To_Boolean(p_perform_sync_only)
   ) THEN
    RETURN;
  END IF;
  --
  -- inv team wish to call only Sync on certain conditions
  -- instead of calling another procedure, then wish to have SYNC
  -- exposed from here only
  --
  IF  FND_API.To_Boolean(p_perform_sync_only) THEN
    code_debug(l_api_name||': calling Sync_Item_Revisions  using perform sync only ');
    Sync_Item_Revisions(
        p_inventory_item_id  => p_inventory_item_id
       ,p_organization_id    => p_organization_id
       ,p_lifecycle_id       => p_lifecycle_id
       ,p_lifecycle_phase_id => p_lifecycle_phase_id
       ,p_validate_changes   => p_perform_sync_only
       ,p_new_cc_in_hier     => p_new_cc_in_hier  --Bug: 4060185
       ,x_return_status      => x_return_status
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
       );
    code_debug(l_api_name||': returning Sync_Item_Revisions perform sync only '|| x_return_status);
    RETURN;
  END IF;

  IF  ( NOT (FND_API.to_boolean(p_lifecycle_changed))
        AND
        FND_API.to_boolean(p_lifecycle_phase_changed)
      ) THEN
    --
    -- check if there are any project associations
    --
    code_debug(l_api_name||': checking for any projet associations ');
    l_organization_id := NULL;
    IF p_item_revision_id IS NULL THEN
      OPEN c_check_item_proj_assocs (cp_item_id => p_inventory_item_id
                                    ,cp_org_id  => p_organization_id
                                    );
      FETCH c_check_item_proj_assocs INTO l_organization_id;
      CLOSE c_check_item_proj_assocs;
    ELSE
      OPEN c_check_rev_proj_assocs (cp_item_id => p_inventory_item_id
                                   ,cp_org_id  => p_organization_id
                                   ,cp_rev_id  => p_item_revision_id
                                    );
      FETCH c_check_rev_proj_assocs INTO l_organization_id;
      CLOSE c_check_rev_proj_assocs;
    END IF;  -- for item revision id found
    IF l_organization_id IS NOT NULL THEN
      --
      -- project association found
      --
      code_debug(l_api_name||': projet associations found ');
      Get_Error_msg(  p_inventory_item_id  => p_inventory_item_id
                     ,p_organization_id    => l_organization_id
                     ,p_item_revision_id   => p_item_revision_id
                     ,p_message_name       => 'EGO_ITEM_LC_PROJ_EXISTS'
                     ,x_return_status      => x_return_status
                     ,x_msg_count          => x_msg_count
                     ,x_msg_data           => x_msg_data
                     );
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RETURN;
        END IF;
      END IF;  -- project association found
  END IF; -- lifecycle phase only has changed.

  code_debug(l_api_name||': calling Checking Pending Phase Changes ');
  --
  -- check if there are any pending phase changes
  --
  OPEN c_pending_phase_change (cp_item_id => p_inventory_item_id
                              ,cp_org_id  => p_organization_id
                              ,cp_rev_id  => p_item_revision_id
                             );
  FETCH c_pending_phase_change INTO l_organization_id;
  IF c_pending_phase_change%FOUND THEN
    code_debug(l_api_name||': pending phase changes found ');
    CLOSE c_pending_phase_change;
    Get_Error_msg(p_inventory_item_id  => p_inventory_item_id
                 ,p_organization_id    => l_organization_id
                 ,p_item_revision_id   => p_item_revision_id
                 ,p_message_name       => 'EGO_ITEM_PENDING_REC_EXISTS'
                 ,x_return_status      => x_return_status
                 ,x_msg_count          => x_msg_count
                 ,x_msg_data           => x_msg_data
                 );
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
    END IF;
  ELSE
    CLOSE c_pending_phase_change;
  END IF;

  code_debug(l_api_name||': calling Check_Pending_Change_Orders');
  IF NOT p_new_cc_in_hier THEN  --Bug: 4060185
  Check_Pending_Change_Orders(
              p_inventory_item_id  => p_inventory_item_id
             ,p_organization_id    => p_organization_id
             ,p_revision_id        => p_item_revision_id
             ,p_lifecycle_changed        => p_lifecycle_changed
             ,p_lifecycle_phase_changed  => p_lifecycle_phase_changed
             ,p_change_id                => NULL
             ,p_change_line_id           => NULL
             ,x_return_status      => x_return_status
             ,x_msg_count          => x_msg_count
             ,x_msg_data           => x_msg_data
      );
   END IF;   --Bug: 4060185
  code_debug(l_api_name||': returning Check_Pending_Change_Orders with status '|| x_return_status);
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  IF (FND_API.To_Boolean(p_lifecycle_changed) AND p_item_revision_id IS NULL) THEN
        -- check for pending changes and remove the associated projects
        code_debug(l_api_name||': calling Sync_Item_Revisions LC of item has changed ');
        Sync_Item_Revisions (
             p_inventory_item_id  => p_inventory_item_id
            ,p_organization_id    => p_organization_id
            ,p_lifecycle_id       => p_lifecycle_id
            ,p_lifecycle_phase_id => p_lifecycle_phase_id
            ,p_validate_changes   => p_perform_sync_only
            ,p_new_cc_in_hier     => p_new_cc_in_hier --Bug: 4060185
            ,x_return_status      => x_return_status
            ,x_msg_count          => x_msg_count
            ,x_msg_data           => x_msg_data
            );
        code_debug(l_api_name||': returning Sync_Item_Revisions with status '|| x_return_status);
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RETURN;
        ELSE
          -- everything is fine
          -- delete the projects associated with the item.
          DELETE  EGO_ITEM_PROJECTS proj
           WHERE  inventory_item_id = p_inventory_item_id
--           AND    revision  IS NULL
           AND    revision_id  IS NULL
           AND    EXISTS
                   (SELECT 'X'
                    FROM   mtl_parameters p1, mtl_parameters p2
                    WHERE  p1.organization_id = p_organization_id
                    AND    p1.master_organization_id = p2.master_organization_id
                    AND    p2.organization_id = proj.organization_id
                    )
           AND    association_type  = 'EGO_ITEM_PROJ_ASSOC_TYPE'
           AND    association_code  = 'LIFECYCLE_TRACKING' ;
        END IF;
  END IF; -- lifecycle has changed

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  code_debug(l_api_name||': Bye Bye ');

EXCEPTION
  WHEN OTHERS THEN
    IF c_check_item_proj_assocs%ISOPEN THEN
      CLOSE c_check_item_proj_assocs;
    END IF;
    IF c_check_rev_proj_assocs%ISOPEN THEN
      CLOSE c_check_rev_proj_assocs;
    END IF;
    IF c_pending_phase_change%ISOPEN THEN
      CLOSE c_pending_phase_change;
    END IF;
    x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.Set_Name(G_APP_NAME, G_PLSQL_ERR);
    FND_MESSAGE.Set_Token(G_PKG_NAME_TOKEN, G_PKG_NAME);
    FND_MESSAGE.Set_Token(G_API_NAME_TOKEN, 'CHANGE_ITEM_LC_DEPENDENCIES');
    FND_MESSAGE.Set_Token(G_SQL_ERR_MSG_TOKEN, SQLERRM);
    x_msg_count := 1;
    x_msg_data := FND_MESSAGE.GET;
    code_debug(' Exception in  '||l_api_name ||': '||x_msg_data );
END Change_Item_LC_Dependecies;


  ------------------------------------------------------------------------------
  -- Start OF comments
  -- API name  : Create_phase_History_Record
  -- TYPE      : Public
  -- Pre-reqs  : None
  -- PROCEDURE : To check if there are any pending change orders
  -- Remarks   : Created as a part of bug 3637854
  -----------------------------------------------------------------------------

PROCEDURE Create_phase_History_Record (
   p_api_version              IN  NUMBER
  ,p_commit                   IN  VARCHAR2
  ,p_inventory_item_id        IN  NUMBER
  ,p_organization_id          IN  NUMBER
  ,p_revision_id              IN  NUMBER
  ,p_lifecycle_id             IN  VARCHAR2
  ,p_lifecycle_phase_id       IN  VARCHAR2
  ,p_item_status_code         IN  VARCHAR2
  ,x_return_status       OUT  NOCOPY  VARCHAR2
  ,x_msg_count           OUT  NOCOPY  NUMBER
  ,x_msg_data            OUT  NOCOPY  VARCHAR2
  ) IS

  l_user_id         NUMBER;
  l_sysdate         DATE;
  l_api_version     NUMBER;
  l_api_name        VARCHAR2(30);

BEGIN
  l_api_version   := 1.0;
  l_api_name    := 'Create_Phase_History_Record';
  --Standard checks
  code_debug(l_api_name||': Started ');
  IF NOT FND_API.Compatible_API_Call (l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,g_pkg_name)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.To_Boolean( p_commit ) THEN
    SAVEPOINT Create_Phase_History_SP;
  END IF;

  l_user_id    := FND_GLOBAL.User_Id;
  l_sysdate    := SYSDATE;
  INSERT INTO mtl_pending_item_status(
            inventory_item_id,
            organization_id,
            status_code,
            revision_id,
            effective_date,
            implemented_date,
            pending_flag,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            lifecycle_id,
            phase_id)
  VALUES(
            p_inventory_item_id,
            p_organization_id,
            p_item_status_code,
            p_revision_id,
            l_sysdate,
            l_sysdate,
            'N',
            l_sysdate,
            l_user_id,
            l_sysdate,
            l_user_id,
            p_lifecycle_id,
            p_lifecycle_phase_id);
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  code_debug(l_api_name||': Bye Bye ');
EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean( p_commit ) THEN
        ROLLBACK TO Create_Phase_History_SP;
      END IF;
      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.Set_Name(G_APP_NAME, G_PLSQL_ERR);
      FND_MESSAGE.Set_Token(G_PKG_NAME_TOKEN, G_PKG_NAME);
      FND_MESSAGE.Set_Token(G_API_NAME_TOKEN, 'CREATE_PHASE_HISTORY_RECORD');
      FND_MESSAGE.Set_Token(G_SQL_ERR_MSG_TOKEN, SQLERRM);
      x_msg_count := 1;
      x_msg_data := FND_MESSAGE.GET;
END Create_phase_History_Record;

------------------------------------------------------------------------------
  -- Start OF comments
  -- API name  : Check_pending_Change_Orders
  -- TYPE      : Public
  -- Pre-reqs  : None
  -- PROCEDURE : To check if there are any pending change orders
  -- Remarks   : Created as a part of bug 3637854
  -----------------------------------------------------------------------------

PROCEDURE Check_pending_Change_Orders (
   p_inventory_item_id        IN  NUMBER
  ,p_organization_id          IN  NUMBER
  ,p_revision_id              IN  NUMBER
  ,p_lifecycle_changed        IN  VARCHAR2
  ,p_lifecycle_phase_changed  IN  VARCHAR2
  ,p_change_id                IN  NUMBER
  ,p_change_line_id           IN  NUMBER
  ,x_return_status       OUT  NOCOPY  VARCHAR2
  ,x_msg_count           OUT  NOCOPY  NUMBER
  ,x_msg_data            OUT  NOCOPY  VARCHAR2
  ) IS

  CURSOR c_get_null_revisions (cp_item_id  IN  NUMBER
                              ,cp_org_id   IN  NUMBER) IS
  SELECT inventory_item_id, organization_id, revision_id
  FROM  mtl_item_revisions_b item_rev
  WHERE item_rev.inventory_item_id = cp_item_id
    AND EXISTS
             (SELECT 'X'
              FROM   mtl_parameters p1, mtl_parameters p2
              WHERE  p1.organization_id = cp_org_id
                AND  p1.master_organization_id = p2.master_organization_id
                AND  p2.organization_id = item_rev.organization_id
              )
    AND item_rev.lifecycle_id IS NULL
    AND item_rev.current_phase_id IS NULL;

  l_organization_id      NUMBER;
  l_revision_id          NUMBER;
  l_fetch_error_message  BOOLEAN;
  l_api_name             VARCHAR2(100);
  l_change_notice        VARCHAR2(100);
  l_change_line_id       NUMBER;
  l_dynamic_sql            VARCHAR2(32767);
  l_dyn_sql_pend_chg_rev   VARCHAR2(32767);
  TYPE DYNAMIC_CUR IS REF CURSOR;
  l_dynamic_cursor         DYNAMIC_CUR;

BEGIN
  l_api_name := 'Check_Pending_Change_Orders';
  l_fetch_error_message := FALSE;
  code_debug(l_api_name||':start ');
  code_debug(l_api_name||': p_inventory_item_id: '||to_char(p_inventory_item_id)||' p_organization_id: '||to_char(p_organization_id));
  code_debug(l_api_name||': p_revision_id: '||to_char(p_revision_id));
  code_debug(l_api_name||': p_lifecycle_changed: '||p_lifecycle_changed||' p_lifecycle_phase_changed: '||p_lifecycle_phase_changed);

  IF p_change_id IS NULL THEN
    IF p_change_line_id IS NOT NULL THEN
      --
      -- this should never occur
      --
      FND_MESSAGE.Set_Name(G_APP_NAME, 'EGO_PKG_MAND_VALUES_MISS');
      FND_MESSAGE.Set_Token('PACKAGE', G_PKG_NAME||l_api_name);
      FND_MESSAGE.Set_Token('VALUE1', 'CHECK_ID');
      FND_MESSAGE.Set_Token('VALUE2', 'CHANGE_LINE_ID');
      x_msg_count := 1;
      x_msg_data := FND_MESSAGE.GET;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
    l_change_notice := FND_API.G_MISS_CHAR;
  ELSE
    -- 3878336 replacing the existing cursor with dynamic query
    l_dynamic_sql := 'SELECT change_notice FROM eng_engineering_changes WHERE change_id = :1' ;
    BEGIN
      OPEN l_dynamic_cursor FOR l_dynamic_sql USING p_change_id;
      FETCH l_dynamic_cursor INTO l_change_notice;
      CLOSE l_dynamic_cursor;
    EXCEPTION
      WHEN OTHERS THEN
            code_debug(l_api_name||': error1: ' || SQLERRM);
        if (l_dynamic_cursor%ISOPEN) then
          CLOSE l_dynamic_cursor;
        END IF;
    END;

  END IF;

  l_change_line_id := NVL(p_change_line_id,FND_API.G_MISS_NUM);
  l_revision_id    := p_revision_id;
  code_debug(l_api_name||': Change context passed -- change notice: '||l_change_notice ||' change line: '||l_change_line_id);

  -- 3878336 replacing the existing cursor with dynamic query
  l_dyn_sql_pend_chg_rev := ' SELECT organization_id FROM  eng_revised_items change ' ||
                            ' WHERE change.revised_item_id = :1 ' ||
                            ' AND change.organization_id = :2 ' ||
                            ' AND change.change_notice <> :3 ' ||
                            ' AND change.revised_item_sequence_id <> :4 ' ||
                            ' AND change.current_item_revision_id = :5 ' ||
                            ' AND change.status_type NOT IN (5, 6) ' ||
                            --bug 8254560 exclude checking of ECO with status type 'DRAFT' when item LC phase is changed
 	                             ' AND NOT EXISTS (SELECT ''X'' FROM ENG_ENGINEERING_CHANGES WHERE  STATUS_TYPE = 0 ' ||
 	                                         '               AND change_notice = change.change_notice   ' ||
 	                                         '               AND organization_id = change.organization_id ) ' ||

                            ' AND  ' ||
                            ' ( change.NEW_ITEM_REVISION_ID IS NOT null  ' || --this CO creates a revision
                            '   OR EXISTS ' ||
-- 4177523  DM changes through bug 4045666
-- from CM side to store the pending doc changes in eng_attachment_changes
--                            ' (SELECT ''X'' FROM  eng_attachment_changes ENG, fnd_attached_documents doc ' ||
--                            ' WHERE eng.revised_item_sequence_id = change.revised_item_sequence_id ' ||
--                            ' AND eng.attachment_id = doc.attached_document_id ' ||
--                            ' AND doc.entity_name = ''MTL_ITEM_REVISIONS'' AND doc.pk1_value = to_char(change.organization_id) ' ||
--                            ' AND doc.pk2_value = to_char(:6)  AND doc.pk3_value = to_char(:7)) ' ||
                            ' (SELECT ''X'' FROM  eng_attachment_changes ENG ' ||
                            ' WHERE eng.revised_item_sequence_id = change.revised_item_sequence_id ' ||
                            ' AND eng.entity_name = ''MTL_ITEM_REVISIONS'''||
                            ' AND eng.pk1_value = to_char(change.organization_id) ' ||
                            ' AND eng.pk2_value = to_char(:6)  '||
                            ' AND eng.pk3_value = to_char(:7)) ' ||
-- 4177523  DM changes through bug 4045666 added condition for structure changes
                            ' OR EXISTS ' ||
                            ' (SELECT ''X'' FROM  bom_components_b bom_comp '||
                            '  WHERE bom_comp.revised_item_sequence_id = change.revised_item_sequence_id '||
                            '  AND bom_comp.bill_sequence_id = change.bill_sequence_id '||
                            '  AND bom_comp.obj_name IS NULL '||
                            '  AND bom_comp.implementation_date IS NULL) '||
                            ' OR EXISTS ' ||
                            ' (SELECT ''X'' FROM  ego_items_attrs_changes_b attr_chg, ego_obj_ag_assocs_b assoc, fnd_objects obj ' ||
                            ' WHERE attr_chg.change_line_id = change.revised_item_sequence_id ' ||
                            -- 3710038 check for the attributes in the hierarchy
                            --          AND to_char(attr_chg.item_catalog_group_id) =  assoc.classification_code
                            ' AND assoc.classification_code IN ( ' ||
                            ' SELECT TO_CHAR(item_catalog_group_id)  FROM   mtl_item_catalog_groups_b ' ||
                            ' CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id ' ||
                            ' START WITH item_catalog_group_id = attr_chg.item_catalog_group_id ) ' ||
                            ' AND attr_chg.attr_group_id = assoc.attr_group_id ' ||
                            ' AND assoc.data_level = ''ITEM_REVISION_LEVEL'' AND assoc.enabled_flag = ''Y''' ||
                            ' AND assoc.object_id = obj.object_id AND obj.obj_name = ''EGO_ITEM'') ' ||
                            '        OR EXISTS                            ' || --this CO has Related Doc Change
                            '           (SELECT NULL ' ||
                            '              FROM  eng_relationship_changes ' ||
                            '             WHERE ENTITY_ID = change.revised_item_sequence_id  ' ||
                            '               AND change_id = change.change_id ' ||
                            '               AND ENTITY_NAME=''ITEM'' ' ||
                            '               AND FROM_ENTITY_NAME = ''EGO_ITEM_REVISION'' ) )';

  IF l_revision_id IS NOT NULL THEN
    IF FND_API.TO_BOOLEAN(p_lifecycle_phase_changed) THEN
      code_debug(l_api_name||': Validating only revision changes ');
      BEGIN
        code_debug(l_api_name||': executing l_dyn_sql_pend_chg_rev ');
        code_debug(l_api_name||': executing p_inventory_item_id ' || p_inventory_item_id);
        code_debug(l_api_name||': executing p_organization_id ' || p_organization_id);
        code_debug(l_api_name||': executing l_change_notice ' || l_change_notice);
        code_debug(l_api_name||': executing l_change_line_id ' || l_change_line_id);
        code_debug(l_api_name||': executing l_revision_id ' || l_revision_id);
        OPEN l_dynamic_cursor FOR l_dyn_sql_pend_chg_rev USING  p_inventory_item_id,
                                                                p_organization_id,
                                                                l_change_notice,
                                                                l_change_line_id,
                                                                l_revision_id,
                                                                p_inventory_item_id,
                                                                l_revision_id;
        LOOP
          FETCH l_dynamic_cursor INTO l_organization_id;
          EXIT WHEN l_dynamic_cursor%NOTFOUND;
           IF l_dynamic_cursor%FOUND THEN
             code_debug(l_api_name||': Validating only revision changes FOUND ');
             l_fetch_error_message := TRUE;
           ELSE
             code_debug(l_api_name||': Validating only revision changes NOT FOUND ');
           END IF;
        END LOOP;
        CLOSE l_dynamic_cursor;
      EXCEPTION
        WHEN OTHERS THEN
          code_debug(l_api_name||': error2: ' || SQLERRM);
          if (l_dynamic_cursor%ISOPEN) then
            CLOSE l_dynamic_cursor;
          END IF;
      END;
    ELSE
      -- you cannot send revision and say lifecycle phase changed
      -- lifecycle change is implemented through the item and not revision.
      code_debug(l_api_name||': Returning as you cannot change lifecycle of item revision ');
      RETURN;
    END IF;
  ELSE

    -- changes are at item level
    IF FND_API.TO_BOOLEAN(p_lifecycle_changed) THEN
      -- changing item lc
      code_debug(l_api_name||': Validating all item changes ');
      -- 3878336 replacing the existing cursor with dynamic query
      l_dynamic_sql := 'SELECT organization_id ' ||
                       'FROM  eng_revised_items change  ' ||
                       'WHERE revised_item_id = :1' ||
                       'AND change_notice <>  :2'||
                       'AND revised_item_sequence_id <> :3' ||
                       'AND EXISTS ' ||
                       ' (SELECT ''X'' FROM   mtl_parameters p1, mtl_parameters p2 ' ||
                       ' WHERE  p1.organization_id = :4 ' ||
                       ' AND  p1.master_organization_id = p2.master_organization_id ' ||
                       ' AND  p2.organization_id = change.organization_id )' ||
                       ' AND status_type NOT IN (5,6) ' ||
                       ' AND ' ||
                       ' ( EXISTS  ' ||
                       ' (SELECT ''X''  FROM  ego_mfg_part_num_chgs ' ||
                       ' WHERE change_line_id = change.revised_item_sequence_id ) ' ||
                       ' OR EXISTS ' ||
                       ' (SELECT ''X'' FROM  eng_attachment_changes ' ||
                       ' WHERE revised_item_sequence_id = change.revised_item_sequence_id) ' ||
                       ' OR EXISTS ' ||
                       ' (SELECT ''X'' FROM  ego_items_attrs_changes_b attr_chg ' ||
                       ' WHERE change_line_id = change.revised_item_sequence_id ) ' ||
                       '               OR EXISTS                             ' || --this CO has Operational Attribute Change
                       '                  (SELECT NULL ' ||
                       '                     FROM  ego_mtl_sy_items_chg_b ' ||
                       '                    WHERE change_line_id = change.revised_item_sequence_id  ' ||
                       '                      AND change_id = change.change_id) ' ||
                       '               OR EXISTS                             ' || --this CO has GTIN Single Change
                       '                  (SELECT NULL ' ||
                       '                     FROM  ego_gtn_attr_chg_b ' ||
                       '                    WHERE change_line_id = change.revised_item_sequence_id  ' ||
                       '                      AND change_id = change.change_id) ' ||
                       '               OR EXISTS                             ' || --this CO has GTIN Multi Change
                       '                  (SELECT NULL ' ||
                       '                     FROM  ego_gtn_mul_attr_chg_b ' ||
                       '                   WHERE change_line_id = change.revised_item_sequence_id  ' ||
                       '                     AND change_id = change.change_id) ' ||
                       '               OR EXISTS                             ' || --this CO has Related Doc Change
                       '                  (SELECT NULL ' ||
                       '                     FROM  eng_relationship_changes ' ||
                       '                    WHERE ENTITY_ID = change.revised_item_sequence_id  ' ||
                       '                      AND change_id = change.change_id ' ||
                       '                      AND ENTITY_NAME=''ITEM'') ' ||
                       '               OR EXISTS                            ' || --this CO has Structure Changes
                       '                  (SELECT NULL ' ||
                       '                     FROM bom_components_b ' ||
                       '                    WHERE revised_item_sequence_id = change.revised_item_sequence_id) ) ';

      BEGIN
        code_debug(l_api_name||': Executing l_dynamic_sql 1 ');
        code_debug(l_api_name||': executing p_inventory_item_id ' || p_inventory_item_id);
        code_debug(l_api_name||': executing l_change_notice ' || l_change_notice);
        code_debug(l_api_name||': executing l_change_line_id ' || l_change_line_id);
        code_debug(l_api_name||': executing p_organization_id ' || p_organization_id);
        OPEN l_dynamic_cursor FOR l_dynamic_sql USING p_inventory_item_id, l_change_notice, l_change_line_id, p_organization_id;
        LOOP
          FETCH l_dynamic_cursor INTO l_organization_id;
          EXIT WHEN l_dynamic_cursor%NOTFOUND;
           IF l_dynamic_cursor%FOUND THEN
             code_debug(l_api_name||': Validating all item changes FOUND ');
             l_fetch_error_message := TRUE;
           ELSE
             code_debug(l_api_name||': Validating all item changes NOT FOUND ');
           END IF;
        END LOOP;
        CLOSE l_dynamic_cursor;
      EXCEPTION
        WHEN OTHERS THEN
          code_debug(l_api_name||': error3: ' || SQLERRM);
          if (l_dynamic_cursor%ISOPEN) then
            CLOSE l_dynamic_cursor;
          end if;
      END;
    ELSIF FND_API.TO_BOOLEAN(p_lifecycle_phase_changed) THEN
      -- check if there are any pending change
      -- associated with the item revision that is NULL
      code_debug(l_api_name||': Validating only item phase changes ');
      -- 3878336 replacing the existing cursor with dynamic query
      l_dynamic_sql := ' SELECT organization_id FROM  eng_revised_items change ' ||
                       ' WHERE change.revised_item_id = :1 ' ||
                       ' AND change.change_notice <> :2 ' ||
                       ' AND change.revised_item_sequence_id <> :3 ' ||
                       ' AND EXISTS ' ||
                       ' (SELECT ''X'' FROM   mtl_parameters p1, mtl_parameters p2 ' ||
                       ' WHERE  p1.organization_id = :4 ' ||
                       ' AND  p1.master_organization_id = p2.master_organization_id ' ||
                       ' AND  p2.organization_id = change.organization_id ' ||
                       '  )  ' ||
                       ' AND change.status_type NOT IN (5, 6 ) ' ||
                       --bug 8254560 exclude checking of ECO with status type 'DRAFT' when item LC phase is changed
 	                        ' AND NOT EXISTS (SELECT ''X'' FROM ENG_ENGINEERING_CHANGES WHERE  STATUS_TYPE = 0 ' ||
 	                        '               AND change_notice = change.change_notice   ' ||
 	                        '               AND organization_id = change.organization_id ) ' ||
                       ' AND (  ' ||
                       ' EXISTS  (SELECT ''X'' FROM  ego_mfg_part_num_chgs ' ||
                       ' WHERE change_line_id = change.revised_item_sequence_id ' ||
                       ' )  OR  EXISTS ' ||
-- 4177523  DM changes through bug 4045666
-- from CM side to store the pending doc changes in eng_attachment_changes
--                       ' (SELECT ''X'' FROM  eng_attachment_changes ENG, fnd_attached_documents doc ' ||
--                       ' WHERE eng.revised_item_sequence_id = change.revised_item_sequence_id ' ||
--                       ' AND eng.attachment_id = doc.attached_document_id ' ||
--                       ' AND doc.entity_name = ''MTL_SYSTEM_ITEMS''  ' ||
--                       ' AND doc.pk1_value = to_char(change.organization_id) ' ||
--                       ' AND doc.pk2_value = to_char(:5) ' ||
                       ' (SELECT ''X'' FROM  eng_attachment_changes ENG ' ||
                       ' WHERE eng.revised_item_sequence_id = change.revised_item_sequence_id ' ||
                       ' AND eng.entity_name = ''MTL_SYSTEM_ITEMS'' ' ||
                       ' AND eng.pk1_value = to_char(change.organization_id) ' ||
                       ' AND eng.pk2_value = to_char(:5) ' ||
                       ' ) OR EXISTS ' ||
                       ' (SELECT ''X'' FROM  ego_items_attrs_changes_b attr_chg, ego_obj_ag_assocs_b assoc, fnd_objects obj ' ||
                       ' WHERE attr_chg.change_line_id = change.revised_item_sequence_id ' ||
                        -- 3710038 check for the attributes in the hierarchy
                        --           AND to_char(attr_chg.item_catalog_group_id) =  assoc.classification_code
                       ' AND assoc.classification_code IN (' ||
                       '   SELECT TO_CHAR(item_catalog_group_id) FROM   mtl_item_catalog_groups_b ' ||
                       '    CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id ' ||
                       '    START WITH item_catalog_group_id = attr_chg.item_catalog_group_id ) ' ||
                       '    AND attr_chg.attr_group_id = assoc.attr_group_id ' ||
                       '    AND assoc.data_level = ''ITEM_LEVEL'' AND assoc.object_id = obj.object_id ' ||
                       '    AND obj.obj_name = ''EGO_ITEM'' AND assoc.enabled_flag = ''Y'' ) ' ||
                       '               OR EXISTS                            ' || --this CO has Operational Attribute Change
                       '                  (SELECT NULL ' ||
                       '                     FROM  ego_mtl_sy_items_chg_b ' ||
                       '                    WHERE change_line_id = change.revised_item_sequence_id  ' ||
                       '                      AND change_id = change.change_id) ' ||
                       '               OR EXISTS                            ' || --this CO has GTIN Single Change
                       '                  (SELECT NULL ' ||
                       '                     FROM  ego_gtn_attr_chg_b ' ||
                       '                    WHERE change_line_id = change.revised_item_sequence_id  ' ||
                       '                      AND change_id = change.change_id) ' ||
                       '               OR EXISTS                            ' || --this CO has GTIN Multi Change
                       '                  (SELECT NULL ' ||
                       '                     FROM  ego_gtn_mul_attr_chg_b ' ||
                       '                   WHERE change_line_id = change.revised_item_sequence_id  ' ||
                       '                     AND change_id = change.change_id) ' ||
                       '               OR EXISTS                            ' || --this CO has Related Doc Change
                       '                  (SELECT NULL ' ||
                       '                     FROM  eng_relationship_changes ' ||
                       '                    WHERE ENTITY_ID = change.revised_item_sequence_id  ' ||
                       '                      AND change_id = change.change_id ' ||
                       '                      AND ENTITY_NAME=''ITEM'') ' ||
                       '               OR EXISTS                           ' || --this CO has Structure Changes
                       '                  (SELECT NULL ' ||
                       '                     FROM bom_components_b ' ||
                       '                    WHERE revised_item_sequence_id = change.revised_item_sequence_id) ) ';

        BEGIN
        code_debug(l_api_name||': Executing l_dynamic_sql 2: ' || l_dynamic_sql);
        code_debug(l_api_name||': executing p_inventory_item_id ' || p_inventory_item_id);
        code_debug(l_api_name||': executing l_change_notice ' || l_change_notice);
        code_debug(l_api_name||': executing l_change_line_id ' || l_change_line_id);
        code_debug(l_api_name||': executing p_organization_id ' || p_organization_id);
          OPEN l_dynamic_cursor FOR l_dynamic_sql USING  p_inventory_item_id,
                                                         l_change_notice,
                                                         l_change_line_id,
                                                         p_organization_id,
                                                         p_inventory_item_id;
          FETCH l_dynamic_cursor INTO l_organization_id;
          code_debug(l_api_name||': executed l_dynamic_sql 2 ');
           IF l_dynamic_cursor%FOUND THEN
             code_debug(l_api_name||': Validating only item phase changes FOUND ');
             l_fetch_error_message := TRUE;
           ELSE
             code_debug(l_api_name||': Validating only item phase changes NOT FOUND ');
             CLOSE l_dynamic_cursor;
  -- check if there are any item revision level pending phase changes
        FOR cr IN c_get_null_revisions(cp_item_id => p_inventory_item_id
                                      ,cp_org_id  => p_organization_id) LOOP
          code_debug(l_api_name||': Validating NULL revision changes for organization_id '||cr.organization_id);
          code_debug(l_api_name||': Validating NULL revision changes for revision '||cr.revision_id);
          BEGIN
           OPEN l_dynamic_cursor FOR l_dyn_sql_pend_chg_rev USING  p_inventory_item_id,
                                                                   p_organization_id,
                                                                   l_change_notice,
                                                                   l_change_line_id,
                                                                   l_revision_id,
                                                                   p_inventory_item_id,
                                                                   l_revision_id;
            FETCH l_dynamic_cursor INTO l_organization_id;
             IF l_dynamic_cursor%FOUND THEN
               code_debug(l_api_name||': Validating NULL revision changes FOUND for revision '||cr.revision_id);
               l_fetch_error_message := TRUE;
               l_revision_id := cr.revision_id;
               CLOSE l_dynamic_cursor;
               EXIT;
             ELSE
               code_debug(l_api_name||': Validating NULL revision changes NOT FOUND for revision '||cr.revision_id);
               CLOSE l_dynamic_cursor;
             END IF;
          EXCEPTION
          WHEN OTHERS THEN
            code_debug(l_api_name||': error4: ' || SQLERRM);
            if (l_dynamic_cursor%ISOPEN) then
              CLOSE l_dynamic_cursor;
            END IF;
          END;
  END LOOP; -- revision null check.
      END IF; -- pending changes found at item
      EXCEPTION
        WHEN OTHERS THEN
        code_debug(l_api_name||': error5: ' || SQLERRM);
          if (l_dynamic_cursor%ISOPEN) then
              CLOSE l_dynamic_cursor;
          END IF;
      END;
    ELSE
      RETURN;
    END IF;  -- changes at item level
  END IF;    -- revision exists or not

  code_debug(l_api_name||': All validations complete ');
  IF l_fetch_error_message THEN
    -- flashing message at item level only.
    code_debug(l_api_name||': Flash error message for pending changes exist ');
    Get_Error_Msg(p_inventory_item_id => p_inventory_item_id
                 ,p_organization_id   => l_organization_id
                 ,p_item_revision_id  => l_revision_id
                 ,p_message_name      => 'EGO_ITEM_PENDING_CHANGES_EXIST'
                 ,x_return_status     => x_return_status
                 ,x_msg_count         => x_msg_count
                 ,x_msg_data          => x_msg_data
                 );
  ELSE
    code_debug(l_api_name||': No Pending Changes ');
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;
    x_msg_data := NULL;
  END IF;
  code_debug(l_api_name||': Bye Bye ');
EXCEPTION
  WHEN OTHERS THEN
            code_debug(l_api_name||': error6: ' || SQLERRM);
      IF l_dynamic_cursor%ISOPEN THEN
        CLOSE l_dynamic_cursor;
      END IF;
      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.Set_Name(G_APP_NAME, G_PLSQL_ERR);
      FND_MESSAGE.Set_Token(G_PKG_NAME_TOKEN, G_PKG_NAME);
      FND_MESSAGE.Set_Token(G_API_NAME_TOKEN, 'CHECK_PENDING_CHANGE_ORDERS');
      FND_MESSAGE.Set_Token(G_SQL_ERR_MSG_TOKEN, SQLERRM);
      x_msg_count := 1;
      x_msg_data := FND_MESSAGE.GET;
END Check_pending_Change_Orders;


END EGO_INV_ITEM_CATALOG_PVT;

/
