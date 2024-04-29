--------------------------------------------------------
--  DDL for Package Body EGO_UPLOAD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_UPLOAD_PUB" AS
/* $Header: EGOPUPLB.pls 120.0 2006/05/26 12:45:55 srajapar noship $ */

-----------
-- private procedures
-----------
procedure code_debug(p_message IN VARCHAR2) IS
BEGIN
--  sri_debug(p_message);
  NULL;
END code_debug;


FUNCTION get_object_id RETURN NUMBER IS
  l_object_id NUMBER;
BEGIN
  SELECT object_id
  INTO l_object_id
  FROM FND_OBJECTS
  WHERE OBJ_NAME = 'EGO_ITEM';
  RETURN l_object_id;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;


PROCEDURE get_catalog_group_id (p_catalog_group     IN VARCHAR2
                               ,x_catalog_group_id OUT NOCOPY NUMBER
                               ) IS
BEGIN
  SELECT CATALOG_GROUP_ID
  INTO x_catalog_group_id
  from EGO_CATALOG_GROUPS_V
  where catalog_group = p_catalog_group;
EXCEPTION
  WHEN OTHERS THEN
    x_catalog_group_id := NULL;
END get_catalog_group_id;


PROCEDURE get_attr_group_id (p_attr_group_name  IN VARCHAR2
                            ,p_attr_group_type  IN VARCHAR2
                            ,x_attr_group_id   OUT NOCOPY NUMBER
                             ) IS
BEGIN
  SELECT attr_group_id
  INTO x_attr_group_id
  from ego_fnd_dsc_flx_ctx_ext
  WHERE descriptive_flexfield_name = p_attr_group_type
   AND  descriptive_flex_context_code = p_attr_group_name
   AND  application_id = 431;
EXCEPTION
  WHEN OTHERS THEN
    x_attr_group_id := NULL;
END get_attr_group_id;


PROCEDURE get_association_id (p_object_id           IN NUMBER
                             ,p_catalog_group_id    IN NUMBER
                             ,p_attr_group_id       IN NUMBER
                             ,x_association_id      OUT NOCOPY NUMBER
                             ) IS
BEGIN
  SELECT association_id
  INTO x_association_id
  FROM EGO_OBJ_AG_ASSOCS_B
  WHERE object_id = p_object_id
   AND  classification_code = TO_CHAR(p_catalog_group_id)
   AND  attr_group_id = p_attr_group_id;
EXCEPTION
  WHEN OTHERS THEN
    x_association_id := NULL;
END get_association_id;


PROCEDURE get_page_id (p_object_id           IN NUMBER
                      ,p_catalog_group_id    IN NUMBER
                      ,p_page_int_name       IN VARCHAR2
                      ,x_page_id            OUT NOCOPY NUMBER
                             ) IS
BEGIN
  SELECT page_id
  INTO x_page_id
  FROM EGO_PAGES_B
  WHERE object_id = p_object_id
   AND  classification_code = TO_CHAR(p_catalog_group_id)
   AND  internal_name = p_page_int_name;
EXCEPTION
  WHEN OTHERS THEN
    x_page_id := NULL;
END get_page_id;


PROCEDURE  get_page_entry (p_page_id           IN NUMBER
                          ,p_association_id    IN NUMBER
                          ,p_catalog_group_id  IN NUMBER
                          ,x_sequence         OUT NOCOPY NUMBER
                          ) IS
BEGIN
  SELECT sequence
  INTO    x_sequence
  FROM ego_page_entries_b
  WHERE page_id = p_page_id
   AND  association_id = p_association_id
   AND  classification_code = TO_CHAR(p_catalog_group_id);
EXCEPTION
  WHEN OTHERS THEN
    x_sequence := NULL;
END get_page_entry;


PROCEDURE createBaseAttributePages (p_catalog_group_id IN NUMBER
                                   ,x_return_status    OUT NOCOPY VARCHAR2
                                   ) IS
  l_object_id         NUMBER;
  l_data_level        VARCHAR2(20) := 'ITEM_LEVEL';
  l_application_id    NUMBER       := 431;
  l_attr_group_type   VARCHAR2(40) := 'EGO_MASTER_ITEMS';
  l_page_desc         VARCHAR2(80) := 'Auto-generated operational attribute page';
  l_page_id           NUMBER;
  l_association_id    NUMBER;
  l_pages_array       EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_page_entry_array  EGO_COL_NAME_VALUE_PAIR_ARRAY;
