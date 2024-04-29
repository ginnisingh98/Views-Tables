--------------------------------------------------------
--  DDL for Package Body INV_EGO_REVISION_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_EGO_REVISION_VALIDATE" AS
/* $Header: INVEGRVB.pls 120.60.12010000.11 2010/06/08 06:22:35 kaizhao ship $ */

   LOGGING_ERR           EXCEPTION;
   G_PROCESS_CONTROL     VARCHAR2(2000) := NULL;--Used by EGO API only for internal flow occntrol
   G_PROCESS_CONTROL_HTML_API     VARCHAR2(100) := NULL;
   /* Added to fix Bug#8434681 : This variable was added to check if the code path flow is comming from HTML pages ('HTML') or through open API ('API')
    variable G_PROCESS_CONTROL could have been used for this purpose. However, this varible is is utilized in many places in the code and reusing it might
    compromise the existing functionality. */

--Bug: 5258295
--  ============================================================================
--     API Name : mtl_catalog_group_update
--     Purpose  : NIR creation/cancellation and validations for ICC Update
--  ============================================================================
FUNCTION mtl_catalog_group_update(
        p_rowid               IN   ROWID
       ,p_process_flag        IN   NUMBER  --Added for R12C
       ,p_inventory_item_id   IN   NUMBER
       ,p_organization_id     IN   NUMBER
       ,p_old_item_cat_grp_id IN   NUMBER
       ,p_new_item_cat_grp_id IN   NUMBER
       ,p_approval_status     IN   VARCHAR2
       ,p_item_number         IN   VARCHAR2
       ,p_transaction_id      IN   NUMBER
       ,p_prog_appid          IN   NUMBER
       ,p_prog_id             IN   NUMBER
       ,p_request_id          IN   NUMBER
       ,p_xset_id             IN   NUMBER --Adding for R12 C
       ,p_user_id             IN   NUMBER
       ,p_login_id            IN   NUMBER
       ,x_err_text    OUT NOCOPY   VARCHAR2) RETURN INTEGER;
--  ============================================================================
--     API Name : Cancel_New_Item_Request
--     Purpose  : Cancels an NIR
--     Changing signature for R12 C
--  ============================================================================
PROCEDURE Cancel_New_Item_Request(
        p_inventory_item_id     IN NUMBER
       ,p_organization_id       IN NUMBER
       ,p_item_number           IN VARCHAR2
       ,p_auto_commit           IN VARCHAR2
       ,p_wf_user_id            IN NUMBER
       ,p_fnd_user_id           IN NUMBER
       ,x_return_status OUT NOCOPY VARCHAR2);

--  ============================================================================
--     API Name : Create_New_Item_Req_Upd
--     Purpose  : Creates a new NIR for ttype UPDATE
--  ============================================================================

PROCEDURE Create_New_Item_Req_Upd(
       p_row_id                IN ROWID
      ,p_item_catalog_group_id IN NUMBER
      ,p_item_number           IN VARCHAR2
      ,p_inventory_item_id     IN NUMBER
      ,p_organization_id       IN NUMBER
      ,p_xset_id               IN NUMBER --Adding for R12 C
      ,p_process_flag          IN NUMBER
      ,x_return_status OUT NOCOPY VARCHAR2);

--  ============================================================================
--  API Name    : validate_style_sku
--  Description : This procedure will be called from IOI
--                (after all other validations, including lifecycle and phase)
--                to validate the Style/SKU attributes of the item.
--  ============================================================================
FUNCTION validate_style_sku  (P_Row_Id IN ROWID,
                              P_Xset_id IN NUMBER,
                              X_Err_Text IN OUT NOCOPY VARCHAR2)
RETURN INTEGER;

--End Bug: 5258295
--  ============================================================================
--  API Name:           Check_LifeCycle
--
--        IN:           Catalog Group Id
--                      Lifecycle Id
--
--   Returns:           TRUE  if the lifecycle is valid for the catalog group
--                      FALSE if the lifecycle is NOT valid for the catalog group
--  ============================================================================

FUNCTION Check_LifeCycle (p_catalog_group_id IN NUMBER,
                          p_lifecycle_id     IN NUMBER)
RETURN BOOLEAN IS

  CURSOR c_Check_LifeCycle (p_catalog_group_id NUMBER,
                            p_lifecycle_id     NUMBER) IS
       SELECT 'x'
       FROM ego_obj_type_lifecycles eotl,
            pa_ego_lifecycles_phases_v lc,
            fnd_objects o
       WHERE lc.proj_element_id = p_lifecycle_id
             AND lc.proj_element_id = eotl.lifecycle_id
             AND   lc.object_type = 'PA_STRUCTURES'
             AND   eotl.object_id = o.object_id
             AND   eotl.object_classification_code in
             ( SELECT to_char(ic.item_catalog_group_id)
               FROM mtl_item_catalog_groups_b ic
               CONNECT BY PRIOR ic.parent_catalog_group_id = ic.item_catalog_group_id
               START WITH ic.item_catalog_group_id = p_catalog_group_id
             )
             AND o.obj_name = 'EGO_ITEM';

  l_exists VARCHAR2(1);

BEGIN

    OPEN c_Check_LifeCycle ( p_catalog_group_id => p_catalog_group_id,
                             p_lifecycle_id     => p_lifecycle_id);

    FETCH c_Check_LifeCycle INTO l_exists;

    IF ( c_Check_LifeCycle%NOTFOUND ) THEN
       CLOSE c_Check_LifeCycle;
       Return FALSE;
    END IF;

    CLOSE c_Check_LifeCycle;

    RETURN TRUE;

    EXCEPTION WHEN OTHERS THEN
      Return FALSE;

END Check_LifeCycle;

--  ============================================================================
--  API Name:           Check_LifeCycle_Phase
--
--        IN:           Lifecycle Id
--                      Lifecycle Phase Id
--
--   Returns:           TRUE  if the lifecycle phase is valid for the lifecycle
--                      FALSE if the lifecycle is NOT valid for the lifecycle
--  ============================================================================


FUNCTION Check_LifeCycle_Phase ( p_lifecycle_id       IN NUMBER,
                                 p_lifecycle_phase_id IN NUMBER)
RETURN BOOLEAN IS

  CURSOR c_Check_Lifecyle_Phase ( p_lifecycle_id       NUMBER,
                                  p_lifecycle_phase_id NUMBER) IS
     --4932389 : Perf fixes for lifecycle-phase-status queries.
     SELECT 'x'
     FROM   pa_proj_element_versions pev_l
           ,pa_lifecycle_usages plu
           ,pa_proj_element_versions pev_p
           ,pa_proj_elements ppe_p
           ,pa_project_statuses pc
     WHERE  pev_l.object_type     = 'PA_STRUCTURES'
       AND  pev_l.proj_element_id = p_lifecycle_id
       AND  pev_l.project_id      = 0
       AND  plu.usage_type        = 'PRODUCTS'
       AND  plu.lifecycle_id      = pev_l.proj_element_id
       AND  pev_p.proj_element_id = p_lifecycle_phase_id
       AND  pev_l.element_version_id = pev_p.parent_structure_version_id
       AND  pev_p.proj_element_id = ppe_p.proj_element_id
       AND  ppe_p.phase_code      = pc.project_status_code
       AND  (pc.start_date_active IS NULL OR pc.start_date_active <= SYSDATE)
       AND  (pc.end_date_active IS NULL OR pc.end_date_active >= SYSDATE)
     ORDER BY pev_p.display_sequence ;


  l_exists VARCHAR2(1);

BEGIN

    OPEN c_Check_Lifecyle_Phase ( p_lifecycle_id       => p_lifecycle_id,
                                  p_lifecycle_phase_id => p_lifecycle_phase_id);

    FETCH c_Check_Lifecyle_Phase INTO l_exists;

    IF ( c_Check_Lifecyle_Phase%NOTFOUND ) THEN
       CLOSE c_Check_Lifecyle_Phase;
       Return FALSE;
    END IF;

    CLOSE c_Check_Lifecyle_Phase;

    RETURN TRUE;

    EXCEPTION WHEN OTHERS THEN
      Return FALSE;

END Check_LifeCycle_Phase;

--  ============================================================================
--  API Name:           Get_Initial_LifeCycle_Phase
--
--        IN:           Lifecycle Id
--
--   Returns:           Initial Phase Id if found for the given lifecycle
--                      0 if NO phases found for the given lifecycle
--  ============================================================================

FUNCTION Get_Initial_Lifecycle_Phase ( p_lifecycle_id  IN NUMBER)
RETURN NUMBER IS

  CURSOR c_Get_Lifecyle_Phase ( p_lifecycle_id       NUMBER) IS
     --4932389 : Perf fixes for lifecycle-phase-status queries.
     SELECT pev_p.proj_element_id
     FROM   pa_proj_element_versions pev_l
           ,pa_lifecycle_usages plu
           ,pa_proj_element_versions pev_p
           ,pa_proj_elements ppe_p
           ,pa_project_statuses pc
     WHERE  pev_l.object_type = 'PA_STRUCTURES'
       AND  pev_l.proj_element_id = p_lifecycle_id
       AND  pev_l.project_id = 0
       AND  plu.usage_type = 'PRODUCTS'
       AND  plu.lifecycle_id = pev_l.proj_element_id
       AND  pev_l.element_version_id = pev_p.parent_structure_version_id
       AND  pev_p.proj_element_id = ppe_p.proj_element_id
       AND  ppe_p.phase_code = pc.project_status_code
       AND  (pc.start_date_active IS NULL OR pc.start_date_active <= SYSDATE)
       AND  (pc.end_date_active IS NULL OR pc.end_date_active     >= SYSDATE)
     ORDER BY pev_p.display_sequence ;

  l_phase_id NUMBER;

BEGIN

    OPEN c_Get_Lifecyle_Phase ( p_lifecycle_id     => p_lifecycle_id );

    FETCH c_Get_Lifecyle_Phase INTO l_phase_id;

    IF ( c_Get_Lifecyle_Phase%NOTFOUND ) THEN
       CLOSE c_Get_Lifecyle_Phase;
       Return 0;
    END IF;

    CLOSE c_Get_Lifecyle_Phase;

    RETURN l_phase_id;

    EXCEPTION WHEN OTHERS THEN
      Return 0;

END Get_Initial_Lifecycle_Phase;

--Start 2777118:Item Lifecycle and Phase validations

PROCEDURE Create_Validation(
         P_Lifecycle_Id      IN         NUMBER
        ,P_Phase_Id          IN         NUMBER
        ,P_Catalog_Group_Id  IN         NUMBER
        ,P_Status_Code       IN         VARCHAR2
        ,P_Rowid             IN         ROWID
        ,X_Error_Column      OUT NOCOPY VARCHAR2
        ,X_Error_Code        OUT NOCOPY VARCHAR2) IS

   CURSOR c_check_item_phase_status(cp_phase_id    NUMBER
                                   ,cp_status_code VARCHAR2)IS
      SELECT 'Y'
      FROM DUAL
      WHERE EXISTS ( SELECT NULL
                     FROM mtl_item_Catalog_groups_b
                     WHERE NVL(NEW_ITEM_REQUEST_REQD,'N') = 'Y'
                     AND   item_Catalog_group_id = P_Catalog_Group_Id)
            --4932389 : Perf fixes for lifecycle-phase-status queries.
            OR EXISTS (SELECT NULL
                       FROM  ego_lcphase_item_status  status
                            ,pa_ego_phases_v phase
                       WHERE status.phase_code = phase.phase_code
                       AND   proj_element_id   = cp_phase_id
                       AND   status.item_status_code = cp_status_code);

--Bug 7651939: item_type check is moved to validate_items_lifecycle function
--Refer to that function in this same package

      l_valid_status  VARCHAR2(1) := 'N';

   BEGIN

      X_Error_Code   := NULL;
      X_Error_Column := NULL;

      --2891650 : IOI should not default LC phase.
      IF P_Phase_Id IS NULL THEN
         X_Error_Code   := 'INV_IOI_PHASE_MANDATORY';
         X_Error_Column := 'CURRENT_PHASE_ID';
         Raise LOGGING_ERR;
      END IF;

      -- Lifecycle validation
      IF NOT INV_EGO_REVISION_VALIDATE.Check_LifeCycle
                      (p_catalog_group_id => P_Catalog_Group_Id,
                       p_lifecycle_id     => P_Lifecycle_Id)
      THEN
         X_Error_Code   := 'INV_IOI_INVALID_LC_CATALOG';
         X_Error_Column := 'LIFECYCLE_ID';
         Raise LOGGING_ERR;
      ELSE
         -- Lifecycle Phase Validation
         IF NOT INV_EGO_REVISION_VALIDATE.Check_LifeCycle_Phase
                      ( p_lifecycle_id       => P_Lifecycle_Id,
                        p_lifecycle_phase_id => P_Phase_Id)
         THEN
               X_Error_Code   := 'INV_IOI_INVALID_PHASE';
               X_Error_Column := 'CURRENT_PHASE_ID';
               Raise LOGGING_ERR;
         END IF;

         -- Phase Item Status validation
         OPEN  c_check_item_phase_status(cp_phase_id    => P_Phase_Id
                                        ,cp_status_code => P_Status_Code);
         FETCH c_check_item_phase_status INTO l_valid_status;
         CLOSE c_check_item_phase_status;

         IF l_valid_status IS NULL OR l_valid_status ='N' THEN
            X_Error_Code   := 'INV_IOI_INVALID_PHASE_STATUS';
            X_Error_Column := 'INVENTORY_ITEM_STATUS';
            Raise LOGGING_ERR;
         END IF;

      END IF; -- Life Cycle Validation

   END Create_Validation;

   PROCEDURE Update_Validation(
         P_Org_Id            IN         NUMBER
        ,P_Item_Id           IN         NUMBER
        ,P_Lifecycle_Id      IN         NUMBER
        ,P_Phase_Id          IN         NUMBER
        ,P_Catalog_Group_Id  IN         NUMBER
        ,P_Status_Code       IN         VARCHAR2
        ,P_Rowid             IN         ROWID
        ,X_Error_Column      OUT NOCOPY VARCHAR2
        ,X_Error_Code        OUT NOCOPY VARCHAR2) IS


      Cursor c_get_lifecycle_phase IS
         SELECT lifecycle_id,
                current_phase_id,
                item_catalog_group_id,
                approval_status    -- Added for 4046435
         FROM   mtl_system_items_b
         WHERE  inventory_item_id = P_Item_Id
         /*Changed for FP bug 8213894 with base bug 7492587*/
         /* AND    organization_id IN
                  (SELECT organization_id
                   FROM   mtl_parameters
                   WHERE  organization_id = master_organization_id); */
         AND    organization_id = P_Org_Id;

      --In update mode if item is unapproved donot validate "Pending" status
      Cursor c_check_item_phase_status
             (cp_phase_id    NUMBER
             ,cp_status_code VARCHAR2)IS
         SELECT 'Y'
         FROM DUAL
         WHERE EXISTS ( SELECT NULL
                        FROM mtl_system_items_b
                        WHERE inventory_item_id = P_Item_Id
                        AND   organization_id = P_Org_Id
                        AND   NVL(approval_status,'A') <> 'A'
                      )
             --4932389 : Perf fixes for lifecycle-phase-status queries.
            OR EXISTS (SELECT NULL
                       FROM  ego_lcphase_item_status  status
                            ,pa_ego_phases_v phase
                       WHERE status.phase_code = phase.phase_code
                       AND   proj_element_id   = cp_phase_id
                       AND   status.item_status_code = cp_status_code);

      --Promote/Demote only to the immediate phase before/after current -Bug5375723
      Cursor c_display_seq_phase(cp_phase_id NUMBER)
      IS
        SELECT display_sequence
          FROM pa_ego_phases_v
         WHERE proj_element_id = cp_phase_id ;

      l_Old_Phase_Id     mtl_system_items_b.current_phase_id%TYPE;
      l_Old_Lifecycle_Id mtl_system_items_b.lifecycle_id%TYPE;
      l_Old_catalog_group_Id mtl_system_items_b.item_catalog_group_id%TYPE;
      l_valid_status     VARCHAR2(1) := 'N';
      l_Policy_Code      VARCHAR2(20);
      l_Return_Status    VARCHAR2(1);
      l_Error_Code       NUMBER;
      l_Msg_Count        NUMBER;
      l_Msg_Data         VARCHAR2(2000);
      l_approval_status  mtl_system_items_b.approval_status%TYPE; --Bug 4046435
      -- Bug 5375723
      l_old_disp_seq     NUMBER;
      l_new_disp_seq     NUMBER;

   BEGIN

      X_Error_Code   := NULL;
      X_Error_Column := NULL;

--Bug 4046435
      OPEN  c_get_lifecycle_phase;
      FETCH c_get_lifecycle_phase
      INTO  l_Old_Lifecycle_Id,l_Old_Phase_Id,l_Old_catalog_group_Id,l_approval_status ;
      CLOSE c_get_lifecycle_phase;

      IF ( (P_Lifecycle_Id <> NVL(l_Old_Lifecycle_Id, -1))  OR
           (P_Phase_Id <> NVL(l_Old_Phase_Id, -1))
         ) AND (NVL(l_approval_status, 'NULL VALUE') = 'S')
           AND (l_Old_Lifecycle_Id is NOT NULL)             THEN --BUG 4046435
            X_Error_Code   := 'INV_IOI_LC_CHANGE_DISALLOWED';
            X_Error_Column := 'LIFECYCLE_ID';
            Raise LOGGING_ERR;
      END IF;
