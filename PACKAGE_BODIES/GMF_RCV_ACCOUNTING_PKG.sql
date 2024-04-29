--------------------------------------------------------
--  DDL for Package Body GMF_RCV_ACCOUNTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_RCV_ACCOUNTING_PKG" AS
/* $Header: gmfrcvab.pls 120.3.12010000.4 2010/01/12 10:50:15 smukalla ship $ */

  /**************************
  * Package Level Constants *
  **************************/
  MODULE  CONSTANT VARCHAR2(80) := 'gmf.plsql.gmf_rcv_accounting_pkg';
  G_PKG_NAME CONSTANT VARCHAR2(30) := 'GMF_RCV_ACCOUNTING_PKG';
  G_DEBUG CONSTANT VARCHAR2(10) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
  G_LOG_HEAD CONSTANT VARCHAR2(40) := 'gmf.plsql.'||G_PKG_NAME;

  /**********************************************************************************************
  * API name                                                                                    *
  *   Get_TransactionAmount                                                                     *
  * Type                                                                                        *
  *   Private                                                                                   *
  * Function                                                                                    *
  *   Returns the transaction amount. Used for service line types.                              *
  * Pre-reqs                                                                                    *
  *                                                                                             *
  * Parameters                                                                                  *
  *   IN                                                                                        *
  *     p_api_version           IN NUMBER       Required                                        *
  *     p_init_msg_list         IN VARCHAR2     Optional Default = FND_API.G_FALSE              *
  *     p_commit                IN VARCHAR2     Optional Default = FND_API.G_FALSE              *
  *     p_validation_level      IN NUMBER       Optional Default = FND_API.G_VALID_LEVEL_FULL   *
  *     p_rcv_accttxn             IN rcv_accttxn_rec_type       Required         *
  *   OUT                                                                                       *
  *     x_return_status         OUT     VARCHAR2(1)                                             *
  *     x_msg_count             OUT     NUMBER                                                  *
  *     x_msg_data              OUT     VARCHAR2(2000)                                          *
  *     x_transaction_amount    OUT     NUMBER                                                  *
  * Version                                                                                     *
  *   1.0                                                                                       *
  * Description                                                                                 *
  *   This API returns the transaction amount. It should only be called for service line types. *
  *                                                                                             *
  * 22-MAY-2009 Uday Phadtare Bug 8517463. Code modified in PROCEDURE create_deliver_txns.      *
  *   Passed proper event_type_id in case of correction to EXPENSE destination type             *
  * 31-Jul-2009 Prasad LCM-OPM Integration, populating unit landed cost value in grat table     *
  **********************************************************************************************/
  PROCEDURE Get_TransactionAmount
  (
  p_api_version           IN      	  NUMBER,
  p_init_msg_list         IN      	  VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN      	  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN      	  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY  VARCHAR2,
  x_msg_count             OUT NOCOPY  NUMBER,
  x_msg_data              OUT NOCOPY  VARCHAR2,
  p_rcv_accttxn		        IN 		      GMF_RCV_ACCOUNTING_PKG.rcv_accttxn_rec_type,
	x_transaction_amount	OUT NOCOPY 	  NUMBER
  )
  IS
    l_api_name            CONSTANT      VARCHAR2(30)   := 'Get_TransactionAmount';
    l_api_version         CONSTANT      NUMBER         := 1.0;
    l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_msg_count           NUMBER := 0;
    l_msg_data            VARCHAR2(8000) := '';
    l_stmt_num            NUMBER := 0;
    l_api_message         VARCHAR2(1000);
    l_transaction_amount  NUMBER;
    l_po_amount_ordered   NUMBER;
    l_po_amount_delivered NUMBER;
    l_abs_rt_amount       NUMBER;
    l_rcv_txn_type        RCV_Transactions.transaction_type%TYPE;
    l_parent_txn_id       NUMBER;
    l_par_rcv_txn_type    RCV_Transactions.transaction_type%TYPE;
  BEGIN
    /**********************************
    * Standard start of API savepoint *
    **********************************/
    SAVEPOINT Get_TransactionAmount_PVT;

    l_stmt_num := 0;

    IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.begin','Get_TransactionAmount <<');
    END IF;

    /************************************************
    * Standard call to check for call compatibility *
    ************************************************/
    IF NOT FND_API.Compatible_API_Call (l_api_version,p_api_version,l_api_name,G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /************************************************************
    * Initialize message list if p_init_msg_list is set to TRUE *
    ************************************************************/
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    /******************************************
    * Initialize API return status to success *
    ******************************************/
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /********************************************************************************
    * For service line types, only the source types of RECEIVING and INVOICEMATCH   *
    * are valid. Retroactive price changes on service line types have no accounting *
    * impact.                                                                       *
    ********************************************************************************/
    IF(p_rcv_accttxn.event_source = 'RECEIVING') THEN

      /**************************************************************************************
      * If receiving transaction has a distribution, entire amount is allocated to          *
      * the distribution. Otherwise, the amount has to be prorated based on amount ordered. *
      **************************************************************************************/
	    l_stmt_num := 10;
      SELECT decode(RT.po_distribution_id, NULL, RT.amount  * (POD.amount_ordered/POLL.amount),RT.amount)
	    INTO   l_transaction_amount
	    FROM   rcv_transactions RT,
	           po_distributions POD,
	           po_line_locations POLL
	    WHERE  RT.transaction_id 	= p_rcv_accttxn.rcv_transaction_id
	    AND    POD.po_distribution_id 	= p_rcv_accttxn.po_distribution_id
	    AND    POLL.line_location_id 	= p_rcv_accttxn.po_line_location_id;
    ELSIF(p_rcv_accttxn.event_source = 'INVOICEMATCH') THEN
      /*************************************************************************
      * For source of invoice match, there will always be a po_distribution_id *
      *************************************************************************/
	    l_stmt_num := 20;
      SELECT APID.amount
      INTO   l_transaction_amount
      FROM   ap_invoice_distributions APID
      WHERE  APID.invoice_distribution_id = p_rcv_accttxn.inv_distribution_id;
    END IF;

    IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      l_api_message := 'Transaction Amount : '||l_transaction_amount;
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num,l_api_message);
    END IF;

    /*****************************************************************
    * For encumbrance reversal transactions , only reverse encumbrance     *
    * upto amount_ordered. If amount received exceeds the            *
    * ordered amount, transaction amount should be reduced such that *
    * it does not exceed amount ordered.                             *
    *****************************************************************/
    IF(p_rcv_accttxn.event_type_id = ENCUMBRANCE_REVERSAL) THEN
      l_abs_rt_amount := ABS(l_transaction_amount);

      l_stmt_num := 40;
      SELECT RT.transaction_type, RT.parent_transaction_id
      INTO   l_rcv_txn_type, l_parent_txn_id
      FROM   rcv_transactions RT
      WHERE  RT.transaction_id = p_rcv_accttxn.rcv_transaction_id;

      l_stmt_num := 50;
      SELECT PARENT.transaction_type
      INTO   l_par_rcv_txn_type
      FROM   rcv_transactions PARENT
      WHERE  PARENT.transaction_id =l_parent_txn_id;

      l_stmt_num := 60;
      SELECT POD.amount_ordered, POD.amount_delivered
      INTO   l_po_amount_ordered, l_po_amount_delivered
      FROM   po_distributions POD
      WHERE  po_distribution_id = p_rcv_accttxn.po_distribution_id;

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        l_api_message := substr('l_rcv_txn_type : '||l_rcv_txn_type||
        ' l_par_rcv_txn_type : '||l_par_rcv_txn_type||
        ' l_po_amount_ordered : '||l_po_amount_ordered||
        ' l_po_amount_delivered : '||l_po_amount_delivered, 1, 1000);
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num,l_api_message);
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
      AND p_rcv_accttxn.transaction_amount < 0) OR
      (l_rcv_txn_type = 'CORRECT' AND l_par_rcv_txn_type = 'RETURN TO RECEIVING'
      AND p_rcv_accttxn.transaction_amount > 0)) THEN
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
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num,l_api_message);
    END IF;

    /*****************************
    * Standard check of p_commit *
    *****************************/
    IF FND_API.to_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    /************************************************************************
    * Standard Call to get message count and if count = 1, get message info *
    ************************************************************************/
    FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,p_data => x_msg_data );

    IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.end','Get_TransactionAmount >>');
    END IF;
  EXCEPTION
    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Get_TransactionAmount_PVT;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Get_TransactionAmount_PVT;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get( p_count  => x_msg_count, p_data   => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO Get_TransactionAmount_PVT;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num,'Get_TransactionAmount : '||l_stmt_num||' : '||substr(SQLERRM,1,200));
      END IF;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        FND_MSG_PUB.add_exc_msg( G_PKG_NAME,l_api_name || 'Statement -'||to_char(l_stmt_num));
      END IF;
      FND_MSG_PUB.count_and_get(  p_count  => x_msg_count, p_data   => x_msg_data);
  END Get_TransactionAmount;

  /****************************************************************************************************
  * API name                                                                                          *
  *   Get_HookAccount                                                                                 *
  * Type                                                                                              *
  *   Private                                                                                         *
  * Function                                                                                          *
  *   Call account hook to  allow customer to override default account.                               *
  * Parameters                                                                                        *
  *   IN                                                                                              *
  *     p_api_version           IN NUMBER       Required                                              *
  *     p_init_msg_list         IN VARCHAR2     Optional Default = FND_API.G_FALSE                    *
  *     p_commit                IN VARCHAR2     Optional Default = FND_API.G_FALSE                    *
  *     p_validation_level      IN NUMBER       Optional Default = FND_API.G_VALID_LEVEL_FULL         *
  *     p_rcv_transaction_id    IN NUMBER       Required p_accounting_line_type  IN VARCHAR2 Required *
  *     p_org_id                IN NUMBER       Required                                              *
  *   OUT                                                                                             *
  *     x_return_status         OUT     VARCHAR2(1)                                                   *
  *     x_msg_count             OUT     NUMBER                                                        *
  *     x_msg_data              OUT     VARCHAR2(2000)                                                *
  *     x_distribution_acct_id  OUT     NUMBER                                                        *
  * Description                                                                                       *
  *   This API creates all accounting transactions for RETURN TO VENDOR transactions                  *
  *   in gmf_rcv_accounting_txns.                                                                     *
  ****************************************************************************************************/

  PROCEDURE Get_HookAccount
  (
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
  )
  IS
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
    /**********************************
    * Standard start of API savepoint *
    **********************************/
    SAVEPOINT Get_HookAccount_PVT;

    l_stmt_num := 0;

    IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.begin','Get_HookAccount <<');
    END IF;

    /************************************************
    * Standard call to check for call compatibility *
    ************************************************/
    IF NOT FND_API.Compatible_API_Call (l_api_version,p_api_version,l_api_name,G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /************************************************************
    * Initialize message list if p_init_msg_list is set to TRUE *
    ************************************************************/
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    /******************************************
    * Initialize API return status to success *
    ******************************************/
    x_return_status   	:= FND_API.G_RET_STS_SUCCESS;
    x_distribution_acct_id 	:= -1;

    l_stmt_num := 10;
    RCV_AccountHook_PUB.Get_Account
    (
    p_api_version           => l_api_version,
    x_return_status         => l_return_status,
    x_msg_count             => l_msg_count,
    x_msg_data              => l_msg_data,
    p_rcv_transaction_id    => p_rcv_transaction_id,
    p_accounting_line_type  => p_accounting_line_type,
    x_distribution_acct_id  => l_dist_acct_id
    );

    IF l_return_status <> FND_API.g_ret_sts_success THEN
      l_api_message := 'Error in Account Hook';
      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num,'Get_HookAccount : '||l_stmt_num||' : '||l_api_message);
      END IF;
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    IF(l_dist_acct_id <> -1) THEN
      l_stmt_num := 20;
      SELECT  count(*)
      INTO    l_account_flag
      FROM    gl_code_combinations GCC,
              cst_organization_definitions COD
      WHERE   COD.operating_unit        = p_org_id
      AND     COD.chart_of_accounts_id  = GCC.chart_of_accounts_id
      AND     GCC.code_combination_id   = l_dist_acct_id;
      IF (l_account_flag = 0) THEN
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
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num,l_api_message);
    END IF;

    /*****************************
    * Standard check of p_commit *
    *****************************/
    IF FND_API.to_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    /************************************************************************
    * Standard Call to get message count and if count = 1, get message info *
    ************************************************************************/
    FND_MSG_PUB.Count_And_Get (p_count     => x_msg_count,p_data      => x_msg_data );

    IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.end','Get_HookAccount >>');
    END IF;
  EXCEPTION
    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Get_HookAccount_PVT;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(  p_count => x_msg_count, p_data  => x_msg_data);
    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Get_HookAccount_PVT;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(  p_count  => x_msg_count, p_data   => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO Get_HookAccount_PVT;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num,'Get_HookAccount : '||l_stmt_num||' : '||substr(SQLERRM,1,200));
      END IF;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)THEN
        FND_MSG_PUB.add_exc_msg(  G_PKG_NAME,l_api_name || 'Statement -'||to_char(l_stmt_num));
      END IF;
      FND_MSG_PUB.count_and_get(  p_count  => x_msg_count, p_data   => x_msg_data);
  END Get_HookAccount;

   /********************************************************************************************
   * API name                                                                                  *
   *   Get_Quantity                                                                            *
   * Type                                                                                      *
   *   Private                                                                                 *
   * Function                                                                                  *
   *   Returns the quantity in source doc UOM. It includes additional                          *
   *   checks for encumbrance reversal transactions. We should only                            *
   *   encumber upto quantity ordered. If quantity received is                                 *
   *   greater than quantity ordered, we should not encumber for                               *
   *   the excess.                                                                             *
   * Parameters                                                                                *
   *   IN                                                                                      *
   *     p_api_version           IN NUMBER       Required                                      *
   *     p_init_msg_list         IN VARCHAR2     Optional Default = FND_API.G_FALSE            *
   *     p_commit                IN VARCHAR2     Optional Default = FND_API.G_FALSE            *
   *     p_validation_level      IN NUMBER       Optional Default = FND_API.G_VALID_LEVEL_FULL *
   *     p_rcv_accttxn           IN rcv_accttxn_rec_type       Required                        *
   *   OUT                                                                                     *
   *     x_return_status         OUT     VARCHAR2(1)                                           *
   *     x_msg_count             OUT     NUMBER                                                *
   *     x_msg_data              OUT     VARCHAR2(2000)                                        *
   *     x_source_doc_quantity   OUT     NUMBER                                                *
   * Description                                                                               *
   *   This API returns the transaction quantity. It should                                    *
   *   only be called for non-service line types.                                              *
   ********************************************************************************************/
   PROCEDURE get_quantity (
      p_api_version           IN              NUMBER,
      p_init_msg_list         IN              VARCHAR2 := fnd_api.g_false,
      p_commit                IN              VARCHAR2 := fnd_api.g_false,
      p_validation_level      IN              NUMBER   := fnd_api.g_valid_level_full,
      x_return_status         OUT NOCOPY      VARCHAR2,
      x_msg_count             OUT NOCOPY      NUMBER,
      x_msg_data              OUT NOCOPY      VARCHAR2,
      p_rcv_accttxn           IN              gmf_rcv_accounting_pkg.rcv_accttxn_rec_type,
      x_source_doc_quantity   OUT NOCOPY      NUMBER
   )
   IS
      l_api_name       CONSTANT VARCHAR2 (30)               := 'Get_Quantity';
      l_api_version    CONSTANT NUMBER                                 := 1.0;
      l_return_status           VARCHAR2 (1)     := fnd_api.g_ret_sts_success;
      l_msg_count               NUMBER                                   := 0;
      l_msg_data                VARCHAR2 (8000)                         := '';
      l_stmt_num                NUMBER                                   := 0;
      l_api_message             VARCHAR2 (1000);
      l_source_doc_quantity     NUMBER;
      l_po_quantity_ordered     NUMBER;
      l_po_quantity_delivered   NUMBER;
      l_abs_rt_quantity         NUMBER;
      l_rcv_txn_type            rcv_transactions.transaction_type%TYPE;
      l_parent_txn_id           NUMBER;
      l_par_rcv_txn_type        rcv_transactions.transaction_type%TYPE;
   BEGIN
      /**********************************
      * Standard start of API savepoint *
      **********************************/
      SAVEPOINT get_quantity_pvt;
      l_stmt_num := 0;

      IF     g_debug = 'Y'
         AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_log_head || '.' || l_api_name || '.begin',
                         'Get_Quantity <<'
                        );
      END IF;

      -- Standard call to check for call compatibility
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      l_stmt_num := 10;

      IF (p_rcv_accttxn.event_source = 'RECEIVING')
      THEN
         l_stmt_num := 20;

         SELECT DECODE (rt.po_distribution_id,
                        NULL, rt.source_doc_quantity
                         * pod.quantity_ordered
                         / poll.quantity,
                        rt.source_doc_quantity
                       )
           INTO l_source_doc_quantity
           FROM rcv_transactions rt,
                po_line_locations poll,
                po_distributions pod
          WHERE rt.transaction_id = p_rcv_accttxn.rcv_transaction_id
            AND poll.line_location_id = p_rcv_accttxn.po_line_location_id
            AND pod.po_distribution_id = p_rcv_accttxn.po_distribution_id;
      ELSIF (p_rcv_accttxn.event_source = 'RETROPRICE')
      THEN
         IF (p_rcv_accttxn.event_type_id = adjust_receive)
         THEN
            l_stmt_num := 30;
            l_source_doc_quantity :=
               rcv_accrual_sv.get_received_quantity
                                           (p_rcv_accttxn.rcv_transaction_id,
                                            SYSDATE
                                           );
         ELSE
            l_stmt_num := 40;
            l_source_doc_quantity :=
               rcv_accrual_sv.get_delivered_quantity
                                           (p_rcv_accttxn.rcv_transaction_id,
                                            SYSDATE
                                           );
         END IF;

         l_stmt_num := 50;

         SELECT DECODE (rt.po_distribution_id,
                        NULL, l_source_doc_quantity
                         * pod.quantity_ordered
                         / poll.quantity,
                        l_source_doc_quantity
                       )
           INTO l_source_doc_quantity
           FROM rcv_transactions rt,
                po_line_locations poll,
                po_distributions pod
          WHERE rt.transaction_id = p_rcv_accttxn.rcv_transaction_id
            AND poll.line_location_id = p_rcv_accttxn.po_line_location_id
            AND pod.po_distribution_id = p_rcv_accttxn.po_distribution_id;
      END IF;

      -- For encumbrance reversal transactions  only match
      -- upto quantity_ordered. If quantity received/invoiced exceeds the
      -- ordered quantity, transaction quantity should be reduced such that
      -- it does not exceed quantity ordered.
      IF (p_rcv_accttxn.event_type_id = encumbrance_reversal)
      THEN
         l_abs_rt_quantity := ABS (l_source_doc_quantity);
         l_stmt_num := 60;

         SELECT rt.transaction_type, rt.parent_transaction_id
           INTO l_rcv_txn_type, l_parent_txn_id
           FROM rcv_transactions rt
          WHERE rt.transaction_id = p_rcv_accttxn.rcv_transaction_id;

         l_stmt_num := 70;

         SELECT PARENT.transaction_type
           INTO l_par_rcv_txn_type
           FROM rcv_transactions PARENT
          WHERE PARENT.transaction_id = l_parent_txn_id;

         l_stmt_num := 80;

         SELECT pod.quantity_ordered, pod.quantity_delivered
           INTO l_po_quantity_ordered, l_po_quantity_delivered
           FROM po_distributions pod
          WHERE pod.po_distribution_id = p_rcv_accttxn.po_distribution_id;

         IF     g_debug = 'Y'
            AND fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            l_api_message :=
               SUBSTR (   'l_rcv_txn_type : '
                       || l_rcv_txn_type
                       || ' l_parent_txn_id : '
                       || l_parent_txn_id
                       || ' l_par_rcv_txn_type : '
                       || l_par_rcv_txn_type
                       || ' l_abs_rt_quantity : '
                       || l_abs_rt_quantity
                       || ' l_po_quantity_ordered : '
                       || l_po_quantity_ordered
                       || ' l_po_quantity_delivered : '
                       || l_po_quantity_delivered,
                       1,
                       1000
                      );
            fnd_log.STRING (fnd_log.level_statement,
                            g_log_head || '.' || l_api_name || '.'
                            || l_stmt_num,
                            l_api_message
                           );
         END IF;

         /* Bug #3333610. Receiving updates quantity delivered prior to calling the transactions API.
            Consequently, we should subtract the current quantity from the quantity delivered to
            get the quantity that has been delivered previously. */
         l_stmt_num := 90;

         IF (   l_rcv_txn_type = 'DELIVER'
             OR (    l_rcv_txn_type = 'CORRECT'
                 AND l_par_rcv_txn_type = 'DELIVER'
                 AND l_source_doc_quantity > 0
                )
             OR (    l_rcv_txn_type = 'CORRECT'
                 AND l_par_rcv_txn_type = 'RETURN TO RECEIVING'
                 AND l_source_doc_quantity < 0
                )
            )
         THEN
            l_po_quantity_delivered :=
                                  l_po_quantity_delivered - l_abs_rt_quantity;

            IF (l_po_quantity_delivered >= l_po_quantity_ordered)
            THEN
               l_source_doc_quantity := 0;
            ELSIF (l_abs_rt_quantity + l_po_quantity_delivered <=
                                                         l_po_quantity_ordered
                  )
            THEN
               l_source_doc_quantity := l_abs_rt_quantity;
            ELSE
               l_source_doc_quantity :=
                              l_po_quantity_ordered - l_po_quantity_delivered;
            END IF;
         ELSIF (   l_rcv_txn_type = 'RETURN TO RECEIVING'
                OR (    l_rcv_txn_type = 'CORRECT'
                    AND l_par_rcv_txn_type = 'DELIVER'
                    AND l_source_doc_quantity < 0
                   )
                OR (    l_rcv_txn_type = 'CORRECT'
                    AND l_par_rcv_txn_type = 'RETURN TO RECEIVING'
                    AND l_source_doc_quantity > 0
                   )
               )
         THEN
            l_po_quantity_delivered :=
                                  l_po_quantity_delivered + l_abs_rt_quantity;

            IF (l_po_quantity_delivered <= l_po_quantity_ordered)
            THEN
               l_source_doc_quantity := l_abs_rt_quantity;
            ELSIF (l_po_quantity_delivered - l_abs_rt_quantity >
                                                         l_po_quantity_ordered
                  )
            THEN
               l_source_doc_quantity := 0;
            ELSE
               l_source_doc_quantity :=
                    l_abs_rt_quantity
                  - (l_po_quantity_delivered - l_po_quantity_ordered);
            END IF;
         END IF;
      END IF;

      x_source_doc_quantity := l_source_doc_quantity;

      IF     g_debug = 'Y'
         AND fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         l_api_message := 'x_source_doc_quantity : ' || x_source_doc_quantity;
         fnd_log.STRING (fnd_log.level_statement,
                         g_log_head || '.' || l_api_name || '.' || l_stmt_num,
                         l_api_message
                        );
      END IF;

      --- Standard check of p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard Call to get message count and if count = 1, get message info
      fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                 p_data       => x_msg_data);

      IF     g_debug = 'Y'
         AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_log_head || '.' || l_api_name || '.end',
                         'Get_Quantity >>'
                        );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO get_quantity_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO get_quantity_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN OTHERS
      THEN
         ROLLBACK TO get_quantity_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF     g_debug = 'Y'
            AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_log_head || '.' || l_api_name || l_stmt_num,
                               'Get_Quantity : '
                            || l_stmt_num
                            || ' : '
                            || SUBSTR (SQLERRM, 1, 200)
                           );
         END IF;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name,
                                        l_api_name
                                     || 'Statement -'
                                     || TO_CHAR (l_stmt_num)
                                    );
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
   END get_quantity;

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
--                              p_rcv_accttxn             IN rcv_accttxn_rec_type       Required
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--          x_intercompany_pricing_option OUT   NUMBER
--          x_unit_price      OUT   NUMBER
--          x_currency_code      OUT   VARCHAR2(15)
--          x_incr_transfer_price   OUT   NUMBER
--          x_incr_currency_code OUT   VARCHAR2(15)
--      Version :
--                        Initial version       1.0
--
--
--      Notes           : This API returns the unit price. It should only be called for non service line types.
--
-- End of comments
   PROCEDURE get_unitprice (
      p_api_version                   IN              NUMBER,
      p_init_msg_list                 IN              VARCHAR2
            := fnd_api.g_false,
      p_commit                        IN              VARCHAR2
            := fnd_api.g_false,
      p_validation_level              IN              NUMBER
            := fnd_api.g_valid_level_full,
      x_return_status                 OUT NOCOPY      VARCHAR2,
      x_msg_count                     OUT NOCOPY      NUMBER,
      x_msg_data                      OUT NOCOPY      VARCHAR2,
      p_rcv_accttxn                   IN              gmf_rcv_accounting_pkg.rcv_accttxn_rec_type,
      p_asset_item_pricing_option     IN              NUMBER,
      p_expense_item_pricing_option   IN              NUMBER,
      x_intercompany_pricing_option   OUT NOCOPY      NUMBER,
      x_unit_price                    OUT NOCOPY      NUMBER,
      x_currency_code                 OUT NOCOPY      VARCHAR2,
      x_incr_transfer_price           OUT NOCOPY      NUMBER,
      x_incr_currency_code            OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_name      CONSTANT VARCHAR2 (30)               := 'Get_UnitPrice';
      l_api_version   CONSTANT NUMBER                                  := 1.0;
      l_return_status          VARCHAR2 (1)      := fnd_api.g_ret_sts_success;
      l_msg_count              NUMBER                                    := 0;
      l_msg_data               VARCHAR2 (8000)                          := '';
      l_stmt_num               NUMBER                                    := 0;
      l_api_message            VARCHAR2 (1000);
      l_asset_flag             VARCHAR2 (1);
      l_ic_pricing_option      NUMBER                                    := 1;
      l_transfer_price         NUMBER;
      l_unit_price             NUMBER;
      l_transaction_uom        VARCHAR2 (3);
      l_currency_code          gmf_rcv_accounting_txns.currency_code%TYPE;
      l_item_exists            NUMBER;
      l_from_organization_id   NUMBER;
      l_from_org_id            NUMBER;
      l_to_org_id              NUMBER;
      l_incr_currency_code     gmf_rcv_accounting_txns.currency_code%TYPE;
      l_incr_transfer_price    NUMBER;
   BEGIN
      -- Standard start of API savepoint
      SAVEPOINT get_unitprice_pvt;
      l_stmt_num := 0;

      IF     g_debug = 'Y'
         AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_log_head || '.' || l_api_name || '.begin',
                         'Get_UnitPrice <<'
                        );
      END IF;

      -- Standard call to check for call compatibility
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      x_incr_transfer_price := 0;
      x_incr_currency_code := NULL;
      l_currency_code := p_rcv_accttxn.currency_code;
      l_stmt_num := 10;

      -- Always use PO price if :
      -- 1. No transaction flow exists or
      -- 2. Destination type is Shopfloor.
      -- 3. If it is the procurement org
      -- 4. The PO is for a one-time item.
      IF (   p_rcv_accttxn.trx_flow_header_id IS NULL
          OR p_rcv_accttxn.item_id IS NULL
          OR p_rcv_accttxn.destination_type_code = 'SHOP FLOOR'
          OR (    p_rcv_accttxn.procurement_org_flag = 'Y'
              AND p_rcv_accttxn.event_type_id NOT IN
                                (intercompany_invoice, intercompany_reversal)
             )
         )
      THEN
         l_ic_pricing_option := 1;
      ELSE
         -- Pricing Option on the Transaction Flow form will determine whether to use
         -- PO price or Transfer price.
         BEGIN
            -- Verify that item exists in organization where event is being created.
            l_stmt_num := 30;

            SELECT COUNT (*)
              INTO l_item_exists
              FROM mtl_system_items msi
             WHERE msi.inventory_item_id = p_rcv_accttxn.item_id
               AND msi.organization_id = p_rcv_accttxn.organization_id;

            IF (l_item_exists = 0)
            THEN
               fnd_message.set_name ('PO', 'PO_INVALID_ITEM');
               fnd_msg_pub.ADD;

               IF     g_debug = 'Y'
                  AND fnd_log.level_error >= fnd_log.g_current_runtime_level
               THEN
                  fnd_log.MESSAGE (fnd_log.level_error,
                                   g_log_head || '.' || l_api_name
                                   || l_stmt_num,
                                   FALSE
                                  );
               END IF;

               RAISE fnd_api.g_exc_error;
            END IF;

            -- Use Inventory Asset Flag in the organization where the physical event occurred. This
            -- would be the ship to organization id. Using POLL.ship_to_organization_id so it will be
            -- available for both Invoice Match and Receiving transactions.
            l_stmt_num := 40;

            SELECT msi.inventory_asset_flag
              INTO l_asset_flag
              FROM mtl_system_items msi, po_line_locations poll
             WHERE msi.inventory_item_id = p_rcv_accttxn.item_id
               AND msi.organization_id = poll.ship_to_organization_id
               AND poll.line_location_id = p_rcv_accttxn.po_line_location_id;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               fnd_message.set_name ('PO', 'PO_INVALID_ITEM');
               fnd_msg_pub.ADD;

               IF     g_debug = 'Y'
                  AND fnd_log.level_error >= fnd_log.g_current_runtime_level
               THEN
                  fnd_log.MESSAGE (fnd_log.level_error,
                                   g_log_head || '.' || l_api_name
                                   || l_stmt_num,
                                   FALSE
                                  );
               END IF;

               RAISE fnd_api.g_exc_error;
         END;

         IF (l_asset_flag = 'Y')
         THEN
            l_ic_pricing_option := p_asset_item_pricing_option;
         ELSE
            l_ic_pricing_option := p_expense_item_pricing_option;
         END IF;
      END IF;

      IF     g_debug = 'Y'
         AND fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         l_api_message := 'l_ic_pricing_option : ' || l_ic_pricing_option;
         fnd_log.STRING (fnd_log.level_statement,
                         g_log_head || '.' || l_api_name || '.' || l_stmt_num,
                         l_api_message
                        );
      END IF;

      -- l_ic_pricing_option of 1 => PO Price.
      -- l_ic_pricing_option of 2 => Transfer Price.
      IF (l_ic_pricing_option = 2)
      THEN
         l_stmt_num := 50;

         -- The l_ic_pricing_option can only be 2 for a source type of 'RECEIVING'.
         -- Get the UOM of the source_doc since unit price is desired in Document's UOM
         SELECT muom.uom_code
           INTO l_transaction_uom
           FROM rcv_transactions rt, mtl_units_of_measure muom
          WHERE rt.transaction_id = p_rcv_accttxn.rcv_transaction_id
            AND muom.unit_of_measure = rt.source_doc_unit_of_measure;

         -- While calling the transfer pricing API, the from organization id should be
         -- passed. For Intercompany transactions, the from organization id is the same as
         -- organization_id on the event. For the remaining transactions, the from organization
         -- is the transfer_organization_id on the event.
         IF (p_rcv_accttxn.event_type_id IN
                                (intercompany_invoice, intercompany_reversal)
            )
         THEN
            l_from_organization_id := p_rcv_accttxn.organization_id;
            l_from_org_id := p_rcv_accttxn.org_id;
            l_to_org_id := p_rcv_accttxn.transfer_org_id;
         ELSE
            l_from_organization_id := p_rcv_accttxn.transfer_organization_id;
            l_from_org_id := p_rcv_accttxn.transfer_org_id;
            l_to_org_id := p_rcv_accttxn.org_id;
         END IF;

         -- Alcoa enhancement. Users will be given the option to determine in which
         -- currency intercompany invoices should be created. The get_transfer_price
         -- API will return the transfer price in the selling OU currency as well in the
         -- currency chosen by the user. The returned values will have to be stored
         -- in MMT and will be used by Intercompany to determine the Currency in which
         -- to create the intercompany invoices.
         l_stmt_num := 60;

         IF     g_debug = 'Y'
            AND fnd_log.level_event >= fnd_log.g_current_runtime_level
         THEN
            l_api_message :=
                  'Calling get_transfer_price API : '
               || ' l_from_org_id : '
               || l_from_org_id
               || ' l_to_org_id : '
               || l_to_org_id
               || ' l_transaction_uom : '
               || l_transaction_uom
               || ' item_id : '
               || p_rcv_accttxn.item_id
               || ' p_transaction_id : '
               || p_rcv_accttxn.rcv_transaction_id;
            fnd_log.STRING (fnd_log.level_event,
                            g_log_head || '.' || l_api_name || '.'
                            || l_stmt_num,
                            l_api_message
                           );
         END IF;

         inv_transaction_flow_pub.get_transfer_price
                        (p_api_version                  => 1.0,
                         x_return_status                => l_return_status,
                         x_msg_data                     => l_msg_data,
                         x_msg_count                    => l_msg_count,
                         x_transfer_price               => l_transfer_price,
                         x_currency_code                => l_currency_code,
                         x_incr_transfer_price          => l_incr_transfer_price,
                         x_incr_currency_code           => l_incr_currency_code,
                         p_from_org_id                  => l_from_org_id,
                         p_to_org_id                    => l_to_org_id,
                         p_transaction_uom              => l_transaction_uom,
                         p_inventory_item_id            => p_rcv_accttxn.item_id,
                         p_transaction_id               => p_rcv_accttxn.rcv_transaction_id,
                         p_from_organization_id         => l_from_organization_id,
                         p_global_procurement_flag      => 'Y',
                         p_drop_ship_flag               => 'N'
                        );

         IF l_return_status <> fnd_api.g_ret_sts_success
         THEN
            IF     g_debug = 'Y'
               AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
            THEN
               l_api_message := 'Error getting transfer price';
               fnd_log.STRING (fnd_log.level_unexpected,
                               g_log_head || '.' || l_api_name || l_stmt_num,
                               l_api_message
                              );
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         IF     g_debug = 'Y'
            AND fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            l_api_message :=
               SUBSTR (   'l_transfer_price : '
                       || l_transfer_price
                       || ' l_currency_code : '
                       || l_currency_code
                       || ' l_incr_transfer_price : '
                       || l_incr_transfer_price
                       || ' l_incr_currency_code : '
                       || l_incr_currency_code,
                       1000
                      );
            fnd_log.STRING (fnd_log.level_statement,
                            g_log_head || '.' || l_api_name || l_stmt_num,
                               'Get_TransferPrice : '
                            || l_stmt_num
                            || ' : '
                            || l_api_message
                           );
         END IF;

         l_unit_price := l_transfer_price;
         x_incr_transfer_price := l_incr_transfer_price;
         x_incr_currency_code := l_incr_currency_code;
      ELSIF (   p_rcv_accttxn.event_source = 'RECEIVING'
             OR p_rcv_accttxn.event_source = 'RETROPRICE'
            )
      THEN
         l_stmt_num := 70;

         SELECT poll.price_override
           INTO l_unit_price
           FROM po_line_locations poll
          WHERE poll.line_location_id = p_rcv_accttxn.po_line_location_id;
      ELSIF (p_rcv_accttxn.event_source = 'INVOICEMATCH')
      THEN
         l_stmt_num := 80;

         SELECT apid.unit_price
           INTO l_unit_price
           FROM ap_invoice_distributions apid
          WHERE apid.invoice_distribution_id =
                                             p_rcv_accttxn.inv_distribution_id;
      END IF;

      x_intercompany_pricing_option := l_ic_pricing_option;
      x_unit_price := l_unit_price;
      x_currency_code := l_currency_code;

      IF     g_debug = 'Y'
         AND fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         l_api_message :=
            SUBSTR (   'x_ic_pricing_option : '
                    || x_intercompany_pricing_option
                    || ' x_unit_price : '
                    || x_unit_price
                    || ' x_currency_code : '
                    || x_currency_code
                    || ' x_incr_currency_code : '
                    || x_incr_currency_code
                    || ' x_incr_transfer_price : '
                    || x_incr_transfer_price,
                    1,
                    1000
                   );
         fnd_log.STRING (fnd_log.level_statement,
                         g_log_head || '.' || l_api_name || '.' || l_stmt_num,
                         l_api_message
                        );
      END IF;

      -- Standard check of p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard Call to get message count and if count = 1, get message info
      fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                 p_data       => x_msg_data);

      IF     g_debug = 'Y'
         AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_log_head || '.' || l_api_name || '.end',
                         'Get_UnitPrice >>'
                        );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO get_unitprice_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO get_unitprice_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN OTHERS
      THEN
         ROLLBACK TO get_unitprice_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF     g_debug = 'Y'
            AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_log_head || '.' || l_api_name || l_stmt_num,
                               'Get_UnitPrice : '
                            || l_stmt_num
                            || ' : '
                            || SUBSTR (SQLERRM, 1, 200)
                           );
         END IF;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name,
                                        l_api_name
                                     || 'Statement -'
                                     || TO_CHAR (l_stmt_num)
                                    );
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
   END get_unitprice;

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
--                              p_rcv_accttxn             IN rcv_accttxn_rec_type       Required
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--          x_unit_nr_tax     OUT   NUMBER
--          x_unit_rec_tax    OUT   NUMBER
--          x_prior_nr_tax    OUT   NUMBER
--          x_prior_rec_tax      OUT   NUMBER
--      Version :
--                        Initial version       1.0
--
--
--      Notes           : This API returns the tax information.
--
-- End of comments
   PROCEDURE get_unittax (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false,
      p_commit             IN              VARCHAR2 := fnd_api.g_false,
      p_validation_level   IN              NUMBER
            := fnd_api.g_valid_level_full,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2,
      p_rcv_accttxn        IN              gmf_rcv_accounting_pkg.rcv_accttxn_rec_type,
      x_unit_nr_tax        OUT NOCOPY      NUMBER,
      x_unit_rec_tax       OUT NOCOPY      NUMBER,
      x_prior_nr_tax       OUT NOCOPY      NUMBER,
      x_prior_rec_tax      OUT NOCOPY      NUMBER
   )
   IS
      l_api_name         CONSTANT VARCHAR2 (30)   := 'Get_UnitTax';
      l_api_version      CONSTANT NUMBER          := 1.0;
      l_return_status             VARCHAR2 (1)   := fnd_api.g_ret_sts_success;
      l_msg_count                 NUMBER          := 0;
      l_msg_data                  VARCHAR2 (8000) := '';
      l_stmt_num                  NUMBER          := 0;
      l_api_message               VARCHAR2 (1000);
      l_unit_nr_tax               NUMBER          := 0;
      l_unit_rec_tax              NUMBER          := 0;
      l_prior_nr_tax              NUMBER          := 0;
      l_prior_rec_tax             NUMBER          := 0;
      l_recoverable_tax           NUMBER          := 0;
      l_non_recoverable_tax       NUMBER          := 0;
      l_old_recoverable_tax       NUMBER          := 0;
      l_old_non_recoverable_tax   NUMBER          := 0;
   BEGIN
      -- Standard start of API savepoint
      SAVEPOINT get_unittax_pvt;
      l_stmt_num := 0;

      IF     g_debug = 'Y'
         AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_log_head || '.' || l_api_name || '.begin',
                         'Get_UnitTax <<'
                        );
      END IF;

      -- Standard call to check for call compatibility
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      x_unit_nr_tax := 0;
      x_unit_rec_tax := 0;
      x_prior_nr_tax := 0;
      x_prior_rec_tax := 0;
      l_stmt_num := 10;

      -- No tax is applicable if pricing option is transfer price.
      IF (p_rcv_accttxn.intercompany_pricing_option = 2)
      THEN
         RETURN;
      END IF;

      IF (   p_rcv_accttxn.event_source = 'RECEIVING'
          OR p_rcv_accttxn.event_source = 'RETROPRICE'
         )
      THEN
         l_stmt_num := 20;
         -- Call PO API to get current an prior receoverable and non-recoverable tax
         po_tax_sv.get_all_po_tax
                      (p_api_version                  => l_api_version,
                       x_return_status                => l_return_status,
                       x_msg_data                     => l_msg_data,
                       p_distribution_id              => p_rcv_accttxn.po_distribution_id,
                       x_recoverable_tax              => l_recoverable_tax,
                       x_non_recoverable_tax          => l_non_recoverable_tax,
                       x_old_recoverable_tax          => l_old_recoverable_tax,
                       x_old_non_recoverable_tax      => l_old_non_recoverable_tax
                      );

         IF l_return_status <> fnd_api.g_ret_sts_success
         THEN
            l_api_message := 'Error getting Tax';

            IF     g_debug = 'Y'
               AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_unexpected,
                               g_log_head || '.' || l_api_name || l_stmt_num,
                                  'Get_UnitPrice : '
                               || l_stmt_num
                               || ' : '
                               || l_api_message
                              );
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         IF     g_debug = 'Y'
            AND fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            l_api_message :=
               SUBSTR (   'l_recoverable_tax : '
                       || l_recoverable_tax
                       || ' l_non_recoverable_tax : '
                       || l_non_recoverable_tax
                       || ' l_old_recoverable_tax : '
                       || l_old_recoverable_tax
                       || ' l_old_non_recoverable_tax : '
                       || l_old_non_recoverable_tax,
                       1,
                       1000
                      );
            fnd_log.STRING (fnd_log.level_statement,
                            g_log_head || '.' || l_api_name || '.'
                            || l_stmt_num,
                            l_api_message
                           );
         END IF;

         IF (p_rcv_accttxn.service_flag = 'Y')
         THEN
            l_stmt_num := 30;

            SELECT l_non_recoverable_tax / pod.amount_ordered,
                   l_recoverable_tax / pod.amount_ordered
              INTO l_unit_nr_tax,
                   l_unit_rec_tax
              FROM po_distributions pod
             WHERE pod.po_distribution_id = p_rcv_accttxn.po_distribution_id;
         ELSE
            l_stmt_num := 40;

            SELECT l_non_recoverable_tax / pod.quantity_ordered,
                   l_recoverable_tax / pod.quantity_ordered
              INTO l_unit_nr_tax,
                   l_unit_rec_tax
              FROM po_distributions pod
             WHERE pod.po_distribution_id = p_rcv_accttxn.po_distribution_id;
         END IF;
      END IF;

      IF (p_rcv_accttxn.event_source = 'RETROPRICE')
      THEN
         l_stmt_num := 50;

         SELECT l_old_non_recoverable_tax / pod.quantity_ordered,
                l_old_recoverable_tax / pod.quantity_ordered
           INTO l_prior_nr_tax,
                l_prior_rec_tax
           FROM po_distributions pod
          WHERE po_distribution_id = p_rcv_accttxn.po_distribution_id;
      END IF;

      x_unit_nr_tax := NVL (l_unit_nr_tax, 0);
      x_unit_rec_tax := NVL (l_unit_rec_tax, 0);
      x_prior_nr_tax := NVL (l_prior_nr_tax, 0);
      x_prior_rec_tax := NVL (l_prior_rec_tax, 0);

      IF     g_debug = 'Y'
         AND fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         l_api_message :=
            SUBSTR (   'x_unit_nr_tax : '
                    || x_unit_nr_tax
                    || ' x_unit_rec_tax : '
                    || x_unit_rec_tax
                    || ' x_prior_nr_tax : '
                    || x_prior_nr_tax
                    || ' x_prior_rec_tax : '
                    || x_prior_rec_tax,
                    1,
                    1000
                   );
         fnd_log.STRING (fnd_log.level_statement,
                         g_log_head || '.' || l_api_name || '.' || l_stmt_num,
                         l_api_message
                        );
      END IF;

      --- Standard check of p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard Call to get message count and if count = 1, get message info
      fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                 p_data       => x_msg_data);

      IF     g_debug = 'Y'
         AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_log_head || '.' || l_api_name || '.end',
                         'Get_UnitTax >>'
                        );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO get_unittax_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO get_unittax_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN OTHERS
      THEN
         ROLLBACK TO get_unittax_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF     g_debug = 'Y'
            AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_log_head || '.' || l_api_name || l_stmt_num,
                               'Get_UnitTax : '
                            || l_stmt_num
                            || ' : '
                            || SUBSTR (SQLERRM, 1, 200)
                           );
         END IF;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name,
                                        l_api_name
                                     || 'Statement -'
                                     || TO_CHAR (l_stmt_num)
                                    );
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
   END get_unittax;

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
--  P_EVENT_REC        Record storing an RCV Accounting Event (GRAT)        --
--  X_TRANSACTION_QTY  Transaction quantity converted from source doc qty  --
--  X_PRIMARY_UOM      Converted UOM                                       --
--  X_PRIMARY_QTY      Primary quantity converted from source doc qty      --
--  X_TRX_UOM_CODE     Transaction UOM                                     --
--                                                                         --
-- HISTORY:                                                                --
--    06/26/03     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------
   PROCEDURE convert_uom (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false,
      p_commit             IN              VARCHAR2 := fnd_api.g_false,
      p_validation_level   IN              NUMBER
            := fnd_api.g_valid_level_full,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2,
      p_event_rec          IN              gmf_rcv_accounting_pkg.rcv_accttxn_rec_type,
      x_transaction_qty    OUT NOCOPY      NUMBER,
      x_primary_uom        OUT NOCOPY      mtl_units_of_measure.unit_of_measure%TYPE,
      x_primary_qty        OUT NOCOPY      NUMBER,
      x_trx_uom_code       OUT NOCOPY      VARCHAR2
   )
   IS
