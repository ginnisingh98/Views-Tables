--------------------------------------------------------
--  DDL for Package Body INV_ITEM_REVISION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_ITEM_REVISION_PUB" AS
/* $Header: INVPREVB.pls 120.7.12010000.7 2010/02/23 09:56:12 qyou ship $ */

--  ============================================================================
--  Package global variables and cursors
--  ============================================================================

G_PKG_NAME     CONSTANT  VARCHAR2(30)  :=  'INV_ITEM_REVISION_PUB';
G_FILE_NAME    CONSTANT  VARCHAR2(12)  :=  'INVPREVB.pls';

G_USER_ID       NUMBER  :=  FND_GLOBAL.User_Id;
G_LOGIN_ID      NUMBER  :=  FND_GLOBAL.Conc_Login_Id;

G_Miss_Char     VARCHAR2(1)  :=  fnd_api.G_MISS_CHAR;
G_Miss_Num      NUMBER       :=  fnd_api.G_MISS_NUM;
G_Miss_Date     DATE         :=  fnd_api.G_MISS_DATE;

G_Language_Code         VARCHAR2(4);
G_Revision_Id           NUMBER;
G_Object_Version_Number NUMBER;

G_Message_API           VARCHAR2(3) := 'FND';

--
-- Capture the sysdate at once for the whole process. During the process we use
-- sysdate in many places for compare, insert and update. It is essential that
-- we deal with the same sysdate value since the revisions are time sensitive
-- upto seconds. Date will be assigned in the entry procedure.
--
G_Sysdate               DATE;

   CURSOR org_item_exists_cur
   (  p_inventory_item_id    NUMBER
   ,  p_organization_id      NUMBER
   ) IS
      SELECT 'x'
      FROM  mtl_system_items_b
      WHERE
              inventory_item_id = p_inventory_item_id
         AND  organization_id   = p_organization_id;

   CURSOR Item_Revision_Exists_cur
   (  p_inventory_item_id    NUMBER
   ,  p_organization_id      NUMBER
   ,  p_revision             VARCHAR2
   ) IS
      SELECT  object_version_number
      FROM  mtl_item_revisions_b
      WHERE
              inventory_item_id = p_inventory_item_id
         AND  organization_id   = p_organization_id
         AND  revision          = p_revision;

   /*Changes for bug 8679971*/
    CURSOR Item_Revision_Lower_cur
     (  p_inventory_item_id    NUMBER
     ,  p_organization_id      NUMBER
     ,  p_revision            VARCHAR2
     ) IS
                  SELECT ascii(p_revision) - ascii(Max(revision))
                  FROM mtl_item_revisions_b
                  WHERE inventory_item_id=p_inventory_item_id
                  AND organization_id=p_organization_id;
   /*End of comment*/

   --3655522 begin
   CURSOR Upd_Item_Rev_Exists_cur
   (  p_inventory_item_id    NUMBER
   ,  p_organization_id      NUMBER
   ,  p_revision             VARCHAR2
   ,  p_revision_id          NUMBER
   ) IS
      SELECT  object_version_number
      FROM  mtl_item_revisions_b
      WHERE
              inventory_item_id = p_inventory_item_id
         AND  organization_id   = p_organization_id
         AND  revision          = p_revision
         AND  revision_id       <> p_revision_id;
   --3655522 end

   CURSOR Item_Revision_Id_Exists_cur
   (  p_inventory_item_id    NUMBER
   ,  p_organization_id      NUMBER
   ,  p_revision_id          NUMBER
   ) IS
      SELECT  object_version_number
      FROM  mtl_item_revisions_b
      WHERE
              inventory_item_id = p_inventory_item_id
         AND  organization_id   = p_organization_id
         AND  revision_id       = p_revision_id;

   /* Current phase id will be obtained from
      INV_EGO_REVISION_VALIDATE.Get_Initial_Lifecycle_Phase API */

   /*
   CURSOR ItemRev_CurrentPhase_cur
   (  p_lifecycle_id        NUMBER
   ) IS
    SELECT pe.proj_element_id lifecycle_phase_id
    FROM pa_proj_elements pe,
         pa_proj_element_versions pevl,
         pa_proj_element_versions pevlp
    WHERE pevl.object_type = 'PA_STRUCTURES' AND
          pevl.project_id = 0 AND
          pevl.proj_element_id = p_lifecycle_id AND
          pevlp.object_type = 'PA_TASKS' AND
          pevlp.project_id = 0 AND
          pevlp.parent_structure_version_id = pevl.element_version_id AND
          pevlp.proj_element_id = pe.proj_element_id AND
          pevlp.project_id = pe.project_id
    ORDER BY pevlp.display_sequence;
    */

--  ============================================================================
--  API Name:           Add_Message
--  ============================================================================

PROCEDURE Add_Message
(
  p_application_short_name      IN VARCHAR2 := NULL
  , p_message_name              IN VARCHAR2 := NULL
  , p_message_text              IN VARCHAR2 := NULL
  , p_api_name                  IN VARCHAR2 := NULL
)
IS
BEGIN

  IF G_Message_API = 'BOM' THEN
    IF p_message_text IS NULL THEN
      Error_Handler.Add_Error_Message
        (  p_message_name       => p_message_name
         , p_application_id     => p_application_short_name
         , p_token_tbl          => Error_Handler.G_MISS_TOKEN_TBL
         , p_message_type      =>  'E'
         , p_row_identifier    =>  NULL
         , p_entity_id         =>  NULL
         , p_entity_index      =>  NULL
         , p_table_name        =>  NULL
         , p_entity_code       =>  'INV_ITEM_REVISION'
      );
    ELSE
      Error_Handler.Add_Error_Message
        (  p_message_text      =>  p_message_text
         , p_message_type      =>  'E'
         , p_row_identifier    =>  NULL
         , p_entity_id         =>  NULL
         , p_entity_index      =>  NULL
         , p_table_name        =>  NULL
         , p_entity_code       =>  'INV_ITEM_REVISION'
      );
    END IF;

  ELSE

    /* If messaging API is FND */

    IF p_message_text IS NULL THEN
      FND_MESSAGE.Set_Name (p_application_short_name, p_message_name);
      FND_MSG_PUB.Add;
    ELSE
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
         FND_MSG_PUB.Add_Exc_Msg
         (  p_pkg_name         =>  G_PKG_NAME
         ,  p_procedure_name   =>  p_api_name
         ,  p_error_text       =>  p_message_text
         );
      END IF;
    END IF;

  END IF;

END;



--  ============================================================================
--  API Name:           Write_Debug_Message
--  ============================================================================

PROCEDURE Write_Debug_Message
(
  p_debug_message  IN VARCHAR2
)
IS

BEGIN

  IF Error_Handler.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug (p_debug_message);
  END IF;

END;

--  ============================================================================
--  API Name:           Validate_Effectivity_Date
--  ============================================================================

PROCEDURE Validate_Effectivity_Date
(
   p_Item_Revision_rec          IN   Item_Revision_rec_type
,  x_return_status              OUT  NOCOPY VARCHAR2
)
IS
   l_api_name        CONSTANT  VARCHAR2(30)  :=  'Validate_Effectivity_Date';

   CURSOR Item_Revs_cur
   IS
      SELECT revision, effectivity_date
      FROM mtl_item_revisions_b
      WHERE
             inventory_item_id = p_Item_Revision_rec.inventory_item_id
         AND organization_id   = p_Item_Revision_rec.organization_id
         AND revision_id      <> NVL(p_Item_Revision_rec.revision_id,-999999) --3655522 , 7248982:API taking same effectivity date
      ORDER BY
         revision, effectivity_date;

   v_revision           mtl_item_revisions_b.revision%TYPE;
   v_effectivity_date   mtl_item_revisions_b.effectivity_date%TYPE;

   v_count            NUMBER;
   rev_place_found    BOOLEAN;

BEGIN

   -- Initialize API return status to success
   x_return_status := FND_API.g_RET_STS_SUCCESS;

   IF ( p_Item_Revision_rec.effectivity_date = FND_API.g_MISS_DATE ) THEN
      RETURN;
   END IF;

   v_count := 0;
   rev_place_found := FALSE;

   -- ----------------------------------------------------------------------------------
   -- Loop through existing revisions to locate a place of the revision being validated
   -- ----------------------------------------------------------------------------------

   FOR item_rev_rec IN Item_Revs_cur LOOP

   -- Skip the revision being validated, so that validation algorithm
   -- remains the same in case of create or update.

   IF ( item_rev_rec.revision <> p_Item_Revision_rec.revision ) THEN

      v_count := v_count + 1;

      -- See if the revision's place within the existing revisions order has been found
      --2880802: Use lpad space while comparing revision code.
      --To avoid cases like '9'>'10' which returns true

/* Reverting the fix done for bug 2880802 for bug3430431
  This is casuing problems while entering revisions like 'M' after
starting revision '00'
*/
      rev_place_found := item_rev_rec.revision > p_Item_Revision_rec.revision;

      IF ( rev_place_found ) THEN

         --IF ( item_rev_rec%ROWCOUNT > 1 ) THEN
         IF ( v_count > 1 ) THEN

            -- -----------------------------------------------------------------------------------------
            -- Effectivity Date must be between effectivity dates of the previous and the next revision
            -- -----------------------------------------------------------------------------------------

            IF NOT (     ( p_Item_Revision_rec.effectivity_date > v_effectivity_date )
                     AND ( p_Item_Revision_rec.effectivity_date < item_rev_rec.effectivity_date )
                   )
            THEN
               -- inv_UTILITY_PVT.debug_message(' BAD DATE...... ');

               x_return_status := FND_API.g_RET_STS_ERROR;
               Add_Message ('INV', 'INV_ITM_REV_OUT_EFF_DATE');

            END IF;

         ELSE  -- v_count = 1

            -- -----------------------------------------------------
            -- Effectivity Date must be less than the next revision
            -- -----------------------------------------------------

            IF ( p_Item_Revision_rec.effectivity_date > item_rev_rec.effectivity_date )
            THEN
               x_return_status := FND_API.g_RET_STS_ERROR;
               Add_Message ('INV', 'INV_ITM_REV_OUT_EFF_DATE');
            END IF;

         END IF;  -- v_count > 1

         -- Exit the Item_Revs_cur loop because revision place has been found

         EXIT;

      END IF;  -- rev_place_found

      -- Save record data for the next cycle

      v_revision         := item_rev_rec.revision;
      v_effectivity_date := item_rev_rec.effectivity_date;

   END IF;  -- skip the revision being validated

   END LOOP;  -- Item_Revs_cur

   -- If the revision place has not been found, and there are other revisions,
   -- validate against the greatest revision.

   IF ( ( NOT rev_place_found ) AND ( v_count > 0 ) ) THEN

      --2880802: Use lpad space while comparing revision code.
      --To avoid cases like '9'>'10' which returns true
/* Reverting the fix done for bug 2880802 for bug3430431
  This is casuing problems while entering revisions like 'M' after
starting revision '00'
*/

      IF p_Item_Revision_rec.revision > v_revision THEN

         -- Effectivity Date must be past the date of the greatest revision

         IF ( p_Item_Revision_rec.effectivity_date <= v_effectivity_date ) THEN
            x_return_status := FND_API.g_RET_STS_ERROR;
            Add_Message ('INV', 'INV_ITM_REV_OUT_EFF_DATE');
         END IF;

      ELSE
         x_return_status := FND_API.g_RET_STS_UNEXP_ERROR;
         Add_Message ('INV', 'INV_ITM_INVALID_REVISION_CODE');
      END IF;

   END IF;  -- NOT rev_place_found AND v_count > 0

EXCEPTION

  WHEN others THEN

     IF ( Item_Revs_cur%ISOPEN ) THEN
        CLOSE Item_Revs_cur;
     END IF;

     x_return_status := FND_API.g_RET_STS_UNEXP_ERROR;

     Add_Message
         ( p_api_name           =>  l_api_name
           , p_message_text       =>  'UNEXP_ERROR : ' || SQLERRM
         );


END Validate_Effectivity_Date;

--Added for 5208102
PROCEDURE Insert_Revision_UserAttr(p_organization_id   IN NUMBER
                                  ,p_inventory_item_id IN NUMBER
                                  ,p_revision_id       IN NUMBER
                                  ,p_transaction_type  IN VARCHAR2
                                  ,p_template_id       IN NUMBER) IS

   CURSOR c_get_item_catalog(cp_inventory_item_id NUMBER
                            ,cp_organization_id   NUMBER) IS
      SELECT item_catalog_group_id
      FROM   mtl_system_items_b
      WHERE organization_id    = cp_organization_id
      AND    inventory_item_id = cp_inventory_item_id;

   CURSOR c_parent_catalogs(cp_catalog_group_id NUMBER) IS
      SELECT item_catalog_group_id
            ,parent_catalog_group_id
      FROM   mtl_item_catalog_groups_b
      CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
      START WITH item_catalog_group_id         = cp_catalog_group_id;

   l_catalog_group_id            mtl_system_items_b.item_catalog_group_id%TYPE;
   l_parent_catalog              VARCHAR2(150):= NULL;
   l_pk_column_name_value_pairs  EGO_COL_NAME_VALUE_PAIR_ARRAY;
   l_class_code_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
   l_data_level_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
   l_msg_count                   NUMBER;
   l_error_code                  NUMBER;
   l_msg_data                    VARCHAR2(2000);
   l_return_status               VARCHAR2(1);
