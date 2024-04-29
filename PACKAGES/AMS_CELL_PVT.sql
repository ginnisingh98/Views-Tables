--------------------------------------------------------
--  DDL for Package AMS_CELL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CELL_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvcels.pls 120.0 2005/05/31 15:48:15 appldev noship $ */


TYPE cell_rec_type IS RECORD(
CELL_ID                                  NUMBER,
SEL_TYPE                                 VARCHAR2(30),
LAST_UPDATE_DATE                         DATE,
LAST_UPDATED_BY                          NUMBER,
CREATION_DATE                            DATE,
CREATED_BY                               NUMBER,
LAST_UPDATE_LOGIN                        NUMBER,
OBJECT_VERSION_NUMBER                    NUMBER,
CELL_CODE                                VARCHAR2(30),
ENABLED_FLAG                             VARCHAR2(1),
ORIGINAL_SIZE                            NUMBER,
PARENT_CELL_ID                           NUMBER,
ORG_ID                                   NUMBER,
OWNER_ID                                 NUMBER,
CELL_NAME                                VARCHAR2(120),
DESCRIPTION                              VARCHAR2(4000),
STATUS_CODE                              VARCHAR2(30),
STATUS_DATE                              DATE,
USER_STATUS_ID                           NUMBER
);

TYPE sqlcell_rec_type IS RECORD(
CELL_ID                                  NUMBER,
SEL_TYPE                                 VARCHAR2(30),
LAST_UPDATE_DATE                         DATE,
LAST_UPDATED_BY                          NUMBER,
CREATION_DATE                            DATE,
CREATED_BY                               NUMBER,
LAST_UPDATE_LOGIN                        NUMBER,
OBJECT_VERSION_NUMBER                    NUMBER,
CELL_CODE                                VARCHAR2(30),
ENABLED_FLAG                             VARCHAR2(1),
ORIGINAL_SIZE                            NUMBER,
PARENT_CELL_ID                           NUMBER,
ORG_ID                                   NUMBER,
OWNER_ID                                 NUMBER,
CELL_NAME                                VARCHAR2(120),
DESCRIPTION                              VARCHAR2(4000),
STATUS_CODE                              VARCHAR2(30),
STATUS_DATE                              DATE,
USER_STATUS_ID                           NUMBER,
DISCOVERER_SQL_ID                        NUMBER,
WORKBOOK_OWNER                           VARCHAR2(100),
WORKBOOK_NAME                            VARCHAR2(254),
WORKSHEET_NAME                           VARCHAR2(254),
ACTIVITY_DISCOVERER_ID                   NUMBER,
ACT_DISC_VERSION_NUMBER                  NUMBER,
LIST_QUERY_ID                            NUMBER,
LIST_SQL_STRING                          VARCHAR2(4000),
SOURCE_OBJECT_NAME                       VARCHAR2(60),
LIST_QUERY_VERSION_NUMBER                NUMBER
);

TYPE t_number        is TABLE OF NUMBER INDEX BY BINARY_INTEGER;

