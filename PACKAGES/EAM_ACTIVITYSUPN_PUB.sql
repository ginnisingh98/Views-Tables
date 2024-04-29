--------------------------------------------------------
--  DDL for Package EAM_ACTIVITYSUPN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ACTIVITYSUPN_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPASRS.pls 120.0 2005/05/25 15:38:49 appldev noship $ */
/*#
 * This package is used for the INSERT / UPDATE of suppression relationships of the asset activity associations.
 * It defines 2 key procedures insert_activitysupn, update_activitysupn
 * which first validates and massages the IN parameters
 * and then carries out the respective operations.
 * @rep:scope public
 * @rep:product EAM
 * @rep:lifecycle active
 * @rep:displayname Activity Suppression
 * @rep:category BUSINESS_ENTITY EAM_ASSET_ACTIVITY_SUPPRESSION
 */


	G_PKG_NAME 	CONSTANT VARCHAR2(30):='EAM_ActivitySupn_PUB';


/*#
 * This procedure is used to insert records in EAM_SUPPRESSION_RELATIONS.
 * It is used to create Activity Suppression.
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param p_validation_level Validation Level of the API
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages.
* @param p_parent_association_id Parent (suppressing) Activity Association Identifier
* @param p_child_association_id Child (suppressed) Activity Association Identifier
* @param p_tmpl_flag Flag indicating suppression of type template
* @param p_description Description text
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
 * @return Returns the status of the procedure call as well as the return messages
 * @rep:scope public
 * @rep:displayname Create Activity Suppression
 */

PROCEDURE Insert_ActivitySupn
(
	p_api_version		IN	NUMBER			,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level	IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	NOCOPY VARCHAR2	,
	x_msg_count		OUT	NOCOPY NUMBER	,
	x_msg_data		OUT	NOCOPY VARCHAR2	,
	p_parent_association_id IN	NUMBER    ,
	p_child_association_id  IN	NUMBER    ,
	p_tmpl_flag		IN	VARCHAR2 DEFAULT NULL,
	p_description		IN	VARCHAR2 DEFAULT NULL,
	p_attribute_category    IN	VARCHAR2 DEFAULT NULL,
	p_attribute1            IN	VARCHAR2 DEFAULT NULL,
	p_attribute2            IN	VARCHAR2 DEFAULT NULL,
	p_attribute3            IN	VARCHAR2 DEFAULT NULL,
	p_attribute4            IN	VARCHAR2 DEFAULT NULL,
	p_attribute5            IN	VARCHAR2 DEFAULT NULL,
	p_attribute6            IN	VARCHAR2 DEFAULT NULL,
	p_attribute7            IN	VARCHAR2 DEFAULT NULL,
	p_attribute8            IN	VARCHAR2 DEFAULT NULL,
	p_attribute9            IN	VARCHAR2 DEFAULT NULL,
	p_attribute10           IN	VARCHAR2 DEFAULT NULL,
	p_attribute11           IN	VARCHAR2 DEFAULT NULL,
	p_attribute12           IN	VARCHAR2 DEFAULT NULL,
	p_attribute13           IN	VARCHAR2 DEFAULT NULL,
	p_attribute14           IN	VARCHAR2 DEFAULT NULL,
	p_attribute15           IN	VARCHAR2 DEFAULT NULL
);


/*#
 * This procedure is used to update the existing records in EAM_SUPPRESSION_RELATIONS .
 * It is used to update Activity Suppression.
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param p_validation_level Validation Level of the API
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages.
 * @param p_parent_association_id Parent (suppressing) Activity Association Identifier
* @param p_child_association_id Child (suppressed) Activity Association Identifier
* @param p_tmpl_flag Flag indicating suppression of type template
* @param p_description Description text
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
 * @return Returns the status of the procedure call as well as the return messages
 * @rep:scope public
 * @rep:displayname Update Activity Suppression
 */

PROCEDURE Update_ActivitySupn
(
	p_api_version		IN	NUMBER			,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level	IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	NOCOPY  VARCHAR2 ,
	x_msg_count		OUT	NOCOPY  NUMBER	  ,
	x_msg_data		OUT	NOCOPY  VARCHAR2 ,
	p_parent_association_id IN	NUMBER    ,
	p_child_association_id  IN	NUMBER    ,
	p_tmpl_flag		IN	VARCHAR2 DEFAULT NULL,
	p_description		IN	VARCHAR2 DEFAULT NULL,
	p_attribute_category	IN	VARCHAR2 DEFAULT NULL,
	p_attribute1		IN	VARCHAR2 DEFAULT NULL,
	p_attribute2		IN	VARCHAR2 DEFAULT NULL,
	p_attribute3		IN	VARCHAR2 DEFAULT NULL,
	p_attribute4		IN	VARCHAR2 DEFAULT NULL,
	p_attribute5		IN	VARCHAR2 DEFAULT NULL,
	p_attribute6		IN	VARCHAR2 DEFAULT NULL,
	p_attribute7		IN	VARCHAR2 DEFAULT NULL,
	p_attribute8		IN	VARCHAR2 DEFAULT NULL,
	p_attribute9		IN	VARCHAR2 DEFAULT NULL,
	p_attribute10		IN	VARCHAR2 DEFAULT NULL,
	p_attribute11		IN	VARCHAR2 DEFAULT NULL,
	p_attribute12		IN	VARCHAR2 DEFAULT NULL,
	p_attribute13		IN	VARCHAR2 DEFAULT NULL,
	p_attribute14		IN	VARCHAR2 DEFAULT NULL,
	p_attribute15		IN	VARCHAR2 DEFAULT NULL
);

/* EAM_ASSETATTR_GRP_PUB.VALIDATE_EAM_ENABLED (p_organization_id) */

/* EAM_ASSETATTR_GRP_PUB.VALIDATE_ITEM_ID (p_asset_group_id,p_organization_id) */

/* organization is eam enabled */
FUNCTION Validate_EamEnabled (p_organization_id NUMBER)
	RETURN boolean;


/* CHECK THE SUPPRESSION RECORD EXISTS, FOR UPDATE CASE */
FUNCTION Validate_SuppressionRecord (p_parent_association_id NUMBER,
					p_child_association_id NUMBER)
	RETURN boolean;


/* CHECK THE PARENT ASSOCIATION ID AND CHILD ASSOCIATION ID SHOULD NOT INTERCHANGE */
FUNCTION Validate_ParentChildAssets (p_parent_association_id NUMBER,
					p_child_association_id NUMBER)
	RETURN boolean;


/* For checking the association_id exists in the mtl_eam_asset_activities table */
FUNCTION Validate_AssociationId (p_association_id NUMBER)
	RETURN boolean;

/* For checking the asset/item is the same for both parent and child activity association */
FUNCTION Validate_MaintainedObjUnique (p_parent_association_id NUMBER,
					p_child_association_id number,
					p_tmpl_flag varchar2)
	RETURN boolean;

PROCEDURE RAISE_ERROR (ERROR VARCHAR2);
PROCEDURE PRINT_LOG(info varchar2);

END EAM_ActivitySupn_PUB;

 

/
