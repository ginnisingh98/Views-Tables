--------------------------------------------------------
--  DDL for Package Body AMV_CATEGORY_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_CATEGORY_GRP" AS
/* $Header: amvgcatb.pls 120.1 2005/06/21 17:50:47 appldev ship $ */
--
-- NAME
--   AMV_CATEGORY_GRP
-- PURPOSE
--
-- HISTORY
--   12/07/1999        SLKRISHN        CREATED
--
--
G_PKG_NAME     CONSTANT VARCHAR2(30) := 'AMV_CATEGORY_GRP';
G_FILE_NAME    CONSTANT VARCHAR2(12) := 'amvgcatb.pls';
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
)
IS
l_api_name varchar2(30) := 'Add_Category';
BEGIN
	AMV_CATEGORY_PVT.Add_Category
	(p_api_version => p_api_version,
      p_init_msg_list => p_init_msg_list,
      p_commit => p_commit,
      p_validation_level => p_validation_level,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_check_login_user => p_check_login_user,
      p_application_id => p_application_id,
      p_category_name => p_category_name,
      p_description => p_description,
      p_parent_category_id => p_parent_category_id,
      p_order => p_order,
      x_category_id => x_category_id
	);

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
		END IF;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
				p_encoded => FND_API.G_FALSE,
				p_count => x_msg_count,
				p_data  => x_msg_data
				);
END Add_Category;
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
)
IS
l_api_name varchar2(30) := 'Delete_Category';
BEGIN

	AMV_CATEGORY_PVT.Delete_Category
	(p_api_version => p_api_version,
      p_init_msg_list => p_init_msg_list,
      p_commit => p_commit,
      p_validation_level => p_validation_level,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_check_login_user => p_check_login_user,
      p_application_id => p_application_id,
      p_category_id => p_category_id,
      p_category_name => p_category_name,
      p_parent_category_id => p_parent_category_id
	);
EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
		END IF;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
				p_encoded => FND_API.G_FALSE,
				p_count => x_msg_count,
				p_data  => x_msg_data
				);
END Delete_Category;
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
)
IS
l_api_name varchar2(30) := 'Sort_Category';
BEGIN
	AMV_CATEGORY_PVT.Sort_Category
	(p_api_version => p_api_version,
      p_init_msg_list => p_init_msg_list,
      p_commit => p_commit,
      p_validation_level => p_validation_level,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_check_login_user => p_check_login_user,
      p_application_id => p_application_id,
	 p_sort_order => p_sort_order,
      p_parent_category_id => p_parent_category_id
	);

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
		END IF;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
				p_encoded => FND_API.G_FALSE,
				p_count => x_msg_count,
				p_data  => x_msg_data
				);
END Sort_Category;
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
)
IS
l_api_name varchar2(30) := 'Reorder_Category';
BEGIN
	AMV_CATEGORY_PVT.Reorder_Category
	(p_api_version => p_api_version,
      p_init_msg_list => p_init_msg_list,
      p_commit => p_commit,
      p_validation_level => p_validation_level,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_check_login_user => p_check_login_user,
      p_application_id => p_application_id,
      p_category_id_array => p_category_id_array,
      p_category_new_order => p_category_new_order
	);

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
		END IF;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
				p_encoded => FND_API.G_FALSE,
				p_count => x_msg_count,
				p_data  => x_msg_data
				);
END Reorder_Category;
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
)
IS
l_api_name varchar2(30) := 'Update_Category';
BEGIN
	AMV_CATEGORY_PVT.Update_Category
	(p_api_version => p_api_version,
      p_init_msg_list => p_init_msg_list,
      p_commit => p_commit,
      p_validation_level => p_validation_level,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_check_login_user => p_check_login_user,
      p_object_version_number => p_object_version_number,
      p_application_id => p_application_id,
      p_category_id => p_category_id,
      p_category_name => p_category_name,
      p_parent_category_id => p_parent_category_id,
      p_category_order => p_category_order,
      p_category_new_name => p_category_new_name,
      p_description => p_description
	);

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
		END IF;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
				p_encoded => FND_API.G_FALSE,
				p_count => x_msg_count,
				p_data  => x_msg_data
				);
END Update_Category;
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
)
IS
l_api_name varchar2(30) := 'Find_Categories';
BEGIN
	AMV_CATEGORY_PVT.Find_Categories
	(p_api_version => p_api_version,
      p_init_msg_list => p_init_msg_list,
      p_validation_level => p_validation_level,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_check_login_user => p_check_login_user,
      p_application_id => p_application_id,
      p_category_name => p_category_name,
      p_parent_category_id => p_parent_category_id,
	 p_ignore_hierarchy => p_ignore_hierarchy,
	 p_request_obj => p_request_obj,
	 x_return_obj	=> x_return_obj,
      x_chan_category_rec_array => x_chan_category_rec_array
	);

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
		END IF;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
				p_encoded => FND_API.G_FALSE,
				p_count => x_msg_count,
				p_data  => x_msg_data
				);
