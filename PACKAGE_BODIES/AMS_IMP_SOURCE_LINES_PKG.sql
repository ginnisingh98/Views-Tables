--------------------------------------------------------
--  DDL for Package Body AMS_IMP_SOURCE_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IMP_SOURCE_LINES_PKG" as
/* $Header: amstislb.pls 115.9 2004/01/22 01:13:53 sranka ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_IMP_SOURCE_LINES_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_IMP_SOURCE_LINES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstislb.pls';


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createInsertBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Insert_Row(
          px_import_source_line_id   IN OUT NOCOPY NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_import_list_header_id    NUMBER,
          p_import_successful_flag    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_import_failure_reason    VARCHAR2,
          p_re_import_last_done_date    DATE,
          p_party_id    NUMBER,
          p_dedupe_key    VARCHAR2,
          p_col1    VARCHAR2,
          p_col2    VARCHAR2,
          p_col3    VARCHAR2,
          p_col4    VARCHAR2,
          p_col5    VARCHAR2,
          p_col6    VARCHAR2,
          p_col7    VARCHAR2,
          p_col8    VARCHAR2,
          p_col9    VARCHAR2,
          p_col10    VARCHAR2,
          p_col11    VARCHAR2,
          p_col12    VARCHAR2,
          p_col13    VARCHAR2,
          p_col14    VARCHAR2,
          p_col15    VARCHAR2,
          p_col16    VARCHAR2,
          p_col17    VARCHAR2,
          p_col18    VARCHAR2,
          p_col19    VARCHAR2,
          p_col20    VARCHAR2,
          p_col21    VARCHAR2,
          p_col22    VARCHAR2,
          p_col23    VARCHAR2,
          p_col24    VARCHAR2,
          p_col25    VARCHAR2,
          p_col26    VARCHAR2,
          p_col27    VARCHAR2,
          p_col28    VARCHAR2,
          p_col29    VARCHAR2,
          p_col30    VARCHAR2,
          p_col31    VARCHAR2,
          p_col32    VARCHAR2,
          p_col33    VARCHAR2,
          p_col34    VARCHAR2,
          p_col35    VARCHAR2,
          p_col36    VARCHAR2,
          p_col37    VARCHAR2,
          p_col38    VARCHAR2,
          p_col39    VARCHAR2,
          p_col40    VARCHAR2,
          p_col41    VARCHAR2,
          p_col42    VARCHAR2,
          p_col43    VARCHAR2,
          p_col44    VARCHAR2,
          p_col45    VARCHAR2,
          p_col46    VARCHAR2,
          p_col47    VARCHAR2,
          p_col48    VARCHAR2,
          p_col49    VARCHAR2,
          p_col50    VARCHAR2,
          p_col51    VARCHAR2,
          p_col52    VARCHAR2,
          p_col53    VARCHAR2,
          p_col54    VARCHAR2,
          p_col55    VARCHAR2,
          p_col56    VARCHAR2,
          p_col57    VARCHAR2,
          p_col58    VARCHAR2,
          p_col59    VARCHAR2,
          p_col60    VARCHAR2,
          p_col61    VARCHAR2,
          p_col62    VARCHAR2,
          p_col63    VARCHAR2,
          p_col64    VARCHAR2,
          p_col65    VARCHAR2,
          p_col66    VARCHAR2,
          p_col67    VARCHAR2,
          p_col68    VARCHAR2,
          p_col69    VARCHAR2,
          p_col70    VARCHAR2,
          p_col71    VARCHAR2,
          p_col72    VARCHAR2,
          p_col73    VARCHAR2,
          p_col74    VARCHAR2,
          p_col75    VARCHAR2,
          p_col76    VARCHAR2,
          p_col77    VARCHAR2,
          p_col78    VARCHAR2,
          p_col79    VARCHAR2,
          p_col80    VARCHAR2,
          p_col81    VARCHAR2,
          p_col82    VARCHAR2,
          p_col83    VARCHAR2,
          p_col84    VARCHAR2,
          p_col85    VARCHAR2,
          p_col86    VARCHAR2,
          p_col87    VARCHAR2,
          p_col88    VARCHAR2,
          p_col89    VARCHAR2,
          p_col90    VARCHAR2,
          p_col91    VARCHAR2,
          p_col92    VARCHAR2,
          p_col93    VARCHAR2,
          p_col94    VARCHAR2,
          p_col95    VARCHAR2,
          p_col96    VARCHAR2,
          p_col97    VARCHAR2,
          p_col98    VARCHAR2,
          p_col99    VARCHAR2,
          p_col100    VARCHAR2,
          p_col101    VARCHAR2,
          p_col102    VARCHAR2,
          p_col103    VARCHAR2,
          p_col104    VARCHAR2,
          p_col105    VARCHAR2,
          p_col106    VARCHAR2,
          p_col107    VARCHAR2,
          p_col108    VARCHAR2,
          p_col109    VARCHAR2,
          p_col110    VARCHAR2,
          p_col111    VARCHAR2,
          p_col112    VARCHAR2,
          p_col113    VARCHAR2,
          p_col114    VARCHAR2,
          p_col115    VARCHAR2,
          p_col116    VARCHAR2,
          p_col117    VARCHAR2,
          p_col118    VARCHAR2,
          p_col119    VARCHAR2,
          p_col120    VARCHAR2,
          p_col121    VARCHAR2,
          p_col122    VARCHAR2,
          p_col123    VARCHAR2,
          p_col124    VARCHAR2,
          p_col125    VARCHAR2,
          p_col126    VARCHAR2,
          p_col127    VARCHAR2,
          p_col128    VARCHAR2,
          p_col129    VARCHAR2,
          p_col130    VARCHAR2,
          p_col131    VARCHAR2,
          p_col132    VARCHAR2,
          p_col133    VARCHAR2,
          p_col134    VARCHAR2,
          p_col135    VARCHAR2,
          p_col136    VARCHAR2,
          p_col137    VARCHAR2,
          p_col138    VARCHAR2,
          p_col139    VARCHAR2,
          p_col140    VARCHAR2,
          p_col141    VARCHAR2,
          p_col142    VARCHAR2,
          p_col143    VARCHAR2,
          p_col144    VARCHAR2,
          p_col145    VARCHAR2,
          p_col146    VARCHAR2,
          p_col147    VARCHAR2,
          p_col148    VARCHAR2,
          p_col149    VARCHAR2,
          p_col150    VARCHAR2,
          p_col151    VARCHAR2,
          p_col152    VARCHAR2,
          p_col153    VARCHAR2,
          p_col154    VARCHAR2,
          p_col155    VARCHAR2,
          p_col156    VARCHAR2,
          p_col157    VARCHAR2,
          p_col158    VARCHAR2,
          p_col159    VARCHAR2,
          p_col160    VARCHAR2,
          p_col161    VARCHAR2,
          p_col162    VARCHAR2,
          p_col163    VARCHAR2,
          p_col164    VARCHAR2,
          p_col165    VARCHAR2,
          p_col166    VARCHAR2,
          p_col167    VARCHAR2,
          p_col168    VARCHAR2,
          p_col169    VARCHAR2,
          p_col170    VARCHAR2,
          p_col171    VARCHAR2,
          p_col172    VARCHAR2,
          p_col173    VARCHAR2,
          p_col174    VARCHAR2,
          p_col175    VARCHAR2,
          p_col176    VARCHAR2,
          p_col177    VARCHAR2,
          p_col178    VARCHAR2,
          p_col179    VARCHAR2,
          p_col180    VARCHAR2,
          p_col181    VARCHAR2,
          p_col182    VARCHAR2,
          p_col183    VARCHAR2,
          p_col184    VARCHAR2,
          p_col185    VARCHAR2,
          p_col186    VARCHAR2,
          p_col187    VARCHAR2,
          p_col188    VARCHAR2,
          p_col189    VARCHAR2,
          p_col190    VARCHAR2,
          p_col191    VARCHAR2,
          p_col192    VARCHAR2,
          p_col193    VARCHAR2,
          p_col194    VARCHAR2,
          p_col195    VARCHAR2,
          p_col196    VARCHAR2,
          p_col197    VARCHAR2,
          p_col198    VARCHAR2,
          p_col199    VARCHAR2,
          p_col200    VARCHAR2,
          p_col201    VARCHAR2,
          p_col202    VARCHAR2,
          p_col203    VARCHAR2,
          p_col204    VARCHAR2,
          p_col205    VARCHAR2,
          p_col206    VARCHAR2,
          p_col207    VARCHAR2,
          p_col208    VARCHAR2,
          p_col209    VARCHAR2,
          p_col210    VARCHAR2,
          p_col211    VARCHAR2,
          p_col212    VARCHAR2,
          p_col213    VARCHAR2,
          p_col214    VARCHAR2,
          p_col215    VARCHAR2,
          p_col216    VARCHAR2,
          p_col217    VARCHAR2,
          p_col218    VARCHAR2,
          p_col219    VARCHAR2,
          p_col220    VARCHAR2,
          p_col221    VARCHAR2,
          p_col222    VARCHAR2,
          p_col223    VARCHAR2,
          p_col224    VARCHAR2,
          p_col225    VARCHAR2,
          p_col226    VARCHAR2,
          p_col227    VARCHAR2,
          p_col228    VARCHAR2,
          p_col229    VARCHAR2,
          p_col230    VARCHAR2,
          p_col231    VARCHAR2,
          p_col232    VARCHAR2,
          p_col233    VARCHAR2,
          p_col234    VARCHAR2,
          p_col235    VARCHAR2,
          p_col236    VARCHAR2,
          p_col237    VARCHAR2,
          p_col238    VARCHAR2,
          p_col239    VARCHAR2,
          p_col240    VARCHAR2,
          p_col241    VARCHAR2,
          p_col242    VARCHAR2,
          p_col243    VARCHAR2,
          p_col244    VARCHAR2,
          p_col245    VARCHAR2,
          p_col246    VARCHAR2,
          p_col247    VARCHAR2,
          p_col248    VARCHAR2,
          p_col249    VARCHAR2,
          p_col250    VARCHAR2,
          p_duplicate_flag    VARCHAR2,
          p_current_usage    NUMBER,
          p_notes     VARCHAR2,
	  p_sales_agent_email_address VARCHAR2,
	  p_vehicle_response_code VARCHAR2,
p_custom_column1 VARCHAR2,
p_custom_column2 VARCHAR2,
p_custom_column3 VARCHAR2,
p_custom_column4 VARCHAR2,
p_custom_column5 VARCHAR2,
p_custom_column6 VARCHAR2,
p_custom_column7 VARCHAR2,
p_custom_column8 VARCHAR2,
p_custom_column9 VARCHAR2,
p_custom_column10 VARCHAR2,
p_custom_column11 VARCHAR2,
p_custom_column12 VARCHAR2,
p_custom_column13 VARCHAR2,
p_custom_column14 VARCHAR2,
p_custom_column15 VARCHAR2,
p_custom_column16 VARCHAR2,
p_custom_column17 VARCHAR2,
p_custom_column18 VARCHAR2,
p_custom_column19 VARCHAR2,
p_custom_column20 VARCHAR2,
p_custom_column21 VARCHAR2,
p_custom_column22 VARCHAR2,
p_custom_column23 VARCHAR2,
p_custom_column24 VARCHAR2,
p_custom_column25 VARCHAR2

      )

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO AMS_IMP_SOURCE_LINES(
           import_source_line_id,
           object_version_number,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           import_list_header_id,
           import_successful_flag,
           enabled_flag,
           import_failure_reason,
           re_import_last_done_date,
           party_id,
           dedupe_key,
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
           col250,
           duplicate_flag,
           current_usage,
	   load_status,
	   notes  ,
	   sales_agent_email_address,
	   vehicle_response_code,
       custom_column1,
custom_column2,
custom_column3,
custom_column4,
custom_column5,
custom_column6,
custom_column7,
custom_column8,
custom_column9,
custom_column10,
custom_column11,
custom_column12,
custom_column13,
custom_column14,
custom_column15,
custom_column16,
custom_column17,
custom_column18,
custom_column19,
custom_column20,
custom_column21,
custom_column22,
custom_column23,
custom_column24,
custom_column25


   ) VALUES (
           DECODE( px_import_source_line_id, FND_API.g_miss_num, NULL, px_import_source_line_id),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( p_import_list_header_id, FND_API.g_miss_num, NULL, p_import_list_header_id),
           DECODE( p_import_successful_flag, FND_API.g_miss_char, NULL, p_import_successful_flag),
           DECODE( p_enabled_flag, FND_API.g_miss_char, NULL, p_enabled_flag),
           DECODE( p_import_failure_reason, FND_API.g_miss_char, NULL, p_import_failure_reason),
           DECODE( p_re_import_last_done_date, FND_API.g_miss_date, NULL, p_re_import_last_done_date),
           DECODE( p_party_id, FND_API.g_miss_num, NULL, p_party_id),
           DECODE( p_dedupe_key, FND_API.g_miss_char, NULL, p_dedupe_key),
           DECODE( p_col1, FND_API.g_miss_char, NULL, p_col1),
           DECODE( p_col2, FND_API.g_miss_char, NULL, p_col2),
           DECODE( p_col3, FND_API.g_miss_char, NULL, p_col3),
           DECODE( p_col4, FND_API.g_miss_char, NULL, p_col4),
           DECODE( p_col5, FND_API.g_miss_char, NULL, p_col5),
           DECODE( p_col6, FND_API.g_miss_char, NULL, p_col6),
           DECODE( p_col7, FND_API.g_miss_char, NULL, p_col7),
           DECODE( p_col8, FND_API.g_miss_char, NULL, p_col8),
           DECODE( p_col9, FND_API.g_miss_char, NULL, p_col9),
           DECODE( p_col10, FND_API.g_miss_char, NULL, p_col10),
           DECODE( p_col11, FND_API.g_miss_char, NULL, p_col11),
           DECODE( p_col12, FND_API.g_miss_char, NULL, p_col12),
           DECODE( p_col13, FND_API.g_miss_char, NULL, p_col13),
           DECODE( p_col14, FND_API.g_miss_char, NULL, p_col14),
           DECODE( p_col15, FND_API.g_miss_char, NULL, p_col15),
           DECODE( p_col16, FND_API.g_miss_char, NULL, p_col16),
           DECODE( p_col17, FND_API.g_miss_char, NULL, p_col17),
           DECODE( p_col18, FND_API.g_miss_char, NULL, p_col18),
           DECODE( p_col19, FND_API.g_miss_char, NULL, p_col19),
           DECODE( p_col20, FND_API.g_miss_char, NULL, p_col20),
           DECODE( p_col21, FND_API.g_miss_char, NULL, p_col21),
           DECODE( p_col22, FND_API.g_miss_char, NULL, p_col22),
           DECODE( p_col23, FND_API.g_miss_char, NULL, p_col23),
           DECODE( p_col24, FND_API.g_miss_char, NULL, p_col24),
           DECODE( p_col25, FND_API.g_miss_char, NULL, p_col25),
           DECODE( p_col26, FND_API.g_miss_char, NULL, p_col26),
           DECODE( p_col27, FND_API.g_miss_char, NULL, p_col27),
           DECODE( p_col28, FND_API.g_miss_char, NULL, p_col28),
           DECODE( p_col29, FND_API.g_miss_char, NULL, p_col29),
           DECODE( p_col30, FND_API.g_miss_char, NULL, p_col30),
           DECODE( p_col31, FND_API.g_miss_char, NULL, p_col31),
           DECODE( p_col32, FND_API.g_miss_char, NULL, p_col32),
           DECODE( p_col33, FND_API.g_miss_char, NULL, p_col33),
           DECODE( p_col34, FND_API.g_miss_char, NULL, p_col34),
           DECODE( p_col35, FND_API.g_miss_char, NULL, p_col35),
           DECODE( p_col36, FND_API.g_miss_char, NULL, p_col36),
           DECODE( p_col37, FND_API.g_miss_char, NULL, p_col37),
           DECODE( p_col38, FND_API.g_miss_char, NULL, p_col38),
           DECODE( p_col39, FND_API.g_miss_char, NULL, p_col39),
           DECODE( p_col40, FND_API.g_miss_char, NULL, p_col40),
           DECODE( p_col41, FND_API.g_miss_char, NULL, p_col41),
           DECODE( p_col42, FND_API.g_miss_char, NULL, p_col42),
           DECODE( p_col43, FND_API.g_miss_char, NULL, p_col43),
           DECODE( p_col44, FND_API.g_miss_char, NULL, p_col44),
           DECODE( p_col45, FND_API.g_miss_char, NULL, p_col45),
           DECODE( p_col46, FND_API.g_miss_char, NULL, p_col46),
           DECODE( p_col47, FND_API.g_miss_char, NULL, p_col47),
           DECODE( p_col48, FND_API.g_miss_char, NULL, p_col48),
           DECODE( p_col49, FND_API.g_miss_char, NULL, p_col49),
           DECODE( p_col50, FND_API.g_miss_char, NULL, p_col50),
           DECODE( p_col51, FND_API.g_miss_char, NULL, p_col51),
           DECODE( p_col52, FND_API.g_miss_char, NULL, p_col52),
           DECODE( p_col53, FND_API.g_miss_char, NULL, p_col53),
           DECODE( p_col54, FND_API.g_miss_char, NULL, p_col54),
           DECODE( p_col55, FND_API.g_miss_char, NULL, p_col55),
           DECODE( p_col56, FND_API.g_miss_char, NULL, p_col56),
           DECODE( p_col57, FND_API.g_miss_char, NULL, p_col57),
           DECODE( p_col58, FND_API.g_miss_char, NULL, p_col58),
           DECODE( p_col59, FND_API.g_miss_char, NULL, p_col59),
           DECODE( p_col60, FND_API.g_miss_char, NULL, p_col60),
           DECODE( p_col61, FND_API.g_miss_char, NULL, p_col61),
           DECODE( p_col62, FND_API.g_miss_char, NULL, p_col62),
           DECODE( p_col63, FND_API.g_miss_char, NULL, p_col63),
           DECODE( p_col64, FND_API.g_miss_char, NULL, p_col64),
           DECODE( p_col65, FND_API.g_miss_char, NULL, p_col65),
           DECODE( p_col66, FND_API.g_miss_char, NULL, p_col66),
           DECODE( p_col67, FND_API.g_miss_char, NULL, p_col67),
           DECODE( p_col68, FND_API.g_miss_char, NULL, p_col68),
           DECODE( p_col69, FND_API.g_miss_char, NULL, p_col69),
           DECODE( p_col70, FND_API.g_miss_char, NULL, p_col70),
           DECODE( p_col71, FND_API.g_miss_char, NULL, p_col71),
           DECODE( p_col72, FND_API.g_miss_char, NULL, p_col72),
           DECODE( p_col73, FND_API.g_miss_char, NULL, p_col73),
           DECODE( p_col74, FND_API.g_miss_char, NULL, p_col74),
           DECODE( p_col75, FND_API.g_miss_char, NULL, p_col75),
           DECODE( p_col76, FND_API.g_miss_char, NULL, p_col76),
           DECODE( p_col77, FND_API.g_miss_char, NULL, p_col77),
           DECODE( p_col78, FND_API.g_miss_char, NULL, p_col78),
           DECODE( p_col79, FND_API.g_miss_char, NULL, p_col79),
           DECODE( p_col80, FND_API.g_miss_char, NULL, p_col80),
           DECODE( p_col81, FND_API.g_miss_char, NULL, p_col81),
           DECODE( p_col82, FND_API.g_miss_char, NULL, p_col82),
           DECODE( p_col83, FND_API.g_miss_char, NULL, p_col83),
           DECODE( p_col84, FND_API.g_miss_char, NULL, p_col84),
           DECODE( p_col85, FND_API.g_miss_char, NULL, p_col85),
           DECODE( p_col86, FND_API.g_miss_char, NULL, p_col86),
           DECODE( p_col87, FND_API.g_miss_char, NULL, p_col87),
           DECODE( p_col88, FND_API.g_miss_char, NULL, p_col88),
           DECODE( p_col89, FND_API.g_miss_char, NULL, p_col89),
           DECODE( p_col90, FND_API.g_miss_char, NULL, p_col90),
           DECODE( p_col91, FND_API.g_miss_char, NULL, p_col91),
           DECODE( p_col92, FND_API.g_miss_char, NULL, p_col92),
           DECODE( p_col93, FND_API.g_miss_char, NULL, p_col93),
           DECODE( p_col94, FND_API.g_miss_char, NULL, p_col94),
           DECODE( p_col95, FND_API.g_miss_char, NULL, p_col95),
           DECODE( p_col96, FND_API.g_miss_char, NULL, p_col96),
           DECODE( p_col97, FND_API.g_miss_char, NULL, p_col97),
           DECODE( p_col98, FND_API.g_miss_char, NULL, p_col98),
           DECODE( p_col99, FND_API.g_miss_char, NULL, p_col99),
           DECODE( p_col100, FND_API.g_miss_char, NULL, p_col100),
           DECODE( p_col101, FND_API.g_miss_char, NULL, p_col101),
           DECODE( p_col102, FND_API.g_miss_char, NULL, p_col102),
           DECODE( p_col103, FND_API.g_miss_char, NULL, p_col103),
           DECODE( p_col104, FND_API.g_miss_char, NULL, p_col104),
           DECODE( p_col105, FND_API.g_miss_char, NULL, p_col105),
           DECODE( p_col106, FND_API.g_miss_char, NULL, p_col106),
           DECODE( p_col107, FND_API.g_miss_char, NULL, p_col107),
           DECODE( p_col108, FND_API.g_miss_char, NULL, p_col108),
           DECODE( p_col109, FND_API.g_miss_char, NULL, p_col109),
           DECODE( p_col110, FND_API.g_miss_char, NULL, p_col110),
           DECODE( p_col111, FND_API.g_miss_char, NULL, p_col111),
           DECODE( p_col112, FND_API.g_miss_char, NULL, p_col112),
           DECODE( p_col113, FND_API.g_miss_char, NULL, p_col113),
           DECODE( p_col114, FND_API.g_miss_char, NULL, p_col114),
           DECODE( p_col115, FND_API.g_miss_char, NULL, p_col115),
           DECODE( p_col116, FND_API.g_miss_char, NULL, p_col116),
           DECODE( p_col117, FND_API.g_miss_char, NULL, p_col117),
           DECODE( p_col118, FND_API.g_miss_char, NULL, p_col118),
           DECODE( p_col119, FND_API.g_miss_char, NULL, p_col119),
           DECODE( p_col120, FND_API.g_miss_char, NULL, p_col120),
           DECODE( p_col121, FND_API.g_miss_char, NULL, p_col121),
           DECODE( p_col122, FND_API.g_miss_char, NULL, p_col122),
           DECODE( p_col123, FND_API.g_miss_char, NULL, p_col123),
           DECODE( p_col124, FND_API.g_miss_char, NULL, p_col124),
           DECODE( p_col125, FND_API.g_miss_char, NULL, p_col125),
           DECODE( p_col126, FND_API.g_miss_char, NULL, p_col126),
           DECODE( p_col127, FND_API.g_miss_char, NULL, p_col127),
           DECODE( p_col128, FND_API.g_miss_char, NULL, p_col128),
           DECODE( p_col129, FND_API.g_miss_char, NULL, p_col129),
           DECODE( p_col130, FND_API.g_miss_char, NULL, p_col130),
           DECODE( p_col131, FND_API.g_miss_char, NULL, p_col131),
           DECODE( p_col132, FND_API.g_miss_char, NULL, p_col132),
           DECODE( p_col133, FND_API.g_miss_char, NULL, p_col133),
           DECODE( p_col134, FND_API.g_miss_char, NULL, p_col134),
           DECODE( p_col135, FND_API.g_miss_char, NULL, p_col135),
           DECODE( p_col136, FND_API.g_miss_char, NULL, p_col136),
           DECODE( p_col137, FND_API.g_miss_char, NULL, p_col137),
           DECODE( p_col138, FND_API.g_miss_char, NULL, p_col138),
           DECODE( p_col139, FND_API.g_miss_char, NULL, p_col139),
           DECODE( p_col140, FND_API.g_miss_char, NULL, p_col140),
           DECODE( p_col141, FND_API.g_miss_char, NULL, p_col141),
           DECODE( p_col142, FND_API.g_miss_char, NULL, p_col142),
           DECODE( p_col143, FND_API.g_miss_char, NULL, p_col143),
           DECODE( p_col144, FND_API.g_miss_char, NULL, p_col144),
           DECODE( p_col145, FND_API.g_miss_char, NULL, p_col145),
           DECODE( p_col146, FND_API.g_miss_char, NULL, p_col146),
           DECODE( p_col147, FND_API.g_miss_char, NULL, p_col147),
           DECODE( p_col148, FND_API.g_miss_char, NULL, p_col148),
           DECODE( p_col149, FND_API.g_miss_char, NULL, p_col149),
           DECODE( p_col150, FND_API.g_miss_char, NULL, p_col150),
           DECODE( p_col151, FND_API.g_miss_char, NULL, p_col151),
           DECODE( p_col152, FND_API.g_miss_char, NULL, p_col152),
           DECODE( p_col153, FND_API.g_miss_char, NULL, p_col153),
           DECODE( p_col154, FND_API.g_miss_char, NULL, p_col154),
           DECODE( p_col155, FND_API.g_miss_char, NULL, p_col155),
           DECODE( p_col156, FND_API.g_miss_char, NULL, p_col156),
           DECODE( p_col157, FND_API.g_miss_char, NULL, p_col157),
           DECODE( p_col158, FND_API.g_miss_char, NULL, p_col158),
           DECODE( p_col159, FND_API.g_miss_char, NULL, p_col159),
           DECODE( p_col160, FND_API.g_miss_char, NULL, p_col160),
           DECODE( p_col161, FND_API.g_miss_char, NULL, p_col161),
           DECODE( p_col162, FND_API.g_miss_char, NULL, p_col162),
           DECODE( p_col163, FND_API.g_miss_char, NULL, p_col163),
           DECODE( p_col164, FND_API.g_miss_char, NULL, p_col164),
           DECODE( p_col165, FND_API.g_miss_char, NULL, p_col165),
           DECODE( p_col166, FND_API.g_miss_char, NULL, p_col166),
           DECODE( p_col167, FND_API.g_miss_char, NULL, p_col167),
           DECODE( p_col168, FND_API.g_miss_char, NULL, p_col168),
           DECODE( p_col169, FND_API.g_miss_char, NULL, p_col169),
           DECODE( p_col170, FND_API.g_miss_char, NULL, p_col170),
           DECODE( p_col171, FND_API.g_miss_char, NULL, p_col171),
           DECODE( p_col172, FND_API.g_miss_char, NULL, p_col172),
           DECODE( p_col173, FND_API.g_miss_char, NULL, p_col173),
           DECODE( p_col174, FND_API.g_miss_char, NULL, p_col174),
           DECODE( p_col175, FND_API.g_miss_char, NULL, p_col175),
           DECODE( p_col176, FND_API.g_miss_char, NULL, p_col176),
           DECODE( p_col177, FND_API.g_miss_char, NULL, p_col177),
           DECODE( p_col178, FND_API.g_miss_char, NULL, p_col178),
           DECODE( p_col179, FND_API.g_miss_char, NULL, p_col179),
           DECODE( p_col180, FND_API.g_miss_char, NULL, p_col180),
           DECODE( p_col181, FND_API.g_miss_char, NULL, p_col181),
           DECODE( p_col182, FND_API.g_miss_char, NULL, p_col182),
           DECODE( p_col183, FND_API.g_miss_char, NULL, p_col183),
           DECODE( p_col184, FND_API.g_miss_char, NULL, p_col184),
           DECODE( p_col185, FND_API.g_miss_char, NULL, p_col185),
           DECODE( p_col186, FND_API.g_miss_char, NULL, p_col186),
           DECODE( p_col187, FND_API.g_miss_char, NULL, p_col187),
           DECODE( p_col188, FND_API.g_miss_char, NULL, p_col188),
           DECODE( p_col189, FND_API.g_miss_char, NULL, p_col189),
           DECODE( p_col190, FND_API.g_miss_char, NULL, p_col190),
           DECODE( p_col191, FND_API.g_miss_char, NULL, p_col191),
           DECODE( p_col192, FND_API.g_miss_char, NULL, p_col192),
           DECODE( p_col193, FND_API.g_miss_char, NULL, p_col193),
           DECODE( p_col194, FND_API.g_miss_char, NULL, p_col194),
           DECODE( p_col195, FND_API.g_miss_char, NULL, p_col195),
           DECODE( p_col196, FND_API.g_miss_char, NULL, p_col196),
           DECODE( p_col197, FND_API.g_miss_char, NULL, p_col197),
           DECODE( p_col198, FND_API.g_miss_char, NULL, p_col198),
           DECODE( p_col199, FND_API.g_miss_char, NULL, p_col199),
           DECODE( p_col200, FND_API.g_miss_char, NULL, p_col200),
           DECODE( p_col201, FND_API.g_miss_char, NULL, p_col201),
           DECODE( p_col202, FND_API.g_miss_char, NULL, p_col202),
           DECODE( p_col203, FND_API.g_miss_char, NULL, p_col203),
           DECODE( p_col204, FND_API.g_miss_char, NULL, p_col204),
           DECODE( p_col205, FND_API.g_miss_char, NULL, p_col205),
           DECODE( p_col206, FND_API.g_miss_char, NULL, p_col206),
           DECODE( p_col207, FND_API.g_miss_char, NULL, p_col207),
           DECODE( p_col208, FND_API.g_miss_char, NULL, p_col208),
           DECODE( p_col209, FND_API.g_miss_char, NULL, p_col209),
           DECODE( p_col210, FND_API.g_miss_char, NULL, p_col210),
           DECODE( p_col211, FND_API.g_miss_char, NULL, p_col211),
           DECODE( p_col212, FND_API.g_miss_char, NULL, p_col212),
           DECODE( p_col213, FND_API.g_miss_char, NULL, p_col213),
           DECODE( p_col214, FND_API.g_miss_char, NULL, p_col214),
           DECODE( p_col215, FND_API.g_miss_char, NULL, p_col215),
           DECODE( p_col216, FND_API.g_miss_char, NULL, p_col216),
           DECODE( p_col217, FND_API.g_miss_char, NULL, p_col217),
           DECODE( p_col218, FND_API.g_miss_char, NULL, p_col218),
           DECODE( p_col219, FND_API.g_miss_char, NULL, p_col219),
           DECODE( p_col220, FND_API.g_miss_char, NULL, p_col220),
           DECODE( p_col221, FND_API.g_miss_char, NULL, p_col221),
           DECODE( p_col222, FND_API.g_miss_char, NULL, p_col222),
           DECODE( p_col223, FND_API.g_miss_char, NULL, p_col223),
           DECODE( p_col224, FND_API.g_miss_char, NULL, p_col224),
           DECODE( p_col225, FND_API.g_miss_char, NULL, p_col225),
           DECODE( p_col226, FND_API.g_miss_char, NULL, p_col226),
           DECODE( p_col227, FND_API.g_miss_char, NULL, p_col227),
           DECODE( p_col228, FND_API.g_miss_char, NULL, p_col228),
           DECODE( p_col229, FND_API.g_miss_char, NULL, p_col229),
           DECODE( p_col230, FND_API.g_miss_char, NULL, p_col230),
           DECODE( p_col231, FND_API.g_miss_char, NULL, p_col231),
           DECODE( p_col232, FND_API.g_miss_char, NULL, p_col232),
           DECODE( p_col233, FND_API.g_miss_char, NULL, p_col233),
           DECODE( p_col234, FND_API.g_miss_char, NULL, p_col234),
           DECODE( p_col235, FND_API.g_miss_char, NULL, p_col235),
           DECODE( p_col236, FND_API.g_miss_char, NULL, p_col236),
           DECODE( p_col237, FND_API.g_miss_char, NULL, p_col237),
           DECODE( p_col238, FND_API.g_miss_char, NULL, p_col238),
           DECODE( p_col239, FND_API.g_miss_char, NULL, p_col239),
           DECODE( p_col240, FND_API.g_miss_char, NULL, p_col240),
           DECODE( p_col241, FND_API.g_miss_char, NULL, p_col241),
           DECODE( p_col242, FND_API.g_miss_char, NULL, p_col242),
           DECODE( p_col243, FND_API.g_miss_char, NULL, p_col243),
           DECODE( p_col244, FND_API.g_miss_char, NULL, p_col244),
           DECODE( p_col245, FND_API.g_miss_char, NULL, p_col245),
           DECODE( p_col246, FND_API.g_miss_char, NULL, p_col246),
           DECODE( p_col247, FND_API.g_miss_char, NULL, p_col247),
           DECODE( p_col248, FND_API.g_miss_char, NULL, p_col248),
           DECODE( p_col249, FND_API.g_miss_char, NULL, p_col249),
           DECODE( p_col250, FND_API.g_miss_char, NULL, p_col250),
           DECODE( p_duplicate_flag, FND_API.g_miss_char, NULL, p_duplicate_flag),
           DECODE( p_current_usage, FND_API.g_miss_num, NULL, p_current_usage),
	   'ACTIVE',
           DECODE( p_notes, FND_API.g_miss_char, NULL, p_notes),
           DECODE( p_sales_agent_email_address, FND_API.g_miss_char, NULL, p_sales_agent_email_address),
           DECODE(  p_vehicle_response_code, FND_API.g_miss_char, NULL,  p_vehicle_response_code),
            DECODE(  p_custom_column1, FND_API.g_miss_char, NULL,  p_custom_column1),
            DECODE(  p_custom_column2, FND_API.g_miss_char, NULL,  p_custom_column2),
            DECODE(  p_custom_column3, FND_API.g_miss_char, NULL,  p_custom_column3),
            DECODE(  p_custom_column4, FND_API.g_miss_char, NULL,  p_custom_column4),
            DECODE(  p_custom_column5, FND_API.g_miss_char, NULL,  p_custom_column5),
            DECODE(  p_custom_column6, FND_API.g_miss_char, NULL,  p_custom_column6),
            DECODE(  p_custom_column7, FND_API.g_miss_char, NULL,  p_custom_column7),
            DECODE(  p_custom_column8, FND_API.g_miss_char, NULL,  p_custom_column8),
            DECODE(  p_custom_column9, FND_API.g_miss_char, NULL,  p_custom_column9),
            DECODE(  p_custom_column10, FND_API.g_miss_char, NULL,  p_custom_column10),
            DECODE(  p_custom_column11, FND_API.g_miss_char, NULL,  p_custom_column11),
            DECODE(  p_custom_column12, FND_API.g_miss_char, NULL,  p_custom_column12),
            DECODE(  p_custom_column13, FND_API.g_miss_char, NULL,  p_custom_column13),
            DECODE(  p_custom_column14, FND_API.g_miss_char, NULL,  p_custom_column14),
            DECODE(  p_custom_column15, FND_API.g_miss_char, NULL,  p_custom_column15),
            DECODE(  p_custom_column16, FND_API.g_miss_char, NULL,  p_custom_column16),
            DECODE(  p_custom_column17, FND_API.g_miss_char, NULL,  p_custom_column17),
            DECODE(  p_custom_column18, FND_API.g_miss_char, NULL,  p_custom_column18),
            DECODE(  p_custom_column19, FND_API.g_miss_char, NULL,  p_custom_column19),
            DECODE(  p_custom_column20, FND_API.g_miss_char, NULL,  p_custom_column20),
            DECODE(  p_custom_column21, FND_API.g_miss_char, NULL,  p_custom_column21),
            DECODE(  p_custom_column22, FND_API.g_miss_char, NULL,  p_custom_column22),
            DECODE(  p_custom_column23, FND_API.g_miss_char, NULL,  p_custom_column23),
            DECODE(  p_custom_column24, FND_API.g_miss_char, NULL,  p_custom_column24),
            DECODE(  p_custom_column25, FND_API.g_miss_char, NULL,  p_custom_column25)


	   );
END Insert_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createUpdateBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
          p_import_source_line_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_import_list_header_id    NUMBER,
          p_import_successful_flag    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_import_failure_reason    VARCHAR2,
          p_re_import_last_done_date    DATE,
          p_party_id    NUMBER,
          p_dedupe_key    VARCHAR2,
          p_col1    VARCHAR2,
          p_col2    VARCHAR2,
          p_col3    VARCHAR2,
          p_col4    VARCHAR2,
          p_col5    VARCHAR2,
          p_col6    VARCHAR2,
          p_col7    VARCHAR2,
          p_col8    VARCHAR2,
          p_col9    VARCHAR2,
          p_col10    VARCHAR2,
          p_col11    VARCHAR2,
          p_col12    VARCHAR2,
          p_col13    VARCHAR2,
          p_col14    VARCHAR2,
          p_col15    VARCHAR2,
          p_col16    VARCHAR2,
          p_col17    VARCHAR2,
          p_col18    VARCHAR2,
          p_col19    VARCHAR2,
          p_col20    VARCHAR2,
          p_col21    VARCHAR2,
          p_col22    VARCHAR2,
          p_col23    VARCHAR2,
          p_col24    VARCHAR2,
          p_col25    VARCHAR2,
          p_col26    VARCHAR2,
          p_col27    VARCHAR2,
          p_col28    VARCHAR2,
          p_col29    VARCHAR2,
          p_col30    VARCHAR2,
          p_col31    VARCHAR2,
          p_col32    VARCHAR2,
          p_col33    VARCHAR2,
          p_col34    VARCHAR2,
          p_col35    VARCHAR2,
          p_col36    VARCHAR2,
          p_col37    VARCHAR2,
          p_col38    VARCHAR2,
          p_col39    VARCHAR2,
          p_col40    VARCHAR2,
          p_col41    VARCHAR2,
          p_col42    VARCHAR2,
          p_col43    VARCHAR2,
          p_col44    VARCHAR2,
          p_col45    VARCHAR2,
          p_col46    VARCHAR2,
          p_col47    VARCHAR2,
          p_col48    VARCHAR2,
          p_col49    VARCHAR2,
          p_col50    VARCHAR2,
          p_col51    VARCHAR2,
          p_col52    VARCHAR2,
          p_col53    VARCHAR2,
          p_col54    VARCHAR2,
          p_col55    VARCHAR2,
          p_col56    VARCHAR2,
          p_col57    VARCHAR2,
          p_col58    VARCHAR2,
          p_col59    VARCHAR2,
          p_col60    VARCHAR2,
          p_col61    VARCHAR2,
          p_col62    VARCHAR2,
          p_col63    VARCHAR2,
          p_col64    VARCHAR2,
          p_col65    VARCHAR2,
          p_col66    VARCHAR2,
          p_col67    VARCHAR2,
          p_col68    VARCHAR2,
          p_col69    VARCHAR2,
          p_col70    VARCHAR2,
          p_col71    VARCHAR2,
          p_col72    VARCHAR2,
          p_col73    VARCHAR2,
          p_col74    VARCHAR2,
          p_col75    VARCHAR2,
          p_col76    VARCHAR2,
          p_col77    VARCHAR2,
          p_col78    VARCHAR2,
          p_col79    VARCHAR2,
          p_col80    VARCHAR2,
          p_col81    VARCHAR2,
          p_col82    VARCHAR2,
          p_col83    VARCHAR2,
          p_col84    VARCHAR2,
          p_col85    VARCHAR2,
          p_col86    VARCHAR2,
          p_col87    VARCHAR2,
          p_col88    VARCHAR2,
          p_col89    VARCHAR2,
          p_col90    VARCHAR2,
          p_col91    VARCHAR2,
          p_col92    VARCHAR2,
          p_col93    VARCHAR2,
          p_col94    VARCHAR2,
          p_col95    VARCHAR2,
          p_col96    VARCHAR2,
          p_col97    VARCHAR2,
          p_col98    VARCHAR2,
          p_col99    VARCHAR2,
          p_col100    VARCHAR2,
          p_col101    VARCHAR2,
          p_col102    VARCHAR2,
          p_col103    VARCHAR2,
          p_col104    VARCHAR2,
          p_col105    VARCHAR2,
          p_col106    VARCHAR2,
          p_col107    VARCHAR2,
          p_col108    VARCHAR2,
          p_col109    VARCHAR2,
          p_col110    VARCHAR2,
          p_col111    VARCHAR2,
          p_col112    VARCHAR2,
          p_col113    VARCHAR2,
          p_col114    VARCHAR2,
          p_col115    VARCHAR2,
          p_col116    VARCHAR2,
          p_col117    VARCHAR2,
          p_col118    VARCHAR2,
          p_col119    VARCHAR2,
          p_col120    VARCHAR2,
          p_col121    VARCHAR2,
          p_col122    VARCHAR2,
          p_col123    VARCHAR2,
          p_col124    VARCHAR2,
          p_col125    VARCHAR2,
          p_col126    VARCHAR2,
          p_col127    VARCHAR2,
          p_col128    VARCHAR2,
          p_col129    VARCHAR2,
          p_col130    VARCHAR2,
          p_col131    VARCHAR2,
          p_col132    VARCHAR2,
          p_col133    VARCHAR2,
          p_col134    VARCHAR2,
          p_col135    VARCHAR2,
          p_col136    VARCHAR2,
          p_col137    VARCHAR2,
          p_col138    VARCHAR2,
          p_col139    VARCHAR2,
          p_col140    VARCHAR2,
          p_col141    VARCHAR2,
          p_col142    VARCHAR2,
          p_col143    VARCHAR2,
          p_col144    VARCHAR2,
          p_col145    VARCHAR2,
          p_col146    VARCHAR2,
          p_col147    VARCHAR2,
          p_col148    VARCHAR2,
          p_col149    VARCHAR2,
          p_col150    VARCHAR2,
          p_col151    VARCHAR2,
          p_col152    VARCHAR2,
          p_col153    VARCHAR2,
          p_col154    VARCHAR2,
          p_col155    VARCHAR2,
          p_col156    VARCHAR2,
          p_col157    VARCHAR2,
          p_col158    VARCHAR2,
          p_col159    VARCHAR2,
          p_col160    VARCHAR2,
          p_col161    VARCHAR2,
          p_col162    VARCHAR2,
          p_col163    VARCHAR2,
          p_col164    VARCHAR2,
          p_col165    VARCHAR2,
          p_col166    VARCHAR2,
          p_col167    VARCHAR2,
          p_col168    VARCHAR2,
          p_col169    VARCHAR2,
          p_col170    VARCHAR2,
          p_col171    VARCHAR2,
          p_col172    VARCHAR2,
          p_col173    VARCHAR2,
          p_col174    VARCHAR2,
          p_col175    VARCHAR2,
          p_col176    VARCHAR2,
          p_col177    VARCHAR2,
          p_col178    VARCHAR2,
          p_col179    VARCHAR2,
          p_col180    VARCHAR2,
          p_col181    VARCHAR2,
          p_col182    VARCHAR2,
          p_col183    VARCHAR2,
          p_col184    VARCHAR2,
          p_col185    VARCHAR2,
          p_col186    VARCHAR2,
          p_col187    VARCHAR2,
          p_col188    VARCHAR2,
          p_col189    VARCHAR2,
          p_col190    VARCHAR2,
          p_col191    VARCHAR2,
          p_col192    VARCHAR2,
          p_col193    VARCHAR2,
          p_col194    VARCHAR2,
          p_col195    VARCHAR2,
          p_col196    VARCHAR2,
          p_col197    VARCHAR2,
          p_col198    VARCHAR2,
          p_col199    VARCHAR2,
          p_col200    VARCHAR2,
          p_col201    VARCHAR2,
          p_col202    VARCHAR2,
          p_col203    VARCHAR2,
          p_col204    VARCHAR2,
          p_col205    VARCHAR2,
          p_col206    VARCHAR2,
          p_col207    VARCHAR2,
          p_col208    VARCHAR2,
          p_col209    VARCHAR2,
          p_col210    VARCHAR2,
          p_col211    VARCHAR2,
          p_col212    VARCHAR2,
          p_col213    VARCHAR2,
          p_col214    VARCHAR2,
          p_col215    VARCHAR2,
          p_col216    VARCHAR2,
          p_col217    VARCHAR2,
          p_col218    VARCHAR2,
          p_col219    VARCHAR2,
          p_col220    VARCHAR2,
          p_col221    VARCHAR2,
          p_col222    VARCHAR2,
          p_col223    VARCHAR2,
          p_col224    VARCHAR2,
          p_col225    VARCHAR2,
          p_col226    VARCHAR2,
          p_col227    VARCHAR2,
          p_col228    VARCHAR2,
          p_col229    VARCHAR2,
          p_col230    VARCHAR2,
          p_col231    VARCHAR2,
          p_col232    VARCHAR2,
          p_col233    VARCHAR2,
          p_col234    VARCHAR2,
          p_col235    VARCHAR2,
          p_col236    VARCHAR2,
          p_col237    VARCHAR2,
          p_col238    VARCHAR2,
          p_col239    VARCHAR2,
          p_col240    VARCHAR2,
          p_col241    VARCHAR2,
          p_col242    VARCHAR2,
          p_col243    VARCHAR2,
          p_col244    VARCHAR2,
          p_col245    VARCHAR2,
          p_col246    VARCHAR2,
          p_col247    VARCHAR2,
          p_col248    VARCHAR2,
          p_col249    VARCHAR2,
          p_col250    VARCHAR2,
          p_duplicate_flag    VARCHAR2,
          p_current_usage    NUMBER,
	  p_load_status VARCHAR2,
  	  p_notes     VARCHAR2,
	  p_sales_agent_email_address VARCHAR2,
	  p_vehicle_response_code VARCHAR2,
p_custom_column1 VARCHAR2,
p_custom_column2 VARCHAR2,
p_custom_column3 VARCHAR2,
p_custom_column4 VARCHAR2,
p_custom_column5 VARCHAR2,
p_custom_column6 VARCHAR2,
p_custom_column7 VARCHAR2,
p_custom_column8 VARCHAR2,
p_custom_column9 VARCHAR2,
p_custom_column10 VARCHAR2,
p_custom_column11 VARCHAR2,
p_custom_column12 VARCHAR2,
p_custom_column13 VARCHAR2,
p_custom_column14 VARCHAR2,
p_custom_column15 VARCHAR2,
p_custom_column16 VARCHAR2,
p_custom_column17 VARCHAR2,
p_custom_column18 VARCHAR2,
p_custom_column19 VARCHAR2,
p_custom_column20 VARCHAR2,
p_custom_column21 VARCHAR2,
p_custom_column22 VARCHAR2,
p_custom_column23 VARCHAR2,
p_custom_column24 VARCHAR2,
p_custom_column25 VARCHAR2

      )


 IS
 BEGIN
    Update AMS_IMP_SOURCE_LINES
    SET
              import_source_line_id = DECODE( p_import_source_line_id, FND_API.g_miss_num, import_source_line_id, p_import_source_line_id),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
              created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              import_list_header_id = DECODE( p_import_list_header_id, FND_API.g_miss_num, import_list_header_id, p_import_list_header_id),
              import_successful_flag = DECODE( p_import_successful_flag, FND_API.g_miss_char, import_successful_flag, p_import_successful_flag),
              enabled_flag = DECODE( p_enabled_flag, FND_API.g_miss_char, enabled_flag, p_enabled_flag),
              import_failure_reason = DECODE( p_import_failure_reason, FND_API.g_miss_char, import_failure_reason, p_import_failure_reason),
              re_import_last_done_date = DECODE( p_re_import_last_done_date, FND_API.g_miss_date, re_import_last_done_date, p_re_import_last_done_date),
              party_id = DECODE( p_party_id, FND_API.g_miss_num, party_id, p_party_id),
              dedupe_key = DECODE( p_dedupe_key, FND_API.g_miss_char, dedupe_key, p_dedupe_key),
              col1 = DECODE( p_col1, FND_API.g_miss_char, col1, p_col1),
              col2 = DECODE( p_col2, FND_API.g_miss_char, col2, p_col2),
              col3 = DECODE( p_col3, FND_API.g_miss_char, col3, p_col3),
              col4 = DECODE( p_col4, FND_API.g_miss_char, col4, p_col4),
              col5 = DECODE( p_col5, FND_API.g_miss_char, col5, p_col5),
              col6 = DECODE( p_col6, FND_API.g_miss_char, col6, p_col6),
              col7 = DECODE( p_col7, FND_API.g_miss_char, col7, p_col7),
              col8 = DECODE( p_col8, FND_API.g_miss_char, col8, p_col8),
              col9 = DECODE( p_col9, FND_API.g_miss_char, col9, p_col9),
              col10 = DECODE( p_col10, FND_API.g_miss_char, col10, p_col10),
              col11 = DECODE( p_col11, FND_API.g_miss_char, col11, p_col11),
              col12 = DECODE( p_col12, FND_API.g_miss_char, col12, p_col12),
              col13 = DECODE( p_col13, FND_API.g_miss_char, col13, p_col13),
              col14 = DECODE( p_col14, FND_API.g_miss_char, col14, p_col14),
              col15 = DECODE( p_col15, FND_API.g_miss_char, col15, p_col15),
              col16 = DECODE( p_col16, FND_API.g_miss_char, col16, p_col16),
              col17 = DECODE( p_col17, FND_API.g_miss_char, col17, p_col17),
              col18 = DECODE( p_col18, FND_API.g_miss_char, col18, p_col18),
              col19 = DECODE( p_col19, FND_API.g_miss_char, col19, p_col19),
              col20 = DECODE( p_col20, FND_API.g_miss_char, col20, p_col20),
              col21 = DECODE( p_col21, FND_API.g_miss_char, col21, p_col21),
              col22 = DECODE( p_col22, FND_API.g_miss_char, col22, p_col22),
              col23 = DECODE( p_col23, FND_API.g_miss_char, col23, p_col23),
              col24 = DECODE( p_col24, FND_API.g_miss_char, col24, p_col24),
              col25 = DECODE( p_col25, FND_API.g_miss_char, col25, p_col25),
              col26 = DECODE( p_col26, FND_API.g_miss_char, col26, p_col26),
              col27 = DECODE( p_col27, FND_API.g_miss_char, col27, p_col27),
              col28 = DECODE( p_col28, FND_API.g_miss_char, col28, p_col28),
              col29 = DECODE( p_col29, FND_API.g_miss_char, col29, p_col29),
              col30 = DECODE( p_col30, FND_API.g_miss_char, col30, p_col30),
              col31 = DECODE( p_col31, FND_API.g_miss_char, col31, p_col31),
              col32 = DECODE( p_col32, FND_API.g_miss_char, col32, p_col32),
              col33 = DECODE( p_col33, FND_API.g_miss_char, col33, p_col33),
              col34 = DECODE( p_col34, FND_API.g_miss_char, col34, p_col34),
              col35 = DECODE( p_col35, FND_API.g_miss_char, col35, p_col35),
              col36 = DECODE( p_col36, FND_API.g_miss_char, col36, p_col36),
              col37 = DECODE( p_col37, FND_API.g_miss_char, col37, p_col37),
              col38 = DECODE( p_col38, FND_API.g_miss_char, col38, p_col38),
              col39 = DECODE( p_col39, FND_API.g_miss_char, col39, p_col39),
              col40 = DECODE( p_col40, FND_API.g_miss_char, col40, p_col40),
              col41 = DECODE( p_col41, FND_API.g_miss_char, col41, p_col41),
              col42 = DECODE( p_col42, FND_API.g_miss_char, col42, p_col42),
              col43 = DECODE( p_col43, FND_API.g_miss_char, col43, p_col43),
              col44 = DECODE( p_col44, FND_API.g_miss_char, col44, p_col44),
              col45 = DECODE( p_col45, FND_API.g_miss_char, col45, p_col45),
              col46 = DECODE( p_col46, FND_API.g_miss_char, col46, p_col46),
              col47 = DECODE( p_col47, FND_API.g_miss_char, col47, p_col47),
              col48 = DECODE( p_col48, FND_API.g_miss_char, col48, p_col48),
              col49 = DECODE( p_col49, FND_API.g_miss_char, col49, p_col49),
              col50 = DECODE( p_col50, FND_API.g_miss_char, col50, p_col50),
              col51 = DECODE( p_col51, FND_API.g_miss_char, col51, p_col51),
              col52 = DECODE( p_col52, FND_API.g_miss_char, col52, p_col52),
              col53 = DECODE( p_col53, FND_API.g_miss_char, col53, p_col53),
              col54 = DECODE( p_col54, FND_API.g_miss_char, col54, p_col54),
              col55 = DECODE( p_col55, FND_API.g_miss_char, col55, p_col55),
              col56 = DECODE( p_col56, FND_API.g_miss_char, col56, p_col56),
              col57 = DECODE( p_col57, FND_API.g_miss_char, col57, p_col57),
              col58 = DECODE( p_col58, FND_API.g_miss_char, col58, p_col58),
              col59 = DECODE( p_col59, FND_API.g_miss_char, col59, p_col59),
              col60 = DECODE( p_col60, FND_API.g_miss_char, col60, p_col60),
              col61 = DECODE( p_col61, FND_API.g_miss_char, col61, p_col61),
              col62 = DECODE( p_col62, FND_API.g_miss_char, col62, p_col62),
              col63 = DECODE( p_col63, FND_API.g_miss_char, col63, p_col63),
              col64 = DECODE( p_col64, FND_API.g_miss_char, col64, p_col64),
              col65 = DECODE( p_col65, FND_API.g_miss_char, col65, p_col65),
              col66 = DECODE( p_col66, FND_API.g_miss_char, col66, p_col66),
              col67 = DECODE( p_col67, FND_API.g_miss_char, col67, p_col67),
              col68 = DECODE( p_col68, FND_API.g_miss_char, col68, p_col68),
              col69 = DECODE( p_col69, FND_API.g_miss_char, col69, p_col69),
              col70 = DECODE( p_col70, FND_API.g_miss_char, col70, p_col70),
              col71 = DECODE( p_col71, FND_API.g_miss_char, col71, p_col71),
              col72 = DECODE( p_col72, FND_API.g_miss_char, col72, p_col72),
              col73 = DECODE( p_col73, FND_API.g_miss_char, col73, p_col73),
              col74 = DECODE( p_col74, FND_API.g_miss_char, col74, p_col74),
              col75 = DECODE( p_col75, FND_API.g_miss_char, col75, p_col75),
              col76 = DECODE( p_col76, FND_API.g_miss_char, col76, p_col76),
              col77 = DECODE( p_col77, FND_API.g_miss_char, col77, p_col77),
              col78 = DECODE( p_col78, FND_API.g_miss_char, col78, p_col78),
              col79 = DECODE( p_col79, FND_API.g_miss_char, col79, p_col79),
              col80 = DECODE( p_col80, FND_API.g_miss_char, col80, p_col80),
              col81 = DECODE( p_col81, FND_API.g_miss_char, col81, p_col81),
              col82 = DECODE( p_col82, FND_API.g_miss_char, col82, p_col82),
              col83 = DECODE( p_col83, FND_API.g_miss_char, col83, p_col83),
              col84 = DECODE( p_col84, FND_API.g_miss_char, col84, p_col84),
              col85 = DECODE( p_col85, FND_API.g_miss_char, col85, p_col85),
              col86 = DECODE( p_col86, FND_API.g_miss_char, col86, p_col86),
              col87 = DECODE( p_col87, FND_API.g_miss_char, col87, p_col87),
              col88 = DECODE( p_col88, FND_API.g_miss_char, col88, p_col88),
              col89 = DECODE( p_col89, FND_API.g_miss_char, col89, p_col89),
              col90 = DECODE( p_col90, FND_API.g_miss_char, col90, p_col90),
              col91 = DECODE( p_col91, FND_API.g_miss_char, col91, p_col91),
              col92 = DECODE( p_col92, FND_API.g_miss_char, col92, p_col92),
              col93 = DECODE( p_col93, FND_API.g_miss_char, col93, p_col93),
              col94 = DECODE( p_col94, FND_API.g_miss_char, col94, p_col94),
              col95 = DECODE( p_col95, FND_API.g_miss_char, col95, p_col95),
              col96 = DECODE( p_col96, FND_API.g_miss_char, col96, p_col96),
              col97 = DECODE( p_col97, FND_API.g_miss_char, col97, p_col97),
              col98 = DECODE( p_col98, FND_API.g_miss_char, col98, p_col98),
              col99 = DECODE( p_col99, FND_API.g_miss_char, col99, p_col99),
              col100 = DECODE( p_col100, FND_API.g_miss_char, col100, p_col100),
              col101 = DECODE( p_col101, FND_API.g_miss_char, col101, p_col101),
              col102 = DECODE( p_col102, FND_API.g_miss_char, col102, p_col102),
              col103 = DECODE( p_col103, FND_API.g_miss_char, col103, p_col103),
              col104 = DECODE( p_col104, FND_API.g_miss_char, col104, p_col104),
              col105 = DECODE( p_col105, FND_API.g_miss_char, col105, p_col105),
              col106 = DECODE( p_col106, FND_API.g_miss_char, col106, p_col106),
              col107 = DECODE( p_col107, FND_API.g_miss_char, col107, p_col107),
              col108 = DECODE( p_col108, FND_API.g_miss_char, col108, p_col108),
              col109 = DECODE( p_col109, FND_API.g_miss_char, col109, p_col109),
              col110 = DECODE( p_col110, FND_API.g_miss_char, col110, p_col110),
              col111 = DECODE( p_col111, FND_API.g_miss_char, col111, p_col111),
              col112 = DECODE( p_col112, FND_API.g_miss_char, col112, p_col112),
              col113 = DECODE( p_col113, FND_API.g_miss_char, col113, p_col113),
              col114 = DECODE( p_col114, FND_API.g_miss_char, col114, p_col114),
              col115 = DECODE( p_col115, FND_API.g_miss_char, col115, p_col115),
              col116 = DECODE( p_col116, FND_API.g_miss_char, col116, p_col116),
              col117 = DECODE( p_col117, FND_API.g_miss_char, col117, p_col117),
              col118 = DECODE( p_col118, FND_API.g_miss_char, col118, p_col118),
              col119 = DECODE( p_col119, FND_API.g_miss_char, col119, p_col119),
              col120 = DECODE( p_col120, FND_API.g_miss_char, col120, p_col120),
              col121 = DECODE( p_col121, FND_API.g_miss_char, col121, p_col121),
              col122 = DECODE( p_col122, FND_API.g_miss_char, col122, p_col122),
              col123 = DECODE( p_col123, FND_API.g_miss_char, col123, p_col123),
              col124 = DECODE( p_col124, FND_API.g_miss_char, col124, p_col124),
              col125 = DECODE( p_col125, FND_API.g_miss_char, col125, p_col125),
              col126 = DECODE( p_col126, FND_API.g_miss_char, col126, p_col126),
              col127 = DECODE( p_col127, FND_API.g_miss_char, col127, p_col127),
              col128 = DECODE( p_col128, FND_API.g_miss_char, col128, p_col128),
              col129 = DECODE( p_col129, FND_API.g_miss_char, col129, p_col129),
              col130 = DECODE( p_col130, FND_API.g_miss_char, col130, p_col130),
              col131 = DECODE( p_col131, FND_API.g_miss_char, col131, p_col131),
              col132 = DECODE( p_col132, FND_API.g_miss_char, col132, p_col132),
              col133 = DECODE( p_col133, FND_API.g_miss_char, col133, p_col133),
              col134 = DECODE( p_col134, FND_API.g_miss_char, col134, p_col134),
              col135 = DECODE( p_col135, FND_API.g_miss_char, col135, p_col135),
              col136 = DECODE( p_col136, FND_API.g_miss_char, col136, p_col136),
              col137 = DECODE( p_col137, FND_API.g_miss_char, col137, p_col137),
              col138 = DECODE( p_col138, FND_API.g_miss_char, col138, p_col138),
              col139 = DECODE( p_col139, FND_API.g_miss_char, col139, p_col139),
              col140 = DECODE( p_col140, FND_API.g_miss_char, col140, p_col140),
              col141 = DECODE( p_col141, FND_API.g_miss_char, col141, p_col141),
              col142 = DECODE( p_col142, FND_API.g_miss_char, col142, p_col142),
              col143 = DECODE( p_col143, FND_API.g_miss_char, col143, p_col143),
              col144 = DECODE( p_col144, FND_API.g_miss_char, col144, p_col144),
              col145 = DECODE( p_col145, FND_API.g_miss_char, col145, p_col145),
              col146 = DECODE( p_col146, FND_API.g_miss_char, col146, p_col146),
              col147 = DECODE( p_col147, FND_API.g_miss_char, col147, p_col147),
              col148 = DECODE( p_col148, FND_API.g_miss_char, col148, p_col148),
              col149 = DECODE( p_col149, FND_API.g_miss_char, col149, p_col149),
              col150 = DECODE( p_col150, FND_API.g_miss_char, col150, p_col150),
              col151 = DECODE( p_col151, FND_API.g_miss_char, col151, p_col151),
              col152 = DECODE( p_col152, FND_API.g_miss_char, col152, p_col152),
              col153 = DECODE( p_col153, FND_API.g_miss_char, col153, p_col153),
              col154 = DECODE( p_col154, FND_API.g_miss_char, col154, p_col154),
              col155 = DECODE( p_col155, FND_API.g_miss_char, col155, p_col155),
              col156 = DECODE( p_col156, FND_API.g_miss_char, col156, p_col156),
              col157 = DECODE( p_col157, FND_API.g_miss_char, col157, p_col157),
              col158 = DECODE( p_col158, FND_API.g_miss_char, col158, p_col158),
              col159 = DECODE( p_col159, FND_API.g_miss_char, col159, p_col159),
              col160 = DECODE( p_col160, FND_API.g_miss_char, col160, p_col160),
              col161 = DECODE( p_col161, FND_API.g_miss_char, col161, p_col161),
              col162 = DECODE( p_col162, FND_API.g_miss_char, col162, p_col162),
              col163 = DECODE( p_col163, FND_API.g_miss_char, col163, p_col163),
              col164 = DECODE( p_col164, FND_API.g_miss_char, col164, p_col164),
              col165 = DECODE( p_col165, FND_API.g_miss_char, col165, p_col165),
              col166 = DECODE( p_col166, FND_API.g_miss_char, col166, p_col166),
              col167 = DECODE( p_col167, FND_API.g_miss_char, col167, p_col167),
              col168 = DECODE( p_col168, FND_API.g_miss_char, col168, p_col168),
              col169 = DECODE( p_col169, FND_API.g_miss_char, col169, p_col169),
              col170 = DECODE( p_col170, FND_API.g_miss_char, col170, p_col170),
              col171 = DECODE( p_col171, FND_API.g_miss_char, col171, p_col171),
              col172 = DECODE( p_col172, FND_API.g_miss_char, col172, p_col172),
              col173 = DECODE( p_col173, FND_API.g_miss_char, col173, p_col173),
              col174 = DECODE( p_col174, FND_API.g_miss_char, col174, p_col174),
              col175 = DECODE( p_col175, FND_API.g_miss_char, col175, p_col175),
              col176 = DECODE( p_col176, FND_API.g_miss_char, col176, p_col176),
              col177 = DECODE( p_col177, FND_API.g_miss_char, col177, p_col177),
              col178 = DECODE( p_col178, FND_API.g_miss_char, col178, p_col178),
              col179 = DECODE( p_col179, FND_API.g_miss_char, col179, p_col179),
              col180 = DECODE( p_col180, FND_API.g_miss_char, col180, p_col180),
              col181 = DECODE( p_col181, FND_API.g_miss_char, col181, p_col181),
              col182 = DECODE( p_col182, FND_API.g_miss_char, col182, p_col182),
              col183 = DECODE( p_col183, FND_API.g_miss_char, col183, p_col183),
              col184 = DECODE( p_col184, FND_API.g_miss_char, col184, p_col184),
              col185 = DECODE( p_col185, FND_API.g_miss_char, col185, p_col185),
              col186 = DECODE( p_col186, FND_API.g_miss_char, col186, p_col186),
              col187 = DECODE( p_col187, FND_API.g_miss_char, col187, p_col187),
              col188 = DECODE( p_col188, FND_API.g_miss_char, col188, p_col188),
              col189 = DECODE( p_col189, FND_API.g_miss_char, col189, p_col189),
              col190 = DECODE( p_col190, FND_API.g_miss_char, col190, p_col190),
              col191 = DECODE( p_col191, FND_API.g_miss_char, col191, p_col191),
              col192 = DECODE( p_col192, FND_API.g_miss_char, col192, p_col192),
              col193 = DECODE( p_col193, FND_API.g_miss_char, col193, p_col193),
              col194 = DECODE( p_col194, FND_API.g_miss_char, col194, p_col194),
              col195 = DECODE( p_col195, FND_API.g_miss_char, col195, p_col195),
              col196 = DECODE( p_col196, FND_API.g_miss_char, col196, p_col196),
              col197 = DECODE( p_col197, FND_API.g_miss_char, col197, p_col197),
              col198 = DECODE( p_col198, FND_API.g_miss_char, col198, p_col198),
              col199 = DECODE( p_col199, FND_API.g_miss_char, col199, p_col199),
              col200 = DECODE( p_col200, FND_API.g_miss_char, col200, p_col200),
              col201 = DECODE( p_col201, FND_API.g_miss_char, col201, p_col201),
              col202 = DECODE( p_col202, FND_API.g_miss_char, col202, p_col202),
              col203 = DECODE( p_col203, FND_API.g_miss_char, col203, p_col203),
              col204 = DECODE( p_col204, FND_API.g_miss_char, col204, p_col204),
              col205 = DECODE( p_col205, FND_API.g_miss_char, col205, p_col205),
              col206 = DECODE( p_col206, FND_API.g_miss_char, col206, p_col206),
              col207 = DECODE( p_col207, FND_API.g_miss_char, col207, p_col207),
              col208 = DECODE( p_col208, FND_API.g_miss_char, col208, p_col208),
              col209 = DECODE( p_col209, FND_API.g_miss_char, col209, p_col209),
              col210 = DECODE( p_col210, FND_API.g_miss_char, col210, p_col210),
              col211 = DECODE( p_col211, FND_API.g_miss_char, col211, p_col211),
              col212 = DECODE( p_col212, FND_API.g_miss_char, col212, p_col212),
              col213 = DECODE( p_col213, FND_API.g_miss_char, col213, p_col213),
              col214 = DECODE( p_col214, FND_API.g_miss_char, col214, p_col214),
              col215 = DECODE( p_col215, FND_API.g_miss_char, col215, p_col215),
              col216 = DECODE( p_col216, FND_API.g_miss_char, col216, p_col216),
              col217 = DECODE( p_col217, FND_API.g_miss_char, col217, p_col217),
              col218 = DECODE( p_col218, FND_API.g_miss_char, col218, p_col218),
              col219 = DECODE( p_col219, FND_API.g_miss_char, col219, p_col219),
              col220 = DECODE( p_col220, FND_API.g_miss_char, col220, p_col220),
              col221 = DECODE( p_col221, FND_API.g_miss_char, col221, p_col221),
              col222 = DECODE( p_col222, FND_API.g_miss_char, col222, p_col222),
              col223 = DECODE( p_col223, FND_API.g_miss_char, col223, p_col223),
              col224 = DECODE( p_col224, FND_API.g_miss_char, col224, p_col224),
              col225 = DECODE( p_col225, FND_API.g_miss_char, col225, p_col225),
              col226 = DECODE( p_col226, FND_API.g_miss_char, col226, p_col226),
              col227 = DECODE( p_col227, FND_API.g_miss_char, col227, p_col227),
              col228 = DECODE( p_col228, FND_API.g_miss_char, col228, p_col228),
              col229 = DECODE( p_col229, FND_API.g_miss_char, col229, p_col229),
              col230 = DECODE( p_col230, FND_API.g_miss_char, col230, p_col230),
              col231 = DECODE( p_col231, FND_API.g_miss_char, col231, p_col231),
              col232 = DECODE( p_col232, FND_API.g_miss_char, col232, p_col232),
              col233 = DECODE( p_col233, FND_API.g_miss_char, col233, p_col233),
              col234 = DECODE( p_col234, FND_API.g_miss_char, col234, p_col234),
              col235 = DECODE( p_col235, FND_API.g_miss_char, col235, p_col235),
              col236 = DECODE( p_col236, FND_API.g_miss_char, col236, p_col236),
              col237 = DECODE( p_col237, FND_API.g_miss_char, col237, p_col237),
              col238 = DECODE( p_col238, FND_API.g_miss_char, col238, p_col238),
              col239 = DECODE( p_col239, FND_API.g_miss_char, col239, p_col239),
              col240 = DECODE( p_col240, FND_API.g_miss_char, col240, p_col240),
              col241 = DECODE( p_col241, FND_API.g_miss_char, col241, p_col241),
              col242 = DECODE( p_col242, FND_API.g_miss_char, col242, p_col242),
              col243 = DECODE( p_col243, FND_API.g_miss_char, col243, p_col243),
              col244 = DECODE( p_col244, FND_API.g_miss_char, col244, p_col244),
              col245 = DECODE( p_col245, FND_API.g_miss_char, col245, p_col245),
              col246 = DECODE( p_col246, FND_API.g_miss_char, col246, p_col246),
              col247 = DECODE( p_col247, FND_API.g_miss_char, col247, p_col247),
              col248 = DECODE( p_col248, FND_API.g_miss_char, col248, p_col248),
              col249 = DECODE( p_col249, FND_API.g_miss_char, col249, p_col249),
              col250 = DECODE( p_col250, FND_API.g_miss_char, col250, p_col250),
              duplicate_flag = DECODE( p_duplicate_flag, FND_API.g_miss_char, duplicate_flag, p_duplicate_flag),
              current_usage = DECODE( p_current_usage, FND_API.g_miss_num, current_usage, p_current_usage),
	      load_status = DECODE( p_load_status, FND_API.g_miss_char, load_status, p_load_status),
              notes = DECODE( p_notes, FND_API.g_miss_char, notes, p_notes),
              sales_agent_email_address = DECODE( p_sales_agent_email_address, FND_API.g_miss_char, sales_agent_email_address, p_sales_agent_email_address),
              vehicle_response_code = DECODE( p_vehicle_response_code, FND_API.g_miss_char, vehicle_response_code, p_vehicle_response_code),
custom_column1 = DECODE( p_custom_column1, FND_API.g_miss_char, custom_column1, p_custom_column1),
custom_column2 = DECODE( p_custom_column2, FND_API.g_miss_char, custom_column2, p_custom_column2),
custom_column3 = DECODE( p_custom_column3, FND_API.g_miss_char, custom_column3, p_custom_column3),
custom_column4 = DECODE( p_custom_column4, FND_API.g_miss_char, custom_column4, p_custom_column4),
custom_column5 = DECODE( p_custom_column5, FND_API.g_miss_char, custom_column5, p_custom_column5),
custom_column6 = DECODE( p_custom_column6, FND_API.g_miss_char, custom_column6, p_custom_column6),
custom_column7 = DECODE( p_custom_column7, FND_API.g_miss_char, custom_column7, p_custom_column7),
custom_column8 = DECODE( p_custom_column8, FND_API.g_miss_char, custom_column8, p_custom_column8),
custom_column9 = DECODE( p_custom_column9, FND_API.g_miss_char, custom_column9, p_custom_column9),
custom_column10 = DECODE( p_custom_column10, FND_API.g_miss_char, custom_column10, p_custom_column10),
custom_column11 = DECODE( p_custom_column11, FND_API.g_miss_char, custom_column11, p_custom_column11),
custom_column12 = DECODE( p_custom_column12, FND_API.g_miss_char, custom_column12, p_custom_column12),
custom_column13 = DECODE( p_custom_column13, FND_API.g_miss_char, custom_column13, p_custom_column13),
custom_column14 = DECODE( p_custom_column14, FND_API.g_miss_char, custom_column14, p_custom_column14),
custom_column15 = DECODE( p_custom_column15, FND_API.g_miss_char, custom_column15, p_custom_column15),
custom_column16 = DECODE( p_custom_column16, FND_API.g_miss_char, custom_column16, p_custom_column16),
custom_column17 = DECODE( p_custom_column17, FND_API.g_miss_char, custom_column17, p_custom_column17),
custom_column18 = DECODE( p_custom_column18, FND_API.g_miss_char, custom_column18, p_custom_column18),
custom_column19 = DECODE( p_custom_column19, FND_API.g_miss_char, custom_column19, p_custom_column19),
custom_column20 = DECODE( p_custom_column20, FND_API.g_miss_char, custom_column20, p_custom_column20),
custom_column21 = DECODE( p_custom_column21, FND_API.g_miss_char, custom_column21, p_custom_column21),
custom_column22 = DECODE( p_custom_column22, FND_API.g_miss_char, custom_column22, p_custom_column22),
custom_column23 = DECODE( p_custom_column23, FND_API.g_miss_char, custom_column23, p_custom_column23),
custom_column24 = DECODE( p_custom_column24, FND_API.g_miss_char, custom_column24, p_custom_column24),
custom_column25 = DECODE( p_custom_column25, FND_API.g_miss_char, custom_column25, p_custom_column25)


   WHERE IMPORT_SOURCE_LINE_ID = p_IMPORT_SOURCE_LINE_ID
   AND   object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
END Update_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createDeleteBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_IMPORT_SOURCE_LINE_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_IMP_SOURCE_LINES
    WHERE IMPORT_SOURCE_LINE_ID = p_IMPORT_SOURCE_LINE_ID;
   If (SQL%NOTFOUND) then
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;



----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createLockBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row(
          p_import_source_line_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_import_list_header_id    NUMBER,
          p_import_successful_flag    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_import_failure_reason    VARCHAR2,
          p_re_import_last_done_date    DATE,
          p_party_id    NUMBER,
          p_dedupe_key    VARCHAR2,
          p_col1    VARCHAR2,
          p_col2    VARCHAR2,
          p_col3    VARCHAR2,
          p_col4    VARCHAR2,
          p_col5    VARCHAR2,
          p_col6    VARCHAR2,
          p_col7    VARCHAR2,
          p_col8    VARCHAR2,
          p_col9    VARCHAR2,
          p_col10    VARCHAR2,
          p_col11    VARCHAR2,
          p_col12    VARCHAR2,
          p_col13    VARCHAR2,
          p_col14    VARCHAR2,
          p_col15    VARCHAR2,
          p_col16    VARCHAR2,
          p_col17    VARCHAR2,
          p_col18    VARCHAR2,
          p_col19    VARCHAR2,
          p_col20    VARCHAR2,
          p_col21    VARCHAR2,
          p_col22    VARCHAR2,
          p_col23    VARCHAR2,
          p_col24    VARCHAR2,
          p_col25    VARCHAR2,
          p_col26    VARCHAR2,
          p_col27    VARCHAR2,
          p_col28    VARCHAR2,
          p_col29    VARCHAR2,
          p_col30    VARCHAR2,
          p_col31    VARCHAR2,
          p_col32    VARCHAR2,
          p_col33    VARCHAR2,
          p_col34    VARCHAR2,
          p_col35    VARCHAR2,
          p_col36    VARCHAR2,
          p_col37    VARCHAR2,
          p_col38    VARCHAR2,
          p_col39    VARCHAR2,
          p_col40    VARCHAR2,
          p_col41    VARCHAR2,
          p_col42    VARCHAR2,
          p_col43    VARCHAR2,
          p_col44    VARCHAR2,
          p_col45    VARCHAR2,
          p_col46    VARCHAR2,
          p_col47    VARCHAR2,
          p_col48    VARCHAR2,
          p_col49    VARCHAR2,
          p_col50    VARCHAR2,
          p_col51    VARCHAR2,
          p_col52    VARCHAR2,
          p_col53    VARCHAR2,
          p_col54    VARCHAR2,
          p_col55    VARCHAR2,
          p_col56    VARCHAR2,
          p_col57    VARCHAR2,
          p_col58    VARCHAR2,
          p_col59    VARCHAR2,
          p_col60    VARCHAR2,
          p_col61    VARCHAR2,
          p_col62    VARCHAR2,
          p_col63    VARCHAR2,
          p_col64    VARCHAR2,
          p_col65    VARCHAR2,
          p_col66    VARCHAR2,
          p_col67    VARCHAR2,
          p_col68    VARCHAR2,
          p_col69    VARCHAR2,
          p_col70    VARCHAR2,
          p_col71    VARCHAR2,
          p_col72    VARCHAR2,
          p_col73    VARCHAR2,
          p_col74    VARCHAR2,
          p_col75    VARCHAR2,
          p_col76    VARCHAR2,
          p_col77    VARCHAR2,
          p_col78    VARCHAR2,
          p_col79    VARCHAR2,
          p_col80    VARCHAR2,
          p_col81    VARCHAR2,
          p_col82    VARCHAR2,
          p_col83    VARCHAR2,
          p_col84    VARCHAR2,
          p_col85    VARCHAR2,
          p_col86    VARCHAR2,
          p_col87    VARCHAR2,
          p_col88    VARCHAR2,
          p_col89    VARCHAR2,
          p_col90    VARCHAR2,
          p_col91    VARCHAR2,
          p_col92    VARCHAR2,
          p_col93    VARCHAR2,
          p_col94    VARCHAR2,
          p_col95    VARCHAR2,
          p_col96    VARCHAR2,
          p_col97    VARCHAR2,
          p_col98    VARCHAR2,
          p_col99    VARCHAR2,
          p_col100    VARCHAR2,
          p_col101    VARCHAR2,
          p_col102    VARCHAR2,
          p_col103    VARCHAR2,
          p_col104    VARCHAR2,
          p_col105    VARCHAR2,
          p_col106    VARCHAR2,
          p_col107    VARCHAR2,
          p_col108    VARCHAR2,
          p_col109    VARCHAR2,
          p_col110    VARCHAR2,
          p_col111    VARCHAR2,
          p_col112    VARCHAR2,
          p_col113    VARCHAR2,
          p_col114    VARCHAR2,
          p_col115    VARCHAR2,
          p_col116    VARCHAR2,
          p_col117    VARCHAR2,
          p_col118    VARCHAR2,
          p_col119    VARCHAR2,
          p_col120    VARCHAR2,
          p_col121    VARCHAR2,
          p_col122    VARCHAR2,
          p_col123    VARCHAR2,
          p_col124    VARCHAR2,
          p_col125    VARCHAR2,
          p_col126    VARCHAR2,
          p_col127    VARCHAR2,
          p_col128    VARCHAR2,
          p_col129    VARCHAR2,
          p_col130    VARCHAR2,
          p_col131    VARCHAR2,
          p_col132    VARCHAR2,
          p_col133    VARCHAR2,
          p_col134    VARCHAR2,
          p_col135    VARCHAR2,
          p_col136    VARCHAR2,
          p_col137    VARCHAR2,
          p_col138    VARCHAR2,
          p_col139    VARCHAR2,
          p_col140    VARCHAR2,
          p_col141    VARCHAR2,
          p_col142    VARCHAR2,
          p_col143    VARCHAR2,
          p_col144    VARCHAR2,
          p_col145    VARCHAR2,
          p_col146    VARCHAR2,
          p_col147    VARCHAR2,
          p_col148    VARCHAR2,
          p_col149    VARCHAR2,
          p_col150    VARCHAR2,
          p_col151    VARCHAR2,
          p_col152    VARCHAR2,
          p_col153    VARCHAR2,
          p_col154    VARCHAR2,
          p_col155    VARCHAR2,
          p_col156    VARCHAR2,
          p_col157    VARCHAR2,
          p_col158    VARCHAR2,
          p_col159    VARCHAR2,
          p_col160    VARCHAR2,
          p_col161    VARCHAR2,
          p_col162    VARCHAR2,
          p_col163    VARCHAR2,
          p_col164    VARCHAR2,
          p_col165    VARCHAR2,
          p_col166    VARCHAR2,
          p_col167    VARCHAR2,
          p_col168    VARCHAR2,
          p_col169    VARCHAR2,
          p_col170    VARCHAR2,
          p_col171    VARCHAR2,
          p_col172    VARCHAR2,
          p_col173    VARCHAR2,
          p_col174    VARCHAR2,
          p_col175    VARCHAR2,
          p_col176    VARCHAR2,
          p_col177    VARCHAR2,
          p_col178    VARCHAR2,
          p_col179    VARCHAR2,
          p_col180    VARCHAR2,
          p_col181    VARCHAR2,
          p_col182    VARCHAR2,
          p_col183    VARCHAR2,
          p_col184    VARCHAR2,
          p_col185    VARCHAR2,
          p_col186    VARCHAR2,
          p_col187    VARCHAR2,
          p_col188    VARCHAR2,
          p_col189    VARCHAR2,
          p_col190    VARCHAR2,
          p_col191    VARCHAR2,
          p_col192    VARCHAR2,
          p_col193    VARCHAR2,
          p_col194    VARCHAR2,
          p_col195    VARCHAR2,
          p_col196    VARCHAR2,
          p_col197    VARCHAR2,
          p_col198    VARCHAR2,
          p_col199    VARCHAR2,
          p_col200    VARCHAR2,
          p_col201    VARCHAR2,
          p_col202    VARCHAR2,
          p_col203    VARCHAR2,
          p_col204    VARCHAR2,
          p_col205    VARCHAR2,
          p_col206    VARCHAR2,
          p_col207    VARCHAR2,
          p_col208    VARCHAR2,
          p_col209    VARCHAR2,
          p_col210    VARCHAR2,
          p_col211    VARCHAR2,
          p_col212    VARCHAR2,
          p_col213    VARCHAR2,
          p_col214    VARCHAR2,
          p_col215    VARCHAR2,
          p_col216    VARCHAR2,
          p_col217    VARCHAR2,
          p_col218    VARCHAR2,
          p_col219    VARCHAR2,
          p_col220    VARCHAR2,
          p_col221    VARCHAR2,
          p_col222    VARCHAR2,
          p_col223    VARCHAR2,
          p_col224    VARCHAR2,
          p_col225    VARCHAR2,
          p_col226    VARCHAR2,
          p_col227    VARCHAR2,
          p_col228    VARCHAR2,
          p_col229    VARCHAR2,
          p_col230    VARCHAR2,
          p_col231    VARCHAR2,
          p_col232    VARCHAR2,
          p_col233    VARCHAR2,
          p_col234    VARCHAR2,
          p_col235    VARCHAR2,
          p_col236    VARCHAR2,
          p_col237    VARCHAR2,
          p_col238    VARCHAR2,
          p_col239    VARCHAR2,
          p_col240    VARCHAR2,
          p_col241    VARCHAR2,
          p_col242    VARCHAR2,
          p_col243    VARCHAR2,
          p_col244    VARCHAR2,
          p_col245    VARCHAR2,
          p_col246    VARCHAR2,
          p_col247    VARCHAR2,
          p_col248    VARCHAR2,
          p_col249    VARCHAR2,
          p_col250    VARCHAR2,
          p_duplicate_flag    VARCHAR2,
          p_current_usage    NUMBER,
  	  p_notes     VARCHAR2,
	  p_sales_agent_email_address VARCHAR2,
	  p_vehicle_response_code VARCHAR2,
p_custom_column1 VARCHAR2,
p_custom_column2 VARCHAR2,
p_custom_column3 VARCHAR2,
p_custom_column4 VARCHAR2,
p_custom_column5 VARCHAR2,
p_custom_column6 VARCHAR2,
p_custom_column7 VARCHAR2,
p_custom_column8 VARCHAR2,
p_custom_column9 VARCHAR2,
p_custom_column10 VARCHAR2,
p_custom_column11 VARCHAR2,
p_custom_column12 VARCHAR2,
p_custom_column13 VARCHAR2,
p_custom_column14 VARCHAR2,
p_custom_column15 VARCHAR2,
p_custom_column16 VARCHAR2,
p_custom_column17 VARCHAR2,
p_custom_column18 VARCHAR2,
p_custom_column19 VARCHAR2,
p_custom_column20 VARCHAR2,
p_custom_column21 VARCHAR2,
p_custom_column22 VARCHAR2,
p_custom_column23 VARCHAR2,
p_custom_column24 VARCHAR2,
p_custom_column25 VARCHAR2


      )


 IS
   CURSOR C IS
        SELECT *
         FROM AMS_IMP_SOURCE_LINES
        WHERE IMPORT_SOURCE_LINE_ID =  p_IMPORT_SOURCE_LINE_ID
        FOR UPDATE of IMPORT_SOURCE_LINE_ID NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN c;
    FETCH c INTO Recinfo;
    If (c%NOTFOUND) then
        CLOSE c;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;
    IF (
           (      Recinfo.import_source_line_id = p_import_source_line_id)
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       AND (    ( Recinfo.last_update_date = p_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.import_list_header_id = p_import_list_header_id)
            OR (    ( Recinfo.import_list_header_id IS NULL )
                AND (  p_import_list_header_id IS NULL )))
       AND (    ( Recinfo.import_successful_flag = p_import_successful_flag)
            OR (    ( Recinfo.import_successful_flag IS NULL )
                AND (  p_import_successful_flag IS NULL )))
       AND (    ( Recinfo.enabled_flag = p_enabled_flag)
            OR (    ( Recinfo.enabled_flag IS NULL )
                AND (  p_enabled_flag IS NULL )))
       AND (    ( Recinfo.import_failure_reason = p_import_failure_reason)
            OR (    ( Recinfo.import_failure_reason IS NULL )
                AND (  p_import_failure_reason IS NULL )))
       AND (    ( Recinfo.re_import_last_done_date = p_re_import_last_done_date)
            OR (    ( Recinfo.re_import_last_done_date IS NULL )
                AND (  p_re_import_last_done_date IS NULL )))
       AND (    ( Recinfo.party_id = p_party_id)
            OR (    ( Recinfo.party_id IS NULL )
                AND (  p_party_id IS NULL )))
       AND (    ( Recinfo.dedupe_key = p_dedupe_key)
            OR (    ( Recinfo.dedupe_key IS NULL )
                AND (  p_dedupe_key IS NULL )))
       AND (    ( Recinfo.col1 = p_col1)
            OR (    ( Recinfo.col1 IS NULL )
                AND (  p_col1 IS NULL )))
       AND (    ( Recinfo.col2 = p_col2)
            OR (    ( Recinfo.col2 IS NULL )
                AND (  p_col2 IS NULL )))
       AND (    ( Recinfo.col3 = p_col3)
            OR (    ( Recinfo.col3 IS NULL )
                AND (  p_col3 IS NULL )))
       AND (    ( Recinfo.col4 = p_col4)
            OR (    ( Recinfo.col4 IS NULL )
                AND (  p_col4 IS NULL )))
       AND (    ( Recinfo.col5 = p_col5)
            OR (    ( Recinfo.col5 IS NULL )
                AND (  p_col5 IS NULL )))
       AND (    ( Recinfo.col6 = p_col6)
            OR (    ( Recinfo.col6 IS NULL )
                AND (  p_col6 IS NULL )))
       AND (    ( Recinfo.col7 = p_col7)
            OR (    ( Recinfo.col7 IS NULL )
                AND (  p_col7 IS NULL )))
       AND (    ( Recinfo.col8 = p_col8)
            OR (    ( Recinfo.col8 IS NULL )
                AND (  p_col8 IS NULL )))
       AND (    ( Recinfo.col9 = p_col9)
            OR (    ( Recinfo.col9 IS NULL )
                AND (  p_col9 IS NULL )))
       AND (    ( Recinfo.col10 = p_col10)
            OR (    ( Recinfo.col10 IS NULL )
                AND (  p_col10 IS NULL )))
       AND (    ( Recinfo.col11 = p_col11)
            OR (    ( Recinfo.col11 IS NULL )
                AND (  p_col11 IS NULL )))
       AND (    ( Recinfo.col12 = p_col12)
            OR (    ( Recinfo.col12 IS NULL )
                AND (  p_col12 IS NULL )))
       AND (    ( Recinfo.col13 = p_col13)
            OR (    ( Recinfo.col13 IS NULL )
                AND (  p_col13 IS NULL )))
       AND (    ( Recinfo.col14 = p_col14)
            OR (    ( Recinfo.col14 IS NULL )
                AND (  p_col14 IS NULL )))
       AND (    ( Recinfo.col15 = p_col15)
            OR (    ( Recinfo.col15 IS NULL )
                AND (  p_col15 IS NULL )))
       AND (    ( Recinfo.col16 = p_col16)
            OR (    ( Recinfo.col16 IS NULL )
                AND (  p_col16 IS NULL )))
       AND (    ( Recinfo.col17 = p_col17)
            OR (    ( Recinfo.col17 IS NULL )
                AND (  p_col17 IS NULL )))
       AND (    ( Recinfo.col18 = p_col18)
            OR (    ( Recinfo.col18 IS NULL )
                AND (  p_col18 IS NULL )))
       AND (    ( Recinfo.col19 = p_col19)
            OR (    ( Recinfo.col19 IS NULL )
                AND (  p_col19 IS NULL )))
       AND (    ( Recinfo.col20 = p_col20)
            OR (    ( Recinfo.col20 IS NULL )
                AND (  p_col20 IS NULL )))
       AND (    ( Recinfo.col21 = p_col21)
            OR (    ( Recinfo.col21 IS NULL )
                AND (  p_col21 IS NULL )))
       AND (    ( Recinfo.col22 = p_col22)
            OR (    ( Recinfo.col22 IS NULL )
                AND (  p_col22 IS NULL )))
       AND (    ( Recinfo.col23 = p_col23)
            OR (    ( Recinfo.col23 IS NULL )
                AND (  p_col23 IS NULL )))
       AND (    ( Recinfo.col24 = p_col24)
            OR (    ( Recinfo.col24 IS NULL )
                AND (  p_col24 IS NULL )))
       AND (    ( Recinfo.col25 = p_col25)
            OR (    ( Recinfo.col25 IS NULL )
                AND (  p_col25 IS NULL )))
       AND (    ( Recinfo.col26 = p_col26)
            OR (    ( Recinfo.col26 IS NULL )
                AND (  p_col26 IS NULL )))
       AND (    ( Recinfo.col27 = p_col27)
            OR (    ( Recinfo.col27 IS NULL )
                AND (  p_col27 IS NULL )))
       AND (    ( Recinfo.col28 = p_col28)
            OR (    ( Recinfo.col28 IS NULL )
                AND (  p_col28 IS NULL )))
       AND (    ( Recinfo.col29 = p_col29)
            OR (    ( Recinfo.col29 IS NULL )
                AND (  p_col29 IS NULL )))
       AND (    ( Recinfo.col30 = p_col30)
            OR (    ( Recinfo.col30 IS NULL )
                AND (  p_col30 IS NULL )))
       AND (    ( Recinfo.col31 = p_col31)
            OR (    ( Recinfo.col31 IS NULL )
                AND (  p_col31 IS NULL )))
       AND (    ( Recinfo.col32 = p_col32)
            OR (    ( Recinfo.col32 IS NULL )
                AND (  p_col32 IS NULL )))
       AND (    ( Recinfo.col33 = p_col33)
            OR (    ( Recinfo.col33 IS NULL )
                AND (  p_col33 IS NULL )))
       AND (    ( Recinfo.col34 = p_col34)
            OR (    ( Recinfo.col34 IS NULL )
                AND (  p_col34 IS NULL )))
       AND (    ( Recinfo.col35 = p_col35)
            OR (    ( Recinfo.col35 IS NULL )
                AND (  p_col35 IS NULL )))
       AND (    ( Recinfo.col36 = p_col36)
            OR (    ( Recinfo.col36 IS NULL )
                AND (  p_col36 IS NULL )))
       AND (    ( Recinfo.col37 = p_col37)
            OR (    ( Recinfo.col37 IS NULL )
                AND (  p_col37 IS NULL )))
       AND (    ( Recinfo.col38 = p_col38)
            OR (    ( Recinfo.col38 IS NULL )
                AND (  p_col38 IS NULL )))
       AND (    ( Recinfo.col39 = p_col39)
            OR (    ( Recinfo.col39 IS NULL )
                AND (  p_col39 IS NULL )))
       AND (    ( Recinfo.col40 = p_col40)
            OR (    ( Recinfo.col40 IS NULL )
                AND (  p_col40 IS NULL )))
       AND (    ( Recinfo.col41 = p_col41)
            OR (    ( Recinfo.col41 IS NULL )
                AND (  p_col41 IS NULL )))
       AND (    ( Recinfo.col42 = p_col42)
            OR (    ( Recinfo.col42 IS NULL )
                AND (  p_col42 IS NULL )))
       AND (    ( Recinfo.col43 = p_col43)
            OR (    ( Recinfo.col43 IS NULL )
                AND (  p_col43 IS NULL )))
       AND (    ( Recinfo.col44 = p_col44)
            OR (    ( Recinfo.col44 IS NULL )
                AND (  p_col44 IS NULL )))
       AND (    ( Recinfo.col45 = p_col45)
            OR (    ( Recinfo.col45 IS NULL )
                AND (  p_col45 IS NULL )))
       AND (    ( Recinfo.col46 = p_col46)
            OR (    ( Recinfo.col46 IS NULL )
                AND (  p_col46 IS NULL )))
       AND (    ( Recinfo.col47 = p_col47)
            OR (    ( Recinfo.col47 IS NULL )
                AND (  p_col47 IS NULL )))
       AND (    ( Recinfo.col48 = p_col48)
            OR (    ( Recinfo.col48 IS NULL )
                AND (  p_col48 IS NULL )))
       AND (    ( Recinfo.col49 = p_col49)
            OR (    ( Recinfo.col49 IS NULL )
                AND (  p_col49 IS NULL )))
       AND (    ( Recinfo.col50 = p_col50)
            OR (    ( Recinfo.col50 IS NULL )
                AND (  p_col50 IS NULL )))
       AND (    ( Recinfo.col51 = p_col51)
            OR (    ( Recinfo.col51 IS NULL )
                AND (  p_col51 IS NULL )))
       AND (    ( Recinfo.col52 = p_col52)
            OR (    ( Recinfo.col52 IS NULL )
                AND (  p_col52 IS NULL )))
       AND (    ( Recinfo.col53 = p_col53)
            OR (    ( Recinfo.col53 IS NULL )
                AND (  p_col53 IS NULL )))
       AND (    ( Recinfo.col54 = p_col54)
            OR (    ( Recinfo.col54 IS NULL )
                AND (  p_col54 IS NULL )))
       AND (    ( Recinfo.col55 = p_col55)
            OR (    ( Recinfo.col55 IS NULL )
                AND (  p_col55 IS NULL )))
       AND (    ( Recinfo.col56 = p_col56)
            OR (    ( Recinfo.col56 IS NULL )
                AND (  p_col56 IS NULL )))
       AND (    ( Recinfo.col57 = p_col57)
            OR (    ( Recinfo.col57 IS NULL )
                AND (  p_col57 IS NULL )))
       AND (    ( Recinfo.col58 = p_col58)
            OR (    ( Recinfo.col58 IS NULL )
                AND (  p_col58 IS NULL )))
       AND (    ( Recinfo.col59 = p_col59)
            OR (    ( Recinfo.col59 IS NULL )
                AND (  p_col59 IS NULL )))
       AND (    ( Recinfo.col60 = p_col60)
            OR (    ( Recinfo.col60 IS NULL )
                AND (  p_col60 IS NULL )))
       AND (    ( Recinfo.col61 = p_col61)
            OR (    ( Recinfo.col61 IS NULL )
                AND (  p_col61 IS NULL )))
       AND (    ( Recinfo.col62 = p_col62)
            OR (    ( Recinfo.col62 IS NULL )
                AND (  p_col62 IS NULL )))
       AND (    ( Recinfo.col63 = p_col63)
            OR (    ( Recinfo.col63 IS NULL )
                AND (  p_col63 IS NULL )))
       AND (    ( Recinfo.col64 = p_col64)
            OR (    ( Recinfo.col64 IS NULL )
                AND (  p_col64 IS NULL )))
       AND (    ( Recinfo.col65 = p_col65)
            OR (    ( Recinfo.col65 IS NULL )
                AND (  p_col65 IS NULL )))
       AND (    ( Recinfo.col66 = p_col66)
            OR (    ( Recinfo.col66 IS NULL )
                AND (  p_col66 IS NULL )))
       AND (    ( Recinfo.col67 = p_col67)
            OR (    ( Recinfo.col67 IS NULL )
                AND (  p_col67 IS NULL )))
       AND (    ( Recinfo.col68 = p_col68)
            OR (    ( Recinfo.col68 IS NULL )
                AND (  p_col68 IS NULL )))
       AND (    ( Recinfo.col69 = p_col69)
            OR (    ( Recinfo.col69 IS NULL )
                AND (  p_col69 IS NULL )))
       AND (    ( Recinfo.col70 = p_col70)
            OR (    ( Recinfo.col70 IS NULL )
                AND (  p_col70 IS NULL )))
       AND (    ( Recinfo.col71 = p_col71)
            OR (    ( Recinfo.col71 IS NULL )
                AND (  p_col71 IS NULL )))
       AND (    ( Recinfo.col72 = p_col72)
            OR (    ( Recinfo.col72 IS NULL )
                AND (  p_col72 IS NULL )))
       AND (    ( Recinfo.col73 = p_col73)
            OR (    ( Recinfo.col73 IS NULL )
                AND (  p_col73 IS NULL )))
       AND (    ( Recinfo.col74 = p_col74)
            OR (    ( Recinfo.col74 IS NULL )
                AND (  p_col74 IS NULL )))
       AND (    ( Recinfo.col75 = p_col75)
            OR (    ( Recinfo.col75 IS NULL )
                AND (  p_col75 IS NULL )))
       AND (    ( Recinfo.col76 = p_col76)
            OR (    ( Recinfo.col76 IS NULL )
                AND (  p_col76 IS NULL )))
       AND (    ( Recinfo.col77 = p_col77)
            OR (    ( Recinfo.col77 IS NULL )
                AND (  p_col77 IS NULL )))
       AND (    ( Recinfo.col78 = p_col78)
            OR (    ( Recinfo.col78 IS NULL )
                AND (  p_col78 IS NULL )))
       AND (    ( Recinfo.col79 = p_col79)
            OR (    ( Recinfo.col79 IS NULL )
                AND (  p_col79 IS NULL )))
       AND (    ( Recinfo.col80 = p_col80)
            OR (    ( Recinfo.col80 IS NULL )
                AND (  p_col80 IS NULL )))
       AND (    ( Recinfo.col81 = p_col81)
            OR (    ( Recinfo.col81 IS NULL )
                AND (  p_col81 IS NULL )))
       AND (    ( Recinfo.col82 = p_col82)
            OR (    ( Recinfo.col82 IS NULL )
                AND (  p_col82 IS NULL )))
       AND (    ( Recinfo.col83 = p_col83)
            OR (    ( Recinfo.col83 IS NULL )
                AND (  p_col83 IS NULL )))
       AND (    ( Recinfo.col84 = p_col84)
            OR (    ( Recinfo.col84 IS NULL )
                AND (  p_col84 IS NULL )))
       AND (    ( Recinfo.col85 = p_col85)
            OR (    ( Recinfo.col85 IS NULL )
                AND (  p_col85 IS NULL )))
       AND (    ( Recinfo.col86 = p_col86)
            OR (    ( Recinfo.col86 IS NULL )
                AND (  p_col86 IS NULL )))
       AND (    ( Recinfo.col87 = p_col87)
            OR (    ( Recinfo.col87 IS NULL )
                AND (  p_col87 IS NULL )))
       AND (    ( Recinfo.col88 = p_col88)
            OR (    ( Recinfo.col88 IS NULL )
                AND (  p_col88 IS NULL )))
       AND (    ( Recinfo.col89 = p_col89)
            OR (    ( Recinfo.col89 IS NULL )
                AND (  p_col89 IS NULL )))
       AND (    ( Recinfo.col90 = p_col90)
            OR (    ( Recinfo.col90 IS NULL )
                AND (  p_col90 IS NULL )))
       AND (    ( Recinfo.col91 = p_col91)
            OR (    ( Recinfo.col91 IS NULL )
                AND (  p_col91 IS NULL )))
       AND (    ( Recinfo.col92 = p_col92)
            OR (    ( Recinfo.col92 IS NULL )
                AND (  p_col92 IS NULL )))
       AND (    ( Recinfo.col93 = p_col93)
            OR (    ( Recinfo.col93 IS NULL )
                AND (  p_col93 IS NULL )))
       AND (    ( Recinfo.col94 = p_col94)
            OR (    ( Recinfo.col94 IS NULL )
                AND (  p_col94 IS NULL )))
       AND (    ( Recinfo.col95 = p_col95)
            OR (    ( Recinfo.col95 IS NULL )
                AND (  p_col95 IS NULL )))
       AND (    ( Recinfo.col96 = p_col96)
            OR (    ( Recinfo.col96 IS NULL )
                AND (  p_col96 IS NULL )))
       AND (    ( Recinfo.col97 = p_col97)
            OR (    ( Recinfo.col97 IS NULL )
                AND (  p_col97 IS NULL )))
       AND (    ( Recinfo.col98 = p_col98)
            OR (    ( Recinfo.col98 IS NULL )
                AND (  p_col98 IS NULL )))
       AND (    ( Recinfo.col99 = p_col99)
            OR (    ( Recinfo.col99 IS NULL )
                AND (  p_col99 IS NULL )))
       AND (    ( Recinfo.col100 = p_col100)
            OR (    ( Recinfo.col100 IS NULL )
                AND (  p_col100 IS NULL )))
       AND (    ( Recinfo.col101 = p_col101)
            OR (    ( Recinfo.col101 IS NULL )
                AND (  p_col101 IS NULL )))
       AND (    ( Recinfo.col102 = p_col102)
            OR (    ( Recinfo.col102 IS NULL )
                AND (  p_col102 IS NULL )))
       AND (    ( Recinfo.col103 = p_col103)
            OR (    ( Recinfo.col103 IS NULL )
                AND (  p_col103 IS NULL )))
       AND (    ( Recinfo.col104 = p_col104)
            OR (    ( Recinfo.col104 IS NULL )
                AND (  p_col104 IS NULL )))
       AND (    ( Recinfo.col105 = p_col105)
            OR (    ( Recinfo.col105 IS NULL )
                AND (  p_col105 IS NULL )))
       AND (    ( Recinfo.col106 = p_col106)
            OR (    ( Recinfo.col106 IS NULL )
                AND (  p_col106 IS NULL )))
       AND (    ( Recinfo.col107 = p_col107)
            OR (    ( Recinfo.col107 IS NULL )
                AND (  p_col107 IS NULL )))
       AND (    ( Recinfo.col108 = p_col108)
            OR (    ( Recinfo.col108 IS NULL )
                AND (  p_col108 IS NULL )))
       AND (    ( Recinfo.col109 = p_col109)
            OR (    ( Recinfo.col109 IS NULL )
                AND (  p_col109 IS NULL )))
       AND (    ( Recinfo.col110 = p_col110)
            OR (    ( Recinfo.col110 IS NULL )
                AND (  p_col110 IS NULL )))
       AND (    ( Recinfo.col111 = p_col111)
            OR (    ( Recinfo.col111 IS NULL )
                AND (  p_col111 IS NULL )))
       AND (    ( Recinfo.col112 = p_col112)
            OR (    ( Recinfo.col112 IS NULL )
                AND (  p_col112 IS NULL )))
       AND (    ( Recinfo.col113 = p_col113)
            OR (    ( Recinfo.col113 IS NULL )
                AND (  p_col113 IS NULL )))
       AND (    ( Recinfo.col114 = p_col114)
            OR (    ( Recinfo.col114 IS NULL )
                AND (  p_col114 IS NULL )))
       AND (    ( Recinfo.col115 = p_col115)
            OR (    ( Recinfo.col115 IS NULL )
                AND (  p_col115 IS NULL )))
       AND (    ( Recinfo.col116 = p_col116)
            OR (    ( Recinfo.col116 IS NULL )
                AND (  p_col116 IS NULL )))
       AND (    ( Recinfo.col117 = p_col117)
            OR (    ( Recinfo.col117 IS NULL )
                AND (  p_col117 IS NULL )))
       AND (    ( Recinfo.col118 = p_col118)
            OR (    ( Recinfo.col118 IS NULL )
                AND (  p_col118 IS NULL )))
       AND (    ( Recinfo.col119 = p_col119)
            OR (    ( Recinfo.col119 IS NULL )
                AND (  p_col119 IS NULL )))
       AND (    ( Recinfo.col120 = p_col120)
            OR (    ( Recinfo.col120 IS NULL )
                AND (  p_col120 IS NULL )))
       AND (    ( Recinfo.col121 = p_col121)
            OR (    ( Recinfo.col121 IS NULL )
                AND (  p_col121 IS NULL )))
       AND (    ( Recinfo.col122 = p_col122)
            OR (    ( Recinfo.col122 IS NULL )
                AND (  p_col122 IS NULL )))
       AND (    ( Recinfo.col123 = p_col123)
            OR (    ( Recinfo.col123 IS NULL )
                AND (  p_col123 IS NULL )))
       AND (    ( Recinfo.col124 = p_col124)
            OR (    ( Recinfo.col124 IS NULL )
                AND (  p_col124 IS NULL )))
       AND (    ( Recinfo.col125 = p_col125)
            OR (    ( Recinfo.col125 IS NULL )
                AND (  p_col125 IS NULL )))
       AND (    ( Recinfo.col126 = p_col126)
            OR (    ( Recinfo.col126 IS NULL )
                AND (  p_col126 IS NULL )))
       AND (    ( Recinfo.col127 = p_col127)
            OR (    ( Recinfo.col127 IS NULL )
                AND (  p_col127 IS NULL )))
       AND (    ( Recinfo.col128 = p_col128)
            OR (    ( Recinfo.col128 IS NULL )
                AND (  p_col128 IS NULL )))
       AND (    ( Recinfo.col129 = p_col129)
            OR (    ( Recinfo.col129 IS NULL )
                AND (  p_col129 IS NULL )))
       AND (    ( Recinfo.col130 = p_col130)
            OR (    ( Recinfo.col130 IS NULL )
                AND (  p_col130 IS NULL )))
       AND (    ( Recinfo.col131 = p_col131)
            OR (    ( Recinfo.col131 IS NULL )
                AND (  p_col131 IS NULL )))
       AND (    ( Recinfo.col132 = p_col132)
            OR (    ( Recinfo.col132 IS NULL )
                AND (  p_col132 IS NULL )))
       AND (    ( Recinfo.col133 = p_col133)
            OR (    ( Recinfo.col133 IS NULL )
                AND (  p_col133 IS NULL )))
       AND (    ( Recinfo.col134 = p_col134)
            OR (    ( Recinfo.col134 IS NULL )
                AND (  p_col134 IS NULL )))
       AND (    ( Recinfo.col135 = p_col135)
            OR (    ( Recinfo.col135 IS NULL )
                AND (  p_col135 IS NULL )))
       AND (    ( Recinfo.col136 = p_col136)
            OR (    ( Recinfo.col136 IS NULL )
                AND (  p_col136 IS NULL )))
       AND (    ( Recinfo.col137 = p_col137)
            OR (    ( Recinfo.col137 IS NULL )
                AND (  p_col137 IS NULL )))
       AND (    ( Recinfo.col138 = p_col138)
            OR (    ( Recinfo.col138 IS NULL )
                AND (  p_col138 IS NULL )))
       AND (    ( Recinfo.col139 = p_col139)
            OR (    ( Recinfo.col139 IS NULL )
                AND (  p_col139 IS NULL )))
       AND (    ( Recinfo.col140 = p_col140)
            OR (    ( Recinfo.col140 IS NULL )
                AND (  p_col140 IS NULL )))
       AND (    ( Recinfo.col141 = p_col141)
            OR (    ( Recinfo.col141 IS NULL )
                AND (  p_col141 IS NULL )))
       AND (    ( Recinfo.col142 = p_col142)
            OR (    ( Recinfo.col142 IS NULL )
                AND (  p_col142 IS NULL )))
       AND (    ( Recinfo.col143 = p_col143)
            OR (    ( Recinfo.col143 IS NULL )
                AND (  p_col143 IS NULL )))
       AND (    ( Recinfo.col144 = p_col144)
            OR (    ( Recinfo.col144 IS NULL )
                AND (  p_col144 IS NULL )))
       AND (    ( Recinfo.col145 = p_col145)
            OR (    ( Recinfo.col145 IS NULL )
                AND (  p_col145 IS NULL )))
       AND (    ( Recinfo.col146 = p_col146)
            OR (    ( Recinfo.col146 IS NULL )
                AND (  p_col146 IS NULL )))
       AND (    ( Recinfo.col147 = p_col147)
            OR (    ( Recinfo.col147 IS NULL )
                AND (  p_col147 IS NULL )))
       AND (    ( Recinfo.col148 = p_col148)
            OR (    ( Recinfo.col148 IS NULL )
                AND (  p_col148 IS NULL )))
       AND (    ( Recinfo.col149 = p_col149)
            OR (    ( Recinfo.col149 IS NULL )
                AND (  p_col149 IS NULL )))
       AND (    ( Recinfo.col150 = p_col150)
            OR (    ( Recinfo.col150 IS NULL )
                AND (  p_col150 IS NULL )))
       AND (    ( Recinfo.col151 = p_col151)
            OR (    ( Recinfo.col151 IS NULL )
                AND (  p_col151 IS NULL )))
       AND (    ( Recinfo.col152 = p_col152)
            OR (    ( Recinfo.col152 IS NULL )
                AND (  p_col152 IS NULL )))
       AND (    ( Recinfo.col153 = p_col153)
            OR (    ( Recinfo.col153 IS NULL )
                AND (  p_col153 IS NULL )))
       AND (    ( Recinfo.col154 = p_col154)
            OR (    ( Recinfo.col154 IS NULL )
                AND (  p_col154 IS NULL )))
       AND (    ( Recinfo.col155 = p_col155)
            OR (    ( Recinfo.col155 IS NULL )
                AND (  p_col155 IS NULL )))
       AND (    ( Recinfo.col156 = p_col156)
            OR (    ( Recinfo.col156 IS NULL )
                AND (  p_col156 IS NULL )))
       AND (    ( Recinfo.col157 = p_col157)
            OR (    ( Recinfo.col157 IS NULL )
                AND (  p_col157 IS NULL )))
       AND (    ( Recinfo.col158 = p_col158)
            OR (    ( Recinfo.col158 IS NULL )
                AND (  p_col158 IS NULL )))
       AND (    ( Recinfo.col159 = p_col159)
            OR (    ( Recinfo.col159 IS NULL )
                AND (  p_col159 IS NULL )))
       AND (    ( Recinfo.col160 = p_col160)
            OR (    ( Recinfo.col160 IS NULL )
                AND (  p_col160 IS NULL )))
       AND (    ( Recinfo.col161 = p_col161)
            OR (    ( Recinfo.col161 IS NULL )
                AND (  p_col161 IS NULL )))
       AND (    ( Recinfo.col162 = p_col162)
            OR (    ( Recinfo.col162 IS NULL )
                AND (  p_col162 IS NULL )))
       AND (    ( Recinfo.col163 = p_col163)
            OR (    ( Recinfo.col163 IS NULL )
                AND (  p_col163 IS NULL )))
       AND (    ( Recinfo.col164 = p_col164)
            OR (    ( Recinfo.col164 IS NULL )
                AND (  p_col164 IS NULL )))
       AND (    ( Recinfo.col165 = p_col165)
            OR (    ( Recinfo.col165 IS NULL )
                AND (  p_col165 IS NULL )))
       AND (    ( Recinfo.col166 = p_col166)
            OR (    ( Recinfo.col166 IS NULL )
                AND (  p_col166 IS NULL )))
       AND (    ( Recinfo.col167 = p_col167)
            OR (    ( Recinfo.col167 IS NULL )
                AND (  p_col167 IS NULL )))
       AND (    ( Recinfo.col168 = p_col168)
            OR (    ( Recinfo.col168 IS NULL )
                AND (  p_col168 IS NULL )))
       AND (    ( Recinfo.col169 = p_col169)
            OR (    ( Recinfo.col169 IS NULL )
                AND (  p_col169 IS NULL )))
       AND (    ( Recinfo.col170 = p_col170)
            OR (    ( Recinfo.col170 IS NULL )
                AND (  p_col170 IS NULL )))
       AND (    ( Recinfo.col171 = p_col171)
            OR (    ( Recinfo.col171 IS NULL )
                AND (  p_col171 IS NULL )))
       AND (    ( Recinfo.col172 = p_col172)
            OR (    ( Recinfo.col172 IS NULL )
                AND (  p_col172 IS NULL )))
       AND (    ( Recinfo.col173 = p_col173)
            OR (    ( Recinfo.col173 IS NULL )
                AND (  p_col173 IS NULL )))
       AND (    ( Recinfo.col174 = p_col174)
            OR (    ( Recinfo.col174 IS NULL )
                AND (  p_col174 IS NULL )))
       AND (    ( Recinfo.col175 = p_col175)
            OR (    ( Recinfo.col175 IS NULL )
                AND (  p_col175 IS NULL )))
       AND (    ( Recinfo.col176 = p_col176)
            OR (    ( Recinfo.col176 IS NULL )
                AND (  p_col176 IS NULL )))
       AND (    ( Recinfo.col177 = p_col177)
            OR (    ( Recinfo.col177 IS NULL )
                AND (  p_col177 IS NULL )))
       AND (    ( Recinfo.col178 = p_col178)
            OR (    ( Recinfo.col178 IS NULL )
                AND (  p_col178 IS NULL )))
       AND (    ( Recinfo.col179 = p_col179)
            OR (    ( Recinfo.col179 IS NULL )
                AND (  p_col179 IS NULL )))
       AND (    ( Recinfo.col180 = p_col180)
            OR (    ( Recinfo.col180 IS NULL )
                AND (  p_col180 IS NULL )))
       AND (    ( Recinfo.col181 = p_col181)
            OR (    ( Recinfo.col181 IS NULL )
                AND (  p_col181 IS NULL )))
       AND (    ( Recinfo.col182 = p_col182)
            OR (    ( Recinfo.col182 IS NULL )
                AND (  p_col182 IS NULL )))
       AND (    ( Recinfo.col183 = p_col183)
            OR (    ( Recinfo.col183 IS NULL )
                AND (  p_col183 IS NULL )))
       AND (    ( Recinfo.col184 = p_col184)
            OR (    ( Recinfo.col184 IS NULL )
                AND (  p_col184 IS NULL )))
       AND (    ( Recinfo.col185 = p_col185)
            OR (    ( Recinfo.col185 IS NULL )
                AND (  p_col185 IS NULL )))
       AND (    ( Recinfo.col186 = p_col186)
            OR (    ( Recinfo.col186 IS NULL )
                AND (  p_col186 IS NULL )))
       AND (    ( Recinfo.col187 = p_col187)
            OR (    ( Recinfo.col187 IS NULL )
                AND (  p_col187 IS NULL )))
       AND (    ( Recinfo.col188 = p_col188)
            OR (    ( Recinfo.col188 IS NULL )
                AND (  p_col188 IS NULL )))
       AND (    ( Recinfo.col189 = p_col189)
            OR (    ( Recinfo.col189 IS NULL )
                AND (  p_col189 IS NULL )))
       AND (    ( Recinfo.col190 = p_col190)
            OR (    ( Recinfo.col190 IS NULL )
                AND (  p_col190 IS NULL )))
       AND (    ( Recinfo.col191 = p_col191)
            OR (    ( Recinfo.col191 IS NULL )
                AND (  p_col191 IS NULL )))
       AND (    ( Recinfo.col192 = p_col192)
            OR (    ( Recinfo.col192 IS NULL )
                AND (  p_col192 IS NULL )))
       AND (    ( Recinfo.col193 = p_col193)
            OR (    ( Recinfo.col193 IS NULL )
                AND (  p_col193 IS NULL )))
       AND (    ( Recinfo.col194 = p_col194)
            OR (    ( Recinfo.col194 IS NULL )
                AND (  p_col194 IS NULL )))
       AND (    ( Recinfo.col195 = p_col195)
            OR (    ( Recinfo.col195 IS NULL )
                AND (  p_col195 IS NULL )))
       AND (    ( Recinfo.col196 = p_col196)
            OR (    ( Recinfo.col196 IS NULL )
                AND (  p_col196 IS NULL )))
       AND (    ( Recinfo.col197 = p_col197)
            OR (    ( Recinfo.col197 IS NULL )
                AND (  p_col197 IS NULL )))
       AND (    ( Recinfo.col198 = p_col198)
            OR (    ( Recinfo.col198 IS NULL )
                AND (  p_col198 IS NULL )))
       AND (    ( Recinfo.col199 = p_col199)
            OR (    ( Recinfo.col199 IS NULL )
                AND (  p_col199 IS NULL )))
       AND (    ( Recinfo.col200 = p_col200)
            OR (    ( Recinfo.col200 IS NULL )
                AND (  p_col200 IS NULL )))
       AND (    ( Recinfo.col201 = p_col201)
            OR (    ( Recinfo.col201 IS NULL )
                AND (  p_col201 IS NULL )))
       AND (    ( Recinfo.col202 = p_col202)
            OR (    ( Recinfo.col202 IS NULL )
                AND (  p_col202 IS NULL )))
       AND (    ( Recinfo.col203 = p_col203)
            OR (    ( Recinfo.col203 IS NULL )
                AND (  p_col203 IS NULL )))
       AND (    ( Recinfo.col204 = p_col204)
            OR (    ( Recinfo.col204 IS NULL )
                AND (  p_col204 IS NULL )))
       AND (    ( Recinfo.col205 = p_col205)
            OR (    ( Recinfo.col205 IS NULL )
                AND (  p_col205 IS NULL )))
       AND (    ( Recinfo.col206 = p_col206)
            OR (    ( Recinfo.col206 IS NULL )
                AND (  p_col206 IS NULL )))
       AND (    ( Recinfo.col207 = p_col207)
            OR (    ( Recinfo.col207 IS NULL )
                AND (  p_col207 IS NULL )))
       AND (    ( Recinfo.col208 = p_col208)
            OR (    ( Recinfo.col208 IS NULL )
                AND (  p_col208 IS NULL )))
       AND (    ( Recinfo.col209 = p_col209)
            OR (    ( Recinfo.col209 IS NULL )
                AND (  p_col209 IS NULL )))
       AND (    ( Recinfo.col210 = p_col210)
            OR (    ( Recinfo.col210 IS NULL )
                AND (  p_col210 IS NULL )))
       AND (    ( Recinfo.col211 = p_col211)
            OR (    ( Recinfo.col211 IS NULL )
                AND (  p_col211 IS NULL )))
       AND (    ( Recinfo.col212 = p_col212)
            OR (    ( Recinfo.col212 IS NULL )
                AND (  p_col212 IS NULL )))
       AND (    ( Recinfo.col213 = p_col213)
            OR (    ( Recinfo.col213 IS NULL )
                AND (  p_col213 IS NULL )))
       AND (    ( Recinfo.col214 = p_col214)
            OR (    ( Recinfo.col214 IS NULL )
                AND (  p_col214 IS NULL )))
       AND (    ( Recinfo.col215 = p_col215)
            OR (    ( Recinfo.col215 IS NULL )
                AND (  p_col215 IS NULL )))
       AND (    ( Recinfo.col216 = p_col216)
            OR (    ( Recinfo.col216 IS NULL )
                AND (  p_col216 IS NULL )))
       AND (    ( Recinfo.col217 = p_col217)
            OR (    ( Recinfo.col217 IS NULL )
                AND (  p_col217 IS NULL )))
       AND (    ( Recinfo.col218 = p_col218)
            OR (    ( Recinfo.col218 IS NULL )
                AND (  p_col218 IS NULL )))
       AND (    ( Recinfo.col219 = p_col219)
            OR (    ( Recinfo.col219 IS NULL )
                AND (  p_col219 IS NULL )))
       AND (    ( Recinfo.col220 = p_col220)
            OR (    ( Recinfo.col220 IS NULL )
                AND (  p_col220 IS NULL )))
       AND (    ( Recinfo.col221 = p_col221)
            OR (    ( Recinfo.col221 IS NULL )
                AND (  p_col221 IS NULL )))
       AND (    ( Recinfo.col222 = p_col222)
            OR (    ( Recinfo.col222 IS NULL )
                AND (  p_col222 IS NULL )))
       AND (    ( Recinfo.col223 = p_col223)
            OR (    ( Recinfo.col223 IS NULL )
                AND (  p_col223 IS NULL )))
       AND (    ( Recinfo.col224 = p_col224)
            OR (    ( Recinfo.col224 IS NULL )
                AND (  p_col224 IS NULL )))
       AND (    ( Recinfo.col225 = p_col225)
            OR (    ( Recinfo.col225 IS NULL )
                AND (  p_col225 IS NULL )))
       AND (    ( Recinfo.col226 = p_col226)
            OR (    ( Recinfo.col226 IS NULL )
                AND (  p_col226 IS NULL )))
       AND (    ( Recinfo.col227 = p_col227)
            OR (    ( Recinfo.col227 IS NULL )
                AND (  p_col227 IS NULL )))
       AND (    ( Recinfo.col228 = p_col228)
            OR (    ( Recinfo.col228 IS NULL )
                AND (  p_col228 IS NULL )))
       AND (    ( Recinfo.col229 = p_col229)
            OR (    ( Recinfo.col229 IS NULL )
                AND (  p_col229 IS NULL )))
       AND (    ( Recinfo.col230 = p_col230)
            OR (    ( Recinfo.col230 IS NULL )
                AND (  p_col230 IS NULL )))
       AND (    ( Recinfo.col231 = p_col231)
            OR (    ( Recinfo.col231 IS NULL )
                AND (  p_col231 IS NULL )))
       AND (    ( Recinfo.col232 = p_col232)
            OR (    ( Recinfo.col232 IS NULL )
                AND (  p_col232 IS NULL )))
       AND (    ( Recinfo.col233 = p_col233)
            OR (    ( Recinfo.col233 IS NULL )
                AND (  p_col233 IS NULL )))
       AND (    ( Recinfo.col234 = p_col234)
            OR (    ( Recinfo.col234 IS NULL )
                AND (  p_col234 IS NULL )))
       AND (    ( Recinfo.col235 = p_col235)
            OR (    ( Recinfo.col235 IS NULL )
                AND (  p_col235 IS NULL )))
       AND (    ( Recinfo.col236 = p_col236)
            OR (    ( Recinfo.col236 IS NULL )
                AND (  p_col236 IS NULL )))
       AND (    ( Recinfo.col237 = p_col237)
            OR (    ( Recinfo.col237 IS NULL )
                AND (  p_col237 IS NULL )))
       AND (    ( Recinfo.col238 = p_col238)
            OR (    ( Recinfo.col238 IS NULL )
                AND (  p_col238 IS NULL )))
       AND (    ( Recinfo.col239 = p_col239)
            OR (    ( Recinfo.col239 IS NULL )
                AND (  p_col239 IS NULL )))
       AND (    ( Recinfo.col240 = p_col240)
            OR (    ( Recinfo.col240 IS NULL )
                AND (  p_col240 IS NULL )))
       AND (    ( Recinfo.col241 = p_col241)
            OR (    ( Recinfo.col241 IS NULL )
                AND (  p_col241 IS NULL )))
       AND (    ( Recinfo.col242 = p_col242)
            OR (    ( Recinfo.col242 IS NULL )
                AND (  p_col242 IS NULL )))
       AND (    ( Recinfo.col243 = p_col243)
            OR (    ( Recinfo.col243 IS NULL )
                AND (  p_col243 IS NULL )))
       AND (    ( Recinfo.col244 = p_col244)
            OR (    ( Recinfo.col244 IS NULL )
                AND (  p_col244 IS NULL )))
       AND (    ( Recinfo.col245 = p_col245)
            OR (    ( Recinfo.col245 IS NULL )
                AND (  p_col245 IS NULL )))
       AND (    ( Recinfo.col246 = p_col246)
            OR (    ( Recinfo.col246 IS NULL )
                AND (  p_col246 IS NULL )))
       AND (    ( Recinfo.col247 = p_col247)
            OR (    ( Recinfo.col247 IS NULL )
                AND (  p_col247 IS NULL )))
       AND (    ( Recinfo.col248 = p_col248)
            OR (    ( Recinfo.col248 IS NULL )
                AND (  p_col248 IS NULL )))
       AND (    ( Recinfo.col249 = p_col249)
            OR (    ( Recinfo.col249 IS NULL )
                AND (  p_col249 IS NULL )))
       AND (    ( Recinfo.col250 = p_col250)
            OR (    ( Recinfo.col250 IS NULL )
                AND (  p_col250 IS NULL )))
       AND (    ( Recinfo.duplicate_flag = p_duplicate_flag)
            OR (    ( Recinfo.duplicate_flag IS NULL )
                AND (  p_duplicate_flag IS NULL )))
       AND (    ( Recinfo.current_usage = p_current_usage)
            OR (    ( Recinfo.current_usage IS NULL )
                AND (  p_current_usage IS NULL )))
       AND (    ( Recinfo.notes = p_notes)
            OR (    ( Recinfo.notes IS NULL )
                AND (  p_notes IS NULL )))
       AND (    ( Recinfo.sales_agent_email_address = p_sales_agent_email_address)
            OR (    ( Recinfo.sales_agent_email_address IS NULL )
                AND (  p_sales_agent_email_address IS NULL )))
       AND (    ( Recinfo.vehicle_response_code = p_vehicle_response_code)
            OR (    ( Recinfo.vehicle_response_code IS NULL )
                AND (  p_vehicle_response_code IS NULL )))



       AND (    ( Recinfo.custom_column1 = p_custom_column1)
            OR (    ( Recinfo.custom_column1 IS NULL )
                AND (  p_custom_column1 IS NULL )))
       AND (    ( Recinfo.custom_column2 = p_custom_column2)
            OR (    ( Recinfo.custom_column2 IS NULL )
                AND (  p_custom_column2 IS NULL )))
       AND (    ( Recinfo.custom_column3 = p_custom_column3)
            OR (    ( Recinfo.custom_column3 IS NULL )
                AND (  p_custom_column3 IS NULL )))
       AND (    ( Recinfo.custom_column4 = p_custom_column4)
            OR (    ( Recinfo.custom_column4 IS NULL )
                AND (  p_custom_column4 IS NULL )))
       AND (    ( Recinfo.custom_column5 = p_custom_column5)
            OR (    ( Recinfo.custom_column5 IS NULL )
                AND (  p_custom_column5 IS NULL )))
       AND (    ( Recinfo.custom_column6 = p_custom_column6)
            OR (    ( Recinfo.custom_column6 IS NULL )
                AND (  p_custom_column6 IS NULL )))
       AND (    ( Recinfo.custom_column7 = p_custom_column7)
            OR (    ( Recinfo.custom_column7 IS NULL )
                AND (  p_custom_column7 IS NULL )))
       AND (    ( Recinfo.custom_column8 = p_custom_column8)
            OR (    ( Recinfo.custom_column8 IS NULL )
                AND (  p_custom_column8 IS NULL )))
       AND (    ( Recinfo.custom_column9 = p_custom_column9)
            OR (    ( Recinfo.custom_column9 IS NULL )
                AND (  p_custom_column9 IS NULL )))
       AND (    ( Recinfo.custom_column10 = p_custom_column10)
            OR (    ( Recinfo.custom_column10 IS NULL )
                AND (  p_custom_column10 IS NULL )))
       AND (    ( Recinfo.custom_column11 = p_custom_column11)
            OR (    ( Recinfo.custom_column11 IS NULL )
                AND (  p_custom_column11 IS NULL )))
       AND (    ( Recinfo.custom_column12 = p_custom_column12)
            OR (    ( Recinfo.custom_column12 IS NULL )
                AND (  p_custom_column12 IS NULL )))
       AND (    ( Recinfo.custom_column13 = p_custom_column13)
            OR (    ( Recinfo.custom_column13 IS NULL )
                AND (  p_custom_column13 IS NULL )))
       AND (    ( Recinfo.custom_column14 = p_custom_column14)
            OR (    ( Recinfo.custom_column14 IS NULL )
                AND (  p_custom_column14 IS NULL )))
       AND (    ( Recinfo.custom_column15 = p_custom_column15)
            OR (    ( Recinfo.custom_column15 IS NULL )
                AND (  p_custom_column15 IS NULL )))
       AND (    ( Recinfo.custom_column16 = p_custom_column16)
            OR (    ( Recinfo.custom_column16 IS NULL )
                AND (  p_custom_column16 IS NULL )))
       AND (    ( Recinfo.custom_column17 = p_custom_column17)
            OR (    ( Recinfo.custom_column17 IS NULL )
                AND (  p_custom_column17 IS NULL )))
       AND (    ( Recinfo.custom_column18 = p_custom_column18)
            OR (    ( Recinfo.custom_column18 IS NULL )
                AND (  p_custom_column18 IS NULL )))
       AND (    ( Recinfo.custom_column19 = p_custom_column19)
            OR (    ( Recinfo.custom_column19 IS NULL )
                AND (  p_custom_column19 IS NULL )))
       AND (    ( Recinfo.custom_column20 = p_custom_column20)
            OR (    ( Recinfo.custom_column20 IS NULL )
                AND (  p_custom_column20 IS NULL )))
       AND (    ( Recinfo.custom_column21 = p_custom_column21)
            OR (    ( Recinfo.custom_column21 IS NULL )
                AND (  p_custom_column21 IS NULL )))
       AND (    ( Recinfo.custom_column22 = p_custom_column22)
            OR (    ( Recinfo.custom_column22 IS NULL )
                AND (  p_custom_column22 IS NULL )))
       AND (    ( Recinfo.custom_column23 = p_custom_column23)
            OR (    ( Recinfo.custom_column23 IS NULL )
                AND (  p_custom_column23 IS NULL )))
       AND (    ( Recinfo.custom_column24 = p_custom_column24)
            OR (    ( Recinfo.custom_column24 IS NULL )
                AND (  p_custom_column24 IS NULL )))
       AND (    ( Recinfo.custom_column25 = p_custom_column25)
            OR (    ( Recinfo.custom_column25 IS NULL )
                AND (  p_custom_column25 IS NULL )))



       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END AMS_IMP_SOURCE_LINES_PKG;

/
