--------------------------------------------------------
--  DDL for Package EAM_ASSET_ROUTES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ASSET_ROUTES_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPAROS.pls 120.3 2005/07/07 16:04:00 hkarmach noship $ */
/*#
 * This package is used for the INSERT / UPDATE of asset routes.
 * It defines 2 key procedures insert_asset_routes, update_asset_routes
 * which first validates and massages the IN parameters
 * and then carries out the respective operations.
 * @rep:scope public
 * @rep:product EAM
 * @rep:lifecycle active
 * @rep:displayname Asset Routes
 * @rep:category BUSINESS_ENTITY EAM_ASSET_ROUTE
 */

-- Start of comments
--	API name 	: EAM_ASSET_ROUTES_PUB
--	Type		: Public
--	Function	: insert_asset_routes, update_asset_routes
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version           	IN NUMBER	Required
--				p_init_msg_list		IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	    		IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--				p_validation_level		IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				parameter1
--				parameter2
--				.
--				.
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count			OUT	NUMBER
--				x_msg_data			OUT	VARCHAR2(2000)
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
 * This procedure is used to insert records in MTL_EAM_NETWORK_ASSETS.
 * It is used to create Asset Routes.
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param p_validation_level Validation Level of the API
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages.
 * @param P_ORGANIZATION_ID Organization identifier of the asset route
* @param P_START_DATE_ACTIVE Effective start date of the member asset
* @param P_END_DATE_ACTIVE Effective end date of the member asset
* @param p_attribute_category Attribute Category
* @param p_attribute1 Descriptive flexfield column
* @param p_attribute2 Descriptive flexfield column
* @param p_attribute3 Descriptive flexfield column
* @param p_attribute4 Descriptive flexfield column
* @param p_attribute5 Descriptive flexfield column
* @param p_attribute6 Descriptive flexfield column
* @param p_attribute7 Descriptive flexfield column
* @param p_attribute8 Descriptive flexfield column
* @param p_attribute9 Descriptive flexfield column
* @param p_attribute10 Descriptive flexfield column
* @param p_attribute11 Descriptive flexfield column
* @param p_attribute12 Descriptive flexfield column
* @param p_attribute13 Descriptive flexfield column
* @param p_attribute14 Descriptive flexfield column
* @param p_attribute15 Descriptive flexfield column
* @param p_NETWORK_ITEM_ID Inventory item identifier for asset route
* @param p_NETWORK_SERIAL_NUMBER Asset route serial number
* @param p_INVENTORY_ITEM_ID Inventory item identifier for the asset group
* @param p_SERIAL_NUMBER Serial number for the asset
* @param p_NETWORK_OBJECT_TYPE Asset Route Object Type. 1 indicates serialized, 2 indicates non-serialized. Currently 1 is the only valid value
* @param p_NETWORK_OBJECT_ID Asset Route Object Identifier
* @param p_MAINTENANCE_OBJECT_TYPE Maintenance Object Type
* @param p_MAINTENANCE_OBJECT_ID Maintenance Object Identifier
 * @param p_asset_number instance number new parameter as part of Cons Asset Repository
 * @return Returns the status of the procedure call as well as the return messages
 * @rep:scope public
 * @rep:displayname Insert Asset Route

 */


PROCEDURE insert_asset_routes
(
        p_api_version       		IN	NUMBER			,
  	p_init_msg_list			IN	VARCHAR2:= FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2:= FND_API.G_FALSE	,
	p_validation_level		IN  	NUMBER  := FND_API.G_VALID_LEVEL_FULL,
	x_return_status			OUT NOCOPY VARCHAR2	 ,
	x_msg_count			OUT NOCOPY NUMBER	 ,
	x_msg_data	    		OUT NOCOPY VARCHAR2  ,

	P_ORGANIZATION_ID               IN	NUMBER		,
	P_START_DATE_ACTIVE             IN	DATE	default null,
	P_END_DATE_ACTIVE               IN	DATE	default null,
	P_ATTRIBUTE_CATEGORY            IN	VARCHAR2	default null,
	P_ATTRIBUTE1	            	IN      VARCHAR2	default null,
	P_ATTRIBUTE2	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE3	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE4	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE5	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE6	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE7	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE8	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE9	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE10	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE11	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE12	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE13	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE14	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE15	            	IN	VARCHAR2	default null,
	P_NETWORK_ITEM_ID               IN	NUMBER		,
	P_NETWORK_SERIAL_NUMBER         IN	VARCHAR2	,
	P_INVENTORY_ITEM_ID             IN	NUMBER		default null	,
	P_SERIAL_NUMBER	            	IN	VARCHAR2	default null	,
	P_NETWORK_OBJECT_TYPE           IN	NUMBER		default null	,
	P_NETWORK_OBJECT_ID             IN	NUMBER		default null	,
	P_MAINTENANCE_OBJECT_TYPE       IN	NUMBER		default null	,
	P_MAINTENANCE_OBJECT_ID         IN	NUMBER		default null	,
	P_NETWORK_ASSET_NUMBER         	IN	VARCHAR2	default null	,
	P_ASSET_NUMBER         		IN	VARCHAR2	default null
);

