--------------------------------------------------------
--  DDL for Package Body AMS_LIST_QUERY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_QUERY_PVT" as
/* $Header: amsvliqb.pls 120.1 2005/09/20 05:50:34 aanjaria noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_List_Query_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_List_Query_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvliqb.pls';


AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Complete_list_query_Rec (
    P_list_query_rec     IN    list_query_rec_type,
     x_complete_rec        OUT NOCOPY    list_query_rec_type
    ) ;
PROCEDURE Complete_List_Query_Rec_tbl(
   p_listquery_rec IN  list_query_rec_type_tbl ,
   x_complete_rec     OUT NOCOPY list_query_rec_type_tbl
);
-- Hint: Primary key needs to be returned.
PROCEDURE Create_List_Query(
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                 IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level       IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status          OUT NOCOPY  VARCHAR2,
    x_msg_count              OUT NOCOPY  NUMBER,
    x_msg_data               OUT NOCOPY  VARCHAR2,
    p_list_query_rec         IN   list_query_rec_type  := g_miss_list_query_rec,
    x_list_query_id          OUT NOCOPY  NUMBER
     )

 IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_List_Query';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_LIST_QUERY_ID                  NUMBER;
   l_parent_list_query_id number;
   l_dummy       NUMBER;

   CURSOR c_id IS
      SELECT AMS_LIST_QUERIES_ALL_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1 FROM dual
      WHERE EXISTS (SELECT 1 FROM AMS_LIST_QUERIES_ALL
                    WHERE LIST_QUERY_ID = l_id);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_List_Query_PVT;

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
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

   IF p_list_query_rec.LIST_QUERY_ID IS NULL OR p_list_query_rec.LIST_QUERY_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_LIST_QUERY_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_LIST_QUERY_ID);
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
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_List_Query');
          END IF;

          -- Invoke validation procedures
          Validate_list_query(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_list_query_rec  =>  p_list_query_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      if  (p_list_query_rec.parent_list_query_id is null or
          p_list_query_rec.parent_list_query_id = FND_API.g_miss_num )then
          l_parent_list_query_id := l_list_query_id;
      else
          l_parent_list_query_id := p_list_query_rec.parent_list_query_id;
      end if;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Call create table handler');
      END IF;
      -- Invoke table handler(AMS_LIST_QUERIES_PKG.Insert_Row)
      AMS_LIST_QUERIES_PKG.Insert_Row(
          px_list_query_id  => l_list_query_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          px_object_version_number  => l_object_version_number,
          p_name  => p_list_query_rec.name,
          p_type  => p_list_query_rec.type,
          p_enabled_flag  => p_list_query_rec.enabled_flag,
          p_primary_key  => p_list_query_rec.primary_key,
          p_source_object_name => p_list_query_rec.source_object_name,
          p_public_flag  => p_list_query_rec.public_flag,
          px_org_id  => l_org_id,
          p_comments  => p_list_query_rec.comments,
          p_act_list_query_used_by_id
                         => p_list_query_rec.act_list_query_used_by_id,
          p_arc_act_list_query_used_by
                         => p_list_query_rec.arc_act_list_query_used_by,
          p_sql_string  => p_list_query_rec.sql_string,
          p_parent_list_query_id => l_parent_list_query_id,
          p_sequence_order       => p_list_query_rec.sequence_order);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      x_list_query_id := l_list_query_id;
--
-- End of API body
--

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

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
     ROLLBACK TO CREATE_List_Query_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_List_Query_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_List_Query_PVT;
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
End Create_List_Query;


PROCEDURE Create_List_Query(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level      IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_list_query_rec_tbl   IN   list_query_rec_type_tbl ,
    p_sql_string_tbl       in sql_string_tbl ,
    x_parent_list_query_id              OUT NOCOPY  NUMBER
     )   is
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_List_Query_tbl';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_list_query_rec            list_query_rec_type;
   l_list_query_id             number;
begin
     x_parent_list_query_id     := FND_API.g_miss_num;
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_List_Query_PVT_TBL;

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
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

   -- =========================================================================
   -- Validate Environment
   -- =========================================================================

      IF FND_GLOBAL.User_Id IS NULL
      THEN
        AMS_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      for i in 1 .. p_sql_string_tbl.last
      loop

         l_list_query_rec.LIST_QUERY_ID   := p_list_query_rec_tbl.LIST_QUERY_ID;
         l_list_query_rec.LAST_UPDATE_DATE   := p_list_query_rec_tbl.LAST_UPDATE_DATE;
         l_list_query_rec.LAST_UPDATED_BY   := p_list_query_rec_tbl.LAST_UPDATED_BY;
         l_list_query_rec.CREATION_DATE   := p_list_query_rec_tbl.CREATION_DATE;
         l_list_query_rec.CREATED_BY   := p_list_query_rec_tbl.CREATED_BY;
         l_list_query_rec.LAST_UPDATE_LOGIN   := p_list_query_rec_tbl.LAST_UPDATE_LOGIN;
         l_list_query_rec.OBJECT_VERSION_NUMBER   := p_list_query_rec_tbl.OBJECT_VERSION_NUMBER;
         l_list_query_rec.NAME   := p_list_query_rec_tbl.NAME;
         l_list_query_rec.TYPE   := p_list_query_rec_tbl.TYPE;
         l_list_query_rec.ENABLED_FLAG   := p_list_query_rec_tbl.ENABLED_FLAG;
         l_list_query_rec.PRIMARY_KEY   := p_list_query_rec_tbl.PRIMARY_KEY;
         l_list_query_rec.PUBLIC_FLAG   := p_list_query_rec_tbl.PUBLIC_FLAG;
         l_list_query_rec.ORG_ID   := p_list_query_rec_tbl.ORG_ID;
         l_list_query_rec.COMMENTS   := p_list_query_rec_tbl.COMMENTS;
         l_list_query_rec.ACT_LIST_QUERY_USED_BY_ID   :=
                                p_list_query_rec_tbl.ACT_LIST_QUERY_USED_BY_ID;
         l_list_query_rec.ARC_ACT_LIST_QUERY_USED_BY   :=
                                p_list_query_rec_tbl.ARC_ACT_LIST_QUERY_USED_BY;
         l_list_query_rec.SEED_FLAG   := p_list_query_rec_tbl.SEED_FLAG;
         l_list_query_rec.SQL_STRING  :=
                                 p_sql_string_tbl(i);
         l_list_query_rec.SOURCE_OBJECT_NAME   :=
                              p_list_query_rec_tbl.SOURCE_OBJECT_NAME;
         l_list_query_rec.PARENT_LIST_QUERY_ID   := x_parent_list_query_id ;
         l_list_query_rec.SEQUENCE_ORDER   := i;
        --IF (AMS_DEBUG_HIGH_ON) THENAMS_UTILITY_PVT.debug_message( 'Private API: Call create Query - Child');END IF;
      -- Invoke table handler(AMS_LIST_QUERIES_PKG.Insert_Row)
         Create_List_Query(
              p_api_version_number     => p_api_version_number,
              p_init_msg_list          => p_init_msg_list,
              p_commit                 => p_commit ,
              p_validation_level       => p_validation_level        ,
              x_return_status          => x_return_status           ,
              x_msg_count              => x_msg_count               ,
              x_msg_data               => x_msg_data   ,
              p_list_query_rec         => l_list_query_rec ,
              x_list_query_id          =>  l_list_query_id
         );
        if i = 1 then
           x_parent_list_query_id := l_list_query_id;
        end if;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
--
     end loop;
--
-- End of API body
--

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

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
     ROLLBACK TO CREATE_List_Query_PVT_TBL;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_List_Query_PVT_TBL;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_List_Query_PVT_TBL;
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
end create_list_query;

PROCEDURE Create_List_Query(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level      IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_list_query_rec_tbl     IN   list_query_rec_type_tbl  ,--:= g_miss_list_query_tbl          ,
    p_sql_string_tbl      in sql_string_tbl ,
    p_query_param          in sql_string_tbl ,
    x_parent_list_query_id              OUT NOCOPY  NUMBER
     )   is
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_List_Query_tbl';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_list_query_rec            list_query_rec_type;
   l_list_query_id             number;
     l_parent_list_query_id     number;
    l_return_status              VARCHAR2(2000);
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2(2000);
begin
     x_parent_list_query_id     := FND_API.g_miss_num;
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_List_Query_PVT_TBL_;

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
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

   -- =========================================================================
   -- Validate Environment
   -- =========================================================================

      IF FND_GLOBAL.User_Id IS NULL
      THEN
        AMS_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

     Create_List_Query(
    p_api_version_number    => p_api_version_number    ,
    p_init_msg_list         => p_init_msg_list         ,
    p_commit                => p_commit                ,
    p_validation_level      => p_validation_level      ,
    x_return_status         => l_return_status         ,
    x_msg_count            => l_msg_count             ,
    x_msg_data              => l_msg_data              ,
    p_list_query_rec_tbl   =>  p_list_query_rec_tbl   ,
    p_sql_string_tbl      => p_sql_string_tbl       ,
    x_parent_list_query_id             => l_parent_list_query_id
     )   ;
    x_return_status         :=  l_return_status         ;
    x_msg_count            :=  l_msg_count             ;
    x_msg_data              :=  l_msg_data              ;
    x_parent_list_query_id             := l_parent_list_query_id   ;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
  update ams_list_queries_all set parameterized_flag = 'Y'
  where parent_list_query_id = l_parent_list_query_id;
  delete from ams_list_queries_param
  where list_query_id = l_parent_list_query_id ;
  FOR I in p_query_param.first .. p_query_param.last
  loop
      INSERT INTO  AMS_LIST_QUERIES_PARAM(
         LIST_QUERY_PARAM_ID    ,
         LIST_QUERY_ID          ,
         LAST_UPDATE_DATE       ,
         LAST_UPDATED_BY        ,
         CREATION_DATE          ,
         CREATED_BY             ,
         LAST_UPDATE_LOGIN      ,
         OBJECT_VERSION_NUMBER  ,
         PARAMETER_ORDER        ,
         PARAMETER_VALUE
      )
      VALUES (
         AMS_LIST_QUERIES_PARAM_S.NEXTVAL
         ,l_parent_list_query_id
         ,SYSDATE
         ,FND_GLOBAL.User_Id
         ,SYSDATE
         ,FND_GLOBAL.User_Id
         ,FND_GLOBAL.Conc_Login_Id
         ,1
         ,i
         , p_query_param(i)
      ) ;
  end loop;
--
--
-- End of API body
--

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

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
     ROLLBACK TO CREATE_List_Query_PVT_TBL_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_List_Query_PVT_TBL_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_List_Query_PVT_TBL_;
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
end ;


PROCEDURE Update_List_Query(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_list_query_rec             IN    list_query_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS

CURSOR c_get_list_query(list_query_id NUMBER) IS
    SELECT *
    FROM  AMS_LIST_QUERIES_ALL
    WHERE list_query_id = p_list_query_rec.list_query_id;

    -- Hint: Developer need to provide Where clause

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_List_Query';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_LIST_QUERY_ID    NUMBER;
l_ref_list_query_rec  c_get_List_Query%ROWTYPE ;
l_tar_list_query_rec  AMS_List_Query_PVT.list_query_rec_type := P_list_query_rec;
l_list_query_rec  AMS_List_Query_PVT.list_query_rec_type := P_list_query_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_List_Query_PVT;

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
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      --IF (AMS_DEBUG_HIGH_ON) THENAMS_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');END IF;


      OPEN c_get_List_Query( l_tar_list_query_rec.list_query_id);

      FETCH c_get_List_Query INTO l_ref_list_query_rec  ;

       IF ( c_get_List_Query%NOTFOUND) THEN
          AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
                                        p_token_name   => 'INFO',
                                        p_token_value  => 'List_Query') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_List_Query;


      IF (l_tar_list_query_rec.object_version_number is NULL or
          l_tar_list_query_rec.object_version_number = FND_API.G_MISS_NUM ) THEN
            AMS_Utility_PVT.Error_Message(p_message_name
                                            => 'API_VERSION_MISSING',
                                          p_token_name   => 'COLUMN',
                                          p_token_value
                                                   => 'Object_version Number') ;
          raise FND_API.G_EXC_ERROR;
      END IF;

      -- Check Whether record has been changed by someone else
      IF (l_tar_list_query_rec.object_version_number <> l_ref_list_query_rec.object_version_number) THEN
           AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
                                         p_token_name   => 'INFO',
                                         p_token_value  => 'List_Query') ;
          raise FND_API.G_EXC_ERROR;
      END IF;

      Complete_list_query_Rec(
         p_list_query_rec      => p_list_query_rec,
         x_complete_rec        => l_list_query_rec
      );
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_List_Query');
          END IF;

          -- Invoke validation procedures
          Validate_list_query(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_list_query_rec  =>  l_list_query_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      -- IF (AMS_DEBUG_HIGH_ON) THEN  AMS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler'); END IF;


      -- Invoke table handler(AMS_LIST_QUERIES_PKG.Update_Row)
      AMS_LIST_QUERIES_PKG.Update_Row(
          p_list_query_id  => l_list_query_rec.list_query_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => l_list_query_rec.creation_date,
          p_created_by  => l_list_query_rec.created_by,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          p_object_version_number  => l_list_query_rec.object_version_number,
          p_name  => l_list_query_rec.name,
          p_type  => l_list_query_rec.type,
          p_enabled_flag  => l_list_query_rec.enabled_flag,
          p_primary_key  => l_list_query_rec.primary_key,
          p_source_object_name => l_list_query_rec.source_object_name,
          p_public_flag  => l_list_query_rec.public_flag,
          p_org_id  => l_list_query_rec.org_id,
          p_comments  => l_list_query_rec.comments,
          p_act_list_query_used_by_id  =>
                          l_list_query_rec.act_list_query_used_by_id,
          p_arc_act_list_query_used_by  =>
                          l_list_query_rec.arc_act_list_query_used_by,
          p_sql_string  => l_list_query_rec.sql_string,
          p_parent_list_query_id => p_list_query_rec.parent_list_query_id,
          p_sequence_order       => p_list_query_rec.sequence_order);
      --
      -- End of API body.
      --
      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

      --Set object version number
      x_object_version_number:=l_list_query_rec.object_version_number+1;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

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
     ROLLBACK TO UPDATE_List_Query_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_List_Query_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_List_Query_PVT;
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
End Update_List_Query;
PROCEDURE Update_List_Query(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_list_query_rec_tbl               IN    list_query_rec_type_tbl,
    p_sql_string_tbl       in sql_string_tbl ,
    x_object_version_number      OUT NOCOPY  NUMBER
    ) is


CURSOR c_get_list_query IS
    SELECT *
    FROM  AMS_LIST_QUERIES_ALL
    WHERE list_query_id = p_list_query_rec_tbl.parent_list_query_id;
cursor  c_get_list_count  is
    SELECT count(1)
    FROM  AMS_LIST_QUERIES_ALL
    WHERE parent_list_query_id = p_list_query_rec_tbl.parent_list_query_id;

    -- Hint: Developer need to provide Where clause

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_List_Query_tbl';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_LIST_QUERY_ID    NUMBER;
l_list_query_temp  number;
l_list_query_rec  AMS_List_Query_PVT.list_query_rec_type ;
l_list_query_rec_tbl  AMS_List_Query_PVT.list_query_rec_type_tbl ;
l_rowid  ROWID;
l_no_of_records  number;
l_no_of_records_upd  number;
l_parent_list_query_id number;
cursor c_get_query_id (cur_parent_query_id number,
                       cur_sequence_order  number) is
select list_query_id ,object_version_number
from   ams_list_queries_all
where parent_list_query_id = cur_parent_query_id
and   sequence_order = cur_sequence_order ;

cursor c_query(cur_parent_query_id number)  is
select query --sql_string column is obsolete bug 4604653
from   ams_list_queries_all
where parent_list_query_id = cur_parent_query_id;
l_sql_string  varchar2(4000);
l_sql_string_tbl  AMS_List_Query_PVT.sql_string_tbl   ;
j number:=0 ;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_List_Query_PVT_TBL;

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
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      --IF (AMS_DEBUG_HIGH_ON) THENAMS_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');END IF;


          IF (AMS_DEBUG_HIGH_ON) THEN





          AMS_UTILITY_PVT.debug_message('parent list header id'
                       ||  p_list_query_rec_tbl.PARENT_LIST_QUERY_ID );


          END IF;
       if p_list_query_rec_tbl.PARENT_LIST_QUERY_ID is null
        or p_list_query_rec_tbl.PARENT_LIST_QUERY_ID = FND_API.G_MISS_NUM then
         --gjoby Add proper message name
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Please Provide parent list header id' );
          END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       end if;

      open c_get_list_count  ;
          fetch c_get_list_count  into l_no_of_records ;
      close c_get_list_count  ;

      Complete_list_query_Rec_tbl (
            p_list_query_rec_tbl,
            l_list_query_rec_tbl
             );

      if p_sql_string_tbl.count = 0 then
         open c_query(p_list_query_rec_tbl.parent_list_query_id) ;
         loop
           fetch c_query  into l_sql_string;
           exit when c_query%notfound;
           j := j+1;
            l_sql_string_tbl(j) := l_sql_string;
         end loop;
         close c_query;
      else
         for j in 1 .. p_sql_string_tbl.last
         loop
             l_sql_string_tbl(j) := p_sql_string_tbl(j);
         end loop;
      end if;
      for i in 1 .. l_sql_string_tbl.last
      loop
         l_list_query_rec.LIST_QUERY_ID   := l_list_query_rec_tbl.LIST_QUERY_ID;
         l_list_query_rec.LAST_UPDATE_DATE   := l_list_query_rec_tbl.LAST_UPDATE_DATE;
         l_list_query_rec.LAST_UPDATED_BY   := l_list_query_rec_tbl.LAST_UPDATED_BY;
         l_list_query_rec.CREATION_DATE   := l_list_query_rec_tbl.CREATION_DATE;
         l_list_query_rec.CREATED_BY   := l_list_query_rec_tbl.CREATED_BY;
         l_list_query_rec.LAST_UPDATE_LOGIN   := l_list_query_rec_tbl.LAST_UPDATE_LOGIN;
         l_list_query_rec.OBJECT_VERSION_NUMBER   := l_list_query_rec_tbl.OBJECT_VERSION_NUMBER;
         l_list_query_rec.NAME   := l_list_query_rec_tbl.NAME;
         l_list_query_rec.TYPE   := l_list_query_rec_tbl.TYPE;
         l_list_query_rec.ENABLED_FLAG   := l_list_query_rec_tbl.ENABLED_FLAG;
         l_list_query_rec.PRIMARY_KEY   := l_list_query_rec_tbl.PRIMARY_KEY;
         l_list_query_rec.PUBLIC_FLAG   := l_list_query_rec_tbl.PUBLIC_FLAG;
         l_list_query_rec.ORG_ID   := l_list_query_rec_tbl.ORG_ID;
         l_list_query_rec.COMMENTS   := l_list_query_rec_tbl.COMMENTS;
         l_list_query_rec.ACT_LIST_QUERY_USED_BY_ID   :=
                                l_list_query_rec_tbl.ACT_LIST_QUERY_USED_BY_ID;
         l_list_query_rec.ARC_ACT_LIST_QUERY_USED_BY   :=
                                l_list_query_rec_tbl.ARC_ACT_LIST_QUERY_USED_BY;
         l_list_query_rec.SEED_FLAG   := l_list_query_rec_tbl.SEED_FLAG;
         l_list_query_rec.SQL_STRING  :=
                                  l_sql_string_tbl(i);
         l_list_query_rec.SOURCE_OBJECT_NAME   :=
                              l_list_query_rec_tbl.SOURCE_OBJECT_NAME;
         l_list_query_rec.PARENT_LIST_QUERY_ID   := l_list_query_rec_tbl.PARENT_LIST_QUERY_ID   ;
         l_list_query_rec.SEQUENCE_ORDER   := i;
        IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_UTILITY_PVT.debug_message( 'Private API: Child->' || i || '<-'
                          || '->' || l_no_of_records|| '<-');
        END IF;
        if i > l_no_of_records  then
        --IF (AMS_DEBUG_HIGH_ON) THENAMS_UTILITY_PVT.debug_message( 'Private API: Create Child->' || i || '<-');END IF;
         l_list_query_rec.LIST_QUERY_ID   := '';
             Create_List_Query(
                  p_api_version_number     => p_api_version_number,
                  p_init_msg_list          => p_init_msg_list,
                  p_commit                 => p_commit ,
                  p_validation_level       => p_validation_level        ,
                  x_return_status          => x_return_status           ,
                  x_msg_count              => x_msg_count               ,
                  x_msg_data               => x_msg_data   ,
                  p_list_query_rec         => l_list_query_rec ,
                  x_list_query_id          =>  l_list_query_id
             );
        else
        IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_UTILITY_PVT.debug_message( '->' || l_list_query_rec.sequence_order || '<-');
        END IF;
        open c_get_query_id (l_list_query_rec.parent_list_query_id,
                             l_list_query_rec.sequence_order);
        fetch c_get_query_id into l_list_query_rec.list_query_id,
                                  l_list_query_rec.object_version_number;
        IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_UTILITY_PVT.debug_message( '->' || l_list_query_rec.list_query_id || '<-');
        END IF;

               Update_List_Query(
                  p_api_version_number     => p_api_version_number,
                  p_init_msg_list          => p_init_msg_list,
                  p_commit                 => p_commit ,
                  p_validation_level       => p_validation_level        ,
                  x_return_status          => x_return_status           ,
                  x_msg_count              => x_msg_count               ,
                  x_msg_data               => x_msg_data   ,
                  p_list_query_rec         => l_list_query_rec ,
                  x_object_version_number  => l_object_version_number
    );
        IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_UTILITY_PVT.debug_message( '->' || x_return_status || '<-');
        END IF;
        close c_get_query_id ;

        end if;
        if i = 1 then
           l_parent_list_query_id := l_list_query_rec.parent_list_query_id;
        end if;

       l_no_of_records_upd  := i;
            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;
      end loop;
        IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_UTILITY_PVT.debug_message( '->' ||  l_no_of_records_upd  || '<-');
        END IF;
        IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_UTILITY_PVT.debug_message( '->' ||  l_parent_list_query_id  || '<-');
        END IF;
      delete from ams_list_queries_all
      where parent_list_query_id = l_parent_list_query_id
       and  sequence_order  > l_no_of_records_upd  ;


      -- End of API body.
      --
      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

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
     ROLLBACK TO UPDATE_List_Query_PVT_tbl;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_List_Query_PVT_tbl;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_List_Query_PVT_tbl;
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
END Update_List_Query;



PROCEDURE Delete_List_Query(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_list_query_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_List_Query';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_List_Query_PVT;

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
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
      END IF;

      -- Invoke table handler(AMS_LIST_QUERIES_PKG.Delete_Row)
      AMS_LIST_QUERIES_PKG.Delete_Row(
          p_LIST_QUERY_ID  => p_LIST_QUERY_ID);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

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
     ROLLBACK TO DELETE_List_Query_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_List_Query_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_List_Query_PVT;
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
End Delete_List_Query;

PROCEDURE Delete_parent_List_Query(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_parent_list_query_id       IN  NUMBER,
    p_object_version_number      IN   NUMBER
    ) is
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_List_Query';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

cursor c_get_child_ids
is select list_query_id
from ams_list_queries_all
where parent_list_query_id = p_parent_list_query_id ;
l_list_query_id  number;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_List_Query_PVT_tbl;

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
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
      END IF;

      open c_get_child_ids;
      loop
         fetch c_get_child_ids into  l_list_query_id  ;
         exit when c_get_child_ids%notfound;
         -- Invoke table handler(AMS_LIST_QUERIES_PKG.Delete_Row)
         AMS_LIST_QUERIES_PKG.Delete_Row(
             p_LIST_QUERY_ID  => l_LIST_QUERY_ID);
      end loop;
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

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
     ROLLBACK TO DELETE_List_Query_PVT_tbl;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_List_Query_PVT_tbl;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_List_Query_PVT_tbl;
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
END Delete_parent_List_Query;




-- Hint: Primary key needs to be returned.
PROCEDURE Lock_List_Query(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_list_query_id              IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_List_Query';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_LIST_QUERY_ID             NUMBER;

CURSOR c_List_Query IS
   SELECT LIST_QUERY_ID
   FROM AMS_LIST_QUERIES_ALL
   WHERE LIST_QUERY_ID = p_LIST_QUERY_ID
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

BEGIN

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;

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

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_Utility_PVT.debug_message(l_full_name||': start');

  END IF;
  OPEN c_List_Query;

  FETCH c_List_Query INTO l_LIST_QUERY_ID;

  IF (c_List_Query%NOTFOUND) THEN
    CLOSE c_List_Query;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_List_Query;

 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name ||': end');
  END IF;
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_List_Query_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_List_Query_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_List_Query_PVT;
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
End Lock_List_Query;


PROCEDURE check_list_query_uk_items(
    p_list_query_rec             IN   list_query_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

--changed vbhandar 03/22/2005 to fix FTS performance issue.Also created index see case change 4115572 bugs
cursor c_check_name
is select FND_API.g_FALSE
from ams_list_queries_vl
where  ( parent_list_query_id <> p_list_query_rec.parent_list_query_id
      or (parent_list_query_id is null
          and list_query_id <> p_list_query_rec.list_query_id ))
and    name   = p_list_query_rec.name ;
BEGIN
      x_return_status := FND_API.g_ret_sts_success;

      -- check for uniqueness of id
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_LIST_QUERIES_ALL',
         'LIST_QUERY_ID = ''' || p_list_query_rec.LIST_QUERY_ID ||''''
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_LIST_QUERY_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      -- check for uniqueness of name

      l_valid_flag := FND_API.g_true ;
      open c_check_name;
      fetch c_check_name into l_valid_flag;
      close c_check_name;


      IF l_valid_flag = FND_API.g_false THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message('parent id: ' || p_list_query_rec.parent_list_query_id );

      END IF;
                FND_MESSAGE.set_name('AMS', 'AMS_LIST_QUERY_DUPE_NAME');
                FND_MSG_PUB.add;
          END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
      END IF;

END check_list_query_uk_items;

PROCEDURE check_list_query_req_items(
    p_list_query_rec               IN  list_query_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

      IF p_list_query_rec.name = FND_API.g_miss_char OR p_list_query_rec.name IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_query_NO_name');
	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('AMS', 'AMS_LIST_QUERY_NO_NAME');
              FND_MSG_PUB.Add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


/*
      IF p_list_query_rec.act_list_query_used_by_id = FND_API.g_miss_num OR p_list_query_rec.act_list_query_used_by_id IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_query_NO_act_list_query_used_by_id');
	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('AMS', 'AMS_LIST_QUERY_NO_USEDBY_ID');
              FND_MSG_PUB.Add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;



      IF p_list_query_rec.arc_act_list_query_used_by = FND_API.g_miss_char OR p_list_query_rec.arc_act_list_query_used_by IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_query_NO_arc_act_list_query_used_by');
	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('AMS', 'AMS_LIST_QUERY_NO_USEDBY');
              FND_MSG_PUB.Add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

*/
     IF p_list_query_rec.sql_string = FND_API.g_miss_char OR p_list_query_rec.sql_string IS NULL THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('AMS', 'AMS_LIST_QUERY_NO_SQLSTRING');
              FND_MSG_PUB.Add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
     END IF;

 /* ------------------------ DON"T THINK I NEED IT BEGIN
      ELSE


      IF p_list_query_rec.list_query_id IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_query_NO_list_query_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


        IF p_list_query_rec.name IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_query_NO_name');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_list_query_rec.type IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_query_NO_type');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_list_query_rec.enabled_flag IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_query_NO_enabled_flag');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_list_query_rec.primary_key IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_query_NO_primary_key');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_list_query_rec.public_flag IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_query_NO_public_flag');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

*/------------------------ DON"T THINK I NEED IT END

   END IF;

