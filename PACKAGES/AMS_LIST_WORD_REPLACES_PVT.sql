--------------------------------------------------------
--  DDL for Package AMS_LIST_WORD_REPLACES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LIST_WORD_REPLACES_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvwdrs.pls 115.5 2002/11/22 08:56:37 jieli ship $ */

TYPE wrd_rpl_rec_type IS RECORD
(
  LIST_WORD_REPLACES_ID    NUMBER,
  LAST_UPDATE_DATE         DATE,
  LAST_UPDATED_BY          NUMBER,
  CREATION_DATE            DATE,
  CREATED_BY               NUMBER,
  LAST_UPDATE_LOGIN        NUMBER,
  OBJECT_VERSION_NUMBER    NUMBER,
  ORIGINAL_WORD            VARCHAR2(120),
  REPLACEMENT_WORD         VARCHAR2(120),
  ENABLED_FLAG             VARCHAR2(1),
  DESCRIPTION              VARCHAR2(4000)
);


/****************************************************************************/
-- Procedure
--   create_list_word_replace
-- Purpose
--   create a row in AMS_LIST_WORD_REPLACES
-- Parameters
--   IN:
--     p_api_version         IN      NUMBER
--     p_init_msg_list       IN      VARCHAR2 := FND_API.g_false
--     p_commit              IN      VARCHAR2 := FND_API.g_false
--     p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full
--
--     p_wrd_rpl_rec         IN      wrd_rpl_rec_type
--
--   OUT:
--     x_return_status       OUT     VARCHAR2
--     x_msg_count           OUT     NUMBER
--     x_msg_data            OUT     VARCHAR2
--
--     x_wrd_rpl_id          OUT     NUMBER
------------------------------------------------------------------------------
PROCEDURE create_list_word_replace
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_commit              IN      VARCHAR2 := FND_API.g_false,
  p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER,
  x_msg_data            OUT NOCOPY     VARCHAR2,

  p_wrd_rpl_rec         IN      wrd_rpl_rec_type,
  x_wrd_rpl_id          OUT NOCOPY     NUMBER
);

/****************************************************************************/
-- Procedure
--   update_list_word_replace
-- Purpose
--   update a row in AMS_LIST_WORD_REPLACES
-- Parameters
--   IN:
--     p_api_version         IN      NUMBER
--     p_init_msg_list       IN      VARCHAR2 := FND_API.g_false
--     p_commit              IN      VARCHAR2 := FND_API.g_false
--     p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full
--
--     p_wrd_rpl_rec         IN      wrd_rpl_rec_type
--
--   OUT:
--     x_return_status       OUT      VARCHAR2
--     x_msg_count           OUT      NUMBER
--     x_msg_data            OUT      VARCHAR2
------------------------------------------------------------------------------
PROCEDURE update_list_word_replace
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_commit              IN      VARCHAR2 := FND_API.g_false,
  p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER,
  x_msg_data            OUT NOCOPY     VARCHAR2,

  p_wrd_rpl_rec         IN      wrd_rpl_rec_type
);

/****************************************************************************/
-- Procedure
--   delete_list_word_replace
-- Purpose
--   delete a row from AMS_LIST_WORD_REPLACES
-- Parameters
--   IN:
--     p_api_version       IN      NUMBER
--     p_init_msg_list     IN      VARCHAR2 := FND_API.g_false
--     p_commit            IN      VARCHAR2 := FND_API.g_false
--
--     p_wrd_rpl_id        IN      NUMBER
--     p_object_version    IN      NUMBER
--
--   OUT:
--     x_return_status     OUT     VARCHAR2
--     x_msg_count         OUT     NUMBER
--     x_msg_data          OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE delete_list_word_replace
(
  p_api_version       IN      NUMBER,
  p_init_msg_list     IN      VARCHAR2 := FND_API.g_false,
  p_commit            IN      VARCHAR2 := FND_API.g_false,

  x_return_status     OUT NOCOPY     VARCHAR2,
  x_msg_count         OUT NOCOPY     NUMBER,
  x_msg_data          OUT NOCOPY     VARCHAR2,

  p_wrd_rpl_id        IN      NUMBER,
  p_object_version    IN      NUMBER
);

