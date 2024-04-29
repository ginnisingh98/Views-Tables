--------------------------------------------------------
--  DDL for Package GMD_OPERATION_RESOURCES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_OPERATION_RESOURCES_PUB" AUTHID CURRENT_USER AS
/*  $Header: GMDPOPRS.pls 120.1.12010000.1 2008/07/24 09:56:44 appldev ship $ */
/*#
 * This interface is used to create, update and delete operation resources.
 * This package defines and implements the procedures and datatypes
 * required to create, update and delete operation resources.
 * @rep:scope public
 * @rep:product GMD
 * @rep:lifecycle active
 * @rep:displayname Operation Resources package
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GMD_OPERATION
 */

TYPE resources_rec_type IS RECORD
(
  OPRN_LINE_ID                    gmd_operation_resources.oprn_line_id%TYPE
 ,RESOURCES                       gmd_operation_resources.resources%TYPE
 ,RESOURCE_USAGE                  gmd_operation_resources.resource_usage%TYPE
 ,RESOURCE_COUNT                  gmd_operation_resources.resource_count%TYPE		DEFAULT 1
 ,RESOURCE_USAGE_UOM                        gmd_operation_resources.usage_um%TYPE
 ,PROCESS_QTY                     gmd_operation_resources.process_qty%TYPE
 ,RESOURCE_PROCESS_UOM                     gmd_operation_resources.process_uom%TYPE
 ,PRIM_RSRC_IND                   gmd_operation_resources.prim_rsrc_ind%TYPE
 ,SCALE_TYPE                      gmd_operation_resources.scale_type%TYPE        		DEFAULT 1
 ,COST_ANALYSIS_CODE              gmd_operation_resources.cost_analysis_code%TYPE
 ,COST_CMPNTCLS_ID                gmd_operation_resources.cost_cmpntcls_id%TYPE
 ,OFFSET_INTERVAL                 gmd_operation_resources.offset_interval%TYPE		DEFAULT 0
 ,MIN_CAPACITY                      gmd_operation_resources.min_capacity%TYPE
 ,MAX_CAPACITY                      gmd_operation_resources.max_capacity%TYPE
 ,RESOURCE_CAPACITY_UOM                      gmd_operation_resources.capacity_uom%TYPE
 ,ATTRIBUTE_CATEGORY                gmd_operation_resources.attribute_category%TYPE
 ,ATTRIBUTE1                        gmd_operation_resources.attribute1%TYPE
 ,ATTRIBUTE2                        gmd_operation_resources.attribute2%TYPE
 ,ATTRIBUTE3                        gmd_operation_resources.attribute3%TYPE
 ,ATTRIBUTE4                        gmd_operation_resources.attribute4%TYPE
 ,ATTRIBUTE5                        gmd_operation_resources.attribute5%TYPE
 ,ATTRIBUTE6                        gmd_operation_resources.attribute6%TYPE
 ,ATTRIBUTE7                        gmd_operation_resources.attribute7%TYPE
 ,ATTRIBUTE8                        gmd_operation_resources.attribute8%TYPE
 ,ATTRIBUTE9                        gmd_operation_resources.attribute9%TYPE
 ,ATTRIBUTE10                       gmd_operation_resources.attribute10%TYPE
 ,ATTRIBUTE11                       gmd_operation_resources.attribute11%TYPE
 ,ATTRIBUTE12                       gmd_operation_resources.attribute12%TYPE
 ,ATTRIBUTE13                       gmd_operation_resources.attribute13%TYPE
 ,ATTRIBUTE14                       gmd_operation_resources.attribute14%TYPE
 ,ATTRIBUTE15                       gmd_operation_resources.attribute15%TYPE
 ,ATTRIBUTE16                       gmd_operation_resources.attribute16%TYPE
 ,ATTRIBUTE17                       gmd_operation_resources.attribute17%TYPE
 ,ATTRIBUTE18                       gmd_operation_resources.attribute18%TYPE
 ,ATTRIBUTE19                       gmd_operation_resources.attribute19%TYPE
 ,ATTRIBUTE20                       gmd_operation_resources.attribute20%TYPE
 ,ATTRIBUTE21                       gmd_operation_resources.attribute21%TYPE
 ,ATTRIBUTE22                       gmd_operation_resources.attribute22%TYPE
 ,ATTRIBUTE23                       gmd_operation_resources.attribute23%TYPE
 ,ATTRIBUTE24                       gmd_operation_resources.attribute24%TYPE
 ,ATTRIBUTE25                       gmd_operation_resources.attribute25%TYPE
 ,ATTRIBUTE26                       gmd_operation_resources.attribute26%TYPE
 ,ATTRIBUTE27                       gmd_operation_resources.attribute27%TYPE
 ,ATTRIBUTE28                       gmd_operation_resources.attribute28%TYPE
 ,ATTRIBUTE29                       gmd_operation_resources.attribute29%TYPE
 ,ATTRIBUTE30                       gmd_operation_resources.attribute30%TYPE
 ,PROCESS_PARAMETER_1               gmd_operation_resources.process_parameter_1%TYPE
 ,PROCESS_PARAMETER_2               gmd_operation_resources.process_parameter_2%TYPE
 ,PROCESS_PARAMETER_3               gmd_operation_resources.process_parameter_3%TYPE
 ,PROCESS_PARAMETER_4               gmd_operation_resources.process_parameter_4%TYPE
 ,PROCESS_PARAMETER_5               gmd_operation_resources.process_parameter_5%TYPE
 ,ACTIVITY                          gmd_operation_activities.activity%TYPE --added w.r.t. bug 3408799
);

