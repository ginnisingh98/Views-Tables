--------------------------------------------------------
--  DDL for Package EAM_SETNAME_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_SETNAME_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPPSNS.pls 120.1 2006/03/21 15:42:37 hkarmach noship $ */
/*#
 * This package is used for the INSERT / UPDATE of PM Set Names.
 * It defines 2 key procedures insert_pmsetname, update_pmsetname
 * which first validates and massages the IN parameters
 * and then carries out the respective operations.
 * @rep:scope public
 * @rep:product EAM
 * @rep:lifecycle active
 * @rep:displayname Preventive Maintenance Set Name
 * @rep:category BUSINESS_ENTITY EAM_SET_NAME
 */

/*
--      API name        : EAM_SetName_PUB
--      Type            : Public
--      Function        : Insert, update and validation of the pm set name
--      Pre-reqs        : None.
*/
	G_PKG_NAME 	CONSTANT VARCHAR2(30):='EAM_SetName_PUB';
/*
This procedure inserts a record in the eam_pm_set_names table
--      Parameters      :
--      IN              :       P_API_VERSION	IN NUMBER	REQUIRED
--                              P_INIT_MSG_LIST IN VARCHAR2	OPTIONAL
--                                      DEFAULT = FND_API.G_FALSE
--                              P_COMMIT	IN VARCHAR2	OPTIONAL
--                                      DEFAULT = FND_API.G_FALSE
--                              P_VALIDATION_LEVEL IN NUMBER	OPTIONAL
--                                      DEFAULT = FND_API.G_VALID_LEVEL_FULL
--				p_set_name              IN    varchar2 ,
--				p_description	      IN    varchar2 DEFAULT NULL,
--				p_end_date	      IN    date DEFAULT NULL    ,
--				p_ATTRIBUTE_CATEGORY    IN    VARCHAR2 DEFAULT NULL,
--				p_ATTRIBUTE1            IN    VARCHAR2 DEFAULT NULL,
--				p_ATTRIBUTE2            IN    VARCHAR2 DEFAULT NULL,
--				p_ATTRIBUTE3            IN    VARCHAR2 DEFAULT NULL,
--				p_ATTRIBUTE4            IN    VARCHAR2 DEFAULT NULL,
--				p_ATTRIBUTE5            IN    VARCHAR2 DEFAULT NULL,
--				p_ATTRIBUTE6            IN    VARCHAR2 DEFAULT NULL,
--				p_ATTRIBUTE7            IN    VARCHAR2 DEFAULT NULL,
--				p_ATTRIBUTE8            IN    VARCHAR2 DEFAULT NULL,
--				p_ATTRIBUTE9            IN    VARCHAR2 DEFAULT NULL,
--				p_ATTRIBUTE10           IN    VARCHAR2 DEFAULT NULL,
--				p_ATTRIBUTE11           IN    VARCHAR2 DEFAULT NULL,
--				p_ATTRIBUTE12           IN    VARCHAR2 DEFAULT NULL,
--				p_ATTRIBUTE13           IN    VARCHAR2 DEFAULT NULL,
--				p_ATTRIBUTE14           IN    VARCHAR2 DEFAULT NULL,
--				p_ATTRIBUTE15           IN    VARCHAR2 DEFAULT NULL,
--				p_end_date_val_req      IN    BOOLEAN  default true ,
--
--      OUT             :       x_return_status    OUT NOCOPY    VARCHAR2(1)
--                              x_msg_count        OUT NOCOPY    NUMBER
--                              x_msg_data         OUT NOCOPY    VARCHAR2 (2000)
--				x_new_set_name_id	OUT	NOCOPY	NUMBER
--      Version :       Current version: 1.0
--                      Initial version: 1.0
--
--      NOTE: p_end_date_validate flag will be false in case of migration, meaning no end date validation required for
--		migration. If the flag is true, only in that case the Validate_FutureEndDate function will be called.
*/

