--------------------------------------------------------
--  DDL for Package Body RCV_ACCRUALACCOUNTING_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_ACCRUALACCOUNTING_GRP" AS
/* $Header: RCVGCSTB.pls 120.5.12010000.2 2008/12/26 14:32:45 mpuranik ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'RCV_AccrualAcct_GRP';
--G_DEBUG CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
G_LOG_LEVEL CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LOG_HEAD CONSTANT VARCHAR2(40) := 'po.plsql.'||G_PKG_NAME;

-- Start of comments
--	API name 	: Create_AccountingEvents
--	Type		: Group
--	Function	: To seed accounting events for receiving transactions,
--			  retroactive price adjustments and global procurement.
--	Pre-reqs	:
--	Parameters	:
--	IN		:	p_api_version           IN NUMBER	Required
--				p_init_msg_list		IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	    	IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--				p_validation_level	IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--                              p_source_type           IN VARCHAR2     Required
--                              Valid values : "RECEIVING", "RETROPRICE"
--
--                              The following parameters are required for a source type
--                              of "RECEIVING"
--                              p_rcv_transaction_id    IN NUMBER       Optional
--                              p_direct_delivery_flag  IN VARCHAR2     Optional
--
--                              The following parameters are required for a source type
--                              of "RETROPRICE"
--                              p_po_header_id          IN NUMBER       Optional
--                              p_po_release_id         IN NUMBER       Optional
--                              p_po_line_id            IN NUMBER       Optional
--                              p_po_line_location_id   IN NUMBER       Optional
--                              p_old_po_price          IN NUMBER       Optional
--                              p_new_po_price          IN NUMBER       Optional
--
--                              The following parameters have been obsoleted. AP will call
--                              the Create_InterCompanyEvents to seed IC events.
--                              p_invoice_dist_id_tbl   IN NUMBER_TBL     Optional
--
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count			OUT	NUMBER
--				x_msg_data			OUT	VARCHAR2(2000)
--	Version	:
--			  Initial version 	1.0
--
--      Notes           : This API creates all Receiving related accounting events in
--                        RCV_ACCOUNTING_EVENTS. For online accruals, it also generates
--                        the accounting entries for the event.
--			  This API is called from :
--                        1. The Receiving Transaction Processor for each transaction in
--                           RCV_Transactions.
--                        2. The PO Approvals Process for retroactive price changes.
--                        3. Accounts Payables during Invoice Validation phase for period
--                           end accruals.
--                        Depending on the calling process, there are three valid source types:
--                              'RECEIVING' when called by Receiving
--                              'RETROPRICE' when called by PO for retroactive price changes
--
-- End of comments
-------------------------------------------------------------------------------
PROCEDURE Create_AccountingEvents(
	        p_api_version          	IN	NUMBER,
	        p_init_msg_list        	IN	VARCHAR2,
	        p_commit               	IN	VARCHAR2,
	        p_validation_level     	IN	NUMBER,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

	        p_source_type       	IN	VARCHAR2, /*RECEIVING, RETROPRICE*/

	/* The following parameters are only required for source type of Receiving */
	        p_rcv_transaction_id 	IN NUMBER,
                p_direct_delivery_flag  IN VARCHAR2,

	/* The following parameters are only required for source type of RetroPrice*/
	        p_po_header_id		IN	NUMBER,
	        p_po_release_id		IN	NUMBER,
                p_po_line_id            IN      NUMBER,
	        p_po_line_location_id	IN 	NUMBER,
	        p_old_po_price    	IN 	NUMBER,
	        p_new_po_price         	IN	NUMBER,

        /* The following parameter has been obsoleted. AP will instead call the
           Create_IntercompanyEvents to seed IC events. */
                p_invoice_distribution_id       IN      NUMBER
)
IS
   l_api_name   CONSTANT VARCHAR2(30)   := 'Create_AccountingEvents';
   l_api_version        CONSTANT NUMBER         := 1.0;

   l_return_status      VARCHAR2(1);
   l_msg_count          NUMBER := 0;
   l_msg_data           VARCHAR2(8000);
   l_stmt_num           NUMBER := 0;
   l_api_message        VARCHAR2(1000);

   l_inv_dist_id	NUMBER;
   l_user_id       	NUMBER := -1;
   l_org_id        	NUMBER := 0;
   l_resp_id       	NUMBER := 0;
   l_resp_appl_id  	NUMBER := 0;
   l_rae_count		NUMBER := 0;
   l_process_enabled_flag   mtl_parameters.process_enabled_flag%TYPE; /* INVCONV ANTHIYAG Bug#5529309 18-Sep-2006 */
   l_lcm_enabled        VARCHAR2(1);

   l_full_name  CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
   l_module     constant varchar2(60) := 'po.plsql.'||l_full_name;

   l_uLog         CONSTANT BOOLEAN := fnd_log.level_unexpected >= g_log_level AND
                                      fnd_log.TEST(fnd_log.level_unexpected, l_module);
   l_errorLog constant boolean := l_uLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
   l_eventLog constant boolean := l_errorLog and (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
   l_pLog constant boolean := l_eventLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
   l_sLog constant boolean := l_pLog and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);


