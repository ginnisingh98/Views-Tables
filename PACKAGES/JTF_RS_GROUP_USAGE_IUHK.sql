--------------------------------------------------------
--  DDL for Package JTF_RS_GROUP_USAGE_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_GROUP_USAGE_IUHK" AUTHID CURRENT_USER AS
  /* $Header: jtfrsnas.pls 120.0 2005/05/11 08:20:40 appldev ship $ */

  /*****************************************************************************************
   This is the Internal Industry User Hook API.
   The Internal Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/

  /* Internal Industry Procedure for pre processing in case of
	create resource group usage */

  PROCEDURE  create_group_usage_pre
  (P_GROUP_ID             IN   NUMBER,
   P_USAGE                IN   VARCHAR2,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  );


  /* Internal Industry Procedure for post processing in case of
	create resource group usage */

  PROCEDURE  create_group_usage_post
  (P_GROUP_USAGE_ID       IN   NUMBER,
   P_GROUP_ID             IN   NUMBER,
   P_USAGE                IN   VARCHAR2,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  );


  /* Internal Industry Procedure for pre processing in case of
	delete resource group usage */

  PROCEDURE  delete_group_usage_pre
  (P_GROUP_ID             IN   NUMBER,
   P_USAGE                IN   VARCHAR2,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  );


  /* Internal Industry Procedure for post processing in case of
	delete resource group usage */

  PROCEDURE  delete_group_usage_post
  (P_GROUP_ID             IN   NUMBER,
   P_USAGE                IN   VARCHAR2,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  );


END jtf_rs_group_usage_iuhk;

 

/
