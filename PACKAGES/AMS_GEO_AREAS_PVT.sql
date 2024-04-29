--------------------------------------------------------
--  DDL for Package AMS_GEO_AREAS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_GEO_AREAS_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvgeos.pls 115.11 2002/11/22 23:37:15 dbiswas ship $ */

TYPE geo_area_rec_type IS RECORD
(
  ACTIVITY_GEO_AREA_ID	           NUMBER,
  LAST_UPDATE_DATE                 DATE,
  LAST_UPDATED_BY                  NUMBER,
  CREATION_DATE                    DATE,
  CREATED_BY                       NUMBER,
  LAST_UPDATE_LOGIN                NUMBER,
  OBJECT_VERSION_NUMBER            NUMBER,
  ACT_GEO_AREA_USED_BY_ID          NUMBER,
  ARC_ACT_GEO_AREA_USED_BY         VARCHAR2(4),
  ATTRIBUTE_CATEGORY               VARCHAR2(30),
  ATTRIBUTE1                       VARCHAR2(150),
  ATTRIBUTE2                       VARCHAR2(150),
  ATTRIBUTE3                       VARCHAR2(150),
  ATTRIBUTE4                       VARCHAR2(150),
  ATTRIBUTE5                       VARCHAR2(150),
  ATTRIBUTE6                       VARCHAR2(150),
  ATTRIBUTE7                       VARCHAR2(150),
  ATTRIBUTE8                       VARCHAR2(150),
  ATTRIBUTE9                       VARCHAR2(150),
  ATTRIBUTE10                      VARCHAR2(150),
  ATTRIBUTE11                      VARCHAR2(150),
  ATTRIBUTE12                      VARCHAR2(150),
  ATTRIBUTE13                      VARCHAR2(150),
  ATTRIBUTE14                      VARCHAR2(150),
  ATTRIBUTE15                      VARCHAR2(150),
  GEO_AREA_TYPE_CODE               VARCHAR2(30),
  GEO_HIERARCHY_ID                 NUMBER
);


/****************************************************************************/
-- Procedure
--   create_geo_area
-- Purpose
--   create a row in AMS_ACT_GEO_AREAS
-- Parameters
--   IN:
--     p_api_version        IN      NUMBER
--     p_init_msg_list      IN      VARCHAR2 := FND_API.g_false
--     p_commit             IN      VARCHAR2 := FND_API.g_false
--     p_validation_level   IN      NUMBER   := FND_API.g_valid_level_full
--
--     p_geo_area_rec       IN      geo_area_rec_type
--
--   OUT:
--     x_return_status      OUT     VARCHAR2
--     x_msg_count          OUT     NUMBER
--     x_msg_data           OUT     VARCHAR2
--
--     x_geo_area_id        OUT     NUMBER
------------------------------------------------------------------------------
PROCEDURE create_geo_area
(
  p_api_version           IN      NUMBER,
  p_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_commit                IN      VARCHAR2 := FND_API.g_false,
  p_validation_level      IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status         OUT NOCOPY     VARCHAR2,
  x_msg_count             OUT NOCOPY     NUMBER,
  x_msg_data              OUT NOCOPY     VARCHAR2,

  p_geo_area_rec          IN      geo_area_rec_type,
  x_geo_area_id           OUT NOCOPY     NUMBER
);

/****************************************************************************/
-- Procedure
--   update_geo_area
-- Purpose
--   update a row in AMS_ACT_GEO_AREAS
-- Parameters
--   IN:
--     p_api_version        IN      NUMBER
--     p_init_msg_list      IN      VARCHAR2 := FND_API.g_false
--     p_commit             IN      VARCHAR2 := FND_API.g_false
--     p_validation_level   IN      NUMBER   := FND_API.g_valid_level_full
--
--     p_geo_area_rec       IN      geo_area_rec_type
--
--   OUT:
--     x_return_status      OUT     VARCHAR2
--     x_msg_count          OUT     NUMBER
--     x_msg_data           OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE update_geo_area
(
  p_api_version           IN      NUMBER,
  P_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_commit                IN      VARCHAR2 := FND_API.g_false,
  p_validation_level      IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status         OUT NOCOPY     VARCHAR2,
  x_msg_count             OUT NOCOPY     NUMBER,
  x_msg_data              OUT NOCOPY     VARCHAR2,

  p_geo_area_rec          IN      geo_area_rec_type
);

/****************************************************************************/
-- Procedure
--   delete_geo_area
-- Purpose
--   delete a row from AMS_ACT_GEO_AREAS
-- Parameters
--   IN:
--     p_api_version        IN      NUMBER
--     p_init_msg_list      IN      VARCHAR2 := FND_API.g_false
--     p_commit             IN      VARCHAR2 := FND_API.g_false
--
--     p_geo_area_id        IN      NUMBER
--     p_object_version     IN      NUMBER
--
--   OUT:
--     x_return_status      OUT     VARCHAR2
--     x_msg_count          OUT     NUMBER
--     x_msg_data           OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE delete_geo_area
(
  p_api_version           IN      NUMBER,
  P_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_commit                IN      VARCHAR2 := FND_API.g_false,

  x_return_status         OUT NOCOPY     VARCHAR2,
  x_msg_count             OUT NOCOPY     NUMBER,
  x_msg_data              OUT NOCOPY     VARCHAR2,

  p_geo_area_id           IN      NUMBER,
  p_object_version        IN      NUMBER
);

