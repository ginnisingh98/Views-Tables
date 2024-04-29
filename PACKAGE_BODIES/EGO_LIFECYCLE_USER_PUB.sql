--------------------------------------------------------
--  DDL for Package Body EGO_LIFECYCLE_USER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_LIFECYCLE_USER_PUB" AS
/* $Header: EGOPLCUB.pls 120.4 2007/05/30 10:49:09 srajapar ship $ */

  g_pkg_name                 CONSTANT VARCHAR2(30) := 'EGO_LIFECYCLE_USER_PUB';
  g_app_name                 CONSTANT VARCHAR2(3)  := 'EGO';
  g_current_user_id          NUMBER                := FND_GLOBAL.User_Id;
  g_current_login_id         NUMBER                := FND_GLOBAL.Login_Id;
  g_validation_error         EXCEPTION;
  g_same_sequence_error      EXCEPTION;
  g_project_assoc_type       CONSTANT VARCHAR2(24) := 'EGO_ITEM_PROJ_ASSOC_TYPE';
  g_lifecycle_tracking_code  CONSTANT VARCHAR2(18) := 'LIFECYCLE_TRACKING';
  g_promote                  CONSTANT VARCHAR2(7)  := 'PROMOTE';
  g_demote                   CONSTANT VARCHAR2(6)  := 'DEMOTE';
  g_plsql_err                VARCHAR2(17)          := 'EGO_PLSQL_ERR';
  g_pkg_name_token           VARCHAR2(8)           := 'PKG_NAME';
  g_api_name_token           VARCHAR2(8)           := 'API_NAME';
  g_sql_err_msg_token        VARCHAR2(11)          := 'SQL_ERR_MSG';
  g_not_allowed              CONSTANT VARCHAR2(11) := 'NOT_ALLOWED';
  g_co_required              CONSTANT VARCHAR2(21) := 'CHANGE_ORDER_REQUIRED';


-- Private Function
----------------------------------------------------------------------
PROCEDURE code_debug (p_msg  IN  VARCHAR2) IS
BEGIN
--  sri_debug ('EGOPLCUB - EGO_LIFECYCLE_USER_PUB '||p_msg);
  RETURN;
EXCEPTION
  WHEN OTHERS THEN
  NULL;
END;

FUNCTION Has_Lifecycle_Tracking_Project
(
     p_inventory_item_id       IN      NUMBER
   , p_organization_id         IN      NUMBER
   , p_revision                IN      VARCHAR2
)
RETURN BOOLEAN
IS

    l_count                  NUMBER;
    l_has_tracking_proj      BOOLEAN;

  BEGIN

    IF p_revision IS NULL THEN

      SELECT COUNT(1) INTO l_count
        FROM ego_item_projects
       WHERE inventory_item_id = p_inventory_item_id
         AND organization_id = p_organization_id
         AND revision_id IS NULL
         AND association_type = G_PROJECT_ASSOC_TYPE
         AND association_code = G_LIFECYCLE_TRACKING_CODE
         AND ROWNUM = 1;

    ELSE

      SELECT COUNT(1) INTO l_count
        FROM EGO_ITEM_PROJECTS a
       WHERE inventory_item_id = p_inventory_item_id
         AND organization_id = p_organization_id
         AND EXISTS
             (SELECT revision_id
                FROM mtl_item_revisions_b
               WHERE inventory_item_id = p_inventory_item_id
                 AND organization_id   = p_organization_id
                 AND revision          = p_revision
              )
         AND association_type = G_PROJECT_ASSOC_TYPE
         AND association_code = G_LIFECYCLE_TRACKING_CODE
         AND ROWNUM = 1;

    END IF;

    IF (l_count > 0) THEN
      l_has_tracking_proj := TRUE;
    ELSE
      l_has_tracking_proj := FALSE;
    END IF;

    RETURN l_has_tracking_proj;
END Has_Lifecycle_Tracking_Project;

----------------------------------------------------------------------


FUNCTION Check_CM_Existance RETURN VARCHAR2 IS
  ----------------------------------------------------------------------------
  -- Start OF comments
  -- API name  : Check_Change_Management_Existance
  -- TYPE      : Public
  -- Pre-reqs  : None
  -- FUNCTION  : Check whether CM is installed and active
  --               (the table ENG_CHANGE_MGMT_TYPES_VL is populated)
  --
  -- Return Parameter:
  --           'S' if view eng_change_mgmt_types_vl is populated
  --           'E' in all other cases
  --
  ----------------------------------------------------------------------------
  l_product_exists   VARCHAR2(1);
  --l_status           fnd_product_installations.status%TYPE;
  --l_count            NUMBER;

  /*CURSOR c_product_check (cp_app_short_name IN VARCHAR2) IS
    SELECT inst.status
    FROM   fnd_product_installations inst, fnd_application app
    WHERE  inst.application_id = app.application_id
      AND  app.application_short_name = cp_app_short_name
      AND  inst.status <> 'N';*/

  BEGIN
    -- Checking whether the product is installed.
    /*OPEN c_product_check (cp_app_short_name => 'ENG');
    FETCH c_product_check INTO l_status;
    CLOSE c_product_check;
    IF (l_status = 'I') THEN
      -- package exists and DBI is installed
      -- check if a record exists in eng_change_mgmt_types_vl
      SELECT count(*)
      INTO  l_count
      FROM eng_change_mgmt_types_vl
      WHERE disable_flag = 'N';
      IF l_count <> 0 THEN
        l_product_exists := FND_API.G_RET_STS_SUCCESS;
      END IF;
    END IF;
    RETURN (l_product_exists);
  EXCEPTION
    WHEN OTHERS THEN
      IF c_product_check%ISOPEN THEN
        CLOSE c_product_check;
      END IF;
      RETURN (l_product_exists);*/

    l_product_exists :=  EGO_COMMON_PVT.Is_EGO_Installed(1.0, '');
    IF (l_product_exists = 'T') THEN
      RETURN FND_API.G_RET_STS_SUCCESS;
    ELSE
      RETURN FND_API.G_RET_STS_ERROR;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FND_API.G_RET_STS_ERROR;

  END Check_CM_Existance;

----------------------------------------------------------------------

-- Public Procedures
----------------------------------------------------------------------

FUNCTION get_change_name  (p_change_id  IN   NUMBER) RETURN VARCHAR2 IS
  l_change_notice  VARCHAR2(2000);
  l_dynamic_sql    VARCHAR2(2000);

BEGIN
  l_change_notice := NULL;
  IF (Check_CM_Existance() = FND_API.G_RET_STS_SUCCESS) THEN
    IF (p_change_id IS NULL) THEN
      l_change_notice := NULL;
    ELSE
      --Bug#5043988 : Literal Fix
      l_dynamic_sql := ' SELECT change_notice FROM eng_engineering_changes'
                     ||' WHERE change_id = :p_change_id' ; --||TO_CHAR(p_change_id);
      EXECUTE IMMEDIATE l_dynamic_sql INTO l_change_notice USING p_change_id ;
      --Bug#5043988 : Literal Fix
    END IF;
  END IF;
  RETURN l_change_notice;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_change_name;


