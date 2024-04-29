--------------------------------------------------------
--  DDL for Package JTF_RS_ROLES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_ROLES_PUB" AUTHID CURRENT_USER AS
  /* $Header: jtfrspos.pls 120.0 2005/05/11 08:21:19 appldev ship $ */
/*#
 * Package containing procedures for maintaining resource roles
 * @rep:scope internal
 * @rep:product JTF
 * @rep:displayname Resource Roles Package
 * @rep:category BUSINESS_ENTITY JTF_RS_ROLE
 * @rep:businessevent oracle.apps.jtf.jres.role.create
 * @rep:businessevent oracle.apps.jtf.jres.role.update
 * @rep:businessevent oracle.apps.jtf.jres.role.delete
 */


  /*****************************************************************************************
   This is a public API that caller will invoke.
   It provides PROCEDUREs for managing resource roles, like
   create, update and delete resource roles from other modules.
   Its main PROCEDUREs are as following:
   Create Resource Roles
   Update Resource Roles
   Delete Resource Roles
   ******************************************************************************************/

   --PROCEDURE to create the resource roles based on input values passed by calling routines

/*#
 * Procedure to create a resource role
 * @param P_API_VERSION API version number
 * @param P_INIT_MSG_LIST Flag to start with clearing messages from database
 * @param P_COMMIT Flag to commit at the end of the procedure
 * @param P_ROLE_TYPE_CODE Code of the role type
 * @param P_ROLE_CODE Unique Code for the role
 * @param P_ROLE_NAME Name for the role
 * @param P_ROLE_DESC Description for the role
 * @param P_ACTIVE_FLAG Is Role Active
 * @param P_SEEDED_FLAG Is Role Seeded
 * @param P_MEMBER_FLAG Does role gives member privileges
 * @param P_ADMIN_FLAG Does role give admin privileges
 * @param P_LEAD_FLAG Does role give lead privileges
 * @param P_MANAGER_FLAG Does role give manager privileges
 * @param X_RETURN_STATUS Output parameter for return status
 * @param X_MSG_COUNT Output parameter for number of user messages from this procedure
 * @param X_MSG_DATA Output parameter containing last user message from this procedure
 * @param X_ROLE_ID ID Output parameter containing unique internal ID of the newly created role
 * @rep:scope internal
 * @rep:displayname Create Resource Role
 * @rep:businessevent oracle.apps.jtf.jres.role.create
 */
PROCEDURE  create_rs_resource_roles (
      P_API_VERSION	IN   	NUMBER,
      P_INIT_MSG_LIST	IN   	VARCHAR2   				DEFAULT  FND_API.G_FALSE,
      P_COMMIT		IN   	VARCHAR2   				DEFAULT  FND_API.G_FALSE,
      P_ROLE_TYPE_CODE	IN   	JTF_RS_ROLES_B.ROLE_TYPE_CODE%TYPE,
      P_ROLE_CODE    	IN   	JTF_RS_ROLES_B.ROLE_CODE%TYPE,
      P_ROLE_NAME	IN   	JTF_RS_ROLES_TL.ROLE_NAME%TYPE,
      P_ROLE_DESC	IN   	JTF_RS_ROLES_TL.ROLE_DESC%TYPE		DEFAULT NULL,
      P_ACTIVE_FLAG	IN   	JTF_RS_ROLES_B.ACTIVE_FLAG%TYPE		DEFAULT 'Y',
      P_SEEDED_FLAG     IN      JTF_RS_ROLES_B.SEEDED_FLAG%TYPE 	DEFAULT 'N',
      P_MEMBER_FLAG	IN   	JTF_RS_ROLES_B.MEMBER_FLAG%TYPE		DEFAULT 'N',
      P_ADMIN_FLAG	IN   	JTF_RS_ROLES_B.ADMIN_FLAG%TYPE		DEFAULT 'N',
      P_LEAD_FLAG	IN   	JTF_RS_ROLES_B.LEAD_FLAG%TYPE		DEFAULT 'N',
      P_MANAGER_FLAG	IN   	JTF_RS_ROLES_B.MANAGER_FLAG%TYPE	DEFAULT 'N',
      X_RETURN_STATUS	OUT NOCOPY 	VARCHAR2,
      X_MSG_COUNT	OUT NOCOPY 	NUMBER,
      X_MSG_DATA	OUT NOCOPY 	VARCHAR2,
      X_ROLE_ID		OUT NOCOPY 	JTF_RS_ROLES_B.ROLE_ID%TYPE
  );

   --PROCEDURE to update the resource roles based on input values passed by calling routines

