--------------------------------------------------------
--  DDL for Package JTF_RS_TEAM_USAGES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_TEAM_USAGES_PUB" AUTHID CURRENT_USER AS
  /* $Header: jtfrspjs.pls 120.0 2005/05/11 08:21:13 appldev ship $ */
/*#
 * Package containing procedures to maintain team usages
 * @rep:scope internal
 * @rep:product JTF
 * @rep:displayname Taem Usages Package
 * @rep:category BUSINESS_ENTITY JTF_RS_TEAM_USAGE
 */


  /*****************************************************************************************
   This is a public API that caller will invoke.
   It provides PROCEDUREs for managing resource team usages.
   Its main PROCEDUREs are as following:
   Create Resource Team Usage
   Delete Resource Team Usage
   Calls to these PROCEDUREs will invoke PROCEDUREs from jtf_rs_team_usages_pvt
   to do business validations and to do actual inserts and updates into tables.
   ******************************************************************************************/


  /* PROCEDURE to create the resource team usage
	based on input values passed by calling routines. */

 /*#
 * Procedure to Create Team Usage
 * @param P_API_VERSION API version number
 * @param P_INIT_MSG_LIST Flag to start with clearing messages from database
 * @param P_COMMIT Flag to commit at the end of the procedure
 * @param P_TEAM_ID Team's unique internal ID
 * @param P_TEAM_NUMBER Team Number
 * @param P_USAGE Usage code
 * @param X_RETURN_STATUS Output parameter for return status
 * @param X_MSG_COUNT Output parameter for number of user messages from this procedure
 * @param X_MSG_DATA Output parameter containing last user message from this procedure
 * @param X_TEAM_USAGE_ID Output parameter containing unique internal ID of newly created team usage record
 * @rep:scope internal
 * @rep:displayname Create Team Usage
 */
PROCEDURE  create_team_usage
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_TEAM_ID              IN   JTF_RS_TEAM_USAGES.TEAM_ID%TYPE,
   P_TEAM_NUMBER          IN   JTF_RS_TEAMS_VL.TEAM_NUMBER%TYPE,
   P_USAGE                IN   JTF_RS_TEAM_USAGES.USAGE%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_TEAM_USAGE_ID        OUT NOCOPY  JTF_RS_TEAM_USAGES.TEAM_USAGE_ID%TYPE
  );



  /* PROCEDURE to delete the resource team usage
	based on input values passed by calling routines. */

/*#
 * Procedure to delete a team usage
 * @param P_API_VERSION API version number
 * @param P_INIT_MSG_LIST Flag to start with clearing messages from database
 * @param P_COMMIT Flag to commit at the end of the procedure
 * @param P_TEAM_ID Team's unique internal ID
 * @param P_TEAM_NUMBER Team Number
 * @param P_USAGE Usage code
 * @param P_OBJECT_VERSION_NUM Object Version Number for the record to delete
 * @param X_RETURN_STATUS Output parameter for return status
 * @param X_MSG_COUNT Output parameter for number of user messages from this procedure
 * @param X_MSG_DATA Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:displayname Delete Team Usage
 */
PROCEDURE  delete_team_usage
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_TEAM_ID              IN   JTF_RS_TEAM_USAGES.TEAM_ID%TYPE,
   P_TEAM_NUMBER          IN   JTF_RS_TEAMS_VL.TEAM_NUMBER%TYPE,
   P_USAGE                IN   JTF_RS_TEAM_USAGES.USAGE%TYPE,
   P_OBJECT_VERSION_NUM   IN   JTF_RS_TEAM_USAGES.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  );


END jtf_rs_team_usages_pub;

 

/
