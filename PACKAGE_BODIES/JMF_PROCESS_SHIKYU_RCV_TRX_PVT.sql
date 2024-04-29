--------------------------------------------------------
--  DDL for Package Body JMF_PROCESS_SHIKYU_RCV_TRX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JMF_PROCESS_SHIKYU_RCV_TRX_PVT" AS
-- $Header: JMFVSKTB.pls 120.14 2006/11/23 15:22:33 vmutyala noship $

--=============================================
-- CONSTANTS
--=============================================
G_MODULE_PREFIX CONSTANT VARCHAR2(50) := 'jmf.plsql.' || G_PKG_NAME || '.';

--=============================================
-- GLOBAL VARIABLES
--=============================================

g_debug_level        NUMBER := NULL;
g_proc_level         NUMBER := NULL;
g_unexp_level        NUMBER := NULL;
g_excep_level        NUMBER := NULL;
g_statement_level    NUMBER := NULL;

PROCEDURE Init;
PROCEDURE Validate_And_Allocate
( p_init_msg_list           IN  VARCHAR2
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, x_return_flag             OUT NOCOPY NUMBER
, p_po_shipment_id          IN  NUMBER
, p_project_id		    IN  NUMBER
, p_task_id		    IN  NUMBER
);

--========================================================================
-- PROCEDURE : Process_Shikyu_Rcv_trx	PUBLIC
-- PARAMETERS: p_api_version  	IN Standard in parameter API version
--             p_init_msg_list 	IN Standard in parameter message list
--             p_request_id  	IN Request Id
--             p_group_id 	IN Group Id
--             x_return_status  OUT Stadard out parameter for return status
--                                     (Values E(Error), S(Success), U(Unexpected error))
--
-- COMMENT   : This concurrent program will be called to process OSA Receipt,
--             OSA Return and RTV of SHIKYU Components at MP site. RTV of SHIKYU
--             Component is triggered by SHIKYU RMA at OEM site.
--             Following is core logic:
--1. Get all records from history table rcv_transactions corresponding to records in staging table.
--
--2. Club correction related records to their parent records if parent transactions are also present in staging table.
--
--  Currently only correction transaction are clubbed parent records
--
--3. Process records after clubbing.
-- If source document code is 'PO' then
--  {
--   If transaction type is 'RECEIVE' then
--    call OSA Receipt( poShipmentLineId )
--   else if transaction type is 'RETURN TO VENDOR' then
--    call OSA Return( poShipmentLineId )
--   else if transaction type is 'CORRECT' and parent Transaction Type in ('RECEIVE', 'DELIVER') then
--    call OSA Receipt( poShipmentLineId )
--   else if transaction type is 'CORRECT' and parent Transaction Type is 'RETURN TO VENDOR' then
--    call OSA Return( poShipmentLineId )
--  }
--  else source document code is 'RMA'
--  {
--   if transaction type is 'RECEIVE'  then
--    call ProcessComponentReturn( OeOrderLineId )
--   -- we're not supporting corrections or returns against RMA
--   -- so other transaction types are not considered.
--}
--========================================================================
PROCEDURE Process_Shikyu_Rcv_trx(
      p_api_version             IN  NUMBER,
      p_init_msg_list           IN  VARCHAR2,
      p_request_id           NUMBER,
      p_group_id             NUMBER,
      x_return_status        OUT NOCOPY VARCHAR2
   ) IS
   -- p_request_id and p_group_id are optional parameters that can be specified to limit the scope of transactions to process

      -- Define a record type to contain required transaction details from rcv_transactions.
      TYPE rcv_pending_trx_rec IS RECORD
      ( transaction_id            rcv_transactions.transaction_id%Type
      , source_document_code      rcv_transactions.source_document_code%Type
      , transaction_type          rcv_transactions.transaction_type%Type
      , primary_quantity          rcv_transactions.primary_quantity%Type
      , primary_unit_of_measure   rcv_transactions.primary_unit_of_measure%Type
      , parent_transaction_id     rcv_transactions.parent_transaction_id%Type
      , po_line_location_id       rcv_transactions.po_line_location_id%Type
      , project_id                rcv_transactions.project_id%Type
      , task_id                   rcv_transactions.task_id%Type
      , oe_order_line_id          rcv_transactions.oe_order_line_id%Type
      , process_type              VARCHAR2(10)
      , clubbed_transaction_id    rcv_transactions.transaction_id%Type
      , error_status              rcv_staging_table.status%Type
      );

      -- Define a table of above record type
      TYPE rcv_pending_trx_tbl IS TABLE OF rcv_pending_trx_rec
       INDEX BY BINARY_INTEGER;
      l_rcv_pending_trx_tbl          rcv_pending_trx_tbl;
      l_rcv_pending_clubbed_trx_tbl  rcv_pending_trx_tbl;

      rcv_success_trx_ids DBMS_SQL.number_table;
      rcv_error_trx_ids   DBMS_SQL.number_table;
      l_net_Quantity      NUMBER;
      l_primary_uom_code  VARCHAR2(3);
      l_exists            BOOLEAN;
      l_parent_transaction_type rcv_transactions.transaction_type%Type;
      l_error_trx_index   NUMBER;

      -- Define standard variables.
      l_msg_count NUMBER;
      l_msg_data VARCHAR2(2000);
      l_api_name       CONSTANT VARCHAR2(30) := 'Process_Shikyu_Rcv_trx';
      l_api_version    CONSTANT NUMBER       := 1.0;

      --   vmutyala changed the cursor get_rcv_transactions to fetch transactions from
      --   rcv_transactions and rcv_staging_table only if the Shipment_ID of the
      --   transaction in RCV_STAGING_TABLE exists in jmf_subcontract_orders Bug 4670527



      CURSOR get_rcv_transactions_case1 IS
       SELECT distinct (rt.TRANSACTION_ID), rt.SOURCE_DOCUMENT_CODE,
              rt.TRANSACTION_TYPE, rt.PRIMARY_QUANTITY, rt.PRIMARY_UNIT_OF_MEASURE,
              rt.PARENT_TRANSACTION_ID,rt.PO_LINE_LOCATION_ID,
              rt.PROJECT_ID, rt.TASK_ID, rt.OE_ORDER_LINE_ID, null, null, rst.status
       FROM   rcv_transactions  rt, rcv_staging_table rst
       WHERE  rst.transaction_id = rt.transaction_id
	AND   rst.transaction_request_id = p_request_id
       	AND   rst.transaction_group_id = p_group_id
        AND   rst.team = g_team_name
	AND  EXISTS(
                SELECT        1
	        FROM          jmf_subcontract_orders jso
	        WHERE         rt.SOURCE_DOCUMENT_CODE = 'PO'
	        AND           jso.SUBCONTRACT_PO_SHIPMENT_ID = rt.PO_LINE_LOCATION_ID
	        UNION
		SELECT 	      1
		FROM          OE_ORDER_LINES_ALL OOLA , JMF_SHIKYU_REPLENISHMENTS JSR
		WHERE         rt.SOURCE_DOCUMENT_CODE = 'RMA'
		AND           rt.OE_ORDER_LINE_ID = OOLA.LINE_ID
		AND           OOLA.REFERENCE_LINE_ID = JSR.REPLENISHMENT_SO_LINE_ID
		)
	ORDER BY rt.transaction_id;


	CURSOR get_rcv_transactions_case2 IS
       SELECT distinct (rt.TRANSACTION_ID), rt.SOURCE_DOCUMENT_CODE,
              rt.TRANSACTION_TYPE, rt.PRIMARY_QUANTITY, rt.PRIMARY_UNIT_OF_MEASURE,
              rt.PARENT_TRANSACTION_ID,rt.PO_LINE_LOCATION_ID,
              rt.PROJECT_ID, rt.TASK_ID, rt.OE_ORDER_LINE_ID, null, null, rst.status
       FROM   rcv_transactions  rt, rcv_staging_table rst
       WHERE  rst.transaction_id = rt.transaction_id
        AND   rst.transaction_request_id = p_request_id
       	AND   rst.team = g_team_name
	AND  EXISTS(
                SELECT        1
	        FROM          jmf_subcontract_orders jso
	        WHERE         rt.SOURCE_DOCUMENT_CODE = 'PO'
	        AND           jso.SUBCONTRACT_PO_SHIPMENT_ID = rt.PO_LINE_LOCATION_ID
	        UNION
		SELECT 	      1
		FROM          OE_ORDER_LINES_ALL OOLA , JMF_SHIKYU_REPLENISHMENTS JSR
		WHERE         rt.SOURCE_DOCUMENT_CODE = 'RMA'
		AND           rt.OE_ORDER_LINE_ID = OOLA.LINE_ID
		AND           OOLA.REFERENCE_LINE_ID = JSR.REPLENISHMENT_SO_LINE_ID
		)
	ORDER BY rt.transaction_id;

	CURSOR get_rcv_transactions_case3 IS
       SELECT distinct (rt.TRANSACTION_ID), rt.SOURCE_DOCUMENT_CODE,
              rt.TRANSACTION_TYPE, rt.PRIMARY_QUANTITY, rt.PRIMARY_UNIT_OF_MEASURE,
              rt.PARENT_TRANSACTION_ID,rt.PO_LINE_LOCATION_ID,
              rt.PROJECT_ID, rt.TASK_ID, rt.OE_ORDER_LINE_ID, null, null, rst.status
       FROM   rcv_transactions  rt, rcv_staging_table rst
       WHERE  rst.transaction_id = rt.transaction_id
        AND   rst.transaction_group_id = p_group_id
        AND   rst.team = g_team_name
	AND  EXISTS(
                SELECT        1
	        FROM          jmf_subcontract_orders jso
	        WHERE         rt.SOURCE_DOCUMENT_CODE = 'PO'
	        AND           jso.SUBCONTRACT_PO_SHIPMENT_ID = rt.PO_LINE_LOCATION_ID
	        UNION
		SELECT 	      1
		FROM          OE_ORDER_LINES_ALL OOLA , JMF_SHIKYU_REPLENISHMENTS JSR
		WHERE         rt.SOURCE_DOCUMENT_CODE = 'RMA'
		AND           rt.OE_ORDER_LINE_ID = OOLA.LINE_ID
		AND           OOLA.REFERENCE_LINE_ID = JSR.REPLENISHMENT_SO_LINE_ID
		)
	ORDER BY rt.transaction_id;

	CURSOR get_rcv_transactions_case4 IS
       SELECT distinct (rt.TRANSACTION_ID), rt.SOURCE_DOCUMENT_CODE,
              rt.TRANSACTION_TYPE, rt.PRIMARY_QUANTITY, rt.PRIMARY_UNIT_OF_MEASURE,
              rt.PARENT_TRANSACTION_ID,rt.PO_LINE_LOCATION_ID,
              rt.PROJECT_ID, rt.TASK_ID, rt.OE_ORDER_LINE_ID, null, null, rst.status
       FROM   rcv_transactions  rt, rcv_staging_table rst
       WHERE rst.transaction_id = rt.transaction_id
        AND  rst.team = g_team_name
	AND  EXISTS(
                SELECT        1
	        FROM          jmf_subcontract_orders jso
	        WHERE         rt.SOURCE_DOCUMENT_CODE = 'PO'
	        AND           jso.SUBCONTRACT_PO_SHIPMENT_ID = rt.PO_LINE_LOCATION_ID
	        UNION
		SELECT 	      1
		FROM          OE_ORDER_LINES_ALL OOLA , JMF_SHIKYU_REPLENISHMENTS JSR
		WHERE         rt.SOURCE_DOCUMENT_CODE = 'RMA'
		AND           rt.OE_ORDER_LINE_ID = OOLA.LINE_ID
		AND           OOLA.REFERENCE_LINE_ID = JSR.REPLENISHMENT_SO_LINE_ID
		)
	ORDER BY rt.transaction_id;

   /* note: the cursor purposely does not distinguish between PENDING and ERROR rows so that the user can fix a problem and then rerun this process and attempt again to process this row */

   BEGIN
      Init;
      IF g_proc_level >= g_debug_level
      THEN
       FND_LOG.string(g_proc_level
                  , G_MODULE_PREFIX || l_api_name || '.begin'
                  , NULL);
      END IF;

      -- Start API initialization
      IF FND_API.to_boolean(NVL(p_init_msg_list, FND_API.G_FALSE)) THEN
       FND_MSG_PUB.initialize;
      END IF;

      IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      /* vmutyala changed the following initialization for Bug 4670527 */

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- End API initialization

      -- collect relevant records from rcv_transactions in table data type.

      IF p_request_id is NOT NULL and p_group_id is NOT NULL then
      OPEN get_rcv_transactions_case1;
      FETCH get_rcv_transactions_case1 BULK COLLECT INTO l_rcv_pending_trx_tbl;
      CLOSE get_rcv_transactions_case1;

      ELSIF p_request_id is NOT NULL  then
      OPEN get_rcv_transactions_case2;
      FETCH get_rcv_transactions_case2 BULK COLLECT INTO l_rcv_pending_trx_tbl;
      CLOSE get_rcv_transactions_case2;

      ELSIF p_group_id is NOT NULL  then
      OPEN get_rcv_transactions_case3;
      FETCH get_rcv_transactions_case3 BULK COLLECT INTO l_rcv_pending_trx_tbl;
      CLOSE get_rcv_transactions_case3;

      ELSE
      OPEN get_rcv_transactions_case4;
      FETCH get_rcv_transactions_case4 BULK COLLECT INTO l_rcv_pending_trx_tbl;
      CLOSE get_rcv_transactions_case4;

      END IF;


      IF g_statement_level >= g_debug_level THEN
      FND_LOG.string(g_statement_level
                  , G_MODULE_PREFIX || l_api_name
                  , 'Read transaction records successfully. Start clubbing Correction records.');
      END IF;
      -- Process all records from staging table corresponding to team JMF
      FOR i IN 1 .. l_rcv_pending_trx_tbl.COUNT LOOP
            -- Get primary UOM code.
            select UOM_CODE
            into l_primary_uom_code
            from MTL_UNITS_OF_MEASURE_VL
            where UNIT_OF_MEASURE = l_rcv_pending_trx_tbl(i).primary_unit_of_measure;

            IF ( l_rcv_pending_trx_tbl(i).transaction_type = 'RECEIVE' OR
                 l_rcv_pending_trx_tbl(i).transaction_type = 'DELIVER' OR
                 l_rcv_pending_trx_tbl(i).transaction_type = 'RETURN TO VENDOR') THEN

             -- Clubbing is not required if it is Receive or Return transaction.
             l_rcv_pending_clubbed_trx_tbl(l_rcv_pending_clubbed_trx_tbl.COUNT+1) :=
               l_rcv_pending_trx_tbl(i);

            ELSIF l_rcv_pending_trx_tbl(i).transaction_type = 'CORRECT' THEN
             l_exists := FALSE;
             -- Clubbing is required if it is Correction transaction.
             FOR k IN 1 .. l_rcv_pending_clubbed_trx_tbl.COUNT LOOP
                IF (l_rcv_pending_clubbed_trx_tbl(k).transaction_id =
                  l_rcv_pending_trx_tbl(i).parent_transaction_id AND
                  l_rcv_pending_clubbed_trx_tbl(k).po_line_location_id =
                  l_rcv_pending_trx_tbl(i).po_line_location_id) THEN

                 l_exists := TRUE;
                 -- Note the transactionId with which it is clubbed to maintain
                 -- proper status in staging table.
                 l_rcv_pending_trx_tbl(i).clubbed_transaction_id :=
                    l_rcv_pending_clubbed_trx_tbl(k).transaction_id;

                 l_parent_transaction_type := l_rcv_pending_clubbed_trx_tbl(k).transaction_type;
                 l_net_Quantity :=
                  l_rcv_pending_clubbed_trx_tbl(k).primary_quantity +
                  l_rcv_pending_trx_tbl(i).primary_quantity;

                 -- If net quantity is less than 0 then clubbed transaction will be a
                 -- negative correction.
                 IF l_net_Quantity < 0 THEN
                  l_rcv_pending_clubbed_trx_tbl(k) := l_rcv_pending_trx_tbl(i);
                 END IF;
                 l_rcv_pending_clubbed_trx_tbl(k).primary_quantity := l_net_Quantity;


                 -- Find process_type based on parent transaction type.
                 IF l_rcv_pending_clubbed_trx_tbl(k).transaction_type = 'CORRECT' THEN
                  IF l_parent_transaction_type = 'RECEIVE' OR
                     l_parent_transaction_type = 'DELIVER' THEN
                    l_rcv_pending_clubbed_trx_tbl(k).process_type := 'RECEIPT' ;
                  ELSIF l_parent_transaction_type = 'RETURN TO VENDOR' THEN
                    l_rcv_pending_clubbed_trx_tbl(k).process_type := 'RETURN';
                  END IF;
                 END IF; -- IF l_rcv_pending_clubbed_trx_tbl(k).transaction_type = 'CORRECT' THEN
                END IF; -- IF (l_rcv_pending_clubbed_trx_tbl(k).transaction_id =
               END LOOP; -- FOR k IN 1 .. l_rcv_pending_clubbed_trx_tbl.COUNT LOOP

               -- If clubbing is not done then add correction transaction to clubbed
               -- transaction list.
	       /* vmutyala modified the following code. Previously independent correction transactions whose
	       parent transactions are deleted from the staging table because of a successful run were inserted
	       into clubbed transactions but not processed later neither in osa receipt nor in return
	       because of conditions in if statements. The condition is that if transaction type is 'CORRECT'
	       and process type is one of 'RECEIPT' or 'RETURN' then process the transaction. Process type of
	       the above mentioned transactions was not being set in the commented code. Bug 4670527 */


	       IF NOT l_exists THEN
                l_rcv_pending_clubbed_trx_tbl(l_rcv_pending_clubbed_trx_tbl.COUNT+1) :=
                  l_rcv_pending_trx_tbl(i);
                select transaction_type
		into l_parent_transaction_type
		from rcv_transactions
		where transaction_id =
		   (select PARENT_TRANSACTION_ID
		     from rcv_transactions
		     where transaction_id = l_rcv_pending_trx_tbl(i).transaction_id);

	       /*vmutyala added the following code.
	        For independent correction transactions to set the process type depending on parent transaction type
	        Bug 4670527*/

		IF (l_parent_transaction_type = 'RECEIVE' OR l_parent_transaction_type = 'DELIVER') THEN
		      l_rcv_pending_clubbed_trx_tbl(l_rcv_pending_clubbed_trx_tbl.COUNT).process_type :=
		                     'RECEIPT';
	        ELSIF (l_parent_transaction_type = 'RETURN TO VENDOR') THEN
                      l_rcv_pending_clubbed_trx_tbl(l_rcv_pending_clubbed_trx_tbl.COUNT).process_type :=
			      'RETURN';
	        END IF; -- IF (l_parent_transaction_type = 'RECEIVE'
              END IF; -- IF NOT l_exists

              END IF; -- IF ( l_rcv_pending_trx_tbl(i).transaction_type = 'RECEIVE' OR


        END LOOP; -- FOR i IN 1 .. l_rcv_pending_trx_tbl.COUNT LOOP

        IF g_statement_level >= g_debug_level THEN
        FND_LOG.string(g_statement_level
                  , G_MODULE_PREFIX || l_api_name
                  , 'Clubbed Correction records successfully.');
        END IF;

        -- process clubbed transactions based on transaction_type.
        FOR i IN 1 .. l_rcv_pending_clubbed_trx_tbl.COUNT LOOP
         BEGIN
	  IF l_rcv_pending_clubbed_trx_tbl(i).primary_quantity = 0 THEN
           x_return_status := fnd_api.g_ret_sts_success;
	  ELSIF l_rcv_pending_clubbed_trx_tbl(i).source_document_code = 'PO' THEN
            IF (l_rcv_pending_clubbed_trx_tbl(i).transaction_type = 'RECEIVE' OR
                l_rcv_pending_clubbed_trx_tbl(i).transaction_type = 'DELIVER' OR
               (l_rcv_pending_clubbed_trx_tbl(i).transaction_type = 'CORRECT' AND
                l_rcv_pending_clubbed_trx_tbl(i).process_type = 'RECEIPT' )) THEN

             IF g_statement_level >= g_debug_level THEN
             FND_LOG.string(g_statement_level
                  , G_MODULE_PREFIX || l_api_name
                  , 'Perform OSA Receipt for transaction : '||
                  l_rcv_pending_clubbed_trx_tbl(i).transaction_id);
             END IF;

	     -- Call OSA Receipt API
	     JMF_PROCESS_SHIKYU_RCV_TRX_PVT.Process_Osa_Receipt(
                 p_api_version => 1.0
               , p_init_msg_list => p_init_msg_list
	       , x_return_status => x_return_status
	       , x_msg_count => l_msg_count
	       , x_msg_data => l_msg_data
	       , p_po_shipment_id =>l_rcv_pending_clubbed_trx_tbl(i).po_line_location_id
	       , p_quantity => l_rcv_pending_clubbed_trx_tbl(i).primary_quantity
	       , p_uom => l_primary_uom_code
	       , p_transaction_type => l_rcv_pending_clubbed_trx_tbl(i).transaction_type
	       , p_project_id => l_rcv_pending_clubbed_trx_tbl(i).project_id
	       , p_task_id => l_rcv_pending_clubbed_trx_tbl(i).task_id
	       , p_status =>  l_rcv_pending_clubbed_trx_tbl(i).error_status
	       );
	    ELSIF (l_rcv_pending_clubbed_trx_tbl(i).transaction_type = 'RETURN TO VENDOR' OR
	          (l_rcv_pending_clubbed_trx_tbl(i).transaction_type = 'CORRECT' AND
	           l_rcv_pending_clubbed_trx_tbl(i).process_type = 'RETURN')) THEN

             IF g_statement_level >= g_debug_level THEN
             FND_LOG.string(g_statement_level
                  , G_MODULE_PREFIX || l_api_name
                  , 'Perform OSA Return for transaction : '||
                  l_rcv_pending_clubbed_trx_tbl(i).transaction_id);
             END IF;

	     -- Call OSA Return API
	     JMF_PROCESS_SHIKYU_RCV_TRX_PVT.Process_Osa_Return(
                 p_api_version => 1.0
               , p_init_msg_list => p_init_msg_list
	       , x_return_status => x_return_status
	       , x_msg_count => l_msg_count
	       , x_msg_data => l_msg_data
	       , p_po_shipment_id =>l_rcv_pending_clubbed_trx_tbl(i).po_line_location_id
	       , p_quantity => l_rcv_pending_clubbed_trx_tbl(i).primary_quantity
	       , p_uom => l_primary_uom_code
	       , p_transaction_type => l_rcv_pending_clubbed_trx_tbl(i).transaction_type
	       , p_project_id => l_rcv_pending_clubbed_trx_tbl(i).project_id
	       , p_task_id => l_rcv_pending_clubbed_trx_tbl(i).task_id
	       , p_status =>  l_rcv_pending_clubbed_trx_tbl(i).error_status
	       );
	    END IF;
	  ELSIF l_rcv_pending_clubbed_trx_tbl(i).source_document_code = 'RMA' THEN
	    IF (l_rcv_pending_clubbed_trx_tbl(i).transaction_type = 'RECEIVE' OR
	        l_rcv_pending_clubbed_trx_tbl(i).transaction_type = 'DELIVER') THEN

             IF g_statement_level >= g_debug_level THEN
             FND_LOG.string(g_statement_level
                  , G_MODULE_PREFIX || l_api_name
                  , 'Perform SHIKYU RTV for transaction : '||
                  l_rcv_pending_clubbed_trx_tbl(i).transaction_id);
             END IF;

	     -- Call Component Return API
             JMF_PROCESS_SHIKYU_RCV_TRX_PVT.Process_Component_Return(
                 p_api_version => 1.0
               , p_init_msg_list => p_init_msg_list
	       , x_return_status => x_return_status
	       , x_msg_count => l_msg_count
	       , x_msg_data => l_msg_data
               , p_rma_line_id => l_rcv_pending_clubbed_trx_tbl(i).oe_order_line_id
	       , p_quantity => l_rcv_pending_clubbed_trx_tbl(i).primary_quantity
	       , p_uom => l_primary_uom_code
	       , p_status =>  l_rcv_pending_clubbed_trx_tbl(i).error_status
	       );
            END IF;

             -- Since corrections or Return against SHIKYU RMA are not supported
             -- so other transaction types are not included

          END IF; -- IF l_rcv_pending_clubbed_trx_tbl.quantity = 0 THEN

          -- If return status is not successful then add transaction in error
          -- transaction list.
	  /*vmutyala changed the following code to make a note of the transactions which are successful along with the erroneous ones Bug 4670527*/

	 IF (x_return_status = fnd_api.g_ret_sts_success) THEN
	     rcv_success_trx_ids(rcv_success_trx_ids.COUNT + 1) :=
                      	     l_rcv_pending_clubbed_trx_tbl(i).transaction_id;
          ELSE
	      rcv_error_trx_ids(rcv_error_trx_ids.COUNT + 1)  := i;
	     IF l_rcv_pending_clubbed_trx_tbl(i).error_status = 'PENDING' THEN
	        l_rcv_pending_clubbed_trx_tbl(i).error_status := 'ERROR';
	      END IF;
          -- log error message here if so desired
          END IF;

         EXCEPTION
          WHEN OTHERS THEN
            rcv_error_trx_ids(rcv_error_trx_ids.COUNT + 1)  := i;

         END;
        END LOOP; -- FOR i IN 1 .. l_rcv_pending_clubbed_trx_tbl.COUNT LOOP

      -- If even a single transaction fails then return status should be Error.
      IF (rcv_error_trx_ids.COUNT > 0) THEN
         x_return_status  := fnd_api.g_ret_sts_error;
      ELSE
         x_return_status  := fnd_api.g_ret_sts_success;
      END IF;

      -- Find related failed records in case of clubbing.
      IF (rcv_error_trx_ids.COUNT > 0) THEN
       FOR i IN 1 .. l_rcv_pending_trx_tbl.COUNT LOOP
        IF (l_rcv_pending_trx_tbl(i).clubbed_transaction_id IS NOT NULL) THEN
         FOR k IN 1 .. rcv_error_trx_ids.COUNT LOOP
          IF (l_rcv_pending_clubbed_trx_tbl(rcv_error_trx_ids(k)).transaction_id = l_rcv_pending_trx_tbl(i).transaction_id) THEN
            UPDATE rcv_staging_table
            SET status = 'CL_ERROR'
	     , LAST_UPDATE_DATE = sysdate
	     , LAST_UPDATED_BY = FND_GLOBAL.user_id
	     , LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
            WHERE transaction_id = l_rcv_pending_trx_tbl(i).clubbed_transaction_id
            AND team = g_team_name;
          ELSIF (l_rcv_pending_clubbed_trx_tbl(rcv_error_trx_ids(k)).transaction_id = l_rcv_pending_trx_tbl(i).clubbed_transaction_id) THEN
	    UPDATE rcv_staging_table
            SET status = 'CL_ERROR'
	     , LAST_UPDATE_DATE = sysdate
	     , LAST_UPDATED_BY = FND_GLOBAL.user_id
	     , LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
            WHERE transaction_id = l_rcv_pending_trx_tbl(i).transaction_id
            AND team = g_team_name;
          END IF;
         END LOOP; -- FORALL k IN 1 .. rcv_error_trx_ids.COUNT LOOP
        END IF;  -- IF (l_rcv_pending_trx_tbl(k).clubbed_transaction_id) IS NOT NULL) THEN
       END LOOP;  -- FOR i IN 1 .. l_rcv_pending_trx_tbl.COUNT LOOP
      END IF; -- IF (rcv_error_trx_ids.COUNT > 0) THEN

      /* vmutyala added the following code to find related success records in case of clubbing Bug 4670527*/
      -- Find related success records in case of clubbing.
       IF (rcv_success_trx_ids.COUNT > 0) THEN
       FOR i IN 1 .. l_rcv_pending_trx_tbl.COUNT LOOP
        IF (l_rcv_pending_trx_tbl(i).clubbed_transaction_id IS NOT NULL) THEN
         FOR k IN 1 .. rcv_success_trx_ids.COUNT LOOP
          IF (rcv_success_trx_ids(k) = l_rcv_pending_trx_tbl(i).transaction_id) THEN
           rcv_success_trx_ids(rcv_success_trx_ids.COUNT + 1)
            := l_rcv_pending_trx_tbl(i).clubbed_transaction_id;
          ELSIF (rcv_success_trx_ids(k) = l_rcv_pending_trx_tbl(i).clubbed_transaction_id) THEN
           rcv_success_trx_ids(rcv_success_trx_ids.COUNT + 1)
            := l_rcv_pending_trx_tbl(i).transaction_id;
          END IF;
         END LOOP; -- FORALL k IN 1 .. rcv_success_trx_ids.COUNT LOOP
        END IF;  -- IF (l_rcv_pending_trx_tbl(k).clubbed_transaction_id) IS NOT NULL) THEN
       END LOOP;  -- FOR i IN 1 .. l_rcv_pending_trx_tbl.COUNT LOOP
      END IF; -- IF (rcv_success_trx_ids.COUNT > 0) THEN

      -- Update status in staging table.
       FOR i IN 1 .. rcv_error_trx_ids.COUNT LOOP
       l_error_trx_index := rcv_error_trx_ids(i);
         UPDATE rcv_staging_table
            SET status = l_rcv_pending_clubbed_trx_tbl(l_error_trx_index).error_status
	     , LAST_UPDATE_DATE = sysdate
	     , LAST_UPDATED_BY = FND_GLOBAL.user_id
	     , LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
            WHERE transaction_id = l_rcv_pending_clubbed_trx_tbl(l_error_trx_index).transaction_id
            AND team = g_team_name;
       END LOOP;
      /* vmutyala changed the following code to delete successful records which might have failed in previous attempts Bug 4670527*/
      -- Delete successful transactions from staging table.


       FORALL i IN 1 .. rcv_success_trx_ids.COUNT
         DELETE rcv_staging_table
            WHERE transaction_id = rcv_success_trx_ids(i)
            AND team = g_team_name;

	/* vmutyala added the following query to delete the 'PO' records which are not processed and whose supplier org is not a trading partner org
           Bug 4670527 */
        delete rcv_staging_table
	where transaction_id IN
		(select distinct(rst.transaction_id)
		from hr_organization_information hoi, rcv_transactions rt, rcv_staging_table rst, mtl_parameters mp
		where rt.SOURCE_DOCUMENT_CODE = 'PO'
		and hoi.ORG_INFORMATION_CONTEXT = 'Customer/Supplier Association'
		and hoi.ORG_INFORMATION3 = to_char(rt.vendor_id)
		and hoi.ORG_INFORMATION4 = to_char(rt.vendor_site_id)
		and rt.transaction_id = rst.transaction_id
		and hoi.organization_id = mp.organization_id
		and (mp.trading_partner_org_flag is NULL OR mp.trading_partner_org_flag  = 'N')
		and rst.status = 'PENDING'
		and rst.team = g_team_name);
	/* vmutyala added the following query to delete the 'RMA' records which are not processed and
	   a corresponding return reference id doesn't exist in OE_ORDER_LINES_ALL or even if it exists, a corresponding
	   replenishent so line id doesn't exist in JMF_SHIKYU_REPLENISHMENTS.
           Bug 4670527 */
	delete rcv_staging_table
	where transaction_id IN
		(select distinct(rst.transaction_id)
		from OE_ORDER_LINES_ALL OOLA, rcv_transactions rt, rcv_staging_table rst
		where rt.SOURCE_DOCUMENT_CODE = 'RMA'
		and rt.OE_ORDER_LINE_ID = OOLA.LINE_ID
		and (OOLA.REFERENCE_LINE_ID is NULL OR NOT EXISTS (select 1 from JMF_SHIKYU_REPLENISHMENTS
								    where REPLENISHMENT_SO_LINE_ID=
								    OOLA.REFERENCE_LINE_ID))
		and rt.transaction_id = rst.transaction_id
		and rst.status = 'PENDING'
		and rst.team = g_team_name);

   IF g_proc_level >= g_debug_level THEN
    FND_LOG.string(g_proc_level
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , NULL);
   END IF;

   EXCEPTION
      WHEN OTHERS THEN
         x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
END Process_Shikyu_Rcv_trx;


--========================================================================
-- PROCEDURE : Process_Osa_Receipt	PUBLIC
-- PARAMETERS: p_api_version  	IN Standard in parameter API version
--             p_init_msg_list 	IN Standard in parameter message list
--             x_return_status      OUT Stadard out parameter for return status
--                                     (Values E(Error), S(Success), U(Unexpected error))
--             x_msg_count          OUT Stadard out parameter for number of messages
--             x_msg_data           OUT Stadard out parameter for message
--             p_po_shipment_id     IN Subcontracting PO shipment
--             p_quantity           IN Received quantity
--             p_uom                IN UOM of received quantity
--             p_transaction_type   IN Transaction Type
--	       p_project_id	    IN Project reference
--	       p_task_id	    IN Task reference
-- COMMENT   : This procedure is called after receipt of Outsourced Assembly
--             Item to perform WIP completion and Misc issue at Manufacturing
--             Partner organization. It does allocations if required.
--Following is logic:
--1. For receipts and positive corrections
--   Validate if all shikyu components are fully allocated and raise exception if not
--2. If Transaction Type is 'CORRECT'
--   If quantity positive then it is positive correction
--    Perform WIP Completion and back flush
--    Perform Misc Issue
--   If quantity is negative then it is negative correction.
--    Perform WIP Assembly Return and reverse back flush
--    Perform Misc Recceipt
--3. If Transaction Type is 'RECEIVE' or 'DELIVER'
--    Perform WIP Completion and back flush
--    Perform Misc Issue
--4. Update Interlock_status in JMF_SUBCONTRACT_ORDERS with either 'C' or 'E'
--   in case of success or error respectively.
--========================================================================
PROCEDURE Process_Osa_Receipt
( p_api_version             IN  NUMBER
, p_init_msg_list           IN  VARCHAR2
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_po_shipment_id          IN  NUMBER
, p_quantity                IN  NUMBER
, p_uom                     IN VARCHAR2
, p_transaction_type        IN VARCHAR2
, p_project_id		    IN NUMBER
, p_task_id	            IN NUMBER
, p_status		    IN OUT NOCOPY VARCHAR2
)
IS

l_api_name       CONSTANT VARCHAR2(30) := 'Process_Osa_Receipt';
l_api_version    CONSTANT NUMBER       := 1.0;


l_osa_item_primary_uom           VARCHAR2(3);
l_rcv_uom                        MTL_UNITS_OF_MEASURE_VL.UOM_CODE%Type;
l_osa_primary_uom_receipt_qty    NUMBER;

l_osa_item_id                    NUMBER;
l_return_flag NUMBER;

-- custom exceptions
l_not_enough_replen_excep        EXCEPTION;
l_not_allocated_completely       EXCEPTION;



BEGIN
  Init;
  IF g_proc_level >= g_debug_level
  THEN
    FND_LOG.string(g_proc_level
                  , G_MODULE_PREFIX || l_api_name || '.begin'
                  , NULL);
  END IF;

  -- Start API initialization
  IF FND_API.to_boolean(NVL(p_init_msg_list, FND_API.G_FALSE)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;

  -- End API initialization

  -- These conversions to primary UOM are done in caller program to avoid same in
  -- called programs like Misc Issue/Return or WIP Completion/Return .

  -- Get primary UOM of OSA item.
  select JSO.OSA_ITEM_ID, JMF_SHIKYU_UTIL.Get_Primary_Uom_Code(JSO.OSA_ITEM_ID, JSO.OEM_ORGANIZATION_ID)
  into l_osa_item_id, l_osa_item_primary_uom
  from JMF_SUBCONTRACT_ORDERS JSO
  where JSO.SUBCONTRACT_PO_SHIPMENT_ID = p_po_shipment_id;

  -- Convert received quantity into primary UOM
  IF (l_osa_item_primary_uom  <> p_uom) THEN
   l_osa_primary_uom_receipt_qty := INV_CONVERT.inv_um_convert
                          ( item_id             => l_osa_item_id
                          , precision           => 5
                          , from_quantity       => p_quantity
                          , from_unit           => p_uom
                          , to_unit             => l_osa_item_primary_uom
                          , from_name           => null
                          , to_name             => null
                          );
  ELSE
   l_osa_primary_uom_receipt_qty := p_quantity;
  END IF;


  -- Call Allocation steps only for OSA Receipt and its positive corrections.
  IF p_quantity > 0 THEN
    Validate_And_Allocate( p_init_msg_list   => p_init_msg_list
			, x_return_status   => x_return_status
			, x_msg_count       => x_msg_count
			, x_msg_data        => x_msg_data
			, x_return_flag     => l_return_flag
			, p_po_shipment_id  => p_po_shipment_id
			, p_project_id	    => p_project_id
			, p_task_id	    => p_task_id
			);
   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
       IF l_return_flag = 0 THEN
           raise FND_API.G_EXC_ERROR;
           ELSIF l_return_flag = 1 THEN
             raise l_not_enough_replen_excep;
           ELSE
             raise l_not_allocated_completely;
       END IF; --IF l_return_flag = 0 THEN
   END IF; -- IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

  END IF; -- IF p_quantity > 0 THEN

  /* ERROR status means that the program has failed in the previous run before or in Validate and allocate. If the issue
  is resolved the program control reaches this point so unless we revert the status, the corresponding operations will not be
  performed and the record from the staging table will be removed since return status is success. Reverting status will make sure
  that the corresponding operations are performed */

  IF p_status = 'ERROR' THEN
     p_status := 'PENDING';
  END IF;

  -- Perform WIP Completion/Return and Misc Issue/Receipt based on transaction type.
  IF p_transaction_type = 'CORRECT' THEN
   -- If correction is positive
   IF p_quantity > 0 THEN
    IF p_status = 'PENDING' OR p_status = 'WC_ERROR' THEN
    JMF_SHIKYU_INV_PVT.Process_WIP_Completion(p_subcontract_po_shipment_id => p_po_shipment_id
                                            , p_osa_quantity => l_osa_primary_uom_receipt_qty
                                            , p_uom => l_osa_item_primary_uom
                                            , x_return_status => x_return_status);
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     p_status := 'WC_ERROR';
     ELSE
     p_status := 'PENDING';              --so that next operation can be performed.
    END IF;
    END IF;
    IF p_status = 'PENDING' OR p_status = 'MI_ERROR' THEN
     JMF_SHIKYU_INV_PVT.Process_Misc_Issue(p_subcontract_po_shipment_id => p_po_shipment_id
                                         , p_osa_quantity => l_osa_primary_uom_receipt_qty
                                         , p_uom => l_osa_item_primary_uom
                                         , x_return_status => x_return_status);
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     p_status := 'MI_ERROR';
    END IF;
    END IF;

   -- If correction is negative
   ELSIF p_quantity < 0 THEN
    IF p_status = 'PENDING' OR p_status = 'MR_ERROR' THEN
     JMF_SHIKYU_INV_PVT.Process_Misc_rcpt(p_subcontract_po_shipment_id => p_po_shipment_id
                                        , p_osa_quantity => ABS(l_osa_primary_uom_receipt_qty)
                                        , p_uom => l_osa_item_primary_uom
                                        , x_return_status => x_return_status);
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     p_status := 'MR_ERROR';
    ELSE
     p_status := 'PENDING';               --so that next operation can be performed.
    END IF;
    END IF;
    IF p_status = 'PENDING' OR p_status = 'AR_ERROR' THEN
    JMF_SHIKYU_INV_PVT.Process_WIP_Assy_Return(p_subcontract_po_shipment_id => p_po_shipment_id
                                             , p_osa_quantity => ABS(l_osa_primary_uom_receipt_qty)
                                             , p_uom => l_osa_item_primary_uom
                                             , x_return_status => x_return_status);
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     p_status := 'AR_ERROR';
    END IF;
    END IF;
   END IF; -- IF p_quantity > 0 THEN

  -- If it is normal OSA receipt
  ELSE
  IF p_status = 'PENDING' OR p_status = 'WC_ERROR' THEN
   JMF_SHIKYU_INV_PVT.Process_WIP_Completion(p_subcontract_po_shipment_id => p_po_shipment_id
                                           , p_osa_quantity => l_osa_primary_uom_receipt_qty
                                           , p_uom => l_osa_item_primary_uom
                                           , x_return_status => x_return_status);
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     p_status := 'WC_ERROR';
    ELSE
     p_status := 'PENDING';                 --so that next operation can be performed.
    END IF;
    END IF;
    IF p_status = 'PENDING' OR p_status = 'MI_ERROR' THEN
    JMF_SHIKYU_INV_PVT.Process_Misc_Issue(p_subcontract_po_shipment_id => p_po_shipment_id
                                        , p_osa_quantity => l_osa_primary_uom_receipt_qty
                                        , p_uom => l_osa_item_primary_uom
                                        , x_return_status => x_return_status);
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     p_status := 'MI_ERROR';
    END IF;
   END IF;
  END IF; -- IF p_transaction_type = 'CORRECT' THEN

  -- If any of the above activity is unsuccessful then throw exception
  -- so that interlock SHIKYU status can be updated with Error.
  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
    raise FND_API.G_EXC_ERROR;
  END IF;

 -- Update Interlock Shikyu status as Completed in JMF_SUBCONTRACT_ORDERS
  UPDATE JMF_SUBCONTRACT_ORDERS SET interlock_status = 'C'
         , LAST_UPDATE_DATE = sysdate
	 , LAST_UPDATED_BY = FND_GLOBAL.user_id
	 , LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
  WHERE SUBCONTRACT_PO_SHIPMENT_ID = p_po_shipment_id;

--  AND NVL(project_id, -1)= NVL(p_project_id, -1)
--  AND NVL(task_id, -1)= NVL(p_task_id, -1);


  IF g_proc_level >= g_debug_level
  THEN
    FND_LOG.string(g_proc_level
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , NULL);
  END IF;

EXCEPTION
  WHEN l_not_enough_replen_excep THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );
    x_return_status := FND_API.G_RET_STS_ERROR;


    IF g_excep_level >= g_debug_level
    THEN
      FND_LOG.string(g_excep_level
                    , G_MODULE_PREFIX || l_api_name
                    , 'Exception - Subcontract Purchase Order Shipment: ' || p_po_shipment_id ||
                    ' - Not found enough Replenishment Sales Orders');
    END IF;
  WHEN l_not_allocated_completely THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );
    x_return_status := FND_API.G_RET_STS_ERROR;


    IF g_excep_level >= g_debug_level
    THEN
      FND_LOG.string(g_excep_level
                    , G_MODULE_PREFIX || l_api_name
                    , 'Exception - Subcontract Purchase Order Shipment: ' || p_po_shipment_id ||
                    ' - Could not allocate all received quantities.');
    END IF;
  WHEN NO_DATA_FOUND THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );

    x_return_status := FND_API.G_RET_STS_ERROR;



    IF g_excep_level >= g_debug_level
    THEN
      FND_LOG.string(g_excep_level
                    , G_MODULE_PREFIX || l_api_name || '.No Date Found'
                    , 'Exception - Subcontract Purchase Order Shipment: ' || p_po_shipment_id);
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


    IF g_unexp_level >= g_debug_level
    THEN
      FND_LOG.string(g_unexp_level
                    , G_MODULE_PREFIX || l_api_name || '.unexpected_exception'
                    , 'Exception');
    END IF;
  WHEN FND_API.G_EXC_ERROR THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );

    x_return_status := FND_API.G_RET_STS_ERROR;


    IF g_unexp_level >= g_debug_level
    THEN
      FND_LOG.string(g_unexp_level
                    , G_MODULE_PREFIX || l_api_name || '.Exception'
                    , 'Exception');
    END IF;
  WHEN OTHERS THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF g_unexp_level >= g_debug_level
    THEN
      FND_LOG.string(g_unexp_level
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , 'Exception');
    END IF;

