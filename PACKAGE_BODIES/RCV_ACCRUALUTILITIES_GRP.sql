--------------------------------------------------------
--  DDL for Package Body RCV_ACCRUALUTILITIES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_ACCRUALUTILITIES_GRP" AS
/* $Header: RCVGUTLB.pls 120.10.12010000.4 2012/04/27 21:51:43 anjha ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'RCV_AccrualUtilities_GRP';
--G_DEBUG CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
G_LOG_LEVEL CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LOG_HEAD CONSTANT VARCHAR2(40) := 'po.plsql.'||G_PKG_NAME;
G_MSG_LEVEL_THRESHOLD CONSTANT VARCHAR2(1):= FND_PROFILE.Value('FND_API_MSG_LEVEL_THRESHOLD');

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- FUNCTION                                                                --
-- get_ret_sts_success              returns constant G_RET_STS_SUCCESS from--
--                                  fnd_api package                        --
-----------------------------------------------------------------------------
FUNCTION get_ret_sts_success return varchar2
IS
BEGIN
  return fnd_api.g_ret_sts_success;
END get_ret_sts_success;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- FUNCTION                                                                --
-- get_ret_sts_error                returns constant G_RET_STS_ERROR from  --
--                                  fnd_api package                        --
-----------------------------------------------------------------------------
FUNCTION get_ret_sts_error return varchar2
IS
BEGIN
  return fnd_api.g_ret_sts_error;
END get_ret_sts_error;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- FUNCTION                                                                --
-- get_ret_sts_unexp_error          returns constant G_RET_STS_UNEXP_ERROR --
--                                  from fnd_api package                   --
-----------------------------------------------------------------------------
FUNCTION get_ret_sts_unexp_error return varchar2
IS
BEGIN
  return fnd_api.g_ret_sts_unexp_error;
END get_ret_sts_unexp_error;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- FUNCTION                                                                --
-- get_true                   returns constant G_TRUE from fnd_api package --
-----------------------------------------------------------------------------
FUNCTION get_true return varchar2
IS
BEGIN
  return fnd_api.g_true;
END get_true;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- FUNCTION                                                                --
-- get_false                  returns constant G_FALSE from fnd_api package--
-----------------------------------------------------------------------------
FUNCTION get_false return varchar2
IS
BEGIN
  return fnd_api.g_false;
END get_false;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- FUNCTION                                                                --
-- get_valid_level_none       returns constant G_VALID_LEVEL_NONE from     --
--                            fnd_api package                              --
-----------------------------------------------------------------------------
FUNCTION get_valid_level_none return NUMBER
IS
BEGIN
  return fnd_api.g_valid_level_none;
END get_valid_level_none;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- FUNCTION                                                                --
-- get_valid_level_full       returns constant G_VALID_LEVEL_FULL from     --
--                            fnd_api package                              --
-----------------------------------------------------------------------------
FUNCTION get_valid_level_full return NUMBER
IS
BEGIN
  return fnd_api.g_valid_level_full;
END get_valid_level_full;

-----------------------------------------------------------------------------
-- Start of comments
--      API name        : Get_ReceivingUnitPrice
--      Type            : Group
--      Function        : To get the average unit price of quantity in Receiving
--			  Inspection given a parent receive/match transaction.  If a date
--            is specified, the average unit price is for the quantity in Receiving
--            as of that date.  Otherwise, it is for the current date.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_rcv_transaction_id    IN NUMBER
--                				p_valuation_date		IN		DATE 	Optional
--                                      Default = NULL
--
--      OUT             :       x_unit_price            OUT     NUMBER
--                              x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count                     OUT     NUMBER
--                              x_msg_data                      OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--
--      Notes           : This procedure is used by the Receving Value Report and the All inventory
--			  value report to display the value in receiving inspection.
--			  Earlier, this value was simply calculated as (mtl_supply.primary_quantity
--			  However, with the introduction of global procurement and drop shipments
--			  the accounting could be done at transfer price instead of PO price.
--			  Furthermore, the transfer price itself can change between transactions.
--			  Mtl_supply contains a summary amount : quantity_recieved + quantity corrected
--			  - quantity returned. Hence the unit price that should be used by the view
--			  should be the average of the unit price across these transactions.
--
-- End of comments
-------------------------------------------------------------------------------
PROCEDURE Get_ReceivingUnitPrice(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
                p_commit                IN      VARCHAR2 := FND_API.G_FALSE,
                p_validation_level      IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                p_rcv_transaction_id    IN              NUMBER,
                p_valuation_date		IN		DATE := NULL,
		x_unit_price		OUT NOCOPY	NUMBER
)
IS
   l_api_name   CONSTANT VARCHAR2(30)   	:= 'Get_ReceivingUnitPrice';
   l_api_version        CONSTANT NUMBER         := 1.0;

   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER 		:= 0;
   l_msg_data            VARCHAR2(8000);
   l_stmt_num            NUMBER 		:= 0;
   l_api_message         VARCHAR2(1000);

   l_rcv_transaction_id	 NUMBER;

   l_dist_flag           NUMBER;
   l_txn_price		 NUMBER;
   l_tax                 NUMBER;

   l_total_price	 NUMBER;
   l_total_quantity	 NUMBER;
   l_rae_count		 NUMBER;
   l_parent_txn_type	 RCV_TRANSACTIONS.TRANSACTION_TYPE%TYPE;
   l_source_doc_code	 RCV_TRANSACTIONS.SOURCE_DOCUMENT_CODE%TYPE;

   l_rcv_organization_id RCV_TRANSACTIONS.organization_id%TYPE;
   l_po_header_id        RCV_TRANSACTIONS.po_header_id%TYPE;
   l_po_org_id           PO_HEADERS_ALL.org_id%TYPE;
   l_po_sob_id           CST_ORGANIZATION_DEFINITIONS.set_of_books_id%TYPE;
   l_rcv_org_id          CST_ORGANIZATION_DEFINITIONS.operating_unit%TYPE;
   l_rcv_sob_id          CST_ORGANIZATION_DEFINITIONS.set_of_books_id%TYPE;
   l_destination_type_code    PO_DISTRIBUTIONS_ALL.destination_type_code%TYPE;
   l_lcm_flag             PO_LINE_LOCATIONS_ALL.lcm_flag%TYPE;

   l_full_name  CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
   l_module     constant varchar2(60) := 'po.plsql.'||l_full_name;

   l_uLog         CONSTANT BOOLEAN := fnd_log.level_unexpected >= g_log_level AND
                                      fnd_log.TEST(fnd_log.level_unexpected, l_module);
   l_errorLog constant boolean := l_uLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
   l_pLog constant boolean := l_errorLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
   l_sLog constant boolean := l_pLog and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);
   l_rae_price         NUMBER;
   l_mmt_count         NUMBER;
   l_WT_COUNT          NUMBER;
   l_wcti_COUNT        NUMBER;
   l_retro_rae_price   NUMBER;
   CURSOR c_txn_history_csr (c_transaction_id NUMBER, c_valuation_date DATE) IS
     SELECT     RT.transaction_id transaction_id,
	        RT.transaction_type transaction_type,
	        RT.source_doc_quantity source_doc_quantity,
	        RT.organization_id organization_id,
		RT.primary_quantity primary_quantity,
		nvl(RT.unit_landed_cost,0) unit_landed_cost,
		RT.po_unit_price
     FROM       rcv_transactions RT
     WHERE ((c_valuation_date is not null and transaction_date <= c_valuation_date)
     		OR c_valuation_date is null)
     START WITH transaction_id 		= c_transaction_id
     CONNECT BY parent_transaction_id 	= PRIOR transaction_id;


BEGIN
      l_return_status := fnd_api.g_ret_sts_success;
   -- Standard start of API savepoint
      SAVEPOINT Get_ReceivingUnitPrice_GRP;

      l_stmt_num := 0;

      IF l_pLog THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.begin'
             ,'Get_ReceivingUnitPrice <<');
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

      IF l_sLog THEN
	 l_api_message := 'p_rcv_transaction_id : '||p_rcv_transaction_id;
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.begin'
             ,l_api_message);
      END IF;

      l_stmt_num := 10;

      SELECT rt.source_document_code, rt.po_header_id, rt.organization_id,
             nvl(poll.lcm_flag,'N')
      INTO   l_source_doc_code, l_po_header_id, l_rcv_organization_id,
             l_lcm_flag
      FROM   rcv_transactions rt,
             po_line_locations_all poll
      WHERE  rt.transaction_id = p_rcv_transaction_id
        AND  rt.po_line_location_id = poll.line_location_id;

      IF l_source_doc_code <> 'PO' THEN
	    FND_MESSAGE.set_name('PO','INVALID_SOURCE_DOCUMENT');
        FND_MSG_pub.add;
        IF l_errorLog THEN
           FND_LOG.message(FND_LOG.LEVEL_ERROR,G_LOG_HEAD || '.'||l_api_name||l_stmt_num,FALSE);
        END IF;
        RAISE FND_API.g_exc_error;
      END IF;


      /* Get the parameters to determine whether this is a global procurement scenario. */

      /* Get PO Operating Unit and Set of Books */
      l_stmt_num := 20;
	  SELECT POH.org_id, HOU.set_of_books_id
	  INTO   l_po_org_id, l_po_sob_id
	  FROM   po_headers_all POH, hr_operating_units HOU
	  WHERE  POH.org_id = HOU.organization_id
	  AND    POH.po_header_id = l_po_header_id;

      IF l_sLog THEN
        l_api_message := 'l_po_org_id : '|| l_po_org_id || ';  l_po_sob_id : ' || l_po_sob_id;
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                       ,l_api_message);
      END IF;

      /* Get Receiving Operating Unit and Set of Books */
      l_stmt_num := 30;
      SELECT  operating_unit, set_of_books_id
      INTO    l_rcv_org_id, l_rcv_sob_id
      FROM    cst_organization_definitions cod
      WHERE   organization_id = l_rcv_organization_id;

      IF l_sLog THEN
        l_api_message := 'l_rcv_org_id : '|| l_rcv_org_id || ';  l_rcv_sob_id : ' || l_rcv_sob_id;
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                       ,l_api_message);
      END IF;


