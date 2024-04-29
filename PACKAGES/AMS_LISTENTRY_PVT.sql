--------------------------------------------------------
--  DDL for Package AMS_LISTENTRY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LISTENTRY_PVT" AUTHID CURRENT_USER as
/* $Header: amsvlses.pls 115.17 2002/11/22 08:55:54 jieli ship $ */
-- Start of Comments
--
-- PACKAGE
--   AMS_ListEntry_PVT
--
-- PURPOSE
--   This package is a Private API for managing List Entry information in
--   AMS.
--
--   Procedures:
--   Create_ListEntry
--   Update_ListEntry
--   Delete_ListEntry
--   Lock_ListEntry
--   Validate_ListEntry
--
--   Check_Entry_items
--   Check_Entry_record
--   Update_Source_Code added 10/27/99

--   Init_Entry_rec
--   Complete_Entry_rec
--   Default_ListEntry

--   Functions
--   Get_List_PinCode    Calculates a unique pincode for every list entry.
--


-- NOTES
--
--
-- HISTORY
--   05/12/1999 tdonohoe created
--   06/06/2000 tdonohoe modified entry_rec_type to include PARTY_ID,PARENT_PARTY_ID,SOURCE_CODE_FOR_ID columns.
--   06/06/2000 tdonohoe added procedure Default_ListEntry.
-- End of Comments