-- local control variables
      l_api_name      CONSTANT VARCHAR2 (30)                 := 'Convert_UOM';
      l_api_version   CONSTANT NUMBER                                  := 1.0;
      l_stmt_num               NUMBER                                    := 0;
      l_api_message            VARCHAR2 (1000);
-- local data variables
      l_item_id                NUMBER;
      l_primary_uom_rate       NUMBER;
      l_trx_uom_rate           NUMBER;
      l_primary_uom_code       mtl_units_of_measure.uom_code%TYPE;
      l_source_doc_uom_code    mtl_units_of_measure.uom_code%TYPE;
      l_trx_uom_code           mtl_units_of_measure.uom_code%TYPE;
      l_primary_uom            mtl_units_of_measure.unit_of_measure%TYPE;
   BEGIN
      SAVEPOINT convert_uom_pvt;

      -- Initialize message list if p_init_msg_list is set to TRUE
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      IF     g_debug = 'Y'
         AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_log_head || l_api_name || '.begin',
                         'Convert_UOM <<'
                        );
      END IF;

      -- Standard check for compatibility
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )                          -- line 90
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      x_msg_count := 0;
      x_msg_data := '';
      -- API body
      l_stmt_num := 10;
      l_item_id := p_event_rec.item_id;

      -- Get UOM code for the source document's UOM
      SELECT uom_code
        INTO l_source_doc_uom_code
        FROM mtl_units_of_measure
       WHERE unit_of_measure = p_event_rec.source_doc_uom;

      -- Get UOM code for the transaction UOM
      SELECT uom_code
        INTO l_trx_uom_code
        FROM mtl_units_of_measure
       WHERE unit_of_measure = p_event_rec.transaction_uom;

      -- Get UOM for this item/org from MSI and populate primary_uom with it
      IF (l_item_id IS NULL)
      THEN
         -- for a one-time item, the primary uom is the
         -- base uom for the item's current uom class
         l_stmt_num := 20;

         SELECT puom.uom_code, puom.unit_of_measure
           INTO l_primary_uom_code, l_primary_uom
           FROM mtl_units_of_measure tuom, mtl_units_of_measure puom
          WHERE tuom.unit_of_measure = p_event_rec.source_doc_uom
            AND tuom.uom_class = puom.uom_class
            AND puom.base_uom_flag = 'Y';

         l_item_id := 0;
      ELSE
         l_stmt_num := 30;

         SELECT primary_uom_code
           INTO l_primary_uom_code
           FROM mtl_system_items
          WHERE organization_id = p_event_rec.organization_id
            AND inventory_item_id = l_item_id;

         l_stmt_num := 40;

         SELECT unit_of_measure
           INTO l_primary_uom
           FROM mtl_units_of_measure
          WHERE uom_code = l_primary_uom_code;
      END IF;

      -- Get the UOM rate from source_doc_uom to primary_uom
      l_stmt_num := 50;
      inv_convert.inv_um_conversion (from_unit      => l_source_doc_uom_code,
                                     to_unit        => l_primary_uom_code,
                                     item_id        => l_item_id,
                                     uom_rate       => l_primary_uom_rate
                                    );

      IF (l_primary_uom_rate = -99999)
      THEN
         RAISE fnd_api.g_exc_error;
         l_api_message :=
                 'inv_convert.inv_um_conversion() failed to get the UOM rate';

         IF     g_debug = 'Y'
            AND fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_log_head || l_api_name || '.' || l_stmt_num,
                            l_api_message
                           );
         END IF;
      END IF;

      -- Get the UOM rate from source_doc_uom to transaction_uom
      l_stmt_num := 60;
      inv_convert.inv_um_conversion (from_unit      => l_source_doc_uom_code,
                                     to_unit        => l_trx_uom_code,
                                     item_id        => l_item_id,
                                     uom_rate       => l_trx_uom_rate
                                    );

      IF (l_trx_uom_rate = -99999)
      THEN
         RAISE fnd_api.g_exc_error;
         l_api_message :=
                 'inv_convert.inv_um_conversion() failed to get the UOM rate';

         IF     g_debug = 'Y'
            AND fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_log_head || l_api_name || '.' || l_stmt_num,
                            l_api_message
                           );
         END IF;
      END IF;

      -- Populate output variables
      x_primary_uom := l_primary_uom;
      x_primary_qty :=
               ROUND (l_primary_uom_rate * p_event_rec.source_doc_quantity, 6);
      x_transaction_qty :=
                   ROUND (l_trx_uom_rate * p_event_rec.source_doc_quantity, 6);
      x_trx_uom_code := l_trx_uom_code;

      IF     g_debug = 'Y'
         AND fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         l_api_message :=
               'x_primary_uom : '
            || x_primary_uom
            || ' x_primary_qty : '
            || x_primary_qty
            || ' x_transaction_qty : '
            || x_transaction_qty
            || ' x_trx_uom_code : '
            || x_trx_uom_code;
         fnd_log.STRING (fnd_log.level_statement,
                         g_log_head || '.' || l_api_name || '.' || l_stmt_num,
                         l_api_message
                        );
      END IF;

      -- End of API body

      -- Standard check of P_COMMIT
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      IF     g_debug = 'Y'
         AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_log_head || l_api_name || '.end',
                         'Convert_UOM >>'
                        );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO convert_uom_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO convert_uom_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN NO_DATA_FOUND
      THEN
         ROLLBACK TO convert_uom_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         l_api_message :=
                ': Statement # ' || TO_CHAR (l_stmt_num)
                || ' - No UOM found.';

         IF     g_debug = 'Y'
            AND fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_log_head || l_api_name || '.' || l_stmt_num,
                            l_api_message
                           );
         END IF;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name || l_api_message);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN OTHERS
      THEN
         ROLLBACK TO convert_uom_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         l_api_message :=
               'Unexpected Error at statement('
            || TO_CHAR (l_stmt_num)
            || '): '
            || TO_CHAR (SQLCODE)
            || '- '
            || SUBSTRB (SQLERRM, 1, 100);

         IF     g_debug = 'Y'
            AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_log_head || l_api_name || '.' || l_stmt_num,
                            l_api_message
                           );
         END IF;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name || l_api_message);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
   END convert_uom;

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
--  P_rcv_accttxn        Record storing an RCV Accounting Event (GRAT)        --
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
   PROCEDURE get_currency (
      p_api_version                IN              NUMBER,
      p_init_msg_list              IN              VARCHAR2 := fnd_api.g_false,
      p_commit                     IN              VARCHAR2 := fnd_api.g_false,
      p_validation_level           IN              NUMBER
            := fnd_api.g_valid_level_full,
      x_return_status              OUT NOCOPY      VARCHAR2,
      x_msg_count                  OUT NOCOPY      NUMBER,
      x_msg_data                   OUT NOCOPY      VARCHAR2,
      p_rcv_accttxn                IN              gmf_rcv_accounting_pkg.rcv_accttxn_rec_type,
      x_currency_code              OUT NOCOPY      VARCHAR2,
      x_currency_conversion_rate   OUT NOCOPY      NUMBER,
      x_currency_conversion_date   OUT NOCOPY      DATE,
      x_currency_conversion_type   OUT NOCOPY      VARCHAR2
   )
   IS
-- local control variables
      l_api_name          CONSTANT VARCHAR2 (30)   := 'GET_Currency';
      l_api_version       CONSTANT NUMBER          := 1.0;
      l_stmt_num                   NUMBER          := 0;
      l_api_message                VARCHAR2 (1000);
-- local data variables
      l_match_option               VARCHAR2 (1);
      l_currency_code              VARCHAR2 (3);
      l_currency_conversion_rate   NUMBER;
      l_currency_conversion_date   DATE;
      l_currency_conversion_type   VARCHAR2 (30)   := '';
      l_ledger_id                  NUMBER;
      l_po_line_location_id        NUMBER;
      l_rcv_transaction_id         NUMBER;
   BEGIN
      SAVEPOINT get_currency_pvt;

-- Standard call to check for call compatibility
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

-- Initialize message list if p_init_msg_list is set to TRUE
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

-- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
-- API body
      l_stmt_num := 10;

      IF (    (p_rcv_accttxn.procurement_org_flag = 'Y')
          AND (p_rcv_accttxn.event_type_id NOT IN
                                (intercompany_invoice, intercompany_reversal)
              )
         )
      THEN
         l_currency_code := p_rcv_accttxn.currency_code;
         l_stmt_num := 20;

         SELECT line_location_id
           INTO l_po_line_location_id
           FROM po_distributions
          WHERE po_distribution_id = p_rcv_accttxn.po_distribution_id;

         l_stmt_num := 30;

         SELECT match_option
           INTO l_match_option
           FROM po_line_locations
          WHERE line_location_id = l_po_line_location_id;

         -- Always use rate on the PO distribution for encumbrance reversals.
         IF (   l_match_option = 'P'
             OR (p_rcv_accttxn.event_type_id = encumbrance_reversal)
            )
         THEN
            l_stmt_num := 40;

            SELECT NVL (pod.rate, 1), poh.rate_type,
                   pod.rate_date
              INTO l_currency_conversion_rate, l_currency_conversion_type,
                   l_currency_conversion_date
              FROM po_distributions pod, po_headers poh
             WHERE pod.po_distribution_id = p_rcv_accttxn.po_distribution_id
               AND poh.po_header_id = pod.po_header_id;
         ELSE
            -- This is also correct for ADJUST transactions where we only create one event
            -- for every parent transaction. In the case of a Match to receipt PO, the
            -- currency conversion rate of the child transactions (DELIVER CORRECT, RTR,
            -- RTV) will be the same as the currency conversion rate on the parent
            -- RECEIVE/MATCH transaction. This will be the case even if the daily rate
            -- has changed between the time that the parent transaction was done and the
            -- time that the child transactions were done.
            l_stmt_num := 50;

            SELECT rt.currency_conversion_rate, rt.currency_conversion_type,
                   rt.currency_conversion_date
              INTO l_currency_conversion_rate, l_currency_conversion_type,
                   l_currency_conversion_date
              FROM rcv_transactions rt
             WHERE rt.transaction_id = p_rcv_accttxn.rcv_transaction_id;
         END IF;
      ELSE
         l_currency_code := p_rcv_accttxn.currency_code;
         l_ledger_id := p_rcv_accttxn.ledger_id;
         -- Use profile INV: Intercompany Currency conversion Type, to determine Conversion Type
         -- Ensure that INV uses the same type for conversion for GP/ DS scenarios
         l_stmt_num := 70;
         fnd_profile.get ('IC_CURRENCY_CONVERSION_TYPE',
                          l_currency_conversion_type
                         );
         l_stmt_num := 80;
         l_currency_conversion_rate :=
            gl_currency_api.get_rate
                         (x_set_of_books_id      => l_ledger_id,
                          x_from_currency        => l_currency_code,
                          x_conversion_date      => p_rcv_accttxn.transaction_date,
                          x_conversion_type      => l_currency_conversion_type
                         );
      END IF;

      x_currency_code := l_currency_code;
      x_currency_conversion_rate := l_currency_conversion_rate;
      x_currency_conversion_date := NVL (l_currency_conversion_date, SYSDATE);
      x_currency_conversion_type := l_currency_conversion_type;

      IF     g_debug = 'Y'
         AND fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         l_api_message :=
            SUBSTR (   'x_currency_code : '
                    || x_currency_code
                    || ' x_currency_conversion_rate : '
                    || TO_CHAR (x_currency_conversion_rate)
                    || ' x_currency_conversion_date : '
                    || TO_CHAR (x_currency_conversion_date, 'DD-MON-YY')
                    || ' x_currency_conversion_type : '
                    || x_currency_conversion_type,
                    1,
                    1000
                   );
         fnd_log.STRING (fnd_log.level_statement,
                         g_log_head || '.' || l_api_name || '.' || l_stmt_num,
                         l_api_message
                        );
      END IF;

-- End of API body
      fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                 p_count        => x_msg_count,
                                 p_data         => x_msg_data
                                );

-- Standard check of P_COMMIT
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO get_currency_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO get_currency_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN NO_DATA_FOUND
      THEN
         ROLLBACK TO get_currency_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         l_api_message :=
               'Unexpected Error: '
            || l_stmt_num
            || TO_CHAR (SQLCODE)
            || '- '
            || SUBSTRB (SQLERRM, 1, 200);

         IF     g_debug = 'Y'
            AND fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_log_head || l_api_name || '.' || l_stmt_num,
                            l_api_message
                           );
         END IF;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name,
                                        l_api_name
                                     || 'Statement -'
                                     || TO_CHAR (l_stmt_num)
                                    );
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN OTHERS
      THEN
         ROLLBACK TO get_currency_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         l_api_message :=
               'Unexpected Error: '
            || l_stmt_num
            || TO_CHAR (SQLCODE)
            || '- '
            || SUBSTRB (SQLERRM, 1, 200);

         IF     g_debug = 'Y'
            AND fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_log_head || l_api_name || '.' || l_stmt_num,
                            l_api_message
                           );
         END IF;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name,
                                        l_api_name
                                     || 'Statement -'
                                     || TO_CHAR (l_stmt_num)
                                    );
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
   END get_currency;

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
--                              p_rcv_accttxn             IN rcv_accttxn_rec_type       Required
--                              p_transaction_forward_flow_rec  mtl_transaction_flow_rec_type,
--                              p_transaction_reverse_flow_rec  mtl_transaction_flow_rec_type,
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--          x_credit_acct_id  OUT   NUMBER
--          x_debit_acct_id      OUT   NUMBER
--          x_ic_cogs_acct_id OUT   NUMBER
--      Version :
--                        Initial version       1.0
--
--
--      Notes           : This API creates all accounting transactions for RETURN TO VENDOR transactions
--                        in gmf_rcv_accounting_txns.
--
-- End of comments
   PROCEDURE get_accounts (
      p_api_version                    IN              NUMBER,
      p_init_msg_list                  IN              VARCHAR2
            := fnd_api.g_false,
      p_commit                         IN              VARCHAR2
            := fnd_api.g_false,
      p_validation_level               IN              NUMBER
            := fnd_api.g_valid_level_full,
      x_return_status                  OUT NOCOPY      VARCHAR2,
      x_msg_count                      OUT NOCOPY      NUMBER,
      x_msg_data                       OUT NOCOPY      VARCHAR2,
      p_rcv_accttxn                    IN              gmf_rcv_accounting_pkg.rcv_accttxn_rec_type,
      p_transaction_forward_flow_rec                   inv_transaction_flow_pub.mtl_transaction_flow_rec_type,
      p_transaction_reverse_flow_rec                   inv_transaction_flow_pub.mtl_transaction_flow_rec_type,
      x_credit_acct_id                 OUT NOCOPY      NUMBER,
      x_debit_acct_id                  OUT NOCOPY      NUMBER,
      x_ic_cogs_acct_id                OUT NOCOPY      NUMBER
   )
   IS
      l_api_name        CONSTANT VARCHAR2 (30)              := 'Get_Accounts';
      l_api_version     CONSTANT NUMBER                                := 1.0;
      l_return_status            VARCHAR2 (1)    := fnd_api.g_ret_sts_success;
      l_msg_count                NUMBER                                  := 0;
      l_msg_data                 VARCHAR2 (8000)                        := '';
      l_stmt_num                 NUMBER                                  := 0;
      l_api_message              VARCHAR2 (1000);
      l_credit_acct_id           NUMBER;
      l_debit_acct_id            NUMBER;
      l_dist_acct_id             NUMBER;
      l_ic_cogs_acct_id          NUMBER;
      l_ic_coss_acct_id          NUMBER;
      l_pod_accrual_acct_id      NUMBER;
      l_pod_ccid                 NUMBER;
      l_dest_pod_ccid            NUMBER;
      l_pod_budget_acct_id       NUMBER;
      l_receiving_insp_acct_id   NUMBER;
      l_clearing_acct_id         NUMBER;
      l_retroprice_adj_acct_id   NUMBER;
      l_overlaid_acct            NUMBER;
      l_trx_type                 rcv_transactions.transaction_type%TYPE;
      l_parent_trx_type          rcv_transactions.transaction_type%TYPE;
      l_parent_trx_id            NUMBER;
      l_account_flag             NUMBER                                  := 0;
   BEGIN
      -- Standard start of API savepoint
      SAVEPOINT get_accounts_pvt;
      l_stmt_num := 0;

      IF     g_debug = 'Y'
         AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_log_head || '.' || l_api_name || '.begin',
                         'Get_Accounts <<'
                        );
      END IF;

      -- Standard call to check for call compatibility
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      x_credit_acct_id := NULL;
      x_debit_acct_id := NULL;
      x_ic_cogs_acct_id := NULL;
      -- No accounts are stored for IC transactions.
      l_stmt_num := 5;

      IF (p_rcv_accttxn.event_type_id IN
                                (intercompany_invoice, intercompany_reversal)
         )
      THEN
         RETURN;
      END IF;

      l_stmt_num := 10;

      SELECT pod.accrual_account_id, pod.code_combination_id,
             NVL (pod.dest_charge_account_id, pod.code_combination_id),
             pod.budget_account_id
        INTO l_pod_accrual_acct_id, l_pod_ccid,
             l_dest_pod_ccid,
             l_pod_budget_acct_id
        FROM po_distributions pod
       WHERE pod.po_distribution_id = p_rcv_accttxn.po_distribution_id;

      l_stmt_num := 20;

      IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.STRING  (
                        fnd_log.level_procedure,
                        g_log_head || '.' || l_api_name || 'stmt num 20',
                        p_rcv_accttxn.organization_id
                        );
      END IF;

      SELECT receiving_account_id, clearing_account_id,
             retroprice_adj_account_id
        INTO l_receiving_insp_acct_id, l_clearing_acct_id,
             l_retroprice_adj_acct_id
        FROM rcv_parameters
       WHERE organization_id = p_rcv_accttxn.organization_id;

       IF G_DEBUG = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.STRING  (
                        fnd_log.level_procedure,
                        g_log_head || '.' || l_api_name || 'stmt num 20-2',
                        p_rcv_accttxn.organization_id
                        );
       END IF;

      -- Changes for JFMIP. Bug # 3076229. Call API to override the balancing segment
      -- of the Receiving Inspection account for expense destination types. The option
      -- (Auto Offset Override on PO_SYSTEM_PARAMETERS) will only be available in orgs
      -- where encumbrance is enabled. Hence this is not applicable to Global Procurement,
      -- Drop Ship or retroactive pricing.
      IF (    p_rcv_accttxn.trx_flow_header_id IS NULL
          AND p_rcv_accttxn.event_type_id IN
                 (receive,
                  match,
                  deliver,
                  correct,
                  return_to_receiving,
                  return_to_vendor
                 )
          AND p_rcv_accttxn.destination_type_code = 'EXPENSE'
         )
      THEN
         l_stmt_num := 30;
         po_accounting_grp.build_offset_account
                                    (p_api_version          => 1.0,
                                     p_init_msg_list        => fnd_api.g_false,
                                     x_return_status        => l_return_status,
                                     p_base_ccid            => l_receiving_insp_acct_id,
                                     p_overlay_ccid         => l_dest_pod_ccid,
                                     p_accounting_date      => SYSDATE,
                                     p_org_id               => p_rcv_accttxn.org_id,
                                     x_result_ccid          => l_overlaid_acct
                                    );
         l_receiving_insp_acct_id := l_overlaid_acct;
      END IF;

      IF (p_rcv_accttxn.event_type_id = correct)
      THEN
         l_stmt_num := 40;

         SELECT parent_trx.transaction_type
           INTO l_parent_trx_type
           FROM rcv_transactions trx, rcv_transactions parent_trx
          WHERE trx.transaction_id = p_rcv_accttxn.rcv_transaction_id
            AND trx.parent_transaction_id = parent_trx.transaction_id;
      END IF;

      l_stmt_num := 50;

      IF (   (p_rcv_accttxn.event_type_id = receive)
          OR (p_rcv_accttxn.event_type_id = match)
          OR (    p_rcv_accttxn.event_type_id = correct
              AND l_parent_trx_type = 'RECEIVE'
             )
          OR     p_rcv_accttxn.event_type_id = correct
             AND l_parent_trx_type = 'MATCH'
         )
      THEN
         l_debit_acct_id := l_receiving_insp_acct_id;

         IF (p_rcv_accttxn.procurement_org_flag = 'Y')
         THEN
            l_credit_acct_id := l_pod_accrual_acct_id;
         ELSIF (p_rcv_accttxn.item_id IS NULL)
         THEN
            l_credit_acct_id :=
                    p_transaction_reverse_flow_rec.expense_accrual_account_id;
         ELSE
            l_credit_acct_id :=
                  p_transaction_reverse_flow_rec.inventory_accrual_account_id;
         END IF;
      ELSIF (p_rcv_accttxn.event_type_id = logical_receive)
      THEN
         -- Use clearing account for :
         --     a. destination type of Inventory
         --     b. destination type of Expense for inventory items.
         -- Use Cost of Sales account for
         --     a. destination type of Shop Floor.
         --     b. destination type of Expense for one time items
         IF (   p_rcv_accttxn.destination_type_code = 'INVENTORY'
             OR (    p_rcv_accttxn.destination_type_code = 'EXPENSE'
                 AND p_rcv_accttxn.item_id IS NOT NULL
                )
            )
         THEN
            l_debit_acct_id := l_clearing_acct_id;
         ELSIF (p_rcv_accttxn.procurement_org_flag = 'Y')
         THEN
            l_debit_acct_id := l_pod_ccid;
         ELSE
            l_stmt_num := 60;

            SELECT cost_of_sales_account
              INTO l_ic_coss_acct_id
              FROM mtl_parameters mp
             WHERE mp.organization_id = p_rcv_accttxn.organization_id;

            l_stmt_num := 70;
            get_hookaccount
                    (p_api_version               => l_api_version,
                     x_return_status             => l_return_status,
                     x_msg_count                 => l_msg_count,
                     x_msg_data                  => l_msg_data,
                     p_rcv_transaction_id        => p_rcv_accttxn.rcv_transaction_id,
                     p_accounting_line_type      => 'IC Cost Of Sales',
                     p_org_id                    => p_rcv_accttxn.org_id,
                     x_distribution_acct_id      => l_dist_acct_id
                    );

            IF l_return_status <> fnd_api.g_ret_sts_success
            THEN
               l_api_message := 'Error in Get_HookAccount';

               IF     g_debug = 'Y'
                  AND fnd_log.level_unexpected >=
                                               fnd_log.g_current_runtime_level
               THEN
                  fnd_log.STRING (fnd_log.level_unexpected,
                                  g_log_head || '.' || l_api_name
                                  || l_stmt_num,
                                     'Get_Accounts : '
                                  || l_stmt_num
                                  || ' : '
                                  || l_api_message
                                 );
               END IF;

               RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            IF (l_dist_acct_id = -1)
            THEN
               l_debit_acct_id := l_ic_coss_acct_id;
            ELSE
               l_debit_acct_id := l_dist_acct_id;
            END IF;
         END IF;

         l_stmt_num := 80;

         IF (p_rcv_accttxn.procurement_org_flag = 'Y')
         THEN
            l_credit_acct_id := l_pod_accrual_acct_id;
         ELSIF (p_rcv_accttxn.item_id IS NULL)
         THEN
            l_credit_acct_id :=
                    p_transaction_reverse_flow_rec.expense_accrual_account_id;
         ELSE
            l_credit_acct_id :=
                  p_transaction_reverse_flow_rec.inventory_accrual_account_id;
         END IF;
      ELSIF (   p_rcv_accttxn.event_type_id = deliver
             OR (    p_rcv_accttxn.event_type_id = correct
                 AND l_parent_trx_type = 'DELIVER'
                )
            )
      THEN
         l_debit_acct_id := l_dest_pod_ccid;
         l_credit_acct_id := l_receiving_insp_acct_id;
      ELSIF (   p_rcv_accttxn.event_type_id = return_to_vendor
             OR (    p_rcv_accttxn.event_type_id = correct
                 AND l_parent_trx_type = 'RETURN TO VENDOR'
                )
            )
      THEN
         l_credit_acct_id := l_receiving_insp_acct_id;

         IF (p_rcv_accttxn.procurement_org_flag = 'Y')
         THEN
            l_debit_acct_id := l_pod_accrual_acct_id;
         ELSIF (p_rcv_accttxn.item_id IS NULL)
         THEN
            l_debit_acct_id :=
                    p_transaction_reverse_flow_rec.expense_accrual_account_id;
         ELSE
            l_debit_acct_id :=
                  p_transaction_reverse_flow_rec.inventory_accrual_account_id;
         END IF;
      ELSIF (p_rcv_accttxn.event_type_id = logical_return_to_vendor)
      THEN
         IF (   p_rcv_accttxn.destination_type_code = 'INVENTORY'
             OR (    p_rcv_accttxn.destination_type_code = 'EXPENSE'
                 AND p_rcv_accttxn.item_id IS NOT NULL
                )
            )
         THEN
            l_credit_acct_id := l_clearing_acct_id;
         ELSIF (p_rcv_accttxn.procurement_org_flag = 'Y')
         THEN
            l_credit_acct_id := l_pod_ccid;
         ELSE
            l_stmt_num := 90;

            SELECT cost_of_sales_account
              INTO l_ic_coss_acct_id
              FROM mtl_parameters mp
             WHERE mp.organization_id = p_rcv_accttxn.organization_id;

            l_stmt_num := 100;
            get_hookaccount
                    (p_api_version               => l_api_version,
                     x_return_status             => l_return_status,
                     x_msg_count                 => l_msg_count,
                     x_msg_data                  => l_msg_data,
                     p_rcv_transaction_id        => p_rcv_accttxn.rcv_transaction_id,
                     p_accounting_line_type      => 'IC Cost Of Sales',
                     p_org_id                    => p_rcv_accttxn.org_id,
                     x_distribution_acct_id      => l_dist_acct_id
                    );

            IF l_return_status <> fnd_api.g_ret_sts_success
            THEN
               l_api_message := 'Error in Get_HookAccount';

               IF     g_debug = 'Y'
                  AND fnd_log.level_unexpected >=
                                               fnd_log.g_current_runtime_level
               THEN
                  fnd_log.STRING (fnd_log.level_unexpected,
                                  g_log_head || '.' || l_api_name
                                  || l_stmt_num,
                                     'Get_Accounts : '
                                  || l_stmt_num
                                  || ' : '
                                  || l_api_message
                                 );
               END IF;

               RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            IF (l_dist_acct_id = -1)
            THEN
               l_credit_acct_id := l_ic_coss_acct_id;
            ELSE
               l_credit_acct_id := l_dist_acct_id;
            END IF;
         END IF;

         IF (p_rcv_accttxn.procurement_org_flag = 'Y')
         THEN
            l_debit_acct_id := l_pod_accrual_acct_id;
         ELSIF (p_rcv_accttxn.item_id IS NULL)
         THEN
            l_debit_acct_id :=
                    p_transaction_reverse_flow_rec.expense_accrual_account_id;
         ELSE
            l_debit_acct_id :=
                  p_transaction_reverse_flow_rec.inventory_accrual_account_id;
         END IF;
      ELSIF (   p_rcv_accttxn.event_type_id = return_to_receiving
             OR (    p_rcv_accttxn.event_type_id = correct
                 AND l_parent_trx_type = 'RETURN TO RECEIVING'
                )
            )
      THEN
         l_credit_acct_id := l_dest_pod_ccid;
         l_debit_acct_id := l_receiving_insp_acct_id;
      ELSIF (p_rcv_accttxn.event_type_id = adjust_receive)
      THEN
         -- In the case of drop shipments, we always use the clearing account instead of the Receiving
         -- Inspection account. In these scenarios, we should be posting the adjustment for the entire
         -- Receipt to the retroactive price adjustment account.
         IF (   p_rcv_accttxn.trx_flow_header_id IS NOT NULL
             OR p_rcv_accttxn.drop_ship_flag IN (1, 2)
            )
         THEN
            -- For global procurement scenarios, the debit account is :
            -- Retroprice adjustment account for inv items and direct items.
            -- IC Cost Of Sales(Charge acct on POD) for one-time items and Expense destinations.
            IF (   p_rcv_accttxn.item_id IS NOT NULL
                OR p_rcv_accttxn.destination_type_code = 'SHOP FLOOR'
               )
            THEN
               l_stmt_num := 110;
               get_hookaccount
                   (p_api_version               => l_api_version,
                    x_return_status             => l_return_status,
                    x_msg_count                 => l_msg_count,
                    x_msg_data                  => l_msg_data,
                    p_rcv_transaction_id        => p_rcv_accttxn.rcv_transaction_id,
                    p_accounting_line_type      => 'Retroprice Adjustment',
                    p_org_id                    => p_rcv_accttxn.org_id,
                    x_distribution_acct_id      => l_dist_acct_id
                   );

               IF l_return_status <> fnd_api.g_ret_sts_success
               THEN
                  l_api_message := 'Error in Get_HookAccount';

                  IF     g_debug = 'Y'
                     AND fnd_log.level_unexpected >=
                                               fnd_log.g_current_runtime_level
                  THEN
                     fnd_log.STRING (fnd_log.level_unexpected,
                                        g_log_head
                                     || '.'
                                     || l_api_name
                                     || l_stmt_num,
                                        'Get_Accounts : '
                                     || l_stmt_num
                                     || ' : '
                                     || l_api_message
                                    );
                  END IF;

                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;

               IF (l_dist_acct_id = -1)
               THEN
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
      ELSIF (p_rcv_accttxn.event_type_id = adjust_deliver)
      THEN
         -- Redundant check. Transaction flow header id is always NULL. We only
         -- get ADJUST_RECEIVE transactions for global procurement.
         IF (    p_rcv_accttxn.trx_flow_header_id IS NULL
             AND p_rcv_accttxn.drop_ship_flag NOT IN (1, 2)
            )
         THEN
            IF (p_rcv_accttxn.destination_type_code = 'EXPENSE')
            THEN
               l_debit_acct_id := l_dest_pod_ccid;
            ELSE
               l_stmt_num := 120;
               get_hookaccount
                   (p_api_version               => l_api_version,
                    x_return_status             => l_return_status,
                    x_msg_count                 => l_msg_count,
                    x_msg_data                  => l_msg_data,
                    p_rcv_transaction_id        => p_rcv_accttxn.rcv_transaction_id,
                    p_accounting_line_type      => 'Retroprice Adjustment',
                    p_org_id                    => p_rcv_accttxn.org_id,
                    x_distribution_acct_id      => l_dist_acct_id
                   );

               IF l_return_status <> fnd_api.g_ret_sts_success
               THEN
                  l_api_message := 'Error in Get_HookAccount';

                  IF     g_debug = 'Y'
                     AND fnd_log.level_unexpected >=
                                               fnd_log.g_current_runtime_level
                  THEN
                     fnd_log.STRING (fnd_log.level_unexpected,
                                        g_log_head
                                     || '.'
                                     || l_api_name
                                     || l_stmt_num,
                                        'Get_Accounts : '
                                     || l_stmt_num
                                     || ' : '
                                     || l_api_message
                                    );
                  END IF;

                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;

               IF (l_dist_acct_id = -1)
               THEN
                  l_debit_acct_id := l_retroprice_adj_acct_id;
               ELSE
                  l_debit_acct_id := l_dist_acct_id;
               END IF;
            END IF;
         END IF;

         l_stmt_num := 130;
         l_credit_acct_id := l_receiving_insp_acct_id;
      ELSIF (   p_rcv_accttxn.event_type_id = intercompany_invoice
             OR p_rcv_accttxn.event_type_id = intercompany_reversal
            )
      THEN
         l_credit_acct_id := NULL;
         l_debit_acct_id := NULL;
      ELSIF (p_rcv_accttxn.event_type_id = encumbrance_reversal)
      THEN
         l_stmt_num := 140;

         SELECT rt.transaction_type, rt.parent_transaction_id
           INTO l_trx_type, l_parent_trx_id
           FROM rcv_transactions rt
          WHERE rt.transaction_id = p_rcv_accttxn.rcv_transaction_id;

         IF (l_trx_type = 'DELIVER')
         THEN
            l_credit_acct_id := l_pod_budget_acct_id;
            l_debit_acct_id := NULL;
         ELSIF (l_trx_type = 'RETURN TO RECEIVING')
         THEN
            l_debit_acct_id := l_pod_budget_acct_id;
            l_credit_acct_id := NULL;
         ELSIF (l_trx_type = 'CORRECT')
         THEN
            l_stmt_num := 150;

            SELECT parent_trx.transaction_type
              INTO l_parent_trx_type
              FROM rcv_transactions parent_trx
             WHERE parent_trx.transaction_id = l_parent_trx_id;

            IF (l_parent_trx_type = 'DELIVER')
            THEN
               l_credit_acct_id := l_pod_budget_acct_id;
               l_debit_acct_id := NULL;
            ELSIF (l_parent_trx_type = 'RETURN_TO_RECEIVING')
            THEN
               l_debit_acct_id := l_pod_budget_acct_id;
               l_credit_acct_id := NULL;
            END IF;
         END IF;
      END IF;

      x_debit_acct_id := l_debit_acct_id;
      x_credit_acct_id := l_credit_acct_id;
      x_ic_cogs_acct_id :=
                   p_transaction_forward_flow_rec.intercompany_cogs_account_id;

      IF     g_debug = 'Y'
         AND fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         l_api_message :=
               'x_debit_acct_id : '
            || x_debit_acct_id
            || ' x_credit_acct_id : '
            || x_credit_acct_id
            || ' x_ic_cogs_acct_id : '
            || x_ic_cogs_acct_id;
         fnd_log.STRING (fnd_log.level_statement,
                         g_log_head || '.' || l_api_name || '.' || l_stmt_num,
                         l_api_message
                        );
      END IF;

      IF (    (l_debit_acct_id IS NULL OR l_credit_acct_id IS NULL)
          AND (p_rcv_accttxn.event_type_id NOT IN
                  (intercompany_invoice,
                   intercompany_reversal,
                   encumbrance_reversal
                  )
              )
         )
      THEN
         IF     g_debug = 'Y'
            AND fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            l_api_message :=
               'Unable to find credit and/or debit account. Setup is incomplete. ';
            fnd_log.STRING (fnd_log.level_statement,
                            g_log_head || '.' || l_api_name || '.'
                            || l_stmt_num,
                            l_api_message
                           );
         END IF;

         fnd_message.set_name ('PO', 'PO_INVALID_ACCOUNT');
         fnd_msg_pub.ADD;

         IF     g_debug = 'Y'
            AND fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.MESSAGE (fnd_log.level_error,
                             g_log_head || '.' || l_api_name || l_stmt_num,
                             FALSE
                            );
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      -- Standard check of p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard Call to get message count and if count = 1, get message info
      fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                 p_data       => x_msg_data);

      IF     g_debug = 'Y'
         AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_log_head || '.' || l_api_name || '.end',
                         'Get_Accounts >>'
                        );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO get_accounts_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO get_accounts_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN OTHERS
      THEN
         ROLLBACK TO get_accounts_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF     g_debug = 'Y'
            AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_log_head || '.' || l_api_name || l_stmt_num,
                               'Get_Accounts : '
                            || l_stmt_num
                            || ' : '
                            || SUBSTR (SQLERRM, 1, 200)
                           );
         END IF;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name,
                                        l_api_name
                                     || 'Statement -'
                                     || TO_CHAR (l_stmt_num)
                                    );
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
   END get_accounts;

