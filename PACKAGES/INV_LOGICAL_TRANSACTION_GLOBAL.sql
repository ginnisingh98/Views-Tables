--------------------------------------------------------
--  DDL for Package INV_LOGICAL_TRANSACTION_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_LOGICAL_TRANSACTION_GLOBAL" AUTHID CURRENT_USER AS
/* $Header: INVLTGLS.pls 120.2 2006/05/09 17:02:51 pranavat ship $ */

-- Record type for drop ship, global procurement and retroactive price update
-- Description of attributes in the record type
-- TRANSACTION_ID               - transaction id (unique identifier)
-- ORGANIZATION_ID              - organization id of the item being transacted
-- INVENTORY_ITEM_ID            - inventory item id of the item being transacted
-- SUBINVENTORY_CODE            - subinventory code where the material is transacted
-- LOCATOR_ID                   - locator id of the locator where it is transacted
-- TRANSACTION_TYPE_ID          - identifies the type of the transaction
-- TRANSACTION_ACTION_ID        - identifies the action such as receipt, issue...
-- TRANSACTION_SOURCE_TYPE_ID   - identifies the source of the transaction such as PO, sales order
-- TRANSACTION_SOURCE_ID        - maps to po_headers_all.po_header_id for global procurement
--                                and drop shipments with a procurement flow
--                              - maps to mtl_sales_orders.sales_order_id for sales order
--                                shipment flows
-- TRANSACTION_SOURCE_NAME      - identifies the source of the transaction such as RCV, PO etc.
-- TRANSACTION_QUANTITY         - quantity transacted
-- TRANSACTION_UOM              - UOM of the quantity
-- PRIMARY_QUANTITY             - quantity in the primary unit of measure
-- TRANSACTION_DATE             - date of the transaction
-- ACCT_PERIOD_ID               - account period id
-- DISTRIBUTION_ACCOUNT_ID      - distribution account id
-- COSTED_FLAG                  - identifies whether the transaction is costed or not.
--                                This should always be N.
-- ACTUAL_COST                  - holds the actual cost of the transaction
-- INVOICED_FLAG                - identifies whether the transaction is invoiced or not.
--                                This should always be N for logical I/C sales issue and receipt,
--                                costing will change the logical I/C receipt to NULL and
--                                intercompany will process the logical I/C sales issue records
--                                with N invoiced_flag and change it to null after it is invoiced.
-- TRANSACTION_COST             - cost of the transaction, can be current item cost or the transfer
--                                price cost.
-- CURRENCY_CODE                - use existing logic to determine the code
-- CURRENCY_CONVERSION_RATE     - use existing logic to determine the rate
-- CURRENCY_CONVERSION_TYPE     - Would follow the logic that exists in inv txn processor.  If the
--                                rate is available, then use the same information; otherwise
--                                obtain the conversion type using the Inventory Inter-Org
--                                currency conversion profile.
-- CURRENCY_CONVERSION_DATE     - transaction date
-- PM_COST_COLLECTED            - All transactions will be populated with 'N', except for logical
--                                sales order issue, which would contain NULL.
-- TRX_SOURCE_LINE_ID           - identifies the document which created the transaction
--                                maps to oe_order_lines_all.line_id for sales order shipments
--                                and drop ship transactions.
-- SOURCE_CODE                  - identifies the source where it is being inserted
--                                RCV for receiving
-- SOURCE_LINE_ID               - holds the transaction source information that created this record
--                                PO will be passing the transaction_id from rcv_transactions
--                                during drop shipments involving a procurement flow and for
--                                pure global procurement situations.
-- RCV_TRANSACTION_ID           - holds the transaction id from rcv_transactions for global
--                                procurement and drop shipment with a procurement flow tied to it.
-- TRANSFER_ORGANIZATION_ID     - transfer organization of the item.
-- TRANSFER_SUBINVENTORY        - subinventory where the item is transferred.
-- TRANSFER_LOCATOR_ID          - locator where the item is transferred.
-- COST_GROUP_ID                - cost group id
-- TRANSFER_COST_GROUP_ID       - transfer cost group id
-- PROJECT_ID                   - project id if the transaction involves a project.
-- TASK_ID                      - task if if the transaction involves project manufacturing.
-- TO_PROJECT_ID                - project id where the project is transferred.
-- TO_TASK_ID                   - task id where the project is transferred.
-- SHIP_TO_LOCATION_ID          - identifies the location where the material is shipped to.
-- TRANSACTION_MODE             - mode of transaction:can be online(1), immediate(2) or backgroud(3)
-- TRANSACTION_BATCH_ID         - batch id of a group of transactions.
-- TRANSACTION_BATCH_SEQ        - sequence number within a batch.
-- TRX_FLOW_HEADER_ID           - the header id of the defined transaction flow.
-- INTERCOMPANY_COST            - the value of the transfer price, either rolled up cost for a CTP item
--                              - or the transfer cost for a regular item.
-- INTERCOMPANY_PRICING_OPTION  - this flag is for intercompany to determine whether to use the
--                                transfer price or not.
--                                1 - Transfer price to be used by the cost processor.
--                                2 - Do not use the transfer price.
--                                NULL - Do not use the transfer price.
-- RELEASE_ID                   - release_id if the consumption invoice is non-global.
-- CONSUMPTION_PO_HEADER_ID     - po_header_id if the consumption invoice is global.
-- OLD_PO_PRICE                 - the column will hold the old PO price for a retroactive price
--                                change transaction.
-- NEW_PO_PRICE                 - the column will hold the changed PO price for a retroactive price
--                                change transaction.
-- PARENT_TRANSACTION_FLAG      - this flag would indicate which transaction passed to the API is
--                                the parent transaction. The transaction ID of this record will be
--                                stamped as the parent_transaction_id on all the other records
--                                belonging to this transaction flow. (This would be null for
--                                retroactive price update transaction, since we have only one
--                                record to be inserted in MMT).
--                                value: 1 - parent transaction, 0 or null - not parent transaction.
-- LPN_ID                       - the license plate number identifier
-- INTERCOMPANY_CURRENCY_CODE   - the currency code of the intercompany cost

