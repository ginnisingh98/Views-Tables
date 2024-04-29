--------------------------------------------------------
--  DDL for Package EAM_DEPT_APPROVERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_DEPT_APPROVERS_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPDAPS.pls 120.0 2005/05/27 15:01:21 appldev noship $ */
/*#
 * This package is used for the INSERT / UPDATE of Department Approvers.
 * It defines 2 key procedures insert_dept_appr, update_dept_appr
 * which first validates and massages the IN parameters
 * and then carries out the respective operations.
 * @rep:scope public
 * @rep:product EAM
 * @rep:lifecycle active
 * @rep:displayname  Department Approvers
 * @rep:category BUSINESS_ENTITY EAM_DEPARTMENT_APPROVER
 */


/*#
 * This procedure is used to insert records in BOM_EAM_DEPT_APPROVERS.
 * It is used to create Department Approvers.
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param p_validation_level Validation Level of the API
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages.
 * @param p_dept_id Department Identifier
 * @param p_organization_id Organization Identifier
 * @param p_resp_app_id Internal identifier of the appliation with which the responsibility is tied to
 * @param p_responsibility_id Internal identifier of the responsibility associated with a department
 * @param p_primary_approver_id Internal Identifier of the primary approver for the current department
 * @return Returns the status of the procedure call as well as the return messages
 * @rep:scope public
 * @rep:displayname Insert Department Approvers
 */


PROCEDURE insert_dept_appr
(
	p_api_version           	IN	NUMBER				,
  	p_init_msg_list			IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level		IN 	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,

	x_return_status			OUT NOCOPY VARCHAR2		  	,
	x_msg_count			OUT NOCOPY NUMBER				,
	x_msg_data			OUT NOCOPY VARCHAR2			,

	p_dept_id			IN 	NUMBER,
	p_organization_id       	IN 	NUMBER,
	p_resp_app_id 			IN 	NUMBER,
	p_responsibility_id		IN 	NUMBER,
	p_primary_approver_id  		IN 	NUMBER
);

/**
 * This procedure is used to update the existing records in BOM_EAM_DEPT_APPROVERS.
 * It is used to update Department Approvers.
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param p_validation_level Validation Level of the API
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages.
  * @param p_dept_id Department Identifier
 * @param p_organization_id Organization Identifier
 * @param p_resp_app_id Internal identifier of the appliation with which the responsibility is tied to
 * @param p_responsibility_id Internal identifier of the responsibility associated with a department
 * @param p_primary_approver_id Internal Identifier of the primary approver for the current department
 * @return Returns the status of the procedure call as well as the return messages
 * @rep:scope public
 * @rep:displayname Update Department Approvers
 */

PROCEDURE update_dept_appr
(
	p_api_version           	IN	NUMBER				,
  	p_init_msg_list			IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level		IN 	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,

	x_return_status			OUT NOCOPY VARCHAR2		  	,
	x_msg_count			OUT NOCOPY NUMBER				,
	x_msg_data			OUT NOCOPY VARCHAR2			,

	p_dept_id			IN 	NUMBER,
	p_organization_id       	IN 	NUMBER,
	p_resp_app_id			IN 	NUMBER,
	p_responsibility_id		IN 	NUMBER,
	p_primary_approver_id  		IN 	NUMBER
);

END;

 

/