BEGIN
   OPEN  c_get_item_catalog(cp_inventory_item_id => p_inventory_item_id
                           ,cp_organization_id   => p_organization_id);
   FETCH c_get_item_catalog INTO l_catalog_group_id;
   CLOSE c_get_item_catalog;

   IF l_catalog_group_id IS NOT NULL THEN
      l_parent_catalog := NULL;
      BEGIN
         FOR parent_cur IN c_parent_catalogs(l_catalog_group_id) LOOP
            IF parent_cur.parent_catalog_group_id IS NOT NULL THEN
               IF l_parent_catalog IS NULL THEN
                  l_parent_catalog := parent_cur.parent_catalog_group_id;
               ELSE
                  l_parent_catalog := l_parent_catalog||','||parent_cur.parent_catalog_group_id;
               END IF;
            END IF;
         END LOOP;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         l_pk_column_name_value_pairs  := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                          EGO_COL_NAME_VALUE_PAIR_OBJ('INVENTORY_ITEM_ID',p_inventory_item_id)
                                         ,EGO_COL_NAME_VALUE_PAIR_OBJ('ORGANIZATION_ID'  ,p_organization_id));
         l_class_code_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                          EGO_COL_NAME_VALUE_PAIR_OBJ('ITEM_CATALOG_GROUP_ID'    ,l_catalog_group_id)
                                         ,EGO_COL_NAME_VALUE_PAIR_OBJ('RELATED_CLASS_CODE_LIST_1',l_parent_catalog));
         l_data_level_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                          EGO_COL_NAME_VALUE_PAIR_OBJ('REVISION_ID', p_revision_id));
         EGO_ITEM_PUB.Apply_Templ_User_Attrs_To_Item
             (p_api_version                   => 1.0
             ,p_mode                          => p_transaction_type
             ,p_item_id                       => p_inventory_item_id
             ,p_organization_id               => p_organization_id
             ,p_template_id                   => p_template_id
             ,p_object_name                   => 'EGO_ITEM'
             ,p_class_code_name_value_pairs   => l_class_code_name_value_pairs
             ,p_data_level_name_value_pairs   => l_data_level_name_value_pairs
             ,x_return_status                 => l_return_status
             ,x_errorcode                     => l_error_code
             ,x_msg_count                     => l_msg_count
             ,x_msg_data                      => l_msg_data);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      NULL;
END Insert_Revision_UserAttr;

--Added for bug 5435229
Procedure copy_rev_UDA(p_organization_id   IN NUMBER
                      ,p_inventory_item_id IN NUMBER
                      ,p_revision_id       IN NUMBER
                      ,p_revision           IN VARCHAR2
                      ,p_source_revision_id IN NUMBER   DEFAULT NULL) IS

  CURSOR c_get_effective_revision(cp_inventory_item_id NUMBER
                                 ,cp_organization_id   NUMBER
                                 ,cp_revision          VARCHAR2) IS
    SELECT  revision_id
      FROM  mtl_item_revisions_b
     WHERE  inventory_item_id = cp_inventory_item_id
       AND  organization_id   = cp_organization_id
       AND  revision          < cp_revision
       AND  implementation_date IS NOT NULL
       AND  effectivity_date  <= sysdate
     ORDER  BY effectivity_date desc;

  CURSOR c_is_source_revision_valid(cp_inventory_item_id  NUMBER
                                   ,cp_organization_id    NUMBER
                                   ,cp_source_revision_id NUMBER) IS
    SELECT  revision_id
      FROM  mtl_item_revisions_b
     WHERE  inventory_item_id = cp_inventory_item_id
       AND  organization_id   = cp_organization_id
       AND  revision_id       = cp_source_revision_id;

  l_source_revision_id      mtl_item_revisions_b.revision_id%TYPE;
  l_return_status           VARCHAR2(100);
  l_error_code              NUMBER;
  l_msg_count               NUMBER  ;
  l_msg_data                VARCHAR2(100);
  l_pk_item_pairs           EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_pk_item_rev_pairs_src   EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_pk_item_rev_pairs_dst   EGO_COL_NAME_VALUE_PAIR_ARRAY;

BEGIN
  IF p_source_revision_id IS NULL THEN
    -- API User has not passed in any Source Revision Id.
    -- So get the current effective revision.

    OPEN  c_get_effective_revision(cp_inventory_item_id => p_inventory_item_id
                                  ,cp_organization_id   => p_organization_id
                                  ,cp_revision          => p_revision);
    FETCH c_get_effective_revision INTO l_source_revision_id;
    CLOSE c_get_effective_revision;

  ELSE --p_source_revision_id IS NULL
    -- API User has passed in a Source Revision Id.
    -- Check if it is valid for the current item.

    OPEN  c_is_source_revision_valid(cp_inventory_item_id  => p_inventory_item_id
                                    ,cp_organization_id    => p_organization_id
                                    ,cp_source_revision_id => p_source_revision_id);
    FETCH c_is_source_revision_valid INTO l_source_revision_id;

    IF ( c_is_source_revision_valid%NOTFOUND ) THEN
      -- Source REvision Id passed by API user is invalid.
      -- So get the current effective revision. (or throw error?)

      OPEN  c_get_effective_revision(cp_inventory_item_id => p_inventory_item_id
                                    ,cp_organization_id   => p_organization_id
                                    ,cp_revision          => p_revision);
      FETCH c_get_effective_revision INTO l_source_revision_id;
      CLOSE c_get_effective_revision;

    END IF; --c_is_source_revision_valid%NOTFOUND

    CLOSE c_is_source_revision_valid;

  END IF; --p_source_revision_id IS NULL

   IF l_source_revision_id IS NOT NULL THEN
      l_pk_item_pairs         :=EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                   EGO_COL_NAME_VALUE_PAIR_OBJ('INVENTORY_ITEM_ID', p_inventory_item_id)
                                  ,EGO_COL_NAME_VALUE_PAIR_OBJ('ORGANIZATION_ID',   p_organization_id));

      l_pk_item_rev_pairs_src :=  EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'REVISION_ID' , l_source_revision_id));
      l_pk_item_rev_pairs_dst :=  EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'REVISION_ID' , p_revision_id));
      EGO_USER_ATTRS_DATA_PVT.Copy_User_Attrs_Data(
                p_api_version                   => 1.0
               ,p_application_id                => 431
               ,p_object_name                   => 'EGO_ITEM'
               ,p_old_pk_col_value_pairs        => l_pk_item_pairs
               ,p_old_dtlevel_col_value_pairs   => l_pk_item_rev_pairs_src
               ,p_new_pk_col_value_pairs        => l_pk_item_pairs
               ,p_new_dtlevel_col_value_pairs   => l_pk_item_rev_pairs_dst
               ,x_return_status                 => l_return_status
               ,x_errorcode                     => l_error_code
               ,x_msg_count                     => l_msg_count
               ,x_msg_data                      => l_msg_data);
   END IF; --l_source_revision_id IS NOT NULL

   EXCEPTION
      WHEN OTHERS THEN
        BEGIN
          IF (c_get_effective_revision%ISOPEN) THEN
            CLOSE c_get_effective_revision;
          END IF; --c_get_effective_revision%ISOPEN
          IF (c_is_source_revision_valid%ISOPEN) THEN
            CLOSE c_is_source_revision_valid;
          END IF; --c_is_source_revision_valid%ISOPEN
       END;

END copy_rev_UDA;
--5435229 : Defaulting UDA's during revision creation.

--  ============================================================================
--  API Name:           Create_Item_Revision
--
--  Note:  Primary key is passed in with the revision record.
--  ============================================================================

PROCEDURE Create_Item_Revision
(
   p_api_version             IN   NUMBER
,  p_init_msg_list           IN   VARCHAR2   :=  FND_API.G_FALSE
,  p_commit                  IN   VARCHAR2   :=  FND_API.G_FALSE
,  p_validation_level        IN   NUMBER     :=  FND_API.G_VALID_LEVEL_FULL
,  p_process_control         IN   VARCHAR2   :=  NULL
,  x_return_status           OUT  NOCOPY VARCHAR2
,  x_msg_count               OUT  NOCOPY NUMBER
,  x_msg_data                OUT  NOCOPY VARCHAR2
,  p_Item_Revision_rec       IN OUT NOCOPY   Item_Revision_rec_type
)
IS

   CURSOR check_template_name (cp_template_name VARCHAR2) IS
      SELECT template_id
      FROM   mtl_item_templates
      WHERE  template_name = cp_template_name;

   CURSOR check_template_id (cp_template_id NUMBER) IS
      SELECT template_id
      FROM   mtl_item_templates
      WHERE  template_id = cp_template_id;

   l_api_name        CONSTANT  VARCHAR2(30)  :=  'Create_Item_Revision';
   l_api_version     CONSTANT  NUMBER        :=  1.0;
   l_return_status             VARCHAR2(1);
   l_exists                    VARCHAR2(1);
   l_object_version_number     NUMBER;
   c_object_version_number     CONSTANT  NUMBER  :=  1;
   l_revision_ascii_diff       NUMBER;  /*Added for bug 8679971*/
   l_sysdate                   DATE;
   l_revision_id               NUMBER;
   l_apply_template            BOOLEAN := FALSE;
   l_template_id               mtl_item_templates.template_id%TYPE := NULL;
   l_message_name              VARCHAR2(200);
   /*Added for bug 8679971 to ensure error message gets displayed*/
    l_entity_index                          NUMBER;
    l_entity_id                             VARCHAR2(100);
    l_message_type                          VARCHAR2(100);
    /*End of comment*/

BEGIN

   -- Standard start of API savepoint
   SAVEPOINT Create_Item_Revision_PUB;

   --
   -- Capture the current date. The Global has value when it is called from
   -- Procees_Item_Revision
   --
   IF G_Sysdate IS NOT NULL THEN
     l_sysdate := G_Sysdate;
   ELSE
     l_sysdate := SYSDATE;
   END IF;

   -- Check for call compatibility
   IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                       l_api_name, G_PKG_NAME)
   THEN
      RAISE FND_API.g_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list
   IF G_Message_API = 'FND' THEN
     IF FND_API.To_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
     END IF;
   END IF;

   -- Define message context
--   Mctx.Package_Name   := G_PKG_NAME;
--   Mctx.Procedure_Name := l_api_name;

   -- Initialize API return status to success
   x_return_status := FND_API.g_RET_STS_SUCCESS;

   -- Debug Message
   -- AMS_UTILITY_PVT.debug_message('API: ' || l_api_name || ': start');

   -- code for req, unique and fk checks

   -- ------------------------------------
   -- Check for missing or NULL PK values
   -- ------------------------------------

   IF    ( p_Item_Revision_rec.inventory_item_id = fnd_api.G_MISS_NUM )
      OR ( p_Item_Revision_rec.inventory_item_id IS NULL )
   THEN
      Add_Message ('INV', 'INV_ITM_MISS_ITEM_ID');
   END IF;

   IF    ( p_Item_Revision_rec.organization_id = fnd_api.G_MISS_NUM )
      OR ( p_Item_Revision_rec.organization_id IS NULL )
   THEN
      Add_Message ('INV', 'INV_ITM_MISS_ORG_ID');
   END IF;

   IF    ( p_Item_Revision_rec.revision = fnd_api.G_MISS_CHAR )
      OR ( p_Item_Revision_rec.revision IS NULL )
   THEN
      Add_Message ('INV', 'INV_ITM_MISS_REVISION_CODE');
   END IF;

   IF ( x_return_status <> fnd_api.G_RET_STS_SUCCESS ) THEN
      RAISE FND_API.g_EXC_UNEXPECTED_ERROR;
   END IF;

   -- ------------------------------------------------
   -- Validate a part of Revision PK - foreign key to
   -- the composite primary key of the System Item.
   -- ------------------------------------------------

--dbms_output.put_line('OPEN org_item_exists_cur ; x_return_status = ' || x_return_status);

   --INV_ITEM_MSG.Debug(Mctx, 'Check if OrgItem Id exists');

   OPEN org_item_exists_cur ( p_Item_Revision_rec.inventory_item_id
                            , p_Item_Revision_rec.organization_id );

   FETCH org_item_exists_cur INTO l_exists;

   IF ( org_item_exists_cur%NOTFOUND ) THEN
      CLOSE org_item_exists_cur;
      Add_Message ('INV', 'INV_ITM_INVALID_ORGITEM_ID');
      RAISE FND_API.g_EXC_ERROR;
   END IF;

   CLOSE org_item_exists_cur;

   -- ----------------------------------
   -- Check for duplicate item revision
   -- ----------------------------------

   --INV_ITEM_MSG.Debug(Mctx, 'Check for duplicate item revision');

   OPEN Item_Revision_Exists_cur ( p_Item_Revision_rec.inventory_item_id
                                 , p_Item_Revision_rec.organization_id
                                 , p_Item_Revision_rec.revision );

   FETCH Item_Revision_Exists_cur INTO l_object_version_number;

   IF ( Item_Revision_Exists_cur%FOUND ) THEN
      CLOSE Item_Revision_Exists_cur;
      Add_Message ('INV', 'INV_ITM_DUPLICATE_REVISION');
      RAISE FND_API.g_EXC_ERROR;
   END IF;

   CLOSE Item_Revision_Exists_cur;

   /*Changes for bug 8679971*/
	-- ----------------------------------------
	-- Check for ascii value for item revision
	-- ----------------------------------------
     OPEN Item_Revision_Lower_cur ( p_Item_Revision_rec.inventory_item_id
                                   , p_Item_Revision_rec.organization_id
                                   , p_Item_Revision_rec.revision );

	 FETCH Item_Revision_Lower_cur INTO l_revision_ascii_diff;

	 IF (l_revision_ascii_diff < 0 ) THEN
	    CLOSE Item_Revision_Lower_cur;
	    Add_Message ('INV', 'INV_IOI_REV_BAD_ORDER');
	    RAISE FND_API.g_EXC_ERROR;
	 END IF;

	 CLOSE Item_Revision_Lower_cur;

   -- --------------------------------------------------------
   -- Description is a mandatory attribute for a new revision
   -- Bug: 3055810 Description is Optional comparing with forms ui.
   -- --------------------------------------------------------

   IF ( p_Item_Revision_rec.description = fnd_api.G_MISS_CHAR ) THEN

        p_Item_Revision_rec.description := NULL;