BEGIN
      l_return_status := fnd_api.g_ret_sts_success;

   -- Standard start of API savepoint
      SAVEPOINT Create_AccountingEvents_GRP;

      l_stmt_num := 0;

      IF l_pLog THEN
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.begin'
             ,'Create_AccountingEvents <<');
         END IF;
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

      FND_PROFILE.get('USER_ID',l_user_id);
      FND_PROFILE.get('ORG_ID',l_org_id);
      FND_PROFILE.get('RESP_ID',l_resp_id);
      FND_PROFILE.get('RESP_APPL_ID',l_resp_appl_id);

      l_api_message := 'Create_ReceivingEvents User ID :'||l_user_id||
                                     ' Org ID :' || l_org_id||
                                     ' Resp_ID : '||l_resp_id||
                                     ' Resp_appl_ID : '||l_resp_appl_id;


      IF l_sLog THEN
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
              ,l_api_message);
         END IF;
      END IF;

      /* INVCONV ANTHIYAG Bug#5529309 18-Sep-2006 Start */
        BEGIN
         SELECT        nvl(b.process_enabled_flag, 'N')
         INTO          l_process_enabled_flag
         FROM          po_line_locations_all a,
                       mtl_parameters b
         WHERE         a.line_location_id = p_po_line_location_id
         AND           b.organization_id = a.ship_to_organization_id;
        EXCEPTION
          WHEN OTHERS THEN
            l_process_enabled_flag := 'N';
        END;

        IF nvl(l_process_enabled_flag, 'N') = 'Y' THEN

          IF l_sLog THEN
	    l_api_message := ' Txn Info: po_line_location_id => ' || p_po_line_location_id ||
	      '  rcv_transaction_id => ' || p_rcv_transaction_id;
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                ,'Inv Org is Process Org.  Skipping Processing.');
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
	        ,l_api_message);
            END IF;
          END IF;

          x_return_status := l_return_status;
          x_msg_data := NULL;
          x_msg_count := l_msg_count;
          RETURN;

	ELSE
          IF l_sLog THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                ,'Inv Org is Discrete Org. Proceeding further...');
            END IF;
          END IF;

        END IF;
      /* INVCONV ANTHIYAG Bug#5529309 18-Sep-2006 End */

   -- If Invalid user_id is stamped, exit
      IF l_user_id = -1 THEN
        FND_MESSAGE.set_name('PO','INVALID_USER_ID');
        FND_MSG_pub.add;
        IF l_errorLog THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
            FND_LOG.message(FND_LOG.LEVEL_ERROR,G_LOG_HEAD || '.'||l_api_name||l_stmt_num,FALSE);
          END IF;
        END IF;
        RAISE FND_API.g_exc_error;
      END IF;

      IF UPPER(p_source_type) = 'RECEIVING' THEN
        l_stmt_num := 100;
        IF l_eventLog THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
             FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                ,'Creating Receiving Event');
           END IF;
        END IF;
        IF l_sLog THEN
	   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
	     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
		,'rcv_transaction_id : '||p_rcv_transaction_id);
	   END IF;
        END IF;

	-- Bug #4267722. Validate transaction_id passed in by Receiving.
	l_stmt_num := 110;
	SELECT 	count(*)
	INTO   	l_rae_count
	FROM 	rcv_accounting_events RAE
	WHERE 	rcv_transaction_id = p_rcv_transaction_id;

	IF l_rae_count <> 0 THEN
           l_api_message := 'Invalid transaction. Accounting events have already been generated for transaction : '||
			    p_rcv_transaction_id;
           IF l_uLog THEN
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                 FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                   ,'Create_AccountingEvents : '||l_stmt_num||' : '||l_api_message);
               END IF;
           END IF;
           RAISE FND_API.g_exc_unexpected_error;
	END IF;

	l_stmt_num := 120;
        RCV_AccEvents_PVT.Create_ReceivingEvents(
                        p_api_version           => 1.0,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        x_msg_data              => l_msg_data,
                        p_rcv_transaction_id    => p_rcv_transaction_id,
			p_direct_delivery_flag  => p_direct_delivery_flag );
      ELSIF UPPER(p_source_type) = 'RETROPRICE' THEN

        /* LCM project */
        l_stmt_num := 130;
        SELECT lcm_flag
          INTO l_lcm_enabled
          FROM po_line_locations_all
         WHERE line_location_id = p_po_line_location_id;

        l_stmt_num := 140;
        IF l_lcm_enabled = 'Y' THEN

          l_stmt_num := 150;
	  FND_MESSAGE.SET_NAME('BOM', 'CST_RETRO_PRC_IN_LCM_SHIP');
          FND_MSG_PUB.ADD;

          IF l_errorLog THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
              FND_LOG.message(FND_LOG.LEVEL_ERROR,l_module,FALSE);
            END IF;
          END IF;
          RAISE FND_API.g_exc_error;

        END IF;

        l_stmt_num := 200;
        IF l_eventLog THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
             FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                ,'Creating Adjust Event');
           END IF;
        END IF;
        IF l_sLog THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                ,'po_header_id : '||p_po_header_id||
		 ' po_release_id : '||p_po_release_id||
		 ' p_po_line_id : '||p_po_line_id||
		 ' p_po_line_location_id : '||p_po_line_location_id||
		 ' p_old_po_price : '||p_old_po_price||
		 ' p_new_po_price : '||p_new_po_price);
           END IF;
        END IF;

        RCV_AccEvents_PVT.Create_AdjustEvents(
                        p_api_version           => 1.0,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        x_msg_data              => l_msg_data,
                	p_po_header_id		=> p_po_header_id,
                	p_po_release_id         => p_po_release_id,
			p_po_line_id		=> p_po_line_id,
                	p_po_line_location_id   => p_po_line_location_id,
                	p_old_po_price          => p_old_po_price,
                	p_new_po_price          => p_new_po_price);

      ELSE
        FND_MESSAGE.set_name('PO','INVALID_EVENT_SOURCE_TYPE');
        FND_MSG_pub.add;
        IF l_errorLog THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
             FND_LOG.message(FND_LOG.LEVEL_ERROR,G_LOG_HEAD || '.'||l_api_name||l_stmt_num,FALSE);
           END IF;
        END IF;
        RAISE FND_API.g_exc_error;
      END IF;

      IF l_return_status <> FND_API.g_ret_sts_success THEN
        l_api_message := 'Error creating event';
        IF l_uLog THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                ,'Create_AccountingEvents : '||l_stmt_num||' : '||l_api_message);
            END IF;
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

      IF l_pLog THEN
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.end'
             ,'Create_AccountingEvents >>');
         END IF;
      END IF;


