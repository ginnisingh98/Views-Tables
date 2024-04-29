--------------------------------------------------------
--  DDL for Package AMS_CUST_SETUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CUST_SETUP_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvcuss.pls 115.19 2003/10/10 05:23:13 vanbukum ship $ */

TYPE cust_setup_rec_type IS RECORD
(
  CUSTOM_SETUP_ID	           NUMBER,
  LAST_UPDATE_DATE                 DATE,
  LAST_UPDATED_BY                  NUMBER,
  CREATION_DATE                    DATE,
  CREATED_BY                       NUMBER,
  LAST_UPDATE_LOGIN                NUMBER,
  OBJECT_VERSION_NUMBER            NUMBER,
  ACTIVITY_TYPE_CODE               VARCHAR2(30),
  MEDIA_ID                         NUMBER,
  ENABLED_FLAG                     VARCHAR2(1),
  ALLOW_ESSENTIAL_GROUPING         VARCHAR2(1),
  USAGE				   VARCHAR2(30),
  OBJECT_TYPE                      VARCHAR2(30),
  SOURCE_CODE_SUFFIX               VARCHAR2(10),
  SETUP_NAME                       VARCHAR2(120),
  DESCRIPTION                      VARCHAR2(4000),
  APPLICATION_ID                   NUMBER
);


/****************************************************************************/
-- Procedure
--   create_cust_setup
-- Purpose
--   create rows in AMS_CUSTOM_SETUPS_B AND AMS_CUSTOM_SETUPS_TL
-- Parameters
--   IN:
--     p_api_version         IN      NUMBER
--     p_init_msg_list       IN      VARCHAR2 := FND_API.g_false
--     p_commit              IN      VARCHAR2 := FND_API.g_false
--     p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full
--
--     p_cust_setup_rec      IN      cust_setup_rec_type
--
--   OUT:
--     x_return_status       OUT     VARCHAR2
--     x_msg_count           OUT     NUMBER
--     x_msg_data            OUT     VARCHAR2
--
--     x_cust_setup_id       OUT     NUMBER
------------------------------------------------------------------------------
PROCEDURE create_cust_setup
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_commit              IN      VARCHAR2 := FND_API.g_false,
  p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER,
  x_msg_data            OUT NOCOPY     VARCHAR2,

  p_cust_setup_rec      IN      cust_setup_rec_type,
  x_cust_setup_id       OUT NOCOPY     NUMBER
);

/****************************************************************************/
-- Procedure
--   update_cust_setup
-- Purpose
--   update rows in AMS_CUSTOM_SETUPS_B AND AMS_CUSTOM_SETUPS_TL
-- Parameters
--   IN:
--     p_api_version         IN      NUMBER
--     p_init_msg_list       IN      VARCHAR2 := FND_API.g_false
--     p_commit              IN      VARCHAR2 := FND_API.g_false
--     p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full
--
--     p_cust_setup_rec      IN      cust_setup_rec_type
--
--   OUT:
--     x_return_status       OUT     VARCHAR2
--     x_msg_count           OUT     NUMBER
--     x_msg_data            OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE update_cust_setup
(
  p_api_version           IN      NUMBER,
  p_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_commit                IN      VARCHAR2 := FND_API.g_false,
  p_validation_level      IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status         OUT NOCOPY     VARCHAR2,
  x_msg_count             OUT NOCOPY     NUMBER,
  x_msg_data              OUT NOCOPY     VARCHAR2,

  p_cust_setup_rec        IN      cust_setup_rec_type
);

/****************************************************************************/
-- Procedure
--   delete_cust_setup
-- Purpose
--   delete rows in AMS_CUSTOM_SETUPS_B AND AMS_CUSTOM_SETUPS_TL
-- Parameters
--   IN:
--     p_api_version        IN      NUMBER
--     p_init_msg_list      IN      VARCHAR2 := FND_API.g_false
--     p_commit             IN      VARCHAR2 := FND_API.g_false
--
--     p_custom_setup_id    IN      NUMBER
--     p_object_version     IN      NUMBER
--
--   OUT:
--     x_return_status      OUT     VARCHAR2
--     x_msg_count          OUT     NUMBER
--     x_msg_data           OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE delete_cust_setup
(
  p_api_version      IN      NUMBER,
  P_init_msg_list    IN      VARCHAR2 := FND_API.g_false,
  p_commit           IN      VARCHAR2 := FND_API.g_false,

  x_return_status    OUT NOCOPY     VARCHAR2,
  x_msg_count        OUT NOCOPY     NUMBER,
  x_msg_data         OUT NOCOPY     VARCHAR2,

  p_cust_setup_id    IN      NUMBER,
  p_object_version   IN      NUMBER
);

