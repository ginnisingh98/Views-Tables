--------------------------------------------------------
--  DDL for Package AMS_CATEGORY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CATEGORY_PVT" AUTHID CURRENT_USER as
/* $Header: amsvctys.pls 120.1 2005/10/21 03:49:16 vmodur noship $ */

-- Start of Comments
--
-- NAME
--   AMS_Category_PVT
--
-- PURPOSE
--   This package is a Private API for managing Category information in
--   AMS.  It contains specification for pl/sql records and tables
--
--   Procedures:
--     Create_Category (see below for specification)
--     Update_Category (see below for specification)
--     Delete_Category (see below for specification)
--     Lock_Category (see below for specification)
--     Validate_Category (see below for specification)
--     Validate_Cty_Items (see below for specification)
--     Validate_Cty_Record (see below for specification)
--     Validate_Cty_Child_Enty (see below for specification)
--     Check_REQ_Cty_Items (see below for specification)
--
-- NOTES
--
--
-- HISTORY
--   01/04/2000     sugupta created
--   06/01/2000     khung   add two new columns accrued_liability_account
--                          and ded_adjustment_account

-- End of Comments

-- global constants

TYPE category_rec_type
IS RECORD
(
CATEGORY_ID                     NUMBER,
 LAST_UPDATE_DATE               DATE,
 LAST_UPDATED_BY                NUMBER,
 CREATION_DATE                  DATE,
 CREATED_BY                     NUMBER,
 LAST_UPDATE_LOGIN              NUMBER,
 OBJECT_VERSION_NUMBER          NUMBER,
 ARC_CATEGORY_CREATED_FOR       VARCHAR2(30),
 ENABLED_FLAG                   VARCHAR2(1),
 PARENT_CATEGORY_ID             NUMBER,
 ATTRIBUTE_CATEGORY             VARCHAR2(30),
 ATTRIBUTE1                     VARCHAR2(150),
 ATTRIBUTE2                     VARCHAR2(150),
 ATTRIBUTE3                VARCHAR2(150),
 ATTRIBUTE4                VARCHAR2(150),
 ATTRIBUTE5                VARCHAR2(150),
 ATTRIBUTE6                VARCHAR2(150),
 ATTRIBUTE7                VARCHAR2(150),
 ATTRIBUTE8                VARCHAR2(150),
 ATTRIBUTE9                VARCHAR2(150),
 ATTRIBUTE10               VARCHAR2(150),
 ATTRIBUTE11               VARCHAR2(150),
 ATTRIBUTE12               VARCHAR2(150),
 ATTRIBUTE13               VARCHAR2(150),
 ATTRIBUTE14               VARCHAR2(150),
 ATTRIBUTE15               VARCHAR2(150),
 SOURCE_LANG               VARCHAR2(4),
 CATEGORY_NAME             VARCHAR2(120),
 DESCRIPTION               VARCHAR2(4000),
 ACCRUED_LIABILITY_ACCOUNT NUMBER,
 DED_ADJUSTMENT_ACCOUNT    NUMBER,
 BUDGET_CODE_SUFFIX        VARCHAR2(30),
 LEDGER_ID                 NUMBER
 );

/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Create_Categories
--    Type        : Private
--    Function    : Create a row in ams_Categories table
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    standard IN parameters
--    p_api_version			IN	NUMBER       := NULL           		Required
--    p_init_msg_list			IN	VARCHAR2                       		Optional
--				    Default := FND_API.g_false,
--    p_commit				IN	VARCHAR2     := FND_API.g_false,  Optional
--    p_validation_level		IN	NUMBER
--                            := FND_API.g_valid_level_full,
--
--    API's IN parameters
--    p_Category_rec			IN	category_rec_type Required
--    OUT        :
--    standard OUT parameters
--    x_return_status			OUT	VARCHAR2(1)
--    x_msg_count			OUT	NUMBER
--    x_msg_data			OUT	VARCHAR2(2000)
--
--
--    API's OUT parameters
--    x_Category_id			OUT	NUMBER
--
--
--    Version    :     Current version     1.0
--                     Initial version     1.0
--
--    Note	 : 1. p_Category_rec.category_id is a required parameter
--
-- End Of Comments

PROCEDURE Create_Category
( p_api_version				IN	NUMBER,
  p_init_msg_list			IN	VARCHAR2    := FND_API.g_false,
  p_commit				IN	VARCHAR2    := FND_API.g_false,
  p_validation_level			IN	NUMBER      := FND_API.g_valid_level_full,
  x_return_status		 OUT NOCOPY VARCHAR2,
  x_msg_count			 OUT NOCOPY NUMBER,
  x_msg_data			 OUT NOCOPY VARCHAR2,
  p_category_rec			IN	category_rec_type,
  x_category_id			 OUT NOCOPY NUMBER
);

