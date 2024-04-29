--------------------------------------------------------
--  DDL for Package Body RCV_ACCEVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_ACCEVENTS_PVT" AS
/* $Header: RCVVRAEB.pls 120.6.12010000.2 2008/11/10 14:40:32 mpuranik ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'RCV_AccEvents_PVT';
G_DEBUG CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
G_LOG_HEAD CONSTANT VARCHAR2(40) := 'po.plsql.'||G_PKG_NAME;

-- Start of comments
--	API name 	: Create_ReceivingEvents
--	Type		: Private
--	Function	: To seed accounting events for receiving transactions
--	Pre-reqs	:
--	Parameters	:
--	IN		:	p_api_version           IN NUMBER	Required
--				p_init_msg_list		IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	    	IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--				p_validation_level	IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--                              p_rcv_transaction_id    IN NUMBER       Optional
--                              p_direct_delivery_flag  IN VARCHAR2     Required
--
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count		OUT	NUMBER
--				x_msg_data		OUT	VARCHAR2(2000)
--	Version	:
--			  Initial version 	1.0
--
--	Notes		: This API creates all accounting events for receiving transactions
-- 			  in RCV_ACCOUNTING_EVENTS. For online accruals, it also generates
--			  the accounting entries for the event.
--
-- End of comments
-------------------------------------------------------------------------------
PROCEDURE Create_ReceivingEvents(
	        p_api_version          	IN	NUMBER,
	        p_init_msg_list        	IN	VARCHAR2 ,
	        p_commit               	IN	VARCHAR2 ,
	        p_validation_level     	IN	NUMBER ,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

	        p_rcv_transaction_id 	IN NUMBER,
                p_direct_delivery_flag  IN VARCHAR2
) IS
   l_api_name   	CONSTANT VARCHAR2(30)   := 'Create_ReceivingEvent';
   l_api_version        CONSTANT NUMBER         := 1.0;

   l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_msg_count           NUMBER := 0;
   l_msg_data            VARCHAR2(8000) := '';
   l_stmt_num            NUMBER := 0;
   l_api_message         VARCHAR2(1000);

   l_err_num   NUMBER;
   l_err_code  VARCHAR2(240);
   l_err_msg   VARCHAR2(240);
   l_return_code NUMBER;

   l_consigned_flag	 RCV_TRANSACTIONS.consigned_flag%TYPE;
   l_source_doc_code	 RCV_TRANSACTIONS.source_document_code%TYPE;
   l_transaction_type	 RCV_TRANSACTIONS.transaction_type%TYPE;
   l_parent_trx_id	 RCV_TRANSACTIONS.transaction_id%TYPE;
   l_parent_trx_type     RCV_TRANSACTIONS.transaction_type%TYPE;
   l_grparent_trx_id	 RCV_TRANSACTIONS.transaction_id%TYPE;
   l_grparent_trx_type   RCV_TRANSACTIONS.transaction_type%TYPE;
   l_po_header_id	 PO_HEADERS_ALL.po_header_id%TYPE;

   -- 12i Complex Work Procurement -------------------------------------------
   l_po_line_location_id	PO_LINE_LOCATIONS_ALL.line_location_id%TYPE;
   l_shipment_type	PO_LINE_LOCATIONS_ALL.shipment_type%TYPE;
   ---------------------------------------------------------------------------

   l_opm_flag		 NUMBER;
   l_cr_flag		 BOOLEAN;
   l_user_id		 NUMBER;


BEGIN
   -- Standard start of API savepoint
      SAVEPOINT Create_ReceivingEvents_PVT;

      l_stmt_num := 0;

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.begin'
             ,'Create_ReceivingEvents <<');
      END IF;

   -- Standard call to check for call compatibility
      IF NOT FND_API.Compatible_API_Call (
                        l_api_version,
                        p_api_version,
                        l_api_name,
                        G_PKG_NAME ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE
      IF FND_API.to_Boolean(p_init_msg_list) THEN
           FND_MSG_PUB.initialize;
      END IF;

   -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      l_stmt_num := 20;
   -- Check if accrual is disabled.
      l_return_code := CSTRVHKS.disable_accrual(l_err_num,
                                          l_err_code,
		                                l_err_msg);
      IF(l_return_code = -999) THEN
         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.message(FND_LOG.LEVEL_ERROR,G_LOG_HEAD || '.'||l_api_name||l_stmt_num,FALSE);
         END IF;
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF (l_return_code = 1) THEN
         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                ,'Accrual has been disabled.');
         END IF;
	 return;
      END IF;


   -- If OPM PO and Common Purchasing is installed, we do not do any
   -- accounting.
      l_stmt_num := 30;
      l_opm_flag := GML_OPM_PO.check_opm_po(l_po_header_id);

      l_stmt_num := 40;
      l_cr_flag := GML_PO_FOR_PROCESS.check_po_for_proc;

      IF (l_opm_flag = 1 AND l_cr_flag = FALSE) THEN
 	return;
      END IF;

      l_stmt_num := 50;
      SELECT RT.consigned_flag,
	     RT.source_document_code,
	     RT.transaction_type,
	     RT.parent_transaction_id,
	     RT.po_header_id,
	     RT.po_line_location_id --12i Complex Work Procurement
      INTO   l_consigned_flag,
	     l_source_doc_code,
	     l_transaction_type,
	     l_parent_trx_id,
	     l_po_header_id,
	     l_po_line_location_id --12i Complex Work Procurement
      FROM   rcv_transactions RT
      WHERE  transaction_id = p_rcv_transaction_id;

   -- If receiving transaction is for a REQ, or an RMA, we do not
   -- do not do any accounting.
      IF(l_source_doc_code <> 'PO') THEN
	return;
      END IF;

      IF(l_transaction_type IN ('UNORDERED','ACCEPT','REJECT','TRANSFER')) THEN
	return;
      END IF;

      IF(l_parent_trx_id NOT IN (0,-1)) THEN
        l_stmt_num := 60;
	-- Get Parent Transaction Type
      	SELECT  transaction_type, parent_transaction_id
      	INTO    l_parent_trx_type, l_grparent_trx_id
      	FROM    rcv_transactions
      	WHERE   transaction_id = l_parent_trx_id;

	IF(l_grparent_trx_id NOT IN (0,-1)) THEN
          l_stmt_num := 70;
       -- Get Grand Parent Transaction Type
          SELECT  transaction_type
          INTO    l_grparent_trx_type
          FROM    rcv_transactions
          WHERE   transaction_id = l_grparent_trx_id;
	END IF;
      END IF;

      IF((l_transaction_type = 'CORRECT' OR l_transaction_type = 'RETURN TO VENDOR') AND
	 (l_parent_trx_type = 'UNORDERED')) THEN
	return;
      END IF;

      IF((l_transaction_type = 'CORRECT') AND
	 (l_parent_trx_type = 'RETURN TO VENDOR') AND
	 (l_grparent_trx_type = 'UNORDERED')) THEN
	return;
      END IF;

      -- R12: Complex Work Procurement
      -- Exclude any transactions whose POLL.shipment_type = 'PREPAYMENT'.
      SELECT  shipment_type
      INTO    l_shipment_type
      FROM    po_line_locations
      WHERE   line_location_id = l_po_line_location_id;

      IF (l_shipment_type = 'PREPAYMENT') THEN
         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name,
                          'Shipment Type is Prepayment. No Receive Events created');
         END IF;
        return;
      END IF;

      IF((l_transaction_type = 'RECEIVE') OR
	 (l_transaction_type = 'MATCH') OR
	 (l_transaction_type = 'CORRECT' AND l_parent_trx_type = 'RECEIVE') OR
	 (l_transaction_type = 'CORRECT' AND l_parent_trx_type = 'MATCH')) THEN
	l_stmt_num := 80;
	IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
	   FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
		,'Creating Events For RECEIVE transaction');
	END IF;

	RCV_AccEvents_PVT.Create_ReceiveEvents(
			p_api_version           => 1.0,
			x_return_status         => l_return_status,
			x_msg_count             => l_msg_count,
			x_msg_data              => l_msg_data,
			p_rcv_transaction_id    => p_rcv_transaction_id,
			p_direct_delivery_flag  => p_direct_delivery_flag );
      ELSIF((l_transaction_type = 'DELIVER')OR
	    (l_transaction_type = 'CORRECT' AND l_parent_trx_type = 'DELIVER')) THEN
	l_stmt_num := 90;
	IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
	   FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
		,'Creating Events For DELIVER transaction');
	END IF;

	RCV_AccEvents_PVT.Create_DeliverEvents(
			p_api_version           => 1.0,
			x_return_status         => l_return_status,
			x_msg_count             => l_msg_count,
			x_msg_data              => l_msg_data,
			p_rcv_transaction_id    => p_rcv_transaction_id,
			p_direct_delivery_flag  => p_direct_delivery_flag );

      ELSIF ((l_transaction_type = 'RETURN TO RECEIVING') OR
	     (l_transaction_type = 'CORRECT' AND l_parent_trx_type = 'RETURN TO RECEIVING')) THEN
	l_stmt_num := 100;
	IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
	   FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
		,'Creating Events For RETURN TO RECEIVING transaction');
	END IF;

	RCV_AccEvents_PVT.Create_RTREvents(
			p_api_version           => 1.0,
			x_return_status         => l_return_status,
			x_msg_count             => l_msg_count,
			x_msg_data              => l_msg_data,
			p_rcv_transaction_id    => p_rcv_transaction_id,
			p_direct_delivery_flag  => p_direct_delivery_flag );
      ELSIF ((l_transaction_type = 'RETURN TO VENDOR') OR
	     (l_transaction_type = 'CORRECT' AND l_parent_trx_type = 'RETURN TO VENDOR')) THEN
	l_stmt_num := 110;
	IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
	   FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
		,'Creating Events For RETURN TO VENDOR transaction');
	END IF;

	RCV_AccEvents_PVT.Create_RTVEvents(
			p_api_version           => 1.0,
			x_return_status         => l_return_status,
			x_msg_count             => l_msg_count,
			x_msg_data              => l_msg_data,
			p_rcv_transaction_id    => p_rcv_transaction_id,
			p_direct_delivery_flag  => p_direct_delivery_flag );
      END IF;

      IF l_return_status <> FND_API.g_ret_sts_success THEN
        l_api_message := 'Error creating event';
        IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                   ,'Create_ReceivingEvents : '||l_stmt_num||' : '||l_api_message);
        END IF;
        RAISE FND_API.g_exc_unexpected_error;
      END IF;


      l_stmt_num := 120;
   --- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
	  COMMIT WORK;
       END IF;

    -- Standard Call to get message count and if count = 1, get message info
       FND_MSG_PUB.Count_And_Get (
	   p_count     => x_msg_count,
	   p_data      => x_msg_data );

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
	 FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.end'
	     ,'Create_ReceivingEvents>>');
      END IF;

EXCEPTION
      WHEN FND_API.g_exc_error THEN
 	ROLLBACK TO Create_ReceivingEvents_PVT;
	x_return_status := FND_API.g_ret_sts_error;
	FND_MSG_PUB.count_and_get
	(  p_count => x_msg_count
	   , p_data  => x_msg_data
	);
      WHEN FND_API.g_exc_unexpected_error THEN
	 ROLLBACK TO Create_ReceivingEvents_PVT;
	 x_return_status := FND_API.g_ret_sts_unexp_error ;
	 FND_MSG_PUB.count_and_get
	 (  p_count  => x_msg_count
	   , p_data   => x_msg_data
	 );

      WHEN OTHERS THEN
        ROLLBACK TO Create_ReceivingEvents_PVT;
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
               ,'Create_ReceivingEvents : '||l_stmt_num||' : '||substr(SQLERRM,1,200));
        END IF;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
              FND_MSG_PUB.add_exc_msg
                (  G_PKG_NAME,
                   l_api_name || 'Statement -'||to_char(l_stmt_num)
                );
         END IF;
         FND_MSG_PUB.count_and_get
         (  p_count  => x_msg_count
            , p_data   => x_msg_data
         );

END Create_ReceivingEvents;



--      API name        : Create_AdjustEvents
--      Type            : Private
--      Function        : To seed accounting events for retroactive price adjustments.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_po_header_id          IN NUMBER       Required
--                              p_po_release_id         IN NUMBER       Optional
--                              p_po_line_id            IN NUMBER       Optional
--                              p_po_line_location_id   IN NUMBER       Required
--                              p_old_po_price          IN NUMBER       Required
--                              p_new_po_price          IN NUMBER       Required
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count                     OUT     NUMBER
--                              x_msg_data                      OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--
--      Notes           : This API creates all accounting events for retroactive price adjustments
--                        in RCV_ACCOUNTING_EVENTS. For online accruals, it also generates
--                        the accounting entries for the event.
--
-- End of comments
-------------------------------------------------------------------------------
PROCEDURE Create_AdjustEvents(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2,
                p_commit                IN      VARCHAR2,
                p_validation_level      IN      NUMBER,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                p_po_header_id          IN      NUMBER,
                p_po_release_id         IN      NUMBER,
                p_po_line_id            IN      NUMBER,
                p_po_line_location_id   IN      NUMBER,
                p_old_po_price          IN      NUMBER,
                p_new_po_price          IN      NUMBER

) IS
   l_api_name   	CONSTANT VARCHAR2(30)   := 'Create_AdjustEvents';
   l_api_version        CONSTANT NUMBER         := 1.0;

   l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_msg_count           NUMBER := 0;
   l_msg_data            VARCHAR2(8000) := '';
   l_stmt_num            NUMBER := 0;
   l_api_message         VARCHAR2(1000);

   l_rcv_event           RCV_SeedEvents_PVT.rcv_event_rec_type;
   l_rcv_events_tbl      RCV_SeedEvents_PVT.rcv_event_tbl_type;
   l_rae_count		 NUMBER;

-- 12i Complex Work Procurement------------------------------------
   l_matching_basis     PO_LINE_LOCATIONS.matching_basis%TYPE;
   l_shipment_type	PO_LINE_LOCATIONS.shipment_type%TYPE;
-------------------------------------------------------------------
   l_proc_operating_unit NUMBER;
   l_po_distribution_id  NUMBER;
   l_organization_id     NUMBER;
   l_rcv_quantity        NUMBER := 0;
   l_delived_quantity    NUMBER := 0;

   l_trx_flow_header_id  NUMBER := NULL;
   l_drop_ship_flag	 NUMBER := NULL;
   l_opm_flag            NUMBER;
   l_cr_flag             BOOLEAN;


-- Cursor to get all parent receive transactions
-- for a given po_header or po_release

   CURSOR c_parent_receive_txns_csr IS
   SELECT transaction_id, organization_id
   FROM   rcv_transactions
   WHERE  ( ( transaction_type = 'RECEIVE'
           and parent_transaction_id = -1 )
           or
           transaction_type = 'MATCH' )
   AND    NVL(consigned_flag,'N') <> 'Y'
   AND    po_header_id = p_po_header_id
   AND    po_line_location_id = p_po_line_location_id
   AND    NVL(po_release_id, -1) = NVL(p_po_release_id, -1);

-- Cursor to get all deliver transactions for
-- a parent receive transaction.

   CURSOR c_deliver_txns_csr (l_par_txn IN NUMBER) IS
   SELECT transaction_id, po_distribution_id
   FROM   rcv_transactions
   WHERE   transaction_type = 'DELIVER'
   START WITH transaction_id = l_par_txn
   CONNECT BY parent_transaction_id = prior transaction_id;

-- Cursor to get all distributions corresponding
-- to a po_line_location.
-- The PO line location corresponds to the parent rcv_transaction

   CURSOR c_po_dists_csr (l_rcv_txn IN NUMBER) IS
   SELECT POD.po_distribution_id
   FROM   po_distributions POD,
          po_line_locations POLL,
          rcv_transactions RT
   WHERE  POD.line_location_id  = POLL.line_location_id
   AND    POLL.line_location_id = RT.po_line_location_id
   AND    RT.transaction_id     = l_rcv_txn;


BEGIN

   -- Standard start of API savepoint
      SAVEPOINT Create_AdjustEvents_PVT;

      l_stmt_num := 0;

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.begin'
             ,'Create_AdjustEvent <<');
      END IF;

   -- Standard call to check for call compatibility
      IF NOT FND_API.Compatible_API_Call (
                        l_api_version,
                        p_api_version,
                        l_api_name,
                        G_PKG_NAME ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE
      IF FND_API.to_Boolean(p_init_msg_list) THEN
           FND_MSG_PUB.initialize;

      END IF;
   -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- If the old and new price are the same, return
      IF p_old_po_price = p_new_po_price THEN
         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name,
			  'Old and New Prices are same. No Adjust Events created');
         END IF;
         RETURN;
      END IF;

   -- If OPM PO and Common Purchasing is installed, we do not do any
   -- accounting.
      l_stmt_num := 5;
      l_opm_flag := GML_OPM_PO.check_opm_po(p_po_header_id);

      l_stmt_num := 10;
      l_cr_flag := GML_PO_FOR_PROCESS.check_po_for_proc;

      IF (l_opm_flag = 1 AND l_cr_flag = FALSE) THEN
        return;
      END IF;

      l_stmt_num := 20;

   -- Get Matching Basis and Shipment Type
      SELECT POLL.matching_basis, POLL.shipment_type
      INTO   l_matching_basis, l_shipment_type
      FROM   po_line_locations POLL
      WHERE  POLL.line_location_id = p_po_line_location_id;

      l_stmt_num := 30;

   -- If Line Type is Service (matching basis = AMOUNT), then return without doing anything
      IF (l_matching_basis is not null and l_matching_basis = 'AMOUNT') THEN
         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name,
			  'Service Line Type. No Adjust Events created');
         END IF;
      	 return;
      END IF;

      l_stmt_num := 35;

   -- If Shipment Type is Prepayment, then return without doing anything
      IF (l_shipment_type = 'PREPAYMENT') THEN
         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name,
			  'Shipment Type is Prepayment. No Adjust Events created');
         END IF;
      	 return;
      END IF;

      l_stmt_num := 40;

   -- Get Procuring operating unit
      SELECT org_id
      INTO   l_proc_operating_unit
      FROM   po_headers
      WHERE  po_header_id = p_po_header_id;


   -- Loop Through all Parent Transactions

      FOR c_par_txn IN c_parent_receive_txns_csr LOOP

       -- Get the Organization in which event is to be seeded
       -- Get the row in RAE with the RCV_TRANSACTION as that of the parent txn
       -- and procurement_org_flag = 'Y'

          l_stmt_num := 50;

	  SELECT count(*)
	  INTO   l_rae_count
	  FROM 	 rcv_accounting_events
	  WHERE  rcv_transaction_id = c_par_txn.transaction_id;

	  IF l_rae_count > 0 THEN

          -- Rownum check is there since there might be multiple events in
          -- RAE for a particular Receive transaction in RCV_TRANSACTIONS

             l_stmt_num := 60;

             SELECT RAE.organization_id, RAE.trx_flow_header_id, NVL(RT.dropship_type_code,3)
             INTO   l_organization_id, l_trx_flow_header_id,l_drop_ship_flag
             FROM   rcv_accounting_events RAE,
		    rcv_transactions	  RT
             WHERE  RAE.rcv_transaction_id   	= c_par_txn.transaction_id
	     AND    RT.transaction_id		= RAE.rcv_transaction_id
             AND    RAE.procurement_org_flag = 'Y'
             AND    rownum = 1;
	  ELSE
	     l_organization_id := c_par_txn.organization_id;
	  END IF;


       -- One event is seeded per PO distribution
       -- If RCV_TRANSACTIONS has the po_distribution_id populated, we
       -- use that. Otherwise, we use cursor c_po_dists_csr to seed as many events
       -- as the number of distributions for the line_location

          l_stmt_num := 70;

          SELECT nvl(po_distribution_id, -1)
          INTO   l_po_distribution_id
          FROM   rcv_transactions
          WHERE  transaction_id = c_par_txn.transaction_id;


          IF l_po_distribution_id <> -1 THEN

            l_stmt_num := 80;

            RCV_SeedEvents_PVT.Seed_RAEEvent(
                  p_api_version           => 1.0,
                  x_return_status         => l_return_status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data,
                  p_event_source          => 'RETROPRICE',
                  p_event_type_id         => RCV_SeedEvents_PVT.ADJUST_RECEIVE,
                  p_rcv_transaction_id    => c_par_txn.transaction_id,
                  p_inv_distribution_id   => NULL,
                  p_po_distribution_id    => l_po_distribution_id,
                  p_direct_delivery_flag  => NULL,
                  p_cross_ou_flag         => NULL,
                  p_procurement_org_flag  => 'Y',
                  p_ship_to_org_flag      => NULL,
                  p_drop_ship_flag        => l_drop_ship_flag,
                  p_org_id                => l_proc_operating_unit,
                  p_organization_id       => l_organization_id,
                  p_transfer_org_id       => NULL,
                  p_transfer_organization_id => NULL,
                  p_trx_flow_header_id    => l_trx_flow_header_id,
                  p_transaction_forward_flow_rec  => NULL,
                  p_transaction_reverse_flow_rec  => NULL,
                  p_unit_price            => p_new_po_price,
                  p_prior_unit_price      => p_old_po_price,
                  /* Support for Landed Cost Management */
                  p_lcm_flag              => 'N',
                  x_rcv_event             => l_rcv_event);

	 -- Suppose there is no net quantity for this receipt (all received quantity has been
	 -- returned), there is no need to seed an event, since there is no accrual to adjust.
 	 -- If transaction quantity is 0, the Seed_RAEEvent API will return a warning. In the
	 -- case of Adjust events, this warning is normal and should be ignored.
	    IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		l_rcv_events_tbl(l_rcv_events_tbl.count + 1) := l_rcv_event;
            ELSIF (l_return_status <> 'W') THEN
               l_api_message := 'Error seeding event';
               IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                       ,'Create_AdjustEvents : '||l_stmt_num||' : '||l_api_message);
               END IF;
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

          ELSE

            FOR c_po_dist IN c_po_dists_csr (c_par_txn.transaction_id) LOOP
              l_stmt_num := 90;

              RCV_SeedEvents_PVT.Seed_RAEEvent(
                  p_api_version           => 1.0,
                  x_return_status         => l_return_status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data,
                  p_event_source          => 'RETROPRICE',
                  p_event_type_id         => RCV_SeedEvents_PVT.ADJUST_RECEIVE,
                  p_rcv_transaction_id    => c_par_txn.transaction_id,
                  p_inv_distribution_id   => NULL,
                  p_po_distribution_id    => c_po_dist.po_distribution_id,
                  p_direct_delivery_flag  => NULL,
                  p_cross_ou_flag         => NULL,
                  p_procurement_org_flag  => 'Y',
                  p_ship_to_org_flag      => NULL,
                  p_drop_ship_flag        => l_drop_ship_flag,
                  p_org_id                => l_proc_operating_unit,
                  p_organization_id       => l_organization_id,
                  p_transfer_org_id       => NULL,
                  p_transfer_organization_id => NULL,
                  p_trx_flow_header_id    => l_trx_flow_header_id,
                  p_transaction_forward_flow_rec  => NULL,
                  p_transaction_reverse_flow_rec  => NULL,
                  p_unit_price            => p_new_po_price,
                  p_prior_unit_price      => p_old_po_price,
                  /* Support for Landed Cost Management */
                  p_lcm_flag              => 'N',
                  x_rcv_event             => l_rcv_event);

           -- Suppose there is no net quantity for this receipt (all received quantity has been
           -- returned), there is no need to seed an event, since there is no accrual to adjust.
           -- If transaction quantity is 0, the Seed_RAEEvent API will return a warning. In the
           -- case of Adjust events, this warning is normal and should be ignored.
              IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_rcv_events_tbl(l_rcv_events_tbl.count + 1) := l_rcv_event;
              ELSIF (l_return_status <> 'W') THEN
                 l_api_message := 'Error seeding event';
                 IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                         ,'Create_AdjustEvents : '||l_stmt_num||' : '||l_api_message);
                 END IF;
                 RAISE FND_API.g_exc_unexpected_error;
              END IF;
            END LOOP;

          END IF;

       -- Adjust Deliver events are not created for global procurement scenarios.
          IF (l_trx_flow_header_id IS NULL AND (l_drop_ship_flag IS NULL or l_drop_ship_flag NOT IN (1,2))) THEN

            l_stmt_num := 100;

            FOR c_del_txn IN c_deliver_txns_csr(c_par_txn.transaction_id) LOOP
              RCV_SeedEvents_PVT.Seed_RAEEvent(
                  p_api_version           => 1.0,
                  x_return_status         => l_return_status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data,
                  p_event_source          => 'RETROPRICE',
                  p_event_type_id         => RCV_SeedEvents_PVT.ADJUST_DELIVER,
                  p_rcv_transaction_id    => c_del_txn.transaction_id,
                  p_inv_distribution_id   => NULL,
                  p_po_distribution_id    => c_del_txn.po_distribution_id,
                  p_direct_delivery_flag  => NULL,
                  p_cross_ou_flag         => NULL,
                  p_procurement_org_flag  => 'Y',
                  p_ship_to_org_flag      => NULL,
                  p_drop_ship_flag        => l_drop_ship_flag,
                  p_org_id                => l_proc_operating_unit,
                  p_organization_id       => l_organization_id,
                  p_transfer_org_id       => NULL,
                  p_transfer_organization_id => NULL,
                  p_trx_flow_header_id    => l_trx_flow_header_id,
                  p_transaction_forward_flow_rec  => NULL,
                  p_transaction_reverse_flow_rec  => NULL,
                  p_unit_price            => p_new_po_price,
                  p_prior_unit_price      => p_old_po_price,
                  /* Support for Landed Cost Management */
                  p_lcm_flag              => 'N',
                  x_rcv_event             => l_rcv_event);

           -- Suppose there is no net quantity for this deliver (all delivered quantity has been
           -- returned), there is no need to seed an event, since there is no accrual to adjust.
           -- If transaction quantity is 0, the Seed_RAEEvent API will return a warning. In the
           -- case of Adjust events, this warning is normal and should be ignored.
              IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_rcv_events_tbl(l_rcv_events_tbl.count + 1) := l_rcv_event;
              ELSIF (l_return_status <> 'W') THEN
                 l_api_message := 'Error seeding event';
                 IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                         ,'Create_AdjustEvents : '||l_stmt_num||' : '||l_api_message);
                 END IF;
                 RAISE FND_API.g_exc_unexpected_error;
              END IF;

            END LOOP;  -- C_DEL_TXN

          END IF; -- If Trx Flow does not exist

       END LOOP; -- C_PAR_TXNS


      IF (l_rcv_events_tbl.count > 0) THEN
      -- Insert events into RCV_Accounting_Events
         l_stmt_num := 110;
         RCV_SeedEvents_PVT.Insert_RAEEvents(
                     p_api_version           => 1.0,
                     x_return_status         => l_return_status,
                     x_msg_count             => l_msg_count,
                     x_msg_data              => l_msg_data,
                     p_rcv_events_tbl        => l_rcv_events_tbl,
                     /* Support for Landed Cost Management */
                     p_lcm_flag              => 'N');

         IF l_return_status <> FND_API.g_ret_sts_success THEN
           l_api_message := 'Error inserting events into RAE';
           IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
             FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                    ,'Create_AdjustEvents : '||l_stmt_num||' : '||l_api_message);
             END IF;
           RAISE FND_API.g_exc_unexpected_error;
         END IF;
      END IF;


   --- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT WORK;
       END IF;

    -- Standard Call to get message count and if count = 1, get message info
       FND_MSG_PUB.Count_And_Get (
           p_count     => x_msg_count,
           p_data      => x_msg_data );

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.end'
             ,'Create_AdjustEvents >>');
      END IF;

