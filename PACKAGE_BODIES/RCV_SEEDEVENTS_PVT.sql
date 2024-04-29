--------------------------------------------------------
--  DDL for Package Body RCV_SEEDEVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_SEEDEVENTS_PVT" AS
/* $Header: RCVVRUTB.pls 120.10.12010000.11 2014/06/06 12:15:43 nuggrara ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'RCV_SeedEvents_PVT';
G_DEBUG CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
G_LOG_HEAD CONSTANT VARCHAR2(40) := 'po.plsql.'||G_PKG_NAME;

--      API name        : Seed_RAEEvent
--      Type            : Private
--      Function        : To seed accounting event in RCV_ACCOUNTING_EVENTS.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--				p_event_source		IN VARCHAR2	Required
--				p_event_type_id		IN NUMBER	Required
--                              p_rcv_transaction_id    IN NUMBER	Optional
--                              p_inv_distribution_id   IN NUMBER	Optional
--				p_po_distribution_id	IN NUMBER	Required
--                              p_direct_delivery_flag  IN VARCHAR2     Optional
--				p_cross_ou_flag         IN VARCHAR2	Optional
--				p_procurement_org_flag  IN VARCHAR2	Optional
--				p_org_id		IN NUMBER	Required
--				p_organization_id	IN NUMBER	Optional
--				p_transfer_org_id	IN NUMBER	Optional
--				p_transfer_organization_id IN NUMBER	Optional
--                	        p_transaction_forward_flow_rec  mtl_transaction_flow_rec_type,
--                              p_transaction_reverse_flow_rec  mtl_transaction_flow_rec_type,
--				p_transaction_flow_rec  IN mtl_transaction_flow_rec_type
--				p_unit_price		IN NUMBER	Required
--				p_prior_unit_price	IN NUMBER	Optional
--                              p_lcm_flag              IN VARCHAR2
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--				x_rcv_event		OUT	RCV_SeedEvents_PVT.rcv_event_tbl_type;
--      Version :
--                        Initial version       1.0
--
--
--      Notes           : This API is used to seed events in RCV_ACCOUNTING_EVENTS table.
--
-- End of comments
-------------------------------------------------------------------------------
PROCEDURE Seed_RAEEvent(
                p_api_version           IN      	NUMBER,
                p_init_msg_list         IN      	VARCHAR2,
                p_commit                IN      	VARCHAR2,
                p_validation_level      IN      	NUMBER,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

		p_event_source		IN		VARCHAR2,
		p_event_type_id		IN		NUMBER,
                p_rcv_transaction_id    IN 		NUMBER,
		p_inv_distribution_id	IN 		NUMBER,
	   	p_po_distribution_id	IN 		NUMBER,
                p_direct_delivery_flag  IN 		VARCHAR2,
		p_cross_ou_flag		IN 		VARCHAR2,
		p_procurement_org_flag	IN 		VARCHAR2,
		p_ship_to_org_flag	IN 		VARCHAR2,
		p_drop_ship_flag	IN 		NUMBER,
		p_org_id		IN 		NUMBER,
		p_organization_id	IN 		NUMBER,
                p_transfer_org_id       IN 		NUMBER,
                p_transfer_organization_id      IN 	NUMBER,
		p_trx_flow_header_id	IN 		NUMBER,
                p_transaction_forward_flow_rec  INV_TRANSACTION_FLOW_PUB.mtl_transaction_flow_rec_type,
                p_transaction_reverse_flow_rec  INV_TRANSACTION_FLOW_PUB.mtl_transaction_flow_rec_type,
		p_unit_price		IN 		NUMBER,
   		p_prior_unit_price	IN 		NUMBER,
                /* Support for Landed Cost Management */
                p_lcm_flag  IN VARCHAR2,
		x_rcv_event		OUT NOCOPY	RCV_SeedEvents_PVT.rcv_event_rec_type


) IS
   l_api_name   	CONSTANT VARCHAR2(30)   := 'Seed_RAEEvent';
   l_api_version        CONSTANT NUMBER         := 1.0;

   l_return_status      VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_msg_count          NUMBER := 0;
   l_msg_data           VARCHAR2(8000) := '';
   l_stmt_num           NUMBER := 0;
   l_api_message        VARCHAR2(1000);

   l_rcv_event       	RCV_SeedEvents_PVT.rcv_event_rec_type;
   l_transaction_amount	NUMBER := 0;
   l_source_doc_quantity NUMBER := 0;
   l_transaction_quantity NUMBER := 0;
   l_ic_pricing_option	 NUMBER := 1;
   l_unit_price		NUMBER := 0;
   l_unit_nr_tax	NUMBER := 0;
   l_unit_rec_tax        NUMBER := 0;
   l_prior_nr_tax        NUMBER := 0;
   l_prior_rec_tax        NUMBER := 0;

   l_currency_code	VARCHAR2(15);
   l_currency_conversion_rate	NUMBER;
   l_currency_conversion_date   DATE;
   l_currency_conversion_type   VARCHAR2(30);

   l_incr_transfer_price NUMBER := 0;
   l_incr_currency_code  VARCHAR2(15) := NULL;

   l_dest_org_id	NUMBER;
   l_trx_uom_code	MTL_UNITS_OF_MEASURE.UOM_CODE%TYPE;
   l_primary_uom	MTL_UNITS_OF_MEASURE.UNIT_OF_MEASURE%TYPE;
   l_primary_qty	NUMBER;
   l_credit_acct_id	NUMBER;
   l_debit_acct_id	NUMBER;
   l_ic_cogs_acct_id	NUMBER;
   /* Support for Landed Cost Management */
   l_lcm_acct_id      NUMBER;
   l_unit_landed_cost NUMBER;

   l_asset_option	NUMBER;
   l_expense_option     NUMBER;
   l_detail_accounting_flag VARCHAR2(1);

   l_gl_installed  	BOOLEAN               := FALSE;
   l_status             VARCHAR2(1);
   l_industry           VARCHAR2(1);
   l_oracle_schema      VARCHAR2(30);
   l_encumbrance_flag   VARCHAR2(1);
   l_ussgl_option	VARCHAR2(1);

BEGIN
   -- Standard start of API savepoint
      SAVEPOINT Seed_RAEEvent_PVT;

      l_stmt_num := 0;

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.begin'
             ,'Seed_RAEEvent <<');
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

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         l_api_message := 'Seed_RAEEvent : PARAMETERS 1:'||
			  ' p_event_source : '||p_event_source||
			  ' p_event_type_id : '||p_event_type_id||
			  ' p_rcv_transaction_id : '||p_rcv_transaction_id||
			  ' p_inv_distribution_id : '||p_inv_distribution_id||
			  ' p_po_distribution_id : '||p_po_distribution_id||
			  ' p_direct_delivery_flag : '||p_direct_delivery_flag||
			  ' p_cross_ou_flag : '||p_cross_ou_flag;
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                ,l_api_message);

	 l_api_message := 'Seed_RAEEvent : PARAMETERS 2:'||
                          ' p_procurement_org_flag : '||p_procurement_org_flag||
                          ' p_ship_to_org_flag : '||p_ship_to_org_flag||
                          ' p_drop_ship_flag : '||p_drop_ship_flag||
                          ' p_org_id : '||p_org_id||
                          ' p_organization_id : '||p_organization_id||
                          ' p_transfer_org_id : '||p_transfer_org_id||
                          ' p_transfer_organization_id : '||p_transfer_organization_id||
                          ' p_trx_flow_header_id : '||p_trx_flow_header_id||
                          ' p_unit_price : '||p_unit_price||
                          ' p_prior_unit_price : '||p_prior_unit_price;

         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                ,l_api_message);

      END IF;


      l_stmt_num := 15;
      l_rcv_event.event_source := p_event_source;
      l_rcv_event.event_type_id := p_event_type_id;
      l_rcv_event.rcv_transaction_id := p_rcv_transaction_id;
      l_rcv_event.cross_ou_flag := p_cross_ou_flag;
      l_rcv_event.procurement_org_flag := p_procurement_org_flag;
      l_rcv_event.ship_to_org_flag := p_ship_to_org_flag;
      l_rcv_event.drop_ship_flag := p_drop_ship_flag;
      l_rcv_event.po_distribution_id := p_po_distribution_id;
      l_rcv_event.direct_delivery_flag := p_direct_delivery_flag;

   -- Initialize PO Information
      IF (p_event_source = 'INVOICEMATCH') THEN
     --	This source is only for period end accruals, one-time items
	IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                           ,'Getting PO information from Invoice');
        END IF;

	l_stmt_num := 20;


        SELECT POD.po_header_id,
               POL.po_line_id,
               POD.po_distribution_id,
	       POD.destination_type_code,
               POLL.line_location_id,
               sysdate,
               POL.item_id,
	       APID.quantity_invoiced,
	       POLL.unit_meas_lookup_code,
	       POH.currency_code
        INTO   l_rcv_event.po_header_id,
               l_rcv_event.po_line_id,
               l_rcv_event.po_distribution_id,
	       l_rcv_event.destination_type_code,
               l_rcv_event.po_line_location_id,
               l_rcv_event.transaction_date,
               l_rcv_event.item_id,
	       l_rcv_event.source_doc_quantity,
	       l_rcv_event.source_doc_uom,
	       l_rcv_event.currency_code
        FROM   ap_invoice_distributions	APID,
	       po_distributions POD,
	       po_line_locations POLL,
	       po_lines POL,
	       po_headers POH
	WHERE  APID.invoice_distribution_id 	= p_inv_distribution_id
	AND    POD.po_distribution_id 		= APID.po_distribution_id
	AND    POD.line_location_id 		= POLL.line_location_id
	AND    POL.po_line_id 			= POLL.po_line_id
	AND    POH.po_header_id 		= POD.po_header_id;

        l_rcv_event.inv_distribution_id  := p_inv_distribution_id;
	l_rcv_event.transaction_quantity := l_rcv_event.source_doc_quantity;
	l_rcv_event.transaction_uom 	 := l_rcv_event.source_doc_uom;
      ELSE
	l_stmt_num := 30;

        IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                           ,'Getting PO information from Receiving Transaction');
        END IF;


        SELECT RT.po_header_id,
               RT.po_release_id,
	       RT.po_line_id,
	       RT.po_line_location_id,
	       RT.transaction_date,
	       POL.item_id,
	       POLL.ship_to_organization_id,
	       RT.unit_of_measure,
	       RT.source_doc_unit_of_measure,
	       POH.currency_code,
	       POD.destination_type_code,
               /* Support for Landed Cost Management */
	       rt.unit_landed_cost
        INTO   l_rcv_event.po_header_id,
               l_rcv_event.po_release_id,
               l_rcv_event.po_line_id,
	       l_rcv_event.po_line_location_id,
               l_rcv_event.transaction_date,
	       l_rcv_event.item_id,
	       l_dest_org_id,
               l_rcv_event.transaction_uom,
	       l_rcv_event.source_doc_uom,
               l_rcv_event.currency_code,
	       l_rcv_event.destination_type_code,
               /* Support for Landed Cost Management */
	       l_rcv_event.unit_landed_cost
        FROM   rcv_transactions RT,
	       po_lines POL,
	       po_line_locations POLL,
	       po_headers POH,
	       po_distributions POD
        WHERE  RT.transaction_id 	= p_rcv_transaction_id
	AND    POH.po_header_id 	= RT.po_header_id
        AND    POL.po_line_id 		= RT.po_line_id
	AND    POLL.line_location_id 	= RT.po_line_location_id
	AND    POD.po_distribution_id 	= p_po_distribution_id;

      END IF;

   -- p_transaction_forward_flow_rec represents the transaction flow record where the
   -- start_org_id is the org_id where the event is being seeded.
   -- p_transaction_reverse_flow_rec represents the transaction flow record where the
   -- end_org_id is the org_id where the event is being seeded.
   -- We need both because some information is derived based on the forward flow and
   -- some based on the reverse flow :
   -- transfer_price : based on reverse flow
   -- I/C accrual : based on reverse flow
   -- I/C cogs : based on forward flow. (used in creating transactions in inventory.
   -- The events will be seeded such that the transfer_org_id will represent the reverse
   -- flow.
      l_stmt_num := 40;

      l_rcv_event.org_id := p_org_id;
      l_rcv_event.transfer_org_id := p_transfer_org_id;
      l_rcv_event.organization_id := p_organization_id;
      l_rcv_event.transfer_organization_id := p_transfer_organization_id;
      l_rcv_event.trx_flow_header_id := p_trx_flow_header_id;

   -- Get the Set Of Books Identifier
      l_stmt_num := 50;
      SELECT  ledger_id
      INTO    l_rcv_event.set_of_books_id
      FROM    cst_acct_info_v
      WHERE   organization_id   = p_organization_id;


   -- Initialize transaction date
      IF (p_event_type_id IN (RCV_SeedEvents_PVT.ADJUST_RECEIVE, RCV_SeedEvents_PVT.ADJUST_DELIVER,
			      RCV_SeedEvents_PVT.INTERCOMPANY_INVOICE,RCV_SeedEvents_PVT.INTERCOMPANY_REVERSAL)) THEN
	l_rcv_event.transaction_date := SYSDATE;
      END IF;

   -- Encumbrance cannot be enabled for global procurement scenarios.
      IF(l_rcv_event.trx_flow_header_id IS NULL) THEN
      -- If GL is installed, and either encumbrance is enabled or USSGL profile is enabled,
      -- journal import is called by the receiving TM. The group_id passed by receiving should
      -- be stamped on the event in this scenario.
         l_stmt_num := 60;
         l_gl_installed := FND_INSTALLATION.GET_APP_INFO  ('SQLGL',
                                                       l_status,
                                                       l_industry,
                                                       l_oracle_schema);

         IF(l_status = 'I') THEN
            l_stmt_num := 70;
            IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
               FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                 ,'Checking if encumbrance is enabled.');
            END IF;
            RCV_SeedEvents_PVT.Check_EncumbranceFlag(
                     p_api_version           => 1.0,
                     x_return_status         => l_return_status,
                     x_msg_count             => l_msg_count,
                     x_msg_data              => l_msg_data,
                     p_rcv_sob_id            => l_rcv_event.set_of_books_id,
                     x_encumbrance_flag      => l_encumbrance_flag,
                     x_ussgl_option          => l_ussgl_option);
            IF l_return_status <> FND_API.g_ret_sts_success THEN
               l_api_message := 'Error in checking for encumbrance flag ';
               IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                   FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                       ,'SeedRAEEvents : '||l_stmt_num||' : '||l_api_message);
               END IF;
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

         END IF;
      END IF;

      l_stmt_num := 80;

   -- Check if event is for a service line type
      SELECT decode(POLL.matching_basis, 'AMOUNT', 'Y', 'N')
      INTO   l_rcv_event.service_flag
      FROM   po_line_locations POLL
      WHERE  POLL.line_location_id = l_rcv_event.po_line_location_id;

      l_stmt_num := 90;


   -- Initialize Unit Price
      IF(p_event_type_id IN (RCV_SeedEvents_PVT.ADJUST_RECEIVE,RCV_SeedEvents_PVT.ADJUST_DELIVER)) THEN
	l_rcv_event.unit_price := p_unit_price;
	l_rcv_event.prior_unit_price := p_prior_unit_price;
      ELSIF l_rcv_event.service_flag = 'Y' THEN
	l_stmt_num := 100;

        IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                           ,'Service line type : Getting Transaction Amount');
        END IF;

	Get_TransactionAmount(  p_api_version 		=> l_api_version,
				x_return_status		=> l_return_status,
				x_msg_count		=> l_msg_count,
				x_msg_data		=> l_msg_data,
				p_rcv_event		=> l_rcv_event,
				x_transaction_amount    => l_transaction_amount);
        IF l_return_status <> FND_API.g_ret_sts_success THEN
              l_api_message := 'Error getting transaction amount';
              IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                      ,'Seed_RAEEvent : '||l_stmt_num||' : '||l_api_message);
              END IF;
              RAISE FND_API.g_exc_unexpected_error;
        END IF;

	l_rcv_event.transaction_amount := l_transaction_amount;
      ELSE
	l_stmt_num := 110;

        IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                           ,'Non Service Line Type : Getting Unit Price');
        END IF;

        IF (p_event_type_id NOT IN (RCV_SeedEvents_PVT.INTERCOMPANY_INVOICE,
                                 RCV_SeedEvents_PVT.INTERCOMPANY_REVERSAL)) THEN
	   l_asset_option := p_transaction_reverse_flow_rec.asset_item_pricing_option;
	   l_expense_option := p_transaction_reverse_flow_rec.expense_item_pricing_option;
	ELSE
           l_asset_option := p_transaction_forward_flow_rec.asset_item_pricing_option;
           l_expense_option := p_transaction_forward_flow_rec.expense_item_pricing_option;
	END IF;
	Get_UnitPrice( p_api_version           => l_api_version,
                       x_return_status         => l_return_status,
                       x_msg_count             => l_msg_count,
                       x_msg_data              => l_msg_data,
                       p_rcv_event             => l_rcv_event,
		       p_asset_item_pricing_option => l_asset_option,
		       p_expense_item_pricing_option => l_expense_option,
                      /* Support for Landed Cost Management */
                       p_lcm_flag => p_lcm_flag,
		       x_intercompany_pricing_option => l_ic_pricing_option,
		       x_unit_price		=> l_unit_price,
                      /* Support for Landed Cost Management */
		       x_unit_landed_cost       => l_unit_landed_cost,
		       x_currency_code		=> l_currency_code,
		       x_incr_transfer_price    => l_incr_transfer_price,
		       x_incr_currency_code	=> l_incr_currency_code);
        IF l_return_status <> FND_API.g_ret_sts_success THEN
              l_api_message := 'Error getting unit price';
              IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                      ,'Seed_RAEEvent : '||l_stmt_num||' : '||l_api_message);
              END IF;
              RAISE FND_API.g_exc_unexpected_error;
        END IF;

	l_rcv_event.intercompany_pricing_option := l_ic_pricing_option;
	l_rcv_event.currency_code 		:= l_currency_code;
	l_rcv_event.unit_price 			:= l_unit_price;
	l_rcv_event.intercompany_price 		:= l_incr_transfer_price;
	l_rcv_event.intercompany_curr_code 	:= l_incr_currency_code;
        /* Support for Landed Cost Management */
	l_rcv_event.unit_landed_cost       	:= l_unit_landed_cost;
      END IF;

   -- Initialize Transaction Quantity
      IF l_rcv_event.service_flag = 'N' THEN
        l_stmt_num := 120;

        IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                           ,'Non Service line type : Getting Quantity');
        END IF;

        Get_Quantity(  p_api_version           => l_api_version,
                       x_return_status         => l_return_status,
                       x_msg_count             => l_msg_count,
                       x_msg_data              => l_msg_data,
                       p_rcv_event             => l_rcv_event,
		       x_source_doc_quantity   => l_source_doc_quantity);

        IF l_return_status <> FND_API.g_ret_sts_success THEN
              l_api_message := 'Error getting quantity';
              IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                      ,'Seed_RAEEvent : '||l_stmt_num||' : '||l_api_message);
              END IF;
              RAISE FND_API.g_exc_unexpected_error;
        END IF;

        l_rcv_event.source_doc_quantity := l_source_doc_quantity;

     -- If transaction quantity is 0, then no event should be seeded.
	IF (l_source_doc_quantity = 0) THEN
	   x_return_status := 'W';

           IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
	      l_api_message := 'Transaction Quantity is 0. Returning without seeding event.';
              FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                  ,'Seed_RAEEvent : '||l_stmt_num||' : '||l_api_message);
           END IF;

	   return;
	END IF;

      END IF;


      l_stmt_num := 130;

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                         ,'Getting Tax');
      END IF;
      Get_UnitTax(  p_api_version           => l_api_version,
                    x_return_status         => l_return_status,
                    x_msg_count             => l_msg_count,
                    x_msg_data              => l_msg_data,
                    p_rcv_event             => l_rcv_event,
		    x_unit_nr_tax	    => l_unit_nr_tax,
                    x_unit_rec_tax          => l_unit_rec_tax,
                    x_prior_nr_tax          => l_prior_nr_tax,
                    x_prior_rec_tax         => l_prior_rec_tax);
      IF l_return_status <> FND_API.g_ret_sts_success THEN
         l_api_message := 'Error getting tax';
         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                    ,'Seed_RAEEvent : '||l_stmt_num||' : '||l_api_message);
         END IF;
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      l_rcv_event.unit_nr_tax := l_unit_nr_tax;
      l_rcv_event.unit_rec_tax := l_unit_rec_tax;
      l_rcv_event.prior_nr_tax := l_prior_nr_tax;
      l_rcv_event.prior_rec_tax := l_prior_rec_tax;


      l_stmt_num := 140;

      IF l_rcv_event.service_flag = 'N' THEN
         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
             FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                            ,'Getting UOM');
         END IF;
         Convert_UOM(  p_api_version           => l_api_version,
                       x_return_status         => l_return_status,
                       x_msg_count             => l_msg_count,
                       x_msg_data              => l_msg_data,
                       p_event_rec             => l_rcv_event,
		       x_transaction_qty	    => l_transaction_quantity,
                       x_primary_uom           => l_primary_uom,
		       x_primary_qty	    => l_primary_qty,
		       x_trx_uom_code	    => l_trx_uom_code);
         IF l_return_status <> FND_API.g_ret_sts_success THEN
            l_api_message := 'Error Converting UOM';
            IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
               FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                       ,'Seed_RAEEvent : '||l_stmt_num||' : '||l_api_message);
            END IF;
            RAISE FND_API.g_exc_unexpected_error;
         END IF;

         l_rcv_event.transaction_quantity 	:= l_transaction_quantity;
         l_rcv_event.primary_uom      		:= l_primary_uom;
         l_rcv_event.primary_quantity 		:= l_primary_qty;
         l_rcv_event.trx_uom_code	   	:= l_trx_uom_code;

      END IF;

   -- Initialize Currency Information
      l_stmt_num := 150;


      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                         ,'Getting Currency Information');
      END IF;
      Get_Currency( p_api_version           => l_api_version,
                    x_return_status         => l_return_status,
                    x_msg_count             => l_msg_count,
                    x_msg_data              => l_msg_data,
		    p_rcv_event             => l_rcv_event,
                    x_currency_code         => l_currency_code,
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

      l_rcv_event.currency_code := l_currency_code;
      l_rcv_event.currency_conversion_rate := l_currency_conversion_rate;
      l_rcv_event.currency_conversion_date := l_currency_conversion_date;
      l_rcv_event.currency_conversion_type := l_currency_conversion_type;

   -- Get Debit and Credit Accounts
      l_stmt_num := 160;

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                         ,'Getting Debit and Credit Accounts');
      END IF;

      Get_Accounts(p_api_version           => l_api_version,
                   x_return_status         => l_return_status,
                   x_msg_count             => l_msg_count,
                   x_msg_data              => l_msg_data,
                   p_rcv_event             => l_rcv_event,
                   p_transaction_forward_flow_rec  => p_transaction_forward_flow_rec,
                   p_transaction_reverse_flow_rec  => p_transaction_reverse_flow_rec,
                  /* Support for Landed Cost Management */
		   p_lcm_flag              => p_lcm_flag,
                   x_credit_acct_id        => l_credit_acct_id,
                   x_debit_acct_id         => l_debit_acct_id,
                   x_ic_cogs_acct_id       => l_ic_cogs_acct_id,
                  /* Support for Landed Cost Management */
                   x_lcm_acct_id           => l_lcm_acct_id);
      IF l_return_status <> FND_API.g_ret_sts_success THEN
         l_api_message := 'Error getting account information';
         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                 ,'Seed_RAEEvent : '||l_stmt_num||' : '||l_api_message);
         END IF;
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      l_rcv_event.credit_account_id := l_credit_acct_id;
      l_rcv_event.debit_account_id := l_debit_acct_id;
      l_rcv_event.intercompany_cogs_account_id := l_ic_cogs_acct_id;
      /* Support for Landed Cost Management */
      l_rcv_event.lcm_account_id := l_lcm_acct_id;


      x_rcv_event := l_rcv_event;

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
             ,'Seed_RAEEvent >>');
      END IF;

