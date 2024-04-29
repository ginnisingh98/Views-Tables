--------------------------------------------------------
--  DDL for Package AMS_ACTRESOURCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ACTRESOURCE_PUB" AUTHID CURRENT_USER as
/*$Header: amsprscs.pls 115.3 2002/12/11 03:43:17 ptendulk ship $*/

/*****************************************************************************************/
--
-- NAME
--   AMS_ActResource_PUB
--
--   Procedures:
--     Create_Act_Resource (see below for specification)
--     Update_Act_Resource (see below for specification)
--     Delete_Act_Resource (see below for specification)
--     Lock_Act_Resource (see below for specification)
--     Validate_Act_Resource (see below for specification)
--
-- NOTES
--
-- History      created    gmadana   28-Mar-2002
--
/*****************************************************************************************/

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

--===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--    Act_Resource_rec_type
--   -------------------------------------------------------
--   Parameters:
--       row_id
--       activity_resource_id
--       last_update_date
--       last_updated_by
--       creation_date
--       created_by
--       last_update_login
--       object_version_number
--       act_resource_used_by_id
--       arc_act_resource_used_by
--       resource_id
--       role_cd
--       user_status_id
--       system_status_code
--       start_date_time
--       end_date_time
--       primary_flag
--       description
--       attribute_category
--       attribute1
--       attribute2
--       attribute3
--       attribute4
--       attribute5
--       attribute6
--       attribute7
--       attribute8
--       attribute9
--       attribute10
--       attribute11
--       attribute12
--       attribute13
--       attribute14
--       attribute15
--
--    Required
--
--    Defaults
--
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of
--          the attributes.
--
--   End of Comments

--===================================================================

TYPE Act_Resource_rec_type
IS RECORD
(
   ACTIVITY_RESOURCE_ID       NUMBER,
   LAST_UPDATE_DATE           DATE,
   LAST_UPDATED_BY            NUMBER,
   CREATION_DATE              DATE,
   CREATED_BY                 NUMBER,
   LAST_UPDATE_LOGIN          NUMBER,
   OBJECT_VERSION_NUMBER      NUMBER,
   ACT_RESOURCE_USED_BY_ID    NUMBER,
   ARC_ACT_RESOURCE_USED_BY   VARCHAR2(30),
   RESOURCE_ID                NUMBER,
   ROLE_CD                    VARCHAR2(30),
   USER_STATUS_ID             NUMBER,
   SYSTEM_STATUS_CODE         VARCHAR2(30),
   START_DATE_TIME            DATE,
   END_DATE_TIME              DATE,
   PRIMARY_FLAG               VARCHAR2(30),
   DESCRIPTION                VARCHAR2(4000),
   ATTRIBUTE_CATEGORY         VARCHAR2(30),
   ATTRIBUTE1      VARCHAR2(150),
   ATTRIBUTE2      VARCHAR2(150),
   ATTRIBUTE3      VARCHAR2(150),
   ATTRIBUTE4      VARCHAR2(150),
   ATTRIBUTE5      VARCHAR2(150),
   ATTRIBUTE6      VARCHAR2(150),
   ATTRIBUTE7      VARCHAR2(150),
   ATTRIBUTE8      VARCHAR2(150),
   ATTRIBUTE9      VARCHAR2(150),
   ATTRIBUTE10     VARCHAR2(150),
   ATTRIBUTE11     VARCHAR2(150),
   ATTRIBUTE12     VARCHAR2(150),
   ATTRIBUTE13     VARCHAR2(150),
   ATTRIBUTE14     VARCHAR2(150),
   ATTRIBUTE15     VARCHAR2(150)
);

g_miss_Act_Resource_rec_type          Act_Resource_rec_type;
TYPE  Act_Resource_rec_tbl   IS TABLE OF Act_Resource_rec_type INDEX BY BINARY_INTEGER;
g_miss_resource_tbl          Act_Resource_rec_tbl;

