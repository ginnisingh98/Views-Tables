--------------------------------------------------------
--  DDL for Package Body EGO_ITEM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_ITEM_PVT" AS
/* $Header: EGOVITMB.pls 120.33.12010000.15 2010/07/15 07:18:35 nendrapu ship $ */

                      -----------------------
                      -- Private Data Type --
                      -----------------------

    TYPE LOCAL_MEDIUM_VARCHAR_TABLE IS TABLE OF VARCHAR2(4000)
      INDEX BY BINARY_INTEGER;

-- =============================================================================
--                         Package constants and cursors
-- =============================================================================

   G_FILE_NAME          CONSTANT  VARCHAR2(12)  := 'EGOVITMB.pls';
   G_PKG_NAME           CONSTANT  VARCHAR2(30)  := 'EGO_ITEM_PVT';
   G_APP_NAME           CONSTANT  VARCHAR2(3)   := 'EGO';
   G_PKG_NAME_TOKEN     CONSTANT  VARCHAR2(8)   := 'PKG_NAME';
   G_API_NAME_TOKEN     CONSTANT  VARCHAR2(8)   := 'API_NAME';
   G_PROC_NAME_TOKEN    CONSTANT  VARCHAR2(9)   := 'PROC_NAME';
   G_SQL_ERR_MSG_TOKEN  CONSTANT  VARCHAR2(11)  := 'SQL_ERR_MSG';
   G_PLSQL_ERR          CONSTANT  VARCHAR2(17)  := 'EGO_PLSQL_ERR';
   G_INVALID_PARAMS_MSG CONSTANT  VARCHAR2(30)  := 'EGO_API_INVALID_PARAMS';

   G_EQ_VAL        CONSTANT  VARCHAR2(2) := 'EQ';
   G_GT_VAL        CONSTANT  VARCHAR2(2) := 'GT';
   G_GE_VAL        CONSTANT  VARCHAR2(2) := 'GE';
   G_LT_VAL        CONSTANT  VARCHAR2(2) := 'LT';
   G_LE_VAL        CONSTANT  VARCHAR2(2) := 'LE';

   G_TRUE          CONSTANT  VARCHAR2(1) := 'T'; -- FND_API.G_TRUE;
   G_FALSE         CONSTANT  VARCHAR2(1) := 'F'; -- FND_API.G_FALSE;

   G_EGO_ITEM                CONSTANT  VARCHAR2(20) := 'EGO_ITEM';
   G_HZ_USER_PARTY_TYPE      CONSTANT  VARCHAR2(20) := 'PERSON';
   G_HZ_COMPANY_PARTY_TYPE   CONSTANT  VARCHAR2(20) := 'ORGANIZATION';

   -- data securiry functions
   G_FN_NAME_ADD_ROLE        CONSTANT  VARCHAR2(50) := 'EGO_ADD_ITEM_PEOPLE';
   G_FN_NAME_PROMOTE         CONSTANT  VARCHAR2(50) := 'EGO_PRO_ITEM_LIFE_CYCLE';
   G_FN_NAME_DEMOTE          CONSTANT  VARCHAR2(50) := 'EGO_DEM_ITEM_LIFE_CYCLE';
   G_FN_NAME_CHANGE_STATUS   CONSTANT  VARCHAR2(50) := 'EGO_EDIT_ITEM_STATUS';
   G_FN_NAME_EDIT_LC_PROJ    CONSTANT  VARCHAR2(50) := 'EGO_CREATE_ITEM_LC_TRACK_PROJ';

   -- functional securiry functions
   G_FN_NAME_ADMIN           CONSTANT  VARCHAR2(50) := 'EGO_ITEM_ADMINISTRATION';

   TYPE DYNAMIC_CUR IS REF CURSOR;

-- =============================================================================
--                         Package variables
-- =============================================================================

   ------------------- BEGIN Bug 6531908: Cached user information --------------

   g_username               VARCHAR2(100);
   g_party_id               VARCHAR2(30);

   --------------------- END Bug 6531908 ---------------------------------------


-- =============================================================================
--                 Private Procedures
-- =============================================================================

-- ----------------------
--
-- Developer debugging
-- ----------------------
PROCEDURE code_debug (p_msg  IN  VARCHAR2) IS
--PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   --insert into xx_debug  values ( p_msg);
   --commit;

  RETURN;
EXCEPTION
  WHEN OTHERS THEN
  NULL;
END code_debug;

------------------------------------------
--
-- Check validation of start date
-- in context with the end date passed
--
 ------------------------------------------
FUNCTION date_check (p_start_date  IN DATE
                    ,p_end_date    IN DATE
                    ,p_validation_type IN VARCHAR2
                    ) RETURN BOOLEAN IS
BEGIN
  IF p_validation_type NOT IN
       (G_EQ_VAL
       ,G_GT_VAL
       ,G_GE_VAL
       ,G_LT_VAL
       ,G_LE_VAL
       ) THEN
    RETURN FALSE;
  END IF;
  IF p_validation_type = G_EQ_VAL THEN
    IF ( (p_start_date IS NULL AND p_end_date IS NULL)
          OR
          (p_start_date = p_end_date)
       ) THEN
      RETURN TRUE;
    END IF;
  ELSIF p_validation_type = G_GT_VAL THEN
    IF (p_end_date IS NOT NULL AND NVL(p_start_date,p_end_date+1)>p_end_date) THEN
      RETURN TRUE;
    END IF;
  ELSIF p_validation_type = G_GE_VAL THEN
    IF ( (p_start_date IS NULL AND p_end_date IS NULL )
          OR
         (p_end_date IS NOT NULL AND NVL(p_start_date,p_end_date)>=p_end_date)
       ) THEN
      RETURN TRUE;
    END IF;
  ELSIF p_validation_type = G_LT_VAL THEN
    IF (p_start_date IS NOT NULL AND p_start_date < NVL(p_end_date,p_start_date+1)) THEN
      RETURN TRUE;
    END IF;
  ELSIF p_validation_type = G_LE_VAL THEN
    IF ( (p_start_date IS NULL AND p_end_date IS NULL)
          OR
         (p_start_date IS NOT NULL AND p_start_date <= NVL(p_end_date,p_start_date))
       ) THEN
      RETURN TRUE;
    END IF;
  END IF;
  RETURN FALSE;
END date_check;

------------------------------------------
--
-- Check validity of organization details passed
--
 ------------------------------------------
FUNCTION validate_org (x_organization_id    IN OUT NOCOPY NUMBER
                      ,p_organization_code  IN VARCHAR2
                      ,p_set_message        IN VARCHAR2
                    ) RETURN BOOLEAN IS
  l_dummy_char  VARCHAR2(32767);
BEGIN
  IF x_organization_id IS NOT NULL THEN
    BEGIN
      SELECT organization_id
      INTO x_organization_id
      from mtl_parameters
      where organization_id = x_organization_id;
      RETURN TRUE;
    EXCEPTION
      WHEN OTHERS THEN
        IF FND_API.To_Boolean(p_set_message) THEN
          fnd_message.Set_Name(G_APP_NAME, 'EGO_ORGANIZATION_ID');
          l_dummy_char := fnd_message.get();
          fnd_message.Set_Name(G_APP_NAME, 'EGO_IPI_INVALID_VALUE');
          fnd_message.Set_Token('NAME', l_dummy_char);
          fnd_message.Set_Token('VALUE', x_organization_id);
          fnd_msg_pub.Add;
        END IF;
        RETURN FALSE;
    END;
  ELSIF p_organization_code IS NOT NULL THEN
    BEGIN
      SELECT organization_id
      INTO x_organization_id
      from mtl_parameters
      where organization_code = p_organization_code;
      RETURN TRUE;
    EXCEPTION
      WHEN OTHERS THEN
        IF FND_API.To_Boolean(p_set_message) THEN
          fnd_message.Set_Name(G_APP_NAME, 'EGO_ORGANIZATION_CODE');
          l_dummy_char := fnd_message.get();
          fnd_message.Set_Name(G_APP_NAME, 'EGO_IPI_INVALID_VALUE');
          fnd_message.Set_Token('NAME', l_dummy_char);
          fnd_message.Set_Token('VALUE', p_organization_code);
          fnd_msg_pub.Add;
        END IF;
        RETURN FALSE;
    END;
  ELSE
--    x_organization_id := NULL;
    RETURN FALSE;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
--    x_organization_id := NULL;
    RETURN FALSE;
END validate_org;

------------------------------------------
--
-- Check validity of item details passed
--
 ------------------------------------------
FUNCTION validate_item (x_inventory_item_id  IN OUT NOCOPY NUMBER
                       ,x_item_number        IN OUT NOCOPY VARCHAR2
                       ,x_approval_status    OUT NOCOPY VARCHAR2
                       ,p_organization_id    IN  NUMBER
                       ,p_set_message        IN VARCHAR2
                    ) RETURN BOOLEAN IS
  l_dummy_char  VARCHAR2(32767);
BEGIN
  IF p_organization_id IS NOT NULL THEN
    IF x_inventory_item_id IS NOT NULL THEN
      BEGIN
        SELECT itm.inventory_item_id, itm.approval_status, itm_num.concatenated_segments
        INTO x_inventory_item_id, x_approval_status, x_item_number
        FROM mtl_system_items_b itm, mtl_system_items_b_kfv itm_num
        WHERE itm.inventory_item_id = x_inventory_item_id
          AND itm.organization_id = p_organization_id
          AND itm_num.inventory_item_id = itm.inventory_item_id
          AND itm_num.organization_id = itm.organization_id;
        RETURN TRUE;
      EXCEPTION
        WHEN OTHERS THEN
          IF FND_API.To_Boolean(p_set_message) THEN
            fnd_message.Set_Name(G_APP_NAME, 'EGO_EF_BL_INV_ITEM_ID_ERR');
            fnd_message.Set_Token('ITEM_ID', x_inventory_item_id);
            fnd_msg_pub.Add;
          END IF;
          RETURN FALSE;
      END;
    ELSIF x_item_number IS NOT NULL THEN
      BEGIN
        SELECT itm.inventory_item_id, itm.approval_status, itm_num.concatenated_segments
        INTO x_inventory_item_id, x_approval_status, x_item_number
        FROM mtl_system_items_b itm, mtl_system_items_b_kfv itm_num
        WHERE itm_num.organization_id = p_organization_id
          AND itm_num.concatenated_segments = x_item_number
          AND itm.inventory_item_id = itm_num.inventory_item_id
          AND itm.organization_id = itm_num.organization_id;
        RETURN TRUE;
      EXCEPTION
        WHEN OTHERS THEN
          IF FND_API.To_Boolean(p_set_message) THEN
            fnd_message.Set_Name(G_APP_NAME, 'EGO_EF_BL_ITEM_NUM_ERR');
            fnd_message.Set_Token('ITEM_NUMBER', x_item_number);
            fnd_msg_pub.Add;
          END IF;
          RETURN FALSE;
      END;
    ELSE
--    x_inventory_item_id := NULL;
--    x_item_number := NULL;
--    x_approval_status := NULL;
      RETURN FALSE;
    END IF;
  ELSE
    IF FND_API.To_Boolean(p_set_message) THEN
      fnd_message.Set_Name(G_APP_NAME, 'EGO_ORGANIZATION');
      l_dummy_char := fnd_message.get();
      fnd_message.Set_Name(G_APP_NAME, 'EGO_IPI_INVALID_VALUE');
      fnd_message.Set_Token('NAME', l_dummy_char);
      fnd_message.Set_Token('VALUE', ' ');
      fnd_msg_pub.Add;
    END IF;
    RETURN FALSE;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
--    x_inventory_item_id := NULL;
--    x_item_number := NULL;
--    x_approval_status := NULL;
    RETURN FALSE;
END validate_item;


------------------------------------------
--
-- Check validity of item revision details
--
 ------------------------------------------
FUNCTION validate_item_rev (x_revision_id        IN OUT NOCOPY NUMBER
                           ,x_revision           IN OUT NOCOPY VARCHAR2
                           ,p_inventory_item_id  IN NUMBER
                           ,p_organization_id    IN NUMBER
                           ,p_set_message        IN VARCHAR2
                    ) RETURN BOOLEAN IS
  l_dummy_char  VARCHAR2(32767);
BEGIN
  IF p_organization_id IS NOT NULL AND p_inventory_item_id IS NOT NULL THEN
    IF x_revision_id IS NOT NULL THEN
      BEGIN
        SELECT revision_id, revision
        INTO x_revision_id, x_revision
        FROM mtl_item_revisions_b
        WHERE inventory_item_id = p_inventory_item_id
          AND organization_id = p_organization_id
          AND revision_id = x_revision_id;
        RETURN TRUE;
      EXCEPTION
        WHEN OTHERS THEN
          IF FND_API.To_Boolean(p_set_message) THEN
            fnd_message.Set_Name(G_APP_NAME, 'EGO_REVISIONID_INVALID');
            fnd_message.Set_Token('REVISION_ID', x_revision_id);
            fnd_msg_pub.Add;
          END IF;
          RETURN FALSE;
      END;
    ELSIF x_revision IS NOT NULL THEN
      BEGIN
        SELECT revision_id, revision
        INTO x_revision_id, x_revision
        FROM mtl_item_revisions_b
        WHERE inventory_item_id = p_inventory_item_id
          AND organization_id = p_organization_id
          AND revision = x_revision;
        RETURN TRUE;
      EXCEPTION
        WHEN OTHERS THEN
          IF FND_API.To_Boolean(p_set_message) THEN
            fnd_message.Set_Name(G_APP_NAME, 'EGO_REVISION_INVALID');
            fnd_message.Set_Token('REVISION', x_revision);
            fnd_msg_pub.Add;
          END IF;
          RETURN FALSE;
      END;
    ELSE
--    x_revision_id := NULL;
--    x_revision := NULL;
      RETURN FALSE;
    END IF;
  ELSE
    RETURN FALSE;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
--    x_revision_id := NULL;
--    x_revision := NULL;
    RETURN FALSE;
END validate_item_rev;

------------------------------------------
--
-- check validity of party details passed
--
 ------------------------------------------
FUNCTION validate_party (p_party_type    IN VARCHAR2
                        ,x_party_id      IN OUT NOCOPY NUMBER
                        ,x_party_name    IN OUT NOCOPY VARCHAR2
                        ) RETURN BOOLEAN IS
  l_hz_party_type   HZ_PARTIES.party_type%TYPE;
  l_dummy_char  VARCHAR2(32767);
BEGIN
  IF p_party_type IN (EGO_ITEM_PUB.G_USER_PARTY_TYPE
                     ,EGO_ITEM_PUB.G_GROUP_PARTY_TYPE
                     ,EGO_ITEM_PUB.G_COMPANY_PARTY_TYPE
                     ,EGO_ITEM_PUB.G_ALL_USERS_PARTY_TYPE
                     ) THEN
    IF p_party_type = EGO_ITEM_PUB.G_ALL_USERS_PARTY_TYPE THEN
      x_party_id := -1000; -- needed by EGO_SECURITY_PUB
      x_party_name := p_party_type;
      RETURN TRUE;
    ELSE
      IF p_party_type = EGO_ITEM_PUB.G_COMPANY_PARTY_TYPE THEN
        l_hz_party_type := G_HZ_COMPANY_PARTY_TYPE;
      ELSIF p_party_type = EGO_ITEM_PUB.G_GROUP_PARTY_TYPE THEN
        l_hz_party_type := p_party_type;
      ELSIF p_party_type = EGO_ITEM_PUB.G_USER_PARTY_TYPE THEN
        l_hz_party_type := G_HZ_USER_PARTY_TYPE;
      END IF;
      IF x_party_id IS NOT NULL THEN
        -- validate the party_id passed.
        BEGIN
          SELECT party_id, party_name
          INTO x_party_id, x_party_name
          FROM hz_parties
          WHERE party_id = x_party_id
          AND party_type = l_hz_party_type;
          RETURN TRUE;
        EXCEPTION
          WHEN OTHERS THEN
--            x_party_id := NULL;
--            x_party_name := NULL;
            RETURN FALSE;
        END;
      ELSIF x_party_name IS NOT NULL THEN
        -- validate the party_name passed.
        BEGIN
          SELECT party_id, party_name
          INTO x_party_id, x_party_name
          FROM hz_parties
          WHERE party_name = x_party_name
          AND party_type = l_hz_party_type;
          RETURN TRUE;
        EXCEPTION
          WHEN OTHERS THEN
--            x_party_id := NULL;
--            x_party_name := NULL;
            RETURN FALSE;
        END;
      END IF;
    END IF;
  ELSE
--    x_party_name := NULL;
--    x_party_id   := NULL;
    RETURN FALSE;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
--    x_party_id := NULL;
--    x_party_name := NULL;
    RETURN FALSE;
END validate_party;

------------------------------------------
--
-- check validity of instance set details
--
 ------------------------------------------
FUNCTION validate_instance_set (x_instance_set_id IN OUT NOCOPY NUMBER
                               ,p_set_disp_name   IN VARCHAR2
                               ) RETURN BOOLEAN IS
  l_dummy_char  VARCHAR2(32767);
BEGIN
  IF x_instance_set_id IS NOT NULL THEN
    BEGIN
      SELECT instance_set_id
      INTO x_instance_set_id
      FROM fnd_object_instance_sets
      WHERE instance_set_id = x_instance_set_id
        AND object_id = (SELECT object_id FROM fnd_objects WHERE obj_name = G_EGO_ITEM);
      RETURN TRUE;
    EXCEPTION
      WHEN OTHERS THEN
--        x_instance_set_id := NULL;
        RETURN FALSE;
    END;
  ELSIF p_set_disp_name IS NOT NULL THEN
    BEGIN
      SELECT instance_set_id
      INTO x_instance_set_id
      FROM fnd_object_instance_sets_vl
      WHERE display_name = p_set_disp_name
        AND object_id = (SELECT object_id FROM fnd_objects WHERE obj_name = G_EGO_ITEM);
      RETURN TRUE;
    EXCEPTION
      WHEN OTHERS THEN
--        x_instance_set_id := NULL;
        RETURN FALSE;
    END;
  ELSE
--    x_instance_set_id := NULL;
    RETURN FALSE;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
--    x_instance_set_id := NULL;
    RETURN FALSE;
END validate_instance_set;

-----------------------------
--
--  check validity of  menu
--
-----------------------------
FUNCTION validate_menu (x_menu_id        IN OUT NOCOPY NUMBER
                       ,x_menu_name      IN OUT NOCOPY VARCHAR2
                       ,p_user_menu_name IN  VARCHAR2
                       ,p_menu_type      IN VARCHAR2
                       ) RETURN BOOLEAN IS
  l_dummy_char  VARCHAR2(32767);
BEGIN
  IF p_menu_type IS NOT NULL THEN
    IF x_menu_id IS NOT NULL THEN
      BEGIN
        SELECT menu_id, menu_name
        INTO x_menu_id, x_menu_name
        FROM fnd_menus
        WHERE menu_id = x_menu_id
        AND type = p_menu_type;
        RETURN TRUE;
      EXCEPTION
        WHEN OTHERS THEN
--          x_menu_id := NULL;
--          x_menu_name := NULL;
          RETURN FALSE;
      END;
    ELSIF p_user_menu_name IS NOT NULL THEN
      BEGIN
        SELECT menu_id, menu_name
        INTO x_menu_id, x_menu_name
        FROM fnd_menus_vl
        WHERE user_menu_name = p_user_menu_name
        AND type = p_menu_type;
        RETURN TRUE;
      EXCEPTION
        WHEN OTHERS THEN
--          x_menu_id := NULL;
--          x_menu_name := NULL;
          RETURN FALSE;
      END;
    END IF;
  ELSE
--    x_menu_id := NULL;
--    x_menu_name := NULL;
    RETURN FALSE;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
--    x_menu_id := NULL;
--    x_menu_name := NULL;
    RETURN FALSE;
END validate_menu;

---------------------------------
--
-- Get Lifecycle / Phase Names
--
---------------------------------
FUNCTION get_lifecycle_name (p_lc_phase_type    IN VARCHAR2
                            ,p_proj_element_id  IN NUMBER
                            ) RETURN VARCHAR2 IS
  l_dummy_char VARCHAR2(32767);
BEGIN
  IF p_lc_phase_type = 'LIFECYCLE' THEN
    SELECT name
    INTO l_dummy_char
    FROM PA_EGO_LIFECYCLES_V
    WHERE proj_element_id = p_proj_element_id;
  ELSIF p_lc_phase_type = 'PHASE' THEN
    SELECT name
    INTO l_dummy_char
    FROM PA_EGO_PHASES_V
    WHERE proj_element_id = p_proj_element_id;
  END IF;
  RETURN l_dummy_char;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_lifecycle_name;

---------------------------------
--
-- check whether the user has functional privilege
--
---------------------------------
FUNCTION validate_function_security (p_function_name     IN VARCHAR2  -- 'EGO_ITEM_ADMINISTRATION'
                                    ,p_set_message       IN VARCHAR2
                                    ) RETURN BOOLEAN IS
BEGIN
  RETURN TRUE;
  IF fnd_function.test(p_function_name) THEN
    RETURN TRUE;
  ELSE
    IF FND_API.To_Boolean(p_set_message) THEN
      fnd_message.Set_Name(G_APP_NAME, 'EGO_NO_FUNC_PRIVILEGE_FOR_USER');
      fnd_msg_pub.Add;
    END IF;
    RETURN FALSE;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END validate_function_security;

-- -----------------------------------------------------------------------------------
--  API Name:       Chg_Order_required
--
--  Description:
--    Returns Y if a change order or update is not allowed on a particular Attribute
--    based on the given inventoryitemid,orgId,ObjectId,attributegroupid and revision level
-- ------------------------------------------------------------------------------------
FUNCTION Chg_Order_Required(
                            p_inventory_item_id IN NUMBER
                           ,p_organization_id IN NUMBER
                           ,p_object_id IN NUMBER
                           ,p_attr_grp_id  IN NUMBER
                           ,p_data_level_1 IN VARCHAR2
                          )
RETURN VARCHAR2
IS

p_chg_ord_req VARCHAR2(1);
l_policy_check_sql       VARCHAR2(32767);

BEGIN
l_policy_check_sql:= 'SELECT ''Y'''||
'          FROM MTL_SYSTEM_ITEMS_B      MSI,'||
'          MTL_ITEM_REVISIONS_B    MIR,'||
'          ENG_CHANGE_POLICIES_V   ECP'||
'          WHERE '||
'          MSI.INVENTORY_ITEM_ID = :1'||
'          AND MSI.ORGANIZATION_ID = :2'||
'          AND MSI.INVENTORY_ITEM_ID = MIR.INVENTORY_ITEM_ID'||
'          AND MSI.ORGANIZATION_ID = MIR.ORGANIZATION_ID '||
'          AND MSI.LIFECYCLE_ID IS NOT NULL'||
'          AND (MSI.APPROVAL_STATUS IS NULL OR MSI.APPROVAL_STATUS =''A'') '||
'          AND ECP.POLICY_OBJECT_PK1_VALUE = '||
'                    (SELECT TO_CHAR(ic.item_catalog_group_id) '||
'                       FROM mtl_item_catalog_groups_b ic'||
'                       WHERE  EXISTS '||
'                          ( SELECT olc.object_classification_code CatalogId '||
'                            FROM  ego_obj_type_lifecycles olc '||
'                            WHERE olc.object_id = :3 '||
'                            AND olc.lifecycle_id = MSI.lifecycle_id '||
'                            AND olc.object_classification_code = ic.item_catalog_group_id  '||
'                          ) '||
'                      AND ROWNUM = 1 '||
'                      CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id '||
'                      START WITH item_catalog_group_id = MSI.item_catalog_group_id '||
'                      )'||
'          AND ECP.ATTRIBUTE_OBJECT_NAME = ''EGO_CATALOG_GROUP'' '||
'          AND ECP.ATTRIBUTE_CODE = ''ATTRIBUTE_GROUP'' '||
'          AND ECP.POLICY_OBJECT_NAME =''CATALOG_LIFECYCLE_PHASE'' '||
'          AND ECP.POLICY_CHAR_VALUE IS NOT NULL '||
'          AND ECP.POLICY_CHAR_VALUE IN (''CHANGE_ORDER_REQUIRED'' ,''NOT_ALLOWED'')'||
'          AND ECP.ATTRIBUTE_NUMBER_VALUE =:4 '||
'          AND ( '||
'                   ( (:5 IS NOT NULL '||
'                     AND MIR.REVISION_ID = :6)'||
'                     AND ECP.POLICY_OBJECT_PK2_VALUE = NVL(MIR.LIFECYCLE_ID, MSI.LIFECYCLE_ID) '||
'                     AND ECP.POLICY_OBJECT_PK3_VALUE = NVL(MIR.CURRENT_PHASE_ID, MSI.CURRENT_PHASE_ID) '||
'                    )  '||
'                    OR '||
'                    ( ECP.POLICY_OBJECT_PK2_VALUE = MSI.LIFECYCLE_ID '||
'                     AND ECP.POLICY_OBJECT_PK3_VALUE = MSI.CURRENT_PHASE_ID '||
'                    ))';

    BEGIN

      EXECUTE IMMEDIATE l_policy_check_sql INTO p_chg_ord_req USING p_inventory_item_id,
                                                                    p_organization_id,
                                                                    p_object_id,
                                                                    p_attr_grp_id,
                                                                    p_data_level_1,
                                                                    p_data_level_1;

     RETURN p_chg_ord_req;
EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 'N';
      WHEN OTHERS THEN
        RETURN NULL;
    END;
END  Chg_Order_Required;

-- -----------------------------------------------------------------------------------
--  API Name:       Remove_Rows_After_Policy_Check
--
--  Description:
--    Updates the error table and deletes the corresponding rows from the
--    EGO_USER_ATTR_ROW_TABLE if a change order is required or update is not allowed
--    for a  given attribute
-- ------------------------------------------------------------------------------------
  FUNCTION Remove_Rows_After_Policy_Check (
            p_inventory_item_id     IN NUMBER
           ,p_organization_id       IN NUMBER
           ,p_attributes_row_table  IN    EGO_USER_ATTR_ROW_TABLE
           ,p_entity_id             IN   NUMBER     DEFAULT NULL
           ,p_entity_index          IN   NUMBER     DEFAULT NULL
           ,p_entity_code           IN   VARCHAR2   DEFAULT NULL
           ,x_return_status         OUT NOCOPY VARCHAR2
) RETURN EGO_USER_ATTR_ROW_TABLE IS

l_object_id NUMBER;
l_is_required VARCHAR2(1);
l_token_table     ERROR_HANDLER.Token_Tbl_Type;
l_attr_grp_id NUMBER;
l_rev_id VARCHAR2(150);
l_delete_sql VARCHAR2(200);
l_attr_data_table_index NUMBER;

l_attributes_row_table   EGO_USER_ATTR_ROW_TABLE;
l_current_data_element EGO_USER_ATTR_ROW_OBJ;

l_current_category_name  MTL_ITEM_CATALOG_GROUPS_KFV.concatenated_segments%TYPE;
l_current_life_cycle   PA_EGO_LIFECYCLES_V.NAME%TYPE;
l_current_phase_name     PA_EGO_PHASES_V.NAME%TYPE;
l_policy_cat_id NUMBER;
l_catalog_category_names_table LOCAL_MEDIUM_VARCHAR_TABLE;
l_item_number MTL_SYSTEM_ITEMS_B.SEGMENT1%TYPE;
l_row_identifier NUMBER;
i NUMBER :=0;
BEGIN
    l_attributes_row_table := EGO_USER_ATTR_ROW_TABLE();
    l_attr_data_table_index := p_attributes_row_table.FIRST;
    SELECT OBJECT_ID into l_object_id FROM  fnd_objects WHERE obj_name ='EGO_ITEM';

    LOOP
          l_current_data_element := p_attributes_row_table(l_attr_data_table_index);
          l_rev_id := l_current_data_element.DATA_LEVEL_1;
          l_attr_grp_id := l_current_data_element.ATTR_GROUP_ID;
          l_row_identifier :=l_current_data_element.ROW_IDENTIFIER;

          l_is_required:=Chg_Order_Required(
                                            p_inventory_item_id =>p_inventory_item_id
                                           ,p_organization_id =>p_organization_id
                                           ,p_object_id =>l_object_id
                                           ,p_attr_grp_id =>l_attr_grp_id
                                           ,p_data_level_1 =>l_rev_id
                                          );

        IF (l_is_required='Y') THEN

             l_token_table(1).TOKEN_NAME := 'ATTR_GROUP_NAME';
             l_token_table(1).TOKEN_VALUE := l_current_data_element.ATTR_GROUP_NAME;

             SELECT segment1 INTO l_item_number FROM MTL_SYSTEM_ITEMS_B  WHERE inventory_item_id=p_inventory_item_id;


             l_token_table(2).TOKEN_NAME := 'ITEM_NUMBER';
             l_token_table(2).TOKEN_VALUE := l_item_number;

            SELECT PEP.NAME
              INTO l_current_life_cycle
              FROM MTL_SYSTEM_ITEMS_B      MSI
                  ,PA_EGO_LIFECYCLES_V     PEP
             WHERE MSI.INVENTORY_ITEM_ID =p_inventory_item_id
               AND MSI.ORGANIZATION_ID = p_organization_id
              AND MSI.LIFECYCLE_ID = PEP.PROJ_ELEMENT_ID;

               l_token_table(3).TOKEN_NAME := 'LIFE_CYCLE';
               l_token_table(3).TOKEN_VALUE := l_current_life_cycle;

              SELECT PEP.NAME
                INTO l_current_phase_name
                FROM MTL_SYSTEM_ITEMS_B      MSI
                    ,PA_EGO_PHASES_V         PEP
               WHERE MSI.INVENTORY_ITEM_ID = p_inventory_item_id
                 AND MSI.ORGANIZATION_ID = p_organization_id
                 AND MSI.CURRENT_PHASE_ID = PEP.PROJ_ELEMENT_ID;

                 l_token_table(4).TOKEN_NAME := 'PHASE';
                 l_token_table(4).TOKEN_VALUE := l_current_phase_name;

                SELECT item_catalog_group_id
                INTO l_policy_cat_id
                FROM (SELECT item_catalog_group_id
                        FROM mtl_item_catalog_groups_b ic
                       WHERE EXISTS
                              ( SELECT olc.object_classification_code CatalogId
                                  FROM  ego_obj_type_lifecycles olc, mtl_system_items_b MSI
                                 WHERE olc.object_id = l_object_id
                                   AND olc.lifecycle_id = MSI.lifecycle_id
                                   AND MSI.inventory_item_id = p_inventory_item_id
                                   AND MSI.organization_id = p_organization_id
                                   AND olc.object_classification_code = ic.item_catalog_group_id
                                )
                         CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
                         START WITH item_catalog_group_id
                         =(SELECT item_catalog_group_id
                                 FROM MTL_SYSTEM_ITEMS_B
                                 WHERE inventory_item_id=p_inventory_item_id
                           )
                       ) CAT_HIER
                WHERE ROWNUM = 1;

                  IF (l_catalog_category_names_table.EXISTS(l_policy_cat_id)) THEN
                    l_current_category_name := l_catalog_category_names_table(l_policy_cat_id);
                  ELSE
                    SELECT concatenated_segments
                      INTO l_current_category_name
                      FROM MTL_ITEM_CATALOG_GROUPS_KFV
                     WHERE ITEM_CATALOG_GROUP_ID = l_policy_cat_id;
                    l_catalog_category_names_table(l_policy_cat_id) := l_current_category_name;
                  END IF;

                   l_token_table(5).TOKEN_NAME := 'CATALOG_CATEGORY_NAME';
                   l_token_table(5).TOKEN_VALUE := l_current_category_name;

                    ERROR_HANDLER.Add_Error_Message(
                    p_message_name                  => 'EGO_EF_BL_ITM_NOT_ALLOW_ERR'
                   ,p_application_id                => 'EGO'
                   ,p_token_tbl                     => l_token_table
                   ,p_message_type                  => FND_API.G_RET_STS_ERROR
                   ,p_row_identifier                =>  l_row_identifier
                   ,p_entity_id                     => p_entity_id
                   ,p_entity_index                  => p_entity_index
                   ,p_entity_code                   => p_entity_code
                 );
                 x_return_status:=FND_API.G_RET_STS_ERROR;
                 l_token_table.DELETE();
                --Delete the row from the ROW_TABLE as it is an error case.
        ELSIF (l_is_required='N') THEN
                   i:=i+1;
                  l_attributes_row_table.EXTEND();
                  l_attributes_row_table(i):=l_current_data_element;
        END IF;--IF(l_is_required='Y')
        l_attr_data_table_index := p_attributes_row_table.NEXT(l_attr_data_table_index);
        IF (l_attr_data_table_index IS NULL) THEN
           EXIT ;
        END IF;--IF(l_attr_data_table_index IS NULL)
      END LOOP;
      RETURN l_attributes_row_table;
EXCEPTION
  WHEN OTHERS THEN
      RETURN NULL;
END Remove_Rows_After_Policy_Check;

-- =============================================================================
--                                  Procedures
-- =============================================================================

-- -----------------------------------------------------------------------------
--  API Name:       Process_Items
-- -----------------------------------------------------------------------------

PROCEDURE Process_Items
(
   p_commit         IN      VARCHAR2      DEFAULT  FND_API.g_FALSE
,  x_return_status      OUT NOCOPY  VARCHAR2
,  x_msg_count          OUT NOCOPY  NUMBER
)
IS
   CURSOR c_get_org_code(cp_org_id NUMBER) IS
      SELECT  organization_code
             ,master_organization_id
      FROM    mtl_parameters
      WHERE   organization_id = cp_org_id;

   l_api_name       CONSTANT    VARCHAR2(30)  :=  'Process_Items';
   l_return_status      VARCHAR2(1)  :=  G_MISS_CHAR;
   l_msg_count          NUMBER       :=  0;

   l_error_code         NUMBER;
   --R12 C
   l_return_err         VARCHAR2(1000);
   l_batch_id           NUMBER;
   G_Item_Rec           EGO_Item_PUB.Item_Rec_Type;
   -- added for bug 7431714
   l_icc_change_flag    BOOLEAN      := FALSE;
   l_init_msg_list      VARCHAR2(1)  := NULL;
   l_curr_icc_id        NUMBER;


   -- end adding bug 7431714
   l_dummy        NUMBER;
     l_error_text   VARCHAR2(4000);
     Item_or_Org_INVALID exception;
