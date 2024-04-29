--------------------------------------------------------
--  DDL for Package INV_ITEM_CATEGORY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_ITEM_CATEGORY_PVT" AUTHID CURRENT_USER AS
/* $Header: INVVCATS.pls 120.0 2005/05/25 06:27:54 appldev noship $ */


----------------------- Global variables and constants -----------------------

g_MISS_CHAR    CONSTANT  VARCHAR2(1)  :=  fnd_api.g_MISS_CHAR;
g_MISS_NUM     CONSTANT  NUMBER       :=  fnd_api.g_MISS_NUM;
g_MISS_DATE    CONSTANT  DATE         :=  fnd_api.g_MISS_DATE;
g_YES          CONSTANT  VARCHAR2(1)  :=  'Y';
g_NO           CONSTANT  VARCHAR2(1)  :=  'N';

-- Validation level

g_VALIDATE_NONE     CONSTANT  NUMBER  :=  0;
g_VALIDATE_RULES    CONSTANT  NUMBER  :=  10;
g_VALIDATE_IDS      CONSTANT  NUMBER  :=  20;
g_VALIDATE_VALUES   CONSTANT  NUMBER  :=  30;
g_VALIDATE_ALL      CONSTANT  NUMBER  :=  100;


--------------------------------- Exceptions ---------------------------------
/*
Numeric_Or_Value_Error    EXCEPTION;
PRAGMA exception_init (Numeric_Or_Value_Error, -6502);
*/


-------------------------- Global type declarations --------------------------

--, p_IPD_Item_tbl  IN  INV_Item_Types.IPD_Item_tbl_type

------------------------------------------------------------------------------


------------------------- Create_Category_Assignment -------------------------

PROCEDURE Create_Category_Assignment
(
   p_api_version        IN   NUMBER
,  p_init_msg_list      IN   VARCHAR2  DEFAULT  fnd_api.g_FALSE
,  p_commit             IN   VARCHAR2  DEFAULT  fnd_api.g_FALSE
,  p_validation_level   IN   NUMBER    DEFAULT  INV_ITEM_CATEGORY_PVT.g_VALIDATE_ALL
,  p_inventory_item_id  IN   NUMBER
,  p_organization_id    IN   NUMBER
,  p_category_set_id    IN   NUMBER
,  p_category_id        IN   NUMBER
,  p_transaction_id     IN   NUMBER    DEFAULT  -9999
,  p_request_id         IN   NUMBER    DEFAULT  NULL
,  x_return_status      OUT  NOCOPY VARCHAR2
,  x_msg_count          OUT  NOCOPY NUMBER
,  x_msg_data           OUT  NOCOPY VARCHAR2
);


------------------------- Delete_Category_Assignment -------------------------

