--------------------------------------------------------
--  DDL for Package Body EGO_ITEM_LC_IMP_PC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_ITEM_LC_IMP_PC_PUB" AS
/* $Header: EGOCIPSB.pls 120.4.12000000.2 2007/03/27 10:45:34 syalaman ship $ */

G_SUCCESS            CONSTANT  NUMBER  :=  0;
G_WARNING            CONSTANT  NUMBER  :=  1;
G_ERROR              CONSTANT  NUMBER  :=  2;

G_PKG_NAME           CONSTANT  VARCHAR2(30)  := 'EGO_ITEM_LC_IMP_PC_PUB';
G_APP_NAME           CONSTANT  VARCHAR2(3)   := 'EGO';
G_PKG_NAME_TOKEN     CONSTANT  VARCHAR2(8)   := 'PKG_NAME';
G_API_NAME_TOKEN     CONSTANT  VARCHAR2(8)   := 'API_NAME';
G_SQL_ERR_MSG_TOKEN  CONSTANT  VARCHAR2(11)  := 'SQL_ERR_MSG';
G_PLSQL_ERR          CONSTANT  VARCHAR2(17)  := 'EGO_PLSQL_ERR';

G_EGO_ITEM           CONSTANT  VARCHAR2(20) := 'EGO_ITEM';
G_CURRENT_USER_ID    NUMBER                := FND_GLOBAL.User_Id;
G_CURRENT_LOGIN_ID   NUMBER                := FND_GLOBAL.Login_Id;


----------------------------------------------------------------------
-- Private Procedures / Functions
----------------------------------------------------------------------

-- Developer debugging
PROCEDURE code_debug (p_msg  IN  VARCHAR2) IS
BEGIN
  --sri_debug (' EGOCIPSB - EGO_ITEM_LC_IMP_PC_PUB.'||p_msg);
  RETURN;
EXCEPTION
  WHEN OTHERS THEN
  NULL;
END;


/***
-------------------------------------------------------
-- fix as a part of bug 3696801
-- this is no more used.  replaced by
-- EGO_INV_ITEM_CATALOG_PVT.check_pending_change_orders
-------------------------------------------------------
PROCEDURE Check_Pending_Change_Orders
(
   p_inventory_item_id   IN  NUMBER
  ,p_organization_id     IN  NUMBER
  ,p_revision_id         IN  NUMBER
  ,x_return_status       OUT  NOCOPY VARCHAR2
  ,x_msg_data            OUT  NOCOPY VARCHAR2
)
IS

  CURSOR c_pending_changes (cp_item_id  IN NUMBER
                           ,cp_org_id   IN NUMBER
                           ,cp_rev_id   IN NUMBER
                           )  IS
  SELECT change.organization_id
  FROM  eng_revised_items change
  WHERE change.revised_item_id = cp_item_id
    AND change.organization_id = cp_org_id
    AND nvl(change.current_item_revision_id, -1) = nvl(cp_rev_id, nvl(change.current_item_revision_id,-1))
    AND change.status_type NOT IN (5, -- CANCELLED
                                   6  -- IMPLEMENTED
                                  )
    AND
      ( EXISTS
        (SELECT 'X'
        FROM  ego_mfg_part_num_chgs
        WHERE change_line_id = change.revised_item_sequence_id )
      OR EXISTS
        (SELECT 'X'
        FROM  ego_items_attrs_changes_vl
        WHERE change_line_id = change.revised_item_sequence_id )
      OR EXISTS
        (SELECT 'X'
        FROM  eng_attachment_changes
        WHERE revised_item_sequence_id = change.revised_item_sequence_id )
      );

  CURSOR c_pending_org_changes (cp_item_id  IN NUMBER
                               ,cp_org_id   IN NUMBER
                               ,cp_rev_id   IN NUMBER
                               )  IS
  SELECT organization_id
  FROM  eng_revised_items change
  WHERE revised_item_id = cp_item_id
    AND organization_id IN
             (SELECT P2.ORGANIZATION_ID
              FROM   MTL_PARAMETERS P1,
                     MTL_PARAMETERS P2
              WHERE  P1.ORGANIZATION_ID = cp_org_id
              AND    P1.MASTER_ORGANIZATION_ID = P2.MASTER_ORGANIZATION_ID
              )
    AND nvl(current_item_revision_id, -1) = nvl(cp_rev_id, nvl(current_item_revision_id,-1))
    AND status_type NOT IN (5, -- CANCELLED
                            6  -- IMPLEMENTED
                           )
    AND
      ( EXISTS
        (SELECT 'X'
        FROM  ego_mfg_part_num_chgs
        WHERE change_line_id = change.revised_item_sequence_id )
      OR EXISTS
        (SELECT 'X'
        FROM  ego_items_attrs_changes_vl
        WHERE change_line_id = change.revised_item_sequence_id )
      OR EXISTS
        (SELECT 'X'
        FROM  eng_attachment_changes
        WHERE revised_item_sequence_id = change.revised_item_sequence_id )
      );

  l_organization_id              MTL_SYSTEM_ITEMS_B.ORGANIZATION_ID%TYPE;
  l_item_number                  VARCHAR2(999);
  l_org_name                     VARCHAR2(999);
  l_is_master_org                VARCHAR2(100);
  l_status_master_controlled     VARCHAR2(100);
  l_pending_change_found         VARCHAR2(100);

BEGIN
  code_debug(' Check_Pending_Change_Orders  Started ');
  code_debug(' item id '||p_inventory_item_id||' org id '||p_organization_id||' revision id '||p_revision_id);
  IF (p_inventory_item_id IS NULL
      OR
      p_organization_id is NULL) THEN
    code_debug(' invalid params ');
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN;
  END IF;
  l_pending_change_found := FND_API.G_FALSE;
  l_is_master_org  := get_master_org_status(p_organization_id => p_organization_id);
  l_status_master_controlled  := get_master_controlled_status();
  IF p_revision_id IS NULL THEN
    IF (FND_API.TO_BOOLEAN(l_status_master_controlled)) THEN
      IF (FND_API.TO_BOOLEAN(l_is_master_org)) THEN
        OPEN c_pending_changes(cp_item_id => p_inventory_item_id
                              ,cp_org_id  => p_organization_id
                              ,cp_rev_id  => p_revision_id
                              );
        FETCH c_pending_changes INTO l_organization_id;
        IF c_pending_changes%FOUND THEN
          l_pending_change_found := FND_API.G_TRUE;
        END IF;
        CLOSE c_pending_changes;
      ELSE
        --
        -- check if there are any changes in org hierarchy
        --
        OPEN c_pending_org_changes(cp_item_id => p_inventory_item_id
                                  ,cp_org_id  => p_organization_id
                                  ,cp_rev_id  => p_revision_id
                                  );
        FETCH c_pending_org_changes INTO l_organization_id;
        IF c_pending_org_changes%FOUND THEN
          l_pending_change_found := FND_API.G_TRUE;
        END IF;
        CLOSE c_pending_org_changes;
      END IF; -- in master org
    ELSE
      -- status is not master controlled
        OPEN c_pending_changes(cp_item_id => p_inventory_item_id
                              ,cp_org_id  => p_organization_id
                              ,cp_rev_id  => p_revision_id
                              );
        FETCH c_pending_changes INTO l_organization_id;
        IF c_pending_changes%FOUND THEN
          l_pending_change_found := FND_API.G_TRUE;
        END IF;
        CLOSE c_pending_changes;
    END IF; -- status is master controlled
  ELSE
    --
    -- revision is present
    -- revision is never master controlled, only org control
    --
    OPEN c_pending_changes(cp_item_id => p_inventory_item_id
                          ,cp_org_id  => p_organization_id
                          ,cp_rev_id  => p_revision_id
                          );
    FETCH c_pending_changes INTO l_organization_id;
    IF c_pending_changes%FOUND THEN
      l_pending_change_found := FND_API.G_TRUE;
    END IF;
    CLOSE c_pending_changes;
  END IF; -- p_revision_id IS NULL

  IF (FND_API.TO_BOOLEAN(l_pending_change_found)) THEN
    code_debug(' pending changes exist ');
    x_return_status := FND_API.G_RET_STS_ERROR;
    --
    -- get item name
    --
    SELECT concatenated_segments
    INTO l_item_number
    FROM mtl_system_items_kfv
    WHERE inventory_item_id = p_inventory_item_id
      AND organization_id = l_organization_id;
    --
    -- get organiation name
    --
    SELECT organization_name
    INTO  l_org_name
    FROM  org_organization_definitions
    WHERE organization_id = l_organization_id;
    fnd_message.set_name('EGO', 'EGO_ITEM_PENDING_CHANGES_EXIST');
    fnd_message.set_token('ITEM_NUMBER', l_item_number);
    fnd_message.set_token('ORG_NAME', l_org_name);
    x_msg_data := fnd_message.get();
    code_debug(' error msg '|| x_msg_data);
  ELSE
    code_debug(' no pending changes ');
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    code_debug(' EXCEPTION in Check_Pending_Change_Orders ');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF c_pending_changes%ISOPEN THEN
      CLOSE c_pending_changes;
    END IF;
    IF c_pending_org_changes%ISOPEN THEN
      CLOSE c_pending_org_changes;
    END IF;
END Check_Pending_Change_Orders;
***/

