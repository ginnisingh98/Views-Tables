--------------------------------------------------------
--  DDL for Package JTF_LOC_AREAS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_LOC_AREAS_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvloas.pls 120.2 2005/08/18 22:55:20 stopiwal ship $ */

TYPE loc_area_rec_type IS RECORD
(
  LOCATION_AREA_ID	               NUMBER,
  LAST_UPDATE_DATE                 DATE,
  LAST_UPDATED_BY                  NUMBER,
  CREATION_DATE                    DATE,
  CREATED_BY                       NUMBER,
  LAST_UPDATE_LOGIN                NUMBER,
  OBJECT_VERSION_NUMBER            NUMBER,
  REQUEST_ID                       NUMBER,
  PROGRAM_APPLICATION_ID           NUMBER,
  PROGRAM_ID                       NUMBER,
  PROGRAM_UPDATE_DATE              DATE,
  LOCATION_TYPE_CODE               VARCHAR2(30),
  START_DATE_ACTIVE                DATE,
  END_DATE_ACTIVE                  DATE,
  LOCATION_AREA_CODE               VARCHAR2(30),
  ORIG_SYSTEM_ID                   NUMBER,
  ORIG_SYSTEM_REF                  VARCHAR2(30),
  PARENT_LOCATION_AREA_ID          NUMBER,
  LOCATION_AREA_NAME               VARCHAR2(240),
  LOCATION_AREA_DESCRIPTION        VARCHAR2(4000)
);


/****************************************************************************/
-- Procedure
--   create_loc_area
-- Purpose
--   create a row in JTF_LOC_AREAS_B and JTF_LOC_AREAS_TL
-- Parameters
--   IN:
--     p_api_version         IN      NUMBER
--     p_init_msg_list       IN      VARCHAR2 := FND_API.g_false
--     p_commit              IN      VARCHAR2 := FND_API.g_false
--     p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full
--
--     p_loc_area_rec        IN      loc_area_rec_type
--
--   OUT:
--     x_return_status       OUT NOCOPY /* file.sql.39 change */     VARCHAR2
--     x_msg_count           OUT NOCOPY /* file.sql.39 change */     NUMBER
--     x_msg_data            OUT NOCOPY /* file.sql.39 change */     VARCHAR2
--
--     x_loc_area_id         OUT NOCOPY /* file.sql.39 change */     NUMBER
------------------------------------------------------------------------------
PROCEDURE create_loc_area
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_commit              IN      VARCHAR2 := FND_API.g_false,
  p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status       OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_msg_count           OUT NOCOPY /* file.sql.39 change */     NUMBER,
  x_msg_data            OUT NOCOPY /* file.sql.39 change */     VARCHAR2,

  p_loc_area_rec        IN      loc_area_rec_type,
  x_loc_area_id         OUT NOCOPY /* file.sql.39 change */     NUMBER
);

/****************************************************************************/
-- Procedure
--   update_loc_area
-- Purpose
--   update a row in JTF_LOC_AREAS_B and JTF_LOC_AREAS_TL
-- Parameters
--   IN:
--     p_api_version         IN      NUMBER
--     p_init_msg_list       IN      VARCHAR2 := FND_API.g_false
--     p_commit              IN      VARCHAR2 := FND_API.g_false
--     p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full
--
--     p_loc_area_rec        IN      loc_area_rec_type
--     p_remove_flag         IN      VARCHAR2 := 'N'
--
--   OUT:
--     x_return_status      OUT NOCOPY /* file.sql.39 change */      VARCHAR2
--     x_msg_count          OUT NOCOPY /* file.sql.39 change */      NUMBER
--     x_msg_data           OUT NOCOPY /* file.sql.39 change */      VARCHAR2
------------------------------------------------------------------------------
PROCEDURE update_loc_area
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_commit              IN      VARCHAR2 := FND_API.g_false,
  p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status       OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_msg_count           OUT NOCOPY /* file.sql.39 change */     NUMBER,
  x_msg_data            OUT NOCOPY /* file.sql.39 change */     VARCHAR2,

  p_loc_area_rec        IN      loc_area_rec_type,
  p_remove_flag         IN      VARCHAR2 := 'N'
);

/****************************************************************************/
-- Procedure
--   delete_loc_area
-- Purpose
--   delete a row from JTF_LOC_AREAS_B and JTF_LOC_AREAS_TL
-- Parameters
--   IN:
--     p_api_version         IN      NUMBER
--     p_init_msg_list       IN      VARCHAR2 := FND_API.g_false
--     p_commit              IN      VARCHAR2 := FND_API.g_false
--
--     p_loc_area_id         IN      NUMBER
--     p_object_version      IN      NUMBER
--
--   OUT:
--     x_return_status       OUT NOCOPY /* file.sql.39 change */     VARCHAR2
--     x_msg_count           OUT NOCOPY /* file.sql.39 change */     NUMBER
--     x_msg_data            OUT NOCOPY /* file.sql.39 change */     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE delete_loc_area
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_commit              IN      VARCHAR2 := FND_API.g_false,

  x_return_status       OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_msg_count           OUT NOCOPY /* file.sql.39 change */     NUMBER,
  x_msg_data            OUT NOCOPY /* file.sql.39 change */     VARCHAR2,

  p_loc_area_id         IN      NUMBER,
  p_object_version      IN      NUMBER
);