EXCEPTION
      WHEN FND_API.g_exc_error THEN
         ROLLBACK TO Create_AccountingEvents_GRP;
         x_return_status := FND_API.g_ret_sts_error;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN FND_API.g_exc_unexpected_error THEN
         ROLLBACK TO Create_AccountingEvents_GRP;
         x_return_status := FND_API.g_ret_sts_unexp_error ;
         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

      WHEN OTHERS THEN
         ROLLBACK TO Create_AccountingEvents_GRP;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF l_uLog THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                ,'Create_AccountingEvents : '||l_stmt_num||' : '||substr(SQLERRM,1,200));
            END IF;
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
END Create_AccountingEvents;
---------------------------------------------------------------------------
-- This Procedure just calls the one above without a gl_group_id
-- This is left in place to avoid patching dependencies with Receiving
-- during R12. Please remove this procedure before R12 release
---------------------------------------------------------------------------

PROCEDURE Create_AccountingEvents(
	        p_api_version          	IN	NUMBER,
	        p_init_msg_list        	IN	VARCHAR2,
	        p_commit               	IN	VARCHAR2,
	        p_validation_level     	IN	NUMBER,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

	        p_source_type       	IN	VARCHAR2,
	        p_rcv_transaction_id 	IN NUMBER,
                p_direct_delivery_flag  IN VARCHAR2,

		p_gl_group_id		IN NUMBER,

	        p_po_header_id		IN	NUMBER,
	        p_po_release_id		IN	NUMBER,
                p_po_line_id            IN      NUMBER,
	        p_po_line_location_id	IN 	NUMBER,
	        p_old_po_price    	IN 	NUMBER,
	        p_new_po_price         	IN	NUMBER,

                p_invoice_distribution_id       IN      NUMBER
)
IS