--Bug 4046435

      IF P_Lifecycle_Id <> NVL(l_Old_Lifecycle_Id, -1)  OR
          NVL(P_Catalog_Group_Id,-1) <> NVL(l_Old_catalog_group_Id, -1) THEN--Bug:4114952
         /* 3342860: Life Cycle now can be changed during Item update.
         X_Error_Code   := 'INV_IOI_INVALID_LC_CHANGE';
         X_Error_Column := 'LIFECYCLE_ID';
         Raise LOGGING_ERR;
         */
         Create_Validation(
                P_Lifecycle_Id     => P_Lifecycle_Id
               ,P_Phase_Id         => P_Phase_Id
               ,P_Catalog_Group_Id => P_Catalog_Group_Id
               ,P_Status_Code      => P_Status_Code
               ,P_Rowid            => P_Rowid
               ,X_Error_Column     => X_Error_Column
               ,X_Error_Code       => X_Error_Code);
      ELSE
         --2891650 : IOI should not default LC phase.
         IF P_Phase_Id IS NULL THEN
            X_Error_Code   := 'INV_IOI_PHASE_MANDATORY';
            X_Error_Column := 'CURRENT_PHASE_ID';
            Raise LOGGING_ERR;
         END IF;

         -- Lifecycle validation
        IF P_Lifecycle_Id <> l_Old_Lifecycle_Id THEN
         IF NOT INV_EGO_REVISION_VALIDATE.Check_LifeCycle
                      (p_catalog_group_id => P_Catalog_Group_Id,
                       p_lifecycle_id     => P_Lifecycle_Id)
         THEN
            X_Error_Code   := 'INV_IOI_INVALID_LC_CATALOG';
            X_Error_Column := 'LIFECYCLE_ID';
            Raise LOGGING_ERR;
         END IF;
        END IF;

        IF  X_Error_Code IS NULL THEN
            -- Lifecycle Phase Validation
            --Check phase change is allowed or not
            IF P_Phase_Id <> l_Old_Phase_Id THEN

             IF NOT INV_EGO_REVISION_VALIDATE.Check_LifeCycle_Phase
                      ( p_lifecycle_id       => P_Lifecycle_Id,
                        p_lifecycle_phase_id => P_Phase_Id)
             THEN
               X_Error_Code   := 'INV_IOI_INVALID_PHASE';
               X_Error_Column := 'CURRENT_PHASE_ID';
               Raise LOGGING_ERR;
             END IF;

             IF P_Lifecycle_Id = l_Old_Lifecycle_Id THEN
                -- Start of bug 5375723
                OPEN  c_display_seq_phase(cp_phase_id => l_Old_Phase_Id);
                FETCH c_display_seq_phase INTO l_old_disp_seq;
                CLOSE c_display_seq_phase;

                OPEN  c_display_seq_phase(cp_phase_id => P_Phase_Id);
                FETCH c_display_seq_phase INTO l_new_disp_seq;
                CLOSE c_display_seq_phase;

                IF ( abs(l_old_disp_seq - l_new_disp_seq) <> 1 ) THEN
                   X_Error_Code   := 'INV_IOI_INVALID_PHASE';
                   X_Error_Column := 'CURRENT_PHASE_ID';
                   Raise LOGGING_ERR;
                END IF;
                -- End of bug 5375723

                EGO_LIFECYCLE_USER_PUB.get_policy_for_phase_change
                   (P_API_VERSION       => 1.0
                   ,P_INVENTORY_ITEM_ID => P_Item_Id
                   ,P_ORGANIZATION_ID   => P_Org_Id
                   ,P_CURR_PHASE_ID     => l_Old_Phase_Id
                   ,P_FUTURE_PHASE_ID   => P_Phase_Id
                   ,P_PHASE_CHANGE_CODE => NULL
                   ,P_LIFECYCLE_ID      => P_Lifecycle_Id
                   ,X_POLICY_CODE       => l_Policy_Code
                   ,X_RETURN_STATUS     => l_Return_Status
                   ,X_ERRORCODE         => l_Error_Code
                   ,X_MSG_COUNT         => l_Msg_Count
                   ,X_MSG_DATA          => l_Msg_Data);

                IF l_Policy_Code <> 'ALLOWED' THEN
                   X_Error_Code   := 'INV_IOI_PHASE_CHANGE_NOT_VALID';
                   X_Error_Column := 'CURRENT_PHASE_ID';
                   Raise LOGGING_ERR;
                END IF;
             END IF;

           END IF;

            -- Phase Item Status validation
            OPEN  c_check_item_phase_status(cp_phase_id    => P_Phase_Id
                                           ,cp_status_code => P_Status_Code);
            FETCH c_check_item_phase_status INTO l_valid_status;
            CLOSE c_check_item_phase_status;


            IF l_valid_status IS NULL OR l_valid_status ='N' THEN
               X_Error_Code   := 'INV_IOI_INVALID_PHASE_STATUS';
               X_Error_Column := 'INVENTORY_ITEM_STATUS';
               Raise LOGGING_ERR;
            END IF;
         END IF; -- Life Cycle Validation X_error_code

      END IF;

   END Update_Validation;

   PROCEDURE Validate_Child_Items(
         P_Org_Id            IN         NUMBER
        ,P_Item_Id           IN         NUMBER
        ,P_Lifecycle_Id      IN         NUMBER
        ,P_Phase_Id          IN         NUMBER
        ,P_Catalog_Group_Id  IN         NUMBER
        ,P_Status_Code       IN         VARCHAR2
        ,P_Transaction_Type  IN         VARCHAR2
        ,P_Rowid             IN         ROWID
        ,X_Error_Column      OUT NOCOPY VARCHAR2
        ,X_Error_Code        OUT NOCOPY VARCHAR2) IS

      CURSOR c_get_master_details(cp_item_id NUMBER) IS
         SELECT Lifecycle_id, Current_Phase_Id
         FROM   mtl_system_items_b
         WHERE  inventory_item_id = cp_item_id
         AND    organization_id IN
                (SELECT organization_id
                 FROM   mtl_parameters
                 WHERE organization_id = master_organization_id)
         UNION
         SELECT Lifecycle_id, Current_Phase_Id
         FROM   mtl_system_items_interface
         WHERE  inventory_item_id = cp_item_id
         AND    process_flag = 4
         AND    organization_id IN
                (SELECT organization_id
                 FROM   mtl_parameters
                 WHERE organization_id = master_organization_id);

     CURSOR c_get_control_level    IS
       SELECT control_level
       FROM   mtl_item_attributes
       WHERE  attribute_name = 'MTL_SYSTEM_ITEMS.INVENTORY_ITEM_STATUS_CODE';


      l_Master_Phase_Id     mtl_system_items_b.current_phase_id%TYPE;
      l_Master_Lifecycle_Id mtl_system_items_b.lifecycle_id%TYPE;
      l_status_control      NUMBER(2) := 1; --Master controlled
   BEGIN
      X_Error_Code   := NULL;
      X_Error_Column := NULL;

      OPEN  c_get_master_details(cp_item_id => P_Item_Id);
      FETCH c_get_master_details
      INTO  l_Master_Lifecycle_Id,l_Master_Phase_Id;
      CLOSE c_get_master_details;

      IF l_Master_Lifecycle_Id IS NULL OR
         l_Master_Lifecycle_Id <> P_Lifecycle_Id
      THEN
         X_Error_Code   := 'INV_IOI_ORGLIFECYCLE_CONFLICT';
         X_Error_Column := 'LIFECYCLE_ID';
         Raise LOGGING_ERR;
      ELSE
         OPEN  c_get_control_level;
         FETCH c_get_control_level INTO  l_status_control;
         CLOSE c_get_control_level ;

         --2891650 : IOI should not default LC phase.
         IF P_Phase_Id IS NULL THEN
            X_Error_Code   := 'INV_IOI_PHASE_MANDATORY';
            X_Error_Column := 'CURRENT_PHASE_ID';
            Raise LOGGING_ERR;
         END IF;

         IF l_Master_Phase_Id IS NULL OR
            (l_Master_Phase_Id <> P_Phase_Id AND l_status_control = 1)
         THEN
            X_Error_Code   := 'INV_IOI_ORGPHASE_CONFLICT';
            X_Error_Column := 'CURRENT_PHASE_ID';
            Raise LOGGING_ERR;
         END IF;

         IF P_Transaction_Type ='CREATE' THEN

            Create_Validation(
                P_Lifecycle_Id     => P_Lifecycle_Id
               ,P_Phase_Id         => P_Phase_Id
               ,P_Catalog_Group_Id => P_Catalog_Group_Id
               ,P_Status_Code      => P_Status_Code
               ,P_Rowid            => P_Rowid
               ,X_Error_Column     => X_Error_Column
               ,X_Error_Code       => X_Error_Code);

         ELSIF P_Transaction_Type ='UPDATE' THEN

            Update_Validation(
               P_Org_Id           => P_Org_Id
              ,P_Item_Id          => P_Item_Id
              ,P_Lifecycle_Id     => P_Lifecycle_Id
              ,P_Phase_Id         => P_Phase_Id
              ,P_Catalog_Group_Id => P_Catalog_Group_Id
              ,P_Status_Code      => P_Status_Code
              ,P_Rowid            => P_Rowid
              ,X_Error_Column     => X_Error_Column
              ,X_Error_Code       => X_Error_Code);

         END IF; --Transaction Type
      END IF;
   END Validate_Child_Items;

  /*
   * Private API to get the display name of attributes
   */
  FUNCTION Get_Attr_Display_Name(p_attr_group_type VARCHAR2,
                                 p_attr_group_name VARCHAR2,
                                 p_attr_name       VARCHAR2)
  RETURN VARCHAR2 IS
    l_disp_name VARCHAR2(4000);
  BEGIN
    SELECT TL.FORM_LEFT_PROMPT ATTR_DISPLAY_NAME
    INTO l_disp_name
    FROM FND_DESCR_FLEX_COLUMN_USAGES FL_COL ,FND_DESCR_FLEX_COL_USAGE_TL TL
    WHERE FL_COL.DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
      AND FL_COL.DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_group_name
      AND FL_COL.APPLICATION_ID = 431
      AND FL_COL.END_USER_COLUMN_NAME = p_attr_name
      AND FL_COL.APPLICATION_ID = TL.APPLICATION_ID
      AND FL_COL.DESCRIPTIVE_FLEXFIELD_NAME = TL.DESCRIPTIVE_FLEXFIELD_NAME
      AND FL_COL.DESCRIPTIVE_FLEX_CONTEXT_CODE = TL.DESCRIPTIVE_FLEX_CONTEXT_CODE
      AND FL_COL.APPLICATION_COLUMN_NAME = TL.APPLICATION_COLUMN_NAME
      AND TL.LANGUAGE = USERENV('LANG');

    RETURN l_disp_name;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN p_attr_name;
  END Get_Attr_Display_Name;

   FUNCTION validate_items_lifecycle(
         P_Org_Id       IN            NUMBER
        ,P_All_Org      IN            NUMBER  DEFAULT  2
        ,P_Prog_AppId   IN            NUMBER  DEFAULT -1
        ,P_Prog_Id      IN            NUMBER  DEFAULT -1
        ,P_Request_Id   IN            NUMBER  DEFAULT -1
        ,P_User_Id      IN            NUMBER  DEFAULT -1
        ,P_Login_Id     IN            NUMBER  DEFAULT -1
        ,P_Set_id       IN            NUMBER  DEFAULT -999
        ,P_Process_Flag IN           NUMBER   DEFAULT 4
        ,X_Err_Text     IN OUT NOCOPY VARCHAR2
        )
   RETURN INTEGER IS

        -- 5351611 Modified both the cursors to use EXISTS/NOT EXISTS
        -- instead of IN/NOT IN
      CURSOR c_get_master_items IS
         SELECT rowid,
                organization_id,
                inventory_item_id,
                lifecycle_id,
                current_phase_Id,
                inventory_item_status_code,
                item_catalog_group_Id,
                transaction_id,
                transaction_type,
                item_number,
                unit_weight,
                weight_uom_code,
                style_item_flag,
                trade_item_descriptor,
                gdsn_outbound_enabled_flag,
                primary_uom_code
         FROM   mtl_system_items_interface int
         WHERE  (int.organization_id = P_Org_Id OR P_All_Org = 1)
         AND    int.set_process_id = P_Set_id
         AND    int.process_flag = P_Process_Flag
         AND    EXISTS -- organization_id IN
                   (SELECT 1 --organization_id
                    FROM   mtl_parameters mp
                    WHERE  int.organization_id = mp.master_organization_id
                      AND  mp.organization_id = mp.master_organization_id )
         FOR UPDATE OF int.current_phase_id, int.process_flag;

      CURSOR c_get_child_items IS
         SELECT rowid,
                organization_id,
                inventory_item_id,
                lifecycle_id,
                current_phase_Id,
                inventory_item_status_code,
                item_catalog_group_Id,
                transaction_id,
                transaction_type,
                item_number,
                unit_weight,
                weight_uom_code,
                style_item_flag,
                trade_item_descriptor,
                gdsn_outbound_enabled_flag,
                primary_uom_code
         FROM   mtl_system_items_interface int
         WHERE  (int.organization_id = P_Org_Id OR P_All_Org = 1)
         AND    int.set_process_id = P_Set_id
         AND    int.process_flag = P_Process_Flag
         AND    NOT EXISTS -- organization_id NOT IN
                   (SELECT 1 -- organization_id
                    FROM   mtl_parameters mp
                    WHERE  int.organization_id = mp.master_organization_id
                      AND  mp.organization_id = mp.master_organization_id)
         FOR UPDATE OF int.current_phase_id,int.process_flag;

      CURSOR c_ego_exists IS
         SELECT 'Y'
         FROM   fnd_objects
         WHERE  obj_name = 'EGO_ITEM';

       CURSOR c_get_existing_item_details(cp_inventory_item_id IN NUMBER,
                                          cp_organization_id IN NUMBER)
       IS
          SELECT item_catalog_group_Id,approval_status
                ,unit_weight, weight_uom_code,trade_item_descriptor
                ,gdsn_outbound_enabled_flag
          FROM mtl_system_items
          WHERE inventory_item_id = cp_inventory_item_id
          AND organization_id = cp_organization_id;

       CURSOR c_pack_item_type (cp_pack_item_type IN VARCHAR2)
       IS
          SELECT 1 FROM ego_value_set_values_v
           WHERE value_set_name =  'TradeItemDescVS'
             AND internal_name = cp_pack_item_type;

       CURSOR c_base_uom (cp_primary_uom_code IN VARCHAR2)
       IS
          SELECT base_uom_flag
            FROM mtl_units_of_measure
           WHERE uom_code = cp_primary_uom_code;

      --Bug 7651939: move item_type check from create_validation to here
      --Bug:3777954 In create mode if catalog category has NIR setup , item must be engineering item
      Cursor c_check_item_type ( cp_row_id IN ROWID
                               , cp_catalog_group_id IN NUMBER
                               )
      IS
         SELECT 'Y'
         FROM DUAL
         WHERE EXISTS ( SELECT NULL
                        FROM mtl_item_Catalog_groups_b
                        WHERE NVL(NEW_ITEM_REQUEST_REQD,'N') = 'Y'
                        AND   item_Catalog_group_id = cp_catalog_group_id
                      )
             AND EXISTS ( SELECT NULL
                         FROM  mtl_system_items_interface
                         WHERE NVL(eng_item_flag,'N')='N'
                         AND  rowid = cp_row_id);

      l_valid_status         VARCHAR2(1) := 'N';
      l_old_pack_item_type   MTL_SYSTEM_ITEMS_B.trade_item_descriptor%TYPE;
      l_ret_status           VARCHAR2(100);
      l_valid_pack_type      NUMBER := 0;
      l_item_in_pack         VARCHAR2(1) := FND_API.G_FALSE;
      l_old_gdsn_flag        VARCHAR2(1);
      l_is_primary_uom_base  VARCHAR2(1);
      l_err_text             VARCHAR2(1000);
      l_ego_exists           VARCHAR2(1) := 'N';
      l_error_status         NUMBER := 0;
      l_error_logged         NUMBER := 0;
      l_master_lifecycle_id  NUMBER;
      X_Error_Code           VARCHAR2(100);
      X_Error_Column         VARCHAR2(100)  := 'LIFECYCLE_ID';
      l_error_msg            VARCHAR2(2000);
      l_return_status        VARCHAR2(100);
      X_RETURN_STATUS        VARCHAR2(3);
      X_MSG_COUNT            NUMBER;
      X_MSG_DATA             VARCHAR2(240);
      l_old_catalog_group_id NUMBER;
      l_approval_status      VARCHAR2(1);
      l_old_unit_weight      MTL_SYSTEM_ITEMS_B.UNIT_WEIGHT%TYPE;
      l_old_weight_uom_code  MTL_SYSTEM_ITEMS_B.WEIGHT_UOM_CODE%TYPE;
      l_valid                VARCHAR2(100) := FND_API.G_TRUE;
      l_is_gdsn              NUMBER;
      l_unit_wt_disp_name      VARCHAR2(1000);
      l_unit_wt_uom_disp_name  VARCHAR2(1000);
      l_gtid_disp_name         VARCHAR2(1000);
   BEGIN

      OPEN  c_ego_exists;
      FETCH c_ego_exists INTO l_ego_exists;
      CLOSE c_ego_exists;

      IF (l_ego_exists ='Y' AND INV_Item_Util.g_Appl_Inst.EGO <> 0) THEN -- Bug 4175124 THEN

       IF (INSTR(NVL(G_PROCESS_CONTROL,'PLM_UI:N'),'PLM_UI:Y') = 0 )
       THEN

         FOR cur IN c_get_master_items LOOP

            l_error_status := 0;
            l_error_logged := 0;

            -- Bug 7651939: move item_type check from create_validation to here
            -- Only check type when item is CREATED for MASTER ORG
            l_valid_status := 'N';
            IF cur.transaction_type ='CREATE' THEN
         			OPEN  c_check_item_type(cur.rowid, cur.item_catalog_group_id);
         			FETCH c_check_item_type INTO l_valid_status;
         			CLOSE c_check_item_type;

		      		IF l_valid_status ='Y' THEN
                  	l_error_logged :=
                        	INVPUOPI.mtl_log_interface_err(
                              	cur.organization_id,
                                	P_User_Id,
                                	P_Login_Id,
                                	P_Prog_AppId,
                                	P_Prog_Id,
                                	P_Request_id,
                                	cur.transaction_id,
                                	l_error_msg,
                                	'ENG_ITEM_FLAG',
                                	'MTL_SYSTEM_ITEMS_INTERFACE',
                                 	'INV_IOI_NIR_NO_MFG_ITEM',
                                 	X_Err_Text);
                     	IF l_error_logged < 0 THEN
                        	Raise LOGGING_ERR;
                     	END IF;
                     	l_error_status := 1;
		      		END IF; -- valid_status

            END IF; -- transaction_type

            IF cur.lifecycle_id IS NOT NULL THEN
               IF cur.transaction_type ='CREATE' THEN
                  BEGIN
                     Create_Validation(
                        P_Lifecycle_Id     => cur.lifecycle_id
                       ,P_Phase_Id         => cur.current_phase_id
                       ,P_Catalog_Group_Id => cur.item_catalog_group_id
                       ,P_Status_Code      => cur.inventory_item_status_code
                       ,P_Rowid            => cur.rowid
                       ,X_Error_Column     => X_Error_Column
                       ,X_Error_Code       => X_Error_Code);

                   EXCEPTION
                      WHEN LOGGING_ERR THEN
                         l_error_logged :=
                            INVPUOPI.mtl_log_interface_err(
                                cur.organization_id,
                                P_User_Id,
                                P_Login_Id,
                                P_Prog_AppId,
                                P_Prog_Id,
                                P_Request_id,
                                cur.transaction_id,
                                l_error_msg,
                                X_Error_Column,
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                 X_Error_Code,
                                 X_Err_Text);
                     IF l_error_logged < 0 THEN
                        Raise LOGGING_ERR;
                     END IF;
                     l_error_status := 1;
                   END; -- Exception Block

               ELSIF cur.transaction_type ='UPDATE' THEN

                  BEGIN

                     Update_Validation(
                        P_Org_Id           => cur.organization_id
                       ,P_Item_Id          => cur.inventory_item_id
                       ,P_Lifecycle_Id     => cur.lifecycle_id
                       ,P_Phase_Id         => cur.current_phase_id
                       ,P_Catalog_Group_Id => cur.item_catalog_group_id
                       ,P_Status_Code      => cur.inventory_item_status_code
                       ,P_Rowid            => cur.rowid
                       ,X_Error_Column     => X_Error_Column
                       ,X_Error_Code       => X_Error_Code);

                  EXCEPTION
                      WHEN LOGGING_ERR THEN
                         l_error_logged :=
                            INVPUOPI.mtl_log_interface_err(
                                cur.organization_id,
                                P_User_Id,
                                P_Login_Id,
                                P_Prog_AppId,
                                P_Prog_Id,
                                P_Request_id,
                                cur.transaction_id,
                                l_error_msg,
                                X_Error_Column,
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                 X_Error_Code,
                                 X_Err_Text);

                     IF l_error_logged < 0 THEN
                        Raise LOGGING_ERR;
                     END IF;
                     l_error_status := 1;
                   END; -- Exception Block
               END IF; -- Transaction Type
            ELSE
               --3457443 : lifecycle and phase validation during update also.
               --Life Cyle is null but phase has been provided
               IF cur.current_phase_id IS NOT NULL THEN
                  l_error_logged := INVPUOPI.mtl_log_interface_err(
                                cur.organization_id,
                                P_User_Id,
                                P_Login_Id,
                                P_Prog_AppId,
                                P_Prog_Id,
                                P_Request_id,
                                cur.transaction_id,
                                l_error_msg,
                                'CURRENT_PHASE_ID',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_LIFECYCLE_MANDATORY',
                                 X_Err_Text);

                  IF l_error_logged  < 0 THEN
                     Raise LOGGING_ERR;
                  END IF;
                  l_error_status := 1;

               END IF; --Phase id is not null
            END IF; -- Lifecycle is not null

            IF p_process_flag = 4 THEN --To prevent validations from firing during Change Policy Check
      /* Bug 5523228 - Added to calidate Unit wt and wt uom against Trade Item Descriptor */
      /* Bug 5571909 - added check for G_PROCESS_CONTROL and also modified messaging*/
             /* Following check is commented out for bug 6126443, Fetching old values have to
                be moved out side the conditional since these values are expected even if the condition fails
                other loops as well */
             -- IF ( l_error_status <> 1 AND NVL(G_PROCESS_CONTROL, 'N') <> 'SUPPRESS_ROLLUP' ) THEN
              OPEN c_get_existing_item_details(cur.inventory_item_id, cur.organization_id);
              FETCH c_get_existing_item_details INTO l_old_catalog_group_id,l_approval_status,
                                                     l_old_unit_weight, l_old_weight_uom_code,
                                                     l_old_pack_item_type,l_old_gdsn_flag;
              CLOSE c_get_existing_item_details;

              IF ( l_error_status <> 1 AND NVL(G_PROCESS_CONTROL, 'N') <> 'SUPPRESS_ROLLUP' ) THEN
                 IF ( (((cur.unit_weight     IS NOT NULL) AND (NVL(cur.unit_weight,-1)     <> NVL(l_old_unit_weight,-1)))
                     OR((cur.weight_uom_code IS NOT NULL) AND (NVL(cur.weight_uom_code,-1) <> NVL(l_old_weight_uom_code,-1))))
                           AND cur.transaction_type = 'UPDATE'
                           AND cur.gdsn_outbound_enabled_flag = 'Y')
                 THEN
                       l_valid := EGO_GTIN_PVT.Validate_Unit_Wt_Uom(p_inventory_item_id => cur.inventory_item_id,
                                                                    p_org_id            => cur.organization_id );

                       IF (l_valid <> FND_API.G_TRUE) THEN
                           l_unit_wt_disp_name := Get_Attr_Display_Name('EGO_MASTER_ITEMS', 'PhysicalAttributes' , 'UNIT_WEIGHT');
                           l_unit_wt_uom_disp_name := Get_Attr_Display_Name('EGO_MASTER_ITEMS', 'PhysicalAttributes' , 'WEIGHT_UOM_CODE');
                           l_gtid_disp_name := Get_Attr_Display_Name('EGO_ITEM_GTIN_ATTRS', 'Trade_Item_Description' , 'Trade_Item_Descriptor');
                           FND_MESSAGE.SET_NAME ( 'EGO', 'EGO_2ATTRS_NOT_EDITABLE');
                           FND_MESSAGE.SET_TOKEN ('ATTR1', l_unit_wt_disp_name);
                           FND_MESSAGE.SET_TOKEN ('ATTR2', l_unit_wt_uom_disp_name);
                           FND_MESSAGE.SET_TOKEN ('GTID', l_gtid_disp_name);
                           l_error_msg := FND_MESSAGE.GET;

                           l_error_logged := INVPUOPI.mtl_log_interface_err(
                                  cur.organization_id,
                                  P_User_Id,
                                  P_Login_Id,
                                  P_Prog_AppId,
                                  P_Prog_Id,
                                  P_Request_id,
                                  cur.transaction_id,
                                  l_error_msg,
                                  'UNIT_WEIGHT',
                                  'MTL_SYSTEM_ITEMS_INTERFACE',
                                  'INV_IOI_ERR',
                                   X_Err_Text);

                           IF l_error_logged  < 0 THEN
                              Raise LOGGING_ERR;
                           END IF;
                           l_error_status := 1;
                       END IF;
                 END IF;
              END IF;

              IF cur.style_item_flag IS NOT NULL THEN
                 l_ret_status := validate_style_sku ( p_row_id => cur.rowid,
                                                      p_xset_id => P_Set_id,
                                                      x_err_text => x_err_text);
                 IF l_ret_status <> 0 THEN

                    UPDATE mtl_system_items_interface
                       SET process_flag = 3
                     WHERE rowid = cur.rowid;

                    l_error_logged := INVPUOPI.mtl_log_interface_err(
                                           cur.organization_id,
                                           P_User_Id,
                                           P_Login_Id,
                                           P_Prog_AppId,
                                           P_Prog_Id,
                                           P_Request_id,
                                           cur.transaction_id,
                                           SQLERRM,
                                          'STYLE_ITEM_FLAG',
                                          'MTL_SYSTEM_ITEMS_INTERFACE',
                                          'INV_IOI_ERR',
                                           x_err_text);
                    IF l_error_logged < 0 THEN
                       Raise LOGGING_ERR;
                    END IF;
                 END IF;
              END IF;

           /* Bug 5389029 - Adding a condition to chk for errors so far */
              IF ((cur.item_catalog_group_id IS NOT NULL) AND ( l_error_status <> 1 ) AND (cur.transaction_type = 'UPDATE'))THEN
                  /* Adding the ttype check and the NVL clause to the ICC change condition */
                 IF (NVL(l_old_catalog_group_id, -1) <> NVL(cur.item_catalog_group_id,-1)) THEN
                 /* Bug 5389029 - Passing Int Table values for Lifecycle/Phase */
                    EGO_INV_ITEM_CATALOG_PVT.Change_Item_Catalog (
                         P_INVENTORY_ITEM_ID    => cur.inventory_item_id
                        ,P_ORGANIZATION_ID      => cur.organization_id
                        ,P_CATALOG_GROUP_ID     => l_old_catalog_group_id
                        ,P_NEW_CATALOG_GROUP_ID => cur.item_catalog_group_id
                        ,P_NEW_LIFECYCLE_ID     => cur.lifecycle_id
                        ,P_NEW_PHASE_ID         => cur.current_phase_id
                        ,P_NEW_ITEM_STATUS_CODE => cur.inventory_item_status_code
                        ,P_COMMIT               => FND_API.G_FALSE
                        ,X_RETURN_STATUS        => X_RETURN_STATUS
                        ,X_MSG_COUNT            => X_MSG_COUNT
                        ,X_MSG_DATA             => X_MSG_DATA );

               /* Bug 5389029 - Passing the right arguments for clear error log */
                    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                       l_error_logged := INVPUOPI.mtl_log_interface_err(
                                           cur.organization_id,
                                           P_User_Id,
                                           P_Login_Id,
                                           P_Prog_AppId,
                                           P_Prog_Id,
                                           P_Request_id,
                                           cur.transaction_id,
                                           X_MSG_DATA,
                                          'ITEM_CATALOG_GROUP_ID',
                                          'MTL_SYSTEM_ITEMS_INTERFACE',
                                          'INV_IOI_ERR',
                                           X_ERR_TEXT);

                       IF l_error_logged < 0 THEN
                          Raise LOGGING_ERR;
                       END IF;
                       l_error_status := 1;
                    ELSE
                       --Bug: 5258295
                       l_return_status := INV_EGO_REVISION_VALIDATE.mtl_catalog_group_update (
                                             p_rowid               => cur.rowid
                                            ,p_process_flag        => p_process_flag --Added for R12 C
                                            ,p_inventory_item_id   => cur.inventory_item_id
                                            ,p_organization_id     => cur.organization_id
                                            ,p_old_item_cat_grp_id => l_old_catalog_group_id
                                            ,p_new_item_cat_grp_id => cur.item_catalog_group_id
                                            ,p_approval_status     => l_approval_status
                                            ,p_item_number         => cur.item_number
                                            ,p_transaction_id      => cur.transaction_id
                                            ,p_prog_appid          => p_prog_appid
                                            ,p_prog_id             => p_prog_id
                                            ,p_request_id          => p_request_id
                                            ,p_xset_id             => P_Set_Id --Added for R12 C
                                            ,p_user_id             => p_user_id
                                            ,p_login_id            => p_login_id
                                            ,x_err_text            => x_err_text);

                       IF l_return_status <> 0 THEN
                          l_error_logged := INVPUOPI.mtl_log_interface_err(
                                             cur.organization_id,
                                             P_User_Id,
                                             P_Login_Id,
                                             P_Prog_AppId,
                                             P_Prog_Id,
                                             P_Request_id,
                                             cur.transaction_id,
                                             l_error_msg,
                                             'ITEM_CATALOG_GROUP_ID',
                                             'MTL_SYSTEM_ITEMS_INTERFACE',
                                              x_err_text,
                                              x_err_text);

                          IF l_error_logged < 0 THEN
                             Raise LOGGING_ERR;
                          END IF;
                          l_error_status := 1;
                       END IF;
                    END IF;  -- X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS
                 END IF;     -- (l_old_catalog_group_id <> cur.item_catalog_group_id)
              END IF;        --(cur.item_catalog_group_id IS NOT NULL)

           /* Pack Item Type Validations */
              IF   ((cur.gdsn_outbound_enabled_flag IS NULL OR cur.gdsn_outbound_enabled_flag = 'N')
                     AND (l_old_gdsn_flag = 'Y')) THEN
                   l_error_logged := INVPUOPI.mtl_log_interface_err (
                                              Cur.organization_id,
                                              P_User_Id,
                                              P_Login_Id,
                                              P_Prog_AppId,
                                              P_Prog_Id,
                                              P_Request_id,
                                              cur.transaction_id,
                                              l_error_msg,
                                              'GDSN_OUTBOUND_ENABLED_FLAG',
                                              'MTL_SYSTEM_ITEMS_INTERFACE',
                                              'INV_GDSN_UPD_NO_INVALID',
                                              X_Err_Text);
                  l_error_status :=  1;
              END IF;

             /* Section 2.5.2 Condition 2 Pack item type should be a valid value */
              IF cur.trade_item_descriptor IS NOT NULL AND
               ((cur.trade_item_descriptor <> NVL(l_old_pack_item_type,'X') AND
                 cur.transaction_type = 'UPDATE') OR (cur.transaction_type = 'CREATE'))
              THEN

                 OPEN  c_pack_item_type (cp_pack_item_type  => cur.trade_item_descriptor);
                 FETCH c_pack_item_type INTO l_valid_pack_type;
                 CLOSE c_pack_item_type;

                 IF l_valid_pack_type <> 1 THEN
                    l_error_logged := INVPUOPI.mtl_log_interface_err (
                                             Cur.organization_id,
                                             P_User_Id,
                                             P_Login_Id,
                                             P_Prog_AppId,
                                             P_Prog_Id,
                                             P_Request_id,
                                             cur.transaction_id,
                                             l_error_msg,
                                             'TRADE_ITEM_DESCRIPTOR',
                                             'MTL_SYSTEM_ITEMS_INTERFACE',
                                             'INV_INVALID_PACK_TYPE',
                                             X_Err_Text);
                    l_error_status :=  1;
                 END IF;

                 IF cur.trade_item_descriptor = 'BASE_UNIT_OR_EACH' THEN
                    OPEN  c_base_uom(cp_primary_uom_code => cur.primary_uom_code);
                    FETCH c_base_uom INTO l_is_primary_uom_base;
                    CLOSE c_base_uom;
                    IF (l_is_primary_uom_base <> 'Y') THEN
                       FND_MESSAGE.Set_Name('EGO', 'EGO_GTID_CANNOT_BE_BASE');
                       FND_MESSAGE.Set_Token('ATTR_NAME', l_gtid_disp_name);
                       l_err_text := FND_MESSAGE.GET;
                       l_error_logged := INVPUOPI.mtl_log_interface_err (
                                             Cur.organization_id,
                                             P_User_Id,
                                             P_Login_Id,
                                             P_Prog_AppId,
                                             P_Prog_Id,
                                             P_Request_id,
                                             cur.transaction_id,
                                             l_err_text,
                                             'TRADE_ITEM_DESCRIPTOR',
                                             'MTL_SYSTEM_ITEMS_INTERFACE',
                                             'INV_IOI_ERR',
                                              X_Err_Text);
                       l_error_status :=  1;
                    END IF;
                 END IF;

                 IF (l_error_status <> 1 AND cur.transaction_type = 'UPDATE')
                 THEN
                 /* API call to resolve item in pack or not */
                    BOM_IMPLODER_PUB.IMPLODER_USEREXIT(
                             SEQUENCE_ID                => null,
                             ENG_MFG_FLAG               => 2,
                             ORG_ID                     => cur.organization_id,
                             IMPL_FLAG                  => 2,
                             DISPLAY_OPTION             => 1,
                             LEVELS_TO_IMPLODE          => 60,
                             OBJ_NAME                   => 'EGO_ITEM',
                             PK1_VALUE                  => cur.inventory_item_id,
                             PK2_VALUE                  => cur.organization_id,
                             PK3_VALUE                  => null,
                             PK4_VALUE                  => null,
                             PK5_VALUE                  => null,
                             IMPL_DATE                  => to_char(SYSDATE,'YYYY/MM/DD HH24:MI:SS') ,
                             UNIT_NUMBER_FROM           => 'N',
                             UNIT_NUMBER_TO             => 'Y',
                             ERR_MSG                    => x_err_text,
                             ERR_CODE                   => l_error_logged,
                             ORGANIZATION_OPTION        => 1,
                             ORGANIZATION_HIERARCHY     => null,
                             SERIAL_NUMBER_FROM         => null,
                             SERIAL_NUMBER_TO           => null,
                             STRUCT_NAME                => 'PIM_PBOM_S',
                             STRUCT_TYPE                => 'Packaging Hierarchy',
                             PREFERRED_ONLY             => 2 ,
                             USED_IN_STRUCTURE          => l_item_in_pack);

                    IF l_item_in_pack = FND_API.G_TRUE THEN
                       l_error_logged := INVPUOPI.mtl_log_interface_err (
                                              Cur.organization_id,
                                              P_User_Id,
                                              P_Login_Id,
                                              P_Prog_AppId,
                                              P_Prog_Id,
                                              P_Request_id,
                                              cur.transaction_id,
                                              l_error_msg,
                                              'TRADE_ITEM_DESCRIPTOR',
                                              'MTL_SYSTEM_ITEMS_INTERFACE',
                                              'INV_ITEM_IN_PACK',
                                               X_Err_Text);
                       l_error_status :=  1;
                    END IF;

                    IF l_error_status <> 1 THEN
                    /* For update of Trade Item Descriptor GDSN Post Processing is triggered */
                       EGO_GTIN_PVT.process_gtid_update ( p_inventory_item_id => cur.inventory_item_id
                                                         ,p_organization_id => cur.organization_id
                                                         ,p_trade_item_desc => cur.trade_item_descriptor
                                                         ,x_return_status => x_return_status
                                                         ,x_msg_count => x_msg_count
                                                         ,x_msg_data => x_msg_data);

                       IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                          l_error_logged := INVPUOPI.mtl_log_interface_err (
                                              Cur.organization_id,
                                              P_User_Id,
                                              P_Login_Id,
                                              P_Prog_AppId,
                                              P_Prog_Id,
                                              P_Request_id,
                                              cur.transaction_id,
                                              x_msg_data,
                                              'TRADE_ITEM_DESCRIPTOR',
                                              'MTL_SYSTEM_ITEMS_INTERFACE',
                                              'INV_IOI_ERR',
                                               X_Err_Text);
                         l_error_status :=  1;
                       END IF;
                    END IF;
                  END IF;
               END IF;
            END IF; --R12 C validations ONLY at the end

            IF l_error_status = 1 THEN
               --Set process flag since failed in LC validation
               UPDATE mtl_system_items_interface
               SET    process_flag = 3
               WHERE  rowid = cur.rowid;
            END IF;

         END LOOP; -- End of c_get_master_items

         FOR cur IN c_get_child_items LOOP

            l_error_status := 0;
            l_error_logged := 0;

            IF cur.lifecycle_id IS NOT NULL THEN
               BEGIN
                  Validate_Child_Items(
                      P_Org_Id           => cur.organization_id
                     ,P_Item_Id          => cur.inventory_item_id
                     ,P_Lifecycle_Id     => cur.lifecycle_id
                     ,P_Phase_Id         => cur.current_phase_id
                     ,P_Catalog_Group_Id => cur.item_catalog_group_id
                     ,P_Status_Code      => cur.inventory_item_status_code
                     ,P_Transaction_Type => cur.transaction_type
                     ,P_Rowid            => cur.rowid
                     ,X_Error_Column     => X_Error_Column
                     ,X_Error_Code       => X_Error_Code);
               EXCEPTION
                  WHEN LOGGING_ERR THEN
                     l_error_logged :=
                         INVPUOPI.mtl_log_interface_err(
                                cur.organization_id,
                                P_User_Id,
                                P_Login_Id,
                                P_Prog_AppId,
                                P_Prog_Id,
                                P_Request_id,
                                cur.transaction_id,
                                l_error_msg,
                                X_Error_Column,
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                 X_Error_Code,
                                 X_Err_Text);

                  IF l_error_logged < 0 THEN
                     Raise LOGGING_ERR;
                  END IF;
                  l_error_status := 1;
               END;
            ELSE
              --3457443 : lifecycle and phase validation during update also.
              --Life Cyle is null but phase has been provided
              IF cur.current_phase_id IS NOT NULL THEN
                 l_error_logged := INVPUOPI.mtl_log_interface_err(
                                cur.organization_id,
                                P_User_Id,
                                P_Login_Id,
                                P_Prog_AppId,
                                P_Prog_Id,
                                P_Request_id,
                                cur.transaction_id,
                                l_error_msg,
                                'CURRENT_PHASE_ID',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_LIFECYCLE_MANDATORY',
                                 X_Err_Text);

                 IF l_error_logged  < 0 THEN
                    Raise LOGGING_ERR;
                 END IF;
                 l_error_status := 1;
              END IF; --Phase id is not null
            END IF; -- Lifecycle is not null


            IF p_process_flag = 4 THEN --To prevent validations from firing during Change Policy Check
            /* Bug 5523228 - Added to calidate Unit wt and wt uom against Trade Item Descriptor */
              IF(l_error_status <> 1) THEN

                 OPEN  c_get_existing_item_details(cur.inventory_item_id, cur.organization_id);
                 FETCH c_get_existing_item_details INTO l_old_catalog_group_id,l_approval_status,
                                                        l_old_unit_weight, l_old_weight_uom_code,
                                                        l_old_pack_item_type,l_old_gdsn_flag;
                 CLOSE c_get_existing_item_details;

                 IF(  (((cur.unit_weight     IS NOT NULL) AND (NVL(cur.unit_weight,-1)     <> NVL(l_old_unit_weight,-1)))
                     OR((cur.weight_uom_code IS NOT NULL) AND (NVL(cur.weight_uom_code,-1) <> NVL(l_old_weight_uom_code,-1))))
                   AND cur.transaction_type = 'UPDATE'
                   AND cur.gdsn_outbound_enabled_flag = 'Y')
                 THEN
                     l_valid := EGO_GTIN_PVT.Validate_Unit_Wt_Uom(p_inventory_item_id => cur.inventory_item_id,
                                                                  p_org_id            => cur.organization_id );

                     IF (l_valid <> FND_API.G_TRUE) THEN
                        FND_MESSAGE.SET_NAME ( 'EGO', 'EGO_ATTR_NOT_EDITABLE');
                        FND_MESSAGE.SET_TOKEN ('ATTR_NAME', 'UNIT WEIGHT AND WEIGHT_UOM_CODE');
                        FND_MESSAGE.SET_TOKEN ('GTID', 'TRADE ITEM DESCRIPTOR');
                        l_error_msg := FND_MESSAGE.GET;

                        l_error_logged := INVPUOPI.mtl_log_interface_err(
                                  cur.organization_id,
                                  P_User_Id,
                                  P_Login_Id,
                                  P_Prog_AppId,
                                  P_Prog_Id,
                                  P_Request_id,
                                  cur.transaction_id,
                                  l_error_msg,
                                  'UNIT_WEIGHT',
                                  'MTL_SYSTEM_ITEMS_INTERFACE',
                                  'INV_IOI_ERR',
                                   X_Err_Text);

                        IF l_error_logged  < 0 THEN
                           Raise LOGGING_ERR;
                        END IF;
                        l_error_status := 1;
                     END IF;
                 END IF;
              END IF;

           /* Validating Style/SKU attributes for non-std items */
              IF cur.style_item_flag IS NOT NULL THEN

                 l_error_status := validate_style_sku ( p_row_id => cur.rowid,
                                                        p_xset_id => P_Set_id,
                                                        x_err_text => x_err_text);
                 IF l_error_status <> 0 THEN

                    UPDATE mtl_system_items_interface
                       SET process_flag = 3
                     WHERE rowid = cur.rowid;

                    l_error_logged := INVPUOPI.mtl_log_interface_err(
                                           cur.organization_id,
                                           P_User_Id,
                                           P_Login_Id,
                                           P_Prog_AppId,
                                           P_Prog_Id,
                                           P_Request_id,
                                           cur.transaction_id,
                                           SQLERRM,
                                          'STYLE_ITEM_FLAG',
                                          'MTL_SYSTEM_ITEMS_INTERFACE',
                                          'INV_IOI_ERR',
                                           x_err_text);
                    IF l_error_logged < 0 THEN
                       Raise LOGGING_ERR;
                    END IF;
                 END IF;
              END IF;

               /* Bug 5389029 - Adding a condition to chk for errors so far */
              IF ((cur.item_catalog_group_id IS NOT NULL) AND ( l_error_status <> 1) AND (cur.transaction_type = 'UPDATE')) THEN
                  /* Adding the ttype check and the NVL clause to the ICC change condition */
                IF (NVL(l_old_catalog_group_id,-1) <> NVL(cur.item_catalog_group_id,-1)) THEN
                 /* Bug 5389029 - Passing Int Table values for Lifecycle/Phase */
                    EGO_INV_ITEM_CATALOG_PVT.Change_Item_Catalog (
                      P_INVENTORY_ITEM_ID    => cur.inventory_item_id
                     ,P_ORGANIZATION_ID      => cur.organization_id
                     ,P_CATALOG_GROUP_ID     => l_old_catalog_group_id
                     ,P_NEW_CATALOG_GROUP_ID => cur.item_catalog_group_id
                     ,P_NEW_LIFECYCLE_ID     => cur.lifecycle_id
                     ,P_NEW_PHASE_ID         => cur.current_phase_id
                     ,P_NEW_ITEM_STATUS_CODE => cur.inventory_item_status_code
                     ,P_COMMIT               => FND_API.G_FALSE
                     ,X_RETURN_STATUS        => X_RETURN_STATUS
                     ,X_MSG_COUNT            => X_MSG_COUNT
                     ,X_MSG_DATA             => X_MSG_DATA );

                 /* Bug 5389029 - Passing the right arguments for clear error log */
                    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                       l_error_logged := INVPUOPI.mtl_log_interface_err(
                                           cur.organization_id,
                                           P_User_Id,
                                           P_Login_Id,
                                           P_Prog_AppId,
                                           P_Prog_Id,
                                           P_Request_id,
                                           cur.transaction_id,
                                           X_MSG_DATA,
                                           'ITEM_CATALOG_GROUP_ID',
                                           'MTL_SYSTEM_ITEMS_INTERFACE',
                                           'INV_IOI_ERR',
                                            X_ERR_TEXT);

                       IF l_error_logged < 0 THEN
                          Raise LOGGING_ERR;
                       END IF;
                       l_error_status := 1;
                    ELSE
                       --Bug: 5258295
                       l_return_status := INV_EGO_REVISION_VALIDATE.mtl_catalog_group_update (
                                                 p_rowid               => cur.rowid
                                                ,p_process_flag        => p_process_flag --Added for R12 C
                                                ,p_inventory_item_id   => cur.inventory_item_id
                                                ,p_organization_id     => cur.organization_id
                                                ,p_old_item_cat_grp_id => l_old_catalog_group_id
                                                ,p_new_item_cat_grp_id => cur.item_catalog_group_id
                                                ,p_approval_status     => l_approval_status
                                                ,p_item_number         => cur.item_number
                                                ,p_transaction_id      => cur.transaction_id
                                                ,p_prog_appid          => p_prog_appid
                                                ,p_prog_id             => p_prog_id
                                                ,p_request_id          => p_request_id
                                                ,p_xset_id             => P_Set_Id --Added for R12 C
                                                ,p_user_id             => p_user_id
                                                ,p_login_id            => p_login_id
                                                ,x_err_text            => x_err_text);

                       IF l_return_status <> 0 THEN
                          l_error_logged := INVPUOPI.mtl_log_interface_err(
                                           cur.organization_id,
                                           P_User_Id,
                                           P_Login_Id,
                                           P_Prog_AppId,
                                           P_Prog_Id,
                                           P_Request_id,
                                           cur.transaction_id,
                                           l_error_msg,
                                           'ITEM_CATALOG_GROUP_ID',
                                           'MTL_SYSTEM_ITEMS_INTERFACE',
                                            x_err_text,
                                            x_err_text);

                          IF l_error_logged < 0 THEN
                            Raise LOGGING_ERR;
                          END IF;
                          l_error_status := 1;
                       END IF;
                    END IF;
                END IF;
              END IF;

               /* Pack Item Type Validations */
              IF ((cur.gdsn_outbound_enabled_flag IS NULL OR cur.gdsn_outbound_enabled_flag = 'N')
                 AND(l_old_gdsn_flag = 'Y')) THEN
                   l_error_logged := INVPUOPI.mtl_log_interface_err (
                                            Cur.organization_id,
                                            P_User_Id,
                                            P_Login_Id,
                                            P_Prog_AppId,
                                            P_Prog_Id,
                                            P_Request_id,
                                            cur.transaction_id,
                                            l_error_msg,
                                            'GDSN_OUTBOUND_ENABLED_FLAG',
                                            'MTL_SYSTEM_ITEMS_INTERFACE',
                                            'INV_GDSN_UPD_NO_INVALID',
                                            X_Err_Text);
                  l_error_status :=  1;
              END IF;

           /* Section 2.5.2 Condition 2 Pack item type should be a valid value */
              IF ( cur.trade_item_descriptor IS NOT NULL AND
                   ( ( cur.trade_item_descriptor <> NVL(l_old_pack_item_type,'X') AND
                       cur.transaction_type = 'UPDATE')
                    OR cur.transaction_type = 'CREATE'  ) )
              THEN
                OPEN c_pack_item_type (cp_pack_item_type  => cur.trade_item_descriptor);
                FETCH c_pack_item_type INTO l_valid_pack_type;
                CLOSE c_pack_item_type;

                IF l_valid_pack_type <> 1 THEN
                   l_error_logged := INVPUOPI.mtl_log_interface_err (
                                            Cur.organization_id,
                                            P_User_Id,
                                            P_Login_Id,
                                            P_Prog_AppId,
                                            P_Prog_Id,
                                            P_Request_id,
                                            cur.transaction_id,
                                            l_error_msg,
                                            'TRADE_ITEM_DESCRIPTOR',
                                            'MTL_SYSTEM_ITEMS_INTERFACE',
                                            'INV_INVALID_PACK_TYPE',
                                            X_Err_Text);
                  l_error_status :=  1;
                END IF;

                IF cur.trade_item_descriptor = 'BASE_UNIT_OR_EACH' THEN
                   OPEN  c_base_uom(cp_primary_uom_code => cur.primary_uom_code);
                   FETCH c_base_uom INTO l_is_primary_uom_base;
                   CLOSE c_base_uom;

                   IF (l_is_primary_uom_base <> 'Y') THEN
                      FND_MESSAGE.Set_Name('EGO', 'EGO_GTID_CANNOT_BE_BASE');
                      FND_MESSAGE.Set_Token('ATTR_NAME', l_gtid_disp_name);
                      l_err_text := FND_MESSAGE.GET;
                      l_error_logged := INVPUOPI.mtl_log_interface_err (
                                              Cur.organization_id,
                                              P_User_Id,
                                              P_Login_Id,
                                              P_Prog_AppId,
                                              P_Prog_Id,
                                              P_Request_id,
                                              cur.transaction_id,
                                              l_err_text,
                                              'TRADE_ITEM_DESCRIPTOR',
                                              'MTL_SYSTEM_ITEMS_INTERFACE',
                                              'INV_IOI_ERR',
                                               X_Err_Text);
                      l_error_status :=  1;
                   END IF;
                END IF;

                IF (l_error_status <> 1 AND cur.transaction_type = 'UPDATE')
                THEN
                /* API call to resolve item in pack or not */
                   BOM_IMPLODER_PUB.IMPLODER_USEREXIT(
                            SEQUENCE_ID                => null,
                            ENG_MFG_FLAG               => 2,
                            ORG_ID                     => cur.organization_id,
                            IMPL_FLAG                  => 2,
                            DISPLAY_OPTION             => 1,
                            LEVELS_TO_IMPLODE          => 60,
                            OBJ_NAME                   => 'EGO_ITEM',
                            PK1_VALUE                  => cur.inventory_item_id,
                            PK2_VALUE                  => cur.organization_id,
                            PK3_VALUE                  => null,
                            PK4_VALUE                  => null,
                            PK5_VALUE                  => null,
                            IMPL_DATE                  => to_char(SYSDATE,'YYYY/MM/DD HH24:MI:SS') ,
                            UNIT_NUMBER_FROM           => 'N',
                            UNIT_NUMBER_TO             => 'Y',
                            ERR_MSG                    => x_err_text,
                            ERR_CODE                   => l_error_logged,
                            ORGANIZATION_OPTION        => 1,
                            ORGANIZATION_HIERARCHY     => null,
                            SERIAL_NUMBER_FROM         => null,
                            SERIAL_NUMBER_TO           => null,
                            STRUCT_TYPE                => 'Packaging Hierarchy',
                            PREFERRED_ONLY             => 2 ,
                            USED_IN_STRUCTURE          => l_item_in_pack);

                  IF l_item_in_pack = FND_API.G_TRUE THEN
                     l_error_logged := INVPUOPI.mtl_log_interface_err (
                                            Cur.organization_id,
                                            P_User_Id,
                                            P_Login_Id,
                                            P_Prog_AppId,
                                            P_Prog_Id,
                                            P_Request_id,
                                            cur.transaction_id,
                                            l_error_msg,
                                            'TRADE_ITEM_DESCRIPTOR',
                                            'MTL_SYSTEM_ITEMS_INTERFACE',
                                            'INV_ITEM_IN_PACK',
                                             X_Err_Text);
                     l_error_status :=  1;
                  END IF;

                  IF l_error_status <> 1 THEN
                  /* For update of Trade Item Descriptor GDSN Post Processing is triggered */
                     EGO_GTIN_PVT.process_gtid_update ( p_inventory_item_id => cur.inventory_item_id
                                                       ,p_organization_id => cur.organization_id
                                                       ,p_trade_item_desc => cur.trade_item_descriptor
                                                       ,x_return_status => x_return_status
                                                       ,x_msg_count => x_msg_count
                                                       ,x_msg_data => x_msg_data);

                     IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                        l_error_logged := INVPUOPI.mtl_log_interface_err (
                                            Cur.organization_id,
                                            P_User_Id,
                                            P_Login_Id,
                                            P_Prog_AppId,
                                            P_Prog_Id,
                                            P_Request_id,
                                            cur.transaction_id,
                                            x_msg_data,
                                            'TRADE_ITEM_DESCRIPTOR',
                                            'MTL_SYSTEM_ITEMS_INTERFACE',
                                            'INV_IOI_ERR',
                                             X_Err_Text);
                       l_error_status :=  1;
                     END IF;
                   END IF;
                END IF;
              END IF;
            END IF; --process flag 4

            IF l_error_status = 1 THEN
               --Set process flag since failed in LC validation
               UPDATE mtl_system_items_interface
               SET    process_flag = 3
               WHERE  rowid = cur.rowid;
            END IF;

         END LOOP; -- End of c_get_child_items

        END IF;
        --Support of user attributes through template
        INV_EGO_REVISION_VALIDATE.Insert_Grants_And_UserAttr(P_Set_id);

      END IF; --Ego exists

     RETURN (0);

   EXCEPTION
     WHEN LOGGING_ERR then
         RETURN(l_error_logged);
       WHEN OTHERS THEN
         X_Err_Text := SUBSTR('INV_EGO_REVISION_VALIDATE.validate_revision_lifecycle' || SQLERRM , 1,240);
         RETURN (SQLCODE);
   END validate_items_lifecycle;
   --End   2777118:Item Lifecycle and Phase validations

   --Start : Check for data security and user priv.
   FUNCTION check_data_security(
          P_Function            IN VARCHAR2
         ,P_Object_Name         IN VARCHAR2
         ,P_Instance_PK1_Value  IN VARCHAR2
         ,P_Instance_PK2_Value  IN VARCHAR2 DEFAULT NULL
         ,P_Instance_PK3_Value  IN VARCHAR2 DEFAULT NULL
         ,P_Instance_PK4_Value  IN VARCHAR2 DEFAULT NULL
         ,P_Instance_PK5_Value  IN VARCHAR2 DEFAULT NULL
         ,P_User_Id             IN NUMBER)
   RETURN VARCHAR2 IS

      --4932512 : Replacing ego_people with ego_user
      CURSOR c_get_party_id(cp_user_id NUMBER) IS
         SELECT TO_CHAR(party_id)
         FROM   ego_user_v
         WHERE  user_id = cp_user_id;

      l_has_privilege VARCHAR2(1) := 'T';
      l_party_name    fnd_grants.grantee_key%TYPE;
      l_user_id       fnd_user.user_id%TYPE := P_User_Id;

   BEGIN

      IF INV_EGO_REVISION_VALIDATE.Get_Process_Control ='EGO_ITEM_BULKLOAD' THEN

         IF l_user_id IS NULL OR l_user_id = -1 THEN
            l_user_id := FND_GLOBAL.user_id;
         END IF;

         OPEN   c_get_party_id(l_user_id);
         FETCH  c_get_party_id INTO l_party_name;
         CLOSE  c_get_party_id;

         l_party_name := 'HZ_PARTY:'||l_party_name;

         l_has_privilege := EGO_DATA_SECURITY.check_function(
                             p_api_version        => 1.0
                            ,p_function           => P_Function
                            ,p_object_name        => P_Object_Name
                            ,p_instance_pk1_value => P_Instance_PK1_Value
                            ,p_instance_pk2_value => P_Instance_PK2_Value
                            ,p_instance_pk3_value => P_Instance_PK3_Value
                            ,p_instance_pk4_value => P_Instance_PK4_Value
                            ,p_instance_pk5_value => P_Instance_PK5_Value
                            ,p_user_name          => l_party_name);

         l_has_privilege := NVL(l_has_privilege,'F');

      END IF;

      RETURN(l_has_privilege);

   EXCEPTION
      WHEN OTHERS THEN
         l_has_privilege := 'F';
         IF c_get_party_id%ISOPEN THEN
            CLOSE c_get_party_id;
         END IF;
         RETURN(l_has_privilege);
   END check_data_security;

