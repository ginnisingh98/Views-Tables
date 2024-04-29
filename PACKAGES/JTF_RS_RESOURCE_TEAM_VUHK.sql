--------------------------------------------------------
--  DDL for Package JTF_RS_RESOURCE_TEAM_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_RESOURCE_TEAM_VUHK" AUTHID CURRENT_USER AS
  /* $Header: jtfrsits.pls 120.0 2005/05/11 08:20:21 appldev ship $ */

  /*****************************************************************************************
   This is the Vertical Industry User Hook API.
   The Vertical Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/

  /* Vertical Industry Procedure for pre processing in case of
	create resource team */

  PROCEDURE  create_resource_team_pre
  (P_TEAM_NAME            IN   JTF_RS_TEAMS_VL.TEAM_NAME%TYPE,
   P_TEAM_DESC            IN   JTF_RS_TEAMS_VL.TEAM_DESC%TYPE,
   P_EXCLUSIVE_FLAG       IN   JTF_RS_TEAMS_VL.EXCLUSIVE_FLAG%TYPE,
   P_EMAIL_ADDRESS        IN   JTF_RS_TEAMS_VL.EMAIL_ADDRESS%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_TEAMS_VL.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_TEAMS_VL.END_DATE_ACTIVE%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  );


  /* Vertical Industry Procedure for post processing in case of
	create resource team */

  PROCEDURE  create_resource_team_post
  (P_TEAM_ID              IN   JTF_RS_TEAMS_VL.TEAM_ID%TYPE,
   P_TEAM_NAME            IN   JTF_RS_TEAMS_VL.TEAM_NAME%TYPE,
   P_TEAM_DESC            IN   JTF_RS_TEAMS_VL.TEAM_DESC%TYPE,
   P_EXCLUSIVE_FLAG       IN   JTF_RS_TEAMS_VL.EXCLUSIVE_FLAG%TYPE,
   P_EMAIL_ADDRESS        IN   JTF_RS_TEAMS_VL.EMAIL_ADDRESS%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_TEAMS_VL.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_TEAMS_VL.END_DATE_ACTIVE%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2
  );


  /* Vertical Industry Procedure for pre processing in case of
	update resource team */

  PROCEDURE  update_resource_team_pre
  (P_TEAM_ID              IN   JTF_RS_TEAMS_VL.TEAM_ID%TYPE,
   P_TEAM_NAME            IN   JTF_RS_TEAMS_VL.TEAM_NAME%TYPE,
   P_TEAM_DESC            IN   JTF_RS_TEAMS_VL.TEAM_DESC%TYPE,
   P_EXCLUSIVE_FLAG       IN   JTF_RS_TEAMS_VL.EXCLUSIVE_FLAG%TYPE,
   P_EMAIL_ADDRESS        IN   JTF_RS_TEAMS_VL.EMAIL_ADDRESS%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_TEAMS_VL.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_TEAMS_VL.END_DATE_ACTIVE%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2
  );


  /* Vertical Industry Procedure for post processing in case of
	update resource team */

  PROCEDURE  update_resource_team_post
  (P_TEAM_ID              IN   JTF_RS_TEAMS_VL.TEAM_ID%TYPE,
   P_TEAM_NAME            IN   JTF_RS_TEAMS_VL.TEAM_NAME%TYPE,
   P_TEAM_DESC            IN   JTF_RS_TEAMS_VL.TEAM_DESC%TYPE,
   P_EXCLUSIVE_FLAG       IN   JTF_RS_TEAMS_VL.EXCLUSIVE_FLAG%TYPE,
   P_EMAIL_ADDRESS        IN   JTF_RS_TEAMS_VL.EMAIL_ADDRESS%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_TEAMS_VL.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_TEAMS_VL.END_DATE_ACTIVE%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2
  );


END jtf_rs_resource_team_vuhk;

 

/
