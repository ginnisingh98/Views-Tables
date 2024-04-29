--------------------------------------------------------
--  DDL for Package AMS_ITEM_CATEGORY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ITEM_CATEGORY_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvicas.pls 115.4 2002/11/11 22:06:15 abhola ship $ */

--------------------------------------------------------------
-- PROCEDURE
--    Create_Category_Assignment
--
--------------------------------------------------------------
  PROCEDURE Create_Category_Assignment
  (
    p_api_version       IN   NUMBER,
    p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_errorcode         OUT NOCOPY  NUMBER,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_category_id       IN   NUMBER,
    p_category_set_id   IN   NUMBER,
    p_inventory_item_id IN   NUMBER,
    p_organization_id   IN   NUMBER
   );

-- Start OF comments
    -- API name  : Create_Category_Assignment
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Create an item category assignment.
    --             If this operation fails then the item-category assignment
    --             is not created and error code is returned.
    --
    -- Parameters:
    --     IN    : p_api_version      IN  NUMBER (required)
    --             API Version of this procedure
    --
    --             p_init_msg_level   IN  VARCHAR2 (optional)
    --                                    DEFAULT = FND_API.G_FALSE,
    --
    --             p_commit           IN  VARCHAR2 (optional)
    --                                    DEFAULT = FND_API.G_FALSE,
    --
    --             p_category_id      IN  NUMBER (required)
    --             category for assigning item
    --
    --             p_category_set_id  IN  NUMBER (required)
    --             category set for assignment. An item can be assigned to
    --             only one category within a category set.
    --
    --             p_inventory_item_id IN  NUMBER (required)
    --             id of inventory item (item key)
    --
    --             p_organization_id  IN  NUMBER (required)
    --             id of item organization  (item key)

    --     OUT  :  x_msg_count        OUT NUMBER,
    --             number of messages in the message list
 --             x_msg_data         OUT VARCHAR2,
    --             if number of messages is 1, then this parameter
    --             contains the message itself
    --
    --             X_return_status    OUT NUMBER
    --             Result of all the operations
    --                   FND_API.G_RET_STS_SUCCESS if success
    --                   FND_API.G_RET_STS_ERROR if error
    --                FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
    --
    --             X_ErrorCode        OUT NUMBER
    --                RETURN value OF the x_errorcode
    --                check only if x_return_status <> fnd_api.g_ret_sts_success
    --                These errors are unrecoverable and the API failed as a result of this
    --                XXX - Error reason/message (will be updated after implementation)
    --                -1  - unexpected error - all operations have been rollbacked
    --
    --
    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
  ----------------------------------------------------------------------------
  -- Delete_Category_Assignment
  ----------------------------------------------------------------------------
  PROCEDURE Delete_Category_Assignment
  (
    p_api_version       IN   NUMBER,
    p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_errorcode         OUT NOCOPY  NUMBER,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_category_id       IN   NUMBER,
    p_category_set_id   IN   NUMBER,
    p_inventory_item_id IN   NUMBER,
    p_organization_id   IN   NUMBER
   );
    -- Start OF comments
    -- API name  : Delete_Category_Assignment
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Delete an item category assignment.
    --             If this operation fails then the category is not
    --             deleted and error code is returned.
    --
    -- Parameters:
    --     IN    : p_api_version      IN  NUMBER (required)
    --             API Version of this procedure
    --
    --             p_init_msg_level   IN  VARCHAR2 (optional)
    --                                    DEFAULT = FND_API.G_FALSE,
    --
    --             p_commit           IN  VARCHAR2 (optional)
    --                                    DEFAULT = FND_API.G_FALSE,
    --
    --             p_category_id      IN  NUMBER (required)
    --             category of the assginement
    --
    --             p_category_set_id  IN  NUMBER (required)
    --             category set of the assignment.
    --
    --             p_inventory_item_id IN  NUMBER (required)
 --             p_organization_id  IN  NUMBER (required)
    --             item organization of the assigned item (item key)

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
    --                FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
    --
    --             X_ErrorCode        OUT NUMBER
    --                RETURN value OF the x_errorcode
    --                check only if x_return_status <> fnd_api.g_ret_sts_success
    --                These errors are unrecoverable and the API failed as a result of this
    --                XXX - Error reason/message (will be updated after implementation)
    --                -1  - unexpected error - all operations have been rollbacked
    --
    --
    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments

    END AMS_ITEM_CATEGORY_PVT;   -- Package spec

 

/
