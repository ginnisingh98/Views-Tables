--------------------------------------------------------
--  DDL for Package INV_RESERVATION_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_RESERVATION_VALIDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: INVRSV1S.pls 120.1 2007/12/17 13:14:05 ckrishna ship $ */

-- Procedure
--   validate_input_parameters
-- Description
--   is valid if all of the following are satisfied
--     1. if p_rsv_action_name is CREATE, or UPDATE, or TRANSFER, or DELETE
--        validate_organization, validate_item, validate_demand_source,
--        validate_supply_source, validate_quantity with the p_orig_rsv_rec
--        (the original reservation record) return success
--     2. if p_rsv_action_name is UPDATE, or TRANSFER
--        validate_organization, validate_item, validate_demand_source,
--        validate_supply_source, validate_quantity with the p_to_rsv_rec
--        (the new reservation record) return success
PROCEDURE validate_input_parameters
 (
    x_return_status      OUT NOCOPY VARCHAR2
  , p_orig_rsv_rec       IN  inv_reservation_global.mtl_reservation_rec_type
  , p_to_rsv_rec         IN  inv_reservation_global.mtl_reservation_rec_type
  , p_orig_serial_array  IN  inv_reservation_global.serial_number_tbl_type
  , p_to_serial_array    IN  inv_reservation_global.serial_number_tbl_type
  , p_rsv_action_name         IN  VARCHAR2
  , x_orig_item_cache_index   OUT NOCOPY INTEGER
  , x_orig_org_cache_index    OUT NOCOPY INTEGER
  , x_orig_demand_cache_index OUT NOCOPY INTEGER
  , x_orig_supply_cache_index OUT NOCOPY INTEGER
  , x_orig_sub_cache_index    OUT NOCOPY INTEGER
  , x_to_item_cache_index     OUT NOCOPY INTEGER
  , x_to_org_cache_index      OUT NOCOPY INTEGER
  , x_to_demand_cache_index   OUT NOCOPY INTEGER
  , x_to_supply_cache_index   OUT NOCOPY INTEGER
  , x_to_sub_cache_index      OUT NOCOPY INTEGER
  , p_substitute_flag    IN  BOOLEAN DEFAULT FALSE /* Bug 6044651 */
 );

/*** {{ R12 Enhanced reservations code changes ***/
-- Procedure
--   validate_serials
-- Description
--   1. validate the supply and demand source for serial reservation
--      returns error if the supply is not INV or demand is not
--      CMRO, SO or INV.
--   2. validate if the reservation record is detailed for serial
--      reservation
--   3. validate the serial controls with the (org, item, rev, lot, sub, loc)
--      controls on the reservation record.
--      returns error if they don't match.
PROCEDURE validate_serials
 (
    x_return_status       OUT NOCOPY VARCHAR2
  , p_orig_rsv_rec        IN  inv_reservation_global.mtl_reservation_rec_type
  , p_to_rsv_rec          IN  inv_reservation_global.mtl_reservation_rec_type
  , p_orig_serial_array   IN  inv_reservation_global.serial_number_tbl_type
  , p_to_serial_array     IN  inv_reservation_global.serial_number_tbl_type
  , p_rsv_action_name     IN  VARCHAR2
 );
/*** End R12 }} ***/

END inv_reservation_validate_pvt;

/
