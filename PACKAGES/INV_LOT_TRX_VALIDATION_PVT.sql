--------------------------------------------------------
--  DDL for Package INV_LOT_TRX_VALIDATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_LOT_TRX_VALIDATION_PVT" AUTHID CURRENT_USER AS
/* $Header: INVVLTVS.pls 120.1 2005/06/17 06:57:04 appldev  $ */

-- Global constant holding the package name
   G_PKG_NAME           CONSTANT VARCHAR2(30) := 'INV_LOT_TRX_VALIDATION_PVT';

/*********************************************************************************************
 * Procedure
 *      Validate_Lot_Split_Trx
 * Description:
 *    This procedure will validate the records for lot split transactions,
 *    This will get all records for the lot split from mtl_transactions_interface
 *    then call the public validation APIs to validate the lots, the result lots, the
 *    the material status, the cost groups and the lot attributes
 * Input Parameters:
 *    p_parent_id  - The transaction_interface_id of the parent lot
 *
 *  Output Parameters:
 *    x_return_status -- return status, S- success, E - error, U- unexpected error
 *    x_msg_count     -- number of error message in the message stack.
 *    x_msg_data      -- the error message on the top of the message stack.
 *    x_validation_status -- 'Y' if validation is successfull, 'N' if not successfull.
 *
 *  Dependency:
 *    None.
 *
 *  Called By:
 *    INV_TXN_MANAGER_PUB.process_transactions
 **************************************************************************************************/

   procedure validate_lot_split_trx(
	x_return_status			OUT NOCOPY VARCHAR2,
	x_msg_count			OUT NOCOPY NUMBER,
	x_msg_data			OUT NOCOPY VARCHAR2,
	x_validation_status		OUT NOCOPY VARCHAR2,
	p_parent_id			IN NUMBER
   );

/*********************************************************************************************
 * Procedure
 *      Validate_Lot_Merge_trx
 * Description:
 *    This procedure will validate the records for lot merge transactions,
 *    This will get all records for the lot split from mtl_transactions_interface
 *    then call the public validation APIs to validate the lots, the result lots, the
 *    the material status, the cost groups and the lot attributes
 * Input Parameters:
 *    p_parent_id  - The transaction_interface_id of the parent lot
 *
 *  Output Parameters:
 *    x_return_status -- return status, S- success, E - error, U- unexpected error
 *    x_msg_count     -- number of error message in the message stack.
 *    x_msg_data      -- the error message on the top of the message stack.
 *    x_validation_status -- 'Y' if validation is successfull, 'N' if not successfull.
 *
 *  Dependency:
 *    None.
 *
 *  Called By:
 *    INV_TXN_MANAGER_PUB.process_transactions
 **************************************************************************************************/
   procedure validate_lot_merge_trx(
	x_return_status			OUT NOCOPY VARCHAR2,
	x_msg_count			OUT NOCOPY NUMBER,
	x_msg_data			OUT NOCOPY VARCHAR2,
	x_validation_status		OUT NOCOPY VARCHAR2,
	p_parent_id			IN NUMBER
   );

/*********************************************************************************************
 * Procedure
 *      Validate_Lot_Translate_Trx
 * Description:
 *    This procedure will validate the records for lot translate transactions,
 *    This will get all records for the lot split from mtl_transactions_interface
 *    then call the public validation APIs to validate the lots, the result lots, the
 *    the material status, the cost groups and the lot attributes
 * Input Parameters:
 *    p_parent_id  - The transaction_interface_id of the parent lot
 *
 *  Output Parameters:
 *    x_return_status -- return status, S- success, E - error, U- unexpected error
 *    x_msg_count     -- number of error message in the message stack.
 *    x_msg_data      -- the error message on the top of the message stack.
 *    x_validation_status -- 'Y' if validation is successfull, 'N' if not successfull.
 *
 *  Dependency:
 *    None.
 *
 *  Called By:
 *    INV_TXN_MANAGER_PUB.process_transactions
 **************************************************************************************************/

   procedure validate_lot_translate_trx(
	x_return_status			OUT NOCOPY VARCHAR2,
	x_msg_count			OUT NOCOPY NUMBER,
	x_msg_data			OUT NOCOPY VARCHAR2,
	x_validation_status		OUT NOCOPY VARCHAR2,
	p_parent_id			IN NUMBER
   );

END INV_LOT_TRX_VALIDATION_PVT;

 

/
