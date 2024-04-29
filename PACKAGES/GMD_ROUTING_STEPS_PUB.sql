--------------------------------------------------------
--  DDL for Package GMD_ROUTING_STEPS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_ROUTING_STEPS_PUB" AUTHID CURRENT_USER AS
/* $Header: GMDPRTSS.pls 120.1 2006/10/03 18:14:12 rajreddy noship $ */
/*#
 * This package is used to create or modify routing steps and dependencies.
 * This package defines and implements the procedures and datatypes
 * required to create/update/delete routing steps and dependencies.
 * @rep:scope public
 * @rep:product GMD
 * @rep:lifecycle active
 * @rep:displayname Routing Steps package
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GMD_ROUTING
 */

  m_api_version   CONSTANT NUMBER         := 1;
  m_pkg_name      CONSTANT VARCHAR2 (30)  := 'GMD_ROUTING_STEPS_PUB';

/*#
 * Inserts Routing Steps
 * This is a PL/SQL procedure to insert Routing Steps in Routing details table
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_routing_id Routing ID
 * @param p_routing_no Routing Number
 * @param p_routing_vers Routing Version
 * @param p_routing_step_rec Row type of Routing details table
 * @param p_routings_step_dep_tbl Table structure of Step dependency table
 * @param x_message_count Number of msg's on message stack
 * @param x_message_list Message list
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Insert Routing Steps procedure
 * @rep:compatibility S
 */
PROCEDURE insert_routing_steps
(
  p_api_version            IN   NUMBER	                       :=  1
, p_init_msg_list          IN   BOOLEAN	                       :=  TRUE
, p_commit		   IN   BOOLEAN	                       :=  FALSE
, p_routing_id             IN   gmd_routings.routing_id%TYPE   :=  NULL
, p_routing_no             IN   gmd_routings.routing_no%TYPE   :=  NULL
, p_routing_vers           IN   gmd_routings.routing_vers%TYPE :=  NULL
, p_routing_step_rec       IN   fm_rout_dtl%ROWTYPE
, p_routings_step_dep_tbl  IN   GMD_ROUTINGS_PUB.gmd_routings_step_dep_tab
, x_message_count          OUT NOCOPY 	NUMBER
, x_message_list           OUT NOCOPY 	VARCHAR2
, x_return_status          OUT NOCOPY 	VARCHAR2
);

/*#
 * Inserts Step Dependencies
 * This is a PL/SQL procedure to insert Routing Steps dependencies in Step dependency table
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_routing_id Routing ID
 * @param p_routing_no Routing Number
 * @param p_routing_vers Version of the Routing
 * @param p_routingstep_id Routing Step ID
 * @param p_routingstep_no Routing Step Number
 * @param p_routings_step_dep_tbl Table structure of Step dependency table
 * @param x_message_count Number of msg's on message stack
 * @param x_message_list Message list
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Insert Step Dependency procedure
 * @rep:compatibility S
 */
PROCEDURE insert_step_dependencies
(
  p_api_version            IN   NUMBER	                          :=  1
, p_init_msg_list          IN   BOOLEAN	                          :=  TRUE
, p_commit		   IN   BOOLEAN	                          :=  FALSE
, p_routing_id             IN   gmd_routings.routing_id%TYPE      :=  NULL
, p_routing_no             IN   gmd_routings.routing_no%TYPE      :=  NULL
, p_routing_vers           IN   gmd_routings.routing_vers%TYPE    :=  NULL
, p_routingstep_id         IN   fm_rout_dtl.routingstep_id%TYPE   :=  NULL
, p_routingstep_no         IN   fm_rout_dtl.routingstep_no%TYPE   :=  NULL
, p_routings_step_dep_tbl  IN   GMD_ROUTINGS_PUB.gmd_routings_step_dep_tab
, x_message_count          OUT NOCOPY 	NUMBER
, x_message_list           OUT NOCOPY 	VARCHAR2
, x_return_status          OUT NOCOPY 	VARCHAR2
);

/*#
 * Updates Routing Steps
 * This is a PL/SQL procedure to update Routing Steps in Routing details table
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_routingstep_id Routing Step ID
 * @param p_routingstep_no Routing Step Number
 * @param p_routing_id Routing ID
 * @param p_routing_no Routing Number
 * @param p_routing_vers Routing version
 * @param p_update_table Table structure containing column and table to be updated
 * @param x_message_count Number of msg's on message stack
 * @param x_message_list Message list
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Routing Steps procedure
 * @rep:compatibility S
 */
PROCEDURE update_routing_steps
( p_api_version         IN 	NUMBER 			        :=  1
, p_init_msg_list 	IN 	BOOLEAN 			:=  TRUE
, p_commit		IN 	BOOLEAN 			:=  FALSE
, p_routingstep_id	IN	fm_rout_dtl.routingstep_id%TYPE :=  NULL
, p_routingstep_no	IN	fm_rout_dtl.routingstep_no%TYPE :=  NULL
, p_routing_id 		IN	gmd_routings.routing_id%TYPE 	:=  NULL
, p_routing_no		IN	gmd_routings.routing_no%TYPE    :=  NULL
, p_routing_vers 	IN	gmd_routings.routing_vers%TYPE  :=  NULL
, p_update_table	IN	GMD_ROUTINGS_PUB.update_tbl_type
, x_message_count 	OUT NOCOPY 	NUMBER
, x_message_list 	OUT NOCOPY 	VARCHAR2
, x_return_status	OUT NOCOPY 	VARCHAR2
);

