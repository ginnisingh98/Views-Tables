--------------------------------------------------------
--  DDL for Package INV_LOGICAL_TRANSACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_LOGICAL_TRANSACTIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: INVLTPVS.pls 115.3 2003/10/15 06:14:36 lplam noship $ */


TYPE VARCHAR30_TBL IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

-- Procedure
--    validate_input_parameters
-- Description
--    validate the input paremters before populating the
--    inventory transactions table.

PROCEDURE validate_input_parameters
  (
   x_return_status            	        OUT    	NOCOPY  VARCHAR2
   , x_msg_count                	OUT    	NOCOPY NUMBER
   , x_msg_data                 	OUT    	NOCOPY VARCHAR2
   , p_api_version_number  IN          NUMBER := 1.0
   , p_init_msg_lst        IN          VARCHAR2 DEFAULT fnd_api.g_false
   , p_mtl_trx_tbl                 	IN     	inv_logical_transaction_global.mtl_trx_tbl_type
   , p_validation_level         	IN     	VARCHAR2 DEFAULT fnd_api.g_true
   , p_logical_trx_type_code	        IN	NUMBER  DEFAULT NULL
   );


/*==========================================================================*
 | Procedure : INV_MMT_INSERT                                               |
 |                                                                          |
 | Description : This API will be called by INV create logical transactions |
 |               API to do a bulk insert into MTL_MATERIAL_TRANSACTIONS     |
 |               table.                                                     |
 |                                                                          |
 | Input Parameters :                                                       |
 |   p_api_version_number - API version number                              |
 |   p_init_msg_lst       - Whether initialize the error message list or not|
 |                          Should be fnd_api.g_false or fnd_api.g_true     |
 |   p_mtl_trx_rec        - An array of mtl_trx_rec_type records            |
 |                                                                          |
 | Output Parameters :                                                      |
 |   x_return_status      - fnd_api.g_ret_sts_success, if succeeded         |
 |                          fnd_api.g_ret_sts_exc_error, if an expected     |
 |                          error occurred                                  |
 |                          fnd_api.g_ret_sts_unexp_error, if an unexpected |
 |                          eror occurred                                   |
 |   x_msg_count          - Number of error message in the error message    |
 |                          list                                            |
 |   x_msg_data           - If the number of error message in the error     |
 |                          message list is one, the error message is in    |
 |                          this output parameter                           |
 *==========================================================================*/

  PROCEDURE inv_mmt_insert
   (
      x_return_status       OUT NOCOPY  VARCHAR2
    , x_msg_count           OUT NOCOPY  NUMBER
    , x_msg_data            OUT NOCOPY  VARCHAR2
    , p_api_version_number  IN          NUMBER := 1.0
    , p_init_msg_lst        IN          VARCHAR2 DEFAULT fnd_api.g_false
    , p_mtl_trx_tbl         IN
    inv_logical_transaction_global.mtl_trx_tbl_type
    , p_logical_trx_type_code	        IN	NUMBER
  );

/*==========================================================================*
 | Procedure : INV_LOT_SERIAL_INSERT                                        |
 |                                                                          |
 | Description : This API will be called by INV create_logical_transactions |
 |               API to do a bulk insert into mtl_transaction_lot_numbers if|
 |               the item is lot control and insert into                    |
 |               mtl_unit_transactions if the item is serial control.       |
 |                                                                          |
 | Input Parameters :                                                       |
 |   p_api_version_number - API version number                              |
 |   p_init_msg_lst       - Whether initialize the error message list or not|
 |                          Should be fnd_api.g_false or fnd_api.g_true     |
 |   p_parent_transaction_id  - the transaction id of the parent transaction|
 |                              in mmt.                                     |
 |   p_transaction_id     - the transaction id of the parent transaction in |
 |                          mmt.                                            |
 |   p_lot_control_code   - the lot control code of the item                |
 |   p_serial_control_code - the serial control code of the item            |
 |                                                                          |
 | Output Parameters :                                                      |
 |   x_return_status      - fnd_api.g_ret_sts_success, if succeeded         |
 |                          fnd_api.g_ret_sts_exc_error, if an expected     |
 |                          error occurred                                  |
 |                          fnd_api.g_ret_sts_unexp_error, if an unexpected |
 |                          eror occurred                                   |
 |   x_msg_count          - Number of error message in the error message    |
 |                          list                                            |
 |   x_msg_data           - If the number of error message in the error     |
 |                          message list is one, the error message is in    |
 |                          this output parameter                           |
 *==========================================================================*/

 PROCEDURE inv_lot_serial_insert
  (
      x_return_status         OUT NOCOPY  VARCHAR2
    , x_msg_count             OUT NOCOPY  NUMBER
    , x_msg_data              OUT NOCOPY  VARCHAR2
    , p_api_version_number    IN          NUMBER := 1.0
    , p_init_msg_lst          IN          VARCHAR2 DEFAULT fnd_api.g_false
    , p_parent_transaction_id IN          NUMBER
    , p_transaction_id        IN          NUMBER
    , p_lot_control_code      IN          NUMBER
    , p_serial_control_code   IN          NUMBER
    , p_organization_id       IN          NUMBER
    , p_inventory_item_id     IN          NUMBER
    , p_primary_quantity      IN          NUMBER
    , p_trx_source_type_id    IN          NUMBER
    , p_revision              IN          VARCHAR2
  );

