--------------------------------------------------------
--  DDL for Package Body AMS_USER_STATUSES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_USER_STATUSES_PVT" AS
/* $Header: amsvustb.pls 115.25 2003/12/10 08:04:13 vmodur ship $ */
-----------------------------------------------------------
-- PACKAGE
--    AMS_USER_STATUSES_PVT
--
-- PROCEDURES
--    AMS_USER_STATUSES_VL:
--       Check_User_Status_Req_Items
--       Check_User_Status_UK_Items
--       Check_User_Status_FK_Items
--       Check_User_Status_Lookup_Items
--       Check_User_Status_Flag_Items
--
-- NOTES
--
--
-- HISTORY
-- 10-Nov-1999    rvaka      Created.
-- 17-Jun-2002    sveerave   included application_id while inserting the row,
--                           and corrected check_lookup_exists for lookup_type
-- 25-Jun-2003    vmodur     Added can_disable_status for Bug 3021076
-- 03-Dec-2003    vmodur     Bug 3265043 and OZF Migration
-----------------------------------------------------------
--
-- Global CONSTANTS
G_PKG_NAME           CONSTANT VARCHAR2(30) := 'AMS_User_Statuses_PVT';
--       Check_User_Status_Req_Items
AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Check_User_Status_Req_Items (
   p_user_status_rec    IN    User_Status_Rec_Type,
   x_return_status    OUT NOCOPY   VARCHAR2
);
--       Check_User_Status_UK_Items
PROCEDURE Check_User_Status_UK_Items (
   p_user_status_rec    IN    User_Status_Rec_Type,
   p_validation_mode 	IN    VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status    OUT NOCOPY   VARCHAR2
);
--       Check_User_Status_FK_Items
PROCEDURE Check_User_Status_FK_Items (
   p_user_status_rec    IN    User_Status_Rec_Type,
   x_return_status    OUT NOCOPY   VARCHAR2
);
--       Check_User_Status_Lookup_Items
PROCEDURE Check_User_Status_Lookup_Items (
   p_user_status_rec    IN    User_Status_Rec_Type,
   x_return_status    OUT NOCOPY   VARCHAR2
);
--       Check_User_Status_Flag_Items
PROCEDURE Check_User_Status_Flag_Items (
   p_user_status_rec    IN    User_Status_Rec_Type,
   x_return_status    OUT NOCOPY   VARCHAR2
);
FUNCTION compare_columns(
	l_user_status_rec	IN	  User_Status_Rec_Type
) RETURN VARCHAR2;   -- FND_API.g_true/g_false

FUNCTION seed_needs_update(
	l_user_status_rec	IN	  User_Status_Rec_Type
) RETURN VARCHAR2;   -- FND_API.g_true/g_false

FUNCTION can_disable_status(
	l_user_status_rec	IN	  User_Status_Rec_Type
) RETURN VARCHAR2;   -- FND_API.g_true/g_false
-------------------------------------
-----          USER_STATUS           -----
-------------------------------------
--------------------------------------------------------------------
-- PROCEDURE
--    Create_User_Status
--
--------------------------------------------------------------------
PROCEDURE Create_User_Status (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_user_status_rec   IN    User_Status_Rec_Type,
   x_user_status_id    OUT NOCOPY NUMBER
)
IS
   L_API_VERSION        CONSTANT NUMBER := 1.0;
   L_API_NAME           CONSTANT VARCHAR2(30) := 'Create_User_Status';
   L_FULL_NAME          CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
   l_User_Status_rec    User_Status_Rec_Type := p_user_status_rec;
   l_dummy              NUMBER;
   l_return_status      VARCHAR2(1);
   CURSOR c_seq IS
      SELECT ams_user_statuses_b_s.NEXTVAL
      FROM   dual;
   CURSOR c_id_exists (x_id IN NUMBER) IS
      SELECT 1
      FROM   dual
      WHERE EXISTS (SELECT 1
                    FROM   ams_user_statuses_vl
                    WHERE  user_status_id = x_id);
BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Create_User_Status;
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



   Validate_User_Status (
      p_api_version        => l_api_version,
      p_init_msg_list      => p_init_msg_list,
      p_validation_level   => p_validation_level,
      x_return_status      => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_user_status_rec    => l_user_status_rec
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
   --
   -- Check for the ID.
   --
   IF l_user_status_rec.user_status_id IS NULL THEN
      LOOP
         --
         -- If the ID is not passed into the API, then
         -- grab a value from the sequence.
         OPEN c_seq;
         FETCH c_seq INTO l_user_status_rec.user_status_id;
         CLOSE c_seq;
         --
         -- Check to be sure that the sequence does not exist.
         OPEN c_id_exists (l_user_status_rec.user_status_id);
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
   INSERT INTO ams_user_statuses_b (
	   user_status_id,
	   -- standard who columns
 	   last_update_date,
 	   last_updated_by,
 	   creation_date,
 	   created_by,
	   last_update_login,
           object_version_number,
	   system_status_type,
           system_status_code,
	   enabled_flag,
           default_flag,
	   seeded_flag,
 	   start_date_active,
           end_date_active,
           application_id
	)
	VALUES (
	   l_user_status_rec.user_status_id,
	   -- standard who columns
	   SYSDATE,
	   FND_GLOBAL.User_Id,
	   SYSDATE,
	   FND_GLOBAL.User_Id,
	   FND_GLOBAL.Conc_Login_Id,
           1,    -- object_version_number
	   l_user_status_rec.system_status_type,
           l_user_status_rec.system_status_code,
 	   NVL (l_user_status_rec.enabled_flag, 'Y'),   -- Default is 'Y'
 	   NVL (l_user_status_rec.default_flag, 'N'),   -- Default is 'N'
	   NVL (l_user_status_rec.seeded_flag, 'N'),   -- Default is 'N'
 	   l_user_status_rec.start_date_active,
 	   l_user_status_rec.end_date_active,
           fnd_global.resp_appl_id -- added to capture application_id
	);
	INSERT INTO ams_user_statuses_tl (
 	   user_status_id,
           language,
 	   last_update_date,
 	   last_updated_by,
 	   creation_date,
 	   created_by,
 	   last_update_login,
 	   source_lang,
	   name,
 	   description
   )
   SELECT   l_user_status_rec.user_status_id,
	         l.language_code,
            -- standard who columns
	         SYSDATE,
	         FND_GLOBAL.User_Id,
	         SYSDATE,
	         FND_GLOBAL.User_Id,
	         FND_GLOBAL.Conc_Login_Id,
                 USERENV('LANG'),
	         l_user_status_rec.name,
	         l_user_status_rec.description
  	FROM     fnd_languages l
  	WHERE    l.installed_flag IN ('I', 'B')
  	AND NOT EXISTS (SELECT  NULL
    		          FROM    ams_user_statuses_tl t
    		          WHERE   t.user_status_id = l_user_status_rec.user_status_id
    		          AND     t.language = l.language_code);
   ------------------------- finish -------------------------------
	-- set OUT value
	x_user_status_id := l_user_status_rec.user_status_id;
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
      ROLLBACK TO Create_User_Status;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Create_User_Status;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Create_User_Status;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Create_user_status;
--------------------------------------------------------------------
-- PROCEDURE
--    Update_User_Status
--
--------------------------------------------------------------------
PROCEDURE Update_User_Status (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_user_status_rec   IN  User_Status_Rec_Type
)
IS
   L_API_VERSION        CONSTANT NUMBER := 1.0;
   L_API_NAME           CONSTANT VARCHAR2(30) := 'Update_User_Status';
   L_FULL_NAME          CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
   l_user_status_rec    User_Status_Rec_Type := p_user_status_rec;
   l_dummy              NUMBER;
   l_return_status      VARCHAR2(1);
BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Update_User_Status;
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
   Complete_User_Status_Rec (p_user_status_rec, l_user_status_rec);

 IF l_user_status_rec.seeded_flag = 'Y' THEN
		IF compare_columns(l_user_status_rec) = FND_API.g_false THEN
	  	  IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
			 FND_MESSAGE.set_name ('AMS', 'AMS_STATUS_SEED_DATA');
			 FND_MSG_PUB.add;
		  END IF;
		  RAISE FND_API.g_exc_error;
	    END IF;
  ELSE

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Check_User_Status_Items (
         p_user_status_rec          => p_user_status_rec,
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
      Check_User_Status_Record (
         p_user_status_rec       => p_user_status_rec,
         p_complete_rec    => l_user_status_rec,
         x_return_status   => l_return_status
      );
      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

  END IF; -- check for seeded flag

   IF l_user_status_rec.default_flag = 'Y' THEN
      UPDATE ams_user_statuses_b
      SET
            default_flag = 'N'
      WHERE system_status_type	= l_user_status_rec.system_status_type
        AND system_status_code	= l_user_status_rec.system_status_code;

      -- always enable the default status.
      l_user_status_rec.enabled_flag := 'Y';
   END IF;

  -- Check to see if the row is seeded if the row is seeded then can't update
  -- modified.. enabled flag for seeded rows can be updated.. added seed_needs_update function
   IF l_user_status_rec.seeded_flag='N' OR
		seed_needs_update(l_user_status_rec) = FND_API.g_true THEN
   -------------------------- update --------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': Update');
   END IF;

   -- Check to see if the user status can be disabled
   IF NVL(l_user_status_rec.enabled_flag,'Y') = 'N' THEN
     IF can_disable_status(l_user_status_rec) = FND_API.g_false THEN
        IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name ('AMS', 'AMS_STATUS_CANNOT_DISABLE');
	  FND_MESSAGE.set_token('USER_STATUS', l_user_status_rec.name);
          FND_MSG_PUB.add;
        END IF;
	  RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;

	UPDATE ams_user_statuses_b
	SET
		last_update_date	= SYSDATE,
		last_updated_by 	= FND_GLOBAL.User_Id,
		last_update_login       = FND_GLOBAL.Conc_Login_Id,
		object_version_number   = object_version_number + 1,
	        system_status_type	= l_user_status_rec.system_status_type,
	        system_status_code	= l_user_status_rec.system_status_code,
		enabled_flag 		= NVL (l_user_status_rec.enabled_flag, 'Y'),
		default_flag            = NVL (l_user_status_rec.default_flag, 'N'),
		seeded_flag            = NVL (l_user_status_rec.seeded_flag, 'N'),
		start_date_active       = l_user_status_rec.start_date_active,
		end_date_active       = l_user_status_rec.end_date_active
	WHERE	user_status_id = l_user_status_rec.user_status_id
	        AND object_version_number = l_user_status_rec.object_version_number;
	IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	UPDATE ams_user_statuses_tl
   SET
      last_update_date 	= SYSDATE,
		last_updated_by 	= FND_GLOBAL.User_Id,
		last_update_login = FND_GLOBAL.Conc_Login_Id,
    	source_lang    	= USERENV('LANG'),
		name   		= l_user_status_rec.name,
    	description 		= l_user_status_rec.description
  	WHERE user_status_id = l_user_status_rec.user_status_id
  	AND   USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);
   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
 END IF; -- ending if loop for second seeded_flag check

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
      ROLLBACK TO Update_User_Status;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Update_User_Status;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Update_User_Status;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Update_User_Status;
