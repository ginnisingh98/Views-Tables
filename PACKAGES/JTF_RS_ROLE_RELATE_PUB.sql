--------------------------------------------------------
--  DDL for Package JTF_RS_ROLE_RELATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_ROLE_RELATE_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfrspls.pls 120.0 2005/05/11 08:21:14 appldev ship $ */
/*#
 * Role Relation create, update and delete API
 * This API contains the procedures to insert, update and delete role relation record.
 * @rep:scope internal
 * @rep:product JTF
 * @rep:displayname Role Relations API
 * @rep:category BUSINESS_ENTITY JTF_RS_ROLE_RELATION
 * @rep:businessevent oracle.apps.jtf.jres.rolerelate.create
 * @rep:businessevent oracle.apps.jtf.jres.rolerelate.update
 * @rep:businessevent oracle.apps.jtf.jres.rolerelate.delete
*/

  /*****************************************************************************************
   This is a public API that caller will invoke.
   It provides procedures for managing resource roles, like
   create, update and delete resource roles from other modules.
   Its main procedures are as following:
   Create Resource Role Relate
   Update Resource Role Relate
   Delete Resource Role Relate
   Calls to these procedures will invoke procedures from jtf_rs_role_relate_pvt
   to do business validations and to do actual inserts, updates and deletes into tables.
   ******************************************************************************************/


  /* Procedure to create the resource roles
	based on input values passed by calling routines. */
/*#
 * Create Role Relations API
 * This procedure allows the user to create role relations record.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_role_id Role Identifier
 * @param p_role_code Role Code
 * @param p_role_resource_id Role Resource Identifier. This can be Resource, group, team, group member or team member Identifier.
 * @param p_role_resource_type Type of the Resource. This can be Resource, group, team, group member or team member.
 * @param p_start_date_active Date on which the role relation becomes active.
 * @param p_end_date_active Date on which the role relation is no longer active.
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @param x_role_relate_id Out parameter for role relation Identifier
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Create Role Relations API
 * @rep:businessevent oracle.apps.jtf.jres.rolerelate.create
*/
  PROCEDURE  create_resource_role_relate
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_ROLE_RESOURCE_TYPE   IN   JTF_RS_ROLE_RELATIONS.ROLE_RESOURCE_TYPE%TYPE,
   P_ROLE_RESOURCE_ID     IN   JTF_RS_ROLE_RELATIONS.ROLE_RESOURCE_ID%TYPE,
   P_ROLE_ID              IN   JTF_RS_ROLE_RELATIONS.ROLE_ID%TYPE,
   P_ROLE_CODE            IN   JTF_RS_ROLES_B.ROLE_CODE%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_ROLE_RELATIONS.START_DATE_ACTIVE%TYPE ,
   P_END_DATE_ACTIVE      IN   JTF_RS_ROLE_RELATIONS.END_DATE_ACTIVE%TYPE   DEFAULT  NULL,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_ROLE_RELATE_ID       OUT NOCOPY  JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE
  );


  /* Procedure to update the resource roles
	based on input values passed by calling routines. */
/*#
 * Update Role Relations API
 * This procedure allows the user to update role relations record.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_role_relate_id Role Relation Identifier
 * @param p_start_date_active Date on which the role relation becomes active.
 * @param p_end_date_active Date on which the role relation is no longer active.
 * @param p_object_version_num The object version number of the role relation derives from the jtf_rs_role_relations table.
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Update Role Relations API
 * @rep:businessevent oracle.apps.jtf.jres.rolerelate.update
*/
  PROCEDURE  update_resource_role_relate
  (P_API_VERSION         IN     NUMBER,
   P_INIT_MSG_LIST       IN     VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT              IN     VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_ROLE_RELATE_ID      IN     JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE,
   P_START_DATE_ACTIVE   IN     JTF_RS_ROLE_RELATIONS.START_DATE_ACTIVE%TYPE   DEFAULT  FND_API.G_MISS_DATE,
   P_END_DATE_ACTIVE     IN     JTF_RS_ROLE_RELATIONS.END_DATE_ACTIVE%TYPE   DEFAULT  FND_API.G_MISS_DATE,
   P_OBJECT_VERSION_NUM  IN OUT NOCOPY JTF_RS_ROLE_RELATIONS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS       OUT NOCOPY    VARCHAR2,
   X_MSG_COUNT           OUT NOCOPY    NUMBER,
   X_MSG_DATA            OUT NOCOPY    VARCHAR2
  );


  /* Procedure to delete the resource roles. */

/*#
 * Delete Role Relations API
 * This procedure allows the user to delete role relations record.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_role_relate_id Role Relation Identifier
 * @param p_object_version_num The object version number of the role relation derives from the jtf_rs_role_relations table.
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Delete Role Relations API
 * @rep:businessevent oracle.apps.jtf.jres.rolerelate.delete
*/
  PROCEDURE  delete_resource_role_relate
  (P_API_VERSION          IN     NUMBER,
   P_INIT_MSG_LIST        IN     VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN     VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_ROLE_RELATE_ID       IN     JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE,
   P_OBJECT_VERSION_NUM   IN    JTF_RS_ROLE_RELATIONS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY    VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY    NUMBER,
   X_MSG_DATA             OUT NOCOPY    VARCHAR2
  );

END jtf_rs_role_relate_pub;

 

/