/* Bug: 5238510
   Added process flag parameter with a default value of 2
   If the caller wants to pick rows other than thie process
   flag value they can pass that value explicitly. The behavior
   remains the same otherwise.
*/
   FUNCTION validate_item_user_privileges(
         P_Org_Id       IN            NUMBER
        ,P_All_Org      IN            NUMBER  DEFAULT  2
        ,P_Prog_AppId   IN            NUMBER  DEFAULT -1
        ,P_Prog_Id      IN            NUMBER  DEFAULT -1
        ,P_Request_Id   IN            NUMBER  DEFAULT -1
        ,P_User_Id      IN            NUMBER  DEFAULT -1
        ,P_Login_Id     IN            NUMBER  DEFAULT -1
        ,P_Set_id       IN            NUMBER  DEFAULT -999
        ,X_Err_Text     IN OUT        NOCOPY  VARCHAR2
        ,P_Process_flag IN            NUMBER  DEFAULT 2 )
   RETURN INTEGER IS

      CURSOR c_get_items IS
         SELECT msii.rowid,
                msii.organization_id,
                msii.inventory_item_id,
                msii.item_catalog_group_Id,
                msii.inventory_item_status_code,
                msii.lifecycle_id,
                msii.current_phase_id,
                msii.transaction_id,
                msii.transaction_type,
                msii.item_number,   --5522789
                mp.master_organization_id,
		msii.created_by
         FROM   mtl_system_items_interface msii,
                mtl_parameters mp
         WHERE  (msii.organization_id = P_Org_Id OR P_All_Org = 1)
         AND    msii.set_process_id = P_Set_id
         AND    msii.process_flag = P_Process_flag
         AND    msii.organization_id = mp.organization_id--Bug 5238510
      FOR UPDATE OF process_flag;

      CURSOR c_get_item_rec(cp_org_id  NUMBER
                           ,cp_item_id NUMBER)
      IS
         SELECT item_catalog_group_id, approval_status,
                inventory_item_status_code,lifecycle_id,
                current_phase_id
         FROM   mtl_system_items_b
         WHERE  organization_id   = cp_org_id
         AND    inventory_item_id = cp_item_id;

      l_has_privilege VARCHAR2(1) := 'F';
      l_log_error     BOOLEAN     := FALSE;
      l_error_status  NUMBER      := 0;
      l_error_logged  NUMBER      := 0;
      l_error_msg     VARCHAR2(70);
      l_error_column  VARCHAR2(50);
      l_error_code    VARCHAR2(70);
      l_err_text      VARCHAR2(240);
      l_item_catalog  NUMBER      := 0;
      l_has_access    VARCHAR2(1):= 'F';
      l_approval_status mtl_system_items_b.approval_status%TYPE;
      l_inventory_item_status_code mtl_system_items_b.inventory_item_status_code%TYPE;
      l_lifecycle_id mtl_system_items.lifecycle_id%TYPE;
      l_current_phase_id mtl_system_items.current_phase_id%TYPE;
      l_inv_debug_level             NUMBER := INVPUTLI.get_debug_level;
   BEGIN

      IF INV_EGO_REVISION_VALIDATE.Get_Process_Control ='EGO_ITEM_BULKLOAD' THEN

         FOR cur in c_get_items LOOP

            l_has_privilege := 'F';
            l_log_error     := FALSE;
            l_has_access := 'F';

            IF cur.transaction_type ='CREATE' THEN

               -- Bug 6126225: Do not check User ICC privilege for Item Organization Assignment
               IF (cur.item_catalog_group_Id IS NOT NULL AND cur.master_organization_id = cur.organization_id)
               THEN
                  l_has_privilege := check_data_security(
                                     p_function           => 'EGO_CREATE_ITEM_OF_GROUP'
                                    ,p_object_name        => 'EGO_CATALOG_GROUP'
                                    ,p_instance_pk1_value => cur.item_catalog_group_Id
                                    ,P_User_Id            => P_User_Id);
                  IF l_has_privilege <> 'T' THEN
                     l_log_error    := TRUE;
                     l_error_column := 'ITEM_CATALOG_GROUP_ID';
                     l_error_code   := 'INV_IOI_NOT_CATALOG_USER';
                  END IF;
               END IF;

               IF cur.master_organization_id <> cur.organization_id THEN
                  --Start 3342860: Check for EGO_EDIT_ITEM for org-item assignment.
                  --3429418 should check for EGO_EDIT_ITEM_ORG_ASSIGN instead of EGO_EDIT_ITEM.
                  --Item-Org assignment not allowed for unapproved items.
                  OPEN  c_get_item_rec(cur.master_organization_id, cur.inventory_item_id);
                  FETCH c_get_item_rec INTO l_item_catalog, l_approval_status,
                                            l_inventory_item_status_code,l_lifecycle_id,
                                            l_current_phase_id;
                  CLOSE c_get_item_rec;

	               l_has_access := Check_Org_Access(
                                     p_org_id  => cur.organization_id);
                  IF l_has_access <> 'T' THEN
                        l_log_error    := TRUE;
                        l_error_column := 'INVENTORY_ITEM_ID';
                        l_error_code   := 'INV_IOI_ITEM_ORGAS_ACCESS_PRIV';
                  END IF;

                  IF ( cur.created_by <> -99 ) THEN
                     l_has_privilege := check_data_security(
                                     p_function           => 'EGO_EDIT_ITEM_ORG_ASSIGN'
                                    ,p_object_name        => 'EGO_ITEM'
                                    ,p_instance_pk1_value => cur.inventory_item_id
                                    ,p_instance_pk2_value => cur.master_organization_id
                                    ,P_User_Id            => P_User_Id);
                     IF l_has_privilege <> 'T' THEN
                           l_log_error    := TRUE;
                           l_error_column := 'INVENTORY_ITEM_ID';
                           l_error_code   := 'INV_IOI_ITEM_ORGASSIGN_PRIV';
                     END IF;
                  ELSE
                     IF l_inv_debug_level IN(101, 102) THEN
                        INVPUTLI.info('INVEGRVB.Secutiry skip for:' || cur.Inventory_Item_ID || '-' || cur.organization_id);
                     END IF;
                  END IF;

                  IF NOT l_log_error AND NVL(l_approval_status,'A') <> 'A' THEN
                        l_log_error    := TRUE;
                        l_error_column := 'INVENTORY_ITEM_ID';
                        l_error_code   := 'INV_IOI_UNAPPROVED_ITEM_ORG';
                  END IF;

               END IF;
               --End 3342860: Check for EGO_EDIT_ITEM for org-item assignment.

            ELSIF cur.transaction_type ='UPDATE'  THEN
               IF ( cur.created_by <> -99 ) THEN
                  l_has_privilege := check_data_security(
                                     p_function           => 'EGO_EDIT_ITEM'
                                    ,p_object_name        => 'EGO_ITEM'
                                    ,p_instance_pk1_value => cur.inventory_item_id
                                    ,p_instance_pk2_value => cur.organization_id
                                    ,P_User_Id            => P_User_Id);

                  IF l_has_privilege <> 'T' THEN
                     l_log_error    := TRUE;
                     l_error_column := 'INVENTORY_ITEM_ID';
                     -- 5522789
                     -- l_error_code   := 'INV_IOI_ITEM_UPDATE_PRIV';
                     FND_MESSAGE.SET_NAME ( 'INV', 'INV_IOI_ITEM_UPDATE_PRIV');
                     FND_MESSAGE.SET_TOKEN ('VALUE', cur.item_number);
                     l_error_msg := FND_MESSAGE.GET;
                     l_error_code   := 'INV_IOI_ERR';
                  END IF;
               ELSE
                     IF l_inv_debug_level IN(101, 102) THEN
                        INVPUTLI.info('INVEGRVB.Secutiry skip for:' || cur.Inventory_Item_ID || '-' || cur.organization_id);
                     END IF;
	       END IF;

               IF NOT l_log_error THEN
                   OPEN  c_get_item_rec(cp_org_id  => cur.organization_id
                                       ,cp_item_id => cur.inventory_item_id);
                   FETCH c_get_item_rec INTO l_item_catalog, l_approval_status,
                                             l_inventory_item_status_code,l_lifecycle_id,
                                             l_current_phase_id;
                   CLOSE c_get_item_rec;

                   --Bug: 5079137 Check EGO_EDIT_ITEM_STATUS_PRIVILEGE for update of Status,ICC,Lifecycle and Phase
                   IF ( NVL(cur.item_catalog_group_id,0) <> NVL(l_item_catalog,0) OR
                        cur.inventory_item_status_code   <> l_inventory_item_status_code OR
                        NVL(cur.lifecycle_id,0)          <> NVL(l_lifecycle_id,0) OR
                        NVL(cur.current_phase_id,0)      <> NVL(l_current_phase_id,0) ) THEN

                       l_has_privilege := check_data_security(
                                          p_function           => 'EGO_EDIT_ITEM_STATUS'
                                         ,p_object_name        => 'EGO_ITEM'
                                         ,p_instance_pk1_value => cur.inventory_item_id
                                         ,p_instance_pk2_value => cur.organization_id
                                         ,P_User_Id            => P_User_Id);

                       IF l_has_privilege <> 'T' THEN
                          l_log_error    := TRUE;
                          l_error_column := 'INVENTORY_ITEM_ID';
                          l_error_code   := 'INV_IOI_STATUS_UPDATE_PRIV';
                       END IF;
                    END IF;
                END IF;

               --Start : Catalog update changes
               IF NOT l_log_error THEN

                  /*Bug: 5258295
                  --Bug:3491746  Added catalog group validation PLM
                  IF NVL(l_approval_status,'A') <> 'A' AND NVL(l_item_catalog,-1) <> NVL(cur.item_catalog_group_Id,-1) THEN
                        l_log_error    := TRUE;
                        l_error_column := 'ITEM_CATALOG_GROUP_ID';
                        l_error_code   := 'INV_IOI_UNAPPROVED_ITEM_CTLG';
                  --Bug:3491746  Added catalog group validation PLM
                  */
                  IF NVL(l_item_catalog,-1) <> cur.item_catalog_group_Id AND cur.item_catalog_group_Id IS NOT NULL THEN
                     l_has_privilege := check_data_security(
                                          p_function           => 'EGO_CREATE_ITEM_OF_GROUP'
                                         ,p_object_name        => 'EGO_CATALOG_GROUP'
                                         ,p_instance_pk1_value => cur.item_catalog_group_Id
                                         ,P_User_Id            => P_User_Id);
                     IF l_has_privilege <> 'T' THEN
                        l_log_error    := TRUE;
                        l_error_column := 'ITEM_CATALOG_GROUP_ID';
                        l_error_code   := 'INV_IOI_NOT_CATALOG_USER';
                     END IF;
                  END IF;
               END IF;
               --End : Catalog update changes
               --Uncommented for 5260528
               --Bug:3491746  Added catalog group validation PLM
               IF NOT l_log_error THEN
               --Bug: 4020501 Claused the call to INVIDIT3.Is_Catalog_Group_Valid
                  IF cur.item_catalog_group_id IS NOT NULL
                                      AND NVL(l_item_catalog,0) <> cur.item_catalog_group_id THEN
                     l_error_msg := INVIDIT3.Is_Catalog_Group_Valid(
                               old_catalog_group_id  => l_item_catalog,
                               new_catalog_group_id  => cur.item_catalog_group_id,
                               item_id               => cur.inventory_item_id);
                     IF l_error_msg IS NOT NULL THEN
                        l_log_error := TRUE;
                        l_error_column := 'ITEM_CATALOG_GROUP_ID';
                        l_error_code   := l_error_msg;
                     END IF;
                  END IF;
               END IF;
            --Bug:3491746  Added catalog group validation PLM Ended
            END IF;

            IF l_log_error THEN
               l_error_logged := INVPUOPI.mtl_log_interface_err(
                                     cur.organization_id,
                                     P_User_Id,
                                     P_Login_Id,
                                     P_Prog_AppId,
                                     P_Prog_Id,
                                     P_Request_id,
                                     cur.transaction_id,
                                     l_error_msg,
                                     l_error_column,
                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                     l_error_code,
                                     l_err_text);
               IF l_error_logged < 0 THEN
                  Raise LOGGING_ERR;
               END IF;

               UPDATE mtl_system_items_interface
               SET    process_flag = 3
               WHERE  rowid = cur.rowid;

            END IF;

         END LOOP;

      END IF; -- IF security_enabled

      RETURN (0);

   EXCEPTION
     WHEN LOGGING_ERR then
         RETURN(l_error_logged);
       WHEN OTHERS THEN
         X_Err_Text := SUBSTR('INV_EGO_REVISION_VALIDATE.validate_revision_lifecycle' || SQLERRM , 1,240);
         RETURN (SQLCODE);
   END validate_item_user_privileges;
   --End : Check for data security and user priv.

