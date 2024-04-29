--------------------------------------------------------
--  DDL for Package JTF_RS_RESOURCE_VALUES_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_RESOURCE_VALUES_IUHK" AUTHID CURRENT_USER AS
  /* $Header: jtfrsncs.pls 120.0 2005/05/11 08:20:41 appldev ship $ */

  /*****************************************************************************************
   This is the Internal User Hook API.
   The Internal Groups can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/

   G_PKG_NAME	CONSTANT	VARCHAR2(30) := 'JTF_RS_RESOURCE_VALUES_IUHK';

  /* Internal Procedure for pre processing in case of create resource values */

  PROCEDURE  create_rs_resource_values_pre (
     X_Return_Status           OUT NOCOPY    VARCHAR2
  );

  /* Internal Procedure for post processing in case of create resource values */

  PROCEDURE  create_rs_resource_values_post (
     X_Return_Status           OUT NOCOPY    VARCHAR2
  );

 /* Internal Procedure for pre processing in case of update resource values */

  PROCEDURE  update_rs_resource_values_pre (
     X_Return_Status           OUT NOCOPY    VARCHAR2
  );

 /* Internal Procedure for post processing in case of update resource values */

  PROCEDURE  update_rs_resource_values_post (
     X_Return_Status           OUT NOCOPY    VARCHAR2
  );

 /* Internal Procedure for pre processing in case of delete resource values */

  PROCEDURE  delete_rs_resource_values_pre (
     X_Return_Status           OUT NOCOPY    VARCHAR2
  );

 /* Internal Procedure for post processing in case of delete resource values */

  PROCEDURE  delete_rs_resource_values_post (
     X_Return_Status           OUT NOCOPY    VARCHAR2
  );

 /* Internal Procedure for pre processing in case of delete all resource values */

  PROCEDURE  delete_all_rs_values_pre (
     X_Return_Status           	OUT NOCOPY    VARCHAR2
  );

 /* Internal Procedure for post processing in case of delete all resource values */

  PROCEDURE  delete_all_rs_values_post (
     X_Return_Status           	OUT NOCOPY    VARCHAR2
  );

END jtf_rs_resource_values_iuhk;

 

/