/* 12i: Since we are modifying the calling procedures to pass in parent receive/match txn,
   we can just set l_rcv_transaction_id := p_rcv_transaction_id.

   -- Bug #3094999. For Accept/Reject/Transfer transactions, mtl_supply gets updated with the
   -- transaction_id of the Accept/Reject/Transfer transaction in place of the parent receipt.
   -- However, accounting is only done against the parent receive transaction. Therefore, we
   -- have to identify the parent receipt to find the actual unit price.
      SELECT transaction_id
      INTO   l_rcv_transaction_id
      FROM (
	SELECT     RT.transaction_id transaction_id,
		   RT.parent_transaction_id parent_transaction_id,
		   RT.transaction_type
	FROM       rcv_transactions RT
	START WITH transaction_id 	= p_rcv_transaction_id
	CONNECT BY transaction_id 	= PRIOR parent_transaction_id)
      WHERE ((transaction_type = 'RECEIVE' and parent_transaction_id=-1)
      OR    transaction_type = 'MATCH');
*/
	l_rcv_transaction_id := p_rcv_transaction_id;

      IF l_sLog THEN
         l_api_message := 'l_rcv_transaction_id : '||l_rcv_transaction_id;
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.begin'
             ,l_api_message);
      END IF;

      l_total_price := 0;
      l_total_quantity := 0;
      IF (l_lcm_flag = 'N') THEN
      FOR rec_txn in c_txn_history_csr(l_rcv_transaction_id, p_valuation_date) LOOP

       -- The situation where the unit_price on an event will vary from the PO
       -- price occurs only in Global Procurement scenarios. In all other cases
       -- including adjust events we use the latest PO price.
       -- So for all global procurement related transactions, we compute the
       -- average unit price from RAE and for non global procurement events,
       -- we use the latest PO price.
         l_stmt_num := 40;
         IF l_sLog THEN
            l_api_message := 'Processing Transaction_ID : '||rec_txn.transaction_id||
                             ' Transaction_Type : '||rec_txn.transaction_type||
                             ' Source_Doc_Qty : '||rec_txn.source_doc_quantity||
                             ' Organization_ID : '||rec_txn.organization_id;
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                 ,l_api_message);
         END IF;


	 IF rec_txn.transaction_type NOT IN ('ACCEPT','REJECT','TRANSFER') THEN

	     IF(rec_txn.transaction_type = 'CORRECT') THEN
	        l_stmt_num := 50;

	        SELECT PARENT.transaction_type
	        INTO   l_parent_txn_type
	        FROM   rcv_transactions RT, rcv_transactions PARENT
	        WHERE  RT.transaction_id 		= rec_txn.transaction_id
	        AND    PARENT.transaction_id 	= RT.parent_transaction_id;

                IF l_sLog THEN
                   l_api_message := 'l_parent_txn_type : '||l_parent_txn_type;
                   FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                       ,l_api_message);
                END IF;

	     END IF;

	    l_stmt_num := 60;

	    SELECT count(*)
	    INTO   l_rae_count
	    FROM   rcv_accounting_events RAE
	    WHERE  RAE.rcv_transaction_id = rec_txn.transaction_id
	    AND    RAE.organization_id 	= rec_txn.organization_id
	    AND    RAE.event_type_id 	IN (1,2,3,4,5,6)
            AND    RAE.TRX_FLOW_HEADER_ID IS NOT NULL;
		/* This condition RAE.trx_flow_header_id IS NOT NULL limits this to
		events in RAE for global procurement scenarios only */


	    IF (l_rae_count = 0) then
	    -- Transaction was done prior to Patchset J or
        -- It is a non-global procurement scenario
	        -- Default to POLL.price_override in this case.
		-- Or, it could be a Deliver, RTR, or Correct to Deliver or RTR
        -- for Inventory or WIP destination types in a global procurement scenario.

           IF (l_po_org_id <> l_rcv_org_id) THEN
               /*
				  The only valid scenario that brings us to this code branch satisfies
				  the following conditions:
				  1. This is a global procurement scenario
				  2. If (1) is true, since the transaction had no events in RAE (l_rae_count = 0),
				     the transaction must be a Deliver, RTR, or Correct to Deliver or RTR
				     for Inventory or WIP destinations only.
				     (For other transaction types in a global procurement scenario and
					 for Expense destinations, l_rae_count > 0)
			    */

			   l_stmt_num := 70;

               SELECT	POD.destination_type_code
               INTO     l_destination_type_code
               FROM     po_distributions_all POD, rcv_transactions RT
               WHERE    POD.po_distribution_id = RT.po_distribution_id
               AND      RT.transaction_id = rec_txn.transaction_id;

               IF l_sLog THEN
                  l_api_message := 'l_destination_type_code : '|| l_destination_type_code;
                  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                       ,l_api_message);
               END IF;

                  /*
                   * The formula to get the actual transaction value from MMT or WT would be:
				   * (MMT.transaction_cost * primary_quantity) or
				   * (WT.actual_resource_rate * primary_quantity)
				   *
                   * However, to yield the correct unit price in global procurement
				   * scenarios with UOM conversion (where primary_quantity <>
				   * source_doc_quantity), l_txn_price must be equal to
				   * unit price * RT.source_doc_quantity, since in the end the API
				   * divides the total transaction value by RT.source_doc_quantity
				   * to get the unit price.
				   * Failing to convert to RT.source_doc_quantity will cause the API
				   * to calculate the incorrect unit price in global procurement scenarios
				   * with UOM conversion.
                   */

               IF (l_destination_type_code = 'INVENTORY') THEN

                  /* For Inventory destinations, use MMT.transaction_cost. */

                    l_stmt_num := 80;
               		SELECT (MMT.transaction_cost * rec_txn.source_doc_quantity)
               		INTO   l_txn_price
               		FROM   mtl_material_transactions MMT
               		WHERE  MMT.rcv_transaction_id = rec_txn.transaction_id
               		AND    MMT.organization_id = rec_txn.organization_id;


               ELSIF (l_destination_type_code = 'SHOP FLOOR') THEN

                  /* For Shop Floor destinations, use WT.actual_resource_rate.
                   * Select from WT if the transaction is costed, and WCTI otherwise.
                   */

                    BEGIN
                        l_stmt_num := 90;
               		    SELECT (((nvl(WT.actual_resource_rate,0) *
                                          decode(nvl(WT.primary_quantity,0),
			                                                  0,decode(nvl(WT.actual_resource_rate,0),0,0,1),
						  nvl(WT.primary_quantity,0)
                                                )
				          )/rec_txn.primary_quantity)*
				         rec_txn.source_doc_quantity)
               		    INTO   l_txn_price
               		    FROM   wip_transactions WT
               		    WHERE  WT.rcv_transaction_id = rec_txn.transaction_id
               		    AND    WT.organization_id = rec_txn.organization_id;
               		EXCEPTION
               			WHEN no_data_found THEN
               		      SELECT (((nvl(WCTI.actual_resource_rate,0) *
                                          decode(nvl(WCTI.primary_quantity,0),
			                                                    0,decode(nvl(WCTI.actual_resource_rate,0),0,0,1),
						  nvl(WCTI.primary_quantity,0)
                                                )
				            )/rec_txn.primary_quantity)*
				           rec_txn.source_doc_quantity)
               		      INTO   l_txn_price
               		      FROM   wip_cost_txn_interface WCTI
               		      WHERE  WCTI.rcv_transaction_id = rec_txn.transaction_id
               		      AND    WCTI.organization_id = rec_txn.organization_id;
               		END;

               END IF; /*  IF (l_destination_type_code = ) */

               IF l_sLog THEN
                  l_api_message := 'l_txn_price : '||l_txn_price;
                  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                         ,l_api_message);
               END IF;

           ELSE
               /* This is a non-global procurement scenario or a pre-Patchset J transaction */
	       /* Check to see if RAE exists If it exists then take the price from RAE.
	          Also make sure that RETRO PRICE Change Events are handled correctly */
		/* Get the RETRO PRICE change first. As it could happen that a delivery transaction
		   has RAE for retro and MMT for delivery we need to consider both */
	       l_stmt_num := 92 ;
	       select nvl(sum((RAE.unit_price-RAE.prior_unit_price) * nvl(RAE.currency_conversion_rate,1)*
                        RAE.source_doc_quantity/RAE.primary_quantity * RAE.source_doc_quantity),0)
		 into l_retro_rae_price
		from RCV_ACCOUNTING_EVENTS RAE
		WHERE  RAE.rcv_transaction_id = rec_txn.transaction_id
	          AND  RAE.organization_id 	= rec_txn.organization_id
	          AND  RAE.event_type_id 	IN (7,8)
		  AND  ((p_valuation_date is not null
		         and RAE.transaction_date <= p_valuation_date)
		        OR p_valuation_date is null );

	         l_stmt_num := 94 ;
	         SELECT count(*),sum(decode(RAE.primary_quantity, 0, 0,
			                               (RAE.unit_price * nvl(RAE.currency_conversion_rate,1)*
	   		                                RAE.source_doc_quantity/RAE.primary_quantity * RAE.source_doc_quantity)
				            )
			             )
	        INTO   l_rae_count,l_txn_price
	        FROM   rcv_accounting_events RAE
	        WHERE  RAE.rcv_transaction_id 	= rec_txn.transaction_id
                AND    RAE.organization_id 	= rec_txn.organization_id
	        AND    RAE.event_type_id 		IN (1,2,3,4,5,6)
		AND  ((p_valuation_date is not null
		         and RAE.transaction_date <= p_valuation_date)
		        OR p_valuation_date is null );
	       IF (l_rae_count = 0) then
	        /* In Non GLobal Procurement after patchet J delivery might be in MMT,WT,WCTI and not in RAE*/
		   l_stmt_num := 96 ;
	           Select count(*),sum((MMT.transaction_cost * rec_txn.source_doc_quantity))
		   into l_mmt_count,l_txn_price
		  from mtl_material_transactions MMT
		   where MMT.rcv_transaction_id = rec_txn.transaction_id
                     AND MMT.organization_id = rec_txn.organization_id;

	             IF(l_mmt_count = 0) then
                        l_stmt_num := 98 ;
                        SELECT count(*),
			       sum ( (    ( nvl(WT.actual_resource_rate,0) *
                                            decode(nvl(WT.primary_quantity,0),
			                           0,decode(nvl(WT.actual_resource_rate,0),0,0,1),
						   nvl(WT.primary_quantity,0)
                                                  )
				            )/rec_txn.primary_quantity
				       )*rec_txn.source_doc_quantity
				    )
               	          INTO   l_WT_COUNT,
			         l_txn_price
               	          FROM   wip_transactions WT
               	         WHERE  WT.rcv_transaction_id = rec_txn.transaction_id
               	           AND    WT.organization_id = rec_txn.organization_id;
			 /* For Bug 13547638 making sure that if WT has actual_resource_rate as 0 even if po_unit_price <> 0
			    then calculate from RT as GL is wrong */
			 IF(l_wt_count <> 0 and l_txn_price = 0 and nvl(rec_txn.po_unit_price,0) <> 0 and rec_txn.primary_quantity <> 0 ) then
			    l_wt_count := 0 ;
			 END IF;
               	        IF (l_WT_COUNT = 0) then
                           l_stmt_num := 99 ;
		           SELECT count(*),
			          sum ( (     (nvl(WCTI.actual_resource_rate,0) *
                                               decode(nvl(WCTI.primary_quantity,0),
			                              0,decode(nvl(WCTI.actual_resource_rate,0),0,0,1),
						      nvl(WCTI.primary_quantity,0)
                                                      )
				               )/rec_txn.primary_quantity
					 )*rec_txn.source_doc_quantity
				       )
               	             INTO   l_wcti_count,
			            l_txn_price
               	             FROM   wip_cost_txn_interface WCTI
               	             WHERE  WCTI.rcv_transaction_id = rec_txn.transaction_id
               	               AND    WCTI.organization_id = rec_txn.organization_id;
			     /* For Bug 13547638 making sure that if WCTI has actual_resource_rate as 0 even if po_unit_price <> 0
			        then calculate from RT as GL is wrong */
                             IF(l_wcti_count <> 0 and l_txn_price = 0 and nvl(rec_txn.po_unit_price,0) <> 0 and rec_txn.primary_quantity <> 0) then
			         l_wcti_count := 0 ;
			     END IF;
               	             IF (l_wcti_count = 0) then /*prior patchset j */
	                       l_stmt_num := 100;
                               SELECT DECODE (PO_DISTRIBUTION_ID, NULL, 0, 1)
                               INTO   l_dist_flag
                               FROM   RCV_TRANSACTIONS
                               WHERE  TRANSACTION_ID = rec_txn.transaction_id;

                               IF l_sLog THEN
                                  l_api_message := 'l_dist_flag : '||l_dist_flag;
                                  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                                  ,l_api_message);
                               END IF;


                               l_stmt_num := 110;
                               IF l_dist_flag = 1 THEN
                               /* Bug 6266340: Modified the Select clause to check for 0 primary quantity */
                                SELECT decode(RT.primary_quantity, 0, 0,
                                ((nvl(RT.po_unit_price,PLL.price_override) * RT.source_doc_quantity +
                                PO_TAX_SV.GET_TAX('PO', POD.PO_DISTRIBUTION_ID) *
                                RT.SOURCE_DOC_QUANTITY/POD.QUANTITY_ORDERED) *
                                decode (nvl(PLL.match_option,'P'),
                                'R',NVL(RT.currency_conversion_rate,1),
                                'P',NVL(NVL(POD.rate,POH.rate),1)) *
                                (RT.source_doc_quantity/RT.primary_quantity)))
                                INTO l_txn_price
                                FROM rcv_transactions RT,
                                po_distributions_all POD,
                                po_line_locations_all PLL,
                                po_headers_all POH
                                WHERE RT.transaction_id      = rec_txn.transaction_id
                                AND POD.po_distribution_id = RT.po_distribution_id
                                AND PLL.line_location_id   = RT.po_line_location_id
                                AND POH.po_header_id       = RT.po_header_id;

                                IF l_sLog THEN
                                l_api_message := 'l_txn_price : '||l_txn_price;
                                FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                                ,l_api_message);
                                END IF;

                                ELSE
                                l_stmt_num := 120;
                                SELECT
                                NVL(SUM(PO_TAX_SV.get_tax('PO', POD.PO_DISTRIBUTION_ID)), 0)
                                INTO
                                l_tax
                                from
                                po_distributions_all pod,
                                po_line_locations_all pol,
                                rcv_transactions rt
                                where
                                rt.transaction_id      = rec_txn.transaction_id
                                and rt.po_line_location_id = pol.line_location_id
                                and pod.line_location_id   = pol.line_location_id;

                                IF l_sLog THEN
                                l_api_message := 'l_tax : '||l_tax;
                                FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                                ,l_api_message);
                                END IF;

                                l_stmt_num := 130;

                                /* Bug 6266340: Modified the Select clause to check for 0 primary quantity */
                                SELECT decode(RT.primary_quantity, 0, 0,
                                ((nvl(RT.po_unit_price,PLL.price_override) * RT.source_doc_quantity +
                                RT.SOURCE_DOC_QUANTITY/PLL.QUANTITY * l_tax) *
                                decode (nvl(PLL.match_option,'P'),
                                'R',NVL(RT.currency_conversion_rate, 1),
                                'P',NVL(POH.rate, 1)) *
                                (RT.source_doc_quantity/RT.primary_quantity)))
                                INTO   l_txn_price
                                FROM   rcv_transactions RT,
                                po_line_locations_all PLL,
                                po_headers_all POH
                                WHERE  RT.transaction_id    = rec_txn.transaction_id
                                AND  PLL.line_location_id = RT.po_line_location_id
                                AND  POH.po_header_id     = RT.po_header_id;

                                IF l_sLog THEN
                                l_api_message := 'l_txn_price : '||l_txn_price;
                                FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                                ,l_api_message);
                                END IF;

                                END IF;  -- l_dist_flag = 1
		              END IF;/*WCTI COUNT */
		        END IF; /*WT COUNT*/
		     END IF; /* MMT_COUNT*/
               END IF; /* RAE COUNT */
            END IF; -- l_po_org_id <> l_rcv_org_id
	     ELSE
	     -- Transaction was done after Patchset J and it relates to global procurement
             -- RAE.unit_price can be used.
	     -- A sum is necessary here since in the case of a standard receipt,
	     -- you could have multiple events - one for each distribution. */
	     -- Added organization check so adjust events in global procurement
	     -- scenarios would get excluded.

	        l_stmt_num := 140;

	        /* Bug 6266340: Modified the Select clause to check for 0 primary quantity */
	        SELECT sum(decode(RAE.primary_quantity, 0, 0,
			(RAE.unit_price * nvl(RAE.currency_conversion_rate,1)*
	   		 RAE.source_doc_quantity/RAE.primary_quantity * RAE.source_doc_quantity)))
	        INTO   l_txn_price
	        FROM   rcv_accounting_events RAE
	        WHERE  RAE.rcv_transaction_id 	= rec_txn.transaction_id
                AND    RAE.organization_id 	= rec_txn.organization_id
	        AND    RAE.event_type_id 		IN (1,2,3,4,5,6);

                IF l_sLog THEN
                   l_api_message := 'l_txn_price : '||l_txn_price;
                   FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                       ,l_api_message);
                END IF;

	     END IF;


	     /* for each transaction, increment or decrement the running total price and quantity. */
	     l_stmt_num := 150;
          -- Receive, Match and RTR transactions increase value in Receiving Inspection.
          -- Deliver and RTV transactions decrease value in Receiving Inspection.
          -- Corrections follow the behavior of the parent.
   	     IF((rec_txn.transaction_type IN ('RECEIVE','MATCH')) OR
	        (rec_txn.transaction_type = 'CORRECT' AND l_parent_txn_type IN ('RECEIVE','MATCH'))) THEN
	        l_total_price 	:= l_total_price + l_txn_price + nvl(l_retro_rae_price,0);
	        l_total_quantity 	:= l_total_quantity + rec_txn.source_doc_quantity;
	     ELSIF ((rec_txn.transaction_type = 'RETURN TO VENDOR') OR
	   	    (rec_txn.transaction_type = 'CORRECT' AND l_parent_txn_type = 'RETURN TO VENDOR')) THEN
                l_total_price 	:= l_total_price - l_txn_price - nvl(l_retro_rae_price,0);
                l_total_quantity 	:= l_total_quantity - rec_txn.source_doc_quantity;
	     ELSIF ((rec_txn.transaction_type = 'RETURN TO RECEIVING') OR
                    (rec_txn.transaction_type = 'CORRECT' AND l_parent_txn_type = 'RETURN TO RECEIVING')) THEN
                l_total_price 	:= l_total_price + l_txn_price + nvl(l_retro_rae_price,0);
                l_total_quantity 	:= l_total_quantity + rec_txn.source_doc_quantity;
             ELSIF ((rec_txn.transaction_type = 'DELIVER') OR
                    (rec_txn.transaction_type = 'CORRECT' AND l_parent_txn_type = 'DELIVER')) THEN
                l_total_price 	:= l_total_price - l_txn_price - nvl(l_retro_rae_price,0);
                l_total_quantity 	:= l_total_quantity - rec_txn.source_doc_quantity;
	     END IF;

             IF l_sLog THEN
                l_api_message := 'l_total_price : '||l_total_price ||
                                 ' l_total_quantity : '||l_total_quantity;
                FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                    ,l_api_message);
             END IF;

	   END IF; /* IF rec_txn.transaction_type... */
      END LOOP;
      ELSE /*LCM ENABLED*/
       l_stmt_num := 150;
       l_rae_price := 0;
       SELECT nvl(sum(decode(rae.event_type_id,
                             15,rae.primary_quantity,
			     -1*rae.primary_quantity)*
			     (rae.unit_price-rae.prior_unit_price)),0)
	 INTO l_rae_price
        FROM rcv_accounting_events rae
       WHERE rae.event_type_id IN (15,16,17)
         AND rae.rcv_transaction_id = l_rcv_transaction_id
	 AND((p_valuation_date is not null
	      and rae.transaction_date <= p_valuation_date)
     		OR p_valuation_date is null);
       IF l_sLog THEN
                l_api_message := 'l_rae_price : '||l_rae_price ;
                FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                    ,l_api_message);
       END IF;

       FOR rec_txn in c_txn_history_csr(l_rcv_transaction_id, p_valuation_date) LOOP
        IF l_sLog THEN
            l_api_message := 'Processing Transaction_ID : '||rec_txn.transaction_id||
                             ' Transaction_Type : '||rec_txn.transaction_type||
                             ' Source_Doc_Qty : '||rec_txn.source_doc_quantity||
                             ' Organization_ID : '||rec_txn.organization_id;
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                 ,l_api_message);
         END IF;


	 IF rec_txn.transaction_type NOT IN ('ACCEPT','REJECT','TRANSFER') THEN

	     IF(rec_txn.transaction_type = 'CORRECT') THEN
	        l_stmt_num := 160;

	        SELECT PARENT.transaction_type
	        INTO   l_parent_txn_type
	        FROM   rcv_transactions RT,
		       rcv_transactions PARENT
	        WHERE  RT.transaction_id 	= rec_txn.transaction_id
	        AND    PARENT.transaction_id 	= RT.parent_transaction_id;

                IF l_sLog THEN
                   l_api_message := 'l_parent_txn_type : '||l_parent_txn_type;
                   FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                       ,l_api_message);
                END IF;

	     END IF;

	     IF((rec_txn.transaction_type IN ('RECEIVE','MATCH')) OR
	        (rec_txn.transaction_type = 'CORRECT' AND
		 l_parent_txn_type IN ('RECEIVE','MATCH'))) THEN
	        l_total_price 	:= l_total_price +
		                   rec_txn.primary_quantity*rec_txn.unit_landed_cost;
	        l_total_quantity := l_total_quantity + rec_txn.primary_quantity;
	     ELSIF ((rec_txn.transaction_type = 'RETURN TO VENDOR') OR
	   	    (rec_txn.transaction_type = 'CORRECT' AND
		     l_parent_txn_type = 'RETURN TO VENDOR')) THEN
                l_total_price 	:= l_total_price -
                                   rec_txn.primary_quantity*rec_txn.unit_landed_cost;
                l_total_quantity := l_total_quantity - rec_txn.primary_quantity;
	     ELSIF ((rec_txn.transaction_type = 'RETURN TO RECEIVING') OR
                    (rec_txn.transaction_type = 'CORRECT' AND
		     l_parent_txn_type = 'RETURN TO RECEIVING')) THEN
                l_total_price 	:= l_total_price +
		                   rec_txn.primary_quantity*rec_txn.unit_landed_cost;
	        l_total_quantity := l_total_quantity + rec_txn.primary_quantity;
             ELSIF ((rec_txn.transaction_type = 'DELIVER') OR
                    (rec_txn.transaction_type = 'CORRECT' AND l_parent_txn_type = 'DELIVER')) THEN
                l_total_price 	:= l_total_price -
                                   rec_txn.primary_quantity*rec_txn.unit_landed_cost;
                l_total_quantity := l_total_quantity - rec_txn.primary_quantity;
	     END IF;

             IF l_sLog THEN
                l_api_message := 'l_total_price : '||l_total_price ||
                                 ' l_total_quantity : '||l_total_quantity;
                FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                    ,l_api_message);
             END IF;

	 END IF;
       END LOOP;
       l_total_price := l_total_price+l_rae_price;

      END IF;

      IF l_total_quantity = 0 THEN
	    x_unit_price := 0;
      ELSE
        x_unit_price := l_total_price/l_total_quantity;
      END IF;

      IF l_sLog THEN
         l_api_message := ' l_total_price : '||l_total_price ||
                          ' l_total_quantity : '||l_total_quantity ||
                          ' x_unit_price : '||x_unit_price;
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


      IF l_pLog THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.end'
             ,'Get_ReceivingUnitPrice >>');
      END IF;


