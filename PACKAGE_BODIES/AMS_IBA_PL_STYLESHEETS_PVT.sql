--------------------------------------------------------
--  DDL for Package Body AMS_IBA_PL_STYLESHEETS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IBA_PL_STYLESHEETS_PVT" as
/* $Header: amsvstyb.pls 120.0 2005/05/31 17:49:40 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Iba_Pl_Stylesheets_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Iba_Pl_Stylesheets_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvstyb.pls';

-- Returns the no. of placements which uses this style
AMS_DEBUG_HIGH_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

function check_style_placements(
      p_stylesheet_id IN NUMBER
    , p_validation_mode IN VARCHAR2
    , x_return_status OUT NOCOPY VARCHAR2
)
return NUMBER
IS
 l_style_placement_count           NUMBER;

CURSOR c_style_placements(c_style_id IN NUMBER) IS
        SELECT COUNT(*)
        FROM AMS_IBA_PL_PLACEMENTS_B
        where stylesheet_id = c_style_id;
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here
      OPEN c_style_placements(p_stylesheet_id);
      FETCH c_style_placements INTO l_style_placement_count;
      CLOSE c_style_placements;

      IF l_style_placement_count = 0 THEN
         x_return_status := FND_API.g_ret_sts_success;
      ELSE
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;
      RETURN l_style_placement_count;
END check_style_placements;

-- Hint: Primary key needs to be returned.
PROCEDURE Create_Iba_Pl_Stylesheets(
    p_api_version_number   IN   NUMBER,
    p_init_msg_list        IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit               IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level     IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status        OUT NOCOPY  VARCHAR2,
    x_msg_count            OUT NOCOPY  NUMBER,
    x_msg_data             OUT NOCOPY  VARCHAR2,

    p_iba_pl_stylesheets_rec  IN   iba_pl_stylesheets_rec_type  := g_miss_iba_pl_stylesheets_rec,
    x_stylesheet_id           OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME          CONSTANT VARCHAR2(30) := 'Create_Iba_Pl_Stylesheets';
L_API_VERSION_NUMBER       CONSTANT NUMBER   := 1.0;
   l_return_status_full    VARCHAR2(1);
   l_object_version_number NUMBER := 1;
   l_org_id                NUMBER := FND_API.G_MISS_NUM;
   l_STYLESHEET_ID         NUMBER;
   l_dummy       NUMBER;

   CURSOR c_id IS
      SELECT AMS_IBA_PL_STYLESHTS_B_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_IBA_PL_STYLESHTS_B
      WHERE STYLESHEET_ID = l_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Iba_Pl_Stylesheets_PVT;

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

   IF p_iba_pl_stylesheets_rec.STYLESHEET_ID IS NULL OR p_iba_pl_stylesheets_rec.STYLESHEET_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_STYLESHEET_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_STYLESHEET_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
	x_stylesheet_id := l_stylesheet_id;
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

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Iba_Pl_Stylesheets');
          END IF;

          -- Invoke validation procedures
          Validate_iba_pl_stylesheets(
              p_api_version_number     => 1.0
            , p_init_msg_list    => FND_API.G_FALSE
            , p_validation_level => p_validation_level
            , p_iba_pl_stylesheets_rec  =>  p_iba_pl_stylesheets_rec
            , x_return_status    => x_return_status
            , x_msg_count        => x_msg_count
            , x_msg_data         => x_msg_data
            , p_validation_mode  => JTF_PLSQL_API.g_create
	);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      END IF;

      -- Invoke table handler(AMS_IBA_PL_STYLESHTS_B_PKG.Insert_Row)
      AMS_IBA_PL_STYLESHTS_B_PKG.Insert_Row(
          px_stylesheet_id  	=> l_stylesheet_id,
          p_content_type  	=> p_iba_pl_stylesheets_rec.content_type,
          p_stylesheet_filename => p_iba_pl_stylesheets_rec.stylesheet_filename,
          p_status_code  	=> 'Active',
          p_created_by  	=> FND_GLOBAL.USER_ID,
          p_creation_date  	=> SYSDATE,
          p_last_updated_by  	=> FND_GLOBAL.USER_ID,
          p_last_update_date  	=> SYSDATE,
          p_last_update_login  	=> FND_GLOBAL.CONC_LOGIN_ID,
          px_object_version_number  => l_object_version_number,
          p_name                => p_iba_pl_stylesheets_rec.name,
          p_description         => p_iba_pl_stylesheets_rec.description
	);


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
     ROLLBACK TO CREATE_Iba_Pl_Stylesheets_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message( 'Private API: in unexpected error '|| x_return_status);
     END IF;
     ROLLBACK TO CREATE_Iba_Pl_Stylesheets_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message( 'Private API: in others'|| x_return_status);
     END IF;
     ROLLBACK TO CREATE_Iba_Pl_Stylesheets_PVT;
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
End Create_Iba_Pl_Stylesheets;


PROCEDURE Update_Iba_Pl_Stylesheets(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_iba_pl_stylesheets_rec               IN    iba_pl_stylesheets_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS
--/*
CURSOR c_get_iba_pl_stylesheets(stylesheet_id NUMBER) IS
    SELECT *
    FROM  AMS_IBA_PL_STYLESHTS_B;
    -- Hint: Developer need to provide Where clause
--*/
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Iba_Pl_Stylesheets';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_STYLESHEET_ID    NUMBER;
l_ref_iba_pl_stylesheets_rec  c_get_Iba_Pl_Stylesheets%ROWTYPE ;
l_tar_iba_pl_stylesheets_rec  AMS_Iba_Pl_Stylesheets_PVT.iba_pl_stylesheets_rec_type := P_iba_pl_stylesheets_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Iba_Pl_Stylesheets_PVT;

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

