--------------------------------------------------------
--  DDL for Package INV_TRX_RELIEF_C_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_TRX_RELIEF_C_PVT" AUTHID CURRENT_USER AS
/* $Header: INVRSV8S.pls 120.2 2006/06/13 14:44:19 aalex noship $*/
-- This procedure should be called only by TrxRsvRelief in inldqc.ppc
PROCEDURE rsv_relief
  ( x_return_status       OUT NOCOPY VARCHAR2, -- return status
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    x_ship_qty            OUT NOCOPY NUMBER,   -- shipped quantity
    x_userline            OUT NOCOPY VARCHAR2, -- user line number
    x_demand_class        OUT NOCOPY VARCHAR2, -- demand class
    x_mps_flag            OUT NOCOPY NUMBER,   -- mrp installed or not (1 yes, 0 no)
    p_organization_id 	  IN  NUMBER,   -- org id
    p_inventory_item_id   IN  NUMBER,   -- inventory item id
    p_subinv              IN  VARCHAR2, -- subinventory
    p_locator             IN  NUMBER,   -- locator id
    p_lotnumber           IN  VARCHAR2, -- lot number
    p_revision            IN  VARCHAR2, -- revision
    p_dsrc_type       	  IN  NUMBER,   -- demand source type
    p_header_id       	  IN  NUMBER,   -- demand source header id
    p_dsrc_name           IN  VARCHAR2, -- demand source name
    p_dsrc_line           IN  NUMBER,   -- demand source line id
    p_dsrc_delivery       IN  NUMBER,   -- demand source delivery
    p_qty_at_puom         IN  NUMBER,   -- primary quantity
    p_lpn_id		  IN  NUMBER  default NULL
  );

-- INVCONV BEGIN
-- Overload to process secondary quantities alongside primary quantities
PROCEDURE rsv_relief
  ( x_return_status       OUT NOCOPY VARCHAR2, -- return status
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    x_ship_qty            OUT NOCOPY NUMBER,   -- shipped quantity
    x_secondary_ship_qty  OUT NOCOPY NUMBER,   -- secondary shipped quantity  INVCONV SPECIFIC
    x_userline            OUT NOCOPY VARCHAR2, -- user line number
    x_demand_class        OUT NOCOPY VARCHAR2, -- demand class
    x_mps_flag            OUT NOCOPY NUMBER,   -- mrp installed or not (1 yes, 0 no)
    p_organization_id     IN  NUMBER,   -- org id
    p_inventory_item_id   IN  NUMBER,   -- inventory item id
    p_subinv              IN  VARCHAR2, -- subinventory
    p_locator             IN  NUMBER,   -- locator id
    p_lotnumber           IN  VARCHAR2, -- lot number
    p_revision            IN  VARCHAR2, -- revision
    p_dsrc_type           IN  NUMBER,   -- demand source type
    p_header_id           IN  NUMBER,   -- demand source header id
    p_dsrc_name           IN  VARCHAR2, -- demand source name
    p_dsrc_line           IN  NUMBER,   -- demand source line id
    p_dsrc_delivery       IN  NUMBER,   -- demand source delivery
    p_qty_at_puom         IN  NUMBER,   -- primary quantity
    p_qty_at_suom         IN  NUMBER,   -- secondary quantity    INVCONV SPECIFIC
  p_lpn_id              IN  NUMBER  default NULL,
  p_transaction_id      IN NUMBER   DEFAULT NULL -- Bug 3517647: Passing transaction id

  );
-- INVCONV END

FUNCTION rsv_relieve(p_transaction_header_id NUMBER) RETURN NUMBER;
END inv_trx_relief_c_pvt;

 

/