EXCEPTION
      WHEN FND_API.g_exc_error THEN
         ROLLBACK TO Seed_RAEEvent_PVT;
         x_return_status := FND_API.g_ret_sts_error;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );
      WHEN FND_API.g_exc_unexpected_error THEN

         ROLLBACK TO Seed_RAEEvent_PVT;
         x_return_status := FND_API.g_ret_sts_unexp_error ;
         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

      WHEN OTHERS THEN
         ROLLBACK TO Seed_RAEEvent_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                ,'Seed_RAEEvent '||l_stmt_num||' : '||substr(SQLERRM,1,200));
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

END Seed_RAEEvent;

-- Start of comments
--      API name        : Get_TransactionAmount
--      Type            : Private
--      Function        : Returns the transaction amount. Used for service line types.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_rcv_event    		IN RCV_SeedEvents_PVT.rcv_event_rec_type       Required
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--                              x_transaction_amount    OUT     NUMBER
--      Version :
--                        Initial version       1.0
--
--
--      Notes           : This API returns the transaction amount. It should only be called for service line types.
--
-- End of comments
PROCEDURE Get_TransactionAmount(
                p_api_version           IN      	NUMBER,
                p_init_msg_list         IN      	VARCHAR2,
                p_commit                IN      	VARCHAR2,
                p_validation_level      IN      	NUMBER,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                p_rcv_event		IN 		RCV_SeedEvents_PVT.rcv_event_rec_type,
		x_transaction_amount	OUT NOCOPY 	NUMBER
) IS
   l_api_name   CONSTANT VARCHAR2(30)   := 'Get_TransactionAmount';
   l_api_version        CONSTANT NUMBER         := 1.0;

   l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_msg_count           NUMBER := 0;
   l_msg_data            VARCHAR2(8000) := '';
   l_stmt_num            NUMBER := 0;
   l_api_message         VARCHAR2(1000);

   l_transaction_amount  NUMBER;
   l_po_amount_ordered   NUMBER;
   l_po_amount_delivered NUMBER;
   l_abs_rt_amount       NUMBER;

   l_rcv_txn_type       RCV_Transactions.transaction_type%TYPE;
   l_parent_txn_id      NUMBER;
   l_par_rcv_txn_type   RCV_Transactions.transaction_type%TYPE;

BEGIN
   -- Standard start of API savepoint
      SAVEPOINT Get_TransactionAmount_PVT;

      l_stmt_num := 0;

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.begin'
             ,'Get_TransactionAmount <<');
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

   -- For service line types, only the source types of RECEIVING and INVOICEMATCH
   -- are valid. Retroactive price changes on service line types have no accounting
   -- impact.
      IF(p_rcv_event.event_source = 'RECEIVING') THEN

     -- If receiving transaction has a distribution, entire amount is allocated to
     -- the distribution. Otherwise, the amount has to be prorated based on amount ordered.
	l_stmt_num := 10;
      	SELECT decode(RT.po_distribution_id, NULL,
			RT.amount  * (POD.amount_ordered/POLL.amount),
			RT.amount)
	INTO   l_transaction_amount
	FROM   rcv_transactions RT,
	       po_distributions POD,
	       po_line_locations POLL
	WHERE  RT.transaction_id 	= p_rcv_event.rcv_transaction_id
	AND    POD.po_distribution_id 	= p_rcv_event.po_distribution_id
	AND    POLL.line_location_id 	= p_rcv_event.po_line_location_id;

      ELSIF(p_rcv_event.event_source = 'INVOICEMATCH') THEN

     -- For source of invoice match, there will always be a po_distribution_id
	l_stmt_num := 20;
        SELECT APID.amount
        INTO   l_transaction_amount
        FROM   ap_invoice_distributions APID
        WHERE  APID.invoice_distribution_id = p_rcv_event.inv_distribution_id;

      END IF;

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         l_api_message := 'Transaction Amount : '||l_transaction_amount;
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                ,l_api_message);
      END IF;


   -- For encumbrance reversal events , only reverse encumbrance
   -- upto amount_ordered. If amount received exceeds the
   -- ordered amount, transaction amount should be reduced such that
   -- it does not exceed amount ordered.
      IF(p_rcv_event.event_type_id = RCV_SeedEvents_PVT.ENCUMBRANCE_REVERSAL) THEN
        l_abs_rt_amount := ABS(l_transaction_amount);

        l_stmt_num := 40;
        SELECT RT.transaction_type, RT.parent_transaction_id
        INTO   l_rcv_txn_type, l_parent_txn_id
        FROM   rcv_transactions RT
        WHERE  RT.transaction_id = p_rcv_event.rcv_transaction_id;

        l_stmt_num := 50;
        SELECT PARENT.transaction_type
        INTO   l_par_rcv_txn_type
        FROM   rcv_transactions PARENT
        WHERE  PARENT.transaction_id =l_parent_txn_id;

        l_stmt_num := 60;
        SELECT POD.amount_ordered, POD.amount_delivered
        INTO   l_po_amount_ordered, l_po_amount_delivered
        FROM   po_distributions POD
        WHERE  po_distribution_id = p_rcv_event.po_distribution_id;

        IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           l_api_message := substr('l_rcv_txn_type : '||l_rcv_txn_type||
			    ' l_par_rcv_txn_type : '||l_par_rcv_txn_type||
			    ' l_po_amount_ordered : '||l_po_amount_ordered||
			    ' l_po_amount_delivered : '||l_po_amount_delivered, 1, 1000);
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                ,l_api_message);
        END IF;


        l_stmt_num := 70;

        IF(l_rcv_txn_type = 'DELIVER' OR
           (l_rcv_txn_type = 'CORRECT' AND l_par_rcv_txn_type = 'DELIVER'
                AND l_transaction_amount > 0) OR
           (l_rcv_txn_type = 'CORRECT' AND l_par_rcv_txn_type = 'RETURN TO RECEIVING'
                AND l_transaction_amount < 0)) THEN
	   l_po_amount_delivered := l_po_amount_delivered - l_abs_rt_amount;
           IF (l_po_amount_delivered >= l_po_amount_ordered) THEN
              l_transaction_amount := 0;
           ELSIF(l_abs_rt_amount + l_po_amount_delivered <= l_po_amount_ordered) THEN
              l_transaction_amount := l_abs_rt_amount;
           ELSE
              l_transaction_amount := l_po_amount_ordered - l_po_amount_delivered;
           END IF;
        ELSIF(l_rcv_txn_type = 'RETURN TO VENDOR' OR
           (l_rcv_txn_type = 'CORRECT' AND l_par_rcv_txn_type = 'DELIVER'
                AND p_rcv_event.transaction_amount < 0) OR
           (l_rcv_txn_type = 'CORRECT' AND l_par_rcv_txn_type = 'RETURN TO RECEIVING'
                AND p_rcv_event.transaction_amount > 0)) THEN
	   l_po_amount_delivered := l_po_amount_delivered + l_abs_rt_amount;
           IF (l_po_amount_delivered < l_po_amount_ordered) THEN
              l_transaction_amount := l_abs_rt_amount;
           ELSIF(l_po_amount_delivered - l_abs_rt_amount > l_po_amount_ordered) THEN
              l_transaction_amount := 0;
           ELSE
              l_transaction_amount := l_abs_rt_amount - (l_po_amount_delivered - l_po_amount_ordered);
           END IF;
        END IF;
      END IF;

      x_transaction_amount := l_transaction_amount;

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         l_api_message := 'x_transaction_amount : '||x_transaction_amount;
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
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
             ,'Get_TransactionAmount >>');
      END IF;
EXCEPTION
      WHEN FND_API.g_exc_error THEN
         ROLLBACK TO Get_TransactionAmount_PVT;
         x_return_status := FND_API.g_ret_sts_error;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );
      WHEN FND_API.g_exc_unexpected_error THEN
         ROLLBACK TO Get_TransactionAmount_PVT;
         x_return_status := FND_API.g_ret_sts_unexp_error ;
         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

      WHEN OTHERS THEN
         ROLLBACK TO Get_TransactionAmount_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                ,'Get_TransactionAmount : '||l_stmt_num||' : '||substr(SQLERRM,1,200));
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

END Get_TransactionAmount;

-- Start of comments
--      API name        : Get_Quantity
--      Type            : Private
--      Function        : Returns the quantity in source doc UOM. It includes additional
--			  checks for encumbrance reversal events. We should only
-- 			  encumber upto quantity ordered. If quantity received is
--			  greater than quantity ordered, we should not encumber for
--			  the excess.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_rcv_event             IN RCV_SeedEvents_PVT.rcv_event_rec_type	      Required
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--                              x_source_doc_quantity  OUT     NUMBER
--      Version :
--                        Initial version       1.0
--
--
--      Notes           : This API returns the transaction quantity. It should
--			  only be called for non-service line types.
--
-- End of comments
PROCEDURE Get_Quantity(
                p_api_version           IN      	NUMBER,
                p_init_msg_list         IN      	VARCHAR2,
                p_commit                IN      	VARCHAR2,
                p_validation_level      IN      	NUMBER,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                p_rcv_event             IN RCV_SeedEvents_PVT.rcv_event_rec_type,
		x_source_doc_quantity	OUT NOCOPY	NUMBER
) IS
   l_api_name   CONSTANT VARCHAR2(30)   := 'Get_Quantity';
   l_api_version        CONSTANT NUMBER         := 1.0;

   l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_msg_count           NUMBER := 0;
   l_msg_data            VARCHAR2(8000) := '';
   l_stmt_num            NUMBER := 0;
   l_api_message         VARCHAR2(1000);

   l_source_doc_quantity   NUMBER;
   l_po_quantity_ordered   NUMBER;
   l_po_quantity_delivered NUMBER;
   l_abs_rt_quantity	   NUMBER;

   l_rcv_txn_type	RCV_Transactions.transaction_type%TYPE;
   l_parent_txn_id	NUMBER;
   l_par_rcv_txn_type   RCV_Transactions.transaction_type%TYPE;


BEGIN
   -- Standard start of API savepoint
      SAVEPOINT Get_Quantity_PVT;

      l_stmt_num := 0;

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.begin'
             ,'Get_Quantity <<');
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

      l_stmt_num := 10;

      IF (p_rcv_event.event_source = 'RECEIVING') THEN
	 l_stmt_num := 20;
         SELECT decode(RT.po_distribution_id, NULL,
                        RT.source_doc_quantity * POD.quantity_ordered/POLL.quantity,
                         RT.source_doc_quantity)
         INTO   l_source_doc_quantity
         FROM   rcv_transactions RT,
	        po_line_locations POLL,
	        po_distributions POD
         WHERE  RT.transaction_id 	= p_rcv_event.rcv_transaction_id
         AND    POLL.line_location_id 	= p_rcv_event.po_line_location_id
         AND    POD.po_distribution_id 	= p_rcv_event.po_distribution_id;

      ELSIF (p_rcv_event.event_source = 'RETROPRICE') THEN
	IF(p_rcv_event.event_type_id = RCV_SeedEvents_PVT.ADJUST_RECEIVE) THEN
	   l_stmt_num := 30;
	   l_source_doc_quantity := RCV_ACCRUAL_SV.get_received_quantity(p_rcv_event.rcv_transaction_id, sysdate);
	ELSE
	   l_stmt_num := 40;
	   l_source_doc_quantity := RCV_ACCRUAL_SV.get_delivered_quantity(p_rcv_event.rcv_transaction_id, sysdate);
	END IF;

 	l_stmt_num := 50;
        SELECT decode(RT.po_distribution_id, NULL,
                        l_source_doc_quantity * POD.quantity_ordered/POLL.quantity,
                         l_source_doc_quantity)
         INTO  l_source_doc_quantity
         FROM  rcv_transactions RT,
               po_line_locations POLL,
               po_distributions POD
         WHERE RT.transaction_id 	= p_rcv_event.rcv_transaction_id
         AND   POLL.line_location_id 	= p_rcv_event.po_line_location_id
         AND   POD.po_distribution_id 	= p_rcv_event.po_distribution_id;
      END IF;


   -- For encumbrance reversal events  only match
   -- upto quantity_ordered. If quantity received/invoiced exceeds the
   -- ordered quantity, transaction quantity should be reduced such that
   -- it does not exceed quantity ordered.
      IF(p_rcv_event.event_type_id = RCV_SeedEvents_PVT.ENCUMBRANCE_REVERSAL) THEN
		l_abs_rt_quantity := ABS(l_source_doc_quantity);

	l_stmt_num := 60;
	SELECT RT.transaction_type, RT.parent_transaction_id
	INTO   l_rcv_txn_type, l_parent_txn_id
	FROM   rcv_transactions RT
	WHERE  RT.transaction_id = p_rcv_event.rcv_transaction_id;

	l_stmt_num := 70;
	SELECT PARENT.transaction_type
	INTO   l_par_rcv_txn_type
	FROM   rcv_transactions PARENT
	WHERE  PARENT.transaction_id =l_parent_txn_id;

	l_stmt_num := 80;
	SELECT POD.quantity_ordered, POD.quantity_delivered
	INTO   l_po_quantity_ordered, l_po_quantity_delivered
	FROM   po_distributions POD
	WHERE  POD.po_distribution_id = p_rcv_event.po_distribution_id;

        IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
  	   l_api_message := SUBSTR('l_rcv_txn_type : '||l_rcv_txn_type||
	        		  ' l_parent_txn_id : '||l_parent_txn_id||
	        		  ' l_par_rcv_txn_type : '||l_par_rcv_txn_type||
	        		  ' l_abs_rt_quantity : '||l_abs_rt_quantity||
	        		  ' l_po_quantity_ordered : '||l_po_quantity_ordered||
	        		  ' l_po_quantity_delivered : '||l_po_quantity_delivered,1,1000);
  	   FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
      				,l_api_message);
        END IF;

        /* Bug #3333610. Receiving updates quantity delivered prior to calling the events API.
           Consequently, we should subtract the current quantity from the quantity delivered to
           get the quantity that has been delivered previously. */

	l_stmt_num := 90;
	IF(l_rcv_txn_type = 'DELIVER' OR
	   (l_rcv_txn_type = 'CORRECT' AND l_par_rcv_txn_type = 'DELIVER'
		AND l_source_doc_quantity > 0) OR
	   (l_rcv_txn_type = 'CORRECT' AND l_par_rcv_txn_type = 'RETURN TO RECEIVING'
                AND l_source_doc_quantity < 0)) THEN

	   l_po_quantity_delivered := l_po_quantity_delivered - l_abs_rt_quantity;
	   IF (l_po_quantity_delivered >= l_po_quantity_ordered) THEN
	      l_source_doc_quantity := 0;
	   ELSIF(l_abs_rt_quantity + l_po_quantity_delivered <= l_po_quantity_ordered) THEN
	      NULL; -- l_source_doc_quantity already holds the correct value
	   ELSE
             --BUG#10209325
             if (l_source_doc_quantity > 0) then
	       l_source_doc_quantity := l_po_quantity_ordered - l_po_quantity_delivered;
             else
               l_source_doc_quantity := -1*(l_po_quantity_ordered - l_po_quantity_delivered);
             end if;
	   END IF;
	ELSIF(l_rcv_txn_type = 'RETURN TO RECEIVING' OR
           (l_rcv_txn_type = 'CORRECT' AND l_par_rcv_txn_type = 'DELIVER'
                AND l_source_doc_quantity < 0) OR
           (l_rcv_txn_type = 'CORRECT' AND l_par_rcv_txn_type = 'RETURN TO RECEIVING'
		AND l_source_doc_quantity > 0)) THEN

	   l_po_quantity_delivered := l_po_quantity_delivered + l_abs_rt_quantity;
	   IF (l_po_quantity_delivered <= l_po_quantity_ordered) THEN
              NULL; -- l_source_doc_quantity already holds the correct value
           ELSIF(l_po_quantity_delivered - l_abs_rt_quantity > l_po_quantity_ordered) THEN
              l_source_doc_quantity := 0;
           ELSE
             --BUG#10209325
             if (l_source_doc_quantity > 0) then
              l_source_doc_quantity := l_abs_rt_quantity - (l_po_quantity_delivered - l_po_quantity_ordered);
             else
              l_source_doc_quantity :=-1*( l_abs_rt_quantity - (l_po_quantity_delivered - l_po_quantity_ordered));
             end if;
           END IF;
	END IF;
      END IF;

      x_source_doc_quantity := l_source_doc_quantity;

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         l_api_message := 'x_source_doc_quantity : '||x_source_doc_quantity;
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
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
             ,'Get_Quantity >>');
      END IF;
EXCEPTION
      WHEN FND_API.g_exc_error THEN
         ROLLBACK TO Get_Quantity_PVT;
         x_return_status := FND_API.g_ret_sts_error;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );
      WHEN FND_API.g_exc_unexpected_error THEN
         ROLLBACK TO Get_Quantity_PVT;
         x_return_status := FND_API.g_ret_sts_unexp_error ;
         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

      WHEN OTHERS THEN
         ROLLBACK TO Get_Quantity_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                ,'Get_Quantity : '||l_stmt_num||' : '||substr(SQLERRM,1,200));
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