END Process_Osa_Receipt;


--========================================================================
-- PROCEDURE : Process_Osa_Return	PUBLIC
-- PARAMETERS: p_api_version  	    IN Standard in parameter API version
--             p_init_msg_list 	    IN Standard in parameter message list
--             x_return_status      OUT Stadard out parameter for return status
--                                     (Values E(Error), S(Success), U(Unexpected error))
--             x_msg_count          OUT Stadard out parameter for number of messages
--             x_msg_data           OUT Stadard out parameter for message
--             p_po_shipment_id     IN Subcontracting PO shipment
--             p_quantity           IN Received quantity
--             p_uom                IN UOM of received quantity
--             p_transaction_type   IN Transaction Type
--	       p_project_id	    IN Project reference
--	       p_task_id	    IN Task reference
-- COMMENT   : This procedure is called after return of Outsourced Assembly
--             Item to Supplier to perform WIP assembly return and Misc receipt at
--             Manufacturing Partner organization.
--  Following is logic:
--  1. If Transaction Type is 'CORRECT'
--     If quantity positive then it is positive correction
--      Perform WIP Assembly Return and reverse back flush
--      Perform Misc Recceipt
--     If quantity is negative then it is negative correction.
--      validate if the shikyu components are fully allocated
--      and allocate if needed and raise exception if unable to allocate.
--      Perform WIP Completion and back flush
--      Perform Misc Issue
--  2.If Transaction Type 'RETRUN TO VENDOR'
--      Perform WIP Assembly Return and reverse back flush
--      Perform Misc Recceipt
--========================================================================
PROCEDURE Process_Osa_Return
( p_api_version             IN  NUMBER
, p_init_msg_list           IN  VARCHAR2
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_po_shipment_id          IN  NUMBER
, p_quantity                IN  NUMBER
, p_uom                     IN VARCHAR2
, p_transaction_type        IN VARCHAR2
, p_project_id		    IN NUMBER
, p_task_id		    IN NUMBER
, p_status		    IN OUT NOCOPY VARCHAR2
)

