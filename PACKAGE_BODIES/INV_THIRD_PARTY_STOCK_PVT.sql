--------------------------------------------------------
--  DDL for Package Body INV_THIRD_PARTY_STOCK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_THIRD_PARTY_STOCK_PVT" AS
-- $Header: INVVTPSB.pls 120.23.12010000.7 2011/04/11 06:41:04 ksaripal ship $
--+=======================================================================+
--|               Copyright (c) 2002 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVVTPSB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Consignment Financial Document API                                 |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Record_Consumption                                                |
--|     Populate_Cost_Details                                             |
--|     Get_Conversion_Rate                                               |
--|     ReSet_OU_Context                                                  |
--|     Get_PO_Info                                                       |
--|     Get_Account                                                       |
--|     Get_Consumed_Amt                                                  |
--|     Get_Total_Blanket_Amt                                             |
--|     Process_Financial_Info                                            |
--|                                                                       |
--| HISTORY                                                               |
--|     10/01/02  Prabha Seshadri Created Finacial Document API           |
--|     Jul-29    rajkrish       consigned error rpt	   				  |
--|		07-Mar-06 kdevadas		 BLANKET_PRICE and PO_DISTRIBUTION_ID     |
--|				  				 columns added to MCT.PO price returned   |
--|                              by get_break_price is inserted INTO      |
--|								 MTL_CONSUMPTION_TRANSACTIONS-Bug 4969421 |
--|		22-May-06 kdevadas		 Delete from ZX_TRX_HEADERS_GT before     |
--|				  				 insertion. This prevents 'Unique         |
--|                              Constraint Violated' error- Bug 5084307  |
--|     18-Jul-06 kdevadas  	 Get_Consumed_Amt procedure changed	  	  |
--|     		  		 		 to use mct.blanket_price rather than     |
--|     		  		 		 mmt.transaction_cost - Bug 5395579		  |
--|     28-Aug-06 kdevadas  	 Delete before inserting into ZX_LINES	  |
--|				  				 and ZX_DISTRIBUTIONS - Bug 5488006	 	  |
--|     14-Sep-06 kdevadas  	 Changed cursor in Calculate_Tax to fetch |
--|				  				 tax_rate and tax_rec_rate - Bug 5530358  |
--+========================================================================

--===================
-- GLOBALS
--===================

G_PKG_NAME CONSTANT    VARCHAR2(30) := 'INV_THIRD_PARTY_STOCK_PVT';
g_user_id              NUMBER       := FND_PROFILE.value('USER_ID');
g_resp_id              NUMBER       := FND_PROFILE.value('RESP_ID');
g_pgm_appl_id          NUMBER       := FND_PROFILE.value('RESP_APPL_ID');

TYPE ctx_value_rec_type IS RECORD (org_id NUMBER, resp_id NUMBER);
TYPE ctx_tbl_type IS TABLE OF ctx_value_rec_type INDEX BY BINARY_INTEGER;
g_context_tbl          ctx_tbl_type;


g_error_code VARCHAR2(35) ;
g_calling_action VARCHAR2(1) ;
g_po_header_id NUMBER ;
g_purchasing_uom VARCHAR2(25);
g_primary_uom    VARCHAR2(25);

--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Record_Consumption            PRIVATE
-- PARAMETERS: p_mtl_transaction_id          Material transaction id
--             p_rct_transaction_id          Txn Id receipt side
--             p_transaction_source_type_id  Txn Src Type
--             p_transaction_source_id       Txn source
--             p_transaction_quantity        Txn Qty
--             p_tax_code_id                 Tax code
--             p_tax_rate                    Tax Rate
--             p_recoverable_tax             Recoverable Tax
--             p_non_recoverable_tax         Non Recoverable Tax
--             p_rate                        Exchange rate
--             p_rate_type                   Exchange Rate type
--             p_charge_account_id           Charge account
--			   p_po_price					 Unit Price  -- Bug 4969420
--             p_secondary_transaction_qty        Secondary Txn Qty /*INVCONV*/

-- COMMENT   : Procedure to insert the consignment transactions, when
--             consumption takes place.Invoked by Process_Financial_Info
-- Changes   : INVCONV added a new parameter p_secondary_transaction_qty
--             to support process features.
--========================================================================
PROCEDURE Record_Consumption
( p_mtl_transaction_id             IN   NUMBER
, p_transaction_source_type_id     IN   NUMBER
, p_transaction_action_id          IN   NUMBER
, p_transaction_source_id          IN   NUMBER
, p_transaction_quantity           IN   NUMBER
, p_tax_code_id                    IN   NUMBER
, p_tax_rate                       IN   NUMBER
, p_tax_recovery_rate              IN   NUMBER
, p_recoverable_tax                IN   NUMBER
, p_non_recoverable_tax            IN   NUMBER
, p_rate                           IN   NUMBER
, p_rate_type                      IN   VARCHAR2
, p_charge_account_id              IN   NUMBER
, p_variance_account_id            IN   NUMBER
  /*bug 4969420 - Start*/
  /* Storing the unit price in MCT */
, p_unit_price					   IN   NUMBER
  /* bug 4969420 - End */
-- Bug 11900144. Passing po_line_id to record consumption
, p_po_line_id                     IN NUMBER
, p_secondary_transaction_qty IN   NUMBER DEFAULT NULL
)
IS
l_net_qty            NUMBER;
l_parent_transaction NUMBER;
l_debug              NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_secondary_net_qty            NUMBER; /* INVCONV */

BEGIN

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> Entering Record Consumption','INV_THIRD_PARTY_STOCK_PVT'
     , 9
     );
  END IF;

  -- For a correction transaction, update the net_qty of the parent txn
  -- by subtracting the transaction quantity of the correction.
  -- After updating the net qty of the parent, make the net_qty null
  -- for the correction transaction. The summarization API will not
  -- pick up the correction transaction for summarization .

  -- INVCONV Similarly update the secondary quantity of the parent.

  IF (p_transaction_source_type_id=13) AND (p_transaction_action_id = 6)
     AND (p_transaction_source_id IS NOT NULL)
  THEN
    UPDATE mtl_consumption_transactions
    SET    net_qty          = (net_qty - ABS(p_transaction_quantity)),
           secondary_net_qty = (secondary_net_qty - ABS(p_secondary_transaction_qty)), /* INVCONV */
	   consumption_processed_flag = Decode(Nvl(net_qty,0) - abs(p_transaction_quantity), 0,                 -- Bug 7361382 Changes Start
                                                  null, consumption_processed_flag)				-- Bug 7361382 Changes End
    WHERE  transaction_id   =  p_transaction_source_id;

    l_net_qty            := NULL;
    l_secondary_net_qty  := NULL; /* INVCONV */
    l_parent_transaction := p_transaction_source_id;
  ELSE
    l_net_qty := p_transaction_quantity;
    l_secondary_net_qty  := p_secondary_transaction_qty; /* INVCONV */
  END IF;


  INSERT INTO mtl_consumption_transactions
  ( transaction_id
  , consumption_processed_flag
  , net_qty
  , tax_code_id
  , tax_rate
  , tax_recovery_rate
  , recoverable_tax
  , non_recoverable_tax
  , rate
  , rate_type
  , charge_account_id
  , variance_account_id
  , parent_transaction_id
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date
  , last_update_login
  /* Bug 4969420 - Start  */
  , blanket_price
  /* Bug 4969420 - End */
  /* Bug 11900144. Addition of po_line_id */
  , po_line_id
  , secondary_net_qty /* INVCONV */
  )
  VALUES
  ( p_mtl_transaction_id
  , 'N'
  , l_net_qty
  , NVL(p_tax_code_id,-1)
  , p_tax_rate
  , p_tax_recovery_rate
  , p_recoverable_tax
  , p_non_recoverable_tax
  , p_rate
  , p_rate_type
  , p_charge_account_id
  , p_variance_account_id
  , l_parent_transaction
  , FND_GLOBAL.user_id
  , SYSDATE
  , FND_GLOBAL.user_id
  , SYSDATE
  , FND_GLOBAL.login_id
  /* Bug 4969420 - Start  */
  , p_unit_price
  /* Bug 4969420 - End */
  /* Bug 11900144. Addition of po_line_id */
  , p_po_line_id
  , l_secondary_net_qty /* INVCONV */
  );

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '<< Exiting Record Consumption','INV_THIRD_PARTY_STOCK_PVT'
     , 9
     );
  END IF;

END Record_Consumption;


--========================================================================
-- PROCEDURE : Populate_Cost_Details         PRIVATE
-- PARAMETERS: p_mtl_transaction_id          Material transaction id
--             p_rct_transaction_id          Mtl Receipt transaction
--             p_transaction_source_type_id  Source Type Id
--             p_transaction_action_id       Transaction Action
--             p_organization_id             Organization id
--             p_inventory_item_id           Item id
--             p_po_price                    Price
-- COMMENT   : Procedure to insert into MTL_CST_TXN_COST_DETAILS table
--             Invoked by Process_Financial_Info
--========================================================================
PROCEDURE Populate_Cost_Details
( p_mtl_transaction_id         IN   NUMBER
, p_rct_transaction_id         IN   NUMBER
, p_transaction_source_type_id IN   NUMBER
, p_transaction_action_id      IN   NUMBER
, p_organization_id            IN   NUMBER
, p_inventory_item_id          IN   NUMBER
, p_po_price                   IN   NUMBER
)
IS
l_rowid                  VARCHAR2(2000);
l_debug                  NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

  -- Call to insert data in costing table.
  -- Do the insert only for implicit transactions. In case of explicit
  -- transactions, the TM will do the insert.

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> Entering Populate Cost Details','INV_THIRD_PARTY_STOCK_PVT'
     , 9
     );
  END IF;

  IF (p_transaction_action_id <> 6)
  THEN

    MTL_CST_TXN_COST_DETAILS_PKG.Insert_Row
    ( x_rowid              =>   l_rowid
    , x_transaction_id     =>   p_rct_transaction_id
    , x_organization_id    =>   p_organization_id
    , x_cost_element_id    =>   1  --material cost
    , x_level_type         =>   1  --current level
    , x_last_update_date   =>   SYSDATE
    , x_last_updated_by    =>   FND_GLOBAL.user_id
    , x_creation_date      =>   SYSDATE
    , x_created_by         =>   FND_GLOBAL.user_id
    , x_inventory_item_id  =>   p_inventory_item_id
    , x_transaction_cost   =>   p_po_price
    , x_new_average_cost   =>   NULL
    , x_percentage_change  =>   NULL
    , x_value_change       =>   NULL
    );

  END IF;

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '<< Exiting Populate Cost Details','INV_THIRD_PARTY_STOCK_PVT'
     , 9
     );
  END IF;

END Populate_Cost_Details;


--========================================================================
-- PROCEDURE : Get_Conversion_Rate       PRIVATE
-- PARAMETERS: p_set_of_books_id         SOB
--             p_from_currency           from currency
--             p_to_currency             to currency
--             p_conversion_date         conversion Date
--             p_conversion_type         conversion type
--             p_amount                  amount to be converted
--             p_user_rate               user rate
--             x_converted_amount        converted amount
--             x_conversion_rate         exchange rate used for conversion
-- COMMENT   : This procedure returns the exchange rate if the currency_code
--             in the blanket is different than the functional currency
--========================================================================
PROCEDURE Get_Conversion_Rate
( p_set_of_books_Id      IN NUMBER
, p_from_currency        IN VARCHAR2
, p_to_currency          IN VARCHAR2
, p_conversion_date      IN DATE
, p_conversion_type      IN VARCHAR2
, p_amount               IN NUMBER
, p_user_rate            IN NUMBER
, p_vendor_name          IN VARCHAR2
, p_vendor_site          IN VARCHAR2
, p_quantity             IN NUMBER
, x_converted_amount     OUT  NOCOPY NUMBER
, x_conversion_rate      OUT  NOCOPY NUMBER
)
IS
l_denominator NUMBER;
l_numerator   NUMBER;
l_debug       NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN
  -- Call to the GL API to get the rate

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> Entering Get Conversion Rate','INV_THIRD_PARTY_STOCK_PVT'
     , 9
     );
  END IF;

  GL_CURRENCY_API.convert_closest_amount
  ( x_from_currency    =>  p_from_currency
  , x_to_currency      =>  p_to_currency
  , x_conversion_date  =>  p_conversion_date
  , x_conversion_type  =>  p_conversion_type
  , x_amount           =>  p_amount
  , x_user_rate        =>  p_user_rate
  , x_max_roll_days    =>  -1
  , x_converted_amount =>  x_converted_amount
  , x_denominator      =>  l_denominator
  , x_numerator        =>  l_numerator
  , x_rate             =>  x_conversion_rate
  );

  SELECT
    DECODE(NVL(fc.minimum_accountable_unit,0), 0,
    (p_amount*p_quantity)* x_conversion_rate/p_quantity,
    (p_amount* p_quantity/fc.minimum_accountable_unit) *
          fc.minimum_accountable_unit*x_conversion_rate/p_quantity)
  INTO
    x_converted_amount
  FROM
    fnd_currencies fc
  WHERE fc.currency_code = p_from_currency;


  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '<< Exiting Get Conversion Rate','INV_THIRD_PARTY_STOCK_PVT'
     , 9
     );
  END IF;

