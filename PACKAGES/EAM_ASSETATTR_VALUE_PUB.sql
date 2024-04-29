--------------------------------------------------------
--  DDL for Package EAM_ASSETATTR_VALUE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ASSETATTR_VALUE_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPAAVS.pls 120.0 2005/05/25 15:39:13 appldev noship $ */
/*#
 * This package is used for the INSERT / UPDATE /Validation of asset attribute values.
 * It defines 2 key procedures insert_assetattr_value and update_assetattr_value
 * which first validates and massages the IN parameters and then carries out
 * the respective operations.
 * @rep:scope public
 * @rep:product EAM
 * @rep:lifecycle active
 * @rep:displayname Asset Attributes Values
 * @rep:category BUSINESS_ENTITY EAM_ASSET_ATTRIBUTE_VALUE
 */

-- Start of comments
--	API name 	: EAM_ASSETATTR_VALUE_PUB
--	Type		: Public
--	Function	: insert_dept_appr, update_dept_appr
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version           IN NUMBER	Required
--				p_init_msg_list		IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	    	IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--				p_validation_level	IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				parameter1
--				parameter2
--				.
--				.
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count		OUT	NUMBER
--				x_msg_data		OUT	VARCHAR2(2000)
--				parameter1
--				parameter2
--				.
--				.
--	Version	: Current version	x.x
--				Changed....
--			  previous version	y.y
--				Changed....
--			  .
--			  .
--			  previous version	2.0
--				Changed....
--			  Initial version 	1.0
--
--	Notes		: Note text
--
-- End of comments

      /*#
	* This procedure is used to insert records in MTL_EAM_ASSET_ATTR_VALUES.
	* It is used to create Asset Attribute Values
	* @param p_api_version  Version of the API
	* @param p_init_msg_list Flag to indicate initialization of message list
	* @param p_commit Flag to indicate whether API should commit changes
	* @param p_validation_level Validation Level of the API
	* @param x_return_status Return status of the procedure call
	* @param x_msg_count Count of the return messages that API returns
	* @param x_msg_data The collection of the messages
	* @param P_ASSOCIATION_ID Asset Group and Attribute Group association ID. This is the foreign key to MTL_EAM_ASSET_ATTR_GROUPS.ASSOCIATION_ID
	* @param P_APPLICATION_ID Application Identifier of the flexfield for the attribute group. From MTL_EAM_ASSET_ATTR_GROUPS.APPLICATION_ID
	* @param P_DESCRIPTIVE_FLEXFIELD_NAME Name of flexfield for the attribute group. From MTL_EAM_ASSET_ATTR_GROUPS.DESCRIPTIVE_FLEXFIELD_NAME
	* @param P_INVENTORY_ITEM_ID Inventory item identifier of the asset group
	* @param P_SERIAL_NUMBER Asset Number
	* @param P_ORGANIZATION_ID Organization identifier of the Asset group
	* @param P_ATTRIBUTE_CATEGORY Descriptive flexfield structure defining column
	* @param P_C_ATTRIBUTE1 Descriptive flexfield column
	* @param P_C_ATTRIBUTE2 Descriptive flexfield column
	* @param P_C_ATTRIBUTE3 Descriptive flexfield column
	* @param P_C_ATTRIBUTE4 Descriptive flexfield column
	* @param P_C_ATTRIBUTE5 Descriptive flexfield column
	* @param P_C_ATTRIBUTE6 Descriptive flexfield column
	* @param P_C_ATTRIBUTE7 Descriptive flexfield column
	* @param P_C_ATTRIBUTE8 Descriptive flexfield column
	* @param P_C_ATTRIBUTE9 Descriptive flexfield column
	* @param P_C_ATTRIBUTE10 Descriptive flexfield column
	* @param P_C_ATTRIBUTE11 Descriptive flexfield column
	* @param P_C_ATTRIBUTE12 Descriptive flexfield column
	* @param P_C_ATTRIBUTE13 Descriptive flexfield column
	* @param P_C_ATTRIBUTE14 Descriptive flexfield column
	* @param P_C_ATTRIBUTE15 Descriptive flexfield column
	* @param P_C_ATTRIBUTE16 Descriptive flexfield column
	* @param P_C_ATTRIBUTE17 Descriptive flexfield column
	* @param P_C_ATTRIBUTE18 Descriptive flexfield column
	* @param P_C_ATTRIBUTE19 Descriptive flexfield column
	* @param P_C_ATTRIBUTE20 Descriptive flexfield column
	* @param P_D_ATTRIBUTE1 Descriptive flexfield column
	* @param P_D_ATTRIBUTE2 Descriptive flexfield column
	* @param P_D_ATTRIBUTE3 Descriptive flexfield column
	* @param P_D_ATTRIBUTE4 Descriptive flexfield column
	* @param P_D_ATTRIBUTE5 Descriptive flexfield column
	* @param P_D_ATTRIBUTE6 Descriptive flexfield column
	* @param P_D_ATTRIBUTE7 Descriptive flexfield column
	* @param P_D_ATTRIBUTE8 Descriptive flexfield column
	* @param P_D_ATTRIBUTE9 Descriptive flexfield column
	* @param P_D_ATTRIBUTE10 Descriptive flexfield column
	* @param P_N_ATTRIBUTE1 Descriptive flexfield column
	* @param P_N_ATTRIBUTE2 Descriptive flexfield column
	* @param P_N_ATTRIBUTE3 Descriptive flexfield column
	* @param P_N_ATTRIBUTE4 Descriptive flexfield column
	* @param P_N_ATTRIBUTE5 Descriptive flexfield column
	* @param P_N_ATTRIBUTE6 Descriptive flexfield column
	* @param P_N_ATTRIBUTE7 Descriptive flexfield column
	* @param P_N_ATTRIBUTE8 Descriptive flexfield column
	* @param P_N_ATTRIBUTE9 Descriptive flexfield column
	* @param P_N_ATTRIBUTE10 Descriptive flexfield column
	* @param P_MAINTENANCE_OBJECT_TYPE Object Type
	* @param P_MAINTENANCE_OBJECT_ID Object ID
	* @param P_CREATION_ORGANIZATION_ID Creation Organization Identifier
	* @return Returns the status of the procedure call as well as the return messages
	* @rep:scope public
	* @rep:displayname Insert Asset Attribute Values
	*/