--
-- function to determine what action is being done
-- during phase / status change. returned values are
-- 'EGO_PRO_ITEM_LIFE_CYCLE' if user is trying to promote
-- 'EGO_DEM_ITEM_LIFE_CYCLE' if user is trying to demote
-- 'EGO_EDIT_ITEM_STATUS' if user is trying to change status
-- these are the data security function names.
--
  FUNCTION get_privlige_name_for_action
     (p_curr_item_id     IN  NUMBER
     ,p_curr_org_id      IN  NUMBER
     ,p_curr_rev_id      IN  NUMBER
     ,p_curr_lc_id       IN  NUMBER
     ,p_curr_phase_id    IN  NUMBER
     ,p_curr_status_code IN  VARCHAR2
     ,p_new_lc_id        IN  NUMBER
     ,p_new_phase_id     IN  NUMBER
     ,p_new_status_code  IN  VARCHAR2
     ) RETURN VARCHAR2 IS
    l_curr_lc_id         mtl_system_items_b.lifecycle_id%TYPE;
    l_curr_phase_id      mtl_system_items_b.current_phase_id%TYPE;
    l_curr_status_code   mtl_system_items_b.inventory_item_status_code%TYPE;
    l_curr_phase_seq     NUMBER;
    l_new_lc_id          mtl_system_items_b.lifecycle_id%TYPE;
    l_new_phase_id       mtl_system_items_b.current_phase_id%TYPE;
    l_new_status_code    mtl_system_items_b.inventory_item_status_code%TYPE;
    l_new_phase_seq      NUMBER;

    -- data securiry functions supported
    l_fn_name_promote         VARCHAR2(50);
    l_fn_name_demote          VARCHAR2(50);
    l_fn_name_change_status   VARCHAR2(50);


  CURSOR c_get_item_det (cp_inventory_item_id  IN  NUMBER
                        ,cp_organization_id    IN  NUMBER) IS
    SELECT lifecycle_id, current_phase_id, inventory_item_status_code
    FROM   mtl_system_items_b
    WHERE  inventory_item_id = cp_inventory_item_id
      AND  organization_id = cp_organization_id;

  CURSOR c_get_item_rev_det (cp_inventory_item_id  IN  NUMBER
                            ,cp_organization_id    IN  NUMBER
                            ,cp_revision_id        IN  NUMBER) IS
    SELECT rev.lifecycle_id, rev.current_phase_id, itm.inventory_item_status_code
    FROM  mtl_system_items_b itm, mtl_item_revisions_b rev
    WHERE itm.inventory_item_id = cp_inventory_item_id
      AND itm.organization_id = cp_organization_id
      AND rev.inventory_item_id = itm.inventory_item_id
      AND rev.organization_id = rev.organization_id
      AND rev.revision_id = rev.revision_id;

  CURSOR c_get_phase_seq (cp_phase_id IN  NUMBER ) IS
    SELECT display_sequence
    FROM   pa_proj_element_versions
    WHERE  proj_element_id = cp_phase_id;

  BEGIN
    code_debug (' Get_privilege_name_for_action started');
    l_fn_name_promote         := 'EGO_PRO_ITEM_LIFE_CYCLE';
    l_fn_name_demote          := 'EGO_DEM_ITEM_LIFE_CYCLE';
    l_fn_name_change_status   := 'EGO_EDIT_ITEM_STATUS';
    IF p_curr_status_code IS NULL THEN
      IF (p_curr_rev_id IS NOT NULL) THEN
        --
        -- context of item revision
        --
        OPEN c_get_item_rev_det (cp_inventory_item_id => p_curr_item_id
                                ,cp_organization_id   => p_curr_org_id
                                ,cp_revision_id       => p_curr_rev_id
                                );
        FETCH c_get_item_rev_det
        INTO l_curr_lc_id, l_curr_phase_id, l_curr_status_code;
        CLOSE c_get_item_rev_det;
      ELSE
        --
        -- context of item
        --
        OPEN c_get_item_det (cp_inventory_item_id => p_curr_item_id
                            ,cp_organization_id   => p_curr_org_id
                            );
        FETCH c_get_item_det
        INTO l_curr_lc_id, l_curr_phase_id, l_curr_status_code;
        CLOSE c_get_item_det;
      END IF;
    ELSE
      l_curr_lc_id       := p_curr_lc_id;
      l_curr_phase_id    := p_curr_phase_id;
      l_curr_status_code := p_curr_status_code;
    END IF;
    code_debug (' curr details  lc '||l_curr_lc_id||' phase '||l_curr_phase_id||' status '||l_curr_status_code);
    code_debug ('  new details  lc '||p_new_lc_id||' phase '||p_new_phase_id||' status '||p_new_status_code);
    IF ( (p_new_lc_id IS NULL OR p_new_lc_id = l_curr_lc_id)
          AND
         (p_new_phase_id IS NULL OR p_new_phase_id = l_curr_phase_id)
          AND
         (l_curr_status_code <> NVL(p_new_status_code,l_curr_status_code))
       ) THEN
      -- user is trying to change status
      RETURN l_fn_name_change_status;
    ELSE
      OPEN c_get_phase_seq(cp_phase_id => l_curr_phase_id);
      FETCH c_get_phase_seq INTO l_curr_phase_seq;
      IF c_get_phase_seq%NOTFOUND THEN
        l_curr_phase_seq := -1;
      END IF;
      CLOSE c_get_phase_seq;
      OPEN c_get_phase_seq(cp_phase_id => p_new_phase_id);
      FETCH c_get_phase_seq INTO l_new_phase_seq;
      IF c_get_phase_seq%NOTFOUND THEN
        l_new_phase_seq := -1;
      END IF;
      CLOSE c_get_phase_seq;
      IF l_curr_phase_seq < l_new_phase_seq THEN
        RETURN l_fn_name_promote;
      ELSIF l_curr_phase_seq > l_new_phase_seq THEN
        RETURN l_fn_name_demote;
      ELSE
        RETURN l_fn_name_change_status;
      END IF;
    END IF;
    RETURN NULL;
  END  get_privlige_name_for_action;

--
-- procedure to implement all pending changes
--
  PROCEDURE Implement_All_Pending_Changes
  (
     p_api_version                 IN   NUMBER
   , p_commit                      IN   VARCHAR2
   , p_inventory_item_id           IN   NUMBER
   , p_organization_id             IN   NUMBER
   , p_revision_id                 IN   NUMBER
   , p_change_id                   IN   NUMBER
   , p_change_line_id              IN   NUMBER
   , p_revision_master_controlled  IN   VARCHAR2
   , p_status_master_controlled    IN   VARCHAR2
   , p_perform_security_check      IN   VARCHAR2
   , p_is_master_org               IN   VARCHAR2
   , x_return_status               OUT  NOCOPY VARCHAR2
   , x_errorcode                   OUT  NOCOPY NUMBER
   , x_msg_count                   OUT  NOCOPY NUMBER
   , x_msg_data                    OUT  NOCOPY VARCHAR2
) IS

  CURSOR l_pending_revision_statuses  IS
  SELECT
    inventory_item_id
   ,revision_id
   ,organization_id
   ,phase_id
   ,lifecycle_id
   ,status_code
   ,effective_date
  FROM
    MTL_PENDING_ITEM_STATUS
  WHERE inventory_item_id = p_inventory_item_id
    AND organization_id = p_organization_id
    AND revision_id = p_revision_id
    AND pending_flag = 'Y'
    AND implemented_date IS NULL
    AND effective_date <= SYSDATE
    AND NVL(change_id,-1) = NVL(p_change_id, NVL(change_id,-1))
    AND NVL(change_line_id,-1) = NVL(p_change_line_id, NVL(change_line_id,-1))
  ORDER BY effective_date ASC
  FOR UPDATE OF IMPLEMENTED_DATE, PENDING_FLAG;

  CURSOR l_phase_ids IS
    SELECT lifecycle_id, phase_id, status_code
    FROM MTL_PENDING_ITEM_STATUS
    WHERE INVENTORY_ITEM_ID = p_inventory_item_id
      AND ORGANIZATION_ID = p_organization_id
      AND REVISION_ID IS NULL
      AND PENDING_FLAG = 'Y'
      AND IMPLEMENTED_DATE IS NULL
      AND STATUS_CODE IS NOT NULL
      AND EFFECTIVE_DATE <= SYSDATE
      AND NVL(change_id,-1) = NVL(p_change_id, NVL(change_id,-1))
      AND NVL(change_line_id,-1) = NVL(p_change_line_id, NVL(change_line_id,-1))
      ORDER BY EFFECTIVE_DATE, LAST_UPDATE_DATE, ROWID;

  CURSOR c_item_pending_phase_change IS
    SELECT pending_status.phase_id
    FROM MTL_PENDING_ITEM_STATUS pending_status, mtl_system_items_b item
    WHERE pending_status.INVENTORY_ITEM_ID = p_inventory_item_id
      AND pending_status.ORGANIZATION_ID = p_organization_id
      AND pending_status.PENDING_FLAG = 'Y'
      AND pending_status.IMPLEMENTED_DATE IS NULL
      AND pending_status.EFFECTIVE_DATE <= SYSDATE
      AND pending_status.inventory_item_id = item.inventory_item_id
      AND pending_status.organization_id = item.organization_id
      AND ( NVL(pending_status.lifecycle_id,NVL(item.lifecycle_id,-1)) <> NVL(item.lifecycle_id,-1)
            OR
            NVL(pending_status.phase_id,NVL(item.current_phase_id,-1)) <> NVL(item.current_phase_id,-1)
           );

  -- bug 3833932
  CURSOR c_rev_pending_phase_change IS
    SELECT pending_status.phase_id
    FROM MTL_PENDING_ITEM_STATUS pending_status, mtl_item_revisions_b rev
    WHERE pending_status.INVENTORY_ITEM_ID = p_inventory_item_id
      AND pending_status.ORGANIZATION_ID = p_organization_id
      AND pending_status.PENDING_FLAG = 'Y'
      AND pending_status.IMPLEMENTED_DATE IS NULL
      AND pending_status.EFFECTIVE_DATE <= SYSDATE
      AND pending_status.inventory_item_id = rev.inventory_item_id
      AND pending_status.organization_id = rev.organization_id
      AND pending_status.revision_id = rev.revision_id
      AND ( NVL(pending_status.lifecycle_id,NVL(rev.lifecycle_id,-1)) <> NVL(rev.lifecycle_id,-1)
            OR
            NVL(pending_status.phase_id,NVL(rev.current_phase_id,-1)) <> NVL(rev.current_phase_id,-1)
           );

  --Start: 4105841 Business Event Enhancement

  Cursor c_get_item_details(p_inventory_item_id NUMBER,
                            p_organization_id   NUMBER) IS
    SELECT   MSI.organization_id,
             MSI.description,
             MSI.concatenated_segments,
             MP.ORGANIZATION_CODE
     FROM MTL_SYSTEM_ITEMS_KFV MSI,
          MTL_PARAMETERS    MP
     WHERE
          MSI.INVENTORY_ITEM_ID   = p_inventory_item_id
          AND MSI.ORGANIZATION_ID = p_organization_id
          AND MSI.Organization_ID = MP.Organization_ID;

  l_event_return_status   VARCHAR2(1);
  l_phase_update          VARCHAR2(1);
  l_msg_data              VARCHAR2(2000);
  l_old_status            MTL_SYSTEM_ITEMS_B.INVENTORY_ITEM_STATUS_CODE%TYPE;
  l_new_status            MTL_SYSTEM_ITEMS_B.INVENTORY_ITEM_STATUS_CODE%TYPE;
  --End 4105841

  l_api_version           NUMBER;
  l_api_name              VARCHAR2(30);
  l_current_phase_id      MTL_SYSTEM_ITEMS_B.CURRENT_PHASE_ID%TYPE;
  l_current_revision      MTL_ITEM_REVISIONS_B.REVISION%TYPE;
  l_perform_policy_check  BOOLEAN;
  l_priv_name_to_check    VARCHAR2(100);



