--------------------------------------------------------
--  DDL for Package AMS_LISTACTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LISTACTION_PUB" AUTHID CURRENT_USER AS
/* $Header: amsplsas.pls 115.11 2002/11/22 08:54:09 jieli ship $ */
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
--    1. object_version_number will be set to 1.
--    2. If action_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If action_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
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

  p_action_rec                           IN     AMS_LISTACTION_PVT.action_rec_type,
  x_action_id                            OUT NOCOPY    NUMBER
) ;

-- Start of Comments
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

  p_action_rec                      IN     AMS_LISTACTION_PVT.action_rec_type
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

  p_action_rec                           IN     AMS_LISTACTION_PVT.action_rec_type
);


END AMS_LISTACTION_PUB; -- Package spec

 

/
