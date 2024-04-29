--------------------------------------------------------
--  DDL for Package EAM_ITEM_ACTIVITIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ITEM_ACTIVITIES_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPIAAS.pls 120.0 2005/05/25 15:44:59 appldev noship $ */
/*#
 * This package is used for the INSERT / UPDATE of Asset Activity association.
 * It defines 2 key procedures insert_item_activities, update_item_activities
 * which first validates and massages the IN parameters
 * and then carries out the respective operations.
 * @rep:scope public
 * @rep:product EAM
 * @rep:lifecycle active
 * @rep:displayname Asset Activity
 * @rep:category BUSINESS_ENTITY EAM_ASSET_ACTIVITY_ASSOCIATION
 */


/*#
 * This procedure is used to insert records in MTL_EAM_ASSET_ACTIVITIES .
 * It is used to create asset activity association.
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param p_validation_level Validation Level of the API
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages.
 * @param P_ASSET_ACTIVITY_ID Asset Activity identifier
* @param P_INVENTORY_ITEM_ID Inventory Item identifier of the asset group
* @param P_ORGANIZATION_ID EAM Organization Identifier
 * @param P_OWNINGDEPARTMENT_ID Asset owning department identifier
 * @param P_MAINTENANCE_OBJECT_ID  Maintenance Object Identifier
 * @param P_CREATION_ORGANIZATION_ID Creation Organization identifier
 * @param P_START_DATE_ACTIVE Effective start date of the association
 * @param P_END_DATE_ACTIVE Effective end date of the association
 * @param P_PRIORITY_CODE Prority Of the asset activity
 * @param P_ACTIVITY_CAUSE_CODE Cause code for asset activity
 * @param P_ACTIVITY_TYPE_CODE Type of asset activity
 * @param P_SHUTDOWN_TYPE_CODE Asset shutdown type code
 * @param P_MAINTENANCE_OBJECT_TYPE Maintenance Object Type
 * @param P_TMPL_FLAG Flag indicating whether this record is a template associaiton
 * @param P_CLASS_CODE Accounting class code for asset activity association
 * @param P_ACTIVITY_SOURCE_CODE Activity Source
 * @param P_SERIAL_NUMBER Asset Number
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
 * @param P_TAGGING_REQUIRED_FLAG Flag indicating whether tag out required for this  activity
 * @param P_LAST_SERVICE_START_DATE The start date when the activity was last performed
 * @param P_LAST_SERVICE_END_DATE The end date when the activity was last performed
 * @param P_PREV_SERVICE_START_DATE Start date when activity was performed prior to last service
 * @param P_PREV_SERVICE_END_DATE End date when activity was performed prior to last service
 * @param P_LAST_SCHEDULED_START_DATE The start date when the activity was last scheduled
 * @param P_LAST_SCHEDULED_END_DATE The end date when the activity was last scheduled
 * @param P_PREV_SCHEDULED_START_DATE Start date when activity was scheduled prior to last service
 * @param P_PREV_SCHEDULED_END_DATE End date when activity was scheduled prior to last service
 * @param P_WIP_ENTITY_ID Work Order Identifier
 * @param P_SOURCE_TMPL_ID Asset Activity Template Identifier from which this association is created
 * @param p_pm_last_service_tbl PL SQL table type of last service associated with this asset  activity combination
 * @return Returns the status of the procedure call as well as the return messages
 * @rep:scope public
 * @rep:displayname Create Asset Activity Association
 */

