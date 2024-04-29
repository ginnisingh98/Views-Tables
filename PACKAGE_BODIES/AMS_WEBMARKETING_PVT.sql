--------------------------------------------------------
--  DDL for Package Body AMS_WEBMARKETING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_WEBMARKETING_PVT" AS
/* $Header: amsvwppb.pls 120.6 2006/08/18 17:52:02 anskumar noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_WEBMARKETING_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvwppb.pls';

-- Hint: Primary key needs to be returned.
AMS_DEBUG_HIGH_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);



-- ========================================================================
-- PROCEDURE
--    handles successful API call for a row during Web ADI ->
--     WebMarketing integration call
-- Purpose
--    COMMIT successful row in database
-- HISTORY
--
-- ========================================================================

	PROCEDURE  WEBMARKETING_PLCE_CONTENT_TYPE (
	   p_api_version_number    IN  NUMBER := 1.0,
	   p_init_msg_list              IN  VARCHAR2  := FND_API.G_FALSE,
	   p_commit                      IN  VARCHAR2  := FND_API.G_FALSE,
	   p_validation_level            IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	   p_placement_mp_id       IN  NUMBER,
	   placement_id           IN NUMBER,
	   x_content_type   OUT    NOCOPY VARCHAR2,
	   x_msg_count           OUT NOCOPY  NUMBER,
	   x_msg_data              OUT NOCOPY  VARCHAR2,
	   x_return_status          OUT NOCOPY VARCHAR2
	) IS


	L_API_NAME               CONSTANT VARCHAR2(30) := 'WEBMARKETING_PLCE_CONTENT_TYPE';
	L_API_VERSION_NUMBER     CONSTANT NUMBER   := 1.0;

	BEGIN

	 -- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
	THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Standard Start of API savepoint

	SAVEPOINT  WEBMARKETING_PLCE_CONTENT_TYPE;

	EXCEPTION

	   WHEN AMS_Utility_PVT.resource_locked THEN
	     x_return_status := FND_API.g_ret_sts_error;
	     AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');


	   WHEN FND_API.G_EXC_ERROR THEN
	     ROLLBACK TO WEBMARKETING_PLCE_CONTENT_TYPE;
	     x_return_status := FND_API.G_RET_STS_ERROR;
	     -- Standard call to get message count and if count=1, get the message

	     FND_MSG_PUB.Count_And_Get (
		    p_encoded => FND_API.G_FALSE,
		    p_count   => x_msg_count,
		    p_data    => x_msg_data
	     );

	   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	     ROLLBACK TO WEBMARKETING_PLCE_CONTENT_TYPE;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	     -- Standard call to get message count and if count=1, get the message
	     FND_MSG_PUB.Count_And_Get (
		    p_encoded => FND_API.G_FALSE,
		    p_count => x_msg_count,
		    p_data  => x_msg_data
	     );

	   WHEN OTHERS THEN
	     ROLLBACK TO WEBMARKETING_PLCE_CONTENT_TYPE;
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


    END WEBMARKETING_PLCE_CONTENT_TYPE;

-- ========================================================================
-- PROCEDURE
--    handles successful API call for a row during Web ADI ->
--     WebMarketing integration call
-- Purpose
--    COMMIT successful row in database
-- HISTORY
--
-- ========================================================================

	PROCEDURE  WEBMARKETING_PLCE_CITEMS (
	   p_api_version_number    IN  NUMBER := 1.0,
	   p_init_msg_list              IN  VARCHAR2  := FND_API.G_FALSE,
	   p_commit                      IN  VARCHAR2  := FND_API.G_FALSE,
	   p_validation_level            IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	   p_placement_mp_id      IN  NUMBER,
	   p_web_mp_rec             IN  web_mp_track_rec_type := g_miss_web_mp_track_rec,
	   x_placement_citem_id_tbl  OUT   NOCOPY  JTF_NUMBER_TABLE,
	   p_content_item_id    IN NUMBER,
	   p_citem_version_id    IN NUMBER,
	   p_association_type   IN VARCHAR2,
	   x_msg_count           OUT   NOCOPY  NUMBER,
	   x_msg_data              OUT  NOCOPY  VARCHAR2,
	   x_return_status          OUT  NOCOPY VARCHAR2
	)  IS

	L_API_NAME               CONSTANT VARCHAR2(30) := 'WEBMARKETING_PLCE_CITEMS';
	L_API_VERSION_NUMBER     CONSTANT NUMBER   := 1.0;
	l_object_version_number     NUMBER := 1;
	l_placement_citem_id_tbl          JTF_NUMBER_TABLE;
	l_placement_citem_count NUMBER;
	l_citem_ver_id NUMBER;
	l_placement_citem_id NUMBER;
	l_assoc_object1 VARCHAR2(30);
	l_assoc_object2 VARCHAR2(30);
	l_assoc_object3 VARCHAR2(30);
	l_assoc_object4 VARCHAR2(30);
	l_assoc_object5 VARCHAR2(30);
	l_content_type_code VARCHAR2(30);
	l_dummy       NUMBER;
	x_placement_citem_id NUMBER;
	i NUMBER := 0;
	l_simple  VARCHAR2(1) := 'Y';


	CURSOR c_citem_assoc_id IS
	    SELECT  AMS_WEB_PLCE_CITEM_ASSOC_S.NEXTVAL
	      FROM dual;

	CURSOR c_citem_assoc_id_exists (l_id IN NUMBER) IS
	      SELECT 1
	      FROM AMS_WEB_PLCE_CITEM_ASSOC
	      WHERE PLACEMENT_CITEM_ID = l_id;


	CURSOR  c_plce_citems(l_citem_version_id  IN NUMBER) IS
		SELECT  civ.CONTENT_ITEM_ID c_item_id ,civ.CITEM_VERSION_ID c_version_id
		FROM  IBC_COMPOUND_RELATIONS cr, IBC_ATTRIBUTE_TYPES_VL attr, IBC_CONTENT_TYPES_VL ct,IBC_CITEM_VERSIONS_VL civ,
		IBC_CONTENT_ITEMS ci WHERE
		cr.ATTRIBUTE_TYPE_CODE = attr.ATTRIBUTE_TYPE_CODE AND
		cr.CONTENT_TYPE_CODE = attr.CONTENT_TYPE_CODE AND
		ct.CONTENT_TYPE_CODE = ci.CONTENT_TYPE_CODE AND
		ci.CONTENT_ITEM_ID = civ.CONTENT_ITEM_ID AND
		cr.CONTENT_ITEM_ID = civ.CONTENT_ITEM_ID AND
		ci.LIVE_CITEM_VERSION_ID = civ.CITEM_VERSION_ID AND
		civ.CITEM_VERSION_STATUS = 'APPROVED' AND
		cr.CITEM_VERSION_ID = l_citem_version_id;

	CURSOR c_citem_ver_id(l_content_item_id  IN NUMBER) IS
		SELECT LIVE_CITEM_VERSION_ID
		   FROM IBC_CONTENT_ITEMS  WHERE CONTENT_ITEM_ID = l_content_item_id;

	citem_rec   c_plce_citems%rowtype;

	BEGIN

	 -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

	-- Standard Start of API savepoint

	SAVEPOINT  webmarketing_plce_citems_pvt;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
     --Bug Fix 4652859
      IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Retrieve the Content Items may be compound or simple .


		OPEN c_citem_ver_id(p_content_item_id);
	                FETCH c_citem_ver_id INTO l_citem_ver_id;
		CLOSE c_citem_ver_id;


		l_placement_citem_id_tbl := JTF_NUMBER_TABLE();
		x_placement_citem_id_tbl := JTF_NUMBER_TABLE();
		 FOR citem_rec IN c_plce_citems ( l_citem_ver_id)
		     LOOP
		      --  Populate the Tables Now
		      -- Call Table Handlers (AMS_WEB_PLCE_CITEM_ASSOC )
		       -- Invoke table handler(AMS_WEB_PLCE_CITEM_ASSOC_PKG.INSERT_ROW)

			    l_simple := 'N';
			    IF (p_web_mp_rec.placement_citem_id IS NULL OR p_web_mp_rec.placement_citem_id = FND_API.g_miss_num) THEN

			      LOOP

				 l_dummy := NULL;
				 OPEN c_citem_assoc_id;
			         FETCH c_citem_assoc_id INTO l_placement_citem_id;
			         CLOSE c_citem_assoc_id;

				 OPEN c_citem_assoc_id_exists(l_placement_citem_id);
				 FETCH c_citem_assoc_id_exists INTO l_dummy;
				 CLOSE c_citem_assoc_id_exists;
				 EXIT WHEN l_dummy IS NULL;

			      END LOOP;
				x_placement_citem_id := l_placement_citem_id;

			   END IF;


			AMS_WEB_CITEM_ASSOC_PKG.Insert_Row(
			  px_placement_citem_id   => l_placement_citem_id,
			  p_placement_mp_id  =>   p_placement_mp_id,
			  p_content_item_id   =>  citem_rec.c_item_id,
			  p_citem_version_id   => citem_rec.c_version_id,
			  p_created_by  =>   FND_GLOBAL.USER_ID,
			  p_creation_date  =>   SYSDATE,
			  p_last_updated_by =>  FND_GLOBAL.USER_ID,
			  p_last_update_date  =>  SYSDATE,
			  p_last_update_login   => FND_GLOBAL.CONC_LOGIN_ID,
			  px_object_version_number  => l_object_version_number,
			  p_return_status        => x_return_status,
			  p_msg_count           => x_msg_data,
			  p_msg_data         =>   x_msg_data);


			   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
						   RAISE FND_API.G_EXC_ERROR;
					 END IF;
			i := i+1;
			l_placement_citem_id_tbl.EXTEND;
			l_placement_citem_id_tbl(i) := l_placement_citem_id;

		   END LOOP;

--  May be a Simple Item

		IF ( i = 0 AND l_simple = 'Y' )  THEN

			  IF (p_web_mp_rec.placement_citem_id IS NULL OR p_web_mp_rec.placement_citem_id = FND_API.g_miss_num) THEN

			      LOOP

				 l_dummy := NULL;
				 OPEN c_citem_assoc_id;
			         FETCH c_citem_assoc_id INTO l_placement_citem_id;
			         CLOSE c_citem_assoc_id;

				 OPEN c_citem_assoc_id_exists(l_placement_citem_id);
				 FETCH c_citem_assoc_id_exists INTO l_dummy;
				 CLOSE c_citem_assoc_id_exists;
				 EXIT WHEN l_dummy IS NULL;

			      END LOOP;
				x_placement_citem_id := l_placement_citem_id;
		      END IF;

			AMS_WEB_CITEM_ASSOC_PKG.Insert_Row(
			  px_placement_citem_id   => l_placement_citem_id,
			  p_placement_mp_id  =>   p_placement_mp_id,
			  p_content_item_id   =>  p_content_item_id,
			  p_citem_version_id   => l_citem_ver_id,
			  p_created_by  =>   FND_GLOBAL.USER_ID,
			  p_creation_date  =>   SYSDATE,
			  p_last_updated_by =>  FND_GLOBAL.USER_ID,
			  p_last_update_date  =>  SYSDATE,
			  p_last_update_login   => FND_GLOBAL.CONC_LOGIN_ID,
			  px_object_version_number  => l_object_version_number,
			  p_return_status        => x_return_status,
			  p_msg_count           => x_msg_data,
			  p_msg_data         =>   x_msg_data);


			   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
						   RAISE FND_API.G_EXC_ERROR;
					 END IF;
			i := i+1;
			l_placement_citem_id_tbl.EXTEND;
			l_placement_citem_id_tbl(i) := l_placement_citem_id;

		END IF;


--- This API would be calling OCM API's for Associations ( IBC_ASSOCIATIONS)
--  p_assoc_type_code => 'AMS_PLCE',
-- p_assoc_object1 =>  object_used_by_id
-- p_assoc_object2 =>  placementid
--p_content_item_id  => p_content_item_id,
--p_citem_version_id  => p_citem_version_id,

		  l_assoc_object1  := p_web_mp_rec.object_used_by_id;
		  l_assoc_object2  := p_web_mp_rec.placement_id;

		  Ibc_Associations_Grp.Create_Association( p_api_version =>  p_api_version_number,
					p_init_msg_list   =>  p_init_msg_list,
					p_commit  => p_commit,
					p_assoc_type_code => 'AMS_PLCE',
					p_assoc_object1  => l_assoc_object1,
					p_assoc_object2  => l_assoc_object2,
					p_assoc_object3  => l_assoc_object3 ,
					p_assoc_object4   => l_assoc_object4,
					p_assoc_object5   => l_assoc_object5,
					p_content_item_id  => p_content_item_id,
					p_citem_version_id  => p_citem_version_id,
					x_return_status   => x_return_status   ,
					x_msg_count      => x_msg_count   ,
					x_msg_data  => x_msg_data  );


	 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			   RAISE FND_API.G_EXC_ERROR;
	 END IF;



     -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

  -- Populate the JTF Number Table
/*

	    l_placement_citem_id_tbl := JTF_NUMBER_TABLE();
	     for i in 1..l_placement_citem_id_tbl.COUNT
		  loop
		    x_placement_citem_id_tbl.EXTEND;
		    x_placement_citem_id_tbl(i) := l_placement_citem_id_tbl(i);
	    end loop;
*/
	    x_placement_citem_id_tbl := l_placement_citem_id_tbl;

	    -- Debug Message

	    IF (AMS_DEBUG_HIGH_ON) THEN
		    AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
	    END IF;

	      -- Standard call to get message count and if count is 1, get message info.
	      FND_MSG_PUB.Count_And_Get
		(p_count          =>   x_msg_count,
		 p_data           =>   x_msg_data
	      );

	-- End of API body

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO webmarketing_plce_citems_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO webmarketing_plce_citems_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO webmarketing_plce_citems_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,L_API_NAME);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

