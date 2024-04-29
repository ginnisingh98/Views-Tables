--------------------------------------------------------
--  DDL for Package JTF_RS_DYNAMIC_GROUPS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_DYNAMIC_GROUPS_PUB" AUTHID CURRENT_USER AS
  /* $Header: jtfrspys.pls 120.0 2005/05/11 08:21:31 appldev ship $ */
/*#
 * Package containing procedures to maintain dynamic groups
 * @rep:scope internal
 * @rep:product JTF
 * @rep:displayname Dynamic Groups Package
 * @rep:category BUSINESS_ENTITY JTF_RS_DYNAMIC_GROUP
 */


  /*****************************************************************************************
   This is a public API that caller will invoke.
   It provides PROCEDUREs for managing Dynamic Groups, like
   create, update and delete Dynamic Groups from other modules.
   Its main PROCEDUREs are as following:
   Create Dynamic Groups
   Update Dynamic Groups
   Delete Dynamic Groups
   ******************************************************************************************/


  /* PROCEDURE to create the Dynamic Groups
	based on input values passed by calling routines. */

/*#
 * Procedure for creating a dynamic group
 * @param P_API_VERSION API version number
 * @param P_INIT_MSG_LIST Flag to start with clearing messages from database
 * @param P_COMMIT Flag to commit at the end of the procedure
 * @param P_GROUP_NAME Name of the group
 * @param P_GROUP_DESC Description for the group
 * @param P_USAGE Usage for the group
 * @param P_START_DATE_ACTIVE Active From Date
 * @param P_END_DATE_ACTIVE Active To Date
 * @param P_SQL_TEXT SQL query for the dynamic group
 * @param X_RETURN_STATUS Output parameter for return status
 * @param X_MSG_COUNT Output parameter for number of user messages from this procedure
 * @param X_MSG_DATA Output parameter containing last user message from this procedure
 * @param X_GROUP_ID Output parameter containing internal unique id for the dynamic group
 * @param X_GROUP_NUMBER Output parameter containing group number
 * @rep:scope internal
 * @rep:displayname Create Dynamic Group
 */
PROCEDURE  create_dynamic_groups
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_GROUP_NAME 	  IN   JTF_RS_DYNAMIC_GROUPS_TL.GROUP_NAME%TYPE,
   P_GROUP_DESC 	  IN   JTF_RS_DYNAMIC_GROUPS_TL.GROUP_DESC%TYPE   DEFAULT  NULL,
   P_USAGE    	  	  IN   JTF_RS_DYNAMIC_GROUPS_B.USAGE%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_DYNAMIC_GROUPS_B.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_DYNAMIC_GROUPS_B.END_DATE_ACTIVE%TYPE   DEFAULT  NULL,
   P_SQL_TEXT             IN   JTF_RS_DYNAMIC_GROUPS_B.SQL_TEXT%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_GROUP_ID    	  OUT NOCOPY  JTF_RS_DYNAMIC_GROUPS_B.GROUP_ID%TYPE,
   X_GROUP_NUMBER    	  OUT NOCOPY  JTF_RS_DYNAMIC_GROUPS_B.GROUP_NUMBER%TYPE
  );


/* PROCEDURE to update the Dynamic Groups
	based on input values passed by calling routines. */

/*#
 * Procedure to update a dynamic group
 * @param P_API_VERSION API version number
 * @param P_INIT_MSG_LIST Flag to start with clearing messages from database
 * @param P_COMMIT Flag to commit at the end of the procedure
 * @param P_GROUP_ID internal unique id for the dynamic group
 * @param P_GROUP_NUMBER dynamic group number
 * @param P_GROUP_NAME Name of the group
 * @param P_GROUP_DESC Description for the group
 * @param P_USAGE Usage for the group
 * @param P_START_DATE_ACTIVE Active From Date
 * @param P_END_DATE_ACTIVE Active To Date
 * @param P_SQL_TEXT SQL query for the dynamic group
 * @param P_OBJECT_VERSION_NUMBER object version number for the database record
 * @param X_RETURN_STATUS Output parameter for return status
 * @param X_MSG_COUNT Output parameter for number of user messages from this procedure
 * @param X_MSG_DATA Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:displayname Update Dynamic Group
 */
PROCEDURE  update_dynamic_groups
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_GROUP_ID    	  IN   JTF_RS_DYNAMIC_GROUPS_B.GROUP_ID%TYPE,
   P_GROUP_NUMBER    	  IN   JTF_RS_DYNAMIC_GROUPS_B.GROUP_NUMBER%TYPE,
   P_GROUP_NAME 	  IN   JTF_RS_DYNAMIC_GROUPS_TL.GROUP_NAME%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_GROUP_DESC 	  IN   JTF_RS_DYNAMIC_GROUPS_TL.GROUP_DESC%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_USAGE    	  	  IN   JTF_RS_DYNAMIC_GROUPS_B.USAGE%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_START_DATE_ACTIVE    IN   JTF_RS_DYNAMIC_GROUPS_B.START_DATE_ACTIVE%TYPE   DEFAULT  FND_API.G_MISS_DATE,
   P_END_DATE_ACTIVE      IN   JTF_RS_DYNAMIC_GROUPS_B.END_DATE_ACTIVE%TYPE   DEFAULT  FND_API.G_MISS_DATE,
   P_SQL_TEXT             IN   JTF_RS_DYNAMIC_GROUPS_B.SQL_TEXT%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_OBJECT_VERSION_NUMBER	IN OUT NOCOPY JTF_RS_DYNAMIC_GROUPS_B.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  );


/* PROCEDURE to delete the Dynamic Groups. */

/*#
 * Procedure to delete a dynamic group
 * @param P_API_VERSION API version number
 * @param P_INIT_MSG_LIST Flag to start with clearing messages from database
 * @param P_COMMIT Flag to commit at the end of the procedure
 * @param P_GROUP_ID internal unique id for the dynamic group
 * @param P_OBJECT_VERSION_NUMBER object version number for the database record
 * @param X_RETURN_STATUS Output parameter for return status
 * @param X_MSG_COUNT Output parameter for number of user messages from this procedure
 * @param X_MSG_DATA Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:displayname Delete Dynamic Group
 */
PROCEDURE  delete_dynamic_groups
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_GROUP_ID    	  IN   JTF_RS_DYNAMIC_GROUPS_B.GROUP_ID%TYPE,
   P_OBJECT_VERSION_NUMBER	IN JTF_RS_DYNAMIC_GROUPS_B.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  );


END jtf_rs_dynamic_groups_pub;

 

/