PROCEDURE Check_Delete_Project_OK
(
     p_api_version             IN      NUMBER
   , p_project_id              IN      NUMBER
   , p_init_msg_list           IN      VARCHAR2   DEFAULT FND_API.G_FALSE
   , x_delete_ok               OUT     NOCOPY VARCHAR2
   , x_return_status           OUT     NOCOPY VARCHAR2
   , x_errorcode               OUT     NOCOPY NUMBER
   , x_msg_count               OUT     NOCOPY NUMBER
   , x_msg_data                OUT     NOCOPY VARCHAR2
)
IS

    l_api_version  NUMBER;
    l_count        VARCHAR2(1);
    l_api_name     VARCHAR2(30);
    l_message      VARCHAR2(4000);

  BEGIN

    l_api_version  := 1.0;
    l_api_name     := 'Check_Delete_Project_OK';
    --Standard checks
    IF NOT FND_API.Compatible_API_Call (l_api_version
                                       ,p_api_version
                                       ,l_api_name
                                       ,g_pkg_name)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    --Check if there are any entries for it in EGO_ITEM_PROJECTS
    SELECT
      COUNT(*) INTO l_count
    FROM
      EGO_ITEM_PROJECTS
    WHERE
      PROJECT_ID = p_project_id;

    IF (l_count > 0)
    THEN
      x_delete_ok := FND_API.G_FALSE;
      l_message := 'EGO_ITEM_ASSOCIATED_PR';
    END IF;

    IF (l_message IS NOT NULL)
    THEN
      FND_MESSAGE.Set_Name(g_app_name, l_message);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(
        p_encoded        => FND_API.G_FALSE,
        p_count          => x_msg_count,
        p_data           => x_msg_data
      );
      x_return_status := FND_API.G_RET_STS_ERROR;
    ELSE
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_delete_ok := FND_API.G_FALSE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
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

END Check_Delete_Project_OK;

----------------------------------------------------------------------

PROCEDURE Get_Policy_For_Revise
(
     p_api_version             IN      NUMBER
   , p_inventory_item_id       IN      NUMBER
   , p_organization_id         IN      NUMBER
   , p_curr_phase_id           IN      NUMBER
   , x_policy_code             OUT     NOCOPY VARCHAR2
   , x_return_status           OUT     NOCOPY VARCHAR2
   , x_errorcode               OUT     NOCOPY NUMBER
   , x_msg_count               OUT     NOCOPY NUMBER
   , x_msg_data                OUT     NOCOPY VARCHAR2
)
IS

  BEGIN

    Get_Policy_For_Phase_Change
    (
       p_api_version
      ,NULL
      ,p_inventory_item_id
      ,p_organization_id
      ,p_curr_phase_id
      ,NULL
      ,'REVISE'
      ,NULL
      ,x_policy_code
      ,x_return_status
      ,x_errorcode
      ,x_msg_count
      ,x_msg_data
    );

END Get_Policy_For_Revise;

----------------------------------------------------------------------

PROCEDURE Get_Policy_For_Phase_Change
(
     p_api_version             IN      NUMBER
   , p_project_id              IN      NUMBER DEFAULT NULL
   , p_inventory_item_id       IN      NUMBER DEFAULT NULL
   , p_organization_id         IN      NUMBER DEFAULT NULL
   , p_curr_phase_id           IN      NUMBER
   , p_future_phase_id         IN      NUMBER
   , p_phase_change_code       IN      VARCHAR2
   , p_lifecycle_id            IN      NUMBER
   , x_policy_code             OUT     NOCOPY VARCHAR2
   , x_return_status           OUT     NOCOPY VARCHAR2
   , x_errorcode               OUT     NOCOPY NUMBER
   , x_msg_count               OUT     NOCOPY NUMBER
   , x_msg_data                OUT     NOCOPY VARCHAR2
)
IS

    l_api_version                   NUMBER;
    l_api_name                      VARCHAR2(30);
    l_curr_sequence                 NUMBER;
    l_future_sequence               NUMBER;
    l_phase_change_code             EGO_LCPHASE_POLICY.ACTION_CODE%TYPE;
    l_inventory_item_id             MTL_SYSTEM_ITEMS_B.INVENTORY_ITEM_ID%TYPE;
    l_organization_id               MTL_SYSTEM_ITEMS_B.ORGANIZATION_ID%TYPE;
    l_catalog_category_id           MTL_SYSTEM_ITEMS_B.ITEM_CATALOG_GROUP_ID%TYPE;
    l_current_catalog_category_id   MTL_SYSTEM_ITEMS_B.ITEM_CATALOG_GROUP_ID%TYPE;
    l_associated_here               VARCHAR2(1);

    l_policy_object_name            VARCHAR2(30);
    l_policy_code                   VARCHAR2(30);
    l_attr_object_name              VARCHAR2(30);
    l_attribute_code                VARCHAR2(30);
    l_attr_num                      NUMBER;
    l_dynamic_sql                   VARCHAR2(32767);

