--------------------------------------------------------
--  DDL for Package Body JTF_RS_TEAM_MEMBER_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_TEAM_MEMBER_IUHK" AS
  /* $Header: jtfrsneb.pls 120.0 2005/05/11 08:20:42 appldev ship $ */

  /*****************************************************************************************
   This is the Internal Industry User Hook API.
   The Internal Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/

  /* Internal Industry Procedure for pre processing in case of
	create resource team members */

  PROCEDURE  create_team_members_pre
  (P_TEAM_ID              IN   JTF_RS_TEAM_MEMBERS.TEAM_ID%TYPE,
   P_TEAM_RESOURCE_ID     IN   JTF_RS_TEAM_MEMBERS.TEAM_RESOURCE_ID%TYPE,
   P_RESOURCE_TYPE        IN   JTF_RS_TEAM_MEMBERS.RESOURCE_TYPE%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  ) IS

  BEGIN

    null;

  END;


  /* Internal Industry Procedure for post processing in case of
	create resource team members */

  PROCEDURE  create_team_members_post
  (P_TEAM_MEMBER_ID       IN   JTF_RS_TEAM_MEMBERS.TEAM_MEMBER_ID%TYPE,
   P_TEAM_ID              IN   JTF_RS_TEAM_MEMBERS.TEAM_ID%TYPE,
   P_TEAM_RESOURCE_ID     IN   JTF_RS_TEAM_MEMBERS.TEAM_RESOURCE_ID%TYPE,
   P_RESOURCE_TYPE        IN   JTF_RS_TEAM_MEMBERS.RESOURCE_TYPE%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  ) IS

  BEGIN

    null;

  END;


  /* Internal Industry Procedure for pre processing in case of
	update resource team members */

  PROCEDURE  update_team_members_pre
  (P_TEAM_MEMBER_ID              IN   JTF_RS_TEAM_MEMBERS.TEAM_MEMBER_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  ) IS

  BEGIN
    null;
  END;


  /* Internal Industry Procedure for post processing in case of
	update resource team members */

  PROCEDURE  update_team_members_post
  (P_TEAM_MEMBER_ID       IN   JTF_RS_TEAM_MEMBERS.TEAM_MEMBER_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  ) IS

  BEGIN
    null;
  END;


  /* Internal Industry Procedure for pre processing in case of
	delete resource team members */

  PROCEDURE  delete_team_members_pre
  (P_TEAM_ID              IN   JTF_RS_TEAM_MEMBERS.TEAM_ID%TYPE,
   P_TEAM_RESOURCE_ID     IN   JTF_RS_TEAM_MEMBERS.TEAM_RESOURCE_ID%TYPE,
   P_RESOURCE_TYPE        IN   JTF_RS_TEAM_MEMBERS.RESOURCE_TYPE%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  ) IS

  BEGIN

    null;

  END;


  /* Internal Industry Procedure for post processing in case of
	delete resource team members */

  PROCEDURE  delete_team_members_post
  (P_TEAM_ID              IN   JTF_RS_TEAM_MEMBERS.TEAM_ID%TYPE,
   P_TEAM_RESOURCE_ID     IN   JTF_RS_TEAM_MEMBERS.TEAM_RESOURCE_ID%TYPE,
   P_RESOURCE_TYPE        IN   JTF_RS_TEAM_MEMBERS.RESOURCE_TYPE%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    null;

  END;

END jtf_rs_team_member_iuhk;

/