END Get_Quantity;


-- Start of comments
--      API name        : Get_UnitPrice
--      Type            : Private
--      Function        : Returns the Unit Price. Used for non-service line types.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_rcv_event             IN RCV_SeedEvents_PVT.rcv_event_rec_type       Required
--                              p_lcm_flag              IN VARCHAR2       Optional
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--				x_intercompany_pricing_option	OUT	NUMBER
--				x_unit_price		OUT	NUMBER
--				x_currency_code		OUT	VARCHAR2(15)
--				x_incr_transfer_price	OUT	NUMBER
--				x_incr_currency_code	OUT 	VARCHAR2(15)
--      Version :
--                        Initial version       1.0
--
--
--      Notes           : This API returns the unit price. It should only be called for non service line types.
--
-- End of comments
PROCEDURE Get_UnitPrice(
                p_api_version           IN      	NUMBER,
                p_init_msg_list         IN      	VARCHAR2,
                p_commit                IN      	VARCHAR2,
                p_validation_level      IN      	NUMBER,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,
                p_rcv_event             IN RCV_SeedEvents_PVT.rcv_event_rec_type,
                p_asset_item_pricing_option   IN       NUMBER,
                p_expense_item_pricing_option IN       NUMBER,
                /* Support for Landed Cost Management */
                p_lcm_flag  IN VARCHAR2,
		x_intercompany_pricing_option OUT NOCOPY	NUMBER,
		x_unit_price		OUT NOCOPY	NUMBER,
                /* Support for Landed Cost Management */
		x_unit_landed_cost      OUT NOCOPY	NUMBER,
		x_currency_code		OUT NOCOPY	VARCHAR2,
		x_incr_transfer_price   OUT NOCOPY      NUMBER,
		x_incr_currency_code    OUT NOCOPY      VARCHAR2

) IS
   l_api_name   CONSTANT VARCHAR2(30)   := 'Get_UnitPrice';
   l_api_version        CONSTANT NUMBER         := 1.0;

   l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_msg_count           NUMBER := 0;
   l_msg_data            VARCHAR2(8000) := '';
   l_stmt_num            NUMBER := 0;
   l_api_message         VARCHAR2(1000);

   l_asset_flag         VARCHAR2(1);
   l_ic_pricing_option 	NUMBER := 1;
   l_transfer_price	NUMBER;
   l_unit_price		NUMBER;
   l_transaction_uom	VARCHAR2(3);
   l_currency_code	RCV_ACCOUNTING_EVENTS.CURRENCY_CODE%TYPE;
   l_item_exists	NUMBER;
   l_from_organization_id NUMBER;
   l_from_org_id	NUMBER;
   l_to_org_id		NUMBER;

   l_incr_currency_code RCV_ACCOUNTING_EVENTS.CURRENCY_CODE%TYPE;
   l_incr_transfer_price NUMBER;

BEGIN
   -- Standard start of API savepoint
      SAVEPOINT Get_UnitPrice_PVT;

      l_stmt_num := 0;

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.begin'
             ,'Get_UnitPrice <<');
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
      x_incr_transfer_price := 0;
      x_incr_currency_code := NULL;
      /* Support for Landed Cost Management */
      x_unit_landed_cost := NULL;
      l_currency_code := p_rcv_event.currency_code;

      l_stmt_num := 10;
   -- Always use PO price if :
   -- 1. No transaction flow exists or
   -- 2. Destination type is Shopfloor.
   -- 3. If it is the procurement org
   -- 4. The PO is for a one-time item.

      IF(p_rcv_event.trx_flow_header_id IS NULL OR
	 p_rcv_event.item_id IS NULL OR
	 p_rcv_event.destination_type_code = 'SHOP FLOOR' OR
	 (p_rcv_event.procurement_org_flag = 'Y' AND
	  p_rcv_event.event_type_id NOT IN (RCV_SeedEvents_PVT.INTERCOMPANY_INVOICE,
                                 RCV_SeedEvents_PVT.INTERCOMPANY_REVERSAL))
	 ) THEN
	l_ic_pricing_option := 1;

      ELSE

     -- Pricing Option on the Transaction Flow form will determine whether to use
     -- PO price or Transfer price.
         BEGIN
	 -- Verify that item exists in organization where event is being created.
            l_stmt_num := 30;
            SELECT count(*)
            INTO   l_item_exists
            FROM   mtl_system_items MSI
            WHERE  MSI.inventory_item_id = p_rcv_event.item_id
            AND    MSI.organization_id   = p_rcv_event.organization_id;

	    IF(l_item_exists = 0) THEN
	       FND_MESSAGE.set_name('PO','PO_INVALID_ITEM');
               FND_MSG_pub.add;
               IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  FND_LOG.message(FND_LOG.LEVEL_ERROR,G_LOG_HEAD || '.'||l_api_name||l_stmt_num,FALSE);
               END IF;
               RAISE FND_API.g_exc_error;
	    END IF;

	 -- Use Inventory Asset Flag in the organization where the physical event occurred. This
	 -- would be the ship to organization id. Using POLL.ship_to_organization_id so it will be
	 -- available for both Invoice Match and Receiving events.
            l_stmt_num := 40;
            SELECT MSI.inventory_asset_flag
            INTO   l_asset_flag
            FROM   mtl_system_items MSI,
		   po_line_locations POLL
            WHERE  MSI.inventory_item_id = p_rcv_event.item_id
            AND    MSI.organization_id   = POLL.ship_to_organization_id
	    AND    POLL.line_location_id = p_rcv_event.po_line_location_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.set_name('PO','PO_INVALID_ITEM');
            FND_MSG_pub.add;
            IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
               FND_LOG.message(FND_LOG.LEVEL_ERROR,G_LOG_HEAD || '.'||l_api_name||l_stmt_num,FALSE);
            END IF;
            RAISE FND_API.g_exc_error;
        END;

        IF(l_asset_flag = 'Y') THEN
          l_ic_pricing_option := p_asset_item_pricing_option;
        ELSE
          l_ic_pricing_option := p_expense_item_pricing_option;
        END IF;

      END IF;

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         l_api_message := 'l_ic_pricing_option : '||l_ic_pricing_option;
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                ,l_api_message);
      END IF;

   -- l_ic_pricing_option of 1 => PO Price.
   -- l_ic_pricing_option of 2 => Transfer Price.
      IF(l_ic_pricing_option = 2) THEN
	l_stmt_num := 50;
     -- The l_ic_pricing_option can only be 2 for a source type of 'RECEIVING'.
     -- Get the UOM of the source_doc since unit price is desired in Document's UOM
	SELECT MUOM.uom_code
	INTO   l_transaction_uom
	FROM   rcv_transactions RT, mtl_units_of_measure MUOM
	WHERE  RT.transaction_id = p_rcv_event.rcv_transaction_id
        AND    MUOM.unit_of_measure = RT.source_doc_unit_of_measure;

     -- While calling the transfer pricing API, the from organization id should be
     -- passed. For Intercompany events, the from organization id is the same as
     -- organization_id on the event. For the remaining events, the from organization
     -- is the transfer_organization_id on the event.

	IF(p_rcv_event.event_type_id IN (RCV_SeedEvents_PVT.INTERCOMPANY_INVOICE,
                                 RCV_SeedEvents_PVT.INTERCOMPANY_REVERSAL)) THEN
	   l_from_organization_id := p_rcv_event.organization_id;
	   l_from_org_id 	  := p_rcv_event.org_id;
	   l_to_org_id		  := p_rcv_event.transfer_org_id;
	ELSE
	   l_from_organization_id := p_rcv_event.transfer_organization_id;
	   l_from_org_id          := p_rcv_event.transfer_org_id;
           l_to_org_id            := p_rcv_event.org_id;
	END IF;


     -- Alcoa enhancement. Users will be given the option to determine in which
     -- currency intercompany invoices should be created. The get_transfer_price
     -- API will return the transfer price in the selling OU currency as well in the
     -- currency chosen by the user. The returned values will have to be stored
     -- in MMT and will be used by Intercompany to determine the Currency in which
     -- to create the intercompany invoices.
	l_stmt_num := 60;
        IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           l_api_message := 'Calling get_transfer_price API : '||
			    ' l_from_org_id : '||l_from_org_id||
			    ' l_to_org_id : '||l_to_org_id||
			    ' l_transaction_uom : '||l_transaction_uom||
			    ' item_id : '||p_rcv_event.item_id||
			    ' p_transaction_id : '|| p_rcv_event.rcv_transaction_id;

           FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                  ,l_api_message);
        END IF;
	INV_TRANSACTION_FLOW_PUB.get_transfer_price(
			p_api_version		=> 1.0,
			x_return_status 	=> l_return_status,
			x_msg_data 		=> l_msg_data,
			x_msg_count		=> l_msg_count,
			x_transfer_price	=> l_transfer_price,
			x_currency_code		=> l_currency_code,
			x_incr_transfer_price   => l_incr_transfer_price,
			x_incr_currency_code	=> l_incr_currency_code,
			p_from_org_id		=> l_from_org_id,
			p_to_org_id		=> l_to_org_id,
			p_transaction_uom	=> l_transaction_uom,
			p_inventory_item_id	=> p_rcv_event.item_id,
			p_transaction_id	=> p_rcv_event.rcv_transaction_id,
			p_from_organization_id  => l_from_organization_id,
			p_global_procurement_flag => 'Y',
			p_drop_ship_flag	=> 'N');
         IF l_return_status <> FND_API.g_ret_sts_success THEN
            IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
               l_api_message := 'Error getting transfer price';
               FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                   ,l_api_message);
            END IF;
            RAISE FND_API.g_exc_unexpected_error;
         END IF;

         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            l_api_message := SUBSTR('l_transfer_price : ' || l_transfer_price||
				    ' l_currency_code : '||l_currency_code||
				    ' l_incr_transfer_price : '||l_incr_transfer_price||
				    ' l_incr_currency_code : '||l_incr_currency_code,1000);
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                   ,'Get_TransferPrice : '||l_stmt_num||' : '||l_api_message);
         END IF;

	 l_unit_price := l_transfer_price;
	 x_incr_transfer_price := l_incr_transfer_price;
         x_incr_currency_code := l_incr_currency_code;

      ELSIF (p_rcv_event.event_source = 'RECEIVING' OR p_rcv_event.event_source = 'RETROPRICE') THEN
	l_stmt_num := 70;
	SELECT POLL.price_override
	INTO   l_unit_price
	FROM   po_line_locations POLL
	WHERE  POLL.line_location_id = p_rcv_event.po_line_location_id;

        /* Support for Landed Cost Management */
        IF (p_rcv_event.event_source = 'RECEIVING' AND p_lcm_flag = 'Y') THEN
         SELECT unit_landed_cost
           INTO x_unit_landed_cost
           FROM rcv_transactions
          WHERE transaction_id = p_rcv_event.rcv_transaction_id;

	END IF;

      ELSIF (p_rcv_event.event_source = 'INVOICEMATCH') THEN
	l_stmt_num := 80;
	SELECT APID.unit_price
        INTO   l_unit_price
	FROM   ap_invoice_distributions APID
	WHERE  APID.invoice_distribution_id = p_rcv_event.inv_distribution_id;
      END IF;

      x_intercompany_pricing_option := l_ic_pricing_option;
      x_unit_price := l_unit_price;
      x_currency_code := l_currency_code;

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         l_api_message := SUBSTR('x_ic_pricing_option : '||x_intercompany_pricing_option||
                          ' x_unit_price : '||x_unit_price ||
                          ' x_currency_code : '||x_currency_code||
			  ' x_incr_currency_code : '||x_incr_currency_code||
			  ' x_incr_transfer_price : '||x_incr_transfer_price,1,1000);
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                ,l_api_message);
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
             ,'Get_UnitPrice >>');
      END IF;
EXCEPTION
      WHEN FND_API.g_exc_error THEN
         ROLLBACK TO Get_UnitPrice_PVT;
         x_return_status := FND_API.g_ret_sts_error;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );
      WHEN FND_API.g_exc_unexpected_error THEN
         ROLLBACK TO Get_UnitPrice_PVT;
         x_return_status := FND_API.g_ret_sts_unexp_error ;
         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

      WHEN OTHERS THEN
         ROLLBACK TO Get_UnitPrice_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                ,'Get_UnitPrice : '||l_stmt_num||' : '||substr(SQLERRM,1,200));
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
END Get_UnitPrice;

-- Start of comments
--      API name        : Get_UnitTax
--      Type            : Private
--      Function        : Returns the recoverable and non-recoverable tax.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_rcv_event             IN RCV_SeedEvents_PVT.rcv_event_rec_type       Required
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--				x_unit_nr_tax		OUT 	NUMBER
--				x_unit_rec_tax		OUT	NUMBER
--				x_prior_nr_tax		OUT	NUMBER
--				x_prior_rec_tax		OUT	NUMBER
--      Version :
--                        Initial version       1.0
--
--
--      Notes           : This API returns the tax information.
--
-- End of comments
PROCEDURE Get_UnitTax(
                p_api_version           IN      	NUMBER,
                p_init_msg_list         IN      	VARCHAR2,
                p_commit                IN      	VARCHAR2,
                p_validation_level      IN      	NUMBER,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                p_rcv_event             IN RCV_SeedEvents_PVT.rcv_event_rec_type,
		x_unit_nr_tax		OUT NOCOPY	NUMBER,
                x_unit_rec_tax          OUT NOCOPY      NUMBER,
                x_prior_nr_tax          OUT NOCOPY      NUMBER,
		x_prior_rec_tax		OUT NOCOPY	NUMBER


) IS
   l_api_name   CONSTANT VARCHAR2(30)   := 'Get_UnitTax';
   l_api_version        CONSTANT NUMBER         := 1.0;

   l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_msg_count           NUMBER := 0;
   l_msg_data            VARCHAR2(8000) := '';
   l_stmt_num            NUMBER := 0;
   l_api_message         VARCHAR2(1000);

   l_unit_nr_tax	NUMBER := 0;
   l_unit_rec_tax	NUMBER := 0;
   l_prior_nr_tax	NUMBER := 0;
   l_prior_rec_tax	NUMBER := 0;

   l_recoverable_tax		NUMBER := 0;
   l_non_recoverable_tax    	NUMBER := 0;
   l_old_recoverable_tax    	NUMBER := 0;
   l_old_non_recoverable_tax    NUMBER := 0;

   l_hook_used                  NUMBER;
   l_loc_non_recoverable_tax    NUMBER;
   l_loc_recoverable_tax        NUMBER;
   l_err_num		        NUMBER;
   l_err_code		        VARCHAR2(240);
   l_err_msg		        VARCHAR2(240);

BEGIN
   -- Standard start of API savepoint
      SAVEPOINT Get_UnitTax_PVT;

      l_stmt_num := 0;
      l_hook_used:= 0;

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.begin'
             ,'Get_UnitTax <<');
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
      x_unit_nr_tax   := 0;
      x_unit_rec_tax  := 0;
      x_prior_nr_tax  := 0;
      x_prior_rec_tax := 0;


      l_stmt_num := 10;

   -- No tax is applicable if pricing option is transfer price.
      IF(p_rcv_event.intercompany_pricing_option = 2) THEN
	return;
      END IF;

      IF (p_rcv_event.event_source = 'RECEIVING' OR p_rcv_event.event_source = 'RETROPRICE') THEN
	l_stmt_num := 20;

     -- Call PO API to get current an prior receoverable and non-recoverable tax
	PO_TAX_SV.Get_All_PO_Tax(
		p_api_version           	=> l_api_version,
                x_return_status         	=> l_return_status,
                x_msg_data              	=> l_msg_data,
		p_distribution_id 		=> p_rcv_event.po_distribution_id,
		x_recoverable_tax		=> l_recoverable_tax,
		x_non_recoverable_tax		=> l_non_recoverable_tax,
		x_old_recoverable_tax		=> l_old_recoverable_tax,
		x_old_non_recoverable_tax	=> l_old_non_recoverable_tax);

        IF l_return_status <> FND_API.g_ret_sts_success THEN
              l_api_message := 'Error getting Tax';
              IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                      ,'Get_UnitPrice : '||l_stmt_num||' : '||l_api_message);
              END IF;
              RAISE FND_API.g_exc_unexpected_error;
        END IF;

        IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           l_api_message := SUBSTR('l_recoverable_tax : '||l_recoverable_tax||
                            ' l_non_recoverable_tax : '||l_non_recoverable_tax||
                            ' l_old_recoverable_tax : '||l_old_recoverable_tax||
                            ' l_old_non_recoverable_tax : '||l_old_non_recoverable_tax,1,1000);
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                  ,l_api_message);
        END IF;

     /* Bug 6405593 :Added hook call to override the recoverable and Non-Recoverable
                      taxes for ENCUMBRANCE_REVERSAL event */

      IF(p_rcv_event.event_type_id = RCV_SeedEvents_PVT.ENCUMBRANCE_REVERSAL) THEN
        l_stmt_num := 25;
         l_hook_used := CST_Common_hooks.Get_NRtax_amount(
	                I_ACCT_TXN_ID        =>p_rcv_event.rcv_transaction_id,
	                I_SOURCE_DOC_TYPE    =>'PO',
	                I_SOURCE_DOC_ID      =>p_rcv_event.po_distribution_id,
	                I_ACCT_SOURCE        =>'RCV',
	                I_USER_ID            =>fnd_global.user_id,
	                I_LOGIN_ID           =>fnd_global.login_id,
	                I_REQ_ID             =>fnd_global.conc_request_id,
	                I_PRG_APPL_ID        =>fnd_global.prog_appl_id,
	                I_PRG_ID             =>fnd_global.conc_program_id,
	                O_DOC_NR_TAX         =>l_loc_non_recoverable_tax,
	                O_DOC_REC_TAX        =>l_loc_recoverable_tax,
	                O_Err_Num            =>l_Err_Num,
	                O_Err_Code           =>l_Err_Code,
	                O_Err_Msg            =>l_Err_Msg
				   );
        IF l_hook_used <>0 THEN

	 IF (l_err_num <> 0) THEN
	      -- Error occured
	      l_api_message := 'Error getting Enc Tax error_code : '||l_Err_Code||' Error Message : '||l_Err_Msg;
              IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                      ,'CST_Common_hooks.Get_NRtax_amount : '||l_stmt_num||' : '||l_api_message);
              END IF;
              RAISE FND_API.g_exc_unexpected_error;
	    END IF;


	IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           l_api_message := SUBSTR('Hook Used  CST_Commonlocalization_hooks.Get_NRtax_amount :'|| l_hook_used ||
	                           ' l_loc_recoverable_tax : '||l_loc_recoverable_tax||
                                   ' l_loc_non_recoverable_tax : '||l_loc_non_recoverable_tax,1,1000);
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                  ,l_api_message);
        END IF;

         l_non_recoverable_tax:=nvl(l_non_recoverable_tax,0)+nvl(l_loc_non_recoverable_tax,0);
         l_recoverable_tax    :=nvl(l_recoverable_tax,0)+nvl(l_loc_recoverable_tax,0);

      END IF;
    END IF;
      /* Bug 6405593 :Added hook call to override the recoverable and Non-Recoverable
                      taxes for ENCUMBRANCE_REVERSAL event */

	IF(p_rcv_event.service_flag = 'Y') THEN
	  l_stmt_num := 30;
          SELECT l_non_recoverable_tax/POD.amount_ordered,
                 l_recoverable_tax/POD.amount_ordered
          INTO   l_unit_nr_tax,
                 l_unit_rec_tax
          FROM   po_distributions POD
          WHERE  POD.po_distribution_id = p_rcv_event.po_distribution_id;
	ELSE
	  l_stmt_num := 40;
	  SELECT l_non_recoverable_tax/POD.quantity_ordered,
	         l_recoverable_tax/POD.quantity_ordered
	  INTO   l_unit_nr_tax,
	         l_unit_rec_tax
	  FROM   po_distributions POD
	  WHERE  POD.po_distribution_id = p_rcv_event.po_distribution_id;
	END IF;
      END IF;

      IF (p_rcv_event.event_source = 'RETROPRICE') THEN
        l_stmt_num := 50;
        SELECT l_old_non_recoverable_tax/POD.quantity_ordered,
               l_old_recoverable_tax/POD.quantity_ordered
        INTO   l_prior_nr_tax,
               l_prior_rec_tax
        FROM   po_distributions POD
        WHERE  po_distribution_id = p_rcv_event.po_distribution_id;
      END IF;

      x_unit_nr_tax   := NVL(l_unit_nr_tax,0);
      x_unit_rec_tax  := NVL(l_unit_rec_tax,0);
      x_prior_nr_tax  := NVL(l_prior_nr_tax,0);
      x_prior_rec_tax := NVL(l_prior_rec_tax,0);

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         l_api_message := SUBSTR('x_unit_nr_tax : '||x_unit_nr_tax||
			  ' x_unit_rec_tax : '||x_unit_rec_tax||
			  ' x_prior_nr_tax : '||x_prior_nr_tax||
			  ' x_prior_rec_tax : '||x_prior_rec_tax,1,1000);
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
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
             ,'Get_UnitTax >>');
      END IF;


