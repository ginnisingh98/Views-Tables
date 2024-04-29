--------------------------------------------------------
--  DDL for Package JTF_LOC_TYPES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_LOC_TYPES_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvlots.pls 120.2 2005/08/18 22:55:48 stopiwal ship $ */

TYPE loc_type_rec_type IS RECORD
(
  LOCATION_TYPE_ID                NUMBER,
  LAST_UPDATE_DATE                DATE,
  LAST_UPDATED_BY                 NUMBER,
  CREATION_DATE                   DATE,
  CREATED_BY                      NUMBER,
  LAST_UPDATE_LOGIN               NUMBER,
  OBJECT_VERSION_NUMBER           NUMBER,
  LOCATION_TYPE_CODE              VARCHAR2(30),
  LOCATION_TYPE_NAME              VARCHAR2(240),
  DESCRIPTION                     VARCHAR2(4000)
);


/****************************************************************************/
-- Procedure
--   update_loc_type
-- Purpose
--   update a row in JTF_LOC_TYPES_B and JTF_LOC_TYPES_TL
-- Parameters
--   IN:
--     p_api_version         IN      NUMBER
--     p_init_msg_list       IN      VARCHAR2 := FND_API.g_false
--     p_commit              IN      VARCHAR2 := FND_API.g_false
--     p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full
--
--     p_loc_type_rec        IN      loc_type_rec_type
--
--   OUT:
--     x_return_status       OUT NOCOPY /* file.sql.39 change */     VARCHAR2
--     x_msg_count           OUT NOCOPY /* file.sql.39 change */     NUMBER
--     x_msg_data            OUT NOCOPY /* file.sql.39 change */     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE update_loc_type
(
  p_api_version           IN      NUMBER,
  P_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_commit                IN      VARCHAR2 := FND_API.g_false,
  p_validation_level      IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER,
  x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,

  p_loc_type_rec          IN      loc_type_rec_type
);

/****************************************************************************/
-- Procedure
--   lock_loc_type
-- Purpose
--   lock a row form JTF_Loc_Tyeps_B and JTF_Loc_Tyeps_TL
-- Parameters
--   IN:
--     p_api_version       IN      NUMBER
--     p_init_msg_list     IN      VARCHAR2 := FND_API.g_false
--
--     p_loc_type_id       IN      NUMBER
--     p_object_version    IN      NUMBER
--
--   OUT:
--     x_return_status      OUT NOCOPY /* file.sql.39 change */     VARCHAR2
--     x_msg_count          OUT NOCOPY /* file.sql.39 change */     NUMBER
--     x_msg_data           OUT NOCOPY /* file.sql.39 change */     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE lock_loc_type
(
  p_api_version       IN  NUMBER,
  p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,

  x_return_status     OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  x_msg_count         OUT NOCOPY /* file.sql.39 change */ NUMBER,
  x_msg_data          OUT NOCOPY /* file.sql.39 change */ VARCHAR2,

  p_loc_type_id       IN  NUMBER,
  p_object_version    IN  NUMBER
);

/***************************************************************************/
-- Procedure
--   check_items
-- Purpose
--   item level checking
-- Parameters
--   IN:
--     p_validation_mode    IN      VARCHAR2
--     p_loc_type_rec       IN      loc_type_rec_type
--
--   OUT:
--     x_return_status      OUT NOCOPY /* file.sql.39 change */     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_items
(
  p_validation_mode    IN      VARCHAR2,
  x_return_status      OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  p_loc_type_rec       IN      loc_type_rec_type
);

/****************************************************************************/
-- Procedure
--   check_loc_type_req_items
-- Purpose
--   check if required items are miss
-- Parameters
--   IN:
--     p_validation_mode    IN      VARCHAR2
--     p_loc_type_rec       IN      loc_type_rec_type
--   OUT:
--     x_return_status      OUT NOCOPY /* file.sql.39 change */     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_loc_type_req_items
(
  p_validation_mode    IN      VARCHAR2,
  p_loc_type_rec       IN      loc_type_rec_type,
  x_return_status      OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);

/****************************************************************************/
-- Procedure
--   check_loc_type_uk_items
-- Purpose
--   check unique keys
-- Parameters
--   IN:
--     p_validation_mode  IN      VARCHAR2
--     p_loc_type_rec     IN      loc_type_rec_type
--   OUT:
--     x_return_status    OUT NOCOPY /* file.sql.39 change */     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_loc_type_uk_items
(
  p_validation_mode  IN      VARCHAR2,
  p_loc_type_rec     IN      loc_type_rec_type,
  x_return_status    OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);

END JTF_Loc_Types_PVT;

 

/