End WEBMARKETING_PLCE_CITEMS;


PROCEDURE VALIDATE_WEB_PLCE_ASSOC(
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
     p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
     p_web_mp_rec             IN   web_mp_track_rec_type,
     x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2,
     p_validation_mode            IN   VARCHAR2
    )
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'VALIDATE_WEB_PLCE_ASSOC';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_web_mp_rec  AMS_WEBMARKETING_PVT.web_mp_track_rec_type;
 l_PLACEMENT_MP_ID                  NUMBER;
 l_object_used_by_id NUMBER;
 l_PLACEMENT_ID                  NUMBER;
 l_application_id  NUMBER;


	 CURSOR c_p_id_exists (l_id IN NUMBER) IS
	      SELECT 1
	      FROM AMS_WEB_PLACEMENTS_B
	      WHERE PLACEMENT_ID = l_id;


	 CURSOR c_site_ref_id (l_site_ref_code IN VARCHAR2) IS
		SELECT site_id
		FROM ams_iba_pl_sites_b
		WHERE site_ref_code = l_site_ref_code;

	 CURSOR c_site_id_exists (l_site_id IN NUMBER) IS
		SELECT site_id
		FROM ams_iba_pl_sites_b
		WHERE site_id = l_site_id;


	CURSOR c_pctype_id_exists (l_id IN NUMBER) IS
	      SELECT 1
	      FROM AMS_WEB_PLCE_CTYPE_ASSOC
	      WHERE PLACEMENT_ID = l_id;

	CURSOR c_campaign_id_exists (l_id IN NUMBER) IS
	      SELECT 1
	      FROM AMS_CAMPAIGNS_ALL_B
	      WHERE CAMPAIGN_ID = l_id;

	CURSOR c_campaign_schedule_id_exists (l_id IN NUMBER) IS
	      SELECT 1
	      FROM AMS_CAMPAIGN_SCHEDULES_B
	      WHERE SCHEDULE_ID = l_id;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_WEB_PLCE_ASSOC_PVT;

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

    --  Verify Campaign Id   ( is it required )
    --  Verify Campaign Schedule Id
    -- Verify   Placement Id
     -- Verify  Application Id
     -- Verify Content Item
     -- Verify Content Item Version Id
     --  Verify Content Type Code
     -- Validate all the cursor values

	OPEN c_campaign_schedule_id_exists(l_web_mp_rec.object_used_by_id);
		FETCH c_campaign_schedule_id_exists INTO l_object_used_by_id;
        CLOSE c_campaign_schedule_id_exists;

	OPEN c_p_id_exists(l_web_mp_rec.placement_id);
		FETCH c_p_id_exists INTO l_PLACEMENT_ID;
        CLOSE c_p_id_exists;

	OPEN c_site_id_exists(l_web_mp_rec.application_id);
		FETCH c_site_id_exists INTO l_application_id;
        CLOSE c_site_id_exists;

	OPEN c_pctype_id_exists(l_web_mp_rec.object_used_by_id);
		FETCH c_pctype_id_exists INTO l_object_used_by_id;
        CLOSE c_pctype_id_exists;

	 IF x_return_status = FND_API.G_RET_STS_ERROR THEN
			  RAISE FND_API.G_EXC_ERROR;
	     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	     END IF;
	END IF;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
		IF (AMS_DEBUG_HIGH_ON) THEN
		AMS_UTILITY_PVT.debug_message('In Validate: before VALIDATE_WEB_PLCE_ASSOC call ' );
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
	      ROLLBACK TO VALIDATE_WEB_PLCE_ASSOC_PVT;
	     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_WEB_PLCE_ASSOC_PVT;
	IF (AMS_DEBUG_HIGH_ON) THEN
		AMS_UTILITY_PVT.debug_message('In Validate - unexpected err: validation_mode= ' || p_validation_mode);
	END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_WEB_PLCE_ASSOC_PVT;
	IF (AMS_DEBUG_HIGH_ON) THEN

	AMS_UTILITY_PVT.debug_message('In Validate - others err: validation_mode= ' || p_validation_mode);
	END IF;
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