/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Update_Categories
--    Type        : Private
--    Function    : Update a row in ams_categories table
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    standard IN parameters
--    p_api_version			IN	NUMBER       := NULL           		Required
--    p_init_msg_list			IN	VARCHAR2                       		Optional
--             Default := FND_API.g_false
--    p_commit				IN	VARCHAR2     := FND_API.g_false Optional
--    p_validation_level		IN	NUMBER	     := FND_API.g_valid_level_full,
--    API's IN parameters
--    p_Category_rec			IN	category_rec_type Required
--
--    OUT        :
--    standard OUT parameters
--    x_return_status			OUT	VARCHAR2(1)
--    x_msg_count			OUT	NUMBER
--    x_msg_data			OUT	VARCHAR2(2000)
--
--
--    Version    :     Current version     1.0
--                     Initial version     1.0
--
--    Note	 : 1. p_Category_rec.category_id is a required parameter
--             2. p_Category_rec.category_id is not updatable
--
-- End Of Comments

PROCEDURE Update_Category
( p_api_version			IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2    := FND_API.g_false,
  p_commit			IN	VARCHAR2    := FND_API.g_false,
  p_validation_level		IN	NUMBER      := FND_API.g_valid_level_full,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,

  p_category_rec		IN	category_rec_type
);

/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Delete_Categories
--    Type        : Private
--    Function    : Delete a row in ams_Categories table
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    standard IN parameters
--    p_api_version			IN	NUMBER       := NULL           		Required
--    p_init_msg_list			IN	VARCHAR2                       		Optional
--             Default := FND_API.g_false
--    p_commit				IN	VARCHAR2     := FND_API.g_false Optional
--    p_validation_level		IN	NUMBER
--                            := FND_API.g_valid_level_full,
--    API's IN parameters
--    p_Category_rec			IN	category_rec_type Required
--
--
--    OUT        :
--    standard OUT parameters
--    x_return_status			OUT	VARCHAR2(1)
--    x_msg_count			OUT	NUMBER
--    x_msg_data			OUT	VARCHAR2(2000)
--
--    Version    :     Current version     1.0
--                     Initial version     1.0
--
--    Note	 : 1. p_Category_rec.category_id is a required parameter
--
-- End Of Comments

PROCEDURE Delete_Category
( p_api_version			IN     NUMBER,
  p_init_msg_list		IN     VARCHAR2    := FND_API.g_false,
  p_commit			IN     VARCHAR2    := FND_API.g_false,
  p_validation_level		IN     NUMBER      := FND_API.g_valid_level_full,
  x_return_status	 OUT NOCOPY    VARCHAR2,
  x_msg_count		 OUT NOCOPY    NUMBER,
  x_msg_data		 OUT NOCOPY    VARCHAR2,

  p_category_id		IN     NUMBER,
  p_object_version    IN  NUMBER
);


/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Lock_Categories
--    Type        : Private
--    Function    : Lock a row in ams_Categories table
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    standard IN parameters
--    p_api_version		IN	NUMBER       := NULL           		Required
--    p_init_msg_list		IN	VARCHAR2                       		Optional
--             Default := FND_API.g_false
--    p_validation_level	IN	NUMBER   := FND_API.g_valid_level_full,
--    API's IN parameters
--  p_category_id		IN     NUMBER   required
--   p_object_version    IN  NUMBER		 required
--    standard OUT parameters
--    x_return_status		OUT	VARCHAR2(1)
--    x_msg_count		OUT	NUMBER
--    x_msg_data		OUT	VARCHAR2(2000)
--
--
--    Version    :     Current version     1.0
--                     Initial version     1.0
--
--    Note	 : p_Category_rec.category_id is a required parameter
--
-- End Of Comments

