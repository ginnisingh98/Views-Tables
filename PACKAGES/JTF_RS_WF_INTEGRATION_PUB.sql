--------------------------------------------------------
--  DDL for Package JTF_RS_WF_INTEGRATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_WF_INTEGRATION_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfrswfs.pls 120.0 2005/05/11 08:23:25 appldev ship $ */
/*#
 * Workflow Integration API
 * This API integrates resources, groups, teams, group members and team members to workflow roles
 * This API contains the procedures which can be called while create/update/delete of Resources,
 * create/update of Groups/Teams and create/delete of group/team members.
 * All the below Procedures will create/update records in wf_local_roles and wf_local_user_roles
 * @rep:scope private
 * @rep:product JTF
 * @rep:displayname Workflow Integration API
 * @rep:category BUSINESS_ENTITY JTF_RS_WF_ROLE
 * @rep:category BUSINESS_ENTITY JTF_RS_WF_USER_ROLE
*/
  /*****************************************************************************************
   ******************************************************************************************/

  /* This procedure returns the workflow role_name, Orig System
     and Orig System Id of the resource_id passed.  */

/*#
 * Get workflow role informations for a given resouurce
 * This procedure returns the workflow role informations for a given resource.
 * @param p_resource_id Resource Id
 * @param x_role_name Out parameter for Workflow Role Name
 * @param x_orig_system Out parameter for Workflow Role Orig System
 * @param x_orig_system_id Out parameter for Workflow Role Orig System Id
 * @rep:scope private
 * @rep:displayname Get Workflow Role informations for a Resource
*/
 PROCEDURE get_wf_role
   (p_resource_id         IN   number,
    x_role_name           OUT NOCOPY  varchar2,
    x_orig_system         OUT NOCOPY  varchar2,
    x_orig_system_id      OUT NOCOPY  number);

  /* This overloaded procedure returns the workflow role_name, Orig System
     and Orig System Id of the resource_id/user_id passed.  */

/*#
 * Get workflow role informations for a given Resouurce and User
 * This procedure returns the workflow role informations for a given resource and a user.
 * @param p_resource_id Resource Id
 * @param p_user_id User Id
 * @param x_role_name Out parameter for Workflow Role Name
 * @param x_orig_system Out parameter for Workflow Role Orig System
 * @param x_orig_system_id Out parameter for Workflow Role Orig System Id
 * @rep:scope private
 * @rep:displayname Get Workflow Role informations for a Resource and User
*/
 PROCEDURE get_wf_role
   (p_resource_id         IN   number,
    p_user_id             IN   number,
    x_role_name           OUT NOCOPY  varchar2,
    x_orig_system         OUT NOCOPY  varchar2,
    x_orig_system_id      OUT NOCOPY  number);

  /* This function returns the workflow role_name
     of the resource_id passed.  */

/*#
 * Get workflow role for a given resouurce
 * This function returns the workflow role for a given resource.
 * @param p_resource_id Resource Id
 * @return Workflow Role
 * @rep:scope private
 * @rep:displayname Get Workflow Role for a Resource
*/
 FUNCTION get_wf_role
   (p_resource_id         IN   number)
 RETURN varchar2;

/*
 AddParameterToList - adds name and value to wf_parameter_list_t
                      If the list is null, will initialize, otherwise just adds to the end of list
*/

/*#
 * Add Parameters to the List
 * This procedure is used to add the parameters to the list, wf_parameter_list_t
 * @param p_name Name
 * @param p_value Value
 * @param p_parameterlist Workflow Parameter List
 * @rep:scope private
 * @rep:displayname Get Workflow Role for a Resource
*/
 PROCEDURE AddParameterToList(p_name  in varchar2,
                              p_value in varchar2,
                              p_parameterlist in out nocopy wf_parameter_list_t);

  /* This procedure creates a record in wf_local_roles table
     and a self relate record in wf_local_user_roles table
     for the redource_id passed. */
/*#
 * API to populate Workflow local tables while creating a resource
 * This API will insert records to wf_local_role and wf_local_user_role,
 * if the resource is active / future active at the time of creation
 * and does not have an fnd_user attached to it.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_resource_id Resource Identifier
 * @param p_resource_name Name of the Resource
 * @param p_category Category of the Resource
 * @param p_user_id User Id of the Resource
 * @param p_email_address Email Address
 * @param p_start_date_active Date on which the resource becomes active.
 * @param p_end_date_active Date on which the resource is no longer active.
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope private
 * @rep:displayname Populate Workflow local tables while creating a resource
*/
  PROCEDURE create_resource
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT NULL,
   P_COMMIT               IN   VARCHAR2   DEFAULT NULL,
   P_RESOURCE_ID          IN   NUMBER,
   P_RESOURCE_NAME        IN   VARCHAR2,
   P_CATEGORY             IN   VARCHAR2,
   P_USER_ID              IN   NUMBER,
   P_EMAIL_ADDRESS        IN   VARCHAR2,
   P_START_DATE_ACTIVE    IN   DATE,
   P_END_DATE_ACTIVE      IN   DATE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
   );

  /* This procedure creates/updates records in wf_local_roles,
     if there is a change in jtf_rs_resource_extns table and this
     will create a mismatch b/w resource_table and workflow tables.
     This also moves the workflow user role, if the user_id of the
     passed resource is changed. */