EXCEPTION
  WHEN GL_CURRENCY_API.no_rate THEN
    FND_MESSAGE.Set_Name('INV', 'INV_CONS_SUP_GL_API_NO_RATE');
    FND_MESSAGE.Set_Token('SuppName',p_vendor_name);
    FND_MESSAGE.Set_Token('SiteCode',p_vendor_site);
    FND_MSG_PUB.ADD;
    g_error_code := 'INV_CONS_SUP_GL_API_NO_RATE' ;
    RAISE FND_API.G_EXC_ERROR;

END Get_Conversion_Rate;

--========================================================================
-- PROCEDURE  : Reset_OU_Context             PRIVATE
-- PARAMETERS:
-- COMMENT   : Reset the OU context to be the same as when TM invoked
--             Process_FInancial_Info
--========================================================================

PROCEDURE Reset_OU_Context
IS
l_debug              NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> Entering Reset OU ','INV_THIRD_PARTY_STOCK_PVT'
     , 9
     );
  END IF;

  FND_GLOBAL.apps_initialize(g_user_id,g_resp_id,g_pgm_appl_id);

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '<< Exiting Reset OU ','INV_THIRD_PARTY_STOCK_PVT'
     , 9
     );
  END IF;

END Reset_OU_Context;

--========================================================================
-- PROCEDURE  : Calculate_Tax         PRIVATE
-- PARAMETERS:
--             p_header_id            PO Header Id
--             p_line_id              PO Line Id
--             p_org_id               Operating Unit
--             p_item_id              Item
--             p_need_by_date         Consumption Date
--             p_ship_to_organization Inventory Organization
--             p_account_id           Accrual account
--             p_tax_code_id          Tax code id from PO Lines
--             p_transaction_quantity Transaction Qty
--             p_po_price             PO price
--             p_vendor_name          Vendor
--             p_vendor_site          Site
--             x_tax_rate             Tax rate
--             x_tax_recovery_rate    Recovery rate
--             x_recoverable_Tax      Recoverable tax
--             x_nonrecoverable_tax   Non recoverable tax
-- COMMENT   : Return the recoverable and nonrecoverable tax
--========================================================================

PROCEDURE Calculate_Tax
( p_header_id               IN NUMBER
, p_line_id                 IN NUMBER
, p_org_id                  IN NUMBER
, p_item_id                 IN NUMBER
, p_need_by_date            IN DATE
, p_ship_to_organization_id IN NUMBER
, p_account_id              IN NUMBER
, p_tax_code_id             IN OUT NOCOPY NUMBER
, p_transaction_quantity    IN NUMBER
, p_po_price                IN NUMBER
, p_vendor_name             IN VARCHAR2
, p_vendor_site             IN VARCHAR2
, p_uom_code                IN VARCHAR2
, p_transaction_id          IN NUMBER
, p_transaction_date        IN DATE
, p_global_flag             IN VARCHAR2
, x_tax_rate                OUT NOCOPY NUMBER
, x_tax_recovery_rate       OUT NOCOPY NUMBER
, x_recoverable_tax         OUT NOCOPY NUMBER
, x_nonrecoverable_tax      OUT NOCOPY NUMBER
)
IS
x_header_id            NUMBER;
x_line_id              NUMBER;
x_shipment_id          NUMBER ;
l_counter              NUMBER;
l_tax_code_id          NUMBER;
i                      NUMBER := 0;
l_ship_to_location_id  NUMBER;
l_debug                NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_precision            NUMBER;
l_return_status        VARCHAR2(1);
l_msg_count            NUMBER;
l_msg_data             VARCHAR2(2000);
l_vendor_id            NUMBER;
l_vendor_site_id       NUMBER;
l_application_id       NUMBER;
l_entity_code          VARCHAR2(25);
l_event_class_code     VARCHAR2(25);
l_event_type_code      VARCHAR2(25);
l_vendor_party_id      NUMBER;
l_vendor_site_party_id NUMBER;
/* bug 5081702  Start */
l_vendor_org_id        NUMBER; -- OU of vendor site
l_rate_type	           VARCHAR2(25);
l_legal_entity_id      NUMBER ;
l_set_of_books_id      NUMBER ;
l_ship_from_location_id NUMBER;
/* bug 5081702 End */

--Rajesh ETax
CURSOR tax_csr_type_nrec IS
SELECT
  SUM(NVL( rec_nrec_tax_amt,0))
FROM
   zx_rec_nrec_dist_gt
WHERE application_id = 201
AND   entity_code    = l_entity_code
AND   trx_id         = p_header_id
AND   event_class_code = l_event_class_code
AND   NVL(recoverable_flag,'N') = 'N' ;

CURSOR tax_csr_type_rec IS
SELECT
  SUM(NVL( rec_nrec_tax_amt,0))
FROM
   zx_rec_nrec_dist_gt
WHERE application_id = 201
AND   entity_code    = l_entity_code
AND   trx_id         = p_header_id
AND   event_class_code = l_event_class_code
AND   NVL(recoverable_flag,'N') = 'Y' ;

/* Bug 5530358 - Start */
/* Tax rate fetched from the tax tables */
CURSOR tax_csr_type_rate IS
SELECT
    rec_nrec_rate
  , tax_rate
FROM
   zx_rec_nrec_dist_gt
WHERE application_id = 201
AND   entity_code    = l_entity_code
AND   trx_id         = p_header_id
AND   event_class_code = l_event_class_code
AND   NVL(recoverable_flag,'N') = 'N' ;
/* Bug 5530358 - End */

BEGIN

IF (l_debug = 1)
    THEN
      INV_LOG_UTIL.trace
      ( 'Entering  Into calculate tax '
       , 9
       );
     END IF;

  l_ship_to_location_id :=
      INV_THIRD_PARTY_STOCK_UTIL.get_location(p_ship_to_organization_id);

  SELECT application_id
  INTO   l_application_id
  FROM   fnd_application
  WHERE  application_short_name = 'PO';

IF (l_debug = 1)
    THEN
      INV_LOG_UTIL.trace
      ( 'l_application_id => ' || l_application_id
       , 9
       );
     END IF;
IF (l_debug = 1)
    THEN
      INV_LOG_UTIL.trace
      ( 'l_ship_to_location_id => '|| l_ship_to_location_id
       , 9
       );
     END IF;

  -- The quantity that is being passed to the tax engine is always 1
  -- This is because the po price in MMT is stored as unit_price. So
  -- tax is calculated for the unit price. When creating the release,
  -- the total amount is calculated  by unit_price times quantity

   IF NVL(p_global_flag,'N') = 'Y'
   THEN
     l_entity_code := 'PURCHASE_ORDER';
     l_event_class_code := 'PO_PA';
     l_event_type_code := 'PO_PA_CREATED';
   ELSE
     l_entity_code := 'RELEASE' ;
     l_event_class_code := 'RELEASE';
     l_event_type_code := 'RELEASE_CREATED';

   END IF;

   SELECT vendor_id
        , vendor_site_id
   INTO  l_vendor_id
      ,  l_vendor_site_id
   FROM  po_headers_all
   WHERE po_header_id = p_header_id;

   SELECT pov.party_id
        , povs.party_site_id
   INTO  l_vendor_party_id
      ,  l_vendor_site_party_id
   FROM
     po_vendors pov
   , po_vendor_sites_all povs
  WHERE pov.vendor_id = povs.vendor_id
  AND   povs.vendor_site_id = l_vendor_site_id
  AND   povs.vendor_id      = l_vendor_id;

   /* bug 5081702  Start  - Insert OU of vendor site id */
    SELECT hzps.location_id
    INTO
        l_ship_from_location_id
    FROM
      hz_party_sites hzps
    WHERE
      hzps.party_site_id = l_vendor_site_party_id;

    l_vendor_org_id :=
      INV_THIRD_PARTY_STOCK_UTIL.get_org_id(l_vendor_site_id);
    l_legal_entity_id := XLE_UTILITIES_GRP.Get_DefaultLegalContext_OU
            (l_vendor_org_id);

    SELECT set_of_books_id
    INTO l_set_of_books_id
    FROM  hr_operating_units
    WHERE organization_id = l_vendor_org_id ;
  /* bug 5081702  End */



IF (l_debug = 1)
    THEN
      INV_LOG_UTIL.trace
      ( 'l_vendor_party_id => ' || l_vendor_party_id
       , 9
       );
      INV_LOG_UTIL.trace
      ( 'l_vendor_site_party_id => '|| l_vendor_site_party_id
       , 9
       );
       INV_LOG_UTIL.trace
      ( 'rajesh p_header_id => '|| p_header_id
       , 9
       );
       INV_LOG_UTIL.trace
      ( 'icx_session_id = > '|| FND_GLOBAL.session_id
       , 9
       );
       INV_LOG_UTIL.trace
      ( 'p_global_flag => '|| p_global_flag
       , 9
       );
       INV_LOG_UTIL.trace
      ( '*** Start inserting into GT tables '
       , 9
       );

       INV_LOG_UTIL.trace
      ( 'l_event_type_code => '|| l_event_type_code
       , 9
       );
       INV_LOG_UTIL.trace
      ( 'l_entity_code => '|| l_entity_code
       , 9
       );
       INV_LOG_UTIL.trace
      ( 'l_event_class_code => ' || l_event_class_code
       , 9
       );
       INV_LOG_UTIL.trace
      ( 'l_vendor_org_id => '|| l_vendor_org_id
       , 9
       );
       INV_LOG_UTIL.trace
      ( 'l_legal_entity_id => ' || l_legal_entity_id
       , 9
       );
       INV_LOG_UTIL.trace
      ( 'l_set_of_books_id => '|| l_set_of_books_id
       , 9
       );
     END IF;

    /* bug 5081702  Start*/
	/* get the rate type from the OU for global blanket*/
	IF p_global_flag = 'Y'
	THEN
	  SELECT
        default_rate_type
      INTO
        l_rate_type
      FROM
        po_system_parameters_all
      WHERE NVL(org_id,-99) = NVL(p_org_id,-99);
	END IF ;
    /* bug 5081702  End*/

      INV_LOG_UTIL.trace
      ( 'l_rate_type => '|| l_rate_type
       , 9
       );

--Rajesh start inserting GT

      INV_LOG_UTIL.trace
      ( 'Etax: clearing existing records from GT '
       , 9
       );
  /* 5084307 - Start */
  /* delete from ZX_TRX_HEADERS_GT if records already exist to
  to prevent duplicate records from being entered */
   /*bug#7120486 delete statement is moved at end after calling ebtax API */
  /* 5084307 - end */

    /*5488006 - Start */
	/* delete from ZX_TRANSACTION_LINES_GT and ZX_ITM_DISTRIBUTIONS_GT
	before inserting records to prevent duplicate insertion of records -
	this caused errors in tax calculation */
   /*bug#7120486 delete statement is moved at end after calling ebtax API */

    /*5488006 - End */


INSERT INTO ZX_TRX_HEADERS_GT
   ( internal_organization_id
   , application_id
   , entity_code
   , event_class_code
   , tax_event_type_code
   , event_type_code
   , trx_id
   , trx_date
   , trx_currency_code
   , currency_conversion_date
   , currency_conversion_rate
   , currency_conversion_type
   , PRECISION
   , legal_entity_id
   , quote_flag
   , ledger_id
   , rounding_ship_from_party_id
/*
   , rounding_ship_to_party_id
   , ship_third_pty_acct_id
   , ship_third_pty_acct_site_id
   , bill_third_pty_acct_id
   , bill_third_pty_acct_site_id
*/
   , provnl_tax_determination_date
   , document_sub_type
   , trx_number
   , icx_session_id
   )
SELECT
    /* bug 5081702  Start*/
	 --poh.org_id
	 NVL(l_vendor_org_id, poh.org_id)
   , l_application_id
   , l_entity_code
   , l_event_class_code
   , 'PURCHASE TRANSACTION'
   , l_event_type_code
   , poh.po_header_id
   , p_transaction_date
   , poh.currency_code
   --, poh.rate_date
   , NVL(p_transaction_date, poh.rate_date)
   , poh.rate
   --, poh.rate_type
   , NVL(l_rate_type, poh.rate_type)
   , fc.PRECISION
   --, ood.legal_entity
   , l_legal_entity_id
   , 'Y'
   --, ood.set_of_books_id
   , l_set_of_books_id
   , l_vendor_party_id