EXCEPTION
      WHEN FND_API.g_exc_error THEN
         ROLLBACK TO Create_AdjustEvents_PVT;
         x_return_status := FND_API.g_ret_sts_error;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );
      WHEN FND_API.g_exc_unexpected_error THEN
         ROLLBACK TO Create_AdjustEvents_PVT;
         x_return_status := FND_API.g_ret_sts_unexp_error ;
         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

      WHEN OTHERS THEN
         ROLLBACK TO Create_AdjustEvents_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                ,'Create_AdjustEvent : '||l_stmt_num||' : '||substr(SQLERRM,1,200));
         END IF;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
               FND_MSG_PUB.add_exc_msg
                 (  G_PKG_NAME,
                    l_api_name || 'Statement -'||to_char(l_stmt_num)
                 );
         END IF;
         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
            , p_data   => x_msg_data
           );

END Create_AdjustEvents;

-- Start of comments
--      API name        : Create_ICEvents
--      Type            : Private
--      Function        : To seed Intercompany events for period end AP line matches.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_invoice_distribution_id IN NUMBER     Required
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count                     OUT     NUMBER
--                              x_msg_data                      OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--
--      Notes           : This API creates inter-company accounting events for AP line matches
--                        in RCV_ACCOUNTING_EVENTS.
--
-- End of comments
-------------------------------------------------------------------------------
PROCEDURE Create_ICEvents(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2,
                p_commit                IN      VARCHAR2,
                p_validation_level      IN      NUMBER,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                p_invoice_distribution_id       IN      NUMBER
)IS
   l_api_name   	CONSTANT VARCHAR2(30)   := 'Create_ICEvents';
   l_api_version        CONSTANT NUMBER         := 1.0;

   l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_msg_count           NUMBER := 0;
   l_msg_data            VARCHAR2(8000) := '';
   l_stmt_num            NUMBER := 0;
   l_api_message         VARCHAR2(1000);

   l_rcv_event           RCV_SeedEvents_PVT.rcv_event_rec_type;
   l_rcv_events_tbl      RCV_SeedEvents_PVT.rcv_event_tbl_type;
   l_event_type_id       NUMBER;

   l_transaction_flows_tbl INV_TRANSACTION_FLOW_PUB.g_transaction_flow_tbl_type;
   l_transaction_forward_flow_rec INV_TRANSACTION_FLOW_PUB.mtl_transaction_flow_rec_type;
   l_transaction_reverse_flow_rec INV_TRANSACTION_FLOW_PUB.mtl_transaction_flow_rec_type;
   l_trx_flow_exists_flag NUMBER := 0;
   l_trx_flow_ctr       NUMBER := 0;

   l_po_header_id        NUMBER;
   l_po_distribution_id  NUMBER;
   l_po_org_id           NUMBER;
   l_rcv_organization_id NUMBER;
   l_transfer_organization_id	NUMBER;
   l_rcv_org_id          NUMBER;
   l_org_id              NUMBER;
   l_event_date          DATE;
   l_drop_ship_flag      NUMBER;
   l_destination_type    VARCHAR(25);
   l_category_id         NUMBER;
   l_project_id          NUMBER;
   l_cross_ou_flag       VARCHAR2(1);
   l_accrual_flag        VARCHAR2(1);
   l_counter             NUMBER;
   l_procurement_org_flag VARCHAR2(1);
   l_quantity_invoiced	 NUMBER;
   l_order_type_lookup_code PO_LINES.ORDER_TYPE_LOOKUP_CODE%TYPE;
   l_inv_amount		 NUMBER;
   l_price_correction_flag VARCHAR2(1) := 'N';

   l_qualifier_code_tbl INV_TRANSACTION_FLOW_PUB.NUMBER_TBL;
   l_qualifier_value_tbl INV_TRANSACTION_FLOW_PUB.NUMBER_TBL;


BEGIN
   -- Standard start of API savepoint
      SAVEPOINT Create_ICEvents_PVT;

      l_stmt_num := 0;

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.begin'
             ,'Create_ICEvents <<');
      END IF;

   -- Standard call to check for call compatibility
      IF NOT FND_API.Compatible_API_Call (
                        l_api_version,
                        p_api_version,
                        l_api_name,
                        G_PKG_NAME ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE
      IF FND_API.to_Boolean(p_init_msg_list) THEN
           FND_MSG_PUB.initialize;
      END IF;

   -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Stubbing out the code since AP will no longer be calling our API for period-end
   -- accruals. This is due to changes to the design for global procurement using
   -- period end accruals. Due to various constraints, it was decided that we will not
   -- support period end accruals for global procurement. This check will be enforced
   -- at the document level.

   -- Standard Call to get message count and if count = 1, get message info
       FND_MSG_PUB.Count_And_Get (
           p_count     => x_msg_count,
           p_data      => x_msg_data );

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.end'
             ,'Create_ICEvents >>');
      END IF;

EXCEPTION
      WHEN FND_API.g_exc_error THEN
         ROLLBACK TO Create_ICEvents_PVT;
         x_return_status := FND_API.g_ret_sts_error;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );
      WHEN FND_API.g_exc_unexpected_error THEN
         ROLLBACK TO Create_ICEvents_PVT;
         x_return_status := FND_API.g_ret_sts_unexp_error ;
         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

      WHEN OTHERS THEN
         ROLLBACK TO Create_ICEvents_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                ,'Create_ICEvents : '||l_stmt_num||' : '||substr(SQLERRM,1,200));
         END IF;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
               FND_MSG_PUB.add_exc_msg
                 (  G_PKG_NAME,
                    l_api_name || 'Statement -'||to_char(l_stmt_num)
                 );
         END IF;
         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
            , p_data   => x_msg_data
           );

END Create_ICEvents;

-- Start of comments
--      API name        : Create_ReceiveEvents
--      Type            : Private
--      Function        : To seed accounting events for RECEIVE transactions.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_rcv_transaction_id    IN NUMBER       Required
--                              p_direct_delivery_flag  IN VARCHAR2     Optional
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--
--      Notes           : This API creates all accounting events for RECEIVE transactions
--                        in RCV_ACCOUNTING_EVENTS.
--
-- End of comments
-------------------------------------------------------------------------------
PROCEDURE Create_ReceiveEvents(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2 ,
                p_commit                IN      VARCHAR2 ,
                p_validation_level      IN      NUMBER ,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                p_rcv_transaction_id    IN NUMBER,
                p_direct_delivery_flag  IN VARCHAR2
) IS
   l_api_name   	CONSTANT VARCHAR2(30)   := 'Create_ReceiveEvents';
   l_api_version        CONSTANT NUMBER         := 1.0;

   l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_msg_count           NUMBER := 0;
   l_msg_data            VARCHAR2(8000) := '';
   l_stmt_num            NUMBER := 0;
   l_api_message         VARCHAR2(1000);

   l_rcv_event		 RCV_SeedEvents_PVT.rcv_event_rec_type;
   l_rcv_events_tbl      RCV_SeedEvents_PVT.rcv_event_tbl_type;
   l_event_type_id       NUMBER;


   l_transaction_flows_tbl INV_TRANSACTION_FLOW_PUB.g_transaction_flow_tbl_type;
   l_transaction_forward_flow_rec INV_TRANSACTION_FLOW_PUB.mtl_transaction_flow_rec_type;
   l_transaction_reverse_flow_rec INV_TRANSACTION_FLOW_PUB.mtl_transaction_flow_rec_type;
   l_trx_flow_exists_flag NUMBER := 0;
   l_trx_flow_ctr 	NUMBER := 0;


   l_po_header_id	 NUMBER;
   l_po_line_id		 NUMBER;
   l_po_line_location_id NUMBER;
   l_po_distribution_id  NUMBER;
   l_po_org_id		 NUMBER;
   l_po_sob_id		 NUMBER;
   l_rcv_organization_id NUMBER;
   l_rcv_org_id    	 NUMBER;
   l_rcv_sob_id		 NUMBER;
   l_org_id		 NUMBER;
   l_transfer_org_id	 NUMBER;
   l_transfer_organization_id NUMBER;
   l_rcv_trx_date	 DATE;
   l_drop_ship_flag	 NUMBER;
   l_destination_type	 VARCHAR(25);
   l_item_id		 NUMBER;
   l_category_id	 NUMBER;
   l_project_id		 NUMBER;
   l_cross_ou_flag	 VARCHAR2(1);
   l_accrual_flag	 VARCHAR2(1);
   l_counter		 NUMBER;
   l_procurement_org_flag VARCHAR2(1);
   l_trx_flow_header_id	 NUMBER;