-- Start of comments
--      API name        : Get_UssglTC
--      Type            : Private
--      Function        : To get the USSGL Transaction code, if applicable.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_rcv_accttxn             IN rcv_accttxn_rec_type       Required
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--          x_ussgl_tc     OUT   VARCHAR2(30)
--      Version :
--                        Initial version       1.0
--
--
--      Notes           : This procedure returns the USSGL Transaction Code for the event,
--         if applicable.
--
-- End of comments
   PROCEDURE get_ussgltc (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false,
      p_commit             IN              VARCHAR2 := fnd_api.g_false,
      p_validation_level   IN              NUMBER
            := fnd_api.g_valid_level_full,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2,
      p_rcv_accttxn        IN              gmf_rcv_accounting_pkg.rcv_accttxn_rec_type,
      x_ussgl_tc           OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_name      CONSTANT VARCHAR2 (30)   := 'Get_UssglTC';
      l_api_version   CONSTANT NUMBER          := 1.0;
      l_return_status          VARCHAR2 (1)    := fnd_api.g_ret_sts_success;
      l_msg_count              NUMBER          := 0;
      l_msg_data               VARCHAR2 (8000) := '';
      l_stmt_num               NUMBER          := 0;
      l_api_message            VARCHAR2 (1000);
      l_ussgl_tc               VARCHAR2 (30);
      l_ussgl_option           VARCHAR2 (1);
   BEGIN
      -- Standard start of API savepoint
      SAVEPOINT get_ussgltc_pvt;
      l_stmt_num := 0;

      IF     g_debug = 'Y'
         AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_log_head || '.' || l_api_name || '.begin',
                         'Get_UssglTC <<'
                        );
      END IF;

      -- Standard call to check for call compatibility
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      l_ussgl_option := NVL (fnd_profile.VALUE ('USSGL_OPTION'), 'N');

      IF (l_ussgl_option = 'Y')
      THEN
         IF (p_rcv_accttxn.event_type_id = encumbrance_reversal)
         THEN
            l_stmt_num := 10;

            SELECT ussgl_transaction_code
              INTO l_ussgl_tc
              FROM po_distributions
             WHERE po_distribution_id = p_rcv_accttxn.po_distribution_id;
         ELSIF (p_rcv_accttxn.event_type_id IN (deliver, return_to_receiving)
               )
         THEN
            l_stmt_num := 20;

            SELECT rsl.ussgl_transaction_code
              INTO l_ussgl_tc
              FROM rcv_transactions rt, rcv_shipment_lines rsl
             WHERE rt.transaction_id = p_rcv_accttxn.rcv_transaction_id
               AND rt.shipment_line_id = rsl.shipment_line_id;
         END IF;
      END IF;

      x_ussgl_tc := l_ussgl_tc;

      IF     g_debug = 'Y'
         AND fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         l_api_message := 'x_ussgl_tc : ' || x_ussgl_tc;
         fnd_log.STRING (fnd_log.level_statement,
                         g_log_head || '.' || l_api_name || '.' || l_stmt_num,
                         l_api_message
                        );
      END IF;

      --- Standard check of p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard Call to get message count and if count = 1, get message info
      fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                 p_data       => x_msg_data);

      IF     g_debug = 'Y'
         AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_log_head || '.' || l_api_name || '.end',
                         'Get_UssglTC >>'
                        );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO get_ussgltc_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO get_ussgltc_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN OTHERS
      THEN
         ROLLBACK TO get_ussgltc_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF     g_debug = 'Y'
            AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_log_head || '.' || l_api_name || l_stmt_num,
                               'Get_UssglTC : '
                            || l_stmt_num
                            || ' : '
                            || SUBSTR (SQLERRM, 1, 200)
                           );
         END IF;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name,
                                        l_api_name
                                     || 'Statement -'
                                     || TO_CHAR (l_stmt_num)
                                    );
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
   END get_ussgltc;

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
--                    p_rcv_ledger_id            IN      NUMBER  Required
--                    p_po_header_id          IN      NUMBER  Required
--
--                    x_encumbrance_flag      OUT     VARCHAR2(1)
--          x_ussgl_option    OUT     VARCHAR2(1)
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
--         be created.
--
-- End of comments
   PROCEDURE check_encumbranceflag (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false,
      p_commit             IN              VARCHAR2 := fnd_api.g_false,
      p_validation_level   IN              NUMBER
            := fnd_api.g_valid_level_full,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2,
      p_rcv_ledger_id      IN              NUMBER,
      x_encumbrance_flag   OUT NOCOPY      VARCHAR2,
      x_ussgl_option       OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_name      CONSTANT VARCHAR2 (30)   := 'Check_EncumbranceFlag';
      l_api_version   CONSTANT NUMBER          := 1.0;
      l_return_status          VARCHAR2 (1)    := fnd_api.g_ret_sts_success;
      l_msg_count              NUMBER          := 0;
      l_msg_data               VARCHAR2 (8000) := '';
      l_stmt_num               NUMBER          := 0;
      l_api_message            VARCHAR2 (1000);
      l_encumbrance_flag       VARCHAR2 (1);
   BEGIN
      -- Standard start of API savepoint
      SAVEPOINT check_encumbranceflag_pvt;
      l_stmt_num := 0;

      IF     g_debug = 'Y'
         AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_log_head || '.' || l_api_name || '.begin',
                         'Check_EncumbranceFlag <<'
                        );
      END IF;

      -- Standard call to check for call compatibility
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      l_stmt_num := 10;

      SELECT NVL (fsp.purch_encumbrance_flag, 'N')
        INTO l_encumbrance_flag
        FROM financials_system_parameters fsp
       WHERE fsp.set_of_books_id = p_rcv_ledger_id;

      x_encumbrance_flag := l_encumbrance_flag;
      x_ussgl_option := NVL (fnd_profile.VALUE ('USSGL_OPTION'), 'N');

      IF     g_debug = 'Y'
         AND fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         l_api_message :=
               'Encumbrance Flag : '
            || x_encumbrance_flag
            || ' Ussgl Option : '
            || x_ussgl_option;
         fnd_log.STRING (fnd_log.level_statement,
                         g_log_head || '.' || l_api_name || '.' || l_stmt_num,
                         l_api_message
                        );
      END IF;

      -- Standard check of p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard Call to get message count and if count = 1, get message info
      fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                 p_data       => x_msg_data);

      IF     g_debug = 'Y'
         AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_log_head || '.' || l_api_name || '.end',
                         'Check_EncumbranceFlag >>'
                        );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO check_encumbranceflag_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO check_encumbranceflag_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN OTHERS
      THEN
         ROLLBACK TO check_encumbranceflag_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF     g_debug = 'Y'
            AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_log_head || '.' || l_api_name || l_stmt_num,
                               'Check_EncumbranceFlag : '
                            || l_stmt_num
                            || ' : '
                            || SUBSTR (SQLERRM, 1, 200)
                           );
         END IF;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name,
                                        l_api_name
                                     || 'Statement -'
                                     || TO_CHAR (l_stmt_num)
                                    );
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
   END check_encumbranceflag;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Create_MMTRecord  This API takes an GRAT record along with the          --
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
--  P_rcv_accttxn        Represents a single GRAT, used to build the MMT entry--
--  P_TXN_TYPE_ID      Txn Type ID of the new MMT row being created        --
--  P_INTERCOMPANY_PRICE  The calling fcn must determine how to populate   --
--                     this based on the txn type and on the OU's position --
--                     in the txn flow. It will represent the transfer     --
--                     price between this OU and an adjacent one.          --
--  P_INTERCOMPANY_CURR_CODE This parameter represents the currency code   --
--           of the intercompany price.               --
--  P_ACCT_ID          Used to populate MMT.distribution_account_id        --
--  P_SIGN             Used to set the signs (+/-) of the primary quantity --
--                     and the transaction quantity                        --
--  P_PARENT_TXN_FLAG  1 - Indicates that this is the parent transaction   --
--  P_TRANSFER_ORGANIZATION_ID The calling function should pass the        --
--           organization from the next event.        --
--  X_INV_TRX          Returns the record that will be inserted into MMT   --
--                                                                         --
-- HISTORY:                                                                --
--    7/21/03     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------
   PROCEDURE create_mmtrecord (
      p_api_version                IN              NUMBER,
      p_init_msg_list              IN              VARCHAR2 := fnd_api.g_false,
      p_commit                     IN              VARCHAR2 := fnd_api.g_false,
      p_validation_level           IN              NUMBER
            := fnd_api.g_valid_level_full,
      x_return_status              OUT NOCOPY      VARCHAR2,
      x_msg_count                  OUT NOCOPY      NUMBER,
      x_msg_data                   OUT NOCOPY      VARCHAR2,
      p_rcv_accttxn                IN              gmf_rcv_accounting_pkg.rcv_accttxn_rec_type,
      p_txn_type_id                IN              NUMBER,
      p_intercompany_price         IN              NUMBER,
      p_intercompany_curr_code     IN              VARCHAR2,
      p_acct_id                    IN              NUMBER,
      p_sign                       IN              NUMBER,
      p_parent_txn_flag            IN              NUMBER,
      p_transfer_organization_id   IN              NUMBER,
      x_inv_trx                    OUT NOCOPY      inv_logical_transaction_global.mtl_trx_rec_type
   )
   IS
      l_api_name      CONSTANT VARCHAR2 (30)            := 'Create_MMTRecord';
      l_api_version   CONSTANT NUMBER                                  := 1.0;
      l_api_message            VARCHAR2 (1000);
      l_return_status          VARCHAR2 (1)      := fnd_api.g_ret_sts_success;
      l_msg_count              NUMBER                                    := 0;
      l_msg_data               VARCHAR2 (8000)                          := '';
      l_stmt_num               NUMBER                                    := 0;
      l_ctr                    BINARY_INTEGER;
      l_unit_price             NUMBER;
      l_inv_trx                inv_logical_transaction_global.mtl_trx_rec_type;
      l_le_id                  NUMBER;
                             -- holds legal entity ID for timezone conversion
      l_le_txn_date            DATE;
         -- transaction date truncated and converted to legal entity timezone
      invalid_txn_type         EXCEPTION;
   BEGIN
-- Standard start of API savepoint
      SAVEPOINT create_mmtrecord_pvt;

      IF     g_debug = 'Y'
         AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_log_head || '.' || l_api_name || '.begin',
                         'Create_MMTRecord <<'
                        );
      END IF;

-- Standard call to check for call compatibility
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

-- Initialize message list if p_init_msg_list is set to TRUE
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

-- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      x_msg_count := 0;
      x_msg_data := '';
-- API Body
      l_inv_trx.intercompany_pricing_option :=
                                     p_rcv_accttxn.intercompany_pricing_option;
      l_stmt_num := 5;

      -- Assign transaction action, source type, and invoiced flag
      IF (p_txn_type_id = 11)
      THEN
         l_inv_trx.transaction_action_id := 9;
         l_inv_trx.transaction_source_type_id := 13;
         l_inv_trx.invoiced_flag := 'N';
      ELSIF (p_txn_type_id = 14)
      THEN
         l_inv_trx.transaction_action_id := 14;
         l_inv_trx.transaction_source_type_id := 13;
         l_inv_trx.invoiced_flag := 'N';
      ELSIF (p_txn_type_id = 69)
      THEN
         l_inv_trx.transaction_action_id := 11;
         l_inv_trx.transaction_source_type_id := 1;

         IF (p_rcv_accttxn.procurement_org_flag = 'Y')
         THEN
            l_inv_trx.invoiced_flag := NULL;
            l_inv_trx.intercompany_pricing_option := 1;
         ELSE
            l_inv_trx.invoiced_flag := 'N';
         END IF;
      ELSIF (p_txn_type_id = 19)
      THEN
         l_inv_trx.transaction_action_id := 26;
         l_inv_trx.transaction_source_type_id := 1;
         l_inv_trx.invoiced_flag := NULL;
         l_inv_trx.intercompany_pricing_option := 1;
      ELSIF (p_txn_type_id = 22)
      THEN
         l_inv_trx.transaction_action_id := 10;
         l_inv_trx.transaction_source_type_id := 13;
         l_inv_trx.invoiced_flag := 'N';
      ELSIF (p_txn_type_id = 23)
      THEN
         l_inv_trx.transaction_action_id := 13;
         l_inv_trx.transaction_source_type_id := 13;
         l_inv_trx.invoiced_flag := 'N';
      ELSIF (p_txn_type_id = 39)
      THEN
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

      IF (p_txn_type_id IN (19, 39))
      THEN
         l_inv_trx.currency_code := p_rcv_accttxn.currency_code;
         l_inv_trx.currency_conversion_rate :=
                                       p_rcv_accttxn.currency_conversion_rate;
         l_inv_trx.currency_conversion_type :=
                                       p_rcv_accttxn.currency_conversion_type;
         l_inv_trx.currency_conversion_date := SYSDATE;
      ELSE
         l_inv_trx.currency_code := NULL;
         l_inv_trx.currency_conversion_rate := NULL;
         l_inv_trx.currency_conversion_type := NULL;
         l_inv_trx.currency_conversion_date := NULL;
      END IF;

      l_stmt_num := 30;

-- Compute unit price and intercompany price
      IF (p_rcv_accttxn.intercompany_pricing_option = 2)
      THEN
         l_unit_price :=
              p_rcv_accttxn.unit_price
            * p_rcv_accttxn.source_doc_quantity
            / p_rcv_accttxn.primary_quantity;
      ELSE
         l_unit_price :=
              (p_rcv_accttxn.unit_price + p_rcv_accttxn.unit_nr_tax
              )
            * p_rcv_accttxn.source_doc_quantity
            / p_rcv_accttxn.primary_quantity;
      END IF;

      l_stmt_num := 40;
      l_api_message := 'No data';

-- Main select statement to populate the l_inv_trx record
      SELECT p_rcv_accttxn.organization_id, p_rcv_accttxn.item_id,
             p_txn_type_id, rt.po_header_id,
             p_sign * ABS (p_rcv_accttxn.transaction_quantity),
             p_rcv_accttxn.trx_uom_code,
             p_sign * ABS (p_rcv_accttxn.primary_quantity),
             rt.transaction_date,
             DECODE (NVL (fc.minimum_accountable_unit, 0),
                     0, ROUND (l_unit_price * p_rcv_accttxn.primary_quantity,
                               fc.PRECISION
                              )
                      * p_rcv_accttxn.currency_conversion_rate
                      / p_rcv_accttxn.primary_quantity,
                       ROUND (  l_unit_price
                              * p_rcv_accttxn.primary_quantity
                              / fc.minimum_accountable_unit
                             )
                     * fc.minimum_accountable_unit
                     * p_rcv_accttxn.currency_conversion_rate
                     / p_rcv_accttxn.primary_quantity
                    ),
             'RCV', rt.transaction_id,
             rt.transaction_id,
             p_transfer_organization_id, NULL,
--pod.project_id,  remove these 2 because projects will cause failure in inv's create_logical_txns
             NULL,
--pod.task_id,     since they are only expected values in the org that does the deliver
                  poll.ship_to_location_id,
             1, p_rcv_accttxn.trx_flow_header_id,
             DECODE (NVL (fc.minimum_accountable_unit, 0),
                     0, ROUND (  p_intercompany_price
                               * p_rcv_accttxn.primary_quantity,
                               fc.PRECISION
                              )
                      / p_rcv_accttxn.primary_quantity,
                       ROUND (  p_intercompany_price
                              * p_rcv_accttxn.primary_quantity
                              / fc.minimum_accountable_unit
                             )
                     * fc.minimum_accountable_unit
                     / p_rcv_accttxn.primary_quantity
                    ),
             p_intercompany_curr_code,
             p_acct_id, 'N',
             NULL, NULL,
             p_parent_txn_flag, NULL
        INTO l_inv_trx.organization_id, l_inv_trx.inventory_item_id,
             l_inv_trx.transaction_type_id, l_inv_trx.transaction_source_id,
             l_inv_trx.transaction_quantity,
             l_inv_trx.transaction_uom,
             l_inv_trx.primary_quantity,
             l_inv_trx.transaction_date,
             l_inv_trx.transaction_cost,
             l_inv_trx.source_code, l_inv_trx.source_line_id,
             l_inv_trx.rcv_transaction_id,
             l_inv_trx.transfer_organization_id, l_inv_trx.project_id,
             l_inv_trx.task_id, l_inv_trx.ship_to_location_id,
             l_inv_trx.transaction_mode, l_inv_trx.trx_flow_header_id,
             l_inv_trx.intercompany_cost,
             l_inv_trx.intercompany_currency_code,
             l_inv_trx.distribution_account_id, l_inv_trx.costed_flag,
             l_inv_trx.subinventory_code, l_inv_trx.locator_id,
             l_inv_trx.parent_transaction_flag, l_inv_trx.trx_source_line_id
        FROM rcv_transactions rt,
             po_lines pol,
             po_line_locations poll,
             po_distributions pod,
             fnd_currencies fc
       WHERE rt.transaction_id = p_rcv_accttxn.rcv_transaction_id
         AND pol.po_line_id = p_rcv_accttxn.po_line_id
         AND poll.line_location_id = p_rcv_accttxn.po_line_location_id
         AND pod.po_distribution_id = p_rcv_accttxn.po_distribution_id
         AND fc.currency_code = p_rcv_accttxn.currency_code;

      l_stmt_num := 50;
      l_api_message := 'Inventory accounting period not open.';

      /* get the legal entity for timezone conversion */
      SELECT TO_NUMBER (org_information2)
        INTO l_le_id
        FROM hr_organization_information
       WHERE organization_id = p_rcv_accttxn.organization_id
         AND org_information_context = 'Accounting Information';

      l_stmt_num := 55;
      /* convert the transaction date into legal entity timezone (truncated) */
      l_le_txn_date :=
         inv_le_timezone_pub.get_le_day_for_server
                                                  (l_inv_trx.transaction_date,
                                                   l_le_id
                                                  );
      l_stmt_num := 60;

      /* retrieve the accounting period ID */
      SELECT acct_period_id
        INTO l_inv_trx.acct_period_id
        FROM org_acct_periods
       WHERE organization_id = p_rcv_accttxn.organization_id
         AND l_le_txn_date BETWEEN period_start_date AND schedule_close_date
         AND open_flag = 'Y';

      /* -- comment out this call for ST bug 3261222
      OE_DROP_SHIP_GRP.Get_Drop_Ship_Line_Ids(
           p_po_header_id     => p_rcv_accttxn.po_header_id,
           p_po_line_id       => p_rcv_accttxn.po_line_id,
           p_po_line_location_id    => p_rcv_accttxn.po_line_location_id,
           p_po_release_id    => l_po_release_id,
           x_line_id       => l_inv_trx.trx_source_line_id,
           x_num_lines     => l_so_num_lines,
           x_header_id     => l_so_header_id,
           x_org_id        => l_so_org_id);
      */
      x_inv_trx := l_inv_trx;

-- ***************

      -- Standard check of p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

-- Standard Call to get message count and if count = 1, get message info
      fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                 p_data       => x_msg_data);

      IF     g_debug = 'Y'
         AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_log_head || '.' || l_api_name || '.end',
                         'Create_MMTRecord >>'
                        );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO create_mmtrecord_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_mmtrecord_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         l_api_message :=
                     'Unexpected error at statement ' || TO_CHAR (l_stmt_num);

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name,
                                     l_api_name || ': ' || l_api_message
                                    );
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN invalid_txn_type
      THEN
         ROLLBACK TO create_mmtrecord_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         l_api_message :=
               'Unexpected transaction type passed in: '
            || TO_CHAR (p_txn_type_id);

         IF     g_debug = 'Y'
            AND fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_log_head || l_api_name || '.' || l_stmt_num,
                            l_api_message
                           );
         END IF;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name,
                                     l_api_name || ': ' || l_api_message
                                    );
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN NO_DATA_FOUND
      THEN
         ROLLBACK TO create_mmtrecord_pvt;
         x_return_status := fnd_api.g_ret_sts_error;

         IF     g_debug = 'Y'
            AND fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_log_head || '.' || l_api_name || '.'
                            || l_stmt_num,
                            l_api_message
                           );
         END IF;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name || l_api_message);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN OTHERS
      THEN
         ROLLBACK TO create_mmtrecord_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         l_api_message :=
                        TO_CHAR (SQLCODE) || '- '
                        || SUBSTRB (SQLERRM, 1, 100);

         IF     g_debug = 'Y'
            AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_log_head || '.' || l_api_name || '.'
                            || l_stmt_num,
                               'Create_MMTRecord : '
                            || l_stmt_num
                            || ' : '
                            || SUBSTR (SQLERRM, 1, 200)
                           );
         END IF;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name,
                                        l_api_name
                                     || '('
                                     || TO_CHAR (l_stmt_num)
                                     || ') - '
                                     || l_api_message
                                    );
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
   END create_mmtrecord;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Insert_MMT  This API takes a PL/SQL table as input that has one        --
--                    entry for each GRAT event. It loops through the table--
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
--  P_rcv_accttxnS_TBL   Collection of transactions of type rcv_accttxn_rec_type     --
--  X_RETURN_STATUS    Success/Error/Unexplained error - 'S','E', or 'U'   --
--  X_MSG_COUNT        Message Count - # of messages placed in message list--
--  X_MSG_DATA         Message Text - returns msg contents if msg_count = 1--
--                                                                         --
-- HISTORY:                                                                --
--    06/26/03     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------
   PROCEDURE insert_mmt (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false,
      p_commit             IN              VARCHAR2 := fnd_api.g_false,
      p_validation_level   IN              NUMBER
            := fnd_api.g_valid_level_full,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2,
      p_rcv_accttxn_tbl    IN              gmf_rcv_accounting_pkg.rcv_accttxn_tbl_type
   )
   IS
      l_api_name          CONSTANT VARCHAR2 (30)              := 'Insert_MMT';
      l_api_version       CONSTANT NUMBER                              := 1.0;
      l_api_message                VARCHAR2 (1000);
      l_return_status              VARCHAR2 (1)  := fnd_api.g_ret_sts_success;
      l_msg_count                  NUMBER                                := 0;
      l_msg_data                   VARCHAR2 (8000)                      := '';
      l_stmt_num                   NUMBER                                := 0;
      l_ctr                        BINARY_INTEGER;
      l_inv_trx_tbl                inv_logical_transaction_global.mtl_trx_tbl_type;
      l_inv_trx_tbl_ctr            BINARY_INTEGER;
      l_correct_ind                BOOLEAN                           := FALSE;
                                      -- indicator variable for whether these
      -- transactions are for a correction or not
      l_rcv_txn_type               rcv_transactions.transaction_type%TYPE;
      l_parent_txn_flag            NUMBER                                := 1;
      l_intercompany_price         NUMBER;
                        -- may include nr tax depending on the pricing option
      l_intercompany_curr_code     gmf_rcv_accounting_txns.currency_code%TYPE;
      l_transfer_organization_id   NUMBER                             := NULL;
      l_rcv_accttxn                gmf_rcv_accounting_pkg.rcv_accttxn_rec_type;
      invalid_event                EXCEPTION;
   BEGIN
-- Standard start of API savepoint
      SAVEPOINT insert_mmt_pvt;
      l_stmt_num := 0;

      IF     g_debug = 'Y'
         AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_log_head || l_api_name || '.begin',
                         'Insert_MMT <<'
                        );
      END IF;

-- Standard call to check for call compatibility
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

-- Initialize message list if p_init_msg_list is set to TRUE
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

-- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      x_msg_count := 0;
      x_msg_data := '';
-- API Body
-- Initialize counters
      l_inv_trx_tbl_ctr := 0;
      l_ctr := p_rcv_accttxn_tbl.FIRST;
      l_stmt_num := 10;

