--------------------------------------------------------
--  DDL for Package AMS_LISTACTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LISTACTION_PVT" AUTHID CURRENT_USER as
/* $Header: amsvlsas.pls 115.13 2002/11/22 08:55:49 jieli ship $ */
-- Start of Comments
--
-- PACKAGE
--   AMS_ListAction_PVT

--   Procedures:

--   Create_ListAction
--   Update_ListAction
--   Delete_ListAction
--   Lock_ListAction
--   Validate_ListAction
--   Init_action_rec
--   Complete_action_rec


-- HISTORY
--   01/22/2001        vbhandar    created
--   02/19/2001        sveerave    included no_of_rows_targeted in action_rec_type
-- End of Comments

TYPE action_rec_type IS RECORD(
  LIST_SELECT_ACTION_ID            NUMBER
 ,LAST_UPDATE_DATE                 DATE
 ,LAST_UPDATED_BY                  NUMBER
 ,CREATION_DATE                    DATE
 ,CREATED_BY                       NUMBER
 ,LAST_UPDATE_LOGIN                NUMBER
 ,OBJECT_VERSION_NUMBER            NUMBER
-- ,LIST_HEADER_ID                 NUMBER
 ,ORDER_NUMBER                     NUMBER
 ,LIST_ACTION_TYPE                 VARCHAR2(30)
-- ,INCL_OBJECT_NAME                 VARCHAR2(254)
 ,ARC_INCL_OBJECT_FROM             VARCHAR2(30)
 ,INCL_OBJECT_ID                   NUMBER
-- ,INCL_OBJECT_WB_SHEET             VARCHAR2(254)
-- ,INCL_OBJECT_WB_OWNER             NUMBER
-- ,INCL_OBJECT_CELL_CODE            VARCHAR2(30)
 ,RANK                             NUMBER
 ,NO_OF_ROWS_AVAILABLE             NUMBER
 ,NO_OF_ROWS_REQUESTED             NUMBER
 ,NO_OF_ROWS_USED                  NUMBER
 ,DISTRIBUTION_PCT                 NUMBER
 ,RESULT_TEXT                      VARCHAR2(4000)
 ,DESCRIPTION                      VARCHAR2(4000)
 ,ARC_ACTION_USED_BY               VARCHAR2(30)
 ,ACTION_USED_BY_ID                NUMBER
 ,NO_OF_ROWS_TARGETED              NUMBER
 ,incl_control_group               varchar2(1)
 );



---------------------------------------------------------------------
-- PROCEDURE
--    Create_ListAction
--
-- PURPOSE
--    Create a new List Select Action.
--
-- PARAMETERS
--    p_action_rec: the new record to be inserted
--    x_action_id: return the campaign_id of the new campaign
--
-- NOTES
--   1. object_version_number will be set to 1.
--   2. If action_id is passed in, the uniqueness will be checked.
--      Raise exception in case of duplicates.
--   3. If action_id is not passed in, generate a unique one from
--      the sequence.
--   4. If a flag column is passed in, check if it is 'Y' or 'N'.
--      Raise exception for invalid flag.
--   5. If a flag column is not passed in, default it to 'Y' or 'N'.
--   6. Please don't pass in any FND_API.g_mess_char/num/date.
--   7. Since it is a generic api check whether valid arc_action_used_by
--      is passed
---------------------------------------------------------------------
PROCEDURE Create_ListAction
( p_api_version                          IN     NUMBER,
  p_init_msg_list                        IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit                               IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level                     IN     NUMBER
                                                := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                        OUT NOCOPY    VARCHAR2,
  x_msg_count                            OUT NOCOPY    NUMBER,
  x_msg_data                             OUT NOCOPY    VARCHAR2,

  p_action_rec                           IN     action_rec_type,
  x_action_id                            OUT NOCOPY    NUMBER
) ;

---------------------------------------------------------------------
-- PROCEDURE
--    Update_ListAction
--
-- PURPOSE
--    Update a List Action.
--
-- PARAMETERS
--    p_action_rec: the record with new items
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
-- End Of Comments
PROCEDURE Update_ListAction
( p_api_version                          IN     NUMBER,
  p_init_msg_list                        IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit                               IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level                     IN     NUMBER
                                                            := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                        OUT NOCOPY    VARCHAR2,
  x_msg_count                            OUT NOCOPY    NUMBER,
  x_msg_data                             OUT NOCOPY    VARCHAR2,

  p_action_rec                           IN     action_rec_type
);

-- Start of Comments
--------------------------------------------------------------------
-- PROCEDURE
--    Delete_ListAction
--
-- PURPOSE
--    Delete a List Action.
--
-- PARAMETERS
--    p_action_id:      the action_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
-- End Of Comments
PROCEDURE Delete_ListAction
( p_api_version                          IN     NUMBER,
  p_init_msg_list                        IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit                               IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level                     IN     NUMBER      := FND_API.G_VALID_LEVEL_FULL,

  x_return_status                        OUT NOCOPY    VARCHAR2,
  x_msg_count                            OUT NOCOPY    NUMBER,
  x_msg_data                             OUT NOCOPY    VARCHAR2,

  p_action_id                            IN     NUMBER
);

-- Start of Comments
-------------------------------------------------------------------
-- PROCEDURE
--     Lock_ListAction
--
-- PURPOSE
--    Lock a List Action.
--
-- PARAMETERS
--    p_action_id: the action_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
-- End Of Comments
PROCEDURE Lock_ListAction
( p_api_version                          IN     NUMBER,
  p_init_msg_list                        IN     VARCHAR2 := FND_API.G_FALSE,
  p_validation_level                     IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,

  x_return_status                        OUT NOCOPY    VARCHAR2,
  x_msg_count                            OUT NOCOPY    NUMBER,
  x_msg_data                             OUT NOCOPY    VARCHAR2,

  p_action_id                            IN     NUMBER,
  p_object_version                       IN     NUMBER
);


-- Start of Comments
---------------------------------------------------------------------
-- PROCEDURE
--    Validate_ListAction
--
-- PURPOSE
--    Validate a List Action.
--
-- PARAMETERS
--    p_action_rec: the list action record to be validated
--
-- NOTES
--    1. p_action_rec should be the complete list action record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
-- End Of Comments
PROCEDURE Validate_ListAction
( p_api_version                          IN     NUMBER,
  p_init_msg_list                        IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level                     IN     NUMBER
                                                            := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                        OUT NOCOPY    VARCHAR2,
  x_msg_count                            OUT NOCOPY    NUMBER,
  x_msg_data                             OUT NOCOPY    VARCHAR2,

  p_action_rec                       IN     action_rec_type
);

---------------------------------------------------------------------
-- PROCEDURE
--    init_action_rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE init_action_rec(
  x_action_rec  OUT NOCOPY  action_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    complete_action_rec
--
-- PURPOSE
--    For update_action, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_action_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE complete_action_rec(
   p_action_rec      IN  action_rec_type,
   x_complete_rec   OUT NOCOPY  action_rec_type
);

END AMS_ListAction_PVT;

 

/