l_po_document_type_code PO_HEADERS_ALL.type_lookup_code%TYPE;
   l_is_shared_proc	 VARCHAR2(1);
   /* Support for Landed Cost Management */
   l_lcm_flag            VARCHAR2(1);

   l_qualifier_code_tbl INV_TRANSACTION_FLOW_PUB.NUMBER_TBL;
   l_qualifier_value_tbl INV_TRANSACTION_FLOW_PUB.NUMBER_TBL;

   CURSOR c_po_distributions_csr(p_po_distribution_id NUMBER, p_po_line_location_id NUMBER) IS
        SELECT po_distribution_id,destination_type_code, project_id
        FROM   po_distributions POD
        WHERE  POD.po_distribution_id	= NVL(p_po_distribution_id,POD.po_distribution_id)
        AND    POD.line_location_id 	= p_po_line_location_id;

BEGIN
   -- Standard start of API savepoint
      SAVEPOINT Create_ReceiveEvents_PVT;

      l_stmt_num := 0;

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.begin'
             ,'Create_ReceiveEvents <<');
      END IF;

   -- Standard call to check for call compatibility
      IF NOT FND_API.Compatible_API_Call (
                        l_api_version,
                        p_api_version,
                        l_api_name,
                        G_PKG_NAME ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE
      IF FND_API.to_Boolean(p_init_msg_list) THEN
           FND_MSG_PUB.initialize;
      END IF;

   -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      l_stmt_num := 20;
      SELECT
              RT.po_header_id,
	      RT.po_line_id,
	      RT.po_line_location_id,
              RT.po_distribution_id,
	      RT.transaction_date,
	      nvl(RT.dropship_type_code,3),
	      POH.org_id,
	      POLL.ship_to_organization_id,
	      POL.item_id,
	      POL.category_id,
	      POL.project_id,
	      nvl(POLL.accrue_on_receipt_flag,'N'),
              POH.type_lookup_code,
              /* Support for Landed Cost Management */
	      nvl(POLL.lcm_flag, 'N')
      INTO    l_po_header_id,
	      l_po_line_id,
	      l_po_line_location_id,
	      l_po_distribution_id,
	      l_rcv_trx_date,
	      l_drop_ship_flag,
	      l_po_org_id,
	      l_rcv_organization_id,
	      l_item_id,
	      l_category_id,
	      l_project_id,
	      l_accrual_flag,
              l_po_document_type_code,
              /* Support for Landed Cost Management */
	      l_lcm_flag
      FROM    po_headers                POH,
	      po_line_locations		POLL,
	      po_lines			POL,
              rcv_transactions          RT
      WHERE   RT.transaction_id 	= p_rcv_transaction_id
      AND     POH.po_header_id 		= RT.po_header_id
      AND     POLL.line_location_id 	= RT.po_line_location_id
      AND     POL.po_line_id 		= RT.po_line_id;

      l_stmt_num := 30;
   -- Get Receiving Operating Unit
      SELECT  operating_unit, ledger_id
      INTO    l_rcv_org_id, l_rcv_sob_id
      FROM    cst_acct_info_v
      WHERE   organization_id = l_rcv_organization_id;

      l_stmt_num := 35;
   -- Get PO SOB
      SELECT  set_of_books_id
      INTO    l_po_sob_id
      FROM    financials_system_parameters;



      l_stmt_num := 40;
      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         l_api_message := 'Creating Receive Events : RCV Transaction ID : ' || p_rcv_transaction_id ||
                          ', PO Header ID : ' || l_po_header_id ||
                          ', PO Line ID : ' || l_po_line_id ||
                          ', PO Line Location ID : ' || l_po_line_location_id ||
                          ', PO Dist ID : ' || l_po_distribution_id ||
                          ', Transaction Date : '|| l_rcv_trx_date ||
                          ', Drop Ship Flag : '|| l_drop_ship_flag ||
                          ', PO Org ID : ' || l_po_org_id ||
			  ', PO SOB ID : ' || l_po_sob_id ||
                          ', RCV Organization ID : '|| l_rcv_organization_id ||
                          ', RCV Org ID : '|| l_rcv_org_id ||
                          ', RCV SOB ID : ' || l_rcv_sob_id ||
                          ', Category ID : ' || l_category_id ||
                          ', Accrual Flag : ' || l_accrual_flag ;

         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
             ,l_api_message);
      END IF;

      IF(l_po_org_id = l_rcv_org_id) THEN
	l_cross_ou_flag := 'N';
      ELSE
        l_cross_ou_flag := 'Y';

        /* For 11i10, the only supported qualifier is category id. */
        l_qualifier_code_tbl(l_qualifier_code_tbl.count+1)  := INV_TRANSACTION_FLOW_PUB.G_QUALIFIER_CODE;
        l_qualifier_value_tbl(l_qualifier_value_tbl.count+1) := l_category_id;

        l_stmt_num := 50;
        IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
	   l_api_message := 'Getting Procurement Transaction Flow :'||
			    'l_po_org_id : '||l_po_org_id||
			    ' l_rcv_org_id : '||l_rcv_org_id||
			    ' l_rcv_organization_id : '||l_rcv_organization_id;

           FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
             ,l_api_message);
        END IF;

        INV_TRANSACTION_FLOW_PUB.GET_TRANSACTION_FLOW(
                x_return_status         => l_return_status,
                x_msg_data              => l_msg_data,
                x_msg_count             => l_msg_count,
                x_transaction_flows_tbl => l_transaction_flows_tbl,
                p_api_version           => 1.0,
                p_start_operating_unit  => l_po_org_id,
                p_end_operating_unit    => l_rcv_org_id,
                p_flow_type             => INV_TRANSACTION_FLOW_PUB.G_PROCURING_FLOW_TYPE,
                p_organization_id       => l_rcv_organization_id,
                p_qualifier_code_tbl    => l_qualifier_code_tbl,
                p_qualifier_value_tbl   => l_qualifier_value_tbl,
                p_transaction_date      => l_rcv_trx_date,
                p_get_default_cost_group=> 'N');

        IF (l_return_status = FND_API.g_ret_sts_success) THEN
           l_trx_flow_exists_flag := 1;
	   l_trx_flow_header_id   := l_transaction_flows_tbl(l_transaction_flows_tbl.FIRST).header_id;
           IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                      ,'Transaction Flow exists');
           END IF;

     -- Return Status of 'W' indicates that no transaction flow exists.
        ELSIF (l_return_status = 'W') THEN
	   l_trx_flow_exists_flag := 0;
           IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                      ,'Transaction Flow does not exist');
           END IF;

        -- If transaction flow does not exist, but the PO crosses multiple
	-- sets of books, error out the transaction.
	   IF(l_po_sob_id <> l_rcv_sob_id) THEN
              l_api_message := 'Transaction Flow does not exist';
              IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                 FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                                 ,'Create_ReceiveEvents : '||l_stmt_num||' : '||l_api_message);
              END IF;
              RAISE FND_API.g_exc_unexpected_error;
	   END IF;

        ELSE
           l_api_message := 'Error occurred in Transaction Flow API';
           IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                              ,'Create_ReceiveEvents : '||l_stmt_num||' : '||l_api_message);
           END IF;
           RAISE FND_API.g_exc_unexpected_error;
        END IF; -- IF l_return_status
      END IF; -- IF l_po_org_id


   -- For the receive transaction, the PO distribution may not be available in the
   -- case of Standard Receipt. Hence perform all steps for each applicable distribution.
   -- If distribution is not available the quantity will be prorated. Furthermore, if
   -- there is a project on any of the distributions, and the destination_type_code is
   -- expense, the transaction flow should be ignored for just that distribution.
      FOR rec_pod IN c_po_distributions_csr(l_po_distribution_id, l_po_line_location_id) LOOP

        l_stmt_num := 60;
        IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           l_api_message := 'Creating Receive Events : '||
			    'po_distribution_id : '||rec_pod.po_distribution_id||
			    ' destination_type_code : '||rec_pod.destination_type_code||
			    ' project_id : '||rec_pod.project_id;
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
             ,l_api_message);
        END IF;


        l_procurement_org_flag := 'Y';
-- Bug #5880899. PO does not support centralized procurement for Blankets.
     -- Call PO API to verify centralized procurement is supported for this document type.
	IF (l_trx_flow_exists_flag = 1) THEN
           l_stmt_num := 45;
           IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              l_api_message := 'Checking if this is a shared proc scenario :'||
                               ' l_po_document_type_code : '||l_po_document_type_code||
                               ' l_po_org_id : '||l_po_org_id||
                               ' l_rcv_org_id : '||l_rcv_org_id||
                               ' l_rcv_organization_id : '||l_rcv_organization_id||
		               ' l_trx_flow_header_id : '||l_trx_flow_header_id;

              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                   ,l_api_message);
           END IF;

           PO_SHARED_PROC_GRP.check_shared_proc_scenario
           (
                p_api_version                =>1.0,
                p_init_msg_list              =>FND_API.G_FALSE,
                x_return_status              =>l_return_status,
                p_destination_type_code      =>rec_pod.destination_type_code,
                p_document_type_code         =>l_po_document_type_code,
                p_project_id                 =>rec_pod.project_id,
                p_purchasing_ou_id           =>l_po_org_id,
                p_ship_to_inv_org_id         =>l_rcv_organization_id,
                p_transaction_flow_header_id =>l_trx_flow_header_id,
                x_is_shared_proc_scenario    =>l_is_shared_proc
            );

            IF l_return_status <> FND_API.g_ret_sts_success THEN
               l_api_message := 'Error in API PO_SHARED_PROC_GRP.check_shared_proc_scenario';
               IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >=
FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                   FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                       ,'Create_ReceiveEvents : '||l_stmt_num||' : '||l_api_message);
               END IF;
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

   	    IF l_is_shared_proc IS NULL OR l_is_shared_proc = 'N' THEN
		l_is_shared_proc := 'N';
                l_trx_flow_exists_flag := 0;
                l_trx_flow_header_id := NULL;
	    END IF;

            IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
               l_api_message := 'Returned from check_shared_proc_scenario :'||
				' l_is_shared_proc :'|| l_is_shared_proc;
               FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                 ,l_api_message);
            END IF;
	END IF;


     -- For POs with destination type of expense, when there is a project on the
     -- POD, we should not look for transaction flow. This is because PA,(which transfers
     -- costs to Projects for expense destinations), is currently not supporting global
     -- procurement.
        IF((l_trx_flow_exists_flag = 1) AND
	   (rec_pod.project_id is NULL OR rec_pod.destination_type_code <> 'EXPENSE')AND
	   (l_is_shared_proc = 'Y')) THEN

        	l_trx_flow_ctr := l_transaction_flows_tbl.COUNT;

   	     -- Create Logical Receive transactions in each intermediate organization.
		FOR l_counter IN  l_transaction_flows_tbl.FIRST..l_transaction_flows_tbl.LAST LOOP

          	   IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
             	      FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                	   ,'Seeding Logical Receive in RAE');
          	   END IF;


		   l_stmt_num := 70;
	        -- l_transaction_forward_flow_rec contains the transaction flow record
	        -- where the org_id is the from_org_id.
	        -- l_transaction_reverse_flow_rec contains the transaction flow record
	        -- where the org_id is the to_org_id.
	        -- Need to pass both to the Seed_RAE procedure because transfer_price is based
	        -- on the reverse flow record and some accounts are based on the forward flow

		   l_transaction_forward_flow_rec := l_transaction_flows_tbl(l_counter);
		   IF(l_counter = l_transaction_flows_tbl.FIRST) THEN
		     l_transaction_reverse_flow_rec := NULL;
		     l_transfer_org_id		    := NULL;
		     l_transfer_organization_id	    := NULL;
		   ELSE
                     l_transaction_reverse_flow_rec := l_transaction_flows_tbl(l_counter - 1);
		     l_transfer_org_id		    := l_transaction_reverse_flow_rec.from_org_id;
		     l_transfer_organization_id	    := l_transaction_reverse_flow_rec.from_organization_id;
		   END IF;


		   l_stmt_num := 80;
		   RCV_SeedEvents_PVT.Seed_RAEEvent(
			p_api_version           => 1.0,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        x_msg_data              => l_msg_data,
			p_event_source		=> 'RECEIVING',
		 	p_event_type_id		=> RCV_SeedEvents_PVT.LOGICAL_RECEIVE,
                        p_rcv_transaction_id    => p_rcv_transaction_id,
			p_inv_distribution_id	=> NULL,
			p_po_distribution_id	=> rec_pod.po_distribution_id,
                        p_direct_delivery_flag  => p_direct_delivery_flag,
			p_cross_ou_flag		=> l_cross_ou_flag,
		  	p_procurement_org_flag	=> l_procurement_org_flag,
                  	p_ship_to_org_flag      => 'N',
			p_drop_ship_flag	=> l_drop_ship_flag,
		   	p_org_id		=> l_transaction_flows_tbl(l_counter).from_org_id,
			p_organization_id	=> l_transaction_flows_tbl(l_counter).from_organization_id,
                  	p_transfer_org_id       => l_transfer_org_id,
			p_transfer_organization_id => l_transfer_organization_id,
                  	p_trx_flow_header_id    => l_trx_flow_header_id,
			p_transaction_forward_flow_rec  => l_transaction_forward_flow_rec,
			p_transaction_reverse_flow_rec 	=> l_transaction_reverse_flow_rec,
			p_unit_price		=> NULL,
			p_prior_unit_price	=> NULL,
                        /* Support for Landed Cost Management */
                        p_lcm_flag              => l_lcm_flag,
			x_rcv_event		=> l_rcv_event);

      		   IF l_return_status <> FND_API.g_ret_sts_success THEN
        		l_api_message := 'Error creating event';
        		IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            		    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                		,'Create_ReceiveEvents : '||l_stmt_num||' : '||l_api_message);
        		END IF;
        		RAISE FND_API.g_exc_unexpected_error;
      		   END IF;

		   l_rcv_events_tbl(l_rcv_events_tbl.count + 1) := l_rcv_event;

	        -- For one-time items, if online accruals is used, seed IC Invoice event.
	   	-- For Shop Floor destination types, always seed IC Invoice events.
		   IF((l_item_id is NULL and l_accrual_flag = 'Y') OR
		      (rec_pod.destination_type_code = 'SHOP FLOOR')) THEN
                      l_stmt_num := 90;
                      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                         FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                              ,'Seeding Invoice Match in RAE');
                      END IF;

                      RCV_SeedEvents_PVT.Seed_RAEEvent(
                           p_api_version           => 1.0,
                           x_return_status         => l_return_status,
                           x_msg_count             => l_msg_count,
                           x_msg_data              => l_msg_data,
                           p_event_source          => 'RECEIVING',
                           p_event_type_id         => RCV_SeedEvents_PVT.INTERCOMPANY_INVOICE,
                           p_rcv_transaction_id    => p_rcv_transaction_id,
                           p_inv_distribution_id   => NULL,
                           p_po_distribution_id    => rec_pod.po_distribution_id,
                           p_direct_delivery_flag   => p_direct_delivery_flag,
                           p_cross_ou_flag         => l_cross_ou_flag,
                           p_procurement_org_flag  => l_procurement_org_flag,
                           p_ship_to_org_flag      => 'N',
                           p_drop_ship_flag        => l_drop_ship_flag,
                           p_org_id                => l_transaction_flows_tbl(l_counter).from_org_id,
                  	   p_organization_id       => l_transaction_flows_tbl(l_counter).from_organization_id,
                  	   p_transfer_org_id       => l_transaction_flows_tbl(l_counter).to_org_id,
                  	   p_transfer_organization_id => l_transaction_flows_tbl(l_counter).to_organization_id,
                           p_trx_flow_header_id    => l_trx_flow_header_id,
                           p_transaction_forward_flow_rec  => l_transaction_forward_flow_rec,
                           p_transaction_reverse_flow_rec  => l_transaction_reverse_flow_rec,
                           p_unit_price            => NULL,
                           p_prior_unit_price      => NULL,
                          /* Support for Landed Cost Management */
                           p_lcm_flag              => l_lcm_flag,
                           x_rcv_event             => l_rcv_event);

                      IF l_return_status <> FND_API.g_ret_sts_success THEN
                         l_api_message := 'Error creating event';
                         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                             FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                                 ,'Create_ReceiveEvents : '||l_stmt_num||' : '||l_api_message);
                         END IF;
                         RAISE FND_API.g_exc_unexpected_error;
                      END IF;

                      l_rcv_events_tbl(l_rcv_events_tbl.count + 1) := l_rcv_event;
		   END IF;

		   l_procurement_org_flag := 'N';
		END LOOP;
        END IF;

	l_stmt_num := 100;
        IF (l_trx_flow_exists_flag = 1) THEN
           l_transaction_forward_flow_rec := NULL;
           l_transaction_reverse_flow_rec := l_transaction_flows_tbl(l_trx_flow_ctr);
           l_org_id 			  := l_transaction_flows_tbl(l_trx_flow_ctr).to_org_id;
	   l_transfer_org_id		  := l_transaction_flows_tbl(l_trx_flow_ctr).from_org_id;
	   l_transfer_organization_id 	  := l_transaction_reverse_flow_rec.from_organization_id;
        ELSE
           l_transaction_forward_flow_rec := NULL;
           l_transaction_reverse_flow_rec := NULL;
           l_org_id 			  := l_po_org_id;
	   l_transfer_org_id              := NULL;
	   l_transfer_organization_id     := NULL;
        END IF;

        l_stmt_num := 110;

     -- If drop ship flag is 1(drop ship with new accounting) OR 2(drop ship with old accounting),
     -- then create a LOGICAL RECEIVE and use the clearing account. It drop ship flag is 3 (not a
     -- drop ship), then create a RECEIVE event
        IF (l_drop_ship_flag IN (1,2)) THEN
        -- This is a pure (external) drop ship scenario. Seed a LOGICAL_RECEIVE event in the receiving org.
           IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                   ,'Drop Ship : Seeding Logical Receive in RAE');
           END IF;

	   l_stmt_num := 120;
           RCV_SeedEvents_PVT.Seed_RAEEvent(
                  p_api_version           => 1.0,
                  x_return_status         => l_return_status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data,
                  p_event_source          => 'RECEIVING',
                  p_event_type_id         => RCV_SeedEvents_PVT.LOGICAL_RECEIVE,
                  p_rcv_transaction_id    => p_rcv_transaction_id,
		  p_inv_distribution_id	  => NULL,
                  p_po_distribution_id    => rec_pod.po_distribution_id,
                  p_direct_delivery_flag   => p_direct_delivery_flag,
                  p_cross_ou_flag         => l_cross_ou_flag,
                  p_procurement_org_flag  => l_procurement_org_flag,
                  p_ship_to_org_flag      => 'Y',
		  p_drop_ship_flag	  => l_drop_ship_flag,
                  p_org_id                => l_org_id,
                  p_organization_id       => l_rcv_organization_id,
                  p_transfer_org_id       => l_transfer_org_id,
                  p_transfer_organization_id => l_transfer_organization_id,
                  p_trx_flow_header_id    => l_trx_flow_header_id,
                  p_transaction_forward_flow_rec  => l_transaction_forward_flow_rec,
                  p_transaction_reverse_flow_rec  => l_transaction_reverse_flow_rec,
                  p_unit_price            => NULL,
                  p_prior_unit_price      => NULL,
                  /* Support for Landed Cost Management */
                  p_lcm_flag              => l_lcm_flag,
                  x_rcv_event             => l_rcv_event);
           IF l_return_status <> FND_API.g_ret_sts_success THEN
              l_api_message := 'Error creating event';
              IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                    ,'Create_ReceiveEvents : '||l_stmt_num||' : '||l_api_message);
              END IF;
              RAISE FND_API.g_exc_unexpected_error;
           END IF;

	   l_rcv_events_tbl(l_rcv_events_tbl.count + 1) := l_rcv_event;

        ELSE

	   l_stmt_num := 130;
	   SELECT decode(RT.transaction_type,'CORRECT',RCV_SeedEvents_PVT.CORRECT,
				RCV_SeedEvents_PVT.RECEIVE)
	   INTO   l_event_type_id
	   FROM   rcv_Transactions RT
	   WHERE  transaction_id = p_rcv_transaction_id;

           IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                   ,'Not Drop Ship : Seeding Receive in RAE');
           END IF;

           l_stmt_num := 140;
           RCV_SeedEvents_PVT.Seed_RAEEvent(
                  p_api_version           => 1.0,
                  x_return_status         => l_return_status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data,
                  p_event_source          => 'RECEIVING',
                  p_event_type_id         => l_event_type_id,
                  p_rcv_transaction_id    => p_rcv_transaction_id,
		  p_inv_distribution_id   => NULL,
                  p_po_distribution_id    => rec_pod.po_distribution_id,
                  p_direct_delivery_flag  => p_direct_delivery_flag,
                  p_cross_ou_flag         => l_cross_ou_flag,
                  p_procurement_org_flag  => l_procurement_org_flag,
                  p_ship_to_org_flag      => 'Y',
		  p_drop_ship_flag	  => l_drop_ship_flag,
                  p_org_id                => l_org_id,
                  p_organization_id       => l_rcv_organization_id,
                  p_transfer_org_id       => l_transfer_org_id,
                  p_transfer_organization_id => l_transfer_organization_id,
                  p_trx_flow_header_id    => l_trx_flow_header_id,
                  p_transaction_forward_flow_rec  => l_transaction_forward_flow_rec,
                  p_transaction_reverse_flow_rec  => l_transaction_reverse_flow_rec,
                  p_unit_price            => NULL,
                  p_prior_unit_price      => NULL,
                  /* Support for Landed Cost Management */
                  p_lcm_flag              => l_lcm_flag,
                  x_rcv_event             => l_rcv_event);
           IF l_return_status <> FND_API.g_ret_sts_success THEN
            l_api_message := 'Error creating event';
            IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                    ,'Create_ReceiveEvents : '||l_stmt_num||' : '||l_api_message);
            END IF;
            RAISE FND_API.g_exc_unexpected_error;
           END IF;

           l_rcv_events_tbl(l_rcv_events_tbl.count + 1) := l_rcv_event;

        END IF;
     END LOOP;

     l_stmt_num := 150;
     IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
              ,'Inserting events into RAE');
     END IF;
     RCV_SeedEvents_PVT.Insert_RAEEvents(
                  p_api_version           => 1.0,
                  x_return_status         => l_return_status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data,
		  p_rcv_events_tbl	  => l_rcv_events_tbl,
                  /* Support for Landed Cost Management */
                  p_lcm_flag              => l_lcm_flag);
      IF l_return_status <> FND_API.g_ret_sts_success THEN
         l_api_message := 'Error inserting events into RAE';
         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
             FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                 ,'Create_ReceiveEvents : '||l_stmt_num||' : '||l_api_message);
         END IF;
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

     IF(l_trx_flow_exists_flag = 1 AND l_item_id IS NOT NULL) THEN
        l_stmt_num := 160;
        IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                 ,'Inserting events into MMT');
        END IF;
        RCV_SeedEvents_PVT.Insert_MMTEvents(
                  p_api_version           => 1.0,
                  x_return_status         => l_return_status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data,
                  p_rcv_events_tbl        => l_rcv_events_tbl);
         IF l_return_status <> FND_API.g_ret_sts_success THEN
            l_api_message := 'Error inserting events into MMT';
            IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                    ,'Create_ReceiveEvents : '||l_stmt_num||' : '||l_api_message);
            END IF;
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
     END IF;


   --- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT WORK;
       END IF;

    -- Standard Call to get message count and if count = 1, get message info
       FND_MSG_PUB.Count_And_Get (
           p_count     => x_msg_count,
           p_data      => x_msg_data );

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.end'
             ,'Create_ReceiveEvents >>');
      END IF;

