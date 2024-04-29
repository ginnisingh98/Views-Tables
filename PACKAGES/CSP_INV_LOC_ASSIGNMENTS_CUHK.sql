--------------------------------------------------------
--  DDL for Package CSP_INV_LOC_ASSIGNMENTS_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_INV_LOC_ASSIGNMENTS_CUHK" AUTHID CURRENT_USER AS
  /* $Header: cspcilas.pls 115.4 2002/11/26 08:07:14 hhaugeru noship $ */

  /*****************************************************************************************
   This is the Vertical Industry User Hook API.
   The Vertical Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/

    G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_INV_LOC_ASSIGNMENT_CUHK';
    G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspcilas.pls';

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

  END csp_inv_loc_assignments_cuhk;

 

/
