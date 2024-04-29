--------------------------------------------------------
--  DDL for Package Body AMS_LIST_SRC_FIELD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_SRC_FIELD_PVT" as
/* $Header: amsvlsfb.pls 120.1 2005/09/20 02:18:42 batoleti noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_List_Src_Field_PVT
-- Purpose
--
-- History
--    14-Oct-2002 nyostos  Added callout to AMS_DM_MODEL_PVT.
--    handle_data_source_changes() if analytics_flag is changed
--    for a data source field.
--    22-Jan-2004 kbasavar  Commented out validation for field
--                   column name in procedure Update_list_Src_Field
--    20-SEP-2005 batoleti  Added p_column_type parameter to insert_row
--                          and update_row procedure calls.
--                          Refer bug# 4619184.
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_List_Src_Field_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvlsfb.pls';


-- Hint: Primary key needs to be returned.
PROCEDURE Create_List_Src_Field(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_list_src_field_rec               IN   list_src_field_rec_type  := g_miss_list_src_field_rec,
    x_list_source_field_id                   OUT NOCOPY  NUMBER
     )

 IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_List_Src_Field';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_LIST_SOURCE_FIELD_ID      NUMBER;
   l_dummy                     NUMBER;
   l_table_name                VARCHAR2(30);
   l_column_name               VARCHAR2(30);

   CURSOR c_id IS
      SELECT AMS_LIST_SRC_FIELDS_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_LIST_SRC_FIELDS
      WHERE LIST_SOURCE_FIELD_ID = l_id;

   CURSOR c_get_column_name(p_table_name VARCHAR2, p_column_name VARCHAR2) IS
       SELECT COLUMN_NAME
       FROM sys.all_tab_columns
       WHERE table_name = UPPER(p_table_name)
       AND column_name = UPPER(p_column_name);

   CURSOR c_get_table_name(p_list_source_type_id NUMBER) IS
       SELECT source_object_name
       FROM ams_list_src_types
       WHERE list_source_type_id = p_list_source_type_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_List_Src_Field_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

   IF p_list_src_field_rec.LIST_SOURCE_FIELD_ID IS NULL OR p_list_src_field_rec.LIST_SOURCE_FIELD_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_LIST_SOURCE_FIELD_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_LIST_SOURCE_FIELD_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   END IF;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.User_Id IS NULL
      THEN
          AMS_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          AMS_UTILITY_PVT.debug_message('Private API: Validate_List_Src_Field');

          -- Invoke validation procedures
          Validate_list_src_field(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_list_src_field_rec  =>  p_list_src_field_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- check if source_column_name exist
      OPEN c_get_table_name(p_list_src_field_rec.list_source_type_id);
      FETCH c_get_table_name INTO l_table_name;
      if (c_get_table_name%NOTFOUND)
      THEN
         close c_get_table_name;
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD','MISS_FIELD','source_object_name');
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      close c_get_table_name;


      OPEN c_get_column_name(l_table_name, p_list_src_field_rec.source_column_name);
      FETCH c_get_column_name INTO l_column_name;
      if (c_get_column_name%NOTFOUND)
      THEN
         close c_get_column_name;
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD','MISS_FIELD','source_column_name');
	 RAISE FND_API.G_EXC_ERROR;

      END IF;
      close c_get_column_name;


      -- check if field_column_name exist
/*
      OPEN c_get_column_name('AMS_LIST_ENTRIES', p_list_src_field_rec.field_column_name);
      FETCH c_get_column_name INTO l_column_name;
      if (c_get_column_name%NOTFOUND)
      THEN
         close c_get_column_name;
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD','MISS_FIELD','field_column_name');
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      close c_get_column_name;
*/

      -- Debug Message
      AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');

      -- Invoke table handler(AMS_LIST_SRC_FIELDS_PKG.Insert_Row)
      AMS_LIST_SRC_FIELDS_PKG.Insert_Row(
        px_list_source_field_id  => l_list_source_field_id,
        p_last_update_date  => SYSDATE,
        p_last_updated_by  => FND_GLOBAL.USER_ID,
        p_creation_date  => SYSDATE,
        p_created_by  => FND_GLOBAL.USER_ID,
        p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
        px_object_version_number  => l_object_version_number,
        p_de_list_source_type_code  => p_list_src_field_rec.de_list_source_type_code,
        p_list_source_type_id  => p_list_src_field_rec.list_source_type_id,
        p_field_table_name  => p_list_src_field_rec.field_table_name,
        p_field_column_name  => p_list_src_field_rec.field_column_name,
        p_source_column_name  => p_list_src_field_rec.source_column_name,
        p_source_column_meaning  => p_list_src_field_rec.source_column_meaning,
        p_enabled_flag  => p_list_src_field_rec.enabled_flag,
        p_start_position  => p_list_src_field_rec.start_position,
        p_end_position  => p_list_src_field_rec.end_position,
        p_field_data_type        => p_list_src_field_rec.field_data_type,
        p_field_data_size         => p_list_src_field_rec.field_data_size,
        p_default_ui_control            => p_list_src_field_rec.default_ui_control,
        p_field_lookup_type             => p_list_src_field_rec.field_lookup_type,
        p_field_lookup_type_view_name   => p_list_src_field_rec.field_lookup_type_view_name,
        p_allow_label_override          => p_list_src_field_rec.allow_label_override,
        p_field_usage_type              => p_list_src_field_rec.field_usage_type,
        p_dialog_enabled                => p_list_src_field_rec.dialog_enabled,
        p_analytics_flag                => p_list_src_field_rec.analytics_flag,
        p_auto_binning_flag             => p_list_src_field_rec.auto_binning_flag,
        p_no_of_buckets                 => p_list_src_field_rec.no_of_buckets,
        p_attb_lov_id			=> p_list_src_field_rec.attb_lov_id,
        p_lov_defined_flag	        => p_list_src_field_rec.lov_defined_flag,
	p_column_type                   => NULL
);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
--
-- End of API body
--
       x_list_source_field_id := l_list_source_field_id;
      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_List_Src_Field_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_List_Src_Field_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_List_Src_Field_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Create_List_Src_Field;


