--------------------------------------------------------
--  DDL for Package JTF_RS_GROUP_USAGES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_GROUP_USAGES_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfrspas.pls 120.0 2005/05/11 08:21:04 appldev ship $ */
/*#
 * Package containing procedures to maintain information
 * about Group Usages
 * @rep:scope internal
 * @rep:product JTF
 * @rep:displayname Group Usages Package
 * @rep:category BUSINESS_ENTITY JTF_RS_GROUP_USAGE
 */


  /*****************************************************************************************
   This is a public API that caller will invoke.
   It provides PROCEDUREs for managing resource group usages.
   Its main PROCEDUREs are as following:
   Create Resource Group Usage
   Delete Resource Group Usage
   Calls to these PROCEDUREs will invoke PROCEDUREs from jtf_rs_group_usages_pvt
   to do business validations and to do actual inserts and updates into tables.
   ******************************************************************************************/



/*#
 * PROCEDURE to create the resource group usage
 * based on input values passed by calling routines.
 * @param P_API_VERSION  API version number
 * @param P_INIT_MSG_LIST Flag to start with clearing messages from database
 * @param P_COMMIT Flag to commit at the end of the procedure
 * @param P_GROUP_ID Internal Unique Id of the group
 * @param P_GROUP_NUMBER Group Number
 * @param P_USAGE Usage Code
 * @param X_RETURN_STATUS Output parameter for return status
 * @param X_MSG_COUNT Output parameter for number of user messages from this procedure
 * @param X_MSG_DATA Output parameter containing last user message from this procedure
 * @param X_GROUP_USAGE_ID Output parameter containing the unique internal id of newly created group usage.
 * @rep:scope internal
 * @rep:displayname Create Group Usage
 */
PROCEDURE  create_group_usage
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_GROUP_ID             IN   JTF_RS_GROUP_USAGES.GROUP_ID%TYPE,
   P_GROUP_NUMBER         IN   JTF_RS_GROUPS_VL.GROUP_NUMBER%TYPE,
   P_USAGE                IN   JTF_RS_GROUP_USAGES.USAGE%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_GROUP_USAGE_ID       OUT NOCOPY  JTF_RS_GROUP_USAGES.GROUP_USAGE_ID%TYPE
  );



/*#
 * PROCEDURE to delete the resource group usage
 * based on input values passed by calling routines.
 * @param P_API_VERSION  API version number
 * @param P_INIT_MSG_LIST Flag to start with clearing messages from database
 * @param P_COMMIT Flag to commit at the end of the procedure
 * @param P_GROUP_ID Internal Unique ID of the group
 * @param P_GROUP_NUMBER Group Number
 * @param P_USAGE Usage Code
 * @param P_OBJECT_VERSION_NUM Object Version Number of the group usage
 * @param X_RETURN_STATUS Output parameter for return status
 * @param X_MSG_COUNT Output parameter for number of user messages from this procedure
 * @param X_MSG_DATA Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:displayname Delete Group Usage
 */
PROCEDURE  delete_group_usage
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_GROUP_ID             IN   JTF_RS_GROUP_USAGES.GROUP_ID%TYPE,
   P_GROUP_NUMBER         IN   JTF_RS_GROUPS_VL.GROUP_NUMBER%TYPE,
   P_USAGE                IN   JTF_RS_GROUP_USAGES.USAGE%TYPE,
   P_OBJECT_VERSION_NUM   IN   JTF_RS_GROUP_USAGES.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  );


END jtf_rs_group_usages_pub;

 

/