PROCEDURE insert_item_activities
(
        p_api_version       		IN	NUMBER			,
  	p_init_msg_list			IN	VARCHAR2:= FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2:= FND_API.G_FALSE	,
	p_validation_level		IN  	NUMBER  := FND_API.G_VALID_LEVEL_FULL,
	x_return_status			OUT NOCOPY VARCHAR2	 ,
	x_msg_count			OUT NOCOPY NUMBER	 ,
	x_msg_data	    		OUT NOCOPY VARCHAR2  ,

	P_ASSET_ACTIVITY_ID		IN	NUMBER	,
	/*P_INVENTORY_ITEM_ID		IN	NUMBER	,*/
	P_INVENTORY_ITEM_ID		IN	NUMBER	default null,
	P_ORGANIZATION_ID		IN	NUMBER	default null,
	P_OWNINGDEPARTMENT_ID		IN	NUMBER	default null,
	P_MAINTENANCE_OBJECT_ID		IN	NUMBER default null,
	P_CREATION_ORGANIZATION_ID	IN	NUMBER 	default null,
	P_START_DATE_ACTIVE		IN	DATE default null	,
	P_END_DATE_ACTIVE		IN	DATE default null	,
	P_PRIORITY_CODE			IN	VARCHAR2 default null	,
	P_ACTIVITY_CAUSE_CODE		IN	VARCHAR2 default null,
	P_ACTIVITY_TYPE_CODE		IN	VARCHAR2 default null	,
	P_SHUTDOWN_TYPE_CODE		IN	VARCHAR2 default null	,
	P_MAINTENANCE_OBJECT_TYPE	IN	NUMBER default null	,
	P_TMPL_FLAG			IN	VARCHAR2 default null	,
	P_CLASS_CODE			IN	VARCHAR2 default null,
	P_ACTIVITY_SOURCE_CODE		IN	VARCHAR2 default null,
	P_SERIAL_NUMBER			IN	VARCHAR2 default null	,
	P_ATTRIBUTE_CATEGORY		IN	VARCHAR2 default null	,
	P_ATTRIBUTE1			IN	VARCHAR2 default null	,
	P_ATTRIBUTE2			IN	VARCHAR2 default null	,
	P_ATTRIBUTE3			IN	VARCHAR2 default null	,
	P_ATTRIBUTE4			IN	VARCHAR2 default null	,
	P_ATTRIBUTE5			IN	VARCHAR2 default null	,
	P_ATTRIBUTE6			IN	VARCHAR2 default null	,
	P_ATTRIBUTE7			IN	VARCHAR2 default null	,
	P_ATTRIBUTE8			IN	VARCHAR2 default null	,
	P_ATTRIBUTE9			IN	VARCHAR2 default null	,
	P_ATTRIBUTE10			IN	VARCHAR2 default null	,
	P_ATTRIBUTE11			IN	VARCHAR2 default null	,
	P_ATTRIBUTE12			IN	VARCHAR2 default null	,
	P_ATTRIBUTE13			IN	VARCHAR2 default null	,
	P_ATTRIBUTE14			IN	VARCHAR2 default null	,
	P_ATTRIBUTE15			IN	VARCHAR2 default null	,
	P_TAGGING_REQUIRED_FLAG		IN	VARCHAR2 default null	,
	P_LAST_SERVICE_START_DATE	IN	DATE default null	,
	P_LAST_SERVICE_END_DATE		IN	DATE default null	,
	P_PREV_SERVICE_START_DATE	IN	DATE default null	,
	P_PREV_SERVICE_END_DATE		IN	DATE default null	,
        P_LAST_SCHEDULED_START_DATE	IN	DATE default null	,
	P_LAST_SCHEDULED_END_DATE	IN	DATE default null	,
	P_PREV_SCHEDULED_START_DATE	IN	DATE default null	,
	P_PREV_SCHEDULED_END_DATE	IN	DATE default null	,
        P_WIP_ENTITY_ID                 IN      NUMBER default null     ,
	P_SOURCE_TMPL_ID		IN	NUMBER default null	,
	p_pm_last_service_tbl           IN      EAM_PM_LAST_SERVICE_PUB.pm_last_service_tbl


);

/*#
 * This procedure is used to update the existing records in MTL_EAM_ASSET_ACTIVITIES  .
 * It is used to update asset activity association.
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param p_validation_level Validation Level of the API
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages.
 * @param P_ACTIVITY_ASSOCIATION_ID Asset activity association identifier
* @param P_ASSET_ACTIVITY_ID Asset Activity identifier
* @param P_INVENTORY_ITEM_ID Inventory Item identifier of the asset group
* @param P_ORGANIZATION_ID EAM Organization Identifier
* @param P_OWNINGDEPARTMENT_ID Asset owning department identifier
* @param P_MAINTENANCE_OBJECT_ID  Maintenance Object Identifier
* @param P_CREATION_ORGANIZATION_ID Creation Organization Identifier
* @param P_START_DATE_ACTIVE Effective start date of the association
* @param P_END_DATE_ACTIVE Effective end date of the association
* @param P_PRIORITY_CODE Prority Of the asset activity
* @param P_ACTIVITY_CAUSE_CODE Cause code for asset activity
* @param P_ACTIVITY_TYPE_CODE Type of asset activity
* @param P_SHUTDOWN_TYPE_CODE Asset shutdown type code
* @param P_MAINTENANCE_OBJECT_TYPE Maintenance Object Type
* @param P_TMPL_FLAG Flag indicating whether this record is a template associaiton
* @param P_CLASS_CODE Accounting class code for asset activity association
* @param P_ACTIVITY_SOURCE_CODE Activity Source
* @param P_SERIAL_NUMBER Asset Number
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
* @param P_TAGGING_REQUIRED_FLAG Flag indicating whether tag out required for this activity
* @param P_LAST_SERVICE_START_DATE The start date when the activity was last performed
* @param P_LAST_SERVICE_END_DATE The end date when the activity was last performed
* @param P_PREV_SERVICE_START_DATE Start date when activity was performed prior to last service
* @param P_PREV_SERVICE_END_DATE End date when activity was performed prior to last service
* @param P_LAST_SCHEDULED_START_DATE The start date when the activity was last scheduled
* @param P_LAST_SCHEDULED_END_DATE The end date when the activity was last scheduled
* @param P_PREV_SCHEDULED_START_DATE Start date when activity was scheduled prior to last service
* @param P_PREV_SCHEDULED_END_DATE End date when activity was scheduled prior to last service
* @param P_WIP_ENTITY_ID Work Order Identifier
* @param P_SOURCE_TMPL_ID Asset Activity Template Identifier from which this association is created
* @param p_pm_last_service_tbl PL SQL table type of last service associated with this asset activity combination
 * @return Returns the status of the procedure call as well as the return messages
 * @rep:scope public
 * @rep:displayname Update Asset Activity Association
 */

