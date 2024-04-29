--------------------------------------------------------
--  DDL for Package Body PRP_IBC_MIGRATION_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PRP_IBC_MIGRATION_INT" AS
/* $Header: PRPVMIBB.pls 115.2 2003/10/22 23:22:25 hekkiral noship $ */

G_PKG_NAME          CONSTANT VARCHAR2(30):='PRP_IBC_MIGRATION_INT';
G_FILE_NAME         CONSTANT VARCHAR2(12):='PRPVMIBB.pls';

--------------------------------------
  -- Local Procedure to log messages
--------------------------------------
  PROCEDURE Log_Message
    (
     pi_migration_code    VARCHAR2,
     pi_module_name       VARCHAR2,
     pi_log_level         VARCHAR2,
     pi_message_text      VARCHAR2
    )
  IS
  BEGIN


    PRP_MIGRATION_PVT.Log_Message
      (
      p_api_version                    => 1.0,
      p_init_msg_list                  => FND_API.G_TRUE,
      p_commit                         => FND_API.G_FALSE,
      p_validation_level               => FND_API.G_VALID_LEVEL_FULL,
      p_module_name                    => pi_module_name,
      p_log_level                      => pi_log_level,
      p_message_text                   => pi_message_text,
      p_migration_code                 => pi_migration_code,
      p_created_by                     => FND_GLOBAL.user_id,
      p_creation_date                  => sysdate,
      p_last_updated_by                => FND_GLOBAL.user_id,
      p_last_update_date               => sysdate,
      p_last_update_login              => FND_GLOBAL.login_id
      );

  END;

/****************************************************************
 * Procedure Name: CREATE_CONTENT                               *
 *                                                              *
 *                                                              *
 ****************************************************************/

PROCEDURE CREATE_CONTENT(
                         p_api_version                 IN  NUMBER,
                         p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE,
                         p_component_style_id          IN  NUMBER,
                         p_base_language               IN  VARCHAR2,
                         p_file_id                     IN  NUMBER,
                         p_comp_style_ctntver_id       IN  NUMBER,
                         px_content_item_id            IN  OUT NOCOPY NUMBER,
                         px_object_version_number      IN  OUT NOCOPY NUMBER,
                         x_citem_ver_id                OUT NOCOPY NUMBER,
                         x_return_status               OUT NOCOPY VARCHAR2,
                         x_msg_count                   OUT NOCOPY NUMBER,
                         x_msg_data                    OUT NOCOPY VARCHAR2) IS

l_content_item_id           NUMBER;
l_object_version_number     NUMBER;
l_citem_ver_id              NUMBER;
l_return_status             VARCHAR2(30);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(2000);
l_api_name                  CONSTANT VARCHAR2(30) := 'CREATE_CONTENT';
l_api_version               CONSTANT NUMBER := 1;
l_module_name               CONSTANT VARCHAR2(256) := 'PLSQL.PRP.PRP_IBC_MIGRATION_INT.CREATE_CONTENT';
l_migration_code            CONSTANT VARCHAR2(30) := 'PRP_COMP_OCM_MIGRATION';

Begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Begin Standard Section

      SAVEPOINT svpt_create_content;
      IF (p_init_msg_list = FND_API.g_true) THEN
        FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
            l_api_version
           ,p_api_version
           ,l_api_name
           ,G_PKG_NAME
      )THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
