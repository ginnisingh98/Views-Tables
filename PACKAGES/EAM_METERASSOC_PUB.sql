--------------------------------------------------------
--  DDL for Package EAM_METERASSOC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_METERASSOC_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPAMAS.pls 120.2 2006/02/17 15:33:04 hkarmach noship $ */
/*#
 * This package is used for the INSERT of Asset Meters Association.
 * It defines a key procedure Insert_AssetMeterAssoc
 * which first validates and massages the IN parameters
 * and then carries out the insert. This API do not support update.
 * @rep:scope public
 * @rep:product EAM
 * @rep:lifecycle active
 * @rep:displayname  Asset Meter
 * @rep:category BUSINESS_ENTITY EAM_ASSET_METER
 */

G_PKG_NAME 	CONSTANT VARCHAR2(30):='EAM_MeterAssoc_PUB';


/*#
 * This procedure is used to create Asset Meter Association.
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param p_validation_level Validation Level of the API
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages.
  * @param p_meter_id Meter Identifier
* @param p_organization_id Organization Identifier of Asset Group
* @param p_asset_group_id Asset Group Identifier
* @param p_asset_number Asset Number
* @param p_maintenance_object_type Maintenance Object Type
* @param p_maintenance_object_id Maitenance Object Identifier
* @param p_attribute_category Descriptive Flexfield Column
* @param p_attribute1 Descriptive Flexfield Column
* @param p_attribute2 Descriptive Flexfield Column
* @param p_attribute3 Descriptive Flexfield Column
* @param p_attribute4 Descriptive Flexfield Column
* @param p_attribute5 Descriptive Flexfield Column
* @param p_attribute6 Descriptive Flexfield Column
* @param p_attribute7 Descriptive Flexfield Column
* @param p_attribute8 Descriptive Flexfield Column
* @param p_attribute9 Descriptive Flexfield Column
* @param p_attribute10 Descriptive Flexfield Column
* @param p_attribute11 Descriptive Flexfield Column
* @param p_attribute12 Descriptive Flexfield Column
* @param p_attribute13 Descriptive Flexfield Column
* @param p_attribute14 Descriptive Flexfield Column
* @param p_attribute15 Descriptive Flexfield Column
* @param p_start_date_active Start Date Active for the association
* @param p_end_date_active  End Date Active for the association
 * @return Returns the status of the procedure call as well as the return messages
 * @rep:scope public
 * @rep:displayname Insert Asset Meter Associations
 */


PROCEDURE Insert_AssetMeterAssoc
(
	p_api_version		           IN	          Number,
	p_init_msg_list		         IN	          VARCHAR2 := FND_API.G_FALSE,
	p_commit	    	           IN  	        VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	       IN  	        NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		         OUT	NOCOPY  VARCHAR2,
	x_msg_count		             OUT	NOCOPY  Number,
	x_msg_data		             OUT	NOCOPY  VARCHAR2,
	p_meter_id		             IN	          Number,
	p_organization_id	         IN	          NUMBER DEFAULT NULL,
	p_asset_group_id	         IN	          NUMBER DEFAULT NULL,
	p_asset_number		         IN	          VARCHAR2 DEFAULT NULL,
	p_maintenance_object_type  IN	          NUMBER  DEFAULT NULL,
	p_maintenance_object_id	   IN	          NUMBER  DEFAULT NULL,
	p_primary_failure_flag	   IN	          VARCHAR2  DEFAULT 'N',
  p_ATTRIBUTE_CATEGORY       IN           VARCHAR2 default null,
  p_ATTRIBUTE1               IN           VARCHAR2 default null,
  p_ATTRIBUTE2               IN           VARCHAR2 default null,
  p_ATTRIBUTE3               IN           VARCHAR2 default null,
  p_ATTRIBUTE4               IN           VARCHAR2 default null,
  p_ATTRIBUTE5               IN           VARCHAR2 default null,
  p_ATTRIBUTE6               IN           VARCHAR2 default null,
  p_ATTRIBUTE7               IN           VARCHAR2 default null,
  p_ATTRIBUTE8               IN           VARCHAR2 default null,
  p_ATTRIBUTE9               IN           VARCHAR2 default null,
  p_ATTRIBUTE10              IN           VARCHAR2 default null,
  p_ATTRIBUTE11              IN           VARCHAR2 default null,
  p_ATTRIBUTE12              IN           VARCHAR2 default null,
  p_ATTRIBUTE13              IN           VARCHAR2 default null,
  p_ATTRIBUTE14              IN           VARCHAR2 default null,
  p_ATTRIBUTE15              IN           VARCHAR2 default null,
  p_start_date_active        IN           DATE default NULL,
  p_end_date_active          IN           DATE default null
);