--      x_return_status := FND_API.g_RET_STS_ERROR;
--      Add_Message ('INV', 'INV_ITM_REV_MISS_DESCRIPTION');
   END IF;
/* Bug:3055810
   IF ( p_Item_Revision_rec.description IS NULL ) THEN
      x_return_status := FND_API.g_RET_STS_ERROR;
      Add_Message ('INV', 'INV_ITM_REV_NULL_DESCRIPTION');
   END IF;
*/
   -- -------------------------------------------------------------
   -- Effectivity Date is a mandatory attribute for a new revision
   -- -------------------------------------------------------------

   IF ( p_Item_Revision_rec.effectivity_date = FND_API.g_MISS_DATE ) THEN
      x_return_status := FND_API.g_RET_STS_ERROR;
      Add_Message ('INV', 'INV_ITM_REV_MISS_EFF_DATE');
   END IF;

   -- New revision Effectivity Date value cannot be NULL

   IF ( p_Item_Revision_rec.effectivity_date IS NULL ) THEN
      x_return_status := FND_API.g_RET_STS_ERROR;
      Add_Message ('INV', 'INV_ITM_REV_NULL_EFF_DATE');
   END IF;

   -- If the effectivity date is current date, then it is
   -- current date + current time
   -- This Validation will be skipped if the Change Notice is present
   -- Check added for bug 3817613 by absinha

    IF(p_Item_Revision_rec.change_notice IS NULL) THEN
     IF ( trunc(p_Item_Revision_rec.effectivity_date) = trunc(l_sysdate) ) THEN
      IF(p_Item_Revision_rec.effectivity_date < l_sysdate) THEN
        p_Item_Revision_rec.effectivity_date := l_sysdate;
      END IF;
     END IF;

   -- New revision Effectivity Date must be past the current date

     IF ( p_Item_Revision_rec.effectivity_date < l_sysdate ) THEN
       x_return_status := FND_API.g_RET_STS_ERROR;
       Add_Message ('INV', 'INV_ITM_REV_OLD_EFF_DATE');
     END IF;
    END IF;

   IF ( x_return_status <> FND_API.g_RET_STS_SUCCESS ) THEN
      RAISE fnd_api.G_EXC_ERROR;
   END IF;

   -- -----------------------------------------------------
   -- Validate all the other Effectivity Date dependencies
   -- -----------------------------------------------------

   --INV_ITEM_MSG.Debug(Mctx, 'Validate Effectivity Date');

   Validate_Effectivity_Date
   (
      p_Item_Revision_rec  =>  p_Item_Revision_rec
   ,  x_return_status      =>  l_return_status
   );

   IF ( l_return_status = FND_API.g_RET_STS_ERROR ) THEN
      RAISE fnd_api.G_EXC_ERROR;
   ELSIF ( l_return_status = FND_API.g_RET_STS_UNEXP_ERROR ) THEN
      RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- ---------------------------
   -- Default missing attributes
   -- ---------------------------

   IF ( p_Item_Revision_rec.change_notice = FND_API.g_MISS_CHAR ) THEN
      p_Item_Revision_rec.change_notice := NULL;
   END IF;

   IF ( p_Item_Revision_rec.ecn_initiation_date = FND_API.g_MISS_DATE ) THEN
      p_Item_Revision_rec.ecn_initiation_date := NULL;
   END IF;

   /*
   IF ( p_Item_Revision_rec.implementation_date = FND_API.g_MISS_DATE ) OR
        p_Item_Revision_rec.implementation_date IS NULL THEN
      p_Item_Revision_rec.implementation_date := p_Item_Revision_rec.effectivity_date;
   END IF;
   */

   -- Implementation date is always the effectivity date
   IF p_Item_Revision_rec.change_notice IS NOT NULL THEN
      p_Item_Revision_rec.implementation_date := NULL;
   ELSE
      p_Item_Revision_rec.implementation_date := p_Item_Revision_rec.effectivity_date;
   END IF;


   IF ( p_Item_Revision_rec.revised_item_sequence_id = FND_API.g_MISS_NUM ) THEN
      p_Item_Revision_rec.revised_item_sequence_id := NULL;
   END IF;

   --
   -- Revision label cannot be null. If the user did not pass any value or the
   -- value is missing, then revision_label will be same as revision
   --
   IF ( p_Item_Revision_rec.revision_label = FND_API.g_MISS_CHAR OR
        p_Item_Revision_rec.revision_label IS NULL  ) THEN
      p_Item_Revision_rec.revision_label := p_Item_Revision_rec.revision;
   END IF;

   IF ( p_Item_Revision_rec.revision_reason = FND_API.g_MISS_CHAR ) THEN
      p_Item_Revision_rec.revision_reason := NULL;
   END IF;

   IF ( p_Item_Revision_rec.lifecycle_id = FND_API.g_MISS_NUM ) THEN
      p_Item_Revision_rec.lifecycle_id := NULL;
      p_Item_Revision_rec.current_phase_id := NULL;
   END IF;

   IF ( p_Item_Revision_rec.current_phase_id = FND_API.g_MISS_NUM ) THEN
      p_Item_Revision_rec.current_phase_id := NULL;
   END IF;

   --
   -- Derive the Current Phase Id when it is not passed by the user
   --
   IF p_Item_Revision_rec.lifecycle_id IS NOT NULL AND
      p_Item_Revision_rec.current_phase_id IS NULL THEN

     p_Item_Revision_rec.current_phase_id :=
                INV_EGO_REVISION_VALIDATE.Get_Initial_Lifecycle_Phase (p_Item_Revision_rec.lifecycle_id);

     IF ( p_Item_Revision_rec.current_phase_id = 0 ) THEN
       Add_Message ('INV', 'INV_REV_LIFECYCLE_INVALID');
       RAISE FND_API.g_EXC_ERROR;
     END IF;

   END IF;

   -- Start :5208102: Supporting template for UDA's at revisions
   IF p_Item_Revision_rec.template_id = FND_API.g_MISS_NUM THEN
      p_Item_Revision_rec.template_id := NULL;
   END IF;
   IF p_Item_Revision_rec.template_name = FND_API.g_MISS_CHAR THEN
      p_Item_Revision_rec.template_name := NULL;
   END IF;

   IF  (p_Item_Revision_rec.template_id   IS NOT NULL)
   OR (p_Item_Revision_rec.template_name  IS NOT NULL)
   THEN
      l_message_name := NULL;
      --Validate template name
      IF p_Item_Revision_rec.template_id IS NULL AND  p_Item_Revision_rec.template_name IS NOT NULL THEN
         OPEN  check_template_name(p_Item_Revision_rec.template_name);
	      FETCH check_template_name INTO l_template_id;
	      CLOSE check_template_name;

         IF l_template_id IS NULL THEN
            l_message_name := 'INV_TEMPLATE_ERROR';
	      END IF;

        --Validate template id
        ELSIF p_Item_Revision_rec.template_id IS NOT NULL THEN
           OPEN  check_template_id(p_Item_Revision_rec.template_id);
      	  FETCH check_template_id INTO l_template_id;
	        CLOSE check_template_id;

	        IF l_template_id IS NULL THEN
              l_message_name := 'INV_TEMPLATE_ERROR';
           END IF;
        END IF;

        IF l_message_name IS NOT NULL THEN
           Add_Message ('INV', l_message_name);
           RAISE FND_API.g_EXC_ERROR;
        ELSE
           l_apply_template := TRUE;
        END IF;
   END IF;
   -- End :5208102: Supporting template for UDA's at revisions

   --Supporting revision id during revision create.
   IF ( p_Item_Revision_rec.revision_id = FND_API.g_MISS_NUM ) THEN
      p_Item_Revision_rec.revision_id := NULL;
   END IF;

   IF p_Item_Revision_rec.revision_id IS NOT NULL THEN
      BEGIN
         SELECT mtl_item_revisions_b_s.CURRVAL
         INTO l_revision_id FROM DUAL;
         IF p_Item_Revision_rec.revision_id > l_revision_id THEN
            Add_Message ('INV', 'INV_INVALID_REVISION_ID');
            RAISE FND_API.g_EXC_ERROR;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            Add_Message ('INV', 'INV_INVALID_REVISION_ID');
            RAISE FND_API.g_EXC_ERROR;
      END;
   END IF;

   IF p_Item_Revision_rec.revision_id IS NULL THEN

      SELECT mtl_item_revisions_b_s.NEXTVAL
      INTO   p_Item_Revision_rec.revision_id
      FROM DUAL;

   END IF;

   --INV_ITEM_MSG.Debug(Mctx, 'INSERT INTO mtl_item_revisions table');

   INSERT INTO mtl_item_revisions_b
   (
      inventory_item_id
   ,  organization_id
   ,  revision_id
   ,  revision
   ,  change_notice
   ,  ecn_initiation_date
   ,  implementation_date
   ,  effectivity_date
   ,  revised_item_sequence_id
   ,  attribute_category
   ,  attribute1
   ,  attribute2
   ,  attribute3
   ,  attribute4
   ,  attribute5
   ,  attribute6
   ,  attribute7
   ,  attribute8
   ,  attribute9
   ,  attribute10
   ,  attribute11
   ,  attribute12
   ,  attribute13
   ,  attribute14
   ,  attribute15
   ,  creation_date
   ,  created_by
   ,  last_update_date
   ,  last_updated_by
   ,  last_update_login
   ,  request_id
   ,  program_application_id
   ,  program_id
   ,  program_update_date
   ,  object_version_number
   ,  revision_label
   ,  revision_reason
   ,  lifecycle_id
   ,  current_phase_id
   )
   VALUES
   (
      p_Item_Revision_rec.inventory_item_id
   ,  p_Item_Revision_rec.organization_id
   ,  p_Item_Revision_rec.revision_id
   ,  p_Item_Revision_rec.revision
   ,  p_Item_Revision_rec.change_notice
   ,  p_Item_Revision_rec.ecn_initiation_date
   ,  p_Item_Revision_rec.implementation_date
   ,  p_Item_Revision_rec.effectivity_date
   ,  p_Item_Revision_rec.revised_item_sequence_id
   ,  DECODE(p_Item_Revision_rec.attribute_category,    G_Miss_Char,    NULL,   p_Item_Revision_rec.attribute_category  )
   ,  DECODE(p_Item_Revision_rec.attribute1,            G_Miss_Char,    NULL,   p_Item_Revision_rec.attribute1          )
   ,  DECODE(p_Item_Revision_rec.attribute2,            G_Miss_Char,    NULL,   p_Item_Revision_rec.attribute2          )
   ,  DECODE(p_Item_Revision_rec.attribute3,            G_Miss_Char,    NULL,   p_Item_Revision_rec.attribute3          )
   ,  DECODE(p_Item_Revision_rec.attribute4,            G_Miss_Char,    NULL,   p_Item_Revision_rec.attribute4          )
   ,  DECODE(p_Item_Revision_rec.attribute5,            G_Miss_Char,    NULL,   p_Item_Revision_rec.attribute5          )
   ,  DECODE(p_Item_Revision_rec.attribute6,            G_Miss_Char,    NULL,   p_Item_Revision_rec.attribute6          )
   ,  DECODE(p_Item_Revision_rec.attribute7,            G_Miss_Char,    NULL,   p_Item_Revision_rec.attribute7          )
   ,  DECODE(p_Item_Revision_rec.attribute8,            G_Miss_Char,    NULL,   p_Item_Revision_rec.attribute8          )
   ,  DECODE(p_Item_Revision_rec.attribute9,            G_Miss_Char,    NULL,   p_Item_Revision_rec.attribute9          )
   ,  DECODE(p_Item_Revision_rec.attribute10,           G_Miss_Char,    NULL,   p_Item_Revision_rec.attribute10         )
   ,  DECODE(p_Item_Revision_rec.attribute11,           G_Miss_Char,    NULL,   p_Item_Revision_rec.attribute11         )
   ,  DECODE(p_Item_Revision_rec.attribute12,           G_Miss_Char,    NULL,   p_Item_Revision_rec.attribute12         )
   ,  DECODE(p_Item_Revision_rec.attribute13,           G_Miss_Char,    NULL,   p_Item_Revision_rec.attribute13         )
   ,  DECODE(p_Item_Revision_rec.attribute14,           G_Miss_Char,    NULL,   p_Item_Revision_rec.attribute14         )
   ,  DECODE(p_Item_Revision_rec.attribute15,           G_Miss_Char,    NULL,   p_Item_Revision_rec.attribute15         )
   ,  l_sysdate
   ,  FND_GLOBAL.user_id
   ,  l_sysdate
   ,  FND_GLOBAL.user_id
   ,  FND_GLOBAL.conc_login_id
   ,  DECODE(p_Item_Revision_rec.request_id,            G_Miss_Num,     NULL,   p_Item_Revision_rec.request_id          )
   ,  DECODE(p_Item_Revision_rec.program_application_id,  G_Miss_Num,   NULL,   p_Item_Revision_rec.program_application_id      )
   ,  DECODE(p_Item_Revision_rec.program_id,            G_Miss_Num,     NULL,   p_Item_Revision_rec.program_id          )
   ,  DECODE(p_Item_Revision_rec.program_update_date,   G_Miss_Date,    NULL,   p_Item_Revision_rec.program_update_date )
   ,  c_object_version_number
   ,  p_Item_Revision_rec.revision_label
   ,  p_Item_Revision_rec.revision_reason
   ,  p_Item_Revision_rec.lifecycle_id
   ,  p_Item_Revision_rec.current_phase_id
   ) RETURNING revision_id, object_version_number INTO G_revision_id, G_object_version_number;

