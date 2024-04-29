--------------------------------------------------------
--  DDL for Package CSP_INV_LOC_ASSIGNMENTS_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_INV_LOC_ASSIGNMENTS_IUHK" AUTHID CURRENT_USER AS
 /* $Header: cspiilas.pls 115.4 2002/11/26 05:43:16 hhaugeru noship $ */

  /*****************************************************************************************
   This is the Vertical Industry User Hook API.
   The Vertical Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/
   G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_INV_LOC_ASSIGNMENT_IUHK';
    G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspiilas.pls';
  PROCEDURE create_inventory_location_Pre
  (
    x_return_status          out nocopy   VARCHAR2
  );


  PROCEDURE  create_inventory_location_post
  (
    x_return_status          out nocopy   VARCHAR2
  ) ;

  PROCEDURE  Update_inventory_location_pre
 (
    x_return_status          out nocopy   VARCHAR2
  ) ;


  PROCEDURE  Update_inventory_location_post
  (
    x_return_status          out nocopy   VARCHAR2
  ) ;
  PROCEDURE  Delete_inventory_location_pre
  (
    x_return_status          out nocopy   VARCHAR2
  ) ;
  PROCEDURE  Delete_inventory_location_post
  (
    x_return_status          out nocopy   VARCHAR2
  ) ;

  END csp_inv_loc_assignments_iuhk;

 

/