----------------------------------------------------------------------------
-- Business Event For Implicit Revision/Category Assignments
----------------------------------------------------------------------------
  CURSOR  DEFAULT_CAT_ASSIGN_CREATE ( CP_ITEM_ID NUMBER
             ,CP_ORG_ID  NUMBER ) IS
  SELECT  S.CATEGORY_SET_ID,
    S.CATEGORY_ID
  FROM    MTL_ITEM_CATEGORIES S
  WHERE   S.INVENTORY_ITEM_ID   = CP_ITEM_ID
  AND     S.ORGANIZATION_ID     = CP_ORG_ID
    AND EXISTS
       (SELECT 'X'
        FROM    MTL_DEFAULT_CATEGORY_SETS D
        WHERE   D.CATEGORY_SET_ID         = S.CATEGORY_SET_ID
          AND (D.FUNCTIONAL_AREA_ID   = DECODE( G_Item_Rec.INVENTORY_ITEM_FLAG, 'Y', 1, 0 )
      OR D.FUNCTIONAL_AREA_ID   = DECODE( G_Item_Rec.PURCHASING_ITEM_FLAG, 'Y', 2, 0 )
      OR D.FUNCTIONAL_AREA_ID   = DECODE( G_Item_Rec.INTERNAL_ORDER_FLAG, 'Y', 2, 0 )
      OR D.FUNCTIONAL_AREA_ID   = DECODE( G_Item_Rec.MRP_PLANNING_CODE, 6, 0, 3 )
      OR D.FUNCTIONAL_AREA_ID   = DECODE( G_Item_Rec.SERVICEABLE_PRODUCT_FLAG, 'Y', 4, 0 )
      OR D.FUNCTIONAL_AREA_ID   = DECODE( G_Item_Rec.COSTING_ENABLED_FLAG, 'Y', 5, 0 )
      OR D.FUNCTIONAL_AREA_ID   = DECODE( G_Item_Rec.ENG_ITEM_FLAG, 'Y', 6, 0 )
      OR D.FUNCTIONAL_AREA_ID   = DECODE( G_Item_Rec.CUSTOMER_ORDER_FLAG, 'Y', 7, 0 )
      OR D.FUNCTIONAL_AREA_ID   = DECODE( NVL(G_Item_Rec.EAM_ITEM_TYPE, 0), 0, 0, 9 )
      OR D.FUNCTIONAL_AREA_ID   = DECODE( G_Item_Rec.CONTRACT_ITEM_TYPE_CODE, 'SERVICE' , 10, 'WARRANTY' , 10, 'SUBSCRIPTION' , 10, 'USAGE' , 10, 0 )
      OR D.FUNCTIONAL_AREA_ID   = DECODE( G_Item_Rec.CONTRACT_ITEM_TYPE_CODE, 'SERVICE' , 4, 'WARRANTY' , 4, 0 )
      OR D.FUNCTIONAL_AREA_ID   = DECODE( G_Item_Rec.CUSTOMER_ORDER_FLAG, 'Y', 11, 0 )
      OR D.FUNCTIONAL_AREA_ID   = DECODE( G_Item_Rec.INTERNAL_ORDER_FLAG, 'Y', 11, 0 )));
 -------------------------------------------------------------------------------
  CURSOR  DEFAULT_CAT_ASSIGN_UPDATE ( CP_ITEM_ID NUMBER
             ,CP_ORG_ID  NUMBER ) IS
  SELECT  S.CATEGORY_SET_ID,
    S.CATEGORY_ID
  FROM    MTL_ITEM_CATEGORIES S,
    MTL_CATEGORY_SETS_B D
  WHERE   S.INVENTORY_ITEM_ID   = CP_ITEM_ID
    AND S.CATEGORY_SET_ID = D.CATEGORY_SET_ID
    AND S.ORGANIZATION_ID = CP_ORG_ID
    AND (D.CONTROL_LEVEL  = 1
    OR EXISTS
    (SELECT 'X'
    FROM    MTL_DEFAULT_CATEGORY_SETS D
    WHERE   D.CATEGORY_SET_ID         = S.CATEGORY_SET_ID
      AND (D.FUNCTIONAL_AREA_ID = DECODE( G_Item_Rec.INVENTORY_ITEM_FLAG, 'Y', 1, 0 )
      OR D.FUNCTIONAL_AREA_ID   = DECODE( G_Item_Rec.PURCHASING_ITEM_FLAG, 'Y', 2, 0 )
      OR D.FUNCTIONAL_AREA_ID   = DECODE( G_Item_Rec.INTERNAL_ORDER_FLAG, 'Y', 2, 0 )
      OR D.FUNCTIONAL_AREA_ID   = DECODE( G_Item_Rec.MRP_PLANNING_CODE, 6, 0, 3 )
      OR D.FUNCTIONAL_AREA_ID   = DECODE( G_Item_Rec.SERVICEABLE_PRODUCT_FLAG, 'Y', 4, 0 )
      OR D.FUNCTIONAL_AREA_ID   = DECODE( G_Item_Rec.COSTING_ENABLED_FLAG, 'Y', 5, 0 )
      OR D.FUNCTIONAL_AREA_ID   = DECODE( G_Item_Rec.ENG_ITEM_FLAG, 'Y', 6, 0 )
      OR D.FUNCTIONAL_AREA_ID   = DECODE( G_Item_Rec.CUSTOMER_ORDER_FLAG, 'Y', 7, 0 )
      OR D.FUNCTIONAL_AREA_ID   = DECODE( NVL(G_Item_Rec.EAM_ITEM_TYPE, 0), 0, 0, 9 )
      OR D.FUNCTIONAL_AREA_ID   = DECODE( G_Item_Rec.CONTRACT_ITEM_TYPE_CODE, 'SERVICE' , 10, 'WARRANTY' , 10, 'SUBSCRIPTION' , 10, 'USAGE' , 10, 0 )
      OR D.FUNCTIONAL_AREA_ID   = DECODE( G_Item_Rec.CONTRACT_ITEM_TYPE_CODE, 'SERVICE' , 4, 'WARRANTY' , 4, 0 )
      OR D.FUNCTIONAL_AREA_ID   = DECODE( G_Item_Rec.CUSTOMER_ORDER_FLAG, 'Y', 11, 0 )
      OR D.FUNCTIONAL_AREA_ID   = DECODE( G_Item_Rec.INTERNAL_ORDER_FLAG, 'Y', 11, 0 ))
    )) ;
  -----------------------------------------------------------------------------
      CURSOR  REV_RECORDS_CREATE ( CP_ITEM_ID NUMBER
                                  ,CP_ORG_ID  NUMBER ) IS
   SELECT REVISION_ID
     FROM MTL_ITEM_REVISIONS_B
    WHERE INVENTORY_ITEM_ID  = CP_ITEM_ID
      AND ORGANIZATION_ID    = CP_ORG_ID ;
 -----------------------------------------------------------------------------
   l_Item_rec_in        INV_ITEM_GRP.Item_Rec_Type;
   l_revision_rec       INV_ITEM_GRP.Item_Revision_Rec_Type;
   l_rev_index_failure  BOOLEAN := FALSE;

   l_Item_rec_out       INV_ITEM_GRP.Item_Rec_Type;

   l_Template_Id        NUMBER;
   l_Template_Name      VARCHAR2(30);
   l_Error_tbl          INV_ITEM_GRP.Error_Tbl_Type;
   --------------------------------------------------------------------------
   -- Business Event enhancement
   --------------------------------------------------------------------------
   l_event_return_status VARCHAR2(1) ;
   l_msg_data            VARCHAR2(2000);
   l_org_code_rec        c_get_org_code%ROWTYPE;
   l_item_desc          mtl_system_items_kfv.DESCRIPTION%TYPE;
   l_item_number        mtl_system_items_kfv.CONCATENATED_SEGMENTS%TYPE;
   ----------------------------------------------------------------
   l_revision_id_out     MTL_ITEM_REVISIONS_B.REVISION_ID%TYPE;
   l_cat_tab_index       NUMBER := G_MISS_NUM ;
   l_cat_match           VARCHAR2(1) DEFAULT  FND_API.G_FALSE ;
   --Bug: 4881908
   l_process_control     VARCHAR2(2000) := INV_EGO_REVISION_VALIDATE.Get_Process_Control;
   ---------------------------------------------------------------------------
   TYPE CATEGORY_ASSIGN_REC IS RECORD (
     CATEGORY_SET_ID   NUMBER := G_MISS_NUM,
     CATEGORY_ID       NUMBER := G_MISS_NUM,
     INVENTORY_ITEM_ID NUMBER := G_MISS_NUM,
     ORGANIZATION_ID   NUMBER := G_MISS_NUM );
   TYPE CATEGORY_ASSIGN_TAB IS TABLE OF CATEGORY_ASSIGN_REC INDEX BY BINARY_INTEGER;

   l_cat_assign_rec_table_bef  CATEGORY_ASSIGN_TAB;
   l_cat_assign_rec_table_aft  CATEGORY_ASSIGN_TAB;
   l_wf_org_code               VARCHAR2(3);

   -- Bug 9852661
   l_attributes_row_table             EGO_USER_ATTR_ROW_TABLE := EGO_USER_ATTR_ROW_TABLE();
   l_attributes_data_table            EGO_USER_ATTR_DATA_TABLE := EGO_USER_ATTR_DATA_TABLE() ;
   l_attr_row_count   NUMBER;
   l_attr_data_count  NUMBER;
   -- Bug 9852661
  BEGIN

   x_return_status  :=  G_RET_STS_SUCCESS;

   -----------------------------------------------------------------------------
   -- Loop through item records in the global table.
   -----------------------------------------------------------------------------

   G_Item_indx     :=  G_Item_Tbl.FIRST;

 WHILE G_Item_indx <= G_Item_Tbl.LAST LOOP

   -- Clear the Item GRP API message table before processing an item
   l_Error_tbl.DELETE;

   G_Item_Rec  :=  G_Item_Tbl(G_Item_indx);

    -- Copy item from
   l_Template_Id                :=  G_Item_Rec.Template_Id;
   l_Template_Name              :=  G_Item_Rec.Template_Name;

   -- Item identifier
   l_Item_rec_in.INVENTORY_ITEM_ID      :=  G_Item_Rec.Inventory_Item_Id;
   l_Item_rec_in.ITEM_NUMBER            :=  G_Item_Rec.Item_Number;
   l_Item_rec_in.SEGMENT1       :=  G_Item_Rec.Segment1;
   l_Item_rec_in.SEGMENT2       :=  G_Item_Rec.Segment2;
   l_Item_rec_in.SEGMENT3       :=  G_Item_Rec.Segment3;
   l_Item_rec_in.SEGMENT4       :=  G_Item_Rec.Segment4;
   l_Item_rec_in.SEGMENT5       :=  G_Item_Rec.Segment5;
   l_Item_rec_in.SEGMENT6       :=  G_Item_Rec.Segment6;
   l_Item_rec_in.SEGMENT7       :=  G_Item_Rec.Segment7;
   l_Item_rec_in.SEGMENT8       :=  G_Item_Rec.Segment8;
   l_Item_rec_in.SEGMENT9       :=  G_Item_Rec.Segment9;
   l_Item_rec_in.SEGMENT10      :=  G_Item_Rec.Segment10;
   l_Item_rec_in.SEGMENT11      :=  G_Item_Rec.Segment11;
   l_Item_rec_in.SEGMENT12      :=  G_Item_Rec.Segment12;
   l_Item_rec_in.SEGMENT13      :=  G_Item_Rec.Segment13;
   l_Item_rec_in.SEGMENT14      :=  G_Item_Rec.Segment14;
   l_Item_rec_in.SEGMENT15      :=  G_Item_Rec.Segment15;
   l_Item_rec_in.SEGMENT16      :=  G_Item_Rec.Segment16;
   l_Item_rec_in.SEGMENT17      :=  G_Item_Rec.Segment17;
   l_Item_rec_in.SEGMENT18      :=  G_Item_Rec.Segment18;
   l_Item_rec_in.SEGMENT19      :=  G_Item_Rec.Segment19;
   l_Item_rec_in.SEGMENT20      :=  G_Item_Rec.Segment20;
   l_Item_rec_in.SUMMARY_FLAG           :=  G_Item_Rec.Summary_Flag;
   l_Item_rec_in.ENABLED_FLAG           :=  G_Item_Rec.Enabled_Flag;
   l_Item_rec_in.START_DATE_ACTIVE      :=  G_Item_Rec.Start_Date_Active;
   l_Item_rec_in.END_DATE_ACTIVE        :=  G_Item_Rec.End_Date_Active;

   -- Organization
   l_Item_rec_in.ORGANIZATION_ID        :=  G_Item_Rec.Organization_Id;
   l_Item_rec_in.ORGANIZATION_CODE      :=  G_Item_Rec.Organization_Code;

   -- Item catalog group (user item type)
   l_Item_rec_in.ITEM_CATALOG_GROUP_ID      :=  G_Item_Rec.Item_Catalog_Group_Id;
   l_Item_rec_in.CATALOG_STATUS_FLAG        :=  G_Item_Rec.Catalog_Status_Flag;

   -- Lifecycle
   l_Item_rec_in.LIFECYCLE_ID           :=  G_Item_Rec.Lifecycle_Id;
   l_Item_rec_in.CURRENT_PHASE_ID       :=  G_Item_Rec.Current_Phase_Id;

   -- Main attributes
   l_Item_rec_in.DESCRIPTION            :=  G_Item_Rec.Description;
   l_Item_rec_in.LONG_DESCRIPTION       :=  G_Item_Rec.Long_Description;
   l_Item_rec_in.PRIMARY_UOM_CODE       :=  G_Item_Rec.Primary_Uom_Code;

   --PRIMARY_UNIT_OF_MEASURE
   l_Item_rec_in.ALLOWED_UNITS_LOOKUP_CODE  :=  G_Item_Rec.ALLOWED_UNITS_LOOKUP_CODE;
   l_Item_rec_in.INVENTORY_ITEM_STATUS_CODE :=  G_Item_Rec.Inventory_Item_Status_Code;

   l_Item_rec_in.DUAL_UOM_CONTROL           :=  G_Item_Rec.DUAL_UOM_CONTROL;
   l_Item_rec_in.SECONDARY_UOM_CODE         :=  G_Item_Rec.SECONDARY_UOM_CODE;
   l_Item_rec_in.DUAL_UOM_DEVIATION_HIGH    :=  G_Item_Rec.DUAL_UOM_DEVIATION_HIGH;
   l_Item_rec_in.DUAL_UOM_DEVIATION_LOW     :=  G_Item_Rec.DUAL_UOM_DEVIATION_LOW;
   l_Item_rec_in.ITEM_TYPE                  :=  G_Item_Rec.ITEM_TYPE;

   -- Inventory
   l_Item_rec_in.INVENTORY_ITEM_FLAG            :=  G_Item_Rec.INVENTORY_ITEM_FLAG;
   l_Item_rec_in.STOCK_ENABLED_FLAG             :=  G_Item_Rec.STOCK_ENABLED_FLAG;
   l_Item_rec_in.MTL_TRANSACTIONS_ENABLED_FLAG  :=  G_Item_Rec.MTL_TRANSACTIONS_ENABLED_FLAG;
   l_Item_rec_in.REVISION_QTY_CONTROL_CODE      :=  G_Item_Rec.REVISION_QTY_CONTROL_CODE;
   l_Item_rec_in.LOT_CONTROL_CODE               :=  G_Item_Rec.LOT_CONTROL_CODE;
   l_Item_rec_in.AUTO_LOT_ALPHA_PREFIX          :=  G_Item_Rec.AUTO_LOT_ALPHA_PREFIX;
   l_Item_rec_in.START_AUTO_LOT_NUMBER          :=  G_Item_Rec.START_AUTO_LOT_NUMBER;
   l_Item_rec_in.SERIAL_NUMBER_CONTROL_CODE     :=  G_Item_Rec.SERIAL_NUMBER_CONTROL_CODE;
   l_Item_rec_in.AUTO_SERIAL_ALPHA_PREFIX       :=  G_Item_Rec.AUTO_SERIAL_ALPHA_PREFIX;
   l_Item_rec_in.START_AUTO_SERIAL_NUMBER       :=  G_Item_Rec.START_AUTO_SERIAL_NUMBER;
   l_Item_rec_in.SHELF_LIFE_CODE                :=  G_Item_Rec.SHELF_LIFE_CODE;
   l_Item_rec_in.SHELF_LIFE_DAYS                :=  G_Item_Rec.SHELF_LIFE_DAYS;
   l_Item_rec_in.RESTRICT_SUBINVENTORIES_CODE   :=  G_Item_Rec.RESTRICT_SUBINVENTORIES_CODE;
   l_Item_rec_in.LOCATION_CONTROL_CODE          :=  G_Item_Rec.LOCATION_CONTROL_CODE;
   l_Item_rec_in.RESTRICT_LOCATORS_CODE         :=  G_Item_Rec.RESTRICT_LOCATORS_CODE;
   l_Item_rec_in.RESERVABLE_TYPE                :=  G_Item_Rec.RESERVABLE_TYPE;
   l_Item_rec_in.CYCLE_COUNT_ENABLED_FLAG       :=  G_Item_Rec.CYCLE_COUNT_ENABLED_FLAG;
   l_Item_rec_in.NEGATIVE_MEASUREMENT_ERROR     :=  G_Item_Rec.NEGATIVE_MEASUREMENT_ERROR;
   l_Item_rec_in.POSITIVE_MEASUREMENT_ERROR     :=  G_Item_Rec.POSITIVE_MEASUREMENT_ERROR;
   l_Item_rec_in.CHECK_SHORTAGES_FLAG           :=  G_Item_Rec.CHECK_SHORTAGES_FLAG;
   l_Item_rec_in.LOT_STATUS_ENABLED             :=  G_Item_Rec.LOT_STATUS_ENABLED;
   l_Item_rec_in.DEFAULT_LOT_STATUS_ID          :=  G_Item_Rec.DEFAULT_LOT_STATUS_ID;
   l_Item_rec_in.SERIAL_STATUS_ENABLED          :=  G_Item_Rec.SERIAL_STATUS_ENABLED;
   l_Item_rec_in.DEFAULT_SERIAL_STATUS_ID       :=  G_Item_Rec.DEFAULT_SERIAL_STATUS_ID;
   l_Item_rec_in.LOT_SPLIT_ENABLED              :=  G_Item_Rec.LOT_SPLIT_ENABLED;
   l_Item_rec_in.LOT_MERGE_ENABLED              :=  G_Item_Rec.LOT_MERGE_ENABLED;
   l_Item_rec_in.LOT_TRANSLATE_ENABLED          :=  G_Item_Rec.LOT_TRANSLATE_ENABLED;
   l_Item_rec_in.LOT_SUBSTITUTION_ENABLED       :=  G_Item_Rec.LOT_SUBSTITUTION_ENABLED;
   l_Item_rec_in.BULK_PICKED_FLAG               :=  G_Item_Rec.BULK_PICKED_FLAG;

   -- Bills of Material
   l_Item_rec_in.BOM_ITEM_TYPE          :=  G_Item_Rec.BOM_ITEM_TYPE;
   l_Item_rec_in.BOM_ENABLED_FLAG       :=  G_Item_Rec.BOM_ENABLED_FLAG;
   l_Item_rec_in.BASE_ITEM_ID           :=  G_Item_Rec.BASE_ITEM_ID;
   l_Item_rec_in.ENG_ITEM_FLAG          :=  G_Item_Rec.ENG_ITEM_FLAG;
   l_Item_rec_in.ENGINEERING_ITEM_ID    :=  G_Item_Rec.ENGINEERING_ITEM_ID;
   l_Item_rec_in.ENGINEERING_ECN_CODE   :=  G_Item_Rec.ENGINEERING_ECN_CODE;
   l_Item_rec_in.ENGINEERING_DATE       :=  G_Item_Rec.ENGINEERING_DATE;
   l_Item_rec_in.EFFECTIVITY_CONTROL    :=  G_Item_Rec.EFFECTIVITY_CONTROL;
   l_Item_rec_in.CONFIG_MODEL_TYPE      :=  G_Item_Rec.CONFIG_MODEL_TYPE;
   l_Item_rec_in.PRODUCT_FAMILY_ITEM_ID :=  G_Item_Rec.Product_Family_Item_Id;
   l_Item_rec_in.AUTO_CREATED_CONFIG_FLAG :=  G_Item_Rec.auto_created_config_flag;--3911562
   -- Costing
   l_Item_rec_in.COSTING_ENABLED_FLAG       :=  G_Item_Rec.COSTING_ENABLED_FLAG;
   l_Item_rec_in.INVENTORY_ASSET_FLAG       :=  G_Item_Rec.INVENTORY_ASSET_FLAG;
   l_Item_rec_in.COST_OF_SALES_ACCOUNT      :=  G_Item_Rec.COST_OF_SALES_ACCOUNT;
   l_Item_rec_in.DEFAULT_INCLUDE_IN_ROLLUP_FLAG :=  G_Item_Rec.DEFAULT_INCLUDE_IN_ROLLUP_FLAG;
   l_Item_rec_in.STD_LOT_SIZE               :=  G_Item_Rec.STD_LOT_SIZE;

   -- Enterprise Asset Management
   l_Item_rec_in.EAM_ITEM_TYPE              :=  G_Item_Rec.EAM_ITEM_TYPE;
   l_Item_rec_in.EAM_ACTIVITY_TYPE_CODE     :=  G_Item_Rec.EAM_ACTIVITY_TYPE_CODE;
   l_Item_rec_in.EAM_ACTIVITY_CAUSE_CODE    :=  G_Item_Rec.EAM_ACTIVITY_CAUSE_CODE;
   l_Item_rec_in.EAM_ACTIVITY_SOURCE_CODE   :=  G_Item_Rec.EAM_ACTIVITY_SOURCE_CODE;
   l_Item_rec_in.EAM_ACT_SHUTDOWN_STATUS    :=  G_Item_Rec.EAM_ACT_SHUTDOWN_STATUS;
   l_Item_rec_in.EAM_ACT_NOTIFICATION_FLAG  :=  G_Item_Rec.EAM_ACT_NOTIFICATION_FLAG;

   -- Purchasing
   l_Item_rec_in.PURCHASING_ITEM_FLAG       :=  G_Item_Rec.PURCHASING_ITEM_FLAG;
   l_Item_rec_in.PURCHASING_ENABLED_FLAG    :=  G_Item_Rec.PURCHASING_ENABLED_FLAG;
   l_Item_rec_in.BUYER_ID                   :=  G_Item_Rec.BUYER_ID;
   l_Item_rec_in.MUST_USE_APPROVED_VENDOR_FLAG  :=  G_Item_Rec.MUST_USE_APPROVED_VENDOR_FLAG;
   l_Item_rec_in.PURCHASING_TAX_CODE        :=  G_Item_Rec.PURCHASING_TAX_CODE;
   l_Item_rec_in.TAXABLE_FLAG               :=  G_Item_Rec.TAXABLE_FLAG;
   l_Item_rec_in.RECEIVE_CLOSE_TOLERANCE    :=  G_Item_Rec.RECEIVE_CLOSE_TOLERANCE;
   l_Item_rec_in.ALLOW_ITEM_DESC_UPDATE_FLAG:=  G_Item_Rec.ALLOW_ITEM_DESC_UPDATE_FLAG;
   l_Item_rec_in.INSPECTION_REQUIRED_FLAG   :=  G_Item_Rec.INSPECTION_REQUIRED_FLAG;
   l_Item_rec_in.RECEIPT_REQUIRED_FLAG      :=  G_Item_Rec.RECEIPT_REQUIRED_FLAG;
   l_Item_rec_in.MARKET_PRICE               :=  G_Item_Rec.MARKET_PRICE;
   l_Item_rec_in.UN_NUMBER_ID               :=  G_Item_Rec.UN_NUMBER_ID;
   l_Item_rec_in.HAZARD_CLASS_ID            :=  G_Item_Rec.HAZARD_CLASS_ID;
   l_Item_rec_in.RFQ_REQUIRED_FLAG          :=  G_Item_Rec.RFQ_REQUIRED_FLAG;
   l_Item_rec_in.LIST_PRICE_PER_UNIT        :=  G_Item_Rec.LIST_PRICE_PER_UNIT;
   l_Item_rec_in.PRICE_TOLERANCE_PERCENT    :=  G_Item_Rec.PRICE_TOLERANCE_PERCENT;
   l_Item_rec_in.ASSET_CATEGORY_ID          :=  G_Item_Rec.ASSET_CATEGORY_ID;
   l_Item_rec_in.ROUNDING_FACTOR            :=  G_Item_Rec.ROUNDING_FACTOR;
   l_Item_rec_in.UNIT_OF_ISSUE              :=  G_Item_Rec.UNIT_OF_ISSUE;
   l_Item_rec_in.OUTSIDE_OPERATION_FLAG     :=  G_Item_Rec.OUTSIDE_OPERATION_FLAG;
   l_Item_rec_in.OUTSIDE_OPERATION_UOM_TYPE :=  G_Item_Rec.OUTSIDE_OPERATION_UOM_TYPE;
   l_Item_rec_in.INVOICE_CLOSE_TOLERANCE    :=  G_Item_Rec.INVOICE_CLOSE_TOLERANCE;
   l_Item_rec_in.ENCUMBRANCE_ACCOUNT        :=  G_Item_Rec.ENCUMBRANCE_ACCOUNT;
   l_Item_rec_in.EXPENSE_ACCOUNT            :=  G_Item_Rec.EXPENSE_ACCOUNT;
   l_Item_rec_in.QTY_RCV_EXCEPTION_CODE     :=  G_Item_Rec.QTY_RCV_EXCEPTION_CODE;
   l_Item_rec_in.RECEIVING_ROUTING_ID       :=  G_Item_Rec.RECEIVING_ROUTING_ID;
   l_Item_rec_in.QTY_RCV_TOLERANCE          :=  G_Item_Rec.QTY_RCV_TOLERANCE;
   l_Item_rec_in.ENFORCE_SHIP_TO_LOCATION_CODE  :=  G_Item_Rec.ENFORCE_SHIP_TO_LOCATION_CODE;
   l_Item_rec_in.ALLOW_SUBSTITUTE_RECEIPTS_FLAG :=  G_Item_Rec.ALLOW_SUBSTITUTE_RECEIPTS_FLAG;
   l_Item_rec_in.ALLOW_UNORDERED_RECEIPTS_FLAG  :=  G_Item_Rec.ALLOW_UNORDERED_RECEIPTS_FLAG;
   l_Item_rec_in.ALLOW_EXPRESS_DELIVERY_FLAG    :=  G_Item_Rec.ALLOW_EXPRESS_DELIVERY_FLAG;
   l_Item_rec_in.DAYS_EARLY_RECEIPT_ALLOWED :=  G_Item_Rec.DAYS_EARLY_RECEIPT_ALLOWED;
   l_Item_rec_in.DAYS_LATE_RECEIPT_ALLOWED  :=  G_Item_Rec.DAYS_LATE_RECEIPT_ALLOWED;
   l_Item_rec_in.RECEIPT_DAYS_EXCEPTION_CODE:=  G_Item_Rec.RECEIPT_DAYS_EXCEPTION_CODE;

   -- Physical
   l_Item_rec_in.WEIGHT_UOM_CODE        :=  G_Item_Rec.WEIGHT_UOM_CODE;
   l_Item_rec_in.UNIT_WEIGHT            :=  G_Item_Rec.UNIT_WEIGHT;
   l_Item_rec_in.VOLUME_UOM_CODE        :=  G_Item_Rec.VOLUME_UOM_CODE;
   l_Item_rec_in.UNIT_VOLUME            :=  G_Item_Rec.UNIT_VOLUME;
   l_Item_rec_in.CONTAINER_ITEM_FLAG    :=  G_Item_Rec.CONTAINER_ITEM_FLAG;
   l_Item_rec_in.VEHICLE_ITEM_FLAG      :=  G_Item_Rec.VEHICLE_ITEM_FLAG;
   l_Item_rec_in.MAXIMUM_LOAD_WEIGHT    :=  G_Item_Rec.MAXIMUM_LOAD_WEIGHT;
   l_Item_rec_in.MINIMUM_FILL_PERCENT   :=  G_Item_Rec.MINIMUM_FILL_PERCENT;
   l_Item_rec_in.INTERNAL_VOLUME        :=  G_Item_Rec.INTERNAL_VOLUME;
   l_Item_rec_in.CONTAINER_TYPE_CODE    :=  G_Item_Rec.CONTAINER_TYPE_CODE;
   l_Item_rec_in.COLLATERAL_FLAG        :=  G_Item_Rec.COLLATERAL_FLAG;
   l_Item_rec_in.EVENT_FLAG             :=  G_Item_Rec.EVENT_FLAG;
   l_Item_rec_in.EQUIPMENT_TYPE         :=  G_Item_Rec.EQUIPMENT_TYPE;
   l_Item_rec_in.ELECTRONIC_FLAG        :=  G_Item_Rec.ELECTRONIC_FLAG;
   l_Item_rec_in.DOWNLOADABLE_FLAG      :=  G_Item_Rec.DOWNLOADABLE_FLAG;
   l_Item_rec_in.INDIVISIBLE_FLAG       :=  G_Item_Rec.INDIVISIBLE_FLAG;
   l_Item_rec_in.DIMENSION_UOM_CODE     :=  G_Item_Rec.DIMENSION_UOM_CODE;
   l_Item_rec_in.UNIT_LENGTH            :=  G_Item_Rec.UNIT_LENGTH;
   l_Item_rec_in.UNIT_WIDTH             :=  G_Item_Rec.UNIT_WIDTH;
   l_Item_rec_in.UNIT_HEIGHT            :=  G_Item_Rec.UNIT_HEIGHT;
   --
   l_Item_rec_in.INVENTORY_PLANNING_CODE    :=  G_Item_Rec.INVENTORY_PLANNING_CODE;
   l_Item_rec_in.PLANNER_CODE               :=  G_Item_Rec.PLANNER_CODE;
   l_Item_rec_in.PLANNING_MAKE_BUY_CODE     :=  G_Item_Rec.PLANNING_MAKE_BUY_CODE;
   l_Item_rec_in.MIN_MINMAX_QUANTITY        :=  G_Item_Rec.MIN_MINMAX_QUANTITY;
   l_Item_rec_in.MAX_MINMAX_QUANTITY        :=  G_Item_Rec.MAX_MINMAX_QUANTITY;
   l_Item_rec_in.SAFETY_STOCK_BUCKET_DAYS   :=  G_Item_Rec.SAFETY_STOCK_BUCKET_DAYS;
   l_Item_rec_in.CARRYING_COST              :=  G_Item_Rec.CARRYING_COST;
   l_Item_rec_in.ORDER_COST                 :=  G_Item_Rec.ORDER_COST;
   l_Item_rec_in.MRP_SAFETY_STOCK_PERCENT   :=  G_Item_Rec.MRP_SAFETY_STOCK_PERCENT;
   l_Item_rec_in.MRP_SAFETY_STOCK_CODE      :=  G_Item_Rec.MRP_SAFETY_STOCK_CODE;
   l_Item_rec_in.FIXED_ORDER_QUANTITY       :=  G_Item_Rec.FIXED_ORDER_QUANTITY;
   l_Item_rec_in.FIXED_DAYS_SUPPLY          :=  G_Item_Rec.FIXED_DAYS_SUPPLY;
   l_Item_rec_in.MINIMUM_ORDER_QUANTITY     :=  G_Item_Rec.MINIMUM_ORDER_QUANTITY;
   l_Item_rec_in.MAXIMUM_ORDER_QUANTITY     :=  G_Item_Rec.MAXIMUM_ORDER_QUANTITY;
   l_Item_rec_in.FIXED_LOT_MULTIPLIER       :=  G_Item_Rec.FIXED_LOT_MULTIPLIER;
   l_Item_rec_in.SOURCE_TYPE                :=  G_Item_Rec.SOURCE_TYPE;
   l_Item_rec_in.SOURCE_ORGANIZATION_ID     :=  G_Item_Rec.SOURCE_ORGANIZATION_ID;
   l_Item_rec_in.SOURCE_SUBINVENTORY        :=  G_Item_Rec.SOURCE_SUBINVENTORY;
   l_Item_rec_in.MRP_PLANNING_CODE          :=  G_Item_Rec.MRP_PLANNING_CODE;
   l_Item_rec_in.ATO_FORECAST_CONTROL       :=  G_Item_Rec.ATO_FORECAST_CONTROL;
   l_Item_rec_in.PLANNING_EXCEPTION_SET     :=  G_Item_Rec.PLANNING_EXCEPTION_SET;
   l_Item_rec_in.SHRINKAGE_RATE             :=  G_Item_Rec.SHRINKAGE_RATE;
   l_Item_rec_in.END_ASSEMBLY_PEGGING_FLAG  :=  G_Item_Rec.END_ASSEMBLY_PEGGING_FLAG;
   l_Item_rec_in.ROUNDING_CONTROL_TYPE      :=  G_Item_Rec.ROUNDING_CONTROL_TYPE;
   l_Item_rec_in.PLANNED_INV_POINT_FLAG     :=  G_Item_Rec.PLANNED_INV_POINT_FLAG;
   l_Item_rec_in.CREATE_SUPPLY_FLAG         :=  G_Item_Rec.CREATE_SUPPLY_FLAG;
   l_Item_rec_in.ACCEPTABLE_EARLY_DAYS      :=  G_Item_Rec.ACCEPTABLE_EARLY_DAYS;
   l_Item_rec_in.MRP_CALCULATE_ATP_FLAG     :=  G_Item_Rec.MRP_CALCULATE_ATP_FLAG;
   l_Item_rec_in.AUTO_REDUCE_MPS            :=  G_Item_Rec.AUTO_REDUCE_MPS;
   l_Item_rec_in.REPETITIVE_PLANNING_FLAG   :=  G_Item_Rec.REPETITIVE_PLANNING_FLAG;
   l_Item_rec_in.OVERRUN_PERCENTAGE         :=  G_Item_Rec.OVERRUN_PERCENTAGE;
   l_Item_rec_in.ACCEPTABLE_RATE_DECREASE   :=  G_Item_Rec.ACCEPTABLE_RATE_DECREASE;
   l_Item_rec_in.ACCEPTABLE_RATE_INCREASE   :=  G_Item_Rec.ACCEPTABLE_RATE_INCREASE;
   l_Item_rec_in.PLANNING_TIME_FENCE_CODE   :=  G_Item_Rec.PLANNING_TIME_FENCE_CODE;
   l_Item_rec_in.PLANNING_TIME_FENCE_DAYS   :=  G_Item_Rec.PLANNING_TIME_FENCE_DAYS;
   l_Item_rec_in.DEMAND_TIME_FENCE_CODE     :=  G_Item_Rec.DEMAND_TIME_FENCE_CODE;
   l_Item_rec_in.DEMAND_TIME_FENCE_DAYS     :=  G_Item_Rec.DEMAND_TIME_FENCE_DAYS;
   l_Item_rec_in.RELEASE_TIME_FENCE_CODE    :=  G_Item_Rec.RELEASE_TIME_FENCE_CODE;
   l_Item_rec_in.RELEASE_TIME_FENCE_DAYS    :=  G_Item_Rec.RELEASE_TIME_FENCE_DAYS;
   l_Item_rec_in.SUBSTITUTION_WINDOW_CODE   :=  G_Item_Rec.SUBSTITUTION_WINDOW_CODE;
   l_Item_rec_in.SUBSTITUTION_WINDOW_DAYS   :=  G_Item_Rec.SUBSTITUTION_WINDOW_DAYS;

   -- Lead Times
   l_Item_rec_in.PREPROCESSING_LEAD_TIME    :=  G_Item_Rec.PREPROCESSING_LEAD_TIME;
   l_Item_rec_in.FULL_LEAD_TIME             :=  G_Item_Rec.FULL_LEAD_TIME;
   l_Item_rec_in.POSTPROCESSING_LEAD_TIME   :=  G_Item_Rec.POSTPROCESSING_LEAD_TIME;
   l_Item_rec_in.FIXED_LEAD_TIME            :=  G_Item_Rec.FIXED_LEAD_TIME;
   l_Item_rec_in.VARIABLE_LEAD_TIME         :=  G_Item_Rec.VARIABLE_LEAD_TIME;
   l_Item_rec_in.CUM_MANUFACTURING_LEAD_TIME:=  G_Item_Rec.CUM_MANUFACTURING_LEAD_TIME;
   l_Item_rec_in.CUMULATIVE_TOTAL_LEAD_TIME :=  G_Item_Rec.CUMULATIVE_TOTAL_LEAD_TIME;
   l_Item_rec_in.LEAD_TIME_LOT_SIZE         :=  G_Item_Rec.LEAD_TIME_LOT_SIZE;

   -- WIP
   l_Item_rec_in.BUILD_IN_WIP_FLAG          :=  G_Item_Rec.BUILD_IN_WIP_FLAG;
   l_Item_rec_in.WIP_SUPPLY_TYPE            :=  G_Item_Rec.WIP_SUPPLY_TYPE;
   l_Item_rec_in.WIP_SUPPLY_SUBINVENTORY    :=  G_Item_Rec.WIP_SUPPLY_SUBINVENTORY;
   l_Item_rec_in.WIP_SUPPLY_LOCATOR_ID      :=  G_Item_Rec.WIP_SUPPLY_LOCATOR_ID;
   l_Item_rec_in.OVERCOMPLETION_TOLERANCE_TYPE  :=  G_Item_Rec.OVERCOMPLETION_TOLERANCE_TYPE;
   l_Item_rec_in.OVERCOMPLETION_TOLERANCE_VALUE :=  G_Item_Rec.OVERCOMPLETION_TOLERANCE_VALUE;
   l_Item_rec_in.INVENTORY_CARRY_PENALTY    :=  G_Item_Rec.INVENTORY_CARRY_PENALTY;
   l_Item_rec_in.OPERATION_SLACK_PENALTY    :=  G_Item_Rec.OPERATION_SLACK_PENALTY;

   -- Order Management
   l_Item_rec_in.CUSTOMER_ORDER_FLAG        :=  G_Item_Rec.CUSTOMER_ORDER_FLAG;
   l_Item_rec_in.CUSTOMER_ORDER_ENABLED_FLAG:=  G_Item_Rec.CUSTOMER_ORDER_ENABLED_FLAG;
   l_Item_rec_in.INTERNAL_ORDER_FLAG        :=  G_Item_Rec.INTERNAL_ORDER_FLAG;
   l_Item_rec_in.INTERNAL_ORDER_ENABLED_FLAG:=  G_Item_Rec.INTERNAL_ORDER_ENABLED_FLAG;
   l_Item_rec_in.SHIPPABLE_ITEM_FLAG        :=  G_Item_Rec.SHIPPABLE_ITEM_FLAG;
   l_Item_rec_in.SO_TRANSACTIONS_FLAG       :=  G_Item_Rec.SO_TRANSACTIONS_FLAG;
   l_Item_rec_in.PICKING_RULE_ID            :=  G_Item_Rec.PICKING_RULE_ID;
   l_Item_rec_in.PICK_COMPONENTS_FLAG       :=  G_Item_Rec.PICK_COMPONENTS_FLAG;
   l_Item_rec_in.REPLENISH_TO_ORDER_FLAG    :=  G_Item_Rec.REPLENISH_TO_ORDER_FLAG;
   l_Item_rec_in.ATP_FLAG                   :=  G_Item_Rec.ATP_FLAG;
   l_Item_rec_in.ATP_COMPONENTS_FLAG        :=  G_Item_Rec.ATP_COMPONENTS_FLAG;
   l_Item_rec_in.ATP_RULE_ID                :=  G_Item_Rec.ATP_RULE_ID;
   l_Item_rec_in.SHIP_MODEL_COMPLETE_FLAG   :=  G_Item_Rec.SHIP_MODEL_COMPLETE_FLAG;
   l_Item_rec_in.DEFAULT_SHIPPING_ORG       :=  G_Item_Rec.DEFAULT_SHIPPING_ORG;
   l_Item_rec_in.DEFAULT_SO_SOURCE_TYPE     :=  G_Item_Rec.DEFAULT_SO_SOURCE_TYPE;
   l_Item_rec_in.RETURNABLE_FLAG            :=  G_Item_Rec.RETURNABLE_FLAG;
   l_Item_rec_in.RETURN_INSPECTION_REQUIREMENT  :=  G_Item_Rec.RETURN_INSPECTION_REQUIREMENT;
   l_Item_rec_in.OVER_SHIPMENT_TOLERANCE    :=  G_Item_Rec.OVER_SHIPMENT_TOLERANCE;
   l_Item_rec_in.UNDER_SHIPMENT_TOLERANCE   :=  G_Item_Rec.UNDER_SHIPMENT_TOLERANCE;
   l_Item_rec_in.OVER_RETURN_TOLERANCE      :=  G_Item_Rec.OVER_RETURN_TOLERANCE;
   l_Item_rec_in.UNDER_RETURN_TOLERANCE     :=  G_Item_Rec.UNDER_RETURN_TOLERANCE;
   l_Item_rec_in.FINANCING_ALLOWED_FLAG     :=  G_Item_Rec.FINANCING_ALLOWED_FLAG;
   l_Item_rec_in.VOL_DISCOUNT_EXEMPT_FLAG   :=  G_Item_Rec.VOL_DISCOUNT_EXEMPT_FLAG;
   l_Item_rec_in.COUPON_EXEMPT_FLAG         :=  G_Item_Rec.COUPON_EXEMPT_FLAG;
   l_Item_rec_in.INVOICEABLE_ITEM_FLAG      :=  G_Item_Rec.INVOICEABLE_ITEM_FLAG;
   l_Item_rec_in.INVOICE_ENABLED_FLAG       :=  G_Item_Rec.INVOICE_ENABLED_FLAG;
   l_Item_rec_in.ACCOUNTING_RULE_ID         :=  G_Item_Rec.ACCOUNTING_RULE_ID;
   l_Item_rec_in.INVOICING_RULE_ID          :=  G_Item_Rec.INVOICING_RULE_ID;
   l_Item_rec_in.TAX_CODE                   :=  G_Item_Rec.TAX_CODE;
   l_Item_rec_in.SALES_ACCOUNT              :=  G_Item_Rec.SALES_ACCOUNT;
   l_Item_rec_in.PAYMENT_TERMS_ID           :=  G_Item_Rec.PAYMENT_TERMS_ID;

   -- Service
   l_Item_rec_in.CONTRACT_ITEM_TYPE_CODE    :=  G_Item_Rec.CONTRACT_ITEM_TYPE_CODE;
   l_Item_rec_in.SERVICE_DURATION_PERIOD_CODE   :=  G_Item_Rec.SERVICE_DURATION_PERIOD_CODE;
   l_Item_rec_in.SERVICE_DURATION           :=  G_Item_Rec.SERVICE_DURATION;
   l_Item_rec_in.COVERAGE_SCHEDULE_ID       :=  G_Item_Rec.COVERAGE_SCHEDULE_ID;
   l_Item_rec_in.SUBSCRIPTION_DEPEND_FLAG   :=  G_Item_Rec.SUBSCRIPTION_DEPEND_FLAG;
   l_Item_rec_in.SERV_IMPORTANCE_LEVEL      :=  G_Item_Rec.SERV_IMPORTANCE_LEVEL;
   l_Item_rec_in.SERV_REQ_ENABLED_CODE      :=  G_Item_Rec.SERV_REQ_ENABLED_CODE;
   l_Item_rec_in.COMMS_ACTIVATION_REQD_FLAG :=  G_Item_Rec.COMMS_ACTIVATION_REQD_FLAG;
   l_Item_rec_in.SERVICEABLE_PRODUCT_FLAG   :=  G_Item_Rec.SERVICEABLE_PRODUCT_FLAG;
   l_Item_rec_in.MATERIAL_BILLABLE_FLAG     :=  G_Item_Rec.MATERIAL_BILLABLE_FLAG;
   l_Item_rec_in.SERV_BILLING_ENABLED_FLAG  :=  G_Item_Rec.SERV_BILLING_ENABLED_FLAG;
   l_Item_rec_in.DEFECT_TRACKING_ON_FLAG    :=  G_Item_Rec.DEFECT_TRACKING_ON_FLAG;
   l_Item_rec_in.RECOVERED_PART_DISP_CODE   :=  G_Item_Rec.RECOVERED_PART_DISP_CODE;
   l_Item_rec_in.COMMS_NL_TRACKABLE_FLAG    :=  G_Item_Rec.COMMS_NL_TRACKABLE_FLAG;
   l_Item_rec_in.ASSET_CREATION_CODE        :=  G_Item_Rec.ASSET_CREATION_CODE;
   l_Item_rec_in.IB_ITEM_INSTANCE_CLASS     :=  G_Item_Rec.IB_ITEM_INSTANCE_CLASS;
   l_Item_rec_in.SERVICE_STARTING_DELAY     :=  G_Item_Rec.SERVICE_STARTING_DELAY;

   -- Web Option
   l_Item_rec_in.WEB_STATUS                 :=  G_Item_Rec.WEB_STATUS;
   l_Item_rec_in.ORDERABLE_ON_WEB_FLAG      :=  G_Item_Rec.ORDERABLE_ON_WEB_FLAG;
   l_Item_rec_in.BACK_ORDERABLE_FLAG        :=  G_Item_Rec.BACK_ORDERABLE_FLAG;
   l_Item_rec_in.MINIMUM_LICENSE_QUANTITY   :=  G_Item_Rec.MINIMUM_LICENSE_QUANTITY;

   --Start: 26 new attributes
   l_Item_rec_in.TRACKING_QUANTITY_IND      :=  G_Item_Rec.TRACKING_QUANTITY_IND;
   l_Item_rec_in.ONT_PRICING_QTY_SOURCE     :=  G_Item_Rec.ONT_PRICING_QTY_SOURCE;
   l_Item_rec_in.SECONDARY_DEFAULT_IND      :=  G_Item_Rec.SECONDARY_DEFAULT_IND;

   --Option specific sourced not used in grp package. This is a invisible field.
   --l_Item_rec_in.OPTION_SPECIFIC_SOURCED    :=  G_Item_Rec.OPTION_SPECIFIC_SOURCED;
   l_Item_rec_in.VMI_MINIMUM_UNITS          :=  G_Item_Rec.VMI_MINIMUM_UNITS;
   l_Item_rec_in.VMI_MINIMUM_DAYS           :=  G_Item_Rec.VMI_MINIMUM_DAYS;
   l_Item_rec_in.VMI_MAXIMUM_UNITS          :=  G_Item_Rec.VMI_MAXIMUM_UNITS;
   l_Item_rec_in.VMI_MAXIMUM_DAYS           :=  G_Item_Rec.VMI_MAXIMUM_DAYS;
   l_Item_rec_in.VMI_FIXED_ORDER_QUANTITY   :=  G_Item_Rec.VMI_FIXED_ORDER_QUANTITY;
   l_Item_rec_in.SO_AUTHORIZATION_FLAG      :=  G_Item_Rec.SO_AUTHORIZATION_FLAG;
   l_Item_rec_in.CONSIGNED_FLAG             :=  G_Item_Rec.CONSIGNED_FLAG;
   l_Item_rec_in.ASN_AUTOEXPIRE_FLAG        :=  G_Item_Rec.ASN_AUTOEXPIRE_FLAG;
   l_Item_rec_in.VMI_FORECAST_TYPE          :=  G_Item_Rec.VMI_FORECAST_TYPE;
   l_Item_rec_in.FORECAST_HORIZON           :=  G_Item_Rec.FORECAST_HORIZON;
   l_Item_rec_in.EXCLUDE_FROM_BUDGET_FLAG   :=  G_Item_Rec.EXCLUDE_FROM_BUDGET_FLAG;
   l_Item_rec_in.DAYS_TGT_INV_SUPPLY        :=  G_Item_Rec.DAYS_TGT_INV_SUPPLY;
   l_Item_rec_in.DAYS_TGT_INV_WINDOW        :=  G_Item_Rec.DAYS_TGT_INV_WINDOW;
   l_Item_rec_in.DAYS_MAX_INV_SUPPLY        :=  G_Item_Rec.DAYS_MAX_INV_SUPPLY;
   l_Item_rec_in.DAYS_MAX_INV_WINDOW        :=  G_Item_Rec.DAYS_MAX_INV_WINDOW;
   l_Item_rec_in.DRP_PLANNED_FLAG           :=  G_Item_Rec.DRP_PLANNED_FLAG;
   l_Item_rec_in.CRITICAL_COMPONENT_FLAG    :=  G_Item_Rec.CRITICAL_COMPONENT_FLAG;
   l_Item_rec_in.CONTINOUS_TRANSFER         :=  G_Item_Rec.CONTINOUS_TRANSFER;
   l_Item_rec_in.CONVERGENCE                :=  G_Item_Rec.CONVERGENCE;
   l_Item_rec_in.DIVERGENCE                 :=  G_Item_Rec.DIVERGENCE;
   l_Item_rec_in.CONFIG_ORGS                :=  G_Item_Rec.CONFIG_ORGS;
   l_Item_rec_in.CONFIG_MATCH               :=  G_Item_Rec.CONFIG_MATCH;
   --End: 26 new attributes
   IF G_Item_Rec.Process_Item_Record NOT IN (1,2) THEN
      G_Item_Rec.Process_Item_Record := 1;
   END IF;
   l_Item_rec_in.Process_Item_Record        := G_Item_Rec.Process_Item_Record;

   -- Descriptive flex
   l_Item_rec_in.ATTRIBUTE_CATEGORY :=  G_Item_Rec.Attribute_Category;
   l_Item_rec_in.ATTRIBUTE1         :=  G_Item_Rec.Attribute1;
   l_Item_rec_in.ATTRIBUTE2         :=  G_Item_Rec.Attribute2;
   l_Item_rec_in.ATTRIBUTE3         :=  G_Item_Rec.Attribute3;
   l_Item_rec_in.ATTRIBUTE4         :=  G_Item_Rec.Attribute4;
   l_Item_rec_in.ATTRIBUTE5         :=  G_Item_Rec.Attribute5;
   l_Item_rec_in.ATTRIBUTE6         :=  G_Item_Rec.Attribute6;
   l_Item_rec_in.ATTRIBUTE7         :=  G_Item_Rec.Attribute7;
   l_Item_rec_in.ATTRIBUTE8         :=  G_Item_Rec.Attribute8;
   l_Item_rec_in.ATTRIBUTE9         :=  G_Item_Rec.Attribute9;
   l_Item_rec_in.ATTRIBUTE10        :=  G_Item_Rec.Attribute10;
   l_Item_rec_in.ATTRIBUTE11        :=  G_Item_Rec.Attribute11;
   l_Item_rec_in.ATTRIBUTE12        :=  G_Item_Rec.Attribute12;
   l_Item_rec_in.ATTRIBUTE13        :=  G_Item_Rec.Attribute13;
   l_Item_rec_in.ATTRIBUTE14        :=  G_Item_Rec.Attribute14;
   l_Item_rec_in.ATTRIBUTE15        :=  G_Item_Rec.Attribute15;
   l_Item_rec_in.ATTRIBUTE16        :=  G_Item_Rec.Attribute16;
   l_Item_rec_in.ATTRIBUTE17        :=  G_Item_Rec.Attribute17;
   l_Item_rec_in.ATTRIBUTE18        :=  G_Item_Rec.Attribute18;
   l_Item_rec_in.ATTRIBUTE19        :=  G_Item_Rec.Attribute19;
   l_Item_rec_in.ATTRIBUTE20        :=  G_Item_Rec.Attribute20;
   l_Item_rec_in.ATTRIBUTE21        :=  G_Item_Rec.Attribute21;
   l_Item_rec_in.ATTRIBUTE22        :=  G_Item_Rec.Attribute22;
   l_Item_rec_in.ATTRIBUTE23        :=  G_Item_Rec.Attribute23;
   l_Item_rec_in.ATTRIBUTE24        :=  G_Item_Rec.Attribute24;
   l_Item_rec_in.ATTRIBUTE25        :=  G_Item_Rec.Attribute25;
   l_Item_rec_in.ATTRIBUTE26        :=  G_Item_Rec.Attribute26;
   l_Item_rec_in.ATTRIBUTE27        :=  G_Item_Rec.Attribute27;
   l_Item_rec_in.ATTRIBUTE28        :=  G_Item_Rec.Attribute28;
   l_Item_rec_in.ATTRIBUTE29        :=  G_Item_Rec.Attribute29;
   l_Item_rec_in.ATTRIBUTE30        :=  G_Item_Rec.Attribute30;
   -- Global Descriptive flex
   l_Item_rec_in.GLOBAL_ATTRIBUTE_CATEGORY  :=  G_Item_Rec.Global_Attribute_Category;
   l_Item_rec_in.GLOBAL_ATTRIBUTE1          :=  G_Item_Rec.Global_Attribute1;
   l_Item_rec_in.GLOBAL_ATTRIBUTE2          :=  G_Item_Rec.Global_Attribute2;
   l_Item_rec_in.GLOBAL_ATTRIBUTE3          :=  G_Item_Rec.Global_Attribute3;
   l_Item_rec_in.GLOBAL_ATTRIBUTE4          :=  G_Item_Rec.Global_Attribute4;
   l_Item_rec_in.GLOBAL_ATTRIBUTE5          :=  G_Item_Rec.Global_Attribute5;
   l_Item_rec_in.GLOBAL_ATTRIBUTE6          :=  G_Item_Rec.Global_Attribute6;
   l_Item_rec_in.GLOBAL_ATTRIBUTE7          :=  G_Item_Rec.Global_Attribute7;
   l_Item_rec_in.GLOBAL_ATTRIBUTE8          :=  G_Item_Rec.Global_Attribute8;
   l_Item_rec_in.GLOBAL_ATTRIBUTE9          :=  G_Item_Rec.Global_Attribute9;
   l_Item_rec_in.GLOBAL_ATTRIBUTE10         :=  G_Item_Rec.Global_Attribute10;


   l_Item_rec_in.GLOBAL_ATTRIBUTE11          :=  G_Item_Rec.Global_Attribute11;
   l_Item_rec_in.GLOBAL_ATTRIBUTE12          :=  G_Item_Rec.Global_Attribute12;
   l_Item_rec_in.GLOBAL_ATTRIBUTE13          :=  G_Item_Rec.Global_Attribute13;
   l_Item_rec_in.GLOBAL_ATTRIBUTE14          :=  G_Item_Rec.Global_Attribute14;
   l_Item_rec_in.GLOBAL_ATTRIBUTE15          :=  G_Item_Rec.Global_Attribute15;
   l_Item_rec_in.GLOBAL_ATTRIBUTE16          :=  G_Item_Rec.Global_Attribute16;
   l_Item_rec_in.GLOBAL_ATTRIBUTE17          :=  G_Item_Rec.Global_Attribute17;
   l_Item_rec_in.GLOBAL_ATTRIBUTE18          :=  G_Item_Rec.Global_Attribute18;
   l_Item_rec_in.GLOBAL_ATTRIBUTE19          :=  G_Item_Rec.Global_Attribute19;
   l_Item_rec_in.GLOBAL_ATTRIBUTE20         :=  G_Item_Rec.Global_Attribute20;

      /* R12 Enhacement */

   l_Item_rec_in.CAS_NUMBER                 :=  G_Item_Rec.CAS_NUMBER;
   l_Item_rec_in.CHILD_LOT_FLAG             :=  G_Item_Rec.CHILD_LOT_FLAG;
   l_Item_rec_in.CHILD_LOT_PREFIX           :=  G_Item_Rec.CHILD_LOT_PREFIX;
   l_Item_rec_in.CHILD_LOT_STARTING_NUMBER  :=  G_Item_Rec.CHILD_LOT_STARTING_NUMBER;
   l_Item_rec_in.CHILD_LOT_VALIDATION_FLAG  :=  G_Item_Rec.CHILD_LOT_VALIDATION_FLAG;
   l_Item_rec_in.COPY_LOT_ATTRIBUTE_FLAG    :=  G_Item_Rec.COPY_LOT_ATTRIBUTE_FLAG;
   l_Item_rec_in.DEFAULT_GRADE              :=  G_Item_Rec.DEFAULT_GRADE;
   l_Item_rec_in.EXPIRATION_ACTION_CODE     :=  G_Item_Rec.EXPIRATION_ACTION_CODE;
   l_Item_rec_in.EXPIRATION_ACTION_INTERVAL :=  G_Item_Rec.EXPIRATION_ACTION_INTERVAL;
   l_Item_rec_in.GRADE_CONTROL_FLAG         :=  G_Item_Rec.GRADE_CONTROL_FLAG;
   l_Item_rec_in.HAZARDOUS_MATERIAL_FLAG    :=  G_Item_Rec.HAZARDOUS_MATERIAL_FLAG;
   l_Item_rec_in.HOLD_DAYS                  :=  G_Item_Rec.HOLD_DAYS;
   l_Item_rec_in.LOT_DIVISIBLE_FLAG         :=  G_Item_Rec.LOT_DIVISIBLE_FLAG;
   l_Item_rec_in.MATURITY_DAYS              :=  G_Item_Rec.MATURITY_DAYS;
   l_Item_rec_in.PARENT_CHILD_GENERATION_FLAG    :=  G_Item_Rec.PARENT_CHILD_GENERATION_FLAG;
   l_Item_rec_in.PROCESS_COSTING_ENABLED_FLAG    :=  G_Item_Rec.PROCESS_COSTING_ENABLED_FLAG;
   l_Item_rec_in.PROCESS_EXECUTION_ENABLED_FLAG  :=  G_Item_Rec.PROCESS_EXECUTION_ENABLED_FLAG;
   l_Item_rec_in.PROCESS_QUALITY_ENABLED_FLAG    :=  G_Item_Rec.PROCESS_QUALITY_ENABLED_FLAG;
   l_Item_rec_in.PROCESS_SUPPLY_LOCATOR_ID       :=  G_Item_Rec.PROCESS_SUPPLY_LOCATOR_ID;
   l_Item_rec_in.PROCESS_SUPPLY_SUBINVENTORY     :=  G_Item_Rec.PROCESS_SUPPLY_SUBINVENTORY;
   l_Item_rec_in.PROCESS_YIELD_LOCATOR_ID        :=  G_Item_Rec.PROCESS_YIELD_LOCATOR_ID;
   l_Item_rec_in.PROCESS_YIELD_SUBINVENTORY      :=  G_Item_Rec.PROCESS_YIELD_SUBINVENTORY;
   l_Item_rec_in.RECIPE_ENABLED_FLAG             :=  G_Item_Rec.RECIPE_ENABLED_FLAG;
   l_Item_rec_in.RETEST_INTERVAL                 :=  G_Item_Rec.RETEST_INTERVAL;
   l_Item_rec_in.CHARGE_PERIODICITY_CODE         :=  G_Item_Rec.CHARGE_PERIODICITY_CODE;
   l_Item_rec_in.REPAIR_LEADTIME                 :=  G_Item_Rec.REPAIR_LEADTIME;
   l_Item_rec_in.REPAIR_YIELD                    :=  G_Item_Rec.REPAIR_YIELD;
   l_Item_rec_in.PREPOSITION_POINT               :=  G_Item_Rec.PREPOSITION_POINT;
   l_Item_rec_in.REPAIR_PROGRAM                  :=  G_Item_Rec.REPAIR_PROGRAM;
   l_Item_rec_in.SUBCONTRACTING_COMPONENT        :=  G_Item_Rec.SUBCONTRACTING_COMPONENT ;
   l_Item_rec_in.OUTSOURCED_ASSEMBLY             :=  G_Item_Rec.OUTSOURCED_ASSEMBLY;
   --R12 C attributes
   l_Item_rec_in.GDSN_OUTBOUND_ENABLED_FLAG      :=  G_Item_Rec.GDSN_OUTBOUND_ENABLED_FLAG;
   l_Item_rec_in.TRADE_ITEM_DESCRIPTOR           :=  G_Item_Rec.TRADE_ITEM_DESCRIPTOR;
   l_item_rec_in.STYLE_ITEM_FLAG                 :=  G_Item_Rec.STYLE_ITEM_FLAG;
   l_item_rec_in.STYLE_ITEM_ID                   :=  G_Item_Rec.STYLE_ITEM_ID;

   -- Bug 9852661
   l_attributes_row_table := EGO_USER_ATTR_ROW_TABLE();
   l_attributes_data_table := EGO_USER_ATTR_DATA_TABLE();

   l_attr_row_count := 1;
   IF (G_Item_Rec.attributes_row_table  IS NOT NULL) THEN
    FOR i IN 1 .. G_Item_Rec.attributes_row_table.Count LOOP
      l_attributes_row_table.EXTEND;
      l_attributes_row_table(l_attr_row_count) :=  G_Item_Rec.attributes_row_table(i);
      l_attr_row_count := l_attr_row_count + 1;
    END LOOP;
   END IF;

   l_attr_data_count := 1;
   IF (G_Item_Rec.attributes_data_table  IS NOT NULL) THEN
    FOR i IN 1 .. G_Item_Rec.attributes_data_table.Count LOOP
      l_attributes_data_table.EXTEND;
      l_attributes_data_table(l_attr_data_count) :=  G_Item_Rec.attributes_data_table(i);
      l_attr_data_count := l_attr_data_count + 1;
    END LOOP;
   END IF;
   -- Bug 9852661

   --Start : Added revision record processing
   BEGIN
      IF NOT l_rev_index_failure THEN
         l_revision_rec.Transaction_Type           := G_Revision_Tbl(G_Item_indx).Transaction_Type;
         l_revision_rec.Inventory_Item_Id          := G_Revision_Tbl(G_Item_indx).Inventory_Item_Id;
         l_revision_rec.Item_Number                := G_Revision_Tbl(G_Item_indx).Item_Number;
         l_revision_rec.Organization_Id            := G_Revision_Tbl(G_Item_indx).Organization_Id;
         l_revision_rec.Revision_Id                := G_Revision_Tbl(G_Item_indx).Revision_Id;
         l_revision_rec.Revision_Code              := G_Revision_Tbl(G_Item_indx).Revision_Code;
         l_revision_rec.Revision_Label             := G_Revision_Tbl(G_Item_indx).Revision_Label;
         l_revision_rec.Description                := G_Revision_Tbl(G_Item_indx).Description;
         l_revision_rec.Effectivity_Date           := G_Revision_Tbl(G_Item_indx).Effectivity_Date;
         l_revision_rec.Lifecycle_Id               := G_Revision_Tbl(G_Item_indx).Lifecycle_Id;
         l_revision_rec.Current_Phase_Id           := G_Revision_Tbl(G_Item_indx).Current_Phase_Id;
         -- 5208102: Supporting template for UDA's at revisions
         l_revision_rec.template_Id                := G_Revision_Tbl(G_Item_indx).Template_Id;
         l_revision_rec.template_Name              := G_Revision_Tbl(G_Item_indx).Template_Name;

         l_revision_rec.Attribute_Category         := G_Revision_Tbl(G_Item_indx).Attribute_Category;
         l_revision_rec.Attribute1                 := G_Revision_Tbl(G_Item_indx).Attribute1;
         l_revision_rec.Attribute2                 := G_Revision_Tbl(G_Item_indx).Attribute2;
         l_revision_rec.Attribute3                 := G_Revision_Tbl(G_Item_indx).Attribute3;
         l_revision_rec.Attribute4                 := G_Revision_Tbl(G_Item_indx).Attribute4;
         l_revision_rec.Attribute5                 := G_Revision_Tbl(G_Item_indx).Attribute5;
         l_revision_rec.Attribute6                 := G_Revision_Tbl(G_Item_indx).Attribute6;
         l_revision_rec.Attribute7                 := G_Revision_Tbl(G_Item_indx).Attribute7;
         l_revision_rec.Attribute8                 := G_Revision_Tbl(G_Item_indx).Attribute8;
         l_revision_rec.Attribute9                 := G_Revision_Tbl(G_Item_indx).Attribute9;
         l_revision_rec.Attribute10                := G_Revision_Tbl(G_Item_indx).Attribute10;
         l_revision_rec.Attribute11                := G_Revision_Tbl(G_Item_indx).Attribute11;
         l_revision_rec.Attribute12                := G_Revision_Tbl(G_Item_indx).Attribute12;
         l_revision_rec.Attribute13                := G_Revision_Tbl(G_Item_indx).Attribute13;
         l_revision_rec.Attribute14                := G_Revision_Tbl(G_Item_indx).Attribute14;
         l_revision_rec.Attribute15                := G_Revision_Tbl(G_Item_indx).Attribute15;
      ELSE
         l_revision_rec := NULL;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         l_revision_rec := NULL;
         l_rev_index_failure := TRUE;
     -- Item and Item Rev should ideally be have same
     -- index and same number of pl/sql records.
   END;
   --End : Added revision record processing

   IF l_Process_Control = 'EGO_INTERFACE_HANDLER' THEN
      INV_ITEM_GRP.Interface_Handler
      (
         p_commit           => FND_API.G_TRUE
       ,p_transaction_type => G_Item_Rec.Transaction_Type
        ,p_Item_rec         => l_Item_rec_in
         ,P_revision_rec     => l_revision_rec
       ,p_Template_Id      => l_template_id
       ,P_Template_Name    => l_Template_Name
       ,x_batch_id         => l_Batch_id
       ,x_return_status    => l_return_status
       ,x_return_err       => l_return_err
      );

      FND_MESSAGE.set_name('INV', l_return_err); --Setting error message to be returned

   ELSIF ( G_Item_Rec.Transaction_Type = 'CREATE' ) THEN

      INV_ITEM_GRP.Create_Item
      (
         p_commit           =>  p_commit
      ,  p_Item_rec         =>  l_Item_rec_in
      ,  p_Revision_rec     =>  l_revision_rec
      ,  p_Template_Id      =>  l_Template_Id
      ,  p_Template_Name    =>  l_Template_Name
      ,  x_Item_rec         =>  l_Item_rec_out
      ,  x_return_status    =>  l_return_status
      ,  x_Error_tbl        =>  l_Error_tbl
      -- Bug 9092888, Bug 9852661 - Changes
      ,  p_attributes_row_table   => l_attributes_row_table  --       IN   EGO_USER_ATTR_ROW_TABLE DEFAULT NULL
      ,  p_attributes_data_table  => l_attributes_data_table --       IN   EGO_USER_ATTR_DATA_TABLE DEFAULT NULL
      -- Bug 9092888, Bug 9852661 - Changes
      );

      --Start 4105841 : Business Event Enhancement
      IF ( l_return_status = G_RET_STS_SUCCESS and  G_Item_Rec.Process_Item_Record = 1) THEN

        OPEN  c_get_org_code(cp_org_id => l_Item_rec_in.ORGANIZATION_ID);
        FETCH c_get_org_code INTO l_org_code_rec;
        CLOSE c_get_org_code;

        IF (INSTR(l_process_control,'PLM_UI:Y') = 0) THEN              --Bug: 4881908
         -----------------------------------------------------------------
   -- Get the functional Area deafulting Attribute Values for the
   -- Record and raise business Event.
   -----------------------------------------------------------------
         FOR DEFAULT_CAT_ASSIGN_REC IN DEFAULT_CAT_ASSIGN_CREATE(CP_ITEM_ID => l_Item_rec_out.INVENTORY_ITEM_ID ,CP_ORG_ID => l_Item_rec_out.ORGANIZATION_ID)
         LOOP
            EGO_WF_WRAPPER_PVT.Raise_Item_Event(
                                  p_event_name         => EGO_WF_WRAPPER_PVT.G_ITEM_CAT_ASSIGN_EVENT
                                 ,p_inventory_item_id  => l_Item_rec_out.INVENTORY_ITEM_ID
                                 ,p_organization_id    => l_Item_rec_in.ORGANIZATION_ID
         ,p_catalog_id         => DEFAULT_CAT_ASSIGN_REC.CATEGORY_SET_ID
                                 ,p_category_id        => DEFAULT_CAT_ASSIGN_REC.CATEGORY_ID
                                 ,x_msg_data           => l_msg_data
                                 ,x_return_status      => l_event_return_status);
         END LOOP;
   -----------------------------------------------------------------
         -- Fix for bug#8474046
         IF (l_org_code_rec.organization_code is not null) THEN
           l_wf_org_code := l_org_code_rec.organization_code;
         ELSE
           l_wf_org_code := l_Item_rec_in.organization_code;
         END IF;
     /* Fix for bug 8660792 - For raising item creation business event, pick the item_number and organization_id
        from l_Item_rec_out instead of l_Item_rec_in to avoid null values */
         EGO_WF_WRAPPER_PVT.Raise_Item_Create_Update_Event(
                                  p_event_name         => EGO_WF_WRAPPER_PVT.G_ITEM_CREATE_EVENT
                                 ,p_organization_id    => l_Item_rec_out.ORGANIZATION_ID
                                 ,p_organization_code  => l_wf_org_code -- fix for bug#8474046 l_org_code_rec.ORGANIZATION_CODE
                                 ,p_inventory_item_id  => l_Item_rec_out.INVENTORY_ITEM_ID
                                 ,p_item_number        => l_Item_rec_out.ITEM_NUMBER
                                 ,p_item_description   => l_Item_rec_in.DESCRIPTION
                                 ,x_msg_data           => l_msg_data
                                 ,x_return_status      => l_event_return_status);
   -----------------------------------------------------------------
   -- Default Revision Business Event Raising
   -----------------------------------------------------------------
         FOR REV_RECORDS_CREATE_REC IN REV_RECORDS_CREATE(CP_ITEM_ID => l_Item_rec_out.INVENTORY_ITEM_ID ,CP_ORG_ID => l_Item_rec_out.ORGANIZATION_ID)
         LOOP
          EGO_WF_WRAPPER_PVT.Raise_Item_Event(
                                  p_event_name         => EGO_WF_WRAPPER_PVT.G_REV_CHANGE_EVENT
                                 ,p_inventory_item_id  => l_Item_rec_out.INVENTORY_ITEM_ID
                                 ,p_organization_id    => l_Item_rec_in.ORGANIZATION_ID
                                 ,p_revision_id        => REV_RECORDS_CREATE_REC.REVISION_ID
                                 ,x_msg_data           => l_msg_data
                                 ,x_return_status      => l_event_return_status);
         END LOOP;
  -----------------------------------------------------------------
  END IF;

      /*Removed the call for default Revision creation
        Will be raising events for explicit actions only*/

        --Call ICX APIs
        BEGIN
           INV_ITEM_EVENTS_PVT.Invoke_ICX_APIs(
              p_entity_type       => 'ITEM'
             ,p_dml_type          => 'CREATE'
             ,p_inventory_item_id => l_Item_rec_out.INVENTORY_ITEM_ID
             ,p_item_number       => l_Item_rec_in.ITEM_NUMBER
             ,p_item_description  => l_Item_rec_in.DESCRIPTION
             ,p_organization_id   => l_Item_rec_in.ORGANIZATION_ID
             ,p_organization_code => l_org_code_rec.ORGANIZATION_CODE );
           EXCEPTION
              WHEN OTHERS THEN
                 NULL;
        END;
        --R12: Business Event Enhancement
      END IF;
      --End 4105841 : Business Event Enhancement

   ELSIF ( G_Item_Rec.Transaction_Type = 'UPDATE' ) THEN

   --- bug 7688289 , because inv_item_id , org_id may not be passed to the API below SQL will
        --- throw no_data_found , if not passed ids need to be derived
        ---
        --- added the INVPUOPI methods

          IF   ( l_Item_rec_in.INVENTORY_ITEM_ID = NULL OR
                        l_Item_rec_in.INVENTORY_ITEM_ID = G_MISS_NUM ) THEN
            l_dummy := 0;
            l_dummy := INVPUOPI.mtl_pr_parse_item_name
                                             (
                                             item_number_in  => l_Item_rec_in.ITEM_NUMBER
                                            ,item_id_out     => l_Item_rec_in.INVENTORY_ITEM_ID
                                            ,err_text        => l_error_text
                                             );

            IF l_dummy <> 0 THEN

              EGO_Item_Msg.Add_Error_Message
              (
                 p_Entity_Index      => G_Item_indx
              ,  p_Application_Short_Name => 'INV'
              ,  p_Message_Name      => 'INV_ICOI_INVALID_ITEM_NUMBER'
              ,  p_Token_Name1       => 'VALUE'
              ,  p_Token_Value1      => l_Item_rec_in.ITEM_NUMBER
              ,  p_Translate1        => FALSE
              );

              RAISE Item_or_Org_INVALID;

             END IF;
          END IF;

        IF   ( l_Item_rec_in.organization_id = NULL OR
                     l_Item_rec_in.organization_id = G_MISS_NUM ) THEN

          l_dummy := 0;
          l_dummy := INVPUOPI.mtl_pr_trans_org_id
                                         (
                                           org_code   => l_Item_rec_in.Organization_Code
                                          ,org_id     => l_Item_rec_in.organization_id
                                          ,err_text   => l_error_text
                                           );

          IF l_dummy <> 0 THEN
            x_return_status := G_RET_STS_ERROR;

            EGO_Item_Msg.Add_Error_Message
            (
               p_Entity_Index      => G_Item_indx
            ,  p_Application_Short_Name => 'INV'
            ,  p_Message_Name      => 'INV_ICOI_INVALID_ORG_CODE'
            ,  p_Token_Name1       => 'VALUE'
            ,  p_Token_Value1      => l_Item_rec_in.Organization_Code
            );
            RAISE Item_or_Org_INVALID;

          END IF;
        END IF;

        --- end 7688289

     BEGIN
    -----------------------------------------------------------------------
   -- added for bug 7431714
   SELECT item_catalog_group_id
   INTO l_curr_icc_id
   FROM MTL_SYSTEM_ITEMS_B
   WHERE inventory_item_id = l_Item_rec_in.INVENTORY_ITEM_ID
   AND organization_id = l_Item_rec_in.ORGANIZATION_ID;

   EXCEPTION
       WHEN NO_DATA_FOUND THEN

            x_return_status := G_RET_STS_ERROR;

            EGO_Item_Msg.Add_Error_Message
            (
               p_Entity_Index      => G_Item_indx
            ,  p_Application_Short_Name => 'INV'
            ,  p_Message_Name      => 'INV_INVALID_ITEM_ORG'
            );
       RAISE Item_or_Org_INVALID;
    END;

   IF (l_Item_rec_in.ITEM_CATALOG_GROUP_ID <> l_curr_icc_id
       AND l_Item_rec_in.ITEM_CATALOG_GROUP_ID <> G_MISS_NUM) THEN -- added condition for the bug 7422745
        -- Deleteing records for AGs that are not associated to the new ICC
        DELETE
        FROM    ego_mtl_sy_items_ext_b
        WHERE   inventory_item_id  = l_Item_rec_in.INVENTORY_ITEM_ID
        AND attr_group_id NOT IN
            (SELECT ATTR_GROUP_ID
            FROM    EGO_OBJ_ATTR_GRP_ASSOCS_V AGV,
                     FND_OBJECTS FO
            WHERE   AGV.OBJECT_ID = FO.OBJECT_ID
            AND AGV.OBJECT_NAME ='EGO_ITEM'
            AND AGV.CLASSIFICATION_CODE IS NOT NULL
            AND AGV.CLASSIFICATION_CODE IN
                 (SELECT TO_CHAR(item_catalog_group_id)
                 FROM    mtl_item_catalog_groups_b CONNECT BY prior parent_catalog_group_id = item_catalog_group_id
                 START WITH item_catalog_group_id   = l_Item_rec_in.ITEM_CATALOG_GROUP_ID
                 )
            UNION ALL
            SELECT  ATTR_GROUP_ID
            FROM    EGO_ATTR_GROUPS_V
            WHERE   APPLICATION_ID   = 431
            AND ATTR_GROUP_TYPE  = 'EGO_ITEMMGMT_GROUP'
            AND (ATTR_GROUP_NAME = 'ItemDetailDesc'
            OR ATTR_GROUP_NAME  = 'ItemDetailImage')
            );

        DELETE
        FROM    ego_mtl_sy_items_ext_tl
        WHERE   inventory_item_id  = l_Item_rec_in.INVENTORY_ITEM_ID
        AND attr_group_id NOT IN
            (SELECT ATTR_GROUP_ID
            FROM    EGO_OBJ_ATTR_GRP_ASSOCS_V AGV,
                    FND_OBJECTS FO
            WHERE   AGV.OBJECT_ID = FO.OBJECT_ID
            AND AGV.OBJECT_NAME ='EGO_ITEM'
            AND AGV.CLASSIFICATION_CODE IS NOT NULL
            AND AGV.CLASSIFICATION_CODE IN
                 (SELECT TO_CHAR(item_catalog_group_id)
                 FROM    mtl_item_catalog_groups_b CONNECT BY prior parent_catalog_group_id = item_catalog_group_id
                 START WITH item_catalog_group_id   = l_Item_rec_in.ITEM_CATALOG_GROUP_ID
                 )
            UNION ALL
            SELECT  ATTR_GROUP_ID
            FROM    EGO_ATTR_GROUPS_V
            WHERE   APPLICATION_ID   = 431
            AND ATTR_GROUP_TYPE  = 'EGO_ITEMMGMT_GROUP'
            AND (ATTR_GROUP_NAME = 'ItemDetailDesc'
            OR ATTR_GROUP_NAME  = 'ItemDetailImage')
            );
    l_icc_change_flag:= TRUE;
   END IF;
   -- end adding for bug 7431714

    IF (INSTR(l_process_control,'PLM_UI:Y') = 0) THEN
      l_cat_tab_index := 1 ;
      FOR DEFAULT_CAT_ASSIGN_REC IN DEFAULT_CAT_ASSIGN_CREATE(CP_ITEM_ID => l_Item_rec_in.INVENTORY_ITEM_ID ,CP_ORG_ID => l_Item_rec_in.ORGANIZATION_ID)
      LOOP
  l_cat_assign_rec_table_bef(l_cat_tab_index).CATEGORY_SET_ID    := DEFAULT_CAT_ASSIGN_REC.CATEGORY_SET_ID;
  l_cat_assign_rec_table_bef(l_cat_tab_index).CATEGORY_ID        := DEFAULT_CAT_ASSIGN_REC.CATEGORY_ID;
  l_cat_assign_rec_table_bef(l_cat_tab_index).INVENTORY_ITEM_ID  := l_Item_rec_in.INVENTORY_ITEM_ID;
  l_cat_assign_rec_table_bef(l_cat_tab_index).ORGANIZATION_ID    := l_Item_rec_in.ORGANIZATION_ID;
        l_cat_tab_index := l_cat_tab_index + 1 ;
      END LOOP;
    END IF;