/*==========================================================================*
 | Procedure : GENERATE_SERIAL_NUMBERS                                      |
 |                                                                          |
 | Description : This API will generate serial numbers with the quantity    |
 |               provided and store it in a pl/sql table.                   |
 |                                                                          |
 | Input Parameters :                                                       |
 |   p_org_id   - the organization_id to generate the serial number.        |
 |   p_item_id  - the inventory_item_id to generate the serial number.      |
 |   p_lot_number - the lot number of the item.                             |
 |   p_qty      - the number of serial numbers that need to be generated.   |
 |   p_revision - the revision of the item.                                 |
 |                                                                          |
 | Output Parameters :                                                      |
 |   x_return_status      - fnd_api.g_ret_sts_success, if succeeded         |
 |                          fnd_api.g_ret_sts_exc_error, if an expected     |
 |                          error occurred                                  |
 |                          fnd_api.g_ret_sts_unexp_error, if an unexpected |
 |                          eror occurred                                   |
 |   x_msg_count          - Number of error message in the error message    |
 |                          list                                            |
 |   x_msg_data           - If the number of error message in the error     |
 |                          message list is one, the error message is in    |
 |                          this output parameter                           |
 |   x_ser_num_tbl        - the pl/sql table of generated serial number.    |
 *==========================================================================*/

 PROCEDURE generate_serial_numbers
  (
      x_return_status         OUT NOCOPY  VARCHAR2
    , x_msg_count             OUT NOCOPY  NUMBER
    , x_msg_data              OUT NOCOPY  VARCHAR2
    , x_ser_num_tbl           OUT NOCOPY  VARCHAR30_TBL
    , p_org_id                IN          NUMBER
    , p_item_id               IN          NUMBER
    , p_lot_number            IN          VARCHAR2
    , p_qty                   IN          NUMBER
    , p_revision              IN          VARCHAR2
  );

/*==========================================================================*
 | Procedure : INV_MUT_INSERT                                               |
 |                                                                          |
 | Description : This API will insert records into mtl_unit_transactions.   |
 |                                                                          |
 | Input Parameters :                                                       |
 |   p_parent_serial_trx_id   - the serial transaction id from the parent   |
 |                              record                                      |
 |   p_serial_transaction_id  - the serial transaction id that should insert|
 |                              into mtl_unit_transactions.                 |
 |   p_serial_number_tbl      - the serial numbers that need to be inserted |
 |                              into mtl_unit_transactions.                 |
 |   p_organization_id        - the organization id.                        |
 |   p_inventory_item_Id      - the inventory item id.                      |
 |   p_trx_source_type_id     - the transaction source type id.             |
 |   p_receipt_issue_type     - the type of the transaction                 |
 |                              1 - issue                                   |
 |                              2 - receipt                                 |
 | Output Parameters :                                                      |
 |   x_return_status      - fnd_api.g_ret_sts_success, if succeeded         |
 |                          fnd_api.g_ret_sts_exc_error, if an expected     |
 |                          error occurred                                  |
 |                          fnd_api.g_ret_sts_unexp_error, if an unexpected |
 |                          eror occurred                                   |
 |   x_msg_count          - Number of error message in the error message    |
 |                          list                                            |
 |   x_msg_data           - If the number of error message in the error     |
 |                          message list is one, the error message is in    |
 |                          this output parameter                           |
 *==========================================================================*/

 PROCEDURE inv_mut_insert
  (
      x_return_status         OUT NOCOPY    VARCHAR2
    , x_msg_count             OUT NOCOPY    NUMBER
    , x_msg_data              OUT NOCOPY    VARCHAR2
    , x_serial_number_tbl     IN OUT NOCOPY VARCHAR30_TBL
    , p_parent_serial_trx_id  IN            NUMBER
    , p_serial_transaction_id IN            NUMBER
    , p_organization_id       IN            NUMBER
    , p_inventory_item_id     IN            NUMBER
    , p_trx_source_type_id    IN            NUMBER
    , p_receipt_issue_type    IN            NUMBER
  );

/*==========================================================================*
 | Procedure : UPDATE_SERIAL_NUMBERS                                        |
 |                                                                          |
 | Description : This API will update the current_status of the serial      |
 |               number in mtl_serial_numbers to issue out of store.        |
 |                                                                          |
 | Input Parameters :                                                       |
 |   p_serial_number_tbl      - the serial numbers that need to be updated  |
 |                              in mtl_serial_numbers.                      |
 |   p_organization_id        - the organization id.                        |
 |   p_inventory_item_Id      - the inventory item id.                      |
 |                                                                          |
 | Output Parameters :                                                      |
 |   x_return_status      - fnd_api.g_ret_sts_success, if succeeded         |
 |                          fnd_api.g_ret_sts_exc_error, if an expected     |
 |                          error occurred                                  |
 |                          fnd_api.g_ret_sts_unexp_error, if an unexpected |
 |                          eror occurred                                   |
 |   x_msg_count          - Number of error message in the error message    |
 |                          list                                            |
 |   x_msg_data           - If the number of error message in the error     |
 |                          message list is one, the error message is in    |
 |                          this output parameter                           |
 *==========================================================================*/
 PROCEDURE update_serial_numbers
  (
      x_return_status         OUT NOCOPY  VARCHAR2
    , x_msg_count             OUT NOCOPY  NUMBER
    , x_msg_data              OUT NOCOPY  VARCHAR2
    , p_ser_num_tbl           IN          VARCHAR30_TBL
    , p_organization_id       IN          NUMBER
    , p_inventory_item_id     IN          NUMBER
  );

END inv_logical_transactions_pvt;

 

/