--    CURSOR ALL_CATALOG_CATEGORY_IDS
--    (
--      cp_catalog_category_id         IN    NUMBER
--    ) IS
--    SELECT
--      ITEM_CATALOG_GROUP_ID
--    FROM
--      MTL_ITEM_CATALOG_GROUPS_B
--      CONNECT BY PRIOR  PARENT_CATALOG_GROUP_ID = ITEM_CATALOG_GROUP_ID
--      START WITH ITEM_CATALOG_GROUP_ID = cp_catalog_category_id;
--
  CURSOR c_get_assoc_category_id (cp_catalog_category_id  IN  NUMBER
                                 ,cp_lifecycle_id         IN  NUMBER
                                 ) IS
     SELECT ic.item_catalog_group_id
       FROM MTL_ITEM_CATALOG_GROUPS_B ic
      WHERE EXISTS (
              SELECT olc.object_classification_code CatalogId
                FROM  ego_obj_type_lifecycles olc, fnd_objects o
               WHERE o.obj_name =  'EGO_ITEM'
                 AND olc.object_id = o.object_id
                 AND olc.lifecycle_id = cp_lifecycle_id
                 AND olc.object_classification_code = item_catalog_group_id
                   )
     CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
     START WITH item_catalog_group_id = cp_catalog_category_id;
  BEGIN
    l_api_name            := 'Get_Policy_For_Phase_Change';
    l_api_version         := 1.0;
    l_policy_object_name  := 'CATALOG_LIFECYCLE_PHASE';
    l_policy_code         := 'CHANGE_POLICY';
    l_attr_object_name    := 'EGO_CATALOG_GROUP';
    l_attribute_code      := 'PROMOTE_DEMOTE';
    code_debug (l_api_name ||' started  project id '|| p_project_id ||' item id '||p_inventory_item_id||' organization id '||p_organization_id||' curr phase id '||p_curr_phase_id ||' future phase id '||p_future_phase_id);

    --Standard checks
    IF NOT FND_API.Compatible_API_Call (l_api_version
                                       ,p_api_version
                                       ,l_api_name
                                       ,g_pkg_name)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- First we need to determine the phase change code if it isn't passed in
    IF (p_phase_change_code IS NULL)
    THEN

      SELECT
        P1.DISPLAY_SEQUENCE INTO l_curr_sequence
      FROM
        PA_PROJ_ELEMENT_VERSIONS P1
       ,PA_PROJ_ELEMENT_VERSIONS P2
      WHERE
        P1.PROJ_ELEMENT_ID = p_curr_phase_id
        AND P1.PARENT_STRUCTURE_VERSION_ID = P2.ELEMENT_VERSION_ID
        AND P2.PROJ_ELEMENT_ID = p_lifecycle_id;

      SELECT P1.DISPLAY_SEQUENCE INTO l_future_sequence
      FROM
        PA_PROJ_ELEMENT_VERSIONS P1
       ,PA_PROJ_ELEMENT_VERSIONS P2
      WHERE
        P1.PROJ_ELEMENT_ID = p_future_phase_id
        AND P1.PARENT_STRUCTURE_VERSION_ID = P2.ELEMENT_VERSION_ID
        AND P2.PROJ_ELEMENT_ID = p_lifecycle_id;

      IF (l_curr_sequence > l_future_sequence)
      THEN
        l_phase_change_code := g_demote;
      ELSIF (l_future_sequence > l_curr_sequence)
      THEN
        l_phase_change_code := g_promote;
      ELSE
        RAISE g_same_sequence_error;
      END IF;

    ELSE
      l_phase_change_code := p_phase_change_code;
    END IF;

    --First get the item for the project if they are null
    l_inventory_item_id := p_inventory_item_id;
    l_organization_id := p_organization_id;

    IF (l_inventory_item_id IS NULL OR l_organization_id IS NULL) THEN

      SELECT
        INVENTORY_ITEM_ID, ORGANIZATION_ID
      INTO
        l_inventory_item_id, l_organization_id
      FROM
        EGO_ITEM_PROJECTS
      WHERE
        PROJECT_ID = p_project_id
        AND ASSOCIATION_TYPE = g_project_assoc_type
        AND ASSOCIATION_CODE = g_lifecycle_tracking_code
        AND ROWNUM = 1;

    END IF;

    --We need to get the catalog category id

    SELECT
      ITEM_CATALOG_GROUP_ID into l_current_catalog_category_id
    FROM
      MTL_SYSTEM_ITEMS_B
    WHERE
      ORGANIZATION_ID = l_organization_id
      AND INVENTORY_ITEM_ID = l_inventory_item_id;

    --Check which catalog category actually has the lifecycle associated with it
    OPEN c_get_assoc_category_id (cp_lifecycle_id => p_lifecycle_id
                                 ,cp_catalog_category_id => l_current_catalog_category_id
                                 );
    FETCH c_get_assoc_category_id INTO l_catalog_category_id;
    CLOSE c_get_assoc_category_id;

    code_debug (l_api_name ||' cat at which lc associated  '||l_catalog_category_id);
    IF (l_phase_change_code = 'REVISE') THEN
      l_attr_num := 3;
    ELSIF (l_phase_change_code = g_demote) THEN
      l_attr_num := 2;
    ELSIF (l_phase_change_code = g_promote) THEN
      l_attr_num := 1;
    END IF;

    IF (Check_CM_Existance() = FND_API.G_RET_STS_SUCCESS) THEN
      /*ENG_CHANGE_POLICY_PKG.GetChangePolicy
      (   p_policy_object_name    => l_policy_object_name
       ,  p_policy_code           => l_policy_code
       ,  p_policy_pk1_value      => l_catalog_category_id
       ,  p_policy_pk2_value      => p_lifecycle_id
       ,  p_policy_pk3_value      => p_curr_phase_id
       ,  p_policy_pk4_value      => null
       ,  p_policy_pk5_value      => null
       ,  p_attribute_object_name => l_attr_object_name
       ,  p_attribute_code        => l_attribute_code
       ,  p_attribute_value       => l_attr_num
       ,  x_policy_value          => x_policy_code
      );*/

     l_dynamic_sql :=
      ' BEGIN                                                               '||
      '    ENG_CHANGE_POLICY_PKG.GetChangePolicy                            '||
      '    (                                                                '||
      '      p_policy_object_name      =>  :l_policy_object_name            '||
      '   ,  p_policy_code             =>  :l_policy_code                   '||
      '   ,  p_policy_pk1_value        =>  TO_CHAR(:l_catalog_category_id)  '||
      '   ,  p_policy_pk2_value        =>  TO_CHAR(:p_lifecycle_id)         '||
      '   ,  p_policy_pk3_value        =>  TO_CHAR(:p_curr_phase_id)        '||
      '   ,  p_policy_pk4_value        =>  NULL                             '||
      '   ,  p_policy_pk5_value        =>  NULL                             '||
      '   ,  p_attribute_object_name   =>  :l_attr_object_name              '||
      '   ,  p_attribute_code          =>  :l_attribute_code                '||
      '   ,  p_attribute_value         =>  :l_attr_num                      '||
      '   ,  x_policy_value            =>  :x_policy_code                   '||
      '   );                                                                '||
      ' END;';

      EXECUTE IMMEDIATE l_dynamic_sql
      USING IN l_policy_object_name,
            IN l_policy_code,
            IN l_catalog_category_id,
            IN p_lifecycle_id,
            IN p_curr_phase_id,
            IN l_attr_object_name,
            IN l_attribute_code,
            IN l_attr_num,
           OUT x_policy_code;

    END IF;
    code_debug (l_api_name ||' policy code returned  '||x_policy_code);
/*
    SELECT
      POLICY_CODE INTO x_policy_code
    FROM
      EGO_LCPHASE_POLICY
    WHERE
      PHASE_ID = p_curr_phase_id
      AND ACTION_CODE = l_phase_change_code
      AND LIFECYCLE_ID = p_lifecycle_id
      AND ITEM_CATALOG_GROUP_ID = l_catalog_category_id;
*/
  EXCEPTION
    WHEN g_same_sequence_error THEN
      x_policy_code := NULL;
    WHEN NO_DATA_FOUND THEN
      x_policy_code := NULL;
    WHEN OTHERS THEN
      IF c_get_assoc_category_id%ISOPEN THEN
        CLOSE c_get_assoc_category_id;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
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

END Get_Policy_For_Phase_Change;

----------------------------------------------------------------------

PROCEDURE Get_Policy_For_Phase_Change
(
     p_api_version             IN      NUMBER
   , p_project_id              IN      NUMBER
   , p_curr_phase_id           IN      NUMBER
   , p_future_phase_id         IN      NUMBER
   , p_phase_change_code       IN      VARCHAR2
   , p_lifecycle_id            IN      NUMBER
   , x_policy_code             OUT     NOCOPY VARCHAR2
   , x_error_message           OUT     NOCOPY VARCHAR2
   , x_return_status           OUT     NOCOPY VARCHAR2
   , x_errorcode               OUT     NOCOPY NUMBER
   , x_msg_count               OUT     NOCOPY NUMBER
   , x_msg_data                OUT     NOCOPY VARCHAR2
)
IS

  BEGIN
    code_debug (' Get Policy for Phase Change -- Projects version called ');
    Get_Policy_For_Phase_Change
    (
       p_api_version
      ,p_project_id
      ,NULL
      ,NULL
      ,p_curr_phase_id
      ,p_future_phase_id
      ,p_phase_change_code
      ,p_lifecycle_id
      ,x_policy_code
      ,x_return_status
      ,x_errorcode
      ,x_msg_count
      ,x_msg_data
    );

    -- Return an error message if the policy is not allowed
    IF ((x_policy_code = g_not_allowed) OR (x_policy_code = g_co_required)) THEN
      x_error_message := 'EGO_PHASE_CHANGE_NOT_ALLOWED';
    END IF;

END Get_Policy_For_Phase_Change;

----------------------------------------

PROCEDURE Check_Lc_Tracking_Project
 (
     p_api_version             IN     NUMBER
   , p_project_id              IN     NUMBER
   , x_is_lifecycle_tracking   OUT    NOCOPY VARCHAR2
   , x_return_status           OUT    NOCOPY VARCHAR2
   , x_errorcode               OUT    NOCOPY NUMBER
   , x_msg_count               OUT    NOCOPY NUMBER
   , x_msg_data                OUT    NOCOPY VARCHAR2
)
IS

    l_api_version            NUMBER;
    l_api_name               VARCHAR2(30);
    l_count                  NUMBER;

BEGIN

  l_api_version  := 1.0;
  l_api_name     := 'Check_Lc_Tracking_Project';
  --Standard checks
  IF NOT FND_API.Compatible_API_Call (l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,g_pkg_name)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- This procedure returns TRUE if and only if the project ID
  -- passed in belongs to a project that is:
  -- 1). associated to an Item in the EGO_ITEM_PROJECTS table, and
  -- 2). associated as a Lifecycle tracking project.

  SELECT COUNT(1) INTO l_count
    FROM EGO_ITEM_PROJECTS
   WHERE PROJECT_ID = p_project_id
     AND ASSOCIATION_TYPE = g_project_assoc_type
     AND ASSOCIATION_CODE = g_lifecycle_tracking_code
     AND ROWNUM = 1;

  IF (l_count > 0) THEN
    x_is_lifecycle_tracking := FND_API.G_TRUE;
  ELSE
    x_is_lifecycle_tracking := FND_API.G_FALSE;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
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

END Check_Lc_Tracking_Project;

----------------------------------------------------------------------

