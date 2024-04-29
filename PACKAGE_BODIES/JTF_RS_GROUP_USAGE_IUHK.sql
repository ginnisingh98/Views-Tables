--------------------------------------------------------
--  DDL for Package Body JTF_RS_GROUP_USAGE_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_GROUP_USAGE_IUHK" AS
  /* $Header: jtfrsnab.pls 120.0 2005/05/11 08:20:39 appldev ship $ */

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
  ) IS

  BEGIN

    null;

  END;


  /* Internal Industry Procedure for post processing in case of
	create resource group usage */

  PROCEDURE  create_group_usage_post
  (P_GROUP_USAGE_ID       IN   NUMBER,
   P_GROUP_ID             IN   NUMBER,
   P_USAGE                IN   VARCHAR2,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  ) IS

  BEGIN

    null;

  END;


  /* Internal Industry Procedure for pre processing in case of
	delete resource group usage */

  PROCEDURE  delete_group_usage_pre
  (P_GROUP_ID             IN   NUMBER,
   P_USAGE                IN   VARCHAR2,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  ) IS

  BEGIN

    null;

  END;


  /* Internal Industry Procedure for post processing in case of
	delete resource group usage */

  PROCEDURE  delete_group_usage_post
  (P_GROUP_ID             IN   NUMBER,
   P_USAGE                IN   VARCHAR2,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  ) IS

  BEGIN

    null;

  END;


END jtf_rs_group_usage_iuhk;

/
