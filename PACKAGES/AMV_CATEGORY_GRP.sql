--------------------------------------------------------
--  DDL for Package AMV_CATEGORY_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMV_CATEGORY_GRP" AUTHID CURRENT_USER AS
/* $Header: amvgcats.pls 120.1 2005/06/22 16:06:59 appldev ship $ */
--
-- NAME
--   AMV_CATEGORY_GRP
-- PURPOSE
--
-- HISTORY
--   12/07/1999        SLKRISHN        CREATED
--
--
G_ASC_ORDER     CONSTANT    VARCHAR2(5) := 'ASC';
G_DESC_ORDER    CONSTANT    VARCHAR2(5) := 'DESC';
--
--
-- This package contains the following procedures
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Add_Category
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Create (sub)category.
--    Parameters :
--    IN           p_api_version                      IN  NUMBER    Required
--                 p_init_msg_list                    IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--		   	    p_application_id		      IN  NUMBER    Required
--			  		application creating the category
--                 p_category_name                    IN  VARCHAR2  Required
--                      the channel category name. Have to be unique.
--                 p_description                      IN  VARCHAR2  Optional
--                      the channel (sub)category description.
--                 p_parent_category_id               IN  VARCHAR2  Required
--                 p_order                            IN  NUMBER    Optional
--                        Default = FND_API.G_MISS_NUM
--                      the order of this catgory among all the categories
--    OUT NOCOPY         : x_return_status                    OUT NOCOPY  VARCHAR2
--                 x_msg_count                        OUT NOCOPY  NUMBER
--                 x_msg_data                         OUT NOCOPY  VARCHAR2
--                 x_category_id                      OUT NOCOPY  NUMBER
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Add_Category
(     p_api_version             IN  NUMBER,
      p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status           OUT NOCOPY  VARCHAR2,
      x_msg_count               OUT NOCOPY  NUMBER,
      x_msg_data                OUT NOCOPY  VARCHAR2,
      p_check_login_user  	  IN  VARCHAR2 := FND_API.G_TRUE,
      p_application_id		  IN  NUMBER,
      p_category_name           IN  VARCHAR2,
      p_description          	  IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      p_parent_category_id      IN  NUMBER,
      p_order                   IN  NUMBER := FND_API.G_MISS_NUM,
      x_category_id          	  OUT NOCOPY  NUMBER
);
--
-- Algorithm:
--   BEGIN
--    ...
--   END
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Delete_Category
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Delete (sub)category given the p_category_id or
--				p_category_name along with p_parent_category_id.
--    Parameters :
--    IN           p_api_version                 IN  NUMBER    Required
--                 p_init_msg_list               IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                      IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level            IN   NUMBER        Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_category_id                 IN  NUMBER    Optional
--				  Default = FND_API.G_MISS_NUM
--                    channel (sub)category id.
--                 p_category_name               IN  VARCHAR2  Optional
--				  Default = FND_API.G_MISS_CHAR
--                    channel (sub)category name.
--                 p_parent_category_id          IN  NUMBER    Optional
--                    Default = FND_API.G_MISS_NUM
--				  parent id for (sub) category
--    OUT NOCOPY         : x_return_status                    OUT NOCOPY  VARCHAR2
--                 x_msg_count                        OUT NOCOPY  NUMBER
--                 x_msg_data                         OUT NOCOPY  VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Delete_Category
(     p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status         OUT NOCOPY  VARCHAR2,
      x_msg_count             OUT NOCOPY  NUMBER,
      x_msg_data              OUT NOCOPY  VARCHAR2,
      p_check_login_user  	IN  VARCHAR2 := FND_API.G_TRUE,
	 p_application_id		IN  NUMBER,
      p_category_id          	IN  NUMBER := FND_API.G_MISS_NUM,
      p_category_name        	IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      p_parent_category_id   	IN  NUMBER := FND_API.G_MISS_NUM
);
--
-- Algorithm:
--   BEGIN
--    ...
--   END
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Sort_Category
--    Type       : Private
--    Pre-reqs   : None
--    Function   : sort (sub)category list in ascending or descending order
--    Parameters :
--    IN           p_api_version                      IN  NUMBER    Required
--                 p_init_msg_list                    IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_sort_order                	      IN  VARCHAR2  Optional
--                        Default = AMV_CATEGORY_PVT.G_ASC_ORDER
--                      Ascending(ASC) or Descending(DESC) Order.
--                 p_parent_category_id               IN  NUMBER    Optional
--                        Default = FND_API.G_MISS_NUM
--                      	parent id for sub categories
--    OUT NOCOPY         : x_return_status                    OUT NOCOPY  VARCHAR2
--                 x_msg_count                        OUT NOCOPY  NUMBER
--                 x_msg_data                         OUT NOCOPY  VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Sort_Category
(     p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status         OUT NOCOPY  VARCHAR2,
      x_msg_count             OUT NOCOPY  NUMBER,
      x_msg_data              OUT NOCOPY  VARCHAR2,
      p_check_login_user  	IN  VARCHAR2 := FND_API.G_TRUE,
	 p_application_id		IN  NUMBER,
      p_sort_order         	IN  VARCHAR2 := AMV_CATEGORY_PVT.G_ASC_ORDER,
      p_parent_category_id	IN  NUMBER := FND_API.G_MISS_NUM
);
--
-- Algorithm:
--   BEGIN
--    ...
--   END
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Reorder_Category
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Reorder (sub)category list
--    Parameters :
--    IN           p_api_version                      IN  NUMBER    Required
--                 p_init_msg_list                    IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER        Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_category_id_array                IN  AMV_NUMBER_VARRAY_TYPE
--                                                                  Required
--                 p_category_new_order               IN  AMV_NUMBER_VARRAY_TYPE
--                                                                  Required
--    OUT NOCOPY         : x_return_status                    OUT NOCOPY  VARCHAR2
--                 x_msg_count                        OUT NOCOPY  NUMBER
--                 x_msg_data                         OUT NOCOPY  VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Reorder_Category
(     p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level     	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status         OUT NOCOPY  VARCHAR2,
      x_msg_count             OUT NOCOPY  NUMBER,
      x_msg_data              OUT NOCOPY  VARCHAR2,
      p_check_login_user  	IN  VARCHAR2 := FND_API.G_TRUE,
	 p_application_id		IN  NUMBER,
      p_category_id_array    	IN  AMV_CATEGORY_PVT.AMV_NUMBER_VARRAY_TYPE,
      p_category_new_order    IN  AMV_CATEGORY_PVT.AMV_NUMBER_VARRAY_TYPE
);
--
-- Algorithm:
--   BEGIN
--    ...
--   END
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Update_Category
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Update (sub)category given (sub)category id or name
--    Parameters :
--    IN           p_api_version                      IN  NUMBER    Required
--                 p_init_msg_list                    IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--		   	    p_object_version_number	         IN  NUMBER    Required
--					object version number
--                 p_category_id                      IN  NUMBER    Required
--                    channel category id.
--                 p_category_name                    IN  VARCHAR2  Optional
--                    channel category name.
--                      (sub)category id or name is required
--                 p_parent_category_id               IN  NUMBER    Optional
--			  		Default = FND_API.G_MISS_NUM
--                    	channel category id.
--		   	    p_category_order		         IN  NUMBER  Optional
--		      		new channel category order
--                 p_category_new_name                IN  VARCHAR2  Optional
--                    new channel category name. New name has to be unique
--                 p_description                      IN  VARCHAR2  Optional
--                        Default = FND_API.G_MISS_CHAR
--                    channel category description.
--    OUT NOCOPY         : x_return_status                    OUT NOCOPY  VARCHAR2
--                 x_msg_count                        OUT NOCOPY  NUMBER
--                 x_msg_data                         OUT NOCOPY  VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Update_Category
(     p_api_version          	IN  NUMBER,
      p_init_msg_list        	IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit               	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level     	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status        	OUT NOCOPY  VARCHAR2,
      x_msg_count            	OUT NOCOPY  NUMBER,
      x_msg_data             	OUT NOCOPY  VARCHAR2,
      p_check_login_user  	IN  VARCHAR2 := FND_API.G_TRUE,
      p_object_version_number   IN  NUMBER,
	 p_application_id		IN  NUMBER,
      p_category_id          	IN  NUMBER := FND_API.G_MISS_NUM,
      p_category_name 	     	IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      p_parent_category_id   	IN  NUMBER := FND_API.G_MISS_NUM,
      p_category_order		IN  NUMBER := FND_API.G_MISS_NUM,
      p_category_new_name    	IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      p_description 	     	IN  VARCHAR2 := FND_API.G_MISS_CHAR
);
--
-- Algorithm:
--   BEGIN
--    ...
--   END
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Find_Categories
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Search and return (sub)categories
--    Parameters :
--    IN           p_api_version                      IN  NUMBER    Required
--                 p_init_msg_list                    IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER        Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--           	    p_application_id            IN  NUMBER    Required
--               		application creating the channel
--                 p_category_name                 IN  VARCHAR2  Optional
--                    Search criteria by name. Default = '%' (everything)
--                 p_parent_category_id IN NUMBER    Optional
--                      Default = FND_API.G_MISS_NUM
--                    parent id for sub categories
--    OUT NOCOPY         : x_return_status      OUT NOCOPY  VARCHAR2
--                 x_msg_count          OUT NOCOPY  NUMBER
--                 x_msg_data           OUT NOCOPY  VARCHAR2
--                 x_chan_category_rec_array OUT NOCOPY  AMV_CATEGORY_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Find_Categories
(     p_api_version             	IN  NUMBER,
      p_init_msg_list           	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level       	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status           	OUT NOCOPY  VARCHAR2,
      x_msg_count               	OUT NOCOPY  NUMBER,
      x_msg_data                	OUT NOCOPY  VARCHAR2,
      p_check_login_user  		IN  VARCHAR2 := FND_API.G_TRUE,
      p_application_id          	IN  NUMBER,
      p_category_name           	IN  VARCHAR2 := '%',
      p_parent_category_id		IN  NUMBER := FND_API.G_MISS_NUM,
      p_ignore_hierarchy           IN  VARCHAR2 := FND_API.G_FALSE,
      p_request_obj             	IN  AMV_CATEGORY_PVT.AMV_REQUEST_OBJ_TYPE,
	 x_return_obj              	OUT NOCOPY  AMV_CATEGORY_PVT.AMV_RETURN_OBJ_TYPE,
      x_chan_category_rec_array 	OUT NOCOPY  AMV_CATEGORY_PVT.AMV_CATEGORY_VARRAY_TYPE
);
--
-- Algorithm:
--   BEGIN
--    ...
--   END
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_ChannelsPerCategory
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Return all channels under a (sub)category
--    Parameters :
--    IN           p_api_version                 IN  NUMBER    Required
--                 p_init_msg_list               IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level            IN  NUMBER        Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_category_id                 IN  NUMBER    Required
--			    p_include_subcats		    IN  VARCHAR2  Optional
--					Default = FND_API.G_FALSE
--    OUT        : x_return_status               OUT VARCHAR2
--                 x_msg_count                   OUT NUMBER
--                 x_msg_data                    OUT VARCHAR2
--                 x_content_chan_array      OUT AMV_CAT_HIERARCHY_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_ChannelsPerCategory
(     p_api_version          	IN  NUMBER,
      p_init_msg_list       	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level   	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status        	OUT NOCOPY  VARCHAR2,
      x_msg_count            	OUT NOCOPY  NUMBER,
      x_msg_data             	OUT NOCOPY  VARCHAR2,
      p_check_login_user  	IN  VARCHAR2 := FND_API.G_TRUE,
      p_category_id      	IN  NUMBER,
	 p_include_subcats		IN  VARCHAR2 := FND_API.G_FALSE,
      x_content_chan_array    OUT NOCOPY  AMV_CATEGORY_PVT.AMV_CAT_HIERARCHY_VARRAY_TYPE
);
--
-- Algorithm:
--   BEGIN
--    ...
--   END
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Fetch_CategoryId
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Return category id for a category or subcategory name.
--    Parameters :
--    IN           p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level           IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_category_name              IN  VARCHAR2  Required
--                      (sub)category id
--                 p_parent_category_id         IN  NUMBER    Optional
--                      Default = FND_API.G_MISS_NUM
--                      parent category id
--    OUT        : x_return_status              OUT VARCHAR2
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2
--                 x_category_id                OUT NUMBER
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
--
PROCEDURE Fetch_CategoryId
(     p_api_version          	IN  NUMBER,
      p_init_msg_list        	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level   	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status        	OUT NOCOPY  VARCHAR2,
      x_msg_count            	OUT NOCOPY  NUMBER,
      x_msg_data             	OUT NOCOPY  VARCHAR2,
      p_check_login_user  	IN  VARCHAR2 := FND_API.G_TRUE,
	 p_application_id		IN  NUMBER,
      p_category_name         IN  VARCHAR2,
      p_parent_category_id    IN  NUMBER := FND_API.G_MISS_NUM,
      x_category_id			OUT NOCOPY  NUMBER
);
-- Algorithm:
--   BEGIN
--    ...
--   END
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Get_CatParentsHierarchy
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Return parents hierarchy of category name and ids
--			for a category id.
--    Parameters :
--    IN           p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level           IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_category_id                IN  NUMBER  Required
--                      (sub)category id
--    OUT        : x_return_status          OUT VARCHAR2
--                 x_msg_count              OUT NUMBER
--                 x_msg_data               OUT VARCHAR2
--                 x_category_hierarchy     OUT AMV_CAT_HIERARCHY_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
--
PROCEDURE Get_CatParentsHierarchy
(     p_api_version          	IN  NUMBER,
      p_init_msg_list        	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level   	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status        	OUT NOCOPY  VARCHAR2,
      x_msg_count            	OUT NOCOPY  NUMBER,
      x_msg_data             	OUT NOCOPY  VARCHAR2,
      p_check_login_user  	IN  VARCHAR2 := FND_API.G_TRUE,
      p_category_id			IN  NUMBER,
      x_category_hierarchy    OUT NOCOPY  AMV_CATEGORY_PVT.AMV_CAT_HIERARCHY_VARRAY_TYPE
);
-- Algorithm:
--   BEGIN
--    ...
--   END
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Get_CatChildrenHierarchy
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Return children hierarchy of category name and ids
--			for a category id.
--    Parameters :
--    IN           p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level           IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_category_id                IN  NUMBER  Required
--                      (sub)category id
--    OUT        : x_return_status          OUT VARCHAR2
--                 x_msg_count              OUT NUMBER
--                 x_msg_data               OUT VARCHAR2
--                 x_category_hierarchy     OUT AMV_CAT_HIERARCHY_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
--
PROCEDURE Get_CatChildrenHierarchy
(     p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level   	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status         OUT NOCOPY  VARCHAR2,
      x_msg_count             OUT NOCOPY  NUMBER,
      x_msg_data              OUT NOCOPY  VARCHAR2,
      p_check_login_user  	IN  VARCHAR2 := FND_API.G_TRUE,
      p_category_id			IN  NUMBER,
      x_category_hierarchy    OUT NOCOPY  AMV_CATEGORY_PVT.AMV_CAT_HIERARCHY_VARRAY_TYPE
);
-- Algorithm:
--   BEGIN
--    ...
--   END
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Get_ChnCategoryHierarchy
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Return parents hierarchy of category name and ids
--			for a channel id.
--    Parameters :
--    IN           p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level           IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_channel_id                IN  NUMBER  Required
--                      channel id
--    OUT        : x_return_status          OUT VARCHAR2
--                 x_msg_count              OUT NUMBER
--                 x_msg_data               OUT VARCHAR2
--			    x_channel_name		    OUT VARCHAR2
--                 x_category_hierarchy     OUT AMV_CAT_HIERARCHY_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
--
PROCEDURE Get_ChnCategoryHierarchy
(     p_api_version          	IN  NUMBER,
      p_init_msg_list        	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level   	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status        	OUT NOCOPY  VARCHAR2,
      x_msg_count            	OUT NOCOPY  NUMBER,
      x_msg_data             	OUT NOCOPY  VARCHAR2,
      p_check_login_user  	IN  VARCHAR2 := FND_API.G_TRUE,
      p_channel_id			IN  NUMBER,
	 x_channel_name		OUT NOCOPY  VARCHAR2,
      x_category_hierarchy    OUT NOCOPY  AMV_CATEGORY_PVT.AMV_CAT_HIERARCHY_VARRAY_TYPE
);
-- Algorithm:
--   BEGIN
--    ...
--   END
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_ItemsPerCategory
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Return all items directly under
--                 a content channel (sub)category
--    Parameters :
--    IN           p_api_version                 IN  NUMBER    Required
--                 p_init_msg_list               IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level            IN  NUMBER        Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_category_id                 IN  NUMBER    Required
--			    p_include_subcats		    IN  VARCHAR2  Optional
--					Default = FND_API.G_FALSE
--    OUT        : x_return_status               OUT VARCHAR2
--                 x_msg_count                   OUT NUMBER
--                 x_msg_data                    OUT VARCHAR2
--                 x_items_array      	 	OUT AMV_CAT_HIERARCHY_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_ItemsPerCategory
(     p_api_version          	IN  NUMBER,
      p_init_msg_list       	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level   	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status        	OUT NOCOPY  VARCHAR2,
      x_msg_count            	OUT NOCOPY  NUMBER,
      x_msg_data             	OUT NOCOPY  VARCHAR2,
      p_check_login_user  	IN  VARCHAR2 := FND_API.G_TRUE,
      p_category_id      	IN  NUMBER,
	 p_include_subcats		IN  VARCHAR2 := FND_API.G_FALSE,
      p_request_obj           IN  AMV_CATEGORY_PVT.AMV_REQUEST_OBJ_TYPE,
      p_category_sort      	IN  AMV_CATEGORY_PVT.AMV_SORT_OBJ_TYPE,
	 x_return_obj            OUT NOCOPY  AMV_CATEGORY_PVT.AMV_RETURN_OBJ_TYPE,
      x_items_array    		OUT NOCOPY  AMV_CATEGORY_PVT.AMV_CAT_HIERARCHY_VARRAY_TYPE
);
--
-- Algorithm:
--   BEGIN
--    ...
--   END
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Add_CategoryParent
--    Type       : Private
--    Pre-reqs   : None
--    Function   : attaches a category to a parent category
--    Parameters :
--    IN           p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level           IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_category_id                IN  NUMBER  Required
--                      category id
--			    p_parent_category_id		   IN  NUMBER Required
--				    parent category id
--			    p_replace_existing		   IN VARCHAR2 Optional
--					Default =	FND_API.G_FALSE
--    OUT        : x_return_status          OUT VARCHAR2
--                 x_msg_count              OUT NUMBER
--                 x_msg_data               OUT VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
--
PROCEDURE Add_CategoryParent
(     p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit               	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level   	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status         OUT NOCOPY  VARCHAR2,
      x_msg_count             OUT NOCOPY  NUMBER,
      x_msg_data              OUT NOCOPY  VARCHAR2,
      p_check_login_user  	IN  VARCHAR2 := FND_API.G_TRUE,
      p_object_version_number IN  NUMBER,
      p_category_id			IN  NUMBER,
	 p_parent_category_id	IN  NUMBER,
	 p_replace_existing		IN  VARCHAR2 := FND_API.G_FALSE
);
-- Algorithm:
--   BEGIN
--    ...
--   END
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Remove_CategoryParent
--    Type       : Private
--    Pre-reqs   : None
--    Function   : removes a category from a parent category
--    Parameters :
--    IN           p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level           IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_category_id                IN  NUMBER  Required
--                      category id
--    OUT        : x_return_status          OUT VARCHAR2
--                 x_msg_count              OUT NUMBER
--                 x_msg_data               OUT VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
--
PROCEDURE Remove_CategoryParent
(     p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit               	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level   	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status         OUT NOCOPY  VARCHAR2,
      x_msg_count             OUT NOCOPY  NUMBER,
      x_msg_data              OUT NOCOPY  VARCHAR2,
      p_check_login_user  	IN  VARCHAR2 := FND_API.G_TRUE,
      p_object_version_number IN  NUMBER,
      p_category_id			IN  NUMBER
);
-- Algorithm:
--   BEGIN
--    ...
--   END
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
END amv_category_grp;

 

/
