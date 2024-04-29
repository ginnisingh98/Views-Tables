--------------------------------------------------------
--  DDL for Package AMS_ACT_MARKET_SEGMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ACT_MARKET_SEGMENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvmkss.pls 120.1 2005/06/16 06:12:48 appldev  $ */

TYPE mks_rec_type IS RECORD
(
  ACTIVITY_MARKET_SEGMENT_ID       NUMBER,
  LAST_UPDATE_DATE                 DATE,
  LAST_UPDATED_BY                  NUMBER,
  CREATION_DATE                    DATE,
  CREATED_BY                       NUMBER,
  MARKET_SEGMENT_ID                NUMBER,
  ACT_MARKET_SEGMENT_USED_BY_ID    NUMBER,
  ARC_ACT_MARKET_SEGMENT_USED_BY   VARCHAR2(30),
  SEGMENT_TYPE                     VARCHAR2(30),
  LAST_UPDATE_LOGIN                NUMBER,
  OBJECT_VERSION_NUMBER            NUMBER,
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
  GROUP_CODE                       VARCHAR2(30),
  EXCLUDE_FLAG                     VARCHAR2(30)
);

/****************************************************************************/
-- Procedure
--   create_market_segments
-- Purpose
--   create a row in AMS_ACT_MARKET_SEGMENTS
-- Parameters
--   IN:
--     p_api_version        IN      NUMBER
--     p_init_msg_list      IN      VARCHAR2 := FND_API.g_false
--     p_commit             IN      VARCHAR2 := FND_API.g_false
--     p_validation_level   IN      NUMBER   := FND_API.g_valid_level_full
--
--     p_mks_rec            IN      mks_rec_type
--
--   OUT:
--     x_return_status      OUT NOCOPY     VARCHAR2
--     x_msg_count          OUT NOCOPY     NUMBER
--     x_msg_data           OUT NOCOPY     VARCHAR2
--
--     x_act_mks_id         OUT NOCOPY     NUMBER
------------------------------------------------------------------------------
PROCEDURE create_market_segments
(
  p_api_version           IN      NUMBER,
  p_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_commit                IN      VARCHAR2 := FND_API.g_false,
  p_validation_level      IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status         OUT NOCOPY     VARCHAR2,
  x_msg_count             OUT NOCOPY     NUMBER,
  x_msg_data              OUT NOCOPY     VARCHAR2,

  p_mks_rec               IN      mks_rec_type,
  x_act_mks_id            OUT NOCOPY     NUMBER
);

/****************************************************************************/
-- Procedure
--   update_market_segments
-- Purpose
--   update a row in AMS_ACT_MARKET_SEGMENTS
-- Parameters
--   IN:
--     p_api_version        IN      NUMBER
--     p_init_msg_list      IN      VARCHAR2 := FND_API.g_false
--     p_commit             IN      VARCHAR2 := FND_API.g_false
--     p_validation_level   IN      NUMBER   := FND_API.g_valid_level_full
--
--     p_mks_rec            IN      mks_rec_type
--
--   OUT:
--     x_return_status      OUT NOCOPY     VARCHAR2
--     x_msg_count          OUT NOCOPY     NUMBER
--     x_msg_data           OUT NOCOPY     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE update_market_segments
(
  p_api_version           IN      NUMBER,
  p_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_commit                IN      VARCHAR2 := FND_API.g_false,
  p_validation_level      IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status         OUT NOCOPY     VARCHAR2,
  x_msg_count             OUT NOCOPY     NUMBER,
  x_msg_data              OUT NOCOPY     VARCHAR2,

  p_mks_rec               IN      mks_rec_type
);

/****************************************************************************/
-- Procedure
--   delete_market_segments
-- Purpose
--   delete a row from AMS_ACT_MARKET_SEGMENTS
-- Parameters
--   IN:
--     p_api_version      IN      NUMBER
--     p_init_msg_list    IN      VARCHAR2 := FND_API.g_false
--     p_commit           IN      VARCHAR2 := FND_API.g_false
--
--     p_act_mks_id       IN      NUMBER
--     p_object_version   IN      NUMBER
--
--   OUT:
--     x_return_status    OUT NOCOPY     VARCHAR2
--     x_msg_count        OUT NOCOPY     NUMBER
--     x_msg_data         OUT NOCOPY     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE delete_market_segments
(
  p_api_version      IN      NUMBER,
  p_init_msg_list    IN      VARCHAR2 := FND_API.g_false,
  p_commit           IN      VARCHAR2 := FND_API.g_false,

  x_return_status    OUT NOCOPY     VARCHAR2,
  x_msg_count        OUT NOCOPY     NUMBER,
  x_msg_data         OUT NOCOPY     VARCHAR2,

  p_act_mks_id       IN      NUMBER,
  p_object_version   IN      NUMBER
);

/****************************************************************************/
-- Procedure
--   lock_market_segments
-- Purpose
--   lock a row form AMS_ACT_MARKET_SEGMENTS
-- Parameters
--   IN:
--     p_api_version      IN      NUMBER
--     p_init_msg_list    IN      VARCHAR2 := FND_API.g_false
--
--     p_act_mks_id       IN      NUMBER
--     p_object_version   IN      NUMBER
--
--   OUT:
--     x_return_status    OUT NOCOPY     VARCHAR2
--     x_msg_count        OUT NOCOPY     NUMBER
--     x_msg_data         OUT NOCOPY     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE lock_market_segments
(
  p_api_version      IN      NUMBER,
  p_init_msg_list    IN      VARCHAR2 := FND_API.g_false,

  x_return_status    OUT NOCOPY     VARCHAR2,
  x_msg_count        OUT NOCOPY     NUMBER,
  x_msg_data         OUT NOCOPY     VARCHAR2,

  p_act_mks_id       IN      NUMBER,
  p_object_version   IN      NUMBER
);