--------------------------------------------------------------------
-- PROCEDURE
--    Delete_User_Status
--
--------------------------------------------------------------------
PROCEDURE Delete_User_Status (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_user_status_id          IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS
   CURSOR c_user_status IS
      SELECT   *
      FROM     ams_user_statuses_vl
      WHERE    user_status_id = p_user_status_id;
   --
   -- This is the only exception for using %ROWTYPE.
   -- We are selecting from the VL view, which may
   -- have some denormalized columns as compared to
   -- the base tables.
   l_user_status_rec    c_user_status%ROWTYPE;

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Delete_User_Status';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
BEGIN
   OPEN c_user_status;
   FETCH c_user_status INTO l_user_status_rec;
   IF c_user_status%NOTFOUND THEN
      CLOSE c_user_status;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_user_status;
   --------------------- initialize -----------------------
   SAVEPOINT Delete_User_Status;
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
   -- Delete TL data

  IF l_user_status_rec.seeded_flag='N'
   THEN

    DELETE FROM ams_user_statuses_tl
    WHERE  user_status_id = p_user_status_id;
     IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error)
		THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
     END IF;
    DELETE FROM ams_user_statuses_b
    WHERE  user_status_id = p_user_status_id
    AND    object_version_number = p_object_version;

  ELSE
       IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_API_SEED_DATA');
         FND_MSG_PUB.add;
		 RAISE FND_API.g_exc_error;
       END IF;

 END IF; -- ending if loop for seeded_flag check


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
      ROLLBACK TO Delete_User_Status;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Delete_User_Status;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_User_Status;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Delete_User_Status;