--  l_name_value_obj    EGO_COL_NAME_VALUE_PAIR_OBJ;
  l_return_status     VARCHAR2(1);
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(4000);

BEGIN
  l_object_id := get_object_id();
  for k in 1..2 LOOP
    IF K = 1 THEN
      l_pages_array := EGO_COL_NAME_VALUE_PAIR_ARRAY (
       EGO_COL_NAME_VALUE_PAIR_OBJ('10','Physical Attributes'),
       EGO_COL_NAME_VALUE_PAIR_OBJ('20','Sales and Order Management'),
       EGO_COL_NAME_VALUE_PAIR_OBJ('30','Planning'),
       EGO_COL_NAME_VALUE_PAIR_OBJ('40','Purchasing'),
       EGO_COL_NAME_VALUE_PAIR_OBJ('50','Inventory/WMS'),
       EGO_COL_NAME_VALUE_PAIR_OBJ('60','Manufacturing')
                                                  );
    ELSE
      l_pages_array := EGO_COL_NAME_VALUE_PAIR_ARRAY (
       EGO_COL_NAME_VALUE_PAIR_OBJ('70','Service')
                                                  );
    END IF;
    FOR i IN l_pages_array.FIRST .. l_pages_array.LAST LOOP
      sync_cat_item_pages (
        p_api_version      => 1.0
       ,p_commit           => 'F'
       ,p_catalog_group_id => p_catalog_group_id
       ,p_catalog_group    => NULL
       ,p_data_level       => l_data_level
       ,p_page_int_name    => l_pages_array(i).value
       ,p_name             => l_pages_array(i).value
       ,p_desc             => l_page_desc
       ,p_sequence         => l_pages_array(i).name
       ,x_page_id          => l_page_id
       ,x_return_status    => l_return_status
       ,x_msg_count        => l_msg_count
       ,x_msg_data         => l_msg_data
                          );
      IF l_pages_array(i).name = 10 THEN
        l_page_entry_array := EGO_COL_NAME_VALUE_PAIR_ARRAY (
             EGO_COL_NAME_VALUE_PAIR_OBJ('10','PhysicalAttributes')
                                                 );
      ELSIF l_pages_array(i).name = 20 THEN
        l_page_entry_array := EGO_COL_NAME_VALUE_PAIR_ARRAY (
             EGO_COL_NAME_VALUE_PAIR_OBJ('10','OrderManagement'),
             EGO_COL_NAME_VALUE_PAIR_OBJ('20','Invoicing'),
             EGO_COL_NAME_VALUE_PAIR_OBJ('30','WebOption')
                                                 );
      ELSIF l_pages_array(i).name = 30 THEN
        l_page_entry_array := EGO_COL_NAME_VALUE_PAIR_ARRAY (
             EGO_COL_NAME_VALUE_PAIR_OBJ('10','GeneralPlanning'),
             EGO_COL_NAME_VALUE_PAIR_OBJ('20','MPSMRPPlanning'),
             EGO_COL_NAME_VALUE_PAIR_OBJ('30','LeadTimes')
                                                 );
      ELSIF l_pages_array(i).name = 40 THEN
        l_page_entry_array := EGO_COL_NAME_VALUE_PAIR_ARRAY (
             EGO_COL_NAME_VALUE_PAIR_OBJ('10','Purchasing'),
             EGO_COL_NAME_VALUE_PAIR_OBJ('20','Receiving')
                                                 );
      ELSIF l_pages_array(i).name = 50 THEN
        l_page_entry_array := EGO_COL_NAME_VALUE_PAIR_ARRAY (
             EGO_COL_NAME_VALUE_PAIR_OBJ('10','Inventory')
                                                 );
      ELSIF l_pages_array(i).name = 60 THEN
        l_page_entry_array := EGO_COL_NAME_VALUE_PAIR_ARRAY (
             EGO_COL_NAME_VALUE_PAIR_OBJ('10','BillofMaterials'),
             EGO_COL_NAME_VALUE_PAIR_OBJ('20','Costing'),
             EGO_COL_NAME_VALUE_PAIR_OBJ('30','WorkInProgress'),
             EGO_COL_NAME_VALUE_PAIR_OBJ('40','ProcessManufacturing')
                                                 );
      ELSIF l_pages_array(i).name = 70 THEN
        l_page_entry_array := EGO_COL_NAME_VALUE_PAIR_ARRAY (
             EGO_COL_NAME_VALUE_PAIR_OBJ('10','AssetManagement'),
             EGO_COL_NAME_VALUE_PAIR_OBJ('20','Service')
                                                 );
      END IF;
      FOR j in l_page_entry_array.FIRST .. l_page_entry_array.LAST LOOP
        sync_cat_attr_grp_assoc (
              p_api_version        => 1.0
             ,p_commit             => 'F'
             ,p_catalog_group_id   => p_catalog_group_id
             ,p_catalog_group      => NULL
             ,p_data_level         => l_data_level
             ,p_attr_group_name    => l_page_entry_array(j).value
             ,p_attr_group_type    => l_attr_group_type
             ,p_enabled_flag       => 'Y'
             ,x_association_id     => l_association_id
             ,x_return_status      => l_return_status
             ,x_msg_count          => l_msg_count
             ,x_msg_data           => l_msg_data
                                 );
        sync_cat_item_page_entries (
              p_api_version           => 1.0
             ,p_commit                => 'F'
             ,p_catalog_group         => NULL
             ,p_page_id               => l_page_id
             ,p_page_int_name         => NULL
             ,p_attr_group_name       => NULL
             ,p_attr_group_type       => NULL
             ,p_sequence              => l_page_entry_array(j).name
             ,p_association_id        => l_association_id
             ,x_return_status         => l_return_status
             ,x_msg_count             => l_msg_count
             ,x_msg_data              => l_msg_data
                                 );
      END LOOP;
      l_page_entry_array := NULL;
    END LOOP;
    l_pages_array := NULL;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    code_debug('createBaseAttributePages raise EXCEPTION '||SQLERRM);