/****************************************************************************/
-- Procedure
--   lock_cust_setup
-- Purpose
--   lock rows in AMS_CUSTOM_SETUPS_B AND AMS_CUSTOM_SETUPS_TL
-- Parameters
--   IN:
--     p_api_version        IN      NUMBER
--     p_init_msg_list      IN      VARCHAR2 := FND_API.g_false
--
--     p_custom_setup_id    IN      NUMBER
--     p_object_version     IN      NUMBER
--
--   OUT:
--     x_return_status      OUT     VARCHAR2
--     x_msg_count          OUT     NUMBER
--     x_msg_data           OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE lock_cust_setup
(
  p_api_version       IN      NUMBER,
  p_init_msg_list     IN      VARCHAR2 := FND_API.g_false,

  x_return_status     OUT NOCOPY     VARCHAR2,
  x_msg_count         OUT NOCOPY     NUMBER,
  x_msg_data          OUT NOCOPY     VARCHAR2,

  p_cust_setup_id     IN      NUMBER,
  p_object_version    IN      NUMBER
);

/***************************************************************************/
-- Procedure
--   validate_cust_setup
-- Purpose
--   validate the record
-- Parameters
--   IN:
--     p_api_version        IN      NUMBER
--     p_init_msg_list      IN      VARCHAR2 := FND_API.g_false
--     p_validation_level   IN      NUMBER := FND_API.g_valid_level_full
--
--     p_cust_setup_rec     IN      cust_setup_rec_type
--
--   OUT:
--     x_return_status      OUT     VARCHAR2
--     x_msg_count          OUT     NUMBER
--     x_msg_data           OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE validate_cust_setup
(
  p_api_version        IN      NUMBER,
  P_init_msg_list      IN      VARCHAR2 := FND_API.g_false,
  p_validation_level   IN      NUMBER := FND_API.g_valid_level_full,
  x_return_status      OUT NOCOPY     VARCHAR2,
  x_msg_count          OUT NOCOPY     NUMBER,
  x_msg_data           OUT NOCOPY     VARCHAR2,

  p_cust_setup_rec     IN      cust_setup_rec_type
);

/****************************************************************************/
-- Procedure
--   check_items
-- Purpose
--   item_level validate
-- Parameters
--   IN:
--     p_validation_mode    IN      VARCHAR2
--     p_cust_setup_rec     IN      cust_setup_rec_type
--   OUT:
--     x_return_status      OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_items
(
    p_validation_mode    IN      VARCHAR2,
    x_return_status      OUT NOCOPY     VARCHAR2,
    p_cust_setup_rec     IN      cust_setup_rec_type
);

/****************************************************************************/
-- Procedure
--   check_cust_setup_req_items
-- Purpose
--   check if required items are miss
-- Parameters
--   IN:
--     p_validation_mode    IN      VARCHAR2
--     p_cust_setup_rec     IN      cust_setup_rec_type
--   OUT:
--     x_return_status      OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_cust_setup_req_items
(
  p_validation_mode    IN      VARCHAR2,
  p_cust_setup_rec     IN      cust_setup_rec_type,
  x_return_status      OUT NOCOPY     VARCHAR2
);

/****************************************************************************/
-- Procedure
--   check_cust_setup_uk_items
-- Purpose
--   check unique keys
-- Parameters
--   IN:
--     p_validation_mode   IN      VARCHAR2 := JTF_PLSQL_API.g_create,
--     p_cust_setup_rec    IN      cust_setup_rec_type
--   OUT:
--     x_return_status     OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_cust_setup_uk_items
(
  p_validation_mode   IN      VARCHAR2 := JTF_PLSQL_API.g_create,
  p_cust_setup_rec    IN      cust_setup_rec_type,
  x_return_status     OUT NOCOPY     VARCHAR2
);

/****************************************************************************/
-- Procedure
--   check_cust_setup_fk_items
-- Purpose
--   check foreign key items
-- Parameters
--   IN:
--     p_cust_setup_rec    IN      cust_setup_rec_type
--   OUT:
--     x_return_status     OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_cust_setup_fk_items
(
  p_cust_setup_rec    IN      cust_setup_rec_type,
  x_return_status     OUT NOCOPY     VARCHAR2
);

/****************************************************************************/
-- Procedure
--   check_cust_setup_flag_items
-- Purpose
--   check for flag items
-- Parameters
--   IN:
--     p_cust_setup_rec    IN      cust_setup_rec_type
--   OUT:
--     x_return_status     OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_cust_setup_flag_items
(
  p_cust_setup_rec    IN      cust_setup_rec_type,
  x_return_status     OUT NOCOPY     VARCHAR2
);

/****************************************************************************/
-- Procedure
--   complete_cust_setup_rec
-- Purpose
--   replace "g_miss" or NULL values with current database values
-- Parameters
--   IN:
--     p_cust_setup_rec    IN      cust_setup_rec_type
--   OUT:
--     x_complete_rec      OUT     cust_setup_rec_type
------------------------------------------------------------------------------
PROCEDURE complete_cust_setup_rec
(
  p_cust_setup_rec    IN      cust_setup_rec_type,
  x_complete_rec      OUT NOCOPY     cust_setup_rec_type
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
  x_cust_setup_rec  OUT NOCOPY  cust_setup_rec_type
);

END AMS_Cust_Setup_PVT;

 

/