/*#
 * This procedure is used to insert records in EAM_PM_SET_NAMES.
 * It is used to create Preventive Maintenance Set Names.
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param p_validation_level Validation Level of the API
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages.
 * @param p_set_name Set name
* @param p_description Description text
* @param p_end_date Effective end date of the Preventive Maintenance set
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
* @param p_organization_id Owning Organization
* @param p_local_flag Flag to indicate whether the set name is org specific
* @param x_new_set_name_id Set name identifier of newly created record
* @param p_end_date_val_req Flag indicating whether the end date validation required of this record
 * @return Returns the status of the procedure call as well as the return messages
 * @rep:scope public
 * @rep:displayname Create PM Set Names
 */

PROCEDURE Insert_PMSetName
(
	p_api_version		IN	NUMBER			,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level	IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	NOCOPY VARCHAR2	,
	x_msg_count		OUT	NOCOPY NUMBER	,
	x_msg_data		OUT	NOCOPY VARCHAR2	,
	p_set_name              IN    VARCHAR2 ,
	p_description		IN    VARCHAR2 DEFAULT NULL,
	p_end_date		IN    DATE DEFAULT NULL    ,
	p_attribute_category    IN    VARCHAR2 DEFAULT NULL,
	p_attribute1            IN    VARCHAR2 DEFAULT NULL,
	p_attribute2            IN    VARCHAR2 DEFAULT NULL,
	p_attribute3            IN    VARCHAR2 DEFAULT NULL,
	p_attribute4            IN    VARCHAR2 DEFAULT NULL,
	p_attribute5            IN    VARCHAR2 DEFAULT NULL,
	p_attribute6            IN    VARCHAR2 DEFAULT NULL,
	p_attribute7            IN    VARCHAR2 DEFAULT NULL,
	p_attribute8            IN    VARCHAR2 DEFAULT NULL,
	p_attribute9            IN    VARCHAR2 DEFAULT NULL,
	p_attribute10           IN    VARCHAR2 DEFAULT NULL,
	p_attribute11           IN    VARCHAR2 DEFAULT NULL,
	p_attribute12           IN    VARCHAR2 DEFAULT NULL,
	p_attribute13           IN    VARCHAR2 DEFAULT NULL,
	p_attribute14           IN    VARCHAR2 DEFAULT NULL,
	p_attribute15           IN    VARCHAR2 DEFAULT NULL,
	p_organization_id       IN    number default null,
	p_local_flag	        IN    VARCHAR2 default 'N',
	x_new_set_name_id	OUT   NOCOPY	NUMBER,
	p_end_date_val_req      IN    varchar2  DEFAULT 'true'
);


/*
This procedure updates a record in the eam_pm_set_names table
--      Parameters      :
--      IN              :       p_api_version	IN NUMBER	REQUIRED
--                              P_INIT_MSG_LIST IN VARCHAR2	OPTIONAL
--                                      DEFAULT = FND_API.G_FALSE
--                              P_COMMIT	IN VARCHAR2	OPTIONAL
--                                      DEFAULT = FND_API.G_FALSE
--                              P_VALIDATION_LEVEL IN NUMBER	OPTIONAL
--                                      DEFAULT = FND_API.G_VALID_LEVEL_FULL
--				p_set_name_id          IN    NUMBER   ,
--				p_set_name             IN    VARCHAR2 ,
--				p_description	     IN    VARCHAR2 DEFAULT NULL,
--				p_end_date	     IN    DATE DEFAULT NULL    ,
--				p_ATTRIBUTE_CATEGORY   IN    VARCHAR2 DEFAULT NULL,
--				p_ATTRIBUTE1           IN    VARCHAR2 DEFAULT NULL,
--				p_ATTRIBUTE2           IN    VARCHAR2 DEFAULT NULL,
--				p_ATTRIBUTE3           IN    VARCHAR2 DEFAULT NULL,
--				p_ATTRIBUTE4           IN    VARCHAR2 DEFAULT NULL,
--				p_ATTRIBUTE5           IN    VARCHAR2 DEFAULT NULL,
--				p_ATTRIBUTE6           IN    VARCHAR2 DEFAULT NULL,
--				p_ATTRIBUTE7           IN    VARCHAR2 DEFAULT NULL,
--				p_ATTRIBUTE8           IN    VARCHAR2 DEFAULT NULL,
--				p_ATTRIBUTE9           IN    VARCHAR2 DEFAULT NULL,
--				p_ATTRIBUTE10          IN    VARCHAR2 DEFAULT NULL,
--			        p_ATTRIBUTE11          IN    VARCHAR2 DEFAULT NULL,
--				p_ATTRIBUTE12          IN    VARCHAR2 DEFAULT NULL,
--				p_ATTRIBUTE13          IN    VARCHAR2 DEFAULT NULL,
--				p_ATTRIBUTE14          IN    VARCHAR2 DEFAULT NULL,
--				p_ATTRIBUTE15          IN    VARCHAR2 DEFAULT NULL,
--				p_end_date_val_req     IN    BOOLEAN  default true
--
--
--      OUT             :       x_return_status    OUT NOCOPY    VARCHAR2(1)
--                              x_msg_count        OUT NOCOPY    NUMBER
--                              x_msg_data         OUT NOCOPY    VARCHAR2 (2000)
--      Version :       Current version: 1.0
--                      Initial version: 1.0
--
--      NOTE: p_end_date_validate flag will be false in case of migration, meaning no end date validation required for
--		migration. If the flag is true, only in that case the Validate_FutureEndDate function will be called.
*/

