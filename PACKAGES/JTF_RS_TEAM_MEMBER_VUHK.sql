--------------------------------------------------------
--  DDL for Package JTF_RS_TEAM_MEMBER_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_TEAM_MEMBER_VUHK" AUTHID CURRENT_USER AS
  /* $Header: jtfrsies.pls 120.0 2005/05/11 08:20:13 appldev ship $ */

  /*****************************************************************************************
   This is the Vertical Industry User Hook API.
   The Vertical Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/

  /* Vertcal Industry Procedure for pre processing in case of
	create resource team members */

  PROCEDURE  create_team_members_pre
  (P_TEAM_ID              IN   JTF_RS_TEAM_MEMBERS.TEAM_ID%TYPE,
   P_TEAM_RESOURCE_ID     IN   JTF_RS_TEAM_MEMBERS.TEAM_RESOURCE_ID%TYPE,
   P_RESOURCE_TYPE        IN   JTF_RS_TEAM_MEMBERS.RESOURCE_TYPE%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2
  );


  /* Vertcal Industry Procedure for post processing in case of
	create resource team members */

  PROCEDURE  create_team_members_post
  (P_TEAM_MEMBER_ID       IN   JTF_RS_TEAM_MEMBERS.TEAM_MEMBER_ID%TYPE,
   P_TEAM_ID              IN   JTF_RS_TEAM_MEMBERS.TEAM_ID%TYPE,
   P_TEAM_RESOURCE_ID     IN   JTF_RS_TEAM_MEMBERS.TEAM_RESOURCE_ID%TYPE,
   P_RESOURCE_TYPE        IN   JTF_RS_TEAM_MEMBERS.RESOURCE_TYPE%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2
  );


  /* Vertcal Industry Procedure for pre processing in case of
	update resource team members */

  PROCEDURE  update_team_members_pre
  (P_TEAM_MEMBER_ID              IN   JTF_RS_TEAM_MEMBERS.TEAM_MEMBER_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2
  );


  /* Vertcal Industry Procedure for post processing in case of
	update resource team members */

  PROCEDURE  update_team_members_post
  (P_TEAM_MEMBER_ID       IN   JTF_RS_TEAM_MEMBERS.TEAM_MEMBER_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2
  );

  /* Vertcal Industry Procedure for pre processing in case of
	delete resource team members */

  PROCEDURE  delete_team_members_pre
  (P_TEAM_ID              IN   JTF_RS_TEAM_MEMBERS.TEAM_ID%TYPE,
   P_TEAM_RESOURCE_ID     IN   JTF_RS_TEAM_MEMBERS.TEAM_RESOURCE_ID%TYPE,
   P_RESOURCE_TYPE        IN   JTF_RS_TEAM_MEMBERS.RESOURCE_TYPE%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2
  );


  /* Vertcal Industry Procedure for post processing in case of
	delete resource team members */

  PROCEDURE  delete_team_members_post
  (P_TEAM_ID              IN   JTF_RS_TEAM_MEMBERS.TEAM_ID%TYPE,
   P_TEAM_RESOURCE_ID     IN   JTF_RS_TEAM_MEMBERS.TEAM_RESOURCE_ID%TYPE,
   P_RESOURCE_TYPE        IN   JTF_RS_TEAM_MEMBERS.RESOURCE_TYPE%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2
  );

END jtf_rs_team_member_vuhk;

 

/