/****************************************************************************/
-- Procedure
--   lock_list_word_replace
-- Purpose
--   lock a row form AMS_LIST_WORD_REPLACES
-- Parameters
--   IN:
--     p_api_version         IN      NUMBER
--     p_init_msg_list       IN      VARCHAR2 := FND_API.g_false
--
--     p_wrd_rpl_id          IN      NUMBER
--     p_object_version      IN      NUMBER
--
--   OUT:
--     x_return_status       OUT     VARCHAR2
--     x_msg_count           OUT     NUMBER
--     x_msg_data            OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE lock_list_word_replace
(
  p_api_version       IN      NUMBER,
  p_init_msg_list     IN      VARCHAR2 := FND_API.g_false,

  x_return_status     OUT NOCOPY     VARCHAR2,
  x_msg_count         OUT NOCOPY     NUMBER,
  x_msg_data          OUT NOCOPY     VARCHAR2,

  p_wrd_rpl_id        IN      NUMBER,
  p_object_version    IN      NUMBER
);

/***************************************************************************/
-- Procedure
--   validate_list_word_replace
-- Purpose
--   validate a record before inserting or updating
--   AMS_LIST_WORD_REPLACES
-- Parameters
--   IN:
--     p_api_version         IN      NUMBER
--     p_init_msg_list       IN      VARCHAR2 := FND_API.g_false
--     p_validation_level    IN      NUMBER := FND_API.g_valid_level_full
--
--     p_wrd_rpl_rec         IN      wrd_rpl_rec_type
--
--   OUT:
--     x_return_status       OUT     VARCHAR2
--     x_msg_count           OUT     NUMBER
--     x_msg_data            OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE validate_list_word_replace
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_validation_level    IN      NUMBER := FND_API.g_valid_level_full,

  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER,
  x_msg_data            OUT NOCOPY     VARCHAR2,

  p_wrd_rpl_rec         IN      wrd_rpl_rec_type
);

/****************************************************************************/
-- Procedure
--   check_items
-- Purpose
--   item_level validate
-- Parameters
--   IN:
--     p_validation_mode    IN      VARCHAR2
--     p_wrd_rpl_rec        IN      wrd_rpl_rec_type
--   OUT:
--     x_return_status      OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_items
(
    p_validation_mode    IN      VARCHAR2,
    x_return_status      OUT NOCOPY     VARCHAR2,
    p_wrd_rpl_rec        IN      wrd_rpl_rec_type
);

/****************************************************************************/
-- Procedure
--   check_req_items
-- Purpose
--   check if required items are missing
-- Parameters
--   IN:
--     p_validation_mode    IN      VARCHAR2
--     p_wrd_rpl_rec        IN      wrd_rpl_rec_type
--   OUT:
--     x_return_status      OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_req_items
(
  p_validation_mode    IN      VARCHAR2,
  p_wrd_rpl_rec        IN      wrd_rpl_rec_type,
  x_return_status      OUT NOCOPY     VARCHAR2
);

/****************************************************************************/
-- Procedure
--   check_uk_items
-- Purpose
--   check unique keys
-- Parameters
--   IN:
--     p_validation_mode  IN      VARCHAR2 := JTF_PLSQL_API.g_create,
--     p_wrd_rpl_rec      IN      wrd_rpl_rec_type
--   OUT:
--     x_return_status    OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_uk_items
(
  p_validation_mode   IN      VARCHAR2 := JTF_PLSQL_API.g_create,
  p_wrd_rpl_rec       IN      wrd_rpl_rec_type,
  x_return_status     OUT NOCOPY     VARCHAR2
);

/****************************************************************************/
-- Procedure
--   complete_rec
-- Purpose
--   replace "g_miss" values with current database values
-- Parameters
--   IN:
--     p_wrd_rpl_rec     IN      wrd_rpl_rec_type
--   OUT:
--     x_complete_rec    OUT     wrd_rpl_rec_type
------------------------------------------------------------------------------
PROCEDURE complete_rec
(
  p_wrd_rpl_rec     IN      wrd_rpl_rec_type,
  x_complete_rec    OUT NOCOPY     wrd_rpl_rec_type
);

/****************************************************************************/
-- Procedure
--   init_rec
--
-- HISTORY
--    12/19/1999    julou    Created.
------------------------------------------------------------------------------
PROCEDURE init_rec
(
  x_wrd_rpl_rec  OUT NOCOPY  wrd_rpl_rec_type
);

END AMS_List_Word_Replaces_PVT;

 

/