--  ============================================================================
--  API Name:           Insert_Grants_And_UserAttr
--
--        IN:           P_Set_id
--                      Bug: 3033702 Moved this code from INVPPROB.pls
--  ============================================================================
  PROCEDURE Insert_Grants_And_UserAttr (P_Set_id IN NUMBER) IS

    CURSOR c_get_processed_records (cp_set_process_id NUMBER) IS
      SELECT interface.inventory_item_id,
             interface.item_catalog_group_id,
             interface.organization_id,
             interface.template_id,
             interface.transaction_id,
             interface.transaction_type,
             interface.rowid
      FROM   mtl_system_items_interface interface
      WHERE  interface.set_process_id = cp_set_process_id
      AND    interface.process_flag   = 4
      AND    interface.transaction_type = 'CREATE'
      --4676088AND    interface.transaction_type IN ('CREATE','UPDATE')
      FOR UPDATE OF process_flag;

   --4676088
   /*
   CURSOR c_parent_catalogs(cp_catalog_group_id NUMBER) IS
      SELECT ITEM_CATALOG_GROUP_ID
            ,PARENT_CATALOG_GROUP_ID
      FROM MTL_ITEM_CATALOG_GROUPS_B
      CONNECT BY PRIOR PARENT_CATALOG_GROUP_ID = ITEM_CATALOG_GROUP_ID
      START WITH ITEM_CATALOG_GROUP_ID         = cp_catalog_group_id;
    */

    l_party_id   EGO_PEOPLE_V.PERSON_ID%TYPE;
    l_grant_guid fnd_grants.grant_guid%TYPE;
    l_error_code                  NUMBER;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(2000);
    l_err_text                    VARCHAR2(240);
    l_error_logged                NUMBER        := 0;
    l_parent_catalog              VARCHAR2(150):= NULL;
    --4676088
    --l_pk_column_name_value_pairs  EGO_COL_NAME_VALUE_PAIR_ARRAY;
    --l_class_code_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;

    l_inv_debug_level             NUMBER := INVPUTLI.get_debug_level;  --Bug: 4667452

	    /*  vggarg bug 9039870 added to check for duplicate item roles when Item is created with NIR */
	  CURSOR c_get_overlap_grantid
	            (cp_inv_item_id            IN  NUMBER
	            ,cp_organization_id        IN  NUMBER
	            ,cp_menu_name              IN  VARCHAR2
		    ,cp_object_name            IN  VARCHAR2
		    ,cp_user_party_id_char     IN  VARCHAR2
		    ,cp_group_party_id_char    IN  VARCHAR2
		    ,cp_company_party_id_char  IN  VARCHAR2
		    ,cp_global_party_id_char   IN  VARCHAR2
		    ,cp_start_date             IN  DATE
		    ,cp_end_date               IN  DATE
		    ) IS
	    SELECT  grant_guid
	    FROM    fnd_grants grants,fnd_menus menus, fnd_objects objects
	    WHERE   grants.object_id          = objects.object_id
	      AND   grants.menu_id            = menus.menu_id
	      AND   objects.obj_name          = cp_object_name
	      AND   menus.menu_name           = cp_menu_name
	      AND   grants.instance_type      = 'INSTANCE'
	      AND   grants.instance_pk1_value = TO_CHAR(cp_inv_item_id)
	      AND   grants.instance_pk2_value = TO_CHAR(cp_organization_id)
	      AND   ((grants.grantee_type =  'USER'    AND grants.grantee_key =  cp_user_party_id_char ) OR
	             (grants.grantee_type =  'GROUP'   AND grants.grantee_key =  cp_group_party_id_char) OR
	             (grants.grantee_type =  'COMPANY' AND grants.grantee_key =  cp_company_party_id_char) OR
		     (grants.grantee_type =  'GLOBAL'  AND grants.grantee_key =  cp_global_party_id_char)
		    )
	      AND   start_date <= NVL(cp_end_date, start_date)
	      AND   NVL(end_date,cp_start_date) >= cp_start_date;

	/*  vggarg bug 9039870 end added to check for duplicate item roles when Item is created with NIR */


  BEGIN

     -- For Internal Users , Customer_Id may not getting populated in FND_USER
     -- Hence checking USER_ID from ego_people_v which always return all registered
     -- Users (Customer, Internal and Vendor)
     -- Bug Fix : 3048453
     -- Calling bulk seeding procedure
     EGO_ITEM_PUB.Seed_Item_Long_Desc_In_Bulk(
        p_set_process_id  => P_Set_id
       ,x_return_status   => l_return_status
       ,x_msg_data        => l_msg_data
     );

     --4932512 : Replacing ego_people with ego_user
     SELECT party_id INTO l_party_id
     FROM EGO_USER_V
     WHERE USER_ID = FND_GLOBAL.User_ID;

     FOR cur in c_get_processed_records(P_Set_id) LOOP
        IF cur.transaction_type ='CREATE' THEN
           IF l_inv_debug_level IN(101, 102) THEN
                INVPUTLI.info('INVEGRVB.Insert_Grants_And_UserAttr: inserting i grants for an Item'||cur.Inventory_Item_ID);
           END IF;
            /*  vggarg bug 9039870 added to check for duplicate item roles when Item is created with NIR */
  					OPEN c_get_overlap_grantid
  					       (cp_inv_item_id            => cur.Inventory_Item_ID
  					       ,cp_organization_id        => cur.Organization_ID
  					       ,cp_menu_name              => 'EGO_ITEM_OWNER'
  					       ,cp_object_name            => 'EGO_ITEM'
  					       ,cp_user_party_id_char     => 'HZ_PARTY:'||TO_CHAR(l_party_id)
  					       ,cp_group_party_id_char    => 'HZ_PARTY:'||TO_CHAR(l_party_id)
  					       ,cp_company_party_id_char  => 'HZ_PARTY:'||TO_CHAR(l_party_id)
  					       ,cp_global_party_id_char   => 'HZ_PARTY:'||TO_CHAR(l_party_id)
  					       ,cp_start_date             => SYSDATE
  					       ,cp_end_date               => NULL);

  					FETCH c_get_overlap_grantid INTO l_grant_guid;
  					IF c_get_overlap_grantid%NOTFOUND THEN
  				/*  vggarg bug 9039870 end added to check for duplicate item roles when Item is created with NIR */

           FND_GRANTS_PKG.GRANT_FUNCTION(
                 P_API_VERSION        => 1.0
                ,P_MENU_NAME          => 'EGO_ITEM_OWNER'
                ,P_OBJECT_NAME        => 'EGO_ITEM'
                ,P_INSTANCE_TYPE      => 'INSTANCE'
                ,P_INSTANCE_PK1_VALUE => cur.Inventory_Item_ID
                ,P_INSTANCE_PK2_VALUE => cur.Organization_ID
                ,P_GRANTEE_KEY        => 'HZ_PARTY:'||TO_CHAR(l_party_id)
                ,P_START_DATE         => SYSDATE
                ,P_END_DATE           => NULL
                ,X_GRANT_GUID         => l_grant_Guid
                ,X_SUCCESS            => l_return_status
                ,X_ERRORCODE          => l_msg_count);

           IF l_inv_debug_level IN(101, 102) THEN
                INVPUTLI.info('INVEGRVB.Insert_Grants_And_UserAttr: inserting Long description Userdefined Attribute.');
           END IF;
           /*  vggarg bug 9039870 start added to check for duplicate item roles when Item is created with NIR */
           END IF;
           /*  vggarg bug 9039870 end added to check for duplicate item roles when Item is created with NIR */
		   CLOSE c_get_overlap_grantid; --close cursor, for bug 9780818
        END IF;

        /* Start:4676088: Template - User defined attributes will done through EGO_ITEM_USER_ATTRS_CP_PUB
        --Start : Support of user attributes through template.
        IF  cur.template_id IS NOT NULL
           AND cur.template_id <> -1
           AND cur.item_catalog_group_id IS NOT NULL THEN

           -- As documented in EGOCIUAB.pls
           -- We build a list of all parent catalog groups, as long as the  --
           -- list is less than 151 characters long (the longest we can fit --
           -- into the EGO_COL_NAME_VALUE_PAIR_OBJ is 150 chars); if the    --
           -- list is too long to fully copy, we can only hope that the     --
           -- portion we copied will contain all the information we need.   --

           l_parent_catalog := NULL;

           BEGIN
              FOR parent_cur IN c_parent_catalogs(cur.item_catalog_group_id) LOOP
                 IF parent_cur.parent_catalog_group_id IS NOT NULL THEN
                    IF l_parent_catalog IS NULL THEN
                       l_parent_catalog := parent_cur.parent_catalog_group_id;
                    ELSE
                       l_parent_catalog := l_parent_catalog||','||parent_cur.parent_catalog_group_id;
                    END IF;
                 END IF;
              END LOOP;
           EXCEPTION
              --Only exception which will occur is when concatenated parent_catalog_groups_id
              --lenght exceeds 150,which is max VALUE_PAIR_OBJ can hold. This is good enough
              --for the program, nothing needs to be done in the exception, let things proceed.
              WHEN OTHERS THEN
                 NULL;
           END;

           IF l_inv_debug_level IN(101, 102) THEN
              INVPUTLI.info('EGO_USER_ATTRS_DATA_PVT.Perform_DML_From_Template: Attaching user defined attribs through template');
           END IF;
           l_pk_column_name_value_pairs  := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                            EGO_COL_NAME_VALUE_PAIR_OBJ('INVENTORY_ITEM_ID',cur.INVENTORY_ITEM_ID)
                                           ,EGO_COL_NAME_VALUE_PAIR_OBJ('ORGANIZATION_ID',cur.ORGANIZATION_ID));
           l_class_code_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                            EGO_COL_NAME_VALUE_PAIR_OBJ('ITEM_CATALOG_GROUP_ID', cur.ITEM_CATALOG_GROUP_ID)
                                           ,EGO_COL_NAME_VALUE_PAIR_OBJ('RELATED_CLASS_CODE_LIST_1',l_parent_catalog));
           -- achampan, bug 3781216: new API for applying template user attrs
           EGO_ITEM_PUB.Apply_Templ_User_Attrs_To_Item
             (p_api_version                   => 1.0
             ,p_mode                          => cur.transaction_type
             ,p_item_id                       => cur.inventory_item_id
             ,p_organization_id               => cur.organization_id
             ,p_template_id                   => ABS(cur.template_id)
             ,p_object_name                   => 'EGO_ITEM'
             ,p_class_code_name_value_pairs   => l_class_code_name_value_pairs
             ,x_return_status                 => l_return_status
             ,x_errorcode                     => l_error_code
             ,x_msg_count                     => l_msg_count
             ,x_msg_data                      => l_msg_data);

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

               UPDATE mtl_system_items_interface
               SET    process_flag = 3
               WHERE  rowid        = cur.rowid;
               l_error_logged := INVPUOPI.mtl_log_interface_err(
                                     cur.organization_id,
                                     FND_GLOBAL.USER_ID,
                                     FND_GLOBAL.LOGIN_ID,
                                     FND_GLOBAL.PROG_APPL_ID,
                                     FND_GLOBAL.CONC_PROGRAM_ID,
                                     FND_GLOBAL.CONC_REQUEST_ID,
                                     cur.transaction_id,
                                     l_msg_data,
                                     'TEMPLATE_ID',
                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                     'INV_IOI_ERR',
                                     l_err_text);
              IF l_error_logged < 0 THEN
                  Raise LOGGING_ERR;
              END IF;
           END IF;

        END IF;
        END 4676088: Template - User defined attributes will done through EGO_ITEM_USER_ATTRS_CP_PUB
        --End : Support of user attributes through template.*/

     END LOOP  ;
  EXCEPTION
  --Bug: 3155733: Added exception
  --Bug: 3685994: Added when no_data_found exception - Anmurali
     WHEN no_data_found THEN
        --4759137 : Grants error not be logged for through INV_ITEM_GRP or INV IOI
        IF (INSTR(NVL(G_PROCESS_CONTROL,'PLM_UI:N'),'PLM_UI:Y')   <> 0 ) OR
           (INSTR(NVL(G_PROCESS_CONTROL,'PLM_UI:N'),'ENG_CALL:Y') <> 0 )
        THEN
           FND_MESSAGE.SET_NAME ( 'INV', 'INV_INVALID_USER');
                FND_MESSAGE.SET_TOKEN ('USER_ID', FND_GLOBAL.User_Id);
           l_msg_data := FND_MESSAGE.GET;
           For exc IN c_get_processed_records (P_Set_Id)
                LOOP
                   UPDATE mtl_system_items_interface
              SET    process_flag = 3
              WHERE  rowid        = exc.rowid;
              l_error_logged := INVPUOPI.mtl_log_interface_err(
                                     exc.organization_id,
                                     FND_GLOBAL.USER_ID,
                                     FND_GLOBAL.LOGIN_ID,
                                     FND_GLOBAL.PROG_APPL_ID,
                                     FND_GLOBAL.CONC_PROGRAM_ID,
                                     FND_GLOBAL.CONC_REQUEST_ID,
                                     exc.transaction_id,
                                     l_msg_data,
                                     'LOGIN_USER_ID',
                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                     'INV_IOI_ERR',
                                     l_err_text);
              IF l_error_logged < 0 THEN
                 Raise LOGGING_ERR;
              END IF;
                END LOOP;
        END IF;
     WHEN OTHERS THEN
         NULL;
  END Insert_Grants_And_UserAttr;

  --  ============================================================================
  --  API Name    : phase_change_policy
  --  Description : This procedure will be called from IOI (INVPVALB.pls)
  --                Stuffed version will return 'ALLOWED' through l_Policy_Code.
  --                EGO_LIFECYCLE_USER_PUB.get_policy_for_phase_change will be called.
  --  ============================================================================

  PROCEDURE phase_change_policy(P_ORGANIZATION_ID    IN         NUMBER
                               ,P_INVENTORY_ITEM_ID  IN         NUMBER
                               ,P_CURR_PHASE_ID      IN         NUMBER
                               ,P_FUTURE_PHASE_ID    IN         NUMBER
                               ,P_PHASE_CHANGE_CODE  IN         VARCHAR2
                               ,P_LIFECYCLE_ID       IN         NUMBER
                               ,X_POLICY_CODE        OUT NOCOPY VARCHAR2
                               ,X_RETURN_STATUS      OUT NOCOPY VARCHAR2
                               ,X_ERRORCODE          OUT NOCOPY NUMBER
                               ,X_MSG_COUNT          OUT NOCOPY NUMBER
                               ,X_MSG_DATA           OUT NOCOPY VARCHAR2) IS
   BEGIN

      EGO_LIFECYCLE_USER_PUB.GET_POLICY_FOR_PHASE_CHANGE
         (P_API_VERSION       => 1.0
         ,P_ORGANIZATION_ID   => P_ORGANIZATION_ID
         ,P_INVENTORY_ITEM_ID => P_INVENTORY_ITEM_ID
         ,P_CURR_PHASE_ID     => P_CURR_PHASE_ID
         ,P_FUTURE_PHASE_ID   => P_FUTURE_PHASE_ID
         ,P_PHASE_CHANGE_CODE => P_PHASE_CHANGE_CODE
         ,P_LIFECYCLE_ID      => P_LIFECYCLE_ID
         ,X_POLICY_CODE       => X_POLICY_CODE
         ,X_RETURN_STATUS     => X_RETURN_STATUS
         ,X_ERRORCODE         => X_ERRORCODE
         ,X_MSG_COUNT         => X_MSG_COUNT
         ,X_MSG_DATA          => X_MSG_DATA);

   END phase_change_policy;

  --Start : 2803833
  FUNCTION get_default_template(p_catalog_group_id IN NUMBER)
  RETURN NUMBER IS

     CURSOR C_Default_Template(cp_catalog_group_id NUMBER) IS
        SELECT cat_temp.TEMPLATE_ID
        FROM   EGO_CAT_GRP_TEMPLATES cat_temp,
               MTL_ITEM_TEMPLATES temp
        WHERE  cat_temp.CATALOG_GROUP_ID = cp_catalog_group_id
        AND    cat_temp.DEFAULT_FLAG     = 'Y'
        AND    cat_temp.TEMPLATE_ID      = temp.TEMPLATE_ID;

     l_template_id      number := NULL;

  BEGIN

     OPEN C_Default_Template(p_catalog_group_id);
     FETCH C_Default_Template INTO l_template_id;
     CLOSE C_Default_Template;

     RETURN l_template_id;

  END get_default_template;
  --End     2803833