procedure insert_assetattr_value
(
	p_api_version           	IN	NUMBER			,
  	p_init_msg_list	   	IN	VARCHAR2:= FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2:= FND_API.G_FALSE	,
	p_validation_level	IN  	NUMBER  := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT NOCOPY VARCHAR2	 ,
	x_msg_count		OUT NOCOPY NUMBER	 ,
	x_msg_data	    	OUT NOCOPY VARCHAR2  ,
	P_ASSOCIATION_ID	IN	NUMBER	,
	P_APPLICATION_ID	IN	NUMBER	default 401,
	P_DESCRIPTIVE_FLEXFIELD_NAME  	IN	VARCHAR2 default 'MTL_EAM_ASSET_ATTR_VALUES'	,
	P_INVENTORY_ITEM_ID	IN	NUMBER	default null,
	P_SERIAL_NUMBER		IN	VARCHAR2 default null	,
	P_ORGANIZATION_ID	IN	NUMBER	,
	P_ATTRIBUTE_CATEGORY	IN	VARCHAR2	,
	P_C_ATTRIBUTE1		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE2		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE3		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE4		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE5		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE6		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE7		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE8		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE9		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE10		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE11		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE12		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE13		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE14		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE15		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE16		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE17		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE18		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE19		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE20		IN	VARCHAR2	default null,
	P_D_ATTRIBUTE1		IN	DATE	default null,
	P_D_ATTRIBUTE2		IN	DATE	default null,
	P_D_ATTRIBUTE3		IN	DATE	default null,
	P_D_ATTRIBUTE4		IN	DATE	default null,
	P_D_ATTRIBUTE5		IN	DATE	default null,
	P_D_ATTRIBUTE6		IN	DATE	default null,
	P_D_ATTRIBUTE7		IN	DATE	default null,
	P_D_ATTRIBUTE8		IN	DATE	default null,
	P_D_ATTRIBUTE9		IN	DATE	default null,
	P_D_ATTRIBUTE10		IN	DATE	default null,
	P_N_ATTRIBUTE1		IN	NUMBER	default null,
	P_N_ATTRIBUTE2		IN	NUMBER	default null,
	P_N_ATTRIBUTE3		IN	NUMBER	default null,
	P_N_ATTRIBUTE4		IN	NUMBER	default null,
	P_N_ATTRIBUTE5		IN	NUMBER	default null,
	P_N_ATTRIBUTE6		IN	NUMBER	default null,
	P_N_ATTRIBUTE7		IN	NUMBER	default null,
	P_N_ATTRIBUTE8		IN	NUMBER	default null,
	P_N_ATTRIBUTE9		IN	NUMBER	default null,
	P_N_ATTRIBUTE10		IN	NUMBER	default null,
	P_MAINTENANCE_OBJECT_TYPE     	IN	VARCHAR2 default null	,
	P_MAINTENANCE_OBJECT_ID		IN	NUMBER	default null,
	P_CREATION_ORGANIZATION_ID  	IN	NUMBER	default null
);