EXCEPTION
      WHEN FND_API.g_exc_error THEN
         ROLLBACK TO Get_ReceivingUnitPrice_GRP;
         x_return_status := FND_API.g_ret_sts_error;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN FND_API.g_exc_unexpected_error THEN
         ROLLBACK TO Get_ReceivingUnitPrice_GRP;
         x_return_status := FND_API.g_ret_sts_unexp_error ;
         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

      WHEN OTHERS THEN
         ROLLBACK TO Get_ReceivingUnitPrice_GRP;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         /*IF l_uLog THEN*/ -- replaced this to work around GSCC false positives File.Sql.45 (bug #4480504)
         IF fnd_log.level_unexpected >= g_log_level THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                ,'Get_ReceivingUnitPrice : '||l_stmt_num||' : '||substr(SQLERRM,1,200));
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

END Get_ReceivingUnitPrice;

-----------------------------------------------------------------------------------------------
-- Start of comments
--      API name        : Validate_PO_Purge
--      Type            : Private
--      Function        : To Validate if records in RAE and RRS can be
--                        deleted for a list of PO_HEADER_ID's
--      Pre-reqs        :
--      Parameters      :
--                        p_purge_entity_type IN VARCHAR2
--                            The table of which the entity is the primary identifier
--                            Values: PO_HEADERS_ALL, RCV_TRANSACTIONS
--                        p_purge_in_rec      IN RCV_AccrualUtilities_GRP.purge_in_rectype
--                            Contains the List of PO_HEADER_ID's to be evaluated
--                        x_purge_out_rec     OUT NOCOPY RCV_AccrualUtilities_GRP.purge_out_rectype
--                            Contains c character ('Y'/'N') indicating whether records
--                            for corresponding header_id's can be deleted or not
----------------------------------------------------------------------------------------------