/*#
 * This procedure is used to update the existing records in EAM_PM_SET_NAMES.
 * It is used to update Preventive Maintenance Set Names.
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param p_validation_level Validation Level of the API
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages.
 * @param p_set_name_id Set name identifier
 * @param p_set_name Set name
* @param p_description Description text
* @param p_end_date Effective end date of the Preventive Maintenance set
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
* @param p_organization_id Owning Organization
* @param p_local_flag Flag to indicate whether the set name is org specific
* @param p_end_date_val_req Flag indicating whether the end date validation required of this record
 * @return Returns the status of the procedure call as well as the return messages
 * @rep:scope public
 * @rep:displayname Update PM Set Names
 */

PROCEDURE Update_PMSetName
(
	p_api_version		IN	  NUMBER			,
	p_init_msg_list		IN	  VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  	  VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level	IN  	  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	NOCOPY  VARCHAR2 ,
	x_msg_count		OUT	NOCOPY  NUMBER	  ,
	x_msg_data		OUT	NOCOPY  VARCHAR2 ,
	p_set_name_id		IN    NUMBER   ,
	p_set_name		IN    VARCHAR2 ,
	p_description		IN    VARCHAR2 DEFAULT NULL,
	p_end_date		IN    DATE DEFAULT NULL    ,
	p_attribute_category    IN    VARCHAR2 DEFAULT NULL,
	p_attribute1            IN    VARCHAR2 DEFAULT NULL,
	p_attribute2            IN    VARCHAR2 DEFAULT NULL,
	p_attribute3            IN    VARCHAR2 DEFAULT NULL,
	p_attribute4            IN    VARCHAR2 DEFAULT NULL,
	p_attribute5            IN    VARCHAR2 DEFAULT NULL,
	p_attribute6            IN    VARCHAR2 DEFAULT NULL,
	p_attribute7            IN    VARCHAR2 DEFAULT NULL,
	p_attribute8            IN    VARCHAR2 DEFAULT NULL,
	p_attribute9            IN    VARCHAR2 DEFAULT NULL,
	p_attribute10           IN    VARCHAR2 DEFAULT NULL,
	p_attribute11           IN    VARCHAR2 DEFAULT NULL,
	p_attribute12           IN    VARCHAR2 DEFAULT NULL,
	p_attribute13           IN    VARCHAR2 DEFAULT NULL,
	p_attribute14           IN    VARCHAR2 DEFAULT NULL,
	p_attribute15           IN    VARCHAR2 DEFAULT NULL,
	p_organization_id       IN    number default null,
	p_local_flag	        IN    VARCHAR2 default 'N',
	p_end_date_val_req	IN    varchar2  default 'true'
);




FUNCTION Validate_SetName (p_set_name_id NUMBER, p_set_name varchar2)
	return boolean;

FUNCTION Validate_SetNameUnique
	(p_set_name VARCHAR2)
	return boolean;

FUNCTION Validate_FutureEndDate
	(p_end_date DATE)
	return boolean;

PROCEDURE RAISE_ERROR (ERROR VARCHAR2);
PROCEDURE PRINT_LOG(info varchar2);

END EAM_SetName_PUB;

 

/