----------------------------------------------------------------
--API Name    : Sync_Template_Attribute   Bug:3405225
--Description : To sync up operational attribute values in mtl_item_templ_attributes
--              with ego_templ_attributes
--parameters:
--  p_attribute_name is the full attribute name in mtl_item_templ_attributes
--                    is NULL for INSERTING new Template and attributes
----------------------------------------------------------------

PROCEDURE Sync_Template_Attribute(
     p_template_id      IN NUMBER,
     p_attribute_name   IN VARCHAR2)
IS
     l_return_status   VARCHAR2(2000);
     l_message_text    VARCHAR2(2000);
BEGIN
 IF (p_attribute_name IS NULL) THEN --Insert
   EGO_TEMPL_ATTRS_PUB.Sync_Template(
     p_template_id      => p_template_id,
     p_commit           => FND_API.G_FALSE,
     x_return_status    => l_return_status,
     x_message_text     => l_message_text);
 ELSE            --Update
   EGO_TEMPL_ATTRS_PUB.Sync_Template_Attribute(
     p_template_id      => p_template_id,
     p_attribute_name   => p_attribute_name,
     p_commit           => FND_API.G_FALSE,
     x_return_status    => l_return_status,
     x_message_text     => l_message_text);
 END IF;
EXCEPTION
  WHEN OTHERS THEN
      NULL;
END Sync_Template_Attribute;

------------------------------------------------------------------------------------------
--API Name    : Update_Attribute_Control_Level   Bug:3405225
--Description : To update the control level of an attribute in EGO_FND_DF_COL_USGS_EXT
--Parameteres required : 1) p_control_level is a valid control level
--             as represented in lookup 'EGO_PC_CONTROL_LEVEL' in fnd_lookups
--            2) p_application_column_name is not null and is a valid column name
--            3) p_application_id is not null and is valid
--            4) p_descriptive_flexfield_name corresponds to a valid attribute group type
------------------------------------------------------------------------------------------
PROCEDURE Update_Attribute_Control_Level (
        p_application_column_name       IN   VARCHAR2
       ,p_control_level                 IN   NUMBER)
IS
     l_return_status   VARCHAR2(2000);
     l_message_count   NUMBER;
     l_msg_data        VARCHAR2(2000);
BEGIN
  EGO_EXT_FWK_PUB.Update_Attribute_Control_Level(
     p_api_version      => 1,
     p_application_id   =>  431,
     p_descriptive_flexfield_name => 'EGO_MASTER_ITEMS' ,
     p_application_column_name => p_application_column_name,
     p_control_level    => p_control_level,
     p_init_msg_list    => FND_API.G_FALSE,
     p_commit           => FND_API.G_FALSE,
     x_return_status    => l_return_status,
     x_msg_count        => l_message_count,
     x_msg_data         => l_msg_data);
EXCEPTION
  WHEN OTHERS THEN
      NULL;
END Update_Attribute_Control_Level;

------------------------------------------------------------------------------------------
--API Name    : Pending_Eco_Check_Sync_Ids
--Description : Pending ECO check and sync lifecycles
------------------------------------------------------------------------------------------
--Start :3637854
PROCEDURE Pending_Eco_Check_Sync_Ids(
         P_Prog_AppId  IN            NUMBER  DEFAULT -1
        ,P_Prog_Id     IN            NUMBER  DEFAULT -1
        ,P_Request_Id  IN            NUMBER  DEFAULT -1
        ,P_User_Id     IN            NUMBER  DEFAULT -1
        ,P_Login_Id    IN            NUMBER  DEFAULT -1
        ,P_Set_id      IN            NUMBER  DEFAULT -999)
IS
   CURSOR c_get_valid_item_records IS
      SELECT inventory_item_id
            ,organization_id
            ,item_catalog_group_id
            ,lifecycle_id
            ,current_phase_id
            ,transaction_id
            ,inventory_item_status_code
            ,rowid
      FROM   MTL_SYSTEM_ITEMS_INTERFACE
      WHERE (set_process_id = p_set_id OR set_process_id = p_set_id + 1000000000000)
      AND   transaction_type IN ('UPDATE', 'AUTO_CHILD')
      AND   process_flag    = 4;

   CURSOR c_get_existing_item_record(cp_item_id NUMBER, cp_org_id NUMBER) IS
      SELECT item_catalog_group_id
            ,lifecycle_id
            ,current_phase_id
      FROM   MTL_SYSTEM_ITEMS_B
      WHERE  inventory_item_id = cp_item_id
      AND    organization_id   = cp_org_id;


   CURSOR c_get_valid_rev_records   IS
      SELECT inventory_item_id
            ,organization_id
            ,revision_id
            ,lifecycle_id
            ,current_phase_id
            ,transaction_id
            ,rowid
      FROM   mtl_item_revisions_interface
      WHERE (set_process_id  = p_set_id OR set_process_id = p_set_id + 1000000000000)
      AND   transaction_type = 'UPDATE'
      AND   process_flag     = 4;

   CURSOR c_get_existing_rev_record(cp_rev_id NUMBER)  IS
      SELECT lifecycle_id
            ,current_phase_id
      FROM   mtl_item_revisions_b
      WHERE revision_id = cp_rev_id;

   l_old_item_rec   c_get_existing_item_record%ROWTYPE;
   l_old_rev_rec    c_get_existing_rev_record%ROWTYPE;
   l_return_status  VARCHAR2(1);
   l_msg_text       VARCHAR2(2000);
   l_msg_count      NUMBER;
   l_column_name    VARCHAR2(30);
   dumm_status      NUMBER;
   err_text         VARCHAR2(2000);

BEGIN

   IF (INV_Item_Util.g_Appl_Inst.EGO <> 0 AND
       INV_ITEM_UTIL.Object_Exists(p_object_type => 'PACKAGE'
                                  ,p_object_name => 'EGO_INV_ITEM_CATALOG_PVT') ='Y')
   THEN

      FOR cur IN c_get_valid_item_records LOOP

         OPEN  c_get_existing_item_record(cur.inventory_item_id,cur.organization_id);
         FETCH c_get_existing_item_record INTO l_old_item_rec;
         CLOSE c_get_existing_item_record;

         l_return_status := NULL;

         IF l_old_item_rec.lifecycle_id IS NOT NULL
            AND cur.lifecycle_id IS NULL
         THEN

            l_column_name := 'LIFECYCLE_ID';

            EXECUTE IMMEDIATE
               ' BEGIN                                                     '
             ||'   EGO_INV_ITEM_CATALOG_PVT.CHANGE_ITEM_LC_DEPENDECIES(    '
             ||'      P_API_VERSION             => 1.0                     '
             ||'     ,P_INVENTORY_ITEM_ID       => :cur.inventory_item_id  '
             ||'     ,P_ORGANIZATION_ID         => :cur.organization_id    '
             ||'     ,P_ITEM_REVISION_ID        => NULL                    '
             ||'     ,P_LIFECYCLE_ID            => NULL                    '
             ||'     ,P_LIFECYCLE_PHASE_ID      => NULL                    '
             ||'     ,P_LIFECYCLE_CHANGED       => NULL                    '
             ||'     ,P_LIFECYCLE_PHASE_CHANGED => NULL                    '
             ||'     ,P_PERFORM_SYNC_ONLY       => FND_API.G_TRUE          '
             ||'     ,X_RETURN_STATUS           => :l_return_status        '
             ||'     ,X_MSG_COUNT               => :l_msg_count            '
             ||'     ,X_MSG_DATA                => :l_msg_text);           '
             ||' EXCEPTION                                                 '
             ||'    WHEN OTHERS THEN                                       '
             ||'      NULL;                                                '
             ||' END;                                                      '
            USING IN  cur.inventory_item_id,
                  IN  cur.organization_id,
                  OUT l_return_status,
                  OUT l_msg_count,
                  OUT l_msg_text;

         ELSIF ( l_old_item_rec.lifecycle_id IS NOT NULL
                 AND cur.lifecycle_id        IS NOT NULL
                 AND l_old_item_rec.lifecycle_id <> cur.lifecycle_id)
                 --3802017 : Pending ECO check for NULL to NOTNULL case.
                OR (l_old_item_rec.lifecycle_id IS NULL
                    AND cur.lifecycle_id        IS NOT NULL)
         THEN

            l_column_name := 'LIFECYCLE_ID';

            EXECUTE IMMEDIATE
               ' BEGIN                                                     '
             ||'   EGO_INV_ITEM_CATALOG_PVT.CHANGE_ITEM_LC_DEPENDECIES(    '
             ||'      P_API_VERSION             => 1.0                     '
             ||'     ,P_INVENTORY_ITEM_ID       => :cur.inventory_item_id  '
             ||'     ,P_ORGANIZATION_ID         => :cur.organization_id    '
             ||'     ,P_ITEM_REVISION_ID        => NULL                    '
             ||'     ,P_LIFECYCLE_ID            => :cur.lifecycle_id       '
             ||'     ,P_LIFECYCLE_PHASE_ID      => :cur.current_phase_id   '
             ||'     ,P_LIFECYCLE_CHANGED       => FND_API.G_TRUE          '
             ||'     ,P_LIFECYCLE_PHASE_CHANGED => FND_API.G_TRUE          '
             ||'     ,P_PERFORM_SYNC_ONLY       => FND_API.G_FALSE         '
             ||'     ,X_RETURN_STATUS           => :l_return_status        '
             ||'     ,X_MSG_COUNT               => :l_msg_count            '
             ||'     ,X_MSG_DATA                => :l_msg_text);           '
             ||' EXCEPTION                                                 '
             ||'    WHEN OTHERS THEN                                       '
             ||'      NULL;                                                '
             ||' END;                                                      '
            USING IN  cur.inventory_item_id,
                  IN  cur.organization_id,
                  IN  cur.lifecycle_id,
                  IN  cur.current_phase_id,
                  OUT l_return_status,
                  OUT l_msg_count,
                  OUT l_msg_text;

         ELSIF (l_old_item_rec.lifecycle_id = cur.lifecycle_id
                AND l_old_item_rec.current_phase_id <> cur.current_phase_id)
         THEN

            l_column_name := 'CURRENT_PHASE_ID';

            EXECUTE IMMEDIATE
               ' BEGIN                                                     '
             ||'   EGO_INV_ITEM_CATALOG_PVT.CHANGE_ITEM_LC_DEPENDECIES(    '
             ||'      P_API_VERSION             => 1.0                     '
             ||'     ,P_INVENTORY_ITEM_ID       => :cur.inventory_item_id  '
             ||'     ,P_ORGANIZATION_ID         => :cur.organization_id    '
             ||'     ,P_ITEM_REVISION_ID        => NULL                    '
             ||'     ,P_LIFECYCLE_ID            => :cur.lifecycle_id       '
             ||'     ,P_LIFECYCLE_PHASE_ID      => :cur.current_phase_id   '
             ||'     ,P_LIFECYCLE_CHANGED       => FND_API.G_FALSE         '
             ||'     ,P_LIFECYCLE_PHASE_CHANGED => FND_API.G_TRUE          '
             ||'     ,P_PERFORM_SYNC_ONLY       => FND_API.G_FALSE         '
             ||'     ,X_RETURN_STATUS           => :l_return_status        '
             ||'     ,X_MSG_COUNT               => :l_msg_count            '
             ||'     ,X_MSG_DATA                => :l_msg_text);           '
             ||' EXCEPTION                                                 '
             ||'    WHEN OTHERS THEN                                       '
             ||'      NULL;                                                '
             ||' END;                                                      '
            USING IN  cur.inventory_item_id,
                  IN  cur.organization_id,
                  IN  cur.lifecycle_id,
                  IN  cur.current_phase_id,
                  OUT l_return_status,
                  OUT l_msg_count,
                  OUT l_msg_text;
         END IF;

         IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN

            UPDATE mtl_system_items_interface
            SET    process_flag = 3
            WHERE  rowid        = cur.rowid;

            dumm_status  := INVPUOPI.mtl_log_interface_err(
                               cur.organization_id
                              ,P_User_Id
                              ,P_Login_Id
                              ,P_Prog_AppId
                              ,P_Prog_Id
                              ,P_Request_Id
                              ,cur.transaction_id
                              ,l_msg_text
                              ,l_column_name
                              ,'MTL_SYSTEM_ITEMS_INTERFACE'
                              ,'INV_IOI_ERR'
                              ,err_text);
         END IF;
      END LOOP;


      FOR cur IN c_get_valid_rev_records LOOP

         OPEN  c_get_existing_rev_record(cp_rev_id=>cur.revision_id);
         FETCH c_get_existing_rev_record INTO l_old_rev_rec;
         CLOSE c_get_existing_rev_record;

         l_return_status := NULL;

         IF (l_old_rev_rec.lifecycle_id IS NOT NULL AND cur.lifecycle_id IS NULL)
          OR(l_old_rev_rec.lifecycle_id IS NOT NULL
             AND cur.lifecycle_id       IS NOT NULL
             AND l_old_rev_rec.lifecycle_id <> cur.lifecycle_id)
          --3802017 : Pending ECO check for NULL to NOTNULL case.
          OR (l_old_rev_rec.lifecycle_id  IS NULL
              AND cur.lifecycle_id        IS NOT NULL)
         THEN

            l_column_name := 'LIFECYCLE_ID';

            EXECUTE IMMEDIATE
               ' BEGIN                                                     '
             ||'   EGO_INV_ITEM_CATALOG_PVT.CHANGE_ITEM_LC_DEPENDECIES(    '
             ||'      P_API_VERSION             => 1.0                     '
             ||'     ,P_INVENTORY_ITEM_ID       => :cur.inventory_item_id  '
             ||'     ,P_ORGANIZATION_ID         => :cur.organization_id    '
             ||'     ,P_ITEM_REVISION_ID        => :cur.revision_id        '
             ||'     ,P_LIFECYCLE_ID            => :cur.lifecycle_id       '
             ||'     ,P_LIFECYCLE_PHASE_ID      => :cur.current_phase_id   '
             ||'     ,P_LIFECYCLE_CHANGED       => FND_API.G_TRUE          '
             ||'     ,P_LIFECYCLE_PHASE_CHANGED => FND_API.G_TRUE          '
             ||'     ,P_PERFORM_SYNC_ONLY       => FND_API.G_FALSE         '
             ||'     ,X_RETURN_STATUS           => :l_return_status        '
             ||'     ,X_MSG_COUNT               => :l_msg_count            '
             ||'     ,X_MSG_DATA                => :l_msg_text);           '
             ||' EXCEPTION                                                 '
             ||'    WHEN OTHERS THEN                                       '
             ||'      NULL;                                                '
             ||' END;                                                      '
            USING IN  cur.inventory_item_id,
                  IN  cur.organization_id,
                  IN  cur.revision_id,
                  IN  cur.lifecycle_id,
                  IN  cur.current_phase_id,
                  OUT l_return_status,
                  OUT l_msg_count,
                  OUT l_msg_text;

         ELSIF (l_old_rev_rec.lifecycle_id = cur.lifecycle_id
                AND l_old_rev_rec.current_phase_id <> cur.current_phase_id)
         THEN

            l_column_name := 'CURRENT_PHASE_ID';

            EXECUTE IMMEDIATE
               ' BEGIN                                                     '
             ||'   EGO_INV_ITEM_CATALOG_PVT.CHANGE_ITEM_LC_DEPENDECIES(    '
             ||'      P_API_VERSION             => 1.0                     '
             ||'     ,P_INVENTORY_ITEM_ID       => :cur.inventory_item_id  '
             ||'     ,P_ORGANIZATION_ID         => :cur.organization_id    '
             ||'     ,P_ITEM_REVISION_ID        => :cur.revision_id        '
             ||'     ,P_LIFECYCLE_ID            => :cur.lifecycle_id       '
             ||'     ,P_LIFECYCLE_PHASE_ID      => :cur.current_phase_id   '
             ||'     ,P_LIFECYCLE_CHANGED       => FND_API.G_FALSE         '
             ||'     ,P_LIFECYCLE_PHASE_CHANGED => FND_API.G_TRUE          '
             ||'     ,P_PERFORM_SYNC_ONLY       => FND_API.G_FALSE         '
             ||'     ,X_RETURN_STATUS           => :l_return_status        '
             ||'     ,X_MSG_COUNT               => :l_msg_count            '
             ||'     ,X_MSG_DATA                => :l_msg_text);           '
             ||' EXCEPTION                                                 '
             ||'    WHEN OTHERS THEN                                       '
             ||'      NULL;                                                '
             ||' END;                                                      '
            USING IN  cur.inventory_item_id,
                  IN  cur.organization_id,
                  IN  cur.revision_id,
                  IN  cur.lifecycle_id,
                  IN  cur.current_phase_id,
                  OUT l_return_status,
                  OUT l_msg_count,
                  OUT l_msg_text;
         END IF;

         IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN

            UPDATE mtl_item_revisions_interface
            SET    process_flag = 3
            WHERE  rowid        = cur.rowid;

            dumm_status  := INVPUOPI.mtl_log_interface_err(
                               cur.organization_id
                              ,P_User_Id
                              ,P_Login_Id
                              ,P_Prog_AppId
                              ,P_Prog_Id
                              ,P_Request_Id
                              ,cur.transaction_id
                              ,l_msg_text
                              ,l_column_name
                              ,'MTL_ITEM_REVISIONS_INTERFACE'
                              ,'INV_IOI_ERR'
                              ,err_text);
         END IF;
      END LOOP;

   END IF; --INV_Item_Util.g_Appl_Inst.EGO <> 0