PROCEDURE Validate_PO_Purge (
  p_api_version         IN NUMBER,
  p_init_msg_list       IN VARCHAR2,
  p_commit              IN VARCHAR2,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  p_purge_entity_type   IN  VARCHAR2,
  p_purge_in_rec        IN  RCV_AccrualUtilities_GRP.purge_in_rectype,
  x_purge_out_rec       OUT NOCOPY RCV_AccrualUtilities_GRP.purge_out_rectype
) IS

l_api_name   constant varchar2(30) := 'Validate_PO_Purge';
l_api_version               number := 1.0;

l_stmt_num                  number;
l_index                     binary_integer;

BEGIN
  -- Establish API Savepoint
  SAVEPOINT Validate_PO_Purge;

  -- Standard call to check for call compatibility
  l_stmt_num := 10;
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list
  l_stmt_num := 20;
  IF FND_API.to_boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;


  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Set each header_id in p_purge_in_rec as Validated
  -- This is marked as 'Y' in x_purge_out_rec in the corresponding
  -- index.

  l_index := p_purge_in_rec.entity_ids.FIRST;

  LOOP
    x_purge_out_rec.purge_allowed(l_index) := 'Y';
    EXIT WHEN l_index = p_purge_in_rec.entity_ids.LAST;
    l_index := p_purge_in_rec.entity_ids.NEXT(l_index);
  END LOOP;

  --- Standard check of p_commit
  IF FND_API.to_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO Validate_PO_Purge;
    IF G_MSG_LEVEL_THRESHOLD <= FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name       => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text     => 'Error at: '||
                            to_char(l_stmt_num) || ' '||
                            SQLERRM
      );

    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;

