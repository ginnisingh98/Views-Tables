--------------------------------------------------------
--  DDL for Package INV_LOGICAL_TRANSACTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_LOGICAL_TRANSACTIONS_PUB" AUTHID CURRENT_USER AS
/* $Header: INVLTPBS.pls 120.4.12000000.1 2007/01/17 16:21:20 appldev ship $ */

-- Global constant holding the package name
G_PKG_NAME CONSTANT VARCHAR2(30) := 'INV_LOGICAL_TRANSACTIONS_PUB';

G_RET_STS_SUCCESS      CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
G_RET_STS_ERROR        CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

G_TRUE                 CONSTANT VARCHAR2(1) := FND_API.G_TRUE;
G_FALSE                CONSTANT VARCHAR2(1) := FND_API.G_FALSE;

-- Global constant for logical transaction type code
G_LOGTRXCODE_DSRECEIPT     CONSTANT NUMBER := INV_LOGICAL_TRANSACTION_GLOBAL.G_LOGTRXCODE_DSRECEIPT;
G_LOGTRXCODE_DSDELIVER     CONSTANT NUMBER := INV_LOGICAL_TRANSACTION_GLOBAL.G_LOGTRXCODE_DSDELIVER;
G_LOGTRXCODE_GLOBPROCRTV   CONSTANT NUMBER := INV_LOGICAL_TRANSACTION_GLOBAL.G_LOGTRXCODE_GLOBPROCRTV;
G_LOGTRXCODE_RETROPRICEUPD CONSTANT NUMBER := INV_LOGICAL_TRANSACTION_GLOBAL.G_LOGTRXCODE_RETROPRICEUPD;
G_LOGTRXCODE_RMASOISSUE    CONSTANT NUMBER := INV_LOGICAL_TRANSACTION_GLOBAL.G_LOGTRXCODE_RMASOISSUE;

-- Global constant for logical transaction type
G_TYPE_LOGL_IC_SHIP_RECEIPT   CONSTANT NUMBER := INV_GLOBALS.G_TYPE_LOGL_IC_SHIP_RECEIPT;
G_TYPE_LOGL_IC_SALES_ISSUE    CONSTANT NUMBER := INV_GLOBALS.G_TYPE_LOGL_IC_SALES_ISSUE;
G_TYPE_LOGL_IC_RECEIPT_RETURN CONSTANT NUMBER := INV_GLOBALS.G_TYPE_LOGL_IC_RECEIPT_RETURN;
G_TYPE_LOGL_IC_SALES_RETURN   CONSTANT NUMBER := INV_GLOBALS.G_TYPE_LOGL_IC_SALES_RETURN;
G_TYPE_LOGL_RMA_RECEIPT       CONSTANT NUMBER := INV_GLOBALS.G_TYPE_LOGL_RMA_RECEIPT;
G_TYPE_LOGL_PO_RECEIPT        CONSTANT NUMBER := INV_GLOBALS.G_TYPE_LOGL_PO_RECEIPT;
G_TYPE_RETRO_PRICE_UPDATE     CONSTANT NUMBER := INV_GLOBALS.G_TYPE_RETRO_PRICE_UPDATE;
G_TYPE_LOGL_SALES_ORDER_ISSUE CONSTANT NUMBER := INV_GLOBALS.G_TYPE_LOGL_SALES_ORDER_ISSUE;
G_TYPE_LOGL_PO_RECEIPT_ADJ    CONSTANT NUMBER := INV_GLOBALS.G_TYPE_LOGL_PO_RECEIPT_ADJ;
g_type_logl_exp_req_receipt   CONSTANT NUMBER := INV_GLOBALS.g_type_logl_exp_req_receipt;
-- Global constant for transaction source type
G_SOURCETYPE_SALESORDER       CONSTANT NUMBER := INV_GLOBALS.G_SOURCETYPE_SALESORDER;
G_SOURCETYPE_RMA              CONSTANT NUMBER := INV_GLOBALS.G_SOURCETYPE_RMA;
G_SOURCETYPE_INVENTORY        CONSTANT NUMBER := INV_GLOBALS.G_SOURCETYPE_INVENTORY;
g_sourcetype_intreq          CONSTANT NUMBER :=  INV_GLOBALS.g_sourcetype_intreq;
g_sourcetype_intorder        CONSTANT NUMBER :=  inv_globals.g_sourcetype_intorder;

  -- Global constant for transaction action
