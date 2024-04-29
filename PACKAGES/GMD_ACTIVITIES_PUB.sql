--------------------------------------------------------
--  DDL for Package GMD_ACTIVITIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_ACTIVITIES_PUB" AUTHID CURRENT_USER AS
/*  $Header: GMDPACTS.pls 115.4 2004/04/16 14:35:33 srsriran noship $ */
/*#
 * This interface is used to create, update and delete Activities.
 * This package defines and implements the procedures and datatypes
 * required to create, update and delete Activities.
 * @rep:scope public
 * @rep:product GMD
 * @rep:lifecycle active
 * @rep:displayname Activities package
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GMD_ACTIVITIES_PUB
 */


TYPE activities_rec_type IS RECORD
(
   ACTIVITY                     gmd_activities.activity%type
  ,COST_ANALYSIS_CODE           gmd_activities.cost_analysis_code%type
  ,DELETE_MARK                  gmd_activities.delete_mark%type   DEFAULT  0
  ,TEXT_CODE                    gmd_activities.text_code%type
  ,TRANS_CNT                    gmd_activities.trans_cnt%type
  ,ACTIVITY_DESC                gmd_activities.activity_desc%type

);


TYPE gmd_activities_tbl_type IS TABLE OF activities_rec_type INDEX BY BINARY_INTEGER;


 TYPE update_table_rec_type IS RECORD
(
  p_col_to_update       VARCHAR2(80)
, p_value               VARCHAR2(80)

);


TYPE update_tbl_type IS TABLE OF update_table_rec_type INDEX BY BINARY_INTEGER;

/*#
 * Insert a new Activity
 * This is a PL/SQL procedure to insert a new Activity
 * Call is made to insert_activity API of GMD_ACTIVITIES_PVT package
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_activity_tbl Table structure of Activities table
 * @param x_message_count Number of msg's on message stack
 * @param x_message_list Message list
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Insert Activity procedure
 * @rep:compatibility S
 */
PROCEDURE insert_activity
(
  p_api_version 		IN 	NUMBER	DEFAULT	   1
, p_init_msg_list 		IN 	BOOLEAN	DEFAULT	  TRUE
, p_commit		        IN 	BOOLEAN	DEFAULT   FALSE
 , p_activity_tbl		IN 	gmd_activities_pub.gmd_activities_tbl_type
 , x_message_count	 	OUT NOCOPY  	NUMBER
, x_message_list 		OUT NOCOPY  	VARCHAR2
, x_return_status		OUT NOCOPY  	VARCHAR2
);

/*#
 * Update an Activity
 * This is a PL/SQL procedure to update an Activity
 * Call is made to update_activity API of GMD_ACTIVITIES_PVT package
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_activity Field to pass activities
 * @param p_update_table Table structure containing column and table to be updated
 * @param x_message_count Number of msg's on message stack
 * @param x_message_list Message list
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Activity procedure
 * @rep:compatibility S
 */
PROCEDURE update_activity
(
  p_api_version 		IN 	NUMBER		DEFAULT 1
, p_init_msg_list 		IN 	BOOLEAN 	DEFAULT TRUE
, p_commit		IN 	BOOLEAN 	DEFAULT FALSE
, p_activity			IN 	gmd_activities.activity%TYPE
, p_update_table		IN	gmd_activities_pub.update_tbl_type
, x_message_count 		OUT NOCOPY  	NUMBER
, x_message_list 		OUT NOCOPY  	VARCHAR2
, x_return_status		OUT NOCOPY  	VARCHAR2
);

/*#
 * Delete an Activity
 * This is a PL/SQL procedure to delete an Activity
 * Call is made to delete_activity API of GMD_ACTIVITIES_PVT package
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_activity Field to pass activities
 * @param x_message_count Number of msg's on message stack
 * @param x_message_list Message list
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Activity procedure
 * @rep:compatibility S
 */
 PROCEDURE delete_activity (
  p_api_version 		IN 	NUMBER		DEFAULT  1
, p_init_msg_list 		IN 	BOOLEAN	DEFAULT  TRUE
, p_commit			IN 	BOOLEAN	DEFAULT  FALSE
, p_activity			IN 	gmd_activities.activity%TYPE
, x_message_count 		OUT NOCOPY  	NUMBER
, x_message_list 		OUT NOCOPY  	VARCHAR2
, x_return_status		OUT NOCOPY  	VARCHAR2
);

END GMD_ACTIVITIES_PUB;

 

/