/*
   , poh.vendor_id
   , poh.vendor_id
   , poh.vendor_site_id
   , poh.vendor_id
   , poh.vendor_site_id
*/
   , p_transaction_date
   , poh.type_lookup_code
   , poh.segment1
   , FND_GLOBAL.session_id
  FROM
    po_headers_all poh
   , fnd_currencies fc
   WHERE poh.currency_code    = fc.currency_code
   AND   poh.po_header_id     = p_header_id;


   /*bug 5081702  End */

   INSERT INTO ZX_TRANSACTION_LINES_GT
   ( application_id
   , entity_code
   , event_class_code
   , trx_level_type
   , line_level_action
   , line_amt
   , trx_line_gl_date
   , line_amt_includes_tax_flag
   , trx_line_quantity
   , uom_code
   --, ship_to_party_id
   , ship_from_party_id
   , ship_from_party_site_id
   , unit_price
   , trx_line_type
   , trx_line_date
   , product_id
   , ship_to_location_id
   , trx_id
   , trx_line_id
   , line_class
   , product_org_id
 -- , bill_to_party_site_id
   , BILL_TO_LOCATION_ID
   , ship_from_location_id
   )
   SELECT
     l_application_id
   , l_entity_code
   , l_event_class_code
   , 'SHIPMENT'
   , 'CREATE'
   , p_po_price
   , p_transaction_date
   , 'N'
   , 1
   , p_uom_code
   --, p_ship_to_organization_id
   , l_vendor_party_id
   , l_vendor_site_party_id
   , p_po_price
   , 'ITEM'
   , p_transaction_date
   , p_item_id
   , l_ship_to_location_id
   , po_header_id
  , p_transaction_id
   , 'INVOICE'
   , p_ship_to_organization_id
  -- , l_vendor_site_id
    , bill_to_location_id
    , l_ship_from_location_id
   FROM  po_headers_all
   WHERE po_header_id = p_header_id;

  INSERT INTO ZX_ITM_DISTRIBUTIONS_GT
   ( application_id
   , entity_code
   , event_class_code
--   , event_type_code
   , trx_id
   , trx_level_type
   , dist_level_action
   , trx_line_dist_date
   , trx_line_dist_amt
   , trx_line_dist_qty
   , trx_line_quantity
   , trx_line_id
   , trx_line_dist_id
   )
   VALUES
   ( l_application_id
   , l_entity_code
   , l_event_class_code
--   , l_event_type_code
   ,  p_header_id
   , 'SHIPMENT'
   , 'CREATE'
   , p_transaction_date
   , p_po_price
   , 1
   , 1
   , p_transaction_id
   , p_transaction_id
   );


-- End Rajesh
    IF (l_debug = 1)
    THEN
      INV_LOG_UTIL.trace
      ( 'Inserted into Tax Global temp tables','INV_THIRD_PARTY_STOCK_PVT'
       , 9
       );
     INV_LOG_UTIL.trace
      ( 'Calling INV_AP_TAX_ENGINE_MDTR.Calculate_Tax'
       , 9
       );

     END IF;


   INV_AP_TAX_ENGINE_MDTR.Calculate_Tax
   ( x_return_status => l_return_status
   , x_msg_count     => l_msg_count
   , x_msg_data      => l_msg_data
   );

    IF (l_debug = 1)
    THEN
      INV_LOG_UTIL.trace
      ( ' returned  '||l_return_status,'INV_THIRD_PARTY_STOCK_PVT'
       , 9
       );
      INV_LOG_UTIL.trace
      ( 'l_msg_count => '|| l_msg_count
       , 9
       );
      INV_LOG_UTIL.trace
      ( 'l_msg_data => '|| l_msg_data
       , 9
       );


     END IF;

   IF l_return_status = FND_API.G_RET_STS_SUCCESS
   THEN

     OPEN tax_csr_type_nrec;
     LOOP
     FETCH tax_csr_type_nrec INTO
       x_nonrecoverable_tax;

     IF tax_csr_type_nrec%NOTFOUND
     THEN
       EXIT;
     END IF;
    END LOOP;
    CLOSE tax_csr_type_nrec;

    -- Recoverable tax
     OPEN tax_csr_type_rec;
     LOOP
     FETCH tax_csr_type_rec INTO
       x_recoverable_tax;

     IF tax_csr_type_rec%NOTFOUND
     THEN
       EXIT;
     END IF;
    END LOOP;
    CLOSE tax_csr_type_rec;

   /* Bug 5530358 - Start */
   /* tax rate was stored in  tax_recovery_rate column.
   The cursor stores the tax values in the correct columns */
   OPEN tax_csr_type_rate;
     LOOP
     FETCH tax_csr_type_rate
	 INTO
       x_tax_recovery_rate
	 , x_tax_rate;
   /* Bug 5530358 - End */

     IF tax_csr_type_rate%NOTFOUND
     THEN
       EXIT;
     END IF;
    END LOOP;
    CLOSE tax_csr_type_rate;

    -- rajesh after loop
    IF (l_debug = 1)
    THEN
      INV_LOG_UTIL.trace
      ( 'x_nonrecoverable_tax is '||x_nonrecoverable_tax,'INV_THIRD_PARTY_STOCK_PVT'
       , 9
       );
      INV_LOG_UTIL.trace
      ( 'x_recoverable_tax is '||x_recoverable_tax,'INV_THIRD_PARTY_STOCK_PVT'
       , 9
       );
      INV_LOG_UTIL.trace
      ( 'x_tax_rate is '||x_tax_rate,'INV_THIRD_PARTY_STOCK_PVT'
       , 9
       );
      INV_LOG_UTIL.trace
      ( 'Return status is '||l_return_status,'INV_THIRD_PARTY_STOCK_PVT'
       , 9
       );
     END IF;

/*Fixed for bug#7120486
  Based on ebTax team input calling program should clear GT tables when
  processing line by line. GT tables are cleared automatically when
  rollback or commit is issues but when more than one lines are processed in
  one transaction then the GT tables still have previous record hence it tries to
  calculate tax for previous line again which result in unique constraint violation
  in ebTax table.
  we have to clear following tables :
  ZX_TRX_HEADERS_GT
  ZX_TRANSACTION_LINES_GT
  ZX_ITM_DISTRIBUTIONS_GT
*/

     DELETE FROM ZX_TRX_HEADERS_GT
     WHERE APPLICATION_ID = l_application_id
     AND ENTITY_CODE = l_entity_code
     AND EVENT_CLASS_CODE = l_event_class_code
     AND TRX_ID = p_header_id;

         DELETE FROM ZX_TRANSACTION_LINES_GT
     WHERE APPLICATION_ID = l_application_id
     AND ENTITY_CODE = l_entity_code
     AND EVENT_CLASS_CODE = l_event_class_code
     AND TRX_ID = p_header_id;

     DELETE FROM ZX_ITM_DISTRIBUTIONS_GT
     WHERE APPLICATION_ID = l_application_id
     AND ENTITY_CODE = l_entity_code
     AND EVENT_CLASS_CODE = l_event_class_code
     AND TRX_ID = p_header_id;

/*Fix#7120486 end */

   /*5488006 - Start */
   DELETE FROM zx_rec_nrec_dist_gt
    WHERE application_id = 201
     AND   entity_code    = l_entity_code
     AND   trx_id         = p_header_id
     AND   event_class_code = l_event_class_code ;
  /*5488006 - End */


   ELSE
    IF (l_debug = 1)
    THEN
      INV_LOG_UTIL.trace
      ( 'eBtax returned failure','INV_THIRD_PARTY_STOCK_PVT'
       , 9
       );
     END IF;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
  IF (l_debug = 1)
    THEN
      INV_LOG_UTIL.trace
      ( 'NO_DATA_FOUND exception','INV Calculate_tax'
       , 9
       );
     END IF;

    IF tax_csr_type_rec%ISOPEN
    THEN
      CLOSE tax_csr_type_rec;
    END IF;
    IF tax_csr_type_nrec%ISOPEN
    THEN
      CLOSE tax_csr_type_nrec;
    END IF;
    IF tax_csr_type_rate%ISOPEN
    THEN
      CLOSE tax_csr_type_rate;
    END IF;

    FND_MESSAGE.Set_Name('INV', 'INV_CONS_SUP_NO_TAX_SETUP');
    FND_MESSAGE.Set_Token('SuppName',p_vendor_name);
    FND_MESSAGE.Set_Token('SiteCode',p_vendor_site);
    FND_MSG_PUB.ADD;
    g_error_code := 'INV_CONS_SUP_NO_TAX_SETUP' ;
    RAISE FND_API.G_EXC_ERROR;

  WHEN OTHERS THEN
      INV_LOG_UTIL.trace
      ( 'SQLERRM '||SQLERRM|| ' SQLCODE '||SQLCODE ,'INV_THIRD_PARTY_STOCK_PVT'
       , 9
       );

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Calculate_Tax;

--========================================================================
-- FUNCTION   : Get_Consumed_Amt PRIVATE
-- PARAMETERS : p_header_id      PO Header
-- COMMENT    : This function sums up all the consumption amounts
--              in MCT that are not processed
--========================================================================
FUNCTION Get_Consumed_Amt
( p_header_id     IN NUMBER
) RETURN NUMBER
IS

--=================
-- VARIABLES
--=================

l_item_id                NUMBER;
l_uom_code               VARCHAR2(25);
l_primary_uom            VARCHAR2(25);
l_organization_id        NUMBER;
l_purchasing_uom         VARCHAR2(25);
l_conv_qty               NUMBER;
l_total_cons_qty         NUMBER;
l_primary_qty            NUMBER;
l_unit_price             NUMBER;
l_debug                  NUMBER ;

--=================
-- CURSORS
--=================

-- Added hint for improving performance in bug 7417022
CURSOR cons_csr_type IS
  SELECT /*+ leading(mct) use_nl(mct mmt) index(mmt MTL_MATERIAL_TRANSACTIONS_U1) */
    mmt.inventory_item_id
  , mmt.organization_id
  /* Bug 5395579 - Start */
  /* mct.blanket_price is used for getting the consumed amt.
  Using mmt.transaction_cost will multiply the consumed amt by the function
  UOM if the pur UOM and function UOM are different*/
  --, mmt.transaction_cost
  , mct.blanket_price
  , SUM(mct.net_qty)
  FROM
    mtl_material_transactions    mmt
  , mtl_consumption_transactions mct
  WHERE mmt.transaction_id = mct.transaction_id
    AND mct.consumption_processed_flag IN ('N','E')
    AND mmt.transaction_source_type_id = 1
    AND mmt.transaction_action_id = 6
    AND mmt.transaction_source_id = p_header_id
  GROUP BY mmt.inventory_item_id,mmt.organization_id,mct.blanket_price;--mmt.transaction_cost;

  /* Bug 5395579 - End */

CURSOR uom_csr_type IS
  SELECT
    pol.unit_meas_lookup_code
  FROM
    po_lines_all pol
  WHERE pol.po_header_id = p_header_id
    AND pol.item_id    = l_item_id
    AND ROWNUM         = 1;


BEGIN

  l_debug             := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> Entering Get Consumed Amt','INV_THIRD_PARTY_STOCK_PVT'
     , 9
     );
  END IF;

  -- Compute the total amount of consumption txns with processed
  -- flag of 'N'. Since the get_total API from PO only
  -- takes into account the released amounts , we need to compute
  -- the transactions that are not yet released, but waiting to be
  -- run to create the consumption advice.

  OPEN cons_csr_type;
  LOOP
  FETCH cons_csr_type
  INTO
    l_item_id
  , l_organization_id
  , l_unit_price
  , l_primary_qty;

  IF cons_csr_type%NOTFOUND
  THEN
    EXIT;
  END IF;

  OPEN uom_csr_type;
  LOOP
  FETCH uom_csr_type
  INTO
    l_purchasing_uom;

  IF uom_csr_type%NOTFOUND
  THEN
    EXIT;
  END IF;

  l_primary_uom := INV_THIRD_PARTY_STOCK_UTIL.Get_Primary_UOM
                   ( p_inventory_item_id=> l_item_id
                   , p_organization_id  => l_organization_id
                   );

  IF l_primary_uom <> NVL(l_purchasing_uom,l_primary_uom)
  THEN
    -- Convert the qty to purchasing UOM, the UOM's are different

    IF (l_debug = 1)
    THEN
      INV_LOG_UTIL.trace
      ( 'l_primary_uom => '|| l_primary_uom, NULL
       , 9
       );
     INV_LOG_UTIL.trace
      ( 'l_purchasing_uom => '|| l_purchasing_uom, NULL
       , 9
       );


      INV_LOG_UTIL.trace
      ( '>> UOM  is different','INV_THIRD_PARTY_STOCK_PVT'
       , 9
       );
    END IF;

    l_conv_qty := INV_CONVERT.inv_um_convert
                  ( item_id             => l_item_id
                  , PRECISION           => 5
                  , from_quantity       => l_primary_qty
                  , from_unit           => NULL
                  , to_unit             => NULL
                  , from_name           => l_primary_uom
                  , to_name             => l_purchasing_uom
                  );

    IF l_conv_qty IS NULL OR l_conv_qty < 0
    THEN
      l_conv_qty := 0;
    END IF;
  ELSE
  -- UOM is the same;no conversion required
    l_conv_qty := l_primary_qty;
  END IF;

  END LOOP;
  CLOSE uom_csr_type;

    l_total_cons_qty := NVL(l_conv_qty,0)*NVL(l_unit_price,0)+
                        NVL(l_total_cons_qty,0);
    IF (l_debug = 1)
    THEN
      INV_LOG_UTIL.trace
      ( '>>Total qty from MCT:'||l_total_cons_qty,'INV_THIRD_PARTY_STOCK_PVT'
       , 9
       );
    END IF;
  END LOOP;
  CLOSE cons_csr_type;

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '<< Exiting Get Consumed Amt','INV_THIRD_PARTY_STOCK_PVT'
     , 9
     );
  END IF;

  RETURN l_total_cons_qty;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    RETURN 0;

  WHEN OTHERS THEN
    RETURN 0;

