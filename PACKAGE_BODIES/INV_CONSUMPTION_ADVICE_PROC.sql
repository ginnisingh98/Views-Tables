--------------------------------------------------------
--  DDL for Package Body INV_CONSUMPTION_ADVICE_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_CONSUMPTION_ADVICE_PROC" AS
-- $Header: INVRCADB.pls 120.20.12010000.6 2011/04/11 06:41:37 ksaripal ship $
--+=======================================================================+
--|               Copyright (c) 2002 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVRCADB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Create Consumption Advice Concurrent Program                       |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Update_Consumption                                                |
--|     Consumption_Txn_Manager                                           |
--|     Load Consumption                                                  |
--|     Load_Summarized_Quantity                                          |
--|     Delete Record                                                     |
--|     Batch Allocation                                                  |
--|     Submit Worker                                                     |
--|     Wait_For_All_Workers                                              |
--|     Wait_For_Worker                                                   |
--|     Has_Worker_Completed                                              |
--|     Generate_Batch_Id                                                 |
--|     Generate_Log                                                      |
--|     Log                                                               |
--|     Log_Initialize                                                    |
--|     Consumption_Txn_Worker                                            |
--|                                                                       |
--| HISTORY                                                               |
--|     11/29/02 David Herring  Created procedure                         |
--|     09/09/03 Vanessa To     Modified for consumption advice error     |
--|                             reporting. Store error message in the     |
--|                             MCT table.   	  			  |
--|     10/20/05 kdevadas	Modified proc consumption_txn_manager     |
--|				to fix a performance issue : Bug 4863365  |
--|     13/01/06 myerrams	Modified for Bug 4723164 		  |
--|	23/01/06 kdevadas	Modified proc consumption_txn_manager to  |
--|				TO prevent release duplication WHEN   	  |
--|				consumption advice concurrent program IS  |
--|				RUN parallely - Bug 4574159	   	  |
--|	30-Jan-06 kdevadas	Modified proc. consumption_txn_worker	  |
--|	  			 to change the EXIT condition for the     |		 	   			 		 								  |
--|				 worker. Bug 5006151			  |
--|	15-Feb-06 kdevadas	 Profile option changes.		  |
--|				 Bug 4599072				  |
--|	07-Mar-06 kdevadas	 BLANKET_PRICE and PO_DISTRIBUTION_ID     |
--|				 columns added to MCT - Bug 4969421	  |
--|     03-Apr-06 kdevadas  	 Bug 5113064 - 11.5.10 CU Fix FP	  |
--|     08-May-06 kdevadas  	 Bug 5210850 - 11.5.10 Regression Fix FP  |
--|     17-May-06 kdevadas  	 Bug 5230913 - 		  	  	  |
--|				 PO VENDORS reference removed 		  |
--|  	08-Aug-06 kdevadas	New column (INTERFACE_DISTRIBUTION_REF)   |
--|				added to PO_DIST_INTERFACE - Bug 5373370  |
--|	06-Nov-06 kdevadas	Tax joins and price joins	  	  |
--|				removed in Update_Po_Dist - Bug 5604129   |
--|	24-Apr-07 kdevadas	Perfomance fix changes 	 - Bug 5104057 	  |
--|    30-Jan-2008 sabghosh two different insert for different
--|                                     global_agreement_flag bug - bug 6388514     |
--+========================================================================

--===================
-- GLOBALS
--===================

G_PKG_NAME CONSTANT    VARCHAR2(30) := 'INV_CONSUMPTION_ADVICE_PROC';
g_user_id              NUMBER       := FND_PROFILE.value('USER_ID');
g_resp_id              NUMBER       := FND_PROFILE.value('RESP_ID');
g_appl_id              NUMBER;
-- Bug 5092489, commented becasue not used
--g_pgm_appl_id          NUMBER;
g_log_level            NUMBER       := NULL;
g_log_mode             VARCHAR2(3)  := 'OFF';

TYPE g_cons_date_tbl_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE g_cons_varchar_tbl_type IS TABLE OF VARCHAR2(24) INDEX BY BINARY_INTEGER;
TYPE g_cons_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE g_request_tbl_type IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;


G_SLEEP_TIME           NUMBER     := 15;
g_batch_size           NUMBER     := 1000;
g_max_workers          NUMBER     := 1;
-- Bug 5092489, commented becasue not used
--g_unit_test_mode       BOOLEAN    := FALSE;
--g_org_id               NUMBER     := FND_PROFILE.value('ORG_ID');
g_submit_failure_exc   EXCEPTION;
g_request_id           NUMBER ;
--===================
-- PRIVATE PROCEDURES
--===================
/* Bug 4969421  Starts here*/
--========================================================================
-- PROCEDURE  : Update_PO_Distrubution_Id    PRIVATE
-- PARAMETERS : -
-- COMMENT    : Update  mtl_consumption_transactions table with the
--              po_distribution_id and the blanket_price for all the
--			    processed transactions
--========================================================================
PROCEDURE update_po_distrubution_id
IS
l_transaction_id		NUMBER;
l_po_distribution_id            NUMBER;
l_consumption_release_id        NUMBER;
l_consumption_po_header_id      NUMBER;
l_blanket_price                 NUMBER ;
l_interface_distribution_ref	VARCHAR2(240);
l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

CURSOR txn_csr_type IS
  SELECT
    mct.transaction_id
  , mct.po_distribution_id
  , mct.consumption_release_id
  , mct.consumption_po_header_id
  /* Bug 5373370 - Start */
  , mct.interface_distribution_ref
  /* Bug 5373370 - End */
  FROM
    MTL_CONSUMPTION_TRANSACTIONS mct
  WHERE
    ( mct.blanket_price IS NULL OR mct.po_distribution_id IS NULL )
    AND mct.net_qty > 0
    AND mct.request_id = g_request_id
    AND mct.consumption_processed_flag = 'Y';

BEGIN

