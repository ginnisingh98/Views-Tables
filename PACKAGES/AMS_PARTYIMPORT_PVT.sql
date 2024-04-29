--------------------------------------------------------
--  DDL for Package AMS_PARTYIMPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_PARTYIMPORT_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvptys.pls 115.14 2002/11/22 08:56:10 jieli ship $ */

-----------------------------------------------------------
-- PACKAGE
--    AMS_PartyImport_PVT
--
-- PURPOSE
--    Private API for Oracle Marketing Party Sources.
--
-- PROCEDURES
--    Create_Party
--    Delete_Party
--    Lock_Party
--    Update_Party
--    Validate_Party
--
--    Check_Party_Items
--    Check_Party_Record
--
--    Init_Party_Rec
--    Complete_Party_Rec
--
--    Refresh_Key
--    Process_Party
--
------------------------------------------------------------

--
-- Record of table AMS_PARTY_SOURCES
TYPE Party_Rec_Type IS RECORD (
   party_sources_id        NUMBER,
   party_id                NUMBER,
   import_source_line_id   NUMBER,
   object_version_number   NUMBER,
   last_update_date        DATE,
   last_updated_by         NUMBER,
   creation_date           DATE,
   created_by              NUMBER,
   last_update_login       NUMBER,
   import_list_header_id   NUMBER,
   list_source_type_id     NUMBER,
   used_flag               VARCHAR2(1),
   overlay_flag            VARCHAR2(1),
   overlay_date            DATE,
   col1                    VARCHAR2(150),
   col2                    VARCHAR2(150),
   col3                    VARCHAR2(150),
   col4                    VARCHAR2(150),
   col5                    VARCHAR2(150),
   col6                    VARCHAR2(150),
   col7                    VARCHAR2(150),
   col8                    VARCHAR2(150),
   col9                    VARCHAR2(150),
   col10                    VARCHAR2(150),
   col11                    VARCHAR2(150),
   col12                    VARCHAR2(150),
   col13                    VARCHAR2(150),
   col14                    VARCHAR2(150),
   col15                    VARCHAR2(150),
   col16                    VARCHAR2(150),
   col17                    VARCHAR2(150),
   col18                    VARCHAR2(150),
   col19                    VARCHAR2(150),
   col20                    VARCHAR2(150),
   col21                    VARCHAR2(150),
   col22                    VARCHAR2(150),
   col23                    VARCHAR2(150),
   col24                    VARCHAR2(150),
   col25                    VARCHAR2(150),
   col26                    VARCHAR2(150),
   col27                    VARCHAR2(150),
   col28                    VARCHAR2(150),
   col29                    VARCHAR2(150),
   col30                    VARCHAR2(150),
   col31                    VARCHAR2(150),
   col32                    VARCHAR2(150),
   col33                    VARCHAR2(150),
   col34                    VARCHAR2(150),
   col35                    VARCHAR2(150),
   col36                    VARCHAR2(150),
   col37                    VARCHAR2(150),
   col38                    VARCHAR2(150),
   col39                    VARCHAR2(150),
   col40                    VARCHAR2(150),
   col41                    VARCHAR2(150),
   col42                    VARCHAR2(150),
   col43                    VARCHAR2(150),
   col44                    VARCHAR2(150),
   col45                    VARCHAR2(150),
   col46                    VARCHAR2(150),
   col47                    VARCHAR2(150),
   col48                    VARCHAR2(150),
   col49                    VARCHAR2(150),
   col50                    VARCHAR2(150),
   col51                    VARCHAR2(150),
   col52                    VARCHAR2(150),
   col53                    VARCHAR2(150),
   col54                    VARCHAR2(150),
   col55                    VARCHAR2(150),
   col56                    VARCHAR2(150),
   col57                    VARCHAR2(150),
   col58                    VARCHAR2(150),
   col59                    VARCHAR2(150),
   col60                    VARCHAR2(150),
   col61                   VARCHAR2(150),
   col62                   VARCHAR2(150),
   col63                   VARCHAR2(150),
   col64                   VARCHAR2(150),
   col65                   VARCHAR2(150),
   col66                   VARCHAR2(150),
   col67                   VARCHAR2(150),
   col68                   VARCHAR2(150),
   col69                   VARCHAR2(150),
   col70                   VARCHAR2(150),
   col71                   VARCHAR2(150),
   col72                   VARCHAR2(150),
   col73                   VARCHAR2(150),
   col74                   VARCHAR2(150),
   col75                   VARCHAR2(150),
   col76                   VARCHAR2(150),
   col77                   VARCHAR2(150),
   col78                   VARCHAR2(150),
   col79                   VARCHAR2(150),
   col80                   VARCHAR2(150),
   col81                   VARCHAR2(150),
   col82                   VARCHAR2(150),
   col83                   VARCHAR2(150),
   col84                   VARCHAR2(150),
   col85                   VARCHAR2(150),
   col86                   VARCHAR2(150),
   col87                   VARCHAR2(150),
   col88                   VARCHAR2(150),
   col89                   VARCHAR2(150),
   col90                   VARCHAR2(150),
   col91                   VARCHAR2(150),
   col92                   VARCHAR2(150),
   col93                   VARCHAR2(150),
   col94                   VARCHAR2(150),
   col95                   VARCHAR2(150),
   col96                   VARCHAR2(150),
   col97                   VARCHAR2(150),
   col98                   VARCHAR2(150),
   col99                   VARCHAR2(150),
   col100                  VARCHAR2(150),
   col101                  VARCHAR2(150),
   col102                  VARCHAR2(150),
   col103                  VARCHAR2(150),
   col104                  VARCHAR2(150),
   col105                  VARCHAR2(150),
   col106                  VARCHAR2(150),
   col107                  VARCHAR2(150),
   col108                  VARCHAR2(150),
   col109                  VARCHAR2(150),
   col110                  VARCHAR2(150),
   col111                  VARCHAR2(150),
   col112                  VARCHAR2(150),
   col113                  VARCHAR2(150),
   col114                  VARCHAR2(150),
   col115                  VARCHAR2(150),
   col116                  VARCHAR2(150),
   col117                  VARCHAR2(150),
   col118                  VARCHAR2(150),
   col119                  VARCHAR2(150),
   col120                  VARCHAR2(150),
   col121                  VARCHAR2(150),
   col122                  VARCHAR2(150),
   col123                  VARCHAR2(150),
   col124                  VARCHAR2(150),
   col125                  VARCHAR2(150),
   col126                  VARCHAR2(150),
   col127                  VARCHAR2(150),
   col128                  VARCHAR2(150),
   col129                  VARCHAR2(150),
   col130                  VARCHAR2(150),
   col131                  VARCHAR2(150),
   col132                  VARCHAR2(150),
   col133                  VARCHAR2(150),
   col134                  VARCHAR2(150),
   col135                  VARCHAR2(150),
   col136                  VARCHAR2(150),
   col137                  VARCHAR2(150),
   col138                  VARCHAR2(150),
   col139                  VARCHAR2(150),
   col140                  VARCHAR2(150),
   col141                  VARCHAR2(150),
   col142                  VARCHAR2(150),
   col143                  VARCHAR2(150),
   col144                  VARCHAR2(150),
   col145                  VARCHAR2(150),
   col146                  VARCHAR2(150),
   col147                  VARCHAR2(150),
   col148                  VARCHAR2(150),
   col149                  VARCHAR2(150),
   col150                  VARCHAR2(150),
   col151                  VARCHAR2(150),
   col152                  VARCHAR2(150),
   col153                  VARCHAR2(150),
   col154                  VARCHAR2(150),
   col155                  VARCHAR2(150),
   col156                  VARCHAR2(150),
   col157                  VARCHAR2(150),
   col158                  VARCHAR2(150),
   col159                  VARCHAR2(150),
   col160                  VARCHAR2(150),
   col161                  VARCHAR2(150),
   col162                  VARCHAR2(150),
   col163                  VARCHAR2(150),
   col164                  VARCHAR2(150),
   col165                  VARCHAR2(150),
   col166                  VARCHAR2(150),
   col167                  VARCHAR2(150),
   col168                  VARCHAR2(150),
   col169                  VARCHAR2(150),
   col170                  VARCHAR2(150),
   col171                  VARCHAR2(150),
   col172                  VARCHAR2(150),
   col173                  VARCHAR2(150),
   col174                  VARCHAR2(150),
   col175                  VARCHAR2(150),
   col176                  VARCHAR2(150),
   col177                  VARCHAR2(150),
   col178                  VARCHAR2(150),
   col179                  VARCHAR2(150),
   col180                  VARCHAR2(150),
   col181                  VARCHAR2(150),
   col182                  VARCHAR2(150),
   col183                  VARCHAR2(150),
   col184                  VARCHAR2(150),
   col185                  VARCHAR2(150),
   col186                  VARCHAR2(150),
   col187                  VARCHAR2(150),
   col188                  VARCHAR2(150),
   col189                  VARCHAR2(150),
   col190                  VARCHAR2(150),
   col191                  VARCHAR2(150),
   col192                  VARCHAR2(150),
   col193                  VARCHAR2(150),
   col194                  VARCHAR2(150),
   col195                  VARCHAR2(150),
   col196                  VARCHAR2(150),
   col197                  VARCHAR2(150),
   col198                  VARCHAR2(150),
   col199                  VARCHAR2(150),
   col200                  VARCHAR2(150),
   col201                  VARCHAR2(150),
   col202                  VARCHAR2(150),
   col203                  VARCHAR2(150),
   col204                  VARCHAR2(150),
   col205                  VARCHAR2(150),
   col206                  VARCHAR2(150),
   col207                  VARCHAR2(150),
   col208                  VARCHAR2(150),
   col209                  VARCHAR2(150),
   col210                  VARCHAR2(150),
   col211                  VARCHAR2(150),
   col212                  VARCHAR2(150),
   col213                  VARCHAR2(150),
   col214                  VARCHAR2(150),
   col215                  VARCHAR2(150),
   col216                  VARCHAR2(150),
   col217                  VARCHAR2(150),
   col218                  VARCHAR2(150),
   col219                  VARCHAR2(150),
   col220                  VARCHAR2(150),
   col221                  VARCHAR2(150),
   col222                  VARCHAR2(150),
   col223                  VARCHAR2(150),
   col224                  VARCHAR2(150),
   col225                  VARCHAR2(150),
   col226                  VARCHAR2(150),
   col227                  VARCHAR2(150),
   col228                  VARCHAR2(150),
   col229                  VARCHAR2(150),
   col230                  VARCHAR2(150),
   col231                  VARCHAR2(150),
   col232                  VARCHAR2(150),
   col233                  VARCHAR2(150),
   col234                  VARCHAR2(150),
   col235                  VARCHAR2(150),
   col236                  VARCHAR2(150),
   col237                  VARCHAR2(150),
   col238                  VARCHAR2(150),
   col239                  VARCHAR2(150),
   col240                  VARCHAR2(150),
   col241                  VARCHAR2(4000),
   col242                  VARCHAR2(4000),
   col243                  VARCHAR2(4000),
   col244                  VARCHAR2(4000),
   col245                  VARCHAR2(4000),
   col246                  VARCHAR2(4000),
   col247                  VARCHAR2(4000),
   col248                  VARCHAR2(4000),
   col249                  VARCHAR2(4000),
   col250                  VARCHAR2(4000)
);


