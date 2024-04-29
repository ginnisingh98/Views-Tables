--------------------------------------------------------
--  DDL for Package Body AMS_PARTYIMPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_PARTYIMPORT_PVT" AS
/* $Header: amsvptyb.pls 120.1 2005/08/12 18:36:09 appldev ship $ */

-----------------------------------------------------------
-- PACKAGE
--    AMS_PartyImport_PVT
--
-- PROCEDURES
--    Listed are the procedures not declared in the package
--    specs:
--       Check_Party_Req_Items
--       Check_Party_UK_Items
--       Check_Party_FK_Items
--       Check_Party_Lookup_Items
--       Check_Party_Flag_Items
--
--       Initialize_Dedupe_Table
--       Synchronize_ID
--       Populate_Keys
--       Party_Exists
--
-- HISTORY
-- 08-Nov-1999 choang      Created.
-- 10-Nov-1999 choang      Added GENERATE_KEY.
-- 12-Nov-1999 choang      Fixed Complete_Party API which used
--                         g_miss_num on USED_FLAG instead of
--                         g_miss_char.
-- 13-Nov-1999 choang      Added Process_Party and Party_Exists.
-- 14-Feb-2001 gjoby       Added a check to get Profile option for dedupe
------------------------------------------------------------

G_PKG_NAME           CONSTANT VARCHAR2(30) := 'AMS_PartyImport_PVT';


AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Check_Party_Req_Items (
   p_party_rec       IN    Party_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
);

PROCEDURE Check_Party_UK_Items (
   p_party_rec       IN    Party_Rec_Type,
   p_validation_mode IN    VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY   VARCHAR2
);

PROCEDURE Check_Party_FK_Items (
   p_party_rec       IN    Party_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
);

PROCEDURE Check_Party_Lookup_Items (
   p_party_rec       IN    Party_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
);

PROCEDURE Check_Party_Flag_Items (
   p_party_rec       IN    Party_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
);

PROCEDURE Initialize_Dedupe_Table;

PROCEDURE Synchronize_ID;

PROCEDURE Populate_Keys (
   p_word_replacement_flag    IN VARCHAR2
);

FUNCTION Party_Exists (
   p_dedupe_key      IN VARCHAR2,
   x_party_id        OUT NOCOPY NUMBER
) RETURN BOOLEAN;


--------------------------------------------------------------------
-- PROCEDURE
--    Create_Party
PROCEDURE Create_Party (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_party_rec         IN  Party_Rec_Type,
   x_party_sources_id  OUT NOCOPY NUMBER
)
IS
   l_api_version  CONSTANT NUMBER       := 1.0;
   l_api_name     CONSTANT VARCHAR2(30) := 'Create_Party';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status   VARCHAR2(1);
   l_party_rec       Party_Rec_Type  := p_party_rec;
   l_dummy           NUMBER;     -- Capture the exit condition for ID existence loop.

   CURSOR c_seq IS
      SELECT ams_party_sources_s.NEXTVAL
      FROM   dual;

   CURSOR c_id_exists (x_id IN NUMBER) IS
      SELECT 1
      FROM   dual
      WHERE EXISTS (SELECT 1
                    FROM   ams_party_sources
                    WHERE  party_sources_id = x_id);
BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Create_Party;

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

   ----------------------- validate -----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': Validate');
   END IF;

   Validate_Party (
      p_api_version        => l_api_version,
      p_init_msg_list      => p_init_msg_list,
      p_validation_level   => p_validation_level,
      x_return_status      => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_party_rec        => l_party_rec
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   --
   -- Check for the ID.
   --
   IF l_party_rec.party_sources_id IS NULL THEN
      LOOP
         --
         -- If the ID is not passed into the API, then
         -- grab a value from the sequence.
         OPEN c_seq;
         FETCH c_seq INTO l_party_rec.party_sources_id;
         CLOSE c_seq;

         --
         -- Check to be sure that the sequence does not exist.
         OPEN c_id_exists (l_party_rec.party_sources_id);
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

   INSERT INTO ams_party_sources (
      party_sources_id,
      party_id,
      import_source_line_id,
      object_version_number,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      import_list_header_id,
      list_source_type_id,
      used_flag,
      overlay_flag,
      overlay_date,
      col1,
      col2,
      col3,
      col4,
      col5,
      col6,
      col7,
      col8,
      col9,
      col10,
      col11,
      col12,
      col13,
      col14,
      col15,
      col16,
      col17,
      col18,
      col19,
      col20,
      col21,
      col22,
      col23,
      col24,
      col25,
      col26,
      col27,
      col28,
      col29,
      col30,
      col31,
      col32,
      col33,
      col34,
      col35,
      col36,
      col37,
      col38,
      col39,
      col40,
      col41,
      col42,
      col43,
      col44,
      col45,
      col46,
      col47,
      col48,
      col49,
      col50,
      col51,
      col52,
      col53,
      col54,
      col55,
      col56,
      col57,
      col58,
      col59,
      col60,
      col61,
      col62,
      col63,
      col64,
      col65,
      col66,
      col67,
      col68,
      col69,
      col70,
      col71,
      col72,
      col73,
      col74,
      col75,
      col76,
      col77,
      col78,
      col79,
      col80,
      col81,
      col82,
      col83,
      col84,
      col85,
      col86,
      col87,
      col88,
      col89,
      col90,
      col91,
      col92,
      col93,
      col94,
      col95,
      col96,
      col97,
      col98,
      col99,
      col100,
      col101,
      col102,
      col103,
      col104,
      col105,
      col106,
      col107,
      col108,
      col109,
      col110,
      col111,
      col112,
      col113,
      col114,
      col115,
      col116,
      col117,
      col118,
      col119,
      col120,
      col121,
      col122,
      col123,
      col124,
      col125,
      col126,
      col127,
      col128,
      col129,
      col130,
      col131,
      col132,
      col133,
      col134,
      col135,
      col136,
      col137,
      col138,
      col139,
      col140,
      col141,
      col142,
      col143,
      col144,
      col145,
      col146,
      col147,
      col148,
      col149,
      col150,
      col151,
      col152,
      col153,
      col154,
      col155,
      col156,
      col157,
      col158,
      col159,
      col160,
      col161,
      col162,
      col163,
      col164,
      col165,
      col166,
      col167,
      col168,
      col169,
      col170,
      col171,
      col172,
      col173,
      col174,
      col175,
      col176,
      col177,
      col178,
      col179,
      col180,
      col181,
      col182,
      col183,
      col184,
      col185,
      col186,
      col187,
      col188,
      col189,
      col190,
      col191,
      col192,
      col193,
      col194,
      col195,
      col196,
      col197,
      col198,
      col199,
      col200,
      col201,
      col202,
      col203,
      col204,
      col205,
      col206,
      col207,
      col208,
      col209,
      col210,
      col211,
      col212,
      col213,
      col214,
      col215,
      col216,
      col217,
      col218,
      col219,
      col220,
      col221,
      col222,
      col223,
      col224,
      col225,
      col226,
      col227,
      col228,
      col229,
      col230,
      col231,
      col232,
      col233,
      col234,
      col235,
      col236,
      col237,
      col238,
      col239,
      col240,
      col241,
      col242,
      col243,
      col244,
      col245,
      col246,
      col247,
      col248,
      col249,
      col250
   )
   VALUES (
      l_party_rec.party_sources_id,
      l_party_rec.party_id,
      l_party_rec.import_source_line_id,
      1,    -- object_version_number
      SYSDATE,                      -- last_update_date
      FND_GLOBAL.user_id,           -- last_updated_by
      SYSDATE,                      -- creation_date
      FND_GLOBAL.user_id,           -- created_by
      FND_GLOBAL.conc_login_id,     -- last_update_login
      l_party_rec.import_list_header_id,
      l_party_rec.list_source_type_id,
      NVL (l_party_rec.used_flag, 'N'),      -- Default to 'N'
      NVL (l_party_rec.overlay_flag, 'N'),   -- Default to 'N'
      l_party_rec.overlay_date,
      l_party_rec.col1,
      l_party_rec.col2,
      l_party_rec.col3,
      l_party_rec.col4,
      l_party_rec.col5,
      l_party_rec.col6,
      l_party_rec.col7,
      l_party_rec.col8,
      l_party_rec.col9,
      l_party_rec.col10,
      l_party_rec.col11,
      l_party_rec.col12,
      l_party_rec.col13,
      l_party_rec.col14,
      l_party_rec.col15,
      l_party_rec.col16,
      l_party_rec.col17,
      l_party_rec.col18,
      l_party_rec.col19,
      l_party_rec.col20,
      l_party_rec.col21,
      l_party_rec.col22,
      l_party_rec.col23,
      l_party_rec.col24,
      l_party_rec.col25,
      l_party_rec.col26,
      l_party_rec.col27,
      l_party_rec.col28,
      l_party_rec.col29,
      l_party_rec.col30,
      l_party_rec.col31,
      l_party_rec.col32,
      l_party_rec.col33,
      l_party_rec.col34,
      l_party_rec.col35,
      l_party_rec.col36,
      l_party_rec.col37,
      l_party_rec.col38,
      l_party_rec.col39,
      l_party_rec.col40,
      l_party_rec.col41,
      l_party_rec.col42,
      l_party_rec.col43,
      l_party_rec.col44,
      l_party_rec.col45,
      l_party_rec.col46,
      l_party_rec.col47,
      l_party_rec.col48,
      l_party_rec.col49,
      l_party_rec.col50,
      l_party_rec.col51,
      l_party_rec.col52,
      l_party_rec.col53,
      l_party_rec.col54,
      l_party_rec.col55,
      l_party_rec.col56,
      l_party_rec.col57,
      l_party_rec.col58,
      l_party_rec.col59,
      l_party_rec.col60,
      l_party_rec.col61,
      l_party_rec.col62,
      l_party_rec.col63,
      l_party_rec.col64,
      l_party_rec.col65,
      l_party_rec.col66,
      l_party_rec.col67,
      l_party_rec.col68,
      l_party_rec.col69,
      l_party_rec.col70,
      l_party_rec.col71,
      l_party_rec.col72,
      l_party_rec.col73,
      l_party_rec.col74,
      l_party_rec.col75,
      l_party_rec.col76,
      l_party_rec.col77,
      l_party_rec.col78,
      l_party_rec.col79,
      l_party_rec.col80,
      l_party_rec.col81,
      l_party_rec.col82,
      l_party_rec.col83,
      l_party_rec.col84,
      l_party_rec.col85,
      l_party_rec.col86,
      l_party_rec.col87,
      l_party_rec.col88,
      l_party_rec.col89,
      l_party_rec.col90,
      l_party_rec.col91,
      l_party_rec.col92,
      l_party_rec.col93,
      l_party_rec.col94,
      l_party_rec.col95,
      l_party_rec.col96,
      l_party_rec.col97,
      l_party_rec.col98,
      l_party_rec.col99,
      l_party_rec.col100,
      l_party_rec.col101,
      l_party_rec.col102,
      l_party_rec.col103,
      l_party_rec.col104,
      l_party_rec.col105,
      l_party_rec.col106,
      l_party_rec.col107,
      l_party_rec.col108,
      l_party_rec.col109,
      l_party_rec.col110,
      l_party_rec.col111,
      l_party_rec.col112,
      l_party_rec.col113,
      l_party_rec.col114,
      l_party_rec.col115,
      l_party_rec.col116,
      l_party_rec.col117,
      l_party_rec.col118,
      l_party_rec.col119,
      l_party_rec.col120,
      l_party_rec.col121,
      l_party_rec.col122,
      l_party_rec.col123,
      l_party_rec.col124,
      l_party_rec.col125,
      l_party_rec.col126,
      l_party_rec.col127,
      l_party_rec.col128,
      l_party_rec.col129,
      l_party_rec.col130,
      l_party_rec.col131,
      l_party_rec.col132,
      l_party_rec.col133,
      l_party_rec.col134,
      l_party_rec.col135,
      l_party_rec.col136,
      l_party_rec.col137,
      l_party_rec.col138,
      l_party_rec.col139,
      l_party_rec.col140,
      l_party_rec.col141,
      l_party_rec.col142,
      l_party_rec.col143,
      l_party_rec.col144,
      l_party_rec.col145,
      l_party_rec.col146,
      l_party_rec.col147,
      l_party_rec.col148,
      l_party_rec.col149,
      l_party_rec.col150,
      l_party_rec.col151,
      l_party_rec.col152,
      l_party_rec.col153,
      l_party_rec.col154,
      l_party_rec.col155,
      l_party_rec.col156,
      l_party_rec.col157,
      l_party_rec.col158,
      l_party_rec.col159,
      l_party_rec.col160,
      l_party_rec.col161,
      l_party_rec.col162,
      l_party_rec.col163,
      l_party_rec.col164,
      l_party_rec.col165,
      l_party_rec.col166,
      l_party_rec.col167,
      l_party_rec.col168,
      l_party_rec.col169,
      l_party_rec.col170,
      l_party_rec.col171,
      l_party_rec.col172,
      l_party_rec.col173,
      l_party_rec.col174,
      l_party_rec.col175,
      l_party_rec.col176,
      l_party_rec.col177,
      l_party_rec.col178,
      l_party_rec.col179,
      l_party_rec.col180,
      l_party_rec.col181,
      l_party_rec.col182,
      l_party_rec.col183,
      l_party_rec.col184,
      l_party_rec.col185,
      l_party_rec.col186,
      l_party_rec.col187,
      l_party_rec.col188,
      l_party_rec.col189,
      l_party_rec.col190,
      l_party_rec.col191,
      l_party_rec.col192,
      l_party_rec.col193,
      l_party_rec.col194,
      l_party_rec.col195,
      l_party_rec.col196,
      l_party_rec.col197,
      l_party_rec.col198,
      l_party_rec.col199,
      l_party_rec.col200,
      l_party_rec.col201,
      l_party_rec.col202,
      l_party_rec.col203,
      l_party_rec.col204,
      l_party_rec.col205,
      l_party_rec.col206,
      l_party_rec.col207,
      l_party_rec.col208,
      l_party_rec.col209,
      l_party_rec.col210,
      l_party_rec.col211,
      l_party_rec.col212,
      l_party_rec.col213,
      l_party_rec.col214,
      l_party_rec.col215,
      l_party_rec.col216,
      l_party_rec.col217,
      l_party_rec.col218,
      l_party_rec.col219,
      l_party_rec.col220,
      l_party_rec.col221,
      l_party_rec.col222,
      l_party_rec.col223,
      l_party_rec.col224,
      l_party_rec.col225,
      l_party_rec.col226,
      l_party_rec.col227,
      l_party_rec.col228,
      l_party_rec.col229,
      l_party_rec.col230,
      l_party_rec.col231,
      l_party_rec.col232,
      l_party_rec.col233,
      l_party_rec.col234,
      l_party_rec.col235,
      l_party_rec.col236,
      l_party_rec.col237,
      l_party_rec.col238,
      l_party_rec.col239,
      l_party_rec.col240,
      l_party_rec.col241,
      l_party_rec.col242,
      l_party_rec.col243,
      l_party_rec.col244,
      l_party_rec.col245,
      l_party_rec.col246,
      l_party_rec.col247,
      l_party_rec.col248,
      l_party_rec.col249,
      l_party_rec.col250
   );

   ------------------------- finish -------------------------------
   --
   -- Set the out variable.
   x_party_sources_id := l_party_rec.party_sources_id;

   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
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
      ROLLBACK TO Create_Party;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Create_Party;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Party;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Create_Party;


--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Party
PROCEDURE Delete_Party (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_party_sources_id  IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS
   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Delete_Party';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Delete_Party;

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
   DELETE FROM ams_party_sources
   WHERE party_sources_id = p_party_sources_id
   AND   object_version_number = p_object_version;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
		THEN
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



   AMS_Utility_PVT.debug_message(l_full_name || ': End');

   END IF;

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Delete_Party;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Delete_Party;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Party;
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
END Delete_Party;


--------------------------------------------------------------------
-- PROCEDURE
--    Lock_Party
PROCEDURE Lock_Party (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_party_sources_id  IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS
   l_api_version  CONSTANT NUMBER       := 1.0;
   l_api_name     CONSTANT VARCHAR2(30) := 'Lock_Party';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

   l_dummy        NUMBER;     -- Used by the lock cursor.

   --
   -- NOTE: Not necessary to distinguish between a record
   -- which does not exist and one which has been updated
   -- by another user.  To get that distinction, remove
   -- the object_version condition from the SQL statement
   -- and perform comparison in the body and raise the
   -- exception there.
   CURSOR c_lock_req IS
      SELECT object_version_number
      FROM   ams_party_sources
      WHERE  party_sources_id = p_party_sources_id
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
   OPEN c_lock_req;
   FETCH c_lock_req INTO l_dummy;
   IF c_lock_req%NOTFOUND THEN
      CLOSE c_lock_req;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_lock_req;

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

      FND_MSG_PUB.count_and_get(
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
END Lock_Party;


--------------------------------------------------------------------
-- PROCEDURE
--    Update_Party
PROCEDURE Update_Party (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_party_rec         IN  Party_Rec_Type
)
IS
   l_api_version CONSTANT NUMBER := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Update_Party';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

   l_party_rec       Party_Rec_Type := p_party_rec;
   l_return_status   VARCHAR2(1);
BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Update_Party;

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
   Complete_Party_Rec (p_party_rec, l_party_rec);

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Check_Party_Items (
         p_party_rec          => p_party_rec,
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
      Check_Party_Record (
         p_party_rec       => p_party_rec,
         p_complete_rec    => l_party_rec,
         x_return_status   => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -------------------------- update --------------------
   UPDATE ams_party_sources
   SET
      party_sources_id = l_party_rec.party_sources_id,
      party_id = l_party_rec.party_id,
      import_source_line_id = l_party_rec.import_source_line_id,
      object_version_number = l_party_rec.object_version_number,
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.user_id,
      last_update_login = FND_GLOBAL.conc_login_id,
      import_list_header_id = l_party_rec.import_list_header_id,
      list_source_type_id = l_party_rec.list_source_type_id,
      used_flag = NVL (l_party_rec.used_flag, 'N'),
      overlay_flag = NVL (l_party_rec.overlay_flag, 'N'),
      overlay_date = l_party_rec.overlay_date,
      col1 = l_party_rec.col1,
      col2 = l_party_rec.col2,
      col3 = l_party_rec.col3,
      col4 = l_party_rec.col4,
      col5 = l_party_rec.col5,
      col6 = l_party_rec.col6,
      col7 = l_party_rec.col7,
      col8 = l_party_rec.col8,
      col9 = l_party_rec.col9,
      col10 = l_party_rec.col10,
      col11 = l_party_rec.col11,
      col12 = l_party_rec.col12,
      col13 = l_party_rec.col13,
      col14 = l_party_rec.col14,
      col15 = l_party_rec.col15,
      col16 = l_party_rec.col16,
      col17 = l_party_rec.col17,
      col18 = l_party_rec.col18,
      col19 = l_party_rec.col19,
      col20 = l_party_rec.col20,
      col21 = l_party_rec.col21,
      col22 = l_party_rec.col22,
      col23 = l_party_rec.col23,
      col24 = l_party_rec.col24,
      col25 = l_party_rec.col25,
      col26 = l_party_rec.col26,
      col27 = l_party_rec.col27,
      col28 = l_party_rec.col28,
      col29 = l_party_rec.col29,
      col30 = l_party_rec.col30,
      col31 = l_party_rec.col31,
      col32 = l_party_rec.col32,
      col33 = l_party_rec.col33,
      col34 = l_party_rec.col34,
      col35 = l_party_rec.col35,
      col36 = l_party_rec.col36,
      col37 = l_party_rec.col37,
      col38 = l_party_rec.col38,
      col39 = l_party_rec.col39,
      col40 = l_party_rec.col40,
      col41 = l_party_rec.col41,
      col42 = l_party_rec.col42,
      col43 = l_party_rec.col43,
      col44 = l_party_rec.col44,
      col45 = l_party_rec.col45,
      col46 = l_party_rec.col46,
      col47 = l_party_rec.col47,
      col48 = l_party_rec.col48,
      col49 = l_party_rec.col49,
      col50 = l_party_rec.col50,
      col51 = l_party_rec.col51,
      col52 = l_party_rec.col52,
      col53 = l_party_rec.col53,
      col54 = l_party_rec.col54,
      col55 = l_party_rec.col55,
      col56 = l_party_rec.col56,
      col57 = l_party_rec.col57,
      col58 = l_party_rec.col58,
      col59 = l_party_rec.col59,
      col60 = l_party_rec.col60,
      col61 = l_party_rec.col61,
      col62 = l_party_rec.col62,
      col63 = l_party_rec.col63,
      col64 = l_party_rec.col64,
      col65 = l_party_rec.col65,
      col66 = l_party_rec.col66,
      col67 = l_party_rec.col67,
      col68 = l_party_rec.col68,
      col69 = l_party_rec.col69,
      col70 = l_party_rec.col70,
      col71 = l_party_rec.col71,
      col72 = l_party_rec.col72,
      col73 = l_party_rec.col73,
      col74 = l_party_rec.col74,
      col75 = l_party_rec.col75,
      col76 = l_party_rec.col76,
      col77 = l_party_rec.col77,
      col78 = l_party_rec.col78,
      col79 = l_party_rec.col79,
      col80 = l_party_rec.col80,
      col81 = l_party_rec.col81,
      col82 = l_party_rec.col82,
      col83 = l_party_rec.col83,
      col84 = l_party_rec.col84,
      col85 = l_party_rec.col85,
      col86 = l_party_rec.col86,
      col87 = l_party_rec.col87,
      col88 = l_party_rec.col88,
      col89 = l_party_rec.col89,
      col90 = l_party_rec.col90,
      col91 = l_party_rec.col91,
      col92 = l_party_rec.col92,
      col93 = l_party_rec.col93,
      col94 = l_party_rec.col94,
      col95 = l_party_rec.col95,
      col96 = l_party_rec.col96,
      col97 = l_party_rec.col97,
      col98 = l_party_rec.col98,
      col99 = l_party_rec.col99,
      col100 = l_party_rec.col100,
      col101 = l_party_rec.col101,
      col102 = l_party_rec.col102,
      col103 = l_party_rec.col103,
      col104 = l_party_rec.col104,
      col105 = l_party_rec.col105,
      col106 = l_party_rec.col106,
      col107 = l_party_rec.col107,
      col108 = l_party_rec.col108,
      col109 = l_party_rec.col109,
      col110 = l_party_rec.col110,
      col111 = l_party_rec.col111,
      col112 = l_party_rec.col112,
      col113 = l_party_rec.col113,
      col114 = l_party_rec.col114,
      col115 = l_party_rec.col115,
      col116 = l_party_rec.col116,
      col117 = l_party_rec.col117,
      col118 = l_party_rec.col118,
      col119 = l_party_rec.col119,
      col120 = l_party_rec.col120,
      col121 = l_party_rec.col121,
      col122 = l_party_rec.col122,
      col123 = l_party_rec.col123,
      col124 = l_party_rec.col124,
      col125 = l_party_rec.col125,
      col126 = l_party_rec.col126,
      col127 = l_party_rec.col127,
      col128 = l_party_rec.col128,
      col129 = l_party_rec.col129,
      col130 = l_party_rec.col130,
      col131 = l_party_rec.col131,
      col132 = l_party_rec.col132,
      col133 = l_party_rec.col133,
      col134 = l_party_rec.col134,
      col135 = l_party_rec.col135,
      col136 = l_party_rec.col136,
      col137 = l_party_rec.col137,
      col138 = l_party_rec.col138,
      col139 = l_party_rec.col139,
      col140 = l_party_rec.col140,
      col141 = l_party_rec.col141,
      col142 = l_party_rec.col142,
      col143 = l_party_rec.col143,
      col144 = l_party_rec.col144,
      col145 = l_party_rec.col145,
      col146 = l_party_rec.col146,
      col147 = l_party_rec.col147,
      col148 = l_party_rec.col148,
      col149 = l_party_rec.col149,
      col150 = l_party_rec.col150,
      col151 = l_party_rec.col151,
      col152 = l_party_rec.col152,
      col153 = l_party_rec.col153,
      col154 = l_party_rec.col154,
      col155 = l_party_rec.col155,
      col156 = l_party_rec.col156,
      col157 = l_party_rec.col157,
      col158 = l_party_rec.col158,
      col159 = l_party_rec.col159,
      col160 = l_party_rec.col160,
      col161 = l_party_rec.col161,
      col162 = l_party_rec.col162,
      col163 = l_party_rec.col163,
      col164 = l_party_rec.col164,
      col165 = l_party_rec.col165,
      col166 = l_party_rec.col166,
      col167 = l_party_rec.col167,
      col168 = l_party_rec.col168,
      col169 = l_party_rec.col169,
      col170 = l_party_rec.col170,
      col171 = l_party_rec.col171,
      col172 = l_party_rec.col172,
      col173 = l_party_rec.col173,
      col174 = l_party_rec.col174,
      col175 = l_party_rec.col175,
      col176 = l_party_rec.col176,
      col177 = l_party_rec.col177,
      col178 = l_party_rec.col178,
      col179 = l_party_rec.col179,
      col180 = l_party_rec.col180,
      col181 = l_party_rec.col181,
      col182 = l_party_rec.col182,
      col183 = l_party_rec.col183,
      col184 = l_party_rec.col184,
      col185 = l_party_rec.col185,
      col186 = l_party_rec.col186,
      col187 = l_party_rec.col187,
      col188 = l_party_rec.col188,
      col189 = l_party_rec.col189,
      col190 = l_party_rec.col190,
      col191 = l_party_rec.col191,
      col192 = l_party_rec.col192,
      col193 = l_party_rec.col193,
      col194 = l_party_rec.col194,
      col195 = l_party_rec.col195,
      col196 = l_party_rec.col196,
      col197 = l_party_rec.col197,
      col198 = l_party_rec.col198,
      col199 = l_party_rec.col199,
      col200 = l_party_rec.col200,
      col201 = l_party_rec.col201,
      col202 = l_party_rec.col202,
      col203 = l_party_rec.col203,
      col204 = l_party_rec.col204,
      col205 = l_party_rec.col205,
      col206 = l_party_rec.col206,
      col207 = l_party_rec.col207,
      col208 = l_party_rec.col208,
      col209 = l_party_rec.col209,
      col210 = l_party_rec.col210,
      col211 = l_party_rec.col211,
      col212 = l_party_rec.col212,
      col213 = l_party_rec.col213,
      col214 = l_party_rec.col214,
      col215 = l_party_rec.col215,
      col216 = l_party_rec.col216,
      col217 = l_party_rec.col217,
      col218 = l_party_rec.col218,
      col219 = l_party_rec.col219,
      col220 = l_party_rec.col220,
      col221 = l_party_rec.col221,
      col222 = l_party_rec.col222,
      col223 = l_party_rec.col223,
      col224 = l_party_rec.col224,
      col225 = l_party_rec.col225,
      col226 = l_party_rec.col226,
      col227 = l_party_rec.col227,
      col228 = l_party_rec.col228,
      col229 = l_party_rec.col229,
      col230 = l_party_rec.col230,
      col231 = l_party_rec.col231,
      col232 = l_party_rec.col232,
      col233 = l_party_rec.col233,
      col234 = l_party_rec.col234,
      col235 = l_party_rec.col235,
      col236 = l_party_rec.col236,
      col237 = l_party_rec.col237,
      col238 = l_party_rec.col238,
      col239 = l_party_rec.col239,
      col240 = l_party_rec.col240,
      col241 = l_party_rec.col241,
      col242 = l_party_rec.col242,
      col243 = l_party_rec.col243,
      col244 = l_party_rec.col244,
      col245 = l_party_rec.col245,
      col246 = l_party_rec.col246,
      col247 = l_party_rec.col247,
      col248 = l_party_rec.col248,
      col249 = l_party_rec.col249,
      col250 = l_party_rec.col250
   WHERE party_sources_id = l_party_rec.party_sources_id
   AND   object_version_number = l_party_rec.object_version_number;

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
      ROLLBACK TO Update_Party;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Update_Party;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Party;
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
END Update_Party;


--------------------------------------------------------------------
-- PROCEDURE
--    Validate_Party
PROCEDURE Validate_Party (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_party_rec       IN  Party_Rec_Type
)
IS
   l_api_version CONSTANT NUMBER := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Validate_Party';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

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
      Check_Party_Items (
         p_party_rec          => p_party_rec,
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
      Check_Party_Record (
         p_party_rec       => p_party_rec,
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
END Validate_Party;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Party_Items
--
-- PURPOSE
--    Perform item level validation.
--
-- HISTORY
-- 08-Nov-1999 choang      Created.
---------------------------------------------------------------------
PROCEDURE Check_Party_Items (
   p_party_rec       IN  Party_Rec_Type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message ('Check required items');
   END IF;
   --
   -- Validate required items.
   Check_Party_Req_Items (
      p_party_rec       => p_party_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message ('Check unique items');

   END IF;
   --
   -- Validate uniqueness.
   Check_Party_UK_Items (
      p_party_rec          => p_party_rec,
      p_validation_mode    => p_validation_mode,
      x_return_status      => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message ('Check FK items');

   END IF;
   Check_Party_FK_Items(
      p_party_rec       => p_party_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message ('Check lookup items');

   END IF;
   Check_Party_Lookup_Items (
      p_party_rec          => p_party_rec,
      x_return_status      => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message ('Check flag items');

   END IF;
   Check_Party_Flag_Items(
      p_party_rec        => p_party_rec,
      x_return_status    => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
END Check_Party_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Party_Record
--
-- PURPOSE
--    Perform record level validation.
--
-- HISTORY
-- 08-Nov-1999 choang      Created as a dummy procedure.
---------------------------------------------------------------------
PROCEDURE Check_Party_Record (
   p_party_rec        IN  Party_Rec_Type,
   p_complete_rec     IN  Party_Rec_Type := NULL,
   x_return_status    OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

END Check_Party_Record;


---------------------------------------------------------------------
-- PROCEDURE
--    Init_Party_Rec
--
-- PURPOSE
--
-- HISTORY
-- 08-Nov-1999 choang      Created.
---------------------------------------------------------------------
PROCEDURE Init_Party_Rec (
   x_party_rec         OUT NOCOPY  Party_Rec_Type
)
IS
BEGIN
      x_party_rec.party_sources_id := FND_API.g_miss_num;
      x_party_rec.party_id := FND_API.g_miss_num;
      x_party_rec.import_source_line_id := FND_API.g_miss_num;
      x_party_rec.object_version_number := FND_API.g_miss_num;
      x_party_rec.last_update_date := FND_API.g_miss_date;
      x_party_rec.last_updated_by := FND_API.g_miss_num;
      x_party_rec.creation_date := FND_API.g_miss_date;
      x_party_rec.created_by := FND_API.g_miss_num;
      x_party_rec.last_update_login := FND_API.g_miss_num;
      x_party_rec.import_list_header_id := FND_API.g_miss_num;
      x_party_rec.list_source_type_id := FND_API.g_miss_num;
      x_party_rec.used_flag := FND_API.g_miss_char;
      x_party_rec.overlay_flag := FND_API.g_miss_char;
      x_party_rec.overlay_date := FND_API.g_miss_date;
      x_party_rec.col1 := FND_API.g_miss_char;
      x_party_rec.col2 := FND_API.g_miss_char;
      x_party_rec.col3 := FND_API.g_miss_char;
      x_party_rec.col4 := FND_API.g_miss_char;
      x_party_rec.col5 := FND_API.g_miss_char;
      x_party_rec.col6 := FND_API.g_miss_char;
      x_party_rec.col7 := FND_API.g_miss_char;
      x_party_rec.col8 := FND_API.g_miss_char;
      x_party_rec.col9 := FND_API.g_miss_char;
      x_party_rec.col10 := FND_API.g_miss_char;
      x_party_rec.col11 := FND_API.g_miss_char;
      x_party_rec.col12 := FND_API.g_miss_char;
      x_party_rec.col13 := FND_API.g_miss_char;
      x_party_rec.col14 := FND_API.g_miss_char;
      x_party_rec.col15 := FND_API.g_miss_char;
      x_party_rec.col16 := FND_API.g_miss_char;
      x_party_rec.col17 := FND_API.g_miss_char;
      x_party_rec.col18 := FND_API.g_miss_char;
      x_party_rec.col19 := FND_API.g_miss_char;
      x_party_rec.col20 := FND_API.g_miss_char;
      x_party_rec.col21 := FND_API.g_miss_char;
      x_party_rec.col22 := FND_API.g_miss_char;
      x_party_rec.col23 := FND_API.g_miss_char;
      x_party_rec.col24 := FND_API.g_miss_char;
      x_party_rec.col25 := FND_API.g_miss_char;
      x_party_rec.col26 := FND_API.g_miss_char;
      x_party_rec.col27 := FND_API.g_miss_char;
      x_party_rec.col28 := FND_API.g_miss_char;
      x_party_rec.col29 := FND_API.g_miss_char;
      x_party_rec.col30 := FND_API.g_miss_char;
      x_party_rec.col31 := FND_API.g_miss_char;
      x_party_rec.col32 := FND_API.g_miss_char;
      x_party_rec.col33 := FND_API.g_miss_char;
      x_party_rec.col34 := FND_API.g_miss_char;
      x_party_rec.col35 := FND_API.g_miss_char;
      x_party_rec.col36 := FND_API.g_miss_char;
      x_party_rec.col37 := FND_API.g_miss_char;
      x_party_rec.col38 := FND_API.g_miss_char;
      x_party_rec.col39 := FND_API.g_miss_char;
      x_party_rec.col40 := FND_API.g_miss_char;
      x_party_rec.col41 := FND_API.g_miss_char;
      x_party_rec.col42 := FND_API.g_miss_char;
      x_party_rec.col43 := FND_API.g_miss_char;
      x_party_rec.col44 := FND_API.g_miss_char;
      x_party_rec.col45 := FND_API.g_miss_char;
      x_party_rec.col46 := FND_API.g_miss_char;
      x_party_rec.col47 := FND_API.g_miss_char;
      x_party_rec.col48 := FND_API.g_miss_char;
      x_party_rec.col49 := FND_API.g_miss_char;
      x_party_rec.col50 := FND_API.g_miss_char;
      x_party_rec.col51 := FND_API.g_miss_char;
      x_party_rec.col52 := FND_API.g_miss_char;
      x_party_rec.col53 := FND_API.g_miss_char;
      x_party_rec.col54 := FND_API.g_miss_char;
      x_party_rec.col55 := FND_API.g_miss_char;
      x_party_rec.col56 := FND_API.g_miss_char;
      x_party_rec.col57 := FND_API.g_miss_char;
      x_party_rec.col58 := FND_API.g_miss_char;
      x_party_rec.col59 := FND_API.g_miss_char;
      x_party_rec.col60 := FND_API.g_miss_char;
      x_party_rec.col61 := FND_API.g_miss_char;
      x_party_rec.col62 := FND_API.g_miss_char;
      x_party_rec.col63 := FND_API.g_miss_char;
      x_party_rec.col64 := FND_API.g_miss_char;
      x_party_rec.col65 := FND_API.g_miss_char;
      x_party_rec.col66 := FND_API.g_miss_char;
      x_party_rec.col67 := FND_API.g_miss_char;
      x_party_rec.col68 := FND_API.g_miss_char;
      x_party_rec.col69 := FND_API.g_miss_char;
      x_party_rec.col70 := FND_API.g_miss_char;
      x_party_rec.col71 := FND_API.g_miss_char;
      x_party_rec.col72 := FND_API.g_miss_char;
      x_party_rec.col73 := FND_API.g_miss_char;
      x_party_rec.col74 := FND_API.g_miss_char;
      x_party_rec.col75 := FND_API.g_miss_char;
      x_party_rec.col76 := FND_API.g_miss_char;
      x_party_rec.col77 := FND_API.g_miss_char;
      x_party_rec.col78 := FND_API.g_miss_char;
      x_party_rec.col79 := FND_API.g_miss_char;
      x_party_rec.col80 := FND_API.g_miss_char;
      x_party_rec.col81 := FND_API.g_miss_char;
      x_party_rec.col82 := FND_API.g_miss_char;
      x_party_rec.col83 := FND_API.g_miss_char;
      x_party_rec.col84 := FND_API.g_miss_char;
      x_party_rec.col85 := FND_API.g_miss_char;
      x_party_rec.col86 := FND_API.g_miss_char;
      x_party_rec.col87 := FND_API.g_miss_char;
      x_party_rec.col88 := FND_API.g_miss_char;
      x_party_rec.col89 := FND_API.g_miss_char;
      x_party_rec.col90 := FND_API.g_miss_char;
      x_party_rec.col91 := FND_API.g_miss_char;
      x_party_rec.col92 := FND_API.g_miss_char;
      x_party_rec.col93 := FND_API.g_miss_char;
      x_party_rec.col94 := FND_API.g_miss_char;
      x_party_rec.col95 := FND_API.g_miss_char;
      x_party_rec.col96 := FND_API.g_miss_char;
      x_party_rec.col97 := FND_API.g_miss_char;
      x_party_rec.col98 := FND_API.g_miss_char;
      x_party_rec.col99 := FND_API.g_miss_char;
      x_party_rec.col100 := FND_API.g_miss_char;
      x_party_rec.col101 := FND_API.g_miss_char;
      x_party_rec.col102 := FND_API.g_miss_char;
      x_party_rec.col103 := FND_API.g_miss_char;
      x_party_rec.col104 := FND_API.g_miss_char;
      x_party_rec.col105 := FND_API.g_miss_char;
      x_party_rec.col106 := FND_API.g_miss_char;
      x_party_rec.col107 := FND_API.g_miss_char;
      x_party_rec.col108 := FND_API.g_miss_char;
      x_party_rec.col109 := FND_API.g_miss_char;
      x_party_rec.col110 := FND_API.g_miss_char;
      x_party_rec.col111 := FND_API.g_miss_char;
      x_party_rec.col112 := FND_API.g_miss_char;
      x_party_rec.col113 := FND_API.g_miss_char;
      x_party_rec.col114 := FND_API.g_miss_char;
      x_party_rec.col115 := FND_API.g_miss_char;
      x_party_rec.col116 := FND_API.g_miss_char;
      x_party_rec.col117 := FND_API.g_miss_char;
      x_party_rec.col118 := FND_API.g_miss_char;
      x_party_rec.col119 := FND_API.g_miss_char;
      x_party_rec.col120 := FND_API.g_miss_char;
      x_party_rec.col121 := FND_API.g_miss_char;
      x_party_rec.col122 := FND_API.g_miss_char;
      x_party_rec.col123 := FND_API.g_miss_char;
      x_party_rec.col124 := FND_API.g_miss_char;
      x_party_rec.col125 := FND_API.g_miss_char;
      x_party_rec.col126 := FND_API.g_miss_char;
      x_party_rec.col127 := FND_API.g_miss_char;
      x_party_rec.col128 := FND_API.g_miss_char;
      x_party_rec.col129 := FND_API.g_miss_char;
      x_party_rec.col130 := FND_API.g_miss_char;
      x_party_rec.col131 := FND_API.g_miss_char;
      x_party_rec.col132 := FND_API.g_miss_char;
      x_party_rec.col133 := FND_API.g_miss_char;
      x_party_rec.col134 := FND_API.g_miss_char;
      x_party_rec.col135 := FND_API.g_miss_char;
      x_party_rec.col136 := FND_API.g_miss_char;
      x_party_rec.col137 := FND_API.g_miss_char;
      x_party_rec.col138 := FND_API.g_miss_char;
      x_party_rec.col139 := FND_API.g_miss_char;
      x_party_rec.col140 := FND_API.g_miss_char;
      x_party_rec.col141 := FND_API.g_miss_char;
      x_party_rec.col142 := FND_API.g_miss_char;
      x_party_rec.col143 := FND_API.g_miss_char;
      x_party_rec.col144 := FND_API.g_miss_char;
      x_party_rec.col145 := FND_API.g_miss_char;
      x_party_rec.col146 := FND_API.g_miss_char;
      x_party_rec.col147 := FND_API.g_miss_char;
      x_party_rec.col148 := FND_API.g_miss_char;
      x_party_rec.col149 := FND_API.g_miss_char;
      x_party_rec.col150 := FND_API.g_miss_char;
      x_party_rec.col151 := FND_API.g_miss_char;
      x_party_rec.col152 := FND_API.g_miss_char;
      x_party_rec.col153 := FND_API.g_miss_char;
      x_party_rec.col154 := FND_API.g_miss_char;
      x_party_rec.col155 := FND_API.g_miss_char;
      x_party_rec.col156 := FND_API.g_miss_char;
      x_party_rec.col157 := FND_API.g_miss_char;
      x_party_rec.col158 := FND_API.g_miss_char;
      x_party_rec.col159 := FND_API.g_miss_char;
      x_party_rec.col160 := FND_API.g_miss_char;
      x_party_rec.col161 := FND_API.g_miss_char;
      x_party_rec.col162 := FND_API.g_miss_char;
      x_party_rec.col163 := FND_API.g_miss_char;
      x_party_rec.col164 := FND_API.g_miss_char;
      x_party_rec.col165 := FND_API.g_miss_char;
      x_party_rec.col166 := FND_API.g_miss_char;
      x_party_rec.col167 := FND_API.g_miss_char;
      x_party_rec.col168 := FND_API.g_miss_char;
      x_party_rec.col169 := FND_API.g_miss_char;
      x_party_rec.col170 := FND_API.g_miss_char;
      x_party_rec.col171 := FND_API.g_miss_char;
      x_party_rec.col172 := FND_API.g_miss_char;
      x_party_rec.col173 := FND_API.g_miss_char;
      x_party_rec.col174 := FND_API.g_miss_char;
      x_party_rec.col175 := FND_API.g_miss_char;
      x_party_rec.col176 := FND_API.g_miss_char;
      x_party_rec.col177 := FND_API.g_miss_char;
      x_party_rec.col178 := FND_API.g_miss_char;
      x_party_rec.col179 := FND_API.g_miss_char;
      x_party_rec.col180 := FND_API.g_miss_char;
      x_party_rec.col181 := FND_API.g_miss_char;
      x_party_rec.col182 := FND_API.g_miss_char;
      x_party_rec.col183 := FND_API.g_miss_char;
      x_party_rec.col184 := FND_API.g_miss_char;
      x_party_rec.col185 := FND_API.g_miss_char;
      x_party_rec.col186 := FND_API.g_miss_char;
      x_party_rec.col187 := FND_API.g_miss_char;
      x_party_rec.col188 := FND_API.g_miss_char;
      x_party_rec.col189 := FND_API.g_miss_char;
      x_party_rec.col190 := FND_API.g_miss_char;
      x_party_rec.col191 := FND_API.g_miss_char;
      x_party_rec.col192 := FND_API.g_miss_char;
      x_party_rec.col193 := FND_API.g_miss_char;
      x_party_rec.col194 := FND_API.g_miss_char;
      x_party_rec.col195 := FND_API.g_miss_char;
      x_party_rec.col196 := FND_API.g_miss_char;
      x_party_rec.col197 := FND_API.g_miss_char;
      x_party_rec.col198 := FND_API.g_miss_char;
      x_party_rec.col199 := FND_API.g_miss_char;
      x_party_rec.col200 := FND_API.g_miss_char;
      x_party_rec.col201 := FND_API.g_miss_char;
      x_party_rec.col202 := FND_API.g_miss_char;
      x_party_rec.col203 := FND_API.g_miss_char;
      x_party_rec.col204 := FND_API.g_miss_char;
      x_party_rec.col205 := FND_API.g_miss_char;
      x_party_rec.col206 := FND_API.g_miss_char;
      x_party_rec.col207 := FND_API.g_miss_char;
      x_party_rec.col208 := FND_API.g_miss_char;
      x_party_rec.col209 := FND_API.g_miss_char;
      x_party_rec.col210 := FND_API.g_miss_char;
      x_party_rec.col211 := FND_API.g_miss_char;
      x_party_rec.col212 := FND_API.g_miss_char;
      x_party_rec.col213 := FND_API.g_miss_char;
      x_party_rec.col214 := FND_API.g_miss_char;
      x_party_rec.col215 := FND_API.g_miss_char;
      x_party_rec.col216 := FND_API.g_miss_char;
      x_party_rec.col217 := FND_API.g_miss_char;
      x_party_rec.col218 := FND_API.g_miss_char;
      x_party_rec.col219 := FND_API.g_miss_char;
      x_party_rec.col220 := FND_API.g_miss_char;
      x_party_rec.col221 := FND_API.g_miss_char;
      x_party_rec.col222 := FND_API.g_miss_char;
      x_party_rec.col223 := FND_API.g_miss_char;
      x_party_rec.col224 := FND_API.g_miss_char;
      x_party_rec.col225 := FND_API.g_miss_char;
      x_party_rec.col226 := FND_API.g_miss_char;
      x_party_rec.col227 := FND_API.g_miss_char;
      x_party_rec.col228 := FND_API.g_miss_char;
      x_party_rec.col229 := FND_API.g_miss_char;
      x_party_rec.col230 := FND_API.g_miss_char;
      x_party_rec.col231 := FND_API.g_miss_char;
      x_party_rec.col232 := FND_API.g_miss_char;
      x_party_rec.col233 := FND_API.g_miss_char;
      x_party_rec.col234 := FND_API.g_miss_char;
      x_party_rec.col235 := FND_API.g_miss_char;
      x_party_rec.col236 := FND_API.g_miss_char;
      x_party_rec.col237 := FND_API.g_miss_char;
      x_party_rec.col238 := FND_API.g_miss_char;
      x_party_rec.col239 := FND_API.g_miss_char;
      x_party_rec.col240 := FND_API.g_miss_char;
      x_party_rec.col241 := FND_API.g_miss_char;
      x_party_rec.col242 := FND_API.g_miss_char;
      x_party_rec.col243 := FND_API.g_miss_char;
      x_party_rec.col244 := FND_API.g_miss_char;
      x_party_rec.col245 := FND_API.g_miss_char;
      x_party_rec.col246 := FND_API.g_miss_char;
      x_party_rec.col247 := FND_API.g_miss_char;
      x_party_rec.col248 := FND_API.g_miss_char;
      x_party_rec.col249 := FND_API.g_miss_char;
      x_party_rec.col250 := FND_API.g_miss_char;
END Init_Party_Rec;


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Party_Rec
--
-- PURPOSE
--    Fill in the columns which did not get passed into the
--    update API, so the "g_miss" columns don't change from
--    the values in the database.
--
-- HISTORY
-- 08-Nov-1999 choang      Created.
---------------------------------------------------------------------
PROCEDURE Complete_Party_Rec (
   p_party_rec      IN  Party_Rec_Type,
   x_complete_rec   OUT NOCOPY Party_Rec_Type
)
IS
   CURSOR c_party IS
      SELECT *
      FROM   ams_party_sources
      WHERE  party_sources_id = p_party_rec.party_sources_id;

   l_party_rec     c_party%ROWTYPE;
BEGIN
   x_complete_rec := p_party_rec;

   --
   -- Fetch the values which are in the database.
   OPEN c_party;
   FETCH c_party INTO l_party_rec;
   IF c_party%NOTFOUND THEN
      CLOSE c_party;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_party;

   --
   -- party_sources_id
   IF p_party_rec.party_sources_id = FND_API.g_miss_num THEN
      x_complete_rec.party_sources_id := l_party_rec.party_sources_id;
   END IF;

   -- party_id
   IF p_party_rec.party_id = FND_API.g_miss_num THEN
      x_complete_rec.party_id := l_party_rec.party_id;
   END IF;

   -- import_source_line_id
   IF p_party_rec.import_source_line_id = FND_API.g_miss_num THEN
      x_complete_rec.import_source_line_id := l_party_rec.import_source_line_id;
   END IF;

   -- object_version_number
   IF p_party_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_party_rec.object_version_number;
   END IF;

   -- last_update_date
   IF p_party_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_party_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_party_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_party_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_party_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_party_rec.creation_date;
   END IF;

   -- created_by
   IF p_party_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_party_rec.created_by;
   END IF;

   -- last_update_login
   IF p_party_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_party_rec.last_update_login;
   END IF;

   -- import_list_header_id
   IF p_party_rec.import_list_header_id = FND_API.g_miss_num THEN
      x_complete_rec.import_list_header_id := l_party_rec.import_list_header_id;
   END IF;

   -- list_source_type_id
   IF p_party_rec.list_source_type_id = FND_API.g_miss_num THEN
      x_complete_rec.list_source_type_id := l_party_rec.list_source_type_id;
   END IF;

   -- used_flag
   IF p_party_rec.used_flag = FND_API.g_miss_char THEN
      x_complete_rec.used_flag := l_party_rec.used_flag;
   END IF;

   -- overlay_flag
   IF p_party_rec.overlay_flag = FND_API.g_miss_char THEN
      x_complete_rec.overlay_flag := l_party_rec.overlay_flag;
   END IF;

   -- overlay_date
   IF p_party_rec.overlay_date = FND_API.g_miss_date THEN
      x_complete_rec.overlay_date := l_party_rec.overlay_date;
   END IF;

   -- col1
   IF p_party_rec.col1 = FND_API.g_miss_char THEN
      x_complete_rec.col1 := l_party_rec.col1;
   END IF;

   -- col2
   IF p_party_rec.col2 = FND_API.g_miss_char THEN
      x_complete_rec.col2 := l_party_rec.col2;
   END IF;

   -- col3
   IF p_party_rec.col3 = FND_API.g_miss_char THEN
      x_complete_rec.col3 := l_party_rec.col3;
   END IF;

   -- col4
   IF p_party_rec.col4 = FND_API.g_miss_char THEN
      x_complete_rec.col4 := l_party_rec.col4;
   END IF;

   -- col5
   IF p_party_rec.col5 = FND_API.g_miss_char THEN
      x_complete_rec.col5 := l_party_rec.col5;
   END IF;

   -- col6
   IF p_party_rec.col6 = FND_API.g_miss_char THEN
      x_complete_rec.col6 := l_party_rec.col6;
   END IF;

   -- col7
   IF p_party_rec.col7 = FND_API.g_miss_char THEN
      x_complete_rec.col7 := l_party_rec.col7;
   END IF;

   -- col8
   IF p_party_rec.col8 = FND_API.g_miss_char THEN
      x_complete_rec.col8 := l_party_rec.col8;
   END IF;

   -- col9
   IF p_party_rec.col9 = FND_API.g_miss_char THEN
      x_complete_rec.col9 := l_party_rec.col9;
   END IF;

   -- col10
   IF p_party_rec.col10 = FND_API.g_miss_char THEN
      x_complete_rec.col10 := l_party_rec.col10;
   END IF;

   -- col11
   IF p_party_rec.col11 = FND_API.g_miss_char THEN
      x_complete_rec.col11 := l_party_rec.col11;
   END IF;

   -- col12
   IF p_party_rec.col12 = FND_API.g_miss_char THEN
      x_complete_rec.col12 := l_party_rec.col12;
   END IF;

   -- col13
   IF p_party_rec.col13 = FND_API.g_miss_char THEN
      x_complete_rec.col13 := l_party_rec.col13;
   END IF;

   -- col14
   IF p_party_rec.col14 = FND_API.g_miss_char THEN
      x_complete_rec.col14 := l_party_rec.col14;
   END IF;

   -- col15
   IF p_party_rec.col15 = FND_API.g_miss_char THEN
      x_complete_rec.col15 := l_party_rec.col15;
   END IF;

   -- col16
   IF p_party_rec.col16 = FND_API.g_miss_char THEN
      x_complete_rec.col16 := l_party_rec.col16;
   END IF;

   -- col17
   IF p_party_rec.col17 = FND_API.g_miss_char THEN
      x_complete_rec.col17 := l_party_rec.col17;
   END IF;

   -- col18
   IF p_party_rec.col18 = FND_API.g_miss_char THEN
      x_complete_rec.col18 := l_party_rec.col18;
   END IF;

   -- col19
   IF p_party_rec.col19 = FND_API.g_miss_char THEN
      x_complete_rec.col19 := l_party_rec.col19;
   END IF;

   -- col20
   IF p_party_rec.col20 = FND_API.g_miss_char THEN
      x_complete_rec.col20 := l_party_rec.col20;
   END IF;

   -- col21
   IF p_party_rec.col21 = FND_API.g_miss_char THEN
      x_complete_rec.col21 := l_party_rec.col21;
   END IF;

   -- col22
   IF p_party_rec.col22 = FND_API.g_miss_char THEN
      x_complete_rec.col22 := l_party_rec.col22;
   END IF;

   -- col23
   IF p_party_rec.col23 = FND_API.g_miss_char THEN
      x_complete_rec.col23 := l_party_rec.col23;
   END IF;

   -- col24
   IF p_party_rec.col24 = FND_API.g_miss_char THEN
      x_complete_rec.col24 := l_party_rec.col24;
   END IF;

   -- col25
   IF p_party_rec.col25 = FND_API.g_miss_char THEN
      x_complete_rec.col25 := l_party_rec.col25;
   END IF;

   -- col26
   IF p_party_rec.col26 = FND_API.g_miss_char THEN
      x_complete_rec.col26 := l_party_rec.col26;
   END IF;

   -- col27
   IF p_party_rec.col27 = FND_API.g_miss_char THEN
      x_complete_rec.col27 := l_party_rec.col27;
   END IF;

   -- col28
   IF p_party_rec.col28 = FND_API.g_miss_char THEN
      x_complete_rec.col28 := l_party_rec.col28;
   END IF;

   -- col29
   IF p_party_rec.col29 = FND_API.g_miss_char THEN
      x_complete_rec.col29 := l_party_rec.col29;
   END IF;

   -- col30
   IF p_party_rec.col30 = FND_API.g_miss_char THEN
      x_complete_rec.col30 := l_party_rec.col30;
   END IF;

   -- col31
   IF p_party_rec.col31 = FND_API.g_miss_char THEN
      x_complete_rec.col31 := l_party_rec.col31;
   END IF;

   -- col32
   IF p_party_rec.col32 = FND_API.g_miss_char THEN
      x_complete_rec.col32 := l_party_rec.col32;
   END IF;

   -- col33
   IF p_party_rec.col33 = FND_API.g_miss_char THEN
      x_complete_rec.col33 := l_party_rec.col33;
   END IF;

   -- col34
   IF p_party_rec.col34 = FND_API.g_miss_char THEN
      x_complete_rec.col34 := l_party_rec.col34;
   END IF;

   -- col35
   IF p_party_rec.col35 = FND_API.g_miss_char THEN
      x_complete_rec.col35 := l_party_rec.col35;
   END IF;

   -- col36
   IF p_party_rec.col36 = FND_API.g_miss_char THEN
      x_complete_rec.col36 := l_party_rec.col36;
   END IF;

   -- col37
   IF p_party_rec.col37 = FND_API.g_miss_char THEN
      x_complete_rec.col37 := l_party_rec.col37;
   END IF;

   -- col38
   IF p_party_rec.col38 = FND_API.g_miss_char THEN
      x_complete_rec.col38 := l_party_rec.col38;
   END IF;

   -- col39
   IF p_party_rec.col39 = FND_API.g_miss_char THEN
      x_complete_rec.col39 := l_party_rec.col39;
   END IF;

   -- col40
   IF p_party_rec.col40 = FND_API.g_miss_char THEN
      x_complete_rec.col40 := l_party_rec.col40;
   END IF;

   -- col41
   IF p_party_rec.col41 = FND_API.g_miss_char THEN
      x_complete_rec.col41 := l_party_rec.col41;
   END IF;

   -- col42
   IF p_party_rec.col42 = FND_API.g_miss_char THEN
      x_complete_rec.col42 := l_party_rec.col42;
   END IF;

   -- col43
   IF p_party_rec.col43 = FND_API.g_miss_char THEN
      x_complete_rec.col43 := l_party_rec.col43;
   END IF;

   -- col44
   IF p_party_rec.col44 = FND_API.g_miss_char THEN
      x_complete_rec.col44 := l_party_rec.col44;
   END IF;

   -- col45
   IF p_party_rec.col45 = FND_API.g_miss_char THEN
      x_complete_rec.col45 := l_party_rec.col45;
   END IF;

   -- col46
   IF p_party_rec.col46 = FND_API.g_miss_char THEN
      x_complete_rec.col46 := l_party_rec.col46;
   END IF;

   -- col47
   IF p_party_rec.col47 = FND_API.g_miss_char THEN
      x_complete_rec.col47 := l_party_rec.col47;
   END IF;

   -- col48
   IF p_party_rec.col48 = FND_API.g_miss_char THEN
      x_complete_rec.col48 := l_party_rec.col48;
   END IF;

   -- col49
   IF p_party_rec.col49 = FND_API.g_miss_char THEN
      x_complete_rec.col49 := l_party_rec.col49;
   END IF;

   -- col50
   IF p_party_rec.col50 = FND_API.g_miss_char THEN
      x_complete_rec.col50 := l_party_rec.col50;
   END IF;

   -- col51
   IF p_party_rec.col51 = FND_API.g_miss_char THEN
      x_complete_rec.col51 := l_party_rec.col51;
   END IF;

   -- col52
   IF p_party_rec.col52 = FND_API.g_miss_char THEN
      x_complete_rec.col52 := l_party_rec.col52;
   END IF;

   -- col53
   IF p_party_rec.col53 = FND_API.g_miss_char THEN
      x_complete_rec.col53 := l_party_rec.col53;
   END IF;

   -- col54
   IF p_party_rec.col54 = FND_API.g_miss_char THEN
      x_complete_rec.col54 := l_party_rec.col54;
   END IF;

   -- col55
   IF p_party_rec.col55 = FND_API.g_miss_char THEN
      x_complete_rec.col55 := l_party_rec.col55;
   END IF;

   -- col56
   IF p_party_rec.col56 = FND_API.g_miss_char THEN
      x_complete_rec.col56 := l_party_rec.col56;
   END IF;

   -- col57
   IF p_party_rec.col57 = FND_API.g_miss_char THEN
      x_complete_rec.col57 := l_party_rec.col57;
   END IF;

   -- col58
   IF p_party_rec.col58 = FND_API.g_miss_char THEN
      x_complete_rec.col58 := l_party_rec.col58;
   END IF;

   -- col59
   IF p_party_rec.col59 = FND_API.g_miss_char THEN
      x_complete_rec.col59 := l_party_rec.col59;
   END IF;

   -- col60
   IF p_party_rec.col60 = FND_API.g_miss_char THEN
      x_complete_rec.col60 := l_party_rec.col60;
   END IF;

   -- col61
   IF p_party_rec.col61 = FND_API.g_miss_char THEN
      x_complete_rec.col61 := l_party_rec.col61;
   END IF;

   -- col62
   IF p_party_rec.col62 = FND_API.g_miss_char THEN
      x_complete_rec.col62 := l_party_rec.col62;
   END IF;

   -- col63
   IF p_party_rec.col63 = FND_API.g_miss_char THEN
      x_complete_rec.col63 := l_party_rec.col63;
   END IF;

   -- col64
   IF p_party_rec.col64 = FND_API.g_miss_char THEN
      x_complete_rec.col64 := l_party_rec.col64;
   END IF;

   -- col65
   IF p_party_rec.col65 = FND_API.g_miss_char THEN
      x_complete_rec.col65 := l_party_rec.col65;
   END IF;

   -- col66
   IF p_party_rec.col66 = FND_API.g_miss_char THEN
      x_complete_rec.col66 := l_party_rec.col66;
   END IF;

   -- col67
   IF p_party_rec.col67 = FND_API.g_miss_char THEN
      x_complete_rec.col67 := l_party_rec.col67;
   END IF;

   -- col68
   IF p_party_rec.col68 = FND_API.g_miss_char THEN
      x_complete_rec.col68 := l_party_rec.col68;
   END IF;

   -- col69
   IF p_party_rec.col69 = FND_API.g_miss_char THEN
      x_complete_rec.col69 := l_party_rec.col69;
   END IF;

   -- col70
   IF p_party_rec.col70 = FND_API.g_miss_char THEN
      x_complete_rec.col70 := l_party_rec.col70;
   END IF;

   -- col71
   IF p_party_rec.col71 = FND_API.g_miss_char THEN
      x_complete_rec.col71 := l_party_rec.col71;
   END IF;

   -- col72
   IF p_party_rec.col72 = FND_API.g_miss_char THEN
      x_complete_rec.col72 := l_party_rec.col72;
   END IF;

   -- col73
   IF p_party_rec.col73 = FND_API.g_miss_char THEN
      x_complete_rec.col73 := l_party_rec.col73;
   END IF;

   -- col74
   IF p_party_rec.col74 = FND_API.g_miss_char THEN
      x_complete_rec.col74 := l_party_rec.col74;
   END IF;

   -- col75
   IF p_party_rec.col75 = FND_API.g_miss_char THEN
      x_complete_rec.col75 := l_party_rec.col75;
   END IF;

   -- col76
   IF p_party_rec.col76 = FND_API.g_miss_char THEN
      x_complete_rec.col76 := l_party_rec.col76;
   END IF;

   -- col77
   IF p_party_rec.col77 = FND_API.g_miss_char THEN
      x_complete_rec.col77 := l_party_rec.col77;
   END IF;

   -- col78
   IF p_party_rec.col78 = FND_API.g_miss_char THEN
      x_complete_rec.col78 := l_party_rec.col78;
   END IF;

   -- col79
   IF p_party_rec.col79 = FND_API.g_miss_char THEN
      x_complete_rec.col79 := l_party_rec.col79;
   END IF;

   -- col80
   IF p_party_rec.col80 = FND_API.g_miss_char THEN
      x_complete_rec.col80 := l_party_rec.col80;
   END IF;

   -- col81
   IF p_party_rec.col81 = FND_API.g_miss_char THEN
      x_complete_rec.col81 := l_party_rec.col81;
   END IF;

   -- col82
   IF p_party_rec.col82 = FND_API.g_miss_char THEN
      x_complete_rec.col82 := l_party_rec.col82;
   END IF;

   -- col83
   IF p_party_rec.col83 = FND_API.g_miss_char THEN
      x_complete_rec.col83 := l_party_rec.col83;
   END IF;

   -- col84
   IF p_party_rec.col84 = FND_API.g_miss_char THEN
      x_complete_rec.col84 := l_party_rec.col84;
   END IF;

   -- col85
   IF p_party_rec.col85 = FND_API.g_miss_char THEN
      x_complete_rec.col85 := l_party_rec.col85;
   END IF;

   -- col86
   IF p_party_rec.col86 = FND_API.g_miss_char THEN
      x_complete_rec.col86 := l_party_rec.col86;
   END IF;

   -- col87
   IF p_party_rec.col87 = FND_API.g_miss_char THEN
      x_complete_rec.col87 := l_party_rec.col87;
   END IF;

   -- col88
   IF p_party_rec.col88 = FND_API.g_miss_char THEN
      x_complete_rec.col88 := l_party_rec.col88;
   END IF;

   -- col89
   IF p_party_rec.col89 = FND_API.g_miss_char THEN
      x_complete_rec.col89 := l_party_rec.col89;
   END IF;

   -- col90
   IF p_party_rec.col90 = FND_API.g_miss_char THEN
      x_complete_rec.col90 := l_party_rec.col90;
   END IF;

   -- col91
   IF p_party_rec.col91 = FND_API.g_miss_char THEN
      x_complete_rec.col91 := l_party_rec.col91;
   END IF;

   -- col92
   IF p_party_rec.col92 = FND_API.g_miss_char THEN
      x_complete_rec.col92 := l_party_rec.col92;
   END IF;

   -- col93
   IF p_party_rec.col93 = FND_API.g_miss_char THEN
      x_complete_rec.col93 := l_party_rec.col93;
   END IF;

   -- col94
   IF p_party_rec.col94 = FND_API.g_miss_char THEN
      x_complete_rec.col94 := l_party_rec.col94;
   END IF;

   -- col95
   IF p_party_rec.col95 = FND_API.g_miss_char THEN
      x_complete_rec.col95 := l_party_rec.col95;
   END IF;

   -- col96
   IF p_party_rec.col96 = FND_API.g_miss_char THEN
      x_complete_rec.col96 := l_party_rec.col96;
   END IF;

   -- col97
   IF p_party_rec.col97 = FND_API.g_miss_char THEN
      x_complete_rec.col97 := l_party_rec.col97;
   END IF;

   -- col98
   IF p_party_rec.col98 = FND_API.g_miss_char THEN
      x_complete_rec.col98 := l_party_rec.col98;
   END IF;

   -- col99
   IF p_party_rec.col99 = FND_API.g_miss_char THEN
      x_complete_rec.col99 := l_party_rec.col99;
   END IF;

   -- col100
   IF p_party_rec.col100 = FND_API.g_miss_char THEN
      x_complete_rec.col100 := l_party_rec.col100;
   END IF;

   -- col101
   IF p_party_rec.col101 = FND_API.g_miss_char THEN
      x_complete_rec.col101 := l_party_rec.col101;
   END IF;

   -- col102
   IF p_party_rec.col102 = FND_API.g_miss_char THEN
      x_complete_rec.col102 := l_party_rec.col102;
   END IF;

   -- col103
   IF p_party_rec.col103 = FND_API.g_miss_char THEN
      x_complete_rec.col103 := l_party_rec.col103;
   END IF;

   -- col104
   IF p_party_rec.col104 = FND_API.g_miss_char THEN
      x_complete_rec.col104 := l_party_rec.col104;
   END IF;

   -- col105
   IF p_party_rec.col105 = FND_API.g_miss_char THEN
      x_complete_rec.col105 := l_party_rec.col105;
   END IF;

   -- col106
   IF p_party_rec.col106 = FND_API.g_miss_char THEN
      x_complete_rec.col106 := l_party_rec.col106;
   END IF;

   -- col107
   IF p_party_rec.col107 = FND_API.g_miss_char THEN
      x_complete_rec.col107 := l_party_rec.col107;
   END IF;

   -- col108
   IF p_party_rec.col108 = FND_API.g_miss_char THEN
      x_complete_rec.col108 := l_party_rec.col108;
   END IF;

   -- col109
   IF p_party_rec.col109 = FND_API.g_miss_char THEN
      x_complete_rec.col109 := l_party_rec.col109;
   END IF;

   -- col110
   IF p_party_rec.col110 = FND_API.g_miss_char THEN
      x_complete_rec.col110 := l_party_rec.col110;
   END IF;

   -- col111
   IF p_party_rec.col111 = FND_API.g_miss_char THEN
      x_complete_rec.col111 := l_party_rec.col111;
   END IF;

   -- col112
   IF p_party_rec.col112 = FND_API.g_miss_char THEN
      x_complete_rec.col112 := l_party_rec.col112;
   END IF;

   -- col113
   IF p_party_rec.col113 = FND_API.g_miss_char THEN
      x_complete_rec.col113 := l_party_rec.col113;
   END IF;

   -- col114
   IF p_party_rec.col114 = FND_API.g_miss_char THEN
      x_complete_rec.col114 := l_party_rec.col114;
   END IF;

   -- col115
   IF p_party_rec.col115 = FND_API.g_miss_char THEN
      x_complete_rec.col115 := l_party_rec.col115;
   END IF;

   -- col116
   IF p_party_rec.col116 = FND_API.g_miss_char THEN
      x_complete_rec.col116 := l_party_rec.col116;
   END IF;

   -- col117
   IF p_party_rec.col117 = FND_API.g_miss_char THEN
      x_complete_rec.col117 := l_party_rec.col117;
   END IF;

   -- col118
   IF p_party_rec.col118 = FND_API.g_miss_char THEN
      x_complete_rec.col118 := l_party_rec.col118;
   END IF;

   -- col119
   IF p_party_rec.col119 = FND_API.g_miss_char THEN
      x_complete_rec.col119 := l_party_rec.col119;
   END IF;

   -- col120
   IF p_party_rec.col120 = FND_API.g_miss_char THEN
      x_complete_rec.col120 := l_party_rec.col120;
   END IF;

   -- col121
   IF p_party_rec.col121 = FND_API.g_miss_char THEN
      x_complete_rec.col121 := l_party_rec.col121;
   END IF;

   -- col122
   IF p_party_rec.col122 = FND_API.g_miss_char THEN
      x_complete_rec.col122 := l_party_rec.col122;
   END IF;

   -- col123
   IF p_party_rec.col123 = FND_API.g_miss_char THEN
      x_complete_rec.col123 := l_party_rec.col123;
   END IF;

   -- col124
   IF p_party_rec.col124 = FND_API.g_miss_char THEN
      x_complete_rec.col124 := l_party_rec.col124;
   END IF;

   -- col125
   IF p_party_rec.col125 = FND_API.g_miss_char THEN
      x_complete_rec.col125 := l_party_rec.col125;
   END IF;

   -- col126
   IF p_party_rec.col126 = FND_API.g_miss_char THEN
      x_complete_rec.col126 := l_party_rec.col126;
   END IF;

   -- col127
   IF p_party_rec.col127 = FND_API.g_miss_char THEN
      x_complete_rec.col127 := l_party_rec.col127;
   END IF;

   -- col128
   IF p_party_rec.col128 = FND_API.g_miss_char THEN
      x_complete_rec.col128 := l_party_rec.col128;
   END IF;

   -- col129
   IF p_party_rec.col129 = FND_API.g_miss_char THEN
      x_complete_rec.col129 := l_party_rec.col129;
   END IF;

   -- col130
   IF p_party_rec.col130 = FND_API.g_miss_char THEN
      x_complete_rec.col130 := l_party_rec.col130;
   END IF;

   -- col131
   IF p_party_rec.col131 = FND_API.g_miss_char THEN
      x_complete_rec.col131 := l_party_rec.col131;
   END IF;

   -- col132
   IF p_party_rec.col132 = FND_API.g_miss_char THEN
      x_complete_rec.col132 := l_party_rec.col132;
   END IF;

   -- col133
   IF p_party_rec.col133 = FND_API.g_miss_char THEN
      x_complete_rec.col133 := l_party_rec.col133;
   END IF;

   -- col134
   IF p_party_rec.col134 = FND_API.g_miss_char THEN
      x_complete_rec.col134 := l_party_rec.col134;
   END IF;

   -- col135
   IF p_party_rec.col135 = FND_API.g_miss_char THEN
      x_complete_rec.col135 := l_party_rec.col135;
   END IF;

   -- col136
   IF p_party_rec.col136 = FND_API.g_miss_char THEN
      x_complete_rec.col136 := l_party_rec.col136;
   END IF;

   -- col137
   IF p_party_rec.col137 = FND_API.g_miss_char THEN
      x_complete_rec.col137 := l_party_rec.col137;
   END IF;

   -- col138
   IF p_party_rec.col138 = FND_API.g_miss_char THEN
      x_complete_rec.col138 := l_party_rec.col138;
   END IF;

   -- col139
   IF p_party_rec.col139 = FND_API.g_miss_char THEN
      x_complete_rec.col139 := l_party_rec.col139;
   END IF;

   -- col140
   IF p_party_rec.col140 = FND_API.g_miss_char THEN
      x_complete_rec.col140 := l_party_rec.col140;
   END IF;

   -- col141
   IF p_party_rec.col141 = FND_API.g_miss_char THEN
      x_complete_rec.col141 := l_party_rec.col141;
   END IF;

   -- col142
   IF p_party_rec.col142 = FND_API.g_miss_char THEN
      x_complete_rec.col142 := l_party_rec.col142;
   END IF;

   -- col143
   IF p_party_rec.col143 = FND_API.g_miss_char THEN
      x_complete_rec.col143 := l_party_rec.col143;
   END IF;

   -- col144
   IF p_party_rec.col144 = FND_API.g_miss_char THEN
      x_complete_rec.col144 := l_party_rec.col144;
   END IF;

   -- col145
   IF p_party_rec.col145 = FND_API.g_miss_char THEN
      x_complete_rec.col145 := l_party_rec.col145;
   END IF;

   -- col146
   IF p_party_rec.col146 = FND_API.g_miss_char THEN
      x_complete_rec.col146 := l_party_rec.col146;
   END IF;

   -- col147
   IF p_party_rec.col147 = FND_API.g_miss_char THEN
      x_complete_rec.col147 := l_party_rec.col147;
   END IF;

   -- col148
   IF p_party_rec.col148 = FND_API.g_miss_char THEN
      x_complete_rec.col148 := l_party_rec.col148;
   END IF;

   -- col149
   IF p_party_rec.col149 = FND_API.g_miss_char THEN
      x_complete_rec.col149 := l_party_rec.col149;
   END IF;

   -- col150
   IF p_party_rec.col150 = FND_API.g_miss_char THEN
      x_complete_rec.col150 := l_party_rec.col150;
   END IF;

   -- col151
   IF p_party_rec.col151 = FND_API.g_miss_char THEN
      x_complete_rec.col151 := l_party_rec.col151;
   END IF;

   -- col152
   IF p_party_rec.col152 = FND_API.g_miss_char THEN
      x_complete_rec.col152 := l_party_rec.col152;
   END IF;

   -- col153
   IF p_party_rec.col153 = FND_API.g_miss_char THEN
      x_complete_rec.col153 := l_party_rec.col153;
   END IF;

   -- col154
   IF p_party_rec.col154 = FND_API.g_miss_char THEN
      x_complete_rec.col154 := l_party_rec.col154;
   END IF;

   -- col155
   IF p_party_rec.col155 = FND_API.g_miss_char THEN
      x_complete_rec.col155 := l_party_rec.col155;
   END IF;

   -- col156
   IF p_party_rec.col156 = FND_API.g_miss_char THEN
      x_complete_rec.col156 := l_party_rec.col156;
   END IF;

   -- col157
   IF p_party_rec.col157 = FND_API.g_miss_char THEN
      x_complete_rec.col157 := l_party_rec.col157;
   END IF;

   -- col158
   IF p_party_rec.col158 = FND_API.g_miss_char THEN
      x_complete_rec.col158 := l_party_rec.col158;
   END IF;

   -- col159
   IF p_party_rec.col159 = FND_API.g_miss_char THEN
      x_complete_rec.col159 := l_party_rec.col159;
   END IF;

   -- col160
   IF p_party_rec.col160 = FND_API.g_miss_char THEN
      x_complete_rec.col160 := l_party_rec.col160;
   END IF;

   -- col161
   IF p_party_rec.col161 = FND_API.g_miss_char THEN
      x_complete_rec.col161 := l_party_rec.col161;
   END IF;

   -- col162
   IF p_party_rec.col162 = FND_API.g_miss_char THEN
      x_complete_rec.col162 := l_party_rec.col162;
   END IF;

   -- col163
   IF p_party_rec.col163 = FND_API.g_miss_char THEN
      x_complete_rec.col163 := l_party_rec.col163;
   END IF;

   -- col164
   IF p_party_rec.col164 = FND_API.g_miss_char THEN
      x_complete_rec.col164 := l_party_rec.col164;
   END IF;

   -- col165
   IF p_party_rec.col165 = FND_API.g_miss_char THEN
      x_complete_rec.col165 := l_party_rec.col165;
   END IF;

   -- col166
   IF p_party_rec.col166 = FND_API.g_miss_char THEN
      x_complete_rec.col166 := l_party_rec.col166;
   END IF;

   -- col167
   IF p_party_rec.col167 = FND_API.g_miss_char THEN
      x_complete_rec.col167 := l_party_rec.col167;
   END IF;

   -- col168
   IF p_party_rec.col168 = FND_API.g_miss_char THEN
      x_complete_rec.col168 := l_party_rec.col168;
   END IF;

   -- col169
   IF p_party_rec.col169 = FND_API.g_miss_char THEN
      x_complete_rec.col169 := l_party_rec.col169;
   END IF;

   -- col170
   IF p_party_rec.col170 = FND_API.g_miss_char THEN
      x_complete_rec.col170 := l_party_rec.col170;
   END IF;

   -- col171
   IF p_party_rec.col171 = FND_API.g_miss_char THEN
      x_complete_rec.col171 := l_party_rec.col171;
   END IF;

   -- col172
   IF p_party_rec.col172 = FND_API.g_miss_char THEN
      x_complete_rec.col172 := l_party_rec.col172;
   END IF;

   -- col173
   IF p_party_rec.col173 = FND_API.g_miss_char THEN
      x_complete_rec.col173 := l_party_rec.col173;
   END IF;

   -- col174
   IF p_party_rec.col174 = FND_API.g_miss_char THEN
      x_complete_rec.col174 := l_party_rec.col174;
   END IF;

   -- col175
   IF p_party_rec.col175 = FND_API.g_miss_char THEN
      x_complete_rec.col175 := l_party_rec.col175;
   END IF;

   -- col176
   IF p_party_rec.col176 = FND_API.g_miss_char THEN
      x_complete_rec.col176 := l_party_rec.col176;
   END IF;

   -- col177
   IF p_party_rec.col177 = FND_API.g_miss_char THEN
      x_complete_rec.col177 := l_party_rec.col177;
   END IF;

   -- col178
   IF p_party_rec.col178 = FND_API.g_miss_char THEN
      x_complete_rec.col178 := l_party_rec.col178;
   END IF;

   -- col179
   IF p_party_rec.col179 = FND_API.g_miss_char THEN
      x_complete_rec.col179 := l_party_rec.col179;
   END IF;

   -- col180
   IF p_party_rec.col180 = FND_API.g_miss_char THEN
      x_complete_rec.col180 := l_party_rec.col180;
   END IF;

   -- col181
   IF p_party_rec.col181 = FND_API.g_miss_char THEN
      x_complete_rec.col181 := l_party_rec.col181;
   END IF;

   -- col182
   IF p_party_rec.col182 = FND_API.g_miss_char THEN
      x_complete_rec.col182 := l_party_rec.col182;
   END IF;

   -- col183
   IF p_party_rec.col183 = FND_API.g_miss_char THEN
      x_complete_rec.col183 := l_party_rec.col183;
   END IF;

   -- col184
   IF p_party_rec.col184 = FND_API.g_miss_char THEN
      x_complete_rec.col184 := l_party_rec.col184;
   END IF;

   -- col185
   IF p_party_rec.col185 = FND_API.g_miss_char THEN
      x_complete_rec.col185 := l_party_rec.col185;
   END IF;

   -- col186
   IF p_party_rec.col186 = FND_API.g_miss_char THEN
      x_complete_rec.col186 := l_party_rec.col186;
   END IF;

   -- col187
   IF p_party_rec.col187 = FND_API.g_miss_char THEN
      x_complete_rec.col187 := l_party_rec.col187;
   END IF;

   -- col188
   IF p_party_rec.col188 = FND_API.g_miss_char THEN
      x_complete_rec.col188 := l_party_rec.col188;
   END IF;

   -- col189
   IF p_party_rec.col189 = FND_API.g_miss_char THEN
      x_complete_rec.col189 := l_party_rec.col189;
   END IF;

   -- col190
   IF p_party_rec.col190 = FND_API.g_miss_char THEN
      x_complete_rec.col190 := l_party_rec.col190;
   END IF;

   -- col191
   IF p_party_rec.col191 = FND_API.g_miss_char THEN
      x_complete_rec.col191 := l_party_rec.col191;
   END IF;

   -- col192
   IF p_party_rec.col192 = FND_API.g_miss_char THEN
      x_complete_rec.col192 := l_party_rec.col192;
   END IF;

   -- col193
   IF p_party_rec.col193 = FND_API.g_miss_char THEN
      x_complete_rec.col193 := l_party_rec.col193;
   END IF;

   -- col194
   IF p_party_rec.col194 = FND_API.g_miss_char THEN
      x_complete_rec.col194 := l_party_rec.col194;
   END IF;

   -- col195
   IF p_party_rec.col195 = FND_API.g_miss_char THEN
      x_complete_rec.col195 := l_party_rec.col195;
   END IF;

   -- col196
   IF p_party_rec.col196 = FND_API.g_miss_char THEN
      x_complete_rec.col196 := l_party_rec.col196;
   END IF;

   -- col197
   IF p_party_rec.col197 = FND_API.g_miss_char THEN
      x_complete_rec.col197 := l_party_rec.col197;
   END IF;

   -- col198
   IF p_party_rec.col198 = FND_API.g_miss_char THEN
      x_complete_rec.col198 := l_party_rec.col198;
   END IF;

   -- col199
   IF p_party_rec.col199 = FND_API.g_miss_char THEN
      x_complete_rec.col199 := l_party_rec.col199;
   END IF;

   -- col200
   IF p_party_rec.col200 = FND_API.g_miss_char THEN
      x_complete_rec.col200 := l_party_rec.col200;
   END IF;

   -- col201
   IF p_party_rec.col201 = FND_API.g_miss_char THEN
      x_complete_rec.col201 := l_party_rec.col201;
   END IF;

   -- col202
   IF p_party_rec.col202 = FND_API.g_miss_char THEN
      x_complete_rec.col202 := l_party_rec.col202;
   END IF;

   -- col203
   IF p_party_rec.col203 = FND_API.g_miss_char THEN
      x_complete_rec.col203 := l_party_rec.col203;
   END IF;

   -- col204
   IF p_party_rec.col204 = FND_API.g_miss_char THEN
      x_complete_rec.col204 := l_party_rec.col204;
   END IF;

   -- col205
   IF p_party_rec.col205 = FND_API.g_miss_char THEN
      x_complete_rec.col205 := l_party_rec.col205;
   END IF;

   -- col206
   IF p_party_rec.col206 = FND_API.g_miss_char THEN
      x_complete_rec.col206 := l_party_rec.col206;
   END IF;

   -- col207
   IF p_party_rec.col207 = FND_API.g_miss_char THEN
      x_complete_rec.col207 := l_party_rec.col207;
   END IF;

   -- col208
   IF p_party_rec.col208 = FND_API.g_miss_char THEN
      x_complete_rec.col208 := l_party_rec.col208;
   END IF;

   -- col209
   IF p_party_rec.col209 = FND_API.g_miss_char THEN
      x_complete_rec.col209 := l_party_rec.col209;
   END IF;

   -- col210
   IF p_party_rec.col210 = FND_API.g_miss_char THEN
      x_complete_rec.col210 := l_party_rec.col210;
   END IF;

   -- col211
   IF p_party_rec.col211 = FND_API.g_miss_char THEN
      x_complete_rec.col211 := l_party_rec.col211;
   END IF;

   -- col212
   IF p_party_rec.col212 = FND_API.g_miss_char THEN
      x_complete_rec.col212 := l_party_rec.col212;
   END IF;

   -- col213
   IF p_party_rec.col213 = FND_API.g_miss_char THEN
      x_complete_rec.col213 := l_party_rec.col213;
   END IF;

   -- col214
   IF p_party_rec.col214 = FND_API.g_miss_char THEN
      x_complete_rec.col214 := l_party_rec.col214;
   END IF;

   -- col215
   IF p_party_rec.col215 = FND_API.g_miss_char THEN
      x_complete_rec.col215 := l_party_rec.col215;
   END IF;

   -- col216
   IF p_party_rec.col216 = FND_API.g_miss_char THEN
      x_complete_rec.col216 := l_party_rec.col216;
   END IF;

   -- col217
   IF p_party_rec.col217 = FND_API.g_miss_char THEN
      x_complete_rec.col217 := l_party_rec.col217;
   END IF;

   -- col218
   IF p_party_rec.col218 = FND_API.g_miss_char THEN
      x_complete_rec.col218 := l_party_rec.col218;
   END IF;

   -- col219
   IF p_party_rec.col219 = FND_API.g_miss_char THEN
      x_complete_rec.col219 := l_party_rec.col219;
   END IF;

   -- col220
   IF p_party_rec.col220 = FND_API.g_miss_char THEN
      x_complete_rec.col220 := l_party_rec.col220;
   END IF;

   -- col221
   IF p_party_rec.col221 = FND_API.g_miss_char THEN
      x_complete_rec.col221 := l_party_rec.col221;
   END IF;

   -- col222
   IF p_party_rec.col222 = FND_API.g_miss_char THEN
      x_complete_rec.col222 := l_party_rec.col222;
   END IF;

   -- col223
   IF p_party_rec.col223 = FND_API.g_miss_char THEN
      x_complete_rec.col223 := l_party_rec.col223;
   END IF;

   -- col224
   IF p_party_rec.col224 = FND_API.g_miss_char THEN
      x_complete_rec.col224 := l_party_rec.col224;
   END IF;

   -- col225
   IF p_party_rec.col225 = FND_API.g_miss_char THEN
      x_complete_rec.col225 := l_party_rec.col225;
   END IF;

   -- col226
   IF p_party_rec.col226 = FND_API.g_miss_char THEN
      x_complete_rec.col226 := l_party_rec.col226;
   END IF;

   -- col227
   IF p_party_rec.col227 = FND_API.g_miss_char THEN
      x_complete_rec.col227 := l_party_rec.col227;
   END IF;

   -- col228
   IF p_party_rec.col228 = FND_API.g_miss_char THEN
      x_complete_rec.col228 := l_party_rec.col228;
   END IF;

   -- col229
   IF p_party_rec.col229 = FND_API.g_miss_char THEN
      x_complete_rec.col229 := l_party_rec.col229;
   END IF;

   -- col230
   IF p_party_rec.col230 = FND_API.g_miss_char THEN
      x_complete_rec.col230 := l_party_rec.col230;
   END IF;

   -- col231
   IF p_party_rec.col231 = FND_API.g_miss_char THEN
      x_complete_rec.col231 := l_party_rec.col231;
   END IF;

   -- col232
   IF p_party_rec.col232 = FND_API.g_miss_char THEN
      x_complete_rec.col232 := l_party_rec.col232;
   END IF;

   -- col233
   IF p_party_rec.col233 = FND_API.g_miss_char THEN
      x_complete_rec.col233 := l_party_rec.col233;
   END IF;

   -- col234
   IF p_party_rec.col234 = FND_API.g_miss_char THEN
      x_complete_rec.col234 := l_party_rec.col234;
   END IF;

   -- col235
   IF p_party_rec.col235 = FND_API.g_miss_char THEN
      x_complete_rec.col235 := l_party_rec.col235;
   END IF;

   -- col236
   IF p_party_rec.col236 = FND_API.g_miss_char THEN
      x_complete_rec.col236 := l_party_rec.col236;
   END IF;

   -- col237
   IF p_party_rec.col237 = FND_API.g_miss_char THEN
      x_complete_rec.col237 := l_party_rec.col237;
   END IF;

   -- col238
   IF p_party_rec.col238 = FND_API.g_miss_char THEN
      x_complete_rec.col238 := l_party_rec.col238;
   END IF;

   -- col239
   IF p_party_rec.col239 = FND_API.g_miss_char THEN
      x_complete_rec.col239 := l_party_rec.col239;
   END IF;

   -- col240
   IF p_party_rec.col240 = FND_API.g_miss_char THEN
      x_complete_rec.col240 := l_party_rec.col240;
   END IF;

   -- col241
   IF p_party_rec.col241 = FND_API.g_miss_char THEN
      x_complete_rec.col241 := l_party_rec.col241;
   END IF;

   -- col242
   IF p_party_rec.col242 = FND_API.g_miss_char THEN
      x_complete_rec.col242 := l_party_rec.col242;
   END IF;

   -- col243
   IF p_party_rec.col243 = FND_API.g_miss_char THEN
      x_complete_rec.col243 := l_party_rec.col243;
   END IF;

   -- col244
   IF p_party_rec.col244 = FND_API.g_miss_char THEN
      x_complete_rec.col244 := l_party_rec.col244;
   END IF;

   -- col245
   IF p_party_rec.col245 = FND_API.g_miss_char THEN
      x_complete_rec.col245 := l_party_rec.col245;
   END IF;

   -- col246
   IF p_party_rec.col246 = FND_API.g_miss_char THEN
      x_complete_rec.col246 := l_party_rec.col246;
   END IF;

   -- col247
   IF p_party_rec.col247 = FND_API.g_miss_char THEN
      x_complete_rec.col247 := l_party_rec.col247;
   END IF;

   -- col248
   IF p_party_rec.col248 = FND_API.g_miss_char THEN
      x_complete_rec.col248 := l_party_rec.col248;
   END IF;

   -- col249
   IF p_party_rec.col249 = FND_API.g_miss_char THEN
      x_complete_rec.col249 := l_party_rec.col249;
   END IF;

   -- col250
   IF p_party_rec.col250 = FND_API.g_miss_char THEN
      x_complete_rec.col250 := l_party_rec.col250;
   END IF;


END Complete_Party_Rec;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Party_Req_Items
--
-- PURPOSE
--    Validate that the required columns for the table have values.
--
-- NOTE
--
-- HISTORY
-- 08-Nov-1999 choang      Created as dummy procedure;
---------------------------------------------------------------------
PROCEDURE Check_Party_Req_Items (
   p_party_rec     IN    Party_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- PARTY_ID
   IF p_party_rec.party_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_PARTY_NO_PARTY_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   -- IMPORT_SOURCE_LINE_ID
   IF p_party_rec.import_source_line_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_PARTY_NO_IMP_SRC_LINE_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   -- IMPORT_LIST_HEADER_ID
   IF p_party_rec.import_list_header_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_PARTY_NO_IMP_LIST_HDR_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   -- LIST_SOURCE_TYPE_ID
   IF p_party_rec.list_source_type_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_PARTY_NO_LST_SRC_TYPE_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

END Check_Party_Req_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Party_UK_Items
--
-- PURPOSE
--    Validate that the uniqueness constraints are met.
--
-- HISTORY
-- 08-Nov-1999 choang      Created.
---------------------------------------------------------------------
PROCEDURE Check_Party_UK_Items (
   p_party_rec       IN    Party_Rec_Type,
   p_validation_mode IN    VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
   l_where_clause    VARCHAR2(4000);
   l_valid_flag      VARCHAR2(1);
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- For Create_Party, when ID is passed in, we need to
   -- check if this ID is unique.
   IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_party_rec.party_sources_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_uniqueness (
		      'ams_party_sources',
				'party_sources_id = ' || p_party_rec.party_sources_id
			) = FND_API.g_false
		THEN
         IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name ('AMS', 'AMS_PARTY_DUP_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END Check_Party_UK_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Party_FK_Items
--
-- PURPOSE
--    Validate foreign key references.
--
-- HISTORY
-- 08-Nov-1999 choang      Created.
---------------------------------------------------------------------
PROCEDURE Check_Party_FK_Items (
   p_party_rec       IN    Party_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
   L_LIST_SRC_TYPES_TABLE     CONSTANT VARCHAR2(30) := 'AMS_LIST_SRC_TYPES';
   L_LIST_SRC_TYPES_ID        CONSTANT VARCHAR2(30) := 'LIST_SOURCE_TYPE_ID';
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   --
   -- PARTY_ID
   IF p_party_rec.party_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists (
            p_table_name            => 'HZ_PARTIES',
            p_pk_name               => 'PARTY_ID',
            p_pk_value              => p_party_rec.party_id,
            p_pk_data_type          => AMS_Utility_PVT.g_number
         ) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_PARTY_BAD_PARTY_ID');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --
   -- IMPORT_SOURCE_LINE_ID
   IF p_party_rec.import_source_line_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists (
            p_table_name            => 'AMS_IMP_SOURCE_LINES',
            p_pk_name               => 'IMPORT_SOURCE_LINE_ID',
            p_pk_value              => p_party_rec.import_source_line_id,
            p_pk_data_type          => AMS_Utility_PVT.g_number
         ) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_PARTY_BAD_IMP_SRC_LINE_ID');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --
   -- IMPORT_LIST_HEADER_ID
   IF p_party_rec.import_list_header_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists (
            p_table_name            => 'AMS_IMP_LIST_HEADERS_ALL',
            p_pk_name               => 'IMPORT_LIST_HEADER_ID',
            p_pk_value              => p_party_rec.import_list_header_id,
            p_pk_data_type          => AMS_Utility_PVT.g_number
         ) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_PARTY_BAD_IMP_LIST_HDR_ID');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --
   -- LIST_SOURCE_TYPE_ID
   IF p_party_rec.list_source_type_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists (
            p_table_name            => 'AMS_LIST_SRC_TYPES',
            p_pk_name               => 'LIST_SOURCE_TYPE_ID',
            p_pk_value              => p_party_rec.list_source_type_id,
            p_pk_data_type          => AMS_Utility_PVT.g_number
         ) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_PARTY_BAD_LST_SRC_TYPE_ID');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END Check_Party_FK_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Party_Lookup_Items
--
-- PURPOSE
--    Validate the existence of the lookup values in AMS_LOOKUPS.
--
-- HISTORY
-- 08-Nov-1999 choang      Created.
---------------------------------------------------------------------
PROCEDURE Check_Party_Lookup_Items (
   p_party_rec       IN    Party_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
END Check_Party_Lookup_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Party_Flag_Items
--
-- PURPOSE
--    Validate that the flags have proper values.  Proper values
--    for flags are 'Y' and 'N'.
--
-- HISTORY
-- 08-Nov-1999 choang      Created.
---------------------------------------------------------------------
PROCEDURE Check_Party_Flag_Items (
   p_party_rec       IN    Party_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   --
   -- USED_FLAG
   IF p_party_rec.used_flag <> FND_API.g_miss_char AND p_party_rec.used_flag IS NOT NULL THEN
      IF AMS_Utility_PVT.is_Y_or_N (p_party_rec.used_flag) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name ('AMS', 'AMS_PARTY_BAD_USED_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --
   -- OVERLAY_FLAG
   IF p_party_rec.overlay_flag <> FND_API.g_miss_char AND p_party_rec.overlay_flag IS NOT NULL THEN
      IF AMS_Utility_PVT.is_Y_or_N (p_party_rec.overlay_flag) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name ('AMS', 'AMS_PARTY_BAD_OVERLAY_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END Check_Party_Flag_Items;



PROCEDURE Refresh_Key (
   errbuf         OUT NOCOPY VARCHAR2,
   retcode        OUT NOCOPY NUMBER,
   p_word_replacement_flag IN VARCHAR2,
   p_commit_flag           IN VARCHAR2
)
IS
   L_MAX_BUFFER_LENGTH     CONSTANT NUMBER := 240;
   L_API_NAME              CONSTANT VARCHAR2(30) := 'Refresh_Key';
   L_FULL_NAME             CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
BEGIN
   --
   -- Initialize the dedupe table.
   Initialize_Dedupe_Table;

   --
   -- Synchronize the ID's in HZ_PARTIES with those
   -- in the dedupe table.
   Synchronize_ID;

   --
   -- Populate the dedupe table with the proper
   -- DEDUPE_KEYs.
   Populate_Keys (p_word_replacement_flag);

   IF p_commit_flag = 'Y' THEN
      COMMIT WORK;
   END IF;

   errbuf := SUBSTR (FND_MESSAGE.get, 1, L_MAX_BUFFER_LENGTH);
   retcode := 0;  -- no problems.
EXCEPTION
   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      retcode := 2;
      errbuf := SUBSTR (FND_MESSAGE.get, 1, L_MAX_BUFFER_LENGTH);
END Refresh_Key;


-----------------------------------------------------------
-- PROCEDURE
--    Initialize_Dedupe_Table
-- PURPOSE
--    Initialize the table AMS_PARTY_DEDUPE.
-- HISTORY
-- 11-Nov-1999 choang      Created.
-----------------------------------------------------------
PROCEDURE Initialize_Dedupe_Table
IS
BEGIN
   DELETE FROM ams_party_dedupe;
END Initialize_Dedupe_Table;


-----------------------------------------------------------
-- PROCEDURE
--    Synchronize_ID
-- PURPOSE
--    Synchronize the PARTY_ID of AMS_PARTY_DEDUPE with
--    that of HZ_PARTIES.
-- HISTORY
-- 11-Nov-1999 choang      Created.
-----------------------------------------------------------
PROCEDURE Synchronize_ID
IS
BEGIN
   INSERT INTO ams_party_dedupe (
      party_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      object_version_number
   )
   SELECT party_id,
          SYSDATE,                  -- last_update_date
          FND_GLOBAL.user_id,       -- last_updated_by
          SYSDATE,                  -- creation_date
          FND_GLOBAL.user_id,       -- created_by
          FND_GLOBAL.conc_login_id, -- last_update_login
          1                         -- object_version_number
   FROM hz_parties
   ;
END Synchronize_ID;


-----------------------------------------------------------
-- PROCEDURE
--    Populate_Keys
-- PURPOSE
--    Populate the DEDUPE_KEY in AMS_PARTY_DEDUPE with
--    the derived key using the Generate_Key API.
-- HISTORY
-- 11-Nov-1999 choang      Created.
-- 07-Jan-2000 choang      Removed dbms_output due to problem with
--                         adchkdrv.
-----------------------------------------------------------
PROCEDURE Populate_Keys (
   p_word_replacement_flag    IN VARCHAR2
)
IS
   L_HZ_DEDUPE_RULE     CONSTANT VARCHAR2(30) := 'AMS_HZ_DEDUPE_RULE';
   L_API_VERSION        CONSTANT NUMBER := 1.0;
   L_PARTY_ID_COLUMN    CONSTANT VARCHAR2(30) := 'PARTY_ID';

   l_party_id           NUMBER;
   l_list_rule_id       NUMBER;
   l_dedupe_key         VARCHAR2(500);

   l_return_status      VARCHAR2(1);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(4000);

   CURSOR c_rule (x_rule_name IN VARCHAR2) IS
      SELECT list_rule_id
      FROM   ams_list_rules_all
      WHERE list_rule_name = x_rule_name
      ;

   --
   -- NOTE: Not using "WHERE CURRENT OF"
   -- in the update statment due to bug 219936.
   CURSOR c_id IS
      SELECT party_id
      FROM   ams_party_dedupe
      WHERE dedupe_key IS NULL
      FOR UPDATE NOWAIT
      ;
BEGIN
   OPEN c_rule (FND_PROFILE.value (L_HZ_DEDUPE_RULE));
   FETCH c_rule INTO l_list_rule_id;
   CLOSE c_rule;

   OPEN c_id;
   LOOP
      FETCH c_id INTO l_party_id;
      EXIT WHEN c_id%NOTFOUND;

      --
      -- Call API to generate the dedupe key.
      AMS_ListDedupe_PVT.Generate_Key (
         p_api_version           => L_API_VERSION,
         p_init_msg_list         => FND_API.g_true,

         x_return_status         => l_return_status,
         x_msg_count             => l_msg_count,
         x_msg_data              => l_msg_data,

         p_list_rule_id          => l_list_rule_id,
         p_sys_object_id         => l_party_id,
         p_sys_object_id_field   => L_PARTY_ID_COLUMN,
         p_word_replacement_flag => p_word_replacement_flag,
         x_dedupe_key            => l_dedupe_key
      );

      UPDATE ams_party_dedupe
      SET
         dedupe_key = l_dedupe_key,
         last_update_date = SYSDATE,
         last_updated_by = FND_GLOBAL.user_id,
         last_update_login = FND_GLOBAL.conc_login_id,
         object_version_number = object_version_number + 1
      WHERE party_id = l_party_id;
   END LOOP;
   CLOSE c_id;
END Populate_Keys;


-----------------------------------------------------------
-- PROCEDURE
--    Process_Party
-- HISTORY
-- 13-Nov-1999 choang      Created.
-- 27-Feb-2000 choang      Party sources were not being created for existing persons
--                         in hz_parties because imported data was only being fetched
--                         for new party sources.  Moved the imported data fetch to
--                         the initialization area of the API.
-----------------------------------------------------------
PROCEDURE Process_Party (
   p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2  := FND_API.g_false,
   p_commit                IN  VARCHAR2  := FND_API.g_false,
   p_validation_level      IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,

   p_import_source_line_id IN  NUMBER,
   p_word_replacement_flag IN  VARCHAR2
)
IS
   L_SOURCE_IMPORT_RULE       VARCHAR2(30) := 'SRC_PERSON_IMPORT';
   L_API_VERSION              CONSTANT NUMBER := 1.0;
   L_API_NAME                 CONSTANT VARCHAR2(30) := 'Process_Party';
   L_FULL_NAME                CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
   L_KEY_ID_COLUMN            CONSTANT VARCHAR2(30) := 'IMPORT_SOURCE_LINE_ID';

   l_return_status            VARCHAR2(1);

   l_party_sources_rec        Party_Rec_Type := NULL; -- PL/SQL record representing AMS_PARTY_SOURCES
   l_party_sources_id         NUMBER;
   l_person_rec               HZ_Party_V2Pub.person_rec_type;
   l_party_id                 NUMBER;
   l_party_number             VARCHAR2(30);
   l_profile_id               NUMBER;

   l_list_rule_id             NUMBER;
   l_list_source_type_id      NUMBER;
   l_dedupe_key               VARCHAR2(500);

   l_errbuf       VARCHAR2(4000);
   l_retcode      NUMBER;

   --
   -- List rule used for dedupe key
   -- generation.
   CURSOR c_rule (x_rule_name IN VARCHAR2) IS
      SELECT list_rule_id
      FROM   ams_list_rules_all
      WHERE  list_rule_name = x_rule_name
   ;

   CURSOR c_import IS
      SELECT *
      FROM   ams_imp_source_lines
      WHERE  import_source_line_id = p_import_source_line_id
   ;
   l_import_rec      c_import%ROWTYPE;

   CURSOR c_type IS
      SELECT list_source_type_id
      FROM   ams_imp_list_headers_all
      WHERE  import_list_header_id = l_import_rec.import_list_header_id
   ;
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

   /* Added code to check dedupe rule from profile option */
   l_source_import_rule := fnd_profile.VALUE ('AMS_IMP_DEDUPE_RULES');
   if l_source_import_rule is null  then
     l_source_import_rule   := 'SRC_PERSON_IMPORT';
   end if;


/*
   --
   -- Initialize the party dedupe reference table
   Refresh_Key (
      errbuf         => l_errbuf,
      retcode        => l_retcode,
      p_word_replacement_flag => p_word_replacement_flag,
      p_commit_flag           => p_commit
   );
*/

   --
   -- Get the rule used for dedupe
   -- key generation.
   OPEN c_rule (L_SOURCE_IMPORT_RULE);
   FETCH c_rule INTO l_list_rule_id;
   IF c_rule%NOTFOUND THEN
      --
      -- The list rule used for generating
      -- of the dedupe key for source imports
      -- was not found.
      CLOSE c_rule;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_LIST_BAD_DEDUPE_RULE');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_rule;

   --
   -- Fetch the imported data.
   OPEN c_import;
   FETCH c_import INTO l_import_rec;
   CLOSE c_import;

   --
   -- Generate the dedupe key.
   AMS_ListDedupe_PVT.Generate_Key (
      p_api_version           => L_API_VERSION,
      p_init_msg_list         => p_init_msg_list,

      x_return_status         => l_return_status,
      x_msg_count             => x_msg_count,
      x_msg_data              => x_msg_data,

      p_list_rule_id          => l_list_rule_id,
      p_sys_object_id         => p_import_source_line_id,
      p_sys_object_id_field   => L_KEY_ID_COLUMN,
      p_word_replacement_flag => p_word_replacement_flag,
      x_dedupe_key            => l_dedupe_key
   );

   --
   -- Does the party exist in HZ_PARTIES?
   IF Party_Exists (l_dedupe_key, l_party_id) THEN
      l_party_sources_rec.overlay_flag := 'Y';
      l_party_sources_rec.overlay_date := SYSDATE;
   ELSE
      l_party_sources_rec.overlay_flag := 'N';
-- Begin change - ryedator - for R12 compilation issues.
/*
      -- Create the record in HZ_PARTIES
      l_person_rec.first_name := l_import_rec.COL1;
      l_person_rec.last_name := l_import_rec.COL2;
      l_person_rec.title := l_import_rec.COL3;
      HZ_Party_Pub.Create_Person (
         p_api_version     => l_api_version,
         p_init_msg_list   => p_init_msg_list,
         p_validation_level   => p_validation_level,
         p_commit          => p_commit,
         p_person_rec      => l_person_rec,
         x_return_status   => l_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data,
         x_party_id        => l_party_id,
         x_party_number    => l_party_number,
         x_profile_id      => l_profile_id
      );
*/
   l_person_rec.person_first_name := l_import_rec.COL1;
   l_person_rec.person_last_name := l_import_rec.COL2;
   l_person_rec.person_title := l_import_rec.COL3;

   HZ_Party_V2Pub.create_person (
    p_init_msg_list   => p_init_msg_list,
    p_person_rec      => l_person_rec,
    x_party_id        => l_party_id,
    x_party_number    => l_party_number,
    x_profile_id      => l_profile_id,
    x_return_status   => l_return_status,
    x_msg_count       => x_msg_count,
    x_msg_data        => x_msg_data
  );
-- End change - ryedator - for R12 compilation issues.

   END IF;

   OPEN c_type;
   FETCH c_type INTO l_list_source_type_id;
   CLOSE c_type;

   ------------ Initialize party_sources_rec ----------------------
   l_party_sources_rec.party_id := l_party_id;
   l_party_sources_rec.import_source_line_id := p_import_source_line_id;
   l_party_sources_rec.import_list_header_id := l_import_rec.import_list_header_id;
   l_party_sources_rec.list_source_type_id := l_list_source_type_id;
   l_party_sources_rec.col1   := l_import_rec.col1;
   l_party_sources_rec.col2   := l_import_rec.col2;
   l_party_sources_rec.col3   := l_import_rec.col3;
   l_party_sources_rec.col4   := l_import_rec.col4;
   l_party_sources_rec.col5   := l_import_rec.col5;
   l_party_sources_rec.col6   := l_import_rec.col6;
   l_party_sources_rec.col7   := l_import_rec.col7;
   l_party_sources_rec.col8   := l_import_rec.col8;
   l_party_sources_rec.col9   := l_import_rec.col9;
   l_party_sources_rec.col10  := l_import_rec.col10;
   l_party_sources_rec.col11  := l_import_rec.col11;
   l_party_sources_rec.col12  := l_import_rec.col12;
   l_party_sources_rec.col13  := l_import_rec.col13;
   l_party_sources_rec.col14  := l_import_rec.col14;
   l_party_sources_rec.col15  := l_import_rec.col15;
   l_party_sources_rec.col16  := l_import_rec.col16;
   l_party_sources_rec.col17  := l_import_rec.col17;
   l_party_sources_rec.col18  := l_import_rec.col18;
   l_party_sources_rec.col19  := l_import_rec.col19;
   l_party_sources_rec.col20  := l_import_rec.col20;
   l_party_sources_rec.col21  := l_import_rec.col21;
   l_party_sources_rec.col22  := l_import_rec.col22;
   l_party_sources_rec.col23  := l_import_rec.col23;
   l_party_sources_rec.col24  := l_import_rec.col24;
   l_party_sources_rec.col25  := l_import_rec.col25;
   l_party_sources_rec.col26  := l_import_rec.col26;
   l_party_sources_rec.col27  := l_import_rec.col27;
   l_party_sources_rec.col28  := l_import_rec.col28;
   l_party_sources_rec.col29  := l_import_rec.col29;
   l_party_sources_rec.col30  := l_import_rec.col30;
   l_party_sources_rec.col31  := l_import_rec.col31;
   l_party_sources_rec.col32  := l_import_rec.col32;
   l_party_sources_rec.col33  := l_import_rec.col33;
   l_party_sources_rec.col34  := l_import_rec.col34;
   l_party_sources_rec.col35  := l_import_rec.col35;
   l_party_sources_rec.col36  := l_import_rec.col36;
   l_party_sources_rec.col37  := l_import_rec.col37;
   l_party_sources_rec.col38  := l_import_rec.col38;
   l_party_sources_rec.col39  := l_import_rec.col39;
   l_party_sources_rec.col40  := l_import_rec.col40;
   l_party_sources_rec.col41  := l_import_rec.col41;
   l_party_sources_rec.col42  := l_import_rec.col42;
   l_party_sources_rec.col43  := l_import_rec.col43;
   l_party_sources_rec.col44  := l_import_rec.col44;
   l_party_sources_rec.col45  := l_import_rec.col45;
   l_party_sources_rec.col46  := l_import_rec.col46;
   l_party_sources_rec.col47  := l_import_rec.col47;
   l_party_sources_rec.col48  := l_import_rec.col48;
   l_party_sources_rec.col49  := l_import_rec.col49;
   l_party_sources_rec.col50  := l_import_rec.col50;
   l_party_sources_rec.col51  := l_import_rec.col51;
   l_party_sources_rec.col52  := l_import_rec.col52;
   l_party_sources_rec.col53  := l_import_rec.col53;
   l_party_sources_rec.col54  := l_import_rec.col54;
   l_party_sources_rec.col55  := l_import_rec.col55;
   l_party_sources_rec.col56  := l_import_rec.col56;
   l_party_sources_rec.col57  := l_import_rec.col57;
   l_party_sources_rec.col58  := l_import_rec.col58;
   l_party_sources_rec.col59  := l_import_rec.col59;
   l_party_sources_rec.col60  := l_import_rec.col60;
   l_party_sources_rec.col61  := l_import_rec.col61;
   l_party_sources_rec.col62  := l_import_rec.col62;
   l_party_sources_rec.col63  := l_import_rec.col63;
   l_party_sources_rec.col64  := l_import_rec.col64;
   l_party_sources_rec.col65  := l_import_rec.col65;
   l_party_sources_rec.col66  := l_import_rec.col66;
   l_party_sources_rec.col67  := l_import_rec.col67;
   l_party_sources_rec.col68  := l_import_rec.col68;
   l_party_sources_rec.col69  := l_import_rec.col69;
   l_party_sources_rec.col70  := l_import_rec.col70;
   l_party_sources_rec.col71  := l_import_rec.col71;
   l_party_sources_rec.col72  := l_import_rec.col72;
   l_party_sources_rec.col73  := l_import_rec.col73;
   l_party_sources_rec.col74  := l_import_rec.col74;
   l_party_sources_rec.col75  := l_import_rec.col75;
   l_party_sources_rec.col76  := l_import_rec.col76;
   l_party_sources_rec.col77  := l_import_rec.col77;
   l_party_sources_rec.col78  := l_import_rec.col78;
   l_party_sources_rec.col79  := l_import_rec.col79;
   l_party_sources_rec.col80  := l_import_rec.col80;
   l_party_sources_rec.col81  := l_import_rec.col81;
   l_party_sources_rec.col82  := l_import_rec.col82;
   l_party_sources_rec.col83  := l_import_rec.col83;
   l_party_sources_rec.col84  := l_import_rec.col84;
   l_party_sources_rec.col85  := l_import_rec.col85;
   l_party_sources_rec.col86  := l_import_rec.col86;
   l_party_sources_rec.col87  := l_import_rec.col87;
   l_party_sources_rec.col88  := l_import_rec.col88;
   l_party_sources_rec.col89  := l_import_rec.col89;
   l_party_sources_rec.col90  := l_import_rec.col90;
   l_party_sources_rec.col91  := l_import_rec.col91;
   l_party_sources_rec.col92  := l_import_rec.col92;
   l_party_sources_rec.col93  := l_import_rec.col93;
   l_party_sources_rec.col94  := l_import_rec.col94;
   l_party_sources_rec.col95  := l_import_rec.col95;
   l_party_sources_rec.col96  := l_import_rec.col96;
   l_party_sources_rec.col97  := l_import_rec.col97;
   l_party_sources_rec.col98  := l_import_rec.col98;
   l_party_sources_rec.col99  := l_import_rec.col99;
   l_party_sources_rec.col100 := l_import_rec.col100;
   l_party_sources_rec.col101 := l_import_rec.col101;
   l_party_sources_rec.col102 := l_import_rec.col102;
   l_party_sources_rec.col103 := l_import_rec.col103;
   l_party_sources_rec.col104 := l_import_rec.col104;
   l_party_sources_rec.col105 := l_import_rec.col105;
   l_party_sources_rec.col106 := l_import_rec.col106;
   l_party_sources_rec.col107 := l_import_rec.col107;
   l_party_sources_rec.col108 := l_import_rec.col108;
   l_party_sources_rec.col109 := l_import_rec.col109;
   l_party_sources_rec.col110 := l_import_rec.col110;
   l_party_sources_rec.col111 := l_import_rec.col111;
   l_party_sources_rec.col112 := l_import_rec.col112;
   l_party_sources_rec.col113 := l_import_rec.col113;
   l_party_sources_rec.col114 := l_import_rec.col114;
   l_party_sources_rec.col115 := l_import_rec.col115;
   l_party_sources_rec.col116 := l_import_rec.col116;
   l_party_sources_rec.col117 := l_import_rec.col117;
   l_party_sources_rec.col118 := l_import_rec.col118;
   l_party_sources_rec.col119 := l_import_rec.col119;
   l_party_sources_rec.col120 := l_import_rec.col120;
   l_party_sources_rec.col121 := l_import_rec.col121;
   l_party_sources_rec.col122 := l_import_rec.col122;
   l_party_sources_rec.col123 := l_import_rec.col123;
   l_party_sources_rec.col124 := l_import_rec.col124;
   l_party_sources_rec.col125 := l_import_rec.col125;
   l_party_sources_rec.col126 := l_import_rec.col126;
   l_party_sources_rec.col127 := l_import_rec.col127;
   l_party_sources_rec.col128 := l_import_rec.col128;
   l_party_sources_rec.col129 := l_import_rec.col129;
   l_party_sources_rec.col130 := l_import_rec.col130;
   l_party_sources_rec.col131 := l_import_rec.col131;
   l_party_sources_rec.col132 := l_import_rec.col132;
   l_party_sources_rec.col133 := l_import_rec.col133;
   l_party_sources_rec.col134 := l_import_rec.col134;
   l_party_sources_rec.col135 := l_import_rec.col135;
   l_party_sources_rec.col136 := l_import_rec.col136;
   l_party_sources_rec.col137 := l_import_rec.col137;
   l_party_sources_rec.col138 := l_import_rec.col138;
   l_party_sources_rec.col139 := l_import_rec.col139;
   l_party_sources_rec.col140 := l_import_rec.col140;
   l_party_sources_rec.col141 := l_import_rec.col141;
   l_party_sources_rec.col142 := l_import_rec.col142;
   l_party_sources_rec.col143 := l_import_rec.col143;
   l_party_sources_rec.col144 := l_import_rec.col144;
   l_party_sources_rec.col145 := l_import_rec.col145;
   l_party_sources_rec.col146 := l_import_rec.col146;
   l_party_sources_rec.col147 := l_import_rec.col147;
   l_party_sources_rec.col148 := l_import_rec.col148;
   l_party_sources_rec.col149 := l_import_rec.col149;
   l_party_sources_rec.col150 := l_import_rec.col150;
   l_party_sources_rec.col151 := l_import_rec.col151;
   l_party_sources_rec.col152 := l_import_rec.col152;
   l_party_sources_rec.col153 := l_import_rec.col153;
   l_party_sources_rec.col154 := l_import_rec.col154;
   l_party_sources_rec.col155 := l_import_rec.col155;
   l_party_sources_rec.col156 := l_import_rec.col156;
   l_party_sources_rec.col157 := l_import_rec.col157;
   l_party_sources_rec.col158 := l_import_rec.col158;
   l_party_sources_rec.col159 := l_import_rec.col159;
   l_party_sources_rec.col160 := l_import_rec.col160;
   l_party_sources_rec.col161 := l_import_rec.col161;
   l_party_sources_rec.col162 := l_import_rec.col162;
   l_party_sources_rec.col163 := l_import_rec.col163;
   l_party_sources_rec.col164 := l_import_rec.col164;
   l_party_sources_rec.col165 := l_import_rec.col165;
   l_party_sources_rec.col166 := l_import_rec.col166;
   l_party_sources_rec.col167 := l_import_rec.col167;
   l_party_sources_rec.col168 := l_import_rec.col168;
   l_party_sources_rec.col169 := l_import_rec.col169;
   l_party_sources_rec.col170 := l_import_rec.col170;
   l_party_sources_rec.col171 := l_import_rec.col171;
   l_party_sources_rec.col172 := l_import_rec.col172;
   l_party_sources_rec.col173 := l_import_rec.col173;
   l_party_sources_rec.col174 := l_import_rec.col174;
   l_party_sources_rec.col175 := l_import_rec.col175;
   l_party_sources_rec.col176 := l_import_rec.col176;
   l_party_sources_rec.col177 := l_import_rec.col177;
   l_party_sources_rec.col178 := l_import_rec.col178;
   l_party_sources_rec.col179 := l_import_rec.col179;
   l_party_sources_rec.col180 := l_import_rec.col180;
   l_party_sources_rec.col181 := l_import_rec.col181;
   l_party_sources_rec.col182 := l_import_rec.col182;
   l_party_sources_rec.col183 := l_import_rec.col183;
   l_party_sources_rec.col184 := l_import_rec.col184;
   l_party_sources_rec.col185 := l_import_rec.col185;
   l_party_sources_rec.col186 := l_import_rec.col186;
   l_party_sources_rec.col187 := l_import_rec.col187;
   l_party_sources_rec.col188 := l_import_rec.col188;
   l_party_sources_rec.col189 := l_import_rec.col189;
   l_party_sources_rec.col190 := l_import_rec.col190;
   l_party_sources_rec.col191 := l_import_rec.col191;
   l_party_sources_rec.col192 := l_import_rec.col192;
   l_party_sources_rec.col193 := l_import_rec.col193;
   l_party_sources_rec.col194 := l_import_rec.col194;
   l_party_sources_rec.col195 := l_import_rec.col195;
   l_party_sources_rec.col196 := l_import_rec.col196;
   l_party_sources_rec.col197 := l_import_rec.col197;
   l_party_sources_rec.col198 := l_import_rec.col198;
   l_party_sources_rec.col199 := l_import_rec.col199;
   l_party_sources_rec.col200 := l_import_rec.col200;
   l_party_sources_rec.col201 := l_import_rec.col201;
   l_party_sources_rec.col202 := l_import_rec.col202;
   l_party_sources_rec.col203 := l_import_rec.col203;
   l_party_sources_rec.col204 := l_import_rec.col204;
   l_party_sources_rec.col205 := l_import_rec.col205;
   l_party_sources_rec.col206 := l_import_rec.col206;
   l_party_sources_rec.col207 := l_import_rec.col207;
   l_party_sources_rec.col208 := l_import_rec.col208;
   l_party_sources_rec.col209 := l_import_rec.col209;
   l_party_sources_rec.col210 := l_import_rec.col210;
   l_party_sources_rec.col211 := l_import_rec.col211;
   l_party_sources_rec.col212 := l_import_rec.col212;
   l_party_sources_rec.col213 := l_import_rec.col213;
   l_party_sources_rec.col214 := l_import_rec.col214;
   l_party_sources_rec.col215 := l_import_rec.col215;
   l_party_sources_rec.col216 := l_import_rec.col216;
   l_party_sources_rec.col217 := l_import_rec.col217;
   l_party_sources_rec.col218 := l_import_rec.col218;
   l_party_sources_rec.col219 := l_import_rec.col219;
   l_party_sources_rec.col220 := l_import_rec.col220;
   l_party_sources_rec.col221 := l_import_rec.col221;
   l_party_sources_rec.col222 := l_import_rec.col222;
   l_party_sources_rec.col223 := l_import_rec.col223;
   l_party_sources_rec.col224 := l_import_rec.col224;
   l_party_sources_rec.col225 := l_import_rec.col225;
   l_party_sources_rec.col226 := l_import_rec.col226;
   l_party_sources_rec.col227 := l_import_rec.col227;
   l_party_sources_rec.col228 := l_import_rec.col228;
   l_party_sources_rec.col229 := l_import_rec.col229;
   l_party_sources_rec.col230 := l_import_rec.col230;
   l_party_sources_rec.col231 := l_import_rec.col231;
   l_party_sources_rec.col232 := l_import_rec.col232;
   l_party_sources_rec.col233 := l_import_rec.col233;
   l_party_sources_rec.col234 := l_import_rec.col234;
   l_party_sources_rec.col235 := l_import_rec.col235;
   l_party_sources_rec.col236 := l_import_rec.col236;
   l_party_sources_rec.col237 := l_import_rec.col237;
   l_party_sources_rec.col238 := l_import_rec.col238;
   l_party_sources_rec.col239 := l_import_rec.col239;
   l_party_sources_rec.col240 := l_import_rec.col240;
   l_party_sources_rec.col241 := l_import_rec.col241;
   l_party_sources_rec.col242 := l_import_rec.col242;
   l_party_sources_rec.col243 := l_import_rec.col243;
   l_party_sources_rec.col244 := l_import_rec.col244;
   l_party_sources_rec.col245 := l_import_rec.col245;
   l_party_sources_rec.col246 := l_import_rec.col246;
   l_party_sources_rec.col247 := l_import_rec.col247;
   l_party_sources_rec.col248 := l_import_rec.col248;
   l_party_sources_rec.col249 := l_import_rec.col249;
   l_party_sources_rec.col250 := l_import_rec.col250;

   --
   -- Update Interface Table
   UPDATE ams_imp_source_lines
   SET
      party_id = l_party_id,
      dedupe_key = l_dedupe_key,
      last_updated_by = FND_GLOBAL.user_id,
      last_update_date = SYSDATE,
      last_update_login = FND_GLOBAL.conc_login_id,
      object_version_number = object_version_number + 1
   WHERE import_source_line_id = p_import_source_line_id;

   --
   -- Create Party Source
   Create_Party (
      p_api_version       => L_API_VERSION,
      p_init_msg_list     => p_init_msg_list,
      p_commit            => p_commit,
      p_validation_level  => p_validation_level,

      x_return_status     => l_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data,

      p_party_rec         => l_party_sources_rec,
      x_party_sources_id  => l_party_sources_id
   );

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
END Process_Party;


-----------------------------------------------------------
-- PROCEDURE
--    Party_Exists
-- PURPOSE
--    Returns whether a party exists in HZ_PARTIES based
--    on the given DEDUPE_KEY.
-- HISTORY
-- 13-Nov-1999 choang      Created.
-----------------------------------------------------------
FUNCTION Party_Exists (
   p_dedupe_key      IN VARCHAR2,
   x_party_id        OUT NOCOPY NUMBER
) RETURN BOOLEAN
IS
   l_party_id     NUMBER;


   CURSOR c_exists IS
      SELECT party_id
      FROM   ams_party_dedupe
      WHERE  dedupe_key = p_dedupe_key
   ;
BEGIN
   OPEN c_exists;
   FETCH c_exists INTO l_party_id;
   IF c_exists%NOTFOUND THEN
      CLOSE c_exists;
      x_party_id := NULL;
      RETURN FALSE;
   END IF;
   CLOSE c_exists;

   x_party_id := l_party_id;

   RETURN TRUE;
END Party_Exists;


-----------------------------------------------------------
-- PROCEDURE
--    Schedule_PartyProcess
-- HISTORY
-- 15-Nov-1999 choang      Created.
-----------------------------------------------------------
PROCEDURE Schedule_Party_Process (
   errbuf                  OUT NOCOPY   VARCHAR2,
   retcode                 OUT NOCOPY   NUMBER,
   p_import_list_header_id IN    NUMBER,
   p_word_replacement_flag IN    VARCHAR2
)
IS
   L_API_VERSION        CONSTANT NUMBER := 1.0;

   l_import_source_line_id    NUMBER;
   l_return_status      VARCHAR2(1);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(4000);

   CURSOR c_import IS
      SELECT import_source_line_id
      FROM   ams_imp_source_lines
      WHERE  import_list_header_id = p_import_list_header_id
   ;
BEGIN
   --
--dbms_session.set_sql_trace(true);
   -- Initialize the party dedupe reference table
   -- modified for performance  issues

   Refresh_Key (
      errbuf         => errbuf,
      retcode        => retcode,
      p_word_replacement_flag => p_word_replacement_flag,
      p_commit_flag           => FND_API.g_true
   );

   OPEN c_import;
   LOOP
      FETCH c_import INTO l_import_source_line_id;
      EXIT WHEN c_import%NOTFOUND;

      Process_Party (
         p_api_version           => L_API_VERSION,
         p_init_msg_list         => FND_API.g_true,
         p_commit                => FND_API.g_true,
         x_return_status         => l_return_status,
         x_msg_count             => l_msg_count,
         x_msg_data              => l_msg_data,

         p_import_source_line_id => l_import_source_line_id,
         p_word_replacement_flag => p_word_replacement_flag
      );
   END LOOP;
   CLOSE c_import;

   -- Import completed successfully
   FND_MESSAGE.set_name ('AMS', 'AMS_PARTY_PROCESS_COMPLETE');

   AMS_Utility_PVT.Create_Log (
      x_return_status   => l_return_status,
      p_arc_log_used_by => 'IMPH',
      p_log_used_by_id  => p_import_list_header_id,
      p_msg_data        => FND_MESSAGE.get,
      p_msg_type        => 'MILESTONE'
   );
--dbms_session.set_sql_trace(false);

END Schedule_Party_Process;


END AMS_PartyImport_PVT;

/