/*#
 * This procedure is used to update the existing records in MTL_EAM_ASSET_ATTR_VALUES.
 * It is used to update Asset Attribute Values.
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param p_validation_level Validation Level of the API
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages.
 * @param P_ASSOCIATION_ID Asset Group and Attribute Group association ID. This is the foreign key to MTL_EAM_ASSET_ATTR_GROUPS.ASSOCIATION_ID
* @param P_APPLICATION_ID Application Identifier of the flexfield for the attribute group. From MTL_EAM_ASSET_ATTR_GROUPS.APPLICATION_ID
* @param P_DESCRIPTIVE_FLEXFIELD_NAME Name of flexfield for the attribute group. From MTL_EAM_ASSET_ATTR_GROUPS.DESCRIPTIVE_FLEXFIELD_NAME
* @param P_INVENTORY_ITEM_ID Inventory item identifier of the asset group
* @param P_SERIAL_NUMBER Asset Number
* @param P_ORGANIZATION_ID Organization identifier of the Asset group
* @param P_ATTRIBUTE_CATEGORY Descriptive flexfield structure defining column
* @param P_C_ATTRIBUTE1 Descriptive flexfield column
* @param P_C_ATTRIBUTE2 Descriptive flexfield column
* @param P_C_ATTRIBUTE3 Descriptive flexfield column
* @param P_C_ATTRIBUTE4 Descriptive flexfield column
* @param P_C_ATTRIBUTE5 Descriptive flexfield column
* @param P_C_ATTRIBUTE6 Descriptive flexfield column
* @param P_C_ATTRIBUTE7 Descriptive flexfield column
* @param P_C_ATTRIBUTE8 Descriptive flexfield column
* @param P_C_ATTRIBUTE9 Descriptive flexfield column
* @param P_C_ATTRIBUTE10 Descriptive flexfield column
* @param P_C_ATTRIBUTE11 Descriptive flexfield column
* @param P_C_ATTRIBUTE12 Descriptive flexfield column
* @param P_C_ATTRIBUTE13 Descriptive flexfield column
* @param P_C_ATTRIBUTE14 Descriptive flexfield column
* @param P_C_ATTRIBUTE15 Descriptive flexfield column
* @param P_C_ATTRIBUTE16 Descriptive flexfield column
* @param P_C_ATTRIBUTE17 Descriptive flexfield column
* @param P_C_ATTRIBUTE18 Descriptive flexfield column
* @param P_C_ATTRIBUTE19 Descriptive flexfield column
* @param P_C_ATTRIBUTE20 Descriptive flexfield column
* @param P_D_ATTRIBUTE1 Descriptive flexfield column
* @param P_D_ATTRIBUTE2 Descriptive flexfield column
* @param P_D_ATTRIBUTE3 Descriptive flexfield column
* @param P_D_ATTRIBUTE4 Descriptive flexfield column
* @param P_D_ATTRIBUTE5 Descriptive flexfield column
* @param P_D_ATTRIBUTE6 Descriptive flexfield column
* @param P_D_ATTRIBUTE7 Descriptive flexfield column
* @param P_D_ATTRIBUTE8 Descriptive flexfield column
* @param P_D_ATTRIBUTE9 Descriptive flexfield column
* @param P_D_ATTRIBUTE10 Descriptive flexfield column
* @param P_N_ATTRIBUTE1 Descriptive flexfield column
* @param P_N_ATTRIBUTE2 Descriptive flexfield column
* @param P_N_ATTRIBUTE3 Descriptive flexfield column
* @param P_N_ATTRIBUTE4 Descriptive flexfield column
* @param P_N_ATTRIBUTE5 Descriptive flexfield column
* @param P_N_ATTRIBUTE6 Descriptive flexfield column
* @param P_N_ATTRIBUTE7 Descriptive flexfield column
* @param P_N_ATTRIBUTE8 Descriptive flexfield column
* @param P_N_ATTRIBUTE9 Descriptive flexfield column
* @param P_N_ATTRIBUTE10 Descriptive flexfield column
* @param P_MAINTENANCE_OBJECT_TYPE Object Type
* @param P_MAINTENANCE_OBJECT_ID Object ID
* @param P_CREATION_ORGANIZATION_ID Creation Organization Identifier
 * @return Returns the status of the procedure call as well as the return messages
 * @scope public
 * @rep:displayname Update Asset Attribute Values
 */

