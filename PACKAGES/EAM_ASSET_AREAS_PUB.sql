--------------------------------------------------------
--  DDL for Package EAM_ASSET_AREAS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ASSET_AREAS_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPASAS.pls 120.0 2005/05/25 09:19:30 appldev noship $ */
/*#
 * This package is used for the INSERT / UPDATE of asset areas.
 * It defines 2 key procedures insert_asset_areas, update_asset_areas
 * which first validates and massages the IN parameters
 * and then carries out the respective operations.
 * @rep:scope public
 * @rep:product EAM
 * @rep:lifecycle active
 * @rep:displayname Asset Areas
 * @rep:category BUSINESS_ENTITY EAM_ASSET_AREA
 */

-- Start of comments
--	API name 	: EAM_ASSET_AREAS_PUB
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
 * This procedure is used to insert records in MTL_EAM_LOCATIONS.
 * It is used to create Asset Areas.
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param p_validation_level Validation Level of the API
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages.
 * @param p_location_codes Asset Area Code
* @param p_start_date Effective start date of the area
* @param p_end_date Effective end date of the area
* @param p_organization_id Organization identifier of the Area
* @param p_description Description of the Area
* @param p_creation_organization_id Creation Organization Identifier
 * @return Returns the status of the procedure call as well as the return messages
 * @rep:scope public
 * @rep:displayname Insert Asset Area
 */


PROCEDURE insert_asset_areas
(
	p_api_version           	IN	NUMBER				,
  	p_init_msg_list			IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level		IN 	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,

	x_return_status			OUT NOCOPY VARCHAR2		  	,
	x_msg_count			OUT NOCOPY NUMBER				,
	x_msg_data			OUT NOCOPY VARCHAR2			,

	p_location_codes	        IN 	varchar2,
	p_start_date	        	IN 	date:=null,
	p_end_date		        IN 	date:=null,
	p_organization_id	        IN 	number,
	p_description	        	IN 	varchar2:=null,
	p_creation_organization_id	IN      number
);

/*#
 * This procedure is used to update the existing records in MTL_EAM_LOCATIONS .
 * It is used to update Asset Areas.
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param p_validation_level Validation Level of the API
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages.
 * @param p_location_id Primary Key of the asset location
 * @param p_location_codes Asset Area Code
* @param p_start_date Effective start date of the area
* @param p_end_date Effective end date of the area
* @param p_organization_id Organization identifier of the Area
* @param p_description Description of the Area
* @param p_creation_organization_id Creation Organization Identifier
 * @return Returns the status of the procedure call as well as the return messages
 * @rep:scope public
 * @rep:displayname Update Asset Area
 */

PROCEDURE update_asset_areas
(
	p_api_version           	IN	NUMBER				,
  	p_init_msg_list			IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level		IN 	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,

	x_return_status			OUT NOCOPY VARCHAR2		  	,
	x_msg_count			OUT NOCOPY NUMBER				,
	x_msg_data			OUT NOCOPY VARCHAR2			,

	p_location_id	        	IN 	number,
	p_location_codes	        IN 	varchar2,
	p_start_date	        	IN 	date:=null,
	p_end_date		        IN 	date:=null,
	p_organization_id	        IN 	number,
	p_description	        	IN 	varchar2:=null,
	p_creation_organization_id	IN      number
);

END;

 

/