BEGIN
  l_api_version          := 1.0;
  l_api_name             := 'Implement_All_Pending_Changes';
  l_perform_policy_check := FALSE;
  l_phase_update         := NULL;
  code_debug(' Implement All Pending Changes called with params ');
  code_debug('  p_api_version : '||p_api_version||' p_commit : '|| p_commit);
  code_debug('  p_inventory_item_id :'||p_inventory_item_id||' p_organization_id : '||p_organization_id);
  code_debug('  p_revision_id : '||p_revision_id||' p_revision_master_controlled: '||p_revision_master_controlled);
  code_debug('  p_status_master_controlled : '||p_status_master_controlled||' p_is_master_org: '||p_is_master_org);

  IF FND_API.To_Boolean(p_commit) THEN
    SAVEPOINT Implement_All_Pending_Changes;
  END IF;

  --Standard checks
  IF NOT FND_API.Compatible_API_Call (l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,g_pkg_name)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF Nvl(FND_GLOBAL.User_Id,-1) <> Nvl(G_CURRENT_USER_ID,-1)
  THEN
      G_CURRENT_USER_ID  := FND_GLOBAL.User_Id;
      G_CURRENT_LOGIN_ID := FND_GLOBAL.Login_Id;
  END IF;

--
-- replaced call to  EGO_INV_ITEM_CATALOG_PVT.Check_pending_Change_Orders
-- as a part of bug 3696801
--  Check_Pending_Change_Orders (p_inventory_item_id => p_inventory_item_id
--                              ,p_organization_id   => p_organization_id
--                              ,p_revision_id       => p_revision_id
--                              ,x_return_status     => x_return_status
--                              ,x_msg_data          => x_msg_data
--                              );
  -- bug 3833932 doing pending phase change only on the corresponding item/rev
  IF p_revision_id IS NULL THEN
    OPEN c_item_pending_phase_change;
    FETCH c_item_pending_phase_change INTO l_current_Phase_id;
    IF c_item_pending_phase_change%FOUND THEN
      l_perform_policy_check := TRUE;
    END IF;
    CLOSE c_item_pending_phase_change;
  ELSE
    OPEN c_rev_pending_phase_change;
    FETCH c_rev_pending_phase_change INTO l_current_Phase_id;
    IF c_rev_pending_phase_change%FOUND THEN
      l_perform_policy_check := TRUE;
    END IF;
    CLOSE c_rev_pending_phase_change;
  END IF;

  IF l_perform_policy_check THEN
    code_debug (' performing policy check ');
    EGO_INV_ITEM_CATALOG_PVT.Check_pending_Change_Orders (
         p_inventory_item_id        => p_inventory_item_id
        ,p_organization_id          => p_organization_id
        ,p_revision_id              => p_revision_id
        ,p_lifecycle_changed        => FND_API.G_FALSE
        ,p_lifecycle_phase_changed  => FND_API.G_TRUE
        ,p_change_id                => p_change_id
        ,p_change_line_id           => p_change_line_id
        ,x_return_status            => x_return_status
        ,x_msg_count                => x_msg_count
        ,x_msg_data                 => x_msg_data
        );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      code_debug (' pending co exist  '|| x_msg_data);
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Implement_All_Pending_Changes;
      END IF;
      RETURN;
    END IF;
  END IF;

  code_debug (' no pending change orders exist ');

  IF FND_API.TO_BOOLEAN(p_is_master_org) THEN
    code_debug (' in context of master org ');
  ELSE
    code_debug (' in context of child org ');
  END IF;

  IF FND_API.TO_BOOLEAN(p_status_master_controlled) THEN
    code_debug (' status is master controlled ');
  ELSE
    code_debug (' status is controlled at org level ');
  END IF;

  --
  -- to be removed after bug 3874132 is resoloved.
  --
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF FND_API.To_Boolean( p_commit ) THEN
                ROLLBACK TO Implement_All_Pending_Changes;
        END IF;
        RETURN;
  END IF;

  IF (p_revision_id IS NULL) THEN

    code_debug (' processing changes for item ');
        code_debug ('p_revision_id is null ');

    --
    -- If it's at the master and status is master controlled,
    -- then do it for all assigned orgs
    --
    IF (FND_API.TO_BOOLEAN(p_is_master_org)
        OR
        FND_API.TO_BOOLEAN(p_status_master_controlled) = FALSE
       ) THEN
      IF (FND_API.TO_BOOLEAN(p_is_master_org)
          AND
          FND_API.TO_BOOLEAN(p_status_master_controlled) = TRUE
         ) THEN
        -- Get the most recent phase id
        code_debug(' before the loop' );

        FOR l_phase_id IN l_phase_ids LOOP
          IF FND_API.To_boolean(p_perform_security_check) THEN
            -- 4052565 perform security check
            l_priv_name_to_check := get_privlige_name_for_action
                              (p_curr_item_id     => p_inventory_item_id
                              ,p_curr_org_id      => p_organization_id
                              ,p_curr_rev_id      => p_revision_id
                              ,p_curr_lc_id       => NULL
                              ,p_curr_phase_id    => NULL
                              ,p_curr_status_code => NULL
                              ,p_new_lc_id        => l_phase_id.lifecycle_id
                              ,p_new_phase_id     => l_phase_id.phase_id
                              ,p_new_status_code  => l_phase_id.status_code
                              );
            IF l_priv_name_to_check IS NOT NULL THEN
              IF NOT EGO_ITEM_PVT.has_role_on_item
                               (p_function_name      => l_priv_name_to_check
                               ,p_inventory_item_id  => p_inventory_item_id
                               ,p_item_number        => NULL
                               ,p_organization_id    => p_organization_id
                               ,p_organization_name  => NULL
                               ,p_user_id            => G_CURRENT_USER_ID
                               ,p_party_id           => NULL
                               ,p_set_message        => FND_API.G_TRUE
                               ) THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;
            END IF;
          END IF;

          code_debug(' before check_floating_attachments 1');
          EGO_DOM_UTIL_PUB.check_floating_attachments (  p_inventory_item_id  => p_inventory_item_id
                                                         ,p_revision_id        => p_revision_id
                                                         ,p_organization_id    => p_organization_id
                                                         ,p_lifecycle_id       => NULL
                                                         ,p_new_phase_id       => l_phase_id.phase_id
                                                         ,x_return_status      => x_return_status
                                                         ,x_msg_count          => x_msg_count
                                                         ,x_msg_data           => x_msg_data );

          code_debug(' after check_floating_attachments 1 ' || x_return_status);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF FND_API.To_Boolean( p_commit ) THEN
                        ROLLBACK TO Implement_All_Pending_Changes;
                END IF;
                RETURN;
          END IF;
          UPDATE MTL_SYSTEM_ITEMS_B
          SET CURRENT_PHASE_ID = NVL(l_phase_id.PHASE_ID,current_phase_id)
          WHERE
            INVENTORY_ITEM_ID = p_inventory_item_id
            AND ORGANIZATION_ID IN
                 (SELECT P2.ORGANIZATION_ID
                  FROM   MTL_PARAMETERS P1, MTL_PARAMETERS P2
                  WHERE  P1.ORGANIZATION_ID = p_organization_id
                  AND    P1.MASTER_ORGANIZATION_ID = P2.MASTER_ORGANIZATION_ID);
          l_phase_update := 'Y';
        END LOOP;
          code_debug(' out side the loop ');
      --
      -- Otherwise, either we are not at master or not master controlled.
      -- So if not master controlled, do it for the current org
      --
      ELSIF (FND_API.TO_BOOLEAN(p_status_master_controlled) = FALSE) THEN
        --
        -- Get the most recent phase id
        --
        FOR l_phase_id IN l_phase_ids LOOP

          IF FND_API.To_boolean(p_perform_security_check) THEN
            -- 4052565 perform security check
            l_priv_name_to_check := get_privlige_name_for_action
                              (p_curr_item_id     => p_inventory_item_id
                              ,p_curr_org_id      => p_organization_id
                              ,p_curr_rev_id      => p_revision_id
                              ,p_curr_lc_id       => NULL
                              ,p_curr_phase_id    => NULL
                              ,p_curr_status_code => NULL
                              ,p_new_lc_id        => l_phase_id.lifecycle_id
                              ,p_new_phase_id     => l_phase_id.phase_id
                              ,p_new_status_code  => l_phase_id.status_code
                              );
            IF l_priv_name_to_check IS NOT NULL THEN
              IF NOT EGO_ITEM_PVT.has_role_on_item
                               (p_function_name      => l_priv_name_to_check
                               ,p_inventory_item_id  => p_inventory_item_id
                               ,p_item_number        => NULL
                               ,p_organization_id    => p_organization_id
                               ,p_organization_name  => NULL
                               ,p_user_id            => G_CURRENT_USER_ID
                               ,p_party_id           => NULL
                               ,p_set_message        => FND_API.G_TRUE
                               ) THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;
            END IF;
          END IF;

          code_debug(' before check_floating_attachments 2');
          EGO_DOM_UTIL_PUB.check_floating_attachments (  p_inventory_item_id  => p_inventory_item_id
                                                         ,p_revision_id        => p_revision_id
                                                         ,p_organization_id    => p_organization_id
                                                         ,p_lifecycle_id       => NULL
                                                         ,p_new_phase_id       => l_phase_id.phase_id
                                                         ,x_return_status      => x_return_status
                                                         ,x_msg_count          => x_msg_count
                                                         ,x_msg_data           => x_msg_data );

          code_debug(' after check_floating_attachments 2 ' || x_return_status);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF FND_API.To_Boolean( p_commit ) THEN
                        ROLLBACK TO Implement_All_Pending_Changes;
                END IF;
                RETURN;
          END IF;

          UPDATE MTL_SYSTEM_ITEMS_B
          SET CURRENT_PHASE_ID = NVL(l_phase_id.PHASE_ID, current_phase_id)
          WHERE INVENTORY_ITEM_ID = p_inventory_item_id
          AND ORGANIZATION_ID = p_organization_id;
          l_phase_update := 'Y';
        END LOOP;
      END IF;
      --
      -- Now call another api to update statuses,
      -- but only if we are at the master org or status is org controlled
      --
      ---Start 4105841 Business events
      SELECT inventory_item_status_code INTO l_old_status
      FROM  mtl_system_items_b msi
      WHERE msi.inventory_item_id = p_inventory_item_id
      AND msi.organization_id = p_organization_id
      AND    rownum < 2;
      ---End 4105841

      INV_ITEM_STATUS_PUB.Update_Pending_Status (1.0
                                                ,p_organization_id
                                                ,p_inventory_item_id
                                                ,NULL
                                                ,NULL
                                                ,x_return_status
                                                ,x_msg_count
                                                ,x_msg_data
                                                );
      --Added for bug 5230594
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         ROLLBACK TO Implement_All_Pending_Changes;
         RETURN;
      END IF;


      ---Start 4105841 Business events
      SELECT inventory_item_status_code INTO l_new_status
      FROM  mtl_system_items_b msi
      WHERE msi.inventory_item_id = p_inventory_item_id
      AND msi.organization_id = p_organization_id
      AND    rownum < 2;

      IF l_phase_update = 'Y' OR
         NVL(l_old_status,-1) <> NVL(l_new_status,-1) THEN
          FOR Item_Rec IN c_get_item_details(p_inventory_item_id
	                                    ,p_organization_id) LOOP
             EGO_WF_WRAPPER_PVT.Raise_Item_Create_Update_Event(
                  p_event_name        => EGO_WF_WRAPPER_PVT.G_ITEM_UPDATE_EVENT
                 ,p_organization_id   => p_organization_id
                 ,p_organization_code => Item_Rec.organization_code
                 ,p_item_number       => Item_Rec.concatenated_segments
                 ,p_item_description  => Item_Rec.DESCRIPTION
                 ,p_inventory_item_id => p_inventory_item_id
                 ,x_msg_data          => l_msg_data
                 ,x_return_status     => l_event_return_status);

                --Call ICX APIs
                BEGIN
                   INV_ITEM_EVENTS_PVT.Invoke_ICX_APIs(
                      p_entity_type       => 'ITEM'
                     ,p_dml_type          => 'UPDATE'
                     ,p_inventory_item_id => p_inventory_item_id
                     ,p_item_number       => Item_Rec.concatenated_segments
                     ,p_item_description  => Item_Rec.DESCRIPTION
                     ,p_organization_id   => p_organization_id
                     ,p_organization_code => Item_Rec.organization_code );
                EXCEPTION
                   WHEN OTHERS THEN
                      NULL;
                END;
                --R12: Business Event Enhancement
          END LOOP;
      END IF;
      --End 4105841 Business Event

    END IF;

  ELSE
    code_debug (' processing changes for item revision ');
    --
    -- Get all of the pending records
    --
    FOR l_pending_record IN l_pending_revision_statuses LOOP
      code_debug (' processing revision '||l_pending_record.REVISION_ID);
      IF NVL(p_perform_security_check,FND_API.G_FALSE) = FND_API.G_TRUE THEN
        -- 4052565 perform security check
        l_priv_name_to_check := get_privlige_name_for_action
                              (p_curr_item_id     => p_inventory_item_id
                              ,p_curr_org_id      => p_organization_id
                              ,p_curr_rev_id      => p_revision_id
                              ,p_curr_lc_id       => NULL
                              ,p_curr_phase_id    => NULL
                              ,p_curr_status_code => NULL
                              ,p_new_lc_id        => l_pending_record.lifecycle_id
                              ,p_new_phase_id     => l_pending_record.phase_id
                              ,p_new_status_code  => l_pending_record.status_code
                              );
        IF l_priv_name_to_check IS NOT NULL THEN
          IF NOT EGO_ITEM_PVT.has_role_on_item
                               (p_function_name      => l_priv_name_to_check
                               ,p_inventory_item_id  => p_inventory_item_id
                               ,p_item_number        => NULL
                               ,p_organization_id    => p_organization_id
                               ,p_organization_name  => NULL
                               ,p_user_id            => G_CURRENT_USER_ID
                               ,p_party_id           => NULL
                               ,p_set_message        => FND_API.G_TRUE
                               ) THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;
      END IF;

      IF l_pending_record.PHASE_ID IS NOT NULL THEN
        --
        -- If master controlled and we are at master
        --
        IF (FND_API.TO_BOOLEAN(p_revision_master_controlled)
            AND
            FND_API.TO_BOOLEAN(p_is_master_org)
           ) THEN
          code_debug (' rev is master controlled and we are at master org ');
          --
          -- First get the revision code
          --
          SELECT REVISION INTO l_current_revision
          FROM MTL_ITEM_REVISIONS_B
          WHERE
            INVENTORY_ITEM_ID = l_pending_record.INVENTORY_ITEM_ID
            AND REVISION_ID = l_pending_record.REVISION_ID
            AND ORGANIZATION_ID = l_pending_record.ORGANIZATION_ID;
          --
          -- Update for all orgs
          --

          code_debug(' before check_floating_attachments 3');
          EGO_DOM_UTIL_PUB.check_floating_attachments (  p_inventory_item_id   => l_pending_record.INVENTORY_ITEM_ID
                                                         ,p_revision_id        => l_pending_record.REVISION_ID
                                                         ,p_organization_id    => l_pending_record.ORGANIZATION_ID
                                                         ,p_lifecycle_id       => NULL
                                                         ,p_new_phase_id       => l_pending_record.PHASE_ID
                                                         ,x_return_status      => x_return_status
                                                         ,x_msg_count          => x_msg_count
                                                         ,x_msg_data           => x_msg_data );

          code_debug(' after check_floating_attachments 3 ' || x_return_status);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF FND_API.To_Boolean( p_commit ) THEN
                        ROLLBACK TO Implement_All_Pending_Changes;
                END IF;
                RETURN;
          END IF;

          UPDATE MTL_ITEM_REVISIONS_B
          SET CURRENT_PHASE_ID = l_pending_record.PHASE_ID
          WHERE
            INVENTORY_ITEM_ID = l_pending_record.INVENTORY_ITEM_ID
            AND REVISION = l_current_revision
            AND ORGANIZATION_ID IN
                            (SELECT P2.ORGANIZATION_ID
                             FROM   MTL_PARAMETERS P1,
                                    MTL_PARAMETERS P2
                             WHERE  P1.ORGANIZATION_ID = p_organization_id
                             AND    P1.MASTER_ORGANIZATION_ID = P2.MASTER_ORGANIZATION_ID);

        ELSIF (FND_API.TO_BOOLEAN(p_revision_master_controlled) = FALSE) THEN
          code_debug (' rev is org controlled and we are at master org ');
          --
          -- Just update for the current one
          --
          code_debug(' before check_floating_attachments 4##########');
          EGO_DOM_UTIL_PUB.check_floating_attachments (  p_inventory_item_id   => l_pending_record.INVENTORY_ITEM_ID
                                                         ,p_revision_id        => l_pending_record.REVISION_ID
                                                         ,p_organization_id    => l_pending_record.ORGANIZATION_ID
                                                         ,p_lifecycle_id       => NULL
                                                         ,p_new_phase_id       => l_pending_record.PHASE_ID
                                                         ,x_return_status      => x_return_status
                                                         ,x_msg_count          => x_msg_count
                                                         ,x_msg_data           => x_msg_data );

          code_debug(' after check_floating_attachments 4 ' || x_return_status);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF FND_API.To_Boolean( p_commit ) THEN
                        ROLLBACK TO Implement_All_Pending_Changes;
                END IF;
                RETURN;
          END IF;

          UPDATE MTL_ITEM_REVISIONS_B
          SET CURRENT_PHASE_ID = l_pending_record.PHASE_ID
          WHERE
            INVENTORY_ITEM_ID = l_pending_record.INVENTORY_ITEM_ID
            AND REVISION_ID = l_pending_record.REVISION_ID
            AND ORGANIZATION_ID = l_pending_record.ORGANIZATION_ID;
        END IF;

        code_debug (' modifying the pending status table now ');
        IF (FND_API.TO_BOOLEAN(p_is_master_org)
            OR
            FND_API.TO_BOOLEAN(p_revision_master_controlled) = FALSE
           ) THEN
          UPDATE MTL_PENDING_ITEM_STATUS
          SET
            PENDING_FLAG = 'N'
           ,IMPLEMENTED_DATE = SYSDATE
          WHERE CURRENT OF l_pending_revision_statuses;
        END IF;

      END IF;

    END LOOP;

  END IF;

  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
    -- Call IP Intermedia Sync
    INV_ITEM_EVENTS_PVT.Sync_IP_IM_Index;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF FND_API.To_Boolean( p_commit ) THEN
        ROLLBACK TO Implement_All_Pending_Changes;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_encoded        => FND_API.G_FALSE,
        p_count          => x_msg_count,
        p_data           => x_msg_data
      );
  WHEN OTHERS THEN
    IF FND_API.To_Boolean(p_commit) THEN
      ROLLBACK TO Implement_All_Pending_Changes;
    END IF;
    IF c_item_pending_phase_change%ISOPEN THEN
      CLOSE c_item_pending_phase_change;
    END IF;
    IF c_rev_pending_phase_change%ISOPEN THEN
      CLOSE c_rev_pending_phase_change;
    END IF;
    x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.Set_Name(G_APP_NAME, G_PLSQL_ERR);
    FND_MESSAGE.Set_Token(G_PKG_NAME_TOKEN, G_PKG_NAME);
    FND_MESSAGE.Set_Token(G_API_NAME_TOKEN, 'IMPLEMENT_ALL_PENDING_CHANGES');
    FND_MESSAGE.Set_Token(G_SQL_ERR_MSG_TOKEN, SQLERRM);
    x_msg_count := 1;
    x_msg_data := FND_MESSAGE.GET;