---------------------------------------------------------------------------
      INV_Item_GRP.Update_Item
      (
         p_commit           =>  p_commit
      ,  p_Item_rec         =>  l_Item_rec_in
      ,  p_Revision_rec     =>  l_revision_rec
      ,  p_Template_Id      =>  l_Template_Id
      ,  p_Template_Name    =>  l_Template_Name
      ,  x_Item_rec         =>  l_Item_rec_out
      ,  x_return_status    =>  l_return_status
      ,  x_Error_tbl        =>  l_Error_tbl
      );

      --Start 4105841 : Business Event Enhancement
      IF ( l_return_status = G_RET_STS_SUCCESS
              and  G_Item_Rec.Process_Item_Record = 1) THEN
        OPEN  c_get_org_code(cp_org_id => l_Item_rec_in.ORGANIZATION_ID);
        FETCH c_get_org_code INTO l_org_code_rec;
        CLOSE c_get_org_code;

        --Bug 4586769  Fetch Item Description and number if NULL
  IF (   trim(l_item_rec_in.DESCRIPTION)   IS NULL
      OR      l_item_rec_in.DESCRIPTION = G_MISS_CHAR
      OR trim(l_Item_rec_in.ITEM_NUMBER)  IS NULL) THEN
           SELECT CONCATENATED_SEGMENTS, DESCRIPTION
       INTO l_item_number, l_item_desc
             FROM MTL_SYSTEM_ITEMS_KFV
            WHERE inventory_item_id = l_Item_rec_in.INVENTORY_ITEM_ID
        AND organization_id   = l_Item_rec_in.ORGANIZATION_ID;
        ELSE
     l_item_desc   := l_item_rec_in.DESCRIPTION;
     l_item_number := l_item_rec_in.ITEM_NUMBER;
  END IF;
        IF (INSTR(l_process_control,'PLM_UI:Y') = 0) THEN        --Bug: 4881908
        -------------------------------------------------------------------------
  -- Implicit Business Event for Cat assignments on Update
  -------------------------------------------------------------------------
        l_cat_tab_index := 1 ;
        FOR DEFAULT_CAT_ASSIGN_REC IN DEFAULT_CAT_ASSIGN_UPDATE(CP_ITEM_ID => l_Item_rec_out.INVENTORY_ITEM_ID ,CP_ORG_ID => l_Item_rec_out.ORGANIZATION_ID)
        LOOP
    l_cat_match := FND_API.G_FALSE;
    l_cat_assign_rec_table_aft(l_cat_tab_index).CATEGORY_SET_ID    := DEFAULT_CAT_ASSIGN_REC.CATEGORY_SET_ID;
    l_cat_assign_rec_table_aft(l_cat_tab_index).CATEGORY_ID        := DEFAULT_CAT_ASSIGN_REC.CATEGORY_ID;
    l_cat_assign_rec_table_aft(l_cat_tab_index).INVENTORY_ITEM_ID  := l_Item_rec_out.INVENTORY_ITEM_ID;
      l_cat_assign_rec_table_aft(l_cat_tab_index).ORGANIZATION_ID    := l_Item_rec_in.ORGANIZATION_ID;
    IF l_cat_assign_rec_table_bef IS NOT NULL AND l_cat_assign_rec_table_bef.FIRST IS NOT NULL THEN
            FOR CAT_REC_BEF IN l_cat_assign_rec_table_bef.FIRST .. l_cat_assign_rec_table_bef.LAST
        LOOP
                IF l_cat_assign_rec_table_aft(l_cat_tab_index).CATEGORY_SET_ID = l_cat_assign_rec_table_bef(CAT_REC_BEF).CATEGORY_SET_ID THEN
            l_cat_match := FND_API.G_TRUE;
          ELSE
           NULL;
          END IF;
       END LOOP;
    END IF;
          IF l_cat_match = FND_API.G_FALSE THEN
              EGO_WF_WRAPPER_PVT.Raise_Item_Event(
                   p_event_name         => EGO_WF_WRAPPER_PVT.G_ITEM_CAT_ASSIGN_EVENT
      ,p_inventory_item_id  => l_cat_assign_rec_table_aft(l_cat_tab_index).INVENTORY_ITEM_ID
      ,p_organization_id    => l_cat_assign_rec_table_aft(l_cat_tab_index).ORGANIZATION_ID
                  ,p_catalog_id         => TO_CHAR(l_cat_assign_rec_table_aft(l_cat_tab_index).CATEGORY_SET_ID)
                  ,p_category_id        => TO_CHAR(l_cat_assign_rec_table_aft(l_cat_tab_index).CATEGORY_ID)
                  ,x_msg_data           => l_msg_data
                  ,x_return_status      => l_event_return_status);
    END IF ;
         l_cat_tab_index := l_cat_tab_index + 1 ;
        END LOOP;
        EGO_WF_WRAPPER_PVT.Raise_Item_Create_Update_Event(
                p_event_name         => EGO_WF_WRAPPER_PVT.G_ITEM_UPDATE_EVENT
               ,p_organization_id    => l_Item_rec_in.ORGANIZATION_ID
               ,p_organization_code  => l_org_code_rec.ORGANIZATION_CODE
               ,p_inventory_item_id  => l_Item_rec_in.INVENTORY_ITEM_ID
               ,p_item_number        => l_item_number
               ,p_item_description   => l_item_desc
               ,x_msg_data           => l_msg_data
               ,x_return_status      => l_event_return_status);
  -------------------------------------------------------------------------
   BEGIN
    SELECT REVISION_ID INTO l_revision_id_out
      FROM MTL_ITEM_REVISIONS_B
     WHERE INVENTORY_ITEM_ID  = l_Item_rec_out.INVENTORY_ITEM_ID
       AND ORGANIZATION_ID    = l_Item_rec_in.ORGANIZATION_ID
       AND REVISION           = l_revision_rec.Revision_Code ;
   EXCEPTION
    WHEN NO_DATA_FOUND
     THEN
       l_revision_id_out := NULL;
   END;
   IF l_revision_id_out IS NOT NULL
   THEN
     EGO_WF_WRAPPER_PVT.Raise_Item_Event(
                                  p_event_name         => EGO_WF_WRAPPER_PVT.G_REV_CHANGE_EVENT
                                 ,p_inventory_item_id  => l_Item_rec_out.INVENTORY_ITEM_ID
                                 ,p_organization_id    => l_Item_rec_in.ORGANIZATION_ID
                                 ,p_revision_id        => l_revision_id_out
                                 ,x_msg_data           => l_msg_data
                                 ,x_return_status      => l_event_return_status);

         END IF;
  END IF;
        /*Removed the call for updates to child orgs
         Will be raising events for explicit actions only*/

        --Call ICX APIs
        BEGIN
           INV_ITEM_EVENTS_PVT.Invoke_ICX_APIs(
              p_entity_type       => 'ITEM'
             ,p_dml_type          => 'UPDATE'
             ,p_inventory_item_id => l_Item_rec_in.INVENTORY_ITEM_ID
             ,p_item_number       => l_item_number
             ,p_item_description  => l_item_desc
             ,p_organization_id   => l_Item_rec_in.ORGANIZATION_ID
             ,p_organization_code => l_org_code_rec.ORGANIZATION_CODE );
           EXCEPTION
              WHEN OTHERS THEN
                 NULL;
        END;
        --R12: Business Event Enhancement
      END IF;
      --End 4105841 : Business Event Enhancement
      --- added for bug 7431714