END createBaseAttributePages;

--------------------------------------------------------

Procedure Sync_Catalog_Group (
    p_api_version           IN  NUMBER
   ,p_commit                IN  VARCHAR2
   ,p_catalog_group         IN  VARCHAR2
   ,p_parent_catalog_group  IN  VARCHAR2
   ,p_description           IN  VARCHAR2
   ,p_template_name         IN  VARCHAR2
   ,p_creation_allowed      IN  VARCHAR2
   ,p_end_date              IN  DATE
   ,p_owner                 IN  VARCHAR2
   ,p_extra_params          IN  EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
   ,x_catalog_group_id      OUT  NOCOPY NUMBER
   ,x_return_status         OUT  NOCOPY VARCHAR2
   ,x_msg_count             OUT  NOCOPY NUMBER
   ,x_msg_data              OUT  NOCOPY VARCHAR2
                              ) IS
   l_user_id           NUMBER;
   l_party_id          NUMBER;
   l_language          VARCHAR2(30);
   l_transaction_type  VARCHAR2(30);
   l_catalog_name      VARCHAR2(100);
   l_catalog_group_id  NUMBER;
   l_errorcode         NUMBER;
   l_grant_guid        RAW(50);
BEGIN
  code_debug('Sync_Catalog_Group called with params ');
--  code_debug('Sync_Catalog_Group p_catalog_group: '||p_catalog_group||' p_parent_catalog_group '||p_parent_catalog_group);
--  code_debug('Sync_Catalog_Group p_description: '||p_description||' p_template_name '||p_template_name);
--  code_debug('Sync_Catalog_Group p_creation_allowed: '||p_creation_allowed||' p_end_date '||p_end_date);
--  code_debug('Sync_Catalog_Group p_owner: '||p_owner);
  -- mandatory param check
  -- check if the catalog group exists, if so, please update else create new
  -- if creating catalog category, then create roles as well
  BEGIN
    SELECT user_id, party_id
    INTO l_user_id, l_party_id
    from ego_user_v
    where user_name = DECODE(p_owner,EGO_ITEM_PUB.G_ALL_USERS_PARTY_TYPE,'MFG',p_owner);
    IF p_owner = EGO_ITEM_PUB.G_ALL_USERS_PARTY_TYPE THEN
      l_party_id := -1000;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      -- defaulting to MFG
      SELECT user_id, party_id
      INTO l_user_id, l_party_id
      from ego_user_v
      where user_name = 'MFG';