IS

l_api_name       CONSTANT VARCHAR2(30) := 'Process_Osa_Return';
l_api_version    CONSTANT NUMBER       := 1.0;

BEGIN
  Init;
  IF g_proc_level >= g_debug_level
  THEN
    FND_LOG.string(g_proc_level
                  , G_MODULE_PREFIX || l_api_name || '.begin'
                  , NULL);
  END IF;

  -- Start API initialization
  IF FND_API.to_boolean(NVL(p_init_msg_list, FND_API.G_FALSE)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;

  -- End API initialization

  -- Perform WIP Completion/Return and Misc Issue/Receipt based on transaction type.
  IF p_transaction_type = 'CORRECT' THEN

   -- If correction is positive
   IF p_quantity > 0 THEN
    IF p_status = 'PENDING' OR p_status = 'MR_ERROR' THEN
     JMF_SHIKYU_INV_PVT.Process_Misc_rcpt(p_subcontract_po_shipment_id => p_po_shipment_id
                                        , p_osa_quantity => p_quantity
                                        , p_uom => p_uom
                                        , x_return_status => x_return_status);
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     p_status := 'MR_ERROR';
      ELSE
     p_status := 'PENDING';           --so that next operation can be performed.
    END IF;
    END IF;
    IF p_status = 'PENDING' OR p_status = 'AR_ERROR' THEN
    JMF_SHIKYU_INV_PVT.Process_WIP_Assy_Return(p_subcontract_po_shipment_id => p_po_shipment_id
                                             , p_osa_quantity => p_quantity
                                             , p_uom => p_uom
                                             , x_return_status => x_return_status);
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     p_status := 'AR_ERROR';
    END IF;
    END IF;

   -- If correction is negative
   ELSIF p_quantity < 0 THEN
    IF p_status = 'PENDING' OR p_status = 'WC_ERROR' THEN
    JMF_SHIKYU_INV_PVT.Process_WIP_Completion(p_subcontract_po_shipment_id => p_po_shipment_id
                                            , p_osa_quantity => ABS(p_quantity)
                                            , p_uom => p_uom
                                            , x_return_status => x_return_status);
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     p_status := 'WC_ERROR';
     ELSE
     p_status := 'PENDING';           --so that next operation can be performed.
    END IF;
    END IF;
    IF p_status = 'PENDING' OR p_status = 'MI_ERROR' THEN
     JMF_SHIKYU_INV_PVT.Process_Misc_Issue(p_subcontract_po_shipment_id => p_po_shipment_id
                                         , p_osa_quantity => ABS(p_quantity)
                                         , p_uom => p_uom
                                         , x_return_status => x_return_status);
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     p_status := 'MI_ERROR';
    END IF;
    END IF;
   END IF; -- IF p_quantity > 0 THEN

  -- If it is normal OSA return
  ELSIF p_transaction_type = 'RETURN TO VENDOR' THEN
   IF p_status = 'PENDING' OR p_status = 'MR_ERROR' THEN
   JMF_SHIKYU_INV_PVT.Process_Misc_rcpt(p_subcontract_po_shipment_id => p_po_shipment_id
                                        , p_osa_quantity => p_quantity
                                        , p_uom => p_uom
                                        , x_return_status => x_return_status);
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     p_status := 'MR_ERROR';
      ELSE
     p_status := 'PENDING';               --so that next operation can be performed.
    END IF;
    END IF;
    IF p_status = 'PENDING' OR p_status = 'AR_ERROR' THEN
   JMF_SHIKYU_INV_PVT.Process_WIP_Assy_Return(p_subcontract_po_shipment_id => p_po_shipment_id
                                             , p_osa_quantity => p_quantity
                                             , p_uom => p_uom
                                             , x_return_status => x_return_status);
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     p_status := 'AR_ERROR';
    END IF;
   END IF;
  END IF; -- IF p_transaction_type = 'CORRECT' THEN

  IF g_proc_level >= g_debug_level
  THEN
    FND_LOG.string(g_proc_level
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , NULL);
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF g_unexp_level >= g_debug_level
    THEN
      FND_LOG.string(g_unexp_level
                    , G_MODULE_PREFIX || l_api_name || '.unexpected_exception'
                    , 'Exception');
    END IF;

  WHEN OTHERS THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF g_unexp_level >= g_debug_level
    THEN
      FND_LOG.string(g_unexp_level
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , 'Exception');
    END IF;

END Process_Osa_Return;

--========================================================================
-- PROCEDURE  : Process_Component_Return	PUBLIC
-- PARAMETERS: p_api_version  		IN Standard in parameter API version
--             p_init_msg_list 		IN Standard in parameter message list
--             x_return_status      	OUT Stadard out parameter for return status
--                                     	 (Values E(Error), S(Success), U(Unexpected error))
--             x_msg_count          	OUT Stadard out parameter for number of messages
--             x_msg_data           	OUT Stadard out parameter for message
--             p_rma_line_id            IN RMA line id
--             p_quantity               IN Received quantity
--             p_uom                    IN UOM of received quantity
-- COMMENT   : This procedure is called after SHIKYU RMA at Subcontracting
--             Organizaiton. It initiates RTV transaction at MP Organization.
--             It also deallocates returned quantities.
--Follwing is logic:
--1. Find all records eligible for SHIKYU RTV at MP site
---2. Perform SHIKYU RTV at MP site
--   A. Enter records into rcv_headers_interface
--   B. Enter records into rcv_transactions_interface
--   C. Submit RVCTP ( Receiving Transaction Processor)
--   D. Wait till concurrent request completes
--   E. Confirm that RTV happened succefully. Received quantity against
--      replenishment PO should be reduced by RTV quantity.
--3. Following logic is part of RTY component return which will be handled
--   by JMF_SHIKYU_ALLOCATION_PVT.Reconcile_Replen_Excess_Qty
--
-- A. Deallocate returned quantity associated with Replenishment SO Line.
--  if SHIKYU RMA is for all quantities(Shipped Qty = Returned Qty for Replenishment SO Line)
--    then delete allocations.
--  if partial quantity is returned then find corresponding Subcontracting PO in LIFO
--    manner based on NeedByDate.
--    then reduce allocation
--  if there are multiple Subcontracting PO with same NeedByDate then pick
--    po no/Line no/Shipment in descending order.
--    then reduce allocation
--
--  B. Reallocate to Subcontracting PO from available replenishments,
--     If allocable replenishment is not present then create a new one and allocate.
--========================================================================
PROCEDURE Process_Component_Return
( p_api_version             IN  NUMBER
, p_init_msg_list           IN  VARCHAR2
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_rma_line_id             IN  NUMBER
, p_quantity                IN  NUMBER
, p_uom                     IN VARCHAR2
, p_status		    IN OUT NOCOPY VARCHAR2
)
IS

l_api_name       CONSTANT VARCHAR2(30) := 'Process_Component_Return';
l_api_version    CONSTANT NUMBER       := 1.0;

l_returned_qty                 NUMBER;
l_replen_po_header_id          NUMBER;
l_replen_po_line_id            NUMBER;
l_replen_po_shipment_id        NUMBER;
l_replen_so_line_id            NUMBER;

l_tp_organization_id          NUMBER;
l_available_quantity           NUMBER;
l_tolerable_quantity           NUMBER;
l_unit_of_measure              MTL_UNITS_OF_MEASURE_TL.UNIT_OF_MEASURE%Type;
l_shikyu_component_id          NUMBER;
l_return_number                NUMBER;
l_group_id                     NUMBER;
l_header_interface_id          NUMBER;
l_allocable_primary_uom_qty    NUMBER;
l_shipped_primary_uom_qty      NUMBER;
l_shikyu_primary_uom           JMF_SHIKYU_REPLENISHMENTS.PRIMARY_UOM%Type;
l_shipped_qty_uom              OE_ORDER_LINES_ALL.ORDER_QUANTITY_UOM%Type;
l_shikyu_unit_of_measure       MTL_UNITS_OF_MEASURE_TL.UNIT_OF_MEASURE%Type;

l_pre_qty_received             NUMBER;
l_post_qty_received            NUMBER;

l_rtv_unsuccessful             EXCEPTION;

l_workers                      JMF_SHIKYU_UTIL.g_request_tbl_type;

l_transaction_type             RCV_TRANSACTIONS.TRANSACTION_TYPE%Type;
l_parent_transaction_id        NUMBER;
l_subinventory                 RCV_TRANSACTIONS.SUBINVENTORY%Type;
l_locator_id                   NUMBER;
l_project_id                   NUMBER;

l_returned_qty_parent_txn_uom  NUMBER;

BEGIN
  Init;
  IF g_proc_level >= g_debug_level
  THEN
    FND_LOG.string(g_proc_level
                  , G_MODULE_PREFIX || l_api_name || '.begin'
                  , NULL);
  END IF;

  -- Start API initialization
  IF FND_API.to_boolean(NVL(p_init_msg_list, FND_API.G_FALSE)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;

  -- End API initialization

  -- get the replenishment SO line id referenced by the rma line

  SELECT  JSR.REPLENISHMENT_SO_LINE_ID
  INTO    l_replen_so_line_id
  FROM    OE_ORDER_LINES_ALL OOLA , JMF_SHIKYU_REPLENISHMENTS JSR
  WHERE   OOLA.LINE_ID = p_rma_line_id
  AND  OOLA.REFERENCE_LINE_ID = JSR.REPLENISHMENT_SO_LINE_ID;


  -- get returned quantity and Replenish PO details against replenishment sales order line
  l_returned_qty := p_quantity;
  l_returned_qty_parent_txn_uom := l_returned_qty;
  select jsr.REPLENISHMENT_PO_HEADER_ID,jsr.REPLENISHMENT_PO_LINE_ID, jsr.REPLENISHMENT_PO_SHIPMENT_ID,
     jsr.SHIKYU_COMPONENT_ID, jsr.TP_ORGANIZATION_ID, jsr.PRIMARY_UOM,
     jsr.ALLOCABLE_PRIMARY_UOM_QUANTITY, oola.SHIPPED_QUANTITY,
     oola.ORDER_QUANTITY_UOM
  into l_replen_po_header_id, l_replen_po_line_id, l_replen_po_shipment_id,
       l_shikyu_component_id, l_tp_organization_id,
       l_shikyu_primary_uom,  l_allocable_primary_uom_qty,
       l_shipped_primary_uom_qty,   l_shipped_qty_uom
  from JMF_SHIKYU_REPLENISHMENTS jsr, OE_ORDER_LINES_ALL oola
  where jsr.REPLENISHMENT_SO_LINE_ID = l_replen_so_line_id
  and jsr.REPLENISHMENT_SO_LINE_ID = oola.line_id;

  -- If there is no return quantity against Replenishment SO then return.
  IF l_returned_qty = 0 THEN
   RETURN;
  END IF;

  -- Perform RTV at MP Organization Replenishment_po_shipment_id

  -- get received quantity against Replenish Purchase Shipment
  select QUANTITY_RECEIVED
  into l_pre_qty_received
  from PO_LINE_LOCATIONS_ALL
  where LINE_LOCATION_ID = l_replen_po_shipment_id;

  -- get UnitOfMeasure from UomCode for Shikyu component
  select UNIT_OF_MEASURE
  into l_shikyu_unit_of_measure
  from MTL_UNITS_OF_MEASURE_VL
  where UOM_CODE = l_shikyu_primary_uom;

  IF p_status <> 'DA_ERROR' THEN

  SELECT  rt.transaction_type, rt.transaction_id, rt.subinventory, rt.locator_id, rt.project_id
  INTO l_transaction_type, l_parent_transaction_id, l_subinventory, l_locator_id, l_project_id
  FROM rcv_transactions rt,
     rcv_shipment_lines rsl
  WHERE rt.organization_id = l_tp_organization_id
     AND rt.po_header_id = l_replen_po_header_id
     AND rt.po_line_id = l_replen_po_line_id
     AND rt.po_line_location_id = l_replen_po_shipment_id
     AND rsl.item_id = l_shikyu_component_id
     AND rt.SOURCE_DOCUMENT_CODE ='PO'
     AND rt.replenish_order_line_id = l_replen_so_line_id
     AND
       (
          (
              RT.TRANSACTION_TYPE IN ('RECEIVE', 'TRANSFER', 'ACCEPT' , 'REJECT', 'MATCH')
              AND EXISTS
              (
               SELECT
                 'POSTIVE RCV SUPPLY'
                  FROM RCV_SUPPLY RS
                  WHERE RS.RCV_TRANSACTION_ID = RT.TRANSACTION_ID
                  AND RS.TO_ORG_PRIMARY_QUANTITY >
                 (
                  SELECT
                    NVL(SUM(RTI.PRIMARY_QUANTITY),0)
                    FROM RCV_TRANSACTIONS_INTERFACE RTI
                  WHERE RTI.PARENT_TRANSACTION_ID = RT.TRANSACTION_ID
                    AND RTI.TRANSACTION_STATUS_CODE = 'PENDING'
                    AND RTI.PROCESSING_STATUS_CODE = 'PENDING'
                 )
              )
           )
         OR
           (
            RT.TRANSACTION_TYPE = 'DELIVER'
            AND RT.SOURCE_DOCUMENT_CODE <> 'RMA'
            )
       )
     AND NOT EXISTS
      (
        SELECT
          'PURCHASE ORDER SHIPMENT CANCELLED OR FC'
        FROM PO_LINE_LOCATIONS_ALL PLL
        WHERE PLL.LINE_LOCATION_ID = RT.PO_LINE_LOCATION_ID
          AND
          (
            NVL(PLL.CANCEL_FLAG,'N') = 'Y'
            OR NVL(PLL.CLOSED_CODE,'OPEN') = 'FINALLY CLOSED'
            OR NVL(PLL.APPROVED_FLAG,'N') <> 'Y'
            OR NVL(PLL.MATCHING_BASIS,'QUANTITY') = 'AMOUNT'
            OR PLL.PAYMENT_TYPE IS NOT NULL
          )
      )
     AND RT.SHIPMENT_LINE_ID = RSL.SHIPMENT_LINE_ID;


   RCV_QUANTITIES_S.get_available_quantity(
     p_transaction_type    => 'RETURN TO VENDOR'
    ,p_parent_id           => l_parent_transaction_id
    ,p_receipt_source_code => 'VENDOR'
    ,p_parent_transaction_type  => l_transaction_type
    ,p_grand_parent_id     => 0
    ,p_correction_type     => 'NEGATIVE'
    ,p_available_quantity  => l_available_quantity
    ,p_tolerable_quantity  => l_tolerable_quantity
    ,p_unit_of_measure     => l_unit_of_measure);

   -- convert available_quantity into primary uom quantity
   IF l_unit_of_measure <> l_shikyu_unit_of_measure THEN
    l_returned_qty_parent_txn_uom := INV_CONVERT.inv_um_convert
				( item_id             => l_shikyu_component_id
				, precision           => 5
				, from_quantity       => l_returned_qty
				, from_unit           => null
				, to_unit             => null
				, from_name           => l_shikyu_unit_of_measure
				, to_name             => l_unit_of_measure
				);
   END IF;

   IF l_returned_qty_parent_txn_uom > l_available_quantity THEN
       raise l_rtv_unsuccessful;
   END IF;

   -- insert into RCV header interface
  JMF_SHIKYU_RCV_PVT.process_rcv_header
                   ( p_vendor_id => NULL --l_rtv_details.vendor_id
		   , p_vendor_site_id => NULL
                   , p_ship_to_org_id => NULL
                   , x_rcv_header_id => l_header_interface_id
                   , x_group_id => l_group_id);

   -- insert into RCV transaction interface
   JMF_SHIKYU_RCV_PVT.process_rcv_trx
                    ( p_rcv_header_id        => l_header_interface_id
                    , p_group_id             => l_group_id
                    , p_quantity             => l_returned_qty_parent_txn_uom
                    , p_unit_of_measure      => l_unit_of_measure
                    , p_po_header_id         => l_replen_po_header_id
                    , p_po_line_id           => l_replen_po_line_id
                    , p_po_line_location_id  => l_replen_po_shipment_id
                    , p_transaction_type     => 'RETURN TO VENDOR'
                    , p_parent_transaction_id=> l_parent_transaction_id
		    , p_from_subinventory    => l_subinventory
		    , p_from_locator_id      => l_locator_id
		    , p_project_id           => l_project_id) ;

 -- submit concurrent request for Receiving Transaction Processor
 l_return_number := fnd_request.submit_request(
		application       => 'PO'
		, program         => 'RVCTP'
		, description     => 'Receiving Transaction Processor'
		, start_time      => SYSDATE
		, sub_request     => FALSE
		, argument1       => 'IMMEDIATE'
		, argument2       => l_group_id
		);

	COMMIT;



   -- Wait till RTV completes to perform deallocation.
  LOOP
   IF JMF_SHIKYU_UTIL.Has_worker_completed(l_return_number) THEN
    EXIT;
   ELSE
    DBMS_LOCK.sleep(JMF_SHIKYU_UTIL.G_SLEEP_TIME);
   END IF;
  END LOOP;

  -- Again search for received quantity against Replenish Po Shipment
  select QUANTITY_RECEIVED
  into l_post_qty_received
  from PO_LINE_LOCATIONS_ALL
  where LINE_LOCATION_ID = l_replen_po_shipment_id;

  -- Check if return happened successfully
  IF l_returned_qty_parent_txn_uom <> (l_pre_qty_received - l_post_qty_received) THEN
    raise l_rtv_unsuccessful;
  END IF;

  END IF;  --IF p_status <> 'DA_ERROR' THEN
  -- Convert shipped_qty to primary uom if required
  IF l_shikyu_primary_uom <> l_shipped_qty_uom THEN
    l_shipped_primary_uom_qty := INV_CONVERT.inv_um_convert
                             ( item_id             => l_shikyu_component_id
                             , precision           => 5
                             , from_quantity       => l_shipped_primary_uom_qty
                             , from_unit           => l_shipped_qty_uom
                             , to_unit             => l_shikyu_primary_uom
                             , from_name           => null
                             , to_name             => null
                             );
  END IF;

  -- Consider case of under Shipment when allocable quantity is more
  -- than shipped quantity. Returned quantity will be increased by
  -- allocable quantity - shipped quantity.
  IF l_allocable_primary_uom_qty > l_shipped_primary_uom_qty THEN
   l_returned_qty := l_returned_qty +
     (l_allocable_primary_uom_qty - l_shipped_primary_uom_qty );
  END IF;
  -- Deallocate based on LIFO order of Need By Date of the Subcontracting
  -- Orders already allocated to the current Replenishment SO Line
  JMF_SHIKYU_ALLOCATION_PVT.Reconcile_Replen_Excess_Qty
        ( p_api_version          => 1.0
        , p_init_msg_list        => p_init_msg_list
        , x_return_status        => x_return_status
        , x_msg_count            => x_msg_count
        , x_msg_data             => x_msg_data
        , p_replen_order_line_id => l_replen_so_line_id
        , p_excess_qty           => l_returned_qty
        );
  IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     p_status := 'DA_ERROR';
  END IF;

  IF g_proc_level >= g_debug_level
  THEN
    FND_LOG.string(g_proc_level
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , NULL);
  END IF;

EXCEPTION
  WHEN l_rtv_unsuccessful THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );

    x_return_status := FND_API.G_RET_STS_ERROR;
    IF g_excep_level >= g_debug_level
    THEN
      FND_LOG.string(g_excep_level
                    , G_MODULE_PREFIX || l_api_name || '.RTV_Failed'
                    , 'Exception - RTV Failed for Replenishment Sales Order Id: '
                    || l_replen_so_line_id);
    END IF;
  WHEN NO_DATA_FOUND THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );

    x_return_status := FND_API.G_RET_STS_ERROR;
    IF g_excep_level >= g_debug_level
    THEN
      FND_LOG.string(g_excep_level
                    , G_MODULE_PREFIX || l_api_name || '.No_Date_Found'
                    , 'Exception - Replenishment Sales Order Line: ' || l_replen_so_line_id);
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF g_unexp_level >= g_debug_level
    THEN
      FND_LOG.string(g_unexp_level
                    , G_MODULE_PREFIX || l_api_name || '.unexpected_exception'
                    , 'Exception');
    END IF;
  WHEN OTHERS THEN
    FND_MSG_PUB.Count_And_Get
              ( p_count => x_msg_count
              , p_data  => x_msg_data
              );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF g_unexp_level >= g_debug_level
    THEN
      FND_LOG.string(g_unexp_level
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , 'Exception');
    END IF;
