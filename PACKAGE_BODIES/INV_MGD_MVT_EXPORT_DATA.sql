--------------------------------------------------------
--  DDL for Package Body INV_MGD_MVT_EXPORT_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MGD_MVT_EXPORT_DATA" AS
-- $Header: INVIDEPB.pls 120.4 2006/05/25 18:10:03 yawang noship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVIDEPB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Package body of generating export data                            |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Generate_Export_Data                                              |
--|                                                                       |
--| HISTORY                                                               |
--|     10/12/01 yawang        Created                                    |
--|     10/23/01 yawang        Modified, add new parameters: legal entity |
--|                            zone code, usage type, stat type and period|
--|                            name                                       |
--|     03/15/02 yawang        Add two new parameters currency code and   |
--|                            exchange rate                              |
--|     12/03/02 vma           Add NOCOPY to OUT parameters to comply     |
--|                            with new PL/SQL standards for better       |
--|                            performance.                               |
--+========================================================================

--===================
-- GLOBALS
--===================

G_PKG_NAME CONSTANT    VARCHAR2(30) := 'INV_MGD_MVT_EXPORT_DADA';
G_MODULE_NAME CONSTANT VARCHAR2(100) := 'inv.plsql.INV_MGD_MVT_EXPORT_DADA.';

--========================================================================
-- PROCEDURE : Generate_Export_Data   PUBLIC
--
-- PARAMETERS: x_return_status         Procedure return status
--             x_msg_count             Number of messages in the list
--             x_msg_data              Message text
--             p_api_version_number    Known Version Number
--             p_init_msg_list         Empty PL/SQL Table list for
--                                     Initialization
--
--             p_legal_entity_id       Legal Entity
--             p_zone_code             Economic Zone
--             p_usage_type            Usage Type
--             p_stat_type             Statistical Type
--             p_period_name           Period Name
--             p_movement_type         Movement Type
--             p_currency_code         The currency in which user want to see
--                                     the statistic value
--             p_exchange_rate         The exchange rate for the currency code
--                                     user selected
--             p_amount_display        Display whole number or of currency precision
--
-- VERSION   : current version         1.0
--             initial version         1.0
--
-- COMMENT   : Procedure specification
--             to generate flat data file used in IDEP
--
-- Updated   :  15/Mar/2002
--=======================================================================--

PROCEDURE Generate_Export_Data
( p_api_version_number   IN  NUMBER
, p_init_msg_list        IN  VARCHAR2
, p_legal_entity_id      IN  NUMBER
, p_zone_code            IN  VARCHAR2
, p_usage_type           IN  VARCHAR2
, p_stat_type            IN  VARCHAR2
, p_movement_type        IN  VARCHAR2
, p_period_name          IN  VARCHAR2
, p_amount_display       IN  VARCHAR2
, p_currency_code        IN  VARCHAR2
, p_exchange_rate_char   IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
)
IS
  l_api_version_number   CONSTANT NUMBER       := 1.0;
  l_api_name             CONSTANT VARCHAR2(30) := 'Generate_Export_Data';

  l_base_currency              VARCHAR2(3);
  l_cons_country               VARCHAR2(2);
  l_cons_eu_country            VARCHAR2(3);
  l_invoice_num                VARCHAR2(50);
  l_invoice_currency           VARCHAR2(3);
  l_process_rec_count          NUMBER := 0;
  l_invoice_value_foreign      NUMBER;
  l_invoice_curr_foreign       VARCHAR2(3);
  l_invoice_value_local        NUMBER;
  l_invoice_value_calc         NUMBER;
  l_stat_ext_val_conv          VARCHAR2(50);
  l_invoice_val_loc_conv       VARCHAR2(50);
  l_invoice_val_fore_conv      VARCHAR2(50);
  l_total_weight_conv          VARCHAR2(50);
  l_exchange_rate              NUMBER;
  l_nls_numeric_char           VARCHAR2(50);
  l_alt_qty_conv               VARCHAR2(50);
  l_precision                  NUMBER;
  l_weight_precision           NUMBER;
  l_round_total_weight         NUMBER;
  l_round_stat_ext_value       NUMBER;
  l_round_invoice_value        NUMBER;
  l_round_alternate_qty        NUMBER;
  l_rounding_precision         NUMBER;
  l_rounding_method            VARCHAR2(30);
  l_format_mask                VARCHAR2(50);
  l_weight_format_mask         VARCHAR2(50);

  /*CURSOR c_precision IS
  SELECT
    NVL(precision,2)
  FROM
    fnd_currencies
  WHERE currency_code = l_invoice_currency;*/

  --Get report currency precision
  CURSOR c_rep_curr_precision IS
  SELECT
    NVL(precision,2)
  FROM
    fnd_currencies
  WHERE currency_code = p_currency_code;

  CURSOR c_mvt IS
  SELECT
    commodity_code
  , transaction_nature
  , transport_mode
  , port
  , statistical_procedure_code
  , total_weight
  , alternate_quantity
  , dispatch_territory_code
  , dispatch_territory_eu_code
  , destination_territory_code
  , destination_territory_eu_code
  , origin_territory_code
  , origin_territory_eu_code
  , stat_ext_value
  , area
  , comments
  , delivery_terms
  , customer_vat_number
 -- , invoice_line_ext_value
  , movement_amount
  , invoice_reference
  , entity_org_id
  , invoice_id
  , document_source_type
  , currency_conversion_rate
  , transaction_quantity
  , invoice_unit_price
  FROM
    mtl_movement_statistics
  WHERE movement_status = 'F'
    AND report_reference = to_char(p_legal_entity_id)||p_zone_code
                           ||p_period_name||p_usage_type
                           ||p_stat_type||p_movement_type
  ORDER BY commodity_code, parent_movement_id, movement_id;

