--------------------------------------------------------
--  DDL for Package Body CSF_DEBRIEF_HEADERS_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_DEBRIEF_HEADERS_IUHK" AS
  /* $Header: csfidbhb.pls 115.4 2002/11/21 00:31:43 ibalint noship $ */

  /*****************************************************************************************
   This is the Interanl User Hook API.
   The Vertical Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/

  PROCEDURE Create_debrief_header_Pre
  (
    x_return_status          OUT NOCOPY   VARCHAR2
  ) IS
  BEGIN
    csf_debrief_pub.call_internal_hook('CSF_DEBRIEF_HEADERS_IUHK','INSERT_ROW','B',x_return_status);
  END Create_debrief_header_Pre;
  PROCEDURE  Create_debrief_header_post
  (
    x_return_status          OUT NOCOPY   VARCHAR2
  ) IS
  BEGIN
    csf_debrief_pub.call_internal_hook('CSF_DEBRIEF_HEADERS_IUHK','INSERT_ROW','A',x_return_status);
  END Create_debrief_header_post;

  PROCEDURE  Update_debrief_header_pre
  (
    x_return_status          OUT NOCOPY   VARCHAR2
  ) IS
  BEGIN
    csf_debrief_pub.call_internal_hook('CSF_DEBRIEF_HEADERS_IUHK','UPDATE_ROW','B',x_return_status);
  END Update_debrief_header_pre;
  PROCEDURE  Update_debrief_header_post
  (
    x_return_status          OUT NOCOPY   VARCHAR2
  ) IS
  BEGIN
    csf_debrief_pub.call_internal_hook('CSF_DEBRIEF_HEADERS_IUHK','UPDATE_ROW','A',x_return_status);
  END Update_debrief_header_post;
  PROCEDURE  Delete_debrief_header_pre
  (
    x_return_status          OUT NOCOPY   VARCHAR2
  ) IS
  BEGIN
    csf_debrief_pub.call_internal_hook('CSF_DEBRIEF_HEADERS_IUHK','DELETE_ROW','B',x_return_status);
  END  Delete_debrief_header_pre;
  PROCEDURE  Delete_debrief_header_post
  (
    x_return_status          OUT NOCOPY   VARCHAR2
  ) IS
  BEGIN
    csf_debrief_pub.call_internal_hook('CSF_DEBRIEF_HEADERS_IUHK','DELETE_ROW','A',x_return_status);
  END Delete_debrief_header_post;
END csf_debrief_headers_iuhk;

/
