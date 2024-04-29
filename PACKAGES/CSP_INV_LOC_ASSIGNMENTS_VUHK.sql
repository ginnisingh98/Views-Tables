--------------------------------------------------------
--  DDL for Package CSP_INV_LOC_ASSIGNMENTS_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_INV_LOC_ASSIGNMENTS_VUHK" AUTHID CURRENT_USER AS
 /* $Header: cspvilas.pls 115.4 2002/11/26 07:21:24 hhaugeru noship $ */

  /*****************************************************************************************
   This is the Vertical Industry User Hook API.
   The Vertical Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/


 G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_INV_LOC_ASSIGNMENT_VUHK';
    G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspvilas.pls';

  PROCEDURE create_inventory_location_Pre
  (
    px_inv_loc_assignment    IN OUT NOCOPY   CSP_INV_LOC_ASSIGNMENTS_PKG.inv_loc_assignments_rec_type,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;





  PROCEDURE  create_inventory_location_post
  (
    px_inv_loc_assignment    IN OUT NOCOPY   CSP_INV_LOC_ASSIGNMENTS_PKG.inv_loc_assignments_rec_type,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;






  PROCEDURE  Update_inventory_location_pre
  (
    px_inv_loc_assignment    IN OUT NOCOPY  CSP_INV_LOC_ASSIGNMENTS_PKG.inv_loc_assignments_rec_type,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;


  PROCEDURE  Update_inventory_location_post
  (
    px_inv_loc_assignment    IN OUT NOCOPY   CSP_INV_LOC_ASSIGNMENTS_PKG.inv_loc_assignments_rec_type,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;
  PROCEDURE  Delete_inventory_location_pre
  (
    p_inv_loc_assignment_id  IN   NUMBER,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;
  PROCEDURE  Delete_inventory_location_post
  (
    p_inv_loc_assignment_id  IN   NUMBER,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;

  END csp_inv_loc_assignments_vuhk;

 

/