--      l_user_id := 1068;
--      l_party_id := 6530;
  END;
  get_catalog_group_id (p_catalog_group    => p_catalog_group
                       ,x_catalog_group_id => l_catalog_group_id
                       );
  IF l_catalog_group_id IS NULL THEN
    l_transaction_type := EGO_ITEM_PUB.G_TTYPE_CREATE;
  ELSE
    l_transaction_type := EGO_ITEM_PUB.G_TTYPE_UPDATE;
  END IF;
  l_language := USERENV ('LANG');
  code_debug('Sync_Catalog_Group calling EGO_ITEM_CATALOG_PUB.Process_Catalog_Group trans type '||l_transaction_type);
  EGO_ITEM_CATALOG_PUB.Process_Catalog_Group
        (  p_Catalog_Group_Name           => p_catalog_group
         , p_Parent_Catalog_Group_Name    => p_parent_catalog_group
--         , p_Catalog_Group_Id              IN  NUMBER           := NULL
--         , p_Parent_Catalog_Group_Id       IN  NUMBER           := NULL
         , p_Description                  => p_description
         , p_Item_Creation_Allowed_Flag   => p_creation_allowed
--         , p_Start_Effective_Date          IN  DATE             := NULL
         , p_Inactive_date               => p_end_date
--         , p_Enabled_Flag                  IN  VARCHAR2         := NULL
--         , p_Summary_Flag                  IN  VARCHAR2         := NULL
--         , p_segment1                      IN  VARCHAR2         := NULL
--         , p_segment2                      IN  VARCHAR2         := NULL
--         , p_segment3                      IN  VARCHAR2         := NULL
--         , p_segment4                      IN  VARCHAR2         := NULL
--         , p_segment5                      IN  VARCHAR2         := NULL
--         , p_segment6                      IN  VARCHAR2         := NULL
--         , p_segment7                      IN  VARCHAR2         := NULL
--         , p_segment8                      IN  VARCHAR2         := NULL
--         , p_segment9                      IN  VARCHAR2         := NULL
--         , p_segment10                     IN  VARCHAR2         := NULL
--         , p_segment11                     IN  VARCHAR2         := NULL
--         , p_segment12                     IN  VARCHAR2         := NULL
--         , p_segment13                     IN  VARCHAR2         := NULL
--         , p_segment14                     IN  VARCHAR2         := NULL
--         , p_segment15                     IN  VARCHAR2         := NULL
--         , p_segment16                     IN  VARCHAR2         := NULL
--         , p_segment17                     IN  VARCHAR2         := NULL
--         , p_segment18                     IN  VARCHAR2         := NULL
--         , p_segment19                     IN  VARCHAR2         := NULL
--         , p_segment20                     IN  VARCHAR2         := NULL
--         , Attribute_category              IN  VARCHAR2         := NULL
--         , Attribute1                      IN  VARCHAR2         := NULL
--         , Attribute2                      IN  VARCHAR2         := NULL
--         , Attribute3                      IN  VARCHAR2         := NULL
--         , Attribute4                      IN  VARCHAR2         := NULL
--         , Attribute5                      IN  VARCHAR2         := NULL
--         , Attribute6                      IN  VARCHAR2         := NULL
--         , Attribute7                      IN  VARCHAR2         := NULL
--         , Attribute8                      IN  VARCHAR2         := NULL
--         , Attribute9                      IN  VARCHAR2         := NULL
--         , Attribute10                     IN  VARCHAR2         := NULL
--         , Attribute11                     IN  VARCHAR2         := NULL
--         , Attribute12                     IN  VARCHAR2         := NULL
--         , Attribute13                     IN  VARCHAR2         := NULL
--         , Attribute14                     IN  VARCHAR2         := NULL
--         , Attribute15                     IN  VARCHAR2         := NULL
         , p_User_id                       => l_user_id
         , p_Language_Code                 => l_language
         , p_Transaction_Type              => l_transaction_type
         , x_Return_Status                 => x_return_status
         , x_msg_count                     => x_msg_count
--         , p_debug                         IN  VARCHAR2 := 'N'
--         , p_output_dir                    IN  VARCHAR2 := NULL
--         , p_debug_filename                IN  VARCHAR2 := 'Ego_Catalog_Grp.log'
         , x_catalog_group_id              => x_catalog_group_id
         , x_catalog_group_name            => l_catalog_name
        );
