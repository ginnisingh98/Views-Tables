--------------------------------------------------------
--  DDL for Package Body INV_DS_LOGICAL_TRX_INFO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DS_LOGICAL_TRX_INFO_PUB" AS
/* $Header: INVLTIPB.pls 115.4 2004/05/12 18:45:01 vipartha noship $ */

l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

 PROCEDURE print_debug
   (
    p_err_msg       IN VARCHAR2,
    p_level         IN NUMBER := 9
    ) IS
 BEGIN
    INV_LOG_UTIL.trace
      (p_message => p_err_msg,
       p_module  => 'INV_DS_LOGICAL_TRX_INFO_PUB',
       p_level   => p_level);
 END print_debug;



/*==========================================================================*
 | Procedure : GET_LOGICAL_ATTR_VALUES                                      |
 |                                                                          |
 | Description : This API will be called by Install base for a              |
 |                 specific transafction to get all the attributes tied to  |
 |                  a drop shipment so that they can update the inventory   |
 |               accordingly                                                |
 |                                                                          |
 |                                                                          |
 | Input Parameters :                                                       |
 |   p_api_version_number - API version number                              |
 |   p_init_msg_lst       - Whether initialize the error message list or not|
 |                          Should be fnd_api.g_false or fnd_api.g_true     |
 |   p_transaction_id     - transaction id of the inserted SO issue MMT     |
 |                          record.                                         |
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
 |   x_logical_trx_attr_values - returns a record type with all the attributes|
 |                                  for a logical transaction.              |
 *==========================================================================*/

   PROCEDURE GET_LOGICAL_ATTR_VALUES
   (
    x_return_status       OUT NOCOPY  VARCHAR2
    , x_msg_count           OUT NOCOPY  NUMBER
    , x_msg_data            OUT nocopy VARCHAR2
    , x_logical_trx_attr_values  OUT NOCOPY INV_DROPSHIP_GLOBALS.logical_trx_attr_tbl
    , p_api_version_number  IN          NUMBER   := 1.0
    , p_init_msg_lst        IN          VARCHAR2 := G_FALSE
    , p_transaction_id      IN          NUMBER
    )
   IS
      --Bug 3620584: Changed the SQL to improve performance. Removed the OR
      -- condition and used a UNION in its place.

      CURSOR logical_transactions(l_txn_id NUMBER)
	IS
	   SELECT transaction_id,transaction_type_id,
	     transaction_source_type_id,transaction_action_id,
	     parent_transaction_id,logical_trx_type_code,
	     intercompany_cost,intercompany_pricing_option,
	     trx_flow_header_id,logical_transactions_created,
	     logical_transaction,intercompany_currency_code

	     FROM MTL_MATERIAL_TRANSACTIONS
	     WHERE TRANSACTION_ACTION_ID NOT IN (24,30) AND
	     (transaction_id = p_transaction_id)

	     UNION

	      SELECT transaction_id,transaction_type_id,
	     transaction_source_type_id,transaction_action_id,
	     parent_transaction_id,logical_trx_type_code,
	     intercompany_cost,intercompany_pricing_option,
	     trx_flow_header_id,logical_transactions_created,
	     logical_transaction,intercompany_currency_code
	     FROM MTL_MATERIAL_TRANSACTIONS
	     WHERE TRANSACTION_ACTION_ID NOT IN (24,30) AND
	     ( PARENT_TRANSACTION_ID IN
	       (SELECT PARENT_TRANSACTION_ID FROM MTL_MATERIAL_TRANSACTIONS
		WHERE TRANSACTION_ACTION_ID NOT IN (24,30) AND
		(transaction_id = p_transaction_id)) AND
	       PARENT_TRANSACTION_ID IS NOT NULL);

	       l_index NUMBER := 0;



   BEGIN

      IF (l_debug = 1) THEN
	 print_debug('enter get logical attr values', 9);
	 print_debug('p_transaction_id = ' || p_transaction_id, 9);
      END IF;


      FOR l_logical_transactions IN logical_transactions(p_transaction_id)

	LOOP

	   l_index := l_index + 1;

	   x_logical_trx_attr_values(l_index).transaction_id :=
	     l_logical_transactions.transaction_id;
	   x_logical_trx_attr_values(l_index).transaction_type_id :=
	     l_logical_transactions.transaction_type_id;
	    x_logical_trx_attr_values(l_index).transaction_source_type_id :=
	     l_logical_transactions.transaction_source_type_id;
	   x_logical_trx_attr_values(l_index).transaction_action_id :=
	     l_logical_transactions.transaction_action_id;
	   x_logical_trx_attr_values(l_index).parent_transaction_id :=
	     l_logical_transactions.parent_transaction_id;
	   x_logical_trx_attr_values(l_index).logical_trx_type_code :=
	     l_logical_transactions.logical_trx_type_code;
	   x_logical_trx_attr_values(l_index).intercompany_cost :=
	     l_logical_transactions.intercompany_cost;
	   x_logical_trx_attr_values(l_index).intercompany_pricing_option
	     := l_logical_transactions.intercompany_pricing_option;
	   x_logical_trx_attr_values(l_index).trx_flow_header_id  :=
	     l_logical_transactions.trx_flow_header_id;
	   x_logical_trx_attr_values(l_index).logical_transactions_created
	     := l_logical_transactions.logical_transactions_created;
	   x_logical_trx_attr_values(l_index).logical_transaction :=
	     l_logical_transactions.logical_transaction;
	   x_logical_trx_attr_values(l_index).intercompany_currency_code :=
	     l_logical_transactions.intercompany_currency_code;

	   IF (l_debug = 1) THEN
	      print_debug('l_transaction_id' || p_transaction_id, 9);
	   END IF;

	END LOOP;

      x_return_status := g_ret_sts_success;

   EXCEPTION
      WHEN  FND_API.G_EXC_ERROR THEN
	 x_return_status := G_RET_STS_ERROR;
	 FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
	 IF (l_debug = 1) THEN
	    print_debug('INV_DS_LOGICAL_TRX_INFO_PUB: no_data_found error', 9);
	    print_debug('SQL Error: ' || Sqlerrm(SQLCODE), 9);
	 END IF;
      WHEN OTHERS THEN
	 x_return_status := G_RET_STS_UNEXP_ERROR;

	 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'INV_DS_LOGICAL_TRX_INFO_PUB');
	 END IF;
	 FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
	 IF (l_debug = 1) THEN
	    print_debug('INV_DS_LOGICAL_TRX_INFO_PUB: others error', 9);
	    print_debug('SQL Error: ' || Sqlerrm(SQLCODE), 9);
	 END IF;

   END get_logical_attr_values;

END INV_DS_LOGICAL_TRX_INFO_PUB;


/