--    x_return_status := FND_API.G_RET_STS_ERROR;
--    x_msg_data := FND_MESSAGE.Get_String('EGO', 'EGO_EXT_EXCEPTION_OCCURED');

END Implement_All_Pending_Changes;



----------------------------------------------------------------------
-- Public Procedures / Functions
----------------------------------------------------------------------

FUNCTION get_master_controlled_status RETURN VARCHAR2 IS
  l_status_master_controlled  VARCHAR2(100);
BEGIN
  l_status_master_controlled := FND_API.G_FALSE;
  SELECT DECODE(LOOKUP_CODE2,
                1, FND_API.G_TRUE,
                2, FND_API.G_FALSE,
                FND_API.G_FALSE)
  INTO l_status_master_controlled
  FROM MTL_ITEM_ATTRIBUTES_V
  WHERE ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVENTORY_ITEM_STATUS_CODE';

  RETURN l_status_master_controlled;
EXCEPTION
  WHEN OTHERS THEN
    RETURN l_status_master_controlled;
END get_master_controlled_status;


-------------------------------------------------------
FUNCTION get_master_org_status (p_organization_id  IN  NUMBER)
RETURN VARCHAR2 IS
  l_is_master_org  VARCHAR2(100);
BEGIN
  l_is_master_org := FND_API.G_FALSE;
  SELECT DECODE(MP.ORGANIZATION_ID,
                MP.MASTER_ORGANIZATION_ID, FND_API.G_TRUE,
                FND_API.G_FALSE)
  INTO l_is_master_org
  FROM MTL_PARAMETERS MP
  WHERE MP.ORGANIZATION_ID = p_organization_id;

  RETURN l_is_master_org;

EXCEPTION
  WHEN OTHERS THEN
    RETURN l_is_master_org;
END get_master_org_status;


-------------------------------------------------------
FUNCTION get_revision_id (p_inventory_item_id  IN  NUMBER
                         ,p_organization_id    IN  NUMBER
                         ,p_revision           IN  VARCHAR2)
RETURN NUMBER IS
  l_revision_id  NUMBER;
