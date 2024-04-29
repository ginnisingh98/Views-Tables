--------------------------------------------------------
--  DDL for Package Body AMS_LIST_ENTRIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_ENTRIES_PVT" as
/* $Header: amsvlieb.pls 120.0.12010000.2 2008/08/11 09:02:30 amlal ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_List_Entries_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_List_Entries_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvlieb.pls';


AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Complete_list_entries_Rec (
    P_list_entries_rec     IN    list_entries_rec_type,
     x_complete_rec        OUT NOCOPY    list_entries_rec_type
    )
IS
   CURSOR c_listentries IS
   select
       list_entry_id                   ,
       list_header_id                  ,
       last_update_date                ,
       last_updated_by                 ,
       creation_date                   ,
       created_by                      ,
       last_update_login               ,
       object_version_number           ,
       list_select_action_id           ,
       arc_list_select_action_from     ,
       list_select_action_from_name    ,
       source_code                     ,
       arc_list_used_by_source         ,
       source_code_for_id              ,
       pin_code                        ,
       list_entry_source_system_id     ,
       list_entry_source_system_type   ,
       view_application_id             ,
       manually_entered_flag           ,
       marked_as_duplicate_flag        ,
       marked_as_random_flag           ,
       part_of_control_group_flag      ,
       exclude_in_triggered_list_flag  ,
       enabled_flag                    ,
       cell_code                       ,
       dedupe_key                      ,
       randomly_generated_number       ,
       campaign_id                     ,
       media_id                        ,
       channel_id                      ,
       channel_schedule_id             ,
       event_offer_id                  ,
       customer_id                     ,
       market_segment_id               ,
       vendor_id                       ,
       transfer_flag                   ,
       transfer_status                 ,
       list_source                     ,
       duplicate_master_entry_id       ,
       marked_flag                     ,
       lead_id                         ,
       letter_id                       ,
       picking_header_id               ,
       batch_id                        ,
       suffix                          ,
       first_name                      ,
       last_name                       ,
       customer_name                   ,
       title                           ,
       address_line1                   ,
       address_line2                   ,
       city                            ,
       state                           ,
       zipcode                         ,
       country                         ,
       fax                             ,
       phone                           ,
       email_address                   ,
       col1                            ,
       col2                            ,
       col3                            ,
       col4                            ,
       col5                            ,
       col6                            ,
       col7                            ,
       col8                            ,
       col9                            ,
       col10                           ,
       col11                           ,
       col12                           ,
       col13                           ,
       col14                           ,
       col15                           ,
       col16                           ,
       col17                           ,
       col18                           ,
       col19                           ,
       col20                           ,
       col21                           ,
       col22                           ,
       col23                           ,
       col24                           ,
       col25                           ,
       col26                           ,
       col27                           ,
       col28                           ,
       col29                           ,
       col30                           ,
       col31                           ,
       col32                           ,
       col33                           ,
       col34                           ,
       col35                           ,
       col36                           ,
       col37                           ,
       col38                           ,
       col39                           ,
       col40                           ,
       col41                           ,
       col42                           ,
       col43                           ,
       col44                           ,
       col45                           ,
       col46                           ,
       col47                           ,
       col48                           ,
       col49                           ,
       col50                           ,
       col51                           ,
       col52                           ,
       col53                           ,
       col54                           ,
       col55                           ,
       col56                           ,
       col57                           ,
       col58                           ,
       col59                           ,
       col60                           ,
       col61                           ,
       col62                           ,
       col63                           ,
       col64                           ,
       col65                           ,
       col66                           ,
       col67                           ,
       col68                           ,
       col69                           ,
       col70                           ,
       col71                           ,
       col72                           ,
       col73                           ,
       col74                           ,
       col75                           ,
       col76                           ,
       col77                           ,
       col78                           ,
       col79                           ,
       col80                           ,
       col81                           ,
       col82                           ,
       col83                           ,
       col84                           ,
       col85                           ,
       col86                           ,
       col87                           ,
       col88                           ,
       col89                           ,
       col90                           ,
       col91                           ,
       col92                           ,
       col93                           ,
       col94                           ,
       col95                           ,
       col96                           ,
       col97                           ,
       col98                           ,
       col99                           ,
       col100                          ,
       col101                          ,
       col102                          ,
       col103                          ,
       col104                          ,
       col105                          ,
       col106                          ,
       col107                          ,
       col108                          ,
       col109                          ,
       col110                          ,
       col111                          ,
       col112                          ,
       col113                          ,
       col114                          ,
       col115                          ,
       col116                          ,
       col117                          ,
       col118                          ,
       col119                          ,
       col120                          ,
       col121                          ,
       col122                          ,
       col123                          ,
       col124                          ,
       col125                          ,
       col126                          ,
       col127                          ,
       col128                          ,
       col129                          ,
       col130                          ,
       col131                          ,
       col132                          ,
       col133                          ,
       col134                          ,
       col135                          ,
       col136                          ,
       col137                          ,
       col138                          ,
       col139                          ,
       col140                          ,
       col141                          ,
       col142                          ,
       col143                          ,
       col144                          ,
       col145                          ,
       col146                          ,
       col147                          ,
       col148                          ,
       col149                          ,
       col150                          ,
       col151                          ,
       col152                          ,
       col153                          ,
       col154                          ,
       col155                          ,
       col156                          ,
       col157                          ,
       col158                          ,
       col159                          ,
       col160                          ,
       col161                          ,
       col162                          ,
       col163                          ,
       col164                          ,
       col165                          ,
       col166                          ,
       col167                          ,
       col168                          ,
       col169                          ,
       col170                          ,
       col171                          ,
       col172                          ,
       col173                          ,
       col174                          ,
       col175                          ,
       col176                          ,
       col177                          ,
       col178                          ,
       col179                          ,
       col180                          ,
       col181                          ,
       col182                          ,
       col183                          ,
       col184                          ,
       col185                          ,
       col186                          ,
       col187                          ,
       col188                          ,
       col189                          ,
       col190                          ,
       col191                          ,
       col192                          ,
       col193                          ,
       col194                          ,
       col195                          ,
       col196                          ,
       col197                          ,
       col198                          ,
       col199                          ,
       col200                          ,
       COL201                          ,
       COL202                          ,
       COL203                          ,
       COL204                          ,
       COL205                          ,
       COL206                          ,
       COL207                          ,
       COL208                          ,
       COL209                          ,
       COL210                          ,
       COL211                          ,
       COL212                          ,
       COL213                          ,
       COL214                          ,
       COL215                          ,
       COL216                          ,
       COL217                          ,
       COL218                          ,
       COL219                          ,
       COL220                          ,
       COL221                          ,
       COL222                          ,
       COL223                          ,
       COL224                          ,
       COL225                          ,
       COL226                          ,
       COL227                          ,
       COL228                          ,
       COL229                          ,
       COL230                          ,
       COL231                          ,
       COL232                          ,
       COL233                          ,
       COL234                          ,
       COL235                          ,
       COL236                          ,
       COL237                          ,
       COL238                          ,
       COL239                          ,
       COL240                          ,
       COL241                          ,
       COL242                          ,
       COL243                          ,
       COL244                          ,
       COL245                          ,
       COL246                          ,
       COL247                          ,
       COL248                          ,
       COL249                          ,
       COL250                          ,
       COL251                          ,
       COL252                          ,
       COL253                          ,
       COL254                          ,
       COL255                          ,
       COL256                          ,
       COL257                          ,
       COL258                          ,
       COL259                          ,
       COL260                          ,
       COL261                          ,
       COL262                          ,
       COL263                          ,
       COL264                          ,
       COL265                          ,
       COL266                          ,
       COL267                          ,
       COL268                          ,
       COL269                          ,
       COL270                          ,
       COL271                          ,
       COL272                          ,
       COL273                          ,
       COL274                          ,
       COL275                          ,
       COL276                          ,
       COL277                          ,
       COL278                          ,
       COL279                          ,
       COL280                          ,
       COL281                          ,
       COL282                          ,
       COL283                          ,
       COL284                          ,
       COL285                          ,
       COL286                          ,
       COL287                          ,
       COL288                          ,
       COL289                          ,
       COL290                          ,
       COL291                          ,
       COL292                          ,
       COL293                          ,
       COL294                          ,
       COL295                          ,
       COL296                          ,
       COL297                          ,
       COL298                          ,
       COL299                          ,
       COL300                          ,
       CURR_CP_COUNTRY_CODE            ,
       CURR_CP_PHONE_NUMBER            ,
       CURR_CP_RAW_PHONE_NUMBER        ,
       CURR_CP_AREA_CODE               ,
       CURR_CP_ID                      ,
       CURR_CP_INDEX                   ,
       CURR_CP_TIME_ZONE               ,
       CURR_CP_TIME_ZONE_AUX           ,
       party_id                        ,
       parent_party_id                 ,
       imp_source_line_id              ,
       usage_restriction               ,
       next_call_time                  ,
       callback_flag                   ,
       do_not_use_flag                 ,
       do_not_use_reason               ,
       record_out_flag                 ,
       record_release_time             ,
       group_code                      ,
       newly_updated_flag              ,
       outcome_id                ,
       result_id               ,
       reason_id                    ,
       notes ,
       VEHICLE_RESPONSE_CODE ,
       SALES_AGENT_EMAIL_ADDRESS ,
       RESOURCE_ID ,
       LOCATION_ID       ,
       CONTACT_POINT_ID  ,
       last_contacted_date
   FROM   ams_list_entries
   WHERE list_entry_id = p_list_entries_rec.list_entry_id;

   l_listentries_rec  list_entries_rec_type;

BEGIN

   x_complete_rec := p_list_entries_rec;
   OPEN c_listentries;
   FETCH c_listentries INTO l_listentries_rec;
   IF c_listentries%NOTFOUND THEN
      CLOSE c_listentries;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_listentries;
    IF p_list_entries_rec.LIST_ENTRY_ID = FND_API.g_miss_num THEN
       x_complete_rec.LIST_ENTRY_ID := l_listentries_rec.LIST_ENTRY_ID  ;
    END IF;
    IF p_list_entries_rec.LIST_HEADER_ID = FND_API.g_miss_num THEN
       x_complete_rec.LIST_HEADER_ID := l_listentries_rec.LIST_HEADER_ID  ;
    END IF;
    IF p_list_entries_rec.LAST_UPDATE_DATE = FND_API.g_miss_date THEN
       x_complete_rec.LAST_UPDATE_DATE := l_listentries_rec.LAST_UPDATE_DATE  ;
    END IF;
    IF p_list_entries_rec.LAST_UPDATED_BY = FND_API.g_miss_num THEN
       x_complete_rec.LAST_UPDATED_BY := l_listentries_rec.LAST_UPDATED_BY  ;
    END IF;
    IF p_list_entries_rec.CREATION_DATE = FND_API.g_miss_date THEN
       x_complete_rec.CREATION_DATE := l_listentries_rec.CREATION_DATE  ;
    END IF;
    IF p_list_entries_rec.CREATED_BY = FND_API.g_miss_num THEN
       x_complete_rec.CREATED_BY := l_listentries_rec.CREATED_BY  ;
    END IF;
    IF p_list_entries_rec.LAST_UPDATE_LOGIN = FND_API.g_miss_num THEN
       x_complete_rec.LAST_UPDATE_LOGIN := l_listentries_rec.LAST_UPDATE_LOGIN  ;
    END IF;
    IF p_list_entries_rec.OBJECT_VERSION_NUMBER = FND_API.g_miss_num THEN
       x_complete_rec.OBJECT_VERSION_NUMBER := l_listentries_rec.OBJECT_VERSION_NUMBER  ;
    END IF;
    IF p_list_entries_rec.LIST_SELECT_ACTION_ID = FND_API.g_miss_num THEN
       x_complete_rec.LIST_SELECT_ACTION_ID := l_listentries_rec.LIST_SELECT_ACTION_ID  ;
    END IF;
    IF p_list_entries_rec.ARC_LIST_SELECT_ACTION_FROM = FND_API.g_miss_char THEN
       x_complete_rec.ARC_LIST_SELECT_ACTION_FROM := l_listentries_rec.ARC_LIST_SELECT_ACTION_FROM  ;
    END IF;
    IF p_list_entries_rec.LIST_SELECT_ACTION_FROM_NAME = FND_API.g_miss_char THEN
       x_complete_rec.LIST_SELECT_ACTION_FROM_NAME := l_listentries_rec.LIST_SELECT_ACTION_FROM_NAME  ;
    END IF;
    IF p_list_entries_rec.SOURCE_CODE = FND_API.g_miss_char THEN
       x_complete_rec.SOURCE_CODE := l_listentries_rec.SOURCE_CODE  ;
    END IF;
    IF p_list_entries_rec.ARC_LIST_USED_BY_SOURCE = FND_API.g_miss_char THEN
       x_complete_rec.ARC_LIST_USED_BY_SOURCE := l_listentries_rec.ARC_LIST_USED_BY_SOURCE  ;
    END IF;
    IF p_list_entries_rec.SOURCE_CODE_FOR_ID = FND_API.g_miss_num THEN
       x_complete_rec.SOURCE_CODE_FOR_ID := l_listentries_rec.SOURCE_CODE_FOR_ID  ;
    END IF;
    IF p_list_entries_rec.PIN_CODE = FND_API.g_miss_char THEN
       x_complete_rec.PIN_CODE := l_listentries_rec.PIN_CODE  ;
    END IF;
    IF p_list_entries_rec.LIST_ENTRY_SOURCE_SYSTEM_ID = FND_API.g_miss_num THEN
       x_complete_rec.LIST_ENTRY_SOURCE_SYSTEM_ID := l_listentries_rec.LIST_ENTRY_SOURCE_SYSTEM_ID  ;
    END IF;
    IF p_list_entries_rec.LIST_ENTRY_SOURCE_SYSTEM_TYPE = FND_API.g_miss_char THEN
       x_complete_rec.LIST_ENTRY_SOURCE_SYSTEM_TYPE := l_listentries_rec.LIST_ENTRY_SOURCE_SYSTEM_TYPE  ;
    END IF;
    IF p_list_entries_rec.VIEW_APPLICATION_ID = FND_API.g_miss_num THEN
       x_complete_rec.VIEW_APPLICATION_ID := l_listentries_rec.VIEW_APPLICATION_ID  ;
    END IF;
    IF p_list_entries_rec.MANUALLY_ENTERED_FLAG = FND_API.g_miss_char THEN
       x_complete_rec.MANUALLY_ENTERED_FLAG := l_listentries_rec.MANUALLY_ENTERED_FLAG  ;
    END IF;
    IF p_list_entries_rec.MARKED_AS_DUPLICATE_FLAG = FND_API.g_miss_char THEN
       x_complete_rec.MARKED_AS_DUPLICATE_FLAG := l_listentries_rec.MARKED_AS_DUPLICATE_FLAG  ;
    END IF;
    IF p_list_entries_rec.MARKED_AS_RANDOM_FLAG = FND_API.g_miss_char THEN
       x_complete_rec.MARKED_AS_RANDOM_FLAG := l_listentries_rec.MARKED_AS_RANDOM_FLAG  ;
    END IF;
    IF p_list_entries_rec.EXCLUDE_IN_TRIGGERED_LIST_FLAG = FND_API.g_miss_char THEN
       x_complete_rec.EXCLUDE_IN_TRIGGERED_LIST_FLAG := l_listentries_rec.EXCLUDE_IN_TRIGGERED_LIST_FLAG  ;
    END IF;
    IF p_list_entries_rec.ENABLED_FLAG = FND_API.g_miss_char THEN
       x_complete_rec.ENABLED_FLAG := l_listentries_rec.ENABLED_FLAG  ;
    END IF;
    IF p_list_entries_rec.PART_OF_CONTROL_GROUP_FLAG = 'Y' THEN
       x_complete_rec.ENABLED_FLAG := 'N';
    END IF;
    IF p_list_entries_rec.PART_OF_CONTROL_GROUP_FLAG = FND_API.g_miss_char THEN
       x_complete_rec.PART_OF_CONTROL_GROUP_FLAG := l_listentries_rec.PART_OF_CONTROL_GROUP_FLAG  ;
    END IF;
    IF p_list_entries_rec.CELL_CODE = FND_API.g_miss_char THEN
       x_complete_rec.CELL_CODE := l_listentries_rec.CELL_CODE  ;
    END IF;
    IF p_list_entries_rec.DEDUPE_KEY = FND_API.g_miss_char THEN
       x_complete_rec.DEDUPE_KEY := l_listentries_rec.DEDUPE_KEY  ;
    END IF;
    IF p_list_entries_rec.RANDOMLY_GENERATED_NUMBER = FND_API.g_miss_num THEN
       x_complete_rec.RANDOMLY_GENERATED_NUMBER := l_listentries_rec.RANDOMLY_GENERATED_NUMBER  ;
    END IF;
    IF p_list_entries_rec.CAMPAIGN_ID = FND_API.g_miss_num THEN
       x_complete_rec.CAMPAIGN_ID := l_listentries_rec.CAMPAIGN_ID  ;
    END IF;
    IF p_list_entries_rec.MEDIA_ID = FND_API.g_miss_num THEN
       x_complete_rec.MEDIA_ID := l_listentries_rec.MEDIA_ID  ;
    END IF;
    IF p_list_entries_rec.CHANNEL_ID = FND_API.g_miss_num THEN
       x_complete_rec.CHANNEL_ID := l_listentries_rec.CHANNEL_ID  ;
    END IF;
    IF p_list_entries_rec.CHANNEL_SCHEDULE_ID = FND_API.g_miss_num THEN
       x_complete_rec.CHANNEL_SCHEDULE_ID := l_listentries_rec.CHANNEL_SCHEDULE_ID  ;
    END IF;
    IF p_list_entries_rec.EVENT_OFFER_ID = FND_API.g_miss_num THEN
       x_complete_rec.EVENT_OFFER_ID := l_listentries_rec.EVENT_OFFER_ID  ;
    END IF;
    IF p_list_entries_rec.CUSTOMER_ID = FND_API.g_miss_num THEN
       x_complete_rec.CUSTOMER_ID := l_listentries_rec.CUSTOMER_ID  ;
    END IF;
    IF p_list_entries_rec.MARKET_SEGMENT_ID = FND_API.g_miss_num THEN
       x_complete_rec.MARKET_SEGMENT_ID := l_listentries_rec.MARKET_SEGMENT_ID  ;
    END IF;
    IF p_list_entries_rec.PARTY_ID = FND_API.g_miss_num THEN
       x_complete_rec.PARTY_ID := l_listentries_rec.PARTY_ID  ;
    END IF;
    IF p_list_entries_rec.PARENT_PARTY_ID = FND_API.g_miss_num THEN
       x_complete_rec.PARENT_PARTY_ID := l_listentries_rec.PARENT_PARTY_ID  ;
    END IF;
    IF p_list_entries_rec.VENDOR_ID = FND_API.g_miss_num THEN
       x_complete_rec.VENDOR_ID := l_listentries_rec.VENDOR_ID  ;
    END IF;
    IF p_list_entries_rec.TRANSFER_FLAG = FND_API.g_miss_char THEN
       x_complete_rec.TRANSFER_FLAG := l_listentries_rec.TRANSFER_FLAG  ;
    END IF;
    IF p_list_entries_rec.TRANSFER_STATUS = FND_API.g_miss_char THEN
       x_complete_rec.TRANSFER_STATUS := l_listentries_rec.TRANSFER_STATUS  ;
    END IF;
    IF p_list_entries_rec.LIST_SOURCE = FND_API.g_miss_char THEN
       x_complete_rec.LIST_SOURCE := l_listentries_rec.LIST_SOURCE  ;
    END IF;
    IF p_list_entries_rec.DUPLICATE_MASTER_ENTRY_ID = FND_API.g_miss_num THEN
       x_complete_rec.DUPLICATE_MASTER_ENTRY_ID := l_listentries_rec.DUPLICATE_MASTER_ENTRY_ID  ;
    END IF;
    IF p_list_entries_rec.MARKED_FLAG = FND_API.g_miss_char THEN
       x_complete_rec.MARKED_FLAG := l_listentries_rec.MARKED_FLAG  ;
    END IF;
    IF p_list_entries_rec.LEAD_ID = FND_API.g_miss_num THEN
       x_complete_rec.LEAD_ID := l_listentries_rec.LEAD_ID  ;
    END IF;
    IF p_list_entries_rec.LETTER_ID = FND_API.g_miss_num THEN
       x_complete_rec.LETTER_ID := l_listentries_rec.LETTER_ID  ;
    END IF;
    IF p_list_entries_rec.PICKING_HEADER_ID = FND_API.g_miss_num THEN
       x_complete_rec.PICKING_HEADER_ID := l_listentries_rec.PICKING_HEADER_ID  ;
    END IF;
    IF p_list_entries_rec.BATCH_ID = FND_API.g_miss_num THEN
       x_complete_rec.BATCH_ID := l_listentries_rec.BATCH_ID  ;
    END IF;
    IF p_list_entries_rec.SUFFIX = FND_API.g_miss_char THEN
       x_complete_rec.SUFFIX := l_listentries_rec.SUFFIX  ;
    END IF;
    IF p_list_entries_rec.FIRST_NAME = FND_API.g_miss_char THEN
       x_complete_rec.FIRST_NAME := l_listentries_rec.FIRST_NAME  ;
    END IF;
    IF p_list_entries_rec.LAST_NAME = FND_API.g_miss_char THEN
       x_complete_rec.LAST_NAME := l_listentries_rec.LAST_NAME  ;
    END IF;
    IF p_list_entries_rec.CUSTOMER_NAME = FND_API.g_miss_char THEN
       x_complete_rec.CUSTOMER_NAME := l_listentries_rec.CUSTOMER_NAME  ;
    END IF;
    IF p_list_entries_rec.TITLE = FND_API.g_miss_char THEN
       x_complete_rec.TITLE := l_listentries_rec.TITLE  ;
    END IF;
    IF p_list_entries_rec.ADDRESS_LINE1 = FND_API.g_miss_char THEN
       x_complete_rec.ADDRESS_LINE1 := l_listentries_rec.ADDRESS_LINE1  ;
    END IF;
    IF p_list_entries_rec.ADDRESS_LINE2 = FND_API.g_miss_char THEN
       x_complete_rec.ADDRESS_LINE2 := l_listentries_rec.ADDRESS_LINE2  ;
    END IF;
    IF p_list_entries_rec.CITY = FND_API.g_miss_char THEN
       x_complete_rec.CITY := l_listentries_rec.CITY  ;
    END IF;
    IF p_list_entries_rec.STATE = FND_API.g_miss_char THEN
       x_complete_rec.STATE := l_listentries_rec.STATE  ;
    END IF;
    IF p_list_entries_rec.ZIPCODE = FND_API.g_miss_char THEN
       x_complete_rec.ZIPCODE := l_listentries_rec.ZIPCODE  ;
    END IF;
    IF p_list_entries_rec.COUNTRY = FND_API.g_miss_char THEN
       x_complete_rec.COUNTRY := l_listentries_rec.COUNTRY  ;
    END IF;
    IF p_list_entries_rec.FAX = FND_API.g_miss_char THEN
       x_complete_rec.FAX := l_listentries_rec.FAX  ;
    END IF;
    IF p_list_entries_rec.PHONE = FND_API.g_miss_char THEN
       x_complete_rec.PHONE := l_listentries_rec.PHONE  ;
    END IF;
    IF p_list_entries_rec.EMAIL_ADDRESS = FND_API.g_miss_char THEN
       x_complete_rec.EMAIL_ADDRESS := l_listentries_rec.EMAIL_ADDRESS  ;
    END IF;
    IF p_list_entries_rec.COL1 = FND_API.g_miss_char THEN
       x_complete_rec.COL1 := l_listentries_rec.COL1  ;
    END IF;
    IF p_list_entries_rec.COL2 = FND_API.g_miss_char THEN
       x_complete_rec.COL2 := l_listentries_rec.COL2  ;
    END IF;
    IF p_list_entries_rec.COL3 = FND_API.g_miss_char THEN
       x_complete_rec.COL3 := l_listentries_rec.COL3  ;
    END IF;
    IF p_list_entries_rec.COL4 = FND_API.g_miss_char THEN
       x_complete_rec.COL4 := l_listentries_rec.COL4  ;
    END IF;
    IF p_list_entries_rec.COL5 = FND_API.g_miss_char THEN
       x_complete_rec.COL5 := l_listentries_rec.COL5  ;
    END IF;
    IF p_list_entries_rec.COL6 = FND_API.g_miss_char THEN
       x_complete_rec.COL6 := l_listentries_rec.COL6  ;
    END IF;
    IF p_list_entries_rec.COL7 = FND_API.g_miss_char THEN
       x_complete_rec.COL7 := l_listentries_rec.COL7  ;
    END IF;
    IF p_list_entries_rec.COL8 = FND_API.g_miss_char THEN
       x_complete_rec.COL8 := l_listentries_rec.COL8  ;
    END IF;
    IF p_list_entries_rec.COL9 = FND_API.g_miss_char THEN
       x_complete_rec.COL9 := l_listentries_rec.COL9  ;
    END IF;
    IF p_list_entries_rec.COL10 = FND_API.g_miss_char THEN
       x_complete_rec.COL10 := l_listentries_rec.COL10  ;
    END IF;
    IF p_list_entries_rec.COL11 = FND_API.g_miss_char THEN
       x_complete_rec.COL11 := l_listentries_rec.COL11  ;
    END IF;
    IF p_list_entries_rec.COL12 = FND_API.g_miss_char THEN
       x_complete_rec.COL12 := l_listentries_rec.COL12  ;
    END IF;
    IF p_list_entries_rec.COL13 = FND_API.g_miss_char THEN
       x_complete_rec.COL13 := l_listentries_rec.COL13  ;
    END IF;
    IF p_list_entries_rec.COL14 = FND_API.g_miss_char THEN
       x_complete_rec.COL14 := l_listentries_rec.COL14  ;
    END IF;
    IF p_list_entries_rec.COL15 = FND_API.g_miss_char THEN
       x_complete_rec.COL15 := l_listentries_rec.COL15  ;
    END IF;
    IF p_list_entries_rec.COL16 = FND_API.g_miss_char THEN
       x_complete_rec.COL16 := l_listentries_rec.COL16  ;
    END IF;
    IF p_list_entries_rec.COL17 = FND_API.g_miss_char THEN
       x_complete_rec.COL17 := l_listentries_rec.COL17  ;
    END IF;
    IF p_list_entries_rec.COL18 = FND_API.g_miss_char THEN
       x_complete_rec.COL18 := l_listentries_rec.COL18  ;
    END IF;
    IF p_list_entries_rec.COL19 = FND_API.g_miss_char THEN
       x_complete_rec.COL19 := l_listentries_rec.COL19  ;
    END IF;
    IF p_list_entries_rec.COL20 = FND_API.g_miss_char THEN
       x_complete_rec.COL20 := l_listentries_rec.COL20  ;
    END IF;
    IF p_list_entries_rec.COL21 = FND_API.g_miss_char THEN
       x_complete_rec.COL21 := l_listentries_rec.COL21  ;
    END IF;
    IF p_list_entries_rec.COL22 = FND_API.g_miss_char THEN
       x_complete_rec.COL22 := l_listentries_rec.COL22  ;
    END IF;
    IF p_list_entries_rec.COL23 = FND_API.g_miss_char THEN
       x_complete_rec.COL23 := l_listentries_rec.COL23  ;
    END IF;
    IF p_list_entries_rec.COL24 = FND_API.g_miss_char THEN
       x_complete_rec.COL24 := l_listentries_rec.COL24  ;
    END IF;
    IF p_list_entries_rec.COL25 = FND_API.g_miss_char THEN
       x_complete_rec.COL25 := l_listentries_rec.COL25  ;
    END IF;
    IF p_list_entries_rec.COL26 = FND_API.g_miss_char THEN
       x_complete_rec.COL26 := l_listentries_rec.COL26  ;
    END IF;
    IF p_list_entries_rec.COL27 = FND_API.g_miss_char THEN
       x_complete_rec.COL27 := l_listentries_rec.COL27  ;
    END IF;
    IF p_list_entries_rec.COL28 = FND_API.g_miss_char THEN
       x_complete_rec.COL28 := l_listentries_rec.COL28  ;
    END IF;
    IF p_list_entries_rec.COL29 = FND_API.g_miss_char THEN
       x_complete_rec.COL29 := l_listentries_rec.COL29  ;
    END IF;
    IF p_list_entries_rec.COL30 = FND_API.g_miss_char THEN
       x_complete_rec.COL30 := l_listentries_rec.COL30  ;
    END IF;
    IF p_list_entries_rec.COL31 = FND_API.g_miss_char THEN
       x_complete_rec.COL31 := l_listentries_rec.COL31  ;
    END IF;
    IF p_list_entries_rec.COL32 = FND_API.g_miss_char THEN
       x_complete_rec.COL32 := l_listentries_rec.COL32  ;
    END IF;
    IF p_list_entries_rec.COL33 = FND_API.g_miss_char THEN
       x_complete_rec.COL33 := l_listentries_rec.COL33  ;
    END IF;
    IF p_list_entries_rec.COL34 = FND_API.g_miss_char THEN
       x_complete_rec.COL34 := l_listentries_rec.COL34  ;
    END IF;
    IF p_list_entries_rec.COL35 = FND_API.g_miss_char THEN
       x_complete_rec.COL35 := l_listentries_rec.COL35  ;
    END IF;
    IF p_list_entries_rec.COL36 = FND_API.g_miss_char THEN
       x_complete_rec.COL36 := l_listentries_rec.COL36  ;
    END IF;
    IF p_list_entries_rec.COL37 = FND_API.g_miss_char THEN
       x_complete_rec.COL37 := l_listentries_rec.COL37  ;
    END IF;
    IF p_list_entries_rec.COL38 = FND_API.g_miss_char THEN
       x_complete_rec.COL38 := l_listentries_rec.COL38  ;
    END IF;
    IF p_list_entries_rec.COL39 = FND_API.g_miss_char THEN
       x_complete_rec.COL39 := l_listentries_rec.COL39  ;
    END IF;
    IF p_list_entries_rec.COL40 = FND_API.g_miss_char THEN
       x_complete_rec.COL40 := l_listentries_rec.COL40  ;
    END IF;
    IF p_list_entries_rec.COL41 = FND_API.g_miss_char THEN
       x_complete_rec.COL41 := l_listentries_rec.COL41  ;
    END IF;
    IF p_list_entries_rec.COL42 = FND_API.g_miss_char THEN
       x_complete_rec.COL42 := l_listentries_rec.COL42  ;
    END IF;
    IF p_list_entries_rec.COL43 = FND_API.g_miss_char THEN
       x_complete_rec.COL43 := l_listentries_rec.COL43  ;
    END IF;
    IF p_list_entries_rec.COL44 = FND_API.g_miss_char THEN
       x_complete_rec.COL44 := l_listentries_rec.COL44  ;
    END IF;
    IF p_list_entries_rec.COL45 = FND_API.g_miss_char THEN
       x_complete_rec.COL45 := l_listentries_rec.COL45  ;
    END IF;
    IF p_list_entries_rec.COL46 = FND_API.g_miss_char THEN
       x_complete_rec.COL46 := l_listentries_rec.COL46  ;
    END IF;
    IF p_list_entries_rec.COL47 = FND_API.g_miss_char THEN
       x_complete_rec.COL47 := l_listentries_rec.COL47  ;
    END IF;
    IF p_list_entries_rec.COL48 = FND_API.g_miss_char THEN
       x_complete_rec.COL48 := l_listentries_rec.COL48  ;
    END IF;
    IF p_list_entries_rec.COL49 = FND_API.g_miss_char THEN
       x_complete_rec.COL49 := l_listentries_rec.COL49  ;
    END IF;
    IF p_list_entries_rec.COL50 = FND_API.g_miss_char THEN
       x_complete_rec.COL50 := l_listentries_rec.COL50  ;
    END IF;
    IF p_list_entries_rec.COL51 = FND_API.g_miss_char THEN
       x_complete_rec.COL51 := l_listentries_rec.COL51  ;
    END IF;
    IF p_list_entries_rec.COL52 = FND_API.g_miss_char THEN
       x_complete_rec.COL52 := l_listentries_rec.COL52  ;
    END IF;
    IF p_list_entries_rec.COL53 = FND_API.g_miss_char THEN
       x_complete_rec.COL53 := l_listentries_rec.COL53  ;
    END IF;
    IF p_list_entries_rec.COL54 = FND_API.g_miss_char THEN
       x_complete_rec.COL54 := l_listentries_rec.COL54  ;
    END IF;
    IF p_list_entries_rec.COL55 = FND_API.g_miss_char THEN
       x_complete_rec.COL55 := l_listentries_rec.COL55  ;
    END IF;
    IF p_list_entries_rec.COL56 = FND_API.g_miss_char THEN
       x_complete_rec.COL56 := l_listentries_rec.COL56  ;
    END IF;
    IF p_list_entries_rec.COL57 = FND_API.g_miss_char THEN
       x_complete_rec.COL57 := l_listentries_rec.COL57  ;
    END IF;
    IF p_list_entries_rec.COL58 = FND_API.g_miss_char THEN
       x_complete_rec.COL58 := l_listentries_rec.COL58  ;
    END IF;
    IF p_list_entries_rec.COL59 = FND_API.g_miss_char THEN
       x_complete_rec.COL59 := l_listentries_rec.COL59  ;
    END IF;
    IF p_list_entries_rec.COL60 = FND_API.g_miss_char THEN
       x_complete_rec.COL60 := l_listentries_rec.COL60  ;
    END IF;
    IF p_list_entries_rec.COL61 = FND_API.g_miss_char THEN
       x_complete_rec.COL61 := l_listentries_rec.COL61  ;
    END IF;
    IF p_list_entries_rec.COL62 = FND_API.g_miss_char THEN
       x_complete_rec.COL62 := l_listentries_rec.COL62  ;
    END IF;
    IF p_list_entries_rec.COL63 = FND_API.g_miss_char THEN
       x_complete_rec.COL63 := l_listentries_rec.COL63  ;
    END IF;
    IF p_list_entries_rec.COL64 = FND_API.g_miss_char THEN
       x_complete_rec.COL64 := l_listentries_rec.COL64  ;
    END IF;
    IF p_list_entries_rec.COL65 = FND_API.g_miss_char THEN
       x_complete_rec.COL65 := l_listentries_rec.COL65  ;
    END IF;
    IF p_list_entries_rec.COL66 = FND_API.g_miss_char THEN
       x_complete_rec.COL66 := l_listentries_rec.COL66  ;
    END IF;
    IF p_list_entries_rec.COL67 = FND_API.g_miss_char THEN
       x_complete_rec.COL67 := l_listentries_rec.COL67  ;
    END IF;
    IF p_list_entries_rec.COL68 = FND_API.g_miss_char THEN
       x_complete_rec.COL68 := l_listentries_rec.COL68  ;
    END IF;
    IF p_list_entries_rec.COL69 = FND_API.g_miss_char THEN
       x_complete_rec.COL69 := l_listentries_rec.COL69  ;
    END IF;
    IF p_list_entries_rec.COL70 = FND_API.g_miss_char THEN
       x_complete_rec.COL70 := l_listentries_rec.COL70  ;
    END IF;
    IF p_list_entries_rec.COL71 = FND_API.g_miss_char THEN
       x_complete_rec.COL71 := l_listentries_rec.COL71  ;
    END IF;
    IF p_list_entries_rec.COL72 = FND_API.g_miss_char THEN
       x_complete_rec.COL72 := l_listentries_rec.COL72  ;
    END IF;
    IF p_list_entries_rec.COL73 = FND_API.g_miss_char THEN
       x_complete_rec.COL73 := l_listentries_rec.COL73  ;
    END IF;
    IF p_list_entries_rec.COL74 = FND_API.g_miss_char THEN
       x_complete_rec.COL74 := l_listentries_rec.COL74  ;
    END IF;
    IF p_list_entries_rec.COL75 = FND_API.g_miss_char THEN
       x_complete_rec.COL75 := l_listentries_rec.COL75  ;
    END IF;
    IF p_list_entries_rec.COL76 = FND_API.g_miss_char THEN
       x_complete_rec.COL76 := l_listentries_rec.COL76  ;
    END IF;
    IF p_list_entries_rec.COL77 = FND_API.g_miss_char THEN
       x_complete_rec.COL77 := l_listentries_rec.COL77  ;
    END IF;
    IF p_list_entries_rec.COL78 = FND_API.g_miss_char THEN
       x_complete_rec.COL78 := l_listentries_rec.COL78  ;
    END IF;
    IF p_list_entries_rec.COL79 = FND_API.g_miss_char THEN
       x_complete_rec.COL79 := l_listentries_rec.COL79  ;
    END IF;
    IF p_list_entries_rec.COL80 = FND_API.g_miss_char THEN
       x_complete_rec.COL80 := l_listentries_rec.COL80  ;
    END IF;
    IF p_list_entries_rec.COL81 = FND_API.g_miss_char THEN
       x_complete_rec.COL81 := l_listentries_rec.COL81  ;
    END IF;
    IF p_list_entries_rec.COL82 = FND_API.g_miss_char THEN
       x_complete_rec.COL82 := l_listentries_rec.COL82  ;
    END IF;
    IF p_list_entries_rec.COL83 = FND_API.g_miss_char THEN
       x_complete_rec.COL83 := l_listentries_rec.COL83  ;
    END IF;
    IF p_list_entries_rec.COL84 = FND_API.g_miss_char THEN
       x_complete_rec.COL84 := l_listentries_rec.COL84  ;
    END IF;
    IF p_list_entries_rec.COL85 = FND_API.g_miss_char THEN
       x_complete_rec.COL85 := l_listentries_rec.COL85  ;
    END IF;
    IF p_list_entries_rec.COL86 = FND_API.g_miss_char THEN
       x_complete_rec.COL86 := l_listentries_rec.COL86  ;
    END IF;
    IF p_list_entries_rec.COL87 = FND_API.g_miss_char THEN
       x_complete_rec.COL87 := l_listentries_rec.COL87  ;
    END IF;
    IF p_list_entries_rec.COL88 = FND_API.g_miss_char THEN
       x_complete_rec.COL88 := l_listentries_rec.COL88  ;
    END IF;
    IF p_list_entries_rec.COL89 = FND_API.g_miss_char THEN
       x_complete_rec.COL89 := l_listentries_rec.COL89  ;
    END IF;
    IF p_list_entries_rec.COL90 = FND_API.g_miss_char THEN
       x_complete_rec.COL90 := l_listentries_rec.COL90  ;
    END IF;
    IF p_list_entries_rec.COL91 = FND_API.g_miss_char THEN
       x_complete_rec.COL91 := l_listentries_rec.COL91  ;
    END IF;
    IF p_list_entries_rec.COL92 = FND_API.g_miss_char THEN
       x_complete_rec.COL92 := l_listentries_rec.COL92  ;
    END IF;
    IF p_list_entries_rec.COL93 = FND_API.g_miss_char THEN
       x_complete_rec.COL93 := l_listentries_rec.COL93  ;
    END IF;
    IF p_list_entries_rec.COL94 = FND_API.g_miss_char THEN
       x_complete_rec.COL94 := l_listentries_rec.COL94  ;
    END IF;
    IF p_list_entries_rec.COL95 = FND_API.g_miss_char THEN
       x_complete_rec.COL95 := l_listentries_rec.COL95  ;
    END IF;
    IF p_list_entries_rec.COL96 = FND_API.g_miss_char THEN
       x_complete_rec.COL96 := l_listentries_rec.COL96  ;
    END IF;
    IF p_list_entries_rec.COL97 = FND_API.g_miss_char THEN
       x_complete_rec.COL97 := l_listentries_rec.COL97  ;
    END IF;
    IF p_list_entries_rec.COL98 = FND_API.g_miss_char THEN
       x_complete_rec.COL98 := l_listentries_rec.COL98  ;
    END IF;
    IF p_list_entries_rec.COL99 = FND_API.g_miss_char THEN
       x_complete_rec.COL99 := l_listentries_rec.COL99  ;
    END IF;
    IF p_list_entries_rec.COL100 = FND_API.g_miss_char THEN
       x_complete_rec.COL100 := l_listentries_rec.COL100  ;
    END IF;
    IF p_list_entries_rec.COL101 = FND_API.g_miss_char THEN
       x_complete_rec.COL101 := l_listentries_rec.COL101  ;
    END IF;
    IF p_list_entries_rec.COL102 = FND_API.g_miss_char THEN
       x_complete_rec.COL102 := l_listentries_rec.COL102  ;
    END IF;
    IF p_list_entries_rec.COL103 = FND_API.g_miss_char THEN
       x_complete_rec.COL103 := l_listentries_rec.COL103  ;
    END IF;
    IF p_list_entries_rec.COL104 = FND_API.g_miss_char THEN
       x_complete_rec.COL104 := l_listentries_rec.COL104  ;
    END IF;
    IF p_list_entries_rec.COL105 = FND_API.g_miss_char THEN
       x_complete_rec.COL105 := l_listentries_rec.COL105  ;
    END IF;
    IF p_list_entries_rec.COL106 = FND_API.g_miss_char THEN
       x_complete_rec.COL106 := l_listentries_rec.COL106  ;
    END IF;
    IF p_list_entries_rec.COL107 = FND_API.g_miss_char THEN
       x_complete_rec.COL107 := l_listentries_rec.COL107  ;
    END IF;
    IF p_list_entries_rec.COL108 = FND_API.g_miss_char THEN
       x_complete_rec.COL108 := l_listentries_rec.COL108  ;
    END IF;
    IF p_list_entries_rec.COL109 = FND_API.g_miss_char THEN
       x_complete_rec.COL109 := l_listentries_rec.COL109  ;
    END IF;
    IF p_list_entries_rec.COL110 = FND_API.g_miss_char THEN
       x_complete_rec.COL110 := l_listentries_rec.COL110  ;
    END IF;
    IF p_list_entries_rec.COL111 = FND_API.g_miss_char THEN
       x_complete_rec.COL111 := l_listentries_rec.COL111  ;
    END IF;
    IF p_list_entries_rec.COL112 = FND_API.g_miss_char THEN
       x_complete_rec.COL112 := l_listentries_rec.COL112  ;
    END IF;
    IF p_list_entries_rec.COL113 = FND_API.g_miss_char THEN
       x_complete_rec.COL113 := l_listentries_rec.COL113  ;
    END IF;
    IF p_list_entries_rec.COL114 = FND_API.g_miss_char THEN
       x_complete_rec.COL114 := l_listentries_rec.COL114  ;
    END IF;
    IF p_list_entries_rec.COL115 = FND_API.g_miss_char THEN
       x_complete_rec.COL115 := l_listentries_rec.COL115  ;
    END IF;
    IF p_list_entries_rec.COL116 = FND_API.g_miss_char THEN
       x_complete_rec.COL116 := l_listentries_rec.COL116  ;
    END IF;
    IF p_list_entries_rec.COL117 = FND_API.g_miss_char THEN
       x_complete_rec.COL117 := l_listentries_rec.COL117  ;
    END IF;
    IF p_list_entries_rec.COL118 = FND_API.g_miss_char THEN
       x_complete_rec.COL118 := l_listentries_rec.COL118  ;
    END IF;
    IF p_list_entries_rec.COL119 = FND_API.g_miss_char THEN
       x_complete_rec.COL119 := l_listentries_rec.COL119  ;
    END IF;
    IF p_list_entries_rec.COL120 = FND_API.g_miss_char THEN
       x_complete_rec.COL120 := l_listentries_rec.COL120  ;
    END IF;
    IF p_list_entries_rec.COL121 = FND_API.g_miss_char THEN
       x_complete_rec.COL121 := l_listentries_rec.COL121  ;
    END IF;
    IF p_list_entries_rec.COL122 = FND_API.g_miss_char THEN
       x_complete_rec.COL122 := l_listentries_rec.COL122  ;
    END IF;
    IF p_list_entries_rec.COL123 = FND_API.g_miss_char THEN
       x_complete_rec.COL123 := l_listentries_rec.COL123  ;
    END IF;
    IF p_list_entries_rec.COL124 = FND_API.g_miss_char THEN
       x_complete_rec.COL124 := l_listentries_rec.COL124  ;
    END IF;
    IF p_list_entries_rec.COL125 = FND_API.g_miss_char THEN
       x_complete_rec.COL125 := l_listentries_rec.COL125  ;
    END IF;
    IF p_list_entries_rec.COL126 = FND_API.g_miss_char THEN
       x_complete_rec.COL126 := l_listentries_rec.COL126  ;
    END IF;
    IF p_list_entries_rec.COL127 = FND_API.g_miss_char THEN
       x_complete_rec.COL127 := l_listentries_rec.COL127  ;
    END IF;
    IF p_list_entries_rec.COL128 = FND_API.g_miss_char THEN
       x_complete_rec.COL128 := l_listentries_rec.COL128  ;
    END IF;
    IF p_list_entries_rec.COL129 = FND_API.g_miss_char THEN
       x_complete_rec.COL129 := l_listentries_rec.COL129  ;
    END IF;
    IF p_list_entries_rec.COL130 = FND_API.g_miss_char THEN
       x_complete_rec.COL130 := l_listentries_rec.COL130  ;
    END IF;
    IF p_list_entries_rec.COL131 = FND_API.g_miss_char THEN
       x_complete_rec.COL131 := l_listentries_rec.COL131  ;
    END IF;
    IF p_list_entries_rec.COL132 = FND_API.g_miss_char THEN
       x_complete_rec.COL132 := l_listentries_rec.COL132  ;
    END IF;
    IF p_list_entries_rec.COL133 = FND_API.g_miss_char THEN
       x_complete_rec.COL133 := l_listentries_rec.COL133  ;
    END IF;
    IF p_list_entries_rec.COL134 = FND_API.g_miss_char THEN
       x_complete_rec.COL134 := l_listentries_rec.COL134  ;
    END IF;
    IF p_list_entries_rec.COL135 = FND_API.g_miss_char THEN
       x_complete_rec.COL135 := l_listentries_rec.COL135  ;
    END IF;
    IF p_list_entries_rec.COL136 = FND_API.g_miss_char THEN
       x_complete_rec.COL136 := l_listentries_rec.COL136  ;
    END IF;
    IF p_list_entries_rec.COL137 = FND_API.g_miss_char THEN
       x_complete_rec.COL137 := l_listentries_rec.COL137  ;
    END IF;
    IF p_list_entries_rec.COL138 = FND_API.g_miss_char THEN
       x_complete_rec.COL138 := l_listentries_rec.COL138  ;
    END IF;
    IF p_list_entries_rec.COL139 = FND_API.g_miss_char THEN
       x_complete_rec.COL139 := l_listentries_rec.COL139  ;
    END IF;
    IF p_list_entries_rec.COL140 = FND_API.g_miss_char THEN
       x_complete_rec.COL140 := l_listentries_rec.COL140  ;
    END IF;
    IF p_list_entries_rec.COL141 = FND_API.g_miss_char THEN
       x_complete_rec.COL141 := l_listentries_rec.COL141  ;
    END IF;
    IF p_list_entries_rec.COL142 = FND_API.g_miss_char THEN
       x_complete_rec.COL142 := l_listentries_rec.COL142  ;
    END IF;
    IF p_list_entries_rec.COL143 = FND_API.g_miss_char THEN
       x_complete_rec.COL143 := l_listentries_rec.COL143  ;
    END IF;
    IF p_list_entries_rec.COL144 = FND_API.g_miss_char THEN
       x_complete_rec.COL144 := l_listentries_rec.COL144  ;
    END IF;
    IF p_list_entries_rec.COL145 = FND_API.g_miss_char THEN
       x_complete_rec.COL145 := l_listentries_rec.COL145  ;
    END IF;
    IF p_list_entries_rec.COL146 = FND_API.g_miss_char THEN
       x_complete_rec.COL146 := l_listentries_rec.COL146  ;
    END IF;
    IF p_list_entries_rec.COL147 = FND_API.g_miss_char THEN
       x_complete_rec.COL147 := l_listentries_rec.COL147  ;
    END IF;
    IF p_list_entries_rec.COL148 = FND_API.g_miss_char THEN
       x_complete_rec.COL148 := l_listentries_rec.COL148  ;
    END IF;
    IF p_list_entries_rec.COL149 = FND_API.g_miss_char THEN
       x_complete_rec.COL149 := l_listentries_rec.COL149  ;
    END IF;
    IF p_list_entries_rec.COL150 = FND_API.g_miss_char THEN
       x_complete_rec.COL150 := l_listentries_rec.COL150  ;
    END IF;
    IF p_list_entries_rec.COL151 = FND_API.g_miss_char THEN
       x_complete_rec.COL151 := l_listentries_rec.COL151  ;
    END IF;
    IF p_list_entries_rec.COL152 = FND_API.g_miss_char THEN
       x_complete_rec.COL152 := l_listentries_rec.COL152  ;
    END IF;
    IF p_list_entries_rec.COL153 = FND_API.g_miss_char THEN
       x_complete_rec.COL153 := l_listentries_rec.COL153  ;
    END IF;
    IF p_list_entries_rec.COL154 = FND_API.g_miss_char THEN
       x_complete_rec.COL154 := l_listentries_rec.COL154  ;
    END IF;
    IF p_list_entries_rec.COL155 = FND_API.g_miss_char THEN
       x_complete_rec.COL155 := l_listentries_rec.COL155  ;
    END IF;
    IF p_list_entries_rec.COL156 = FND_API.g_miss_char THEN
       x_complete_rec.COL156 := l_listentries_rec.COL156  ;
    END IF;
    IF p_list_entries_rec.COL157 = FND_API.g_miss_char THEN
       x_complete_rec.COL157 := l_listentries_rec.COL157  ;
    END IF;
    IF p_list_entries_rec.COL158 = FND_API.g_miss_char THEN
       x_complete_rec.COL158 := l_listentries_rec.COL158  ;
    END IF;
    IF p_list_entries_rec.COL159 = FND_API.g_miss_char THEN
       x_complete_rec.COL159 := l_listentries_rec.COL159  ;
    END IF;
    IF p_list_entries_rec.COL160 = FND_API.g_miss_char THEN
       x_complete_rec.COL160 := l_listentries_rec.COL160  ;
    END IF;
    IF p_list_entries_rec.COL161 = FND_API.g_miss_char THEN
       x_complete_rec.COL161 := l_listentries_rec.COL161  ;
    END IF;
    IF p_list_entries_rec.COL162 = FND_API.g_miss_char THEN
       x_complete_rec.COL162 := l_listentries_rec.COL162  ;
    END IF;
    IF p_list_entries_rec.COL163 = FND_API.g_miss_char THEN
       x_complete_rec.COL163 := l_listentries_rec.COL163  ;
    END IF;
    IF p_list_entries_rec.COL164 = FND_API.g_miss_char THEN
       x_complete_rec.COL164 := l_listentries_rec.COL164  ;
    END IF;
    IF p_list_entries_rec.COL165 = FND_API.g_miss_char THEN
       x_complete_rec.COL165 := l_listentries_rec.COL165  ;
    END IF;
    IF p_list_entries_rec.COL166 = FND_API.g_miss_char THEN
       x_complete_rec.COL166 := l_listentries_rec.COL166  ;
    END IF;
    IF p_list_entries_rec.COL167 = FND_API.g_miss_char THEN
       x_complete_rec.COL167 := l_listentries_rec.COL167  ;
    END IF;
    IF p_list_entries_rec.COL168 = FND_API.g_miss_char THEN
       x_complete_rec.COL168 := l_listentries_rec.COL168  ;
    END IF;
    IF p_list_entries_rec.COL169 = FND_API.g_miss_char THEN
       x_complete_rec.COL169 := l_listentries_rec.COL169  ;
    END IF;
    IF p_list_entries_rec.COL170 = FND_API.g_miss_char THEN
       x_complete_rec.COL170 := l_listentries_rec.COL170  ;
    END IF;
    IF p_list_entries_rec.COL171 = FND_API.g_miss_char THEN
       x_complete_rec.COL171 := l_listentries_rec.COL171  ;
    END IF;
    IF p_list_entries_rec.COL172 = FND_API.g_miss_char THEN
       x_complete_rec.COL172 := l_listentries_rec.COL172  ;
    END IF;
    IF p_list_entries_rec.COL173 = FND_API.g_miss_char THEN
       x_complete_rec.COL173 := l_listentries_rec.COL173  ;
    END IF;
    IF p_list_entries_rec.COL174 = FND_API.g_miss_char THEN
       x_complete_rec.COL174 := l_listentries_rec.COL174  ;
    END IF;
    IF p_list_entries_rec.COL175 = FND_API.g_miss_char THEN
       x_complete_rec.COL175 := l_listentries_rec.COL175  ;
    END IF;
    IF p_list_entries_rec.COL176 = FND_API.g_miss_char THEN
       x_complete_rec.COL176 := l_listentries_rec.COL176  ;
    END IF;
    IF p_list_entries_rec.COL177 = FND_API.g_miss_char THEN
       x_complete_rec.COL177 := l_listentries_rec.COL177  ;
    END IF;
    IF p_list_entries_rec.COL178 = FND_API.g_miss_char THEN
       x_complete_rec.COL178 := l_listentries_rec.COL178  ;
    END IF;
    IF p_list_entries_rec.COL179 = FND_API.g_miss_char THEN
       x_complete_rec.COL179 := l_listentries_rec.COL179  ;
    END IF;
    IF p_list_entries_rec.COL180 = FND_API.g_miss_char THEN
       x_complete_rec.COL180 := l_listentries_rec.COL180  ;
    END IF;
    IF p_list_entries_rec.COL181 = FND_API.g_miss_char THEN
       x_complete_rec.COL181 := l_listentries_rec.COL181  ;
    END IF;
    IF p_list_entries_rec.COL182 = FND_API.g_miss_char THEN
       x_complete_rec.COL182 := l_listentries_rec.COL182  ;
    END IF;
    IF p_list_entries_rec.COL183 = FND_API.g_miss_char THEN
       x_complete_rec.COL183 := l_listentries_rec.COL183  ;
    END IF;
    IF p_list_entries_rec.COL184 = FND_API.g_miss_char THEN
       x_complete_rec.COL184 := l_listentries_rec.COL184  ;
    END IF;
    IF p_list_entries_rec.COL185 = FND_API.g_miss_char THEN
       x_complete_rec.COL185 := l_listentries_rec.COL185  ;
    END IF;
    IF p_list_entries_rec.COL186 = FND_API.g_miss_char THEN
       x_complete_rec.COL186 := l_listentries_rec.COL186  ;
    END IF;
    IF p_list_entries_rec.COL187 = FND_API.g_miss_char THEN
       x_complete_rec.COL187 := l_listentries_rec.COL187  ;
    END IF;
    IF p_list_entries_rec.COL188 = FND_API.g_miss_char THEN
       x_complete_rec.COL188 := l_listentries_rec.COL188  ;
    END IF;
    IF p_list_entries_rec.COL189 = FND_API.g_miss_char THEN
       x_complete_rec.COL189 := l_listentries_rec.COL189  ;
    END IF;
    IF p_list_entries_rec.COL190 = FND_API.g_miss_char THEN
       x_complete_rec.COL190 := l_listentries_rec.COL190  ;
    END IF;
    IF p_list_entries_rec.COL191 = FND_API.g_miss_char THEN
       x_complete_rec.COL191 := l_listentries_rec.COL191  ;
    END IF;
    IF p_list_entries_rec.COL192 = FND_API.g_miss_char THEN
       x_complete_rec.COL192 := l_listentries_rec.COL192  ;
    END IF;
    IF p_list_entries_rec.COL193 = FND_API.g_miss_char THEN
       x_complete_rec.COL193 := l_listentries_rec.COL193  ;
    END IF;
    IF p_list_entries_rec.COL194 = FND_API.g_miss_char THEN
       x_complete_rec.COL194 := l_listentries_rec.COL194  ;
    END IF;
    IF p_list_entries_rec.COL195 = FND_API.g_miss_char THEN
       x_complete_rec.COL195 := l_listentries_rec.COL195  ;
    END IF;
    IF p_list_entries_rec.COL196 = FND_API.g_miss_char THEN
       x_complete_rec.COL196 := l_listentries_rec.COL196  ;
    END IF;
    IF p_list_entries_rec.COL197 = FND_API.g_miss_char THEN
       x_complete_rec.COL197 := l_listentries_rec.COL197  ;
    END IF;
    IF p_list_entries_rec.COL198 = FND_API.g_miss_char THEN
       x_complete_rec.COL198 := l_listentries_rec.COL198  ;
    END IF;
    IF p_list_entries_rec.COL199 = FND_API.g_miss_char THEN
       x_complete_rec.COL199 := l_listentries_rec.COL199  ;
    END IF;
    IF p_list_entries_rec.COL200 = FND_API.g_miss_char THEN
       x_complete_rec.COL200 := l_listentries_rec.COL200  ;
    END IF;


 IF p_list_entries_rec.COL201  = FND_API.g_miss_char THEN
     x_complete_rec.COL201 := l_listentries_rec.COL201;
 END IF;

 IF p_list_entries_rec.COL202 = FND_API.g_miss_char THEN
     x_complete_rec.COL202 := l_listentries_rec.COL202;
 END IF;

 IF p_list_entries_rec.COL203 = FND_API.g_miss_char THEN
     x_complete_rec.COL203 := l_listentries_rec.COL203;
 END IF;

 IF p_list_entries_rec.COL204 = FND_API.g_miss_char THEN
     x_complete_rec.COL204 := l_listentries_rec.COL204;
 END IF;

 IF p_list_entries_rec.COL205 = FND_API.g_miss_char THEN
     x_complete_rec.COL205 := l_listentries_rec.COL205;
 END IF;

 IF p_list_entries_rec.COL206 = FND_API.g_miss_char THEN
     x_complete_rec.COL206 := l_listentries_rec.COL206;
 END IF;

 IF p_list_entries_rec.COL207 = FND_API.g_miss_char THEN
     x_complete_rec.COL207 := l_listentries_rec.COL207;
 END IF;

 IF p_list_entries_rec.COL208 = FND_API.g_miss_char THEN
     x_complete_rec.COL208 := l_listentries_rec.COL208;
 END IF;

 IF p_list_entries_rec.COL209 = FND_API.g_miss_char THEN
     x_complete_rec.COL209 := l_listentries_rec.COL209;
 END IF;

 IF p_list_entries_rec.COL210 = FND_API.g_miss_char THEN
     x_complete_rec.COL210 := l_listentries_rec.COL210;
 END IF;

 IF p_list_entries_rec.COL211 = FND_API.g_miss_char THEN
     x_complete_rec.COL211 := l_listentries_rec.COL211;
 END IF;

 IF p_list_entries_rec.COL212 = FND_API.g_miss_char THEN
     x_complete_rec.COL212 := l_listentries_rec.COL212;
 END IF;

 IF p_list_entries_rec.COL213 = FND_API.g_miss_char THEN
     x_complete_rec.COL213 := l_listentries_rec.COL213;
 END IF;

 IF p_list_entries_rec.COL214 = FND_API.g_miss_char THEN
     x_complete_rec.COL214 := l_listentries_rec.COL214;
 END IF;

 IF p_list_entries_rec.COL215 = FND_API.g_miss_char THEN
     x_complete_rec.COL215 := l_listentries_rec.COL215;
 END IF;

 IF p_list_entries_rec.COL216 = FND_API.g_miss_char THEN
      x_complete_rec.COL216 := l_listentries_rec.COL216;
 END IF;

 IF p_list_entries_rec.COL217 = FND_API.g_miss_char THEN
     x_complete_rec.COL217 := l_listentries_rec.COL217;
 END IF;

 IF p_list_entries_rec.COL218 = FND_API.g_miss_char THEN
     x_complete_rec.COL218 := l_listentries_rec.COL218;
 END IF;

 IF p_list_entries_rec.COL219 = FND_API.g_miss_char THEN
     x_complete_rec.COL219 := l_listentries_rec.COL219;
 END IF;

 IF p_list_entries_rec.COL220 = FND_API.g_miss_char THEN
     x_complete_rec.COL220  := l_listentries_rec.COL220 ;
 END IF;

 IF p_list_entries_rec.COL221 = FND_API.g_miss_char THEN
     x_complete_rec.COL221 := l_listentries_rec.COL221;
 END IF;

 IF p_list_entries_rec.COL222 = FND_API.g_miss_char THEN
     x_complete_rec.COL222 := l_listentries_rec.COL222;
 END IF;

 IF p_list_entries_rec.COL223 = FND_API.g_miss_char THEN
     x_complete_rec.COL223 := l_listentries_rec.COL223;
 END IF;

 IF p_list_entries_rec.COL224 = FND_API.g_miss_char THEN
     x_complete_rec.COL224 := l_listentries_rec.COL224;
 END IF;

 IF p_list_entries_rec.COL225 = FND_API.g_miss_char THEN
     x_complete_rec.COL225 := l_listentries_rec.COL225;
 END IF;

 IF p_list_entries_rec.COL226 = FND_API.g_miss_char THEN
     x_complete_rec.COL226 := l_listentries_rec.COL226;
 END IF;

 IF p_list_entries_rec.COL227 = FND_API.g_miss_char THEN
     x_complete_rec.COL227  := l_listentries_rec.COL227 ;
 END IF;

 IF p_list_entries_rec.COL228 = FND_API.g_miss_char THEN
     x_complete_rec.COL228  := l_listentries_rec.COL228 ;
 END IF;

 IF p_list_entries_rec.COL229 = FND_API.g_miss_char THEN
     x_complete_rec.COL229 := l_listentries_rec.COL229;
 END IF;

 IF p_list_entries_rec.COL230 = FND_API.g_miss_char THEN
     x_complete_rec.COL230  := l_listentries_rec.COL230 ;
 END IF;

 IF p_list_entries_rec.COL231 = FND_API.g_miss_char THEN
     x_complete_rec.COL231 := l_listentries_rec.COL231;
 END IF;

 IF p_list_entries_rec.COL232 = FND_API.g_miss_char THEN
     x_complete_rec.COL232 := l_listentries_rec.COL232;
 END IF;

 IF p_list_entries_rec.COL233 = FND_API.g_miss_char THEN
     x_complete_rec.COL233 := l_listentries_rec.COL233;
 END IF;

 IF p_list_entries_rec.COL234 = FND_API.g_miss_char THEN
     x_complete_rec.COL234 := l_listentries_rec.COL234;
 END IF;

 IF p_list_entries_rec.COL235 = FND_API.g_miss_char THEN
     x_complete_rec.COL235  := l_listentries_rec.COL235 ;
 END IF;

 IF p_list_entries_rec.COL236 = FND_API.g_miss_char THEN
     x_complete_rec.COL236 := l_listentries_rec.COL236;
 END IF;

 IF p_list_entries_rec.COL237 = FND_API.g_miss_char THEN
     x_complete_rec.COL237 := l_listentries_rec.COL237;
 END IF;

 IF p_list_entries_rec.COL238 = FND_API.g_miss_char THEN
     x_complete_rec.COL238  := l_listentries_rec.COL238 ;
 END IF;

 IF p_list_entries_rec.COL239 = FND_API.g_miss_char THEN
     x_complete_rec.COL239 := l_listentries_rec.COL239;
 END IF;

 IF p_list_entries_rec.COL240 = FND_API.g_miss_char THEN
     x_complete_rec.COL240 := l_listentries_rec.COL240;
 END IF;

 IF p_list_entries_rec.COL241 = FND_API.g_miss_char THEN
     x_complete_rec.COL241  := l_listentries_rec.COL241 ;
 END IF;

 IF p_list_entries_rec.COL242 = FND_API.g_miss_char THEN
     x_complete_rec.COL242 := l_listentries_rec.COL242;
 END IF;

 IF p_list_entries_rec.COL243 = FND_API.g_miss_char THEN
     x_complete_rec.COL243 := l_listentries_rec.COL243;
 END IF;

 IF p_list_entries_rec.COL244 = FND_API.g_miss_char THEN
     x_complete_rec.COL244 := l_listentries_rec.COL244;
 END IF;

 IF p_list_entries_rec.COL245 = FND_API.g_miss_char THEN
     x_complete_rec.COL245 := l_listentries_rec.COL245;
 END IF;

 IF p_list_entries_rec.COL246 = FND_API.g_miss_char THEN
     x_complete_rec.COL246 := l_listentries_rec.COL246;
 END IF;

 IF p_list_entries_rec.COL247 = FND_API.g_miss_char THEN
     x_complete_rec.COL247 := l_listentries_rec.COL247;
 END IF;

 IF p_list_entries_rec.COL248 = FND_API.g_miss_char THEN
     x_complete_rec.COL248  := l_listentries_rec.COL248 ;
 END IF;

 IF p_list_entries_rec.COL249 = FND_API.g_miss_char THEN
     x_complete_rec.COL249 := l_listentries_rec.COL249;
 END IF;

 IF p_list_entries_rec.COL250 = FND_API.g_miss_char THEN
     x_complete_rec.COL250 := l_listentries_rec.COL250;
 END IF;

 IF p_list_entries_rec.COL251 = FND_API.g_miss_char THEN
    x_complete_rec.COL251 := l_listentries_rec.COL251;
 END IF;


 IF p_list_entries_rec.COL252 = FND_API.g_miss_char THEN
    x_complete_rec.COL252 := l_listentries_rec.COL252;
 END IF;


 IF p_list_entries_rec.COL253 = FND_API.g_miss_char THEN
    x_complete_rec.COL253 := l_listentries_rec.COL253;
 END IF;


 IF p_list_entries_rec.COL254 = FND_API.g_miss_char THEN
    x_complete_rec.COL254 := l_listentries_rec.COL254;
 END IF;


 IF p_list_entries_rec.COL255 = FND_API.g_miss_char THEN
    x_complete_rec.COL255 := l_listentries_rec.COL255;
 END IF;


 IF p_list_entries_rec.COL256 = FND_API.g_miss_char THEN
    x_complete_rec.COL256 := l_listentries_rec.COL256;
 END IF;


 IF p_list_entries_rec.COL257 = FND_API.g_miss_char THEN
    x_complete_rec.COL257 := l_listentries_rec.COL257;
 END IF;


 IF p_list_entries_rec.COL258 = FND_API.g_miss_char THEN
    x_complete_rec.COL258 := l_listentries_rec.COL258;
 END IF;


 IF p_list_entries_rec.COL259 = FND_API.g_miss_char THEN
    x_complete_rec.COL259 := l_listentries_rec.COL259;
 END IF;


 IF p_list_entries_rec.COL260 = FND_API.g_miss_char THEN
    x_complete_rec.COL260 := l_listentries_rec.COL260;
 END IF;


 IF p_list_entries_rec.COL261 = FND_API.g_miss_char THEN
    x_complete_rec.COL261 := l_listentries_rec.COL261;
 END IF;


 IF p_list_entries_rec.COL262 = FND_API.g_miss_char THEN
    x_complete_rec.COL262 := l_listentries_rec.COL262;
 END IF;


 IF p_list_entries_rec.COL263 = FND_API.g_miss_char THEN
    x_complete_rec.COL263 := l_listentries_rec.COL263;
 END IF;


 IF p_list_entries_rec.COL264 = FND_API.g_miss_char THEN
    x_complete_rec.COL264 := l_listentries_rec.COL264;
 END IF;


 IF p_list_entries_rec.COL265 = FND_API.g_miss_char THEN
    x_complete_rec.COL265 := l_listentries_rec.COL265;
 END IF;


 IF p_list_entries_rec.COL266 = FND_API.g_miss_char THEN
    x_complete_rec.COL266 := l_listentries_rec.COL266;
 END IF;


 IF p_list_entries_rec.COL267 = FND_API.g_miss_char THEN
    x_complete_rec.COL267 := l_listentries_rec.COL267;
 END IF;


 IF p_list_entries_rec.COL268 = FND_API.g_miss_char THEN
    x_complete_rec.COL268 := l_listentries_rec.COL268;
 END IF;


 IF p_list_entries_rec.COL269 = FND_API.g_miss_char THEN
    x_complete_rec.COL269 := l_listentries_rec.COL269;
 END IF;


 IF p_list_entries_rec.COL270 = FND_API.g_miss_char THEN
    x_complete_rec.COL270 := l_listentries_rec.COL270;
 END IF;


 IF p_list_entries_rec.COL271 = FND_API.g_miss_char THEN
    x_complete_rec.COL271 := l_listentries_rec.COL271;
 END IF;


 IF p_list_entries_rec.COL272 = FND_API.g_miss_char THEN
    x_complete_rec.COL272 := l_listentries_rec.COL272;
 END IF;


 IF p_list_entries_rec.COL273 = FND_API.g_miss_char THEN
    x_complete_rec.COL273 := l_listentries_rec.COL273;
 END IF;


 IF p_list_entries_rec.COL274 = FND_API.g_miss_char THEN
    x_complete_rec.COL274 := l_listentries_rec.COL274;
 END IF;


 IF p_list_entries_rec.COL275 = FND_API.g_miss_char THEN
    x_complete_rec.COL275 := l_listentries_rec.COL275;
 END IF;


 IF p_list_entries_rec.COL276 = FND_API.g_miss_char THEN
    x_complete_rec.COL276 := l_listentries_rec.COL276;
 END IF;


 IF p_list_entries_rec.COL277 = FND_API.g_miss_char THEN
    x_complete_rec.COL277 := l_listentries_rec.COL277;
 END IF;


 IF p_list_entries_rec.COL278 = FND_API.g_miss_char THEN
    x_complete_rec.COL278 := l_listentries_rec.COL278;
 END IF;


 IF p_list_entries_rec.COL279 = FND_API.g_miss_char THEN
    x_complete_rec.COL279 := l_listentries_rec.COL279;
 END IF;


 IF p_list_entries_rec.COL280 = FND_API.g_miss_char THEN
    x_complete_rec.COL280 := l_listentries_rec.COL280;
 END IF;


 IF p_list_entries_rec.COL281 = FND_API.g_miss_char THEN
    x_complete_rec.COL281 := l_listentries_rec.COL281;
 END IF;


 IF p_list_entries_rec.COL282 = FND_API.g_miss_char THEN
    x_complete_rec.COL282 := l_listentries_rec.COL282;
 END IF;


 IF p_list_entries_rec.COL283 = FND_API.g_miss_char THEN
    x_complete_rec.COL283 := l_listentries_rec.COL283;
 END IF;


 IF p_list_entries_rec.COL284 = FND_API.g_miss_char THEN
    x_complete_rec.COL284 := l_listentries_rec.COL284;
 END IF;


 IF p_list_entries_rec.COL285 = FND_API.g_miss_char THEN
    x_complete_rec.COL285 := l_listentries_rec.COL285;
 END IF;


 IF p_list_entries_rec.COL286 = FND_API.g_miss_char THEN
    x_complete_rec.COL286 := l_listentries_rec.COL286;
 END IF;


 IF p_list_entries_rec.COL287 = FND_API.g_miss_char THEN
    x_complete_rec.COL287 := l_listentries_rec.COL287;
 END IF;


 IF p_list_entries_rec.COL288 = FND_API.g_miss_char THEN
    x_complete_rec.COL288 := l_listentries_rec.COL288;
 END IF;


 IF p_list_entries_rec.COL289 = FND_API.g_miss_char THEN
    x_complete_rec.COL289 := l_listentries_rec.COL289;
 END IF;


 IF p_list_entries_rec.COL290 = FND_API.g_miss_char THEN
    x_complete_rec.COL290 := l_listentries_rec.COL290;
 END IF;


 IF p_list_entries_rec.COL291 = FND_API.g_miss_char THEN
    x_complete_rec.COL291 := l_listentries_rec.COL291;
 END IF;


 IF p_list_entries_rec.COL292 = FND_API.g_miss_char THEN
    x_complete_rec.COL292 := l_listentries_rec.COL292;
 END IF;


 IF p_list_entries_rec.COL293 = FND_API.g_miss_char THEN
    x_complete_rec.COL293 := l_listentries_rec.COL293;
 END IF;


 IF p_list_entries_rec.COL294 = FND_API.g_miss_char THEN
    x_complete_rec.COL294 := l_listentries_rec.COL294;
 END IF;


 IF p_list_entries_rec.COL295 = FND_API.g_miss_char THEN
    x_complete_rec.COL295 := l_listentries_rec.COL295;
 END IF;


 IF p_list_entries_rec.COL296 = FND_API.g_miss_char THEN
    x_complete_rec.COL296 := l_listentries_rec.COL296;
 END IF;


 IF p_list_entries_rec.COL297 = FND_API.g_miss_char THEN
    x_complete_rec.COL297 := l_listentries_rec.COL297;
 END IF;


 IF p_list_entries_rec.COL298 = FND_API.g_miss_char THEN
    x_complete_rec.COL298 := l_listentries_rec.COL298;
 END IF;


 IF p_list_entries_rec.COL299 = FND_API.g_miss_char THEN
    x_complete_rec.COL299 := l_listentries_rec.COL299;
 END IF;


 IF p_list_entries_rec.COL300 = FND_API.g_miss_char THEN
    x_complete_rec.COL300 := l_listentries_rec.COL300;
 END IF;


 IF p_list_entries_rec.ADDRESS_LINE1 = FND_API.g_miss_char THEN
    x_complete_rec.ADDRESS_LINE1 := l_listentries_rec.ADDRESS_LINE1;
 END IF;


 IF p_list_entries_rec.ADDRESS_LINE2 = FND_API.g_miss_char THEN
    x_complete_rec.ADDRESS_LINE2 := l_listentries_rec.ADDRESS_LINE2;
 END IF;


 IF p_list_entries_rec.CALLBACK_FLAG = FND_API.g_miss_char THEN
    x_complete_rec.CALLBACK_FLAG := l_listentries_rec.CALLBACK_FLAG;
 END IF;


 IF p_list_entries_rec.CITY = FND_API.g_miss_char THEN
    x_complete_rec.CITY := l_listentries_rec.CITY;
 END IF;


 IF p_list_entries_rec.COUNTRY = FND_API.g_miss_char THEN
    x_complete_rec.COUNTRY := l_listentries_rec.COUNTRY;
 END IF;


 IF p_list_entries_rec.DO_NOT_USE_FLAG = FND_API.g_miss_char THEN
    x_complete_rec.DO_NOT_USE_FLAG := l_listentries_rec.DO_NOT_USE_FLAG;
 END IF;


 IF p_list_entries_rec.DO_NOT_USE_REASON = FND_API.g_miss_char THEN
    x_complete_rec.DO_NOT_USE_REASON := l_listentries_rec.DO_NOT_USE_REASON;
 END IF;


 IF p_list_entries_rec.EMAIL_ADDRESS = FND_API.g_miss_char THEN
    x_complete_rec.EMAIL_ADDRESS := l_listentries_rec.EMAIL_ADDRESS;
 END IF;


 IF p_list_entries_rec.FAX = FND_API.g_miss_char THEN
    x_complete_rec.FAX := l_listentries_rec.FAX;
 END IF;


 IF p_list_entries_rec.PHONE = FND_API.g_miss_char THEN
    x_complete_rec.PHONE := l_listentries_rec.PHONE;
 END IF;


 IF p_list_entries_rec.RECORD_OUT_FLAG = FND_API.g_miss_char THEN
    x_complete_rec.RECORD_OUT_FLAG := l_listentries_rec.RECORD_OUT_FLAG;
 END IF;


 IF p_list_entries_rec.STATE = FND_API.g_miss_char THEN
    x_complete_rec.STATE := l_listentries_rec.STATE;
 END IF;


 IF p_list_entries_rec.SUFFIX = FND_API.g_miss_char THEN
    x_complete_rec.SUFFIX := l_listentries_rec.SUFFIX;
 END IF;


 IF p_list_entries_rec.TITLE = FND_API.g_miss_char THEN
    x_complete_rec.TITLE := l_listentries_rec.TITLE;
 END IF;


 IF p_list_entries_rec.USAGE_RESTRICTION = FND_API.g_miss_char THEN
    x_complete_rec.USAGE_RESTRICTION := l_listentries_rec.USAGE_RESTRICTION;
 END IF;


 IF p_list_entries_rec.ZIPCODE = FND_API.g_miss_char THEN
    x_complete_rec.ZIPCODE := l_listentries_rec.ZIPCODE;
 END IF;


 IF p_list_entries_rec.CURR_CP_COUNTRY_CODE = FND_API.g_miss_char THEN
    x_complete_rec.CURR_CP_COUNTRY_CODE := l_listentries_rec.CURR_CP_COUNTRY_CODE;
 END IF;


 IF p_list_entries_rec.CURR_CP_PHONE_NUMBER = FND_API.g_miss_char  THEN
    x_complete_rec.CURR_CP_PHONE_NUMBER := l_listentries_rec.CURR_CP_PHONE_NUMBER;
 END IF;


 IF p_list_entries_rec.CURR_CP_RAW_PHONE_NUMBER = FND_API.g_miss_char  THEN
    x_complete_rec.CURR_CP_RAW_PHONE_NUMBER := l_listentries_rec.CURR_CP_RAW_PHONE_NUMBER;
 END IF;


 IF p_list_entries_rec.CURR_CP_AREA_CODE = FND_API.g_miss_num  THEN
    x_complete_rec.CURR_CP_AREA_CODE := l_listentries_rec.CURR_CP_AREA_CODE;
 END IF;


 IF p_list_entries_rec.CURR_CP_ID = FND_API.g_miss_num  THEN
    x_complete_rec.CURR_CP_ID := l_listentries_rec.CURR_CP_ID;
 END IF;


 IF p_list_entries_rec.CURR_CP_INDEX = FND_API.g_miss_num  THEN
    x_complete_rec.CURR_CP_INDEX := l_listentries_rec.CURR_CP_INDEX;
 END IF;


 IF p_list_entries_rec.CURR_CP_TIME_ZONE = FND_API.g_miss_num  THEN
    x_complete_rec.CURR_CP_TIME_ZONE := l_listentries_rec.CURR_CP_TIME_ZONE;
 END IF;


 IF p_list_entries_rec.CURR_CP_TIME_ZONE_AUX = FND_API.g_miss_num  THEN
    x_complete_rec.CURR_CP_TIME_ZONE_AUX := l_listentries_rec.CURR_CP_TIME_ZONE_AUX;
 END IF;


 IF p_list_entries_rec.IMP_SOURCE_LINE_ID = FND_API.g_miss_num  THEN
    x_complete_rec.IMP_SOURCE_LINE_ID := l_listentries_rec.IMP_SOURCE_LINE_ID;
 END IF;


 IF p_list_entries_rec.NEXT_CALL_TIME = FND_API.g_miss_date THEN
    x_complete_rec.NEXT_CALL_TIME := l_listentries_rec.NEXT_CALL_TIME;
 END IF;


 IF p_list_entries_rec.RECORD_RELEASE_TIME = FND_API.g_miss_date THEN
    x_complete_rec.RECORD_RELEASE_TIME := l_listentries_rec.RECORD_RELEASE_TIME;
 END IF;
 IF p_list_entries_rec.PARTY_ID = FND_API.g_miss_num THEN
     x_complete_rec.PARTY_ID := l_listentries_rec.PARTY_ID;
 END IF;
 IF p_list_entries_rec.PARENT_PARTY_ID = FND_API.g_miss_num THEN
     x_complete_rec.PARENT_PARTY_ID := l_listentries_rec.PARENT_PARTY_ID;
 END IF;

 IF p_list_entries_rec.group_code = FND_API.g_miss_char THEN
     x_complete_rec.group_code := l_listentries_rec.group_code;
 END IF;

 IF p_list_entries_rec.newly_updated_flag = FND_API.g_miss_char THEN
     x_complete_rec.newly_updated_flag := l_listentries_rec.newly_updated_flag;
 END IF;
 IF p_list_entries_rec.outcome_id = FND_API.g_miss_num THEN
     x_complete_rec.outcome_id := l_listentries_rec.outcome_id;
 END IF;
 IF p_list_entries_rec.reason_id = FND_API.g_miss_num THEN
     x_complete_rec.reason_id := l_listentries_rec.reason_id;
 END IF;
 IF p_list_entries_rec.result_id = FND_API.g_miss_num THEN
     x_complete_rec.result_id := l_listentries_rec.result_id;
 END IF;
 IF p_list_entries_rec.notes = FND_API.g_miss_char THEN
     x_complete_rec.notes := l_listentries_rec.notes;
 END IF;
 IF p_list_entries_rec.VEHICLE_RESPONSE_CODE = FND_API.g_miss_char THEN
     x_complete_rec.VEHICLE_RESPONSE_CODE := l_listentries_rec.VEHICLE_RESPONSE_CODE;
 END IF;
 IF p_list_entries_rec.SALES_AGENT_EMAIL_ADDRESS = FND_API.g_miss_char THEN
     x_complete_rec.SALES_AGENT_EMAIL_ADDRESS := l_listentries_rec.SALES_AGENT_EMAIL_ADDRESS;
 END IF;
 IF p_list_entries_rec.RESOURCE_ID = FND_API.g_miss_num THEN
     x_complete_rec.RESOURCE_ID := l_listentries_rec.RESOURCE_ID;
 END IF;
 IF p_list_entries_rec.location_id = FND_API.g_miss_num THEN
     x_complete_rec.location_id := l_listentries_rec.location_id;
 END IF;
 IF p_list_entries_rec.contact_point_id = FND_API.g_miss_num THEN
     x_complete_rec.contact_point_id := l_listentries_rec.contact_point_id;
 END IF;
 IF p_list_entries_rec.last_contacted_date = FND_API.g_miss_date THEN
    x_complete_rec.last_contacted_date := l_listentries_rec.last_contacted_date;
 END IF;
END Complete_list_entries_Rec;

-- Hint: Primary key needs to be returned.
PROCEDURE Create_List_Entries
(
  p_api_version_number      IN   NUMBER,
  p_init_msg_list           IN   VARCHAR2     := FND_API.G_FALSE,
  p_commit                  IN   VARCHAR2     := FND_API.G_FALSE,
  p_validation_level        IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
  x_return_status           OUT NOCOPY  VARCHAR2,
  x_msg_count               OUT NOCOPY  NUMBER,
  x_msg_data                OUT NOCOPY  VARCHAR2,
  p_list_entries_rec        IN   list_entries_rec_type
                                  := g_miss_list_entries_rec,
  x_list_entry_id           OUT NOCOPY  NUMBER
) IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_List_Entries';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_LIST_ENTRY_ID             NUMBER;
   l_dummy                     NUMBER;

   l_created_by                NUMBER;  --batoleti added this var. For bug# 6688996

   CURSOR c_id IS
      SELECT AMS_LIST_ENTRIES_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1 FROM dual
      WHERE EXISTS (SELECT 1 FROM AMS_LIST_ENTRIES
                    WHERE LIST_ENTRY_ID = l_id);

/* batoleti. Bug# 6688996. Added the below cursor */
    CURSOR cur_get_created_by (x_list_header_id IN NUMBER) IS
      SELECT created_by
      FROM ams_list_headers_all
      WHERE list_header_id= x_list_header_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_List_Entries_PVT;

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

   IF p_list_entries_rec.LIST_ENTRY_ID IS NULL
      OR
      p_list_entries_rec.LIST_ENTRY_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_LIST_ENTRY_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_LIST_ENTRY_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   END IF;
   x_list_entry_id := l_list_entry_id;

   -- =========================================================================
   -- Validate Environment
   -- =========================================================================

   IF FND_GLOBAL.User_Id IS NULL THEN
      AMS_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF ( p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
      -- Debug message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: Validate_List_Entries');
      END IF;

      -- Invoke validation procedures
      Validate_list_entries(
         p_api_version_number     => 1.0,
         p_init_msg_list    => FND_API.G_FALSE,
         p_validation_level => p_validation_level,
	 p_validation_mode => JTF_PLSQL_API.g_create,
         p_list_entries_rec  =>  p_list_entries_rec,
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data);
   END IF;

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message('Private API: After Validate' );

      END IF;
   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: After Validate failed'   );
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;


   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
   END IF;

      -- batoleti  coding starts for bug# 6688996
      l_created_by := 0;

       OPEN cur_get_created_by(p_list_entries_rec.list_header_id);

       FETCH cur_get_created_by INTO l_created_by;
       CLOSE cur_get_created_by;

   -- batoleti  coding ends for bug# 6688996


   -- Invoke table handler(AMS_LIST_ENTRIES_PKG.Insert_Row)
   AMS_LIST_ENTRIES_PKG.Insert_Row(
      px_list_entry_id  => l_list_entry_id,
      p_list_header_id  => p_list_entries_rec.list_header_id,
      p_last_update_date  => SYSDATE,
      p_last_updated_by  => FND_GLOBAL.USER_ID,
      p_creation_date  => SYSDATE,
      p_created_by  => nvl(l_created_by, FND_GLOBAL.USER_ID),
      p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
      px_object_version_number  => l_object_version_number,
      p_list_select_action_id  => p_list_entries_rec.list_select_action_id,
      p_arc_list_select_action_from  => p_list_entries_rec.arc_list_select_action_from,
      p_list_select_action_from_name  => p_list_entries_rec.list_select_action_from_name,
      p_source_code  => p_list_entries_rec.source_code,
      p_arc_list_used_by_source  => p_list_entries_rec.arc_list_used_by_source,
      p_source_code_for_id  => p_list_entries_rec.source_code_for_id,
      p_pin_code  => l_list_entry_id,
      p_list_entry_source_system_id  => p_list_entries_rec.list_entry_source_system_id,
      p_list_entry_source_system_tp  => p_list_entries_rec.list_entry_source_system_type,
      p_view_application_id  => p_list_entries_rec.view_application_id,
      p_manually_entered_flag  => p_list_entries_rec.manually_entered_flag,
      p_marked_as_duplicate_flag  => p_list_entries_rec.marked_as_duplicate_flag,
      p_marked_as_random_flag  => p_list_entries_rec.marked_as_random_flag,
      p_part_of_control_group_flag  => p_list_entries_rec.part_of_control_group_flag,
      p_exclude_in_triggered_list_fg  => p_list_entries_rec.exclude_in_triggered_list_flag,
      p_enabled_flag  => p_list_entries_rec.enabled_flag,
      p_cell_code  => p_list_entries_rec.cell_code,
      p_dedupe_key  => p_list_entries_rec.dedupe_key,
      p_randomly_generated_number  => p_list_entries_rec.randomly_generated_number,
      p_campaign_id  => p_list_entries_rec.campaign_id,
      p_media_id  => p_list_entries_rec.media_id,
      p_channel_id  => p_list_entries_rec.channel_id,
      p_channel_schedule_id  => p_list_entries_rec.channel_schedule_id,
      p_event_offer_id  => p_list_entries_rec.event_offer_id,
      p_customer_id  => p_list_entries_rec.customer_id,
      p_market_segment_id  => p_list_entries_rec.market_segment_id,
      p_vendor_id  => p_list_entries_rec.vendor_id,
      p_transfer_flag  => p_list_entries_rec.transfer_flag,
      p_transfer_status  => p_list_entries_rec.transfer_status,
      p_list_source  => p_list_entries_rec.list_source,
      p_duplicate_master_entry_id  => p_list_entries_rec.duplicate_master_entry_id,
      p_marked_flag  => p_list_entries_rec.marked_flag,
      p_lead_id  => p_list_entries_rec.lead_id,
      p_letter_id  => p_list_entries_rec.letter_id,
      p_picking_header_id  => p_list_entries_rec.picking_header_id,
      p_batch_id  => p_list_entries_rec.batch_id,
      p_suffix  => p_list_entries_rec.suffix,
      p_first_name  => p_list_entries_rec.first_name,
      p_last_name  => p_list_entries_rec.last_name,
      p_customer_name  => p_list_entries_rec.customer_name,
      p_title  => p_list_entries_rec.title,
      p_address_line1  => p_list_entries_rec.address_line1,
      p_address_line2  => p_list_entries_rec.address_line2,
      p_city  => p_list_entries_rec.city,
      p_state  => p_list_entries_rec.state,
      p_zipcode  => p_list_entries_rec.zipcode,
      p_country  => p_list_entries_rec.country,
      p_fax  => p_list_entries_rec.fax,
      p_phone  => p_list_entries_rec.phone,
      p_email_address  => p_list_entries_rec.email_address,
      p_col1  => p_list_entries_rec.col1,
      p_col2  => p_list_entries_rec.col2,
      p_col3  => p_list_entries_rec.col3,
      p_col4  => p_list_entries_rec.col4,
      p_col5  => p_list_entries_rec.col5,
      p_col6  => p_list_entries_rec.col6,
      p_col7  => p_list_entries_rec.col7,
      p_col8  => p_list_entries_rec.col8,
      p_col9  => p_list_entries_rec.col9,
      p_col10  => p_list_entries_rec.col10,
      p_col11  => p_list_entries_rec.col11,
      p_col12  => p_list_entries_rec.col12,
      p_col13  => p_list_entries_rec.col13,
      p_col14  => p_list_entries_rec.col14,
      p_col15  => p_list_entries_rec.col15,
      p_col16  => p_list_entries_rec.col16,
      p_col17  => p_list_entries_rec.col17,
      p_col18  => p_list_entries_rec.col18,
      p_col19  => p_list_entries_rec.col19,
      p_col20  => p_list_entries_rec.col20,
      p_col21  => p_list_entries_rec.col21,
      p_col22  => p_list_entries_rec.col22,
      p_col23  => p_list_entries_rec.col23,
      p_col24  => p_list_entries_rec.col24,
      p_col25  => p_list_entries_rec.col25,
      p_col26  => p_list_entries_rec.col26,
      p_col27  => p_list_entries_rec.col27,
      p_col28  => p_list_entries_rec.col28,
      p_col29  => p_list_entries_rec.col29,
      p_col30  => p_list_entries_rec.col30,
      p_col31  => p_list_entries_rec.col31,
      p_col32  => p_list_entries_rec.col32,
      p_col33  => p_list_entries_rec.col33,
      p_col34  => p_list_entries_rec.col34,
      p_col35  => p_list_entries_rec.col35,
      p_col36  => p_list_entries_rec.col36,
      p_col37  => p_list_entries_rec.col37,
      p_col38  => p_list_entries_rec.col38,
      p_col39  => p_list_entries_rec.col39,
      p_col40  => p_list_entries_rec.col40,
      p_col41  => p_list_entries_rec.col41,
      p_col42  => p_list_entries_rec.col42,
      p_col43  => p_list_entries_rec.col43,
      p_col44  => p_list_entries_rec.col44,
      p_col45  => p_list_entries_rec.col45,
      p_col46  => p_list_entries_rec.col46,
      p_col47  => p_list_entries_rec.col47,
      p_col48  => p_list_entries_rec.col48,
      p_col49  => p_list_entries_rec.col49,
      p_col50  => p_list_entries_rec.col50,
      p_col51  => p_list_entries_rec.col51,
      p_col52  => p_list_entries_rec.col52,
      p_col53  => p_list_entries_rec.col53,
      p_col54  => p_list_entries_rec.col54,
      p_col55  => p_list_entries_rec.col55,
      p_col56  => p_list_entries_rec.col56,
      p_col57  => p_list_entries_rec.col57,
      p_col58  => p_list_entries_rec.col58,
      p_col59  => p_list_entries_rec.col59,
      p_col60  => p_list_entries_rec.col60,
      p_col61  => p_list_entries_rec.col61,
      p_col62  => p_list_entries_rec.col62,
      p_col63  => p_list_entries_rec.col63,
      p_col64  => p_list_entries_rec.col64,
      p_col65  => p_list_entries_rec.col65,
      p_col66  => p_list_entries_rec.col66,
      p_col67  => p_list_entries_rec.col67,
      p_col68  => p_list_entries_rec.col68,
      p_col69  => p_list_entries_rec.col69,
      p_col70  => p_list_entries_rec.col70,
      p_col71  => p_list_entries_rec.col71,
      p_col72  => p_list_entries_rec.col72,
      p_col73  => p_list_entries_rec.col73,
      p_col74  => p_list_entries_rec.col74,
      p_col75  => p_list_entries_rec.col75,
      p_col76  => p_list_entries_rec.col76,
      p_col77  => p_list_entries_rec.col77,
      p_col78  => p_list_entries_rec.col78,
      p_col79  => p_list_entries_rec.col79,
      p_col80  => p_list_entries_rec.col80,
      p_col81  => p_list_entries_rec.col81,
      p_col82  => p_list_entries_rec.col82,
      p_col83  => p_list_entries_rec.col83,
      p_col84  => p_list_entries_rec.col84,
      p_col85  => p_list_entries_rec.col85,
      p_col86  => p_list_entries_rec.col86,
      p_col87  => p_list_entries_rec.col87,
      p_col88  => p_list_entries_rec.col88,
      p_col89  => p_list_entries_rec.col89,
      p_col90  => p_list_entries_rec.col90,
      p_col91  => p_list_entries_rec.col91,
      p_col92  => p_list_entries_rec.col92,
      p_col93  => p_list_entries_rec.col93,
      p_col94  => p_list_entries_rec.col94,
      p_col95  => p_list_entries_rec.col95,
      p_col96  => p_list_entries_rec.col96,
      p_col97  => p_list_entries_rec.col97,
      p_col98  => p_list_entries_rec.col98,
      p_col99  => p_list_entries_rec.col99,
      p_col100  => p_list_entries_rec.col100,
      p_col101  => p_list_entries_rec.col101,
      p_col102  => p_list_entries_rec.col102,
      p_col103  => p_list_entries_rec.col103,
      p_col104  => p_list_entries_rec.col104,
      p_col105  => p_list_entries_rec.col105,
      p_col106  => p_list_entries_rec.col106,
      p_col107  => p_list_entries_rec.col107,
      p_col108  => p_list_entries_rec.col108,
      p_col109  => p_list_entries_rec.col109,
      p_col110  => p_list_entries_rec.col110,
      p_col111  => p_list_entries_rec.col111,
      p_col112  => p_list_entries_rec.col112,
      p_col113  => p_list_entries_rec.col113,
      p_col114  => p_list_entries_rec.col114,
      p_col115  => p_list_entries_rec.col115,
      p_col116  => p_list_entries_rec.col116,
      p_col117  => p_list_entries_rec.col117,
      p_col118  => p_list_entries_rec.col118,
      p_col119  => p_list_entries_rec.col119,
      p_col120  => p_list_entries_rec.col120,
      p_col121  => p_list_entries_rec.col121,
      p_col122  => p_list_entries_rec.col122,
      p_col123  => p_list_entries_rec.col123,
      p_col124  => p_list_entries_rec.col124,
      p_col125  => p_list_entries_rec.col125,
      p_col126  => p_list_entries_rec.col126,
      p_col127  => p_list_entries_rec.col127,
      p_col128  => p_list_entries_rec.col128,
      p_col129  => p_list_entries_rec.col129,
      p_col130  => p_list_entries_rec.col130,
      p_col131  => p_list_entries_rec.col131,
      p_col132  => p_list_entries_rec.col132,
      p_col133  => p_list_entries_rec.col133,
      p_col134  => p_list_entries_rec.col134,
      p_col135  => p_list_entries_rec.col135,
      p_col136  => p_list_entries_rec.col136,
      p_col137  => p_list_entries_rec.col137,
      p_col138  => p_list_entries_rec.col138,
      p_col139  => p_list_entries_rec.col139,
      p_col140  => p_list_entries_rec.col140,
      p_col141  => p_list_entries_rec.col141,
      p_col142  => p_list_entries_rec.col142,
      p_col143  => p_list_entries_rec.col143,
      p_col144  => p_list_entries_rec.col144,
      p_col145  => p_list_entries_rec.col145,
      p_col146  => p_list_entries_rec.col146,
      p_col147  => p_list_entries_rec.col147,
      p_col148  => p_list_entries_rec.col148,
      p_col149  => p_list_entries_rec.col149,
      p_col150  => p_list_entries_rec.col150,
      p_col151  => p_list_entries_rec.col151,
      p_col152  => p_list_entries_rec.col152,
      p_col153  => p_list_entries_rec.col153,
      p_col154  => p_list_entries_rec.col154,
      p_col155  => p_list_entries_rec.col155,
      p_col156  => p_list_entries_rec.col156,
      p_col157  => p_list_entries_rec.col157,
      p_col158  => p_list_entries_rec.col158,
      p_col159  => p_list_entries_rec.col159,
      p_col160  => p_list_entries_rec.col160,
      p_col161  => p_list_entries_rec.col161,
      p_col162  => p_list_entries_rec.col162,
      p_col163  => p_list_entries_rec.col163,
      p_col164  => p_list_entries_rec.col164,
      p_col165  => p_list_entries_rec.col165,
      p_col166  => p_list_entries_rec.col166,
      p_col167  => p_list_entries_rec.col167,
      p_col168  => p_list_entries_rec.col168,
      p_col169  => p_list_entries_rec.col169,
      p_col170  => p_list_entries_rec.col170,
      p_col171  => p_list_entries_rec.col171,
      p_col172  => p_list_entries_rec.col172,
      p_col173  => p_list_entries_rec.col173,
      p_col174  => p_list_entries_rec.col174,
      p_col175  => p_list_entries_rec.col175,
      p_col176  => p_list_entries_rec.col176,
      p_col177  => p_list_entries_rec.col177,
      p_col178  => p_list_entries_rec.col178,
      p_col179  => p_list_entries_rec.col179,
      p_col180  => p_list_entries_rec.col180,
      p_col181  => p_list_entries_rec.col181,
      p_col182  => p_list_entries_rec.col182,
      p_col183  => p_list_entries_rec.col183,
      p_col184  => p_list_entries_rec.col184,
      p_col185  => p_list_entries_rec.col185,
      p_col186  => p_list_entries_rec.col186,
      p_col187  => p_list_entries_rec.col187,
      p_col188  => p_list_entries_rec.col188,
      p_col189  => p_list_entries_rec.col189,
      p_col190  => p_list_entries_rec.col190,
      p_col191  => p_list_entries_rec.col191,
      p_col192  => p_list_entries_rec.col192,
      p_col193  => p_list_entries_rec.col193,
      p_col194  => p_list_entries_rec.col194,
      p_col195  => p_list_entries_rec.col195,
      p_col196  => p_list_entries_rec.col196,
      p_col197  => p_list_entries_rec.col197,
      p_col198  => p_list_entries_rec.col198,
      p_col199  => p_list_entries_rec.col199,
      p_col200  => p_list_entries_rec.col200,
      p_col201  => p_list_entries_rec.col201,
      p_col202  => p_list_entries_rec.col202,
      p_col203  => p_list_entries_rec.col203,
      p_col204  => p_list_entries_rec.col204,
      p_col205  => p_list_entries_rec.col205,
      p_col206  => p_list_entries_rec.col206,
      p_col207  => p_list_entries_rec.col207,
      p_col208  => p_list_entries_rec.col208,
      p_col209  => p_list_entries_rec.col209,
      p_col210  => p_list_entries_rec.col210,
      p_col211  => p_list_entries_rec.col211,
      p_col212  => p_list_entries_rec.col212,
      p_col213  => p_list_entries_rec.col213,
      p_col214  => p_list_entries_rec.col214,
      p_col215  => p_list_entries_rec.col215,
      p_col216  => p_list_entries_rec.col216,
      p_col217  => p_list_entries_rec.col217,
      p_col218  => p_list_entries_rec.col218,
      p_col219  => p_list_entries_rec.col219,
      p_col220  => p_list_entries_rec.col220,
      p_col221  => p_list_entries_rec.col221,
      p_col222  => p_list_entries_rec.col222,
      p_col223  => p_list_entries_rec.col223,
      p_col224  => p_list_entries_rec.col224,
      p_col225  => p_list_entries_rec.col225,
      p_col226  => p_list_entries_rec.col226,
      p_col227  => p_list_entries_rec.col227,
      p_col228  => p_list_entries_rec.col228,
      p_col229  => p_list_entries_rec.col229,
      p_col230  => p_list_entries_rec.col230,
      p_col231  => p_list_entries_rec.col231,
      p_col232  => p_list_entries_rec.col232,
      p_col233  => p_list_entries_rec.col233,
      p_col234  => p_list_entries_rec.col234,
      p_col235  => p_list_entries_rec.col235,
      p_col236  => p_list_entries_rec.col236,
      p_col237  => p_list_entries_rec.col237,
      p_col238  => p_list_entries_rec.col238,
      p_col239  => p_list_entries_rec.col239,
      p_col240  => p_list_entries_rec.col240,
      p_col241  => p_list_entries_rec.col241,
      p_col242  => p_list_entries_rec.col242,
      p_col243  => p_list_entries_rec.col243,
      p_col244  => p_list_entries_rec.col244,
      p_col245  => p_list_entries_rec.col245,
      p_col246  => p_list_entries_rec.col246,
      p_col247  => p_list_entries_rec.col247,
      p_col248  => p_list_entries_rec.col248,
      p_col249  => p_list_entries_rec.col249,
      p_col250  => p_list_entries_rec.col250,
      p_col251  => p_list_entries_rec.col251,
      p_col252  => p_list_entries_rec.col252,
      p_col253  => p_list_entries_rec.col253,
      p_col254  => p_list_entries_rec.col254,
      p_col255  => p_list_entries_rec.col255,
      p_col256  => p_list_entries_rec.col256,
      p_col257  => p_list_entries_rec.col257,
      p_col258  => p_list_entries_rec.col258,
      p_col259  => p_list_entries_rec.col259,
      p_col260  => p_list_entries_rec.col260,
      p_col261  => p_list_entries_rec.col261,
      p_col262  => p_list_entries_rec.col262,
      p_col263  => p_list_entries_rec.col263,
      p_col264  => p_list_entries_rec.col264,
      p_col265  => p_list_entries_rec.col265,
      p_col266  => p_list_entries_rec.col266,
      p_col267  => p_list_entries_rec.col267,
      p_col268  => p_list_entries_rec.col268,
      p_col269  => p_list_entries_rec.col269,
      p_col270  => p_list_entries_rec.col270,
      p_col271  => p_list_entries_rec.col271,
      p_col272  => p_list_entries_rec.col272,
      p_col273  => p_list_entries_rec.col273,
      p_col274  => p_list_entries_rec.col274,
      p_col275  => p_list_entries_rec.col275,
      p_col276  => p_list_entries_rec.col276,
      p_col277  => p_list_entries_rec.col277,
      p_col278  => p_list_entries_rec.col278,
      p_col279  => p_list_entries_rec.col279,
      p_col280  => p_list_entries_rec.col280,
      p_col281  => p_list_entries_rec.col281,
      p_col282  => p_list_entries_rec.col282,
      p_col283  => p_list_entries_rec.col283,
      p_col284  => p_list_entries_rec.col284,
      p_col285  => p_list_entries_rec.col285,
      p_col286  => p_list_entries_rec.col286,
      p_col287  => p_list_entries_rec.col287,
      p_col288  => p_list_entries_rec.col288,
      p_col289  => p_list_entries_rec.col289,
      p_col290  => p_list_entries_rec.col290,
      p_col291  => p_list_entries_rec.col291,
      p_col292  => p_list_entries_rec.col292,
      p_col293  => p_list_entries_rec.col293,
      p_col294  => p_list_entries_rec.col294,
      p_col295  => p_list_entries_rec.col295,
      p_col296  => p_list_entries_rec.col296,
      p_col297  => p_list_entries_rec.col297,
      p_col298  => p_list_entries_rec.col298,
      p_col299  => p_list_entries_rec.col299,
      p_col300  => p_list_entries_rec.col300,
      p_party_id  => p_list_entries_rec.party_id,
      p_parent_party_id  => p_list_entries_rec.parent_party_id,
      p_imp_source_line_id  => p_list_entries_rec.imp_source_line_id,
      p_usage_restriction  => p_list_entries_rec.usage_restriction,
      p_next_call_time  => p_list_entries_rec.next_call_time,
      p_callback_flag  => p_list_entries_rec.callback_flag,
      p_do_not_use_flag  => p_list_entries_rec.do_not_use_flag,
      p_do_not_use_reason  => p_list_entries_rec.do_not_use_reason,
      p_record_out_flag  => p_list_entries_rec.record_out_flag,
      p_record_release_time  => p_list_entries_rec.record_release_time,
      p_group_code => p_list_entries_rec.group_code,
      p_newly_updated_flag => p_list_entries_rec.newly_updated_flag,
      p_outcome_id => p_list_entries_rec.outcome_id,
      p_result_id => p_list_entries_rec.result_id ,
      p_reason_id => p_list_entries_rec.reason_id,
      p_notes =>  p_list_entries_rec.notes ,
      p_VEHICLE_RESPONSE_CODE => p_list_entries_rec.VEHICLE_RESPONSE_CODE ,
      p_SALES_AGENT_EMAIL_ADDRESS => p_list_entries_rec.SALES_AGENT_EMAIL_ADDRESS ,
      p_RESOURCE_ID  => p_list_entries_rec.RESOURCE_ID ,
      p_LOCATION_ID       => p_list_entries_rec.location_id,
      p_CONTACT_POINT_ID  => p_list_entries_rec.contact_point_id,
      p_last_contacted_date  => p_list_entries_rec.last_contacted_date
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
     ROLLBACK TO CREATE_List_Entries_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_List_Entries_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_List_Entries_PVT;
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
End Create_List_Entries;


PROCEDURE Update_List_Entries
(
   p_api_version_number         IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
   p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2,
   p_list_entries_rec               IN    list_entries_rec_type,
   x_object_version_number      OUT NOCOPY  NUMBER
) IS
CURSOR c_get_list_entries(lc_list_entry_id NUMBER) IS
    SELECT *
    FROM  AMS_LIST_ENTRIES
    WHERE list_entry_id = lc_list_entry_id ;
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_List_Entries';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_LIST_ENTRY_ID    NUMBER;
l_ref_list_entries_rec  c_get_List_Entries%ROWTYPE ;
l_tar_list_entries_rec  AMS_List_Entries_PVT.list_entries_rec_type := P_list_entries_rec;
l_rowid  ROWID;
x_list_entries_rec        AMS_List_Entries_PVT.list_entries_rec_type ;

l_created_by                NUMBER;  --batoleti added this var. For bug# 6688996

/* batoleti. Bug# 6688996. Added the below cursor */
    CURSOR cur_get_created_by (x_list_header_id IN NUMBER) IS
      SELECT created_by
      FROM ams_list_headers_all
      WHERE list_header_id= x_list_header_id;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_List_Entries_PVT;

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

      OPEN c_get_List_Entries( l_tar_list_entries_rec.list_entry_id);

      FETCH c_get_List_Entries INTO l_ref_list_entries_rec  ;

       If ( c_get_List_Entries%NOTFOUND) THEN
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'List_Entries' || P_list_entries_rec.list_entry_id) ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_List_Entries;


      If (l_tar_list_entries_rec.object_version_number is NULL or
          l_tar_list_entries_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'object_version_number') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_list_entries_rec.object_version_number <> l_ref_list_entries_rec.object_version_number) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'List_Entries') ;
          raise FND_API.G_EXC_ERROR;
      End if;
       Complete_list_entries_Rec (
        P_list_entries_rec    =>  P_list_entries_rec     ,
        x_complete_rec       =>  x_list_entries_rec        );

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_List_Entries');
          END IF;

          -- Invoke validation procedures
          Validate_list_entries(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
	    p_validation_mode => JTF_PLSQL_API.g_update,
            p_list_entries_rec  =>  x_list_entries_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message

         -- batoleti  coding starts for bug# 6688996
      l_created_by := 0;

       OPEN cur_get_created_by(x_list_entries_rec.list_header_id);

       FETCH cur_get_created_by INTO l_created_by;
       CLOSE cur_get_created_by;

   -- batoleti  coding ends for bug# 6688996


      -- Invoke table handler(AMS_LIST_ENTRIES_PKG.Update_Row)
      AMS_LIST_ENTRIES_PKG.Update_Row(
          p_list_entry_id  => x_list_entries_rec.list_entry_id,
          p_list_header_id  => x_list_entries_rec.list_header_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => nvl(l_created_by, FND_GLOBAL.USER_ID),
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          p_object_version_number  => x_list_entries_rec.object_version_number,
          p_list_select_action_id  => x_list_entries_rec.list_select_action_id,
          p_arc_list_select_action_from  => x_list_entries_rec.arc_list_select_action_from,
          p_list_select_action_from_name  => x_list_entries_rec.list_select_action_from_name,
          p_source_code  => x_list_entries_rec.source_code,
          p_arc_list_used_by_source  => x_list_entries_rec.arc_list_used_by_source,
          p_source_code_for_id  => x_list_entries_rec.source_code_for_id,
          p_pin_code  => x_list_entries_rec.pin_code,
          p_list_entry_source_system_id  => x_list_entries_rec.list_entry_source_system_id,
          p_list_entry_source_system_tp  => x_list_entries_rec.list_entry_source_system_type,
          p_view_application_id  => x_list_entries_rec.view_application_id,
          p_manually_entered_flag  => x_list_entries_rec.manually_entered_flag,
          p_marked_as_duplicate_flag  => x_list_entries_rec.marked_as_duplicate_flag,
          p_marked_as_random_flag  => x_list_entries_rec.marked_as_random_flag,
          p_part_of_control_group_flag  => x_list_entries_rec.part_of_control_group_flag,
          p_exclude_in_triggered_list_fg  => x_list_entries_rec.exclude_in_triggered_list_flag,
          p_enabled_flag  => x_list_entries_rec.enabled_flag,
          p_cell_code  => x_list_entries_rec.cell_code,
          p_dedupe_key  => x_list_entries_rec.dedupe_key,
          p_randomly_generated_number  => x_list_entries_rec.randomly_generated_number,
          p_campaign_id  => x_list_entries_rec.campaign_id,
          p_media_id  => x_list_entries_rec.media_id,
          p_channel_id  => x_list_entries_rec.channel_id,
          p_channel_schedule_id  => x_list_entries_rec.channel_schedule_id,
          p_event_offer_id  => x_list_entries_rec.event_offer_id,
          p_customer_id  => x_list_entries_rec.customer_id,
          p_market_segment_id  => x_list_entries_rec.market_segment_id,
          p_vendor_id  => x_list_entries_rec.vendor_id,
          p_transfer_flag  => x_list_entries_rec.transfer_flag,
          p_transfer_status  => x_list_entries_rec.transfer_status,
          p_list_source  => x_list_entries_rec.list_source,
          p_duplicate_master_entry_id  => x_list_entries_rec.duplicate_master_entry_id,
          p_marked_flag  => x_list_entries_rec.marked_flag,
          p_lead_id  => x_list_entries_rec.lead_id,
          p_letter_id  => x_list_entries_rec.letter_id,
          p_picking_header_id  => x_list_entries_rec.picking_header_id,
          p_batch_id  => x_list_entries_rec.batch_id,
          p_suffix  => x_list_entries_rec.suffix,
          p_first_name  => x_list_entries_rec.first_name,
          p_last_name  => x_list_entries_rec.last_name,
          p_customer_name  => x_list_entries_rec.customer_name,
          p_title  => x_list_entries_rec.title,
          p_address_line1  => x_list_entries_rec.address_line1,
          p_address_line2  => x_list_entries_rec.address_line2,
          p_city  => x_list_entries_rec.city,
          p_state  => x_list_entries_rec.state,
          p_zipcode  => x_list_entries_rec.zipcode,
          p_country  => x_list_entries_rec.country,
          p_fax  => x_list_entries_rec.fax,
          p_phone  => x_list_entries_rec.phone,
          p_email_address  => x_list_entries_rec.email_address,
          p_col1  => x_list_entries_rec.col1,
          p_col2  => x_list_entries_rec.col2,
          p_col3  => x_list_entries_rec.col3,
          p_col4  => x_list_entries_rec.col4,
          p_col5  => x_list_entries_rec.col5,
          p_col6  => x_list_entries_rec.col6,
          p_col7  => x_list_entries_rec.col7,
          p_col8  => x_list_entries_rec.col8,
          p_col9  => x_list_entries_rec.col9,
          p_col10  => x_list_entries_rec.col10,
          p_col11  => x_list_entries_rec.col11,
          p_col12  => x_list_entries_rec.col12,
          p_col13  => x_list_entries_rec.col13,
          p_col14  => x_list_entries_rec.col14,
          p_col15  => x_list_entries_rec.col15,
          p_col16  => x_list_entries_rec.col16,
          p_col17  => x_list_entries_rec.col17,
          p_col18  => x_list_entries_rec.col18,
          p_col19  => x_list_entries_rec.col19,
          p_col20  => x_list_entries_rec.col20,
          p_col21  => x_list_entries_rec.col21,
          p_col22  => x_list_entries_rec.col22,
          p_col23  => x_list_entries_rec.col23,
          p_col24  => x_list_entries_rec.col24,
          p_col25  => x_list_entries_rec.col25,
          p_col26  => x_list_entries_rec.col26,
          p_col27  => x_list_entries_rec.col27,
          p_col28  => x_list_entries_rec.col28,
          p_col29  => x_list_entries_rec.col29,
          p_col30  => x_list_entries_rec.col30,
          p_col31  => x_list_entries_rec.col31,
          p_col32  => x_list_entries_rec.col32,
          p_col33  => x_list_entries_rec.col33,
          p_col34  => x_list_entries_rec.col34,
          p_col35  => x_list_entries_rec.col35,
          p_col36  => x_list_entries_rec.col36,
          p_col37  => x_list_entries_rec.col37,
          p_col38  => x_list_entries_rec.col38,
          p_col39  => x_list_entries_rec.col39,
          p_col40  => x_list_entries_rec.col40,
          p_col41  => x_list_entries_rec.col41,
          p_col42  => x_list_entries_rec.col42,
          p_col43  => x_list_entries_rec.col43,
          p_col44  => x_list_entries_rec.col44,
          p_col45  => x_list_entries_rec.col45,
          p_col46  => x_list_entries_rec.col46,
          p_col47  => x_list_entries_rec.col47,
          p_col48  => x_list_entries_rec.col48,
          p_col49  => x_list_entries_rec.col49,
          p_col50  => x_list_entries_rec.col50,
          p_col51  => x_list_entries_rec.col51,
          p_col52  => x_list_entries_rec.col52,
          p_col53  => x_list_entries_rec.col53,
          p_col54  => x_list_entries_rec.col54,
          p_col55  => x_list_entries_rec.col55,
          p_col56  => x_list_entries_rec.col56,
          p_col57  => x_list_entries_rec.col57,
          p_col58  => x_list_entries_rec.col58,
          p_col59  => x_list_entries_rec.col59,
          p_col60  => x_list_entries_rec.col60,
          p_col61  => x_list_entries_rec.col61,
          p_col62  => x_list_entries_rec.col62,
          p_col63  => x_list_entries_rec.col63,
          p_col64  => x_list_entries_rec.col64,
          p_col65  => x_list_entries_rec.col65,
          p_col66  => x_list_entries_rec.col66,
          p_col67  => x_list_entries_rec.col67,
          p_col68  => x_list_entries_rec.col68,
          p_col69  => x_list_entries_rec.col69,
          p_col70  => x_list_entries_rec.col70,
          p_col71  => x_list_entries_rec.col71,
          p_col72  => x_list_entries_rec.col72,
          p_col73  => x_list_entries_rec.col73,
          p_col74  => x_list_entries_rec.col74,
          p_col75  => x_list_entries_rec.col75,
          p_col76  => x_list_entries_rec.col76,
          p_col77  => x_list_entries_rec.col77,
          p_col78  => x_list_entries_rec.col78,
          p_col79  => x_list_entries_rec.col79,
          p_col80  => x_list_entries_rec.col80,
          p_col81  => x_list_entries_rec.col81,
          p_col82  => x_list_entries_rec.col82,
          p_col83  => x_list_entries_rec.col83,
          p_col84  => x_list_entries_rec.col84,
          p_col85  => x_list_entries_rec.col85,
          p_col86  => x_list_entries_rec.col86,
          p_col87  => x_list_entries_rec.col87,
          p_col88  => x_list_entries_rec.col88,
          p_col89  => x_list_entries_rec.col89,
          p_col90  => x_list_entries_rec.col90,
          p_col91  => x_list_entries_rec.col91,
          p_col92  => x_list_entries_rec.col92,
          p_col93  => x_list_entries_rec.col93,
          p_col94  => x_list_entries_rec.col94,
          p_col95  => x_list_entries_rec.col95,
          p_col96  => x_list_entries_rec.col96,
          p_col97  => x_list_entries_rec.col97,
          p_col98  => x_list_entries_rec.col98,
          p_col99  => x_list_entries_rec.col99,
          p_col100  => x_list_entries_rec.col100,
          p_col101  => x_list_entries_rec.col101,
          p_col102  => x_list_entries_rec.col102,
          p_col103  => x_list_entries_rec.col103,
          p_col104  => x_list_entries_rec.col104,
          p_col105  => x_list_entries_rec.col105,
          p_col106  => x_list_entries_rec.col106,
          p_col107  => x_list_entries_rec.col107,
          p_col108  => x_list_entries_rec.col108,
          p_col109  => x_list_entries_rec.col109,
          p_col110  => x_list_entries_rec.col110,
          p_col111  => x_list_entries_rec.col111,
          p_col112  => x_list_entries_rec.col112,
          p_col113  => x_list_entries_rec.col113,
          p_col114  => x_list_entries_rec.col114,
          p_col115  => x_list_entries_rec.col115,
          p_col116  => x_list_entries_rec.col116,
          p_col117  => x_list_entries_rec.col117,
          p_col118  => x_list_entries_rec.col118,
          p_col119  => x_list_entries_rec.col119,
          p_col120  => x_list_entries_rec.col120,
          p_col121  => x_list_entries_rec.col121,
          p_col122  => x_list_entries_rec.col122,
          p_col123  => x_list_entries_rec.col123,
          p_col124  => x_list_entries_rec.col124,
          p_col125  => x_list_entries_rec.col125,
          p_col126  => x_list_entries_rec.col126,
          p_col127  => x_list_entries_rec.col127,
          p_col128  => x_list_entries_rec.col128,
          p_col129  => x_list_entries_rec.col129,
          p_col130  => x_list_entries_rec.col130,
          p_col131  => x_list_entries_rec.col131,
          p_col132  => x_list_entries_rec.col132,
          p_col133  => x_list_entries_rec.col133,
          p_col134  => x_list_entries_rec.col134,
          p_col135  => x_list_entries_rec.col135,
          p_col136  => x_list_entries_rec.col136,
          p_col137  => x_list_entries_rec.col137,
          p_col138  => x_list_entries_rec.col138,
          p_col139  => x_list_entries_rec.col139,
          p_col140  => x_list_entries_rec.col140,
          p_col141  => x_list_entries_rec.col141,
          p_col142  => x_list_entries_rec.col142,
          p_col143  => x_list_entries_rec.col143,
          p_col144  => x_list_entries_rec.col144,
          p_col145  => x_list_entries_rec.col145,
          p_col146  => x_list_entries_rec.col146,
          p_col147  => x_list_entries_rec.col147,
          p_col148  => x_list_entries_rec.col148,
          p_col149  => x_list_entries_rec.col149,
          p_col150  => x_list_entries_rec.col150,
          p_col151  => x_list_entries_rec.col151,
          p_col152  => x_list_entries_rec.col152,
          p_col153  => x_list_entries_rec.col153,
          p_col154  => x_list_entries_rec.col154,
          p_col155  => x_list_entries_rec.col155,
          p_col156  => x_list_entries_rec.col156,
          p_col157  => x_list_entries_rec.col157,
          p_col158  => x_list_entries_rec.col158,
          p_col159  => x_list_entries_rec.col159,
          p_col160  => x_list_entries_rec.col160,
          p_col161  => x_list_entries_rec.col161,
          p_col162  => x_list_entries_rec.col162,
          p_col163  => x_list_entries_rec.col163,
          p_col164  => x_list_entries_rec.col164,
          p_col165  => x_list_entries_rec.col165,
          p_col166  => x_list_entries_rec.col166,
          p_col167  => x_list_entries_rec.col167,
          p_col168  => x_list_entries_rec.col168,
          p_col169  => x_list_entries_rec.col169,
          p_col170  => x_list_entries_rec.col170,
          p_col171  => x_list_entries_rec.col171,
          p_col172  => x_list_entries_rec.col172,
          p_col173  => x_list_entries_rec.col173,
          p_col174  => x_list_entries_rec.col174,
          p_col175  => x_list_entries_rec.col175,
          p_col176  => x_list_entries_rec.col176,
          p_col177  => x_list_entries_rec.col177,
          p_col178  => x_list_entries_rec.col178,
          p_col179  => x_list_entries_rec.col179,
          p_col180  => x_list_entries_rec.col180,
          p_col181  => x_list_entries_rec.col181,
          p_col182  => x_list_entries_rec.col182,
          p_col183  => x_list_entries_rec.col183,
          p_col184  => x_list_entries_rec.col184,
          p_col185  => x_list_entries_rec.col185,
          p_col186  => x_list_entries_rec.col186,
          p_col187  => x_list_entries_rec.col187,
          p_col188  => x_list_entries_rec.col188,
          p_col189  => x_list_entries_rec.col189,
          p_col190  => x_list_entries_rec.col190,
          p_col191  => x_list_entries_rec.col191,
          p_col192  => x_list_entries_rec.col192,
          p_col193  => x_list_entries_rec.col193,
          p_col194  => x_list_entries_rec.col194,
          p_col195  => x_list_entries_rec.col195,
          p_col196  => x_list_entries_rec.col196,
          p_col197  => x_list_entries_rec.col197,
          p_col198  => x_list_entries_rec.col198,
          p_col199  => x_list_entries_rec.col199,
          p_col200  => x_list_entries_rec.col200,
          p_col201  => p_list_entries_rec.col201,
          p_col202  => p_list_entries_rec.col202,
          p_col203  => p_list_entries_rec.col203,
          p_col204  => p_list_entries_rec.col204,
          p_col205  => p_list_entries_rec.col205,
          p_col206  => p_list_entries_rec.col206,
          p_col207  => p_list_entries_rec.col207,
          p_col208  => p_list_entries_rec.col208,
          p_col209  => p_list_entries_rec.col209,
          p_col210  => p_list_entries_rec.col210,
          p_col211  => p_list_entries_rec.col211,
          p_col212  => p_list_entries_rec.col212,
          p_col213  => p_list_entries_rec.col213,
          p_col214  => p_list_entries_rec.col214,
          p_col215  => p_list_entries_rec.col215,
          p_col216  => p_list_entries_rec.col216,
          p_col217  => p_list_entries_rec.col217,
          p_col218  => p_list_entries_rec.col218,
          p_col219  => p_list_entries_rec.col219,
          p_col220  => p_list_entries_rec.col220,
          p_col221  => p_list_entries_rec.col221,
          p_col222  => p_list_entries_rec.col222,
          p_col223  => p_list_entries_rec.col223,
          p_col224  => p_list_entries_rec.col224,
          p_col225  => p_list_entries_rec.col225,
          p_col226  => p_list_entries_rec.col226,
          p_col227  => p_list_entries_rec.col227,
          p_col228  => p_list_entries_rec.col228,
          p_col229  => p_list_entries_rec.col229,
          p_col230  => p_list_entries_rec.col230,
          p_col231  => p_list_entries_rec.col231,
          p_col232  => p_list_entries_rec.col232,
          p_col233  => p_list_entries_rec.col233,
          p_col234  => p_list_entries_rec.col234,
          p_col235  => p_list_entries_rec.col235,
          p_col236  => p_list_entries_rec.col236,
          p_col237  => p_list_entries_rec.col237,
          p_col238  => p_list_entries_rec.col238,
          p_col239  => p_list_entries_rec.col239,
          p_col240  => p_list_entries_rec.col240,
          p_col241  => p_list_entries_rec.col241,
          p_col242  => p_list_entries_rec.col242,
          p_col243  => p_list_entries_rec.col243,
          p_col244  => p_list_entries_rec.col244,
          p_col245  => p_list_entries_rec.col245,
          p_col246  => p_list_entries_rec.col246,
          p_col247  => p_list_entries_rec.col247,
          p_col248  => p_list_entries_rec.col248,
          p_col249  => p_list_entries_rec.col249,
          p_col250  => p_list_entries_rec.col250,
          p_col251  => p_list_entries_rec.col251,
          p_col252  => p_list_entries_rec.col252,
          p_col253  => p_list_entries_rec.col253,
          p_col254  => p_list_entries_rec.col254,
          p_col255  => p_list_entries_rec.col255,
          p_col256  => p_list_entries_rec.col256,
          p_col257  => p_list_entries_rec.col257,
          p_col258  => p_list_entries_rec.col258,
          p_col259  => p_list_entries_rec.col259,
          p_col260  => p_list_entries_rec.col260,
          p_col261  => p_list_entries_rec.col261,
          p_col262  => p_list_entries_rec.col262,
	  p_col263  => p_list_entries_rec.col263,
          p_col264  => p_list_entries_rec.col264,
          p_col265  => p_list_entries_rec.col265,
          p_col266  => p_list_entries_rec.col266,
          p_col267  => p_list_entries_rec.col267,
          p_col268  => p_list_entries_rec.col268,
          p_col269  => p_list_entries_rec.col269,
          p_col270  => p_list_entries_rec.col270,
          p_col271  => p_list_entries_rec.col271,
          p_col272  => p_list_entries_rec.col272,
          p_col273  => p_list_entries_rec.col273,
          p_col274  => p_list_entries_rec.col274,
          p_col275  => p_list_entries_rec.col275,
          p_col276  => p_list_entries_rec.col276,
          p_col277  => p_list_entries_rec.col277,
          p_col278  => p_list_entries_rec.col278,
          p_col279  => p_list_entries_rec.col279,
          p_col280  => p_list_entries_rec.col280,
          p_col281  => p_list_entries_rec.col281,
          p_col282  => p_list_entries_rec.col282,
          p_col283  => p_list_entries_rec.col283,
          p_col284  => p_list_entries_rec.col284,
          p_col285  => p_list_entries_rec.col285,
          p_col286  => p_list_entries_rec.col286,
          p_col287  => p_list_entries_rec.col287,
          p_col288  => p_list_entries_rec.col288,
          p_col289  => p_list_entries_rec.col289,
          p_col290  => p_list_entries_rec.col290,
          p_col291  => p_list_entries_rec.col291,
          p_col292  => p_list_entries_rec.col292,
          p_col293  => p_list_entries_rec.col293,
          p_col294  => p_list_entries_rec.col294,
          p_col295  => p_list_entries_rec.col295,
          p_col296  => p_list_entries_rec.col296,
          p_col297  => p_list_entries_rec.col297,
          p_col298  => p_list_entries_rec.col298,
          p_col299  => p_list_entries_rec.col299,
          p_col300  => p_list_entries_rec.col300,
          p_party_id  => x_list_entries_rec.party_id,
          p_parent_party_id  => x_list_entries_rec.parent_party_id,
          --p_geometry  => x_list_entries_rec.geometry,
          p_imp_source_line_id  => x_list_entries_rec.imp_source_line_id,
          p_usage_restriction  => x_list_entries_rec.usage_restriction,
          p_next_call_time  => x_list_entries_rec.next_call_time,
          p_callback_flag  => x_list_entries_rec.callback_flag,
          p_do_not_use_flag  => x_list_entries_rec.do_not_use_flag,
          p_do_not_use_reason  => x_list_entries_rec.do_not_use_reason,
          p_record_out_flag  => x_list_entries_rec.record_out_flag,
          p_record_release_time  => x_list_entries_rec.record_release_time,
          p_group_code => p_list_entries_rec.group_code,
          p_newly_updated_flag => p_list_entries_rec.newly_updated_flag,
          p_outcome_id => p_list_entries_rec.outcome_id,
          p_result_id => p_list_entries_rec.result_id ,
          p_reason_id => p_list_entries_rec.reason_id,
      p_notes =>  p_list_entries_rec.notes ,
      p_VEHICLE_RESPONSE_CODE => p_list_entries_rec.VEHICLE_RESPONSE_CODE ,
      p_SALES_AGENT_EMAIL_ADDRESS => p_list_entries_rec.SALES_AGENT_EMAIL_ADDRESS ,
      p_RESOURCE_ID  => p_list_entries_rec.RESOURCE_ID ,
      p_LOCATION_ID       => p_list_entries_rec.location_id,
      p_CONTACT_POINT_ID  => p_list_entries_rec.contact_point_id,
      p_last_contacted_date => p_list_entries_rec.last_contacted_date
	  );
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
     ROLLBACK TO UPDATE_List_Entries_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_List_Entries_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_List_Entries_PVT;
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
End Update_List_Entries;


PROCEDURE Delete_List_Entries(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_list_entry_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_List_Entries';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_List_Entries_PVT;

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

      -- Invoke table handler(AMS_LIST_ENTRIES_PKG.Delete_Row)
      AMS_LIST_ENTRIES_PKG.Delete_Row(
          p_LIST_ENTRY_ID  => p_LIST_ENTRY_ID);
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
     ROLLBACK TO DELETE_List_Entries_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_List_Entries_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_List_Entries_PVT;
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
End Delete_List_Entries;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_List_Entries(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_list_entry_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_List_Entries';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_LIST_ENTRY_ID                  NUMBER;

CURSOR c_List_Entries IS
   SELECT LIST_ENTRY_ID
   FROM AMS_LIST_ENTRIES
   WHERE LIST_ENTRY_ID = p_LIST_ENTRY_ID
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
  OPEN c_List_Entries;

  FETCH c_List_Entries INTO l_LIST_ENTRY_ID;

  IF (c_List_Entries%NOTFOUND) THEN
    CLOSE c_List_Entries;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_List_Entries;

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
     ROLLBACK TO LOCK_List_Entries_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_List_Entries_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_List_Entries_PVT;
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
End Lock_List_Entries;


PROCEDURE check_list_entries_uk_items(
    p_list_entries_rec               IN   list_entries_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_LIST_ENTRIES',
         'LIST_ENTRY_ID = ''' || p_list_entries_rec.LIST_ENTRY_ID ||''''
         );
      ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_LIST_ENTRIES',
         'LIST_ENTRY_ID = ''' || p_list_entries_rec.LIST_ENTRY_ID ||
         ''' AND LIST_ENTRY_ID <> ' || p_list_entries_rec.LIST_ENTRY_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_LIST_ENTRY_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

END check_list_entries_uk_items;

PROCEDURE check_list_entries_req_items(
    p_list_entries_rec               IN  list_entries_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_list_entries_rec.list_header_id = FND_API.g_miss_num OR p_list_entries_rec.list_header_id IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'list_header_id');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.list_select_action_id = FND_API.g_miss_num OR p_list_entries_rec.list_select_action_id IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'list_select_action_id');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.arc_list_select_action_from = FND_API.g_miss_char OR p_list_entries_rec.arc_list_select_action_from IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'arc_list_select_action_from');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.list_select_action_from_name = FND_API.g_miss_char OR p_list_entries_rec.list_select_action_from_name IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'list_select_action_from_name');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.source_code = FND_API.g_miss_char OR p_list_entries_rec.source_code IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'source_code');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.arc_list_used_by_source = FND_API.g_miss_char OR p_list_entries_rec.arc_list_used_by_source IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'arc_list_used_by_source');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.source_code_for_id = FND_API.g_miss_num OR p_list_entries_rec.source_code_for_id IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'source_code_for_id');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      -- no validation for creation, pin_code uses list_entry_id
      /*
      IF p_list_entries_rec.pin_code = FND_API.g_miss_char OR p_list_entries_rec.pin_code IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'pin_code');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      */

      IF p_list_entries_rec.list_entry_source_system_id = FND_API.g_miss_num OR p_list_entries_rec.list_entry_source_system_id IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'list_entry_source_system_id');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.list_entry_source_system_type = FND_API.g_miss_char OR p_list_entries_rec.list_entry_source_system_type IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'list_entry_source_system_type');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.view_application_id = FND_API.g_miss_num OR p_list_entries_rec.view_application_id IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'view_application_id');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.manually_entered_flag = FND_API.g_miss_char OR p_list_entries_rec.manually_entered_flag IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'manually_entered_flag');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.marked_as_duplicate_flag = FND_API.g_miss_char OR p_list_entries_rec.marked_as_duplicate_flag IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'marked_as_duplicate_flag');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.marked_as_random_flag = FND_API.g_miss_char OR p_list_entries_rec.marked_as_random_flag IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'marked_as_random_flag');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.part_of_control_group_flag = FND_API.g_miss_char OR p_list_entries_rec.part_of_control_group_flag IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'part_of_control_group_flag');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.exclude_in_triggered_list_flag = FND_API.g_miss_char OR p_list_entries_rec.exclude_in_triggered_list_flag IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'exclude_in_triggered_list_flag');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.enabled_flag = FND_API.g_miss_char OR p_list_entries_rec.enabled_flag IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'enabled_flag');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   ELSE


      IF p_list_entries_rec.list_entry_id IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'list_entry_id');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.list_header_id IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'list_header_id');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.last_update_date IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.last_updated_by IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.creation_date IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'creation_date');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.created_by IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'created_by');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.list_select_action_id IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'list_select_action_id');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.arc_list_select_action_from IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'arc_list_select_action_from');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.list_select_action_from_name IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'list_select_action_from_name');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.source_code IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'source_code');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.arc_list_used_by_source IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'arc_list_used_by_source');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.source_code_for_id IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'source_code_for_id');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_list_entries_rec.pin_code IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'pin_code');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.list_entry_source_system_id IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'list_entry_source_system_id');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.list_entry_source_system_type IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'list_entry_source_system_type');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.view_application_id IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'view_application_id');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.manually_entered_flag IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'manually_entered_flag');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.marked_as_duplicate_flag IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'marked_as_duplicate_flag');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.marked_as_random_flag IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'marked_as_random_flag');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.part_of_control_group_flag IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'part_of_control_group_flag');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.exclude_in_triggered_list_flag IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'exclude_in_triggered_list_flag');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_list_entries_rec.enabled_flag IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'enabled_flag');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

END check_list_entries_req_items;

PROCEDURE check_list_entries_FK_items(
    p_list_entries_rec IN list_entries_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_list_entries_FK_items;

PROCEDURE check_list_entries_Lookup_item(
    p_list_entries_rec IN list_entries_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_list_entries_Lookup_item;

PROCEDURE check_list_entries_Business(
    p_list_entries_rec IN list_entries_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
l_dummy varchar2(1);
cursor check_outcome (cur_outcome_id number)
is
select 'x'
from jtf_ih_outcomes_vl
where outcome_id = cur_outcome_id ;
cursor check_result (cur_outcome_id number, cur_result_id number)
is
select 'x'
from jtf_ih_outcome_results
where outcome_id = cur_outcome_id
and result_id = cur_result_id;
cursor check_reason (cur_reason_id number, cur_result_id number)
is
select 'x'
from jtf_ih_result_reasons
where reason_id = cur_reason_id
and result_id = cur_result_id;

l varchar2(40);
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF ( p_list_entries_rec.newly_updated_flag = 'Y' OR
        p_list_entries_rec.newly_updated_flag = 'N' OR
	p_list_entries_rec.newly_updated_flag is NULL OR
	p_list_entries_rec.newly_updated_flag  = fnd_api.g_miss_char
      )
   THEN
     null;
   else
        AMS_Utility_PVT.Error_Message('AMS_API_INVALID_FLAG','INVALID_FLAG','newly_updated_flag');
        x_return_status := FND_API.g_ret_sts_error;
   END IF;

   IF ( p_list_entries_rec.manually_entered_flag = 'Y' OR
        p_list_entries_rec.manually_entered_flag = 'N' OR
	p_list_entries_rec.manually_entered_flag is NULL OR
	p_list_entries_rec.manually_entered_flag  = fnd_api.g_miss_char
      )
   THEN
     null;
   else
        AMS_Utility_PVT.Error_Message('AMS_API_INVALID_FLAG','INVALID_FLAG','manually_entered_flag');
        x_return_status := FND_API.g_ret_sts_error;
   END IF;

   IF ( p_list_entries_rec.marked_as_duplicate_flag = 'Y' OR
        p_list_entries_rec.marked_as_duplicate_flag = 'N' OR
	p_list_entries_rec.marked_as_duplicate_flag is NULL OR
	p_list_entries_rec.marked_as_duplicate_flag  = fnd_api.g_miss_char
      )
   THEN
     null;
   else
        AMS_Utility_PVT.Error_Message('AMS_API_INVALID_FLAG','INVALID_FLAG','marked_as_duplicate_flag');
        x_return_status := FND_API.g_ret_sts_error;
   END IF;

   IF ( p_list_entries_rec.marked_as_random_flag = 'Y' OR
        p_list_entries_rec.marked_as_random_flag = 'N' OR
	p_list_entries_rec.marked_as_random_flag is NULL OR
	p_list_entries_rec.marked_as_random_flag  = fnd_api.g_miss_char
      )
   THEN
     null;
   else
        AMS_Utility_PVT.Error_Message('AMS_API_INVALID_FLAG','INVALID_FLAG','marked_as_random_flag');
        x_return_status := FND_API.g_ret_sts_error;
   END IF;

   IF ( p_list_entries_rec.part_of_control_group_flag = 'Y' OR
        p_list_entries_rec.part_of_control_group_flag = 'N' OR
	p_list_entries_rec.part_of_control_group_flag is NULL OR
	p_list_entries_rec.part_of_control_group_flag  = fnd_api.g_miss_char
      )
   THEN
     null;
   else
        AMS_Utility_PVT.Error_Message('AMS_API_INVALID_FLAG','INVALID_FLAG','part_of_control_group_flag');
        x_return_status := FND_API.g_ret_sts_error;
   END IF;

   IF ( p_list_entries_rec.exclude_in_triggered_list_flag = 'Y' OR
        p_list_entries_rec.exclude_in_triggered_list_flag = 'N' OR
	p_list_entries_rec.exclude_in_triggered_list_flag is NULL OR
	p_list_entries_rec.exclude_in_triggered_list_flag  = fnd_api.g_miss_char
      )
   THEN
     null;
   else
        AMS_Utility_PVT.Error_Message('AMS_API_INVALID_FLAG','INVALID_FLAG','exclude_in_triggered_list_flag');
        x_return_status := FND_API.g_ret_sts_error;
   END IF;

   IF ( p_list_entries_rec.enabled_flag = 'Y' OR
        p_list_entries_rec.enabled_flag = 'N' OR
	p_list_entries_rec.enabled_flag is NULL OR
	p_list_entries_rec.enabled_flag  = fnd_api.g_miss_char
      )
   THEN
     null;
   else
        AMS_Utility_PVT.Error_Message('AMS_API_INVALID_FLAG','INVALID_FLAG','enabled_flag');
        x_return_status := FND_API.g_ret_sts_error;
   END IF;

   IF ( p_list_entries_rec.outcome_id is not null AND
        p_list_entries_rec.outcome_id <> FND_API.g_miss_num) THEN
       open check_outcome(p_list_entries_rec.outcome_id);
       fetch check_outcome into l_dummy;
       if check_outcome%notfound then
           AMS_Utility_PVT.Error_Message(p_message_name=>'AMS_BAD_OUTCOME_ID');
           x_return_status := FND_API.g_ret_sts_error;
	   return;
       end if;
       close check_outcome;
   END IF;
   IF ( p_list_entries_rec.result_id is NOT NULL   AND
        p_list_entries_rec.result_id <> FND_API.g_miss_num) THEN
       open check_result(p_list_entries_rec.outcome_id,p_list_entries_rec.result_id);
       fetch check_result into l_dummy;
       if check_result%notfound then
           AMS_Utility_PVT.Error_Message(p_message_name=>'AMS_BAD_RESULT_ID');
           x_return_status := FND_API.g_ret_sts_error;
	   return;
       end if;
       close check_result;
   END IF;
   IF ( p_list_entries_rec.reason_id is NOT NULL  AND
        p_list_entries_rec.reason_id <> fnd_api.g_miss_num) THEN
       open check_reason(p_list_entries_rec.reason_id,p_list_entries_rec.result_id);
       fetch check_reason into l_dummy;
       if check_reason%notfound then
           AMS_Utility_PVT.Error_Message(p_message_name=>'AMS_BAD_REASON_ID');
           x_return_status := FND_API.g_ret_sts_error;
	   return;
       end if;
       close check_reason;
   END IF;


END check_list_entries_Business;

PROCEDURE Check_list_entries_Items (
    P_list_entries_rec     IN    list_entries_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_list_entries_uk_items(
      p_list_entries_rec => p_list_entries_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_list_entries_req_items(
      p_list_entries_rec => p_list_entries_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   check_list_entries_FK_items(
      p_list_entries_rec => p_list_entries_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

   check_list_entries_Lookup_item(
      p_list_entries_rec => p_list_entries_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message('Private API: ' || 'before check_list_entries_Business');

   END IF;
   check_list_entries_Business(
      p_list_entries_rec => p_list_entries_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || 'after check_list_entries_Business');
   END IF;

END Check_list_entries_Items;


PROCEDURE Validate_list_entries(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_validation_mode            IN   VARCHAR2     := JTF_PLSQL_API.g_update,
    p_list_entries_rec           IN   list_entries_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_List_Entries';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_list_entries_rec  AMS_List_Entries_PVT.list_entries_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_List_Entries_;

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
              Check_list_entries_Items(
                 p_list_entries_rec        => p_list_entries_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('complete rec');
      END IF;
         Validate_list_entries_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_list_entries_rec           =>    l_list_entries_rec);

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
     ROLLBACK TO VALIDATE_List_Entries_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_List_Entries_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_List_Entries_;
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
End Validate_List_Entries;


PROCEDURE Validate_list_entries_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_list_entries_rec               IN    list_entries_rec_type
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
END Validate_list_entries_Rec;

PROCEDURE init_entry_rec(
   x_entry_rec         OUT NOCOPY list_entries_rec_type
) IS

Begin
 x_entry_rec.LIST_ENTRY_ID                   := FND_API.g_miss_num;
 x_entry_rec.LIST_HEADER_ID                  := FND_API.g_miss_num;
 x_entry_rec.LAST_UPDATE_DATE                := FND_API.g_miss_date;
 x_entry_rec.LAST_UPDATED_BY                 := FND_API.g_miss_num;
 x_entry_rec.CREATION_DATE                   := FND_API.g_miss_date;
 x_entry_rec.CREATED_BY                      := FND_API.g_miss_num;
 x_entry_rec.LAST_UPDATE_LOGIN               := FND_API.g_miss_num;
 x_entry_rec.OBJECT_VERSION_NUMBER           := FND_API.g_miss_num;
 x_entry_rec.LIST_SELECT_ACTION_ID           := FND_API.g_miss_num;
 x_entry_rec.ARC_LIST_SELECT_ACTION_FROM     := FND_API.g_miss_char;
 x_entry_rec.LIST_SELECT_ACTION_FROM_NAME    := FND_API.g_miss_char;
 x_entry_rec.SOURCE_CODE                     := FND_API.g_miss_char;
 x_entry_rec.SOURCE_CODE_FOR_ID              := FND_API.g_miss_num;
 x_entry_rec.ARC_LIST_USED_BY_SOURCE         := FND_API.g_miss_char;
 x_entry_rec.PIN_CODE                        := FND_API.g_miss_char;
 x_entry_rec.LIST_ENTRY_SOURCE_SYSTEM_ID     := FND_API.g_miss_num;
 x_entry_rec.LIST_ENTRY_SOURCE_SYSTEM_TYPE   := FND_API.g_miss_char;
 x_entry_rec.VIEW_APPLICATION_ID             := FND_API.g_miss_num;
 x_entry_rec.MANUALLY_ENTERED_FLAG           := FND_API.g_miss_char;
 x_entry_rec.MARKED_AS_DUPLICATE_FLAG        := FND_API.g_miss_char;
 x_entry_rec.MARKED_AS_RANDOM_FLAG           := FND_API.g_miss_char;
 x_entry_rec.PART_OF_CONTROL_GROUP_FLAG      := FND_API.g_miss_char;
 x_entry_rec.EXCLUDE_IN_TRIGGERED_LIST_FLAG  := FND_API.g_miss_char;
 x_entry_rec.ENABLED_FLAG                    := FND_API.g_miss_char;
 x_entry_rec.CELL_CODE                       := FND_API.g_miss_char;
 x_entry_rec.DEDUPE_KEY                      := FND_API.g_miss_char;

 x_entry_rec.RANDOMLY_GENERATED_NUMBER       := FND_API.g_miss_num;
 x_entry_rec.CAMPAIGN_ID                     := FND_API.g_miss_num;
 x_entry_rec.MEDIA_ID                        := FND_API.g_miss_num;
 x_entry_rec.CHANNEL_ID                      := FND_API.g_miss_num;
 x_entry_rec.CHANNEL_SCHEDULE_ID             := FND_API.g_miss_num;
 x_entry_rec.EVENT_OFFER_ID                  := FND_API.g_miss_num;
 x_entry_rec.CUSTOMER_ID                     := FND_API.g_miss_num;
 x_entry_rec.MARKET_SEGMENT_ID               := FND_API.g_miss_num;
 x_entry_rec.VENDOR_ID                       := FND_API.g_miss_num;
 x_entry_rec.TRANSFER_FLAG                   := FND_API.g_miss_char;
 x_entry_rec.TRANSFER_STATUS                 := FND_API.g_miss_char;
 x_entry_rec.LIST_SOURCE                     := FND_API.g_miss_char;
 x_entry_rec.DUPLICATE_MASTER_ENTRY_ID       := FND_API.g_miss_num;
 x_entry_rec.MARKED_FLAG                     := FND_API.g_miss_char;
 x_entry_rec.LEAD_ID                         := FND_API.g_miss_num;
 x_entry_rec.LETTER_ID                       := FND_API.g_miss_num;
 x_entry_rec.PICKING_HEADER_ID               := FND_API.g_miss_num;
 x_entry_rec.BATCH_ID                        := FND_API.g_miss_num;


 x_entry_rec.COL1                            := FND_API.g_miss_char;
 x_entry_rec.COL2                            := FND_API.g_miss_char;
 x_entry_rec.COL3                            := FND_API.g_miss_char;
 x_entry_rec.COL4                            := FND_API.g_miss_char;
 x_entry_rec.COL5                            := FND_API.g_miss_char;
 x_entry_rec.COL6                            := FND_API.g_miss_char;
 x_entry_rec.COL7                            := FND_API.g_miss_char;
 x_entry_rec.COL8                            := FND_API.g_miss_char;
 x_entry_rec.COL9                            := FND_API.g_miss_char;
 x_entry_rec.COL10                           := FND_API.g_miss_char;
 x_entry_rec.COL11                           := FND_API.g_miss_char;
 x_entry_rec.COL12                           := FND_API.g_miss_char;
 x_entry_rec.COL13                           := FND_API.g_miss_char;
 x_entry_rec.COL14                           := FND_API.g_miss_char;
 x_entry_rec.COL15                           := FND_API.g_miss_char;
 x_entry_rec.COL16                           := FND_API.g_miss_char;
 x_entry_rec.COL17                           := FND_API.g_miss_char;
 x_entry_rec.COL18                           := FND_API.g_miss_char;
 x_entry_rec.COL19                           := FND_API.g_miss_char;
 x_entry_rec.COL20                           := FND_API.g_miss_char;
 x_entry_rec.COL21                           := FND_API.g_miss_char;
 x_entry_rec.COL22                           := FND_API.g_miss_char;
 x_entry_rec.COL23                           := FND_API.g_miss_char;
 x_entry_rec.COL24                           := FND_API.g_miss_char;
 x_entry_rec.COL25                           := FND_API.g_miss_char;
 x_entry_rec.COL26                           := FND_API.g_miss_char;
 x_entry_rec.COL27                           := FND_API.g_miss_char;
 x_entry_rec.COL28                           := FND_API.g_miss_char;
 x_entry_rec.COL29                           := FND_API.g_miss_char;
 x_entry_rec.COL30                           := FND_API.g_miss_char;
 x_entry_rec.COL31                           := FND_API.g_miss_char;
 x_entry_rec.COL32                           := FND_API.g_miss_char;
 x_entry_rec.COL33                           := FND_API.g_miss_char;
 x_entry_rec.COL34                           := FND_API.g_miss_char;
 x_entry_rec.COL35                           := FND_API.g_miss_char;
 x_entry_rec.COL36                           := FND_API.g_miss_char;
 x_entry_rec.COL37                           := FND_API.g_miss_char;
 x_entry_rec.COL38                           := FND_API.g_miss_char;
 x_entry_rec.COL39                           := FND_API.g_miss_char;
 x_entry_rec.COL40                           := FND_API.g_miss_char;
 x_entry_rec.COL41                           := FND_API.g_miss_char;
 x_entry_rec.COL42                           := FND_API.g_miss_char;
 x_entry_rec.COL43                           := FND_API.g_miss_char;
 x_entry_rec.COL44                           := FND_API.g_miss_char;
 x_entry_rec.COL45                           := FND_API.g_miss_char;
 x_entry_rec.COL46                           := FND_API.g_miss_char;
 x_entry_rec.COL47                           := FND_API.g_miss_char;
 x_entry_rec.COL48                           := FND_API.g_miss_char;
 x_entry_rec.COL49                           := FND_API.g_miss_char;
 x_entry_rec.COL50                           := FND_API.g_miss_char;
 x_entry_rec.COL51                           := FND_API.g_miss_char;
 x_entry_rec.COL52                           := FND_API.g_miss_char;
 x_entry_rec.COL53                           := FND_API.g_miss_char;
 x_entry_rec.COL54                           := FND_API.g_miss_char;
 x_entry_rec.COL55                           := FND_API.g_miss_char;
 x_entry_rec.COL56                           := FND_API.g_miss_char;
 x_entry_rec.COL57                           := FND_API.g_miss_char;
 x_entry_rec.COL58                           := FND_API.g_miss_char;
 x_entry_rec.COL59                           := FND_API.g_miss_char;
 x_entry_rec.COL60                           := FND_API.g_miss_char;
 x_entry_rec.COL61                           := FND_API.g_miss_char;
 x_entry_rec.COL62                           := FND_API.g_miss_char;
 x_entry_rec.COL63                           := FND_API.g_miss_char;
 x_entry_rec.COL64                           := FND_API.g_miss_char;
 x_entry_rec.COL65                           := FND_API.g_miss_char;
 x_entry_rec.COL66                           := FND_API.g_miss_char;
 x_entry_rec.COL67                           := FND_API.g_miss_char;
 x_entry_rec.COL68                           := FND_API.g_miss_char;
 x_entry_rec.COL69                           := FND_API.g_miss_char;
 x_entry_rec.COL70                           := FND_API.g_miss_char;
 x_entry_rec.COL71                           := FND_API.g_miss_char;
 x_entry_rec.COL72                           := FND_API.g_miss_char;
 x_entry_rec.COL73                           := FND_API.g_miss_char;
 x_entry_rec.COL74                           := FND_API.g_miss_char;
 x_entry_rec.COL75                           := FND_API.g_miss_char;
 x_entry_rec.COL76                           := FND_API.g_miss_char;
 x_entry_rec.COL77                           := FND_API.g_miss_char;
 x_entry_rec.COL78                           := FND_API.g_miss_char;
 x_entry_rec.COL79                           := FND_API.g_miss_char;
 x_entry_rec.COL80                           := FND_API.g_miss_char;
 x_entry_rec.COL81                           := FND_API.g_miss_char;
 x_entry_rec.COL82                           := FND_API.g_miss_char;
 x_entry_rec.COL83                           := FND_API.g_miss_char;
 x_entry_rec.COL84                           := FND_API.g_miss_char;
 x_entry_rec.COL85                           := FND_API.g_miss_char;
 x_entry_rec.COL86                           := FND_API.g_miss_char;
 x_entry_rec.COL87                           := FND_API.g_miss_char;
 x_entry_rec.COL88                           := FND_API.g_miss_char;
 x_entry_rec.COL89                           := FND_API.g_miss_char;
 x_entry_rec.COL90                           := FND_API.g_miss_char;
 x_entry_rec.COL91                           := FND_API.g_miss_char;
 x_entry_rec.COL92                           := FND_API.g_miss_char;
 x_entry_rec.COL93                           := FND_API.g_miss_char;
 x_entry_rec.COL94                           := FND_API.g_miss_char;
 x_entry_rec.COL95                           := FND_API.g_miss_char;
 x_entry_rec.COL96                           := FND_API.g_miss_char;
 x_entry_rec.COL97                           := FND_API.g_miss_char;
 x_entry_rec.COL98                           := FND_API.g_miss_char;
 x_entry_rec.COL99                           := FND_API.g_miss_char;
 x_entry_rec.COL100                          := FND_API.g_miss_char;
 x_entry_rec.COL101                          := FND_API.g_miss_char;
 x_entry_rec.COL102                          := FND_API.g_miss_char;
 x_entry_rec.COL103                          := FND_API.g_miss_char;
 x_entry_rec.COL104                          := FND_API.g_miss_char;
 x_entry_rec.COL105                          := FND_API.g_miss_char;
 x_entry_rec.COL106                          := FND_API.g_miss_char;
 x_entry_rec.COL107                          := FND_API.g_miss_char;
 x_entry_rec.COL108                          := FND_API.g_miss_char;
 x_entry_rec.COL109                          := FND_API.g_miss_char;
 x_entry_rec.COL110                          := FND_API.g_miss_char;
 x_entry_rec.COL111                          := FND_API.g_miss_char;
 x_entry_rec.COL112                          := FND_API.g_miss_char;
 x_entry_rec.COL113                          := FND_API.g_miss_char;
 x_entry_rec.COL114                          := FND_API.g_miss_char;
 x_entry_rec.COL115                          := FND_API.g_miss_char;
 x_entry_rec.COL116                          := FND_API.g_miss_char;
 x_entry_rec.COL117                          := FND_API.g_miss_char;
 x_entry_rec.COL118                          := FND_API.g_miss_char;
 x_entry_rec.COL119                          := FND_API.g_miss_char;
 x_entry_rec.COL120                          := FND_API.g_miss_char;
 x_entry_rec.COL121                          := FND_API.g_miss_char;
 x_entry_rec.COL122                          := FND_API.g_miss_char;
 x_entry_rec.COL123                          := FND_API.g_miss_char;
 x_entry_rec.COL124                          := FND_API.g_miss_char;
 x_entry_rec.COL125                          := FND_API.g_miss_char;
 x_entry_rec.COL126                          := FND_API.g_miss_char;
 x_entry_rec.COL127                          := FND_API.g_miss_char;
 x_entry_rec.COL128                          := FND_API.g_miss_char;
 x_entry_rec.COL129                          := FND_API.g_miss_char;
 x_entry_rec.COL130                          := FND_API.g_miss_char;
 x_entry_rec.COL131                          := FND_API.g_miss_char;
 x_entry_rec.COL132                          := FND_API.g_miss_char;
 x_entry_rec.COL133                          := FND_API.g_miss_char;
 x_entry_rec.COL134                          := FND_API.g_miss_char;
 x_entry_rec.COL135                          := FND_API.g_miss_char;
 x_entry_rec.COL136                          := FND_API.g_miss_char;
 x_entry_rec.COL137                          := FND_API.g_miss_char;
 x_entry_rec.COL138                          := FND_API.g_miss_char;
 x_entry_rec.COL139                          := FND_API.g_miss_char;
 x_entry_rec.COL140                          := FND_API.g_miss_char;
 x_entry_rec.COL141                          := FND_API.g_miss_char;
 x_entry_rec.COL142                          := FND_API.g_miss_char;
 x_entry_rec.COL143                          := FND_API.g_miss_char;
 x_entry_rec.COL144                          := FND_API.g_miss_char;
 x_entry_rec.COL145                          := FND_API.g_miss_char;
 x_entry_rec.COL146                          := FND_API.g_miss_char;
 x_entry_rec.COL147                          := FND_API.g_miss_char;
 x_entry_rec.COL148                          := FND_API.g_miss_char;
 x_entry_rec.COL149                          := FND_API.g_miss_char;
 x_entry_rec.COL150                          := FND_API.g_miss_char;
 x_entry_rec.COL151                          := FND_API.g_miss_char;
 x_entry_rec.COL152                          := FND_API.g_miss_char;
 x_entry_rec.COL153                          := FND_API.g_miss_char;
 x_entry_rec.COL154                          := FND_API.g_miss_char;
 x_entry_rec.COL155                          := FND_API.g_miss_char;
 x_entry_rec.COL156                          := FND_API.g_miss_char;
 x_entry_rec.COL157                          := FND_API.g_miss_char;
 x_entry_rec.COL158                          := FND_API.g_miss_char;
 x_entry_rec.COL159                          := FND_API.g_miss_char;
 x_entry_rec.COL160                          := FND_API.g_miss_char;
 x_entry_rec.COL161                          := FND_API.g_miss_char;
 x_entry_rec.COL162                          := FND_API.g_miss_char;
 x_entry_rec.COL163                          := FND_API.g_miss_char;
 x_entry_rec.COL164                          := FND_API.g_miss_char;
 x_entry_rec.COL165                          := FND_API.g_miss_char;
 x_entry_rec.COL166                          := FND_API.g_miss_char;
 x_entry_rec.COL167                          := FND_API.g_miss_char;
 x_entry_rec.COL168                          := FND_API.g_miss_char;
 x_entry_rec.COL169                          := FND_API.g_miss_char;
 x_entry_rec.COL170                          := FND_API.g_miss_char;
 x_entry_rec.COL171                          := FND_API.g_miss_char;
 x_entry_rec.COL172                          := FND_API.g_miss_char;
 x_entry_rec.COL173                          := FND_API.g_miss_char;
 x_entry_rec.COL174                          := FND_API.g_miss_char;
 x_entry_rec.COL175                          := FND_API.g_miss_char;
 x_entry_rec.COL176                          := FND_API.g_miss_char;
 x_entry_rec.COL177                          := FND_API.g_miss_char;
 x_entry_rec.COL178                          := FND_API.g_miss_char;
 x_entry_rec.COL179                          := FND_API.g_miss_char;
 x_entry_rec.COL180                          := FND_API.g_miss_char;
 x_entry_rec.COL181                          := FND_API.g_miss_char;
 x_entry_rec.COL182                          := FND_API.g_miss_char;
 x_entry_rec.COL183                          := FND_API.g_miss_char;
 x_entry_rec.COL184                          := FND_API.g_miss_char;
 x_entry_rec.COL185                          := FND_API.g_miss_char;
 x_entry_rec.COL186                          := FND_API.g_miss_char;
 x_entry_rec.COL187                          := FND_API.g_miss_char;
 x_entry_rec.COL188                          := FND_API.g_miss_char;
 x_entry_rec.COL189                          := FND_API.g_miss_char;
 x_entry_rec.COL190                          := FND_API.g_miss_char;
 x_entry_rec.COL191                          := FND_API.g_miss_char;
 x_entry_rec.COL192                          := FND_API.g_miss_char;
 x_entry_rec.COL193                          := FND_API.g_miss_char;
 x_entry_rec.COL194                          := FND_API.g_miss_char;
 x_entry_rec.COL195                          := FND_API.g_miss_char;
 x_entry_rec.COL196                          := FND_API.g_miss_char;
 x_entry_rec.COL197                          := FND_API.g_miss_char;
 x_entry_rec.COL198                          := FND_API.g_miss_char;
 x_entry_rec.COL199                          := FND_API.g_miss_char;
 x_entry_rec.COL200                          := FND_API.g_miss_char;
 x_entry_rec.COL201                          := FND_API.g_miss_char;
 x_entry_rec.COL202                          := FND_API.g_miss_char;
 x_entry_rec.COL203                          := FND_API.g_miss_char;
 x_entry_rec.COL204                          := FND_API.g_miss_char;
 x_entry_rec.COL205                          := FND_API.g_miss_char;
 x_entry_rec.COL206                          := FND_API.g_miss_char;
 x_entry_rec.COL207                          := FND_API.g_miss_char;
 x_entry_rec.COL208                          := FND_API.g_miss_char;
 x_entry_rec.COL209                          := FND_API.g_miss_char;
 x_entry_rec.COL210                          := FND_API.g_miss_char;
 x_entry_rec.COL211                          := FND_API.g_miss_char;
 x_entry_rec.COL212                          := FND_API.g_miss_char;
 x_entry_rec.COL213                          := FND_API.g_miss_char;
 x_entry_rec.COL214                          := FND_API.g_miss_char;
 x_entry_rec.COL215                          := FND_API.g_miss_char;
 x_entry_rec.COL216                          := FND_API.g_miss_char;
 x_entry_rec.COL217                          := FND_API.g_miss_char;
 x_entry_rec.COL218                          := FND_API.g_miss_char;
 x_entry_rec.COL219                          := FND_API.g_miss_char;
 x_entry_rec.COL220                          := FND_API.g_miss_char;
 x_entry_rec.COL221                          := FND_API.g_miss_char;
 x_entry_rec.COL222                          := FND_API.g_miss_char;
 x_entry_rec.COL223                          := FND_API.g_miss_char;
 x_entry_rec.COL224                          := FND_API.g_miss_char;
 x_entry_rec.COL225                          := FND_API.g_miss_char;
 x_entry_rec.COL226                          := FND_API.g_miss_char;
 x_entry_rec.COL227                          := FND_API.g_miss_char;
 x_entry_rec.COL228                          := FND_API.g_miss_char;
 x_entry_rec.COL229                          := FND_API.g_miss_char;
 x_entry_rec.COL230                          := FND_API.g_miss_char;
 x_entry_rec.COL231                          := FND_API.g_miss_char;
 x_entry_rec.COL232                          := FND_API.g_miss_char;
 x_entry_rec.COL233                          := FND_API.g_miss_char;
 x_entry_rec.COL234                          := FND_API.g_miss_char;
 x_entry_rec.COL235                          := FND_API.g_miss_char;
 x_entry_rec.COL236                          := FND_API.g_miss_char;
 x_entry_rec.COL237                          := FND_API.g_miss_char;
 x_entry_rec.COL238                          := FND_API.g_miss_char;
 x_entry_rec.COL239                          := FND_API.g_miss_char;
 x_entry_rec.COL240                          := FND_API.g_miss_char;
 x_entry_rec.COL241                          := FND_API.g_miss_char;
 x_entry_rec.COL242                          := FND_API.g_miss_char;
 x_entry_rec.COL243                          := FND_API.g_miss_char;
 x_entry_rec.COL244                          := FND_API.g_miss_char;
 x_entry_rec.COL245                          := FND_API.g_miss_char;
 x_entry_rec.COL246                          := FND_API.g_miss_char;
 x_entry_rec.COL247                          := FND_API.g_miss_char;
 x_entry_rec.COL248                          := FND_API.g_miss_char;
 x_entry_rec.COL249                          := FND_API.g_miss_char;
 x_entry_rec.COL250                          := FND_API.g_miss_char;
 x_entry_rec.COL251                          := FND_API.g_miss_char;
 x_entry_rec.COL252                          := FND_API.g_miss_char;
 x_entry_rec.COL253                          := FND_API.g_miss_char;
 x_entry_rec.COL254                          := FND_API.g_miss_char;
 x_entry_rec.COL255                          := FND_API.g_miss_char;
 x_entry_rec.COL256                          := FND_API.g_miss_char;
 x_entry_rec.COL257                          := FND_API.g_miss_char;
 x_entry_rec.COL258                          := FND_API.g_miss_char;
 x_entry_rec.COL259                          := FND_API.g_miss_char;
 x_entry_rec.COL260                          := FND_API.g_miss_char;
 x_entry_rec.COL261                          := FND_API.g_miss_char;
 x_entry_rec.COL262                          := FND_API.g_miss_char;
 x_entry_rec.COL263                          := FND_API.g_miss_char;
 x_entry_rec.COL264                          := FND_API.g_miss_char;
 x_entry_rec.COL265                          := FND_API.g_miss_char;
 x_entry_rec.COL266                          := FND_API.g_miss_char;
 x_entry_rec.COL267                          := FND_API.g_miss_char;
 x_entry_rec.COL268                          := FND_API.g_miss_char;
 x_entry_rec.COL269                          := FND_API.g_miss_char;
 x_entry_rec.COL270                          := FND_API.g_miss_char;
 x_entry_rec.COL271                          := FND_API.g_miss_char;
 x_entry_rec.COL272                          := FND_API.g_miss_char;
 x_entry_rec.COL273                          := FND_API.g_miss_char;
 x_entry_rec.COL274                          := FND_API.g_miss_char;
 x_entry_rec.COL275                          := FND_API.g_miss_char;
 x_entry_rec.COL276                          := FND_API.g_miss_char;
 x_entry_rec.COL277                          := FND_API.g_miss_char;
 x_entry_rec.COL278                          := FND_API.g_miss_char;
 x_entry_rec.COL279                          := FND_API.g_miss_char;
 x_entry_rec.COL280                          := FND_API.g_miss_char;
 x_entry_rec.COL281                          := FND_API.g_miss_char;
 x_entry_rec.COL282                          := FND_API.g_miss_char;
 x_entry_rec.COL283                          := FND_API.g_miss_char;
 x_entry_rec.COL284                          := FND_API.g_miss_char;
 x_entry_rec.COL285                          := FND_API.g_miss_char;
 x_entry_rec.COL286                          := FND_API.g_miss_char;
 x_entry_rec.COL287                          := FND_API.g_miss_char;
 x_entry_rec.COL288                          := FND_API.g_miss_char;
 x_entry_rec.COL289                          := FND_API.g_miss_char;
 x_entry_rec.COL290                          := FND_API.g_miss_char;
 x_entry_rec.COL291                          := FND_API.g_miss_char;
 x_entry_rec.COL292                          := FND_API.g_miss_char;
 x_entry_rec.COL293                          := FND_API.g_miss_char;
 x_entry_rec.COL294                          := FND_API.g_miss_char;
 x_entry_rec.COL295                          := FND_API.g_miss_char;
 x_entry_rec.COL296                          := FND_API.g_miss_char;
 x_entry_rec.COL297                          := FND_API.g_miss_char;
 x_entry_rec.COL298                          := FND_API.g_miss_char;
 x_entry_rec.COL299                          := FND_API.g_miss_char;
 x_entry_rec.COL300                          := FND_API.g_miss_char;
 x_entry_rec.first_name                      := FND_API.G_MISS_CHAR;
 x_entry_rec.last_name                       := FND_API.G_MISS_CHAR;
 x_entry_rec.customer_name                   := FND_API.G_MISS_CHAR;
 x_entry_rec.title                           := FND_API.G_MISS_CHAR;
 x_entry_rec.PARTY_ID                        := FND_API.g_miss_num;
 x_entry_rec.ADDRESS_LINE1                   := FND_API.g_miss_char;
 x_entry_rec.ADDRESS_LINE2                   := FND_API.g_miss_char;
 x_entry_rec.CALLBACK_FLAG                   := FND_API.g_miss_char;
 x_entry_rec.CITY                            := FND_API.g_miss_char;
 x_entry_rec.COUNTRY                         := FND_API.g_miss_char;
 x_entry_rec.DO_NOT_USE_FLAG                 := FND_API.g_miss_char;
 x_entry_rec.DO_NOT_USE_REASON               := FND_API.g_miss_char;
 x_entry_rec.EMAIL_ADDRESS                   := FND_API.g_miss_char;
 x_entry_rec.FAX                             := FND_API.g_miss_char;
 x_entry_rec.PHONE                           := FND_API.g_miss_char;
 x_entry_rec.RECORD_OUT_FLAG                 := FND_API.g_miss_char;
 x_entry_rec.STATE                           := FND_API.g_miss_char;
 x_entry_rec.SUFFIX                          := FND_API.g_miss_char;
 x_entry_rec.TITLE                           := FND_API.g_miss_char;
 x_entry_rec.USAGE_RESTRICTION               := FND_API.g_miss_char;
 x_entry_rec.ZIPCODE                         := FND_API.g_miss_char;
 x_entry_rec.CURR_CP_COUNTRY_CODE            := FND_API.g_miss_char;
 x_entry_rec.CURR_CP_PHONE_NUMBER            := FND_API.g_miss_char;
 x_entry_rec.CURR_CP_RAW_PHONE_NUMBER        := FND_API.g_miss_char;
 x_entry_rec.CURR_CP_AREA_CODE               := FND_API.g_miss_num;
 x_entry_rec.CURR_CP_ID                      := FND_API.g_miss_num;
 x_entry_rec.CURR_CP_INDEX                   := FND_API.g_miss_num;
 x_entry_rec.CURR_CP_TIME_ZONE               := FND_API.g_miss_num;
 x_entry_rec.CURR_CP_TIME_ZONE_AUX           := FND_API.g_miss_num;
 x_entry_rec.IMP_SOURCE_LINE_ID              := FND_API.g_miss_num;
 x_entry_rec.NEXT_CALL_TIME                  := FND_API.g_miss_date;
 x_entry_rec.RECORD_RELEASE_TIME             := FND_API.g_miss_date;
 x_entry_rec.PARENT_PARTY_ID                 := FND_API.g_miss_num;
 x_entry_rec.GROUP_CODE                      := FND_API.g_miss_char;
 x_entry_rec.NEWLY_UPDATED_FLAG              := FND_API.g_miss_char;
 x_entry_rec.outcome_id                      := FND_API.g_miss_num;
 x_entry_rec.result_id                       := FND_API.g_miss_num;
 x_entry_rec.reason_id                       := FND_API.g_miss_num;
 x_entry_rec.notes                           := FND_API.g_miss_char;
 x_entry_rec.VEHICLE_RESPONSE_CODE           := FND_API.g_miss_char;
 x_entry_rec.SALES_AGENT_EMAIL_ADDRESS       := FND_API.g_miss_char;
 x_entry_rec.RESOURCE_ID                     := FND_API.g_miss_num;
 x_entry_rec.LOCATION_ID                     := FND_API.g_miss_num;
 x_entry_rec.CONTACT_POINT_ID                := FND_API.g_miss_num;
 x_entry_rec.last_contacted_date             := FND_API.g_miss_date;


END init_entry_rec;



PROCEDURE Copy_List_Entries
(
  p_api_version_number      IN   NUMBER,
  p_init_msg_list           IN   VARCHAR2     := FND_API.G_FALSE,
  p_commit                  IN   VARCHAR2     := FND_API.G_FALSE,
  p_validation_level        IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
  x_return_status           OUT NOCOPY  VARCHAR2,
  x_msg_count               OUT NOCOPY  NUMBER,
  x_msg_data                OUT NOCOPY  VARCHAR2,
  p_list_header_id        IN   NUMBER,
  p_new_list_header_id    IN NUMBER
)IS
l_api_name            CONSTANT VARCHAR2(30)  := 'Copy_List';
l_api_version         CONSTANT NUMBER        := 1.0;
-- Status Local Variables
l_return_status                VARCHAR2(1);  -- Return value from procedures

l_listheader_id                number :=p_list_header_id;

x_rowid VARCHAR2(30);

l_sqlerrm varchar2(600);
l_sqlcode varchar2(100);

l_init_msg_list    VARCHAR2(2000)    := FND_API.G_FALSE;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT Copy_List_Entries_PVT;

  x_return_status := FND_API.G_RET_STS_SUCCESS;




  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version_number,
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
     FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('ROW', 'AMS_ListHeaders_PVT.Copy_List_Entries: Start', TRUE);
     FND_MSG_PUB.Add;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INSERT INTO AMS_lIST_ENTRIES(list_entry_id                ,
       list_header_id                  ,
       last_update_date                ,
       last_updated_by                 ,
       creation_date                   ,
       created_by                      ,
       last_update_login               ,
       object_version_number           ,
       list_select_action_id           ,
       arc_list_select_action_from     ,
       list_select_action_from_name    ,
       source_code                     ,
       arc_list_used_by_source         ,
       source_code_for_id              ,
       pin_code                        ,
       list_entry_source_system_id     ,
       list_entry_source_system_type   ,
       view_application_id             ,
       manually_entered_flag           ,
       marked_as_duplicate_flag        ,
       marked_as_random_flag           ,
       part_of_control_group_flag      ,
       exclude_in_triggered_list_flag  ,
       enabled_flag                    ,
       cell_code                       ,
       dedupe_key                      ,
       randomly_generated_number       ,
       campaign_id                     ,
       media_id                        ,
       channel_id                      ,
       channel_schedule_id             ,
       event_offer_id                  ,
       customer_id                     ,
       market_segment_id               ,
       vendor_id                       ,
       transfer_flag                   ,
       transfer_status                 ,
       list_source                     ,
       duplicate_master_entry_id       ,
       marked_flag                     ,
       lead_id                         ,
       letter_id                       ,
       picking_header_id               ,
       batch_id                        ,
       suffix                          ,
       first_name                      ,
       last_name                       ,
       customer_name                   ,
       title                           ,
       address_line1                   ,
       address_line2                   ,
       city                            ,
       state                           ,
       zipcode                         ,
       country                         ,
       fax                             ,
       phone                           ,
       email_address                   ,
       col1                            ,
       col2                            ,
       col3                            ,
       col4                            ,
       col5                            ,
       col6                            ,
       col7                            ,
       col8                            ,
       col9                            ,
       col10                           ,
       col11                           ,
       col12                           ,
       col13                           ,
       col14                           ,
       col15                           ,
       col16                           ,
       col17                           ,
       col18                           ,
       col19                           ,
       col20                           ,
       col21                           ,
       col22                           ,
       col23                           ,
       col24                           ,
       col25                           ,
       col26                           ,
       col27                           ,
       col28                           ,
       col29                           ,
       col30                           ,
       col31                           ,
       col32                           ,
       col33                           ,
       col34                           ,
       col35                           ,
       col36                           ,
       col37                           ,
       col38                           ,
       col39                           ,
       col40                           ,
       col41                           ,
       col42                           ,
       col43                           ,
       col44                           ,
       col45                           ,
       col46                           ,
       col47                           ,
       col48                           ,
       col49                           ,
       col50                           ,
       col51                           ,
       col52                           ,
       col53                           ,
       col54                           ,
       col55                           ,
       col56                           ,
       col57                           ,
       col58                           ,
       col59                           ,
       col60                           ,
       col61                           ,
       col62                           ,
       col63                           ,
       col64                           ,
       col65                           ,
       col66                           ,
       col67                           ,
       col68                           ,
       col69                           ,
       col70                           ,
       col71                           ,
       col72                           ,
       col73                           ,
       col74                           ,
       col75                           ,
       col76                           ,
       col77                           ,
       col78                           ,
       col79                           ,
       col80                           ,
       col81                           ,
       col82                           ,
       col83                           ,
       col84                           ,
       col85                           ,
       col86                           ,
       col87                           ,
       col88                           ,
       col89                           ,
       col90                           ,
       col91                           ,
       col92                           ,
       col93                           ,
       col94                           ,
       col95                           ,
       col96                           ,
       col97                           ,
       col98                           ,
       col99                           ,
       col100                          ,
       col101                          ,
       col102                          ,
       col103                          ,
       col104                          ,
       col105                          ,
       col106                          ,
       col107                          ,
       col108                          ,
       col109                          ,
       col110                          ,
       col111                          ,
       col112                          ,
       col113                          ,
       col114                          ,
       col115                          ,
       col116                          ,
       col117                          ,
       col118                          ,
       col119                          ,
       col120                          ,
       col121                          ,
       col122                          ,
       col123                          ,
       col124                          ,
       col125                          ,
       col126                          ,
       col127                          ,
       col128                          ,
       col129                          ,
       col130                          ,
       col131                          ,
       col132                          ,
       col133                          ,
       col134                          ,
       col135                          ,
       col136                          ,
       col137                          ,
       col138                          ,
       col139                          ,
       col140                          ,
       col141                          ,
       col142                          ,
       col143                          ,
       col144                          ,
       col145                          ,
       col146                          ,
       col147                          ,
       col148                          ,
       col149                          ,
       col150                          ,
       col151                          ,
       col152                          ,
       col153                          ,
       col154                          ,
       col155                          ,
       col156                          ,
       col157                          ,
       col158                          ,
       col159                          ,
       col160                          ,
       col161                          ,
       col162                          ,
       col163                          ,
       col164                          ,
       col165                          ,
       col166                          ,
       col167                          ,
       col168                          ,
       col169                          ,
       col170                          ,
       col171                          ,
       col172                          ,
       col173                          ,
       col174                          ,
       col175                          ,
       col176                          ,
       col177                          ,
       col178                          ,
       col179                          ,
       col180                          ,
       col181                          ,
       col182                          ,
       col183                          ,
       col184                          ,
       col185                          ,
       col186                          ,
       col187                          ,
       col188                          ,
       col189                          ,
       col190                          ,
       col191                          ,
       col192                          ,
       col193                          ,
       col194                          ,
       col195                          ,
       col196                          ,
       col197                          ,
       col198                          ,
       col199                          ,
       col200                          ,
       col201                          ,
       col202                          ,
       col203                          ,
       col204                          ,
       col205                          ,
       col206                          ,
       col207                          ,
       col208                          ,
       col209                          ,
       col210                          ,
       col211                          ,
       col212                          ,
       col213                          ,
       col214                          ,
       col215                          ,
       col216                          ,
       col217                          ,
       col218                          ,
       col219                          ,
       col220                          ,
       col221                          ,
       col222                          ,
       col223                          ,
       col224                          ,
       col225                          ,
       col226                          ,
       col227                          ,
       col228                          ,
       col229                          ,
       col230                          ,
       col231                          ,
       col232                          ,
       col233                          ,
       col234                          ,
       col235                          ,
       col236                          ,
       col237                          ,
       col238                          ,
       col239                          ,
       col240                          ,
       col241                          ,
       col242                          ,
       col243                          ,
       col244                          ,
       col245                          ,
       col246                          ,
       col247                          ,
       col248                          ,
       col249                          ,
       col250                          ,
       col251                          ,
       col252                          ,
       col253                          ,
       col254                          ,
       col255                          ,
       col256                          ,
       col257                          ,
       col258                          ,
       col259                          ,
       col260                          ,
       col261                          ,
       col262                          ,
       col263                          ,
       col264                          ,
       col265                          ,
       col266                          ,
       col267                          ,
       col268                          ,
       col269                          ,
       col270                          ,
       col271                          ,
       col272                          ,
       col273                          ,
       col274                          ,
       col275                          ,
       col276                          ,
       col277                          ,
       col278                          ,
       col279                          ,
       col280                          ,
       col281                          ,
       col282                          ,
       col283                          ,
       col284                          ,
       col285                          ,
       col286                          ,
       col287                          ,
       col288                          ,
       col289                          ,
       col290                          ,
       col291                          ,
       col292                          ,
       col293                          ,
       col294                          ,
       col295                          ,
       col296                          ,
       col297                          ,
       col298                          ,
       col299                          ,
       col300                          ,
       party_id                        ,
       parent_party_id                 ,
       -- geometry                     ,
       imp_source_line_id              ,
       group_code		       ,
       newly_updated_flag	       ,
       outcome_id		       ,
       result_id 	       ,
       reason_id
  )
   select ams_list_entries_s.nextval   ,
       p_new_list_header_id            ,
       SYSDATE                         ,
       FND_GLOBAL.user_id              ,
       SYSDATE                         ,
       FND_GLOBAL.user_id              ,
       FND_GLOBAL.conc_login_id        ,
       1                               ,
       0                               ,--put select action id as 0 for now
       arc_list_select_action_from     ,
       list_select_action_from_name    ,
       'NONE'                          ,
       'NONE'                          ,
       0                               ,
       ams_list_entries_s.currval      ,
       list_entry_source_system_id     ,
       list_entry_source_system_type   ,
       view_application_id             ,
       manually_entered_flag           ,
       marked_as_duplicate_flag        ,
       marked_as_random_flag           ,
       part_of_control_group_flag      ,
       exclude_in_triggered_list_flag  ,
       enabled_flag                    ,
       cell_code                       ,
       dedupe_key                      ,
       randomly_generated_number       ,
       campaign_id                     ,
       media_id                        ,
       channel_id                      ,
       channel_schedule_id             ,
       event_offer_id                  ,
       customer_id                     ,
       market_segment_id               ,
       vendor_id                       ,
       transfer_flag                   ,
       transfer_status                 ,
       list_source                     ,
       duplicate_master_entry_id       ,
       marked_flag                     ,
       lead_id                         ,
       letter_id                       ,
       picking_header_id               ,
       batch_id                        ,
       suffix                          ,
       first_name                      ,
       last_name                       ,
       customer_name                   ,
       title                           ,
       address_line1                   ,
       address_line2                   ,
       city                            ,
       state                           ,
       zipcode                         ,
       country                         ,
       fax                             ,
       phone                           ,
       email_address                   ,
       col1                            ,
       col2                            ,
       col3                            ,
       col4                            ,
       col5                            ,
       col6                            ,
       col7                            ,
       col8                            ,
       col9                            ,
       col10                           ,
       col11                           ,
       col12                           ,
       col13                           ,
       col14                           ,
       col15                           ,
       col16                           ,
       col17                           ,
       col18                           ,
       col19                           ,
       col20                           ,
       col21                           ,
       col22                           ,
       col23                           ,
       col24                           ,
       col25                           ,
       col26                           ,
       col27                           ,
       col28                           ,
       col29                           ,
       col30                           ,
       col31                           ,
       col32                           ,
       col33                           ,
       col34                           ,
       col35                           ,
       col36                           ,
       col37                           ,
       col38                           ,
       col39                           ,
       col40                           ,
       col41                           ,
       col42                           ,
       col43                           ,
       col44                           ,
       col45                           ,
       col46                           ,
       col47                           ,
       col48                           ,
       col49                           ,
       col50                           ,
       col51                           ,
       col52                           ,
       col53                           ,
       col54                           ,
       col55                           ,
       col56                           ,
       col57                           ,
       col58                           ,
       col59                           ,
       col60                           ,
       col61                           ,
       col62                           ,
       col63                           ,
       col64                           ,
       col65                           ,
       col66                           ,
       col67                           ,
       col68                           ,
       col69                           ,
       col70                           ,
       col71                           ,
       col72                           ,
       col73                           ,
       col74                           ,
       col75                           ,
       col76                           ,
       col77                           ,
       col78                           ,
       col79                           ,
       col80                           ,
       col81                           ,
       col82                           ,
       col83                           ,
       col84                           ,
       col85                           ,
       col86                           ,
       col87                           ,
       col88                           ,
       col89                           ,
       col90                           ,
       col91                           ,
       col92                           ,
       col93                           ,
       col94                           ,
       col95                           ,
       col96                           ,
       col97                           ,
       col98                           ,
       col99                           ,
       col100                          ,
       col101                          ,
       col102                          ,
       col103                          ,
       col104                          ,
       col105                          ,
       col106                          ,
       col107                          ,
       col108                          ,
       col109                          ,
       col110                          ,
       col111                          ,
       col112                          ,
       col113                          ,
       col114                          ,
       col115                          ,
       col116                          ,
       col117                          ,
       col118                          ,
       col119                          ,
       col120                          ,
       col121                          ,
       col122                          ,
       col123                          ,
       col124                          ,
       col125                          ,
       col126                          ,
       col127                          ,
       col128                          ,
       col129                          ,
       col130                          ,
       col131                          ,
       col132                          ,
       col133                          ,
       col134                          ,
       col135                          ,
       col136                          ,
       col137                          ,
       col138                          ,
       col139                          ,
       col140                          ,
       col141                          ,
       col142                          ,
       col143                          ,
       col144                          ,
       col145                          ,
       col146                          ,
       col147                          ,
       col148                          ,
       col149                          ,
       col150                          ,
       col151                          ,
       col152                          ,
       col153                          ,
       col154                          ,
       col155                          ,
       col156                          ,
       col157                          ,
       col158                          ,
       col159                          ,
       col160                          ,
       col161                          ,
       col162                          ,
       col163                          ,
       col164                          ,
       col165                          ,
       col166                          ,
       col167                          ,
       col168                          ,
       col169                          ,
       col170                          ,
       col171                          ,
       col172                          ,
       col173                          ,
       col174                          ,
       col175                          ,
       col176                          ,
       col177                          ,
       col178                          ,
       col179                          ,
       col180                          ,
       col181                          ,
       col182                          ,
       col183                          ,
       col184                          ,
       col185                          ,
       col186                          ,
       col187                          ,
       col188                          ,
       col189                          ,
       col190                          ,
       col191                          ,
       col192                          ,
       col193                          ,
       col194                          ,
       col195                          ,
       col196                          ,
       col197                          ,
       col198                          ,
       col199                          ,
       col200                          ,
       col201                          ,
       col202                          ,
       col203                          ,
       col204                          ,
       col205                          ,
       col206                          ,
       col207                          ,
       col208                          ,
       col209                          ,
       col210                          ,
       col211                          ,
       col212                          ,
       col213                          ,
       col214                          ,
       col215                          ,
       col216                          ,
       col217                          ,
       col218                          ,
       col219                          ,
       col220                          ,
       col221                          ,
       col222                          ,
       col223                          ,
       col224                          ,
       col225                          ,
       col226                          ,
       col227                          ,
       col228                          ,
       col229                          ,
       col230                          ,
       col231                          ,
       col232                          ,
       col233                          ,
       col234                          ,
       col235                          ,
       col236                          ,
       col237                          ,
       col238                          ,
       col239                          ,
       col240                          ,
       col241                          ,
       col242                          ,
       col243                          ,
       col244                          ,
       col245                          ,
       col246                          ,
       col247                          ,
       col248                          ,
       col249                          ,
       col250                          ,
       col251                          ,
       col252                          ,
       col253                          ,
       col254                          ,
       col255                          ,
       col256                          ,
       col257                          ,
       col258                          ,
       col259                          ,
       col260                          ,
       col261                          ,
       col262                          ,
       col263                          ,
       col264                          ,
       col265                          ,
       col266                          ,
       col267                          ,
       col268                          ,
       col269                          ,
       col270                          ,
       col271                          ,
       col272                          ,
       col273                          ,
       col274                          ,
       col275                          ,
       col276                          ,
       col277                          ,
       col278                          ,
       col279                          ,
       col280                          ,
       col281                          ,
       col282                          ,
       col283                          ,
       col284                          ,
       col285                          ,
       col286                          ,
       col287                          ,
       col288                          ,
       col289                          ,
       col290                          ,
       col291                          ,
       col292                          ,
       col293                          ,
       col294                          ,
       col295                          ,
       col296                          ,
       col297                          ,
       col298                          ,
       col299                          ,
       col300                          ,
       party_id                        ,
       parent_party_id                 ,
       -- geometry                     ,
       imp_source_line_id              ,
       group_code		       ,
       newly_updated_flag	       ,
       outcome_id ,
       result_id	       ,
       reason_id
       FROM ams_list_entries
       WHERE list_header_id = p_list_header_id  ;



    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

      -- Standard check of p_commit.
      IF FND_API.To_Boolean ( p_commit ) THEN
           COMMIT WORK;
      END IF;

      -- Success Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
      THEN
            FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
            FND_MESSAGE.Set_Token('ROW', 'AMS_listheaders_PVT.Copy_List_Entries', TRUE);
            FND_MSG_PUB.Add;
      END IF;

      IF (AMS_DEBUG_HIGH_ON) THEN
            FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('ROW', 'AMS_listheaders_PVT.Copy_List_Entries: END', TRUE);
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
      ROLLBACK TO Copy_List_Entries_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR ;

      FND_MSG_PUB.Count_AND_Get
          ( p_count           =>      x_msg_count,
            p_data            =>      x_msg_data,
            p_encoded         =>      FND_API.G_FALSE
           );


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Copy_List_Entries_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_AND_Get
      ( p_count      =>      x_msg_count,
        p_data       =>      x_msg_data,
        p_encoded    =>      FND_API.G_FALSE
      );

   WHEN OTHERS THEN
      ROLLBACK TO Copy_List_Entries_PVT;
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


END Copy_List_Entries;


END AMS_List_Entries_PVT;

/