-- End Standard Section

 IF px_content_item_id is not null THEN
    l_content_item_id := px_content_item_id;
 END IF;

 IF px_object_version_number is not null THEN
    l_object_version_number := px_object_version_number;
 END IF;

  -- Create Content Item.
  IBC_CITEM_ADMIN_GRP.upsert_item_full(
             p_ctype_code                => 'IBC_FILE'
            ,p_citem_name               => p_component_style_id
            ,p_citem_description        => null
            ,p_dir_node_id              => 43
            ,p_owner_resource_id        => NULL
            ,p_owner_resource_type      => NULL
            ,p_reference_code           => NULL
            ,p_trans_required           => FND_API.g_true -- Translation required.
            ,p_parent_item_id           => NULL
            ,p_lock_flag                => FND_API.g_false
            ,p_wd_restricted            => FND_API.g_true
            ,p_start_date               => NULL
            ,p_end_date                 => NULL
            ,p_attribute_type_codes     => NULL
            ,p_attributes               => NULL
            ,p_attach_file_id           => p_file_id
            ,p_component_citems         => NULL
            ,p_component_atypes         => NULL
            ,p_sort_order               => NULL
            ,p_status                   => IBC_UTILITIES_PUB.G_STV_WORK_IN_PROGRESS
            ,p_log_action               => FND_API.g_true
            ,p_language                 => p_base_language
            ,p_update                   => FND_API.g_true
            ,p_commit                   => FND_API.g_false
            ,p_api_version_number       => IBC_CITEM_ADMIN_GRP.G_API_VERSION_DEFAULT
            ,p_init_msg_list            => FND_API.g_true
            ,px_content_item_id         => l_content_item_id
            ,px_object_version_number   => l_object_version_number
            ,px_citem_ver_id            => l_citem_ver_id
            ,x_return_status            => l_return_status
            ,x_msg_count                => l_msg_count
            ,x_msg_data                 => l_msg_data
          );

   IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
       FND_MESSAGE.Set_Name('PRP', 'PRP_MG_API_RETURN_ERR');
       FND_MESSAGE.Set_Token('API', 'IBC_CITEM_ADMIN_GRP.UPSERT_ITEM_FULL');
       FND_MESSAGE.Set_Token('PROC', 'PRP_IBC_MIGRATION_INT.CREATE_CONTENT');
       Log_Message(
             pi_migration_code    => l_migration_code
            ,pi_module_name       => l_module_name
            ,pi_log_level         => 'I'
            ,pi_message_text      => FND_MESSAGE.get ||' '|| l_msg_data);
      RAISE FND_API.G_EXC_ERROR;
   END IF;


   /* Approve Item */

   IBC_CITEM_ADMIN_GRP.APPROVE_ITEM(
           p_citem_ver_id               => l_citem_ver_id
          ,p_commit                     => FND_API.g_false
          ,p_api_version_number         => IBC_CITEM_ADMIN_GRP.G_API_VERSION_DEFAULT
          ,p_init_msg_list              => FND_API.g_true
          ,px_object_version_number     => l_object_version_number
          ,x_return_status              => l_return_status
          ,x_msg_count                  => l_msg_count
          ,x_msg_data                   => l_msg_data
          );


   IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
       FND_MESSAGE.Set_Name('PRP', 'PRP_MG_API_RETURN_ERR');
       FND_MESSAGE.Set_Token('API', 'IBC_CITEM_ADMIN_GRP.APPROVE_ITEM');
       FND_MESSAGE.Set_Token('PROC', 'PRP_IBC_MIGRATION_INT.CREATE_CONTENT');
       Log_Message(
             pi_migration_code    => l_migration_code
            ,pi_module_name       => l_module_name
            ,pi_log_level         => 'I'
            ,pi_message_text      => FND_MESSAGE.get ||' '|| l_msg_data);
      RAISE FND_API.G_EXC_ERROR;
   END IF;

    IF px_content_item_id is null THEN

     -- Associate Content Item with Component Style
     Update PRP_COMPONENT_STYLES_B PCS set pcs.content_item_id = l_content_item_id, pcs.content_node_type='HIDDEN'
     Where  pcs.component_style_id = p_component_style_id;

     -- Create Association in OCM.
     IBC_ASSOCIATIONS_GRP.CREATE_ASSOCIATION (
	            p_api_version               => 1.0
               ,p_init_msg_list             => FND_API.G_TRUE
	           ,p_commit                    => FND_API.G_FALSE
	           ,p_assoc_type_code           => 'PRP_COMPONENT_DOCUMENT'
	           ,p_assoc_object1             => p_component_style_id
	           ,p_content_item_id           => l_content_item_id
               ,p_citem_version_id          => null
	           ,x_return_status             => l_return_status
               ,x_msg_count			        => l_msg_count
               ,x_msg_data                  => l_msg_data
                                             );

        IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          FND_MESSAGE.Set_Name('PRP', 'PRP_MG_API_RETURN_ERR');
          FND_MESSAGE.Set_Token('API', 'IBC_ASSOCIATIONS_GRP.CREATE_ASSOCIATION');
          FND_MESSAGE.Set_Token('PROC', 'PRP_IBC_MIGRATION_INT.CREATE_CONTENT');
          Log_Message(
             pi_migration_code    => l_migration_code
            ,pi_module_name       => l_module_name
            ,pi_log_level         => 'I'
            ,pi_message_text      => FND_MESSAGE.get ||' '|| l_msg_data);
            RAISE FND_API.G_EXC_ERROR;
        END IF;

   END IF;

   -- Update PRP_COMP_STYLE_CTNTVERS table with citem_version_id.
   Update PRP_COMP_STYLE_CTNTVERS PCC set pcc.citem_version_id = l_citem_ver_id
   Where pcc.comp_style_ctntver_id = p_comp_style_ctntver_id;

   -- Create Association in OCM for versions.
   IBC_ASSOCIATIONS_GRP.CREATE_ASSOCIATION (
	            p_api_version               => 1.0
               ,p_init_msg_list             => FND_API.G_TRUE
	           ,p_commit                    => FND_API.G_FALSE
	           ,p_assoc_type_code           => 'PRP_COMPONENT_DOCUMENT_VERSION'
	           ,p_assoc_object1             => p_comp_style_ctntver_id
	           ,p_content_item_id           => l_content_item_id
               ,p_citem_version_id          => l_citem_ver_id
	           ,x_return_status             => l_return_status
               ,x_msg_count			        => l_msg_count
               ,x_msg_data                  => l_msg_data
                                             );

   IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          FND_MESSAGE.Set_Name('PRP', 'PRP_MG_API_RETURN_ERR');
          FND_MESSAGE.Set_Token('API', 'IBC_ASSOCIATIONS_GRP.CREATE_ASSOCIATION');
          FND_MESSAGE.Set_Token('PROC', 'PRP_IBC_MIGRATION_INT.CREATE_CONTENT');
          Log_Message(
             pi_migration_code    => l_migration_code
            ,pi_module_name       => l_module_name
            ,pi_log_level         => 'I'
            ,pi_message_text      => FND_MESSAGE.get ||' '|| l_msg_data);
            RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Assign values to out variables.
   x_citem_ver_id := l_citem_ver_id;
   px_object_version_number := l_object_version_number;

   IF (px_content_item_id IS NULL) THEN
      px_content_item_id := l_content_item_id;
   END IF;



EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     Rollback TO svpt_create_content;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.count_and_get(p_count => x_msg_count
                              ,p_data  => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     Rollback TO svpt_create_content;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.count_and_get(p_count => x_msg_count
                              ,p_data  => x_msg_data);
  WHEN OTHERS THEN
      Rollback TO svpt_create_content;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- x_msg_data := sqlerrm;
      FND_MSG_PUB.count_and_get(p_count => x_msg_count
                              ,p_data  => x_msg_data);
END CREATE_CONTENT;

/****************************************************************
 * Procedure Name: UPDATE_CONTENT                               *
 *                                                              *
 *                                                              *
 ****************************************************************/

PROCEDURE UPDATE_CONTENT(
                         p_api_version                 IN  NUMBER,
                         p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE,
                         p_file_id                     IN  NUMBER,
                         p_component_style_id          IN  NUMBER,
                         p_comp_style_ctntver_id       IN  NUMBER,
                         p_content_item_id             IN  NUMBER,
                         p_citem_version_id            IN  NUMBER,
                         p_language                    IN  VARCHAR2,
                         px_object_version_number      IN  OUT NOCOPY NUMBER,
                         x_return_status               OUT NOCOPY VARCHAR2,
                         x_msg_count                   OUT NOCOPY NUMBER,
                         x_msg_data                    OUT NOCOPY VARCHAR2) IS

l_content_item_id           NUMBER;
l_object_version_number     NUMBER;
l_citem_ver_id              NUMBER;
l_return_status             VARCHAR2(30);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(2000);
l_api_name                  CONSTANT VARCHAR2(30) := 'UPDATE_CONTENT';
l_api_version               CONSTANT NUMBER := 1;
l_module_name               CONSTANT VARCHAR2(256) := 'PLSQL.PRP.PRP_IBC_MIGRATION_INT.UPDATE_CONTENT';
l_migration_code            CONSTANT VARCHAR2(30) := 'PRP_COMP_OCM_MIGRATION';

Begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF px_object_version_number is not null THEN
    l_object_version_number := px_object_version_number;
   END IF;

   IF p_content_item_id is not null THEN
    l_content_item_id := p_content_item_id;
   END IF;

   IF p_citem_version_id  is not null THEN
    l_citem_ver_id  := p_citem_version_id ;
   END IF;

-- Begin Standard Section

      SAVEPOINT svpt_update_content;
      IF (p_init_msg_list = FND_API.g_true) THEN
        FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
            l_api_version
           ,p_api_version
           ,l_api_name
           ,G_PKG_NAME
      )THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