BEGIN
  l_revision_id := NULL;
  SELECT REVISION_ID
  INTO   l_revision_id
  FROM   MTL_ITEM_REVISIONS
  WHERE  INVENTORY_ITEM_ID = p_inventory_item_id
    AND  ORGANIZATION_ID = p_organization_id
    AND  revision = p_revision;
  RETURN l_revision_id;

EXCEPTION
  WHEN OTHERS THEN
    RETURN l_revision_id;
END get_revision_id;


-------------------------------------------------------
PROCEDURE Create_Pending_Phase_Change
(
  p_api_version                     IN   NUMBER
 ,p_commit                          IN   VARCHAR2
 ,p_inventory_item_id               IN   NUMBER
 ,p_item_number                     IN   VARCHAR2  DEFAULT NULL
 ,p_organization_id                 IN   NUMBER
 ,p_effective_date                  IN   DATE
 ,p_pending_flag                    IN   VARCHAR2
 ,p_revision                        IN   VARCHAR2
 ,p_revision_id                     IN   NUMBER    DEFAULT NULL
 ,p_lifecycle_id                    IN   NUMBER
 ,p_phase_id                        IN   NUMBER
 ,p_status_code                     IN   VARCHAR2  DEFAULT NULL
 ,p_change_id                       IN   NUMBER
 ,p_change_line_id                  IN   NUMBER
 ,p_perform_security_check          IN   VARCHAR2  DEFAULT 'F'
 ,x_return_status                   OUT  NOCOPY VARCHAR2
 ,x_errorcode                       OUT  NOCOPY NUMBER
 ,x_msg_count                       OUT  NOCOPY NUMBER
 ,x_msg_data                        OUT  NOCOPY VARCHAR2
 ) IS

  l_api_version        NUMBER;
  l_api_name           VARCHAR2(50);
  l_sysdate            DATE;
  l_revision           mtl_item_revisions_b.revision%TYPE;
  l_revision_id        mtl_pending_item_status.revision_id%TYPE;
  l_phase_id           mtl_pending_item_status.phase_id%TYPE;
  l_lifecycle_id       mtl_pending_item_status.lifecycle_id%TYPE;
  l_status_code        mtl_pending_item_status.status_code%TYPE;
  l_phase_id_curr      mtl_pending_item_status.phase_id%TYPE;
  l_lifecycle_id_itm   mtl_pending_item_status.lifecycle_id%TYPE;
  l_status_code_itm    mtl_pending_item_status.status_code%TYPE;
  l_status_code_def    mtl_pending_item_status.status_code%TYPE;
  l_pending_rec_count  NUMBER;
  l_item_number        MTL_SYSTEM_ITEMS_KFV.CONCATENATED_SEGMENTS%TYPE;
  l_org_name           HR_ALL_ORGANIZATION_UNITS_VL.NAME%TYPE;
  l_dummy_char         VARCHAR2(32767);
  l_approval_status    mtl_system_items_b.approval_status%TYPE;
  l_priv_name_to_check VARCHAR2(100);

  l_revision_master_controlled    VARCHAR2(1);
  l_status_master_controlled      VARCHAR2(1);
  l_is_master_org                 VARCHAR2(1);

  CURSOR c_get_rev_details (cp_item_id      IN  NUMBER
                           ,cp_org_id       IN  NUMBER
                           ,cp_revision     IN  VARCHAR2
                           ,cp_revision_id  IN  NUMBER) IS
  SELECT rev.current_phase_id, rev.lifecycle_id, rev.revision, rev.revision_id, item.approval_status
  FROM mtl_item_revisions_b rev, mtl_system_items_b item
  WHERE rev.inventory_item_id = cp_item_id
    AND rev.organization_id = cp_org_id
    AND rev.revision = NVL(cp_revision, rev.revision)
    AND rev.revision_id = NVL(cp_revision_id, rev.revision_id)
    AND item.inventory_item_id = rev.inventory_item_id
    AND item.organization_id = rev.organization_id;

  CURSOR c_get_item_details (cp_item_id  IN  NUMBER
                            ,cp_org_id   IN  NUMBER) IS
  SELECT current_phase_id, lifecycle_id, inventory_item_status_code, approval_status
  FROM mtl_system_items_b
  WHERE inventory_item_id = cp_item_id
    AND organization_id = cp_org_id;

  CURSOR c_get_def_status_code (cp_phase_id IN NUMBER) IS
  SELECT status.item_status_code
  FROM   ego_lcphase_item_status status, pa_proj_elements lc_phases
  WHERE  lc_phases.proj_element_id = cp_phase_id
    AND  status.phase_code = lc_phases.phase_code
    AND  status.default_flag = 'Y'
    AND  lc_phases.PROJECT_ID = 0 AND lc_phases.OBJECT_TYPE = 'PA_TASKS';

  CURSOR c_validate_status_code (cp_phase_id     IN NUMBER
                                ,cp_status_code  IN  VARCHAR2) IS
  SELECT status.item_status_code
  FROM   ego_lcphase_item_status status, pa_ego_phases_v lc_phases
  WHERE  lc_phases.proj_element_id = cp_phase_id
    AND  status.phase_code = lc_phases.phase_code
    AND  status.item_status_code = cp_status_code;

