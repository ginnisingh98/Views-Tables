--------------------------------------------------------
--  DDL for Package Body GMF_GET_TRANSFER_PRICE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_GET_TRANSFER_PRICE_PUB" AS
/* $Header: GMFGXFRB.pls 120.13.12010000.4 2009/12/21 19:07:13 uphadtar ship $ */

  G_PACKAGE_NAME                 VARCHAR2(50) := 'GMF_get_transfer_price_PUB';
  --===================================================================
  --
  -- Following G_ global variables will be used for Advanced Pricing
  --
  --===================================================================
  G_LINE_INDEX_TBL               QP_PREQ_GRP.pls_integer_type;
  G_LINE_TYPE_CODE_TBL           QP_PREQ_GRP.VARCHAR_TYPE;
  G_PRICING_EFFECTIVE_DATE_TBL   QP_PREQ_GRP.DATE_TYPE;
  G_ACTIVE_DATE_FIRST_TBL        QP_PREQ_GRP.DATE_TYPE;
  G_ACTIVE_DATE_FIRST_TYPE_TBL   QP_PREQ_GRP.VARCHAR_TYPE;
  G_ACTIVE_DATE_SECOND_TBL       QP_PREQ_GRP.DATE_TYPE;
  G_ACTIVE_DATE_SECOND_TYPE_TBL  QP_PREQ_GRP.VARCHAR_TYPE;
  G_LINE_QUANTITY_TBL            QP_PREQ_GRP.NUMBER_TYPE;
  G_LINE_UOM_CODE_TBL            QP_PREQ_GRP.VARCHAR_TYPE;
  G_REQUEST_TYPE_CODE_TBL        QP_PREQ_GRP.VARCHAR_TYPE;
  G_PRICED_QUANTITY_TBL          QP_PREQ_GRP.NUMBER_TYPE;
  G_UOM_QUANTITY_TBL             QP_PREQ_GRP.NUMBER_TYPE;
  G_PRICED_UOM_CODE_TBL          QP_PREQ_GRP.VARCHAR_TYPE;
  G_CURRENCY_CODE_TBL            QP_PREQ_GRP.VARCHAR_TYPE;
  G_UNIT_PRICE_TBL               QP_PREQ_GRP.NUMBER_TYPE;
  G_PERCENT_PRICE_TBL            QP_PREQ_GRP.NUMBER_TYPE;
  G_ADJUSTED_UNIT_PRICE_TBL      QP_PREQ_GRP.NUMBER_TYPE;
  G_UPD_ADJUSTED_UNIT_PRICE_TBL  QP_PREQ_GRP.NUMBER_TYPE;
  G_PROCESSED_FLAG_TBL           QP_PREQ_GRP.VARCHAR_TYPE;
  G_PRICE_FLAG_TBL               QP_PREQ_GRP.VARCHAR_TYPE;
  G_LINE_ID_TBL                  QP_PREQ_GRP.NUMBER_TYPE;
  G_PROCESSING_ORDER_TBL         QP_PREQ_GRP.PLS_INTEGER_TYPE;
  G_ROUNDING_FACTOR_TBL          QP_PREQ_GRP.PLS_INTEGER_TYPE;
  G_ROUNDING_FLAG_TBL            QP_PREQ_GRP.FLAG_TYPE;
  G_QUALIFIERS_EXIST_FLAG_TBL    QP_PREQ_GRP.VARCHAR_TYPE;
  G_PRICING_ATTRS_EXIST_FLAG_TBL QP_PREQ_GRP.VARCHAR_TYPE;
  G_PRICE_LIST_ID_TBL            QP_PREQ_GRP.NUMBER_TYPE;
  G_PL_VALIDATED_FLAG_TBL        QP_PREQ_GRP.VARCHAR_TYPE;
  G_PRICE_REQUEST_CODE_TBL       QP_PREQ_GRP.VARCHAR_TYPE;
  G_USAGE_PRICING_TYPE_TBL       QP_PREQ_GRP.VARCHAR_TYPE;
  G_PRICING_STATUS_CODE_TBL      QP_PREQ_GRP.VARCHAR_TYPE;
  G_PRICING_STATUS_TEXT_TBL      QP_PREQ_GRP.VARCHAR_TYPE;
  G_LINE_CATEGORY_TBL            QP_PREQ_GRP.VARCHAR_TYPE;

  G_UNIT_SELLING_PRICE_TBL       QP_PREQ_GRP.NUMBER_TYPE;
  G_UNIT_LIST_PRICE_TBL          QP_PREQ_GRP.NUMBER_TYPE;
  G_UNIT_SELL_PRICE_PER_PQTY_TBL QP_PREQ_GRP.NUMBER_TYPE;
  G_UNIT_LIST_PRICE_PER_PQTY_TBL QP_PREQ_GRP.NUMBER_TYPE;
  G_PRICING_QUANTITY_TBL         QP_PREQ_GRP.NUMBER_TYPE;
  G_UNIT_LIST_PERCENT_TBL        QP_PREQ_GRP.NUMBER_TYPE;
  G_UNIT_PERCENT_BASE_PRICE_TBL  QP_PREQ_GRP.NUMBER_TYPE;
  G_UNIT_SELLING_PERCENT_TBL     QP_PREQ_GRP.NUMBER_TYPE;

  --  Package body level globals to store input values
  g_transfer_type           VARCHAR2(6);  /* INTCOM or INTORG */

  g_from_ou                 BINARY_INTEGER;
  g_to_ou                   BINARY_INTEGER;

  g_from_organization_id    NUMBER;
  g_from_org_currency       VARCHAR2(31);
  g_to_organization_id      BINARY_INTEGER;

  g_inventory_item_id       NUMBER;
  g_transaction_qty         mtl_material_transactions.transaction_quantity%TYPE;
  g_transaction_uom         mtl_material_transactions.transaction_uom%TYPE;
  g_primary_uom             mtl_system_items_b.primary_uom_code%TYPE;

  g_transaction_id          BINARY_INTEGER; -- will be NULL
  g_order_line_id           BINARY_INTEGER; -- will be order_line_id for Internal Orders

  g_global_procurement_flag VARCHAR2(1);
  g_drop_ship_flag          VARCHAR2(1);

  g_xfer_source             VARCHAR2(6);

  G_XFER_PRICE_IN_TXN_UOM   CONSTANT BINARY_INTEGER := 1;
  G_XFER_PRICE_IN_PRI_UOM   CONSTANT BINARY_INTEGER := 2;

  l_debug                   BINARY_INTEGER;

  PROCEDURE print_debug(p_message in VARCHAR2) IS
  BEGIN
    IF (l_debug = 1) THEN
      inv_log_util.trace(p_message, '', 4);
    END IF;
  END print_debug;

  --===================================================================
  --
  -- Start of comments
  -- API name        : get_transfer_price
  -- Type            : Public
  -- Pre-reqs        : None
  -- Version         : Current version 1.0
  --                   Initial version 1.0
  -- PURPOSE         : Get Transfer Price
  -- Parameters      :
  --  p_transaction_id  : Order Line Id of Sales Order
  --  p_transfer_type   : Valid values are INTCOM and INTORG.
  --                      INTCOM: Transfer using Internal Orders across OUs
  --                              with InterCompany Invoicing Enabled.
  --                              (Set when Internal Order Shipment Line is
  --                               being created. Package INV_TXN_MANAGER_GRP)
  --                      INTORG: All other interorg transfers.
  --                              (set during Internal Req creation and during
  --                               Inv. Interorg Transfer)
  --
  --  p_transfer_source : INTORG: Inventory InterOrg Xfer
  --                      INTORD: Internal Order
  --                      INTREQ: Internal Req
  --
  --  x_transfer_price                    OUT NOCOPY    NUMBER   /* In Txn UOM */
  --  x_currency_code                     OUT NOCOPY    VARCHAR2
  --  x_transfer_price_priuom             OUT NOCOPY    NUMBER   /* In Item Primary UOM */
  --
  --  HISTORY
  --
  --    Bug#5461545 Anand Thiyagarajan 17-Aug-2006
  --      Modified Code to correct the way the transfer price in transaction UOM
  --      and transfer price in Primary UOM are correctly calculated.
  -- End of comments
  -- Uday Phadtare Bug 7713946 24-FEB-2009. Derive OU IDs for p_from_organization_id,
  --   p_to_organization_id and use them instead of using p_from_ou and p_to_ou.
  -- Uday Phadtare Bug 9189961 28-OCT-2009. Added parameter p_transaction_date to
  --   procedure get_transfer_price.
  --===================================================================

  Procedure get_transfer_price
    ( p_api_version                       IN            NUMBER
    , p_init_msg_list                     IN            VARCHAR2

    , p_inventory_item_id                 IN            NUMBER
    , p_transaction_qty                   IN            NUMBER
    , p_transaction_uom                   IN            VARCHAR2

    , p_transaction_id                    IN            NUMBER                 /* Order Line Id for now */
    , p_global_procurement_flag           IN            VARCHAR2
    , p_drop_ship_flag                    IN            VARCHAR2

    , p_from_organization_id              IN            NUMBER
    , p_from_ou                           IN            NUMBER                 /* from OU */
    , p_to_organization_id                IN            NUMBER
    , p_to_ou                             IN            NUMBER                 /* to OU */

    , p_transfer_type                     IN            VARCHAR2
    , p_transfer_source                   IN            VARCHAR2               /* INTORG, INTORD, INTREQ */
    , p_transaction_date                  IN            DATE     DEFAULT NULL  /* Bug 9189961 */

    , x_return_status                     OUT NOCOPY    VARCHAR2
    , x_msg_data                          OUT NOCOPY    VARCHAR2
    , x_msg_count                         OUT NOCOPY    NUMBER

    , x_transfer_price                    OUT NOCOPY    NUMBER                 /* In Txn UOM */
    , x_transfer_price_priuom             OUT NOCOPY    NUMBER                 /* In Item Primary UOM */
    , x_currency_code                     OUT NOCOPY    VARCHAR2
    , x_incr_transfer_price               OUT NOCOPY    NUMBER
    , x_incr_currency_code                OUT NOCOPY    VARCHAR2
    )
  IS

    l_transfer_price             NUMBER;
    l_transfer_price_code        NUMBER;

    l_item_description           VARCHAR2(255);
    l_uom_rate                   NUMBER;

    l_use_adv_pricing            VARCHAR2(4);
    l_pricelist_currency         VARCHAR2(30);
    l_functional_currency_code   VARCHAR2(30);

    l_return_status              VARCHAR2(1);
    l_user_hook_status           NUMBER;

    l_api_name                   VARCHAR2(80);

    l_from_uom                   VARCHAR2(40);
    l_to_uom                     VARCHAR2(40);

    l_curr_rate                  NUMBER;
    l_precision                  NUMBER;
    l_ext_precision              NUMBER;
    l_min_unit                   NUMBER;

    e_user_hook_error            EXCEPTION;
    e_uom_conversion_error       EXCEPTION;
    e_currency_conversion_error  EXCEPTION;
    e_adv_pricing_profile_error  EXCEPTION;
    e_transfer_price_null_error  EXCEPTION;
    e_ignore_error               EXCEPTION; -- Bug 5136335

    l_process_enabled_flag_from  VARCHAR2(1);
    l_process_enabled_flag_to    VARCHAR2(1);
    l_exists                     NUMBER(1);

  BEGIN

    l_api_name := 'GMF_get_transfer_price_PUB.get_transfer_price';
    l_debug    := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    print_debug(l_api_name || ' Begin Input Parameters ');
    print_debug(l_api_name || '  p_inventory_item_id: ' || p_inventory_item_id);
    print_debug(l_api_name || '  p_transaction_qty: ' || p_transaction_qty);
    print_debug(l_api_name || '  p_transaction_uom: ' || p_transaction_uom);
    print_debug(l_api_name || '  p_transaction_id: ' || p_transaction_id);
    print_debug(l_api_name || '  p_global_procurement_flag: ' || p_global_procurement_flag);
    print_debug(l_api_name || '  p_drop_ship_flag: ' || p_drop_ship_flag);
    print_debug(l_api_name || '  p_from_organization_id: ' || p_from_organization_id);
    print_debug(l_api_name || '  p_from_ou: ' || p_from_ou);
    print_debug(l_api_name || '  p_to_organization_id: ' || p_to_organization_id);
    print_debug(l_api_name || '  p_to_ou: ' || p_to_ou);
    print_debug(l_api_name || '  p_transfer_type: ' || p_transfer_type);
    print_debug(l_api_name || '  p_transfer_source: ' || p_transfer_source);
    print_debug(l_api_name || '  p_transaction_date: ' || to_char(p_transaction_date, 'DD-MON-YYYY HH24:MI:SS'));
    print_debug(l_api_name || ' End Input Parameters ');

    --===================================================================
    --
    -- set global variables to use across procedures
    -- INTCOM: Internal order across OUs with intercompany invoicing.
    -- INTORG: All other transfers.
    --
    --===================================================================
    g_transfer_type           := p_transfer_type;  /* INTCOM or INTORG */

    --===================================================================
    --
    -- Following parameter will have 3 values: INTORG, INTORD, and REQ
    -- Will be used to determine which transfer_price routines to call for
    -- advanced pricing.
    --
    -- For INTORG and REQ, THIS package will be used.
    -- For INTORD we will use mtl_qp_price.get_transfer_price.
    --
    --===================================================================
    g_xfer_source             := p_transfer_source; /* INTORG, INTORD, REQ */

    g_from_organization_id    := p_from_organization_id;
    g_from_ou                 := p_from_ou;
    g_to_organization_id      := p_to_organization_id;
    g_to_ou                   := p_to_ou;

    g_inventory_item_id       := p_inventory_item_id;
    g_transaction_qty         := p_transaction_qty;
    g_transaction_uom         := p_transaction_uom;

    g_transaction_id          := p_transaction_id;
    g_global_procurement_flag := p_global_procurement_flag;
    g_drop_ship_flag          := p_drop_ship_flag;

    --===================================================================
    --
    -- Validating Inputs
    -- shall we do this for Orgs and OUs???
    --
    --===================================================================
    IF (g_from_ou is null OR g_to_ou IS NULL) OR
       (g_from_organization_id is NULL OR g_to_organization_id IS NULL)
    THEN
        print_debug('Invalid parameters to transfer price API: From/To OUs or From/To Orgs should be passed');
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --Begin Bug 7713946
    SELECT to_number(src.org_information3) src_ou
    INTO   g_from_ou
    FROM   hr_organization_information src
    WHERE  src.organization_id          = g_from_organization_id
    AND    src.org_information_context  = 'Accounting Information';

    SELECT to_number(dest.org_information3) dest_ou
    INTO   g_to_ou
    FROM   hr_organization_information dest
    WHERE  dest.organization_id         = g_to_organization_id
    AND    dest.org_information_context = 'Accounting Information';

    print_debug(l_api_name || '  g_from_ou: ' || g_from_ou);
    print_debug(l_api_name || '  g_to_ou  : ' || g_to_ou);
    --End Bug 7713946

    print_debug('  ' || l_api_name || ': Get price for item: ' || g_inventory_item_id ||
      ' org: ' || g_from_organization_id || ' Dest. Org.: ' || g_to_organization_id ||
      ' transaction qty: ' || g_transaction_qty || ' '|| g_transaction_uom);

    --===================================================================
    --
    -- Get items primary uom
    --
    --===================================================================
    SELECT primary_uom_code
      INTO g_primary_uom
      FROM mtl_system_items_b
     WHERE inventory_item_id = g_inventory_item_id
       AND organization_id   = g_from_organization_id;

    --===================================================================
    --
    -- Get sending org's base currency
    --
    -- jboppana bug 4906497:
    --  Fixed following sql for performance issue
    --===================================================================
    SELECT currency_code
      INTO g_from_org_currency
      FROM hr_organization_information org, gl_ledgers gll
     WHERE org.organization_id  = g_from_organization_id
       AND gll.ledger_id = org.org_information1
       AND org.org_information_context = 'Accounting Information';

    print_debug(l_api_name || ': p_transfer_type: ' || p_transfer_type);


    --===================================================================
    --
    -- For inter-company xfers, call existing INV transfer price API
    --
    --===================================================================
    IF (p_transfer_type = 'INTCOM')
    THEN

       print_debug(l_api_name || 'Calling INV_TRANSACTION_FLOW_PUB.get_transfer_price with following input parameters');
       print_debug(l_api_name || ' Begin Input Parameters ');
       print_debug(l_api_name || '  p_from_org_id: ' || g_from_ou);
       print_debug(l_api_name || '  p_to_org_id: ' || g_to_ou);
       print_debug(l_api_name || '  p_transaction_uom: ' || p_transaction_uom);
       print_debug(l_api_name || '  p_inventory_item_id: ' || p_inventory_item_id);
       print_debug(l_api_name || '  p_transaction_id: ' || 'NULL');
       print_debug(l_api_name || '  p_global_procurement_flag: ' || 'N');
       print_debug(l_api_name || '  p_drop_ship_flag: ' || p_drop_ship_flag);
       print_debug(l_api_name || '  p_from_organization_id: ' || p_from_organization_id);
       print_debug(l_api_name || '  p_order_line_id: ' || p_transaction_id);
       print_debug(l_api_name || '  p_transaction_date: ' || to_char(p_transaction_date, 'DD-MON-YYYY HH24:MI:SS'));
       print_debug(l_api_name || ' End Input Parameters ');

         INV_TRANSACTION_FLOW_PUB.get_transfer_price(
             x_return_status           => x_return_status
           , x_msg_data                => x_msg_data
           , x_msg_count               => x_msg_count

           , x_transfer_price          => l_transfer_price
           , x_currency_code           => l_pricelist_currency
           , x_incr_transfer_price     => x_incr_transfer_price
           , x_incr_currency_code      => x_incr_currency_code

           , p_api_version             => 1.0
           , p_init_msg_list           => fnd_api.g_false

           --Bug 7713946 Replaced p_from_ou with g_from_ou and p_to_ou with g_to_ou
           , p_from_org_id             => g_from_ou
           , p_to_org_id               => g_to_ou

           , p_transaction_uom         => p_transaction_uom
           , p_inventory_item_id       => p_inventory_item_id
           , p_transaction_id          => NULL
           , p_global_procurement_flag => 'N'
           , p_drop_ship_flag          => p_drop_ship_flag
           , p_from_organization_id    => p_from_organization_id
           , p_order_line_id           => p_transaction_id
           -- , p_process_discrete_xfer_flag => 'Y' Bug 5171637: replaced with above line.
           , p_txn_date                => p_transaction_date /* Bug 9189961 */
         );

      print_debug(l_api_name || ': return status from INV_TRANSACTION_FLOW_PUB.get_transfer_price: ' || x_return_status);
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN

        --
        -- Bug 5136335
        -- For Discrete Intercompany transfers, if no intercompany setup
        -- is done, then ignore the error. Look at the bug for more details.
        -- If intercompany setup is done, then raise error.
	--

        --
        -- Get process mfg org flag for from and to orgs
        --
        SELECT mp_from.process_enabled_flag, mp_to.process_enabled_flag
          INTO l_process_enabled_flag_from, l_process_enabled_flag_to
          FROM mtl_parameters mp_from, mtl_parameters mp_to
         WHERE mp_from.organization_id = g_from_organization_id
           AND mp_to.organization_id   = g_to_organization_id;

        IF  l_process_enabled_flag_from = 'N'
        AND l_process_enabled_flag_to   = 'N'
        THEN

          BEGIN
	    --
	    -- Bug 5675254: following query was using orgnIds instead of OU Ids.
	    -- Also added flow_type to the query
	    --
            SELECT 1
              INTO l_exists
              FROM mtl_intercompany_parameters
             WHERE sell_organization_id = g_to_ou
               AND ship_organization_id = g_from_ou
	       AND flow_type = 1
            ;
              print_debug('Discrete Xfer. IC Relations do exists between from OU and To OU. Error is being raised and txn will not be shipconfirmed.');
          EXCEPTION
            WHEN no_data_found
            THEN
              print_debug('Discrete Xfer. No IC Relations exists between from OU and To OU. No error is being raised.');
              x_transfer_price        := NULL;
              x_transfer_price_priuom := NULL;
              RAISE e_ignore_error;
          END;

        END IF;
	--
	-- End -- Bug 5136335
	--

        x_msg_data := FND_MESSAGE.get;
        IF (l_debug = 1) THEN
           print_debug('INV_TRANSACTION_FLOW_PUB.get_transfer_price: Error = '|| x_msg_data );
        END IF;
        RAISE FND_API.G_EXC_ERROR;

      ELSE

        IF l_transfer_price IS NULL
        THEN
          print_debug('INV_TRANSACTION_FLOW_PUB.get_transfer_price: Transfer Price is NULL: '|| x_msg_data );
          RAISE e_transfer_price_null_error;
        END IF;

      END IF;

      l_transfer_price_code := G_XFER_PRICE_IN_TXN_UOM; -- since above api returns in Txn uom
      print_debug(l_api_name || ': Transfer Price: ' || l_transfer_price ||
        ' PriceCode: ' || l_transfer_price_code);

    ELSE

      --===================================================================
      -- Call user hook - always
      --===================================================================
      print_debug(l_api_name || ': calling user hook');
      GMF_get_xfer_price_hook_PUB.Get_xfer_price_user_hook (
          p_api_version          => 1.0
        , p_init_msg_list        => fnd_api.g_false

        , p_transaction_uom      => p_transaction_uom
        , p_inventory_item_id    => p_inventory_item_id
        , p_transaction_id       => p_transaction_id

        , p_from_organization_id => p_from_organization_id
        , p_to_organization_id   => p_to_organization_id

        --Bug 7713946 Replaced p_from_ou with g_from_ou and p_to_ou with g_to_ou
        , p_from_ou              => g_from_ou
        , p_to_ou                => g_to_ou

        , x_return_status        => l_user_hook_status
        , x_msg_data             => x_msg_data
        , x_msg_count            => x_msg_count

        , x_transfer_price       => x_transfer_price
        , x_transfer_price_priuom=> x_transfer_price_priuom   /* In Item Primary UOM */
        , x_currency_code        => x_currency_code
        );

      --===================================================================
      --
      -- x_return_status = -1 is default i.e., user hook
      -- not implemented.
      -- Any other value means, user hook implemented and
      -- we need to honor whatever the outcome
      --
      --===================================================================
      IF l_user_hook_status = -2   -- User Hook error
      THEN
        print_debug(l_api_name || ': user hook returned error: ' || x_msg_data);
        RAISE e_user_hook_error;

      ELSIF l_user_hook_status = 0
      THEN
        -- Got the transfer price. return from here.
        print_debug(l_api_name || ': user hook returned transfer price in txn uom: ' || x_transfer_price ||
            ' and in item primary uom: ' || x_transfer_price_priuom);
        print_debug(l_api_name || ': End');
        RETURN;
      END IF;
      print_debug(l_api_name || ': user hook NOT implemented');


      --===================================================================
      -- If we are here means user hook is not implemented.
      --
      -- Get the new profile to see whether we can use Adv. Pricing or not.
      -- This is the new profile added for inter-org transfer across
      -- process/discrete xfers only.
      --===================================================================

      l_use_adv_pricing := fnd_profile.value('INV_USE_QP_FOR_INTERORG');

      print_debug(l_api_name || ': Adv. Pricing profile: ' || l_use_adv_pricing);


      IF (l_use_adv_pricing IS NULL OR l_use_adv_pricing = 2)
        -- Profile set to No
      THEN
        --===================================================================
        --
        -- Basic pricing. So, get pricelist from interorg parameters
        --
        --===================================================================

        print_debug(l_api_name || ': Calling Basic Pricing...');

        GMF_get_transfer_price_PUB.get_xfer_price_basic (
            x_transfer_price      => l_transfer_price
          , x_transfer_price_code => l_transfer_price_code
          , x_pricelist_currency  => l_pricelist_currency
          , x_return_status       => x_return_status
          , x_msg_data            => x_msg_data
          , x_msg_count           => x_msg_count
          );

        print_debug(l_api_name || ': Basic Pricing status: ' || x_return_status);
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
        THEN

          x_msg_data := FND_MESSAGE.get;
          IF (l_debug = 1) THEN
             print_debug('GMF_get_transfer_price_PUB.get_xfer_price_basic: Error = '|| x_msg_data );
          END IF;
          RAISE FND_API.G_EXC_ERROR;

        ELSE

          IF l_transfer_price IS NULL
          THEN
            print_debug('GMF_get_transfer_price_PUB.get_xfer_price_basic: Transfer Price is NULL: '|| x_msg_data );
            RAISE e_transfer_price_null_error;
          END IF;

        END IF;

        -- l_pricelist_currency := g_from_org_currency;
        print_debug(l_api_name || ': Transfer Price: ' || l_transfer_price ||
          ' PriceCode: ' || l_transfer_price_code);


      ELSIF l_use_adv_pricing = 1
      THEN
        --===================================================================
        --
        -- Advance pricing
        --
        --===================================================================

        print_debug(l_api_name || ': Calling Advanced Pricing...');
        GMF_get_transfer_price_PUB.get_xfer_price_qp (
             x_transfer_price       => l_transfer_price
           , x_currency_code        => l_pricelist_currency
           , x_transfer_price_code  => l_transfer_price_code
           , x_return_status        => x_return_status
           , x_msg_data             => x_msg_data
           , x_msg_count            => x_msg_count
        );

        print_debug(l_api_name || ': After Advanced Pricing. status: ' || x_return_status);

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
        THEN

          IF (l_debug = 1) THEN
             print_debug('GMF_get_transfer_price_PUB.get_xfer_price_qp: Error = '|| x_msg_data );
          END IF;
          RAISE FND_API.G_EXC_ERROR;

        ELSE

          IF l_transfer_price IS NULL
          THEN
            print_debug('GMF_get_transfer_price_PUB.get_xfer_price_qp: Transfer Price is NULL: '|| x_msg_data );
            RAISE e_transfer_price_null_error;
          END IF;

        END IF;

        -- l_pricelist_currency := g_from_org_currency;
        print_debug(l_api_name || ': Transfer Price: ' || l_transfer_price ||
          ' PriceCode: ' || l_transfer_price_code);

      END IF;

    END IF;  -- IF (p_transfer_type = 'INTCOM')


    --===================================================================
    --
    -- l_transfer_price_code = 2: xfer price in item's primary uom
    -- Convert to transaction_uom
    --
    --===================================================================
    IF  (NVL(l_transfer_price,0) >= 0  --smukalla Bug 8668021 Changed 'IF  (NVL(l_transfer_price,0) > 0' to 'IF  (NVL(l_transfer_price,0) >= 0'
    AND  g_primary_uom = g_transaction_uom)
    THEN

      x_transfer_price        := l_transfer_price;
      x_transfer_price_priuom := l_transfer_price;

    ELSIF  (NVL(l_transfer_price,0)  >= 0  --smukalla Bug 8668021 Changed '(NVL(l_transfer_price,0) > 0' to '(NVL(l_transfer_price,0) >= 0'
    AND  g_primary_uom <> g_transaction_uom)
    THEN

      print_debug(l_api_name || ': Converting Transfer Price from Primary UOM: ' || g_primary_uom ||
        ' to Transaction UOM: ' || g_transaction_uom);

      IF  l_transfer_price_code = G_XFER_PRICE_IN_PRI_UOM
      THEN
        l_from_uom := g_primary_uom;
        l_to_uom   := g_transaction_uom;
      ELSE
        l_from_uom := g_transaction_uom;
        l_to_uom   := g_primary_uom;
      END IF;

      -- do uom conversion
      INV_CONVERT.inv_um_conversion(
          from_unit   => l_from_uom
        , to_unit     => l_to_uom
        , item_id     => g_inventory_item_id
        , uom_rate    => l_uom_rate
        );

      IF (l_uom_rate = -99999) THEN
        --
        -- UOM conversion error
        --
        RAISE e_uom_conversion_error;

      END IF;

      IF  l_transfer_price_code = G_XFER_PRICE_IN_PRI_UOM
      THEN
