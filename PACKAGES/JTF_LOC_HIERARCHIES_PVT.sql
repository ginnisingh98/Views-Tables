--------------------------------------------------------
--  DDL for Package JTF_LOC_HIERARCHIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_LOC_HIERARCHIES_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvlohs.pls 120.2 2005/08/18 22:55:30 stopiwal ship $ */

TYPE loc_hier_rec_type IS RECORD
(
   LOCATION_HIERARCHY_ID        NUMBER,
   LAST_UPDATE_DATE             DATE,
   LAST_UPDATED_BY              NUMBER,
   CREATION_DATE                DATE,
   CREATED_BY                   NUMBER,
   LAST_UPDATE_LOGIN            NUMBER,
   OBJECT_VERSION_NUMBER        NUMBER,
   REQUEST_ID                   NUMBER,
   PROGRAM_APPLICATION_ID       NUMBER,
   PROGRAM_ID                   NUMBER,
   PROGRAM_UPDATE_DATE          DATE,
   CREATED_BY_APPLICATION_ID    NUMBER,
   LOCATION_TYPE_CODE           VARCHAR2(30),
   START_DATE_ACTIVE            DATE,
   END_DATE_ACTIVE              DATE,
   AREA1_ID                     NUMBER,
   AREA1_CODE                   VARCHAR2(30),
   AREA2_ID                     NUMBER,
   AREA2_CODE                   VARCHAR2(30),
   COUNTRY_ID                   NUMBER,
   COUNTRY_CODE                 VARCHAR2(30),
   COUNTRY_REGION_ID            NUMBER,
   COUNTRY_REGION_CODE          VARCHAR2(30),
   STATE_ID                     NUMBER,
   STATE_CODE                   VARCHAR2(30),
   STATE_REGION_ID              NUMBER,
   STATE_REGION_CODE            VARCHAR2(30),
   CITY_ID                      NUMBER,
   CITY_CODE                    VARCHAR2(30),
   POSTAL_CODE_ID               NUMBER
);

/****************************************************************************/
-- Procedure
--   create_hierarchy
-- Purpose
--   create a row in JTF_LOC_HIERARCHIES_B
-- Parameters
--   IN:
--     p_api_version         IN      NUMBER
--     p_init_msg_list       IN      VARCHAR2 := FND_API.g_false
--     p_commit              IN      VARCHAR2 := FND_API.g_false
--     p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full
--
--     p_loc_hier_rec        IN      loc_hier_rec_type
--
--   OUT:
--     x_return_status       OUT NOCOPY /* file.sql.39 change */     VARCHAR2
--     x_msg_count           OUT NOCOPY /* file.sql.39 change */     NUMBER
--     x_msg_data            OUT NOCOPY /* file.sql.39 change */     VARCHAR2
--     x_hier_id             OUT NOCOPY /* file.sql.39 change */     NUMBER
------------------------------------------------------------------------------
PROCEDURE create_hierarchy
(
  p_api_version           IN      NUMBER,
  p_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_commit                IN      VARCHAR2 := FND_API.g_false,
  p_validation_level      IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER,
  x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,

  p_loc_hier_rec          IN      loc_hier_rec_type,
  x_hier_id               OUT NOCOPY /* file.sql.39 change */     NUMBER
);


/****************************************************************************/
-- Procedure
--   update_hierarchy
-- Purpose
--   update a row in JTF_LOC_HIERARCHIES_B
-- Parameters
--   IN:
--     p_api_version         IN      NUMBER
--     p_init_msg_list       IN      VARCHAR2 := FND_API.g_false
--     p_commit              IN      VARCHAR2 := FND_API.g_false
--     p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full
--
--     p_loc_hier_rec        IN      loc_hier_rec_type
--
--   OUT:
--     x_return_status       OUT NOCOPY /* file.sql.39 change */     VARCHAR2
--     x_msg_count           OUT NOCOPY /* file.sql.39 change */     NUMBER
--     x_msg_data            OUT NOCOPY /* file.sql.39 change */     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE update_hierarchy
(
  p_api_version           IN      NUMBER,
  p_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_commit                IN      VARCHAR2 := FND_API.g_false,
  p_validation_level      IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER,
  x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,

  p_loc_hier_rec          IN      loc_hier_rec_type
);


/****************************************************************************/
-- Procedure
--   delete_hierarchy
-- Purpose
--   delete a row in JTF_LOC_HIERARCHIES_B
-- Parameters
--   IN:
--     p_api_version         IN      NUMBER
--     p_init_msg_list       IN      VARCHAR2 := FND_API.g_false
--     p_commit              IN      VARCHAR2 := FND_API.g_false
--
--     p_hier_id             IN      NUMBER
--     p_object_version      IN      NUMBER
--
--   OUT:
--     x_return_status       OUT NOCOPY /* file.sql.39 change */     VARCHAR2
--     x_msg_count           OUT NOCOPY /* file.sql.39 change */     NUMBER
--     x_msg_data            OUT NOCOPY /* file.sql.39 change */     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE delete_hierarchy
(
  p_api_version           IN      NUMBER,
  p_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_commit                IN      VARCHAR2 := FND_API.g_false,

  x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER,
  x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,

  p_hier_id               IN      NUMBER,
  p_object_version        IN      NUMBER
);