EXCEPTION
      WHEN FND_API.g_exc_error THEN
         ROLLBACK TO Create_ReceiveEvents_PVT;
         x_return_status := FND_API.g_ret_sts_error;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );
      WHEN FND_API.g_exc_unexpected_error THEN
         ROLLBACK TO Create_ReceiveEvents_PVT;
         x_return_status := FND_API.g_ret_sts_unexp_error ;
         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

      WHEN OTHERS THEN
         ROLLBACK TO Create_ReceiveEvents_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                ,'Create_ReceiveEvents : '||l_stmt_num||' : '||substr(SQLERRM,1,200));
         END IF;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
               FND_MSG_PUB.add_exc_msg
                 (  G_PKG_NAME,
                    l_api_name || 'Statement -'||to_char(l_stmt_num)
                 );
         END IF;
         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
            , p_data   => x_msg_data
           );

END Create_ReceiveEvents;



--      API name        : Create_DeliverEvents
--      Type            : Private
--      Function        : To seed accounting events for DELIVER transactions.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_rcv_transaction_id    IN NUMBER       Required
--                              p_direct_delivery_flag  IN VARCHAR2     Optional
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--
--
--      Notes           : This API creates all accounting events for DELIVER transactions
--                        in RCV_ACCOUNTING_EVENTS.
--
-- End of comments
-------------------------------------------------------------------------------
PROCEDURE Create_DeliverEvents(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2,
                p_commit                IN      VARCHAR2,
                p_validation_level      IN      NUMBER,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                p_rcv_transaction_id    IN NUMBER,
                p_direct_delivery_flag  IN VARCHAR2
) IS
   l_api_name   	CONSTANT VARCHAR2(30)   := 'Create_DeliverEvents';
   l_api_version        CONSTANT NUMBER         := 1.0;

   l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_msg_count           NUMBER := 0;
   l_msg_data            VARCHAR2(8000) := '';
   l_stmt_num            NUMBER := 0;
   l_api_message         VARCHAR2(1000);

   l_rcv_event           RCV_SeedEvents_PVT.rcv_event_rec_type;
   l_rcv_events_tbl      RCV_SeedEvents_PVT.rcv_event_tbl_type;
   l_event_type_id	 NUMBER;

   l_transaction_flows_tbl INV_TRANSACTION_FLOW_PUB.g_transaction_flow_tbl_type;
   l_transaction_reverse_flow_rec INV_TRANSACTION_FLOW_PUB.mtl_transaction_flow_rec_type := NULL;
   l_trx_flow_exists_flag NUMBER := 0;
   l_trx_flow_ctr       NUMBER := 0;

   l_po_header_id        NUMBER;
   l_po_distribution_id  NUMBER;
   l_po_org_id           NUMBER;
   l_po_sob_id           NUMBER;
   l_rcv_organization_id NUMBER;
   l_rcv_org_id          NUMBER;
   l_transfer_org_id     NUMBER 	:= NULL;
   l_transfer_organization_id NUMBER 	:= NULL;
   l_rcv_sob_id 	 NUMBER;
   l_rcv_trx_date        DATE;
   l_drop_ship_flag      NUMBER;
   l_destination_type    VARCHAR(25);
   l_category_id         NUMBER;
   l_project_id          NUMBER;
   l_cross_ou_flag       VARCHAR2(1) 	:= 'N';
   l_accrual_flag        VARCHAR2(1) 	:= 'N';
   l_procurement_org_flag VARCHAR2(1)	:= 'Y';
   l_trx_flow_header_id	 NUMBER;
   l_qualifier_code_tbl INV_TRANSACTION_FLOW_PUB.NUMBER_TBL;
   l_qualifier_value_tbl INV_TRANSACTION_FLOW_PUB.NUMBER_TBL;
   l_encumbrance_flag	VARCHAR2(1);
   l_ussgl_option	VARCHAR2(1);
   l_po_document_type_code PO_HEADERS_ALL.type_lookup_code%TYPE;
   l_is_shared_proc      VARCHAR2(1);
   /* Support for Landed Cost Management */
   l_lcm_flag            VARCHAR2(1);