---/*
      OPEN c_get_Iba_Pl_Stylesheets( l_tar_iba_pl_stylesheets_rec.stylesheet_id);

      FETCH c_get_Iba_Pl_Stylesheets INTO l_ref_iba_pl_stylesheets_rec  ;

       If ( c_get_Iba_Pl_Stylesheets%NOTFOUND) THEN
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Iba_Pl_Stylesheets') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_Iba_Pl_Stylesheets;
--*/


      If (l_tar_iba_pl_stylesheets_rec.object_version_number is NULL or
          l_tar_iba_pl_stylesheets_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_iba_pl_stylesheets_rec.object_version_number <> l_ref_iba_pl_stylesheets_rec.object_version_number) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Iba_Pl_Stylesheets') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Iba_Pl_Stylesheets');
          END IF;

          -- Invoke validation procedures
          Validate_iba_pl_stylesheets(
              p_api_version_number     => 1.0
            , p_init_msg_list    => FND_API.G_FALSE
            , p_validation_level => p_validation_level
            , p_iba_pl_stylesheets_rec  =>  p_iba_pl_stylesheets_rec
            , x_return_status    => x_return_status
            , x_msg_count        => x_msg_count
            , x_msg_data         => x_msg_data
            , p_validation_mode  => JTF_PLSQL_API.g_update
          );

      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
--      IF (AMS_DEBUG_HIGH_ON) THEN            AMS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');      END IF;

      -- Invoke table handler(AMS_IBA_PL_STYLESHTS_B_PKG.Update_Row)
      AMS_IBA_PL_STYLESHTS_B_PKG.Update_Row(
          p_stylesheet_id  => p_iba_pl_stylesheets_rec.stylesheet_id,
          p_content_type  => p_iba_pl_stylesheets_rec.content_type,
          p_stylesheet_filename  => p_iba_pl_stylesheets_rec.stylesheet_filename,
          p_status_code  => p_iba_pl_stylesheets_rec.status_code,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          p_object_version_number  => p_iba_pl_stylesheets_rec.object_version_number,
          p_name                => p_iba_pl_stylesheets_rec.name,
          p_description         => p_iba_pl_stylesheets_rec.description);


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
     ROLLBACK TO UPDATE_Iba_Pl_Stylesheets_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Iba_Pl_Stylesheets_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Iba_Pl_Stylesheets_PVT;
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
End Update_Iba_Pl_Stylesheets;


