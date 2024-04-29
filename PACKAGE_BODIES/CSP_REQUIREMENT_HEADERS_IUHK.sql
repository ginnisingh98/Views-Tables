--------------------------------------------------------
--  DDL for Package Body CSP_REQUIREMENT_HEADERS_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_REQUIREMENT_HEADERS_IUHK" AS
 /* $Header: cspirqhb.pls 115.3 2002/11/26 05:43:33 hhaugeru noship $ */

  /*****************************************************************************************
   This is the Internal Hook API.
   The Vertical Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspirqhb.pls';
  PROCEDURE Create_requirement_header_Pre
  (
    x_return_status          out nocopy   VARCHAR2
  ) IS
  BEGIN
  csp_ship_to_address_pvt.call_internal_hook('CSP_REQUIREMENT_HEADERS_PKG','INSERT_ROW','B',x_return_status);
  END Create_requirement_header_Pre;

  PROCEDURE  Create_requirement_header_post
  (
    x_return_status          out nocopy   VARCHAR2
  ) IS
  BEGIN
    csp_ship_to_address_pvt.call_internal_hook('CSP_REQUIREMENT_HEADERS_PKG','INSERT_ROW','A',x_return_status);
  END Create_requirement_header_Post;

  PROCEDURE  Update_requirement_header_pre
  (
    x_return_status          out nocopy   VARCHAR2
  ) IS
  BEGIN
    csp_ship_to_address_pvt.call_internal_hook('CSP_REQUIREMENT_HEADERS_PKG','UPDATE_ROW','B',x_return_status);
  END Update_requirement_header_Pre;

  PROCEDURE  Update_requirement_header_post
  (
    x_return_status          out nocopy   VARCHAR2
  ) IS
  BEGIN
    csp_ship_to_address_pvt.call_internal_hook('CSP_REQUIREMENT_HEADERS_PKG','UPDATE_ROW','A',x_return_status);
  END Update_requirement_header_post;
  PROCEDURE  Delete_requirement_header_pre
  (
    x_return_status          out nocopy   VARCHAR2
  ) IS
  BEGIN
    csp_ship_to_address_pvt.call_internal_hook('CSP_REQUIREMENT_HEADERS_PKG','DELETE_ROW','B',x_return_status);
  END Delete_requirement_header_pre;
  PROCEDURE  Delete_requirement_header_post
 (
    x_return_status          out nocopy   VARCHAR2
  ) IS
  BEGIN
    csp_ship_to_address_pvt.call_internal_hook('CSP_REQUIREMENT_HEADERS_PKG','DELETE_ROW','A',x_return_status);
  END Delete_requirement_header_post;
END csp_requirement_headers_iuhk;

/