-- End Standard Section

-- Update the Attachement File id for the content.
IBC_CITEM_ADMIN_GRP.upsert_item_full(
             p_ctype_code                => 'IBC_FILE'
            ,p_citem_name               => p_component_style_id
            ,p_citem_description        => null
            ,p_dir_node_id              => 43
            ,p_owner_resource_id        => NULL
            ,p_owner_resource_type      => NULL
            ,p_reference_code           => NULL
            ,p_trans_required           => FND_API.g_true -- Translation required.
            ,p_parent_item_id           => NULL
            ,p_lock_flag                => FND_API.g_false
            ,p_wd_restricted            => FND_API.g_true
            ,p_start_date               => NULL
            ,p_end_date                 => NULL
            ,p_attribute_type_codes     => NULL
            ,p_attributes               => NULL
            ,p_attach_file_id           => p_file_id
            ,p_component_citems         => NULL
            ,p_component_atypes         => NULL
            ,p_sort_order               => NULL
            ,p_status                   => IBC_UTILITIES_PUB.G_STV_WORK_IN_PROGRESS
            ,p_log_action               => FND_API.g_true
            ,p_language                 => p_language
            ,p_update                   => FND_API.g_true
            ,p_commit                   => FND_API.g_false
            ,p_api_version_number       => IBC_CITEM_ADMIN_GRP.G_API_VERSION_DEFAULT
            ,p_init_msg_list            => FND_API.g_true
            ,px_content_item_id         => l_content_item_id
            ,px_object_version_number   => l_object_version_number
            ,px_citem_ver_id            => l_citem_ver_id
            ,x_return_status            => l_return_status
            ,x_msg_count                => l_msg_count
            ,x_msg_data                 => l_msg_data
          );

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        FND_MESSAGE.Set_Name('PRP', 'PRP_MG_API_RETURN_ERR');
        FND_MESSAGE.Set_Token('API', 'IBC_ASSOCIATIONS_GRP.UPSERT_ITEM_FULL');
        FND_MESSAGE.Set_Token('PROC', 'PRP_IBC_MIGRATION_INT.UPDATE_CONTENT');
        Log_Message(
             pi_migration_code    => l_migration_code
            ,pi_module_name       => l_module_name
            ,pi_log_level         => 'I'
            ,pi_message_text      => FND_MESSAGE.get ||' '|| l_msg_data);
      RAISE FND_API.G_EXC_ERROR;
    END IF;


