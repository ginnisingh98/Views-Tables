--------------------------------------------------------
--  DDL for Package AMS_SETUP_ATTR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_SETUP_ATTR_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvatts.pls 115.19 2002/12/30 05:29:13 vmodur ship $ */

TYPE setup_attr_rec_type IS RECORD
(
  SETUP_ATTRIBUTE_ID               NUMBER,
  CUSTOM_SETUP_ID	               NUMBER,
  LAST_UPDATE_DATE                 DATE,
  LAST_UPDATED_BY                  NUMBER,
  CREATION_DATE                    DATE,
  CREATED_BY                       NUMBER,
  LAST_UPDATE_LOGIN                NUMBER,
  OBJECT_VERSION_NUMBER            NUMBER,
  DISPLAY_SEQUENCE_NO              NUMBER,
  OBJECT_ATTRIBUTE                 VARCHAR2(30),
  ATTR_MANDATORY_FLAG              VARCHAR2(1),
  ATTR_AVAILABLE_FLAG              VARCHAR2(1),
  FUNCTION_NAME                    VARCHAR2(30),
  PARENT_FUNCTION_NAME             VARCHAR2(30),
  PARENT_SETUP_ATTRIBUTE           VARCHAR2(30),
  PARENT_DISPLAY_SEQUENCE          NUMBER,
  SHOW_IN_REPORT                   VARCHAR2(1),
  SHOW_IN_CUE_CARD                 VARCHAR2(1),
  COPY_ALLOWED_FLAG                VARCHAR2(1),
  RELATED_AK_ATTRIBUTE             VARCHAR2(30),
  ESSENTIAL_SEQ_NUM                NUMBER
);


/****************************************************************************/
-- Procedure
--   create_setup_attr
-- Purpose
--   create rows in AMS_CUSTOM_SETUP_ATTR
-- Parameters
--   IN:
--     p_api_version         IN      NUMBER
--     p_init_msg_list       IN      VARCHAR2 := FND_API.g_false
--     p_commit              IN      VARCHAR2 := FND_API.g_false
--     p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full
--
--     p_setup_attr_rec      IN      setup_attr_rec_type
--
--   OUT:
--     x_return_status       OUT     VARCHAR2
--     x_msg_count           OUT     NUMBER
--     x_msg_data            OUT     VARCHAR2
--
--     x_setup_attr_id       OUT     NUMBER
------------------------------------------------------------------------------
PROCEDURE create_setup_attr
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_commit              IN      VARCHAR2 := FND_API.g_false,
  p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER,
  x_msg_data            OUT NOCOPY     VARCHAR2,

  p_setup_attr_rec      IN      setup_attr_rec_type,
  x_setup_attr_id       OUT NOCOPY     NUMBER
);


/****************************************************************************/
-- Procedure
--   update_setup_attr
-- Purpose
--   update rows in AMS_CUSTOM_SETUP_ATTR
-- Parameters
--   IN:
--     p_api_version         IN      NUMBER
--     p_init_msg_list       IN      VARCHAR2 := FND_API.g_false
--     p_commit              IN      VARCHAR2 := FND_API.g_false
--     p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full
--
--     p_setup_attr_rec      IN      setup_attr_rec_type
--
--   OUT:
--     x_return_status       OUT     VARCHAR2
--     x_msg_count           OUT     NUMBER
--     x_msg_data            OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE update_setup_attr
(
  p_api_version           IN      NUMBER,
  p_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_commit                IN      VARCHAR2 := FND_API.g_false,
  p_validation_level      IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status         OUT NOCOPY     VARCHAR2,
  x_msg_count             OUT NOCOPY     NUMBER,
  x_msg_data              OUT NOCOPY     VARCHAR2,

  p_setup_attr_rec        IN      setup_attr_rec_type
);


