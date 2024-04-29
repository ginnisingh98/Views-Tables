--------------------------------------------------------
--  DDL for Package EAM_ASSETATTR_GRP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ASSETATTR_GRP_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPAAGS.pls 120.0 2005/05/24 19:18:09 appldev noship $ */
/*#
 * This package is used for the INSERT / UPDATE /Validation of asset attribute groups.
 * It defines 2 key procedures insert_assetattr_grp and update_assetattr_grp,
 * which first validates and massages the IN parameters and then carries out
 * the respective operations.
 * @rep:scope public
 * @rep:product EAM
 * @rep:lifecycle active
 * @rep:displayname Asset Group and Attributes Group Association
 * @rep:category BUSINESS_ENTITY EAM_ASSET_ATTRIBUTE_GROUPS
 */

/*
--      API name        : EAM_ASSETATTR_GRP_PUB
--      Type            : Public
--      Function        : Insert, update and validation of the asset attribute assignemnt data
--      Pre-reqs        : None.
*/
/* Check why this global variable is required - Anand */
	G_PKG_NAME 	CONSTANT VARCHAR2(30):='EAM_ASSETATTR_GRP_PUB';

/*
This procedure inserts a record in the mtl_eam_asset_attr_groups table
--      Parameters      :
--      IN              :       P_API_VERSION	IN NUMBER	REQUIRED
--                              P_INIT_MSG_LIST IN VARCHAR2	OPTIONAL
--                                      DEFAULT = FND_API.G_FALSE
--                              P_COMMIT	IN VARCHAR2	OPTIONAL
--                                      DEFAULT = FND_API.G_FALSE
--                              P_VALIDATION_LEVEL IN NUMBER	OPTIONAL
--                                      DEFAULT = FND_API.G_VALID_LEVEL_FULL
--				P_APPLICATION_ID		IN NUMBER
--				P_DESCRIPTIVE_FLEXFIELD_NAME	IN VARCHAR2
--					DEFAULT NULL
--				P_DESC_FLEX_CONTEXT_CODE	IN VARCHAR2
--					DEFAULT NULL
--				P_ORGANIZATION_ID	IN NUMBER
--				P_INVENTORY_ITEM_ID	IN NUMBER
--				P_ENABLED_FLAG		IN VARCHAR2
--					DEFAULT NULL
--				P_CREATION_ORGANIZATION_ID IN NUMBER
--
--      OUT             :       x_return_status    OUT NOCOPY    VARCHAR2(1)
--                              x_msg_count        OUT NOCOPY    NUMBER
--                              x_msg_data         OUT NOCOPY    VARCHAR2 (2000)
--      Version :       Current version: 1.0
--                      Initial version: 1.0
--
--      Notes
*/

/*#
 * This procedure is used to insert records in MTL_EAM_ASSET_ATTR_GROUPS.
 * It is used to create Asset Attribute Groups association.
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param p_validation_level Validation Level of the API
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages
 * @param P_APPLICATION_ID Application Identifier of the flexfield for the attribute group
 * @param P_DESCRIPTIVE_FLEXFIELD_NAME Name of flexfield for the attribute group
 * @param P_DESC_FLEX_CONTEXT_CODE Context code of the flexfield for the attribute group
 * @param P_ORGANIZATION_ID Organization identifier of the asset group
 * @param P_INVENTORY_ITEM_ID Inventory item identifier of the asset group
 * @param P_ENABLED_FLAG Flag to enable or disable the association
 * @param P_CREATION_ORGANIZATION_ID Creation Organization Identifier
 * @param X_NEW_ASSOCIATION_ID This is the newly created Primary Key for the association inserted. The association is created between asset group and attribute group.
 * @return Returns the newly created Primary Key for the record inserted
 * @rep:scope public
 * @rep:displayname Insert Asset Attribute Group Association
 */


PROCEDURE INSERT_ASSETATTR_GRP
(	P_API_VERSION           	IN		NUMBER				,
  	P_INIT_MSG_LIST	   		IN		VARCHAR2:= FND_API.G_FALSE	,
	P_COMMIT	    		IN  		VARCHAR2:= FND_API.G_FALSE	,
	P_VALIDATION_LEVEL		IN  		NUMBER  := FND_API.G_VALID_LEVEL_FULL,
	X_RETURN_STATUS	    		OUT NOCOPY	VARCHAR2			,
	X_MSG_COUNT	    		OUT NOCOPY 	NUMBER				,
	X_MSG_DATA	    		OUT NOCOPY 	VARCHAR2			,
	P_APPLICATION_ID		IN		NUMBER	DEFAULT 401			,
	P_DESCRIPTIVE_FLEXFIELD_NAME	IN		VARCHAR2  DEFAULT 'MTL_EAM_ASSET_ATTR_VALUES',
	P_DESC_FLEX_CONTEXT_CODE	IN		VARCHAR2 ,
	P_ORGANIZATION_ID		IN		NUMBER				,
	P_INVENTORY_ITEM_ID		IN		NUMBER				,
	P_ENABLED_FLAG			IN		VARCHAR2 DEFAULT 'Y',
	P_CREATION_ORGANIZATION_ID	IN		NUMBER	,
	X_NEW_ASSOCIATION_ID		OUT NOCOPY	NUMBER
);

