--------------------------------------------------------
--  DDL for Package Body AMS_ADV_FILTER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ADV_FILTER_PVT" as
/* $Header: amsvadfb.pls 120.1 2005/11/24 03:25:21 srivikri noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Adv_Filter_PVT
-- Purpose
--
-- History
-- 20-Aug-2003 rosharma Fixed bug 3104201.
-- 19-Sep-2003 rosharma Audience Data Sources Uptake.
--
-- NOTE
--
-- End of Comments
-- ===============================================================

---------------------------------------------------------------------
-- PROCEDURE
--    check_filter_changes
--
-- HISTORY
--    14-Oct-2002  nyostos  Check if the Filter record has changed
---------------------------------------------------------------------
PROCEDURE check_filter_changes(
   p_filter_rec     IN  filter_rec_type,
   x_rec_changed    OUT  NOCOPY  VARCHAR2
);


G_PKG_NAME CONSTANT VARCHAR2(30)  := 'AMS_Adv_Filter_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvadfb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;


PROCEDURE Create_Filter_Row
(
       p_api_version_number         IN   NUMBER,
       p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
       p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
       p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
       x_return_status              OUT  NOCOPY   VARCHAR2,
       x_msg_count                  OUT  NOCOPY   NUMBER,
       x_msg_data                   OUT  NOCOPY   VARCHAR2,
       p_filter_rec                 IN   filter_rec_type  := g_miss_filter_rec,
       x_query_param_id             OUT  NOCOPY  NUMBER
)

IS
   L_API_NAME                  CONSTANT VARCHAR2(30)  := 'Create_Filter_Row';
   L_API_VERSION_NUMBER        CONSTANT NUMBER        := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_org_id                    NUMBER                 := FND_API.G_MISS_NUM;
   l_query_param_id            NUMBER;
   l_dummy                     NUMBER;

   l_filter_rec  filter_rec_type := p_filter_rec;

   CURSOR c_id IS
      SELECT JTF_PERZ_QUERY_PARAM_S.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM JTF_PERZ_QUERY_PARAM
      WHERE QUERY_PARAM_ID = l_id;

   l_obj_type                 VARCHAR2(30);
   l_obj_id                   NUMBER;
   l_parameter_type           VARCHAR2(30);
   l_temp_str                 VARCHAR2(30);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Filter_Row_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Local variable initialization
      IF l_filter_rec.query_param_id IS NULL OR l_filter_rec.query_param_id = FND_API.g_miss_num THEN
         LOOP
            l_dummy := NULL;
            OPEN c_id;
            FETCH c_id INTO l_query_param_id;
            CLOSE c_id;

            OPEN c_id_exists(l_query_param_id);
            FETCH c_id_exists INTO l_dummy;
            CLOSE c_id_exists;
            EXIT WHEN l_dummy IS NULL;
          END LOOP;
      END IF;

      l_filter_rec.query_param_id   := l_query_param_id;
      l_filter_rec.created_by       := G_USER_ID;
      l_filter_rec.last_updated_by  := G_USER_ID;
      l_filter_rec.last_update_date := sysdate;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.User_Id IS NULL THEN
          AMS_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
          -- Debug message
          AMS_UTILITY_PVT.debug_message('Private API: Validate_Filter_Row');

          -- Invoke validation procedures
          Validate_Filter_Row(
            p_api_version_number     => 1.0,
            p_init_msg_list          => FND_API.G_FALSE,
            p_validation_level       => p_validation_level,
            p_validation_mode        => JTF_PLSQL_API.g_create,
            p_filter_rec             =>  l_filter_rec,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');


      AMS_ADV_FILTER_PKG.Insert_Row
      (
          px_query_param_id       => l_query_param_id,
          p_query_id              => l_filter_rec.query_id,
          p_parameter_name        => l_filter_rec.parameter_name,
          p_parameter_type        => l_filter_rec.parameter_type,
          p_parameter_value       => l_filter_rec.parameter_value,
          p_parameter_condition   => l_filter_rec.parameter_condition,
          p_parameter_sequence    => l_filter_rec.parameter_sequence,
          p_created_by            => l_filter_rec.created_by,
          p_last_updated_by       => l_filter_rec.last_updated_by,
          p_last_update_date      => l_filter_rec.last_update_date,
          p_last_update_login     => G_LOGIN_ID,
          p_security_group_id     => l_filter_rec.security_group_id
	   );

      x_query_param_id := l_query_param_id;

      -- Added by nyostos on Oct 14, 2002
      -- Adding a Filter record to a Model/Scoring Run data sets
      -- may INVALIDATE the Model if it has already been built or the Scoring
      -- Run if it has already run. Call the appropriate procedure to check.
      l_parameter_type := l_filter_rec.parameter_type;
      IF l_parameter_type IS NOT NULL AND l_parameter_type <> FND_API.g_miss_char THEN

         l_obj_type := SUBSTR(l_parameter_type, 1, INSTR(l_parameter_type, ';') - 1);

         IF l_obj_type IN ('MODL', 'SCOR') THEN

            l_temp_str := SUBSTR(l_parameter_type, 6, 30);
            l_obj_id := to_number(SUBSTR(l_temp_str, 1, INSTR(l_temp_str,';') - 1)) ;

            IF l_obj_type = 'MODL' THEN
               AMS_DM_MODEL_PVT.handle_data_selection_changes(l_obj_id);
            ELSE
               AMS_DM_SCORE_PVT.handle_data_selection_changes(l_obj_id);
            END IF;
         END IF;
      END IF;
      -- End of addition by nyostos.

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

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
      ROLLBACK TO CREATE_Filter_Row_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_Filter_Row_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO CREATE_Filter_Row_PVT;
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
End Create_Filter_Row;


PROCEDURE Update_Filter_Row(
    p_api_version_number         IN    NUMBER,
    p_init_msg_list              IN    VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN    VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN    NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT  NOCOPY   VARCHAR2,
    x_msg_count                  OUT  NOCOPY   NUMBER,
    x_msg_data                   OUT  NOCOPY   VARCHAR2,
    p_filter_rec                 IN    filter_rec_type
    )
IS

   CURSOR c_get_filter_row(p_query_param_id NUMBER) IS
    SELECT *
    FROM  JTF_PERZ_QUERY_PARAM
    WHERE query_param_id = p_query_param_id;

   L_API_NAME                 CONSTANT VARCHAR2(30)   := 'Update_Filter_Row';
   L_API_VERSION_NUMBER       CONSTANT NUMBER         := 1.0;
   l_filter_rec               filter_rec_type         := p_filter_rec;

   l_query_param_id           NUMBER;
   l_ref_filter_rec           c_get_filter_row%ROWTYPE ;
   l_tar_filter_rec           AMS_Adv_Filter_PVT.filter_rec_type  := p_filter_rec;
   l_rowid                    ROWID;

   l_rec_changed              VARCHAR2(1) := 'N';
   l_obj_type                 VARCHAR2(30);
   l_obj_id                   NUMBER;
   l_parameter_type           VARCHAR2(30);
   l_temp_str                 VARCHAR2(30);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Filter_Row_PVT;

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

      l_query_param_id := l_tar_filter_rec.query_param_id;

      OPEN c_get_Filter_row(l_tar_filter_rec.query_param_id);
      FETCH c_get_filter_row INTO l_ref_filter_rec  ;
      IF ( c_get_Filter_row%NOTFOUND) THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
                                      p_token_name   => 'INFO',
                                      p_token_value  => 'Filter_Row'
             ) ;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE     c_get_filter_row;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
         -- Debug message
         AMS_UTILITY_PVT.debug_message('Private API: Validate_Filter_Rec');

         -- Invoke validation procedures
         Validate_Filter_Row( p_api_version_number     => 1.0,
                              p_init_msg_list          => FND_API.G_FALSE,
                              p_validation_level       => p_validation_level,
                              p_validation_mode        => JTF_PLSQL_API.g_update,
                              p_filter_rec             =>  l_filter_rec,
                              x_return_status          => x_return_status,
                              x_msg_count              => x_msg_count,
                              x_msg_data               => x_msg_data);
      END IF;

      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Added by nyostos on Oct 14, 2002
      -- Check if the record has any changes
      check_filter_changes(p_filter_rec, l_rec_changed);

      AMS_UTILITY_PVT.debug_message('Private API: Before Calling Table Update Row');

      AMS_ADV_FILTER_PKG.Update_Row(
          px_query_param_id      => p_filter_rec.query_param_id,
          p_query_id             => p_filter_rec.query_id,
          p_parameter_name       => p_filter_rec.parameter_name,
          p_parameter_type       => p_filter_rec.parameter_type,
          p_parameter_value      => p_filter_rec.parameter_value,
          p_parameter_condition  => p_filter_rec.parameter_condition,
          p_parameter_sequence   => p_filter_rec.parameter_sequence,
          p_last_updated_by      => G_USER_ID,
          p_last_update_date     => SYSDATE,
          p_last_update_login    => G_LOGIN_ID,
          p_security_group_id    => p_filter_rec.security_group_id
        );

      AMS_UTILITY_PVT.debug_message('Private API: After Update Row');

      -- Added by nyostos on Oct 14, 2002
      -- Adding a Filter record to a Model/Scoring Run data sets
      -- may INVALIDATE the Model if it has already been built or the Scoring
      -- Run if it has already run. Call the appropriate procedure to check.
      l_parameter_type := p_filter_rec.parameter_type;

      IF l_rec_changed = 'Y' THEN
         IF l_parameter_type IS NOT NULL AND l_parameter_type <> FND_API.g_miss_char THEN

            l_obj_type := SUBSTR(l_parameter_type, 1, INSTR(l_parameter_type,';') - 1);

            IF l_obj_type IN ('MODL', 'SCOR') THEN

               l_temp_str := SUBSTR(l_parameter_type, 6, 30);
               l_obj_id := to_number(SUBSTR(l_temp_str, 1, INSTR(l_temp_str,';') - 1)) ;

               IF l_obj_type = 'MODL' THEN
                  AMS_DM_MODEL_PVT.handle_data_selection_changes(l_obj_id);
               ELSE
                  AMS_DM_SCORE_PVT.handle_data_selection_changes(l_obj_id);
               END IF;
            END IF;
         END IF;
      END IF;
      -- End of addition by nyostos.

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

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
     ROLLBACK TO UPDATE_Filter_Row_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Filter_Row_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Filter_Row_PVT;
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
End Update_Filter_Row;


PROCEDURE Delete_Filter_Row
   (
      p_api_version_number         IN   NUMBER,
      p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
      p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
      p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
      x_return_status              OUT  NOCOPY  VARCHAR2,
      x_msg_count                  OUT  NOCOPY  NUMBER,
      x_msg_data                   OUT  NOCOPY  VARCHAR2,
      p_query_param_id             IN  NUMBER
      )

IS

   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Filter_Row';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;

   CURSOR c_get_parameter_type(p_query_param_id NUMBER) IS
       SELECT parameter_type
       FROM  JTF_PERZ_QUERY_PARAM
       WHERE query_param_id = p_query_param_id;

   l_obj_type                 VARCHAR2(30);
   l_obj_id                   NUMBER;
   l_parameter_type           VARCHAR2(30);
   l_temp_str                 VARCHAR2(30);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Filter_Row_PVT;

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

      -- Get the parameter type
      OPEN  c_get_parameter_type(p_query_param_id);
      FETCH c_get_parameter_type INTO l_parameter_type;
      CLOSE c_get_parameter_type;

      --
      -- Api body
      --
      -- Debug Message
      AMS_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');

      AMS_ADV_FILTER_PKG.Delete_Row(
          p_query_param_id  => p_query_param_id);

      -- Added by nyostos on Oct 14, 2002
      -- Adding a Filter record to a Model/Scoring Run data sets
      -- may INVALIDATE the Model if it has already been built or the Scoring
      -- Run if it has already run. Call the appropriate procedure to check.
      IF l_parameter_type IS NOT NULL AND l_parameter_type <> FND_API.g_miss_char THEN

         l_obj_type := SUBSTR(l_parameter_type, 1, INSTR(l_parameter_type,';') - 1);

         IF l_obj_type IN ('MODL', 'SCOR') THEN

            l_temp_str := SUBSTR(l_parameter_type, 6, 30);
            l_obj_id := to_number(SUBSTR(l_temp_str, 1, INSTR(l_temp_str,';') - 1)) ;

            IF l_obj_type = 'MODL' THEN
               AMS_DM_MODEL_PVT.handle_data_selection_changes(l_obj_id);
            ELSE
               AMS_DM_SCORE_PVT.handle_data_selection_changes(l_obj_id);
            END IF;
         END IF;
      END IF;
      -- End of addition by nyostos.


      -- End of API body

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
     ROLLBACK TO DELETE_Filter_Row_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Filter_Row_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Filter_Row_PVT;
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
End Delete_Filter_Row;




PROCEDURE check_filter_row_uk_items
   (
     p_filter_rec                 IN   filter_rec_type,
     p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
     x_return_status              OUT  NOCOPY VARCHAR2
   )

IS

l_valid_flag  VARCHAR2(1);


BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
          l_valid_flag := 'T';
--          AMS_Utility_PVT.check_uniqueness(
--         'JTF_PERZ_QUERY_PARAM',
--         'query_param_id = 0'
--         || p_filter_rec.query_param_id ||''''
--        );
      ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'JTF_PERZ_QUERY_PARAM',
         'query_param_id= ''' || p_filter_rec.query_param_id ||
         ''' AND query_param_id <> ' || p_filter_rec.query_param_id
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
          AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_QUERY_PARAM_ID_DUPLICATE');
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
      END IF;

END check_filter_row_uk_items;

PROCEDURE check_filter_row_req_items
  (
    p_filter_rec           IN  filter_rec_type,
    p_validation_mode      IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	   OUT  NOCOPY VARCHAR2
)

IS

BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

      AMS_UTILITY_PVT.debug_message('Private API: Inside check_filter_row_req_items');

      IF p_filter_rec.query_id = FND_API.g_miss_num OR p_filter_rec.query_id IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','QUERY_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_filter_rec.parameter_name = FND_API.g_miss_char OR p_filter_rec.parameter_name IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','PAREMETER_NAME');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_filter_rec.parameter_type = FND_API.g_miss_char OR p_filter_rec.parameter_type IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','PARAMETER_NAME');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_filter_rec.parameter_value = FND_API.g_miss_char OR p_filter_rec.parameter_value IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','PAREMETER_VALUE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_filter_rec.parameter_condition = FND_API.g_miss_char OR p_filter_rec.parameter_condition IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','PAREMETER_CONDITION');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_filter_rec.created_by = FND_API.g_miss_num OR p_filter_rec.created_by IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','CREATED_BY');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_filter_rec.last_updated_by = FND_API.g_miss_num OR p_filter_rec.last_updated_by IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','LAST_UPDATED_BY');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_filter_rec.last_update_date = FND_API.g_miss_date OR p_filter_rec.last_update_date IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','LAST_UPDATE_DATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE

      IF p_filter_rec.query_param_id IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_Filter_row_no_query_param_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_filter_rec.query_id IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_Filter_row_no_query_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_filter_rec.parameter_name IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_Filter_row_no_parameter_name');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_filter_rec.parameter_type IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_Filter_row_no_parameter_type');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_filter_rec.parameter_value IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_Filter_row_no_parameter_value');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_filter_rec.parameter_condition IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_Filter_row_no_parameter_condition');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_filter_row_req_items;


PROCEDURE Check_filter_Items (
    p_filter_rec       IN    filter_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT  NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls
      AMS_UTILITY_PVT.debug_message('Private API: Inside Check Filter Items. Calling UK Items');
   check_filter_row_uk_items(
      p_filter_rec => p_filter_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_filter_row_req_items(
      p_filter_rec => p_filter_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_filter_Items;


PROCEDURE Complete_Filter_Rec
(
   p_filter_rec   IN filter_rec_type,
   x_complete_rec OUT  NOCOPY filter_rec_type
)

IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM jtf_perz_query_param
      WHERE query_param_id = p_filter_rec.query_param_id ;

   l_filter_rec c_complete%ROWTYPE;

BEGIN
   x_complete_rec := p_filter_rec;

   OPEN c_complete;
   FETCH c_complete INTO l_filter_rec;
   CLOSE c_complete;

   -- query_param_id
   IF p_filter_rec.query_param_id = FND_API.g_miss_num THEN
      x_complete_rec.query_param_id := l_filter_rec.query_param_id;
   END IF;

   -- parameter_name
   IF p_filter_rec.parameter_name = FND_API.g_miss_char THEN
      x_complete_rec.parameter_name := l_filter_rec.parameter_name;
   END IF;

   -- parameter_type
   IF p_filter_rec.parameter_type = FND_API.g_miss_char THEN
      x_complete_rec.parameter_type := l_filter_rec.parameter_type;
   END IF;

   -- parameter_value
   IF p_filter_rec.parameter_value = FND_API.g_miss_char THEN
      x_complete_rec.parameter_value := l_filter_rec.parameter_value;
   END IF;

   -- parameter_condition
   IF p_filter_rec.parameter_condition = FND_API.g_miss_char THEN
      x_complete_rec.parameter_condition := l_filter_rec.parameter_condition;
   END IF;


   -- created_by
   IF p_filter_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_filter_rec.created_by;
   END IF;


   -- last_updated_by
   IF p_filter_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_filter_rec.last_updated_by;
   END IF;

   -- last_update_date
   IF p_filter_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_filter_rec.last_update_date;
   END IF;

   -- last_update_login
   IF p_filter_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_filter_rec.last_update_login;
   END IF;

   -- security_group_id
   IF p_filter_rec.security_group_id = FND_API.g_miss_num THEN
      x_complete_rec.security_group_id := l_filter_rec.security_group_id;
   END IF;

END Complete_Filter_Rec;


PROCEDURE Validate_Filter_Row
(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_filter_rec                 IN   filter_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT  NOCOPY  VARCHAR2,
    x_msg_count                  OUT  NOCOPY  NUMBER,
    x_msg_data                   OUT  NOCOPY  VARCHAR2
)

IS

   L_API_NAME                  CONSTANT VARCHAR2(30)  := 'Validate_Filter_Row';
   L_API_VERSION_NUMBER        CONSTANT NUMBER        := 1.0;
   l_filter_rec                filter_rec_type        := p_filter_rec;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Filter_Row;

      AMS_UTILITY_PVT.debug_message('Private API: Inside' || l_api_name );

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
              Check_Filter_Items(
                 p_filter_rec        => p_filter_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;

      Complete_Filter_Rec(
         p_filter_rec          => p_filter_rec,
         x_complete_rec        => l_filter_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_Filter_Row_Rec
         (
            p_api_version_number     => 1.0,
            p_init_msg_list          => FND_API.G_FALSE,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data,
            p_filter_rec             => l_filter_rec
         );

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
     ROLLBACK TO VALIDATE_Filter_Row;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Filter_Row;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Filter_Row;
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
End Validate_Filter_Row;


PROCEDURE Validate_Filter_Row_Rec
   (
      p_api_version_number         IN   NUMBER,
      p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
      x_return_status              OUT  NOCOPY  VARCHAR2,
      x_msg_count                  OUT  NOCOPY  NUMBER,
      x_msg_data                   OUT  NOCOPY  VARCHAR2,
      p_filter_rec                 IN    filter_rec_type
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
END Validate_Filter_Row_Rec;


-- Procedure to get the Filter Record on the basis of parameters passed.

PROCEDURE Get_filter_data
(    p_objType             IN VARCHAR2,
     p_objectId            IN NUMBER,
     p_dataSourceId        IN NUMBER,
     x_return_status       OUT  NOCOPY VARCHAR2,
     x_msg_count           OUT  NOCOPY NUMBER,
     x_msg_data            OUT  NOCOPY VARCHAR2,
     x_filters             OUT  NOCOPY filter_rec_tbl_type
)

IS
  CURSOR c_queryId IS
  SELECT qry.query_id
  FROM  JTF_PERZ_PROFILE profile, JTF_PERZ_QUERY qry
  WHERE profile.profile_name = 'AMS_DEFAULT_PROFILE'
  AND   profile.profile_id   = qry.profile_id
  AND   qry.query_name       = 'advancedFilter';


--kbasavar 12/27/2004 modified for 3906434
  CURSOR c_filterRec(l_qid IN NUMBER ,l_ptype in VARCHAR2)  IS
  SELECT QParam.query_param_id ,QParam.parameter_name,QParam.parameter_type,QParam.parameter_value
         ,QParam.parameter_condition,QParam.parameter_sequence,QParam.created_by,QParam.last_updated_by
         ,QParam.last_update_date,QParam.last_update_login
  FROM   JTF_PERZ_QUERY Query, JTF_PERZ_QUERY_PARAM QParam, AMS_LIST_SRC_FIELDS Fields
  WHERE (Query.query_id = l_qid
              AND QParam.parameter_type = l_ptype
              AND QParam.parameter_name = fields.list_source_field_id
	      AND Query.query_id = QParam.query_id );

/*  SELECT query_param_id ,parameter_name,parameter_type,parameter_value
         ,parameter_condition,parameter_sequence,created_by,last_updated_by
         ,last_update_date,last_update_login
  FROM   jtf_perz_query_param
  WHERE  query_id = l_qid
  AND    parameter_type = l_ptype;
*/

  CURSOR c_fieldName(l_fieldId IN NUMBER , p_ds_id IN NUMBER) IS
  SELECT b.source_object_name || '.' || a.source_column_name
  FROM   ams_list_src_fields_vl a , ams_list_src_types b , ams_list_src_types d
  WHERE  a.list_source_field_id = l_fieldId
  AND    a.list_source_type_id = b.list_source_type_id
  AND    d.list_source_type_id = p_ds_id
  AND    d.enabled_flag = 'Y'
  AND    a.enabled_flag = 'Y'
  AND    b.enabled_flag = 'Y'
  AND    (EXISTS (SELECT 1 from ams_list_src_type_assocs c WHERE c.master_source_type_id = p_ds_id
                 AND c.sub_source_type_id = b.list_source_type_id AND  c.enabled_flag = 'Y')
          OR b.list_source_type_id = p_ds_id)
  ;

  l_nQueryId           NUMBER;
  l_curfilterRec       c_filterRec%ROWTYPE;
  l_filterRec          filter_rec_type;
  l_filterRec_tbl      filter_rec_tbl_type;
  l_iIndex             NUMBER;
  l_parameterType      VARCHAR2(60);
  l_fieldName          VARCHAR2(60);
  l_api_name           CONSTANT VARCHAR2(40) := 'Get_Filter_data';