/*#
 * API to populate Workflow local tables while updating a resource
 * This procedure creates/updates records in wf_local_roles and wf_local_user_roles,
 * if there is a change in jtf_rs_resource_extns table and this
 * will create a mismatch b/w resource table and workflow tables.
 * This also moves the workflow user role, if the user_id of the
 * passed resource is changed.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_resource_id Resource Identifier
 * @param p_resource_name Name of the Resource
 * @param p_user_id User Id of the Resource
 * @param p_email_address Email Address
 * @param p_start_date_active Date on which the resource becomes active.
 * @param p_end_date_active Date on which the resource is no longer active.
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope private
 * @rep:displayname Populate Workflow local tables while updating a resource
*/
  PROCEDURE update_resource
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT NULL,
   P_COMMIT               IN   VARCHAR2   DEFAULT NULL,
   P_RESOURCE_ID          IN   NUMBER,
   P_RESOURCE_NAME        IN   VARCHAR2,
   P_USER_ID              IN   NUMBER,
   P_EMAIL_ADDRESS        IN   VARCHAR2,
   P_START_DATE_ACTIVE    IN   DATE,
   P_END_DATE_ACTIVE      IN   DATE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  );

  /* This procedure deletes the record from wf_local_roles table
     for the Resource_id passed. */
/*#
 * API to populate Workflow local tables while deleting a resource
 * This procedure updates records in wf_local_roles and wf_local_user_roles to inactive,
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_resource_id Resource Identifier
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope private
 * @rep:displayname Populate Workflow local tables while deleting a resource
*/
  PROCEDURE delete_resource
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  NULL,
   P_COMMIT               IN   VARCHAR2   DEFAULT  NULL,
   P_RESOURCE_ID          IN   NUMBER,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  ) ;


  /* If called for an active group, this procedure creates a record
     in wf_local_roles table and a self relate record in wf_local_user_roles
     table */
/*#
 * API to populate Workflow local tables while creating a group
 * This API will insert records to wf_local_role and wf_local_user_role,
 * if the group is active / future active at the time of creation
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_group_id Group Identifier
 * @param p_group_name Name of the Group
 * @param p_email_address Email Address of the Group
 * @param p_start_date_active Date on which the group becomes active.
 * @param p_end_date_active Date on which the group is no longer active.
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope private
 * @rep:displayname Populate Workflow local tables while creating a group
*/
  PROCEDURE create_resource_group
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT NULL,
   P_COMMIT               IN   VARCHAR2   DEFAULT NULL,
   P_GROUP_ID             IN   NUMBER,
   P_GROUP_NAME           IN   VARCHAR2,
   P_EMAIL_ADDRESS        IN   VARCHAR2,
   P_START_DATE_ACTIVE    IN   DATE,
   P_END_DATE_ACTIVE      IN   DATE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
   ) ;

  /* 1.If called for an active group,
       1.1 having no record in wf_local_roles table,
           this procedure creates a record in wf_local_roles table and
           a self relate record in wf_local_user_roles table.
       1.2 having changes in start/end date, group name or email address,
           applies these changes to wf_local_roles.
     2.If called for an inactive group,
       2.1 having a record in wf_local_roles table,
        2.1.1 group to be active in future
           updates the wf_local_roles record if group start date change from
           past to future.
        2.1.2 group was active in the past
           this procedure updates the wf_local_roles record, if any of the
           start date/end date/email/group name changed.
      */
/*#
 * API to populate Workflow local tables while updating a group
 * This procedure creates/updates records in wf_local_roles and wf_local_user_roles,
 * if there is a change in jtf_rs_groups_vl and this
 * will create a mismatch b/w resource group table and workflow tables.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_group_id Group Identifier
 * @param p_group_name Name of the Group
 * @param p_email_address Email Address of the Group
 * @param p_start_date_active Date on which the group becomes active.
 * @param p_end_date_active Date on which the group is no longer active.
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope private
 * @rep:displayname Populate Workflow local tables while updating a group
*/
  PROCEDURE update_resource_group
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT NULL,
   P_COMMIT               IN   VARCHAR2   DEFAULT NULL,
   P_GROUP_ID             IN   NUMBER,
   P_GROUP_NAME           IN   VARCHAR2,
   P_EMAIL_ADDRESS        IN   VARCHAR2,
   P_START_DATE_ACTIVE    IN   DATE,
   P_END_DATE_ACTIVE      IN   DATE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  ) ;

  /* Creates record in wf_local_user_roles table for the group member
     if group and  resource both are active. */