PROCEDURE Update_List_Src_Field(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_list_src_field_rec         IN    list_src_field_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS

   CURSOR c_get_list_src_field(list_source_field_id NUMBER) IS
       SELECT *
       FROM  AMS_LIST_SRC_FIELDS
       WHERE list_source_field_id =p_list_src_field_rec.list_source_field_id;

   CURSOR c_get_analytics_flag(p_list_source_field_id NUMBER) IS
       SELECT analytics_flag
       FROM  AMS_LIST_SRC_FIELDS
       WHERE list_source_field_id = p_list_source_field_id;

   CURSOR c_get_column_name(p_table_name VARCHAR2, p_column_name VARCHAR2) IS
       SELECT COLUMN_NAME
       FROM sys.all_tab_columns
       WHERE table_name = UPPER(p_table_name)
       AND column_name = UPPER(p_column_name);

   CURSOR c_get_table_name(p_list_source_type_id NUMBER) IS
       SELECT source_object_name,nvl(remote_flag,'N'),database_link
       FROM ams_list_src_types
       WHERE list_source_type_id = p_list_source_type_id;

   L_API_NAME                    CONSTANT VARCHAR2(30) := 'Update_List_Src_Field';
   L_API_VERSION_NUMBER          CONSTANT NUMBER   := 1.0;
   -- Local Variables
   l_object_version_number       NUMBER;
   l_LIST_SOURCE_FIELD_ID        NUMBER;
   l_ref_list_src_field_rec      c_get_List_Src_Field%ROWTYPE ;
   l_tar_list_src_field_rec      AMS_List_Src_Field_PVT.list_src_field_rec_type := P_list_src_field_rec;
   l_rowid                       ROWID;

   l_ref_analytics_flag          VARCHAR2(1);

   l_table_name                  VARCHAR2(30);
   l_column_name                 VARCHAR2(30);
   l_remote_flag                 VARCHAR2(1);
   l_database_link		 VARCHAR2(1000);
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_List_Src_Field_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');

       -- check if source_column_name exist
      OPEN c_get_table_name(p_list_src_field_rec.list_source_type_id);
      FETCH c_get_table_name INTO l_table_name,l_remote_flag,l_database_link;
      if (c_get_table_name%NOTFOUND)
      THEN
         close c_get_table_name;
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD','MISS_FIELD','source_object_name');
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      close c_get_table_name;

      if l_remote_flag = 'N' then
         OPEN c_get_column_name(l_table_name, p_list_src_field_rec.source_column_name);
         FETCH c_get_column_name INTO l_column_name;
         if (c_get_column_name%NOTFOUND)
           THEN
          close c_get_column_name;
          AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD','MISS_FIELD','source_column_name');
	  RAISE FND_API.G_EXC_ERROR;
         END IF;
        close c_get_column_name;
      end if;


      if l_remote_flag = 'Y' then
         EXECUTE IMMEDIATE
           'BEGIN
              SELECT distinct COLUMN_NAME INTO :1
              FROM sys.all_tab_columns'||'@'||l_database_link||
           ' WHERE table_name = UPPER( :1 )'||
           ' AND column_name = UPPER( :2 ); END;'
         USING l_table_name,
               p_list_src_field_rec.source_column_name,
         OUT l_column_name;
--            ' WHERE table_name = UPPER('||''''||l_table_name||''''||')'||
--         ' AND column_name = UPPER('|| ''''||p_list_src_field_rec.source_column_name||''''||'); END;' USING OUT l_column_name;
         if l_column_name is NULL
           THEN
          AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD','MISS_FIELD','source_column_name');
          RAISE FND_API.G_EXC_ERROR;
         END IF;
      end if;


      If (l_tar_list_src_field_rec.object_version_number is NULL or
          l_tar_list_src_field_rec.object_version_number = FND_API.G_MISS_NUM ) Then
         AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
                                       p_token_name   => 'COLUMN',
                                       p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_list_src_field_rec.object_version_number <> l_ref_list_src_field_rec.object_version_number) Then
         AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
                                       p_token_name   => 'INFO',
                                       p_token_value  => 'List_Src_Field') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          AMS_UTILITY_PVT.debug_message('Private API: Validate_List_Src_Field');

          -- Invoke validation procedures
          Validate_list_src_field(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_list_src_field_rec  =>  p_list_src_field_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      -- AMS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');

      -- Invoke table handler(AMS_LIST_SRC_FIELDS_PKG.Update_Row)
      AMS_LIST_SRC_FIELDS_PKG.Update_Row(
          p_list_source_field_id          => p_list_src_field_rec.list_source_field_id,
          p_last_update_date              => SYSDATE,
          p_last_updated_by               => FND_GLOBAL.USER_ID,
          p_creation_date                 => SYSDATE,
          p_created_by                    => FND_GLOBAL.USER_ID,
          p_last_update_login             => FND_GLOBAL.CONC_LOGIN_ID,
          p_object_version_number         => p_list_src_field_rec.object_version_number,
          p_de_list_source_type_code      => p_list_src_field_rec.de_list_source_type_code,
          p_list_source_type_id           => p_list_src_field_rec.list_source_type_id,
          p_field_table_name              => p_list_src_field_rec.field_table_name,
          p_field_column_name             => p_list_src_field_rec.field_column_name,
          p_source_column_name            => p_list_src_field_rec.source_column_name,
          p_source_column_meaning         => p_list_src_field_rec.source_column_meaning,
          p_enabled_flag                  => p_list_src_field_rec.enabled_flag,
          p_start_position                => p_list_src_field_rec.start_position,
          p_end_position                  => p_list_src_field_rec.end_position,
          p_field_data_type               => p_list_src_field_rec.field_data_type,
          p_field_data_size               => p_list_src_field_rec.field_data_size,
          p_default_ui_control            => p_list_src_field_rec.default_ui_control,
          p_field_lookup_type             => p_list_src_field_rec.field_lookup_type,
          p_field_lookup_type_view_name   => p_list_src_field_rec.field_lookup_type_view_name,
          p_allow_label_override          => p_list_src_field_rec.allow_label_override,
          p_field_usage_type              => p_list_src_field_rec.field_usage_type,
          p_dialog_enabled                => p_list_src_field_rec.dialog_enabled,
          p_analytics_flag                => p_list_src_field_rec.analytics_flag,
          p_auto_binning_flag             => p_list_src_field_rec.auto_binning_flag,
          p_no_of_buckets                 => p_list_src_field_rec.no_of_buckets,
          p_attb_lov_id			=> p_list_src_field_rec.attb_lov_id,
          p_lov_defined_flag	        => p_list_src_field_rec.lov_defined_flag,
	  p_column_type                 => NULL
	);

   -- Beginning of Code for Analytics Data Source Fields
   -- Added by nyostos - June 11, 2002
   -- If the auto_binning_flag is set to 'Y', then remove all binning details for the field
   IF p_list_src_field_rec.auto_binning_flag = 'Y' THEN
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' AutoBinning Flag - Going to delete bin values for this field');
      AMS_Dm_Binvalues_PVT.Delete_Dm_Binvalues_For_Field (p_datasource_field_id => p_list_src_field_rec.list_source_field_id);
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' AutoBinning Flag - After delete of bin values for this field');
   END IF;
   -- End of Code for Analytics Data Source Fields

   -- Added by nyostos - Oct 14, 2002
   -- If the analytics_flag has been changed for the field, then call
   -- a procedure to INVALIDATE all AVAILABLE models using this data source.
   -- First get the saved analytics_flag
   OPEN  c_get_analytics_flag (p_list_src_field_rec.list_source_field_id);
   FETCH c_get_analytics_flag INTO l_ref_analytics_flag;
   CLOSE c_get_analytics_flag;

   IF (l_ref_analytics_flag IS NULL AND p_list_src_field_rec.analytics_flag IS NOT NULL) OR
      (l_ref_analytics_flag <> p_list_src_field_rec.analytics_flag ) THEN
      AMS_DM_MODEL_PVT.handle_data_source_changes(p_list_src_field_rec.list_source_type_id);
   END IF;
   -- End of addition by nyostos - Oct 14, 2002

   --
   -- End of API body.
   --

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;


   -- Debug Message
   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_List_Src_Field_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_List_Src_Field_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
      ROLLBACK TO UPDATE_List_Src_Field_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Update_List_Src_Field;