/* Bug 8400788 Adding the condition to check the l_return_status */
      IF ( l_return_status = G_RET_STS_SUCCESS
              and  G_Item_Rec.Process_Item_Record = 1) THEN

         IF (l_icc_change_flag) THEN
             EGO_ITEM_PUB.Update_Item_Attr_Ext(
                          P_API_VERSION           => 1.0,
                          P_INIT_MSG_LIST         => l_init_msg_list,
                          P_COMMIT                => P_COMMIT,
                          P_INVENTORY_ITEM_ID     => l_Item_rec_in.INVENTORY_ITEM_ID,
                          P_ITEM_CATALOG_GROUP_ID => l_Item_rec_in.ITEM_CATALOG_GROUP_ID,
                          x_return_status         => l_return_status,
                          X_MSG_COUNT             => l_msg_count);

         END IF;
      -- end adding for bug 7431714
      END IF; --Bug8400788
   END IF;

   -----------------------------------------------------------------------------
   --  Re-populate item record back to the global table.
   -----------------------------------------------------------------------------

   IF l_process_control = 'EGO_INTERFACE_HANDLER' THEN
      G_Item_Tbl(G_Item_indx).Inventory_Item_Id := l_batch_id;
   ELSIF G_Item_Rec.Process_Item_Record = 1 THEN
      G_Item_Tbl(G_Item_indx).Inventory_Item_Id          :=  l_Item_rec_out.INVENTORY_ITEM_ID;
      G_Item_Tbl(G_Item_indx).Organization_Id            :=  l_Item_rec_out.ORGANIZATION_ID;
      G_Item_Tbl(G_Item_indx).Item_Catalog_Group_Id      :=  l_Item_rec_out.ITEM_CATALOG_GROUP_ID;
      G_Item_Tbl(G_Item_indx).Description                :=  l_Item_rec_out.DESCRIPTION;
      G_Item_Tbl(G_Item_indx).Long_Description           :=  l_Item_rec_out.LONG_DESCRIPTION;
      G_Item_Tbl(G_Item_indx).Primary_Uom_Code           :=  l_Item_rec_out.PRIMARY_UOM_CODE;
      G_Item_Tbl(G_Item_indx).Allowed_Units_Lookup_Code  :=  l_Item_rec_out.ALLOWED_UNITS_LOOKUP_CODE;
      G_Item_Tbl(G_Item_indx).Inventory_Item_Status_Code :=  l_Item_rec_out.INVENTORY_ITEM_STATUS_CODE;
      G_Item_Tbl(G_Item_indx).Bom_Enabled_Flag           :=  l_Item_rec_out.BOM_ENABLED_FLAG;
      G_Item_Tbl(G_Item_indx).Eng_Item_Flag              :=  l_Item_rec_out.ENG_ITEM_FLAG;

   END IF;

   G_Item_Tbl(G_Item_indx).Return_Status              :=  l_return_status;


   IF ( l_return_status <> G_RET_STS_SUCCESS ) THEN
      x_return_status  :=  l_return_status;
   END IF;

   l_msg_count  :=  l_msg_count + NVL(l_Error_tbl.COUNT, 0);
   x_msg_count  :=  l_msg_count;

   -----------------------------------------------------------------------------
   --  Populate the item error message table.
   -----------------------------------------------------------------------------

   FOR errno IN 1 .. NVL(l_Error_tbl.LAST, 0) LOOP

      IF ( l_Error_tbl(errno).MESSAGE_TEXT IS NOT NULL ) THEN
         EGO_Item_Msg.Add_Error_Text (G_Item_indx, l_Error_tbl(errno).MESSAGE_TEXT);
      ELSE
         EGO_Item_Msg.Add_Error_Message (G_Item_indx, 'INV', l_Error_tbl(errno).MESSAGE_NAME);
      END IF;

   END LOOP;  -- l_Error_tbl

   -----------------------------------------------------------------------------
   --  Assign the next value of the global index variable of the global table.
   -----------------------------------------------------------------------------

   G_Item_indx  :=  G_Item_indx + 1;

 END LOOP;  -- G_Item_Tbl

EXCEPTION
     WHEN Item_or_Org_INVALID THEN
          x_return_status  :=  G_RET_STS_ERROR;

   WHEN others THEN
      x_return_status  :=  G_RET_STS_UNEXP_ERROR;
      EGO_Item_Msg.Add_Error_Message ( G_Item_indx, 'INV', 'INV_ITEM_UNEXPECTED_ERROR',
                                       'PACKAGE_NAME', G_PKG_NAME, FALSE,
                                       'PROCEDURE_NAME', l_api_name, FALSE,
                                       'ERROR_TEXT', SQLERRM, FALSE );
END Process_Items;


-- -----------------------------------------------------------------------------
--  API Name:       Process_Item_Org_Assignments
-- -----------------------------------------------------------------------------

PROCEDURE Process_Item_Org_Assignments
(
   p_commit         IN      VARCHAR2      DEFAULT  FND_API.g_FALSE
,  x_return_status      OUT NOCOPY  VARCHAR2
,  x_msg_count          OUT NOCOPY  NUMBER
)
IS
   CURSOR c_get_item_rev_rec (cp_item_id NUMBER
                             ,cp_org_id  NUMBER) IS
      SELECT item.concatenated_segments
            ,item.description
      ,item.organization_id
      ,rev.revision_id
      FROM  mtl_system_items_b_kfv item
           ,mtl_item_revisions_b rev
      WHERE item.inventory_item_id       = cp_item_id
      AND   item.organization_id         = cp_org_id
      AND   rev.inventory_item_id        = cp_item_id
      AND   rev.organization_id          = cp_org_id;

   l_api_name       CONSTANT    VARCHAR2(30)  :=  'Process_Item_Org_Assignments';
   l_return_status              VARCHAR2(1) :=  G_MISS_CHAR;
   l_msg_count                  NUMBER      :=  0;
   l_Item_Org_Assignment_Rec    EGO_Item_PUB.Item_Org_Assignment_Rec_Type;
   l_Item_rec_in                INV_ITEM_GRP.Item_Rec_Type;
   l_revision_rec               INV_ITEM_GRP.Item_Revision_Rec_Type;
   l_rev_index_failure          BOOLEAN := FALSE;
   l_Item_rec_out               INV_ITEM_GRP.Item_Rec_Type;
   l_Error_tbl                  INV_ITEM_GRP.Error_Tbl_Type;
   l_master_org                 INV.MTL_SYSTEM_ITEMS_B.ORGANIZATION_ID%TYPE;
   l_event_return_status VARCHAR2(1) ; --business event enhancement
   l_item_rev_rec        c_get_item_rev_rec%ROWTYPE;
   l_msg_data            VARCHAR2(2000);
   l_process_control     VARCHAR2(2000)  :=  INV_EGO_REVISION_VALIDATE.Get_Process_Control;  --Bug: 4881908

BEGIN
   x_return_status  :=  G_RET_STS_SUCCESS;

   -- Loop through item records in the global table
   G_Item_Org_indx  :=  G_Item_Org_Assignment_Tbl.FIRST;

 WHILE G_Item_Org_indx <= G_Item_Org_Assignment_Tbl.LAST LOOP

   -- Clear the Item GRP API message table before processing an item
   l_Error_tbl.DELETE;

   l_Item_Org_Assignment_Rec  :=  G_Item_Org_Assignment_Tbl(G_Item_Org_indx);

   -- Item identifier
   l_Item_rec_in.INVENTORY_ITEM_ID      :=  l_Item_Org_Assignment_Rec.Inventory_Item_Id;
   l_Item_rec_in.ITEM_NUMBER            :=  l_Item_Org_Assignment_Rec.Item_Number;
   -- Organization
   l_Item_rec_in.ORGANIZATION_ID        :=  l_Item_Org_Assignment_Rec.Organization_Id;
   l_Item_rec_in.ORGANIZATION_CODE      :=  l_Item_Org_Assignment_Rec.Organization_Code;
   --Fix for Bug# 2768532
   l_Item_rec_in.PRIMARY_UOM_CODE       :=  l_Item_Org_Assignment_Rec.Primary_Uom_Code;

   --Start : Added revision record processing
   BEGIN
      IF NOT l_rev_index_failure THEN
         l_revision_rec.Transaction_Type           := G_Revision_Tbl(G_Item_indx).Transaction_Type;
         l_revision_rec.Inventory_Item_Id          := G_Revision_Tbl(G_Item_indx).Inventory_Item_Id;
         l_revision_rec.Item_Number                := G_Revision_Tbl(G_Item_indx).Item_Number;
         l_revision_rec.Organization_Id            := G_Revision_Tbl(G_Item_indx).Organization_Id;
         l_revision_rec.Revision_Id                := G_Revision_Tbl(G_Item_indx).Revision_Id;
         l_revision_rec.Revision_Code              := G_Revision_Tbl(G_Item_indx).Revision_Code;
         l_revision_rec.Revision_Label             := G_Revision_Tbl(G_Item_indx).Revision_Label;
         l_revision_rec.Description                := G_Revision_Tbl(G_Item_indx).Description;
         l_revision_rec.Effectivity_Date           := G_Revision_Tbl(G_Item_indx).Effectivity_Date;
         l_revision_rec.Lifecycle_Id               := G_Revision_Tbl(G_Item_indx).Lifecycle_Id;
         l_revision_rec.Current_Phase_Id           := G_Revision_Tbl(G_Item_indx).Current_Phase_Id;
         -- 5208102: Supporting template for UDA's at revisions
         l_revision_rec.template_Id                := G_Revision_Tbl(G_Item_indx).Template_Id;
         l_revision_rec.template_Name              := G_Revision_Tbl(G_Item_indx).Template_Name;

         l_revision_rec.Attribute_Category         := G_Revision_Tbl(G_Item_indx).Attribute_Category;
         l_revision_rec.Attribute1                 := G_Revision_Tbl(G_Item_indx).Attribute1;
         l_revision_rec.Attribute2                 := G_Revision_Tbl(G_Item_indx).Attribute2;
         l_revision_rec.Attribute3                 := G_Revision_Tbl(G_Item_indx).Attribute3;
         l_revision_rec.Attribute4                 := G_Revision_Tbl(G_Item_indx).Attribute4;
         l_revision_rec.Attribute5                 := G_Revision_Tbl(G_Item_indx).Attribute5;
         l_revision_rec.Attribute6                 := G_Revision_Tbl(G_Item_indx).Attribute6;
         l_revision_rec.Attribute7                 := G_Revision_Tbl(G_Item_indx).Attribute7;
         l_revision_rec.Attribute8                 := G_Revision_Tbl(G_Item_indx).Attribute8;
         l_revision_rec.Attribute9                 := G_Revision_Tbl(G_Item_indx).Attribute9;
         l_revision_rec.Attribute10                := G_Revision_Tbl(G_Item_indx).Attribute10;
         l_revision_rec.Attribute11                := G_Revision_Tbl(G_Item_indx).Attribute11;
         l_revision_rec.Attribute12                := G_Revision_Tbl(G_Item_indx).Attribute12;
         l_revision_rec.Attribute13                := G_Revision_Tbl(G_Item_indx).Attribute13;
         l_revision_rec.Attribute14                := G_Revision_Tbl(G_Item_indx).Attribute14;
         l_revision_rec.Attribute15                := G_Revision_Tbl(G_Item_indx).Attribute15;
      ELSE
         l_revision_rec := NULL;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         l_revision_rec := NULL;
         l_rev_index_failure := TRUE;
     -- Item and Item Rev should ideally be have same
     -- index and same number of pl/sql records.
   END;
   --End : Added revision record processing


   INV_ITEM_GRP.Create_Item
      (
         p_commit           =>  p_commit
      ,  p_Item_rec         =>  l_Item_rec_in
      ,  p_Revision_rec     =>  l_revision_rec
      ,  p_Template_Id      =>  NULL
      ,  p_Template_Name    =>  NULL
      ,  x_Item_rec         =>  l_Item_rec_out
      ,  x_return_status    =>  l_return_status
      ,  x_Error_tbl        =>  l_Error_tbl
      );



   G_Item_Org_Assignment_Tbl(G_Item_Org_indx).Return_Status  :=  l_return_status;

   IF ( l_return_status <> G_RET_STS_SUCCESS ) THEN
      x_return_status  :=  l_return_status;
/*Fix for Bug 4013187*/
   ELSE /*Copy the Description into TL tables for all the languages supported*/
      SELECT MASTER_ORGANIZATION_ID INTO l_master_org
      FROM mtl_parameters
      WHERE ORGANIZATION_ID = l_Item_rec_in.ORGANIZATION_ID;

      UPDATE MTL_SYSTEM_ITEMS_TL ASSIGNEE
      SET (ASSIGNEE.DESCRIPTION, ASSIGNEE.LONG_DESCRIPTION, ASSIGNEE.SOURCE_LANG)
                               = (SELECT DESCRIPTION, LONG_DESCRIPTION, SOURCE_LANG
                              FROM MTL_SYSTEM_ITEMS_TL MASTER
                                  WHERE INVENTORY_ITEM_ID = l_Item_rec_in.INVENTORY_ITEM_ID
                      AND ORGANIZATION_ID =L_MASTER_ORG
                                  AND MASTER."LANGUAGE" = ASSIGNEE."LANGUAGE")
         WHERE INVENTORY_ITEM_ID = l_Item_rec_in.INVENTORY_ITEM_ID
     AND ORGANIZATION_ID = l_Item_rec_in.ORGANIZATION_ID;

     --Start 4105841 : Business Event Enhancement
      IF ( l_return_status = G_RET_STS_SUCCESS ) THEN
        OPEN  c_get_item_rev_rec (cp_item_id => l_Item_rec_in.INVENTORY_ITEM_ID
                                 ,cp_org_id  => l_Item_rec_in.ORGANIZATION_ID);

        FETCH c_get_item_rev_rec INTO l_item_rev_rec;
        CLOSE c_get_item_rev_rec;

        IF (INSTR(l_process_control,'PLM_UI:Y') = 0) THEN              --Bug: 4881908
           EGO_WF_WRAPPER_PVT.Raise_Item_Create_Update_Event(
                                  p_event_name         => EGO_WF_WRAPPER_PVT.G_ITEM_CREATE_EVENT
                                 ,p_organization_id    => l_Item_rec_in.ORGANIZATION_ID
                                 ,p_organization_code  => l_Item_rec_in.ORGANIZATION_CODE
                                 ,p_inventory_item_id  => l_Item_rec_in.INVENTORY_ITEM_ID
                                 ,p_item_number        => l_item_rev_rec.concatenated_segments
                                 ,p_item_description   => l_item_rev_rec.description
                                 ,x_msg_data           => l_msg_data
                                 ,x_return_status      => l_event_return_status);
  END IF;
      /*Removed the call for default Revision creation
        Will be raising events for explicit actions only*/
        --Call ICX APIs
        BEGIN
           INV_ITEM_EVENTS_PVT.Invoke_ICX_APIs(
              p_entity_type       => 'ITEM'
             ,p_dml_type          => 'CREATE'
             ,p_inventory_item_id => l_Item_rec_in.INVENTORY_ITEM_ID
             ,p_item_number       => l_item_rev_rec.concatenated_segments
             ,p_item_description  => l_item_rev_rec.description
             ,p_organization_id   => l_Item_rec_in.ORGANIZATION_ID
             ,p_organization_code => l_Item_rec_in.ORGANIZATION_CODE );
           EXCEPTION
              WHEN OTHERS THEN
                 NULL;
        END;
        --R12: Business Event Enhancement

      --End 4105841 : Business Event Enhancement
     END IF;
   END IF;

   l_msg_count  :=  l_msg_count + NVL(l_Error_tbl.COUNT, 0);
   x_msg_count  :=  l_msg_count;

   FOR errno IN 1 .. NVL(l_Error_tbl.LAST, 0) LOOP

      IF ( l_Error_tbl(errno).MESSAGE_TEXT IS NOT NULL ) THEN
         EGO_Item_Msg.Add_Error_Text (G_Item_Org_indx, l_Error_tbl(errno).MESSAGE_TEXT);
      ELSE
         EGO_Item_Msg.Add_Error_Message (G_Item_Org_indx, 'INV', l_Error_tbl(errno).MESSAGE_NAME);
      END IF;

   END LOOP;  -- l_Error_tbl

   G_Item_Org_indx  :=  G_Item_Org_indx + 1;

 END LOOP;  -- G_Item_Org_Assignment_Tbl


EXCEPTION

   WHEN others THEN
      x_return_status  :=  G_RET_STS_UNEXP_ERROR;
      EGO_Item_Msg.Add_Error_Message ( G_Item_Org_indx, 'INV', 'INV_ITEM_UNEXPECTED_ERROR',
                                       'PACKAGE_NAME', G_PKG_NAME, FALSE,
                                       'PROCEDURE_NAME', l_api_name, FALSE,
                                       'ERROR_TEXT', SQLERRM, FALSE );

END Process_Item_Org_Assignments;

-- -----------------------------------------------------------------------------
--  API Name:       Seed_Item_Long_Desc_Attr_Group
--
--  Description:
--    Add a row to the User-Defined Attribute Group 'Detailed Descriptions'
--    so that the Item Long Description is shown on the Item Detail page.
-- -----------------------------------------------------------------------------

PROCEDURE Seed_Item_Long_Desc_Attr_Group (
        p_inventory_item_id             IN  NUMBER
       ,p_organization_id               IN  NUMBER
       ,p_item_catalog_group_id         IN  NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Seed_Item_Long_Desc_Attr_Group';

    l_pk_column_values       EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_class_code_values      EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_label                  VARCHAR2(80);
    l_attr_value_info_table  EGO_USER_ATTR_DATA_TABLE;

  BEGIN

    l_pk_column_values := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                            EGO_COL_NAME_VALUE_PAIR_OBJ('INVENTORY_ITEM_ID', p_inventory_item_id)
                           ,EGO_COL_NAME_VALUE_PAIR_OBJ('ORGANIZATION_ID', p_organization_id)
                          );

    l_class_code_values := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                             EGO_COL_NAME_VALUE_PAIR_OBJ('ITEM_CATALOG_GROUP_ID', NVL(p_item_catalog_group_id, -1))
                           );

    SELECT DISPLAY_NAME
      INTO l_label
      FROM EGO_VALUE_SET_VALUES_V
     WHERE VALUE_SET_NAME = 'DescSource'
       AND INTERNAL_NAME = 'D';

    l_attr_value_info_table := EGO_USER_ATTR_DATA_TABLE(
                                 EGO_USER_ATTR_DATA_OBJ(1, 'Sequence', null, 10, null, null, null, null)
                                ,EGO_USER_ATTR_DATA_OBJ(1, 'DescriptionSource', 'D', null, null, null, null, null)
                                ,EGO_USER_ATTR_DATA_OBJ(1, 'Label', l_label, null, null, null, null, null)
                                ,EGO_USER_ATTR_DATA_OBJ(1, 'DisplayMode', 'AsText', null, null, null, null, null)
                               );

    EGO_USER_ATTRS_DATA_PVT.Perform_DML_On_Row(
        p_api_version                   => 1.0
       ,p_object_name                   => 'EGO_ITEM'
       ,p_application_id                => 431
       ,p_attr_group_type               => 'EGO_ITEMMGMT_GROUP'
       ,p_attr_group_name               => 'ItemDetailDesc'
       ,p_pk_column_name_value_pairs    => l_pk_column_values
       ,p_class_code_name_value_pairs   => l_class_code_values
       ,p_data_level_name_value_pairs   => NULL
       ,p_attr_name_value_pairs         => l_attr_value_info_table
       ,x_return_status                 => x_return_status
       ,x_errorcode                     => x_errorcode
       ,x_msg_count                     => x_msg_count
       ,x_msg_data                      => x_msg_data
    );

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;

END Seed_Item_Long_Desc_Attr_Group;

-- -----------------------------------------------------------------------------
--  API Name:       Seed_Item_Long_Desc_In_Bulk
--
--    Add a row to the User-Defined Attribute Group 'Detailed Descriptions'
--    for all newly created items in the set identified by p_set_process_id
-- -----------------------------------------------------------------------------

