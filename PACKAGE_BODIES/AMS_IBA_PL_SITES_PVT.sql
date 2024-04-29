--------------------------------------------------------
--  DDL for Package Body AMS_IBA_PL_SITES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IBA_PL_SITES_PVT" as
/* $Header: amsvsitb.pls 120.0 2005/05/31 14:22:44 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Iba_Pl_Sites_PVT
-- Purpose
--		  Private api created to insert/update/delete placement sites
-- History
--		  18-Apr-2001     sodixit      Created
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Iba_Pl_Sites_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvsitb.pls';

AMS_DEBUG_HIGH_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

function check_site_pages(
      p_site_id IN NUMBER
    , p_validation_mode IN VARCHAR2
    , x_return_status OUT NOCOPY VARCHAR2
)
return NUMBER
IS
 l_site_page_count           NUMBER;

CURSOR c_site_pages(c_site_id IN NUMBER) IS
        SELECT COUNT(*)
        FROM AMS_IBA_PL_PAGES_B
        where site_id = c_site_id;
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here
      OPEN c_site_pages(p_site_id);
      FETCH c_site_pages INTO l_site_page_count;
      CLOSE c_site_pages;

      IF l_site_page_count = 0 THEN
   	 x_return_status := FND_API.g_ret_sts_success;
      ELSE
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;
      RETURN l_site_page_count;
END check_site_pages;

function is_site_name_changed(
	p_iba_pl_sites_rec   IN   iba_pl_sites_rec_type
	, p_validation_mode  IN VARCHAR2
        , x_return_status    OUT NOCOPY VARCHAR2
)
return VARCHAR2
IS
 l_site_name_count           NUMBER;

CURSOR c_site_name(c_site_id IN NUMBER, c_site_name IN VARCHAR2) IS
       SELECT COUNT(*)
        FROM AMS_IBA_PL_SITES_VL
        where site_id = c_site_id
	and name = c_site_name;
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here
      OPEN c_site_name(p_iba_pl_sites_rec.site_id, p_iba_pl_sites_rec.name);
      FETCH c_site_name INTO l_site_name_count;
      CLOSE c_site_name;

      IF l_site_name_count = 1 THEN
         x_return_status := FND_API.g_ret_sts_success;
      	 RETURN fnd_api.g_false;
      ELSE
        x_return_status := fnd_api.g_ret_sts_error;
        RETURN fnd_api.g_true;
      END IF;
END is_site_name_changed;

function is_site_ref_changed(
	p_iba_pl_sites_rec   IN   iba_pl_sites_rec_type
	, p_validation_mode  IN VARCHAR2
        , x_return_status    OUT NOCOPY VARCHAR2
)
return VARCHAR2
IS
 l_site_ref_count           NUMBER;

CURSOR c_site_ref(c_site_id IN NUMBER, c_site_ref_code IN VARCHAR2) IS
        SELECT COUNT(*)
        FROM AMS_IBA_PL_SITES_B
        where site_id = c_site_id
	and site_ref_code = c_site_ref_code;
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here
      OPEN c_site_ref(p_iba_pl_sites_rec.site_id, p_iba_pl_sites_rec.site_ref_code);
      FETCH c_site_ref INTO l_site_ref_count;
      CLOSE c_site_ref;

      IF l_site_ref_count = 1 THEN
         x_return_status := FND_API.g_ret_sts_success;
      	 RETURN fnd_api.g_false;
      ELSE
        x_return_status := fnd_api.g_ret_sts_error;
        RETURN fnd_api.g_true;
      END IF;

END is_site_ref_changed;

-- Hint: Primary key needs to be returned.
PROCEDURE Create_Iba_Pl_Sites(
    p_api_version_number  IN   NUMBER,
    p_init_msg_list       IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN   VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL,

    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,

    p_iba_pl_sites_rec    IN   iba_pl_sites_rec_type := g_miss_iba_pl_sites_rec,
    x_site_id             OUT NOCOPY  NUMBER
   )

 IS
   L_API_NAME                CONSTANT VARCHAR2(30) := 'Create_Iba_Pl_Sites';
   L_API_VERSION_NUMBER      CONSTANT NUMBER   := 1.0;
   l_return_status_full      VARCHAR2(1);
   l_object_version_number   NUMBER := 1;
   l_org_id                  NUMBER := FND_API.G_MISS_NUM;
   l_site_id                 NUMBER;
   l_dummy       			 NUMBER;

   CURSOR c_id IS
      SELECT ams_iba_pl_sites_b_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
	 (SELECT 1 FROM ams_iba_pl_sites_b
			      WHERE site_id = l_id);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Iba_Pl_Sites_PVT;

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

   IF p_iba_pl_sites_rec.SITE_ID IS NULL OR p_iba_pl_sites_rec.SITE_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_SITE_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_SITE_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
	x_site_id := l_SITE_ID;
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

          AMS_UTILITY_PVT.debug_message('Private API: validate_iba_pl_sites');
          END IF;

          -- Invoke validation procedures
          validate_iba_pl_sites(
              p_api_version_number  => 1.0
            , p_init_msg_list    => FND_API.G_FALSE
            , p_validation_level => p_validation_level
            , p_iba_pl_sites_rec =>  p_iba_pl_sites_rec
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

      -- Invoke table handler(AMS_IBA_PL_SITES_B_PKG.Insert_Row)
      AMS_IBA_PL_SITES_B_PKG.Insert_Row(
          px_site_id  		=> l_site_id,
          p_site_ref_code  	=> p_iba_pl_sites_rec.site_ref_code,
          p_site_category_type  => p_iba_pl_sites_rec.site_category_type,
          p_site_category_object_id  => p_iba_pl_sites_rec.site_category_object_id,
          p_status_code  	=> p_iba_pl_sites_rec.status_code,
          p_created_by  	=> FND_GLOBAL.USER_ID,
          p_creation_date  	=> SYSDATE,
          p_last_updated_by  	=> FND_GLOBAL.USER_ID,
          p_last_update_date  	=> SYSDATE,
          p_last_update_login  	=> FND_GLOBAL.CONC_LOGIN_ID,
          px_object_version_number  => l_object_version_number,
	  p_name  		=> p_iba_pl_sites_rec.name,
	  p_description 	=> p_iba_pl_sites_rec.description);

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
     ROLLBACK TO CREATE_Iba_Pl_Sites_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Iba_Pl_Sites_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Iba_Pl_Sites_PVT;
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
End Create_Iba_Pl_Sites;


PROCEDURE Update_Iba_Pl_Sites(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN   VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,

    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2,

    p_iba_pl_sites_rec      IN  iba_pl_sites_rec_type,
    x_object_version_number OUT NOCOPY  NUMBER
    )

 IS
--/*
CURSOR c_get_iba_pl_sites(site_id NUMBER) IS
    SELECT *
    FROM  AMS_IBA_PL_SITES_B
    WHERE site_id = site_id;
    -- Hint: Developer need to provide Where clause
--*/
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Iba_Pl_Sites';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_SITE_ID    NUMBER;
l_ref_iba_pl_sites_rec  c_get_Iba_Pl_Sites%ROWTYPE ;
l_tar_iba_pl_sites_rec  AMS_Iba_Pl_Sites_PVT.iba_pl_sites_rec_type := P_iba_pl_sites_rec;
l_rowid  ROWID;
l_site_pages NUMBER;
l_siterefcode_changed VARCHAR2(1);
l_sitename_changed VARCHAR2(1);

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Iba_Pl_Sites_PVT;

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
      OPEN c_get_Iba_Pl_Sites( l_tar_iba_pl_sites_rec.site_id);

      FETCH c_get_Iba_Pl_Sites INTO l_ref_iba_pl_sites_rec  ;

       IF ( c_get_Iba_Pl_Sites%NOTFOUND) THEN
		AMS_Utility_PVT.Error_Message(
				p_message_name => 'API_MISSING_UPDATE_TARGET',
				p_token_name   => 'INFO',
				p_token_value  => 'Iba_Pl_Sites') ;
		RAISE FND_API.G_EXC_ERROR;
       END IF;

       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_Iba_Pl_Sites;
