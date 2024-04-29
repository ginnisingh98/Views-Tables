--------------------------------------------------------
--  DDL for Package AMS_LISTHEADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LISTHEADER_PVT" AUTHID CURRENT_USER as
/* $Header: amsvlshs.pls 120.1 2005/08/24 16:01:57 appldev ship $ */
-- Start of Comments
--
-- NAME
--   AMS_ListHeader_PVT
--
-- PURPOSE
--   Private API for Oracle Marketing(AMS) List Headers
--
--   Procedures:

--   Create_ListHeader
--   Update_ListHeader
--   Delete_ListHeader
--   Lock_ListHeader

--   Validate_ListHeader
--   Validate_List_Record
--   Validate_List_Items


--   Complete_ListHeader_rec
--   Init_ListHeader_rec
--   Copy list
-- HISTORY
--   05/12/1999 tdonohoe created
--   07/05/2000 tdonohoe modified, update code to conform to SQL coding standards.
--   07/05/2000 tdonohoe modified, update code to conform to SQL coding standards.
--   12/05/201  vbhandar added
-- End of Comments


TYPE list_header_rec_type IS RECORD(
 list_header_id                   number,
 last_update_date                 date,
 last_updated_by                  number,
 creation_date                    date,
 created_by                       number,
 last_update_login                number,
 object_version_number            number,
 request_id                       number,
 program_id                       number,
 program_application_id           number,
 program_update_date              date,
 view_application_id              number,
 list_name                        varchar2(240),
 list_used_by_id                  number,
 arc_list_used_by                 varchar2(30),
 list_type                        varchar2(30),
 status_code                      varchar2(30),
 status_date                      date,
 generation_type                  varchar2(30),
 repeat_exclude_type              varchar2(30),
 row_selection_type               varchar2(30),
 owner_user_id                    number,
 access_level                     varchar2(30),
 enable_log_flag                  varchar2(1),
 enable_word_replacement_flag     varchar2(1),
 enable_parallel_dml_flag         varchar2(1),
 dedupe_during_generation_flag    varchar2(1),
 generate_control_group_flag      varchar2(1),
 last_generation_success_flag     varchar2(1),
 forecasted_start_date            date,
 forecasted_end_date              date,
 actual_end_date                  date,
 sent_out_date                    date,
 dedupe_start_date                date,
 last_dedupe_date                 date,
 last_deduped_by_user_id          number,
 workflow_item_key                number,
 no_of_rows_duplicates            number,
 no_of_rows_min_requested         number,
 no_of_rows_max_requested         number,
 no_of_rows_in_list               number,
 no_of_rows_in_ctrl_group         number,
 no_of_rows_active                number,
 no_of_rows_inactive              number,
 no_of_rows_manually_entered      number,
 no_of_rows_do_not_call           number,
 no_of_rows_do_not_mail           number,
 no_of_rows_random                number,
 org_id                           number,
 main_gen_start_time              date,
 main_gen_end_time                date,
 main_random_nth_row_selection    number,
 main_random_pct_row_selection    number,
 ctrl_random_nth_row_selection    number,
 ctrl_random_pct_row_selection    number,
 repeat_source_list_header_id     varchar2(4000),
 result_text                      varchar2(4000),
 keywords                         varchar2(4000),
 description                      varchar2(4000),
 list_priority                    number,
 assign_person_id                 number,
 list_source                      varchar2(240),
 list_source_type                 varchar2(30),
 list_online_flag                 varchar2(1),
 random_list_id                   number,
 enabled_flag                     varchar2(1),
 assigned_to                      number,
 query_id                         number,
 owner_person_id                  number,
 archived_by                      number,
 archived_date                    date,
 attribute_category               varchar2(30),
 attribute1                       varchar2(150),
 attribute2                       varchar2(150),
 attribute3                       varchar2(150),
 attribute4                       varchar2(150),
 attribute5                       varchar2(150),
 attribute6                       varchar2(150),
 attribute7                       varchar2(150),
 attribute8                       varchar2(150),
 attribute9                       varchar2(150),
 attribute10                      varchar2(150),
 attribute11                      varchar2(150),
 attribute12                      varchar2(150),
 attribute13                      varchar2(150),
 attribute14                      varchar2(150),
 attribute15                      varchar2(150),
 timezone_id                      number,
 user_entered_start_time          date,
 user_status_id                   number,
 quantum                          number,
 release_control_alg_id           number,
 dialing_method                   varchar2(10),
 calling_calendar_id              number,
 release_strategy                 varchar2(10),
 custom_setup_id                  number,
 country                          number,
 callback_priority_flag           varchar2(1),
 call_center_ready_flag           varchar2(1),
 language                         varchar2(4) ,
 purge_flag                       varchar2(1),
 public_flag                      varchar2(1),
 list_category                    varchar2(120),
 quota                            number,
 quota_reset                      number,
 recycling_alg_id                 number,
 source_lang                      varchar2(4),
 no_of_rows_prev_contacted        number,
 APPLY_TRAFFIC_COP                varchar2(1),
 PURPOSE_CODE			  varchar2(120),
 CTRL_CONF_LEVEL		  number,
 CTRL_REQ_RESP_RATE		  number,
 CTRL_LIMIT_OF_ERROR		  number,
 STATUS_CODE_OLD		  varchar2(30),
 CTRL_CONC_JOB_ID		  number,
 CTRL_STATUS_CODE		  varchar2(30),
 CTRL_GEN_MODE			  varchar2(30),
 APPLY_SUPPRESSION_FLAG		  varchar2(1)
 );


