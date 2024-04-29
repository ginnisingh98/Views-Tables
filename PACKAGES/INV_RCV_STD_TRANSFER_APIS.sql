--------------------------------------------------------
--  DDL for Package INV_RCV_STD_TRANSFER_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_RCV_STD_TRANSFER_APIS" AUTHID CURRENT_USER AS
  /* $Header: INVSTDTS.pls 120.1 2005/09/16 14:37:43 gayu noship $ */

/** PROCEDURE: create_transfer_rcvtxn_rec
  * Description:
  *   Specification of the stub procedure
  *
  *    @param x_return_status
  *      Return status indicating Success (S), Error (E), Unexpected Error (U)
  *    @param x_msg_count
  *      Number of messages in  message list
  *    @param x_msg_data
  *      Stacked messages text
  *    @param p_organization_id     - Organization ID
  *    @param p_parent_txn_id       - Transaction ID of the parent transaction
  *    @param p_reference_id        - Reference ID of the move order line
  *    @param p_reference           - Reference Indicator for the source doc
  *    @param p_reference_type_code - Reference Type Code
  *    @param p_item_id             - Item Being transferred
  *    @param p_revision            - Item Revision
  *    @param p_subinventory_code   - Destination receiving subinventory code
  *    @param p_locator_id          - Destination receiving locator ID
  *    @param p_transfer_quantity   - Quantity to be transferred
  *    @param p_transfer_uom_code   - UOM code of the quantity being tranferred
  *    @param p_lot_control_code    - Lot Control Code of the item
  *    @param p_serial_control_code - Serial Control Code of the item
  *    @param p_original_rti_id     - Original RTI ID for lot/serial split
  *    @param p_original_temp_id    - Transaction Temp ID of the putaway MMTT
  *    @param p_lot_number          - Lot Number on the move order line
  *    @param p_lpn_id              - LPN ID of the move order line
  *    @param p_transfer_lpn_id     - Transfer LPN ID (LPN being dropped into)
  *
  * @ return: NONE
  *---------------------------------------------------------------------------*/

  PROCEDURE create_transfer_rcvtxn_rec(
      x_return_status       OUT NOCOPY  VARCHAR2
    , x_msg_count           OUT NOCOPY  NUMBER
    , x_msg_data            OUT NOCOPY  VARCHAR2
    , p_organization_id     IN          NUMBER
    , p_parent_txn_id       IN          NUMBER
    , p_reference_id        IN          NUMBER
    , p_reference           IN          VARCHAR2
    , p_reference_type_code IN          NUMBER
    , p_item_id             IN          NUMBER
    , p_revision            IN          VARCHAR2
    , p_subinventory_code   IN          VARCHAR2
    , p_locator_id          IN          NUMBER
    , p_transfer_quantity   IN          NUMBER
    , p_transfer_uom_code   IN          VARCHAR2
    , p_lot_control_code    IN          NUMBER
    , p_serial_control_code IN          NUMBER
    , p_original_rti_id     IN          NUMBER   DEFAULT NULL
    , p_original_temp_id    IN          NUMBER   DEFAULT NULL
    , p_lot_number          IN          VARCHAR2 DEFAULT NULL
    , p_lpn_id              IN          NUMBER   DEFAULT NULL
    , p_transfer_lpn_id     IN          NUMBER   DEFAULT NULL
    , p_sec_transfer_quantity    IN          NUMBER  DEFAULT NULL --OPM Convergence
    , p_sec_transfer_uom_code         IN          VARCHAR2 DEFAULT NULL ); --OPM Convergence

  PROCEDURE Match_transfer_rcvtxn_rec(
      x_return_status       OUT NOCOPY  VARCHAR2
    , x_msg_count           OUT NOCOPY  NUMBER
    , x_msg_data            OUT NOCOPY  VARCHAR2
    , p_organization_id     IN          NUMBER
    , p_parent_txn_id       IN          NUMBER
    , p_reference_id        IN          NUMBER
    , p_reference           IN          VARCHAR2
    , p_reference_type_code IN          NUMBER
    , p_item_id             IN          NUMBER
    , p_revision            IN          VARCHAR2
    , p_subinventory_code   IN          VARCHAR2
    , p_locator_id          IN          NUMBER
    , p_transfer_quantity   IN          NUMBER
    , p_transfer_uom_code   IN          VARCHAR2
    , p_lot_control_code    IN          NUMBER
    , p_serial_control_code IN          NUMBER
    , p_original_rti_id     IN          NUMBER   DEFAULT NULL
    , p_original_temp_id    IN          NUMBER   DEFAULT NULL
    , p_lot_number          IN          VARCHAR2 DEFAULT NULL
    , p_lpn_id              IN          NUMBER   DEFAULT NULL
    , p_transfer_lpn_id     IN          NUMBER   DEFAULT NULL
    , p_sec_transfer_quantity    IN     NUMBER  DEFAULT NULL --OPM Convergence
    , p_sec_transfer_uom_code    IN     VARCHAR2 DEFAULT NULL  --OPM Convergence
    , p_inspection_status        IN     NUMBER DEFAULT NULL
    , p_primary_uom_code         IN     VARCHAR2
    , p_from_sub            IN          VARCHAR2 DEFAULT NULL --Needed for matching non-lpn materials
    , p_from_loc            IN          NUMBER DEFAULT NULL); --Needed for matching non-lpn materials

END INV_RCV_STD_TRANSFER_APIS;


 

/