--  code_debug('Sync_Catalog_Group returning EGO_ITEM_CATALOG_PUB.Process_Catalog_Group with status '||x_Return_Status);
  x_catalog_group_id := NVL(x_catalog_group_id, l_catalog_group_id);
  x_return_status := NVL(x_return_status,EGO_ITEM_PUB.G_RET_STS_SUCCESS);
  IF x_return_status = EGO_ITEM_PUB.G_RET_STS_SUCCESS AND
    l_transaction_type = EGO_ITEM_PUB.G_TTYPE_CREATE  THEN
    IF p_parent_catalog_group IS NULL THEN
      createBaseAttributePages(p_catalog_group_id => x_catalog_group_id
                              ,x_return_status    => x_return_status
                              );
    END IF;
    EGO_SECURITY_PUB.grant_role_guid(
              p_api_version        => p_api_version
            , p_role_name          => 'EGO_CATALOG_GROUP_USER'
            , p_object_name        => 'EGO_CATALOG_GROUP'
            , p_instance_type      => EGO_ITEM_PUB.G_INSTANCE_TYPE_INSTANCE
            , p_instance_set_id    => NULL
            , p_instance_pk1_value => x_catalog_group_id
            , p_instance_pk2_value => NULL
            , p_instance_pk3_value => NULL
            , p_instance_pk4_value => NULL
            , p_instance_pk5_value => NULL
            , p_party_id           => l_party_id
            , p_start_date         => NULL
            , p_end_date           => NULL
            , x_return_status      => x_return_status
            , x_errorcode          => l_errorcode
            , x_grant_guid         => l_grant_guid
                 );
    IF FND_API.TO_BOOLEAN(x_return_status) THEN
      x_return_status := EGO_ITEM_PUB.G_RET_STS_SUCCESS;
    ELSE
      x_return_status := EGO_ITEM_PUB.G_RET_STS_ERROR;
    END IF;
  END IF;
  IF FND_API.TO_BOOLEAN(p_commit) AND
     x_return_status = EGO_ITEM_PUB.G_RET_STS_SUCCESS THEN
    COMMIT WORK;
  END IF;
--  code_debug('Sync_Catalog_Group returning with status '||x_return_status);
EXCEPTION
  WHEN OTHERS THEN
    code_debug('Sync_Catalog_Group returning EXCEPTION '||SQLERRM);
    x_return_status := EGO_ITEM_PUB.G_RET_STS_UNEXP_ERROR;
    x_msg_data := SQLERRM;
END Sync_Catalog_Group;

--------------------------------------------------------
PROCEDURE sync_cat_attr_grp_assoc (
    p_api_version           IN  NUMBER
   ,p_commit                IN  VARCHAR2
   ,p_catalog_group_id      IN  NUMBER
   ,p_catalog_group         IN  VARCHAR2
   ,p_data_level            IN  VARCHAR2
   ,p_attr_group_name       IN  VARCHAR2
   ,p_attr_group_type       IN  VARCHAR2
   ,p_enabled_flag          IN  VARCHAR2
   ,p_extra_params          IN  EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
   ,x_association_id        OUT  NOCOPY NUMBER
   ,x_return_status         OUT  NOCOPY VARCHAR2
   ,x_msg_count             OUT  NOCOPY NUMBER
   ,x_msg_data              OUT  NOCOPY VARCHAR2
   ) IS
   l_catalog_group_id   NUMBER;
   l_attr_group_id      NUMBER;
   l_object_id          NUMBER;
   l_association_id     NUMBER;
   l_errorcode          NUMBER;