-- global constants
TYPE entry_rec_type IS RECORD(
LIST_ENTRY_ID                    NUMBER,
LIST_HEADER_ID                   NUMBER,
LAST_UPDATE_DATE                 DATE,
LAST_UPDATED_BY                  NUMBER,
CREATION_DATE                    DATE,
CREATED_BY                       NUMBER,
LAST_UPDATE_LOGIN                NUMBER,
OBJECT_VERSION_NUMBER            NUMBER,
LIST_SELECT_ACTION_ID            NUMBER,
ARC_LIST_SELECT_ACTION_FROM      VARCHAR2(30),
LIST_SELECT_ACTION_FROM_NAME     VARCHAR2(254),
SOURCE_CODE                      VARCHAR2(30),
ARC_LIST_USED_BY_SOURCE          VARCHAR2(30),
SOURCE_CODE_FOR_ID               NUMBER,
PIN_CODE                         VARCHAR2(30),
LIST_ENTRY_SOURCE_SYSTEM_ID      NUMBER,
LIST_ENTRY_SOURCE_SYSTEM_TYPE    VARCHAR2(30),
VIEW_APPLICATION_ID              NUMBER,
MANUALLY_ENTERED_FLAG            VARCHAR2(1),
MARKED_AS_DUPLICATE_FLAG         VARCHAR2(1),
MARKED_AS_RANDOM_FLAG            VARCHAR2(1),
PART_OF_CONTROL_GROUP_FLAG       VARCHAR2(1),
EXCLUDE_IN_TRIGGERED_LIST_FLAG   VARCHAR2(1),
ENABLED_FLAG                     VARCHAR2(1),
CELL_CODE                        VARCHAR2(30),
DEDUPE_KEY                       VARCHAR2(500),
RANDOMLY_GENERATED_NUMBER        NUMBER,
CAMPAIGN_ID                      NUMBER,
MEDIA_ID                         NUMBER,
CHANNEL_ID                               NUMBER,
CHANNEL_SCHEDULE_ID                      NUMBER,
EVENT_OFFER_ID                           NUMBER,
CUSTOMER_ID                              NUMBER,
MARKET_SEGMENT_ID                        NUMBER,
VENDOR_ID                                NUMBER,
TRANSFER_FLAG                            VARCHAR2(1),
TRANSFER_STATUS                          VARCHAR2(1),
LIST_SOURCE                              VARCHAR2(240),
DUPLICATE_MASTER_ENTRY_ID                NUMBER,
MARKED_FLAG                              VARCHAR2(1),
LEAD_ID                                  NUMBER,
LETTER_ID                                NUMBER,
PICKING_HEADER_ID                        NUMBER,
BATCH_ID                                 NUMBER,
FIRST_NAME                               VARCHAR2(150),
LAST_NAME                                VARCHAR2(150),
CUSTOMER_NAME                            VARCHAR2(500),
COL1                                     VARCHAR2(500),
COL2                                     VARCHAR2(500),
COL3                                     VARCHAR2(500),
COL4                                     VARCHAR2(500),
COL5                                     VARCHAR2(500),
COL6                                     VARCHAR2(500),
COL7                                     VARCHAR2(500),
COL8                                     VARCHAR2(500),
COL9                                     VARCHAR2(500),
COL10                                    VARCHAR2(500),
COL11                                    VARCHAR2(500),
COL12                                    VARCHAR2(500),
COL13                                    VARCHAR2(500),
COL14                                    VARCHAR2(500),
COL15                                    VARCHAR2(500),
COL16                                    VARCHAR2(500),
COL17                                    VARCHAR2(500),
COL18                                    VARCHAR2(500),
COL19                                    VARCHAR2(500),
COL20                                    VARCHAR2(500),
COL21                                    VARCHAR2(500),
COL22                                    VARCHAR2(500),
COL23                                    VARCHAR2(500),
COL24                                    VARCHAR2(500),
COL25                                    VARCHAR2(500),
COL26                                    VARCHAR2(500),
COL27                                    VARCHAR2(500),
COL28                                    VARCHAR2(500),
COL29                                    VARCHAR2(500),
COL30                                    VARCHAR2(500),
COL31                                    VARCHAR2(500),
COL32                                    VARCHAR2(500),
COL33                                    VARCHAR2(500),
COL34                                    VARCHAR2(500),
COL35                                    VARCHAR2(500),
COL36                                    VARCHAR2(500),
COL37                                    VARCHAR2(500),
COL38                                    VARCHAR2(500),
COL39                                    VARCHAR2(500),
COL40                                    VARCHAR2(500),
COL41                                    VARCHAR2(500),
COL42                                    VARCHAR2(500),
COL43                                    VARCHAR2(500),
COL44                                    VARCHAR2(500),
COL45                                    VARCHAR2(500),
COL46                                    VARCHAR2(500),
COL47                                    VARCHAR2(500),
COL48                                    VARCHAR2(500),
COL49                                    VARCHAR2(500),
COL50                                    VARCHAR2(500),
COL51                                    VARCHAR2(500),
COL52                                    VARCHAR2(500),
COL53                                    VARCHAR2(500),
COL54                                    VARCHAR2(500),
COL55                                    VARCHAR2(500),
COL56                                    VARCHAR2(500),
COL57                                    VARCHAR2(500),
COL58                                    VARCHAR2(500),
COL59                                    VARCHAR2(500),
COL60                                    VARCHAR2(500),
COL61                                    VARCHAR2(500),
COL62                                    VARCHAR2(500),
COL63                                    VARCHAR2(500),
COL64                                    VARCHAR2(500),
COL65                                    VARCHAR2(500),
COL66                                    VARCHAR2(500),
COL67                                    VARCHAR2(500),
COL68                                    VARCHAR2(500),
COL69                                    VARCHAR2(500),
COL70                                    VARCHAR2(500),
COL71                                    VARCHAR2(500),
COL72                                    VARCHAR2(500),
COL73                                    VARCHAR2(500),
COL74                                    VARCHAR2(500),
COL75                                    VARCHAR2(500),
COL76                                    VARCHAR2(500),
COL77                                    VARCHAR2(500),
COL78                                    VARCHAR2(500),
COL79                                    VARCHAR2(500),
COL80                                    VARCHAR2(500),
COL81                                    VARCHAR2(500),
COL82                                    VARCHAR2(500),
COL83                                    VARCHAR2(500),
COL84                                    VARCHAR2(500),
COL85                                    VARCHAR2(500),
COL86                                    VARCHAR2(500),
COL87                                    VARCHAR2(500),
COL88                                    VARCHAR2(500),
COL89                                    VARCHAR2(500),
COL90                                    VARCHAR2(500),
COL91                                    VARCHAR2(500),
COL92                                    VARCHAR2(500),
COL93                                    VARCHAR2(500),
COL94                                    VARCHAR2(500),
COL95                                    VARCHAR2(500),
COL96                                    VARCHAR2(500),
COL97                                    VARCHAR2(500),
COL98                                    VARCHAR2(500),
COL99                                    VARCHAR2(500),
COL100                                   VARCHAR2(500),
COL101                                   VARCHAR2(500),
COL102                                   VARCHAR2(500),
COL103                                   VARCHAR2(500),
COL104                                   VARCHAR2(500),
COL105                                   VARCHAR2(500),
COL106                                   VARCHAR2(500),
COL107                                   VARCHAR2(500),
COL108                                   VARCHAR2(500),
COL109                                   VARCHAR2(500),
COL110                                   VARCHAR2(500),
COL111                                   VARCHAR2(500),
COL112                                   VARCHAR2(500),
COL113                                   VARCHAR2(500),
COL114                                   VARCHAR2(500),
COL115                                   VARCHAR2(500),
COL116                                   VARCHAR2(500),
COL117                                   VARCHAR2(500),
COL118                                   VARCHAR2(500),
COL119                                   VARCHAR2(500),
COL120                                   VARCHAR2(500),
COL121                                   VARCHAR2(500),
COL122                                   VARCHAR2(500),
COL123                                   VARCHAR2(500),
COL124                                   VARCHAR2(500),
COL125                                   VARCHAR2(500),
COL126                                   VARCHAR2(500),
COL127                                   VARCHAR2(500),
COL128                                   VARCHAR2(500),
COL129                                   VARCHAR2(500),
COL130                                   VARCHAR2(500),
COL131                                   VARCHAR2(500),
COL132                                   VARCHAR2(500),
COL133                                   VARCHAR2(500),
COL134                                   VARCHAR2(500),
COL135                                   VARCHAR2(500),
COL136                                   VARCHAR2(500),
COL137                                   VARCHAR2(500),
COL138                                   VARCHAR2(500),
COL139                                   VARCHAR2(500),
COL140                                   VARCHAR2(500),
COL141                                   VARCHAR2(500),
COL142                                   VARCHAR2(500),
COL143                                   VARCHAR2(500),
COL144                                   VARCHAR2(500),
COL145                                   VARCHAR2(500),
COL146                                   VARCHAR2(500),
COL147                                   VARCHAR2(500),
COL148                                   VARCHAR2(500),
COL149                                   VARCHAR2(500),
COL150                                   VARCHAR2(500),
COL151                                   VARCHAR2(500),
COL152                                   VARCHAR2(500),
COL153                                   VARCHAR2(500),
COL154                                   VARCHAR2(500),
COL155                                   VARCHAR2(500),
COL156                                   VARCHAR2(500),
COL157                                   VARCHAR2(500),
COL158                                   VARCHAR2(500),
COL159                                   VARCHAR2(500),
COL160                                   VARCHAR2(500),
COL161                                   VARCHAR2(500),
COL162                                   VARCHAR2(500),
COL163                                   VARCHAR2(500),
COL164                                   VARCHAR2(500),
COL165                                   VARCHAR2(500),
COL166                                   VARCHAR2(500),
COL167                                   VARCHAR2(500),
COL168                                   VARCHAR2(500),
COL169                                   VARCHAR2(500),
COL170                                   VARCHAR2(500),
COL171                                   VARCHAR2(500),
COL172                                   VARCHAR2(500),
COL173                                   VARCHAR2(500),
COL174                                   VARCHAR2(500),
COL175                                   VARCHAR2(500),
COL176                                   VARCHAR2(500),
COL177                                   VARCHAR2(500),
COL178                                   VARCHAR2(500),
COL179                                   VARCHAR2(500),
COL180                                   VARCHAR2(500),
COL181                                   VARCHAR2(500),
COL182                                   VARCHAR2(500),
COL183                                   VARCHAR2(500),
COL184                                   VARCHAR2(500),
COL185                                   VARCHAR2(500),
COL186                                   VARCHAR2(500),
COL187                                   VARCHAR2(500),
COL188                                   VARCHAR2(500),
COL189                                   VARCHAR2(500),
COL190                                   VARCHAR2(500),
COL191                                   VARCHAR2(500),
COL192                                   VARCHAR2(500),
COL193                                   VARCHAR2(500),
COL194                                   VARCHAR2(500),
COL195                                   VARCHAR2(500),
COL196                                   VARCHAR2(500),
COL197                                   VARCHAR2(500),
COL198                                   VARCHAR2(500),
COL199                                   VARCHAR2(500),
COL200                                   VARCHAR2(500),
COL201                                   VARCHAR2(500),
COL202                                   VARCHAR2(500),
COL203                                   VARCHAR2(500),
COL204                                   VARCHAR2(500),
COL205                                   VARCHAR2(500),
COL206                                   VARCHAR2(500),
COL207                                   VARCHAR2(500),
COL208                                   VARCHAR2(500),
COL209                                   VARCHAR2(500),
COL210                                   VARCHAR2(500),
COL211                                   VARCHAR2(500),
COL212                                   VARCHAR2(500),
COL213                                   VARCHAR2(500),
COL214                                   VARCHAR2(500),
COL215                                   VARCHAR2(500),
COL216                                   VARCHAR2(500),
COL217                                   VARCHAR2(500),
COL218                                   VARCHAR2(500),
COL219                                   VARCHAR2(500),
COL220                                   VARCHAR2(500),
COL221                                   VARCHAR2(500),
COL222                                   VARCHAR2(500),
COL223                                   VARCHAR2(500),
COL224                                   VARCHAR2(500),
COL225                                   VARCHAR2(500),
COL226                                   VARCHAR2(500),
COL227                                   VARCHAR2(500),
COL228                                   VARCHAR2(500),
COL229                                   VARCHAR2(500),
COL230                                   VARCHAR2(500),
COL231                                   VARCHAR2(500),
COL232                                   VARCHAR2(500),
COL233                                   VARCHAR2(500),
COL234                                   VARCHAR2(500),
COL235                                   VARCHAR2(500),
COL236                                   VARCHAR2(500),
COL237                                   VARCHAR2(500),
COL238                                   VARCHAR2(500),
COL239                                   VARCHAR2(500),
COL240                                   VARCHAR2(500),
COL241                                   VARCHAR2(4000),
COL242                                   VARCHAR2(4000),
COL243                                   VARCHAR2(4000),
COL244                                   VARCHAR2(4000),
COL245                                   VARCHAR2(4000),
COL246                                   VARCHAR2(4000),
COL247                                   VARCHAR2(4000),
COL248                                   VARCHAR2(4000),
COL249                                   VARCHAR2(4000),
COL250                                   VARCHAR2(4000),
COL251                                   VARCHAR2(500),
COL252                                   VARCHAR2(500),
COL253                                   VARCHAR2(500),
COL254                                   VARCHAR2(500),
COL255                                   VARCHAR2(500),
COL256                                   VARCHAR2(500),
COL257                                   VARCHAR2(500),
COL258                                   VARCHAR2(500),
COL259                                   VARCHAR2(500),
COL260                                   VARCHAR2(500),
COL261                                   VARCHAR2(500),
COL262                                   VARCHAR2(500),
COL263                                   VARCHAR2(500),
COL264                                   VARCHAR2(500),
COL265                                   VARCHAR2(500),
COL266                                   VARCHAR2(500),
COL267                                   VARCHAR2(500),
COL268                                   VARCHAR2(500),
COL269                                   VARCHAR2(500),
COL270                                   VARCHAR2(500),
COL271                                   VARCHAR2(500),
COL272                                   VARCHAR2(500),
COL273                                   VARCHAR2(500),
COL274                                   VARCHAR2(500),
COL275                                   VARCHAR2(500),
COL276                                   VARCHAR2(500),
COL277                                   VARCHAR2(500),
COL278                                   VARCHAR2(500),
COL279                                   VARCHAR2(500),
COL280                                   VARCHAR2(500),
COL281                                   VARCHAR2(500),
COL282                                   VARCHAR2(500),
COL283                                   VARCHAR2(500),
COL284                                   VARCHAR2(500),
COL285                                   VARCHAR2(500),
COL286                                   VARCHAR2(500),
COL287                                   VARCHAR2(500),
COL288                                   VARCHAR2(500),
COL289                                   VARCHAR2(500),
COL290                                   VARCHAR2(500),
COL291                                   VARCHAR2(500),
COL292                                   VARCHAR2(500),
COL293                                   VARCHAR2(500),
COL294                                   VARCHAR2(500),
COL295                                   VARCHAR2(500),
COL296                                   VARCHAR2(500),
COL297                                   VARCHAR2(500),
COL298                                   VARCHAR2(500),
COL299                                   VARCHAR2(500),
COL300                                   VARCHAR2(500),
ADDRESS_LINE1                            VARCHAR2(500),
ADDRESS_LINE2                            VARCHAR2(500),
CALLBACK_FLAG                            VARCHAR2(1),
CITY                                     VARCHAR2(100),
COUNTRY                                  VARCHAR2(100),
DO_NOT_USE_FLAG                          VARCHAR2(1),
DO_NOT_USE_REASON                        VARCHAR2(30),
EMAIL_ADDRESS                            VARCHAR2(500),
FAX                                      VARCHAR2(150),
PHONE                                    VARCHAR2(150),
RECORD_OUT_FLAG                          VARCHAR2(1),
STATE                                    VARCHAR2(100),
SUFFIX                                   VARCHAR2(30),
TITLE                                    VARCHAR2(150),
USAGE_RESTRICTION                        VARCHAR2(1),
ZIPCODE                                  VARCHAR2(100),
CURR_CP_COUNTRY_CODE                     VARCHAR2(30),
CURR_CP_PHONE_NUMBER                     VARCHAR2(10),
CURR_CP_RAW_PHONE_NUMBER                 VARCHAR2(60),
CURR_CP_AREA_CODE                        NUMBER,
CURR_CP_ID                               NUMBER,
CURR_CP_INDEX                            NUMBER,
CURR_CP_TIME_ZONE                        NUMBER,
CURR_CP_TIME_ZONE_AUX                    NUMBER,
IMP_SOURCE_LINE_ID                       NUMBER,
NEXT_CALL_TIME                           DATE,
RECORD_RELEASE_TIME                      DATE,
PARTY_ID                                 NUMBER,
PARENT_PARTY_ID                          NUMBER);

