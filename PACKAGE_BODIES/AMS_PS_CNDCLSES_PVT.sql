--------------------------------------------------------
--  DDL for Package Body AMS_PS_CNDCLSES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_PS_CNDCLSES_PVT" as
/* $Header: amsvcclb.pls 120.0 2005/05/31 16:43:01 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Ps_Cndclses_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ========================================================

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Ps_Cndclses_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvcclb.pls';

AMS_DEBUG_HIGH_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

-- Hint: Primary key needs to be returned.
PROCEDURE Create_Ps_Cndclses(
    p_api_version_number  IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,

    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,

    p_ps_cndclses_rec     IN  ps_cndclses_rec_type := g_miss_ps_cndclses_rec,
    x_cnd_clause_id       OUT NOCOPY NUMBER
   )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Ps_Cndclses';
L_API_VERSION_NUMBER        CONSTANT NUMBER := 1.0;

TYPE str_tab is TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_CND_CLAUSE_ID             NUMBER;
   l_dummy       NUMBER;
   l_str_tab	str_tab;
   l_temp_refcode   VARCHAR2(30);
   l_ref_code       VARCHAR2(30);

   CURSOR c_id IS
      SELECT AMS_IBA_PS_CNDCLSES_B_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_IBA_PS_CNDCLSES_B
      WHERE CND_CLAUSE_ID = l_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Ps_Cndclses_PVT;

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

   IF p_ps_cndclses_rec.CND_CLAUSE_ID IS NULL OR p_ps_cndclses_rec.CND_CLAUSE_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_CND_CLAUSE_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_CND_CLAUSE_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   END IF;

   -- ====================================================
   -- Validate Environment
   -- ====================================================

      IF FND_GLOBAL.User_Id IS NULL
      THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Ps_Cndclses');
          END IF;

          -- Invoke validation procedures
          Validate_ps_cndclses(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_ps_cndclses_rec  =>  p_ps_cndclses_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

     -- Debug Message
     IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('Private API: Calling create table handler');
     END IF;

     select CND_CLAUSE_REF_CODE bulk collect into l_str_tab
     from ams_iba_ps_cndclses_b
     order by CND_CLAUSE_REF_CODE;

     if (SQL%NOTFOUND) then
        l_ref_code := 'CV1';
     else
        -- there is at least one condition clause
        for i in 1..l_str_tab.count
	loop
          l_temp_refcode := 'CV'||to_char(i);
	  if l_str_tab(i) <>  l_temp_refcode then
	    l_ref_code := l_temp_refcode;
	    exit;
          end if;
	end loop;

	if l_ref_code is null then
	   l_ref_code := 'CV'||to_char(l_str_tab.count + 1);
	end if;

     End If;

      -- Invoke table handler(AMS_IBA_PS_CNDCLSES_B_PKG.Insert_Row)
      AMS_IBA_PS_CNDCLSES_B_PKG.Insert_Row(
          p_created_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          px_object_version_number  => l_object_version_number,
          px_cnd_clause_id  => l_cnd_clause_id,
          p_cnd_clause_datatype  => p_ps_cndclses_rec.cnd_clause_datatype,
          p_cnd_clause_ref_code  => l_ref_code,
          p_cnd_comp_operator  => p_ps_cndclses_rec.cnd_comp_operator,
          p_cnd_default_value  => p_ps_cndclses_rec.cnd_default_value,
	  p_cnd_clause_name => p_ps_cndclses_rec.cnd_clause_name,
	  p_cnd_clause_description => p_ps_cndclses_rec.cnd_clause_description);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
--
-- End of API body
--

      x_cnd_clause_id := l_cnd_clause_id;

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
        (p_count => x_msg_count,
         p_data  => x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Ps_Cndclses_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Ps_Cndclses_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Ps_Cndclses_PVT;
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
End Create_Ps_Cndclses;


PROCEDURE Update_Ps_Cndclses(
    p_api_version_number     IN  NUMBER,
    p_init_msg_list          IN  VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN  VARCHAR2  := FND_API.G_FALSE,
    p_validation_level       IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,

    x_return_status          OUT NOCOPY  VARCHAR2,
    x_msg_count              OUT NOCOPY  NUMBER,
    x_msg_data               OUT NOCOPY  VARCHAR2,

    p_ps_cndclses_rec        IN    ps_cndclses_rec_type,
    x_object_version_number  OUT NOCOPY  NUMBER
   )

 IS

CURSOR c_get_ps_cndclses(p_cnd_clause_id NUMBER) IS
    SELECT *
    FROM  AMS_IBA_PS_CNDCLSES_B
    WHERE cnd_clause_id = p_cnd_clause_id;
    -- Hint: Developer need to provide Where clause

L_API_NAME             CONSTANT VARCHAR2(30) := 'Update_Ps_Cndclses';
L_API_VERSION_NUMBER   CONSTANT NUMBER  := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_CND_CLAUSE_ID    NUMBER;
l_ref_ps_cndclses_rec  c_get_Ps_Cndclses%ROWTYPE ;
l_tar_ps_cndclses_rec  AMS_Ps_Cndclses_PVT.ps_cndclses_rec_type := P_ps_cndclses_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Ps_Cndclses_PVT;

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
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');
      END IF;

--/*
      OPEN c_get_Ps_Cndclses( l_tar_ps_cndclses_rec.cnd_clause_id);

      FETCH c_get_Ps_Cndclses INTO l_ref_ps_cndclses_rec  ;

       If ( c_get_Ps_Cndclses%NOTFOUND) THEN
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Ps_Cndclses') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_Ps_Cndclses;
--*/

      If (l_tar_ps_cndclses_rec.object_version_number is NULL or
          l_tar_ps_cndclses_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_ps_cndclses_rec.object_version_number <> l_ref_ps_cndclses_rec.object_version_number) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Ps_Cndclses') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Ps_Cndclses');
          END IF;

          -- Invoke validation procedures
          Validate_ps_cndclses(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_ps_cndclses_rec  =>  p_ps_cndclses_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      -- IF (AMS_DEBUG_HIGH_ON) THEN  AMS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler'); END IF;

      -- Invoke table handler(AMS_IBA_PS_CNDCLSES_B_PKG.Update_Row)
      AMS_IBA_PS_CNDCLSES_B_PKG.Update_Row(
          p_created_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          p_object_version_number  => p_ps_cndclses_rec.object_version_number,
          p_cnd_clause_id  => p_ps_cndclses_rec.cnd_clause_id,
          p_cnd_clause_datatype  => p_ps_cndclses_rec.cnd_clause_datatype,
          p_cnd_clause_ref_code  => p_ps_cndclses_rec.cnd_clause_ref_code,
          p_cnd_comp_operator  => p_ps_cndclses_rec.cnd_comp_operator,
          p_cnd_default_value  => p_ps_cndclses_rec.cnd_default_value,
          p_cnd_clause_name => p_ps_cndclses_rec.cnd_clause_name,
          p_cnd_clause_description => p_ps_cndclses_rec.cnd_clause_description);

      --
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
     ROLLBACK TO UPDATE_Ps_Cndclses_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Ps_Cndclses_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Ps_Cndclses_PVT;
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
End Update_Ps_Cndclses;


PROCEDURE Delete_Ps_Cndclses(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN   VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2,
    p_cnd_clause_id         IN   NUMBER,
    p_object_version_number IN   NUMBER
   )

 IS
L_API_NAME               CONSTANT VARCHAR2(30) := 'Delete_Ps_Cndclses';
L_API_VERSION_NUMBER     CONSTANT NUMBER   := 1.0;
l_object_version_number  NUMBER;
l_wclause	VARCHAR2(100);
l_query		VARCHAR2(100);
l_count		Number;
l_cnd_rcode	VARCHAR2(30);

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Ps_Cndclses_PVT;

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

      select cnd_clause_ref_code into l_cnd_rcode
      from ams_iba_ps_cndclses_b
      where cnd_clause_id = p_cnd_clause_id;

      select decode(l_cnd_rcode,'CV1', 'use_clause6',
				'CV2', 'use_clause7',
				'CV3', 'use_clause8',
				'CV4', 'use_clause9',
				'CV5', 'use_clause10')
      into l_wclause
      from dual;

      l_query := 'select count(*) from ams_iba_ps_rules where ';
      execute immediate l_query || l_wclause || ' = ''Y''' into l_count;

      if l_count > 0 then
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
       THEN
          FND_MESSAGE.set_name('AMS','AMS_POST_COND_IN_USE');
          FND_MSG_PUB.add;
       END IF;
       RAISE FND_API.g_exc_error;
      end if;

      --
      -- Api body
      --
      -- Debug Message

     IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('Private API: Calling delete table handler');

     END IF;

      -- Invoke table handler(AMS_IBA_PS_CNDCLSES_B_PKG.Delete_Row)
      AMS_IBA_PS_CNDCLSES_B_PKG.Delete_Row(
          p_CND_CLAUSE_ID  => p_CND_CLAUSE_ID);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean(p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count  =>  x_msg_count,
         p_data   =>  x_msg_data
      );

 EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
   AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Ps_Cndclses_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Ps_Cndclses_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Ps_Cndclses_PVT;
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
End Delete_Ps_Cndclses;


-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Ps_Cndclses(
    p_api_version_number  IN   NUMBER,
    p_init_msg_list       IN   VARCHAR2  := FND_API.G_FALSE,

    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,

    p_cnd_clause_id       IN  NUMBER,
    p_object_version      IN  NUMBER
    )

 IS
L_API_NAME              CONSTANT VARCHAR2(30) := 'Lock_Ps_Cndclses';
L_API_VERSION_NUMBER    CONSTANT NUMBER   := 1.0;
L_FULL_NAME             CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_CND_CLAUSE_ID         NUMBER;

CURSOR c_Ps_Cndclses IS
   SELECT CND_CLAUSE_ID
   FROM AMS_IBA_PS_CNDCLSES_B
   WHERE CND_CLAUSE_ID = p_CND_CLAUSE_ID
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
  OPEN c_Ps_Cndclses;

  FETCH c_Ps_Cndclses INTO l_CND_CLAUSE_ID;

  IF (c_Ps_Cndclses%NOTFOUND) THEN
    CLOSE c_Ps_Cndclses;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Ps_Cndclses;

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
     ROLLBACK TO LOCK_Ps_Cndclses_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Ps_Cndclses_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Ps_Cndclses_PVT;
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
End Lock_Ps_Cndclses;


PROCEDURE check_ps_cndclses_uk_items(
    p_ps_cndclses_rec  IN  ps_cndclses_rec_type,
    p_validation_mode  IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status    OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_IBA_PS_CNDCLSES_B',
         'CND_CLAUSE_ID = ''' || p_ps_cndclses_rec.CND_CLAUSE_ID ||''''
         );
      ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_IBA_PS_CNDCLSES_B',
         'CND_CLAUSE_ID = ''' || p_ps_cndclses_rec.CND_CLAUSE_ID ||
         ''' AND CND_CLAUSE_ID <> ' || p_ps_cndclses_rec.CND_CLAUSE_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_CND_CLAUSE_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

END check_ps_cndclses_uk_items;

PROCEDURE check_ps_cndclses_req_items(
    p_ps_cndclses_rec               IN  ps_cndclses_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
/*
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_ps_cndclses_rec.created_by = FND_API.g_miss_num OR p_ps_cndclses_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_cndclses_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_cndclses_rec.creation_date = FND_API.g_miss_date OR p_ps_cndclses_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_cndclses_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_cndclses_rec.last_updated_by = FND_API.g_miss_num OR p_ps_cndclses_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_cndclses_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_cndclses_rec.last_update_date = FND_API.g_miss_date OR p_ps_cndclses_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_cndclses_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_cndclses_rec.cnd_clause_id = FND_API.g_miss_num OR p_ps_cndclses_rec.cnd_clause_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_cndclses_NO_cnd_clause_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE


      IF p_ps_cndclses_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_cndclses_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_cndclses_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_cndclses_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_cndclses_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_cndclses_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_cndclses_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_cndclses_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_cndclses_rec.cnd_clause_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_cndclses_NO_cnd_clause_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
*/
END check_ps_cndclses_req_items;

PROCEDURE check_ps_cndclses_FK_items(
    p_ps_cndclses_rec IN ps_cndclses_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_ps_cndclses_FK_items;

PROCEDURE check_ps_cndclses_Lookup_items(
    p_ps_cndclses_rec IN ps_cndclses_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_ps_cndclses_Lookup_items;

PROCEDURE Check_ps_cndclses_Items (
    P_ps_cndclses_rec     IN    ps_cndclses_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_ps_cndclses_uk_items(
      p_ps_cndclses_rec => p_ps_cndclses_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_ps_cndclses_req_items(
      p_ps_cndclses_rec => p_ps_cndclses_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   check_ps_cndclses_FK_items(
      p_ps_cndclses_rec => p_ps_cndclses_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

   check_ps_cndclses_Lookup_items(
      p_ps_cndclses_rec => p_ps_cndclses_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_ps_cndclses_Items;

/*
PROCEDURE Complete_ps_cndclses_Rec (
    P_ps_cndclses_rec     IN    ps_cndclses_rec_type,
     x_complete_rec        OUT NOCOPY    ps_cndclses_rec_type
    )
*/

PROCEDURE Complete_ps_cndclses_Rec (
   p_ps_cndclses_rec IN ps_cndclses_rec_type,
   x_complete_rec OUT NOCOPY ps_cndclses_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_iba_ps_cndclses_b
      WHERE cnd_clause_id = p_ps_cndclses_rec.cnd_clause_id;
   l_ps_cndclses_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_ps_cndclses_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_ps_cndclses_rec;
   CLOSE c_complete;

   -- created_by
   IF p_ps_cndclses_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_ps_cndclses_rec.created_by;
   END IF;

   -- creation_date
   IF p_ps_cndclses_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_ps_cndclses_rec.creation_date;
   END IF;

   -- last_updated_by
   IF p_ps_cndclses_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_ps_cndclses_rec.last_updated_by;
   END IF;

   -- last_update_date
   IF p_ps_cndclses_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_ps_cndclses_rec.last_update_date;
   END IF;

   -- last_update_login
   IF p_ps_cndclses_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_ps_cndclses_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_ps_cndclses_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_ps_cndclses_rec.object_version_number;
   END IF;

   -- cnd_clause_id
   IF p_ps_cndclses_rec.cnd_clause_id = FND_API.g_miss_num THEN
      x_complete_rec.cnd_clause_id := l_ps_cndclses_rec.cnd_clause_id;
   END IF;

   -- cnd_clause_datatype
   IF p_ps_cndclses_rec.cnd_clause_datatype = FND_API.g_miss_char THEN
      x_complete_rec.cnd_clause_datatype := l_ps_cndclses_rec.cnd_clause_datatype;
   END IF;

   -- cnd_clause_ref_code
   IF p_ps_cndclses_rec.cnd_clause_ref_code = FND_API.g_miss_char THEN
      x_complete_rec.cnd_clause_ref_code := l_ps_cndclses_rec.cnd_clause_ref_code;
   END IF;

   -- cnd_comp_operator
   IF p_ps_cndclses_rec.cnd_comp_operator = FND_API.g_miss_char THEN
      x_complete_rec.cnd_comp_operator := l_ps_cndclses_rec.cnd_comp_operator;
   END IF;

   -- cnd_default_value
   IF p_ps_cndclses_rec.cnd_default_value = FND_API.g_miss_char THEN
      x_complete_rec.cnd_default_value := l_ps_cndclses_rec.cnd_default_value;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_ps_cndclses_Rec;
PROCEDURE Validate_ps_cndclses(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_ps_cndclses_rec               IN   ps_cndclses_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Ps_Cndclses';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_ps_cndclses_rec  AMS_Ps_Cndclses_PVT.ps_cndclses_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Ps_Cndclses_;

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
              Check_ps_cndclses_Items(
                 p_ps_cndclses_rec        => p_ps_cndclses_rec,
                 p_validation_mode   => JTF_PLSQL_API.g_update,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;
/*
      Complete_ps_cndclses_Rec(
         p_ps_cndclses_rec        => p_ps_cndclses_rec,
         x_complete_rec        => l_ps_cndclses_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_ps_cndclses_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_ps_cndclses_rec           =>    l_ps_cndclses_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

*/
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
        (p_count => x_msg_count,
         p_data  => x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Ps_Cndclses_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Ps_Cndclses_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Ps_Cndclses_;
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
End Validate_Ps_Cndclses;


PROCEDURE Validate_ps_cndclses_rec(
    p_api_version_number IN   NUMBER,
    p_init_msg_list      IN   VARCHAR2 := FND_API.G_FALSE,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2,
    p_ps_cndclses_rec    IN  ps_cndclses_rec_type
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

      AMS_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count => x_msg_count,
         p_data  => x_msg_data
      );
END Validate_ps_cndclses_Rec;

END AMS_Ps_Cndclses_PVT;

/