--------------------------------------------------------------------
-- PROCEDURE
--    Create_Party
--
-- PURPOSE
--    Create a party source entry.
--
-- PARAMETERS
--    p_party_rec: the record representing AMS_PARTY_SOURCES.
--    x_party_sources_id: the party_sources_id.
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If party_sources_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If party_sources_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
--------------------------------------------------------------------
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
);


--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Party
--
-- PURPOSE
--    Delete a party source entry.
--
-- PARAMETERS
--    p_party_sources_id: the party_sources_id
--    p_object_version: the object_version_number
--
-- ISSUES
--    Currently, we are not allowing people to delete list header
--    entries.  We may add some business rules for deletion though.
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
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
);


--------------------------------------------------------------------
-- PROCEDURE
--    Lock_Party
--
-- PURPOSE
--    Lock a party source entry.
--
-- PARAMETERS
--    p_party_sources_id: the party_sources_id
--    p_object_version: the object_version_number
--
-- ISSUES
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
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
);


--------------------------------------------------------------------
-- PROCEDURE
--    Update_Party
--
-- PURPOSE
--    Update a party source entry.
--
-- PARAMETERS
--    p_party_rec: the record representing AMS_PARTY_SOURCES.
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
--------------------------------------------------------------------
PROCEDURE Update_Party (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_party_rec         IN  Party_Rec_Type
);