EXCEPTION
      WHEN FND_API.g_exc_error THEN
         ROLLBACK TO Get_UnitTax_PVT;
         x_return_status := FND_API.g_ret_sts_error;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );
      WHEN FND_API.g_exc_unexpected_error THEN
         ROLLBACK TO Get_UnitTax_PVT;
         x_return_status := FND_API.g_ret_sts_unexp_error ;
         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

      WHEN OTHERS THEN
         ROLLBACK TO Get_UnitTax_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                ,'Get_UnitTax : '||l_stmt_num||' : '||substr(SQLERRM,1,200));
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
END Get_UnitTax;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Convert_UOM     This function updates the record type variable         --
--                  that is passed to it. It inserts the UOM into the      --
--                  primary_uom field, then it updates the primary_        --
--                  quantity with the transaction_quantity converted to    --
--                  the new UOM and it updates the unit_price by           --
--                  converting it with the new UOM.                        --
--                                                                         --
--                  Because there are already other modules under PO_TOP   --
--                  that use the inv_convert package, we can safely use    --
--                  it here without introducing new dependencies on that   --
--                  product.                                               --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  P_API_VERSION      API Version # - REQUIRED: enter 1.0                 --
--  P_INIT_MSG_LIST    Initialize message list? True/False                 --
--  P_COMMIT           Should the API commit before returning? True/False  --
--  X_RETURN_STATUS    Success/Error/Unexplained error - 'S','E', or 'U'   --
--  X_MSG_COUNT        Message Count - # of messages placed in message list--
--  X_MSG_DATA         Message Text - returns msg contents if msg_count = 1--
--  P_EVENT_REC        Record storing an RCV Accounting Event (RAE)        --
--  X_TRANSACTION_QTY  Transaction quantity converted from source doc qty  --
--  X_PRIMARY_UOM      Converted UOM                                       --
--  X_PRIMARY_QTY      Primary quantity converted from source doc qty      --
--  X_TRX_UOM_CODE     Transaction UOM                                     --
--                                                                         --
-- HISTORY:                                                                --
--    06/26/03     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------

PROCEDURE Convert_UOM (
  P_API_VERSION        IN          NUMBER,
  P_INIT_MSG_LIST      IN          VARCHAR2,
  P_COMMIT             IN          VARCHAR2,
  P_VALIDATION_LEVEL   IN          NUMBER,    -- := FND_API.G_VALID_LEVEL_FULL,
  X_RETURN_STATUS      OUT NOCOPY  VARCHAR2,
  X_MSG_COUNT          OUT NOCOPY  NUMBER,
  X_MSG_DATA           OUT NOCOPY  VARCHAR2,
  P_EVENT_REC          IN          RCV_SeedEvents_PVT.rcv_event_rec_type,
  X_TRANSACTION_QTY    OUT NOCOPY  NUMBER,
  X_PRIMARY_UOM        OUT NOCOPY  MTL_UNITS_OF_MEASURE.UNIT_OF_MEASURE%TYPE,
  X_PRIMARY_QTY        OUT NOCOPY  NUMBER,
  X_TRX_UOM_CODE       OUT NOCOPY  VARCHAR2
) IS

-- local control variables
   l_api_name            CONSTANT VARCHAR2(30) := 'Convert_UOM';
   l_api_version         CONSTANT NUMBER       := 1.0;
   l_stmt_num            number := 0;
   l_api_message         VARCHAR2(1000);

-- local data variables
   l_item_id               NUMBER;
   l_primary_uom_rate      NUMBER;
   l_trx_uom_rate          NUMBER;
   l_primary_uom_code      MTL_UNITS_OF_MEASURE.UOM_CODE%TYPE;
   l_source_doc_uom_code   MTL_UNITS_OF_MEASURE.UOM_CODE%TYPE;
   l_trx_uom_code          MTL_UNITS_OF_MEASURE.UOM_CODE%TYPE;
   l_primary_uom           MTL_UNITS_OF_MEASURE.UNIT_OF_MEASURE%TYPE;

BEGIN

     SAVEPOINT Convert_UOM_PVT;
  -- Initialize message list if p_init_msg_list is set to TRUE
     if FND_API.to_Boolean(P_INIT_MSG_LIST) then
       FND_MSG_PUB.initialize;
     end if;

     IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD ||l_api_name||'.begin'
             ,'Convert_UOM <<');
     END IF;

  -- Standard check for compatibility
     IF NOT FND_API.Compatible_API_Call (
                      l_api_version,
                      P_API_VERSION,
                      l_api_name,
                      G_PKG_NAME ) -- line 90
     THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     x_msg_count := 0;
     x_msg_data := '';

  -- API body
     l_stmt_num := 10;
     l_item_id := p_event_rec.item_id;

  -- Get UOM code for the source document's UOM
     SELECT uom_code
     INTO   l_source_doc_uom_code
     FROM   mtl_units_of_measure
     WHERE  unit_of_measure = p_event_rec.source_doc_uom;

  -- Get UOM code for the transaction UOM
     SELECT uom_code
     INTO   l_trx_uom_code
     FROM   mtl_units_of_measure
     WHERE  unit_of_measure = p_event_rec.transaction_uom;


  -- Get UOM for this item/org from MSI and populate primary_uom with it
     IF (l_item_id IS NULL) THEN

    -- for a one-time item, the primary uom is the
    -- base uom for the item's current uom class
       l_stmt_num := 20;
       SELECT PUOM.uom_code, PUOM.unit_of_measure
       INTO   l_primary_uom_code, l_primary_uom
       FROM   mtl_units_of_measure TUOM,
              mtl_units_of_measure PUOM
       WHERE  TUOM.unit_of_measure = p_event_rec.source_doc_uom
       AND    TUOM.uom_class       = PUOM.uom_class
       AND    PUOM.base_uom_flag   = 'Y';

       l_item_id := 0;
     ELSE
       l_stmt_num := 30;
       SELECT primary_uom_code
       INTO   l_primary_uom_code
       FROM   mtl_system_items
       WHERE  organization_id   = p_event_rec.organization_id
       AND    inventory_item_id = l_item_id;

       l_stmt_num := 40;
       SELECT unit_of_measure
       INTO   l_primary_uom
       FROM   mtl_units_of_measure
       WHERE  uom_code = l_primary_uom_code;
     END IF;

  -- Get the UOM rate from source_doc_uom to primary_uom
     l_stmt_num := 50;
     INV_Convert.INV_UM_Conversion(
                        from_unit	=> l_source_doc_uom_code,
                        to_unit		=> l_primary_uom_code,
                        item_id		=> l_item_id,
                        uom_rate	=> l_primary_uom_rate);

     IF (l_primary_uom_rate = -99999) THEN
       RAISE FND_API.G_EXC_ERROR;
       l_api_message := 'inv_convert.inv_um_conversion() failed to get the UOM rate';
       IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.string(FND_LOG.LEVEL_ERROR,G_LOG_HEAD ||l_api_name||'.'||l_stmt_num,
                      l_api_message);
       END IF;
     END IF;

  -- Get the UOM rate from source_doc_uom to transaction_uom
     l_stmt_num := 60;
     INV_Convert.INV_UM_Conversion(
                        from_unit       => l_source_doc_uom_code,
                        to_unit         => l_trx_uom_code,
                        item_id         => l_item_id,
                        uom_rate        => l_trx_uom_rate);

     IF (l_trx_uom_rate = -99999) THEN
       RAISE FND_API.G_EXC_ERROR;
       l_api_message := 'inv_convert.inv_um_conversion() failed to get the UOM rate';
       IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.string(FND_LOG.LEVEL_ERROR,G_LOG_HEAD ||l_api_name||'.'||l_stmt_num,
                      l_api_message);
       END IF;
     END IF;


  -- Populate output variables
     x_primary_uom     := l_primary_uom;
     x_primary_qty     := l_primary_uom_rate * p_event_rec.source_doc_quantity; /*BUG 6838756 Removed rounding*/
     x_transaction_qty := l_trx_uom_rate * p_event_rec.source_doc_quantity; /*BUG 6838756 Removed rounding*/
     x_trx_uom_code    := l_trx_uom_code;

     IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        l_api_message := 'x_primary_uom : '||x_primary_uom||
                         ' x_primary_qty : '||x_primary_qty||
			 ' x_transaction_qty : '||x_transaction_qty||
			 ' x_trx_uom_code : '||x_trx_uom_code;
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
               ,l_api_message);
     END IF;

  -- End of API body

  -- Standard check of P_COMMIT
     IF FND_API.to_Boolean(P_COMMIT) THEN
        COMMIT WORK;
     END IF;

     IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD ||l_api_name||'.end'
                     ,'Convert_UOM >>');
     END IF;

EXCEPTION
      WHEN FND_API.g_exc_error THEN
         ROLLBACK TO Convert_UOM_PVT;
         x_return_status := FND_API.g_ret_sts_error;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN FND_API.g_exc_unexpected_error THEN
         ROLLBACK TO Convert_UOM_PVT;
         x_return_status := FND_API.g_ret_sts_unexp_error;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN NO_DATA_FOUND then
         ROLLBACK TO Convert_UOM_PVT;
         X_RETURN_STATUS := fnd_api.g_ret_sts_error;
         l_api_message := ': Statement # '||to_char(l_stmt_num)||' - No UOM found.';
         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.string(FND_LOG.LEVEL_ERROR,G_LOG_HEAD ||l_api_name||'.'||l_stmt_num,
                        l_api_message);
         END IF;
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
         THEN
               FND_MSG_PUB.add_exc_msg
                 (  G_PKG_NAME,
                    l_api_name || l_api_message
                 );
         END IF;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN OTHERS then
         ROLLBACK TO Convert_UOM_PVT;
         x_return_status := FND_API.g_ret_sts_unexp_error ;
         l_api_message := 'Unexpected Error at statement('||to_char(l_stmt_num)||'): '||to_char(SQLCODE)||'- '|| substrb(SQLERRM,1,100);
         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD ||l_api_name||'.'||l_stmt_num,
                        l_api_message);
         END IF;
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
               FND_MSG_PUB.add_exc_msg
                 (  G_PKG_NAME,
                    l_api_name || l_api_message );
         END IF;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

END Convert_UOM;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Get_Currency    This procedure returns the currency_conversion         --
--                  parameters, conversion rate, date and type             --
--
--                  It is being coded for the purpose of providing the     --
--                  currency conversion parameters for Global Procurement  --
--                  and true drop shipment scenario, but may be used as a  --
--                  generic API to return currency conversion rates for    --
--                  Receiving transactions.                                --
--                                                                         --
--                  Logic:                                                 --
--                  If supplier facing org, if match to po use POD.rate    --
--                                          else                           --
--                                          rcv_transactions.curr_conv_rate--
--                  Else                                                   --
--                  Get the conversion type                                --
--                  Determine currency conversion rate                     --
--                                                                         --
--                                                                         --
--                                                                         --

--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  P_API_VERSION      API Version # - REQUIRED: enter 1.0                 --
--  P_INIT_MSG_LIST    Initialize message list? True/False                 --
--  P_COMMIT           Should the API commit before returning? True/False  --
--  P_RCV_EVENT        Record storing an RCV Accounting Event (RAE)        --
--  X_CURRENCY_CODE                                                        --
--  X_CURRENCY_CONVERSION_RATE                                             --
--  X_CURRENCY_CONVERSION_TYPE                                             --
--  X_CURRENCY_CONVERSION_TYPE                                             --
--  X_RETURN_STATUS    Success/Error/Unexplained error - 'S','E', or 'U'   --
--  X_MSG_COUNT        Message Count - # of messages placed in message list--
--  X_MSG_DATA         Message Text - returns msg contents if msg_count = 1--
--                                                                         --
-- HISTORY:                                                                --
--    08/02/03     Anju Gupta     Created                                  --
-- End of comments                                                         --
-----------------------------------------------------------------------------
PROCEDURE Get_Currency(
  P_API_VERSION                 IN          NUMBER,
  P_INIT_MSG_LIST               IN          VARCHAR2,
  P_COMMIT                      IN          VARCHAR2,
  P_VALIDATION_LEVEL            IN          NUMBER,
  X_RETURN_STATUS               OUT NOCOPY  VARCHAR2,
  X_MSG_COUNT                   OUT NOCOPY  NUMBER,
  X_MSG_DATA                    OUT NOCOPY  VARCHAR2,

  P_RCV_EVENT			IN	    RCV_SeedEvents_PVT.rcv_event_rec_type,
  X_CURRENCY_CODE               OUT NOCOPY  VARCHAR2,
  X_CURRENCY_CONVERSION_RATE    OUT NOCOPY  NUMBER,
  X_CURRENCY_CONVERSION_DATE    OUT NOCOPY  DATE,
  X_CURRENCY_CONVERSION_TYPE    OUT NOCOPY  VARCHAR2
) IS

-- local control variables
   l_api_name            CONSTANT VARCHAR2(30) := 'GET_Currency';
   l_api_version         CONSTANT NUMBER       := 1.0;
   l_stmt_num            number := 0;
   l_api_message         VARCHAR2(1000);

-- local data variables
   l_match_option                VARCHAR2(1);
   l_currency_code               RCV_TRANSACTIONS.currency_code%TYPE;
   l_currency_conversion_rate    NUMBER;
   l_currency_conversion_date    DATE;
   l_currency_conversion_type    RCV_TRANSACTIONS.currency_conversion_type%TYPE := '';
   l_sob_id                      NUMBER;
   l_po_line_location_id         NUMBER;
   l_rcv_transaction_id          NUMBER;


BEGIN

   SAVEPOINT Get_Currency_PVT;

-- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call (
					l_api_version,
					p_api_version,
					l_api_name,
					G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- Initialize message list if p_init_msg_list is set to TRUE
   IF FND_API.to_Boolean(P_INIT_MSG_LIST) then
      FND_MSG_PUB.initialize;
   END IF;


-- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- API body
   l_stmt_num := 10;

   IF ((p_rcv_event.procurement_org_flag = 'Y') AND
       (p_rcv_event.event_type_id NOT IN (RCV_SeedEvents_PVT.INTERCOMPANY_INVOICE,
						  RCV_SeedEvents_PVT.INTERCOMPANY_REVERSAL))) THEN

	l_currency_code := p_rcv_event.currency_code;

	l_stmt_num := 20;
	SELECT line_location_id
	INTO   l_po_line_location_id
	FROM   po_distributions
	WHERE  po_distribution_id = p_rcv_event.po_distribution_id;

	l_stmt_num := 30;
	SELECT match_option
	INTO   l_match_option
	FROM   po_line_locations
	WHERE  line_location_id = l_po_line_location_id;

     -- Always use rate on the PO distribution for encumbrance reversals.
	IF (l_match_option = 'P' OR (p_rcv_event.event_type_id = RCV_SeedEvents_PVT.ENCUMBRANCE_REVERSAL)) THEN

	    l_stmt_num := 40;
	    SELECT nvl(POD.rate,1),
		   POH.rate_type,
		   nvl(POD.rate_date,POD.creation_date) /*Changes for bug 8623413 to take creation date in case rate_date is null */
	    INTO   l_currency_conversion_rate,
		   l_currency_conversion_type,
		   l_currency_conversion_date
	    FROM   po_distributions POD,
		   po_headers POH
	    WHERE  POD.po_distribution_id  = p_rcv_event.po_distribution_id
	    AND    POH.po_header_id 	   = POD.po_header_id;

	ELSE
	-- This is also correct for ADJUST events where we only create one event
	-- for every parent transaction. In the case of a Match to receipt PO, the
	-- currency conversion rate of the child transactions (DELIVER CORRECT, RTR,
	-- RTV) will be the same as the currency conversion rate on the parent
	-- RECEIVE/MATCH transaction. This will be the case even if the daily rate
	-- has changed between the time that the parent transaction was done and the
	-- time that the child transactions were done.

	   l_stmt_num := 50;
	   SELECT RT.currency_conversion_rate,
		  RT.currency_conversion_type,
		  RT.currency_conversion_date
	   INTO   l_currency_conversion_rate,
		  l_currency_conversion_type,
		  l_currency_conversion_date
	   FROM   rcv_transactions RT
	   WHERE  RT.transaction_id = p_rcv_event.rcv_transaction_id;

	END IF;
   ELSE

	l_currency_code := p_rcv_event.currency_code;
	l_sob_id	:= p_rcv_event.set_of_books_id;

     -- Use profile INV: Intercompany Currency conversion Type, to determine Conversion Type
     -- Ensure that INV uses the same type for conversion for GP/ DS scenarios

	l_stmt_num := 70;
	FND_PROFILE.get('IC_CURRENCY_CONVERSION_TYPE', l_currency_conversion_type);

	l_stmt_num := 80;
	l_currency_conversion_rate := GL_Currency_API.get_rate(
						  x_set_of_books_id	=> l_sob_id,
						  x_from_currency	=> l_currency_code,
						  x_conversion_date	=> p_rcv_event.transaction_date,
						  x_conversion_type	=> l_currency_conversion_type);
   END IF;

   x_currency_code 	       := l_currency_code;
   x_currency_conversion_rate  := l_currency_conversion_rate;
   x_currency_conversion_date  := NVL(l_currency_conversion_date,sysdate);
   x_currency_conversion_type  := l_currency_conversion_type;

   IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      l_api_message :=   SUBSTR('x_currency_code : '||x_currency_code||
		         ' x_currency_conversion_rate : '||TO_CHAR(x_currency_conversion_rate)||
			 ' x_currency_conversion_date : '||TO_CHAR(x_currency_conversion_date,'DD-MON-YY')||
			 ' x_currency_conversion_type : '||x_currency_conversion_type,1,1000);
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
               ,l_api_message);
   END IF;


-- End of API body

   FND_MSG_PUB.Count_And_Get (
         p_encoded   => FND_API.G_FALSE,
         p_count     => X_MSG_COUNT,
         p_data      => X_MSG_DATA );


-- Standard check of P_COMMIT
     IF FND_API.to_Boolean(P_COMMIT) THEN
        COMMIT WORK;
     END IF;


EXCEPTION
      WHEN FND_API.g_exc_error THEN
         ROLLBACK TO Get_Currency_PVT;
         x_return_status := FND_API.g_ret_sts_error;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN FND_API.g_exc_unexpected_error THEN
         ROLLBACK TO Get_Currency_PVT;
         x_return_status := FND_API.g_ret_sts_unexp_error ;
         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

      WHEN NO_DATA_FOUND then
         ROLLBACK TO GET_CURRENCY_PVT;
         X_RETURN_STATUS := fnd_api.g_ret_sts_error;
         l_api_message := 'Unexpected Error: '||l_stmt_num||to_char(SQLCODE)||'- '|| substrb(SQLERRM,1,200);
         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.string(FND_LOG.LEVEL_ERROR,G_LOG_HEAD ||l_api_name||'.'||l_stmt_num,
                        l_api_message);
         END IF;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
               FND_MSG_PUB.add_exc_msg
                 (  G_PKG_NAME,
                    l_api_name || 'Statement -'||to_char(l_stmt_num)
                 );
         END IF;

         FND_MSG_PUB.Count_And_Get (
           p_count     => X_MSG_COUNT,
           p_data      => X_MSG_DATA );

      WHEN OTHERS then
         ROLLBACK TO GET_CURRENCY_PVT;
         x_return_status := FND_API.g_ret_sts_unexp_error ;
         l_api_message := 'Unexpected Error: '||l_stmt_num||to_char(SQLCODE)||'- '|| substrb(SQLERRM,1,200);
         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.string(FND_LOG.LEVEL_ERROR,G_LOG_HEAD ||l_api_name||'.'||l_stmt_num,
                        l_api_message);
         END IF;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
               FND_MSG_PUB.add_exc_msg
                 (  G_PKG_NAME,
                    l_api_name || 'Statement -'||to_char(l_stmt_num)
                 );
         END IF;

         FND_MSG_PUB.Count_And_Get (
           p_count     => X_MSG_COUNT,
           p_data      => X_MSG_DATA );

END Get_Currency;