-- Determine if this group of transactions are for a CORRECT txn type
      SELECT transaction_type
        INTO l_rcv_txn_type
        FROM rcv_transactions
       WHERE transaction_id = p_rcv_accttxn_tbl (l_ctr).rcv_transaction_id;

      IF (l_rcv_txn_type = 'CORRECT')
      THEN
         l_correct_ind := TRUE;
      END IF;

-- Loop for every event in the table
      WHILE l_ctr <= p_rcv_accttxn_tbl.LAST
      LOOP
         -- Logical transactions are only seeded in Receiving but not in Inventory for :
         -- 1. Expense destination types for one-time items
         -- 2. Shop Floor destination types (for both OSP and direct items).
         IF (    p_rcv_accttxn_tbl (l_ctr).destination_type_code <>
                                                                  'SHOP FLOOR'
             AND (   p_rcv_accttxn_tbl (l_ctr).destination_type_code <>
                                                                     'EXPENSE'
                  OR p_rcv_accttxn_tbl (l_ctr).item_id IS NOT NULL
                 )
            )
         THEN
            IF (p_rcv_accttxn_tbl (l_ctr).ship_to_org_flag = 'N')
            THEN
               -- For GRAT events, the transfer_organization_id represents the organization from
               -- where the transfer price is derived. Hence in the flow :
               -- OU2 <-------- OU1 <--------- Supplier
               -- The Logical Receive in OU1 will be at PO price and the transfer_org will be NULL.
               -- The Recieve in OU2 could be at transfer price between OU1 and OU2. Hence trasnfer
               -- org will be OU1.
               -- However, in Inventory the Logical Receive in GRAT translates to a Logical PO Receipt
               -- and a Logical I/C Sales Issue. The Logical I/C Sales event could be at transfer price.
               -- The transfer organization should therefore be picked up from the next event. To keep
               -- the values for the Logical PO Receipt and the Logical I/C Sales issue consistent, we
               -- will follow this logic for both transactions.
               l_transfer_organization_id :=
                  p_rcv_accttxn_tbl (p_rcv_accttxn_tbl.NEXT (l_ctr)).organization_id;

               IF (p_rcv_accttxn_tbl (l_ctr).event_type_id = logical_receive
                  )
               THEN
                  l_inv_trx_tbl_ctr := l_inv_trx_tbl_ctr + 1;

                  IF (p_rcv_accttxn_tbl (l_ctr).intercompany_pricing_option =
                                                                             2
                     )
                  THEN
                     l_intercompany_price :=
                                 p_rcv_accttxn_tbl (l_ctr).intercompany_price;
                     l_intercompany_curr_code :=
                             p_rcv_accttxn_tbl (l_ctr).intercompany_curr_code;
                  ELSE
                     l_intercompany_price :=
                          p_rcv_accttxn_tbl (l_ctr).unit_price
                        + p_rcv_accttxn_tbl (l_ctr).unit_nr_tax;
                     l_intercompany_curr_code :=
                                       p_rcv_accttxn_tbl (l_ctr).currency_code;
                  END IF;

                  IF (l_correct_ind)
                  THEN
                     l_stmt_num := 20;
                     create_mmtrecord
                        (p_api_version                   => 1.0,
                         p_rcv_accttxn                   => p_rcv_accttxn_tbl
                                                                        (l_ctr),
                         p_txn_type_id                   => 69,
                         p_intercompany_price            => l_intercompany_price,
                         p_intercompany_curr_code        => l_intercompany_curr_code,
                         p_acct_id                       => p_rcv_accttxn_tbl
                                                                        (l_ctr).debit_account_id,
                         p_sign                          => SIGN
                                                               (p_rcv_accttxn_tbl
                                                                        (l_ctr).transaction_quantity
                                                               ),
                         p_parent_txn_flag               => l_parent_txn_flag,
                         p_transfer_organization_id      => l_transfer_organization_id,
                         x_return_status                 => l_return_status,
                         x_msg_count                     => l_msg_count,
                         x_msg_data                      => l_msg_data,
                         x_inv_trx                       => l_inv_trx_tbl
                                                               (l_inv_trx_tbl_ctr
                                                               )
                        );
                  ELSIF (p_rcv_accttxn_tbl (l_ctr).procurement_org_flag = 'Y'
                        )
                  THEN
                     l_stmt_num := 30;
                     create_mmtrecord
                        (p_api_version                   => 1.0,
                         p_rcv_accttxn                   => p_rcv_accttxn_tbl
                                                                        (l_ctr),
                         p_txn_type_id                   => 19,
                                                         -- Logical PO Receipt
                         p_intercompany_price            => l_intercompany_price,
                         p_intercompany_curr_code        => l_intercompany_curr_code,
                         p_acct_id                       => p_rcv_accttxn_tbl
                                                                        (l_ctr).debit_account_id,
                         p_sign                          => 1,
                         p_parent_txn_flag               => l_parent_txn_flag,
                         p_transfer_organization_id      => l_transfer_organization_id,
                         x_return_status                 => l_return_status,
                         x_msg_count                     => l_msg_count,
                         x_msg_data                      => l_msg_data,
                         x_inv_trx                       => l_inv_trx_tbl
                                                               (l_inv_trx_tbl_ctr
                                                               )
                        );
                  ELSE
                     l_stmt_num := 40;
                     create_mmtrecord
                        (p_api_version                   => 1.0,
                         p_rcv_accttxn                   => p_rcv_accttxn_tbl
                                                                        (l_ctr),
                         p_txn_type_id                   => 22,
                                            -- Logical I/C Procurement Receipt
                         p_intercompany_price            => l_intercompany_price,
                         p_intercompany_curr_code        => l_intercompany_curr_code,
                         p_acct_id                       => p_rcv_accttxn_tbl
                                                                        (l_ctr).debit_account_id,
                         p_sign                          => 1,
                         p_parent_txn_flag               => l_parent_txn_flag,
                         p_transfer_organization_id      => l_transfer_organization_id,
                         x_return_status                 => l_return_status,
                         x_msg_count                     => l_msg_count,
                         x_msg_data                      => l_msg_data,
                         x_inv_trx                       => l_inv_trx_tbl
                                                               (l_inv_trx_tbl_ctr
                                                               )
                        );
                  END IF;

                  IF (l_return_status <> fnd_api.g_ret_sts_success)
                  THEN
                     RAISE fnd_api.g_exc_error;
                  END IF;

                  l_stmt_num := 50;
                  l_inv_trx_tbl_ctr := l_inv_trx_tbl_ctr + 1;

                  IF (p_rcv_accttxn_tbl (p_rcv_accttxn_tbl.NEXT (l_ctr)).intercompany_pricing_option =
                                                                             2
                     )
                  THEN
                     l_intercompany_price :=
                        p_rcv_accttxn_tbl (p_rcv_accttxn_tbl.NEXT (l_ctr)).intercompany_price;
                     l_intercompany_curr_code :=
                        p_rcv_accttxn_tbl (p_rcv_accttxn_tbl.NEXT (l_ctr)).intercompany_curr_code;
                  ELSE
                     l_intercompany_price :=
                          p_rcv_accttxn_tbl (p_rcv_accttxn_tbl.NEXT (l_ctr)).unit_price
                        + p_rcv_accttxn_tbl (p_rcv_accttxn_tbl.NEXT (l_ctr)).unit_nr_tax;
                     l_intercompany_curr_code :=
                        p_rcv_accttxn_tbl (p_rcv_accttxn_tbl.NEXT (l_ctr)).currency_code;
                  END IF;

                  IF (p_rcv_accttxn_tbl (l_ctr).transaction_quantity > 0)
                  THEN
                     l_stmt_num := 60;
                     create_mmtrecord
                        (p_api_version                   => 1.0,
                         p_rcv_accttxn                   => p_rcv_accttxn_tbl
                                                                        (l_ctr),
                         p_txn_type_id                   => 11,
                                                    -- Logical I/C Sales Issue
                         p_intercompany_price            => l_intercompany_price,
                         p_intercompany_curr_code        => l_intercompany_curr_code,
                         p_acct_id                       => p_rcv_accttxn_tbl
                                                                        (l_ctr).intercompany_cogs_account_id,
                         p_sign                          => -1,
                         p_parent_txn_flag               => 0,
                         p_transfer_organization_id      => l_transfer_organization_id,
                         x_return_status                 => l_return_status,
                         x_msg_count                     => l_msg_count,
                         x_msg_data                      => l_msg_data,
                         x_inv_trx                       => l_inv_trx_tbl
                                                               (l_inv_trx_tbl_ctr
                                                               )
                        );
                  ELSE
                     l_stmt_num := 70;
                     l_rcv_accttxn := p_rcv_accttxn_tbl (l_ctr);
                     create_mmtrecord
                        (p_api_version                   => 1.0,
                         p_rcv_accttxn                   => p_rcv_accttxn_tbl
                                                                        (l_ctr),
                         p_txn_type_id                   => 14,
                                                   -- Logical I/C Sales Return
                         p_intercompany_price            => l_intercompany_price,
                         p_intercompany_curr_code        => l_intercompany_curr_code,
                         p_acct_id                       => p_rcv_accttxn_tbl
                                                                        (l_ctr).intercompany_cogs_account_id,
                         p_sign                          => 1,
                         p_parent_txn_flag               => 0,
                         p_transfer_organization_id      => l_transfer_organization_id,
                         x_return_status                 => l_return_status,
                         x_msg_count                     => l_msg_count,
                         x_msg_data                      => l_msg_data,
                         x_inv_trx                       => l_inv_trx_tbl
                                                               (l_inv_trx_tbl_ctr
                                                               )
                        );
                  END IF;

                  IF (l_return_status <> fnd_api.g_ret_sts_success)
                  THEN
                     RAISE fnd_api.g_exc_error;
                  END IF;
               ELSIF (p_rcv_accttxn_tbl (l_ctr).event_type_id =
                                                      logical_return_to_vendor
                     )
               THEN
                  l_stmt_num := 80;
                  l_inv_trx_tbl_ctr := l_inv_trx_tbl_ctr + 1;

                  IF (p_rcv_accttxn_tbl (l_ctr).intercompany_pricing_option =
                                                                             2
                     )
                  THEN
                     l_intercompany_price :=
                                         p_rcv_accttxn_tbl (l_ctr).unit_price;
                     l_intercompany_curr_code :=
                             p_rcv_accttxn_tbl (l_ctr).intercompany_curr_code;
                  ELSE
                     l_intercompany_price :=
                          p_rcv_accttxn_tbl (l_ctr).unit_price
                        + p_rcv_accttxn_tbl (l_ctr).unit_nr_tax;
                     l_intercompany_curr_code :=
                                       p_rcv_accttxn_tbl (l_ctr).currency_code;
                  END IF;

                  IF (l_correct_ind)
                  THEN
                     l_stmt_num := 90;
                     l_rcv_accttxn := p_rcv_accttxn_tbl (l_ctr);
                     create_mmtrecord
                        (p_api_version                   => 1.0,
                         p_rcv_accttxn                   => p_rcv_accttxn_tbl
                                                                        (l_ctr),
                         p_txn_type_id                   => 69,
                         p_intercompany_price            => l_intercompany_price,
                         p_intercompany_curr_code        => l_intercompany_curr_code,
                         p_acct_id                       => p_rcv_accttxn_tbl
                                                                        (l_ctr).credit_account_id,
                         p_sign                          =>   -1
                                                            * SIGN
                                                                 (p_rcv_accttxn_tbl
                                                                        (l_ctr).transaction_quantity
                                                                 ),
                         p_parent_txn_flag               => l_parent_txn_flag,
                         p_transfer_organization_id      => l_transfer_organization_id,
                         x_return_status                 => l_return_status,
                         x_msg_count                     => l_msg_count,
                         x_msg_data                      => l_msg_data,
                         x_inv_trx                       => l_inv_trx_tbl
                                                               (l_inv_trx_tbl_ctr
                                                               )
                        );
                  ELSIF (p_rcv_accttxn_tbl (l_ctr).procurement_org_flag = 'Y'
                        )
                  THEN
                     l_stmt_num := 100;
                     l_rcv_accttxn := p_rcv_accttxn_tbl (l_ctr);
                     create_mmtrecord
                        (p_api_version                   => 1.0,
                         p_rcv_accttxn                   => p_rcv_accttxn_tbl
                                                                        (l_ctr),
                         p_txn_type_id                   => 39, -- Logical RTV
                         p_intercompany_price            => l_intercompany_price,
                         p_intercompany_curr_code        => l_intercompany_curr_code,
                         p_acct_id                       => p_rcv_accttxn_tbl
                                                                        (l_ctr).credit_account_id,
                         p_sign                          => -1,
                         p_parent_txn_flag               => l_parent_txn_flag,
                         p_transfer_organization_id      => l_transfer_organization_id,
                         x_return_status                 => l_return_status,
                         x_msg_count                     => l_msg_count,
                         x_msg_data                      => l_msg_data,
                         x_inv_trx                       => l_inv_trx_tbl
                                                               (l_inv_trx_tbl_ctr
                                                               )
                        );
                  ELSE
                     l_stmt_num := 110;
                     l_rcv_accttxn := p_rcv_accttxn_tbl (l_ctr);
                     create_mmtrecord
                        (p_api_version                   => 1.0,
                         p_rcv_accttxn                   => p_rcv_accttxn_tbl
                                                                        (l_ctr),
                         p_txn_type_id                   => 23,
                                             -- Logical I/C Procurement Return
                         p_intercompany_price            => l_intercompany_price,
                         p_intercompany_curr_code        => l_intercompany_curr_code,
                         p_acct_id                       => p_rcv_accttxn_tbl
                                                                        (l_ctr).credit_account_id,
                         p_sign                          => -1,
                         p_parent_txn_flag               => l_parent_txn_flag,
                         p_transfer_organization_id      => l_transfer_organization_id,
                         x_return_status                 => l_return_status,
                         x_msg_count                     => l_msg_count,
                         x_msg_data                      => l_msg_data,
                         x_inv_trx                       => l_inv_trx_tbl
                                                               (l_inv_trx_tbl_ctr
                                                               )
                        );
                  END IF;

                  IF (l_return_status <> fnd_api.g_ret_sts_success)
                  THEN
                     RAISE fnd_api.g_exc_error;
                  END IF;

                  l_stmt_num := 120;
                  l_inv_trx_tbl_ctr := l_inv_trx_tbl_ctr + 1;

                  IF (p_rcv_accttxn_tbl (p_rcv_accttxn_tbl.NEXT (l_ctr)).intercompany_pricing_option =
                                                                             2
                     )
                  THEN
                     l_intercompany_price :=
                        p_rcv_accttxn_tbl (p_rcv_accttxn_tbl.NEXT (l_ctr)).unit_price;
                     l_intercompany_curr_code :=
                        p_rcv_accttxn_tbl (p_rcv_accttxn_tbl.NEXT (l_ctr)).intercompany_curr_code;
                  ELSE
                     l_intercompany_price :=
                          p_rcv_accttxn_tbl (p_rcv_accttxn_tbl.NEXT (l_ctr)).unit_price
                        + p_rcv_accttxn_tbl (p_rcv_accttxn_tbl.NEXT (l_ctr)).unit_nr_tax;
                     l_intercompany_curr_code :=
                        p_rcv_accttxn_tbl (p_rcv_accttxn_tbl.NEXT (l_ctr)).currency_code;
                  END IF;

                  IF (p_rcv_accttxn_tbl (l_ctr).transaction_quantity > 0)
                  THEN
                     l_stmt_num := 130;
                     l_rcv_accttxn := p_rcv_accttxn_tbl (l_ctr);
                     create_mmtrecord
                        (p_api_version                   => 1.0,
                         p_rcv_accttxn                   => p_rcv_accttxn_tbl
                                                                        (l_ctr),
                         p_txn_type_id                   => 14,
                                                   -- Logical I/C Sales Return
                         p_intercompany_price            => l_intercompany_price,
                         p_intercompany_curr_code        => l_intercompany_curr_code,
                         p_acct_id                       => p_rcv_accttxn_tbl
                                                                        (l_ctr).intercompany_cogs_account_id,
                         p_sign                          => 1,
                         p_parent_txn_flag               => 0,
                         p_transfer_organization_id      => l_transfer_organization_id,
                         x_return_status                 => l_return_status,
                         x_msg_count                     => l_msg_count,
                         x_msg_data                      => l_msg_data,
                         x_inv_trx                       => l_inv_trx_tbl
                                                               (l_inv_trx_tbl_ctr
                                                               )
                        );
                  ELSE
                     l_stmt_num := 140;
                     l_rcv_accttxn := p_rcv_accttxn_tbl (l_ctr);
                     create_mmtrecord
                        (p_api_version                   => 1.0,
                         p_rcv_accttxn                   => p_rcv_accttxn_tbl
                                                                        (l_ctr),
                         p_txn_type_id                   => 11,
                                                    -- Logical I/C Sales Issue
                         p_intercompany_price            => l_intercompany_price,
                         p_intercompany_curr_code        => l_intercompany_curr_code,
                         p_acct_id                       => p_rcv_accttxn_tbl
                                                                        (l_ctr).intercompany_cogs_account_id,
                         p_sign                          => -1,
                         p_parent_txn_flag               => 0,
                         p_transfer_organization_id      => l_transfer_organization_id,
                         x_return_status                 => l_return_status,
                         x_msg_count                     => l_msg_count,
                         x_msg_data                      => l_msg_data,
                         x_inv_trx                       => l_inv_trx_tbl
                                                               (l_inv_trx_tbl_ctr
                                                               )
                        );
                  END IF;

                  IF (l_return_status <> fnd_api.g_ret_sts_success)
                  THEN
                     RAISE fnd_api.g_exc_error;
                  END IF;
               ELSE
                  RAISE invalid_event;
               -- catch error: should never get anything but Log rcpt or Log RTV
               END IF;

               l_parent_txn_flag := 0;
              -- the first transaction inserted will be the parent, all others
              -- will be children so their flags are 0
            END IF;
         END IF;

         l_ctr := p_rcv_accttxn_tbl.NEXT (l_ctr);
      END LOOP;

      IF     g_debug = 'Y'
         AND fnd_log.level_event >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_log_head || '.' || l_api_name || '.' || l_stmt_num,
                         'Creating Logical Transactions in MMT'
                        );
      END IF;

      l_stmt_num := 150;
      inv_logical_transactions_pub.create_logical_transactions
         (x_return_status                   => l_return_status,
          x_msg_count                       => l_msg_count,
          x_msg_data                        => l_msg_data,
          p_api_version_number              => 1.0,
          p_mtl_trx_tbl                     => l_inv_trx_tbl,
          p_trx_flow_header_id              => p_rcv_accttxn_tbl
                                                      (p_rcv_accttxn_tbl.FIRST).trx_flow_header_id,
          p_defer_logical_transactions      => 2,
          p_logical_trx_type_code           => 3,
          p_exploded_flag                   => 1
         );

      IF (l_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

-- End API Body

      -- Standard check of p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      IF     g_debug = 'Y'
         AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_log_head || l_api_name || '.end',
                         'Insert_MMT >>'
                        );
      END IF;
   EXCEPTION
      WHEN invalid_event
      THEN
         ROLLBACK TO insert_mmt_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         l_api_message :=
               'Unexpected event in element '
            || TO_CHAR (l_ctr)
            || ' of input parameter p_rcv_accttxn_tbl';

         IF     g_debug = 'Y'
            AND fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_log_head || l_api_name || '.' || l_stmt_num,
                            l_api_message
                           );
         END IF;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name,
                                     l_api_name || ': ' || l_api_message
                                    );
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO insert_mmt_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         l_api_message := 'Call to procedure failed';

         IF     g_debug = 'Y'
            AND fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_log_head || l_api_name || '.' || l_stmt_num,
                            l_api_message
                           );
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO insert_mmt_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         l_api_message :=
             'Wrong version #, expecting version ' || TO_CHAR (l_api_version);

         IF     g_debug = 'Y'
            AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_log_head || l_api_name || '.' || l_stmt_num,
                            l_api_message
                           );
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN OTHERS
      THEN
         ROLLBACK TO insert_mmt_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         l_api_message :=
               'Unexpected Error: '
            || l_stmt_num
            || ': '
            || TO_CHAR (SQLCODE)
            || '- '
            || SUBSTRB (SQLERRM, 1, 100);

         IF     g_debug = 'Y'
            AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_log_head || l_api_name || '.' || l_stmt_num,
                            l_api_message
                           );
         END IF;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name,
                                     l_api_name || ': ' || l_api_message
                                    );
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
   END insert_mmt;

/** =========================================
* Adapted from Seed_RAEEvents
** ========================================== **/
   PROCEDURE insert_txn (
      p_api_version                    IN              NUMBER := 1.0,
      p_init_msg_list                  IN              VARCHAR2
            := fnd_api.g_false,
      p_commit                         IN              VARCHAR2
            := fnd_api.g_false,
      p_validation_level               IN              NUMBER
            := fnd_api.g_valid_level_full,
      x_return_status                  OUT NOCOPY      VARCHAR2,
      x_msg_count                      OUT NOCOPY      NUMBER,
      x_msg_data                       OUT NOCOPY      VARCHAR2,
      p_event_source                   IN              VARCHAR2,
      p_event_type_id                  IN              NUMBER,
      p_rcv_transaction_id             IN              NUMBER,
      p_inv_distribution_id            IN              NUMBER,
      p_po_distribution_id             IN              NUMBER,
      p_direct_delivery_flag           IN              VARCHAR2,
      p_gl_group_id                    IN              NUMBER,
      p_cross_ou_flag                  IN              VARCHAR2,
      p_procurement_org_flag           IN              VARCHAR2,
      p_ship_to_org_flag               IN              VARCHAR2,
      p_drop_ship_flag                 IN              NUMBER,
      p_org_id                         IN              NUMBER,
      p_organization_id                IN              NUMBER,
      p_transfer_org_id                IN              NUMBER,
      p_transfer_organization_id       IN              NUMBER,
      p_trx_flow_header_id             IN              NUMBER,
      p_transaction_forward_flow_rec                   inv_transaction_flow_pub.mtl_transaction_flow_rec_type,
      p_transaction_reverse_flow_rec                   inv_transaction_flow_pub.mtl_transaction_flow_rec_type,
      p_unit_price                     IN              NUMBER,
      p_prior_unit_price               IN              NUMBER,
      x_rcv_accttxn                    OUT NOCOPY      gmf_rcv_accounting_pkg.rcv_accttxn_rec_type
   )
   IS
      c_log_module        CONSTANT VARCHAR2 (30)              := 'Insert_Txn';
      l_api_version       CONSTANT NUMBER                              := 1.0;
      l_return_status              VARCHAR2 (1)  := fnd_api.g_ret_sts_success;
      l_msg_count                  NUMBER                                := 0;
      l_msg_data                   VARCHAR2 (8000)                      := '';
      l_stmt_num                   NUMBER                                := 0;
      l_api_message                VARCHAR2 (1000);
      l_api_name          CONSTANT VARCHAR2 (30)              := 'Insert_Txn';
      l_rcv_accttxn                gmf_rcv_accounting_pkg.rcv_accttxn_rec_type;
      l_transaction_amount         NUMBER                                := 0;
      l_source_doc_quantity        NUMBER                                := 0;
      l_transaction_quantity       NUMBER                                := 0;
      l_ic_pricing_option          NUMBER                                := 1;
      l_unit_price                 NUMBER                                := 0;
      l_unit_nr_tax                NUMBER                                := 0;
      l_unit_rec_tax               NUMBER                                := 0;
      l_prior_nr_tax               NUMBER                                := 0;
      l_prior_rec_tax              NUMBER                                := 0;
      l_currency_code              VARCHAR2 (15);
      l_currency_conversion_rate   NUMBER;
      l_currency_conversion_date   DATE;
      l_currency_conversion_type   VARCHAR2 (30);
      l_incr_transfer_price        NUMBER                                := 0;
      l_incr_currency_code         VARCHAR2 (15)                      := NULL;
      l_dest_org_id                NUMBER;
      l_trx_uom_code               mtl_units_of_measure.uom_code%TYPE;
      l_primary_uom                mtl_units_of_measure.unit_of_measure%TYPE;
      l_primary_qty                NUMBER;
      l_credit_acct_id             NUMBER;
      l_debit_acct_id              NUMBER;
      l_ic_cogs_acct_id            NUMBER;
      l_ussgl_tc                   VARCHAR2 (30);
      l_asset_option               NUMBER;
      l_expense_option             NUMBER;
      l_detail_accounting_flag     VARCHAR2 (1);
      l_gl_installed               BOOLEAN                           := FALSE;
      l_status                     VARCHAR2 (1);
      l_industry                   VARCHAR2 (1);
      l_oracle_schema              VARCHAR2 (30);
      l_encumbrance_flag           VARCHAR2 (1);
      l_ussgl_option               VARCHAR2 (1);
   BEGIN
      -- Standard start of API savepoint
      SAVEPOINT insert_txn_pvt;
      l_stmt_num := 0;

      IF     g_debug = 'Y'
         AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_log_head || '.' || l_api_name || '.begin',
                         'Insert_Txn <<'
                        );
      END IF;

      -- Standard call to check for call compatibility
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      IF     g_debug = 'Y'
         AND fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         l_api_message :=
               'Insert_Txn : PARAMETERS 1:'
            || ' p_event_source : '
            || p_event_source
            || ' p_event_type_id : '
            || p_event_type_id
            || ' p_rcv_transaction_id : '
            || p_rcv_transaction_id
            || ' p_inv_distribution_id : '
            || p_inv_distribution_id
            || ' p_po_distribution_id : '
            || p_po_distribution_id
            || ' p_direct_delivery_flag : '
            || p_direct_delivery_flag
            || ' p_gl_group_id : '
            || p_gl_group_id
            || ' p_cross_ou_flag : '
            || p_cross_ou_flag;
         fnd_log.STRING (fnd_log.level_statement,
                         g_log_head || '.' || l_api_name || '.' || l_stmt_num,
                         l_api_message
                        );
         l_api_message :=
               'Insert_Txn : PARAMETERS 2:'
            || ' p_procurement_org_flag : '
            || p_procurement_org_flag
            || ' p_ship_to_org_flag : '
            || p_ship_to_org_flag
            || ' p_drop_ship_flag : '
            || p_drop_ship_flag
            || ' p_org_id : '
            || p_org_id
            || ' p_organization_id : '
            || p_organization_id
            || ' p_transfer_org_id : '
            || p_transfer_org_id
            || ' p_transfer_organization_id : '
            || p_transfer_organization_id
            || ' p_trx_flow_header_id : '
            || p_trx_flow_header_id
            || ' p_unit_price : '
            || p_unit_price
            || ' p_prior_unit_price : '
            || p_prior_unit_price;
         fnd_log.STRING (fnd_log.level_statement,
                         g_log_head || '.' || l_api_name || '.' || l_stmt_num,
                         l_api_message
                        );
      END IF;

      l_stmt_num := 15;
      l_rcv_accttxn.event_source := p_event_source;
      l_rcv_accttxn.event_type_id := p_event_type_id;
      l_rcv_accttxn.rcv_transaction_id := p_rcv_transaction_id;
      l_rcv_accttxn.cross_ou_flag := p_cross_ou_flag;
      l_rcv_accttxn.procurement_org_flag := p_procurement_org_flag;
      l_rcv_accttxn.ship_to_org_flag := p_ship_to_org_flag;
      l_rcv_accttxn.drop_ship_flag := p_drop_ship_flag;
      l_rcv_accttxn.po_distribution_id := p_po_distribution_id;
      l_rcv_accttxn.direct_delivery_flag := p_direct_delivery_flag;

      -- Initialize PO Information
      IF (p_event_source = 'INVOICEMATCH')
      THEN
         -- This source is only for period end accruals, one-time items
         IF     g_debug = 'Y'
            AND fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_log_head || '.' || l_api_name || '.'
                            || l_stmt_num,
                            'Getting PO information from Invoice'
                           );
         END IF;

         l_stmt_num := 20;

         SELECT pod.po_header_id, pol.po_line_id,
                pod.po_distribution_id,
                pod.destination_type_code,
                poll.line_location_id,
                SYSDATE, pol.item_id,
                apid.quantity_invoiced,
                poll.unit_meas_lookup_code, poh.currency_code
           INTO l_rcv_accttxn.po_header_id, l_rcv_accttxn.po_line_id,
                l_rcv_accttxn.po_distribution_id,
                l_rcv_accttxn.destination_type_code,
                l_rcv_accttxn.po_line_location_id,
                l_rcv_accttxn.transaction_date, l_rcv_accttxn.item_id,
                l_rcv_accttxn.source_doc_quantity,
                l_rcv_accttxn.source_doc_uom, l_rcv_accttxn.currency_code
           FROM ap_invoice_distributions apid,
                po_distributions pod,
                po_line_locations poll,
                po_lines pol,
                po_headers poh
          WHERE apid.invoice_distribution_id = p_inv_distribution_id
            AND pod.po_distribution_id = apid.po_distribution_id
            AND pod.line_location_id = poll.line_location_id
            AND pol.po_line_id = poll.po_line_id
            AND poh.po_header_id = pod.po_header_id;

         l_rcv_accttxn.inv_distribution_id := p_inv_distribution_id;
         l_rcv_accttxn.transaction_quantity :=
                                             l_rcv_accttxn.source_doc_quantity;
         l_rcv_accttxn.transaction_uom := l_rcv_accttxn.source_doc_uom;
      ELSE
         l_stmt_num := 30;

         IF     g_debug = 'Y'
            AND fnd_log.level_event >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING
                         (fnd_log.level_event,
                          g_log_head || '.' || l_api_name || '.' || l_stmt_num,
                          'Getting PO information from Receiving Transaction'
                         );
         END IF;

         SELECT rt.po_header_id, rt.po_line_id,
                rt.po_line_location_id,
                rt.transaction_date, pol.item_id,
                poll.ship_to_organization_id, rt.unit_of_measure,
                rt.source_doc_unit_of_measure, poh.currency_code,
                pod.destination_type_code,
                /* start LCM-OPM Integration  */
                rt.unit_landed_cost
                /* end LCM-OPM Integration  */
           INTO l_rcv_accttxn.po_header_id, l_rcv_accttxn.po_line_id,
                l_rcv_accttxn.po_line_location_id,
                l_rcv_accttxn.transaction_date, l_rcv_accttxn.item_id,
                l_dest_org_id, l_rcv_accttxn.transaction_uom,
                l_rcv_accttxn.source_doc_uom, l_rcv_accttxn.currency_code,
                l_rcv_accttxn.destination_type_code,
                /* start LCM-OPM Integration  */
                l_rcv_accttxn.unit_landed_cost
                /* end LCM-OPM Integration  */
           FROM rcv_transactions rt,
                po_lines pol,
                po_line_locations poll,
                po_headers poh,
                po_distributions pod
          WHERE rt.transaction_id = p_rcv_transaction_id
            AND poh.po_header_id = rt.po_header_id
            AND pol.po_line_id = rt.po_line_id
            AND poll.line_location_id = rt.po_line_location_id
            AND pod.po_distribution_id = p_po_distribution_id;
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
      -- The transactions will be seeded such that the transfer_org_id will represent the reverse
      -- flow.
      l_stmt_num := 40;
      l_rcv_accttxn.org_id := p_org_id;
      l_rcv_accttxn.transfer_org_id := p_transfer_org_id;
      l_rcv_accttxn.organization_id := p_organization_id;
      l_rcv_accttxn.transfer_organization_id := p_transfer_organization_id;
      l_rcv_accttxn.trx_flow_header_id := p_trx_flow_header_id;
      -- Get the Set Of Books Identifier
      l_stmt_num := 50;

      SELECT set_of_books_id
        INTO l_rcv_accttxn.ledger_id
        FROM cst_organization_definitions cod
       WHERE organization_id = p_organization_id;

      -- Initialize transaction date
      IF (p_event_type_id IN
             (adjust_receive,
              adjust_deliver,
              intercompany_invoice,
              intercompany_reversal
             )
         )
      THEN
         l_rcv_accttxn.transaction_date := SYSDATE;
      END IF;

      -- Encumbrance cannot be enabled for global procurement scenarios.
      IF (l_rcv_accttxn.trx_flow_header_id IS NULL)
      THEN
         -- If GL is installed, and either encumbrance is enabled or USSGL profile is enabled,
         -- journal import is called by the receiving TM. The group_id passed by receiving should
         -- be stamped on the event in this scenario.
         l_stmt_num := 60;
         l_gl_installed :=
            fnd_installation.get_app_info ('SQLGL',
                                           l_status,
                                           l_industry,
                                           l_oracle_schema
                                          );

         IF (l_status = 'I')
         THEN
            l_stmt_num := 70;

            IF     g_debug = 'Y'
               AND fnd_log.level_event >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_event,
                                  g_log_head
                               || '.'
                               || l_api_name
                               || '.'
                               || l_stmt_num,
                               'Checking if encumbrance is enabled.'
                              );
            END IF;

            check_encumbranceflag (p_api_version           => 1.0,
                                   x_return_status         => l_return_status,
                                   x_msg_count             => l_msg_count,
                                   x_msg_data              => l_msg_data,
                                   p_rcv_ledger_id         => l_rcv_accttxn.ledger_id,
                                   x_encumbrance_flag      => l_encumbrance_flag,
                                   x_ussgl_option          => l_ussgl_option
                                  );

            IF l_return_status <> fnd_api.g_ret_sts_success
            THEN
               l_api_message := 'Error in checking for encumbrance flag ';

               IF     g_debug = 'Y'
                  AND fnd_log.level_unexpected >=
                                               fnd_log.g_current_runtime_level
               THEN
                  fnd_log.STRING (fnd_log.level_unexpected,
                                  g_log_head || '.' || l_api_name
                                  || l_stmt_num,
                                     'Insert_Txn : '
                                  || l_stmt_num
                                  || ' : '
                                  || l_api_message
                                 );
               END IF;

               RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            IF (l_encumbrance_flag = 'Y' OR l_ussgl_option = 'Y')
            THEN
               l_rcv_accttxn.gl_group_id := p_gl_group_id;
            END IF;
         END IF;
      END IF;

      l_stmt_num := 80;

      -- Check if event is for a service line type
      SELECT DECODE (poll.matching_basis, 'AMOUNT', 'Y', 'N')
        INTO l_rcv_accttxn.service_flag
        FROM po_line_locations poll
       WHERE poll.line_location_id = l_rcv_accttxn.po_line_location_id;

      l_stmt_num := 90;

      -- Initialize Unit Price
      IF (p_event_type_id IN (adjust_receive, adjust_deliver))
      THEN
         l_rcv_accttxn.unit_price := p_unit_price;
         l_rcv_accttxn.prior_unit_price := p_prior_unit_price;
      ELSIF l_rcv_accttxn.service_flag = 'Y'
      THEN
         l_stmt_num := 100;

         IF     g_debug = 'Y'
            AND fnd_log.level_event >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_event,
                            g_log_head || '.' || l_api_name || '.'
                            || l_stmt_num,
                            'Service line type : Getting Transaction Amount'
                           );
         END IF;

         get_transactionamount (p_api_version             => l_api_version,
                                x_return_status           => l_return_status,
                                x_msg_count               => l_msg_count,
                                x_msg_data                => l_msg_data,
                                p_rcv_accttxn             => l_rcv_accttxn,
                                x_transaction_amount      => l_transaction_amount
                               );

         IF l_return_status <> fnd_api.g_ret_sts_success
         THEN
            l_api_message := 'Error getting transaction amount';

            IF     g_debug = 'Y'
               AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_unexpected,
                               g_log_head || '.' || l_api_name || l_stmt_num,
                                  'Insert_Txn : '
                               || l_stmt_num
                               || ' : '
                               || l_api_message
                              );
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         l_rcv_accttxn.transaction_amount := l_transaction_amount;
      ELSE
         l_stmt_num := 110;

         IF     g_debug = 'Y'
            AND fnd_log.level_event >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_event,
                            g_log_head || '.' || l_api_name || '.'
                            || l_stmt_num,
                            'Non Service Line Type : Getting Unit Price'
                           );
         END IF;

         IF (p_event_type_id NOT IN
                                (intercompany_invoice, intercompany_reversal)
            )
         THEN
            l_asset_option :=
                     p_transaction_reverse_flow_rec.asset_item_pricing_option;
            l_expense_option :=
                   p_transaction_reverse_flow_rec.expense_item_pricing_option;
         ELSE
            l_asset_option :=
                     p_transaction_forward_flow_rec.asset_item_pricing_option;
            l_expense_option :=
                   p_transaction_forward_flow_rec.expense_item_pricing_option;
         END IF;

         get_unitprice (p_api_version                      => l_api_version,
                        x_return_status                    => l_return_status,
                        x_msg_count                        => l_msg_count,
                        x_msg_data                         => l_msg_data,
                        p_rcv_accttxn                      => l_rcv_accttxn,
                        p_asset_item_pricing_option        => l_asset_option,
                        p_expense_item_pricing_option      => l_expense_option,
                        x_intercompany_pricing_option      => l_ic_pricing_option,
                        x_unit_price                       => l_unit_price,
                        x_currency_code                    => l_currency_code,
                        x_incr_transfer_price              => l_incr_transfer_price,
                        x_incr_currency_code               => l_incr_currency_code
                       );

         IF l_return_status <> fnd_api.g_ret_sts_success
         THEN
            l_api_message := 'Error getting unit price';

            IF     g_debug = 'Y'
               AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_unexpected,
                               g_log_head || '.' || l_api_name || l_stmt_num,
                                  'Insert_Txn : '
                               || l_stmt_num
                               || ' : '
                               || l_api_message
                              );
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         l_rcv_accttxn.intercompany_pricing_option := l_ic_pricing_option;
         l_rcv_accttxn.currency_code := l_currency_code;
         l_rcv_accttxn.unit_price := l_unit_price;
         l_rcv_accttxn.intercompany_price := l_incr_transfer_price;
         l_rcv_accttxn.intercompany_curr_code := l_incr_currency_code;
      END IF;

      -- Initialize Transaction Quantity
      IF l_rcv_accttxn.service_flag = 'N'
      THEN
         l_stmt_num := 120;

         IF     g_debug = 'Y'
            AND fnd_log.level_event >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_event,
                            g_log_head || '.' || l_api_name || '.'
                            || l_stmt_num,
                            'Non Service line type : Getting Quantity'
                           );
         END IF;

         get_quantity (p_api_version              => l_api_version,
                       x_return_status            => l_return_status,
                       x_msg_count                => l_msg_count,
                       x_msg_data                 => l_msg_data,
                       p_rcv_accttxn              => l_rcv_accttxn,
                       x_source_doc_quantity      => l_source_doc_quantity
                      );

         IF l_return_status <> fnd_api.g_ret_sts_success
         THEN
            l_api_message := 'Error getting quantity';

            IF     g_debug = 'Y'
               AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_unexpected,
                               g_log_head || '.' || l_api_name || l_stmt_num,
                                  'Insert_Txn : '
                               || l_stmt_num
                               || ' : '
                               || l_api_message
                              );
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         l_rcv_accttxn.source_doc_quantity := l_source_doc_quantity;

         -- If transaction quantity is 0, then no event should be seeded.
         IF (l_source_doc_quantity = 0)
         THEN
            x_return_status := 'W';

            IF     g_debug = 'Y'
               AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
            THEN
               l_api_message :=
                  'Transaction Quantity is 0. Returning without seeding event.';
               fnd_log.STRING (fnd_log.level_unexpected,
                               g_log_head || '.' || l_api_name || l_stmt_num,
                                  'Insert_Txnt : '
                               || l_stmt_num
                               || ' : '
                               || l_api_message
                              );
            END IF;

            RETURN;
         END IF;
      END IF;

      l_stmt_num := 130;

      IF     g_debug = 'Y'
         AND fnd_log.level_event >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_log_head || '.' || l_api_name || '.' || l_stmt_num,
                         'Getting Tax'
                        );
      END IF;

      get_unittax (p_api_version        => l_api_version,
                   x_return_status      => l_return_status,
                   x_msg_count          => l_msg_count,
                   x_msg_data           => l_msg_data,
                   p_rcv_accttxn        => l_rcv_accttxn,
                   x_unit_nr_tax        => l_unit_nr_tax,
                   x_unit_rec_tax       => l_unit_rec_tax,
                   x_prior_nr_tax       => l_prior_nr_tax,
                   x_prior_rec_tax      => l_prior_rec_tax
                  );

      IF l_return_status <> fnd_api.g_ret_sts_success
      THEN
         l_api_message := 'Error getting tax';

         IF     g_debug = 'Y'
            AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_log_head || '.' || l_api_name || l_stmt_num,
                               'Insert_Txn : '
                            || l_stmt_num
                            || ' : '
                            || l_api_message
                           );
         END IF;

         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_rcv_accttxn.unit_nr_tax := l_unit_nr_tax;
      l_rcv_accttxn.unit_rec_tax := l_unit_rec_tax;
      l_rcv_accttxn.prior_nr_tax := l_prior_nr_tax;
      l_rcv_accttxn.prior_rec_tax := l_prior_rec_tax;
      l_stmt_num := 140;

      IF l_rcv_accttxn.service_flag = 'N'
      THEN
         IF     g_debug = 'Y'
            AND fnd_log.level_event >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_event,
                            g_log_head || '.' || l_api_name || '.'
                            || l_stmt_num,
                            'Getting UOM'
                           );
         END IF;

         convert_uom (p_api_version          => l_api_version,
                      x_return_status        => l_return_status,
                      x_msg_count            => l_msg_count,
                      x_msg_data             => l_msg_data,
                      p_event_rec            => l_rcv_accttxn,
                      x_transaction_qty      => l_transaction_quantity,
                      x_primary_uom          => l_primary_uom,
                      x_primary_qty          => l_primary_qty,
                      x_trx_uom_code         => l_trx_uom_code
                     );

         IF l_return_status <> fnd_api.g_ret_sts_success
         THEN
            l_api_message := 'Error Converting UOM';

            IF     g_debug = 'Y'
               AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_unexpected,
                               g_log_head || '.' || l_api_name || l_stmt_num,
                                  'Insert_Txn : '
                               || l_stmt_num
                               || ' : '
                               || l_api_message
                              );
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         l_rcv_accttxn.transaction_quantity := l_transaction_quantity;
         l_rcv_accttxn.primary_uom := l_primary_uom;
         l_rcv_accttxn.primary_quantity := l_primary_qty;
         l_rcv_accttxn.trx_uom_code := l_trx_uom_code;
      END IF;

      -- Initialize Currency Information
      l_stmt_num := 150;

      IF     g_debug = 'Y'
         AND fnd_log.level_event >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_log_head || '.' || l_api_name || '.' || l_stmt_num,
                         'Getting Currency Information'
                        );
      END IF;

      get_currency (p_api_version                   => l_api_version,
                    x_return_status                 => l_return_status,
                    x_msg_count                     => l_msg_count,
                    x_msg_data                      => l_msg_data,
                    p_rcv_accttxn                   => l_rcv_accttxn,
                    x_currency_code                 => l_currency_code,
                    x_currency_conversion_rate      => l_currency_conversion_rate,
                    x_currency_conversion_date      => l_currency_conversion_date,
                    x_currency_conversion_type      => l_currency_conversion_type
                   );

      IF l_return_status <> fnd_api.g_ret_sts_success
      THEN
         l_api_message := 'Error Getting Currency';

         IF     g_debug = 'Y'
            AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_log_head || '.' || l_api_name || l_stmt_num,
                               'Insert_Txn : '
                            || l_stmt_num
                            || ' : '
                            || l_api_message
                           );
         END IF;

         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_rcv_accttxn.currency_code := l_currency_code;
      l_rcv_accttxn.currency_conversion_rate := l_currency_conversion_rate;
      l_rcv_accttxn.currency_conversion_date := l_currency_conversion_date;
      l_rcv_accttxn.currency_conversion_type := l_currency_conversion_type;
      -- Get Debit and Credit Accounts
      l_stmt_num := 160;

      IF     g_debug = 'Y'
         AND fnd_log.level_event >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_log_head || '.' || l_api_name || '.' || l_stmt_num,
                         'Getting Debit and Credit Accounts'
                        );
      END IF;

      get_accounts
            (p_api_version                       => l_api_version,
             x_return_status                     => l_return_status,
             x_msg_count                         => l_msg_count,
             x_msg_data                          => l_msg_data,
             p_rcv_accttxn                       => l_rcv_accttxn,
             p_transaction_forward_flow_rec      => p_transaction_forward_flow_rec,
             p_transaction_reverse_flow_rec      => p_transaction_reverse_flow_rec,
             x_credit_acct_id                    => l_credit_acct_id,
             x_debit_acct_id                     => l_debit_acct_id,
             x_ic_cogs_acct_id                   => l_ic_cogs_acct_id
            );

      IF l_return_status <> fnd_api.g_ret_sts_success
      THEN
         l_api_message := 'Error getting account information';

         IF     g_debug = 'Y'
            AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_log_head || '.' || l_api_name || l_stmt_num,
                               'Insert_Txn : '
                            || l_stmt_num
                            || ' : '
                            || l_api_message
                           );
         END IF;

         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_rcv_accttxn.credit_account_id := l_credit_acct_id;
      l_rcv_accttxn.debit_account_id := l_debit_acct_id;
      l_rcv_accttxn.intercompany_cogs_account_id := l_ic_cogs_acct_id;
      -- Initialize USSGL Transaction Codes
      l_stmt_num := 170;

      IF     g_debug = 'Y'
         AND fnd_log.level_event >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_log_head || '.' || l_api_name || '.' || l_stmt_num,
                         'Getting USSGL TC'
                        );
      END IF;

      get_ussgltc (p_api_version        => l_api_version,
                   x_return_status      => l_return_status,
                   x_msg_count          => l_msg_count,
                   x_msg_data           => l_msg_data,
                   p_rcv_accttxn        => l_rcv_accttxn,
                   x_ussgl_tc           => l_ussgl_tc
                  );

      IF l_return_status <> fnd_api.g_ret_sts_success
      THEN
         l_api_message := 'Error getting USSGL Transaction Code';

         IF     g_debug = 'Y'
            AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_log_head || '.' || l_api_name || l_stmt_num,
                               'Insert_Txn : '
                            || l_stmt_num
                            || ' : '
                            || l_api_message
                           );
         END IF;

         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_rcv_accttxn.ussgl_transaction_code := l_ussgl_tc;
      x_rcv_accttxn := l_rcv_accttxn;

      --- Standard check of p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard Call to get message count and if count = 1, get message info
      fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                 p_data       => x_msg_data);

      IF     g_debug = 'Y'
         AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_log_head || '.' || l_api_name || '.end',
                         'Insert_Txn >>'
                        );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO insert_txn_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO insert_txn_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN OTHERS
      THEN
         ROLLBACK TO insert_txn_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF     g_debug = 'Y'
            AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_log_head || '.' || l_api_name || l_stmt_num,
                               'Insert_Txn '
                            || l_stmt_num
                            || ' : '
                            || SUBSTR (SQLERRM, 1, 200)
                           );
         END IF;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name,
                                        l_api_name
                                     || 'Statement -'
                                     || TO_CHAR (l_stmt_num)
                                    );
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
   END insert_txn;

