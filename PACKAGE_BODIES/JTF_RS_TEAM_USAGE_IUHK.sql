--------------------------------------------------------
--  DDL for Package Body JTF_RS_TEAM_USAGE_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_TEAM_USAGE_IUHK" AS
  /* $Header: jtfrsnjb.pls 120.0 2005/05/11 08:20:49 appldev ship $ */

  /*****************************************************************************************
   This is the Internal Industry User Hook API.
   The Internal Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/

  /* Internal Industry Procedure for pre processing in case of
	create resource team usage */

  PROCEDURE  create_team_usage_pre
  (P_TEAM_ID              IN   NUMBER,
   P_USAGE                IN   VARCHAR2,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  ) IS

  BEGIN

    null;

  END;


  /* Internal Industry Procedure for post processing in case of
	create resource team usage */

  PROCEDURE  create_team_usage_post
  (P_TEAM_USAGE_ID        IN   NUMBER,
   P_TEAM_ID              IN   NUMBER,
   P_USAGE                IN   VARCHAR2,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  ) IS

  BEGIN

    null;

  END;


  /* Internal Industry Procedure for pre processing in case of
	delete resource team usage */

  PROCEDURE  delete_team_usage_pre
  (P_TEAM_ID              IN   NUMBER,
   P_USAGE                IN   VARCHAR2,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  ) IS

  BEGIN

    null;

  END;


  /* Internal Industry Procedure for post processing in case of
	delete resource team usage */

  PROCEDURE  delete_team_usage_post
  (P_TEAM_ID              IN   NUMBER,
   P_USAGE                IN   VARCHAR2,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    null;

  END;


END jtf_rs_team_usage_iuhk;

/