PROCEDURE Delete_All_Item_Assocs
 (
     p_api_version             IN     NUMBER
   , p_project_id              IN     NUMBER
   , p_commit                  IN     VARCHAR2  DEFAULT fnd_api.g_FALSE
   , x_return_status           OUT    NOCOPY VARCHAR2
   , x_errorcode               OUT    NOCOPY NUMBER
   , x_msg_count               OUT    NOCOPY NUMBER
   , x_msg_data                OUT    NOCOPY VARCHAR2
)
IS
  l_api_version  NUMBER;
  l_api_name     VARCHAR2(30);

  CURSOR c_item_project (cp_project_id IN NUMBER) IS
    SELECT inventory_item_id, organization_id
    FROM  ego_item_projects
    WHERE project_id = cp_project_id;

BEGIN

  l_api_version  := 1.0;
  l_api_name     := 'Delete_All_Item_Assocs';
  --Standard checks
  IF NOT FND_API.Compatible_API_Call (l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,g_pkg_name)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- 4052565 perform security check
  FOR l_item_projs IN c_item_project(cp_project_id => p_project_id) LOOP
    IF NOT EGO_ITEM_PVT.has_role_on_item
               (p_function_name      => 'EGO_CREATE_ITEM_LC_TRACK_PROJ'
               ,p_inventory_item_id  => l_item_projs.inventory_item_id
               ,p_item_number        => NULL
               ,p_organization_id    => l_item_projs.organization_id
               ,p_organization_name  => NULL
               ,p_user_id            => NULL
               ,p_party_id           => NULL
               ,p_set_message        => FND_API.G_TRUE
               ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_encoded        => FND_API.G_FALSE,
        p_count          => x_msg_count,
        p_data           => x_msg_data
      );
      RETURN;
    END IF;
  END LOOP;
  DELETE
    FROM EGO_ITEM_PROJECTS
   WHERE PROJECT_ID = p_project_id;

  -- Standard check of p_commit.
  IF FND_API.To_Boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
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

END Delete_All_Item_Assocs;

----------------------------------------------------------------------

PROCEDURE Sync_Phase_Change
 (
     p_api_version             IN      NUMBER
   , p_project_id              IN      NUMBER
   , p_lifecycle_id            IN      NUMBER
   , p_phase_id                IN      NUMBER
   , p_effective_date          IN      DATE
   , p_init_msg_list           IN      VARCHAR2   DEFAULT fnd_api.g_FALSE
   , p_commit                  IN      VARCHAR2   DEFAULT fnd_api.g_FALSE
   , x_return_status           OUT     NOCOPY VARCHAR2
   , x_errorcode               OUT     NOCOPY NUMBER
   , x_msg_count               OUT     NOCOPY NUMBER
   , x_msg_data                OUT     NOCOPY VARCHAR2
)
IS

    l_api_version       NUMBER;
    l_api_name          VARCHAR2(30);
    l_status_code       EGO_LCPHASE_ITEM_STATUS.ITEM_STATUS_CODE%TYPE;
    l_phase_code        EGO_LCPHASE_ITEM_STATUS.PHASE_CODE%TYPE;
--    l_revision_id       MTL_ITEM_REVISIONS_B.REVISION_ID%TYPE;
    l_revision          MTL_ITEM_REVISIONS_B.REVISION%TYPE;
    l_current_phase_id  MTL_ITEM_REVISIONS_B.CURRENT_PHASE_ID%TYPE;

    l_revision_master_controlled    VARCHAR2(1);
    l_status_master_controlled      VARCHAR2(1);
    l_is_master_org                 VARCHAR2(1);

    l_return_status                 VARCHAR2(1);
    l_error_code                     NUMBER;
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(4000);


    CURSOR l_item_revisions IS
    SELECT
      inventory_item_id
     ,organization_id
--     ,revision
     ,revision_id
    FROM EGO_ITEM_PROJECTS proj
    WHERE project_id = p_project_id
      AND association_type = G_PROJECT_ASSOC_TYPE
      AND association_code = G_LIFECYCLE_TRACKING_CODE
--  sync phase changes of items which are not in the same phase of project
      AND ( (revision_id IS NULL
             AND NOT EXISTS
               (SELECT 'X'
                FROM mtl_system_items_b item
                WHERE item.inventory_item_id = proj.inventory_item_id
                  AND item.organization_id = proj.organization_id
                  AND item.lifecycle_id = p_lifecycle_id
                  AND item.current_phase_id = p_phase_id
                )
             )
             OR
             (revision_id IS NOT NULL
             AND NOT EXISTS
               (SELECT 'X'
                FROM mtl_item_revisions_b rev
                WHERE rev.inventory_item_id = proj.inventory_item_id
                  AND rev.organization_id = proj.organization_id
                  AND rev.revision_id = proj.revision_id
                  AND rev.lifecycle_id = p_lifecycle_id
                  AND rev.current_phase_id = p_phase_id
                )
             )
          );


  BEGIN
    l_api_version  := 1.0;
    l_api_name     := 'Proj_Sync_Phase_Change';
    code_debug (l_api_name ||' started  p_project_id '||p_project_id||'  lc  id '||p_lifecycle_id ||'  phase id '||p_phase_id);
    code_debug (l_api_name ||'   p_effective_date '||to_char(p_effective_date,'DD-MON-YYYY HH24:MI:SS'));

    --Standard checks
    IF NOT FND_API.Compatible_API_Call (l_api_version
                                       ,p_api_version
                                       ,l_api_name
                                       ,g_pkg_name)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Sync_Phase_Change_PUB;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    l_revision_master_controlled := FND_API.g_false;
    l_status_master_controlled := EGO_ITEM_LC_IMP_PC_PUB.get_master_controlled_status();

    FOR l_item_record IN l_item_revisions LOOP
        code_debug (l_api_name ||' creating pending phase change for item '||l_item_record.INVENTORY_ITEM_ID||'in org '||l_item_record.organization_id||' revision id '||l_item_record.REVISION_id);
        -- 4052565 perform security check

        -- validate the current status code in the new phase; if current status exists
        -- in the new phase, keep it; otherwise, use the default status
        SELECT msi.INVENTORY_ITEM_STATUS_CODE
          INTO l_status_code
          FROM MTL_SYSTEM_ITEMS_B msi
         WHERE msi.INVENTORY_ITEM_ID = l_item_record.INVENTORY_ITEM_ID
           AND msi.ORGANIZATION_ID = l_item_record.ORGANIZATION_ID;

        BEGIN
          SELECT status.ITEM_STATUS_CODE
            INTO l_status_code
            FROM EGO_LCPHASE_ITEM_STATUS status
                ,PA_EGO_PHASES_V phases
           WHERE phases.PROJ_ELEMENT_ID = p_phase_id
             AND status.PHASE_CODE = phases.PHASE_CODE
             AND status.ITEM_STATUS_CODE = l_status_code;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_status_code := NULL;
        END;

        EGO_ITEM_LC_IMP_PC_PUB.Create_Pending_Phase_Change
             (p_api_version         => p_api_version
             ,p_commit              => FND_API.G_FALSE
             ,p_inventory_item_id   => l_item_record.INVENTORY_ITEM_ID
             ,p_organization_id     => l_item_record.ORGANIZATION_ID
             ,p_effective_date      => p_effective_date
             ,p_pending_flag        => NULL
             ,p_revision            => NULL
             ,p_revision_id         => l_item_record.revision_id
             ,p_lifecycle_id        => p_lifecycle_id
             ,p_phase_id            => p_phase_id
             ,p_status_code         => l_status_code
             ,p_change_id           => NULL
             ,p_change_line_id      => NULL
             ,p_perform_security_check => FND_API.G_TRUE
             ,x_return_status       => x_return_status
             ,x_errorcode           => x_errorcode
             ,x_msg_count           => x_msg_count
             ,x_msg_data            => x_msg_data
             );
      code_debug (l_api_name ||' creating pending phase change for item  returned with status '||x_return_status);
      EXIT WHEN x_return_status <> FND_API.G_RET_STS_SUCCESS;

      l_is_master_org :=
          EGO_ITEM_LC_IMP_PC_PUB.get_master_org_status(l_item_record.ORGANIZATION_ID);