EXCEPTION
   WHEN OTHERS THEN
      NULL;
END Pending_Eco_Check_Sync_Ids;
--End : 3637854
------------------------------------------------------------------------------------------
--API Name    : Upgrade_cat_User_Attrs_Data
--Description : Bug: 3527633    Added for EGO
--             There are certain extensible attribute groups that are associated with the
--             default category set of the product reporting functional area. When the
--             default category set is changed we need to call an EGO API that will
--             automatically associate these attribute groups with the new category set.
--Parameteres required : 1) p_functional_area_id is a unctional area
------------------------------------------------------------------------------------------
PROCEDURE Upgrade_cat_User_Attrs_Data ( p_functional_area_id  IN  NUMBER  ) IS
     l_return_status   VARCHAR2(2000);
     l_message_count   NUMBER;
     l_msg_data        VARCHAR2(2000);
     l_errorcode       NUMBER;
BEGIN
  IF (INV_Item_Util.g_Appl_Inst.EGO <> 0 AND
        INV_ITEM_UTIL.Object_Exists(p_object_type => 'PACKAGE'
                                   ,p_object_name => 'EGO_UPGRADE_USER_ATTR_VAL_PUB') ='Y')
  THEN
    EXECUTE IMMEDIATE
    'BEGIN
      EGO_UPGRADE_USER_ATTR_VAL_PUB.Upgrade_Cat_User_Attrs_Data
      (
       p_api_version              => 1.0
      ,p_functional_area_id       => :p_functional_area_id
      ,p_attr_group_name          => NULL
      ,x_return_status            => :l_return_status
      ,x_errorcode                => :l_errorcode
      ,x_msg_count                => :l_message_count
      ,x_msg_data                 => :l_msg_data
      ); '||
    'EXCEPTION               '||
      ' WHEN OTHERS THEN     '||
      '   NULL;              '||
      'END;'
      USING IN p_functional_area_id, OUT l_return_status, OUT l_errorcode, OUT l_message_count, OUT l_msg_data;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
      NULL;
END Upgrade_cat_User_Attrs_Data;

------------------------------------------------------------------------------------------
--API Name    : Check_No_MFG_Associations
--Description : Bug: 3735702    Added for EGO
--             There are certain associations to the manufacturers which are used by EGO
--             So, when deleting the Manufacturer, we need to check for the associations
--             and flash an error if any associations exist
--Parameteres required : 1) p_manufacturer_id  2)p_api_version
--Return parameteres   : 1) x_return_status = 'Y' if no associations exist
--                                            'N' in all other cases
--                       2) x_message_text  = valid only if x_return_status = 'N'
--
------------------------------------------------------------------------------------------
PROCEDURE Check_No_MFG_Associations
  (p_api_version          IN  NUMBER
  ,p_manufacturer_id      IN  NUMBER
  ,p_manufacturer_name    IN  VARCHAR2
  ,x_return_status       OUT  NOCOPY VARCHAR2
  ,x_message_name        OUT  NOCOPY VARCHAR2
  ,x_message_text        OUT  NOCOPY VARCHAR2
  ) IS

  BEGIN
   IF (INV_Item_Util.g_Appl_Inst.EGO <> 0 AND
       INV_ITEM_UTIL.Object_Exists(p_object_type => 'PACKAGE'
                                  ,p_object_name => 'EGO_ITEM_AML_PUB') ='Y')
   THEN
     EXECUTE IMMEDIATE
               ' BEGIN                                                     '
             ||'   EGO_ITEM_AML_PUB.Check_No_MFG_Associations(       '
             ||'      P_API_VERSION          => :p_api_version       '
             ||'     ,P_MANUFACTURER_ID      => :p_manufacturer_id   '
             ||'     ,P_MANUFACTURER_NAME    => :p_manufacturer_name '
             ||'     ,X_RETURN_STATUS        => :x_return_status     '
             ||'     ,X_MESSAGE_NAME         => :x_message_name      '
             ||'     ,X_MESSAGE_TEXT         => :x_message_text);    '
             ||' EXCEPTION                                           '
             ||'    WHEN OTHERS THEN                                 '
             ||'      NULL;                                          '
             ||' END;                                                '
      USING IN  p_api_version,
                  IN  p_manufacturer_id,
                  IN  p_manufacturer_name,
            OUT x_return_status,
            OUT x_message_name,
            OUT x_message_text;
  ELSE
    x_return_status := 'Y';
  END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := 'N';
      x_message_text := SUBSTR('INV_EGO_REVISION_VALIDATE.Check_No_MFG_Associations ' || SQLERRM , 1,240);
  END CHECK_NO_MFG_ASSOCIATIONS;

------------------------------------------------------------------------------------------
--API Name    : Check_Template_Cat_Associations
--Description : Bug # 3326991    Added for Delete template Operation.
--This procedure is used in the deletion of Item templates in the form
--INVIDTMP.fmb (MTL_ITEM_TEMPLATES.check_delete_row)

-- An Item Template cannot be deleted if any associations to catalog categories exist

--Parameteres required : 1) p_template_id
--Return parametere    : 1) x_return_status = 1 if no associations exist
--                                            0 in all other cases
------------------------------------------------------------------------------------------
PROCEDURE CHECK_TEMPLATE_CAT_ASSOCS
  (p_template_id         IN  NUMBER
  ,x_return_status       OUT NOCOPY NUMBER
  ) IS
  l_template_exists NUMBER := 0;
  BEGIN

  IF (INV_ITEM_UTIL.APPL_INST_EGO <> 0) THEN
        EXECUTE IMMEDIATE
                'SELECT count(*)
                 FROM dual
                 WHERE EXISTS(SELECT 1 FROM ego_cat_grp_templates
                              WHERE template_id = :p_template_id)'
        INTO l_template_exists
        USING p_template_id;
  END IF;
  IF (l_template_exists <= 0) THEN
    x_return_status := 1;
  ELSE
    x_return_status := 0;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := 1;
  END CHECK_TEMPLATE_CAT_ASSOCS;
------------------------------------------------------------------------------------------

-- Added for 11.5.10+ UCCnet functionality
------------------------------------------------------------------------------------------
--API Name    : Process_UCCnet_Attributes
--Description : Calls the method to update the REGISTRATION_UPDATE_DATE
--              and TP_NEUTRAL_UPDATE_DATE for each Item/GTIN, when the respective
--              attributes are changed
------------------------------------------------------------------------------------------
PROCEDURE Process_UCCnet_Attributes(
   P_Prog_AppId  IN            NUMBER  DEFAULT -1
  ,P_Prog_Id     IN            NUMBER  DEFAULT -1
  ,P_Request_Id  IN            NUMBER  DEFAULT -1
  ,P_User_Id     IN            NUMBER  DEFAULT -1
  ,P_Login_Id    IN            NUMBER  DEFAULT -1
  ,P_Set_id      IN            NUMBER  DEFAULT -999)
IS
  l_sql            VARCHAR2(15000);
  l_suppress_flag  VARCHAR2(10);
BEGIN
  IF (INV_Item_Util.g_Appl_Inst.EGO <> 0 AND
        INV_ITEM_UTIL.Object_Exists(p_object_type => 'PACKAGE'
                                   ,p_object_name => 'EGO_GTIN_PVT') ='Y')  THEN
--Bug:4174218 BOM rollup code is calling ego-pvt with supress_rollup
    IF NVL(G_PROCESS_CONTROL,'N') <> 'SUPPRESS_ROLLUP' THEN
      l_suppress_flag := 'N';
    ELSE
      l_suppress_flag := 'Y';
    END IF;
    l_sql := 'BEGIN                                             '||
             '  EGO_GTIN_PVT.PROCESS_UCCNET_ATTRIBUTES(         '||
             '                  P_Prog_AppId => :P_Prog_AppId,  '||
             '                  P_Prog_Id    => :P_Prog_Id,     '||
             '                  P_Request_Id => :P_Request_Id,  '||
             '                  P_User_Id    => :P_User_Id,     '||
             '                  P_Login_Id   => :P_Login_Id,    '||
             '                  P_Set_id     => :P_Set_id,      '||
             '                  P_Suppress_Rollup => :l_suppress_flag);'||
             'END;                                              ';
    EXECUTE IMMEDIATE l_sql USING
      IN P_Prog_AppId,
      IN P_Prog_Id,
      IN P_Request_Id,
      IN P_User_Id,
      IN P_Login_Id,
      IN P_Set_id,
      IN l_suppress_flag;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
     NULL;
END Process_UCCnet_Attributes;

/*------------------------------------------------------------------------------------------
--API Name    : Create_New_Item_Request
--Description : Bug# 3777954
--This procedure is used to create new item request for an item with 'CREATE' option.
-- Only for EGO IOI/EXCEL this needs to be called.
-- Current Phase, Approval Status and Item status will be reset accordingly.
--Parameteres required : 1) p_set_process_id => Record Set Id
------------------------------------------------------------------------------------------*/
PROCEDURE Create_New_Item_Request
   ( p_set_process_id IN  NUMBER)
IS

/* R12C : Changing the New Item Req Reqd = 'Y' sub-query for hierarchy enabled Catalogs */
   CURSOR c_nir_rec (cp_batch_id IN NUMBER)
   IS
     SELECT interface.inventory_item_id, interface.organization_id,
            interface.item_catalog_group_id
       FROM mtl_system_items_interface interface,
            mtl_parameters mp
      WHERE interface.SET_PROCESS_ID = p_set_process_id
        AND interface.PROCESS_FLAG   = 4
        AND interface.TRANSACTION_TYPE = 'CREATE'
        AND interface.ITEM_CATALOG_GROUP_ID IS NOT NULL
        AND mp.ORGANIZATION_ID = interface.ORGANIZATION_ID
        AND mp.ORGANIZATION_ID = mp.MASTER_ORGANIZATION_ID;

/* R12C : Introducing cursor for hierarchy enabled Catalogs */
   CURSOR c_nir_reqd (cp_item_catalog_group_id IN NUMBER)
   IS
      SELECT  ICC.NEW_ITEM_REQUEST_REQD
        FROM  MTL_ITEM_CATALOG_GROUPS_B ICC
       WHERE  ICC.NEW_ITEM_REQUEST_REQD IS NOT NULL
         AND  ICC.NEW_ITEM_REQUEST_REQD <> 'I'
     CONNECT BY PRIOR ICC.PARENT_CATALOG_GROUP_ID = ICC.ITEM_CATALOG_GROUP_ID
       START WITH ICC.ITEM_CATALOG_GROUP_ID = cp_item_catalog_group_id
       ORDER BY LEVEL ASC;

   CURSOR c_nir_option
   IS
     SELECT nir_option
       FROM ego_import_option_sets
      WHERE batch_id = p_set_process_id;

   --To fetch Batch level option in the case of Bulk SKU creation from UI
   CURSOR c_nir_batch_option
   IS
     SELECT selection_flag
       FROM ego_import_copy_options
      WHERE copy_option = 'NIR_OPTION'
        AND batch_id = p_set_process_id;

 l_nir_import_option VARCHAR2(1);
 l_ret_status        VARCHAR2(1);
 l_msg_data          VARCHAR2(1000);
 l_msg_count         NUMBER;
 l_inv_debug_level   NUMBER := INVPUTLI.get_debug_level;  --Bug: 4667452
 l_rec_for_process   NUMBER := 0;
 l_nir_reqd          VARCHAR2(1) := 'N';

BEGIN

  IF (INSTR(NVL(G_PROCESS_CONTROL,'PLM_UI:N'),'PLM_UI:Y') = 0 ) THEN
  /*  EMTAPIA: commented out for bug: 7036113. Replacing this for loop with a single       SQL statement
    FOR nir_item IN c_nir_rec(cp_batch_id => p_set_process_id)
    LOOP
       l_nir_reqd := 'N';
    -- R12C : Retrieving NIR reqd for hierarchy enabled Catalogs
       OPEN  c_nir_reqd(cp_item_catalog_group_id => nir_item.item_catalog_group_id);
       FETCH c_nir_reqd INTO l_nir_reqd;
       CLOSE c_nir_reqd;

       IF l_nir_reqd = 'Y' THEN
          UPDATE  MTL_SYSTEM_ITEMS_B
             SET  INVENTORY_ITEM_STATUS_CODE='Pending'
                 ,APPROVAL_STATUS = 'N'
                 ,CURRENT_PHASE_ID = DECODE(LIFECYCLE_ID,NULL,NULL,Get_Initial_Lifecycle_Phase(LIFECYCLE_ID))
           WHERE  INVENTORY_ITEM_ID = nir_item.inventory_item_id
             AND  ORGANIZATION_ID = nir_item.organization_id;

           l_rec_for_process := 1;
       END IF;
    END LOOP;
*/

 --EMTAPIA: added for bug 7036113
 /* Bug 8799957. Replacing LEVEL = 1 condition with ROWNUM = 1 to check if New Item Request is
 required or not, in case child ICC is inheriting NIR from parent ICC */
     UPDATE mtl_system_items_b
     SET    inventory_item_status_code = 'Pending',
            approval_status = 'N',
            current_phase_id = DECODE(lifecycle_id, NULL, NULL,
                Get_Initial_Lifecycle_Phase(lifecycle_id))
     WHERE (inventory_item_id, organization_id) IN
       (SELECT interface.inventory_item_id, interface.organization_id
        FROM   mtl_system_items_interface interface,
               mtl_parameters mp
        WHERE  interface.set_process_id = p_set_process_id
          AND  interface.process_flag = 4
          AND  interface.transaction_type = 'CREATE'
          AND  interface.item_catalog_group_id IS NOT NULL
          AND  mp.organization_id = interface.organization_id
          AND  mp.organization_id = mp.master_organization_id
          AND  'Y' =
            (SELECT icc.new_item_request_reqd
             FROM   mtl_item_catalog_groups_b icc
             WHERE  icc.new_item_request_reqd IS NOT NULL
               AND  icc.new_item_request_reqd <> 'I'
               AND  ROWNUM = 1
             CONNECT BY PRIOR
                 icc.parent_catalog_group_id = icc.item_catalog_group_id
             START WITH
                 icc.item_catalog_group_id = interface.item_catalog_group_id
             ));


      IF SQL%ROWCOUNT > 0 THEN
         l_rec_for_process := 1;
      END IF;
      --EMTAPIA: end added for bug 7036113



    IF l_rec_for_process = 1 THEN
      OPEN  c_nir_option;
      FETCH c_nir_option INTO l_nir_import_option;

      IF c_nir_option%NOTFOUND THEN
         OPEN  c_nir_batch_option;
         FETCH c_nir_batch_option INTO l_nir_import_option;

         IF c_nir_batch_option%NOTFOUND THEN
            l_nir_import_option := 'I';
         END IF;
         CLOSE c_nir_batch_option;
      END IF;
      CLOSE c_nir_option;

      IF l_nir_import_option <> 'N' THEN

        /* R12C Modifying stmt to support hierarchy enabled catalogs for NIR reqd */
        UPDATE mtl_system_items_interface msii
           SET msii.process_flag = 5
         WHERE msii.ROWID IN
         ( SELECT interface.ROWID
             FROM mtl_system_items_interface interface,
              --  MTL_ITEM_CATALOG_GROUPS_B  micb,
                  MTL_PARAMETERS mp
            WHERE  interface.SET_PROCESS_ID = p_set_process_id
              AND  interface.PROCESS_FLAG   = 4
              AND  interface.TRANSACTION_TYPE = 'CREATE'
              --AND  interface.ITEM_CATALOG_GROUP_ID = micb.item_catalog_group_id
              AND  interface.ITEM_CATALOG_GROUP_ID IS NOT NULL
              --AND  micb.NEW_ITEM_REQUEST_REQD = 'Y'
              AND  mp.organization_id = interface.organization_id
              AND interface.organization_id = mp.master_organization_id
              AND 'Y' =
                       ( SELECT  ICC.NEW_ITEM_REQUEST_REQD
                           FROM  MTL_ITEM_CATALOG_GROUPS_B ICC
                          WHERE  ICC.NEW_ITEM_REQUEST_REQD IS NOT NULL
                            AND  ICC.NEW_ITEM_REQUEST_REQD <> 'I'
                            AND  ROWNUM = 1
                         CONNECT BY PRIOR ICC.PARENT_CATALOG_GROUP_ID = ICC.ITEM_CATALOG_GROUP_ID
                         START WITH ICC.ITEM_CATALOG_GROUP_ID = interface.ITEM_CATALOG_GROUP_ID ) );

        ENG_NEW_ITEM_REQ_UTIL.create_new_item_requests( p_batch_id      => p_set_process_id,
                                                        p_nir_option    => l_nir_import_option,
                                                        x_return_status => l_ret_status,
                                                        x_msg_data      => l_msg_data,
                                                        x_msg_count     => l_msg_count );

        IF (l_ret_status = FND_API.G_RET_STS_SUCCESS )THEN
            UPDATE mtl_system_items_interface
               SET process_flag = 4
             WHERE set_process_id = p_set_process_id
               AND process_flag = 5;
        ELSE
           IF l_inv_debug_level IN(101, 102) THEN
              INVPUTLI.info('INV_EGO_REVISION_VALIDATE.Create_New_Item_Request: Following exception from CM during NIR creation');
              INVPUTLI.info(l_msg_data);
           END IF;

           UPDATE mtl_system_items_interface
              SET process_flag = 3,
                  change_id = NULL,
                  change_line_id = NULL
            WHERE set_process_id = p_set_process_id
              AND process_flag = 5;
        END IF;
      END IF; -- NIR batch option NOT 'N'
    END IF; --More than 0 items for NIR creation
  END IF; -- Not called for UI create
EXCEPTION
  WHEN OTHERS THEN
       IF l_inv_debug_level IN(101, 102) THEN
          INVPUTLI.info('INV_EGO_REVISION_VALIDATE.Create_New_Item_Request: Exception'||substr(SQLERRM,1,200));
       END IF;

       UPDATE mtl_system_items_interface
          SET process_flag = 3,
              change_id = NULL,
              change_line_id = NULL
        WHERE set_process_id = p_set_process_id
          AND process_flag = 5;

END Create_New_Item_Request;

/* Obsoleting the below procedure and replacing its definition with the one above - R12 FPC
  PROCEDURE Create_New_Item_Request
   ( p_set_process_id NUMBER
   ) IS

   CURSOR c_get_processed_records (cp_set_process_id NUMBER) IS
      SELECT interface.INVENTORY_ITEM_ID,
             interface.ITEM_CATALOG_GROUP_ID,
             interface.ORGANIZATION_ID,
             interface.TRANSACTION_ID,
             interface.ITEM_NUMBER,
             interface.rowid,
             micb.NEW_ITEM_REQ_CHANGE_TYPE_ID,
             mp.ORGANIZATION_CODE
       FROM  MTL_SYSTEM_ITEMS_INTERFACE interface,
             MTL_ITEM_CATALOG_GROUPS_B  micb,
             MTL_PARAMETERS mp
      WHERE  interface.SET_PROCESS_ID = cp_set_process_id
        AND  interface.PROCESS_FLAG   = 4
        AND  interface.TRANSACTION_TYPE = 'CREATE'
        AND  interface.ITEM_CATALOG_GROUP_ID = micb.ITEM_CATALOG_GROUP_ID
        AND  micb.NEW_ITEM_REQUEST_REQD = 'Y'
        AND  mp.ORGANIZATION_ID = interface.ORGANIZATION_ID
        AND  mp.ORGANIZATION_ID = mp.MASTER_ORGANIZATION_ID --Bug 4517161
        FOR UPDATE OF interface.INVENTORY_ITEM_ID;

    l_return_status VARCHAR2(10) := 'S';
    err_text        VARCHAR2(240);
    l_dynamic_sql   VARCHAR2(2000);
    l_dummy         NUMBER;
    dumm_status     NUMBER;
    l_cursor_id     NUMBER;
    l_change_id     NUMBER;
    l_error_table   Error_Handler.Error_Tbl_Type;
    l_type_name     VARCHAR2(1000);
    l_error         boolean;

    l_inv_debug_level   NUMBER := INVPUTLI.get_debug_level;  --Bug: 4667452
  BEGIN

    IF (INSTR(NVL(G_PROCESS_CONTROL,'PLM_UI:N'),'PLM_UI:Y') = 0 ) THEN

    FOR i in c_get_processed_records(p_set_process_id) LOOP
--Ideally this update should be done only after NIR created succesfully
-- but for technical reasons we are not stoping item creation even though
-- NIR is not created.
      UPDATE MTL_SYSTEM_ITEMS_B
         SET INVENTORY_ITEM_STATUS_CODE='Pending'
             ,APPROVAL_STATUS = 'N'
             ,CURRENT_PHASE_ID = DECODE(LIFECYCLE_ID,NULL,NULL,Get_Initial_Lifecycle_Phase(LIFECYCLE_ID))
       WHERE INVENTORY_ITEM_ID = i.inventory_item_id
         AND ORGANIZATION_ID = i.organization_id;

      IF l_cursor_id IS NULL THEN
         l_cursor_id := DBMS_SQL.Open_Cursor;
         l_dynamic_sql := 'select type_name from eng_change_order_types_vl '||
                              'where change_order_type_id = :type_id ';
         DBMS_SQL.Parse(l_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);
         DBMS_SQL.define_column(l_cursor_id,1,l_type_name,1000);
      END IF;
      DBMS_SQL.Bind_Variable(l_cursor_id, 'type_id', i.NEW_ITEM_REQ_CHANGE_TYPE_ID);
      l_dummy := DBMS_SQL.Execute(l_cursor_id);
      IF DBMS_SQL.fetch_rows(l_cursor_id) > 0 THEN
        dbms_sql.column_value(l_cursor_id,1,l_type_name);
        EXECUTE IMMEDIATE
               ' BEGIN                                               '
             ||'   ENG_NEW_ITEM_REQ_UTIL.Create_New_Item_Request(    '
             ||'      change_number       => :i.ITEM_NUMBER          '
             ||'     ,change_name         => :i.ITEM_NUMBER          '
             ||'     ,change_type_code    => :l_type_name            '
             ||'     ,item_number         => :i.ITEM_NUMBER          '
             ||'     ,organization_code   => :i.ORGANIZATION_CODE    '
             ||'     ,requestor_user_name =>  FND_GLOBAL.user_name   '
             ||'     ,batch_id            => :p_set_process_id       '
             ||'     ,X_CHANGE_ID         => :l_change_id            '
             ||'     ,X_RETURN_STATUS     => :l_return_status    );  '
             ||' EXCEPTION                                           '
             ||'    WHEN OTHERS THEN                                 '
             ||'      NULL;                                          '
             ||' END;                                                '
           USING IN  i.ITEM_NUMBER,
                 IN  l_type_name,
                 IN  i.ORGANIZATION_CODE,
                 IN  p_set_process_id,
                 OUT l_change_id,
                 OUT l_return_status;
      ELSE
        l_error := true;
      END IF;
      IF (l_error OR l_return_status ='G' )THEN
        UPDATE MTL_SYSTEM_ITEMS_INTERFACE
           SET process_flag = 3
         WHERE rowid       = i.rowid;

         dumm_status  := INVPUOPI.mtl_log_interface_err(
                               i.organization_id,
                               FND_GLOBAL.USER_ID,
                               FND_GLOBAL.LOGIN_ID,
                               FND_GLOBAL.PROG_APPL_ID,
                               FND_GLOBAL.CONC_PROGRAM_ID,
                               FND_GLOBAL.CONC_REQUEST_ID
                              ,i.transaction_id
                              ,err_text
                              ,'ITEM_NUMBER'
                              ,'MTL_SYSTEM_ITEMS_INTERFACE'
                              ,'INV_IOI_NO_AUTO_NIR'
                              ,err_text);
      ELSIF (l_return_status <> FND_API.G_RET_STS_SUCCESS )THEN
        Error_Handler.Get_Message_List( x_message_list => l_error_table);
        UPDATE MTL_SYSTEM_ITEMS_INTERFACE
           SET process_flag = 3
         WHERE rowid       = i.rowid;

         dumm_status  := INVPUOPI.mtl_log_interface_err(
                               i.organization_id,
                               FND_GLOBAL.USER_ID,
                               FND_GLOBAL.LOGIN_ID,
                               FND_GLOBAL.PROG_APPL_ID,
                               FND_GLOBAL.CONC_PROGRAM_ID,
                               FND_GLOBAL.CONC_REQUEST_ID
                              ,i.transaction_id
                              ,l_error_table(1).message_text
                              ,'ITEM_CATALOG_GORUP_ID'
                              ,'MTL_SYSTEM_ITEMS_INTERFACE'
                              ,'INV_IOI_ERR'
                              ,err_text);
      ELSE
        UPDATE MTL_SYSTEM_ITEMS_INTERFACE
        SET CHANGE_ID = l_change_id
        WHERE rowid   = i.rowid;
      END IF;
    END LOOP;
    IF l_cursor_id IS NOT NULL THEN
     dbms_sql.close_cursor(l_cursor_id);
    END IF;
   END IF;

   EXCEPTION
     WHEN OTHERS THEN
          UPDATE MTL_SYSTEM_ITEMS_INTERFACE
            SET process_flag = 3
           WHERE set_process_id= p_set_process_id;


          IF l_inv_debug_level IN(101, 102) THEN
             INVPUTLI.info('INV_EGO_REVISION_VALIDATE.Create_New_Item_Request: Exception'||substr(SQLERRM,1,200));
          END IF;

          dumm_status  := INVPUOPI.mtl_log_interface_err(
                               null,--i.organization_id,
                               FND_GLOBAL.USER_ID,
                               FND_GLOBAL.LOGIN_ID,
                               FND_GLOBAL.PROG_APPL_ID,
                               FND_GLOBAL.CONC_PROGRAM_ID,
                               FND_GLOBAL.CONC_REQUEST_ID,
                               p_set_process_id--i.transaction_id
                              ,'CO NIR is having problem for this set proecess id'||p_set_process_id
                              ,'ITEM_CATALOG_GORUP_ID'
                              ,'MTL_SYSTEM_ITEMS_INTERFACE'
                              ,'INV_IOI_ERR'
                              ,err_text);
  END Create_New_Item_Request; */
