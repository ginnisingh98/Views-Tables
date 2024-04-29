--------------------------------------------------------
--  DDL for Package AMS_LIST_ENTRIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LIST_ENTRIES_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvlies.pls 115.17 2003/08/19 18:33:34 vbhandar ship $ */
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

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             list_entries_rec_type
--   -------------------------------------------------------
--   Parameters:
--       list_entry_id
--       list_header_id
--       last_update_date
--       last_updated_by
--       creation_date
--       created_by
--       last_update_login
--       object_version_number
--       list_select_action_id
--       arc_list_select_action_from
--       list_select_action_from_name
--       source_code
--       arc_list_used_by_source
--       source_code_for_id
--       pin_code
--       list_entry_source_system_id
--       list_entry_source_system_type
--       view_application_id
--       manually_entered_flag
--       marked_as_duplicate_flag
--       marked_as_random_flag
--       part_of_control_group_flag
--       exclude_in_triggered_list_flag
--       enabled_flag
--       cell_code
--       dedupe_key
--       randomly_generated_number
--       campaign_id
--       media_id
--       channel_id
--       channel_schedule_id
--       event_offer_id
--       customer_id
--       market_segment_id
--       vendor_id
--       transfer_flag
--       transfer_status
--       list_source
--       duplicate_master_entry_id
--       marked_flag
--       lead_id
--       letter_id
--       picking_header_id
--       batch_id
--       suffix
--       first_name
--       last_name
--       customer_name
--       title
--       address_line1
--       address_line2
--       city
--       state
--       zipcode
--       country
--       fax
--       phone
--       email_address
--       col1
--       col2
--       col3
--       col4
--       col5
--       col6
--       col7
--       col8
--       col9
--       col10
--       col11
--       col12
--       col13
--       col14
--       col15
--       col16
--       col17
--       col18
--       col19
--       col20
--       col21
--       col22
--       col23
--       col24
--       col25
--       col26
--       col27
--       col28
--       col29
--       col30
--       col31
--       col32
--       col33
--       col34
--       col35
--       col36
--       col37
--       col38
--       col39
--       col40
--       col41
--       col42
--       col43
--       col44
--       col45
--       col46
--       col47
--       col48
--       col49
--       col50
--       col51
--       col52
--       col53
--       col54
--       col55
--       col56
--       col57
--       col58
--       col59
--       col60
--       col61
--       col62
--       col63
--       col64
--       col65
--       col66
--       col67
--       col68
--       col69
--       col70
--       col71
--       col72
--       col73
--       col74
--       col75
--       col76
--       col77
--       col78
--       col79
--       col80
--       col81
--       col82
--       col83
--       col84
--       col85
--       col86
--       col87
--       col88
--       col89
--       col90
--       col91
--       col92
--       col93
--       col94
--       col95
--       col96
--       col97
--       col98
--       col99
--       col100
--       col101
--       col102
--       col103
--       col104
--       col105
--       col106
--       col107
--       col108
--       col109
--       col110
--       col111
--       col112
--       col113
--       col114
--       col115
--       col116
--       col117
--       col118
--       col119
--       col120
--       col121
--       col122
--       col123
--       col124
--       col125
--       col126
--       col127
--       col128
--       col129
--       col130
--       col131
--       col132
--       col133
--       col134
--       col135
--       col136
--       col137
--       col138
--       col139
--       col140
--       col141
--       col142
--       col143
--       col144
--       col145
--       col146
--       col147
--       col148
--       col149
--       col150
--       col151
--       col152
--       col153
--       col154
--       col155
--       col156
--       col157
--       col158
--       col159
--       col160
--       col161
--       col162
--       col163
--       col164
--       col165
--       col166
--       col167
--       col168
--       col169
--       col170
--       col171
--       col172
--       col173
--       col174
--       col175
--       col176
--       col177
--       col178
--       col179
--       col180
--       col181
--       col182
--       col183
--       col184
--       col185
--       col186
--       col187
--       col188
--       col189
--       col190
--       col191
--       col192
--       col193
--       col194
--       col195
--       col196
--       col197
--       col198
--       col199
--       col200
--       party_id
--       parent_party_id
--       geometry
--       imp_source_line_id
--       usage_restriction
--       next_call_time
--       callback_flag
--       do_not_use_flag
--       do_not_use_reason
--       record_out_flag
--       record_release_time
--       last_contacted_date
--
--    Required
--
--    Defaults
--
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