/****************************************************************************/
-- Procedure
--   lock_loc_area
-- Purpose
--   lock a row form JTF_LOC_AREAS_B and JTF_LOC_AREAS_TL
-- Parameters
--   IN:
--     p_api_version         IN      NUMBER
--     p_init_msg_list       IN      VARCHAR2 := FND_API.g_false
--
--     p_loc_area_id         IN      NUMBER
--     p_object_version      IN      NUMBER
--
--   OUT:
--     x_return_status       OUT NOCOPY /* file.sql.39 change */     VARCHAR2
--     x_msg_count           OUT NOCOPY /* file.sql.39 change */     NUMBER
--     x_msg_data            OUT NOCOPY /* file.sql.39 change */     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE lock_loc_area
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,

  x_return_status       OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_msg_count           OUT NOCOPY /* file.sql.39 change */     NUMBER,
  x_msg_data            OUT NOCOPY /* file.sql.39 change */     VARCHAR2,

  p_loc_area_id         IN      NUMBER,
  p_object_version      IN      NUMBER
);

/***************************************************************************/
-- Procedure
--   validate_loc_area
-- Purpose
--   validate a record before inserting or updating
--   JTF_LOC_AREAS_B and JTF_LOC_AREAS_TL
-- Parameters
--   IN:
--     p_api_version        IN      NUMBER
--     p_init_msg_list      IN      VARCHAR2 := FND_API.g_false
--     p_validation_level   IN      NUMBER := FND_API.g_valid_level_full
--
--     p_loc_area_rec       IN      loc_area_rec_type
--
--   OUT:
--     x_return_status      OUT NOCOPY /* file.sql.39 change */     VARCHAR2
--     x_msg_count          OUT NOCOPY /* file.sql.39 change */     NUMBER
--     x_msg_data           OUT NOCOPY /* file.sql.39 change */     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE validate_loc_area
(
  p_api_version           IN      NUMBER,
  p_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_validation_level      IN      NUMBER := FND_API.g_valid_level_full,

  x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER,
  x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,

  p_loc_area_rec          IN      loc_area_rec_type
);

/****************************************************************************/
-- Procedure
--   check_items
-- Purpose
--   item_level validate
-- Parameters
--   IN:
--     p_validation_mode    IN      VARCHAR2
--     p_loc_area_rec       IN      loc_area_rec_type
--   OUT:
--     x_return_status      OUT NOCOPY /* file.sql.39 change */     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_items
(
    p_validation_mode    IN      VARCHAR2,
    x_return_status      OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    p_loc_area_rec       IN      loc_area_rec_type
);

/****************************************************************************/
-- Procedure
--   check_loc_area_req_items
-- Purpose
--   check if required items are missing
-- Parameters
--   IN:
--     p_validation_mode    IN      VARCHAR2
--     p_loc_area_rec       IN      loc_area_rec_type
--   OUT:
--     x_return_status      OUT NOCOPY /* file.sql.39 change */     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_loc_area_req_items
(
  p_validation_mode    IN      VARCHAR2,
  p_loc_area_rec       IN      loc_area_rec_type,
  x_return_status      OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);

/****************************************************************************/
-- Procedure
--   check_loc_area_uk_items
-- Purpose
--   check unique keys
-- Parameters
--   IN:
--     p_validation_mode  IN      VARCHAR2 := JTF_PLSQL_API.g_create,
--     p_loc_area_rec     IN      loc_area_rec_type
--   OUT:
--     x_return_status    OUT NOCOPY /* file.sql.39 change */     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_loc_area_uk_items
(
  p_validation_mode   IN      VARCHAR2 := JTF_PLSQL_API.g_create,
  p_loc_area_rec      IN      loc_area_rec_type,
  x_return_status     OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);

/****************************************************************************/
-- Procedure
--   check_loc_area_fk_items
-- Purpose
--   check foreign key items
-- Parameters
--   IN:
--     p_loc_area_rec     IN      loc_area_rec_type
--   OUT:
--     x_return_status    OUT NOCOPY /* file.sql.39 change */     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_loc_area_fk_items
(
  p_loc_area_rec     IN      loc_area_rec_type,
  x_return_status    OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);

/*****************************************************************************/
-- Procedure
--    check_record
-- Purpose
--   record level check
-- Parameters
--   IN:
--     p_loc_area_rec   IN      loc_area_rec_type
--     p_complete_rec   IN      loc_area_rec_type
--   OUT:
--     x_return_status  OUT NOCOPY /* file.sql.39 change */     VARCHAR2
-- HISTORY
--    12/23/99    julou    Created.
-------------------------------------------------------------------------------
PROCEDURE check_record
(
  p_loc_area_rec    IN  loc_area_rec_type,
  p_complete_rec    IN  loc_area_rec_type,
  x_return_status   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

/****************************************************************************/
-- Procedure
--   complete_loc_area_rec
-- Purpose
--   replace "g_miss" or NULL values with current database values
-- Parameters
--   IN:
--     p_loc_area_rec    IN      loc_area_rec_type
--   OUT:
--     x_complete_rec    OUT NOCOPY /* file.sql.39 change */     loc_area_rec_type
------------------------------------------------------------------------------
PROCEDURE complete_loc_area_rec
(
  p_loc_area_rec    IN      loc_area_rec_type,
  x_complete_rec    OUT NOCOPY /* file.sql.39 change */     loc_area_rec_type
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
  x_loc_area_rec  OUT NOCOPY /* file.sql.39 change */  loc_area_rec_type
);

END JTF_Loc_Areas_PVT;

 

/