---     x_transfer_price        := l_uom_rate * l_transfer_price; /* ANTHIYAG Bug#5461545 17-Aug-2006 */
        x_transfer_price        := l_transfer_price / nvl(l_uom_rate,1); /* ANTHIYAG Bug#5461545 17-Aug-2006 */

        x_transfer_price_priuom := l_transfer_price;
      ELSE
        x_transfer_price        := l_transfer_price;
---     x_transfer_price_priuom := l_uom_rate * l_transfer_price; /* ANTHIYAG Bug#5461545 17-Aug-2006 */
        x_transfer_price_priuom := l_transfer_price / nvl(l_uom_rate,1); /* ANTHIYAG Bug#5461545 17-Aug-2006 */
      END IF;
      -- l_transfer_price := l_uom_rate * l_transfer_price;

      print_debug(l_api_name || ': After UOM conversion Transfer Price in ' ||
        'Txn/Pri UOM is: ' || x_transfer_price ||'/'|| x_transfer_price_priuom);

    END IF;

    /* For InterCompany xfer, INV API has already converted the transfer price
     * to base currency.
     */
    IF  (p_transfer_type <> 'INTCOM')
    AND (NVL(l_transfer_price,0) >= 0) --smukalla Bug 8668021 Changed ' (NVL(l_transfer_price,0) > 0' to '(NVL(l_transfer_price,0) >= 0'
    THEN
      print_debug(l_api_name || ': Now doing currency conversion from priceList Currency: ' ||
        l_pricelist_currency || ' to functional currency, if necessary');

      l_curr_rate := INV_TRANSACTION_FLOW_PUB.convert_currency (
                              p_org_id              => g_from_ou
                            , p_transfer_price      => 1
                            , p_currency_code       => l_pricelist_currency
                            , p_transaction_date    => sysdate
                            , x_functional_currency_code => l_functional_currency_code
                            , x_return_status       => x_return_status
                            , x_msg_data            => x_msg_data
                            , x_msg_count           => x_msg_count
                            );
      print_debug(l_api_name || ' l_curr_rate: ' || l_curr_rate);
      print_debug(l_api_name || ' l_functional_currency_code: ' || l_functional_currency_code);

      fnd_currency.get_info (currency_code     => l_functional_currency_code,
                             precision         => l_precision,
                             ext_precision     => l_ext_precision,
                             min_acct_unit     => l_min_unit);

      print_debug(l_api_name || ' l_precision: ' || l_precision);
      print_debug(l_api_name || ' l_ext_precision: ' || l_ext_precision);
      print_debug(l_api_name || ' l_min_unit: ' || l_min_unit);

      x_transfer_price        := round(l_curr_rate * x_transfer_price, l_ext_precision);
      x_transfer_price_priuom := round(l_curr_rate * x_transfer_price_priuom, l_ext_precision);

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS )
      THEN
        --
        -- currency conversion error
        --
        RAISE e_currency_conversion_error;
      END IF;
    END IF;

    print_debug(l_api_name || ': Final Transfer Price in Txn/Pri UOM: ' || x_transfer_price ||'/'|| x_transfer_price_priuom);
    print_debug(l_api_name || ': Functional Currency Price (may be null if currConv is not called): ' || l_functional_currency_code);
    print_debug(l_api_name || ': all done! exiting...');

    -- x_transfer_price := l_transfer_price;
    x_currency_code  := l_functional_currency_code;


  EXCEPTION
    WHEN e_uom_conversion_error
    THEN
      FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_UOM_CONV');
      FND_MESSAGE.SET_TOKEN('VALUE1', p_transaction_uom);
      FND_MESSAGE.SET_TOKEN('VALUE2', g_primary_uom);
      FND_MSG_PUB.ADD;

      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN e_currency_conversion_error
    THEN
      print_debug('GMF_get_transfer_price_PUB.get_transfer_price: currency conversion error');
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
       print_debug('Exc_Unexpected_Error in GMF_get_transfer_price_PUB.get_transfer_price');
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
       x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);

    WHEN FND_API.G_EXC_ERROR
    THEN
       print_debug('EXC_ERROR in GMF_get_transfer_price_PUB.get_transfer_price: ' || x_msg_data);
       x_return_status := FND_API.G_RET_STS_ERROR;
       IF x_msg_data IS NULL
       THEN
         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
         x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);
       END IF;

    WHEN e_user_hook_error
    THEN
       print_debug('user hook returned Error: ' || x_msg_data);
       x_return_status := FND_API.G_RET_STS_ERROR;
       IF x_msg_data IS NULL
       THEN
         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
         x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);
       END IF;


    WHEN e_transfer_price_null_error
    THEN
       print_debug('transfer price is null: ' || x_msg_data);
       x_return_status := FND_API.G_RET_STS_ERROR;
       IF x_msg_data IS NULL
       THEN
         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
         x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);
       END IF;

    WHEN e_ignore_error
    THEN
       x_return_status := FND_API.G_RET_STS_SUCCESS;


    WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
       x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);

       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PACKAGE_NAME, l_api_name);
       end if;
       print_debug('When Other in GMF_get_transfer_price_PUB.get_transfer_price (sqlerrm): ' || sqlerrm);
       print_debug('When Other in GMF_get_transfer_price_PUB.get_transfer_price (backtrace): ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);

  END get_transfer_price;

  --
  -- Start of comments
  -- API name        : get_xfer_price_basic
  -- Type            : Public
  -- Pre-reqs        : None
  -- Parameters      :
  -- Version         : Current version 1.0
  --                   Initial version 1.0
  -- PURPOSE: Pseudo code
  --   Begin
  --     if (transfer type = 'INTCOM' then
  --       call transfer_price api for inter company
  --        i.e., INV_TRANSACTION_FLOW_PUB
  --       return;
  --     end if;
  --
  --     call the user hook
  --     -- either to get prior period cost as transfer price (supplied)
  --     -- or transfer price from user code, by commenting above code
  --
  --     if hook is successful then
  --       return transfer price
  --     end if;
  --
  --     get profile value for advance pricing for inter org transfers
  --     -- profile: INV_USE_QP_FOR_INTERORG
  --
  --     if (advance pricing enabled ) then
  --       call  price request engine call
  --       return transfer_price;
  --     end if;
  --
  --     get price from static price list
  --     -- defined in shipping networks for this item.
  --
  --     return transfer price;
  --
  --   end;
  -- End of comments

  Procedure get_xfer_price_basic (
      x_transfer_price       OUT NOCOPY NUMBER
    , x_transfer_price_code  OUT NOCOPY NUMBER
    , x_pricelist_currency   OUT NOCOPY VARCHAR2
    , x_return_status        OUT NOCOPY VARCHAR2
    , x_msg_count            OUT NOCOPY NUMBER
    , x_msg_data             OUT NOCOPY VARCHAR2
    )
  IS

    l_transfer_price        NUMBER;
    l_transfer_price_code   NUMBER;

    l_pricelist_id          NUMBER;
    l_pricelist_name        VARCHAR2(255);
    l_pricelist_currency    VARCHAR2(30);

    l_item_description      VARCHAR2(2000);
    l_primary_uom           VARCHAR2(4);

    l_uom_rate              NUMBER;

    l_api_name              VARCHAR2(50);

    e_price_list_not_found  exception;
    e_item_not_on_pricelist exception;

  BEGIN

    l_api_name := 'GMF_get_transfer_price_PUB.get_xfer_price_basic';

    print_debug('  ' || l_api_name || ': Basic pricing. Get price for item: ' || g_inventory_item_id ||
      ' org: ' || g_from_organization_id);
    --
    -- get price list id
    --
    BEGIN
      SELECT NVL(mip.pricelist_id,-1)
        INTO l_pricelist_Id
        FROM mtl_interorg_parameters mip
       WHERE mip.from_organization_id = g_from_organization_id
         AND mip.to_organization_id   = g_to_organization_id;

      IF ( l_pricelist_id = -1)
      THEN
        RAISE e_price_list_not_found;
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        RAISE e_price_list_not_found;
    END;

    print_debug('  ' || l_api_name || ': Price List Id is ' || l_pricelist_id);

    BEGIN
      --
      -- Get static price list in transaction uom
      --
      print_debug('  ' || l_api_name || ': Getting price using transaction uom: ' || g_transaction_uom);

      l_transfer_price_code := G_XFER_PRICE_IN_TXN_UOM; -- (1)

      SELECT spll.operand, substr(spl.currency_code, 1, 15)
        INTO l_transfer_price, l_pricelist_currency
        FROM qp_list_headers_b spl, qp_list_lines spll, qp_pricing_attributes qpa
       WHERE spl.list_header_id            = l_pricelist_id
         AND spll.list_header_id           = spl.list_header_id
         AND spll.list_line_id             = qpa.list_line_id
         AND qpa.product_attribute_context = 'ITEM'
         AND qpa.product_attribute         = 'PRICING_ATTRIBUTE1'
         AND qpa.product_attr_value        = to_Char(g_inventory_item_id)
         AND qpa.product_uom_code          = g_transaction_uom
         AND sysdate BETWEEN NVL(spll.start_date_active, (sysdate-1)) AND
                       NVL(spll.end_date_active+0.99999, (sysdate+1))
         AND rownum = 1
      ;

      print_debug('  ' || l_api_name || ': List Price: ' || l_transfer_price);

    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        --
        -- Get static price list in primary uom
        --
        BEGIN
          print_debug('  ' || l_api_name || ': Getting price using primary uom: ' || g_primary_uom);

          l_transfer_price_code := G_XFER_PRICE_IN_PRI_UOM; -- (2)

          SELECT spll.operand, substr(spl.currency_code, 1, 15), msi.primary_uom_code
            INTO l_transfer_price, l_pricelist_currency, l_primary_uom
            FROM qp_list_headers_b spl, qp_list_lines spll,
                 qp_pricing_attributes qpa, mtl_system_items_b msi
           WHERE msi.organization_id           = g_from_organization_id
             AND msi.inventory_item_id         = g_inventory_item_id
             AND spl.list_header_id            = l_pricelist_id
             AND spll.list_header_id           = spl.list_header_id
             AND qpa.list_header_id            = spl.list_header_id
             AND spll.list_line_id             = qpa.list_line_id
             AND qpa.product_attribute_context = 'ITEM'
             AND qpa.product_attribute         = 'PRICING_ATTRIBUTE1'
             AND qpa.product_attr_value        = to_char(msi.inventory_item_id)
             AND qpa.product_uom_code          = msi.primary_uom_code
             AND sysdate BETWEEN NVL(spll.start_date_active, (sysdate-1)) AND
                           NVL(spll.end_date_active + 0.99999, (sysdate+1))
             AND   rownum = 1
          ;

          print_debug('  ' || l_api_name || ': List Price: ' || l_transfer_price);

        EXCEPTION
          WHEN NO_DATA_FOUND
          THEN
            --
            -- Item not on pricelist
            --
            print_debug('  ' || l_api_name || ': item not on price list');
            RAISE e_item_not_on_pricelist;
        END;
    END;


   x_transfer_price      := l_transfer_price;
   x_transfer_price_code := l_transfer_price_code;
   x_pricelist_currency  := l_pricelist_currency;
   x_return_status       := FND_API.G_RET_STS_SUCCESS;

   print_debug('  ' || l_api_name || ': PriceList Currency: ' || l_pricelist_currency);
   print_debug('  ' || l_api_name || ': exiting...');

  EXCEPTION
    WHEN e_price_list_not_found
    THEN
      print_debug('  ' || l_api_name || ': PriceList not found!');
      -- l_transfer_price := -99;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MESSAGE.SET_NAME('GMF', 'IC-Price List Not Found');
      FND_MESSAGE.SET_TOKEN('FROM_ORG', g_from_organization_id);
      FND_MESSAGE.SET_TOKEN('TO_ORG', g_to_organization_id);
      FND_MSG_PUB.ADD;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);
      RAISE FND_API.G_EXC_ERROR;

    WHEN e_item_not_on_pricelist
    THEN
      print_debug('  ' || l_api_name || ': Item is not on price list!');
      -- l_transfer_price := -99;
      x_return_status  := FND_API.G_RET_STS_ERROR;

      SELECT concatenated_segments
        INTO l_item_description
        FROM mtl_system_items_kfv
       WHERE organization_id = g_from_organization_id
         AND  inventory_item_id = g_inventory_item_id;

      SELECT name
        INTO l_pricelist_name
        FROM QP_LIST_HEADERS
       WHERE list_header_id = l_pricelist_id;

      FND_MESSAGE.SET_NAME('QP', 'QP_PRC_NO_LIST_PRICE');
      FND_MESSAGE.SET_TOKEN('ITEM', l_item_description);
      FND_MESSAGE.SET_TOKEN('UNIT', g_primary_uom);
      FND_MESSAGE.SET_TOKEN('PRICE_LIST', l_pricelist_name);
      FND_MSG_PUB.ADD;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);
      RAISE FND_API.G_EXC_ERROR;

    WHEN OTHERS then
       print_debug('  ' || l_api_name || ': in When Others (sqlerrm): ' || substr(sqlerrm, 1, 200));
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
       x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PACKAGE_NAME, l_api_name);
       end if;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      /*
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
         x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);

      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
         print_debug('In EXC_ERROR ' || l_progress, 'Get_Transfer_Price');
         x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);
       */
  END get_xfer_price_basic;

  --
  -- Start of comments
  -- API name        : get_xfer_price_qp
  -- Type            : Public
  -- Pre-reqs        : None
  -- Parameters      :
  -- Version         : Current version 1.0
  --                   Initial version 1.0
  -- PURPOSE: Pseudo code
  --   Begin
  --     if (transfer type = 'INTCOM' then
  --       call transfer_price api for inter company
  --        i.e., INV_TRANSACTION_FLOW_PUB
  --       return;
  --     end if;
  --
  --     call the user hook
  --     -- either to get prior period cost as transfer price (supplied)
  --     -- or transfer price from user code, by commenting above code
  --
  --     if hook is successful then
  --       return transfer price
  --     end if;
  --
  --     get profile value for advance pricing for inter org transfers
  --     -- profile: INV_USE_QP_FOR_INTERORG
  --
  --     if (advance pricing enabled ) then
  --       call  price request engine call
  --       return transfer_price;
  --     end if;
  --
  --     get price from static price list
  --     -- defined in shipping networks for this item.
  --
  --     return transfer price;
  --
  --   end;
  -- End of comments

  Procedure get_xfer_price_qp (
      x_transfer_price      OUT NOCOPY NUMBER
    , x_currency_code       OUT NOCOPY VARCHAR2
    , x_transfer_price_code OUT NOCOPY NUMBER
    , x_return_status       OUT NOCOPY VARCHAR2
    , x_msg_data            OUT NOCOPY VARCHAR2
    , x_msg_count           OUT NOCOPY NUMBER
    )
  IS

    -- INTORD for Internal Orders
    -- INTORG for Inventory InterOrg Transfers

    l_header_id                     NUMBER;
    l_line_id                       NUMBER;
    l_inventory_item_id             NUMBER;
    l_organization_id               NUMBER;
    l_transaction_uom               VARCHAR2(3);
    l_Control_Rec                   QP_PREQ_GRP.CONTROL_RECORD_TYPE;
    l_pricing_event                 VARCHAR2(30); -- DEFAULT 'ICBATCH';
    l_request_type_code             VARCHAR2(30); -- DEFAULT 'INTORG'; -- 'INVXFR';
    l_line_index                    NUMBER := 0;
    l_return_status_Text            VARCHAR2(2000);
    l_version                       VARCHAR2(240);
    l_dir                           VARCHAR2(2000);
    l_tfrPrice                      NUMBER;
    l_uom_rate                      NUMBER;
    l_doc_type			    VARCHAR2(4); /* OPM Bug 2865040 */

    l_order_line_id     NUMBER;
    l_base_item_id	NUMBER;
    l_transaction_source_type_id NUMBER;
    l_transaction_action_id      NUMBER;

begin

    IF (l_debug = 1) THEN
       Print_debug('GMF_get_transfer_price_PUB.get_xfer_price_qp: xfr source: ' || g_xfer_source);
    END IF;

    -- QP: Pricing Transaction Entity  =>  Inter Organization Transfers for Internal Orders
    -- QP: Source System Code          =>  Oracle Inventory
    fnd_profile.put('QP_PRICING_TRANSACTION_ENTITY', 'INTCOM');
    fnd_profile.put('QP_SOURCE_SYSTEM_CODE', 'INV');

    l_request_type_code := 'INTORG';
    l_pricing_event     := 'ICBATCH';

    --
    -- First doing for Internal Orders
    -- For internal Order we will be reusing INV team API.
    -- For that to happen we need to send Request Type code.
    --
    IF g_xfer_source = 'INTORD'
    THEN

      -- l_request_type_code := 'INVIOT';

      INV_IC_ORDER_PUB.G_LINE.from_organization_id := g_from_organization_id;
      INV_IC_ORDER_PUB.G_LINE.to_organization_id   := g_to_organization_id;

      print_debug('GMF_get_transfer_price_PUB.get_xfer_price_qp: Calling MTL_QP_PRICE.get_transfer_price' ||
        ' with From Orgn: ' || g_from_organization_id ||
        ' To Orgn: ' || g_to_organization_id ||
        ' for order line id: ' || g_transaction_id ||
        ' itemID: ' || g_inventory_item_id);

      x_transfer_price := MTL_QP_PRICE.get_transfer_price(
                            p_transaction_id    => NULL,
                            p_sell_ou_id        => g_from_ou,
                            p_ship_ou_id        => g_to_ou,
                            p_order_line_id     => g_transaction_id,
                            p_inventory_item_id => g_inventory_item_id,
                            p_organization_id   => g_from_organization_id,
                            p_uom_code          => g_transaction_uom,
                            p_cto_item_flag     => 'N',
                            p_incr_code         => 1,
                            p_incrCurrency      => g_from_org_currency,
                            p_request_type_code => l_request_type_code,
                            p_pricing_event     => l_pricing_event,
                            x_currency_code     => x_currency_code,
                            x_tfrPriceCode      => x_transfer_price_code,
                            x_return_status     => x_return_status,
                            x_msg_count         => x_msg_count,
                            x_msg_data          => x_msg_data
                          );

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        IF (l_debug = 1) THEN
           print_debug('GMF_get_transfer_price_PUB.get_xfer_price_qp: MTL_QP_PRICE.get_transfer_price error ' );
           print_debug('GMF_get_transfer_price_PUB.get_xfer_price_qp: Error ='|| x_msg_data );
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      print_debug('GMF_get_transfer_price_PUB.get_xfer_price_qp: ' ||
        'Transfer Price from MTL_QP_PRICE.get_transfer_price: ' || x_transfer_price);

    ELSIF g_xfer_source in ('INTORG', 'INTREQ')
    THEN
      --
      -- set QP profile to force Inter-Org context.
      -- For intercompany, this profile will be honored, but
      -- not for inter-org transfers
      --

      -- l_request_type_code := 'INVXFR';

      IF (l_debug = 1) THEN
         Print_debug('GMF_get_transfer_price_PUB.get_xfer_price_qp:: Selecting Line Identifier...');
      END IF;

      -- l_organization_id            := g_from_organization_id;
      l_transaction_uom            := g_transaction_uom;
      -- l_inventory_item_id          := g_inventory_item_id;
      -- l_line_id                    := NULL;
      -- l_transaction_source_type_id := 13;
      -- l_transaction_action_id      := 21;

      /*
      G_Hdr_Initialize;

      -- Header
      copy_Header_to_request( p_header_rec             => INV_IC_ORDER_PUB.g_txn_hdr
                              , p_Request_Type_Code    => l_request_type_code
                              , px_line_index          => l_line_index );

      IF (l_debug = 1) THEN
         Print_debug('GMF_get_transfer_price_PUB.get_xfer_price_qp: Build Context for header...');
      END IF;

      QP_Attr_Mapping_PUB.Build_Contexts(
          p_request_type_code  => l_request_type_code
        , p_pricing_type_code  => 'H'
        , p_line_index         => INV_IC_ORDER_PUB.g_txn_hdr.dummy );
      */

      IF (l_debug = 1) THEN
         Print_debug('GMF_get_transfer_price_PUB.get_xfer_price_qp: calling G_Line_Initialize...');
      END IF;

      G_Line_Initialize;
      QP_price_request_context.set_request_id;

      IF (l_debug = 1) THEN
         Print_debug('GMF_get_transfer_price_PUB.get_xfer_price_qp: calling copy_Line_to_request...');
      END IF;

      --
      -- Copy line to request
      --
      copy_Line_to_request( p_Line_rec            => INV_IC_ORDER_PUB.g_line
                            , p_pricing_events    => l_pricing_event
                            , p_request_type_code => l_request_type_code
                            , px_line_index       => l_line_index );


      --
      -- Build Context
      --
      IF (l_debug = 1) THEN
         Print_debug('GMF_get_transfer_price_PUB.get_xfer_price_qp: Build Context for line...');
      END IF;

      QP_Attr_Mapping_PUB.Build_Contexts(
          p_request_type_code => l_request_type_code
        , p_pricing_type_code => 'L'
        , p_line_index        => g_inventory_item_id + g_from_organization_id + g_to_organization_id);


      --
      -- Populate temp table
      --
      IF l_line_index > 0 THEN
          IF (l_debug = 1) THEN
             Print_debug('GMF_get_transfer_price_PUB.get_xfer_price_qp: Populating Lines temp table...');
          END IF;
          Populate_Temp_Table(x_return_status);
      END IF;

      --
      -- Initializing control record
      --
      IF (l_debug = 1) THEN
         Print_debug('GMF_get_transfer_price_PUB.get_xfer_price_qp: Initializing control record...');
      END IF;

      l_control_rec.pricing_event          := l_pricing_event;
      l_control_rec.calculate_flag         := qp_preq_grp.G_SEARCH_N_CALCULATE;
      l_control_rec.temp_table_insert_flag := 'N';
      l_control_rec.request_type_code      := l_request_type_code;
      l_control_rec.rounding_flag          := 'Y';
      l_control_rec.USE_MULTI_CURRENCY     := 'Y';

      --
      -- All set. Call Adv. Pricing Engine.
      --
      IF (l_debug = 1) THEN
         Print_debug('GMF_get_transfer_price_PUB.get_xfer_price_qp: Calling QP:Price Request routine ...');
      END IF;

      QP_PREQ_PUB.PRICE_REQUEST( p_control_rec          => l_control_rec
                                 , x_return_status      => x_return_status
                                 , x_return_status_Text => l_return_status_Text);

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          IF (l_debug = 1) THEN
             print_debug('GMF_get_transfer_price_PUB.get_xfer_price_qp: QP_PREQ_PUB.PRICE_REQUEST error ' );
             print_debug('GMF_get_transfer_price_PUB.get_xfer_price_qp: x_return_status_text='|| l_return_status_text );
          END IF;
          fnd_message.set_name('INV', 'INV_UNHANDLED_ERR');
          fnd_message.set_token('ENTITY1', 'QP_PREQ_PUB.PRICE_REQUEST');
          fnd_message.set_token('ENTITY2', substr(l_return_status_text, 1, 150) );
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (l_debug = 1) THEN
         Print_debug('GMF_get_transfer_price_PUB.get_xfer_price_qp: Populating QP results ...');
      END IF;

      --
      -- Populating results
      --
      Populate_Results (l_line_index, x_return_status, x_msg_data);

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      x_currency_code  := G_CURRENCY_CODE_TBL(l_line_index);
      x_transfer_price := G_UNIT_SELLING_PRICE_TBL(l_line_index);

      IF G_PRICED_UOM_CODE_TBL(l_line_index) = l_transaction_uom
      THEN
          x_transfer_price_code := 1;
      ELSIF G_PRICED_UOM_CODE_TBL(l_line_index) = g_primary_uom
      THEN
          x_transfer_price_code := 2;
      ELSE
          x_transfer_price_code := 1;
      END IF;


      IF (l_debug = 1)
      THEN
         Print_debug('Transfer Price='|| to_char(x_transfer_price));
         Print_debug('UOM='|| G_PRICED_UOM_CODE_TBL(l_line_index));
      END IF;

    END IF;  -- IF g_xfer_source = 'INTORG'


  EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
        IF (l_debug = 1)
        THEN
           print_debug('GMF_get_transfer_price_PUB.get_xfer_price_qp: EXCEP NO_DATA_FOUND ' );
        END IF;
        fnd_message.set_name('INV', 'INV_NO_DATA_EXISTS');

    WHEN FND_API.G_EXC_ERROR
    THEN
        IF (l_debug = 1)
        THEN
           print_debug('GMF_get_transfer_price_PUB.get_xfer_price_qp: EXCEP G_EXC_ERROR ' );
        END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
        IF (l_debug = 1)
        THEN
           print_debug('GMF_get_transfer_price_PUB.get_xfer_price_qp: EXCEP G_EXC_UNEXPECTED_ERROR ' );
        END IF;
    WHEN OTHERS
    THEN
        IF (l_debug = 1)
        THEN
           print_debug('GMF_get_transfer_price_PUB.get_xfer_price_qp: EXCEP UNEXP OTHERS - ' || sqlerrm);
        END IF;
  END get_xfer_price_qp;

--
-- Not being used currently
--
PROCEDURE G_Hdr_Initialize
IS
BEGIN

    -- x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Header population
    IF (l_debug = 1) THEN
       print_debug('GMF_get_transfer_price_PUB.G_Hdr_Initialize: Populating G_HDR...');
    END IF;

    --
    -- For InterOrg Transfers header is not supported.
    -- For Adv Pricing setup purpose we've to create one. So, we created
    -- a dummy header
    --
    -- INV_IC_ORDER_PUB.G_TXN_HDR.dummy := 1;

EXCEPTION
    WHEN OTHERS THEN
        -- x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF (l_debug = 1) THEN
           print_debug('GMF_get_transfer_price_PUB.G_Hdr_Initialize: EXCEP UNEXP OTHERS - ' || sqlerrm);
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END G_Hdr_Initialize;


PROCEDURE G_Line_Initialize
IS
BEGIN

    --  Line population
    IF (l_debug = 1) THEN
       print_debug('GMF_get_transfer_price_PUB.G_Line_Initialize: Populating G_LINE...');
    END IF;

    INV_IC_ORDER_PUB.G_LINE.from_organization_id     := G_from_organization_id;
    INV_IC_ORDER_PUB.G_LINE.to_organization_id       := G_to_organization_id;

    INV_IC_ORDER_PUB.G_LINE.from_ou                  := G_from_ou;
    INV_IC_ORDER_PUB.G_LINE.to_ou                    := G_to_ou;

    INV_IC_ORDER_PUB.G_LINE.inventory_item_id        := G_inventory_item_id;
    INV_IC_ORDER_PUB.G_LINE.ordered_quantity         := G_transaction_qty;
    INV_IC_ORDER_PUB.G_LINE.order_quantity_uom       := G_transaction_uom;
    INV_IC_ORDER_PUB.G_LINE.primary_uom              := G_primary_uom;

    INV_IC_ORDER_PUB.G_LINE.calculate_price_flag     := 'Y';

    IF (l_debug = 1) THEN
       print_debug('GMF_get_transfer_price_PUB.G_Line_Initialize: item/qty/uom: ' ||
         INV_IC_ORDER_PUB.G_LINE.inventory_item_id ||'/'|| INV_IC_ORDER_PUB.G_LINE.ordered_quantity ||'/'||
         INV_IC_ORDER_PUB.G_LINE.order_quantity_uom);
    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        -- x_return_status := FND_API.G_RET_STS_ERROR;
        IF (l_debug = 1) THEN
           print_debug('GMF_get_transfer_price_PUB.G_Line_Initialize: EXCEP NO_DATA_FOUND ' );
        END IF;
        RAISE NO_DATA_FOUND;
    WHEN OTHERS THEN
        -- x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF (l_debug = 1) THEN
           print_debug('GMF_get_transfer_price_PUB.G_Line_Initialize: EXCEP UNEXP OTHERS - ' || sqlerrm);
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END G_Line_Initialize;


--
-- Not being used currently
--
PROCEDURE copy_Header_to_request( p_header_rec             INV_IC_ORDER_PUB.Header_Rec_Type
                                  , p_Request_Type_Code    VARCHAR2
                                  , px_line_index   	     IN OUT NOCOPY NUMBER )
IS
BEGIN

    px_line_index := px_line_index+1;

    G_REQUEST_TYPE_CODE_TBL(px_line_index) := p_Request_Type_Code;
    G_PRICE_REQUEST_CODE_TBL(px_line_index) := p_Request_Type_Code;
    -- G_LINE_INDEX_tbl(px_line_index) := p_Header_rec.dummy;
    G_LINE_TYPE_CODE_TBL(px_line_index) := 'ORDER';

    --  Hold the header_id in line_id for 'HEADER' Records
    -- G_LINE_ID_TBL(px_line_index) := p_Header_rec.dummy;

    G_PRICING_EFFECTIVE_DATE_TBL(px_line_index) := trunc(SYSDATE);

    G_CURRENCY_CODE_TBL(px_line_index) := NULL;
    G_PROCESSED_FLAG_TBL(px_line_index) := QP_PREQ_GRP.G_NOT_PROCESSED;
    G_PRICING_STATUS_CODE_tbl(px_line_index) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
    G_USAGE_PRICING_TYPE_TBL(px_line_index) := 'REGULAR';

    G_PRICE_FLAG_TBL(px_line_index) := 'Y';
    G_QUALIFIERS_EXIST_FLAG_TBL(px_line_index) :='N';
    G_PRICING_ATTRS_EXIST_FLAG_TBL(px_line_index) :='N';
    G_ROUNDING_FLAG_TBL(px_line_index) := 'Y';

    G_ACTIVE_DATE_FIRST_TYPE_TBL(px_line_index) := NULL;
    G_ACTIVE_DATE_FIRST_TBL(px_line_index) := NULL;
    G_ACTIVE_DATE_SECOND_TBL(px_line_index) := NULL;
    G_ACTIVE_DATE_SECOND_TYPE_TBL(px_line_index) := NULL;

    G_ROUNDING_FACTOR_TBL(px_line_index) := NULL;
    G_PROCESSING_ORDER_TBL(px_line_index) := NULL;
    G_PRICING_STATUS_TEXT_tbl(px_line_index) := NULL;
    G_PRICE_LIST_ID_TBL(px_line_index) := NULL;
    G_PL_VALIDATED_FLAG_TBL(px_line_index) := 'N';
    G_UPD_ADJUSTED_UNIT_PRICE_TBL(px_line_index) := NULL;
    G_LINE_QUANTITY_TBL(px_line_index) := NULL;
    G_LINE_UOM_CODE_TBL(px_line_index) := NULL;
    G_PRICED_QUANTITY_TBL(px_line_index) := NULL;
    G_UOM_QUANTITY_TBL(px_line_index) := NULL;
    G_PRICED_UOM_CODE_TBL(px_line_index) := NULL;
    G_UNIT_PRICE_TBL(px_line_index) := NULL;
    G_PERCENT_PRICE_TBL(px_line_index) := NULL;
    G_ADJUSTED_UNIT_PRICE_TBL(px_line_index) := NULL;

    G_LINE_CATEGORY_TBL(px_line_index) := NULL;

END copy_Header_to_request;


PROCEDURE copy_Line_to_request ( p_Line_rec          IN INV_IC_ORDER_PUB.Line_Rec_Type
                               , p_pricing_events    IN VARCHAR2
                               , p_request_type_code IN VARCHAR2
                               , px_line_index       IN OUT NOCOPY NUMBER )
IS
    l_uom_rate      NUMBER;
BEGIN

    px_line_index := px_line_index+1;

    G_REQUEST_TYPE_CODE_TBL(px_line_index)  := p_Request_Type_Code;
    G_PRICE_REQUEST_CODE_TBL(px_line_index) := p_Request_Type_Code;

    G_LINE_ID_TBL(px_line_index)        := px_line_index;
    G_LINE_INDEX_tbl(px_line_index)     := G_inventory_item_id + G_from_organization_id + G_to_organization_id;
    G_LINE_TYPE_CODE_TBL(px_line_index) := 'LINE';

    G_LINE_QUANTITY_TBL(px_line_index) := g_transaction_qty;
    G_LINE_UOM_CODE_TBL(px_line_index) := g_transaction_uom;
    G_CURRENCY_CODE_TBL(px_line_index) := g_from_org_currency;

    G_PRICED_QUANTITY_TBL(px_line_index) := g_transaction_qty;
    G_PRICED_UOM_CODE_TBL(px_line_index) := g_transaction_uom;

    G_PROCESSED_FLAG_TBL(px_line_index)      := QP_PREQ_GRP.G_NOT_PROCESSED;
    G_PRICING_STATUS_CODE_TBL(px_line_index) := QP_PREQ_GRP.G_STATUS_UNCHANGED;

    G_PRICE_FLAG_TBL(px_line_index)               := 'Y';
    G_ROUNDING_FLAG_TBL(px_line_index)            := 'Y';
    G_QUALIFIERS_EXIST_FLAG_TBL(px_line_index)    := 'N';
    G_PRICING_ATTRS_EXIST_FLAG_TBL(px_line_index) := 'N';
    G_PL_VALIDATED_FLAG_TBL(px_line_index)        := 'N';
    G_USAGE_PRICING_TYPE_TBL(px_line_index)       := 'REGULAR';
    G_PRICING_EFFECTIVE_DATE_TBL(px_line_index)   := trunc(SYSDATE);

    --
    -- All the following are not applicable for us
    --
    G_PERCENT_PRICE_TBL(px_line_index)   := NULL;

    G_ACTIVE_DATE_FIRST_TYPE_TBL(px_line_index)  := NULL;
    G_ACTIVE_DATE_FIRST_TBL(px_line_index)       := NULL;
    G_ACTIVE_DATE_SECOND_TBL(px_line_index)      := NULL;
    G_ACTIVE_DATE_SECOND_TYPE_TBL(px_line_index) := NULL;

    G_ROUNDING_FACTOR_TBL(px_line_index)         := NULL;
    G_PROCESSING_ORDER_TBL(px_line_index)        := NULL;
    G_PRICING_STATUS_TEXT_tbl(px_line_index)     := NULL;
    G_UPD_ADJUSTED_UNIT_PRICE_TBL(px_line_index) := NULL;

    G_PRICE_LIST_ID_TBL(px_line_index)           := NULL;
    G_UOM_QUANTITY_TBL(px_line_index)            := NULL;
    G_UNIT_PRICE_TBL(px_line_index)              := NULL;
    G_ADJUSTED_UNIT_PRICE_TBL(px_line_index)     := NULL;
    G_LINE_CATEGORY_TBL(px_line_index)           := NULL;

END copy_Line_to_request;


PROCEDURE Populate_Temp_Table ( x_return_status OUT NOCOPY VARCHAR2 )
IS
    l_return_status      VARCHAR2(1);
    l_return_status_Text VARCHAR2(2000) ;
    i number :=0;
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    print_debug('G_LINE_INDEX_TBL.count: ' || G_LINE_INDEX_TBL.count);
    FOR i IN G_LINE_INDEX_TBL.FIRST..G_LINE_INDEX_TBL.LAST
    LOOP
       IF (l_debug = 1) THEN
          print_debug('i = ' || i);
          print_debug(G_LINE_TYPE_CODE_TBL(i));
          print_debug('-----------------------------------------------');
          print_debug('line_index               => '||to_char(G_LINE_INDEX_TBL(i)));
          print_debug('pricing_effective_date   => '||to_char(G_PRICING_EFFECTIVE_DATE_TBL(i)));
          print_debug('active_date_first        => '||to_char(G_ACTIVE_DATE_FIRST_TBL(i)));
          print_debug('active_date_first_type   => '||G_ACTIVE_DATE_FIRST_TYPE_TBL(i));
          print_debug('active_date_second       => '||to_char(G_ACTIVE_DATE_SECOND_TBL(i)));
          print_debug('active_date_second_type  => '||G_ACTIVE_DATE_SECOND_TYPE_TBL(i));
          print_debug('line_quantity            => '||to_char(G_LINE_QUANTITY_TBL(i)));
          print_debug('line_uom_code            => '||G_LINE_UOM_CODE_TBL(i));
          print_debug('request_type_code        => '||G_REQUEST_TYPE_CODE_TBL(i));
          print_debug('PRICED_QUANTITY          => '||to_char(G_PRICED_QUANTITY_TBL(i)));
          print_debug('PRICED_UOM_CODE          => '||G_PRICED_UOM_CODE_TBL(i));
          print_debug('CURRENCY_CODE            => '||G_CURRENCY_CODE_TBL(i));
          -- print_debug('UNIT_PRICE               => '||to_char(G_UNIT_PRICE_TBL(i)));
          -- print_debug('PERCENT_PRICE            => '||to_char(G_PERCENT_PRICE_TBL(i)));
          print_debug('UOM_QUANTITY             => '||to_char(G_UOM_QUANTITY_TBL(i)));
          -- print_debug('ADJUSTED_UNIT_PRICE      => '||to_char(G_ADJUSTED_UNIT_PRICE_TBL(i)));
          -- print_debug('UPD_ADJUSTED_UNIT_PRICE  => '||to_char(G_UPD_ADJUSTED_UNIT_PRICE_TBL(i)));
          print_debug('PROCESSED_FLAG           => '||G_PROCESSED_FLAG_TBL(i));
          print_debug('price_flag               => '||G_PRICE_FLAG_TBL(i));
          print_debug('LINE_ID                  => '||to_char(G_LINE_ID_TBL(i)));
          -- print_debug('PROCESSING_ORDER         => '||to_char(G_PROCESSING_ORDER_TBL(i)));
          print_debug('pricing_status_code      => '||substr(G_PRICING_STATUS_CODE_TBL(i), 1, 5));
          print_debug('PRICING_STATUS_TEXT      => '||G_PRICING_STATUS_TEXT_TBL(i));
          print_debug('ROUNDING_FLAG            => '||G_ROUNDING_FLAG_TBL(i));
          -- print_debug('ROUNDING_FACTOR          => '||to_char(G_ROUNDING_FACTOR_TBL(i)));
          print_debug('QUALIFIERS_EXIST_FLAG    => '||G_QUALIFIERS_EXIST_FLAG_TBL(i));
          print_debug('PRICING_ATTRS_EXIST_FLAG => '||G_PRICING_ATTRS_EXIST_FLAG_TBL(i));
          print_debug('PRICE_LIST_ID            => '||to_char(G_PRICE_LIST_ID_TBL(i)));
          print_debug('VALIDATED_FLAG           => '||G_PL_VALIDATED_FLAG_TBL(i));
          print_debug('PRICE_REQUEST_CODE       => '||G_PRICE_REQUEST_CODE_TBL(i));
          print_debug('USAGE_PRICING_TYPE       => '||G_USAGE_PRICING_TYPE_TBL(i));
          print_debug('LINE_CATEGORY            => '||G_LINE_CATEGORY_TBL(i));
       END IF;
    END LOOP;

    IF (l_debug = 1) THEN
       print_debug('GMF_get_transfer_price_PUB.Populate_Temp_Table: Calling QP:Bulk insert routine...' );
    END IF;

    QP_PREQ_GRP.INSERT_LINES2 (
                 p_LINE_INDEX               => G_LINE_INDEX_TBL,
                 p_LINE_TYPE_CODE           => G_LINE_TYPE_CODE_TBL,
                 p_PRICING_EFFECTIVE_DATE   => G_PRICING_EFFECTIVE_DATE_TBL,
                 p_ACTIVE_DATE_FIRST        => G_ACTIVE_DATE_FIRST_TBL,
                 p_ACTIVE_DATE_FIRST_TYPE   => G_ACTIVE_DATE_FIRST_TYPE_TBL,
                 p_ACTIVE_DATE_SECOND       => G_ACTIVE_DATE_SECOND_TBL,
                 p_ACTIVE_DATE_SECOND_TYPE  => G_ACTIVE_DATE_SECOND_TYPE_TBL,
                 p_LINE_QUANTITY            => G_LINE_QUANTITY_TBL,
                 p_LINE_UOM_CODE            => G_LINE_UOM_CODE_TBL,
                 p_REQUEST_TYPE_CODE        => G_REQUEST_TYPE_CODE_TBL,
                 p_PRICED_QUANTITY          => G_PRICED_QUANTITY_TBL,
                 p_PRICED_UOM_CODE          => G_PRICED_UOM_CODE_TBL,
                 p_CURRENCY_CODE            => G_CURRENCY_CODE_TBL,
                 p_UNIT_PRICE               => G_UNIT_PRICE_TBL,
                 p_PERCENT_PRICE            => G_PERCENT_PRICE_TBL,
                 p_UOM_QUANTITY             => G_UOM_QUANTITY_TBL,
                 p_ADJUSTED_UNIT_PRICE      => G_ADJUSTED_UNIT_PRICE_TBL,
                 p_UPD_ADJUSTED_UNIT_PRICE  => G_UPD_ADJUSTED_UNIT_PRICE_TBL,
                 p_PROCESSED_FLAG           => G_PROCESSED_FLAG_TBL,
                 p_PRICE_FLAG               => G_PRICE_FLAG_TBL,
                 p_LINE_ID                  => G_LINE_ID_TBL,
                 p_PROCESSING_ORDER         => G_PROCESSING_ORDER_TBL,
                 p_PRICING_STATUS_CODE      => G_PRICING_STATUS_CODE_TBL,
                 p_PRICING_STATUS_TEXT      => G_PRICING_STATUS_TEXT_TBL,
                 p_ROUNDING_FLAG            => G_ROUNDING_FLAG_TBL,
                 p_ROUNDING_FACTOR          => G_ROUNDING_FACTOR_TBL,
                 p_QUALIFIERS_EXIST_FLAG    => G_QUALIFIERS_EXIST_FLAG_TBL,
                 p_PRICING_ATTRS_EXIST_FLAG => G_PRICING_ATTRS_EXIST_FLAG_TBL,
                 p_PRICE_LIST_ID            => G_PRICE_LIST_ID_TBL,
                 p_VALIDATED_FLAG           => G_PL_VALIDATED_FLAG_TBL,
                 p_PRICE_REQUEST_CODE       => G_PRICE_REQUEST_CODE_TBL,
                 p_USAGE_PRICING_TYPE       => G_USAGE_PRICING_TYPE_TBL,
                 p_LINE_CATEGORY            => G_LINE_CATEGORY_TBL,
                 x_status_code              => l_return_status,
                 x_status_text              => l_return_status_text );

    print_debug('GMF_get_transfer_price_PUB.Populate_Temp_Table: after QP:Bulk insert routine...' );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        IF (l_debug = 1) THEN
           print_debug('GMF_get_transfer_price_PUB.Populate_Temp_Table: QP_PREQ_GRP.INSERT_LINES2 error ' );
           print_debug('GMF_get_transfer_price_PUB.Populate_Temp_Table: x_return_status_text='|| l_return_status_text );
        END IF;
        x_return_status := l_return_status;
        fnd_message.set_name('INV', 'INV_UNHANDLED_ERR');
        fnd_message.set_token('ENTITY1', 'QP_PREQ_GRP.INSERT_LINES2');
        fnd_message.set_token('ENTITY2', substr(l_return_status_text, 1, 150) );
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    SELECT count(*)
    INTO   i
    FROM   qp_preq_lines_tmp;

    IF (l_debug = 1) THEN
       print_debug('GMF_get_transfer_price_PUB.Populate_Temp_Table: No. of records inserted in QP_PREQ_LINES_TMP=' || to_char(i));
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF (l_debug = 1) THEN
           print_debug('GMF_get_transfer_price_PUB.Populate_Temp_Table: EXCEP UNEXP OTHERS - ' || sqlerrm);
        END IF;

END Populate_Temp_Table;


PROCEDURE Populate_Results(
  p_line_index    IN         NUMBER
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_data      OUT NOCOPY VARCHAR2
)
IS
    i number :=0;
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FOR i IN G_LINE_INDEX_TBL.FIRST..G_LINE_INDEX_TBL.LAST
    LOOP
        BEGIN
            SELECT lines.ADJUSTED_UNIT_PRICE
                , lines.UNIT_PRICE
                , lines.ADJUSTED_UNIT_PRICE
                , lines.UNIT_PRICE
                , lines.priced_quantity
                , lines.priced_uom_code
                , lines.price_list_header_id
                , nvl(lines.percent_price, NULL)
                , nvl(lines.parent_price, NULL)
                , decode(lines.parent_price, NULL, 0, 0, 0, lines.adjusted_unit_price/lines.parent_price)
                , lines.currency_code
                , lines.pricing_status_code
                , lines.pricing_status_text
            INTO  G_UNIT_SELLING_PRICE_TBL(i)
                , G_UNIT_LIST_PRICE_TBL(i)
                , G_UNIT_SELL_PRICE_PER_PQTY_TBL(i)
                , G_UNIT_LIST_PRICE_PER_PQTY_TBL(i)
                , G_PRICING_QUANTITY_TBL(i)
                , G_PRICED_UOM_CODE_TBL(i)
                , G_PRICE_LIST_ID_TBL(i)
                , G_UNIT_LIST_PERCENT_TBL(i)
                , G_UNIT_PERCENT_BASE_PRICE_TBL(i)
                , G_UNIT_SELLING_PERCENT_TBL(i)
                , G_CURRENCY_CODE_TBL(i)
                , G_PRICING_STATUS_CODE_TBL(i)
                , G_PRICING_STATUS_TEXT_TBL(i)
            FROM  qp_preq_lines_tmp lines
            WHERE lines.line_id=G_LINE_ID_TBL(i);

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                IF G_LINE_TYPE_CODE_TBL(i) = 'LINE' THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF (l_debug = 1) THEN
                       print_debug('GMF_get_transfer_price_PUB.Populate_Results: UNIT PRICE NOT POPULATED');
                    END IF;
                ELSE
                    IF (l_debug = 1) THEN
                       print_debug('GMF_get_transfer_price_PUB.Populate_Results: ' || G_LINE_TYPE_CODE_TBL(i) || ' NO_DATA_FOUND');
                    END IF;
                END IF;

            WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF (l_debug = 1) THEN
                   print_debug('GMF_get_transfer_price_PUB.Populate_Results: ' || sqlerrm );
                END IF;
                RAISE;
        END;

        IF G_LINE_TYPE_CODE_TBL(i) = 'LINE' THEN
          IF G_PRICING_STATUS_CODE_TBL(i) = QP_PREQ_GRP.G_STATUS_UPDATED THEN
            IF (l_debug = 1) THEN
              print_debug('GMF_get_transfer_price_PUB.Populate_Results: Unit_Price=' || G_UNIT_SELLING_PRICE_TBL(i));
            END IF;
          ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_data      := G_PRICING_STATUS_TEXT_TBL(i);

            IF (l_debug = 1) THEN
              print_debug('GMF_get_transfer_price_PUB.Populate_Results: Status_Code=' || G_PRICING_STATUS_CODE_TBL(i) ||
                            ' Status_Text=' || G_PRICING_STATUS_TEXT_TBL(i));
            END IF;
          END IF;
        END IF;

    END LOOP;

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR i IN G_LINE_INDEX_TBL.FIRST..G_LINE_INDEX_TBL.LAST
    LOOP
        IF (l_debug = 1) THEN
           print_debug(G_LINE_TYPE_CODE_TBL(i));
           print_debug('-----------------------------------------------');
           print_debug('PRICING_STATUS_CODE      => ' || G_UNIT_SELLING_PERCENT_TBL(i));
           print_debug('UNIT_SELLING_PRICE       => ' || to_char(G_UNIT_SELLING_PRICE_TBL(i)));
           print_debug('UNIT_LIST_PRICE          => ' || to_char(G_UNIT_LIST_PRICE_TBL(i)));
           print_debug('UNIT_SELL_PRICE_PER_PQTY => ' || to_char(G_UNIT_SELL_PRICE_PER_PQTY_TBL(i)));
           print_debug('UNIT_LIST_PRICE_PER_PQTY => ' || to_char(G_UNIT_LIST_PRICE_PER_PQTY_TBL(i)));
           print_debug('PRICING_QUANTITY         => ' || to_char(G_PRICING_QUANTITY_TBL(i)));
           print_debug('PRICING_QUANTITY_UOM     => ' || G_PRICED_UOM_CODE_TBL(i));
           print_debug('PRICE_LIST_ID            => ' || to_char(G_PRICE_LIST_ID_TBL(i)));
           print_debug('UNIT_LIST_PERCENT        => ' || to_char(G_UNIT_LIST_PERCENT_TBL(i)));
           print_debug('UNIT_PERCENT_BASE_PRICE  => ' || to_char(G_UNIT_PERCENT_BASE_PRICE_TBL(i)));
           print_debug('UNIT_SELLING_PERCENT     => ' || to_char(G_UNIT_SELLING_PERCENT_TBL(i)));
           print_debug('CURRENCY_CODE            => ' || G_CURRENCY_CODE_TBL(i));
        END IF;
    END LOOP;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR
    THEN
      print_debug('EXC_ERROR in GMF_get_transfer_price_PUB.Populate_Results');
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;

    WHEN OTHERS
    THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF (l_debug = 1) THEN
        print_debug('GMF_get_transfer_price_PUB.Populate_Results: EXCEP UNEXP OTHERS - ' || sqlerrm);
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Populate_Results;

END GMF_get_transfer_price_PUB;

/