PROCEDURE Delete_Category_Assignment
(
   p_api_version       IN   NUMBER
,  p_init_msg_list     IN   VARCHAR2  DEFAULT  fnd_api.g_FALSE
,  p_commit            IN   VARCHAR2  DEFAULT  fnd_api.g_FALSE
,  p_inventory_item_id IN   NUMBER
,  p_organization_id   IN   NUMBER
,  p_category_set_id   IN   NUMBER
,  p_category_id       IN   NUMBER
,  p_transaction_id    IN   NUMBER    DEFAULT  -9999
,  x_return_status     OUT  NOCOPY VARCHAR2
,  x_msg_count         OUT  NOCOPY NUMBER
,  x_msg_data          OUT  NOCOPY VARCHAR2
);


  -- API to create a valid Category in Category Sets
  -----------------------------------------------------------------------------
  PROCEDURE Create_Valid_Category(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_category_set_id     IN  NUMBER,
    p_category_id         IN  NUMBER,
    p_parent_category_id  IN  NUMBER,
    x_return_status       OUT  NOCOPY VARCHAR2,
    x_errorcode           OUT  NOCOPY NUMBER,
    x_msg_count           OUT  NOCOPY NUMBER,
    x_msg_data            OUT  NOCOPY VARCHAR2
  );
    -- Start OF comments
    -- API name  : Create_Valid_Category
    -- TYPE      : Private and USed by ENI Upgrade program alone
    -- Pre-reqs  : 11.5.10 level
    -- FUNCTION  : Create a record in mtl_category_set_valid_cats.
    --             This sets the PUB API package level variable
    --             and calls the corresponding PUB API procedure.
    --             This will NOT do validations for ENABLED_FLAG and DISABLE_DATE
    --
    -- Parameters:
    --     IN    : p_api_version         IN  NUMBER (required)
    --             API Version of this procedure
    --
    --             p_init_msg_level      IN  VARCHAR2 (optional)
    --                                       DEFAULT = FND_API.G_FALSE,
    --
    --             p_commit              IN  VARCHAR2 (optional)
    --                                       DEFAULT = FND_API.G_FALSE,
    --
    --             p_category_set_id     IN  NUMBER (required)
    --                                       category_set_id
    --
    --             p_category_id         IN  NUMBER (required)
    --                                       category_id
    --
    --             p_parent_category_id  IN  NUMBER (required)
    --                                       parent of current category id
    --
    --     OUT  :  x_msg_count        OUT NUMBER,
    --             number of messages in the message list
    --
    --             x_msg_data         OUT VARCHAR2,
    --             if number of messages is 1, then this parameter
    --             contains the message itself
    --
    --             X_return_status    OUT NUMBER
    --             Result of all the operations
    --                   FND_API.G_RET_STS_SUCCESS if success
    --                   FND_API.G_RET_STS_ERROR if error
    --                   FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
    --
    --             X_ErrorCode        OUT NUMBER
    --                RETURN value OF the x_errorcode
    --                check only if x_return_status <> fnd_api.g_ret_sts_success
    --                These errors are unrecoverable and the API failed as a result of this
    --                XXX - Error reason/message (will be updated after implementation)
    --                -1  - unexpected error - all operations have been rollbacked
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
  -----------------------------------------------------------------------------

  --  Update Valid Category
  -- API to update a valid Category in Category Sets
  -----------------------------------------------------------------------------
  PROCEDURE Update_Valid_Category(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_category_set_id     IN  NUMBER,
    p_category_id         IN  NUMBER,
    p_parent_category_id  IN  NUMBER,
    x_return_status       OUT  NOCOPY VARCHAR2,
    x_errorcode           OUT  NOCOPY NUMBER,
    x_msg_count           OUT  NOCOPY NUMBER,
    x_msg_data            OUT  NOCOPY VARCHAR2
  );
    -- Start OF comments
    -- API name  : Update_Valid_Category
    -- TYPE      : Private and USed by ENI Upgrade program alone
    -- Pre-reqs  : 11.5.10 level
    -- FUNCTION  : Update a record in mtl_category_set_valid_cats.
    --             This sets the PUB API package level variable
    --             and calls the corresponding PUB API procedure.
    --             This will NOT do validations for ENABLED_FLAG and DISABLE_DATE
    --
    -- Parameters:
    --     IN    : p_api_version         IN  NUMBER (required)
    --             API Version of this procedure
    --
    --             p_init_msg_level      IN  VARCHAR2 (optional)
    --                                       DEFAULT = FND_API.G_FALSE,
    --
    --             p_commit              IN  VARCHAR2 (optional)
    --                                       DEFAULT = FND_API.G_FALSE,
    --
    --             p_category_set_id     IN  NUMBER (required)
    --                                       category_set_id
    --
    --             p_category_id         IN  NUMBER (required)
    --                                       category_id
    --
    --             p_parent_category_id  IN  NUMBER (required)
    --                                       parent of current category id
    --     OUT  :  x_msg_count        OUT NUMBER,
    --             number of messages in the message list
    --
    --             x_msg_data         OUT VARCHAR2,
    --             if number of messages is 1, then this parameter
    --             contains the message itself
    --
    --             X_return_status    OUT NUMBER
    --             Result of all the operations
    --                   FND_API.G_RET_STS_SUCCESS if success
    --                   FND_API.G_RET_STS_ERROR if error
    --                   FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
    --
    --             X_ErrorCode        OUT NUMBER
    --                RETURN value OF the x_errorcode
    --                check only if x_return_status <> fnd_api.g_ret_sts_success
    --                These errors are unrecoverable and the API failed as a result of this
    --                XXX - Error reason/message (will be updated after implementation)
    --                -1  - unexpected error - all operations have been rollbacked
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
  -----------------------------------------------------------------------------

  --* Added for Bug #3991044
  ------------------------- Update_Category_Assignment -------------------------

  PROCEDURE Update_Category_Assignment
  (
     p_api_version       IN   NUMBER
  ,  p_init_msg_list     IN   VARCHAR2  DEFAULT  fnd_api.g_FALSE
  ,  p_commit            IN   VARCHAR2  DEFAULT  fnd_api.g_FALSE
  ,  p_inventory_item_id IN   NUMBER
  ,  p_organization_id   IN   NUMBER
  ,  p_category_set_id   IN   NUMBER
  ,  p_category_id       IN   NUMBER
  ,  p_old_category_id   IN   NUMBER
  ,  p_transaction_id    IN   NUMBER    DEFAULT  -9999
  ,  x_return_status     OUT  NOCOPY    VARCHAR2
  ,  x_msg_count         OUT  NOCOPY    NUMBER
  ,  x_msg_data          OUT  NOCOPY    VARCHAR2
  );
  --* End of Bug #3991044

END INV_ITEM_CATEGORY_PVT;

 

/