BEGIN

Create_AccountingEvents (
   p_api_version             => p_api_version,
   p_init_msg_list           => p_init_msg_list,
   p_commit                  => p_commit,
   p_validation_level        => p_validation_level,
   x_return_status           => x_return_status,
   x_msg_count               => x_msg_count,
   x_msg_data                => x_msg_data,
   p_source_type             => p_source_type,
   p_rcv_transaction_id      => p_rcv_transaction_id,
   p_direct_delivery_flag    => p_direct_delivery_flag,
   p_po_header_id            => p_po_header_id,
   p_po_release_id           => p_po_release_id,
   p_po_line_id              => p_po_line_id,
   p_po_line_location_id     => p_po_line_location_id,
   p_old_po_price            => p_old_po_price,
   p_new_po_price            => p_new_po_price,
   p_invoice_distribution_id => p_invoice_distribution_id);


END Create_AccountingEvents;

-- Start of comments
--      API name        : Create_InterCompanyEvents
--      Type            : Group
--      Function        : To seed accounting Intercompany events for period end accruals.
--                        When Invoice is matched to PO and validated, IC events will be
--                        seeded for Global Procurement scenarios.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--
--                              p_invoice_dist_id_tbl   IN      NUMBER_TBL Required
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--
--      Notes           : This API seeds Intercompany events for period end accruals.
--                        When Invoice is matched to PO and validated, AP will call this
--                        this API for period end accruals. If Invoice is for a global
--                        procurement scenario, this API will seed Intercompany events in
--                        RCV_ACCOUNTING_EVENTS. The intercompany invoicing program will
--                        later use these events to create intercompany invoices.
--
--                        This API is called from :
--                        1. Accounts Payables during Invoice Validation phase for period
--                           end accruals.
-- Start of comments
PROCEDURE Create_InterCompanyEvents(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
                p_commit                IN      VARCHAR2 := FND_API.G_FALSE,
                p_validation_level      IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                p_invoice_dist_id_tbl   IN      NUMBER_TBL
)

IS
   l_api_name   	CONSTANT VARCHAR2(30)   := 'Create_InterCompanyEvents';
   l_api_version        CONSTANT NUMBER         := 1.0;

   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER := 0;
   l_msg_data            VARCHAR2(8000);
   l_stmt_num            NUMBER := 0;
   l_api_message         VARCHAR2(1000);

   l_inv_dist_id	 NUMBER;

   l_full_name               CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
   l_module    constant varchar2(60) := 'po.plsql.'||l_full_name;

   l_uLog         CONSTANT BOOLEAN := fnd_log.level_unexpected >= g_log_level AND
                                      fnd_log.TEST(fnd_log.level_unexpected, l_module);
   l_eventLog constant boolean := l_uLog and (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
   l_pLog constant boolean := l_eventLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
   l_sLog constant boolean := l_pLog and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);
