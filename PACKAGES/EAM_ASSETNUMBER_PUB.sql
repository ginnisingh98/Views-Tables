--------------------------------------------------------
--  DDL for Package EAM_ASSETNUMBER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ASSETNUMBER_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPASNS.pls 120.3 2006/09/15 12:32:24 sshahid noship $ */
/*#
 * This package is used for the INSERT / UPDATE of asset numbers.
 * It defines 2 key procedures Insert_Asset_Number, Update_Asset_Number
 * which first validates and massages the IN parameters

 * and then carries out the respective operations.
 * @rep:scope public
 * @rep:product EAM
 * @rep:lifecycle active
 * @rep:displayname Asset Number
 * @rep:category BUSINESS_ENTITY EAM_ASSET_NUMBER
 */


-- Start of comments
--	API name 	: Insert_Asset_Number
--	Type		: Public
--	Function	:
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
 * This procedure is used to insert records in CSI_ITEM_INSTANCES.
 * It is used to create Asset Numbers. This procedure also takes care of instantiation
 * of the records at the time of insert if the p_instantiate_flag parameter is passed
 * as true.
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param p_validation_level Validation Level of the API
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages.
 * @param x_object_id The new object id, primary key of new record.
 * @param p_inventory_item_id Asset Group Identifier
 * @param p_serial_number Asset Serial Number
 * @param p_instance_number Asset Number
 * @param p_current_status Current Status. 1: Defined but not used. 3: Resides in stores. 4: Issued out of stores. 5: Resides in intransit.
 * @param p_descriptive_text Asset descriptive text
 * @param p_current_organization_id Organization where the serial number is currently stored
 * @param p_attribute_category Descriptive flexfield structure defining column
 * @param p_attribute1 Descriptive flexfield segment
 * @param p_attribute2 Descriptive flexfield segment
 * @param p_attribute3 Descriptive flexfield segment
 * @param p_attribute4 Descriptive flexfield segment
 * @param p_attribute5 Descriptive flexfield segment
 * @param p_attribute6 Descriptive flexfield segment
 * @param p_attribute7 Descriptive flexfield segment
 * @param p_attribute8 Descriptive flexfield segment
 * @param p_attribute9 Descriptive flexfield segment
 * @param p_attribute10 Descriptive flexfield segment
 * @param p_attribute11 Descriptive flexfield segment
 * @param p_attribute12 Descriptive flexfield segment
 * @param p_attribute13 Descriptive flexfield segment
 * @param p_attribute14 Descriptive flexfield segment
 * @param p_attribute15 Descriptive flexfield segment
 * @param p_wip_accounting_class_code WIP Accounting class code
 * @param p_maintainable_flag Flag indicating whether the asset is maintainable
 * @param p_owning_department_id Owning Department Identifier
 * @param p_network_asset_flag Route Asset Flag
 * @param p_fa_asset_id Fixed Asset Identifier
 * @param p_pn_location_id Property Manager Location Identifier
 * @param p_eam_location_id Area Identifier
 * @param p_asset_criticality_code Asset criticality code
 * @param p_category_id Category Identifier
 * @param p_prod_organization_id Production Organization Identifier
 * @param p_equipment_item_id Equipment Item Identifier
 * @param p_eqp_serial_number Equipment serial number
 * @param p_instantiate_flag Flag to indicate if asset number instantiation setups are complete. Setup includes creation of pm definition, meter, meter association, activity association for asset number being created.
 * @param P_EAM_LINEAR_ID Linear Location Id
 * @return Returns the status of the procedure call as well as the return messages
 * @rep:scope public
 * @rep:displayname Insert Asset Number
 */