procedure update_assetattr_value
(   p_api_version           	IN	NUMBER			,
  	p_init_msg_list	   	IN	VARCHAR2:= FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2:= FND_API.G_FALSE	,
	p_validation_level	IN  	NUMBER  := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT NOCOPY VARCHAR2	 ,
	x_msg_count		OUT NOCOPY NUMBER	 ,
	x_msg_data	 	OUT NOCOPY VARCHAR2  ,
	P_ASSOCIATION_ID	IN	NUMBER	,
	P_APPLICATION_ID	IN	NUMBER	default 401,
	P_DESCRIPTIVE_FLEXFIELD_NAME  IN	VARCHAR2 default 'MTL_EAM_ASSET_ATTR_VALUES'	,
	P_INVENTORY_ITEM_ID	IN	NUMBER	default null,
	P_SERIAL_NUMBER		IN	VARCHAR2	default null,
	P_ORGANIZATION_ID	IN	NUMBER	,
	P_ATTRIBUTE_CATEGORY	IN	VARCHAR2	,
	P_C_ATTRIBUTE1		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE2		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE3		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE4		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE5		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE6		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE7		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE8		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE9		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE10		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE11		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE12		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE13		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE14		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE15		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE16		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE17		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE18		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE19		IN	VARCHAR2	default null,
	P_C_ATTRIBUTE20		IN	VARCHAR2	default null,
	P_D_ATTRIBUTE1		IN	DATE	default null,
	P_D_ATTRIBUTE2		IN	DATE	default null,
	P_D_ATTRIBUTE3		IN	DATE	default null,
	P_D_ATTRIBUTE4		IN	DATE	default null,
	P_D_ATTRIBUTE5		IN	DATE	default null,
	P_D_ATTRIBUTE6		IN	DATE	default null,
	P_D_ATTRIBUTE7		IN	DATE	default null,
	P_D_ATTRIBUTE8		IN	DATE	default null,
	P_D_ATTRIBUTE9		IN	DATE	default null,
	P_D_ATTRIBUTE10		IN	DATE	default null,
	P_N_ATTRIBUTE1		IN	NUMBER	default null,
	P_N_ATTRIBUTE2		IN	NUMBER	default null,
	P_N_ATTRIBUTE3		IN	NUMBER	default null,
	P_N_ATTRIBUTE4		IN	NUMBER	default null,
	P_N_ATTRIBUTE5		IN	NUMBER	default null,
	P_N_ATTRIBUTE6		IN	NUMBER	default null,
	P_N_ATTRIBUTE7		IN	NUMBER	default null,
	P_N_ATTRIBUTE8		IN	NUMBER	default null,
	P_N_ATTRIBUTE9		IN	NUMBER	default null,
	P_N_ATTRIBUTE10		IN	NUMBER	default null,
	P_MAINTENANCE_OBJECT_TYPE     	IN	VARCHAR2	default null,
	P_MAINTENANCE_OBJECT_ID		IN	NUMBER	default null,
	P_CREATION_ORGANIZATION_ID  	IN	NUMBER	default null
);

END EAM_ASSETATTR_VALUE_PUB;

 

/