--      l_revision_id   :=
--          EGO_ITEM_LC_IMP_PC_PUB.get_revision_id
--                   (p_inventory_item_id  => l_item_record.INVENTORY_ITEM_ID
--                   ,p_organization_id    => l_item_record.ORGANIZATION_ID
--                   ,p_revision           => l_item_record.REVISION
--                   );
      code_debug (l_api_name ||' creating implement pending phase change ');
      -- 4052565 perform security check
      EGO_ITEM_LC_IMP_PC_PUB.Implement_Pending_Changes
              (p_api_version                  => p_api_version
              ,p_inventory_item_id            => l_item_record.INVENTORY_ITEM_ID
              ,p_organization_id              => l_item_record.ORGANIZATION_ID
              ,p_revision_id                  => l_item_record.REVISION_ID
              ,p_revision_master_controlled   => l_revision_master_controlled
              ,p_status_master_controlled     => l_status_master_controlled
              ,p_is_master_org                => l_is_master_org
              ,p_perform_security_check       => FND_API.G_FALSE
              ,x_return_status                => x_return_status
              ,x_errorcode                    => x_errorcode
              ,x_msg_count                    => x_msg_count
              ,x_msg_data                     => x_msg_data
              );
      code_debug (l_api_name ||' returning implement pending phase change with status '||x_return_status||' msg count'||x_msg_count||' errorcode '||x_errorcode);
      EXIT WHEN x_return_status <> FND_API.G_RET_STS_SUCCESS;
--
-- Commented as a part of fix for 3371749
--
--        Sync_Phase_Change
--         (
--             p_api_version           => p_api_version
--           , p_organization_id       => l_item_record.ORGANIZATION_ID
--           , p_inventory_item_id     => l_item_record.INVENTORY_ITEM_ID
--           , p_revision              => l_item_record.REVISION
--           , p_lifecycle_id          => p_lifecycle_id
--           , p_phase_id              => p_phase_id
--           , p_effective_date        => p_effective_date
--           , p_init_msg_list         => p_init_msg_list
--           , p_commit                => p_commit
--           , x_return_status         => x_return_status
--           , x_errorcode             => x_errorcode
--           , x_msg_count             => x_msg_count
--           , x_msg_data              => x_msg_data
--        );
--
    END LOOP;

    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      -- Standard check of p_commit.
      IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
      END IF;
    ELSE
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Sync_Phase_Change_PUB;
      END IF;
      code_debug (l_api_name ||' returning with msg count'||x_msg_count);
      IF NOT x_msg_count = 1 THEN
        FND_MSG_PUB.Count_And_Get(
          p_encoded        => FND_API.G_FALSE,
          p_count          => x_msg_count,
          p_data           => x_msg_data
          );
      END IF;
    END IF;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Sync_Phase_Change_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF NOT x_msg_count = 1 THEN
        FND_MSG_PUB.Count_And_Get(
          p_encoded        => FND_API.G_FALSE,
          p_count          => x_msg_count,
          p_data           => x_msg_data
          );
      END IF;
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Sync_Phase_Change_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
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

END Sync_Phase_Change;


----------------------------------------------------------------------
PROCEDURE Sync_Phase_Change
 (
     p_api_version             IN      NUMBER
   , p_organization_id         IN      NUMBER
   , p_inventory_item_id       IN      NUMBER
   , p_revision                IN      VARCHAR2   DEFAULT null
   , p_lifecycle_id            IN      NUMBER
   , p_phase_id                IN      NUMBER
   , p_effective_date          IN      DATE
   , p_init_msg_list           IN      VARCHAR2   DEFAULT fnd_api.g_FALSE
   , p_commit                  IN      VARCHAR2   DEFAULT fnd_api.g_FALSE
   , x_return_status           OUT     NOCOPY VARCHAR2
   , x_errorcode               OUT     NOCOPY NUMBER
   , x_msg_count               OUT     NOCOPY NUMBER
   , x_msg_data                OUT     NOCOPY VARCHAR2
)
IS

    l_api_version     NUMBER;
    l_api_name        VARCHAR2(30);
    l_status_code     EGO_LCPHASE_ITEM_STATUS.ITEM_STATUS_CODE%TYPE;
    l_phase_code      EGO_LCPHASE_ITEM_STATUS.PHASE_CODE%TYPE;
    l_revision_id     MTL_ITEM_REVISIONS_B.REVISION_ID%TYPE;
    l_current_phase_id MTL_ITEM_REVISIONS_B.CURRENT_PHASE_ID%TYPE;

    l_revision_master_controlled    VARCHAR2(1);
    l_status_master_controlled      VARCHAR2(1);
    l_is_master_org                 VARCHAR2(1);

    l_return_status                 VARCHAR2(1);
    l_error_code                     NUMBER;
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(4000);

  BEGIN
    l_api_version     := 1.0;
    l_api_name        := 'Item_Sync_Phase_Change';
    code_debug (l_api_name ||' started  p_inventory_item_id '||p_inventory_item_id||' revision '|| p_revision ||'  lc  id '||p_lifecycle_id ||'  phase id '||p_phase_id);
    code_debug (l_api_name ||'   p_effective_date '||to_char(p_effective_date,'DD-MON-YYYY HH24:MI:SS'));

    --Standard checks
    IF NOT FND_API.Compatible_API_Call (l_api_version
                                       ,p_api_version
                                       ,l_api_name
                                       ,g_pkg_name)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Implement_All_Pending_Changes;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;
    code_debug (l_api_name ||' creating pending phase change for item ');

    EGO_ITEM_LC_IMP_PC_PUB.Create_Pending_Phase_Change
             (p_api_version         => p_api_version
             ,p_commit              => FND_API.G_FALSE
             ,p_inventory_item_id   => p_inventory_item_id
             ,p_organization_id     => p_organization_id
             ,p_effective_date      => p_effective_date
             ,p_pending_flag        => NULL
             ,p_revision            => p_revision
             ,p_revision_id         => NULL
             ,p_lifecycle_id        => p_lifecycle_id
             ,p_phase_id            => p_phase_id
             ,p_change_id           => NULL
             ,p_change_line_id      => NULL
             ,p_perform_security_check => FND_API.G_TRUE
             ,x_return_status       => x_return_status
             ,x_errorcode           => x_errorcode
             ,x_msg_count           => x_msg_count
             ,x_msg_data            => x_msg_data
             );
    code_debug (l_api_name ||' returning pending phase change for item with status '||x_return_status);
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RETURN;
    END IF;
    l_revision_master_controlled := FND_API.g_false;
    l_status_master_controlled := EGO_ITEM_LC_IMP_PC_PUB.get_master_controlled_status();
    l_is_master_org :=
          EGO_ITEM_LC_IMP_PC_PUB.get_master_org_status(p_organization_id);
    l_revision_id   :=
          EGO_ITEM_LC_IMP_PC_PUB.get_revision_id
                   (p_inventory_item_id  => p_inventory_item_id
                   ,p_organization_id    => p_organization_id
                   ,p_revision           => p_revision
                   );
    code_debug (l_api_name ||' calling implement pending phase changes for item ');

    EGO_ITEM_LC_IMP_PC_PUB.Implement_Pending_Changes
              (p_api_version                  => p_api_version
              ,p_inventory_item_id            => p_inventory_item_id
              ,p_organization_id              => p_organization_id
              ,p_revision_id                  => l_revision_id
              ,p_revision_master_controlled   => l_revision_master_controlled
              ,p_status_master_controlled     => l_status_master_controlled
              ,p_is_master_org                => l_is_master_org
              ,p_perform_security_check       => FND_API.G_FALSE
              ,x_return_status                => x_return_status
              ,x_errorcode                    => x_errorcode
              ,x_msg_count                    => x_msg_count
              ,x_msg_data                     => x_msg_data
              );
    code_debug (l_api_name ||' returning implement pending phase change for item with status '||x_return_status);
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RETURN;
    END IF;