--dbms_output.put_line('done INSERTing INTO mtl_item_revisions table; x_return_status = ' || x_return_status);

   --
   -- IF Create revision API is called directly (not through Process_Item_Revision),
   -- then get the language code
   --

   IF G_language_code IS NULL THEN
     SELECT userenv('LANG') INTO G_language_code FROM dual;
   END IF;

   -- Insert into TL table

   INSERT INTO mtl_item_revisions_TL
                (  Inventory_Item_Id
                ,  Organization_Id
                ,  Revision_id
                 , Language
                 , Source_Lang
                 , Created_By
                 , Creation_Date
                 , Last_Updated_By
                 , Last_Update_Date
                 , Last_Update_Login
                 , Description
                 )
                SELECT p_Item_Revision_rec.inventory_item_id
                     , p_Item_Revision_rec.organization_id
                     , G_revision_id
                     , lang.language_code
                     , G_language_code
                     , G_User_Id
                     , l_sysdate
                     , G_User_Id
                     , l_sysdate
                     , G_Login_Id
                     , p_Item_Revision_rec.description
                  FROM FND_LANGUAGES lang
                 WHERE lang.installed_flag in ('I', 'B');

   --
   -- Initiate the revision entry in pending item status table which will maintain
   -- the period for each lifecycle phase
   --

   IF p_Item_Revision_rec.lifecycle_id IS NOT NULL THEN

     INSERT INTO mtl_pending_item_status
                (  Inventory_Item_Id
                 , Organization_Id
                 , Status_code
                 , Effective_date
                 , Implemented_date
                 , Pending_flag
                 , Revision_Id
                 , lifecycle_id
                 , phase_id
                 , Created_By
                 , Creation_Date
                 , Last_Updated_By
                 , Last_Update_Date
                 , Last_Update_Login
                 )
                VALUES
                (  p_Item_Revision_rec.Inventory_Item_Id
                 , p_Item_Revision_rec.Organization_Id
                 , NULL
                 , l_sysdate
                 , l_sysdate
                 , 'N'
                 , G_revision_id
                 , p_Item_Revision_rec.lifecycle_id
                 , p_Item_Revision_rec.current_phase_id
                 , G_User_Id
                 , l_sysdate
                 , G_User_Id
                 , l_sysdate
                 , G_Login_Id
                 );
   END IF;

   IF (INSTR(NVL(p_process_control,'PLM_UI:N'),'PLM_UI:Y') = 0 ) THEN
      -- Start 5208102: Supporting template for UDA's at revisions


      IF l_apply_template THEN
         Insert_Revision_UserAttr(p_organization_id   => p_Item_Revision_rec.Organization_Id
                                 ,p_inventory_item_id => p_Item_Revision_rec.inventory_item_id
                                 ,p_revision_id       => G_revision_id
                                 ,p_transaction_type  => 'CREATE'
                                 ,p_template_id       => l_template_id);
      END IF;
      -- End 5208102: Supporting template for UDA's at revisions

      -- Bug 5435229
      -- Copy revision UDA
      copy_rev_UDA(p_organization_id   => p_Item_Revision_rec.organization_id
                  ,p_inventory_item_id => p_Item_Revision_rec.inventory_item_id
                  ,p_revision_id       => p_Item_Revision_rec.revision_id
                  ,p_revision          => p_Item_Revision_rec.revision);

   -- Bug 5525054
      BEGIN
	 INV_ITEM_EVENTS_PVT.Raise_Events(
	  p_event_name        => 'EGO_WF_WRAPPER_PVT.G_REV_CHANGE_EVENT'
	 ,p_dml_type          => 'CREATE'
	 ,p_inventory_item_id => p_Item_Revision_rec.Inventory_Item_Id
	 ,p_organization_id   => p_Item_Revision_rec.Organization_Id
	 ,p_revision_id       => p_Item_Revision_rec.revision_id);

	 EXCEPTION
	  WHEN OTHERS THEN
	 NULL;
      END;

   END IF;

   --Commented out for bug 5525054
   /* R12: Business Event Enhancement:
   Raise Event if Revision got Created successfully *//*
   BEGIN
     INV_ITEM_EVENTS_PVT.Raise_Events(
         p_event_name        => 'EGO_WF_WRAPPER_PVT.G_REV_CHANGE_EVENT'
        ,p_dml_type          => 'CREATE'
        ,p_inventory_item_id => p_Item_Revision_rec.Inventory_Item_Id
        ,p_organization_id   => p_Item_Revision_rec.Organization_Id
        ,p_revision_id       => p_Item_Revision_rec.revision_id);
   EXCEPTION
      WHEN OTHERS THEN
	NULL;
   END;
  */ /* R12: Business Event Enhancement:
   Raise Event if Revision got Created successfully */

   -- Standard check of p_commit
   IF FND_API.To_Boolean (p_commit) THEN
      --INV_ITEM_MSG.Debug(Mctx, 'before COMMIT WORK');
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.

      IF G_Message_API = 'BOM' THEN
        x_msg_count := Error_Handler.Get_Message_Count;
      ELSE
        FND_MSG_PUB.Count_And_Get
        (  p_count  =>  x_msg_count
        ,  p_data   =>  x_msg_data
        );

	 /*Bug 6853558 Added to get the message if count is > 1 */
         IF( x_msg_count > 1 ) THEN
		x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE );
         END IF;
      END IF;

EXCEPTION

   WHEN FND_API.g_EXC_ERROR THEN

      ROLLBACK TO Create_Item_Revision_PUB;
      x_return_status := FND_API.g_RET_STS_ERROR;
	  /*Added for Bug 8679971 to ensure error message is displayed*/
      IF G_Message_API = 'BOM' THEN
        x_msg_count := Error_Handler.Get_Message_Count;
        Error_Handler.Get_Message
	         (x_message_text     => x_msg_data
              , x_entity_index        => l_entity_index
              , x_entity_id                => l_entity_id
              , x_message_type        => l_message_type
              );
 	   /*End of comment*/
      ELSE
        FND_MSG_PUB.Count_And_Get
        (  p_count  =>  x_msg_count
        ,  p_data   =>  x_msg_data
        );
	 /*Bug 6853558 Added to get the message if count is > 1 */
 	 IF( x_msg_count > 1 ) THEN
 	    x_msg_data := fnd_msg_pub.get(x_msg_count,FND_API.G_FALSE );
 	 END IF;
      END IF;

   WHEN FND_API.g_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Create_Item_Revision_PUB;
      x_return_status := FND_API.g_RET_STS_UNEXP_ERROR;

      IF G_Message_API = 'BOM' THEN
        x_msg_count := Error_Handler.Get_Message_Count;
      ELSE
        FND_MSG_PUB.Count_And_Get
        (  p_count  =>  x_msg_count
        ,  p_data   =>  x_msg_data
        );
	 /*Bug 6853558 Added to get the message if count is > 1 */
 	IF( x_msg_count > 1 ) THEN
 	   x_msg_data := fnd_msg_pub.get(x_msg_count,FND_API.G_FALSE);
 	END IF;
      END IF;

   WHEN others THEN

      ROLLBACK TO Create_Item_Revision_PUB;
      x_return_status := FND_API.g_RET_STS_UNEXP_ERROR;

      Add_Message
         ( p_api_name           =>  l_api_name
           , p_message_text       =>  'UNEXP_ERROR : ' || SQLERRM
         );

      IF G_Message_API = 'BOM' THEN
        x_msg_count := Error_Handler.Get_Message_Count;
      ELSE
        FND_MSG_PUB.Count_And_Get
        (  p_count  =>  x_msg_count
        ,  p_data   =>  x_msg_data
        );
	/*Bug 6853558 Added to get the message if count is > 1 */
 	 IF( x_msg_count > 1 ) THEN
 	   x_msg_data := fnd_msg_pub.get(x_msg_count,FND_API.G_FALSE);
 	 END IF;
      END IF;

END Create_Item_Revision;


--  ============================================================================
--  API Name:           Update_Item_Revision
--  ============================================================================

PROCEDURE Update_Item_Revision
(
   p_api_version             IN   NUMBER
,  p_init_msg_list           IN   VARCHAR2   :=  FND_API.g_FALSE
,  p_commit                  IN   VARCHAR2   :=  FND_API.g_FALSE
,  p_validation_level        IN   NUMBER     :=  FND_API.g_VALID_LEVEL_FULL
,  p_process_control         IN   VARCHAR2   :=  NULL
,  x_return_status           OUT  NOCOPY VARCHAR2
,  x_msg_count               OUT  NOCOPY NUMBER
,  x_msg_data                OUT  NOCOPY VARCHAR2
,  p_Item_Revision_rec       IN OUT NOCOPY Item_Revision_rec_type
)
IS
   CURSOR check_template_name (cp_template_name VARCHAR2) IS
      SELECT template_id
      FROM   mtl_item_templates
      WHERE  template_name = cp_template_name;

   CURSOR check_template_id (cp_template_id NUMBER) IS
      SELECT template_id
      FROM   mtl_item_templates
      WHERE  template_id = cp_template_id;

   CURSOR ItemRev_oldvalues_cur(p_inventory_item_id    NUMBER
                               ,p_organization_id      NUMBER
                               ,p_revision             VARCHAR2) IS
      SELECT  effectivity_date
             ,implementation_date
             ,lifecycle_id
             ,current_phase_id
      FROM  mtl_item_revisions_b
      WHERE   inventory_item_id = p_inventory_item_id
         AND  organization_id   = p_organization_id
         AND  revision          = p_revision;

   l_api_name        CONSTANT  VARCHAR2(30)  :=  'Update_Item_Revision';
   l_api_version     CONSTANT  NUMBER        :=  1.0;
   l_return_status             VARCHAR2(1) := NULL;
   l_exists                    VARCHAR2(1);
   l_object_version_number     NUMBER;
   l_orig_effectivity_date     DATE;
   l_orig_implementation_date  DATE;
   l_orig_lifecycle_id         NUMBER;
   l_orig_current_phase_id     NUMBER;
   l_lifecycle_id              NUMBER;
   l_current_phase_id          NUMBER;
   l_sysdate                   DATE;
   l_msg_count                 NUMBER;
   l_msg_text                  VARCHAR2(4000);
   l_apply_template            BOOLEAN := FALSE;
   l_template_id               mtl_item_templates.template_id%TYPE := NULL;
   l_message_name              VARCHAR2(200);

BEGIN


   -- Standard start of API savepoint
   SAVEPOINT Update_Item_Revision_PUB;

   --
   -- Capture the current date. The Global has value when it is called from
   -- Procees_Item_Revision
   --
   IF G_Sysdate IS NOT NULL THEN
     l_sysdate := G_Sysdate;
   ELSE
     l_sysdate := SYSDATE;
   END IF;

   -- Check for call compatibility
   IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                       l_api_name, G_PKG_NAME)
   THEN
      RAISE FND_API.g_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list
   IF G_Message_API = 'FND' THEN
     IF FND_API.To_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
     END IF;
   END IF;

   -- Define message context
--   Mctx.Package_Name   := G_PKG_NAME;
--   Mctx.Procedure_Name := l_api_name;

   -- Initialize API return status to success
   x_return_status := FND_API.g_RET_STS_SUCCESS;

   -- code for req, unique and fk checks

   -- ------------------------------------
   -- Check for missing or NULL PK values
   -- ------------------------------------

   IF    ( p_Item_Revision_rec.inventory_item_id = FND_API.g_MISS_NUM )
      OR ( p_Item_Revision_rec.inventory_item_id IS NULL )
   THEN
      Add_Message ('INV', 'INV_ITM_MISS_ITEM_ID');
   END IF;

   IF    ( p_Item_Revision_rec.organization_id = FND_API.g_MISS_NUM )
      OR ( p_Item_Revision_rec.organization_id IS NULL )
   THEN
      Add_Message ('INV', 'INV_ITM_MISS_ORG_ID');
   END IF;

   IF    ( p_Item_Revision_rec.revision = FND_API.g_MISS_CHAR )
      OR ( p_Item_Revision_rec.revision IS NULL )
   THEN
      Add_Message ('INV', 'INV_ITM_MISS_REVISION_CODE');
   END IF;

   -- Return with errors accumulated so far
   IF ( x_return_status <> FND_API.g_RET_STS_SUCCESS ) THEN
      RAISE FND_API.g_EXC_UNEXPECTED_ERROR;
   END IF;

   -- ------------------------------------------------
   -- Validate a part of Revision PK - foreign key to
   -- the composite primary key of the System Item.
   -- ------------------------------------------------