--BUG#6167988
   l_cnt                 NUMBER := 0;

BEGIN
      l_return_status := fnd_api.g_ret_sts_success;
   -- Standard start of API savepoint
      SAVEPOINT Create_InterCompanyEvents_GRP;

      l_stmt_num := 0;

      IF l_pLog THEN
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.begin'
             ,'Create_InterCompanyEvents <<');
         END IF;
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
      IF l_eventLog THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
             FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                ,'Creating Intercompany Event');
           END IF;
      END IF;



--BUG#6167988
     l_cnt := p_invoice_dist_id_tbl.COUNT;

     IF l_eventLog THEN
        FND_LOG.string(FND_LOG.LEVEL_EVENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num,
                      'DEBUG p_invoice_dist_id_tbl.COUNT: '||l_cnt);
     END IF;


     IF l_cnt > 0 THEN

      FOR l_counter IN p_invoice_dist_id_tbl.FIRST..p_invoice_dist_id_tbl.LAST LOOP
 	   l_inv_dist_id := p_invoice_dist_id_tbl(l_counter);

           IF l_sLog THEN
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                   ,'invoice_distribution_id : '|| l_inv_dist_id);
              END IF;
           END IF;

	   l_stmt_num := 20;
           RCV_AccEvents_PVT.Create_ICEvents(
                        p_api_version           => 1.0,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        x_msg_data              => l_msg_data,
			p_invoice_distribution_id => l_inv_dist_id);
           IF l_return_status <> FND_API.g_ret_sts_success THEN
             l_api_message := 'Error creating IC event';
             IF l_uLog THEN
                 IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                   FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                     ,'Create_InterCompanyEvents : '||l_stmt_num||' : '||l_api_message);
                 END IF;
             END IF;
             RAISE FND_API.g_exc_unexpected_error;
           END IF;
      END LOOP;

   END IF;

   --- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT WORK;
       END IF;


    -- Standard Call to get message count and if count = 1, get message info
       FND_MSG_PUB.Count_And_Get (
           p_count     => x_msg_count,
           p_data      => x_msg_data );

      IF l_pLog THEN
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.end'
             ,'Create_InterCompanyEvents >>');
         END IF;
      END IF;


EXCEPTION
      WHEN FND_API.g_exc_error THEN
         ROLLBACK TO Create_InterCompanyEvents_GRP;
         x_return_status := FND_API.g_ret_sts_error;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN FND_API.g_exc_unexpected_error THEN
         ROLLBACK TO Create_InterCompanyEvents_GRP;
         x_return_status := FND_API.g_ret_sts_unexp_error ;
         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

      WHEN OTHERS THEN
         ROLLBACK TO Create_InterCompanyEvents_GRP;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF l_uLog THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                ,'Create_InterCompanyEvents : '||l_stmt_num||' : '||substr(SQLERRM,1,200));
            END IF;
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
END Create_InterCompanyEvents;