END Get_Consumed_Amt;

--========================================================================
-- PROCEDURE  : Get_Total_Blanket_Amt       PRIVATE
-- PARAMETERS : p_po_header_id    PO Header
--            : p_exchange_rate   Exch. rate if blanket is in diff. curreny
--              than the functional currency.
--            : p_ccode_flag      Flag to indicate it is foreign curr. blanket
--            : x_released_amt    Released amount against the blanket
--            : x_consumed_amt    Consumed amount against the blanket
--            : x_amount_limit    Amount limit for the blanket
-- COMMENT    : This procedure  returns the released amt for the blanket
--              the consumption amounts in MCT that are not processed and
--              the blanket total amount.
--========================================================================
PROCEDURE Get_Total_Blanket_Amt
( p_po_header_id  IN  NUMBER
, p_object        IN  VARCHAR2
, p_exchange_rate IN  NUMBER
, p_ccode_flag    IN  VARCHAR2
, x_released_amt  OUT NOCOPY NUMBER
, x_consumed_amt  OUT NOCOPY NUMBER
, x_amount_limit  OUT NOCOPY NUMBER
)
IS
l_total_amt   NUMBER;
l_debug       NUMBER ;
BEGIN

  l_debug      := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> Entering Get Total Blanket Amt','INV_THIRD_PARTY_STOCK_PVT'
     , 9
     );
  END IF;

  SELECT
    NVL(blanket_total_amount,0)
  INTO
    l_total_amt
  FROM
    po_headers_all
  WHERE  po_header_id = p_po_header_id;

  IF l_total_amt > 0
  THEN

   -- Get the released amounts for the blanket

    x_released_amt := INV_PO_THIRD_PARTY_STOCK_MDTR.get_total
                      ( p_object_type => NVL(p_object,'B')
                      , p_header_id   => p_po_header_id
                      );

    IF (l_debug = 1)
    THEN
      INV_LOG_UTIL.trace
      ( '>> Released Amt:'||x_released_amt,'INV_THIRD_PARTY_STOCK_PVT'
       , 9
       );
    END IF;

   -- Get the consumed amounts for the blanket from MCT
    x_consumed_amt := INV_THIRD_PARTY_STOCK_PVT.get_consumed_amt
                      ( p_header_id     => p_po_header_id
		      );

    IF (l_debug = 1)
    THEN
      INV_LOG_UTIL.trace
      ( '>> COnsumed Amt:'||x_consumed_amt,'INV_THIRD_PARTY_STOCK_PVT'
       , 9
       );
    END IF;

    x_amount_limit := l_total_amt;

  ELSE
    IF (l_debug = 1)
    THEN
      INV_LOG_UTIL.trace
      ( '>> Blanket does not have amount limit','INV_THIRD_PARTY_STOCK_PVT'
       , 9
       );
    END IF;

    x_released_amt := 0;
    x_consumed_amt := 0;
    x_amount_limit := 0;

  END IF;

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '<< Exiting Get Total BLanket Amt','INV_THIRD_PARTY_STOCK_PVT'
     , 9
     );
  END IF;

END Get_Total_Blanket_Amt;


