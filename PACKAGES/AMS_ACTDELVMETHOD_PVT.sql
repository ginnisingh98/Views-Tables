--------------------------------------------------------
--  DDL for Package AMS_ACTDELVMETHOD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ACTDELVMETHOD_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvdlvs.pls 120.1 2005/06/27 05:41:21 appldev ship $ */

-- Start of Comments
--
-- NAME
--   AMS_ActDelvMethod_PVT
--
-- PURPOSE
--   This package is a Private API for managing Delivery Method information in
--   AMS.
--
--   Procedures:
--     Create_Act_DelvMethod (see below for specification)
--     Update_Act_DelvMethod (see below for specification)
--     Delete_Act_DelvMethod (see below for specification)
--     Lock_Act_DelvMethod (see below for specification)
--     Validate_Act_DelvMethod (see below for specification)
--     Validate_Act_DelvMethod_Items (see below for specification)
--     Validate_Act_DelvMethod_Record (see below for specification
--
-- NOTES
--
-- History      created    rvaka   11/11/1999
--
-- End of Comments

-- global constants

TYPE act_DelvMethod_rec_type
IS RECORD
(
ACTIVITY_DELIVERY_METHOD_ID     NUMBER, -- PK
LAST_UPDATE_DATE                DATE,
LAST_UPDATED_BY                 NUMBER ,
CREATION_DATE                   DATE ,
CREATED_BY                      NUMBER ,
LAST_UPDATE_LOGIN               NUMBER ,
OBJECT_VERSION_NUMBER		NUMBER,

ACT_DELIVERY_METHOD_USED_BY_ID  NUMBER,
ARC_ACT_DELIVERY_USED_BY	VARCHAR2(30),
DELIVERY_MEDIA_TYPE_CODE	VARCHAR2(30),

ATTRIBUTE_CATEGORY 		VARCHAR2(30),
ATTRIBUTE1 		 VARCHAR2(150),
ATTRIBUTE2 		 VARCHAR2(150),
ATTRIBUTE3 		 VARCHAR2(150),
ATTRIBUTE4 		 VARCHAR2(150),
ATTRIBUTE5 		 VARCHAR2(150),
ATTRIBUTE6 		 VARCHAR2(150),
ATTRIBUTE7 		 VARCHAR2(150),
ATTRIBUTE8 		 VARCHAR2(150),
ATTRIBUTE9 		 VARCHAR2(150),
ATTRIBUTE10 		 VARCHAR2(150),
ATTRIBUTE11 		 VARCHAR2(150),
ATTRIBUTE12 		 VARCHAR2(150),
ATTRIBUTE13 		 VARCHAR2(150),
ATTRIBUTE14 		 VARCHAR2(150),
ATTRIBUTE15 		 VARCHAR2(150)
);

PROCEDURE Create_Act_DelvMethod
( p_api_version		IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE,
  p_commit			IN	VARCHAR2	:= FND_API.G_FALSE,
  p_validation_level	IN	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,

  p_act_DelvMethod_rec	IN	Act_DelvMethod_rec_type,
  x_act_DelvMethod_id	 OUT NOCOPY NUMBER
);

/****************************************************************************/
-- Start of Comments
--
--    API name    : Update_Act_DelvMethod
--    Type        : Private
--    Function    : Update a row in AMS_ACT_DELIVERY_METHODS table
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    standard IN parameters
--    p_api_version       IN NUMBER       := NULL           		Required
--    p_init_msg_list     IN VARCHAR2                       		Optional
--    p_commit		  IN VARCHAR2     := FND_API.G_FALSE Optional
--    p_validation_level		  IN     NUMBER
--                            := FND_API.G_VALID_LEVEL_FULL,
--    API's IN parameters
--
--    p_act_DelvMethod_rec		   IN     Act_DelvMethod_rec_type
--
--    OUT        :
--    standard OUT parameters
--    x_return_status            OUT    VARCHAR2(1)
--    x_msg_count                OUT    NUMBER
--    x_msg_data                 OUT    VARCHAR2(2000)
--
--    Version    :     Current version     1.0
--                     Initial version     1.0
--
--    Note	 : 1. p_act_DelvMethod_rec.activity_delivery_method_id is a required parameter
--             2. p_act_DelvMethod_rec.activity_delivery_method_id is not updatable
--
-- End Of Comments

PROCEDURE Update_Act_DelvMethod
( p_api_version		IN     NUMBER,
  p_init_msg_list		IN     VARCHAR2	:= FND_API.G_FALSE,
  p_commit			IN     VARCHAR2	:= FND_API.G_FALSE,
  p_validation_level	IN     NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY    VARCHAR2,
  x_msg_count		 OUT NOCOPY    NUMBER,
  x_msg_data		 OUT NOCOPY    VARCHAR2,

  p_act_DelvMethod_rec	IN     Act_DelvMethod_rec_type
);

/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Delete_Act_DelvMethod
--    Type        : Private
--    Function    : Delete a row in AMS_ACT_DELIVERY_METHODS table
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    standard IN parameters
--    p_api_version         IN NUMBER       := NULL        Required
--    p_init_msg_list       IN VARCHAR2    Optional
--             Default := FND_API.G_FALSE
--    p_commit			  IN VARCHAR2     := FND_API.G_FALSE Optional
--    p_validation_level    IN     NUMBER
--                            := FND_API.G_VALID_LEVEL_FULL,
--    API's IN parameters
--    p_act_DelvMethod_rec               IN     Act_DelvMethod_rec_type  Required
--
--    standard OUT parameters
--    x_return_status                OUT    VARCHAR2(1)
--    x_msg_count                    OUT    NUMBER
--    x_msg_data                     OUT    VARCHAR2(2000)
--
--    Version    :     Current version     1.0
--                     Initial version     1.0
--
--    Note	 : 1. p_DelvMethod_rec.activity_Delivery_method_id is a required parameter
--
-- End Of Comments

PROCEDURE Delete_Act_DelvMethod
( p_api_version		IN     NUMBER,
  p_init_msg_list	IN     VARCHAR2	:= FND_API.G_FALSE,
  p_commit		IN     VARCHAR2	:= FND_API.G_FALSE,
  p_validation_level	IN     NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY    VARCHAR2,
  x_msg_count	 OUT NOCOPY    NUMBER,
  x_msg_data	 OUT NOCOPY    VARCHAR2,

  p_act_DelvMethod_id   IN     NUMBER,
  p_object_version      IN     NUMBER
);


/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Lock_Act_DelvMethod
--    Type        : Private
--    Function    : Lock a row in AMS_ACT_DELIVERY_METHODS table
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    standard IN parameters
--    p_api_version       IN NUMBER       := NULL      Required
--    p_init_msg_list     IN VARCHAR2           		Optional
--             Default := FND_API.G_FALSE
--    p_validation_level  IN     NUMBER
--                            := FND_API.G_VALID_LEVEL_FULL,
--    API's IN parameters
--    p_DelvMethod_rec      IN     Act_DelvMethod_rec_type Required
--    OUT        :
--    standard OUT parameters
--    x_return_status     OUT    VARCHAR2(1)
--    x_msg_count         OUT    NUMBER
--    x_msg_data          OUT    VARCHAR2(2000)
--
--
--    Version    :     Current version     1.0
--                     Initial version     1.0
--
--    Note	 : p_DelvMethod_rec.activity_category_id is a required parameter
--
-- End Of Comments

PROCEDURE Lock_Act_DelvMethod
( p_api_version		IN     NUMBER,
  p_init_msg_list	IN     VARCHAR2		:= FND_API.G_FALSE,
  p_validation_level	IN     NUMBER		:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY    VARCHAR2,
  x_msg_count	 OUT NOCOPY    NUMBER,
  x_msg_data	 OUT NOCOPY    VARCHAR2,

  p_act_DelvMethod_id   IN     NUMBER,
  p_object_version      IN     NUMBER
);

/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Validate_Act_DelvMethod
--    Type        : Private
--    Function    : Validate a row in AMS_ACT_DELIVERY_METHODS table
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    standard IN parameters
--    p_api_version         IN NUMBER       := NULL  Required
--    p_init_msg_list       IN VARCHAR2              Optional
--             Default := FND_API.G_FALSE
--    p_validation_level            IN     NUMBER
--                            := FND_API.G_VALID_LEVEL_FULL,
--    API's IN parameters
--
--    p_DelvMethod_rec               IN     Act_DelvMethod_rec_type  Required
--
--    standard OUT parameters
--    x_return_status                OUT    VARCHAR2(1)
--    x_msg_count                    OUT    NUMBER
--    x_msg_data                     OUT    VARCHAR2(2000)
--
--    Version    :     Current version     1.0
--                     Initial version     1.0
--
--    Note : 1. p_DelvMethod_rec.activity_delivery_method_id is a required parameter
--           2. x_return_status will be FND_API.G_RET_STS_SUCCESS,
--		FND_API.G_RET_STS_ERROR, or
--              FND_API.G_RET_STS_UNEXP_ERROR
--
-- End Of Comments

PROCEDURE Validate_Act_DelvMethod
( p_api_version		IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE,
  p_validation_level	IN	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,

  p_act_DelvMethod_rec	IN	Act_DelvMethod_rec_type
);

PROCEDURE Validate_Act_DelvMethod_Items
( p_act_DelvMethod_rec	IN   Act_DelvMethod_rec_type,
  p_validation_mode      IN   VARCHAR2 := JTF_PLSQL_API.g_create,
  x_return_status	 OUT NOCOPY  VARCHAR2
);

PROCEDURE Validate_Act_DelvMethod_Record
(
  p_act_DelvMethod_rec	IN	Act_DelvMethod_rec_type,
  x_return_status        OUT NOCOPY  VARCHAR2
);
--added sugupta 07/25/2000  init_act_DelvMethod_rec
PROCEDURE init_act_DelvMethod_rec(
   x_act_DelvMethod_rec  OUT NOCOPY  act_DelvMethod_rec_type
);
PROCEDURE complete_act_DelvMethod_rec(
  p_act_DelvMethod_rec  IN    Act_DelvMethod_rec_type,
  x_act_DelvMethod_rec  OUT NOCOPY   Act_DelvMethod_rec_type
);

END AMS_ActDelvMethod_PVT;

 

/