--dbms_output.put_line('OPEN org_item_exists_cur ; x_return_status = ' || x_return_status);

   --INV_ITEM_MSG.Debug(Mctx, 'Check if OrgItem Id exists');

   OPEN org_item_exists_cur ( p_Item_Revision_rec.inventory_item_id
                            , p_Item_Revision_rec.organization_id );

   FETCH org_item_exists_cur INTO l_exists;

   IF ( org_item_exists_cur%NOTFOUND ) THEN
      CLOSE org_item_exists_cur;
      Add_Message ('INV', 'INV_ITM_INVALID_ORGITEM_ID');
      RAISE FND_API.g_EXC_ERROR;
   END IF;

   CLOSE org_item_exists_cur;

   -- ------------------------------
   -- Check if item revision exists
   -- ------------------------------

   --INV_ITEM_MSG.Debug(Mctx, 'Check if item revision exists');
   IF p_Item_Revision_rec.revision_id IS NOT NULL THEN
      OPEN Item_Revision_Id_Exists_cur ( p_Item_Revision_rec.inventory_item_id
                                       , p_Item_Revision_rec.organization_id
                                       , p_Item_Revision_rec.revision_id );
      FETCH Item_Revision_Id_Exists_cur INTO l_object_version_number;
      IF ( Item_Revision_Id_Exists_cur%NOTFOUND ) THEN
         CLOSE Item_Revision_Id_Exists_cur;
         Add_Message ('INV', 'INV_ITM_INVALID_REVISION_CODE');
         RAISE FND_API.g_EXC_ERROR;
      END IF;
      CLOSE Item_Revision_Id_Exists_cur;

      --3655522 begin
      OPEN Upd_Item_Rev_Exists_cur (p_Item_Revision_rec.inventory_item_id
                                       , p_Item_Revision_rec.organization_id
                                       , p_Item_Revision_rec.revision
                                       , p_Item_Revision_rec.revision_id);
      FETCH Upd_Item_Rev_Exists_cur INTO l_object_version_number;
      IF ( Upd_Item_Rev_Exists_cur%FOUND ) THEN
         CLOSE Upd_Item_Rev_Exists_cur;
         Add_Message ('INV', 'INV_ITM_DUPLICATE_REVISION');
         RAISE FND_API.g_EXC_ERROR;
      END IF;
      CLOSE Upd_Item_Rev_Exists_cur;
      --3655522 end

   ELSE
      OPEN Item_Revision_Exists_cur ( p_Item_Revision_rec.inventory_item_id
                                    , p_Item_Revision_rec.organization_id
                                    , p_Item_Revision_rec.revision );

      FETCH Item_Revision_Exists_cur INTO l_object_version_number;
      IF ( Item_Revision_Exists_cur%NOTFOUND ) THEN
         CLOSE Item_Revision_Exists_cur;
         Add_Message ('INV', 'INV_ITM_INVALID_REVISION_CODE');
         RAISE FND_API.g_EXC_ERROR;
      END IF;
      CLOSE Item_Revision_Exists_cur;
   END IF;

   -- --------------------------------------
   -- Description cannot be updated to NULL
   -- Bug: 3055810 Description is optional.
   -- --------------------------------------
