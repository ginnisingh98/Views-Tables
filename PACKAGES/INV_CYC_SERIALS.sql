--------------------------------------------------------
--  DDL for Package INV_CYC_SERIALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_CYC_SERIALS" AUTHID CURRENT_USER AS
/* $Header: INVCYCMS.pls 120.0 2005/05/25 06:28:28 appldev noship $ */

TYPE t_genref IS REF CURSOR;

PROCEDURE get_scheduled_serial_lov
  (x_serials                 OUT  NOCOPY t_genref          ,
   p_organization_id         IN          NUMBER            ,
   p_subinventory            IN          VARCHAR2          ,
   p_locator_id              IN          NUMBER   := NULL  ,
   p_inventory_item_id       IN          NUMBER            ,
   p_revision                IN          VARCHAR2 := NULL  ,
   p_lot_number              IN          VARCHAR2 := NULL  ,
   p_cycle_count_header_id   IN          NUMBER            ,
   p_parent_lpn_id           IN          NUMBER   := NULL);

PROCEDURE get_serial_entry_lov
  (x_serials                 OUT  NOCOPY t_genref          ,
   p_organization_id         IN          NUMBER            ,
   p_subinventory            IN          VARCHAR2          ,
   p_locator_id              IN          NUMBER   := NULL  ,
   p_inventory_item_id       IN          NUMBER            ,
   p_revision                IN          VARCHAR2 := NULL  ,
   p_lot_number              IN          VARCHAR2 := NULL  ,
   p_cycle_count_header_id   IN          NUMBER            ,
   p_parent_lpn_id           IN          NUMBER   := NULL);

PROCEDURE initialize_scheduled_serials
  (p_organization_id         IN   NUMBER            ,
   p_subinventory            IN   VARCHAR2          ,
   p_locator_id              IN   NUMBER   := NULL  ,
   p_inventory_item_id       IN   NUMBER            ,
   p_revision                IN   VARCHAR2 := NULL  ,
   p_lot_number              IN   VARCHAR2 := NULL  ,
   p_cycle_count_header_id   IN   NUMBER            ,
   p_parent_lpn_id           IN   NUMBER   := NULL);


--      Name: MARK_SERIAL
--
--      Input parameters:
--       p_organization_id         Organization ID
--       p_subinventory            Subinventory code
--       p_locator_id              Locator ID
--       p_inventory_item_id       Inventory Item ID
--       p_revision                Revision
--       p_lot_number              Lot Number
--       p_serial_number           Serial Number
--       p_parent_lpn_id           Parent LPN ID
--       p_cycle_count_header_id   Cycle Count Header ID
--
--      Output parameters:
--       x_return_code             This outputs the return status
--                                 of the API
--            0      - Serial was successfully marked
--            1      - Unscheduled entries are not allowed
--                     The serial number given was not part of the
--                     cycle count entry and we are not allowing
--                     unscheduled multiple serial entries at this time
--           -1      - Others type of error occurred
--
--      Functions: This API is used for multiple serial cycle counting.
--                 This marks the serial number's group mark ID so that
--                 it is considered as currently counted, marked to be
--                 processed in the future.
--
PROCEDURE mark_serial
  (p_organization_id         IN           NUMBER            ,
   p_subinventory            IN           VARCHAR2          ,
   p_locator_id              IN           NUMBER   := NULL  ,
   p_inventory_item_id       IN           NUMBER            ,
   p_revision                IN           VARCHAR2 := NULL  ,
   p_lot_number              IN           VARCHAR2 := NULL  ,
   p_serial_number           IN           VARCHAR2          ,
   p_parent_lpn_id           IN           NUMBER   := NULL  ,
   p_cycle_count_header_id   IN           NUMBER            ,
   x_return_code             OUT   NOCOPY NUMBER);

