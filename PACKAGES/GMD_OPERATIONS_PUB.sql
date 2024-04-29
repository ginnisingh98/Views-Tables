--------------------------------------------------------
--  DDL for Package GMD_OPERATIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_OPERATIONS_PUB" AUTHID CURRENT_USER AS
/*  $Header: GMDPOPSS.pls 120.1 2006/10/03 18:11:45 rajreddy noship $ */
/*#
 * This interface is used to create, update and delete operations.
 * This package defines and implements the procedures and datatypes
 * required to create, update and delete operations.
 * @rep:scope public
 * @rep:product GMD
 * @rep:lifecycle active
 * @rep:displayname Operations Public package
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GMD_OPERATION
 */

 /*
 +=========================================================================+
 | FILENAME                                                                |
 |     GMDPOPSS.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains public definitions for  			   |
 |     creating, modifying, deleting opeations                                            |
 |                                                                         |
 | HISTORY                                                                 |
 |     22-JUNE-2002  Sandra Dulyk    Created                               |
 |     10-MAR-2004   kkillams       New p_oprn_rsrc_tbl input paramter is  |
 |                                  added to proceudre to pass the resource|
 |                                  details for activities w.r.t.          |
 |                                  bug# 3408799                           |
 +=========================================================================+
  API Name  : GMD_OPERATIONS_PUB
  Type      : Public
  Function  : This package contains public procedures used to create, modify, and delete operations
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

  Previous Vers : 1.0

  Initial Vers  : 1.0
  Notes
*/

TYPE gmd_oprn_activities_tbl_type IS TABLE OF gmd_operation_activities%ROWTYPE
       INDEX BY BINARY_INTEGER;


TYPE update_table_rec_type IS RECORD
(
 p_col_to_update	VARCHAR2(30)
, p_value		VARCHAR2(30)
);

TYPE update_tbl_type IS TABLE OF update_table_rec_type INDEX BY BINARY_INTEGER;

/*#
 * Insert a new Operation
 * This is a PL/SQL procedure to insert a new Operation in Operations Table
 * Call is made to insert_operation API of GMD_OPERATIONS_PVT package
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_operations Row type of Operations table
 * @param p_oprn_actv_tbl Table structure of Operation activities table
 * @param x_message_count Number of msg's on message stack
 * @param x_message_list Message list
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param p_oprn_rsrc_tbl Table structure of Operation Resource Table
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Insert Operation procedure
 * @rep:compatibility S
 */
PROCEDURE insert_operation
( p_api_version                 IN  NUMBER                  DEFAULT 1
, p_init_msg_list               IN  BOOLEAN                 DEFAULT TRUE
, p_commit                      IN  BOOLEAN                 DEFAULT  FALSE
, p_operations                  IN  OUT NOCOPY              gmd_operations%ROWTYPE
, p_oprn_actv_tbl               IN  OUT NOCOPY              gmd_operations_pub.gmd_oprn_activities_tbl_type
, x_message_count               OUT NOCOPY      NUMBER
, x_message_list                OUT NOCOPY      VARCHAR2
, x_return_status               OUT NOCOPY      VARCHAR2
, p_oprn_rsrc_tbl               IN  gmd_operation_resources_pub.gmd_oprn_resources_tbl_type --Added w.r.t. bug 3408799
);

/*#
 * Update an Operation
 * This is a PL/SQL procedure to update an Operation in Operations Table
 * Call is made to update_operation API of GMD_OPERATIONS_PVT package
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_oprn_id Operation ID
 * @param p_oprn_no Operation Number
 * @param p_oprn_vers Operation Version
 * @param p_update_table Table structure containing column and table to be updated
 * @param x_message_count Number of msg's on message stack
 * @param x_message_list Message list
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Operation procedure
 * @rep:compatibility S
 */
PROCEDURE update_operation
( p_api_version 		IN 	NUMBER 				DEFAULT  1
, p_init_msg_list 		IN 	BOOLEAN 			DEFAULT TRUE
, p_commit		IN 	BOOLEAN 			DEFAULT FALSE
, p_oprn_id		IN	gmd_operations.oprn_id%TYPE   	DEFAULT NULL
, p_oprn_no		IN	gmd_operations.oprn_no%TYPE   	DEFAULT NULL
, p_oprn_vers		IN	gmd_operations.oprn_vers%TYPE   	DEFAULT  NULL
, p_update_table		IN	gmd_operations_pub.update_tbl_type
, x_message_count 		OUT NOCOPY  	NUMBER
, x_message_list 		OUT NOCOPY  	VARCHAR2
, x_return_status		OUT NOCOPY  	VARCHAR2
);

/*#
 * Delete an Operation
 * This is a PL/SQL procedure to delete an Operation in Operations Table
 * Call is made to delete_operation API of GMD_OPERATIONS_PVT package
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_oprn_id Operation ID
 * @param p_oprn_no Operation Number
 * @param p_oprn_vers Operation Version
 * @param x_message_count Number of msg's on message stack
 * @param x_message_list Message list
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Operation procedure
 * @rep:compatibility S
 */
PROCEDURE delete_operation
( p_api_version 		IN 	NUMBER 				DEFAULT  1
, p_init_msg_list	 	IN 	BOOLEAN 			DEFAULT   TRUE
, p_commit		IN 	BOOLEAN 			DEFAULT    FALSE
, p_oprn_id		IN	gmd_operations.oprn_id%TYPE      	DEFAULT   NULL
, p_oprn_no		IN	gmd_operations.oprn_no%TYPE      	DEFAULT  NULL
, p_oprn_vers		IN	gmd_operations.oprn_vers%TYPE   	DEFAULT  NULL
, x_message_count 		OUT NOCOPY  	NUMBER
, x_message_list 		OUT NOCOPY  	VARCHAR2
, x_return_status		OUT NOCOPY  	VARCHAR2
);

END GMD_OPERATIONS_PUB;

 

/