-- Start of comments
--      API name        : Get_Accounts
--      Type            : Private
--      Function        : To get the credit and debit accounts for each event.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_rcv_event             IN RCV_SeedEvents_PVT.rcv_event_rec_type       Required
--                              p_transaction_forward_flow_rec  mtl_transaction_flow_rec_type,
--                              p_transaction_reverse_flow_rec  mtl_transaction_flow_rec_type,
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--				x_credit_acct_id	OUT	NUMBER
--				x_debit_acct_id		OUT	NUMBER
--				x_ic_cogs_acct_id	OUT	NUMBER
--      Version :
--                        Initial version       1.0
--
--
--      Notes           : This API creates all accounting events for RETURN TO VENDOR transactions
--                        in RCV_ACCOUNTING_EVENTS.
--
-- End of comments
PROCEDURE Get_Accounts(
                p_api_version           IN      	NUMBER,
                p_init_msg_list         IN      	VARCHAR2,
                p_commit                IN      	VARCHAR2,
                p_validation_level      IN      	NUMBER,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                p_rcv_event             IN RCV_SeedEvents_PVT.rcv_event_rec_type,
                p_transaction_forward_flow_rec  INV_TRANSACTION_FLOW_PUB.mtl_transaction_flow_rec_type,
                p_transaction_reverse_flow_rec  INV_TRANSACTION_FLOW_PUB.mtl_transaction_flow_rec_type,
                /* Support for Landed Cost Management */
                p_lcm_flag IN VARCHAR2,
		x_credit_acct_id	OUT NOCOPY      NUMBER,
                x_debit_acct_id         OUT NOCOPY      NUMBER,
                x_ic_cogs_acct_id       OUT NOCOPY      NUMBER,
                /* Support for Landed Cost Management */
                x_lcm_acct_id       OUT NOCOPY      NUMBER
) IS
   l_api_name   CONSTANT VARCHAR2(30)   := 'Get_Accounts';
   l_api_version        CONSTANT NUMBER         := 1.0;

   l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_msg_count           NUMBER := 0;
   l_msg_data            VARCHAR2(8000) := '';
   l_stmt_num            NUMBER := 0;
   l_api_message         VARCHAR2(1000);

   l_credit_acct_id	NUMBER;
   l_debit_acct_id	NUMBER;
   l_dist_acct_id	NUMBER;
   l_ic_cogs_acct_id	NUMBER;
   l_ic_coss_acct_id	NUMBER;

   l_pod_accrual_acct_id NUMBER;
   l_pod_ccid		NUMBER;
   l_dest_pod_ccid	NUMBER;
   l_pod_budget_acct_id NUMBER;

   l_receiving_insp_acct_id NUMBER;
   l_clearing_acct_id 	NUMBER;
   l_retroprice_adj_acct_id NUMBER;
   l_overlaid_acct	NUMBER;
   /* Support for Landed Cost Management */
   l_lcm_acct_id NUMBER;

   l_trx_type		rcv_transactions.transaction_type%TYPE;
   l_parent_trx_type    rcv_transactions.transaction_type%TYPE;
   l_parent_trx_id	NUMBER;
   l_account_flag 	NUMBER := 0;
BEGIN
   -- Standard start of API savepoint
      SAVEPOINT Get_Accounts_PVT;

      l_stmt_num := 0;

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.begin'
             ,'Get_Accounts <<');

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
      x_return_status   := FND_API.G_RET_STS_SUCCESS;
      x_credit_acct_id  := NULL;
      x_debit_acct_id   := NULL;
      x_ic_cogs_acct_id := NULL;
      /* Support for Landed Cost Management */
      x_lcm_acct_id     := NULL;

   -- No accounts are stored for IC events.
      l_stmt_num := 5;
      IF(p_rcv_event.event_type_id IN (RCV_SeedEvents_PVT.INTERCOMPANY_INVOICE,
				       RCV_SeedEvents_PVT.INTERCOMPANY_REVERSAL)) THEN
	return;
      END IF;

      l_stmt_num := 10;
      SELECT POD.accrual_account_id,
	     POD.code_combination_id,
	     NVL(POD.dest_charge_account_id,POD.code_combination_id),
	     POD.budget_account_id
      INTO   l_pod_accrual_acct_id,
	     l_pod_ccid,
	     l_dest_pod_ccid,
	     l_pod_budget_acct_id
      FROM   po_distributions POD
      WHERE  POD.po_distribution_id = p_rcv_event.po_distribution_id;

      l_stmt_num := 20;
      SELECT receiving_account_id,
	     clearing_account_id,
	     retroprice_adj_account_id,
             /* Support for Landed Cost Management */
             DECODE(p_lcm_flag, 'Y', lcm_account_id, NULL)
      INTO   l_receiving_insp_acct_id,
	     l_clearing_acct_id,
	     l_retroprice_adj_acct_id,
             /* Support for Landed Cost Management */
             l_lcm_acct_id
      FROM   RCV_PARAMETERS
      WHERE  organization_id = p_rcv_event.organization_id;
   -- Changes for JFMIP. Bug # 3076229. Call API to override the balancing segment
   -- of the Receiving Inspection account for expense destination types. The option
   -- (Auto Offset Override on PO_SYSTEM_PARAMETERS) will only be available in orgs
   -- where encumbrance is enabled. Hence this is not applicable to Global Procurement,
   -- Drop Ship or retroactive pricing.
   -- Modified for bug #4893292: Call API to override balance segment for inventory destinations as well.
      IF(p_rcv_event.trx_flow_header_id IS NULL AND
   	 p_rcv_event.event_type_id IN (RCV_SeedEvents_PVT.RECEIVE, RCV_SeedEvents_PVT.MATCH,
				       RCV_SeedEvents_PVT.DELIVER, RCV_SeedEvents_PVT.CORRECT,
				       RCV_SeedEvents_PVT.RETURN_TO_RECEIVING,
				       RCV_SeedEvents_PVT.RETURN_TO_VENDOR) AND
	 p_rcv_event.destination_type_code IN ('EXPENSE', 'INVENTORY')) THEN

	 l_stmt_num := 30;
	 PO_Accounting_GRP.build_offset_account
            (p_api_version    => 1.0,
             p_init_msg_list  =>  FND_API.G_FALSE,
             x_return_status  => l_return_status,
             p_base_ccid      => l_receiving_insp_acct_id,
             p_overlay_ccid   => l_dest_pod_ccid,
             p_accounting_date =>sysdate,
             p_org_id         => p_rcv_event.org_id,
             x_result_ccid    => l_overlaid_acct
            );

	l_receiving_insp_acct_id := l_overlaid_acct;

      END IF;

      IF( p_rcv_event.event_type_id = RCV_SeedEvents_PVT.CORRECT) THEN

	l_stmt_num := 40;
	SELECT PARENT_TRX.transaction_type
	INTO   l_parent_trx_type
	FROM   rcv_transactions TRX,
	       rcv_transactions PARENT_TRX
	WHERE  TRX.transaction_id 	 = p_rcv_event.rcv_transaction_id
	AND    TRX.parent_transaction_id = PARENT_TRX.transaction_id;
      END IF;

      l_stmt_num := 50;
      IF((p_rcv_event.event_type_id = RCV_SeedEvents_PVT.RECEIVE) OR
	 (p_rcv_event.event_type_id = RCV_SeedEvents_PVT.MATCH) OR
	 (p_rcv_event.event_type_id = RCV_SeedEvents_PVT.CORRECT AND
	  l_parent_trx_type = 'RECEIVE') OR
	 p_rcv_event.event_type_id = RCV_SeedEvents_PVT.CORRECT AND
	  l_parent_trx_type = 'MATCH') THEN

	l_debit_acct_id := l_receiving_insp_acct_id;

	IF(p_rcv_event.procurement_org_flag = 'Y') THEN
	   l_credit_acct_id := l_pod_accrual_acct_id;
	ELSIF(p_rcv_event.item_id IS NULL) THEN
	   l_credit_acct_id := p_transaction_reverse_flow_rec.expense_accrual_account_id;
	ELSE
	   l_credit_acct_id := p_transaction_reverse_flow_rec.inventory_accrual_account_id;
	END IF;

     ELSIF(p_rcv_event.event_type_id = RCV_SeedEvents_PVT.LOGICAL_RECEIVE) THEN

      -- Use clearing account for :
      --     a. destination type of Inventory
      --     b. destination type of Expense for inventory items.
      -- Use Cost of Sales account for
      --     a. destination type of Shop Floor.
      --     b. destination type of Expense for one time items
	IF(p_rcv_event.destination_type_code = 'INVENTORY' OR
	     (p_rcv_event.destination_type_code = 'EXPENSE' AND
	      p_rcv_event.item_id is not null)) THEN
	    l_debit_acct_id := l_clearing_acct_id;
	ELSIF(p_rcv_event.procurement_org_flag = 'Y') THEN
	    l_debit_acct_id := l_pod_ccid;
	ELSE
	    l_stmt_num := 60;
	    SELECT cost_of_sales_account
	    INTO   l_ic_coss_acct_id
	    FROM   mtl_parameters MP
	    WHERE  MP.organization_id = p_rcv_event.organization_id;

	    l_stmt_num := 70;
            RCV_SeedEvents_PVT.Get_HookAccount(
                   p_api_version           => l_api_version,
                   x_return_status         => l_return_status,
                   x_msg_count             => l_msg_count,
                   x_msg_data              => l_msg_data,
                   p_rcv_transaction_id    => p_rcv_event.rcv_transaction_id,
                   p_accounting_line_type  => 'IC Cost Of Sales',
		   p_org_id		   => p_rcv_event.org_id,
                   x_distribution_acct_id  => l_dist_acct_id);

            IF l_return_status <> FND_API.g_ret_sts_success THEN
               l_api_message := 'Error in Get_HookAccount';
               IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                   FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                       ,'Get_Accounts : '||l_stmt_num||' : '||l_api_message);
               END IF;
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

            IF(l_dist_acct_id = -1) THEN
               l_debit_acct_id := l_ic_coss_acct_id;
            ELSE
	       l_debit_acct_id := l_dist_acct_id;
            END IF;

	END IF;

	l_stmt_num := 80;
        IF(p_rcv_event.procurement_org_flag = 'Y') THEN
	    l_credit_acct_id := l_pod_accrual_acct_id;
        ELSIF(p_rcv_event.item_id IS NULL) THEN
             l_credit_acct_id := p_transaction_reverse_flow_rec.expense_accrual_account_id;
        ELSE
             l_credit_acct_id := p_transaction_reverse_flow_rec.inventory_accrual_account_id;
        END IF;

     ELSIF(p_rcv_event.event_type_id = RCV_SeedEvents_PVT.DELIVER OR
	  (p_rcv_event.event_type_id = RCV_SeedEvents_PVT.CORRECT AND
           l_parent_trx_type = 'DELIVER')) THEN
	l_debit_acct_id  := l_dest_pod_ccid;
	l_credit_acct_id := l_receiving_insp_acct_id;

     ELSIF(p_rcv_event.event_type_id = RCV_SeedEvents_PVT.RETURN_TO_VENDOR OR
	  (p_rcv_event.event_type_id = RCV_SeedEvents_PVT.CORRECT AND
           l_parent_trx_type = 'RETURN TO VENDOR')) THEN
        l_credit_acct_id := l_receiving_insp_acct_id;

        IF(p_rcv_event.procurement_org_flag = 'Y') THEN
           l_debit_acct_id := l_pod_accrual_acct_id;
        ELSIF(p_rcv_event.item_id IS NULL) THEN
           l_debit_acct_id := p_transaction_reverse_flow_rec.expense_accrual_account_id;
        ELSE
           l_debit_acct_id := p_transaction_reverse_flow_rec.inventory_accrual_account_id;
        END IF;

     ELSIF(p_rcv_event.event_type_id = RCV_SeedEvents_PVT.LOGICAL_RETURN_TO_VENDOR) THEN
        IF(p_rcv_event.destination_type_code = 'INVENTORY' OR
             (p_rcv_event.destination_type_code = 'EXPENSE' AND
              p_rcv_event.item_id is not null)) THEN
           l_credit_acct_id := l_clearing_acct_id;
        ELSIF(p_rcv_event.procurement_org_flag = 'Y') THEN
           l_credit_acct_id := l_pod_ccid;
        ELSE
	   l_stmt_num := 90;
           SELECT cost_of_sales_account
           INTO   l_ic_coss_acct_id
           FROM   mtl_parameters MP
           WHERE  MP.organization_id = p_rcv_event.organization_id;

           l_stmt_num := 100;
           RCV_SeedEvents_PVT.Get_HookAccount(
                  p_api_version           => l_api_version,
                  x_return_status         => l_return_status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data,
                  p_rcv_transaction_id    => p_rcv_event.rcv_transaction_id,
                  p_accounting_line_type  => 'IC Cost Of Sales',
                  p_org_id                => p_rcv_event.org_id,
                  x_distribution_acct_id  => l_dist_acct_id);

           IF l_return_status <> FND_API.g_ret_sts_success THEN
              l_api_message := 'Error in Get_HookAccount';
              IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                      ,'Get_Accounts : '||l_stmt_num||' : '||l_api_message);
              END IF;
              RAISE FND_API.g_exc_unexpected_error;
           END IF;

           IF(l_dist_acct_id = -1) THEN
              l_credit_acct_id := l_ic_coss_acct_id;
           ELSE
              l_credit_acct_id := l_dist_acct_id;
           END IF;

        END IF;

        IF(p_rcv_event.procurement_org_flag = 'Y') THEN
           l_debit_acct_id := l_pod_accrual_acct_id;
        ELSIF(p_rcv_event.item_id IS NULL) THEN
           l_debit_acct_id := p_transaction_reverse_flow_rec.expense_accrual_account_id;
        ELSE
           l_debit_acct_id := p_transaction_reverse_flow_rec.inventory_accrual_account_id;
        END IF;

     ELSIF(p_rcv_event.event_type_id = RCV_SeedEvents_PVT.RETURN_TO_RECEIVING OR
	  (p_rcv_event.event_type_id = RCV_SeedEvents_PVT.CORRECT AND
           l_parent_trx_type = 'RETURN TO RECEIVING')) THEN
        l_credit_acct_id := l_dest_pod_ccid;
        l_debit_acct_id  := l_receiving_insp_acct_id;

     ELSIF(p_rcv_event.event_type_id = RCV_SeedEvents_PVT.ADJUST_RECEIVE) THEN
     -- In the case of drop shipments, we always use the clearing account instead of the Receiving
     -- Inspection account. In these scenarios, we should be posting the adjustment for the entire
     -- Receipt to the retroactive price adjustment account.
        IF(p_rcv_event.trx_flow_header_id IS NOT NULL OR p_rcv_event.drop_ship_flag IN (1,2)) THEN

       -- For global procurement scenarios, the debit account is :
       -- Retroprice adjustment account for inv items and direct items.
       -- IC Cost Of Sales(Charge acct on POD) for one-time items and Expense destinations.

	  IF ( p_rcv_event.item_id IS NOT NULL OR
	       p_rcv_event.destination_type_code = 'SHOP FLOOR') THEN

            l_stmt_num := 110;
            RCV_SeedEvents_PVT.Get_HookAccount(
                   p_api_version           => l_api_version,
                   x_return_status         => l_return_status,
                   x_msg_count             => l_msg_count,
                   x_msg_data              => l_msg_data,
                   p_rcv_transaction_id    => p_rcv_event.rcv_transaction_id,
                   p_accounting_line_type  => 'Retroprice Adjustment',
                   p_org_id                => p_rcv_event.org_id,
                   x_distribution_acct_id  => l_dist_acct_id);

            IF l_return_status <> FND_API.g_ret_sts_success THEN
               l_api_message := 'Error in Get_HookAccount';
               IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                   FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                       ,'Get_Accounts : '||l_stmt_num||' : '||l_api_message);
               END IF;
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

            IF(l_dist_acct_id = -1) THEN
               l_debit_acct_id := l_retroprice_adj_acct_id;
            ELSE
               l_debit_acct_id := l_dist_acct_id;
            END IF;

	  ELSE
	      l_debit_acct_id := l_pod_ccid;
	  END IF;
	ELSE
          l_debit_acct_id := l_receiving_insp_acct_id;
	END IF;

	l_credit_acct_id := l_pod_accrual_acct_id;

     ELSIF(p_rcv_event.event_type_id = RCV_SeedEvents_PVT.ADJUST_DELIVER) THEN

     -- Redundant check. Transaction flow header id is always NULL. We only
     -- get ADJUST_RECEIVE events for global procurement.
        /* Modified for bug 8832353
	IF(p_rcv_event.trx_flow_header_id IS NULL AND p_rcv_event.drop_ship_flag NOT IN (1,2)) THEN*/
        IF(p_rcv_event.trx_flow_header_id IS NULL AND (p_rcv_event.drop_ship_flag IS NULL OR p_rcv_event.drop_ship_flag NOT IN (1,2))) THEN
	  IF(p_rcv_event.destination_type_code = 'EXPENSE')THEN
	    l_debit_acct_id := l_dest_pod_ccid;
	  ELSE

             l_stmt_num := 120;
             RCV_SeedEvents_PVT.Get_HookAccount(
                   p_api_version           => l_api_version,
                   x_return_status         => l_return_status,
                   x_msg_count             => l_msg_count,
                   x_msg_data              => l_msg_data,
                   p_rcv_transaction_id    => p_rcv_event.rcv_transaction_id,
                   p_accounting_line_type  => 'Retroprice Adjustment',
                   p_org_id                => p_rcv_event.org_id,
                   x_distribution_acct_id  => l_dist_acct_id);

             IF l_return_status <> FND_API.g_ret_sts_success THEN
                l_api_message := 'Error in Get_HookAccount';
                IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                        ,'Get_Accounts : '||l_stmt_num||' : '||l_api_message);
                END IF;
                RAISE FND_API.g_exc_unexpected_error;
             END IF;

             IF(l_dist_acct_id = -1) THEN
                l_debit_acct_id := l_retroprice_adj_acct_id;
             ELSE
                l_debit_acct_id := l_dist_acct_id;
             END IF;
	  END IF;

	  l_stmt_num := 130;
	  l_credit_acct_id := l_receiving_insp_acct_id;
	END IF;

     ELSIF(p_rcv_event.event_type_id = RCV_SeedEvents_PVT.INTERCOMPANY_INVOICE OR
	   p_rcv_event.event_type_id = RCV_SeedEvents_PVT.INTERCOMPANY_REVERSAL)THEN
	l_credit_acct_id := NULL;
	l_debit_acct_id := NULL;

     ELSIF(p_rcv_event.event_type_id = RCV_SeedEvents_PVT.ENCUMBRANCE_REVERSAL) THEN


	l_stmt_num := 140;
	SELECT RT.transaction_type, RT.parent_transaction_id
	INTO   l_trx_type, l_parent_trx_id
	FROM   rcv_transactions RT
	WHERE  RT.transaction_id = p_rcv_event.rcv_transaction_id;

	IF(l_trx_type = 'DELIVER')THEN
           l_credit_acct_id := l_pod_budget_acct_id;
	   l_debit_acct_id := NULL;
	ELSIF (l_trx_type = 'RETURN TO RECEIVING') THEN
           l_debit_acct_id := l_pod_budget_acct_id;
           l_credit_acct_id := NULL;
	ELSIF (l_trx_type = 'CORRECT') THEN

	   l_stmt_num := 150;
           SELECT PARENT_TRX.transaction_type
           INTO   l_parent_trx_type
           FROM   rcv_transactions PARENT_TRX
           WHERE  PARENT_TRX.transaction_id = l_parent_trx_id;

	   IF(l_parent_trx_type = 'DELIVER')THEN
              l_credit_acct_id := l_pod_budget_acct_id;
              l_debit_acct_id := NULL;
           ELSIF (l_parent_trx_type = 'RETURN_TO_RECEIVING') THEN
              l_debit_acct_id := l_pod_budget_acct_id;
              l_credit_acct_id := NULL;
	   END IF;
	END IF;

     END IF;

     x_debit_acct_id   := l_debit_acct_id;
     x_credit_acct_id  := l_credit_acct_id;
     x_ic_cogs_acct_id := p_transaction_forward_flow_rec.intercompany_cogs_account_id;
     /* Support for Landed Cost Management */
     x_lcm_acct_id     := l_lcm_acct_id;

     IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        l_api_message := 'x_debit_acct_id : '||x_debit_acct_id||
                         ' x_credit_acct_id : '||x_credit_acct_id||
                         ' x_ic_cogs_acct_id : ' || x_ic_cogs_acct_id;
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
               ,l_api_message);
     END IF;

     IF ((l_debit_acct_id IS NULL OR l_credit_acct_id IS NULL) AND
	 (p_rcv_event.event_type_id NOT IN (RCV_SeedEvents_PVT.INTERCOMPANY_INVOICE,
					    RCV_SeedEvents_PVT.INTERCOMPANY_REVERSAL,
					    RCV_SeedEvents_PVT.ENCUMBRANCE_REVERSAL))) THEN
        IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      	   l_api_message := 'Unable to find credit and/or debit account. Setup is incomplete. ';
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                  ,l_api_message);
        END IF;

        FND_MESSAGE.set_name('PO','PO_INVALID_ACCOUNT');
        FND_MSG_pub.add;
        IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.message(FND_LOG.LEVEL_ERROR,G_LOG_HEAD || '.'||l_api_name||l_stmt_num,FALSE);
        END IF;
        RAISE FND_API.g_exc_error;
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
           ,'Get_Accounts >>');
    END IF;


