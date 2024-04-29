--------------------------------------------------------
--  DDL for Package JTF_RS_WF_EVENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_WF_EVENTS_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfrswps.pls 120.0 2005/05/11 08:23:28 appldev ship $ */
/*#
 * Workflow Events API
 * This API raises business events for create/update/delete resources, roles, role relations
 * and merge of two resources.
 * This API contains the procedures which can be called while create/update/delete of Resources,
 * roles, role relations and merge of two resources.
 * @rep:scope private
 * @rep:product JTF
 * @rep:displayname Workflow Events API
 * @rep:category BUSINESS_ENTITY JTF_RS_WF_EVENT
 * @rep:businessevent oracle.apps.jtf.jres.resource.create
 * @rep:businessevent oracle.apps.jtf.jres.resource.update.user
 * @rep:businessevent oracle.apps.jtf.jres.resource.update.effectivedate
 * @rep:businessevent oracle.apps.jtf.jres.resource.update.attributes
 * @rep:businessevent oracle.apps.jtf.jres.resource.delete
 * @rep:businessevent oracle.apps.jtf.jres.role.create
 * @rep:businessevent oracle.apps.jtf.jres.role.update
 * @rep:businessevent oracle.apps.jtf.jres.role.delete
 * @rep:businessevent oracle.apps.jtf.jres.rolerelate.create
 * @rep:businessevent oracle.apps.jtf.jres.rolerelate.update
 * @rep:businessevent oracle.apps.jtf.jres.rolerelate.delete
 * @rep:businessevent oracle.apps.jtf.jres.resource.merge
*/
  /*****************************************************************************************
   ******************************************************************************************/

  /* This procedure raises the business event oracle.apps.jtf.jres.resource.create
     This Resource Create Event will be raised for all the newly created
     or Imported resources */

/*#
 * API to raise the business event while creating a resource.
 * Resource Create Event will be raised for all the newly created / Imported resources.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_resource_id Resource Identifier
 * @param p_resource_name Name of the Resource
 * @param p_category Category of the Resource
 * @param p_user_id User Id of the Resource
 * @param p_start_date_active Date on which the resource becomes active.
 * @param p_end_date_active Date on which the resource is no longer active.
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope private
 * @rep:displayname Resource Create Event API
 * @rep:businessevent oracle.apps.jtf.jres.resource.create
*/
  PROCEDURE create_resource
  (P_API_VERSION	IN	NUMBER,
   P_INIT_MSG_LIST	IN	VARCHAR2   DEFAULT NULL,
   P_COMMIT		IN	VARCHAR2   DEFAULT NULL,
   P_RESOURCE_ID	IN	NUMBER,
   P_RESOURCE_NAME	IN	VARCHAR2,
   P_CATEGORY		IN	VARCHAR2,
   P_USER_ID		IN	NUMBER,
   P_START_DATE_ACTIVE	IN	DATE,
   P_END_DATE_ACTIVE	IN	DATE,
   X_RETURN_STATUS	OUT	NOCOPY VARCHAR2,
   X_MSG_COUNT		OUT	NOCOPY NUMBER,
   X_MSG_DATA		OUT	NOCOPY VARCHAR2
   );


  /* This procedure raises the business event oracle.apps.jtf.jres.resource.merge
     This Resource merge Event will be raised when two resources are merged.
     currently this API is called from party merge.*/
/*#
 * API to raise the business event while merge of two resources.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_resource_id From Resource Identifier
 * @param p_end_date_active Date on which the from resource is no longer active.
 * @param p_repl_resource_id Replacement Resource Identifier
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope private
 * @rep:displayname Resource Merge Event API
 * @rep:businessevent oracle.apps.jtf.jres.resource.merge
*/
  PROCEDURE merge_resource
  (P_API_VERSION        IN      NUMBER,
   P_INIT_MSG_LIST	IN	VARCHAR2   DEFAULT NULL,
   P_COMMIT		IN	VARCHAR2   DEFAULT NULL,
   P_RESOURCE_ID        IN      NUMBER,
   P_END_DATE_ACTIVE    IN      DATE,
   P_REPL_RESOURCE_ID   IN      NUMBER,
   X_RETURN_STATUS      OUT     NOCOPY VARCHAR2,
   X_MSG_COUNT          OUT     NOCOPY NUMBER,
   X_MSG_DATA           OUT     NOCOPY VARCHAR2
   );

  /* This procedure raises the following business events
     User_id change - oracle.apps.jtf.jres.resource.update.user
     Date effective change - oracle.apps.jtf.jres.resource.update.effectivedate
     Other attributes change - oracle.apps.jtf.jres.resource.update.attributes
   */