/** =========================================
* Adapted from Insert_Txn
** ========================================== **/
   PROCEDURE insert_txn2 (
      p_api_version        IN              NUMBER := 1.0,
      p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false,
      p_commit             IN              VARCHAR2 := fnd_api.g_false,
      p_validation_level   IN              NUMBER
            := fnd_api.g_valid_level_full,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2,
      p_rcv_accttxn_tbl    IN              gmf_rcv_accounting_pkg.rcv_accttxn_tbl_type
   )
   IS
      l_api_name        CONSTANT VARCHAR2 (30)   := 'Insert_Txn2';
      l_api_version     CONSTANT NUMBER          := 1.0;
      l_return_status            VARCHAR2 (1)    := fnd_api.g_ret_sts_success;
      l_msg_count                NUMBER          := 0;
      l_msg_data                 VARCHAR2 (8000) := '';
      l_stmt_num                 NUMBER          := 0;
      l_api_message              VARCHAR2 (1000);
      l_summarize_acc_flag       VARCHAR2 (1)    := 'N';
      l_err_num                  NUMBER;
      l_err_code                 VARCHAR2 (240);
      l_err_msg                  VARCHAR2 (240);
      l_return_code              NUMBER;
      l_rcv_transaction_id       NUMBER;
      l_del_transaction_id       NUMBER;
      l_detail_accounting_flag   VARCHAR2 (1)    := 'Y';
      l_accrue_on_receipt_flag   VARCHAR2 (1)    := 'N';
      l_accounting_txn_id        NUMBER;
      l_ctr_first                NUMBER;
   BEGIN
      -- Standard start of API savepoint
      SAVEPOINT insert_txn2_pvt;
      l_stmt_num := 0;

      IF     g_debug = 'Y'
         AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_log_head || '.' || l_api_name || '.begin',
                         'Insert_Txn2 <<'
                        );
      END IF;

      -- Standard call to check for call compatibility
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      IF     g_debug = 'Y'
         AND fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         l_api_message :=
               'Inserting '
            || p_rcv_accttxn_tbl.COUNT
            || ' transactions into GRAT';
         fnd_log.STRING (fnd_log.level_statement,
                         g_log_head || '.' || l_api_name || '.' || l_stmt_num,
                         l_api_message
                        );
      END IF;

      l_ctr_first := p_rcv_accttxn_tbl.FIRST;
      -- Check for accrual option. If accrual option is set to accrue at period-end, don't call the
      -- accounting API.
      l_stmt_num := 20;

      SELECT NVL (poll.accrue_on_receipt_flag, 'N')
        INTO l_accrue_on_receipt_flag
        FROM po_line_locations poll
       WHERE poll.line_location_id =
                           p_rcv_accttxn_tbl (l_ctr_first).po_line_location_id;

      <<grat_insert>>
      FOR i IN p_rcv_accttxn_tbl.FIRST .. p_rcv_accttxn_tbl.LAST
      LOOP
         l_stmt_num := 30;

         SELECT gmf_rcv_accounting_txns_s.NEXTVAL
           INTO l_accounting_txn_id
           FROM DUAL;

         IF     g_debug = 'Y'
            AND fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            l_api_message :=
               SUBSTR (   'i : '
                       || i
                       || 'accounting_txn_id : '
                       || l_accounting_txn_id
                       || 'rcv_transaction_id : '
                       || p_rcv_accttxn_tbl (i).rcv_transaction_id
                       || 'po_line_id : '
                       || p_rcv_accttxn_tbl (i).po_line_id
                       || 'po_dist_id : '
                       || p_rcv_accttxn_tbl (i).po_distribution_id
                       || 'unit_price : '
                       || p_rcv_accttxn_tbl (i).unit_price
                       || 'currency : '
                       || p_rcv_accttxn_tbl (i).currency_code
                       || 'nr tax : '
                       || p_rcv_accttxn_tbl (i).unit_nr_tax
                       || 'rec tax : '
                       || p_rcv_accttxn_tbl (i).unit_rec_tax,
                       1,
                       1000
                      );
            fnd_log.STRING (fnd_log.level_statement,
                            g_log_head || '.' || l_api_name || '.'
                            || l_stmt_num,
                            l_api_message
                           );
         END IF;

         -- We are not doing a bulk insert due to a database limitation. On databases
         -- prior to 9i, you cannot do a bulk insert using a table of records. You have to
         -- multiple tables of scalar types. The expense of converting the table of records
         -- to multiple tables is not worthwhile in this case since we do not expect the
         -- number of rows to exceed 10.
         l_stmt_num := 40;

         INSERT INTO gmf_rcv_accounting_txns
                     (accounting_txn_id,
                      rcv_transaction_id,
                      event_type,
                      event_source,
                      event_source_id,
                      ledger_id,
                      org_id,
                      transfer_org_id,
                      organization_id,
                      transfer_organization_id,
                      debit_account_id,
                      credit_account_id,
                      transaction_date,
                      transaction_quantity,
                      transaction_unit_of_measure,
                      source_doc_quantity,
                      source_doc_unit_of_measure,
                      primary_quantity,
                      primary_unit_of_measure,
                      inventory_item_id,
                      po_header_id,
                      po_release_id,
                      po_line_id,
                      po_line_location_id,
                      po_distribution_id,
                      intercompany_pricing_option,
                      unit_price,
                      transaction_amount,
                      prior_unit_price,
                      nr_tax,
                      rec_tax, nr_tax_amount, rec_tax_amount,
                      prior_nr_tax,
                      prior_rec_tax,
                      currency_code,
                      currency_conversion_type,
                      currency_conversion_rate,
                      currency_conversion_date, accounted_flag,
                      procurement_org_flag,
                      cross_ou_flag,
                      trx_flow_header_id, invoiced_flag, creation_date,
                      created_by, last_update_date, last_updated_by,
                      last_update_login, request_id,
                      program_application_id, program_id,
                      program_udpate_date,
                      /* start LCM-OPM Integration  */
                      unit_landed_cost
                      /* end LCM-OPM Integration  */
                     )
              VALUES (gmf_rcv_accounting_txns_s.NEXTVAL,
                      DECODE (p_rcv_accttxn_tbl (i).event_source,
                              'INVOICEMATCH', p_rcv_accttxn_tbl (i).inv_distribution_id,
                              p_rcv_accttxn_tbl (i).rcv_transaction_id
                             ),
                      p_rcv_accttxn_tbl (i).event_type_id,
                      p_rcv_accttxn_tbl (i).event_source,
                      DECODE (p_rcv_accttxn_tbl (i).event_source,
                              'INVOICEMATCH', p_rcv_accttxn_tbl (i).inv_distribution_id,
                              p_rcv_accttxn_tbl (i).rcv_transaction_id
                             ),
                      p_rcv_accttxn_tbl (i).ledger_id,
                      p_rcv_accttxn_tbl (i).org_id,
                      p_rcv_accttxn_tbl (i).transfer_org_id,
                      p_rcv_accttxn_tbl (i).organization_id,
                      p_rcv_accttxn_tbl (i).transfer_organization_id,
                      p_rcv_accttxn_tbl (i).debit_account_id,
                      p_rcv_accttxn_tbl (i).credit_account_id,
                      p_rcv_accttxn_tbl (i).transaction_date,
                      DECODE (p_rcv_accttxn_tbl (i).service_flag,
                              'N', p_rcv_accttxn_tbl (i).transaction_quantity,
                              NULL
                             ),
                      p_rcv_accttxn_tbl (i).transaction_uom,
                      DECODE (p_rcv_accttxn_tbl (i).service_flag,
                              'N', p_rcv_accttxn_tbl (i).source_doc_quantity,
                              NULL
                             ),
                      p_rcv_accttxn_tbl (i).source_doc_uom,
                      DECODE (p_rcv_accttxn_tbl (i).service_flag,
                              'N', p_rcv_accttxn_tbl (i).primary_quantity,
                              NULL
                             ),
                      p_rcv_accttxn_tbl (i).primary_uom,
                      p_rcv_accttxn_tbl (i).item_id,
                      p_rcv_accttxn_tbl (i).po_header_id,
                      p_rcv_accttxn_tbl (i).po_release_id,
                      p_rcv_accttxn_tbl (i).po_line_id,
                      p_rcv_accttxn_tbl (i).po_line_location_id,
                      p_rcv_accttxn_tbl (i).po_distribution_id,
                      p_rcv_accttxn_tbl (i).intercompany_pricing_option,
                      DECODE (p_rcv_accttxn_tbl (i).service_flag,
                              'N', p_rcv_accttxn_tbl (i).unit_price
                               + p_rcv_accttxn_tbl (i).unit_nr_tax,
                              NULL
                             ),
                      DECODE (p_rcv_accttxn_tbl (i).event_source,
                              'RETROPRICE', p_rcv_accttxn_tbl (i).prior_unit_price
                               + p_rcv_accttxn_tbl (i).prior_nr_tax,
                              NULL
                             ),
                      p_rcv_accttxn_tbl (i).prior_unit_price,
                      p_rcv_accttxn_tbl (i).unit_nr_tax,
                      p_rcv_accttxn_tbl (i).unit_rec_tax, NULL, NULL,
                      p_rcv_accttxn_tbl (i).prior_nr_tax,
                      p_rcv_accttxn_tbl (i).prior_rec_tax,
                      p_rcv_accttxn_tbl (i).currency_code,
                      p_rcv_accttxn_tbl (i).currency_conversion_type,
                      p_rcv_accttxn_tbl (i).currency_conversion_rate,
                      p_rcv_accttxn_tbl (i).currency_conversion_date, 'N',
                      p_rcv_accttxn_tbl (i).procurement_org_flag,
                      p_rcv_accttxn_tbl (i).cross_ou_flag,
                      p_rcv_accttxn_tbl (i).trx_flow_header_id, 'Y', SYSDATE,
                      fnd_global.user_id, SYSDATE, fnd_global.user_id,
                      fnd_global.login_id, fnd_global.conc_request_id,
                      fnd_global.prog_appl_id, fnd_global.conc_program_id,
                      SYSDATE,
                      /* start LCM-OPM Integration  */
                      p_rcv_accttxn_tbl (i).unit_landed_cost
                      /* end LCM-OPM Integration  */
                     );

         IF     g_debug = 'Y'
            AND fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            l_api_message :=
                  'Inserted '
               || SQL%ROWCOUNT
               || 'rows in GRAT for org '
               || p_rcv_accttxn_tbl (i).org_id;
            fnd_log.STRING (fnd_log.level_statement,
                            g_log_head || '.' || l_api_name || '.'
                            || l_stmt_num,
                            l_api_message
                           );
         END IF;

        /**
        * rs - For process orgs, we are done at this point.
        * the accounting events for SLA will be created by the pre-processor
        * when it is run for PO transactions
        **/

      END LOOP grat_insert;

      --- Standard check of p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard Call to get message count and if count = 1, get message info
      fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                 p_data       => x_msg_data);

      IF     g_debug = 'Y'
         AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_log_head || '.' || l_api_name || '.end',
                         'Insert_Txn2 >>'
                        );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO insert_txn2_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO insert_txn2_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN OTHERS
      THEN
         ROLLBACK TO insert_txn2_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF     g_debug = 'Y'
            AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_log_head || '.' || l_api_name || l_stmt_num,
                               'Insert_Txn2 : '
                            || l_stmt_num
                            || ' : '
                            || SUBSTR (SQLERRM, 1, 200)
                           );
         END IF;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name,
                                        l_api_name
                                     || 'Statement -'
                                     || TO_CHAR (l_stmt_num)
                                    );
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
   END insert_txn2;

   PROCEDURE create_receive_txns (
      p_api_version            IN              NUMBER,
      p_init_msg_list          IN              VARCHAR2 := fnd_api.g_false,
      p_commit                 IN              VARCHAR2 := fnd_api.g_false,
      p_validation_level       IN              NUMBER
            := fnd_api.g_valid_level_full,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2,
      p_rcv_transaction_id     IN              NUMBER,
      p_direct_delivery_flag   IN              VARCHAR2,
      p_gl_group_id            IN              NUMBER
   )
   IS
      l_api_name              CONSTANT VARCHAR2 (30)
                                                    := 'Create_ReceiveEvents';
      l_api_version           CONSTANT NUMBER                          := 1.0;
      l_return_status                  VARCHAR2 (1)
                                                 := fnd_api.g_ret_sts_success;
      l_msg_count                      NUMBER                            := 0;
      l_msg_data                       VARCHAR2 (8000)                  := '';
      l_stmt_num                       NUMBER                            := 0;
      l_api_message                    VARCHAR2 (1000);
      l_rcv_accttxn                    gmf_rcv_accounting_pkg.rcv_accttxn_rec_type;
      l_rcv_accttxn_tbl                gmf_rcv_accounting_pkg.rcv_accttxn_tbl_type;
      l_event_type_id                  NUMBER;
      l_transaction_flows_tbl          inv_transaction_flow_pub.g_transaction_flow_tbl_type;
      l_transaction_forward_flow_rec   inv_transaction_flow_pub.mtl_transaction_flow_rec_type;
      l_transaction_reverse_flow_rec   inv_transaction_flow_pub.mtl_transaction_flow_rec_type;
      l_trx_flow_exists_flag           NUMBER                            := 0;
      l_trx_flow_ctr                   NUMBER                            := 0;
      l_po_header_id                   NUMBER;
      l_po_line_id                     NUMBER;
      l_po_line_location_id            NUMBER;
      l_po_distribution_id             NUMBER;
      l_po_org_id                      NUMBER;
      l_po_ledger_id                   NUMBER;
      l_rcv_organization_id            NUMBER;
      l_rcv_org_id                     NUMBER;
      l_rcv_ledger_id                  NUMBER;
      l_org_id                         NUMBER;
      l_transfer_org_id                NUMBER;
      l_transfer_organization_id       NUMBER;
      l_rcv_trx_date                   DATE;
      l_drop_ship_flag                 NUMBER;
      l_destination_type               VARCHAR (25);
      l_item_id                        NUMBER;
      l_category_id                    NUMBER;
      l_project_id                     NUMBER;
      l_cross_ou_flag                  VARCHAR2 (1);
      l_accrual_flag                   VARCHAR2 (1);
      l_counter                        NUMBER;
      l_procurement_org_flag           VARCHAR2 (1);
      l_trx_flow_header_id             NUMBER;
      l_qualifier_code_tbl             inv_transaction_flow_pub.number_tbl;
      l_qualifier_value_tbl            inv_transaction_flow_pub.number_tbl;

      CURSOR c_po_distributions_csr (
         p_po_distribution_id    NUMBER,
         p_po_line_location_id   NUMBER
      )
      IS
         SELECT po_distribution_id, destination_type_code, project_id
           FROM po_distributions pod
          WHERE pod.po_distribution_id =
                           NVL (p_po_distribution_id, pod.po_distribution_id)
            AND pod.line_location_id = p_po_line_location_id;
   BEGIN
      -- Standard start of API savepoint
      SAVEPOINT create_receiveevents_pvt;
      l_stmt_num := 0;

      IF     g_debug = 'Y'
         AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_log_head || '.' || l_api_name || '.begin',
                         'Create_ReceiveEvents <<'
                        );
      END IF;

      -- Standard call to check for call compatibility
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      l_stmt_num := 20;

      SELECT rt.po_header_id, rt.po_line_id, rt.po_line_location_id,
             rt.po_distribution_id, rt.transaction_date,
             NVL (rt.dropship_type_code, 3), poh.org_id,
             poll.ship_to_organization_id, pol.item_id, pol.category_id,
             pol.project_id, NVL (poll.accrue_on_receipt_flag, 'N')
        INTO l_po_header_id, l_po_line_id, l_po_line_location_id,
             l_po_distribution_id, l_rcv_trx_date,
             l_drop_ship_flag, l_po_org_id,
             l_rcv_organization_id, l_item_id, l_category_id,
             l_project_id, l_accrual_flag
        FROM po_headers poh,
             po_line_locations poll,
             po_lines pol,
             rcv_transactions rt
       WHERE rt.transaction_id = p_rcv_transaction_id
         AND poh.po_header_id = rt.po_header_id
         AND poll.line_location_id = rt.po_line_location_id
         AND pol.po_line_id = rt.po_line_id;

      l_stmt_num := 30;

      -- Get Receiving Operating Unit
      SELECT operating_unit, set_of_books_id
        INTO l_rcv_org_id, l_rcv_ledger_id
        FROM cst_organization_definitions cod
       WHERE organization_id = l_rcv_organization_id;

      l_stmt_num := 35;

      -- Get PO SOB
      SELECT set_of_books_id
        INTO l_po_ledger_id
        FROM financials_system_parameters;

      l_stmt_num := 40;

      IF     g_debug = 'Y'
         AND fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         l_api_message :=
               'Creating Receive transactions : RCV Transaction ID : '
            || p_rcv_transaction_id
            || ', PO Header ID : '
            || l_po_header_id
            || ', PO Line ID : '
            || l_po_line_id
            || ', PO Line Location ID : '
            || l_po_line_location_id
            || ', PO Dist ID : '
            || l_po_distribution_id
            || ', Transaction Date : '
            || l_rcv_trx_date
            || ', Drop Ship Flag : '
            || l_drop_ship_flag
            || ', PO Org ID : '
            || l_po_org_id
            || ', PO LEDGER ID : '
            || l_po_ledger_id
            || ', RCV Organization ID : '
            || l_rcv_organization_id
            || ', RCV Org ID : '
            || l_rcv_org_id
            || ', RCV LEDGER ID : '
            || l_rcv_ledger_id
            || ', Category ID : '
            || l_category_id
            || ', Accrual Flag : '
            || l_accrual_flag;
         fnd_log.STRING (fnd_log.level_statement,
                         g_log_head || '.' || l_api_name || '.' || l_stmt_num,
                         l_api_message
                        );
      END IF;

      IF (l_po_org_id = l_rcv_org_id)
      THEN
         l_cross_ou_flag := 'N';
      ELSE
         l_cross_ou_flag := 'Y';
         /* For 11i10, the only supported qualifier is category id. */
         l_qualifier_code_tbl (l_qualifier_code_tbl.COUNT + 1) :=
                                    inv_transaction_flow_pub.g_qualifier_code;
         l_qualifier_value_tbl (l_qualifier_value_tbl.COUNT + 1) :=
                                                                l_category_id;
         l_stmt_num := 50;

         IF     g_debug = 'Y'
            AND fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            l_api_message :=
                  'Getting Procurement Transaction Flow :'
               || 'l_po_org_id : '
               || l_po_org_id
               || ' l_rcv_org_id : '
               || l_rcv_org_id
               || ' l_rcv_organization_id : '
               || l_rcv_organization_id;
            fnd_log.STRING (fnd_log.level_statement,
                            g_log_head || '.' || l_api_name || '.'
                            || l_stmt_num,
                            l_api_message
                           );
         END IF;

         inv_transaction_flow_pub.get_transaction_flow
               (x_return_status               => l_return_status,
                x_msg_data                    => l_msg_data,
                x_msg_count                   => l_msg_count,
                x_transaction_flows_tbl       => l_transaction_flows_tbl,
                p_api_version                 => 1.0,
                p_start_operating_unit        => l_po_org_id,
                p_end_operating_unit          => l_rcv_org_id,
                p_flow_type                   => inv_transaction_flow_pub.g_procuring_flow_type,
                p_organization_id             => l_rcv_organization_id,
                p_qualifier_code_tbl          => l_qualifier_code_tbl,
                p_qualifier_value_tbl         => l_qualifier_value_tbl,
                p_transaction_date            => l_rcv_trx_date,
                p_get_default_cost_group      => 'N'
               );

         IF (l_return_status = fnd_api.g_ret_sts_success)
         THEN
            l_trx_flow_exists_flag := 1;
            l_trx_flow_header_id :=
               l_transaction_flows_tbl (l_transaction_flows_tbl.FIRST).header_id;

            IF     g_debug = 'Y'
               AND fnd_log.level_event >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_event,
                                  g_log_head
                               || '.'
                               || l_api_name
                               || '.'
                               || l_stmt_num,
                               'Transaction Flow exists'
                              );
            END IF;
         -- Return Status of 'W' indicates that no transaction flow exists.
         ELSIF (l_return_status = 'W')
         THEN
            l_trx_flow_exists_flag := 0;

            IF     g_debug = 'Y'
               AND fnd_log.level_event >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_event,
                                  g_log_head
                               || '.'
                               || l_api_name
                               || '.'
                               || l_stmt_num,
                               'Transaction Flow does not exist'
                              );
            END IF;

                  -- If transaction flow does not exist, but the PO crosses multiple
            -- sets of books, error out the transaction.
            IF (l_po_ledger_id <> l_rcv_ledger_id)
            THEN
               l_api_message := 'Transaction Flow does not exist';

               IF     g_debug = 'Y'
                  AND fnd_log.level_unexpected >=
                                               fnd_log.g_current_runtime_level
               THEN
                  fnd_log.STRING (fnd_log.level_unexpected,
                                  g_log_head || '.' || l_api_name
                                  || l_stmt_num,
                                     'Create_ReceiveEvents : '
                                  || l_stmt_num
                                  || ' : '
                                  || l_api_message
                                 );
               END IF;

               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
         ELSE
            l_api_message := 'Error occurred in Transaction Flow API';

            IF     g_debug = 'Y'
               AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_unexpected,
                               g_log_head || '.' || l_api_name || l_stmt_num,
                                  'Create_ReceiveEvents : '
                               || l_stmt_num
                               || ' : '
                               || l_api_message
                              );
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
         END IF;                                         -- IF l_return_status
      END IF;                                                -- IF l_po_org_id

      -- For the receive transaction, the PO distribution may not be available in the
      -- case of Standard Receipt. Hence perform all steps for each applicable distribution.
      -- If distribution is not available the quantity will be prorated. Furthermore, if
      -- there is a project on any of the distributions, and the destination_type_code is
      -- expense, the transaction flow should be ignored for just that distribution.
      FOR rec_pod IN c_po_distributions_csr (l_po_distribution_id,
                                             l_po_line_location_id
                                            )
      LOOP
         l_stmt_num := 60;

         IF     g_debug = 'Y'
            AND fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            l_api_message :=
                  'Creating Receive transactions : '
               || 'po_distribution_id : '
               || rec_pod.po_distribution_id
               || ' destination_type_code : '
               || rec_pod.destination_type_code
               || ' project_id : '
               || rec_pod.project_id;
            fnd_log.STRING (fnd_log.level_statement,
                            g_log_head || '.' || l_api_name || '.'
                            || l_stmt_num,
                            l_api_message
                           );
         END IF;

         l_procurement_org_flag := 'Y';

         -- For POs with destination type of expense, when there is a project on the
         -- POD, we should not look for transaction flow. This is because PA,(which transfers
         -- costs to Projects for expense destinations), is currently not supporting global
         -- procurement.
         IF (    (l_trx_flow_exists_flag = 1)
             AND (   rec_pod.project_id IS NULL
                  OR rec_pod.destination_type_code <> 'EXPENSE'
                 )
            )
         THEN
            l_trx_flow_ctr := l_transaction_flows_tbl.COUNT;

            -- Create Logical Receive transactions in each intermediate organization.
            FOR l_counter IN
               l_transaction_flows_tbl.FIRST .. l_transaction_flows_tbl.LAST
            LOOP
               IF     g_debug = 'Y'
                  AND fnd_log.level_event >= fnd_log.g_current_runtime_level
               THEN
                  fnd_log.STRING (fnd_log.level_event,
                                     g_log_head
                                  || '.'
                                  || l_api_name
                                  || '.'
                                  || l_stmt_num,
                                  'Seeding Logical Receive in GRAT'
                                 );
               END IF;

               l_stmt_num := 70;
               -- l_transaction_forward_flow_rec contains the transaction flow record
               -- where the org_id is the from_org_id.
               -- l_transaction_reverse_flow_rec contains the transaction flow record
               -- where the org_id is the to_org_id.
               -- Need to pass both to the Seed_RAE procedure because transfer_price is based
               -- on the reverse flow record and some accounts are based on the forward flow
               l_transaction_forward_flow_rec :=
                                           l_transaction_flows_tbl (l_counter);

               IF (l_counter = l_transaction_flows_tbl.FIRST)
               THEN
                  l_transaction_reverse_flow_rec := NULL;
                  l_transfer_org_id := NULL;
                  l_transfer_organization_id := NULL;
               ELSE
                  l_transaction_reverse_flow_rec :=
                                      l_transaction_flows_tbl (l_counter - 1);
                  l_transfer_org_id :=
                                   l_transaction_reverse_flow_rec.from_org_id;
                  l_transfer_organization_id :=
                          l_transaction_reverse_flow_rec.from_organization_id;
               END IF;

               l_stmt_num := 80;
               insert_txn
                  (x_return_status                     => l_return_status,
                   x_msg_count                         => l_msg_count,
                   x_msg_data                          => l_msg_data,
                   p_event_source                      => 'RECEIVING',
                   p_event_type_id                     => logical_receive,
                   p_rcv_transaction_id                => p_rcv_transaction_id,
                   p_inv_distribution_id               => NULL,
                   p_po_distribution_id                => rec_pod.po_distribution_id,
                   p_direct_delivery_flag              => p_direct_delivery_flag,
                   p_gl_group_id                       => p_gl_group_id,
                   p_cross_ou_flag                     => l_cross_ou_flag,
                   p_procurement_org_flag              => l_procurement_org_flag,
                   p_ship_to_org_flag                  => 'N',
                   p_drop_ship_flag                    => l_drop_ship_flag,
                   p_org_id                            => l_transaction_flows_tbl
                                                                    (l_counter).from_org_id,
                   p_organization_id                   => l_transaction_flows_tbl
                                                                    (l_counter).from_organization_id,
                   p_transfer_org_id                   => l_transfer_org_id,
                   p_transfer_organization_id          => l_transfer_organization_id,
                   p_trx_flow_header_id                => l_trx_flow_header_id,
                   p_transaction_forward_flow_rec      => l_transaction_forward_flow_rec,
                   p_transaction_reverse_flow_rec      => l_transaction_reverse_flow_rec,
                   p_unit_price                        => NULL,
                   p_prior_unit_price                  => NULL,
                   x_rcv_accttxn                       => l_rcv_accttxn
                  );

               IF l_return_status <> fnd_api.g_ret_sts_success
               THEN
                  l_api_message := 'Error creating event';

                  IF     g_debug = 'Y'
                     AND fnd_log.level_unexpected >=
                                               fnd_log.g_current_runtime_level
                  THEN
                     fnd_log.STRING (fnd_log.level_unexpected,
                                        g_log_head
                                     || '.'
                                     || l_api_name
                                     || l_stmt_num,
                                        'Create_ReceiveEvents : '
                                     || l_stmt_num
                                     || ' : '
                                     || l_api_message
                                    );
                  END IF;

                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;

               l_rcv_accttxn_tbl (l_rcv_accttxn_tbl.COUNT + 1) :=
                                                                 l_rcv_accttxn;

                   -- For one-time items, if online accruals is used, seed IC Invoice event.
               -- For Shop Floor destination types, always seed IC Invoice events.
               IF (   (l_item_id IS NULL AND l_accrual_flag = 'Y')
                   OR (rec_pod.destination_type_code = 'SHOP FLOOR')
                  )
               THEN
                  l_stmt_num := 90;

                  IF     g_debug = 'Y'
                     AND fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                  THEN
                     fnd_log.STRING (fnd_log.level_event,
                                        g_log_head
                                     || '.'
                                     || l_api_name
                                     || '.'
                                     || l_stmt_num,
                                     'Seeding Invoice Match in GRAT'
                                    );
                  END IF;

                  insert_txn
                     (p_api_version                       => 1.0,
                      x_return_status                     => l_return_status,
                      x_msg_count                         => l_msg_count,
                      x_msg_data                          => l_msg_data,
                      p_event_source                      => 'RECEIVING',
                      p_event_type_id                     => intercompany_invoice,
                      p_rcv_transaction_id                => p_rcv_transaction_id,
                      p_inv_distribution_id               => NULL,
                      p_po_distribution_id                => rec_pod.po_distribution_id,
                      p_direct_delivery_flag              => p_direct_delivery_flag,
                      p_gl_group_id                       => NULL,
                      p_cross_ou_flag                     => l_cross_ou_flag,
                      p_procurement_org_flag              => l_procurement_org_flag,
                      p_ship_to_org_flag                  => 'N',
                      p_drop_ship_flag                    => l_drop_ship_flag,
                      p_org_id                            => l_transaction_flows_tbl
                                                                    (l_counter).from_org_id,
                      p_organization_id                   => l_transaction_flows_tbl
                                                                    (l_counter).from_organization_id,
                      p_transfer_org_id                   => l_transaction_flows_tbl
                                                                    (l_counter).to_org_id,
                      p_transfer_organization_id          => l_transaction_flows_tbl
                                                                    (l_counter).to_organization_id,
                      p_trx_flow_header_id                => l_trx_flow_header_id,
                      p_transaction_forward_flow_rec      => l_transaction_forward_flow_rec,
                      p_transaction_reverse_flow_rec      => l_transaction_reverse_flow_rec,
                      p_unit_price                        => NULL,
                      p_prior_unit_price                  => NULL,
                      x_rcv_accttxn                       => l_rcv_accttxn
                     );

                  IF l_return_status <> fnd_api.g_ret_sts_success
                  THEN
                     l_api_message := 'Error creating event';

                     IF     g_debug = 'Y'
                        AND fnd_log.level_unexpected >=
                                               fnd_log.g_current_runtime_level
                     THEN
                        fnd_log.STRING (fnd_log.level_unexpected,
                                           g_log_head
                                        || '.'
                                        || l_api_name
                                        || l_stmt_num,
                                           'Create_ReceiveEvents : '
                                        || l_stmt_num
                                        || ' : '
                                        || l_api_message
                                       );
                     END IF;

                     RAISE fnd_api.g_exc_unexpected_error;
                  END IF;

                  l_rcv_accttxn_tbl (l_rcv_accttxn_tbl.COUNT + 1) :=
                                                                 l_rcv_accttxn;
               END IF;

               l_procurement_org_flag := 'N';
            END LOOP;
         END IF;

         l_stmt_num := 100;

         IF (l_trx_flow_exists_flag = 1)
         THEN
            l_transaction_forward_flow_rec := NULL;
            l_transaction_reverse_flow_rec :=
                                     l_transaction_flows_tbl (l_trx_flow_ctr);
            l_org_id := l_transaction_flows_tbl (l_trx_flow_ctr).to_org_id;
            l_transfer_org_id :=
                         l_transaction_flows_tbl (l_trx_flow_ctr).from_org_id;
            l_transfer_organization_id :=
                          l_transaction_reverse_flow_rec.from_organization_id;
         ELSE
            l_transaction_forward_flow_rec := NULL;
            l_transaction_reverse_flow_rec := NULL;
            l_org_id := l_po_org_id;
            l_transfer_org_id := NULL;
            l_transfer_organization_id := NULL;
         END IF;

         l_stmt_num := 110;

         -- If drop ship flag is 1(drop ship with new accounting) OR 2(drop ship with old accounting),
         -- then create a LOGICAL RECEIVE and use the clearing account. It drop ship flag is 3 (not a
         -- drop ship), then create a RECEIVE event
         IF (l_drop_ship_flag IN (1, 2))
         THEN
            -- This is a pure (external) drop ship scenario. Seed a LOGICAL_RECEIVE event in the receiving org.
            IF     g_debug = 'Y'
               AND fnd_log.level_event >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_event,
                                  g_log_head
                               || '.'
                               || l_api_name
                               || '.'
                               || l_stmt_num,
                               'Drop Ship : Seeding Logical Receive in GRAT'
                              );
            END IF;

            l_stmt_num := 120;
            insert_txn
               (p_api_version                       => 1.0,
                x_return_status                     => l_return_status,
                x_msg_count                         => l_msg_count,
                x_msg_data                          => l_msg_data,
                p_event_source                      => 'RECEIVING',
                p_event_type_id                     => logical_receive,
                p_rcv_transaction_id                => p_rcv_transaction_id,
                p_inv_distribution_id               => NULL,
                p_po_distribution_id                => rec_pod.po_distribution_id,
                p_direct_delivery_flag              => p_direct_delivery_flag,
                p_gl_group_id                       => p_gl_group_id,
                p_cross_ou_flag                     => l_cross_ou_flag,
                p_procurement_org_flag              => l_procurement_org_flag,
                p_ship_to_org_flag                  => 'Y',
                p_drop_ship_flag                    => l_drop_ship_flag,
                p_org_id                            => l_org_id,
                p_organization_id                   => l_rcv_organization_id,
                p_transfer_org_id                   => l_transfer_org_id,
                p_transfer_organization_id          => l_transfer_organization_id,
                p_trx_flow_header_id                => l_trx_flow_header_id,
                p_transaction_forward_flow_rec      => l_transaction_forward_flow_rec,
                p_transaction_reverse_flow_rec      => l_transaction_reverse_flow_rec,
                p_unit_price                        => NULL,
                p_prior_unit_price                  => NULL,
                x_rcv_accttxn                       => l_rcv_accttxn
               );

            IF l_return_status <> fnd_api.g_ret_sts_success
            THEN
               l_api_message := 'Error creating event';

               IF     g_debug = 'Y'
                  AND fnd_log.level_unexpected >=
                                               fnd_log.g_current_runtime_level
               THEN
                  fnd_log.STRING (fnd_log.level_unexpected,
                                  g_log_head || '.' || l_api_name
                                  || l_stmt_num,
                                     'Create_ReceiveEvents : '
                                  || l_stmt_num
                                  || ' : '
                                  || l_api_message
                                 );
               END IF;

               RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            l_rcv_accttxn_tbl (l_rcv_accttxn_tbl.COUNT + 1) := l_rcv_accttxn;
         ELSE
            l_stmt_num := 130;

            SELECT DECODE (rt.transaction_type, 'CORRECT', correct, receive)
              INTO l_event_type_id
              FROM rcv_transactions rt
             WHERE transaction_id = p_rcv_transaction_id;

            IF     g_debug = 'Y'
               AND fnd_log.level_event >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_event,
                                  g_log_head
                               || '.'
                               || l_api_name
                               || '.'
                               || l_stmt_num,
                               'Not Drop Ship : Seeding Receive in GRAT'
                              );
            END IF;

            l_stmt_num := 140;
            insert_txn
               (p_api_version                       => 1.0,
                x_return_status                     => l_return_status,
                x_msg_count                         => l_msg_count,
                x_msg_data                          => l_msg_data,
                p_event_source                      => 'RECEIVING',
                p_event_type_id                     => l_event_type_id,
                p_rcv_transaction_id                => p_rcv_transaction_id,
                p_inv_distribution_id               => NULL,
                p_po_distribution_id                => rec_pod.po_distribution_id,
                p_direct_delivery_flag              => p_direct_delivery_flag,
                p_gl_group_id                       => p_gl_group_id,
                p_cross_ou_flag                     => l_cross_ou_flag,
                p_procurement_org_flag              => l_procurement_org_flag,
                p_ship_to_org_flag                  => 'Y',
                p_drop_ship_flag                    => l_drop_ship_flag,
                p_org_id                            => l_org_id,
                p_organization_id                   => l_rcv_organization_id,
                p_transfer_org_id                   => l_transfer_org_id,
                p_transfer_organization_id          => l_transfer_organization_id,
                p_trx_flow_header_id                => l_trx_flow_header_id,
                p_transaction_forward_flow_rec      => l_transaction_forward_flow_rec,
                p_transaction_reverse_flow_rec      => l_transaction_reverse_flow_rec,
                p_unit_price                        => NULL,
                p_prior_unit_price                  => NULL,
                x_rcv_accttxn                       => l_rcv_accttxn
               );

            IF l_return_status <> fnd_api.g_ret_sts_success
            THEN
               l_api_message := 'Error creating event';

               IF     g_debug = 'Y'
                  AND fnd_log.level_unexpected >=
                                               fnd_log.g_current_runtime_level
               THEN
                  fnd_log.STRING (fnd_log.level_unexpected,
                                  g_log_head || '.' || l_api_name
                                  || l_stmt_num,
                                     'Create_ReceiveEvents : '
                                  || l_stmt_num
                                  || ' : '
                                  || l_api_message
                                 );
               END IF;

               RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            l_rcv_accttxn_tbl (l_rcv_accttxn_tbl.COUNT + 1) := l_rcv_accttxn;
         END IF;
      END LOOP;

      l_stmt_num := 150;

      IF     g_debug = 'Y'
         AND fnd_log.level_event >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_log_head || '.' || l_api_name || '.' || l_stmt_num,
                         'Inserting transactions into GRAT'
                        );
      END IF;

      insert_txn2 (x_return_status        => l_return_status,
                   x_msg_count            => l_msg_count,
                   x_msg_data             => l_msg_data,
                   p_rcv_accttxn_tbl      => l_rcv_accttxn_tbl
                  );

      IF l_return_status <> fnd_api.g_ret_sts_success
      THEN
         l_api_message := 'Error inserting transactions into GRAT';

         IF     g_debug = 'Y'
            AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_log_head || '.' || l_api_name || l_stmt_num,
                               'Create_ReceiveEvents : '
                            || l_stmt_num
                            || ' : '
                            || l_api_message
                           );
         END IF;

         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF (l_trx_flow_exists_flag = 1 AND l_item_id IS NOT NULL)
      THEN
         l_stmt_num := 160;

         IF     g_debug = 'Y'
            AND fnd_log.level_event >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_event,
                            g_log_head || '.' || l_api_name || '.'
                            || l_stmt_num,
                            'Inserting transactions into MMT'
                           );
         END IF;

         insert_mmt (p_api_version          => 1.0,
                     x_return_status        => l_return_status,
                     x_msg_count            => l_msg_count,
                     x_msg_data             => l_msg_data,
                     p_rcv_accttxn_tbl      => l_rcv_accttxn_tbl
                    );

         IF l_return_status <> fnd_api.g_ret_sts_success
         THEN
            l_api_message := 'Error inserting transactions into MMT';

            IF     g_debug = 'Y'
               AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_unexpected,
                               g_log_head || '.' || l_api_name || l_stmt_num,
                                  'Create_ReceiveEvents : '
                               || l_stmt_num
                               || ' : '
                               || l_api_message
                              );
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      --- Standard check of p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard Call to get message count and if count = 1, get message info
      fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                 p_data       => x_msg_data);

      IF     g_debug = 'Y'
         AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_log_head || '.' || l_api_name || '.end',
                         'Create_ReceiveEvents >>'
                        );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO create_receiveevents_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_receiveevents_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN OTHERS
      THEN
         ROLLBACK TO create_receiveevents_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF     g_debug = 'Y'
            AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_log_head || '.' || l_api_name || l_stmt_num,
                               'Create_ReceiveEvents : '
                            || l_stmt_num
                            || ' : '
                            || SUBSTR (SQLERRM, 1, 200)
                           );
         END IF;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name,
                                        l_api_name
                                     || 'Statement -'
                                     || TO_CHAR (l_stmt_num)
                                    );
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
   END create_receive_txns;

   PROCEDURE create_deliver_txns (
      p_api_version            IN              NUMBER,
      p_init_msg_list          IN              VARCHAR2 := fnd_api.g_false,
      p_commit                 IN              VARCHAR2 := fnd_api.g_false,
      p_validation_level       IN              NUMBER
            := fnd_api.g_valid_level_full,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2,
      p_rcv_transaction_id     IN              NUMBER,
      p_direct_delivery_flag   IN              VARCHAR2,
      p_gl_group_id            IN              NUMBER
   )
   IS
      c_log_module            CONSTANT VARCHAR2 (80)
                                           := module || 'Create_Deliver_Txns';
      l_return_status                  VARCHAR2 (1)
                                                 := fnd_api.g_ret_sts_success;
      l_msg_count                      NUMBER                            := 0;
      l_msg_data                       VARCHAR2 (8000)                  := '';
      l_stmt_num                       NUMBER                            := 0;
      l_api_message                    VARCHAR2 (1000);
      l_api_name              CONSTANT VARCHAR2 (30) := 'Create_Deliver_Txns';
      l_rcv_accttxn                    gmf_rcv_accounting_pkg.rcv_accttxn_rec_type;
      l_rcv_accttxn_tbl                gmf_rcv_accounting_pkg.rcv_accttxn_tbl_type;
      l_event_type_id                  NUMBER;
      l_transaction_flows_tbl          inv_transaction_flow_pub.g_transaction_flow_tbl_type;
      l_transaction_reverse_flow_rec   inv_transaction_flow_pub.mtl_transaction_flow_rec_type
                                                                      := NULL;
      l_trx_flow_exists_flag           NUMBER                            := 0;
      l_trx_flow_ctr                   NUMBER                            := 0;
      l_po_header_id                   NUMBER;
      l_po_distribution_id             NUMBER;
      l_po_org_id                      NUMBER;
      l_po_ledger_id                   NUMBER;
      l_rcv_organization_id            NUMBER;
      l_rcv_org_id                     NUMBER;
      l_transfer_org_id                NUMBER                         := NULL;
      l_transfer_organization_id       NUMBER                         := NULL;
      l_rcv_ledger_id                  NUMBER;
      l_rcv_trx_date                   DATE;
      l_drop_ship_flag                 NUMBER;
      l_destination_type               VARCHAR (25);
      l_category_id                    NUMBER;
      l_project_id                     NUMBER;
      l_cross_ou_flag                  VARCHAR2 (1)                    := 'N';
      l_accrual_flag                   VARCHAR2 (1)                    := 'N';
      l_procurement_org_flag           VARCHAR2 (1)                    := 'Y';
      l_trx_flow_header_id             NUMBER;
      l_qualifier_code_tbl             inv_transaction_flow_pub.number_tbl;
      l_qualifier_value_tbl            inv_transaction_flow_pub.number_tbl;
      l_encumbrance_flag               VARCHAR2 (1);
      l_ussgl_option                   VARCHAR2 (1);
      l_rcv_quantity                   NUMBER := 0;   /* Bug 8517463 */
      l_rcv_transaction_type           VARCHAR2(25);  /* Bug 8517463 */

   BEGIN
      -- Standard start of API savepoint
      SAVEPOINT create_deliver_txns;
      l_stmt_num := 0;

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure, c_log_module, 'Begin...');
      END IF;

      -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      -- Unlike for Receive transactions, for Deliver transactions, the po_distribution_id
      -- is always available.
      l_stmt_num := 20;

      SELECT rt.po_header_id, rt.po_distribution_id,
             pod.destination_type_code, rt.transaction_date,
             NVL (rt.dropship_type_code, 3), poh.org_id,
             poll.ship_to_organization_id, pol.category_id, pol.project_id,
             NVL (poll.accrue_on_receipt_flag, 'N')
        INTO l_po_header_id, l_po_distribution_id,
             l_destination_type, l_rcv_trx_date,
             l_drop_ship_flag, l_po_org_id,
             l_rcv_organization_id, l_category_id, l_project_id,
             l_accrual_flag
        FROM po_headers poh,
             po_line_locations poll,
             po_lines pol,
             po_distributions pod,
             rcv_transactions rt
       WHERE rt.transaction_id = p_rcv_transaction_id
         AND poh.po_header_id = rt.po_header_id
         AND poll.line_location_id = rt.po_line_location_id
         AND pol.po_line_id = rt.po_line_id
         AND pod.po_distribution_id = rt.po_distribution_id;

      l_stmt_num := 30;

      -- Get Receiving Operating Unit and SOB
      SELECT operating_unit, set_of_books_id
        INTO l_rcv_org_id, l_rcv_ledger_id
        FROM org_organization_definitions
       WHERE organization_id = l_rcv_organization_id;

      l_stmt_num := 35;

      -- Get PO SOB
      SELECT set_of_books_id
        INTO l_po_ledger_id
        FROM financials_system_parameters;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         l_api_message :=
               'Creating Deliver transactions : RCV Transaction ID : '
            || p_rcv_transaction_id
            || ', PO Header ID : '
            || l_po_header_id
            || ', PO Dist ID : '
            || l_po_distribution_id
            || ', Destination Type : '
            || l_destination_type
            || ', Transaction Date : '
            || l_rcv_trx_date
            || ', Drop Ship Flag : '
            || l_drop_ship_flag
            || ', PO Org ID : '
            || l_po_org_id
            || ', RCV Organization ID : '
            || l_rcv_organization_id
            || ', RCV Org ID : '
            || l_rcv_org_id
            || ', Project ID : '
            || l_project_id
            || ', Category ID : '
            || l_category_id
            || ', Accrual Flag : '
            || l_accrual_flag;
         fnd_log.STRING (fnd_log.level_statement,
                         c_log_module || '.' || l_stmt_num,
                         l_api_message
                        );
      END IF;

      -- Only create transactions for Deliver transactions for expense destination types. Other
      -- destination types do not have any accounting implications in the Receiving sub-ledger.
      IF (l_destination_type <> 'EXPENSE')
      THEN
         RETURN;
      END IF;

      IF (l_po_org_id <> l_rcv_org_id)
      THEN
         l_cross_ou_flag := 'Y';
      END IF;

      -- Get transaction flow when procuring and receiving operating units are different.
      -- However, for POs with destination type of expense, when there is a project on the
      -- PO, we should not look for transaction flow. This is because PA,(which transfers
      -- costs to Projects for expense destinations), is currently not supporting global
      -- procurement.
      IF (l_cross_ou_flag = 'Y' AND l_project_id IS NULL)
      THEN
         /* For 11i10, the only supported qualifier is category id. */
         l_qualifier_code_tbl (l_qualifier_code_tbl.COUNT + 1) :=
                                    inv_transaction_flow_pub.g_qualifier_code;
         l_qualifier_value_tbl (l_qualifier_value_tbl.COUNT + 1) :=
                                                                l_category_id;

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
         THEN
            l_api_message :=
                  'Getting Procurement Transaction Flow :'
               || 'l_po_org_id : '
               || l_po_org_id
               || ' l_rcv_org_id : '
               || l_rcv_org_id
               || ' l_rcv_organization_id : '
               || l_rcv_organization_id;
            fnd_log.STRING (fnd_log.level_statement,
                            c_log_module || '.' || l_stmt_num,
                            l_api_message
                           );
         END IF;

         inv_transaction_flow_pub.get_transaction_flow
               (x_return_status               => l_return_status,
                x_msg_data                    => l_msg_data,
                x_msg_count                   => l_msg_count,
                x_transaction_flows_tbl       => l_transaction_flows_tbl,
                p_api_version                 => 1.0,
                p_start_operating_unit        => l_po_org_id,
                p_end_operating_unit          => l_rcv_org_id,
                p_flow_type                   => inv_transaction_flow_pub.g_procuring_flow_type,
                p_organization_id             => l_rcv_organization_id,
                p_qualifier_code_tbl          => l_qualifier_code_tbl,
                p_qualifier_value_tbl         => l_qualifier_value_tbl,
                p_transaction_date            => l_rcv_trx_date,
                p_get_default_cost_group      => 'N'
               );

         IF (l_return_status = fnd_api.g_ret_sts_success)
         THEN
            l_procurement_org_flag := 'N';
            l_trx_flow_exists_flag := 1;
            l_trx_flow_header_id :=
               l_transaction_flows_tbl (l_transaction_flows_tbl.FIRST).header_id;
            l_trx_flow_ctr := l_transaction_flows_tbl.COUNT;
            l_transaction_reverse_flow_rec :=
                                     l_transaction_flows_tbl (l_trx_flow_ctr);
            l_transfer_org_id := l_transaction_reverse_flow_rec.from_org_id;
            l_transfer_organization_id :=
                          l_transaction_reverse_flow_rec.from_organization_id;
         ELSIF (l_return_status = 'W')
         THEN
            l_trx_flow_exists_flag := 0;

            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING (fnd_log.level_event,
                               c_log_module || '.' || l_stmt_num,
                               'Transaction Flow does not exist'
                              );
            END IF;

            -- If transaction flow does not exist, but the PO crosses multiple
            -- sets of books, error out the transaction.
            IF (l_po_ledger_id <> l_rcv_ledger_id)
            THEN
               l_api_message := 'Transaction Flow does not exist';

               IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING (fnd_log.level_unexpected,
                                  c_log_module || '.' || l_stmt_num,
                                  l_api_message
                                 );
               END IF;

               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
         ELSE
            l_api_message := 'Error occurred in Transaction Flow API';

            IF     g_debug = 'Y'
               AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_unexpected,
                               g_log_head || '.' || l_api_name || l_stmt_num,
                                  'Create_DeliverEvents : '
                               || l_stmt_num
                               || ' : '
                               || l_api_message
                              );
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
         END IF;                                          -- End if ret_status
      END IF;                                         -- End cross_ou_flag = Y

      l_stmt_num := 50;

    /* Begin Bug 8517463 */

      /* Following SELECT commented and substituted with subsequent code */
      /*
      SELECT DECODE (rt.transaction_type, 'CORRECT', correct, deliver)
        INTO l_event_type_id
        FROM rcv_transactions rt
       WHERE transaction_id = p_rcv_transaction_id;
      */

      SELECT NVL(quantity,0), transaction_type
      INTO   l_rcv_quantity, l_rcv_transaction_type
      FROM   rcv_transactions rt
      WHERE  transaction_id = p_rcv_transaction_id;

      IF l_rcv_transaction_type = 'CORRECT' THEN
         IF l_rcv_quantity < 0 THEN
           l_event_type_id := return_to_receiving;
         ELSIF l_rcv_quantity > 0 THEN
           l_event_type_id := deliver;
         ELSE
           l_event_type_id := correct;
         END IF;
      ELSE
         l_event_type_id := deliver;
      END IF;

    /* End Bug 8517463 */


      l_stmt_num := 60;

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         c_log_module || '.' || l_stmt_num,
                         'Seeding Deliver Txn'
                        );
      END IF;

      insert_txn
            (p_api_version                       => 1.0,
             x_return_status                     => l_return_status,
             x_msg_count                         => l_msg_count,
             x_msg_data                          => l_msg_data,
             p_event_source                      => 'RECEIVING',
             p_event_type_id                     => l_event_type_id,
             p_rcv_transaction_id                => p_rcv_transaction_id,
             p_inv_distribution_id               => NULL,
             p_po_distribution_id                => l_po_distribution_id,
             p_direct_delivery_flag              => p_direct_delivery_flag,
             p_gl_group_id                       => p_gl_group_id,
             p_cross_ou_flag                     => l_cross_ou_flag,
             p_procurement_org_flag              => l_procurement_org_flag,
             p_ship_to_org_flag                  => 'Y',
             p_drop_ship_flag                    => l_drop_ship_flag,
             p_org_id                            => l_rcv_org_id,
             p_organization_id                   => l_rcv_organization_id,
             p_transfer_org_id                   => l_transfer_org_id,
             p_transfer_organization_id          => l_transfer_organization_id,
             p_trx_flow_header_id                => l_trx_flow_header_id,
             p_transaction_forward_flow_rec      => NULL,
             p_transaction_reverse_flow_rec      => l_transaction_reverse_flow_rec,
             p_unit_price                        => NULL,
             p_prior_unit_price                  => NULL,
             x_rcv_accttxn                       => l_rcv_accttxn
            );

      /* Begin Bug 8517463 */
      IF ( l_rcv_transaction_type = 'CORRECT' AND
           l_event_type_id = return_to_receiving ) THEN
         l_rcv_accttxn.transaction_quantity := -1*l_rcv_accttxn.transaction_quantity;
         l_rcv_accttxn.primary_quantity     := -1*l_rcv_accttxn.primary_quantity;
         l_rcv_accttxn.source_doc_quantity  := -1*l_rcv_accttxn.source_doc_quantity;
      END IF;
      /* End Bug 8517463 */

      IF l_return_status <> fnd_api.g_ret_sts_success
      THEN
         l_api_message := 'Error creating Txn';

         IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            c_log_module || '.' || l_stmt_num,
                            l_api_message
                           );
         END IF;

         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_rcv_accttxn_tbl (l_rcv_accttxn_tbl.COUNT + 1) := l_rcv_accttxn;

      -- Encumbrance cannot be enabled for global procurement scenarios.
      IF l_trx_flow_exists_flag = 0
      THEN
         l_stmt_num := 70;

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_event,
                            c_log_module || '.' || l_stmt_num,
                            'Checking if encumbrance txns need to be created'
                           );
         END IF;

         -- Reuse existing check
         check_encumbranceflag (p_api_version           => 1.0,
                                x_return_status         => l_return_status,
                                x_msg_count             => l_msg_count,
                                x_msg_data              => l_msg_data,
                                p_rcv_ledger_id         => l_rcv_ledger_id,
                                x_encumbrance_flag      => l_encumbrance_flag,
                                x_ussgl_option          => l_ussgl_option
                               );

         IF l_return_status <> fnd_api.g_ret_sts_success
         THEN
            l_api_message := 'Error in checking for encumbrance flag ';

            IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
               )
            THEN
               fnd_log.STRING (fnd_log.level_unexpected,
                               c_log_module || '.' || l_stmt_num,
                               l_api_message
                              );
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
         THEN
            l_api_message := 'Encumbrance Flag : ' || l_encumbrance_flag;
            fnd_log.STRING (fnd_log.level_statement,
                            c_log_module || '.' || l_stmt_num,
                            l_api_message
                           );
         END IF;

         IF (l_encumbrance_flag = 'Y')
         THEN
            l_stmt_num := 80;

            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING (fnd_log.level_event,
                               c_log_module || '.' || l_stmt_num,
                               'Seeding Encumbrance Reversal Txn'
                              );
            END IF;

            insert_txn
               (p_api_version                       => 1.0,
                x_return_status                     => l_return_status,
                x_msg_count                         => l_msg_count,
                x_msg_data                          => l_msg_data,
                p_event_source                      => 'RECEIVING',
                p_event_type_id                     => encumbrance_reversal,
                p_rcv_transaction_id                => p_rcv_transaction_id,
                p_inv_distribution_id               => NULL,
                p_po_distribution_id                => l_po_distribution_id,
                p_direct_delivery_flag              => p_direct_delivery_flag,
                p_gl_group_id                       => p_gl_group_id,
                p_cross_ou_flag                     => l_cross_ou_flag,
                p_procurement_org_flag              => l_procurement_org_flag,
                p_ship_to_org_flag                  => 'Y',
                p_drop_ship_flag                    => l_drop_ship_flag,
                p_org_id                            => l_rcv_org_id,
                p_organization_id                   => l_rcv_organization_id,
                p_transfer_org_id                   => NULL,
                p_transfer_organization_id          => NULL,
                p_trx_flow_header_id                => NULL,
                p_transaction_forward_flow_rec      => NULL,
                p_transaction_reverse_flow_rec      => l_transaction_reverse_flow_rec,
                p_unit_price                        => NULL,
                p_prior_unit_price                  => NULL,
                x_rcv_accttxn                       => l_rcv_accttxn
               );

             /**
            Bug #3333610. In the case of encumbrance reversals, the quantity to unencumber
            may turn out to be zero if the quantity delivered is greater than the quantity
            ordered. In such a situation, we should not error out the event.
            **/
            IF l_return_status = fnd_api.g_ret_sts_success
            THEN
               l_rcv_accttxn_tbl (l_rcv_accttxn_tbl.COUNT + 1) :=
                                                                l_rcv_accttxn;
            ELSIF l_return_status <> 'W'
            THEN
               l_api_message := 'Error in seeding encumbrance reversal event';

               IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING (fnd_log.level_unexpected,
                                  c_log_module || '.' || l_stmt_num,
                                  l_api_message
                                 );
               END IF;

               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
         END IF;                                      -- end if encum_flag = y
      END IF;                               -- end if trx_flow_exists_flag = 0

      l_stmt_num := 90;

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         c_log_module || '.' || l_stmt_num,
                         'Inserting txns into GRAT'
                        );
      END IF;

      insert_txn2 (x_return_status        => l_return_status,
                   x_msg_count            => l_msg_count,
                   x_msg_data             => l_msg_data,
                   p_rcv_accttxn_tbl      => l_rcv_accttxn_tbl
                  );

      IF l_return_status <> fnd_api.g_ret_sts_success
      THEN
         l_api_message := 'Error inserting txns into GRAT';

         IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            c_log_module || l_stmt_num,
                            l_api_message
                           );
         END IF;

         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard Call to get message count and if count = 1, get message info
      fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                 p_data       => x_msg_data);

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure, c_log_module, '...End');
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO create_deliver_txns;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_deliver_txns;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN OTHERS
      THEN
         ROLLBACK TO create_deliver_txns;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            c_log_module || '.' || l_stmt_num,
                            SUBSTR (SQLERRM, 1, 200)
                           );
         END IF;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name,
                                        l_api_name
                                     || 'Statement -'
                                     || TO_CHAR (l_stmt_num)
                                    );
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
   END create_deliver_txns;

   PROCEDURE create_rtr_txns (
      p_api_version            IN              NUMBER := 1.0,
      p_init_msg_list          IN              VARCHAR2 := fnd_api.g_false,
      p_commit                 IN              VARCHAR2 := fnd_api.g_false,
      p_validation_level       IN              NUMBER
            := fnd_api.g_valid_level_full,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2,
      p_rcv_transaction_id     IN              NUMBER,
      p_direct_delivery_flag   IN              VARCHAR2,
      p_gl_group_id            IN              NUMBER
   )
   IS
      l_api_name              CONSTANT VARCHAR2 (30)     := 'Create_RTR_Txns';
      l_api_version           CONSTANT NUMBER                          := 1.0;
      l_return_status                  VARCHAR2 (1)
                                                 := fnd_api.g_ret_sts_success;
      l_msg_count                      NUMBER                            := 0;
      l_msg_data                       VARCHAR2 (8000)                  := '';
      l_stmt_num                       NUMBER                            := 0;
      l_api_message                    VARCHAR2 (1000);
      l_rcv_accttxn                    gmf_rcv_accounting_pkg.rcv_accttxn_rec_type;
      l_rcv_accttxn_tbl                gmf_rcv_accounting_pkg.rcv_accttxn_tbl_type;
      l_event_type_id                  NUMBER;
      l_transaction_flows_tbl          inv_transaction_flow_pub.g_transaction_flow_tbl_type;
      l_transaction_reverse_flow_rec   inv_transaction_flow_pub.mtl_transaction_flow_rec_type
                                                                      := NULL;
      l_trx_flow_exists_flag           NUMBER                            := 0;
      l_trx_flow_ctr                   NUMBER                            := 0;
      l_po_header_id                   NUMBER;
      l_po_distribution_id             NUMBER;
      l_po_org_id                      NUMBER;
      l_po_ledger_id                   NUMBER;
      l_rcv_organization_id            NUMBER;
      l_rcv_org_id                     NUMBER;
      l_transfer_org_id                NUMBER                         := NULL;
      l_transfer_organization_id       NUMBER                         := NULL;
      l_rcv_ledger_id                  NUMBER;
      l_rcv_trx_date                   DATE;
      l_drop_ship_flag                 NUMBER;
      l_destination_type               VARCHAR (25);
      l_category_id                    NUMBER;
      l_project_id                     NUMBER;
      l_cross_ou_flag                  VARCHAR2 (1)                    := 'N';
      l_accrual_flag                   VARCHAR2 (1)                    := 'N';
      l_procurement_org_flag           VARCHAR2 (1)                    := 'Y';
      l_trx_flow_header_id             NUMBER;
      l_qualifier_code_tbl             inv_transaction_flow_pub.number_tbl;
      l_qualifier_value_tbl            inv_transaction_flow_pub.number_tbl;
      l_encumbrance_flag               VARCHAR2 (1);
      l_ussgl_option                   VARCHAR2 (1);
   BEGIN
      -- Standard start of API savepoint
      SAVEPOINT create_rtrevents_pvt;
      l_stmt_num := 0;

      IF     g_debug = 'Y'
         AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_log_head || '.' || l_api_name || '.begin',
                         'Create_RTREvents <<'
                        );
      END IF;

      -- Standard call to check for call compatibility
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      -- Unlike for RTV transactions, for RTR transactions, the po_distribution_id
      -- is always available.
      l_stmt_num := 20;

      SELECT rt.po_header_id, rt.po_distribution_id,
             pod.destination_type_code, rt.transaction_date,
             NVL (rt.dropship_type_code, 3), poh.org_id,
             poll.ship_to_organization_id, pol.category_id, pol.project_id,
             NVL (poll.accrue_on_receipt_flag, 'N')
        INTO l_po_header_id, l_po_distribution_id,
             l_destination_type, l_rcv_trx_date,
             l_drop_ship_flag, l_po_org_id,
             l_rcv_organization_id, l_category_id, l_project_id,
             l_accrual_flag
        FROM po_headers poh,
             po_line_locations poll,
             po_lines pol,
             po_distributions pod,
             rcv_transactions rt
       WHERE rt.transaction_id = p_rcv_transaction_id
         AND poh.po_header_id = rt.po_header_id
         AND poll.line_location_id = rt.po_line_location_id
         AND pol.po_line_id = rt.po_line_id
         AND pod.po_distribution_id = rt.po_distribution_id;

      l_stmt_num := 30;

      -- Get Receiving Operating Unit and SOB
      SELECT operating_unit, set_of_books_id
        INTO l_rcv_org_id, l_rcv_ledger_id
        FROM cst_organization_definitions cod
       WHERE organization_id = l_rcv_organization_id;

      l_stmt_num := 35;

      -- Get PO SOB
      SELECT set_of_books_id
        INTO l_po_ledger_id
        FROM financials_system_parameters;

      IF     g_debug = 'Y'
         AND fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         l_api_message :=
               'Creating RTR transactions : RCV Transaction ID : '
            || p_rcv_transaction_id
            || ', PO Header ID : '
            || l_po_header_id
            || ', PO Dist ID : '
            || l_po_distribution_id
            || ', Destination Type : '
            || l_destination_type
            || ', Transaction Date : '
            || l_rcv_trx_date
            || ', Drop Ship Flag : '
            || l_drop_ship_flag
            || ', PO Org ID : '
            || l_po_org_id
            || ', PO LEDGER ID : '
            || l_po_ledger_id
            || ', RCV Organization ID : '
            || l_rcv_organization_id
            || ', RCV Org ID : '
            || l_rcv_org_id
            || ', RCV LEDGER ID : '
            || l_rcv_ledger_id
            || ', Project ID : '
            || l_project_id
            || ', Category ID : '
            || l_category_id
            || ', Accrual Flag : '
            || l_accrual_flag;
         fnd_log.STRING (fnd_log.level_statement,
                         g_log_head || '.' || l_api_name || '.' || l_stmt_num,
                         l_api_message
                        );
      END IF;

      -- Only create transactions for RTR transactions for expense destination types. Other
      -- destination types do not have any accounting implications in the Receiving sub-ledger.
      IF (l_destination_type <> 'EXPENSE')
      THEN
         RETURN;
      END IF;

      IF (l_po_org_id <> l_rcv_org_id)
      THEN
         l_cross_ou_flag := 'Y';
      END IF;

      -- Get transaction flow when procuring and receiving operating units are different.
      -- However, for POs with destination type of expense, when there is a project on the
      -- PO, we should not look for transaction flow. This is because PA,(which transfers
      -- costs to Projects for expense destinations), is currently not supporting global
      -- procurement.
      IF (l_cross_ou_flag = 'Y' AND l_project_id IS NULL)
      THEN
         /* For 11i10, the only supported qualifier is category id. */
         l_qualifier_code_tbl (l_qualifier_code_tbl.COUNT + 1) :=
                                    inv_transaction_flow_pub.g_qualifier_code;
         l_qualifier_value_tbl (l_qualifier_value_tbl.COUNT + 1) :=
                                                                l_category_id;
         l_stmt_num := 40;

         IF     g_debug = 'Y'
            AND fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            l_api_message :=
                  'Getting Procurement Transaction Flow :'
               || 'l_po_org_id : '
               || l_po_org_id
               || ' l_rcv_org_id : '
               || l_rcv_org_id
               || ' l_rcv_organization_id : '
               || l_rcv_organization_id;
            fnd_log.STRING (fnd_log.level_statement,
                            g_log_head || '.' || l_api_name || '.'
                            || l_stmt_num,
                            l_api_message
                           );
         END IF;

         inv_transaction_flow_pub.get_transaction_flow
               (x_return_status               => l_return_status,
                x_msg_data                    => l_msg_data,
                x_msg_count                   => l_msg_count,
                x_transaction_flows_tbl       => l_transaction_flows_tbl,
                p_api_version                 => 1.0,
                p_start_operating_unit        => l_po_org_id,
                p_end_operating_unit          => l_rcv_org_id,
                p_flow_type                   => inv_transaction_flow_pub.g_procuring_flow_type,
                p_organization_id             => l_rcv_organization_id,
                p_qualifier_code_tbl          => l_qualifier_code_tbl,
                p_qualifier_value_tbl         => l_qualifier_value_tbl,
                p_transaction_date            => l_rcv_trx_date,
                p_get_default_cost_group      => 'N'
               );

         IF (l_return_status = fnd_api.g_ret_sts_success)
         THEN
            l_procurement_org_flag := 'N';
            l_trx_flow_exists_flag := 1;
            l_trx_flow_header_id :=
               l_transaction_flows_tbl (l_transaction_flows_tbl.FIRST).header_id;
            l_trx_flow_ctr := l_transaction_flows_tbl.COUNT;
            l_transaction_reverse_flow_rec :=
                                     l_transaction_flows_tbl (l_trx_flow_ctr);
            l_transfer_org_id := l_transaction_reverse_flow_rec.from_org_id;
            l_transfer_organization_id :=
                          l_transaction_reverse_flow_rec.from_organization_id;
         ELSIF (l_return_status = 'W')
         THEN
            l_trx_flow_exists_flag := 0;

            IF     g_debug = 'Y'
               AND fnd_log.level_event >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_event,
                                  g_log_head
                               || '.'
                               || l_api_name
                               || '.'
                               || l_stmt_num,
                               'Transaction Flow does not exist'
                              );
            END IF;

            -- If transaction flow does not exist, but the PO crosses multiple
            -- sets of books, error out the transaction.
            IF (l_po_ledger_id <> l_rcv_ledger_id)
            THEN
               l_api_message := 'Transaction Flow does not exist';

               IF     g_debug = 'Y'
                  AND fnd_log.level_unexpected >=
                                               fnd_log.g_current_runtime_level
               THEN
                  fnd_log.STRING (fnd_log.level_unexpected,
                                  g_log_head || '.' || l_api_name
                                  || l_stmt_num,
                                     'Create_RTREvents : '
                                  || l_stmt_num
                                  || ' : '
                                  || l_api_message
                                 );
               END IF;

               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
         ELSE
            l_api_message := 'Error occurred in Transaction Flow API';

            IF     g_debug = 'Y'
               AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_unexpected,
                               g_log_head || '.' || l_api_name || l_stmt_num,
                                  'Create_RTREvents : '
                               || l_stmt_num
                               || ' : '
                               || l_api_message
                              );
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      l_stmt_num := 50;

      SELECT DECODE (rt.transaction_type,
                     'CORRECT', correct,
                     return_to_receiving
                    )
        INTO l_event_type_id
        FROM rcv_transactions rt
       WHERE transaction_id = p_rcv_transaction_id;

      l_stmt_num := 60;

      IF     g_debug = 'Y'
         AND fnd_log.level_event >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_log_head || '.' || l_api_name || '.' || l_stmt_num,
                         'Seeding RTR Event'
                        );
      END IF;

      insert_txn
            (p_api_version                       => 1.0,
             x_return_status                     => l_return_status,
             x_msg_count                         => l_msg_count,
             x_msg_data                          => l_msg_data,
             p_event_source                      => 'RECEIVING',
             p_event_type_id                     => l_event_type_id,
             p_rcv_transaction_id                => p_rcv_transaction_id,
             p_inv_distribution_id               => NULL,
             p_po_distribution_id                => l_po_distribution_id,
             p_direct_delivery_flag              => p_direct_delivery_flag,
             p_gl_group_id                       => p_gl_group_id,
             p_cross_ou_flag                     => l_cross_ou_flag,
             p_procurement_org_flag              => l_procurement_org_flag,
             p_ship_to_org_flag                  => 'Y',
             p_drop_ship_flag                    => l_drop_ship_flag,
             p_org_id                            => l_rcv_org_id,
             p_organization_id                   => l_rcv_organization_id,
             p_transfer_org_id                   => l_transfer_org_id,
             p_transfer_organization_id          => l_transfer_organization_id,
             p_trx_flow_header_id                => l_trx_flow_header_id,
             p_transaction_forward_flow_rec      => NULL,
             p_transaction_reverse_flow_rec      => l_transaction_reverse_flow_rec,
             p_unit_price                        => NULL,
             p_prior_unit_price                  => NULL,
             x_rcv_accttxn                       => l_rcv_accttxn
            );
      l_rcv_accttxn_tbl (l_rcv_accttxn_tbl.COUNT + 1) := l_rcv_accttxn;

      IF l_return_status <> fnd_api.g_ret_sts_success
      THEN
         l_api_message := 'Error creating event';

         IF     g_debug = 'Y'
            AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_log_head || '.' || l_api_name || l_stmt_num,
                               'Create_RTREvents : '
                            || l_stmt_num
                            || ' : '
                            || l_api_message
                           );
         END IF;

         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF l_trx_flow_exists_flag = 0
      THEN
         l_stmt_num := 70;

         IF     g_debug = 'Y'
            AND fnd_log.level_event >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING
                   (fnd_log.level_event,
                    g_log_head || '.' || l_api_name || '.' || l_stmt_num,
                    'Checking if encumbrance transactions need to be seeded.'
                   );
         END IF;

         check_encumbranceflag (p_api_version           => 1.0,
                                x_return_status         => l_return_status,
                                x_msg_count             => l_msg_count,
                                x_msg_data              => l_msg_data,
                                p_rcv_ledger_id         => l_rcv_ledger_id,
                                x_encumbrance_flag      => l_encumbrance_flag,
                                x_ussgl_option          => l_ussgl_option
                               );

         IF l_return_status <> fnd_api.g_ret_sts_success
         THEN
            l_api_message := 'Error in checking for encumbrance flag ';

            IF     g_debug = 'Y'
               AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_unexpected,
                               g_log_head || '.' || l_api_name || l_stmt_num,
                                  'Create_RTREvents : '
                               || l_stmt_num
                               || ' : '
                               || l_api_message
                              );
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         IF     g_debug = 'Y'
            AND fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            l_api_message := 'Encumbrance Flag : ' || l_encumbrance_flag;
            fnd_log.STRING (fnd_log.level_statement,
                            g_log_head || '.' || l_api_name || '.'
                            || l_stmt_num,
                            l_api_message
                           );
         END IF;

         IF (l_encumbrance_flag = 'Y')
         THEN
            l_stmt_num := 80;

            IF     g_debug = 'Y'
               AND fnd_log.level_event >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_event,
                                  g_log_head
                               || '.'
                               || l_api_name
                               || '.'
                               || l_stmt_num,
                               'Seeding Encumbrance Reversal Event'
                              );
            END IF;

            insert_txn
               (x_return_status                     => l_return_status,
                x_msg_count                         => l_msg_count,
                x_msg_data                          => l_msg_data,
                p_event_source                      => 'RECEIVING',
                p_event_type_id                     => encumbrance_reversal,
                p_rcv_transaction_id                => p_rcv_transaction_id,
                p_inv_distribution_id               => NULL,
                p_po_distribution_id                => l_po_distribution_id,
                p_direct_delivery_flag              => p_direct_delivery_flag,
                p_gl_group_id                       => p_gl_group_id,
                p_cross_ou_flag                     => l_cross_ou_flag,
                p_procurement_org_flag              => l_procurement_org_flag,
                p_ship_to_org_flag                  => 'Y',
                p_drop_ship_flag                    => l_drop_ship_flag,
                p_org_id                            => l_rcv_org_id,
                p_organization_id                   => l_rcv_organization_id,
                p_transfer_org_id                   => NULL,
                p_transfer_organization_id          => NULL,
                p_trx_flow_header_id                => NULL,
                p_transaction_forward_flow_rec      => NULL,
                p_transaction_reverse_flow_rec      => l_transaction_reverse_flow_rec,
                p_unit_price                        => NULL,
                p_prior_unit_price                  => NULL,
                x_rcv_accttxn                       => l_rcv_accttxn
               );

            /* Bug #3333610. In the case of encumbrance reversals, the quantity to unencumber
               may turn out to be zero if the quantity delivered is greater than the quantity
               ordered. In such a situation, we should not error out the event. */
            IF l_return_status = fnd_api.g_ret_sts_success
            THEN
               l_rcv_accttxn_tbl (l_rcv_accttxn_tbl.COUNT + 1) :=
                                                                l_rcv_accttxn;
            ELSIF l_return_status <> 'W'
            THEN
               l_api_message := 'Error in seeding encumbrance reversal event';

               IF     g_debug = 'Y'
                  AND fnd_log.level_unexpected >=
                                               fnd_log.g_current_runtime_level
               THEN
                  fnd_log.STRING (fnd_log.level_unexpected,
                                  g_log_head || '.' || l_api_name
                                  || l_stmt_num,
                                     'Create_RTREvents : '
                                  || l_stmt_num
                                  || ' : '
                                  || l_api_message
                                 );
               END IF;

               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
         END IF;
      END IF;

      l_stmt_num := 90;

      IF     g_debug = 'Y'
         AND fnd_log.level_event >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_log_head || '.' || l_api_name || '.' || l_stmt_num,
                         'Inserting transactions into GRAT'
                        );
      END IF;

      insert_txn2 (x_return_status        => l_return_status,
                   x_msg_count            => l_msg_count,
                   x_msg_data             => l_msg_data,
                   p_rcv_accttxn_tbl      => l_rcv_accttxn_tbl
                  );

      IF l_return_status <> fnd_api.g_ret_sts_success
      THEN
         l_api_message := 'Error inserting transactions into GRAT';

         IF     g_debug = 'Y'
            AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_log_head || '.' || l_api_name || l_stmt_num,
                               'Create_RTREvents : '
                            || l_stmt_num
                            || ' : '
                            || l_api_message
                           );
         END IF;

         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Standard check of p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard Call to get message count and if count = 1, get message info
      fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                 p_data       => x_msg_data);

      IF     g_debug = 'Y'
         AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_log_head || '.' || l_api_name || '.end',
                         'Create_RTREvents >>'
                        );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO create_rtrevents_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_rtrevents_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN OTHERS
      THEN
         ROLLBACK TO create_rtrevents_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF     g_debug = 'Y'
            AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_log_head || '.' || l_api_name || l_stmt_num,
                               'Create_RTREvents : '
                            || l_stmt_num
                            || ' : '
                            || SUBSTR (SQLERRM, 1, 200)
                           );
         END IF;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name,
                                        l_api_name
                                     || 'Statement -'
                                     || TO_CHAR (l_stmt_num)
                                    );
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
   END create_rtr_txns;

