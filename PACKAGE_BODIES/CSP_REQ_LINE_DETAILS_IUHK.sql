--------------------------------------------------------
--  DDL for Package Body CSP_REQ_LINE_DETAILS_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_REQ_LINE_DETAILS_IUHK" AS
 /* $Header: cspirldb.pls 120.0 2005/05/24 19:11:02 appldev noship $ */

  /*****************************************************************************************
   This is the Internal Hook API.
   The Vertical Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspirldb.pls';
  PROCEDURE Create_req_line_detail_Pre
  (
    x_return_status          out nocopy   VARCHAR2
  ) IS
  BEGIN
  csp_ship_to_address_pvt.call_internal_hook('CSP_REQ_LINE_DETAILS_PKG','INSERT_ROW','B',x_return_status);
  END Create_req_line_detail_Pre;

  PROCEDURE  Create_req_line_detail_post
  (
    x_return_status          out nocopy   VARCHAR2
  ) IS
  BEGIN
    csp_ship_to_address_pvt.call_internal_hook('CSP_REQ_LINE_DETAILS_PKG','INSERT_ROW','A',x_return_status);
  END Create_req_line_detail_post;

  PROCEDURE  Update_req_line_detail_pre
  (
    x_return_status          out nocopy   VARCHAR2
  ) IS
  BEGIN
    csp_ship_to_address_pvt.call_internal_hook('CSP_REQ_LINE_DETAILS_PKG','UPDATE_ROW','B',x_return_status);
  END Update_req_line_detail_pre;

  PROCEDURE  Update_req_line_detail_post
  (
    x_return_status          out nocopy   VARCHAR2
  ) IS
  BEGIN
    csp_ship_to_address_pvt.call_internal_hook('CSP_REQ_LINE_DETAILS_PKG','UPDATE_ROW','A',x_return_status);
  END Update_req_line_detail_post;
  PROCEDURE  Delete_req_line_detail_pre
  (
    x_return_status          out nocopy   VARCHAR2
  ) IS
  BEGIN
    csp_ship_to_address_pvt.call_internal_hook('CSP_REQ_LINE_DETAILS_PKG','DELETE_ROW','B',x_return_status);
  END Delete_req_line_detail_pre;
  PROCEDURE  Delete_req_line_detail_post
 (
    x_return_status          out nocopy   VARCHAR2
  ) IS
  BEGIN
    csp_ship_to_address_pvt.call_internal_hook('CSP_REQ_LINE_DETAILS_PKG','DELETE_ROW','A',x_return_status);
  END Delete_req_line_detail_post;
END CSP_REQ_LINE_DETAILS_IUHK;

/