END Process_Component_Return;

/* Private Helper Functions/Procedures */
--========================================================================
-- PROCEDURE : Validate_And_Allocate	PRIVATE
-- PARAMETERS: p_init_msg_list 	    IN  Standard in parameter message list
--	       x_return_flag	    OUT To indicate whether the required number of
--					replenishments are available or not
--             x_return_status      OUT Stadard out parameter for return status
--                                     (Values E(Error), S(Success), U(Unexpected error))
--             x_msg_count          OUT Stadard out parameter for number of messages
--             x_msg_data           OUT Stadard out parameter for message
--                                     (Values E(Error), S(Success), U(Unexpected error))
--             p_po_shipment_id     IN Subcontracting PO shipment
--	       p_project_id	    IN	project reference
--	       p_task_id	    IN  task reference
--
-- COMMENT   : This procedure is called from OSA Receipt and OSA Return api
--             before performing WIP completion and Misc issue at Manufacturing
--             Partner organization. It does allocations if required. It raises exception
--	       if sufficient allocations are not available.
--Following is logic:
--1. If Subcontracting PO is allocable
--   IF Required quantity of SHIKYU Component at TP site for this subcontract PO >
--      Allocated quantity of SHIKYU Component against that Subcontracting Order
--   Then
--     Find available Replenishment SO for allocation
--     If Enough replenishment SO are not available then error out.
--     perform allocation for SHIKYU Component quantities against OSA Receipt quantity.
--========================================================================
PROCEDURE Validate_And_Allocate
( p_init_msg_list           IN  VARCHAR2
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, x_return_flag             OUT NOCOPY NUMBER
, p_po_shipment_id          IN  NUMBER
, p_project_id		    IN  NUMBER
, p_task_id		    IN  NUMBER
)
IS