--*/


      IF (l_tar_iba_pl_sites_rec.object_version_number is NULL or
          l_tar_iba_pl_sites_rec.object_version_number = FND_API.G_MISS_NUM )
	 THEN
		AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
		p_token_name   => 'COLUMN',
		p_token_value  => 'Last_Update_Date') ;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Check Whether record has been changed by someone else
      IF (l_tar_iba_pl_sites_rec.object_version_number <> l_ref_iba_pl_sites_rec.object_version_number)
	 THEN
		AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
		p_token_name   => 'INFO',
		p_token_value  => 'Iba_Pl_Sites') ;
          RAISE FND_API.G_EXC_ERROR;
      End if;

--Check if site_id is < 10000, if so the site is seeded site, so site name and site_ref_code should not be modified.
-- Commenting this check as this is being taken care at UI level. UI is making site_ref_code and site_id read only.
--	if (p_iba_pl_sites_rec.site_id < 10000)
--	then
--	        l_sitename_changed := is_site_name_changed(
--                               p_iba_pl_sites_rec =>  p_iba_pl_sites_rec
--                            , p_validation_mode  => JTF_PLSQL_API.g_update
--                           , x_return_status => x_return_status
--                          );
--
--	        l_siterefcode_changed := is_site_ref_changed(
--                               p_iba_pl_sites_rec =>  p_iba_pl_sites_rec
--                            , p_validation_mode  => JTF_PLSQL_API.g_update
--                          , x_return_status => x_return_status
--                           );
--
--		IF ((l_sitename_changed=fnd_api.g_true) or (l_siterefcode_changed = fnd_api.g_true))
--               THEN
--                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
--		     THEN
--                          FND_MESSAGE.set_name('AMS','AMS_PLCE_SEED_SITE_NOUPD');
--                          FND_MSG_PUB.add;
--                   END IF;
--                   RAISE FND_API.g_exc_error;
--                END IF;
--	end if;