END Validate_PO_Purge;

-----------------------------------------------------------------------------------------------
-- Start of comments
--      API name        : Purge
--      Type            : Private
--      Function        : To delete the records in RAE and RRS corresponding to po_header_id's
--                        specified.
--      Pre-reqs        :
--      Parameters      :
--                        p_purge_entity_type IN VARCHAR2
--                            The table of which the entity is the primary identifier
--                            Values: PO_HEADERS_ALL, RCV_TRANSACTIONS
--                        p_purge_in_rec IN RCV_AccrualUtilities_GRP.purge_in_rectype
--                            Contains the List of PO_HEADER_ID's for which corresponding
--                            records need to be deleted from RAE and RRS
----------------------------------------------------------------------------------------------

PROCEDURE Purge (
  p_api_version IN NUMBER,
  p_init_msg_list       IN VARCHAR2,
  p_commit              IN VARCHAR2,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  p_purge_entity_type   IN  VARCHAR2,
  p_purge_in_rec        IN  RCV_AccrualUtilities_GRP.purge_in_rectype
) IS

l_api_name   constant varchar2(30) := 'Purge';
l_api_version               number := 1.0;

l_stmt_num                  number;
l_index                     binary_integer;


l_acct_events               RCV_AccrualUtilities_GRP.TBL_NUM;

