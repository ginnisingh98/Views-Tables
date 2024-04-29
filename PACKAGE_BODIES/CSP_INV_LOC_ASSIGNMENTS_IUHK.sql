--------------------------------------------------------
--  DDL for Package Body CSP_INV_LOC_ASSIGNMENTS_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_INV_LOC_ASSIGNMENTS_IUHK" AS
 /* $Header: cspiilab.pls 115.3 2002/11/26 05:42:41 hhaugeru noship $ */

  /*****************************************************************************************
   This is the Vertical Industry User Hook API.
   The Vertical Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/

    G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspiilab.pls';
  PROCEDURE create_inventory_location_Pre
  (
    x_return_status          out nocopy   VARCHAR2
  ) IS
  BEGIN
    csp_ship_to_address_pvt.call_internal_hook('CSP_INV_LOC_ASSIGNMENTS_IUHK','INSERT_ROW','B',x_return_status);
  END create_inventory_location_Pre;


  PROCEDURE  create_inventory_location_post
  (
    x_return_status          out nocopy   VARCHAR2
  ) IS
  BEGIN
    csp_ship_to_address_pvt.call_internal_hook('CSP_INV_LOC_ASSIGNMENTS_IUHK','INSERT_ROW','A',x_return_status);
  END create_inventory_location_post;

  PROCEDURE  Update_inventory_location_pre
 (
    x_return_status          out nocopy   VARCHAR2
  ) IS
  BEGIN
    csp_ship_to_address_pvt.call_internal_hook('CSP_INV_LOC_ASSIGNMENTS_IUHK','UPDATE_ROW','B',x_return_status);
  END Update_inventory_location_pre;


  PROCEDURE  Update_inventory_location_post
  (
    x_return_status          out nocopy   VARCHAR2
  ) IS
  BEGIN
    csp_ship_to_address_pvt.call_internal_hook('CSP_INV_LOC_ASSIGNMENTS_IUHK','UPDATE_ROW','A',x_return_status);
  END Update_inventory_location_post;
  PROCEDURE  Delete_inventory_location_pre
  (
    x_return_status          out nocopy   VARCHAR2
  ) IS
  BEGIN
    csp_ship_to_address_pvt.call_internal_hook('CSP_INV_LOC_ASSIGNMENTS_IUHK','DELETE_ROW','B',x_return_status);
  END Delete_inventory_location_pre;
  PROCEDURE  Delete_inventory_location_post
  (
    x_return_status          out nocopy   VARCHAR2
  ) IS
  BEGIN
    csp_ship_to_address_pvt.call_internal_hook('CSP_INV_LOC_ASSIGNMENTS_IUHK','DELETE_ROW','A',x_return_status);
  END Delete_inventory_location_post;

  END csp_inv_loc_assignments_iuhk;

/