--Check if the site to be updated has any pages, if so, site_ref_code should not be modified.
         l_site_pages := check_site_pages(
		            p_site_id => p_iba_pl_sites_rec.site_id
		          , p_validation_mode  => JTF_PLSQL_API.g_update
			  , x_return_status => x_return_status
         );

	IF (l_site_pages <> 0)
	THEN
		l_siterefcode_changed := is_site_ref_changed(
				p_iba_pl_sites_rec =>  p_iba_pl_sites_rec
			      , p_validation_mode  => JTF_PLSQL_API.g_update
                              , x_return_status => x_return_status
		              );

		IF (l_siterefcode_changed = fnd_api.g_true)
		THEN
        	    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
		          FND_MESSAGE.set_name('AMS','AMS_PLCE_SITE_PG_REF_NOUPD');
		          FND_MSG_PUB.add;
		    END IF;
	            RAISE FND_API.g_exc_error;
		END IF;
	END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: validate_iba_pl_sites');
          END IF;

          -- Invoke validation procedures
          validate_iba_pl_sites(
              p_api_version_number  => 1.0
            , p_init_msg_list    => FND_API.G_FALSE
            , p_validation_level => p_validation_level
            , p_iba_pl_sites_rec =>  p_iba_pl_sites_rec
            , x_return_status    => x_return_status
            , x_msg_count        => x_msg_count
            , x_msg_data         => x_msg_data
            , p_validation_mode  => JTF_PLSQL_API.g_update
          );
      END IF;

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' After Validate call - return_status='||x_return_status);

      END IF;
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
--      IF (AMS_DEBUG_HIGH_ON) THEN            AMS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: Calling update table handler - mymessage - site_id='||p_iba_pl_sites_rec.site_id);
      END IF;

      -- Invoke table handler(AMS_IBA_PL_SITES_B_PKG.Update_Row)
      AMS_IBA_PL_SITES_B_PKG.Update_Row(
          p_site_id  => p_iba_pl_sites_rec.site_id,
          p_site_ref_code  => p_iba_pl_sites_rec.site_ref_code,
          p_site_category_type  => p_iba_pl_sites_rec.site_category_type,
          p_site_category_object_id  => p_iba_pl_sites_rec.site_category_object_id,
          p_status_code  => p_iba_pl_sites_rec.status_code,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          p_object_version_number  => p_iba_pl_sites_rec.object_version_number,
          p_name                => p_iba_pl_sites_rec.name,
          p_description         => p_iba_pl_sites_rec.description);

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
     ROLLBACK TO UPDATE_Iba_Pl_Sites_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Iba_Pl_Sites_PVT;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' in Updte method - unexpected exception area');
      END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Iba_Pl_Sites_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' in Update method - others exception area');
      END IF;
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
End Update_Iba_Pl_Sites;