EXCEPTION
      WHEN FND_API.g_exc_error THEN
         ROLLBACK TO Get_Accounts_PVT;
         x_return_status := FND_API.g_ret_sts_error;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );
      WHEN FND_API.g_exc_unexpected_error THEN
         ROLLBACK TO Get_Accounts_PVT;
         x_return_status := FND_API.g_ret_sts_unexp_error ;
         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

      WHEN OTHERS THEN
         ROLLBACK TO Get_Accounts_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                ,'Get_Accounts : '||l_stmt_num||' : '||substr(SQLERRM,1,200));
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

END Get_Accounts;

-- Start of comments
--      API name        : Get_HookAccount
--      Type            : Private
--      Function        : Call account hook to  allow customer to override default account.
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
--                              p_accounting_line_type  IN VARCHAR2     Required
--                              p_org_id                IN NUMBER       Required
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--                              x_distribution_acct_id  OUT     NUMBER
--
--      Version :
--                        Initial version       1.0
--
--
--      Notes           : This API creates all accounting events for RETURN TO VENDOR transactions
--                        in RCV_ACCOUNTING_EVENTS.
--
-- End of comments
PROCEDURE Get_HookAccount(
                p_api_version           IN              NUMBER,
                p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE,
                p_commit                IN              VARCHAR2 := FND_API.G_FALSE,
                p_validation_level      IN              NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                p_rcv_transaction_id    IN              NUMBER,
                p_accounting_line_type  IN              VARCHAR2,
                p_org_id                IN              NUMBER,
                x_distribution_acct_id  OUT NOCOPY      NUMBER
) IS
   l_api_name   CONSTANT VARCHAR2(30)   := 'Get_HookAccount';
   l_api_version        CONSTANT NUMBER         := 1.0;

   l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_msg_count           NUMBER := 0;
   l_msg_data            VARCHAR2(8000) := '';
   l_stmt_num            NUMBER := 0;
   l_api_message         VARCHAR2(1000);

   l_dist_acct_id	 NUMBER;
   l_account_flag	 NUMBER;

BEGIN
   -- Standard start of API savepoint
      SAVEPOINT Get_HookAccount_PVT;

      l_stmt_num := 0;

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.begin'
             ,'Get_HookAccount <<');

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
      x_return_status   	:= FND_API.G_RET_STS_SUCCESS;
      x_distribution_acct_id 	:= -1;

      l_stmt_num := 10;
      RCV_AccountHook_PUB.Get_Account(
            p_api_version           => l_api_version,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data,
            p_rcv_transaction_id    => p_rcv_transaction_id,
            p_accounting_line_type  => p_accounting_line_type,
            x_distribution_acct_id  => l_dist_acct_id);

      IF l_return_status <> FND_API.g_ret_sts_success THEN
         l_api_message := 'Error in Account Hook';
         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
             FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
              ,'Get_HookAccount : '||l_stmt_num||' : '||l_api_message);
         END IF;
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      IF(l_dist_acct_id <> -1) THEN

         l_stmt_num := 20;
         SELECT count(*)
         INTO   l_account_flag
         FROM   gl_code_combinations GCC,
                cst_organization_definitions COD
         WHERE  COD.operating_unit        = p_org_id
         AND    COD.chart_of_accounts_id  = GCC.chart_of_accounts_id
         AND    GCC.code_combination_id   = l_dist_acct_id;

         IF(l_account_flag = 0)THEN
              FND_MESSAGE.set_name('PO','PO_INVALID_ACCOUNT');
              FND_MSG_pub.add;
              IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
               FND_LOG.message(FND_LOG.LEVEL_ERROR,G_LOG_HEAD || '.'||l_api_name||l_stmt_num,FALSE);
              END IF;
              RAISE FND_API.g_exc_error;
         END IF;
      END IF;

     x_distribution_acct_id := l_dist_acct_id;

     IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        l_api_message := 'x_distribution_acct_id : '||x_distribution_acct_id;
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
               ,l_api_message);
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
           ,'Get_HookAccount >>');
    END IF;


EXCEPTION
      WHEN FND_API.g_exc_error THEN
         ROLLBACK TO Get_HookAccount_PVT;
         x_return_status := FND_API.g_ret_sts_error;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );
      WHEN FND_API.g_exc_unexpected_error THEN
         ROLLBACK TO Get_HookAccount_PVT;
         x_return_status := FND_API.g_ret_sts_unexp_error ;
         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

      WHEN OTHERS THEN
         ROLLBACK TO Get_HookAccount_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                ,'Get_HookAccount : '||l_stmt_num||' : '||substr(SQLERRM,1,200));
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

END Get_HookAccount;




-- Start of comments
--      API name        : Insert_RAEEvents
--      Type            : Private
--      Function        : To insert events into the Receiving Accounting Events table.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_rcv_events_tbl        IN RCV_SeedEvents_PVT.rcv_event_tbl_type       Required
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--
--
--      Notes           : This API inserts all events for a given receiving transaction
--                        into RCV_ACCOUNTING_EVENTS.
--
-- End of comments
PROCEDURE Insert_RAEEvents(
                p_api_version           IN      	NUMBER,
                p_init_msg_list         IN      	VARCHAR2,
                p_commit                IN      	VARCHAR2,
                p_validation_level      IN      	NUMBER,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                p_rcv_events_tbl        IN RCV_SeedEvents_PVT.rcv_event_tbl_type,
                /* Support for Landed Cost Management */
                p_lcm_flag              IN VARCHAR2
) IS
   l_api_name   CONSTANT VARCHAR2(30)   	:= 'Insert_RAEEvents';
   l_api_version        CONSTANT NUMBER         := 1.0;

   l_return_status       VARCHAR2(1) 		:= fnd_api.g_ret_sts_success;
   l_msg_count           NUMBER 		:= 0;
   l_msg_data            VARCHAR2(8000) 	:= '';
   l_stmt_num            NUMBER 		:= 0;
   l_api_message         VARCHAR2(1000);

   l_summarize_acc_flag VARCHAR2(1) 		:= 'N';

   l_err_num   NUMBER;
   l_err_code  VARCHAR2(240);
   l_err_msg   VARCHAR2(240);
   l_return_code NUMBER;

   l_rcv_transaction_id NUMBER;
   l_del_transaction_id NUMBER;
   l_detail_accounting_flag VARCHAR2(1) 	:= 'Y';
   l_accrue_on_receipt_flag VARCHAR2(1) 	:= 'N';
   l_accounting_event_id	NUMBER;

   l_ctr_first		NUMBER;

   l_project_id NUMBER;
   l_task_id NUMBER;
   l_expenditure_item_date DATE;
   l_expenditure_organization_id NUMBER;
   l_expenditure_type VARCHAR2(30);

BEGIN
   -- Standard start of API savepoint
      SAVEPOINT Insert_RAEEvents_PVT;

      l_stmt_num := 0;

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.begin'
             ,'Insert_RAEEvents <<');

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

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
	 l_api_message := 'Inserting '||p_rcv_events_tbl.count||' events into RAE';
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                ,l_api_message);
      END IF;

      l_ctr_first := p_rcv_events_tbl.FIRST;

   -- Check for accrual option. If accrual option is set to accrue at period-end, don't call the
   -- accounting API.
      l_stmt_num := 20;
      SELECT nvl(poll.accrue_on_receipt_flag, 'N')
      INTO   l_accrue_on_receipt_flag
      FROM   po_line_locations POLL
      WHERE  POLL.line_location_id = p_rcv_events_tbl(l_ctr_first).po_line_location_id;


      FOR i IN p_rcv_events_tbl.FIRST..p_rcv_events_tbl.LAST LOOP
	l_stmt_num := 30;
	SELECT rcv_accounting_event_s.nextval
	INTO   l_accounting_event_id
	FROM   dual;

        IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           l_api_message := SUBSTR('i : '||i||
                        'accounting_event_id : '||l_accounting_event_id||
                        'rcv_transaction_id : '||p_rcv_events_tbl(i).rcv_transaction_id||
                        'po_line_id : '||p_rcv_events_tbl(i).po_line_id||
                        'po_dist_id : '||p_rcv_events_tbl(i).po_distribution_id||
                        'unit_price : '||p_rcv_events_tbl(i).unit_price||
                        'currency : '||p_rcv_events_tbl(i).currency_code||
                        'nr tax : '||p_rcv_events_tbl(i).unit_nr_tax||
                        'rec tax : '||p_rcv_events_tbl(i).unit_rec_tax,1,1000);
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                  ,l_api_message);
        END IF;

     -- We are not doing a bulk insert due to a database limitation. On databases
     -- prior to 9i, you cannot do a bulk insert using a table of records. You have to
     -- multiple tables of scalar types. The expense of converting the table of records
     -- to multiple tables is not worthwhile in this case since we do not expect the
     -- number of rows to exceed 10.
	l_stmt_num := 40;
        INSERT into RCV_ACCOUNTING_EVENTS(
	   accounting_event_id,
	   last_update_date,
           last_updated_by,
           last_update_login,
           creation_date,
           created_by,
           request_id,
           program_application_id,
           program_id,
           program_udpate_date,
	   rcv_transaction_id,
	   event_type_id,
	   event_source,
	   event_source_id,
	   set_of_books_id,
	   org_id,
	   transfer_org_id,
	   organization_id,
	   transfer_organization_id,
	   debit_account_id,
	   credit_account_id,
           /* Support for Landed Cost Management */
	   lcm_account_id,
	   transaction_date,
	   source_doc_quantity,
 	   transaction_quantity,
	   primary_quantity,
           source_doc_unit_of_measure,
	   transaction_unit_of_measure,
	   primary_unit_of_measure,
	   po_header_id,
	   po_release_id,
	   po_line_id,
	   po_line_location_id,
	   po_distribution_id,
	   inventory_item_id,
	   unit_price,
	   prior_unit_price,
	   intercompany_pricing_option,
	   transaction_amount,
	   nr_tax,
           rec_tax,
	   nr_tax_amount,
	   rec_tax_amount,
	   prior_nr_tax,
	   prior_rec_tax,
	   currency_code,
	   currency_conversion_type,
	   currency_conversion_rate,
	   currency_conversion_date,
	   accounted_flag,
	   procurement_org_flag,
	   cross_ou_flag,
	   trx_flow_header_id,
	   invoiced_flag,
	   pa_addition_flag,
           /* Support for Landed Cost Management */
	   unit_landed_cost)
       (SELECT
	   l_accounting_event_id,
           sysdate,
	   fnd_global.user_id,
	   fnd_global.login_id,
	   sysdate,
	   fnd_global.user_id,
           fnd_global.conc_request_id,
           fnd_global.prog_appl_id,
           fnd_global.conc_program_id,
           sysdate,
	   p_rcv_events_tbl(i).rcv_transaction_id,
	   p_rcv_events_tbl(i).event_type_id,
	   p_rcv_events_tbl(i).event_source,
	   decode(p_rcv_events_tbl(i).event_source,
		'INVOICEMATCH', p_rcv_events_tbl(i).inv_distribution_id,
		p_rcv_events_tbl(i).rcv_transaction_id),
	   p_rcv_events_tbl(i).set_of_books_id,
      	   p_rcv_events_tbl(i).org_id,
	   p_rcv_events_tbl(i).transfer_org_id,
	   p_rcv_events_tbl(i).organization_id,
	   p_rcv_events_tbl(i).transfer_organization_id,
	   p_rcv_events_tbl(i).debit_account_id,
	   p_rcv_events_tbl(i).credit_account_id,
           /* Support for Landed Cost Management */
	   p_rcv_events_tbl(i).lcm_account_id,
	   p_rcv_events_tbl(i).transaction_date,
           decode(p_rcv_events_tbl(i).service_flag, 'N',
                        p_rcv_events_tbl(i).source_doc_quantity , NULL)  source_doc_quantity,
	   decode(p_rcv_events_tbl(i).service_flag, 'N',
			p_rcv_events_tbl(i).transaction_quantity , NULL)  transaction_quantity,
           decode(p_rcv_events_tbl(i).service_flag, 'N',
                        p_rcv_events_tbl(i).primary_quantity , NULL)  primary_quantity,
	   p_rcv_events_tbl(i).source_doc_uom,
	   p_rcv_events_tbl(i).transaction_uom,
	   p_rcv_events_tbl(i).primary_uom,
	   p_rcv_events_tbl(i).po_header_id,
	   p_rcv_events_tbl(i).po_release_id,
           p_rcv_events_tbl(i).po_line_id,
           p_rcv_events_tbl(i).po_line_location_id,
	   p_rcv_events_tbl(i).po_distribution_id,
	   p_rcv_events_tbl(i).item_id,
	   decode(p_rcv_events_tbl(i).service_flag, 'N',
	          p_rcv_events_tbl(i).unit_price + p_rcv_events_tbl(i).unit_nr_tax, NULL) unit_price,
	   decode(p_rcv_events_tbl(i).event_source,'RETROPRICE',
		  p_rcv_events_tbl(i).prior_unit_price + p_rcv_events_tbl(i).prior_nr_tax,NULL),
	   p_rcv_events_tbl(i).intercompany_pricing_option,
	   decode(p_rcv_events_tbl(i).service_flag,'Y',
		p_rcv_events_tbl(i).transaction_amount+
		p_rcv_events_tbl(i).transaction_amount * p_rcv_events_tbl(i).unit_nr_tax, NULL),
	   decode(p_rcv_events_tbl(i).service_flag, 'N',
		 p_rcv_events_tbl(i).unit_nr_tax,NULL),
           decode(p_rcv_events_tbl(i).service_flag, 'N',
                 p_rcv_events_tbl(i).unit_rec_tax,NULL),
           decode(p_rcv_events_tbl(i).service_flag, 'Y',
                 p_rcv_events_tbl(i).transaction_amount*p_rcv_events_tbl(i).unit_nr_tax,NULL),
           decode(p_rcv_events_tbl(i).service_flag, 'Y',
                 p_rcv_events_tbl(i).transaction_amount*p_rcv_events_tbl(i).unit_rec_tax,NULL),
	   decode(p_rcv_events_tbl(i).event_source,'RETROPRICE',
		p_rcv_events_tbl(i).prior_nr_tax,NULL),
	   decode(p_rcv_events_tbl(i).event_source,'RETROPRICE',
		p_rcv_events_tbl(i).prior_rec_tax,NULL),
	   p_rcv_events_tbl(i).Currency_code,
	   p_rcv_events_tbl(i).Currency_conversion_type,
	   p_rcv_events_tbl(i).Currency_conversion_rate,
	   p_rcv_events_tbl(i).Currency_conversion_date,
	   'N',
	   p_rcv_events_tbl(i).procurement_org_flag,
	   p_rcv_events_tbl(i).Cross_ou_flag,
	   p_rcv_events_tbl(i).trx_flow_header_id,
	   decode(p_rcv_events_tbl(i).event_type_id,
			RCV_SeedEvents_PVT.INTERCOMPANY_INVOICE,'N',
			RCV_SeedEvents_PVT.INTERCOMPANY_REVERSAL,'N',NULL),
           'N', -- Will be changed by PA process
           /* Support for Landed Cost Management */
	   p_rcv_events_tbl(i).unit_landed_cost
	FROM DUAL);

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         l_api_message := 'Inserted '||SQL%ROWCOUNT||
			  'rows in RAE for org '||p_rcv_events_tbl(i).org_id;
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                ,l_api_message);
      END IF;

      /* For accrue on receipt POs, call the Create_Accounting API to generate accounting entries
	 online. For period-end POs that are not global procurement scenarios, the accounting will
	 be done by the period end accruals process. For global procurement scenarios, the accounting
	 for the procurement org will be done at period end. For all other orgs, the accounting will
	 be done online. */
      IF ((l_accrue_on_receipt_flag = 'Y' OR
	   p_rcv_events_tbl(i).procurement_org_flag = 'N') AND
	   p_rcv_events_tbl(i).event_type_id NOT IN
		(RCV_SeedEvents_PVT.INTERCOMPANY_INVOICE,RCV_SeedEvents_PVT.INTERCOMPANY_REVERSAL)) THEN
         l_stmt_num := 50;
         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                    ,'Creating accounting entries in RRS');
         END IF;

        IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                       ,'Creating accounting entries for accounting_event_id : '||l_accounting_event_id);
        END IF;

     -- Call Account generation API to create accounting entries
        RCV_CreateAccounting_PVT.Create_AccountingEntry(
                  p_api_version           => 1.0,
                  x_return_status         => l_return_status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data,
                  p_accounting_event_id   => l_accounting_event_id,
                  /* Support for Landed Cost Management */
                  p_lcm_flag              => p_lcm_flag);
        IF l_return_status <> FND_API.g_ret_sts_success THEN
           l_api_message := 'Error in Create_AccountingEntry API';
           IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
               FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                   ,'Insert_RAEEvents : '||l_stmt_num||' : '||l_api_message);
           END IF;
           RAISE FND_API.g_exc_unexpected_error;
        END IF;

     -- Call PA API to update pa_addition_flag - bug 5074573 (fp of 4409125)
        l_stmt_num := 55;
		select project_id, task_id, expenditure_item_date, expenditure_organization_id, expenditure_type
		into l_project_id, l_task_id, l_expenditure_item_date, l_expenditure_organization_id, l_expenditure_type
		from po_distributions
		where po_distribution_id = p_rcv_events_tbl(i).po_distribution_id;

      	IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         l_api_message := 'Calling PA_PO_INTEGRATION_UTILS.Update_PA_Addition_Flg with '
                           || 'p_api_version = '|| '1.0'
                           || 'p_rcv_transaction_id = ' || p_rcv_events_tbl(i).rcv_transaction_id
                           || 'p_po_distribution_id = ' || p_rcv_events_tbl(i).po_distribution_id
                           || 'p_accounting_event_id = ' || l_accounting_event_id;
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                ,'Insert_RAEEvents : '||l_stmt_num||' : '||l_api_message);
      	END IF;

		IF l_project_id IS NOT NULL AND l_task_id IS NOT NULL AND l_expenditure_item_date IS NOT NULL
                   AND l_expenditure_organization_id IS NOT NULL AND l_expenditure_type IS NOT NULL THEN
		  l_api_message := 'Calling PA_PO_INTEGRATION_UTILS.Update_PA_Addition_Flg in an IF loop';
		PA_PO_INTEGRATION_UTILS.Update_PA_Addition_Flg (
              p_api_version            => 1.0,
              x_return_status          => l_return_status,
              x_msg_count              => l_msg_count,
              x_msg_data               => l_msg_data,
              p_rcv_transaction_id     => p_rcv_events_tbl(i).rcv_transaction_id,
              p_po_distribution_id     => p_rcv_events_tbl(i).po_distribution_id,
              p_accounting_event_id    => l_accounting_event_id);
        ELSE
		  l_api_message := 'Passing the IF loop that is calling PA_PO_INTEGRATION_UTILS.Update_PA_Addition_Flg';

        END IF;

      	IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         l_api_message := 'PA_PO_INTEGRATION_UTILS.Update_PA_Addition_Flg returned with '
		 		|| 'x_return_status = '|| l_return_status
		 		|| 'x_msg_count = ' || l_msg_count
		 		|| 'x_msg_data = ' || l_msg_data;
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                ,'Insert_RAEEvents : '||l_stmt_num||' : '||l_api_message);
      	END IF;

        IF l_return_status <> FND_API.g_ret_sts_success THEN
           l_api_message := 'Error in PA_PO_INTEGRATION_UTILS.Update_PA_Addition_Flg API';
           IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
               FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                   ,'Insert_RAEEvents : '||l_stmt_num||' : '||l_api_message);
           END IF;
           RAISE FND_API.g_exc_unexpected_error;
        END IF;

      END IF;
   END LOOP;



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
             ,'Insert_RAEEvents >>');
      END IF;


