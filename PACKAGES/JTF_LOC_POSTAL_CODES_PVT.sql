--------------------------------------------------------
--  DDL for Package JTF_LOC_POSTAL_CODES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_LOC_POSTAL_CODES_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvlops.pls 120.2 2005/08/18 22:55:39 stopiwal ship $ */

TYPE postal_code_rec_type IS RECORD
(
  LOCATION_POSTAL_CODE_ID        NUMBER,
  LAST_UPDATE_DATE               DATE,
  LAST_UPDATED_BY                NUMBER,
  CREATION_DATE                  DATE,
  CREATED_BY                     NUMBER,
  LAST_UPDATE_LOGIN              NUMBER,
  OBJECT_VERSION_NUMBER          NUMBER,
  ORIG_SYSTEM_REF                VARCHAR2(30),
  ORIG_SYSTEM_ID                 NUMBER,
  LOCATION_AREA_ID               NUMBER,
  START_DATE_ACTIVE              DATE,
  END_DATE_ACTIVE                DATE,
  POSTAL_CODE_START              VARCHAR2(6),
  POSTAL_CODE_END                VARCHAR2(6)
);


/****************************************************************************/
-- Procedure
--   create_postal_code
-- Purpose
--   create rows in JTF_LOC_POSTAL_CODES
-- Parameters
--   IN:
--     p_api_version         IN      NUMBER
--     p_init_msg_list       IN      VARCHAR2 := FND_API.g_false
--     p_commit              IN      VARCHAR2 := FND_API.g_false
--     p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full
--
--     p_postal_code_rec     IN      postal_code_rec_type
--
--   OUT:
--     x_return_status       OUT NOCOPY /* file.sql.39 change */     VARCHAR2
--     x_msg_count           OUT NOCOPY /* file.sql.39 change */     NUMBER
--     x_msg_data            OUT NOCOPY /* file.sql.39 change */     VARCHAR2
--
--     x_postal_code_id      OUT NOCOPY /* file.sql.39 change */     NUMBER
------------------------------------------------------------------------------
PROCEDURE create_postal_code
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.g_false,
  p_commit              IN      VARCHAR2 := FND_API.g_false,
  p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status       OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_msg_count           OUT NOCOPY /* file.sql.39 change */     NUMBER,
  x_msg_data            OUT NOCOPY /* file.sql.39 change */     VARCHAR2,

  p_postal_code_rec     IN      postal_code_rec_type,
  x_postal_code_id      OUT NOCOPY /* file.sql.39 change */     NUMBER
);

/****************************************************************************/
-- Procedure
--   update_postal_code
-- Purpose
--   update rows in JTF_LOC_POSTAL_CODES
-- Parameters
--   IN:
--     p_api_version         IN      NUMBER
--     p_init_msg_list       IN      VARCHAR2 := FND_API.g_false
--     p_commit              IN      VARCHAR2 := FND_API.g_false
--     p_validation_level    IN      NUMBER   := FND_API.g_valid_level_full
--     p_remove_flag         IN      VARCHAR2 := 'N'
--     p_postal_code_rec     IN      postal_code_rec_type
--
--   OUT:
--     x_return_status       OUT NOCOPY /* file.sql.39 change */     VARCHAR2
--     x_msg_count           OUT NOCOPY /* file.sql.39 change */     NUMBER
--     x_msg_data            OUT NOCOPY /* file.sql.39 change */     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE update_postal_code
(
  p_api_version           IN      NUMBER,
  p_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_commit                IN      VARCHAR2 := FND_API.g_false,
  p_validation_level      IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER,
  x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,

  p_postal_code_rec       IN      postal_code_rec_type,
  p_remove_flag           IN      VARCHAR2 := 'N'
);

/****************************************************************************/
-- Procedure
--   delete_postal_code
-- Purpose
--   delete rows in JTF_LOC_POSTAL_CODES
-- Parameters
--   IN:
--     p_api_version        IN      NUMBER
--     p_init_msg_list      IN      VARCHAR2 := FND_API.g_false
--     p_commit             IN      VARCHAR2 := FND_API.g_false
--
--     p_postal_code_id     IN      NUMBER
--     p_object_version     IN      NUMBER
--
--   OUT:
--     x_return_status      OUT NOCOPY /* file.sql.39 change */     VARCHAR2
--     x_msg_count          OUT NOCOPY /* file.sql.39 change */     NUMBER
--     x_msg_data           OUT NOCOPY /* file.sql.39 change */     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE delete_postal_code
(
  p_api_version      IN      NUMBER,
  p_init_msg_list    IN      VARCHAR2 := FND_API.g_false,
  p_commit           IN      VARCHAR2 := FND_API.g_false,

  x_return_status    OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_msg_count        OUT NOCOPY /* file.sql.39 change */     NUMBER,
  x_msg_data         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,

  p_postal_code_id   IN      NUMBER,
  p_object_version   IN      NUMBER
);