--
-- commented for fixing 3371749
--
/***
    --Get the revision id for the current cursor row
    IF p_revision IS NULL THEN

    l_revision_id := NULL;
  --Bug: 2871650 getting Current phase id to compare
      SELECT
        CURRENT_PHASE_ID INTO l_current_phase_id
      FROM
        MTL_SYSTEM_ITEMS_B
      WHERE
        INVENTORY_ITEM_ID = p_inventory_item_id
        AND ORGANIZATION_ID = p_organization_id;

    ELSE

      SELECT
--Bug: 2871650 getting Current phase id to compare
        REVISION_ID, CURRENT_PHASE_ID INTO l_revision_id, l_current_phase_id
      FROM
        MTL_ITEM_REVISIONS_B
      WHERE
        INVENTORY_ITEM_ID = p_inventory_item_id
        AND ORGANIZATION_ID = p_organization_id
        AND REVISION = p_revision;

     END IF;

     IF (l_current_phase_id <> p_phase_id) then
      l_status_code := NULL;

      BEGIN

        --Now get the phase code
        SELECT PHASE_CODE INTO l_phase_code
        FROM PA_EGO_LIFECYCLES_PHASES_V
        WHERE PROJ_ELEMENT_ID = p_phase_id;

        IF p_revision IS NULL
        THEN
          SELECT ITEM_STATUS_CODE INTO l_status_code
          FROM
            EGO_LCPHASE_ITEM_STATUS
          WHERE
            PHASE_CODE = l_phase_code
            AND DEFAULT_FLAG = 'Y';
        END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;

      END;


      INSERT INTO MTL_PENDING_ITEM_STATUS
      (
         INVENTORY_ITEM_ID
        ,ORGANIZATION_ID
        ,STATUS_CODE
        ,EFFECTIVE_DATE
        ,PENDING_FLAG
        ,LAST_UPDATE_DATE
        ,LAST_UPDATED_BY
        ,CREATION_DATE
        ,CREATED_BY
        ,LAST_UPDATE_LOGIN
        ,LIFECYCLE_ID
        ,PHASE_ID
        ,REVISION_ID
      )
      VALUES
      (
         p_inventory_item_id
        ,p_organization_id
        ,l_status_code
        ,NVL(p_effective_date,SYSDATE)
        ,'Y'
        ,SYSDATE
        ,g_current_login_id
        ,SYSDATE
        ,g_current_login_id
        ,g_current_login_id
        ,p_lifecycle_id
        ,p_phase_id
        ,l_revision_id
      );

      --Now call an api to implement all of the pendings we just added

      SELECT DECODE(LOOKUP_CODE2, 1, FND_API.G_TRUE, 2, FND_API.G_FALSE, FND_API.G_FALSE) INTO l_status_master_controlled
      FROM MTL_ITEM_ATTRIBUTES_V
      WHERE ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVENTORY_ITEM_STATUS_CODE';

      l_revision_master_controlled := FND_API.G_FALSE;

      SELECT
        DECODE(MP.ORGANIZATION_ID,MP.MASTER_ORGANIZATION_ID, FND_API.G_TRUE, FND_API.G_FALSE) INTO l_is_master_org
      FROM MTL_PARAMETERS MP
      WHERE MP.ORGANIZATION_ID = p_organization_id;

      EGO_ITEM_LC_IMP_PC_PUB.Implement_Pending_Changes(1.0
                                                      ,p_inventory_item_id
                                                      ,p_organization_id
                                                      ,l_revision_id
                                                      ,l_revision_master_controlled
                                                      ,l_status_master_controlled
                                                      ,l_is_master_org
                                                      ,l_return_status
                                                      ,l_error_code
                                                      ,l_msg_count
                                                      ,l_msg_data
                                                      );



     END IF;--Bug: 2871650 ended If condition
***/
    -- Standard check of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Sync_Phase_Change_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF NOT x_msg_count = 1 THEN
        FND_MSG_PUB.Count_And_Get(
          p_encoded        => FND_API.G_FALSE,
          p_count          => x_msg_count,
          p_data           => x_msg_data
          );
      END IF;
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Sync_Phase_Change_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
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

END Sync_Phase_Change;

----------------------------------------------------------------------