G_ACTION_LOGICALISSUE         CONSTANT NUMBER := INV_GLOBALS.G_ACTION_LOGICALISSUE;
G_ACTION_LOGICALICSALES       CONSTANT NUMBER := INV_GLOBALS.G_ACTION_LOGICALICSALES;
G_ACTION_LOGICALICRECEIPT     CONSTANT NUMBER := INV_GLOBALS.G_ACTION_LOGICALICRECEIPT;
G_ACTION_LOGICALDELADJ        CONSTANT NUMBER := INV_GLOBALS.G_ACTION_LOGICALDELADJ;
G_ACTION_LOGICALICRCPTRETURN  CONSTANT NUMBER := INV_GLOBALS.G_ACTION_LOGICALICRCPTRETURN;
G_ACTION_LOGICALICSALESRETURN CONSTANT NUMBER := INV_GLOBALS.G_ACTION_LOGICALICSALESRETURN;
G_ACTION_LOGICALEXPREQRECEIPT CONSTANT NUMBER := INV_GLOBALS.G_ACTION_LOGICALEXPREQRECEIPT;
G_ACTION_RETROPRICEUPDATE     CONSTANT NUMBER := INV_GLOBALS.G_ACTION_RETROPRICEUPDATE;
G_ACTION_LOGICALRECEIPT       CONSTANT NUMBER := INV_GLOBALS.G_ACTION_LOGICALRECEIPT;
G_ACTION_RECEIPT              CONSTANT NUMBER := INV_GLOBALS.G_ACTION_RECEIPT;
G_ACTION_ISSUE                CONSTANT NUMBER := INV_GLOBALS.G_ACTION_ISSUE;
g_action_intransitshipment    CONSTANT NUMBER := INV_GLOBALS.g_action_intransitshipment;

-- Global constant for defer_logical_transactions_flag
G_DEFER_LOGICAL_TRX           CONSTANT NUMBER := 1;
G_NOT_DEFER_LOGICAL_TRX       CONSTANT NUMBER := 2;
G_DEFER_LOGICAL_TRX_ORG_LEVEL CONSTANT NUMBER := 3;

-- Global constant for exploded_flag
G_EXPLODED     CONSTANT NUMBER := 1;
G_NOT_EXPLODED CONSTANT NUMBER := 2;

-- Global constant for transaction flow type
G_SHIPPING     CONSTANT NUMBER := 1;
G_PROCURING    CONSTANT NUMBER := 2;

-- Record type for transfer price
Type mtl_transfer_price_rec_type is RECORD
  (
     from_org_id             NUMBER
   , to_org_id               NUMBER
   , transfer_price          NUMBER
   , functional_currency_code VARCHAR2(16)
   , incr_transfer_price     NUMBER
   , incr_currency_code      VARCHAR2(15)
  );

-- Table type definition for an array of mtl_transfer_price_rec_type record
TYPE mtl_transfer_price_tbl_type is TABLE of mtl_transfer_price_rec_type
     INDEX BY BINARY_INTEGER;

/*==================================================================================*
 | Procedure : CREATE_LOGICAL_TRX_WRAPPER                                           |
 |                                                                                  |
 | Description : This API is a wrapper that would be called from TM to create       |
 |               logical transactions. This API has the input parameter of          |
 |               transaction id of the inserted SO issue MMT record, check if the   |
 |               selling OU is not the same as the shipping OU, the transaction flow|
 |               exists and new transaction flow is checked, then it creates a      |
 |               record of mtl_trx_rec_type and table of mtl_trx_tbl_type and then  |
 |               calls the create_logical_transactions. This API is mainly called   |
 |               from the INV java TM.                                              |
 |                                                                                  |
 | Input Parameters :                                                               |
 |   p_api_version_number - API version number                                      |
 |   p_init_msg_lst       - Whether initialize the error message list or not        |
 |                          Should be fnd_api.g_false or fnd_api.g_true             |
 |   p_transaction_id     - transaction id of the inserted SO issue MMT record.     |
 |   p_transaction_temp_id - mmtt transaction temp id, only will be passed
 |  from the inventory transaction manager for internal order intransit
 |  shipment transactions, where the destination type is EXPENSE                                                   |
 | Output Parameters :                                                              |
 |   x_return_status      - fnd_api.g_ret_sts_success, if succeeded                 |
 |                          fnd_api.g_ret_sts_exc_error, if an expected error       |
 |                          occurred                                                |
 |                          fnd_api.g_ret_sts_unexp_error, if an unexpected error   |
 |                          occurred                                                |
 |   x_msg_count          - Number of error message in the error message list       |
 |   x_msg_data           - If the number of error message in the error message     |
 |                          message list is one, the error message is in            |
 |                          this output parameter                                   |
 *==================================================================================*/
  PROCEDURE create_logical_trx_wrapper(
            x_return_status       OUT NOCOPY  VARCHAR2
          , x_msg_count           OUT NOCOPY  NUMBER
          , x_msg_data            OUT NOCOPY  VARCHAR2
          , p_api_version_number  IN          NUMBER   := 1.0
          , p_init_msg_lst        IN          VARCHAR2 := G_FALSE
          , p_transaction_id      IN          NUMBER
          , p_transaction_temp_id IN          NUMBER   := NULL
				       );