-- Start of comments
--      API name        : Create_RTVEvents
--      Type            : Private
--      Function        : To seed accounting transactions for RETURN TO VENDOR transactions.
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
--                              p_gl_group_id           IN NUMBER       Optional
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--
--
--      Notes           : This API creates all accounting transactions for RETURN TO VENDOR transactions
--                        in gmf_rcv_accounting_txns.
--
-- End of comments
   PROCEDURE create_rtv_txns (
      p_api_version            IN              NUMBER := 1.0,
      p_init_msg_list          IN              VARCHAR2 := fnd_api.g_false,
      p_commit                 IN              VARCHAR2 := fnd_api.g_false,
      p_validation_level       IN              NUMBER
            := fnd_api.g_valid_level_full,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2,
      p_rcv_transaction_id     IN              NUMBER,
      p_direct_delivery_flag   IN              VARCHAR2,
      p_gl_group_id            IN              NUMBER
   )
   IS
      l_api_name              CONSTANT VARCHAR2 (30)     := 'Create_RTV_Txns';
      l_api_version           CONSTANT NUMBER                          := 1.0;
      l_return_status                  VARCHAR2 (1)
                                                 := fnd_api.g_ret_sts_success;
      l_msg_count                      NUMBER                            := 0;
      l_msg_data                       VARCHAR2 (8000)                  := '';
      l_stmt_num                       NUMBER                            := 0;
      l_api_message                    VARCHAR2 (1000);
      l_rcv_accttxn                    gmf_rcv_accounting_pkg.rcv_accttxn_rec_type;
      l_rcv_accttxn_tbl                gmf_rcv_accounting_pkg.rcv_accttxn_tbl_type;
      l_event_type_id                  NUMBER;
      l_transaction_flows_tbl          inv_transaction_flow_pub.g_transaction_flow_tbl_type;
      l_transaction_forward_flow_rec   inv_transaction_flow_pub.mtl_transaction_flow_rec_type;
      l_transaction_reverse_flow_rec   inv_transaction_flow_pub.mtl_transaction_flow_rec_type;
      l_trx_flow_exists_flag           NUMBER                            := 0;
      l_trx_flow_ctr                   NUMBER                            := 0;
      l_po_header_id                   NUMBER;
      l_po_line_id                     NUMBER;
      l_po_line_location_id            NUMBER;
      l_po_distribution_id             NUMBER;
      l_po_org_id                      NUMBER;
      l_po_ledger_id                   NUMBER;
      l_rcv_organization_id            NUMBER;
      l_rcv_org_id                     NUMBER;
      l_rcv_ledger_id                  NUMBER;
      l_org_id                         NUMBER;
      l_transfer_org_id                NUMBER;
      l_transfer_organization_id       NUMBER;
      l_rcv_trx_date                   DATE;
      l_drop_ship_flag                 NUMBER;
      l_destination_type               VARCHAR (25);
      l_item_id                        NUMBER;
      l_category_id                    NUMBER;
      l_project_id                     NUMBER;
      l_cross_ou_flag                  VARCHAR2 (1);
      l_accrual_flag                   VARCHAR2 (1);
      l_counter                        NUMBER;
      l_procurement_org_flag           VARCHAR2 (1);
      l_trx_flow_header_id             NUMBER;
      l_qualifier_code_tbl             inv_transaction_flow_pub.number_tbl;
      l_qualifier_value_tbl            inv_transaction_flow_pub.number_tbl;

      CURSOR c_po_distributions_csr (
         p_po_distribution_id    NUMBER,
         p_po_line_location_id   NUMBER
      )
      IS
         SELECT po_distribution_id, destination_type_code, project_id
           FROM po_distributions pod
          WHERE pod.po_distribution_id =
                           NVL (p_po_distribution_id, pod.po_distribution_id)
            AND pod.line_location_id = p_po_line_location_id;
   BEGIN
      -- Standard start of API savepoint
      SAVEPOINT create_rtvevents_pvt;
      l_stmt_num := 0;

      IF     g_debug = 'Y'
         AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_log_head || '.' || l_api_name || '.begin',
                         'Create_RTVEvents <<'
                        );
      END IF;

      -- Standard call to check for call compatibility
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      l_stmt_num := 20;

      SELECT rt.po_header_id, rt.po_line_id, rt.po_line_location_id,
             rt.po_distribution_id, rt.transaction_date,
             NVL (rt.dropship_type_code, 3), poh.org_id,
             poll.ship_to_organization_id, pol.item_id, pol.category_id,
             pol.project_id, NVL (poll.accrue_on_receipt_flag, 'N')
        INTO l_po_header_id, l_po_line_id, l_po_line_location_id,
             l_po_distribution_id, l_rcv_trx_date,
             l_drop_ship_flag, l_po_org_id,
             l_rcv_organization_id, l_item_id, l_category_id,
             l_project_id, l_accrual_flag
        FROM po_headers poh,
             po_line_locations poll,
             po_lines pol,
             rcv_transactions rt
       WHERE rt.transaction_id = p_rcv_transaction_id
         AND poh.po_header_id = rt.po_header_id
         AND poll.line_location_id = rt.po_line_location_id
         AND pol.po_line_id = rt.po_line_id;

      l_stmt_num := 30;

      -- Get Receiving Operating Unit
      SELECT operating_unit, set_of_books_id
        INTO l_rcv_org_id, l_rcv_ledger_id
        FROM cst_organization_definitions cod
       WHERE organization_id = l_rcv_organization_id;

      l_stmt_num := 35;

      -- Get PO SOB
      SELECT set_of_books_id
        INTO l_po_ledger_id
        FROM financials_system_parameters;

      l_stmt_num := 40;

      IF     g_debug = 'Y'
         AND fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         l_api_message :=
               'Creating RTV transactions : RCV Transaction ID : '
            || p_rcv_transaction_id
            || ', PO Header ID : '
            || l_po_header_id
            || ', PO Line ID : '
            || l_po_line_id
            || ', PO Line Location ID : '
            || l_po_line_location_id
            || ', PO Dist ID : '
            || l_po_distribution_id
            || ', Transaction Date : '
            || l_rcv_trx_date
            || ', Drop Ship Flag : '
            || l_drop_ship_flag
            || ', PO Org ID : '
            || l_po_org_id
            || ', PO Ledger ID : '
            || l_po_ledger_id
            || ', RCV Organization ID : '
            || l_rcv_organization_id
            || ', RCV Org ID : '
            || l_rcv_org_id
            || ', RCV Ledger ID : '
            || l_rcv_ledger_id
            || ', Category ID : '
            || l_category_id
            || ', Accrual Flag : '
            || l_accrual_flag;
         fnd_log.STRING (fnd_log.level_statement,
                         g_log_head || '.' || l_api_name || '.' || l_stmt_num,
                         l_api_message
                        );
      END IF;

      IF (l_po_org_id = l_rcv_org_id)
      THEN
         l_cross_ou_flag := 'N';
      ELSE
         l_cross_ou_flag := 'Y';
         /* For 11i10, the only supported qualifier is category id. */
         l_qualifier_code_tbl (l_qualifier_code_tbl.COUNT + 1) :=
                                    inv_transaction_flow_pub.g_qualifier_code;
         l_qualifier_value_tbl (l_qualifier_value_tbl.COUNT + 1) :=
                                                                l_category_id;
         l_stmt_num := 50;

         IF     g_debug = 'Y'
            AND fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            l_api_message :=
                  'Getting Procurement Transaction Flow :'
               || 'l_po_org_id : '
               || l_po_org_id
               || ' l_rcv_org_id : '
               || l_rcv_org_id
               || ' l_rcv_organization_id : '
               || l_rcv_organization_id;
            fnd_log.STRING (fnd_log.level_statement,
                            g_log_head || '.' || l_api_name || '.'
                            || l_stmt_num,
                            l_api_message
                           );
         END IF;

         inv_transaction_flow_pub.get_transaction_flow
               (x_return_status               => l_return_status,
                x_msg_data                    => l_msg_data,
                x_msg_count                   => l_msg_count,
                x_transaction_flows_tbl       => l_transaction_flows_tbl,
                p_api_version                 => 1.0,
                p_start_operating_unit        => l_po_org_id,
                p_end_operating_unit          => l_rcv_org_id,
                p_flow_type                   => inv_transaction_flow_pub.g_procuring_flow_type,
                p_organization_id             => l_rcv_organization_id,
                p_qualifier_code_tbl          => l_qualifier_code_tbl,
                p_qualifier_value_tbl         => l_qualifier_value_tbl,
                p_transaction_date            => l_rcv_trx_date,
                p_get_default_cost_group      => 'N'
               );

         IF (l_return_status = fnd_api.g_ret_sts_success)
         THEN
            l_trx_flow_exists_flag := 1;
            l_trx_flow_header_id :=
               l_transaction_flows_tbl (l_transaction_flows_tbl.FIRST).header_id;
         -- Return Status of 'W' indicates that no transaction flow exists.
         ELSIF (l_return_status = 'W')
         THEN
            l_trx_flow_exists_flag := 0;

            IF     g_debug = 'Y'
               AND fnd_log.level_event >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_event,
                                  g_log_head
                               || '.'
                               || l_api_name
                               || '.'
                               || l_stmt_num,
                               'Transaction Flow does not exist'
                              );
            END IF;

            -- If transaction flow does not exist, but the PO crosses multiple
            -- sets of books, error out the transaction.
            IF (l_po_ledger_id <> l_rcv_ledger_id)
            THEN
               l_api_message := 'Transaction Flow does not exist';

               IF     g_debug = 'Y'
                  AND fnd_log.level_unexpected >=
                                               fnd_log.g_current_runtime_level
               THEN
                  fnd_log.STRING (fnd_log.level_unexpected,
                                  g_log_head || '.' || l_api_name
                                  || l_stmt_num,
                                     'Create_RTVEvents : '
                                  || l_stmt_num
                                  || ' : '
                                  || l_api_message
                                 );
               END IF;

               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
         ELSE
            l_api_message := 'Error occurred in Transaction Flow API';

            IF     g_debug = 'Y'
               AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_unexpected,
                               g_log_head || '.' || l_api_name || l_stmt_num,
                                  'Create_RTVEvents : '
                               || l_stmt_num
                               || ' : '
                               || l_api_message
                              );
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
         END IF;                                         -- IF l_return_status
      END IF;                                                -- IF l_po_org_id

      -- For the RTV transaction, the PO distribution may not be available in the
      -- case of Standard Receipt. Hence perform all steps for each applicable distribution.
      -- If distribution is not available the quantity will be prorated. Furthermore, if
      -- there is a project on any of the distributions, and the destination_type_code is
      -- expense, the transaction flow should be ignored for just that distribution.
      FOR rec_pod IN c_po_distributions_csr (l_po_distribution_id,
                                             l_po_line_location_id
                                            )
      LOOP
         l_stmt_num := 50;

         IF     g_debug = 'Y'
            AND fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            l_api_message :=
                  'Creating  transactions : '
               || 'po_distribution_id : '
               || rec_pod.po_distribution_id
               || ' destination_type_code : '
               || rec_pod.destination_type_code
               || ' project_id : '
               || rec_pod.project_id;
            fnd_log.STRING (fnd_log.level_statement,
                            g_log_head || '.' || l_api_name || '.'
                            || l_stmt_num,
                            l_api_message
                           );
         END IF;

         l_procurement_org_flag := 'Y';

         -- For POs with destination type of expense, when there is a project on the
         -- POD, we should not look for transaction flow. This is because PA,(which transfers
         -- costs to Projects for expense destinations), is currently not supporting global
         -- procurement.
         IF (    (l_trx_flow_exists_flag = 1)
             AND (   rec_pod.project_id IS NULL
                  OR rec_pod.destination_type_code <> 'EXPENSE'
                 )
            )
         THEN
            l_trx_flow_ctr := l_transaction_flows_tbl.COUNT;

            -- Create Logical RTV transactions in each intermediate organization.
            FOR l_counter IN
               l_transaction_flows_tbl.FIRST .. l_transaction_flows_tbl.LAST
            LOOP
               IF     g_debug = 'Y'
                  AND fnd_log.level_event >= fnd_log.g_current_runtime_level
               THEN
                  fnd_log.STRING (fnd_log.level_event,
                                     g_log_head
                                  || '.'
                                  || l_api_name
                                  || '.'
                                  || l_stmt_num,
                                  'Seeding Logical RTV in GRAT'
                                 );
               END IF;

               l_stmt_num := 60;
               -- l_transaction_forward_flow_rec contains the transaction flow record
               -- where the org_id is the from_org_id.
               -- l_transaction_reverse_flow_rec contains the transaction flow record
               -- where the org_id is the to_org_id.
               -- Need to pass both to the Seed_GRAT procedure because transfer_price is based
               -- on the reverse flow record and some accounts are based on the forward flow
               l_transaction_forward_flow_rec :=
                                           l_transaction_flows_tbl (l_counter);

               IF (l_counter = l_transaction_flows_tbl.FIRST)
               THEN
                  l_transaction_reverse_flow_rec := NULL;
                  l_transfer_org_id := NULL;
                  l_transfer_organization_id := NULL;
               ELSE
                  l_transaction_reverse_flow_rec :=
                                      l_transaction_flows_tbl (l_counter - 1);
                  l_transfer_org_id :=
                                   l_transaction_reverse_flow_rec.from_org_id;
                  l_transfer_organization_id :=
                          l_transaction_reverse_flow_rec.from_organization_id;
               END IF;

               insert_txn
                  (x_return_status                     => l_return_status,
                   x_msg_count                         => l_msg_count,
                   x_msg_data                          => l_msg_data,
                   p_event_source                      => 'RECEIVING',
                   p_event_type_id                     => logical_return_to_vendor,
                   p_rcv_transaction_id                => p_rcv_transaction_id,
                   p_inv_distribution_id               => NULL,
                   p_po_distribution_id                => rec_pod.po_distribution_id,
                   p_direct_delivery_flag              => p_direct_delivery_flag,
                   p_gl_group_id                       => p_gl_group_id,
                   p_cross_ou_flag                     => l_cross_ou_flag,
                   p_procurement_org_flag              => l_procurement_org_flag,
                   p_ship_to_org_flag                  => 'N',
                   p_drop_ship_flag                    => l_drop_ship_flag,
                   p_org_id                            => l_transaction_flows_tbl
                                                                    (l_counter).from_org_id,
                   p_organization_id                   => l_transaction_flows_tbl
                                                                    (l_counter).from_organization_id,
                   p_transfer_org_id                   => l_transfer_org_id,
                   p_transfer_organization_id          => l_transfer_organization_id,
                   p_trx_flow_header_id                => l_trx_flow_header_id,
                   p_transaction_forward_flow_rec      => l_transaction_forward_flow_rec,
                   p_transaction_reverse_flow_rec      => l_transaction_reverse_flow_rec,
                   p_unit_price                        => NULL,
                   p_prior_unit_price                  => NULL,
                   x_rcv_accttxn                       => l_rcv_accttxn
                  );

               IF l_return_status <> fnd_api.g_ret_sts_success
               THEN
                  l_api_message := 'Error creating event';

                  IF     g_debug = 'Y'
                     AND fnd_log.level_unexpected >=
                                               fnd_log.g_current_runtime_level
                  THEN
                     fnd_log.STRING (fnd_log.level_unexpected,
                                        g_log_head
                                     || '.'
                                     || l_api_name
                                     || l_stmt_num,
                                        'Create_RTVEvents : '
                                     || l_stmt_num
                                     || ' : '
                                     || l_api_message
                                    );
                  END IF;

                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;

               l_rcv_accttxn_tbl (l_rcv_accttxn_tbl.COUNT + 1) :=
                                                                 l_rcv_accttxn;

               -- For one-time items, if online accruals is used, seed IC Invoice event.
               -- For Shop Floor destination types, always seed IC Invoice events.
               IF (   (l_item_id IS NULL AND l_accrual_flag = 'Y')
                   OR (rec_pod.destination_type_code = 'SHOP FLOOR')
                  )
               THEN
                  l_stmt_num := 70;

                  IF     g_debug = 'Y'
                     AND fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                  THEN
                     fnd_log.STRING (fnd_log.level_event,
                                        g_log_head
                                     || '.'
                                     || l_api_name
                                     || '.'
                                     || l_stmt_num,
                                     'Seeding Invoice Match in GRAT'
                                    );
                  END IF;

                  insert_txn
                     (x_return_status                     => l_return_status,
                      x_msg_count                         => l_msg_count,
                      x_msg_data                          => l_msg_data,
                      p_event_source                      => 'RECEIVING',
                      p_event_type_id                     => intercompany_reversal,
                      p_rcv_transaction_id                => p_rcv_transaction_id,
                      p_inv_distribution_id               => NULL,
                      p_po_distribution_id                => rec_pod.po_distribution_id,
                      p_direct_delivery_flag              => p_direct_delivery_flag,
                      p_gl_group_id                       => NULL,
                      p_cross_ou_flag                     => l_cross_ou_flag,
                      p_procurement_org_flag              => l_procurement_org_flag,
                      p_ship_to_org_flag                  => 'N',
                      p_drop_ship_flag                    => l_drop_ship_flag,
                      p_org_id                            => l_transaction_flows_tbl
                                                                    (l_counter).from_org_id,
                      p_organization_id                   => l_transaction_flows_tbl
                                                                    (l_counter).from_organization_id,
                      p_transfer_org_id                   => l_transaction_flows_tbl
                                                                    (l_counter).to_org_id,
                      p_transfer_organization_id          => l_transaction_flows_tbl
                                                                    (l_counter).to_organization_id,
                      p_trx_flow_header_id                => l_trx_flow_header_id,
                      p_transaction_forward_flow_rec      => l_transaction_forward_flow_rec,
                      p_transaction_reverse_flow_rec      => l_transaction_reverse_flow_rec,
                      p_unit_price                        => NULL,
                      p_prior_unit_price                  => NULL,
                      x_rcv_accttxn                       => l_rcv_accttxn
                     );

                  IF l_return_status <> fnd_api.g_ret_sts_success
                  THEN
                     l_api_message := 'Error creating event';

                     IF     g_debug = 'Y'
                        AND fnd_log.level_unexpected >=
                                               fnd_log.g_current_runtime_level
                     THEN
                        fnd_log.STRING (fnd_log.level_unexpected,
                                           g_log_head
                                        || '.'
                                        || l_api_name
                                        || l_stmt_num,
                                           'Create_RTVEvents : '
                                        || l_stmt_num
                                        || ' : '
                                        || l_api_message
                                       );
                     END IF;

                     RAISE fnd_api.g_exc_unexpected_error;
                  END IF;

                  l_rcv_accttxn_tbl (l_rcv_accttxn_tbl.COUNT + 1) :=
                                                                 l_rcv_accttxn;
               END IF;

               l_procurement_org_flag := 'N';
            END LOOP;
         END IF;

         l_stmt_num := 80;

         IF (l_trx_flow_exists_flag = 1)
         THEN
            l_transaction_forward_flow_rec := NULL;
            l_transaction_reverse_flow_rec :=
                                     l_transaction_flows_tbl (l_trx_flow_ctr);
            l_org_id := l_transaction_flows_tbl (l_trx_flow_ctr).to_org_id;
            l_transfer_org_id :=
                         l_transaction_flows_tbl (l_trx_flow_ctr).from_org_id;
            l_transfer_organization_id :=
                          l_transaction_reverse_flow_rec.from_organization_id;
         ELSE
            l_transaction_forward_flow_rec := NULL;
            l_transaction_reverse_flow_rec := NULL;
            l_org_id := l_po_org_id;
            l_transfer_org_id := NULL;
            l_transfer_organization_id := NULL;
         END IF;

         l_stmt_num := 90;
         -- The drop ship flag is not applicable in the case of returns. There will always
         -- be a physical receipt in the procuring org.
         l_stmt_num := 110;

         SELECT DECODE (rt.transaction_type,
                        'CORRECT', correct,
                        return_to_vendor
                       )
           INTO l_event_type_id
           FROM rcv_transactions rt
          WHERE transaction_id = p_rcv_transaction_id;

         IF     g_debug = 'Y'
            AND fnd_log.level_event >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_event,
                            g_log_head || '.' || l_api_name || '.'
                            || l_stmt_num,
                            'Seeding RTV in GRAT'
                           );
         END IF;

         l_stmt_num := 120;
         insert_txn
            (x_return_status                     => l_return_status,
             x_msg_count                         => l_msg_count,
             x_msg_data                          => l_msg_data,
             p_event_source                      => 'RECEIVING',
             p_event_type_id                     => l_event_type_id,
             p_rcv_transaction_id                => p_rcv_transaction_id,
             p_inv_distribution_id               => NULL,
             p_po_distribution_id                => rec_pod.po_distribution_id,
             p_direct_delivery_flag              => p_direct_delivery_flag,
             p_gl_group_id                       => p_gl_group_id,
             p_cross_ou_flag                     => l_cross_ou_flag,
             p_procurement_org_flag              => l_procurement_org_flag,
             p_ship_to_org_flag                  => 'Y',
             p_drop_ship_flag                    => l_drop_ship_flag,
             p_org_id                            => l_org_id,
             p_organization_id                   => l_rcv_organization_id,
             p_transfer_org_id                   => l_transfer_org_id,
             p_transfer_organization_id          => l_transfer_organization_id,
             p_trx_flow_header_id                => l_trx_flow_header_id,
             p_transaction_forward_flow_rec      => l_transaction_forward_flow_rec,
             p_transaction_reverse_flow_rec      => l_transaction_reverse_flow_rec,
             p_unit_price                        => NULL,
             p_prior_unit_price                  => NULL,
             x_rcv_accttxn                       => l_rcv_accttxn
            );

         IF l_return_status <> fnd_api.g_ret_sts_success
         THEN
            l_api_message := 'Error creating event';

            IF     g_debug = 'Y'
               AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_unexpected,
                               g_log_head || '.' || l_api_name || l_stmt_num,
                                  'Create_RTVEvents : '
                               || l_stmt_num
                               || ' : '
                               || l_api_message
                              );
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         l_rcv_accttxn_tbl (l_rcv_accttxn_tbl.COUNT + 1) := l_rcv_accttxn;
      END LOOP;

      l_stmt_num := 130;

      IF     g_debug = 'Y'
         AND fnd_log.level_event >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_log_head || '.' || l_api_name || '.' || l_stmt_num,
                         'Inserting transactions into GRAT'
                        );
      END IF;

      insert_txn2 (x_return_status        => l_return_status,
                   x_msg_count            => l_msg_count,
                   x_msg_data             => l_msg_data,
                   p_rcv_accttxn_tbl      => l_rcv_accttxn_tbl
                  );

      IF l_return_status <> fnd_api.g_ret_sts_success
      THEN
         l_api_message := 'Error inserting transactions into GRAT';

         IF     g_debug = 'Y'
            AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_log_head || '.' || l_api_name || l_stmt_num,
                               'Create_RTVEvents : '
                            || l_stmt_num
                            || ' : '
                            || l_api_message
                           );
         END IF;

         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF (l_trx_flow_exists_flag = 1 AND l_item_id IS NOT NULL)
      THEN
         l_stmt_num := 140;

         IF     g_debug = 'Y'
            AND fnd_log.level_event >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_event,
                            g_log_head || '.' || l_api_name || '.'
                            || l_stmt_num,
                            'Inserting transactions into MMT'
                           );
         END IF;

         insert_mmt (p_api_version          => 1.0,
                     x_return_status        => l_return_status,
                     x_msg_count            => l_msg_count,
                     x_msg_data             => l_msg_data,
                     p_rcv_accttxn_tbl      => l_rcv_accttxn_tbl
                    );

         IF l_return_status <> fnd_api.g_ret_sts_success
         THEN
            l_api_message := 'Error inserting transactions into MMT';

            IF     g_debug = 'Y'
               AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_unexpected,
                               g_log_head || '.' || l_api_name || l_stmt_num,
                                  'Create_RTVEvents : '
                               || l_stmt_num
                               || ' : '
                               || l_api_message
                              );
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      -- Standard check of p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard Call to get message count and if count = 1, get message info
      fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                 p_data       => x_msg_data);

      IF     g_debug = 'Y'
         AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_log_head || '.' || l_api_name || '.end',
                         'Create_RTVEvents >>'
                        );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO create_rtvevents_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_rtvevents_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN OTHERS
      THEN
         ROLLBACK TO create_rtvevents_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF     g_debug = 'Y'
            AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_log_head || '.' || l_api_name || l_stmt_num,
                               'Create_RTVEvents : '
                            || l_stmt_num
                            || ' : '
                            || SUBSTR (SQLERRM, 1, 200)
                           );
         END IF;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name,
                                        l_api_name
                                     || 'Statement -'
                                     || TO_CHAR (l_stmt_num)
                                    );
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
   END create_rtv_txns;

   PROCEDURE create_accounting_txns (
      p_api_version            IN              NUMBER,
      p_init_msg_list          IN              VARCHAR2,
      p_commit                 IN              VARCHAR2,
      p_validation_level       IN              NUMBER,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2,
      p_source_type	       IN VARCHAR2,
      p_rcv_transaction_id     IN              NUMBER,
      p_direct_delivery_flag   IN              VARCHAR2
   )
   IS
      c_log_module   CONSTANT VARCHAR2 (80)
                                       := module || '.create_accounting_txns';
      l_stmt_num              NUMBER (10)                                := 0;
      l_consigned_flag        rcv_transactions.consigned_flag%TYPE;
      l_source_doc_code       rcv_transactions.source_document_code%TYPE;
      l_transaction_type      rcv_transactions.transaction_type%TYPE;
      l_parent_trx_id         rcv_transactions.transaction_id%TYPE;
      l_parent_trx_type       rcv_transactions.transaction_type%TYPE;
      l_grparent_trx_id       rcv_transactions.transaction_id%TYPE;
      l_grparent_trx_type     rcv_transactions.transaction_type%TYPE;
      l_po_header_id          po_headers_all.po_header_id%TYPE;
      l_po_line_location_id   po_line_locations_all.line_location_id%TYPE;
      l_shipment_type         po_line_locations_all.shipment_type%TYPE;
      l_rcv_accttxn_tbl       gmf_rcv_accounting_pkg.rcv_accttxn_tbl_type;
      l_api_version           NUMBER                                   := 1.0;
      l_return_status         VARCHAR2 (100);
      l_msg_count             NUMBER (38);
      l_msg_data              VARCHAR2 (4000);
      l_api_message           VARCHAR2 (4000);
      l_api_name              VARCHAR2 (30)       := 'CREATE_ACCOUNTING_TXNS';

      p_gl_group_id	NUMBER := NULL;  /* Should be removed */

   BEGIN
      SAVEPOINT s_create_accounting_txns;

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure, c_log_module, 'Begin...');
      END IF;

      -- Standard call to check for call compatibility
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      SELECT rt.consigned_flag, rt.source_document_code, rt.transaction_type,
             rt.parent_transaction_id, rt.po_header_id,
             rt.po_line_location_id             --12i Complex Work Procurement
        INTO l_consigned_flag, l_source_doc_code, l_transaction_type,
             l_parent_trx_id, l_po_header_id,
             l_po_line_location_id              --12i Complex Work Procurement
        FROM rcv_transactions rt
       WHERE transaction_id = p_rcv_transaction_id;

      -- If receiving transaction is for a REQ, or an RMA, we do not
      -- do not do any accounting.
      IF (l_source_doc_code <> 'PO')
      THEN
         RETURN;
      END IF;

      IF (l_transaction_type IN ('UNORDERED', 'ACCEPT', 'REJECT', 'TRANSFER')
         )
      THEN
         RETURN;
      END IF;

      IF (l_parent_trx_id NOT IN (0, -1))
      THEN
         l_stmt_num := 60;