PROCEDURE Delete_Iba_Pl_Sites(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN   VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2,
    p_site_id               IN  NUMBER,
    p_object_version_number IN   NUMBER
)

IS
 l_api_name                  CONSTANT VARCHAR2(30) := 'Delete_Iba_Pl_Sites';
 l_api_version_number        CONSTANT NUMBER   := 1.0;
 l_object_version_number     NUMBER;
 l_site_page_count           NUMBER;

CURSOR c_site_pages(c_site_id IN NUMBER) IS
        SELECT COUNT(*)
        FROM AMS_IBA_PL_PAGES_B
        where site_id = c_site_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Iba_Pl_Sites_PVT;

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

      OPEN c_site_pages(p_site_id);
      FETCH c_site_pages INTO l_site_page_count;
      CLOSE c_site_pages;

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message('Private API: Page Count = ' || l_site_page_count );

      END IF;
      -- Invoke table handler(AMS_IBA_PL_SITES_B_PKG.Delete_Row)
      IF l_site_page_count = 0 	          --MEANING NO PAGES ARE AVAILABLE FOR THIS SITE
      THEN
--  	IF l_object_version_number = p_object_version_number  -- VERSIONS MATCH
--	THEN
      	      IF (AMS_DEBUG_HIGH_ON) THEN

      	      AMS_UTILITY_PVT.debug_message('Private API: Just before calling Delete site_id = ' || p_site_id || 'obj_ver_no = ' || p_object_version_number);
      	      END IF;

	      AMS_IBA_PL_SITES_B_PKG.Delete_Row
				(p_site_id  => p_site_id,
			         p_object_version_number => p_object_version_number
				);
      	      IF (AMS_DEBUG_HIGH_ON) THEN

      	      AMS_UTILITY_PVT.debug_message('Private API: Just after calling Delete site_id = ' || p_site_id || 'obj_ver_no = ' || p_object_version_number);
      	      END IF;
--        ELSE                                           -- VERSIONS DOESN'T MATCH
--           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
--	    THEN
--              	FND_MESSAGE.set_name('AMS','AMS_API_VERS_DONT_MATCH');
--              	FND_MSG_PUB.add;
--            END IF;
--            RAISE FND_API.g_exc_error;
--        END IF;
      ELSE                                   -- PAGES ARE AVAILABLE FOR THIS SITE
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('AMS','AMS_PLCE_SITE_HAS_PAGES');
          FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.g_exc_error;
      END IF;

      --
      -- End of API body
      --

      	 IF (AMS_DEBUG_HIGH_ON) THEN



      	 AMS_UTILITY_PVT.debug_message( 'Private API: before Commit : p_commit = '|| p_commit);

      	 END IF;
      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      	 IF (AMS_DEBUG_HIGH_ON) THEN

      	 AMS_UTILITY_PVT.debug_message( 'Private API: After Commit : p_commit = '|| p_commit);
      	 END IF;
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
     ROLLBACK TO DELETE_Iba_Pl_Sites_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Iba_Pl_Sites_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Iba_Pl_Sites_PVT;
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
End Delete_Iba_Pl_Sites;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Iba_Pl_Sites(
    p_api_version_number IN   NUMBER,
    p_init_msg_list      IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status      OUT NOCOPY  VARCHAR2,
    x_msg_count          OUT NOCOPY  NUMBER,
    x_msg_data           OUT NOCOPY  VARCHAR2,

    p_site_id            IN  NUMBER,
    p_object_version     IN  NUMBER
    )