BEGIN
--  code_debug('sync_cat_attr_grp_assoc called with params p_attr_group_name '||p_attr_group_name);
  IF p_catalog_group_id IS NULL THEN
    get_catalog_group_id (p_catalog_group    => p_catalog_group
                         ,x_catalog_group_id => l_catalog_group_id
                         );
  ELSE
    l_catalog_group_id := p_catalog_group_id;
  END IF;
  IF l_catalog_group_id IS NULL THEN
    x_return_status := EGO_ITEM_PUB.G_RET_STS_ERROR;
    x_msg_data := 'sync_cat_attr_grp_assoc Catalog Category does not exist for '||p_catalog_group;
    RETURN;
  END IF;
  get_attr_group_id (p_attr_group_name  => p_attr_group_name
                    ,p_attr_group_type  => p_attr_group_type
                    ,x_attr_group_id    => l_attr_group_id
                    );
  IF l_attr_group_id IS NULL THEN
    x_return_status := EGO_ITEM_PUB.G_RET_STS_ERROR;
    x_msg_data := 'sync_cat_attr_grp_assoc attr group does not exist for '||p_attr_group_name;
    RETURN;
  END IF;
  l_object_id := get_object_id ();
  get_association_id (p_object_id           => l_object_id
                     ,p_catalog_group_id    => l_catalog_group_id
                     ,p_attr_group_id       => l_attr_group_id
                     ,x_association_id      => x_association_id
                     );
  IF x_association_id IS NULL THEN
    EGO_EXT_FWK_PUB.Create_Association (
        p_api_version             => p_api_version
       ,p_association_id          => NULL
       ,p_object_id               => l_object_id
       ,p_classification_code     => TO_CHAR(l_catalog_group_id)
       ,p_data_level              => p_data_level
       ,p_attr_group_id           => l_attr_group_id
       ,p_enabled_flag            => p_enabled_flag
       ,p_view_privilege_id       => NULL    --ignored for now
       ,p_edit_privilege_id       => NULL     --ignored for now
--       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                  => p_commit
       ,x_association_id          => x_association_id
       ,x_return_status           => x_return_status
       ,x_errorcode               => l_errorcode
       ,x_msg_count               => x_msg_count
       ,x_msg_data                => x_msg_data
       );
  ELSE
    EGO_EXT_FWK_PUB. Update_Association (
        p_api_version            => p_api_version
       ,p_association_id         => x_association_id
       ,p_enabled_flag           => p_enabled_flag
       ,p_view_privilege_id      => NULL    --ignored for now
       ,p_edit_privilege_id      => NULL     --ignored for now
--       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                  => p_commit
       ,x_return_status           => x_return_status
       ,x_errorcode               => l_errorcode
       ,x_msg_count               => x_msg_count
       ,x_msg_data                => x_msg_data
       );
  END IF;
  x_return_status := NVL(x_return_status,EGO_ITEM_PUB.G_RET_STS_SUCCESS);
--  code_debug('sync_cat_attr_grp_assoc returning with status '||x_return_status);

EXCEPTION
  WHEN OTHERS THEN
    code_debug('sync_cat_attr_grp_assoc returning EXCEPTION '||SQLERRM);
    x_return_status := EGO_ITEM_PUB.G_RET_STS_UNEXP_ERROR;
    x_msg_data := SQLERRM;
END sync_cat_attr_grp_assoc;

--------------------------------------------------------
PROCEDURE sync_cat_item_pages (
    p_api_version           IN  NUMBER
   ,p_commit                IN  VARCHAR2
   ,p_catalog_group_id      IN  NUMBER
   ,p_catalog_group         IN  VARCHAR2
   ,p_data_level            IN  VARCHAR2
   ,p_page_int_name         IN  VARCHAR2
   ,p_name                  IN  VARCHAR2
   ,p_desc                  IN  VARCHAR2
   ,p_sequence              IN  NUMBER
   ,p_extra_params          IN  EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
   ,x_page_id               OUT  NOCOPY NUMBER
   ,x_return_status         OUT  NOCOPY VARCHAR2
   ,x_msg_count             OUT  NOCOPY NUMBER
   ,x_msg_data              OUT  NOCOPY VARCHAR2
   ) IS
   l_catalog_group_id   NUMBER;
   l_attr_group_id      NUMBER;
   l_object_id          NUMBER;
   l_errorcode          NUMBER;