l_remaining_qty			 NUMBER;
l_actual_qty_allocated		 NUMBER;
l_shikyu_qty_to_allocate         NUMBER;
l_total_allocated_Qty            NUMBER;
l_required_quantity		 NUMBER;
l_allocable_flag                 JMF_SHIKYU_ALLOCATIONS_V.ALLOCATABLE_FLAG%Type;
l_available_replen_so_qty_tbl    JMF_SHIKYU_ALLOCATION_PVT.g_replen_so_qty_tbl_type;
l_adjustment_total               NUMBER;
l_interlock_status               VARCHAR2(1);
-- custom exceptions
l_not_enough_replen_excep        EXCEPTION;
l_not_allocated_completely       EXCEPTION;

-- cursor definitions
cursor c_subcontract_po_shikyu_comp is
select jsc.SHIKYU_COMPONENT_ID shikyu_component_id, jso.TP_ORGANIZATION_ID tp_organization_id, jsc.PRIMARY_UOM primary_uom
from JMF_SHIKYU_COMPONENTS jsc, JMF_SUBCONTRACT_ORDERS jso
where  jsc.SUBCONTRACT_PO_SHIPMENT_ID = p_po_shipment_id
and    jso.subcontract_po_shipment_id = jsc.SUBCONTRACT_PO_SHIPMENT_ID;