--------------------------------------------------------------------
-- PROCEDURE
--    Lock_User_Status
--
--------------------------------------------------------------------
PROCEDURE Lock_User_Status (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_user_status_id          IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS
   l_api_version  CONSTANT NUMBER       := 1.0;
   l_api_name     CONSTANT VARCHAR2(30) := 'Lock_User_Status';
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
      FROM   ams_user_statuses_vl
      WHERE  user_status_id = p_user_status_id
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
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Lock_User_Status;
--------------------------------------------------------------------
-- PROCEDURE
--    Validate_User_Status
--
--------------------------------------------------------------------
PROCEDURE Validate_User_Status (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_user_status_rec         IN  User_Status_Rec_Type
)
IS
   L_API_VERSION CONSTANT NUMBER := 1.0;
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Validate_User_Status';
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
      Check_User_Status_Items (
         p_user_status_rec          => p_user_status_rec,
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
      Check_User_Status_Record (
         p_user_status_rec       => p_user_status_rec,
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
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Validate_User_Status;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_User_Status_Items
--
---------------------------------------------------------------------
PROCEDURE Check_User_Status_Items (
   p_user_status_rec       IN  User_Status_Rec_Type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN
   --
   -- Validate required items.
   Check_User_Status_Req_Items (
      p_user_status_rec       => p_user_status_rec,
      x_return_status   => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   --
   -- Validate uniqueness.
   Check_User_Status_UK_Items (
      p_user_status_rec          => p_user_status_rec,
      p_validation_mode    => p_validation_mode,
      x_return_status      => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   Check_User_Status_FK_Items(
      p_user_status_rec       => p_user_status_rec,
      x_return_status   => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   Check_User_Status_Lookup_Items (
      p_user_status_rec          => p_user_status_rec,
      x_return_status      => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   Check_User_Status_Flag_Items(
      p_user_status_rec       => p_user_status_rec,
      x_return_status   => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
END Check_User_Status_Items;
---------------------------------------------------------------------
-- PROCEDURE
--    Check_User_Status_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_user_status_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_User_Status_Record (
   p_user_status_rec        IN  User_Status_Rec_Type,
   p_complete_rec     IN  User_Status_Rec_Type := NULL,
   x_return_status    OUT NOCOPY VARCHAR2
)
IS
   l_start_date_active      DATE;
   l_end_date_active        DATE;
BEGIN
   --
   -- Use local vars to reduce amount of typing.
   if p_complete_rec.start_date_active IS NOT NULL then
	   l_start_date_active := p_complete_rec.start_date_active;
   else
		if p_user_status_rec.start_date_active is NOT NULL AND
			p_user_status_rec.start_date_active <> FND_API.g_miss_date then
			l_start_date_active := p_user_status_rec.start_date_active;
		end if;
   end if;

	if p_complete_rec.end_date_active IS NOT NULL then
	   l_end_date_active := p_complete_rec.end_date_active;
    else
		if p_user_status_rec.end_date_active is NOT NULL AND
			p_user_status_rec.end_date_active <> FND_API.g_miss_date then
			l_end_date_active := p_user_status_rec.end_date_active;
		end if;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   /*
   -- Validate the active dates.
   IF l_start_date_active <> FND_API.g_miss_date OR l_end_date_active <> FND_API.g_miss_date THEN
      IF (l_start_date_active = FND_API.g_miss_date) THEN
         l_start_date_active := p_complete_rec.start_date_active;
      END IF;

      IF (l_end_date_active IS NULL OR l_end_date_active = FND_API.g_miss_date) THEN
         l_end_date_active := p_complete_rec.end_date_active;
      END IF;
*/
--IF (AMS_DEBUG_HIGH_ON) THENAMS_UTILITY_PVT.DEBUG_MESSAGE('sTART DATE:'|| to_char(l_start_date_active,'DD_MON_YYYY'));END IF;
--IF (AMS_DEBUG_HIGH_ON) THENAMS_UTILITY_PVT.DEBUG_MESSAGE('end DATE:'|| to_char(l_end_date_active,'DD-MON-YYYY'));END IF;

		IF l_start_date_active IS NOT NULL AND l_end_date_active IS NOT NULL THEN
		  IF l_start_date_active > l_end_date_active THEN
			IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
				FND_MESSAGE.set_name ('AMS', 'AMS_STATUS_FROMDT_GTR_TODT');
				FND_MSG_PUB.add;
			 END IF;
			 x_return_status := FND_API.g_ret_sts_error;
			 RETURN;
		  END IF;
		END IF;
 -- END IF;

END Check_User_Status_Record;


---------------------------------------------------------------------
-- PROCEDURE
--    Init_User_Status_Rec
--
---------------------------------------------------------------------
PROCEDURE Init_User_Status_Rec (
   x_user_status_rec         OUT NOCOPY  User_Status_Rec_Type
)
IS
BEGIN
   x_user_status_rec.user_status_id 	:= FND_API.g_miss_num;
   x_user_status_rec.last_update_date 	:= FND_API.g_miss_date;
   x_user_status_rec.last_updated_by 	:= FND_API.g_miss_num;
   x_user_status_rec.creation_date 	:= FND_API.g_miss_date;
   x_user_status_rec.created_by 	:= FND_API.g_miss_num;
   x_user_status_rec.last_update_login 	:= FND_API.g_miss_num;
   x_user_status_rec.object_version_number := FND_API.g_miss_num;
   x_user_status_rec.system_status_type := FND_API.g_miss_char;
   x_user_status_rec.system_status_code := FND_API.g_miss_char;
   x_user_status_rec.enabled_flag := FND_API.g_miss_char;
   x_user_status_rec.default_flag := FND_API.g_miss_char;
   x_user_status_rec.seeded_flag := FND_API.g_miss_char;
   x_user_status_rec.start_date_active 	:= FND_API.g_miss_date;
   x_user_status_rec.end_date_active 	:= FND_API.g_miss_date;
   x_user_status_rec.name 	 := FND_API.g_miss_char;
   x_user_status_rec.description := FND_API.g_miss_char;
END Init_User_Status_Rec;
---------------------------------------------------------------------
-- PROCEDURE
--    Complete_User_Status_Rec
--
---------------------------------------------------------------------
PROCEDURE Complete_User_Status_Rec (
   p_user_status_rec      IN  User_Status_Rec_Type,
   x_complete_rec   OUT NOCOPY User_Status_Rec_Type
)
IS
   CURSOR c_user_status IS
      SELECT   *
      FROM     ams_user_statuses_vl
      WHERE    user_status_id = p_user_status_rec.user_status_id;
   --
   -- This is the only exception for using %ROWTYPE.
   -- We are selecting from the VL view, which may
   -- have some denormalized columns as compared to
   -- the base tables.
   l_user_status_rec    c_user_status%ROWTYPE;
BEGIN
   x_complete_rec := p_user_status_rec;
   OPEN c_user_status;
   FETCH c_user_status INTO l_user_status_rec;
   IF c_user_status%NOTFOUND THEN
      CLOSE c_user_status;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_user_status;
   --
   -- SYSTEM_STATUS_TYPE
   IF p_user_status_rec.system_status_type = FND_API.g_miss_char THEN
      x_complete_rec.system_status_type := l_user_status_rec.system_status_type;
   END IF;
   -- SYSTEM_STATUS_CODE
   IF p_user_status_rec.system_status_code = FND_API.g_miss_char THEN
      x_complete_rec.system_status_code := l_user_status_rec.system_status_code;
   END IF;
   --
   -- DEFAULT_FLAG
   IF p_user_status_rec.default_flag = FND_API.g_miss_char THEN
      x_complete_rec.default_flag := l_user_status_rec.default_flag;
   END IF;
   --
   -- ENABLED_FLAG
   IF p_user_status_rec.enabled_flag = FND_API.g_miss_char THEN
      x_complete_rec.enabled_flag := l_user_status_rec.enabled_flag;
   END IF;

   -- SEEDED_FLAG
   IF p_user_status_rec.seeded_flag = FND_API.g_miss_char THEN
      x_complete_rec.seeded_flag := l_user_status_rec.seeded_flag;
   END IF;
   --
   -- START_DATE_ACTIVE
   IF p_user_status_rec.start_date_active = FND_API.g_miss_date THEN
      x_complete_rec.start_date_active := l_user_status_rec.start_date_active;
   END IF;
   --
   -- END_DATE_ACTIVE
   IF p_user_status_rec.end_date_active = FND_API.g_miss_date THEN
      x_complete_rec.end_date_active := l_user_status_rec.end_date_active;
   END IF;
   --
   -- NAME
   IF p_user_status_rec.name = FND_API.g_miss_char THEN
      x_complete_rec.name := l_user_status_rec.name;
   END IF;
   --
   -- DESCRIPTION
   IF p_user_status_rec.description = FND_API.g_miss_char THEN
      x_complete_rec.description := l_user_status_rec.description;
   END IF;
END Complete_User_Status_Rec;
---------------------------------------------------------
--  Function Compare Columns
-- added sugupta 05/22/2000
-- this procedure will compare that no values have been modified for seeded statuses
-----------------------------------------------------------------
FUNCTION compare_columns(
	l_user_status_rec	IN	  User_Status_Rec_Type
)
RETURN VARCHAR2
IS
  l_count NUMBER := 0;

BEGIN
IF (AMS_DEBUG_HIGH_ON) THEN

AMS_UTILITY_PVT.DEBUG_MESSAGE('sTART DATE:'|| to_char(l_user_status_rec.start_date_active,'DD_MON_YYYY'));
END IF;
IF (AMS_DEBUG_HIGH_ON) THEN

AMS_UTILITY_PVT.DEBUG_MESSAGE('end DATE:'|| to_char(l_user_status_rec.end_Date_active,'DD-MON-YYYY'));
END IF;

	if l_user_status_rec.start_date_active is NOT NULL then
		if l_user_status_rec.end_Date_active is NOT NULL then

			  BEGIN
				select 1 into l_count
				from ams_user_statuses_vl
				where user_status_id = l_user_status_rec.user_status_id
				and	  name = l_user_status_rec.name
				and   start_date_active = l_user_status_rec.start_date_active
				and   end_date_active = l_user_status_rec.end_Date_active
				and   system_status_type = l_user_status_rec.system_status_type
				and   system_status_code = l_user_status_rec.system_status_code
				and   seeded_flag = 'Y';
			  EXCEPTION
					WHEN NO_DATA_FOUND THEN
						l_count := 0;
			  END;
		else -- for end date
			  BEGIN
				select 1 into l_count
				from ams_user_statuses_vl
				where user_status_id = l_user_status_rec.user_status_id
				and	  name = l_user_status_rec.name
				and   start_date_active = l_user_status_rec.start_date_active
				and   system_status_type = l_user_status_rec.system_status_type
				and   system_status_code = l_user_status_rec.system_status_code
				and   seeded_flag = 'Y';
			  EXCEPTION
					WHEN NO_DATA_FOUND THEN
						l_count := 0;
			  END;
		end if; -- for end date
	else
			  BEGIN
				select 1 into l_count
				from ams_user_statuses_vl
				where user_status_id = l_user_status_rec.user_status_id
				and	  name = l_user_status_rec.name
				and   system_status_type = l_user_status_rec.system_status_type
				and   system_status_code = l_user_status_rec.system_status_code
				and   seeded_flag = 'Y';
			  EXCEPTION
					WHEN NO_DATA_FOUND THEN
						l_count := 0;
			  END;
	end if;

   IF l_count = 0 THEN
      RETURN FND_API.g_false;
   ELSE
      RETURN FND_API.g_true;
   END IF;
END compare_columns;

---------------------------------------------------------
--  Function seed_needs_update
-- added sugupta 05/22/2000
-- this procedure will look at enabled flag and determine if update is needed
-- updated dcastlem 09/17/2001
-- also looks at defualt flag
-----------------------------------------------------------------
FUNCTION seed_needs_update(
	l_user_status_rec	IN	  User_Status_Rec_Type
)
RETURN VARCHAR2
IS
  l_count NUMBER := 0;

BEGIN
   BEGIN
	select 1 into l_count
	from ams_user_statuses_vl
	where user_status_id = l_user_status_rec.user_status_id
	and	  enabled_flag = l_user_status_rec.enabled_flag
	and	  default_flag = l_user_status_rec.default_flag
	and   seeded_flag = 'Y';
   EXCEPTION
		WHEN NO_DATA_FOUND THEN
			l_count := 0;
   END;

   IF l_count = 0 THEN
      RETURN FND_API.g_true;  -- needs update
   ELSE
      RETURN FND_API.g_false;  -- doesnt need update
   END IF;
END seed_needs_update;

--       Check_User_Status_Req_Items
PROCEDURE Check_User_Status_Req_Items (
   p_user_status_rec       IN    User_Status_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
BEGIN
   -- SYSTEM_STATUS_TYPE
   IF p_user_status_rec.system_status_type IS NULL THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_STATUS_NO_STATUS_TYPE');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
   -- SYSTEM_STATUS_CODE
   IF p_user_status_rec.system_status_code IS NULL THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_STATUS_NO_SYSTEM_STATUS');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
   -- NAME
   IF p_user_status_rec.name IS NULL THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_STATUS_NO_NAME');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   --
   -- START_DATE_ACTIVE
   --IF p_user_status_rec.start_date_active IS NULL THEN
   --   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
   --   THEN
   --      FND_MESSAGE.set_name('AMS', 'AMS_STATUS_NO_ACTIVE_FROM');
   --     FND_MSG_PUB.add;
   --   END IF;
   --
   --   x_return_status := FND_API.g_ret_sts_error;
   --   RETURN;
   --END IF;


END Check_User_Status_Req_Items;
--       Check_User_Status_UK_Items
PROCEDURE Check_User_Status_UK_Items (
   p_user_status_rec       IN    User_Status_Rec_Type,
   p_validation_mode IN    VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
   l_valid_flag   VARCHAR2(1);
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- MEDIA_ID
   -- For Create_User_Status, when ID is passed in, we need to
   -- check if this ID is unique.
   IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_user_status_rec.user_status_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_uniqueness(
		      'ams_user_statuses_vl',
				'user_status_id = ' || p_user_status_rec.user_status_id
			) = FND_API.g_false
		THEN
         IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name ('AMS', 'AMS_STATUS_DUP_USR_ST_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
   -- check if NAME is UNIQUE
   -- modified sugupta 02/22/2000 UNIQUENESS OF NAME LIMITED TO THAT ACTIVITY TYPE
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      l_valid_flag := AMS_Utility_PVT.check_uniqueness (
         'ams_user_statuses_vl',
         'name = ''' || p_user_status_rec.name ||
		 ''' AND system_status_type = '''|| p_user_status_rec.system_status_type || ''''
      );
   ELSE
      l_valid_flag := AMS_Utility_PVT.check_uniqueness (
         'ams_user_statuses_vl',
         'name = ''' || p_user_status_rec.name ||
		 ''' AND system_status_type = '''|| p_user_status_rec.system_status_type ||
            ''' AND user_status_id <> ' || p_user_status_rec.user_status_id
      );
   END IF;
   IF l_valid_flag = FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_STATUS_DUP_NAME');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
END Check_User_Status_UK_Items;
--       Check_User_Status_FK_Items
PROCEDURE Check_User_Status_FK_Items (
   p_user_status_rec       IN    User_Status_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
BEGIN
   --
   -- What do we need to do about FKs between the
   -- B and TL tables?
   x_return_status := FND_API.g_ret_sts_success;
END Check_User_Status_FK_Items;
--       Check_User_Status_Lookup_Items
PROCEDURE Check_User_Status_Lookup_Items (
   p_user_status_rec       IN    User_Status_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
--  Shouldnt l_system_status_type be equal to p_user_status_rec.system_status_type
   l_system_status_type    VARCHAR2(30);
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   --
   -- SYSTEM_STATUS_TYPE
	l_system_status_type := p_user_status_rec.system_status_type;
   IF p_user_status_rec.system_status_code <> FND_API.g_miss_char THEN
    /* changed by BGEORGE 6/17/2002
      IF AMS_Utility_PVT.check_lookup_exists (
            p_lookup_type => l_system_status_type,
            p_lookup_code => p_user_status_rec.system_status_code
         ) = FND_API.g_false
    */
    IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => l_system_status_type,
            p_lookup_code => p_user_status_rec.system_status_code,
            p_view_application_id => fnd_global.resp_appl_id
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name ('AMS', 'AMS_STATUS_BAD_SYSTEM_STATUS');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
END Check_User_Status_Lookup_Items;
--       Check_User_Status_Flag_Items
PROCEDURE Check_User_Status_Flag_Items (
   p_user_status_rec       IN    User_Status_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- DEFAULT_FLAG
   IF p_user_status_rec.default_flag <> FND_API.g_miss_char AND p_user_status_rec.default_flag IS NOT NULL THEN
      IF AMS_Utility_PVT.is_Y_or_N (p_user_status_rec.default_flag) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name ('AMS', 'AMS_STATUS_BAD_DEFAULT_FLAG');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
   -- ENABLED_FLAG
   IF p_user_status_rec.enabled_flag <> FND_API.g_miss_char AND p_user_status_rec.enabled_flag IS NOT NULL THEN
      IF AMS_Utility_PVT.is_Y_or_N (p_user_status_rec.enabled_flag) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name ('AMS', 'AMS_STATUS_BAD_ENABLED_FLAG');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
END Check_User_Status_Flag_Items;

-----------------------------------------------------------------
FUNCTION can_disable_status(
	l_user_status_rec	IN	  User_Status_Rec_Type
)
RETURN VARCHAR2
IS
  l_count NUMBER := 0;
  l_system_status_type VARCHAR2(30);
  l_obj_type VARCHAR2(30);
  l_stmt VARCHAR2(1000);
  l_user_status_id NUMBER;
  l_table VARCHAR2(30);

BEGIN
   l_system_status_type := l_user_status_rec.system_status_type;
   l_user_status_id := l_user_status_rec.user_status_id;
   l_obj_type := substr(l_system_status_type, instr(l_system_status_type, '_', 1,1)+1, instr(l_system_status_type,'_',-1,1)-instr(l_system_status_type, '_', 1,1)-1);


     -- Not all these tables have an index on user_status_id
     -- In such cases, there may be performance hit.

     IF l_obj_type IN ('CAMPAIGN','PROGRAM') THEN
       l_table := 'AMS_CAMPAIGNS_ALL_B';

     ELSIF l_obj_type = 'CAMPAIGN_SCHEDULE' THEN
       l_table := 'AMS_CAMPAIGN_SCHEDULES_B';

     ELSIF l_obj_type = 'EVENT' THEN
       l_table := 'AMS_EVENT_HEADERS_ALL_B'; -- Also AMS_EVENT_OFFERS_ALL_B

     ELSIF l_obj_type = 'EVENT_REG' THEN
       l_table := 'AMS_EVENT_REGISTRATIONS';

     ELSIF l_obj_type = 'EVENT_AGENDA' THEN
       l_table := 'AMS_ACT_RESOURCES';

     ELSIF l_obj_type = 'DELIV' THEN
       l_table := 'AMS_DELIVERABLES_ALL_B';

     ELSIF l_obj_type = 'PRICELIST' THEN
       l_table := 'OZF_PRICE_LIST_ATTRIBUTES';

     ELSIF l_obj_type = 'BUDGETSOURCE' THEN
       l_table := 'OZF_ACT_BUDGETS';

     ELSIF l_obj_type = 'FUND' THEN
       l_table := 'OZF_FUNDS_ALL_B';

     ELSIF l_obj_type = 'DM_SCORE' THEN
       l_table := 'AMS_DM_SCORES_ALL_B';

     ELSIF l_obj_type = 'DM_MODEL' THEN
       l_table := 'AMS_DM_MODELS_ALL_B';

     ELSIF l_obj_type = 'CLAIM' THEN
       l_table := 'OZF_CLAIMS_ALL';

     ELSIF l_obj_type = 'LIST' THEN
       l_table := 'AMS_LIST_HEADERS_ALL';

     ELSIF l_obj_type = 'LIST_SEGMENT' THEN
       l_table := 'AMS_CELLS_ALL_B';

     ELSIF l_obj_type = 'IMPORT' THEN
       l_table := 'AMS_IMP_LIST_HEADERS_ALL';

     ELSIF l_obj_type = 'OFFER' THEN
       l_table := 'OZF_OFFERS';

     END IF;

     IF l_table IS NOT NULL THEN
       l_stmt := 'SELECT count(1) from  '||l_table||' where user_status_id = :b1';
       EXECUTE IMMEDIATE l_stmt INTO l_count USING l_user_status_id;

       IF l_obj_type = 'EVENT' and l_count = 0 THEN
        l_table := 'AMS_EVENT_OFFERS_ALL_B'; -- Already checked ams_event_headers_all_b
        l_stmt := 'SELECT count(1) from  '||l_table||' where user_status_id = :b1';
        EXECUTE IMMEDIATE l_stmt INTO l_count USING l_user_status_id;
       END IF;

     END IF;


   IF l_count = 0 THEN
      RETURN FND_API.g_true;  -- can be disabled
   ELSE
      RETURN FND_API.g_false; -- cannot be disables
   END IF;

END can_disable_status;

END AMS_User_Statuses_PVT;

/