--===================================================================
TYPE list_entries_rec_type IS RECORD
(
       list_entry_id                   NUMBER := FND_API.G_MISS_NUM,
       list_header_id                  NUMBER := FND_API.G_MISS_NUM,
       last_update_date                DATE := FND_API.G_MISS_DATE,
       last_updated_by                 NUMBER := FND_API.G_MISS_NUM,
       creation_date                   DATE := FND_API.G_MISS_DATE,
       created_by                      NUMBER := FND_API.G_MISS_NUM,
       last_update_login               NUMBER := FND_API.G_MISS_NUM,
       object_version_number           NUMBER := FND_API.G_MISS_NUM,
       list_select_action_id           NUMBER := FND_API.G_MISS_NUM,
       arc_list_select_action_from     VARCHAR2(30) := FND_API.G_MISS_CHAR,
       list_select_action_from_name    VARCHAR2(254) := FND_API.G_MISS_CHAR,
       source_code                     VARCHAR2(30) := FND_API.G_MISS_CHAR,
       arc_list_used_by_source         VARCHAR2(30) := FND_API.G_MISS_CHAR,
       source_code_for_id              NUMBER := FND_API.G_MISS_NUM,
       pin_code                        VARCHAR2(30) := FND_API.G_MISS_CHAR,
       list_entry_source_system_id     NUMBER := FND_API.G_MISS_NUM,
       list_entry_source_system_type   VARCHAR2(30) := FND_API.G_MISS_CHAR,
       view_application_id             NUMBER := FND_API.G_MISS_NUM,
       manually_entered_flag           VARCHAR2(1) := FND_API.G_MISS_CHAR,
       marked_as_duplicate_flag        VARCHAR2(1) := FND_API.G_MISS_CHAR,
       marked_as_random_flag           VARCHAR2(1) := FND_API.G_MISS_CHAR,
       part_of_control_group_flag      VARCHAR2(1) := FND_API.G_MISS_CHAR,
       exclude_in_triggered_list_flag  VARCHAR2(1) := FND_API.G_MISS_CHAR,
       enabled_flag                    VARCHAR2(1) := FND_API.G_MISS_CHAR,
       cell_code                       VARCHAR2(30) := FND_API.G_MISS_CHAR,
       dedupe_key                      VARCHAR2(500) := FND_API.G_MISS_CHAR,
       randomly_generated_number       NUMBER := FND_API.G_MISS_NUM,
       campaign_id                     NUMBER := FND_API.G_MISS_NUM,
       media_id                        NUMBER := FND_API.G_MISS_NUM,
       channel_id                      NUMBER := FND_API.G_MISS_NUM,
       channel_schedule_id             NUMBER := FND_API.G_MISS_NUM,
       event_offer_id                  NUMBER := FND_API.G_MISS_NUM,
       customer_id                     NUMBER := FND_API.G_MISS_NUM,
       market_segment_id               NUMBER := FND_API.G_MISS_NUM,
       vendor_id                       NUMBER := FND_API.G_MISS_NUM,
       transfer_flag                   VARCHAR2(1) := FND_API.G_MISS_CHAR,
       transfer_status                 VARCHAR2(1) := FND_API.G_MISS_CHAR,
       list_source                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       duplicate_master_entry_id       NUMBER := FND_API.G_MISS_NUM,
       marked_flag                     VARCHAR2(1) := FND_API.G_MISS_CHAR,
       lead_id                         NUMBER := FND_API.G_MISS_NUM,
       letter_id                       NUMBER := FND_API.G_MISS_NUM,
       picking_header_id               NUMBER := FND_API.G_MISS_NUM,
       batch_id                        NUMBER := FND_API.G_MISS_NUM,
       suffix                          VARCHAR2(30) := FND_API.G_MISS_CHAR,
       first_name                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       last_name                       VARCHAR2(150) := FND_API.G_MISS_CHAR,
       customer_name                   VARCHAR2(500) := FND_API.G_MISS_CHAR,
       title                           VARCHAR2(150) := FND_API.G_MISS_CHAR,
       address_line1                   VARCHAR2(500) := FND_API.G_MISS_CHAR,
       address_line2                   VARCHAR2(500) := FND_API.G_MISS_CHAR,
       city                            VARCHAR2(100) := FND_API.G_MISS_CHAR,
       state                           VARCHAR2(100) := FND_API.G_MISS_CHAR,
       zipcode                         VARCHAR2(100) := FND_API.G_MISS_CHAR,
       country                         VARCHAR2(100) := FND_API.G_MISS_CHAR,
       fax                             VARCHAR2(150) := FND_API.G_MISS_CHAR,
       phone                           VARCHAR2(150) := FND_API.G_MISS_CHAR,
       email_address                   VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col1                            VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col2                            VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col3                            VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col4                            VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col5                            VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col6                            VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col7                            VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col8                            VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col9                            VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col10                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col11                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col12                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col13                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col14                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col15                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col16                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col17                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col18                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col19                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col20                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col21                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col22                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col23                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col24                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col25                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col26                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col27                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col28                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col29                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col30                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col31                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col32                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col33                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col34                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col35                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col36                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col37                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col38                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col39                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col40                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col41                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col42                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col43                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col44                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col45                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col46                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col47                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col48                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col49                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col50                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col51                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col52                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col53                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col54                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col55                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col56                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col57                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col58                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col59                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col60                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col61                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col62                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col63                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col64                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col65                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col66                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col67                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col68                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col69                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col70                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col71                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col72                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col73                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col74                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col75                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col76                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col77                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col78                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col79                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col80                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col81                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col82                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col83                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col84                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col85                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col86                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col87                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col88                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col89                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col90                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col91                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col92                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col93                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col94                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col95                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col96                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col97                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col98                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col99                           VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col100                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col101                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col102                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col103                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col104                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col105                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col106                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col107                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col108                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col109                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col110                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col111                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col112                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col113                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col114                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col115                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col116                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col117                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col118                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col119                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col120                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col121                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col122                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col123                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col124                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col125                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col126                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col127                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col128                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col129                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col130                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col131                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col132                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col133                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col134                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col135                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col136                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col137                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col138                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col139                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col140                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col141                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col142                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col143                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col144                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col145                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col146                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col147                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col148                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col149                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col150                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col151                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col152                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col153                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col154                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col155                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col156                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col157                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col158                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col159                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col160                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col161                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col162                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col163                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col164                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col165                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col166                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col167                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col168                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col169                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col170                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col171                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col172                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col173                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col174                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col175                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col176                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col177                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col178                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col179                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col180                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col181                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col182                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col183                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col184                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col185                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col186                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col187                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col188                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col189                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col190                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col191                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col192                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col193                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col194                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col195                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col196                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col197                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col198                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col199                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col200                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL201                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL202                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL203                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL204                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL205                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL206                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL207                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL208                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL209                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL210                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL211                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL212                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL213                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL214                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL215                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL216                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL217                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL218                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL219                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL220                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL221                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL222                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL223                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL224                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL225                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL226                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL227                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL228                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL229                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL230                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL231                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL232                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL233                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL234                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL235                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL236                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL237                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL238                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL239                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL240                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL241                          VARCHAR2(4000) := FND_API.G_MISS_CHAR,
       COL242                          VARCHAR2(4000) := FND_API.G_MISS_CHAR,
       COL243                          VARCHAR2(4000) := FND_API.G_MISS_CHAR,
       COL244                          VARCHAR2(4000) := FND_API.G_MISS_CHAR,
       COL245                          VARCHAR2(4000) := FND_API.G_MISS_CHAR,
       COL246                          VARCHAR2(4000) := FND_API.G_MISS_CHAR,
       COL247                          VARCHAR2(4000) := FND_API.G_MISS_CHAR,
       COL248                          VARCHAR2(4000) := FND_API.G_MISS_CHAR,
       COL249                          VARCHAR2(4000) := FND_API.G_MISS_CHAR,
       COL250                          VARCHAR2(4000) := FND_API.G_MISS_CHAR,
       COL251                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL252                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL253                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL254                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL255                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL256                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL257                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL258                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL259                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL260                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL261                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL262                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL263                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL264                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL265                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL266                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL267                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL268                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL269                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL270                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL271                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL272                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL273                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL274                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL275                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL276                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL277                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL278                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL279                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL280                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL281                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL282                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL283                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL284                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL285                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL286                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL287                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL288                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL289                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL290                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL291                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL292                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL293                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL294                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL295                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL296                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL297                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL298                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL299                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       COL300                          VARCHAR2(500) := FND_API.G_MISS_CHAR,
       CURR_CP_COUNTRY_CODE            VARCHAR2(30) := FND_API.G_MISS_CHAR,
       CURR_CP_PHONE_NUMBER            VARCHAR2(10) := FND_API.G_MISS_CHAR,
       CURR_CP_RAW_PHONE_NUMBER        VARCHAR2(60) := FND_API.G_MISS_CHAR,
       CURR_CP_AREA_CODE               NUMBER := FND_API.G_MISS_NUM,
       CURR_CP_ID                      NUMBER := FND_API.G_MISS_NUM,
       CURR_CP_INDEX                   NUMBER := FND_API.G_MISS_NUM,
       CURR_CP_TIME_ZONE               NUMBER := FND_API.G_MISS_NUM,
       CURR_CP_TIME_ZONE_AUX           NUMBER := FND_API.G_MISS_NUM,
       party_id                        NUMBER := FND_API.G_MISS_NUM,
       parent_party_id                 NUMBER := FND_API.G_MISS_NUM,
       imp_source_line_id              NUMBER := FND_API.G_MISS_NUM,
       usage_restriction               VARCHAR2(1) := FND_API.G_MISS_CHAR,
       next_call_time                  DATE := FND_API.G_MISS_DATE,
       callback_flag                   VARCHAR2(1) := FND_API.G_MISS_CHAR,
       do_not_use_flag                 VARCHAR2(1) := FND_API.G_MISS_CHAR,
       do_not_use_reason               VARCHAR2(30) := FND_API.G_MISS_CHAR,
       record_out_flag                 VARCHAR2(1) := FND_API.G_MISS_CHAR,
       record_release_time             DATE := FND_API.G_MISS_DATE,
       group_code                      VARCHAR2(10) := FND_API.G_MISS_CHAR,
       newly_updated_flag              VARCHAR2(1) := FND_API.G_MISS_CHAR,
       outcome_id                      NUMBER := FND_API.G_MISS_NUM,
       result_id                       NUMBER := FND_API.G_MISS_NUM,
       reason_id                       NUMBER := FND_API.G_MISS_NUM,
       notes                           varchar2(4000) := FND_API.G_MISS_CHAR,
       VEHICLE_RESPONSE_CODE           varchar2(30) := FND_API.G_MISS_CHAR,
       SALES_AGENT_EMAIL_ADDRESS       varchar2(2000) := FND_API.G_MISS_CHAR,
       RESOURCE_ID                     number := FND_API.G_MISS_NUM,
       LOCATION_ID                     NUMBER := FND_API.G_MISS_NUM,
       CONTACT_POINT_ID                NUMBER  := FND_API.G_MISS_NUM,
       last_contacted_date	       DATE := FND_API.G_MISS_DATE
);

