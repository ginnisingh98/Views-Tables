--------------------------------------------------------
--  DDL for Package AMS_LISTHEADER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LISTHEADER_PUB" AUTHID CURRENT_USER AS
/* $Header: amsplshs.pls 115.14 2002/11/22 08:54:18 jieli ship $ */
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
  p_listheader_rec           IN     AMS_LISTHEADER_PVT.list_header_rec_type,
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
  p_listheader_rec           IN     AMS_LISTHEADER_PVT.list_header_rec_type
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
  p_validation_level         IN     NUMBER      := FND_API.g_valid_level_full,
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
( p_api_version             IN  NUMBER,
  p_init_msg_list           IN  VARCHAR2    := FND_API.G_FALSE,
  p_validation_level        IN  NUMBER      := FND_API.g_valid_level_full,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2,
  p_listheader_id           IN  NUMBER,
  p_object_version          IN  NUMBER
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
( p_api_version             IN     NUMBER,
  p_init_msg_list           IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level        IN     NUMBER      := FND_API.g_valid_level_full,
  x_return_status           OUT NOCOPY    VARCHAR2,
  x_msg_count               OUT NOCOPY    NUMBER,
  x_msg_data                OUT NOCOPY    VARCHAR2,
  p_listheader_rec          IN     AMS_LISTHEADER_PVT.list_header_rec_type
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
  p_source_listheader_id     IN     NUMBER,
  p_listheader_rec           IN     AMS_LISTHEADER_PVT.list_header_rec_type,
  p_copy_select_actions      IN     VARCHAR2  := 'Y',
  p_copy_list_queries        IN     VARCHAR2  := 'Y',
  p_copy_list_entries        IN     VARCHAR2  := 'Y',

  x_listheader_id            OUT NOCOPY    NUMBER
);




END AMS_LISTHEADER_PUB; -- Package spec

 

/