BEGIN

 x_return_status := FND_API.G_RET_STS_ERROR;
 x_return_flag := 0;

 SELECT interlock_status
 into l_interlock_status
 FROM JMF_SUBCONTRACT_ORDERS
 WHERE SUBCONTRACT_PO_SHIPMENT_ID = p_po_shipment_id;

 -- AND NVL(project_id, -1)= NVL(p_project_id, -1)
 -- AND NVL(task_id, -1)= NVL(p_task_id, -1);

 IF l_interlock_status = 'C' THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
 ELSE
  -- Check if allocation is needed against OSA receipt
   select ALLOCATABLE_FLAG
   into l_allocable_flag
   from JMF_SHIKYU_ALLOCATIONS_V
   where SUBCONTRACT_PO_SHIPMENT_ID = p_po_shipment_id;


   -- Call Allocations API to allcoate if all received quantities are not allocated
   IF l_allocable_flag = 'Y' THEN
    -- Allocate each SHIKYU component of OSA item
    FOR l_subcontract_po_shikyu_comp IN c_subcontract_po_shikyu_comp
    LOOP

     -- Get total allocated quantity for SHIKYU Component.
     l_total_allocated_Qty := JMF_SHIKYU_UTIL.Get_Subcontract_Allocated_Qty
                  (p_po_shipment_id
                  ,l_subcontract_po_shikyu_comp.shikyu_component_id);

     -- Get required quantity of shikyu component.


     l_required_quantity := JMF_SHIKYU_WIP_PVT.get_component_quantity
                     ( p_item_id => l_subcontract_po_shikyu_comp.shikyu_component_id
                     , p_organization_id => l_subcontract_po_shikyu_comp.tp_organization_id
                     , p_subcontract_po_shipment_id => p_po_shipment_id
                     );

     /*vmutyala added the following to take into account the consumption adjustments made after receiving partial
     quantity. The subcontract PO is fully allocated if l_required_quantity - l_total_allocated_Qty = total adjustments made */
     l_adjustment_total := 0;

     SELECT nvl(SUM(adjustment), 0)
     INTO l_adjustment_total
     FROM jmf_shikyu_adjustments
     WHERE subcontract_po_shipment_id = p_po_shipment_id
     AND shikyu_component_id = l_subcontract_po_shikyu_comp.shikyu_component_id
     AND request_id IS NOT NULL;

     l_required_quantity := l_required_quantity - l_adjustment_total;


     IF (l_required_quantity > l_total_allocated_Qty) THEN

      -- Calculate total SHIKYU comsumption by received OSA items
      l_shikyu_qty_to_allocate := l_required_quantity - l_total_allocated_Qty;


      -- Find available Replenishment Sales Orders for allocation
      JMF_SHIKYU_ALLOCATION_PVT.Get_Available_Replenishment_So
        ( p_api_version                => 1.0
        , p_init_msg_list              => p_init_msg_list
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , p_subcontract_po_shipment_id => p_po_shipment_id
        , p_component_id               => l_subcontract_po_shikyu_comp.shikyu_component_id
        , p_qty                        => l_shikyu_qty_to_allocate
        , p_include_additional_supply  => 'N'
        , p_arrived_so_lines_only      => 'Y'
        , x_available_replen_tbl       => l_available_replen_so_qty_tbl
        , x_remaining_qty              => l_remaining_qty
        );

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
        raise FND_API.G_EXC_ERROR;
      -- Raise an exception if there is not enough existing replenishments
      ELSIF l_remaining_qty > 0 THEN
        raise l_not_enough_replen_excep;
      -- Allocate if there is enough existing replenishments
      END IF;

      -- Allocate SHIKYU components from available Replenishments.
      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        JMF_SHIKYU_ALLOCATION_PVT.Allocate_Quantity
         ( p_api_version                => 1.0
         , p_init_msg_list              => p_init_msg_list
         , x_return_status              => x_return_status
         , x_msg_count                  => x_msg_count
         , x_msg_data                   => x_msg_data
         , p_subcontract_po_shipment_id => p_po_shipment_id
         , p_component_id               => l_subcontract_po_shikyu_comp.shikyu_component_id
         , p_qty_to_allocate            => l_shikyu_qty_to_allocate
         , p_available_replen_tbl       => l_available_replen_so_qty_tbl
         -- to store the actual qty being returned as OUT parameter
         , x_qty_allocated              => l_actual_qty_allocated
         );

        -- Raise an exception if actual quantity allocated is not same as requested quantity.
        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         raise FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
         raise FND_API.G_EXC_ERROR;
        ELSIF l_actual_qty_allocated < l_shikyu_qty_to_allocate THEN
         raise l_not_allocated_completely;
        END IF; -- IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      END IF; --IF x_return_status = success THEN
     ELSIF l_required_quantity = l_total_allocated_Qty THEN
         x_return_status := FND_API.G_RET_STS_SUCCESS;
     END IF; --IF (l_required_quantity > l_total_allocated_Qty) THEN


    END LOOP; -- FOR l_subcontract_po_shikyu_comp IN c_subcontract_po_shikyu_comp
   ELSIF l_allocable_flag = 'N' THEN
         x_return_status := FND_API.G_RET_STS_SUCCESS;
   END IF; -- IF l_allocable_flag = 'Y' THEN
  END IF; -- IF l_interlock_status = 'C' THEN