--------------------------------------------------------------------
-- PROCEDURE
--    Validate_Party
--
-- PURPOSE
--    Validate a party source entry.
--
-- PARAMETERS
--    p_party_rec: the record representing AMS_PARTY_SOURCES.
--
-- NOTES
--    1. p_party_rec should be the complete list header record. There
--       should not be any FND_API.g_miss_char/num/date in it.
--    2. If FND_API.g_miss_char/num/date is in the record, then raise
--       an exception, as those values are not handled.
--------------------------------------------------------------------
PROCEDURE Validate_Party (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_party_rec         IN  Party_Rec_Type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Party_Items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_party_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE Check_Party_Items (
   p_party_rec       IN  Party_Rec_Type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Party_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_party_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_Party_Record (
   p_party_rec        IN  Party_Rec_Type,
   p_complete_rec     IN  Party_Rec_Type := NULL,
   x_return_status    OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    Init_Party_Rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE Init_Party_Rec (
   x_party_rec         OUT NOCOPY  Party_Rec_Type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Party_Rec
--
-- PURPOSE
--    For Update_Party, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_listdr_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_Party_Rec (
   p_party_rec      IN  Party_Rec_Type,
   x_complete_rec   OUT NOCOPY Party_Rec_Type
);


--------------------------------------------------------------------
-- PROCEDURE
--    Refresh_Key
-- PURPOSE
--    Concurrent program which updates AMS_PARTY_DEDUPE with the
--    DEDUPE_KEY, derived from HZ_PARTIES.
--------------------------------------------------------------------
PROCEDURE Refresh_Key (
   errbuf         OUT NOCOPY VARCHAR2,
   retcode        OUT NOCOPY NUMBER,
   p_word_replacement_flag IN VARCHAR2,
   p_commit_flag           IN VARCHAR2
);


--------------------------------------------------------------------
-- PROCEDURE
--    Process_Party
-- PURPOSE
--    Process an imported record using business rules
--    which validate against HZ_PARTIES.  Those records
--    are then created in AMS_PARTY_SOURCES.
--------------------------------------------------------------------
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
);


--------------------------------------------------------------------
-- PROCEDURE
--    Schedule_PartyProcess
-- PURPOSE
--    Used as a concurrent program to process all imported
--    records for a given import header.
--------------------------------------------------------------------
PROCEDURE Schedule_Party_Process (
   errbuf                  OUT NOCOPY   VARCHAR2,
   retcode                 OUT NOCOPY   NUMBER,
   p_import_list_header_id IN    NUMBER,
   p_word_replacement_flag IN    VARCHAR2
);


END AMS_PartyImport_PVT;

 

/