-- Approve Translations
   IBC_CITEM_ADMIN_GRP.CHANGE_TRANSLATION_STATUS(
                p_citem_ver_id              => p_citem_version_id
               ,p_new_status                => IBC_UTILITIES_PUB.G_STV_APPROVED
               ,p_language                  => p_language
               ,p_commit                    => FND_API.G_FALSE
               ,p_api_version_number        => IBC_CITEM_ADMIN_GRP.G_API_VERSION_DEFAULT
               ,p_init_msg_list             => FND_API.G_TRUE
               ,px_object_version_number    => l_object_version_number
               ,x_return_status             => l_return_status
               ,x_msg_count                 => l_msg_count
               ,x_msg_data                  => l_msg_data);


    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        FND_MESSAGE.Set_Name('PRP', 'PRP_MG_API_RETURN_ERR');
        FND_MESSAGE.Set_Token('API', 'IBC_CITEM_ADMIN_GRP.CHANGE_TRANSLATION_STATUS');
        FND_MESSAGE.Set_Token('PROC','PRP_IBC_MIGRATION_INT.UPDATE_CONTENT');
        Log_Message(
             pi_migration_code    => l_migration_code
            ,pi_module_name       => l_module_name
            ,pi_log_level         => 'I'
            ,pi_message_text      => FND_MESSAGE.get ||' '|| l_msg_data);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Update PRP_COMP_STYLE_CTNTVERS table with citem_version_id.
   Update PRP_COMP_STYLE_CTNTVERS PCC set pcc.citem_version_id = l_citem_ver_id
   Where pcc.comp_style_ctntver_id = p_comp_style_ctntver_id;

   -- Create Association in OCM for versions.
   IBC_ASSOCIATIONS_GRP.CREATE_ASSOCIATION (
	            p_api_version               => 1.0
               ,p_init_msg_list             => FND_API.G_TRUE
	           ,p_commit                    => FND_API.G_FALSE
	           ,p_assoc_type_code           => 'PRP_COMPONENT_DOCUMENT_VERSION'
	           ,p_assoc_object1             => p_comp_style_ctntver_id
	           ,p_content_item_id           => l_content_item_id
               ,p_citem_version_id          => l_citem_ver_id
	           ,x_return_status             => l_return_status
               ,x_msg_count			        => l_msg_count
               ,x_msg_data                  => l_msg_data
                                             );

   IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          FND_MESSAGE.Set_Name('PRP', 'PRP_MG_API_RETURN_ERR');
          FND_MESSAGE.Set_Token('API', 'IBC_ASSOCIATIONS_GRP.CREATE_ASSOCIATION');
          FND_MESSAGE.Set_Token('PROC', 'PRP_IBC_MIGRATION_INT.CREATE_CONTENT');
          Log_Message(
             pi_migration_code    => l_migration_code
            ,pi_module_name       => l_module_name
            ,pi_log_level         => 'I'
            ,pi_message_text      => FND_MESSAGE.get ||' '|| l_msg_data);
            RAISE FND_API.G_EXC_ERROR;
   END IF;

   px_object_version_number := l_object_version_number;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     Rollback TO svpt_update_content;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.count_and_get(p_count => x_msg_count
                              ,p_data  => x_msg_count);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     Rollback TO svpt_update_content;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.count_and_get(p_count => x_msg_count
                              ,p_data  => x_msg_count);
  WHEN OTHERS THEN
      Rollback TO svpt_update_content;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- x_msg_data := sqlerrm;
      FND_MSG_PUB.count_and_get(p_count => x_msg_count
                              ,p_data  => x_msg_count);
END UPDATE_CONTENT;

/****************************************************************
 * Procedure Name: MIGRATE_PROPOSAL_DOC                         *
 *                                                              *
 *                                                              *
 ****************************************************************/

PROCEDURE MIGRATE_PROPOSAL_DOC(
                         p_api_version                 IN  NUMBER,
                         p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE,
                         p_proposal_id                 IN  NUMBER,
                         p_proposal_ctntver_id         IN  NUMBER,
                         p_base_language               IN  VARCHAR2,
                         p_file_id                     IN  NUMBER,
                         px_content_item_id            IN  OUT NOCOPY NUMBER,
                         px_object_version_number      IN  OUT NOCOPY NUMBER,
                         x_citem_ver_id                OUT NOCOPY NUMBER,
                         x_return_status               OUT NOCOPY VARCHAR2,
                         x_msg_count                   OUT NOCOPY NUMBER,
                         x_msg_data                    OUT NOCOPY VARCHAR2) IS

l_content_item_id           NUMBER;
l_object_version_number     NUMBER;
l_citem_ver_id              NUMBER;
l_return_status             VARCHAR2(30);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(2000);
l_api_name                  CONSTANT VARCHAR2(30)  := 'MIGRATE_PROPOSAL_DOC';
l_api_version               CONSTANT NUMBER := 1;
l_module_name               CONSTANT VARCHAR2(256) := 'PLSQL.PRP.PRP_IBC_MIGRATION_INT.MIGRATE_PROPOSAL_DOC';
l_migration_code            CONSTANT VARCHAR2(30)  := 'PRP_PROP_OCM_MIGRATION';

Begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Begin Standard Section

      SAVEPOINT svpt_migrate_proposal_doc;
      IF (p_init_msg_list = FND_API.g_true) THEN
        FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
            l_api_version
           ,p_api_version
           ,l_api_name
           ,G_PKG_NAME
      )THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
-- End Standard Section

 IF px_content_item_id is not null THEN
    l_content_item_id := px_content_item_id;
 END IF;

 IF px_object_version_number is not null THEN
    l_object_version_number := px_object_version_number;
 END IF;

  -- Create Content Item.
  IBC_CITEM_ADMIN_GRP.upsert_item_full(
             p_ctype_code                => 'IBC_FILE'
            ,p_citem_name               => p_proposal_id
            ,p_citem_description        => null
            ,p_dir_node_id              => 41
            ,p_owner_resource_id        => NULL
            ,p_owner_resource_type      => NULL
            ,p_reference_code           => NULL
            ,p_trans_required           => FND_API.g_false -- Translation not required.
            ,p_parent_item_id           => NULL
            ,p_lock_flag                => FND_API.g_false
            ,p_wd_restricted            => FND_API.g_true
            ,p_start_date               => NULL
            ,p_end_date                 => NULL
            ,p_attribute_type_codes     => NULL
            ,p_attributes               => NULL
            ,p_attach_file_id           => p_file_id
            ,p_component_citems         => NULL
            ,p_component_atypes         => NULL
            ,p_sort_order               => NULL
            ,p_status                   => IBC_UTILITIES_PUB.G_STV_WORK_IN_PROGRESS
            ,p_log_action               => FND_API.g_true
            ,p_language                 => p_base_language
            ,p_update                   => FND_API.g_true
            ,p_commit                   => FND_API.g_false
            ,p_api_version_number       => IBC_CITEM_ADMIN_GRP.G_API_VERSION_DEFAULT
            ,p_init_msg_list            => FND_API.g_true
            ,px_content_item_id         => l_content_item_id
            ,px_object_version_number   => l_object_version_number
            ,px_citem_ver_id            => l_citem_ver_id
            ,x_return_status            => l_return_status
            ,x_msg_count                => l_msg_count
            ,x_msg_data                 => l_msg_data
          );

   IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        FND_MESSAGE.Set_Name('PRP', 'PRP_MG_API_RETURN_ERR');
        FND_MESSAGE.Set_Token('API', 'IBC_CITEM_ADMIN_GRP.UPSERT_ITEM_FULL');
        FND_MESSAGE.Set_Token('PROC','PRP_IBC_MIGRATION_INT.MIGRATE_PROPOSAL_DOC');
        Log_Message(
             pi_migration_code    => l_migration_code
            ,pi_module_name       => l_module_name
            ,pi_log_level         => 'I'
            ,pi_message_text      => FND_MESSAGE.get ||' '|| l_msg_data);
      RAISE FND_API.G_EXC_ERROR;
   END IF;


   /* Approve Item */

   IBC_CITEM_ADMIN_GRP.APPROVE_ITEM(
           p_citem_ver_id               => l_citem_ver_id
          ,p_commit                     => FND_API.g_false
          ,p_api_version_number         => IBC_CITEM_ADMIN_GRP.G_API_VERSION_DEFAULT
          ,p_init_msg_list              => FND_API.g_true
          ,px_object_version_number     => l_object_version_number
          ,x_return_status              => l_return_status
          ,x_msg_count                  => l_msg_count
          ,x_msg_data                   => l_msg_data
          );


   IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
       FND_MESSAGE.Set_Name('PRP', 'PRP_MG_API_RETURN_ERR');
        FND_MESSAGE.Set_Token('API', 'IBC_CITEM_ADMIN_GRP.APPROVE_ITEM');
        FND_MESSAGE.Set_Token('PROC','PRP_IBC_MIGRATION_INT.MIGRATE_PROPOSAL_DOC');
        Log_Message(
             pi_migration_code    => l_migration_code
            ,pi_module_name       => l_module_name
            ,pi_log_level         => 'I'
            ,pi_message_text      => FND_MESSAGE.get || l_msg_data);
      RAISE FND_API.G_EXC_ERROR;
   END IF;

    IF px_content_item_id is null THEN

     -- Associate Content Item with Proposal
     Update PRP_PROPOSALS PP set pp.content_item_id = l_content_item_id
     Where  pp.proposal_id = p_proposal_id;

     -- Create Association in OCM.
     IBC_ASSOCIATIONS_GRP.CREATE_ASSOCIATION (
	            p_api_version               => 1.0
               ,p_init_msg_list             => FND_API.G_TRUE
	           ,p_commit                    => FND_API.G_FALSE
	           ,p_assoc_type_code           => 'PRP_GENERATED_PROPOSAL'
	           ,p_assoc_object1             => p_proposal_id
	           ,p_content_item_id           => l_content_item_id
               ,p_citem_version_id          => null
	           ,x_return_status             => l_return_status
               ,x_msg_count			        => l_msg_count
               ,x_msg_data                  => l_msg_data
                                             );

        IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          FND_MESSAGE.Set_Name('PRP', 'PRP_MG_API_RETURN_ERR');
          FND_MESSAGE.Set_Token('API', 'IBC_ASSOCIATIONS_GRP.CREATE_ASSOCIATION');
          FND_MESSAGE.Set_Token('PROC','PRP_IBC_MIGRATION_INT.MIGRATE_PROPOSAL_DOC');
          Log_Message(
             pi_migration_code    => l_migration_code
            ,pi_module_name       => l_module_name
            ,pi_log_level         => 'I'
            ,pi_message_text      => FND_MESSAGE.get ||' '|| l_msg_data);
            RAISE FND_API.G_EXC_ERROR;
        END IF;

   END IF;

   -- Update PRP_PROP_STYLE_CTNTVERS table with citem_version_id.
   Update PRP_PROPOSAL_CTNTVERS PPS set pps.citem_version_id = l_citem_ver_id
   Where pps.proposal_ctntver_id = p_proposal_ctntver_id;

   -- Create Association in OCM for the versions.
   IBC_ASSOCIATIONS_GRP.CREATE_ASSOCIATION (
	            p_api_version               => 1.0
               ,p_init_msg_list             => FND_API.G_TRUE
	           ,p_commit                    => FND_API.G_FALSE
	           ,p_assoc_type_code           => 'PRP_GENERATED_DOCUMENT_VERSION'
	           ,p_assoc_object1             => p_proposal_ctntver_id
	           ,p_content_item_id           => l_content_item_id
               ,p_citem_version_id          => l_citem_ver_id
	           ,x_return_status             => l_return_status
               ,x_msg_count			        => l_msg_count
               ,x_msg_data                  => l_msg_data
                                             );

   IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      FND_MESSAGE.Set_Name('PRP', 'PRP_MG_API_RETURN_ERR');
      FND_MESSAGE.Set_Token('API', 'IBC_ASSOCIATIONS_GRP.CREATE_ASSOCIATION');
      FND_MESSAGE.Set_Token('PROC','PRP_IBC_MIGRATION_INT.MIGRATE_PROPOSAL_DOC');
      Log_Message(
             pi_migration_code    => l_migration_code
            ,pi_module_name       => l_module_name
            ,pi_log_level         => 'I'
            ,pi_message_text      => FND_MESSAGE.get ||' '|| l_msg_data);
      RAISE FND_API.G_EXC_ERROR;
   END IF;


   -- Assign values to out variables.
   x_citem_ver_id := l_citem_ver_id;
   px_object_version_number := l_object_version_number;

   IF (px_content_item_id IS NULL) THEN
      px_content_item_id := l_content_item_id;
   END IF;



EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     Rollback TO svpt_migrate_proposal_doc;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.count_and_get(p_count => x_msg_count
                              ,p_data  => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     Rollback TO svpt_migrate_proposal_doc;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.count_and_get(p_count => x_msg_count
                              ,p_data  => x_msg_data);
  WHEN OTHERS THEN
      Rollback TO svpt_migrate_proposal_doc;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      --x_msg_data := sqlerrm;
      FND_MSG_PUB.count_and_get(p_count => x_msg_count
                              ,p_data  => x_msg_data);
END MIGRATE_PROPOSAL_DOC;
END PRP_IBC_MIGRATION_INT;

/