/*#
 * API to raise the business events while updating a resource.
 * Resource Update User Event will be raised for all the resources that have a change in user_id.
 * Resource Update dateEffectivity Event will be raised for all the resources that have a change in start date active or end date active.
 * Resource Update Attribute Event will be raised for all the resources that have a change all other attributes.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_resource_rec Information about the changed resource record
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope private
 * @rep:displayname Resource Update Event API
 * @rep:businessevent oracle.apps.jtf.jres.resource.update.user
 * @rep:businessevent oracle.apps.jtf.jres.resource.update.effectivedate
 * @rep:businessevent oracle.apps.jtf.jres.resource.update.attributes
*/
  PROCEDURE update_resource
  (P_API_VERSION	IN	NUMBER,
   P_INIT_MSG_LIST	IN	VARCHAR2   DEFAULT NULL,
   P_COMMIT		IN	VARCHAR2   DEFAULT NULL,
   P_RESOURCE_REC	IN	jtf_rs_resource_pvt.RESOURCE_REC_TYPE,
   X_RETURN_STATUS	OUT	NOCOPY VARCHAR2,
   X_MSG_COUNT		OUT	NOCOPY NUMBER,
   X_MSG_DATA		OUT	NOCOPY VARCHAR2
  );


  /* This procedure raises the business event oracle.apps.jtf.jres.resource.delete
     This Resource Delete Event will be raised for all the deleted TBH resources */
/*#
 * API to raise the business events while deleting a resource.
 * Resource Delete Event will be raised for all deleted resources.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_resource_id Resource Identifier
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope private
 * @rep:displayname Resource Delete Event API
 * @rep:businessevent oracle.apps.jtf.jres.resource.delete
*/
  PROCEDURE delete_resource
  (P_API_VERSION	IN  	NUMBER,
   P_INIT_MSG_LIST	IN	VARCHAR2   DEFAULT NULL,
   P_COMMIT		IN	VARCHAR2   DEFAULT NULL,
   P_RESOURCE_ID	IN	NUMBER,
   X_RETURN_STATUS	OUT	NOCOPY VARCHAR2,
   X_MSG_COUNT		OUT	NOCOPY NUMBER,
   X_MSG_DATA		OUT	NOCOPY VARCHAR2
  );

  /* This procedure raises the business event oracle.apps.jtf.jres.role.create
     This Resource Role Create Event will be raised for all the newly created resource roles */
/*#
 * API to raise the business event while creating a resource role.
 * Role Create Event will be raised for all the newly created roles
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_role_id Role Identifier
 * @param p_role_type_code Role Type Code
 * @param p_role_code Role Code
 * @param p_role_name Role name
 * @param p_role_desc Role Description
 * @param p_active_flag Flag indicating this role is an active role or not
 * @param p_member_flag Flag indicating if this role is a member role or not
 * @param p_admin_flag Flag indicating if this role is an admin role or not
 * @param p_lead_flag Flag indicating if this role is a leader role or not
 * @param p_manager_flag Flag indicating if this role is a manager role or not
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope private
 * @rep:displayname Resource Role Create Event API
 * @rep:businessevent oracle.apps.jtf.jres.role.create
*/
  PROCEDURE create_resource_role
  (P_API_VERSION	IN	NUMBER,
   P_INIT_MSG_LIST	IN	VARCHAR2,
   P_COMMIT		IN	VARCHAR2,
   P_ROLE_ID		IN	NUMBER,
   P_ROLE_TYPE_CODE	IN	VARCHAR2,
   P_ROLE_CODE		IN	VARCHAR2,
   P_ROLE_NAME		IN	VARCHAR2,
   P_ROLE_DESC		IN	VARCHAR2,
   P_ACTIVE_FLAG	IN	VARCHAR2,
   P_MEMBER_FLAG	IN	VARCHAR2,
   P_ADMIN_FLAG		IN	VARCHAR2,
   P_LEAD_FLAG		IN	VARCHAR2,
   P_MANAGER_FLAG	IN	VARCHAR2,
   X_RETURN_STATUS	OUT	NOCOPY VARCHAR2,
   X_MSG_COUNT		OUT	NOCOPY NUMBER,
   X_MSG_DATA		OUT	NOCOPY VARCHAR2
   );

  /* This procedure raises the business event oracle.apps.jtf.jres.role.update
     This Resource Role Update Event will be raised for all upadted resource roles */

/*#
 * API to raise the business events while updating a resource Role.
 * Role Update Event will be raised for all the roles that have a changed.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_resource_role_rec Information about the changed role record
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope private
 * @rep:displayname Resource Role Update Event API
 * @rep:businessevent oracle.apps.jtf.jres.role.update
*/
  PROCEDURE update_resource_role
  (P_API_VERSION	IN	NUMBER,
   P_INIT_MSG_LIST	IN	VARCHAR2,
   P_COMMIT		IN	VARCHAR2,
   P_RESOURCE_ROLE_REC	IN	jtf_rs_roles_pvt.RESOURCE_ROLE_REC_TYPE,
   X_RETURN_STATUS	OUT	NOCOPY VARCHAR2,
   X_MSG_COUNT		OUT	NOCOPY NUMBER,
   X_MSG_DATA		OUT	NOCOPY VARCHAR2
  );

  /* This procedure raises the business event oracle.apps.jtf.jres.role.delete
     This Resource Role Delete Event will be raised for all deleted resource roles */

