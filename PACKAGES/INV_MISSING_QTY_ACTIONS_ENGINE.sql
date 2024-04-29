--------------------------------------------------------
--  DDL for Package INV_MISSING_QTY_ACTIONS_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MISSING_QTY_ACTIONS_ENGINE" AUTHID CURRENT_USER AS
  /* $Header: INVMQAES.pls 120.0 2005/05/25 06:04:10 appldev noship $ */

  /** Missing Qty Actions (Lookups - INV_MISSING_QTY_ACTIONS) */
  /** Decreases the Reservation - Equal to No Action */
  g_action_backorder        CONSTANT NUMBER := 1;
  /** Split the Allocation into two */
  g_action_split_allocation CONSTANT NUMBER := 2;
  /** Create Cycle Count Reservations */
  g_action_cycle_count      CONSTANT NUMBER := 3;

  /**
    * The procedure backups the allocations of a Move Order Line identified
    * either by Move Order Line ID or Transaction Temp ID by populating the
    * table MTL_ALLOCATIONS_GTMP.
    * <p>
    * The API populates the table MTL_ALLOCATIONS_GTMP (Global Temporary Table)
    * by querying MMTT for the allocations. The table will be populated only for <br>
    *   1. Lot Controlled            - Lot Info is captured from MTLT <br>
    *   2. Serial Controlled         - Serial Info is captured from MSN <br>
    *   3. Lot and Serial Controlled - Lot and Serial Info is captured from MTLT and MSN <br>
    * <br>
    * Before populating the table, all the records that are inserted into the temp
    * table by this Session are deleted.
    * <p>
    * If Transaction Temp ID is passed, then only the Allocation identified by
    * Transaction Temp ID is inserted into the Table. <br>
    * If Transaction Temp ID is not passed, then Move Order Line ID has to be
    * passed, in which case all the Allocations identified by Move Order Line ID
    * are inserted into the Table. <br>
    * Lot and Serial Control Codes are not mandatory. If not passed, they will be
    * determined by the API. <br>
    * <p>
    * @param x_return_status        Return Status
    * @param x_msg_data             Message is the Count of Messages is 1
    * @param x_msg_count            Count of Messages in the Stack
    * @param p_transaction_temp_id  Transaction Temp ID
    * @param p_mo_line_id           Move Order Line ID
    * @param p_lot_control_code     Lot Control Code
    * @param p_serial_control_code  Serial Control Code
    **/
  PROCEDURE populate_table(
    x_return_status       OUT NOCOPY VARCHAR2
  , x_msg_data            OUT NOCOPY VARCHAR2
  , x_msg_count           OUT NOCOPY NUMBER
  , p_transaction_temp_id            NUMBER
  , p_mo_line_id                     NUMBER
  , p_lot_control_code               NUMBER DEFAULT NULL
  , p_serial_control_code            NUMBER DEFAULT NULL
  );

  /**
    * The procedure proceeds with the processing required for the chosen Missing
    * Qty Action.
    * <p>
    * The API first removes all the Confirmed Lots and Serials and updates the
    * table MTL_ALLOCATIONS_GTMP (Global Temporary Table) so that it contains only
    * the Non Confirmed Lots and Serials. <br>
    * If the Missing Qty Action is <br>
    * Backorder Only (Action ID #1):<br>
    *   Decreases the Reservation if any by the passed Missing Qty. <p>
    * Split Allocation (Action ID #2): <br>
    *   Splits the current Allocation to create a new one for the Remaining Qty
    *   passed till Lot and Serial level. <p>
    * Cycle Count (Action ID #3): <br>
    *   Creates a (or Transfer the existing reservation) Cycle Count Reservation
    *   for the Missing Quantity passed till Lot Level. <br>
    *   Then Creates a Cycle Count Reservation on the Remaining Availability of
    *   the item for that Revision, Lot, Subinventory and Locator identified by
    *   the Allocation.
    * <p>
    * Lot and Serial Control Codes are not mandatory. If not passed, they will be
    * determined by the API. <br>
    * <p>
    * @param x_return_status        Return Status
    * @param x_msg_data             Message is the Count of Messages is 1
    * @param x_msg_count            Count of Messages in the Stack
    * @param x_new_record_id        ID of the new Record.
    * @param p_action               Missing Qty Action (Either 1, 2 or 3)
    * @param p_transaction_temp_id  Transaction Temp ID
    * @param p_remaining_quantity   Remaining Quantity (Non Confirmed Qty)
    * @param p_lot_control_code     Lot Control Code
    * @param p_serial_control_code  Serial Control Code
    **/
  PROCEDURE process_action(
    x_return_status       OUT NOCOPY VARCHAR2
  , x_msg_data            OUT NOCOPY VARCHAR2
  , x_msg_count           OUT NOCOPY NUMBER
  , x_new_record_id       OUT NOCOPY NUMBER
  , p_action                         NUMBER
  , p_transaction_temp_id            NUMBER
  , p_remaining_quantity             NUMBER
  , p_remaining_secondary_quantity   NUMBER DEFAULT NULL  --INVCONV KKILLALMS
  , p_lot_control_code               NUMBER DEFAULT NULL
  , p_serial_control_code            NUMBER DEFAULT NULL
  );


PROCEDURE update_allocation_qty
   (
    x_return_status       OUT NOCOPY VARCHAR2
  , x_msg_data            OUT NOCOPY VARCHAR2
  , x_msg_count           OUT NOCOPY NUMBER
  , p_transaction_temp_id            NUMBER
  , p_confirmed_quantity             NUMBER
  , p_transaction_uom                VARCHAR2
   --INVCONV kkillams
  , p_sec_confirmed_quantity         NUMBER   DEFAULT NULL
  , p_secondary_uom_code             VARCHAR2 DEFAULT NULL
   --INVCONV kkillams
  );

END inv_missing_qty_actions_engine;

 

/