/*
   IF ( p_Item_Revision_rec.description = FND_API.g_MISS_CHAR ) THEN
      x_return_status := FND_API.g_RET_STS_ERROR;
      Add_Message ('INV', 'INV_ITM_REV_NULL_DESCRIPTION');
   END IF;
*/
   -- -------------------------------------------
   -- Effectivity Date cannot be updated to NULL
   -- -------------------------------------------

   --Dbms_output.put_line('UPDATE: Checking for missing effectivity date');

   IF ( p_Item_Revision_rec.effectivity_date = FND_API.g_MISS_DATE ) THEN
      x_return_status := FND_API.g_RET_STS_ERROR;
      Add_Message ('INV', 'INV_ITM_REV_NULL_EFF_DATE');
   END IF;

   IF x_return_status <> FND_API.g_RET_STS_SUCCESS THEN
      RAISE FND_API.g_EXC_ERROR;
   END IF;

   -- ------------------------------------------------------------------------------
   -- Revision is not updateable when Effectivity Date is prior to the current date
   -- ------------------------------------------------------------------------------

   --Dbms_output.put_line('UPDATE: Checking for null effectivity date');

   -- Get the original effectivity date and compare with the user input

   OPEN ItemRev_Oldvalues_cur ( p_Item_Revision_rec.inventory_item_id
                                 , p_Item_Revision_rec.organization_id
                                 , p_Item_Revision_rec.revision );
   FETCH ItemRev_Oldvalues_cur INTO l_orig_effectivity_date, l_orig_implementation_date, l_orig_lifecycle_id,
                                                l_orig_current_phase_id;
   CLOSE ItemRev_Oldvalues_cur;

   -- If the user has passed in the effectivity date

   IF ( p_Item_Revision_rec.effectivity_date IS NOT NULL ) THEN

     -- And it is different from the revision's old effectivity date

     IF (p_Item_Revision_rec.effectivity_date <> l_orig_effectivity_date) THEN

       -- Assign current date + time if the user is passing the current date
       -- (may be he is moving the effectivity from future to current)
       -- Adding the nested IF loop for Bug 4162240 - Anmurali

       IF trunc(p_Item_Revision_rec.effectivity_date) = trunc(l_sysdate) THEN
           IF(p_Item_Revision_rec.effectivity_date < l_sysdate) THEN
               p_Item_Revision_rec.effectivity_date := l_sysdate;
           END IF;
       END IF;

       -- Effectivity cannnot be changed if the revision is current/past revision
       -- and also the effectivity cannot be moved to past
       /*Bug: 5037166 Modified the clause below to prevent Revision being updated
                      with Effectivity date prior to SYSDATE*/
       IF (( l_orig_effectivity_date < l_sysdate AND
             l_orig_implementation_date IS NOT NULL )
            OR p_Item_Revision_rec.effectivity_date < l_sysdate ) THEN
            --3655522 if rev is not implemented, then we allow changing effectivity date
         x_return_status := FND_API.g_RET_STS_ERROR;
         Add_Message ('INV','INV_ITM_REV_EFF_DATE_NON_UPD');
         RAISE FND_API.g_EXC_ERROR;
       END IF;

     END IF;

   END IF;

   -- -----------------------------------------------------
   -- Validate all the other Effectivity Date dependencies
   -- -----------------------------------------------------

   --INV_ITEM_MSG.Debug(Mctx, 'Validate Effectivity Date');

   IF ( p_Item_Revision_rec.effectivity_date IS NOT NULL ) --AND
      --( p_Item_Revision_rec.effectivity_date <> l_orig_effectivity_date )
      --3655522 we support update of rev code through ECO. So we need to
      --validate if rev code conforms to effectivity date rules
      THEN

     Validate_Effectivity_Date
     (
      p_Item_Revision_rec  =>  p_Item_Revision_rec
     ,  x_return_status      =>  l_return_status
     );

     IF ( l_return_status = FND_API.g_RET_STS_ERROR ) THEN
      RAISE FND_API.g_EXC_ERROR;
     ELSIF ( l_return_status = FND_API.g_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.g_EXC_UNEXPECTED_ERROR;
     END IF;

   END IF;

--dbms_output.put_line('UPDATE mtl_item_revisions table; x_return_status = ' || x_return_status);
   --
   -- Cannnot NULL OUT or CHANGE an existing lifecycle for a revision
   --
-- 3557001
-- user can null out lifecycle.
--   IF l_orig_lifecycle_id IS NOT NULL AND
--      nvl(p_Item_Revision_rec.lifecycle_id,l_orig_lifecycle_id) <> l_orig_lifecycle_id THEN
--
--      Add_Message ('INV', 'INV_CANNOT_CHANGE_LIFECYCLE');
--      RAISE FND_API.g_EXC_ERROR;
--   END IF;
--
   --
   -- Now either the user tries to update an existing life cycle (can update only the current phase)
   -- or assign a new one to the revision or leave those as it is
   --
   l_lifecycle_id     := p_Item_Revision_rec.lifecycle_id;
   l_current_phase_id := p_Item_Revision_rec.current_phase_id;
   --
   -- When the lifecycle id is a MISSING value, then assign NULL to both lifecycle and
   -- current phase
   --
   IF l_lifecycle_id = FND_API.g_MISS_NUM THEN

     l_lifecycle_id     := NULL;
     l_current_phase_id := NULL;

     --
     -- If the lifecycle is NULL, then default it from database
     --
   ELSIF l_lifecycle_id IS NULL THEN

     l_lifecycle_id := l_orig_lifecycle_id;

     -- The lifecycle id could be null in the database (i.e not yet assigned to this revision)
     -- When a lifecycle is null, then current phase cannnot have value
     --
     IF l_lifecycle_id IS NULL THEN
       l_current_phase_id := NULL;

     -- When there is a lifecycle and the current phase id is null or missing, then
     -- default it from the database.
     -- If the user has passed a valid current phase id, then use that

     ELSIF l_current_phase_id IS NULL OR l_current_phase_id = FND_API.g_MISS_NUM THEN
      l_current_phase_id := l_orig_current_phase_id;
     END IF;

   ELSIF l_lifecycle_id IS NOT NULL THEN
     --
     -- If the life cycle already exists for the revision, and the user has passed null
     -- or missing for the current phase, then default the old from the database
     --
     IF l_orig_lifecycle_id IS NOT NULL THEN

       IF l_current_phase_id IS NULL OR l_current_phase_id = FND_API.g_MISS_NUM THEN
         l_current_phase_id := l_orig_current_phase_id;
       END IF;

     ELSE
     --
     -- If the life cycle does not exist, and the user has passed null or missing for
     -- the current phase, then derive the current phase id
     --
       IF l_current_phase_id IS NULL OR l_current_phase_id = FND_API.g_MISS_NUM THEN

         l_current_phase_id :=
                INV_EGO_REVISION_VALIDATE.Get_Initial_Lifecycle_Phase (l_lifecycle_id);
         IF l_current_phase_id = 0 THEN
           Add_Message ('INV', 'INV_REV_LIFECYCLE_INVALID');
           RAISE FND_API.g_EXC_ERROR;
         END IF;

       END IF;

     END IF;
   END IF;
--Bug: 3802017 Validate if there is any pending CO for revision
   EXECUTE IMMEDIATE
               ' BEGIN                                                     '
             ||'   EGO_INV_ITEM_CATALOG_PVT.VALIDATE_AND_CHANGE_ITEM_LC(   '
             ||'      P_API_VERSION             => 1.0                     '
             ||'     ,P_COMMIT                  => FND_API.G_FALSE         '
             ||'     ,P_INVENTORY_ITEM_ID       => :p_Item_Revision_rec.inventory_item_id'
             ||'     ,P_ORGANIZATION_ID         => :p_Item_Revision_rec.organization_id  '
             ||'     ,P_ITEM_REVISION_ID        => :p_Item_Revision_rec.revision_id      '
             ||'     ,P_FETCH_CURR_VALUES       => FND_API.G_TRUE          '
             ||'     ,P_CURR_CC_ID              => NULL                    '
             ||'     ,P_NEW_CC_ID               => NULL                    '
             ||'     ,P_CURR_LC_ID              => NULL                    '
             ||'     ,P_NEW_LC_ID               => :l_lifecycle_id         '
             ||'     ,P_NEW_LCP_ID              => :l_current_phase_id     '
             ||'     ,P_CURR_LCP_ID             => NULL                    '
             ||'     ,P_IS_NEW_CC_IN_HIER       => FND_API.G_TRUE          '
             ||'     ,P_CHANGE_ID               => NULL                    '
             ||'     ,P_CHANGE_LINE_ID          => NULL                    '
             ||'     ,X_RETURN_STATUS           => :l_return_status        '
             ||'     ,X_MSG_COUNT               => :l_msg_count            '
             ||'     ,X_MSG_DATA                => :l_msg_text);           '
             ||' EXCEPTION                                                 '
             ||'    WHEN OTHERS THEN                                       '
             ||'      NULL;                                                '
             ||' END;                                                      '
            USING IN  p_Item_Revision_rec.inventory_item_id,
                  IN  p_Item_Revision_rec.organization_id,
                  IN  p_Item_Revision_rec.revision_id,
                  IN  l_lifecycle_id,
                  IN  l_current_phase_id,
                  OUT l_return_status,
                  OUT l_msg_count,
                  OUT l_msg_text;

    IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
         Add_Message (p_message_text => l_msg_text);
         RAISE FND_API.g_EXC_ERROR;
    END IF;

--Bug: 3802017 ends

   -- Start :5208102: Supporting template for UDA's at revisions
   IF p_Item_Revision_rec.template_id = FND_API.g_MISS_NUM THEN
      p_Item_Revision_rec.template_id := NULL;
   END IF;
   IF p_Item_Revision_rec.template_name = FND_API.g_MISS_CHAR THEN
      p_Item_Revision_rec.template_name := NULL;
   END IF;

   IF  (p_Item_Revision_rec.template_id   IS NOT NULL)
   OR (p_Item_Revision_rec.template_name  IS NOT NULL)
   THEN
      l_message_name := NULL;
      --Validate template name
      IF p_Item_Revision_rec.template_id IS NULL AND  p_Item_Revision_rec.template_name IS NOT NULL THEN
         OPEN  check_template_name(p_Item_Revision_rec.template_name);
	 FETCH check_template_name INTO l_template_id;
	 CLOSE check_template_name;

         IF l_template_id IS NULL THEN
            l_message_name := 'INV_TEMPLATE_ERROR';
	 END IF;

         --Validate template id
      ELSIF p_Item_Revision_rec.template_id IS NOT NULL THEN
         OPEN  check_template_id(p_Item_Revision_rec.template_id);
      	 FETCH check_template_id INTO l_template_id;
	 CLOSE check_template_id;

	 IF l_template_id IS NULL THEN
            l_message_name := 'INV_TEMPLATE_ERROR';
         END IF;
      END IF;

      IF l_message_name IS NOT NULL THEN
         Add_Message ('INV', l_message_name);
         RAISE FND_API.g_EXC_ERROR;
      ELSE
         l_apply_template := TRUE;
      END IF;
   END IF;
   -- End :5208102: Supporting template for UDA's at revisions


   --INV_ITEM_MSG.Debug(Mctx, 'UPDATE mtl_item_revisions table');

   UPDATE mtl_item_revisions_b
   SET
      revision                  =  DECODE(p_Item_Revision_rec.revision,                 G_Miss_Char,    revision, null, revision,               p_Item_Revision_rec.revision    )
   ,  change_notice             =  DECODE(p_Item_Revision_rec.change_notice,            G_Miss_Char,    null, null, change_notice,              p_Item_Revision_rec.change_notice       )
   ,  ecn_initiation_date       =  DECODE(p_Item_Revision_rec.ecn_initiation_date,      G_Miss_Date,    null, null, ecn_initiation_date,        p_Item_Revision_rec.ecn_initiation_date )
   ,  effectivity_date          =  DECODE(p_Item_Revision_rec.effectivity_date, null, effectivity_date,         p_Item_Revision_rec.effectivity_date    )
   ,  implementation_date       =  DECODE(change_notice,null,DECODE(p_Item_Revision_rec.effectivity_date,null,effectivity_date,p_Item_Revision_rec.effectivity_date),implementation_date) --3607562
   ,  revised_item_sequence_id  =  DECODE(p_Item_Revision_rec.revised_item_sequence_id, G_Miss_Num,     null, null, revised_item_sequence_id,  p_Item_Revision_rec.revised_item_sequence_id     )
   ,  attribute_category        =  DECODE(p_Item_Revision_rec.attribute_category,       G_Miss_Char, null, null,        attribute_category,     p_Item_Revision_rec.attribute_category  )
   ,  attribute1                =  DECODE(p_Item_Revision_rec.attribute1,               G_Miss_Char, null, null,        attribute1,             p_Item_Revision_rec.attribute1          )
   ,  attribute2                =  DECODE(p_Item_Revision_rec.attribute2,               G_Miss_Char, null, null,        attribute2,             p_Item_Revision_rec.attribute2          )
   ,  attribute3                =  DECODE(p_Item_Revision_rec.attribute3,               G_Miss_Char, null, null,        attribute3,             p_Item_Revision_rec.attribute3          )
   ,  attribute4                =  DECODE(p_Item_Revision_rec.attribute4,               G_Miss_Char, null, null,        attribute4,             p_Item_Revision_rec.attribute4          )
   ,  attribute5                =  DECODE(p_Item_Revision_rec.attribute5,               G_Miss_Char, null, null,        attribute5,             p_Item_Revision_rec.attribute5          )
   ,  attribute6                =  DECODE(p_Item_Revision_rec.attribute6,               G_Miss_Char, null, null,        attribute6,             p_Item_Revision_rec.attribute6          )
   ,  attribute7                =  DECODE(p_Item_Revision_rec.attribute7,               G_Miss_Char, null, null,        attribute7,             p_Item_Revision_rec.attribute7          )
   ,  attribute8                =  DECODE(p_Item_Revision_rec.attribute8,               G_Miss_Char, null, null,        attribute8,             p_Item_Revision_rec.attribute8          )
   ,  attribute9                =  DECODE(p_Item_Revision_rec.attribute9,               G_Miss_Char, null, null,        attribute9,             p_Item_Revision_rec.attribute9          )
   ,  attribute10               =  DECODE(p_Item_Revision_rec.attribute10,              G_Miss_Char, null, null,        attribute10,            p_Item_Revision_rec.attribute10         )
   ,  attribute11               =  DECODE(p_Item_Revision_rec.attribute11,              G_Miss_Char, null, null,        attribute11,            p_Item_Revision_rec.attribute11         )
   ,  attribute12               =  DECODE(p_Item_Revision_rec.attribute12,              G_Miss_Char, null, null,        attribute12,            p_Item_Revision_rec.attribute12         )
   ,  attribute13               =  DECODE(p_Item_Revision_rec.attribute13,              G_Miss_Char, null, null,        attribute13,            p_Item_Revision_rec.attribute13         )
   ,  attribute14               =  DECODE(p_Item_Revision_rec.attribute14,              G_Miss_Char, null, null,        attribute14,            p_Item_Revision_rec.attribute14         )
   ,  attribute15               =  DECODE(p_Item_Revision_rec.attribute15,              G_Miss_Char, null, null,        attribute15,            p_Item_Revision_rec.attribute15         )
   ,  last_update_date          =  l_sysdate
   ,  last_updated_by           =  FND_GLOBAL.user_id
   ,  last_update_login         =  FND_GLOBAL.conc_login_id
   ,  request_id                =  DECODE(p_Item_Revision_rec.request_id,               G_Miss_Num,     null, null, request_id,         p_Item_Revision_rec.request_id          )
   ,  program_application_id    =  DECODE(p_Item_Revision_rec.program_application_id,   G_Miss_Num,     null, null, program_application_id,     p_Item_Revision_rec.program_application_id      )
   ,  program_id                =  DECODE(p_Item_Revision_rec.program_id,               G_Miss_Num,     null, null, program_id,         p_Item_Revision_rec.program_id          )
   ,  program_update_date       =  DECODE(p_Item_Revision_rec.program_update_date,      G_Miss_Date,    null, null, program_update_date,        p_Item_Revision_rec.program_update_date )
   ,  object_version_number     =  nvl(object_version_number,0) + 1
   ,  revision_label            =  DECODE(p_Item_Revision_rec.revision_label,           G_Miss_Char,    revision_label, null, revision_label,           p_Item_Revision_rec.revision_label)
   ,  revision_reason           =  DECODE(p_Item_Revision_rec.revision_reason,          G_Miss_Char,    null, null, revision_reason,            p_Item_Revision_rec.revision_reason)
   ,  lifecycle_id              =  l_lifecycle_id
   ,  current_phase_id          =  l_current_phase_id
   WHERE
           inventory_item_id      =  p_Item_Revision_rec.inventory_item_id
      AND  organization_id        =  p_Item_Revision_rec.organization_id
      AND  (revision_id = p_Item_Revision_rec.revision_id or revision   =  p_Item_Revision_rec.revision)
      AND  nvl(object_version_number,0)  =  nvl(p_Item_Revision_rec.object_version_number,nvl(object_version_number,0))
   RETURNING revision_id, object_version_number INTO G_revision_id, G_object_version_number;

   IF ( SQL%NOTFOUND ) THEN
      Add_Message ('INV', 'INV_ITM_REVISION_REC_CHANGED');
      RAISE FND_API.g_EXC_ERROR;
   END IF;


   --
   -- IF Update revision API is called directly (not through Process_Item_Revision),
   -- then get the language code
   --

   IF G_language_code IS NULL THEN
     SELECT userenv('LANG') INTO G_language_code FROM dual;
   END IF;

   -- Update the description in the TL table
   --
   UPDATE  mtl_item_revisions_TL
             SET  description = DECODE( p_Item_Revision_rec.description, G_Miss_Char, description, --Bug: 3055810 replaced NULL with G_Miss_Char
                                        p_Item_Revision_rec.description)
                  , last_updated_by    = G_User_Id
                  , last_update_date   = l_sysdate
                 WHERE  revision_id = G_revision_id
                   AND  LANGUAGE = G_language_code;

   --
   -- Initiate the revision entry in pending item status table which will maintain
   -- the period for each lifecycle phase
   --
   IF l_lifecycle_id IS NOT NULL AND
      l_orig_lifecycle_id IS NULL THEN

     INSERT INTO mtl_pending_item_status
                (  Inventory_Item_Id
                 , Organization_Id
                 , Status_code
                 , Effective_date
                 , Implemented_date
                 , Pending_flag
                 , Revision_Id
                 , lifecycle_id
                 , phase_id
                 , Created_By
                 , Creation_Date
                 , Last_Updated_By
                 , Last_Update_Date
                 , Last_Update_Login
                 )
                VALUES
                (  p_Item_Revision_rec.Inventory_Item_Id
                 , p_Item_Revision_rec.Organization_Id
                 , NULL
                 , l_sysdate
                 , l_sysdate
                 , 'N'
                 , G_revision_id
                 , l_lifecycle_id
                 , l_current_phase_id
                 , G_User_Id
                 , l_sysdate
                 , G_User_Id
                 , l_sysdate
                 , G_Login_Id
                 );
   END IF;



   /* R12: Business Event Enhancement :
   Raise Event if Revision got Updated successfully */

   IF (INSTR(NVL(p_process_control,'PLM_UI:N'),'PLM_UI:Y') = 0 ) THEN

       -- Start 5208102: Supporting template for UDA's at revisions
   IF l_apply_template THEN
      Insert_Revision_UserAttr(p_organization_id   => p_Item_Revision_rec.Organization_Id
                              ,p_inventory_item_id => p_Item_Revision_rec.inventory_item_id
                              ,p_revision_id       => G_revision_id
                              ,p_transaction_type  => 'UPDATE'
                              ,p_template_id       => l_template_id);
   END IF;
   -- End 5208102: Supporting template for UDA's at revisions

     -- Bug 5525054
     BEGIN
       INV_ITEM_EVENTS_PVT.Raise_Events(
          p_event_name    => 'EGO_WF_WRAPPER_PVT.G_REV_CHANGE_EVENT'
         ,p_dml_type      => 'UPDATE'
         ,p_inventory_item_id => p_Item_Revision_rec.Inventory_Item_Id
         ,p_organization_id   => p_Item_Revision_rec.Organization_Id
         ,p_revision_id       => p_Item_Revision_rec.revision_id);

       EXCEPTION
	 WHEN OTHERS THEN
	    NULL;
     END;
   END IF;
   /* R12: Business Event Enhancement :
   Raise Event if Revision got Updated successfully */


   -- Standard check of p_commit
   IF FND_API.To_Boolean (p_commit) THEN
      --INV_ITEM_MSG.Debug(Mctx, 'before COMMIT WORK');
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.

      IF G_Message_API = 'BOM' THEN
        x_msg_count := Error_Handler.Get_Message_Count;
      ELSE
        FND_MSG_PUB.Count_And_Get
        (  p_count  =>  x_msg_count
        ,  p_data   =>  x_msg_data
        );
	/*Bug 6853558 Added to get the message if count is > 1 */
 	IF( x_msg_count > 1 ) THEN
 	  x_msg_data := fnd_msg_pub.get( x_msg_count,FND_API.G_FALSE);
 	END IF;
      END IF;

EXCEPTION

   WHEN FND_API.g_EXC_ERROR THEN

      ROLLBACK TO Update_Item_Revision_PUB;
      x_return_status := FND_API.g_RET_STS_ERROR;

      IF G_Message_API = 'BOM' THEN
        x_msg_count := Error_Handler.Get_Message_Count;
      ELSE
        FND_MSG_PUB.Count_And_Get
        (  p_count  =>  x_msg_count
        ,  p_data   =>  x_msg_data
        );
	/*Bug 6853558 Added to get the message if count is > 1 */
 	IF( x_msg_count > 1 ) THEN
 	   x_msg_data := fnd_msg_pub.get(x_msg_count,FND_API.G_FALSE);
 	END IF;
      END IF;

   WHEN FND_API.g_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Update_Item_Revision_PUB;
      x_return_status := FND_API.g_RET_STS_UNEXP_ERROR;

      IF G_Message_API = 'BOM' THEN
        x_msg_count := Error_Handler.Get_Message_Count;
      ELSE
        FND_MSG_PUB.Count_And_Get
        (  p_count  =>  x_msg_count
        ,  p_data   =>  x_msg_data
        );
	/*Bug 6853558 Added to get the message if count is > 1 */
 	IF( x_msg_count > 1 ) THEN
 	    x_msg_data := fnd_msg_pub.get(x_msg_count,FND_API.G_FALSE);
 	END IF;
      END IF;

   WHEN others THEN

      ROLLBACK TO Update_Item_Revision_PUB;
      x_return_status := FND_API.g_RET_STS_UNEXP_ERROR;

      Add_Message
         ( p_api_name           =>  l_api_name
           , p_message_text       =>  'UNEXP_ERROR : ' || SQLERRM
         );

      IF G_Message_API = 'BOM' THEN
        x_msg_count := Error_Handler.Get_Message_Count;
      ELSE
        FND_MSG_PUB.Count_And_Get
        (  p_count  =>  x_msg_count
        ,  p_data   =>  x_msg_data
        );
	/**Bug 6853558 Added to get the message if count is > 1 */
 	IF( x_msg_count > 1 ) THEN
 	                 x_msg_data := fnd_msg_pub.get(x_msg_count,FND_API.G_FALSE);
 	END IF;
      END IF;

END Update_Item_Revision;


--  ============================================================================
--  API Name:           Lock_Item_Revision
--  ============================================================================

PROCEDURE Lock_Item_Revision
(
   p_api_version             IN   NUMBER
,  p_init_msg_list           IN   VARCHAR2   :=  FND_API.g_FALSE
,  x_return_status           OUT  NOCOPY VARCHAR2
,  x_msg_count               OUT  NOCOPY NUMBER
,  x_msg_data                OUT  NOCOPY VARCHAR2
,  p_inventory_item_id       IN   NUMBER
,  p_organization_id         IN   NUMBER
,  p_revision                IN   VARCHAR2
,  p_object_version_number   IN   NUMBER
)
IS
   l_api_name        CONSTANT  VARCHAR2(30)  :=  'Lock_Item_Revision';
   l_api_version     CONSTANT  NUMBER        :=  1.0;
--   Mctx              INV_ITEM_MSG.Msg_Ctx_type;

   l_return_status            VARCHAR2(1);
   l_object_version_number    NUMBER;

   CURSOR Item_Revision_Lock_cur
   (  p_inventory_item_id    NUMBER
   ,  p_organization_id      NUMBER
   ,  p_revision             VARCHAR2
   ) IS
      SELECT  object_version_number
      FROM  mtl_item_revisions_b
      WHERE
              inventory_item_id = p_inventory_item_id
         AND  organization_id   = p_organization_id
         AND  revision          = p_revision
      FOR UPDATE NOWAIT;

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT Lock_Item_Revision_PUB;

   -- Check for call compatibility
   IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                       l_api_name, G_PKG_NAME)
   THEN
      RAISE FND_API.g_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list
   IF G_Message_API = 'FND' THEN
     IF FND_API.To_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
     END IF;
   END IF;

   -- Define message context