End VALIDATE_WEB_PLCE_ASSOC;


---------------------------------------------------------------------
-- FUNCTION
--    check_citem_version_id
-- HISTORY
---------------------------------------------------------------------


FUNCTION  check_citem_version_id(
   p_content_item_id         IN  NUMBER
 )
RETURN NUMBER
IS
 CURSOR c_citem_version_id  IS
 SELECT  CITEM_VER_ID
   FROM  IBC_CITEMS_V
  WHERE CITEM_ID = p_content_item_id;
 l_citem_ver_id NUMBER;

BEGIN

  OPEN c_citem_version_id;
  FETCH c_citem_version_id INTO l_citem_ver_id;
  CLOSE c_citem_version_id;

  return l_citem_ver_id;

  END check_citem_version_id;

---------------------------------------------------------------------
-- FUNCTION
--    check_placement_publish  : Verify the Publish status of the Placement
-- HISTORY
---------------------------------------------------------------------

FUNCTION  check_placement_publish(
   p_placement_id         IN  NUMBER
 )
RETURN VARCHAR
IS
 CURSOR c_check_placement_publish  IS
 select auto_publish_flag from ams_web_placements_b where placement_id = p_placement_id;
 l_publish VARCHAR2(1);

BEGIN

  OPEN c_check_placement_publish;
  FETCH c_check_placement_publish INTO l_publish;
  CLOSE c_check_placement_publish;

  return l_publish;

  END check_placement_publish;