IS
  L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Iba_Pl_Sites';
  L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
  L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_SITE_ID                  NUMBER;

CURSOR c_Iba_Pl_Sites IS
   SELECT SITE_ID
   FROM AMS_IBA_PL_SITES_B
   WHERE SITE_ID = p_SITE_ID
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
  OPEN c_Iba_Pl_Sites;

  FETCH c_Iba_Pl_Sites INTO l_SITE_ID;

  IF (c_Iba_Pl_Sites%NOTFOUND) THEN
    CLOSE c_Iba_Pl_Sites;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Iba_Pl_Sites;

 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data
  );
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name ||': end');
  END IF;
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
	AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Iba_Pl_Sites_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Iba_Pl_Sites_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Iba_Pl_Sites_PVT;
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
End Lock_Iba_Pl_Sites;


PROCEDURE check_iba_pl_sites_uk_items(
      p_iba_pl_sites_rec    IN  iba_pl_sites_rec_type
    , p_validation_mode     IN  VARCHAR2 := JTF_PLSQL_API.g_create
    , x_return_status       OUT NOCOPY VARCHAR2
)
IS
l_valid_flag     VARCHAR2(1);
l_site_id_flag 	 VARCHAR2(1);
l_site_name_flag VARCHAR2(1);
l_site_ref_code_flag VARCHAR2(1);

BEGIN
     x_return_status := FND_API.g_ret_sts_success;
