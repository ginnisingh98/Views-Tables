--------------------------------------------------------
--  DDL for Package JTF_RS_GROUP_USAGE_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_GROUP_USAGE_CUHK" AUTHID CURRENT_USER AS
  /* $Header: jtfrscas.pls 120.0 2005/05/11 08:19:35 appldev ship $ */

  /*****************************************************************************************
   This is the Customer User Hook API.
   The Customers can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/

  /* Customer Procedure for pre processing in case of
	create resource group usages */

  PROCEDURE  create_group_usage_pre
  (P_GROUP_ID             IN   NUMBER,
   P_USAGE                IN   VARCHAR2,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  );


  /* Customer Procedure for post processing in case of
	create resource group usage */

  PROCEDURE  create_group_usage_post
  (P_GROUP_USAGE_ID       IN   NUMBER,
   P_GROUP_ID             IN   NUMBER,
   P_USAGE                IN   VARCHAR2,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  );


  /* Customer Procedure for pre processing in case of
	delete resource group usage */

  PROCEDURE  delete_group_usage_pre
  (P_GROUP_ID             IN   NUMBER,
   P_USAGE                IN   VARCHAR2,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  );


  /* Customer Procedure for post processing in case of
	delete resource group usage */

  PROCEDURE  delete_group_usage_post
  (P_GROUP_ID             IN   NUMBER,
   P_USAGE                IN   VARCHAR2,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  );



  /* Customer/Vertical Industry Function before Message Generation */

  FUNCTION ok_to_generate_msg
  (P_GROUP_USAGE_ID       IN   NUMBER,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN;



END jtf_rs_group_usage_cuhk;

 

/