-- ========================================================================
-- PROCEDURE
--    handles successful API call for a row during Web ADI ->
--     WebMarketing integration call
-- Purpose
--    COMMIT successful row in database
-- HISTORY
--
-- ========================================================================

PROCEDURE CREATE_WEB_PLCE_ASSOC (
		 p_api_version_number    IN  NUMBER := 1.0,
		 p_init_msg_list            IN  VARCHAR2  := FND_API.G_FALSE,
		 p_commit                    IN  VARCHAR2  := FND_API.G_FALSE,
		 p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
		 p_web_mp_rec             IN   web_mp_track_rec_type := g_miss_web_mp_track_rec,
		 x_placement_mp_id     OUT NOCOPY  NUMBER,
		 x_placement_citem_id_tbl  OUT NOCOPY JTF_NUMBER_TABLE,
		 x_msg_count              OUT NOCOPY  NUMBER,
		 x_msg_data                OUT NOCOPY  VARCHAR2,
		 x_return_status           OUT NOCOPY VARCHAR2
	)  IS

	L_API_NAME               CONSTANT VARCHAR2(30) := 'CREATE_WEB_PLCE_ASSOC';
	L_API_VERSION_NUMBER     CONSTANT NUMBER   := 1.0;
	l_object_version_number     NUMBER := 1;
	l_dummy       NUMBER;
	l_PLACEMENT_MP_ID                  NUMBER;
        l_validation_mode VARCHAR2(30);
        l_rowid VARCHAR2(100);
       l_content_type_code  VARCHAR2(100);
       L_CITEM_VERSION_ID  NUMBER;
       l_publish_flag  Varchar2(1);
       l_placement_citem_id_tbl          JTF_NUMBER_TABLE;

	CURSOR c_mp_id IS
	    SELECT  AMS_WEB_PLCE_MP_B_S.NEXTVAL
	      FROM dual;

	CURSOR c_citem_assoc_id IS
	    SELECT  AMS_WEB_PLCE_CITEM_ASSOC_S.NEXTVAL
	      FROM dual;

	CURSOR c_mp_id_exists (l_id IN NUMBER) IS
	      SELECT 1
	      FROM AMS_WEB_PLCE_MP_B
	      WHERE PLACEMENT_MP_ID = l_id;

	CURSOR c_citem_assoc_id_exists (l_id IN NUMBER) IS
	      SELECT 1
	      FROM AMS_WEB_PLCE_CITEM_ASSOC
	      WHERE PLACEMENT_CITEM_ID = l_id;

	CURSOR c_media_id (l_id IN NUMBER) IS
	      SELECT 1
	      FROM AMS_MEDIA_B
	      WHERE MEDIA_ID = l_id;



	BEGIN

	-- Standard Start of API savepoint
	SAVEPOINT CREATE_WEB_PLCE_ASSOC;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
	                                   p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean(p_init_msg_list)
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN
	      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

       -- Validate the In Rec

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
               AMS_UTILITY_PVT.debug_message('Private API: VALIDATE_WEB_PLCE_ASSOC');
          END IF;

          -- Invoke validation procedures


       END IF;

 	IF (AMS_DEBUG_HIGH_ON) THEN
		AMS_UTILITY_PVT.debug_message('In CREATE_WEB_PLCE_ASSOC: before VALIDATE_WEB_PLCE_ASSOC call ' );
	END IF;

	IF (AMS_DEBUG_HIGH_ON) THEN
		AMS_UTILITY_PVT.debug_message('In CREATE_WEB_PLCE_ASSOC: before VALIDATE_WEB_PLCE_ASSOC call ' );
	END IF;

     -- Local variable initialization


        IF (p_web_mp_rec.PLACEMENT_MP_ID IS NULL OR p_web_mp_rec.PLACEMENT_MP_ID = FND_API.g_miss_num) THEN
      LOOP
         l_dummy := NULL;
         OPEN c_mp_id;
         FETCH c_mp_id INTO l_PLACEMENT_MP_ID;
         CLOSE c_mp_id;

         OPEN c_mp_id_exists(l_PLACEMENT_MP_ID);
         FETCH c_mp_id_exists INTO l_dummy;
         CLOSE c_mp_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
	x_PLACEMENT_MP_ID := l_PLACEMENT_MP_ID;
   END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      END IF;

      -- Invoke table handler(AMS_WEB_PLCE_MP_PKG.INSERT_ROW)

      -- Verify the Activity_ID

      -- IF  ( p_web_mp_rec.activity_id = 510 ) THEN
	--	l_content_type_code := 'AMS_WEB_PROD_RECOM';

        IF (p_web_mp_rec.activity_id = 30  OR p_web_mp_rec.activity_id  = 40 ) THEN
		l_content_type_code := 'AMS_WEB_AD';
      END IF;