IF (l_debug = 1)
THEN
    INV_LOG_UTIL.trace
    ( '>> Update po_distrubution_id','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
END IF;
OPEN txn_csr_type;
LOOP
  l_po_distribution_id         := NULL ;
  l_consumption_release_id     := NULL;
  l_consumption_po_header_id   := NULL;
  l_transaction_id             := NULL ;
  l_blanket_price              := NULL ;
  l_interface_distribution_ref	:= NULL;

  FETCH txn_csr_type
  INTO
    l_transaction_id
  , l_po_distribution_id
  , l_consumption_release_id
  , l_consumption_po_header_id
  , l_interface_distribution_ref	 ;

    EXIT WHEN txn_csr_type%NOTFOUND;

  IF (l_debug = 1)
  THEN
   INV_LOG_UTIL.trace
    ( 'Transaction_id: '||l_transaction_id
     , 9
    );
   INV_LOG_UTIL.trace
    ( 'Consumption_Release_Id: '||l_consumption_release_id
     , 9
    );
   INV_LOG_UTIL.trace
    ( 'Consumption_Po_Header_Id: '||l_consumption_po_header_id
     , 9
    );
  END IF;

 IF  l_po_distribution_id IS NULL
 THEN
  BEGIN
  IF l_consumption_release_id IS NOT NULL
  THEN
      -- Bug 5092489, Query modified to avoid use of MMT
      SELECT pod.po_distribution_id
      INTO  l_po_distribution_id
      FROM
        MTL_CONSUMPTION_TRANSACTIONS mct,
        --MTL_MATERIAL_TRANSACTIONS mmt,
        po_line_locations_all poll,
        po_distributions_all pod,
        po_lines_all pol
      WHERE  mct.transaction_id = l_transaction_id
        AND mct.consumption_processed_flag = 'Y'
        AND mct.inventory_item_id = pol.item_id
        AND mct.transaction_source_id = pol.po_header_id
        AND poll.po_line_id      = pol.po_line_id
        AND poll.po_header_id    = pol.po_header_id
        AND poll.po_release_id   = mct.consumption_release_id
        AND poll.shipment_type   = 'BLANKET'
        AND poll.line_location_id = pod.line_location_id
        AND pod.po_release_id    = mct.consumption_release_id
        AND pod.po_header_id     = poll.po_header_id
        /* Bug 5604129  - Start */
        --AND NVL(mct.tax_code_id, -1) = NVL(poll.TAX_CODE_ID, -1)
       /* Bug 5373370 - Start */
        /*AND (  NVL(mct.RECOVERABLE_TAX,0)   = NVL(pod.RECOVERABLE_TAX,0)
        OR ( NVL(mct.RECOVERABLE_TAX,0)  =
           NVL(pod.RECOVERABLE_TAX,0) / pod.quantity_ordered ) )
        AND (  NVL(mct.NON_RECOVERABLE_TAX,0)   = NVL(pod.NONRECOVERABLE_TAX,0)
        OR ( NVL(mct.NON_RECOVERABLE_TAX,0)  =
           NVL(pod.NONRECOVERABLE_TAX,0) / pod.quantity_ordered ) )*/
	 AND mct.interface_distribution_ref = pod.interface_distribution_ref
	 /* Buf 5373370 - End*/
	 --AND NVL(mct.TAX_RECOVERY_RATE,0)  = NVL(pod.RECOVERY_RATE,0)
     AND mct.CHARGE_ACCOUNT_ID =  pod.CODE_COMBINATION_ID
     AND mct.VARIANCE_ACCOUNT_ID = pod.VARIANCE_ACCOUNT_ID
     AND mct.accrual_account_id = pod.ACCRUAL_ACCOUNT_ID
     AND poll.price_override = mct.blanket_price
     AND ROWNUM = 1;
 /* Bug 5604129  - End */

   END IF; -- po release

  IF l_consumption_po_header_id IS NOT NULL
  THEN
      -- Bug 5092489, Query modified to avoid use of MMT
      SELECT pod.po_distribution_id
      INTO  l_po_distribution_id
      FROM
        MTL_CONSUMPTION_TRANSACTIONS mct,
        --MTL_MATERIAL_TRANSACTIONS mmt,
        po_line_locations_all poll,
        po_distributions_all pod,
        po_lines_all pol
      WHERE  mct.transaction_id = l_transaction_id
        AND mct.consumption_processed_flag = 'Y'
        AND mct.inventory_item_id = pol.item_id
        AND pol.from_header_id = mct.transaction_source_id
        AND pol.po_header_id = mct.consumption_po_header_id
        AND poll.po_line_id      = pol.po_line_id
        AND poll.po_header_id    = pol.po_header_id
        AND poll.shipment_type   = 'STANDARD'
        AND poll.line_location_id = pod.line_location_id
        AND pod.po_header_id   = mct.consumption_po_header_id

        /* Bug 5604129  - Start */
        --AND NVL(mct.tax_code_id, -1) = NVL(poll.TAX_CODE_ID, -1)
       /* Bug 5373370 - Start */
	    /*AND (  NVL(mct.RECOVERABLE_TAX,0)   = NVL(pod.RECOVERABLE_TAX,0)
        OR ( NVL(mct.RECOVERABLE_TAX,0)  =
           NVL(pod.RECOVERABLE_TAX,0) / pod.quantity_ordered ) )
        AND (  NVL(mct.NON_RECOVERABLE_TAX,0)   = NVL(pod.NONRECOVERABLE_TAX,0)
        OR ( NVL(mct.NON_RECOVERABLE_TAX,0)  =
           NVL(pod.NONRECOVERABLE_TAX,0) / pod.quantity_ordered ) )*/
	 AND mct.interface_distribution_ref = pod.interface_distribution_ref
	 /* Bug 5373370 - End*/
     --AND NVL(mct.TAX_RECOVERY_RATE,0)  = NVL(pod.RECOVERY_RATE,0)
     AND mct.CHARGE_ACCOUNT_ID =  pod.CODE_COMBINATION_ID
     AND mct.VARIANCE_ACCOUNT_ID = pod.VARIANCE_ACCOUNT_ID
     AND mct.accrual_ACCOUNT_ID = pod.ACCRUAL_ACCOUNT_ID
     --AND poll.price_override = mct.blanket_price
	 AND ROWNUM = 1;
     /* Bug 5604129  - End */

   END IF; -- po header id

  IF (l_debug = 1)
  THEN
   INV_LOG_UTIL.trace
    ( 'Updating MTL_CONSUMPTION_TRANSACTIONS with po_distrubution_id '
      ||l_po_distribution_id
     , 9
    );
  END IF;

  UPDATE MTL_CONSUMPTION_TRANSACTIONS
   SET po_distribution_id  = l_po_distribution_id
 WHERE transaction_id = l_transaction_id ;

COMMIT;

EXCEPTION
WHEN NO_DATA_FOUND THEN
     IF txn_csr_type%ISOPEN THEN
      CLOSE txn_csr_type;
     END IF;

     IF (l_debug = 1) THEN
     INV_LOG_UTIL.trace
     ( SQLCODE  || ' : ' || SQLERRM ,'INV_CONSUMPTION_ADVICE_PROC'
      , 9
     );
    END IF;

WHEN TOO_MANY_ROWS THEN
     IF txn_csr_type%ISOPEN THEN
      CLOSE txn_csr_type;
     END IF;

     IF (l_debug = 1) THEN
     INV_LOG_UTIL.trace
     ( SQLCODE  || ' : ' || SQLERRM ,'INV_CONSUMPTION_ADVICE_PROC'
      , 9
     );
    END IF;

END ;

END IF;

END LOOP;

CLOSE txn_csr_type;

IF (l_debug = 1)
THEN
    INV_LOG_UTIL.trace
    ( '<< Update po_distrubution_id','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
END IF;

END update_po_distrubution_id ;
/* Bug 4969421  Ends here*/

--========================================================================
-- PROCEDURE  : Update_Consumption            PRIVATE
-- PARAMETERS:
--             p_consumption_po_header_id    PO Header Id
--             p_consumption_release_id      Release id
--             p_error_code                  Error code if any
--             p_batch_id                    batch id from concurrent pgm
--             p_consumption_processed_flag  E if error,else Y
--             p_accrual_account_id          Accrual account
--             p_variance_account_id         Variance account
--             p_charg_account_id            Charge account
--             p_transaction_date            Date of transaction
-- COMMENT   : Update  mtl_consumption_transactions table
--             This procedure is called by the Create_Consumption_Advice
--             procedures after creation of the
--             document. Update the table with the appropriate release
--             info or the po_header info.
--========================================================================
PROCEDURE Update_Consumption
( p_consumption_po_header_id       IN   NUMBER
, p_consumption_release_id         IN   NUMBER
, p_error_code                     IN   VARCHAR2
, p_batch_id                       IN   NUMBER
, p_transaction_source_id          IN   NUMBER
, p_consumption_processed_flag     IN   VARCHAR2
, p_accrual_account_id             IN   NUMBER
, p_variance_account_id            IN   NUMBER
, p_charge_account_id              IN   NUMBER
, p_transaction_date               IN   DATE
, p_global_rate_type               IN   VARCHAR2
, p_global_rate                    IN   NUMBER
, p_vendor_site_id                 IN   NUMBER
)
IS
l_debug              NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_blanket_po_number  VARCHAR2(20)  := NULL;
l_error_explanation  VARCHAR2(240) := NULL;
l_transaction_date   DATE;

l_count              NUMBER;

--Bug 5113064
l_consumption_processed_flag  VARCHAR2(1);

BEGIN

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> Update Consumption','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;


  --
  -- Check for consumption advice processing errors. If there is one, get the
  -- translated message text and store it in the consumption transaction.
  --
  IF (p_consumption_processed_flag = 'E')
  THEN
    IF (p_error_code = 'INV_SUP_CONS_NO_BPO_EXISTS')
    THEN
      BEGIN
        SELECT segment1
        INTO   l_blanket_po_number
        FROM   po_headers_all
        WHERE  po_header_id = p_consumption_po_header_id;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
      FND_MESSAGE.Set_Name('INV', 'INV_SUP_CONS_NO_BPO_EXISTS');
      FND_MESSAGE.Set_Token('BLANKET_PO_NUMBER', l_blanket_po_number);
    ELSE
      FND_MESSAGE.Set_Name('INV', p_error_code);
    END IF;
    l_error_explanation := SUBSTRB(FND_MESSAGE.Get, 1, 240);
  END IF;

  IF (l_debug = 1)
  THEN
  INV_LOG_UTIL.trace
  ( ' consumption_po_header_id : '||p_consumption_po_header_id,'INV_CONSUMPTION_ADVICE_PROC'
  , 9
  );
  END IF;

  IF (l_debug = 1)
  THEN
  INV_LOG_UTIL.trace
  ( ' consumption_release_id : '||p_consumption_release_id,'INV_CONSUMPTION_ADVICE_PROC'
  , 9
  );
  END IF;

  IF (l_debug = 1)
  THEN
  INV_LOG_UTIL.trace
  ( ' consumption_processed_flag : '||p_consumption_processed_flag,'INV_CONSUMPTION_ADVICE_PROC'
  , 9
  );
  END IF;

  IF (l_debug = 1)
  THEN
  INV_LOG_UTIL.trace
  ( ' error_code : '||p_error_code,'INV_CONSUMPTION_ADVICE_PROC'
  , 9
  );
  END IF;

  IF (l_debug = 1)
  THEN
  INV_LOG_UTIL.trace
  ( ' charge_account_id : '||p_charge_account_id,'INV_CONSUMPTION_ADVICE_PROC'
  , 9
  );
  END IF;

  IF (l_debug = 1)
  THEN
  INV_LOG_UTIL.trace
  ( ' variance_account_id : '||p_variance_account_id,'INV_CONSUMPTION_ADVICE_PROC'
  , 9
  );
  END IF;

  IF (l_debug = 1)
  THEN
  INV_LOG_UTIL.trace
  ( ' transaction_source_id : '||p_transaction_source_id,'INV_CONSUMPTION_ADVICE_PROC'
  , 9
  );
  END IF;


  IF (l_debug = 1)
  THEN
  INV_LOG_UTIL.trace
  ( ' distribution_account_id : '||p_accrual_account_id,'INV_CONSUMPTION_ADVICE_PROC'
  , 9
  );
  END IF;

  IF (l_debug = 1)
  THEN
  INV_LOG_UTIL.trace
  ( ' transaction_date : '||p_transaction_date,'INV_CONSUMPTION_ADVICE_PROC'
  , 9
  );
  END IF;

  --Bug 5113064, avoid possibility of null value of consumption_processed_flag
  l_consumption_processed_flag := p_consumption_processed_flag;
  IF (l_consumption_processed_flag IS NULL) THEN
   l_consumption_processed_flag := 'N';
  END IF;

  IF NVL(FND_PROFILE.value('INV_SUPPLIER_CONSIGNED_GROUPING'),'N') = 'N'
  THEN
    -- Bug 5092489, Query modified to eliminate use of MMT in subquery
    UPDATE MTL_CONSUMPTION_TRANSACTIONS mct
     SET mct.consumption_po_header_id   = p_consumption_po_header_id
       , mct.consumption_release_id     = p_consumption_release_id
       , mct.consumption_processed_flag = l_consumption_processed_flag
       , mct.error_code                 = p_error_code
    WHERE  mct.batch_id                   = p_batch_id
    AND  mct.charge_account_id          = p_charge_account_id
    AND  mct.variance_account_id        = p_variance_account_id
    AND  NVL(mct.rate_type,'##')        = NVL(p_global_rate_type,'##')
    AND  NVL(mct.rate,-1)               = NVL(p_global_rate,-1)
    AND mct.consumption_processed_flag IN ('N', 'E')
    AND mct.transaction_source_id = p_transaction_source_id
    AND mct.accrual_account_id = p_accrual_account_id
    AND mct.owning_organization_id  = p_vendor_site_id
    AND ((NVL(mct.global_agreement_flag,'N') = 'Y'
    AND TRUNC(mct.transaction_date) = TRUNC(p_transaction_date))
    OR (NVL(mct.global_agreement_flag,'N') = 'N'));

    -- Deleted unused commented code as part of bug 11900144
  ELSE
    -- Bug 5092489, Query modified to eliminate use of MMT in subquery
    UPDATE MTL_CONSUMPTION_TRANSACTIONS mct
     SET mct.consumption_po_header_id   = p_consumption_po_header_id
       , mct.consumption_release_id     = p_consumption_release_id
       , mct.consumption_processed_flag = l_consumption_processed_flag
       , mct.error_code                 = p_error_code
       , mct.error_explanation          = l_error_explanation
   WHERE  mct.batch_id                   = p_batch_id
    AND  mct.charge_account_id          = p_charge_account_id
    AND  mct.variance_account_id        = p_variance_account_id
    AND  NVL(mct.rate_type,'##')        = NVL(p_global_rate_type,'##')
    AND  NVL(mct.rate,-1)               = NVL(p_global_rate,-1)
    AND mct.consumption_processed_flag IN ('N', 'E')
    AND mct.transaction_source_id  = p_transaction_source_id
    AND mct.accrual_account_id = p_accrual_account_id
    AND mct.owning_organization_id  = p_vendor_site_id
    AND TRUNC(mct.transaction_date) = TRUNC(p_transaction_date);

/*
    AND  transaction_id IN
         (SELECT transaction_id
          FROM MTL_MATERIAL_TRANSACTIONS
          WHERE  transaction_source_id   = p_transaction_source_id
          AND    distribution_account_id = p_accrual_account_id
          AND    owning_organization_id  = p_vendor_site_id
          AND    TRUNC(transaction_date) = TRUNC(p_transaction_date)
          AND    inventory_item_id IN
                 (SELECT inventory_item_id
                  FROM   MTL_CONSUMPTION_TXN_TEMP
                  WHERE  transaction_source_id = p_transaction_source_id));
*/
  END IF;

  UPDATE MTL_CONSUMPTION_TRANSACTIONS
     SET consumption_po_header_id   = p_consumption_po_header_id
       , consumption_release_id     = p_consumption_release_id
       , consumption_processed_flag = l_consumption_processed_flag
       , error_code                 = p_error_code
       , error_explanation          = l_error_explanation
  WHERE parent_transaction_id IN
   (SELECT mct.transaction_id
    FROM MTL_CONSUMPTION_TRANSACTIONS mct
    WHERE mct.batch_id = p_batch_id
    AND  mct.charge_account_id          = p_charge_account_id
    AND  mct.variance_account_id        = p_variance_account_id
    AND  NVL(mct.rate_type,'##')        = NVL(p_global_rate_type,'##')
    AND  NVL(mct.rate,-1)               = NVL(p_global_rate,-1)
    AND mct.transaction_source_id  = p_transaction_source_id
    AND mct.accrual_account_id = p_accrual_account_id
    AND mct.owning_organization_id  = p_vendor_site_id
    )
    AND consumption_processed_flag IN ('N', 'E');

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '<< Update Consumption','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

END Update_Consumption;


--========================================================================
-- PROCEDURE : Load_Combination      PRIVATE
-- COMMENT   : This procedure will load all the records of a context batch
--             from MTL_CONSUMPTION_TRANSACTIONS to
--             MTL_CONSUMPTION_TRANSACTIONS_TEMP
--             If the batch_id passed is -1 then the call is from the
--             manager in which case all records with a
--             processed_consumption_flag are loaded.
--             The insert statement will also be selective by the
--             input parameters p_txn_s_id, p_item_id and p_org_id
--=========================================================================
PROCEDURE load_combination
( p_batch_id             IN  NUMBER
, p_vendor_id            IN  NUMBER
, p_vendor_site_id       IN  NUMBER
, p_inventory_item_id    IN  NUMBER
, p_organization_id      IN  NUMBER
)
IS
l_debug              NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_count              NUMBER;
BEGIN

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
	( '>> Load Combination(p_batch_id):'||p_batch_id,'INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

  -- Insert records to the temp table that do belong to
  -- a global agreement

  -- Insert records to the temp table
  -- Group the records by use of the distinct clause
  -- Bug 5092489. Query modified to eliminate use of MMT and DISTINCT clause
  INSERT INTO MTL_CONSUMPTION_TXN_TEMP mctt
  ( mctt.transaction_source_id
  , mctt.inventory_item_id
  , mctt.organization_id
  , mctt.owning_organization_id
  /* Bug 4969421  Starts here*/
  /* We pass the blanket_price (from MCT) instead of the transaction_cost from MMT */
  , mctt.transaction_cost
  /* Bug 4969421  Ends here*/
  , mctt.batch_id
  , mctt.tax_code_id
  , mctt.tax_rate
  , mctt.recoverable_tax
  , mctt.non_recoverable_tax
  , mctt.tax_recovery_rate
  , mctt.accrual_account_id
  , mctt.charge_account_id
  , mctt.variance_account_id
  , mctt.rate_type
  , mctt.rate
  , mctt.transaction_date
  , mctt.global_agreement_flag
  , mctt.net_qty
  /* Bug 11900144. Addition of po_line_id */
  , mctt.po_line_id
  )
  SELECT
    mct.transaction_source_id
  , mct.inventory_item_id
  , mct.organization_id
  , mct.owning_organization_id
  ,	mct.blanket_price
  /* Bug 4969421  Ends here*/
  , p_batch_id
  , NVL(mct.tax_code_id,-1)
  , NVL(mct.tax_rate,-1)
  , NVL(mct.recoverable_tax,0)
  , NVL(mct.non_recoverable_tax,0)
  , NVL(mct.tax_recovery_rate,0)
  , mct.accrual_account_id
  , mct.charge_account_id
  , mct.variance_account_id
  , NVL(mct.rate_type,'##')
  , NVL(mct.rate,-1)
  , TRUNC(mct.transaction_date)
  , mct.global_agreement_flag
  , SUM(mct.net_qty)
  /* Bug 11900144. Addition of po_line_id */
  , mct.po_line_id
  FROM
    MTL_CONSUMPTION_TRANSACTIONS mct
  , po_vendor_sites_all pvsa
  WHERE mct.owning_organization_id = pvsa.vendor_site_id
    AND pvsa.vendor_id = NVL(p_vendor_id,pvsa.vendor_id)
    AND mct.owning_organization_id =
        NVL(p_vendor_site_id,mct.owning_organization_id)
    AND mct.inventory_item_id = NVL(p_inventory_item_id,mct.inventory_item_id)
    AND mct.organization_id = NVL(p_organization_id,mct.organization_id)
    AND mct.consumption_processed_flag IN ('N', 'E')
    AND mct.batch_id = p_batch_id
  GROUP BY
   mct.transaction_source_id
  , mct.inventory_item_id
  , mct.organization_id
  , mct.owning_organization_id
  , mct.blanket_price
  /* Bug 11900144. Addition of po_line_id */
  , mct.po_line_id
  , mct.tax_code_id
  , mct.tax_rate
  , mct.recoverable_tax
  , mct.non_recoverable_tax
  , mct.tax_recovery_rate
  , mct.accrual_account_id
  , mct.charge_account_id
  , mct.variance_account_id
  , mct.rate_type
  , mct.rate
  , mct.global_agreement_flag
  , TRUNC(mct.transaction_date)
;

    -- Deleted unused commented code as part of bug 11900144

  select count(*) into l_count
  from MTL_CONSUMPTION_TXN_TEMP where batch_id = p_batch_id;

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
     ( 'temp table count: ' || l_count ,'INV_CONSUMPTION_ADVICE_PROC'
      , 9
     );

    INV_LOG_UTIL.trace
    ( '<< Load Combination','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;
EXCEPTION

  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
     INV_LOG_UTIL.trace
     ( SQLCODE  || ' : ' || SQLERRM ,'INV_CONSUMPTION_ADVICE_PROC'
      , 9
     );
    END IF;

    FND_MESSAGE.set_name('INV', 'INV_CONS_SUP_LD_COM');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END load_combination;


--========================================================================
-- PROCEDURE : Load_Combination_prf      PRIVATE
-- COMMENT   : This procedure will load all the records of a context batch
--             from MTL_CONSUMPTION_TRANSACTIONS to
--             MTL_CONSUMPTION_TRANSACTIONS_TEMP
--             If the batch_id passed is -1 then the call is from the
--             manager in which case all records with a
--             processed_consumption_flag are loaded.
--             The insert statement will also be selective by the
--             input parameters p_txn_s_id, p_item_id and p_org_id
--=========================================================================
PROCEDURE load_combination_prf
( p_batch_id             IN  NUMBER
, p_vendor_id            IN  NUMBER
, p_vendor_site_id       IN  NUMBER
, p_inventory_item_id    IN  NUMBER
, p_organization_id      IN  NUMBER
)
IS
l_debug              NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_count              NUMBER;
BEGIN

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> Load Combination_prf(p_batch_id)'||p_batch_id,'INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

  --Bug 5092489. Modified insert statement to eliminate use of MMT and DISTINCT clause
  INSERT INTO MTL_CONSUMPTION_TXN_TEMP mctt
  ( mctt.transaction_source_id
  , mctt.inventory_item_id
  , mctt.organization_id
  , mctt.owning_organization_id
  /* Bug 4969421  Starts here*/
  /* We pass the blanket_price (from MCT) instead of the transaction_cost from MMT */
  , mctt.transaction_cost
  /* Bug 4969421  Ends here*/
  , mctt.batch_id
  , mctt.tax_code_id
  , mctt.tax_rate
  , mctt.recoverable_tax
  , mctt.non_recoverable_tax
  , mctt.tax_recovery_rate
  , mctt.accrual_account_id
  , mctt.charge_account_id
  , mctt.variance_account_id
  , mctt.rate_type
  , mctt.rate
  , mctt.transaction_date
  , mctt.global_agreement_flag
  , mctt.net_qty
  /* Bug 11900144. Addition of po_line_id */
  , mctt.po_line_id
  )
  SELECT
    mct.transaction_source_id
  , mct.inventory_item_id
  , mct.organization_id
  , mct.owning_organization_id
  , mct.blanket_price
  , p_batch_id
  , NVL(mct.tax_code_id,-1)
  , NVL(mct.tax_rate,-1)
  , NVL(mct.recoverable_tax,0)
  , NVL(mct.non_recoverable_tax,0)
  , NVL(mct.tax_recovery_rate,0)
  , mct.accrual_account_id
  , mct.charge_account_id
  , mct.variance_account_id
  , NVL(mct.rate_type,'##')
  , NVL(mct.rate,-1)
 /* Start  Bug 6388514  Splitting the deode function into two different  INSERT into MCT */
--, DECODE(mct.global_agreement_flag, 'Y', TRUNC(mct.transaction_date),'N', TRUNC(MAX(mct.transaction_date)))
  , TRUNC(mct.transaction_date)
/* End  Bug 6388514 */
  , mct.global_agreement_flag
  , SUM(mct.net_qty)
  /* Bug 11900144. Addition of po_line_id */
  , mct.po_line_id
  FROM
    MTL_CONSUMPTION_TRANSACTIONS mct
  , po_vendor_sites_all pvsa
  WHERE mct.owning_organization_id = pvsa.vendor_site_id
    AND pvsa.vendor_id = NVL(p_vendor_id,pvsa.vendor_id)
    AND mct.owning_organization_id =
        NVL(p_vendor_site_id,mct.owning_organization_id)
    AND mct.inventory_item_id = NVL(p_inventory_item_id,mct.inventory_item_id)
    AND mct.organization_id = NVL(p_organization_id,mct.organization_id)
    AND mct.consumption_processed_flag IN ('N','E')
    AND mct.batch_id = p_batch_id
 /* Start  Bug 6388514 */
    AND mct.global_agreement_flag = 'Y'
 /* End  Bug 6388514 */
  GROUP BY
   mct.transaction_source_id
  , mct.inventory_item_id
  , mct.organization_id
  , mct.owning_organization_id
  , mct.blanket_price
  /* Bug 11900144. Addition of po_line_id */
  , mct.po_line_id
  , mct.tax_code_id
  , mct.tax_rate
  , mct.recoverable_tax
  , mct.non_recoverable_tax
  , mct.tax_recovery_rate
  , mct.accrual_account_id
  , mct.charge_account_id
  , mct.variance_account_id
  , mct.rate_type
  , mct.rate
  , mct.global_agreement_flag
  , TRUNC(mct.transaction_date)
  ;

    -- Deleted unused commented code as part of bug 11900144

/* Start  Bug 6388514   INSERT into MCT  for global_agreement_flag = 'N' */
  INSERT INTO MTL_CONSUMPTION_TXN_TEMP mctt
  ( mctt.transaction_source_id
  , mctt.inventory_item_id
  , mctt.organization_id
  , mctt.owning_organization_id
  , mctt.transaction_cost
  , mctt.batch_id
  , mctt.tax_code_id
  , mctt.tax_rate
  , mctt.recoverable_tax
  , mctt.non_recoverable_tax
  , mctt.tax_recovery_rate
  , mctt.accrual_account_id
  , mctt.charge_account_id
  , mctt.variance_account_id
  , mctt.rate_type
  , mctt.rate
  , mctt.global_agreement_flag
  , mctt.net_qty
  /* Bug 11900144. Addition of po_line_id */
  , mctt.po_line_id
  )
  SELECT
    mct.transaction_source_id
  , mct.inventory_item_id
  , mct.organization_id
  , mct.owning_organization_id
  , mct.blanket_price
  , p_batch_id
  , NVL(mct.tax_code_id,-1)
  , NVL(mct.tax_rate,-1)
  , NVL(mct.recoverable_tax,0)
  , NVL(mct.non_recoverable_tax,0)
  , NVL(mct.tax_recovery_rate,0)
  , mct.accrual_account_id
  , mct.charge_account_id
  , mct.variance_account_id
  , NVL(mct.rate_type,'##')
  , NVL(mct.rate,-1)
  , mct.global_agreement_flag
  , SUM(mct.net_qty)
  /* Bug 11900144. Addition of po_line_id */
  , mct.po_line_id
  FROM
    MTL_CONSUMPTION_TRANSACTIONS mct
  , po_vendor_sites_all pvsa
  WHERE mct.owning_organization_id = pvsa.vendor_site_id
    AND pvsa.vendor_id = NVL(p_vendor_id,pvsa.vendor_id)
    AND mct.owning_organization_id =
        NVL(p_vendor_site_id,mct.owning_organization_id)
    AND mct.inventory_item_id = NVL(p_inventory_item_id,mct.inventory_item_id)
    AND mct.organization_id = NVL(p_organization_id,mct.organization_id)
    AND mct.consumption_processed_flag IN ('N','E')
    AND mct.batch_id = p_batch_id
    AND mct.global_agreement_flag = 'N'
  GROUP BY
   mct.transaction_source_id
  , mct.inventory_item_id
  , mct.organization_id
  , mct.owning_organization_id
  , mct.blanket_price
  /* Bug 11900144. Addition of po_line_id */
  , mct.po_line_id
  , mct.tax_code_id
  , mct.tax_rate
  , mct.recoverable_tax
  , mct.non_recoverable_tax
  , mct.tax_recovery_rate
  , mct.accrual_account_id
  , mct.charge_account_id
  , mct.variance_account_id
  , mct.rate_type
  , mct.rate
  , mct.global_agreement_flag
  ;
/* End  Bug 6388514  */

/* Start bug 6388514 Update transaction_date in MCTT */
   UPDATE/*+ leading(mctt) */  MTL_CONSUMPTION_TXN_TEMP mctt
   SET mctt.transaction_date =
    (SELECT
       TRUNC(MAX(mct.transaction_date))
     FROM
       --MTL_MATERIAL_TRANSACTIONS mmt
       MTL_CONSUMPTION_TRANSACTIONS mct
     WHERE --mct.transaction_id = mmt.transaction_id  AND
       mct.transaction_source_id = mctt.transaction_source_id
       AND mct.inventory_item_id = mctt.inventory_item_id
       AND mct.organization_id = mctt.organization_id
   	  /* Bug 4969420  Starts here*/
   	  /* We use the blanket_price (from MCT) instead of the transaction_cost from MMT */
       --AND mmt.transaction_cost = mctt.transaction_cost
   	  AND mct.blanket_price = mctt.transaction_cost
   	  /* Bug 4969420  Ends here*/
       /* Bug 11900144. Addition of po_line_id clause */
       AND mct.po_line_id=mctt.po_line_id
       AND NVL(mct.tax_code_id,-1) = NVL(mctt.tax_code_id,-1)
       AND NVL(mct.recoverable_tax,0) = NVL(mctt.recoverable_tax,0)
       AND NVL(mct.non_recoverable_tax,0) = NVL(mctt.non_recoverable_tax,0)
       AND NVL(mct.tax_recovery_rate,0) = NVL(mctt.tax_recovery_rate,0)
       AND NVL(mct.rate,-1) = NVL(mctt.rate,-1)
       AND mct.accrual_account_id = mctt.accrual_account_id
       AND mct.charge_account_id = mctt.charge_account_id
       AND mct.variance_account_id = mctt.variance_account_id
       AND mct.global_agreement_flag = 'N'
       AND mct.consumption_processed_flag IN ('N', 'E'))
  WHERE mctt.transaction_date IS NULL;
/* End bug 6388514  */

  select count(*) into l_count
  from MTL_CONSUMPTION_TXN_TEMP where batch_id = p_batch_id;

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
     ( 'temp table count: ' || l_count ,'INV_CONSUMPTION_ADVICE_PROC'
      , 9
     );

    INV_LOG_UTIL.trace
    ( '<< Load Combination_prf','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
     INV_LOG_UTIL.trace
     ( SQLCODE  || ' : ' || SQLERRM ,'INV_CONSUMPTION_ADVICE_PROC'
      , 9
     );
    END IF;

    FND_MESSAGE.set_name('INV', 'INV_CONS_SUP_LD_COM');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END load_combination_prf;




--========================================================================
-- PROCEDURE  : Validate_Blanket     PRIVATE
-- PARAMETERS : p_batch_id           Batch Id
-- COMMENT    : Populates the valid_flag if the blanket is valid
--========================================================================
PROCEDURE validate_blanket
( p_batch_id NUMBER)
IS

--=================
-- CURSORS
--=================

CURSOR valid_csr_type IS
SELECT DISTINCT
  transaction_source_id
, inventory_item_id
, owning_organization_id
FROM
  mtl_consumption_txn_temp
WHERE batch_id=p_batch_id;

--=================
-- VARIABLES
--=================

l_count                  NUMBER;
l_header_id              NUMBER;
l_item_id                NUMBER;
l_owning_organization_id NUMBER;
l_org_id                 NUMBER;
l_valid_flag             VARCHAR2(1);
l_debug                  NUMBER :=
                           NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_error_msg				 VARCHAR2(100) := 'INV_SUP_CONS_NO_BPO_EXISTS';
l_error_explanation  VARCHAR2(240) := NULL;
l_blanket_po_number  VARCHAR2(20)  := NULL;


BEGIN

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> Validate Blanket','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

  OPEN valid_csr_type;
  LOOP
    FETCH valid_csr_type
    INTO l_header_id
        ,l_item_id
        ,l_owning_organization_id;

    IF valid_csr_type%NOTFOUND
    THEN
      EXIT;
    END IF;

    -- Check to see if the blanket is still valid

    SELECT
      COUNT(1)
    INTO
      l_count
    FROM
      po_headers_all poh
    , po_lines_all pol
    WHERE poh.po_header_id = pol.po_header_id
      AND (TRUNC(NVL(poh.start_date,SYSDATE -1)) <= TRUNC(SYSDATE))
      AND (TRUNC(NVL(poh.end_date+NVL(FND_PROFILE.VALUE('PO_REL_CREATE_TOLERANCE'),0),SYSDATE +1)) >= TRUNC(SYSDATE))	-- Bug 8397146
      AND (TRUNC(NVL(pol.expiration_date,SYSDATE )) >= TRUNC(SYSDATE))
      AND poh.approved_flag = 'Y'
      AND NVL(poh.frozen_flag, 'N') = 'N'
      AND (NVL(poh.cancel_flag,'N') = 'N'
           OR NVL(pol.cancel_flag,'N') = 'N')
      AND NVL(pol.closed_code,'OPEN') = 'OPEN'
      AND poh.po_header_id = l_header_id
      AND pol.item_id = l_item_id;

    l_org_id :=
      INV_THIRD_PARTY_STOCK_UTIL.get_org_id(l_owning_organization_id);

    IF l_count > 0
    THEN

      -- If it is a Global agreement, mark as valid_flag = 'G'
      IF INV_PO_THIRD_PARTY_STOCK_MDTR.is_global(l_header_id)
      THEN
         l_valid_flag := 'G';
      ELSE
         l_valid_flag := 'Y';
      END IF;

      UPDATE mtl_consumption_txn_temp
      SET valid_flag = l_valid_flag
         ,org_id = l_org_id
      WHERE transaction_source_id = l_header_id
      AND inventory_item_id = l_item_id
      AND valid_flag IS NULL;
    INV_LOG_UTIL.trace
    ( 'VALID line : item - '
	  ||l_item_id || ', source - '|| l_header_id || ', org - '|| l_org_id,
	  'INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );

    ELSE

      UPDATE mtl_consumption_txn_temp
      SET valid_flag = 'N'
         ,org_id = l_org_id
      WHERE transaction_source_id = l_header_id
      AND inventory_item_id = l_item_id
      AND valid_flag IS NULL;

	  /* bug 5113064  - Start */
	  /* delete all records in MCT_TEMP that have valid flag as 'N' */
	  /* Also update MCT records with error status and message */
          /*Bug 5092489. Query is modified to eliminate use of MMT. */
	  UPDATE mtl_consumption_transactions SET
	    consumption_processed_flag = 'E'
	  , error_code = l_error_msg
          WHERE transaction_source_id = l_header_id
          AND inventory_item_id = l_item_id
          AND owning_organization_id = l_owning_organization_id
	  AND consumption_processed_flag IN ('N','E')
          AND batch_id = p_batch_id;
	  /*WHERE transaction_id IN
	    (SELECT transaction_id FROM mtl_material_transactions
	     WHERE transaction_source_id = l_header_id
	     AND inventory_item_id = l_item_id
		 AND owning_organization_id = l_owning_organization_id)
	  AND consumption_processed_flag IN ('N','E')
	 AND batch_id = p_batch_id;
         */

	  DELETE FROM mtl_consumption_txn_temp
	  WHERE valid_flag = 'N'
	  AND org_id = l_org_id
	  AND transaction_source_id = l_header_id
	  AND inventory_item_id = l_item_id;
	  /* bug 5113064  - End */
    INV_LOG_UTIL.trace
    ( '**** INVALID line  : item - '
	  ||l_item_id || ', source - '|| l_header_id || ', org - '|| l_org_id,
	  'INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );

    END IF;

  END LOOP;

  CLOSE valid_csr_type;

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '<< Validate Blanket','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF valid_csr_type% ISOPEN
    THEN
      CLOSE valid_csr_type;
    END IF;
END validate_blanket;

--========================================================================
-- PROCEDURE : Load_Interface_Tables            PRIVATE
-- PARAMETERS: p_transaction_source_id          Material transaction id
--             p_batch_id                       Batch id
-- COMMENT   : This procedure is called from the worker. It loads
--           : unprocessed summarized change of ownership transactions
--           : from the consumption temp table MTL_CONSUMPTION_TXN_TEMP
--           : into the PO interface tables in preperation for the
--           : creation of either a consumption advice or standard PO
--           : Once this is done the autocreate procedure is called
--           : to process the interface tables and create the release.
--           : The corresponding records are updated with the result,
--           : whether success or failure. If success the last billing date
--           : of the associated asl_id is also updated.
-- CHANGE    : Added secondary quantity in the interface table insert.
--========================================================================

PROCEDURE load_interface_tables
( p_batch_id                IN NUMBER
, x_return_status           OUT NOCOPY VARCHAR2
)

IS

--=================
-- VARIABLES
--=================

l_header_id             NUMBER;
l_transaction_source_id NUMBER;
l_interface_header_id   NUMBER;
l_interface_line_id     NUMBER;
l_item_id               NUMBER;
l_organization_id       NUMBER;
l_quantity              NUMBER;
l_po_price              NUMBER;
l_date                  DATE;
l_vendor_site_id        NUMBER;
l_blanket_id            NUMBER;
l_lines                 NUMBER;
l_org_id                NUMBER;
l_user                  NUMBER;
l_document_type_code    VARCHAR2(30);
-- Bug 5092489. Commented because not used.
--l_document_subtype      VARCHAR2(30);
l_location_id           NUMBER;
-- Bug 5092489. Commented because not used.
--l_ship_to_location      NUMBER;
l_bill_to_location      NUMBER;

l_vendor_ship_to_location NUMBER;
l_vendor_bill_to_location NUMBER;
l_recoverable_tax       NUMBER;
l_nonrecoverable_tax    NUMBER;
l_recovery_rate         NUMBER;
l_accrual_account_id    NUMBER;
l_charge_account_id    NUMBER;
l_variance_account_id  NUMBER;
l_tax_code_id          NUMBER;
-- Bug 5092489. Commented because not used.
--l_description          VARCHAR2(100);
--l_category_id          NUMBER;
l_owning_organization_id NUMBER;
l_document_id          NUMBER;
l_error_code           NUMBER;
l_vendor_id            NUMBER;
l_rate                 NUMBER;
-- Bug 5092489. Commented because not used.
--l_coa_id               NUMBER;
l_rate_type            VARCHAR2(30);
l_global_rate_type     VARCHAR2(30);
l_global_rate          NUMBER;
l_global_rate_date     DATE;
l_valid_flag           VARCHAR2(1);
l_po_num_code          VARCHAR2(25);
l_consumption_po_header_id NUMBER;
l_consumption_release_id   NUMBER;
l_return_status        VARCHAR2(1);
l_archive_status       VARCHAR2(1);
l_archive_type         VARCHAR2(30);
l_archive_subtype      VARCHAR2(30);
l_msg_data             VARCHAR2(2000);
l_document_number      VARCHAR2(30);
l_current_org_id       NUMBER;
l_error_msg            VARCHAR2(30);
l_consumption_processed_flag VARCHAR2(1);
-- Bug 5092489. Commented because not used.
--l_po_line_id           NUMBER;
--l_from_uom_code        VARCHAR2(25);
--l_to_uom_code          VARCHAR2(25);
l_primary_uom          VARCHAR2(25);
l_purchasing_uom       VARCHAR2(25);
l_pay_on_flag          VARCHAR2(25);
l_pay_on_code          VARCHAR2(25);
-- Bug 5092489. Commented because not used.
--l_conv_rate            NUMBER;
l_conv_qty             NUMBER;
-- Bug 5092489. Commented because not used.
--l_uom_rate             NUMBER;
l_asl_id               NUMBER;
l_appl_id              NUMBER;
l_api_version          NUMBER;
-- Bug 5092489. Commented because not used.
--l_precision            NUMBER;
l_debug                NUMBER :=
                         NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_vendor_name          VARCHAR2(240);
l_vendor_site          VARCHAR2(15);
l_transaction_date     DATE;
l_currency_code        VARCHAR2(15);
-- Bug 5092489. Commented because not used.
--l_fin_curr_code        VARCHAR2(15);
l_func_po_price        NUMBER;
l_profile_option	   VARCHAR2(1);

 --l_location_id_OU      NUMBER ;
TYPE g_asl_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_asl_cons_tab         g_asl_tbl_type;
l_curr_asl_index   NUMBER := 0;

/* INVCONV */
l_secondary_quantity  NUMBER;
l_secondary_uom       VARCHAR2(50);
-- Variables Defined for the fix of Bug 3959073
l_inv_org_location     NUMBER;
l_header_ship_to_location NUMBER;
/* Bug 4969420  Starts here*/
/* We use the blanket_price (from MCT) instead of the transaction_cost from MMT */
/* This would be passed to the po_lines_interface */
l_blanket_price  NUMBER;
/* Bug 4969420 Ends here */

/* Bug 11900144. Addition of po_line_id */
l_po_line_id NUMBER;

/* bug 5373370 - Start */
l_dist_interface_header_id NUMBER;
/* bug 5373370 - End */


--=================
-- CURSORS
--=================

-- Cursor to get the header info to insert into the
-- po_headers_interface table.

CURSOR header_csr_type IS
  SELECT DISTINCT
    transaction_source_id
  , valid_flag
  , org_id
  , accrual_account_id
  , charge_account_id
  , variance_account_id
  , rate_type
  /* bug 5210850 - Start */
  --, TRUNC(transaction_date)
  , DECODE(global_agreement_flag,'Y',TRUNC(transaction_date),
      DECODE(l_profile_option,'N', NULL,TRUNC(transaction_date)) )
  /* bug 5210850 - End */
  , rate
  , owning_organization_id
  , currency_code
  FROM
    mtl_consumption_txn_temp
  WHERE  batch_id = p_batch_id;

-- Cursor to get the line info to insert into the
-- po_lines_interface table for the corresponding header that is inserted.

CURSOR line_csr_type IS
  SELECT
    inventory_item_id
  , organization_id
  , net_qty
  , secondary_net_qty /* INVCONV */
  , transaction_cost  -- This is the blanket_price from MCT  Bug 4969421
  , TRUNC(transaction_date)
  , NVL(tax_code_id,-1)
  , rate
  , owning_organization_id
  , recoverable_tax
  , non_recoverable_tax
  , tax_recovery_rate
  , asl_id
  /* Bug 11900144. Addition of po_line_id */
  , po_line_id
  FROM
    mtl_consumption_txn_temp
  WHERE transaction_source_id  = l_blanket_id
  AND   valid_flag             = l_valid_flag
  AND   TRUNC(transaction_date)  = NVL(l_transaction_date, TRUNC(transaction_date))
  AND   rate_type                = NVL(l_global_rate_type,'##')
  AND   rate                   = NVL(l_global_rate,-1)
  AND   owning_organization_id = l_vendor_site_id
  AND   accrual_account_id     = l_accrual_account_id
  AND   charge_account_id      = l_charge_account_id
  AND   variance_account_id    = l_variance_account_id;

/* INVCONV cursor to get secondary unit of measure for the item*/
CURSOR cr_get_sec_uom IS
SELECT m.unit_of_measure
FROM   mtl_system_items i,
mtl_units_of_measure m
WHERE  i.inventory_item_id = l_item_id
AND    i.organization_id   = l_organization_id
AND    i.secondary_uom_code = m.uom_code;

BEGIN

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> Load Interface Tables','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_user          := FND_PROFILE.value('USER_ID');
  l_org_id        := FND_PROFILE.value('ORG_ID');
  l_return_status := x_return_status;

  /* bug 5200436 - Start */
  l_profile_option := NVL(FND_PROFILE.value('INV_SUPPLIER_CONSIGNED_GROUPING'),'N');
  /* bug 5200436 - End */

 l_curr_asl_index := l_asl_cons_tab.COUNT;

  INV_CONSUMPTION_ADVICE_PROC.validate_blanket(p_batch_id);

  l_document_type_code := 'PO';

  -- Get the header info

  OPEN header_csr_type;
  LOOP
    FETCH header_csr_type
    INTO
      l_blanket_id
    , l_valid_flag
    , l_current_org_id
    , l_accrual_account_id
    , l_charge_account_id
    , l_variance_account_id
    , l_global_rate_type
    , l_global_rate_date
    , l_global_rate
    , l_vendor_site_id
    , l_currency_code;

    EXIT WHEN header_csr_type%NOTFOUND;

    IF  l_valid_flag = 'N'
    THEN
      l_error_msg := 'INV_SUP_CONS_NO_BPO_EXISTS';

      IF (l_debug = 1)
      THEN
        INV_LOG_UTIL.trace
        ( '>> No valid BPO:'||l_blanket_id,'INV_CONSUMPTION_ADVICE_PROC'
        , 9
        );
      END IF;

      INV_CONSUMPTION_ADVICE_PROC.update_consumption
       (p_consumption_po_header_id  => NULL
       ,p_consumption_release_id    => NULL
       ,p_error_code                => l_error_msg
       ,p_batch_id                  => p_batch_id
       ,p_transaction_source_id     => l_blanket_id
       ,p_consumption_processed_flag => 'E'
       ,p_accrual_account_id        => l_accrual_account_id
       ,p_charge_account_id         => l_charge_account_id
       ,p_variance_account_id       => l_variance_account_id
       ,p_transaction_date          => l_global_rate_date
       ,p_global_rate_type          => l_global_rate_type
       ,p_global_rate               => l_global_rate
       ,p_vendor_site_id            => l_vendor_site_id);

       l_error_msg := NULL;

    ELSE -- Valid Blanket

      -- If the operating unit from which the concurrent pgm is run is
      -- different than the operating unit of the summarized transaction,
      -- set the OU context to be the OU of summarized transactions.

      IF l_org_id <> l_current_org_id
      THEN

        INV_THIRD_PARTY_STOCK_UTIL.set_ou_context
          ( p_org_id         => l_current_org_id
         --, p_vendor_site_id => l_vendor_site_id
          --, x_appl_id        => l_appl_id
          );
        --MO_GLOBAL.Init('PO');
        MO_GLOBAL.set_policy_context('S',l_current_org_id);
      ELSE
        --MO_GLOBAL.Init('PO');
        MO_GLOBAL.set_policy_context('S',l_org_id);
      END IF;


      -- Bug 5092489. Query modified.
      SELECT
--         NVL(povs.ship_to_location_id,pov.ship_to_location_id)
--       , NVL(povs.bill_to_location_id,pov.bill_to_location_id)
         /* fix for bug 5230913 - Start */
		 povs.ship_to_location_id
       , povs.bill_to_location_id
       , pov.vendor_id			--Bug 4723164
         /* fix for bug 5230913 - End */
      INTO
        l_vendor_ship_to_location
      , l_vendor_bill_to_location
      , l_vendor_id			--Bug 4723164
      FROM
        po_vendor_sites_all povs
      , po_vendors pov
      WHERE povs.vendor_id = pov.vendor_id
        AND povs.vendor_site_id = l_vendor_site_id;

     -- Bug 5092489. Query modified
     /* SELECT
        glc.PRECISION
      , glc.currency_code
      , fsp.ship_to_location_id
      , fsp.bill_to_location_id
      INTO
        l_precision
      , l_fin_curr_code
      , l_ship_to_location
      , l_bill_to_location
      FROM
        financials_system_params_all fsp
      , gl_sets_of_books glb
      , gl_currencies glc
      WHERE  fsp.set_of_books_id = glb.set_of_books_id
        AND  glb.currency_code   = glc.currency_code
        AND  NVL(fsp.org_id,-99) = NVL(l_current_org_id,-99);
      */
      SELECT
       fsp.bill_to_location_id
      INTO
       l_bill_to_location
      FROM
       financials_system_params_all fsp
      WHERE  NVL(fsp.org_id,-99) = NVL(l_current_org_id,-99);

      SELECT
        user_defined_po_num_code
      INTO
        l_po_num_code
      FROM
        po_system_parameters_all
      WHERE  NVL(org_id,-99) = NVL(l_current_org_id,-99);

      IF l_po_num_code <> 'AUTOMATIC'
      THEN
        SELECT
          segment1
        INTO
          l_document_number
        FROM
          po_headers_all
        WHERE po_header_id = l_blanket_id;

      ELSE
        l_document_number := NULL;
      END IF;

      SELECT
        po_headers_interface_s.NEXTVAL
      INTO
        l_interface_header_id
      FROM
        DUAL;

      l_transaction_date := l_global_rate_date;

      IF (l_valid_flag = 'G') AND (NVL(l_global_rate,-1) = -1)
      THEN
        l_global_rate_type  := NULL;
        l_global_rate_date  := NULL;
        l_global_rate       := NULL;
      END IF;

      -- Check the vendor sites for pay on code

      SELECT
        pay_on_code
      INTO
        l_pay_on_code
      FROM
        po_vendor_sites_all
      WHERE vendor_site_id = l_vendor_site_id;

      IF NVL(l_pay_on_code,'NONE') IN ('RECEIPT_AND_USE','USE')
      THEN
        l_pay_on_flag := 'USE';
      ELSE
        l_pay_on_flag := NULL;
      END IF;

      --l_ship_to_location := NVL(l_vendor_ship_to_location,l_ship_to_location);
      l_bill_to_location := NVL(l_vendor_bill_to_location,l_bill_to_location);

      --l_location_id_OU := NULL ;
      l_location_id :=
        INV_THIRD_PARTY_STOCK_UTIL.get_location(l_current_org_id);

      --l_location_id_OU  := l_location_id ;

      INSERT INTO po_headers_interface
       ( interface_header_id
       , interface_source_code
       , batch_id
       , document_type_code
       , document_subtype
       , document_num
       , vendor_id
       , vendor_site_id
       , agent_id
       , currency_code
       , rate_type_code
       , rate_date
       , rate
       , ship_to_location_id
       , bill_to_location_id
       , terms_id
       , fob
       , pay_on_code
       , freight_terms
       , min_release_amount
       , creation_date
       , created_by
       , group_code
       , action
       , org_id
       )
      SELECT
        l_interface_header_id
      , 'CONSUMPTION_ADVICE'
      , p_batch_id
      , l_document_type_code
      , DECODE(l_valid_flag,'Y','RELEASE','STANDARD')
      , DECODE(l_valid_flag,'Y',segment1,NULL)
      , DECODE(l_valid_flag,'G',l_vendor_id,vendor_id)			--Bug 4723164
      , DECODE(l_valid_flag,'G',l_vendor_site_id,vendor_site_id)	--Bug 4723164
      , agent_id
      , currency_code
      , DECODE(l_valid_flag,'G',l_global_rate_type,rate_type)
      , DECODE(l_valid_flag,'G',l_global_rate_date,rate_date)
      , DECODE(l_valid_flag,'G',l_global_rate,rate)
      --, DECODE(l_valid_flag,'G',NVL(l_ship_to_location,l_location_id),ship_to_location_id)
      -- Bug Fix for 3959073
      -- Ship To Location to be set at the Header of the Consumption Advice should
      -- be taken from the BPA, regardless if the BPA is local or global
      , ship_to_location_id
      , DECODE(l_valid_flag,'G',NVL(l_bill_to_location,l_location_id),bill_to_location_id)
      , terms_id
      , fob_lookup_code
      , l_pay_on_flag
      , freight_terms_lookup_code
      , min_release_amount
      , SYSDATE
      , l_user
      , 'DEFAULT'
      , 'NEW'
      , l_current_org_id
      FROM
        po_headers_all
      WHERE po_header_id = l_blanket_id;


      -- Now fetch info. related to the lines that we need to insert

      OPEN line_csr_type;
      LOOP
        FETCH line_csr_type
        INTO
          l_item_id
        , l_organization_id
        , l_quantity
        , l_secondary_quantity -- INVCONV
        , l_po_price
        , l_date
        , l_tax_code_id
        , l_rate
        , l_owning_organization_id
        , l_recoverable_tax
        , l_nonrecoverable_tax
        , l_recovery_rate
        , l_asl_id
        /* Bug 11900144. Addition of po_line_id */
        , l_po_line_id
        ;

	    /* Bug 4969421  Starts here*/
  	    /*We use the blanket_price (from MCT) instead of the transaction_cost from MMT*/
		/*l_po_price was initially gettting the transaction cost from MMT.*/
		/*po_price now stores the blanket_price (PO currency) in MCT */
		/*l_blanket_price would be used to populate po_lines_interface. No conversions required */
		/*as blanket_price is in PO currency */
		l_blanket_price := l_po_price ;
		/* Bug 4969421 Ends here */


        EXIT WHEN line_csr_type%NOTFOUND;

       IF (l_debug = 1)
        THEN
          INV_LOG_UTIL.trace
          ( '>> Load Interface Tables'||l_asl_id,'INV_CONSUMPTION_ADVICE_PROC'
           , 9
           );
        END IF;

        l_asl_cons_tab(l_curr_asl_index) := l_asl_id;
        l_curr_asl_index := l_curr_asl_index+1;

        IF (l_debug = 1)
        THEN
          INV_LOG_UTIL.trace
          ( '>> Load Interface Tables:','INV_CONSUMPTION_ADVICE_PROC'
           , 9
           );
        END IF;

        -- Bug 5092489. Retrival of po_line_id is commented
        -- because not used.
        SELECT
          unit_meas_lookup_code
        --, po_line_id
        INTO
          l_purchasing_uom
        --, l_po_line_id
        FROM po_lines_all
        WHERE po_header_id = l_blanket_id
        AND   item_id      = l_item_id
        AND   ROWNUM       = 1;

        l_primary_uom := INV_THIRD_PARTY_STOCK_UTIL.get_primary_uom
                        ( p_inventory_item_id=> l_item_id
                        , p_organization_id  => l_organization_id
                         );
        IF (l_debug = 1)
        THEN
          INV_LOG_UTIL.trace
          ( '>> Load Interface Tables_prf(UOM):'||l_primary_uom,'INV_CONSUMPTION_ADVICE_PROC'
           , 9
           );
        END IF;

        -- If the primary UOM of the item is different than the purchasing
        -- UOM, convert the quantity to purchasing UOM.

        IF l_primary_uom <> NVL(l_purchasing_uom,l_primary_uom)
        THEN
          IF (l_debug = 1)
          THEN
            INV_LOG_UTIL.trace
            ( '>> Load Interface Tables_prf:(UOM differ)','INV_CONSUMPTION_ADVICE_PROC'
             , 9
             );
            INV_LOG_UTIL.trace
            ( 'Primary,Purchasing UOM is '||l_primary_uom||' '||l_purchasing_uom,'INV_CONSUMPTION_ADVICE_PROC'
             , 9
             );
          END IF;

          l_conv_qty := INV_CONVERT.inv_um_convert
                       ( item_id             => l_item_id
                       , PRECISION           => 5
                       , from_quantity       => l_quantity
                       , from_unit           => NULL
                       , to_unit             => NULL
                       , from_name           => l_primary_uom
                       , to_name             => l_purchasing_uom
                       );

          IF l_conv_qty < 0
          THEN
            l_error_msg := 'INV_CONS_SUP_NO_UOM_CONV';
          END IF;

          /* Bug 5092489. Commented because not used in code
          INV_THIRD_PARTY_STOCK_UTIL.Get_Vendor_Info
          ( p_vendor_site_id   => l_vendor_site_id
          , x_vendor_name      => l_vendor_name
          , x_vendor_site_code => l_vendor_site
          );
          IF (l_debug = 1)
          THEN
          INV_LOG_UTIL.trace
         ( '>> UOM conversion '||l_conv_qty,'INV_CONSUMPTION_ADVICE_PROC'
          , 9
          );
          END IF;

          l_from_uom_code :=
            INV_THIRD_PARTY_STOCK_UTIL.get_uom_code
            ( p_unit_of_measure  => l_primary_uom
            , p_vendor_name      => l_vendor_name
            , p_vendor_site_code => l_vendor_site
            );

          l_to_uom_code   :=
            INV_THIRD_PARTY_STOCK_UTIL.get_uom_code
            ( p_unit_of_measure  => l_purchasing_uom
            , p_vendor_name      => l_vendor_name
            , p_vendor_site_code => l_vendor_site
            );


          IF (l_debug = 1)
          THEN
          INV_LOG_UTIL.trace
         ( '>> From UOM  '||l_from_uom_code,'INV_CONSUMPTION_ADVICE_PROC'
          , 9
          );
          INV_LOG_UTIL.trace
         ( '>> To UOM  '||l_to_uom_code,'INV_CONSUMPTION_ADVICE_PROC'
          , 9
          );
          END IF;

          INV_CONVERT.inv_um_conversion
          (item_id             => l_item_id
          ,from_unit           => l_from_uom_code
          ,to_unit             => l_to_uom_code
          ,uom_rate            => l_uom_rate
           );

          IF (l_debug = 1)
          THEN
          INV_LOG_UTIL.trace
         ( '>>UOM Rate  '||l_uom_rate,'INV_CONSUMPTION_ADVICE_PROC'
          , 9
          );
          INV_LOG_UTIL.trace
         ( '>> Qty  '||l_conv_qty,'INV_CONSUMPTION_ADVICE_PROC'
          , 9
          );
          END IF;

          IF l_uom_rate IS NULL OR l_conv_qty < 0
          THEN
            l_error_msg := 'INV_CONS_SUP_NO_UOM_CONV';
          END IF;
          */
          -- The PO price should be unit price against purchasing UOM; hence
          -- convert to unit price for purchasing UOM
         /* conversion not reqd anymore - Bug 4969421  */
		 /*
          l_po_price :=  l_po_price / NVL(l_uom_rate,1);

          IF (l_debug = 1)
          THEN
            INV_LOG_UTIL.trace
            ( '>> Load Interface Tables_prf(Price):'||l_po_price,'INV_CONSUMPTION_ADVICE_PROC'
             , 9
             );
          END IF;
		 */
        ELSE
          l_conv_qty := l_quantity;
        END IF;

        -- INVCONV retrive secondary unit of measure for the item
        -- if its not null that means item is tracked in dual units
        -- from the quantity
        IF l_secondary_quantity IS NOT NULL THEN
           OPEN cr_get_sec_uom;
           FETCH cr_get_sec_uom INTO l_secondary_uom;
           IF (cr_get_sec_uom%NOTFOUND) THEN
              CLOSE cr_get_sec_uom;
              l_secondary_quantity := NULL;
           ELSE
              CLOSE cr_get_sec_uom;
           END IF;
		END IF ;

        IF (l_debug = 1)
        THEN
          INV_LOG_UTIL.trace
          ( '>> Outside Loop(Qty):'||l_conv_qty,'INV_CONSUMPTION_ADVICE_PROC'
           , 9
           );
          INV_LOG_UTIL.trace
          ( '>> Outside Loop(Price):'||l_po_price,'INV_CONSUMPTION_ADVICE_PROC'
           , 9
           );
          INV_LOG_UTIL.trace
          ( '>> Outside Loop(error):'||l_error_msg,'INV_CONSUMPTION_ADVICE_PROC'
           , 9
           );
        END IF;

        IF l_error_msg IS NOT NULL
        THEN
          l_consumption_release_id   := NULL;
          l_consumption_po_header_id := NULL;
          l_consumption_processed_flag := 'E';
          EXIT;
        END IF;

	   /* conversion not reqd anymore - Bug 4969421  */
	   /*

        -- If the blanket is in foreign currency, convert the unit price to
        -- currency of the original blanket. THe unit price from MMT is
        -- in functional currency.

        IF NVL(l_rate,-1) = -1
        THEN
          l_po_price := l_po_price - NVL(l_nonrecoverable_tax,0);
          IF (l_debug = 1)
          THEN
            INV_LOG_UTIL.trace
            ( '>> PO Price (no conv):'||l_po_price,'INV_CONSUMPTION_ADVICE_PROC'
             , 9
             );
          END IF;
        ELSE

          l_func_po_price := l_po_price - NVL(l_nonrecoverable_tax,0);

          IF (l_debug = 1)
          THEN
            INV_LOG_UTIL.trace
            ( '>> PO Price (conv):'||l_po_price||' '||l_nonrecoverable_tax,'INV_CONSUMPTION_ADVICE_PROC'
             , 9
             );
          END IF;

          SELECT
            DECODE(NVL(fc.minimum_accountable_unit,0), 0,
            ROUND((l_func_po_price*l_conv_qty)* (1/ABS(l_rate))/l_conv_qty,
                   NVL(fc.extended_precision,fc.PRECISION)),
            ROUND(l_func_po_price* l_conv_qty/fc.minimum_accountable_unit) *
                  fc.minimum_accountable_unit*(1/ABS(l_rate))/l_conv_qty)
          INTO
            l_po_price
          FROM
            fnd_currencies fc
          WHERE fc.currency_code = NVL(l_currency_code,l_fin_curr_code);

          IF (l_debug = 1)
          THEN
            INV_LOG_UTIL.trace
            ( '>> PO Price (fnd_curr):'||l_po_price,'INV_CONSUMPTION_ADVICE_PROC'
             , 9
             );
          END IF;
	    END IF;
		 */
        -- Bug Fix for 3959073
        -- Getting the ship to location set at the PO Header of the Blanket Agreement
        SELECT
          ship_to_location_id
        INTO
          l_header_ship_to_location
        FROM
          po_headers_all
        WHERE po_header_id = l_blanket_id;

        -- Bug Fix for 3959073
        -- Getting the location of the Inventory Organization
        l_inv_org_location:= INV_THIRD_PARTY_STOCK_UTIL.get_location(l_organization_id);
        IF (l_debug = 1)
        THEN
          INV_LOG_UTIL.trace
          ( '>> Location :'||l_location_id,'INV_CONSUMPTION_ADVICE_PROC'
           , 9
           );
          INV_LOG_UTIL.trace
          ( '>> Blanket /Item :'||l_blanket_id||' '||l_item_id,'INV_CONSUMPTION_ADVICE_PROC'
           , 9
           );
          INV_LOG_UTIL.trace
          ( '>> Owning org is :'||l_owning_organization_id,'INV_CONSUMPTION_ADVICE_PROC'
           , 9
           );
        END IF;

        SELECT PO_LINES_INTERFACE_S.NEXTVAL
        INTO l_interface_line_id
        FROM DUAL;

       /* Bug 7231720 If the Profile Option PO: Automatic Document Sourcing is set to "Yes" then
          the latest valid blanket must be picked even if the blanket is not present in the Approved
	  Supplier List. There is no check for the presence of a record in the table po_asl_documents if
	  the  Profile Option PO: Automatic Document Sourcing is set to "No". The blanket is picked up
	  from MMT.TRANSACTION_SOURCE_ID when the profile is set to "No"                              */

       /* Bug 11900144. Commented the below if condition as line details are taken from MCT,
          separate insert statements based on profile value are not required */
	  --IF (nvl(fnd_profile.value('PO_AUTO_SOURCE_DOC'),'N') = 'Y') THEN

		INSERT INTO po_lines_interface
		( interface_header_id
		, interface_line_id
		, line_num
		, line_type_id
		, item_id
		, item_description
		, category_id
		, unit_of_measure
		, quantity
		, vendor_product_num
		, unit_price
		, ship_to_organization_id
		, ship_to_location_id
		, need_by_date
		, promised_date
		, creation_date
		, created_by
		, tax_code_id
		, from_header_id
		, from_line_id
		, closed_date
		, closed_by
		, receive_close_tolerance
		, closed_code
		, closed_reason
		, secondary_quantity      --/* INVCONV
		, secondary_unit_of_measure --/* INVCONV
		)
		SELECT
		  l_interface_header_id
		, l_interface_line_id
		, DECODE(l_valid_flag,'Y',line_num,NULL)
		, line_type_id
		, l_item_id
		, item_description
		, category_id
		, unit_meas_lookup_code
		, l_conv_qty
		, vendor_product_num
		,l_blanket_price
		, l_organization_id
		, NVL(l_inv_org_location,l_header_ship_to_location)
		, l_date
		, SYSDATE
		, SYSDATE
		, l_user
		, DECODE(l_tax_code_id,-1,NULL,l_tax_code_id)
		, DECODE(l_valid_flag,'G',l_blanket_id,NULL)
		, DECODE(l_valid_flag,'G',po_line_id,NULL)
		, SYSDATE
		, l_user
		, 100
		, 'CLOSED'
		, 'Consumption Advice'
		, l_secondary_quantity      --/* INVCONV
		, l_secondary_uom           --/* INVCONV
		FROM
		  po_lines_all pla
		WHERE po_header_id = l_blanket_id
		AND   item_id = l_item_id
		AND  po_line_id=l_po_line_id;
		--Bug 11900144. removed rownum condition and added po_line_id

    -- Deleted unused commented code as part of bug 11900144

        SELECT
          vendor_id
        INTO
          l_vendor_id
        FROM
          po_vendor_sites_all
        WHERE vendor_site_id = l_owning_organization_id;

        IF (l_debug = 1)
        THEN
          INV_LOG_UTIL.trace
          ( 'Populated Lines Interface','INV_CONSUMPTION_ADVICE_PROC'
           , 9
           );
        END IF;

        /* Bug 5373370 - Start */
		SELECT
		  PO_DISTRIBUTIONS_INTERFACE_S.NEXTVAL
		INTO
		  l_dist_interface_header_id
		FROM DUAL;

		IF (l_debug = 1)
        THEN
          INV_LOG_UTIL.trace
          ( '>> interface_header_id :'|| l_dist_interface_header_id,'INV_CONSUMPTION_ADVICE_PROC'
           , 9
           );
		END IF ;

		/* Bug 5373370 - End */


		INSERT INTO po_distributions_interface
         ( interface_header_id
         , interface_line_id
         , interface_distribution_id
         , quantity_ordered
         , charge_account_id
         , accrual_account_id
         , variance_account_id
         , deliver_to_location_id
         , destination_organization_id
         , recoverable_Tax
         , nonrecoverable_Tax
         , recovery_rate
         , creation_date
         , created_by
         , destination_type_code
         , rate
         , rate_date
		 /*  Bug fix 5373370 - new column addded to po_dist_interface  - Start*/
		 , INTERFACE_DISTRIBUTION_REF
		 /*  Bug fix 5373370 - End */
         )
        SELECT
          l_interface_header_id
        , l_interface_line_id
        , l_dist_interface_header_id -- bug 5373370
        , l_conv_qty
        , l_charge_account_id
        , l_accrual_account_id
        , l_variance_account_id
        --, DECODE(l_valid_flag,'G',NVL(l_ship_to_location,l_location_id),l_location_id)
        -- Bug Fix for 3959073
        -- Ship To Location to be set at the Distribution Line of the Consumption
        -- Advice should be taken from the Inventory Organization.  If the location
        -- is not defined for the Inventory Organization, then take the Ship To
        -- Location from the Header of the current Consumption Advice, i.e.,
        -- from the Header of the BPA.
        , NVL(l_inv_org_location,l_header_ship_to_location)
        , l_organization_id
        , (l_recoverable_tax*l_conv_qty)
        , (l_nonrecoverable_tax*l_conv_qty)
        , l_recovery_rate
        , SYSDATE
        , l_user
        , 'INVENTORY'
        , DECODE(l_valid_flag,'G',l_global_rate,DECODE(l_rate,-1,NULL,l_rate))
        , DECODE(l_valid_flag,'G',l_global_rate_date
                ,DECODE(l_rate,-1,NULL,l_date))
		 /*  Bug fix 5373370 - new column addded to po_dist_interface  - Start*/
		, TO_CHAR(l_dist_interface_header_id)
		 /*  Bug fix 5373370 - End */
        FROM DUAL;


		/* Bug 5373370 - Start */
		/* The distribution_interface_ref that is inserted into
		PO_DISTRIBUTIONS_INTERFACE is inserted into MCT. This column
		will later be joined to PO_DISTRIBUTIONS_ALL to fetch the
		PO_DISTRIBUTION_ID */

		/* MMT no longer used in this query */

		UPDATE mtl_consumption_transactions
		SET interface_distribution_ref = TO_CHAR(l_dist_interface_header_id)
	    WHERE transaction_id IN
		  ( SELECT mct.transaction_id
		    FROM MTL_CONSUMPTION_TRANSACTIONS mct
			WHERE mct.consumption_processed_flag IN ('N','E')
			AND mct.inventory_item_id = l_item_id
			AND mct.transaction_source_id = l_blanket_id
		    AND mct.blanket_price = l_blanket_price
		    AND NVL(mct.recoverable_tax,0) = l_recoverable_tax
		    AND NVL(mct.non_recoverable_tax,0) = l_nonrecoverable_tax
			AND mct.charge_account_id = l_charge_account_id
			AND mct.variance_account_id = l_variance_account_id
			AND mct.ACCRUAL_ACCOUNT_ID = l_accrual_account_id
			AND NVL(mct.tax_recovery_rate,0) = l_recovery_rate
			AND NVL(mct.tax_code_id,-1) = l_tax_code_id
		    AND mct.batch_id = p_batch_id
	 	  );

		/* Bug 5373370 - End */


        IF (l_debug = 1)
        THEN
          INV_LOG_UTIL.trace
          ( 'Populated Distributions Interface','INV_CONSUMPTION_ADVICE_PROC'
           , 9
           );
        END IF;
      END LOOP; -- line

      CLOSE line_csr_type;

      -- Call the document sourcing to create a release or a std PO

      IF l_error_msg IS NULL
      THEN

        IF (l_debug = 1)
        THEN
        INV_LOG_UTIL.trace
        ( '>> Create Documents ','INV_CONSUMPTION_ADVICE_PROC'
        , 9
        );
        END IF;

        IF (l_debug = 1)
        THEN
        INV_LOG_UTIL.trace
        ( 'Batch Id : '||p_batch_id,'INV_CONSUMPTION_ADVICE_PROC'
        , 9
        );
        END IF;

        IF (l_debug = 1)
        THEN
        INV_LOG_UTIL.trace
        ( 'Document Id : '||l_document_id,'INV_CONSUMPTION_ADVICE_PROC'
        , 9
        );
        END IF;

        IF (l_debug = 1)
        THEN
        INV_LOG_UTIL.trace
        ( 'Document Number : '||l_document_number,'INV_CONSUMPTION_ADVICE_PROC'
        , 9
        );
        END IF;

        IF (l_debug = 1)
        THEN
        INV_LOG_UTIL.trace
        ( 'Line : '||l_lines,'INV_CONSUMPTION_ADVICE_PROC'
        , 9
        );
        END IF;

        INV_PO_THIRD_PARTY_STOCK_MDTR.create_documents
         ( p_batch_id                   => p_batch_id
         , p_document_id                => l_document_id
         , p_document_number            => l_document_number
         , p_line                       => l_lines
         , x_error_code                 => l_error_code
         );

        IF (l_debug = 1)
        THEN
        INV_LOG_UTIL.trace
        ( 'Error Code : '||l_error_code,'INV_CONSUMPTION_ADVICE_PROC'
        , 9
        );
        END IF;

        IF (l_debug = 1)
        THEN
        INV_LOG_UTIL.trace
        ( '<< Create Documents ','INV_CONSUMPTION_ADVICE_PROC'
        , 9
        );
        END IF;


        IF l_error_code = 1
        THEN


          -- Update the ASL entry with the last billing date

          FOR v_counter IN l_asl_cons_tab.FIRST .. l_asl_cons_tab.LAST
          LOOP
            l_asl_id := l_asl_cons_tab(v_counter);

          IF (l_debug = 1)
          THEN
          INV_LOG_UTIL.trace
          ( '>> Update ASL ' ,'INV_CONSUMPTION_ADVICE_PROC'
          , 9
          );
          END IF;

          IF (l_debug = 1)
          THEN
          INV_LOG_UTIL.trace
          ( ' ASL_ID : '||l_asl_id,'INV_CONSUMPTION_ADVICE_PROC'
          , 9
          );
          END IF;

          INV_PO_THIRD_PARTY_STOCK_MDTR.update_asl
           (p_asl_id               => l_asl_id);

         END LOOP;

          IF (l_debug = 1)
          THEN
          INV_LOG_UTIL.trace
          ( '<< Update ASL ','INV_CONSUMPTION_ADVICE_PROC'
          , 9
          );
          END IF;

          -- If a Release was created, populate release id

          IF l_valid_flag = 'Y' THEN

            l_consumption_release_id := l_document_id;
            l_consumption_po_header_id := NULL;
            l_error_msg := NULL;
            l_consumption_processed_flag := 'Y';
          ELSE -- GA, Standard PO was created

            l_consumption_release_id := NULL;
            l_consumption_po_header_id := l_document_id;
            l_error_msg :=NULL;
            l_consumption_processed_flag := 'Y';
          END IF;

          IF NVL(l_valid_flag,'N') = 'Y'
          THEN
            l_archive_subtype := 'BLANKET';
            l_archive_type    := 'RELEASE';
          ELSIF NVL(l_valid_flag,'N') = 'G'
          THEN
            l_archive_subtype := 'STANDARD';
            l_archive_type    := 'PO';
          END IF;

          l_api_version := 1.0;

          IF (l_debug = 1)
          THEN
          INV_LOG_UTIL.trace
          ( '>> Archive PO ','INV_CONSUMPTION_ADVICE_PROC'
          , 9
          );
          END IF;

          IF (l_debug = 1)
          THEN
          INV_LOG_UTIL.trace
          ( ' api version : '||l_api_version,'INV_CONSUMPTION_ADVICE_PROC'
          , 9
          );
          END IF;

          IF (l_debug = 1)
          THEN
          INV_LOG_UTIL.trace
          ( ' document id : '||l_document_id,'INV_CONSUMPTION_ADVICE_PROC'
          , 9
          );
          END IF;

          IF (l_debug = 1)
          THEN
          INV_LOG_UTIL.trace
          ( ' document_type : '||l_archive_type,'INV_CONSUMPTION_ADVICE_PROC'
          , 9
          );
          END IF;

          IF (l_debug = 1)
          THEN
          INV_LOG_UTIL.trace
          ( ' document subtype : '||l_archive_subtype,'INV_CONSUMPTION_ADVICE_PROC'
          , 9
          );
          END IF;

          INV_PO_THIRD_PARTY_STOCK_MDTR.archive_po
           ( p_api_version       => l_api_version
           , p_document_id       => l_document_id
           , p_document_type     => l_archive_type
           , p_document_subtype  => l_archive_subtype
           , x_return_status     => l_archive_status
           , x_msg_data          => l_msg_data
           );

          IF (l_debug = 1)
          THEN
          INV_LOG_UTIL.trace
          ( ' return status : '||l_archive_status,'INV_CONSUMPTION_ADVICE_PROC'
          , 9
          );
          END IF;

          IF (l_debug = 1)
          THEN
          INV_LOG_UTIL.trace
          ( ' msg data : '||l_msg_data,'INV_CONSUMPTION_ADVICE_PROC'
          , 9
          );
          END IF;

          IF (l_debug = 1)
          THEN
          INV_LOG_UTIL.trace
          ( '<<  Archive PO : ','INV_CONSUMPTION_ADVICE_PROC'
          , 9
          );
          END IF;


           IF l_archive_status <> FND_API.G_RET_STS_SUCCESS
           THEN
             l_error_msg := 'INV_SUP_CONS_ARCHIVING_FAIL';
           END IF;

        ELSE

          -- autocreate returned error
          l_consumption_release_id := NULL;
          l_consumption_po_header_id :=NULL;
          l_error_msg := 'INV_SUP_CONS_AUTO_CREATE_FAIL';
          l_consumption_processed_flag := 'E';
        END IF;
      END IF;

      INV_CONSUMPTION_ADVICE_PROC.Update_Consumption
       (p_consumption_po_header_id   => l_consumption_po_header_id
       ,p_consumption_release_id     => l_consumption_release_id
       ,p_error_code                 => l_error_msg
       ,p_batch_id                   => p_batch_id
       ,p_transaction_source_id      => l_blanket_id
       ,p_consumption_processed_flag => l_consumption_processed_flag
       ,p_accrual_account_id         => l_accrual_account_id
       ,p_charge_account_id          => l_charge_account_id
       ,p_variance_account_id        => l_variance_account_id
       ,p_transaction_date           => l_transaction_date
       ,p_global_rate_type           => l_global_rate_type
       ,p_global_rate                => l_global_rate
       ,p_vendor_site_id             => l_vendor_site_id);

        IF (l_debug = 1)
        THEN
          INV_LOG_UTIL.trace
          ('Release created :'||l_consumption_release_id,'INV_CONSUMPTION_ADVICE_PROC',9);
          INV_LOG_UTIL.trace
          ('PO created :'||l_consumption_po_header_id,'INV_CONSUMPTION_ADVICE_PROC',9);
          INV_LOG_UTIL.trace
          ('Batch :'||p_batch_id,'INV_CONSUMPTION_ADVICE_PROC',9);
          INV_LOG_UTIL.trace
          ('Blanket is :'||l_blanket_id,'INV_CONSUMPTION_ADVICE_PROC',9);
          INV_LOG_UTIL.trace
          ('Site is :'||l_vendor_site_id,'INV_CONSUMPTION_ADVICE_PROC',9);
          INV_LOG_UTIL.trace
          ('Txn Date is :'||l_transaction_date,'INV_CONSUMPTION_ADVICE_PROC',9);
        END IF;

      l_error_msg                  := NULL;
      l_consumption_processed_flag := NULL;

    END IF;

  END LOOP; -- header

  CLOSE header_csr_type;

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '<< Load Interface Tables','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

EXCEPTION

  WHEN OTHERS THEN

    IF header_csr_type% ISOPEN
    THEN
      CLOSE header_csr_type;
    END IF;

    IF line_csr_type% ISOPEN
    THEN
      CLOSE line_csr_type;
    END IF;

    IF (l_debug = 1) THEN
     INV_LOG_UTIL.trace
     ( SQLCODE  || ' : ' || SQLERRM ,'INV_CONSUMPTION_ADVICE_PROC'
      , 9
     );
    END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END load_interface_tables;


--========================================================================
-- PROCEDURE : Load_Summarized_Quantity      PRIVATE
-- COMMENT   : This procedure summarizes records in
--             MTL_CONSUMPTION_TRANSACTIONS for a unique combination of
--             transaction_source_id, inventory_item_id, organization_id
--             transaction cost, tax code id, accrual account, variance
--             account, charge account
--             present in MTL_CONSUMPTION_TXN_TEMP. The result updates the
--             net quantity column in MTL_CONSUMPTION_TXN_TEMP
-- CHANGE    : INVCONV Added secondary_net_quantity to support process attributes
--             for inventory convergence project.
--=========================================================================
PROCEDURE  load_summarized_quantity
( p_txn_source_tab            IN  g_cons_tbl_type
, p_inventory_item_tab        IN  g_cons_tbl_type
, p_organization_tab          IN  g_cons_tbl_type
, p_own_org_tab               IN  g_cons_tbl_type
, p_transaction_cost_tab      IN  g_cons_tbl_type
, p_tax_code_tab              IN  g_cons_tbl_type
, p_rec_tax_tab               IN  g_cons_tbl_type
, p_non_rec_tax_tab           IN  g_cons_tbl_type
, p_accrual_account_tab       IN  g_cons_tbl_type
, p_charge_account_tab        IN  g_cons_tbl_type
, p_variance_account_tab      IN  g_cons_tbl_type
, p_date_tab                  IN  g_cons_date_tbl_type
, p_rate_tab                  IN  g_cons_tbl_type
, p_rate_type_tab             IN  g_cons_varchar_tbl_type
, p_batch_id                  IN  NUMBER
, p_tax_rec_rate_tab		  IN  g_cons_tbl_type  -- Bug 4969421
)
IS
l_debug   NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
-- Bug 5092489, commenting as not used
--l_txn_count   NUMBER;
--l_txn_first   NUMBER;
--l_txn_last    NUMBER;
--l_txn_ct      NUMBER;

BEGIN

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> Load Summarized Quantity','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

   -- Bug 5092489, commenting as not used
   /*l_txn_first := p_txn_source_tab.FIRST;
   l_txn_last  := p_txn_source_tab.LAST;
   l_txn_ct    := p_txn_source_tab.COUNT;

   IF l_txn_first IS NULL
   THEN
     l_txn_first :=0;
   END IF;

   IF l_txn_last IS NULL
   THEN
     l_txn_last :=0;
   END IF;

   IF (l_debug = 1)
   THEN
     INV_LOG_UTIL.trace
     ( 'First is :'||l_txn_first,'INV_CONSUMPTION_ADVICE_PROC'
      , 9
      );
     INV_LOG_UTIL.trace
     ( 'Last is :'||l_txn_ct,'INV_CONSUMPTION_ADVICE_PROC'
      , 9
      );
   END IF;
   */

   IF (l_debug = 1)
   THEN
     INV_LOG_UTIL.trace
     ( 'Last is :'||p_txn_source_tab.COUNT,'INV_CONSUMPTION_ADVICE_PROC'
      , 9
      );
   END IF;

  -- Use the bulk update to summarize the net quantity for
  -- the current batch. The net quantity takes into account
  -- any corrections that were made to the transaction quantity
  -- by the user.

  IF p_txn_source_tab.COUNT > 0
  THEN

  FORALL i IN p_txn_source_tab.FIRST..p_txn_source_tab.LAST
    UPDATE/*+ leading(mctt) */  MTL_CONSUMPTION_TXN_TEMP mctt
    SET (mctt.net_qty,mctt.secondary_net_qty) =
     (SELECT SUM(mct.net_qty),SUM(mct.secondary_net_qty)

      FROM MTL_CONSUMPTION_TRANSACTIONS mct
         --, MTL_MATERIAL_TRANSACTIONS mmt
      WHERE --mmt.transaction_id = mct.transaction_id AND
      mct.transaction_source_id = p_txn_source_tab(i)
      AND mct.inventory_item_id = p_inventory_item_tab(i)
      AND mct.organization_id = p_organization_tab(i)
      AND mct.owning_organization_id = p_own_org_tab(i)
	  /* Bug 4969420  Starts here*/
  	  /* We use the blanket_price (from MCT) instead of the transaction_cost from MMT */
      --AND mmt.transaction_cost = p_transaction_cost_tab(i)
	  AND mct.blanket_price  = p_transaction_cost_tab(i)
      /* Bug 4969421  Ends here*/
      /* Bug 11900144. Addition of po_line_id */
      AND mct.po_line_id=mctt.po_line_id
      AND NVL(mct.tax_code_id,-1) = p_tax_code_tab(i)
      AND NVL(mct.recoverable_tax,0) = p_rec_tax_tab(i)
      AND NVL(mct.non_recoverable_tax,0) = p_non_rec_tax_tab(i)
      AND mct.accrual_account_id = p_accrual_account_tab(i)
      AND mct.charge_account_id = p_charge_account_tab(i)
      AND mct.variance_account_id = p_variance_account_tab(i)
      AND TRUNC(mct.transaction_date) = TRUNC(p_date_tab(i))
      AND NVL(mct.rate,-1) = p_rate_tab(i)
      AND NVL(mct.rate_type,'##') = p_rate_type_tab(i)
	  /* Bug 4969421 - Starts here  - new check included for tax recovery rate */
	  AND NVL(mct.tax_recovery_rate,0) =NVL(p_tax_rec_rate_tab(i),0)
	  /*Bug 4969421 - Ends here  */
      AND mct.batch_id = p_batch_id
      AND mct.consumption_processed_flag IN ('N', 'E'))
    WHERE mctt.transaction_source_id = p_txn_source_tab(i)
    AND mctt.inventory_item_id = p_inventory_item_tab(i)
    AND mctt.organization_id = p_organization_tab(i)
    AND mctt.owning_organization_id = p_own_org_tab(i)
    AND mctt.transaction_cost = p_transaction_cost_tab(i)
    AND mctt.tax_code_id = p_tax_code_tab(i)
    AND mctt.recoverable_tax = p_rec_tax_tab(i)
    AND mctt.non_recoverable_tax = p_non_rec_tax_tab(i)
    AND mctt.accrual_account_id = p_accrual_account_tab(i)
    AND mctt.charge_account_id = p_charge_account_tab(i)
    AND mctt.variance_account_id = p_variance_account_tab(i)
    AND mctt.transaction_date = TRUNC(p_date_tab(i))
    AND mctt.rate = p_rate_tab(i)
	/* Bug 4969421 - Starts here  - new check included for tax recovery rate */
	AND NVL(mctt.tax_recovery_rate,0) =NVL(p_tax_rec_rate_tab(i),0)
	/*Bug 4969421 - Ends here  */
    AND mctt.rate_type = p_rate_type_tab(i);


  ELSE
  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '<< Load Summarized Quantity null index','INV_CONSUMPTION_ADVICE_PROC'     , 9
     );
  END IF;
  END IF;

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '<< Load Summarized Quantity','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
     INV_LOG_UTIL.trace
     ( SQLCODE  || ' : ' || SQLERRM ,'INV_CONSUMPTION_ADVICE_PROC'
      , 9
     );
    END IF;

    FND_MESSAGE.set_name('INV', 'INV_CONS_SUP_LD_SUM');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END load_summarized_quantity;

--========================================================================
-- PROCEDURE : Load_Summarized_Quantity_prf      PRIVATE
-- COMMENT   : This procedure summarizes records in
--             MTL_CONSUMPTION_TRANSACTIONS for a unique combination of
--             transaction_source_id, inventory_item_id, organization_id
--             transaction cost, tax code id, accrual account, variance
--             account, charge account
--             present in MTL_CONSUMPTION_TXN_TEMP. The result updates the
--             net quantity column in MTL_CONSUMPTION_TXN_TEMP
-- CHANGE    : INVCONV Added secondary_net_quantity to support process attributes
--             for inventory convergence project.
--=========================================================================
PROCEDURE  load_summarized_quantity_prf
( p_txn_source_tab            IN  g_cons_tbl_type
, p_inventory_item_tab        IN  g_cons_tbl_type
, p_organization_tab          IN  g_cons_tbl_type
, p_own_org_tab               IN  g_cons_tbl_type
, p_transaction_cost_tab      IN  g_cons_tbl_type
, p_tax_code_tab              IN  g_cons_tbl_type
, p_rec_tax_tab               IN  g_cons_tbl_type
, p_non_rec_tax_tab           IN  g_cons_tbl_type
, p_accrual_account_tab       IN  g_cons_tbl_type
, p_charge_account_tab        IN  g_cons_tbl_type
, p_variance_account_tab      IN  g_cons_tbl_type
, p_date_tab                  IN  g_cons_date_tbl_type
, p_rate_tab                  IN  g_cons_tbl_type
, p_rate_type_tab             IN  g_cons_varchar_tbl_type
, p_batch_id                  IN  NUMBER
, p_tax_rec_rate_tab		  IN  g_cons_tbl_type  -- Bug 4969421
)
IS
l_debug   NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
-- Bug 5092489, commenting as not used
--l_txn_count   NUMBER;
--l_txn_first   NUMBER;
--l_txn_last    NUMBER;
--l_txn_ct      NUMBER;
BEGIN

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> Load Summarized Quantity Prf','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

   -- Bug 5092489, commenting as not used
   /*l_txn_first := p_txn_source_tab.FIRST;
   l_txn_last  := p_txn_source_tab.LAST;
   l_txn_ct    := p_txn_source_tab.COUNT;

   IF l_txn_first IS NULL
   THEN
     l_txn_first :=0;
   END IF;

   IF l_txn_last IS NULL
   THEN
     l_txn_last :=0;
   END IF;

   IF (l_debug = 1)
   THEN
     INV_LOG_UTIL.trace
     ( 'First is :'||l_txn_first,'INV_CONSUMPTION_ADVICE_PROC'
      , 9
      );
     INV_LOG_UTIL.trace
     ( 'Last is :'||l_txn_last||' '||l_txn_ct,'INV_CONSUMPTION_ADVICE_PROC'
      , 9
      );
   END IF;
   */

   IF (l_debug = 1)
   THEN
     INV_LOG_UTIL.trace
     ( 'Last is :'||p_txn_source_tab.COUNT,'INV_CONSUMPTION_ADVICE_PROC'
      , 9
      );
   END IF;

  -- Use the bulk update to summarize the net quantity for
  -- the current batch. The net quantity takes into account
  -- any corrections that were made to the transaction quantity
  -- by the user.

  IF p_txn_source_tab.COUNT > 0
  THEN

  FORALL i IN p_txn_source_tab.FIRST..p_txn_source_tab.LAST
    UPDATE/*+ leading(mctt) */  MTL_CONSUMPTION_TXN_TEMP mctt
    SET (mctt.net_qty,mctt.secondary_net_qty) =
     (SELECT SUM(mct.net_qty),SUM(mct.secondary_net_qty)

      FROM MTL_CONSUMPTION_TRANSACTIONS mct
         --, MTL_MATERIAL_TRANSACTIONS mmt
      WHERE --mmt.transaction_id = mct.transaction_id AND
      mct.transaction_source_id = p_txn_source_tab(i)
      AND mct.inventory_item_id = p_inventory_item_tab(i)
      AND mct.organization_id = p_organization_tab(i)
      AND mct.owning_organization_id = p_own_org_tab(i)
	  /* Bug 4969420  Starts here*/
  	  /* We use the blanket_price (from MCT) instead of the transaction_cost from MMT */
      --AND mmt.transaction_cost = p_transaction_cost_tab(i)
	  AND mct.blanket_price  = p_transaction_cost_tab(i)
      /* Bug 4969421  Ends here*/
      /* Bug 11900144. Addition of po_line_id */
      AND mct.po_line_id=mctt.po_line_id
      AND NVL(mct.tax_code_id,-1) = p_tax_code_tab(i)
      AND NVL(mct.recoverable_tax,0) = p_rec_tax_tab(i)
      AND NVL(mct.non_recoverable_tax,0) = p_non_rec_tax_tab(i)
      AND mct.accrual_account_id = p_accrual_account_tab(i)
      AND mct.charge_account_id = p_charge_account_tab(i)
      AND mct.variance_account_id = p_variance_account_tab(i)
      AND TRUNC(mct.transaction_date) = TRUNC(p_date_tab(i))
      AND NVL(mct.rate,-1) = p_rate_tab(i)
      AND NVL(mct.rate_type,'##') = p_rate_type_tab(i)
	  /* Bug 4969421 - Starts here  - new check included for tax recovery rate */
	  AND NVL(mct.tax_recovery_rate,0) =NVL(p_tax_rec_rate_tab(i),0)
	  /*Bug 4969421 - Ends here  */
      AND mct.batch_id = p_batch_id
      AND mct.consumption_processed_flag IN ('N', 'E'))
    WHERE mctt.transaction_source_id = p_txn_source_tab(i)
    AND mctt.inventory_item_id = p_inventory_item_tab(i)
    AND mctt.organization_id = p_organization_tab(i)
    AND mctt.owning_organization_id = p_own_org_tab(i)
    AND mctt.transaction_cost = p_transaction_cost_tab(i)
    AND mctt.tax_code_id = p_tax_code_tab(i)
    AND mctt.recoverable_tax = p_rec_tax_tab(i)
    AND mctt.non_recoverable_tax = p_non_rec_tax_tab(i)
    AND mctt.accrual_account_id = p_accrual_account_tab(i)
    AND mctt.charge_account_id = p_charge_account_tab(i)
    AND mctt.variance_account_id = p_variance_account_tab(i)
    AND mctt.transaction_date = TRUNC(p_date_tab(i))
    AND mctt.rate = p_rate_tab(i)
    AND mctt.rate_type = p_rate_type_tab(i)
	/* Bug 4969421 - Starts here  - new check included for tax recovery rate */
	AND NVL(mctt.tax_recovery_rate,0) =NVL(p_tax_rec_rate_tab(i),0)
	/*Bug 4969421 - Ends here  */
    AND mctt.global_agreement_flag = 'Y';

  FORALL i IN p_txn_source_tab.FIRST..p_txn_source_tab.LAST
    UPDATE/*+ leading(mctt) */  MTL_CONSUMPTION_TXN_TEMP mctt
    SET mctt.net_qty =
     (SELECT SUM(mct.net_qty)
      FROM MTL_CONSUMPTION_TRANSACTIONS mct
         --, MTL_MATERIAL_TRANSACTIONS mmt
      WHERE --mmt.transaction_id = mct.transaction_id AND
      mct.transaction_source_id = p_txn_source_tab(i)
      AND mct.inventory_item_id = p_inventory_item_tab(i)
      AND mct.organization_id = p_organization_tab(i)
      AND mct.owning_organization_id = p_own_org_tab(i)
  	  /* Bug 4969420  Starts here*/
  	  /* We use the blanket_price (from MCT) instead of the transaction_cost from MMT */
      --AND mmt.transaction_cost = p_transaction_cost_tab(i)
	  AND mct.blanket_price = p_transaction_cost_tab(i)
  	  /* Bug 4969421  Ends here*/
      /* Bug 11900144. Addition of po_line_id */
      AND mct.po_line_id=mctt.po_line_id
      AND NVL(mct.tax_code_id,-1) = p_tax_code_tab(i)
      AND NVL(mct.recoverable_tax,0) = p_rec_tax_tab(i)
      AND NVL(mct.non_recoverable_tax,0) = p_non_rec_tax_tab(i)
      AND mct.accrual_account_id = p_accrual_account_tab(i)
      AND mct.charge_account_id = p_charge_account_tab(i)
      AND mct.variance_account_id = p_variance_account_tab(i)
	  /* Bug 4969421 - Starts here  - new check included for tax recovery rate */
	  AND NVL(mct.tax_recovery_rate,0) =NVL(p_tax_rec_rate_tab(i),0)
	  /*Bug 4969421 - Ends here  */
      AND mct.batch_id = p_batch_id
      AND mct.consumption_processed_flag IN ('N', 'E'))
    WHERE mctt.transaction_source_id = p_txn_source_tab(i)
    AND mctt.inventory_item_id = p_inventory_item_tab(i)
    AND mctt.organization_id = p_organization_tab(i)
    AND mctt.owning_organization_id = p_own_org_tab(i)
    AND mctt.transaction_cost = p_transaction_cost_tab(i)-- mctt.transaction_cost is the blanket_price from MCT
    AND mctt.tax_code_id = p_tax_code_tab(i)
    AND mctt.recoverable_tax = p_rec_tax_tab(i)
    AND mctt.non_recoverable_tax = p_non_rec_tax_tab(i)
	/* Bug 4969421 - Starts here  - new check included for tax recovery rate */
	AND NVL(mctt.tax_recovery_rate,0) =NVL(p_tax_rec_rate_tab(i),0)
	/*Bug 4969421 - Ends here  */
    AND mctt.accrual_account_id = p_accrual_account_tab(i)
    AND mctt.charge_account_id = p_charge_account_tab(i)
    AND mctt.variance_account_id = p_variance_account_tab(i)
    AND mctt.global_agreement_flag = 'N';
  ELSE
    IF (l_debug = 1)
    THEN
      INV_LOG_UTIL.trace
      ( '<< Load Summarized Quantity null index','INV_CONSUMPTION_ADVICE_PROC'     , 9
     );
    END IF;
  END IF;

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '<< Load Summarized Quantity_prf','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
     INV_LOG_UTIL.trace
     ( SQLCODE  || ' : ' || SQLERRM ,'INV_CONSUMPTION_ADVICE_PROC'
      , 9
     );
    END IF;

    FND_MESSAGE.set_name('INV', 'INV_CONS_SUP_LD_SUM');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END load_summarized_quantity_prf;

--========================================================================
-- PROCEDURE : Delete Record      PRIVATE
-- COMMENT   : If the billing date for the current asl entry
--           : has not elapsed yet then the associated
--           : change of ownership transactions held in
--           : MTL_CONSUMPTION_TRANSACTIONS should not be
--           : processed yet. The current record slipped
--           : into this loop for that reason and should
--           : therefore be deleted from the current batch

--=========================================================================
PROCEDURE  delete_record
( p_txn_source_id          IN  NUMBER
, p_inventory_item_id      IN  NUMBER
, p_organization_id        IN  NUMBER
, p_own_org_id             IN  NUMBER
, p_price                  IN  NUMBER
, p_tax_code_id            IN  NUMBER
, p_rec_tax_id             IN  NUMBER
, p_non_rec_tax_id         IN  NUMBER
, p_accrual_account_id     IN  NUMBER
, p_charge_account_id      IN  NUMBER
, p_variance_account_id    IN  NUMBER
, p_date                   IN  DATE
, p_rate                   IN  NUMBER
, p_rate_type              IN  VARCHAR
)
IS
l_debug   NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> Delete Record','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

  DELETE FROM mtl_consumption_txn_temp mctt
  WHERE mctt.transaction_source_id = p_txn_source_id
  AND mctt.inventory_item_id = p_inventory_item_id
  AND mctt.organization_id = p_organization_id
  AND mctt.owning_organization_id = p_own_org_id
  AND mctt.transaction_cost = p_price
  AND mctt.tax_code_id = p_tax_code_id
  AND mctt.recoverable_tax = p_rec_tax_id
  AND mctt.non_recoverable_tax = p_non_rec_tax_id
  AND mctt.accrual_account_id = p_accrual_account_id
  AND mctt.charge_account_id = p_charge_account_id
  AND mctt.variance_account_id = p_variance_account_id
  AND mctt.transaction_date = TRUNC(p_date)
  AND mctt.rate = p_rate
  AND mctt.rate_type = p_rate_type;

  -- Bug 5092489. Query modified for better performance
  UPDATE MTL_CONSUMPTION_TRANSACTIONS mct
  SET mct.batch_id = NULL
  WHERE mct.transaction_source_id = p_txn_source_id
       AND mct.inventory_item_id = p_inventory_item_id
       AND mct.organization_id = p_organization_id
       AND mct.owning_organization_id = p_own_org_id
       AND mct.accrual_account_id = p_accrual_account_id
  	  /* Bug 4969420  Starts here*/
  	  /* We use the blanket_price (from MCT) instead of the transaction_cost from MMT */
       --AND mmt.transaction_cost = p_price
--	   AND mct.blanket_price = p_price
  	  /* Bug 4969420  Ends here*/
       AND TRUNC(mct.transaction_date) = TRUNC(p_date)
  AND NVL(mct.tax_code_id,-1) = p_tax_code_id
  AND NVL(mct.recoverable_tax,0) = p_rec_tax_id
  AND NVL(mct.non_recoverable_tax,0) = p_non_rec_tax_id
  AND mct.charge_account_id = p_charge_account_id
  AND mct.variance_account_id = p_variance_account_id
  AND NVL(mct.rate,-1) = p_rate
       AND NVL(mct.rate_type,'##') = p_rate_type
       AND mct.consumption_processed_flag IN ('N', 'E');

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '<< Delete Record','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
     INV_LOG_UTIL.trace
     ( SQLCODE  || ' : ' || SQLERRM ,'INV_CONSUMPTION_ADVICE_PROC'
      , 9
     );
    END IF;

    FND_MESSAGE.set_name('INV', 'INV_CONS_SUP_DEL_REC');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END delete_record;

--========================================================================
-- PROCEDURE : Log_Initialize             PRIVATE
-- COMMENT   : Initializes the log facility. It should be called from
--             the top level procedure of each concurrent program
--========================================================================
PROCEDURE Log_Initialize
IS
l_debug   NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> Log Initialize','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

  g_log_level  := TO_NUMBER(FND_PROFILE.Value('AFLOG_LEVEL'));
  IF g_log_level IS NULL THEN
    g_log_mode := 'OFF';
  ELSE
    IF (TO_NUMBER(FND_PROFILE.Value('CONC_REQUEST_ID')) <> 0) THEN
      g_log_mode := 'SRS';
    ELSE
      g_log_mode := 'SQL';
    END IF;
  END IF;

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '<< Log Initialize','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

END Log_Initialize;

--========================================================================
-- PROCEDURE : Log                        PRIVATE
-- PARAMETERS: p_level                IN    2
--                                          -- G_LOG_PROCEDURE
--             p_msg                  IN  message to be print on the log
--                                        file
-- COMMENT   : Add an entry to the log
--=======================================================================--
PROCEDURE LOG
( p_priority                    IN  NUMBER
, p_msg                         IN  VARCHAR2
)
IS
l_debug   NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> Log','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

  IF ((g_log_mode <> 'OFF') AND (p_priority >= g_log_level))
  THEN
    IF g_log_mode = 'SQL'
    THEN
      -- SQL*Plus session: uncomment the next line during unit test
      -- DBMS_OUTPUT.put_line(p_msg);
      NULL;
    ELSE
      -- Concurrent request
      FND_FILE.put_line
      ( FND_FILE.LOG
      , p_msg
      );
    END IF;
  END IF;

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '<< Log','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END LOG;

--========================================================================
-- FUNCTION  : Generate_Log         PRIVATE
-- PARAMETERS: None
-- RETURNS   : NUMBER
-- COMMENT   : This procedure is called when there are errors
--           : in creating the consumption advice.
--           : It populates a log file with the triansaction ids
--           : of records that have failed. The user can view
--           : this information through the log of an application request
--=========================================================================
PROCEDURE generate_log
( p_batch_id           IN    NUMBER
)
IS

--=================
-- CURSORS
--=================

CURSOR con_ad_err_cur IS
SELECT mct.transaction_id
     , mct.error_code
FROM MTL_CONSUMPTION_TRANSACTIONS mct
WHERE mct.consumption_processed_flag = 'E'
AND mct.batch_id = p_batch_id;

--=================
-- VARIABLES
--=================

l_error_code  VARCHAR2(10);
l_txn_id      NUMBER;
l_debug       NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);


BEGIN

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> Generate Log','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

  INV_CONSUMPTION_ADVICE_PROC.LOG
  ( INV_CONSUMPTION_ADVICE_PROC.G_LOG_PROCEDURE
  , '< Consumption Advice Error'
  );

  OPEN con_ad_err_cur;
  LOOP
    FETCH con_ad_err_cur
    INTO
      l_txn_id
     ,l_error_code;

    IF con_ad_err_cur%NOTFOUND THEN
      EXIT;
    END IF;

  END LOOP;

  CLOSE con_ad_err_cur;

  INV_CONSUMPTION_ADVICE_PROC.LOG
  ( INV_CONSUMPTION_ADVICE_PROC.G_LOG_PROCEDURE
  , '> Consumption Advice Error'
  );

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '<< Generate Log','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;


END generate_log;


--Added procedure populate_po_line_id as part of bug 11900144
PROCEDURE populate_po_line_id
IS

--declare the variable types for bulk collect
type t_transaction_id          IS TABLE OF mTL_material_TRANSACTIONS.transaction_id%type;
type t_transaction_source_id   IS TABLE OF mTL_material_TRANSACTIONS.transaction_source_id%type;
type t_inventory_item_id       IS TABLE OF mTL_material_TRANSACTIONS.inventory_item_id%type;
type t_item_revision           IS TABLE OF mTL_material_TRANSACTIONS.revision%type;
type t_OWNING_ORGANIZATION_ID  IS TABLE OF mTL_material_TRANSACTIONS.OWNING_ORGANIZATION_ID%type;
type t_organization_id         IS TABLE OF mTL_material_TRANSACTIONS.organization_id%type;
type t_transaction_date        IS TABLE OF mTL_material_TRANSACTIONS.transaction_date%type;

--declare the local variables
l_transaction_id        t_transaction_id;
l_transaction_source_id t_transaction_source_id;
l_inventory_item_id     t_inventory_item_id;
l_item_revision         t_item_revision;
l_vendor_site_id        t_OWNING_ORGANIZATION_ID;
l_organization_id       t_organization_id;
l_transaction_date      t_transaction_date;
l_header_id             po_lines_all.po_header_id%TYPE;
l_document_line_id      po_lines_all.po_line_id%TYPE;
l_global_flag           varchar(2);

CURSOR csr_null_po_line_id IS
   SELECT mmt.transaction_id                     ,
          mmt.TRANSACTION_SOURCE_ID              ,
          mmt.inventory_item_id                  ,
          mmt.REVISION                           ,
          mmt.OWNING_ORGANIZATION_ID             ,
          mmt.ORGANIZATION_ID                    ,
          mmt.TRANSACTION_DATE
    FROM  MTL_CONSUMPTION_TRANSACTIONS mct       ,
          MTL_MATERIAL_TRANSACTIONS mmt
   WHERE  mmt.transaction_id = mct.transaction_id
      AND consumption_processed_flag IN ( 'N',
                                          'E')
      AND PO_LINE_ID IS NULL ;

BEGIN
        INV_LOG_UTIL.trace('Starting datafix for missing po_line_id','INV_CONSUMPTION_ADVICE_PROC',9);
        OPEN csr_null_po_line_id ;
        LOOP -- loop through each bulk of 100 records
          FETCH csr_null_po_line_id
               BULK COLLECT
          INTO l_transaction_id,
               l_transaction_source_id,
               l_inventory_item_id,
               l_item_revision,
               l_vendor_site_id,
               l_organization_id,
               l_transaction_date
          LIMIT 100;
          EXIT WHEN l_transaction_id.Count = 0;

          INV_LOG_UTIL.trace('there are '||l_inventory_item_id.Count ||' more unprocessed record(s) with missing po_line_id','INV_CONSUMPTION_ADVICE_PROC',9);
          IF(l_inventory_item_id.Count >0) THEN

            FOR i IN l_inventory_item_id.first .. l_inventory_item_id.last
            LOOP    -- loop through each transaction in the bulk
                    INV_LOG_UTIL.trace(l_transaction_source_id(i)
                    || ' , '
                    || l_inventory_item_id(i)
                    || ' , '
                    || l_item_revision(i)
                    || ' , '
                    || l_vendor_site_id(i)
                    || ' , '
                    || l_organization_id(i)
                    || ' , '
                    || l_transaction_date(i),'INV_CONSUMPTION_ADVICE_PROC',9 );

                    INV_PO_THIRD_PARTY_STOCK_MDTR.Get_Blanket_Number
                    ( p_inventory_item_id => l_inventory_item_id(i)
                    , p_item_revision => l_item_revision(i)
                    , p_vendor_site_id => l_vendor_site_id(i)
                    , p_organization_id => l_organization_id(i)
                    , p_transaction_date =>trunc(l_transaction_date(i))
                    , x_document_header_id => l_header_id
                    , x_document_line_id => l_document_line_id
                    , x_global_flag => l_global_flag
                    );

                    INV_LOG_UTIL.trace( l_header_id
                    || ' , '
                    || l_document_line_id
                    || ' , '
                    || l_global_flag
                    || ' , '
                    || l_transaction_id(i),'INV_CONSUMPTION_ADVICE_PROC',9
                    );
                    -- start of bug 9539634
                    IF  l_transaction_source_id(i) <> l_header_id THEN
                        -- if the derived po_line_id does not belong to the blanket header of the transaction
                        l_document_line_id := null;
                        INV_LOG_UTIL.trace('fetched blanket header is not equal to that of the transaction','INV_CONSUMPTION_ADVICE_PROC',9);
                        BEGIN
                            -- Since now the current eligible blanket has changed to newer one
                            -- fetching the po_line of the blanket which was associated with the transaction.
                            -- If there was more than one line for the same item in the old blanket
                            -- we take the 1st one only.In case of exception we set it back to null.
                            -- If po_line_id remains null , it will not be processed at all and manual datafix
                            -- needs to be applied to resolve this extreemly corner case.
                            select po_line_id
                            into   l_document_line_id
                            from   po_lines_All
                            where  po_header_id  = l_transaction_source_id(i)
                            and    item_id       = l_inventory_item_id(i)
                            and rownum = 1 ;
                        INV_LOG_UTIL.trace('Derived po_line_id is '||l_document_line_id,'INV_CONSUMPTION_ADVICE_PROC',9);
                        EXCEPTION
                        WHEN OTHERS THEN
                        INV_LOG_UTIL.trace('Unable to derive po_line_id , setting back to null ','INV_CONSUMPTION_ADVICE_PROC',9);
                        END;
                    END IF;
                    -- End  of bug 9539634
                    /* update the po line id and make it ready to be processed */
                    UPDATE mtl_consumption_transactions mct
                    SET    batch_id   = NULL,
                          po_line_id =l_document_line_id
                    WHERE  consumption_processed_flag in ('N','E')
                      AND transaction_id = l_transaction_id(i)
                      AND po_line_id IS NULL;

                      IF(SQL%ROWCOUNT = 1) THEN
                        INV_LOG_UTIL.trace('Updated the Trx id '||l_transaction_id(i)||' with po_line_id '||l_document_line_id ,'INV_CONSUMPTION_ADVICE_PROC',9);
                      END IF;

            END LOOP; -- loop through each transaction in the bulk
          END IF;
        END LOOP;   -- loop through each bul of 100 records
EXCEPTION WHEN OTHERS    THEN
        INV_LOG_UTIL.trace('Something went wrong with populate_po_line_id still proceeding with consumption advice','INV_CONSUMPTION_ADVICE_PROC',9);
END populate_po_line_id;


--========================================================================
-- PROCEDURE : Consumption_Txn_Worker      PRIVATE
-- COMMENT   : This procedure will copy all the records of a context batch
--             from MTL_CONSUMPTION_TRANSACTIONS to
--             MTL_CONSUMPTION_TRANSACTIONS_TEMP
--             summarize the net quantity  and call the create consumption
--             advice procedure
--=========================================================================
PROCEDURE  consumption_txn_worker
( p_batch_id            IN NUMBER
)
IS

  --=================
  -- CURSORS
  --=================

  CURSOR cons_temp_csr_type IS
  SELECT mctt.transaction_source_id
       , mctt.inventory_item_id
       , mctt.organization_id
       , mctt.owning_organization_id
       , mctt.transaction_cost-- This is the blanket_price from MCT Bug 4969421
       , mctt.tax_code_id
       , mctt.recoverable_tax
       , mctt.non_recoverable_tax
       , mctt.accrual_account_id
       , mctt.charge_account_id
       , mctt.variance_account_id
       , mctt.rate
       , mctt.rate_type
       , mctt.transaction_date
       , mctt.tax_recovery_rate  -- Bug 4969420
  FROM MTL_CONSUMPTION_TXN_TEMP mctt
  /* bug 5113064 - Start */
  /* filter just for the given batch */
  WHERE batch_id =p_batch_id  ;
  /* bug 5113064 - End*/

  --=================
  -- LOCAL VARIABLES
  --=================

  l_current_cons_index          BINARY_INTEGER := 0;
  l_empty_cons_tab              g_cons_tbl_type;
  l_empty_date_cons_tab         g_cons_date_tbl_type;
  l_empty_varchar_cons_tab      g_cons_varchar_tbl_type;
  l_txn_source_tab              g_cons_tbl_type;
  l_item_tab                    g_cons_tbl_type;
  l_org_tab                     g_cons_tbl_type;
  l_owning_org_tab              g_cons_tbl_type;
  l_price_tab                   g_cons_tbl_type;
  l_tax_code_tab                g_cons_tbl_type;
  l_rec_tax_tab                 g_cons_tbl_type;
  l_non_rec_tax_tab             g_cons_tbl_type;
  l_accrual_account_tab         g_cons_tbl_type;
  l_charge_account_tab          g_cons_tbl_type;
  l_variance_account_tab        g_cons_tbl_type;
  l_rate_tab                    g_cons_tbl_type;
  l_rate_type_tab               g_cons_varchar_tbl_type;
  l_tax_rec_rate_tab			g_cons_tbl_type; -- Bug 4969421
  l_date_tab                    g_cons_date_tbl_type;
  -- Bug 5092489. commented becasue not used
  --l_last_billing_date           DATE;
  --l_next_billing_date           DATE;
  --l_con_bill_cycle              NUMBER;
  l_bulk_count                  NUMBER := 0;
  l_loop_count                  NUMBER := 0;
  l_vendor_id                   NUMBER;
  l_vendor_site_id              NUMBER;
  -- Bug 5092489. commented becasue not used
  --l_con_from_sup_flag           NUMBER;
  --l_enable_vmi_flag             NUMBER;
  l_document_header_id          NUMBER;
  l_document_line_id            NUMBER;
  l_bill_date_elapsed           NUMBER := 0;
  l_batch_id                    NUMBER;
  l_return_status               VARCHAR2(24);
  l_count                       NUMBER;
  l_asl_id                      NUMBER;
  l_vendor_product_num          VARCHAR2(25);
  l_purchasing_uom              VARCHAR2(25);
  l_organization_id             NUMBER := 0;
  l_current_txn_source_id       NUMBER := 0;
  l_inventory_item_id           NUMBER := 0;
  l_debug                       NUMBER :=
                                  NVL(FND_PROFILE.VALUE
                                  ('INV_DEBUG_TRACE'),0);


BEGIN

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> Consumption Txn Worker(p_batch_id)'||p_batch_id,'INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

  -- Call procedure to load MTL_CONSUMPTION_TXNS_TEMP
  -- from MTL_CONSUMPTION_TRANSACTIONS
  -- with records that belong to the specified batch

  IF NVL(FND_PROFILE.value('INV_SUPPLIER_CONSIGNED_GROUPING'),'N') = 'N'
  THEN
    INV_CONSUMPTION_ADVICE_PROC.load_combination_prf
   (p_batch_id          => p_batch_id
   ,p_vendor_id         => NULL
   ,p_vendor_site_id    => NULL
   ,p_inventory_item_id => NULL
   ,p_organization_id   => NULL);
  ELSE
  INV_CONSUMPTION_ADVICE_PROC.load_combination
   (p_batch_id          => p_batch_id
   ,p_vendor_id         => NULL
   ,p_vendor_site_id    => NULL
   ,p_inventory_item_id => NULL
   ,p_organization_id   => NULL);

  END IF;

  -- open cursor

  IF NOT cons_temp_csr_type%ISOPEN
  THEN
  OPEN cons_temp_csr_type;
  END IF;


  LOOP

    l_txn_source_tab         := l_empty_cons_tab;
    l_item_tab               := l_empty_cons_tab;
    l_org_tab                := l_empty_cons_tab;
    l_owning_org_tab         := l_empty_cons_tab;
    l_price_tab              := l_empty_cons_tab;
    l_tax_code_tab           := l_empty_cons_tab;
    l_rec_tax_tab            := l_empty_cons_tab;
    l_non_rec_tax_tab        := l_empty_cons_tab;
    l_accrual_account_tab    := l_empty_cons_tab;
    l_charge_account_tab     := l_empty_cons_tab;
    l_variance_account_tab   := l_empty_cons_tab;
    l_rate_tab               := l_empty_cons_tab;
    l_rate_type_tab          := l_empty_varchar_cons_tab;
    l_date_tab               := l_empty_date_cons_tab;
    l_batch_id               := p_batch_id;
	l_tax_rec_rate_tab		 := l_empty_cons_tab; -- Bug 4969421

    -- Bulk population of pl/sql table

    FETCH cons_temp_csr_type
    BULK COLLECT INTO l_txn_source_tab
                     ,l_item_tab
                     ,l_org_tab
                     ,l_owning_org_tab
                     ,l_price_tab
                     ,l_tax_code_tab
                     ,l_rec_tax_tab
                     ,l_non_rec_tax_tab
                     ,l_accrual_account_tab
                     ,l_charge_account_tab
                     ,l_variance_account_tab
                     ,l_rate_tab
                     ,l_rate_type_tab
                     ,l_date_tab
			   ,l_tax_rec_rate_tab  -- Bug 4969420
                      LIMIT 1000;

    /* But 5006151 - Start */
	/* When the number of records in the MTL_CONSUMPTION_TXN_TEMP table is a
	multiple of 1000, the worker does not exit correctly with the check
	'EXIT WHEN l_loop_count < 1000' as l_loop_count equals '1000'.
	The following check would ensure that the worker exits correctly */
	EXIT WHEN l_bulk_count = cons_temp_csr_type%ROWCOUNT;
	/* Bug 5006151 - End */

    -- Summarize the net quantity of all records in
    -- MTL_CONSUMPTION_TRANSACTIONS associated with
    -- records in MTL_CONSUMPTION_TXNS_TEMP.
    -- Record the result in MTL_CONSUMPTION_TXNS_TEMP.

  /*  BUg 5092489. Following IF block is commented becasue quantity is populated during insert
  IF NVL(FND_PROFILE.value('INV_SUPPLIER_CONSIGNED_GROUPING'),'N') = 'N'
  THEN
    INV_CONSUMPTION_ADVICE_PROC.load_summarized_quantity_prf
     (p_txn_source_tab        => l_txn_source_tab
     ,p_inventory_item_tab    => l_item_tab
     ,p_organization_tab      => l_org_tab
     ,p_own_org_tab           => l_owning_org_tab
     ,p_transaction_cost_tab  => l_price_tab -- blanket_price from MCT Bug 4969421
     ,p_tax_code_tab          => l_tax_code_tab
     ,p_rec_tax_tab           => l_rec_tax_tab
     ,p_non_rec_tax_tab       => l_non_rec_tax_tab
     ,p_accrual_account_tab   => l_accrual_account_tab
     ,p_charge_account_tab    => l_charge_account_tab
     ,p_variance_account_tab  => l_variance_account_tab
     ,p_rate_tab              => l_rate_tab
     ,p_rate_type_tab         => l_rate_type_tab
     ,p_date_tab              => l_date_tab
     ,p_batch_id              => l_batch_id
	 ,p_tax_rec_rate_tab	  => l_tax_rec_rate_tab); -- Bug 4969421
   ELSE
    INV_CONSUMPTION_ADVICE_PROC.load_summarized_quantity
     (p_txn_source_tab        => l_txn_source_tab
     ,p_inventory_item_tab    => l_item_tab
     ,p_organization_tab      => l_org_tab
     ,p_own_org_tab           => l_owning_org_tab
     ,p_transaction_cost_tab  => l_price_tab -- blanket_price from MCT Bug 4969421
     ,p_tax_code_tab          => l_tax_code_tab
     ,p_rec_tax_tab           => l_rec_tax_tab
     ,p_non_rec_tax_tab       => l_non_rec_tax_tab
     ,p_accrual_account_tab   => l_accrual_account_tab
     ,p_charge_account_tab    => l_charge_account_tab
     ,p_variance_account_tab  => l_variance_account_tab
     ,p_rate_tab              => l_rate_tab
     ,p_rate_type_tab         => l_rate_type_tab
     ,p_date_tab              => l_date_tab
     ,p_batch_id              => l_batch_id
	 ,p_tax_rec_rate_tab	  => l_tax_rec_rate_tab); -- Bug 4969421
   END IF;
   */

    -- The following loop removes records from the temp table
    -- if they are not candidates to populate the ensuing
    -- Consumption Advice document.
    -- The criteria for this decision being the
    -- state of their billing cycle

    l_loop_count := cons_temp_csr_type%ROWCOUNT - l_bulk_count;

    IF (l_debug = 1)
    THEN
      INV_LOG_UTIL.trace
      ( 'Consumption Txn Worker(l_loop_count)'||l_loop_count,'INV_CONSUMPTION_ADVICE_PROC'
       , 9
       );
    END IF;

    FOR i IN 1..l_loop_count
    LOOP

      IF l_txn_source_tab(i) <> l_current_txn_source_id OR
         l_org_tab(i) <> l_organization_id OR
         l_item_tab(i) <> l_inventory_item_id THEN

        l_current_txn_source_id := l_txn_source_tab(i);
        l_organization_id := l_org_tab(i);
        l_inventory_item_id := l_item_tab(i);

        IF (l_debug = 1)
        THEN
          INV_LOG_UTIL.trace
          ( 'Consumption Worker(l_current_txn_source_id)'||l_current_txn_source_id,'INV_CONSUMPTION_ADVICE_PROC'
           , 9
           );
          INV_LOG_UTIL.trace
          ( 'Cons Worker(l_organization_id)'||l_organization_id,'INV_CONSUMPTION_ADVICE_PROC'
           , 9
           );
          INV_LOG_UTIL.trace
          ( 'Cons Worker(l_inventory_item_id)'||l_inventory_item_id,'INV_CONSUMPTION_ADVICE_PROC'
           , 9
           );
        END IF;

        -- Find the vendor location information
        -- Bug 5092489. Query modified
        SELECT pvsa.vendor_id
        INTO l_vendor_id
        FROM po_vendor_sites_all pvsa
        WHERE pvsa.vendor_site_id = l_owning_org_tab(i)
        AND ROWNUM = 1;

        IF (l_debug = 1)
        THEN
          INV_LOG_UTIL.trace
          ( 'Consumption Txn Worker(l_vendor_id)'||l_vendor_id,'INV_CONSUMPTION_ADVICE_PROC'
           , 9
           );
        END IF;

        -- Find the billing cycle for each record in the temp table
        -- if no asl_id is found then the org id is updated to -1
        -- however in such cases we still process the transaction
        -- therefore the following line is required

        INV_PO_THIRD_PARTY_STOCK_MDTR.get_asl_info
         (p_item_id               => l_item_tab(i)
         ,p_vendor_id             => l_vendor_id
         ,p_vendor_site_id        => l_owning_org_tab(i)
         ,p_using_organization_id => l_organization_id
         ,x_asl_id                => l_asl_id
         ,x_vendor_product_num    => l_vendor_product_num
         ,x_purchasing_uom        => l_purchasing_uom);

         IF (l_debug = 1)
         THEN
           INV_LOG_UTIL.trace
           ( 'Consumption Txn Worker(l_asl_id)'||l_asl_id,'INV_CONSUMPTION_ADVICE_PROC'
            , 9
            );
         END IF;

        -- Update the temp table with the currency of the blanket

        UPDATE/*+ leading(mctt) */  MTL_CONSUMPTION_TXN_TEMP mctt
        SET mctt.currency_code = (SELECT poa.currency_code
                                  FROM po_headers_all poa
                                  WHERE poa.po_header_id
                                  = l_txn_source_tab(i))
           ,mctt.asl_id = l_asl_id
        WHERE mctt.transaction_source_id = l_txn_source_tab(i)
        AND mctt.organization_id = l_org_tab(i)
        AND mctt.inventory_item_id = l_item_tab(i);

      END IF;

      -- Even if no ASL_ID is returned then continue and process the record

      IF l_asl_id IS NULL
      THEN

        l_bill_date_elapsed := 0;

      ELSE

        INV_PO_THIRD_PARTY_STOCK_MDTR.get_elapsed_info
         (p_org_id               => l_org_tab(i)
         ,p_asl_id               => l_asl_id
         ,x_bill_date_elapsed    => l_bill_date_elapsed);

        IF (l_debug = 1)
        THEN
          INV_LOG_UTIL.trace
          ( 'Consumption Txn Worker(l_elapsed)'||l_bill_date_elapsed,'INV_CONSUMPTION_ADVICE_PROC'
           , 9
           );
          INV_LOG_UTIL.trace
          ( 'Consumption Txn Worker(l_org_tab)'||l_org_tab(i),'INV_CONSUMPTION_ADVICE_PROC'
           , 9
           );
      END IF;

      END IF;

      -- If the billing cycle has not elapsed yet then
      -- delete that record from the temp table
      -- This will have the effect of deferring the processing
      -- of the record until it's billing cycle has elapsed

      IF l_bill_date_elapsed = 1 THEN

        -- delete the record from the temporary table
        IF (l_debug = 1)
        THEN
          INV_LOG_UTIL.trace
          ( 'Consumption Txn Worker:Inside delete record','INV_CONSUMPTION_ADVICE_PROC'
           , 9
           );
        END IF;

        INV_CONSUMPTION_ADVICE_PROC.delete_record
         (p_txn_source_id         => l_txn_source_tab(i)
         ,p_inventory_item_id     => l_item_tab(i)
         ,p_organization_id       => l_org_tab(i)
         ,p_own_org_id            => l_owning_org_tab(i)
         ,p_price                 => l_price_tab(i)
         ,p_tax_code_id           => l_tax_code_tab(i)
         ,p_rec_tax_id            => l_rec_tax_tab(i)
         ,p_non_rec_tax_id        => l_non_rec_tax_tab(i)
         ,p_accrual_account_id    => l_accrual_account_tab(i)
         ,p_charge_account_id     => l_charge_account_tab(i)
         ,p_variance_account_id   => l_variance_account_tab(i)
         ,p_rate                  => l_rate_tab(i)
         ,p_rate_type             => l_rate_type_tab(i)
         ,p_date                  => l_date_tab(i));

      END IF;

    END LOOP;
    l_bulk_count :=  cons_temp_csr_type%ROWCOUNT;

    IF (l_debug = 1)
    THEN
      INV_LOG_UTIL.trace
      ( 'Consumption Txn Worker(l_bulk_count)'||l_bulk_count,'INV_CONSUMPTION_ADVICE_PROC'
       , 9
       );
    END IF;
    EXIT WHEN l_loop_count < 1000;

  END LOOP;

  CLOSE cons_temp_csr_type;

  -- Call the Load Interface Tables procedure to
  -- Load the PO interface tables and call the autocreate procedure

  /* Bug 4599072 - Start */
  /* The Load_Interface_Tables_prf procedure will no longer be used */

  INV_CONSUMPTION_ADVICE_PROC.load_interface_tables
   (p_batch_id       => l_batch_id
   ,x_return_status  => l_return_status);
  /* Bug 4599072 - Start */
   /* bug 5113064 - Start */
  /* clean up invalid records in MCT */
  UPDATE mtl_consumption_transactions
  SET batch_id = NULL
  WHERE batch_id = p_batch_id
  AND consumption_processed_flag IN ('N','E')
  AND consumption_po_header_id IS  NULL
  AND consumption_release_id IS NULL;
  /* clean up MCT - end */
  /* bug 5113064 - Start */

  IF l_return_status <> 'S' THEN

    INV_CONSUMPTION_ADVICE_PROC.generate_log(l_batch_id);

  END IF;

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '<< Consumption Txn Worker','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

END consumption_txn_worker;

--========================================================================
-- FUNCTION  : Generate_Batch_Id         PRIVATE
-- PARAMETERS: None
-- RETURNS   : NUMBER
-- COMMENT   : This function returns the next batch id to be assigned to
--             the records in MTL_CONSUMPTION_TRANSACTIONS
--=========================================================================
FUNCTION generate_batch_id
RETURN NUMBER
IS
l_batch_id NUMBER;
l_debug    NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> Generate Batch Id','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

  -- Generate sequence that will become the new batch id

  /* Bug 11822877. Changed the sequence value from mtl_third_party_cp_s
     to be in synchronization with PO headers sequence */
  SELECT  po_headers_interface_s.nextval
    INTO  l_batch_id
    FROM  dual;

  RETURN l_batch_id;

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '<< Generate Batch Id','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

END generate_batch_id;

--========================================================================
-- FUNCTION  : Has_Worker_Completed    PRIVATE
-- PARAMETERS: p_request_id            IN  NUMBER
-- RETURNS   : BOOLEAN
-- COMMENT   : Accepts a request ID. TRUE if the corresponding worker
--             has completed; FALSE otherwise
--=========================================================================
FUNCTION has_worker_completed
( p_request_id  IN NUMBER
)
RETURN BOOLEAN
IS
l_count   NUMBER;
l_result  BOOLEAN;
l_debug    NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> Has Worker Completed','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

  SELECT  COUNT(*)
    INTO  l_count
    FROM  fnd_concurrent_requests
    WHERE request_id = p_request_id
      AND phase_code = 'C';

  IF l_count = 1 THEN
    l_result := TRUE;
  ELSE
    l_result := FALSE;
  END IF;

  RETURN l_result;

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '<< Has Worker Completed','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

END has_worker_completed;

--========================================================================
-- PROCEDURE : Wait_For_Worker         PRIVATE
-- PARAMETERS: p_workers               IN  workers' request ID
--             x_worker_idx            OUT position in p_workers of the
--                                         completed worked
-- COMMENT   : This procedure polls the submitted workers and suspend
--             the program till the completion of one of them; it returns
--             the completed worker through x_worker_idx
--=========================================================================
PROCEDURE wait_for_worker
( p_workers          IN  g_request_tbl_type
, x_worker_idx       OUT NOCOPY BINARY_INTEGER
)
IS
l_done     BOOLEAN;
l_debug    NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> Wait For Worker','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

  l_done := FALSE;

  WHILE (NOT l_done) LOOP

    FOR l_Idx IN 1..p_workers.COUNT LOOP

      IF INV_CONSUMPTION_ADVICE_PROC.has_worker_completed(p_workers(l_Idx))
      THEN
          l_done := TRUE;
          x_worker_idx := l_Idx;
          EXIT;
      END IF;

    END LOOP;

    IF (NOT l_done) THEN
      DBMS_LOCK.sleep(G_SLEEP_TIME);
    END IF;

  END LOOP;

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '<< Wait For Worker','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

END wait_for_worker;


--========================================================================
-- PROCEDURE : Wait_For_All_Workers    PRIVATE
-- PARAMETERS: p_workers               IN workers' request ID
-- COMMENT   : This procedure polls the submitted workers and suspend
--             the program till the completion of all of them.
--=========================================================================
PROCEDURE wait_for_all_workers
( p_workers          IN g_request_tbl_type
)
IS
l_done     BOOLEAN;
l_debug    NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> Wait For All Workers','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

  l_done := FALSE;

  WHILE (NOT l_done) LOOP

    l_done := TRUE;

    FOR l_Idx IN 1..p_workers.COUNT LOOP

      IF NOT
        INV_CONSUMPTION_ADVICE_PROC.has_worker_completed(p_workers(l_Idx))
      THEN
        l_done := FALSE;
        EXIT;
      END IF;

    END LOOP;

    IF (NOT l_done) THEN
      DBMS_LOCK.sleep(G_SLEEP_TIME);
    END IF;

  END LOOP;

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '<< Wait For All Workers','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

END wait_for_all_workers;


--========================================================================
-- PROCEDURE : Submit_Worker           PRIVATE
-- PARAMETERS: p_organization_id       IN            an organization
--             p_set_process_id        IN            Set process ID
--             x_workers               IN OUT NOCOPY workers' request ID
--             p_request_count         IN            max worker number
-- COMMENT   : This procedure submits the Worker concurrent program.
--             Before submitting the request, it verifies that there are
--             enough workers available and wait for the completion of one
--             if necessary.
--             The list of workers' request ID is updated.
--=========================================================================
PROCEDURE submit_worker
( p_batch_id         IN            NUMBER
, p_request_count    IN            NUMBER
, x_workers          IN OUT NOCOPY g_request_tbl_type
)
IS
l_worker_idx     BINARY_INTEGER;
l_request_id     NUMBER;
l_org_name       VARCHAR2(60) := NULL;
l_debug          NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> Submit Worker','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

  IF x_workers.COUNT < p_request_count THEN
    -- number of workers submitted so far does not exceed the maximum
    -- number of workers allowed
    l_worker_idx := x_workers.COUNT + 1;
  ELSE
    -- need to wait for a submitted worker to finish
    INV_CONSUMPTION_ADVICE_PROC.wait_for_worker
    ( p_workers    => x_workers
    , x_worker_idx => l_worker_idx
    );
  END IF;
 --bug7357385 start
  IF NOT FND_REQUEST.Set_Options
         (
         protected => 'YES'
         )
  --bug7357385 end
  THEN
    RAISE g_submit_failure_exc;
  END IF;

  x_workers(l_worker_idx) := FND_REQUEST.submit_request
                             ( application =>'INV'
                             , program     =>'INVCTXCW'
                             , description => l_org_name
                             , argument1   => p_batch_id
                             );

  IF x_workers(l_worker_idx) = 0 THEN
    RAISE g_submit_failure_exc;
  END IF;

  COMMIT;

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '<< Submit Worker','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

END submit_worker;

--========================================================================
-- PROCEDURE : Batch Allocation      PRIVATE
-- COMMENT   : This procedure will be called exclusively from the manager.
--             It divides candidate unprocessed records into batches.
--             Once the contents of a batch are established the
--             associated records in MTL_CONSUMPTION_TRANSACTIONS are
--             updated with a batch id and a concurrent program submitted.
--             If there are more candidate unprocessed records then further
--             batches are established and concurrent programs submitted.
--             Thus for large numbers of records concurrency can be achieved.
--             The precedure ends and contol is passed back to the manager
--             when all the submitted concurrent programs have completed.
--=========================================================================
PROCEDURE  batch_allocation
( p_batch_size       IN           NUMBER
, p_max_workers      IN           NUMBER
)
IS

  --================
  -- CURSORS
  --================

  CURSOR cons_temp_csr_type IS
    SELECT mctt.transaction_source_id
         , mctt.inventory_item_id
         , mctt.organization_id
         , mctt.transaction_cost-- blanket_price from MCT  Bug 4969421
         , mctt.tax_code_id
         , mctt.accrual_account_id
         , mctt.charge_account_id
         , mctt.variance_account_id
         , mctt.rate
         , mctt.rate_type
         , mctt.transaction_date
    FROM MTL_CONSUMPTION_TXN_TEMP mctt
    ORDER BY mctt.transaction_source_id
           , mctt.organization_id;

  --=================
  -- LOCAL VARIABLES
  --=================

  l_previous_cons_index         BINARY_INTEGER := 1;
  l_current_cons_index          BINARY_INTEGER := 1;
  l_next_cons_index             BINARY_INTEGER := 1;
  l_empty_cons_tab              g_cons_tbl_type;
  l_empty_varchar_cons_tab      g_cons_varchar_tbl_type;
  l_empty_date_cons_tab         g_cons_date_tbl_type;
  l_txn_source_tab              g_cons_tbl_type;
  l_item_tab                    g_cons_tbl_type;
  l_org_tab                     g_cons_tbl_type;
  l_price_tab                   g_cons_tbl_type;
  l_tax_code_tab                g_cons_tbl_type;
  l_accrual_account_tab         g_cons_tbl_type;
  l_charge_account_tab          g_cons_tbl_type;
  l_variance_account_tab        g_cons_tbl_type;
  l_rate_tab                    g_cons_tbl_type;
  l_rate_type_tab               g_cons_varchar_tbl_type;
  l_date_tab                    g_cons_date_tbl_type;
  l_batch_id                    NUMBER;
  l_current_batch_id            NUMBER;
  l_batch_size                  NUMBER;
  l_batch_count                 NUMBER := 1;
  l_group_size                  NUMBER;
  l_group_count                 NUMBER := 1;
  l_remain_batch_count          NUMBER;
  l_workers_tbl                 g_request_tbl_type;
  l_count                       NUMBER;
  l_max_workers                 NUMBER;
  l_org_id                      NUMBER;
  l_new_batch                   VARCHAR2(1) := 'Y';
  l_debug                       NUMBER := NVL(FND_PROFILE.VALUE
                                          ('INV_DEBUG_TRACE'),0);
  l_debug_txn_id                NUMBER;


BEGIN

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> Batch Allocation','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

  -- open cursor

  IF NOT cons_temp_csr_type%ISOPEN
  THEN
    OPEN cons_temp_csr_type;
  END IF;

  -- clear the pl/sql table before use

  l_txn_source_tab         := l_empty_cons_tab;
  l_item_tab               := l_empty_cons_tab;
  l_org_tab                := l_empty_cons_tab;
  l_price_tab              := l_empty_cons_tab;
  l_tax_code_tab           := l_empty_cons_tab;
  l_accrual_account_tab    := l_empty_cons_tab;
  l_charge_account_tab     := l_empty_cons_tab;
  l_variance_account_tab   := l_empty_cons_tab;
  l_rate_tab               := l_empty_cons_tab;
  l_rate_type_tab          := l_empty_varchar_cons_tab;
  l_date_tab               := l_empty_date_cons_tab;


  IF p_batch_size IS NOT NULL THEN
    l_batch_size := p_batch_size;
  ELSE
    l_batch_size := g_batch_size;
  END IF;

  IF p_max_workers IS NOT NULL THEN
    l_max_workers := p_max_workers;
  ELSE
    l_max_workers := g_max_workers;
  END IF;

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> Batch Allocation(p_batch_size)'||p_batch_size,'INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
    INV_LOG_UTIL.trace
    ( '>> Batch Allocation(l_batch_size)'||l_batch_size,'INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
    INV_LOG_UTIL.trace
    ( '>> Batch Allocation(l_max_workers)'||l_max_workers,'INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
    INV_LOG_UTIL.trace
    ( '>> Batch Allocation(p_max_workers)'||p_max_workers,'INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

  -- population of pl/sql table

  FETCH cons_temp_csr_type
  INTO l_txn_source_tab(l_txn_source_tab.COUNT+1)
      ,l_item_tab(l_item_tab.COUNT+1)
      ,l_org_tab(l_org_tab.COUNT+1)
      ,l_price_tab(l_price_tab.COUNT+1)
      ,l_tax_code_tab(l_tax_code_tab.COUNT+1)
      ,l_accrual_account_tab(l_accrual_account_tab.COUNT+1)
      ,l_charge_account_tab(l_charge_account_tab.COUNT+1)
      ,l_variance_account_tab(l_variance_account_tab.COUNT+1)
      ,l_rate_tab(l_rate_tab.COUNT+1)
      ,l_rate_type_tab(l_rate_type_tab.COUNT+1)
      ,l_date_tab(l_date_tab.COUNT+1);


  WHILE cons_temp_csr_type%FOUND
  LOOP

   FETCH cons_temp_csr_type
    INTO l_txn_source_tab(l_txn_source_tab.COUNT+1)
        ,l_item_tab(l_item_tab.COUNT+1)
        ,l_org_tab(l_org_tab.COUNT+1)
        ,l_price_tab(l_price_tab.COUNT+1)
        ,l_tax_code_tab(l_tax_code_tab.COUNT+1)
        ,l_accrual_account_tab(l_accrual_account_tab.COUNT+1)
        ,l_charge_account_tab(l_charge_account_tab.COUNT+1)
        ,l_variance_account_tab(l_variance_account_tab.COUNT+1)
        ,l_rate_tab(l_rate_tab.COUNT+1)
        ,l_rate_type_tab(l_rate_type_tab.COUNT+1)
        ,l_date_tab(l_date_tab.COUNT+1);


  END LOOP;

  CLOSE cons_temp_csr_type;

  -- Allocate a batch id to records in MTL_CONSUMPTION_TRANSACTIONS
  -- A new batch is started if the current batch is full or if the
  -- number of summarized records in the next batch exceeds
  -- the size remaining in the current batch. The only exception to
  -- this rule is when the first record a new batch is being
  -- considered. If in that case the blanket size > batch size then
  -- the current batch is used.

  l_current_batch_id := generate_batch_id();
  l_remain_batch_count := l_batch_size;
  l_current_cons_index := l_txn_source_tab.FIRST;

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> Batch Alloc (l_current_batch_id)'||l_current_batch_id,'INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
    INV_LOG_UTIL.trace
    ( '>> Batch Alloc (l_remain_batch_count)'||l_remain_batch_count,'INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
    INV_LOG_UTIL.trace
    ( '>> Batch Alloc (l_current_cons_index)'||l_current_cons_index,'INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

  -- Query how many summarized records have been loaded into
  -- in the temporary table MTL_CONSUMPTION_TXN_TEMP for the
  -- current blanket and set the group size accordingly

  SELECT
    COUNT(*)
  INTO
    l_group_size
  FROM
    mtl_consumption_txn_temp mctt
  WHERE mctt.transaction_source_id = l_txn_source_tab(l_current_cons_index);

  LOOP

    l_group_count := l_group_count + 1;

    IF (l_debug = 1)
    THEN
      INV_LOG_UTIL.trace
      ( '>> Batch Alloc(l_group_count)'||l_group_count,'INV_CONSUMPTION_ADVICE_PROC'
       , 9
       );
      INV_LOG_UTIL.trace
      ( '>> Batch Alloc(l_group_size)'||l_group_size,'INV_CONSUMPTION_ADVICE_PROC'
       , 9
       );
    END IF;

    -- If the last record of the current blanket
    -- has been reached then reset the associate parameters
    -- for the next blanket in the batch

    l_next_cons_index := l_current_cons_index + 1;

    IF (l_debug = 1)
    THEN
      INV_LOG_UTIL.trace
      ( '>> Batch Alloc(l_next_cons_index)'||l_next_cons_index,'INV_CONSUMPTION_ADVICE_PROC'
       , 9
       );
      INV_LOG_UTIL.trace
      ( '>> Batch Alloc(l_current_cons_index)'||l_current_cons_index,'INV_CONSUMPTION_ADVICE_PROC'
       , 9
       );
    END IF;

    IF l_group_count > l_group_size
    AND l_current_cons_index < l_txn_source_tab.LAST THEN

      -- Find the number of summarized records in the next blanket

      SELECT
        COUNT(*)
      INTO
        l_group_size
      FROM
        mtl_consumption_txn_temp mctt
      WHERE mctt.transaction_source_id =
            l_txn_source_tab(l_next_cons_index);

      l_group_count := 1;

      l_remain_batch_count := l_batch_size - l_batch_count;
      l_new_batch := 'N';

      IF (l_debug = 1)
      THEN
        INV_LOG_UTIL.trace
        ( '>> Batch Alloc....group_count>group_size' ,'INV_CONSUMPTION_ADVICE_PROC'
         , 9
         );
        INV_LOG_UTIL.trace
        ( '>> Batch Alloc (l_group_size)'||l_group_size,'INV_CONSUMPTION_ADVICE_PROC'
         , 9
         );
        INV_LOG_UTIL.trace
        ( '>> Batch Alloc (l_remain_batch_count)'||l_remain_batch_count,'INV_CONSUMPTION_ADVICE_PROC'
         , 9
         );
        INV_LOG_UTIL.trace
        ( '>> Batch Alloc (l_batch_size)'||l_batch_size,'INV_CONSUMPTION_ADVICE_PROC'
         , 9
         );
        INV_LOG_UTIL.trace
        ( '>> Batch Alloc (l_batch_ct)'||l_batch_count,'INV_CONSUMPTION_ADVICE_PROC'
         , 9
         );
        INV_LOG_UTIL.trace
        ( '>> Batch Alloc....' ,'INV_CONSUMPTION_ADVICE_PROC'
         , 9
         );
    END IF;

    END IF;

    -- If the last record of the current batch has been reached
    -- OR the record count for the next
    -- blanket exceeds the remaining batch size
    -- then move to the next batch
    -- unless the batch count is 1 in which case continue
    -- with the current batch id

    IF l_batch_count = l_batch_size
    OR (l_group_size > l_remain_batch_count AND l_new_batch = 'N')
    OR l_current_cons_index = l_txn_source_tab.LAST
    THEN

    --IF NVL(FND_PROFILE.value('INV_SUPPLIER_CONSIGNED_GROUPING'),'N') = 'N'
    --THEN
      FORALL i IN l_previous_cons_index..l_current_cons_index
        --Bug 5092489, Query modified to eliminate use of MMT
        UPDATE
          MTL_CONSUMPTION_TRANSACTIONS mct
        SET mct.batch_id = l_current_batch_id
 	       /* request id stamped to MCT  - bug 5200436 - Start*/
	      , mct.request_id					= g_request_id
        WHERE  mct.transaction_source_id  = l_txn_source_tab(i)
        AND mct.batch_id = -1
        AND mct.consumption_processed_flag IN ('N','E')
        AND mct.inventory_item_id = l_item_tab(i)
        AND mct.organization_id = l_org_tab(i)
        AND mct.blanket_price = l_price_tab(i)
        AND NVL(mct.tax_code_id,-1) = NVL(l_tax_code_tab(i),-1)
        AND NVL(mct.accrual_account_id,-1) =
                 NVL(l_accrual_account_tab(i),-1)
        AND NVL(mct.charge_account_id,-1) =
                 NVL(l_charge_account_tab(i),-1)
        AND NVL(mct.variance_account_id,-1) =
                 NVL(l_variance_account_tab(i),-1)
        AND NVL(mct.rate,-1) = NVL(l_rate_tab(i),-1)
        AND NVL(mct.rate_type,'##') = NVL(l_rate_type_tab(i), '##');
 	       /* bug 5200436 - End*/

     -- Deleted unused commented code as part of bug 11900144

     -- Bug 5092489. l_previous_cons_index has to be set as l_current_cons_index
     l_previous_cons_index := l_current_cons_index+1;

      -- Update the table MTL_CONSUMPTION_TRANSACTIONS with the
      -- current batch id for Transfer to consigned txns.


      UPDATE
        MTL_CONSUMPTION_TRANSACTIONS mct
      SET mct.batch_id = l_current_batch_id
      WHERE mct.parent_transaction_id IN
        (SELECT
           mct_in.transaction_id
         FROM
           MTL_CONSUMPTION_TRANSACTIONS mct_in
         WHERE mct_in.batch_id = l_current_batch_id
         --AND mct.consumption_processed_flag <> 'Y');
         --Bug 5092489
         AND mct_in.consumption_processed_flag IN ('N', 'E'))
         AND mct.consumption_processed_flag IN ('N', 'E');

      -- Call concurrent worker

      INV_CONSUMPTION_ADVICE_PROC.submit_worker( l_current_batch_id
                                               , l_max_workers
                                               , l_workers_tbl);

      -- the size of the group can only be a maximum of the batch size

      IF (l_debug = 1)
      THEN
        INV_LOG_UTIL.trace
        ( 'After submit worker'||l_group_size,'INV_CONSUMPTION_ADVICE_PROC'
         , 9
         );
        INV_LOG_UTIL.trace
        ( 'Batch Alloc(l_group_size)'||l_group_size,'INV_CONSUMPTION_ADVICE_PROC'
         , 9
         );
        INV_LOG_UTIL.trace
        ( 'Batch Alloc(l_batch_size)'||l_batch_size,'INV_CONSUMPTION_ADVICE_PROC'
         , 9
         );
      END IF;

      IF l_group_size > l_batch_size THEN
        l_group_size := l_group_size - l_batch_count;
      END IF;

      IF (l_debug = 1)
      THEN
        INV_LOG_UTIL.trace
        ( 'Batch Alloc(l_group_size)'||l_group_size,'INV_CONSUMPTION_ADVICE_PROC'
         , 9
         );
      END IF;

      --l_group_count :=0;

      -- Reset Batch Variables

      l_new_batch := 'Y';
      l_current_batch_id := generate_batch_id();
      l_batch_count := 0;
      l_remain_batch_count := l_batch_size;
      l_group_count :=0;

      IF (l_debug = 1)
      THEN
        INV_LOG_UTIL.trace
        ( 'Batch Alloc(l_current_batch_id)'||l_current_batch_id,'INV_CONSUMPTION_ADVICE_PROC'
         , 9
         );
        INV_LOG_UTIL.trace
        ( 'Batch Alloc(l_remain_batch_count)'||l_remain_batch_count,'INV_CONSUMPTION_ADVICE_PROC'
         , 9
         );
    END IF;

    END IF;

    -- If the last record in MMTT is reached then stop
    EXIT WHEN l_current_cons_index = l_txn_source_tab.LAST;

    l_current_cons_index := l_txn_source_tab.NEXT(l_current_cons_index);

    l_batch_count := l_batch_count + 1;

    IF (l_debug = 1)
    THEN
      INV_LOG_UTIL.trace
      ( 'Batch Alloc(l_current_cons_index)'||l_current_cons_index,'INV_CONSUMPTION_ADVICE_PROC'
       , 9
       );
      INV_LOG_UTIL.trace
      ( 'Batch Alloc(l_batch_count)'||l_batch_count,'INV_CONSUMPTION_ADVICE_PROC'
       , 9
       );
    END IF;

  END LOOP;

  -- Return control when all concurrent programs have completed

  INV_CONSUMPTION_ADVICE_PROC.wait_for_all_workers
  ( p_workers => l_workers_tbl
  );

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '<< Batch Allocation','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;


EXCEPTION

  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
     INV_LOG_UTIL.trace
     ( SQLCODE  || ' : ' || SQLERRM ,'INV_CONSUMPTION_ADVICE_PROC'
      , 9
     );
    END IF;

    FND_MESSAGE.set_name('INV', 'INV_CONS_SUP_BCH_ALL');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END batch_allocation;

--========================================================================
-- PROCEDURE : Consumption_Txn_Manager     PUBLIC
-- COMMENT   : This procedure will assign each unprocessed record in
--             MTL_CONSUMPTION_TRANSACTIONS to a batch and then call the
--             Consumption_Transaction_Worker for that batch. The manager
--             will continue until all records
--             in MTL_CONSUMPTION_TRANSACTIONS
--             have been assigned to a batch.
--=========================================================================
PROCEDURE  consumption_txn_manager
( p_batch_size         IN    NUMBER
, p_max_workers        IN    NUMBER
, p_vendor_id          IN    NUMBER
, p_vendor_site_id     IN    NUMBER
, p_inventory_item_id  IN    NUMBER
, p_organization_id    IN    NUMBER
)
IS

-- Bug ,  - Creating REF cursors to associate with
-- appropriate queries at run time and avoid NVL checks
-- Start
-- ======================
-- Dynamic Cursor Variable
-- =======================
/* Bug 5092489. Commented as not used
TYPE blanket_csr_type             IS REF CURSOR;
l_blanket_csr                     blanket_csr_type;

--Bug 4863365 - End


--=================
-- VARIABLES
--=================

l_agreement_flag              VARCHAR2(1);
l_transaction_source_id       NUMBER;
l_current_cons_index          BINARY_INTEGER := 0;
l_current_index               BINARY_INTEGER;
l_empty_cons_tab              g_cons_tbl_type;
l_txn_source_tab              g_cons_tbl_type;
l_org_tab                     g_cons_tbl_type;
l_blanket_query			    VARCHAR2(15000); --  Bug 4666585
*/
l_count                       NUMBER;
l_batch_id                    NUMBER := -1;
l_debug                       NUMBER := NVL(FND_PROFILE.VALUE
                                 ('INV_DEBUG_TRACE'),0);



BEGIN

  IF (l_debug = 1)
  THEN
      INV_LOG_UTIL.trace
    ( '>> Consumption Txn Manager','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
    INV_LOG_UTIL.trace
    ( '>> p_batch_size: '|| p_batch_size,'INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
    INV_LOG_UTIL.trace
    ( '>> p_max_workers: '||p_max_workers,'INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
    INV_LOG_UTIL.trace
    ( '>> p_vendor_id: '||p_vendor_id,'INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
    INV_LOG_UTIL.trace
    ( '>> p_vendor_site_id: '||p_vendor_site_id,'INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
    INV_LOG_UTIL.trace
    ( '>> p_inventory_item_id: '||p_inventory_item_id,'INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
    INV_LOG_UTIL.trace
    ( '>> p_organization_id: '||p_organization_id,'INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );

  END IF;

  g_request_id := NULL;
  g_request_id    :=
      TO_NUMBER(FND_PROFILE.Value('CONC_REQUEST_ID') ) ;

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> g_request_id => '|| g_request_id
     , 9
     );
  END IF;

       -- Bug 11900144
       INV_CONSUMPTION_ADVICE_PROC.populate_po_line_id();


  -- Mark all the records that are to be processed

	 /* Bug 4945892 - Start */
	/* Update modified to remove check for consumption_processed_flag */
	/* When consumption advice program is run , the manager populates
	the null batch_ids to -1. A parallely running consumption advice program
	will NOT pick up these 'marked' records. Prevents release duplication */
  -- Bug 5092489. Following query is commented in included with other query.
  --UPDATE
  --  MTL_CONSUMPTION_TRANSACTIONS
  --SET
  --  batch_id = l_batch_id
  --/* bug 5200436 - request_id stamped in batch_allocation */
  --, request_id = g_request_id
  --WHERE
  --  batch_id IS NULL
  --  AND NVL(net_qty,0) > 0
  --  -- Bug: 5092489. Following clause added for fast searching of MCT.
  --  AND consumption_processed_flag IN ('N', 'E') ;

   /* Bug 4945892 - End */

  -- Bug 5092489. Following query is  modified to check (net_qty>0) and (mct.batch_id IS NULL)
  SELECT
    COUNT(*)
  INTO
    l_count
  FROM
    MTL_CONSUMPTION_TRANSACTIONS mct
  , MTL_MATERIAL_TRANSACTIONS mmt
  , po_vendor_sites_all pvsa
  WHERE mct.transaction_id = mmt.transaction_id
  AND mmt.owning_organization_id = pvsa.vendor_site_id
  AND pvsa.vendor_id = NVL(p_vendor_id, pvsa.vendor_id)
  AND ( mct.batch_id = l_batch_id OR mct.batch_id IS NULL)
  And NVL(net_qty,0) > 0
  AND mmt.owning_organization_id =
      NVL(p_vendor_site_id, mmt.owning_organization_id)
  AND mmt.organization_id = NVL(p_organization_id, mmt.organization_id)
  AND mmt.inventory_item_id = NVL(p_inventory_item_id, mmt.inventory_item_id)
  AND consumption_processed_flag IN ('N', 'E')
  AND mmt.transaction_type_id = 74
    AND mmt.transaction_action_id = 6
    AND mmt.transaction_source_type_id = 1;

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '<< CA Mgr (l_count):'||l_count,'INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
    INV_LOG_UTIL.trace
    ( '<< CA Mgr(batch_id):'||l_batch_id,'INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

  IF l_count > 0 THEN

       --Bug 5092489: New condition added
       UPDATE MTL_CONSUMPTION_TRANSACTIONS mct
       SET (mct.batch_id, mct.transaction_source_id, mct.inventory_item_id,
       mct.accrual_account_id, mct.organization_id,
       mct.owning_organization_id, mct.transaction_date)
       = (SELECT
         l_batch_id, mmt.transaction_source_id,
         mmt.inventory_item_id, mmt.distribution_account_id,
         mmt.organization_id, mmt.owning_organization_id,
         mmt.transaction_date
         FROM mtl_material_transactions mmt,po_vendor_sites_all pvsa
         WHERE mct.transaction_id = mmt.transaction_id
         AND mmt.owning_organization_id = pvsa.vendor_site_id
         AND (p_vendor_id IS NULL OR pvsa.vendor_id = p_vendor_id)
         AND (p_vendor_site_id IS NULL OR pvsa.vendor_site_id =
           p_vendor_site_id)
         AND (p_organization_id IS NULL OR mmt.organization_id = p_organization_id)
         AND (p_inventory_item_id IS NULL OR mmt.inventory_item_id = p_inventory_item_id)
         )
       WHERE mct.consumption_processed_flag IN ('N', 'E')
       AND NVL(net_qty,0) > 0
       AND ( mct.batch_id = l_batch_id OR mct.batch_id IS NULL)
       AND mct.po_line_id IS NOT NULL;          --bug 11900144


       UPDATE MTL_CONSUMPTION_TRANSACTIONS mct
       SET (mct.global_agreement_flag) =
         (SELECT NVL(global_agreement_flag,'N') FROM po_headers_all
          WHERE po_header_id = mct.transaction_source_id)
       WHERE mct.consumption_processed_flag IN ('N', 'E')
       AND mct.batch_id = l_batch_id;

    -- Deleted unused commeneted code as part of bug 11900144

  IF NVL(FND_PROFILE.value('INV_SUPPLIER_CONSIGNED_GROUPING'),'N') = 'N'
  THEN
    INV_CONSUMPTION_ADVICE_PROC.load_combination_prf
     (p_batch_id          => l_batch_id
     ,p_vendor_id         => p_vendor_id
     ,p_vendor_site_id    => p_vendor_site_id
     ,p_inventory_item_id => p_inventory_item_id
     ,p_organization_id   => p_organization_id);
  ELSE
    INV_CONSUMPTION_ADVICE_PROC.load_combination
     (p_batch_id          => l_batch_id
     ,p_vendor_id         => p_vendor_id
     ,p_vendor_site_id    => p_vendor_site_id
     ,p_inventory_item_id => p_inventory_item_id
     ,p_organization_id   => p_organization_id);

  END IF;

    -- Call procedure to assign a batch_id to unprocessed data
    -- in MTL_CONSUMPTION_TRANSACTIONS and call the worker to
    -- process a batch

    IF (l_debug = 1)
    THEN
      INV_LOG_UTIL.trace
      ( 'Calling Batch Allocation(size) '||p_batch_size,'INV_CONSUMPTION_ADVICE_PROC'
       , 9
       );
      INV_LOG_UTIL.trace
      ( 'Workers '||p_max_workers,'INV_CONSUMPTION_ADVICE_PROC'
       , 9
       );
    END IF;

    INV_CONSUMPTION_ADVICE_PROC.batch_allocation
     (p_batch_size        => p_batch_size
     ,p_max_workers       => p_max_workers);

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( 'Calling update_po_distrubution_id '
     , 9
     );
  END IF;

  update_po_distrubution_id ;
  END IF;


  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '<< Consumption Txn Manager','INV_CONSUMPTION_ADVICE_PROC'
     , 9
     );
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
     INV_LOG_UTIL.trace
     ( SQLCODE  || ' : ' || SQLERRM ,'INV_CONSUMPTION_ADVICE_PROC'
      , 9
     );
    END IF;

    FND_MESSAGE.set_name('INV', 'INV_CONS_SUP_DEL_REC');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END consumption_txn_manager;

END INV_CONSUMPTION_ADVICE_PROC;

/