/***************************************************************************/
-- Procedure
--   validate_market_segments
-- Purpose
--   validate a record before inserting or updating AMS_ACT_MARKET_SEGMENTS
-- Parameters
--   IN:
--     p_api_version        IN      NUMBER
--     p_init_msg_list      IN      VARCHAR2 := FND_API.g_false
--     p_validation_mode    IN      VARCHAR2
--
--     p_mks_rec            IN      mks_rec_type
--
--   OUT:
--     x_return_status      OUT NOCOPY     VARCHAR2
--     x_msg_count          OUT NOCOPY     NUMBER
--     x_msg_data           OUT NOCOPY     VARCHAR2
------------------------------------------------------------------------------
PROCEDURE validate_market_segments
(
    p_api_version           IN      NUMBER,
    P_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
    p_validation_level      IN      NUMBER   := FND_API.g_valid_level_full,

    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2,

    p_mks_rec               IN      mks_rec_type
);


-- Start of Comments
--
-- NAME
--   Check_Mks_Items
--
-- PURPOSE
--   This procedure is to validate ams_act_market_segtments
-- NOTES
--
-- HISTORY
--   12/16/1999        ptendulk            created
-- End of Comments

PROCEDURE check_Mks_items(
   p_mks_rec         IN  mks_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
) ;


-- Start of Comments
--
-- NAME
--   Validate_cross_ent_Rec
--
-- PURPOSE
--   This procedure is to validate Unique Marketsegment across
--   Activities
-- NOTES
--
--
-- HISTORY
--   12/16/1999        ptendulk            created
-- End of Comments
PROCEDURE Validate_cross_ent_Rec(
   p_mks_rec         IN  mks_rec_type,
   p_complete_rec    IN  mks_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
) ;


-- Start of Comments
--
-- NAME
--   Validate_Mks_Record
--
-- PURPOSE
--   This procedure is to validate ams_act_market_segments table
-- NOTES
--
--
-- HISTORY
--   12/16/1999        ptendulk            created
-- End of Comments
PROCEDURE Check_Mks_Record(
   p_mks_rec        IN  mks_rec_type,
   p_complete_rec   IN  mks_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
) ;

-- Start of Comments
--
-- NAME
--   Init_Mks_Rec
--
-- PURPOSE
--   This procedure is to Initialize the Record type before Updation.
--
-- NOTES
--
--
-- HISTORY
--   12/16/1999        ptendulk            created
-- End of Comments
PROCEDURE Init_Mks_Rec(
   x_mks_rec  OUT NOCOPY  mks_rec_type
) ;

/* Start of Comments Made by ptendulk */
/****************************************************************************/
-- Procedure
--   check_mks_req_items
-- Purpose
--   check if required items are missing
-- Parameters
--   IN:
--     p_validation_mode    IN      VARCHAR2
--     p_mks_rec            IN      mks_rec_type
--   OUT:
--     x_return_status      OUT NOCOPY     VARCHAR2
------------------------------------------------------------------------------
--PROCEDURE check_mks_req_items
--(
--  p_validation_mode       IN      VARCHAR2,
--  p_mks_rec               IN      mks_rec_type,
--  x_return_status         OUT NOCOPY     VARCHAR2
--);

/****************************************************************************/
-- Procedure
--   check_mks_fk_items
-- Purpose
--   check foreign key items
-- Parameters
--   IN:
--     p_mks_rec            IN      mks_rec_type
--   OUT:
--     x_return_status      OUT NOCOPY     VARCHAR2
------------------------------------------------------------------------------
--PROCEDURE check_mks_fk_items
--(
--  p_mks_rec               IN      mks_rec_type,
--  x_return_status         OUT NOCOPY     VARCHAR2
--);

/****************************************************************************/
-- Procedure
--   check_mks_lookup_items
-- Purpose
--   check for lookup items
-- Parameters
--   IN:
---     p_mks_rec            IN      mks_rec_type
--   OUT:
--     x_return_status      OUT NOCOPY     VARCHAR2
------------------------------------------------------------------------------
--PROCEDURE check_mks_lookup_items
--(
--  p_mks_rec               IN      mks_rec_type,
--  x_return_status         OUT NOCOPY     VARCHAR2
--);
/* End Of code Commented by ptendulk */

/****************************************************************************/
-- Procedure
--   complete_mks_rec
-- Purpose
--   replace "g_miss" values with current database values
-- Parameters
--   IN:
--     p_mks_rec         IN      mks_rec_type
--   OUT:
--     x_complete_rec    OUT NOCOPY     mks_rec_type
------------------------------------------------------------------------------
PROCEDURE complete_mks_rec
(
  p_mks_rec           IN      mks_rec_type,
  x_complete_rec      OUT NOCOPY     mks_rec_type
);

END AMS_Act_Market_Segments_PVT;

 

/
