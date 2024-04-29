--------------------------------------------------------
--  DDL for Package AMV_CATEGORY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMV_CATEGORY_PVT" AUTHID CURRENT_USER AS
/* $Header: amvvcats.pls 115.15 2003/01/29 16:43:51 kelangov ship $ */
--
-- NAME
--   AMV_CATEGORY_PVT
-- PURPOSE
--
-- HISTORY
--   07/19/1999        SLKRISHN        CREATED
--
--
G_ASC_ORDER     CONSTANT    VARCHAR2(5) := 'ASC';
G_DESC_ORDER    CONSTANT    VARCHAR2(5) := 'DESC';
--
--
-- This package contains the following procedures
--

TYPE AMV_CHAR_VARRAY_TYPE IS TABLE OF VARCHAR2(4000);
	--INDEX BY BINARY_INTEGER;

TYPE AMV_NUMBER_VARRAY_TYPE IS TABLE OF NUMBER;
	--INDEX BY BINARY_INTEGER;

TYPE amv_return_obj_type IS RECORD(
      returned_record_count           NUMBER,
      next_record_position            NUMBER,
      total_record_count              NUMBER
);

TYPE amv_request_obj_type IS RECORD(
      records_requested               NUMBER,
      start_record_position           NUMBER,
      return_total_count_flag         VARCHAR2(1)
);

TYPE AMV_CATEGORY_OBJ_TYPE IS RECORD(
   category_id       		NUMBER,
   object_version_number 	NUMBER,
   parent_category_id 		NUMBER,
   category_order    		NUMBER,
   channel_count    	 	NUMBER,
   category_name     		VARCHAR2(80),
   description       		VARCHAR2(2000),
   count					NUMBER
);

TYPE AMV_CATEGORY_VARRAY_TYPE IS TABLE OF AMV_CATEGORY_OBJ_TYPE;
	--INDEX BY BINARY_INTEGER;

TYPE amv_cat_hierarchy_obj_type IS RECORD(
   hierarchy_level 	 number,
   id			 number,
   name			 varchar2(240)
);

TYPE AMV_SORT_OBJ_TYPE IS RECORD(
   sort_col	 varchar2(80),
   sort_dir	 varchar2(80)
);