/*#
 * This procedure is used to update Asset Meter Association.
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param p_validation_level Validation Level of the API
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages.
 * @param p_association_id The Association Id that has to be updated
* @param p_attribute_category Descriptive Flexfield Column
* @param p_attribute1 Descriptive Flexfield Column
* @param p_attribute2 Descriptive Flexfield Column
* @param p_attribute3 Descriptive Flexfield Column
* @param p_attribute4 Descriptive Flexfield Column
* @param p_attribute5 Descriptive Flexfield Column
* @param p_attribute6 Descriptive Flexfield Column
* @param p_attribute7 Descriptive Flexfield Column
* @param p_attribute8 Descriptive Flexfield Column
* @param p_attribute9 Descriptive Flexfield Column
* @param p_attribute10 Descriptive Flexfield Column
* @param p_attribute11 Descriptive Flexfield Column
* @param p_attribute12 Descriptive Flexfield Column
* @param p_attribute13 Descriptive Flexfield Column
* @param p_attribute14 Descriptive Flexfield Column
* @param p_attribute15 Descriptive Flexfield Column
 * @param p_end_date_active End Date Active
 * @param p_tmpl_flag  Flag indicating whether the association is for a template meter or not
 * @return Returns the status of the procedure call as well as the return messages
 * @rep:scope public
 * @rep:displayname Update Asset Meter Associations
 */

PROCEDURE Update_AssetMeterAssoc
(
	p_api_version		           IN	          Number,
	p_init_msg_list		         IN	          VARCHAR2 := FND_API.G_FALSE,
	p_commit	    	           IN  	        VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	       IN  	        NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		         OUT	NOCOPY  VARCHAR2,
	x_msg_count		             OUT	NOCOPY  Number,
	x_msg_data		             OUT	NOCOPY  VARCHAR2,
  p_association_id           IN           Number,
  p_primary_failure_flag	   IN	          VARCHAR2  DEFAULT 'N',
  p_ATTRIBUTE_CATEGORY       IN           VARCHAR2 default null,
  p_ATTRIBUTE1               IN           VARCHAR2 default null,
  p_ATTRIBUTE2               IN           VARCHAR2 default null,
  p_ATTRIBUTE3               IN           VARCHAR2 default null,
  p_ATTRIBUTE4               IN           VARCHAR2 default null,
  p_ATTRIBUTE5               IN           VARCHAR2 default null,
  p_ATTRIBUTE6               IN           VARCHAR2 default null,
  p_ATTRIBUTE7               IN           VARCHAR2 default null,
  p_ATTRIBUTE8               IN           VARCHAR2 default null,
  p_ATTRIBUTE9               IN           VARCHAR2 default null,
  p_ATTRIBUTE10              IN           VARCHAR2 default null,
  p_ATTRIBUTE11              IN           VARCHAR2 default null,
  p_ATTRIBUTE12              IN           VARCHAR2 default null,
  p_ATTRIBUTE13              IN           VARCHAR2 default null,
  p_ATTRIBUTE14              IN           VARCHAR2 default null,
  p_ATTRIBUTE15              IN           VARCHAR2 default null,
  p_end_date_active          IN           DATE     DEFAULT NULL,
  p_tmpl_flag                IN           VARCHAR2 DEFAULT 'N'
);



PROCEDURE RAISE_ERROR (ERROR VARCHAR2);

END EAM_MeterAssoc_PUB;

 

/