------------------------------------------------------------------------------------------
  FUNCTION Get_Process_Control RETURN VARCHAR2 IS
  BEGIN
      IF ( G_PROCESS_CONTROL IS NOT NULL ) THEN
         RETURN (G_PROCESS_CONTROL);
      ELSE
         RETURN ('PLM_UI:N');
      END IF;
  END  Get_Process_Control;
------------------------------------------------------------------------------------------
  PROCEDURE Set_Process_Control(p_process_control VARCHAR2) IS
  BEGIN
     G_PROCESS_CONTROL := p_process_control;
  END  Set_Process_Control;
------------------------------------------------------------------------------------------

FUNCTION Get_Process_Control_HTML_API RETURN VARCHAR2 IS
     BEGIN
          RETURN (G_PROCESS_CONTROL_HTML_API);
     END  Get_Process_Control_HTML_API; /* Added to fix Bug#8434681*/


  PROCEDURE Set_Process_Control_HTML_API(p_process_control VARCHAR2) IS
     BEGIN
        G_PROCESS_CONTROL_HTML_API := p_process_control;
     END  Set_Process_Control_HTML_API;  /* Added to fix Bug#8434681*/

PROCEDURE Populate_Seq_Gen_Item_Nums
          (p_set_id           IN         NUMBER
          ,p_org_id           IN         NUMBER
          ,p_all_org          IN         NUMBER
          ,p_rec_status       IN         NUMBER
          ,x_return_status    OUT NOCOPY VARCHAR2
          ,x_msg_count        OUT NOCOPY NUMBER
          ,x_msg_data         OUT NOCOPY VARCHAR2) IS

  l_sql  VARCHAR2(1000);
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data := NULL;
  IF NOT (INV_Item_Util.g_Appl_Inst.EGO <> 0 AND
              INV_ITEM_UTIL.Object_Exists
                (p_object_type => 'PACKAGE'
                ,p_object_name => 'EGO_ITEM_BULKLOAD_PKG') ='Y') THEN
    -- EGO not installed here no need to do further processing
    RETURN;
  END IF;

  l_sql := ' BEGIN                                     '||
           '  EGO_ITEM_BULKLOAD_PKG.Populate_Seq_Gen_Item_Nums(  '||
           '    p_set_id         => :p_set_id,        '||
           '    p_org_id         => :p_org_id,        '||
           '    p_all_org        => :p_all_org,       '||
           '    p_rec_status     => :p_rec_status,    '||
           '    x_return_status  => :x_return_status, '||
           '    x_msg_count      => :x_msg_count,     '||
           '    x_msg_data       => :x_msg_data);     '||
           ' END; ';
  EXECUTE IMMEDIATE l_sql USING
    IN  p_set_id,
    IN  p_org_id,
    IN  p_all_org,
    IN  p_rec_status,
    OUT x_return_status,
    OUT x_msg_count,
    OUT x_msg_data;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count := 1;
    x_msg_data := SQLERRM;
END Populate_Seq_Gen_Item_Nums;

--Removed the procedure body for 5498078
--5208102 :Insert_Revision_UserAttr added
--Code is identical to Insert_Grants_And_UserAttr.
PROCEDURE Insert_Revision_UserAttr(P_Set_id  IN  NUMBER  DEFAULT -999) IS
BEGIN
   RETURN;
END Insert_Revision_UserAttr;

-- Bug: 5258295
FUNCTION mtl_catalog_group_update(
   p_rowid               IN   ROWID
  ,p_process_flag        IN   NUMBER --Added for R12C
  ,p_inventory_item_id   IN   NUMBER
  ,p_organization_id     IN   NUMBER
  ,p_old_item_cat_grp_id IN   NUMBER
  ,p_new_item_cat_grp_id IN   NUMBER
  ,p_approval_status     IN   VARCHAR2
  ,p_item_number         IN   VARCHAR2
  ,p_transaction_id      IN   NUMBER
  ,p_prog_appid          IN   NUMBER
  ,p_prog_id             IN   NUMBER
  ,p_request_id          IN   NUMBER
  ,p_xset_id             IN   NUMBER
  ,p_user_id             IN   NUMBER
  ,p_login_id            IN   NUMBER
  ,x_err_text   OUT NOCOPY VARCHAR2) RETURN INTEGER IS

   CURSOR c_get_nir_setup(cp_item_catalog_group_id IN NUMBER)  IS
      SELECT new_item_request_reqd
      FROM   mtl_item_catalog_groups_b
      WHERE  new_item_request_reqd IS NOT NULL
        AND  new_item_request_reqd <> 'I'
      CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
      START WITH item_catalog_group_id = cp_item_catalog_group_id
      ORDER BY LEVEL ASC;

   l_nir_status_type          NUMBER;
   l_nir_approval_status_type NUMBER;
   l_old_nir_change_type      NUMBER;
   l_new_nir_change_type      NUMBER;
   l_old_nir_reqd             VARCHAR2(1);
   l_old_item_cat_grp_id      NUMBER;
   l_new_nir_reqd             VARCHAR2(1);
   dumm_status                NUMBER;
   l_type_name                VARCHAR2(1000);
   l_error                    BOOLEAN;
   l_dynamic_sql              VARCHAR2(2000);
   l_error_msg                VARCHAR2(2000);
   l_dummy                    NUMBER;
   l_cursor_id                NUMBER;
   l_error_table              Error_Handler.Error_Tbl_Type;
   l_change_id                NUMBER;
   l_change_notice            VARCHAR2(100);
   l_return_status            VARCHAR2(10) := FND_API.G_RET_STS_SUCCESS;
   l_pk1_value                VARCHAR2(100);
   l_raise_create_nir         BOOLEAN := FALSE;
   l_raise_cancel_nir         BOOLEAN := FALSE;
   l_update_msb               BOOLEAN := FALSE;
   l_error_occured            BOOLEAN := FALSE;


BEGIN

      l_raise_create_nir := FALSE;
      l_raise_cancel_nir := FALSE;
      l_update_msb       := FALSE;

      IF l_cursor_id IS NULL THEN
         l_cursor_id   := DBMS_SQL.Open_Cursor;

         /* Bug 5253300 /5253294 Using Status Type Column from eng_change_statuses_vl corresponding to
            Status Code from eng_engineering_changes - Anmurali */
         l_dynamic_sql :=    'SELECT st.status_type
                                    ,ch.approval_status_type
                                    ,ch.change_id
                                    ,ch.change_notice
                              FROM   eng_engineering_changes ch
                                    ,eng_change_subjects sb
                                    ,eng_change_order_types_vl tp
                                    ,eng_change_statuses_vl st
                              WHERE tp.type_classification   = :l_type_classification
                              AND   tp.change_mgmt_type_code = :l_change_mgmt_type_code
                              AND   ch.change_mgmt_type_code = tp.change_mgmt_type_code
                              AND   ch.change_id             = sb.change_id
                              AND   sb.entity_name           = :l_entity_name
                              AND   st.status_code           = ch.status_code
                              AND   sb.pk1_value             = :l_inv_item_id
                              AND   sb.pk2_value             = :l_org_id';

         DBMS_SQL.Parse(l_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);
         DBMS_SQL.define_column(l_cursor_id,1,l_nir_status_type);
         DBMS_SQL.define_column(l_cursor_id,2,l_nir_approval_status_type);
         DBMS_SQL.define_column(l_cursor_id,3,l_change_id);
         DBMS_SQL.define_column(l_cursor_id,4,l_change_notice,100);
      END IF;

      DBMS_SQL.Bind_Variable(l_cursor_id, 'l_type_classification'  , 'CATEGORY');
      DBMS_SQL.Bind_Variable(l_cursor_id, 'l_change_mgmt_type_code', 'NEW_ITEM_REQUEST');
      DBMS_SQL.Bind_Variable(l_cursor_id, 'l_entity_name'          , 'EGO_ITEM');
      DBMS_SQL.Bind_Variable(l_cursor_id, 'l_inv_item_id'          , p_inventory_item_id);
      DBMS_SQL.Bind_Variable(l_cursor_id, 'l_org_id'               , p_organization_id);
      l_dummy := DBMS_SQL.EXECUTE(l_cursor_id);

      IF DBMS_SQL.fetch_rows(l_cursor_id) > 0 THEN
         dbms_sql.column_value(l_cursor_id,1,l_nir_status_type);
         dbms_sql.column_value(l_cursor_id,2,l_nir_approval_status_type);
         dbms_sql.column_value(l_cursor_id,3,l_change_id);
         dbms_sql.column_value(l_cursor_id,4,l_change_notice);
      END IF;

      OPEN  c_get_nir_setup (p_new_item_cat_grp_id);
      FETCH c_get_nir_setup INTO l_new_nir_reqd;
      CLOSE c_get_nir_setup;

      OPEN  c_get_nir_setup (p_old_item_cat_grp_id);
      FETCH c_get_nir_setup INTO l_old_nir_reqd;
      CLOSE c_get_nir_setup;

      IF l_old_nir_reqd = 'Y' THEN -- Originating ICC HAS NIR

         IF l_new_nir_reqd = 'Y' THEN -- If both originating and destination ICC HAS NIR

            IF  l_nir_status_type = 5
            AND l_nir_approval_status_type IN (1,4)
            AND p_approval_status IN ( 'N', 'R' )
            THEN

               l_raise_create_nir := TRUE;

            ELSIF (p_approval_status = 'N'
                   AND   l_nir_approval_status_type = 1
                   AND   l_nir_status_type  =  1)
            OR    (p_approval_status = 'S'
                   AND   l_nir_approval_status_type = 3
                   AND   l_nir_status_type  =  8)
            OR    (p_approval_status = 'A'
                   AND   l_nir_approval_status_type = 5
                   AND   l_nir_status_type  =  8)
         -- Added to handle the case of rejected items - Bug 5224208
            OR    (p_approval_status = 'R'
                   AND   l_nir_approval_status_type = 4
                   AND   l_nir_status_type  =  8)

            THEN

               l_raise_cancel_nir := TRUE;
               l_raise_create_nir := TRUE;

            END IF;

         ELSIF l_new_nir_reqd = 'N' THEN -- If the destination ICC does not have NIR

            IF  l_nir_status_type = 5
            AND l_nir_approval_status_type IN (1,4)
            AND p_approval_status IN ( 'N', 'R' )
            THEN
                  l_update_msb := TRUE;

            ELSIF (l_nir_status_type              = 1
                   AND l_nir_approval_status_type = 1
                   AND p_approval_status         = 'N' )
            OR    (p_approval_status             = 'S'
                   AND l_nir_approval_status_type = 3
                   AND l_nir_status_type          = 8)
         -- Added to handle the case of rejected items - Bug 5224213
            OR    (p_approval_status = 'R'
                   AND   l_nir_approval_status_type = 4
                   AND   l_nir_status_type  =  8)

            THEN

                 l_raise_cancel_nir := TRUE;
                 l_update_msb       := TRUE;

            ELSIF p_approval_status = 'A'
            AND   l_nir_approval_status_type = 5
            AND   l_nir_status_type  =  8
            THEN
               --Replacing the erroneous create call with cancel -5222730-Anmurali
               l_raise_cancel_nir := TRUE;
            END IF;
         END IF; --IF l_new_nir_reqd = 'Y' THEN
      END IF; --IF l_old_nir_reqd = 'Y' THEN

      l_error_occured := FALSE;

      IF l_raise_cancel_nir THEN
         --Changing the call as per signature change - R12 C
         Cancel_New_Item_Request(
                        p_inventory_item_id => p_inventory_item_id
                       ,p_organization_id   => p_organization_id
                       ,p_item_number       => p_item_number
                       ,p_auto_commit       => FND_API.G_FALSE
                       ,p_wf_user_id        => p_user_id
                       ,p_fnd_user_id       => p_login_id
                       ,x_return_status     => l_return_status );

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            l_error_occured := TRUE;

            UPDATE MTL_SYSTEM_ITEMS_INTERFACE
            SET process_flag = 3
            WHERE rowid      = p_rowid;

            dumm_status  := INVPUOPI.mtl_log_interface_err(
                                        p_organization_id,
                                        p_user_id,
                                        p_login_id,
                                        p_prog_appid,
                                        p_prog_id,
                                        p_request_id,
                                        p_transaction_id,
                                        l_error_msg,
                                        'ITEM_CATALOG_GORUP_ID',
                                        'MTL_SYSTEM_ITEMS_INTERFACE',
                                        'INV_IOI_CANCEL_NIR_FAILED',
                                         x_err_text);
         ELSIF (l_return_status <> FND_API.G_RET_STS_SUCCESS )THEN
            l_error_occured := TRUE;
            Error_Handler.Get_Message_List( x_message_list => l_error_table);

            UPDATE MTL_SYSTEM_ITEMS_INTERFACE
            SET process_flag = 3
            WHERE rowid      = p_rowid;

            dumm_status  := INVPUOPI.mtl_log_interface_err(
                                        p_organization_id,
                                        p_user_id,
                                        p_login_id,
                                        p_prog_appid,
                                        p_prog_id,
                                        p_request_id,
                                        p_transaction_id,
                                        l_error_table(1).message_text,
                                       'ITEM_CATALOG_GORUP_ID',
                                       'MTL_SYSTEM_ITEMS_INTERFACE',
                                       'INV_IOI_ERR',
                                        x_err_text);
         END IF;
      END IF; --IF l_raise_cancel_nir THEN

      IF l_raise_create_nir AND NOT l_error_occured THEN
         Create_New_Item_Req_Upd (p_row_id                 => p_rowid
                                 ,p_item_catalog_group_id  => p_new_item_cat_grp_id
                                 ,p_item_number            => p_item_number
                                 ,p_inventory_item_id      => p_inventory_item_id
                                 ,p_organization_id        => p_organization_id
                                 ,p_xset_id                => p_xset_id --Adding for R12 C
                                 ,p_process_flag           => p_process_flag
                                 ,x_return_status          => l_return_status);

         IF (l_return_status ='G' )THEN
            l_error_occured := TRUE;

            UPDATE MTL_SYSTEM_ITEMS_INTERFACE
            SET process_flag = 3
            WHERE rowid      = p_rowid;

            dumm_status  := INVPUOPI.mtl_log_interface_err(
                                      p_organization_id
                                     ,p_user_id
                                     ,p_login_id
                                     ,p_prog_appid
                                     ,p_prog_id
                                     ,p_request_id
                                     ,p_transaction_id
                                     ,l_error_msg
                                     ,'ITEM_NUMBER'
                                     ,'MTL_SYSTEM_ITEMS_INTERFACE'
                                     ,'INV_IOI_NO_AUTO_NIR'
                                     ,x_err_text);
         ELSIF (l_return_status <> FND_API.G_RET_STS_SUCCESS )THEN
            l_error_occured := TRUE;
            Error_Handler.Get_Message_List( x_message_list => l_error_table);
            UPDATE MTL_SYSTEM_ITEMS_INTERFACE
            SET process_flag = 3
            WHERE rowid      = p_rowid;

            dumm_status  := INVPUOPI.mtl_log_interface_err(
                                        p_organization_id
                                       ,p_user_id
                                       ,p_login_id
                                       ,p_prog_appid
                                       ,p_prog_id
                                       ,p_request_id
                                       ,p_transaction_id
                                       ,l_error_table(1).message_text
                                       ,'ITEM_CATALOG_GORUP_ID'
                                       ,'MTL_SYSTEM_ITEMS_INTERFACE'
                                       ,'INV_IOI_ERR'
                                       ,x_err_text);
         END IF;
      END IF; --IF l_raise_create_nir AND NOT l_error_occured THEN

      IF l_update_msb  AND NOT l_error_occured THEN
         UPDATE mtl_system_items_b
         SET approval_status     = 'A'
         WHERE inventory_item_id = p_inventory_item_id
         AND organization_id     = p_organization_id;
      END IF;

      IF l_cursor_id IS NOT NULL THEN
         dbms_sql.close_cursor(l_cursor_id);
      END IF;

      RETURN (0);

EXCEPTION
   WHEN OTHERS THEN
      IF l_cursor_id IS NOT NULL THEN
         dbms_sql.close_cursor(l_cursor_id);
      END IF;
      RETURN(SQLCODE);
END mtl_catalog_group_update;


--Changing signature for R12 C
PROCEDURE Cancel_New_Item_Request (     p_inventory_item_id IN NUMBER,
                                        p_organization_id   IN NUMBER,
                                        p_item_number       IN VARCHAR2,
                                        p_auto_commit IN VARCHAR2,
                                        p_wf_user_id IN NUMBER,
                                        p_fnd_user_id IN NUMBER,
                                        x_return_status OUT NOCOPY VARCHAR2 )
  IS

   dumm_status          NUMBER;
   l_translated_text    fnd_new_messages.message_text%TYPE;
   l_nir_cancel_status  VARCHAR2(10);

  BEGIN

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      dumm_status := INVUPD2B.get_message('EGO_NIR_CANCEL_COMMENT', l_translated_text);

      ENG_NIR_UTIL_PKG.Cancel_nir_for_item(
                   p_item_id           => p_inventory_item_id
                  ,p_org_id            => p_organization_id
--                ,p_item_number       => p_item_number
                  ,p_auto_commit       => p_auto_commit
--                ,p_mode              => 'CANCEL'
                  ,p_wf_user_id        => p_wf_user_id
                  ,p_fnd_user_id       => p_fnd_user_id
                  ,p_cancel_comments   => l_translated_text
                  ,x_nir_cancel_status => l_nir_cancel_status);

   /* EXECUTE IMMEDIATE
               ' BEGIN                                               '
             ||'   ENG_NIR_UTIL_PKG.Cancel_NIR(                      '
             ||'      p_change_id         => :p_change_id            '
             ||'     ,p_org_id            => :p_org_id               '
             ||'     ,p_change_notice     => :p_change_notice        '
             ||'     ,p_auto_commit       => :p_auto_commit          '
             ||'     ,p_wf_user_id        => :p_wf_user_id           '
             ||'     ,p_fnd_user_id       => :p_fnd_user_id          '
             ||'     ,p_cancel_comments   => :l_translated_text      '
             ||'     ,x_nir_cancel_status => :l_nir_cancel_status);  '
             ||' EXCEPTION                                           '
             ||'    WHEN OTHERS THEN                                 '
             ||'      NULL;                                          '
             ||' END;                                                '
           USING IN  p_change_id,
                 IN  p_org_id,
                 IN  p_change_notice,
       IN  p_auto_commit,
       IN  p_wf_user_id,
       IN  p_fnd_user_id,
       IN  l_translated_text,
       OUT l_nir_cancel_status; */
  EXCEPTION
     WHEN others THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       INVPUTLI.info('INV_EGO_REVISION_VALIDATE.Cancel_NIR: Exception'||substr(SQLERRM,1,200));
  END Cancel_New_Item_Request;

/* Obsoleting this procedure and recreating it below with new NIR create signature for R12 FPC
  PROCEDURE Create_New_Item_Req_Upd ( p_item_catalog_group_id IN NUMBER,
                                      p_item_number           IN VARCHAR2,
                  p_inventory_item_id     IN NUMBER,
                  p_organization_id       IN NUMBER,
                  x_return_status OUT NOCOPY VARCHAR2 )
  IS
     l_type_name     VARCHAR2(1000);
     l_type_id       NUMBER;
     l_org_code      VARCHAR2(10);
     l_dynamic_sql   VARCHAR2(2000);
     l_dummy         NUMBER;
     l_cursor_id     NUMBER;
     l_error_table   Error_Handler.Error_Tbl_Type;
     l_return_status VARCHAR2(10) := FND_API.G_RET_STS_SUCCESS;
  BEGIN

     SELECT organization_code INTO l_org_code
       FROM mtl_parameters
      WHERE organization_id = p_organization_id;

     SELECT new_item_req_change_type_id INTO l_type_id
       FROM mtl_item_catalog_groups_b
      WHERE item_catalog_group_id = p_item_catalog_group_id;

      UPDATE MTL_SYSTEM_ITEMS_B
         SET INVENTORY_ITEM_STATUS_CODE='Pending'
             ,APPROVAL_STATUS  = 'N'
             ,CURRENT_PHASE_ID = DECODE(LIFECYCLE_ID,NULL,NULL,Get_Initial_Lifecycle_Phase(LIFECYCLE_ID))
       WHERE INVENTORY_ITEM_ID = p_inventory_item_id
         AND ORGANIZATION_ID   = p_organization_id;

      IF l_cursor_id IS NULL THEN
         l_cursor_id := DBMS_SQL.Open_Cursor;
         l_dynamic_sql := 'select type_name from eng_change_order_types_vl '||
                          'where change_order_type_id = :type_id ';
         DBMS_SQL.Parse(l_cursor_id, l_dynamic_sql, DBMS_SQL.NATIVE);
         DBMS_SQL.define_column(l_cursor_id,1,l_type_name,1000);
      END IF;
      DBMS_SQL.Bind_Variable(l_cursor_id, 'type_id', l_type_id);
      l_dummy := DBMS_SQL.Execute(l_cursor_id);
      IF DBMS_SQL.fetch_rows(l_cursor_id) > 0 THEN
        dbms_sql.column_value(l_cursor_id,1,l_type_name);
        EXECUTE IMMEDIATE
               ' BEGIN                                               '
             ||'   ENG_NEW_ITEM_REQ_UTIL.Create_New_Item_Request(    '
             ||'      change_number       => :p_item_number          '
             ||'     ,change_name         => :p_item_number          '
             ||'     ,change_type_code    => :l_type_code            '
             ||'     ,item_number         => :p_item_number          '
             ||'     ,organization_code   => :l_org_code             '
             ||'     ,requestor_user_name => FND_GLOBAL.USER_NAME    '
             ||'     ,X_RETURN_STATUS     => :l_return_status    );  '
             ||' EXCEPTION                                           '
             ||'    WHEN OTHERS THEN                                 '
             ||'      NULL;                                          '
             ||' END;                                                '
           USING IN  p_item_number,
                 IN  l_type_name,
                 IN  l_org_code,
                 OUT l_return_status;
      ELSE
        l_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      x_return_status := l_return_status;
      IF l_cursor_id IS NOT NULL THEN
         dbms_sql.close_cursor(l_cursor_id);
      END IF;
  EXCEPTION
    WHEN others THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF l_cursor_id IS NOT NULL THEN
         dbms_sql.close_cursor(l_cursor_id);
      END IF;
      INVPUTLI.info('INV_EGO_REVISION_VALIDATE.Create_New_Item_Request: Exception'||substr(SQLERRM,1,200));
  END Create_New_Item_Req_Upd; */