--========================================================================
-- PROCEDURE : Get_PO_Info                   PRIVATE
-- PARAMETERS: p_mtl_transaction_id          Material transaction id
--             p_transaction_source_type_id  Txn  source Type
--             p_inventory_item_id           item
--             p_owning_organization_id      owning organization
--             p_organization_id             Inv. organization
--             p_transaction_quantity        Transaction Quantity
--             p_transaction_source_id       Txn source
--             p_account_id                  Accrual account
--             p_item_revision               Revision
--             x_po_price                    PO price
--             x_tax_code_id                 Tax code
--             x_tax_rate                    Tax Rate
--             x_tax_recovery_rate           Recovery Rate
--             x_recoverable_tax             Recoverable Tax
--             x_non_recoverable_tax         Non recoverable Tax
--             x_rate                        Exchange Rate
--             x_rate_type                   Exchange Rate Type
--   		   x_unit_price					 Unit Price  -- Bug 4969420
-- COMMENT   : This procedure invokes the PO price break procedure to
--             calculate the price for consigned transactions.It also
--             returns the PO header id for the sourced blanket
--========================================================================
PROCEDURE Get_PO_Info
( p_mtl_transaction_id         IN  NUMBER
, p_transaction_source_type_id IN  NUMBER
, p_transaction_action_id      IN  NUMBER
, p_inventory_item_id          IN  NUMBER
, p_owning_organization_id     IN  NUMBER
, p_xfr_owning_organization_id IN  NUMBER
, p_organization_id            IN  NUMBER
, p_transaction_quantity       IN  NUMBER
, p_transaction_source_id      IN  OUT NOCOPY NUMBER
, p_transaction_date           IN  DATE
, p_account_id                 IN  NUMBER
, p_item_revision              VARCHAR2 DEFAULT NULL
, x_po_price                   OUT NOCOPY NUMBER
, x_tax_code_id                OUT NOCOPY NUMBER
, x_tax_rate                   OUT NOCOPY NUMBER
, x_tax_recovery_rate          OUT NOCOPY NUMBER
, x_recoverable_tax            OUT NOCOPY NUMBER
, x_non_recoverable_tax        OUT NOCOPY NUMBER
, x_rate                       OUT NOCOPY NUMBER
, x_rate_type                  OUT NOCOPY VARCHAR2
, x_rate_date                  OUT NOCOPY DATE
, x_currency_code              OUT NOCOPY VARCHAR2
  /* bug 4969420 Start */
  -- The unit price non-inclusive of recoverable,non-recoverable taxes and the conversions
, x_unit_price                 OUT NOCOPY NUMBER
  /* bug 4969420 End */
  -- Bug 11900144. Getting po_line_id
, x_po_line_id                OUT NOCOPY NUMBER
)
IS
l_po_price               NUMBER;
l_cum_flag               BOOLEAN;
l_line_location_id       NUMBER;
l_price_break_code       VARCHAR2(25);
l_currency_code          VARCHAR2(15);
l_item_rev               VARCHAR2(3);
l_vendor_site_id         NUMBER;
l_document_header_id     NUMBER;
l_document_type_code     VARCHAR2(25);
l_document_line_num      NUMBER;
l_vendor_contact_id      NUMBER;
l_vendor_product_num     VARCHAR2(25);
l_purchasing_uom         VARCHAR2(25);
l_primary_uom            VARCHAR2(25);
l_from_uom_code          VARCHAR2(25);
l_to_uom_code            VARCHAR2(25);
l_multi_org              VARCHAR2(1);
l_transaction_source_id  NUMBER;
l_document_line_id       NUMBER;
l_header_id              NUMBER;
l_sob_id                 NUMBER;
l_conv_price             NUMBER;
l_func_currency          VARCHAR2(25);
l_conv_type              VARCHAR2(25);
l_user_rate              NUMBER;
l_rate                   NUMBER;
l_precision              NUMBER;
l_tax_code_id            NUMBER;
l_recoverable_tax        NUMBER;
l_nonrecoverable_tax     NUMBER;
l_org_id                 NUMBER;
l_tax_rate               NUMBER;
l_rate_date              DATE;
l_conv_qty               NUMBER;
l_uom_rate               NUMBER;
l_primary_quantity       NUMBER;
l_ship_to_location_id    NUMBER;
l_released_amt           NUMBER;
l_consumed_amt           NUMBER;
l_ccode_flag             VARCHAR2(1);
l_bkt_amt_limit          NUMBER;
l_purch_uom_price        NUMBER;
l_global_flag            VARCHAR2(1);
l_object                 VARCHAR2(1);
l_debug                  NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_vendor_name            VARCHAR2(240);
l_vendor_site            VARCHAR2(15);
/* price break api change uptake - Bug 5076263 - Start*/
l_api_version 			 NUMBER := 1.0;
l_base_unit_price		 NUMBER;
l_price_break_id  		 NUMBER;
l_return_status 		 VARCHAR2(1);
l_vendor_id				 NUMBER;
l_category_id			 NUMBER;
l_line_type_id			 NUMBER;
l_supplier_item_num		 VARCHAR2(25);
/* price break api change uptake - Bug 5076263 - End */
l_calculate_tax_global           VARCHAR2(1) ;
BEGIN

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> Entering Get PO Info ','INV_THIRD_PARTY_STOCK_PVT'
     , 9
     );
  END IF;
  g_po_header_id := NULL;

  IF (p_transaction_source_type_id=13) AND (p_transaction_action_id = 6)
  THEN
    -- For  correction transaction
    -- Get the price from the parent transaction

    SELECT
      transaction_cost
    , transaction_source_id
    INTO
      l_po_price
    , l_header_id
    FROM
      MTL_MATERIAL_TRANSACTIONS
    WHERE  transaction_id = p_transaction_source_id;

  ELSE

    -- For a Transfer to regular stock, the blanket line_id is stored in
    -- txn source id column. We use this info to get the po_header_id,
    -- price etc and when we return PO info to TM, we update
    -- transaction_source_id with the po header id

    l_vendor_site_id := p_owning_organization_id;
    l_org_id         := INV_THIRD_PARTY_STOCK_UTIL.Get_Org_id
                        ( l_vendor_site_id
                        );

    INV_THIRD_PARTY_STOCK_UTIL.Get_Vendor_Info
    ( p_vendor_site_id   => l_vendor_site_id
    , x_vendor_name      => l_vendor_name
    , x_vendor_site_code => l_vendor_site
    );


    l_document_line_id := p_transaction_source_id;

    -- This is possibly a call from TM for an implicit transaction
    -- Hence , retrieve the blanket info

    IF (p_transaction_source_id IS NULL) OR
       (p_transaction_action_id<>6)
    THEN
      IF (l_debug = 1)
      THEN
        INV_LOG_UTIL.trace('Implicit Txn ','INV_THIRD_PARTY_STOCK_PVT',9);
      END IF;

      INV_PO_THIRD_PARTY_STOCK_MDTR.Get_Blanket_Number
      ( p_inventory_item_id  => p_inventory_item_id
      , p_item_revision      => p_item_revision
      , p_vendor_site_id     => l_vendor_site_id
      , p_organization_id    => p_organization_id
      , p_transaction_date   => TRUNC(p_transaction_date)
      , x_document_header_id => l_header_id
      , x_document_line_id   => l_document_line_id
      , x_global_flag        => l_global_flag
      );

      IF (l_debug = 1)
      THEN
        INV_LOG_UTIL.trace
        ( 'Blanket Header and line are:'||l_header_id||' '||l_document_line_id
        , 'INV_THIRD_PARTY_STOCK_PVT'
        , 9
        );

        INV_LOG_UTIL.trace
        ( 'Global flag is l_global_flag: '||l_global_flag
        , 'INV_THIRD_PARTY_STOCK_PVT'
        , 9
        );
      END IF;

      -- The following assignment is used for the Consigned error rpt
      g_po_header_id := l_header_id ;

      -- There is no valid blanket aggrement, hence raise error

      IF l_header_id IS NULL
      THEN
        IF NVL(l_global_flag,'N') = 'Y'
        THEN
          FND_MESSAGE.Set_Name('INV','INV_CONS_SUP_MANUAL_NUM_CODE');
          FND_MESSAGE.Set_Token('SuppName',l_vendor_name);
          FND_MESSAGE.Set_Token('SiteCode',l_vendor_site);
          FND_MSG_PUB.ADD;
          g_error_code := 'INV_CONS_SUP_MANUAL_NUM_CODE' ;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          FND_MESSAGE.Set_Name('INV', 'INV_CONS_SUP_NO_BPO_EXISTS');
          FND_MESSAGE.Set_Token('SuppName',l_vendor_name);
          FND_MESSAGE.Set_Token('SiteCode',l_vendor_site);
          FND_MSG_PUB.ADD;
          g_error_code := 'INV_CONS_SUP_NO_BPO_EXISTS' ;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

    END IF;

    -- Check to see if there are cumulative discounts defined
    -- at the PO line level

    SELECT
      price_break_lookup_code
    , po_line_id
    , po_header_id
    , tax_code_id
    , unit_meas_lookup_code
	/* Bug 5076263 - category_id to be passed to get_break_price API - Start*/
	, category_id
	, line_type_id
	, vendor_product_num
	/* Bug 5076263 - category_id to be passed to get_break_price API  - End*/
    INTO
      l_price_break_code
    , l_document_line_id
    , l_header_id
    , l_tax_code_id
    , l_purchasing_uom
	/* Bug 5076263 - category_id, line_type_id to be passed to get_break_price API - Start*/
	, l_category_id
	, l_line_type_id
	, l_supplier_item_num
	/* Bug 5076263 - category_id, line_type_id to be passed to get_break_price API - End*/
    FROM
      po_lines_all
    WHERE  po_line_id  = l_document_line_id;

      --Bug 11900144. saving po_line_id
      x_po_line_id := l_document_line_id;

	/* Bug 5076263 - currency_code, vendor_id to be passed to get_break_price API - Start*/
     SELECT
      currency_code
	, vendor_id
    INTO
      l_currency_code
	, l_vendor_id
    FROM
      po_headers_all
    WHERE po_header_id = l_header_id;
	/* Bug 5076263 - currency_code, vendor_id to be passed to get_break_price API - End*/

	-- Get the primary UOM for the item and check if it same as
    -- Purchasing UOM; if not, convert the qty in Purchasing UOM
    -- to pass the qty to the Price Break

    l_primary_uom := INV_THIRD_PARTY_STOCK_UTIL.Get_Primary_UOM
                     ( p_inventory_item_id=> p_inventory_item_id
                     , p_organization_id  => p_organization_id
                     );

    l_primary_quantity := p_transaction_quantity;

    IF l_primary_uom <> NVL(l_purchasing_uom,l_primary_uom)
    THEN
      IF (l_debug = 1)
      THEN
        INV_LOG_UTIL.trace
        ( 'l_primary_uom => '|| l_primary_uom, NULL
         , 9
         );
        INV_LOG_UTIL.trace
         ( 'l_purchasing_uom => '|| l_purchasing_uom, NULL
         , 9
          );
       END IF;

     g_primary_uom    := l_primary_uom;
     g_purchasing_uom := l_purchasing_uom;


      -- Convert the qty to purchasing UOM
      l_conv_qty := INV_CONVERT.inv_um_convert
                    ( item_id             => p_inventory_item_id
                    , PRECISION           => 5
                    , from_quantity       => l_primary_quantity
                    , from_unit           => NULL
                    , to_unit             => NULL
                    , from_name           => l_primary_uom
                    , to_name             => l_purchasing_uom
                    );

      -- If there is no conversion, error out

      IF l_conv_qty IS NULL OR l_conv_qty < 0
      THEN
        FND_MESSAGE.Set_Name('INV', 'INV_CONS_SUP_NO_UOM_CONV');
        FND_MESSAGE.Set_Token('SuppName',l_vendor_name);
        FND_MESSAGE.Set_Token('SiteCode',l_vendor_site);
        FND_MSG_PUB.ADD;
        g_error_code := 'INV_CONS_SUP_NO_UOM_CONV' ;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_from_uom_code := INV_THIRD_PARTY_STOCK_UTIL.Get_UOM_Code
                         ( p_unit_of_measure  => l_primary_uom
                         , p_vendor_name      => l_vendor_name
                         , p_vendor_site_code => l_vendor_site
                         );

      l_to_uom_code   := INV_THIRD_PARTY_STOCK_UTIL.Get_UOM_Code
                         ( p_unit_of_measure  => l_purchasing_uom
                         , p_vendor_name      => l_vendor_name
                         , p_vendor_site_code => l_vendor_site
                         );

      INV_CONVERT.inv_um_conversion
      ( item_id             => p_inventory_item_id
      , from_unit           => l_from_uom_code
      , to_unit             => l_to_uom_code
      , uom_rate            => l_uom_rate
      );

      -- If there is no conversion rate, error out

      IF l_uom_rate IS NULL OR l_uom_rate < 0
      THEN
        FND_MESSAGE.Set_Name('INV', 'INV_CONS_SUP_NO_UOM_CONV');
        FND_MESSAGE.Set_Token('SuppName',l_vendor_name);
        FND_MESSAGE.Set_Token('SiteCode',l_vendor_site);
        FND_MSG_PUB.ADD;
        g_error_code := 'INV_CONS_SUP_NO_UOM_CONV' ;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    ELSE -- Both UOM are same;no conversion is required

      l_to_uom_code   := INV_THIRD_PARTY_STOCK_UTIL.Get_UOM_Code
                         ( p_unit_of_measure  => l_purchasing_uom
                         , p_vendor_name      => l_vendor_name
                         , p_vendor_site_code => l_vendor_site
                         );

      l_conv_qty := l_primary_quantity;
      l_uom_rate := 1;

    END IF;

    IF l_price_break_code = 'CUMULATIVE'
    THEN
      l_cum_flag := TRUE;
    ELSE
      l_cum_flag := FALSE;
    END IF;

    l_ship_to_location_id :=
      INV_THIRD_PARTY_STOCK_UTIL.get_location(p_organization_id);

    -- If the transaction type is 'Transfer to regular stock',
    -- call the price break API to calculate the PO price.
  /* get break price API change updtake - Bug 5076263 */
  /* get_break_price API has changed */
  /*    INV_PO_THIRD_PARTY_STOCK_MDTR.get_break_price
    ( p_order_quantity    => l_conv_qty
    , p_ship_to_org       => p_organization_id
    , p_ship_to_loc       => NVL(l_ship_to_location_id,p_organization_id)
    , p_po_line_id        => l_document_line_id
    , p_cum_flag          => l_cum_flag
    , p_need_by_date      => p_transaction_date
    , p_line_location_id  => l_line_location_id
    , x_po_price          => l_po_price
    );
  */
    IF (l_debug = 1)
    THEN
      INV_LOG_UTIL.trace
      ( 'Before Price break the Price is '||l_po_price
      , 'INV_THIRD_PARTY_STOCK_PVT'
      , 9
      );
    END IF;

	INV_PO_THIRD_PARTY_STOCK_MDTR.get_break_price
    ( p_api_version		  => l_api_version
	, p_order_quantity    => l_conv_qty
    , p_ship_to_org       => p_organization_id
    , p_ship_to_loc       => NVL(l_ship_to_location_id,p_organization_id)
    , p_po_line_id        => l_document_line_id
    , p_cum_flag          => l_cum_flag
    , p_need_by_date      => p_transaction_date
    , p_line_location_id  => l_line_location_id
    , p_contract_id       => NULL
	, p_org_id 			  => l_org_id
	, p_supplier_id		  => l_vendor_id
	, p_supplier_site_id  => l_vendor_site_id
	, p_creation_date	  => p_transaction_date
	, p_order_header_id	  => NULL
	, p_order_line_id	  => NULL
	, p_line_type_id	  => l_line_type_id
	, p_item_revision	  => l_item_rev
	, p_item_id			  => p_inventory_item_id
	, p_category_id		  => l_category_id
	, p_supplier_item_num => l_supplier_item_num
	, p_uom				  => l_purchasing_uom
	, p_in_price		  => NULL
	, p_currency_code 	  => l_currency_code
    , x_base_unit_price   => l_base_unit_price
    , x_price_break_id    => l_price_break_id
    , x_price             => l_po_price
    , x_return_status     => l_return_status
    );
  /* get break price API change updtake - Bug 5076263  - End */

    IF (l_debug = 1)
    THEN
      INV_LOG_UTIL.trace
      ( 'After Price break the Price is '||l_po_price
      , 'INV_THIRD_PARTY_STOCK_PVT'
      , 9
      );
    END IF;

	/* Bug 4969420  Start*/
	/* Storing Unit price  */
	x_unit_price := l_po_price ;
	/* Bug 4969420 - End*/

   IF l_po_price IS NULL
    THEN
      FND_MESSAGE.Set_Name('INV', 'INV_CONS_SUP_NO_BPO_EXISTS');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Call the tax API to calculate nonrecoverable tax

    x_tax_code_id := l_tax_code_id;

    l_calculate_tax_global := NULL ;
    IF INV_PO_THIRD_PARTY_STOCK_MDTR.is_global(l_header_id)
      THEN
         l_calculate_tax_global := 'Y' ;
      ELSE
           l_calculate_tax_global := 'N' ;
    END IF;

    INV_THIRD_PARTY_STOCK_PVT.Calculate_Tax
    ( p_header_id               => l_header_id
    , p_line_id                 => l_document_line_id
    , p_org_id                  => l_org_id
    , p_item_id                 => p_inventory_item_id
    , p_need_by_date            => p_transaction_date
    , p_ship_to_organization_id => p_organization_id
    , p_account_id              => p_account_id
    , p_tax_code_id             => x_tax_code_id
    , p_transaction_quantity    => l_conv_qty
    , p_po_price                => l_po_price
    , p_vendor_name             => l_vendor_name
    , p_vendor_site             => l_vendor_site
    , p_transaction_id          => p_mtl_transaction_id
    , p_uom_code                => l_to_uom_code
    , p_transaction_date        => p_transaction_date
    , p_global_flag             => l_calculate_tax_global
    , x_tax_rate                => x_tax_rate
    , x_tax_recovery_rate       => x_tax_recovery_rate
    , x_recoverable_tax         => x_recoverable_tax
    , x_nonrecoverable_tax      => x_non_recoverable_Tax
    );

 --  x_recoverable_tax := 0;
 --  x_non_recoverable_tax :=0;

    IF (l_debug = 1)
    THEN
      INV_LOG_UTIL.trace
      ( 'x_non_recoverable_tax is '||x_non_recoverable_tax
       , 9
       );
     END IF;

    l_po_price := l_po_price + NVL(x_non_recoverable_tax,0);

    IF (l_debug = 1)
    THEN
      INV_LOG_UTIL.trace
      ( 'Price after tax calc is  '||l_po_price
      , 'INV_THIRD_PARTY_STOCK_PVT'
      , 9
      );
    END IF;

     -- Convert the unit po price from purchasing UOM to primary UOM. THe
     -- unit price stored in MMT is based on the unit for primary UOM

     l_purch_uom_price := l_po_price * ABS(l_conv_qty);
     l_po_price        := l_po_price * l_uom_rate;

     IF (l_debug = 1)
     THEN
       INV_LOG_UTIL.trace
       ( 'conversion rate for UOM is '||l_uom_rate
       , 'INV_THIRD_PARTY_STOCK_PVT'
       , 9
       );

       INV_LOG_UTIL.trace
       ( 'Price after conversion of UOM is '||l_po_price
       , 'INV_THIRD_PARTY_STOCK_PVT'
       , 9
       );
     END IF;

     --  Get the functional currency

     SELECT
       fsp.set_of_books_id
     , glb.currency_code
     , glc.PRECISION
     INTO
       l_sob_id
     , l_func_currency
     , l_precision
    FROM
      financials_system_params_all fsp
    , gl_sets_of_books glb
    , gl_currencies glc
    WHERE  fsp.set_of_books_id = glb.set_of_books_id
      AND  glb.currency_code   = glc.currency_code
      AND  NVL(fsp.org_id,-99) = NVL(l_org_id,-99);

    --  Get the currency code from the blanket PO

    SELECT
      currency_code
    , rate_type
    , rate
    , rate_date
    INTO
      l_currency_code
    , l_conv_type
    , l_user_rate
    , l_rate_date
    FROM
      po_headers_all
    WHERE po_header_id = l_header_id;

    -- If the currency code of the blanket is different than the
    -- functional currency, convert to functional currency since
    -- the price that is stored  in MMT is in fucntional currency.

    IF l_func_currency <> NVL(l_currency_code,l_func_currency)
    THEN
      -- IF it is a global agreement, get the conversion rate from
      -- the Purchasing options.

      IF (l_debug = 1)
      THEN
        INV_LOG_UTIL.trace('Curr. conv ','INV_THIRD_PARTY_STOCK_PVT',9);
      END IF;

      IF INV_PO_THIRD_PARTY_STOCK_MDTR.is_global(l_header_id)
      THEN

        l_object := 'G';
        l_rate_date := p_transaction_date;

        IF (l_debug = 1)
        THEN
          INV_LOG_UTIL.trace('Blanket is GA','INV_THIRD_PARTY_STOCK_PVT',9);
        END IF;

        SELECT
          default_rate_type
        INTO
          l_conv_type
        FROM
          po_system_parameters_all
        WHERE NVL(org_id,-99) = NVL(l_org_id,-99);

        IF l_conv_type IS NULL
        THEN
          FND_MESSAGE.Set_Name('INV', 'INV_CONS_SUP_NO_RATE_SETUP');
          FND_MESSAGE.Set_Token('SuppName',l_vendor_name);
          FND_MESSAGE.Set_Token('SiteCode',l_vendor_site);
          FND_MSG_PUB.ADD;
          g_error_code := 'INV_CONS_SUP_NO_RATE_SETUP';
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF;

      IF (l_debug = 1)
      THEN
        INV_LOG_UTIL.trace
        ( '>> Rate date and type are: '||l_conv_type||' '||l_rate_date||
          l_currency_code||' '||l_func_currency
        , 'INV_THIRD_PARTY_STOCK_PVT'
        , 9
        );
      END IF;

      INV_THIRD_PARTY_STOCK_PVT.Get_Conversion_Rate
      ( p_set_of_books_id  => l_sob_id
      , p_from_currency    => l_currency_code
      , p_to_currency      => l_func_currency
      , p_conversion_date  => NVL(l_rate_date,SYSDATE)
      , p_conversion_type  => l_conv_type
      , p_amount           => l_po_price
      , p_user_rate        => l_user_rate
      , p_vendor_name      => l_vendor_name
      , p_vendor_site      => l_vendor_site
      , p_quantity         => p_transaction_quantity
      , x_converted_amount => l_conv_price
      , x_conversion_rate  => l_rate
      );

      l_po_price   := l_conv_price;
      l_ccode_flag := 'Y';

      IF (l_debug = 1)
      THEN
        INV_LOG_UTIL.trace
        ( '>> PO price as OUT :'||l_po_price
        , 'INV_THIRD_PARTY_STOCK_PVT'
        , 9
        );
      END IF;

    END IF;

    -- Get the total blanket amount from the PO if entered

    INV_THIRD_PARTY_STOCK_PVT.Get_Total_Blanket_Amt
    ( p_po_header_id   => l_header_id
    , p_object         => NVL(l_object,'B')
    , p_exchange_rate  => l_rate
    , p_ccode_flag     => NVL(l_ccode_flag,'N')
    , x_released_amt   => l_released_amt
    , x_consumed_amt   => l_consumed_amt
    , x_amount_limit   => l_bkt_amt_limit
    );

    IF (l_debug = 1)
    THEN
      INV_LOG_UTIL.trace
      ( '>> Amount limit:'||l_bkt_amt_limit
        ||'>> Released Amount: '||l_released_amt
        ||'>> Consumed Amount: '||l_consumed_amt
        ||'>> PO Price: '||l_purch_uom_price
      , 'INV_THIRD_PARTY_STOCK_PVT'
      , 9
      );
    END IF;

    -- If there is a amount limit specified in the blanket for the PO,
    -- check needs to be made to verify if the amount of the consumption
    -- exceeds the released_amount plus the txns in MCT  for which there
    -- is no consumption advice created . If the validation fails, we need
    -- to fail the transaction and return the error message to TM.

    IF (NVL(l_bkt_amt_limit,0) > 0) AND
       (NVL(l_released_amt,0)+NVL(l_consumed_amt,0)+
        NVL(l_purch_uom_price,0) > l_bkt_amt_limit)
    THEN
      FND_MESSAGE.Set_Name('INV', 'INV_CONS_SUP_AMT_AGREED_FAIL');
      FND_MESSAGE.Set_Token('SuppName',l_vendor_name);
      FND_MESSAGE.Set_Token('SiteCode',l_vendor_site);
      FND_MSG_PUB.ADD;
      g_error_code := 'INV_CONS_SUP_AMT_AGREED_FAIL' ;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  x_po_price              := l_po_price;
  p_transaction_source_id := l_header_id;
  x_rate_type             := l_conv_type;
  x_rate                  := l_rate;
  x_currency_code         := l_currency_code;
  x_rate_date             := l_rate_date;


  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '<< Exiting Get PO Info','INV_THIRD_PARTY_STOCK_PVT'
     , 9
     );
  END IF;


