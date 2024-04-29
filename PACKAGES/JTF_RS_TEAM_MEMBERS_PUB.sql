--------------------------------------------------------
--  DDL for Package JTF_RS_TEAM_MEMBERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_TEAM_MEMBERS_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfrspes.pls 120.0 2005/05/11 08:21:07 appldev ship $ */
/*#
 * Team Member create and delete API
 * This API contains the procedures to insert and delete Team member record.
 * @rep:scope internal
 * @rep:product JTF
 * @rep:displayname Team Members API
 * @rep:category BUSINESS_ENTITY JTF_RS_TEAM_MEMBER
*/
  /*****************************************************************************************
   This is a public API that caller will invoke.
   It provides procedures for managing resource team members, like
   create, update and delete resource team members from other modules.
   Its main procedures are as following:
   Create Resource Team Members
   Update Resource Team Members
   Delete Resource Team Members
   Calls to these procedures will invoke procedures from jtf_rs_team_members_pvt
   to do business validations and to do actual inserts, updates and deletes into tables.
   ******************************************************************************************/


  /* Procedure to create the resource team members
	based on input values passed by calling routines. */

/*#
 * Create Team Member API
 * This procedure allows the user to create a team member record.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_team_id Team Identifier
 * @param p_team_number Team Number
 * @param p_team_resource_id Team Resource Identifier. This can be Resource or Group Identifier
 * @param p_team_resource_number Team Resource Number. This can be Resource or Group Number
 * @param p_resource_type Type of the Resource. This can be Resource or Group.
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @param x_team_member_id Out parameter for Team Member Identifier
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Create Team Member API
*/
  PROCEDURE  create_resource_team_members
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_TEAM_ID              IN   JTF_RS_TEAM_MEMBERS.TEAM_ID%TYPE,
   P_TEAM_NUMBER          IN   JTF_RS_TEAMS_VL.TEAM_NUMBER%TYPE,
   P_TEAM_RESOURCE_ID     IN   JTF_RS_TEAM_MEMBERS.TEAM_RESOURCE_ID%TYPE,
   P_TEAM_RESOURCE_NUMBER IN   NUMBER,
   P_RESOURCE_TYPE        IN   JTF_RS_TEAM_MEMBERS.RESOURCE_TYPE%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_TEAM_MEMBER_ID       OUT NOCOPY  JTF_RS_TEAM_MEMBERS.TEAM_MEMBER_ID%TYPE
  );


  /* Procedure to delete the resource team members. */
/*#
 * Delete Team Member API
 * This procedure allows the user to delete a team member record.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_team_id Team Identifier
 * @param p_team_number Team Number
 * @param p_team_resource_id Team Resource Identifier. This can be Resource or Group Identifier
 * @param p_team_resource_number Team Resource Number. This can be Resource or Group Number
 * @param p_resource_type Type of the Resource. This can be Resource or Group.
 * @param p_object_version_num The object version number of the team member derives from the jtf_rs_team_members table
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Delete Team Member API
*/
  PROCEDURE  delete_resource_team_members
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_TEAM_ID              IN   JTF_RS_TEAM_MEMBERS.TEAM_ID%TYPE,
   P_TEAM_NUMBER          IN   JTF_RS_TEAMS_VL.TEAM_NUMBER%TYPE,
   P_TEAM_RESOURCE_ID     IN   JTF_RS_TEAM_MEMBERS.TEAM_RESOURCE_ID%TYPE,
   P_TEAM_RESOURCE_NUMBER IN   NUMBER,
   P_RESOURCE_TYPE        IN   JTF_RS_TEAM_MEMBERS.RESOURCE_TYPE%TYPE,
   P_OBJECT_VERSION_NUM   IN   JTF_RS_TEAM_MEMBERS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  );


END jtf_rs_team_members_pub;

 

/
