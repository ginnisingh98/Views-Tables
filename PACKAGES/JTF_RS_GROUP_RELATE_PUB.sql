--------------------------------------------------------
--  DDL for Package JTF_RS_GROUP_RELATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_GROUP_RELATE_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfrspfs.pls 120.0 2005/05/11 08:21:08 appldev ship $ */
/*#
 * Group Relation create, update and delete API
 * This API contains the procedures to insert, update and delete Group relation record.
 * @rep:scope internal
 * @rep:product JTF
 * @rep:displayname Group Relations API
 * @rep:category BUSINESS_ENTITY JTF_RS_GROUP_RELATION
*/

  /*****************************************************************************************
   This is a public API that caller will invoke.
   It provides procedures for managing resource group relations, like
   create, update and delete resource group relations from other modules.
   Its main procedures are as following:
   Create Resource Group Relate
   Update Resource Group Relate
   Delete Resource Group Relate
   Calls to these procedures will invoke procedures from jtf_rs_group_relate_pvt
   to do business validations and to do actual inserts, updates and deletes into tables.
   ******************************************************************************************/


  /* Procedure to create the resource group relation
	based on input values passed by calling routines. */
/*#
 * Create Group Relations API
 * This procedure allows the user to create group relations record.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_group_id Group Identifier
 * @param p_group_number Group Number
 * @param p_related_group_id Related Group Identifier
 * @param p_related_group_number Related Group Number
 * @param p_relation_type Relation Type
 * @param p_start_date_active Date on which the group relation becomes active.
 * @param p_end_date_active Date on which the group relation is no longer active.
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @param x_group_relate_id Out parameter for Group Relations Identifier
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Create Group Relations API
*/
  PROCEDURE  create_resource_group_relate
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_GROUP_ID             IN   JTF_RS_GROUPS_B.GROUP_ID%TYPE,
   P_GROUP_NUMBER         IN   JTF_RS_GROUPS_B.GROUP_NUMBER%TYPE,
   P_RELATED_GROUP_ID     IN   JTF_RS_GRP_RELATIONS.RELATED_GROUP_ID%TYPE,
   P_RELATED_GROUP_NUMBER IN   JTF_RS_GROUPS_B.GROUP_NUMBER%TYPE,
   P_RELATION_TYPE        IN   JTF_RS_GRP_RELATIONS.RELATION_TYPE%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_GRP_RELATIONS.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_GRP_RELATIONS.END_DATE_ACTIVE%TYPE   DEFAULT  NULL,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_GROUP_RELATE_ID      OUT NOCOPY  JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID%TYPE
  );


  /* Procedure to update the resource group relation
	based on input values passed by calling routines. */
/*#
 * Update Group Relations API
 * This procedure allows the user to update group relations record.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_group_relate_id Group Relation Identifier
 * @param p_start_date_active Date on which the group relation becomes active.
 * @param p_end_date_active Date on which the group relation is no longer active.
 * @param p_object_version_num The object version number of the group relation derives from the jtf_rs_grp_relations table.
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Update Group Relations API
*/
  PROCEDURE  update_resource_group_relate
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_GROUP_RELATE_ID      IN   JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_GRP_RELATIONS.START_DATE_ACTIVE%TYPE   DEFAULT  FND_API.G_MISS_DATE,
   P_END_DATE_ACTIVE      IN   JTF_RS_GRP_RELATIONS.END_DATE_ACTIVE%TYPE   DEFAULT  FND_API.G_MISS_DATE,
   P_OBJECT_VERSION_NUM   IN OUT NOCOPY  JTF_RS_GRP_RELATIONS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  );


  /* Procedure to delete the resource group relation. */

/*#
 * Delete Group Relations API
 * This procedure allows the user to delete group relations record.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_group_relate_id Group Relation Identifier
 * @param p_object_version_num The object version number of the group relation derives from the jtf_rs_grp_relations table.
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Delete Group Relations API
*/
  PROCEDURE  delete_resource_group_relate
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_GROUP_RELATE_ID      IN   JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID%TYPE,
   P_OBJECT_VERSION_NUM   IN   JTF_RS_GROUPS_VL.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  );

END jtf_rs_group_relate_pub;

 

/
