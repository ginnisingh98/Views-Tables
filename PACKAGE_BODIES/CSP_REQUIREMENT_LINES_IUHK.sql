--------------------------------------------------------
--  DDL for Package Body CSP_REQUIREMENT_LINES_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_REQUIREMENT_LINES_IUHK" AS
 /* $Header: cspirqlb.pls 115.4 2002/11/26 05:44:02 hhaugeru noship $ */

  /*****************************************************************************************
   This is the Internal Hook API.
   The Vertical Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspirqlb.pls';
  PROCEDURE Create_requirement_line_Pre
  (
    x_return_status          out nocopy   VARCHAR2
  ) IS
  BEGIN
  csp_ship_to_address_pvt.call_internal_hook('CSP_REQUIREMENT_LINES_PKG','INSERT_ROW','B',x_return_status);
  END Create_requirement_line_Pre;

  PROCEDURE  Create_requirement_line_post
  (
    x_return_status          out nocopy   VARCHAR2
  ) IS
  BEGIN
    csp_ship_to_address_pvt.call_internal_hook('CSP_REQUIREMENT_LINES_PKG','INSERT_ROW','A',x_return_status);
  END Create_requirement_line_post;

  PROCEDURE  Update_requirement_line_pre
  (
    x_return_status          out nocopy   VARCHAR2
  ) IS
  BEGIN
    csp_ship_to_address_pvt.call_internal_hook('CSP_REQUIREMENT_LINES_PKG','UPDATE_ROW','B',x_return_status);
  END Update_requirement_line_pre;

  PROCEDURE  Update_requirement_line_post
  (
    x_return_status          out nocopy   VARCHAR2
  ) IS
  BEGIN
    csp_ship_to_address_pvt.call_internal_hook('CSP_REQUIREMENT_LINES_PKG','UPDATE_ROW','A',x_return_status);
  END Update_requirement_line_post;
  PROCEDURE  Delete_requirement_line_pre
  (
    x_return_status          out nocopy   VARCHAR2
  ) IS
  BEGIN
    csp_ship_to_address_pvt.call_internal_hook('CSP_REQUIREMENT_LINES_PKG','DELETE_ROW','B',x_return_status);
  END Delete_requirement_line_pre;
  PROCEDURE  Delete_requirement_line_post
 (
    x_return_status          out nocopy   VARCHAR2
  ) IS
  BEGIN
    csp_ship_to_address_pvt.call_internal_hook('CSP_REQUIREMENT_LINES_PKG','DELETE_ROW','A',x_return_status);
  END Delete_requirement_line_post;
END csp_requirement_lines_iuhk;

/