PROCEDURE Insert_Asset_Number
( 	p_api_version           IN	NUMBER				,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level	IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL	,
	x_return_status		OUT 	NOCOPY	VARCHAR2		  	,
	x_msg_count		OUT	NOCOPY	NUMBER				,
	x_msg_data		OUT	NOCOPY	VARCHAR2			,
	x_object_id		OUT	NOCOPY 	NUMBER,
	p_INVENTORY_ITEM_ID	IN 	NUMBER,
	p_SERIAL_NUMBER		IN	VARCHAR2,
	p_INSTANCE_NUMBER	IN 	VARCHAR2 DEFAULT NULL,
	--p_INITIALIZATION_DATE	IN	DATE:=NULL,  -- always use sysdate
	p_CURRENT_STATUS	IN 	NUMBER:=3,
	p_DESCRIPTIVE_TEXT		IN	VARCHAR2:=NULL,
	p_CURRENT_ORGANIZATION_ID 	IN 	NUMBER,
	p_ATTRIBUTE_CATEGORY	IN	VARCHAR2:=NULL,
	p_ATTRIBUTE1		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE2		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE3		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE4		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE5		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE6		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE7		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE8		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE9		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE10		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE11		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE12		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE13		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE14		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE15		IN	VARCHAR2:=NULL,
	P_ATTRIBUTE16                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE17                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE18                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE19                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE20                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE21                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE22                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE23                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE24                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE25                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE26                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE27                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE28                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE29                   VARCHAR2 DEFAULT NULL,
        P_ATTRIBUTE30                   VARCHAR2 DEFAULT NULL,
--	p_STATUS_ID		IN 	NUMBER:=1,
--	p_PREVIOUS_STATUS		IN 	NUMBER:=NULL,
	p_WIP_ACCOUNTING_CLASS_CODE	IN	VARCHAR2:=NULL,
	p_MAINTAINABLE_FLAG		IN	VARCHAR2:=NULL,
	p_OWNING_DEPARTMENT_ID		IN 	NUMBER,
	p_NETWORK_ASSET_FLAG		IN	VARCHAR2:=NULL,
	p_FA_ASSET_ID			IN 	NUMBER:=NULL,
	p_PN_LOCATION_ID		IN 	NUMBER:=NULL,
	p_EAM_LOCATION_ID		IN 	NUMBER:=NULL,
	p_ASSET_CRITICALITY_CODE	IN	VARCHAR2:=NULL,
	p_CATEGORY_ID			IN 	NUMBER:=NULL,
	p_PROD_ORGANIZATION_ID 		IN 	NUMBER:=NULL,
	p_EQUIPMENT_ITEM_ID		IN 	NUMBER:=NULL,
	p_EQP_SERIAL_NUMBER		IN	VARCHAR2:=NULL,
	p_EQUIPMENT_GEN_OBJECT_ID	IN 	NUMBER := NULL,
	p_instantiate_flag		IN 	BOOLEAN:=FALSE,
	p_eam_linear_id			IN	NUMBER:=NULL
	,p_active_start_date	        DATE := NULL
	,p_active_end_date	        DATE := NULL
	,p_location		        NUMBER := NULL
	,p_operational_log_flag	  	VARCHAR2 := NULL
	,p_checkin_status		NUMBER := NULL
	,p_supplier_warranty_exp_date   DATE := NULL
);

