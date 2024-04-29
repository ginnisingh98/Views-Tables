--------------------------------------------------------
--  DDL for Package WIP_EAM_WORKREQUEST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_EAM_WORKREQUEST_PUB" AUTHID CURRENT_USER AS
/* $Header: WIPPWRPS.pls 120.0 2005/05/24 18:19:40 appldev noship $ */
/*#
 * This package is used for importing the Work Requests.
 * This is actually a public script to create and update work request with validations.
 * It defines 1 key procedure work_request_import
 * which first validates and massages the IN parameters
 * and then carries out the respective operations.
 * @rep:scope public
 * @rep:product EAM
 * @rep:lifecycle active
 * @rep:displayname Work Request Import
 * @rep:category BUSINESS_ENTITY EAM_WORK_REQUEST
 */

 -- Start of comments
 -- API name : WIP_EAM_WORKREQUEST_PUB
 -- Type     : Public
 -- Function :
 -- Pre-reqs : None.
 -- Parameters  :
 -- IN       p_api_version IN NUMBER   Required
 --          p_init_msg_list IN VARCHAR2    Optional
 --             Default = FND_API.G_FALSE
 --          p_commit IN VARCHAR2 Optional
 --             Default = FND_API.G_FALSE
 --          p_validation_level IN NUMBER   Optional
 --             Default = FND_API.G_VALID_LEVEL_FULL
 --          p_work_request_record_type IN record
 -- OUT      x_return_status   OUT   VARCHAR2(1)
 --          x_msg_count       OUT   NUMBER
 --          x_msg_data        OUT   VARCHAR2(2000)
 --
 -- Version  Current version 115.0
 --
 -- Notes    : public script to create and update work request with validations
 --
 -- End of comments

/*#
 * This procedure creates or updates the work request based on the parameter p_mode
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param p_validation_level Validation Level of the API
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages.
 * @param p_mode The flag indicating the operation is CREATE or UPDATE
* @param p_work_request_rec This is a PL QL record type, it is a ROWTYPE of WIP_EAM_WORK_REQUESTS table
* @param p_request_log This is a reqest log for the current work request, if this is null, it is same as the work request description
* @param p_user_id The user who creates / updates the work request
* @param x_work_request_id This is the unique identifier of newly created work request record.
 * @return Returns the unique identifier of newly created record and status of the procedure call as well as the return messages
 * @scope public
 * @rep:displayname Create / Update Work Request
 */

procedure work_request_import
(
p_api_version in NUMBER := 1.0,
p_init_msg_list in VARCHAR2 := FND_API.G_FALSE,
p_commit in VARCHAR2 := FND_API.G_TRUE,
p_validation_level in NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_mode in VARCHAR2,
p_work_request_rec in WIP_EAM_WORK_REQUESTS%ROWTYPE,
p_request_log in VARCHAR2,
p_user_id in NUMBER,
x_work_request_id out NOCOPY NUMBER,
x_return_status out NOCOPY VARCHAR2,
x_msg_count out NOCOPY NUMBER,
x_msg_data out NOCOPY VARCHAR2
);

end WIP_EAM_WORKREQUEST_PUB;

 

/