/*#
 * API to populate Workflow local tables while creating a group member
 * This API will insert records to wf_local_user_role,
 * if the group and resource both are active / future active at the time of creation
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_resource_id Resource Identifier
 * @param p_group_id Group Identifier
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope private
 * @rep:displayname Populate Workflow local tables while creating a group member
*/
  PROCEDURE create_resource_group_members
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT NULL,
   P_COMMIT               IN   VARCHAR2   DEFAULT NULL,
   P_RESOURCE_ID          IN   NUMBER,
   P_GROUP_ID             IN   NUMBER,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
   );

  /* deletes record in wf_local_user_roles table for the group
     member. */
/*#
 * API to populate Workflow local tables while deleting a group member
 * This API will update records in wf_local_user_role to inactive
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_resource_id Resource Identifier
 * @param p_group_id Group Identifier
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope private
 * @rep:displayname Populate Workflow local tables while deleting a group member
*/
  PROCEDURE delete_resource_group_members
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT NULL,
   P_COMMIT               IN   VARCHAR2   DEFAULT NULL,
   P_RESOURCE_ID          IN   NUMBER,
   P_GROUP_ID             IN   NUMBER,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
   );

/*#
 * API to populate Workflow local tables while creating a team
 * This API will insert records to wf_local_role and wf_local_user_role,
 * if the team is active / future active at the time of creation
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_team_id Team Identifier
 * @param p_team_name Name of the Team
 * @param p_email_address Email Address of the Team
 * @param p_start_date_active Date on which the team becomes active.
 * @param p_end_date_active Date on which the team is no longer active.
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope private
 * @rep:displayname Populate Workflow local tables while creating a team
*/
  PROCEDURE create_resource_team
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT NULL,
   P_COMMIT               IN   VARCHAR2   DEFAULT NULL,
   P_TEAM_ID             IN   NUMBER,
   P_TEAM_NAME           IN   VARCHAR2,
   P_EMAIL_ADDRESS        IN   VARCHAR2,
   P_START_DATE_ACTIVE      IN   DATE,
   P_END_DATE_ACTIVE      IN   DATE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
   );

/*#
 * API to populate Workflow local tables while updating a team
 * This procedure creates/updates records in wf_local_roles and wf_local_user_roles,
 * if there is a change in jtf_rs_teams_vl and this
 * will create a mismatch b/w resource team table and workflow tables.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_team_id Team Identifier
 * @param p_team_name Name of the Team
 * @param p_email_address Email Address of the Team
 * @param p_start_date_active Date on which the team becomes active.
 * @param p_end_date_active Date on which the team is no longer active.
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope private
 * @rep:displayname Populate Workflow local tables while updating a team
*/
  PROCEDURE update_resource_team
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT NULL,
   P_COMMIT               IN   VARCHAR2   DEFAULT NULL,
   P_TEAM_ID             IN   NUMBER,
   P_TEAM_NAME           IN   VARCHAR2,
   P_EMAIL_ADDRESS        IN   VARCHAR2,
   P_START_DATE_ACTIVE      IN   DATE,
   P_END_DATE_ACTIVE      IN   DATE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  );

/*#
 * API to populate Workflow local tables while creating a team member
 * This API will insert records to wf_local_user_role,
 * if the team and resource/group both are active / future active at the time of creation
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_resource_id Resource Identifier
 * @param p_group_id Group Identifier
 * @param p_team_id Team Identifier
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope private
 * @rep:displayname Populate Workflow local tables while creating a team member
*/
  PROCEDURE create_resource_team_members
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT NULL,
   P_COMMIT               IN   VARCHAR2   DEFAULT NULL,
   P_RESOURCE_ID          IN   NUMBER,
   P_GROUP_ID           IN    NUMBER,
   P_TEAM_ID             IN   NUMBER,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
   );

/*#
 * API to populate Workflow local tables while deleting a team member
 * This API will update records in wf_local_user_role to inactive
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_resource_id Resource Identifier
 * @param p_group_id Group Identifier
 * @param p_team_id Team Identifier
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope private
 * @rep:displayname Populate Workflow local tables while deleting a team member
*/
  PROCEDURE delete_resource_team_members
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT NULL,
   P_COMMIT               IN   VARCHAR2   DEFAULT NULL,
   P_RESOURCE_ID          IN   NUMBER,
   P_GROUP_ID             IN   NUMBER,
   P_TEAM_ID             IN   NUMBER,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
   );

END jtf_rs_wf_integration_pub;

 

/