BEGIN
   -- Standard start of API savepoint
      SAVEPOINT Create_DeliverEvents_PVT;

      l_stmt_num := 0;

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.begin'
             ,'Create_DeliverEvents <<');
      END IF;

   -- Standard call to check for call compatibility
      IF NOT FND_API.Compatible_API_Call (
                        l_api_version,
                        p_api_version,
                        l_api_name,
                        G_PKG_NAME ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE
      IF FND_API.to_Boolean(p_init_msg_list) THEN
           FND_MSG_PUB.initialize;
      END IF;

   -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Unlike for Receive transactions, for Deliver transactions, the po_distribution_id
   -- is always available.
      l_stmt_num := 20;
      SELECT
              RT.po_header_id,
              RT.po_distribution_id,
              POD.destination_type_code,
              RT.transaction_date,
              nvl(RT.dropship_type_code,3),
              POH.org_id,
              POLL.ship_to_organization_id,
              POL.category_id,
              POL.project_id,
              nvl(POLL.accrue_on_receipt_flag,'N'),
              POH.type_lookup_code,
              /* Support for Landed Cost Management */
              NVL(POLL.lcm_flag,'N')
      INTO    l_po_header_id,
              l_po_distribution_id,
              l_destination_type,
              l_rcv_trx_date,
              l_drop_ship_flag,
              l_po_org_id,
              l_rcv_organization_id,
              l_category_id,
              l_project_id,
              l_accrual_flag,
              l_po_document_type_code,
              /* Support for Landed Cost Management */
              l_lcm_flag
      FROM    po_headers                POH,
              po_line_locations         POLL,
              po_lines                  POL,
              po_distributions          POD,
              rcv_transactions          RT
      WHERE   RT.transaction_id         = p_rcv_transaction_id
      AND     POH.po_header_id          = RT.po_header_id
      AND     POLL.line_location_id     = RT.po_line_location_id
      AND     POL.po_line_id            = RT.po_line_id
      AND     POD.po_distribution_id    = RT.po_distribution_id;

      l_stmt_num := 30;

   -- Get Receiving Operating Unit and SOB
      SELECT  operating_unit, ledger_id
      INTO    l_rcv_org_id, l_rcv_sob_id
      FROM    cst_acct_info_v
      WHERE   organization_id = l_rcv_organization_id;

      l_stmt_num := 35;
   -- Get PO SOB
      SELECT  set_of_books_id
      INTO    l_po_sob_id
      FROM    financials_system_parameters;

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         l_api_message := 'Creating Deliver Events : RCV Transaction ID : ' || p_rcv_transaction_id ||
                          ', PO Header ID : ' || l_po_header_id ||
                          ', PO Dist ID : ' || l_po_distribution_id ||
                          ', Destination Type : '|| l_destination_type ||
                          ', Transaction Date : '|| l_rcv_trx_date ||
                          ', Drop Ship Flag : '|| l_drop_ship_flag ||
                          ', PO Org ID : ' || l_po_org_id ||
                          ', RCV Organization ID : '|| l_rcv_organization_id ||
                          ', RCV Org ID : '|| l_rcv_org_id ||
                          ', Project ID : '|| l_project_id ||
                          ', Category ID : ' || l_category_id ||
                         ', Accrual Flag : ' || l_accrual_flag ;

         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
             ,l_api_message);
      END IF;

   -- Only create events for Deliver transactions for expense destination types. Other
   -- destination types do not have any accounting implications in the Receiving sub-ledger.
      IF (l_destination_type <> 'EXPENSE') THEN
	return;
      END IF;

      IF(l_po_org_id <> l_rcv_org_id) THEN
	l_cross_ou_flag := 'Y';
      END IF;

   -- Get transaction flow when procuring and receiving operating units are different.
   -- However, for POs with destination type of expense, when there is a project on the
   -- PO, we should not look for transaction flow. This is because PA,(which transfers
   -- costs to Projects for expense destinations), is currently not supporting global
   -- procurement.
      IF(l_cross_ou_flag = 'Y' AND l_project_id is NULL) THEN

          /* For 11i10, the only supported qualifier is category id. */
          l_qualifier_code_tbl(l_qualifier_code_tbl.count+1)  := INV_TRANSACTION_FLOW_PUB.G_QUALIFIER_CODE;
          l_qualifier_value_tbl(l_qualifier_value_tbl.count+1) := l_category_id;

          IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
             l_api_message := 'Getting Procurement Transaction Flow :'||
                              'l_po_org_id : '||l_po_org_id||
                              ' l_rcv_org_id : '||l_rcv_org_id||
                              ' l_rcv_organization_id : '||l_rcv_organization_id;

             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
               ,l_api_message);
          END IF;


          INV_TRANSACTION_FLOW_PUB.GET_TRANSACTION_FLOW(
                x_return_status         => l_return_status,
                x_msg_data              => l_msg_data,
                x_msg_count             => l_msg_count,
                x_transaction_flows_tbl => l_transaction_flows_tbl,
                p_api_version           => 1.0,
                p_start_operating_unit  => l_po_org_id,
                p_end_operating_unit    => l_rcv_org_id,
                p_flow_type             => INV_TRANSACTION_FLOW_PUB.G_PROCURING_FLOW_TYPE,
                p_organization_id       => l_rcv_organization_id,
                p_qualifier_code_tbl    => l_qualifier_code_tbl,
                p_qualifier_value_tbl   => l_qualifier_value_tbl,
                p_transaction_date      => l_rcv_trx_date,
                p_get_default_cost_group=> 'N');
           IF (l_return_status = FND_API.g_ret_sts_success) THEN
		l_procurement_org_flag 		:= 'N';
                l_trx_flow_exists_flag 		:= 1;
		l_trx_flow_header_id 		:= l_transaction_flows_tbl(l_transaction_flows_tbl.FIRST).header_id;
                l_trx_flow_ctr 			:= l_transaction_flows_tbl.COUNT;
		l_transaction_reverse_flow_rec  := l_transaction_flows_tbl(l_trx_flow_ctr);
		l_transfer_org_id 		:= l_transaction_reverse_flow_rec.from_org_id;
		l_transfer_organization_id	:= l_transaction_reverse_flow_rec.from_organization_id;


	   -- Bug #5880899. PO does not support centralized procurement for Blankets.
        -- Call PO API to verify centralized procurement is supported for this document type.
           l_stmt_num := 45;
           IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              l_api_message := 'Checking if this is a shared proc scenario :'||
                               ' l_po_document_type_code : '||l_po_document_type_code||
                               ' l_po_org_id : '||l_po_org_id||
                               ' l_rcv_org_id : '||l_rcv_org_id||
                               ' l_rcv_organization_id : '||l_rcv_organization_id||
                               ' l_trx_flow_header_id : '||l_trx_flow_header_id;

              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                   ,l_api_message);
           END IF;

           PO_SHARED_PROC_GRP.check_shared_proc_scenario
           (
                p_api_version                =>1.0,
                p_init_msg_list              =>FND_API.G_FALSE,
                x_return_status              =>l_return_status,
                p_destination_type_code      =>l_destination_type,
                p_document_type_code         =>l_po_document_type_code,
                p_project_id                 =>l_project_id,
                p_purchasing_ou_id           =>l_po_org_id,
                p_ship_to_inv_org_id         =>l_rcv_organization_id,
                p_transaction_flow_header_id =>l_trx_flow_header_id,
                x_is_shared_proc_scenario    =>l_is_shared_proc
            );

            IF l_return_status <> FND_API.g_ret_sts_success THEN
               l_api_message := 'Error in API PO_SHARED_PROC_GRP.check_shared_proc_scenario';
               IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                   FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                       ,'Create_ReceiveEvents : '||l_stmt_num||' : '||l_api_message);
               END IF;
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

            IF l_is_shared_proc IS NULL OR l_is_shared_proc = 'N' THEN
                l_is_shared_proc := 'N';
		l_trx_flow_exists_flag := 0;
		l_trx_flow_header_id := NULL;
            END IF;

            IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
               l_api_message := 'Returned from check_shared_proc_scenario :'||
                                ' l_is_shared_proc :'|| l_is_shared_proc;
               FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                 ,l_api_message);
            END IF;















	   ELSIF (l_return_status = 'W') THEN
		l_trx_flow_exists_flag := 0;
                IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                   FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                           ,'Transaction Flow does not exist');
                END IF;

             -- If transaction flow does not exist, but the PO crosses multiple
             -- sets of books, error out the transaction.
                IF(l_po_sob_id <> l_rcv_sob_id) THEN
                   l_api_message := 'Transaction Flow does not exist';
                   IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                                      ,'Create_DeliverEvents : '||l_stmt_num||' : '||l_api_message);
                   END IF;
                   RAISE FND_API.g_exc_unexpected_error;
                END IF;

	   ELSE
                l_api_message := 'Error occurred in Transaction Flow API';
                IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                   FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                              ,'Create_DeliverEvents : '||l_stmt_num||' : '||l_api_message);
                END IF;
                RAISE FND_API.g_exc_unexpected_error;
           END IF;
	END IF;

	l_stmt_num := 50;
        SELECT decode(RT.transaction_type,'CORRECT',RCV_SeedEvents_PVT.CORRECT,
                                RCV_SeedEvents_PVT.DELIVER)
        INTO   l_event_type_id
        FROM   rcv_Transactions RT
        WHERE  transaction_id = p_rcv_transaction_id;

        l_stmt_num := 60;
	IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
             FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                ,'Seeding Deliver Event');
        END IF;

	RCV_SeedEvents_PVT.Seed_RAEEvent(
           p_api_version           => 1.0,
           x_return_status         => l_return_status,
           x_msg_count             => l_msg_count,
           x_msg_data              => l_msg_data,
           p_event_source          => 'RECEIVING',
           p_event_type_id         => l_event_type_id,
           p_rcv_transaction_id    => p_rcv_transaction_id,
           p_inv_distribution_id   => NULL,
           p_po_distribution_id    => l_po_distribution_id,
           p_direct_delivery_flag  => p_direct_delivery_flag,
           p_cross_ou_flag         => l_cross_ou_flag,
           p_procurement_org_flag  => l_procurement_org_flag,
           p_ship_to_org_flag      => 'Y',
           p_drop_ship_flag        => l_drop_ship_flag,
           p_org_id                => l_rcv_org_id,
           p_organization_id       => l_rcv_organization_id,
           p_transfer_org_id       => l_transfer_org_id,
           p_transfer_organization_id => l_transfer_organization_id,
	   p_trx_flow_header_id	   => l_trx_flow_header_id,
           p_transaction_forward_flow_rec  => NULL,
           p_transaction_reverse_flow_rec  => l_transaction_reverse_flow_rec,
           p_unit_price            => NULL,
           p_prior_unit_price      => NULL,
           /* Support for Landed Cost Management */
           p_lcm_flag              => l_lcm_flag,
           x_rcv_event             => l_rcv_event);

        IF l_return_status <> FND_API.g_ret_sts_success THEN
           l_api_message := 'Error creating event';
           IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
               FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                   ,'Create_DeliverEvents : '||l_stmt_num||' : '||l_api_message);
           END IF;
           RAISE FND_API.g_exc_unexpected_error;
        END IF;
        l_rcv_events_tbl(l_rcv_events_tbl.count + 1) := l_rcv_event;

   -- Encumbrance cannot be enabled for global procurement scenarios.
      IF l_trx_flow_exists_flag = 0 THEN
         l_stmt_num := 70;
         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                 ,'Checking if encumbrance events need to be seeded.');
         END IF;
         RCV_SeedEvents_PVT.Check_EncumbranceFlag(
                  p_api_version           => 1.0,
                  x_return_status         => l_return_status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data,
                  p_rcv_sob_id        	  => l_rcv_sob_id,
		  x_encumbrance_flag	  => l_encumbrance_flag,
		  x_ussgl_option	  => l_ussgl_option);
         IF l_return_status <> FND_API.g_ret_sts_success THEN
            l_api_message := 'Error in checking for encumbrance flag ';
            IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                    ,'Create_DeliverEvents : '||l_stmt_num||' : '||l_api_message);
            END IF;
            RAISE FND_API.g_exc_unexpected_error;
         END IF;

         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
	    l_api_message := 'Encumbrance Flag : '||l_encumbrance_flag;
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                   ,l_api_message);
         END IF;

         IF(l_encumbrance_flag = 'Y') THEN
           l_stmt_num := 80;
           IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                   ,'Seeding Encumbrance Reversal Event');
             END IF;


           RCV_SeedEvents_PVT.Seed_RAEEvent(
              p_api_version           => 1.0,
              x_return_status         => l_return_status,
              x_msg_count             => l_msg_count,
              x_msg_data              => l_msg_data,
              p_event_source          => 'RECEIVING',
              p_event_type_id         => RCV_SeedEvents_PVT.ENCUMBRANCE_REVERSAL,
              p_rcv_transaction_id    => p_rcv_transaction_id,
              p_inv_distribution_id   => NULL,
              p_po_distribution_id    => l_po_distribution_id,
              p_direct_delivery_flag  => p_direct_delivery_flag,
              p_cross_ou_flag         => l_cross_ou_flag,
              p_procurement_org_flag  => l_procurement_org_flag,
              p_ship_to_org_flag      => 'Y',
              p_drop_ship_flag        => l_drop_ship_flag,
              p_org_id                => l_rcv_org_id,
              p_organization_id       => l_rcv_organization_id,
              p_transfer_org_id       => NULL,
              p_transfer_organization_id => NULL,
              p_transaction_forward_flow_rec  => NULL,
              p_transaction_reverse_flow_rec  => l_transaction_reverse_flow_rec,
              p_unit_price            => NULL,
              p_prior_unit_price      => NULL,
              /* Support for Landed Cost Management */
              p_lcm_flag              => l_lcm_flag,
              x_rcv_event             => l_rcv_event);


	   /* Bug #3333610. In the case of encumbrance reversals, the quantity to unencumber
	      may turn out to be zero if the quantity delivered is greater than the quantity
	      ordered. In such a situation, we should not error out the event. */
	   IF l_return_status = FND_API.g_ret_sts_success THEN
              l_rcv_events_tbl(l_rcv_events_tbl.count + 1) := l_rcv_event;
	   ELSIF l_return_status <> 'W' THEN
              l_api_message := 'Error in seeding encumbrance reversal event';
              IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                      ,'Create_DeliverEvents : '||l_stmt_num||' : '||l_api_message);
              END IF;
              RAISE FND_API.g_exc_unexpected_error;
           END IF;
         END IF;
      END IF;

      l_stmt_num := 90;
      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
              ,'Inserting events into RAE');
      END IF;
      RCV_SeedEvents_PVT.Insert_RAEEvents(
                  p_api_version           => 1.0,
                  x_return_status         => l_return_status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data,
                  p_rcv_events_tbl        => l_rcv_events_tbl,
                  /* Support for Landed Cost Management */
                  p_lcm_flag              => l_lcm_flag);
      IF l_return_status <> FND_API.g_ret_sts_success THEN
         l_api_message := 'Error inserting events into RAE';
         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
             FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                 ,'Create_DeliverEvents : '||l_stmt_num||' : '||l_api_message);
         END IF;
         RAISE FND_API.g_exc_unexpected_error;
      END IF;



   --- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT WORK;
       END IF;

    -- Standard Call to get message count and if count = 1, get message info
       FND_MSG_PUB.Count_And_Get (
           p_count     => x_msg_count,
           p_data      => x_msg_data );

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.end'
             ,'Create_DeliverEvents >>');
      END IF;


EXCEPTION
      WHEN FND_API.g_exc_error THEN
         ROLLBACK TO Create_DeliverEvents_PVT;
         x_return_status := FND_API.g_ret_sts_error;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );
      WHEN FND_API.g_exc_unexpected_error THEN
         ROLLBACK TO Create_DeliverEvents_PVT;
         x_return_status := FND_API.g_ret_sts_unexp_error ;
         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

      WHEN OTHERS THEN
         ROLLBACK TO Create_DeliverEvents_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                ,'Create_DeliverEvents : '||l_stmt_num||' : '||substr(SQLERRM,1,200));
         END IF;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
               FND_MSG_PUB.add_exc_msg
                 (  G_PKG_NAME,
                    l_api_name || 'Statement -'||to_char(l_stmt_num)
                 );
         END IF;
         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
            , p_data   => x_msg_data
           );

END Create_DeliverEvents;


-- Start of comments
--      API name        : Create_RTREvents
--      Type            : Private
--      Function        : To seed accounting events for RETURN TO RECEIVING transactions.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_rcv_transaction_id    IN NUMBER       Required
--                              p_direct_delivery_flag  IN VARCHAR2     Optional
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--
--
--      Notes           : This API creates all accounting events for RETURN TO RECEIVING transactions
--                        in RCV_ACCOUNTING_EVENTS.
--
-- End of comments
PROCEDURE Create_RTREvents(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2,
                p_commit                IN      VARCHAR2,
                p_validation_level      IN      NUMBER,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                p_rcv_transaction_id    IN NUMBER,
                p_direct_delivery_flag  IN VARCHAR2
) IS
   l_api_name   	CONSTANT VARCHAR2(30)   := 'Create_RTREvents';
   l_api_version        CONSTANT NUMBER         := 1.0;

   l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_msg_count           NUMBER := 0;
   l_msg_data            VARCHAR2(8000) := '';
   l_stmt_num            NUMBER := 0;
   l_api_message         VARCHAR2(1000);

   l_rcv_event           RCV_SeedEvents_PVT.rcv_event_rec_type;
   l_rcv_events_tbl      RCV_SeedEvents_PVT.rcv_event_tbl_type;
   l_event_type_id	 NUMBER;

   l_transaction_flows_tbl INV_TRANSACTION_FLOW_PUB.g_transaction_flow_tbl_type;
   l_transaction_reverse_flow_rec INV_TRANSACTION_FLOW_PUB.mtl_transaction_flow_rec_type := NULL;
   l_trx_flow_exists_flag NUMBER := 0;
   l_trx_flow_ctr       NUMBER := 0;

   l_po_header_id        NUMBER;
   l_po_distribution_id  NUMBER;
   l_po_org_id           NUMBER;
   l_po_sob_id           NUMBER;
   l_rcv_organization_id NUMBER;
   l_rcv_org_id          NUMBER;
   l_transfer_org_id     NUMBER         := NULL;
   l_transfer_organization_id NUMBER    := NULL;
   l_rcv_sob_id 	 NUMBER;
   l_rcv_trx_date        DATE;
   l_drop_ship_flag      NUMBER;
   l_destination_type    VARCHAR(25);
   l_category_id         NUMBER;
   l_project_id          NUMBER;
   l_cross_ou_flag       VARCHAR2(1) := 'N';
   l_accrual_flag        VARCHAR2(1) := 'N';
   l_procurement_org_flag VARCHAR2(1) := 'Y';
   l_trx_flow_header_id	 NUMBER;
   l_qualifier_code_tbl  INV_TRANSACTION_FLOW_PUB.NUMBER_TBL;
   l_qualifier_value_tbl INV_TRANSACTION_FLOW_PUB.NUMBER_TBL;
   l_encumbrance_flag    VARCHAR2(1);
   l_ussgl_option	 VARCHAR2(1);
   l_po_document_type_code PO_HEADERS_ALL.type_lookup_code%TYPE;
   l_is_shared_proc      VARCHAR2(1);
   /* Support for Landed Cost Management */
   l_lcm_flag            VARCHAR2(1);
BEGIN
   -- Standard start of API savepoint
      SAVEPOINT Create_RTREvents_PVT;

      l_stmt_num := 0;

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.begin'
             ,'Create_RTREvents <<');
      END IF;

   -- Standard call to check for call compatibility
      IF NOT FND_API.Compatible_API_Call (
                        l_api_version,
                        p_api_version,
                        l_api_name,
                        G_PKG_NAME ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE
      IF FND_API.to_Boolean(p_init_msg_list) THEN
           FND_MSG_PUB.initialize;
      END IF;

   -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Unlike for RTV transactions, for RTR transactions, the po_distribution_id
   -- is always available.
      l_stmt_num := 20;
      SELECT
              RT.po_header_id,
              RT.po_distribution_id,
              POD.destination_type_code,
              RT.transaction_date,
              nvl(RT.dropship_type_code,3),
              POH.org_id,
              POLL.ship_to_organization_id,
              POL.category_id,
              POL.project_id,
              nvl(POLL.accrue_on_receipt_flag,'N'),
              POH.type_lookup_code,
              /* Support for Landed Cost Management */
	      nvl(POLL.lcm_flag, 'N')
      INTO    l_po_header_id,
              l_po_distribution_id,
              l_destination_type,
              l_rcv_trx_date,
              l_drop_ship_flag,
              l_po_org_id,
              l_rcv_organization_id,
              l_category_id,
              l_project_id,
              l_accrual_flag,
              l_po_document_type_code,
              /* Support for Landed Cost Management */
              l_lcm_flag
      FROM    po_headers                POH,
              po_line_locations         POLL,
              po_lines                  POL,
              po_distributions          POD,
              rcv_transactions          RT
      WHERE   RT.transaction_id         = p_rcv_transaction_id
      AND     POH.po_header_id          = RT.po_header_id
      AND     POLL.line_location_id     = RT.po_line_location_id
      AND     POL.po_line_id            = RT.po_line_id
      AND     POD.po_distribution_id    = RT.po_distribution_id;

      l_stmt_num := 30;

   -- Get Receiving Operating Unit and SOB
      SELECT  operating_unit, ledger_id
      INTO    l_rcv_org_id, l_rcv_sob_id
      FROM    cst_acct_info_v
      WHERE   organization_id = l_rcv_organization_id;

      l_stmt_num := 35;
   -- Get PO SOB
      SELECT  set_of_books_id
      INTO    l_po_sob_id
      FROM    financials_system_parameters;


      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         l_api_message := 'Creating RTR Events : RCV Transaction ID : ' || p_rcv_transaction_id ||
                          ', PO Header ID : ' || l_po_header_id ||
                          ', PO Dist ID : ' || l_po_distribution_id ||
                          ', Destination Type : '|| l_destination_type ||
                          ', Transaction Date : '|| l_rcv_trx_date ||
                          ', Drop Ship Flag : '|| l_drop_ship_flag ||
                          ', PO Org ID : ' || l_po_org_id ||
			  ', PO SOB ID : ' || l_po_sob_id ||
                          ', RCV Organization ID : '|| l_rcv_organization_id ||
                          ', RCV Org ID : '|| l_rcv_org_id ||
                          ', RCV SOB ID : ' || l_rcv_sob_id ||
                          ', Project ID : '|| l_project_id ||
                          ', Category ID : ' || l_category_id ||
                         ', Accrual Flag : ' || l_accrual_flag ;

         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
             ,l_api_message);
      END IF;

   -- Only create events for RTR transactions for expense destination types. Other
   -- destination types do not have any accounting implications in the Receiving sub-ledger.
      IF (l_destination_type <> 'EXPENSE') THEN
	return;
      END IF;

      IF(l_po_org_id <> l_rcv_org_id) THEN
	l_cross_ou_flag := 'Y';
      END IF;

   -- Get transaction flow when procuring and receiving operating units are different.
   -- However, for POs with destination type of expense, when there is a project on the
   -- PO, we should not look for transaction flow. This is because PA,(which transfers
   -- costs to Projects for expense destinations), is currently not supporting global
   -- procurement.
      IF(l_cross_ou_flag = 'Y' AND l_project_id is NULL) THEN

          /* For 11i10, the only supported qualifier is category id. */
          l_qualifier_code_tbl(l_qualifier_code_tbl.count+1)  := INV_TRANSACTION_FLOW_PUB.G_QUALIFIER_CODE;
          l_qualifier_value_tbl(l_qualifier_value_tbl.count+1) := l_category_id;

          l_stmt_num := 40;
          IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
             l_api_message := 'Getting Procurement Transaction Flow :'||
                              'l_po_org_id : '||l_po_org_id||
                              ' l_rcv_org_id : '||l_rcv_org_id||
                              ' l_rcv_organization_id : '||l_rcv_organization_id;

             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
               ,l_api_message);
          END IF;

          INV_TRANSACTION_FLOW_PUB.GET_TRANSACTION_FLOW(
                x_return_status         => l_return_status,
                x_msg_data              => l_msg_data,
                x_msg_count             => l_msg_count,
                x_transaction_flows_tbl => l_transaction_flows_tbl,
                p_api_version           => 1.0,
                p_start_operating_unit  => l_po_org_id,
                p_end_operating_unit    => l_rcv_org_id,
                p_flow_type             => INV_TRANSACTION_FLOW_PUB.G_PROCURING_FLOW_TYPE,
                p_organization_id       => l_rcv_organization_id,
                p_qualifier_code_tbl    => l_qualifier_code_tbl,
                p_qualifier_value_tbl   => l_qualifier_value_tbl,
                p_transaction_date      => l_rcv_trx_date,
                p_get_default_cost_group=> 'N');
           IF (l_return_status = FND_API.g_ret_sts_success) THEN
		l_procurement_org_flag := 'N';
                l_trx_flow_exists_flag := 1;
		l_trx_flow_header_id := l_transaction_flows_tbl(l_transaction_flows_tbl.FIRST).header_id;
                l_trx_flow_ctr := l_transaction_flows_tbl.COUNT;
		l_transaction_reverse_flow_rec := l_transaction_flows_tbl(l_trx_flow_ctr);
                l_transfer_org_id               := l_transaction_reverse_flow_rec.from_org_id;
                l_transfer_organization_id      := l_transaction_reverse_flow_rec.from_organization_id;



