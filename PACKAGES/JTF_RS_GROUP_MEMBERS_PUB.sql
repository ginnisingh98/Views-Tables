--------------------------------------------------------
--  DDL for Package JTF_RS_GROUP_MEMBERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_GROUP_MEMBERS_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfrspms.pls 120.0 2005/05/11 08:21:16 appldev ship $ */
/*#
 * Group Member create, update and delete API
 * This API contains the procedures to insert, update and delete Group member record.
 * @rep:scope internal
 * @rep:product JTF
 * @rep:displayname Group Members API
 * @rep:category BUSINESS_ENTITY JTF_RS_GROUP_MEMBER
*/
  /*****************************************************************************************
   This is a public API that caller will invoke.
   It provides procedures for managing resource group members, like
   create, update and delete resource group members from other modules.
   Its main procedures are as following:
   Create Resource Group Members
   Delete Resource Group Members
   Calls to these procedures will invoke procedures from jtf_rs_group_members_pvt
   to do business validations and to do actual inserts and deletes into tables.
   ******************************************************************************************/


  /* Procedure to create the resource group members
	based on input values passed by calling routines. */
/*#
 * Create Group Member API
 * This procedure allows the user to create a group member record.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_group_id Group Identifier
 * @param p_group_number Group Number
 * @param p_resource_id Resource Identifier
 * @param p_resource_number Resource Number
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @param x_group_member_id Out parameter for Group Member Identifier
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Create Group Member API
*/
  PROCEDURE  create_resource_group_members
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_GROUP_NUMBER         IN   JTF_RS_GROUPS_VL.GROUP_NUMBER%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
   P_RESOURCE_NUMBER      IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_GROUP_MEMBER_ID      OUT NOCOPY  JTF_RS_GROUP_MEMBERS.GROUP_MEMBER_ID%TYPE
  );


  /* Procedure to update the resource group members. */
/*#
 * Update Group Member API
 * This procedure allows the user to update a group member record.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_group_member_id Group Member Identifier
 * @param p_group_id Group Identifier
 * @param p_group_number Group Number
 * @param p_resource_id Resource Identifier
 * @param p_resource_number Resource Number
 * @param p_object_version_number The object version number of the group member derives from the jtf_rs_group_members table.
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Update Group Member API
*/
  PROCEDURE  update_resource_group_members
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_GROUP_MEMBER_ID      IN   JTF_RS_GROUP_MEMBERS.GROUP_MEMBER_ID%TYPE,
   P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_GROUP_NUMBER         IN   JTF_RS_GROUPS_VL.GROUP_NUMBER%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
   P_RESOURCE_NUMBER      IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE,
   P_OBJECT_VERSION_NUMBER IN OUT NOCOPY JTF_RS_GROUP_MEMBERS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  );

  /* Procedure to delete the resource group members. */
/*#
 * Delete Group Member API
 * This procedure allows the user to delete a group member record.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_group_id Group Identifier
 * @param p_group_number Group Number
 * @param p_resource_id Resource Identifier
 * @param p_resource_number Resource Number
 * @param p_object_version_num The object version number of the group member derives from the jtf_rs_group_members table.
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Delete Group Member API
*/
  PROCEDURE  delete_resource_group_members
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_GROUP_NUMBER         IN   JTF_RS_GROUPS_VL.GROUP_NUMBER%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
   P_RESOURCE_NUMBER      IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE,
   P_OBJECT_VERSION_NUM   IN   JTF_RS_GROUP_MEMBERS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  );


END jtf_rs_group_members_pub;

 

/