/***************************************************************************/
-- Procedure
--   validate_setup_attr
-- Purpose
--   validate the record
-- Parameters
--   IN:
--     p_api_version        IN      NUMBER
--     p_init_msg_list      IN      VARCHAR2 := FND_API.g_false
--     p_validation_mode    IN      VARCHAR2
--
--     p_setup_attr_rec     IN      setup_attr_rec_type
--
--   OUT:
--     x_return_status      OUT     VARCHAR2
--     x_msg_count          OUT     NUMBER
--     x_msg_data           OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE validate_setup_attr
(
  p_api_version        IN      NUMBER,
  p_init_msg_list      IN      VARCHAR2 := FND_API.g_false,
  p_validation_level   IN      NUMBER := FND_API.g_valid_level_full,

  x_return_status      OUT NOCOPY     VARCHAR2,
  x_msg_count          OUT NOCOPY     NUMBER,
  x_msg_data           OUT NOCOPY     VARCHAR2,

  p_setup_attr_rec     IN      setup_attr_rec_type
);


/****************************************************************************/
-- Procedure
--   check_items
-- Purpose
--   item_level validate
-- Parameters
--   IN:
--     p_validation_mode    IN      VARCHAR2
--     p_setup_attr_rec     IN      setup_attr_rec_type
--   OUT:
--     x_return_status      OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_items
(
    p_validation_mode    IN      VARCHAR2,
    x_return_status      OUT NOCOPY     VARCHAR2,
    p_setup_attr_rec     IN      setup_attr_rec_type
);


/****************************************************************************/
-- Procedure
--   check_setup_attr_req_items
-- Purpose
--   check if required items are miss
-- Parameters
--   IN:
--     p_validation_mode    IN      VARCHAR2
--     p_setup_attr_rec     IN      setup_attr_rec_type
--   OUT:
--     x_return_status      OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_setup_attr_req_items
(
  p_validation_mode    IN      VARCHAR2,
  p_setup_attr_rec     IN      setup_attr_rec_type,
  x_return_status      OUT NOCOPY     VARCHAR2
);


/****************************************************************************/
-- Procedure
--   check_setup_attr_uk_items
-- Purpose
--   check unique keys
-- Parameters
--   IN:
--     p_setup_attr_rec    IN      setup_attr_rec_type
--   OUT:
--     x_return_status     OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_setup_attr_uk_items
(
  p_validation_mode   IN      VARCHAR2 := JTF_PLSQL_API.g_create,
  p_setup_attr_rec    IN      setup_attr_rec_type,
  x_return_status     OUT NOCOPY     VARCHAR2
);


/****************************************************************************/
-- Procedure
--   check_setup_attr_fk_items
-- Purpose
--   check foreign key items
-- Parameters
--   IN:
--     p_setup_attr_rec    IN      setup_attr_rec_type
--   OUT:
--     x_return_status     OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_setup_attr_fk_items
(
  p_setup_attr_rec    IN      setup_attr_rec_type,
  x_return_status     OUT NOCOPY     VARCHAR2
);


/****************************************************************************/
-- Procedure
--   check_setup_attr_flag_items
-- Purpose
--   check for flag items
-- Parameters
--   IN:
--     p_setup_attr_rec    IN      setup_attr_rec_type
--   OUT:
--     x_return_status     OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_setup_attr_flag_items
(
  p_setup_attr_rec    IN      setup_attr_rec_type,
  x_return_status     OUT NOCOPY     VARCHAR2
);


/****************************************************************************/
-- Procedure
--   complete_setup_attr_rec
-- Purpose
--   replace "g_miss" or NULL values with current database values
-- Parameters
--   IN:
--     p_setup_attr_rec    IN      setup_attr_rec_type
--   OUT:
--     x_complete_rec      OUT     setup_attr_rec_type
------------------------------------------------------------------------------
PROCEDURE complete_setup_attr_rec
(
  p_setup_attr_rec    IN      setup_attr_rec_type,
  x_complete_rec      OUT NOCOPY     setup_attr_rec_type
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
  x_setup_attr_rec  OUT NOCOPY  setup_attr_rec_type
);

END AMS_Setup_Attr_PVT;

 

/