END Find_Categories;
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
)
IS
l_api_name varchar2(30) := 'Get_ChannelsPerCategory';
BEGIN
	AMV_CATEGORY_PVT.Get_ChannelsPerCategory
	(p_api_version => p_api_version,
      p_init_msg_list => p_init_msg_list,
      p_validation_level => p_validation_level,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_check_login_user => p_check_login_user,
      p_category_id => p_category_id,
	 p_include_subcats => p_include_subcats,
      x_content_chan_array => x_content_chan_array
	);

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
		END IF;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
				p_encoded => FND_API.G_FALSE,
				p_count => x_msg_count,
				p_data  => x_msg_data
				);
END Get_ChannelsPerCategory;
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
)
IS
l_api_name varchar2(30) := 'Fetch_CategoryId';
BEGIN
	AMV_CATEGORY_PVT.Fetch_CategoryId
	(p_api_version => p_api_version,
      p_init_msg_list => p_init_msg_list,
      p_validation_level => p_validation_level,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_check_login_user => p_check_login_user,
      p_application_id => p_application_id,
      p_category_name => p_category_name,
      p_parent_category_id => p_parent_category_id,
      x_category_id => x_category_id
	);

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
		END IF;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
				p_encoded => FND_API.G_FALSE,
				p_count => x_msg_count,
				p_data  => x_msg_data
				);
END Fetch_CategoryId;
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
)
IS
l_api_name varchar2(30) := 'Get_CatParentsHierarchy';
BEGIN
	AMV_CATEGORY_PVT.Get_CatParentsHierarchy
	(p_api_version => p_api_version,
      p_init_msg_list => p_init_msg_list,
      p_validation_level => p_validation_level,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_check_login_user => p_check_login_user,
      p_category_id => p_category_id,
      x_category_hierarchy => x_category_hierarchy
	);

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
		END IF;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
				p_encoded => FND_API.G_FALSE,
				p_count => x_msg_count,
				p_data  => x_msg_data
				);
END Get_CatParentsHierarchy;
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
)
IS
l_api_name varchar2(30) := 'Get_CatChildrenHierarchy';
BEGIN
	AMV_CATEGORY_PVT.Get_CatChildrenHierarchy
	(p_api_version => p_api_version,
      p_init_msg_list => p_init_msg_list,
      p_validation_level => p_validation_level,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_check_login_user => p_check_login_user,
      p_category_id => p_category_id,
      x_category_hierarchy => x_category_hierarchy
	);

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
		END IF;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
				p_encoded => FND_API.G_FALSE,
				p_count => x_msg_count,
				p_data  => x_msg_data
				);
END Get_CatChildrenHierarchy;
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
)
IS
l_api_name varchar2(30) := 'Get_ChnCategoryHierarchy';
BEGIN
	AMV_CATEGORY_PVT.Get_ChnCategoryHierarchy
	(p_api_version => p_api_version,
      p_init_msg_list => p_init_msg_list,
      p_validation_level => p_validation_level,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_check_login_user => p_check_login_user,
      p_channel_id => p_channel_id,
	 x_channel_name => x_channel_name,
      x_category_hierarchy => x_category_hierarchy
	);

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
		END IF;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
				p_encoded => FND_API.G_FALSE,
				p_count => x_msg_count,
				p_data  => x_msg_data
				);
END Get_ChnCategoryHierarchy;
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
)
IS
l_api_name varchar2(30) := 'Get_ItemsPerCategory';
BEGIN
	AMV_CATEGORY_PVT.Get_ItemsPerCategory
	(p_api_version => p_api_version,
      p_init_msg_list => p_init_msg_list,
      p_validation_level => p_validation_level,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_check_login_user => p_check_login_user,
      p_category_id => p_category_id,
	 p_include_subcats => p_include_subcats,
	 p_request_obj => p_request_obj,
	 p_category_sort => p_category_sort,
	 x_return_obj => x_return_obj,
      x_items_array => x_items_array
	);

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
		END IF;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
				p_encoded => FND_API.G_FALSE,
				p_count => x_msg_count,
				p_data  => x_msg_data
				);
END Get_ItemsPerCategory;
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
)
IS
l_api_name varchar2(30) := 'Add_CategoryParent';
BEGIN
	AMV_CATEGORY_PVT.Add_CategoryParent
	(p_api_version => p_api_version,
      p_init_msg_list => p_init_msg_list,
      p_commit => p_commit,
      p_validation_level => p_validation_level,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_check_login_user => p_check_login_user,
      p_object_version_number => p_object_version_number,
      p_category_id => p_category_id,
	 p_parent_category_id => p_parent_category_id,
	 p_replace_existing => p_replace_existing
	);

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
		END IF;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
				p_encoded => FND_API.G_FALSE,
				p_count => x_msg_count,
				p_data  => x_msg_data
				);
END Add_CategoryParent;
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
)
IS
l_api_name varchar2(30) := 'Remove_CategoryParent';
BEGIN
	AMV_CATEGORY_PVT.Remove_CategoryParent
	(p_api_version => p_api_version,
      p_init_msg_list => p_init_msg_list,
      p_commit => p_commit,
      p_validation_level => p_validation_level,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_check_login_user => p_check_login_user,
      p_object_version_number => p_object_version_number,
      p_category_id => p_category_id
	);

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
		END IF;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
				p_encoded => FND_API.G_FALSE,
				p_count => x_msg_count,
				p_data  => x_msg_data
				);
END Remove_CategoryParent;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
END amv_category_grp;

/
