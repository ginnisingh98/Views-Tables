--------------------------------------------------------
--  DDL for Package AMS_ACTPRODUCT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ACTPRODUCT_PVT" AUTHID CURRENT_USER as
/*$Header: amsvprds.pls 120.0 2005/06/01 00:06:54 appldev noship $*/

-- Start of Comments
--
-- NAME
--   AMS_ActProduct_PVT
--
-- PURPOSE
--   This package is a Private API for managing Product information in
--   AMS.
--
--   Procedures:
--     Create_Act_Product (see below for specification)
--     Update_Act_Product (see below for specification)
--     Delete_Act_Product (see below for specification)
--     Lock_Act_Product (see below for specification)
--     Validate_Act_Product (see below for specification)
--     Validate_Act_Product_Items (see below for specification)
--     Validate_Act_Product_Record (see below for specification
--
-- NOTES
--
-- History      created    rvaka   28-DEC-1999
--              01-MAY-2001  julou     modified, added 3 columns to ams_act_products
--                                     security_group_id, line_lumpsum_amount, line_lumpsum_qty
--              05-Nov-2001  musman    Commented out the reference to security_group_id

-- End of Comments

-- global constants

TYPE act_Product_rec_type
IS RECORD
(
ACTIVITY_PRODUCT_ID             NUMBER,
LAST_UPDATE_DATE                DATE,
LAST_UPDATED_BY                 NUMBER,
CREATION_DATE                   DATE,
CREATED_BY                      NUMBER,
LAST_UPDATE_LOGIN               NUMBER,
OBJECT_VERSION_NUMBER           NUMBER,
ACT_PRODUCT_USED_BY_ID          NUMBER,
ARC_ACT_PRODUCT_USED_BY         VARCHAR2(30),
PRODUCT_SALE_TYPE               VARCHAR2(30),
PRIMARY_PRODUCT_FLAG            VARCHAR2(1),
ENABLED_FLAG                    VARCHAR2(1),
EXCLUDED_FLAG                   VARCHAR2(1),
CATEGORY_ID                     NUMBER,
CATEGORY_SET_ID                 NUMBER,
ORGANIZATION_ID                 NUMBER,
INVENTORY_ITEM_ID               NUMBER,
LEVEL_TYPE_CODE                 VARCHAR2(30),
--SECURITY_GROUP_ID    NUMBER,
LINE_LUMPSUM_AMOUNT  NUMBER,
LINE_LUMPSUM_QTY     NUMBER,
ATTRIBUTE_CATEGORY              VARCHAR2(30),
ATTRIBUTE1               VARCHAR2(150),
ATTRIBUTE2               VARCHAR2(150),
ATTRIBUTE3               VARCHAR2(150),
ATTRIBUTE4               VARCHAR2(150),
ATTRIBUTE5               VARCHAR2(150),
ATTRIBUTE6               VARCHAR2(150),
ATTRIBUTE7               VARCHAR2(150),
ATTRIBUTE8               VARCHAR2(150),
ATTRIBUTE9               VARCHAR2(150),
ATTRIBUTE10              VARCHAR2(150),
ATTRIBUTE11              VARCHAR2(150),
ATTRIBUTE12              VARCHAR2(150),
ATTRIBUTE13              VARCHAR2(150),
ATTRIBUTE14              VARCHAR2(150),
ATTRIBUTE15              VARCHAR2(150),
CHANNEL_ID           NUMBER,
UOM_CODE             VARCHAR2(3),
QUANTITY             NUMBER,
SCAN_VALUE           NUMBER,
SCAN_UNIT_FORECAST   NUMBER,
ADJUSTMENT_FLAG      VARCHAR2(1));

FUNCTION get_actual_unit(p_activity_product_id IN NUMBER)
RETURN NUMBER;

--FUNCTION get_actual_amount(p_activity_product_id IN NUMBER)
--RETURN NUMBER;

PROCEDURE Create_Act_Product
( p_api_version         IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2        := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,

  p_act_Product_rec     IN      Act_Product_rec_type,
  x_act_Product_id       OUT NOCOPY NUMBER
);

/****************************************************************************/
-- Start of Comments
--
--    API name    : Update_Act_Product
--    Type        : Private
--    Function    : Update a row in AMS_ACT_PRODUCTS table
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    standard IN parameters
--    p_api_version       IN NUMBER       := NULL                       Required
--    p_init_msg_list     IN VARCHAR2                                   Optional
--    p_commit            IN VARCHAR2     := FND_API.G_FALSE Optional
--    p_validation_level                  IN     NUMBER
--                            := FND_API.G_VALID_LEVEL_FULL,
--    API's IN parameters
--
--    p_act_Product_rec            IN     Act_Product_rec_type
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
--    Note       : 1. p_act_Product_rec.activity_delivery_method_id is a required parameter
--             2. p_act_Product_rec.activity_delivery_method_id is not updatable
--
-- End Of Comments

PROCEDURE Update_Act_Product
( p_api_version         IN     NUMBER,
  p_init_msg_list               IN     VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN     VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_count            OUT NOCOPY    NUMBER,
  x_msg_data             OUT NOCOPY    VARCHAR2,

  p_act_Product_rec     IN     Act_Product_rec_type
);

/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Delete_Act_Product
--    Type        : Private
--    Function    : Delete a row in AMS_ACT_PRODUCTS table
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    standard IN parameters
--    p_api_version         IN NUMBER       := NULL        Required
--    p_init_msg_list       IN VARCHAR2    Optional
--             Default := FND_API.G_FALSE
--    p_commit                    IN VARCHAR2     := FND_API.G_FALSE Optional
--    p_validation_level    IN     NUMBER
--                            := FND_API.G_VALID_LEVEL_FULL,
--    API's IN parameters
--    p_act_Product_rec               IN     Act_Product_rec_type  Required
--
--    standard OUT parameters
--    x_return_status                OUT    VARCHAR2(1)
--    x_msg_count                    OUT    NUMBER
--    x_msg_data                     OUT    VARCHAR2(2000)
--
--    Version    :     Current version     1.0
--                     Initial version     1.0
--
--    Note       : 1. p_Product_rec.activity_Delivery_method_id is a required parameter
--
-- End Of Comments

PROCEDURE Delete_Act_Product
( p_api_version         IN     NUMBER,
  p_init_msg_list       IN     VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN     VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY    VARCHAR2,
  x_msg_count    OUT NOCOPY    NUMBER,
  x_msg_data     OUT NOCOPY    VARCHAR2,

  p_act_Product_id   IN     NUMBER,
  p_object_version      IN     NUMBER
);


/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Lock_Act_Product
--    Type        : Private
--    Function    : Lock a row in AMS_ACT_PRODUCTS table
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    standard IN parameters
--    p_api_version       IN NUMBER       := NULL      Required
--    p_init_msg_list     IN VARCHAR2                           Optional
--             Default := FND_API.G_FALSE
--    p_validation_level  IN     NUMBER
--                            := FND_API.G_VALID_LEVEL_FULL,
--    API's IN parameters
--    p_Product_rec      IN     Act_Product_rec_type Required
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
--    Note       : p_Product_rec.activity_product_id is a required parameter
--
-- End Of Comments

PROCEDURE Lock_Act_Product
( p_api_version         IN     NUMBER,
  p_init_msg_list       IN     VARCHAR2         := FND_API.G_FALSE,
  p_validation_level    IN     NUMBER           := FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY    VARCHAR2,
  x_msg_count    OUT NOCOPY    NUMBER,
  x_msg_data     OUT NOCOPY    VARCHAR2,

  p_act_Product_id   IN     NUMBER,
  p_object_version      IN     NUMBER
);

/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Validate_Act_Product
--    Type        : Private
--    Function    : Validate a row in AMS_ACT_PRODUCTS table
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
--    p_Product_rec               IN     Act_Product_rec_type  Required
--
--    standard OUT parameters
--    x_return_status                OUT    VARCHAR2(1)
--    x_msg_count                    OUT    NUMBER
--    x_msg_data                     OUT    VARCHAR2(2000)
--
--    Version    :     Current version     1.0
--                     Initial version     1.0
--
--    Note : 1. p_Product_rec.activity_product_id is a required parameter
--           2. x_return_status will be FND_API.G_RET_STS_SUCCESS,
--              FND_API.G_RET_STS_ERROR, or
--              FND_API.G_RET_STS_UNEXP_ERROR
--
-- End Of Comments

PROCEDURE Validate_Act_Product
( p_api_version         IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2        := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,

  p_act_Product_rec     IN      Act_Product_rec_type
);

PROCEDURE Validate_Act_Product_Items
( p_act_Product_rec     IN   Act_Product_rec_type,
  p_validation_mode      IN   VARCHAR2 := JTF_PLSQL_API.g_create,
  x_return_status        OUT NOCOPY  VARCHAR2
);

PROCEDURE Validate_Act_Product_Record
(
  p_act_Product_rec     IN      Act_Product_rec_type,
  x_return_status        OUT NOCOPY  VARCHAR2
);

PROCEDURE complete_act_Product_rec(
  p_act_Product_rec  IN    Act_Product_rec_type,
  x_act_Product_rec  OUT NOCOPY   Act_Product_rec_type
);

FUNCTION get_category_name(
  p_category_id  IN  NUMBER,
  p_category_set_id IN NUMBER,
  p_object_type in varchar2
) RETURN VARCHAR2;

FUNCTION get_category_desc(
  p_category_id  IN  NUMBER,
  p_category_set_id IN NUMBER,
  p_object_type in varchar2
) RETURN VARCHAR2;

-------------------------------------------------------------
-- Start of Comments
-- Name
-- UPDATE_SCHEDULE_ACTIVITIES
--
-- Purpose
-- This function is called from Business Event
-------------------------------------------------------------
FUNCTION UPDATE_SCHEDULE_ACTIVITIES(p_subscription_guid   IN       RAW,
                 p_event               IN OUT NOCOPY  WF_EVENT_T
) RETURN VARCHAR2;

PROCEDURE IS_ALL_CONTENT_APPROVED (
   p_schedule_id    IN         NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
);

-------------------------------------------------------------
-- Start of Comments
-- Name
-- GET_CATEGORY_SET_ID
--
-- Purpose
-- This function is used by web adi import apis
-------------------------------------------------------------
FUNCTION GET_CATEGORY_SET_ID
RETURN NUMBER;

-------------------------------------------------------------
-- Start of Comments
-- Name
-- GET_LEVEL_TYPE_CODE
--
-- Purpose
-- This function is used by web adi import apis
-------------------------------------------------------------
FUNCTION GET_LEVEL_TYPE_CODE( p_inv_id  IN  NUMBER
                          ,p_Cat_id  IN NUMBER)
RETURN VARCHAR2;


END AMS_ActProduct_PVT;

 

/