--      Name: REMOVE_SERIAL
--
--      Input parameters:
--       p_organization_id         Organization ID
--       p_subinventory            Subinventory code
--       p_locator_id              Locator ID
--       p_inventory_item_id       Inventory Item ID
--       p_revision                Revision
--       p_lot_number              Lot Number
--       p_serial_number           Serial Number
--       p_parent_lpn_id           Parent LPN ID
--       p_cycle_count_header_id   Cycle Count Header ID
--
--      Output parameters:
--       x_return_code             This outputs the return status
--                                 of the API
--            0      - Serial was successfully unmarked
--            1      - The serial number given was not part of the
--                     cycle count entry so nothing was removed or unmarked
--           -1      - Others type of error occurred
--
--      Functions: This API is used for multiple serial cycle counting.
--                 This unmarks the serial number's group mark ID so that
--                 it is not considered to be currently counted.  It
--                 removes the given serial number from consideration
--                 for the multiple serial count entry
--
PROCEDURE remove_serial
  (p_organization_id         IN          NUMBER            ,
   p_subinventory            IN          VARCHAR2          ,
   p_locator_id              IN          NUMBER   := NULL  ,
   p_inventory_item_id       IN          NUMBER            ,
   p_revision                IN          VARCHAR2 := NULL  ,
   p_lot_number              IN          VARCHAR2 := NULL  ,
   p_serial_number           IN          VARCHAR2          ,
   p_parent_lpn_id           IN          NUMBER   := NULL  ,
   p_cycle_count_header_id   IN          NUMBER            ,
   x_return_code             OUT NOCOPY  NUMBER);

PROCEDURE mark_all_present
  (p_organization_id         IN    NUMBER            ,
   p_subinventory            IN    VARCHAR2          ,
   p_locator_id              IN    NUMBER   := NULL  ,
   p_inventory_item_id       IN    NUMBER            ,
   p_revision                IN    VARCHAR2 := NULL  ,
   p_lot_number              IN    VARCHAR2 := NULL  ,
   p_cycle_count_header_id   IN    NUMBER            ,
   p_parent_lpn_id           IN    NUMBER   := NULL);


--      Name: GET_SERIAL_ENTRY_NUMBER
--
--      Input parameters:
--       p_organization_id         Organization ID
--       p_subinventory            Subinventory code
--       p_locator_id              Locator ID
--       p_inventory_item_id       Inventory Item ID
--       p_revision                Revision
--       p_lot_number              Lot Number
--       p_cycle_count_header_id   Cycle Count Header ID
--       p_parent_lpn_id           Parent LPN ID
--
--      Output parameters:
--       x_return_code     This outputs the number of marked
--                         serial numbers that have been entered
--
--      Functions: This API is used to get the number of marked
--                 serial numbers that will be processed
--
PROCEDURE get_serial_entry_number
  (p_organization_id         IN         NUMBER            ,
   p_subinventory            IN         VARCHAR2          ,
   p_locator_id              IN         NUMBER   := NULL  ,
   p_inventory_item_id       IN         NUMBER            ,
   p_revision                IN         VARCHAR2 := NULL  ,
   p_lot_number              IN         VARCHAR2 := NULL  ,
   p_cycle_count_header_id   IN         NUMBER            ,
   p_parent_lpn_id           IN         NUMBER   := NULL  ,
   x_number                  OUT NOCOPY NUMBER);


--      Name: INSERT_SERIAL_NUMBER
--      Functions: This API is used to enter or update the serial numbers that are entered in
--                 mtl_cc_serial_numbers.
--
PROCEDURE insert_serial_number
   (p_serial_number           IN   VARCHAR2 ,
    p_cycle_count_header_id   IN   NUMBER,
    p_organization_id         IN   NUMBER            ,
    p_subinventory            IN   VARCHAR2          ,
    p_locator_id              IN   NUMBER   := NULL  ,
    p_inventory_item_id       IN   NUMBER            ,
    p_revision                IN   VARCHAR2 := NULL  ,
    p_lot_number              IN   VARCHAR2 := NULL  ,
    p_parent_lpn_id           IN   NUMBER   := NULL
   );

  /*Remove the serial numbers from mtl_cc_Serial_numbers and unmark the serials in mtl_serial_numbers
  for serials that have been entered till now */
PROCEDURE remove_serial_number
 (p_cycle_count_header_id   IN   NUMBER,
  p_organization_id         IN   NUMBER            ,
  p_subinventory            IN   VARCHAR2          ,
  p_locator_id              IN   NUMBER   := NULL  ,
  p_inventory_item_id       IN   NUMBER            ,
  p_revision                IN   VARCHAR2 := NULL  ,
  p_lot_number              IN   VARCHAR2 := NULL  ,
  p_parent_lpn_id           IN   NUMBER   := NULL
 ) ;


END INV_CYC_SERIALS;

 

/