-- Start of Comments
---------------------------------------------------------------------
-- PROCEDURE
--    Create_Listheader
--
-- PURPOSE
--    Creates a new List Hheader.
--
-- PARAMETERS
--    p_listheader_rec   The New Record to be inserted.
--    x_listheader_id    The Primary of The New Record.
-- End Of Comments

PROCEDURE Create_Listheader
( p_api_version              IN     NUMBER,
  p_init_msg_list            IN     VARCHAR2  := FND_API.G_FALSE,
  p_commit                   IN     VARCHAR2  := FND_API.G_FALSE,
  p_validation_level         IN     NUMBER    := FND_API.g_valid_level_full,
  x_return_status            OUT NOCOPY    VARCHAR2,
  x_msg_count                OUT NOCOPY    NUMBER,
  x_msg_data                 OUT NOCOPY    VARCHAR2,
  p_listheader_rec           IN     list_header_rec_type,
  x_listheader_id            OUT NOCOPY    NUMBER
);



-- Start of Comments
------------------------------------------------------------------------------
-- PROCEDURE
--    Update_ListHeader
--
-- PURPOSE
--    Updates an existing List Header.
--
-- PARAMETERS
--    p_listheader_rec   The Record to be Updated.

-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
-- End Of Comments

PROCEDURE Update_ListHeader
( p_api_version              IN     NUMBER,
  p_init_msg_list            IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit                   IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level         IN     NUMBER      := FND_API.g_valid_level_full,
  x_return_status            OUT NOCOPY    VARCHAR2,
  x_msg_count                OUT NOCOPY    NUMBER,
  x_msg_data                 OUT NOCOPY    VARCHAR2,
  p_listheader_rec           IN     list_header_rec_type
);


--------------------------------------------------------------------
-- PROCEDURE
--    Delete_ListHeader
--
-- PURPOSE
--    Deletes a List Header.
--
-- PARAMETERS
--    p_listheader_id:  the list header primary key.
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------

PROCEDURE Delete_ListHeader
( p_api_version              IN     NUMBER,
  p_init_msg_list            IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit                   IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level         IN     NUMBER := FND_API.g_valid_level_full,
  x_return_status            OUT NOCOPY    VARCHAR2,
  x_msg_count                OUT NOCOPY    NUMBER,
  x_msg_data                 OUT NOCOPY    VARCHAR2,
  p_listheader_id            IN      NUMBER
);

-- Start Of Comments
-------------------------------------------------------------------
-- PROCEDURE
--    Lock_ListHeader
--
-- PURPOSE
--    Lock a List Header.
--
-- PARAMETERS
--    p_listheader:     the list header primary key
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
-- End Of Comments

PROCEDURE Lock_ListHeader
( p_api_version              IN  NUMBER,
  p_init_msg_list            IN  VARCHAR2    := FND_API.G_FALSE,
  p_validation_level         IN  NUMBER      := FND_API.g_valid_level_full,
  x_return_status            OUT NOCOPY VARCHAR2,
  x_msg_count                OUT NOCOPY NUMBER,
  x_msg_data                 OUT NOCOPY VARCHAR2,
  p_listheader_id            IN  NUMBER,
  p_object_version           IN  NUMBER
);


-- Start of Comments
---------------------------------------------------------------------
-- PROCEDURE
--    Validate_ListHeader
--
-- PURPOSE
--    Validate a List Header Record.
--
-- PARAMETERS
--    p_listheader_rec: the list header record to be validated
--
-- NOTES
--    1. p_listheader_rec_rec should be the complete list header record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
-- End Of Comments

PROCEDURE Validate_ListHeader
( p_api_version              IN     NUMBER,
  p_init_msg_list            IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level         IN     NUMBER := FND_API.g_valid_level_full,
  x_return_status            OUT NOCOPY    VARCHAR2,
  x_msg_count                OUT NOCOPY    NUMBER,
  x_msg_data                 OUT NOCOPY    VARCHAR2,
  p_listheader_rec           IN     list_header_rec_type
);


-- Start of Comments
---------------------------------------------------------------------
-- PROCEDURE
--    Validate_List_Items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_listheader     : the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
----------------------------------------------------------------------- End Of Comments