BEGIN
--  code_debug('sync_cat_item_pages called with params p_page_int_name '||p_page_int_name);
  IF p_catalog_group_id IS NULL THEN
    get_catalog_group_id (p_catalog_group    => p_catalog_group
                         ,x_catalog_group_id => l_catalog_group_id
                         );
  ELSE
    l_catalog_group_id := p_catalog_group_id;
  END IF;
  IF l_catalog_group_id IS NULL THEN
    x_return_status := EGO_ITEM_PUB.G_RET_STS_ERROR;
    x_msg_data := 'sync_cat_item_pages Catalog Category does not exist for '||p_catalog_group;
    RETURN;
  END IF;
  l_object_id := get_object_id();
  get_page_id (p_object_id           => l_object_id
              ,p_catalog_group_id    => l_catalog_group_id
              ,p_page_int_name       => p_page_int_name
              ,x_page_id             => x_page_id
              );
  IF x_page_id IS NULL THEN
    EGO_EXT_FWK_PUB.Create_Page (
        p_api_version             => p_api_version
       ,p_page_id                 => NULL
       ,p_object_id               => l_object_id
       ,p_classification_code     => TO_CHAR(l_catalog_group_id)
       ,p_data_level              => p_data_level
       ,p_internal_name           => p_page_int_name
       ,p_display_name            => p_name
       ,p_description             => p_desc
       ,p_sequence                => p_sequence
--       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                  => p_commit
       ,x_page_id                 => x_page_id
       ,x_return_status           => x_return_status
       ,x_errorcode               => l_errorcode
       ,x_msg_count               => x_msg_count
       ,x_msg_data                => x_msg_data
       );
  ELSE
    EGO_EXT_FWK_PUB.Update_Page (
        p_api_version             => p_api_version
       ,p_page_id                 => x_page_id
       ,p_internal_name           => p_page_int_name
       ,p_display_name            => p_name
       ,p_description             => p_desc
       ,p_sequence                => p_sequence
--       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                  => p_commit
--       ,p_is_nls_mode                   IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_return_status           => x_return_status
       ,x_errorcode               => l_errorcode
       ,x_msg_count               => x_msg_count
       ,x_msg_data                => x_msg_data
       );
  END IF;
  x_return_status := NVL(x_return_status,EGO_ITEM_PUB.G_RET_STS_SUCCESS);
EXCEPTION
  WHEN OTHERS THEN
    code_debug('sync_cat_item_pages returning EXCEPTION '||SQLERRM);
    x_return_status := EGO_ITEM_PUB.G_RET_STS_UNEXP_ERROR;
    x_msg_data := SQLERRM;
END sync_cat_item_pages;

--------------------------------------------------------
PROCEDURE sync_cat_item_page_entries (
    p_api_version           IN  NUMBER
   ,p_commit                IN  VARCHAR2
   ,p_catalog_group         IN  VARCHAR2
   ,p_page_id               IN  NUMBER
   ,p_page_int_name         IN  VARCHAR2
   ,p_attr_group_name       IN  VARCHAR2
   ,p_attr_group_type       IN  VARCHAR2
   ,p_sequence              IN  NUMBER
   ,p_association_id        IN  NUMBER
   ,p_extra_params          IN  EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
   ,x_return_status         OUT  NOCOPY VARCHAR2
   ,x_msg_count             OUT  NOCOPY NUMBER
   ,x_msg_data              OUT  NOCOPY VARCHAR2
   ) IS
   l_catalog_group_id   NUMBER;
   l_attr_group_id      NUMBER;
   l_object_id          NUMBER;
   l_association_id     NUMBER;
   l_page_id            NUMBER;
   l_errorcode          NUMBER;
   l_sequence           NUMBER;