mvt_rec c_mvt%ROWTYPE;

BEGIN
  --  Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call
    ( l_api_version_number
    , p_api_version_number
    , l_api_name
    , G_PKG_NAME
    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --  Initialize message stack if required
  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  --Temporary file for unit test,will remove after using concurrent pgm
  --FND_FILE.Put_Names('yawang.log','yawang.out','/sqlcom/mgdev115');

  --Get base currency
  l_base_currency := INV_MGD_MVT_UTILS_PKG.Get_LE_Currency(p_legal_entity_id);

  --Get profile value of NLS Numeric Character
  l_nls_numeric_char := FND_PROFILE.Value('ICX_NUMERIC_CHARACTERS');

  --Convert exchange rate from char to number
  l_exchange_rate := FND_NUMBER.Canonical_To_Number(p_exchange_rate_char);

  FOR mvt_rec IN c_mvt
    LOOP
      --Count how many records have been processed
      l_process_rec_count := l_process_rec_count + 1;

      --Get country of consignment
      IF p_movement_type IN ('A','AA')
      THEN
        l_cons_country := mvt_rec.dispatch_territory_code;
        l_cons_eu_country := mvt_rec.dispatch_territory_eu_code;
      ELSE
        l_cons_country := mvt_rec.destination_territory_code;
        l_cons_eu_country := mvt_rec.destination_territory_eu_code;
      END IF;

      --Calculate invoice value. Can not use invoice_line_ext_value
      --directly, becasue for multiple receipts one invoice,the invoice
      --value in table is the total for all the receipts. We need to
      --split for each receipt using transaction quantity
      IF mvt_rec.invoice_unit_price IS NOT NULL
      THEN
        l_invoice_value_calc := mvt_rec.invoice_unit_price *
                                mvt_rec.transaction_quantity;
      ELSE
        l_invoice_value_calc := null;
      END IF;

      --Get invoice number and invoice currency
      --Get invoice value in foreign currency, invoice foreign currency and
      --invoice value in local currency
      IF mvt_rec.document_source_type IN ('PO','RTV')
         AND mvt_rec.invoice_id  IS NOT NULL
      THEN
        BEGIN
          SELECT
            invoice_num
          , invoice_currency_code
          INTO
            l_invoice_num
          , l_invoice_currency
          FROM ap_invoices_all
          WHERE invoice_id = mvt_rec.invoice_id;

          EXCEPTION
            WHEN OTHERS THEN
              l_invoice_num := null;
              l_invoice_currency := null;
        END;

        IF l_invoice_currency IS NOT NULL
        THEN
          IF (l_invoice_currency <> l_base_currency
             AND l_invoice_value_calc IS NOT NULL)
          THEN
          /*  --Get precision of the foreign currency
            OPEN c_precision;
            FETCH c_precision
            INTO  l_precision;
            CLOSE c_precision;*/

            --Calculate the base invoice value
            --Fix bug 5203245. Don't round here. The final rounding will
            --be later after apply exchange rate
            l_invoice_value_foreign := null; --mvt_rec.invoice_line_ext_value;
            l_invoice_curr_foreign := null; --l_invoice_currency;
            l_invoice_value_local := l_invoice_value_calc *
                                     mvt_rec.currency_conversion_rate;
          ELSE
            l_invoice_value_foreign := null;
            l_invoice_curr_foreign := null;
            l_invoice_value_local := NVL(l_invoice_value_calc,mvt_rec.movement_amount);
          END IF;
        ELSE
          l_invoice_value_foreign := null;
          l_invoice_curr_foreign := null;
          l_invoice_value_local := NVL(l_invoice_value_calc,mvt_rec.movement_amount);
        END IF;
      ELSIF mvt_rec.document_source_type IN ('SO', 'RMA', 'OPSO')
            AND mvt_rec.invoice_id  IS NOT NULL
      THEN
        BEGIN
          --the invoice is a customer invoice
          SELECT
            trx_number
          , invoice_currency_code
          INTO
            l_invoice_num
          , l_invoice_currency
          FROM ra_customer_trx_all
          WHERE customer_trx_id = mvt_rec.invoice_id;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              IF p_movement_type = 'A'
              THEN
                BEGIN
                  -- the invoice is ap intercompany invoice
                  SELECT
                    invoice_num
                  , invoice_currency_code
                  INTO
                    l_invoice_num
                  , l_invoice_currency
                  FROM ap_invoices_all
                  WHERE invoice_id = mvt_rec.invoice_id;

                  EXCEPTION
                    WHEN OTHERS THEN
                      l_invoice_num := null;
                      l_invoice_currency := null;
                END;
              ELSE
                l_invoice_num := null;
                l_invoice_currency := null;
              END IF;

            WHEN OTHERS THEN
              l_invoice_num := null;
              l_invoice_currency := null;

        END;

        IF l_invoice_currency IS NOT NULL
        THEN
          IF (l_invoice_currency <> l_base_currency
              AND l_invoice_value_calc IS NOT NULL)
          THEN
            --comment this cursor out bug 5203245
            /*--Get precision of the foreign currency
            OPEN c_precision;
            FETCH c_precision
            INTO  l_precision;
            CLOSE c_precision;*/

            --Calculate the base invoice value
            --Fix bug 5203245. Don't round here. The final rounding will
            --be later after apply exchange rate
            l_invoice_value_foreign := null; --mvt_rec.invoice_line_ext_value;
            l_invoice_curr_foreign := null; --l_invoice_currency;
            l_invoice_value_local := l_invoice_value_calc *
                                     mvt_rec.currency_conversion_rate;
          ELSE
            l_invoice_value_foreign := null;
            l_invoice_curr_foreign := null;
            l_invoice_value_local := NVL(l_invoice_value_calc,mvt_rec.movement_amount);
          END IF;
        ELSE
          l_invoice_value_foreign := null;
          l_invoice_curr_foreign := null;
          l_invoice_value_local := NVL(l_invoice_value_calc,mvt_rec.movement_amount);
        END IF;
      ELSIF mvt_rec.document_source_type = 'MISC'
      THEN
        l_invoice_num := mvt_rec.invoice_reference;
        l_invoice_currency := null;
        l_invoice_value_foreign := null;
        l_invoice_curr_foreign := null;
        l_invoice_value_local := NVL(l_invoice_value_calc,mvt_rec.movement_amount);
      ELSE
        l_invoice_num := null;
        l_invoice_currency := null;
        l_invoice_value_foreign := null;
        l_invoice_curr_foreign := null;
        l_invoice_value_local := NVL(l_invoice_value_calc,mvt_rec.movement_amount);
      END IF;

      --Fix bug 4866967 and 5203245, get weight precision and rounding
      --method defined on parameter form
      INV_MGD_MVT_UTILS_PKG.Get_Weight_Precision
      (p_legal_entity_id => p_legal_entity_id
      , p_zone_code      => p_zone_code
      , p_usage_type     => p_usage_type
      , p_stat_type      => p_stat_type
      , x_weight_precision => l_weight_precision
      , x_rep_rounding     => l_rounding_method);

      --Get currency precision for the reporting currency
      OPEN c_rep_curr_precision;
      FETCH c_rep_curr_precision
      INTO  l_precision;

      IF c_rep_curr_precision%NOTFOUND
      THEN
        l_precision := 2;
      END IF;
      CLOSE c_rep_curr_precision;

      --Get rounding precision based on display format
      IF p_amount_display = 'W'
      THEN
        l_rounding_precision := 0;
      ELSE
        l_rounding_precision := l_precision; --normal currency precision
      END IF;

      --Fix bug 4866967 and 5203245 allow user to decide the round digit
      --and rounding method
      --Round total weight before formating (it is rounded already in processor
      --but in case the value in db has different precision as defined, round again here
      l_round_total_weight := INV_MGD_MVT_UTILS_PKG.Round_Number
      ( p_number          => mvt_rec.total_weight
      , p_precision       => l_weight_precision
      , p_rounding_method => l_rounding_method
      );

      l_round_alternate_qty := INV_MGD_MVT_UTILS_PKG.Round_Number
      ( p_number          => mvt_rec.alternate_quantity
      , p_precision       => l_weight_precision
      , p_rounding_method => l_rounding_method
      );

      --Round statistics value and apply exchange rate
      l_round_stat_ext_value := INV_MGD_MVT_UTILS_PKG.Round_Number
      ( p_number          => mvt_rec.stat_ext_value * l_exchange_rate
      , p_precision       => l_rounding_precision
      , p_rounding_method => l_rounding_method
      );

      --Round invoice value and apply exchange rate
      l_round_invoice_value := INV_MGD_MVT_UTILS_PKG.Round_Number
      ( p_number          => l_invoice_value_local * l_exchange_rate
      , p_precision       => l_rounding_precision
      , p_rounding_method => l_rounding_method
      );

      --Get weight format mask
      IF l_weight_precision = 0
      THEN
        l_weight_format_mask := 'FM9999999999999990';
      ELSE
        l_weight_format_mask := 'FM9999999999999990'||rpad('D',l_weight_precision+1,'0');
      END IF;

      --Get amount format mask
      IF p_amount_display = 'W'
      THEN
        l_format_mask := 'FM9999999999999990';
      ELSE
        l_format_mask := 'FM9999999999999990'||rpad('D',l_precision+1,'0');
      END IF;

      --Apply user preference for numeric value
      IF l_nls_numeric_char IS NOT NULL
      THEN
        l_stat_ext_val_conv    := TO_CHAR(l_round_stat_ext_value, l_format_mask,
                                  'NLS_NUMERIC_CHARACTERS = '''||l_nls_numeric_char||'''');

        l_invoice_val_loc_conv := TO_CHAR(l_round_invoice_value, l_format_mask,
                                  'NLS_NUMERIC_CHARACTERS = '''||l_nls_numeric_char||'''');

        l_alt_qty_conv         := TO_CHAR(l_round_alternate_qty, l_weight_format_mask,
                                  'NLS_NUMERIC_CHARACTERS = '''||l_nls_numeric_char||'''');

        l_total_weight_conv    := TO_CHAR(l_round_total_weight, l_weight_format_mask,
                                  'NLS_NUMERIC_CHARACTERS = '''||l_nls_numeric_char||'''');

        /*l_invoice_val_fore_conv :=
               TO_CHAR(l_invoice_value_foreign,'FM9999999999999990D00',
                      'NLS_NUMERIC_CHARACTERS = '''||l_nls_numeric_char||'''');*/
      ELSE
        l_stat_ext_val_conv    := TO_CHAR(l_round_stat_ext_value, l_format_mask);
        l_invoice_val_loc_conv := TO_CHAR(l_round_invoice_value, l_format_mask);
        l_alt_qty_conv         := TO_CHAR(l_round_alternate_qty, l_weight_format_mask);
        l_total_weight_conv    := TO_CHAR(l_round_total_weight, l_weight_format_mask);

        --l_invoice_val_fore_conv := TO_CHAR(l_invoice_value_foreign,'FM9999999999999990D00');
      END IF;

      FND_FILE.Put_Line(FND_FILE.Output, NVL(RPAD(mvt_rec.commodity_code,8), '        ')
                        ||NVL(RPAD(l_cons_country, 2), '  ')
                        ||NVL(RPAD(l_cons_eu_country, 3), '   ')
                        ||NVL(RPAD(mvt_rec.transaction_nature,2), '  ')
                        ||NVL(RPAD(mvt_rec.transport_mode,1), ' ')
                        ||NVL(RPAD(mvt_rec.statistical_procedure_code,5), '     ')
                        ||NVL(RPAD(mvt_rec.port,5), '     ')
                        ||NVL(RPAD(mvt_rec.area,10), '          ')
                        ||NVL(RPAD(mvt_rec.delivery_terms,4), '    ')
                        ||NVL(RPAD(l_total_weight_conv,15), '               ')
                        ||NVL(RPAD(l_alt_qty_conv,15),'               ')
                        ||NVL(RPAD(mvt_rec.origin_territory_code,2), '  ')
                        ||NVL(RPAD(l_stat_ext_val_conv,15),'               ')
                        ||NVL(RPAD(l_invoice_val_loc_conv,15),'               ')
                        ||NVL(RPAD(l_invoice_val_fore_conv,15),'               ')
                        ||NVL(RPAD(l_invoice_num, 25),'                         ')
                        ||NVL(RPAD(l_invoice_curr_foreign,3), '   ')
                        ||NVL(RPAD(mvt_rec.customer_vat_number, 20), '                    ')
                        ||NVL(mvt_rec.comments, ''));


    END LOOP;
  --FND_FILE.Close;

  --Check if process_rec_count is greate than 0, if yes then update
  --movement status to Exported,else print "No Data Found" in output file
  IF l_process_rec_count > 0
  THEN
    UPDATE
      mtl_movement_statistics
    SET
      movement_status = 'X'
    WHERE movement_status = 'F'
      AND report_reference = to_char(p_legal_entity_id)||p_zone_code
                             ||p_period_name||p_usage_type
                             ||p_stat_type||p_movement_type;
  ELSE
    --FND_FILE.Put_Names('yawang.log','yawang.out','/sqlcom/mgdev115');
    FND_FILE.Put_Line(FND_FILE.Output, 'No Data Found');
    --FND_FILE.Close;
  END IF;

  --Commit the Operation
  COMMIT;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- generate proper error message
    FND_MESSAGE.set_name
    ( application => 'INV'
    , name        => 'INV_MGD_MVT_NO_DATA_FOUND'
    );
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_And_Get
    ( p_encoded => FND_API.G_FALSE
    , p_count   => x_msg_count
    , p_data    => x_msg_data
    );

  WHEN TOO_MANY_ROWS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- generate proper error message
    FND_MESSAGE.set_name
    ( application => 'INV'
    , name        => 'INV_MGD_MVT_TOO_MANY_TRANS'
    );
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_And_Get
    ( p_encoded => FND_API.G_FALSE
    , p_count   => x_msg_count
    , p_data    => x_msg_data
    );

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_encoded => FND_API.G_FALSE
    , p_count   => x_msg_count
    , p_data    => x_msg_data
    );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_encoded => FND_API.G_FALSE
    , p_count   => x_msg_count
    , p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Generate_Export_Data'
      );
    END IF;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_encoded => FND_API.G_FALSE
    , p_count   => x_msg_count
    , p_data    => x_msg_data
    );
END Generate_Export_Data;

END INV_MGD_MVT_EXPORT_DATA;

/