PROCEDURE Create_Project_Item_Assoc
 (
     p_api_version             IN      NUMBER
   , p_project_id              IN      NUMBER
   , p_organization_id         IN      NUMBER
   , p_inventory_item_id       IN      NUMBER
   , p_revision                IN      VARCHAR2  DEFAULT NULL
   , p_revision_id             IN      NUMBER    DEFAULT NULL
   , p_task_id                 IN      NUMBER    DEFAULT NULL
   , p_association_type        IN      VARCHAR2
   , p_association_code        IN      VARCHAR2
   , p_organization_specific   IN      VARCHAR2  DEFAULT FND_API.G_FALSE
                                                          -- Currently not used
   , p_check_privileges        IN      VARCHAR2  DEFAULT FND_API.G_TRUE
   , p_init_msg_list           IN      VARCHAR2  DEFAULT FND_API.G_FALSE
   , p_commit                  IN      VARCHAR2  DEFAULT FND_API.G_FALSE
   , x_return_status           OUT     NOCOPY VARCHAR2
   , x_errorcode               OUT     NOCOPY NUMBER
   , x_msg_count               OUT     NOCOPY NUMBER
   , x_msg_data                OUT     NOCOPY VARCHAR2
) IS

    l_api_version     NUMBER;
    l_api_name        VARCHAR2(30);
    l_item_project_id EGO_ITEM_PROJECTS.item_project_id%TYPE;
    l_revision_id     EGO_ITEM_PROJECTS.revision_id%TYPE;

  BEGIN

    l_api_version     := 1.0;
    l_api_name        := 'Create_Project_Item_Assoc';

    code_debug (l_api_name ||' is called with params '
        ||' p_project_id :' ||p_project_id );
    code_debug (l_api_name ||' p_organization_id : '||p_organization_id
        ||' p_inventory_item_id :' ||p_inventory_item_id);
    code_debug (l_api_name ||' p_revision : '||p_revision
        ||' p_revision_id :' ||p_revision_id );
    code_debug (l_api_name ||' p_association_type :' ||p_association_type
        ||' p_association_code : '||p_association_code);

    --------------------------------------------------------------------------
    --                        Validity Checking                             --
    --------------------------------------------------------------------------

    --Standard checks
    IF NOT FND_API.Compatible_API_Call (l_api_version
                                       ,p_api_version
                                       ,l_api_name
                                       ,g_pkg_name)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (FND_API.To_Boolean(p_commit)) THEN
      SAVEPOINT Create_Proj_Item_Assoc_PUB;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    -- Since this is an API intended for use by Projects, it
    -- will almost always be used for creating Lifecycle tracking
    -- projects.  There can only be one Lifecycle tracking
    -- project per Item, but there is no unique index enforcing
    -- such a constraint, so we have to check it ourselves.

    IF (p_association_type = G_PROJECT_ASSOC_TYPE AND
        p_association_code = g_lifecycle_tracking_code) THEN


      IF (FND_API.To_Boolean(p_check_privileges)) THEN

        -- 4052565 perform security check
        code_debug (l_api_name ||' performing security checks ');
        IF NOT EGO_ITEM_PVT.has_role_on_item
                 (p_function_name      => 'EGO_CREATE_ITEM_LC_TRACK_PROJ'
                 ,p_inventory_item_id  => p_inventory_item_id
                 ,p_item_number        => NULL
                 ,p_organization_id    => p_organization_id
                 ,p_organization_name  => NULL
                 ,p_user_id            => NULL
                 ,p_party_id           => NULL
                 ,p_set_message        => FND_API.G_TRUE
                 ) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSE
        code_debug (l_api_name ||' security checks bypassed');
      END IF;

      --we want to delete it
      IF p_revision IS NULL AND p_revision_id IS NULL THEN
        code_debug (l_api_name ||' working in context of item ');
        l_revision_id := NULL;
        DELETE
          FROM EGO_ITEM_PROJECTS
         WHERE INVENTORY_ITEM_ID = p_inventory_item_id
           AND ORGANIZATION_ID = p_organization_id
           AND REVISION_ID IS NULL
           AND ASSOCIATION_TYPE = g_project_assoc_type
           AND ASSOCIATION_CODE = g_lifecycle_tracking_code;
      ELSE
        code_debug (l_api_name ||' working in context of revision ');
        IF p_revision_id IS NULL THEN
          l_revision_id := EGO_ITEM_LC_IMP_PC_PUB.get_revision_id
              (p_inventory_item_id  => p_inventory_item_id
              ,p_organization_id    => p_organization_id
              ,p_revision           => p_revision);
        ELSE
          l_revision_id := p_revision_id;
        END IF;
        DELETE
          FROM EGO_ITEM_PROJECTS
         WHERE INVENTORY_ITEM_ID = p_inventory_item_id
           AND ORGANIZATION_ID = p_organization_id
           AND REVISION_id = l_revision_id
           AND ASSOCIATION_TYPE = g_project_assoc_type
           AND ASSOCIATION_CODE = g_lifecycle_tracking_code;
      END IF;

    END IF;

    SELECT EGO_ITEM_PROJECTS_S.NEXTVAL
      INTO l_item_project_id
      FROM DUAL;

    code_debug (l_api_name ||' revision id '||l_revision_id);

    --------------------------------------------------------------------------
    --         Insert the new row into the item-projects table              --
    --------------------------------------------------------------------------

    INSERT INTO
    EGO_ITEM_PROJECTS
    (
      ITEM_PROJECT_ID
     ,INVENTORY_ITEM_ID
     ,ORGANIZATION_ID
--     ,REVISION
     ,REVISION_ID
     ,PROJECT_ID
     ,TASK_ID
     ,ASSOCIATION_TYPE
     ,ASSOCIATION_CODE
     ,CREATED_BY
     ,CREATION_DATE
     ,LAST_UPDATED_BY
     ,LAST_UPDATE_DATE
     ,LAST_UPDATE_LOGIN
    )
    VALUES
    (
      l_item_project_id
     ,p_inventory_item_id
     ,p_organization_id
--     ,p_revision
     ,l_revision_id
     ,p_project_id
     ,p_task_id
     ,p_association_type
     ,p_association_code
     ,G_CURRENT_USER_ID
     ,SYSDATE
     ,G_CURRENT_USER_ID
     ,SYSDATE
     ,G_CURRENT_LOGIN_ID
    );

    --------------------------------------------------------------------------
    --                              Commit                                  --
    --------------------------------------------------------------------------

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(p_commit)
    THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      IF (FND_API.To_Boolean(p_commit)) THEN
        ROLLBACK TO Create_Proj_Item_Assoc_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name(g_app_name, 'EGO_ITEM_PROJ_DUP_ERR');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(
        p_encoded        => FND_API.G_FALSE,
        p_count          => x_msg_count,
        p_data           => x_msg_data
      );
    WHEN G_VALIDATION_ERROR THEN
      IF (FND_API.To_Boolean(p_commit)) THEN
        ROLLBACK TO Create_Proj_Item_Assoc_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name(g_app_name, 'EGO_ITEM_PROJ_TRACK_EXISTS');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(
        p_encoded        => FND_API.G_FALSE,
        p_count          => x_msg_count,
        p_data           => x_msg_data
      );
    WHEN FND_API.G_EXC_ERROR THEN
      IF FND_API.To_Boolean( p_commit ) THEN
        ROLLBACK TO Create_Proj_Item_Assoc_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF NOT x_msg_count = 1 THEN
        FND_MSG_PUB.Count_And_Get(
          p_encoded        => FND_API.G_FALSE,
          p_count          => x_msg_count,
          p_data           => x_msg_data
        );
      END IF;
    WHEN OTHERS THEN
      IF (FND_API.To_Boolean(p_commit)) THEN
        ROLLBACK TO Create_Proj_Item_Assoc_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
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

END Create_Project_Item_Assoc;

----------------------------------------------------------------------

/*

  DESCRIPTION
    Copies a project from a source item to a destination item.

  AUTHOR
    ssarnoba

  NOTES
    (-) This API copies a project associated at a source item to destination
    (-) Currently there is no need to return the ID of the association just
        created. It has no use to the caller.

  PARAMETERS
    (-) Association code is NOT functionally dependent on association type
    (-) We support all types of association code, not just LIFECYCLE_TRACKING
    (-) NULL value for p_init_msg_list means fnd_api.G_FALSE
    (-) NULL value for p_commit means fnd_api.G_FALSE

  PRECONDITIONS
    These must be respected by the caller and are not enforced here.
    (-) The source and destination items already exist
    (-) The user has VIEW privilege on source item.
    (-) The destination item is allowed to take on the same values as that
        of the project to which the destination item is being assigned.

  RETURN
    (-) When we are copying a Development Project, the return value
        x_item_project_id is NULL, because there will usually be several
        newly created item_project associations.

*/
PROCEDURE Copy_Project
(
     p_api_version             IN      NUMBER
   , p_init_msg_list           IN      VARCHAR2 DEFAULT FND_API.G_FALSE
   , p_commit                  IN      VARCHAR2 DEFAULT FND_API.G_FALSE
   , p_source_item_id          IN      NUMBER
   , p_source_org_id           IN      NUMBER
   , p_source_rev_id           IN      NUMBER
   , p_association_type        IN      VARCHAR2
   , p_association_code        IN      VARCHAR2
   , p_dest_item_id            IN      NUMBER
   , p_dest_org_id             IN      NUMBER
   , p_dest_rev_id             IN      NUMBER
   , p_check_privileges        IN      VARCHAR2 DEFAULT FND_API.G_FALSE
   , x_return_status           OUT     NOCOPY  VARCHAR2
   , x_error_code              OUT     NOCOPY  NUMBER
   , x_msg_count               OUT     NOCOPY  NUMBER
   , x_msg_data                OUT     NOCOPY  VARCHAR2
) IS
     l_return_status           VARCHAR2(1);
     l_error_code              NUMBER;
     l_msg_count               NUMBER;
     l_msg_data                VARCHAR2(4000);
     l_api_name                VARCHAR2(30);
     l_api_version             NUMBER;
     l_has_errors              BOOLEAN;

  -- Query that fetches all association records between the source item and
  -- its project(s)
  CURSOR project_assocs_cursor (cp_inventory_item_id IN NUMBER
                               ,cp_organization_id   IN NUMBER
                               ,cp_revision_id       IN NUMBER
                               ,cp_association_type  IN VARCHAR2
                               ,cp_association_code  IN VARCHAR2
                               ) IS
  SELECT project_id, task_id
    FROM ego_item_projects
   WHERE inventory_item_id = cp_inventory_item_id
     AND organization_id   = cp_organization_id
     AND NVL(revision_id,-1) = NVL(cp_revision_id,-1)  -- -1 is not a valid revision_id
     AND association_type  = cp_association_type
     AND association_code  = cp_association_code ;

