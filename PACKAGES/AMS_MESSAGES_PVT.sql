--------------------------------------------------------
--  DDL for Package AMS_MESSAGES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_MESSAGES_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvmsgs.pls 115.12 2002/11/15 21:02:34 abhola ship $ */

TYPE msg_rec_type IS RECORD
(
  MESSAGE_ID               NUMBER,
  LAST_UPDATE_DATE         DATE,
  LAST_UPDATED_BY          NUMBER,
  CREATION_DATE            DATE,
  CREATED_BY               NUMBER,
  LAST_UPDATE_LOGIN        NUMBER,
  OBJECT_VERSION_NUMBER    NUMBER,
  DATE_EFFECTIVE_FROM      DATE,
  DATE_EFFECTIVE_TO        DATE,
  ACTIVE_FLAG              VARCHAR2(1),
  MESSAGE_TYPE_CODE        VARCHAR2(30),
  OWNER_USER_ID            NUMBER,
  MESSAGE_NAME             VARCHAR2(120),
  DESCRIPTION              VARCHAR2(4000),
  COUNTRY_ID               NUMBER,
  attribute_category            VARCHAR2(30),
  attribute1                    VARCHAR2(150),
  attribute2                    VARCHAR2(150),
  attribute3                    VARCHAR2(150),
  attribute4                    VARCHAR2(150),
  attribute5                    VARCHAR2(150),
  attribute6                    VARCHAR2(150),
  attribute7                    VARCHAR2(150),
  attribute8                    VARCHAR2(150),
  attribute9                    VARCHAR2(150),
  attribute10                   VARCHAR2(150),
  attribute11                   VARCHAR2(150),
  attribute12                   VARCHAR2(150),
  attribute13                   VARCHAR2(150),
  attribute14                   VARCHAR2(150),
  attribute15                   VARCHAR2(150)
);


/****************************************************************************/
-- Procedure
--   create_message
-- Purpose
--   create a row in AMS_MESSAGES_B and AMS_MESSAGES_TL
-- Parameters
--   IN:
--     p_api_version         IN      NUMBER
--     p_init_msg_list       IN      VARCHAR2 := FND_API.g_false
--     p_commit              IN      VARCHAR2 := FND_API.g_false
--     p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full
--
--     p_msg_rec             IN      msg_rec_type
--
--   OUT:
--     x_return_status       OUT     VARCHAR2
--     x_msg_count           OUT     NUMBER
--     x_msg_data            OUT     VARCHAR2
--
--     x_msg_id         OUT     NUMBER
------------------------------------------------------------------------------
PROCEDURE create_msg
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_commit              IN      VARCHAR2 := FND_API.g_false,
  p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER,
  x_msg_data            OUT NOCOPY     VARCHAR2,

  p_msg_rec             IN      msg_rec_type,
  x_msg_id              OUT NOCOPY     NUMBER
);

/****************************************************************************/
-- Procedure
--   update_msg
-- Purpose
--   update a row in AMS_MESSAGES_B and AMS_MESSAGES_TL
-- Parameters
--   IN:
--     p_api_version         IN      NUMBER
--     p_init_msg_list       IN      VARCHAR2 := FND_API.g_false
--     p_commit              IN      VARCHAR2 := FND_API.g_false
--     p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full
--
--     p_msg_rec             IN      msg_rec_type
--
--   OUT:
--     x_return_status      OUT      VARCHAR2
--     x_msg_count          OUT      NUMBER
--     x_msg_data           OUT      VARCHAR2
------------------------------------------------------------------------------
PROCEDURE update_msg
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_commit              IN      VARCHAR2 := FND_API.g_false,
  p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER,
  x_msg_data            OUT NOCOPY     VARCHAR2,

  p_msg_rec             IN      msg_rec_type
);

/****************************************************************************/
-- Procedure
--   delete_msg
-- Purpose
--   delete a row from AMS_MESSAGES_B and AMS_MESSAGES_TL
-- Parameters
--   IN:
--     p_api_version       IN      NUMBER
--     p_init_msg_list     IN      VARCHAR2 := FND_API.g_false
--     p_commit            IN      VARCHAR2 := FND_API.g_false
--
--     p_msg_id            IN      NUMBER
--     p_object_version    IN      NUMBER
--
--   OUT:
--     x_return_status     OUT     VARCHAR2
--     x_msg_count         OUT     NUMBER
--     x_msg_data          OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE delete_msg
(
  p_api_version       IN      NUMBER,
  p_init_msg_list     IN      VARCHAR2 := FND_API.g_false,
  p_commit            IN      VARCHAR2 := FND_API.g_false,

  x_return_status     OUT NOCOPY     VARCHAR2,
  x_msg_count         OUT NOCOPY     NUMBER,
  x_msg_data          OUT NOCOPY     VARCHAR2,

  p_msg_id            IN      NUMBER,
  p_object_version    IN      NUMBER
);