PROCEDURE update_item_activities
(
        p_api_version       		IN	NUMBER			,
  	p_init_msg_list			IN	VARCHAR2:= FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2:= FND_API.G_FALSE	,
	p_validation_level		IN  	NUMBER  := FND_API.G_VALID_LEVEL_FULL,
	x_return_status			OUT NOCOPY VARCHAR2	 ,
	x_msg_count			OUT NOCOPY NUMBER	 ,
	x_msg_data	    		OUT NOCOPY VARCHAR2  ,

	P_ACTIVITY_ASSOCIATION_ID	IN	NUMBER	,
	P_ASSET_ACTIVITY_ID		IN	NUMBER	,
	P_INVENTORY_ITEM_ID		IN	NUMBER	default null,
	P_ORGANIZATION_ID		IN	NUMBER	default null,
	P_OWNINGDEPARTMENT_ID		IN	NUMBER	default null,
	P_MAINTENANCE_OBJECT_ID		IN	NUMBER default null,
	P_CREATION_ORGANIZATION_ID	IN	NUMBER default null	,
	P_START_DATE_ACTIVE		IN	DATE default null	,
	P_END_DATE_ACTIVE		IN	DATE default null	,
	P_PRIORITY_CODE			IN	VARCHAR2 default null	,
	P_ACTIVITY_CAUSE_CODE		IN	VARCHAR2 default null,
	P_ACTIVITY_TYPE_CODE		IN	VARCHAR2 default null	,
	P_SHUTDOWN_TYPE_CODE		IN	VARCHAR2 default null	,
	P_MAINTENANCE_OBJECT_TYPE	IN	NUMBER default null	,
	P_TMPL_FLAG			IN	VARCHAR2 default null	,
	P_CLASS_CODE			IN	VARCHAR2 default null,
	P_ACTIVITY_SOURCE_CODE		IN	VARCHAR2 default null,
	P_SERIAL_NUMBER			IN	VARCHAR2 default null	,
	P_ATTRIBUTE_CATEGORY		IN	VARCHAR2 default null	,
	P_ATTRIBUTE1			IN	VARCHAR2 default null	,
	P_ATTRIBUTE2			IN	VARCHAR2 default null	,
	P_ATTRIBUTE3			IN	VARCHAR2 default null	,
	P_ATTRIBUTE4			IN	VARCHAR2 default null	,
	P_ATTRIBUTE5			IN	VARCHAR2 default null	,
	P_ATTRIBUTE6			IN	VARCHAR2 default null	,
	P_ATTRIBUTE7			IN	VARCHAR2 default null	,
	P_ATTRIBUTE8			IN	VARCHAR2 default null	,
	P_ATTRIBUTE9			IN	VARCHAR2 default null	,
	P_ATTRIBUTE10			IN	VARCHAR2 default null	,
	P_ATTRIBUTE11			IN	VARCHAR2 default null	,
	P_ATTRIBUTE12			IN	VARCHAR2 default null	,
	P_ATTRIBUTE13			IN	VARCHAR2 default null	,
	P_ATTRIBUTE14			IN	VARCHAR2 default null	,
	P_ATTRIBUTE15			IN	VARCHAR2 default null	,
	P_TAGGING_REQUIRED_FLAG		IN	VARCHAR2 default null	,
	P_LAST_SERVICE_START_DATE	IN	DATE default null	,
	P_LAST_SERVICE_END_DATE		IN	DATE default null	,
	P_PREV_SERVICE_START_DATE	IN	DATE default null	,
	P_PREV_SERVICE_END_DATE		IN	DATE default null	,
	P_LAST_SCHEDULED_START_DATE	IN	DATE default null	,
	P_LAST_SCHEDULED_END_DATE	IN	DATE default null	,
	P_PREV_SCHEDULED_START_DATE	IN	DATE default null	,
	P_PREV_SCHEDULED_END_DATE	IN	DATE default null	,
        P_WIP_ENTITY_ID                 IN      NUMBER default null     ,
	P_SOURCE_TMPL_ID		IN	NUMBER default null	,
	p_pm_last_service_tbl           IN      EAM_PM_LAST_SERVICE_PUB.pm_last_service_tbl

);

END;

 

/