BEGIN
--  code_debug('sync_cat_item_page_entries called with params p_catalog_group '||p_catalog_group||' p_page_int_name '||p_page_int_name||' p_attr_group_name '||p_attr_group_name);
  IF p_association_id IS NULL THEN
    get_catalog_group_id (p_catalog_group    => p_catalog_group
                         ,x_catalog_group_id => l_catalog_group_id
                         );
    IF l_catalog_group_id IS NULL THEN
      x_return_status := EGO_ITEM_PUB.G_RET_STS_ERROR;
      x_msg_data := 'sync_cat_item_page_entries Catalog Category does not exist for '||p_catalog_group;
      RETURN;
    END IF;
    get_attr_group_id (p_attr_group_name  => p_attr_group_name
                      ,p_attr_group_type  => p_attr_group_type
                      ,x_attr_group_id    => l_attr_group_id
                      );
    IF l_attr_group_id IS NULL THEN
      x_return_status := EGO_ITEM_PUB.G_RET_STS_ERROR;
      x_msg_data := 'sync_cat_item_page_entries attr group does not exist for '||p_attr_group_name;
      RETURN;
    END IF;
    l_object_id := get_object_id ();
    get_association_id (p_object_id           => l_object_id
                       ,p_catalog_group_id    => l_catalog_group_id
                       ,p_attr_group_id       => l_attr_group_id
                       ,x_association_id      => l_association_id
                       );
  ELSE
    l_association_id := p_association_id;
  END IF;
  IF l_association_id IS NULL THEN
    x_return_status := EGO_ITEM_PUB.G_RET_STS_ERROR;
    x_msg_data := 'sync_cat_item_page_entries association id does not exist for '||l_attr_group_id;
    RETURN;
  END IF;
  IF p_page_id IS NULL THEN
    get_page_id (p_object_id           => l_object_id
                ,p_catalog_group_id    => l_catalog_group_id
                ,p_page_int_name       => p_page_int_name
                ,x_page_id             => l_page_id
                );
  ELSE
    l_page_id := p_page_id;
  END IF;
  IF l_page_id IS NULL THEN
    x_return_status := EGO_ITEM_PUB.G_RET_STS_ERROR;
    x_msg_data := 'sync_cat_item_page_entries page id does not exist for '||p_page_int_name;
    RETURN;
  END IF;

  get_page_entry (p_page_id          => l_page_id
                 ,p_association_id   => l_association_id
                 ,p_catalog_group_id => l_catalog_group_id
                 ,x_sequence         => l_sequence
                 );
  IF l_sequence IS NULL THEN
    -- sequence is ready to be allocated
    EGO_EXT_FWK_PUB.Create_Page_Entry (
        p_api_version             => p_api_version
       ,p_page_id                 => l_page_id
       ,p_association_id          => l_association_id
       ,p_sequence                => p_sequence
       ,p_classification_code     => TO_CHAR(l_catalog_group_id)
--       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                  => p_commit
       ,x_return_status           => x_return_status
       ,x_errorcode               => l_errorcode
       ,x_msg_count               => x_msg_count
       ,x_msg_data                => x_msg_data
       );
  ELSIF l_sequence = p_sequence THEN
    -- nothing needs to be done
    NULL;
  ELSE
    -- sequence must be updated
    EGO_EXT_FWK_PUB.Update_Page_Entry (
        p_api_version             => p_api_version
       ,p_page_id                 => l_page_id
       ,p_new_association_id      => l_association_id
       ,p_old_association_id      => l_association_id
       ,p_sequence                => p_sequence
--       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                  => p_commit
       ,x_return_status           => x_return_status
       ,x_errorcode               => l_errorcode
       ,x_msg_count               => x_msg_count
       ,x_msg_data                => x_msg_data
       );
  END IF;
  x_return_status := NVL(x_return_status,EGO_ITEM_PUB.G_RET_STS_SUCCESS);
EXCEPTION
  WHEN OTHERS THEN
    code_debug('sync_cat_item_page_entries returning EXCEPTION '||SQLERRM);
    x_return_status := EGO_ITEM_PUB.G_RET_STS_UNEXP_ERROR;
    x_msg_data := SQLERRM;
END sync_cat_item_page_entries;


END EGO_UPLOAD_PUB;

/