-- Get Parent Transaction Type
         SELECT transaction_type, parent_transaction_id
           INTO l_parent_trx_type, l_grparent_trx_id
           FROM rcv_transactions
          WHERE transaction_id = l_parent_trx_id;

         IF (l_grparent_trx_id NOT IN (0, -1))
         THEN
            l_stmt_num := 70;

            -- Get Grand Parent Transaction Type
            SELECT transaction_type
              INTO l_grparent_trx_type
              FROM rcv_transactions
             WHERE transaction_id = l_grparent_trx_id;
         END IF;
      END IF;

      IF (    (   l_transaction_type = 'CORRECT'
               OR l_transaction_type = 'RETURN TO VENDOR'
              )
          AND (l_parent_trx_type = 'UNORDERED')
         )
      THEN
         RETURN;
      END IF;

      IF (    (l_transaction_type = 'CORRECT')
          AND (l_parent_trx_type = 'RETURN TO VENDOR')
          AND (l_grparent_trx_type = 'UNORDERED')
         )
      THEN
         RETURN;
      END IF;

/* Bug 8910852 : moved following code from above*/
	   -- r12: complex work procurement
      -- Exclude any transactions whose POLL.shipment_type = 'PREPAYMENT'
      SELECT shipment_type
        INTO l_shipment_type
        FROM po_line_locations
       WHERE line_location_id = l_po_line_location_id;

      IF (l_shipment_type = 'PREPAYMENT')
      THEN
         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
               (fnd_log.level_statement,
                c_log_module,
                'Shipment Type is Prepayment. No Receive accounting required'
               );
         END IF;

         RETURN;
      END IF;

	  /*Bug 8910852 End */

      IF (   (l_transaction_type = 'RECEIVE')
          OR (l_transaction_type = 'MATCH')
          OR (l_transaction_type = 'CORRECT' AND l_parent_trx_type = 'RECEIVE'
             )
          OR (l_transaction_type = 'CORRECT' AND l_parent_trx_type = 'MATCH'
             )
         )
      THEN
         l_stmt_num := 80;

         IF     g_debug = 'Y'
            AND fnd_log.level_event >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_event,
                            c_log_module || '.' || l_stmt_num,
                            'Creating txns For RECEIVE transaction'
                           );
         END IF;

         create_receive_txns
                            (p_api_version               => 1.0,
                             x_return_status             => l_return_status,
                             x_msg_count                 => l_msg_count,
                             x_msg_data                  => l_msg_data,
                             p_rcv_transaction_id        => p_rcv_transaction_id,
                             p_direct_delivery_flag      => p_direct_delivery_flag,
                             p_gl_group_id               => p_gl_group_id
                            );
      ELSIF (   (l_transaction_type = 'DELIVER')
             OR (    l_transaction_type = 'CORRECT'
                 AND l_parent_trx_type = 'DELIVER'
                )
            )
      THEN
         l_stmt_num := 90;

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_event,
                            c_log_module || l_stmt_num,
                            'Creating Txns For DELIVER transaction'
                           );
         END IF;

         create_deliver_txns
                            (p_api_version               => 1.0,
                             x_return_status             => l_return_status,
                             x_msg_count                 => l_msg_count,
                             x_msg_data                  => l_msg_data,
                             p_rcv_transaction_id        => p_rcv_transaction_id,
                             p_direct_delivery_flag      => p_direct_delivery_flag,
                             p_gl_group_id               => p_gl_group_id
                            );
      ELSIF (   (l_transaction_type = 'RETURN TO RECEIVING')
             OR (    l_transaction_type = 'CORRECT'
                 AND l_parent_trx_type = 'RETURN TO RECEIVING'
                )
            )
      THEN
         l_stmt_num := 100;

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                         (fnd_log.level_event,
                          c_log_module || l_stmt_num,
                          'Creating Txns For RETURN TO RECEIVING transaction'
                         );
         END IF;

         create_rtr_txns (x_return_status             => l_return_status,
                          x_msg_count                 => l_msg_count,
                          x_msg_data                  => l_msg_data,
                          p_rcv_transaction_id        => p_rcv_transaction_id,
                          p_direct_delivery_flag      => p_direct_delivery_flag,
                          p_gl_group_id               => p_gl_group_id
                         );
      ELSIF (   (l_transaction_type = 'RETURN TO VENDOR')
             OR (    l_transaction_type = 'CORRECT'
                 AND l_parent_trx_type = 'RETURN TO VENDOR'
                )
            )
      THEN
         l_stmt_num := 110;

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                    (fnd_log.level_event,
                     c_log_module || l_stmt_num,
                     'Creating transactions For RETURN TO VENDOR transaction'
                    );
         END IF;

         create_rtv_txns (x_return_status             => l_return_status,
                          x_msg_count                 => l_msg_count,
                          x_msg_data                  => l_msg_data,
                          p_rcv_transaction_id        => p_rcv_transaction_id,
                          p_direct_delivery_flag      => p_direct_delivery_flag,
                          p_gl_group_id               => p_gl_group_id
                         );
      END IF;

      IF l_return_status <> fnd_api.g_ret_sts_success
      THEN
         l_api_message := 'Error creating event';

         IF     g_debug = 'Y'
            AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            c_log_module || l_stmt_num,
                               'Create_ReceivingEvents : '
                            || l_stmt_num
                            || ' : '
                            || l_api_message
                           );
         END IF;

         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_stmt_num := 120;

      --- Standard check of p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard Call to get message count and if count = 1, get message info
      fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                 p_data       => x_msg_data);

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure, c_log_module, '...End');
      END IF;

   EXCEPTION
      -- rseshadr - return error back to caller
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO s_create_accounting_txns;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN OTHERS
      THEN
         ROLLBACK TO s_create_accounting_txns;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF     g_debug = 'Y'
            AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_log_head || '.' || l_api_name || l_stmt_num,
                               'Create_Accounting_Txns : '
                            || l_stmt_num
                            || ' : '
                            || SUBSTR (SQLERRM, 1, 200)
                           );
         END IF;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name,
                                        l_api_name
                                     || 'Statement -'
                                     || TO_CHAR (l_stmt_num)
                                    );
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );

   END create_accounting_txns;

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
--                        in GMF_RCV_ACCOUNTING_TXNS. For online accruals, it also generates
--                        the accounting entries for the event.
--
-- End of comments
-------------------------------------------------------------------------------
   PROCEDURE create_adjust_txns (
      p_api_version           IN              NUMBER,
      p_init_msg_list         IN              VARCHAR2,
      p_commit                IN              VARCHAR2,
      p_validation_level      IN              NUMBER,
      x_return_status         OUT NOCOPY      VARCHAR2,
      x_msg_count             OUT NOCOPY      NUMBER,
      x_msg_data              OUT NOCOPY      VARCHAR2,
      p_po_header_id          IN              NUMBER,
      p_po_release_id         IN              NUMBER,
      p_po_line_id            IN              NUMBER,
      p_po_line_location_id   IN              NUMBER,
      p_old_po_price          IN              NUMBER,
      p_new_po_price          IN              NUMBER
   )
   IS
      l_api_name      CONSTANT VARCHAR2 (30)          := 'Create_Adjust_Txns';
      l_api_version   CONSTANT NUMBER                                  := 1.0;
      l_return_status          VARCHAR2 (1)      := fnd_api.g_ret_sts_success;
      l_msg_count              NUMBER                                    := 0;
      l_msg_data               VARCHAR2 (8000)                          := '';
      l_stmt_num               NUMBER                                    := 0;
      l_api_message            VARCHAR2 (1000);
      l_rcv_accttxn            gmf_rcv_accounting_pkg.rcv_accttxn_rec_type;
      l_rcv_accttxn_tbl        gmf_rcv_accounting_pkg.rcv_accttxn_tbl_type;
      l_rae_count              NUMBER;