-- End : 5258295

  PROCEDURE Create_New_Item_Req_Upd ( p_row_id                IN ROWID,
                                      p_item_catalog_group_id IN NUMBER,
                                      p_item_number           IN VARCHAR2,
                                      p_inventory_item_id     IN NUMBER,
                                      p_organization_id       IN NUMBER,
                                      p_xset_id               IN NUMBER,
                                      p_process_flag          IN NUMBER,
                                      x_return_status        OUT NOCOPY VARCHAR2 )
  IS
    l_return_status VARCHAR2(1);
    l_err_text VARCHAR2(1000);
    l_msg_count NUMBER;
    l_inv_debug_level   NUMBER := INVPUTLI.get_debug_level;  --Bug: 4667452
    l_proc_flag NUMBER;
  BEGIN
    UPDATE MTL_SYSTEM_ITEMS_B
       SET INVENTORY_ITEM_STATUS_CODE='Pending'
          ,APPROVAL_STATUS  = 'N'
          ,CURRENT_PHASE_ID = DECODE(LIFECYCLE_ID,NULL,NULL,Get_Initial_Lifecycle_Phase(LIFECYCLE_ID))
     WHERE INVENTORY_ITEM_ID = p_inventory_item_id
       AND ORGANIZATION_ID   = p_organization_id;

    UPDATE mtl_system_items_interface
       SET process_flag = 5
     WHERE rowid = p_row_id;

    ENG_NEW_ITEM_REQ_UTIL.Create_New_Item_Requests( p_batch_id      => p_xset_id
                                                   ,p_nir_option    => 'I'
                                                   ,x_return_status => l_return_status
                                                   ,x_msg_data      => l_err_text
                                                   ,x_msg_count     => l_msg_count);

    x_return_status := l_return_status;

    IF (l_return_status = FND_API.G_RET_STS_SUCCESS )THEN
        UPDATE mtl_system_items_interface
           SET process_flag = p_process_flag
         WHERE rowid = p_row_id;
    ELSE
        IF l_inv_debug_level IN(101, 102) THEN
           INVPUTLI.info('INV_EGO_REVISION_VALIDATE.Create_New_Item_Request: Following exception from CM during NIR creation');
           INVPUTLI.info(l_err_text);
        END IF;

        UPDATE mtl_system_items_interface
           SET process_flag = 3,
               change_id = NULL,
               change_line_id = NULL
         WHERE rowid = p_row_id;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
       IF l_inv_debug_level IN(101, 102) THEN
          INVPUTLI.info('INV_EGO_REVISION_VALIDATE.Create_New_Item_Request: Exception'||substr(SQLERRM,1,200));
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       UPDATE mtl_system_items_interface
          SET process_flag = 3,
              change_id = NULL,
              change_line_id = NULL
        WHERE rowid = p_row_id;

 END Create_New_Item_Req_Upd;

 --Removed the procedure body for 5498078
 --Added for bug 5435229
 PROCEDURE apply_default_uda_values(P_Set_id  IN  NUMBER  DEFAULT -999,p_commit  IN NUMBER DEFAULT 1) IS /* Added to fix Bug#7422423*/
l_err_bug    VARCHAR2(1000); /* Added to fix Bug#8434681*/
l_ret_code   VARCHAR2(1000); /* Added to fix Bug#8434681*/
l_commit_flag VARCHAR2(1) ; /* Added to fix Bug#7422423*/
  BEGIN
    /* Added to fix Bug#8434681: Make sure template is not applied for HTML pages. This is because the template is pre-applied using java code in HTML pages.
    However, the template must be applied if code is being called from 1. open API, 2.excel import, 3.concurrent request (import items batch) */
        IF (INSTR(NVL(G_PROCESS_CONTROL,'PLM_UI:N'),'PLM_UI:Y') <> 0 AND
             SUBSTR(NVL(G_PROCESS_CONTROL_HTML_API,'HTML'),1,3) <> 'API')
        THEN

     return;
END IF;

        INVPUTLI.info('Start : INV_EGO_REVISION_VALIDATE.apply_default_uda_values');
        IF  SUBSTR(NVL(G_PROCESS_CONTROL,'SSSSSS'),1,6) <> 'NO_NIR'
        AND NVL(G_PROCESS_CONTROL,'SSSSSS') NOT IN ('EGO_XL_IMPORT_ITEM1','EGO_XL_IMPORT_ITEM2','EGO_XL_IMPORT_ITEM3')
        THEN
        --   commit;  /* Commented to fix Bug#7422423*/
	   /* Bug 8275121. Pass the parameter p_validate_only as FND_API.G_TRUE to validate Item Associations against both
              EGO_ITEM_ASSOCIATIONS and EGO_ITEM_ASSOCIATIONS_INTF tables, in the function
              EGO_ITEM_USER_ATTRS_CP_PUB.Process_Item_User_Attrs_Data(). */

           /* Bug 9336604 - Commenting the below call since EGO_ITEM_USER_ATTRS_CP_PUB.Process_Item_User_Attrs_Data
		does not handle templates in 12.1 code
	   EGO_ITEM_USER_ATTRS_CP_PUB.Process_Item_User_Attrs_Data(
              ERRBUF        => l_err_bug
             ,RETCODE       => l_err_bug
             ,p_data_set_id => P_Set_id
	     ,p_validate_only => FND_API.G_TRUE
	     ,p_commit => l_commit_flag ); */ -- Bug 9336604  /* Added to fix Bug#7422423*/

	     NULL; -- Bug 9336604

        END IF;
        INVPUTLI.info('End   : INV_EGO_REVISION_VALIDATE.apply_default_uda_values');
     EXCEPTION
        WHEN OTHERS THEN
           NULL; -- Donot propogate any error message.
           INVPUTLI.info('INV_EGO_REVISION_VALIDATE.apply_default_uda_values: Exception'||substr(SQLERRM,1,200));

  END apply_default_uda_values;

 --  ============================================================================
 --  API Name    : validate_style_sku
 --  Description : This procedure will be called from IOI
 --                (after all other validations, including lifecycle and phase)
 --                to validate the Style/SKU attributes of the item.
 --  ============================================================================

 FUNCTION validate_style_sku  (P_Row_Id IN ROWID,
                               P_Xset_id IN NUMBER,
                               X_Err_Text IN OUT NOCOPY VARCHAR2)
 RETURN INTEGER IS

    CURSOR c_interface_row (cp_row_id IN ROWID)
    IS
       SELECT item_catalog_group_id,
              style_item_id,
              style_item_flag,
              gdsn_outbound_enabled_flag,
              inventory_item_id,
              organization_id,
              transaction_type,
              request_id,
              transaction_id
         FROM mtl_system_items_interface
        WHERE rowid = cp_row_id;

    CURSOR c_master_org (cp_organization_id IN NUMBER)
    IS
       SELECT master_organization_id
         FROM mtl_parameters
        WHERE organization_id = cp_organization_id;

    CURSOR c_get_existing_item_details (Cp_inventory_item_id IN NUMBER,
                                        Cp_organization_id IN NUMBER)
    IS
       SELECT style_item_flag,style_item_id,
              item_catalog_group_id
         FROM mtl_system_items_b
        WHERE inventory_item_id = cp_inventory_item_id
          AND organization_id = cp_organization_id;

    l_user_id  NUMBER := FND_GLOBAL.User_Id;
    l_login_id NUMBER := FND_GLOBAL.Login_Id;
    l_Prog_Appl_Id NUMBER := FND_GLOBAL.Prog_Appl_Id;
    l_conc_prog_id NUMBER := FND_GLOBAL.Conc_program_id;

    l_msii_icc_id NUMBER;
    l_msi_icc_id NUMBER;
    l_msii_style_item_flag VARCHAR2(1);
    l_msii_style_item_id NUMBER;
    l_msii_inv_item_id NUMBER;
    l_msii_org_id NUMBER;
    l_transaction_type VARCHAR2(10);
    l_transaction_id NUMBER;
    l_request_id NUMBER;
    l_msi_style_item_flag VARCHAR2(1);
    l_msi_style_item_id NUMBER;
    l_error_logged NUMBER;
    l_err_text   VARCHAR2(1000);
    l_valid_icc NUMBER;
    l_style_icc_id NUMBER;
    l_sku_variant BOOLEAN;
    l_inv_debug_level NUMBER := INVPUTLI.get_debug_level;  --Bug: 4667452
    l_error_exists NUMBER := 0;
    l_null_icc_id NUMBER := -1;
    l_sku_exists NUMBER;
    l_master_org  NUMBER;
    l_msii_gdsn_flag VARCHAR2(1);
    l_var_attrs_missing BOOLEAN;

 BEGIN
    OPEN  c_interface_row  (cp_row_id => P_Row_Id);
    FETCH c_interface_row INTO l_msii_icc_id, l_msii_style_item_id,l_msii_style_item_flag,
                               l_msii_gdsn_flag, l_msii_inv_item_id, l_msii_org_id,
                               l_transaction_type, l_request_id, l_transaction_id;
    CLOSE c_interface_row;

    OPEN  c_master_org(cp_organization_id => l_msii_org_id);
    FETCH c_master_org INTO l_master_org;
    CLOSE c_master_org;

    OPEN  c_get_existing_item_details (Cp_inventory_item_id => l_msii_inv_item_id,
                                      Cp_organization_id => l_msii_org_id);
    FETCH c_get_existing_item_details INTO l_msi_style_item_flag,l_msi_style_item_id,l_msi_icc_id;
    CLOSE c_get_existing_item_details;

    IF l_inv_debug_level IN(101, 102) THEN
       INVPUTLI.info('MSII ICC ID ' ||l_msii_icc_id ||' MSI ICC ID ' ||l_msi_icc_id);
    END IF;

    IF l_msii_icc_id IS NULL THEN
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVEGRVB.validate_style_sku: ICC is mandatory');
      END IF;
      l_error_logged := INVPUOPI.mtl_log_interface_err( l_msii_org_id,
                                                        l_User_Id,
                                                        l_Login_Id,
                                                        l_Prog_Appl_Id,
                                                        l_Conc_prog_id,
                                                        l_request_id,
                                                        l_transaction_id,
                                                        l_err_text,
                                                        'ITEM_CATALOG_GROUP_ID',
                                                        'MTL_SYSTEM_ITEMS_INTERFACE',
                                                        'INV_STYLE_SKU_REQUIRED_ICC',
                                                         X_Err_Text);
      l_error_exists := 1;
    END IF;

    /* The Style/SKU status of the item cannot be updated - Sec 2.5.1 - Condition 1*/
    IF ((l_transaction_type = 'UPDATE') AND (l_msii_style_item_flag <> l_msi_style_item_flag))
    THEN
        IF l_inv_debug_level IN(101, 102) THEN
           INVPUTLI.info('INVEGRVB.validate_style_sku: Cannot update Style Item Flag ');
        END IF;
        l_error_logged := INVPUOPI.mtl_log_interface_err( l_msii_org_id,
                                                          l_User_Id,
                                                          l_Login_Id,
                                                          l_Prog_Appl_Id,
                                                          l_Conc_prog_id,
                                                          l_request_id,
                                                          l_transaction_id,
                                                          l_err_text,
                                                          'STYLE_ITEM_FLAG',
                                                          'MTL_SYSTEM_ITEMS_INTERFACE',
                                                          'INV_STYLE_SKU_NOT_UPD',
                                                           X_Err_Text);
        l_error_exists := 1;
    END IF;

    /* The Style Item for a given SKU item cannot be updated - Sec 2.5.1 - Condition 1.1*/
    IF (l_transaction_type = 'UPDATE') AND (l_msii_style_item_id <> l_msi_style_item_id)
    THEN
        IF l_inv_debug_level IN(101, 102) THEN
           INVPUTLI.info('INVEGRVB.validate_style_sku: Cannot update Style Item Id ');
        END IF;
        l_error_logged := INVPUOPI.mtl_log_interface_err( l_msii_org_id,
                                                          l_User_Id,
                                                          l_Login_Id,
                                                          l_Prog_Appl_Id,
                                                          l_Conc_prog_id,
                                                          l_request_id,
                                                          l_transaction_id,
                                                          l_err_text,
                                                          'STYLE_ITEM_FLAG',
                                                          'MTL_SYSTEM_ITEMS_INTERFACE',
                                                          'INV_STYLE_ID_NOT_UPD',
                                                           X_Err_Text);
        l_error_exists := 1;
    END IF;

    --Bug 6161263: Adding validation to disallow the creation/updation of GDSN Syndicated Style items
    IF (l_msii_style_item_flag = 'Y' AND l_msii_gdsn_flag = 'Y') THEN
        IF l_inv_debug_level IN(101, 102) THEN
           INVPUTLI.info('INVEGRVB.validate_style_sku: Style Item cannot be GDSN SYndicated ');
        END IF;
        l_error_logged := INVPUOPI.mtl_log_interface_err( l_msii_org_id,
                                                          l_User_Id,
                                                          l_Login_Id,
                                                          l_Prog_Appl_Id,
                                                          l_Conc_prog_id,
                                                          l_request_id,
                                                          l_transaction_id,
                                                          l_err_text,
                                                          'STYLE_ITEM_FLAG',
                                                          'MTL_SYSTEM_ITEMS_INTERFACE',
                                                          'INV_STYLE_NOT_GDSN',
                                                           X_Err_Text);
        l_error_exists := 1;
    END IF;

    IF ((l_transaction_type = 'CREATE')OR
        (l_transaction_type = 'UPDATE' AND NVL(l_msi_icc_id,l_null_icc_id) <> NVL(l_msii_icc_id,l_null_icc_id)) )THEN
     /* Styles to be created in only those ICCs that contain Variant AGs - Sec 2.5.1 -Condition 2 */
       IF l_msii_style_item_flag = 'Y' THEN
          SELECT COUNT(*) INTO l_sku_exists
            FROM mtl_system_items_b
           WHERE style_item_id = l_msii_inv_item_id
             AND organization_id = l_msii_org_id;

          IF l_sku_exists <> 0 THEN
             l_error_logged := INVPUOPI.mtl_log_interface_err( l_msii_org_id,
                                                               l_User_Id,
                                                               l_Login_Id,
                                                               l_Prog_Appl_Id,
                                                               l_Conc_prog_id,
                                                               l_request_id,
                                                               l_transaction_id,
                                                               l_err_text,
                                                              'ITEM_CATALOG_GROUP_ID',
                                                              'MTL_SYSTEM_ITEMS_INTERFACE',
                                                              'INV_STYLE_ICC_SKU_EXISTS',
                                                               X_Err_Text);
             l_error_exists := 1;
          ELSE
            -- Modifying query to take inherited attribute groups into account
            SELECT count(*) INTO l_valid_icc
              FROM ego_obj_attr_grp_assocs_v
             WHERE variant  = 'Y'
               AND classification_code IN ( SELECT to_char(item_catalog_group_id)
                                              FROM mtl_item_catalog_groups_b
                                            CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
                                            START WITH item_catalog_group_id = l_msii_icc_id );

            IF l_valid_icc = 0 THEN
               IF l_inv_debug_level IN(101, 102) THEN
                  INVPUTLI.info('INVEGRVB.validate_style_sku: Invalid ICC ');
               END IF;
               l_error_logged := INVPUOPI.mtl_log_interface_err( l_msii_org_id,
                                                                 l_User_Id,
                                                                 l_Login_Id,
                                                                 l_Prog_Appl_Id,
                                                                 l_Conc_prog_id,
                                                                 l_request_id,
                                                                 l_transaction_id,
                                                                 l_err_text,
                                                                'ITEM_CATALOG_GROUP_ID',
                                                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                                                'INV_STYLE_INVALID_ICC',
                                                                 X_Err_Text);
               l_error_exists := 1;
            ELSE
              --Added condition to avoid entry twice, from INVNIRIB and INVPVALB
              IF ((l_transaction_type = 'CREATE') AND
                  (p_xset_id < 3000000000000 AND p_xset_id <> 3000000000000-999) AND
                  (l_msii_org_id = l_master_org) )THEN
                   l_error_logged := EGO_STYLE_SKU_ITEM_PVT.Default_Style_Variant_Attrs(
                                               p_inventory_item_id => l_msii_inv_item_id,
                                               p_item_catalog_group_id => l_msii_icc_id,
                                               x_err_text => l_err_text );
                   IF l_error_logged <> 0 THEN
                      l_error_logged := INVPUOPI.mtl_log_interface_err(
                                                                 l_msii_org_id,
                                                                 l_User_Id,
                                                                 l_Login_Id,
                                                                 l_Prog_Appl_Id,
                                                                 l_Conc_prog_id,
                                                                 l_request_id,
                                                                 l_transaction_id,
                                                                 l_err_text,
                                                                'ITEM_CATALOG_GROUP_ID',
                                                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                                                'INV_IOI_ERR',
                                                                 X_Err_Text);
                      l_error_exists := 1;
                   END IF; --Create
              END IF; --Valid ICC
            END IF; --SKU does not exist
          END IF; --Style Item
       ELSE
         BEGIN
           SELECT item_catalog_group_id INTO l_style_icc_id
             FROM mtl_system_items_b
            WHERE inventory_item_id = l_msii_style_item_id
              AND organization_id = l_msii_org_id;
         EXCEPTION
           WHEN no_data_found THEN
             Null;
         END;
        /* SKUs and their corresponding Styles must belong to the same ICC - Sec 2.5.1 -Condition 3 */
         IF l_style_icc_id IS NULL OR l_style_icc_id <> l_msii_icc_id THEN
            IF l_inv_debug_level IN(101, 102) THEN
               INVPUTLI.info('INVEGRVB.validate_style_sku: SKU and Style must belong to same ICC ');
            END IF;
            l_error_logged := INVPUOPI.mtl_log_interface_err (l_msii_org_id,
                                                              l_User_Id,
                                                              l_Login_Id,
                                                              l_Prog_Appl_Id,
                                                              l_Conc_prog_id,
                                                              l_request_id,
                                                              l_transaction_id,
                                                              l_err_text,
                                                              'ITEM_CATALOG_GROUP_ID',
                                                              'MTL_SYSTEM_ITEMS_INTERFACE',
                                                              'INV_SKU_INVALID_ICC',
                                                               X_Err_Text);
            l_error_exists := 1;
         END IF;
     END IF;
   END IF;

   IF (l_error_exists <> 1 AND l_msii_style_item_flag = 'N' AND
        (l_transaction_type = 'CREATE'
              OR (l_transaction_type = 'UPDATE' AND l_msii_style_item_flag = 'N' AND l_msi_style_item_flag IS NULL) --bug 6345529
      )
       AND l_msii_org_id = l_master_org )THEN
    /* The Variant attribute combination for SKU items must be unique - Sec 2.5.1 -Condition 8 */
      --Added condition to avoid entry twice, from INVNIRIB and INVPVALB
      IF (p_xset_id < 3000000000000 AND p_xset_id <> 3000000000000-999) THEN
          l_error_logged  := EGO_STYLE_SKU_ITEM_PVT.Validate_SKU_Variant_Usage (
                                                                     p_intf_row_id => P_Row_Id
                                                                    ,x_sku_exists  => l_sku_variant
                                                                    ,x_err_text    => l_err_text
     							            ,x_var_attrs_missing => l_var_attrs_missing);
          IF l_sku_variant THEN
             l_error_logged := INVPUOPI.mtl_log_interface_err( l_msii_org_id,
                                                           l_User_Id,
                                                           l_Login_Id,
                                                           l_Prog_Appl_Id,
                                                           l_Conc_prog_id,
                                                           l_request_id,
                                                           l_transaction_id,
                                                           l_err_text,
                                                           'VARIANT_ATTRIBUTE_COMB',
                                                           'MTL_SYSTEM_ITEMS_INTERFACE',
                                                           'INV_SKU_VAR_NO_UNIQUE',
                                                            X_Err_Text);
             l_error_exists := 1;
          ELSIF l_error_logged <> 0 THEN
             l_error_logged := INVPUOPI.mtl_log_interface_err( l_msii_org_id,
                                                            l_User_Id,
                                                            l_Login_Id,
                                                            l_Prog_Appl_Id,
                                                            l_Conc_prog_id,
                                                            l_request_id,
                                                            l_transaction_id,
                                                            l_err_text,
                                                            'VARIANT_ATTRIBUTE_COMB',
                                                            'MTL_SYSTEM_ITEMS_INTERFACE',
                                                            'INV_IOI_ERR',
                                                             X_Err_Text);
             l_error_exists := 1;
          ELSIF l_var_attrs_missing = TRUE THEN
             l_error_logged := INVPUOPI.mtl_log_interface_err( l_msii_org_id,
                                                            l_User_Id,
                                                            l_Login_Id,
                                                            l_Prog_Appl_Id,
                                                            l_Conc_prog_id,
                                                            l_request_id,
                                                            l_transaction_id,
                                                            l_err_text,
                                                            'VARIANT_ATTRIBUTE_COMB',
                                                            'MTL_SYSTEM_ITEMS_INTERFACE',
                                                            'INV_SKU_VAR_ATTR_MISSING',
                                                             X_Err_Text);
             l_error_exists := 1;
          END IF;
      END IF;
   END IF;

   IF l_error_exists = 1 THEN
      UPDATE mtl_system_items_interface
         SET process_flag = 3
       WHERE rowid = p_row_id;
   END IF;

   RETURN(0);

 EXCEPTION
   WHEN others THEN
     INVPUTLI.info('INVEGRVB.validate_style_sku: Exception '||SQLERRM);
     RETURN(SQLCODE);

 END validate_style_sku;

--  ============================================================================
--  API Name    : Check_Org_Access
--  Description : This procedure will be called from IOI to check if org_access_view
--                has this org
--  ============================================================================
FUNCTION Check_Org_Access (p_org_id    IN NUMBER)
RETURN VARCHAR2 IS

CURSOR c_check_org_access (p_org_id    IN NUMBER) IS
    SELECT 'X'
    FROM ORG_ACCESS_VIEW
    WHERE ORGANIZATION_ID = p_org_id
    AND RESPONSIBILITY_ID = FND_GLOBAL.RESP_ID
    AND RESP_APPLICATION_ID = FND_GLOBAL.RESP_APPL_ID;

 l_has_access VARCHAR2(1) := 'T';
 l_exists VARCHAR2(1);

  BEGIN

  OPEN   c_check_org_access(p_org_id);
  FETCH   c_check_org_access INTO l_exists;
  IF (c_check_org_access%NOTFOUND ) THEN
       l_has_access := 'F';
  END IF;
  CLOSE  c_check_org_access;

 RETURN(l_has_access);

 EXCEPTION WHEN OTHERS THEN
      IF c_check_org_access%ISOPEN THEN
      CLOSE c_check_org_access;
      END IF;
      INVPUTLI.info('INVEGRVB.Check_Org_Access '||SQLERRM);
      RETURN(SQLCODE);

END Check_Org_Access;

END INV_EGO_REVISION_VALIDATE;

/
