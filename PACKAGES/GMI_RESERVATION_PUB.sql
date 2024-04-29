--------------------------------------------------------
--  DDL for Package GMI_RESERVATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_RESERVATION_PUB" AUTHID CURRENT_USER AS
/*  $Header: GMIPRSVS.pls 120.0 2005/05/26 00:12:50 appldev noship $
+=========================================================================+
|                Copyright (c) 2000 Oracle Corporation                    |
|                        TVP, Reading, England                            |
|                         All rights reserved                             |
+=========================================================================+
| FILENAME                                                                |
|    GMIPRSVS.pls                                                         |
|                                                                         |
| DESCRIPTION                                                             |
|     This package contains public procedures relating to OPM             |
|     reservation.                                                        |
|                                                                         |
| - Query_Reservation                                                     |
| - Create_Reservation                                                    |
| - Update_Reservation                                                    |
| - Delete_Reservation                                                    |
| - Transfer_Reservation                                                  |
|                                                                         |
|                                                                         |
| HISTORY                                                                 |
|     21-FEB-2000  odaboval        Created                                |
|   								            |
+=========================================================================+
 API Name  : GMI_Reservation_PUB
 Type      : Global
 Function  : This package contains Global procedures used to
             OPM reservation process.

 Pre-reqs  : N/A
 Parameters: Per function

 Current Vers  : 1.0

*/
/*
 Global Variable Useful in the Branching Logic :
organization_id  NUMBER;
oe_line_id       NUMBER;
*/


PROCEDURE Query_Reservation
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_validation_flag               IN  VARCHAR2 DEFAULT FND_API.G_TRUE
   , p_query_input                   IN  inv_reservation_global.mtl_reservation_rec_type
   , p_lock_records                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_sort_by_req_date              IN  NUMBER   DEFAULT inv_reservation_global.g_query_no_sort
   , p_cancel_order_mode             IN  NUMBER   DEFAULT inv_reservation_global.g_cancel_order_no
   , x_mtl_reservation_tbl           OUT NOCOPY inv_reservation_global.mtl_reservation_tbl_type
   , x_mtl_reservation_tbl_count     OUT NOCOPY NUMBER
   , x_error_code                    OUT NOCOPY NUMBER
   );

PROCEDURE Create_Reservation
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_validation_flag               IN  VARCHAR2 DEFAULT FND_API.G_TRUE
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
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_validation_flag               IN  VARCHAR2 DEFAULT FND_API.G_TRUE
   , p_original_rsv_rec              IN  inv_reservation_global.mtl_reservation_rec_type
   , p_to_rsv_rec                    IN  inv_reservation_global.mtl_reservation_rec_type
   , p_original_serial_number        IN  inv_reservation_global.serial_number_tbl_type
   , p_to_serial_number              IN  inv_reservation_global.serial_number_tbl_type
   );

PROCEDURE Delete_Reservation
  (
     p_api_version_number       IN  NUMBER
   , p_init_msg_lst             IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status            OUT NOCOPY VARCHAR2
   , x_msg_count                OUT NOCOPY NUMBER
   , x_msg_data                 OUT NOCOPY VARCHAR2
   , p_validation_flag          IN  VARCHAR2 DEFAULT FND_API.G_TRUE
   , p_rsv_rec                  IN  inv_reservation_global.mtl_reservation_rec_type
   , p_serial_number            IN  inv_reservation_global.serial_number_tbl_type
   );

PROCEDURE Transfer_Reservation
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_validation_flag               IN  VARCHAR2 DEFAULT FND_API.G_TRUE
   , p_is_transfer_supply            IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_original_rsv_rec              IN  inv_reservation_global.mtl_reservation_rec_type
   , p_to_rsv_rec                    IN  inv_reservation_global.mtl_reservation_rec_type
   , p_original_serial_number        IN  inv_reservation_global.serial_number_tbl_type
   , p_to_serial_number              IN  inv_reservation_global.serial_number_tbl_type
   , x_to_reservation_id             OUT NOCOPY NUMBER
   );

END GMI_Reservation_PUB;

 

/