-- 12i Complex Work Procurement------------------------------------
      l_matching_basis         po_line_locations.matching_basis%TYPE;
      l_shipment_type          po_line_locations.shipment_type%TYPE;
-------------------------------------------------------------------
      l_proc_operating_unit    NUMBER;
      l_po_distribution_id     NUMBER;
      l_organization_id        NUMBER;
      l_rcv_quantity           NUMBER                                    := 0;
      l_delived_quantity       NUMBER                                    := 0;
      l_trx_flow_header_id     NUMBER                                 := NULL;
      l_drop_ship_flag         NUMBER                                 := NULL;
      l_opm_flag               NUMBER;
      l_cr_flag                BOOLEAN;
      l_process_enabled_flag   mtl_parameters.process_enabled_flag%TYPE; /* INVCONV ANTHIYAG Bug#5529309 18-Sep-2006 */

-- Cursor to get all parent receive transactions
-- for a given po_header or po_release
      CURSOR c_parent_receive_txns_csr
      IS
      SELECT      a.transaction_id, a.organization_id
      FROM        rcv_transactions a, mtl_parameters b
      WHERE       (
                  (a.transaction_type = 'RECEIVE' AND a.parent_transaction_id = -1)
                  OR
                  a.transaction_type = 'MATCH'
                  )
      AND         NVL (a.consigned_flag, 'N') <> 'Y'
      AND         a.po_header_id = p_po_header_id
      AND         a.organization_id = b.organization_id
      AND         NVL(b.process_enabled_flag, 'N') = 'Y'
      AND         a.po_line_location_id = p_po_line_location_id
      AND         NVL (a.po_release_id, -1) = NVL (p_po_release_id, -1);

-- Cursor to get all deliver transactions for
-- a parent receive transaction.
      CURSOR c_deliver_txns_csr (l_par_txn IN NUMBER)
      IS
      SELECT      a.transaction_id, a.po_distribution_id
      FROM        rcv_transactions a, mtl_parameters b
      WHERE       a.transaction_type = 'DELIVER'
      AND         a.organization_id = b.organization_id
      AND         NVL(b.process_enabled_flag, 'N') = 'Y'
      AND         a.parent_transaction_id = l_par_txn;

-- Cursor to get all distributions corresponding
-- to a po_line_location.
-- The PO line location corresponds to the parent rcv_transaction
      CURSOR c_po_dists_csr (l_rcv_txn IN NUMBER)
      IS
         SELECT pod.po_distribution_id
           FROM po_distributions pod,
                po_line_locations poll,
                rcv_transactions rt
          WHERE pod.line_location_id = poll.line_location_id
            AND poll.line_location_id = rt.po_line_location_id
            AND rt.transaction_id = l_rcv_txn;
   BEGIN

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
     IF nvl(l_process_enabled_flag, 'N') <> 'Y' THEN
       x_return_status := fnd_api.g_ret_sts_success;
       x_msg_count := 0;
       x_msg_data := NULL;
       RETURN;
     END IF;
/* INVCONV ANTHIYAG Bug#5529309 18-Sep-2006 End */

      -- Standard start of API savepoint
      SAVEPOINT create_adjust_txns_pvt;
      l_stmt_num := 0;

      IF     g_debug = 'Y'
         AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_log_head || '.' || l_api_name || '.begin',
                         'Create_Adjust_Txns <<'
                        );
      END IF;

      -- Standard call to check for call compatibility
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- If the old and new price are the same, return
      IF p_old_po_price = p_new_po_price
      THEN
         IF     g_debug = 'Y'
            AND fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING
               (fnd_log.level_statement,
                g_log_head || '.' || l_api_name,
                'Old and New Prices are same. No Adjust Transactions created'
               );
         END IF;

         RETURN;
      END IF;

      -- If OPM PO and Common Purchasing is installed, we do not do any
      -- accounting.
      l_stmt_num := 5;
      l_opm_flag := gml_opm_po.check_opm_po (p_po_header_id);
      l_stmt_num := 10;
      l_cr_flag := gml_po_for_process.check_po_for_proc;

      IF (l_opm_flag = 1 AND l_cr_flag = FALSE)
      THEN
         RETURN;
      END IF;

      l_stmt_num := 20;

      -- Get Matching Basis and Shipment Type
      SELECT poll.matching_basis, poll.shipment_type
        INTO l_matching_basis, l_shipment_type
        FROM po_line_locations poll
       WHERE poll.line_location_id = p_po_line_location_id;

      l_stmt_num := 30;

      -- If Line Type is Service (matching basis = AMOUNT), then return without doing anything
      IF (l_matching_basis IS NOT NULL AND l_matching_basis = 'AMOUNT')
      THEN
         IF     g_debug = 'Y'
            AND fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING
                         (fnd_log.level_statement,
                          g_log_head || '.' || l_api_name,
                          'Service Line Type. No Adjust Transactions created'
                         );
         END IF;

         RETURN;
      END IF;

      l_stmt_num := 35;

      -- If Shipment Type is Prepayment, then return without doing anything
      IF (l_shipment_type = 'PREPAYMENT')
      THEN
         IF     g_debug = 'Y'
            AND fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING
               (fnd_log.level_statement,
                g_log_head || '.' || l_api_name,
                'Shipment Type is Prepayment. No Adjust Transactions created'
               );
         END IF;

         RETURN;
      END IF;

      l_stmt_num := 40;

      -- Get Procuring operating unit
      SELECT org_id
        INTO l_proc_operating_unit
        FROM po_headers
       WHERE po_header_id = p_po_header_id;

      -- Loop Through all Parent Transactions
      FOR c_par_txn IN c_parent_receive_txns_csr
      LOOP
         -- Get the Organization in which event is to be seeded
         -- Get the row in GRAT with the RCV_TRANSACTION as that of the parent txn
         -- and procurement_org_flag = 'Y'
         l_stmt_num := 50;

         SELECT COUNT (*)
           INTO l_rae_count
           FROM gmf_rcv_accounting_txns
          WHERE rcv_transaction_id = c_par_txn.transaction_id;

         IF l_rae_count > 0
         THEN
            -- Rownum check is there since there might be multiple events in
            -- GRAT for a particular Receive transaction in RCV_TRANSACTIONS
            l_stmt_num := 60;

            SELECT grat.organization_id, grat.trx_flow_header_id,
                   NVL (rt.dropship_type_code, 3)
              INTO l_organization_id, l_trx_flow_header_id,
                   l_drop_ship_flag
              FROM gmf_rcv_accounting_txns grat, rcv_transactions rt
             WHERE grat.rcv_transaction_id = c_par_txn.transaction_id
               AND rt.transaction_id = grat.rcv_transaction_id
               AND grat.procurement_org_flag = 'Y'
               AND ROWNUM = 1;
         ELSE
            l_organization_id := c_par_txn.organization_id;
         END IF;

         -- One event is seeded per PO distribution
         -- If RCV_TRANSACTIONS has the po_distribution_id populated, we
         -- use that. Otherwise, we use cursor c_po_dists_csr to seed as many events
         -- as the number of distributions for the line_location
         l_stmt_num := 70;

         SELECT NVL (po_distribution_id, -1)
           INTO l_po_distribution_id
           FROM rcv_transactions
          WHERE transaction_id = c_par_txn.transaction_id;

         IF l_po_distribution_id <> -1
         THEN
            l_stmt_num := 80;
            insert_txn (x_return_status                     => l_return_status,
                        x_msg_count                         => l_msg_count,
                        x_msg_data                          => l_msg_data,
                        p_event_source                      => 'RETROPRICE',
                        p_event_type_id                     => adjust_receive,
                        p_rcv_transaction_id                => c_par_txn.transaction_id,
                        p_inv_distribution_id               => NULL,
                        p_po_distribution_id                => l_po_distribution_id,
                        p_direct_delivery_flag              => NULL,
                        p_gl_group_id                       => NULL,
                        p_cross_ou_flag                     => NULL,
                        p_procurement_org_flag              => 'Y',
                        p_ship_to_org_flag                  => NULL,
                        p_drop_ship_flag                    => l_drop_ship_flag,
                        p_org_id                            => l_proc_operating_unit,
                        p_organization_id                   => l_organization_id,
                        p_transfer_org_id                   => NULL,
                        p_transfer_organization_id          => NULL,
                        p_trx_flow_header_id                => l_trx_flow_header_id,
                        p_transaction_forward_flow_rec      => NULL,
                        p_transaction_reverse_flow_rec      => NULL,
                        p_unit_price                        => p_new_po_price,
                        p_prior_unit_price                  => p_old_po_price,
                        x_rcv_accttxn                       => l_rcv_accttxn
                       );

            -- Suppose there is no net quantity for this receipt (all received quantity has been
            -- returned), there is no need to seed an event, since there is no accrual to adjust.
            -- If transaction quantity is 0, the Insert_Txn API will return a warning. In the
            -- case of Adjust events, this warning is normal and should be ignored.
            IF (l_return_status = fnd_api.g_ret_sts_success)
            THEN
               l_rcv_accttxn_tbl (l_rcv_accttxn_tbl.COUNT + 1) :=
                                                                l_rcv_accttxn;
            ELSIF (l_return_status <> 'W')
            THEN
               l_api_message := 'Error seeding Transactions';

               IF     g_debug = 'Y'
                  AND fnd_log.level_unexpected >=
                                               fnd_log.g_current_runtime_level
               THEN
                  fnd_log.STRING (fnd_log.level_unexpected,
                                  g_log_head || '.' || l_api_name
                                  || l_stmt_num,
                                     'Create_Adjust_Txns : '
                                  || l_stmt_num
                                  || ' : '
                                  || l_api_message
                                 );
               END IF;

               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
         ELSE
            FOR c_po_dist IN c_po_dists_csr (c_par_txn.transaction_id)
            LOOP
               l_stmt_num := 90;
               insert_txn
                       (x_return_status                     => l_return_status,
                        x_msg_count                         => l_msg_count,
                        x_msg_data                          => l_msg_data,
                        p_event_source                      => 'RETROPRICE',
                        p_event_type_id                     => adjust_receive,
                        p_rcv_transaction_id                => c_par_txn.transaction_id,
                        p_inv_distribution_id               => NULL,
                        p_po_distribution_id                => c_po_dist.po_distribution_id,
                        p_direct_delivery_flag              => NULL,
                        p_gl_group_id                       => NULL,
                        p_cross_ou_flag                     => NULL,
                        p_procurement_org_flag              => 'Y',
                        p_ship_to_org_flag                  => NULL,
                        p_drop_ship_flag                    => l_drop_ship_flag,
                        p_org_id                            => l_proc_operating_unit,
                        p_organization_id                   => l_organization_id,
                        p_transfer_org_id                   => NULL,
                        p_transfer_organization_id          => NULL,
                        p_trx_flow_header_id                => l_trx_flow_header_id,
                        p_transaction_forward_flow_rec      => NULL,
                        p_transaction_reverse_flow_rec      => NULL,
                        p_unit_price                        => p_new_po_price,
                        p_prior_unit_price                  => p_old_po_price,
                        x_rcv_accttxn                       => l_rcv_accttxn
                       );

               -- Suppose there is no net quantity for this receipt (all received quantity has been
               -- returned), there is no need to seed an event, since there is no accrual to adjust.
               -- If transaction quantity is 0, the Insert_Txn API will return a warning. In the
               -- case of Adjust events, this warning is normal and should be ignored.
               IF (l_return_status = fnd_api.g_ret_sts_success)
               THEN
                  l_rcv_accttxn_tbl (l_rcv_accttxn_tbl.COUNT + 1) :=
                                                                l_rcv_accttxn;
               ELSIF (l_return_status <> 'W')
               THEN
                  l_api_message := 'Error seeding Transactions';

                  IF     g_debug = 'Y'
                     AND fnd_log.level_unexpected >=
                                               fnd_log.g_current_runtime_level
                  THEN
                     fnd_log.STRING (fnd_log.level_unexpected,
                                        g_log_head
                                     || '.'
                                     || l_api_name
                                     || l_stmt_num,
                                        'Create_Adjust_Txns : '
                                     || l_stmt_num
                                     || ' : '
                                     || l_api_message
                                    );
                  END IF;

                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;
            END LOOP;
         END IF;

         -- Adjust Deliver events are not created for global procurement scenarios.
         IF (    l_trx_flow_header_id IS NULL
             AND (l_drop_ship_flag IS NULL OR l_drop_ship_flag NOT IN (1, 2)
                 )
            )
         THEN
            l_stmt_num := 100;

            FOR c_del_txn IN c_deliver_txns_csr (c_par_txn.transaction_id)
            LOOP
               insert_txn
                       (x_return_status                     => l_return_status,
                        x_msg_count                         => l_msg_count,
                        x_msg_data                          => l_msg_data,
                        p_event_source                      => 'RETROPRICE',
                        p_event_type_id                     => adjust_deliver,
                        p_rcv_transaction_id                => c_del_txn.transaction_id,
                        p_inv_distribution_id               => NULL,
                        p_po_distribution_id                => c_del_txn.po_distribution_id,
                        p_direct_delivery_flag              => NULL,
                        p_gl_group_id                       => NULL,
                        p_cross_ou_flag                     => NULL,
                        p_procurement_org_flag              => 'Y',
                        p_ship_to_org_flag                  => NULL,
                        p_drop_ship_flag                    => l_drop_ship_flag,
                        p_org_id                            => l_proc_operating_unit,
                        p_organization_id                   => l_organization_id,
                        p_transfer_org_id                   => NULL,
                        p_transfer_organization_id          => NULL,
                        p_trx_flow_header_id                => l_trx_flow_header_id,
                        p_transaction_forward_flow_rec      => NULL,
                        p_transaction_reverse_flow_rec      => NULL,
                        p_unit_price                        => p_new_po_price,
                        p_prior_unit_price                  => p_old_po_price,
                        x_rcv_accttxn                       => l_rcv_accttxn
                       );

               -- Suppose there is no net quantity for this deliver (all delivered quantity has been
               -- returned), there is no need to seed an event, since there is no accrual to adjust.
               -- If transaction quantity is 0, the Insert_Txn API will return a warning. In the
               -- case of Adjust events, this warning is normal and should be ignored.
               IF (l_return_status = fnd_api.g_ret_sts_success)
               THEN
                  l_rcv_accttxn_tbl (l_rcv_accttxn_tbl.COUNT + 1) :=
                                                                l_rcv_accttxn;
               ELSIF (l_return_status <> 'W')
               THEN
                  l_api_message := 'Error seeding Transactions';

                  IF     g_debug = 'Y'
                     AND fnd_log.level_unexpected >=
                                               fnd_log.g_current_runtime_level
                  THEN
                     fnd_log.STRING (fnd_log.level_unexpected,
                                        g_log_head
                                     || '.'
                                     || l_api_name
                                     || l_stmt_num,
                                        'Create_Adjust_Txns : '
                                     || l_stmt_num
                                     || ' : '
                                     || l_api_message
                                    );
                  END IF;

                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;
            END LOOP;                                             -- C_DEL_TXN
         END IF;                                 -- If Trx Flow does not exist
      END LOOP;                                                  -- C_PAR_TXNS

      IF (l_rcv_accttxn_tbl.COUNT > 0)
      THEN
         l_stmt_num := 110;
         insert_txn2 (x_return_status        => l_return_status,
                      x_msg_count            => l_msg_count,
                      x_msg_data             => l_msg_data,
                      p_rcv_accttxn_tbl      => l_rcv_accttxn_tbl
                     );

         IF l_return_status <> fnd_api.g_ret_sts_success
         THEN
            l_api_message := 'Error inserting Transactions into GRAT';

            IF     g_debug = 'Y'
               AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_unexpected,
                               g_log_head || '.' || l_api_name || l_stmt_num,
                                  'Create_Adjust_Txns : '
                               || l_stmt_num
                               || ' : '
                               || l_api_message
                              );
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      --- Standard check of p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard Call to get message count and if count = 1, get message info
      fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                 p_data       => x_msg_data);

      IF     g_debug = 'Y'
         AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_log_head || '.' || l_api_name || '.end',
                         'Create_Adjust_Txns >>'
                        );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO create_adjust_txns_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_adjust_txns_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN OTHERS
      THEN
         ROLLBACK TO create_adjust_txns_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF     g_debug = 'Y'
            AND fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_log_head || '.' || l_api_name || l_stmt_num,
                               'Create_Adjust_Txns : '
                            || l_stmt_num
                            || ' : '
                            || SUBSTR (SQLERRM, 1, 200)
                           );
         END IF;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name,
                                        l_api_name
                                     || 'Statement -'
                                     || TO_CHAR (l_stmt_num)
                                    );
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
   END create_adjust_txns;
END gmf_rcv_accounting_pkg;

/