PROCEDURE Seed_Item_Long_Desc_In_Bulk (
        p_set_process_id                IN  NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Seed_Item_Long_Desc_In_Bulk';
    l_attr_group_id          NUMBER;
    --commented out as a part of Bug 4906499
    --l_label                  VARCHAR2(80);
BEGIN

    -----------------------------------------------------------
    -- Find the Attr Group ID and Label we will be inserting --
    -----------------------------------------------------------
    SELECT ATTR_GROUP_ID
      INTO l_attr_group_id
      FROM EGO_FND_DSC_FLX_CTX_EXT
     WHERE APPLICATION_ID = 431
       AND DESCRIPTIVE_FLEXFIELD_NAME = 'EGO_ITEMMGMT_GROUP'
       AND DESCRIPTIVE_FLEX_CONTEXT_CODE = 'ItemDetailDesc';
    --commented out as a part of Bug 4906499
    /*SELECT DISPLAY_NAME
      INTO l_label
      FROM EGO_VALUE_SET_VALUES_V
     WHERE VALUE_SET_NAME = 'DescSource'
       AND INTERNAL_NAME = 'D';*/

    ----------------------------------------------------------------------
    -- Insert a row for every newly created item in the interface table --
    ----------------------------------------------------------------------
    INSERT INTO EGO_MTL_SY_ITEMS_EXT_B
    (
      EXTENSION_ID
     ,ORGANIZATION_ID
     ,INVENTORY_ITEM_ID
     ,ITEM_CATALOG_GROUP_ID
     ,ATTR_GROUP_ID
     ,CREATED_BY
     ,CREATION_DATE
     ,LAST_UPDATED_BY
     ,LAST_UPDATE_DATE
     ,N_EXT_ATTR1
     ,C_EXT_ATTR1
--     ,C_EXT_ATTR2 -- commented out as a part of Bug 4906499
     ,C_EXT_ATTR4
     ,DATA_LEVEL_ID --Added for bug 6155995
    )
    SELECT EGO_EXTFWK_S.NEXTVAL
          ,MTL.ORGANIZATION_ID
          ,MTL.INVENTORY_ITEM_ID
          ,NVL(MTL.ITEM_CATALOG_GROUP_ID, -1)
          ,l_attr_group_id
          ,1
          ,SYSDATE
          ,1
          ,SYSDATE
          ,10
          ,'D'
--          ,l_label  --commented out as a part of Bug 4906499
          ,'AsText'
    ,43102  --Added for bug 6155995
      FROM MTL_SYSTEM_ITEMS_INTERFACE MTL
     WHERE MTL.SET_PROCESS_ID = p_set_process_id
       AND MTL.PROCESS_FLAG = 4
       AND MTL.TRANSACTION_TYPE = 'CREATE';

    -----------------------------------------------------------------------------
    -- Insert corresponding rows in the TL table for each B table row we added --
    -----------------------------------------------------------------------------
    INSERT INTO EGO_MTL_SY_ITEMS_EXT_TL
    (
      EXTENSION_ID
     ,ORGANIZATION_ID
     ,INVENTORY_ITEM_ID
     ,ITEM_CATALOG_GROUP_ID
     ,ATTR_GROUP_ID
     ,SOURCE_LANG
     ,LANGUAGE
     ,CREATED_BY
     ,CREATION_DATE
     ,LAST_UPDATED_BY
     ,LAST_UPDATE_DATE
     ,TL_EXT_ATTR2  -- Added as a part of Bug 4906499
     ,DATA_LEVEL_ID --Added for bug 6155995
    )
    SELECT EXT.EXTENSION_ID
          ,EXT.ORGANIZATION_ID
          ,EXT.INVENTORY_ITEM_ID
          ,EXT.ITEM_CATALOG_GROUP_ID
          ,EXT.ATTR_GROUP_ID
          ,USERENV('LANG')
          ,L.LANGUAGE_CODE
          ,EXT.CREATED_BY
          ,EXT.CREATION_DATE
          ,EXT.LAST_UPDATED_BY
          ,EXT.LAST_UPDATE_DATE
         ,NVL(M.MESSAGE_TEXT,'Long Description')
   ,43102 --Added for bug 6155995
      FROM MTL_SYSTEM_ITEMS_INTERFACE MTL
          ,EGO_MTL_SY_ITEMS_EXT_B     EXT
          ,FND_LANGUAGES              L
          ,FND_NEW_MESSAGES           M
     WHERE MTL.SET_PROCESS_ID = p_set_process_id
       AND MTL.PROCESS_FLAG = 4
       AND MTL.TRANSACTION_TYPE = 'CREATE'
       AND MTL.ORGANIZATION_ID = EXT.ORGANIZATION_ID
       AND MTL.INVENTORY_ITEM_ID = EXT.INVENTORY_ITEM_ID
       AND EXT.ATTR_GROUP_ID = l_attr_group_id
       AND L.INSTALLED_FLAG IN ('I', 'B')
       AND MESSAGE_NAME = 'EGO_ITEM_LONG_DESCRIPTION'
       AND M.LANGUAGE_CODE = L.LANGUAGE_CODE
       AND M.APPLICATION_ID = 431;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;

END Seed_Item_Long_Desc_In_Bulk;

-- -----------------------------------------------------------------------------
--  API Name:      Build_Parent_Cat_Group_List
--
--  Description:
--    This Function is copied from EGO_ITEM_USER_ATTRS_CP_PUB for Installation bug
--    3873647.
--    Gets the parent catalog group/categories list for a given catalog group/category code
-- -----------------------------------------------------------------------------

FUNCTION Build_Parent_Cat_Group_List (
        p_catalog_group_id              IN   NUMBER
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
)
RETURN VARCHAR2
IS

    l_parent_cat_group_list  VARCHAR2(150) := '';
    l_token_table            ERROR_HANDLER.Token_Tbl_Type;
    l_dummy_transaction_id   NUMBER;

    -------------------------------------------------------------------------
    -- For finding all parent catalog groups for the current catalog group --
    -------------------------------------------------------------------------
    CURSOR parent_catalog_group_cursor
    IS
    SELECT ITEM_CATALOG_GROUP_ID
          ,PARENT_CATALOG_GROUP_ID
      FROM MTL_ITEM_CATALOG_GROUPS_B
   CONNECT BY PRIOR PARENT_CATALOG_GROUP_ID = ITEM_CATALOG_GROUP_ID
     START WITH ITEM_CATALOG_GROUP_ID = p_catalog_group_id;

  BEGIN

    -------------------------------------------------------------------
    -- We build a list of all parent catalog groups, as long as the  --
    -- list is less than 151 characters long (the longest we can fit --
    -- into the EGO_COL_NAME_VALUE_PAIR_OBJ is 150 chars); if the    --
    -- list is too long to fully copy, we can only hope that the     --
    -- portion we copied will contain all the information we need.   --
    -------------------------------------------------------------------
    FOR cat_rec IN parent_catalog_group_cursor
    LOOP
      IF (cat_rec.PARENT_CATALOG_GROUP_ID IS NOT NULL) THEN

        l_parent_cat_group_list := l_parent_cat_group_list ||
                                   cat_rec.PARENT_CATALOG_GROUP_ID || ',';
      END IF;
    END LOOP;

    ---------------------------------------------------------------------
    -- Trim the trailing ',' from l_parent_cat_group_list if necessary --
    ---------------------------------------------------------------------
    IF (LENGTH(l_parent_cat_group_list) > 0) THEN
      l_parent_cat_group_list := SUBSTR(l_parent_cat_group_list, 1, LENGTH(l_parent_cat_group_list) - LENGTH(','));
    END IF;

    RETURN l_parent_cat_group_list;

  EXCEPTION
    WHEN OTHERS THEN

      l_token_table(1).TOKEN_NAME := 'CAT_GROUP_NAME';
      SELECT CONCATENATED_SEGMENTS
        INTO l_token_table(1).TOKEN_VALUE
        FROM MTL_ITEM_CATALOG_GROUPS_KFV
       WHERE ITEM_CATALOG_GROUP_ID = p_catalog_group_id;

      ERROR_HANDLER.Add_Error_Message(
        p_message_name                  => 'EGO_TOO_MANY_CAT_GROUPS'
       ,p_application_id                => 'EGO'
       ,p_token_tbl                     => l_token_table
       ,p_message_type                  => FND_API.G_RET_STS_ERROR
       ,p_entity_id                     => p_entity_id
       ,p_entity_index                  => p_entity_index
       ,p_entity_code                   => p_entity_code
      );

    ---------------------------------------------------------------------
    -- Trim the trailing ',' from l_parent_cat_group_list if necessary --
    ---------------------------------------------------------------------
    IF (LENGTH(l_parent_cat_group_list) > 0) THEN
      l_parent_cat_group_list := SUBSTR(l_parent_cat_group_list, 1, LENGTH(l_parent_cat_group_list) - LENGTH(','));
    END IF;

    RETURN l_parent_cat_group_list;

END Build_Parent_Cat_Group_List;

-- -----------------------------------------------------------------------------
--  API Name:       Get_Related_Class_Codes
--
--  Description:
--    This Procedure is copied from EGO_ITEM_USER_ATTRS_CP_PUB for Installation bug
--    3873647.
--    Gets the related classification codes list for a given classification code
-- -----------------------------------------------------------------------------

PROCEDURE Get_Related_Class_Codes (
        p_classification_code           IN   VARCHAR2
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,x_related_class_codes_list      OUT NOCOPY VARCHAR2
) IS

BEGIN

  x_related_class_codes_list :=
    Build_Parent_Cat_Group_List(TO_NUMBER(p_classification_code), p_entity_id, p_entity_index, p_entity_code);

END Get_Related_Class_Codes;

-- -----------------------------------------------------------------------------
--  API Name:       Get_User_Attrs_Privs
--
--  Description:
--    Helper function (private) to build a table of privileges;
--    should never be exposed as a public API.  Raises an exception
--    if anything fails.
-- -----------------------------------------------------------------------------
FUNCTION Get_User_Attrs_Privs (
        p_inventory_item_id             IN   NUMBER
       ,p_organization_id               IN   NUMBER
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
)
RETURN EGO_VARCHAR_TBL_TYPE
IS

    l_party_id               VARCHAR2(30);
    l_return_status          VARCHAR2(1);
    l_user_privileges_table  EGO_DATA_SECURITY.EGO_PRIVILEGE_NAME_TABLE_TYPE;
    l_user_privileges_on_object EGO_VARCHAR_TBL_TYPE;
    l_privilege_table_index  NUMBER;
    l_token_table            ERROR_HANDLER.Token_Tbl_Type;
    l_api_name               CONSTANT VARCHAR2(30) := 'Get_User_Attrs_Privs';
  BEGIN

    --------------------------------------------------------------------------
    --           Get the party ID if we don't already know it               --
    --------------------------------------------------------------------------

    IF L_PARTY_ID IS NULL OR
       FND_GLOBAL.USER_NAME <> g_username THEN

      --
      -- New user - find out its party ID.
      --

      -------------------------------------------------------------
      -- This query assumes that the user is logged in correctly --
      -------------------------------------------------------------

      BEGIN
        SELECT 'HZ_PARTY:'||TO_CHAR(PARTY_ID)
          INTO l_party_id
          FROM EGO_USER_V
         WHERE USER_NAME = FND_GLOBAL.USER_NAME;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN

          ERROR_HANDLER.Add_Error_Message(
            p_message_name                  => 'EGO_EF_NO_NAME_TO_VALIDATE'
           ,p_application_id                => 'EGO'
           ,p_message_type                  => FND_API.G_RET_STS_ERROR
           ,p_entity_id                     => p_entity_id
           ,p_entity_index                  => p_entity_index
           ,p_entity_code                   => p_entity_code
          );

          RAISE FND_API.G_EXC_ERROR;

      END;

      ------------------- BEGIN Bug 6531908 -----------------------------------

      code_debug(l_api_name ||
                 ' Writing username to party ID mapping to cache.' );

      -- Cache this most recent username to party ID mapping to avoid
      -- redundantly performing this lookup again.
      g_party_id := l_party_id;
      g_username := FND_GLOBAL.USER_NAME;

    ELSE

      -- Bug 6531908: The user is the same as previously, so reuse the same
      -- party ID as that determined previously.
      l_party_id := g_party_id;

      code_debug(l_api_name||' Querying cached party ID.' );


    END IF;

     ---------------------- END Bug 6531908 -----------------------------------


    EGO_DATA_SECURITY.Get_Functions(
      p_api_version         => 1.0
     ,p_object_name         => 'EGO_ITEM'
     ,p_instance_pk1_value  => p_inventory_item_id
     ,p_instance_pk2_value  => p_organization_id
     ,p_user_name           => l_party_id
     ,x_return_status       => l_return_status
     ,x_privilege_tbl       => l_user_privileges_table
    );

    ---------------------------------------------------------------------
    -- If the user has privileges on this instance, we need to convert --
    -- the table we have into a table of type EGO_VARCHAR_TBL_TYPE     --
    ---------------------------------------------------------------------
    IF (l_return_status = 'T' AND
        l_user_privileges_table.COUNT > 0) THEN

      l_user_privileges_on_object := EGO_VARCHAR_TBL_TYPE();

      l_privilege_table_index := l_user_privileges_table.FIRST;
      WHILE (l_privilege_table_index <= l_user_privileges_table.LAST)
      LOOP
        l_user_privileges_on_object.EXTEND();
        l_user_privileges_on_object(l_user_privileges_on_object.LAST) := l_user_privileges_table(l_privilege_table_index);
        l_privilege_table_index := l_user_privileges_table.NEXT(l_privilege_table_index);
      END LOOP;

    ELSE

      -----------------------------------------------
      -- If Get_Functions failed, report the error --
      -----------------------------------------------
      DECLARE

        l_error_message_name VARCHAR2(30);
        l_org_code           MTL_PARAMETERS.ORGANIZATION_CODE%TYPE;
        l_item_number        MTL_SYSTEM_ITEMS_KFV.CONCATENATED_SEGMENTS%TYPE;

      BEGIN

        IF (l_return_status = 'F') THEN
          l_error_message_name := 'EGO_EF_BL_NO_PRIVS_ON_INSTANCE';
        ELSE
          l_error_message_name := 'EGO_EF_BL_PRIV_CHECK_ERROR';
        END IF;

        SELECT CONCATENATED_SEGMENTS
          INTO l_item_number
          FROM MTL_SYSTEM_ITEMS_KFV
         WHERE INVENTORY_ITEM_ID = p_inventory_item_id
           AND ORGANIZATION_ID = p_organization_id;

        SELECT ORGANIZATION_CODE
          INTO l_org_code
          FROM MTL_PARAMETERS
         WHERE ORGANIZATION_ID = p_organization_id;

        l_token_table(1).TOKEN_NAME := 'USER_NAME';
        l_token_table(1).TOKEN_VALUE := FND_GLOBAL.USER_NAME;
        l_token_table(2).TOKEN_NAME := 'ITEM_NUMBER';
        l_token_table(2).TOKEN_VALUE := l_item_number;
        l_token_table(3).TOKEN_NAME := 'ORG_CODE';
        l_token_table(3).TOKEN_VALUE := l_org_code;

        ERROR_HANDLER.Add_Error_Message(
          p_message_name                  => l_error_message_name
         ,p_application_id                => 'EGO'
         ,p_token_tbl                     => l_token_table
         ,p_message_type                  => FND_API.G_RET_STS_ERROR
         ,p_entity_id                     => p_entity_id
         ,p_entity_index                  => p_entity_index
         ,p_entity_code                   => p_entity_code
        );

        RAISE FND_API.G_EXC_ERROR;

      END;
    END IF;

    RETURN l_user_privileges_on_object;

END Get_User_Attrs_Privs;

-- -----------------------------------------------------------------------------
--  API Name:       Process_User_Attrs_For_Item
--
--  Description:
--    Process passed-in User-Defined Attrs data for
--    the Item whose Primary Keys are passed in
-- -----------------------------------------------------------------------------
PROCEDURE Process_User_Attrs_For_Item (
        p_api_version                   IN   NUMBER
       ,p_inventory_item_id             IN   NUMBER
       ,p_organization_id               IN   NUMBER
       ,p_attributes_row_table          IN   EGO_USER_ATTR_ROW_TABLE
       ,p_attributes_data_table         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_change_info_table             IN   EGO_USER_ATTR_CHANGE_TABLE DEFAULT NULL
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_write_to_concurrent_log       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_log_errors                    IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_do_policy_check               IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_validate_hierarchy            IN   VARCHAR2   DEFAULT FND_API.G_TRUE--Added for bugFix:5275391
       ,x_failed_row_id_list            OUT NOCOPY VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Process_User_Attrs_For_Item';

    l_pk_column_values       EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_class_code_values      EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_item_catalog_group_id  NUMBER;
    l_related_class_codes_list VARCHAR2(150);
    l_user_privileges_on_object EGO_VARCHAR_TBL_TYPE;
    l_token_table            ERROR_HANDLER.Token_Tbl_Type;
    l_attributes_row_table   EGO_USER_ATTR_ROW_TABLE;
    l_return_status VARCHAR2(2);

  BEGIN
    l_attributes_row_table:=EGO_USER_ATTR_ROW_TABLE();
    -------------------------------------------------------------------------
    -- First we build tables of Primary Key and Classification Code values --
    -------------------------------------------------------------------------

    -----------------------
    -- Get PKs organized --
    -----------------------
    l_pk_column_values :=
      EGO_COL_NAME_VALUE_PAIR_ARRAY(
        EGO_COL_NAME_VALUE_PAIR_OBJ('INVENTORY_ITEM_ID', TO_CHAR(p_inventory_item_id))
       ,EGO_COL_NAME_VALUE_PAIR_OBJ('ORGANIZATION_ID', TO_CHAR(p_organization_id))
      );

    -----------------------------------------------------------------
    -- Get the Item Catalog Group ID as well as a comma-delimited  --
    -- list of all parent Catalog Group IDs, which we then pass as --
    -- the second element in this array (Item Catalog Group ID is  --
    -- Item's Classification Code)                                 --
    -----------------------------------------------------------------
    -- Bug: 5636895 added NVL(ITEM...., -1)
    BEGIN
      SELECT NVL(ITEM_CATALOG_GROUP_ID, -1)
        INTO l_item_catalog_group_id
        FROM MTL_SYSTEM_ITEMS_B
       WHERE INVENTORY_ITEM_ID = p_inventory_item_id
         AND ORGANIZATION_ID = p_organization_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN

        ----------------------------------------------------
        -- If the passed-in PKs are bad, report the error --
        ----------------------------------------------------
        l_token_table(1).TOKEN_NAME := 'ITEM_ID';
        l_token_table(1).TOKEN_VALUE := p_inventory_item_id;

        IF (FND_API.To_Boolean(p_add_errors_to_fnd_stack)) THEN
          ERROR_HANDLER.Add_Error_Message(
            p_message_name                  => 'EGO_EF_BL_INV_ITEM_ID_ERR'
           ,p_application_id                => 'EGO'
           ,p_token_tbl                     => l_token_table
           ,p_message_type                  => FND_API.G_RET_STS_ERROR
           ,p_entity_id                     => p_entity_id
           ,p_entity_index                  => p_entity_index
           ,p_entity_code                   => p_entity_code
           ,p_addto_fnd_stack               => 'Y'
          );
        ELSE
          ERROR_HANDLER.Add_Error_Message(
            p_message_name                  => 'EGO_EF_BL_INV_ITEM_ID_ERR'
           ,p_application_id                => 'EGO'
           ,p_token_tbl                     => l_token_table
           ,p_message_type                  => FND_API.G_RET_STS_ERROR
           ,p_entity_id                     => p_entity_id
           ,p_entity_index                  => p_entity_index
           ,p_entity_code                   => p_entity_code
          );
        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END;

    Get_Related_Class_Codes(
      l_item_catalog_group_id
      ,p_entity_id
      ,p_entity_index
      ,p_entity_code
     ,l_related_class_codes_list
    );

    l_class_code_values :=
      EGO_COL_NAME_VALUE_PAIR_ARRAY(
        EGO_COL_NAME_VALUE_PAIR_OBJ('ITEM_CATALOG_GROUP_ID', TO_CHAR(l_item_catalog_group_id))
       ,EGO_COL_NAME_VALUE_PAIR_OBJ('RELATED_CLASS_CODE_LIST_1', l_related_class_codes_list)
      );

    ---------------------------------------------------------------
    -- Next, we build our privileges table for the current user; --
    -- any error in this helper function will be raised as an    --
    -- exception, which will prevent us from calling PUAD at all --
    ---------------------------------------------------------------
    l_user_privileges_on_object := Get_User_Attrs_Privs(
                                     p_inventory_item_id,
                                     p_organization_id,
                                     p_entity_id,
                                     p_entity_index,
                                     p_entity_code
                                   );

    ---------------------------------------------------------------
    -- we are calling the API to check and error out if  an attribute
    --update needs to have a change order or update is not allowed.
    ---------------------------------------------------------------
IF (p_do_policy_check = FND_API.G_TRUE ) THEN
    l_attributes_row_table:=
                  Remove_Rows_After_Policy_Check(
                           p_inventory_item_id => p_inventory_item_id
                           ,p_organization_id => p_organization_id
                           ,p_attributes_row_table => p_attributes_row_table
                           ,p_entity_id => p_entity_id
                           ,p_entity_code => p_entity_code
                           ,x_return_status => l_return_status
                           );
ELSE
    l_attributes_row_table:=p_attributes_row_table;
END IF;
--writing the errors to the log
IF (l_return_status=FND_API.G_RET_STS_ERROR) THEN
            ERROR_HANDLER.Log_Error(
              p_write_err_to_inttable         => 'Y'
             ,p_write_err_to_debugfile        => ERROR_HANDLER.Get_Debug()
            );
END IF;

    ---------------------------------------------------------------
    -- If all went well with retrieving privileges, we call PUAD --
    ---------------------------------------------------------------
    EGO_USER_ATTRS_DATA_PVT.Process_User_Attrs_Data(
      p_api_version                   => 1.0
     ,p_object_name                   => 'EGO_ITEM'
     ,p_attributes_row_table          => l_attributes_row_table
     ,p_attributes_data_table         => p_attributes_data_table
     ,p_pk_column_name_value_pairs    => l_pk_column_values
     ,p_class_code_name_value_pairs   => l_class_code_values
     ,p_user_privileges_on_object     => l_user_privileges_on_object
     ,p_change_info_table             => p_change_info_table
     --,p_pending_b_table_name          => 'EGO_ITEMS_ATTRS_CHANGES_B'
     --,p_pending_tl_table_name         => 'EGO_ITEMS_ATTRS_CHANGES_TL'
     --,p_pending_vl_name               => 'EGO_ITEMS_ATTRS_CHANGES_VL'
     ,p_entity_id                     => p_entity_id
     ,p_entity_index                  => p_entity_index
     ,p_entity_code                   => p_entity_code
     ,p_debug_level                   => p_debug_level
     ,p_validate_hierarchy            => p_validate_hierarchy
     ,p_init_error_handler            => p_init_error_handler
     ,p_write_to_concurrent_log       => p_write_to_concurrent_log
     ,p_init_fnd_msg_list             => p_init_fnd_msg_list
     ,p_log_errors                    => p_log_errors
     ,p_add_errors_to_fnd_stack       => p_add_errors_to_fnd_stack
     ,p_commit                        => p_commit
     ,x_failed_row_id_list            => x_failed_row_id_list
     ,x_return_status                 => x_return_status
     ,x_errorcode                     => x_errorcode
     ,x_msg_count                     => x_msg_count
     ,x_msg_data                      => x_msg_data
    );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR;

      x_msg_count := ERROR_HANDLER.Get_Message_Count();

      IF (x_msg_count > 0) THEN
        IF (FND_API.To_Boolean(p_log_errors)) THEN
          IF (FND_API.To_Boolean(p_write_to_concurrent_log)) THEN
            ERROR_HANDLER.Log_Error(
              p_write_err_to_inttable         => 'Y'
             ,p_write_err_to_conclog          => 'Y'
             ,p_write_err_to_debugfile        => ERROR_HANDLER.Get_Debug()
            );
          ELSE
            ERROR_HANDLER.Log_Error(
              p_write_err_to_inttable         => 'Y'
             ,p_write_err_to_debugfile        => ERROR_HANDLER.Get_Debug()
            );
          END IF;
        END IF;

        IF (x_msg_count = 1) THEN
          DECLARE
            message_list  ERROR_HANDLER.Error_Tbl_Type;
          BEGIN
            ERROR_HANDLER.Get_Message_List(message_list);
            x_msg_data := message_list(message_list.FIRST).message_text;
          END;
        ELSE
          x_msg_data := NULL;
        END IF;
      END IF;

    WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      DECLARE
        l_dummy_entity_index     NUMBER;
        l_dummy_entity_id        VARCHAR2(60);
        l_dummy_message_type     VARCHAR2(1);
      BEGIN
        l_token_table(1).TOKEN_NAME := 'PKG_NAME';
        l_token_table(1).TOKEN_VALUE := G_PKG_NAME;
        l_token_table(2).TOKEN_NAME := 'API_NAME';
        l_token_table(2).TOKEN_VALUE := l_api_name;
        l_token_table(3).TOKEN_NAME := 'SQL_ERR_MSG';
        l_token_table(3).TOKEN_VALUE := SQLERRM;

        IF (FND_API.To_Boolean(p_add_errors_to_fnd_stack)) THEN
          ERROR_HANDLER.Add_Error_Message(
            p_message_name                  => 'EGO_PLSQL_ERR'
           ,p_application_id                => 'EGO'
           ,p_token_tbl                     => l_token_table
           ,p_message_type                  => FND_API.G_RET_STS_ERROR
           ,p_addto_fnd_stack               => 'Y'
          );
        ELSE
          ERROR_HANDLER.Add_Error_Message(
            p_message_name                  => 'EGO_PLSQL_ERR'
           ,p_application_id                => 'EGO'
           ,p_token_tbl                     => l_token_table
           ,p_message_type                  => FND_API.G_RET_STS_ERROR
          );
        END IF;

        ERROR_HANDLER.Get_Message(x_message_text => x_msg_data
                                 ,x_entity_index => l_dummy_entity_index
                                 ,x_entity_id    => l_dummy_entity_id
                                 ,x_message_type => l_dummy_message_type);

      END;

END Process_User_Attrs_For_Item;

-- -----------------------------------------------------------------------------
--  API Name:       Get_User_Attrs_For_Item
--
--  Description:
--    Fetch passed-in User-Defined Attrs data for
--    the Item whose Primary Keys are passed in
-- -----------------------------------------------------------------------------
PROCEDURE Get_User_Attrs_For_Item (
        p_api_version                   IN   NUMBER
       ,p_inventory_item_id             IN   NUMBER
       ,p_organization_id               IN   NUMBER
       ,p_attr_group_request_table      IN   EGO_ATTR_GROUP_REQUEST_TABLE
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_attributes_row_table          OUT NOCOPY EGO_USER_ATTR_ROW_TABLE
       ,x_attributes_data_table         OUT NOCOPY EGO_USER_ATTR_DATA_TABLE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Get_User_Attrs_For_Item';

    l_pk_column_values       EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_user_privileges_on_object EGO_VARCHAR_TBL_TYPE;

  BEGIN

    -----------------------
    -- Get PKs organized --
    -----------------------
    l_pk_column_values :=
      EGO_COL_NAME_VALUE_PAIR_ARRAY(
        EGO_COL_NAME_VALUE_PAIR_OBJ('INVENTORY_ITEM_ID', TO_CHAR(p_inventory_item_id))
       ,EGO_COL_NAME_VALUE_PAIR_OBJ('ORGANIZATION_ID', TO_CHAR(p_organization_id))
      );

    ---------------------------------------------------------------
    -- Next, we build our privileges table for the current user; --
    -- any error in this helper function will be raised as an    --
    -- exception, which will prevent us from calling GUAD at all --
    ---------------------------------------------------------------
    l_user_privileges_on_object := Get_User_Attrs_Privs(
                                     p_inventory_item_id,
                                     p_organization_id,
                                     p_entity_id,
                                     p_entity_index,
                                     p_entity_code
                                   );

    ---------------------------------------------------------------
    -- If all went well with retrieving privileges, we call GUAD --
    ---------------------------------------------------------------
    EGO_USER_ATTRS_DATA_PUB.Get_User_Attrs_Data(
      p_api_version                   => p_api_version
     ,p_object_name                   => 'EGO_ITEM'
     ,p_pk_column_name_value_pairs    => l_pk_column_values
     ,p_attr_group_request_table      => p_attr_group_request_table
     ,p_user_privileges_on_object     => l_user_privileges_on_object
     ,p_entity_id                     => p_entity_id
     ,p_entity_index                  => p_entity_index
     ,p_entity_code                   => p_entity_code
     ,p_debug_level                   => p_debug_level
     ,p_init_error_handler            => p_init_error_handler
     ,p_init_fnd_msg_list             => p_init_fnd_msg_list
     ,p_add_errors_to_fnd_stack       => p_add_errors_to_fnd_stack
     ,p_commit                        => p_commit
     ,x_attributes_row_table          => x_attributes_row_table
     ,x_attributes_data_table         => x_attributes_data_table
     ,x_return_status                 => x_return_status
     ,x_errorcode                     => x_errorcode
     ,x_msg_count                     => x_msg_count
     ,x_msg_data                      => x_msg_data
    );


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR;

      x_msg_count := ERROR_HANDLER.Get_Message_Count();

      IF (x_msg_count > 0) THEN
        ERROR_HANDLER.Log_Error(
          p_write_err_to_inttable         => 'Y'
         ,p_write_err_to_debugfile        => ERROR_HANDLER.Get_Debug()
        );

        IF (x_msg_count = 1) THEN
          DECLARE
            message_list  ERROR_HANDLER.Error_Tbl_Type;
          BEGIN
            ERROR_HANDLER.Get_Message_List(message_list);
            x_msg_data := message_list(message_list.FIRST).message_text;
          END;
        ELSE
          x_msg_data := NULL;
        END IF;
      END IF;

    WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      DECLARE
        l_token_table            ERROR_HANDLER.Token_Tbl_Type;
        l_dummy_entity_index     NUMBER;
        l_dummy_entity_id        VARCHAR2(60);
        l_dummy_message_type     VARCHAR2(1);
      BEGIN
        l_token_table(1).TOKEN_NAME := 'PKG_NAME';
        l_token_table(1).TOKEN_VALUE := G_PKG_NAME;
        l_token_table(2).TOKEN_NAME := 'API_NAME';
        l_token_table(2).TOKEN_VALUE := l_api_name;
        l_token_table(3).TOKEN_NAME := 'SQL_ERR_MSG';
        l_token_table(3).TOKEN_VALUE := SQLERRM;

        IF (FND_API.To_Boolean(p_add_errors_to_fnd_stack)) THEN
          ERROR_HANDLER.Add_Error_Message(
            p_message_name                  => 'EGO_PLSQL_ERR'
           ,p_application_id                => 'EGO'
           ,p_token_tbl                     => l_token_table
           ,p_message_type                  => FND_API.G_RET_STS_ERROR
           ,p_addto_fnd_stack               => 'Y'
          );
        ELSE
          ERROR_HANDLER.Add_Error_Message(
            p_message_name                  => 'EGO_PLSQL_ERR'
           ,p_application_id                => 'EGO'
           ,p_token_tbl                     => l_token_table
           ,p_message_type                  => FND_API.G_RET_STS_ERROR
          );
        END IF;

        ERROR_HANDLER.Get_Message(x_message_text => x_msg_data
                                 ,x_entity_index => l_dummy_entity_index
                                 ,x_entity_id    => l_dummy_entity_id
                                 ,x_message_type => l_dummy_message_type);

      END;

END Get_User_Attrs_For_Item;

-- -----------------------------------------------------------------------------
--  API Name:       Generate_Seq_For_Item_Catalog
--
--  Description:
--  Generates the Item Sequence For Number Generation
-- -----------------------------------------------------------------------------
PROCEDURE Generate_Seq_For_Item_Catalog (
       p_item_catalog_group_id          IN  NUMBER
       ,p_seq_start_num                 IN  NUMBER
       ,p_seq_increment_by              IN  NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
)IS
    l_api_name               CONSTANT VARCHAR2(50) := 'Generate_Sequence_For_Item_Catalog';
    l_seq_name               VARCHAR2(100);
    l_syn_name               VARCHAR2(100);
    l_seq_name_prefix        VARCHAR2(70) ;
    l_syn_name_prefix        CONSTANT VARCHAR2(70) := 'ITEM_NUM_SEQ_';
    l_seq_name_suffix        CONSTANT VARCHAR2(10) := '_S' ;
    l_dyn_sql                VARCHAR2(100);

    l_status                 VARCHAR2(1);
    l_industry               VARCHAR2(1);
    l_schema                 VARCHAR2(30);

BEGIN

    IF FND_INSTALLATION.GET_APP_INFO('INV', l_status, l_industry, l_schema) THEN
       IF l_schema IS NULL    THEN
          Raise_Application_Error (-20001, 'INV Schema could not be located.');
       END IF;
    ELSE
       Raise_Application_Error (-20001, 'INV Schema could not be located.');
    END IF;

    l_seq_name_prefix := l_schema ||'.'||'ITEM_NUM_SEQ_';

    l_seq_name  := l_seq_name_prefix || p_item_catalog_group_id || l_seq_name_suffix;
    l_dyn_sql   := 'CREATE SEQUENCE '||l_seq_name||' INCREMENT BY '||p_seq_increment_by||' START WITH '||p_seq_start_num || ' NOCACHE';
    EXECUTE IMMEDIATE l_dyn_sql;
    l_syn_name  := l_syn_name_prefix || p_item_catalog_group_id || l_seq_name_suffix;
    l_dyn_sql   := 'CREATE SYNONYM '||l_syn_name||' FOR '||l_seq_name;
    EXECUTE IMMEDIATE l_dyn_sql;
EXCEPTION
   WHEN others THEN
      x_return_status  :=  G_RET_STS_UNEXP_ERROR;
      x_msg_data := G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;
END Generate_Seq_For_Item_Catalog;

----------------------------------------------------------------------
-- -----------------------------------------------------------------------------
--  API Name:       Drop_Sequence_For_Item_Catalog
--
--  Description:
--  Drops the Item Sequence For Number Generation
-- -----------------------------------------------------------------------------
PROCEDURE Drop_Sequence_For_Item_Catalog (
       p_item_catalog_seq_name         IN  VARCHAR2
       ,x_return_status                OUT NOCOPY VARCHAR2
       ,x_errorcode                    OUT NOCOPY NUMBER
       ,x_msg_count                    OUT NOCOPY NUMBER
       ,x_msg_data                     OUT NOCOPY VARCHAR2)
IS
    l_api_name               CONSTANT VARCHAR2(50) := 'Drop_Sequence_For_Item_Catalog';
    l_dyn_sql                VARCHAR2(100);
    l_status                 VARCHAR2(1);
    l_industry               VARCHAR2(1);
    l_schema                 VARCHAR2(30);
BEGIN

    IF FND_INSTALLATION.GET_APP_INFO('INV', l_status, l_industry, l_schema) THEN
       IF l_schema IS NULL    THEN
          Raise_Application_Error (-20001, 'INV Schema could not be located.');
       END IF;
    ELSE
       Raise_Application_Error (-20001, 'INV Schema could not be located.');
    END IF;

    l_dyn_sql   := 'DROP SYNONYM '||p_item_catalog_seq_name;
    EXECUTE IMMEDIATE l_dyn_sql;
    l_dyn_sql   := 'DROP SEQUENCE '||l_schema||'.'||p_item_catalog_seq_name;
    EXECUTE IMMEDIATE l_dyn_sql;
EXCEPTION
   WHEN others THEN
      x_return_status  :=  G_RET_STS_UNEXP_ERROR;
      x_msg_data := G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;
END Drop_Sequence_For_Item_Catalog;


-- -----------------------------------------------------------------------------
--  API Name:       has_role_on_item
--
--  Description:
--    API to check whether the user has a role on Item or Not
--    TRUE if the user has the specified role on the item
--    FALSE if the user does not have the specified role on the item
--
-- -----------------------------------------------------------------------------
FUNCTION has_role_on_item (p_function_name     IN VARCHAR2
                          ,p_instance_type     IN VARCHAR2 DEFAULT 'UNIVERSAL'
                          ,p_inventory_item_id IN NUMBER
                          ,p_item_number       IN VARCHAR2
                          ,p_organization_id   IN VARCHAR2
                          ,p_organization_name IN VARCHAR2
                          ,p_user_id           IN NUMBER
                          ,p_party_id          IN NUMBER
                          ,p_set_message       IN VARCHAR2
                          ) RETURN BOOLEAN IS
  TYPE dynamic_cur IS REF CURSOR;
  c_priv_cursor     dynamic_cur;
  l_owner_party_id     hz_parties.party_id%TYPE;
  l_owner_party_name   hz_parties.party_name%TYPE;
  l_sec_predicate   VARCHAR2(32767);
  l_return_status   VARCHAR2(10);
  l_select_sql      VARCHAR2(32767);
  l_dummy_number    NUMBER;
  l_dummy_char      VARCHAR2(32767);


  CURSOR c_user_party_id (cp_user_id IN NUMBER) IS
     SELECT party_id, party_name
     FROM   ego_user_v
     WHERE  user_id  = cp_user_id;

  CURSOR c_user_party_name (cp_party_id IN NUMBER) IS
     SELECT party_name
     FROM   hz_parties
     WHERE  party_id = cp_party_id;


BEGIN
  l_owner_party_name := NULL;
  IF p_user_id IS NULL THEN
    OPEN c_user_party_id(cp_user_id => FND_GLOBAL.User_Id);
  ELSE
    OPEN c_user_party_id(cp_user_id => p_user_id);
  END IF;
  FETCH c_user_party_id INTO l_owner_party_id, l_owner_party_name;
  IF c_user_party_id%NOTFOUND THEN
    CLOSE c_user_party_id;
    --
    -- user is not registered properly
    --
    fnd_message.Set_Name(G_APP_NAME, 'EGO_NO_FUNC_PRIVILEGE_FOR_USER');
    IF FND_API.To_Boolean(p_set_message) THEN
      fnd_msg_pub.Add;
    END IF;
    RETURN FALSE;
  ELSE
    CLOSE c_user_party_id;
  END IF;

  EGO_DATA_SECURITY.get_security_predicate(
            p_api_version          => 1.0,
            p_function             => p_function_name,
            p_object_name          => G_EGO_ITEM,
            p_grant_instance_type  => p_instance_type,
            p_user_name            => 'HZ_PARTY:'||TO_CHAR(l_owner_party_id),
            p_statement_type       => 'EXISTS',
            p_pk1_alias            => 'MSIB.INVENTORY_ITEM_ID',
            p_pk2_alias            => 'MSIB.ORGANIZATION_ID',
            p_pk3_alias            => NULL,
            p_pk4_alias            => NULL,
            p_pk5_alias            => NULL,
            x_predicate            => l_sec_predicate,
            x_return_status        => l_return_status );
  code_debug(' Security Predicate '||l_sec_predicate);
  IF (l_sec_predicate IS NULL OR l_sec_predicate = '') THEN
    RETURN TRUE;
  ELSE
    l_select_sql :=
      ' SELECT  1 '||
      ' FROM MTL_SYSTEM_ITEMS MSIB '||
      ' WHERE MSIB.INVENTORY_ITEM_ID = :1'||
      ' AND MSIB.ORGANIZATION_ID = :2'||
      ' AND ' ||l_sec_predicate;
    code_debug(' Priv Query '||l_select_sql);
    OPEN c_priv_cursor FOR l_select_sql USING p_inventory_item_id,p_organization_id;
    FETCH c_priv_cursor INTO l_dummy_number;
    IF c_priv_cursor%NOTFOUND THEN
      CLOSE c_priv_cursor;
      IF FND_API.To_Boolean(p_set_message) THEN
        code_debug (' user does not have privilege '||p_function_name ||' on item '||p_inventory_item_id);
        IF p_function_name = G_FN_NAME_ADD_ROLE THEN
          fnd_message.Set_Name(G_APP_NAME, 'EGO_IPI_CANNOT_GRANT');
-- EGO_IPI_CANNOT_GRANT :  User "USER" does not have privilege to give grants on Item "ITEM" in Organization "ORGANIZATION".
        ELSIF p_function_name IN (G_FN_NAME_PROMOTE) THEN
          fnd_message.Set_Name(G_APP_NAME, 'EGO_NO_PRIV_PROMOTE');
-- EGO_NO_PRIV_PROMOTE : User "USER" does not have privilege to create, update, or delete pending phase records for promotion of Item "ITEM_NUMBER" in Organization "ORGANIZATION".
        ELSIF p_function_name IN (G_FN_NAME_DEMOTE) THEN
          fnd_message.Set_Name(G_APP_NAME, 'EGO_NO_PRIV_DEMOTE');
-- EGO_NO_PRIV_DEMOTE : User "USER" does not have privilege to create, update, or delete pending phase records for demotion of Item "ITEM_NUMBER" in Organization "ORGANIZATION".
        ELSIF p_function_name =  G_FN_NAME_CHANGE_STATUS THEN
          fnd_message.Set_Name(G_APP_NAME, 'EGO_NO_PRIV_CHANGE_STATUS');
-- EGO_NO_PRIV_CHANGE_STATUS :  User "USER" does not have privilege to change status of Item "ITEM" in Organization "ORGANIZATION".
        ELSIF p_function_name = G_FN_NAME_EDIT_LC_PROJ THEN
          fnd_message.set_name(G_APP_NAME, 'EGO_NO_PRIV_ITEM_PROJ_ASSOC');
-- EGO_NO_PRIV_ITEM_PROJ_ASSOC :  User "USER" does not have privilege to create, update or delete project associtions on Item "ITEM" in Organization "ORGANIZATION".
        END IF;
        IF l_owner_party_name IS NULL THEN
          OPEN c_user_party_name (cp_party_id => l_owner_party_id);
          FETCH c_user_party_name INTO l_owner_party_name;
          CLOSE c_user_party_name;
        END IF;
        fnd_message.Set_Token('USER', l_owner_party_name);
        IF p_item_number IS NULL THEN
          SELECT concatenated_segments
            INTO l_dummy_char
            FROM mtl_system_items_b_kfv
           WHERE organization_id = p_organization_id
             AND inventory_item_id = p_inventory_item_id;
        ELSE
          l_dummy_char := p_item_number;
        END IF;
        IF p_function_name = G_FN_NAME_ADD_ROLE THEN
          fnd_message.Set_Token('ITEM', l_dummy_char);
        ELSE
          fnd_message.Set_Token('ITEM_NUMBER', l_dummy_char);
        END IF;
        IF p_organization_name IS NULL THEN
          SELECT name
          INTO l_dummy_char
          FROM hr_all_organization_units_vl
          WHERE organization_id = p_organization_id;
        ELSE
          l_dummy_char := p_organization_name;
        END IF;
        fnd_message.Set_Token('ORGANIZATION', l_dummy_char);
        fnd_msg_pub.Add;
      END IF;
      RETURN FALSE;
    ELSE
      CLOSE c_priv_cursor;
      RETURN TRUE;
    END IF;
  END IF;
 EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END has_role_on_item;

------------------------------------------------------------------------------
  -- Start OF comments
  -- API name  : Process_item_role
  -- TYPE      : Public
  -- Pre-reqs  : None
  -- PROCEDURE : Grants a role on an item.
  --
------------------------------------------------------------------------------
  PROCEDURE Process_item_role
      (p_api_version           IN  NUMBER
      ,p_commit                IN  VARCHAR2
      ,p_init_msg_list         IN  VARCHAR2
      ,p_transaction_type      IN  VARCHAR2
      ,p_inventory_item_id     IN  NUMBER
      ,p_item_number           IN  VARCHAR2
      ,p_organization_id       IN  NUMBER
      ,p_organization_code     IN  VARCHAR2
      ,p_role_id               IN  NUMBER
      ,p_role_name             IN  VARCHAR2
      ,p_instance_type         IN  VARCHAR2
      ,p_instance_set_id       IN  NUMBER
      ,p_instance_set_name     IN  VARCHAR2
      ,p_party_type            IN  VARCHAR2
      ,p_party_id              IN  NUMBER
      ,p_party_name            IN  VARCHAR2
      ,p_start_date            IN  DATE
      ,p_end_date              IN  DATE
      ,x_grant_guid            IN  OUT NOCOPY RAW
      ,x_return_status         OUT NOCOPY VARCHAR2
      ,x_msg_count             OUT NOCOPY NUMBER
      ,x_msg_data              OUT NOCOPY VARCHAR2
     ) IS
  l_api_name                    VARCHAR2(30);
  l_api_version                 NUMBER;
  l_error_token_table           ERROR_HANDLER.Token_Tbl_Type;
  l_dummy_number                NUMBER;
  l_dummy_char                  VARCHAR2(32767);
  l_sysdate                     DATE;
  l_start_date                  DATE;
  l_end_date                    DATE;
  l_organization_id             mtl_system_items_b.organization_id%TYPE;
  l_inventory_item_id           mtl_system_items_b.inventory_item_id%TYPE;
  l_approval_status             mtl_system_items_b.approval_status%TYPE;
  l_item_number                 mtl_system_items_b_kfv.concatenated_segments%TYPE;
  l_hz_party_type               hz_parties.party_type%TYPE;
  l_instance_set_id             fnd_object_instance_sets.instance_set_id%TYPE;
  l_party_id                    hz_parties.party_id%TYPE;
  l_party_name                  hz_parties.party_name%TYPE;
  l_role_id                     fnd_menus_vl.menu_id%TYPE;
  l_role_name                   fnd_menus_vl.menu_name%TYPE;
  l_instance_type               fnd_grants.instance_type%TYPE;
  l_pk1_value                   fnd_grants.instance_pk1_value%TYPE;
  l_pk2_value                   fnd_grants.instance_pk2_value%TYPE;
  l_invalid_flag                BOOLEAN;
  l_create_grant_flag           BOOLEAN;
  l_user_id                     NUMBER;
BEGIN

-- user must not be able to delete his own grants
  l_api_name    := 'Process_item_role';
  l_api_version := 1.0;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_user_id       :=  FND_GLOBAL.User_Id;
  code_debug(l_api_name ||' started with params - grant guid '||RAWTOHEX(x_grant_guid));
  code_debug(' p_api_version '|| p_api_version||' p_commit '||p_commit||' p_init_msg_list '||p_init_msg_list );
  code_debug(' p_transaction_type '||p_transaction_type ||' p_inventory_item_id '||p_inventory_item_id||' p_item_number '||p_item_number );
  code_debug(' p_organization_id '||p_organization_id ||' p_organization_code '||p_organization_code||' p_role_id '||p_role_id );
  code_debug(' p_role_name '||p_role_name ||' p_instance_type '||p_instance_type||' p_instance_set_id '||p_instance_set_id );
  code_debug(' p_instance_set_name '||p_instance_set_name ||' p_party_type '||p_party_type||' p_party_id '||p_party_id );
  code_debug(' p_party_name'||p_party_name ||' p_start_date'||p_start_date||' p_end_date'||p_end_date );

  IF FND_API.To_Boolean( p_commit ) THEN
    SAVEPOINT PROCESS_ITEM_ROLE_SP;
  END IF;
  --
  -- Initialize message list
  --
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;
  code_debug(l_api_name||' msg pub initialized ' );
  --
  --Standard checks
  --
  IF NOT FND_API.Compatible_API_Call (l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,g_pkg_name)THEN
    code_debug (l_api_version ||' invalid api version ');
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  code_debug(l_api_name||' valid api ' );
  --
  -- invalid params passed
  --
  IF ( p_transaction_type IS NULL
       OR
       p_transaction_type NOT IN
           (EGO_ITEM_PUB.G_TTYPE_CREATE
           ,EGO_ITEM_PUB.G_TTYPE_DELETE
           ,EGO_ITEM_PUB.G_TTYPE_UPDATE
           )
       OR
       (p_transaction_type = EGO_ITEM_PUB.G_TTYPE_CREATE
           AND( (p_role_name IS NULL AND p_role_id IS NULL)
                OR
                p_party_type IS NULL
                OR
                p_party_type NOT IN
                   (EGO_ITEM_PUB.G_USER_PARTY_TYPE
                   ,EGO_ITEM_PUB.G_GROUP_PARTY_TYPE
                   ,EGO_ITEM_PUB.G_COMPANY_PARTY_TYPE
                   ,EGO_ITEM_PUB.G_ALL_USERS_PARTY_TYPE
                   )
                OR
                (p_party_type IN (EGO_ITEM_PUB.G_GROUP_PARTY_TYPE
                                 ,EGO_ITEM_PUB.G_COMPANY_PARTY_TYPE
                                 ,EGO_ITEM_PUB.G_USER_PARTY_TYPE)
                   AND p_party_name IS NULL
                   AND p_party_id IS NULL
                )
                OR
                p_instance_type IS NULL
                OR
                p_instance_type NOT IN
                  (EGO_ITEM_PUB.G_INSTANCE_TYPE_SET
                  ,EGO_ITEM_PUB.G_INSTANCE_TYPE_INSTANCE
                  )
                OR
                (p_instance_type = EGO_ITEM_PUB.G_INSTANCE_TYPE_SET
                    AND
                    ( (p_instance_set_id IS NULL AND p_instance_set_name IS NULL)
                     OR
                     p_inventory_item_id IS NOT NULL
                     OR
                     p_organization_id IS NOT NULL
                    )
                )
                OR
                (p_instance_type = EGO_ITEM_PUB.G_INSTANCE_TYPE_INSTANCE
                   AND
                   ( (p_inventory_item_id IS NULL AND p_item_number IS NULL)
                    OR
                     (p_organization_id IS NULL AND p_organization_code IS NULL)
                    OR
                     (p_instance_set_id IS NOT NULL OR p_instance_set_name IS NOT NULL)
                   )
                )
              )
       )
       OR
       (p_transaction_type = EGO_ITEM_PUB.G_TTYPE_UPDATE
           AND (x_grant_guid IS NULL)
       )
       OR
       (p_transaction_type = EGO_ITEM_PUB.G_TTYPE_DELETE
           AND (x_grant_guid IS NULL)
       )
     ) THEN
    --
    -- inalid parameters passed
    --
    code_debug (l_api_version ||' invalid parameters passed ');
    fnd_message.Set_Name(G_APP_NAME, G_INVALID_PARAMS_MSG);
    fnd_message.Set_Token(G_PKG_NAME_TOKEN, G_PKG_NAME);
    fnd_message.Set_Token(G_PROC_NAME_TOKEN, l_api_name);
    fnd_msg_pub.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  code_debug(l_api_name||' valid params passed ' );
  l_sysdate           := SYSDATE;
  l_start_date        := NVL(p_start_date, l_sysdate);
  l_organization_id   := p_organization_id;
  l_inventory_item_id := p_inventory_item_id;
  l_item_number       := p_item_number;
  l_role_id           := p_role_id;
  l_instance_set_id   := p_instance_set_id;
  l_party_id          := p_party_id;
  l_party_name        := p_party_name;
  l_create_grant_flag := TRUE;

  IF p_transaction_type IN (EGO_ITEM_PUB.G_TTYPE_DELETE
                           ,EGO_ITEM_PUB.G_TTYPE_UPDATE) THEN

    BEGIN
      SELECT instance_type, instance_set_id, instance_pk1_value,
             instance_pk2_value, start_date, end_date
      INTO   l_instance_type, l_instance_set_id, l_pk1_value,
             l_pk2_value, l_start_date, l_end_date
      FROM   fnd_grants
      WHERE  grant_guid = x_grant_guid
        AND object_id = (SELECT object_id FROM fnd_objects WHERE obj_name = G_EGO_ITEM);
      code_debug(l_api_name||' grant validation check done ' );
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        code_debug (l_api_version ||' no grant found for modification ');
        IF p_transaction_type = EGO_ITEM_PUB.G_TTYPE_UPDATE THEN
          fnd_message.set_name (G_APP_NAME, 'EGO_NO_REC_UPDATE');
        ELSE
          fnd_message.set_name (G_APP_NAME, 'EGO_NO_REC_DELETE');
        END IF;
        fnd_msg_pub.Add;
        RAISE FND_API.G_EXC_ERROR;
    END;
    --
    -- no security check done for the update of grants of type instance set.
    -- should this be done??
    --
    IF l_instance_type = EGO_ITEM_PUB.G_INSTANCE_TYPE_INSTANCE THEN
      l_inventory_item_id := l_pk1_value;
      l_organization_id := l_pk2_value;
      -- 4052565
      -- modified call to has_role_on_item from validate_role_privilege
      IF NOT has_role_on_item
               (p_function_name      => G_FN_NAME_ADD_ROLE
               ,p_instance_type      => p_instance_type
               ,p_inventory_item_id  => l_inventory_item_id
               ,p_item_number        => NULL
               ,p_organization_id    => l_organization_id
               ,p_organization_name  => NULL
               ,p_user_id            => l_user_id
               ,p_party_id           => l_party_id
               ,p_set_message        => G_TRUE
               ) THEN
        code_debug(l_api_name ||' user does not have privilege to update the roles on item');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      code_debug(l_api_name ||' user has privilege to update the roles on item');
    ELSE
      IF NOT validate_function_security(p_function_name  => G_FN_NAME_ADMIN
                                       ,p_set_message    => G_TRUE) THEN
        code_debug(l_api_name ||' user does not have function privilege to update roles in instance set');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      code_debug(l_api_name ||' user has function privilege to update the roles in instance set');
    END IF;

    IF p_transaction_type = EGO_ITEM_PUB.G_TTYPE_DELETE THEN
      --
      -- delete the grant given
      --
      code_debug(l_api_name||' calling EGO_SECURITY_PUB.revoke_grant ' );
      EGO_SECURITY_PUB.revoke_grant
        (p_api_version    => 1.0
        ,p_grant_guid     => RAWTOHEX(x_grant_guid)
        ,x_return_status  => x_return_status
        ,x_errorcode      => l_dummy_number
        );
      code_debug(l_api_name||' returning EGO_SECURITY_PUB.revoke_grant with status '||x_return_status );
      IF x_return_status <> G_TRUE THEN
        --
        -- should never occur as the grant is already valid
        --
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        IF FND_API.To_Boolean( p_commit ) THEN
          COMMIT WORK;
        END IF;
        RETURN;
      END IF;
    ELSIF p_transaction_type = EGO_ITEM_PUB.G_TTYPE_UPDATE  THEN
      --
      -- update the grant given
      --
      IF date_check (p_start_date      => l_sysdate
                    ,p_end_date        => l_end_date
                    ,p_validation_type => G_GT_VAL
                    ) THEN
        code_debug (l_api_version ||' grant is already end dated ');
        fnd_message.Set_Name(G_APP_NAME, 'EGO_GRANT_END_DATED');
        fnd_msg_pub.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF date_check (p_start_date      => l_sysdate
                    ,p_end_date        => p_end_date
                    ,p_validation_type => G_GT_VAL
                    ) THEN
        code_debug (l_api_version ||' end date less than sysdate ');
        fnd_message.Set_Name(G_APP_NAME, 'EGO_ENDDATE_LT_CURRDATE');
        fnd_msg_pub.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (p_start_date > l_sysdate and l_start_date > l_sysdate) THEN
        l_start_date := NVL(p_start_date,l_start_date);
      END IF;
      code_debug(l_api_name||' calling EGO_SECURITY_PUB.set_grant_date ');
      EGO_SECURITY_PUB.set_grant_date
       (p_api_version    => 1.0
       ,p_grant_guid     => RAWTOHEX(x_grant_guid)
       ,p_start_date     => l_start_date
       ,p_end_date       => p_end_date
       ,x_return_status  => x_return_status
       );
      code_debug(l_api_name||' returning EGO_SECURITY_PUB.set_grant_date with status '||x_return_status );
      IF x_return_status = G_FALSE THEN
        code_debug (l_api_version ||' overlap grant found for update ');
        fnd_message.Set_Name(G_APP_NAME, 'EGO_IPI_OVERLAP_GRANT');
        fnd_message.Set_Token('START_DATE', l_start_date);
        fnd_message.Set_Token('END_DATE', p_end_date);
        fnd_msg_pub.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        IF FND_API.To_Boolean( p_commit ) THEN
          COMMIT WORK;
        END IF;
        RETURN;
      END IF;
    END IF;
  ELSIF p_transaction_type = EGO_ITEM_PUB.G_TTYPE_CREATE THEN
    code_debug(l_api_name||' started validations for CREATE ');
    --
    -- start validations for create
    --
    --
    -- validate the party_id / party_name
    --
    IF NOT validate_party (p_party_type   => p_party_type
                          ,x_party_id     => l_party_id
                          ,x_party_name   => l_party_name
                          ) THEN
      code_debug (l_api_version ||' invalid party passed ');
      l_create_grant_flag := FALSE;
      IF p_party_type = EGO_ITEM_PUB.G_USER_PARTY_TYPE THEN
        fnd_message.Set_Name(G_APP_NAME, 'EGO_USER');
        l_dummy_char := fnd_message.get();
      ELSIF p_party_type = EGO_ITEM_PUB.G_GROUP_PARTY_TYPE THEN
        fnd_message.Set_Name(G_APP_NAME, 'EGO_GROUP_NAME');
        l_dummy_char := fnd_message.get();
      ELSIF p_party_type = EGO_ITEM_PUB.G_COMPANY_PARTY_TYPE THEN
        fnd_message.Set_Name(G_APP_NAME, 'EGO_COMPANY');
        l_dummy_char := fnd_message.get();
      END IF;
      fnd_message.Set_Name(G_APP_NAME, 'EGO_IPI_INVALID_VALUE');
      fnd_message.Set_Token('NAME', l_dummy_char);
      IF l_party_id IS NOT NULL THEN
        fnd_message.Set_Token('VALUE', l_party_id);
      ELSE
        fnd_message.Set_Token('VALUE', l_party_name);
      END IF;
      fnd_msg_pub.Add;
    END IF;
    code_debug(l_api_name||' validate party done ');
    --
    -- validate the menu details passed
    --
    IF NOT validate_menu (x_menu_id        => l_role_id
                         ,x_menu_name      => l_role_name
                         ,p_user_menu_name => p_role_name
                         ,p_menu_type      => 'SECURITY'
                         ) THEN
      code_debug (l_api_version ||' invalid menu passed ');
      l_create_grant_flag := FALSE;
      fnd_message.Set_Name(G_APP_NAME, 'EGO_ROLE');
      l_dummy_char := fnd_message.get();
      fnd_message.Set_Name(G_APP_NAME, 'EGO_IPI_INVALID_VALUE');
      fnd_message.Set_Token('NAME', l_dummy_char);
      IF l_role_id IS NOT NULL THEN
        fnd_message.Set_Token('VALUE', l_role_id);
      ELSE
        fnd_message.Set_Token('VALUE', p_role_name);
      END IF;
      fnd_msg_pub.Add;
    END IF;
    code_debug(l_api_name||' validate menu done ');
    --
    -- validate the start_date - end_date standrad checks
    --
    IF date_check (p_start_date      => l_start_date
                  ,p_end_date        => l_sysdate
                  ,p_validation_type => G_LT_VAL
                  ) THEN
      code_debug (l_api_version ||' start date less than sysdate ');
      l_create_grant_flag := FALSE;
      fnd_message.Set_Name(G_APP_NAME, 'EGO_INVALID_GRANT_START_DATE');
      fnd_msg_pub.Add;
    END IF;
    IF date_check (p_start_date      => l_sysdate
                  ,p_end_date        => p_end_date
                  ,p_validation_type => G_GT_VAL
                  ) THEN
      code_debug (l_api_version ||' end date less than sysdate ');
      l_create_grant_flag := FALSE;
      fnd_message.Set_Name(G_APP_NAME, 'EGO_ENDDATE_LT_CURRDATE');
      fnd_msg_pub.Add;
    END IF;
    IF date_check (p_start_date      => l_start_date
                  ,p_end_date        => p_end_date
                  ,p_validation_type => G_GT_VAL
                  ) THEN
      code_debug (l_api_version ||' end date less than startdate ');
      l_create_grant_flag := FALSE;
      fnd_message.Set_Name(G_APP_NAME, 'EGO_ENDDATE_EXCEEDS_STARTDATE');
      fnd_msg_pub.Add;
    END IF;
    code_debug(l_api_name||' validate date done ');

    IF  l_instance_set_id IS NOT NULL OR p_instance_set_name IS NOT NULL THEN
      --
      -- validate instance set
      --
      IF NOT validate_instance_set (x_instance_set_id => l_instance_set_id
                                   ,p_set_disp_name   => p_instance_set_name
                                   ) THEN
        code_debug (l_api_version ||' invalid instance set ');
        l_create_grant_flag := FALSE;
        fnd_message.Set_Name(G_APP_NAME, 'EGO_INSTANCE');
        l_dummy_char := fnd_message.get();
        fnd_message.Set_Name(G_APP_NAME, 'EGO_IPI_INVALID_VALUE');
        fnd_message.Set_Token('NAME', l_dummy_char);
        IF l_instance_set_id IS NOT NULL THEN
          fnd_message.Set_Token('VALUE', l_instance_set_id);
        ELSE
          fnd_message.Set_Token('VALUE', p_instance_set_name);
        END IF;
        fnd_msg_pub.Add;
      END IF;
      code_debug(l_api_name||' validate instance done ');
      IF NOT validate_function_security(p_function_name  => G_FN_NAME_ADMIN
                                       ,p_set_message    => G_TRUE) THEN
        code_debug(l_api_name ||' user does not have function privilege to update the roles on item');
        l_create_grant_flag := FALSE;
      END IF;
    ELSE
      --
      -- validate organization details
      --
      IF NOT validate_org (x_organization_id   => l_organization_id
                          ,p_organization_code => p_organization_code
                          ,p_set_message       => G_TRUE) THEN
        code_debug (l_api_version ||' invalid organization ');
        l_create_grant_flag := FALSE;
      ELSE
        code_debug(l_api_name||' validate org done ');
        --
        -- validate item details
        --
        IF NOT validate_item (x_inventory_item_id => l_inventory_item_id
                             ,x_item_number       => l_item_number
                             ,x_approval_status   => l_approval_status
                             ,p_organization_id   => l_organization_id
                            ,p_set_message        => G_TRUE) THEN
          code_debug (l_api_version ||' invalid item ');
          l_create_grant_flag := FALSE;
        ELSE
          code_debug(l_api_name||' validate item done ');
          -- 4052565
          -- modified call to has_role_on_item from validate_role_privilege
          IF NOT has_role_on_item
                    (p_function_name      => G_FN_NAME_ADD_ROLE
                    ,p_instance_type      => p_instance_type
                    ,p_inventory_item_id  => l_inventory_item_id
                    ,p_item_number        => l_item_number
                    ,p_organization_id    => l_organization_id
                    ,p_organization_name  => NULL
                    ,p_user_id            => l_user_id
                    ,p_party_id           => l_party_id
                    ,p_set_message        => G_TRUE
                    ) THEN
            code_debug(l_api_name ||' user does not have privilege to create roles ');
            l_create_grant_flag := FALSE;
          END IF;
          code_debug(l_api_name||' validate role privilege done ');
        END IF;
      END IF;
    END IF;

    IF l_create_grant_flag THEN
      --
      -- create a new grant
      --
      code_debug(l_api_name||' calling EGO_SECURITY_PUB.grant_role_guid ');
      EGO_SECURITY_PUB.grant_role_guid
        (p_api_version           => 1.0
        ,p_role_name             => l_role_name
        ,p_object_name           => G_EGO_ITEM
        ,p_instance_type         => p_instance_type
        ,p_instance_set_id       => l_instance_set_id
        ,p_instance_pk1_value    => TO_CHAR(l_inventory_item_id)
        ,p_instance_pk2_value    => TO_CHAR(l_organization_id)
        ,p_instance_pk3_value    => NULL
        ,p_instance_pk4_value    => NULL
        ,p_instance_pk5_value    => NULL
        ,p_party_id              => l_party_id
        ,p_start_date            => l_start_date
        ,p_end_date              => p_end_date
        ,x_return_status         => x_return_status
        ,x_errorcode             => x_msg_data
        ,x_grant_guid            => x_grant_guid
        );
      code_debug(l_api_name||' returning EGO_SECURITY_PUB.grant_role_guid with status '||x_return_status);
      IF x_return_status = G_FALSE THEN
        code_debug (l_api_version ||' grant overlap when creating new grant ');
        fnd_message.Set_Name(G_APP_NAME, 'EGO_IPI_OVERLAP_GRANT');
        fnd_message.Set_Token('START_DATE', l_start_date);
        fnd_message.Set_Token('END_DATE', p_end_date);
        fnd_msg_pub.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        -- changing return status to FND_API.G_RET_STS_SUCCESS
        -- as per standards
        x_return_status := FND_API.G_RET_STS_SUCCESS;
      END IF;
    ELSE
      code_debug(l_api_name||' raising errors ');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  -- commit data
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      code_debug(l_api_name||' returning expected error ');
      IF FND_API.To_Boolean( p_commit ) THEN
        ROLLBACK TO  PROCESS_ITEM_ROLE_SP;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      IF FND_API.To_Boolean( p_commit ) THEN
        ROLLBACK TO  PROCESS_ITEM_ROLE_SP;
      END IF;
      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.Set_Name(G_APP_NAME, G_PLSQL_ERR);
      FND_MESSAGE.Set_Token(G_PKG_NAME_TOKEN, G_PKG_NAME);
      FND_MESSAGE.Set_Token(G_API_NAME_TOKEN, l_api_name);
      FND_MESSAGE.Set_Token(G_SQL_ERR_MSG_TOKEN, SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      code_debug(' EXCEPTION in '||l_api_name||' : ' ||x_msg_data );
  END Process_item_role;


------------------------------------------------------------------------------
  -- Start OF comments
  -- API name  : Process_item_phase_and_status
  -- TYPE      : Public
  -- Pre-reqs  : None
  -- PROCEDURE : Changes item phase and status
  --
------------------------------------------------------------------------------
PROCEDURE Process_item_phase_and_status
      (p_api_version           IN  NUMBER
      ,p_commit                IN  VARCHAR2
      ,p_init_msg_list         IN  VARCHAR2
      ,p_transaction_type      IN  VARCHAR2
      ,p_inventory_item_id     IN  NUMBER
      ,p_item_number           IN  VARCHAR2
      ,p_organization_id       IN  NUMBER
      ,p_organization_code     IN  VARCHAR2
      ,p_revision_id           IN  NUMBER
      ,p_revision              IN  VARCHAR2
      ,p_implement_changes     IN  VARCHAR2
      ,p_status                IN  VARCHAR2
      ,p_effective_date        IN  DATE
      ,p_lifecycle_id          IN  NUMBER
      ,p_phase_id              IN  NUMBER
      ,p_new_effective_date    IN  DATE
      ,x_return_status         OUT NOCOPY VARCHAR2
      ,x_msg_count             OUT NOCOPY NUMBER
      ,x_msg_data              OUT NOCOPY VARCHAR2
     ) IS
  l_api_name                    VARCHAR2(30);
  l_api_version                 NUMBER;
  l_organization_id             mtl_system_items_b.organization_id%TYPE;
  l_inventory_item_id           mtl_system_items_b.inventory_item_id%TYPE;
  l_item_number                 mtl_system_items_b_kfv.concatenated_segments%TYPE;
  l_approval_status             mtl_system_items_b.approval_status%TYPE;
  l_revision_id                 mtl_item_revisions_b.revision_id%TYPE;
  l_revision                    mtl_item_revisions_b.revision%TYPE;
  l_curr_cc_id                  mtl_system_items_b.item_catalog_group_id%TYPE;
  l_curr_lifecycle_id           mtl_system_items_b.lifecycle_id%TYPE;
  l_curr_phase_id               mtl_system_items_b.current_phase_id%TYPE;
  l_future_phase_id             mtl_system_items_b.current_phase_id%TYPE;
  l_item_sequence               NUMBER;
  l_phase_sequence              NUMBER;
  l_curr_status                 mtl_system_items_b.inventory_item_status_code%TYPE;
  l_policy_code                 VARCHAR2(99);
  l_policy_co_required          VARCHAR2(99);
  l_policy_not_allowed          VARCHAR2(99);
  l_sysdate                     DATE;
  l_effective_date              DATE;
  l_invalid_flag                BOOLEAN;
  l_change_status_flag          BOOLEAN;
  l_dummy_char                  VARCHAR2(32767);
  l_dummy_number                NUMBER;
  l_revision_master_controlled  VARCHAR2(1);
  l_status_master_controlled    VARCHAR2(1);
  l_is_master_org               VARCHAR2(1);
  l_org_name                    hr_all_organization_units_vl.name%TYPE;
  l_error_message               fnd_new_messages.message_name%TYPE;
  l_priv_function_name          fnd_form_functions.function_name%TYPE;
  l_user_id                     NUMBER;
  l_temp                        NUMBER;

  CURSOR c_get_item_det (cp_inventory_item_id  IN  NUMBER
                        ,cp_organization_id    IN  NUMBER) IS
  SELECT item_catalog_group_id, lifecycle_id,
         current_phase_id, inventory_item_status_code
  FROM mtl_system_items_b
  WHERE inventory_item_id = cp_inventory_item_id
    AND organization_id = cp_organization_id;

  CURSOR c_get_item_rev_det (cp_inventory_item_id  IN  NUMBER
                            ,cp_organization_id    IN  NUMBER
                            ,cp_revision_id        IN  NUMBER) IS
  SELECT itm.item_catalog_group_id, rev.lifecycle_id, rev.current_phase_id, itm.inventory_item_status_code
  FROM mtl_system_items_b itm, mtl_item_revisions_b rev
  WHERE itm.inventory_item_id = cp_inventory_item_id
    AND itm.organization_id = cp_organization_id
    AND rev.inventory_item_id = itm.inventory_item_id
    AND rev.organization_id = itm.organization_id --changed = rev.organization_id to itm.organization_id bug 7324207
    AND rev.revision_id = cp_revision_id; --changed =rev.revision_id to cp_revision_id bug 7324207

  CURSOR c_get_phase_seq (cp_phase_id     IN  NUMBER ) IS
    SELECT p1.display_sequence
    FROM   PA_PROJ_ELEMENT_VERSIONS P1
    WHERE  P1.PROJ_ELEMENT_ID = cp_phase_id;

  CURSOR c_get_next_phase (cp_lifecycle_id IN  NUMBER
                          ,cp_phase_id     IN  NUMBER ) IS
    SELECT p1.proj_element_id, p1.display_sequence
    FROM   PA_PROJ_ELEMENT_VERSIONS P1, PA_PROJ_ELEMENT_VERSIONS P2
    WHERE  P1.PARENT_STRUCTURE_VERSION_ID = P2.ELEMENT_VERSION_ID
      AND  P2.PROJ_ELEMENT_ID = cp_lifecycle_id
      AND  P1.display_sequence >
              (SELECT P3.display_sequence
               FROM   PA_PROJ_ELEMENT_VERSIONS P3
               WHERE  P3.PROJ_ELEMENT_ID = cp_phase_id
                 AND  P3.PARENT_STRUCTURE_VERSION_ID = P1.parent_structure_version_id
               )
    ORDER BY p1.DISPLAY_SEQUENCE ASC;

  CURSOR c_get_priv_phase (cp_lifecycle_id IN  NUMBER
                          ,cp_phase_id     IN  NUMBER ) IS
    SELECT p1.proj_element_id, p1.display_sequence
    FROM   PA_PROJ_ELEMENT_VERSIONS P1, PA_PROJ_ELEMENT_VERSIONS P2
    WHERE  P1.PARENT_STRUCTURE_VERSION_ID = P2.ELEMENT_VERSION_ID
      AND  P2.PROJ_ELEMENT_ID = cp_lifecycle_id
      AND  P1.display_sequence <
              (SELECT P3.display_sequence
               FROM   PA_PROJ_ELEMENT_VERSIONS P3
               WHERE  P3.PROJ_ELEMENT_ID = cp_phase_id
                 AND  P3.PARENT_STRUCTURE_VERSION_ID = P1.parent_structure_version_id
               )
    ORDER BY p1.DISPLAY_SEQUENCE DESC;


  CURSOR c_chk_phase_against_lc ( cp_lifecycle_id IN NUMBER
                                 ,cp_phase_id     IN NUMBER
                                ) IS
    SELECT 1
    FROM PA_PROJ_ELEMENT_VERSIONS LC
    WHERE LC.proj_element_id = cp_lifecycle_id
    AND EXISTS
    (
    SELECT 1
    FROM PA_PROJ_ELEMENT_VERSIONS PHASES
    WHERE PHASES.parent_structure_version_id = LC.element_version_id
    AND PHASES.proj_element_id = cp_phase_id
    );



BEGIN
  l_api_name := 'Process_item_phase_and_status';
  l_api_version := 1.0;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_user_id       :=  FND_GLOBAL.User_Id;
  l_policy_co_required  := 'CHANGE_ORDER_REQUIRED';
  l_policy_not_allowed  := 'NOT_ALLOWED';
  code_debug(l_api_name ||' started with params -- effective date '|| p_effective_date);
  code_debug(' p_api_version '|| p_api_version||' p_commit '||p_commit||' p_init_msg_list '||p_init_msg_list );
  code_debug(' p_transaction_type '||p_transaction_type ||' p_inventory_item_id '||p_inventory_item_id||' p_item_number '||p_item_number );
  code_debug(' p_organization_id '||p_organization_id ||' p_organization_code '||p_organization_code||' p_revision_id '||p_revision_id );
  code_debug(' p_revision '||p_revision ||' p_implement_changes '||p_implement_changes||' p_status     '||p_status     );

  IF FND_API.To_Boolean( p_commit ) THEN
    SAVEPOINT PROCESS_ITEM_PHASE_SP;
  END IF;
  --
  -- Initialize message list
  --
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;
  code_debug(l_api_name||' msg pub initialized ' );
  --
  --Standard checks
  --
  IF NOT FND_API.Compatible_API_Call (l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,g_pkg_name) THEN
    code_debug (l_api_version ||' invalid api version ');
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --
  -- check for invalid params
  --
  IF ( p_transaction_type IS NULL
       OR
       p_transaction_type NOT IN (EGO_ITEM_PUB.G_TTYPE_UPDATE
                                 ,EGO_ITEM_PUB.G_TTYPE_DELETE
                                 ,EGO_ITEM_PUB.G_TTYPE_PROMOTE
                                 ,EGO_ITEM_PUB.G_TTYPE_DEMOTE
                                 ,EGO_ITEM_PUB.G_TTYPE_CHANGE_STATUS
                                 ,EGO_ITEM_PUB.G_TTYPE_CHANGE_PHASE  /* P4TP immutability enhancement */
                                 )
       OR
       (  p_transaction_type NOT IN (EGO_ITEM_PUB.G_TTYPE_UPDATE
                                    ,EGO_ITEM_PUB.G_TTYPE_DELETE
                                    ,EGO_ITEM_PUB.G_TTYPE_CHANGE_PHASE
                                    )
           AND
          (p_revision IS NOT NULL OR p_revision_id IS NOT NULL)
           AND
           p_status IS NOT NULL
       )
       OR
       (   p_transaction_type = EGO_ITEM_PUB.G_TTYPE_CHANGE_PHASE
            AND
           (
             (p_phase_id IS NULL)    --- phase_id must be passed
              OR
             (p_status IS NOT NULL)   --- if status is passed, error since status is not required for rev phase change
              OR
             (p_revision IS NULL AND p_revision_id IS NULL) -- one of these must be passed
           )
       )
       OR
       (p_inventory_item_id IS NULL AND p_item_number IS NULL)
        OR
       (p_organization_id IS NULL AND p_organization_code IS NULL)
     ) THEN
    --
    -- inalid parameters passed
    --
    code_debug (l_api_version ||' invalid parameters passed ');
    fnd_message.Set_Name(G_APP_NAME, G_INVALID_PARAMS_MSG);
    fnd_message.Set_Token(G_PKG_NAME_TOKEN, G_PKG_NAME);
    fnd_message.Set_Token(G_PROC_NAME_TOKEN, l_api_name);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  l_change_status_flag := TRUE;
  l_organization_id    := p_organization_id;
  l_inventory_item_id  := p_inventory_item_id;
  l_item_number        := p_item_number;
  l_sysdate            := SYSDATE;

  IF p_transaction_type = EGO_ITEM_PUB.G_TTYPE_UPDATE THEN
    l_effective_date := NVL(p_new_effective_date,l_sysdate);
  ELSIF p_transaction_type IN (EGO_ITEM_PUB.G_TTYPE_PROMOTE
                              ,EGO_ITEM_PUB.G_TTYPE_DEMOTE
                              ,EGO_ITEM_PUB.G_TTYPE_CHANGE_STATUS) THEN
    l_effective_date := NVL(p_effective_date, l_sysdate);
  ELSE
    l_effective_date := l_sysdate;
  END IF;

  IF date_check (p_start_date      => l_effective_date
                ,p_end_date        => l_sysdate
                ,p_validation_type => G_LT_VAL
                ) THEN
    code_debug (l_api_name ||' effective date is less than system date ');
    l_change_status_flag := FALSE;
    fnd_message.Set_Name(G_APP_NAME, 'EGO_ITEM_INVALID_EFFCT_DATE');
    fnd_msg_pub.Add;
  ELSE
    code_debug (l_api_name ||' effective date is valid ');
  END IF;
  --
  -- validate organization details
  --
  IF NOT validate_org (x_organization_id   => l_organization_id
                      ,p_organization_code => p_organization_code
                      ,p_set_message       => G_TRUE) THEN
    code_debug (l_api_name ||' invalid organization ');
    l_change_status_flag := FALSE;
  ELSE
    code_debug (l_api_name ||' valid organization ');
    SELECT name
    INTO l_org_name
    FROM hr_all_organization_units_vl
    WHERE organization_id = l_organization_id;
    --
    -- validate item details
    --
    IF NOT validate_item (x_inventory_item_id => l_inventory_item_id
                         ,x_item_number       => l_item_number
                         ,x_approval_status   => l_approval_status
                         ,p_organization_id   => l_organization_id
                         ,p_set_message       => G_TRUE) THEN
      code_debug (l_api_name ||' invalid item ');
      l_change_status_flag := FALSE;
    ELSE
      code_debug (l_api_name ||' valid item ');
      IF NVL(l_approval_status,'A') <> 'A' THEN
        --
        -- item is not approved no operations permitted
        --
        code_debug (l_api_name ||' unapproved item ');
        l_change_status_flag := FALSE;
        fnd_message.Set_Name(G_APP_NAME, 'EGO_ITEM_NOT_APPROVED');
        fnd_msg_pub.Add;
      ELSE
        IF p_transaction_type = EGO_ITEM_PUB.G_TTYPE_PROMOTE THEN
          l_priv_function_name := G_FN_NAME_PROMOTE;
        ELSIF p_transaction_type = EGO_ITEM_PUB.G_TTYPE_DEMOTE THEN
          l_priv_function_name := G_FN_NAME_DEMOTE;
        ELSIF p_transaction_type = EGO_ITEM_PUB.G_TTYPE_CHANGE_STATUS THEN
          l_priv_function_name := G_FN_NAME_CHANGE_STATUS;
        END IF;
        IF NOT has_role_on_item
                    (p_function_name        => l_priv_function_name
                    ,p_inventory_item_id    => l_inventory_item_id
                    ,p_item_number          => l_item_number
                    ,p_organization_id      => l_organization_id
                    ,p_organization_name    => NULL
                    ,p_user_id              => l_user_id
                    ,p_party_id             => NULL
                    ,p_set_message          => G_TRUE
                    ) THEN
          code_debug(l_api_name ||' user does not have privilege to perform specified action '||p_transaction_type);
          l_change_status_flag := FALSE;
        ELSE
          code_debug(l_api_name ||' user has privilege to perform the action '||l_priv_function_name);
        END IF;
        --
        -- validate revision details
        --
        l_revision_id := p_revision_id;
        l_revision    := p_revision;
        IF (l_revision IS NOT NULL OR l_revision_id IS NOT NULL) THEN
          IF NOT validate_item_rev
                               (x_revision_id        => l_revision_id
                               ,x_revision           => l_revision
                               ,p_inventory_item_id  => l_inventory_item_id
                               ,p_organization_id    => l_organization_id
                               ,p_set_message        => G_TRUE) THEN
            code_debug (l_api_name ||' invalid item revision ');
            l_change_status_flag := FALSE;
          ELSE
            code_debug (l_api_name ||' valid item revision ');
            --
            -- context of rev
            --
            OPEN c_get_item_rev_det (cp_inventory_item_id => l_inventory_item_id
                                    ,cp_organization_id => l_organization_id
                                    ,cp_revision_id     => l_revision_id
                                    );
            FETCH c_get_item_rev_det INTO l_curr_cc_id, l_curr_lifecycle_id, l_curr_phase_id, l_curr_status;
            CLOSE c_get_item_rev_det;
          END IF;
        ELSE
          --
          -- context of item
          --
          OPEN c_get_item_det (cp_inventory_item_id => l_inventory_item_id
                              ,cp_organization_id => l_organization_id
                              );
          FETCH c_get_item_det INTO l_curr_cc_id, l_curr_lifecycle_id, l_curr_phase_id, l_curr_status;
          CLOSE c_get_item_det;
        END IF;
        IF ( p_transaction_type IN (EGO_ITEM_PUB.G_TTYPE_PROMOTE, EGO_ITEM_PUB.G_TTYPE_DEMOTE)
             AND
             l_curr_lifecycle_id IS NULL
           ) THEN
          l_change_status_flag := FALSE;
          code_debug (l_api_name ||' no lifecycle associated to item / revision ');
          IF l_revision_id IS NULL THEN
            fnd_message.Set_Name(G_APP_NAME, 'EGO_ITEM_NO_LC_FOR_CHANGE');
          ELSE
            fnd_message.Set_Name(G_APP_NAME, 'EGO_REV_NO_LC_FOR_CHANGE');
          END IF;
          fnd_msg_pub.Add;
        END IF;
      END IF;  -- approval status
    END IF; -- validate item
  END IF; -- validate org

  IF NOT l_change_status_flag THEN
    --
    -- logical set of errors completed
    -- further validations assume that there are no errors
    --
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_transaction_type IN (EGO_ITEM_PUB.G_TTYPE_PROMOTE, EGO_ITEM_PUB.G_TTYPE_DEMOTE
          , EGO_ITEM_PUB.G_TTYPE_CHANGE_PHASE )  THEN
    --
    -- check if there is a project associated
    --
    IF 'TRUE' = EGO_LIFECYCLE_USER_PUB.Has_LC_Tracking_Project
                    (p_inventory_item_id  => l_inventory_item_id
                    ,p_organization_id    => l_organization_id
                    ,p_revision           => l_revision)  THEN
      code_debug (l_api_name ||' lc project associated to item / revision ');
      l_change_status_flag := FALSE;
      IF l_revision IS NOT NULL THEN
        fnd_message.Set_Name(G_APP_NAME,'EGO_ITEM_REV_LC_PROJ_EXISTS');
        fnd_message.set_token('REVISION', l_revision);
      ELSE
        fnd_message.Set_Name(G_APP_NAME,'ITEM_LC_PROJ_EXISTS');
      END IF;
      fnd_message.set_token('ITEM_NUMBER', l_item_number);
      fnd_message.set_token('ORG_NAME', l_org_name);
      fnd_msg_pub.Add;
    END IF;

    IF p_transaction_type = EGO_ITEM_PUB.G_TTYPE_PROMOTE THEN
      OPEN c_get_next_phase (cp_lifecycle_id => l_curr_lifecycle_id
                            ,cp_phase_id     => l_curr_phase_id
                            );
      FETCH c_get_next_phase INTO l_future_phase_id, l_phase_sequence;
      IF c_get_next_phase%NOTFOUND THEN
        CLOSE c_get_next_phase;
        code_debug (l_api_name ||' no phase to promote ');
        l_change_status_flag := FALSE;
        fnd_message.Set_Name(G_APP_NAME,'EGO_ITEM_CANNOT_PROMOTE');
        l_dummy_char := get_lifecycle_name (p_lc_phase_type   => 'LIFECYCLE'
                                           ,p_proj_element_id => l_curr_lifecycle_id);
        fnd_message.set_token('LIFE_CYCLE', l_dummy_char);
        l_dummy_char := get_lifecycle_name (p_lc_phase_type   => 'PHASE'
                                           ,p_proj_element_id => l_curr_phase_id);
        fnd_message.set_token('PHASE', l_dummy_char);
        fnd_msg_pub.Add;
      ELSE
        CLOSE c_get_next_phase;
      END IF;
    ELSIF p_transaction_type = EGO_ITEM_PUB.G_TTYPE_DEMOTE THEN
      OPEN c_get_priv_phase (cp_lifecycle_id => l_curr_lifecycle_id
                            ,cp_phase_id     => l_curr_phase_id
                            );
      FETCH c_get_priv_phase INTO l_future_phase_id, l_phase_sequence;
      IF c_get_priv_phase%NOTFOUND THEN
        CLOSE c_get_priv_phase;
        code_debug (l_api_name ||' no phase to demote ');
        l_change_status_flag := FALSE;
        fnd_message.Set_Name(G_APP_NAME,'EGO_ITEM_CANNOT_DEMOTE');
        l_dummy_char := get_lifecycle_name (p_lc_phase_type   => 'LIFECYCLE'
                                           ,p_proj_element_id => l_curr_lifecycle_id);
        fnd_message.set_token('LIFE_CYCLE', l_dummy_char);
        l_dummy_char := get_lifecycle_name (p_lc_phase_type   => 'PHASE'
                                           ,p_proj_element_id => l_curr_phase_id);
        fnd_message.set_token('PHASE', l_dummy_char);
        fnd_msg_pub.Add;
        fnd_msg_pub.Add;
      ELSE
        CLOSE c_get_priv_phase;
      END IF;
    ELSIF   p_transaction_type = EGO_ITEM_PUB.G_TTYPE_CHANGE_PHASE then
      --- first chk if the phase entered exists
      ---
      --- chk if the phase is part of the current lifecycle of the item
      OPEN c_chk_phase_against_lc (cp_lifecycle_id => l_curr_lifecycle_id
                                  ,cp_phase_id     => p_phase_id
                                  );
      FETCH c_chk_phase_against_lc INTO l_temp;
      IF c_chk_phase_against_lc%NOTFOUND THEN
        CLOSE c_chk_phase_against_lc;
        l_dummy_char := null;
        code_debug (l_api_name ||' phase does not exists in the current lifecycle of the item');
        l_change_status_flag := FALSE;
        fnd_message.Set_Name(G_APP_NAME,'EGO_LC_PHASE_NOT_ALLOWED');
        l_dummy_char := get_lifecycle_name (p_lc_phase_type   => 'LIFECYCLE'
                                           ,p_proj_element_id => l_curr_lifecycle_id);
        fnd_message.set_token('LIFECYCLE', l_dummy_char);
        l_dummy_char := get_lifecycle_name (p_lc_phase_type   => 'PHASE'
                                           ,p_proj_element_id => p_phase_id);
        fnd_message.set_token('PHASE', l_dummy_char);
        fnd_msg_pub.Add;
        -- EGO_LIFECYCLE_PHASE_INVALID if phase is invalid id?
      ELSE
        CLOSE c_chk_phase_against_lc;
        l_future_phase_id := p_phase_id;
      END IF;

      --- Only promotes are allowed to 'Freeze' phase
      ---
      OPEN c_get_phase_seq(cp_phase_id => l_curr_phase_id);
      FETCH c_get_phase_seq INTO l_item_sequence;
      CLOSE c_get_phase_seq;
      OPEN c_get_phase_seq(cp_phase_id => p_phase_id);
      FETCH c_get_phase_seq INTO l_phase_sequence;
      CLOSE c_get_phase_seq;

      IF l_phase_sequence < l_item_sequence THEN
        code_debug (l_api_name ||' for CHANGE_PHASE only promotes are allowed');
        l_change_status_flag := FALSE;
        fnd_message.Set_Name(G_APP_NAME,'EGO_LC_PHASE_CHG_NOT_ALLOWED');

        fnd_message.set_token('ITEM_NUMBER', l_item_number);
        fnd_message.set_token('REVISION', l_revision);
        fnd_msg_pub.Add;
      END IF;


    END IF;

    --
    -- get the policy for changes
    --
    code_debug (l_api_name ||' calling  EGO_LIFECYCLE_USER_PUB.Get_Policy_For_Phase_Change ');
    EGO_LIFECYCLE_USER_PUB.Get_Policy_For_Phase_Change
        ( p_api_version          => p_api_version
        , p_project_id           => NULL
        , p_inventory_item_id    => l_inventory_item_id
        , p_organization_id      => l_organization_id
        , p_curr_phase_id        => l_curr_phase_id
        , p_future_phase_id      => l_future_phase_id
        , p_phase_change_code    => p_transaction_type
        , p_lifecycle_id         => l_curr_lifecycle_id
        , x_policy_code          => l_policy_code
        , x_return_status        => x_return_status
        , x_errorcode            => l_dummy_char
        , x_msg_count            => x_msg_count
        , x_msg_data             => x_msg_data
        );
    code_debug (l_api_name ||' returning EGO_LIFECYCLE_USER_PUB.Get_Policy_For_Phase_Change with status '||x_return_status);
    IF l_policy_code IN (l_policy_co_required, l_policy_not_allowed) THEN
      l_change_status_flag := FALSE;
      -- decide the message based upon
      -- item /item revision
      -- change order required OR changes not allowed
      IF l_policy_code = l_policy_co_required THEN
        code_debug (l_api_name ||' policy requires CO to promote / demote ');
        IF l_revision_id IS NULL THEN
          l_error_message := 'EGO_ITEM_NO_PROMOTE';
        ELSE
          l_error_message := 'EGO_ITEM_REV_NO_PROMOTE';
        END IF;
      ELSIF l_policy_code = l_policy_not_allowed THEN
        code_debug (l_api_name ||' policy says not allowed to promote / demote ');
        IF l_revision_id IS NULL THEN
          l_error_message := 'EGO_ITEM_NO_DEMOTE';
        ELSE
          l_error_message := 'EGO_ITEM_REV_NO_DEMOTE';
        END IF;
      END IF;
      fnd_message.Set_Name(G_APP_NAME,l_error_message);
      fnd_message.set_token('ITEM_NUMBER', l_item_number);
      IF l_revision_id IS NOT NULL THEN
        fnd_message.set_token('REVISION', l_revision);
      END IF;
      l_dummy_char := get_lifecycle_name (p_lc_phase_type   => 'LIFECYCLE'
                                         ,p_proj_element_id => l_curr_lifecycle_id);
      fnd_message.set_token('LIFE_CYCLE', l_dummy_char);
      l_dummy_char := get_lifecycle_name (p_lc_phase_type   => 'PHASE'
                                         ,p_proj_element_id => l_curr_phase_id);
      fnd_message.set_token('PHASE', l_dummy_char);
      SELECT concatenated_segments
      INTO l_dummy_char
      FROM MTL_ITEM_CATALOG_GROUPS_KFV
      WHERE ITEM_CATALOG_GROUP_ID = (
          SELECT item_catalog_group_id
          FROM (SELECT item_catalog_group_id
                FROM mtl_item_catalog_groups_b ic
                WHERE EXISTS
                        ( SELECT olc.object_classification_code CatalogId
                          FROM  ego_obj_type_lifecycles olc, fnd_objects o
                          WHERE o.obj_name =  G_EGO_ITEM
                            AND olc.object_id = o.object_id
                            AND olc.lifecycle_id = l_curr_lifecycle_id
                            AND olc.object_classification_code = l_curr_cc_id
                         )
                CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
                START WITH item_catalog_group_id = l_curr_cc_id
                ) CAT_HIER
          WHERE ROWNUM = 1
                                   );
      fnd_message.set_token('CATALOG_CATEGORY_NAME', l_dummy_char);
      fnd_msg_pub.Add;
    END IF;
  ELSIF p_transaction_type IN (EGO_ITEM_PUB.G_TTYPE_UPDATE, EGO_ITEM_PUB.G_TTYPE_DELETE) THEN
    -- check if the user has privilege to update the item.
    IF p_phase_id IS NOT NULL THEN
      -- user changing phase
      OPEN c_get_phase_seq(cp_phase_id => l_curr_phase_id);
      FETCH c_get_phase_seq INTO l_item_sequence;
      CLOSE c_get_phase_seq;
      OPEN c_get_phase_seq(cp_phase_id => p_phase_id);
      FETCH c_get_phase_seq INTO l_phase_sequence;
      CLOSE c_get_phase_seq;
      IF l_item_sequence < l_phase_sequence THEN
        l_priv_function_name := G_FN_NAME_PROMOTE;
        l_error_message := 'EGO_NO_PRIV_PROMOTE';
      ELSIF l_item_sequence > l_phase_sequence THEN
        l_priv_function_name := G_FN_NAME_DEMOTE;
        l_error_message := 'EGO_NO_PRIV_DEMOTE';
      ELSE
        -- phase is same, doing status change
        l_priv_function_name := G_FN_NAME_CHANGE_STATUS;
        l_error_message := 'EGO_NO_PRIV_CHANGE_STATUS';
      END IF;
    ELSE
      l_priv_function_name := G_FN_NAME_CHANGE_STATUS;
      l_error_message := 'EGO_NO_PRIV_CHANGE_STATUS';
    END IF;
    -- 4052565
    -- modified call to has_role_on_item from validate_role_privilege
    IF NOT has_role_on_item
                   (p_function_name        => l_priv_function_name
                   ,p_inventory_item_id    => l_inventory_item_id
                   ,p_item_number          => l_item_number
                   ,p_organization_id      => l_organization_id
                   ,p_organization_name    => NULL
                   ,p_user_id              => l_user_id
                   ,p_party_id             => NULL
                   ,p_set_message          => G_TRUE
                   ) THEN
      code_debug(l_api_name ||' user does not have privilege to update the existing change '||p_transaction_type);
      l_change_status_flag := FALSE;
      fnd_message.Set_Name(G_APP_NAME,l_error_message);
      fnd_message.set_token('USER', FND_GLOBAL.USER_NAME);
      fnd_message.set_token('ITEM_NUMBER', l_item_number);
      fnd_message.set_token('ORGANIZATION', l_org_name);
      fnd_msg_pub.Add;
    END IF;
  END IF;

  IF l_change_status_flag THEN
    code_debug (l_api_name ||' calling  EGO_ITEM_LC_IMP_PC_PUB.Create_Pending_Phase_Change ');
    IF p_transaction_type IN (EGO_ITEM_PUB.G_TTYPE_PROMOTE, EGO_ITEM_PUB.G_TTYPE_DEMOTE)  THEN
      EGO_ITEM_LC_IMP_PC_PUB.Create_Pending_Phase_Change
             (p_api_version         => p_api_version
             ,p_commit              => FND_API.G_FALSE
             ,p_inventory_item_id   => l_inventory_item_id
             ,p_item_number         => l_item_number
             ,p_organization_id     => l_organization_id
             ,p_effective_date      => l_effective_date
             ,p_pending_flag        => NULL
             ,p_revision            => l_revision
             ,p_lifecycle_id        => l_curr_lifecycle_id
             ,p_phase_id            => l_future_phase_id
             ,p_status_code         => p_status
             ,p_change_id           => NULL
             ,p_change_line_id      => NULL
             ,p_perform_security_check => FND_API.G_FALSE
             ,x_return_status       => x_return_status
             ,x_errorcode           => l_dummy_char
             ,x_msg_count           => x_msg_count
             ,x_msg_data            => x_msg_data
             );
    ELSIF p_transaction_type = EGO_ITEM_PUB.G_TTYPE_CHANGE_PHASE  THEN

      EGO_ITEM_LC_IMP_PC_PUB.Create_Pending_Phase_Change
             (p_api_version         => p_api_version
             ,p_commit              => FND_API.G_FALSE
             ,p_inventory_item_id   => l_inventory_item_id
             ,p_item_number         => l_item_number
             ,p_organization_id     => l_organization_id
             ,p_effective_date      => l_effective_date
             ,p_pending_flag        => NULL
             ,p_revision            => l_revision
             ,p_lifecycle_id        => l_curr_lifecycle_id
             ,p_phase_id            => l_future_phase_id
             ,p_status_code         => NULL
             ,p_change_id           => NULL
             ,p_change_line_id      => NULL
             ,p_perform_security_check => FND_API.G_FALSE
             ,x_return_status       => x_return_status
             ,x_errorcode           => l_dummy_char
             ,x_msg_count           => x_msg_count
             ,x_msg_data            => x_msg_data
             );

    ELSIF p_transaction_type = EGO_ITEM_PUB.G_TTYPE_CHANGE_STATUS THEN
      EGO_ITEM_LC_IMP_PC_PUB.Create_Pending_Phase_Change
             (p_api_version         => p_api_version
             ,p_commit              => FND_API.G_FALSE
             ,p_inventory_item_id   => l_inventory_item_id
             ,p_item_number         => l_item_number
             ,p_organization_id     => l_organization_id
             ,p_effective_date      => l_effective_date
             ,p_pending_flag        => NULL
             ,p_revision            => NULL
             ,p_lifecycle_id        => NULL
             ,p_phase_id            => NULL
             ,p_status_code         => p_status
             ,p_change_id           => NULL
             ,p_change_line_id      => NULL
             ,p_perform_security_check => FND_API.G_FALSE
             ,x_return_status       => x_return_status
             ,x_errorcode           => l_dummy_char
             ,x_msg_count           => x_msg_count
             ,x_msg_data            => x_msg_data
             );

    ELSIF p_transaction_type IN (EGO_ITEM_PUB.G_TTYPE_UPDATE, EGO_ITEM_PUB.G_TTYPE_DELETE) THEN
      EGO_ITEM_LC_IMP_PC_PUB.Modify_Pending_Phase_Change
             (p_api_version         => p_api_version
             ,p_commit              => FND_API.G_FALSE
             ,p_transaction_type    => p_transaction_type
             ,p_inventory_item_id   => l_inventory_item_id
             ,p_organization_id     => l_organization_id
             ,p_revision_id         => l_revision_id
             ,p_lifecycle_id        => p_lifecycle_id
             ,p_phase_id            => p_phase_id
             ,p_status_code         => p_status
             ,p_change_id           => NULL
             ,p_change_line_id      => NULL
             ,p_effective_date      => p_effective_date
             ,p_new_effective_date  => l_effective_date
             ,p_perform_security_check => FND_API.G_FALSE
             ,x_return_status       => x_return_status
             ,x_errorcode           => l_dummy_char
             ,x_msg_count           => x_msg_count
             ,x_msg_data            => x_msg_data
             );
    END IF;

    code_debug (l_api_name ||' return status from ego_item_lc_imp_pc_pub.create_pending_phase_change '||x_return_status);
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      code_debug (l_api_name ||' cannot create/modify/delete pending phase change '||x_msg_data);
      --
      -- this will occur only in case of exception
      -- all valid values are passed.
      --
      IF x_msg_count = 1 THEN
        fnd_message.Set_Name(G_APP_NAME,'EGO_GENERIC_MSG_TEXT');
        fnd_message.set_token('MESSAGE', x_msg_data);
        fnd_msg_pub.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF  FND_API.To_Boolean(p_implement_changes) THEN
      code_debug (l_api_name ||' calling EGO_ITEM_LC_IMP_PC_PUB.Implement_Pending_Changes ');
      l_is_master_org := EGO_ITEM_LC_IMP_PC_PUB.get_master_org_status(l_organization_id);
      l_revision_master_controlled := FND_API.g_false;
      l_status_master_controlled := EGO_ITEM_LC_IMP_PC_PUB.get_master_controlled_status();
      EGO_ITEM_LC_IMP_PC_PUB.Implement_Pending_Changes
              (p_api_version                  => p_api_version
              ,p_inventory_item_id            => l_inventory_item_id
              ,p_organization_id              => l_organization_id
              ,p_revision_id                  => l_revision_id
              ,p_revision_master_controlled   => l_revision_master_controlled
              ,p_status_master_controlled     => l_status_master_controlled
              ,p_is_master_org                => l_is_master_org
              ,p_perform_security_check       => FND_API.G_FALSE
              ,x_return_status                => x_return_status
              ,x_errorcode                    => l_dummy_char
              ,x_msg_count                    => x_msg_count
              ,x_msg_data                     => x_msg_data
              );
      code_debug (l_api_name ||' return status from ego_item_lc_imp_pc_pub.Implement_Pending_Changes '||x_return_status);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        code_debug (l_api_name ||' cannot implement changes '||x_msg_data);
        IF x_msg_count = 1 THEN
          fnd_message.Set_Name(G_APP_NAME,'EGO_GENERIC_MSG_TEXT');
          fnd_message.set_token('MESSAGE', x_msg_data);
          fnd_msg_pub.Add;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
  ELSE
    code_debug (l_api_name ||' flashing all errors ');
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --
  -- commit data
  --
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF FND_API.To_Boolean( p_commit ) THEN
        ROLLBACK TO  PROCESS_ITEM_PHASE_SP;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      IF FND_API.To_Boolean( p_commit ) THEN
        ROLLBACK TO  PROCESS_ITEM_PHASE_SP;
      END IF;
      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
      IF c_get_item_det%ISOPEN THEN
        CLOSE c_get_item_det;
      END IF;
      IF c_get_item_rev_det%ISOPEN THEN
        CLOSE c_get_item_rev_det;
      END IF;
      IF c_get_phase_seq%ISOPEN THEN
        CLOSE c_get_phase_seq;
      END IF;
      IF c_get_next_phase%ISOPEN THEN
        CLOSE c_get_next_phase;
      END IF;
      IF c_get_priv_phase%ISOPEN THEN
        CLOSE c_get_priv_phase;
      END IF;
      IF c_chk_phase_against_lc%ISOPEN THEN
        CLOSE c_chk_phase_against_lc;
      END IF;
      FND_MESSAGE.Set_Name(G_APP_NAME, G_PLSQL_ERR);
      FND_MESSAGE.Set_Token(G_PKG_NAME_TOKEN, G_PKG_NAME);
      FND_MESSAGE.Set_Token(G_API_NAME_TOKEN, l_api_name);
      FND_MESSAGE.Set_Token(G_SQL_ERR_MSG_TOKEN, SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      code_debug(' Exception in '||l_api_name||' : ' ||x_msg_data );
END Process_item_phase_and_status;

------------------------------------------------------------------------------
  -- Start OF comments
  -- API name  : Implement_Item_Pending_Changes
  -- TYPE      : Public
  -- Pre-reqs  : None
  -- PROCEDURE : Implement the pending changes on the item
  --
------------------------------------------------------------------------------
PROCEDURE Implement_Item_Pending_Changes
      (p_api_version           IN  NUMBER
      ,p_commit                IN  VARCHAR2
      ,p_init_msg_list         IN  VARCHAR2
      ,p_inventory_item_id     IN  NUMBER
      ,p_item_number           IN  VARCHAR2
      ,p_organization_id       IN  NUMBER
      ,p_organization_code     IN  VARCHAR2
      ,p_revision_id           IN  NUMBER
      ,p_revision              IN  VARCHAR2
      ,x_return_status         OUT NOCOPY VARCHAR2
      ,x_msg_count             OUT NOCOPY NUMBER
      ,x_msg_data              OUT NOCOPY VARCHAR2
     ) IS
  l_api_name                    VARCHAR2(30);
  l_api_version                 NUMBER;
  l_organization_id             mtl_system_items_b.organization_id%TYPE;
  l_inventory_item_id           mtl_system_items_b.inventory_item_id%TYPE;
  l_item_number                 mtl_system_items_b_kfv.concatenated_segments%TYPE;
  l_approval_status             mtl_system_items_b.approval_status%TYPE;
  l_revision_id                 mtl_item_revisions_b.revision_id%TYPE;
  l_revision                    mtl_item_revisions_b.revision%TYPE;
  l_dummy_char                  VARCHAR2(999);
  l_revision_master_controlled  VARCHAR2(1);
  l_status_master_controlled    VARCHAR2(1);
  l_is_master_org               VARCHAR2(1);
  l_invalid_flag                BOOLEAN;
  l_implement_flag              BOOLEAN;

BEGIN
  l_api_name := 'Implement_Item_Pending_Changes';
  l_api_version := 1.0;
  code_debug(l_api_name ||' started with params ');
  code_debug(' p_api_version '|| p_api_version||' p_commit '||p_commit||' p_init_msg_list '||p_init_msg_list );
  code_debug(' p_inventory_item_id '||p_inventory_item_id||' p_item_number '||p_item_number||' p_revision  '||p_revision );
  code_debug(' p_organization_id '||p_organization_id ||' p_organization_code '||p_organization_code||' p_revision_id '||p_revision_id );
  IF FND_API.To_Boolean( p_commit ) THEN
    SAVEPOINT IMPLEMENT_CHANGES_SP;
  END IF;
  --
  -- Initialize message list
  --
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;
  code_debug(l_api_name||' msg pub initialized ' );
  --
  --Standard checks
  --
  IF NOT FND_API.Compatible_API_Call (l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,g_pkg_name) THEN
    code_debug (l_api_name ||' invalid api version ');
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --
  -- check for mandatory params
  --
  IF ( (p_inventory_item_id IS NULL AND p_item_number IS NULL)
        OR
       (p_organization_id IS NULL AND p_organization_code IS NULL)
     ) THEN
    --
    -- invalid params passed
    --
    code_debug (l_api_name ||' invalid parameters passed ');
    fnd_message.Set_Name(G_APP_NAME, G_INVALID_PARAMS_MSG);
    fnd_message.Set_Token(G_PKG_NAME_TOKEN, G_PKG_NAME);
    fnd_message.Set_Token(G_PROC_NAME_TOKEN, l_api_name);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  -- validate organization details
  --
  l_organization_id   := p_organization_id;
  l_inventory_item_id := p_inventory_item_id;
  l_item_number       := p_item_number;
  l_revision_id       := p_revision_id;
  l_revision          := p_revision;
  l_implement_flag    := TRUE;

  IF NOT validate_org (x_organization_id   => l_organization_id
                      ,p_organization_code => p_organization_code
                      ,p_set_message       => G_TRUE) THEN
    code_debug (l_api_name ||' invalid organiation passed ');
    l_implement_flag := FALSE;
  ELSE
    --
    -- validate item details
    --
    IF NOT validate_item (x_inventory_item_id => l_inventory_item_id
                         ,x_item_number       => l_item_number
                         ,x_approval_status   => l_approval_status
                         ,p_organization_id   => l_organization_id
                         ,p_set_message       => G_TRUE) THEN
      code_debug (l_api_name ||' invalid item passed ');
      l_implement_flag := FALSE;
    ELSE
-- 4052565
-- privilege check is now done in Implement_Pending_changes
--      IF NOT validate_role_privilege (p_function_name     => G_FN_NAME_CHANGE_STATUS
--                                     ,p_inventory_item_id => l_inventory_item_id
--                                     ,p_item_number       => l_item_number
--                                     ,p_organization_id   => l_organization_id
--                                     ,p_organization_name => NULL
--                                     ,p_set_message       => G_TRUE) THEN
--        code_debug(l_api_name ||' user does not have privilege to implement pending changes');
--        l_implement_flag := FALSE;
--      END IF;
      --
      -- validate revision details
      --
      IF (l_revision_id IS NOT NULL OR l_revision IS NOT NULL) THEN
        IF NOT validate_item_rev
                             (x_revision_id        => l_revision_id
                             ,x_revision           => l_revision
                             ,p_inventory_item_id  => l_inventory_item_id
                             ,p_organization_id    => l_organization_id
                             ,p_set_message        => G_TRUE ) THEN
          code_debug (l_api_name ||' invalid revision passed ');
          l_implement_flag := FALSE;
        END IF;
      END IF;
    END IF;
  END IF;

  IF l_implement_flag THEN
    code_debug (l_api_name ||' calling  EGO_ITEM_LC_IMP_PC_PUB.Implement_Pending_Changes ');
    l_is_master_org := EGO_ITEM_LC_IMP_PC_PUB.get_master_org_status(l_organization_id);
    l_revision_master_controlled := FND_API.g_false;
    l_status_master_controlled := EGO_ITEM_LC_IMP_PC_PUB.get_master_controlled_status();
    EGO_ITEM_LC_IMP_PC_PUB.Implement_Pending_Changes
              (p_api_version                  => p_api_version
              ,p_inventory_item_id            => l_inventory_item_id
              ,p_organization_id              => l_organization_id
              ,p_revision_id                  => l_revision_id
              ,p_revision_master_controlled   => l_revision_master_controlled
              ,p_status_master_controlled     => l_status_master_controlled
              ,p_is_master_org                => l_is_master_org
              ,p_perform_security_check       => FND_API.G_TRUE
              ,x_return_status                => x_return_status
              ,x_errorcode                    => l_dummy_char
              ,x_msg_count                    => x_msg_count
              ,x_msg_data                     => x_msg_data
              );
    code_debug (l_api_name ||' return status from ego_item_lc_imp_pc_pub.Implement_Pending_Changes '||x_return_status);
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF x_msg_count = 1 THEN
        code_debug (l_api_name ||' cannot implement changes for '||x_msg_data);
        fnd_message.Set_Name(G_APP_NAME,'EGO_GENERIC_MSG_TEXT');
        fnd_message.set_token('MESSAGE', x_msg_data);
        fnd_msg_pub.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    code_debug (l_api_name ||' flashing all errors ');
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --
  -- commit data
  --
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF FND_API.To_Boolean( p_commit ) THEN
        ROLLBACK TO  IMPLEMENT_CHANGES_SP;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      IF FND_API.To_Boolean( p_commit ) THEN
        ROLLBACK TO  IMPLEMENT_CHANGES_SP;
      END IF;
      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.Set_Name(G_APP_NAME, G_PLSQL_ERR);
      FND_MESSAGE.Set_Token(G_PKG_NAME_TOKEN, G_PKG_NAME);
      FND_MESSAGE.Set_Token(G_API_NAME_TOKEN, l_api_name);
      FND_MESSAGE.Set_Token(G_SQL_ERR_MSG_TOKEN, SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      code_debug(' Exception in '||l_api_name||' : ' ||x_msg_data );
END Implement_Item_Pending_Changes;


-- -----------------------------------------------------------------------------
--  Fix for Bug# 3945885.
--
--  API Name:       Get_Seq_Gen_Item_Nums
--
--  Description:
--    API to return a Sequence of Item Numbers, given the Item Catalog Group ID.
--
-- -----------------------------------------------------------------------------
 PROCEDURE Get_Seq_Gen_Item_Nums( p_item_catalog_group_id    IN  NUMBER
         ,p_org_id_tbl               IN  DBMS_SQL.VARCHAR2_TABLE
                                 ,x_item_num_tbl             IN OUT NOCOPY EGO_VARCHAR_TBL_TYPE
                                 ) IS

   -----------------------------------------------------------------------
   -- Variables used to query Item Number Generation Method
   -----------------------------------------------------------------------
   l_itemgen_method_table         DBMS_SQL.VARCHAR2_TABLE;
   l_itemgen_seq_table            DBMS_SQL.VARCHAR2_TABLE;
   l_itemgen_prefix_table         DBMS_SQL.VARCHAR2_TABLE;
   l_itemgen_suffix_table         DBMS_SQL.VARCHAR2_TABLE;
   l_itemgen_method_cursor        INTEGER;
   l_itemgen_method_exec          INTEGER;
   l_itemgen_method_rows_cnt      NUMBER;

   l_item_num                     VARCHAR(1000);
   l_item_num_tbl                 EGO_VARCHAR_TBL_TYPE;
   l_exists                       VARCHAR2(1);
   l_can_itemnum_gen              BOOLEAN;
   l_itemgen_rownum               NUMBER;
   l_new_itemgen_sql              VARCHAR2(1000);
   -----------------------------------------------------------------------

   l_itemgen_hierarchy_sql    VARCHAR2(10000) :=
   ' SELECT EgoNewItemReqSetupEO.ITEM_CATALOG_GROUP_ID,             '||
   '        EgoNewItemReqSetupEO.PARENT_CATALOG_GROUP_ID,           '||
   '        DECODE(EgoNewItemReqSetupEO.ITEM_NUM_GEN_METHOD,            '||
   '               null, DECODE(EgoNewItemReqSetupEO.PARENT_CATALOG_GROUP_ID, null, ''U'', ''I''), '||
   '               EgoNewItemReqSetupEO.ITEM_NUM_GEN_METHOD) ITEM_NUM_GEN_METHOD,       '||
   '        EgoNewItemReqSetupEO.ITEM_NUM_SEQ_NAME,             '||
   '        EgoNewItemReqSetupEO.PREFIX,                '||
   '        EgoNewItemReqSetupEO.SUFFIX                 '||
   ' FROM MTL_ITEM_CATALOG_GROUPS_B EgoNewItemReqSetupEO            '||
   ' CONNECT BY PRIOR EgoNewItemReqSetupEO.PARENT_CATALOG_GROUP_ID =          '||
   '             EgoNewItemReqSetupEO.ITEM_CATALOG_GROUP_ID           '||
   ' START WITH EgoNewItemReqSetupEO.ITEM_CATALOG_GROUP_ID = :ITEM_CATALOG_GROUP_ID     ';


   CURSOR c_itemnum_exists_cursor (cp_item_number       IN  VARCHAR2
                                  ,cp_organization_id   IN  NUMBER ) IS
     SELECT 'x'
     FROM   mtl_system_items_b_kfv
     WHERE  concatenated_segments = cp_item_number
       AND  organization_id       = cp_organization_id;

 BEGIN

      l_itemgen_method_cursor := DBMS_SQL.OPEN_CURSOR;
      DBMS_SQL.PARSE(l_itemgen_method_cursor, l_itemgen_hierarchy_sql, DBMS_SQL.NATIVE);

      LOOP -- Loop for every 2500 rows.

        DBMS_SQL.DEFINE_ARRAY(
            c           => l_itemgen_method_cursor  -- cursor --
                , position    => 3                        -- select position --
                , c_tab       => l_itemgen_method_table   -- table of chars --
                , cnt         => 2500                     -- rows requested --
                , lower_bound => 1                        -- start at --
                 );

        DBMS_SQL.DEFINE_ARRAY(
            c           => l_itemgen_method_cursor  -- cursor --
                , position    => 4                        -- select position --
                , c_tab       => l_itemgen_seq_table      -- table of chars --
                , cnt         => 2500                     -- rows requested --
                , lower_bound => 1                        -- start at --
                 );

        DBMS_SQL.DEFINE_ARRAY(
            c           => l_itemgen_method_cursor  -- cursor --
                , position    => 5                        -- select position --
                , c_tab       => l_itemgen_prefix_table   -- table of chars --
                , cnt         => 2500                     -- rows requested --
                , lower_bound => 1                        -- start at --
                 );

        DBMS_SQL.DEFINE_ARRAY(
            c           => l_itemgen_method_cursor  -- cursor --
                , position    => 6                        -- select position --
                , c_tab       => l_itemgen_suffix_table   -- table of chars --
                , cnt         => 2500                     -- rows requested --
                , lower_bound => 1                        -- start at --
                 );

        DBMS_SQL.BIND_VARIABLE(l_itemgen_method_cursor, ':ITEM_CATALOG_GROUP_ID', p_item_catalog_group_id);

        l_itemgen_method_exec := DBMS_SQL.EXECUTE(l_itemgen_method_cursor);
        l_itemgen_method_rows_cnt := DBMS_SQL.FETCH_ROWS(l_itemgen_method_cursor);

        DBMS_SQL.COLUMN_VALUE(l_itemgen_method_cursor, 3, l_itemgen_method_table);
        DBMS_SQL.COLUMN_VALUE(l_itemgen_method_cursor, 4, l_itemgen_seq_table);
        DBMS_SQL.COLUMN_VALUE(l_itemgen_method_cursor, 5, l_itemgen_prefix_table);
        DBMS_SQL.COLUMN_VALUE(l_itemgen_method_cursor, 6, l_itemgen_suffix_table);

        --begin add for bug 9127677
        IF DBMS_SQL.IS_OPEN(l_itemgen_method_cursor) then
           DBMS_SQL.Close_Cursor(l_itemgen_method_cursor);
        END IF;
	      --end add for bug 9127677
        --DBMS_OUTPUT.PUT_LINE('load_item_oper_attr_values: Retrieved rows => '||To_char(l_itemgen_method_rows_cnt));

        l_can_itemnum_gen := FALSE;
        l_itemgen_rownum := 0;
        FOR i IN 1..l_itemgen_method_table.COUNT  LOOP
          --DBMS_OUTPUT.PUT_LINE('Item Gen Method  => '|| l_itemgen_method_table(i));
          IF (l_itemgen_method_table(i) IN ('I','S')) THEN
            IF (l_itemgen_method_table(i) IN ('S')) THEN
              l_can_itemnum_gen := TRUE;
              l_itemgen_rownum  := i;
              --DBMS_OUTPUT.PUT_LINE('Item Number will be generated using Row => '||i);
              EXIT;
            ELSE
              --DBMS_OUTPUT.PUT_LINE('Need to traverse up 1 more level');
              NULL;
            END IF; --end: IF (l_itemgen_method_table(i) IN ('S'))
          ELSE
            --DBMS_OUTPUT.PUT_LINE('Item Number cannot be generated !!! ');
            EXIT;
          END IF; --end: IF (l_itemgen_method_table(i) IN ('I','S'))
        END LOOP; --end: FOR (i:=0; i < l_itemgen_method_table.COUNT; i++)

        l_new_itemgen_sql := '';
        IF (l_can_itemnum_gen) THEN
          ---------------------------------------------------------------------
          --As many Org IDs in the table, so many Item Numbers to be generated
          ---------------------------------------------------------------------
          FOR i IN 1..p_org_id_tbl.LAST
          LOOP --To generate ~requested number~ of Item Numbers
            LOOP -- To generate 1 Valid Item Number
              -----------------------------------------------------
              --Since this is a loop, re-set the string each time.
              -----------------------------------------------------
              l_new_itemgen_sql := '';
              l_new_itemgen_sql := l_new_itemgen_sql || ' SELECT ';
              l_new_itemgen_sql := l_new_itemgen_sql ||''''|| l_itemgen_prefix_table(l_itemgen_rownum) || ''' || ';
              l_new_itemgen_sql := l_new_itemgen_sql || l_itemgen_seq_table(l_itemgen_rownum) || '.NEXTVAL || ';
              l_new_itemgen_sql := l_new_itemgen_sql ||''''|| l_itemgen_suffix_table(l_itemgen_rownum)||'''';
              l_new_itemgen_sql := l_new_itemgen_sql || ' FROM DUAL ';

              --DBMS_OUTPUT.PUT_LINE('l_new_itemgen_sql => '||l_new_itemgen_sql);
              EXECUTE IMMEDIATE l_new_itemgen_sql INTO l_item_num;

              ------------------------------------------------------------------------
              --Check if this Item Number *doesnt* already exist.
              --NOTE: Convert the VARCHAR2 Org ID to NUMBER before calling the Cursor
              ------------------------------------------------------------------------
              OPEN c_itemnum_exists_cursor(l_item_num, FND_NUMBER.CANONICAL_TO_NUMBER(p_org_id_tbl(i)));
              FETCH c_itemnum_exists_cursor INTO l_exists;
              IF (c_itemnum_exists_cursor%NOTFOUND) THEN
                CLOSE c_itemnum_exists_cursor;
                EXIT;
              END IF; --end: IF (c_itemnum_exists_cursor%NOTFOUND) THEN
              CLOSE c_itemnum_exists_cursor;
            END LOOP; --end: To generate 1 Valid Item Number

            -----------------------------------------------------------------------
            -- If NULL, then create a New VARCHAR table.
            -----------------------------------------------------------------------
            IF l_item_num_tbl IS NULL THEN
              l_item_num_tbl := EGO_VARCHAR_TBL_TYPE();
            END IF;

            -----------------------------------------------------------------------
            -- Add newly generated Item Number to the end of existing table.
            -----------------------------------------------------------------------
            l_item_num_tbl.EXTEND();
            l_item_num_tbl(l_item_num_tbl.LAST) := l_item_num;

          END LOOP; --end: FOR i IN 1..p_num_of_items

          x_item_num_tbl := l_item_num_tbl;

        ELSE
          x_item_num_tbl := NULL;
        END IF; --end: IF (l_can_itemnum_gen) THEN

        EXIT WHEN l_itemgen_method_rows_cnt < 2500;

      END LOOP; --end: Loop for every 2500 rows.

 END Get_Seq_Gen_Item_Nums;


  -------------------------------------------------------------------------------------
  --  API Name: Get_Default_Template_Id                                              --
  --                                                                                 --
  --  Description: This function takes a catalog group ID as a parameter and returns --
  --    the template ID corresponding to the default template for the specified      --
  --    catalog group.                                                               --
  --                                                                                 --
  --  Parameters: p_category_id      NUMBER  Catalog group ID whose default template --
  --                                         is to be returned; if null, return      --
  --                                         value is null.                          --
  -------------------------------------------------------------------------------------
  FUNCTION Get_Default_Template_Id (
             p_category_id          IN NUMBER
           ) RETURN NUMBER IS

    l_parent_id                        NUMBER;
    l_default_template                 NUMBER;

  BEGIN

    l_parent_id := NULL;
    l_default_template := NULL;

    IF (p_category_id IS NULL) THEN

      -- the case when the catalog group ID is null
      RETURN FND_PROFILE.VALUE('INV_ITEM_DEFAULT_TEMPLATE');

    ELSE

      BEGIN
        -- search for a default template for the given category
        SELECT TEMPLATE_ID
          INTO l_default_template
          FROM EGO_CAT_GRP_TEMPLATES
         WHERE CATALOG_GROUP_ID = p_category_id
           AND DEFAULT_FLAG = 'Y'
           AND ROWNUM = 1;

        RETURN l_default_template;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN

          -- if a default is not found, get the parent category ID
          SELECT PARENT_CATALOG_GROUP_ID
            INTO l_parent_id
            FROM MTL_ITEM_CATALOG_GROUPS_B
           WHERE ITEM_CATALOG_GROUP_ID = p_category_id;

          -- recurse on the parent category
          RETURN Get_Default_Template_Id(
                   p_category_id     => l_parent_id
                 );

      END;

    END IF; -- IF (p_category_id IS NULL)

  END Get_Default_Template_Id;

-- -----------------------------------------------------------------------------
--  API Name:       Validate_Required_Attrs
--
--  Description:
--    Given an Item whose Primary Keys are passed in, find those attributes
--    whose values are required but is null for the Item.
--    Returns EGO_USER_ATTR_TABLE containing list of required
--    attributes information.
-- -----------------------------------------------------------------------------
--
PROCEDURE Validate_Required_Attrs (
        p_api_version                   IN   NUMBER
       ,p_inventory_item_id             IN   NUMBER
       ,p_organization_id               IN   NUMBER
       ,p_revision_id                   IN   NUMBER
       ,x_attributes_req_table          OUT NOCOPY EGO_USER_ATTR_TABLE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS
    l_api_name                  CONSTANT VARCHAR2(30) := 'Validate_Required_Attrs';
    l_pk_column_values          EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_data_level_values         EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_class_code_values         EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_attr_group_type_table     EGO_VARCHAR_TBL_TYPE;
    l_item_catalog_group_id     NUMBER;
    l_related_class_codes_list  VARCHAR2(150);
    l_token_table               ERROR_HANDLER.Token_Tbl_Type;

    CURSOR get_catalog_group_id IS
      SELECT ITEM_CATALOG_GROUP_ID
        INTO l_item_catalog_group_id
        FROM MTL_SYSTEM_ITEMS_B
       WHERE INVENTORY_ITEM_ID = p_inventory_item_id
         AND ORGANIZATION_ID = p_organization_id;

  BEGIN

    -----------------------
    -- Get PKs organized --
    -----------------------
    l_pk_column_values :=
      EGO_COL_NAME_VALUE_PAIR_ARRAY(
        EGO_COL_NAME_VALUE_PAIR_OBJ('INVENTORY_ITEM_ID', TO_CHAR(p_inventory_item_id))
       ,EGO_COL_NAME_VALUE_PAIR_OBJ('ORGANIZATION_ID', TO_CHAR(p_organization_id))
      );

    ----------------------
    -- Get Class Codes  --
    ----------------------
    FOR catalog_group_rec IN get_catalog_group_id LOOP
       l_item_catalog_group_id := catalog_group_rec.ITEM_CATALOG_GROUP_ID;
    END LOOP;

    Get_Related_Class_Codes(
       p_classification_code      => l_item_catalog_group_id
      ,x_related_class_codes_list => l_related_class_codes_list
    );

    l_class_code_values :=
      EGO_COL_NAME_VALUE_PAIR_ARRAY(
        EGO_COL_NAME_VALUE_PAIR_OBJ('ITEM_CATALOG_GROUP_ID', TO_CHAR(l_item_catalog_group_id))
       ,EGO_COL_NAME_VALUE_PAIR_OBJ('RELATED_CLASS_CODE_LIST_1', l_related_class_codes_list)
      );

    ----------------------
    -- Get Data Levels  --
    ----------------------
    l_data_level_values :=
      EGO_COL_NAME_VALUE_PAIR_ARRAY(
        EGO_COL_NAME_VALUE_PAIR_OBJ('ITEM_LEVEL', null)
       ,EGO_COL_NAME_VALUE_PAIR_OBJ('ITEM_REVISION_LEVEL', TO_CHAR(p_revision_id))
      );

    ---------------------------------
    -- Setup attribute group type  --
    ---------------------------------
    l_attr_group_type_table := EGO_VARCHAR_TBL_TYPE();
    l_attr_group_type_table.EXTEND();
    l_attr_group_type_table(l_attr_group_type_table.LAST):= 'EGO_ITEMMGMT_GROUP';


    EGO_USER_ATTRS_DATA_PVT.Validate_Required_Attrs (
      p_api_version                   => p_api_version
     ,p_object_name                   => 'EGO_ITEM'
     ,p_pk_column_name_value_pairs    => l_pk_column_values
     ,p_class_code_name_value_pairs   => l_class_code_values
     ,p_data_level_name_value_pairs   => l_data_level_values
     ,p_attr_group_type_table         => l_attr_group_type_table
     ,x_attributes_req_table          => x_attributes_req_table
     ,x_return_status                 => x_return_status
     ,x_errorcode                     => x_errorcode
     ,x_msg_count                     => x_msg_count
     ,x_msg_data                      => x_msg_data
    );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR;

      x_msg_count := ERROR_HANDLER.Get_Message_Count();

      IF (x_msg_count > 0) THEN
        ERROR_HANDLER.Log_Error(
          p_write_err_to_inttable         => 'Y'
         ,p_write_err_to_debugfile        => ERROR_HANDLER.Get_Debug()
        );

        IF (x_msg_count = 1) THEN
          DECLARE
            message_list  ERROR_HANDLER.Error_Tbl_Type;
          BEGIN
            ERROR_HANDLER.Get_Message_List(message_list);
            x_msg_data := message_list(message_list.FIRST).message_text;
          END;
        ELSE
          x_msg_data := NULL;
        END IF;
      END IF;

    WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      DECLARE
        l_token_table            ERROR_HANDLER.Token_Tbl_Type;
        l_dummy_entity_index     NUMBER;
        l_dummy_entity_id        VARCHAR2(60);
        l_dummy_message_type     VARCHAR2(1);
      BEGIN
        l_token_table(1).TOKEN_NAME := 'PKG_NAME';
        l_token_table(1).TOKEN_VALUE := G_PKG_NAME;
        l_token_table(2).TOKEN_NAME := 'API_NAME';
        l_token_table(2).TOKEN_VALUE := l_api_name;
        l_token_table(3).TOKEN_NAME := 'SQL_ERR_MSG';
        l_token_table(3).TOKEN_VALUE := SQLERRM;

        ERROR_HANDLER.Add_Error_Message(
            p_message_name                  => 'EGO_PLSQL_ERR'
           ,p_application_id                => 'EGO'
           ,p_token_tbl                     => l_token_table
           ,p_message_type                  => FND_API.G_RET_STS_ERROR
        );

        ERROR_HANDLER.Get_Message(x_message_text => x_msg_data
                                 ,x_entity_index => l_dummy_entity_index
                                 ,x_entity_id    => l_dummy_entity_id
                                 ,x_message_type => l_dummy_message_type);

      END;

END Validate_Required_Attrs;










PROCEDURE Generate_GDSN_Ext_AG_TP_Views  (
                                            p_attr_group_name   IN VARCHAR2 DEFAULT NULL
                                           ,ERRBUF              OUT NOCOPY VARCHAR2
                                           ,RETCODE             OUT NOCOPY VARCHAR2
                                         )
IS

 TYPE VIEW_INFO IS RECORD
  (
      ITEM_ATTR_GROUP_NAME    VARCHAR2(30)
     ,TP_ATTR_GROUP_NAME      VARCHAR2(30)
     ,ITEM_ATTR_AGV_NAME      VARCHAR2(30)
     ,TP_ATTR_AGV_NAME        VARCHAR2(30)
     ,ITEM_AGV_ALIAS          VARCHAR2(30)
     ,TP_AGV_ALIAS            VARCHAR2(30)
     ,FINAL_WRAPPER_AGV_NAME  VARCHAR2(30)
  );

 TYPE VIEW_INFO_TABLE IS TABLE OF VIEW_INFO
 INDEX BY BINARY_INTEGER;

  CURSOR c_check_agv_name (cp_agv_name         IN VARCHAR2
                          ,cp_application_id   IN NUMBER
                          ,cp_attr_group_type  IN VARCHAR2
                          ,cp_attr_group_name  IN VARCHAR2
                          ) IS
  SELECT AGV_NAME
  FROM EGO_FND_DSC_FLX_CTX_EXT EXT1
  WHERE EXT1.AGV_NAME = cp_agv_name
    AND EXT1.ATTR_GROUP_ID NOT IN  (SELECT ATTR_GROUP_ID
               FROM EGO_FND_DSC_FLX_CTX_EXT EXT2
              WHERE EXT2.AGV_NAME = cp_agv_name
                AND EXT2.APPLICATION_ID = cp_application_id
                AND EXT2.DESCRIPTIVE_FLEXFIELD_NAME = cp_attr_group_type
                AND EXT2.DESCRIPTIVE_FLEX_CONTEXT_CODE = cp_attr_group_name);

  CURSOR c_check_obj_name (cp_agv_name        IN  VARCHAR2
                          ,cp_application_id  IN NUMBER
                          ,cp_attr_group_type IN VARCHAR2
                          ,cp_attr_group_name IN VARCHAR2
                          )IS
 SELECT OBJECT_NAME
   FROM SYS.ALL_OBJECTS
  WHERE OBJECT_NAME = cp_agv_name
    AND OBJECT_NAME NOT IN (SELECT AGV_NAME
                              FROM EGO_FND_DSC_FLX_CTX_EXT
                             WHERE AGV_NAME = cp_agv_name
                               AND APPLICATION_ID  = cp_application_id
                               AND DESCRIPTIVE_FLEXFIELD_NAME =  cp_attr_group_type
                               AND DESCRIPTIVE_FLEX_CONTEXT_CODE =  cp_attr_group_name
                           );


 l_views_to_process           VIEW_INFO_TABLE;

 l_return_status              VARCHAR2(3);
 l_errorcode                  NUMBER;
 l_msg_count                  NUMBER;
 l_msg_data                   VARCHAR2(1000);
 l_temp_num                   NUMBER;
 l_multi_row_ag               VARCHAR2(2);
 l_ag_id                      VARCHAR2(20);
 l_temp_agv_name              VARCHAR2(30);
 l_views_exist                VARCHAR2(32767);
 l_view_compile_errs          VARCHAR2(32767);
 l_item_view_failed           BOOLEAN;
 l_tp_view_failed             BOOLEAN;

 ERR_OCCURED                  EXCEPTION;

BEGIN


  ----------------------------------------------
  -- Building up the table of Attr groups to  --
  -- be processed                             --
  ----------------------------------------------


  l_views_to_process(1).ITEM_ATTR_GROUP_NAME   := 'EGOINT_GDSN_TRADE_ITEM_INFO';
  l_views_to_process(1).ITEM_ATTR_AGV_NAME     := 'EGO_SBDH_TRADE_ITEM_INFO_AGV';


  l_views_to_process(2).ITEM_ATTR_GROUP_NAME   := 'EGOINT_GDSN_PRICE';
  l_views_to_process(2).TP_ATTR_GROUP_NAME     := 'EGOINT_GDSN_PRICE';
  l_views_to_process(2).ITEM_ATTR_AGV_NAME     := 'EGO_SBDH_PRICE_INFO_AGV';
  l_views_to_process(2).TP_ATTR_AGV_NAME       := 'EGO_SBDH_PRICE_INFO_TPAGV';
  l_views_to_process(2).ITEM_AGV_ALIAS         := 'ITEMAGV';
  l_views_to_process(2).TP_AGV_ALIAS           := 'TPAGV';
  l_views_to_process(2).FINAL_WRAPPER_AGV_NAME := 'EGO_SBDH_PRICE_INFO_TPV';

  l_views_to_process(3).ITEM_ATTR_GROUP_NAME   := 'EGOINT_GDSN_VAR_TRD_ITEM_TYPE';
  l_views_to_process(3).TP_ATTR_GROUP_NAME     := 'EGOINT_GDSN_VAR_TRD_ITEM_TYPE';
  l_views_to_process(3).ITEM_ATTR_AGV_NAME     := 'EGO_SBDH_VAR_TRD_ITEM_TYPE_AGV';
  l_views_to_process(3).TP_ATTR_AGV_NAME       := 'EGO_SBDH_VAR_TRD_ITM_TYP_TPAGV';
  l_views_to_process(3).ITEM_AGV_ALIAS         := 'ITEMAGV';
  l_views_to_process(3).TP_AGV_ALIAS           := 'TPAGV';
  l_views_to_process(3).FINAL_WRAPPER_AGV_NAME := 'EGO_SBDH_VAR_TRD_ITEM_TYPE_TPV';

  l_views_to_process(4).ITEM_ATTR_GROUP_NAME   := 'EGOINT_GDSN_DEP_VAL_DATE_INFO';
  l_views_to_process(4).ITEM_ATTR_AGV_NAME     := 'EGO_SBDH_DEP_VAL_DATE_INFO_AGV';

  l_views_to_process(5).ITEM_ATTR_GROUP_NAME   := 'EGOINT_GDSN_RETURNS';
  l_views_to_process(5).ITEM_ATTR_AGV_NAME     := 'EGO_SBDH_RETURNS_AGV';

  l_views_to_process(6).ITEM_ATTR_GROUP_NAME   := 'EGOINT_GDSN_BUYING_QTY_INFO';
  l_views_to_process(6).TP_ATTR_GROUP_NAME     := 'EGOINT_GDSN_BUYING_QTY_INFO';
  l_views_to_process(6).ITEM_ATTR_AGV_NAME     := 'EGO_SBDH_BUYING_QTY_INFO_AGV';
  l_views_to_process(6).TP_ATTR_AGV_NAME       := 'EGO_SBDH_BUYING_QTY_INFO_TPAGV';
  l_views_to_process(6).ITEM_AGV_ALIAS         := 'ITEMAGV';
  l_views_to_process(6).TP_AGV_ALIAS           := 'TPAGV';
  l_views_to_process(6).FINAL_WRAPPER_AGV_NAME := 'EGO_SBDH_BUYING_QTY_INFO_TPV';

  l_views_to_process(7).ITEM_ATTR_GROUP_NAME   := 'EGOINT_GDSN_SHIP_EXCL_DATES';
  l_views_to_process(7).TP_ATTR_GROUP_NAME     := 'EGOINT_GDSN_SHIP_EXCL_DATES';
  l_views_to_process(7).ITEM_ATTR_AGV_NAME     := 'EGO_SBDH_SHIP_EXCL_DATES_AGV';
  l_views_to_process(7).TP_ATTR_AGV_NAME       := 'EGO_SBDH_SHIP_EXCL_DATES_TPAGV';
  l_views_to_process(7).ITEM_AGV_ALIAS         := 'ITEMAGV';
  l_views_to_process(7).TP_AGV_ALIAS           := 'TPAGV';
  l_views_to_process(7).FINAL_WRAPPER_AGV_NAME := 'EGO_SBDH_SHIP_EXCL_DATES_TPV';

  l_views_to_process(8).ITEM_ATTR_GROUP_NAME   := 'EGOINT_GDSN_ORDERING_INFO';
  l_views_to_process(8).TP_ATTR_GROUP_NAME     := 'EGOINT_GDSN_ORDERING_INFO';
  l_views_to_process(8).ITEM_ATTR_AGV_NAME     := 'EGO_SBDH_ORDERING_INFO_AGV';
  l_views_to_process(8).TP_ATTR_AGV_NAME       := 'EGO_SBDH_ORDERING_INFO_TPAGV';
  l_views_to_process(8).ITEM_AGV_ALIAS         := 'ITEMAGV';
  l_views_to_process(8).TP_AGV_ALIAS           := 'TPAGV';
  l_views_to_process(8).FINAL_WRAPPER_AGV_NAME := 'EGO_SBDH_ORDERING_INFO_TPV';

  l_views_to_process(9).ITEM_ATTR_GROUP_NAME   := 'EGOINT_GDSN_TRD_ITM_LIFESPAN';
  l_views_to_process(9).TP_ATTR_GROUP_NAME     := 'EGOINT_GDSN_TRD_ITM_LIFESPAN';
  l_views_to_process(9).ITEM_ATTR_AGV_NAME     := 'EGO_SBDH_TRD_ITM_LIFESPAN_AGV';
  l_views_to_process(9).TP_ATTR_AGV_NAME       := 'EGO_SBDH_TRD_ITM_LIFSPAN_TPAGV';
  l_views_to_process(9).ITEM_AGV_ALIAS         := 'ITEMAGV';
  l_views_to_process(9).TP_AGV_ALIAS           := 'TPAGV';
  l_views_to_process(9).FINAL_WRAPPER_AGV_NAME := 'EGO_SBDH_TRD_ITM_LIFESPAN_TPV';


  l_views_to_process(10).ITEM_ATTR_GROUP_NAME   := 'EGOINT_GDSN_PAYMENT_METHOD';
  l_views_to_process(10).TP_ATTR_GROUP_NAME     := 'EGOINT_GDSN_PAYMENT_METHOD';
  l_views_to_process(10).ITEM_ATTR_AGV_NAME     := 'EGO_SBDH_PAYMENT_METHOD_AGV';
  l_views_to_process(10).TP_ATTR_AGV_NAME       := 'EGO_SBDH_PAYMENT_METHOD_TPAGV';
  l_views_to_process(10).ITEM_AGV_ALIAS         := 'ITEMAGV';
  l_views_to_process(10).TP_AGV_ALIAS           := 'TPAGV';
  l_views_to_process(10).FINAL_WRAPPER_AGV_NAME := 'EGO_SBDH_PAYMENT_METHOD_TPV';


  l_views_to_process(11).ITEM_ATTR_GROUP_NAME   := 'EGOINT_GDSN_PRC_CMPRSN_CONTNT';
  l_views_to_process(11).ITEM_ATTR_AGV_NAME     := 'EGO_SBDH_PRC_CMPRSN_CONTNT_AGV';

  l_views_to_process(12).ITEM_ATTR_GROUP_NAME   := 'EGOINT_GDSN_PRC_CMPRSN_MSRMT';
  l_views_to_process(12).ITEM_ATTR_AGV_NAME     := 'EGO_SBDH_PRC_CMPRSN_MSRMT_AGV';

  l_views_to_process(13).ITEM_ATTR_GROUP_NAME   := 'EGOINT_GDSN_STRG_HNDLG_HUMIDTY';
  l_views_to_process(13).ITEM_ATTR_AGV_NAME     := 'EGO_SBDH_STRG_HNDLG_HMDTY_AGV';

  l_views_to_process(14).ITEM_ATTR_GROUP_NAME   := 'EGOINT_GDSN_CLASS_COMPLIANCE';
  l_views_to_process(14).ITEM_ATTR_AGV_NAME     := 'EGO_SBDH_CLASS_COMPLIANCE_AGV';

  l_views_to_process(15).ITEM_ATTR_GROUP_NAME   := 'EGOINT_GDSN_COUNTRY_OF_ASSY';
  l_views_to_process(15).ITEM_ATTR_AGV_NAME     := 'EGO_SBDH_COUNTRY_OF_ASSY_AGV';

  l_views_to_process(16).ITEM_ATTR_GROUP_NAME   := 'EGOINT_GDSN_CAMPAIGN_INFO';
  l_views_to_process(16).ITEM_ATTR_AGV_NAME     := 'EGO_SBDH_CAMPAIGN_INFO_AGV';

  l_views_to_process(17).ITEM_ATTR_GROUP_NAME   := 'EGOINT_GDSN_SPECIAL_ITEM';
  l_views_to_process(17).ITEM_ATTR_AGV_NAME     := 'EGO_SBDH_SPECIAL_ITEM_AGV';


  l_views_to_process(18).ITEM_ATTR_GROUP_NAME   := 'EGOINT_GDSN_ITEM_FEATURE_BNFT';
  l_views_to_process(18).ITEM_ATTR_AGV_NAME     := 'EGO_SBDH_ITEM_FEATURE_BNFT_AGV';

  l_views_to_process(19).ITEM_ATTR_GROUP_NAME   := 'EGOINT_GDSN_MATERIAL_INFO';
  l_views_to_process(19).ITEM_ATTR_AGV_NAME     := 'EGO_SBDH_MATERIAL_INFO_AGV';

  l_views_to_process(20).ITEM_ATTR_GROUP_NAME   := 'EGOINT_GDSN_SIZE_INFO';
  l_views_to_process(20).ITEM_ATTR_AGV_NAME     := 'EGO_SBDH_SIZE_INFO_AGV';

  l_views_to_process(21).ITEM_ATTR_GROUP_NAME   := 'EGOINT_GDSN_SEASON_AVL_DATE';
  l_views_to_process(21).ITEM_ATTR_AGV_NAME     := 'EGO_SBDH_SEASON_AVL_DATE_AGV';

  l_views_to_process(22).ITEM_ATTR_GROUP_NAME   := 'EGOINT_GDSN_SEASON';
  l_views_to_process(22).ITEM_ATTR_AGV_NAME     := 'EGO_SBDH_SEASON_AGV';

  l_views_to_process(23).ITEM_ATTR_GROUP_NAME   := 'EGOINT_GDSN_TARGET_CONSUMER';
  l_views_to_process(23).ITEM_ATTR_AGV_NAME     := 'EGO_SBDH_TARGET_CONSUMER_AGV';


  ----------------------------------------------
  -- Here we loop through the complete table  --
  -- built above for processing each of the   --
  -- attribute groups view                    --
  ----------------------------------------------
  l_views_exist := '';
  l_view_compile_errs := '';
  FOR i in 1 .. l_views_to_process.LAST
  LOOP

    IF( p_attr_group_name IS NULL OR
        (p_attr_group_name IS NOT NULL AND p_attr_group_name = l_views_to_process(i).ITEM_ATTR_GROUP_NAME)
      )
    THEN
        ----------------------------------------
        -- Firstly we need to sync up the     --
        -- metadata for all the tp attr group --
        ----------------------------------------

        l_return_status := NULL;
        l_errorcode := NULL;
        l_msg_count := NULL;
        l_msg_data := NULL;

        IF ( l_views_to_process(i).ITEM_ATTR_GROUP_NAME IS NOT NULL
             AND l_views_to_process(i).TP_ATTR_GROUP_NAME IS NOT NULL) THEN

            EGO_EXT_FWK_PUB.Sync_Up_Attr_Metadata (
                                  p_source_ag_name      => l_views_to_process(i).ITEM_ATTR_GROUP_NAME
                                 ,p_source_ag_type      => 'EGO_ITEMMGMT_GROUP'
                                 ,p_source_appl_id      => 431
                                 ,p_target_ag_name      => l_views_to_process(i).TP_ATTR_GROUP_NAME
                                 ,p_target_ag_type      => 'EGO_ITEM_TP_EXT_ATTRS'
                                 ,p_target_appl_id      => 431
                                 ,x_return_status       => l_return_status
                                 ,x_errorcode           => l_errorcode
                                 ,x_msg_count           => l_msg_count
                                 ,x_msg_data            => l_msg_data
                              );
        END IF;


        l_item_view_failed := FALSE;
        l_multi_row_ag := '';
        --------------------------------
        -- Validating the ITEM AGV NAME
        --------------------------------

        OPEN c_check_agv_name (cp_agv_name        => UPPER(l_views_to_process(i).ITEM_ATTR_AGV_NAME)
                              ,cp_application_id  => 431
                              ,cp_attr_group_type => 'EGO_ITEMMGMT_GROUP'
                              ,cp_attr_group_name => l_views_to_process(i).ITEM_ATTR_GROUP_NAME
                              );
        FETCH c_check_agv_name INTO l_temp_agv_name;

        OPEN c_check_obj_name (cp_agv_name => UPPER(l_views_to_process(i).ITEM_ATTR_AGV_NAME)
                              ,cp_application_id => 431
                              ,cp_attr_group_type => 'EGO_ITEMMGMT_GROUP'
                              ,cp_attr_group_name => l_views_to_process(i).ITEM_ATTR_GROUP_NAME
                              );
        FETCH c_check_obj_name INTO l_temp_agv_name;


        IF c_check_agv_name%FOUND OR c_check_obj_name%FOUND THEN
          l_views_exist := l_views_exist||' '||UPPER(l_views_to_process(i).ITEM_ATTR_AGV_NAME);--RAISE L_ITEM_VNAME_EXISTS;
          l_item_view_failed :=TRUE;
        ELSE
          UPDATE ego_fnd_dsc_flx_ctx_ext
            SET agv_name = UPPER(l_views_to_process(i).ITEM_ATTR_AGV_NAME)
          WHERE application_id                = 431
            AND descriptive_flexfield_name    = 'EGO_ITEMMGMT_GROUP'
            AND descriptive_flex_context_code = l_views_to_process(i).ITEM_ATTR_GROUP_NAME;
        END IF;

        CLOSE c_check_agv_name;
        CLOSE c_check_obj_name;


        --------------------------------
        -- Validating the TP AGV NAME
        --------------------------------
        IF (l_views_to_process(i).TP_ATTR_AGV_NAME IS NOT NULL AND
            l_views_to_process(i).TP_ATTR_GROUP_NAME IS NOT NULL) THEN

            OPEN c_check_agv_name (cp_agv_name        => UPPER(l_views_to_process(i).TP_ATTR_AGV_NAME)
                                  ,cp_application_id  => 431
                                  ,cp_attr_group_type => 'EGO_ITEM_TP_EXT_ATTRS'
                                  ,cp_attr_group_name => l_views_to_process(i).TP_ATTR_GROUP_NAME
                                  );
            FETCH c_check_agv_name INTO l_temp_agv_name;

            OPEN c_check_obj_name (cp_agv_name => UPPER(l_views_to_process(i).TP_ATTR_AGV_NAME)
                                  ,cp_application_id => 431
                                  ,cp_attr_group_type => 'EGO_ITEM_TP_EXT_ATTRS'
                                  ,cp_attr_group_name => l_views_to_process(i).TP_ATTR_GROUP_NAME
                                  );
            FETCH c_check_obj_name INTO l_temp_agv_name;


            IF c_check_agv_name%FOUND OR c_check_obj_name%FOUND THEN
              l_views_exist := l_views_exist||' '||UPPER(l_views_to_process(i).TP_ATTR_AGV_NAME);--RAISE L_TP_VNAME_EXISTS;
              l_tp_view_failed := TRUE;
            ELSE
              UPDATE ego_fnd_dsc_flx_ctx_ext
                SET agv_name = UPPER(l_views_to_process(i).TP_ATTR_AGV_NAME)
              WHERE application_id                = 431
                AND descriptive_flexfield_name    = 'EGO_ITEM_TP_EXT_ATTRS'
                AND descriptive_flex_context_code = l_views_to_process(i).TP_ATTR_GROUP_NAME;
            END IF;

            CLOSE c_check_agv_name;
            CLOSE c_check_obj_name;

        END IF;

        --------------------------------------------------------------
        -- Fetching the attr group id for the item attr group --
        --------------------------------------------------------------
          SELECT ATTR_GROUP_ID, MULTI_ROW
            INTO l_temp_num, l_multi_row_ag
            FROM EGO_FND_DSC_FLX_CTX_EXT
           WHERE DESCRIPTIVE_FLEXFIELD_NAME = 'EGO_ITEMMGMT_GROUP'
             AND APPLICATION_ID = 431
             AND DESCRIPTIVE_FLEX_CONTEXT_CODE = l_views_to_process(i).ITEM_ATTR_GROUP_NAME;

        l_return_status := NULL;
        l_errorcode := NULL;
        l_msg_count := NULL;
        l_msg_data := NULL;

        -------------------------------------------------------------
        -- Here we generate the view for item attribute group      --
        -------------------------------------------------------------
        IF (l_temp_num >0) THEN

            l_ag_id := TO_CHAR(l_temp_num);
            EGO_EXT_FWK_PUB.Compile_Attr_Group_Views(
                                            ERRBUF                          => l_msg_data
                                           ,RETCODE                         => l_return_status
                                           ,p_attr_group_id_list            => l_ag_id
                                           ,p_init_msg_list                 => fnd_api.g_FALSE
                                           ,p_commit                        => fnd_api.g_TRUE
                                            );

        END IF;

        IF (l_return_status <> 'S') THEN
          l_view_compile_errs := l_view_compile_errs||' ,Error while creating view for :'||l_views_to_process(i).ITEM_ATTR_GROUP_NAME||
                                                      '('||l_msg_data||')';
          l_item_view_failed := TRUE;
        END IF;




        -----------------------------------------------
        -- Processing the TPAGV and the wrapper VIEW --
        -----------------------------------------------

        IF (l_views_to_process(i).TP_ATTR_AGV_NAME IS NOT NULL AND
            l_views_to_process(i).TP_ATTR_GROUP_NAME IS NOT NULL) THEN

            ----------------------------------------------------------------------
            -- Fetching the attr group id for the corresponding tp attr group   --
            ----------------------------------------------------------------------
            BEGIN
              SELECT ATTR_GROUP_ID
                INTO l_temp_num
                FROM EGO_FND_DSC_FLX_CTX_EXT
               WHERE DESCRIPTIVE_FLEXFIELD_NAME = 'EGO_ITEM_TP_EXT_ATTRS'
                 AND APPLICATION_ID = 431
                 AND DESCRIPTIVE_FLEX_CONTEXT_CODE = l_views_to_process(i).TP_ATTR_GROUP_NAME;

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
               l_temp_num := -1;
            END;

            -------------------------------------------------------------
            -- Here we generate the view for the corresponding trading --
            -- partner attr grp                                        --
            -------------------------------------------------------------
            IF (l_temp_num >0) THEN
                EGO_EXT_FWK_PUB.Compile_Attr_Group_Views(
                                                ERRBUF                          => l_msg_data
                                               ,RETCODE                         => l_return_status
                                               ,p_attr_group_id_list            => TO_CHAR(l_temp_num)
                                               ,p_init_msg_list                 => fnd_api.g_FALSE
                                               ,p_commit                        => fnd_api.g_TRUE
                                                );
            END IF;

            IF (l_return_status <> 'S') THEN
              l_view_compile_errs := l_view_compile_errs||' ,Error while creating view for :'||l_views_to_process(i).TP_ATTR_GROUP_NAME||
                                                          '('||l_msg_data||') ';
              l_tp_view_failed := TRUE;
            END IF;

            -------------------------------------------------------------
            -- Generating the wrapper view over the tp and item attr   --
            -- attr group views.                                       --
            -------------------------------------------------------------

            IF (l_views_to_process(i).FINAL_WRAPPER_AGV_NAME IS NOT NULL )THEN

                IF (l_item_view_failed OR l_tp_view_failed) THEN
                  l_view_compile_errs := l_view_compile_errs||' ,Could not create the view '||l_views_to_process(i).FINAL_WRAPPER_AGV_NAME||
                                                              ' since the base view creation failed :';
                ELSE
                  EGO_Item_PVT.GENERATE_GTIN_TP_ATTRS_VIEW (
                                                p_item_attr_agv_name   => UPPER(l_views_to_process(i).ITEM_ATTR_AGV_NAME)
                                               ,p_tp_agv_name          => UPPER(l_views_to_process(i).TP_ATTR_AGV_NAME)
                                               ,p_item_attr_agv_alias  => l_views_to_process(i).ITEM_AGV_ALIAS
                                               ,p_tp_agv_alias         => l_views_to_process(i).TP_AGV_ALIAS
                                               ,p_final_agv_name       => l_views_to_process(i).FINAL_WRAPPER_AGV_NAME
                                               ,p_multi_row_ag         => l_multi_row_ag
                                               ,x_return_status        => l_return_status
                                               ,x_msg_data             => l_msg_data
                                              );
                END IF;


                IF (l_return_status <> 'S') THEN
                  l_view_compile_errs := l_view_compile_errs||' ,Error while creating view :'||l_views_to_process(i).FINAL_WRAPPER_AGV_NAME||
                                                              '('||l_msg_data||') ';
                END IF;

            END IF;

        END IF;
    END IF;--
  END LOOP;

  IF (LENGTH(l_view_compile_errs)>1 OR LENGTH(l_views_exist)>1) THEN
   RAISE ERR_OCCURED;
  END IF;

  ERRBUF  := '';
  RETCODE := FND_API.G_RET_STS_SUCCESS;


EXCEPTION
 WHEN ERR_OCCURED THEN

  IF(LENGTH(l_views_exist)>1) THEN
     l_views_exist := 'Could not create the following views as already an object exists by this name - '||l_views_exist;
  END IF;

  ERRBUF  := l_views_exist||'  '||l_view_compile_errs;
  RETCODE := FND_API.G_RET_STS_ERROR;

  RAISE_APPLICATION_ERROR(-20000, l_views_exist||'  '||l_view_compile_errs);

END Generate_GDSN_Ext_AG_TP_Views;












PROCEDURE GENERATE_GTIN_TP_ATTRS_VIEW  (
                                         p_item_attr_agv_name      IN    VARCHAR2
                                        ,p_tp_agv_name             IN    VARCHAR2
                                        ,p_item_attr_agv_alias     IN    VARCHAR2
                                        ,p_tp_agv_alias            IN    VARCHAR2
                                        ,p_final_agv_name          IN    VARCHAR2
                                        ,p_multi_row_ag            IN    VARCHAR2  -- 'Y' or 'N'
                                        ,x_return_status           OUT NOCOPY VARCHAR2
                                        ,x_msg_data                OUT NOCOPY VARCHAR2
                                       )
IS

    TYPE LOCAL_VIEW_COLUMN_RECORD IS RECORD
         (
            VIEW_NAME       VARCHAR2(30)
           ,COLUMN_NAME     VARCHAR2(30)
         );

    TYPE VIEW_COLUMNS_TABLE IS TABLE OF LOCAL_VIEW_COLUMN_RECORD
    INDEX BY BINARY_INTEGER;

    l_item_agv_cols_tab       VIEW_COLUMNS_TABLE;
    l_tp_agv_cols_tab              VIEW_COLUMNS_TABLE;

    l_dynamic_sql                    VARCHAR2(2000);
    l_no_of_item_agv_cols            NUMBER;
    l_no_of_tp_agv_cols              NUMBER;
    l_item_agv_col_list                VARCHAR2(10000);
    l_final_view_query               VARCHAR2(10000);
    l_final_view_col_list            VARCHAR2(10000);
    l_final_view_sql                 VARCHAR2(20000);
    l_item_agv_alias            VARCHAR2(30);
    l_tp_agv_alias                   VARCHAR2(30);
    l_current_col_name               VARCHAR2(30);
    l_item_cur_col                     VARCHAR2(30);

BEGIN

    IF(p_item_attr_agv_alias IS NULL ) THEN
      l_item_agv_alias := p_item_attr_agv_name;
    ELSE
      l_item_agv_alias := p_item_attr_agv_alias;
    END IF;

    IF(p_tp_agv_alias IS NULL ) THEN
      l_tp_agv_alias := p_tp_agv_name;
    ELSE
      l_tp_agv_alias := p_tp_agv_alias;
    END IF;

    ---------------------------------------------------
    -- Fetching the column names of primary and the  --
    -- secondry view                                 --
    ---------------------------------------------------

    l_dynamic_sql := ' SELECT TABLE_NAME, COLUMN_NAME   '||
                     '   FROM SYS.ALL_TAB_COLUMNS           '||
                     '  WHERE TABLE_NAME = :1           ';

    EXECUTE IMMEDIATE l_dynamic_sql
    BULK COLLECT INTO l_item_agv_cols_tab
    USING p_item_attr_agv_name;

    EXECUTE IMMEDIATE l_dynamic_sql
    BULK COLLECT INTO l_tp_agv_cols_tab
    USING p_tp_agv_name;

    l_no_of_item_agv_cols := l_item_agv_cols_tab.COUNT;
    l_no_of_tp_agv_cols := l_tp_agv_cols_tab.COUNT;

    --------------------------------------------------------
    -- Building the concatenated list of sec view columns --
    --------------------------------------------------------

    l_item_agv_col_list := ' ';
    FOR i IN 1 .. l_no_of_item_agv_cols
    LOOP
      l_item_agv_col_list := l_item_agv_col_list || l_item_agv_cols_tab(i).COLUMN_NAME;
    END LOOP;


    ---------------------------------------------------
    -- Building the VIEW SQL                         --
    ---------------------------------------------------

    l_final_view_query := ' SELECT  ';
    l_final_view_col_list := ' ';

    FOR i IN 1 .. l_no_of_tp_agv_cols
    LOOP

      l_current_col_name := l_tp_agv_cols_tab(i).COLUMN_NAME;
      l_final_view_col_list := l_final_view_col_list||' '||l_current_col_name;

      IF (l_current_col_name = 'MASTER_ORGANIZATION_ID') THEN
        l_item_cur_col := 'ORGANIZATION_ID';
      ELSE
        l_item_cur_col := l_current_col_name;
      END IF;

      IF (INSTR(l_item_agv_col_list,l_item_cur_col) > 0) THEN
        l_final_view_query := l_final_view_query||' NVL('||l_tp_agv_alias||'.'||l_current_col_name||
                                                        ' , '||l_item_agv_alias||'.'||l_item_cur_col||
                                                        ' ) '|| l_current_col_name;
      ELSE
        l_final_view_query := l_final_view_query||' '||l_tp_agv_alias||'.'||l_current_col_name||
                                                  ' '||l_current_col_name;
      END IF;

      IF (i <> l_no_of_item_agv_cols) THEN
         -- commented following two lines to fix bug 6910417
         --l_final_view_query := l_final_view_query||' , ';
         --l_final_view_col_list := l_final_view_col_list||' , ';

         -- added following IF..ELSE..END IF to fix bug 6910417
         IF (i = l_no_of_tp_agv_cols) THEN
             l_final_view_query := l_final_view_query;
         l_final_view_col_list := l_final_view_col_list;
     ELSE
                 l_final_view_query := l_final_view_query||' , ';
         l_final_view_col_list := l_final_view_col_list||' , ';
     END IF;

      END IF;

    END LOOP;

    IF (p_multi_row_ag = 'Y') THEN

      l_final_view_sql:= ' CREATE OR REPLACE VIEW '||p_final_agv_name||' ( '||l_final_view_col_list||') '||
                         ' AS SELECT '||l_final_view_col_list||
                         '      FROM '||p_tp_agv_name||
                         '  UNION ALL '||
                         ' SELECT '||l_final_view_col_list||
                         '   FROM (SELECT NULL PARTY_SITE_ID, '||l_item_agv_alias||'.* , '||
                         '                '||l_item_agv_alias||'.ORGANIZATION_ID MASTER_ORGANIZATION_ID '||
                         '           FROM '||p_item_attr_agv_name||'  '||l_item_agv_alias||
                         '         ) ';


    ELSE

      l_final_view_sql := ' CREATE OR REPLACE VIEW '||p_final_agv_name||' ( '||l_final_view_col_list||') '||
                          ' AS '||l_final_view_query||
                          ' FROM '||p_item_attr_agv_name||' '||l_item_agv_alias||
                          ' , '||p_tp_agv_name||' '||l_tp_agv_alias||
                          ' WHERE '||l_item_agv_alias||'.INVENTORY_ITEM_ID = '||l_tp_agv_alias||'.INVENTORY_ITEM_ID(+) '||
                          '   AND '||l_item_agv_alias||'.ORGANIZATION_ID = '||l_tp_agv_alias||'.MASTER_ORGANIZATION_ID(+) '||
                          ' UNION ALL '||
                          ' SELECT '||l_final_view_col_list||
                          ' FROM '||p_tp_agv_name||' '||l_tp_agv_alias||
                          ' WHERE NOT EXISTS ( SELECT ''X'' '||
                          '                      FROM '||p_item_attr_agv_name||' '||l_item_agv_alias||
                          '                     WHERE INVENTORY_ITEM_ID = '||l_tp_agv_alias||'.INVENTORY_ITEM_ID '||
                          '                       AND ORGANIZATION_ID = '||l_tp_agv_alias||'.MASTER_ORGANIZATION_ID ) '||
                          '  UNION ALL '||
                          ' SELECT '||l_final_view_col_list||
                          '   FROM (SELECT NULL PARTY_SITE_ID, '||l_item_agv_alias||'.* , '||
                          '                '||l_item_agv_alias||'.ORGANIZATION_ID MASTER_ORGANIZATION_ID '||
                          '           FROM '||p_item_attr_agv_name||'  '||l_item_agv_alias||
                          '          WHERE EXISTS ( SELECT ''X'' '||
                          '                               FROM '||p_tp_agv_name||' '||l_tp_agv_alias||
                          '                              WHERE INVENTORY_ITEM_ID = '||l_item_agv_alias||'.INVENTORY_ITEM_ID '||
                          '                                AND MASTER_ORGANIZATION_ID = '||l_item_agv_alias||'.ORGANIZATION_ID '||
                          '                            ) '||
                          '        ) ';



    END IF;


    EXECUTE IMMEDIATE l_final_view_sql;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
 WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data := SQLERRM;

END  GENERATE_GTIN_TP_ATTRS_VIEW;

PROCEDURE  process_attribute_defaulting(p_item_attr_def_tab   IN OUT NOCOPY SYSTEM.EGO_ITEM_ATTR_DEFAULT_TABLE
                                       ,p_gdsn_enabled        IN         VARCHAR2
                                       ,p_commit              IN         VARCHAR2
                                       ,x_return_status       OUT NOCOPY VARCHAR2
                                       ,x_msg_data            OUT NOCOPY VARCHAR2
                                       ,x_msg_count           OUT NOCOPY  NUMBER)

IS

l_error_code VARCHAR2(2000);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
l_failed_row_id_list  VARCHAR2(2000);

l_pk_column_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
l_class_code_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
l_data_level_values EGO_COL_NAME_VALUE_PAIR_ARRAY;
l_inventory_item_id  NUMBER;
l_organization_id NUMBER;
l_revision_id NUMBER;
l_object_name VARCHAR2(10);
l_application_id NUMBER;
l_catalog_group_id NUMBER;
l_additional_class_Code_list VARCHAR2(32000);
l_attribute_group_type VARCHAR2(20);
l_record_first NUMBER;
l_record_last  NUMBER;
l_return_status VARCHAR2(10);
l_commit VARCHAR2(2);
l_attr_groups_to_exclude VARCHAR2(2000);

CURSOR attr_default_recs IS
     SELECT A.ORGANIZATION_ID          ORGANIZATION_ID
           ,A.INVENTORY_ITEM_ID        INVENTORY_ITEM_ID
           ,A.REVISION_ID              REVISION_ID
           ,A.APPLICATION_ID           APPLICATION_ID
           ,A.ITEM_CATALOG_GROUP_ID    ITEM_CATALOG_GROUP_ID
           ,A.OBJECT_NAME              OBJECT_NAME
           ,A.ATTRIBUTE_GROUP_TYPE     ATTRIBUTE_GROUP_TYPE
     FROM THE (SELECT CAST(p_item_attr_def_tab AS "SYSTEM".EGO_ITEM_ATTR_DEFAULT_TABLE)
                FROM dual) A
     ORDER BY INVENTORY_ITEM_ID;

   BEGIN
      x_return_status := l_return_status;
      x_msg_count     := 0;

      l_record_first := p_item_attr_def_tab.FIRST;
      l_record_last  := p_item_attr_def_tab.LAST;
      FOR attr_default_rec IN attr_default_recs LOOP
        l_inventory_item_id  := attr_default_rec.INVENTORY_ITEM_ID;
        l_organization_id := attr_default_rec.ORGANIZATION_ID;
        l_revision_id := attr_default_rec.REVISION_ID;
        l_object_name := attr_default_rec.OBJECT_NAME;
        l_application_id := attr_default_rec.APPLICATION_ID;
        l_catalog_group_id := attr_default_rec.ITEM_CATALOG_GROUP_ID;
        l_attribute_group_type := attr_default_rec.ATTRIBUTE_GROUP_TYPE;
        l_commit := p_commit;
        l_pk_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY
          ( EGO_COL_NAME_VALUE_PAIR_OBJ('INVENTORY_ITEM_ID', TO_CHAR(attr_default_rec.INVENTORY_ITEM_ID))
          , EGO_COL_NAME_VALUE_PAIR_OBJ('ORGANIZATION_ID', TO_CHAR(attr_default_rec.ORGANIZATION_ID)));

        l_class_code_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY
          (EGO_COL_NAME_VALUE_PAIR_OBJ('ITEM_CATALOG_GROUP_ID', to_char(attr_default_rec.ITEM_CATALOG_GROUP_ID)));

        l_data_level_values := EGO_COL_NAME_VALUE_PAIR_ARRAY
          (EGO_COL_NAME_VALUE_PAIR_OBJ('REVISION_ID', to_char(attr_default_rec.REVISION_ID)));

        Get_Related_Class_Codes ( p_classification_code      => l_catalog_group_id,
                                 x_related_class_codes_list => l_additional_class_Code_list);
        IF l_additional_class_Code_list IS NULL  THEN
           l_additional_class_Code_list := '-1';
         ELSE
           l_additional_class_Code_list := l_additional_class_Code_list|| ','||l_catalog_group_id||',-1';
        END IF;
        IF p_gdsn_enabled = 'N' THEN

           l_attr_groups_to_exclude := 'SELECT ATTR_GROUP_ID  FROM '||
                                 ' EGO_FND_DSC_FLX_CTX_EXT WHERE DESCRIPTIVE_FLEX_CONTEXT_CODE ' ||
               ' LIKE ''EGOINT_GDSN%'' AND APPLICATION_ID = 431 ' ||
               ' AND DESCRIPTIVE_FLEXFIELD_NAME = ''EGO_ITEMMGMT_GROUP'' ' ;
        END IF;
        EGO_USER_ATTRS_DATA_PVT.Apply_Default_Vals_For_Entity
                   ( p_object_name                   => l_object_name
                    ,p_application_id                => l_application_id
                    ,p_attr_group_type               => l_attribute_group_type
                    ,p_attr_groups_to_exclude        => l_attr_groups_to_exclude
                    ,p_pk_column_name_value_pairs    => l_pk_column_name_value_pairs
                    ,p_class_code_name_value_pairs   => l_class_code_name_value_pairs
                    ,p_data_level_values             => l_data_level_values
                    ,p_additional_class_Code_list    => l_additional_class_Code_list
                    ,p_init_error_handler            => 'T'
                    ,p_init_fnd_msg_list             => 'T'
                    ,p_log_errors                    => 'T'
                    ,p_add_errors_to_fnd_stack       => 'T'
                    ,P_commit                        => l_commit
                    ,x_failed_row_id_list            => l_failed_row_id_list
                    ,x_return_status                 => l_return_status
                    ,x_errorcode                     => l_error_code
                    ,x_msg_count                     => l_msg_count
                    ,x_msg_data                      => l_msg_data
                   );
        x_return_status := l_return_status ;
      END LOOP;
 EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data := SQLERRM;

END process_attribute_defaulting;

END EGO_ITEM_PVT;

/