/*==================================================================================*
 | Procedure : CREATE_LOGICAL_TRANSACTIONS                                          |
 |                                                                                  |
 | Description : The create_logical_transactions API will be a public API that will |
 |               be called from within Oracle Inventory and other modules that would|
 |               like to insert records into mtl_material_transactions table as part|
 |               part of a logical shipment or a logical receipt transaction or a   |
 |               retroactive price change transaction.                              |
 |               The following transactions may trigger such as insert:             |
 |               1. Sales order issue transaction tied to a transaction flow        |
 |                  spanning across multiple operating units.                       |
 |               2. Global procurement transaction tied to a transaction flow       |
 |                  across multiple operating units.                                |
 |               3. Drop ship transaction from a supplier/vendor to a customer      |
 |                  spanning across multiple operating units and tied to a          |
 |                  transaction flow. The drop shipments can also be a combination  |
 |                  of the global procurement and a shipment flow depending on the  |
 |                  receiving operating unit.                                       |
 |               4. Retroactive price update that has a consumption advice already  |
 |                  created.                                                        |
 |               5. In-transit receipt transaction with an expense destination.     |
 |               6. All return transactions such as return to vendor, RMAs or PO    |
 |                  corrections spanning multiple operating units.                  |
 |                                                                                  |
 | Input Parameters:                                                                |
 |   p_api_version_number    - API version number                                   |
 |   p_init_msg_lst          - Whether initialize the error message list or not     |
 |                             Should be fnd_api.g_false or fnd_api.g_true          |
 |   p_mtl_trx_tbl           - An array of mtl_trx_rec_type records, the definition |
 |                             is in the INV_LOGICAL_TRANSACTION_GLOBAL package.    |
 |   p_validation_flag       - To indicate whether the call to this API is a trusted|
 |                             call or not. Depending on this flag, we will decide  |
 |                             whether to validate the parameters passed.           |
 |                             Default will be 'TRUE'                               |
 |   p_trx_flow_header_id    - The header id of the transaction flow that is being  |
 |                             used. This parameter would be null for retroactive   |
 |                             price update transactions.                           |
 |   p_defer_logical_transactions - The flag indicates whether to defer the creation|
 |                             of logical transactions or not. The following are the|
 |                             values:                                              |
 |                             1 - YES. This would indicate that the creation of    |
 |                                 logical transactions would be deferred.          |
 |                             2 - No. This would indicate that the creation of     |
 |                                 logical transactions would not be deferred.      |
 |                             3 - Use the flag set at the Org level. mtl_parameters|
 |                                 will hold the default value for a specific       |
 |                                 organization.                                    |
 |                                 Default would be set to 3 - use the flag set at  |
 |                                 the organization level.                          |
 |   p_logical_trx_type_code - Indentify the type of transaction being processed.   |
 |                             The following are the values:                        |
 |                             1 - Indicates a Drop Ship transaction.               |
 |                             2 - Indicates sales order shipment spanning multiple |
 |                                 operating units/RMA return transaction flow      |
 |                                 across multiple nodes.                           |
 |                             3 - Indicates Global Procurement/Return to Vendor    |
 |                             4 - Retroactive Price Update.                        |
 |                             Null - Transactions that does not belong to any of   |
 |                                    the type mentioned above.                     |
 |                                                                                  |
 |   p_exploded_flag         - This will indicate whether the table of records that |
 |                             is being passed to this API has already been exploded|
 |                             or not. Exploded means that all the logical          |
 |                             transactions for all the intermediate nodes have been|
 |                             created and this API would just perform a bulk insert|
 |                             into MMT. Otherwise, this API has to create all the  |
 |                             logical transactions. Default value will be 2 (No).  |
 |                             The following are the values this can take:          |
 |                             1 - YES. This would indicate that the calling API has|
 |                                 already exploded all the nodes and all this API  |
 |                                 has to do is to insert the logical transactions  |
 |                                 into MMT.                                        |
 |                             2 - No. This would indicate that the calling API has |
 |                                 not done the creation of the logical transactions|
 |                                 and this API would have to explode the           |
 |                                 intermediate nodes.                              |
 | Output Parameters:                                                               |
 |   x_return_status      - fnd_api.g_ret_sts_success, if succeeded                 |
 |                          fnd_api.g_ret_sts_exc_error, if an expected error       |
 |                          occurred                                                |
 |                          fnd_api.g_ret_sts_unexp_error, if an unexpected error   |
 |                          occurred                                                |
 |   x_msg_count          - Number of error message in the error message list       |
 |   x_msg_data           - If the number of error message in the error message     |
 |                          message list is one, the error message is in            |
 |                          this output parameter                                   |
 *==================================================================================*/
  PROCEDURE create_logical_transactions(
            x_return_status              OUT NOCOPY  VARCHAR2
          , x_msg_count                  OUT NOCOPY  NUMBER
          , x_msg_data                   OUT NOCOPY  VARCHAR2
          , p_api_version_number         IN          NUMBER   := 1.0
          , p_init_msg_lst               IN          VARCHAR2 := G_FALSE
          , p_mtl_trx_tbl                IN          INV_LOGICAL_TRANSACTION_GLOBAL.mtl_trx_tbl_type
          , p_validation_flag            IN          VARCHAR2 := G_TRUE
          , p_trx_flow_header_id         IN          NUMBER
          , p_defer_logical_transactions IN          NUMBER := G_DEFER_LOGICAL_TRX_ORG_LEVEL
          , p_logical_trx_type_code      IN          NUMBER := NULL
          , p_exploded_flag              IN          NUMBER := G_NOT_EXPLODED
  );


 PROCEDURE create_deferred_log_txns_cp
   (errbuf               OUT    NOCOPY VARCHAR2,
    retcode              OUT    NOCOPY NUMBER,
    p_api_version        IN     NUMBER,
    p_start_date         IN     VARCHAR2,
    p_end_date           IN     VARCHAR2
    );

 PROCEDURE check_accounting_period_close
   (x_return_status              OUT NOCOPY  VARCHAR2
    , x_msg_count                  OUT NOCOPY  NUMBER
    , x_msg_data                   OUT NOCOPY  VARCHAR2
    , x_period_close               OUT nocopy  VARCHAR2
    , p_api_version_number         IN          NUMBER   := 1.0
    , p_init_msg_lst               IN          VARCHAR2 := G_FALSE
    , p_organization_id            IN NUMBER
    , p_org_id                     IN NUMBER
    , p_period_start_date          IN DATE
    , p_period_end_date            IN DATE
    );

