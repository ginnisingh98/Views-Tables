--------------------------------------------------------
--  DDL for Package INV_RESERVATION_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_RESERVATION_WORKFLOW" AUTHID CURRENT_USER AS
/* $Header: INVRSVWS.pls 120.1 2005/06/17 17:38:14 appldev  $*/

-- Procedure
--   handle_broken_reservation
-- Description
--   Start the work flow process to handle broken reservation
-- Note
--   You need to provide values for all input parameters. The other
--   overloaded version of the procedure requires less information.
-- Output Parameters
--   x_return_status    'T' if succeeded, 'F' if failed
PROCEDURE handle_broken_reservation
  (
     p_item_type                     IN  VARCHAR2 DEFAULT 'INVRSVWF'
   , p_item_key                      IN  VARCHAR2
   , p_reservation_id                IN  NUMBER
   , p_organization_id               IN  NUMBER
   , p_organization_code             IN  VARCHAR2
   , p_inventory_item_id             IN  NUMBER
   , p_inventory_item_number         IN  VARCHAR2
   , p_revision                      IN  VARCHAR2
   , p_lot_number		     IN  VARCHAR2
   , p_subinventory_code	     IN  VARCHAR2
   , p_locator_id		     IN  NUMBER
   , p_locator                       IN  VARCHAR2
   , p_demand_source_type_id	     IN  NUMBER
   , p_demand_source_type            IN  VARCHAR2
   , p_demand_source_header_id	     IN  NUMBER
   , p_demand_source_line_id	     IN  NUMBER
   , p_demand_source_name            IN  VARCHAR2
   , p_supply_source_type_id	     IN  NUMBER
   , p_supply_source_type            IN  VARCHAR2
   , p_supply_source_header_id	     IN  NUMBER
   , p_supply_source_line_id	     IN  NUMBER
   , p_supply_source_name            IN  VARCHAR2
   , p_supply_source_line_detail     IN  NUMBER
   , p_primary_uom_code              IN  VARCHAR2
   , p_primary_reservation_quantity  IN  NUMBER
   , p_from_user_name                IN  VARCHAR2
   , p_to_notify_role                IN  VARCHAR2
  );

-- Procedure
--   handle_broken_reservation
-- Description
--   Start the work flow process to handle broken reservation
-- Output Parameters
--   x_return_status    'T' if succeeded, 'F' if failed
PROCEDURE handle_broken_reservation
  (
     p_item_type                     IN  VARCHAR2 DEFAULT 'INVRSVWF'
   , p_item_key                      IN  VARCHAR2
   , p_reservation_id                IN  NUMBER
   , p_from_user_name                IN  VARCHAR2
   , p_to_notify_role                IN  VARCHAR2
   , x_return_status                 OUT NOCOPY VARCHAR2
   );

PROCEDURE selector
  (   itemtype IN  VARCHAR2
    , itemkey  IN  VARCHAR2
    , actid    IN  NUMBER
    , command  IN  VARCHAR2
    , result   OUT NOCOPY VARCHAR2
    );

END inv_reservation_workflow;

 

/