-- call to get the citem-version-id

		l_citem_version_id := check_citem_version_id(p_web_mp_rec.content_item_id);
		l_publish_flag := check_placement_publish(p_web_mp_rec.placement_id);

		 AMS_WEB_PLCE_MP_PKG.INSERT_ROW(
			  x_rowid  => l_rowid,
			  x_placement_mp_id  => l_placement_mp_id,
			  x_placement_id => p_web_mp_rec.placement_id,
			  x_content_item_id => p_web_mp_rec.content_item_id,
			  x_citem_version_id => l_citem_version_id,
			  x_display_priority => p_web_mp_rec.display_priority,
			  x_publish_flag => l_publish_flag,
			  x_max_recommendations => p_web_mp_rec.max_recommendations,
			  x_object_used_by_id => p_web_mp_rec.object_used_by_id,
			  x_object_used_by =>  p_web_mp_rec.object_used_by,
			  x_security_group_id => null,
			  x_object_version_number => l_object_version_number,
			  x_attribute_category => null,
			  x_attribute1 => null,
			  x_attribute2 => null,
			  x_attribute3 => null,
			  x_attribute4 => null,
			  x_attribute5 => null,
			  x_attribute6 => null,
			  x_attribute7 => null,
			  x_attribute8 => null,
			  x_attribute9 => null,
			  x_attribute10 => null,
			  x_attribute11 => null,
			  x_attribute12 => null,
			  x_attribute13 => null,
			  x_attribute14 => null,
			  x_attribute15 => null,
			  x_content_type_code => l_content_type_code ,
			  x_placement_mp_title => p_web_mp_rec.placement_mp_title,
			  x_creation_date => sysdate ,
			  x_created_by =>  fnd_global.user_id,
			  x_last_update_date => sysdate,
			  x_last_updated_by => fnd_global.user_id,
			  x_last_update_login => fnd_global.conc_login_id );


		      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			  RAISE FND_API.G_EXC_ERROR;
		      END IF;

		-- Only for WebAdv / WebOffer
		-- Verify the media-id for the Dynamic recommendations

		      IF  (p_web_mp_rec.activity_id <> 510 )   THEN

				 WEBMARKETING_PLCE_CITEMS (
				   p_api_version_number   =>  p_api_version_number,
				   p_init_msg_list    =>        p_init_msg_list,
				   p_commit          => p_commit ,
				   p_validation_level    => p_validation_level,
				   p_placement_mp_id => l_placement_mp_id,
				   p_web_mp_rec => p_web_mp_rec,
				   x_placement_citem_id_tbl  => l_placement_citem_id_tbl ,
				   p_content_item_id    => p_web_mp_rec.content_item_id,
				   p_citem_version_id   => p_web_mp_rec.citem_version_id,
				   p_association_type  =>   'AMS_PLCE',
				   x_msg_count           =>  x_msg_count,
				   x_msg_data            =>  x_msg_data ,
				   x_return_status         => x_return_status
				 );


			 END IF;

		 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  RAISE FND_API.G_EXC_ERROR;
	      END IF;

		x_return_status := FND_API.G_RET_STS_SUCCESS;

	     -- Standard check for p_commit   ( This shud be romved after testing - Actual Commit is done by the calling program )
	     IF FND_API.to_Boolean( p_commit)  THEN
		 COMMIT WORK;
	      END IF;

	       -- Debug Message
	   --   IF (AMS_DEBUG_HIGH_ON) THEN
	     --       AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
	   --   END IF;

	      -- Standard call to get message count and if count is 1, get message info.
	      FND_MSG_PUB.Count_And_Get    (p_count          =>   x_msg_count,
		 p_data           =>   x_msg_data
	      );

	 x_placement_mp_id  :=  l_placement_mp_id;
	 x_placement_citem_id_tbl := l_placement_citem_id_tbl;