PROCEDURE create_cogs_recognition ( x_return_status OUT nocopy NUMBER,
					x_error_code OUT nocopy VARCHAR2,
					x_error_message OUT nocopy VARCHAR2);

 /*==================================================================================*
 | OPM INVCONV  rseshadr/umoogala  15-feb-2005                                      |
 |   Added following variables and procedure for Process to Discrete and vice-versa |
 |   transfers. For intransit transfers of these type, logical transactons will be  |
 |   created. Owning orgs for these will depend on FOB point.                       |
 *==================================================================================*/

  G_ACTION_INTRANSITRECEIPT     CONSTANT NUMBER := INV_GLOBALS.G_ACTION_INTRANSITRECEIPT;

  -- constants for process/discrete transfers
  -- G_LOGTRXCODE_INTSHIP       CONSTANT NUMBER := INV_LOGICAL_TRANSACTION_GLOBAL.G_LOGTRXCODE_INTSHIP;
  -- G_LOGTRXCODE_INTRECEIPT    CONSTANT NUMBER := INV_LOGICAL_TRANSACTION_GLOBAL.G_LOGTRXCODE_INTRECEIPT;

  -- added 2 new trx types for process/discrete transfer
  -- for inter-org and internal orders
  --
  G_TYPE_LOGL_INTORG_INTRECEIPT  CONSTANT NUMBER := 59;
  G_TYPE_LOGL_INTORG_INTSHIPMENT CONSTANT NUMBER := 60;

  G_TYPE_LOGL_INTORD_INTSHIPMENT CONSTANT NUMBER := 65;
  G_TYPE_LOGL_INTREQ_INTRECEIPT  CONSTANT NUMBER := 76;

  --
  -- added 2 new trx action for process/discrete transfers
  -- also added action for intransit receipt
  --
  G_ACTION_LOGICALINTSHIPMENT   CONSTANT NUMBER := 22;
  G_ACTION_LOGICALINTRECEIPT    CONSTANT NUMBER := 15;

  --
  -- added 2 new global variables for FOB points
  --
  G_FOB_SHIPPING   CONSTANT NUMBER := 1;
  G_FOB_RECEIVING  CONSTANT NUMBER := 2;

  --
  -- added procedure for creating logical trx for any process/discrete
  -- in-transit transfers.
  -- No logical txns will be created for direct transfers
  --
  PROCEDURE create_opm_disc_logical_trx (
      x_return_status       OUT NOCOPY VARCHAR2
    , x_msg_count           OUT NOCOPY NUMBER
    , x_msg_data            OUT NOCOPY VARCHAR2
    , p_api_version_number  IN         NUMBER := 1.0
    , p_init_msg_lst        IN         VARCHAR2 := G_FALSE
    , p_transaction_id      IN         NUMBER
    , p_transaction_temp_id IN         NUMBER
  );

end INV_LOGICAL_TRANSACTIONS_PUB;


 

/