/*#
 * API to raise the business events while deleting a resource Role.
 * Role Delete Event will be raised for all deleted roles.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_role_id Role Identifier
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope private
 * @rep:displayname Resource Role Delete Event API
 * @rep:businessevent oracle.apps.jtf.jres.role.delete
*/
  PROCEDURE delete_resource_role
  (P_API_VERSION	IN   	NUMBER,
   P_INIT_MSG_LIST	IN	VARCHAR2,
   P_COMMIT		IN	VARCHAR2,
   P_ROLE_ID		IN	NUMBER,
   X_RETURN_STATUS	OUT	NOCOPY VARCHAR2,
   X_MSG_COUNT		OUT	NOCOPY NUMBER,
   X_MSG_DATA		OUT	NOCOPY VARCHAR2
  );

  /* This procedure raises the business event oracle.apps.jtf.jres.rolerelate.create
     This Resource Role Relation Create Event will be raised for all the newly created role relations */

/*#
 * API to raise the business event while creating a role relation.
 * Role Relation Create Event will be raised whenever a role is assigned to a resource, group member or team member.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_role_id Role Identifier
 * @param p_role_relate_id Role Relation Identifier
 * @param p_role_resource_id Role Resource Identifier. This can be Resource, group, team, group member or team member Identifier.
 * @param p_role_resource_type Type of the Resource. This can be Resource, group, team, group member or team member.
 * @param p_start_date_active Date on which the role relation becomes active.
 * @param p_end_date_active Date on which the role relation is no longer active.
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope private
 * @rep:displayname Role Relation Create Event API
 * @rep:businessevent oracle.apps.jtf.jres.rolerelate.create
*/
    PROCEDURE create_resource_role_relate
  (P_API_VERSION	IN	NUMBER,
   P_INIT_MSG_LIST	IN	VARCHAR2,
   P_COMMIT		IN	VARCHAR2,
   P_ROLE_RELATE_ID	IN	NUMBER,
   P_ROLE_RESOURCE_TYPE	IN	VARCHAR2,
   P_ROLE_RESOURCE_ID	IN	NUMBER,
   P_ROLE_ID		IN	NUMBER,
   P_START_DATE_ACTIVE	IN	DATE,
   P_END_DATE_ACTIVE	IN	DATE,
   X_RETURN_STATUS	OUT	NOCOPY VARCHAR2,
   X_MSG_COUNT		OUT	NOCOPY NUMBER,
   X_MSG_DATA		OUT	NOCOPY VARCHAR2
   );

  /* This procedure raises the business event oracle.apps.jtf.jres.rolerelate.update
     This Resource Role Relation Update Event will be raised for all upadted role relations */
/*#
 * API to raise the business event while updating a role relation.
 * Role Relation Update Event will be raised whenever a an existing role relation is updated.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_role_id Role Identifier
 * @param p_role_relate_id Role Relation Identifier
 * @param p_role_resource_id Role Resource Identifier. This can be Resource, group, team, group member or team member Identifier.
 * @param p_role_resource_type Type of the Resource. This can be Resource, group, team, group member or team member.
 * @param p_start_date_active Date on which the role relation becomes active.
 * @param p_end_date_active Date on which the role relation is no longer active.
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope private
 * @rep:displayname Role Relation Update Event API
 * @rep:businessevent oracle.apps.jtf.jres.rolerelate.update
*/
  PROCEDURE update_resource_role_relate
  (P_API_VERSION		IN	NUMBER,
   P_INIT_MSG_LIST		IN	VARCHAR2,
   P_COMMIT			IN	VARCHAR2,
   P_ROLE_RELATE_ID 		IN	NUMBER,
   P_ROLE_RESOURCE_TYPE		IN	VARCHAR2,
   P_ROLE_RESOURCE_ID           IN      NUMBER,
   P_ROLE_ID            	IN      NUMBER,
   P_START_DATE_ACTIVE	        IN	DATE,
   P_END_DATE_ACTIVE	        IN	DATE,
   X_RETURN_STATUS		OUT	NOCOPY VARCHAR2,
   X_MSG_COUNT			OUT	NOCOPY NUMBER,
   X_MSG_DATA			OUT	NOCOPY VARCHAR2
  );

  /* This procedure raises the business event oracle.apps.jtf.jres.rolerelate.delete
     This Resource Role Relations Delete Event will be raised for all deleted role realtions */
/*#
 * API to raise the business event while deleting a role relation.
 * Role Relation Delete Event will be raised whenever a an existing role relation is deleted.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_role_relate_id Role Relation Identifier
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope private
 * @rep:displayname Role Relation Delete Event API
 * @rep:businessevent oracle.apps.jtf.jres.rolerelate.delete
*/
  PROCEDURE delete_resource_role_relate
  (P_API_VERSION	IN   	NUMBER,
   P_INIT_MSG_LIST	IN	VARCHAR2,
   P_COMMIT		IN	VARCHAR2,
   P_ROLE_RELATE_ID	IN	NUMBER,
   X_RETURN_STATUS	OUT	NOCOPY VARCHAR2,
   X_MSG_COUNT		OUT	NOCOPY NUMBER,
   X_MSG_DATA		OUT	NOCOPY VARCHAR2
  );


END jtf_rs_wf_events_pub;

 

/