/*
          for i in 1..l_placement_citem_id_tbl.COUNT
		  loop
		    x_placement_citem_id_tbl.EXTEND;
		    x_placement_citem_id_tbl(i) := l_placement_citem_id_tbl(i);
	    end loop;
*/
	-- End of API body

	EXCEPTION

	   WHEN AMS_Utility_PVT.resource_locked THEN
	     x_return_status := FND_API.g_ret_sts_error;
	     AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');


	   WHEN FND_API.G_EXC_ERROR THEN
	     ROLLBACK TO CREATE_WEB_PLCE_ASSOC;
	     x_return_status := FND_API.G_RET_STS_ERROR;
	     -- Standard call to get message count and if count=1, get the message

	     FND_MSG_PUB.Count_And_Get (
		    p_encoded => FND_API.G_FALSE,
		    p_count   => x_msg_count,
		    p_data    => x_msg_data
	     );

	   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	     ROLLBACK TO CREATE_WEB_PLCE_ASSOC;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	     -- Standard call to get message count and if count=1, get the message
	     FND_MSG_PUB.Count_And_Get (
		    p_encoded => FND_API.G_FALSE,
		    p_count => x_msg_count,
		    p_data  => x_msg_data
	     );

	   WHEN OTHERS THEN
	     ROLLBACK TO CREATE_WEB_PLCE_ASSOC;
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

	End CREATE_WEB_PLCE_ASSOC;