PROCEDURE Validate_List_Items
( p_listheader_rec           IN     list_header_rec_type,
  p_validation_mode          IN     VARCHAR2 := JTF_PLSQL_API.g_create,
  x_return_status            OUT NOCOPY    VARCHAR2
);



-- Start of Comments
---------------------------------------------------------------------
-- PROCEDURE
--    Validate_List_Record
--
-- PURPOSE
--    Validate the list record level business rules.
--
-- PARAMETERS
--    p_listheader_rec: the record to be validated; may contain attributes
--                      as FND_API.g_miss_char/num/date
--    p_complete_rec:   the complete record after all "g_miss" items
--                      have been replaced by current database values
---------------------------------------------------------------------
-- End Of Comments

PROCEDURE Validate_List_Record
( p_listheader_rec           IN     list_header_rec_type,
  p_complete_rec             IN     list_header_rec_type := NULL,
  x_return_status            OUT NOCOPY    VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    Init_ListHeader_rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE Init_ListHeader_rec(
   x_listheader_rec         OUT NOCOPY  list_header_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_ListHeader_rec
--
-- PURPOSE
--    For update_listheader, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_listheader_rec: the record which may contain attributes as
--                      FND_API.g_miss_char/num/date
--    x_complete_rec  : the complete record after all "g_miss" items
--                      have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_ListHeader_rec(
   p_listheader_rec   IN   list_header_rec_type,
   x_complete_rec     OUT NOCOPY  list_header_rec_type
);

PROCEDURE Update_list_header_count(
   p_list_header_id  IN  number,
   p_init_msg_list            IN    VARCHAR2   := FND_API.G_FALSE,
   p_commit                   IN    VARCHAR2   := FND_API.G_FALSE,
   x_return_status            OUT NOCOPY    VARCHAR2,
   x_msg_count                OUT NOCOPY    NUMBER,
   x_msg_data                 OUT NOCOPY    VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Update_Prev_contacted_count
--
-- PURPOSE
--    aDDED TO SUPPORT TRIGGER BACKPORT FUNCTIONALITY
--    Gived a schedule id / one off event id or event header id and the last contacted date
--    update all list entries of the related target group or invite list ,
--	who were not contacted earlier, with the last contacted date
--	also populate list header with total number of records with last contacted date populated
-- PARAMETERS
--    p_used_by:  eg CSCH/EVEO/EVEH
--    p_used_by  : Schedule Id/ or One off Event Id or Event Header Id
--    p_last_contacted_date :last contacted date to be populated in to the list entries table
---------------------------------------------------------------------

PROCEDURE Update_Prev_contacted_count(
   p_used_by_id			IN  number,
   p_used_by			IN  VARCHAR2,
   p_last_contacted_date	IN  DATE,
   p_init_msg_list            IN    VARCHAR2   := FND_API.G_FALSE,
   p_commit                   IN    VARCHAR2   := FND_API.G_FALSE,
   x_return_status            OUT NOCOPY    VARCHAR2,
   x_msg_count                OUT NOCOPY    NUMBER,
   x_msg_data                 OUT NOCOPY    VARCHAR2
);


-- Start of Comments
---------------------------------------------------------------------
-- PROCEDURE
--    Copy_List
--
-- PURPOSE
--    Take list header id of the list to copy from, list name, public
--    flag, purge flag, owner user id and description for the new list and generate
--    a new list header id.
--    last update date, last updated by, creation date and
--    created by are defaulted
--    copy the entries pertaining to a particular list in
--    AMS_LIST_SELECT_ACTIONS, AMS_LIST_QUERIES_ALL, AMS_LIST_ENTRIES into a new set
--    and associate them with a new list header.
--
-- PARAMETERS
--    p_listheader_rec   The Record to be copied.
--    x_listheader_id    The Primary of The New Record.
-- End Of Comments



PROCEDURE Copy_List
( p_api_version              IN     NUMBER,
  p_init_msg_list            IN     VARCHAR2  := FND_API.G_FALSE,
  p_commit                   IN     VARCHAR2  := FND_API.G_FALSE,
  p_validation_level         IN     NUMBER    := FND_API.g_valid_level_full,
  x_return_status            OUT NOCOPY    VARCHAR2,
  x_msg_count                OUT NOCOPY    NUMBER,
  x_msg_data                 OUT NOCOPY    VARCHAR2,
  p_source_listheader_id           IN     NUMBER,
  p_listheader_rec           IN     list_header_rec_type,
  p_copy_select_actions      IN     VARCHAR2  := 'Y',
  p_copy_list_queries        IN     VARCHAR2  := 'Y',
  p_copy_list_entries        IN     VARCHAR2  := 'Y',

  x_listheader_id            OUT NOCOPY    NUMBER
);



END AMS_ListHeader_PVT;

 

/
