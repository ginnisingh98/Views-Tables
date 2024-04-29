--------------------------------------------------------
--  DDL for Package Body AMS_MEDIA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_MEDIA_PVT" AS
/* $Header: amsvmedb.pls 115.35 2004/05/14 10:50:29 vmodur ship $ */

------------------------------------------------------------------------------------------
-- PACKAGE
--    AMS_Media_PVT
--
-- PROCEDURES
--    AMS_MEDIA_VL:
--       Check_Media_Req_Items
--       Check_Media_UK_Items
--       Check_Media_FK_Items
--       Check_Media_Lookup_Items
--       Check_Media_Flag_Items
--
--    AMS_MEDIA_CHANNELS:
--       Check_MediaChannel_Req_Items
--       Check_MediaChannel_UK_Items
--       Check_MediaChannel_FK_Items
--       Check_MediaChl_Lookup_Items
--       Check_MediaChannel_Flag_Items
--       Check_MediaChannel_InterEntity
--
-- NOTES
--
--
-- HISTORY
-- 03-Nov-1999    choang      Created.
-- 19-Nov-1999    choang      Added Inter-Entity validation.
-- 10-Dec-1999    ptendulk    Modified Create Media API as
--                            Media with media_type_code = EVENTS can not be created
-- 15-dec-1999    ptendulk    Modified Create Media Channel API
-- 31-Dec-1999    ptendulk    Modified (Check Object Version Number before
--                            updating /deleting)
-- 07-Nov-2000    rrajesh     Modified the uniqueness checking of media_name, by replacing
--                            the AMS_Utility_PVT call with c_name_unique_cr,
--                            c_name_unique_up cursors.
-- 06-Dec-2000    julou       Commented out procedure check_media_flag_items
-- 07-Nov-2000    rrajesh     Bug fix. 2005131. Moved dependancy checking of media from
--                            campaign level to schedule level.
-- 31-OCT-2001    rrajesh     Bug fix:2089112
-- 31-Dec-2002    dbiswas     updated cursor c_check_schedule_association
-- 12-Feb-2003    vmodur      Bug 2766207 Fix in Update_MediaChannel
-- 14-May-2004    vmodur      SQL Perf Fixes
------------------------------------------------------------------------------------------

--
-- Global CONSTANTS
G_PKG_NAME           CONSTANT VARCHAR2(30) := 'AMS_Media_PVT';

--       Check_Media_Req_Items
AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Check_Media_Req_Items (
   p_media_rec       IN    Media_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
);

--       Check_Media_UK_Items
PROCEDURE Check_Media_UK_Items (
   p_media_rec       IN    Media_Rec_Type,
   p_validation_mode IN    VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY   VARCHAR2
);

--       Check_Media_FK_Items
PROCEDURE Check_Media_FK_Items (
   p_media_rec       IN    Media_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
);

--       Check_Media_Lookup_Items
PROCEDURE Check_Media_Lookup_Items (
   p_media_rec       IN    Media_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
);

--       Check_Media_Flag_Items
/*
PROCEDURE Check_Media_Flag_Items (
   p_media_rec       IN    Media_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
);
*/

--       Check_MediaChannel_Req_Items
PROCEDURE Check_MediaChannel_Req_Items (
   p_mediachl_rec    IN    MediaChannel_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
);

--       Check_MediaChannel_UK_Items
PROCEDURE Check_MediaChannel_UK_Items (
   p_mediachl_rec    IN    MediaChannel_Rec_Type,
   p_validation_mode IN    VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY   VARCHAR2
);

--       Check_MediaChannel_FK_Items
PROCEDURE Check_MediaChannel_FK_Items (
   p_mediachl_rec    IN    MediaChannel_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
);

--       Check_MediaChl_Lookup_Items
PROCEDURE Check_MediaChl_Lookup_Items (
   p_mediachl_rec    IN    MediaChannel_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
);

--       Check_MediaChannel_Flag_Items
PROCEDURE Check_MediaChannel_Flag_Items (
   p_mediachl_rec    IN    MediaChannel_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
);

--
-- PROCEDURE
--    Check_MediaChannel_InterEntity
PROCEDURE Check_MediaChannel_InterEntity (
   p_mediachl_rec       IN MediaChannel_Rec_Type,
   p_complete_rec       IN MediaChannel_Rec_Type := NULL,
   x_return_status      OUT NOCOPY VARCHAR2
);

-------------------------------------
-----          MEDIA            -----
-------------------------------------

--
-- NAME
--    IsSeeded
--
-- PURPOSE
--    Returns whether the given ID is that of a seeded record.
--
-- NOTES
--    As of creation of the function, a seeded record has an ID
--    less than 10,000.
--
-- HISTORY
-- 01/05/2000   ptendulk         Created.
--
FUNCTION IsSeeded (
   p_id        IN NUMBER
)
RETURN BOOLEAN
IS
BEGIN
   IF p_id < 10000 THEN
      RETURN TRUE;
   END IF;

   RETURN FALSE;
END IsSeeded;


--------------------------------------------------------------------
-- PROCEDURE
--    Create_Media
--
--------------------------------------------------------------------
PROCEDURE Create_Media (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_media_rec         IN  Media_Rec_Type,
   x_media_id          OUT NOCOPY NUMBER
)
IS
   L_API_VERSION        CONSTANT NUMBER := 1.0;
   L_API_NAME           CONSTANT VARCHAR2(30) := 'Create_Media';
   L_FULL_NAME          CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

   l_media_rec          Media_Rec_Type := p_media_rec;
   l_dummy              NUMBER;
   l_return_status      VARCHAR2(1);

   CURSOR c_seq IS
      SELECT ams_media_b_s.NEXTVAL
      FROM   dual;

   CURSOR c_id_exists (x_id IN NUMBER) IS
      SELECT 1
      FROM   dual
      WHERE EXISTS (SELECT 1
                    FROM   ams_media_b
                    WHERE  media_id = x_id);

BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Create_Media;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message (l_full_name || ': Start');

   END IF;

   IF FND_API.to_boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call (
         L_API_VERSION,
         p_api_version,
         L_API_NAME,
         G_PKG_NAME
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- validate -----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': Validate');
   END IF;

-- Start of Comments by ptendulk
-- Following lines are commented on 10-Dec-1999 as
-- Media with Media_type_code = 'EVENTS' can not not be created and
-- can be created with media_type_code = 'DIRECT_MARKETING'
-- End of Comments by ptendulk