TYPE amv_cat_hierarchy_varray_type IS TABLE of amv_cat_hierarchy_obj_type;
	--INDEX BY BINARY_INTEGER;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Add_Category
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Create channel (sub)category.
--    Parameters :
--    IN           p_api_version                      IN  NUMBER    Required
--                 p_init_msg_list                    IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--		   p_application_id		      IN  NUMBER    Optional
--			  Default = AMV_UTILITY_PVT.G_AMV_APP_ID (520)
--			  application creating the channel
--                 p_category_name                    IN  VARCHAR2  Required
--                      the channel category name. Have to be unique.
--                 p_description                      IN  VARCHAR2  Optional
--                      the channel (sub)category description.
--                 p_parent_category_id               IN  VARCHAR2  Optional
--                        Default = FND_API.G_MISS_NUM
--                 p_parent_category_name             IN  VARCHAR2  Optional
--                        Default = FND_API.G_MISS_CHAR
--                    parent id or name required for creating sub categories.
--                 p_order                            IN  NUMBER    Optional
--                        Default = FND_API.G_MISS_NUM
--                      the order of this catgory among all the categories
--    OUT        : x_return_status                    OUT VARCHAR2
--                 x_msg_count                        OUT NUMBER
--                 x_msg_data                         OUT VARCHAR2
--                 x_category_id                      OUT NUMBER
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
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2,
      p_check_login_user  	  IN  VARCHAR2 := FND_API.G_TRUE,
      p_application_id		  IN  NUMBER := AMV_UTILITY_PVT.G_AMV_APP_ID,
      p_category_name           IN  VARCHAR2,
      p_description          	  IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      p_parent_category_id      IN  NUMBER := FND_API.G_MISS_NUM,
      p_parent_category_name    IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      p_order                   IN  NUMBER := FND_API.G_MISS_NUM,
      x_category_id          	  OUT NOCOPY NUMBER
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
--    Function   : Delete channel (sub)category given the
--                 p_category_id(preferred) or p_category_name.
--    Parameters :
--    IN           p_api_version                 IN  NUMBER    Required
--                 p_init_msg_list               IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                      IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level            IN   NUMBER        Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_category_id                 IN  NUMBER    Optional
--			Default = FND_API.G_MISS_NUM
--                    channel (sub)category id.
--                 p_category_name               IN  VARCHAR2  Optional
--			Default = FND_API.G_MISS_CHAR
--                    channel (sub)category name.
--                 p_parent_category_id          IN  NUMBER    Optional
--                        Default = FND_API.G_MISS_NUM
--                 p_parent_category_name        IN  VARCHAR2  Optional
--                        Default = FND_API.G_MISS_CHAR
--                    Either pass the channe (sub)category id (preferred)
--                    or channel (sub)category name
--                    to identify the channel (sub)category.
--    OUT        : x_return_status                    OUT VARCHAR2
--                 x_msg_count                        OUT NUMBER
--                 x_msg_data                         OUT VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Delete_Category
(     p_api_version             IN  NUMBER,
      p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2,
      p_check_login_user  	IN  VARCHAR2 := FND_API.G_TRUE,
      p_application_id		  IN  NUMBER := AMV_UTILITY_PVT.G_AMV_APP_ID,
      p_category_id          	IN  NUMBER := FND_API.G_MISS_NUM,
      p_category_name        	IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      p_parent_category_id      IN  NUMBER := FND_API.G_MISS_NUM,
      p_parent_category_name    IN  VARCHAR2 := FND_API.G_MISS_CHAR
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
--                      parent id for sub categories
--                 p_parent_category_name             IN  VARCHAR2  Optional
--                        Default = FND_API.G_MISS_CHAR
--                      category name for sub categories
--                      category name or parent category id should be
--                      supplied for sorting sub categories
--    OUT        : x_return_status                    OUT VARCHAR2
--                 x_msg_count                        OUT NUMBER
--                 x_msg_data                         OUT VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Sort_Category
(     p_api_version             IN  NUMBER,
      p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2,
      p_check_login_user  	IN  VARCHAR2 := FND_API.G_TRUE,
      p_application_id		  IN  NUMBER := AMV_UTILITY_PVT.G_AMV_APP_ID,
      p_sort_order         	IN  VARCHAR2 := AMV_CATEGORY_PVT.G_ASC_ORDER,
      p_parent_category_id	IN  NUMBER := FND_API.G_MISS_NUM,
      p_parent_category_name    IN  VARCHAR2 := FND_API.G_MISS_CHAR
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
--    Function   : Reorder channel (sub)category list
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
--    OUT        : x_return_status                    OUT VARCHAR2
--                 x_msg_count                        OUT NUMBER
--                 x_msg_data                         OUT VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Reorder_Category
(     p_api_version             IN  NUMBER,
      p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2,
      p_check_login_user  	IN  VARCHAR2 := FND_API.G_TRUE,
      p_application_id		  IN  NUMBER := AMV_UTILITY_PVT.G_AMV_APP_ID,
      p_category_id_array       IN  AMV_NUMBER_VARRAY_TYPE,
      p_category_new_order      IN  AMV_NUMBER_VARRAY_TYPE
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
--    Function   : Update channel (sub)category given (sub)category id or name
--    Parameters :
--    IN           p_api_version                      IN  NUMBER    Required
--                 p_init_msg_list                    IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--		   p_object_version_number	      IN  NUMBER    Required
--			object version number
--                 p_category_id                      IN  NUMBER    Required
--                    channel category id.
--                 p_category_name                    IN  VARCHAR2  Optional
--                    channel category name.
--                      (sub)category id or name is required
--                 p_parent_category_id               IN  NUMBER    Optional
--			  Default = FND_API.G_MISS_NUM
--                    channel category id.
--                 p_parent_category_name             IN  VARCHAR2  Optional
--                        Default = FND_API.G_MISS_CHAR
--                    channel category name.
--                    takes either parent id or name. id taken if both passed
--		   p_category_order		      IN  NUMBER  Optional
--		      new channel category order
--                 p_category_new_name                IN  VARCHAR2  Optional
--                    new channel category name. New name has to be unique
--                 p_description                      IN  VARCHAR2  Optional
--                        Default = FND_API.G_MISS_CHAR
--                    channel category description.
--    OUT        : x_return_status                    OUT VARCHAR2
--                 x_msg_count                        OUT NUMBER
--                 x_msg_data                         OUT VARCHAR2
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
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,
      p_check_login_user  	IN  VARCHAR2 := FND_API.G_TRUE,
      p_object_version_number   IN  NUMBER,
      p_application_id		  IN  NUMBER := AMV_UTILITY_PVT.G_AMV_APP_ID,
      p_category_id          	IN  NUMBER := FND_API.G_MISS_NUM,
      p_category_name 	     	IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      p_parent_category_id   	IN  NUMBER := FND_API.G_MISS_NUM,
      p_parent_category_name 	IN  VARCHAR2 := FND_API.G_MISS_CHAR,
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
--    Function   : Search and return channel (sub)categories
--    Parameters :
--    IN           p_api_version                      IN  NUMBER    Required
--                 p_init_msg_list                    IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER        Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--           	    p_application_id            IN  NUMBER    Optional
--               		Default = AMV_UTILITY_PVT.G_AMV_APP_ID (520)
--               		application creating the channel
--                 p_category_name                 IN  VARCHAR2  Optional
--                    Search criteria by name. Default = '%' (everything)
--                 p_parent_category_id IN NUMBER    Optional
--                      Default = FND_API.G_MISS_NUM
--                    parent id for sub categories
--                 p_parent_category_name IN VARCHAR2 Optional
--                      Default = FND_API.G_MISS_CHAR
--                    parent name for sub categories
--                    takes either parent id or name. id taken if both passed
--    OUT        : x_return_status      OUT VARCHAR2
--                 x_msg_count          OUT NUMBER
--                 x_msg_data           OUT VARCHAR2
--                 x_chan_category_rec_array OUT AMV_CATEGORY_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Find_Categories
(     p_api_version             IN  NUMBER,
      p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level       	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2,
      p_check_login_user  	IN  VARCHAR2 := FND_API.G_TRUE,
      p_application_id          IN  NUMBER := AMV_UTILITY_PVT.G_AMV_APP_ID,
      p_category_name           IN  VARCHAR2 := '%',
      p_parent_category_id	IN  NUMBER := FND_API.G_MISS_NUM,
      p_parent_category_name    IN  VARCHAR2 := FND_API.G_MISS_CHAR,
	 p_ignore_hierarchy		  IN  VARCHAR2 := FND_API.G_FALSE,
	 p_request_obj			  IN  AMV_REQUEST_OBJ_TYPE,
	 x_return_obj			  OUT NOCOPY AMV_RETURN_OBJ_TYPE,
      x_chan_category_rec_array OUT NOCOPY AMV_CATEGORY_VARRAY_TYPE
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
--    Function   : Return all channels directly under
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
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,
      p_check_login_user  	IN  VARCHAR2 := FND_API.G_TRUE,
      p_category_id      	IN  NUMBER,
	 p_include_subcats		IN  VARCHAR2 := FND_API.G_FALSE,
      x_content_chan_array    OUT NOCOPY AMV_CAT_HIERARCHY_VARRAY_TYPE
);
--
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
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,
      p_check_login_user  	IN  VARCHAR2 := FND_API.G_TRUE,
      p_category_id      	IN  NUMBER,
	 p_include_subcats		IN  VARCHAR2 := FND_API.G_FALSE,
      x_items_array    	 OUT NOCOPY AMV_CAT_HIERARCHY_VARRAY_TYPE
);
--
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
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,
      p_check_login_user  	IN  VARCHAR2 := FND_API.G_TRUE,
      p_category_id      	IN  NUMBER,
	 p_include_subcats		IN  VARCHAR2 := FND_API.G_FALSE,
	 p_request_obj			IN  AMV_REQUEST_OBJ_TYPE,
      p_category_sort      	IN  AMV_SORT_OBJ_TYPE,
	 x_return_obj		 OUT NOCOPY AMV_RETURN_OBJ_TYPE,
      x_items_array    	 OUT NOCOPY AMV_CAT_HIERARCHY_VARRAY_TYPE
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
--                 p_parent_category_name       IN  VARCHAR2  Optional
--                      Default = FND_API.G_MISS_CHAR
--                      parent category name
--                      parent id or name required for subcategory name
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
(     p_api_version           	IN  NUMBER,
      p_init_msg_list         	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level   	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status          OUT NOCOPY VARCHAR2,
      x_msg_count              OUT NOCOPY NUMBER,
      x_msg_data               OUT NOCOPY VARCHAR2,
      p_check_login_user  	IN  VARCHAR2 := FND_API.G_TRUE,
      p_application_id		  IN  NUMBER := AMV_UTILITY_PVT.G_AMV_APP_ID,
      p_category_name           IN  VARCHAR2,
      p_parent_category_id      IN  NUMBER := FND_API.G_MISS_NUM,
      p_parent_category_name    IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      x_category_id	 OUT NOCOPY NUMBER
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
(     p_api_version           	IN  NUMBER,
      p_init_msg_list         	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level   	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status          OUT NOCOPY VARCHAR2,
      x_msg_count              OUT NOCOPY NUMBER,
      x_msg_data               OUT NOCOPY VARCHAR2,
      p_check_login_user  	IN  VARCHAR2 := FND_API.G_TRUE,
      p_category_id		IN  NUMBER,
      x_category_hierarchy      OUT NOCOPY AMV_CAT_HIERARCHY_VARRAY_TYPE
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
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,
      p_check_login_user  	IN  VARCHAR2 := FND_API.G_TRUE,
      p_category_id			IN  NUMBER,
      x_category_hierarchy    OUT NOCOPY AMV_CAT_HIERARCHY_VARRAY_TYPE
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
(     p_api_version           	IN  NUMBER,
      p_init_msg_list         	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level   	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status          OUT NOCOPY VARCHAR2,
      x_msg_count              OUT NOCOPY NUMBER,
      x_msg_data               OUT NOCOPY VARCHAR2,
      p_check_login_user  	IN  VARCHAR2 := FND_API.G_TRUE,
      p_channel_id		IN  NUMBER,
	 x_channel_name OUT NOCOPY VARCHAR2,
      x_category_hierarchy      OUT NOCOPY AMV_CAT_HIERARCHY_VARRAY_TYPE
);
-- Algorithm:
--   BEGIN
--    ...
--   END
--------------------------------------------------------------------------------
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
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,
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
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,
      p_check_login_user  	IN  VARCHAR2 := FND_API.G_TRUE,
      p_object_version_number IN  NUMBER,
      p_category_id			IN  NUMBER
);
-- Algorithm:
--   BEGIN
--    ...
--   END
--------------------------------------------------------------------------------
--
END amv_category_pvt;

 

/