-- Start of comments
--	API name 	: Get_InvTransactionInfo
--	Type		: Private
--	Pre-reqs	:
--	Function	: To return the transfer price and distribution account in
--			  global procurement and drop shipment scenarios.
--	Parameters	:
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
--				x_intercompany_pricing_option	OUT	NUMBER
--				x_currency_code		OUT 	VARCHAR2
--                              x_currency_conversion_rate OUT  NUMBER
--                              x_currency_conversion_date OUT  DATE
--                              x_currency_conversion_type OUT  VARCHAR2(30)
--				x_distribution_acct_id	OUT 	NUMBER
--	Version	:
--			  Initial version 	1.0
--
--      Notes           :
--      This API is called by the receiving transaction processor for Deliver, RTR
--      and Corrections to Deliver/RTR transactions, to determine if the price to be
--      stamped on MMTT is the PO price or the transfer price. This API returns a
--      flag to indicate if transfer price is to be used. If the intercompany_pricing_option
--      is set to 2, the transfer price and the corresponding currency code,
--      currency conversion rate, date and type are returned.
--      The transfer price is returned in the transaction UOM.
--      If the returned intercompany_pricing_option is 1, the Receiving transaction
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

          p_rcv_transaction_id        IN      	     NUMBER,

          x_intercompany_pricing_option       OUT NOCOPY     NUMBER,
          x_transfer_price	      OUT NOCOPY     NUMBER,
	  x_currency_code	      OUT NOCOPY     VARCHAR2,
          x_currency_conversion_rate  OUT NOCOPY     NUMBER,
          x_currency_conversion_date  OUT NOCOPY     DATE,
          x_currency_conversion_type  OUT NOCOPY     VARCHAR2,
	  x_distribution_acct_id      OUT NOCOPY     NUMBER
)
IS
   l_api_name           CONSTANT VARCHAR2(30)   := 'Get_InvTransactionInfo';
   l_api_version        CONSTANT NUMBER         := 1.0;

   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER := 0;
   l_msg_data            VARCHAR2(8000);
   l_stmt_num            NUMBER := 0;
   l_api_message         VARCHAR2(1000);

   l_full_name               CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
   l_module    constant varchar2(60) := 'po.plsql.'||l_full_name;

   l_uLog         CONSTANT BOOLEAN := fnd_log.level_unexpected >= g_log_level AND
                                      fnd_log.TEST(fnd_log.level_unexpected, l_module);
   l_pLog constant boolean := l_uLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);

BEGIN
      l_return_status := fnd_api.g_ret_sts_success;
   -- Standard start of API savepoint
      SAVEPOINT Get_InvTransactionInfo_GRP;

      l_stmt_num := 0;

      IF l_pLog THEN
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.begin'
             ,'Get_InvTransactionInfo <<');
         END IF;
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

   --- Initialize Output Variables
      x_intercompany_pricing_option := 1;
      x_distribution_acct_id := -1;

      l_stmt_num := 10;
      RCV_AccEvents_PVT.Get_InvTransactionInfo(
				p_api_version           => 1.0,
                                x_return_status         => l_return_status,
                                x_msg_count             => l_msg_count,
                                x_msg_data              => l_msg_data,
                                p_rcv_transaction_id    => p_rcv_transaction_id,
				x_intercompany_pricing_option	=> x_intercompany_pricing_option,
				x_transfer_price	=> x_transfer_price,
				x_currency_code		=> x_currency_code,
				x_currency_conversion_rate => x_currency_conversion_rate,
				x_currency_conversion_date => x_currency_conversion_date,
				x_currency_conversion_type => x_currency_conversion_type,
				x_distribution_acct_id	=> x_distribution_acct_id);

   --- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT WORK;
       END IF;

    -- Standard Call to get message count and if count = 1, get message info
       FND_MSG_PUB.Count_And_Get (
           p_count     => x_msg_count,
           p_data      => x_msg_data );

      IF l_pLog THEN
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.end'
             ,'Get_InvTransactionInfo >>');
         END IF;
      END IF;

EXCEPTION
      WHEN FND_API.g_exc_error THEN
         ROLLBACK TO Get_InvTransactionInfo_GRP;
         x_return_status := FND_API.g_ret_sts_error;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN FND_API.g_exc_unexpected_error THEN
         ROLLBACK TO Get_InvTransactionInfo_GRP;
         x_return_status := FND_API.g_ret_sts_unexp_error ;
        FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

      WHEN OTHERS THEN
         ROLLBACK TO Get_InvTransactionInfo_GRP;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF l_uLog THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                ,'Get_InvTransactionInfo : '||l_stmt_num||' : '||substr(SQLERRM,1,200));
            END IF;
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

END RCV_AccrualAccounting_GRP;

/
