--------------------------------------------------------
--  DDL for Package IBC_ASSOCIATIONS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_ASSOCIATIONS_GRP" AUTHID CURRENT_USER AS
/* $Header: ibcgasss.pls 115.6 2003/09/19 21:55:37 enunez ship $ */


-- shared default value
G_OBJ_VERSION_DEFAULT    CONSTANT NUMBER := 1;



--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Create_Association
--    Type       : Group
--    Pre-reqs   : None
--    Function   : Create an association mapping between an External object
--                 and a content item (optionally, a particular version).
--------------------------------------------------------------------------------
PROCEDURE Create_Association (
	p_api_version			IN    	NUMBER,
        p_init_msg_list			IN    	VARCHAR2 DEFAULT Fnd_Api.G_FALSE,
	p_commit			IN	VARCHAR2 DEFAULT Fnd_Api.G_FALSE,
	p_assoc_type_code		IN	VARCHAR2,
	p_assoc_object1			IN	VARCHAR2,
	p_assoc_object2			IN	VARCHAR2 DEFAULT NULL,
	p_assoc_object3			IN	VARCHAR2 DEFAULT NULL,
	p_assoc_object4			IN	VARCHAR2 DEFAULT NULL,
	p_assoc_object5			IN	VARCHAR2 DEFAULT NULL,
	p_content_item_id		IN	NUMBER,
        p_citem_version_id              IN      NUMBER DEFAULT NULL,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
);

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Delete_Association
--    Type       : Group
--    Pre-reqs   : None
--    Function   : Delete an association mapping between an External object
--		   and a content item.
--------------------------------------------------------------------------------
PROCEDURE Delete_Association (
	p_api_version			IN    	NUMBER,
        p_init_msg_list			IN    	VARCHAR2 DEFAULT Fnd_Api.G_FALSE,
	p_commit			IN	VARCHAR2 DEFAULT Fnd_Api.G_FALSE,
	p_assoc_type_code		IN	VARCHAR2,
	p_assoc_object1			IN	VARCHAR2,
	p_assoc_object2			IN	VARCHAR2 DEFAULT NULL,
	p_assoc_object3			IN	VARCHAR2 DEFAULT NULL,
	p_assoc_object4			IN	VARCHAR2 DEFAULT NULL,
	p_assoc_object5			IN	VARCHAR2 DEFAULT NULL,
	p_content_item_id		IN	NUMBER,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
);

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Update_Association
--    Type       : Group
--    Pre-reqs   : None
--    Function   : Update an External object's association mapping with
--                 a content item (optionally, a particular version).
--------------------------------------------------------------------------------
PROCEDURE Update_Association (
	p_api_version			IN    	NUMBER,
        p_init_msg_list			IN    	VARCHAR2 DEFAULT Fnd_Api.G_FALSE,
	p_commit			IN	VARCHAR2 DEFAULT Fnd_Api.G_FALSE,
	p_assoc_type_code		IN	VARCHAR2,
	p_assoc_object1			IN	VARCHAR2,
	p_assoc_object2			IN	VARCHAR2 DEFAULT NULL,
	p_assoc_object3			IN	VARCHAR2 DEFAULT NULL,
	p_assoc_object4			IN	VARCHAR2 DEFAULT NULL,
	p_assoc_object5			IN	VARCHAR2 DEFAULT NULL,
	p_old_citem_id			IN	NUMBER,
	p_new_citem_id			IN	NUMBER,
	p_new_citem_ver_id		IN	NUMBER DEFAULT NULL,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
);