---------------------------------------------------------------------
-- PROCEDURE
--    create_cell
--
-- PURPOSE
--    Create a new cell
--
-- PARAMETERS
--    p_cell_rec: the new record to be inserted
--    x_cell_id: return the cell_id of the new cell
--
-- NOTES
--    1. Please don't pass in any FND_API.g_mess_char/num/date.
--    2. object_version_number will be set to 1.
--    3. If cell_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates. If cell_id is not
--       passed in, generate a unique one from the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag. If a flag column is not
--       passed in, default it to 'Y' or 'N'.
--    5.  If the market segmentflag is passed null then it will be defaulted to N
--    6.  If the market segmentflag is passed null then it will be defaulted to Y
---------------------------------------------------------------------
PROCEDURE create_cell(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_cell_rec          IN  cell_rec_type,
   x_cell_id           OUT NOCOPY NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    delete_cell
--
-- PURPOSE
--    Set the cell to be disabled so that it won't be available
--    to users.
--
-- PARAMETERS
--    p_cell_id: the cell_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. Will set the cells to be disabled, instead of remove it
--       from database.
--------------------------------------------------------------------
PROCEDURE delete_cell(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_commit            IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_cell_id           IN  NUMBER,
   p_object_version    IN  NUMBER
);


-------------------------------------------------------------------
-- PROCEDURE
--    lock_cell
--
-- PURPOSE
--    Lock a celln
--
-- PARAMETERS
--    p_cell_id: the cell_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE lock_cell(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_cell_id           IN  NUMBER,
   p_object_version    IN  NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    update_cell
--
-- PURPOSE
--    Update a cell
--
-- PARAMETERS
--    p_cell_rec: the record with new items
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE update_cell(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_cell_rec          IN  cell_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    validate_cell
--
-- PURPOSE
--    Validate a cell record.
--
-- PARAMETERS
--    p_cell_rec: the record to be validated
--
-- NOTES
--    1. p_cell_rec should be the complete cell record wothout
--       any FND_API.g_miss_char/num/date items.
----------------------------------------------------------------------
PROCEDURE validate_cell(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_cell_rec          IN  cell_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    check_cell_items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_cell_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE check_cell_items(
   p_cell_rec        IN  cell_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
);



---------------------------------------------------------------------
-- PROCEDURE
--    init_cell_rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE init_cell_rec(
   x_cell_rec         OUT NOCOPY  cell_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    complete_cell_rec
--
-- PURPOSE
--    For update_cell, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_cell_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
--
-- NOTES
--    1. If a valid status_date is provided, use it. If not, set it
--       to be the original value or SYSDATE depending on whether
--       the user_status_id is cellged or not.
---------------------------------------------------------------------
PROCEDURE complete_cell_rec(
   p_cell_rec       IN  cell_rec_type,
   x_complete_rec   OUT NOCOPY cell_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    add_sel_workbook
--
-- PURPOSE
--    insert a new entry into table ams_act_discoverer_all
--    if the segment selection type is Workbook
--
-- PARAMETERS
--    p_cell_id: the cell_id of the segment
--    p_discoverer_sql_id: the discoverer_sql_id of the workbook/worksheet
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE add_sel_workbook(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_cell_id           IN  NUMBER,
   p_discoverer_sql_id IN  NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    add_sel_sql
--
-- HISTORY
--    02/02/01  yxliu  Created.
---------------------------------------------------------------------
PROCEDURE add_sel_sql(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_cell_id           IN  NUMBER,
   p_cell_name         IN  VARCHAR2,
   p_cell_code         IN  VARCHAR2,
   p_sql_string        IN  VARCHAR2,
   p_source_object_name IN VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    get_single_sql
--
-- PURPOSE
--    Get all the sql statements for one segment
--
-- PARAMETERS
--    p_cell_id: the cell_id of the segment
--    x_sql_string: return the sql statements for the segment
--
-- NOTES
--    1. Select type from ams_cells_all_b where cell_id = p_cell_id
--    2. if type is DISCOVERER, select workbook_name, worksheet_name from
--       ams_act_discoverer_all where ac_discoverer_used_by_id = p_cell_id,
--       Then use the workbook info to get the sql string from
--       ams_discoverer_sql
--    3. If type is SQL, get SQL string from ams_list_queries_all where
--       act_list_query_used_by = p_cell_id
---------------------------------------------------------------------
PROCEDURE get_single_sql(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_cell_id           IN  NUMBER,
   x_sql_string        OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    get_comp_sql
--
-- PURPOSE
--    Get intersection sql statement for one segment and all its
--    ancestors
--
-- PARAMETERS
--    p_cell_id: the cell_id of the segment
--    p_party_id_only: only keep the party_id column in the select part of
--               current cell's sql? TRUE is yes, FALSE is no.
--    x_sql_tbl: return a PL/SQL table hold the compose sql statements
--               for the segment and all its ancestors
--
-- NOTES
--    comment out for rosetta's sake
---------------------------------------------------------------------
PROCEDURE get_comp_sql(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_cell_id           IN  NUMBER,
   p_party_id_only     IN  VARCHAR2  := FND_API.g_false,
   x_sql_tbl           OUT NOCOPY DBMS_SQL.VARCHAR2S
);

---------------------------------------------------------------------
-- PROCEDURE
--    format_sql_string
--
-- PURPOSE
--    Take the input sql string, manipulate it so that party_id is the
--    only column in the select clause, all the substring after FROM
--    of the original string is not altered.
--
-- PARAMETERS
--    p_string: the input sql string
--    x_string: the output sql string is keeps all the part after 'FROM'
--              but have only PARTY_ID or ams_table.PARTY_ID in the
--              select clause. i.e., SELECT *.party_id FROM ....
--              for the segment and all its ancestors
--
-- NOTES
---------------------------------------------------------------------

procedure format_sql_string
(
   p_string            IN  VARCHAR2,
   x_string            OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    format_sql_string
--
-- PURPOSE
--    Take the input sql string, manipulate it so that party_id is the
--    only column in the select clause, all the substring after FROM
--    of the original string is not altered.
--
-- PARAMETERS
--    p_string: the input sql string
--    x_string: the output sql string is keeps all the part after 'FROM'
--              but have only PARTY_ID or ams_table.PARTY_ID in the
--              select clause. i.e., SELECT *.party_id FROM ....
--              for the segment and all its ancestors
----    x_party_id_string:
--             ams_table.PARTY_ID
--              for the segment and all its ancestors
-- NOTES
---------------------------------------------------------------------

procedure format_sql_string
(
   p_string            IN  VARCHAR2,
   x_string            OUT NOCOPY VARCHAR2,
   x_party_id_string   OUT NOCOPY VARCHAR2
);
---------------------------------------------------------------------
-- PROCEDURE
--    get_workbook_sql
--
-- HISTORY
--    03/01/2001  yxliu  Created.
---------------------------------------------------------------------
PROCEDURE get_workbook_sql(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_disc_sql_id       IN  NUMBER,
   x_sql_string        OUT NOCOPY VARCHAR2
);
---------------------------------------------------------------------
-- PROCEDURE
--    get_segment_size
--
-- HISTORY
--    03/01/2001  yxliu  Created.
---------------------------------------------------------------------
PROCEDURE get_segment_size(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_sql_string        IN  VARCHAR2,
   x_segment_size              OUT NOCOPY NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    get_comp_segment_size
--
-- HISTORY
--    04/16/2001  yxliu  Created. using the get_comp_sql to get the segment
--                       size which means segment and all its ancestors'
--                       criteria.
---------------------------------------------------------------------
PROCEDURE get_comp_segment_size(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_cell_id           IN  NUMBER,
   x_segment_size      OUT NOCOPY NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    create_sql_cell
--
-- HISTORY
--    03/01/01  yxliu   created, create a segment and add entries into
--                      corresponding mapping tables
---------------------------------------------------------------------
PROCEDURE create_sql_cell(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_sql_cell_rec      IN  sqlcell_rec_type,
   x_cell_id           OUT NOCOPY NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    update_sql_cell
--
-- HISTORY
--    03/01/01  yxliu   created, update the segment and based on the sel_type,
--                      update the corresponding mapping tables
---------------------------------------------------------------------
PROCEDURE update_sql_cell(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_sql_cell_rec      IN  sqlcell_rec_type
);

/*****************************************************************************/
-- Procedure
--   Update_Segment_Size
--
-- Purpose
--   This procedure will calculate the segment size for
--
-- Notes
--
--
-- History
--   04/09/2001      yxliu    created
------------------------------------------------------------------------------
PROCEDURE Update_Segment_Size
(   p_cell_id        IN    NUMBER DEFAULT NULL,
    x_return_status  OUT NOCOPY   VARCHAR2,
    x_msg_count      OUT NOCOPY   NUMBER,
    x_msg_data       OUT NOCOPY   VARCHAR2
);

/*****************************************************************************/
-- Procedure
--   Refresh_Segment_Size
--
-- Purpose
--   This procedure is created to as a concurrent program which
--   will call the update_segment_size and will return errors if any
--
-- Notes
--
--
-- History
--   04/09/2001      yxliu    created
--   06/20/2001      yxliu    moved to package AMS_Party_Mkt_Seg_Loader_PVT
------------------------------------------------------------------------------

--PROCEDURE Refresh_Segment_Size
--(   errbuf        OUT NOCOPY    VARCHAR2,
--    retcode       OUT    NUMBER,
--    p_cell_id     IN     NUMBER DEFAULT NULL
--);

END AMS_CEll_PVT;

 

/
