--------------------------------------------------------
--  DDL for Package INVIDIT3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVIDIT3" AUTHID CURRENT_USER AS
/* $Header: INVIDI3S.pls 120.6.12010000.2 2010/03/26 10:22:39 qyou ship $ */

G_inv_item_id   NUMBER;

PROCEDURE Table_Queries(
   p_org_id                   IN            NUMBER,
   p_item_id                  IN            NUMBER,
   p_master_org               IN            NUMBER,
   p_primary_uom_code         IN            VARCHAR2,
   p_catalog_group_id         IN            NUMBER,
   p_calling_routine          IN            VARCHAR2, -- Values are INVIDITM,IOI.
   x_onhand_lot               IN OUT NOCOPY NUMBER,
   x_onhand_serial            IN OUT NOCOPY NUMBER,
   x_onhand_shelf             IN OUT NOCOPY NUMBER,
   x_onhand_rev               IN OUT NOCOPY NUMBER,
   x_onhand_loc               IN OUT NOCOPY NUMBER,
   x_onhand_all               IN OUT NOCOPY NUMBER,
   x_onhand_trackable         IN OUT NOCOPY NUMBER,
   x_wip_repetitive_item      IN OUT NOCOPY NUMBER,
   x_rsv_exists               IN OUT NOCOPY NUMBER,
   x_so_rsv                   IN OUT NOCOPY NUMBER,
   x_so_ship                  IN OUT NOCOPY NUMBER,
   x_so_txn                   IN OUT NOCOPY NUMBER,
   x_demand_exists            IN OUT NOCOPY NUMBER,
   x_uom_conv                 IN OUT NOCOPY NUMBER,
   x_comp_atp                 IN OUT NOCOPY NUMBER,
   x_bom_exists               IN OUT NOCOPY NUMBER,
   x_cost_txn                 IN OUT NOCOPY NUMBER,
   x_bom_item                 IN OUT NOCOPY NUMBER,
   x_mrp_schedule             IN OUT NOCOPY NUMBER,
   x_null_elem_exists         IN OUT NOCOPY NUMBER,
   x_so_open_exists           IN OUT NOCOPY NUMBER,
   x_fte_vechicle_exists      IN OUT NOCOPY NUMBER,
   x_pendadj_lot              IN OUT NOCOPY NUMBER,
   x_pendadj_rev              IN OUT NOCOPY NUMBER,
   x_pendadj_loc              IN OUT NOCOPY NUMBER,
   x_so_ato                   IN OUT NOCOPY NUMBER,
   x_vmiorconsign_enabled     IN OUT NOCOPY NUMBER,
   x_consign_enabled          IN OUT NOCOPY NUMBER,
   x_process_enabled          IN OUT NOCOPY NUMBER,
   x_onhand_tracking_qty_ind  IN OUT NOCOPY NUMBER,
   x_pendadj_tracking_qty_ind IN OUT NOCOPY NUMBER,
   x_onhand_primary_uom       IN OUT NOCOPY NUMBER,
   x_pendadj_primary_uom      IN OUT NOCOPY NUMBER,
   x_onhand_secondary_uom     IN OUT NOCOPY NUMBER,
   x_pendadj_secondary_uom    IN OUT NOCOPY NUMBER,
   x_onhand_sec_default_ind   IN OUT NOCOPY NUMBER,
   x_pendadj_sec_default_ind  IN OUT NOCOPY NUMBER,
   x_onhand_deviation_high    IN OUT NOCOPY NUMBER,
   x_pendadj_deviation_high   IN OUT NOCOPY NUMBER,
   x_onhand_deviation_low     IN OUT NOCOPY NUMBER,
   x_pendadj_deviation_low    IN OUT NOCOPY NUMBER,
   x_onhand_child_lot         IN OUT NOCOPY NUMBER,
   x_pendadj_child_lot        IN OUT NOCOPY NUMBER,
   x_onhand_lot_divisible     IN OUT NOCOPY NUMBER,
   x_pendadj_lot_divisible    IN OUT NOCOPY NUMBER,
   x_onhand_grade             IN OUT NOCOPY NUMBER,
   x_pendadj_grade            IN OUT NOCOPY NUMBER,
   x_intr_ship_lot            IN OUT NOCOPY NUMBER,
   x_intr_ship_serial         IN OUT NOCOPY NUMBER,
   X_revision_control            OUT NOCOPY number,   -- Bug 6501149
   X_stockable                   OUT NOCOPY number,   -- Bug 6501149
   X_lot_control                 OUT NOCOPY number,   -- Bug 6501149
   X_serial_control              OUT NOCOPY number,   -- Bug 6501149
   X_open_shipment_lot        IN OUT NOCOPY number,   -- Bug 9043779
   X_open_shipment_serial     IN OUT NOCOPY number    -- Bug 9043779
   );

-- Added for 11.5.10
PROCEDURE VMI_Table_Queries(
  p_org_id                  IN            NUMBER
, p_item_id                 IN            NUMBER
, x_vmiorconsign_enabled    OUT NOCOPY    NUMBER
, x_consign_enabled         OUT NOCOPY    NUMBER);

FUNCTION Get_inv_item_id RETURN NUMBER;

PROCEDURE Set_inv_item_id(item_id number);

FUNCTION Is_Catalog_Group_Valid(
       old_catalog_group_id VARCHAR2,
       new_catalog_group_id VARCHAR2,
       item_id              NUMBER) RETURN VARCHAR2;--Bug: 3171098

FUNCTION CHECK_NPR_CATALOG(p_catalog_group_id NUMBER) RETURN  BOOLEAN;

FUNCTION CHECK_ITEM_APPROVED(p_inventory_item_id NUMBER
                            ,p_organization_id   NUMBER) RETURN  BOOLEAN;

--Added for Bug: 4569555
PROCEDURE CSI_Table_Queries (
   p_inventory_item_id   IN            NUMBER
  ,p_organization_id     IN            NUMBER
  ,x_ib_ret_status       OUT NOCOPY    VARCHAR2
  ,x_ib_msg              OUT NOCOPY    VARCHAR2);

END INVIDIT3;

/
