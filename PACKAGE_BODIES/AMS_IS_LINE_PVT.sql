--------------------------------------------------------
--  DDL for Package Body AMS_IS_LINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IS_LINE_PVT" as
/* $Header: amsvislb.pls 115.16 2004/01/27 20:49:07 sranka ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Is_Line_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Is_Line_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvislb.pls';


-- Hint: Primary key needs to be returned.
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_Is_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_is_line_rec               IN   is_line_rec_type  := g_miss_is_line_rec,
    x_import_source_line_id                   OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Is_Line';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_IMPORT_SOURCE_LINE_ID                  NUMBER;
   l_dummy       NUMBER;

   CURSOR c_id IS
      SELECT AMS_IMP_SOURCE_LINES_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_IMP_SOURCE_LINES
      WHERE IMPORT_SOURCE_LINE_ID = l_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Is_Line_PVT;

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

   IF p_is_line_rec.IMPORT_SOURCE_LINE_ID IS NULL OR p_is_line_rec.IMPORT_SOURCE_LINE_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_IMPORT_SOURCE_LINE_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_IMPORT_SOURCE_LINE_ID);
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

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Is_Line');
          END IF;

          -- Invoke validation procedures
          Validate_is_line(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_is_line_rec  =>  p_is_line_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      END IF;

      -- Invoke table handler(AMS_IMP_SOURCE_LINES_PKG.Insert_Row)
      AMS_IMP_SOURCE_LINES_PKG.Insert_Row(
          px_import_source_line_id  => l_import_source_line_id,
          px_object_version_number  => l_object_version_number,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          p_import_list_header_id  => p_is_line_rec.import_list_header_id,
          p_import_successful_flag  => p_is_line_rec.import_successful_flag,
          p_enabled_flag  => p_is_line_rec.enabled_flag,
          p_import_failure_reason  => p_is_line_rec.import_failure_reason,
          p_re_import_last_done_date  => p_is_line_rec.re_import_last_done_date,
          p_party_id  => p_is_line_rec.party_id,
          p_dedupe_key  => p_is_line_rec.dedupe_key,
          p_col1  => p_is_line_rec.col1,
          p_col2  => p_is_line_rec.col2,
          p_col3  => p_is_line_rec.col3,
          p_col4  => p_is_line_rec.col4,
          p_col5  => p_is_line_rec.col5,
          p_col6  => p_is_line_rec.col6,
          p_col7  => p_is_line_rec.col7,
          p_col8  => p_is_line_rec.col8,
          p_col9  => p_is_line_rec.col9,
          p_col10  => p_is_line_rec.col10,
          p_col11  => p_is_line_rec.col11,
          p_col12  => p_is_line_rec.col12,
          p_col13  => p_is_line_rec.col13,
          p_col14  => p_is_line_rec.col14,
          p_col15  => p_is_line_rec.col15,
          p_col16  => p_is_line_rec.col16,
          p_col17  => p_is_line_rec.col17,
          p_col18  => p_is_line_rec.col18,
          p_col19  => p_is_line_rec.col19,
          p_col20  => p_is_line_rec.col20,
          p_col21  => p_is_line_rec.col21,
          p_col22  => p_is_line_rec.col22,
          p_col23  => p_is_line_rec.col23,
          p_col24  => p_is_line_rec.col24,
          p_col25  => p_is_line_rec.col25,
          p_col26  => p_is_line_rec.col26,
          p_col27  => p_is_line_rec.col27,
          p_col28  => p_is_line_rec.col28,
          p_col29  => p_is_line_rec.col29,
          p_col30  => p_is_line_rec.col30,
          p_col31  => p_is_line_rec.col31,
          p_col32  => p_is_line_rec.col32,
          p_col33  => p_is_line_rec.col33,
          p_col34  => p_is_line_rec.col34,
          p_col35  => p_is_line_rec.col35,
          p_col36  => p_is_line_rec.col36,
          p_col37  => p_is_line_rec.col37,
          p_col38  => p_is_line_rec.col38,
          p_col39  => p_is_line_rec.col39,
          p_col40  => p_is_line_rec.col40,
          p_col41  => p_is_line_rec.col41,
          p_col42  => p_is_line_rec.col42,
          p_col43  => p_is_line_rec.col43,
          p_col44  => p_is_line_rec.col44,
          p_col45  => p_is_line_rec.col45,
          p_col46  => p_is_line_rec.col46,
          p_col47  => p_is_line_rec.col47,
          p_col48  => p_is_line_rec.col48,
          p_col49  => p_is_line_rec.col49,
          p_col50  => p_is_line_rec.col50,
          p_col51  => p_is_line_rec.col51,
          p_col52  => p_is_line_rec.col52,
          p_col53  => p_is_line_rec.col53,
          p_col54  => p_is_line_rec.col54,
          p_col55  => p_is_line_rec.col55,
          p_col56  => p_is_line_rec.col56,
          p_col57  => p_is_line_rec.col57,
          p_col58  => p_is_line_rec.col58,
          p_col59  => p_is_line_rec.col59,
          p_col60  => p_is_line_rec.col60,
          p_col61  => p_is_line_rec.col61,
          p_col62  => p_is_line_rec.col62,
          p_col63  => p_is_line_rec.col63,
          p_col64  => p_is_line_rec.col64,
          p_col65  => p_is_line_rec.col65,
          p_col66  => p_is_line_rec.col66,
          p_col67  => p_is_line_rec.col67,
          p_col68  => p_is_line_rec.col68,
          p_col69  => p_is_line_rec.col69,
          p_col70  => p_is_line_rec.col70,
          p_col71  => p_is_line_rec.col71,
          p_col72  => p_is_line_rec.col72,
          p_col73  => p_is_line_rec.col73,
          p_col74  => p_is_line_rec.col74,
          p_col75  => p_is_line_rec.col75,
          p_col76  => p_is_line_rec.col76,
          p_col77  => p_is_line_rec.col77,
          p_col78  => p_is_line_rec.col78,
          p_col79  => p_is_line_rec.col79,
          p_col80  => p_is_line_rec.col80,
          p_col81  => p_is_line_rec.col81,
          p_col82  => p_is_line_rec.col82,
          p_col83  => p_is_line_rec.col83,
          p_col84  => p_is_line_rec.col84,
          p_col85  => p_is_line_rec.col85,
          p_col86  => p_is_line_rec.col86,
          p_col87  => p_is_line_rec.col87,
          p_col88  => p_is_line_rec.col88,
          p_col89  => p_is_line_rec.col89,
          p_col90  => p_is_line_rec.col90,
          p_col91  => p_is_line_rec.col91,
          p_col92  => p_is_line_rec.col92,
          p_col93  => p_is_line_rec.col93,
          p_col94  => p_is_line_rec.col94,
          p_col95  => p_is_line_rec.col95,
          p_col96  => p_is_line_rec.col96,
          p_col97  => p_is_line_rec.col97,
          p_col98  => p_is_line_rec.col98,
          p_col99  => p_is_line_rec.col99,
          p_col100  => p_is_line_rec.col100,
          p_col101  => p_is_line_rec.col101,
          p_col102  => p_is_line_rec.col102,
          p_col103  => p_is_line_rec.col103,
          p_col104  => p_is_line_rec.col104,
          p_col105  => p_is_line_rec.col105,
          p_col106  => p_is_line_rec.col106,
          p_col107  => p_is_line_rec.col107,
          p_col108  => p_is_line_rec.col108,
          p_col109  => p_is_line_rec.col109,
          p_col110  => p_is_line_rec.col110,
          p_col111  => p_is_line_rec.col111,
          p_col112  => p_is_line_rec.col112,
          p_col113  => p_is_line_rec.col113,
          p_col114  => p_is_line_rec.col114,
          p_col115  => p_is_line_rec.col115,
          p_col116  => p_is_line_rec.col116,
          p_col117  => p_is_line_rec.col117,
          p_col118  => p_is_line_rec.col118,
          p_col119  => p_is_line_rec.col119,
          p_col120  => p_is_line_rec.col120,
          p_col121  => p_is_line_rec.col121,
          p_col122  => p_is_line_rec.col122,
          p_col123  => p_is_line_rec.col123,
          p_col124  => p_is_line_rec.col124,
          p_col125  => p_is_line_rec.col125,
          p_col126  => p_is_line_rec.col126,
          p_col127  => p_is_line_rec.col127,
          p_col128  => p_is_line_rec.col128,
          p_col129  => p_is_line_rec.col129,
          p_col130  => p_is_line_rec.col130,
          p_col131  => p_is_line_rec.col131,
          p_col132  => p_is_line_rec.col132,
          p_col133  => p_is_line_rec.col133,
          p_col134  => p_is_line_rec.col134,
          p_col135  => p_is_line_rec.col135,
          p_col136  => p_is_line_rec.col136,
          p_col137  => p_is_line_rec.col137,
          p_col138  => p_is_line_rec.col138,
          p_col139  => p_is_line_rec.col139,
          p_col140  => p_is_line_rec.col140,
          p_col141  => p_is_line_rec.col141,
          p_col142  => p_is_line_rec.col142,
          p_col143  => p_is_line_rec.col143,
          p_col144  => p_is_line_rec.col144,
          p_col145  => p_is_line_rec.col145,
          p_col146  => p_is_line_rec.col146,
          p_col147  => p_is_line_rec.col147,
          p_col148  => p_is_line_rec.col148,
          p_col149  => p_is_line_rec.col149,
          p_col150  => p_is_line_rec.col150,
          p_col151  => p_is_line_rec.col151,
          p_col152  => p_is_line_rec.col152,
          p_col153  => p_is_line_rec.col153,
          p_col154  => p_is_line_rec.col154,
          p_col155  => p_is_line_rec.col155,
          p_col156  => p_is_line_rec.col156,
          p_col157  => p_is_line_rec.col157,
          p_col158  => p_is_line_rec.col158,
          p_col159  => p_is_line_rec.col159,
          p_col160  => p_is_line_rec.col160,
          p_col161  => p_is_line_rec.col161,
          p_col162  => p_is_line_rec.col162,
          p_col163  => p_is_line_rec.col163,
          p_col164  => p_is_line_rec.col164,
          p_col165  => p_is_line_rec.col165,
          p_col166  => p_is_line_rec.col166,
          p_col167  => p_is_line_rec.col167,
          p_col168  => p_is_line_rec.col168,
          p_col169  => p_is_line_rec.col169,
          p_col170  => p_is_line_rec.col170,
          p_col171  => p_is_line_rec.col171,
          p_col172  => p_is_line_rec.col172,
          p_col173  => p_is_line_rec.col173,
          p_col174  => p_is_line_rec.col174,
          p_col175  => p_is_line_rec.col175,
          p_col176  => p_is_line_rec.col176,
          p_col177  => p_is_line_rec.col177,
          p_col178  => p_is_line_rec.col178,
          p_col179  => p_is_line_rec.col179,
          p_col180  => p_is_line_rec.col180,
          p_col181  => p_is_line_rec.col181,
          p_col182  => p_is_line_rec.col182,
          p_col183  => p_is_line_rec.col183,
          p_col184  => p_is_line_rec.col184,
          p_col185  => p_is_line_rec.col185,
          p_col186  => p_is_line_rec.col186,
          p_col187  => p_is_line_rec.col187,
          p_col188  => p_is_line_rec.col188,
          p_col189  => p_is_line_rec.col189,
          p_col190  => p_is_line_rec.col190,
          p_col191  => p_is_line_rec.col191,
          p_col192  => p_is_line_rec.col192,
          p_col193  => p_is_line_rec.col193,
          p_col194  => p_is_line_rec.col194,
          p_col195  => p_is_line_rec.col195,
          p_col196  => p_is_line_rec.col196,
          p_col197  => p_is_line_rec.col197,
          p_col198  => p_is_line_rec.col198,
          p_col199  => p_is_line_rec.col199,
          p_col200  => p_is_line_rec.col200,
          p_col201  => p_is_line_rec.col201,
          p_col202  => p_is_line_rec.col202,
          p_col203  => p_is_line_rec.col203,
          p_col204  => p_is_line_rec.col204,
          p_col205  => p_is_line_rec.col205,
          p_col206  => p_is_line_rec.col206,
          p_col207  => p_is_line_rec.col207,
          p_col208  => p_is_line_rec.col208,
          p_col209  => p_is_line_rec.col209,
          p_col210  => p_is_line_rec.col210,
          p_col211  => p_is_line_rec.col211,
          p_col212  => p_is_line_rec.col212,
          p_col213  => p_is_line_rec.col213,
          p_col214  => p_is_line_rec.col214,
          p_col215  => p_is_line_rec.col215,
          p_col216  => p_is_line_rec.col216,
          p_col217  => p_is_line_rec.col217,
          p_col218  => p_is_line_rec.col218,
          p_col219  => p_is_line_rec.col219,
          p_col220  => p_is_line_rec.col220,
          p_col221  => p_is_line_rec.col221,
          p_col222  => p_is_line_rec.col222,
          p_col223  => p_is_line_rec.col223,
          p_col224  => p_is_line_rec.col224,
          p_col225  => p_is_line_rec.col225,
          p_col226  => p_is_line_rec.col226,
          p_col227  => p_is_line_rec.col227,
          p_col228  => p_is_line_rec.col228,
          p_col229  => p_is_line_rec.col229,
          p_col230  => p_is_line_rec.col230,
          p_col231  => p_is_line_rec.col231,
          p_col232  => p_is_line_rec.col232,
          p_col233  => p_is_line_rec.col233,
          p_col234  => p_is_line_rec.col234,
          p_col235  => p_is_line_rec.col235,
          p_col236  => p_is_line_rec.col236,
          p_col237  => p_is_line_rec.col237,
          p_col238  => p_is_line_rec.col238,
          p_col239  => p_is_line_rec.col239,
          p_col240  => p_is_line_rec.col240,
          p_col241  => p_is_line_rec.col241,
          p_col242  => p_is_line_rec.col242,
          p_col243  => p_is_line_rec.col243,
          p_col244  => p_is_line_rec.col244,
          p_col245  => p_is_line_rec.col245,
          p_col246  => p_is_line_rec.col246,
          p_col247  => p_is_line_rec.col247,
          p_col248  => p_is_line_rec.col248,
          p_col249  => p_is_line_rec.col249,
          p_col250  => p_is_line_rec.col250,
          p_duplicate_flag  => p_is_line_rec.duplicate_flag,
          p_current_usage  => p_is_line_rec.current_usage,
	  p_notes   => p_is_line_rec.notes,
	  p_sales_agent_email_address => p_is_line_rec.sales_agent_email_address,
	  p_vehicle_response_code => p_is_line_rec.vehicle_response_code,
      p_custom_column1 => p_is_line_rec.custom_column1,
        p_custom_column2 => p_is_line_rec.custom_column2,
        p_custom_column3 => p_is_line_rec.custom_column3,
        p_custom_column4 => p_is_line_rec.custom_column4,
        p_custom_column5 => p_is_line_rec.custom_column5,
        p_custom_column6 => p_is_line_rec.custom_column6,
        p_custom_column7 => p_is_line_rec.custom_column7,
        p_custom_column8 => p_is_line_rec.custom_column8,
        p_custom_column9 => p_is_line_rec.custom_column9,
        p_custom_column10 => p_is_line_rec.custom_column10,
        p_custom_column11 => p_is_line_rec.custom_column11,
        p_custom_column12 => p_is_line_rec.custom_column12,
        p_custom_column13 => p_is_line_rec.custom_column13,
        p_custom_column14 => p_is_line_rec.custom_column14,
        p_custom_column15 => p_is_line_rec.custom_column15,
        p_custom_column16 => p_is_line_rec.custom_column16,
        p_custom_column17 => p_is_line_rec.custom_column17,
        p_custom_column18 => p_is_line_rec.custom_column18,
        p_custom_column19 => p_is_line_rec.custom_column19,
        p_custom_column20 => p_is_line_rec.custom_column20,
        p_custom_column21 => p_is_line_rec.custom_column21,
        p_custom_column22 => p_is_line_rec.custom_column22,
        p_custom_column23 => p_is_line_rec.custom_column23,
        p_custom_column24 => p_is_line_rec.custom_column24,
        p_custom_column25 => p_is_line_rec.custom_column25

      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      x_import_source_line_id := l_import_source_line_id;
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
     ROLLBACK TO CREATE_Is_Line_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Is_Line_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Is_Line_PVT;
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
End Create_Is_Line;


PROCEDURE Update_Is_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_is_line_rec               IN    is_line_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS

CURSOR c_get_is_line(import_source_line_id NUMBER) IS
    SELECT *
    FROM  AMS_IMP_SOURCE_LINES
    where import_source_line_id=p_is_line_rec.import_source_line_id;

CURSOR c_get_batch_id IS
    SELECT AS_IMPORT_INTERFACE_S.NEXTVAL
    FROM  DUAL;

    -- Hint: Developer need to provide Where clause

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Is_Line';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_IMPORT_SOURCE_LINE_ID    NUMBER;
l_ref_is_line_rec  c_get_Is_Line%ROWTYPE ;
l_tar_is_line_rec  AMS_Is_Line_PVT.is_line_rec_type := P_is_line_rec;
l_rowid  ROWID;
l_batchId NUMBER;
 l_user_status_id NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Is_Line_PVT;

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


      OPEN  c_get_Is_Line( l_tar_is_line_rec.import_source_line_id);
      FETCH c_get_Is_Line INTO l_ref_is_line_rec  ;
      CLOSE c_get_Is_Line;
      if (l_ref_is_line_rec.load_status = 'DUPLICATE') then
        -- p_is_line_rec.duplicate_flag := 'N';
        l_tar_is_line_rec.duplicate_flag := 'N';
      end if;


/*
       If ( c_get_Is_Line%NOTFOUND) THEN
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Is_Line') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_Is_Line;
*/


      If (l_tar_is_line_rec.object_version_number is NULL or
          l_tar_is_line_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'OBJECT_VERSION_NUMBER') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_is_line_rec.object_version_number <> l_ref_is_line_rec.object_version_number) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Is_Line') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Is_Line');
          END IF;

          -- Invoke validation procedures
          Validate_is_line(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_is_line_rec  =>  p_is_line_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: Calling update table handler');
      END IF;



      -- Invoke table handler(AMS_IMP_SOURCE_LINES_PKG.Update_Row)
      AMS_IMP_SOURCE_LINES_PKG.Update_Row(
            p_import_source_line_id  => p_is_line_rec.import_source_line_id,
            p_object_version_number  => p_is_line_rec.object_version_number,
            p_last_update_date  => SYSDATE,
            p_last_updated_by  => FND_GLOBAL.USER_ID,
            p_creation_date  => SYSDATE,
            p_created_by  => FND_GLOBAL.USER_ID,
            p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
            p_import_list_header_id  => p_is_line_rec.import_list_header_id,
            p_import_successful_flag  => p_is_line_rec.import_successful_flag,
            p_enabled_flag  => p_is_line_rec.enabled_flag,
            p_import_failure_reason  => p_is_line_rec.import_failure_reason,
            p_re_import_last_done_date  => p_is_line_rec.re_import_last_done_date,
            p_party_id  => p_is_line_rec.party_id,
            p_dedupe_key  => p_is_line_rec.dedupe_key,
            p_col1  => p_is_line_rec.col1,
            p_col2  => p_is_line_rec.col2,
            p_col3  => p_is_line_rec.col3,
            p_col4  => p_is_line_rec.col4,
            p_col5  => p_is_line_rec.col5,
            p_col6  => p_is_line_rec.col6,
            p_col7  => p_is_line_rec.col7,
            p_col8  => p_is_line_rec.col8,
            p_col9  => p_is_line_rec.col9,
            p_col10  => p_is_line_rec.col10,
            p_col11  => p_is_line_rec.col11,
            p_col12  => p_is_line_rec.col12,
            p_col13  => p_is_line_rec.col13,
            p_col14  => p_is_line_rec.col14,
            p_col15  => p_is_line_rec.col15,
            p_col16  => p_is_line_rec.col16,
            p_col17  => p_is_line_rec.col17,
            p_col18  => p_is_line_rec.col18,
            p_col19  => p_is_line_rec.col19,
            p_col20  => p_is_line_rec.col20,
            p_col21  => p_is_line_rec.col21,
            p_col22  => p_is_line_rec.col22,
            p_col23  => p_is_line_rec.col23,
            p_col24  => p_is_line_rec.col24,
            p_col25  => p_is_line_rec.col25,
            p_col26  => p_is_line_rec.col26,
            p_col27  => p_is_line_rec.col27,
            p_col28  => p_is_line_rec.col28,
            p_col29  => p_is_line_rec.col29,
            p_col30  => p_is_line_rec.col30,
            p_col31  => p_is_line_rec.col31,
            p_col32  => p_is_line_rec.col32,
            p_col33  => p_is_line_rec.col33,
            p_col34  => p_is_line_rec.col34,
            p_col35  => p_is_line_rec.col35,
            p_col36  => p_is_line_rec.col36,
            p_col37  => p_is_line_rec.col37,
            p_col38  => p_is_line_rec.col38,
            p_col39  => p_is_line_rec.col39,
            p_col40  => p_is_line_rec.col40,
            p_col41  => p_is_line_rec.col41,
            p_col42  => p_is_line_rec.col42,
            p_col43  => p_is_line_rec.col43,
            p_col44  => p_is_line_rec.col44,
            p_col45  => p_is_line_rec.col45,
            p_col46  => p_is_line_rec.col46,
            p_col47  => p_is_line_rec.col47,
            p_col48  => p_is_line_rec.col48,
            p_col49  => p_is_line_rec.col49,
            p_col50  => p_is_line_rec.col50,
            p_col51  => p_is_line_rec.col51,
            p_col52  => p_is_line_rec.col52,
            p_col53  => p_is_line_rec.col53,
            p_col54  => p_is_line_rec.col54,
            p_col55  => p_is_line_rec.col55,
            p_col56  => p_is_line_rec.col56,
            p_col57  => p_is_line_rec.col57,
            p_col58  => p_is_line_rec.col58,
            p_col59  => p_is_line_rec.col59,
            p_col60  => p_is_line_rec.col60,
            p_col61  => p_is_line_rec.col61,
            p_col62  => p_is_line_rec.col62,
            p_col63  => p_is_line_rec.col63,
            p_col64  => p_is_line_rec.col64,
            p_col65  => p_is_line_rec.col65,
            p_col66  => p_is_line_rec.col66,
            p_col67  => p_is_line_rec.col67,
            p_col68  => p_is_line_rec.col68,
            p_col69  => p_is_line_rec.col69,
            p_col70  => p_is_line_rec.col70,
            p_col71  => p_is_line_rec.col71,
            p_col72  => p_is_line_rec.col72,
            p_col73  => p_is_line_rec.col73,
            p_col74  => p_is_line_rec.col74,
            p_col75  => p_is_line_rec.col75,
            p_col76  => p_is_line_rec.col76,
            p_col77  => p_is_line_rec.col77,
            p_col78  => p_is_line_rec.col78,
            p_col79  => p_is_line_rec.col79,
            p_col80  => p_is_line_rec.col80,
            p_col81  => p_is_line_rec.col81,
            p_col82  => p_is_line_rec.col82,
            p_col83  => p_is_line_rec.col83,
            p_col84  => p_is_line_rec.col84,
            p_col85  => p_is_line_rec.col85,
            p_col86  => p_is_line_rec.col86,
            p_col87  => p_is_line_rec.col87,
            p_col88  => p_is_line_rec.col88,
            p_col89  => p_is_line_rec.col89,
            p_col90  => p_is_line_rec.col90,
            p_col91  => p_is_line_rec.col91,
            p_col92  => p_is_line_rec.col92,
            p_col93  => p_is_line_rec.col93,
            p_col94  => p_is_line_rec.col94,
            p_col95  => p_is_line_rec.col95,
            p_col96  => p_is_line_rec.col96,
            p_col97  => p_is_line_rec.col97,
            p_col98  => p_is_line_rec.col98,
            p_col99  => p_is_line_rec.col99,
            p_col100  => p_is_line_rec.col100,
            p_col101  => p_is_line_rec.col101,
            p_col102  => p_is_line_rec.col102,
            p_col103  => p_is_line_rec.col103,
            p_col104  => p_is_line_rec.col104,
            p_col105  => p_is_line_rec.col105,
            p_col106  => p_is_line_rec.col106,
            p_col107  => p_is_line_rec.col107,
            p_col108  => p_is_line_rec.col108,
            p_col109  => p_is_line_rec.col109,
            p_col110  => p_is_line_rec.col110,
            p_col111  => p_is_line_rec.col111,
            p_col112  => p_is_line_rec.col112,
            p_col113  => p_is_line_rec.col113,
            p_col114  => p_is_line_rec.col114,
            p_col115  => p_is_line_rec.col115,
            p_col116  => p_is_line_rec.col116,
            p_col117  => p_is_line_rec.col117,
            p_col118  => p_is_line_rec.col118,
            p_col119  => p_is_line_rec.col119,
            p_col120  => p_is_line_rec.col120,
            p_col121  => p_is_line_rec.col121,
            p_col122  => p_is_line_rec.col122,
            p_col123  => p_is_line_rec.col123,
            p_col124  => p_is_line_rec.col124,
            p_col125  => p_is_line_rec.col125,
            p_col126  => p_is_line_rec.col126,
            p_col127  => p_is_line_rec.col127,
            p_col128  => p_is_line_rec.col128,
            p_col129  => p_is_line_rec.col129,
            p_col130  => p_is_line_rec.col130,
            p_col131  => p_is_line_rec.col131,
            p_col132  => p_is_line_rec.col132,
            p_col133  => p_is_line_rec.col133,
            p_col134  => p_is_line_rec.col134,
            p_col135  => p_is_line_rec.col135,
            p_col136  => p_is_line_rec.col136,
            p_col137  => p_is_line_rec.col137,
            p_col138  => p_is_line_rec.col138,
            p_col139  => p_is_line_rec.col139,
            p_col140  => p_is_line_rec.col140,
            p_col141  => p_is_line_rec.col141,
            p_col142  => p_is_line_rec.col142,
            p_col143  => p_is_line_rec.col143,
            p_col144  => p_is_line_rec.col144,
            p_col145  => p_is_line_rec.col145,
            p_col146  => p_is_line_rec.col146,
            p_col147  => p_is_line_rec.col147,
            p_col148  => p_is_line_rec.col148,
            p_col149  => p_is_line_rec.col149,
            p_col150  => p_is_line_rec.col150,
            p_col151  => p_is_line_rec.col151,
            p_col152  => p_is_line_rec.col152,
            p_col153  => p_is_line_rec.col153,
            p_col154  => p_is_line_rec.col154,
            p_col155  => p_is_line_rec.col155,
            p_col156  => p_is_line_rec.col156,
            p_col157  => p_is_line_rec.col157,
            p_col158  => p_is_line_rec.col158,
            p_col159  => p_is_line_rec.col159,
            p_col160  => p_is_line_rec.col160,
            p_col161  => p_is_line_rec.col161,
            p_col162  => p_is_line_rec.col162,
            p_col163  => p_is_line_rec.col163,
            p_col164  => p_is_line_rec.col164,
            p_col165  => p_is_line_rec.col165,
            p_col166  => p_is_line_rec.col166,
            p_col167  => p_is_line_rec.col167,
            p_col168  => p_is_line_rec.col168,
            p_col169  => p_is_line_rec.col169,
            p_col170  => p_is_line_rec.col170,
            p_col171  => p_is_line_rec.col171,
            p_col172  => p_is_line_rec.col172,
            p_col173  => p_is_line_rec.col173,
            p_col174  => p_is_line_rec.col174,
            p_col175  => p_is_line_rec.col175,
            p_col176  => p_is_line_rec.col176,
            p_col177  => p_is_line_rec.col177,
            p_col178  => p_is_line_rec.col178,
            p_col179  => p_is_line_rec.col179,
            p_col180  => p_is_line_rec.col180,
            p_col181  => p_is_line_rec.col181,
            p_col182  => p_is_line_rec.col182,
            p_col183  => p_is_line_rec.col183,
            p_col184  => p_is_line_rec.col184,
            p_col185  => p_is_line_rec.col185,
            p_col186  => p_is_line_rec.col186,
            p_col187  => p_is_line_rec.col187,
            p_col188  => p_is_line_rec.col188,
            p_col189  => p_is_line_rec.col189,
            p_col190  => p_is_line_rec.col190,
            p_col191  => p_is_line_rec.col191,
            p_col192  => p_is_line_rec.col192,
            p_col193  => p_is_line_rec.col193,
            p_col194  => p_is_line_rec.col194,
            p_col195  => p_is_line_rec.col195,
            p_col196  => p_is_line_rec.col196,
            p_col197  => p_is_line_rec.col197,
            p_col198  => p_is_line_rec.col198,
            p_col199  => p_is_line_rec.col199,
            p_col200  => p_is_line_rec.col200,
            p_col201  => p_is_line_rec.col201,
            p_col202  => p_is_line_rec.col202,
            p_col203  => p_is_line_rec.col203,
            p_col204  => p_is_line_rec.col204,
            p_col205  => p_is_line_rec.col205,
            p_col206  => p_is_line_rec.col206,
            p_col207  => p_is_line_rec.col207,
            p_col208  => p_is_line_rec.col208,
            p_col209  => p_is_line_rec.col209,
            p_col210  => p_is_line_rec.col210,
            p_col211  => p_is_line_rec.col211,
            p_col212  => p_is_line_rec.col212,
            p_col213  => p_is_line_rec.col213,
            p_col214  => p_is_line_rec.col214,
            p_col215  => p_is_line_rec.col215,
            p_col216  => p_is_line_rec.col216,
            p_col217  => p_is_line_rec.col217,
            p_col218  => p_is_line_rec.col218,
            p_col219  => p_is_line_rec.col219,
            p_col220  => p_is_line_rec.col220,
            p_col221  => p_is_line_rec.col221,
            p_col222  => p_is_line_rec.col222,
            p_col223  => p_is_line_rec.col223,
            p_col224  => p_is_line_rec.col224,
            p_col225  => p_is_line_rec.col225,
            p_col226  => p_is_line_rec.col226,
            p_col227  => p_is_line_rec.col227,
            p_col228  => p_is_line_rec.col228,
            p_col229  => p_is_line_rec.col229,
            p_col230  => p_is_line_rec.col230,
            p_col231  => p_is_line_rec.col231,
            p_col232  => p_is_line_rec.col232,
            p_col233  => p_is_line_rec.col233,
            p_col234  => p_is_line_rec.col234,
            p_col235  => p_is_line_rec.col235,
            p_col236  => p_is_line_rec.col236,
            p_col237  => p_is_line_rec.col237,
            p_col238  => p_is_line_rec.col238,
            p_col239  => p_is_line_rec.col239,
            p_col240  => p_is_line_rec.col240,
            p_col241  => p_is_line_rec.col241,
            p_col242  => p_is_line_rec.col242,
            p_col243  => p_is_line_rec.col243,
            p_col244  => p_is_line_rec.col244,
            p_col245  => p_is_line_rec.col245,
            p_col246  => p_is_line_rec.col246,
            p_col247  => p_is_line_rec.col247,
            p_col248  => p_is_line_rec.col248,
            p_col249  => p_is_line_rec.col249,
            p_col250  => p_is_line_rec.col250,
            -- p_duplicate_flag  => p_is_line_rec.duplicate_flag,
            p_duplicate_flag  => l_tar_is_line_rec.duplicate_flag,
            p_current_usage  => p_is_line_rec.current_usage,
            p_load_status => 'RELOAD',
            p_notes   => p_is_line_rec.notes,
            p_sales_agent_email_address => p_is_line_rec.sales_agent_email_address,
            p_vehicle_response_code => p_is_line_rec.vehicle_response_code,
            p_custom_column1 => p_is_line_rec.custom_column1,
            p_custom_column2 => p_is_line_rec.custom_column2,
            p_custom_column3 => p_is_line_rec.custom_column3,
            p_custom_column4 => p_is_line_rec.custom_column4,
            p_custom_column5 => p_is_line_rec.custom_column5,
            p_custom_column6 => p_is_line_rec.custom_column6,
            p_custom_column7 => p_is_line_rec.custom_column7,
            p_custom_column8 => p_is_line_rec.custom_column8,
            p_custom_column9 => p_is_line_rec.custom_column9,
            p_custom_column10 => p_is_line_rec.custom_column10,
            p_custom_column11 => p_is_line_rec.custom_column11,
            p_custom_column12 => p_is_line_rec.custom_column12,
            p_custom_column13 => p_is_line_rec.custom_column13,
            p_custom_column14 => p_is_line_rec.custom_column14,
            p_custom_column15 => p_is_line_rec.custom_column15,
            p_custom_column16 => p_is_line_rec.custom_column16,
            p_custom_column17 => p_is_line_rec.custom_column17,
            p_custom_column18 => p_is_line_rec.custom_column18,
            p_custom_column19 => p_is_line_rec.custom_column19,
            p_custom_column20 => p_is_line_rec.custom_column20,
            p_custom_column21 => p_is_line_rec.custom_column21,
            p_custom_column22 => p_is_line_rec.custom_column22,
            p_custom_column23 => p_is_line_rec.custom_column23,
            p_custom_column24 => p_is_line_rec.custom_column24,
            p_custom_column25 => p_is_line_rec.custom_column25


	  );       --For Error handling and Correction Update LOAD_STATUS = 'RELOAD'


	--In  AMS_IMP_LIST_HEADERS_ALL
        --1. Increment BATCH_ID FROM AS_IMPORT_INTERFACE_S SEQUENCE.
        --2. Update the STATUS_CODE = 'STAGED'
        --3. Update EXECUTE_MODE = 'R'

      /*   OPEN c_get_batch_id;
         FETCH c_get_batch_id INTO l_batchId;
         CLOSE c_get_batch_id;

	 l_user_status_id := null;
	 SELECT user_status_id into l_user_status_id FROM ams_user_statuses_vl
	 WHERE system_status_type = 'AMS_IMPORT_STATUS' AND
         system_status_code = 'STAGED';
*/

	UPDATE ams_imp_list_headers_all
	SET
	--  batch_id =l_batchId
	-- , status_code = 'STAGED'
	 execute_mode = 'R'
	-- , user_status_id = l_user_status_id
        WHERE import_list_header_id=p_is_line_rec.import_list_header_id
	--AND STATUS_CODE <> 'STAGED'
	--AND user_status_id <> l_user_status_id;
	AND execute_mode <> 'R';


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
     ROLLBACK TO UPDATE_Is_Line_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Is_Line_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Is_Line_PVT;
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
End Update_Is_Line;


PROCEDURE Delete_Is_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_import_source_line_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Is_Line';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Is_Line_PVT;

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

      -- Invoke table handler(AMS_IMP_SOURCE_LINES_PKG.Delete_Row)
      AMS_IMP_SOURCE_LINES_PKG.Delete_Row(
          p_IMPORT_SOURCE_LINE_ID  => p_IMPORT_SOURCE_LINE_ID);
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
     ROLLBACK TO DELETE_Is_Line_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Is_Line_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Is_Line_PVT;
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
End Delete_Is_Line;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Is_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_import_source_line_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Is_Line';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_IMPORT_SOURCE_LINE_ID                  NUMBER;

CURSOR c_Is_Line IS
   SELECT IMPORT_SOURCE_LINE_ID
   FROM AMS_IMP_SOURCE_LINES
   WHERE IMPORT_SOURCE_LINE_ID = p_IMPORT_SOURCE_LINE_ID
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
  OPEN c_Is_Line;

  FETCH c_Is_Line INTO l_IMPORT_SOURCE_LINE_ID;

  IF (c_Is_Line%NOTFOUND) THEN
    CLOSE c_Is_Line;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Is_Line;

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
     ROLLBACK TO LOCK_Is_Line_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Is_Line_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Is_Line_PVT;
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
End Lock_Is_Line;


PROCEDURE check_is_line_uk_items(
    p_is_line_rec               IN   is_line_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_IMP_SOURCE_LINES',
         'IMPORT_SOURCE_LINE_ID = ''' || p_is_line_rec.IMPORT_SOURCE_LINE_ID ||''''
         );
      ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_IMP_SOURCE_LINES',
         'IMPORT_SOURCE_LINE_ID = ''' || p_is_line_rec.IMPORT_SOURCE_LINE_ID ||
         ''' AND IMPORT_SOURCE_LINE_ID <> ' || p_is_line_rec.IMPORT_SOURCE_LINE_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_IMPORT_SOURCE_LINE_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

END check_is_line_uk_items;

PROCEDURE check_is_line_req_items(
    p_is_line_rec               IN  is_line_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_is_line_rec.import_source_line_id = FND_API.g_miss_num OR p_is_line_rec.import_source_line_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_is_line_NO_import_source_line_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_is_line_rec.last_update_date = FND_API.g_miss_date OR p_is_line_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_is_line_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_is_line_rec.last_updated_by = FND_API.g_miss_num OR p_is_line_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_is_line_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_is_line_rec.creation_date = FND_API.g_miss_date OR p_is_line_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_is_line_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_is_line_rec.created_by = FND_API.g_miss_num OR p_is_line_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_is_line_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_is_line_rec.last_update_login = FND_API.g_miss_num OR p_is_line_rec.last_update_login IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_is_line_NO_last_update_login');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_is_line_rec.import_list_header_id = FND_API.g_miss_num OR p_is_line_rec.import_list_header_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'NO_import_list_header_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_is_line_rec.import_successful_flag = FND_API.g_miss_char OR p_is_line_rec.import_successful_flag IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'NO_import_successful_flag');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE


      IF p_is_line_rec.import_source_line_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'NO_import_source_line_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_is_line_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_is_line_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_is_line_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_is_line_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_is_line_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_is_line_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_is_line_rec.last_update_login IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_is_line_NO_last_update_login');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_is_line_rec.import_list_header_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'NO_import_list_header_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_is_line_rec.import_successful_flag IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'NO_import_successful_flag');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_is_line_req_items;

PROCEDURE check_is_line_FK_items(
    p_is_line_rec IN is_line_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_is_line_FK_items;

PROCEDURE check_is_line_Lookup_items(
    p_is_line_rec IN is_line_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_is_line_Lookup_items;

PROCEDURE Check_is_line_Items (
    P_is_line_rec     IN    is_line_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_is_line_uk_items(
      p_is_line_rec => p_is_line_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_is_line_req_items(
      p_is_line_rec => p_is_line_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   check_is_line_FK_items(
      p_is_line_rec => p_is_line_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

   check_is_line_Lookup_items(
      p_is_line_rec => p_is_line_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_is_line_Items;


PROCEDURE Complete_is_line_Rec (
   p_is_line_rec IN is_line_rec_type,
   x_complete_rec OUT NOCOPY is_line_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_imp_source_lines
      WHERE import_source_line_id = p_is_line_rec.import_source_line_id;
   l_is_line_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_is_line_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_is_line_rec;
   CLOSE c_complete;

   -- import_source_line_id
   IF p_is_line_rec.import_source_line_id = FND_API.g_miss_num THEN
      x_complete_rec.import_source_line_id := l_is_line_rec.import_source_line_id;
   END IF;

   -- object_version_number
   IF p_is_line_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_is_line_rec.object_version_number;
   END IF;

   -- last_update_date
   IF p_is_line_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_is_line_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_is_line_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_is_line_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_is_line_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_is_line_rec.creation_date;
   END IF;

   -- created_by
   IF p_is_line_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_is_line_rec.created_by;
   END IF;

   -- last_update_login
   IF p_is_line_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_is_line_rec.last_update_login;
   END IF;

   -- import_list_header_id
   IF p_is_line_rec.import_list_header_id = FND_API.g_miss_num THEN
      x_complete_rec.import_list_header_id := l_is_line_rec.import_list_header_id;
   END IF;

   -- import_successful_flag
   IF p_is_line_rec.import_successful_flag = FND_API.g_miss_char THEN
      x_complete_rec.import_successful_flag := l_is_line_rec.import_successful_flag;
   END IF;

   -- enabled_flag
   IF p_is_line_rec.enabled_flag = FND_API.g_miss_char THEN
      x_complete_rec.enabled_flag := l_is_line_rec.enabled_flag;
   END IF;

   -- import_failure_reason
   IF p_is_line_rec.import_failure_reason = FND_API.g_miss_char THEN
      x_complete_rec.import_failure_reason := l_is_line_rec.import_failure_reason;
   END IF;

   -- re_import_last_done_date
   IF p_is_line_rec.re_import_last_done_date = FND_API.g_miss_date THEN
      x_complete_rec.re_import_last_done_date := l_is_line_rec.re_import_last_done_date;
   END IF;

   -- party_id
   IF p_is_line_rec.party_id = FND_API.g_miss_num THEN
      x_complete_rec.party_id := l_is_line_rec.party_id;
   END IF;

   -- dedupe_key
   IF p_is_line_rec.dedupe_key = FND_API.g_miss_char THEN
      x_complete_rec.dedupe_key := l_is_line_rec.dedupe_key;
   END IF;

   -- col1
   IF p_is_line_rec.col1 = FND_API.g_miss_char THEN
      x_complete_rec.col1 := l_is_line_rec.col1;
   END IF;

   -- col2
   IF p_is_line_rec.col2 = FND_API.g_miss_char THEN
      x_complete_rec.col2 := l_is_line_rec.col2;
   END IF;

   -- col3
   IF p_is_line_rec.col3 = FND_API.g_miss_char THEN
      x_complete_rec.col3 := l_is_line_rec.col3;
   END IF;

   -- col4
   IF p_is_line_rec.col4 = FND_API.g_miss_char THEN
      x_complete_rec.col4 := l_is_line_rec.col4;
   END IF;

   -- col5
   IF p_is_line_rec.col5 = FND_API.g_miss_char THEN
      x_complete_rec.col5 := l_is_line_rec.col5;
   END IF;

   -- col6
   IF p_is_line_rec.col6 = FND_API.g_miss_char THEN
      x_complete_rec.col6 := l_is_line_rec.col6;
   END IF;

   -- col7
   IF p_is_line_rec.col7 = FND_API.g_miss_char THEN
      x_complete_rec.col7 := l_is_line_rec.col7;
   END IF;

   -- col8
   IF p_is_line_rec.col8 = FND_API.g_miss_char THEN
      x_complete_rec.col8 := l_is_line_rec.col8;
   END IF;

   -- col9
   IF p_is_line_rec.col9 = FND_API.g_miss_char THEN
      x_complete_rec.col9 := l_is_line_rec.col9;
   END IF;

   -- col10
   IF p_is_line_rec.col10 = FND_API.g_miss_char THEN
      x_complete_rec.col10 := l_is_line_rec.col10;
   END IF;

   -- col11
   IF p_is_line_rec.col11 = FND_API.g_miss_char THEN
      x_complete_rec.col11 := l_is_line_rec.col11;
   END IF;

   -- col12
   IF p_is_line_rec.col12 = FND_API.g_miss_char THEN
      x_complete_rec.col12 := l_is_line_rec.col12;
   END IF;

   -- col13
   IF p_is_line_rec.col13 = FND_API.g_miss_char THEN
      x_complete_rec.col13 := l_is_line_rec.col13;
   END IF;

   -- col14
   IF p_is_line_rec.col14 = FND_API.g_miss_char THEN
      x_complete_rec.col14 := l_is_line_rec.col14;
   END IF;

   -- col15
   IF p_is_line_rec.col15 = FND_API.g_miss_char THEN
      x_complete_rec.col15 := l_is_line_rec.col15;
   END IF;

   -- col16
   IF p_is_line_rec.col16 = FND_API.g_miss_char THEN
      x_complete_rec.col16 := l_is_line_rec.col16;
   END IF;

   -- col17
   IF p_is_line_rec.col17 = FND_API.g_miss_char THEN
      x_complete_rec.col17 := l_is_line_rec.col17;
   END IF;

   -- col18
   IF p_is_line_rec.col18 = FND_API.g_miss_char THEN
      x_complete_rec.col18 := l_is_line_rec.col18;
   END IF;

   -- col19
   IF p_is_line_rec.col19 = FND_API.g_miss_char THEN
      x_complete_rec.col19 := l_is_line_rec.col19;
   END IF;

   -- col20
   IF p_is_line_rec.col20 = FND_API.g_miss_char THEN
      x_complete_rec.col20 := l_is_line_rec.col20;
   END IF;

   -- col21
   IF p_is_line_rec.col21 = FND_API.g_miss_char THEN
      x_complete_rec.col21 := l_is_line_rec.col21;
   END IF;

   -- col22
   IF p_is_line_rec.col22 = FND_API.g_miss_char THEN
      x_complete_rec.col22 := l_is_line_rec.col22;
   END IF;

   -- col23
   IF p_is_line_rec.col23 = FND_API.g_miss_char THEN
      x_complete_rec.col23 := l_is_line_rec.col23;
   END IF;

   -- col24
   IF p_is_line_rec.col24 = FND_API.g_miss_char THEN
      x_complete_rec.col24 := l_is_line_rec.col24;
   END IF;

   -- col25
   IF p_is_line_rec.col25 = FND_API.g_miss_char THEN
      x_complete_rec.col25 := l_is_line_rec.col25;
   END IF;

   -- col26
   IF p_is_line_rec.col26 = FND_API.g_miss_char THEN
      x_complete_rec.col26 := l_is_line_rec.col26;
   END IF;

   -- col27
   IF p_is_line_rec.col27 = FND_API.g_miss_char THEN
      x_complete_rec.col27 := l_is_line_rec.col27;
   END IF;

   -- col28
   IF p_is_line_rec.col28 = FND_API.g_miss_char THEN
      x_complete_rec.col28 := l_is_line_rec.col28;
   END IF;

   -- col29
   IF p_is_line_rec.col29 = FND_API.g_miss_char THEN
      x_complete_rec.col29 := l_is_line_rec.col29;
   END IF;

   -- col30
   IF p_is_line_rec.col30 = FND_API.g_miss_char THEN
      x_complete_rec.col30 := l_is_line_rec.col30;
   END IF;

   -- col31
   IF p_is_line_rec.col31 = FND_API.g_miss_char THEN
      x_complete_rec.col31 := l_is_line_rec.col31;
   END IF;

   -- col32
   IF p_is_line_rec.col32 = FND_API.g_miss_char THEN
      x_complete_rec.col32 := l_is_line_rec.col32;
   END IF;

   -- col33
   IF p_is_line_rec.col33 = FND_API.g_miss_char THEN
      x_complete_rec.col33 := l_is_line_rec.col33;
   END IF;

   -- col34
   IF p_is_line_rec.col34 = FND_API.g_miss_char THEN
      x_complete_rec.col34 := l_is_line_rec.col34;
   END IF;

   -- col35
   IF p_is_line_rec.col35 = FND_API.g_miss_char THEN
      x_complete_rec.col35 := l_is_line_rec.col35;
   END IF;

   -- col36
   IF p_is_line_rec.col36 = FND_API.g_miss_char THEN
      x_complete_rec.col36 := l_is_line_rec.col36;
   END IF;

   -- col37
   IF p_is_line_rec.col37 = FND_API.g_miss_char THEN
      x_complete_rec.col37 := l_is_line_rec.col37;
   END IF;

   -- col38
   IF p_is_line_rec.col38 = FND_API.g_miss_char THEN
      x_complete_rec.col38 := l_is_line_rec.col38;
   END IF;

   -- col39
   IF p_is_line_rec.col39 = FND_API.g_miss_char THEN
      x_complete_rec.col39 := l_is_line_rec.col39;
   END IF;

   -- col40
   IF p_is_line_rec.col40 = FND_API.g_miss_char THEN
      x_complete_rec.col40 := l_is_line_rec.col40;
   END IF;

   -- col41
   IF p_is_line_rec.col41 = FND_API.g_miss_char THEN
      x_complete_rec.col41 := l_is_line_rec.col41;
   END IF;

   -- col42
   IF p_is_line_rec.col42 = FND_API.g_miss_char THEN
      x_complete_rec.col42 := l_is_line_rec.col42;
   END IF;

   -- col43
   IF p_is_line_rec.col43 = FND_API.g_miss_char THEN
      x_complete_rec.col43 := l_is_line_rec.col43;
   END IF;

   -- col44
   IF p_is_line_rec.col44 = FND_API.g_miss_char THEN
      x_complete_rec.col44 := l_is_line_rec.col44;
   END IF;

   -- col45
   IF p_is_line_rec.col45 = FND_API.g_miss_char THEN
      x_complete_rec.col45 := l_is_line_rec.col45;
   END IF;

   -- col46
   IF p_is_line_rec.col46 = FND_API.g_miss_char THEN
      x_complete_rec.col46 := l_is_line_rec.col46;
   END IF;

   -- col47
   IF p_is_line_rec.col47 = FND_API.g_miss_char THEN
      x_complete_rec.col47 := l_is_line_rec.col47;
   END IF;

   -- col48
   IF p_is_line_rec.col48 = FND_API.g_miss_char THEN
      x_complete_rec.col48 := l_is_line_rec.col48;
   END IF;

   -- col49
   IF p_is_line_rec.col49 = FND_API.g_miss_char THEN
      x_complete_rec.col49 := l_is_line_rec.col49;
   END IF;

   -- col50
   IF p_is_line_rec.col50 = FND_API.g_miss_char THEN
      x_complete_rec.col50 := l_is_line_rec.col50;
   END IF;

   -- col51
   IF p_is_line_rec.col51 = FND_API.g_miss_char THEN
      x_complete_rec.col51 := l_is_line_rec.col51;
   END IF;

   -- col52
   IF p_is_line_rec.col52 = FND_API.g_miss_char THEN
      x_complete_rec.col52 := l_is_line_rec.col52;
   END IF;

   -- col53
   IF p_is_line_rec.col53 = FND_API.g_miss_char THEN
      x_complete_rec.col53 := l_is_line_rec.col53;
   END IF;

   -- col54
   IF p_is_line_rec.col54 = FND_API.g_miss_char THEN
      x_complete_rec.col54 := l_is_line_rec.col54;
   END IF;

   -- col55
   IF p_is_line_rec.col55 = FND_API.g_miss_char THEN
      x_complete_rec.col55 := l_is_line_rec.col55;
   END IF;

   -- col56
   IF p_is_line_rec.col56 = FND_API.g_miss_char THEN
      x_complete_rec.col56 := l_is_line_rec.col56;
   END IF;

   -- col57
   IF p_is_line_rec.col57 = FND_API.g_miss_char THEN
      x_complete_rec.col57 := l_is_line_rec.col57;
   END IF;

   -- col58
   IF p_is_line_rec.col58 = FND_API.g_miss_char THEN
      x_complete_rec.col58 := l_is_line_rec.col58;
   END IF;

   -- col59
   IF p_is_line_rec.col59 = FND_API.g_miss_char THEN
      x_complete_rec.col59 := l_is_line_rec.col59;
   END IF;

   -- col60
   IF p_is_line_rec.col60 = FND_API.g_miss_char THEN
      x_complete_rec.col60 := l_is_line_rec.col60;
   END IF;

   -- col61
   IF p_is_line_rec.col61 = FND_API.g_miss_char THEN
      x_complete_rec.col61 := l_is_line_rec.col61;
   END IF;

   -- col62
   IF p_is_line_rec.col62 = FND_API.g_miss_char THEN
      x_complete_rec.col62 := l_is_line_rec.col62;
   END IF;

   -- col63
   IF p_is_line_rec.col63 = FND_API.g_miss_char THEN
      x_complete_rec.col63 := l_is_line_rec.col63;
   END IF;

   -- col64
   IF p_is_line_rec.col64 = FND_API.g_miss_char THEN
      x_complete_rec.col64 := l_is_line_rec.col64;
   END IF;

   -- col65
   IF p_is_line_rec.col65 = FND_API.g_miss_char THEN
      x_complete_rec.col65 := l_is_line_rec.col65;
   END IF;

   -- col66
   IF p_is_line_rec.col66 = FND_API.g_miss_char THEN
      x_complete_rec.col66 := l_is_line_rec.col66;
   END IF;

   -- col67
   IF p_is_line_rec.col67 = FND_API.g_miss_char THEN
      x_complete_rec.col67 := l_is_line_rec.col67;
   END IF;

   -- col68
   IF p_is_line_rec.col68 = FND_API.g_miss_char THEN
      x_complete_rec.col68 := l_is_line_rec.col68;
   END IF;

   -- col69
   IF p_is_line_rec.col69 = FND_API.g_miss_char THEN
      x_complete_rec.col69 := l_is_line_rec.col69;
   END IF;

   -- col70
   IF p_is_line_rec.col70 = FND_API.g_miss_char THEN
      x_complete_rec.col70 := l_is_line_rec.col70;
   END IF;

   -- col71
   IF p_is_line_rec.col71 = FND_API.g_miss_char THEN
      x_complete_rec.col71 := l_is_line_rec.col71;
   END IF;

   -- col72
   IF p_is_line_rec.col72 = FND_API.g_miss_char THEN
      x_complete_rec.col72 := l_is_line_rec.col72;
   END IF;

   -- col73
   IF p_is_line_rec.col73 = FND_API.g_miss_char THEN
      x_complete_rec.col73 := l_is_line_rec.col73;
   END IF;

   -- col74
   IF p_is_line_rec.col74 = FND_API.g_miss_char THEN
      x_complete_rec.col74 := l_is_line_rec.col74;
   END IF;

   -- col75
   IF p_is_line_rec.col75 = FND_API.g_miss_char THEN
      x_complete_rec.col75 := l_is_line_rec.col75;
   END IF;

   -- col76
   IF p_is_line_rec.col76 = FND_API.g_miss_char THEN
      x_complete_rec.col76 := l_is_line_rec.col76;
   END IF;

   -- col77
   IF p_is_line_rec.col77 = FND_API.g_miss_char THEN
      x_complete_rec.col77 := l_is_line_rec.col77;
   END IF;

   -- col78
   IF p_is_line_rec.col78 = FND_API.g_miss_char THEN
      x_complete_rec.col78 := l_is_line_rec.col78;
   END IF;

   -- col79
   IF p_is_line_rec.col79 = FND_API.g_miss_char THEN
      x_complete_rec.col79 := l_is_line_rec.col79;
   END IF;

   -- col80
   IF p_is_line_rec.col80 = FND_API.g_miss_char THEN
      x_complete_rec.col80 := l_is_line_rec.col80;
   END IF;

   -- col81
   IF p_is_line_rec.col81 = FND_API.g_miss_char THEN
      x_complete_rec.col81 := l_is_line_rec.col81;
   END IF;

   -- col82
   IF p_is_line_rec.col82 = FND_API.g_miss_char THEN
      x_complete_rec.col82 := l_is_line_rec.col82;
   END IF;

   -- col83
   IF p_is_line_rec.col83 = FND_API.g_miss_char THEN
      x_complete_rec.col83 := l_is_line_rec.col83;
   END IF;

   -- col84
   IF p_is_line_rec.col84 = FND_API.g_miss_char THEN
      x_complete_rec.col84 := l_is_line_rec.col84;
   END IF;

   -- col85
   IF p_is_line_rec.col85 = FND_API.g_miss_char THEN
      x_complete_rec.col85 := l_is_line_rec.col85;
   END IF;

   -- col86
   IF p_is_line_rec.col86 = FND_API.g_miss_char THEN
      x_complete_rec.col86 := l_is_line_rec.col86;
   END IF;

   -- col87
   IF p_is_line_rec.col87 = FND_API.g_miss_char THEN
      x_complete_rec.col87 := l_is_line_rec.col87;
   END IF;

   -- col88
   IF p_is_line_rec.col88 = FND_API.g_miss_char THEN
      x_complete_rec.col88 := l_is_line_rec.col88;
   END IF;

   -- col89
   IF p_is_line_rec.col89 = FND_API.g_miss_char THEN
      x_complete_rec.col89 := l_is_line_rec.col89;
   END IF;

   -- col90
   IF p_is_line_rec.col90 = FND_API.g_miss_char THEN
      x_complete_rec.col90 := l_is_line_rec.col90;
   END IF;

   -- col91
   IF p_is_line_rec.col91 = FND_API.g_miss_char THEN
      x_complete_rec.col91 := l_is_line_rec.col91;
   END IF;

   -- col92
   IF p_is_line_rec.col92 = FND_API.g_miss_char THEN
      x_complete_rec.col92 := l_is_line_rec.col92;
   END IF;

   -- col93
   IF p_is_line_rec.col93 = FND_API.g_miss_char THEN
      x_complete_rec.col93 := l_is_line_rec.col93;
   END IF;

   -- col94
   IF p_is_line_rec.col94 = FND_API.g_miss_char THEN
      x_complete_rec.col94 := l_is_line_rec.col94;
   END IF;

   -- col95
   IF p_is_line_rec.col95 = FND_API.g_miss_char THEN
      x_complete_rec.col95 := l_is_line_rec.col95;
   END IF;

   -- col96
   IF p_is_line_rec.col96 = FND_API.g_miss_char THEN
      x_complete_rec.col96 := l_is_line_rec.col96;
   END IF;

   -- col97
   IF p_is_line_rec.col97 = FND_API.g_miss_char THEN
      x_complete_rec.col97 := l_is_line_rec.col97;
   END IF;

   -- col98
   IF p_is_line_rec.col98 = FND_API.g_miss_char THEN
      x_complete_rec.col98 := l_is_line_rec.col98;
   END IF;

   -- col99
   IF p_is_line_rec.col99 = FND_API.g_miss_char THEN
      x_complete_rec.col99 := l_is_line_rec.col99;
   END IF;

   -- col100
   IF p_is_line_rec.col100 = FND_API.g_miss_char THEN
      x_complete_rec.col100 := l_is_line_rec.col100;
   END IF;

   -- col101
   IF p_is_line_rec.col101 = FND_API.g_miss_char THEN
      x_complete_rec.col101 := l_is_line_rec.col101;
   END IF;

   -- col102
   IF p_is_line_rec.col102 = FND_API.g_miss_char THEN
      x_complete_rec.col102 := l_is_line_rec.col102;
   END IF;

   -- col103
   IF p_is_line_rec.col103 = FND_API.g_miss_char THEN
      x_complete_rec.col103 := l_is_line_rec.col103;
   END IF;

   -- col104
   IF p_is_line_rec.col104 = FND_API.g_miss_char THEN
      x_complete_rec.col104 := l_is_line_rec.col104;
   END IF;

   -- col105
   IF p_is_line_rec.col105 = FND_API.g_miss_char THEN
      x_complete_rec.col105 := l_is_line_rec.col105;
   END IF;

   -- col106
   IF p_is_line_rec.col106 = FND_API.g_miss_char THEN
      x_complete_rec.col106 := l_is_line_rec.col106;
   END IF;

   -- col107
   IF p_is_line_rec.col107 = FND_API.g_miss_char THEN
      x_complete_rec.col107 := l_is_line_rec.col107;
   END IF;

   -- col108
   IF p_is_line_rec.col108 = FND_API.g_miss_char THEN
      x_complete_rec.col108 := l_is_line_rec.col108;
   END IF;

   -- col109
   IF p_is_line_rec.col109 = FND_API.g_miss_char THEN
      x_complete_rec.col109 := l_is_line_rec.col109;
   END IF;

   -- col110
   IF p_is_line_rec.col110 = FND_API.g_miss_char THEN
      x_complete_rec.col110 := l_is_line_rec.col110;
   END IF;

   -- col111
   IF p_is_line_rec.col111 = FND_API.g_miss_char THEN
      x_complete_rec.col111 := l_is_line_rec.col111;
   END IF;

   -- col112
   IF p_is_line_rec.col112 = FND_API.g_miss_char THEN
      x_complete_rec.col112 := l_is_line_rec.col112;
   END IF;

   -- col113
   IF p_is_line_rec.col113 = FND_API.g_miss_char THEN
      x_complete_rec.col113 := l_is_line_rec.col113;
   END IF;

   -- col114
IF p_is_line_rec.col114 = FND_API.g_miss_char THEN
      x_complete_rec.col114 := l_is_line_rec.col114;
   END IF;

   -- col115
   IF p_is_line_rec.col115 = FND_API.g_miss_char THEN
      x_complete_rec.col115 := l_is_line_rec.col115;
   END IF;

   -- col116
   IF p_is_line_rec.col116 = FND_API.g_miss_char THEN
      x_complete_rec.col116 := l_is_line_rec.col116;
   END IF;

   -- col117
   IF p_is_line_rec.col117 = FND_API.g_miss_char THEN
      x_complete_rec.col117 := l_is_line_rec.col117;
   END IF;

   -- col118
   IF p_is_line_rec.col118 = FND_API.g_miss_char THEN
      x_complete_rec.col118 := l_is_line_rec.col118;
   END IF;

   -- col119
   IF p_is_line_rec.col119 = FND_API.g_miss_char THEN
      x_complete_rec.col119 := l_is_line_rec.col119;
   END IF;

   -- col120
   IF p_is_line_rec.col120 = FND_API.g_miss_char THEN
      x_complete_rec.col120 := l_is_line_rec.col120;
   END IF;

   -- col121
   IF p_is_line_rec.col121 = FND_API.g_miss_char THEN
      x_complete_rec.col121 := l_is_line_rec.col121;
   END IF;

   -- col122
   IF p_is_line_rec.col122 = FND_API.g_miss_char THEN
      x_complete_rec.col122 := l_is_line_rec.col122;
   END IF;

   -- col123
   IF p_is_line_rec.col123 = FND_API.g_miss_char THEN
      x_complete_rec.col123 := l_is_line_rec.col123;
   END IF;

   -- col124
   IF p_is_line_rec.col124 = FND_API.g_miss_char THEN
      x_complete_rec.col124 := l_is_line_rec.col124;
   END IF;

   -- col125
   IF p_is_line_rec.col125 = FND_API.g_miss_char THEN
      x_complete_rec.col125 := l_is_line_rec.col125;
   END IF;

   -- col126
   IF p_is_line_rec.col126 = FND_API.g_miss_char THEN
      x_complete_rec.col126 := l_is_line_rec.col126;
   END IF;

   -- col127
   IF p_is_line_rec.col127 = FND_API.g_miss_char THEN
      x_complete_rec.col127 := l_is_line_rec.col127;
   END IF;

   -- col128
   IF p_is_line_rec.col128 = FND_API.g_miss_char THEN
      x_complete_rec.col128 := l_is_line_rec.col128;
   END IF;

   -- col129
   IF p_is_line_rec.col129 = FND_API.g_miss_char THEN
      x_complete_rec.col129 := l_is_line_rec.col129;
   END IF;

   -- col130
   IF p_is_line_rec.col130 = FND_API.g_miss_char THEN
      x_complete_rec.col130 := l_is_line_rec.col130;
   END IF;

   -- col131
   IF p_is_line_rec.col131 = FND_API.g_miss_char THEN
      x_complete_rec.col131 := l_is_line_rec.col131;
   END IF;

   -- col132
   IF p_is_line_rec.col132 = FND_API.g_miss_char THEN
      x_complete_rec.col132 := l_is_line_rec.col132;
   END IF;

   -- col133
   IF p_is_line_rec.col133 = FND_API.g_miss_char THEN
      x_complete_rec.col133 := l_is_line_rec.col133;
   END IF;

   -- col134
   IF p_is_line_rec.col134 = FND_API.g_miss_char THEN
      x_complete_rec.col134 := l_is_line_rec.col134;
   END IF;

   -- col135
   IF p_is_line_rec.col135 = FND_API.g_miss_char THEN
      x_complete_rec.col135 := l_is_line_rec.col135;
   END IF;

   -- col136
   IF p_is_line_rec.col136 = FND_API.g_miss_char THEN
      x_complete_rec.col136 := l_is_line_rec.col136;
   END IF;

   -- col137
   IF p_is_line_rec.col137 = FND_API.g_miss_char THEN
      x_complete_rec.col137 := l_is_line_rec.col137;
   END IF;

   -- col138
   IF p_is_line_rec.col138 = FND_API.g_miss_char THEN
      x_complete_rec.col138 := l_is_line_rec.col138;
   END IF;

   -- col139
   IF p_is_line_rec.col139 = FND_API.g_miss_char THEN
      x_complete_rec.col139 := l_is_line_rec.col139;
   END IF;

   -- col140
   IF p_is_line_rec.col140 = FND_API.g_miss_char THEN
      x_complete_rec.col140 := l_is_line_rec.col140;
   END IF;

   -- col141
   IF p_is_line_rec.col141 = FND_API.g_miss_char THEN
      x_complete_rec.col141 := l_is_line_rec.col141;
   END IF;

   -- col142
   IF p_is_line_rec.col142 = FND_API.g_miss_char THEN
      x_complete_rec.col142 := l_is_line_rec.col142;
   END IF;

   -- col143
   IF p_is_line_rec.col143 = FND_API.g_miss_char THEN
      x_complete_rec.col143 := l_is_line_rec.col143;
   END IF;

   -- col144
   IF p_is_line_rec.col144 = FND_API.g_miss_char THEN
      x_complete_rec.col144 := l_is_line_rec.col144;
   END IF;

   -- col145
   IF p_is_line_rec.col145 = FND_API.g_miss_char THEN
      x_complete_rec.col145 := l_is_line_rec.col145;
   END IF;

   -- col146
   IF p_is_line_rec.col146 = FND_API.g_miss_char THEN
      x_complete_rec.col146 := l_is_line_rec.col146;
   END IF;

   -- col147
   IF p_is_line_rec.col147 = FND_API.g_miss_char THEN
      x_complete_rec.col147 := l_is_line_rec.col147;
   END IF;

   -- col148
   IF p_is_line_rec.col148 = FND_API.g_miss_char THEN
      x_complete_rec.col148 := l_is_line_rec.col148;
   END IF;

   -- col149
   IF p_is_line_rec.col149 = FND_API.g_miss_char THEN
      x_complete_rec.col149 := l_is_line_rec.col149;
   END IF;

   -- col150
   IF p_is_line_rec.col150 = FND_API.g_miss_char THEN
      x_complete_rec.col150 := l_is_line_rec.col150;
   END IF;

   -- col151
   IF p_is_line_rec.col151 = FND_API.g_miss_char THEN
      x_complete_rec.col151 := l_is_line_rec.col151;
   END IF;

   -- col152
   IF p_is_line_rec.col152 = FND_API.g_miss_char THEN
      x_complete_rec.col152 := l_is_line_rec.col152;
   END IF;

   -- col153
   IF p_is_line_rec.col153 = FND_API.g_miss_char THEN
      x_complete_rec.col153 := l_is_line_rec.col153;
   END IF;

   -- col154
   IF p_is_line_rec.col154 = FND_API.g_miss_char THEN
      x_complete_rec.col154 := l_is_line_rec.col154;
   END IF;

   -- col155
   IF p_is_line_rec.col155 = FND_API.g_miss_char THEN
      x_complete_rec.col155 := l_is_line_rec.col155;
   END IF;

   -- col156
   IF p_is_line_rec.col156 = FND_API.g_miss_char THEN
      x_complete_rec.col156 := l_is_line_rec.col156;
   END IF;

   -- col157
   IF p_is_line_rec.col157 = FND_API.g_miss_char THEN
      x_complete_rec.col157 := l_is_line_rec.col157;
   END IF;

   -- col158
   IF p_is_line_rec.col158 = FND_API.g_miss_char THEN
      x_complete_rec.col158 := l_is_line_rec.col158;
   END IF;

   -- col159
   IF p_is_line_rec.col159 = FND_API.g_miss_char THEN
      x_complete_rec.col159 := l_is_line_rec.col159;
   END IF;

   -- col160
   IF p_is_line_rec.col160 = FND_API.g_miss_char THEN
      x_complete_rec.col160 := l_is_line_rec.col160;
   END IF;

   -- col161
   IF p_is_line_rec.col161 = FND_API.g_miss_char THEN
      x_complete_rec.col161 := l_is_line_rec.col161;
   END IF;

   -- col162
   IF p_is_line_rec.col162 = FND_API.g_miss_char THEN
      x_complete_rec.col162 := l_is_line_rec.col162;
   END IF;

   -- col163
   IF p_is_line_rec.col163 = FND_API.g_miss_char THEN
      x_complete_rec.col163 := l_is_line_rec.col163;
   END IF;

   -- col164
   IF p_is_line_rec.col164 = FND_API.g_miss_char THEN
      x_complete_rec.col164 := l_is_line_rec.col164;
   END IF;

   -- col165
   IF p_is_line_rec.col165 = FND_API.g_miss_char THEN
      x_complete_rec.col165 := l_is_line_rec.col165;
   END IF;

   -- col166
   IF p_is_line_rec.col166 = FND_API.g_miss_char THEN
      x_complete_rec.col166 := l_is_line_rec.col166;
   END IF;

   -- col167
   IF p_is_line_rec.col167 = FND_API.g_miss_char THEN
      x_complete_rec.col167 := l_is_line_rec.col167;
   END IF;

   -- col168
   IF p_is_line_rec.col168 = FND_API.g_miss_char THEN
      x_complete_rec.col168 := l_is_line_rec.col168;
   END IF;

   -- col169
   IF p_is_line_rec.col169 = FND_API.g_miss_char THEN
      x_complete_rec.col169 := l_is_line_rec.col169;
   END IF;

   -- col170
   IF p_is_line_rec.col170 = FND_API.g_miss_char THEN
      x_complete_rec.col170 := l_is_line_rec.col170;
   END IF;

   -- col171
   IF p_is_line_rec.col171 = FND_API.g_miss_char THEN
      x_complete_rec.col171 := l_is_line_rec.col171;
   END IF;

   -- col172
   IF p_is_line_rec.col172 = FND_API.g_miss_char THEN
      x_complete_rec.col172 := l_is_line_rec.col172;
   END IF;

   -- col173
   IF p_is_line_rec.col173 = FND_API.g_miss_char THEN
      x_complete_rec.col173 := l_is_line_rec.col173;
   END IF;

   -- col174
   IF p_is_line_rec.col174 = FND_API.g_miss_char THEN
      x_complete_rec.col174 := l_is_line_rec.col174;
   END IF;

   -- col175
   IF p_is_line_rec.col175 = FND_API.g_miss_char THEN
      x_complete_rec.col175 := l_is_line_rec.col175;
   END IF;

   -- col176
   IF p_is_line_rec.col176 = FND_API.g_miss_char THEN
      x_complete_rec.col176 := l_is_line_rec.col176;
   END IF;

   -- col177
   IF p_is_line_rec.col177 = FND_API.g_miss_char THEN
      x_complete_rec.col177 := l_is_line_rec.col177;
   END IF;

   -- col178
   IF p_is_line_rec.col178 = FND_API.g_miss_char THEN
      x_complete_rec.col178 := l_is_line_rec.col178;
   END IF;

   -- col179
   IF p_is_line_rec.col179 = FND_API.g_miss_char THEN
      x_complete_rec.col179 := l_is_line_rec.col179;
   END IF;

   -- col180
   IF p_is_line_rec.col180 = FND_API.g_miss_char THEN
      x_complete_rec.col180 := l_is_line_rec.col180;
   END IF;

   -- col181
   IF p_is_line_rec.col181 = FND_API.g_miss_char THEN
      x_complete_rec.col181 := l_is_line_rec.col181;
   END IF;

   -- col182
   IF p_is_line_rec.col182 = FND_API.g_miss_char THEN
      x_complete_rec.col182 := l_is_line_rec.col182;
   END IF;

   -- col183
   IF p_is_line_rec.col183 = FND_API.g_miss_char THEN
      x_complete_rec.col183 := l_is_line_rec.col183;
   END IF;

   -- col184
   IF p_is_line_rec.col184 = FND_API.g_miss_char THEN
      x_complete_rec.col184 := l_is_line_rec.col184;
   END IF;

   -- col185
   IF p_is_line_rec.col185 = FND_API.g_miss_char THEN
      x_complete_rec.col185 := l_is_line_rec.col185;
   END IF;

   -- col186
   IF p_is_line_rec.col186 = FND_API.g_miss_char THEN
      x_complete_rec.col186 := l_is_line_rec.col186;
   END IF;

   -- col187
   IF p_is_line_rec.col187 = FND_API.g_miss_char THEN
      x_complete_rec.col187 := l_is_line_rec.col187;
   END IF;

   -- col188
   IF p_is_line_rec.col188 = FND_API.g_miss_char THEN
      x_complete_rec.col188 := l_is_line_rec.col188;
   END IF;

   -- col189
   IF p_is_line_rec.col189 = FND_API.g_miss_char THEN
      x_complete_rec.col189 := l_is_line_rec.col189;
   END IF;

   -- col190
   IF p_is_line_rec.col190 = FND_API.g_miss_char THEN
      x_complete_rec.col190 := l_is_line_rec.col190;
   END IF;

   -- col191
   IF p_is_line_rec.col191 = FND_API.g_miss_char THEN
      x_complete_rec.col191 := l_is_line_rec.col191;
   END IF;

   -- col192
   IF p_is_line_rec.col192 = FND_API.g_miss_char THEN
      x_complete_rec.col192 := l_is_line_rec.col192;
   END IF;

   -- col193
   IF p_is_line_rec.col193 = FND_API.g_miss_char THEN
      x_complete_rec.col193 := l_is_line_rec.col193;
   END IF;

   -- col194
   IF p_is_line_rec.col194 = FND_API.g_miss_char THEN
      x_complete_rec.col194 := l_is_line_rec.col194;
   END IF;

   -- col195
   IF p_is_line_rec.col195 = FND_API.g_miss_char THEN
      x_complete_rec.col195 := l_is_line_rec.col195;
   END IF;

   -- col196
   IF p_is_line_rec.col196 = FND_API.g_miss_char THEN
      x_complete_rec.col196 := l_is_line_rec.col196;
   END IF;

   -- col197
   IF p_is_line_rec.col197 = FND_API.g_miss_char THEN
      x_complete_rec.col197 := l_is_line_rec.col197;
   END IF;

   -- col198
   IF p_is_line_rec.col198 = FND_API.g_miss_char THEN
      x_complete_rec.col198 := l_is_line_rec.col198;
   END IF;

   -- col199
   IF p_is_line_rec.col199 = FND_API.g_miss_char THEN
      x_complete_rec.col199 := l_is_line_rec.col199;
   END IF;

   -- col200
   IF p_is_line_rec.col200 = FND_API.g_miss_char THEN
      x_complete_rec.col200 := l_is_line_rec.col200;
   END IF;

   -- col201
   IF p_is_line_rec.col201 = FND_API.g_miss_char THEN
      x_complete_rec.col201 := l_is_line_rec.col201;
   END IF;

   -- col202
   IF p_is_line_rec.col202 = FND_API.g_miss_char THEN
      x_complete_rec.col202 := l_is_line_rec.col202;
   END IF;

   -- col203
   IF p_is_line_rec.col203 = FND_API.g_miss_char THEN
      x_complete_rec.col203 := l_is_line_rec.col203;
   END IF;

   -- col204
   IF p_is_line_rec.col204 = FND_API.g_miss_char THEN
      x_complete_rec.col204 := l_is_line_rec.col204;
   END IF;

   -- col205
   IF p_is_line_rec.col205 = FND_API.g_miss_char THEN
      x_complete_rec.col205 := l_is_line_rec.col205;
   END IF;

   -- col206
   IF p_is_line_rec.col206 = FND_API.g_miss_char THEN
      x_complete_rec.col206 := l_is_line_rec.col206;
   END IF;

   -- col207
   IF p_is_line_rec.col207 = FND_API.g_miss_char THEN
      x_complete_rec.col207 := l_is_line_rec.col207;
   END IF;

   -- col208
   IF p_is_line_rec.col208 = FND_API.g_miss_char THEN
      x_complete_rec.col208 := l_is_line_rec.col208;
   END IF;

   -- col209
   IF p_is_line_rec.col209 = FND_API.g_miss_char THEN
      x_complete_rec.col209 := l_is_line_rec.col209;
   END IF;

   -- col210
   IF p_is_line_rec.col210 = FND_API.g_miss_char THEN
      x_complete_rec.col210 := l_is_line_rec.col210;
   END IF;

   -- col211
   IF p_is_line_rec.col211 = FND_API.g_miss_char THEN
      x_complete_rec.col211 := l_is_line_rec.col211;
   END IF;

   -- col212
   IF p_is_line_rec.col212 = FND_API.g_miss_char THEN
      x_complete_rec.col212 := l_is_line_rec.col212;
   END IF;

   -- col213
   IF p_is_line_rec.col213 = FND_API.g_miss_char THEN
      x_complete_rec.col213 := l_is_line_rec.col213;
   END IF;

   -- col214
   IF p_is_line_rec.col214 = FND_API.g_miss_char THEN
      x_complete_rec.col214 := l_is_line_rec.col214;
   END IF;

   -- col215
   IF p_is_line_rec.col215 = FND_API.g_miss_char THEN
      x_complete_rec.col215 := l_is_line_rec.col215;
   END IF;

   -- col216
   IF p_is_line_rec.col216 = FND_API.g_miss_char THEN
      x_complete_rec.col216 := l_is_line_rec.col216;
   END IF;

   -- col217
   IF p_is_line_rec.col217 = FND_API.g_miss_char THEN
      x_complete_rec.col217 := l_is_line_rec.col217;
   END IF;

   -- col218
   IF p_is_line_rec.col218 = FND_API.g_miss_char THEN
      x_complete_rec.col218 := l_is_line_rec.col218;
   END IF;

   -- col219
   IF p_is_line_rec.col219 = FND_API.g_miss_char THEN
      x_complete_rec.col219 := l_is_line_rec.col219;
   END IF;

   -- col220
   IF p_is_line_rec.col220 = FND_API.g_miss_char THEN
      x_complete_rec.col220 := l_is_line_rec.col220;
   END IF;

   -- col221
   IF p_is_line_rec.col221 = FND_API.g_miss_char THEN
      x_complete_rec.col221 := l_is_line_rec.col221;
   END IF;

   -- col222
   IF p_is_line_rec.col222 = FND_API.g_miss_char THEN
      x_complete_rec.col222 := l_is_line_rec.col222;
   END IF;

   -- col223
   IF p_is_line_rec.col223 = FND_API.g_miss_char THEN
      x_complete_rec.col223 := l_is_line_rec.col223;
   END IF;

   -- col224
   IF p_is_line_rec.col224 = FND_API.g_miss_char THEN
      x_complete_rec.col224 := l_is_line_rec.col224;
   END IF;

   -- col225
   IF p_is_line_rec.col225 = FND_API.g_miss_char THEN
      x_complete_rec.col225 := l_is_line_rec.col225;
   END IF;

   -- col226
   IF p_is_line_rec.col226 = FND_API.g_miss_char THEN
      x_complete_rec.col226 := l_is_line_rec.col226;
   END IF;

   -- col227
   IF p_is_line_rec.col227 = FND_API.g_miss_char THEN
      x_complete_rec.col227 := l_is_line_rec.col227;
   END IF;

   -- col228
   IF p_is_line_rec.col228 = FND_API.g_miss_char THEN
      x_complete_rec.col228 := l_is_line_rec.col228;
   END IF;

   -- col229
   IF p_is_line_rec.col229 = FND_API.g_miss_char THEN
      x_complete_rec.col229 := l_is_line_rec.col229;
   END IF;

   -- col230
   IF p_is_line_rec.col230 = FND_API.g_miss_char THEN
      x_complete_rec.col230 := l_is_line_rec.col230;
   END IF;

   -- col231
   IF p_is_line_rec.col231 = FND_API.g_miss_char THEN
      x_complete_rec.col231 := l_is_line_rec.col231;
   END IF;

   -- col232
   IF p_is_line_rec.col232 = FND_API.g_miss_char THEN
      x_complete_rec.col232 := l_is_line_rec.col232;
   END IF;

   -- col233
   IF p_is_line_rec.col233 = FND_API.g_miss_char THEN
      x_complete_rec.col233 := l_is_line_rec.col233;
   END IF;

   -- col234
   IF p_is_line_rec.col234 = FND_API.g_miss_char THEN
      x_complete_rec.col234 := l_is_line_rec.col234;
   END IF;

   -- col235
   IF p_is_line_rec.col235 = FND_API.g_miss_char THEN
      x_complete_rec.col235 := l_is_line_rec.col235;
   END IF;

   -- col236
   IF p_is_line_rec.col236 = FND_API.g_miss_char THEN
      x_complete_rec.col236 := l_is_line_rec.col236;
   END IF;

   -- col237
   IF p_is_line_rec.col237 = FND_API.g_miss_char THEN
      x_complete_rec.col237 := l_is_line_rec.col237;
   END IF;

   -- col238
   IF p_is_line_rec.col238 = FND_API.g_miss_char THEN
      x_complete_rec.col238 := l_is_line_rec.col238;
   END IF;

   -- col239
   IF p_is_line_rec.col239 = FND_API.g_miss_char THEN
      x_complete_rec.col239 := l_is_line_rec.col239;
   END IF;

   -- col240
   IF p_is_line_rec.col240 = FND_API.g_miss_char THEN
      x_complete_rec.col240 := l_is_line_rec.col240;
   END IF;

   -- col241
   IF p_is_line_rec.col241 = FND_API.g_miss_char THEN
      x_complete_rec.col241 := l_is_line_rec.col241;
   END IF;

   -- col242
   IF p_is_line_rec.col242 = FND_API.g_miss_char THEN
      x_complete_rec.col242 := l_is_line_rec.col242;
   END IF;

   -- col243
   IF p_is_line_rec.col243 = FND_API.g_miss_char THEN
      x_complete_rec.col243 := l_is_line_rec.col243;
   END IF;

   -- col244
   IF p_is_line_rec.col244 = FND_API.g_miss_char THEN
      x_complete_rec.col244 := l_is_line_rec.col244;
   END IF;

   -- col245
   IF p_is_line_rec.col245 = FND_API.g_miss_char THEN
      x_complete_rec.col245 := l_is_line_rec.col245;
   END IF;

   -- col246
   IF p_is_line_rec.col246 = FND_API.g_miss_char THEN
      x_complete_rec.col246 := l_is_line_rec.col246;
   END IF;

   -- col247
   IF p_is_line_rec.col247 = FND_API.g_miss_char THEN
      x_complete_rec.col247 := l_is_line_rec.col247;
   END IF;

   -- col248
   IF p_is_line_rec.col248 = FND_API.g_miss_char THEN
      x_complete_rec.col248 := l_is_line_rec.col248;
   END IF;

   -- col249
   IF p_is_line_rec.col249 = FND_API.g_miss_char THEN
      x_complete_rec.col249 := l_is_line_rec.col249;
   END IF;

   -- col250
   IF p_is_line_rec.col250 = FND_API.g_miss_char THEN
      x_complete_rec.col250 := l_is_line_rec.col250;
   END IF;


   -- duplicate_flag
   IF p_is_line_rec.duplicate_flag = FND_API.g_miss_char THEN
      x_complete_rec.duplicate_flag := l_is_line_rec.duplicate_flag;
   END IF;

   -- current_usage
   IF p_is_line_rec.current_usage = FND_API.g_miss_num THEN
      x_complete_rec.current_usage := l_is_line_rec.current_usage;
   END IF;

   -- notes
   IF p_is_line_rec.notes = FND_API.g_miss_char THEN
      x_complete_rec.notes := l_is_line_rec.notes;
   END IF;

   -- sales_agent_email_address
   IF p_is_line_rec.sales_agent_email_address = FND_API.g_miss_char THEN
      x_complete_rec.sales_agent_email_address := l_is_line_rec.sales_agent_email_address;
   END IF;

   -- vehicle_response_code
   IF p_is_line_rec.vehicle_response_code = FND_API.g_miss_char THEN
      x_complete_rec.vehicle_response_code := l_is_line_rec.vehicle_response_code;
   END IF;

 -- custom_column1
    IF p_is_line_rec.custom_column1 = FND_API.g_miss_char THEN
     x_complete_rec.custom_column1 := l_is_line_rec.custom_column1;
    END IF;
 -- custom_column2
    IF p_is_line_rec.custom_column2 = FND_API.g_miss_char THEN
     x_complete_rec.custom_column2 := l_is_line_rec.custom_column2;
    END IF;
 -- custom_column3
    IF p_is_line_rec.custom_column3 = FND_API.g_miss_char THEN
     x_complete_rec.custom_column3 := l_is_line_rec.custom_column3;
    END IF;
 -- custom_column4
    IF p_is_line_rec.custom_column4 = FND_API.g_miss_char THEN
     x_complete_rec.custom_column4 := l_is_line_rec.custom_column4;
    END IF;
 -- custom_column5
    IF p_is_line_rec.custom_column5 = FND_API.g_miss_char THEN
     x_complete_rec.custom_column5 := l_is_line_rec.custom_column5;
    END IF;
 -- custom_column6
    IF p_is_line_rec.custom_column6 = FND_API.g_miss_char THEN
     x_complete_rec.custom_column6 := l_is_line_rec.custom_column6;
    END IF;
 -- custom_column7
    IF p_is_line_rec.custom_column7 = FND_API.g_miss_char THEN
     x_complete_rec.custom_column7 := l_is_line_rec.custom_column7;
    END IF;
 -- custom_column8
    IF p_is_line_rec.custom_column8 = FND_API.g_miss_char THEN
     x_complete_rec.custom_column8 := l_is_line_rec.custom_column8;
    END IF;
 -- custom_column9
    IF p_is_line_rec.custom_column9 = FND_API.g_miss_char THEN
     x_complete_rec.custom_column9 := l_is_line_rec.custom_column9;
    END IF;
 -- custom_column10
    IF p_is_line_rec.custom_column10 = FND_API.g_miss_char THEN
     x_complete_rec.custom_column10 := l_is_line_rec.custom_column10;
    END IF;
 -- custom_column11
    IF p_is_line_rec.custom_column11 = FND_API.g_miss_char THEN
     x_complete_rec.custom_column11 := l_is_line_rec.custom_column11;
    END IF;
 -- custom_column12
    IF p_is_line_rec.custom_column12 = FND_API.g_miss_char THEN
     x_complete_rec.custom_column12 := l_is_line_rec.custom_column12;
    END IF;
 -- custom_column13
    IF p_is_line_rec.custom_column13 = FND_API.g_miss_char THEN
     x_complete_rec.custom_column13 := l_is_line_rec.custom_column13;
    END IF;
 -- custom_column14
    IF p_is_line_rec.custom_column14 = FND_API.g_miss_char THEN
     x_complete_rec.custom_column14 := l_is_line_rec.custom_column14;
    END IF;
 -- custom_column15
    IF p_is_line_rec.custom_column15 = FND_API.g_miss_char THEN
     x_complete_rec.custom_column15 := l_is_line_rec.custom_column15;
    END IF;
 -- custom_column16
    IF p_is_line_rec.custom_column16 = FND_API.g_miss_char THEN
     x_complete_rec.custom_column16 := l_is_line_rec.custom_column16;
    END IF;
 -- custom_column17
    IF p_is_line_rec.custom_column17 = FND_API.g_miss_char THEN
     x_complete_rec.custom_column17 := l_is_line_rec.custom_column17;
    END IF;
 -- custom_column18
    IF p_is_line_rec.custom_column18 = FND_API.g_miss_char THEN
     x_complete_rec.custom_column18 := l_is_line_rec.custom_column18;
    END IF;
 -- custom_column19
    IF p_is_line_rec.custom_column19 = FND_API.g_miss_char THEN
     x_complete_rec.custom_column19 := l_is_line_rec.custom_column19;
    END IF;
 -- custom_column20
    IF p_is_line_rec.custom_column20 = FND_API.g_miss_char THEN
     x_complete_rec.custom_column20 := l_is_line_rec.custom_column20;
    END IF;
 -- custom_column21
    IF p_is_line_rec.custom_column21 = FND_API.g_miss_char THEN
     x_complete_rec.custom_column21 := l_is_line_rec.custom_column21;
    END IF;
 -- custom_column22
    IF p_is_line_rec.custom_column22 = FND_API.g_miss_char THEN
     x_complete_rec.custom_column22 := l_is_line_rec.custom_column22;
    END IF;
 -- custom_column23
    IF p_is_line_rec.custom_column23 = FND_API.g_miss_char THEN
     x_complete_rec.custom_column23 := l_is_line_rec.custom_column23;
    END IF;
 -- custom_column24
    IF p_is_line_rec.custom_column24 = FND_API.g_miss_char THEN
     x_complete_rec.custom_column24 := l_is_line_rec.custom_column24;
    END IF;
 -- custom_column25
    IF p_is_line_rec.custom_column25 = FND_API.g_miss_char THEN
     x_complete_rec.custom_column25 := l_is_line_rec.custom_column25;
    END IF;


-- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_is_line_Rec;
PROCEDURE Validate_is_line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_is_line_rec               IN   is_line_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Is_Line';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_is_line_rec  AMS_Is_Line_PVT.is_line_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Is_Line_;

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
              Check_is_line_Items(
                 p_is_line_rec        => p_is_line_rec,
                 p_validation_mode   => JTF_PLSQL_API.g_update,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_is_line_Rec(
         p_is_line_rec        => p_is_line_rec,
         x_complete_rec        => l_is_line_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_is_line_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_is_line_rec           =>    l_is_line_rec);

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
     ROLLBACK TO VALIDATE_Is_Line_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Is_Line_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Is_Line_;
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
End Validate_Is_Line;


PROCEDURE Validate_is_line_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_is_line_rec               IN    is_line_rec_type
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
END Validate_is_line_Rec;

END AMS_Is_Line_PVT;

/