-- ========================================================================
-- PROCEDURE
--    handles successful API call for a row during Web ADI ->
--     WebMarketing integration call
-- Purpose
--
-- HISTORY
--
-- ========================================================================

	PROCEDURE  WEBMARKETING_PLCE_CONTENT_TYPE (
	   p_api_version_number    IN  NUMBER := 1.0,
	   p_init_msg_list              IN  VARCHAR2  := FND_API.G_FALSE,
	   p_commit                      IN  VARCHAR2  := FND_API.G_FALSE,
	   p_validation_level            IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	   p_placement_mp_id       IN  NUMBER,
	   p_content_item_id	   IN NUMBER,
	   x_content_type  OUT  NOCOPY VARCHAR2,
	   x_msg_count           OUT NOCOPY  NUMBER,
	   x_msg_data              OUT NOCOPY  VARCHAR2,
	   x_return_status          OUT NOCOPY VARCHAR2
	) IS

	L_API_NAME               CONSTANT VARCHAR2(30) := 'WEBMARKETING_PLCE_CONTENT_TYPE';
	L_API_VERSION_NUMBER     CONSTANT NUMBER   := 1.0;
	l_placement_mp_id NUMBER;

	CURSOR c_ctype_code (l_placement_mp_id IN NUMBER) IS
		SELECT content_type_code
		FROM ams_web_plce_mp_b
		WHERE placement_mp_id = l_placement_mp_id;

	CURSOR c_mp_id_exists (l_placement_mp_id IN NUMBER) IS
	      SELECT 1
	      FROM AMS_WEB_PLCE_MP_B
	      WHERE PLACEMENT_MP_ID = l_placement_mp_id;

--  Need to verify the Content Type Code Presence in IBC  Schema Also

         CURSOR c_content_id_exists (l_content_item_id IN NUMBER) IS
	 	 SELECT CONTENT_TYPE_CODE from
		    IBC_CONTENT_ITEMS WHERE CONTENT_ITEM_ID = l_content_item_id AND CONTENT_ITEM_STATUS = 'APPROVED';


	BEGIN

	-- Standard Start of API savepoint
	SAVEPOINT webmarketing_plce_content_type ;

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
      --Bug Fix 4652859
      IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.debug_message('Private API: ' || L_API_NAME || 'start');
      END IF;


    -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

	OPEN c_mp_id_exists(p_placement_mp_id);
		FETCH c_mp_id_exists INTO l_placement_mp_id;
        CLOSE c_mp_id_exists;

	IF  (l_placement_mp_id = p_placement_mp_id )  THEN
		OPEN c_ctype_code(l_placement_mp_id);
			FETCH c_ctype_code INTO x_content_type;
		CLOSE c_ctype_code;
	END IF;

	OPEN c_content_id_exists(p_placement_mp_id);
		FETCH c_mp_id_exists INTO l_placement_mp_id;
        CLOSE c_mp_id_exists;


	-- x_content_type  := l_content_type;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO webmarketing_plce_content_type;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO webmarketing_plce_content_type;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO webmarketing_plce_content_type;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,L_API_NAME);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

End  WEBMARKETING_PLCE_CONTENT_TYPE;

-- ========================================================================
-- PROCEDURE
--    Integration API Call for WebPlacement Content Status for Approval Process- ->
--     WebMarketing integration call
-- Purpose
--    WebMarketing integration call  for Campaign Activity Approval Process
-- HISTORY
--
-- ========================================================================