EXCEPTION
  WHEN l_not_enough_replen_excep THEN


    x_return_flag := 1;
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN l_not_allocated_completely THEN

    x_return_flag := 2;
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Validate_And_Allocate;
--=============================================================================
-- PROCEDURE NAME: Init
-- TYPE          : PRIVATE
-- PARAMETERS    : None
-- DESCRIPTION   : Initializes Global Variables.
-- EXCEPTIONS    : None
-- CHANGE HISTORY: 23-MAY-05    VCHU    Created.
--=============================================================================

PROCEDURE Init
IS
BEGIN

  -- initializes the global variables for FND Log

  IF g_proc_level IS NULL
    THEN
    g_proc_level := FND_LOG.LEVEL_PROCEDURE;
  END IF; /* IF g_proc_level IS NULL */

  IF g_unexp_level IS NULL
    THEN
    g_unexp_level := FND_LOG.LEVEL_UNEXPECTED;
  END IF; /* IF g_unexp_level IS NULL */

  IF g_excep_level IS NULL
    THEN
    g_excep_level := FND_LOG.LEVEL_EXCEPTION;
  END IF; /* IF g_excep_level IS NULL */

  IF g_statement_level IS NULL
    THEN
    g_statement_level := FND_LOG.LEVEL_STATEMENT;
  END IF; /* IF g_statement_level IS NULL */

  g_debug_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;


END Init;

END JMF_PROCESS_SHIKYU_RCV_TRX_PVT;

/