/****************************************************************************/
-- Procedure
--   lock_msg
-- Purpose
--   lock a row form AMS_MESSAGES_B and AMS_MESSAGES_TL
-- Parameters
--   IN:
--     p_api_version         IN      NUMBER
--     p_init_msg_list       IN      VARCHAR2 := FND_API.g_false
--
--     p_msg_id         IN      NUMBER
--     p_object_version      IN      NUMBER
--
--   OUT:
--     x_return_status       OUT     VARCHAR2
--     x_msg_count           OUT     NUMBER
--     x_msg_data            OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE lock_msg
(
  p_api_version       IN      NUMBER,
  p_init_msg_list     IN      VARCHAR2 := FND_API.g_false,

  x_return_status     OUT NOCOPY     VARCHAR2,
  x_msg_count         OUT NOCOPY     NUMBER,
  x_msg_data          OUT NOCOPY     VARCHAR2,

  p_msg_id            IN      NUMBER,
  p_object_version    IN      NUMBER
);

/***************************************************************************/
-- Procedure
--   validate_msg
-- Purpose
--   validate a record before inserting or updating
--   AMS_MESSAGES_B and AMS_MESSAGES_TL
-- Parameters
--   IN:
--     p_api_version         IN      NUMBER
--     p_init_msg_list       IN      VARCHAR2 := FND_API.g_false
--     p_validation_level    IN      NUMBER := FND_API.g_valid_level_full
--
--     p_msg_rec             IN      msg_rec_type
--
--   OUT:
--     x_return_status       OUT     VARCHAR2
--     x_msg_count           OUT     NUMBER
--     x_msg_data            OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE validate_msg
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_validation_level    IN      NUMBER := FND_API.g_valid_level_full,

  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER,
  x_msg_data            OUT NOCOPY     VARCHAR2,

  p_msg_rec             IN      msg_rec_type
);

/****************************************************************************/
-- Procedure
--   check_items
-- Purpose
--   item_level validate
-- Parameters
--   IN:
--     p_validation_mode    IN      VARCHAR2
--     p_msg_rec            IN      msg_rec_type
--   OUT:
--     x_return_status      OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_items
(
    p_validation_mode    IN      VARCHAR2,
    x_return_status      OUT NOCOPY     VARCHAR2,
    p_msg_rec            IN      msg_rec_type
);

/****************************************************************************/
-- Procedure
--   check_req_items
-- Purpose
--   check if required items are missing
-- Parameters
--   IN:
--     p_validation_mode    IN      VARCHAR2
--     p_msg_rec            IN      msg_rec_type
--   OUT:
--     x_return_status      OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_req_items
(
  p_validation_mode    IN      VARCHAR2,
  p_msg_rec       IN      msg_rec_type,
  x_return_status      OUT NOCOPY     VARCHAR2
);

/****************************************************************************/
-- Procedure
--   check_uk_items
-- Purpose
--   check unique key items
-- Parameters
--   IN:
--     p_validation_mode    IN      VARCHAR2
--     p_msg_rec            IN      msg_rec_type
--   OUT:
--     x_return_status      OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_uk_items
(
  p_validation_mode    IN      VARCHAR2 := JTF_PLSQL_API.g_create,
  p_msg_rec            IN      msg_rec_type,
  x_return_status      OUT NOCOPY     VARCHAR2
);

/*****************************************************************************/
-- Procedure
--    check_record
-- Purpose
--   record level check
-- Parameters
--   IN:
--     p_msg_rec         IN      msg_rec_type
--     p_complete_rec    IN      msg_rec_type
--   OUT:
--     x_return_status   OUT     VARCHAR2
-- HISTORY
-------------------------------------------------------------------------------
PROCEDURE check_record
(
  p_msg_rec         IN  msg_rec_type,
  p_complete_rec    IN  msg_rec_type,
  x_return_status   OUT NOCOPY VARCHAR2
);

/****************************************************************************/
-- Procedure
--   complete_rec
-- Purpose
--   replace "g_miss" values with current database values
-- Parameters
--   IN:
--     p_msg_rec         IN      msg_rec_type
--   OUT:
--     x_complete_rec    OUT     msg_rec_type
------------------------------------------------------------------------------
PROCEDURE complete_msg_rec
(
  p_msg_rec         IN      msg_rec_type,
  x_complete_rec    OUT NOCOPY     msg_rec_type
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
  x_msg_rec  OUT NOCOPY  msg_rec_type
);

END AMS_Messages_PVT;

 

/