/*#
 * Update Resource Role information
 * @param P_API_VERSION API version number
 * @param P_INIT_MSG_LIST Flag to start with clearing messages from database
 * @param P_COMMIT Flag to commit at the end of the procedure
 * @param P_ROLE_ID Unique internal ID for the role to update
 * @param P_ROLE_TYPE_CODE Code of the role type
 * @param P_ROLE_CODE Unique Code for the role
 * @param P_ROLE_NAME Name for the role
 * @param P_ROLE_DESC Description for the role
 * @param P_SEEDED_FLAG Is Role Seeded
 * @param P_ACTIVE_FLAG Is Role Active
 * @param P_MEMBER_FLAG Does role gives member privileges
 * @param P_ADMIN_FLAG Does role give admin privileges
 * @param P_LEAD_FLAG Does role give lead privileges
 * @param P_MANAGER_FLAG Does role give manager privileges
 * @param P_OBJECT_VERSION_NUMBER object version number for the record
 * @param X_RETURN_STATUS Output parameter for return status
 * @param X_MSG_COUNT Output parameter for number of user messages from this procedure
 * @param X_MSG_DATA Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:displayname Update Resource Role
 * @rep:businessevent oracle.apps.jtf.jres.role.update
 */
PROCEDURE  update_rs_resource_roles (
      P_API_VERSION          	IN   	NUMBER,
      P_INIT_MSG_LIST        	IN   	VARCHAR2   				DEFAULT FND_API.G_FALSE,
      P_COMMIT               	IN   	VARCHAR2   				DEFAULT FND_API.G_FALSE,
      P_ROLE_ID      	  	IN   	JTF_RS_ROLES_B.ROLE_ID%TYPE		DEFAULT FND_API.G_MISS_NUM,
      P_ROLE_TYPE_CODE       	IN   	JTF_RS_ROLES_B.ROLE_TYPE_CODE%TYPE	DEFAULT FND_API.G_MISS_CHAR,
      P_ROLE_CODE		IN   	JTF_RS_ROLES_B.ROLE_CODE%TYPE   	DEFAULT FND_API.G_MISS_CHAR,
      P_ROLE_NAME            	IN   	JTF_RS_ROLES_TL.ROLE_NAME%TYPE  	DEFAULT FND_API.G_MISS_CHAR,
      P_ROLE_DESC            	IN   	JTF_RS_ROLES_TL.ROLE_DESC%TYPE		DEFAULT FND_API.G_MISS_CHAR,
      P_SEEDED_FLAG             IN      JTF_RS_ROLES_B.SEEDED_FLAG%TYPE         DEFAULT FND_API.G_MISS_CHAR,
      P_ACTIVE_FLAG 	  	IN   	JTF_RS_ROLES_B.ACTIVE_FLAG%TYPE		DEFAULT FND_API.G_MISS_CHAR,
      P_MEMBER_FLAG	  	IN   	JTF_RS_ROLES_B.MEMBER_FLAG%TYPE		DEFAULT FND_API.G_MISS_CHAR,
      P_ADMIN_FLAG	  	IN   	JTF_RS_ROLES_B.ADMIN_FLAG%TYPE		DEFAULT FND_API.G_MISS_CHAR,
      P_LEAD_FLAG	  	IN   	JTF_RS_ROLES_B.LEAD_FLAG%TYPE		DEFAULT FND_API.G_MISS_CHAR,
      P_MANAGER_FLAG	  	IN   	JTF_RS_ROLES_B.MANAGER_FLAG%TYPE	DEFAULT FND_API.G_MISS_CHAR,
      P_OBJECT_VERSION_NUMBER	IN OUT NOCOPY 	JTF_RS_ROLES_B.OBJECT_VERSION_NUMBER%TYPE,
      X_RETURN_STATUS        	OUT NOCOPY 	VARCHAR2,
      X_MSG_COUNT            	OUT NOCOPY 	NUMBER,
      X_MSG_DATA             	OUT NOCOPY 	VARCHAR2
  );

   --PROCEDURE to delete the resource roles

/*#
 * Delete a resource role
 * @param P_API_VERSION API version number
 * @param P_INIT_MSG_LIST Flag to start with clearing messages from database
 * @param P_COMMIT Flag to commit at the end of the procedure
 * @param P_ROLE_ID Internal unique ID for the role to update
 * @param P_ROLE_CODE Unique Code for the role
 * @param P_OBJECT_VERSION_NUMBER object version number for the record
 * @param X_RETURN_STATUS Output parameter for return status
 * @param X_MSG_COUNT Output parameter for number of user messages from this procedure
 * @param X_MSG_DATA Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:displayname Delete Resource Role
 * @rep:businessevent oracle.apps.jtf.jres.role.delete
 */
PROCEDURE  delete_rs_resource_roles (
      P_API_VERSION          	IN   	NUMBER,
      P_INIT_MSG_LIST        	IN   	VARCHAR2	DEFAULT  FND_API.G_FALSE,
      P_COMMIT               	IN   	VARCHAR2	DEFAULT  FND_API.G_FALSE,
      P_ROLE_ID      	  	IN   	JTF_RS_ROLES_B.ROLE_ID%TYPE,
      P_ROLE_CODE            	IN   	JTF_RS_ROLES_B.ROLE_CODE%TYPE,
      P_OBJECT_VERSION_NUMBER	IN   	JTF_RS_ROLES_B.OBJECT_VERSION_NUMBER%TYPE,
      X_RETURN_STATUS        	OUT NOCOPY 	VARCHAR2,
      X_MSG_COUNT            	OUT NOCOPY 	NUMBER,
      X_MSG_DATA             	OUT NOCOPY 	VARCHAR2
  );

END jtf_rs_roles_pub;

 

/