-- Bug #5880899. PO does not support centralized procurement for Blankets.
           -- Call PO API to verify centralized procurement is supported for this document type.
              l_stmt_num := 45;
              IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                 l_api_message := 'Checking if this is a shared proc scenario :'||
                                  ' l_po_document_type_code : '||l_po_document_type_code||
                                  ' l_po_org_id : '||l_po_org_id||
                                  ' l_rcv_org_id : '||l_rcv_org_id||
                                  ' l_rcv_organization_id : '||l_rcv_organization_id||
                                  ' l_trx_flow_header_id : '||l_trx_flow_header_id;

                 FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                      ,l_api_message);
              END IF;

              PO_SHARED_PROC_GRP.check_shared_proc_scenario
              (
                   p_api_version                =>1.0,
                   p_init_msg_list              =>FND_API.G_FALSE,
                   x_return_status              =>l_return_status,
                   p_destination_type_code      =>l_destination_type,
                   p_document_type_code         =>l_po_document_type_code,
                   p_project_id                 =>l_project_id,
                   p_purchasing_ou_id           =>l_po_org_id,
                   p_ship_to_inv_org_id         =>l_rcv_organization_id,
                   p_transaction_flow_header_id =>l_trx_flow_header_id,
                   x_is_shared_proc_scenario    =>l_is_shared_proc
               );

               IF l_return_status <> FND_API.g_ret_sts_success THEN
                  l_api_message := 'Error in API PO_SHARED_PROC_GRP.check_shared_proc_scenario';
                  IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                          ,'Create_ReceiveEvents : '||l_stmt_num||' : '||l_api_message);
                  END IF;
                  RAISE FND_API.g_exc_unexpected_error;
               END IF;

               IF l_is_shared_proc IS NULL OR l_is_shared_proc = 'N' THEN
                   l_is_shared_proc := 'N';
                   l_trx_flow_exists_flag := 0;
                   l_trx_flow_header_id := NULL;
               END IF;

               IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  l_api_message := 'Returned from check_shared_proc_scenario :'||
                                   ' l_is_shared_proc :'|| l_is_shared_proc;
                  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                    ,l_api_message);
               END IF;



	   ELSIF (l_return_status = 'W') THEN
		l_trx_flow_exists_flag := 0;
                IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                   FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                           ,'Transaction Flow does not exist');
                END IF;

             -- If transaction flow does not exist, but the PO crosses multiple
             -- sets of books, error out the transaction.
                IF(l_po_sob_id <> l_rcv_sob_id) THEN
                   l_api_message := 'Transaction Flow does not exist';
                   IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                                      ,'Create_RTREvents : '||l_stmt_num||' : '||l_api_message);
                   END IF;
                   RAISE FND_API.g_exc_unexpected_error;
                END IF;

	   ELSE
                l_api_message := 'Error occurred in Transaction Flow API';
                IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                   FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                              ,'Create_RTREvents : '||l_stmt_num||' : '||l_api_message);
                END IF;
                RAISE FND_API.g_exc_unexpected_error;
           END IF;
	END IF;

	l_stmt_num := 50;
        SELECT decode(RT.transaction_type,'CORRECT',RCV_SeedEvents_PVT.CORRECT,
                                RCV_SeedEvents_PVT.RETURN_TO_RECEIVING)
        INTO   l_event_type_id
        FROM   rcv_Transactions RT
        WHERE  transaction_id = p_rcv_transaction_id;

        l_stmt_num := 60;
	IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
             FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                ,'Seeding RTR Event');
        END IF;

	RCV_SeedEvents_PVT.Seed_RAEEvent(
           p_api_version           => 1.0,
           x_return_status         => l_return_status,
           x_msg_count             => l_msg_count,
           x_msg_data              => l_msg_data,
           p_event_source          => 'RECEIVING',
           p_event_type_id         => l_event_type_id,
           p_rcv_transaction_id    => p_rcv_transaction_id,
           p_inv_distribution_id   => NULL,
           p_po_distribution_id    => l_po_distribution_id,
           p_direct_delivery_flag  => p_direct_delivery_flag,
           p_cross_ou_flag         => l_cross_ou_flag,
           p_procurement_org_flag  => l_procurement_org_flag,
           p_ship_to_org_flag      => 'Y',
           p_drop_ship_flag        => l_drop_ship_flag,
           p_org_id                => l_rcv_org_id,
           p_organization_id       => l_rcv_organization_id,
           p_transfer_org_id       => l_transfer_org_id,
           p_transfer_organization_id => l_transfer_organization_id,
	   p_trx_flow_header_id	   => l_trx_flow_header_id,
           p_transaction_forward_flow_rec  => NULL,
           p_transaction_reverse_flow_rec  => l_transaction_reverse_flow_rec,
           p_unit_price            => NULL,
           p_prior_unit_price      => NULL,
           /* Support for Landed Cost Management */
           p_lcm_flag              => l_lcm_flag,
           x_rcv_event             => l_rcv_event);

        l_rcv_events_tbl(l_rcv_events_tbl.count + 1) := l_rcv_event;


        IF l_return_status <> FND_API.g_ret_sts_success THEN
           l_api_message := 'Error creating event';
           IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
               FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                   ,'Create_RTREvents : '||l_stmt_num||' : '||l_api_message);
           END IF;
           RAISE FND_API.g_exc_unexpected_error;
        END IF;

      IF l_trx_flow_exists_flag = 0 THEN
         l_stmt_num := 70;
         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                 ,'Checking if encumbrance events need to be seeded.');
         END IF;
         RCV_SeedEvents_PVT.Check_EncumbranceFlag(
                  p_api_version           => 1.0,
                  x_return_status         => l_return_status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data,
                  p_rcv_sob_id        	  => l_rcv_sob_id,
		  x_encumbrance_flag	  => l_encumbrance_flag,
		  x_ussgl_option          => l_ussgl_option);
         IF l_return_status <> FND_API.g_ret_sts_success THEN
            l_api_message := 'Error in checking for encumbrance flag ';
            IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                    ,'Create_RTREvents : '||l_stmt_num||' : '||l_api_message);
            END IF;
            RAISE FND_API.g_exc_unexpected_error;
         END IF;

         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
	    l_api_message := 'Encumbrance Flag : '||l_encumbrance_flag;
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                   ,l_api_message);
         END IF;

         IF(l_encumbrance_flag = 'Y') THEN
           l_stmt_num := 80;
           IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                   ,'Seeding Encumbrance Reversal Event');
           END IF;


           RCV_SeedEvents_PVT.Seed_RAEEvent(
              p_api_version           => 1.0,
              x_return_status         => l_return_status,
              x_msg_count             => l_msg_count,
              x_msg_data              => l_msg_data,
              p_event_source          => 'RECEIVING',
              p_event_type_id         => RCV_SeedEvents_PVT.ENCUMBRANCE_REVERSAL,
              p_rcv_transaction_id    => p_rcv_transaction_id,
              p_inv_distribution_id   => NULL,
              p_po_distribution_id    => l_po_distribution_id,
              p_direct_delivery_flag  => p_direct_delivery_flag,
              p_cross_ou_flag         => l_cross_ou_flag,
              p_procurement_org_flag  => l_procurement_org_flag,
              p_ship_to_org_flag      => 'Y',
              p_drop_ship_flag        => l_drop_ship_flag,
              p_org_id                => l_rcv_org_id,
              p_organization_id       => l_rcv_organization_id,
              p_transfer_org_id       => NULL,
              p_transfer_organization_id => NULL,
              p_transaction_forward_flow_rec  => NULL,
              p_transaction_reverse_flow_rec  => l_transaction_reverse_flow_rec,
              p_unit_price            => NULL,
              p_prior_unit_price      => NULL,
              /* Support for Landed Cost Management */
              p_lcm_flag              => l_lcm_flag,
              x_rcv_event             => l_rcv_event);

           /* Bug #3333610. In the case of encumbrance reversals, the quantity to unencumber
              may turn out to be zero if the quantity delivered is greater than the quantity
              ordered. In such a situation, we should not error out the event. */
	   IF l_return_status = FND_API.g_ret_sts_success THEN
	      l_rcv_events_tbl(l_rcv_events_tbl.count + 1) := l_rcv_event;
	   ELSIF l_return_status <> 'W' THEN
              l_api_message := 'Error in seeding encumbrance reversal event';
              IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                      ,'Create_RTREvents : '||l_stmt_num||' : '||l_api_message);
              END IF;
              RAISE FND_API.g_exc_unexpected_error;
           END IF;
         END IF;
      END IF;

      l_stmt_num := 90;
      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
              ,'Inserting events into RAE');
      END IF;
      RCV_SeedEvents_PVT.Insert_RAEEvents(
                  p_api_version           => 1.0,
                  x_return_status         => l_return_status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data,
                  p_rcv_events_tbl        => l_rcv_events_tbl,
                  /* Support for Landed Cost Management */
                  p_lcm_flag              => l_lcm_flag);
      IF l_return_status <> FND_API.g_ret_sts_success THEN
         l_api_message := 'Error inserting events into RAE';
         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
             FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                 ,'Create_RTREvents : '||l_stmt_num||' : '||l_api_message);
         END IF;
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

    -- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT WORK;
       END IF;

    -- Standard Call to get message count and if count = 1, get message info
       FND_MSG_PUB.Count_And_Get (
           p_count     => x_msg_count,
           p_data      => x_msg_data );

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.end'
             ,'Create_RTREvents >>');
      END IF;


EXCEPTION
      WHEN FND_API.g_exc_error THEN
         ROLLBACK TO Create_RTREvents_PVT;
         x_return_status := FND_API.g_ret_sts_error;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );
      WHEN FND_API.g_exc_unexpected_error THEN
         ROLLBACK TO Create_RTREvents_PVT;
         x_return_status := FND_API.g_ret_sts_unexp_error ;
         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

      WHEN OTHERS THEN
         ROLLBACK TO Create_RTREvents_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                ,'Create_RTREvents : '||l_stmt_num||' : '||substr(SQLERRM,1,200));
         END IF;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
               FND_MSG_PUB.add_exc_msg
                 (  G_PKG_NAME,
                    l_api_name || 'Statement -'||to_char(l_stmt_num)
                 );
         END IF;
         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
            , p_data   => x_msg_data
           );

END Create_RTREvents;


-- Start of comments
--      API name        : Create_RTVEvents
--      Type            : Private
--      Function        : To seed accounting events for RETURN TO VENDOR transactions.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_rcv_transaction_id    IN NUMBER       Required
--                              p_direct_delivery_flag  IN VARCHAR2     Optional
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--
--
--      Notes           : This API creates all accounting events for RETURN TO VENDOR transactions
--                        in RCV_ACCOUNTING_EVENTS.
--
-- End of comments
PROCEDURE Create_RTVEvents(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2,
                p_commit                IN      VARCHAR2,
                p_validation_level      IN      NUMBER,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                p_rcv_transaction_id    IN NUMBER,
                p_direct_delivery_flag  IN VARCHAR2
) IS
   l_api_name   	CONSTANT VARCHAR2(30)   := 'Create_RTVEvents';
   l_api_version        CONSTANT NUMBER         := 1.0;

   l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_msg_count           NUMBER := 0;
   l_msg_data            VARCHAR2(8000) := '';
   l_stmt_num            NUMBER := 0;
   l_api_message         VARCHAR2(1000);

   l_rcv_event		 RCV_SeedEvents_PVT.rcv_event_rec_type;
   l_rcv_events_tbl      RCV_SeedEvents_PVT.rcv_event_tbl_type;
   l_event_type_id       NUMBER;


   l_transaction_flows_tbl INV_TRANSACTION_FLOW_PUB.g_transaction_flow_tbl_type;
   l_transaction_forward_flow_rec INV_TRANSACTION_FLOW_PUB.mtl_transaction_flow_rec_type;
   l_transaction_reverse_flow_rec INV_TRANSACTION_FLOW_PUB.mtl_transaction_flow_rec_type;
   l_trx_flow_exists_flag NUMBER := 0;
   l_trx_flow_ctr 	NUMBER := 0;


   l_po_header_id	 NUMBER;
   l_po_line_id		 NUMBER;
   l_po_line_location_id NUMBER;
   l_po_distribution_id  NUMBER;
   l_po_org_id		 NUMBER;
   l_po_sob_id		 NUMBER;
   l_rcv_organization_id NUMBER;
   l_rcv_org_id    	 NUMBER;
   l_rcv_sob_id		 NUMBER;
   l_org_id		 NUMBER;
   l_transfer_org_id     NUMBER;
   l_transfer_organization_id NUMBER;
   l_rcv_trx_date	 DATE;
   l_drop_ship_flag	 NUMBER;
   l_destination_type	 VARCHAR(25);
   l_item_id		 NUMBER;
   l_category_id	 NUMBER;
   l_project_id		 NUMBER;
   l_cross_ou_flag	 VARCHAR2(1);
   l_accrual_flag	 VARCHAR2(1);
   l_counter		 NUMBER;
   l_procurement_org_flag VARCHAR2(1);
   l_trx_flow_header_id	 NUMBER;


   l_po_document_type_code PO_HEADERS_ALL.type_lookup_code%TYPE;
   l_is_shared_proc      VARCHAR2(1);
   /* Support for Landed Cost Management */
   l_lcm_flag            VARCHAR2(1);

   l_qualifier_code_tbl INV_TRANSACTION_FLOW_PUB.NUMBER_TBL;
   l_qualifier_value_tbl INV_TRANSACTION_FLOW_PUB.NUMBER_TBL;

   CURSOR c_po_distributions_csr(p_po_distribution_id NUMBER, p_po_line_location_id NUMBER) IS
        SELECT po_distribution_id,destination_type_code, project_id
        FROM   po_distributions POD
        WHERE  POD.po_distribution_id    = NVL(p_po_distribution_id,POD.po_distribution_id)
        AND    POD.line_location_id      = p_po_line_location_id;