PROCEDURE Lock_Category
( p_api_version			IN     NUMBER,
  p_init_msg_list		IN     VARCHAR2    := FND_API.g_false,
  p_validation_level		IN     NUMBER      := FND_API.g_valid_level_full,
  x_return_status	 OUT NOCOPY    VARCHAR2,
  x_msg_count		 OUT NOCOPY    NUMBER,
  x_msg_data		 OUT NOCOPY    VARCHAR2,

  p_category_id		IN     NUMBER,
  p_object_version    IN  NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    complete_category_rec
--
-- PURPOSE
--    For update_category, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_category_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE complete_category_rec(
   p_category_rec       IN  category_rec_type,
   x_complete_rec  OUT NOCOPY category_rec_type
);

/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Validate_Categories
--    Type        : Private
--    Function    : Validate a row in ams_Categories table
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    standard IN parameters
--    p_api_version			IN	NUMBER       := NULL           		Required
--    p_init_msg_list			IN	VARCHAR2                       		Optional
--             Default := FND_API.g_false
--    p_validation_level		IN	NUMBER
--                            := FND_API.g_valid_level_full,
--    API's IN parameters
--    p_Category_rec			IN	category_rec_type Required
--
--    OUT        :
--    standard OUT parameters
--    x_return_status			OUT	VARCHAR2(1)
--    x_msg_count			OUT	NUMBER
--    x_msg_data			OUT	VARCHAR2(2000)
--
--    API's OUT parameters
--    x_Category_rec			OUT	category_rec_type
--
--
--    Version    :     Current version     1.0
--                     Initial version     1.0
--
--    Note	 : 1. p_Category_rec.category_id is a required parameter
--                 2. x_return_status will be FND_API.G_RET_STS_SUCCESS, FND_API.G_RET_STS_ERROR, or
--                    FND_API.G_RET_STS_UNEXP_ERROR
--
-- End Of Comments

PROCEDURE Validate_Category
( p_api_version			IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2	:= FND_API.g_false,
  p_validation_level		IN	NUMBER		:= FND_API.g_valid_level_full,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,

  p_category_rec		IN	category_rec_type
);

/*****************************************************************************************/
-- Start of Comments
--
--    Name        : Validate_Cty_Items
--    Type        : Private
--    Function    : Validate columns in ams_Categories table
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    p_Category_rec			IN	category_rec_type Required
--
--    OUT        :
--    x_return_status			OUT	VARCHAR2
--
-- End Of Comments

PROCEDURE Validate_Cty_Items
( p_category_rec			IN	category_rec_type,
  x_return_status		 OUT NOCOPY VARCHAR2
);

/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Validate_Cty_Record
--    Type        : Private
--    Function    : Validate a row in ams_Categories table
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    standard IN parameters
--    p_api_version			IN NUMBER       := NULL           		Required
--    p_init_msg_list			IN VARCHAR2                       		Optional
--             Default := FND_API.g_false
--    API's IN parameters
--
--    p_Category_rec			IN	category_rec_type Required
--
--
--    OUT        :
--    standard OUT parameters
--    x_return_status			OUT	VARCHAR2(1)
--    x_msg_count			OUT	NUMBER
--    x_msg_data			OUT	VARCHAR2(2000)
--
--    Version    :     Current version     1.0
--                     Initial version     1.0
--
--    Note	 : x_return_status will be FND_API.G_RET_STS_SUCCESS, FND_API.G_RET_STS_ERROR, or
--                 FND_API.G_RET_STS_UNEXP_ERROR
--
-- End Of Comments

PROCEDURE Validate_Cty_Record
( p_api_version				IN	NUMBER,
  p_init_msg_list			IN	VARCHAR2    := FND_API.g_false,
  x_return_status		 OUT NOCOPY VARCHAR2,
  x_msg_count			 OUT NOCOPY NUMBER,
  x_msg_data			 OUT NOCOPY VARCHAR2,

  p_category_rec			IN	category_rec_type
);

/*****************************************************************************************/
-- Start of Comments
--
--    Name        : Validate_Cty_Child_Enty
--    Type        : Private
--    Function    : Check to see if any child entity exists
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    p_Category_id			IN	NUMBER Required
--
--    OUT        :
--    x_return_status			OUT	VARCHAR2
--
-- End Of Comments

PROCEDURE Validate_Cty_Child_Enty
( p_category_id		IN	NUMBER,
  x_return_status	 OUT NOCOPY VARCHAR2
);

/*****************************************************************************************/
-- Start of Comments
--
--    Name        : Check_REQ_Cty_Items
--    Type        : Private
--    Function    : Check required parameters for caller needs
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    p_category_rec			IN	category_rec_type Required
--
--    OUT        :
--    x_return_status			OUT	VARCHAR2
--
-- End Of Comments

PROCEDURE Check_REQ_Cty_Items
( p_category_rec			IN	category_rec_type,
  x_return_status		 OUT NOCOPY VARCHAR2
);

--
-- unit test procedure
--
/*
PROCEDURE Unit_Test_Insert;
PROCEDURE Unit_Test_Delete;
PROCEDURE Unit_Test_Update;
PROCEDURE Unit_Test_Lock;


PROCEDURE Unit_Test_Act_Insert;
PROCEDURE Unit_Test_Act_Delete;
PROCEDURE Unit_Test_Act_Update;
PROCEDURE Unit_Test_Act_Lock;
*/

END AMS_Category_PVT;

 

/