--    IF p_media_rec.media_type_code = 'DIRECT_MARKETING' THEN
--      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
--         FND_MESSAGE.set_name ('AMS', 'AMS_MED_CANT_CREATE_DM_MEDIA');
--         FND_MSG_PUB.add;
--      END IF;
--      RAISE FND_API.g_exc_error;
--   END IF;


    IF p_media_rec.media_type_code = 'EVENTS' THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_MED_CANT_CREATE_EVE_MEDIA');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

    IF p_media_rec.media_type_code = 'INTERNET' THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_MED_CANT_CR_INTERNET_MEDIA');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   Validate_Media (
      p_api_version        => l_api_version,
      p_init_msg_list      => p_init_msg_list,
      p_validation_level   => p_validation_level,
      x_return_status      => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_media_rec          => l_media_rec
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   --
   -- Check for the ID.
   --
   IF l_media_rec.media_id IS NULL THEN
      LOOP
         --
         -- If the ID is not passed into the API, then
         -- grab a value from the sequence.
         OPEN c_seq;
         FETCH c_seq INTO l_media_rec.media_id;
         CLOSE c_seq;

         --
         -- Check to be sure that the sequence does not exist.
         OPEN c_id_exists (l_media_rec.media_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;

         --
         -- If the value for the ID already exists, then
         -- l_dummy would be populated with '1', otherwise,
         -- it receives NULL.
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   END IF;

   -------------------------- insert --------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': Insert');
   END IF;

	--
   -- Insert into mutli-language supported table.
   --
   INSERT INTO ams_media_b (
	   media_id,

	   -- standard who columns
 	   last_update_date,
 	   last_updated_by,
 	   creation_date,
 	   created_by,
	   last_update_login,

      object_version_number,
	   media_type_code,
	   inbound_flag,
 	   enabled_flag,

	   attribute_category,
 	   attribute1,
 	   attribute2,
 	   attribute3,
 	   attribute4,
 	   attribute5,
 	   attribute6,
 	   attribute7,
 	   attribute8,
 	   attribute9,
 	   attribute10,
 	   attribute11,
 	   attribute12,
 	   attribute13,
 	   attribute14,
 	   attribute15
	)
	VALUES (
	   l_media_rec.media_id,

	   -- standard who columns
	   SYSDATE,
	   FND_GLOBAL.User_Id,
	   SYSDATE,
	   FND_GLOBAL.User_Id,
	   FND_GLOBAL.Conc_Login_Id,

      1,    -- object_version_number
	   l_media_rec.media_type_code,
	   NVL (l_media_rec.inbound_flag, 'Y'),   -- Default is 'Y'. changed from 'N' to 'Y' by julou, 12/06/2000
 	   NVL (l_media_rec.enabled_flag, 'Y'),   -- Default is 'Y'

	   l_media_rec.attribute_category,
 	   l_media_rec.attribute1,
 	   l_media_rec.attribute2,
 	   l_media_rec.attribute3,
 	   l_media_rec.attribute4,
 	   l_media_rec.attribute5,
 	   l_media_rec.attribute6,
 	   l_media_rec.attribute7,
 	   l_media_rec.attribute8,
 	   l_media_rec.attribute9,
 	   l_media_rec.attribute10,
 	   l_media_rec.attribute11,
 	   l_media_rec.attribute12,
 	   l_media_rec.attribute13,
 	   l_media_rec.attribute14,
 	   l_media_rec.attribute15
	);

	INSERT INTO ams_media_tl (
 	   media_id,
      language,
 	   last_update_date,
 	   last_updated_by,
 	   creation_date,
 	   created_by,
 	   last_update_login,
 	   source_lang,
	   media_name,
 	   description
   )
   SELECT   l_media_rec.media_id,
	         l.language_code,
            -- standard who columns
	         SYSDATE,
	         FND_GLOBAL.User_Id,
	         SYSDATE,
	         FND_GLOBAL.User_Id,
	         FND_GLOBAL.Conc_Login_Id,
            USERENV('LANG'),
	         l_media_rec.media_name,
	         l_media_rec.description
  	FROM     fnd_languages l
  	WHERE    l.installed_flag IN ('I', 'B')
  	AND NOT EXISTS (SELECT  NULL
    		          FROM    ams_media_tl t
    		          WHERE   t.media_id = l_media_rec.media_id
    		          AND     t.language = l.language_code);

   ------------------------- finish -------------------------------
	-- set OUT value
	x_media_id := l_media_rec.media_id;

        --
        -- END of API body.
        --

        -- Standard check of p_commit.
   IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message (l_full_name || ': End');

   END IF;

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Create_Media;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Create_Media;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Media;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Create_Media;


--------------------------------------------------------------------
-- PROCEDURE
--    Update_Media
--
--------------------------------------------------------------------
PROCEDURE Update_Media (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_media_rec         IN  Media_Rec_Type
)
IS
   L_API_VERSION        CONSTANT NUMBER := 1.0;
   L_API_NAME           CONSTANT VARCHAR2(30) := 'Update_Media';
   L_FULL_NAME          CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

   l_media_rec          Media_Rec_Type := p_media_rec;
   l_dummy              NUMBER;
   l_return_status      VARCHAR2(1);

BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Update_Media;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message (l_full_name || ': Start');

   END IF;

   IF FND_API.to_boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- validate ----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': Validate');
   END IF;

   --
   -- Check if record is seeded.
   --
   -- Seed Data can be disabled
 /***
   IF IsSeeded (p_media_rec.media_id) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_SEED_DATA');
         FND_MSG_PUB.add;
      END IF;

      RAISE FND_API.G_EXC_ERROR;
   END IF;
***/

   -- replace g_miss_char/num/date with current column values
   Complete_Media_Rec (p_media_rec, l_media_rec);

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Check_Media_Items (
         p_media_rec          => p_media_rec,
         p_validation_mode    => JTF_PLSQL_API.g_update,
         x_return_status      => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Check_Media_Record (
         p_media_rec       => p_media_rec,
         p_complete_rec    => l_media_rec,
         x_return_status   => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -------------------------- update --------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': Update');
   END IF;

-- Modified by ptendulk on 30Dec1999
-- Check Obj Version Number before Updating
	UPDATE ams_media_b
	SET
		last_update_date        = SYSDATE,
		last_updated_by 	      = FND_GLOBAL.User_Id,
		last_update_login       = FND_GLOBAL.Conc_Login_Id,

		object_version_number   = object_version_number + 1,
      media_type_code	      = l_media_rec.media_type_code,
		inbound_flag            = NVL (l_media_rec.inbound_flag, 'Y'), -- changed default value to 'Y', julou 12/06/2000
		enabled_flag		      = NVL (l_media_rec.enabled_flag, 'Y'),

		attribute_category      = l_media_rec.attribute_category,
		attribute1 		         = l_media_rec.attribute1,
		attribute2 		         = l_media_rec.attribute2,
		attribute3 		         = l_media_rec.attribute3,
		attribute4 		         = l_media_rec.attribute4,
		attribute5 		         = l_media_rec.attribute5,
		attribute6 		         = l_media_rec.attribute6,
		attribute7 		         = l_media_rec.attribute7,
		attribute8 		         = l_media_rec.attribute8,
		attribute9 		         = l_media_rec.attribute9,
		attribute10 		      = l_media_rec.attribute10,
		attribute11 		      = l_media_rec.attribute11,
		attribute12 		      = l_media_rec.attribute12,
		attribute13 		      = l_media_rec.attribute13,
		attribute14 		      = l_media_rec.attribute14,
		attribute15 		      = l_media_rec.attribute15
	WHERE	media_id = l_media_rec.media_id
    AND     object_version_number = l_media_rec.object_version_number ;

	IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	UPDATE ams_media_tl
   SET
      last_update_date 	= SYSDATE,
		last_updated_by 	= FND_GLOBAL.User_Id,
		last_update_login = FND_GLOBAL.Conc_Login_Id,

    	source_lang    	= USERENV('LANG'),
		media_name   		= l_media_rec.media_name,
    	description 		= l_media_rec.description
  	WHERE media_id = l_media_rec.media_id
  	AND   USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   -------------------- finish --------------------------
   IF FND_API.to_boolean (p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message (l_full_name || ': End');

   END IF;

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Update_Media;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Update_Media;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Media;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Update_Media;


--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Media
--------------------------------------------------------------------
PROCEDURE Delete_Media (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_media_id          IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Delete_Media';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

   -- added by abhola

   -- Following code is modidifed by rrajesh on 09/20/01
   -- bug fix. 2005131
   -- media should be attached at the schedule level instead of campaigns

   /*CURSOR c_check_campaign(l_media_id in NUMBER) IS
		SELECT 'Y'
		  FROM ams_campaigns_all_b
		 WHERE media_id = l_media_id;*/
   CURSOR c_check_campaign(l_media_id in NUMBER) IS
		SELECT 'Y'
		  FROM ams_campaign_schedules_b
		 WHERE activity_id = l_media_id;
   -- end bug fix. 2005131

   CURSOR c_check_customsetup(l_media_id IN NUMBER) IS
		SELECT 'Y'
		  FROM ams_custom_setups_b
           WHERE media_id = l_media_id;
   -- end abhola

   l_is_campaign VARCHAR2(1);
   l_is_setup    VARCHAR2(1);

BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Delete_Media;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message (l_full_name || ': Start');

   END IF;

   IF FND_API.to_boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call (
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ delete ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': Delete');
   END IF;

   --
   -- Check if record is seeded.
   IF IsSeeded (p_media_id) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_SEED_DATA');
         FND_MSG_PUB.add;
      END IF;

      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- added by ABHOLA

   OPEN c_check_campaign(p_media_id);
   OPEN c_check_customsetup(p_media_id);

   FETCH c_check_campaign INTO l_is_campaign;
   FETCH c_check_customsetup INTO l_is_setup;

   CLOSE c_check_campaign;
   CLOSE c_check_customsetup;

   IF ( l_is_campaign = 'Y' ) OR ( l_is_setup = 'Y') THEN
	 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
	  THEN
		 FND_MESSAGE.set_name('AMS', 'AMS_MEDIA_IS_USED');
		 FND_MSG_PUB.add;
	 END IF;

     RAISE FND_API.G_EXC_ERROR;

  END IF;

   -- end abhola

   -- Delete TL data
   DELETE FROM ams_media_tl
   WHERE  media_id = p_media_id ;


   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   DELETE FROM ams_media_b
   WHERE  media_id = p_media_id
   AND    object_version_number = p_object_version;

   -------------------- finish --------------------------
   IF FND_API.to_boolean (p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message (l_full_name || ': End');

   END IF;

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Delete_Media;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Delete_Media;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Media;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Delete_Media;


--------------------------------------------------------------------
-- PROCEDURE
--    Lock_Media
--
--------------------------------------------------------------------
PROCEDURE Lock_Media (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_media_id          IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS
   l_api_version  CONSTANT NUMBER       := 1.0;
   l_api_name     CONSTANT VARCHAR2(30) := 'Lock_Media';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

   l_dummy        NUMBER;     -- Used by the lock cursor.

   --
   -- NOTE: Not necessary to distinguish between a record
   -- which does not exist and one which has been updated
   -- by another user.  To get that distinction, remove
   -- the object_version condition from the SQL statement
   -- and perform comparison in the body and raise the
   -- exception there.
   CURSOR c_lock IS
      SELECT object_version_number
      FROM   ams_media_b
      WHERE  media_id = p_media_id
      AND    object_version_number = p_object_version
      FOR UPDATE NOWAIT;
BEGIN
   --------------------- initialize -----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': Start');
   END IF;

   IF FND_API.to_boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call (
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ lock -------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': Lock');
   END IF;

   OPEN c_lock;
   FETCH c_lock INTO l_dummy;
   IF (c_lock%NOTFOUND) THEN
      CLOSE c_lock;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_lock;

   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message (l_full_name || ': End');

   END IF;

EXCEPTION
   WHEN AMS_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
		IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
		   FND_MESSAGE.set_name ('AMS', 'AMS_API_RESOURCE_LOCKED');
		   FND_MSG_PUB.add;
		END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
	WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Lock_Media;


--------------------------------------------------------------------
-- PROCEDURE
--    Validate_Media
--
--------------------------------------------------------------------
PROCEDURE Validate_Media (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_media_rec         IN  Media_Rec_Type
)
IS
   L_API_VERSION CONSTANT NUMBER := 1.0;
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Validate_Media';
   L_FULL_NAME   CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

   l_return_status   VARCHAR2(1);
BEGIN
   --------------------- initialize -----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': Start');
   END IF;

   IF FND_API.to_boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call (
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ---------------------- validate ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': Check items');
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Check_Media_Items (
         p_media_rec          => p_media_rec,
         p_validation_mode    => JTF_PLSQL_API.g_create,
         x_return_status      => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message (l_full_name || ': Check record');

   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Check_Media_Record (
         p_media_rec       => p_media_rec,
         p_complete_rec    => NULL,
         x_return_status   => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message (l_full_name || ': End');

   END IF;

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Validate_Media;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Media_Items
--
---------------------------------------------------------------------
PROCEDURE Check_Media_Items (
   p_media_rec       IN  Media_Rec_Type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN
   --
   -- Validate required items.
   Check_Media_Req_Items (
      p_media_rec       => p_media_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   --
   -- Validate uniqueness.
   Check_Media_UK_Items (
      p_media_rec          => p_media_rec,
      p_validation_mode    => p_validation_mode,
      x_return_status      => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_Media_FK_Items(
      p_media_rec       => p_media_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_Media_Lookup_Items (
      p_media_rec          => p_media_rec,
      x_return_status      => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
/*
   Check_Media_Flag_Items(
      p_media_rec       => p_media_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
*/
END Check_Media_Items;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Media_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_media_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_Media_Record (
   p_media_rec        IN  Media_Rec_Type,
   p_complete_rec     IN  Media_Rec_Type := NULL,
   x_return_status    OUT NOCOPY VARCHAR2
)
IS
BEGIN
   --
   -- Currently, no business rule for record
   -- level validation.
   x_return_status := FND_API.g_ret_sts_success;
END Check_Media_Record;

---------------------------------------------------------------------
-- PROCEDURE
--    Init_Media_Rec
--
---------------------------------------------------------------------
PROCEDURE Init_Media_Rec (
   x_media_rec         OUT NOCOPY  Media_Rec_Type
)
IS
BEGIN
   x_media_rec.media_id := FND_API.g_miss_num;
   x_media_rec.last_update_date := FND_API.g_miss_date;
   x_media_rec.last_updated_by := FND_API.g_miss_num;
   x_media_rec.creation_date := FND_API.g_miss_date;
   x_media_rec.created_by := FND_API.g_miss_num;
   x_media_rec.last_update_login := FND_API.g_miss_num;
   x_media_rec.object_version_number := FND_API.g_miss_num;
   x_media_rec.media_type_code := FND_API.g_miss_char;
   x_media_rec.inbound_flag := FND_API.g_miss_char;
   x_media_rec.enabled_flag := FND_API.g_miss_char;
   x_media_rec.attribute_category := FND_API.g_miss_char;
   x_media_rec.attribute1 := FND_API.g_miss_char;
   x_media_rec.attribute2 := FND_API.g_miss_char;
   x_media_rec.attribute3 := FND_API.g_miss_char;
   x_media_rec.attribute4 := FND_API.g_miss_char;
   x_media_rec.attribute5 := FND_API.g_miss_char;
   x_media_rec.attribute6 := FND_API.g_miss_char;
   x_media_rec.attribute7 := FND_API.g_miss_char;
   x_media_rec.attribute8 := FND_API.g_miss_char;
   x_media_rec.attribute9 := FND_API.g_miss_char;
   x_media_rec.attribute10 := FND_API.g_miss_char;
   x_media_rec.attribute11 := FND_API.g_miss_char;
   x_media_rec.attribute12 := FND_API.g_miss_char;
   x_media_rec.attribute13 := FND_API.g_miss_char;
   x_media_rec.attribute14 := FND_API.g_miss_char;
   x_media_rec.attribute15 := FND_API.g_miss_char;
   x_media_rec.media_name := FND_API.g_miss_char;
   x_media_rec.description := FND_API.g_miss_char;
END Init_Media_Rec;


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Media_Rec
--
---------------------------------------------------------------------
PROCEDURE Complete_Media_Rec (
   p_media_rec      IN  Media_Rec_Type,
   x_complete_rec   OUT NOCOPY Media_Rec_Type
)
IS
   CURSOR c_media IS
      SELECT   *
      FROM     ams_media_vl
      WHERE    media_id = p_media_rec.media_id;
   --
   -- This is the only exception for using %ROWTYPE.
   -- We are selecting from the VL view, which may
   -- have some denormalized columns as compared to
   -- the base tables.
   l_media_rec    c_media%ROWTYPE;
BEGIN
   x_complete_rec := p_media_rec;

   OPEN c_media;
   FETCH c_media INTO l_media_rec;
   IF c_media%NOTFOUND THEN
      CLOSE c_media;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_media;

   --
   -- MEDIA_TYPE_CODE
   IF p_media_rec.media_type_code = FND_API.g_miss_char THEN
      x_complete_rec.media_type_code := l_media_rec.media_type_code;
   END IF;

   --
   -- INBOUND_FLAG
   IF p_media_rec.inbound_flag = FND_API.g_miss_char THEN
      x_complete_rec.inbound_flag := l_media_rec.inbound_flag;
   END IF;

   --
   -- ENABLED_FLAG
   IF p_media_rec.enabled_flag = FND_API.g_miss_char THEN
      x_complete_rec.enabled_flag := l_media_rec.enabled_flag;
   END IF;

   --
   -- ATTRIBUTE_CATEGORY
   IF p_media_rec.attribute_category = FND_API.g_miss_char THEN
      x_complete_rec.attribute_category := l_media_rec.attribute_category;
   END IF;

   --
   -- ATTRIBUTE1
   IF p_media_rec.attribute1 = FND_API.g_miss_char THEN
      x_complete_rec.attribute1 := l_media_rec.attribute1;
   END IF;

   --
   -- ATTRIBUTE2
   IF p_media_rec.attribute2 = FND_API.g_miss_char THEN
      x_complete_rec.attribute2 := l_media_rec.attribute2;
   END IF;

   --
   -- ATTRIBUTE3
   IF p_media_rec.attribute3 = FND_API.g_miss_char THEN
      x_complete_rec.attribute3 := l_media_rec.attribute3;
   END IF;

   --
   -- ATTRIBUTE4
   IF p_media_rec.attribute4 = FND_API.g_miss_char THEN
      x_complete_rec.attribute4 := l_media_rec.attribute4;
   END IF;

   --
   -- ATTRIBUTE5
   IF p_media_rec.attribute5 = FND_API.g_miss_char THEN
      x_complete_rec.attribute5 := l_media_rec.attribute5;
   END IF;

   --
   -- ATTRIBUTE6
   IF p_media_rec.attribute6 = FND_API.g_miss_char THEN
      x_complete_rec.attribute6 := l_media_rec.attribute6;
   END IF;

   --
   -- ATTRIBUTE7
   IF p_media_rec.attribute7 = FND_API.g_miss_char THEN
      x_complete_rec.attribute7 := l_media_rec.attribute7;
   END IF;

   --
   -- ATTRIBUTE8
   IF p_media_rec.attribute8 = FND_API.g_miss_char THEN
      x_complete_rec.attribute8 := l_media_rec.attribute8;
   END IF;

   --
   -- ATTRIBUTE9
   IF p_media_rec.attribute9 = FND_API.g_miss_char THEN
      x_complete_rec.attribute9 := l_media_rec.attribute9;
   END IF;

   --
   -- ATTRIBUTE10
   IF p_media_rec.attribute10 = FND_API.g_miss_char THEN
      x_complete_rec.attribute10 := l_media_rec.attribute10;
   END IF;

   --
   -- ATTRIBUTE11
   IF p_media_rec.attribute11 = FND_API.g_miss_char THEN
      x_complete_rec.attribute11 := l_media_rec.attribute11;
   END IF;

   --
   -- ATTRIBUTE12
   IF p_media_rec.attribute12 = FND_API.g_miss_char THEN
      x_complete_rec.attribute12 := l_media_rec.attribute12;
   END IF;

   --
   -- ATTRIBUTE13
   IF p_media_rec.attribute13 = FND_API.g_miss_char THEN
      x_complete_rec.attribute13 := l_media_rec.attribute13;
   END IF;

   --
   -- ATTRIBUTE14
   IF p_media_rec.attribute14 = FND_API.g_miss_char THEN
      x_complete_rec.attribute14 := l_media_rec.attribute14;
   END IF;

   --
   -- ATTRIBUTE15
   IF p_media_rec.attribute15 = FND_API.g_miss_char THEN
      x_complete_rec.attribute15 := l_media_rec.attribute15;
   END IF;

   --
   -- MEDIA_NAME
   IF p_media_rec.media_name = FND_API.g_miss_char THEN
      x_complete_rec.media_name := l_media_rec.media_name;
   END IF;

   --
   -- DESCRIPTION
   IF p_media_rec.description = FND_API.g_miss_char THEN
      x_complete_rec.description := l_media_rec.description;
   END IF;
END Complete_Media_Rec;


--       Check_Media_Req_Items
PROCEDURE Check_Media_Req_Items (
   p_media_rec       IN    Media_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
BEGIN
   -- MEDIA_TYPE_CODE
   IF p_media_rec.media_type_code IS NULL THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_MED_NO_MEDIA_TYPE_CODE');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   -- MEDIA_NAME
   IF p_media_rec.media_name IS NULL THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_MED_NO_MEDIA_NAME');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

END Check_Media_Req_Items;

--       Check_Media_UK_Items
PROCEDURE Check_Media_UK_Items (
   p_media_rec       IN    Media_Rec_Type,
   p_validation_mode IN    VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
   l_valid_flag   VARCHAR2(1);
   -- rrajesh 11/07/00 start
   l_count        NUMBER ;

   CURSOR c_name_unique_cr (p_media_name IN VARCHAR2) IS
	SELECT COUNT(1)
	FROM ams_media_vl
	WHERE UPPER(media_name) = UPPER(p_media_name) ;

   CURSOR c_name_unique_up (p_media_name IN VARCHAR2, p_media_id IN NUMBER) IS
	SELECT COUNT(1)
	FROM ams_media_vl
	WHERE UPPER(media_name) = UPPER(p_media_name)
	AND media_id <> p_media_id ;
   -- end 11/07

BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   --IF (AMS_DEBUG_HIGH_ON) THENAMS_Utility_PVT.debug_message('Check the uniqueness');END IF;

   -- MEDIA_ID
   -- For Create_Media, when ID is passed in, we need to
   -- check if this ID is unique.
   IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_media_rec.media_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_uniqueness(
		      'ams_media_b',
				'media_id = ' || p_media_rec.media_id
			) = FND_API.g_false
		THEN
         IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name ('AMS', 'AMS_MED_DUP_MEDIA_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- MEDIA_NAME
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

-- rrajesh start 11/07. Replaced the AMS_Utility_PVT call
-- with the new cursor.
       OPEN c_name_unique_cr(p_media_rec.media_name) ;
       FETCH c_name_unique_cr INTO l_count ;
       CLOSE c_name_unique_cr ;

--      l_valid_flag := AMS_Utility_PVT.check_uniqueness (
--         'ams_media_vl',
--         'media_name = ''' || p_media_rec.media_name || ''''
--      );
   ELSE
--      l_valid_flag := AMS_Utility_PVT.check_uniqueness (
--         'ams_media_vl',
--         'media_name = ''' || p_media_rec.media_name ||
--            ''' AND media_id <> ' || p_media_rec.media_id
--      );
       OPEN c_name_unique_up(p_media_rec.media_name,p_media_rec.media_id) ;
       FETCH c_name_unique_up INTO l_count ;
       CLOSE c_name_unique_up ;
-- rrajesh end 11/07

   END IF;
   -- IF (AMS_DEBUG_HIGH_ON) THEN  AMS_Utility_PVT.debug_message('Check the uniqueness Cpount '|| l_count ); END IF;
   -- rrajesh start 11/07. Checking the uniqueness against the new cursor,
   -- c_name_unique_up
   IF l_count > 0 THEN
   -- rrajesh end 11/07
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_MED_DUP_NAME');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

END Check_Media_UK_Items;

--       Check_Media_FK_Items
PROCEDURE Check_Media_FK_Items (
   p_media_rec       IN    Media_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
--
-- choang - 19-Nov-1999
-- No foreign key validation required.  Only
-- FK is between B and TL tables.
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
END Check_Media_FK_Items;

--       Check_Media_Lookup_Items
PROCEDURE Check_Media_Lookup_Items (
   p_media_rec       IN    Media_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
   L_MEDIA_TYPE_CODE    CONSTANT VARCHAR2(30) := 'AMS_MEDIA_TYPE';
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   --
   -- MEDIA_TYPE_CODE
   IF p_media_rec.media_type_code <> FND_API.g_miss_char THEN
      IF AMS_Utility_PVT.check_lookup_exists (
            p_lookup_type => L_MEDIA_TYPE_CODE,
            p_lookup_code => p_media_rec.media_type_code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name ('AMS', 'AMS_MED_BAD_MEDIA_TYPE_CODE');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
END Check_Media_Lookup_Items;

-- This procedure is commented out by JULOU 12/06/2000
-- These flags will be defaulted to "Y".
-- The validation is not required.
--       Check_Media_Flag_Items
/*
PROCEDURE Check_Media_Flag_Items (
   p_media_rec       IN    Media_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- INBOUND_FLAG
   IF p_media_rec.inbound_flag <> FND_API.g_miss_char AND p_media_rec.inbound_flag IS NOT NULL THEN
      IF AMS_Utility_PVT.is_Y_or_N (p_media_rec.inbound_flag) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name ('AMS', 'AMS_MED_BAD_INBOUND_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- ENABLED_FLAG
   IF p_media_rec.enabled_flag <> FND_API.g_miss_char AND p_media_rec.enabled_flag IS NOT NULL THEN
      IF AMS_Utility_PVT.is_Y_or_N (p_media_rec.enabled_flag) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name ('AMS', 'AMS_MED_BAD_ENABLED_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END Check_Media_Flag_Items;
*/

-------------------------------------
-------     MEDIA CHANNEL      ------
-------------------------------------
---------------------------------------------------------------------
-- PROCEDURE
--    Create_MediaChannel
---------------------------------------------------------------------
PROCEDURE Create_MediaChannel (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_mediachl_rec      IN  MediaChannel_Rec_Type,
   x_mediachl_id       OUT NOCOPY NUMBER
)
IS
   L_API_VERSION        CONSTANT NUMBER := 1.0;
   L_API_NAME           CONSTANT VARCHAR2(30) := 'Create_MediaChannel';
   L_FULL_NAME          CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

-- Following Line is Commented by ptendulk as l_mediachl_rec
-- should be initialized with the input record type
--   l_mediachl_rec       MediaChannel_Rec_Type;

   l_mediachl_rec       MediaChannel_Rec_Type := p_mediachl_rec;
   l_dummy              NUMBER;
   l_return_status      VARCHAR2(1);

   CURSOR c_seq IS
      SELECT ams_media_channels_s.NEXTVAL
      FROM   dual;

   CURSOR c_id_exists (x_id IN NUMBER) IS
      SELECT 1
      FROM   dual
      WHERE EXISTS (SELECT 1
                    FROM   ams_media_channels
                    WHERE  media_channel_id = x_id);

BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Create_MediaChannel;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message (l_full_name || ': Start');

   END IF;

   IF FND_API.to_boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call (
         L_API_VERSION,
         p_api_version,
         L_API_NAME,
         G_PKG_NAME
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- validate -----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': Validate');
   END IF;

   Validate_MediaChannel (
      p_api_version        => l_api_version,
      p_init_msg_list      => p_init_msg_list,
      p_validation_level   => p_validation_level,
      x_return_status      => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_mediachl_rec       => l_mediachl_rec
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   --
   -- Check for the ID.
   --
   IF l_mediachl_rec.media_channel_id IS NULL THEN
      LOOP
         --
         -- If the ID is not passed into the API, then
         -- grab a value from the sequence.
         OPEN c_seq;
         FETCH c_seq INTO l_mediachl_rec.media_channel_id;
         CLOSE c_seq;

         --
         -- Check to be sure that the sequence does not exist.
         OPEN c_id_exists (l_mediachl_rec.media_channel_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;

         --
         -- If the value for the ID already exists, then
         -- l_dummy would be populated with '1', otherwise,
         -- it receives NULL.
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   END IF;

   -------------------------- insert --------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': insert');
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': '||l_mediachl_rec.media_channel_id);
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': '||l_mediachl_rec.media_id);
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': '||l_mediachl_rec.channel_id);
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': '||l_mediachl_rec.active_from_date);
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': '||l_mediachl_rec.active_to_date);
   END IF;

   INSERT INTO ams_media_channels (
      media_channel_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      object_version_number,
      media_id,
      channel_id,
      active_from_date,
      active_to_date
   )
   VALUES (
      l_mediachl_rec.media_channel_id,
      SYSDATE,             -- last_update_date
      FND_GLOBAL.user_id,  -- last_updated_by
      SYSDATE,             -- creation_date
      FND_GLOBAL.user_id,  -- created_by
      FND_GLOBAl.conc_login_id,  -- last_update_login
      1,                   -- object_version_number
      l_mediachl_rec.media_id,
      l_mediachl_rec.channel_id,
      l_mediachl_rec.active_from_date,
      l_mediachl_rec.active_to_date
   );

   ------------------------- finish -------------------------------
	-- set OUT value
	x_mediachl_id := l_mediachl_rec.media_channel_id;

        --
        -- END of API body.
        --

        -- Standard check of p_commit.
   IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END IF;

   FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message (l_full_name || ': End');

   END IF;

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Create_MediaChannel;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Create_MediaChannel;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Create_MediaChannel;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Create_MediaChannel;


---------------------------------------------------------------------
-- PROCEDURE
--    Update_MediaChannel
---------------------------------------------------------------------
PROCEDURE Update_MediaChannel (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_mediachl_rec      IN  MediaChannel_Rec_Type
)
IS
   L_API_VERSION        CONSTANT NUMBER := 1.0;
   L_API_NAME           CONSTANT VARCHAR2(30) := 'Update_MediaChannel';
   L_FULL_NAME          CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

   l_mediachl_rec       MediaChannel_Rec_Type;
   l_dummy              NUMBER;
   l_return_status      VARCHAR2(1);

BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Update_MediaChannel;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message (l_full_name || ': Start');

   END IF;

   IF FND_API.to_boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- validate ----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': Validate');
   END IF;

   -- replace g_miss_char/num/date with current column values
   Complete_MediaChannel_Rec (p_mediachl_rec, l_mediachl_rec);

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Check_MediaChannel_Items (
         p_mediachl_rec       => l_mediachl_rec, -- change from p_mediachl_rec vmodur
         p_validation_mode    => JTF_PLSQL_API.g_update,
         x_return_status      => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Check_MediaChannel_Record (
         p_mediachl_rec    => l_mediachl_rec, -- change from p_mediachl_rec vmodur
         p_complete_rec    => l_mediachl_rec,
         x_return_status   => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

-- Following lines are commented by ptendulk on 16dec1999
-- as we are not validating Interentity
--   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_inter_entity THEN
--      Check_MediaChannel_InterEntity (
--         p_mediachl_rec    => p_mediachl_rec,
--         p_complete_rec    => l_mediachl_rec,
--         x_return_status   => l_return_status
--      );
--
--      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
--         RAISE FND_API.g_exc_unexpected_error;
--      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
--         RAISE FND_API.g_exc_error;
--      END IF;
--   END IF;

   -------------------------- update --------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': update');
   END IF;

-- Modified by ptendulk on 30Dec1999
-- Check Obj Version Number before Updating
   UPDATE ams_media_channels
   SET
      last_update_date        = SYSDATE,
      last_updated_by         = FND_GLOBAL.user_id,
      last_update_login       = FND_GLOBAL.conc_login_id,
      object_version_number   = object_version_number + 1,
      media_id                = l_mediachl_rec.media_id,
      channel_id              = l_mediachl_rec.channel_id,
      active_from_date        = l_mediachl_rec.active_from_date,
      active_to_date          = l_mediachl_rec.active_to_date
   WHERE media_channel_id = l_mediachl_rec.media_channel_id
    AND     object_version_number = l_mediachl_rec.object_version_number ;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   -------------------- finish --------------------------
   IF FND_API.to_boolean (p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message (l_full_name || ': End');

   END IF;

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Update_MediaChannel;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Update_MediaChannel;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Update_MediaChannel;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Update_MediaChannel;


---------------------------------------------------------------------
-- PROCEDURE
--    Delete_MediaChannel
-- HISTORY
--    11-JUL-2000  holiu  Cannot delete if used by campaigns.
---------------------------------------------------------------------
PROCEDURE Delete_MediaChannel (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_mediachl_id       IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Delete_MediaChannel';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
   l_in_use      NUMBER;

   CURSOR c_in_use IS
   SELECT 1
   FROM   DUAL
   WHERE  EXISTS(
          SELECT A.campaign_id
          FROM   ams_campaigns_all_b A, ams_media_channels B -- Perf fix use all_b
          WHERE  A.active_flag = 'Y'
          AND    A.arc_channel_from = 'CHLS'
          AND    A.media_id = B.media_id
          AND    A.channel_id = B.channel_id
          ANd    B.media_channel_id = p_mediachl_id);

   --  Bug fix:2089112. Added by rrajesh on 10/31/01
   CURSOR c_check_schedule_association IS
       SELECT marketing_medium_id
       FROM ams_campaign_schedules_b a, ams_media_channels b
       WHERE a.marketing_medium_id = b.channel_id
     -- Added by dbiswas 12/31/02 to allow removal of medium from activity
       AND a.activity_id = b.media_id
     -- end change  12/31/02
       AND b.media_channel_id = p_mediachl_id;
   l_mktg_medium_id NUMBER;
   -- End change 10/31/01
BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Delete_MediaChannel;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message (l_full_name || ': Start');

   END IF;

   IF FND_API.to_boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call (
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   -- holiu: add the following checking for bug 1350477
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': check before delete');
   END IF;

   OPEN c_in_use;
   FETCH c_in_use INTO l_in_use;
   CLOSE c_in_use;

   IF l_in_use IS NOT NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
		THEN
         FND_MESSAGE.set_name('AMS', 'AMS_MED_CANNOT_DELETE_CHAN');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   --  Bug fix:2089112. Added by rrajesh on 10/31/01
   OPEN c_check_schedule_association;
   FETCH c_check_schedule_association INTO l_mktg_medium_id;
   CLOSE c_check_schedule_association;

   IF l_mktg_medium_id IS NOT NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
		THEN
         FND_MESSAGE.set_name('AMS', 'AMS_MKTG_MEDIA_ACT_IN_USE');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   --  Bug fix:2089112. 10/31/01

   ------------------------ delete ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': Delete');
   END IF;

   DELETE FROM ams_media_channels
   WHERE  media_channel_id = p_mediachl_id;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   -------------------- finish --------------------------
   IF FND_API.to_boolean (p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message (l_full_name || ': End');

   END IF;

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Delete_MediaChannel;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Delete_MediaChannel;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_MediaChannel;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Delete_MediaChannel;


---------------------------------------------------------------------
-- PROCEDURE
--    Lock_MediaChannel
---------------------------------------------------------------------
PROCEDURE Lock_MediaChannel (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_mediachl_id       IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS
   l_api_version  CONSTANT NUMBER       := 1.0;
   l_api_name     CONSTANT VARCHAR2(30) := 'Lock_MediaChannel';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

   l_dummy        NUMBER;     -- Used by the lock cursor.

   --
   -- NOTE: Not necessary to distinguish between a record
   -- which does not exist and one which has been updated
   -- by another user.  To get that distinction, remove
   -- the object_version condition from the SQL statement
   -- and perform comparison in the body and raise the
   -- exception there.
   CURSOR c_lock IS
      SELECT object_version_number
      FROM   ams_media_channels
      WHERE  media_channel_id = p_mediachl_id
      AND    object_version_number = p_object_version
      FOR UPDATE NOWAIT;
BEGIN
   --------------------- initialize -----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': Start');
   END IF;

   IF FND_API.to_boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call (
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ lock -------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': Lock');
   END IF;

   OPEN c_lock;
   FETCH c_lock INTO l_dummy;
   IF (c_lock%NOTFOUND) THEN
      CLOSE c_lock;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_lock;

   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message (l_full_name || ': End');

   END IF;

EXCEPTION
   WHEN AMS_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
		IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
		   FND_MESSAGE.set_name ('AMS', 'AMS_API_RESOURCE_LOCKED');
		   FND_MSG_PUB.add;
		END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
	WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Lock_MediaChannel;


---------------------------------------------------------------------
-- PROCEDURE
--    Validate_MediaChannel
---------------------------------------------------------------------
PROCEDURE Validate_MediaChannel (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_mediachl_rec      IN  MediaChannel_Rec_Type
)
IS
   L_API_VERSION CONSTANT NUMBER := 1.0;
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Validate_MediaChannel';
   L_FULL_NAME   CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

   l_return_status   VARCHAR2(1);
BEGIN
   --------------------- initialize -----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': Start');
   END IF;

   IF FND_API.to_boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call (
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ---------------------- validate ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': Check items');
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Check_MediaChannel_Items (
         p_mediachl_rec       => p_mediachl_rec,
         p_validation_mode    => JTF_PLSQL_API.g_create,
         x_return_status      => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message (l_full_name || ': Check record');

   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Check_MediaChannel_Record (
         p_mediachl_rec    => p_mediachl_rec,
         p_complete_rec    => NULL,
         x_return_status   => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message (l_full_name || ': End');

   END IF;

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Validate_MediaChannel;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_MediaChannel_Items
---------------------------------------------------------------------
PROCEDURE Check_MediaChannel_Items (
   p_mediachl_rec    IN  MediaChannel_Rec_Type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN
   --
   -- Validate required items.
   Check_MediaChannel_Req_Items (
      p_mediachl_rec    => p_mediachl_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   --
   -- Validate uniqueness.
   Check_MediaChannel_UK_Items (
      p_mediachl_rec       => p_mediachl_rec,
      p_validation_mode    => p_validation_mode,
      x_return_status      => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_MediaChannel_FK_Items(
      p_mediachl_rec    => p_mediachl_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_MediaChl_Lookup_Items (
      p_mediachl_rec       => p_mediachl_rec,
      x_return_status      => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_MediaChannel_Flag_Items(
      p_mediachl_rec    => p_mediachl_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
END Check_MediaChannel_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_MediaChannel_Record
---------------------------------------------------------------------
PROCEDURE Check_MediaChannel_Record (
   p_mediachl_rec     IN  MediaChannel_Rec_Type,
   p_complete_rec     IN  MediaChannel_Rec_Type := NULL,
   x_return_status    OUT NOCOPY VARCHAR2
)
IS
   l_active_from_date      DATE;
   l_active_to_date        DATE;
   l_channel_id            NUMBER;
   l_chan_from_date        DATE;
   l_chan_to_date          DATE;

   CURSOR c_check_date(p_chan_id IN NUMBER) IS
	    SELECT active_from_date, active_to_date
		 FROM AMS_CHANNELS_VL
       WHERE channel_id = p_chan_id;

BEGIN
   --
   -- Use local vars to reduce amount of typing.
   l_active_from_date := p_mediachl_rec.active_from_date;
   l_active_to_date := p_mediachl_rec.active_to_date;


   l_channel_id := p_mediachl_rec.channel_id;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   -- Validate the active dates.
   --
   IF l_active_from_date <> FND_API.g_miss_date AND l_active_to_date <> FND_API.g_miss_date THEN
      IF l_active_from_date IS NULL THEN
         l_active_from_date := p_complete_rec.active_from_date;
      END IF;

      IF l_active_to_date IS NULL THEN
         l_active_to_date := p_complete_rec.active_to_date;
      END IF;

      IF l_active_from_date > l_active_to_date THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_MED_FROMDT_GTR_TODT');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --
   -- this code added by abhola
   --

   -- Validate that media chaneel dates entered should not be greater
   -- than channel dates
   --
 IF l_active_from_date <> FND_API.g_miss_date OR l_active_to_date <> FND_API.g_miss_date THEN
	 IF l_active_from_date IS NULL THEN
		l_active_from_date := p_complete_rec.active_from_date;
	 END IF;

	IF l_active_to_date IS NULL THEN
		    l_active_to_date := p_complete_rec.active_to_date;
	END IF;

      OPEN  c_check_date(l_channel_id);
	 FETCH c_check_date INTO l_chan_from_date, l_chan_to_date;
      CLOSE c_check_date;

	 IF ((l_chan_from_date IS NOT NULL) AND (l_chan_to_date IS NOT NULL))

	    THEN

		IF (   (l_active_from_date < l_chan_from_date)
		    OR  (l_active_from_date > l_chan_to_date )
		    )
          THEN

                FND_MESSAGE.set_name ('AMS', 'AMS_MEDCHAN_FROMDT_GTR');
			 FND_MSG_PUB.add;
			 x_return_status := FND_API.g_ret_sts_error;
			RETURN;

		END IF;


		IF (
		        (l_active_to_date  > l_chan_to_date  )
		    OR  (l_active_to_date  < l_chan_from_date)
		    )
          THEN

                FND_MESSAGE.set_name ('AMS', 'AMS_MEDCHAN_TODT_GTR');
			 FND_MSG_PUB.add;
			 x_return_status := FND_API.g_ret_sts_error;
			RETURN;

		END IF;
       END IF;
     END IF;

     -- vmodur added
     IF (l_chan_from_date IS NOT NULL AND l_chan_to_date IS NULL) THEN

         IF l_active_from_date < l_chan_from_date THEN

                FND_MESSAGE.set_name ('AMS', 'AMS_MEDCHAN_FROMDT_GTR');
	        FND_MSG_PUB.add;
		x_return_status := FND_API.g_ret_sts_error;
		RETURN;

	END IF;

    END IF;

END Check_MediaChannel_Record;


---------------------------------------------------------------------
-- PROCEDURE
--    Init_MediaChannel_Rec
---------------------------------------------------------------------
PROCEDURE Init_MediaChannel_Rec (
   x_mediachl_rec         OUT NOCOPY  MediaChannel_Rec_Type
)
IS
BEGIN
   x_mediachl_rec.media_channel_id := FND_API.g_miss_num;
   x_mediachl_rec.last_update_date := FND_API.g_miss_date;
   x_mediachl_rec.last_updated_by := FND_API.g_miss_num;
   x_mediachl_rec.creation_date := FND_API.g_miss_date;
   x_mediachl_rec.created_by := FND_API.g_miss_num;
   x_mediachl_rec.last_update_login := FND_API.g_miss_num;
   x_mediachl_rec.object_version_number := FND_API.g_miss_num;
   x_mediachl_rec.media_id := FND_API.g_miss_num;
   x_mediachl_rec.channel_id := FND_API.g_miss_num;
   x_mediachl_rec.active_from_date := FND_API.g_miss_date;
   x_mediachl_rec.active_to_date := FND_API.g_miss_date;
END Init_MediaChannel_Rec;


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_MediaChannel_Rec
---------------------------------------------------------------------
PROCEDURE Complete_MediaChannel_Rec (
   p_mediachl_rec   IN  MediaChannel_Rec_Type,
   x_complete_rec   OUT NOCOPY MediaChannel_Rec_Type
)
IS
   CURSOR c_mediachl IS
      SELECT *
      FROM   ams_media_channels
      WHERE media_channel_id = p_mediachl_rec.media_channel_id;

   l_mediachl_rec c_mediachl%ROWTYPE;
BEGIN
   x_complete_rec := p_mediachl_rec;

   OPEN c_mediachl;
   FETCH c_mediachl INTO l_mediachl_rec;
   IF c_mediachl%NOTFOUND THEN
      CLOSE c_mediachl;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_mediachl;

   -- MEDIA_ID
   IF p_mediachl_rec.media_id = FND_API.g_miss_num THEN
      x_complete_rec.media_id := l_mediachl_rec.media_id;
   END IF;
   -- CHANNEL_ID
   IF p_mediachl_rec.channel_id = FND_API.g_miss_num THEN
      x_complete_rec.channel_id := l_mediachl_rec.channel_id;
   END IF;
   -- ACTIVE_FROM_DATE
   IF p_mediachl_rec.active_from_date = FND_API.g_miss_date THEN
      x_complete_rec.active_from_date := l_mediachl_rec.active_from_date;
   END IF;
   -- ACTIVE_TO_DATE
   IF p_mediachl_rec.active_to_date = FND_API.g_miss_date THEN
      x_complete_rec.active_to_date := l_mediachl_rec.active_to_date;
   END IF;


END Complete_MediaChannel_Rec;


---------------------------------------------------------------------
-- PROCEDURE
--       Check_MediaChannel_Req_Items
--
---------------------------------------------------------------------
PROCEDURE Check_MediaChannel_Req_Items (
   p_mediachl_rec    IN    MediaChannel_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   --
   -- MEDIA_ID
   IF p_mediachl_rec.media_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_MED_NO_MEDIA_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   --
   -- CHANNEL_ID
   IF p_mediachl_rec.channel_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_MED_NO_CHANNEL_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   --
   -- ACTIVE_FROM_DATE
   IF p_mediachl_rec.active_from_date IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_MED_NO_ACTIVE_FROM_DATE');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

END Check_MediaChannel_Req_Items;


---------------------------------------------------------------------
-- PROCEDURE
--       Check_MediaChannel_UK_Items
--
---------------------------------------------------------------------
PROCEDURE Check_MediaChannel_UK_Items (
   p_mediachl_rec    IN    MediaChannel_Rec_Type,
   p_validation_mode IN    VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
   -- soagrawa 15-jan-2002
   -- added the following two cursors
   CURSOR c_check_uniqueness_create(p_media_id IN NUMBER, p_channel_id IN NUMBER) IS
      SELECT count(*)
      FROM   ams_media_channels
      WHERE  media_id = p_media_id
      AND channel_id = p_channel_id
      AND active_from_date <= sysdate
      AND (active_to_date IS NULL OR active_to_date > SYSDATE) ;

   CURSOR c_check_uniqueness_update(p_media_id IN NUMBER, p_channel_id IN NUMBER, p_media_channel_id IN NUMBER) IS
      SELECT count(*)
      FROM   ams_media_channels
      WHERE  media_id = p_media_id
      AND channel_id = p_channel_id
      AND media_channel_id <> p_media_channel_id
      AND active_from_date <= sysdate
      AND (active_to_date IS NULL OR active_to_date > SYSDATE) ;


   l_valid_flag   VARCHAR2(1);
   l_count        NUMBER;
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message('Check_MediaChannel_UK_Items start');
   END IF;
   -- The combination of media and channel should
   -- be unique.
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message('Check_MediaChannel_UK_Items CREATE');
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message('Check_MediaChannel_UK_Items >'||p_mediachl_rec.media_id);
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message('Check_MediaChannel_UK_Items >'||p_mediachl_rec.channel_id);
      END IF;
      /*
      l_valid_flag := AMS_Utility_PVT.check_uniqueness (
         'ams_media_channels',
         'media_id = ' || p_mediachl_rec.media_id
          || ' AND channel_id = ' || p_mediachl_rec.channel_id
         -- following two where clauses added by soagrawa on 15-jan-2002
         -- to keep it consistent with the query in AmsGetChannel.java checkMedChan()
         || ' AND active_from_date <= SYSDATE '
         || ' AND ( active_to_date is NULL OR active_to_date > SYSDATE)'
      );*/
      -- soagrawa 15-jan-2002
      -- check uniqueness replaced by cursor
      OPEN  c_check_uniqueness_create(p_mediachl_rec.media_id, p_mediachl_rec.channel_id);
      FETCH c_check_uniqueness_create INTO l_count;
      CLOSE c_check_uniqueness_create;

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_Utility_PVT.debug_message('l_count is >'||l_count);

      END IF;
      IF l_count = 0
      THEN
        l_valid_flag := FND_API.g_true;
      ELSE
        l_valid_flag := FND_API.g_false;
      END IF;

   ELSE
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message('Check_MediaChannel_UK_Items UPDATE');
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message('Check_MediaChannel_UK_Items >'||p_mediachl_rec.media_id);
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message('Check_MediaChannel_UK_Items >'||p_mediachl_rec.channel_id);
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message('Check_MediaChannel_UK_Items >'||p_mediachl_rec.media_channel_id);
      END IF;
      --
      -- For UPDATE operations, make sure the
      -- uniqueness check excludes the current
      -- record.
      /*
      l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'ams_media_channels',
         'media_id = ' || p_mediachl_rec.media_id
         || ' AND channel_id = ' || p_mediachl_rec.channel_id
         || ' AND media_channel_id <> ' || p_mediachl_rec.media_channel_id
         -- following two where clauses added by soagrawa on 15-jan-2002
         -- to keep it consistent with the query in AmsGetChannel.java checkMedChan()
         || ' AND active_from_date <= SYSDATE '
         || ' AND ( active_to_date is NULL OR active_to_date > SYSDATE)'
      );
      */
      -- soagrawa 15-jan-2002
      -- check uniqueness replaced by cursor
      OPEN  c_check_uniqueness_update(p_mediachl_rec.media_id,p_mediachl_rec.channel_id,p_mediachl_rec.media_channel_id);
      FETCH c_check_uniqueness_update INTO l_count;
      CLOSE c_check_uniqueness_update;

      IF l_count = 0
      THEN
        l_valid_flag := FND_API.g_true;
      ELSE
        l_valid_flag := FND_API.g_false;
      END IF;

   END IF;
   IF l_valid_flag = FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_MED_DUP_MEDIA_CHANNEL');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
END Check_MediaChannel_UK_Items;


---------------------------------------------------------------------
-- PROCEDURE
--       Check_MediaChannel_FK_Items
--
---------------------------------------------------------------------
PROCEDURE Check_MediaChannel_FK_Items (
   p_mediachl_rec    IN    MediaChannel_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   --
   -- MEDIA_ID
   IF p_mediachl_rec.media_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists (
            'ams_media_b',
            'media_id',
            p_mediachl_rec.media_id
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name ('AMS', 'AMS_MED_BAD_MEDIA_ID');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --
   -- CHANNEL_ID
   IF p_mediachl_rec.channel_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists (
            'ams_channels_b',
            'channel_id',
            p_mediachl_rec.channel_id
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name ('AMS', 'AMS_MED_BAD_CHANNEL_ID');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;



END Check_MediaChannel_FK_Items;


---------------------------------------------------------------------
-- PROCEDURE
--       Check_MediaChl_Lookup_Items
--
---------------------------------------------------------------------
PROCEDURE Check_MediaChl_Lookup_Items (
   p_mediachl_rec    IN    MediaChannel_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
--
-- No AMS_LOOKUPS references as of 04-Nov-1999.
--
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
END Check_MediaChl_Lookup_Items;


---------------------------------------------------------------------
-- PROCEDURE
--       Check_MediaChannel_Flag_Items
--
---------------------------------------------------------------------
PROCEDURE Check_MediaChannel_Flag_Items (
   p_mediachl_rec    IN    MediaChannel_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
--
-- No flags to validate as of 04-Nov-1999.
--
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
END Check_MediaChannel_Flag_Items;


--
-- PROCEDURE
--    Check_MediaChannel_InterEntity
PROCEDURE Check_MediaChannel_InterEntity (
   p_mediachl_rec       IN MediaChannel_Rec_Type,
   p_complete_rec       IN MediaChannel_Rec_Type := NULL,
   x_return_status      OUT NOCOPY VARCHAR2
)
IS
   l_active_from_date         DATE;
   l_active_to_date           DATE;

   CURSOR c_channel IS
      SELECT active_from_date,
             active_to_date
      FROM   ams_channels_b
      WHERE  channel_id = p_mediachl_rec.channel_id
   ;
   l_channel_rec     c_channel%ROWTYPE;
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Initialize media channel dates
   l_active_from_date := p_mediachl_rec.active_from_date;
   l_active_to_date := p_mediachl_rec.active_to_date;

   OPEN c_channel;
   --
   -- Check_MediaChannel_FK_Items should have
   -- already taken care of existence of this
   -- channel, so check not needed.
   FETCH c_channel INTO l_channel_rec;
   CLOSE c_channel;

   --
   -- Channel vs. Media Channel Validation
   -- Validate the active dates.
   -- Note: stack error messages into message buffer
   -- so all error messages returned in one time.
   IF l_active_from_date <> FND_API.g_miss_date OR l_active_to_date <> FND_API.g_miss_date THEN
      IF l_active_from_date IS NULL THEN
         l_active_from_date := p_complete_rec.active_from_date;
      END IF;

      IF l_active_to_date IS NULL THEN
         l_active_to_date := p_complete_rec.active_to_date;
      END IF;

      --
      -- Channel dates should not be NULL if
      -- media channel dates have a value.
/***
   ISSUE: Do we need to check this even though
   from date is NOT NULL on channels table?
***/
      IF l_channel_rec.active_from_date IS NULL AND l_active_from_date IS NOT NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name ('AMS', 'AMS_MED_CFD_IS_NULL');  -- Channel From Date is NULL.
            FND_MSG_PUB.Add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF l_channel_rec.active_to_date IS NULL AND l_active_from_date IS NOT NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name ('AMS', 'AMS_MED_CTD_IS_NULL');  -- Channel To Date is NULL.
            FND_MSG_PUB.Add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      --
      -- media channel's active from date should not
      -- be before channel's active from date.
      IF l_active_from_date < l_channel_rec.active_from_date THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name ('AMS', 'AMS_MED_MFD_LT_CFD');
            FND_MSG_PUB.Add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      --
      -- media channel's active from date should not
      -- be after channel's active to date.
      IF l_active_from_date > l_channel_rec.active_to_date THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name ('AMS', 'AMS_MED_CFD_GT_MTD');
            FND_MSG_PUB.Add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      --
      -- media channel's active to date should not
      -- be after channel's active to date.
      IF l_active_to_date > l_channel_rec.active_to_date THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name ('AMS', 'AMS_MED_CTD_GT_MTD');
            FND_MSG_PUB.Add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
      END IF;

   END IF;

END Check_MediaChannel_InterEntity;


END AMS_Media_PVT;

/