END Get_PO_Info;


--========================================================================
-- PROCEDURE  : Get_Account                  PRIVATE
-- PARAMETERS: p_mtl_transaction_id          Material transaction id
--             p_transaction_source_type_id  Txn Source Type
--             p_transaction_action_id       Txn action
--             p_transaction_source_id       Txn source
--             p_inventory_item_id           item
--             p_owning_organization_id      owning organization
--             p_xfr_owning_organization_id  Transfer owning organization
--             p_organization_id             Inv. organization
--             p_vendor_id                   Vendor Id
--             x_accrual_account_id          Accrual account
--             x_charge_account_id           Charge account
--             x_variance_account_id         Variance account
-- COMMENT   : Get the  accounts.
--========================================================================
PROCEDURE Get_Account
( p_mtl_transaction_id         IN   NUMBER
, p_transaction_source_type_id IN   NUMBER
, p_transaction_action_id      IN   NUMBER
, p_transaction_source_id      IN   NUMBER
, p_inventory_item_id          IN   NUMBER
, p_owning_organization_id     IN   NUMBER
, p_xfr_owning_organization_id IN   NUMBER
, p_organization_id            IN   NUMBER
, p_vendor_id                  IN   NUMBER
, x_accrual_account_id         OUT  NOCOPY NUMBER
, x_charge_account_id          OUT  NOCOPY NUMBER
, x_variance_account_id        OUT  NOCOPY NUMBER
)
IS
l_coa_id                       NUMBER;
l_vendor_site_id               NUMBER;
l_transaction_source_id        NUMBER;
l_charge_success               BOOLEAN := TRUE;
l_budget_success               BOOLEAN := TRUE;
l_accrual_success              BOOLEAN := TRUE;
l_variance_success             BOOLEAN := TRUE;
l_bom_resource_id              NUMBER;
l_bom_cost_element_id          NUMBER;
l_category_id                  NUMBER;
l_destination_type_code        VARCHAR2(50) := 'INVENTORY';
l_deliver_to_location_id       NUMBER;
l_destination_organization_id  NUMBER ;
l_destination_subinventory     VARCHAR2(50):= NULL;
l_expenditure_type             VARCHAR2(50):= NULL;
l_expenditure_organization_id  NUMBER := NULL;
l_expenditure_item_date        DATE;
l_item_id                      NUMBER ;
l_line_type_id                 NUMBER ;
l_result_billable_flag         VARCHAR2(50) :=NULL;
l_agent_id                     NUMBER :=NULL;
l_project_id                   NUMBER;
l_from_type_lookup_code        VARCHAR2(50);
l_from_header_id               NUMBER;
l_from_line_id                 NUMBER;
l_task_id                      NUMBER;
l_deliver_to_person_id         NUMBER;
l_type_lookup_code             VARCHAR2(50) := 'BLANKET';
l_vendor_id                    NUMBER ;
l_wip_entity_id                NUMBER;
l_wip_entity_type              VARCHAR2(50);
l_wip_line_id                  NUMBER;
l_wip_repetitive_schedule_id   NUMBER;
l_wip_operation_seq_num        NUMBER;
l_wip_resource_seq_num         NUMBER;
l_po_encumberance_flag         VARCHAR2(50);
l_gl_encumbered_date           DATE;
x_code_combination_id          NUMBER;
x_budget_account_id            NUMBER;
l_award_id                     NUMBER DEFAULT NULL ;
l_charge_account_flex          VARCHAR2(2000);
l_budget_account_flex          VARCHAR2(2000);
l_accrual_account_flex         VARCHAR2(2000);
l_variance_account_flex        VARCHAR2(2000);
l_charge_account_desc          VARCHAR2(2000);
l_budget_account_desc          VARCHAR2(2000);
l_accrual_account_desc         VARCHAR2(2000);
l_variance_account_desc        VARCHAR2(2000);
l_charge_field_name            VARCHAR2(60);
l_budget_field_name            VARCHAR2(60);
l_accrual_field_name           VARCHAR2(60);
l_variance_field_name          VARCHAR2(60);
l_charge_desc_field_name       VARCHAR2(60);
l_budget_desc_field_name       VARCHAR2(60);
l_accrual_desc_field_name      VARCHAR2(60);
l_variance_desc_field_name     VARCHAR2(60);
l_progress                     VARCHAR2(3) := '001';
l_new_ccid                     NUMBER;
l_ccid_returned                BOOLEAN := FALSE;
l_header_att1                  VARCHAR2(150) := NULL;
l_header_att2                  VARCHAR2(150) := NULL;
l_header_att3                  VARCHAR2(150) := NULL;
l_header_att4                  VARCHAR2(150) := NULL;
l_header_att5                  VARCHAR2(150) := NULL;
l_header_att6                  VARCHAR2(150) := NULL;
l_header_att7                  VARCHAR2(150) := NULL;
l_header_att8                  VARCHAR2(150) := NULL;
l_header_att9                  VARCHAR2(150) := NULL;
l_header_att10                 VARCHAR2(150) := NULL;
l_header_att11                 VARCHAR2(150) := NULL;
l_header_att12                 VARCHAR2(150) := NULL;
l_header_att13                 VARCHAR2(150) := NULL;
l_header_att14                 VARCHAR2(150) := NULL;
l_header_att15                 VARCHAR2(150) := NULL;
l_line_att1                    VARCHAR2(150) := NULL;
l_line_att2                    VARCHAR2(150) := NULL;
l_line_att3                    VARCHAR2(150) := NULL;
l_line_att4                    VARCHAR2(150) := NULL;
l_line_att5                    VARCHAR2(150) := NULL;
l_line_att6                    VARCHAR2(150) := NULL;
l_line_att7                    VARCHAR2(150) := NULL;
l_line_att8                    VARCHAR2(150) := NULL;
l_line_att9                    VARCHAR2(150) := NULL;
l_line_att10                   VARCHAR2(150) := NULL;
l_line_att11                   VARCHAR2(150) := NULL;
l_line_att12                   VARCHAR2(150) := NULL;
l_line_att13                   VARCHAR2(150) := NULL;
l_line_att14                   VARCHAR2(150) := NULL;
l_line_att15                   VARCHAR2(150) := NULL;
l_fb_error_msg                 VARCHAR2(2000);
wf_itemkey                     VARCHAR2(80) := NULL;
po_encumberance_flag           VARCHAR2(2)  := 'N';
l_new_ccid_generated           BOOLEAN := FALSE;
l_shipment_att1                VARCHAR2(150);
l_shipment_att2                VARCHAR2(150);
l_shipment_att3                VARCHAR2(150) ;
l_shipment_att4                VARCHAR2(150) ;
l_shipment_att5                VARCHAR2(150) ;
l_shipment_att6                VARCHAR2(150) ;
l_shipment_att7                VARCHAR2(150) ;
l_shipment_att8                VARCHAR2(150) ;
l_shipment_att9                VARCHAR2(150) ;
l_shipment_att10               VARCHAR2(150) ;
l_shipment_att11               VARCHAR2(150) ;
l_shipment_att12               VARCHAR2(150) ;
l_shipment_att13               VARCHAR2(150) ;
l_shipment_att14               VARCHAR2(150) ;
l_shipment_att15               VARCHAR2(150) ;
l_distribution_att1            VARCHAR2(150) ;
l_distribution_att2            VARCHAR2(150) ;
l_distribution_att3            VARCHAR2(150) ;
l_distribution_att4            VARCHAR2(150) ;
l_distribution_att5            VARCHAR2(150) ;
l_distribution_att6            VARCHAR2(150) ;
l_distribution_att7            VARCHAR2(150);
l_distribution_att8            VARCHAR2(150);
l_distribution_att9            VARCHAR2(150);
l_distribution_att10           VARCHAR2(150) ;
l_distribution_att11           VARCHAR2(150) ;
l_distribution_att12           VARCHAR2(150) ;
l_distribution_att13           VARCHAR2(150) ;
l_distribution_att14           VARCHAR2(150) ;
l_distribution_att15           VARCHAR2(150) ;
l_accrual_account_id           NUMBER;
l_variance_account_id          NUMBER;
l_charge_account_id            NUMBER;
l_debug                        NUMBER ;
l_vendor_name                  VARCHAR2(240);
l_vendor_site                  VARCHAR2(15);