PROCEDURE Delete_Iba_Pl_Stylesheets(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_stylesheet_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Iba_Pl_Stylesheets';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_style_placements    	    NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Iba_Pl_Stylesheets_PVT;

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


--Check if the style to be deleted is being used in any of placements, if so, it should not be deleted.
         l_style_placements := check_style_placements(
			    p_STYLESHEET_ID  => p_STYLESHEET_ID
                          , p_validation_mode  => JTF_PLSQL_API.g_update
                          , x_return_status => x_return_status
         );

        IF (l_style_placements <> 0)
        THEN
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
                THEN
                   FND_MESSAGE.set_name('AMS','AMS_PLCE_STYLE_HAS_PLACEMENTS');
                   FND_MSG_PUB.add;
                END IF;
                RAISE FND_API.g_exc_error;
        ELSE
	      -- Invoke table handler(AMS_IBA_PL_STYLESHTS_B_PKG.Delete_Row)
	      AMS_IBA_PL_STYLESHTS_B_PKG.Delete_Row(
	          p_STYLESHEET_ID  => p_STYLESHEET_ID);
	      --
	      -- End of API body
	      --
        END IF;

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
     ROLLBACK TO DELETE_Iba_Pl_Stylesheets_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Iba_Pl_Stylesheets_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Iba_Pl_Stylesheets_PVT;
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
End Delete_Iba_Pl_Stylesheets;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Iba_Pl_Stylesheets(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_stylesheet_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Iba_Pl_Stylesheets';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_STYLESHEET_ID                  NUMBER;

CURSOR c_Iba_Pl_Stylesheets IS
   SELECT STYLESHEET_ID
   FROM AMS_IBA_PL_STYLESHTS_B
   WHERE STYLESHEET_ID = p_STYLESHEET_ID
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
  OPEN c_Iba_Pl_Stylesheets;

  FETCH c_Iba_Pl_Stylesheets INTO l_STYLESHEET_ID;

  IF (c_Iba_Pl_Stylesheets%NOTFOUND) THEN
    CLOSE c_Iba_Pl_Stylesheets;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Iba_Pl_Stylesheets;

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
     ROLLBACK TO LOCK_Iba_Pl_Stylesheets_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Iba_Pl_Stylesheets_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Iba_Pl_Stylesheets_PVT;
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
End Lock_Iba_Pl_Stylesheets;


PROCEDURE check_iba_pl_style_uk_items(
    p_iba_pl_stylesheets_rec               IN   iba_pl_stylesheets_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);
l_style_name_flag VARCHAR2(1);
l_stylesheet_file_flag VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
--If Validation_mode is create, check uniqueness of style name, stylesheet filename
      if p_validation_mode = JTF_PLSQL_API.g_create then
        -- Checking if the style name passed is unique
         l_style_name_flag := ams_utility_pvt.check_uniqueness(
                               'ams_iba_pl_styleshts_vl'
                             , 'name = ''' || p_iba_pl_stylesheets_rec.name ||''' and content_type = ''' || p_iba_pl_stylesheets_rec.content_type || ''''
         );
         if l_style_name_flag = fnd_api.g_false then
                ams_uTILITY_pvt.error_Message(p_message_name => 'AMS_PLCE_STYLE_NAME_DUP');
                x_return_status := fnd_api.g_ret_sts_error;
                return;
         end if;

        -- Checking if the stylesheet filename passed is unique
         l_stylesheet_file_flag := ams_utility_pvt.check_uniqueness(
                               'ams_iba_pl_styleshts_vl'
                             , 'STYLESHEET_FILENAME = ''' || p_iba_pl_stylesheets_rec.STYLESHEET_FILENAME ||''' and CONTENT_TYPE = ''' || p_iba_pl_stylesheets_rec.CONTENT_TYPE || ''''

         );
         if l_stylesheet_file_flag = fnd_api.g_false then
                ams_utility_pvt.error_Message(p_message_name => 'AMS_PLCE_DUP_STYLE_FILENAME');
                x_return_status := fnd_api.g_ret_sts_error;
                return;
         end if;
      end if;

--If Validation_mode is update, check uniqueness of  style name, stylesheet filename
      if p_validation_mode = JTF_PLSQL_API.g_update then
        -- Checking if the style name passed is unique
         l_style_name_flag := ams_utility_pvt.check_uniqueness(
                               'ams_iba_pl_styleshts_vl'
                             , 'name = ''' || p_iba_pl_stylesheets_rec.name ||''' and STYLESHEET_ID <> ' || p_iba_pl_stylesheets_rec.STYLESHEET_ID || ' and CONTENT_TYPE = ''' || p_iba_pl_stylesheets_rec.CONTENT_TYPE || ''''
         );
              IF (AMS_DEBUG_HIGH_ON) THEN

              AMS_UTILITY_PVT.debug_message('In update unique check - style_name: ' || p_iba_pl_stylesheets_rec.name);
              END IF;
         if l_style_name_flag = fnd_api.g_false then
                ams_uTILITY_pvt.error_Message(p_message_name => 'AMS_PLCE_STYLE_NAME_DUP');
                x_return_status := fnd_api.g_ret_sts_error;
                return;
         end if;

        -- Checking if the stylesheet filename passed is unique
         l_stylesheet_file_flag := ams_utility_pvt.check_uniqueness(
                               'ams_iba_pl_styleshts_vl'
                             , 'STYLESHEET_FILENAME = ''' || p_iba_pl_stylesheets_rec.STYLESHEET_FILENAME ||''' and STYLESHEET_ID <> ' || p_iba_pl_stylesheets_rec.STYLESHEET_ID || ' and CONTENT_TYPE = ''' || p_iba_pl_stylesheets_rec.CONTENT_TYPE || ''''
         );
         if l_stylesheet_file_flag = fnd_api.g_false then
                ams_utility_pvt.error_Message(p_message_name => 'AMS_PLCE_DUP_STYLE_FILENAME');
                x_return_status := fnd_api.g_ret_sts_error;
                return;
         end if;
      end if;


--      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
--         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
--         'AMS_IBA_PL_STYLESHTS_B',
--         'STYLESHEET_ID = ''' || p_iba_pl_stylesheets_rec.STYLESHEET_ID ||''''
--         );
--      ELSE
--         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
--         'AMS_IBA_PL_STYLESHTS_B',
--         'STYLESHEET_ID = ''' || p_iba_pl_stylesheets_rec.STYLESHEET_ID ||
--         ''' AND STYLESHEET_ID <> ' || p_iba_pl_stylesheets_rec.STYLESHEET_ID
--         );
--      END IF;

--      IF l_valid_flag = FND_API.g_false THEN
-- AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_STYLESHEET_ID_DUPLICATE');
--         x_return_status := FND_API.g_ret_sts_error;
--         RETURN;
--      END IF;

END check_iba_pl_style_uk_items;

PROCEDURE check_iba_pl_style_req_items(
    p_iba_pl_stylesheets_rec               IN  iba_pl_stylesheets_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_iba_pl_stylesheets_rec.stylesheet_id = FND_API.g_miss_num OR p_iba_pl_stylesheets_rec.stylesheet_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_pl_stylesheets_NO_stylesheet_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_pl_stylesheets_rec.stylesheet_filename = FND_API.g_miss_char OR p_iba_pl_stylesheets_rec.stylesheet_filename IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_pl_stylesheets_NO_stylesheet_filename');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_pl_stylesheets_rec.status_code = FND_API.g_miss_char OR p_iba_pl_stylesheets_rec.status_code IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_pl_stylesheets_NO_status_code');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_pl_stylesheets_rec.created_by = FND_API.g_miss_num OR p_iba_pl_stylesheets_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_pl_stylesheets_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_pl_stylesheets_rec.creation_date = FND_API.g_miss_date OR p_iba_pl_stylesheets_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_pl_stylesheets_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_pl_stylesheets_rec.last_updated_by = FND_API.g_miss_num OR p_iba_pl_stylesheets_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_pl_stylesheets_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_pl_stylesheets_rec.last_update_date = FND_API.g_miss_date OR p_iba_pl_stylesheets_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_pl_stylesheets_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE


      IF p_iba_pl_stylesheets_rec.stylesheet_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_pl_stylesheets_NO_stylesheet_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_pl_stylesheets_rec.stylesheet_filename IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_pl_stylesheets_NO_stylesheet_filename');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_pl_stylesheets_rec.status_code IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_pl_stylesheets_NO_status_code');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_pl_stylesheets_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_pl_stylesheets_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_pl_stylesheets_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_pl_stylesheets_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_pl_stylesheets_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_pl_stylesheets_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_pl_stylesheets_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_pl_stylesheets_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_iba_pl_style_req_items;

PROCEDURE check_iba_pl_style_FK_items(
    p_iba_pl_stylesheets_rec IN iba_pl_stylesheets_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_iba_pl_style_FK_items;

PROCEDURE check_iba_pl_style_Lkup_itm(
    p_iba_pl_stylesheets_rec IN iba_pl_stylesheets_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_iba_pl_style_Lkup_itm;

PROCEDURE Check_iba_pl_style_Items (
    P_iba_pl_stylesheets_rec     IN    iba_pl_stylesheets_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_iba_pl_style_uk_items(
      p_iba_pl_stylesheets_rec => p_iba_pl_stylesheets_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

--   check_iba_pl_style_req_items(
--      p_iba_pl_stylesheets_rec => p_iba_pl_stylesheets_rec,
--      p_validation_mode => p_validation_mode,
--      x_return_status => x_return_status);
--   IF x_return_status <> FND_API.g_ret_sts_success THEN
--      RETURN;
--   END IF;
   -- Check Items Foreign Keys API calls
--
--   check_iba_pl_style_FK_items(
--      p_iba_pl_stylesheets_rec => p_iba_pl_stylesheets_rec,
--      x_return_status => x_return_status);
--   IF x_return_status <> FND_API.g_ret_sts_success THEN
--      RETURN;
--   END IF;
   -- Check Items Lookups

--   check_iba_pl_style_Lkup_itm(
--      p_iba_pl_stylesheets_rec => p_iba_pl_stylesheets_rec,
--      x_return_status => x_return_status);
--   IF x_return_status <> FND_API.g_ret_sts_success THEN
--      RETURN;
--   END IF;

END Check_iba_pl_style_Items;


PROCEDURE Complete_iba_pl_style_Rec (
   p_iba_pl_stylesheets_rec IN iba_pl_stylesheets_rec_type,
   x_complete_rec OUT NOCOPY iba_pl_stylesheets_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_iba_pl_styleshts_b
      WHERE stylesheet_id = p_iba_pl_stylesheets_rec.stylesheet_id;
   l_iba_pl_stylesheets_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_iba_pl_stylesheets_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_iba_pl_stylesheets_rec;
   CLOSE c_complete;

   -- stylesheet_id
   IF p_iba_pl_stylesheets_rec.stylesheet_id = FND_API.g_miss_num THEN
      x_complete_rec.stylesheet_id := l_iba_pl_stylesheets_rec.stylesheet_id;
   END IF;

   -- content_type
   IF p_iba_pl_stylesheets_rec.content_type = FND_API.g_miss_char THEN
      x_complete_rec.content_type := l_iba_pl_stylesheets_rec.content_type;
   END IF;

   -- stylesheet_filename
   IF p_iba_pl_stylesheets_rec.stylesheet_filename = FND_API.g_miss_char THEN
      x_complete_rec.stylesheet_filename := l_iba_pl_stylesheets_rec.stylesheet_filename;
   END IF;

   -- status_code
   IF p_iba_pl_stylesheets_rec.status_code = FND_API.g_miss_char THEN
      x_complete_rec.status_code := l_iba_pl_stylesheets_rec.status_code;
   END IF;

   -- created_by
   IF p_iba_pl_stylesheets_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_iba_pl_stylesheets_rec.created_by;
   END IF;

   -- creation_date
   IF p_iba_pl_stylesheets_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_iba_pl_stylesheets_rec.creation_date;
   END IF;

   -- last_updated_by
   IF p_iba_pl_stylesheets_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_iba_pl_stylesheets_rec.last_updated_by;
   END IF;

   -- last_update_date
   IF p_iba_pl_stylesheets_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_iba_pl_stylesheets_rec.last_update_date;
   END IF;

   -- last_update_login
   IF p_iba_pl_stylesheets_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_iba_pl_stylesheets_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_iba_pl_stylesheets_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_iba_pl_stylesheets_rec.object_version_number;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_iba_pl_style_Rec;
PROCEDURE Validate_iba_pl_stylesheets(
      p_api_version_number         IN   NUMBER
    , p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    , p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL
    , p_iba_pl_stylesheets_rec     IN   iba_pl_stylesheets_rec_type
    , x_return_status              OUT NOCOPY  VARCHAR2
    , x_msg_count                  OUT NOCOPY  NUMBER
    , x_msg_data                   OUT NOCOPY  VARCHAR2
    , p_validation_mode            IN   VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Iba_Pl_Stylesheets';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_iba_pl_stylesheets_rec  AMS_Iba_Pl_Stylesheets_PVT.iba_pl_stylesheets_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Iba_Pl_Stylesheets_;

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
              Check_iba_pl_style_Items(
                 p_iba_pl_stylesheets_rec        => p_iba_pl_stylesheets_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_iba_pl_style_Rec(
         p_iba_pl_stylesheets_rec        => p_iba_pl_stylesheets_rec,
         x_complete_rec        => l_iba_pl_stylesheets_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_iba_pl_style_rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_iba_pl_stylesheets_rec           =>    l_iba_pl_stylesheets_rec);

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
     ROLLBACK TO VALIDATE_Iba_Pl_Stylesheets_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Iba_Pl_Stylesheets_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Iba_Pl_Stylesheets_;
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
End Validate_Iba_Pl_Stylesheets;


PROCEDURE Validate_iba_pl_style_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_iba_pl_stylesheets_rec               IN    iba_pl_stylesheets_rec_type
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
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_iba_pl_style_rec;

END AMS_Iba_Pl_Stylesheets_PVT;

/
