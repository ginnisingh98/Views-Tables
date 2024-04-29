--------------------------------------------------------
--  DDL for Package JTF_RS_TEAMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_TEAMS_PUB" AUTHID CURRENT_USER AS
  /* $Header: jtfrspts.pls 120.0 2005/05/11 08:21:25 appldev ship $ */
/*#
 * Package containing procedures to maintain teams
 * @rep:scope internal
 * @rep:product JTF
 * @rep:displayname Teams Package
 * @rep:category BUSINESS_ENTITY JTF_RS_TEAM
 */


  /*****************************************************************************************
   This is a public API that caller will invoke.
   It provides PROCEDUREs for managing resource teams.
   Its main PROCEDUREs are as following:
   Create Resource Teams
   Update Resource Teams
   Calls to these PROCEDUREs will invoke PROCEDUREs from jtf_rs_teams_pvt
   to do business validations and to do actual inserts and updates into tables.
   This package uses variables of type record and  pl/sql table .
   ******************************************************************************************/

  /* PROCEDURE to create the resource team and the members
	based on input values passed by calling routines. */

/*#
 * Create a resource team
 * @param P_API_VERSION API version number
 * @param P_INIT_MSG_LIST Flag to start with clearing messages from database
 * @param P_COMMIT Flag to commit at the end of the procedure
 * @param P_TEAM_NAME Name of the team
 * @param P_TEAM_DESC Description for the team
 * @param P_EXCLUSIVE_FLAG Is it exclusive
 * @param P_EMAIL_ADDRESS Email for the team
 * @param P_START_DATE_ACTIVE Active From Date
 * @param P_END_DATE_ACTIVE Active To Date
 * @param X_RETURN_STATUS Output parameter for return status
 * @param X_MSG_COUNT Output parameter for number of user messages from this procedure
 * @param X_MSG_DATA Output parameter containing last user message from this procedure
 * @param X_TEAM_ID Output parameter containing Internal Unique ID for the newly create team
 * @param X_TEAM_NUMBER Output parameter containing team number for the newly create team
 * @rep:scope internal
 * @rep:displayname Create Resource Team
 */
PROCEDURE  create_resource_team
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_TEAM_NAME            IN   JTF_RS_TEAMS_VL.TEAM_NAME%TYPE,
   P_TEAM_DESC            IN   JTF_RS_TEAMS_VL.TEAM_DESC%TYPE   DEFAULT  NULL,
   P_EXCLUSIVE_FLAG       IN   JTF_RS_TEAMS_VL.EXCLUSIVE_FLAG%TYPE   DEFAULT  'N',
   P_EMAIL_ADDRESS        IN   JTF_RS_TEAMS_VL.EMAIL_ADDRESS%TYPE   DEFAULT  NULL,
   P_START_DATE_ACTIVE    IN   JTF_RS_TEAMS_VL.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_TEAMS_VL.END_DATE_ACTIVE%TYPE   DEFAULT  NULL,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_TEAM_ID              OUT NOCOPY  JTF_RS_TEAMS_VL.TEAM_ID%TYPE,
   X_TEAM_NUMBER          OUT NOCOPY  JTF_RS_TEAMS_VL.TEAM_NUMBER%TYPE
  );


/* PROCEDURE to update the resource team based on input values
	passed by calling routines. */

/*#
 * Update Resource Team
 * @param P_API_VERSION API version number
 * @param P_INIT_MSG_LIST Flag to start with clearing messages from database
 * @param P_COMMIT Flag to commit at the end of the procedure
 * @param P_TEAM_ID Internal Unique identifier for the team
 * @param P_TEAM_NUMBER Team Number for the team
 * @param P_TEAM_NAME Name of the team
 * @param P_TEAM_DESC Description for the team
 * @param P_EXCLUSIVE_FLAG Is it exclusive
 * @param P_EMAIL_ADDRESS Email for the team
 * @param P_START_DATE_ACTIVE Active From Date
 * @param P_END_DATE_ACTIVE Active To Date
 * @param P_OBJECT_VERSION_NUM Object version number for the team record
 * @param X_RETURN_STATUS Output parameter for return status
 * @param X_MSG_COUNT Output parameter for number of user messages from this procedure
 * @param X_MSG_DATA Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:displayname Update Resource Team
 */
PROCEDURE  update_resource_team
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_TEAM_ID              IN   JTF_RS_TEAMS_VL.TEAM_ID%TYPE,
   P_TEAM_NUMBER          IN   JTF_RS_TEAMS_VL.TEAM_NUMBER%TYPE,
   P_TEAM_NAME            IN   JTF_RS_TEAMS_VL.TEAM_NAME%TYPE   DEFAULT FND_API.G_MISS_CHAR,
   P_TEAM_DESC            IN   JTF_RS_TEAMS_VL.TEAM_DESC%TYPE   DEFAULT FND_API.G_MISS_CHAR,
   P_EXCLUSIVE_FLAG       IN   JTF_RS_TEAMS_VL.EXCLUSIVE_FLAG%TYPE   DEFAULT FND_API.G_MISS_CHAR,
   P_EMAIL_ADDRESS        IN   JTF_RS_TEAMS_VL.EMAIL_ADDRESS%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_START_DATE_ACTIVE    IN   JTF_RS_TEAMS_VL.START_DATE_ACTIVE%TYPE   DEFAULT FND_API.G_MISS_DATE,
   P_END_DATE_ACTIVE      IN   JTF_RS_TEAMS_VL.END_DATE_ACTIVE%TYPE   DEFAULT FND_API.G_MISS_DATE,
   P_OBJECT_VERSION_NUM   IN OUT NOCOPY  JTF_RS_TEAMS_VL.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  );


END jtf_rs_teams_pub;

 

/