TYPE gmd_oprn_resources_tbl_type IS TABLE OF resources_rec_type INDEX BY BINARY_INTEGER;


TYPE update_table_rec_type IS RECORD
(
 p_col_to_update	VARCHAR2(30)
, p_value		VARCHAR2(30)
);

TYPE update_tbl_type IS TABLE OF update_table_rec_type INDEX BY BINARY_INTEGER;

/*#
 * Insert a new Operation Resource
 * This is a PL/SQL procedure to insert a new Operation Resource
 * Call is made to insert_operation_resources API of GMD_OPERATION_RESOURCES_PVT package
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_oprn_line_id Operation Line ID
 * @param p_oprn_rsrc_tbl Table structure of Operation resources table
 * @param x_message_count Number of msg's on message stack
 * @param x_message_list Message list
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Insert Operation Resource procedure
 * @rep:compatibility S
 */
PROCEDURE insert_operation_resources
( p_api_version 		IN 	NUMBER 				DEFAULT 1
, p_init_msg_list	 	IN 	BOOLEAN 			DEFAULT TRUE
, p_commit		IN 	BOOLEAN 			DEFAULT FALSE
, p_oprn_line_id		IN	gmd_operation_activities.oprn_line_id%TYPE
, p_oprn_rsrc_tbl		IN 	gmd_operation_resources_pub.gmd_oprn_resources_tbl_type
, x_message_count 		OUT NOCOPY  	NUMBER
, x_message_list 		OUT NOCOPY  	VARCHAR2
, x_return_status		OUT NOCOPY  	VARCHAR2
);

/*#
 * Update an Operation Resource
 * This is a PL/SQL procedure to update an Operation Resource
 * Call is made to update_operation_resources API of GMD_OPERATION_RESOURCES_PVT package
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_oprn_line_id Operation Line ID
 * @param p_resources Field to pass resources
 * @param p_update_table Table structure containing column and table to be updated
 * @param x_message_count Number of msg's on message stack
 * @param x_message_list Message list
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Operation Resource procedure
 * @rep:compatibility S
 */
PROCEDURE update_operation_resources
( p_api_version 		IN 	NUMBER 				DEFAULT 1
, p_init_msg_list 		IN 	BOOLEAN 			DEFAULT TRUE
, p_commit			IN 	BOOLEAN 			DEFAULT FALSE
, p_oprn_line_id		IN	gmd_operation_resources.oprn_line_id%TYPE
, p_resources			IN	gmd_operation_resources.resources%TYPE
, p_update_table		IN	gmd_operation_resources_pub.update_tbl_type
, x_message_count 		OUT NOCOPY  	NUMBER
, x_message_list 		OUT NOCOPY  	VARCHAR2
, x_return_status		OUT NOCOPY  	VARCHAR2
);

/*#
 * Delete an Operation Resource
 * This is a PL/SQL procedure to delete an Operation Resource
 * Call is made to delete_operation_resources API of GMD_OPERATION_RESOURCES_PVT package
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_oprn_line_id Operation Line ID
 * @param p_resources Field to pass resources
 * @param x_message_count Number of msg's on message stack
 * @param x_message_list Message list
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Operation Resource procedure
 * @rep:compatibility S
 */
PROCEDURE delete_operation_resources
( p_api_version 		IN 	NUMBER 				DEFAULT 1
, p_init_msg_list 		IN 	BOOLEAN 			DEFAULT TRUE
, p_commit		IN 	BOOLEAN 			DEFAULT FALSE
, p_oprn_line_id		IN	gmd_operation_resources.oprn_line_id%TYPE
, p_resources		IN 	gmd_operation_resources.resources%TYPE
, x_message_count 		OUT NOCOPY  	NUMBER
, x_message_list 		OUT NOCOPY  	VARCHAR2
, x_return_status		OUT NOCOPY  	VARCHAR2
);

END GMD_OPERATION_RESOURCES_PUB;

/