BEGIN

  l_transaction_source_id       := p_transaction_source_id;
  l_destination_organization_id := p_organization_id;
  l_item_id                     := p_inventory_item_id;
  l_vendor_site_id              := p_owning_organization_id;
  l_debug                       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> Entering Get Account','INV_THIRD_PARTY_STOCK_PVT'
     , 9
     );
  END IF;

  IF (p_transaction_source_type_id=13) AND (p_transaction_action_id = 6)
  THEN
    -- Get the account from the parent transaction
    SELECT
      distribution_account_id
    INTO
      l_accrual_account_id
    FROM
      mtl_material_transactions
    WHERE  transaction_id = p_transaction_source_id;
  ELSE
    -- Get the chart of accounts id to pass to the Accounting engine

    SELECT
      gl.chart_of_accounts_id
    INTO
      l_coa_id
    FROM
      hr_organization_information hoi
    , hr_all_organization_units hou
    , gl_sets_of_books gl
    WHERE  hoi.organization_id        = hou.organization_id
    AND    hoi.org_information1       = TO_CHAR(gl.set_of_books_id)
    AND    hoi.org_information_context='Accounting Information'
    AND    hoi.organization_id        = p_organization_id;

    -- Call PO Account Generator to generate accrual account

    IF (l_debug = 1)
    THEN
      INV_LOG_UTIL.trace('Got coaid ','INV_THIRD_PARTY_STOCK_PVT',9);
    END IF;

    INV_PO_THIRD_PARTY_STOCK_MDTR.Generate_Account
    ( p_charge_success                 => l_charge_success
    , p_budget_success                 => l_budget_success
    , p_accrual_success                => l_accrual_success
    , p_variance_success               => l_variance_success
    , p_code_combination_id            => x_code_combination_id
    , p_charge_account_id              => l_charge_account_id
    , p_budget_account_id              => x_budget_account_id
    , p_accrual_account_id             => l_accrual_account_id
    , p_variance_account_id            => l_variance_account_id
    , p_charge_account_flex            => l_charge_account_flex
    , p_budget_account_flex            => l_budget_account_flex
    , p_accrual_account_flex           => l_accrual_account_flex
    , p_variance_account_flex          => l_variance_account_flex
    , p_charge_account_desc            => l_charge_account_desc
    , p_budget_account_desc            => l_budget_account_desc
    , p_accrual_account_desc           => l_accrual_account_desc
    , p_variance_account_desc          => l_variance_account_desc
    , p_coa_id                         => l_coa_id
    , p_bom_resource_id                => l_bom_resource_id
    , p_bom_cost_element_id            => l_bom_cost_element_id
    , p_category_id                    => l_category_id
    , p_destination_type_code          => l_destination_type_code
    , p_deliver_to_location_id         => l_deliver_to_location_id
    , p_destination_organization_id    => l_destination_organization_id
    , p_destination_subinventory       => l_destination_subinventory
    , p_expenditure_type               => l_expenditure_type
    , p_expenditure_organization_id    => l_expenditure_organization_id
    , p_expenditure_item_date          => l_expenditure_item_date
    , p_item_id                        => l_item_id
    , p_line_type_id                   => l_line_type_id
    , p_result_billable_flag           => l_result_billable_flag
    , p_agent_id                       => l_agent_id
    , p_project_id                     => l_project_id
    , p_from_type_lookup_code          => l_from_type_lookup_code
    , p_from_header_id                 => l_from_header_id
    , p_from_line_id                   => l_from_line_id
    , p_task_id                        => l_task_id
    , p_deliver_to_person_id           => l_deliver_to_person_id
    , p_type_lookup_code               => l_type_lookup_code
    , p_vendor_id                      => p_vendor_id
    , p_wip_entity_id                  => l_wip_entity_id
    , p_wip_entity_type                => l_wip_entity_type
    , p_wip_line_id                    => l_wip_line_id
    , p_wip_repetitive_schedule_id     => l_wip_repetitive_schedule_id
    , p_wip_operation_seq_num          => l_wip_operation_seq_num
    , p_wip_resource_seq_num           => l_wip_resource_seq_num
    , p_po_encumberance_flag           => l_po_encumberance_flag
    , p_gl_encumbered_date             => l_gl_encumbered_date
    , p_wf_itemkey                     => wf_itemkey
    , p_new_combination                => l_new_ccid_generated
    , p_header_att1                    => l_header_att1
    , p_header_att2                    => l_header_att2
    , p_header_att3                    => l_header_att3
    , p_header_att4                    => l_header_att4
    , p_header_att5                    => l_header_att5
    , p_header_att6                    => l_header_att6
    , p_header_att7                    => l_header_att7
    , p_header_att8                    => l_header_att8
    , p_header_att9                    => l_header_att9
    , p_header_att10                   => l_header_att10
    , p_header_att11                   => l_header_att11
    , p_header_att12                   => l_header_att12
    , p_header_att13                   => l_header_att13
    , p_header_att14                   => l_header_att14
    , p_header_att15                   => l_header_att15
    , p_line_att1                      => l_line_att1
    , p_line_att2                      => l_line_att2
    , p_line_att3                      => l_line_att3
    , p_line_att4                      => l_line_att4
    , p_line_att5                      => l_line_att5
    , p_line_att6                      => l_line_att6
    , p_line_att7                      => l_line_att7
    , p_line_att8                      => l_line_att8
    , p_line_att9                      => l_line_att9
    , p_line_att10                     => l_line_att10
    , p_line_att11                     => l_line_att11
    , p_line_att12                     => l_line_att12
    , p_line_att13                     => l_line_att13
    , p_line_att14                     => l_line_att14
    , p_line_att15                     => l_line_att15
    , p_shipment_att1                  => l_shipment_att1
    , p_shipment_att2                  => l_shipment_att2
    , p_shipment_att3                  => l_shipment_att3
    , p_shipment_att4                  => l_shipment_att4
    , p_shipment_att5                  => l_shipment_att5
    , p_shipment_att6                  => l_shipment_att6
    , p_shipment_att7                  => l_shipment_att7
    , p_shipment_att8                  => l_shipment_att8
    , p_shipment_att9                  => l_shipment_att9
    , p_shipment_att10                 => l_shipment_att10
    , p_shipment_att11                 => l_shipment_att11
    , p_shipment_att12                 => l_shipment_att12
    , p_shipment_att13                 => l_shipment_att13
    , p_shipment_att14                 => l_shipment_att14
    , p_shipment_att15                 => l_shipment_att15
    , p_distribution_att1              => l_distribution_att1
    , p_distribution_att2              => l_distribution_att2
    , p_distribution_att3              => l_distribution_att3
    , p_distribution_att4              => l_distribution_att4
    , p_distribution_att5              => l_distribution_att5
    , p_distribution_att6              => l_distribution_att6
    , p_distribution_att7              => l_distribution_att7
    , p_distribution_att8              => l_distribution_att8
    , p_distribution_att9              => l_distribution_att9
    , p_distribution_att10             => l_distribution_att10
    , p_distribution_att11             => l_distribution_att11
    , p_distribution_att12             => l_distribution_att12
    , p_distribution_att13             => l_distribution_att13
    , p_distribution_att14             => l_distribution_att14
    , p_distribution_att15             => l_distribution_att15
    , p_fb_error_msg                   => l_fb_error_msg
    , p_Award_id                       => l_award_id
    , p_vendor_site_id                 => l_vendor_site_id
    );
  END IF;

  x_charge_account_id   := l_charge_account_id;
  x_accrual_account_id  := l_accrual_account_id;
  x_variance_account_id := l_variance_account_id;

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( 'acct generated is'||x_accrual_account_id
    , 'INV_THIRD_PARTY_STOCK_PVT'
    , 9
    );
  END IF;

  IF (l_fb_error_msg IS NOT NULL)
  THEN
    SELECT
      pov.vendor_name
    , povs.vendor_site_code
    INTO
      l_vendor_name
    , l_vendor_site
    FROM
      po_vendors pov
    , po_vendor_sites_all povs
    WHERE pov.vendor_id       = povs.vendor_id
      AND pov.vendor_id       = p_vendor_id
      AND povs.vendor_site_id = l_vendor_site_id;

    FND_MESSAGE.Set_Name('INV', 'INV_CONS_SUP_GEN_ACCT');
    FND_MESSAGE.Set_Token('SuppName',l_vendor_name);
    FND_MESSAGE.Set_Token('SiteCode',l_vendor_site);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;


EXCEPTION
  WHEN OTHERS THEN
   g_error_code := 'INV_CONS_SUP_GEN_ACCT' ;

   IF (l_debug = 1)
   THEN
    INV_LOG_UTIL.trace
    ( 'OTHERS error - Get_Account' ,
             'INV_THIRD_PARTY_STOCK_PVT'
     , 9
     );
   END IF;
   RAISE;

END Get_Account;


--========================================================================
-- PROCEDURE : Process_Financial_Info PUBLIC
-- PARAMETERS: p_mtl_transaction_id          Material transaction id
--             p_transaction_source_type_id  Txn source Type
--             p_transaction_action_id       Txn action
--             p_inventory_item_id           item
--             p_owning_organization_id      owning organization
--             p_xfr_owning_organization_id  transfer owning organization
--             p_organization_id             Inv. organization
--             p_transaction_quantity        Transaction Quantity
--             p_transaction_source_id       Txn source
--             p_item_revision               Revision
--             x_po_price                    PO price
--             x_account_id                  Account
--             x_rate                        Exchange Rate
--             x_rate_type                   Exchange Rate type
--             x_rate_date                   Exchange rate date
--             x_currency_code               Currency Code
--             x_message_count
--             x_message_data
--             x_return_status               status
--             p_secondary_transaction_qty   Transaction Quantity
--                                           in Secondary UOM
-- COMMENT   : Process Finanical information for consigned transactions
--             This procedure is invoked by the Inventory TM when
--             processing consigned transactions.
-- CHANGE    : INVCONV START PBAMB
--             Added  a new parameter p_secondary_transaction_qty
--             to support process attributes for Inventory Convergence
--========================================================================
PROCEDURE Process_Financial_Info
( p_mtl_transaction_id         IN   NUMBER
, p_rct_transaction_id         IN   NUMBER
, p_transaction_source_type_id IN   NUMBER
, p_transaction_action_id      IN   NUMBER
, p_inventory_item_id          IN   NUMBER
, p_owning_organization_id     IN   NUMBER
, p_xfr_owning_organization_id IN   NUMBER
, p_organization_id            IN   NUMBER
, p_transaction_quantity       IN   NUMBER
, p_transaction_date           IN   DATE
, p_transaction_source_id      IN   OUT NOCOPY NUMBER
, p_item_revision              IN   VARCHAR2
, x_po_price                   OUT  NOCOPY NUMBER
, x_account_id                 OUT  NOCOPY NUMBER
, x_rate                       OUT  NOCOPY NUMBER
, x_rate_type                  OUT  NOCOPY VARCHAR2
, x_rate_date                  OUT  NOCOPY DATE
, x_currency_code              OUT  NOCOPY VARCHAR2
, x_msg_count                  OUT  NOCOPY NUMBER
, x_msg_data                   OUT  NOCOPY VARCHAR2
, x_return_status              OUT  NOCOPY VARCHAR2
, p_secondary_transaction_qty  IN   NUMBER -- INVCONV
)
IS
l_transaction_source_id NUMBER;
l_po_header_id          NUMBER;
l_vendor_site_id        NUMBER;
l_tax_code_id           NUMBER;
l_tax_rate              NUMBER;
l_tax_recovery_rate     NUMBER;
l_recoverable_tax       NUMBER;
l_non_recoverable_tax   NUMBER;
l_rate                  NUMBER;
l_rate_type             VARCHAR2(30);
l_rate_date             DATE;
l_currency_code         VARCHAR2(25);
l_charge_account_id     NUMBER;
l_variance_account_id   NUMBER;
l_org_id                NUMBER;
l_vendor_id             NUMBER;
l_appl_id               NUMBER;
l_debug                 NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
/* bug 4969420 -  start */
/*unit price to be stored in MCT*/
l_unit_price 			NUMBER;
/* bug 4969420 -  end */
--Bug 11900144. Storing po_line_id in MCT
l_line_id NUMBER;


