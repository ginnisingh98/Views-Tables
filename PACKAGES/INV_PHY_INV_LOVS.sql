--------------------------------------------------------
--  DDL for Package INV_PHY_INV_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_PHY_INV_LOVS" AUTHID CURRENT_USER AS
/* $Header: INVPINLS.pls 120.3 2006/11/23 06:38:41 vssrivat noship $ */

TYPE t_genref IS REF CURSOR;

--      Name: GET_PHY_INV_LOV
--
--      Input parameters:
--       p_phy_inv            Restricts LOV SQL to the user input text
--       p_organization_id    Organization ID
--
--      Output parameters:
--       x_phy_inv_lov        Returns LOV rows as a reference cursor
--
--      Functions: This API returns valid physical inventories
--

PROCEDURE get_phy_inv_lov
  (x_phy_inv_lov       OUT  NOCOPY  t_genref,
   p_phy_inv           IN           VARCHAR2,
   p_organization_id   IN           NUMBER);


--      Name: GET_SERIAL_COUNT_NUMBER
--
--      Input parameters:
--       p_physical_inventory_id    Physical Inventory ID
--       p_organization_id          Organization ID
--       p_serial_number            Serial Number
--       p_inventory_item_id        Inventory Item ID
--
--      Output parameters:
--       x_number            Returns the serial count for the number
--                           of physical tags with that particular
--                           serial number that has already been counted.
--       x_serial_in_scope   Returns 1 if the serial is within the scope
--                           of the physical inventory.  Otherwise it will
--                           return 0.
--
--      Functions: This API returns the count of physical tag records
--                 for the given serial number inputted.
--                 It has also been overloaded so that it will also
--                 check if the inputted serial is within the scope
--                 of the physical inventory, i.e. exists in a subinventory
--                 for which the physical inventory covers
--

PROCEDURE get_serial_count_number
  (p_physical_inventory_id   IN          NUMBER            ,
   p_organization_id         IN          NUMBER            ,
   p_serial_number           IN          VARCHAR2          ,
   p_inventory_item_id       IN          NUMBER            ,
   x_number                  OUT NOCOPY  NUMBER            ,
   x_serial_in_scope         OUT NOCOPY  NUMBER);

PROCEDURE process_tag
  (p_physical_inventory_id   IN    NUMBER,
   p_organization_id         IN    NUMBER,
   p_subinventory            IN    VARCHAR2,
   p_locator_id              IN    NUMBER := NULL,
   p_parent_lpn_id           IN    NUMBER := NULL,
   p_inventory_item_id       IN    NUMBER,
   p_revision                IN    VARCHAR2 := NULL,
   p_lot_number              IN    VARCHAR2 := NULL,
   p_from_serial_number      IN    VARCHAR2 := NULL,
   p_to_serial_number        IN    VARCHAR2 := NULL,
   p_tag_quantity            IN    NUMBER,
   p_tag_uom                 IN    VARCHAR2,
   p_dynamic_tag_entry_flag  IN    NUMBER,
   p_user_id                 IN    NUMBER,
   p_cost_group_id           IN    NUMBER := NULL
   --INVCONV, NSRIVAST, START
   ,p_tag_sec_uom            IN    VARCHAR2 := NULL
   ,p_tag_sec_quantity       IN    NUMBER   := NULL
   --INVCONV, NSRIVAST, END
   );

PROCEDURE insert_row
  (p_physical_inventory_id   IN    NUMBER,
   p_organization_id         IN    NUMBER,
   p_subinventory            IN    VARCHAR2,
   p_locator_id              IN    NUMBER,
   p_parent_lpn_id           IN    NUMBER,
   p_inventory_item_id       IN    NUMBER,
   p_revision                IN    VARCHAR2,
   p_lot_number              IN    VARCHAR2,
   p_serial_number           IN    VARCHAR2,
   p_tag_quantity            IN    NUMBER,
   p_tag_uom                 IN    VARCHAR2,
   p_user_id                 IN    NUMBER,
   p_cost_group_id           IN    NUMBER,
   p_adjustment_id           IN    NUMBER
   --INVCONV, NSRIVAST, START
   ,p_tag_sec_quantity       IN    NUMBER   := NULL
   ,p_tag_sec_uom            IN    VARCHAR2 := NULL
   --INVCONV, NSRIVAST, END
   );

PROCEDURE update_row
  (p_tag_id                  IN    NUMBER,
   p_physical_inventory_id   IN    NUMBER,
   p_organization_id         IN    NUMBER,
   p_subinventory            IN    VARCHAR2,
   p_locator_id              IN    NUMBER,
   p_parent_lpn_id           IN    NUMBER,
   p_inventory_item_id       IN    NUMBER,
   p_revision                IN    VARCHAR2,
   p_lot_number              IN    VARCHAR2,
   p_serial_number           IN    VARCHAR2,
   p_tag_quantity            IN    NUMBER,
   p_tag_uom                 IN    VARCHAR2,
   p_user_id                 IN    NUMBER,
   p_cost_group_id           IN    NUMBER,
   p_adjustment_id           IN    NUMBER
   ,p_tag_sec_quantity       IN    NUMBER   := NULL     --INVCONV, NSRIVAST
   );

PROCEDURE update_adjustment
  (p_adjustment_id           IN   NUMBER,
   p_physical_inventory_id   IN   NUMBER,
   p_organization_id         IN   NUMBER,
   p_user_id                 IN   NUMBER
   );

PROCEDURE find_existing_adjustment
  (p_physical_inventory_id   IN           NUMBER,
   p_organization_id         IN           NUMBER,
   p_subinventory            IN           VARCHAR2,
   p_locator_id              IN           NUMBER,
   p_parent_lpn_id           IN           NUMBER,
   p_inventory_item_id       IN           NUMBER,
   p_revision                IN           VARCHAR2,
   p_lot_number              IN           VARCHAR2,
   p_serial_number           IN           VARCHAR2,
   p_user_id                 IN           NUMBER,
   p_cost_group_id           IN           NUMBER,
   x_adjustment_id           OUT   NOCOPY NUMBER
   );

PROCEDURE process_summary
  (p_physical_inventory_id   IN    NUMBER,
   p_organization_id         IN    NUMBER,
   p_subinventory            IN    VARCHAR2,
   p_locator_id              IN    NUMBER := NULL,
   p_parent_lpn_id           IN    NUMBER := NULL,
   p_dynamic_tag_entry_flag  IN    NUMBER,
   p_user_id                 IN    NUMBER
   );


--Fix for bug #4654210
PROCEDURE unmark_serials
  (p_physical_inventory_id   IN    NUMBER,
   p_organization_id         IN    NUMBER,
   p_item_id                 IN    NUMBER,
   x_status                 OUT    NOCOPY NUMBER
  );

-- Fix for bug 5660272
PROCEDURE GET_SERIAL_NUMBER_TYPE
  (	x_serial_number_type OUT NOCOPY	NUMBER,
	p_organization_id   IN		NUMBER
  );

-- Fix for bug 5660272
PROCEDURE VALIDATE_SERIAL_STATUS
   (    x_status             OUT NOCOPY NUMBER,
        x_organization_code  OUT NOCOPY VARCHAR2,
        x_current_status     OUT NOCOPY VARCHAR2,
        p_serial_num         IN         VARCHAR2,
        p_organization_id    IN         NUMBER,
        p_subinventory_code  IN         VARCHAR2,
        p_locator_id         IN         NUMBER,
        p_inventory_item_id  IN         NUMBER,
	p_serial_number_type IN		NUMBER
    );


END INV_PHY_INV_LOVS;

/