--   Mctx.Package_Name   := G_PKG_NAME;
--   Mctx.Procedure_Name := l_api_name;

   -- Initialize API return status to success
   x_return_status := FND_API.g_RET_STS_SUCCESS;

   -- ----------------------------------------------
   -- Check if revision exists, and lock the record
   -- ----------------------------------------------

   OPEN Item_Revision_Lock_cur ( p_inventory_item_id
                               , p_organization_id
                               , p_revision );

   FETCH Item_Revision_Lock_cur INTO l_object_version_number;

   IF ( Item_Revision_Lock_cur%NOTFOUND ) THEN
      CLOSE Item_Revision_Lock_cur;
      Add_Message ('INV', 'INV_ITM_REVISION_REC_DELETED');
      RAISE FND_API.g_EXC_ERROR;
   END IF;

   CLOSE Item_Revision_Lock_cur;

   -- -------------------------------------
   -- Check if revision record has changed
   -- -------------------------------------

   IF ( nvl(l_object_version_number,0) <> nvl(p_object_version_number,0) ) THEN
      Add_Message ('INV', 'INV_ITM_REVISION_REC_CHANGED');
      RAISE FND_API.g_EXC_ERROR;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.

      IF G_Message_API = 'BOM' THEN
        x_msg_count := Error_Handler.Get_Message_Count;
      ELSE
        FND_MSG_PUB.Count_And_Get
        (  p_count  =>  x_msg_count
        ,  p_data   =>  x_msg_data
        );
	/*Bug 6853558 Added to get the message if count is > 1 */
 	IF( x_msg_count > 1 ) THEN
 	   x_msg_data := fnd_msg_pub.get(x_msg_count,FND_API.G_FALSE);
 	END IF;
      END IF;

EXCEPTION

   WHEN FND_API.g_EXC_ERROR THEN

      ROLLBACK TO Lock_Item_Revision_PUB;
      x_return_status := FND_API.g_RET_STS_ERROR;

      IF G_Message_API = 'BOM' THEN
        x_msg_count := Error_Handler.Get_Message_Count;
      ELSE
        FND_MSG_PUB.Count_And_Get
        (  p_count  =>  x_msg_count
        ,  p_data   =>  x_msg_data
        );
	/*Bug 6853558 Added to get the message if count is > 1 */
 	IF( x_msg_count > 1 ) THEN
 	    x_msg_data := fnd_msg_pub.get(x_msg_count,FND_API.G_FALSE);
 	END IF;
      END IF;

   WHEN FND_API.g_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Lock_Item_Revision_PUB;
      x_return_status := FND_API.g_RET_STS_UNEXP_ERROR;

      IF G_Message_API = 'BOM' THEN
        x_msg_count := Error_Handler.Get_Message_Count;
      ELSE
        FND_MSG_PUB.Count_And_Get
        (  p_count  =>  x_msg_count
        ,  p_data   =>  x_msg_data
        );
	/*Bug 6853558 Added to get the message if count is > 1 */
 	IF( x_msg_count > 1 ) THEN
 	   x_msg_data := fnd_msg_pub.get(x_msg_count,FND_API.G_FALSE);
 	END IF;
      END IF;

   WHEN others THEN

      ROLLBACK TO Lock_Item_Revision_PUB;
      x_return_status := FND_API.g_RET_STS_UNEXP_ERROR;

      Add_Message
         ( p_api_name           =>  l_api_name
           , p_message_text       =>  'UNEXP_ERROR : ' || SQLERRM
         );

      IF G_Message_API = 'BOM' THEN
        x_msg_count := Error_Handler.Get_Message_Count;
      ELSE
        FND_MSG_PUB.Count_And_Get
        (  p_count  =>  x_msg_count
        ,  p_data   =>  x_msg_data
        );
	 /*Bug 6853558 Added to get the message if count is > 1 */
 	 IF( x_msg_count > 1 ) THEN
 	    x_msg_data := fnd_msg_pub.get(x_msg_count,FND_API.G_FALSE);
 	 END IF;
      END IF;

END Lock_Item_Revision;


--  ============================================================================
--  API Name:           Delete_Item_Revision
--  ============================================================================

PROCEDURE Delete_Item_Revision
(
   p_api_version             IN   NUMBER
,  p_init_msg_list           IN   VARCHAR2   :=  FND_API.g_FALSE
,  p_commit                  IN   VARCHAR2   :=  FND_API.g_FALSE
,  p_validation_level        IN   NUMBER     :=  FND_API.g_VALID_LEVEL_FULL
,  x_return_status           OUT  NOCOPY VARCHAR2
,  x_msg_count               OUT  NOCOPY NUMBER
,  x_msg_data                OUT  NOCOPY VARCHAR2
,  p_inventory_item_id       IN   NUMBER
,  p_organization_id         IN   NUMBER
,  p_revision                IN   VARCHAR2
,  p_object_version_number   IN   NUMBER
)
IS
   l_api_name        CONSTANT  VARCHAR2(30)  :=  'Delete_Item_Revision';
   l_api_version     CONSTANT  NUMBER        :=  1.0;
--   Mctx              INV_ITEM_MSG.Msg_Ctx_type;

   l_return_status            VARCHAR2(1);
   l_object_version_number    NUMBER;

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT Delete_Item_Revision_PUB;

   -- Check for call compatibility
   IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                       l_api_name, G_PKG_NAME)
   THEN
      RAISE FND_API.g_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list
   IF G_Message_API = 'FND' THEN
     IF FND_API.To_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
     END IF;
   END IF;

   -- Define message context
--   Mctx.Package_Name   := G_PKG_NAME;
--   Mctx.Procedure_Name := l_api_name;

   -- Initialize API return status to success
   x_return_status := FND_API.g_RET_STS_SUCCESS;

   -- -------------------------
   -- Check if revision exists
   -- -------------------------

   OPEN Item_Revision_Exists_cur ( p_inventory_item_id
                                 , p_organization_id
                                 , p_revision );

   FETCH Item_Revision_Exists_cur INTO l_object_version_number;

   IF ( Item_Revision_Exists_cur%NOTFOUND ) THEN
      CLOSE Item_Revision_Exists_cur;
      Add_Message ('INV', 'INV_ITM_REVISION_REC_DELETED');
      RAISE FND_API.g_EXC_ERROR;
   END IF;

   CLOSE Item_Revision_Exists_cur;

   -- -------------------------------------
   -- Check if revision record has changed
   -- -------------------------------------

   IF ( l_object_version_number <> p_object_version_number ) THEN
      Add_Message ('INV', 'INV_ITM_REVISION_REC_CHANGED');
      RAISE FND_API.g_EXC_ERROR;
   END IF;

--dbms_output.put_line('DELETE FROM mtl_item_revisions; x_return_status = ' || x_return_status);

   DELETE FROM mtl_item_revisions_b
   WHERE
          inventory_item_id      =  p_inventory_item_id
      AND organization_id        =  p_organization_id
      AND revision               =  p_revision
      AND nvl(object_version_number,0)  =  nvl(p_object_version_number,0)
   RETURNING revision_id, object_version_number INTO G_revision_id, G_object_version_number;

   IF ( SQL%NOTFOUND ) THEN
      Add_Message ('INV', 'INV_ITM_REVISION_REC_CHANGED');
      RAISE FND_API.g_EXC_ERROR;
   END IF;

   --
   -- Remove the corresponding TL entries for this revision record
   -- from the TL table
   --
   DELETE FROM mtl_item_revisions_TL
   WHERE revision_id  =  G_revision_id;

   --
   -- Remove the corresponding entries from pending item status table
   --
   DELETE FROM mtl_pending_item_status
   WHERE inventory_item_id      =  p_inventory_item_id
      AND organization_id        =  p_organization_id
      AND revision_id            = G_revision_id;

--dbms_output.put_line('done DELETEing FROM mtl_item_revisions; x_return_status = ' || x_return_status);

   -- Standard check of p_commit
   IF FND_API.To_Boolean (p_commit) THEN
      --INV_ITEM_MSG.Debug(Mctx, 'before COMMIT WORK');
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.

      IF G_Message_API = 'BOM' THEN
        x_msg_count := Error_Handler.Get_Message_Count;
      ELSE
        FND_MSG_PUB.Count_And_Get
        (  p_count  =>  x_msg_count
        ,  p_data   =>  x_msg_data
        );
	/*Bug 6853558 Added to get the message if count is > 1 */
 	IF( x_msg_count > 1 ) THEN
 	   x_msg_data := fnd_msg_pub.get(x_msg_count,FND_API.G_FALSE);
 	END IF;
      END IF;

EXCEPTION

   WHEN FND_API.g_EXC_ERROR THEN

      ROLLBACK TO Delete_Item_Revision_PUB;
      x_return_status := FND_API.g_RET_STS_ERROR;

      IF G_Message_API = 'BOM' THEN
        x_msg_count := Error_Handler.Get_Message_Count;
      ELSE
        FND_MSG_PUB.Count_And_Get
        (  p_count  =>  x_msg_count
        ,  p_data   =>  x_msg_data
        );
	/*Bug 6853558 Added to get the message if count is > 1 */
 	IF( x_msg_count > 1 ) THEN
 	   x_msg_data := fnd_msg_pub.get(x_msg_count,FND_API.G_FALSE);
 	END IF;
      END IF;

   WHEN FND_API.g_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Delete_Item_Revision_PUB;
      x_return_status := FND_API.g_RET_STS_UNEXP_ERROR;

      IF G_Message_API = 'BOM' THEN
        x_msg_count := Error_Handler.Get_Message_Count;
      ELSE
        FND_MSG_PUB.Count_And_Get
        (  p_count  =>  x_msg_count
        ,  p_data   =>  x_msg_data
        );
	/*Bug 6853558 Added to get the message if count is > 1 */
 	IF( x_msg_count > 1 ) THEN
 	  x_msg_data := fnd_msg_pub.get(x_msg_count,FND_API.G_FALSE);
 	END IF;
      END IF;

   WHEN others THEN

      ROLLBACK TO Delete_Item_Revision_PUB;
      x_return_status := FND_API.g_RET_STS_UNEXP_ERROR;

      Add_Message
         ( p_api_name           =>  l_api_name
           , p_message_text       =>  'UNEXP_ERROR : ' || SQLERRM
         );

      IF G_Message_API = 'BOM' THEN
        x_msg_count := Error_Handler.Get_Message_Count;
      ELSE
        FND_MSG_PUB.Count_And_Get
        (  p_count  =>  x_msg_count
        ,  p_data   =>  x_msg_data
        );
	/*Bug 6853558 Added to get the message if count is > 1 */
 	IF( x_msg_count > 1 ) THEN
 	  x_msg_data := fnd_msg_pub.get(x_msg_count,FND_API.G_FALSE);
 	END IF;
      END IF;

END Delete_Item_Revision;