BEGIN

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN c_queryId;
  FETCH c_queryId INTO l_nQueryId;
  CLOSE c_queryId;

  IF p_objType = FND_API.g_miss_char OR p_objType IS NULL THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_OBJ_TYPE');
        FND_MESSAGE.set_token('MISS_FIELD','OBJ_TYPE');
        x_return_status := FND_API.g_ret_sts_error;
        RETURN;
  END IF;
  IF p_objectId = FND_API.g_miss_num OR p_objType IS NULL THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_OBJECT_ID');
        FND_MESSAGE.set_token('MISS_FIELD','OBJECT_ID');
        x_return_status := FND_API.g_ret_sts_error;
        RETURN;
  END IF;
  IF p_dataSourceId = FND_API.g_miss_num OR p_dataSourceId IS NULL THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_DATASOURCE_ID');
        FND_MESSAGE.set_token('MISS_FIELD','DATASOURCE_ID');
        x_return_status := FND_API.g_ret_sts_error;
        RETURN;
  END IF;

  l_parameterType := p_objType||';'||to_char(p_objectId)||';'||to_char(p_dataSourceId);

  AMS_UTILITY_PVT.debug_message('Private API: ' || 'Get_filter_date ' || 'Parameter Name is:: ' || l_parameterType);

  l_iIndex := 0;

  OPEN c_filterRec(l_nQueryId,l_parameterType);

  LOOP
     FETCH c_filterRec INTO l_curfilterRec;
     EXIT WHEN c_FilterRec%NOTFOUND;

        OPEN c_fieldName(to_number(l_curfilterRec.parameter_name) , p_dataSourceId);
        FETCH c_fieldName INTO l_fieldName;
	IF c_fieldName%NOTFOUND THEN
	   CLOSE c_fieldName;
           AMS_UTILITY_PVT.debug_message('Disabled attribute/Disabled Data Source/Disabled Data Source Association....raising exception');
           AMS_Utility_PVT.error_message('AMS_FILTER_ATTRIBUTE_DISABLED');
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
        CLOSE c_fieldName;

        AMS_UTILITY_PVT.debug_message('Private API: ' || 'Get_filter_data ' || 'field Name is:: ' || l_fieldName);

        l_filterRec.query_param_id      := l_curfilterRec.query_param_id;
        l_filterRec.query_id            := l_nQueryId;
        l_filterRec.parameter_name      := l_fieldName;
        l_filterRec.parameter_type      := l_curfilterRec.parameter_type;
        l_filterRec.parameter_value     := l_curfilterRec.parameter_value;
        l_filterRec.parameter_condition := l_curfilterRec.parameter_condition;
        l_filterRec.parameter_sequence  := l_curfilterRec.parameter_sequence;
        l_filterRec.created_by          := l_curfilterRec.created_by;
        l_filterRec.last_updated_by     := l_curfilterRec.last_updated_by;
        l_filterRec.last_update_date    := l_curfilterRec.last_update_date;
        l_filterRec.last_update_login   := l_curfilterRec.last_update_login;

        l_iIndex := l_iIndex+1;

        l_filterRec_tbl(l_iIndex) := l_filterRec;


  END LOOP;

  CLOSE c_filterRec;

  x_filters := l_filterRec_tbl;

  FND_MSG_PUB.Count_And_Get
  ( p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
  );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    CLOSE c_filterRec;
    x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get
    (
           p_encoded => FND_API.G_FALSE,
           p_count   => x_msg_count,
           p_data    => x_msg_data
    );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get
     (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get
     (
            p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
            p_data  => x_msg_data
     );



END Get_filter_data;

---------------------------------------------------------------------
-- PROCEDURE
--    check_filter_changes
--
-- HISTORY
--    14-Oct-2002  nyostos  Check if the Filter record has changed
---------------------------------------------------------------------
PROCEDURE check_filter_changes(
   p_filter_rec     IN  filter_rec_type,
   x_rec_changed    OUT  NOCOPY VARCHAR2
)
IS

   CURSOR c_get_filter_row(p_query_param_id NUMBER) IS
    SELECT *
    FROM  JTF_PERZ_QUERY_PARAM
    WHERE query_param_id = p_query_param_id;

   l_ref_filter_rec  c_get_filter_row%ROWTYPE ;

BEGIN

   -- Initialize record changed flag to 'N'
   x_rec_changed := 'N';

   -- Open cursor to get the reference filter record.
   OPEN  c_get_filter_row (p_filter_rec.query_param_id);
   FETCH c_get_filter_row INTO l_ref_filter_rec;
   CLOSE c_get_filter_row;

   -- parameter_name
   IF (l_ref_filter_rec.parameter_name IS NULL AND p_filter_rec.parameter_name IS NOT NULL) OR
      (l_ref_filter_rec.parameter_name <> p_filter_rec.parameter_name) THEN
      x_rec_changed := 'Y';
      RETURN;
   END IF;

   -- parameter_type
   IF (l_ref_filter_rec.parameter_type IS NULL AND p_filter_rec.parameter_type IS NOT NULL) OR
      (l_ref_filter_rec.parameter_type <> p_filter_rec.parameter_type) THEN
      x_rec_changed := 'Y';
      RETURN;
   END IF;

   -- parameter_value
   IF (l_ref_filter_rec.parameter_value IS NULL AND p_filter_rec.parameter_value IS NOT NULL) OR
      (l_ref_filter_rec.parameter_value <> p_filter_rec.parameter_value) THEN
      x_rec_changed := 'Y';
      RETURN;
   END IF;

   -- parameter_condition
   IF (l_ref_filter_rec.parameter_condition IS NULL AND p_filter_rec.parameter_condition IS NOT NULL) OR
      (l_ref_filter_rec.parameter_condition <> p_filter_rec.parameter_condition) THEN
      x_rec_changed := 'Y';
      RETURN;
   END IF;

END check_filter_changes;

PROCEDURE copy_filter_data (
   p_api_version        IN NUMBER,
   p_init_msg_list      IN VARCHAR2 := FND_API.G_FALSE,
   p_commit             IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
   p_objType             IN VARCHAR2,
   p_old_objectId        IN NUMBER,
   p_new_objectId        IN NUMBER,
   p_dataSourceId        IN NUMBER,
   x_return_status      OUT  NOCOPY VARCHAR2,
   x_msg_count          OUT  NOCOPY NUMBER,
   x_msg_data           OUT  NOCOPY VARCHAR2
)
IS
   L_API_NAME           CONSTANT VARCHAR2(30) := 'copy_filter_data';
   L_API_VERSION_NUMBER CONSTANT NUMBER := 1.0;

   CURSOR c_fieldId(p_fieldName IN VARCHAR2 , p_ds_id IN NUMBER) IS
     SELECT to_char(list_source_field_id)
     FROM   ams_list_src_fields_vl
     WHERE  source_column_name = SUBSTR(p_fieldName , INSTR(p_fieldName , '.') + 1)
     AND    list_source_type_id = p_ds_id
     ;
   l_fieldName          VARCHAR2(60);

   --start kbasavar 4/23/2004 for bug 3565835
   CURSOR c_get_data_source(p_query_param_id IN NUMBER) IS
      SELECT Fields.LIST_SOURCE_TYPE_ID
      FROM JTF_PERZ_QUERY_PARAM QParam, AMS_LIST_SRC_FIELDS fields
      WHERE (QParam.QUERY_PARAM_ID = p_query_param_id AND QParam.parameter_name = fields.list_source_field_id );
   l_data_source NUMBER ;
   --end kbasavar 4/23/2004 for bug 3565835

   l_ref_filter_tbl     filter_rec_tbl_type;
   l_new_filter_rec     filter_rec_type;
   l_query_param_id     NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT ams_filter_pvt_copy_filter;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )THEN
      FND_MSG_PUB.initialize;
   END IF;

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start');

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Start of API body.
   --
   -- Get the adv filter records for passed object type and object id
   -- For each record, replace the parameter type and call create_filter_row
   get_filter_data (
	p_objType       => p_objType,
	p_objectId      => p_old_objectId,
	p_dataSourceId  => p_dataSourceId,
	x_return_status => x_return_status,
	x_msg_count     => x_msg_count,
	x_msg_data      => x_msg_data,
	x_filters       => l_ref_filter_tbl
   );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF l_ref_filter_tbl IS NULL THEN
   RETURN;
  END IF;

  IF l_ref_filter_tbl.COUNT = 0 THEN
   RETURN;
  END IF;

  FOR i IN 1..l_ref_filter_tbl.COUNT LOOP
     --start kbasavar 4/23/2004 for bug 3565835
     OPEN c_get_data_source(l_ref_filter_tbl(i).query_param_id);
        FETCH c_get_data_source INTO l_data_source;
     CLOSE c_get_data_source;
     --end kbasavar 4/23/2004 for bug 3565835
    OPEN  c_fieldId (l_ref_filter_tbl(i).parameter_name , l_data_source); --kbasavar 4/23/2004
     FETCH c_fieldId INTO l_fieldName;
    CLOSE c_fieldId;
    l_new_filter_rec.query_id              := l_ref_filter_tbl(i).query_id;
    l_new_filter_rec.parameter_name        := l_fieldName;
    l_new_filter_rec.parameter_type        := p_objType||';'||to_char(p_new_objectId)||';'||to_char(p_dataSourceId);
    l_new_filter_rec.parameter_value       := l_ref_filter_tbl(i).parameter_value;
    l_new_filter_rec.parameter_condition   := l_ref_filter_tbl(i).parameter_condition;
    l_new_filter_rec.parameter_sequence    := l_ref_filter_tbl(i).parameter_sequence;
    l_new_filter_rec.created_by            := G_USER_ID;
    l_new_filter_rec.last_updated_by       := G_USER_ID;
    l_new_filter_rec.last_update_date      := SYSDATE;
    l_new_filter_rec.security_group_id     := l_ref_filter_tbl(i).security_group_id;

    --create the filter row
    Create_Filter_Row
    (
	p_api_version_number         =>   1.0,
	p_init_msg_list              =>   FND_API.G_FALSE,
	p_commit                     =>   FND_API.G_FALSE,
	p_validation_level           =>   p_validation_level,
	x_return_status              =>   x_return_status,
	x_msg_count                  =>   x_msg_count,
	x_msg_data                   =>   x_msg_data,
	p_filter_rec                 =>   l_new_filter_rec,
	x_query_param_id             =>   l_query_param_id
    );
  END LOOP;

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
   --
   -- End of API body.
   --

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;


   -- Debug Message
   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' end');

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get (
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO ams_filter_pvt_copy_filter;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ams_filter_pvt_copy_filter;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO ams_filter_pvt_copy_filter;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );
END copy_filter_data;

END AMS_Adv_Filter_PVT;

/