TYPE resource_sort_rec_type IS RECORD
(
      -- Please define your own sort by record here.
      activity_resource_id   NUMBER := NULL
);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Act_Resource
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_Act_Resource_rec        IN   Act_Resource_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================

PROCEDURE Create_Act_Resource
( p_api_version      IN   NUMBER,
  p_init_msg_list    IN   VARCHAR2   := FND_API.G_FALSE,
  p_commit           IN   VARCHAR2   := FND_API.G_FALSE,
  p_validation_level IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,

  x_return_status    OUT NOCOPY  VARCHAR2,
  x_msg_count        OUT NOCOPY  NUMBER,
  x_msg_data         OUT NOCOPY  VARCHAR2,

  p_Act_Resource_rec IN   Act_Resource_rec_type,
  x_Act_Resource_id  OUT NOCOPY  NUMBER
);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Act_Resource
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_Act_Resource_rec        IN   Act_Resource_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================

PROCEDURE Update_Act_Resource
( p_api_version      IN     NUMBER,
  p_init_msg_list    IN     VARCHAR2   := FND_API.G_FALSE,
  p_commit           IN     VARCHAR2   := FND_API.G_FALSE,
  p_validation_level IN     NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  x_return_status    OUT NOCOPY    VARCHAR2,
  x_msg_count        OUT NOCOPY    NUMBER,
  x_msg_data         OUT NOCOPY    VARCHAR2,
  p_Act_Resource_rec IN     Act_Resource_rec_type
);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Act_Resource
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_Act_Resource_id         IN   NUMBER
--       p_object_version_number   IN   NUMBER     Optional  Default = NULL
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================

PROCEDURE Delete_Act_Resource
( p_api_version      IN     NUMBER,
  p_init_msg_list    IN     VARCHAR2   := FND_API.G_FALSE,
  p_commit           IN     VARCHAR2   := FND_API.G_FALSE,
  p_validation_level IN     NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  x_return_status    OUT NOCOPY    VARCHAR2,
  x_msg_count        OUT NOCOPY    NUMBER,
  x_msg_data         OUT NOCOPY    VARCHAR2,

  p_Act_Resource_id  IN    NUMBER,
  p_object_version   IN    NUMBER
);


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Act_Resource
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_Act_Resource_id         IN   NUMBER    Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================

PROCEDURE Lock_Act_Resource
( p_api_version      IN     NUMBER,
  p_init_msg_list    IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level IN     NUMBER      := FND_API.G_VALID_LEVEL_FULL,
  x_return_status    OUT NOCOPY    VARCHAR2,
  x_msg_count        OUT NOCOPY    NUMBER,
  x_msg_data         OUT NOCOPY    VARCHAR2,

  p_Act_Resource_id  IN     NUMBER,
  p_object_version   IN     NUMBER
);

/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Validate_Act_Resource
--    Type        : Public
--    Function    : Validate a row in AMS_ACT_RESOURCES table
--
--    Paramaeters :
--
--    IN        :
--              p_api_version         IN NUMBER       Required
--              p_init_msg_list       IN VARCHAR2     Optional Default := FND_API.G_FALSE
--              p_validation_level    IN NUMBER       := FND_API.G_VALID_LEVEL_FULL,
--              p_Resource_rec        IN Act_Resource_rec_type  Required
--
--    OUT
--             x_return_status        OUT    VARCHAR2(1)
--             x_msg_count            OUT    NUMBER
--             x_msg_data             OUT    VARCHAR2(2000)
--
/*****************************************************************************************/

PROCEDURE Validate_Act_Resource
( p_api_version      IN   NUMBER,
  p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
  p_validation_level IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status    OUT NOCOPY  VARCHAR2,
  x_msg_count        OUT NOCOPY  NUMBER,
  x_msg_data         OUT NOCOPY  VARCHAR2,
  p_Act_Resource_rec   IN   Act_Resource_rec_type
);


END AMS_ActResource_PUB;

 

/
