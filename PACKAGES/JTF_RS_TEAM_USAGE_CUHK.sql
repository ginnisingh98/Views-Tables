--------------------------------------------------------
--  DDL for Package JTF_RS_TEAM_USAGE_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_TEAM_USAGE_CUHK" AUTHID CURRENT_USER AS
  /* $Header: jtfrscjs.pls 120.0 2005/05/11 08:19:40 appldev ship $ */

  /*****************************************************************************************
   This is the Customer User Hook API.
   The Customers can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/

  /* Customer Procedure for pre processing in case of
	create resource team usages */

  PROCEDURE  create_team_usage_pre
  (P_TEAM_ID              IN   NUMBER,
   P_USAGE                IN   VARCHAR2,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2
  );


  /* Customer Procedure for post processing in case of
	create resource team usage */

  PROCEDURE  create_team_usage_post
  (P_TEAM_USAGE_ID        IN   NUMBER,
   P_TEAM_ID              IN   NUMBER,
   P_USAGE                IN   VARCHAR2,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  );


  /* Customer Procedure for pre processing in case of
	delete resource team usage */

  PROCEDURE  delete_team_usage_pre
  (P_TEAM_ID              IN   NUMBER,
   P_USAGE                IN   VARCHAR2,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  );


  /* Customer Procedure for post processing in case of
	delete resource team usage */

  PROCEDURE  delete_team_usage_post
  (P_TEAM_ID              IN   NUMBER,
   P_USAGE                IN   VARCHAR2,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  );



  /* Customer/Vertical Industry Function before Message Generation */

  FUNCTION ok_to_generate_msg
  (P_TEAM_USAGE_ID        IN   NUMBER,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN;



END jtf_rs_team_usage_cuhk;

 

/
