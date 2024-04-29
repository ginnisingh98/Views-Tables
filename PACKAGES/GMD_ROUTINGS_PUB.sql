--------------------------------------------------------
--  DDL for Package GMD_ROUTINGS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_ROUTINGS_PUB" AUTHID CURRENT_USER AS
/* $Header: GMDPROUS.pls 120.1.12010000.1 2008/07/24 09:57:14 appldev ship $ */
/*#
 * This interface is used to insert, update, delete and undelete routings
 * This package defines and implements the procedures and datatypes
 * required to insert/update/delete/undelete routings .
 * @rep:scope public
 * @rep:product GMD
 * @rep:lifecycle active
 * @rep:displayname Routings Public package
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GMD_ROUTING
 */

  m_api_version   CONSTANT NUMBER         := 1;
  m_pkg_name      CONSTANT VARCHAR2 (30)  := 'GMD_ROUTINGS_PUB';

  TYPE gmd_routings_step_tab IS TABLE OF fm_rout_dtl%ROWTYPE
       INDEX BY BINARY_INTEGER;

  TYPE gmd_routings_step_dep_tab IS TABLE OF fm_rout_dep%ROWTYPE
       INDEX BY BINARY_INTEGER;

  /* define record and table type to specify the column that needs to
     updated */
  TYPE update_table_rec_type IS RECORD
  (
   p_col_to_update	VARCHAR2(240)
  ,p_value		VARCHAR2(240)
  );

  TYPE update_tbl_type IS TABLE OF update_table_rec_type INDEX BY BINARY_INTEGER;

/*#
 * Insert routings
 * This is a PL/SQL procedure is responsible for inserting new routings
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_routings Row type of GMD_ROUTINGS table
 * @param p_routings_step_tbl Table structure of Routings Step details table
 * @param p_routings_step_dep_tbl Table structure of Routings Step dependency table
 * @param x_message_count Number of msg's on message stack
 * @param x_message_list Message list
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Insert Routing procedure
 * @rep:compatibility S
 */
  PROCEDURE insert_routing
  ( p_api_version            IN   NUMBER	                   :=  1
  , p_init_msg_list          IN   BOOLEAN	                   :=  TRUE
  , p_commit		     IN   BOOLEAN	                   :=  FALSE
  , p_routings               IN   gmd_routings%ROWTYPE
  , p_routings_step_tbl      IN   GMD_ROUTINGS_PUB.gmd_routings_step_tab
  , p_routings_step_dep_tbl  IN   GMD_ROUTINGS_PUB.gmd_routings_step_dep_tab
  , x_message_count          OUT NOCOPY  NUMBER
  , x_message_list           OUT NOCOPY  VARCHAR2
  , x_return_status          OUT NOCOPY  VARCHAR2
  );

/*#
 * Update routings
 * This is a PL/SQL procedure is responsible for updating routings
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_routing_id Routing ID
 * @param p_routing_no Routing Number
 * @param p_routing_vers Routing Version
 * @param p_update_table Table structure containing column and table to be updated
 * @param x_message_count Number of msg's on message stack
 * @param x_message_list Message list
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Routing procedure
 * @rep:compatibility S
 */
  PROCEDURE update_routing
  ( p_api_version 	IN 	NUMBER 			        := 1
  , p_init_msg_list 	IN 	BOOLEAN 			:= TRUE
  , p_commit		IN 	BOOLEAN 			:= FALSE
  , p_routing_id	IN	gmd_routings.routing_id%TYPE    := NULL
  , p_routing_no	IN	gmd_routings.routing_no%TYPE    := NULL
  , p_routing_vers	IN	gmd_routings.routing_vers%TYPE  := NULL
  , p_update_table	IN	update_tbl_type
  , x_message_count 	OUT NOCOPY 	NUMBER
  , x_message_list 	OUT NOCOPY 	VARCHAR2
  , x_return_status	OUT NOCOPY 	VARCHAR2
  );

/*#
 * Delete routings
 * This is a PL/SQL procedure is responsible for deleting routings
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_routing_id Routing ID
 * @param p_routing_no Routing Number
 * @param p_routing_vers Routing Version
 * @param x_message_count Number of msg's on message stack
 * @param x_message_list Message list
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Routing procedure
 * @rep:compatibility S
 */
  PROCEDURE delete_routing
  ( p_api_version 	IN 	NUMBER 			        := 1
  , p_init_msg_list 	IN 	BOOLEAN 			:= TRUE
  , p_commit		IN 	BOOLEAN 			:= FALSE
  , p_routing_id	IN	gmd_routings.routing_id%TYPE    := NULL
  , p_routing_no	IN	gmd_routings.routing_no%TYPE    := NULL
  , p_routing_vers	IN	gmd_routings.routing_vers%TYPE  := NULL
  , x_message_count 	OUT NOCOPY 	NUMBER
  , x_message_list 	OUT NOCOPY 	VARCHAR2
  , x_return_status	OUT NOCOPY 	VARCHAR2
  );

/*#
 * Undelete routings
 * This is a PL/SQL procedure is responsible for undeleting a deleted routing
 * after validation to see if deleted routing exists in Database
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_routing_id Routing ID
 * @param p_routing_no Routing Number
 * @param p_routing_vers Routing Version
 * @param x_message_count Number of msg's on message stack
 * @param x_message_list Message list
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Routing procedure
 * @rep:compatibility S
 */
  PROCEDURE undelete_routing
  ( p_api_version 	IN 	NUMBER 			        := 1
  , p_init_msg_list 	IN 	BOOLEAN 			:= TRUE
  , p_commit		IN 	BOOLEAN 			:= FALSE
  , p_routing_id	IN	gmd_routings.routing_id%TYPE    := NULL
  , p_routing_no	IN	gmd_routings.routing_no%TYPE    := NULL
  , p_routing_vers	IN	gmd_routings.routing_vers%TYPE  := NULL
  , x_message_count 	OUT NOCOPY 	NUMBER
  , x_message_list 	OUT NOCOPY 	VARCHAR2
  , x_return_status	OUT NOCOPY 	VARCHAR2
  );


END GMD_ROUTINGS_PUB;

/