/*
This procedure updates a record in the mtl_eam_asset_attr_groups table
--      Parameters      :
--      IN              :       P_API_VERSION	IN NUMBER	REQUIRED
--                              P_INIT_MSG_LIST IN VARCHAR2	OPTIONAL
--                                      DEFAULT = FND_API.G_FALSE
--                              P_COMMIT	IN VARCHAR2	OPTIONAL
--                                      DEFAULT = FND_API.G_FALSE
--                              P_VALIDATION_LEVEL IN NUMBER	OPTIONAL
--                                      DEFAULT = FND_API.G_VALID_LEVEL_FULL
--				P_APPLICATION_ID		IN NUMBER
--				P_DESCRIPTIVE_FLEXFIELD_NAME	IN VARCHAR2
--					DEFAULT NULL
--				P_DESC_FLEX_CONTEXT_CODE	IN VARCHAR2
--					DEFAULT NULL
--				P_ORGANIZATION_ID	IN NUMBER
--				P_INVENTORY_ITEM_ID	IN NUMBER
--				P_ENABLED_FLAG		IN VARCHAR2
--					DEFAULT NULL
--				P_CREATION_ORGANIZATION_ID IN NUMBER
--
--      OUT             :       x_return_status    OUT NOCOPY    VARCHAR2(1)
--                              x_msg_count        OUT NOCOPY    NUMBER
--                              x_msg_data         OUT NOCOPY    VARCHAR2 (2000)
--      Version :       Current version: 1.0
--                      Initial version: 1.0
--
--      Notes
*/

/*#
 * This procedure is used to update the existing records in MTL_EAM_ASSET_ATTR_GROUPS.
 * It is used to update Asset Attribute Groups association.
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param p_validation_level Validation Level of the API
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages.
 * @param P_ASSOCIATION_ID Primary Key Column. Asset Group and Attribute Group association ID
 * @param P_APPLICATION_ID Application Identifier of the flexfield for the attribute group
 * @param P_DESCRIPTIVE_FLEXFIELD_NAME Name of flexfield for the attribute group
 * @param P_DESC_FLEX_CONTEXT_CODE Context code of the flexfield for the attribute group
 * @param P_ORGANIZATION_ID Organization identifier of the asset group
 * @param P_INVENTORY_ITEM_ID Inventory item identifier of the asset group
 * @param P_ENABLED_FLAG Flag to enable or disable the association. Once the associations have been defined, it cannot be deleted, user can only disable it by using this flag.
 * @param P_CREATION_ORGANIZATION_ID Creation Organization Identifier
 * @return Returns the status of the procedure call as well as the return messages
 * @rep:scope public
 * @rep:displayname Update Asset Attribute Group Association
 */

PROCEDURE UPDATE_ASSETATTR_GRP
(	P_API_VERSION           	IN		NUMBER				,
  	P_INIT_MSG_LIST	   		IN		VARCHAR2:= FND_API.G_FALSE	,
	P_COMMIT	    	    	IN  		VARCHAR2:= FND_API.G_FALSE	,
	P_VALIDATION_LEVEL	    	IN  		NUMBER  := FND_API.G_VALID_LEVEL_FULL,
	X_RETURN_STATUS	    		OUT NOCOPY 	VARCHAR2			,
	X_MSG_COUNT	    		OUT NOCOPY 	NUMBER				,
	X_MSG_DATA	    	    	OUT NOCOPY 	VARCHAR2			,
	P_ASSOCIATION_ID		IN		NUMBER	,
	P_APPLICATION_ID		IN		NUMBER	DEFAULT 401			,
	P_DESCRIPTIVE_FLEXFIELD_NAME	IN		VARCHAR2  DEFAULT 'MTL_EAM_ASSET_ATTR_VALUES',
	P_DESC_FLEX_CONTEXT_CODE	IN		VARCHAR2 ,
	P_ORGANIZATION_ID		IN		NUMBER				,
	P_INVENTORY_ITEM_ID		IN		NUMBER				,
	P_ENABLED_FLAG			IN		VARCHAR2 DEFAULT 'Y',
	P_CREATION_ORGANIZATION_ID	IN		NUMBER
);



FUNCTION VALIDATE_DESC_FLEX_FIELD_NAME
	( P_DESCRIPTIVE_FLEXFIELD_NAME VARCHAR2)
	return boolean;

FUNCTION CHECK_DESC_FLEX_CONTEXT_CODE
	(P_DESC_FLEX_CONTEXT_CODE VARCHAR2,
	P_APPLICATION_ID NUMBER)
	return boolean;

FUNCTION VALIDATE_EAM_ENABLED
	(P_ORGANIZATION_ID NUMBER)
	return boolean;

FUNCTION VALIDATE_FLAG_FIELD
	(P_ENABLED_FLAG VARCHAR2)
	return boolean;


FUNCTION VALIDATE_ITEM_ID
	(P_INVENTORY_ITEM_ID NUMBER,
	P_ORGANIZATION_ID NUMBER)
	return boolean;

FUNCTION get_item_type
(p_creation_organization_id in number,
p_inventory_item_id in number)
return number;

FUNCTION validate_row_exists
        (p_item_type in number,
        p_creation_organization_id in number,
        p_inventory_item_id in number,
        P_DESC_FLEX_CONTEXT_CODE in varchar2,
	p_association_id in number default null)
return boolean;

PROCEDURE RAISE_ERROR (ERROR VARCHAR2);
PROCEDURE PRINT_LOG(info varchar2);

END EAM_ASSETATTR_GRP_PUB;

 

/