g_miss_list_entries_rec          list_entries_rec_type;
TYPE  list_entries_tbl_type      IS TABLE OF list_entries_rec_type INDEX BY BINARY_INTEGER;
g_miss_list_entries_tbl          list_entries_tbl_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_List_Entries
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_list_entries_rec            IN   list_entries_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--

PROCEDURE Create_List_Entries(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_list_entries_rec               IN   list_entries_rec_type  := g_miss_list_entries_rec,
    x_list_entry_id                   OUT NOCOPY  NUMBER
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_List_Entries
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_list_entries_rec            IN   list_entries_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--

PROCEDURE Update_List_Entries(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_list_entries_rec           IN    list_entries_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_List_Entries
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_LIST_ENTRY_ID                IN   NUMBER
--       p_object_version_number   IN   NUMBER     Optional  Default = NULL
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--

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
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_List_Entries
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_list_entries_rec            IN   list_entries_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--

PROCEDURE Lock_List_Entries(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_list_entry_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    );


-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in AMS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. We can also validate table instead of record. There will be an option for user to choose.
-- End of Comments

PROCEDURE Validate_list_entries(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_validation_mode            IN   VARCHAR2 := JTF_PLSQL_API.g_update,
    p_list_entries_rec           IN   list_entries_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in AMS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. Validate the unique keys, lookups here
-- End of Comments

PROCEDURE Check_list_entries_Items (
    P_list_entries_rec     IN    list_entries_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    );

-- Start of Comments
--
-- Record level validation procedures
--
-- p_validation_mode is a constant defined in AMS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. Developer can manually added inter-field level validation.
-- End of Comments

PROCEDURE Validate_list_entries_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_list_entries_rec               IN    list_entries_rec_type
    );
PROCEDURE init_entry_rec(
   x_entry_rec         OUT NOCOPY list_entries_rec_type
) ;


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

);



END AMS_List_Entries_PVT;

 

/