PROCEDURE Move_Associations (
	p_api_version			IN  NUMBER,
	p_init_msg_list			IN  VARCHAR2,
	p_commit			IN  VARCHAR2,
	p_old_content_item_ids		IN  JTF_NUMBER_TABLE,
	p_new_content_item_ids		IN  JTF_NUMBER_TABLE,
	p_assoc_type_codes		IN  JTF_VARCHAR2_TABLE_100,
	p_assoc_objects1		IN  JTF_VARCHAR2_TABLE_300,
	p_assoc_objects2		IN  JTF_VARCHAR2_TABLE_300,
	p_assoc_objects3		IN  JTF_VARCHAR2_TABLE_300,
	p_assoc_objects4		IN  JTF_VARCHAR2_TABLE_300,
	p_assoc_objects5		IN  JTF_VARCHAR2_TABLE_300,
	x_return_status			OUT NOCOPY VARCHAR2,
	x_msg_count			OUT NOCOPY NUMBER,
	x_msg_data			OUT NOCOPY VARCHAR2
);

PROCEDURE Move_Associations (
	p_api_version			IN  NUMBER,
	p_init_msg_list			IN  VARCHAR2,
	p_commit			IN  VARCHAR2,
	p_old_content_item_ids		IN  JTF_NUMBER_TABLE,
	p_new_content_item_ids		IN  JTF_NUMBER_TABLE,
    p_old_citem_version_ids     IN  JTF_NUMBER_TABLE,
    p_new_citem_version_ids     IN  JTF_NUMBER_TABLE,
	p_assoc_type_codes		IN  JTF_VARCHAR2_TABLE_100,
	p_assoc_objects1		IN  JTF_VARCHAR2_TABLE_300,
	p_assoc_objects2		IN  JTF_VARCHAR2_TABLE_300,
	p_assoc_objects3		IN  JTF_VARCHAR2_TABLE_300,
	p_assoc_objects4		IN  JTF_VARCHAR2_TABLE_300,
	p_assoc_objects5		IN  JTF_VARCHAR2_TABLE_300,
	x_return_status			OUT NOCOPY VARCHAR2,
	x_msg_count			OUT NOCOPY NUMBER,
	x_msg_data			OUT NOCOPY VARCHAR2
);

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Create_Associations
--    Type       : Group
--    Pre-reqs   : None
--    Function   : Create association mappings between content items and
--		   other CRM objects.
--    Parameters :
--    IN         : p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit			IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--		   p_content_item_ids		IN  JTF_NUMBER_TABLE Required
--		   p_assoc_type_codes		IN  JTF_VARCHAR2_TABLE_100 Required
--		   p_assoc_objects1		IN  JTF_VARCHAR2_TABLE_300 Required
--		   p_assoc_objects2		IN  JTF_VARCHAR2_TABLE_300 Optional
--			  Default = NULL
--		   p_assoc_objects3		IN  JTF_VARCHAR2_TABLE_300 Optional
--			  Default = NULL
--		   p_assoc_objects4		IN  JTF_VARCHAR2_TABLE_300 Optional
--			  Default = NULL
--		   p_assoc_objects5		IN  JTF_VARCHAR2_TABLE_300 Optional
--			  Default = NULL
--    OUT        : x_return_status              OUT VARCHAR2
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2
--------------------------------------------------------------------------------
PROCEDURE Create_Associations (
	p_api_version			IN    	NUMBER,
    p_init_msg_list			IN    	VARCHAR2 DEFAULT Fnd_Api.G_FALSE,
	p_commit			    IN	VARCHAR2 DEFAULT Fnd_Api.G_FALSE,
	p_content_item_ids		IN	JTF_NUMBER_TABLE,
	p_assoc_type_codes		IN	JTF_VARCHAR2_TABLE_100,
	p_assoc_objects1		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects2		IN	JTF_VARCHAR2_TABLE_300 DEFAULT NULL,
	p_assoc_objects3		IN	JTF_VARCHAR2_TABLE_300 DEFAULT NULL,
	p_assoc_objects4		IN	JTF_VARCHAR2_TABLE_300 DEFAULT NULL,
	p_assoc_objects5		IN	JTF_VARCHAR2_TABLE_300 DEFAULT NULL,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
);