BEGIN

  l_api_version  := 1.0;
  l_api_name     := 'Create_Pending_Phase_Change';

  IF FND_API.To_Boolean(p_commit) THEN
    SAVEPOINT Create_Pending_Phase_Change_SP;
  END IF;
  code_debug( l_api_name ||' started with params');
  code_debug( l_api_name ||' p_inventory_item_id '|| p_inventory_item_id ||' p_organization_id '|| p_organization_id || ' p_revision '|| p_revision);
  code_debug( l_api_name ||' p_lifecycle_id '|| p_lifecycle_id ||' p_phase_id '|| p_phase_id ||' p_status_code '|| p_status_code);
  code_debug( l_api_name ||' p_pending_flag '|| p_pending_flag ||' p_change_id '|| p_change_id ||' p_change_line_id '|| p_change_line_id);

  --Standard checks
  IF NOT FND_API.Compatible_API_Call (l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,g_pkg_name)
  THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF Nvl(FND_GLOBAL.User_Id,-1) <> Nvl(G_CURRENT_USER_ID,-1)
  THEN
      G_CURRENT_USER_ID  := FND_GLOBAL.User_Id;
      G_CURRENT_LOGIN_ID := FND_GLOBAL.Login_Id;
  END IF;

  IF (p_inventory_item_id IS NULL
      OR
      p_organization_id IS NULL
      OR
      ( (p_revision IS NOT NULL OR p_revision_id IS NOT NULL) AND p_status_code IS NOT NULL)
      OR
      (p_phase_id IS NULL AND p_status_code IS NULL)
      ) THEN
    fnd_message.Set_Name(G_APP_NAME, 'EGO_API_INVALID_PARAMS');
    fnd_message.Set_Token(G_PKG_NAME_TOKEN, G_PKG_NAME);
    fnd_message.Set_Token(G_API_NAME_TOKEN, l_api_name);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_revision := p_revision;
  l_revision_id := p_revision_id;

  IF (l_revision IS NULL AND l_revision_id IS NULL) THEN
    OPEN c_get_item_details (cp_item_id => p_inventory_item_id
                            ,cp_org_id  => p_organization_id);
    FETCH c_get_item_details
    INTO l_phase_id_curr, l_lifecycle_id_itm, l_status_code_itm, l_approval_status;
    IF c_get_item_details%NOTFOUND THEN
      l_phase_id_curr := NULL;
      l_lifecycle_id_itm := NULL;
    END IF;
    CLOSE c_get_item_details;
  ELSE
    l_status_code_itm := NULL;
    OPEN c_get_rev_details (cp_item_id      => p_inventory_item_id
                           ,cp_org_id       => p_organization_id
                           ,cp_revision     => l_revision
                           ,cp_revision_id  => l_revision_id);
    FETCH c_get_rev_details
    INTO l_phase_id_curr, l_lifecycle_id_itm, l_revision, l_revision_id, l_approval_status;
    IF c_get_rev_details%NOTFOUND THEN
      l_phase_id_curr := NULL;
      l_lifecycle_id_itm := NULL;
      l_revision_id := NULL;
    END IF;
    CLOSE c_get_rev_details;
  END IF;

  code_debug( l_api_name ||' curr values - current_phase_id '||l_phase_id_curr||' lifecycle_id '||l_lifecycle_id_itm||' status_code '||l_status_code_itm );

  -- bug 3909677
  IF NVL(l_approval_status,'A') <> 'A' THEN
    fnd_message.Set_Name(G_APP_NAME, 'EGO_ITEM_NOT_READY_FOR_CHANGE');
    SELECT CONCATENATED_SEGMENTS
      INTO l_dummy_char
      FROM MTL_SYSTEM_ITEMS_KFV
     WHERE INVENTORY_ITEM_ID = p_inventory_item_id
       AND ORGANIZATION_ID = p_organization_id;
    fnd_message.set_token('ITEM_NUMBER', l_dummy_char);
    SELECT name
      INTO l_dummy_char
      FROM hr_all_organization_units_vl
     WHERE organization_id = p_organization_id;
    fnd_message.set_token('ORGANIZATION', l_dummy_char);
    fnd_msg_pub.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF FND_API.To_Boolean(p_perform_security_check) THEN
    code_debug( l_api_name ||' need to perform security check ');
    -- 4052565 perform security check
    l_priv_name_to_check := get_privlige_name_for_action
                      (p_curr_item_id     => p_inventory_item_id
                      ,p_curr_org_id      => p_organization_id
                      ,p_curr_rev_id      => l_revision_id
                      ,p_curr_lc_id       => l_lifecycle_id_itm
                      ,p_curr_phase_id    => l_phase_id_curr
                      ,p_curr_status_code => l_status_code_itm
                      ,p_new_lc_id        => p_lifecycle_id
                      ,p_new_phase_id     => p_phase_id
                      ,p_new_status_code  => p_status_code
                      );
    code_debug( l_api_name ||' priv check name '||l_priv_name_to_check);
    IF l_priv_name_to_check IS NOT NULL THEN
      IF NOT EGO_ITEM_PVT.has_role_on_item
                       (p_function_name      => l_priv_name_to_check
                       ,p_inventory_item_id  => p_inventory_item_id
                       ,p_item_number        => p_item_number
                       ,p_organization_id    => p_organization_id
                       ,p_organization_name  => NULL
                       ,p_user_id            => G_CURRENT_USER_ID
                       ,p_party_id           => NULL
                       ,p_set_message        => FND_API.G_TRUE
                       ) THEN
        code_debug( l_api_name ||' user does not have privilege for '||l_priv_name_to_check);
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        code_debug( l_api_name ||' user can perform the action '||l_priv_name_to_check);
      END IF;
    END IF;
  ELSE
    code_debug( l_api_name ||' NO need to perform security check ');
  END IF;

  IF p_phase_id IS NOT NULL THEN
    --
    -- if status is not passed, get the default status code
    --
    l_phase_id := p_phase_id;
    l_lifecycle_id := NVL(p_lifecycle_id, l_lifecycle_id_itm);
    IF p_status_code IS NULL THEN
      -- get the default phase for the new phase
      OPEN c_get_def_status_code (cp_phase_id => p_phase_id);
      FETCH c_get_def_status_code INTO l_status_code_def;
      IF c_get_def_status_code%NOTFOUND THEN
        CLOSE c_get_def_status_code;
        SELECT name
        INTO l_dummy_char
        FROM PA_EGO_PHASES_V
        WHERE proj_element_id = p_phase_id;
        fnd_message.Set_Name(G_APP_NAME, 'EGO_NO_STATUS_FOR_PHASE_ERR');
        fnd_message.Set_Token('PHASE', l_dummy_char);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        CLOSE c_get_def_status_code;
      END IF;
    ELSE
      l_status_code_def := NULL;
    END IF;  -- p_status_code IS NULL
    --
    -- user trying to do a phase change
    --
    IF (NVL(l_phase_id_curr,-1) <> p_phase_id) THEN
      SELECT count(*)
      INTO l_pending_rec_count
      FROM mtl_pending_item_status
      WHERE inventory_item_id = p_inventory_item_id
        AND organization_id = p_organization_id
        AND pending_flag = 'Y'
        AND implemented_date IS NULL
        AND NVL(revision_id,-1) = NVL(l_revision_id,-1)
        AND lifecycle_id IS NOT NULL
        AND phase_id IS NOT NULL;
      IF l_pending_rec_count <> 0 THEN
        --
        -- pending chanes already exist
        --
        IF p_item_number IS NULL THEN
          SELECT concatenated_segments
          INTO l_dummy_char
          FROM mtl_system_items_b_kfv
          WHERE inventory_item_id = p_inventory_item_id
          AND   organization_id = p_organization_id;
        ELSE
          l_dummy_char := p_item_number;
        END IF;
        IF l_revision_id IS NULL THEN
          fnd_message.Set_Name(G_APP_NAME, 'EGO_ITEM_PENDING_PHASE_CHANGE');
          fnd_message.Set_Token('ITEM_NUMBER', l_dummy_char);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          fnd_message.Set_Name(G_APP_NAME, 'EGO_REV_PENDING_PHASE_CHANGE');
          fnd_message.Set_Token('ITEM_NUMBER', l_dummy_char);
          fnd_message.Set_Token('REVISION', l_revision);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;  -- l_pending_rec_count
    END IF;    -- NVL(l_phase_id_curr,-1) <> p_phase_id
  ELSE
    l_phase_id := NULL;
    l_lifecycle_id := NULL;
  END IF;      -- phase id is not null
  code_debug( l_api_name ||' no pending phase changes ');

  IF l_revision IS NULL THEN
    -- check if the current status is valid
    OPEN c_validate_status_code (cp_phase_id    => NVL(p_phase_id,l_phase_id_curr)
                                ,cp_status_code => NVL(p_status_code,l_status_code_def)
                                );
    FETCH c_validate_status_code INTO l_status_code;
    IF c_validate_status_code%NOTFOUND THEN
      CLOSE c_validate_status_code;
      fnd_message.Set_Name(G_APP_NAME, 'EGO_ITEM_INVALID_STATUS');
      fnd_message.Set_Token('STATUS', p_status_code);
      SELECT name
      INTO l_dummy_char
      FROM PA_EGO_PHASES_V
      WHERE proj_element_id = NVL(p_phase_id,l_phase_id_curr);
      fnd_message.Set_Token('PHASE', l_dummy_char);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      code_debug (l_api_name ||' checking for master controlled status ');
      l_is_master_org := get_master_org_status(p_organization_id);
      l_revision_master_controlled := FND_API.g_false;
      l_status_master_controlled := get_master_controlled_status();
      IF ('T' = l_status_master_controlled) AND NOT ('T' = l_is_master_org) THEN
        IF l_status_code_itm <> l_status_code THEN
          code_debug (l_api_name ||' status changes controlled at master cannot change ');
          fnd_message.Set_Name(G_APP_NAME,'EGO_ITEM_STATUS_MC');
          fnd_msg_pub.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF; -- status is master controlled and we are in context of child org
    END IF;  -- status is valid
  ELSE
    -- context of revision
    l_status_code := NULL;
  END IF;    -- revision IS NULL
    code_debug(' comparing values before insert p_lifecycle_id '||p_lifecycle_id ||' l_lifecycle_id '||l_lifecycle_id);
    --
    -- to be removed after bug 3874132 is resoloved.
    --
    l_sysdate := SYSDATE;
    INSERT INTO MTL_PENDING_ITEM_STATUS
    (
      inventory_item_id
     ,organization_id
     ,status_code
     ,effective_date
     ,implemented_date
     ,pending_flag
     ,last_update_date
     ,last_updated_by
     ,creation_date
     ,created_by
     ,last_update_login
--     ,request_id
--     ,program_update_date
     ,revision_id
     ,lifecycle_id
     ,phase_id
     ,change_id
     ,change_line_id
    )
    VALUES
    (
      p_inventory_item_id
     ,p_organization_id
     ,l_status_code
     ,NVL(p_effective_date,l_sysdate)
     ,NULL
     ,NVL(p_pending_flag,'Y')
     ,l_sysdate
     ,G_CURRENT_USER_ID
     ,l_sysdate
     ,G_CURRENT_USER_ID
     ,G_CURRENT_LOGIN_ID
--     ,NULL
--     ,l_sysdate
     ,l_revision_id
     ,l_lifecycle_id
     ,l_phase_id
     ,p_change_id
     ,p_change_line_id
    );

  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF FND_API.To_Boolean( p_commit ) THEN
        ROLLBACK TO Create_Pending_Phase_Change_SP;
      END IF;
      IF  c_get_rev_details%ISOPEN THEN
        CLOSE c_get_rev_details;
      END IF;
      IF  c_get_item_details%ISOPEN THEN
        CLOSE c_get_item_details;
      END IF;
      IF  c_get_def_status_code%ISOPEN THEN
        CLOSE c_get_def_status_code;
      END IF;
      IF  c_validate_status_code%ISOPEN THEN
        CLOSE c_validate_status_code;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Create_Pending_Phase_Change_SP;
      END IF;
      IF  c_get_rev_details%ISOPEN THEN
        CLOSE c_get_rev_details;
      END IF;
      IF  c_get_item_details%ISOPEN THEN
        CLOSE c_get_item_details;
      END IF;
      IF  c_get_def_status_code%ISOPEN THEN
        CLOSE c_get_def_status_code;
      END IF;
      IF  c_validate_status_code%ISOPEN THEN
        CLOSE c_validate_status_code;
      END IF;
      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.Set_Name(g_app_name, g_plsql_err);
      FND_MESSAGE.Set_Token(g_pkg_name_token, g_pkg_name);
      FND_MESSAGE.Set_Token(g_api_name_token, l_api_name);
      FND_MESSAGE.Set_Token(g_sql_err_msg_token, SQLERRM);
      FND_MSG_PUB.Add;
END Create_Pending_Phase_Change;


-------------------------------------------------------
PROCEDURE Modify_Pending_Phase_Change
  (p_api_version                    IN   NUMBER
  ,p_commit                         IN   VARCHAR2
  ,p_transaction_type               IN   VARCHAR2
  ,p_inventory_item_id              IN   NUMBER
  ,p_organization_id                IN   NUMBER
  ,p_revision_id                    IN   NUMBER
  ,p_lifecycle_id                   IN   NUMBER
  ,p_phase_id                       IN   NUMBER
  ,p_status_code                    IN   VARCHAR2
  ,p_change_id                      IN   NUMBER
  ,p_change_line_id                 IN   NUMBER
  ,p_effective_date                 IN   DATE
  ,p_new_effective_date             IN   DATE
  ,p_perform_security_check         IN   VARCHAR2
  ,x_return_status                  OUT  NOCOPY VARCHAR2
  ,x_errorcode                      OUT  NOCOPY NUMBER
  ,x_msg_count                      OUT  NOCOPY NUMBER
  ,x_msg_data                       OUT  NOCOPY VARCHAR2
  ) IS

  l_api_version         NUMBER;
  l_api_name            VARCHAR2(50);
  l_miss_num            NUMBER;
  l_miss_char           VARCHAR2(1);
  l_priv_name_to_check  VARCHAR2(100);


  BEGIN
    l_api_version      := 1.0;
    l_api_name         := 'Modify_Pending_Phase_Change';
    l_miss_num         := FND_API.G_MISS_NUM;
    l_miss_char        := FND_API.G_MISS_CHAR;

    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Modify_Pending_Phase_Change_SP;
    END IF;

    --Standard checks
    IF NOT FND_API.Compatible_API_Call (l_api_version
                                       ,p_api_version
                                       ,l_api_name
                                       ,g_pkg_name)
    THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF Nvl(FND_GLOBAL.User_Id,-1) <> Nvl(G_CURRENT_USER_ID,-1)
    THEN
      G_CURRENT_USER_ID  := FND_GLOBAL.User_Id;
      G_CURRENT_LOGIN_ID := FND_GLOBAL.Login_Id;
    END IF;


    IF ( p_inventory_item_id IS NULL
         OR
         p_organization_id IS NULL
         OR
         p_effective_date IS NULL
         OR
         p_transaction_type NOT IN (EGO_ITEM_PUB.G_TTYPE_UPDATE, EGO_ITEM_PUB.G_TTYPE_DELETE)
      ) THEN
      fnd_message.Set_Name(G_APP_NAME, 'EGO_API_INVALID_PARAMS');
      fnd_message.Set_Token(G_PKG_NAME_TOKEN, G_PKG_NAME);
      fnd_message.Set_Token(G_API_NAME_TOKEN, l_api_name);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.To_Boolean(p_perform_security_check) THEN
      -- 4052565 perform security check
      l_priv_name_to_check := get_privlige_name_for_action
                        (p_curr_item_id     => p_inventory_item_id
                        ,p_curr_org_id      => p_organization_id
                        ,p_curr_rev_id      => p_revision_id
                        ,p_curr_lc_id       => NULL
                        ,p_curr_phase_id    => NULL
                        ,p_curr_status_code => NULL
                        ,p_new_lc_id        => p_lifecycle_id
                        ,p_new_phase_id     => p_phase_id
                        ,p_new_status_code  => p_status_code
                        );
      IF l_priv_name_to_check IS NOT NULL THEN
        IF NOT EGO_ITEM_PVT.has_role_on_item
                            (p_function_name      => l_priv_name_to_check
                            ,p_inventory_item_id  => p_inventory_item_id
                            ,p_item_number        => NULL
                            ,p_organization_id    => p_organization_id
                            ,p_organization_name  => NULL
                            ,p_user_id            => G_CURRENT_USER_ID
                            ,p_party_id           => NULL
                            ,p_set_message        => FND_API.G_TRUE
                            ) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    END IF;

    IF p_transaction_type = EGO_ITEM_PUB.G_TTYPE_UPDATE THEN
      --
      -- to be removed after bug 3874132 is resoloved.
      --
      code_debug(l_api_name|| ' Updating pending change record ');
      UPDATE mtl_pending_item_status
      SET    effective_date     = p_new_effective_date,
             last_update_date   = SYSDATE,
             last_updated_by    = G_CURRENT_USER_ID,
             last_update_login  = G_CURRENT_LOGIN_ID
      WHERE  inventory_item_id                 = p_inventory_item_id
        AND  organization_id                   = p_organization_id
        AND  NVL(revision_id,l_miss_num)       = NVL(p_revision_id, l_miss_num)
        AND  NVL(lifecycle_id, l_miss_num)     = NVL(p_lifecycle_id, l_miss_num)
        AND  NVL(phase_id, l_miss_num)         = NVL(p_phase_id, l_miss_num)
        AND  NVL(status_code,l_miss_char)      = NVL(p_status_code, l_miss_char)
        AND  NVL(p_change_id, l_miss_num)      = NVL(p_change_id, l_miss_num)
        AND  NVL(p_change_line_id, l_miss_num) = NVL(p_change_line_id, l_miss_num)
        AND  effective_date                    = p_effective_date
        AND  pending_flag                      = 'Y'
        AND  implemented_date IS NULL;
      IF SQL%ROWCOUNT = 0 THEN
        code_debug(l_api_name|| ' cannot update record!! ');
        -- no records found for update
        fnd_message.Set_Name(G_APP_NAME, 'EGO_NO_REC_UPDATE');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    ELSIF p_transaction_type = EGO_ITEM_PUB.G_TTYPE_DELETE THEN
      --
      -- to be removed after bug 3874132 is resoloved.
      --
      code_debug(l_api_name|| ' Deleting pending change record ');
      DELETE mtl_pending_item_status
      WHERE  inventory_item_id                 = p_inventory_item_id
        AND  organization_id                   = p_organization_id
        AND  NVL(revision_id,l_miss_num)       = NVL(p_revision_id, l_miss_num)
        AND  NVL(lifecycle_id, l_miss_num)     = NVL(p_lifecycle_id, l_miss_num)
        AND  NVL(phase_id, l_miss_num)         = NVL(p_phase_id, l_miss_num)
        AND  NVL(status_code,l_miss_char)      = NVL(p_status_code, l_miss_char)
        AND  NVL(p_change_id, l_miss_num)      = NVL(p_change_id, l_miss_num)
        AND  NVL(p_change_line_id, l_miss_num) = NVL(p_change_line_id, l_miss_num)
        AND  effective_date                    = p_effective_date
        AND  pending_flag                      = 'Y'
        AND  implemented_date IS NULL;
      IF SQL%ROWCOUNT = 0 THEN
        -- no records found for delete
        fnd_message.Set_Name(G_APP_NAME, 'EGO_NO_REC_DELETE');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF FND_API.To_Boolean( p_commit ) THEN
        ROLLBACK TO Create_Pending_Phase_Change_SP;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;

