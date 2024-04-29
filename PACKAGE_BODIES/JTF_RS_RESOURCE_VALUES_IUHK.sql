--------------------------------------------------------
--  DDL for Package Body JTF_RS_RESOURCE_VALUES_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_RESOURCE_VALUES_IUHK" AS
  /* $Header: jtfrsncb.pls 120.0 2005/05/11 08:20:41 appldev ship $ */

  /*****************************************************************************************
   This is the Internal User Hook API.
   The Internal Groups can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/

  /* Internal Procedure for pre processing in case of create resource values */

  PROCEDURE  create_rs_resource_values_pre (
     X_Return_Status           OUT NOCOPY    VARCHAR2
  ) IS

   BEGIN
      jtf_resource_utl.call_internal_hook (
         'JTF_RS_RESOURCE_VALUES_PVT',
         'CREATE_RS_RESOURCE_VALUES',
         'B',
         x_return_status
      );
   END create_rs_resource_values_pre;

  /* Internal Procedure for post processing in case of create resource values */

  PROCEDURE  create_rs_resource_values_post (
     X_Return_Status           OUT NOCOPY    VARCHAR2
  ) IS

   BEGIN
      jtf_resource_utl.call_internal_hook (
         'JTF_RS_RESOURCE_VALUES_PVT',
         'CREATE_RS_RESOURCE_VALUES',
         'A',
         x_return_status
      );

   END create_rs_resource_values_post;

 /* Internal Procedure for pre processing in case of update resource values */

  PROCEDURE  update_rs_resource_values_pre (
     X_Return_Status           OUT NOCOPY    VARCHAR2
  ) IS

   BEGIN
      jtf_resource_utl.call_internal_hook (
         'JTF_RS_RESOURCE_VALUES_PVT',
         'UPDATE_RS_RESOURCE_VALUES',
         'B',
         x_return_status
      );
   END update_rs_resource_values_pre;

 /* Internal Procedure for post processing in case of update resource values */

  PROCEDURE  update_rs_resource_values_post (
     X_Return_Status           OUT NOCOPY    VARCHAR2
  ) IS

   BEGIN
      jtf_resource_utl.call_internal_hook (
         'JTF_RS_RESOURCE_VALUES_PVT',
         'UPDATE_RS_RESOURCE_VALUES',
         'A',
         x_return_status
      );
   END update_rs_resource_values_post;

 /* Internal Procedure for pre processing in case of delete resource values */

  PROCEDURE  delete_rs_resource_values_pre (
     X_Return_Status           OUT NOCOPY    VARCHAR2
  ) IS

   BEGIN
      jtf_resource_utl.call_internal_hook (
         'JTF_RS_RESOURCE_VALUES_PVT',
         'DELETE_RS_RESOURCE_VALUES',
         'B',
         x_return_status
      );
   END delete_rs_resource_values_pre;

 /* Internal Procedure for post processing in case of delete resource values */

  PROCEDURE  delete_rs_resource_values_post (
     X_Return_Status           OUT NOCOPY    VARCHAR2
  ) IS

   BEGIN
      jtf_resource_utl.call_internal_hook (
         'JTF_RS_RESOURCE_VALUES_PVT',
         'DELETE_RS_RESOURCE_VALUES',
         'A',
         x_return_status
      );

   END delete_rs_resource_values_post;

 /* Internal Procedure for pre processing in case of delete all resource values */

  PROCEDURE  delete_all_rs_values_pre (
     X_Return_Status           	OUT NOCOPY    VARCHAR2
  ) IS

   BEGIN
      jtf_resource_utl.call_internal_hook (
         'JTF_RS_RESOURCE_VALUES_PVT',
         'DELETE_ALL_RS_VALUES',
         'B',
         x_return_status
      );
   END delete_all_rs_values_pre;

 /* Internal Procedure for post processing in case of delete all resource values */

  PROCEDURE  delete_all_rs_values_post (
     X_Return_Status           	OUT NOCOPY    VARCHAR2
  ) IS

   BEGIN
      jtf_resource_utl.call_internal_hook (
         'JTF_RS_RESOURCE_VALUES_PVT',
         'DELETE_ALL_RS_VALUES',
         'A',
         x_return_status
      );

   END delete_all_rs_values_post;

END jtf_rs_resource_values_iuhk;

/