PROCEDURE Create_Associations (
	p_api_version			IN    	NUMBER,
    p_init_msg_list			IN    	VARCHAR2 DEFAULT Fnd_Api.G_FALSE,
	p_commit			    IN	VARCHAR2 DEFAULT Fnd_Api.G_FALSE,
	p_content_item_ids		IN	JTF_NUMBER_TABLE,
    p_citem_version_ids     IN  JTF_NUMBER_TABLE,
	p_assoc_type_codes		IN	JTF_VARCHAR2_TABLE_100,
	p_assoc_objects1		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects2		IN	JTF_VARCHAR2_TABLE_300 DEFAULT NULL,
	p_assoc_objects3		IN	JTF_VARCHAR2_TABLE_300 DEFAULT NULL,
	p_assoc_objects4		IN	JTF_VARCHAR2_TABLE_300 DEFAULT NULL,
	p_assoc_objects5		IN	JTF_VARCHAR2_TABLE_300 DEFAULT NULL,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
);


--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Delete_Associations
--    Type       : Group
--    Pre-reqs   : None
--    Function   : Delete association mappings between content items and
--		   other CRM objects.
--    Parameters :
--    IN         : p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit			IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--		   p_content_item_ids		IN  JTF_NUMBER_TABLE Required
--		   p_assoc_type_codes		IN  JTF_VARCHAR2_TABLE_100 Required
--		   p_assoc_objects1		IN  JTF_VARCHAR2_TABLE_300 Required
--		   p_assoc_objects2		IN  JTF_VARCHAR2_TABLE_300 Optional
--			  Default = NULL
--		   p_assoc_objects3		IN  JTF_VARCHAR2_TABLE_300 Optional
--			  Default = NULL
--		   p_assoc_objects4		IN  JTF_VARCHAR2_TABLE_300 Optional
--			  Default = NULL
--		   p_assoc_objects5		IN  JTF_VARCHAR2_TABLE_300 Optional
--			  Default = NULL
--    OUT        : x_return_status              OUT VARCHAR2
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2
--------------------------------------------------------------------------------
PROCEDURE Delete_Associations (
	p_api_version			IN    	NUMBER,
        p_init_msg_list			IN    	VARCHAR2 DEFAULT Fnd_Api.G_FALSE,
	p_commit			IN	VARCHAR2 DEFAULT Fnd_Api.G_FALSE,
	p_content_item_ids		IN	JTF_NUMBER_TABLE,
	p_assoc_type_codes		IN	JTF_VARCHAR2_TABLE_100,
	p_assoc_objects1		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects2		IN	JTF_VARCHAR2_TABLE_300 DEFAULT NULL,
	p_assoc_objects3		IN	JTF_VARCHAR2_TABLE_300 DEFAULT NULL,
	p_assoc_objects4		IN	JTF_VARCHAR2_TABLE_300 DEFAULT NULL,
	p_assoc_objects5		IN	JTF_VARCHAR2_TABLE_300 DEFAULT NULL,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
);

PROCEDURE Delete_Associations (
	p_api_version			IN    	NUMBER,
        p_init_msg_list			IN    	VARCHAR2 DEFAULT Fnd_Api.G_FALSE,
	p_commit			IN	VARCHAR2 DEFAULT Fnd_Api.G_FALSE,
	p_content_item_ids		IN	JTF_NUMBER_TABLE,
    p_citem_version_ids     IN  JTF_NUMBER_TABLE,
	p_assoc_type_codes		IN	JTF_VARCHAR2_TABLE_100,
	p_assoc_objects1		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects2		IN	JTF_VARCHAR2_TABLE_300 DEFAULT NULL,
	p_assoc_objects3		IN	JTF_VARCHAR2_TABLE_300 DEFAULT NULL,
	p_assoc_objects4		IN	JTF_VARCHAR2_TABLE_300 DEFAULT NULL,
	p_assoc_objects5		IN	JTF_VARCHAR2_TABLE_300 DEFAULT NULL,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
);