Type mtl_trx_rec_type is RECORD
  (
     TRANSACTION_ID              NUMBER
   , ORGANIZATION_ID             NUMBER
   , INVENTORY_ITEM_ID           NUMBER
   , REVISION                    VARCHAR2(3)
   , SUBINVENTORY_CODE           VARCHAR2(10)
   , LOCATOR_ID                  NUMBER
   , TRANSACTION_TYPE_ID         NUMBER
   , TRANSACTION_ACTION_ID       NUMBER
   , TRANSACTION_SOURCE_TYPE_ID  NUMBER
   , TRANSACTION_SOURCE_ID       NUMBER
   , TRANSACTION_SOURCE_NAME     VARCHAR2(30)
   , TRANSACTION_QUANTITY        NUMBER
   , TRANSACTION_UOM             VARCHAR2(3)
   , PRIMARY_QUANTITY            NUMBER
   , TRANSACTION_DATE            DATE
   , ACCT_PERIOD_ID              NUMBER
   , DISTRIBUTION_ACCOUNT_ID     NUMBER
   , COSTED_FLAG                 VARCHAR2(1)
   , ACTUAL_COST                 NUMBER
   , INVOICED_FLAG               VARCHAR2(1)
   , TRANSACTION_COST            NUMBER
   , CURRENCY_CODE               VARCHAR2(10)
   , CURRENCY_CONVERSION_RATE    NUMBER
   , CURRENCY_CONVERSION_TYPE    VARCHAR2(30)
   , CURRENCY_CONVERSION_DATE    DATE
   , PM_COST_COLLECTED           VARCHAR2(1)
   , TRX_SOURCE_LINE_ID          NUMBER
   , SOURCE_CODE                 VARCHAR2(30)
   , RCV_TRANSACTION_ID          NUMBER
   , SOURCE_LINE_ID              NUMBER
   , TRANSFER_ORGANIZATION_ID    NUMBER
   , TRANSFER_SUBINVENTORY       VARCHAR2(10)
   , TRANSFER_LOCATOR_ID         NUMBER
   , COST_GROUP_ID               NUMBER
   , TRANSFER_COST_GROUP_ID      NUMBER
   , PROJECT_ID                  NUMBER
   , TASK_ID                     NUMBER
   , TO_PROJECT_ID               NUMBER
   , TO_TASK_ID                  NUMBER
   , SHIP_TO_LOCATION_ID         NUMBER
   , TRANSACTION_MODE            NUMBER
   , TRANSACTION_BATCH_ID        NUMBER
   , TRANSACTION_BATCH_SEQ       NUMBER
   , TRX_FLOW_HEADER_ID          NUMBER
   , INTERCOMPANY_COST           NUMBER
   , INTERCOMPANY_PRICING_OPTION NUMBER
   , PARENT_TRANSACTION_ID       NUMBER
   , CONSUMPTION_RELEASE_ID      NUMBER
   , CONSUMPTION_PO_HEADER_ID    NUMBER
   , OLD_PO_PRICE                NUMBER
   , NEW_PO_PRICE                NUMBER
   , PARENT_TRANSACTION_FLAG     NUMBER
   , LPN_ID                      NUMBER
  , INTERCOMPANY_CURRENCY_CODE  VARCHAR2(15)
  , po_distribution_id NUMBER
  );


