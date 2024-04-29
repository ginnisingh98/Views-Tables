--------------------------------------------------------
--  DDL for Package GMD_OPERATION_ACTIVITIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_OPERATION_ACTIVITIES_PUB" AUTHID CURRENT_USER AS
/*  $Header: GMDPOPAS.pls 120.2 2006/10/03 18:10:56 rajreddy noship $ */
/*#
 * This interface is used to create, update and delete operation activities.
 * This package defines and implements the procedures and datatypes
 * required to create, update and delete operation activities.
 * @rep:scope public
 * @rep:product GMD
 * @rep:lifecycle active
 * @rep:displayname Operation Activity package
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GMD_OPERATION
 */


TYPE gmd_oprn_activities_tbl_type IS TABLE OF gmd_operation_activities%ROWTYPE
       INDEX BY BINARY_INTEGER;

TYPE update_table_rec_type IS RECORD
(
 p_col_to_update		VARCHAR2(30)
, p_value			VARCHAR2(240)
);

TYPE update_tbl_type IS TABLE OF update_table_rec_type INDEX BY BINARY_INTEGER;

/*#
 * Insert a new Operation Activity
 * This is a PL/SQL procedure to insert a new Operation Activity
 * Call is made to insert_operation_activity API of GMD_OPERATION_ACTIVITIES_PVT package
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_oprn_no Operation Number
 * @param p_oprn_vers Operation Version
 * @param p_oprn_activity Rowtype of Operation activities table
 * @param p_oprn_rsrc_tbl Table structure of Operation resources table
 * @param x_message_count Number of msg's on message stack
 * @param x_message_list Message list
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Insert Operation Activity procedure
 * @rep:compatibility S
 */
PROCEDURE insert_operation_activity
( p_api_version 		IN 	NUMBER 				DEFAULT 1
, p_init_msg_list	 	IN 	BOOLEAN 			DEFAULT TRUE
, p_commit		IN 	BOOLEAN 			DEFAULT FALSE
, p_oprn_no		IN	gmd_operations.oprn_no%TYPE            	DEFAULT  NULL
, p_oprn_vers		IN	gmd_operations.oprn_vers%TYPE         	DEFAULT  NULL
, p_oprn_activity		IN OUT NOCOPY 	gmd_operation_activities%ROWTYPE
, p_oprn_rsrc_tbl		IN 	gmd_operation_resources_pub.gmd_oprn_resources_tbl_type
, x_message_count 		OUT NOCOPY  	NUMBER
, x_message_list 		OUT NOCOPY  	VARCHAR2
, x_return_status		OUT NOCOPY  	VARCHAR2
);

/*#
 * Update an Operation Activity
 * This is a PL/SQL procedure to update an Operation Activity
 * Call is made to update_operation_activity API of GMD_OPERATION_ACTIVITIES_PVT package
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_oprn_line_id Operation Line ID
 * @param p_update_table Table structure containing column and table to be updated
 * @param x_message_count Number of msg's on message stack
 * @param x_message_list Message list
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Operation Activity procedure
 * @rep:compatibility S
 */
PROCEDURE update_operation_activity
( p_api_version 		IN 	NUMBER 				DEFAULT 1
, p_init_msg_list 		IN 	BOOLEAN 			DEFAULT TRUE
, p_commit		IN 	BOOLEAN 			DEFAULT FALSE
, p_oprn_line_id		IN	gmd_operation_activities.oprn_line_id%TYPE
, p_update_table		IN	gmd_operation_activities_pub.update_tbl_type
, x_message_count 		OUT NOCOPY  	NUMBER
, x_message_list 		OUT NOCOPY  	VARCHAR2
, x_return_status		OUT NOCOPY  	VARCHAR2
);


/*#
 * Delete an Operation Activity
 * This is a PL/SQL procedure to delete an Operation Activity
 * Call is made to delete_operation_activity API of GMD_OPERATION_ACTIVITIES_PVT package
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_oprn_line_id Operation Line ID
 * @param x_message_count Number of msg's on message stack
 * @param x_message_list Message list
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Operation Activity procedure
 * @rep:compatibility S
 */
PROCEDURE delete_operation_activity
( p_api_version 		IN 	NUMBER 				DEFAULT  1
, p_init_msg_list	 	IN 	BOOLEAN 			DEFAULT   TRUE
, p_commit		IN 	BOOLEAN 			DEFAULT  FALSE
, p_oprn_line_id		IN	gmd_operation_activities.oprn_line_id%TYPE
, x_message_count 		OUT NOCOPY  	NUMBER
, x_message_list 		OUT NOCOPY  	VARCHAR2
, x_return_status		OUT NOCOPY  	VARCHAR2
);


END GMD_OPERATION_ACTIVITIES_PUB;

 

/