/*#
 * This procedure is used to update the existing records in MTL_EAM_NETWORK_ASSETS .
 * It is used to update Asset Routes.
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param p_validation_level Validation Level of the API
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages.
 * @param P_ORGANIZATION_ID Organization identifier of the asset route
* @param P_START_DATE_ACTIVE Effective start date of the member asset
* @param P_END_DATE_ACTIVE Effective end date of the member asset
* @param p_attribute_category Attribute Category
* @param p_attribute1 Descriptive flexfield column
* @param p_attribute2 Descriptive flexfield column
* @param p_attribute3 Descriptive flexfield column
* @param p_attribute4 Descriptive flexfield column
* @param p_attribute5 Descriptive flexfield column
* @param p_attribute6 Descriptive flexfield column
* @param p_attribute7 Descriptive flexfield column
* @param p_attribute8 Descriptive flexfield column
* @param p_attribute9 Descriptive flexfield column
* @param p_attribute10 Descriptive flexfield column
* @param p_attribute11 Descriptive flexfield column
* @param p_attribute12 Descriptive flexfield column
* @param p_attribute13 Descriptive flexfield column
* @param p_attribute14 Descriptive flexfield column
* @param p_attribute15 Descriptive flexfield column
* @param p_NETWORK_ITEM_ID Inventory item identifier for asset route
* @param p_NETWORK_SERIAL_NUMBER Asset route serial number
* @param p_INVENTORY_ITEM_ID Inventory item identifier for the asset group
* @param p_SERIAL_NUMBER Serial number for the asset
* @param P_NETWORK_ASSOCIATION_ID Primary key, association ID
* @param p_NETWORK_OBJECT_TYPE Asset Route Object Type. 1 indicates serialized, 2 indicates non-serialized. Currently 1 is the only valid value
* @param p_NETWORK_OBJECT_ID Asset Route Object Identifier
* @param p_MAINTENANCE_OBJECT_TYPE Maintenance Object Type
* @param p_MAINTENANCE_OBJECT_ID Maintenance Object Identifier
 * @return Returns the status of the procedure call as well as the return messages
 * @rep:scope public
 * @rep:displayname Update Asset Route
 */

PROCEDURE update_asset_routes
(
        p_api_version       		IN	NUMBER			,
  	p_init_msg_list			IN	VARCHAR2:= FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2:= FND_API.G_FALSE	,
	p_validation_level		IN  	NUMBER  := FND_API.G_VALID_LEVEL_FULL,
	x_return_status			OUT NOCOPY VARCHAR2	 ,
	x_msg_count			OUT NOCOPY NUMBER	 ,
	x_msg_data	    		OUT NOCOPY VARCHAR2  ,

	P_ORGANIZATION_ID               IN	NUMBER		,
	P_START_DATE_ACTIVE             IN	DATE	default null,
	P_END_DATE_ACTIVE               IN	DATE	default null,
	P_ATTRIBUTE_CATEGORY            IN	VARCHAR2	default null,
	P_ATTRIBUTE1	            	IN      VARCHAR2	default null,
	P_ATTRIBUTE2	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE3	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE4	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE5	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE6	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE7	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE8	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE9	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE10	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE11	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE12	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE13	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE14	            	IN	VARCHAR2	default null,
	P_ATTRIBUTE15	            	IN	VARCHAR2	default null,
	P_NETWORK_ITEM_ID               IN	NUMBER		,
	P_NETWORK_SERIAL_NUMBER         IN	VARCHAR2		,
	P_INVENTORY_ITEM_ID             IN	NUMBER		default null,
	P_SERIAL_NUMBER	            	IN	VARCHAR2	default null	,
	P_NETWORK_ASSOCIATION_ID        IN	NUMBER		,
	P_NETWORK_OBJECT_TYPE           IN	NUMBER	default null	,
	P_NETWORK_OBJECT_ID             IN	NUMBER	default null	,
	P_MAINTENANCE_OBJECT_TYPE       IN	NUMBER	default null	,
	P_MAINTENANCE_OBJECT_ID         IN	NUMBER	default null	,
	P_NETWORK_ASSET_NUMBER         	IN	VARCHAR2	default null	,
	P_ASSET_NUMBER         		IN	VARCHAR2	default null
);

END;

 

/
