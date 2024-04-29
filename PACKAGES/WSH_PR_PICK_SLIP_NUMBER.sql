--------------------------------------------------------
--  DDL for Package WSH_PR_PICK_SLIP_NUMBER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_PR_PICK_SLIP_NUMBER" AUTHID CURRENT_USER AS
/* $Header: WSHPRPNS.pls 120.1 2006/06/20 09:06:21 aymohant noship $ */

--
-- Package
--        WSH_PR_PICK_SLIP_NUMBER
--
-- Purpose
--   This package does the following:
--   - Initialize variables to be used
--     in determining the how to group pick slips.
--   - Get pick slip number
--   - Print Pick Slip Report
--

   TYPE psTabTyp is TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   g_print_ps_table psTabTyp;

   --
   -- PUBLIC FUNCTIONS/PROCEDURES
   --

   --
   -- Name
   --   PROCEDURE Print_Pick_Slip
   --
   -- Purpose
   --   This function prints a Pick Slip for a given Pick Slip number
   --   or all Pick Slips for the session
   --
   -- Input Parameters
   --   p_pick_slip_number => pick slip number
   --   p_report_set_id    => report set
   --   If p_report_set_id IS NULL, procedure returns. No printing.
   --   p_order_header_id  => Order Header id
   --   p_batch_id         => Batch id
   --   p_ps_mode          => P.Slip Mode ('I'mmediate, 'D'effered, 'N'one)   -- 1676123
   --
   --
   -- Output Parameters
   --   x_api_status    => FND_API.G_RET_STS_SUCESSS or
   --                      FND_API.G_RET_STS_ERROR or
   --                      FND_API.G_RET_STS_UNEXP_ERROR
   --   x_error_message => Error message
   --
   --
   PROCEDURE Print_Pick_Slip (
      p_pick_slip_number         IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
      p_report_set_id            IN  NUMBER,
	 p_organization_id          IN  NUMBER,
	 p_order_header_id          IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
	 p_batch_id                 IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
	 p_ps_mode                  IN  VARCHAR2 DEFAULT NULL,
      x_api_status               OUT NOCOPY VARCHAR2,
      x_error_message            OUT NOCOPY VARCHAR2 );

 /*
 ###############   PLEASE READ ####################################
   Following APIs were owned by WSH until patchset H (11.5.8).
   From Patchset-I onwards, ownership has been transfered to INV Team.
   Please do not modify these APIs for any ongoing development
   or bug-fixes from Patchset-I and beyond.

   Modify these APIs only if you are making bug-fix for pre-I
   customers. Please consult Nikhil Parikh/Anil Verma, if you have
   any questions.

   The APIs are maintained here only for backward-compatibility, i.e.
   if customer has applied INV-H and WSH-I, it should still
   continue to work.

 */
   --
   -- Name
   --   PROCEDURE Get_Pick_Slip_Number
   --
   -- Purpose
   --   Returns pick slip number and whether a Pick Slip
   --   should be printed
   --
   -- Input Parameters
   --   p_ps_mode              => pick slip print mode: I=immed, E=deferred
   --   p_pick_grouping_rule_id => pick grouping rule id
   --   p_org_id               => organization_id
   --   p_header_id            => order header id
   --   p_customer_id          => customer id
   --   p_ship_method_code     => ship method
   --   p_ship_to_loc_id       => ship to location
   --   p_shipment_priority    => shipment priority
   --   p_subinventory         => subinventory
   --   p_trip_stop_id         => trip stop
   --   p_delivery_id          => delivery
   --   p_inventory_item_id    => inventory item id
   --   p_locator_id           => locator id
   --   p_lot_number           => lot number
   --   p_revision             => revision
   --
   -- Output Parameters
   --   x_pick_slip_number     => pick_slip_number
   --   x_ready_to_print       => FND_API.G_TRUE or FND_API.G_FALSE
   --   x_api_status           => FND_API.G_RET_STS_SUCESSS or
   --                             FND_API.G_RET_STS_ERROR
   --   x_error_message        => Error message
   --
   PROCEDURE Get_Pick_Slip_Number (
      p_ps_mode                    IN      VARCHAR2,
      p_pick_grouping_rule_id      IN      NUMBER,
      p_org_id                     IN      NUMBER,
      p_header_id                  IN      NUMBER,
      p_customer_id                IN      NUMBER,
      p_ship_method_code           IN      VARCHAR2,
      p_ship_to_loc_id             IN      NUMBER,
      p_shipment_priority          IN      VARCHAR2,
      p_subinventory               IN      VARCHAR2,
      p_trip_stop_id               IN      NUMBER,
      p_delivery_id                IN      NUMBER,
      p_inventory_item_id          IN      NUMBER   DEFAULT NULL,
      p_locator_id                 IN      NUMBER   DEFAULT NULL,
      p_lot_number                 IN      VARCHAR2 DEFAULT NULL,
      p_revision                   IN      VARCHAR2 DEFAULT NULL,
      x_pick_slip_number           OUT     NOCOPY NUMBER,
      x_ready_to_print             OUT     NOCOPY VARCHAR2,
      x_call_mode                  OUT     NOCOPY VARCHAR2,
      x_api_status                 OUT     NOCOPY VARCHAR2,
      x_error_message              OUT     NOCOPY VARCHAR2  );

   -- Name
   --   PROCEDURE delete_pick_slip_numbers   /* For parallel Pick-Release */
   --
   -- Purpose
   --   This function used by shipping to delete the pickslip numbers
   --    from mtl_pick_slip_numbers at the end the pickrelease session
   --     for parallel pick-release
   --
   -- Input Parameters
   --   p_batch_id => pickrelease batch_id (WSH_PICKING_BATCHES)

 PROCEDURE delete_pick_slip_numbers (
      p_batch_id    IN NUMBER);

 -- Name
 --   PROCEDURE DELETE_PS_TBL
 --
 -- Purpose
 --   Deletes the global PL/SQL table used to store pick slip numbers
 --   For code levels 11.5.9 or above  it will delete the table from INV.
 --
 -- Input Parameters
 --   None
 --
 -- Output Parameters
 --   None
 PROCEDURE delete_ps_tbl(
     x_api_status                 OUT     NOCOPY VARCHAR2,
     x_error_message              OUT     NOCOPY VARCHAR2  );

END WSH_PR_PICK_SLIP_NUMBER;

 

/