END Modify_Pending_Phase_change;



/***
PROCEDURE Delete_Pending_Phase_Change
(
  p_api_version                     IN   NUMBER
 ,p_commit                          IN   VARCHAR2
 ,p_inventory_item_id               IN   NUMBER
 ,p_organization_id                 IN   NUMBER
 ,p_change_id                       IN   NUMBER
 ,p_change_line_id                  IN   NUMBER
 ,x_return_status                   OUT  NOCOPY VARCHAR2
 ,x_errorcode                       OUT  NOCOPY NUMBER
 ,x_msg_count                       OUT  NOCOPY NUMBER
 ,x_msg_data                        OUT  NOCOPY VARCHAR2
 ) IS

  l_api_version      NUMBER;
  l_api_name         VARCHAR2(50);

BEGIN
  l_api_version      := 1.0;
  l_api_name         := 'Delete_Pending_Phase_Change';
  --Standard checks
  IF NOT FND_API.Compatible_API_Call (l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,g_pkg_name)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF ( (p_inventory_item_id IS NULL
        AND
        p_change_id IS NULL
        AND
        p_change_line_id IS NULL
        )
      OR
      p_organization_id IS NULL
      ) THEN
    x_return_status :=  FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  IF FND_API.To_Boolean(p_commit) THEN
    SAVEPOINT Delete_Pending_Phase_Change_SP;
  END IF;

  IF p_change_id IS NOT NULL THEN
    IF p_change_line_id IS NOT NULL THEN
      IF p_inventory_item_id IS NOT NULL THEN
        --
        -- change_id, change_line_id, inventory_item_id present
        --
        DELETE MTL_PENDING_ITEM_STATUS
        WHERE  organization_id   = p_organization_id
          AND  inventory_item_id = p_inventory_item_id
          AND  change_id         = p_change_id
          AND  change_line_id    = p_change_line_id
          AND  implemented_date IS NULL
          AND  pending_flag = 'Y';
      ELSE
        --
        -- change_id, change_line_id present
        --
        DELETE MTL_PENDING_ITEM_STATUS
        WHERE  organization_id   = p_organization_id
          AND  change_id         = p_change_id
          AND  change_line_id    = p_change_line_id
          AND  implemented_date IS NULL
          AND  pending_flag = 'Y';
      END IF;
    ELSE  -- change line id is null
      IF p_inventory_item_id IS NOT NULL THEN
        --
        -- change_id, inventory_item_id present
        --
        DELETE MTL_PENDING_ITEM_STATUS
        WHERE  organization_id   = p_organization_id
          AND  inventory_item_id = p_inventory_item_id
          AND  change_id         = p_change_id
          AND  implemented_date IS NULL
          AND  pending_flag = 'Y';
      ELSE
        --
        -- only change_id present
        --
        DELETE MTL_PENDING_ITEM_STATUS
        WHERE  organization_id   = p_organization_id
          AND  change_id         = p_change_id
          AND  implemented_date IS NULL
          AND  pending_flag = 'Y';
      END IF;
    END IF;
  ELSE   -- change id is null
    IF p_change_line_id IS NOT NULL THEN
      IF p_inventory_item_id IS NOT NULL THEN
        --
        -- change_line_id, inventory_item_id present
        --
        DELETE MTL_PENDING_ITEM_STATUS
        WHERE  organization_id   = p_organization_id
          AND  inventory_item_id = p_inventory_item_id
          AND  change_line_id    = p_change_line_id
          AND  implemented_date IS NULL
          AND  pending_flag = 'Y';
      ELSE
        --
        -- only change_line_id present
        --
        DELETE MTL_PENDING_ITEM_STATUS
        WHERE  organization_id   = p_organization_id
          AND  change_line_id    = p_change_line_id
          AND  implemented_date IS NULL
          AND  pending_flag = 'Y';
      END IF;
    ELSE  -- change line id is null
      IF p_inventory_item_id IS NOT NULL THEN
        --
        -- only inventory_item_id present
        -- delete where change_id and change_line_id are null
        --
        DELETE MTL_PENDING_ITEM_STATUS
        WHERE  organization_id   = p_organization_id
          AND  inventory_item_id = p_inventory_item_id
          AND  change_id        IS NULL
          AND  change_line_id   IS NULL
          AND  implemented_date IS NULL
          AND  pending_flag = 'Y';
      END IF;
    END IF;
  END IF;

  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Delete_Pending_Phase_Change_SP;
      END IF;
      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.Set_Name(g_app_name, g_plsql_err);
      FND_MESSAGE.Set_Token(g_pkg_name_token, g_pkg_name);
      FND_MESSAGE.Set_Token(g_api_name_token, l_api_name);
      FND_MESSAGE.Set_Token(g_sql_err_msg_token, SQLERRM);
      FND_MSG_PUB.Add;

END Delete_Pending_Phase_Change;
***/

PROCEDURE Implement_Pending_Changes
(
     p_api_version                 IN   NUMBER
   , p_inventory_item_id           IN   NUMBER
   , p_organization_id             IN   NUMBER
   , p_revision_id                 IN   NUMBER
   , p_revision_master_controlled  IN   VARCHAR2
   , p_status_master_controlled    IN   VARCHAR2
   , p_is_master_org               IN   VARCHAR2
   , p_perform_security_check      IN   VARCHAR2   DEFAULT 'F'
   , x_return_status               OUT  NOCOPY VARCHAR2
   , x_errorcode                   OUT  NOCOPY NUMBER
   , x_msg_count                   OUT  NOCOPY NUMBER
   , x_msg_data                    OUT  NOCOPY VARCHAR2
) IS

  l_commit  VARCHAR2(1);

BEGIN
  --
  -- existing functionality is doing a commit always
  --
  code_debug(' Implement Pending Changes from Projects area item id '||p_inventory_item_id||' org id '||p_organization_id||' rev id '||p_revision_id);
  l_commit := FND_API.G_TRUE;
  Implement_All_Pending_Changes
       (p_api_version                  => p_api_version
       ,p_commit                       => l_commit
       ,p_inventory_item_id            => p_inventory_item_id
       ,p_organization_id              => p_organization_id
       ,p_revision_id                  => p_revision_id
       ,p_change_id                    => NULL
       ,p_change_line_id               => NULL
       ,p_revision_master_controlled   => p_revision_master_controlled
       ,p_status_master_controlled     => p_status_master_controlled
       ,p_is_master_org                => p_is_master_org
       ,p_perform_security_check       => p_perform_security_check
       ,x_return_status                => x_return_status
       ,x_errorcode                    => x_errorcode
       ,x_msg_count                    => x_msg_count
       ,x_msg_data                     => x_msg_data
       );

END Implement_Pending_Changes;

--
-- Created as a part of Fix for 3371749
--
PROCEDURE Implement_Pending_Changes
(
     p_api_version                 IN   NUMBER
   , p_commit                      IN   VARCHAR2
   , p_change_id                   IN   NUMBER
   , p_change_line_id              IN   NUMBER
   , p_perform_security_check      IN   VARCHAR2  DEFAULT 'F'
   , x_return_status               OUT  NOCOPY VARCHAR2
   , x_errorcode                   OUT  NOCOPY NUMBER
   , x_msg_count                   OUT  NOCOPY NUMBER
   , x_msg_data                    OUT  NOCOPY VARCHAR2
)
IS

  l_api_version      NUMBER;
  l_api_name         VARCHAR2(50);

  l_revision_master_controlled    VARCHAR2(1);
  l_status_master_controlled      VARCHAR2(1);
  l_is_master_org                 VARCHAR2(1);

  CURSOR c_get_pending_items (cp_change_id       IN  NUMBER
                           ,cp_change_line_id  IN  NUMBER) IS
  SELECT *
  FROM  mtl_pending_item_status
  WHERE implemented_date IS NULL
    AND pending_flag = 'Y'
    AND change_id = NVL(cp_change_id, change_id)
    AND change_line_id = NVL(cp_change_line_id, change_line_id);