/****************************************************************************/
-- Procedure
--   lock_hierarchy
-- Purpose
--   delete a row in JTF_LOC_HIERARCHIES_B
-- Parameters
--   IN:
--     p_api_version         IN      NUMBER
--     p_init_msg_list       IN      VARCHAR2 := FND_API.g_false
--
--     p_hier_id             IN      NUMBER
--     p_object_version      IN      NUMBER
--
--   OUT:
--     x_return_status       OUT NOCOPY /* file.sql.39 change */     VARCHAR2
--     x_msg_count           OUT NOCOPY /* file.sql.39 change */     NUMBER
--     x_msg_data            OUT NOCOPY /* file.sql.39 change */     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE lock_hierarchy
(
  p_api_version           IN      NUMBER,
  p_init_msg_list         IN      VARCHAR2 := FND_API.g_false,

  x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER,
  x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,

  p_hier_id               IN      NUMBER,
  p_object_version        IN      NUMBER
);


/***************************************************************************/
-- Procedure
--   validate_hierarchy
-- Purpose
--   validate a record before inserting or updating JTF_LOC_HIERARCHIES_B
-- Parameters
--   IN:
--     p_api_version        IN      NUMBER
--     p_init_msg_list      IN      VARCHAR2 := FND_API.g_false
--     p_validation_level   IN      NUMBER := FND_API.g_valid_level_full
--
--     p_loc_hier_rec       IN      loc_hier_rec_type
--
--   OUT:
--     x_return_status      OUT NOCOPY /* file.sql.39 change */     VARCHAR2
--     x_msg_count          OUT NOCOPY /* file.sql.39 change */     NUMBER
--     x_msg_data           OUT NOCOPY /* file.sql.39 change */     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE validate_hierarchy
(
  p_api_version           IN      NUMBER,
  p_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_validation_level      IN      NUMBER := FND_API.g_valid_level_full,

  x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER,
  x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,

  p_loc_hier_rec          IN      loc_hier_rec_type
);

/****************************************************************************/
-- Procedure
--   check_items
-- Purpose
--   item_level validate
-- Parameters
--   IN:
--     p_validation_mode    IN      VARCHAR2
--     p_loc_hier_rec       IN      loc_hier_rec_type
--   OUT:
--     x_return_status      OUT NOCOPY /* file.sql.39 change */     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_items
(
    p_validation_mode    IN      VARCHAR2,
    x_return_status      OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    p_loc_hier_rec       IN      loc_hier_rec_type
);

/****************************************************************************/
-- Procedure
--   check_req_items
-- Purpose
--   check if required items are missing
-- Parameters
--   IN:
--     p_validation_mode    IN      VARCHAR2
--     p_loc_hier_rec       IN      loc_hier_rec_type
--   OUT:
--     x_return_status      OUT NOCOPY /* file.sql.39 change */     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_req_items
(
  p_validation_mode       IN      VARCHAR2,
  p_loc_hier_rec          IN      loc_hier_rec_type,
  x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);

/****************************************************************************/
-- Procedure
--   check_uk_items
-- Purpose
--   check unique keys
-- Parameters
--   IN:
--     p_validation_mode   IN      VARCHAR2 := JTF_PLSQL_API.g_create,
--     p_loc_hier_rec      IN      loc_hier_rec_type
--   OUT:
--     x_return_status     OUT NOCOPY /* file.sql.39 change */     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_uk_items
(
  p_validation_mode   IN      VARCHAR2 := JTF_PLSQL_API.g_create,
  p_loc_hier_rec      IN      loc_hier_rec_type,
  x_return_status     OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);

/****************************************************************************/
-- Procedure
--   check_fk_items
-- Purpose
--   check foreign key items
-- Parameters
--   IN:
--     p_loc_hier_rec       IN      loc_hier_rec_type
--   OUT:
--     x_return_status      OUT NOCOPY /* file.sql.39 change */     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_fk_items
(
  p_loc_hier_rec          IN      loc_hier_rec_type,
  x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);

/*****************************************************************************/
-- Procedure
--   check_record
-- Purpose
--   record level check
-- Parameters
--   IN:
--     p_loc_hier_rec   IN      loc_hier_rec_type
--     p_complete_rec   IN      loc_hier_rec_type
--   OUT:
--     x_return_status     OUT NOCOPY /* file.sql.39 change */     VARCHAR2
-- HISTORY
--    12/23/99    julou    Created.
-------------------------------------------------------------------------------
PROCEDURE check_record
(
  p_loc_hier_rec    IN  loc_hier_rec_type,
  p_complete_rec    IN  loc_hier_rec_type,
  x_return_status   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

/****************************************************************************/
-- Procedure
--   complete_rec
-- Purpose
--   replace "g_miss" values with current database values
-- Parameters
--   IN:
--     p_loc_hier_rec    IN      loc_hier_rec_type
--   OUT:
--     x_complete_rec    OUT NOCOPY /* file.sql.39 change */     loc_hier_rec_type
------------------------------------------------------------------------------
PROCEDURE complete_rec
(
  p_loc_hier_rec      IN      loc_hier_rec_type,
  x_complete_rec      OUT NOCOPY /* file.sql.39 change */     loc_hier_rec_type
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
  x_loc_hier_rec  OUT NOCOPY /* file.sql.39 change */  loc_hier_rec_type
);

END JTF_Loc_Hierarchies_PVT;

 

/