-- Start of comments
--	API name 	: Update_Asset_Number
--	Type		: Public
--	Function	:
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
 * This procedure is used to update the existing records in MTL_SERIAL_NUMBERS.
 * It is used to update Asset Numbers.
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param p_validation_level Validation Level of the API
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages.
 * @param p_inventory_item_id Asset Group Identifier
 * @param p_serial_number Asset Number
 * @param p_current_status Current Status. 1: Defined but not used. 3: Resides in stores. 4: Issued out of stores. 5: Resides in intransit.
 * @param p_descriptive_text Unit descriptive text
 * @param p_current_organization_id Organization where the serial number is currently stored
 * @param p_attribute_category Descriptive flexfield structure defining column
 * @param p_attribute1 Descriptive flexfield segment
 * @param p_attribute2 Descriptive flexfield segment
 * @param p_attribute3 Descriptive flexfield segment
 * @param p_attribute4 Descriptive flexfield segment
 * @param p_attribute5 Descriptive flexfield segment
 * @param p_attribute6 Descriptive flexfield segment
 * @param p_attribute7 Descriptive flexfield segment
 * @param p_attribute8 Descriptive flexfield segment
 * @param p_attribute9 Descriptive flexfield segment
 * @param p_attribute10 Descriptive flexfield segment
 * @param p_attribute11 Descriptive flexfield segment
 * @param p_attribute12 Descriptive flexfield segment
 * @param p_attribute13 Descriptive flexfield segment
 * @param p_attribute14 Descriptive flexfield segment
 * @param p_attribute15 Descriptive flexfield segment
 * @param p_wip_accounting_class_code WIP Accounting class code
 * @param p_maintainable_flag Flag indicating whether the asset is maintainable
 * @param p_owning_department_id Owning Department Identifier
 * @param p_network_asset_flag Route Asset Flag
 * @param p_fa_asset_id Fixed Asset Identifier
 * @param p_pn_location_id Property Manager Location Identifier
 * @param p_eam_location_id Area Identifier
 * @param p_asset_criticality_code Asset criticality code
 * @param p_category_id Category Identifier
 * @param p_prod_organization_id Production Organization Identifier
 * @param p_equipment_item_id Equipment Item Identifier
 * @param p_eqp_serial_number Equipment serial number
 * @param P_EAM_LINEAR_ID Linear Location Id
 * @return Returns the status of the procedure call as well as the return messages
 * @rep:scope public
 * @rep:displayname Update Asset Number
 */

PROCEDURE Update_Asset_Number
( 	p_api_version           IN	NUMBER				,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level	IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL	,
	x_return_status		OUT	NOCOPY	VARCHAR2		  	,
	x_msg_count		OUT	NOCOPY	NUMBER				,
	x_msg_data		OUT	NOCOPY	VARCHAR2			,
	--p_GEN_OBJECT_ID		IN  	NUMBER:=NULL,
	p_INVENTORY_ITEM_ID	IN 	NUMBER,
	p_SERIAL_NUMBER		IN	VARCHAR2,
	p_INSTANCE_NUMBER	IN 	VARCHAR2:= NULL,
	P_INSTANCE_ID		IN 	NUMBER:=NULL,
	--p_INITIALIZATION_DATE	IN	DATE:=NULL,
	p_CURRENT_STATUS	IN 	NUMBER:=3,
	p_DESCRIPTIVE_TEXT	IN	VARCHAR2:=NULL,
	p_CURRENT_ORGANIZATION_ID IN 	NUMBER,
	p_ATTRIBUTE_CATEGORY	IN	VARCHAR2:=NULL,
	p_ATTRIBUTE1		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE2		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE3		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE4		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE5		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE6		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE7		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE8		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE9		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE10		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE11		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE12		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE13		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE14		IN	VARCHAR2:=NULL,
	p_ATTRIBUTE15		IN	VARCHAR2:=NULL,
	P_ATTRIBUTE16                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE17                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE18                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE19                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE20                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE21                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE22                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE23                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE24                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE25                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE26                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE27                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE28                   VARCHAR2 DEFAULT NULL,
	P_ATTRIBUTE29                   VARCHAR2 DEFAULT NULL,
        P_ATTRIBUTE30                   VARCHAR2 DEFAULT NULL,
	--p_STATUS_ID		IN 	NUMBER:=1,
	--p_PREVIOUS_STATUS		IN 	NUMBER:=NULL,
	p_WIP_ACCOUNTING_CLASS_CODE	IN	VARCHAR2:=NULL,
	p_MAINTAINABLE_FLAG		IN	VARCHAR2:=NULL,
	p_OWNING_DEPARTMENT_ID		IN 	NUMBER,
	p_NETWORK_ASSET_FLAG		IN	VARCHAR2:=NULL,
	p_FA_ASSET_ID			IN 	NUMBER:=NULL,
	p_PN_LOCATION_ID		IN 	NUMBER:=NULL,
	p_EAM_LOCATION_ID		IN 	NUMBER:=NULL,
	p_ASSET_CRITICALITY_CODE	IN	VARCHAR2:=NULL,
	p_CATEGORY_ID			IN 	NUMBER:=NULL,
	p_PROD_ORGANIZATION_ID 		IN 	NUMBER:=NULL,
	p_EQUIPMENT_ITEM_ID		IN 	NUMBER:=NULL,
	p_EQP_SERIAL_NUMBER		IN	VARCHAR2:=NULL,
	p_EAM_LINEAR_ID			IN	NUMBER:=NULL
	,P_LOCATION_TYPE_CODE		IN	VARCHAR2:=NULL
	,P_LOCATION_ID			IN	NUMBER:=NULL
	,P_ACTIVE_END_DATE		IN 	DATE:=NULL
	,P_OPERATIONAL_LOG_FLAG	  	IN	VARCHAR2:=NULL
	,P_CHECKIN_STATUS		IN 	NUMBER:=NULL
	,P_SUPPLIER_WARRANTY_EXP_DATE	IN	DATE:=NULL
	,P_EQUIPMENT_GEN_OBJECT_ID	IN	NUMBER:=NULL
	,P_DISASSOCIATE_FA_FLAG		IN      VARCHAR2:='N'

);