PROCEDURE Get_Associations (
	p_api_version			IN    	NUMBER,
        p_init_msg_list			IN    	VARCHAR2 DEFAULT Fnd_Api.G_FALSE,
	p_content_item_id		IN	NUMBER,
	p_assoc_type_codes		IN	JTF_VARCHAR2_TABLE_100,
	p_assoc_objects1		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects2		IN	JTF_VARCHAR2_TABLE_300 DEFAULT NULL,
	p_assoc_objects3		IN	JTF_VARCHAR2_TABLE_300 DEFAULT NULL,
	p_assoc_objects4		IN	JTF_VARCHAR2_TABLE_300 DEFAULT NULL,
	p_assoc_objects5		IN	JTF_VARCHAR2_TABLE_300 DEFAULT NULL,
	x_assoc_type_codes		OUT NOCOPY	JTF_VARCHAR2_TABLE_100,
	x_assoc_objects1		OUT NOCOPY	JTF_VARCHAR2_TABLE_300,
	x_assoc_objects2		OUT NOCOPY	JTF_VARCHAR2_TABLE_300,
	x_assoc_objects3		OUT NOCOPY	JTF_VARCHAR2_TABLE_300,
	x_assoc_objects4		OUT NOCOPY	JTF_VARCHAR2_TABLE_300,
	x_assoc_objects5		OUT NOCOPY	JTF_VARCHAR2_TABLE_300,
	x_assoc_names			OUT NOCOPY	JTF_VARCHAR2_TABLE_4000,
	x_assoc_codes			OUT NOCOPY	JTF_VARCHAR2_TABLE_100,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
);

PROCEDURE Get_Associations (
	p_api_version			IN    	NUMBER,
        p_init_msg_list			IN    	VARCHAR2 DEFAULT Fnd_Api.G_FALSE,
	p_content_item_id		IN	NUMBER,
    p_citem_version_id      IN  NUMBER,
	p_assoc_type_codes		IN	JTF_VARCHAR2_TABLE_100,
	p_assoc_objects1		IN	JTF_VARCHAR2_TABLE_300,
	p_assoc_objects2		IN	JTF_VARCHAR2_TABLE_300 DEFAULT NULL,
	p_assoc_objects3		IN	JTF_VARCHAR2_TABLE_300 DEFAULT NULL,
	p_assoc_objects4		IN	JTF_VARCHAR2_TABLE_300 DEFAULT NULL,
	p_assoc_objects5		IN	JTF_VARCHAR2_TABLE_300 DEFAULT NULL,
	x_assoc_type_codes		OUT NOCOPY	JTF_VARCHAR2_TABLE_100,
	x_assoc_objects1		OUT NOCOPY	JTF_VARCHAR2_TABLE_300,
	x_assoc_objects2		OUT NOCOPY	JTF_VARCHAR2_TABLE_300,
	x_assoc_objects3		OUT NOCOPY	JTF_VARCHAR2_TABLE_300,
	x_assoc_objects4		OUT NOCOPY	JTF_VARCHAR2_TABLE_300,
	x_assoc_objects5		OUT NOCOPY	JTF_VARCHAR2_TABLE_300,
	x_assoc_names			OUT NOCOPY	JTF_VARCHAR2_TABLE_4000,
	x_assoc_codes			OUT NOCOPY	JTF_VARCHAR2_TABLE_100,
	x_return_status			OUT NOCOPY   	VARCHAR2,
        x_msg_count			OUT NOCOPY    	NUMBER,
        x_msg_data			OUT NOCOPY   	VARCHAR2
);

FUNCTION Get_Association_NameAndCode(p_content_item_id  IN NUMBER,
                                     p_citem_version_id IN NUMBER   DEFAULT NULL,
                                     p_assoc_type_code  IN VARCHAR2,
                                     p_assoc_object1    IN VARCHAR2,
                                     p_assoc_object2    IN VARCHAR2 DEFAULT NULL,
                                     p_assoc_object3    IN VARCHAR2 DEFAULT NULL,
                                     p_assoc_object4    IN VARCHAR2 DEFAULT NULL,
                                     p_assoc_object5    IN VARCHAR2 DEFAULT NULL
                                     )
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(Get_Association_NameAndCode, WNDS, WNPS, TRUST);

END Ibc_Associations_Grp;

 

/