BEGIN
   -- Standard start of API savepoint
      SAVEPOINT Create_RTVEvents_PVT;

      l_stmt_num := 0;

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.begin'
             ,'Create_RTVEvents <<');
      END IF;

   -- Standard call to check for call compatibility
      IF NOT FND_API.Compatible_API_Call (
                        l_api_version,
                        p_api_version,
                        l_api_name,
                        G_PKG_NAME ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE
      IF FND_API.to_Boolean(p_init_msg_list) THEN
           FND_MSG_PUB.initialize;
      END IF;

   -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      l_stmt_num := 20;
      SELECT
              RT.po_header_id,
	      RT.po_line_id,
	      RT.po_line_location_id,
              RT.po_distribution_id,
	      RT.transaction_date,
	      nvl(RT.dropship_type_code,3),
	      POH.org_id,
	      POLL.ship_to_organization_id,
	      POL.item_id,
	      POL.category_id,
	      POL.project_id,
	      nvl(POLL.accrue_on_receipt_flag,'N'),
              POH.type_lookup_code,
              /* Support for Landed Cost Management */
	      nvl(POLL.lcm_flag, 'N')
      INTO    l_po_header_id,
	      l_po_line_id,
	      l_po_line_location_id,
	      l_po_distribution_id,
	      l_rcv_trx_date,
	      l_drop_ship_flag,
	      l_po_org_id,
	      l_rcv_organization_id,
	      l_item_id,
	      l_category_id,
	      l_project_id,
	      l_accrual_flag,
	      l_po_document_type_code,
              /* Support for Landed Cost Management */
	      l_lcm_flag
      FROM    po_headers                POH,
	      po_line_locations		POLL,
	      po_lines			POL,
              rcv_transactions          RT
      WHERE   RT.transaction_id 	= p_rcv_transaction_id
      AND     POH.po_header_id 		= RT.po_header_id
      AND     POLL.line_location_id 	= RT.po_line_location_id
      AND     POL.po_line_id 		= RT.po_line_id;

      l_stmt_num := 30;
   -- Get Receiving Operating Unit
      SELECT  operating_unit, ledger_id
      INTO    l_rcv_org_id, l_rcv_sob_id
      FROM    cst_acct_info_v
      WHERE   organization_id = l_rcv_organization_id;

      l_stmt_num := 35;
   -- Get PO SOB
      SELECT  set_of_books_id
      INTO    l_po_sob_id
      FROM    financials_system_parameters;

      l_stmt_num := 40;
      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         l_api_message := 'Creating RTV Events : RCV Transaction ID : ' || p_rcv_transaction_id ||
                          ', PO Header ID : ' || l_po_header_id ||
                          ', PO Line ID : ' || l_po_line_id ||
                          ', PO Line Location ID : ' || l_po_line_location_id ||
                          ', PO Dist ID : ' || l_po_distribution_id ||
                          ', Transaction Date : '|| l_rcv_trx_date ||
                          ', Drop Ship Flag : '|| l_drop_ship_flag ||
                          ', PO Org ID : ' || l_po_org_id ||
                          ', PO SOB ID : ' || l_po_sob_id ||
                          ', RCV Organization ID : '|| l_rcv_organization_id ||
                          ', RCV Org ID : '|| l_rcv_org_id ||
                          ', RCV SOB ID : ' || l_rcv_sob_id ||
                          ', Category ID : ' || l_category_id ||
                          ', Accrual Flag : ' || l_accrual_flag ;

         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
             ,l_api_message);
      END IF;

      IF(l_po_org_id = l_rcv_org_id) THEN
	l_cross_ou_flag := 'N';
      ELSE
        l_cross_ou_flag := 'Y';

        /* For 11i10, the only supported qualifier is category id. */
        l_qualifier_code_tbl(l_qualifier_code_tbl.count+1)  := INV_TRANSACTION_FLOW_PUB.G_QUALIFIER_CODE;
        l_qualifier_value_tbl(l_qualifier_value_tbl.count+1) := l_category_id;


        l_stmt_num := 50;
        IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           l_api_message := 'Getting Procurement Transaction Flow :'||
                            'l_po_org_id : '||l_po_org_id||
                            ' l_rcv_org_id : '||l_rcv_org_id||
                            ' l_rcv_organization_id : '||l_rcv_organization_id;

           FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
             ,l_api_message);
        END IF;

        INV_TRANSACTION_FLOW_PUB.GET_TRANSACTION_FLOW(
                x_return_status         => l_return_status,
                x_msg_data              => l_msg_data,
                x_msg_count             => l_msg_count,
                x_transaction_flows_tbl => l_transaction_flows_tbl,
                p_api_version           => 1.0,
                p_start_operating_unit  => l_po_org_id,
                p_end_operating_unit    => l_rcv_org_id,
                p_flow_type             => INV_TRANSACTION_FLOW_PUB.G_PROCURING_FLOW_TYPE,
                p_organization_id       => l_rcv_organization_id,
                p_qualifier_code_tbl    => l_qualifier_code_tbl,
                p_qualifier_value_tbl   => l_qualifier_value_tbl,
                p_transaction_date      => l_rcv_trx_date,
                p_get_default_cost_group=> 'N');

        IF (l_return_status = FND_API.g_ret_sts_success) THEN
           l_trx_flow_exists_flag := 1;
	   l_trx_flow_header_id := l_transaction_flows_tbl(l_transaction_flows_tbl.FIRST).header_id;
	-- Return Status of 'W' indicates that no transaction flow exists.
        ELSIF (l_return_status = 'W') THEN
	   l_trx_flow_exists_flag := 0;
           IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                      ,'Transaction Flow does not exist');
           END IF;

        -- If transaction flow does not exist, but the PO crosses multiple
        -- sets of books, error out the transaction.
           IF(l_po_sob_id <> l_rcv_sob_id) THEN
              l_api_message := 'Transaction Flow does not exist';
              IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                 FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                                 ,'Create_RTVEvents : '||l_stmt_num||' : '||l_api_message);
              END IF;
              RAISE FND_API.g_exc_unexpected_error;
           END IF;

        ELSE
           l_api_message := 'Error occurred in Transaction Flow API';
           IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                              ,'Create_RTVEvents : '||l_stmt_num||' : '||l_api_message);
           END IF;
           RAISE FND_API.g_exc_unexpected_error;
        END IF; -- IF l_return_status
      END IF; -- IF l_po_org_id


   -- For the RTV transaction, the PO distribution may not be available in the
   -- case of Standard Receipt. Hence perform all steps for each applicable distribution.
   -- If distribution is not available the quantity will be prorated. Furthermore, if
   -- there is a project on any of the distributions, and the destination_type_code is
   -- expense, the transaction flow should be ignored for just that distribution.
      FOR rec_pod IN c_po_distributions_csr(l_po_distribution_id, l_po_line_location_id) LOOP

	l_stmt_num := 50;

        IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           l_api_message := 'Creating  Events : '||
			    'po_distribution_id : '||rec_pod.po_distribution_id||
			    ' destination_type_code : '||rec_pod.destination_type_code||
			    ' project_id : '||rec_pod.project_id;
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
             ,l_api_message);
        END IF;


        l_procurement_org_flag := 'Y';

	-- Bug #5880899. PO does not support centralized procurement for Blankets.
     -- Call PO API to verify centralized procurement is supported for this document type.
        IF (l_trx_flow_exists_flag = 1) THEN
           l_stmt_num := 45;
           IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              l_api_message := 'Checking if this is a shared proc scenario :'||
                               ' l_po_document_type_code : '||l_po_document_type_code||
                               ' l_po_org_id : '||l_po_org_id||
                               ' l_rcv_org_id : '||l_rcv_org_id||
                               ' l_rcv_organization_id : '||l_rcv_organization_id||
                               ' l_trx_flow_header_id : '||l_trx_flow_header_id;

              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                   ,l_api_message);
           END IF;

           PO_SHARED_PROC_GRP.check_shared_proc_scenario
           (
                p_api_version                =>1.0,
                p_init_msg_list              =>FND_API.G_FALSE,
                x_return_status              =>l_return_status,
                p_destination_type_code      =>rec_pod.destination_type_code,
                p_document_type_code         =>l_po_document_type_code,
                p_project_id                 =>rec_pod.project_id,
                p_purchasing_ou_id           =>l_po_org_id,
                p_ship_to_inv_org_id         =>l_rcv_organization_id,
                p_transaction_flow_header_id =>l_trx_flow_header_id,
                x_is_shared_proc_scenario    =>l_is_shared_proc
            );

            IF l_return_status <> FND_API.g_ret_sts_success THEN
               l_api_message := 'Error in API PO_SHARED_PROC_GRP.check_shared_proc_scenario';
               IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                   FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                       ,'Create_ReceiveEvents : '||l_stmt_num||' : '||l_api_message);
               END IF;
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

            IF l_is_shared_proc IS NULL OR l_is_shared_proc = 'N' THEN
                l_is_shared_proc := 'N';
                l_trx_flow_exists_flag := 0;
                l_trx_flow_header_id := NULL;
            END IF;


            IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
               l_api_message := 'Returned from check_shared_proc_scenario :'||
                                ' l_is_shared_proc :'|| l_is_shared_proc;
               FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                 ,l_api_message);
            END IF;
        END IF;

     -- For POs with destination type of expense, when there is a project on the
     -- POD, we should not look for transaction flow. This is because PA,(which transfers
     -- costs to Projects for expense destinations), is currently not supporting global
     -- procurement.
        IF((l_trx_flow_exists_flag = 1) AND
	(rec_pod.project_id is NULL OR rec_pod.destination_type_code <> 'EXPENSE')AND
	   (l_is_shared_proc = 'Y')) THEN

		l_trx_flow_ctr := l_transaction_flows_tbl.COUNT;
	     -- Create Logical RTV transactions in each intermediate organization.
		FOR l_counter IN  l_transaction_flows_tbl.FIRST..l_transaction_flows_tbl.LAST LOOP

          	   IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
             	      FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                	   ,'Seeding Logical RTV in RAE');
          	   END IF;

		   l_stmt_num := 60;
	        -- l_transaction_forward_flow_rec contains the transaction flow record
	        -- where the org_id is the from_org_id.
	        -- l_transaction_reverse_flow_rec contains the transaction flow record
	        -- where the org_id is the to_org_id.
	        -- Need to pass both to the Seed_RAE procedure because transfer_price is based
	        -- on the reverse flow record and some accounts are based on the forward flow

		   l_transaction_forward_flow_rec := l_transaction_flows_tbl(l_counter);
		   IF(l_counter = l_transaction_flows_tbl.FIRST) THEN
		     l_transaction_reverse_flow_rec := NULL;
                     l_transfer_org_id              := NULL;
                     l_transfer_organization_id     := NULL;
		   ELSE
                     l_transaction_reverse_flow_rec := l_transaction_flows_tbl(l_counter - 1);
                     l_transfer_org_id              := l_transaction_reverse_flow_rec.from_org_id;
                     l_transfer_organization_id     := l_transaction_reverse_flow_rec.from_organization_id;
		   END IF;

		   RCV_SeedEvents_PVT.Seed_RAEEvent(
			p_api_version           => 1.0,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        x_msg_data              => l_msg_data,
			p_event_source		=> 'RECEIVING',
		 	p_event_type_id		=> RCV_SeedEvents_PVT.LOGICAL_RETURN_TO_VENDOR,
                        p_rcv_transaction_id    => p_rcv_transaction_id,
			p_inv_distribution_id	=> NULL,
			p_po_distribution_id	=> rec_pod.po_distribution_id,
                        p_direct_delivery_flag  => p_direct_delivery_flag,
			p_cross_ou_flag		=> l_cross_ou_flag,
		  	p_procurement_org_flag	=> l_procurement_org_flag,
                  	p_ship_to_org_flag      => 'N',
			p_drop_ship_flag	=> l_drop_ship_flag,
		   	p_org_id		=> l_transaction_flows_tbl(l_counter).from_org_id,
			p_organization_id	=> l_transaction_flows_tbl(l_counter).from_organization_id,
                  	p_transfer_org_id       => l_transfer_org_id,
			p_transfer_organization_id => l_transfer_organization_id,
                  	p_trx_flow_header_id    => l_trx_flow_header_id,
			p_transaction_forward_flow_rec  => l_transaction_forward_flow_rec,
			p_transaction_reverse_flow_rec 	=> l_transaction_reverse_flow_rec,
			p_unit_price		=> NULL,
			p_prior_unit_price	=> NULL,
                       /* Support for Landed Cost Management */
                        p_lcm_flag              => l_lcm_flag,
			x_rcv_event		=> l_rcv_event);

      		   IF l_return_status <> FND_API.g_ret_sts_success THEN
        		l_api_message := 'Error creating event';
        		IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            		    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                		,'Create_RTVEvents : '||l_stmt_num||' : '||l_api_message);
        		END IF;
        		RAISE FND_API.g_exc_unexpected_error;
      		   END IF;

		   l_rcv_events_tbl(l_rcv_events_tbl.count + 1) := l_rcv_event;

		-- For one-time items, if online accruals is used, seed IC Invoice event.
	  	-- For Shop Floor destination types, always seed IC Invoice events.
		   IF((l_item_id is NULL and l_accrual_flag = 'Y')OR
                      (rec_pod.destination_type_code = 'SHOP FLOOR')) THEN
                      l_stmt_num := 70;
                      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                         FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                              ,'Seeding Invoice Match in RAE');
                      END IF;

                      RCV_SeedEvents_PVT.Seed_RAEEvent(
                           p_api_version           => 1.0,
                           x_return_status         => l_return_status,
                           x_msg_count             => l_msg_count,
                           x_msg_data              => l_msg_data,
                           p_event_source          => 'RECEIVING',
                           p_event_type_id         => RCV_SeedEvents_PVT.INTERCOMPANY_REVERSAL,
                           p_rcv_transaction_id    => p_rcv_transaction_id,
                           p_inv_distribution_id   => NULL,
                           p_po_distribution_id    => rec_pod.po_distribution_id,
                           p_direct_delivery_flag   => p_direct_delivery_flag,
                           p_cross_ou_flag         => l_cross_ou_flag,
                           p_procurement_org_flag  => l_procurement_org_flag,
                           p_ship_to_org_flag      => 'N',
                           p_drop_ship_flag        => l_drop_ship_flag,
                           p_org_id                => l_transaction_flows_tbl(l_counter).from_org_id,
                  	   p_organization_id       => l_transaction_flows_tbl(l_counter).from_organization_id,
                  	   p_transfer_org_id       => l_transaction_flows_tbl(l_counter).to_org_id,
                  	   p_transfer_organization_id => l_transaction_flows_tbl(l_counter).to_organization_id,
                           p_trx_flow_header_id    => l_trx_flow_header_id,
                           p_transaction_forward_flow_rec  => l_transaction_forward_flow_rec,
                           p_transaction_reverse_flow_rec  => l_transaction_reverse_flow_rec,
                           p_unit_price            => NULL,
                           p_prior_unit_price      => NULL,
                           /* Support for Landed Cost Management */
                           p_lcm_flag              => l_lcm_flag,
                           x_rcv_event             => l_rcv_event);

                      IF l_return_status <> FND_API.g_ret_sts_success THEN
                         l_api_message := 'Error creating event';
                         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                             FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                                 ,'Create_RTVEvents : '||l_stmt_num||' : '||l_api_message);
                         END IF;
                         RAISE FND_API.g_exc_unexpected_error;
                      END IF;

                      l_rcv_events_tbl(l_rcv_events_tbl.count + 1) := l_rcv_event;
		   END IF;

		   l_procurement_org_flag := 'N';
		END LOOP;
        END IF;

	l_stmt_num := 80;
        IF (l_trx_flow_exists_flag = 1) THEN
           l_transaction_forward_flow_rec := NULL;
           l_transaction_reverse_flow_rec := l_transaction_flows_tbl(l_trx_flow_ctr);
           l_org_id 			  := l_transaction_flows_tbl(l_trx_flow_ctr).to_org_id;
           l_transfer_org_id              := l_transaction_flows_tbl(l_trx_flow_ctr).from_org_id;
           l_transfer_organization_id     := l_transaction_reverse_flow_rec.from_organization_id;
        ELSE
           l_transaction_forward_flow_rec := NULL;
           l_transaction_reverse_flow_rec := NULL;
           l_org_id := l_po_org_id;
           l_transfer_org_id              := NULL;
           l_transfer_organization_id     := NULL;
        END IF;

        l_stmt_num := 90;

     -- The drop ship flag is not applicable in the case of returns. There will always
     -- be a physical receipt in the procuring org.
	l_stmt_num := 110;
	SELECT decode(RT.transaction_type,'CORRECT',RCV_SeedEvents_PVT.CORRECT,
		RCV_SeedEvents_PVT.RETURN_TO_VENDOR)
	INTO   l_event_type_id
	FROM   rcv_Transactions RT
	WHERE  transaction_id = p_rcv_transaction_id;

        IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                ,'Seeding RTV in RAE');
        END IF;

        l_stmt_num := 120;
        RCV_SeedEvents_PVT.Seed_RAEEvent(
                  p_api_version           => 1.0,
                  x_return_status         => l_return_status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data,
                  p_event_source          => 'RECEIVING',
                  p_event_type_id         => l_event_type_id,
                  p_rcv_transaction_id    => p_rcv_transaction_id,
		  p_inv_distribution_id   => NULL,
                  p_po_distribution_id    => rec_pod.po_distribution_id,
                  p_direct_delivery_flag  => p_direct_delivery_flag,
                  p_cross_ou_flag         => l_cross_ou_flag,
                  p_procurement_org_flag  => l_procurement_org_flag,
                  p_ship_to_org_flag      => 'Y',
		  p_drop_ship_flag	  => l_drop_ship_flag,
                  p_org_id                => l_org_id,
                  p_organization_id       => l_rcv_organization_id,
                  p_transfer_org_id       => l_transfer_org_id,
                  p_transfer_organization_id => l_transfer_organization_id,
                  p_trx_flow_header_id    => l_trx_flow_header_id,
                  p_transaction_forward_flow_rec  => l_transaction_forward_flow_rec,
                  p_transaction_reverse_flow_rec  => l_transaction_reverse_flow_rec,
                  p_unit_price            => NULL,
                  p_prior_unit_price      => NULL,
                  /* Support for Landed Cost Management */
                  p_lcm_flag              => l_lcm_flag,
                  x_rcv_event             => l_rcv_event);
        IF l_return_status <> FND_API.g_ret_sts_success THEN
         l_api_message := 'Error creating event';
         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
             FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                 ,'Create_RTVEvents : '||l_stmt_num||' : '||l_api_message);
         END IF;
         RAISE FND_API.g_exc_unexpected_error;
        END IF;

        l_rcv_events_tbl(l_rcv_events_tbl.count + 1) := l_rcv_event;

     END LOOP;

     l_stmt_num := 130;
     IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
              ,'Inserting events into RAE');
     END IF;
     RCV_SeedEvents_PVT.Insert_RAEEvents(
                  p_api_version           => 1.0,
                  x_return_status         => l_return_status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data,
		  p_rcv_events_tbl	  => l_rcv_events_tbl,
                  /* Support for Landed Cost Management */
                  p_lcm_flag              => l_lcm_flag);
      IF l_return_status <> FND_API.g_ret_sts_success THEN
         l_api_message := 'Error inserting events into RAE';
         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
             FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                 ,'Create_RTVEvents : '||l_stmt_num||' : '||l_api_message);
         END IF;
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

     IF(l_trx_flow_exists_flag = 1 and l_item_id IS NOT NULL) THEN
        l_stmt_num := 140;
        IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                 ,'Inserting events into MMT');
        END IF;
        RCV_SeedEvents_PVT.Insert_MMTEvents(
                  p_api_version           => 1.0,
                  x_return_status         => l_return_status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data,
                  p_rcv_events_tbl        => l_rcv_events_tbl);
         IF l_return_status <> FND_API.g_ret_sts_success THEN
            l_api_message := 'Error inserting events into MMT';
            IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                    ,'Create_RTVEvents : '||l_stmt_num||' : '||l_api_message);
            END IF;
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
     END IF;

    -- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT WORK;
       END IF;

    -- Standard Call to get message count and if count = 1, get message info
       FND_MSG_PUB.Count_And_Get (
           p_count     => x_msg_count,
           p_data      => x_msg_data );

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.end'
             ,'Create_RTVEvents >>');
      END IF;


EXCEPTION
      WHEN FND_API.g_exc_error THEN
         ROLLBACK TO Create_RTVEvents_PVT;
         x_return_status := FND_API.g_ret_sts_error;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );
      WHEN FND_API.g_exc_unexpected_error THEN
         ROLLBACK TO Create_RTVEvents_PVT;
         x_return_status := FND_API.g_ret_sts_unexp_error ;
         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

      WHEN OTHERS THEN
         ROLLBACK TO Create_RTVEvents_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                ,'Create_RTVEvents : '||l_stmt_num||' : '||substr(SQLERRM,1,200));
         END IF;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
               FND_MSG_PUB.add_exc_msg
                 (  G_PKG_NAME,
                    l_api_name || 'Statement -'||to_char(l_stmt_num)
                 );
         END IF;
         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
            , p_data   => x_msg_data
           );

END Create_RTVEvents;