/****************************************************************************/
-- Procedure
--   lock_postal_code
-- Purpose
--   lock rows in JTF_LOC_POSTAL_CODES
-- Parameters
--   IN:
--     p_api_version        IN      NUMBER
--     p_init_msg_list      IN      VARCHAR2 := FND_API.g_false
--
--     p_postal_code_id     IN      NUMBER
--     p_object_version     IN      NUMBER
--
--   OUT:
--     x_return_status      OUT NOCOPY /* file.sql.39 change */     VARCHAR2
--     x_msg_count          OUT NOCOPY /* file.sql.39 change */     NUMBER
--     x_msg_data           OUT NOCOPY /* file.sql.39 change */     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE lock_postal_code
(
  p_api_version       IN      NUMBER,
  p_init_msg_list     IN      VARCHAR2 := FND_API.g_false,

  x_return_status     OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_msg_count         OUT NOCOPY /* file.sql.39 change */     NUMBER,
  x_msg_data          OUT NOCOPY /* file.sql.39 change */     VARCHAR2,

  p_postal_code_id    IN      NUMBER,
  p_object_version    IN      NUMBER
);

/***************************************************************************/
-- Procedure
--   validate_postal_code
-- Purpose
--   validate the record
-- Parameters
--   IN:
--     p_api_version        IN      NUMBER
--     p_init_msg_list      IN      VARCHAR2 := FND_API.g_false
--     p_validation_level   IN      NUMBER := FND_API.g_valid_level_full
--
--     p_postal_code_rec    IN      postal_code_rec_type
--
--   OUT:
--     x_return_status      OUT NOCOPY /* file.sql.39 change */     VARCHAR2
--     x_msg_count          OUT NOCOPY /* file.sql.39 change */     NUMBER
--     x_msg_data           OUT NOCOPY /* file.sql.39 change */     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE validate_postal_code
(
  p_api_version        IN      NUMBER,
  p_init_msg_list      IN      VARCHAR2 := FND_API.g_false,
  p_validation_level   IN      NUMBER := FND_API.g_valid_level_full,
  x_return_status      OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_msg_count          OUT NOCOPY /* file.sql.39 change */     NUMBER,
  x_msg_data           OUT NOCOPY /* file.sql.39 change */     VARCHAR2,

  p_postal_code_rec    IN      postal_code_rec_type
);

/****************************************************************************/
-- Procedure
--   check_items
-- Purpose
--   item_level validate
-- Parameters
--   IN:
--     p_validation_mode    IN      VARCHAR2
--     p_postal_code_rec    IN      postal_code_rec_type
--   OUT:
--     x_return_status      OUT NOCOPY /* file.sql.39 change */     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_items
(
    p_validation_mode    IN      VARCHAR2,
    x_return_status      OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    p_postal_code_rec    IN      postal_code_rec_type
);

/****************************************************************************/
-- Procedure
--   check_req_items
-- Purpose
--   check if required items are miss
-- Parameters
--   IN:
--     p_validation_mode    IN      VARCHAR2
--     p_postal_code_rec    IN      postal_code_rec_type
--   OUT:
--     x_return_status      OUT NOCOPY /* file.sql.39 change */     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_req_items
(
  p_validation_mode    IN      VARCHAR2,
  p_postal_code_rec    IN      postal_code_rec_type,
  x_return_status      OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);

/****************************************************************************/
-- Procedure
--   check_fk_items
-- Purpose
--   check foreign key items
-- Parameters
--   IN:
--     p_postal_code_rec   IN      postal_code_rec_type
--   OUT:
--     x_return_status     OUT NOCOPY /* file.sql.39 change */     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE check_fk_items
(
  p_postal_code_rec   IN      postal_code_rec_type,
  x_return_status     OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);

/*****************************************************************************/
-- Procedure
--    check_record
-- Purpose
--   record level check
-- Parameters
--   IN:
--     p_postal_code_rec   IN      postal_code_rec_type
--     p_complete_rec      IN      postal_code_rec_type
--   OUT:
--     x_return_status     OUT NOCOPY /* file.sql.39 change */     VARCHAR2
-- HISTORY
--    12/23/99    julou    Created.
-------------------------------------------------------------------------------
PROCEDURE check_record
(
  p_postal_code_rec    IN  postal_code_rec_type,
  p_complete_rec       IN  postal_code_rec_type,
  x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

/****************************************************************************/
-- Procedure
--   complete_rec
-- Purpose
--   replace "g_miss" or NULL values with current database values
-- Parameters
--   IN:
--     p_postal_code_rec   IN      postal_code_rec_type
--   OUT:
--     x_complete_rec      OUT NOCOPY /* file.sql.39 change */     postal_code_rec_type
------------------------------------------------------------------------------
PROCEDURE complete_rec
(
  p_postal_code_rec   IN      postal_code_rec_type,
  x_complete_rec      OUT NOCOPY /* file.sql.39 change */     postal_code_rec_type
);

/****************************************************************************/
-- Procedure
--   init_rec
-- Purpose
--   initialize a record
-- Parameters
------------------------------------------------------------------------------
PROCEDURE init_rec
(
  x_postal_code_rec  OUT NOCOPY /* file.sql.39 change */  postal_code_rec_type
);

END JTF_Loc_Postal_Codes_PVT;

 

/
