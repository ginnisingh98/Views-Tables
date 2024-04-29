--------------------------------------------------------
--  DDL for Package GMI_RESERVATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_RESERVATION_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMIVRSVS.pls 115.12 2003/01/15 21:05:46 nchekuri ship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIVRSVS.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private procedures relating to OPM            |
 |     reservation.                                                        |
 |                                                                         |
 | - Query_Reservation                                                     |
 | - Create_Reservation                                                    |
 | - Update_Reservation                                                    |
 | - Delete_Reservation                                                    |
 | - Transfer_Reservation                                                  |
 | - Check_Shipping_Details                                                |
 | - Calculate Prior Reservations
 |                                                                         |
 | HISTORY                                                                 |
 |     21-FEB-2000  odaboval        Created                                |
 |     09/10/01 BUG#:1941429 Added code to support cross_docking           |
 |     03-OCT-2001  odaboval, local fix for bug 2025611                    |
 |                           added procedure Check_Shipping_Details        |
 |     13-JAN-2003  NC Added Calculate_prior_reservations Bug#2670928      |
 |									   |
 +=========================================================================+
  API Name  : GMI_Reservation_PVT
  Type      : Private
  Function  : This package contains Private procedures used to
              OPM reservation process.
 -
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0
*/


/*
TYPE ic_tran_pnd_tbl IS TABLE OF ic_tran_pnd%ROWTYPE
                     INDEX BY BINARY_INTEGER;

l_ic_tran_pnd_tbl ic_tran_pnd_tbl;


p_tran_rec ic_tran_pnd%rowtype;

p_tran_tbl is table of p_tran_rec index by binary_integer;
*/

PROCEDURE Query_Reservation
  (
     x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_validation_flag               IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_query_input                   IN  inv_reservation_global.mtl_reservation_rec_type
   , p_lock_records                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_mtl_reservation_tbl           OUT NOCOPY inv_reservation_global.mtl_reservation_tbl_type
   , x_mtl_reservation_tbl_count     OUT NOCOPY NUMBER
   , x_error_code                    OUT NOCOPY NUMBER
   );

PROCEDURE Create_Reservation
  (
     x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_validation_flag               IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_rsv_rec                       IN  inv_reservation_global.mtl_reservation_rec_type
   , p_serial_number                 IN  inv_reservation_global.serial_number_tbl_type
   , x_serial_number                 OUT NOCOPY inv_reservation_global.serial_number_tbl_type
   , p_partial_reservation_flag      IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_force_reservation_flag        IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_quantity_reserved             OUT NOCOPY NUMBER
   , x_reservation_id                OUT NOCOPY NUMBER
  );

PROCEDURE Update_Reservation
  (
     x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_validation_flag               IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_original_rsv_rec              IN  inv_reservation_global.mtl_reservation_rec_type
   , p_to_rsv_rec                    IN  inv_reservation_global.mtl_reservation_rec_type
   , p_original_serial_number        IN  inv_reservation_global.serial_number_tbl_type
   , p_to_serial_number              IN  inv_reservation_global.serial_number_tbl_type
   );

PROCEDURE Delete_Reservation
  (
     x_return_status            OUT NOCOPY VARCHAR2
   , x_msg_count                OUT NOCOPY NUMBER
   , x_msg_data                 OUT NOCOPY VARCHAR2
   , p_validation_flag          IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_rsv_rec                  IN  inv_reservation_global.mtl_reservation_rec_type
   , p_serial_number            IN  inv_reservation_global.serial_number_tbl_type
   );

PROCEDURE Transfer_Reservation
  (
     p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_validation_flag               IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_is_transfer_supply            IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_original_rsv_rec              IN  inv_reservation_global.mtl_reservation_rec_type
   , p_to_rsv_rec                    IN  inv_reservation_global.mtl_reservation_rec_type
   , p_original_serial_number        IN  inv_reservation_global.serial_number_tbl_type
   , p_to_serial_number              IN  inv_reservation_global.serial_number_tbl_type
   , x_to_reservation_id             OUT NOCOPY NUMBER
   );

-- HW BUG#:1941429 procedure to calculate qty reserved for cross_docking
  PROCEDURE Calculate_Reservation(
     p_organization_id         IN NUMBER,
     p_item_id                 IN NUMBER,
     p_demand_source_line_id   IN NUMBER,
     p_delivery_detail_id      IN NUMBER,
     p_requested_quantity      IN NUMBER,
     p_requested_quantity2     IN NUMBER DEFAULT NULL,
     x_result_qty1             OUT NOCOPY NUMBER,
     x_result_qty2             OUT NOCOPY NUMBER
     );

PROCEDURE Check_Shipping_Details
   ( p_rsv_rec                  IN  inv_reservation_global.mtl_reservation_rec_type
   , x_return_status            OUT NOCOPY VARCHAR2
   , x_msg_count                OUT NOCOPY NUMBER
   , x_msg_data                 OUT NOCOPY VARCHAR2
   );

PROCEDURE query_qty_for_ATP(
   p_organization_id         IN NUMBER,
   p_item_id                 IN NUMBER,
   p_demand_source_line_id   IN NUMBER,
   x_onhand_qty1             OUT NOCOPY NUMBER,
   x_onhand_qty2             OUT NOCOPY NUMBER,
   x_avail_qty1              OUT NOCOPY NUMBER,
   x_avail_qty2              OUT NOCOPY NUMBER
   );

/* NC Added for prior reservations project Bug#2670928 */
PROCEDURE Calculate_Prior_Reservations(
   p_organization_id         IN NUMBER
  ,p_item_id                 IN NUMBER
  ,p_demand_source_line_id   IN NUMBER
  ,p_delivery_detail_id      IN NUMBER
  ,p_requested_quantity      IN NUMBER
  ,p_requested_quantity2     IN NUMBER DEFAULT NULL
  ,x_result_qty1             OUT NOCOPY NUMBER
  ,x_result_qty2             OUT NOCOPY NUMBER
  ,x_return_status           OUT NOCOPY VARCHAR2
  ,x_msg_count               OUT NOCOPY NUMBER
  ,x_msg_data                OUT NOCOPY VARCHAR2
  );

END GMI_Reservation_PVT;

 

/