/****************************************************************************/
-- Procedure
--   lock_geo_area
-- Purpose
--   lock a row form AMS_ACT_GEO_AREAS
-- Parameters
--   IN:
--     p_api_version        IN      NUMBER
--     p_init_msg_list      IN      VARCHAR2 := FND_API.g_false
--
--     p_geo_area_id        IN      NUMBER
--     p_object_version     IN      NUMBER
--
--   OUT:
--     x_return_status      OUT     VARCHAR2
--     x_msg_count          OUT     NUMBER
--     x_msg_data           OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE lock_geo_area
(
  p_api_version          IN      NUMBER,
  p_init_msg_list        IN      VARCHAR2 := FND_API.g_false,

  x_return_status        OUT NOCOPY     VARCHAR2,
  x_msg_count            OUT NOCOPY     NUMBER,
  x_msg_data             OUT NOCOPY     VARCHAR2,

  p_geo_area_id          IN      NUMBER,
  p_object_version       IN      NUMBER
);

/***************************************************************************/
-- Procedure
--   validate_geo_area
-- Purpose
--   validate a record before inserting or updating AMS_ACT_GEO_AREAS
-- Parameters
--   IN:
--     p_api_version        IN      NUMBER
--     p_init_msg_list      IN      VARCHAR2 := FND_API.g_false
--     p_validation_level   IN      NUMBER := FND_API.g_valid_level_full
--
--     p_geo_area_rec       IN      geo_area_rec_type
--
--   OUT:
--     x_return_status      OUT     VARCHAR2
--     x_msg_count          OUT     NUMBER
--     x_msg_data           OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE validate_geo_area
(
  p_api_version           IN      NUMBER,
  P_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_validation_level      IN      NUMBER := FND_API.g_valid_level_full,

  x_return_status         OUT NOCOPY     VARCHAR2,
  x_msg_count             OUT NOCOPY     NUMBER,
  x_msg_data              OUT NOCOPY     VARCHAR2,

  p_geo_area_rec          IN      geo_area_rec_type
);

/****************************************************************************/
-- Procedure
--   check_items
-- Purpose
--   item_level validate
-- Parameters
--   IN:
--     p_validation_mode    IN      VARCHAR2
--     p_geo_area_rec       IN      geo_area_rec_type
--   OUT:
--     x_return_status      OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_items
(
    p_validation_mode    IN      VARCHAR2,
    x_return_status      OUT NOCOPY     VARCHAR2,
    p_geo_area_rec       IN      geo_area_rec_type
);

/****************************************************************************/
-- Procedure
--   check_geo_area_req_items
-- Purpose
--   check if required items are miss
-- Parameters
--   IN:
--     p_validation_mode    IN      VARCHAR2
--     p_geo_area_rec       IN      geo_area_rec_type
--   OUT:
--     x_return_status      OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_geo_area_req_items
(
  p_validation_mode       IN      VARCHAR2,
  p_geo_area_rec          IN      geo_area_rec_type,
  x_return_status         OUT NOCOPY     VARCHAR2
);

/****************************************************************************/
-- Procedure
--   check_geo_area_uk_items
-- Purpose
--   check unique keys
-- Parameters
--   IN:
--     p_validation_mode    IN      VARCHAR2 := JTF_PLSQL_API.g_create,
--     p_geo_area_rec       IN      geo_area_rec_type
--   OUT:
--     x_return_status      OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_geo_area_uk_items
(
  p_validation_mode       IN      VARCHAR2 := JTF_PLSQL_API.g_create,
  p_geo_area_rec          IN      geo_area_rec_type,
  x_return_status         OUT NOCOPY     VARCHAR2
);

/****************************************************************************/
-- Procedure
--   check_geo_area_fk_items
-- Purpose
--   check foreign key items
-- Parameters
--   IN:
--     p_geo_area_rec       IN      geo_area_rec_type
--   OUT:
--     x_return_status      OUT     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_geo_area_fk_items
(
  p_geo_area_rec          IN      geo_area_rec_type,
  x_return_status         OUT NOCOPY     VARCHAR2
);

/****************************************************************************/
-- Procedure
--   complete_geo_area_rec
-- Purpose
--   replace "g_miss" or NULL values with current database values
-- Parameters
--   IN:
--     p_geo_area_rec    IN      geo_area_rec_type
--   OUT:
--     x_complete_rec    OUT     geo_area_rec_type
------------------------------------------------------------------------------
PROCEDURE complete_geo_area_rec
(
  p_geo_area_rec      IN      geo_area_rec_type,
  x_complete_rec      OUT NOCOPY     geo_area_rec_type
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
  x_geo_area_rec  OUT NOCOPY  geo_area_rec_type
);

END AMS_Geo_Areas_PVT;

 

/