-- Start of comments
--      API name        : Get_InvTransactionInfo
--      Type            : Private
--      Pre-reqs        :
--      Function        : To return the transfer price and distribution account in
--                        global procurement and drop shipment scenarios.
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_rcv_transaction_id    IN NUMBER       Required
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--                              x_intercompany_pricing_option   OUT    NUMBER
--                              x_currency_code         OUT     VARCHAR2
--                              x_currency_conversion_rate OUT  NUMBER
--                              x_currency_conversion_date OUT  DATE
--                              x_currency_conversion_type OUT  VARCHAR2(30)
--                              x_distribution_acct_id  OUT     NUMBER
--      Version :
--                        Initial version       1.0
--
--      Notes           :
--      This API is called by the receiving transaction processor for Deliver, RTR
--      and Corrections to Deliver/RTR transactions, to determine if the price to be
--      stamped on MMTT is the PO price or the transfer price. This API returns a
--      flag to indicate if transfer price is to be used. If this flag is set to 'Y',
--      the transfer price and the corresponding currency code are returned. The
--      transfer price is returned in the transaction UOM.
--      If the returned transfer price flag is 'N', the Receiving transaction
--      Processor should stamp the PO price as usual.
--
--      This API also returns the distribution account for External Drop Shipments
--      when the new accounting flag is checked. If the returned distribution account
--      is -1, the Receiving transaction processor should stamp the MMTT transaction
--      with the Receiving Inspection account as usual.
--      Otherwise, it should stamp the returned Clearing Account.
--
-- End of comments
-------------------------------------------------------------------------------
PROCEDURE Get_InvTransactionInfo(
          p_api_version               IN      NUMBER,
          p_init_msg_list             IN      VARCHAR2,
          p_commit                    IN      VARCHAR2,
          p_validation_level          IN      VARCHAR2,
          x_return_status             OUT NOCOPY     VARCHAR2,
          x_msg_count                 OUT NOCOPY     NUMBER,
          x_msg_data                  OUT NOCOPY     VARCHAR2,

          p_rcv_transaction_id        IN             NUMBER,

          x_intercompany_pricing_option       OUT NOCOPY     NUMBER,
          x_transfer_price            OUT NOCOPY     NUMBER,
          x_currency_code             OUT NOCOPY     VARCHAR2,
          x_currency_conversion_rate  OUT NOCOPY     NUMBER,
          x_currency_conversion_date  OUT NOCOPY     DATE,
          x_currency_conversion_type  OUT NOCOPY     VARCHAR2,
          x_distribution_acct_id      OUT NOCOPY     NUMBER
)IS
   l_api_name   	CONSTANT VARCHAR2(30)   := 'Get_InvTransactionInfo';
   l_api_version        CONSTANT NUMBER         := 1.0;

   l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_msg_count           NUMBER := 0;
   l_msg_data            VARCHAR2(8000) := '';
   l_stmt_num            NUMBER := 0;
   l_api_message         VARCHAR2(1000);

   l_transaction_flows_tbl INV_TRANSACTION_FLOW_PUB.g_transaction_flow_tbl_type;
   l_consigned_flag      RCV_TRANSACTIONS.consigned_flag%TYPE;
   l_source_doc_code     RCV_TRANSACTIONS.source_document_code%TYPE;
   l_transaction_type    RCV_TRANSACTIONS.transaction_type%TYPE;
   l_parent_trx_id       RCV_TRANSACTIONS.transaction_id%TYPE;
   l_parent_trx_type     RCV_TRANSACTIONS.transaction_type%TYPE;
   l_po_header_id        NUMBER;
   l_po_distribution_id  NUMBER;
   l_po_line_id		 NUMBER;
   l_po_line_location_id NUMBER;
   l_po_org_id           NUMBER;
   l_po_sob_id           NUMBER;
   l_rcv_organization_id NUMBER;
   l_rcv_org_id          NUMBER;
   l_rcv_sob_id		 NUMBER;
   l_org_id              NUMBER;
   l_rcv_trx_date        DATE;
   l_drop_ship_flag      NUMBER;
   l_destination_type    VARCHAR(25);
   l_item_id             NUMBER;
   l_category_id         NUMBER;
   l_project_id          NUMBER;
   l_cross_ou_flag       VARCHAR2(1);
   l_accrual_flag        VARCHAR2(1);
   l_counter             NUMBER;
   l_procurement_org_flag VARCHAR2(1);

   l_qualifier_code_tbl INV_TRANSACTION_FLOW_PUB.NUMBER_TBL;
   l_qualifier_value_tbl INV_TRANSACTION_FLOW_PUB.NUMBER_TBL;

   l_rcv_event           RCV_SeedEvents_PVT.rcv_event_rec_type;
   l_ic_pricing_option 	NUMBER := 1;
   l_unit_price         NUMBER := 0;
   l_unit_landed_cost   NUMBER := NULL;
   l_currency_code      VARCHAR2(15) := NULL;
   l_currency_conversion_rate   NUMBER;
   l_currency_conversion_date   DATE;
   l_currency_conversion_type   VARCHAR2(30);
   l_clearing_acct_id 	NUMBER := -1;

   l_incr_transfer_price NUMBER := 0;
   l_incr_currency_code  VARCHAR2(15) := NULL;
   /* Support for Landed Cost Management */
   l_lcm_flag            VARCHAR2(1);


BEGIN
   -- Standard start of API savepoint
      SAVEPOINT Get_InvTransactionInfo_PVT;

      l_stmt_num := 0;

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.begin'
             ,'Get_InvTransactionInfo <<');
      END IF;

   -- Standard call to check for call compatibility
      IF NOT FND_API.Compatible_API_Call (
                        l_api_version,
                        p_api_version,
                        l_api_name,
                        G_PKG_NAME ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE
      IF FND_API.to_Boolean(p_init_msg_list) THEN
           FND_MSG_PUB.initialize;
      END IF;

   -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Initialize return variables
      x_intercompany_pricing_option 	:= 1;
      x_transfer_price			:= 0;
      x_distribution_acct_id 		:= -1;

      l_stmt_num := 10;

      SELECT
	      RT.consigned_flag,
              RT.source_document_code,
              RT.transaction_type,
	      RT.parent_transaction_id,
              RT.po_header_id,
	      RT.po_line_id,
	      RT.po_line_location_id,
              RT.po_distribution_id,
              POD.destination_type_code,
              RT.transaction_date,
              nvl(RT.dropship_type_code,3),
              POH.org_id,
              POLL.ship_to_organization_id,
              POL.item_id,
              POL.category_id,
              POL.project_id,
              nvl(POLL.accrue_on_receipt_flag,'N'),
              /* Support for Landed Cost Management */
	      nvl(POLL.lcm_flag, 'N')
      INTO    l_consigned_flag,
              l_source_doc_code,
              l_transaction_type,
	      l_parent_trx_id,
	      l_po_header_id,
	      l_po_line_id,
	      l_po_line_location_id,
              l_po_distribution_id,
              l_destination_type,
              l_rcv_trx_date,
              l_drop_ship_flag,
              l_po_org_id,
              l_rcv_organization_id,
              l_item_id,
              l_category_id,
              l_project_id,
              l_accrual_flag,
              /* Support for Landed Cost Management */
	      l_lcm_flag
      FROM    po_headers                POH,
              po_line_locations         POLL,
              po_lines                  POL,
              po_distributions          POD,
              rcv_transactions          RT
      WHERE   RT.transaction_id         = p_rcv_transaction_id
      AND     POH.po_header_id          = RT.po_header_id
      AND     POLL.line_location_id     = RT.po_line_location_id
      AND     POL.po_line_id            = RT.po_line_id
      AND     POD.po_distribution_id    = RT.po_distribution_id;

   -- If receiving transaction is for a REQ, or an RMA, we do not
   -- do not do any accounting.
   -- If consigned receipt, we do not do any accounting.
      IF(l_source_doc_code <> 'PO' OR l_consigned_flag = 'Y') THEN
        return;
      END IF;

      IF(l_transaction_type = 'CORRECT') THEN
	l_stmt_num := 20;
	SELECT transaction_type
	INTO   l_parent_trx_type
	FROM   rcv_transactions PARENT
	WHERE  PARENT.transaction_id = l_parent_trx_id;
      END IF;

   -- This API is only applicable for Deliver/RTR transactions or corrections to deliver/RTR
   -- transactions.
      IF(l_transaction_type NOT IN ('DELIVER','RETURN TO RECEIVING') AND
	 (l_transaction_type <> 'CORRECT'
		OR l_parent_trx_type NOT IN ('DELIVER','RETURN TO RECEIVING'))) THEN
	return;
      END IF;

      l_stmt_num := 30;

   -- Get Receiving Operating Unit
      SELECT  operating_unit, ledger_id
      INTO    l_rcv_org_id, l_rcv_sob_id
      FROM    cst_acct_info_v
      WHERE   organization_id = l_rcv_organization_id;

   -- Get PO SOB
      SELECT  set_of_books_id
      INTO    l_po_sob_id
      FROM    financials_system_parameters;

      l_stmt_num := 40;

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         l_api_message := 'Getting InvTransactionInfor : RCV Transaction ID : ' || p_rcv_transaction_id ||
                          ', PO Header ID : ' || l_po_header_id ||
                          ', PO Dist ID : ' || l_po_distribution_id ||
                          ', Destination Type : '|| l_destination_type ||
                          ', Transaction Date : '|| l_rcv_trx_date ||
                          ', Drop Ship Flag : '|| l_drop_ship_flag ||
                          ', PO Org ID : ' || l_po_org_id ||
                          ', RCV Organization ID : '|| l_rcv_organization_id ||
                          ', RCV Org ID : '|| l_rcv_org_id ||
                          ', Project ID : '|| l_project_id ||
                          ', Category ID : ' || l_category_id ||
                          ', Accrual Flag : ' || l_accrual_flag ;

         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
             ,l_api_message);
      END IF;

   -- Get transaction flow when procuring and receiving operating units are different.
   -- However, for POs with destination type of expense, when there is a project on the
   -- PO, we should not look for transaction flow. This is because PA,(which transfers
   -- costs to Projects for expense destinations), is currently not supporting global
   -- procurement.
      IF((l_po_org_id = l_rcv_org_id) OR
         (l_project_id is NOT NULL AND l_destination_type = 'EXPENSE') OR
	 (l_item_id IS NULL)
	 ) THEN
	l_ic_pricing_option := 1;
      ELSE

        /* For 11i10, the only supported qualifier is category id. */
        l_qualifier_code_tbl(l_qualifier_code_tbl.count+1)  := INV_TRANSACTION_FLOW_PUB.G_QUALIFIER_CODE;
        l_qualifier_value_tbl(l_qualifier_value_tbl.count+1) := l_category_id;

	l_stmt_num := 50;
        IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           l_api_message := 'Getting Procurement Transaction Flow :'||
                            'l_po_org_id : '||l_po_org_id||
                            ' l_rcv_org_id : '||l_rcv_org_id||
                            ' l_rcv_organization_id : '||l_rcv_organization_id;

           FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
           ,l_api_message);
        END IF;

        INV_TRANSACTION_FLOW_PUB.GET_TRANSACTION_FLOW(
            x_return_status         => l_return_status,
            x_msg_data              => l_msg_data,
            x_msg_count             => l_msg_count,
            x_transaction_flows_tbl => l_transaction_flows_tbl,
            p_api_version           => 1.0,
            p_start_operating_unit  => l_po_org_id,
            p_end_operating_unit    => l_rcv_org_id,
            p_flow_type             => INV_TRANSACTION_FLOW_PUB.G_PROCURING_FLOW_TYPE,
            p_organization_id       => l_rcv_organization_id,
            p_qualifier_code_tbl    => l_qualifier_code_tbl,
            p_qualifier_value_tbl   => l_qualifier_value_tbl,
            p_transaction_date      => l_rcv_trx_date,
            p_get_default_cost_group=> 'N');

        IF (l_return_status = FND_API.g_ret_sts_success) THEN
	-- Populate dummy l_rcv_event record to pass to Get_UnitPrice function.
	   l_counter 				:= l_transaction_flows_tbl.COUNT;
	   l_rcv_event.trx_flow_header_id 	:= l_transaction_flows_tbl(l_counter).header_id;
	   l_rcv_event.destination_type_code 	:= l_destination_type;
	   l_rcv_event.procurement_org_flag 	:= 'N';
	   l_rcv_event.drop_ship_flag 		:= l_drop_ship_flag;
	   l_rcv_event.item_id 			:= l_item_id;
	   l_rcv_event.org_id 			:= l_rcv_org_id;
	   l_rcv_event.transfer_org_id 		:= l_transaction_flows_tbl(l_counter).from_org_id;
	   l_rcv_event.organization_id 		:= l_rcv_organization_id;
	   l_rcv_event.transfer_organization_id := l_transaction_flows_tbl(l_counter).from_organization_id;
	   l_rcv_event.rcv_transaction_id 	:= p_rcv_transaction_id;
	   l_rcv_event.transaction_date 	:= l_rcv_trx_date;
	   l_rcv_event.event_source 		:= 'RECEIVING';
	   l_rcv_event.po_header_id 		:= l_po_header_id;
	   l_rcv_event.po_line_id 		:= l_po_line_id;
	   l_rcv_event.po_distribution_id 	:= l_po_distribution_id;
	   l_rcv_event.po_line_location_id 	:= l_po_line_location_id;
	   l_rcv_event.set_of_books_id		:= l_rcv_sob_id;

	   l_stmt_num := 60;
	   RCV_SeedEvents_PVT.Get_UnitPrice( p_api_version           => l_api_version,
                          x_return_status         => l_return_status,
                          x_msg_count             => l_msg_count,
                          x_msg_data              => l_msg_data,
                          p_rcv_event             => l_rcv_event,
                          p_asset_item_pricing_option =>
					l_transaction_flows_tbl(l_counter).asset_item_pricing_option,
                          p_expense_item_pricing_option =>
					l_transaction_flows_tbl(l_counter).expense_item_pricing_option,
                          /* Support for Landed Cost Management */
                          p_lcm_flag              => l_lcm_flag,
                          x_intercompany_pricing_option => l_ic_pricing_option,
                          x_unit_price             => l_unit_price,
                          x_unit_landed_cost       => l_unit_landed_cost,
                          x_currency_code          => l_currency_code,
			  x_incr_transfer_price    => l_incr_transfer_price,
                          x_incr_currency_code     => l_incr_currency_code);
           IF l_return_status <> FND_API.g_ret_sts_success THEN
              l_api_message := 'Error getting unit price';
              IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                      ,'Get_InvInfo : '||l_stmt_num||' : '||l_api_message);
              END IF;
              RAISE FND_API.g_exc_unexpected_error;
           END IF;

           l_rcv_event.currency_code := l_currency_code;

           IF (l_ic_pricing_option  = 2) THEN
              x_transfer_price := l_unit_price;
       	      x_currency_code := l_currency_code;

       	      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
             	 FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                            ,'Getting Currency Information');
              END IF;
	      l_stmt_num :=70;
              RCV_SeedEvents_PVT.Get_Currency(
		     p_api_version           => l_api_version,
                     x_return_status         => l_return_status,
                     x_msg_count             => l_msg_count,
                     x_msg_data              => l_msg_data,
		     p_rcv_event	     => l_rcv_event,
		     x_currency_code	     => l_currency_code,
                     x_currency_conversion_rate => l_currency_conversion_rate,
                     x_currency_conversion_date => l_currency_conversion_date,
                     x_currency_conversion_type => l_currency_conversion_type);

              IF l_return_status <> FND_API.g_ret_sts_success THEN
                 l_api_message := 'Error Getting Currency';
                 IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                            ,'Seed_RAEEvent : '||l_stmt_num||' : '||l_api_message);
                 END IF;
                 RAISE FND_API.g_exc_unexpected_error;
              END IF;
	   END IF;
	ELSIF(l_return_status = FND_API.g_ret_sts_error) THEN
	    l_api_message := 'Error occurred in Transaction Flow API';
            IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                    ,'Get_InvTransaction_Info : '||l_stmt_num||' : '||l_api_message);
            END IF;
            RAISE FND_API.g_exc_unexpected_error;
	END IF;
    END IF;

    IF(l_drop_ship_flag IN (1,2)) THEN
      l_stmt_num := 80;
      SELECT nvl(clearing_account_id, receiving_account_id)
      INTO   l_clearing_acct_id
      FROM   rcv_parameters
      WHERE  organization_id = l_rcv_organization_id;

      x_distribution_acct_id           := l_clearing_acct_id;
    END IF;

    l_stmt_num := 90;
    x_intercompany_pricing_option := l_ic_pricing_option;
    IF (l_ic_pricing_option  = 2) THEN
       x_transfer_price 		:= l_unit_price;
       x_currency_code 			:= l_currency_code;
       x_currency_conversion_rate  	:= l_currency_conversion_rate;
       x_currency_conversion_date  	:= l_currency_conversion_date;
       x_currency_conversion_type  	:= l_currency_conversion_type;
    END IF;

    IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       l_api_message := 'x_intercompany_pricing_option : '||x_intercompany_pricing_option||
			'x_transfer_price : '||x_transfer_price||
			'x_currency_code : '||x_currency_code||
			'x_currency_conversion_rate : '||x_currency_conversion_rate||
			'x_currency_conversion_date : '||x_currency_conversion_date||
			'x_currency_conversion_type : '||x_currency_conversion_type||
			'x_distribution_acct_id : '||x_distribution_acct_id;

       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
           ,l_api_message);
    END IF;

   --- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT WORK;
       END IF;

    -- Standard Call to get message count and if count = 1, get message info
       FND_MSG_PUB.Count_And_Get (
           p_count     => x_msg_count,
           p_data      => x_msg_data );

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.end'
             ,'Get_InvTransactionInfo >>');
      END IF;


EXCEPTION
      WHEN FND_API.g_exc_error THEN
         ROLLBACK TO Get_InvTransactionInfo_PVT;
         x_return_status := FND_API.g_ret_sts_error;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );
      WHEN FND_API.g_exc_unexpected_error THEN
         ROLLBACK TO Get_InvTransactionInfo_PVT;
         x_return_status := FND_API.g_ret_sts_unexp_error ;
         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

      WHEN OTHERS THEN
         ROLLBACK TO Get_InvTransactionInfo_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                ,'Get_InvTransactionInfo : '||l_stmt_num||' : '||substr(SQLERRM,1,200));
         END IF;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
               FND_MSG_PUB.add_exc_msg
                 (  G_PKG_NAME,
                    l_api_name || 'Statement -'||to_char(l_stmt_num)
                 );
         END IF;
         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
            , p_data   => x_msg_data
           );

END Get_InvTransactionInfo;


END RCV_AccEvents_PVT;

/