-- Table type definition for an array of mtl_trx_rec_type records
TYPE mtl_trx_tbl_type is TABLE OF mtl_trx_rec_type INDEX BY BINARY_INTEGER;

/*========================================================================*
 | International Drop Shipment Project - Patchset J                       |
 | Following constant are for Logical Transaction Type Code which will    |
 | identify the type of transaction being processed.                      |
 | 1 - Indicates a Drop Ship Receipt transaction corresponding to the     |
 |     procurement flow set up in the intercompany relations form between |
 |     the procuring OU and the receiving OU.                             |
 | 2 - Indicates a Drop Ship Deliver transaction corresponding to the     |
 |     shipping flow set up in the intercompany relations form between the|
 |     shipping OU and the selling OU.                                    |
 | 3 - Indicates Global Procurement /Return to Vendor transaction set up  |
 |     between the procuring and the receiving OU.                        |
 | 4 - Retroactive Price Update transaction type.                         |
 | 5 - Indicates sales order shipment spanning multiple operating units / |
 |     RMA return transaction flow across multiple nodes corresonding to  |
 |     the transaction flow set up between the shipping and the selling   |
 |     OUs.                                                               |
 | null - Transactions that does not belong to any of the type mentioned  |
 |        above.                                                          |
 *========================================================================*/
G_LOGTRXCODE_DSRECEIPT     CONSTANT NUMBER := 1;
G_LOGTRXCODE_DSDELIVER     CONSTANT NUMBER := 2;
G_LOGTRXCODE_GLOBPROCRTV   CONSTANT NUMBER := 3;
G_LOGTRXCODE_RETROPRICEUPD CONSTANT NUMBER := 4;
G_LOGTRXCODE_RMASOISSUE    CONSTANT NUMBER := 5;

/* INVCONV rseshadr */
G_LOGTRXCODE_INV_INTRECEIPT   CONSTANT NUMBER := 59; /* source Inventory */
G_LOGTRXCODE_INV_INTSHIP      CONSTANT NUMBER := 60; /* source Inventory */
G_LOGTRXCODE_IREQ_INTRECEIPT  CONSTANT NUMBER := 76; /* source Int. Req. */
G_LOGTRXCODE_IO_INTSHIP       CONSTANT NUMBER := 65; /* source Int. Ord. */

end INV_LOGICAL_TRANSACTION_GLOBAL;

 

/