BEGIN

  l_api_version      := 1.0;
  l_api_name         := 'Implement_Pending_Changes';
  code_debug(' Implement Pending Changes from Change area ');
  --Standard checks
  IF NOT FND_API.Compatible_API_Call (l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,g_pkg_name)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (p_change_id IS NULL AND p_change_line_id IS NULL) THEN
    FND_MESSAGE.Set_name(G_APP_NAME, 'EGO_API_INVALID_PARAMS');
    FND_MESSAGE.Set_token('PKG_NAME', G_PKG_NAME);
    FND_MESSAGE.Set_Token('PROC_NAME', l_api_name);
    x_msg_data := FND_MESSAGE.get();
    x_msg_count := 1;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  IF FND_API.To_Boolean(p_commit) THEN
    SAVEPOINT Implement_Pending_Changes_SP;
  END IF;

  l_revision_master_controlled := FND_API.g_false;
  l_status_master_controlled := EGO_ITEM_LC_IMP_PC_PUB.get_master_controlled_status();

  FOR l_item_record IN
           c_get_pending_items (cp_change_id      => p_change_id
                               ,cp_change_line_id => p_change_line_id)
  LOOP

      l_is_master_org := get_master_org_status(l_item_record.ORGANIZATION_ID);
      Implement_All_Pending_Changes
              (p_api_version                  => p_api_version
              ,p_commit                       => FND_API.G_FALSE
              ,p_inventory_item_id            => l_item_record.INVENTORY_ITEM_ID
              ,p_organization_id              => l_item_record.ORGANIZATION_ID
              ,p_revision_id                  => l_item_record.REVISION_ID
              ,p_change_id                    => p_change_id
              ,p_change_line_id               => p_change_line_id
              ,p_revision_master_controlled   => l_revision_master_controlled
              ,p_status_master_controlled     => l_status_master_controlled
              ,p_is_master_org                => l_is_master_org
              ,p_perform_security_check       => p_perform_security_check
              ,x_return_status                => x_return_status
              ,x_errorcode                    => x_errorcode
              ,x_msg_count                    => x_msg_count
              ,x_msg_data                     => x_msg_data
              );
      EXIT WHEN x_return_status <> FND_API.G_RET_STS_SUCCESS;
  END LOOP;

  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
  ELSE
    IF x_msg_count <>1 THEN
      FND_MSG_PUB.Count_And_Get(
         p_encoded        => FND_API.G_FALSE,
         p_count          => x_msg_count,
         p_data           => x_msg_data
         );
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF c_get_pending_items%ISOPEN THEN
      CLOSE c_get_pending_items;
    END IF;
    IF FND_API.To_Boolean(p_commit) THEN
      ROLLBACK TO Implement_Pending_Changes_SP;
    END IF;
    x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.Set_Name(g_app_name, g_plsql_err);
    FND_MESSAGE.Set_Token(g_pkg_name_token, g_pkg_name);
    FND_MESSAGE.Set_Token(g_api_name_token, l_api_name);
    FND_MESSAGE.Set_Token(g_sql_err_msg_token, SQLERRM);
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_And_Get(
       p_encoded        => FND_API.G_FALSE,
       p_count          => x_msg_count,
       p_data           => x_msg_data
       );

END Implement_Pending_Changes;


PROCEDURE Implement_Pending_Changes_CP
(
     ERRBUF                        OUT  NOCOPY VARCHAR2
   , RETCODE                       OUT  NOCOPY NUMBER
   , p_organization_id             IN   MTL_SYSTEM_ITEMS_B.ORGANIZATION_ID%TYPE
   , p_inventory_item_id           IN   MTL_SYSTEM_ITEMS_B.INVENTORY_ITEM_ID%TYPE
   , p_revision_code               IN   MTL_ITEM_REVISIONS_B.REVISION%TYPE
)
IS

  TYPE ORG_TABLE IS TABLE OF MTL_SYSTEM_ITEMS_B.ORGANIZATION_ID%TYPE;
  TYPE ITEM_TABLE IS TABLE OF MTL_SYSTEM_ITEMS_B.INVENTORY_ITEM_ID%TYPE;
  TYPE REV_TABLE IS TABLE OF MTL_ITEM_REVISIONS_B.REVISION%TYPE;

  l_revision_master_controlled    VARCHAR2(1);
  l_status_master_controlled      VARCHAR2(1);
  l_is_master_org                 VARCHAR2(1);

  l_return_status                 VARCHAR2(1);
  l_errorcode                     NUMBER;
  l_msg_count                     NUMBER;
  l_msg_data                      VARCHAR2(4000);

  l_orgs                          ORG_TABLE;
  l_items                         ITEM_TABLE;
  l_revs                          REV_TABLE;
  l_revision_id                   MTL_ITEM_REVISIONS_B.REVISION_ID%TYPE;
  l_master_org                    MTL_ITEM_REVISIONS_B.ORGANIZATION_ID%TYPE;

l_ret VARCHAR2(1);
l_error_mesg VARCHAR2(4000);


BEGIN

  code_debug(' Implement Pending Changes from Concurrent Program ');
  SELECT
    DECODE(LOOKUP_CODE2, 1, FND_API.G_TRUE, 2, FND_API.G_FALSE, FND_API.G_FALSE) INTO l_status_master_controlled
  FROM
    MTL_ITEM_ATTRIBUTES_V
  WHERE
    ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVENTORY_ITEM_STATUS_CODE';

  l_revision_master_controlled := FND_API.G_FALSE;

  --If there is no organization id, then do everything
  IF p_organization_id IS NULL
  THEN

    SELECT
      ORGANIZATION_ID BULK COLLECT INTO l_orgs
    FROM
      ORG_ACCESS_VIEW
    WHERE RESPONSIBILITY_ID = FND_GLOBAL.RESP_ID
    AND RESP_APPLICATION_ID = FND_GLOBAL.RESP_APPL_ID;

  ELSE

    l_orgs := ORG_TABLE(p_organization_id);

  END IF;

  --For each org
  IF (l_orgs IS NOT NULL AND l_orgs.COUNT > 0)
  THEN

    FOR org_index IN l_orgs.FIRST..l_orgs.LAST
    LOOP

      BEGIN

        --Select the master org
        SELECT
          MP.MASTER_ORGANIZATION_ID INTO l_master_org
        FROM
          MTL_PARAMETERS MP
        WHERE
          MP.ORGANIZATION_ID = l_orgs(org_index);

        l_is_master_org := FND_API.G_FALSE;

        IF l_master_org = l_orgs(org_index)
        THEN
          l_is_master_org := FND_API.G_TRUE;
        END IF;

        --If item is null, then get them all
        IF p_inventory_item_id IS NULL
        THEN

          SELECT
            INVENTORY_ITEM_ID BULK COLLECT INTO l_items
          FROM
            MTL_SYSTEM_ITEMS_B
          WHERE
            ORGANIZATION_ID = l_orgs(org_index);

        ELSE

          l_items := ITEM_TABLE(p_inventory_item_id);

        END IF;

        IF (l_items IS NOT NULL AND l_items.COUNT > 0)
        THEN

          --For each item
          FOR item_index IN l_items.FIRST..l_items.LAST
          LOOP

            BEGIN

              IF p_revision_code = 'ALL' OR p_revision_code is NULL
              THEN

                SELECT
                  REVISION BULK COLLECT INTO l_revs
                FROM
                  MTL_ITEM_REVISIONS_B
                WHERE ORGANIZATION_ID = l_orgs(org_index)
                      AND INVENTORY_ITEM_ID = l_items(item_index);

                --If it's all, then also add a null entry to mean no revision
                --(NULL will do the work of 'ALL' plus 'NONE')
                l_revs.EXTEND();

              ELSIF p_revision_code = 'NONE'
              THEN

                l_revs := REV_TABLE(NULL);

              ELSE

                l_revs := REV_TABLE(p_revision_code);

              END IF;

              IF (l_revs IS NOT NULL AND l_revs.COUNT > 0)
              THEN

                FOR rev_index IN l_revs.FIRST..l_revs.LAST
                LOOP

                  BEGIN

                    --First we need to get the revision_id
                    l_revision_id := NULL;

                    IF l_revs(rev_index) IS NOT NULL
                    THEN

                      --Either the master or current
                      IF FND_API.To_Boolean(l_revision_master_controlled)
                      THEN

                        SELECT
                          REVISION_ID INTO l_revision_id
                        FROM
                          MTL_ITEM_REVISIONS_B
                        WHERE
                          ORGANIZATION_ID = l_master_org
                          AND INVENTORY_ITEM_ID = l_items(item_index)
                          AND REVISION = l_revs(rev_index);

                      ELSE

                        SELECT
                          REVISION_ID INTO l_revision_id
                        FROM
                          MTL_ITEM_REVISIONS_B
                        WHERE
                          ORGANIZATION_ID = l_orgs(org_index)
                          AND INVENTORY_ITEM_ID = l_items(item_index)
                          AND REVISION = l_revs(rev_index);

                      END IF; -- select rev id

                    END IF; -- if revision is not null

                    Implement_Pending_Changes
                    (
                          p_api_version                 => 1.0
                        , p_inventory_item_id           => l_items(item_index)
                        , p_organization_id             => l_orgs(org_index)
                        , p_revision_id                 => l_revision_id
                        , p_revision_master_controlled  => l_revision_master_controlled
                        , p_status_master_controlled    => l_status_master_controlled
                        , p_is_master_org               => l_is_master_org
                        , p_perform_security_check      => FND_API.G_FALSE
                        , x_return_status               => l_return_status
                        , x_errorcode                   => l_errorcode
                        , x_msg_count                   => l_msg_count
                        , x_msg_data                    => l_msg_data
                    );

                  EXCEPTION

                    WHEN OTHERS
                    THEN
                      NULL;

                  END; -- rev block

                END LOOP; -- for each rev

              END IF;

            EXCEPTION

              WHEN OTHERS
              THEN
                NULL;

            END; -- item block

          END LOOP; -- for each item

        END IF; -- if there are any items

      EXCEPTION

        WHEN OTHERS
        THEN
          NULL;

      END; -- org block

    END LOOP; -- for each org

  END IF; -- if there are any orgs

  RETCODE := G_SUCCESS;
  ERRBUF := FND_MESSAGE.Get_String('EGO', 'EGO_IPC_SUCCESS');

END Implement_Pending_Changes_CP;

END EGO_ITEM_LC_IMP_PC_PUB;


/