EXCEPTION
      WHEN FND_API.g_exc_error THEN
         ROLLBACK TO Insert_RAEEvents_PVT;
         x_return_status := FND_API.g_ret_sts_error;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN FND_API.g_exc_unexpected_error THEN
         ROLLBACK TO Insert_RAEEvents_PVT;
         x_return_status := FND_API.g_ret_sts_unexp_error ;
         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

      WHEN OTHERS THEN
         ROLLBACK TO Insert_RAEEvents_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                ,'Insert_RAEEvents : '||l_stmt_num||' : '||substr(SQLERRM,1,200));
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

END Insert_RAEEvents;

-- Start of comments
--      API name        : Check_EncumbranceFlag
--      Type            : Private
--      Function        : Checks to see if encumbrance entries need to be created.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--		                p_rcv_sob_id            IN      NUMBER  Required
--		                p_po_header_id          IN      NUMBER  Required
--
--		                x_encumbrance_flag      OUT     VARCHAR2(1)
--				x_ussgl_option		OUT     VARCHAR2(1)
--
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--
--
--      Notes           : This API checks to see if encumbrance entries need to
--			  be created.
--
-- End of comments
PROCEDURE Check_EncumbranceFlag(
                p_api_version           IN      	NUMBER,
                p_init_msg_list         IN      	VARCHAR2,
                p_commit                IN      	VARCHAR2,
                p_validation_level      IN      	NUMBER,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

	  	p_rcv_sob_id		IN 		NUMBER,

		x_encumbrance_flag	OUT NOCOPY 	VARCHAR2,
                x_ussgl_option          OUT NOCOPY      VARCHAR2

) IS
   l_api_name   	CONSTANT VARCHAR2(30)   := 'Check_EncumbranceFlag';
   l_api_version        CONSTANT NUMBER         := 1.0;

   l_return_status      VARCHAR2(1) 		:= fnd_api.g_ret_sts_success;
   l_msg_count          NUMBER 			:= 0;
   l_msg_data           VARCHAR2(8000) 		:= '';
   l_stmt_num           NUMBER 			:= 0;
   l_api_message        VARCHAR2(1000);

   l_encumbrance_flag	VARCHAR2(1);

BEGIN
   -- Standard start of API savepoint
      SAVEPOINT Check_EncumbranceFlag_PVT;

      l_stmt_num := 0;

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.begin'
             ,'Check_EncumbranceFlag <<');
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

      l_stmt_num := 10;
      SELECT nvl(FSP.purch_encumbrance_flag, 'N')
      INTO   l_encumbrance_flag
      FROM   financials_system_parameters FSP
      WHERE  FSP.set_of_books_id = p_rcv_sob_id;

      x_encumbrance_flag := l_encumbrance_flag;
      x_ussgl_option := NVL(FND_PROFILE.VALUE('USSGL_OPTION'),'N');


      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         l_api_message := 'Encumbrance Flag : '||x_encumbrance_flag||
			  ' Ussgl Option : '||x_ussgl_option;
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                ,l_api_message);
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
             ,'Check_EncumbranceFlag >>');
      END IF;


EXCEPTION
      WHEN FND_API.g_exc_error THEN
         ROLLBACK TO Check_EncumbranceFlag_PVT;
         x_return_status := FND_API.g_ret_sts_error;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );
      WHEN FND_API.g_exc_unexpected_error THEN
         ROLLBACK TO Check_EncumbranceFlag_PVT;
         x_return_status := FND_API.g_ret_sts_unexp_error ;
         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

      WHEN OTHERS THEN
         ROLLBACK TO Check_EncumbranceFlag_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                ,'Check_EncumbranceFlag : '||l_stmt_num||' : '||substr(SQLERRM,1,200));
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

END Check_EncumbranceFlag;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Insert_MMTEvents  This API takes a PL/SQL table as input that has one  --
--                    entry for each RAE event. It loops through the table --
--                    and calls Create_MMTRecord to create logical MMT     --
--                    transactions as appropriate for each event.          --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  P_API_VERSION      API Version # - REQUIRED: enter 1.0                 --
--  P_INIT_MSG_LIST    Initialize message list? True/False                 --
--  P_COMMIT           Should the API commit before returning? True/False  --
--  P_VALIDATION_LEVEL Specify the level of validation on the inputs       --
--  P_RCV_EVENTS_TBL   Collection of events of type rcv_event_rec_type     --
--  X_RETURN_STATUS    Success/Error/Unexplained error - 'S','E', or 'U'   --
--  X_MSG_COUNT        Message Count - # of messages placed in message list--
--  X_MSG_DATA         Message Text - returns msg contents if msg_count = 1--
--                                                                         --
-- HISTORY:                                                                --
--    06/26/03     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------

PROCEDURE Insert_MMTEvents (
  P_API_VERSION        IN          NUMBER,
  P_INIT_MSG_LIST      IN          VARCHAR2,
  P_COMMIT             IN          VARCHAR2,
  P_VALIDATION_LEVEL   IN          NUMBER,
  X_RETURN_STATUS      OUT NOCOPY  VARCHAR2,
  X_MSG_COUNT          OUT NOCOPY  NUMBER,
  X_MSG_DATA           OUT NOCOPY  VARCHAR2,
  P_RCV_EVENTS_TBL     IN          RCV_SeedEvents_PVT.rcv_event_tbl_type
) IS
   l_api_name            CONSTANT VARCHAR2(30) 	:= 'Insert_MMTEvents';
   l_api_version         CONSTANT NUMBER 	:= 1.0;
   l_api_message         VARCHAR2(1000);

   l_return_status       VARCHAR2(1) 		:= FND_API.G_RET_STS_SUCCESS;
   l_msg_count           NUMBER 		:= 0;
   l_msg_data            VARCHAR2(8000) 	:= '';
   l_stmt_num            NUMBER 		:= 0;

   l_ctr                 BINARY_INTEGER;
   l_inv_trx_tbl         INV_Logical_Transaction_Global.mtl_trx_tbl_type;
   l_inv_trx_tbl_ctr     BINARY_INTEGER;
   l_correct_ind         BOOLEAN 		:= FALSE; -- indicator variable for whether these
                                       			  -- events are for a correction or not
   l_rcv_txn_type        RCV_TRANSACTIONS.TRANSACTION_TYPE%TYPE;
   l_parent_txn_flag     NUMBER 		:= 1;
   l_intercompany_price  NUMBER; 		-- may include nr tax depending on the pricing option
   l_intercompany_curr_code RCV_ACCOUNTING_EVENTS.CURRENCY_CODE%TYPE;
   l_transfer_organization_id NUMBER		:= NULL;

   invalid_event         EXCEPTION;
BEGIN

-- Standard start of API savepoint
   SAVEPOINT Insert_MMTEvents_PVT;

   l_stmt_num := 0;

   IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD ||l_api_name||'.begin'
             ,'Insert_MMTEvents <<');
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
   x_msg_count := 0;
   x_msg_data := '';

-- API Body
-- Initialize counters
   l_inv_trx_tbl_ctr := 0;
   l_ctr := p_rcv_events_tbl.FIRST;

   l_stmt_num := 10;
-- Determine if this group of events are for a CORRECT txn type
   SELECT transaction_type
   INTO   l_rcv_txn_type
   FROM   rcv_transactions
   WHERE  transaction_id = p_rcv_events_tbl(l_ctr).rcv_transaction_id;

   if (l_rcv_txn_type = 'CORRECT') then
     l_correct_ind := TRUE;
   end if;

-- Loop for every event in the table
   WHILE l_ctr <= p_rcv_events_tbl.LAST LOOP

  -- Logical Events are only seeded in Receiving but not in Inventory for :
  -- 1. Expense destination types for one-time items
  -- 2. Shop Floor destination types (for both OSP and direct items).
     IF(p_rcv_events_tbl(l_ctr).destination_type_code <> 'SHOP FLOOR' AND
	(p_rcv_events_tbl(l_ctr).destination_type_code <> 'EXPENSE' OR
	 p_rcv_events_tbl(l_ctr).item_id IS NOT NULL)) THEN

        IF (p_rcv_events_tbl(l_ctr).ship_to_org_flag = 'N') then

          -- For RAE events, the transfer_organization_id represents the organization from
          -- where the transfer price is derived. Hence in the flow :
          -- OU2 <-------- OU1 <--------- Supplier
          -- The Logical Receive in OU1 will be at PO price and the transfer_org will be NULL.
          -- The Recieve in OU2 could be at transfer price between OU1 and OU2. Hence trasnfer
          -- org will be OU1.
          -- However, in Inventory the Logical Receive in RAE translates to a Logical PO Receipt
          -- and a Logical I/C Sales Issue. The Logical I/C Sales event could be at transfer price.
          -- The transfer organization should therefore be picked up from the next event. To keep
          -- the values for the Logical PO Receipt and the Logical I/C Sales issue consistent, we
          -- will follow this logic for both transactions.

          l_transfer_organization_id := p_rcv_events_tbl(p_rcv_events_tbl.NEXT(l_ctr)).organization_id;

          IF (p_rcv_events_tbl(l_ctr).event_type_id = RCV_SeedEvents_PVT.LOGICAL_RECEIVE) THEN

            l_inv_trx_tbl_ctr := l_inv_trx_tbl_ctr + 1;
            IF (p_rcv_events_tbl(l_ctr).intercompany_pricing_option = 2) then
              l_intercompany_price := p_rcv_events_tbl(l_ctr).intercompany_price;
		  -- Bug #18852061
              IF   p_rcv_events_tbl(l_ctr).source_doc_uom <>  p_rcv_events_tbl(l_ctr).transaction_uom  THEN
              l_intercompany_price :=  l_intercompany_price * (p_rcv_events_tbl(l_ctr).source_doc_quantity / p_rcv_events_tbl(l_ctr).transaction_quantity);
              END IF;
              l_intercompany_curr_code  := p_rcv_events_tbl(l_ctr).intercompany_curr_code;
            ELSE
              l_intercompany_price := p_rcv_events_tbl(l_ctr).unit_price + p_rcv_events_tbl(l_ctr).unit_nr_tax;
              l_intercompany_curr_code  := p_rcv_events_tbl(l_ctr).currency_code;
            END IF;

            IF (l_correct_ind) THEN
              l_stmt_num := 20;
              Create_MMTRecord(p_api_version       => 1.0,
                           p_rcv_event          => p_rcv_events_tbl(l_ctr),
                           p_txn_type_id        => 69,
                           p_intercompany_price => l_intercompany_price,
                           p_intercompany_curr_code => l_intercompany_curr_code,
                           p_acct_id            => p_rcv_events_tbl(l_ctr).debit_account_id,
                           p_sign               => sign(p_rcv_events_tbl(l_ctr).transaction_quantity),
                           p_parent_txn_flag    => l_parent_txn_flag,
                           p_transfer_organization_id => l_transfer_organization_id,
                           x_return_status      => l_return_status,
                           x_msg_count          => l_msg_count,
                           x_msg_data           => l_msg_data,
                           x_inv_trx            => l_inv_trx_tbl(l_inv_trx_tbl_ctr));
            ELSIF (p_rcv_events_tbl(l_ctr).procurement_org_flag = 'Y') THEN
              l_stmt_num := 30;
              Create_MMTRecord(p_api_version       => 1.0,
                           p_rcv_event          => p_rcv_events_tbl(l_ctr),
                           p_txn_type_id        => 19, -- Logical PO Receipt
                           p_intercompany_price => l_intercompany_price,
                           p_intercompany_curr_code => l_intercompany_curr_code,
                           p_acct_id            => p_rcv_events_tbl(l_ctr).debit_account_id,
                           p_sign               => 1,
                           p_parent_txn_flag    => l_parent_txn_flag,
                           p_transfer_organization_id => l_transfer_organization_id,
                           x_return_status      => l_return_status,
                           x_msg_count          => l_msg_count,
                           x_msg_data           => l_msg_data,
                           x_inv_trx            => l_inv_trx_tbl(l_inv_trx_tbl_ctr));
            ELSE
              l_stmt_num := 40;
              Create_MMTRecord(p_api_version       => 1.0,
                           p_rcv_event          => p_rcv_events_tbl(l_ctr),
                           p_txn_type_id        => 22, -- Logical I/C Procurement Receipt
                           p_intercompany_price => l_intercompany_price,
                           p_intercompany_curr_code => l_intercompany_curr_code,
                           p_acct_id            => p_rcv_events_tbl(l_ctr).debit_account_id,
                           p_sign               => 1,
                           p_parent_txn_flag    => l_parent_txn_flag,
                           p_transfer_organization_id => l_transfer_organization_id,
                           x_return_status      => l_return_status,
                           x_msg_count          => l_msg_count,
                           x_msg_data           => l_msg_data,
                           x_inv_trx            => l_inv_trx_tbl(l_inv_trx_tbl_ctr));
            END IF;

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              RAISE FND_API.g_exc_error;
            END IF;

            l_stmt_num := 50;
            l_inv_trx_tbl_ctr := l_inv_trx_tbl_ctr + 1;
            IF (p_rcv_events_tbl(p_rcv_events_tbl.NEXT(l_ctr)).intercompany_pricing_option = 2) THEN
              l_intercompany_price := p_rcv_events_tbl(p_rcv_events_tbl.NEXT(l_ctr)).intercompany_price;
		  -- Bug #18852061
              IF   p_rcv_events_tbl(p_rcv_events_tbl.NEXT(l_ctr)).source_doc_uom <>  p_rcv_events_tbl(p_rcv_events_tbl.NEXT(l_ctr)).transaction_uom  THEN
              l_intercompany_price :=  l_intercompany_price * ((p_rcv_events_tbl(p_rcv_events_tbl.NEXT(l_ctr)).source_doc_quantity) / (p_rcv_events_tbl(p_rcv_events_tbl.NEXT(l_ctr)).transaction_quantity));
              END IF;
              l_intercompany_curr_code := p_rcv_events_tbl(p_rcv_events_tbl.NEXT(l_ctr)).intercompany_curr_code;
            ELSE
              l_intercompany_price := p_rcv_events_tbl(p_rcv_events_tbl.NEXT(l_ctr)).unit_price +
                                   p_rcv_events_tbl(p_rcv_events_tbl.NEXT(l_ctr)).unit_nr_tax;
              l_intercompany_curr_code :=p_rcv_events_tbl(p_rcv_events_tbl.NEXT(l_ctr)).currency_code;
            END IF;

            IF (p_rcv_events_tbl(l_ctr).transaction_quantity > 0) THEN
              l_stmt_num := 60;
              Create_MMTRecord(p_api_version       => 1.0,
                           p_rcv_event          => p_rcv_events_tbl(l_ctr),
                           p_txn_type_id        => 11, -- Logical I/C Sales Issue
                           p_intercompany_price => l_intercompany_price,
                           p_intercompany_curr_code => l_intercompany_curr_code,
                           p_acct_id            => p_rcv_events_tbl(l_ctr).intercompany_cogs_account_id,
                           p_sign               => -1,
                           p_parent_txn_flag    => 0,
                           p_transfer_organization_id => l_transfer_organization_id,
                           x_return_status      => l_return_status,
                           x_msg_count          => l_msg_count,
                           x_msg_data           => l_msg_data,
                           x_inv_trx            => l_inv_trx_tbl(l_inv_trx_tbl_ctr));
            ELSE
              l_stmt_num := 70;
              Create_MMTRecord(p_api_version       => 1.0,
                           p_rcv_event          => p_rcv_events_tbl(l_ctr),
                           p_txn_type_id        => 14, -- Logical I/C Sales Return
                           p_intercompany_price => l_intercompany_price,
                           p_intercompany_curr_code => l_intercompany_curr_code,
                           p_acct_id            => p_rcv_events_tbl(l_ctr).intercompany_cogs_account_id,
                           p_sign               => 1,
                           p_parent_txn_flag    => 0,
                           p_transfer_organization_id => l_transfer_organization_id,
                           x_return_status      => l_return_status,
                           x_msg_count          => l_msg_count,
                           x_msg_data           => l_msg_data,
                           x_inv_trx            => l_inv_trx_tbl(l_inv_trx_tbl_ctr));
            END IF;
            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
              RAISE FND_API.g_exc_error;
            END IF;

          ELSIF (p_rcv_events_tbl(l_ctr).event_type_id = RCV_SeedEvents_PVT.LOGICAL_RETURN_TO_VENDOR) THEN
            l_stmt_num := 80;
            l_inv_trx_tbl_ctr := l_inv_trx_tbl_ctr + 1;
            IF (p_rcv_events_tbl(l_ctr).intercompany_pricing_option = 2) then
              l_intercompany_price := p_rcv_events_tbl(l_ctr).intercompany_price;
		  -- Bug #18852061
              IF   p_rcv_events_tbl(l_ctr).source_doc_uom <>  p_rcv_events_tbl(l_ctr).transaction_uom  THEN
              l_intercompany_price :=  l_intercompany_price * (p_rcv_events_tbl(l_ctr).source_doc_quantity / p_rcv_events_tbl(l_ctr).transaction_quantity);
              END IF;
              l_intercompany_curr_code  := p_rcv_events_tbl(l_ctr).intercompany_curr_code;
            ELSE
              l_intercompany_price := p_rcv_events_tbl(l_ctr).unit_price + p_rcv_events_tbl(l_ctr).unit_nr_tax;
              l_intercompany_curr_code  := p_rcv_events_tbl(l_ctr).currency_code;
            END IF;

            IF (l_correct_ind) THEN
              l_stmt_num := 90;
              Create_MMTRecord(p_api_version       => 1.0,
                           p_rcv_event          => p_rcv_events_tbl(l_ctr),
                           p_txn_type_id        => 69,
                           p_intercompany_price => l_intercompany_price,
                           p_intercompany_curr_code => l_intercompany_curr_code,
                           p_acct_id            => p_rcv_events_tbl(l_ctr).credit_account_id,
                           p_sign               => -1*sign(p_rcv_events_tbl(l_ctr).transaction_quantity),
                           p_parent_txn_flag    => l_parent_txn_flag,
                           p_transfer_organization_id => l_transfer_organization_id,
                           x_return_status      => l_return_status,
                           x_msg_count          => l_msg_count,
                           x_msg_data           => l_msg_data,
                           x_inv_trx            => l_inv_trx_tbl(l_inv_trx_tbl_ctr));

            ELSIF (p_rcv_events_tbl(l_ctr).procurement_org_flag = 'Y') THEN
              l_stmt_num := 100;
              Create_MMTRecord(p_api_version       => 1.0,
                           p_rcv_event          => p_rcv_events_tbl(l_ctr),
                           p_txn_type_id        => 39, -- Logical RTV
                           p_intercompany_price => l_intercompany_price,
                           p_intercompany_curr_code => l_intercompany_curr_code,
                           p_acct_id            => p_rcv_events_tbl(l_ctr).credit_account_id,
                           p_sign               => -1,
                           p_parent_txn_flag    => l_parent_txn_flag,
                           p_transfer_organization_id => l_transfer_organization_id,
                           x_return_status      => l_return_status,
                           x_msg_count          => l_msg_count,
                           x_msg_data           => l_msg_data,
                           x_inv_trx            => l_inv_trx_tbl(l_inv_trx_tbl_ctr));
            ELSE
              l_stmt_num := 110;
              Create_MMTRecord(p_api_version       => 1.0,
                           p_rcv_event          => p_rcv_events_tbl(l_ctr),
                           p_txn_type_id        => 23, -- Logical I/C Procurement Return
                           p_intercompany_price => l_intercompany_price,
                           p_intercompany_curr_code => l_intercompany_curr_code,
                           p_acct_id            => p_rcv_events_tbl(l_ctr).credit_account_id,
                           p_sign               => -1,
                           p_parent_txn_flag    => l_parent_txn_flag,
                           p_transfer_organization_id => l_transfer_organization_id,
                           x_return_status      => l_return_status,
                           x_msg_count          => l_msg_count,
                           x_msg_data           => l_msg_data,
                           x_inv_trx            => l_inv_trx_tbl(l_inv_trx_tbl_ctr));
            END IF;

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              RAISE FND_API.g_exc_error;
            END IF;

            l_stmt_num := 120;
            l_inv_trx_tbl_ctr := l_inv_trx_tbl_ctr + 1;

            IF (p_rcv_events_tbl(p_rcv_events_tbl.NEXT(l_ctr)).intercompany_pricing_option = 2) then
              l_intercompany_price := p_rcv_events_tbl(p_rcv_events_tbl.NEXT(l_ctr)).intercompany_price;
	      -- Bug #18852061
			  IF   p_rcv_events_tbl(p_rcv_events_tbl.NEXT(l_ctr)).source_doc_uom <>  p_rcv_events_tbl(p_rcv_events_tbl.NEXT(l_ctr)).transaction_uom  THEN
              l_intercompany_price :=  l_intercompany_price * ((p_rcv_events_tbl(p_rcv_events_tbl.NEXT(l_ctr)).source_doc_quantity) / (p_rcv_events_tbl(p_rcv_events_tbl.NEXT(l_ctr)).transaction_quantity));
              END IF;
              l_intercompany_curr_code := p_rcv_events_tbl(p_rcv_events_tbl.NEXT(l_ctr)).intercompany_curr_code;
            ELSE
              l_intercompany_price := p_rcv_events_tbl(p_rcv_events_tbl.NEXT(l_ctr)).unit_price +
                                      p_rcv_events_tbl(p_rcv_events_tbl.NEXT(l_ctr)).unit_nr_tax;
              l_intercompany_curr_code := p_rcv_events_tbl(p_rcv_events_tbl.NEXT(l_ctr)).currency_code;
            END IF;

            IF (p_rcv_events_tbl(l_ctr).transaction_quantity > 0) THEN
              l_stmt_num := 130;
              Create_MMTRecord(p_api_version       => 1.0,
                           p_rcv_event          => p_rcv_events_tbl(l_ctr),
                           p_txn_type_id        => 14, -- Logical I/C Sales Return
                           p_intercompany_price => l_intercompany_price,
                           p_intercompany_curr_code => l_intercompany_curr_code,
                           p_acct_id            => p_rcv_events_tbl(l_ctr).intercompany_cogs_account_id,
                           p_sign               => 1,
                           p_parent_txn_flag    => 0,
                           p_transfer_organization_id => l_transfer_organization_id,
                           x_return_status      => l_return_status,
                           x_msg_count          => l_msg_count,
                           x_msg_data           => l_msg_data,
                           x_inv_trx            => l_inv_trx_tbl(l_inv_trx_tbl_ctr));
            else
              l_stmt_num := 140;
              Create_MMTRecord(p_api_version       => 1.0,
                           p_rcv_event          => p_rcv_events_tbl(l_ctr),
                           p_txn_type_id        => 11, -- Logical I/C Sales Issue
                           p_intercompany_price => l_intercompany_price,
                           p_intercompany_curr_code => l_intercompany_curr_code,
                           p_acct_id            => p_rcv_events_tbl(l_ctr).intercompany_cogs_account_id,
                           p_sign               => -1,
                           p_parent_txn_flag    => 0,
                           p_transfer_organization_id => l_transfer_organization_id,
                           x_return_status      => l_return_status,
                           x_msg_count          => l_msg_count,
                           x_msg_data           => l_msg_data,
                           x_inv_trx            => l_inv_trx_tbl(l_inv_trx_tbl_ctr));
            END IF;
            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
              RAISE FND_API.g_exc_error;
            END IF;

          ELSE
           RAISE invalid_event;
           -- catch error: should never get anything but Log rcpt or Log RTV
          END IF;
          l_parent_txn_flag := 0; -- the first transaction inserted will be the parent, all others
                                  -- will be children so their flags are 0
        END IF;
     END IF;

     l_ctr := p_rcv_events_tbl.NEXT(l_ctr);
   END LOOP;

   IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                     ,'Creating Logical Transactions in MMT');
   END IF;

   l_stmt_num := 150;
   INV_Logical_Transactions_PUB.Create_Logical_Transactions(
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        p_api_version_number    => 1.0,
        p_mtl_trx_tbl           => l_inv_trx_tbl,
        p_trx_flow_header_id    => p_rcv_events_tbl(p_rcv_events_tbl.FIRST).trx_flow_header_id,
        p_defer_logical_transactions => 2,
        p_logical_trx_type_code => 3,
        p_exploded_flag         => 1);
   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE FND_API.g_exc_error;
   END IF;