INCORRECT_ENTITY            EXCEPTION;
DELETE_FAILED               EXCEPTION;

BEGIN
  -- Establish API Savepoint
  SAVEPOINT Purge;

  -- Standard call to check for call compatibility
  l_stmt_num := 10;
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list
  l_stmt_num := 20;
  IF FND_API.to_boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;


  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_stmt_num := 25;

  IF p_purge_entity_type <> 'RCV_TRANSACTIONS' THEN
    RAISE INCORRECT_ENTITY;
  END IF;

  BEGIN
    l_stmt_num := 30;

    FORALL l_index in p_purge_in_rec.entity_ids.FIRST..p_purge_in_rec.entity_ids.LAST
      DELETE FROM RCV_ACCOUNTING_EVENTS
      WHERE  RCV_TRANSACTION_ID = p_purge_in_rec.entity_ids(l_index);
    FORALL l_index in p_purge_in_rec.entity_ids.FIRST..p_purge_in_rec.entity_ids.LAST
      DELETE FROM RCV_RECEIVING_SUB_LEDGER
      WHERE  RCV_TRANSACTION_ID = p_purge_in_rec.entity_ids(l_index);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE DELETE_FAILED;
  END;
  --- Standard check of p_commit
  IF FND_API.to_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;


EXCEPTION
  WHEN INCORRECT_ENTITY THEN
    ROLLBACK TO Purge;
    IF G_MSG_LEVEL_THRESHOLD <= FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name       => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text     => 'Incorrect Entity Passed to API, RCV_TRANSACTION_ID expected'||
                            to_char(l_stmt_num) || ' '||
                            SQLERRM
      );

    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;


  WHEN DELETE_FAILED THEN
    ROLLBACK TO Purge;
    IF G_MSG_LEVEL_THRESHOLD <= FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name       => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text     => 'Purge of RCV_Accounting_Events/RCV_Receiving_Sub_Ledger Failed'||
                            to_char(l_stmt_num) || ' '||
                            SQLERRM
      );

    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN
    ROLLBACK To Purge;
    IF G_MSG_LEVEL_THRESHOLD <= FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name       => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text     => 'Error at: '||
                            to_char(l_stmt_num) || ' '||
                            SQLERRM
      );

    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;