BEGIN

  x_return_status         := FND_API.G_RET_STS_SUCCESS;
  l_transaction_source_id := p_transaction_source_id;
  l_po_header_id          := p_transaction_source_id;

  -- If the transaction type is a 'Transfer to regular stock correction'
  -- the transfer owning organization is the vendor site.
  -- In all other cases, for implicit and explicit 'Transfer to regular
  -- stock' transactions, owning_organization_id is the vendor site id.

   g_error_code  := NULL ;
   g_po_header_id := NULL ;

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace('Call from TM >>',
              'INVVTPSB: INV_THIRD_PARTY_STOCK_PVT',9);
    INV_LOG_UTIL.trace('g_calling_action => '||g_calling_action ,9 );
    INV_LOG_UTIL.trace('g_error_code     => '|| g_error_code,9);
  END IF;


  IF (p_transaction_source_type_id=13) AND (p_transaction_action_id = 6)
  THEN
    l_vendor_site_id := p_xfr_owning_organization_id;
  ELSE
    l_vendor_site_id := p_owning_organization_id;
  END IF;

  l_org_id   := INV_THIRD_PARTY_STOCK_UTIL.Get_Org_Id(l_vendor_site_id);

  /* Removing the commented code for setting ou context: 8608765 */
   INV_THIRD_PARTY_STOCK_UTIL.Set_OU_Context
  ( p_org_id          => l_org_id);

  g_pgm_appl_id := l_appl_id;

  -- Get the vendor id

  SELECT
    vendor_id
  INTO
    l_vendor_id
  FROM
    po_vendor_sites_all
  WHERE  vendor_site_id = l_vendor_site_id;

  -- INVCONV get accoutn for process organiztions from OPM setup.
  /*????IF INV_GMI_RSV_BRANCH.Is_Org_Process_Org(l_org_id) THEN
     NULL; --INVCONV ???? this will be replaced with the new call of OPM API.
  ELSE */
     INV_THIRD_PARTY_STOCK_PVT.Get_Account
     ( p_mtl_transaction_id         => p_mtl_transaction_id
     , p_transaction_source_type_id => p_transaction_source_type_id
     , p_transaction_action_id      => p_transaction_action_id
     , p_transaction_source_id      => l_transaction_source_id
     , p_inventory_item_id          => p_inventory_item_id
     , p_owning_organization_id     => p_owning_organization_id
     , p_xfr_owning_organization_id => p_xfr_owning_organization_id
     , p_organization_id            => p_organization_id
     , p_vendor_id                  => l_vendor_id
     , x_accrual_account_id         => x_account_id
     , x_charge_account_id          => l_charge_account_id
     , x_variance_account_id        => l_variance_account_id
     );
  ----END IF;

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace('Account Generated>>','INV_THIRD_PARTY_STOCK_PVT',9);
  END IF;

  -- Call to get the PO price, po_header_id.

  INV_THIRD_PARTY_STOCK_PVT.Get_PO_Info
  ( p_mtl_transaction_id         => p_mtl_transaction_id
  , p_transaction_source_type_id => p_transaction_source_type_id
  , p_transaction_action_id      => p_transaction_action_id
  , p_inventory_item_id          => p_inventory_item_id
  , p_owning_organization_id     => p_owning_organization_id
  , p_xfr_owning_organization_id => p_xfr_owning_organization_id
  , p_organization_id            => p_organization_id
  , p_transaction_quantity       => ABS(p_transaction_quantity)
  , p_transaction_source_id      => l_po_header_id
  , p_transaction_date           => p_transaction_date
  , p_account_id                 => x_account_id
  , p_item_revision              => p_item_revision
  , x_po_price                   => x_po_price
  , x_tax_code_id                => l_tax_code_id
  , x_tax_rate                   => l_tax_rate
  , x_tax_recovery_rate          => l_tax_recovery_rate
  , x_recoverable_tax            => l_recoverable_tax
  , x_non_recoverable_tax        => l_non_recoverable_tax
  , x_rate                       => l_rate
  , x_rate_type                  => l_rate_type
  , x_rate_date                  => l_rate_date
  , x_currency_code              => l_currency_code
  	/* bug 4969420 -  fetching the unit price  - start */
  , x_unit_price				 => l_unit_price
  	/* bug 4969420 - end */
  -- Bug 11900144. out parameter to get po_line_id
  , x_po_line_id                 => l_line_id
  );

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace('PO Info fetched >>','INV_THIRD_PARTY_STOCK_PVT',9);
  END IF;

  -- Call to insert to consumptions table.
  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace('g_calling_action => '|| g_calling_action ,9);
  END IF;

  IF g_calling_action IS NULL OR
          g_calling_action <> 'D'
  THEN
    IF (l_debug = 1)
    THEN
      INV_LOG_UTIL.trace('Record_Consumption' ,
        'INV_THIRD_PARTY_STOCK_PVT ',9);
    END IF;

    /* INVCONV START PBAMB - Passing a new parameter p_secondary_transaction_qty to
    Record Consumption procedure to support process attributes for inventory convergence project*/
    INV_THIRD_PARTY_STOCK_PVT.Record_Consumption
    ( p_mtl_transaction_id         => p_mtl_transaction_id
    , p_transaction_source_type_id => p_transaction_source_type_id
    , p_transaction_action_id      => p_transaction_action_id
    , p_transaction_source_id      => l_transaction_source_id
    , p_transaction_quantity       => ABS(p_transaction_quantity)
    , p_secondary_transaction_qty => ABS(p_secondary_transaction_qty) /* INVCONV */
    , p_tax_code_id                => l_tax_code_id
    , p_tax_rate                   => l_tax_rate
    , p_tax_recovery_rate          => l_tax_recovery_rate
    , p_recoverable_tax            => l_recoverable_tax
    , p_non_recoverable_tax        => l_non_recoverable_tax
    , p_rate                       => l_rate
    , p_rate_type                  => l_rate_type
    , p_charge_account_id          => l_charge_account_id
    , p_variance_account_id        => l_variance_account_id
  	/* bug 4969420 - start */
	/*  passing unit price  to Record Consumption */
  , p_unit_price 				 => l_unit_price
  	/* bug 4969420   start */
    -- Bug 11900144. Passing po_line_id to record consumption
    ,  p_po_line_id                => l_line_id
    );

    IF (l_debug = 1)
    THEN
      INV_LOG_UTIL.trace('Inserted to MCT>>','INV_THIRD_PARTY_STOCK_PVT',9);
    END IF;

  -- Populate the costing table with the details of the txn.
    IF (l_debug = 1)
    THEN
      INV_LOG_UTIL.trace('Populate_Cost_Dtl',
        'INV_THIRD_PARTY_STOCK_PVT ',9);
    END IF;

    -- INVCONV do not populate cost details for process organiztions.
    /* ????IF INV_GMI_RSV_BRANCH.Is_Org_Process_Org(l_org_id) THEN
       NULL;
    ELSE */
       INV_THIRD_PARTY_STOCK_PVT.Populate_Cost_Details
       ( p_mtl_transaction_id         => p_mtl_transaction_id
       , p_rct_transaction_id         => p_rct_transaction_id
       , p_transaction_source_type_id => p_transaction_source_type_id
       , p_transaction_action_id      => p_transaction_action_id
       , p_organization_id            => p_organization_id
       , p_inventory_item_id          => p_inventory_item_id
       , p_po_price                   => x_po_price
       );
    --END IF;

     IF (l_debug = 1)
     THEN
       INV_LOG_UTIL.trace('Populated CST tbl>>','INV_THIRD_PARTY_STOCK_PVT',9);
     END IF;
  END IF ; -- Diagnostics

  p_transaction_source_id := l_po_header_id;
  x_rate                  := l_rate;
  x_rate_type             := l_rate_type;
  x_currency_code         := l_currency_code;
  x_rate_date             := l_rate_date;

  -- The following assignment is used for Consigned Inv error rpt
  g_po_header_id          := l_po_header_id ;

  -- After all the processing is complete, reset the OU context
  -- to the original value when the TM invoked the procedure.
 --  Reset_OU_Context;

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '<< Exiting Process Financial Info ','INV_THIRD_PARTY_STOCK_PVT'
     , 9
     );
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
--    Reset_OU_Context;
    x_return_status := FND_API.G_RET_STS_ERROR;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );
   IF (l_debug = 1)
   THEN
    INV_LOG_UTIL.trace
    ( '<< FND_API.G_EXC_ERROR - Process_fin Original API ',
             'INV_THIRD_PARTY_STOCK_PVT'
     , 9
     );
   END IF;


  WHEN OTHERS THEN
--    Reset_OU_Context;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );
   IF (l_debug = 1)
   THEN
    INV_LOG_UTIL.trace
    ( '<< OTHERS error - Process_fin Original API ',
             'INV_THIRD_PARTY_STOCK_PVT'
     , 9
     );
    INV_LOG_UTIL.trace
    ( '<< OTHERS error - Process_fin Original API ',
             'INV_THIRD_PARTY_STOCK_PVT'
     , 9
     );
   END IF;


END Process_Financial_Info;
/* INVCONV END */


--========================================================================
-- PROCEDURE : Process_Financial_Info  OVERLOAD API
-- PARAMETERS: p_mtl_transaction_id          Material transaction id issue
--             p_rct_transaction_id          Material transaction rct side
--             p_transaction_source_type_id  Txn source Type
--             p_transaction_action_id       Txn action
--             p_inventory_item_id           item
--             p_owning_organization_id      owning organization
--             p_owning_tp_type              owning tp type
--             p_organization_id             Inv. organization
--             p_transaction_quantity        Transaction Quantity
--             p_transaction_source_id       Txn source
--             p_item_revision               Revision
--             x_po_price                    PO price
--             x_account_id                  Accrual Account
--             x_rate                        Exchange Rate
--             x_rate_type                   Exchange Rate type
--             x_rate_date                   Exchange rate date
--             x_currency_code               Currency Code
--             x_message_count
--             x_message_data
--             x_return_status               status
-- COMMENT   : This procedure will be used by the
--             INV Consigned Inventory Diagnostics program
--             This procedure will inturn invoke the process_financial_info
--             to validate the moqd data waiting for ownership transfer
--             transaction process.
--             The process_financial_info API will also be modified
--             to make sure that it does not insert/update
--             any records as such and just perform and return
--             the validation results
--========================================================================
PROCEDURE Process_Financial_Info
( p_mtl_transaction_id         IN   NUMBER
, p_rct_transaction_id         IN   NUMBER
, p_transaction_source_type_id IN   NUMBER
, p_transaction_action_id      IN   NUMBER
, p_inventory_item_id          IN   NUMBER
, p_owning_organization_id     IN   NUMBER
, p_xfr_owning_organization_id IN   NUMBER
, p_organization_id            IN   NUMBER
, p_transaction_quantity       IN   NUMBER
, p_transaction_date           IN   DATE
, p_transaction_source_id      IN   OUT  NOCOPY NUMBER
, p_item_revision              IN   VARCHAR2 DEFAULT NULL
, p_calling_action             IN   VARCHAR2
, x_po_price                   OUT  NOCOPY NUMBER
, x_account_id                 OUT  NOCOPY NUMBER
, x_rate                       OUT  NOCOPY NUMBER
, x_rate_type                  OUT  NOCOPY VARCHAR2
, x_rate_date                  OUT  NOCOPY DATE
, x_currency_code              OUT  NOCOPY VARCHAR2
, x_msg_count                  OUT  NOCOPY NUMBER
, x_msg_data                   OUT  NOCOPY VARCHAR2
, x_return_status              OUT  NOCOPY VARCHAR2
, x_error_code                 OUT  NOCOPY VARCHAR2
, x_po_header_id               OUT  NOCOPY NUMBER
, x_purchasing_UOM             OUT  NOCOPY VARCHAR2
, x_primary_UOM                OUT  NOCOPY VARCHAR2
)
IS

l_debug                 NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_secondary_transaction_qty NUMBER := NULL;

BEGIN
  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> IN Process Financial Info -  Diagnostics ',
           'INVVTPSB: INV_THIRD_PARTY_STOCK_PVT'
     , 9
     );
    INV_LOG_UTIL.trace
    ( 'p_calling_action => ' || p_calling_action ,'INV_THIRD_PARTY_STOCK_PVT'
     , 9
     );
  END IF;

  x_return_status         := FND_API.G_RET_STS_SUCCESS;
  x_error_code            := NULL;
  g_calling_action        := p_calling_action ;
  g_error_code            := NULL;
  g_po_header_id          := NULL ;
  x_po_header_id          := NULL ;
  x_purchasing_UOM        := NULL ;
  x_primary_UOM           := NULL;
  g_purchasing_uom        := NULL ;
  g_primary_uom           := NULL ;

  -- Call the original API that was released in 11.5.9

  IF (l_debug = 1)
  THEN
  INV_LOG_UTIL.trace
  ( 'Calling main Process_Financial_Info ' ,
             'from Overloaded API '
   , 9
   );
  END IF;


  INV_THIRD_PARTY_STOCK_PVT.Process_Financial_Info
  ( p_mtl_transaction_id         => p_mtl_transaction_id
  , p_rct_transaction_id         => p_rct_transaction_id
  , p_transaction_source_type_id => p_transaction_source_type_id
  , p_transaction_action_id      => p_transaction_action_id
  , p_inventory_item_id          => p_inventory_item_id
  , p_owning_organization_id     => p_owning_organization_id
  , p_xfr_owning_organization_id => p_xfr_owning_organization_id
  , p_organization_id            => p_organization_id
  , p_transaction_quantity       => p_transaction_quantity
  , p_transaction_date           => p_transaction_date
  , p_transaction_source_id      => p_transaction_source_id
  , p_item_revision              => p_item_revision
  , p_secondary_transaction_qty  => l_secondary_transaction_qty
  , x_po_price                   => x_po_price
  , x_account_id                 => x_account_id
  , x_rate                       => x_rate
  , x_rate_type                  => x_rate_type
  , x_rate_date                  => x_rate_date
  , x_currency_code              => x_currency_code
  , x_msg_count                  => x_msg_count
  , x_msg_data                   => x_msg_data
  , x_return_status              => x_return_status
  );

  x_error_code     := g_error_code ;
  x_po_header_id   := g_po_header_id ;
  x_purchasing_UOM := g_purchasing_uom ;
  x_primary_UOM    := g_primary_uom ;

  IF (l_debug = 1)
  THEN
  INV_LOG_UTIL.trace
  ( '<< Out of main Process_Financial_Info '|| x_return_status ,
             'from Overloaded API '
   , 9
   );
    INV_LOG_UTIL.trace
    ( 'x_return_status => '|| x_return_status ,'INV_THIRD_PARTY_STOCK_PVT'
     , 9);
    INV_LOG_UTIL.trace
    ( 'x_error_code =>' || x_error_code ,'INV_THIRD_PARTY_STOCK_PVT'
     , 9);

    INV_LOG_UTIL.trace
    ( 'x_purchasing_UOM=> ' || x_purchasing_UOM ,'INV_THIRD_PARTY_STOCK_PVT'
     , 9);
    INV_LOG_UTIL.trace
    ( 'x_primary_UOM=> ' || x_primary_UOM ,'INV_THIRD_PARTY_STOCK_PVT'
     , 9);
    INV_LOG_UTIL.trace
    ( 'x_po_header_id=> ' || x_po_header_id ,'INV_THIRD_PARTY_STOCK_PVT'
     , 9);
 END IF;

  x_error_code := g_error_code ;

  IF x_return_status = fnd_api.g_ret_sts_error
  THEN
      RAISE fnd_api.g_exc_error;
  END IF ;

  IF x_return_status = fnd_api.g_ret_sts_unexp_error
  THEN
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '<< OUT Process Financial Info - Diagnostics  ',
          'INVVTPSB: INV_THIRD_PARTY_STOCK_PVT'
     , 9
     );
    INV_LOG_UTIL.trace
    ( 'x_return_status => '|| x_return_status ,'INV_THIRD_PARTY_STOCK_PVT'
     , 9);
    INV_LOG_UTIL.trace
    ( 'x_error_code =>' || x_error_code ,'INV_THIRD_PARTY_STOCK_PVT'
     , 9);
  END IF;
  g_po_header_id := NULL ;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
   -- Reset_OU_Context;
    x_return_status := FND_API.G_RET_STS_ERROR;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( 'SQLERRM=> ' || SQLERRM ,
          'INVVTPSB: INV_THIRD_PARTY_STOCK_PVT' , 9);
  END IF;

  WHEN fnd_api.g_exc_unexpected_error THEN
  -- Reset_OU_Context;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( 'SQLERRM=> ' || SQLERRM ,
          'INVVTPSB: INV_THIRD_PARTY_STOCK_PVT' , 9);
  END IF;


  WHEN OTHERS THEN
  -- Reset_OU_Context;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );
  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( 'SQLERRM=> ' || SQLERRM ,
          'INVVTPSB: INV_THIRD_PARTY_STOCK_PVT' , 9);
  END IF;


END Process_Financial_Info;

END INV_THIRD_PARTY_STOCK_PVT;

/