-- End API Body

-- Standard check of p_commit
   IF FND_API.to_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD ||l_api_name||'.end'
          ,'Insert_MMTEvents >>');
   END IF;

EXCEPTION

      WHEN invalid_event THEN
         ROLLBACK TO Insert_MMTEvents_PVT;
         x_return_status := FND_API.g_ret_sts_unexp_error ;
         l_api_message := 'Unexpected event in element '||to_char(l_ctr)||
                          ' of input parameter p_rcv_events_tbl';
         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.string(FND_LOG.LEVEL_ERROR,G_LOG_HEAD ||l_api_name||'.'||l_stmt_num,
                        l_api_message);
         END IF;
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
               FND_MSG_PUB.add_exc_msg
                 (  G_PKG_NAME,
                    l_api_name ||': '|| l_api_message );
         END IF;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN FND_API.g_exc_error THEN
         ROLLBACK TO Insert_MMTEvents_PVT;
         x_return_status := FND_API.g_ret_sts_error;
         l_api_message := 'Call to procedure failed';
         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.string(FND_LOG.LEVEL_ERROR,G_LOG_HEAD ||l_api_name||'.'||l_stmt_num,
                        l_api_message);
         END IF;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN FND_API.g_exc_unexpected_error THEN
         ROLLBACK TO Insert_MMTEvents_PVT;
         x_return_status := FND_API.g_ret_sts_unexp_error;
         l_api_message := 'Wrong version #, expecting version '||to_char(l_api_version);
         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD ||l_api_name||'.'||l_stmt_num,
                        l_api_message);
         END IF;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN OTHERS THEN
         ROLLBACK TO Insert_MMTEvents_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;
         l_api_message := 'Unexpected Error: '||l_stmt_num||': '||to_char(SQLCODE)||'- '|| substrb(SQLERRM,1,100);
         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD ||l_api_name||'.'||l_stmt_num,
                        l_api_message);
         END IF;
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
               FND_MSG_PUB.add_exc_msg
                 (  G_PKG_NAME,
                    l_api_name ||': '|| l_api_message );
         END IF;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

END Insert_MMTEvents;


-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Create_MMTRecord  This API takes an RAE record along with the          --
--                    parameters listed above and converts them into a     --
--                    single MMT record which will be used in a subsequent --
--                    function to make the physical insert into MMT        --
--                                                                         --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  P_API_VERSION      API Version # - REQUIRED: enter 1.0                 --
--  P_INIT_MSG_LIST    Initialize message list? True/False                 --
--  P_COMMIT           Should the API commit before returning? True/False  --
--  P_VALIDATION_LEVEL Specify the level of validation on the inputs       --
--  X_RETURN_STATUS    Success/Error/Unexplained error - 'S','E', or 'U'   --
--  X_MSG_COUNT        Message Count - # of messages placed in message list--
--  X_MSG_DATA         Message Text - returns msg contents if msg_count = 1--
--  P_RCV_EVENT        Represents a single RAE, used to build the MMT entry--
--  P_TXN_TYPE_ID      Txn Type ID of the new MMT row being created        --
--  P_INTERCOMPANY_PRICE  The calling fcn must determine how to populate   --
--                     this based on the txn type and on the OU's position --
--                     in the txn flow. It will represent the transfer     --
--                     price between this OU and an adjacent one.          --
--  P_INTERCOMPANY_CURR_CODE This parameter represents the currency code   --
--		       of the intercompany price.		   	   --
--  P_ACCT_ID          Used to populate MMT.distribution_account_id        --
--  P_SIGN             Used to set the signs (+/-) of the primary quantity --
--                     and the transaction quantity                        --
--  P_PARENT_TXN_FLAG  1 - Indicates that this is the parent transaction   --
--  P_TRANSFER_ORGANIZATION_ID The calling function should pass the        --
--		       organization from the next event.		   --
--  X_INV_TRX          Returns the record that will be inserted into MMT   --
--                                                                         --
-- HISTORY:                                                                --
--    7/21/03     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------
PROCEDURE Create_MMTRecord(
                p_api_version           IN      	NUMBER,
                p_init_msg_list         IN      	VARCHAR2,
                p_commit                IN      	VARCHAR2,
                p_validation_level      IN      	NUMBER,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,
                p_rcv_event             IN      RCV_SeedEvents_PVT.rcv_event_rec_type,
                p_txn_type_id           IN      	NUMBER,
                p_intercompany_price    IN      	NUMBER,
                p_intercompany_curr_code IN	    	VARCHAR2,
                p_acct_id               IN      	NUMBER,
                p_sign                  IN      	NUMBER,
                p_parent_txn_flag       IN      	NUMBER,
                p_transfer_organization_id IN 		NUMBER,
                x_inv_trx               OUT NOCOPY      INV_LOGICAL_TRANSACTION_GLOBAL.mtl_trx_rec_type
) IS
   l_api_name            CONSTANT VARCHAR2(30) 	:= 'Create_MMTRecord';
   l_api_version         CONSTANT NUMBER 	:= 1.0;
   l_api_message         VARCHAR2(1000);

   l_return_status       VARCHAR2(1) 		:= fnd_api.g_ret_sts_success;
   l_msg_count           NUMBER 		:= 0;
   l_msg_data            VARCHAR2(8000) 	:= '';
   l_stmt_num            NUMBER 		:= 0;

   l_ctr                 BINARY_INTEGER;
   l_unit_price          NUMBER;
   l_inv_trx             INV_LOGICAL_TRANSACTION_GLOBAL.mtl_trx_rec_type;

   l_le_id               NUMBER; -- holds legal entity ID for timezone conversion
   l_le_txn_date         DATE;   -- transaction date truncated and converted to legal entity timezone

   invalid_txn_type      EXCEPTION;
BEGIN

-- Standard start of API savepoint
   SAVEPOINT Create_MMTRecord_PVT;

   IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD ||'.'||l_api_name||'.begin'
          ,'Create_MMTRecord <<');
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
   x_msg_count := 0;
   x_msg_data := '';

-- API Body
   l_inv_trx.intercompany_pricing_option := p_rcv_event.intercompany_pricing_option;

   l_stmt_num := 5;

   -- Assign transaction action, source type, and invoiced flag
   IF (p_txn_type_id = 11) THEN
     l_inv_trx.transaction_action_id := 9;
     l_inv_trx.transaction_source_type_id := 13;
     l_inv_trx.invoiced_flag := 'N';
   ELSIF (p_txn_type_id = 14) THEN
     l_inv_trx.transaction_action_id := 14;
     l_inv_trx.transaction_source_type_id := 13;
     l_inv_trx.invoiced_flag := 'N';
   ELSIF (p_txn_type_id = 69) THEN
     l_inv_trx.transaction_action_id := 11;
     l_inv_trx.transaction_source_type_id := 1;
     IF (p_rcv_event.procurement_org_flag = 'Y') THEN
        l_inv_trx.invoiced_flag := NULL;
        l_inv_trx.intercompany_pricing_option := 1;
     ELSE
        l_inv_trx.invoiced_flag := 'N';
     END IF;
   ELSIF (p_txn_type_id = 19) THEN
     l_inv_trx.transaction_action_id := 26;
     l_inv_trx.transaction_source_type_id := 1;
     l_inv_trx.invoiced_flag := NULL;
     l_inv_trx.intercompany_pricing_option := 1;
   ELSIF (p_txn_type_id = 22) THEN
     l_inv_trx.transaction_action_id := 10;
     l_inv_trx.transaction_source_type_id := 13;
     l_inv_trx.invoiced_flag := 'N';
   ELSIF (p_txn_type_id = 23) THEN
     l_inv_trx.transaction_action_id := 13;
     l_inv_trx.transaction_source_type_id := 13;
     l_inv_trx.invoiced_flag := 'N';
   ELSIF (p_txn_type_id = 39) THEN
     l_inv_trx.transaction_action_id := 7;
     l_inv_trx.transaction_source_type_id := 1;
     l_inv_trx.invoiced_flag := NULL;
     l_inv_trx.intercompany_pricing_option := 1;
   ELSE
     l_api_message := 'Invalid transaction type';
     RAISE invalid_txn_type;
   END IF;

-- Set currency columns
   l_stmt_num := 20;
   IF (p_txn_type_id in (19,39)) THEN
        l_inv_trx.currency_code := p_rcv_event.currency_code;
        l_inv_trx.currency_conversion_rate := p_rcv_event.currency_conversion_rate;
        l_inv_trx.currency_conversion_type := p_rcv_event.currency_conversion_type;
        l_inv_trx.currency_conversion_date := sysdate;
   ELSE
        l_inv_trx.currency_code := NULL;
        l_inv_trx.currency_conversion_rate := NULL;
        l_inv_trx.currency_conversion_type := NULL;
        l_inv_trx.currency_conversion_date := NULL;
   END IF;

   l_stmt_num := 30;
-- Compute unit price and intercompany price
   IF (p_rcv_event.intercompany_pricing_option = 2) THEN
     l_unit_price := p_rcv_event.unit_price * p_rcv_event.source_doc_quantity/p_rcv_event.primary_quantity;
   ELSE
     l_unit_price := (p_rcv_event.unit_price + p_rcv_event.unit_nr_tax) *
                      p_rcv_event.source_doc_quantity/p_rcv_event.primary_quantity;
   END IF;

   l_stmt_num := 40;
   l_api_message := 'No data';
-- Main select statement to populate the l_inv_trx record
   SELECT
        p_rcv_event.organization_id,
        p_rcv_event.item_id,
        p_txn_type_id,
        rt.po_header_id,
        P_SIGN * ABS(p_rcv_event.transaction_quantity),
        p_rcv_event.trx_uom_code,
        P_SIGN * ABS(p_rcv_event.primary_quantity),
        rt.transaction_date,
        decode(nvl(fc.minimum_accountable_unit,0), 0,
                round(l_unit_price*p_rcv_event.primary_quantity,fc.precision)*
                        p_rcv_event.currency_conversion_rate/p_rcv_event.primary_quantity,
                round(l_unit_price*
                        p_rcv_event.primary_quantity/fc.minimum_accountable_unit) *
                fc.minimum_accountable_unit*p_rcv_event.currency_conversion_rate/p_rcv_event.primary_quantity),
        'RCV',
        rt.transaction_id,
        rt.transaction_id,
        p_transfer_organization_id,
        NULL, --pod.project_id,  remove these 2 because projects will cause failure in inv's create_logical_txns
        NULL, --pod.task_id,     since they are only expected values in the org that does the deliver
        poll.ship_to_location_id,
        1,
        p_rcv_event.trx_flow_header_id,
        decode(nvl(fc.minimum_accountable_unit,0), 0,
                round(p_intercompany_price*p_rcv_event.primary_quantity,fc.precision)
                /p_rcv_event.primary_quantity,
                round(p_intercompany_price*
                        p_rcv_event.primary_quantity/fc.minimum_accountable_unit) *
                fc.minimum_accountable_unit
                /p_rcv_event.primary_quantity),
        p_intercompany_curr_code,
        p_acct_id,
        'N',
        NULL,
        NULL,
        p_parent_txn_flag,
        NULL
   INTO
        l_inv_trx.organization_id,
        l_inv_trx.inventory_item_id,
        l_inv_trx.transaction_type_id,
        l_inv_trx.transaction_source_id,
        l_inv_trx.transaction_quantity,
        l_inv_trx.transaction_uom,
        l_inv_trx.primary_quantity,
        l_inv_trx.transaction_date,
        l_inv_trx.transaction_cost,
        l_inv_trx.source_code,
        l_inv_trx.source_line_id,
        l_inv_trx.rcv_transaction_id,
        l_inv_trx.transfer_organization_id,
        l_inv_trx.project_id,
        l_inv_trx.task_id,
        l_inv_trx.ship_to_location_id,
        l_inv_trx.transaction_mode,
        l_inv_trx.trx_flow_header_id,
        l_inv_trx.intercompany_cost,
        l_inv_trx.intercompany_currency_code,
        l_inv_trx.distribution_account_id,
        l_inv_trx.costed_flag,
        l_inv_trx.subinventory_code,
        l_inv_trx.locator_id,
        l_inv_trx.parent_transaction_flag,
        l_inv_trx.trx_source_line_id
   FROM rcv_transactions RT,
        po_lines POL,
        po_line_locations POLL,
        po_distributions POD,
        fnd_currencies FC
   WHERE RT.transaction_id 	= p_rcv_event.rcv_transaction_id
   AND   POL.po_line_id		= p_rcv_event.po_line_id
   AND   POLL.line_location_id  = p_rcv_event.po_line_location_id
   AND   POD.po_distribution_id	= p_rcv_event.po_distribution_id
   AND   FC.currency_code 	= p_rcv_event.currency_code;

   l_stmt_num := 50;
   l_api_message := 'Inventory accounting period not open.';
   /* get the legal entity for timezone conversion */
   SELECT to_number(org_information2)
   INTO l_le_id
   FROM hr_organization_information
   WHERE organization_id = p_rcv_event.organization_id
   AND org_information_context = 'Accounting Information';

   l_stmt_num := 55;
   /* convert the transaction date into legal entity timezone (truncated) */
   l_le_txn_date := INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_SERVER(l_inv_trx.transaction_date, l_le_id);

   l_stmt_num := 60;
   /* retrieve the accounting period ID */
   SELECT acct_period_id
   INTO   l_inv_trx.acct_period_id
   FROM   org_acct_periods
   WHERE  organization_id = p_rcv_event.organization_id
   AND    l_le_txn_date BETWEEN period_start_date AND schedule_close_date
   AND    open_flag = 'Y';

   /* -- comment out this call for ST bug 3261222
   OE_DROP_SHIP_GRP.Get_Drop_Ship_Line_Ids(
        p_po_header_id 		=> p_rcv_event.po_header_id,
        p_po_line_id 		=> p_rcv_event.po_line_id,
        p_po_line_location_id 	=> p_rcv_event.po_line_location_id,
        p_po_release_id 	=> l_po_release_id,
        x_line_id 		=> l_inv_trx.trx_source_line_id,
        x_num_lines 		=> l_so_num_lines,
        x_header_id 		=> l_so_header_id,
        x_org_id    		=> l_so_org_id);
   */


   X_INV_TRX := l_inv_trx;
-- ***************

-- Standard check of p_commit
   IF FND_API.to_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

-- Standard Call to get message count and if count = 1, get message info
   FND_MSG_PUB.Count_And_Get (
       p_count     => x_msg_count,
       p_data      => x_msg_data );

  IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD ||'.'||l_api_name||'.end'
         ,'Create_MMTRecord >>');
  END IF;

EXCEPTION

      WHEN FND_API.g_exc_error THEN
         ROLLBACK TO Create_MMTRecord_PVT;
         x_return_status := FND_API.g_ret_sts_error;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN FND_API.g_exc_unexpected_error THEN
         ROLLBACK TO Create_MMTRecord_PVT;
         x_return_status := FND_API.g_ret_sts_unexp_error ;
         l_api_message := 'Unexpected error at statement '||to_char(l_stmt_num);
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
               FND_MSG_PUB.add_exc_msg
                 (  G_PKG_NAME,
                    l_api_name ||': '|| l_api_message );
         END IF;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN invalid_txn_type THEN
         ROLLBACK TO Create_MMTRecord_PVT;
         x_return_status := FND_API.g_ret_sts_error ;
         l_api_message := 'Unexpected transaction type passed in: '||to_char(p_txn_type_id);
         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.string(FND_LOG.LEVEL_ERROR,G_LOG_HEAD ||l_api_name||'.'||l_stmt_num,
                        l_api_message);
         END IF;
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
               FND_MSG_PUB.add_exc_msg
                 (  G_PKG_NAME,
                    l_api_name ||': '|| l_api_message );
         END IF;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN NO_DATA_FOUND THEN
         ROLLBACK TO Create_MMTRecord_PVT;
         X_RETURN_STATUS := fnd_api.g_ret_sts_error;
         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.string(FND_LOG.LEVEL_ERROR,G_LOG_HEAD ||'.'||l_api_name||'.'||l_stmt_num,
                        l_api_message);
         END IF;
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
         THEN
               FND_MSG_PUB.add_exc_msg
                 (  G_PKG_NAME,
                    l_api_name || l_api_message
                 );
         END IF;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN OTHERS THEN
         ROLLBACK TO Create_MMTRecord_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;
         l_api_message := to_char(SQLCODE)||'- '|| substrb(SQLERRM,1,100);
         IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD ||'.'||l_api_name||'.'||l_stmt_num
                ,'Create_MMTRecord : '||l_stmt_num||' : '||substr(SQLERRM,1,200));
         END IF;
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
         THEN
               FND_MSG_PUB.add_exc_msg
                 (  G_PKG_NAME,
                    l_api_name ||'('||to_char(l_stmt_num)||') - ' || l_api_message
                 );
         END IF;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

END Create_MMTRecord;

END RCV_SeedEvents_PVT;

/