END Purge;

-----------------------------------------------------------------------------
-- Start of comments
--      API name        : Get_encumReversalAmt
--      Type            : Group
--      Function        : To obtain total encumbrance reversal by PO distribution ID
--      Pre-reqs        :
--      Parameters      :
--      IN              :      p_po_distribution_id    IN     NUMBER
--                             p_start_gl_date         IN     DATE    Optional
--                             p_end_gl_date           IN     DATE    Optional
--
--      RETURN          :      Encumbrance Reversal Amount
--                             This amount is always a positive number
--      Version         :      Initial version       1.0
--      Notes           :      This function will be used in the Encumbrance Detail Report
--                             and active encumbrance summary screen.
--                             The function will be called only if accrue on receipt is set to Yes
--
--                             For inventory destinations,
--                                sum(MTA.base_transaction_value) for deliveries
--                                against the PO distribution
--                                that have been transferred to GL
--                             For expense destinations,
--                                sum(RRS.accounted_dr/cr for E rows) for
--                                 deliveries against the PO distribution
--
--                             Encumbrance is not supported currently for Shop Floor
--                             For Time Zone changes
--                               Assume that date sent in is server timezone,
--                               and validate with TxnDate
-- End of comments
-------------------------------------------------------------------------------

 FUNCTION Get_encumReversalAmt(
              p_po_distribution_id   IN            NUMBER,
              p_start_txn_date       IN            VARCHAR2,
              p_end_txn_date         IN            VARCHAR2
              )

 RETURN NUMBER
 IS
   l_encReversalAmt     NUMBER := 0;
   l_accrueOnRcptFlg    VARCHAR(1);
   l_destTypeCode       VARCHAR2(25);
   l_stmt_num 		NUMBER := 0;

 BEGIN
   l_accrueOnRcptFlg := 'Y';
   -- Obtain Accrue on Receipt flag and destination type from POD

   /* MOAC Uptake - Replaced po_distributions with po_distributions_all as the view
      would be obsoleted in R12 */

   l_stmt_num := 10;
   select nvl(accrue_on_receipt_flag,'N'),
          destination_type_code
     into l_accrueOnRcptFlg,
          l_destTypeCode
     from po_distributions_all
    where po_distribution_id = p_po_distribution_id;

   -- Check if accrue on receipt, else return 0
   l_stmt_num := 20;
   if (l_accrueOnRcptFlg <> 'Y') then
     return l_encReversalAmt;
   end if;

   -- Obtain Encumbrance Reversal Amount
   l_stmt_num := 30;

   if (l_destTypeCode = 'INVENTORY') then
     l_stmt_num := 40;
     select sum(nvl(mta.base_transaction_value, 0))
       into l_encReversalAmt
       from mtl_material_transactions mmt,
            mtl_transaction_accounts mta,
            rcv_transactions rt
      where rt.po_distribution_id = p_po_distribution_id
        and fnd_date.date_to_canonical(rt.transaction_date)
            between nvl(p_start_txn_date,fnd_date.date_to_canonical(rt.transaction_date))
            and nvl(p_end_txn_date,fnd_date.date_to_canonical(sysdate))
        and mmt.rcv_transaction_id = rt.transaction_id
        and mta.transaction_id     = mmt.transaction_id
        and mta.accounting_line_type = 15
        and NVL(mta.gl_batch_id, 0) <> -1;

   elsif (l_destTypeCode = 'EXPENSE') then
     l_stmt_num := 50;
     select sum(nvl(rrs.accounted_dr,0)-nvl(rrs.accounted_cr,0))
       into l_encReversalAmt
       from rcv_receiving_sub_ledger rrs,
            rcv_transactions rt
      where rt.po_distribution_id = p_po_distribution_id
        and fnd_date.date_to_canonical(rt.transaction_date)
            between nvl(p_start_txn_date,fnd_date.date_to_canonical(rt.transaction_date))
            and nvl(p_end_txn_date,fnd_date.date_to_canonical(sysdate))
        and rrs.rcv_transaction_id = rt.transaction_id
        and rrs.actual_flag = 'E';
   else
     l_stmt_num := 60;
     l_encReversalAmt := 0;
   end if;

   l_stmt_num := 70;
   return (abs(l_encReversalAmt));

EXCEPTION
   when no_data_found then
    l_encReversalAmt := 0;
    return (l_encReversalAmt);

   when others then
    l_encReversalAmt := 0;
    return (l_encReversalAmt);
END;

END RCV_AccrualUtilities_GRP;

/