END check_list_query_req_items;

PROCEDURE check_list_query_FK_items(
    p_list_query_rec IN list_query_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
l_table_name varchar2(100);
l_pk_name    varchar2(100);

BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_list_query_rec.arc_act_list_query_used_by <> FND_API.g_miss_char THEN

      AMS_Utility_PVT.get_qual_table_name_and_pk(
      p_sys_qual        => p_list_query_rec.arc_act_list_query_used_by,
      x_return_status   => x_return_status,
      x_table_name      => l_table_name,
      x_pk_name         => l_pk_name
      );

      IF x_return_status <> FND_API.g_ret_sts_success THEN
        RETURN;
      END IF;

      IF p_list_query_rec.act_list_query_used_by_id <> FND_API.g_miss_num THEN
         IF ( AMS_Utility_PVT.Check_FK_Exists(l_table_name
                                              , l_pk_name
                                              , p_list_query_rec.act_list_query_used_by_id)
                                              = FND_API.G_TRUE)
         THEN
                x_return_status := FND_API.G_RET_STS_SUCCESS;

         ELSE
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                       FND_MESSAGE.set_name('AMS', 'AMS_LIST_QRY_USEDBYID_INVALID');
                       FND_MSG_PUB.Add;
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
         END IF; -- end AMS_Utility_PVT.Check_FK_Exists
      END IF; -- end p_list_query_rec.act_list_query_used_by_id
   END IF; --end p_list_query_rec.arc_act_list_query_used_by <> FND_API.g_miss_char

END check_list_query_FK_items;

PROCEDURE check_list_query_Lookup_items(
    p_list_query_rec IN list_query_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

    ----------------------- arc_act_list_query_used_by  ------------------------
   IF p_list_query_rec.arc_act_list_query_used_by <> FND_API.g_miss_char THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_LIST_QUERY_TYPE',
            p_lookup_code => p_list_query_rec.arc_act_list_query_used_by
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_QUERY_USEDBY_INVALID');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_list_query_Lookup_items;

PROCEDURE Check_list_query_Items (
    P_list_query_rec     IN    list_query_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_list_query_uk_items(
      p_list_query_rec => p_list_query_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_list_query_req_items(
      p_list_query_rec => p_list_query_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   check_list_query_FK_items(
      p_list_query_rec => p_list_query_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

   check_list_query_Lookup_items(
      p_list_query_rec => p_list_query_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_list_query_Items;


PROCEDURE Complete_list_query_Rec (
    P_list_query_rec     IN    list_query_rec_type,
     x_complete_rec        OUT NOCOPY    list_query_rec_type
    )
IS
   CURSOR c_query IS
   SELECT *
   FROM ams_list_queries_all
   WHERE list_query_id = p_list_query_rec.list_query_id;

   l_query_rec  c_query%ROWTYPE;
BEGIN

    x_complete_rec := p_list_query_rec;

   OPEN c_query;
   FETCH c_query INTO l_query_rec;
   IF c_query%NOTFOUND THEN
      CLOSE c_query;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_query;


   IF p_list_query_rec.list_query_id = FND_API.g_miss_num THEN
    x_complete_rec.list_query_id   := l_query_rec.list_query_id;
   END IF;

   IF p_list_query_rec.last_update_date = FND_API.g_miss_date THEN
     x_complete_rec.last_update_date        := l_query_rec.last_update_date;
   END IF;

   IF p_list_query_rec.last_updated_by = FND_API.g_miss_num THEN
     x_complete_rec.last_updated_by         := l_query_rec.last_updated_by;
   END IF;

   IF p_list_query_rec.creation_date = FND_API.g_miss_date THEN
     x_complete_rec.creation_date           := l_query_rec.creation_date;
   END IF;

   IF p_list_query_rec.created_by = FND_API.g_miss_num THEN
    x_complete_rec.created_by              := l_query_rec.created_by;
   END IF;

   IF p_list_query_rec.last_update_login  = FND_API.g_miss_num THEN
    x_complete_rec.last_update_login       := l_query_rec.last_update_login;
   END IF;

   IF p_list_query_rec.object_version_number = FND_API.g_miss_num THEN
    x_complete_rec.object_version_number   := l_query_rec.object_version_number;
   END IF;

   IF p_list_query_rec.name = FND_API.g_miss_char THEN
     x_complete_rec.name            := l_query_rec.name;
   END IF;

   IF p_list_query_rec.type = FND_API.g_miss_char THEN
    x_complete_rec.type        := l_query_rec.type;
   END IF;


   IF p_list_query_rec.enabled_flag = FND_API.g_miss_char THEN
     x_complete_rec.enabled_flag    := l_query_rec.enabled_flag;
   END IF;

   IF p_list_query_rec.public_flag = FND_API.g_miss_char THEN
    x_complete_rec.public_flag             := l_query_rec.public_flag ;
   END IF;

   IF p_list_query_rec.org_id = FND_API.g_miss_num THEN
    x_complete_rec.org_id    := l_query_rec.org_id;
   END IF;

   IF p_list_query_rec.comments = FND_API.g_miss_char THEN
    x_complete_rec.comments    := l_query_rec.comments;
   END IF;

   IF p_list_query_rec.primary_key = FND_API.g_miss_char THEN
    x_complete_rec.primary_key             := l_query_rec.primary_key;
   END IF;

   IF p_list_query_rec.source_object_name = FND_API.g_miss_char THEN
    x_complete_rec.source_object_name  := l_query_rec.source_object_name;
   END IF;


   IF p_list_query_rec.arc_act_list_query_used_by  =  FND_API.g_miss_char THEN
     x_complete_rec.arc_act_list_query_used_by          := l_query_rec.arc_act_list_query_used_by;
   END IF;

   IF p_list_query_rec.act_list_query_used_by_id  =  FND_API.g_miss_num THEN
     x_complete_rec.act_list_query_used_by_id          := l_query_rec.act_list_query_used_by_id;
   END IF;

  IF p_list_query_rec.sql_string = FND_API.g_miss_char THEN
     x_complete_rec.sql_string          := l_query_rec.sql_string;
  END IF;
  IF p_list_query_rec.parent_list_query_id = FND_API.g_miss_num THEN
     x_complete_rec.parent_list_query_id  := l_query_rec.parent_list_query_id;
  END IF;
  IF p_list_query_rec.sequence_order = FND_API.g_miss_num THEN
     x_complete_rec.sequence_order  := l_query_rec.sequence_order;
  END IF;



END Complete_list_query_Rec;

PROCEDURE Validate_list_query(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_list_query_rec             IN   list_query_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_List_Query';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_list_query_rec  AMS_List_Query_PVT.list_query_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_List_Query_;

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
              Check_list_query_Items(
                 p_list_query_rec        => p_list_query_rec,
                 p_validation_mode   => JTF_PLSQL_API.g_update,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_list_query_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_list_query_rec           =>    l_list_query_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

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
     ROLLBACK TO VALIDATE_List_Query_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_List_Query_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_List_Query_;
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
End Validate_List_Query;


PROCEDURE Validate_list_query_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_list_query_rec               IN    list_query_rec_type
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
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: Validate_query__rec->'
                                 || x_return_status);
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_list_query_Rec;

PROCEDURE Init_List_query_Rec(
   x_listquery_rec  OUT NOCOPY  list_query_rec_type_tbl
)
IS
BEGIN
   x_listquery_rec.LIST_QUERY_ID   := FND_API.g_miss_num ;
   x_listquery_rec.LAST_UPDATE_DATE   := FND_API.g_miss_date ;
   x_listquery_rec.LAST_UPDATED_BY   := FND_API.g_miss_num ;
   x_listquery_rec.CREATION_DATE   := FND_API.g_miss_date ;
   x_listquery_rec.CREATED_BY   := FND_API.g_miss_num ;
   x_listquery_rec.LAST_UPDATE_LOGIN   := FND_API.g_miss_num ;
   x_listquery_rec.OBJECT_VERSION_NUMBER   := FND_API.g_miss_num ;
   x_listquery_rec.NAME   := FND_API.g_miss_char ;
   x_listquery_rec.TYPE   := FND_API.g_miss_char ;
   x_listquery_rec.ENABLED_FLAG   := FND_API.g_miss_char ;
   x_listquery_rec.PRIMARY_KEY   := FND_API.g_miss_char ;
   x_listquery_rec.PUBLIC_FLAG   := FND_API.g_miss_char ;
   x_listquery_rec.ORG_ID   := FND_API.g_miss_num ;
   x_listquery_rec.COMMENTS   := FND_API.g_miss_char ;
   x_listquery_rec.ACT_LIST_QUERY_USED_BY_ID   := FND_API.g_miss_num ;
   x_listquery_rec.ARC_ACT_LIST_QUERY_USED_BY   := FND_API.g_miss_char ;
   x_listquery_rec.SEED_FLAG   := FND_API.g_miss_char ;
   x_listquery_rec.SOURCE_OBJECT_NAME   := FND_API.g_miss_char ;
   x_listquery_rec.PARENT_LIST_QUERY_ID   := FND_API.g_miss_num ;
   x_listquery_rec.SEQUENCE_ORDER   := FND_API.g_miss_num ;
END Init_List_Query_rec;


PROCEDURE Init_List_query_Rec(
   x_listquery_rec  OUT NOCOPY  list_query_rec_type
)
IS
BEGIN
   x_listquery_rec.LIST_QUERY_ID   := FND_API.g_miss_num ;
   x_listquery_rec.LAST_UPDATE_DATE   := FND_API.g_miss_date ;
   x_listquery_rec.LAST_UPDATED_BY   := FND_API.g_miss_num ;
   x_listquery_rec.CREATION_DATE   := FND_API.g_miss_date ;
   x_listquery_rec.CREATED_BY   := FND_API.g_miss_num ;
   x_listquery_rec.LAST_UPDATE_LOGIN   := FND_API.g_miss_num ;
   x_listquery_rec.OBJECT_VERSION_NUMBER   := FND_API.g_miss_num ;
   x_listquery_rec.NAME   := FND_API.g_miss_char ;
   x_listquery_rec.TYPE   := FND_API.g_miss_char ;
   x_listquery_rec.ENABLED_FLAG   := FND_API.g_miss_char ;
   x_listquery_rec.PRIMARY_KEY   := FND_API.g_miss_char ;
   x_listquery_rec.PUBLIC_FLAG   := FND_API.g_miss_char ;
   x_listquery_rec.ORG_ID   := FND_API.g_miss_num ;
   x_listquery_rec.COMMENTS   := FND_API.g_miss_char ;
   x_listquery_rec.ACT_LIST_QUERY_USED_BY_ID   := FND_API.g_miss_num ;
   x_listquery_rec.ARC_ACT_LIST_QUERY_USED_BY   := FND_API.g_miss_char ;
   x_listquery_rec.SEED_FLAG   := FND_API.g_miss_char ;
   x_listquery_rec.SQL_STRING   := FND_API.g_miss_char ;
   x_listquery_rec.SOURCE_OBJECT_NAME   := FND_API.g_miss_char ;
   x_listquery_rec.PARENT_LIST_QUERY_ID   := FND_API.g_miss_num ;
   x_listquery_rec.SEQUENCE_ORDER   := FND_API.g_miss_num ;
END Init_List_Query_rec;

PROCEDURE Complete_List_Query_Rec_tbl(
   p_listquery_rec IN  list_query_rec_type_tbl ,
   x_complete_rec     OUT NOCOPY list_query_rec_type_tbl
)
IS

   CURSOR c_listquery IS
   SELECT *
   FROM   ams_list_queries_all
   WHERE list_query_id = p_listquery_rec.parent_list_query_id
     and sequence_order = 1;

   l_listquery_rec  c_listquery%ROWTYPE;

BEGIN

   x_complete_rec := p_listquery_rec;
   OPEN c_listquery;
   FETCH c_listquery INTO l_listquery_rec;
   IF c_listquery%NOTFOUND THEN
      CLOSE c_listquery;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_listquery;

   IF p_listquery_rec.LIST_QUERY_ID   = FND_API.g_miss_num THEN
         x_complete_rec.LIST_QUERY_ID   := l_listquery_rec.LIST_QUERY_ID;
   END IF;

   IF p_listquery_rec.LAST_UPDATE_DATE   = FND_API.g_miss_date THEN
         x_complete_rec.LAST_UPDATE_DATE   := l_listquery_rec.LAST_UPDATE_DATE;
   END IF;

   IF p_listquery_rec.LAST_UPDATED_BY   = FND_API.g_miss_num THEN
         x_complete_rec.LAST_UPDATED_BY   := l_listquery_rec.LAST_UPDATED_BY;
   END IF;


   IF p_listquery_rec.CREATION_DATE   = FND_API.g_miss_date THEN
         x_complete_rec.CREATION_DATE   := l_listquery_rec.CREATION_DATE;
   END IF;

   IF p_listquery_rec.CREATED_BY   = FND_API.g_miss_num THEN
         x_complete_rec.CREATED_BY   := l_listquery_rec.CREATED_BY;
   END IF;

   IF p_listquery_rec.LAST_UPDATE_LOGIN   = FND_API.g_miss_num THEN
         x_complete_rec.LAST_UPDATE_LOGIN   := l_listquery_rec.LAST_UPDATE_LOGIN;
   END IF;

   IF p_listquery_rec.OBJECT_VERSION_NUMBER   = FND_API.g_miss_num THEN
         x_complete_rec.OBJECT_VERSION_NUMBER   := l_listquery_rec.OBJECT_VERSION_NUMBER;
   END IF;

   IF p_listquery_rec.NAME   = FND_API.g_miss_char THEN
         x_complete_rec.NAME   := l_listquery_rec.NAME;
   END IF;

   IF p_listquery_rec.TYPE   = FND_API.g_miss_char THEN
         x_complete_rec.TYPE   := l_listquery_rec.TYPE;
   END IF;

   IF p_listquery_rec.ENABLED_FLAG   = FND_API.g_miss_char THEN
         x_complete_rec.ENABLED_FLAG   := l_listquery_rec.ENABLED_FLAG;
   END IF;

   IF p_listquery_rec.PRIMARY_KEY   = FND_API.g_miss_char THEN
         x_complete_rec.PRIMARY_KEY   := l_listquery_rec.PRIMARY_KEY;
   END IF;

   IF p_listquery_rec.PUBLIC_FLAG   = FND_API.g_miss_char THEN
         x_complete_rec.PUBLIC_FLAG   := l_listquery_rec.PUBLIC_FLAG;
   END IF;

   IF p_listquery_rec.ORG_ID   = FND_API.g_miss_num THEN
         x_complete_rec.ORG_ID   := l_listquery_rec.ORG_ID;
   END IF;

   IF p_listquery_rec.COMMENTS   = FND_API.g_miss_char THEN
         x_complete_rec.COMMENTS   := l_listquery_rec.COMMENTS;
   END IF;


   IF p_listquery_rec.ACT_LIST_QUERY_USED_BY_ID   = FND_API.g_miss_num THEN
         x_complete_rec.ACT_LIST_QUERY_USED_BY_ID   := l_listquery_rec.ACT_LIST_QUERY_USED_BY_ID;
   END IF;

   IF p_listquery_rec.ARC_ACT_LIST_QUERY_USED_BY   = FND_API.g_miss_char THEN
         x_complete_rec.ARC_ACT_LIST_QUERY_USED_BY   := l_listquery_rec.ARC_ACT_LIST_QUERY_USED_BY;
   END IF;

   IF p_listquery_rec.SEED_FLAG   = FND_API.g_miss_char THEN
         x_complete_rec.SEED_FLAG   := l_listquery_rec.SEED_FLAG;
   END IF;


   IF p_listquery_rec.SOURCE_OBJECT_NAME   = FND_API.g_miss_char THEN
         x_complete_rec.SOURCE_OBJECT_NAME   := l_listquery_rec.SOURCE_OBJECT_NAME;
   END IF;

   IF p_listquery_rec.PARENT_LIST_QUERY_ID   = FND_API.g_miss_num THEN
         x_complete_rec.PARENT_LIST_QUERY_ID   := l_listquery_rec.PARENT_LIST_QUERY_ID;
   END IF;

   IF p_listquery_rec.SEQUENCE_ORDER   = FND_API.g_miss_num THEN
         x_complete_rec.SEQUENCE_ORDER   := l_listquery_rec.SEQUENCE_ORDER;
   END IF;


END Complete_List_Query_rec_tbl;

PROCEDURE Complete_List_Query_Rec(
   p_listquery_rec IN  list_query_rec_type ,
   x_complete_rec     OUT NOCOPY list_query_rec_type
)
IS

   CURSOR c_listquery IS
   SELECT *
   FROM   ams_list_queries_all
   WHERE list_query_id = p_listquery_rec.list_query_id;

   l_listquery_rec  c_listquery%ROWTYPE;

BEGIN

   x_complete_rec := p_listquery_rec;
   OPEN c_listquery;
   FETCH c_listquery INTO l_listquery_rec;
   IF c_listquery%NOTFOUND THEN
      CLOSE c_listquery;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_listquery;

   IF p_listquery_rec.LIST_QUERY_ID   = FND_API.g_miss_num THEN
         x_complete_rec.LIST_QUERY_ID   := l_listquery_rec.LIST_QUERY_ID;
   END IF;

   IF p_listquery_rec.LAST_UPDATE_DATE   = FND_API.g_miss_date THEN
         x_complete_rec.LAST_UPDATE_DATE   := l_listquery_rec.LAST_UPDATE_DATE;
   END IF;

   IF p_listquery_rec.LAST_UPDATED_BY   = FND_API.g_miss_num THEN
         x_complete_rec.LAST_UPDATED_BY   := l_listquery_rec.LAST_UPDATED_BY;
   END IF;


   IF p_listquery_rec.CREATION_DATE   = FND_API.g_miss_date THEN
         x_complete_rec.CREATION_DATE   := l_listquery_rec.CREATION_DATE;
   END IF;

   IF p_listquery_rec.CREATED_BY   = FND_API.g_miss_num THEN
         x_complete_rec.CREATED_BY   := l_listquery_rec.CREATED_BY;
   END IF;

   IF p_listquery_rec.LAST_UPDATE_LOGIN   = FND_API.g_miss_num THEN
         x_complete_rec.LAST_UPDATE_LOGIN   := l_listquery_rec.LAST_UPDATE_LOGIN;
   END IF;

   IF p_listquery_rec.OBJECT_VERSION_NUMBER   = FND_API.g_miss_num THEN
         x_complete_rec.OBJECT_VERSION_NUMBER   := l_listquery_rec.OBJECT_VERSION_NUMBER;
   END IF;

   IF p_listquery_rec.NAME   = FND_API.g_miss_char THEN
         x_complete_rec.NAME   := l_listquery_rec.NAME;
   END IF;

   IF p_listquery_rec.TYPE   = FND_API.g_miss_char THEN
         x_complete_rec.TYPE   := l_listquery_rec.TYPE;
   END IF;

   IF p_listquery_rec.ENABLED_FLAG   = FND_API.g_miss_char THEN
         x_complete_rec.ENABLED_FLAG   := l_listquery_rec.ENABLED_FLAG;
   END IF;

   IF p_listquery_rec.PRIMARY_KEY   = FND_API.g_miss_char THEN
         x_complete_rec.PRIMARY_KEY   := l_listquery_rec.PRIMARY_KEY;
   END IF;

   IF p_listquery_rec.PUBLIC_FLAG   = FND_API.g_miss_char THEN
         x_complete_rec.PUBLIC_FLAG   := l_listquery_rec.PUBLIC_FLAG;
   END IF;

   IF p_listquery_rec.ORG_ID   = FND_API.g_miss_num THEN
         x_complete_rec.ORG_ID   := l_listquery_rec.ORG_ID;
   END IF;

   IF p_listquery_rec.COMMENTS   = FND_API.g_miss_char THEN
         x_complete_rec.COMMENTS   := l_listquery_rec.COMMENTS;
   END IF;


   IF p_listquery_rec.ACT_LIST_QUERY_USED_BY_ID   = FND_API.g_miss_num THEN
         x_complete_rec.ACT_LIST_QUERY_USED_BY_ID   := l_listquery_rec.ACT_LIST_QUERY_USED_BY_ID;
   END IF;

   IF p_listquery_rec.ARC_ACT_LIST_QUERY_USED_BY   = FND_API.g_miss_char THEN
         x_complete_rec.ARC_ACT_LIST_QUERY_USED_BY   := l_listquery_rec.ARC_ACT_LIST_QUERY_USED_BY;
   END IF;

   IF p_listquery_rec.SEED_FLAG   = FND_API.g_miss_char THEN
         x_complete_rec.SEED_FLAG   := l_listquery_rec.SEED_FLAG;
   END IF;

   IF p_listquery_rec.SQL_STRING   = FND_API.g_miss_char THEN
         x_complete_rec.SQL_STRING   := l_listquery_rec.SQL_STRING;
   END IF;

   IF p_listquery_rec.SOURCE_OBJECT_NAME   = FND_API.g_miss_char THEN
         x_complete_rec.SOURCE_OBJECT_NAME   := l_listquery_rec.SOURCE_OBJECT_NAME;
   END IF;

   IF p_listquery_rec.PARENT_LIST_QUERY_ID   = FND_API.g_miss_num THEN
         x_complete_rec.PARENT_LIST_QUERY_ID   := l_listquery_rec.PARENT_LIST_QUERY_ID;
   END IF;

   IF p_listquery_rec.SEQUENCE_ORDER   = FND_API.g_miss_num THEN
         x_complete_rec.SEQUENCE_ORDER   := l_listquery_rec.SEQUENCE_ORDER;
   END IF;


END Complete_List_Query_rec;

PROCEDURE Copy_List_Queries
( p_api_version              IN     NUMBER,
  p_init_msg_list            IN     VARCHAR2  := FND_API.G_FALSE,
  p_commit                   IN     VARCHAR2  := FND_API.G_FALSE,
  p_validation_level         IN     NUMBER    := FND_API.g_valid_level_full,
  p_source_listheader_id     IN     NUMBER,
  p_new_listheader_id        IN     NUMBER,
  p_new_listheader_name      IN     VARCHAR2,
  x_return_status            OUT NOCOPY    VARCHAR2,
  x_msg_count                OUT NOCOPY    NUMBER,
  x_msg_data                 OUT NOCOPY    VARCHAR2
)IS

l_api_name            CONSTANT VARCHAR2(30)  := 'Copy_List_Queries';
l_api_version         CONSTANT NUMBER        := 1.0;
j		      NUMBER:=0;

-- Status Local Variables
l_return_status                VARCHAR2(1);  -- Return value from procedures

--l_listheader_id                number;

x_rowid VARCHAR2(30);

l_sqlerrm varchar2(600);
l_sqlcode varchar2(100);

l_init_msg_list    VARCHAR2(2000)    := FND_API.G_FALSE;


CURSOR fetch_list_queries (listqueryId NUMBER) IS
  SELECT *
  FROM ams_list_queries_all
  WHERE parent_list_query_id =listqueryId
  ORDER BY sequence_order;

 CURSOR fetch_list_select_actions(list_id NUMBER) IS
      SELECT incl_object_id,rank,order_number,description,list_action_type
             ,no_of_rows_requested,no_of_rows_available,no_of_rows_used
	     ,distribution_pct,no_of_rows_targeted
      FROM ams_list_select_actions
      WHERE action_used_by_id =list_id
      AND arc_action_used_by='LIST'
      AND arc_incl_object_from='SQL';

l_list_queries_rec               fetch_list_queries%ROWTYPE;
l_action_rec                     AMS_ListAction_PVT.action_rec_type;

l_list_query_rec_type_tbl        list_query_rec_type_tbl;
l_sql_string_tbl                 sql_string_tbl;
l_parent_list_query_id           NUMBER;
l_action_id                      NUMBER;
BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT Copy_List_Queries_PVT;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  -- Initialize message list IF p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
     FND_MSG_PUB.initialize;
  END IF;

  -- Debug Message
  IF (AMS_DEBUG_HIGH_ON) THEN
     FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT', 'AMS_List_Query_PVT.Copy_List_Queries: Start', TRUE);
     FND_MSG_PUB.Add;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


 FOR l_list_actions_rec IN fetch_list_select_actions(p_source_listheader_id)
 LOOP

	   j:=0;
	   l_sql_string_tbl.DELETE;
	   Init_List_query_Rec(l_list_query_rec_type_tbl);

	   open fetch_list_queries(l_list_actions_rec.incl_object_id);
		 loop
		   fetch fetch_list_queries  into l_list_queries_rec;
   		   exit when fetch_list_queries%notfound;

		   IF l_list_queries_rec.list_query_id IS NOT NULL THEN
			--   l_list_query_rec_type_tbl.NAME   := p_new_listheader_name || l_list_queries_rec.NAME;
                           l_list_query_rec_type_tbl.NAME   :=substr(rpad(substr(l_list_queries_rec.NAME,1,150),150,' ')||p_new_listheader_id||'_'||p_new_listheader_name,1,240);
			   l_list_query_rec_type_tbl.TYPE   := l_list_queries_rec.TYPE ;
			   l_list_query_rec_type_tbl.ENABLED_FLAG   := l_list_queries_rec.ENABLED_FLAG ;
			   l_list_query_rec_type_tbl.PRIMARY_KEY   := l_list_queries_rec.PRIMARY_KEY ;
			   l_list_query_rec_type_tbl.PUBLIC_FLAG   := l_list_queries_rec.PUBLIC_FLAG ;
			   l_list_query_rec_type_tbl.SOURCE_OBJECT_NAME   := l_list_queries_rec.SOURCE_OBJECT_NAME;
			   j := j+1;
			   l_sql_string_tbl(j) := l_list_queries_rec.sql_string;
		   END IF;
		 end loop;
	    close fetch_list_queries;

	  IF l_list_queries_rec.list_query_id IS NOT NULL THEN

		   Create_List_Query(
		    l_api_version ,
		    l_init_msg_list,
		    p_commit,
		    p_validation_level ,
		    x_return_status,
		    x_msg_count,
		    x_msg_data ,
		    l_list_query_rec_type_tbl ,
		    l_sql_string_tbl ,
		    l_parent_list_query_id
		     ) ;

		    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		    RAISE FND_API.G_EXC_ERROR;
		    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		    END IF;

		    AMS_ListAction_PVT.init_action_rec(l_action_rec);
		  l_action_rec.list_select_action_id          := NULL;
		  l_action_rec.order_number          := l_list_actions_rec.order_number;
		  l_action_rec.list_action_type      := l_list_actions_rec.list_action_type;
		  l_action_rec.arc_incl_object_from  := 'SQL';
		  l_action_rec.incl_object_id        := l_parent_list_query_id;
		  l_action_rec.rank                  := l_list_actions_rec.rank;
		  l_action_rec.no_of_rows_available  := l_list_actions_rec.no_of_rows_available;
		  l_action_rec.no_of_rows_requested  := l_list_actions_rec.no_of_rows_requested;
		  l_action_rec.no_of_rows_used       := l_list_actions_rec.no_of_rows_used;
		  l_action_rec.distribution_pct      := l_list_actions_rec.distribution_pct;
		  l_action_rec.description           := l_list_actions_rec.description;
		  l_action_rec.arc_action_used_by    := 'LIST';
		  l_action_rec.action_used_by_id     := p_new_listheader_id;
 		  l_action_rec.no_of_rows_targeted  := l_list_actions_rec.no_of_rows_targeted;



		    AMS_ListAction_PVT.Create_ListAction
		   (l_api_version,
		    l_init_msg_list,
		    p_commit ,
		    p_validation_level,
		    x_return_status ,
		    x_msg_count,
		    x_msg_data,
		    l_action_rec,
		    l_action_id
		) ;

		 IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		    RAISE FND_API.G_EXC_ERROR;
		    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		    END IF;


	END IF; --l_list_queries_rec.list_query_id IS NOT NULL


 END LOOP;

      -- Standard check of p_commit.
      IF FND_API.To_Boolean ( p_commit ) THEN
           COMMIT WORK;
      END IF;

      -- Success Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
      THEN
            FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
            FND_MESSAGE.Set_Token('ROW', 'AMS_List_Query_PVT.Copy_List_Queries', TRUE);
            FND_MSG_PUB.Add;
      END IF;

      IF (AMS_DEBUG_HIGH_ON) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('TEXT', 'AMS_List_Query_PVT.Copy_List_Queries: END', TRUE);
            FND_MSG_PUB.Add;
      END IF;


      -- Standard call to get message count AND IF count is 1, get message info.
      FND_MSG_PUB.Count_AND_Get
          ( p_count        =>      x_msg_count,
            p_data         =>      x_msg_data,
            p_encoded      =>        FND_API.G_FALSE
          );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Copy_List_Queries_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR ;

      FND_MSG_PUB.Count_AND_Get
          ( p_count           =>      x_msg_count,
            p_data            =>      x_msg_data,
            p_encoded         =>      FND_API.G_FALSE
           );


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Copy_List_Queries_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_AND_Get
      ( p_count      =>      x_msg_count,
        p_data       =>      x_msg_data,
        p_encoded    =>      FND_API.G_FALSE
      );

   WHEN OTHERS THEN
      ROLLBACK TO Copy_List_Queries_PVT;
      FND_MESSAGE.set_name('AMS','SQL ERROR ->' || sqlerrm );
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                  p_encoded         =>      FND_API.G_FALSE
                );

END Copy_List_Queries;


END AMS_List_Query_PVT;

/