PROCEDURE  WEBMARKETING_CONTENT_STATUS (
	   p_api_version_number    IN  NUMBER := 1.0,
	   p_init_msg_list              IN  VARCHAR2  := FND_API.G_FALSE,
	   p_validation_level            IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	   p_campaign_activity_id       IN  NUMBER,
	   x_msg_count           OUT NOCOPY  NUMBER,
	   x_msg_data              OUT NOCOPY  VARCHAR2,
	   x_return_status          OUT NOCOPY VARCHAR2
	) IS

	L_API_NAME               CONSTANT VARCHAR2(30) := 'WEBMARKETING_CONTENT_STATUS';
	L_API_VERSION_NUMBER     CONSTANT NUMBER   := 1.0;
	l_campaign_activity_id NUMBER;
	l_content_id NUMBER;
	l_media_id NUMBER;

	CURSOR c_campaign_activity_id_exists (l_campaign_activity_id IN NUMBER) IS
 	       SELECT sched.schedule_id
	       FROM  AMS_CAMPAIGN_SCHEDULES_B SCHED, AMS_WEB_PLCE_MP_B MP
	       WHERE SCHED.SCHEDULE_ID = MP.OBJECT_USED_BY_ID AND SCHED.SCHEDULE_ID =  L_CAMPAIGN_ACTIVITY_ID;

        CURSOR c_media_id_exists(l_schedule_id IN NUMBER) IS
  	       SELECT activity_id FROM ams_campaign_schedules_b where SCHEDULE_ID=l_schedule_id;

	 CURSOR c_content_id_exists(l_campaign_activity_id  IN NUMBER) IS
	       SELECT Assn.content_item_id , Citem.live_citem_version_id
		FROM   IBC_ASSOCIATIONS  Assn, IBC_CONTENT_ITEMS Citem
		WHERE  Assn.ASSOCIATED_OBJECT_VAL1 = TO_CHAR(l_campaign_activity_id)
	        AND  Assn.CONTENT_ITEM_ID    = Citem.CONTENT_ITEM_ID
	       AND Citem.CONTENT_ITEM_STATUS <> 'APPROVED'
	       AND Assn.ASSOCIATION_TYPE_CODE  in ('AMS_PLCE') ;

-- if required
-- mp.placement_mp_id ,sched.schedule_id, mp.content_item_id
-- l_mp_activity_rec  c_campaign_activity_id_exists%rowtype;

		l_content_item_rec  c_content_id_exists%rowtype;


BEGIN

	-- Standard Start of API savepoint
	SAVEPOINT WEBMARKETING_CONTENT_STATUS_S ;

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
	--Bug Fix 4652859
      IF (AMS_DEBUG_HIGH_ON) THEN
           AMS_UTILITY_PVT.debug_message('Private API: ' || L_API_NAME || 'start');
      END IF;


    -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF (p_campaign_activity_id IS NOT NULL ) THEN

	OPEN c_media_id_exists(p_campaign_activity_id);
		FETCH c_media_id_exists INTO l_media_id;
        CLOSE c_media_id_exists;

    --Added the Media_id=510 for Web Dynamic Rec Activity Bug : 5468790

	IF (l_media_id = 30 OR  l_media_id = 40 OR l_media_id = 510) THEN

		OPEN c_campaign_activity_id_exists(p_campaign_activity_id);
			FETCH c_campaign_activity_id_exists INTO l_campaign_activity_id;
		CLOSE c_campaign_activity_id_exists;

		-- valid association
		IF (l_campaign_activity_id IS NOT NULL) THEN

		OPEN c_content_id_exists(l_campaign_activity_id);
			FETCH c_content_id_exists INTO l_content_item_rec;
		CLOSE c_content_id_exists;

		  IF (l_content_item_rec.content_item_id IS NULL) then
		    x_return_status := FND_API.G_RET_STS_SUCCESS;
		  ELSE
		      x_return_status := FND_API. G_RET_STS_ERROR;
		     FND_MESSAGE.set_name('AMS', 'AMS_WEB_PLCE_CITEM_NOT_APPR');
		    FND_MSG_PUB.add;
		     FND_MSG_PUB.Count_AND_Get
		       ( p_count           =>      x_msg_count,
			 p_data            =>      x_msg_data,
			 p_encoded         =>      FND_API.G_FALSE
		       );
		 END IF;
	-- Invalid association
   	      ELSE
		    x_return_status := FND_API. G_RET_STS_ERROR;
		    FND_MESSAGE.set_name('AMS', 'AMS_WEB_PLCE_ACTIVITY_INVALID');
		    FND_MSG_PUB.add;
		     FND_MSG_PUB.Count_AND_Get
		       ( p_count           =>      x_msg_count,
			 p_data            =>      x_msg_data,
			 p_encoded         =>      FND_API.G_FALSE
		       );
	   END IF;

       ELSE

        -- not required to validate
		x_return_status := FND_API. G_RET_STS_SUCCESS;

	END IF;

	ELSE

	-- Invalid activity id passed
            x_return_status := FND_API. G_RET_STS_ERROR;
	    FND_MESSAGE.set_name('AMS', 'AMS_WEB_PLCE_NO_ACTIVITY');
            FND_MSG_PUB.add;
             FND_MSG_PUB.Count_AND_Get
	       ( p_count           =>      x_msg_count,
	         p_data            =>      x_msg_data,
	         p_encoded         =>      FND_API.G_FALSE
	       );

	END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO WEBMARKETING_CONTENT_STATUS_S;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO WEBMARKETING_CONTENT_STATUS_S;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO WEBMARKETING_CONTENT_STATUS_S;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,L_API_NAME);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

End  WEBMARKETING_CONTENT_STATUS;


END  AMS_WEBMARKETING_PVT;


/
