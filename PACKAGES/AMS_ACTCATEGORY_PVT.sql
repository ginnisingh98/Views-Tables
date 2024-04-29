--------------------------------------------------------
--  DDL for Package AMS_ACTCATEGORY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ACTCATEGORY_PVT" AUTHID CURRENT_USER AS
/*$Header: amsvacts.pls 120.1 2005/06/15 01:31:17 appldev  $*/
-- Start of Comments
--
-- NAME
--   AMS_ActCategory_PVT
--
-- PURPOSE
--   This package is a Private API for managing Activity Category information in
--   AMS.
--
--   Procedures:
--     Create_Act_Category (see below for specification)
--     Update_Act_Category (see below for specification)
--     Delete_Act_Category (see below for specification)
--     Lock_Act_Category (see below for specification)
--     Validate_Act_Category (see below for specification)
--     Validate_Act_Cty_Items (see below for specification)
--     Validate_Act_Cty_Record (see below for specification
--
-- NOTES
--
-- History      created    sugupta   11/8/99
--
-- End of Comments

-- global constants

TYPE act_category_rec_type
IS RECORD
(
ACTIVITY_CATEGORY_ID		  NUMBER, -- PK
LAST_UPDATE_DATE                DATE,
LAST_UPDATED_BY                 NUMBER ,
CREATION_DATE                   DATE ,
CREATED_BY                      NUMBER ,
LAST_UPDATE_LOGIN               NUMBER ,
OBJECT_VERSION_NUMBER		  NUMBER,
ACT_CATEGORY_USED_BY_ID		  NUMBER,
ARC_ACT_CATEGORY_USED_BY		  VARCHAR2(30),
CATEGORY_ID				  NUMBER,
ATTRIBUTE_CATEGORY 		 	  VARCHAR2(30),
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

PROCEDURE Create_Act_Category
( p_api_version		IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE,
  p_commit			IN	VARCHAR2	:= FND_API.G_FALSE,
  p_validation_level	IN	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,

  p_act_category_rec	IN	act_category_rec_type,
  x_act_category_id	 OUT NOCOPY NUMBER
);

/****************************************************************************/
-- Start of Comments
--
--    API name    : Update_Act_Categories
--    Type        : Private
--    Function    : Update a row in AMS_ACT_CATEGORIES table
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
--    p_act_category_rec		   IN     Act_category_rec_type
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
--    Note	 : 1. p_act_Category_rec.act_category_id is a required parameter
--             2. p_act_Category_rec.act_category_id is not updatable
--
-- End Of Comments

PROCEDURE Update_Act_Category
( p_api_version		IN     NUMBER,
  p_init_msg_list		IN     VARCHAR2	:= FND_API.G_FALSE,
  p_commit			IN     VARCHAR2	:= FND_API.G_FALSE,
  p_validation_level	IN     NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY    VARCHAR2,
  x_msg_count		 OUT NOCOPY    NUMBER,
  x_msg_data		 OUT NOCOPY    VARCHAR2,

  p_act_category_rec	IN     Act_category_rec_type
);

/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Delete_Act_Category
--    Type        : Private
--    Function    : Delete a row in AMS_ACT_CATEGORIES table
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
--    p_act_Category_rec               IN     Act_category_rec_type  Required
--
--    standard OUT parameters
--    x_return_status                OUT    VARCHAR2(1)
--    x_msg_count                    OUT    NUMBER
--    x_msg_data                     OUT    VARCHAR2(2000)
--
--    Version    :     Current version     1.0
--                     Initial version     1.0
--
--    Note	 : 1. p_Category_rec.act_category_id is a required parameter
--
-- End Of Comments

PROCEDURE Delete_Act_Category
( p_api_version		IN     NUMBER,
  p_init_msg_list		IN     VARCHAR2	:= FND_API.G_FALSE,
  p_commit			IN     VARCHAR2	:= FND_API.G_FALSE,
  p_validation_level	IN     NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY    VARCHAR2,
  x_msg_count		 OUT NOCOPY    NUMBER,
  x_msg_data		 OUT NOCOPY    VARCHAR2,

  p_act_category_id      IN     NUMBER,
  p_object_version       IN     NUMBER
);


/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Lock_Act_Categories
--    Type        : Private
--    Function    : Lock a row in AMS_ACT_CATEGORIES table
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
--    p_Category_rec      IN     Act_category_rec_type Required
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
--    Note	 : p_Category_rec.act_category_id is a required parameter
--
-- End Of Comments

PROCEDURE Lock_Act_Category
( p_api_version		IN     NUMBER,
  p_init_msg_list		IN     VARCHAR2		:= FND_API.G_FALSE,
  p_validation_level	IN     NUMBER		:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY    VARCHAR2,
  x_msg_count		 OUT NOCOPY    NUMBER,
  x_msg_data		 OUT NOCOPY    VARCHAR2,

  p_act_category_id      IN     NUMBER,
  p_object_version       IN     NUMBER
);

/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Validate_Act_Categories
--    Type        : Private
--    Function    : Validate a row in AMS_ACT_CATEGORIES table
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
--    p_Category_rec               IN     Act_category_rec_type  Required
--
--    standard OUT parameters
--    x_return_status                OUT    VARCHAR2(1)
--    x_msg_count                    OUT    NUMBER
--    x_msg_data                     OUT    VARCHAR2(2000)
--
--    Version    :     Current version     1.0
--                     Initial version     1.0
--
--    Note	 : 1. p_Category_rec.act_category_id is a required parameter
--                 2. x_return_status will be FND_API.G_RET_STS_SUCCESS, FND_API.G_RET_STS_ERROR, or
--                    FND_API.G_RET_STS_UNEXP_ERROR
--
-- End Of Comments

PROCEDURE Validate_Act_Category
( p_api_version		IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE,
  p_validation_level	IN	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,

  p_act_category_rec	IN	act_category_rec_type
);

PROCEDURE Validate_Act_Cty_Items
( p_act_category_rec	IN   act_category_rec_type,
  p_validation_mode      IN   VARCHAR2 := JTF_PLSQL_API.g_create,
  x_return_status	 OUT NOCOPY  VARCHAR2
);

PROCEDURE Validate_Act_Cty_Record
(
  p_act_category_rec	IN	act_category_rec_type,
  x_return_status        OUT NOCOPY  VARCHAR2
);

PROCEDURE complete_act_category_rec(
  p_act_category_rec  IN    act_category_rec_type,
  x_act_category_rec  OUT NOCOPY   act_category_rec_type
);

END AMS_ActCategory_PVT;

 

/