---------------------------------------------------------------------
-- PROCEDURE
--    update_listentry_source_code
--
-- PURPOSE
--    Updates The Source_Code and Arc_List_Used_By_Source fields on The List Entry table.

--    A List may be generated without a Source Code Associated , in this case the two columns
--    will be defaulted to NONE and 0.

--    If The List later gets a Source code we must update the two columns to reflect this change
--    to allow list tracking from the interactions table.

-- PARAMETERS
--    p_list_id -- the list header id.
-- NOTES
---------------------------------------------------------------------

PROCEDURE update_listentry_source_code(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_list_id           IN  NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    create_listentry
--
-- PURPOSE
--    Create a new list entry.
--
-- PARAMETERS
--    p_entry_rec: the new record to be inserted
--    x_entry_id: return the list_entry_id of the new campaign
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If list_entry_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If list_entry_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------
PROCEDURE create_listentry(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_entry_rec          IN  entry_rec_type,
   x_entry_id           OUT NOCOPY NUMBER
);
---------------------------------------------------------------------
-- PROCEDURE
--    update_listentry
--
-- PURPOSE
--    Update a listentry.
--
-- PARAMETERS
--    p_entry_rec: the record with new items
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE update_listentry(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_entry_rec          IN  entry_rec_type
);

--------------------------------------------------------------------
-- PROCEDURE
--    delete_listentry
--
-- PURPOSE
--    Delete a listentry.
--
-- PARAMETERS
--    p_entry_id: the listentry_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE delete_listentry(
   p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2 := FND_API.g_false,
   p_commit                IN  VARCHAR2 := FND_API.g_false,
   p_validation_level      IN  NUMBER   := FND_API.g_valid_level_full,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2,
   p_entry_id              IN NUMBER,
   p_object_version_number IN NUMBER
);

-------------------------------------------------------------------
-- PROCEDURE
--    lock_listentry
--
-- PURPOSE
--    Lock a List Entry.
--
-- PARAMETERS
--    p_entry_id: the list_entry_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE lock_listentry(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_entry_id           IN  NUMBER,
   p_object_version    IN  NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    validate_listentry
--
-- PURPOSE
--    Validate a listentry record.
--
-- PARAMETERS
--    p_camp_rec: the listentry record to be validated
--
-- NOTES
--    1. p_entry_rec should be the complete campaign record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
PROCEDURE validate_listentry(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_entry_rec          IN  entry_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    check_entry_items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_entry_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE check_entry_items(
   p_entry_rec        IN  entry_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    check_entry_record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_entry_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE check_entry_record(
   p_entry_rec         IN  entry_rec_type,
   p_complete_rec     IN  entry_rec_type := NULL,
   x_return_status    OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    init_entry_rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE init_entry_rec(
   x_entry_rec         OUT NOCOPY  entry_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    complete_entry_rec
--
-- PURPOSE
--    For update_listentry, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_camp_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE complete_entry_rec(
   p_entry_rec       IN  entry_rec_type,
   x_complete_rec    OUT NOCOPY entry_rec_type
);



Function Get_ListPinCode(p_list_header_id IN NUMBER,
                         p_list_entry_id  IN NUMBER)
Return varchar2;

END AMS_ListEntry_PVT;

 

/