/*#
 * Updates Step Dependencies
 * This is a PL/SQL procedure to update Routing Steps dependencies in Step dependency table
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_routingstep_no Routing Step Number
 * @param p_routingstep_id Routing Step ID
 * @param p_dep_routingstep_no Dependency Routing Step number
 * @param p_routing_id Routing ID
 * @param p_routing_no Routing Number
 * @param p_routing_vers Routing Version
 * @param p_update_table Table structure containing column and table to be updated
 * @param x_message_count Number of msg's on message stack
 * @param x_message_list Message list
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Step Dependency procedure
 * @rep:compatibility S
 */
PROCEDURE update_step_dependencies
( p_api_version 	IN 	NUMBER 			        :=  1
, p_init_msg_list 	IN 	BOOLEAN 			:=  TRUE
, p_commit		IN 	BOOLEAN 			:=  FALSE
, p_routingstep_no	IN	fm_rout_dep.routingstep_no%TYPE :=  NULL
, p_routingstep_id      IN      fm_rout_dtl.routingstep_id%TYPE :=  NULL
, p_dep_routingstep_no	IN	fm_rout_dep.routingstep_no%TYPE
, p_routing_id 		IN	fm_rout_dep.routing_id%TYPE 	:=  NULL
, p_routing_no		IN	gmd_routings.routing_no%TYPE    :=  NULL
, p_routing_vers 	IN	gmd_routings.routing_vers%TYPE  :=  NULL
, p_update_table	IN	GMD_ROUTINGS_PUB.update_tbl_type
, x_message_count 	OUT NOCOPY 	NUMBER
, x_message_list 	OUT NOCOPY 	VARCHAR2
, x_return_status	OUT NOCOPY 	VARCHAR2
);

/*#
 * Deletes Routing Steps
 * This is a PL/SQL procedure to delete Routing Steps in Routing details table
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_routingstep_id Routing Step ID
 * @param p_routingstep_no Routing Step Number
 * @param p_routing_id Routing ID
 * @param p_routing_no Routing Number
 * @param p_routing_vers Routing Version
 * @param x_message_count Number of msg's on message stack
 * @param x_message_list Message list
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Routing Steps procedure
 * @rep:compatibility S
 */
PROCEDURE delete_routing_step
( p_api_version 	IN 	NUMBER 			        :=  1
, p_init_msg_list 	IN 	BOOLEAN 			:=  TRUE
, p_commit		IN 	BOOLEAN 			:=  FALSE
, p_routingstep_id	IN	fm_rout_dtl.routingstep_id%TYPE :=  NULL
, p_routingstep_no	IN	fm_rout_dtl.routingstep_no%TYPE :=  NULL
, p_routing_id		IN	fm_rout_dtl.routing_id%TYPE	:=  NULL
, p_routing_no		IN	gmd_routings.routing_no%TYPE    :=  NULL
, p_routing_vers 	IN	gmd_routings.routing_vers%TYPE  :=  NULL
, x_message_count 	OUT NOCOPY 	NUMBER
, x_message_list 	OUT NOCOPY 	VARCHAR2
, x_return_status	OUT NOCOPY 	VARCHAR2
);

/*#
 * Deletes Routing Step Dependencies
 * This is a PL/SQL procedure to delete Routing Steps dependencies in Step dependency table
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_routingstep_no Routing Step Number
 * @param p_dep_routingstep_no Dependency Routing Step number
 * @param p_routing_id Routing ID
 * @param p_routing_no Routing Number
 * @param p_routing_vers Routing Version
 * @param x_message_count Number of msg's on message stack
 * @param x_message_list Message list
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Step Dependency procedure
 * @rep:compatibility S
 */
PROCEDURE delete_step_dependencies
( p_api_version 	IN 	NUMBER 			        :=  1
, p_init_msg_list 	IN 	BOOLEAN 			:=  TRUE
, p_commit		IN 	BOOLEAN 			:=  FALSE
, p_routingstep_no	IN	fm_rout_dep.routingstep_no%TYPE
, p_dep_routingstep_no	IN	fm_rout_dep.routingstep_no%TYPE :=  NULL
, p_routing_id 		IN	fm_rout_dep.routing_id%TYPE 	:=  NULL
, p_routing_no		IN	gmd_routings.routing_no%TYPE    :=  NULL
, p_routing_vers 	IN	gmd_routings.routing_vers%TYPE  :=  NULL
, x_message_count 	OUT NOCOPY 	NUMBER
, x_message_list 	OUT NOCOPY 	VARCHAR2
, x_return_status	OUT NOCOPY 	VARCHAR2
);

END GMD_ROUTING_STEPS_PUB;

 

/