BEGIN

  x_return_status := NULL;
  l_api_name      := 'Copy_Project';
  l_api_version   := 1.0;
  l_has_errors    := FALSE;

  code_debug (l_api_name ||' is called with params:');
  code_debug ('        p_source_item_id: ' || p_source_item_id);
  code_debug ('        p_source_org_id: ' || p_source_org_id);
  code_debug ('        p_source_rev_id: ' || p_source_rev_id);
  code_debug ('        p_association_type: ' || p_association_type);
  code_debug ('        p_association_code: ' || p_association_code);
  code_debug ('        p_dest_item_id: ' || p_dest_item_id);
  code_debug ('        p_dest_org_id: ' || p_dest_org_id);
  code_debug ('        p_dest_rev_id: ' || p_dest_rev_id);

  --Standard checks
  IF NOT FND_API.Compatible_API_Call (l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,g_pkg_name)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (FND_API.To_Boolean(p_init_msg_list)) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  IF FND_API.To_Boolean(p_commit) THEN
    SAVEPOINT Copy_Project_PUB;
  END IF;

  IF (p_source_item_id    IS NULL OR
      p_source_org_id     IS NULL OR
      p_association_type  IS NULL OR
      p_association_code  IS NULL OR
      p_dest_item_id      IS NULL OR
      p_dest_org_id       IS NULL
     ) THEN
    FND_MESSAGE.Set_Name(g_app_name, 'EGO_IPI_INSUFFICIENT_PARAMS');
    FND_MESSAGE.Set_Token('PROG_NAME', g_pkg_name||'.'||l_api_name);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  ----------------------------------------------------------------------------
  --                    Obtain the data to be inserted                      --
  ----------------------------------------------------------------------------

  -- Execute the query to get all rows for the existing project association
  FOR cr in project_assocs_cursor (cp_inventory_item_id => p_source_item_id
                                  ,cp_organization_id   => p_source_org_id
                                  ,cp_revision_id       => p_source_rev_id
                                  ,cp_association_type  => p_association_type
                                  ,cp_association_code  => p_association_code
                                  ) LOOP

    --------------------------------------------------------------------------
    --       Insert a copy of each row into the item-projects table         --
    --------------------------------------------------------------------------
    Create_Project_Item_Assoc(
      p_api_version             => p_api_version
     ,p_project_id              => cr.project_id
     ,p_organization_id         => p_dest_org_id
     ,p_inventory_item_id       => p_dest_item_id
     ,p_revision                => NULL           -- this is redundant if we pass revision_id
     ,p_revision_id             => p_dest_rev_id
     ,p_task_id                 => cr.task_id
     ,p_association_type        => p_association_type
     ,p_association_code        => p_association_code
     ,p_organization_specific   => NULL             -- this gets ignored anyway
     ,p_check_privileges        => p_check_privileges
     ,x_return_status           => l_return_status
     ,x_errorcode               => l_error_code
     ,x_msg_count               => l_msg_count
     ,x_msg_data                => l_msg_data);

    --------------------------------------------------------------------------
    --                          Error Handling                              --
    --------------------------------------------------------------------------

    IF NVL(l_return_status,FND_API.G_RET_STS_SUCCESS) <> FND_API.G_RET_STS_SUCCESS THEN
      l_has_errors := TRUE;
      IF NVL(l_return_status,FND_API.G_RET_STS_SUCCESS) = FND_API.G_RET_STS_UNEXP_ERROR THEN
        x_return_status := l_return_status;
      END IF;
      IF l_msg_count = 1 THEN
        -- add the fetched message into error stack
        FND_MESSAGE.Set_Name(g_app_name, 'EGO_GENERIC_MSG_TEXT');
        FND_MESSAGE.Set_Token('MESSAGE', l_msg_data);
        FND_MSG_PUB.Add;
      END IF;
    END IF;
  END LOOP;

  -- raise an error if anything was unsuccessful
  IF l_has_errors THEN
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  END IF;

  -- Standard check of p_commit.
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Copy_Project_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_encoded        => FND_API.G_FALSE,
        p_count          => x_msg_count,
        p_data           => x_msg_data
      );
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Copy_Project_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
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

END Copy_Project;

----------------------------------------------------------------------

PROCEDURE Copy_Item_Assocs
(
      p_api_version            IN      NUMBER
     ,p_project_id_from        IN      NUMBER
     ,p_project_id_to          IN      NUMBER
     ,p_init_msg_list          IN      VARCHAR2  DEFAULT fnd_api.g_FALSE
     ,p_commit                 IN      VARCHAR2  DEFAULT fnd_api.g_FALSE
     ,x_return_status          OUT     NOCOPY VARCHAR2
     ,x_errorcode              OUT     NOCOPY NUMBER
     ,x_msg_count              OUT     NOCOPY NUMBER
     ,x_msg_data               OUT     NOCOPY VARCHAR2
) IS

    l_api_version            NUMBER;
    l_api_name               VARCHAR2(30);
    l_is_org_specific        VARCHAR2(1);
    l_return_status          VARCHAR2(1);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(100);

    CURSOR project_assocs_cursor (cp_project_id IN NUMBER)
    IS
    SELECT DISTINCT ORGANIZATION_ID
                   ,INVENTORY_ITEM_ID
                   ,REVISION_ID
                   ,ASSOCIATION_TYPE
                   ,ASSOCIATION_CODE
               FROM EGO_ITEM_PROJECTS
              WHERE PROJECT_ID = cp_project_id;

  BEGIN

    l_api_version  := 1.0;
    l_api_name     := 'Copy_Item_Assocs';

    --Standard checks
    IF NOT FND_API.Compatible_API_Call (l_api_version
                                       ,p_api_version
                                       ,l_api_name
                                       ,g_pkg_name)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Copy_Item_Assocs_PUB;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    FOR assoc_rec IN project_assocs_cursor(p_project_id_from)
    LOOP

      IF (assoc_rec.ORGANIZATION_ID IS NULL) THEN
        l_is_org_specific := FND_API.G_FALSE;
      ELSE
        l_is_org_specific := FND_API.G_TRUE;
      END IF;

      IF (assoc_rec.ASSOCIATION_TYPE = g_project_assoc_type
          AND assoc_rec.ASSOCIATION_CODE <> g_lifecycle_tracking_code) THEN

        Create_Project_Item_Assoc(
          p_api_version             => 1.0
         ,p_project_id              => p_project_id_to
         ,p_organization_id         => assoc_rec.ORGANIZATION_ID
         ,p_inventory_item_id       => assoc_rec.INVENTORY_ITEM_ID
--         ,p_revision                => assoc_rec.REVISION
         ,p_revision_id             => assoc_rec.REVISION_ID
         ,p_association_type        => assoc_rec.ASSOCIATION_TYPE
         ,p_association_code        => assoc_rec.ASSOCIATION_CODE
         ,p_organization_specific   => l_is_org_specific
         ,x_return_status           => l_return_status
         ,x_errorcode               => x_errorcode
         ,x_msg_count               => x_msg_count
         ,x_msg_data                => x_msg_data
        );

        -- Keep track of and report the status of our worst failure
        IF (x_return_status IS NULL OR
            x_return_status = FND_API.G_RET_STS_SUCCESS OR
            (x_return_status = FND_API.G_RET_STS_ERROR AND
             l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)) THEN

          x_return_status := l_return_status;
        END IF;

      END IF;
    END LOOP;

    -- (keep this code before the commit check or it may behave incorrectly)
    IF (x_return_status IS NULL) THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;

    -- If we got no errors and the commit check passes, we commit
    IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND
        FND_API.To_Boolean(p_commit)) THEN
      COMMIT WORK;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_API.To_Boolean(p_commit)) THEN
        ROLLBACK TO Copy_Item_Assocs_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
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

END Copy_Item_Assocs;

----------------------------------------------------------------------


FUNCTION Has_LC_Tracking_Project (
      p_organization_id         IN      NUMBER
    , p_inventory_item_id       IN      NUMBER
    , p_revision                IN      VARCHAR2  DEFAULT NULL
) RETURN VARCHAR2
  IS

  BEGIN

   if (Has_Lifecycle_Tracking_Project(p_inventory_item_id, p_organization_id, p_revision)) THEN
      RETURN 'TRUE';
    END IF;

    RETURN 'FALSE';


END Has_LC_Tracking_Project;

----------------------------------------------------------------------



END EGO_LIFECYCLE_USER_PUB;


/