--If Validation_mode is create, check uniqueness of site_id, name, site_ref_code
      if p_validation_mode = JTF_PLSQL_API.g_create then
	-- Checking if the site id passed is unique
         l_site_id_flag := ams_uTILITY_pvt.check_uniqueness(
      			   'ams_iba_pl_sites_b'
		          , 'site_id = ''' || p_iba_pl_sites_rec.site_id ||''''
         );

      	 if l_site_id_flag = fnd_api.g_false then
		ams_utility_pvt.Error_Message(p_message_name => 'AMS_PLCE_SITE_ID_DUP');
		x_return_status := fnd_api.g_ret_sts_error;
		return;
	 end if;

	-- Checking if the site name passed is unique
         l_site_name_flag := ams_utility_pvt.check_uniqueness(
         		       'ams_iba_pl_sites_vl'
			     , 'name = ''' || p_iba_pl_sites_rec.name ||''''
	 );
      	 if l_site_name_flag = fnd_api.g_false then
		ams_uTILITY_pvt.error_Message(p_message_name => 'AMS_PLCE_SITE_NAME_DUP');
		x_return_status := fnd_api.g_ret_sts_error;
		return;
	 end if;

	-- Checking if the site ref code passed is unique
         l_site_ref_code_flag := ams_utility_pvt.check_uniqueness(
         		       'ams_iba_pl_sites_vl'
			     , 'site_ref_code = ''' || p_iba_pl_sites_rec.site_ref_code ||''''
	 );
      	 if l_site_ref_code_flag = fnd_api.g_false then
		ams_utility_pvt.error_Message(p_message_name => 'AMS_PLCE_DUP_SITE_REF');
		x_return_status := fnd_api.g_ret_sts_error;
		return;
	 end if;
      end if;

--If Validation_mode is update, check uniqueness of site name, site_ref_code
      if p_validation_mode = JTF_PLSQL_API.g_update then
	-- Checking if the site name passed is unique
         l_site_name_flag := ams_utility_pvt.check_uniqueness(
         		       'ams_iba_pl_sites_vl'
			     , 'name = ''' || p_iba_pl_sites_rec.name ||''' and site_id <> ' || p_iba_pl_sites_rec.site_id
	 );
	      IF (AMS_DEBUG_HIGH_ON) THEN

	      AMS_UTILITY_PVT.debug_message('In update unique check - site_name: ' || p_iba_pl_sites_rec.name);
	      END IF;
      	 if l_site_name_flag = fnd_api.g_false then
		ams_uTILITY_pvt.error_Message(p_message_name => 'AMS_PLCE_SITE_NAME_DUP');
		x_return_status := fnd_api.g_ret_sts_error;
		return;
	 end if;

	-- Checking if the site ref code passed is unique
         l_site_ref_code_flag := ams_utility_pvt.check_uniqueness(
         		       'ams_iba_pl_sites_vl'
			     , 'site_ref_code = ''' || p_iba_pl_sites_rec.site_ref_code ||''' and site_id <> ' || p_iba_pl_sites_rec.site_id
	 );
      	 if l_site_ref_code_flag = fnd_api.g_false then
		ams_utility_pvt.error_Message(p_message_name => 'AMS_PLCE_DUP_SITE_REF');
		x_return_status := fnd_api.g_ret_sts_error;
		return;
	 end if;
      end if;
END check_iba_pl_sites_uk_items;

PROCEDURE check_iba_pl_sites_req_items(
    p_iba_pl_sites_rec IN  iba_pl_sites_rec_type,
    p_validation_mode IN VARCHAR2,
    x_return_status	OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

---------------
-- sodixit : commenting the following lines as validation of the required fields for mode = create will be done in middle tier
---------------
		AMS_Utility_PVT.Error_Message(p_message_name => 'private API :in check required columns procedure');
--      IF (p_iba_pl_sites_rec.site_id = FND_API.g_miss_num) OR (p_iba_pl_sites_rec.site_id IS NULL)
--	 THEN
--		AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_pl_sites_NO_site_id');
--		x_return_status := FND_API.g_ret_sts_error;
--		RETURN;
--     END IF;

--    IF (p_iba_pl_sites_rec.site_ref_code = FND_API.g_miss_char) OR (p_iba_pl_sites_rec.site_ref_code IS NULL)
----	 THEN
--		AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_pl_sites_NO_site_ref_code');
--		x_return_status := FND_API.g_ret_sts_error;
--		RETURN;
--     END IF;


--      IF (p_iba_pl_sites_rec.site_category_type = FND_API.g_miss_char) OR (p_iba_pl_sites_rec.site_category_type IS NULL)
--	 THEN
--		AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_pl_sites_NO_site_category_type');
--		x_return_status := FND_API.g_ret_sts_error;
--		RETURN;
--     END IF;


--    IF (p_iba_pl_sites_rec.status_code = FND_API.g_miss_char) OR (p_iba_pl_sites_rec.status_code IS NULL)
--	 THEN
--		AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_pl_sites_NO_status_code');
--	     x_return_status := FND_API.g_ret_sts_error;
--         RETURN;
--    END IF;


--   IF (p_iba_pl_sites_rec.created_by = FND_API.g_miss_num) OR (p_iba_pl_sites_rec.created_by IS NULL)
--	 THEN
--		AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_pl_sites_NO_created_by');
--		x_return_status := FND_API.g_ret_sts_error;
--		RETURN;
--     END IF;


 --    IF (p_iba_pl_sites_rec.creation_date = FND_API.g_miss_date) OR (p_iba_pl_sites_rec.creation_date IS NULL)
--	 THEN
--		AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_pl_sites_NO_creation_date');
--		x_return_status := FND_API.g_ret_sts_error;
--		RETURN;
--     END IF;
--

--     IF p_iba_pl_sites_rec.last_updated_by = FND_API.g_miss_num OR p_iba_pl_sites_rec.last_updated_by IS NULL
--	 THEN
--		AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_pl_sites_NO_last_updated_by');
--		x_return_status := FND_API.g_ret_sts_error;
--		RETURN;
--     END IF;
--

----     IF p_iba_pl_sites_rec.last_update_date = FND_API.g_miss_date OR p_iba_pl_sites_rec.last_update_date IS NULL
--	THEN
--		AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_pl_sites_NO_last_update_date');
--		x_return_status := FND_API.g_ret_sts_error;
--		RETURN;
--     END IF;

   ELSE

      IF p_iba_pl_sites_rec.site_id IS NULL THEN
		AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_pl_sites_NO_site_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_pl_sites_rec.site_ref_code IS NULL THEN
		AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_pl_sites_NO_site_ref_code');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_pl_sites_rec.site_category_type IS NULL THEN
		AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_pl_sites_NO_site_category_type');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_pl_sites_rec.status_code IS NULL THEN
		AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_pl_sites_NO_status_code');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_pl_sites_rec.created_by IS NULL THEN
		 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_pl_sites_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_pl_sites_rec.creation_date IS NULL THEN
		 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_pl_sites_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_pl_sites_rec.last_updated_by IS NULL THEN
		 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_pl_sites_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_pl_sites_rec.last_update_date IS NULL THEN
		 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_pl_sites_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_iba_pl_sites_req_items;

PROCEDURE check_iba_pl_sites_FK_items(
      p_iba_pl_sites_rec IN iba_pl_sites_rec_type
    , p_validation_mode IN VARCHAR2
    , x_return_status OUT NOCOPY VARCHAR2
)
IS
 l_site_page_count           NUMBER;

CURSOR c_site_pages(c_site_id IN NUMBER) IS
        SELECT COUNT(*)
        FROM AMS_IBA_PL_PAGES_B
        where site_id = c_site_id;
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here
      OPEN c_site_pages(p_iba_pl_sites_rec.site_id);
      FETCH c_site_pages INTO l_site_page_count;
      CLOSE c_site_pages;

      IF l_site_page_count = 0 THEN
   	 x_return_status := FND_API.g_ret_sts_success;
      ELSE
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('AMS','AMS_PLCE_SITE_HAS_PAGES');
          FND_MSG_PUB.add;
        END IF;
        x_return_status := fnd_api.g_ret_sts_error;
        RAISE FND_API.g_exc_error;
        return;
      END IF;
END check_iba_pl_sites_FK_items;

PROCEDURE check_iba_pl_sites_Lkup_itm(
    p_iba_pl_sites_rec IN iba_pl_sites_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_iba_pl_sites_Lkup_itm;

PROCEDURE check_iba_pl_sites_items (
      p_iba_pl_sites_rec IN    iba_pl_sites_rec_type
    , p_validation_mode  IN    VARCHAR2
    , x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_iba_pl_sites_uk_items(
        p_iba_pl_sites_rec => p_iba_pl_sites_rec
      , p_validation_mode => p_validation_mode
      , x_return_status => x_return_status
     );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

-- sodixit : commenting following lines : 05/13/01
--   check_iba_pl_sites_req_items(
--      p_iba_pl_sites_rec => p_iba_pl_sites_rec,
--      p_validation_mode => p_validation_mode,
--      x_return_status => x_return_status);
--   IF x_return_status <> FND_API.g_ret_sts_success THEN
--      RETURN;
--   END IF;

   -- Check Items Foreign Keys API calls

--   check_iba_pl_sites_FK_items(
--        p_iba_pl_sites_rec => p_iba_pl_sites_rec
--      , p_validation_mode => p_validation_mode
--      , x_return_status => x_return_status);
--   IF x_return_status <> FND_API.g_ret_sts_success THEN
--      RETURN;
--   END IF;

   -- Check Items Lookups

-- sodixit : commenting following lines : 05/13/01
--   check_iba_pl_sites_Lkup_itm(
--      p_iba_pl_sites_rec => p_iba_pl_sites_rec,
--      x_return_status => x_return_status);
--   IF x_return_status <> FND_API.g_ret_sts_success THEN
--      RETURN;
--   END IF;

END check_iba_pl_sites_items;


PROCEDURE Complete_iba_pl_sites_Rec (
   p_iba_pl_sites_rec IN iba_pl_sites_rec_type,
   x_complete_rec OUT NOCOPY iba_pl_sites_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_iba_pl_sites_b
      WHERE site_id = p_iba_pl_sites_rec.site_id;
   l_iba_pl_sites_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_iba_pl_sites_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_iba_pl_sites_rec;
   CLOSE c_complete;

   -- site_id
   IF p_iba_pl_sites_rec.site_id = FND_API.g_miss_num THEN
      x_complete_rec.site_id := l_iba_pl_sites_rec.site_id;
   END IF;

   -- site_ref_code
   IF p_iba_pl_sites_rec.site_ref_code = FND_API.g_miss_char THEN
      x_complete_rec.site_ref_code := l_iba_pl_sites_rec.site_ref_code;
   END IF;

   -- site_category_type
   IF p_iba_pl_sites_rec.site_category_type = FND_API.g_miss_char THEN
      x_complete_rec.site_category_type := l_iba_pl_sites_rec.site_category_type;
   END IF;

   -- site_category_object_id
   IF p_iba_pl_sites_rec.site_category_object_id = FND_API.g_miss_num THEN
      x_complete_rec.site_category_object_id := l_iba_pl_sites_rec.site_category_object_id;
   END IF;

   -- status_code
   IF p_iba_pl_sites_rec.status_code = FND_API.g_miss_char THEN
      x_complete_rec.status_code := l_iba_pl_sites_rec.status_code;
   END IF;

   -- created_by
   IF p_iba_pl_sites_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_iba_pl_sites_rec.created_by;
   END IF;

   -- creation_date
   IF p_iba_pl_sites_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_iba_pl_sites_rec.creation_date;
   END IF;

   -- last_updated_by
   IF p_iba_pl_sites_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_iba_pl_sites_rec.last_updated_by;
   END IF;

   -- last_update_date
   IF p_iba_pl_sites_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_iba_pl_sites_rec.last_update_date;
   END IF;

   -- last_update_login
   IF p_iba_pl_sites_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_iba_pl_sites_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_iba_pl_sites_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_iba_pl_sites_rec.object_version_number;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_iba_pl_sites_Rec;
PROCEDURE validate_iba_pl_sites(
      p_api_version_number         IN   NUMBER
    , p_init_msg_list              IN   VARCHAR2 := FND_API.G_FALSE
    , p_validation_level           IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
    , p_iba_pl_sites_rec           IN   iba_pl_sites_rec_type
    , x_return_status              OUT NOCOPY  VARCHAR2
    , x_msg_count                  OUT NOCOPY  NUMBER
    , x_msg_data                   OUT NOCOPY  VARCHAR2
    , p_validation_mode  	   IN   VARCHAR2
)
IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'validate_iba_pl_sites';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_iba_pl_sites_rec  AMS_Iba_Pl_Sites_PVT.iba_pl_sites_rec_type;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_iba_pl_sites_;

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
      -- sodixit : commenting following lines as site items will be checked in middle tier
      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
              check_iba_pl_sites_items(
                   p_iba_pl_sites_rec  => p_iba_pl_sites_rec
                 , p_validation_mode   => p_validation_mode
                 , x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_iba_pl_sites_Rec(
         p_iba_pl_sites_rec    => p_iba_pl_sites_rec,
         x_complete_rec        => l_iba_pl_sites_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         validate_iba_pl_sites_rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_iba_pl_sites_rec       => l_iba_pl_sites_rec);

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
     ROLLBACK TO validate_iba_pl_sites_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO validate_iba_pl_sites_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO validate_iba_pl_sites_;
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
End validate_iba_pl_sites;


PROCEDURE validate_iba_pl_sites_rec(
    p_api_version_number IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_msg_count          OUT NOCOPY  NUMBER,
    x_msg_data           OUT NOCOPY  VARCHAR2,
    p_iba_pl_sites_rec   IN  iba_pl_sites_rec_type
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
        (p_count  => x_msg_count,
         p_data   => x_msg_data
      );
END validate_iba_pl_sites_rec;

END AMS_Iba_Pl_Sites_PVT;

/
