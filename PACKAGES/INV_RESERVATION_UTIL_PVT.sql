--------------------------------------------------------
--  DDL for Package INV_RESERVATION_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_RESERVATION_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: INVRSV2S.pls 120.1 2005/06/20 11:10:17 appldev ship $ */

PROCEDURE set_file_info
  (
   p_file_name IN VARCHAR2
   );

PROCEDURE close_file;

PROCEDURE write_to_logfile
  (
     x_return_status    OUT NOCOPY VARCHAR2
   , p_msg_to_append    IN  VARCHAR2
   , p_appl_short_name  IN  VARCHAR2
   , p_file_name        IN  VARCHAR2
   , p_program_name     IN  VARCHAR2
   , p_new_or_append    IN  NUMBER
   );

PROCEDURE search_item_cache
  (
     x_return_status           OUT NOCOPY VARCHAR2
   , p_inventory_item_id       IN  NUMBER
   , p_organization_id         IN  NUMBER
   , x_index                   OUT NOCOPY NUMBER
   );

PROCEDURE add_item_cache
  (
     x_return_status   OUT NOCOPY VARCHAR2
   , p_item_record     IN  inv_reservation_global.item_record
   , x_index           OUT NOCOPY NUMBER
   );

PROCEDURE search_organization_cache
  (
     x_return_status           OUT NOCOPY VARCHAR2
   , p_organization_id         IN  NUMBER
   , x_index                   OUT NOCOPY NUMBER
   );

PROCEDURE add_organization_cache
  (
     x_return_status           OUT NOCOPY VARCHAR2
   , p_organization_record     IN  inv_reservation_global.organization_record
   , x_index                   OUT NOCOPY NUMBER
   );

PROCEDURE search_demand_cache
  (
     x_return_status           OUT NOCOPY VARCHAR2
   , p_demand_source_type_id   IN  NUMBER
   , p_demand_source_header_id IN  NUMBER
   , p_demand_source_line_id   IN  NUMBER
   , p_demand_source_name      IN  VARCHAR2
   , x_index                   OUT NOCOPY NUMBER
   );

PROCEDURE add_demand_cache
  (
     x_return_status   OUT NOCOPY VARCHAR2
   , p_demand_record   IN  inv_reservation_global.demand_record
   , x_index           OUT NOCOPY NUMBER
   );

PROCEDURE search_supply_cache
  (
     x_return_status           OUT NOCOPY VARCHAR2
   , p_supply_source_type_id   IN  NUMBER
   , p_supply_source_header_id IN  NUMBER
   , p_supply_source_line_id   IN  NUMBER
   , p_supply_source_name      IN  VARCHAR2
   , x_index                   OUT NOCOPY NUMBER
   );

PROCEDURE add_supply_cache
  (
     x_return_status   OUT NOCOPY VARCHAR2
   , p_supply_record   IN  inv_reservation_global.supply_record
   , x_index           OUT NOCOPY NUMBER
   );

PROCEDURE search_sub_cache
  (
     x_return_status         OUT NOCOPY VARCHAR2
   , p_subinventory_code     IN  VARCHAR2
   , p_organization_id       IN  NUMBER
   , x_index                 OUT NOCOPY NUMBER
   );

PROCEDURE add_sub_cache
  (
     x_return_status   OUT NOCOPY VARCHAR2
   , p_sub_record      IN  inv_reservation_global.sub_record
   , x_index           OUT NOCOPY NUMBER
   );

-- Function
--   locator_control
-- Description
--   Determine whether locator control is on.
--   uses lookup code from mtl_location_controls.
--   see mtl_system_items in the TRM for more
--   information.
--   mtl_location_control lookup code
--      1      no locator control
--      2      prespecified locator control
--      3      dynamic entry locator control
--      4      locator control determined at subinventory level
--      5      locator control determined at item level
--   Since this package is used by reservation only,
--   we will no have dynamic entry locator control at all
--   (if the input is 3, we treats it as 2);
--   also as create, update, delete, or transfer a reservation
--   has no impact on on hand quantity, we will not check
--   negative balance as we do in validation module for
--   cycle count transactions.
-- Return Value
--      a number in (1,2,4,5), as defined in mtl_location_control
--      lookup code
FUNCTION locator_control
  (
     p_org_control  IN    NUMBER
   , p_sub_control  IN    NUMBER
   , p_item_control IN    NUMBER DEFAULT NULL
   ) RETURN NUMBER;

/*** {{ R12 Enhanced reservations code changes ***/
-- add the wip record cache
PROCEDURE get_wip_cache
  (
     x_return_status OUT NOCOPY VARCHAR2
   , p_wip_entity_id IN   NUMBER
  );


/*** End R12 }} ***/
END inv_reservation_util_pvt;

 

/