function validate_fields
(
	p_CURRENT_ORGANIZATION_ID	IN	number,
	p_INVENTORY_ITEM_ID		IN	number,
	p_SERIAL_NUMBER			IN	varchar2,
        p_WIP_ACCOUNTING_CLASS_CODE     IN      VARCHAR2:=NULL,
        p_MAINTAINABLE_FLAG             IN      VARCHAR2:=NULL,
        p_OWNING_DEPARTMENT_ID          IN      NUMBER,
        p_NETWORK_ASSET_FLAG            IN      VARCHAR2:=NULL,
        p_FA_ASSET_ID                   IN      NUMBER:=NULL,
        p_PN_LOCATION_ID                IN      NUMBER:=NULL,
        p_EAM_LOCATION_ID               IN      NUMBER:=NULL,
        p_ASSET_CRITICALITY_CODE        IN      VARCHAR2:=NULL,
        p_CATEGORY_ID                   IN      NUMBER:=NULL,
        p_PROD_ORGANIZATION_ID          IN      NUMBER:=NULL,
        p_EQUIPMENT_ITEM_ID             IN      NUMBER:=NULL,
        p_EQP_SERIAL_NUMBER             IN      VARCHAR2:=NULL,
        p_ATTRIBUTE_CATEGORY    IN      VARCHAR2:=NULL,
        p_ATTRIBUTE1            IN      VARCHAR2:=NULL,
        p_ATTRIBUTE2            IN      VARCHAR2:=NULL,
        p_ATTRIBUTE3            IN      VARCHAR2:=NULL,
        p_ATTRIBUTE4            IN      VARCHAR2:=NULL,
        p_ATTRIBUTE5            IN      VARCHAR2:=NULL,
        p_ATTRIBUTE6            IN      VARCHAR2:=NULL,
        p_ATTRIBUTE7            IN      VARCHAR2:=NULL,
        p_ATTRIBUTE8            IN      VARCHAR2:=NULL,
        p_ATTRIBUTE9            IN      VARCHAR2:=NULL,
        p_ATTRIBUTE10           IN      VARCHAR2:=NULL,
        p_ATTRIBUTE11           IN      VARCHAR2:=NULL,
        p_ATTRIBUTE12           IN      VARCHAR2:=NULL,
        p_ATTRIBUTE13           IN      VARCHAR2:=NULL,
        p_ATTRIBUTE14           IN      VARCHAR2:=NULL,
        p_ATTRIBUTE15           IN      VARCHAR2:=NULL,
	p_EAM_LINEAR_ID		IN	NUMBER:= NULL,
        p_equipment_object_id	IN	NUMBER := NULL,
	p_operational_log_flag	IN      VARCHAR2 := NULL,
	p_checkin_status	IN      NUMBER := NULL,
  	p_supplier_warranty_exp_date IN     DATE := NULL,
  	x_reason_failed         OUT     NOCOPY VARCHAR2,
        x_token                 OUT     NOCOPY VARCHAR2
)
return boolean;

procedure add_error (p_error_code IN varchar2);

END eam_assetnumber_pub;

 

/
