--------------------------------------------------------
--  DDL for Package AMS_IS_LINE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_IS_LINE_PUB" AUTHID CURRENT_USER AS
/* $Header: amspisls.pls 115.7 2002/11/22 08:53:54 jieli ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Is_Line_PUB
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
--             is_line_rec_type
--   -------------------------------------------------------
--   Parameters:
--       import_source_line_id
--       object_version_number
--       last_update_date
--       last_updated_by
--       creation_date
--       created_by
--       last_update_login
--       import_list_header_id
--       import_successful_flag
--       enabled_flag
--       import_failure_reason
--       re_import_last_done_date
--       party_id
--       dedupe_key
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
--       col201
--       col202
--       col203
--       col204
--       col205
--       col206
--       col207
--       col208
--       col209
--       col210
--       col211
--       col212
--       col213
--       col214
--       col215
--       col216
--       col217
--       col218
--       col219
--       col220
--       col221
--       col222
--       col223
--       col224
--       col225
--       col226
--       col227
--       col228
--       col229
--       col230
--       col231
--       col232
--       col233
--       col234
--       col235
--       col236
--       col237
--       col238
--       col239
--       col240
--       col241
--       col242
--       col243
--       col244
--       col245
--       col246
--       col247
--       col248
--       col249
--       col250
--       duplicate_flag
--       current_usage
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
TYPE is_line_rec_type IS RECORD
(
       import_source_line_id           NUMBER := FND_API.G_MISS_NUM,
       object_version_number           NUMBER := FND_API.G_MISS_NUM,
       last_update_date                DATE := FND_API.G_MISS_DATE,
       last_updated_by                 NUMBER := FND_API.G_MISS_NUM,
       creation_date                   DATE := FND_API.G_MISS_DATE,
       created_by                      NUMBER := FND_API.G_MISS_NUM,
       last_update_login               NUMBER := FND_API.G_MISS_NUM,
       import_list_header_id           NUMBER := FND_API.G_MISS_NUM,
       import_successful_flag          VARCHAR2(1) := FND_API.G_MISS_CHAR,
       enabled_flag                    VARCHAR2(1) := FND_API.G_MISS_CHAR,
       import_failure_reason           VARCHAR2(4000) := FND_API.G_MISS_CHAR,
       re_import_last_done_date        DATE := FND_API.G_MISS_DATE,
       party_id                        NUMBER := FND_API.G_MISS_NUM,
       dedupe_key                      VARCHAR2(500) := FND_API.G_MISS_CHAR,
       col1                            VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col2                            VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col3                            VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col4                            VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col5                            VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col6                            VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col7                            VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col8                            VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col9                            VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col10                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col11                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col12                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col13                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col14                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col15                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col16                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col17                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col18                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col19                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col20                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col21                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col22                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col23                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col24                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col25                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col26                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col27                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col28                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col29                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col30                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col31                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col32                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col33                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col34                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col35                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col36                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col37                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col38                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col39                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col40                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col41                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col42                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col43                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col44                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col45                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col46                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col47                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col48                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col49                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col50                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col51                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col52                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col53                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col54                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col55                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col56                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col57                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col58                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col59                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col60                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col61                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col62                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col63                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col64                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col65                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col66                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col67                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col68                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col69                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col70                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col71                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col72                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col73                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col74                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col75                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col76                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col77                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col78                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col79                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col80                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col81                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col82                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col83                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col84                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col85                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col86                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col87                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col88                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col89                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col90                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col91                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col92                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col93                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col94                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col95                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col96                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col97                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col98                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col99                           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col100                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col101                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col102                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col103                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col104                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col105                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col106                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col107                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col108                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col109                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col110                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col111                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col112                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col113                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col114                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col115                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col116                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col117                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col118                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col119                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col120                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col121                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col122                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col123                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col124                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col125                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col126                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col127                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col128                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col129                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col130                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col131                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col132                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col133                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col134                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col135                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col136                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col137                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col138                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col139                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col140                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col141                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col142                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col143                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col144                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col145                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col146                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col147                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col148                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col149                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col150                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col151                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col152                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col153                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col154                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col155                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col156                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col157                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col158                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col159                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col160                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col161                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col162                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col163                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col164                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col165                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col166                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col167                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col168                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col169                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col170                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col171                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col172                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col173                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col174                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col175                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col176                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col177                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col178                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col179                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col180                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col181                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col182                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col183                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col184                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col185                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col186                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col187                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col188                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col189                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col190                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col191                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col192                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col193                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col194                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col195                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col196                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col197                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col198                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col199                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col200                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col201                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col202                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col203                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col204                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col205                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col206                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col207                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col208                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col209                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col210                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col211                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col212                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col213                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col214                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col215                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col216                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col217                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col218                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col219                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col220                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col221                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col222                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col223                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col224                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col225                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col226                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col227                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col228                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col229                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col230                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col231                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col232                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col233                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col234                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col235                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col236                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col237                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col238                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col239                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col240                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       col241                          VARCHAR2(4000) := FND_API.G_MISS_CHAR,
       col242                          VARCHAR2(4000) := FND_API.G_MISS_CHAR,
       col243                          VARCHAR2(4000) := FND_API.G_MISS_CHAR,
       col244                          VARCHAR2(4000) := FND_API.G_MISS_CHAR,
       col245                          VARCHAR2(4000) := FND_API.G_MISS_CHAR,
       col246                          VARCHAR2(4000) := FND_API.G_MISS_CHAR,
       col247                          VARCHAR2(4000) := FND_API.G_MISS_CHAR,
       col248                          VARCHAR2(4000) := FND_API.G_MISS_CHAR,
       col249                          VARCHAR2(4000) := FND_API.G_MISS_CHAR,
       col250                          VARCHAR2(4000) := FND_API.G_MISS_CHAR,
       duplicate_flag                  VARCHAR2(1) := FND_API.G_MISS_CHAR,
       current_usage                   NUMBER := FND_API.G_MISS_NUM,
       load_status                     VARCHAR2(30) := FND_API.G_MISS_CHAR
);

g_miss_is_line_rec          is_line_rec_type;
TYPE  is_line_tbl_type      IS TABLE OF is_line_rec_type INDEX BY BINARY_INTEGER;
g_miss_is_line_tbl          is_line_tbl_type;

TYPE is_line_sort_rec_type IS RECORD
(
      -- Please define your own sort by record here.
      object_version_number   NUMBER := NULL
);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Is_Line
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_is_line_rec            IN   is_line_rec_type  Required
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

PROCEDURE Create_Is_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_is_line_rec               IN   is_line_rec_type  := g_miss_is_line_rec,
    x_import_source_line_id                   OUT NOCOPY  NUMBER
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Is_Line
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_is_line_rec            IN   is_line_rec_type  Required
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

PROCEDURE Update_Is_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_is_line_rec               IN    is_line_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Is_Line
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_IMPORT_SOURCE_LINE_ID                IN   NUMBER
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

PROCEDURE Delete_Is_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_import_source_line_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Is_Line
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_is_line_rec            IN   is_line_rec_type  Required
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

PROCEDURE Lock_Is_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_import_source_line_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    );

END AMS_Is_Line_PUB;

 

/
