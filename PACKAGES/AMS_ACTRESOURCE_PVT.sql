--------------------------------------------------------
--  DDL for Package AMS_ACTRESOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ACTRESOURCE_PVT" AUTHID CURRENT_USER as
/*$Header: amsvrscs.pls 115.11 2002/11/22 23:37:33 dbiswas ship $*/

/*****************************************************************************************/
--
-- NAME
--   AMS_ActResource_PVT
--
-- PURPOSE
--   This package is a Private API for managing Product information in
--   AMS.
--
--   Procedures:
--     Create_Act_Resource (see below for specification)
--     Update_Act_Resource (see below for specification)
--     Delete_Act_Resource (see below for specification)
--     Lock_Act_Resource (see below for specification)
--     Validate_Act_Resource (see below for specification)
--     Validate_Act_Resource_Items (see below for specification)
--     Validate_Act_Rsc_Record (see below for specification
--
-- NOTES
--
-- History      created    rvaka   28-DEC-1999
--
/*****************************************************************************************/

-- global constants

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
   --TOP_LEVEL_PARTEN_ID        NUMBER,
   --TOP_LEVEL_PARENT_TYPE      VARCHAR2(30),
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

PROCEDURE Create_Act_Resource
( p_api_version      IN   NUMBER,
  p_init_msg_list    IN   VARCHAR2   := FND_API.G_FALSE,
  p_commit           IN   VARCHAR2   := FND_API.G_FALSE,
  p_validation_level IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
  x_return_status    OUT NOCOPY  VARCHAR2,
  x_msg_count        OUT NOCOPY  NUMBER,
  x_msg_data         OUT NOCOPY  VARCHAR2,

  p_Act_Resource_rec IN   Act_Resource_rec_type,
  x_Act_Resource_id  OUT NOCOPY  NUMBER
);

/****************************************************************************/
-- Start of Comments
--
--    API name    : Update_Act_Resource
--    Type        : Private
--    Function    : Update a row in AMS_ACT_RESOURCES table
--
--    Paramaeters :
--    IN        :
--    standard IN parameters
--    p_api_version       IN NUMBER       := NULL           Required
--    p_init_msg_list     IN VARCHAR2                       Optional
--    p_commit            IN VARCHAR2     := FND_API.G_FALSE Optional
--    p_validation_level  IN     NUMBER
--                            := FND_API.G_VALID_LEVEL_FULL,
--    API's IN parameters
--
--    p_Act_Resource_rec  IN     Act_Resource_rec_type
--
--    OUT        :
--    standard OUT parameters
--    x_return_status     OUT    VARCHAR2(1)
--    x_msg_count         OUT    NUMBER
--    x_msg_data          OUT    VARCHAR2(2000)
--
--
--    Note   : 1. p_Act_Resource_rec.activity_delivery_method_id is a required parameter
--             2. p_Act_Resource_rec.activity_delivery_method_id is not updatable
--
/****************************************************************************/

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

/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Delete_Act_Resource
--    Type        : Private
--    Function    : Delete a row in AMS_ACT_RESOURCES table
--
--    Paramaeters :
--    IN        :
--    standard IN parameters
--    p_api_version         IN NUMBER       := NULL        Required
--    p_init_msg_list       IN VARCHAR2    Optional
--             Default := FND_API.G_FALSE
--    p_commit              IN VARCHAR2     := FND_API.G_FALSE Optional
--    p_validation_level    IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
--    API's IN parameters
--    p_Act_Resource_rec    IN     Act_Resource_rec_type  Required
--
--    standard OUT parameters
--    x_return_status       OUT    VARCHAR2(1)
--    x_msg_count           OUT    NUMBER
--    x_msg_data            OUT    VARCHAR2(2000)
--
--
--    Note   : 1. p_Resource_rec.activity_Delivery_method_id is a required parameter
--
/*****************************************************************************************/

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


/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Lock_Act_Resource
--    Type        : Private
--    Function    : Lock a row in AMS_ACT_RESOURCES table
--
--    Paramaeters :
--    IN        :
--    standard IN parameters
--    p_api_version       IN NUMBER      := NULL      Required
--    p_init_msg_list     IN VARCHAR2           Optional
--             Default := FND_API.G_FALSE
--    p_validation_level  IN     NUMBER  := FND_API.G_VALID_LEVEL_FULL,
--    API's IN parameters
--    p_Resource_rec      IN     Act_Resource_rec_type Required
--    OUT        :
--    standard OUT parameters
--    x_return_status     OUT    VARCHAR2(1)
--    x_msg_count         OUT    NUMBER
--    x_msg_data          OUT    VARCHAR2(2000)
--
--    Note   : p_Resource_rec.activity_product_id is a required parameter
--
/*****************************************************************************************/

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
--    Type        : Private
--    Function    : Validate a row in AMS_ACT_RESOURCES table
--
--    Paramaeters :
--    IN        :
--    standard IN parameters
--    p_api_version         IN NUMBER       := NULL  Required
--    p_init_msg_list       IN VARCHAR2              Optional
--             Default := FND_API.G_FALSE
--    p_validation_level    IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
--    API's IN parameters
--
--    p_Resource_rec        IN     Act_Resource_rec_type  Required
--
--    standard OUT parameters
--    x_return_status       OUT    VARCHAR2(1)
--    x_msg_count           OUT    NUMBER
--    x_msg_data            OUT    VARCHAR2(2000)
--
--
--    Note : 1. p_Resource_rec.activity_product_id is a required parameter
--           2. x_return_status will be FND_API.G_RET_STS_SUCCESS,
--              FND_API.G_RET_STS_ERROR, or
--              FND_API.G_RET_STS_UNEXP_ERROR
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

PROCEDURE Validate_Act_Resource_Items
( p_Act_Resource_rec  IN   Act_Resource_rec_type,
  p_validation_mode   IN   VARCHAR2 := JTF_PLSQL_API.g_create,
  x_return_status     OUT NOCOPY  VARCHAR2
);

PROCEDURE Validate_Act_Rsc_Record
(
  p_Act_Resource_rec   IN   Act_Resource_rec_type,
  x_return_status      OUT NOCOPY  VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    init_Act_Rsc_Record
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE init_Act_Rsc_Record(
   x_Act_Resource_rec       OUT NOCOPY  Act_Resource_rec_type
);


PROCEDURE complete_Act_Resource_rec(
  p_Act_Resource_rec  IN    Act_Resource_rec_type,
  x_Act_Resource_rec  OUT NOCOPY   Act_Resource_rec_type
);

END AMS_ActResource_PVT;

 

/