PROCEDURE Delete_List_Src_Field(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_list_source_field_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_List_Src_Field';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_List_Src_Field_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      AMS_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');

      -- Invoke table handler(AMS_LIST_SRC_FIELDS_PKG.Delete_Row)
      AMS_LIST_SRC_FIELDS_PKG.Delete_Row(
          p_LIST_SOURCE_FIELD_ID  => p_LIST_SOURCE_FIELD_ID);


      -- Beginning of Code for Analytics Data Source Fields
      -- Added by nyostos - June 11, 2002
      -- Remove all binning details for the field
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Going to delete bin values for this field');
      AMS_Dm_Binvalues_PVT.Delete_Dm_Binvalues_For_Field (p_datasource_field_id => p_list_source_field_id);
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' After delete of bin values for this field');
      -- End of Code for Analytics Data Source Fields


      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_List_Src_Field_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_List_Src_Field_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_List_Src_Field_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Delete_List_Src_Field;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_List_Src_Field(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_list_source_field_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_List_Src_Field';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_LIST_SOURCE_FIELD_ID                  NUMBER;

CURSOR c_List_Src_Field IS
   SELECT LIST_SOURCE_FIELD_ID
   FROM AMS_LIST_SRC_FIELDS
   WHERE LIST_SOURCE_FIELD_ID = p_LIST_SOURCE_FIELD_ID
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

BEGIN

      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


------------------------ lock -------------------------

  AMS_Utility_PVT.debug_message(l_full_name||': start');
  OPEN c_List_Src_Field;

  FETCH c_List_Src_Field INTO l_LIST_SOURCE_FIELD_ID;

  IF (c_List_Src_Field%NOTFOUND) THEN
    CLOSE c_List_Src_Field;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_List_Src_Field;

 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  AMS_Utility_PVT.debug_message(l_full_name ||': end');
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_List_Src_Field_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_List_Src_Field_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_List_Src_Field_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Lock_List_Src_Field;


PROCEDURE check_list_src_field_uk_items(
    p_list_src_field_rec               IN   list_src_field_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_LIST_SRC_FIELDS',
         'LIST_SOURCE_FIELD_ID = ''' || p_list_src_field_rec.LIST_SOURCE_FIELD_ID ||''''
         );
      ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_LIST_SRC_FIELDS',
         'LIST_SOURCE_FIELD_ID = ''' || p_list_src_field_rec.LIST_SOURCE_FIELD_ID ||
         ''' AND LIST_SOURCE_FIELD_ID <> ' || p_list_src_field_rec.LIST_SOURCE_FIELD_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
	AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_LIST_SOURCE_FIELD_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

   IF  p_validation_mode = JTF_PLSQL_API.g_create
   AND p_list_src_field_rec.source_column_name IS NOT NULL
   AND p_list_src_field_rec.field_column_name IS NOT NULL
   AND p_list_src_field_rec.field_table_name IS NOT NULL
   AND p_list_src_field_rec.list_source_type_id IS NOT NULL

   THEN
      IF AMS_Utility_PVT.check_uniqueness(
             'ams_list_src_fields',
                'source_column_name = ' || p_list_src_field_rec.source_column_name||
                ' and field_table_name = '||p_list_src_field_rec.field_table_name
                ||' and field_column_name = '||p_list_src_field_rec.field_column_name
                ||' and list_source_type_id = '||p_list_src_field_rec.list_source_type_id

                        ) = FND_API.g_false
      THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('AMS', 'BAD_COMB');
             FND_MSG_PUB.add;
          END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
      END IF;
   END IF;


END check_list_src_field_uk_items;

PROCEDURE check_list_src_field_req_items(
    p_list_src_field_rec               IN  list_src_field_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_list_src_field_rec.list_source_field_id = FND_API.g_miss_num OR p_list_src_field_rec.list_source_field_id IS NULL THEN
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD','MISS_FIELD','LIST_SOURCE_FIELD_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_src_field_rec.de_list_source_type_code = FND_API.g_miss_char OR p_list_src_field_rec.de_list_source_type_code IS NULL THEN
        AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD','MISS_FIELD','DE_LIST_SOURCE_TYPE_CODE' );
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_src_field_rec.list_source_type_id = FND_API.g_miss_num OR p_list_src_field_rec.list_source_type_id IS NULL THEN
      AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD','MISS_FIELD','LIST_SOURCE_TYPE_ID' );
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
/*
      field_table_name and field_column_name are checked in check_lstsrcfld_business()
      IF p_list_src_field_rec.field_table_name = FND_API.g_miss_char OR p_list_src_field_rec.field_table_name IS NULL THEN
        AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD','MISS_FIELD','FIELD_TABLE_NAME' );
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_src_field_rec.field_column_name = FND_API.g_miss_char OR p_list_src_field_rec.field_column_name IS NULL THEN
        AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD','MISS_FIELD','FIELD_COLUMN_NAME' );
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
*/

      IF p_list_src_field_rec.source_column_name = FND_API.g_miss_char OR p_list_src_field_rec.source_column_name IS NULL THEN
        AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD','MISS_FIELD','SOURCE_COLUMN_NAME' );
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

     IF p_list_src_field_rec.enabled_flag = FND_API.g_miss_char OR p_list_src_field_rec.enabled_flag IS NULL THEN
        AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD','MISS_FIELD','ENABLED_FLAG' );
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

   END IF;


END check_list_src_field_req_items;

PROCEDURE check_list_src_field_FK_items(
    p_list_src_field_rec IN list_src_field_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_list_src_field_FK_items;

PROCEDURE check_lstsrcfld_lookup_items(
    p_list_src_field_rec IN list_src_field_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_lstsrcfld_lookup_items;

PROCEDURE check_lstsrcfld_business(
    p_list_src_field_rec IN list_src_field_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS

CURSOR c_lstsrcfld_crt IS
    SELECT *
    FROM  ams_list_src_fields_vl
    WHERE list_source_type_id=p_list_src_field_rec.list_source_type_id
    and source_column_name = p_list_src_field_rec.source_column_name;

CURSOR c_lstsrcfld_upd IS
    SELECT *
    FROM  ams_list_src_fields_vl
    WHERE list_source_type_id=p_list_src_field_rec.list_source_type_id
    and source_column_name = p_list_src_field_rec.source_column_name
    and list_source_field_id <> p_list_src_field_rec.list_source_field_id;

CURSOR c_fldcolname_crt IS
-- Bug 3664542, SOLIN SQL Repository, tuning
--    SELECT *
--    FROM  ams_list_src_fields_vl
--    WHERE
--    (list_source_type_id=p_list_src_field_rec.list_source_type_id
--    OR list_source_type_id IN
--       ( SELECT sub_source_type_id
--         FROM ams_list_src_type_assocs
--         WHERE ( master_source_type_id = p_list_src_field_rec.list_source_type_id
--              OR sub_source_type_id = p_list_src_field_rec.list_source_type_id)
--         AND enabled_flag = 'Y'
--       )
--    )
--    AND field_column_name = p_list_src_field_rec.field_column_name;
    SELECT *
    FROM  ams_list_src_fields_vl
    WHERE list_source_type_id=p_list_src_field_rec.list_source_type_id
    AND field_column_name = p_list_src_field_rec.field_column_name
    UNION ALL
    SELECT *
    FROM  ams_list_src_fields_vl
    WHERE list_source_type_id IN
       ( SELECT sub_source_type_id
         FROM ams_list_src_type_assocs
         WHERE ( master_source_type_id = p_list_src_field_rec.list_source_type_id
              OR sub_source_type_id = p_list_src_field_rec.list_source_type_id)
         AND enabled_flag = 'Y'
       )
    AND field_column_name = p_list_src_field_rec.field_column_name;

CURSOR c_fldcolname_upd IS
-- Bug 3664542, SOLIN SQL Repository, tuning
--    SELECT *
--    FROM  ams_list_src_fields_vl
--    WHERE
--    (list_source_type_id=p_list_src_field_rec.list_source_type_id
--    OR list_source_type_id IN
--       ( SELECT sub_source_type_id
--         FROM ams_list_src_type_assocs
--         WHERE ( master_source_type_id = p_list_src_field_rec.list_source_type_id
--              OR sub_source_type_id = p_list_src_field_rec.list_source_type_id)
--         AND enabled_flag = 'Y'
--       )
--    )
--    AND field_column_name = p_list_src_field_rec.field_column_name
--    AND list_source_field_id <> p_list_src_field_rec.list_source_field_id;
    SELECT *
    FROM  ams_list_src_fields_vl
    WHERE list_source_type_id=p_list_src_field_rec.list_source_type_id
    AND field_column_name = p_list_src_field_rec.field_column_name
    AND list_source_field_id <> p_list_src_field_rec.list_source_field_id
    UNION ALL
    SELECT *
    FROM  ams_list_src_fields_vl
    WHERE list_source_type_id IN
       ( SELECT sub_source_type_id
         FROM ams_list_src_type_assocs
         WHERE ( master_source_type_id = p_list_src_field_rec.list_source_type_id
              OR sub_source_type_id = p_list_src_field_rec.list_source_type_id)
         AND enabled_flag = 'Y'
       )
    AND field_column_name = p_list_src_field_rec.field_column_name
    AND list_source_field_id <> p_list_src_field_rec.list_source_field_id;

l_lstsrcfld_crt_rec c_lstsrcfld_crt%ROWTYPE;
l_fldcolname_crt_rec c_fldcolname_crt%ROWTYPE;
l_lstsrcfld_upd_rec c_lstsrcfld_upd%ROWTYPE;
l_fldcolname_upd_rec c_fldcolname_upd%ROWTYPE;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- Create
   IF p_list_src_field_rec.list_source_field_id = FND_API.g_miss_num or
      p_list_src_field_rec.list_source_field_id IS NULL
   THEN
      OPEN c_lstsrcfld_crt;
      FETCH c_lstsrcfld_crt INTO l_lstsrcfld_crt_rec;

      IF (c_lstsrcfld_crt%FOUND) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DUPLICATE_SRC_COL_NAME');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      OPEN c_fldcolname_crt;
      FETCH c_fldcolname_crt INTO l_fldcolname_crt_rec;

      IF (c_fldcolname_crt%FOUND) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DUPLICATE_FLD_COL_NAME');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

   -- Update
   ELSE
      OPEN c_lstsrcfld_upd;
      FETCH c_lstsrcfld_upd INTO l_lstsrcfld_upd_rec;

      IF (c_lstsrcfld_upd%FOUND) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DUPLICATE_SRC_COL_NAME');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      OPEN c_fldcolname_upd;
      FETCH c_fldcolname_upd INTO l_fldcolname_upd_rec;

      IF (c_fldcolname_upd%FOUND) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_DUPLICATE_FLD_COL_NAME');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

   END IF;

   /*
   IF p_list_src_field_rec.de_list_source_type_code <> 'ANALYTICS' THEN
      IF p_list_src_field_rec.field_table_name = FND_API.g_miss_char OR p_list_src_field_rec.field_table_name IS NULL THEN
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD','MISS_FIELD','field_table_name' );
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_list_src_field_rec.field_column_name = FND_API.g_miss_char OR p_list_src_field_rec.field_column_name IS NULL THEN
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD','MISS_FIELD','field_column_name' );
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
  END IF;
  */
  IF p_list_src_field_rec.enabled_flag = 'Y' THEN
      IF p_list_src_field_rec.field_table_name = FND_API.g_miss_char OR p_list_src_field_rec.field_table_name IS NULL THEN
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD','MISS_FIELD','field_table_name' );
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_list_src_field_rec.field_column_name = FND_API.g_miss_char OR p_list_src_field_rec.field_column_name IS NULL THEN
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD','MISS_FIELD','field_column_name' );
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
  END IF;

END check_lstsrcfld_business;

PROCEDURE Check_list_src_field_Items (
    P_list_src_field_rec     IN    list_src_field_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_list_src_field_uk_items(
      p_list_src_field_rec => p_list_src_field_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_list_src_field_req_items(
      p_list_src_field_rec => p_list_src_field_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   check_list_src_field_FK_items(
      p_list_src_field_rec => p_list_src_field_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

   check_lstsrcfld_lookup_items(
      p_list_src_field_rec => p_list_src_field_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   AMS_UTILITY_PVT.debug_message('Private API: ' || 'before check_lstsrcfld_business');
   check_lstsrcfld_business(
      p_list_src_field_rec => p_list_src_field_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   AMS_UTILITY_PVT.debug_message('Private API: ' || 'after check_lstsrcfld_business');

END Check_list_src_field_Items;


PROCEDURE Complete_list_src_field_Rec (
   p_list_src_field_rec IN list_src_field_rec_type,
   x_complete_rec OUT NOCOPY list_src_field_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_list_src_fields_vl
      WHERE list_source_field_id = p_list_src_field_rec.list_source_field_id;
   l_list_src_field_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_list_src_field_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_list_src_field_rec;
   CLOSE c_complete;

   -- list_source_field_id
   IF p_list_src_field_rec.list_source_field_id = FND_API.g_miss_num THEN
      x_complete_rec.list_source_field_id := l_list_src_field_rec.list_source_field_id;
   END IF;

   -- last_update_date
   IF p_list_src_field_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_list_src_field_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_list_src_field_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_list_src_field_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_list_src_field_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_list_src_field_rec.creation_date;
   END IF;

   -- created_by
   IF p_list_src_field_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_list_src_field_rec.created_by;
   END IF;

   -- last_update_login
   IF p_list_src_field_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_list_src_field_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_list_src_field_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_list_src_field_rec.object_version_number;
   END IF;

   -- de_list_source_type_code
   IF p_list_src_field_rec.de_list_source_type_code = FND_API.g_miss_char THEN
      x_complete_rec.de_list_source_type_code := l_list_src_field_rec.de_list_source_type_code;
   END IF;

   -- list_source_type_id
   IF p_list_src_field_rec.list_source_type_id = FND_API.g_miss_num THEN
      x_complete_rec.list_source_type_id := l_list_src_field_rec.list_source_type_id;
   END IF;

   -- field_table_name
   IF p_list_src_field_rec.field_table_name = FND_API.g_miss_char THEN
      x_complete_rec.field_table_name := l_list_src_field_rec.field_table_name;
   END IF;

   -- field_column_name
   IF p_list_src_field_rec.field_column_name = FND_API.g_miss_char THEN
      x_complete_rec.field_column_name := l_list_src_field_rec.field_column_name;
   END IF;

   -- source_column_name
   IF p_list_src_field_rec.source_column_name = FND_API.g_miss_char THEN
      x_complete_rec.source_column_name := l_list_src_field_rec.source_column_name;
   END IF;

   -- source_column_meaning
   IF p_list_src_field_rec.source_column_meaning = FND_API.g_miss_char THEN
      x_complete_rec.source_column_meaning := l_list_src_field_rec.source_column_meaning;
   END IF;

   -- enabled_flag
   IF p_list_src_field_rec.enabled_flag = FND_API.g_miss_char THEN
      x_complete_rec.enabled_flag := l_list_src_field_rec.enabled_flag;
   END IF;

   -- start_position
   IF p_list_src_field_rec.start_position = FND_API.g_miss_num THEN
      x_complete_rec.start_position := l_list_src_field_rec.start_position;
   END IF;

   -- end_position
   IF p_list_src_field_rec.end_position = FND_API.g_miss_num THEN
      x_complete_rec.end_position := l_list_src_field_rec.end_position;
   END IF;

   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_list_src_field_Rec;
PROCEDURE Validate_list_src_field(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_list_src_field_rec               IN   list_src_field_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_List_Src_Field';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_list_src_field_rec  AMS_List_Src_Field_PVT.list_src_field_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_List_Src_Field_;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;



      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
              Check_list_src_field_Items(
                 p_list_src_field_rec        => p_list_src_field_rec,
                 p_validation_mode   => JTF_PLSQL_API.g_update,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_list_src_field_Rec(
         p_list_src_field_rec        => p_list_src_field_rec,
         x_complete_rec        => l_list_src_field_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_list_src_field_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_list_src_field_rec           =>    l_list_src_field_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_List_Src_Field_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_List_Src_Field_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_List_Src_Field_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Validate_List_Src_Field;


PROCEDURE Validate_list_src_field_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_list_src_field_rec               IN    list_src_field_rec_type
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Hint: Validate data
      -- If data not valid
      -- THEN
      -- x_return_status := FND_API.G_RET_STS_ERROR;

      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_list_src_field_Rec;

END AMS_List_Src_Field_PVT;

/