PROCEDURE Process_Item_Revision
(
   p_inventory_item_id            IN NUMBER
,  p_organization_id              IN NUMBER
,  p_revision                     IN VARCHAR2
,  p_description                  IN VARCHAR2 := NULL
,  p_change_notice                IN VARCHAR2 := NULL
,  p_ecn_initiation_date          IN DATE := NULL
,  p_implementation_date          IN DATE := NULL
,  p_effectivity_date             IN DATE := NULL
,  p_revised_item_sequence_id     IN NUMBER := NULL
,  p_attribute_category           IN VARCHAR2 := NULL
,  p_attribute1                   IN VARCHAR2 := NULL
,  p_attribute2                   IN VARCHAR2 := NULL
,  p_attribute3                   IN VARCHAR2 := NULL
,  p_attribute4                   IN VARCHAR2 := NULL
,  p_attribute5                   IN VARCHAR2 := NULL
,  p_attribute6                   IN VARCHAR2 := NULL
,  p_attribute7                   IN VARCHAR2 := NULL
,  p_attribute8                   IN VARCHAR2 := NULL
,  p_attribute9                   IN VARCHAR2 := NULL
,  p_attribute10                  IN VARCHAR2 := NULL
,  p_attribute11                  IN VARCHAR2 := NULL
,  p_attribute12                  IN VARCHAR2 := NULL
,  p_attribute13                  IN VARCHAR2 := NULL
,  p_attribute14                  IN VARCHAR2 := NULL
,  p_attribute15                  IN VARCHAR2 := NULL
,  p_object_version_number        IN NUMBER
,  p_revision_label               IN VARCHAR2 := NULL
,  p_revision_reason              IN VARCHAR2 := NULL
,  p_lifecycle_id                 IN NUMBER   := NULL
,  p_current_phase_id             IN NUMBER   := NULL
,  p_template_id                  IN NUMBER   := NULL --5208102
,  p_template_name                IN VARCHAR2 := NULL --5208102
,  p_language_code                IN VARCHAR2 := 'US'
,  p_transaction_type             IN VARCHAR2
,  p_message_api                  IN VARCHAR2 := 'FND'
,  p_init_msg_list                IN VARCHAR2 :=  FND_API.G_TRUE
,  x_Return_Status                OUT NOCOPY VARCHAR2
,  x_msg_count                    OUT NOCOPY NUMBER
,  x_msg_data                     OUT NOCOPY VARCHAR2 /*Added for bug 8679971 to ensure error message is returned back*/
,  x_revision_id                  IN OUT NOCOPY NUMBER
,  x_object_version_number        IN OUT NOCOPY NUMBER
,  p_debug                        IN  VARCHAR2 := 'N'
,  p_output_dir                   IN  VARCHAR2 := NULL
,  p_debug_filename               IN  VARCHAR2 := 'Ego_Item_Revision.log'
,  p_revision_id                  IN  NUMBER   := NULL
,  p_process_control              IN  VARCHAR2 := NULL
) IS

  l_item_revision_rec     Item_Revision_rec_type;
  l_object_version_number NUMBER;
  l_msg_data              VARCHAR2(2000);
  l_api_name    CONSTANT  VARCHAR2(30)  :=  'Process_Item_Revision';

  l_debug_return_status   VARCHAR2(1);
  l_debug_error_message   VARCHAR2(2000);

  l_inherit               NUMBER :=0;  -- Added for PIM for Telco enhancements
BEGIN
  -- Initialize the global variables

  G_revision_id           := NULL;
  G_object_version_number := NULL;
  G_language_code         := p_language_code;
  G_Message_API           := p_message_API;
  G_Sysdate               := SYSDATE;

   -- Initialize message list
   IF G_Message_API = 'BOM' THEN
     IF FND_API.To_Boolean (p_init_msg_list) THEN
       Error_Handler.Initialize;
       Error_Handler.Set_BO_Identifier ('INV_ITEM_REVISION');
     END IF;
   ELSE
     /* G_Message_API = 'FND' THEN */
     IF FND_API.To_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
     END IF;
   END IF;

   -- Open the debug session

   IF p_debug = 'Y' THEN

     Error_Handler.Set_Debug (p_debug_flag => 'Y');

     Error_Handler.Open_Debug_Session
        (  p_debug_filename     => p_debug_filename
         , p_output_dir         => p_output_dir
         , x_return_status      => l_debug_return_status
         , x_error_mesg         => l_debug_error_message
        );

     IF l_debug_return_status <> FND_API.g_RET_STS_SUCCESS THEN
       -- Debug fail information can be inserted into the error table
       Null;
     END IF;

   END IF;

   Error_Handler.Write_Debug('Debug file mode is '||Error_Handler.Get_Debug);

   Error_Handler.Write_Debug('Sysdate is '||to_char(G_sysdate,'DD-MON-YYYY HH24:MI:SS')||' Effectivity date is '||to_char(p_effectivity_date,'DD-MON-YYYY HH24:MI:SS'));

  -- Convert the transaction type if it is SYNC

  IF p_transaction_type = 'SYNC' THEN

    OPEN Item_Revision_Exists_cur ( p_inventory_item_id
                                 , p_organization_id
                                 , p_revision );

    FETCH Item_Revision_Exists_cur INTO l_object_version_number;

    IF ( Item_Revision_Exists_cur%FOUND ) THEN
      l_item_revision_rec.transaction_type := Bom_Globals.G_OPR_UPDATE;
    ELSE
      l_item_revision_rec.transaction_type := Bom_Globals.G_OPR_CREATE;
    END IF;

    CLOSE Item_Revision_Exists_cur;

  ELSE

    l_item_revision_rec.transaction_type := p_transaction_type;

  END IF;

  -- Validate the transaction type

  IF l_item_revision_rec.transaction_type NOT IN (Bom_Globals.G_OPR_CREATE,
                                Bom_Globals.G_OPR_UPDATE,
                                Bom_Globals.G_OPR_DELETE) THEN

    Add_Message ('INV', 'INV_INVALID_TRANS_TYPE');
    x_return_status := FND_API.g_RET_STS_UNEXP_ERROR;

    IF G_Message_API = 'BOM' THEN
      x_msg_count := Error_Handler.Get_Message_Count;
    ELSE
      FND_MSG_PUB.Count_And_Get
      (  p_count  =>  x_msg_count
      ,  p_data   =>  l_msg_data
      );
      /*Bug 6853558 Added to get the message if count is > 1 */
      IF( x_msg_count > 1 ) THEN
         l_msg_data := fnd_msg_pub.get(x_msg_count,FND_API.G_FALSE);
      END IF;
    END IF;

    IF Error_Handler.Get_Debug = 'Y' THEN
      Error_Handler.Close_Debug_Session;
    END IF;

    Return;

  END IF;

  IF l_item_revision_rec.transaction_type = Bom_Globals.G_OPR_CREATE
     AND p_revision_id IS NOT NULL THEN
     l_item_revision_rec.revision_id   := p_revision_id;
  END IF;

  -- Create the record structure from the individual parameters for CREATE and UPDATE
  IF l_item_revision_rec.transaction_type IN (Bom_Globals.G_OPR_CREATE,
                                Bom_Globals.G_OPR_UPDATE)
  THEN
    l_item_revision_rec.inventory_item_id        := p_inventory_item_id;
    l_item_revision_rec.organization_id          := p_organization_id;
    l_item_revision_rec.revision                 := p_revision;
    l_item_revision_rec.description              := p_description;
    l_item_revision_rec.change_notice            := p_change_notice;
    l_item_revision_rec.ecn_initiation_date      := p_ecn_initiation_date;
    l_item_revision_rec.implementation_date      := p_implementation_date;
    l_item_revision_rec.effectivity_date         := p_effectivity_date;
    l_item_revision_rec.revised_item_sequence_id := p_revised_item_sequence_id;
    l_item_revision_rec.attribute_category       := p_attribute_category;
    l_item_revision_rec.attribute1               := p_attribute1;
    l_item_revision_rec.attribute2               := p_attribute2;
    l_item_revision_rec.attribute3               := p_attribute3;
    l_item_revision_rec.attribute4               := p_attribute4;
    l_item_revision_rec.attribute5               := p_attribute5;
    l_item_revision_rec.attribute6               := p_attribute6;
    l_item_revision_rec.attribute7               := p_attribute7;
    l_item_revision_rec.attribute8               := p_attribute8;
    l_item_revision_rec.attribute9               := p_attribute9;
    l_item_revision_rec.attribute10              := p_attribute10;
    l_item_revision_rec.attribute11              := p_attribute11;
    l_item_revision_rec.attribute12              := p_attribute12;
    l_item_revision_rec.attribute13              := p_attribute13;
    l_item_revision_rec.attribute14              := p_attribute14;
    l_item_revision_rec.attribute15              := p_attribute15;
    l_item_revision_rec.object_version_number    := p_object_version_number;
    l_item_revision_rec.revision_label           := p_revision_label;
    l_item_revision_rec.revision_reason          := p_revision_reason;
--35557001
-- lifecycle can be null, for API compatability, change it to MISS_NUM
    l_item_revision_rec.lifecycle_id             := NVL(p_lifecycle_id,FND_API.G_MISS_NUM);
    l_item_revision_rec.current_phase_id         := NVL(p_current_phase_id,FND_API.G_MISS_NUM);

    -- 5208102: Supporting template for UDA's at revisions
    l_item_revision_rec.template_id              := p_template_id;
    l_item_revision_rec.template_name            := p_template_name;

  END IF;

  -- Call the appropriate procedure to carry out the transaction

  IF l_item_revision_rec.transaction_type = Bom_Globals.G_OPR_CREATE
  THEN

    --dbms_output.put_line('Calling Create ...');

    Create_Item_Revision
        (
           p_api_version             => 1.0
        ,  p_init_msg_list           => FND_API.G_TRUE
        ,  x_return_status           => x_return_status
        ,  x_msg_count               => x_msg_count
        ,  x_msg_data                => l_msg_data
        ,  p_Item_Revision_rec       => l_item_revision_rec
	,  p_process_control         => p_process_control
        );

  ELSIF l_item_revision_rec.transaction_type = Bom_Globals.G_OPR_UPDATE
  THEN

    --dbms_output.put_line('Calling Update ...');
    l_item_revision_rec.revision_id := p_revision_id;

    /* Added for PIM for Telco enhancements  */
    begin
        select 1
        into l_inherit
        from mtl_item_revisions_b
        where revision_id = p_revision_id
        and effectivity_date <> p_effectivity_date;
    exception
        when others then
            l_inherit :=0;
    end;

    Update_Item_Revision
        (
           p_api_version             => 1.0
        ,  p_init_msg_list           => FND_API.G_TRUE
        ,  x_return_status           => x_return_status
        ,  x_msg_count               => x_msg_count
        ,  x_msg_data                => l_msg_data
        ,  p_Item_Revision_rec       => l_item_revision_rec
	,  p_process_control         => p_process_control
        );

  ELSE

    --dbms_output.put_line('Calling Delete ...');

    Delete_Item_Revision
        (
           p_api_version             => 1.0
        ,  p_init_msg_list           => FND_API.G_TRUE
        ,  x_return_status           => x_return_status
        ,  x_msg_count               => x_msg_count
        ,  x_msg_data                => l_msg_data
        ,  p_inventory_item_id       => p_inventory_item_id
        ,  p_organization_id         => p_organization_id
        ,  p_revision                => p_revision
        ,  p_object_version_number   => p_object_version_number
        );
  END IF;

  -- Assign the values for remaining OUT variables

  x_revision_id := G_revision_id;
  x_object_version_number := G_object_version_number;

  /* call to this procedure will inherit Components of ICC structure
     to item structure. Added as part of PIM for Telco enhancements. */

  -- bug 8986750, save the msg before calling inherit_icc_components
  x_msg_data := l_msg_data;
  IF (l_item_revision_rec.transaction_type = Bom_Globals.G_OPR_CREATE or l_inherit =1) Then

      EGO_ICC_STRUCTURE_PVT.inherit_icc_components(
        p_inventory_item_id   => p_inventory_item_id,
        p_organization_id     => p_organization_id,
        p_revision_id         => p_revision_id,
        p_rev_date            => p_effectivity_date,
        x_Return_Status       => x_return_status,
        x_Error_Message       => l_msg_data);

        If x_Return_Status <> 0 Then
            x_msg_count :=  x_msg_count + 1;
            Add_Message ( p_message_text  => l_msg_data);
        End If;
        -- bug 8986750, append the msg of inherit_icc_components with prev msg
        l_msg_data := x_msg_data || '  ' || l_msg_data;
  End If;
  /* End of inherit components...  */

  IF Error_Handler.Get_Debug = 'Y' THEN
    Error_Handler.Close_Debug_Session;
  END IF;
  /*Changes made for bug 8679971. To ensure error message is returned back*/
   x_msg_data := l_msg_data;
  /*End of comment*/
  EXCEPTION WHEN OTHERS THEN

    x_return_status := FND_API.g_RET_STS_UNEXP_ERROR;

    Add_Message
         ( p_api_name           =>  l_api_name
           , p_message_text       =>  'UNEXP_ERROR : ' || SQLERRM
         );

    IF G_Message_API = 'BOM' THEN
      x_msg_count := Error_Handler.Get_Message_Count;
    ELSE
      FND_MSG_PUB.Count_And_Get
      (  p_count  =>  x_msg_count
      ,  p_data   =>  l_msg_data
      );
      /*Bug 6853558 Added to get the message if count is > 1 */
      IF( x_msg_count > 1 ) THEN
        l_msg_data := fnd_msg_pub.get(x_msg_count,FND_API.G_FALSE);
      END IF;
    END IF;

    IF Error_Handler.Get_Debug = 'Y' THEN
      Error_Handler.Close_Debug_Session;
    END IF;

    /*Changes made for bug 8646872. To ensure error message is returned back*/
    x_msg_data := l_msg_data;
    /*End of comment*/
END Process_Item_Revision;



END INV_ITEM_REVISION_PUB;

/
