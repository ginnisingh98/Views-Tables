--------------------------------------------------------
--  DDL for Package Body JL_ZZ_TAX_INTEGRATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_TAX_INTEGRATION_PKG" AS
/* $Header: jlzztinb.pls 120.19.12010000.5 2009/08/04 23:06:42 skorrapa ship $ */

  g_current_runtime_level NUMBER;
  g_level_statement       CONSTANT  NUMBER   := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure       CONSTANT  NUMBER   := FND_LOG.LEVEL_PROCEDURE;
  g_level_event           CONSTANT  NUMBER   := FND_LOG.LEVEL_EVENT;
  g_level_exception       CONSTANT  NUMBER   := FND_LOG.LEVEL_EXCEPTION;
  g_level_unexpected      CONSTANT  NUMBER   := FND_LOG.LEVEL_UNEXPECTED;


-- Bugfix# 3259701

  PROCEDURE populate_om_ar_tax_struct
       (p_conversion_rate    IN NUMBER,
        p_currency_code      IN VARCHAR2,
        p_fob_point_code     IN VARCHAR2,
        p_global_attribute5  IN VARCHAR2,
        p_line_id            IN NUMBER,
        p_header_id          IN NUMBER,
        p_inventory_item_id  IN NUMBER,
        p_invoice_to_org_id  IN NUMBER,
        p_invoicing_rule_id  IN NUMBER,
        p_line_type_id       IN NUMBER,
        p_pricing_quantity   IN NUMBER,
        p_payment_term_id    IN NUMBER,
        p_global_attribute6  IN VARCHAR2,
        p_ship_from_org_id   IN NUMBER,
        p_ship_to_org_id     IN NUMBER,
        p_tax_code           IN VARCHAR2,
        p_tax_date           IN DATE,
        p_tax_exempt_flag    IN VARCHAR2,
        p_tax_exempt_number  IN VARCHAR2,
        p_tax_exempt_reason  IN VARCHAR2,
        p_unit_selling_price IN NUMBER,
        p_org_id             IN NUMBER) IS   --Bug fix 2367111

    l_cust_trx_type_id         ra_cust_trx_types.cust_trx_type_id%type;
    l_location_structure_id    ar_system_parameters.location_structure_id%type;
    l_location_segment_num     number;
    l_set_of_books_id          ar_system_parameters.set_of_books_id%type;
    l_tax_rounding_allow_override
                          ar_system_parameters.tax_rounding_allow_override%type;
    l_tax_header_level_flag    ar_system_parameters.tax_header_level_flag%type;
    l_tax_rounding_rule        ar_system_parameters.tax_rounding_rule%type;
    l_tax_rule_set             ar_system_parameters.global_attribute13%type;
    l_location_id              hr_locations_all.location_id%type;
    l_org_class                hr_locations_all.global_attribute1%type;
    l_taxable_basis            ar_vat_tax.taxable_basis%type;
    l_tax_calculation_plsql_block
                               ar_vat_tax.tax_calculation_plsql_block%type;
    l_tax_calculation_flag     ra_cust_trx_types.tax_calculation_flag%type;
    l_tax_type                 ar_vat_tax.tax_type%type;
    l_vat_tax_id               ar_vat_tax.vat_tax_id%type;
    l_tax_category_id          ar_vat_tax.global_attribute1%type;
    l_minimum_accountable_unit fnd_currencies_vl.minimum_accountable_unit%type;
    l_precision                fnd_currencies_vl.precision%type;
    --l_site_use_code            ra_site_uses.site_use_code%type;
    l_site_use_id              NUMBER;
    l_global_attribute5        mtl_system_items.global_attribute1%type;
    l_global_attribute6        mtl_system_items.global_attribute2%type;
    l_org_id                   NUMBER;

  BEGIN

     g_current_runtime_level  :=  FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF p_org_id IS NULL THEN
      l_org_id := to_number(fnd_profile.value('ORG_ID'));

    END IF;
    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','JL_ZZ_TAX_INTEGRATION_PKG.populate_om_ar_tax_struct ()+');
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-P- Exchange Rate : ' || to_char(p_conversion_rate));
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-P- Currency Code : ' || p_currency_code);
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-P- FOB Point Code : ' || p_fob_point_code);
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-P- Global Attribute5 : ' || p_global_attribute5);
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-P- Line Id : ' || to_char(p_line_id));
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-P- Header Id : ' || to_char(p_header_id));
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-P- Inventory Item Id : ' || to_char(p_inventory_item_id));
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-P- Invoice to Org Id : ' || to_char(p_invoice_to_org_id));
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-P- Invoicing Rule Id : ' || to_char(p_invoicing_rule_id));
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-P- Transaction Type Id : ' || to_char(p_line_type_id));
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-P- Pricing Quantity : ' || to_char(p_pricing_quantity));
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-P- Payment Term Id : ' || to_char(p_payment_term_id));
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-P- Global Attribute6 : ' || p_global_attribute6);
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-P- Ship From Org Id : ' || to_char(p_ship_from_org_id));
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-P- Ship To Org Id : ' || to_char(p_ship_to_org_id));
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-P- Tax Code : ' || p_tax_code);
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-P- Tax Date : ' || to_char(p_tax_date,'DD-MON-YYYY'));
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-P- Tax Exempt Flag : ' || p_tax_exempt_flag);
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-P- Tax Exempt Number : ' || p_tax_exempt_number);
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-P- Tax Exempt Reason : ' || p_tax_exempt_reason);
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-P- Unit Selling Price : ' || to_char(p_unit_selling_price));
    END IF;

    -- Validate Required Parameter
    IF p_line_type_id IS NULL THEN
      fnd_message.set_name('AR', 'GENERIC_MESSAGE');
      fnd_message.set_token('GENERIC_TEXT',
                            'Required Parameter Missing: Transaction Type Id');
      g_jl_exception_type := 'E';
      app_exception.raise_exception;
    END IF;

    l_global_attribute5 := p_global_attribute5;
    l_global_attribute6 := p_global_attribute6;
    -- Validate Global Attribute5 and Global Attribute6

    -- Bug 3610797.
    -- default API of LTE will be called by TSRM to populate missing values (bug 3680358)
/*
    IF (l_global_attribute5 IS NULL OR l_global_attribute6 IS NULL) THEN
      -- Default values from Global Attributes of Items
      jl_zz_ar_tx_lib_pkg.get_item_fsc_txn_code (p_inventory_item_id,
                                                 p_invoice_to_org_id,
                                                 l_global_attribute5,
                                                 l_global_attribute6);

      IF l_global_attribute5 IS NULL THEN
        fnd_message.set_name('AR', 'GENERIC_MESSAGE');
        fnd_message.set_token('GENERIC_TEXT',
   	            'Required Parameter Missing: Fiscal Classification');
        app_exception.raise_exception;
      END IF;

      IF l_global_attribute6 IS NULL THEN
        fnd_message.set_name('AR', 'GENERIC_MESSAGE');
        fnd_message.set_token('GENERIC_TEXT',
   	                          'Required Parameter Missing: Transaction Condition Class');
        app_exception.raise_exception;
      END IF;
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Global Attribute5 : ' || l_global_attribute5);
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Global Attribute6 : ' || l_global_attribute6);
      END IF;

    END IF;
*/

    -- Fetch Customer Trx_Type_Id and Tax Calculation Flag
    -- If Tax Calculation Flag is unchecked then return.
    l_cust_trx_type_id := NULL;

    BEGIN
      SELECT INV_TYPE.CUST_TRX_TYPE_ID,
             INV_TYPE.TAX_CALCULATION_FLAG
      INTO l_cust_trx_type_id,
           l_tax_calculation_flag
      FROM OE_LINE_TYPES_V LINE_TYPE, --OE_TRANSACTION_TYPES_VL LINE_TYPE,
           RA_CUST_TRX_TYPES INV_TYPE
      WHERE LINE_TYPE.TRANSACTION_TYPE_ID = p_line_type_id
      --AND LINE_TYPE.TRANSACTION_TYPE_CODE = 'LINE'
      AND LINE_TYPE.CUST_TRX_TYPE_ID = INV_TYPE.CUST_TRX_TYPE_ID
      AND nvl(inv_type.org_id,-99) = nvl(line_type.org_id,-99)  --Bugfix 2367111
      AND nvl(inv_type.org_id,-99) = nvl(l_org_id,-99);         --Bugfix 2367111

    EXCEPTION
      WHEN NO_DATA_FOUND THEN

        -- Fetch Receivables Customer Trx_Type_Id set at Order Level
        BEGIN
          SELECT INV_TYPE.CUST_TRX_TYPE_ID,
                 INV_TYPE.TAX_CALCULATION_FLAG
          INTO l_cust_trx_type_id,
               l_tax_calculation_flag
          FROM OE_ORDER_TYPES_V ORD_TYPE,
               OE_ORDER_HEADERS ORD_HEADER,
               RA_CUST_TRX_TYPES INV_TYPE
          WHERE ORD_TYPE.ORDER_TYPE_ID = ORD_HEADER.ORDER_TYPE_ID
          AND ORD_HEADER.HEADER_ID = p_header_id
          AND ORD_TYPE.CUST_TRX_TYPE_ID = INV_TYPE.CUST_TRX_TYPE_ID;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
               -- Fetch Receivables Customer Trx_Type_Id set at Order Level
               -- when p_line_type_id contains order_type_id
               BEGIN
                   SELECT INV_TYPE.CUST_TRX_TYPE_ID,
                          INV_TYPE.TAX_CALCULATION_FLAG
                   INTO   l_cust_trx_type_id,
                          l_tax_calculation_flag
                   FROM   OE_ORDER_TYPES_V ORD_TYPE,
                          RA_CUST_TRX_TYPES INV_TYPE
                   WHERE  ORD_TYPE.ORDER_TYPE_ID = p_line_type_id
                   AND    ORD_TYPE.CUST_TRX_TYPE_ID = INV_TYPE.CUST_TRX_TYPE_ID;

               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                      -- Fetch Receivables Customer Trx_Type_Id set at Profile Level
                      BEGIN
                        SELECT INV_TYPE.CUST_TRX_TYPE_ID,
                               INV_TYPE.TAX_CALCULATION_FLAG
                        INTO l_cust_trx_type_id,
                             l_tax_calculation_flag
                        FROM RA_CUST_TRX_TYPES INV_TYPE
                        WHERE INV_TYPE.CUST_TRX_TYPE_ID =
                               FND_PROFILE.VALUE('OE_INVOICE_TRANSACTION_TYPE_ID');
                      EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                          fnd_message.set_name('AR', 'GENERIC_MESSAGE');
                          fnd_message.set_token('GENERIC_TEXT',
                                                'EXCEPTION(NO_DATA_FOUND) : Customer Trx Type Id');
                          g_jl_exception_type := 'E';
                          app_exception.raise_exception;
                      END; -- End fetch for Profile Level
                END; -- End fetch for order_type_id passed in line_type_id
        END; -- End fetch for Order Level

      WHEN OTHERS THEN
        fnd_message.set_name('AR', 'GENERIC_MESSAGE');
        fnd_message.set_token('GENERIC_TEXT',
                              'EXCEPTION(OTHERS) : Customer Trx Type Id : ' || sqlerrm);
        g_jl_exception_type := 'E';
        app_exception.raise_exception;
    END;

    IF (NVL(l_tax_calculation_flag,'N') <> 'Y') THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','Tax Calculation Flag is not checked');
        END IF;
      IF (NVL(p_tax_exempt_flag,'S') <> 'R') THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','Tax Exempt Flag is ' || p_tax_exempt_flag);
          FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','VALUES ARE NOT POPULATED');
          FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','populate_om_ar_tax_struct ()-');
        END IF;
        return;
      END IF;
    END IF;

    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.trx_type_id := l_cust_trx_type_id;

    -- Fetch System Parameters
    l_location_structure_id := NULL;
    l_location_segment_num := NULL;
    l_set_of_books_id := NULL;
    l_tax_rounding_allow_override := NULL;
    l_tax_header_level_flag := NULL;
    l_tax_rounding_rule := NULL;
    l_tax_rule_set := NULL;

    BEGIN
      SELECT SYS.LOCATION_STRUCTURE_ID,
             TO_NUMBER(SYS.GLOBAL_ATTRIBUTE10),
             SYS.SET_OF_BOOKS_ID,
             SYS.TAX_ROUNDING_ALLOW_OVERRIDE,
             SYS.TAX_HEADER_LEVEL_FLAG,
             TAX_ROUNDING_RULE,
             SYS.GLOBAL_ATTRIBUTE13
      INTO l_location_structure_id,
           l_location_segment_num,
           l_set_of_books_id,
           l_tax_rounding_allow_override,
           l_tax_header_level_flag,
           l_tax_rounding_rule,
           l_tax_rule_set
      FROM ar_system_parameters_all sys             --Bugfix 2367111
      WHERE nvl(sys.org_id,-99) = nvl(p_org_id,-99);  --Bugfix 2367111;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('AR', 'GENERIC_MESSAGE');
        fnd_message.set_token('GENERIC_TEXT',
                              'EXCEPTION(NO_DATA_FOUND) : System Options');
        g_jl_exception_type := 'E';
        app_exception.raise_exception;

      WHEN OTHERS THEN
        fnd_message.set_name('AR', 'GENERIC_MESSAGE');
        fnd_message.set_token('GENERIC_TEXT',
                              'EXCEPTION(OTHERS) : System Options : ' || sqlerrm);
        g_jl_exception_type := 'E';
        app_exception.raise_exception;
    END;

    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern9 := l_location_structure_id;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern10 := l_location_segment_num;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf1 := l_tax_rule_set;

    -- Fetch Location Id and Organization Class
    l_location_id := NULL;
    l_org_class := NULL;

    BEGIN
      SELECT HRL.LOCATION_ID,
             NVL(HRL.GLOBAL_ATTRIBUTE1, 'DEFAULT')
      INTO l_location_id,
           l_org_class
      FROM HR_LOCATIONS_ALL HRL,
           HR_ORGANIZATION_UNITS ORG
      WHERE ORG.LOCATION_ID = HRL.LOCATION_ID
      AND ORG.ORGANIZATION_ID = NVL(p_ship_from_org_id,
                                    NVL(p_invoice_to_org_id,
                                        OE_PROFILE.VALUE('SO_ORGANIZATION_ID')));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('AR', 'GENERIC_MESSAGE');
        fnd_message.set_token('GENERIC_TEXT',
                              'EXCEPTION(NO_DATA_FOUND) : Organization Class');
        g_jl_exception_type := 'E';
        app_exception.raise_exception;

      WHEN OTHERS THEN
        fnd_message.set_name('AR', 'GENERIC_MESSAGE');
        fnd_message.set_token('GENERIC_TEXT',
                              'EXCEPTION(OTHERS) : Organization Class : ' || sqlerrm);
        g_jl_exception_type := 'E';
        app_exception.raise_exception;
    END;

    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern4 := l_location_id;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf10 := l_org_class;

    -- Validate Tax Code
    IF p_tax_code IS NULL THEN
      fnd_message.set_name('AR', 'GENERIC_MESSAGE');
      fnd_message.set_token('GENERIC_TEXT',
                            'Required Parameter Missing: Tax Code');
      g_jl_exception_type := 'E';
      app_exception.raise_exception;
    END IF;

    -- Fetch AR_VAT_TAX details
    l_taxable_basis := NULL;
    l_tax_calculation_plsql_block := NULL;
    l_tax_type := NULL;
    l_vat_tax_id := NULL;

    BEGIN
      SELECT vat.TAXABLE_BASIS,
             vat.TAX_CALCULATION_PLSQL_BLOCK,
             vat.TAX_TYPE,
             decode(vat.tax_type,'TAX_GROUP',vat.vat_tax_id,null),
             decode(vat.tax_type,'TAX_GROUP',NULL,
                    decode (length(translate(vat.global_attribute1,
                                             '0123456789 ', '0123456789')),
                            length(translate(vat.global_attribute1, '0123456789
               ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_-,:.',
               '0123456789')), vat.global_attribute1, -99))
      INTO l_taxable_basis,
           l_tax_calculation_plsql_block,
           l_tax_type,
           l_vat_tax_id,
           l_tax_category_id
      FROM ar_vat_tax_all_b vat       --Bugfix 2367111
      WHERE vat.set_of_books_id = l_set_of_books_id
      AND vat.tax_code = p_tax_code
      AND p_tax_date BETWEEN vat.start_date
                          AND NVL(vat.end_date, TO_DATE( '31122199', 'DDMMYYYY'))
      AND NVL(vat.enabled_flag,'Y') = 'Y'
      AND NVL(vat.tax_class,'O') = 'O'
      AND NVL(vat.org_id,-99) = nvl(l_org_id,99);   --Bugfix 2367111
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('AR', 'GENERIC_MESSAGE');
        fnd_message.set_token('GENERIC_TEXT',
                              'EXCEPTION(NO_DATA_FOUND) : Tax Code');
        g_jl_exception_type := 'E';
        app_exception.raise_exception;

      WHEN OTHERS THEN
        fnd_message.set_name('AR', 'GENERIC_MESSAGE');
        fnd_message.set_token('GENERIC_TEXT',
                              'EXCEPTION(OTHERS) : Tax Code : ' || sqlerrm);
        g_jl_exception_type := 'E';
        app_exception.raise_exception;
    END;

    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.taxable_basis := l_taxable_basis;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_calculation_plsql_block :=
                                                l_tax_calculation_plsql_block;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.amount_includes_tax_flag := 'N';
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf7 := l_tax_type;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern1 := l_tax_category_id;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern2 := l_vat_tax_id;

    -- Fetch Currency
    l_minimum_accountable_unit := NULL;
    l_precision := NULL;

    BEGIN
      SELECT MINIMUM_ACCOUNTABLE_UNIT,
             PRECISION
      INTO l_minimum_accountable_unit,
           l_precision
      FROM FND_CURRENCIES_VL
      WHERE currency_code = p_currency_code;
    EXCEPTION
      WHEN OTHERS THEN
        l_minimum_accountable_unit := NULL;
        l_precision := NULL;
    END;

    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.trx_currency_code := p_currency_code;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.minimum_accountable_unit := l_minimum_accountable_unit;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.precision := l_precision;

    -- Calculated Columns
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.taxed_quantity := NVL(p_pricing_quantity,0);
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.extended_amount := NVL(p_pricing_quantity,0) *
                                            NVL(p_unit_selling_price,0);

    -- Columns with Values from Parameters
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.trx_exchange_rate := p_conversion_rate;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.customer_trx_line_id := p_line_id;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.customer_trx_id := p_header_id;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.trx_date := p_tax_date;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_code := p_tax_code;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.inventory_item_id := p_inventory_item_id;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_control := p_tax_exempt_flag;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.xmpt_cert_no := p_tax_exempt_number;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.xmpt_reason := p_tax_exempt_reason;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.invoicing_rule_id := p_invoicing_rule_id;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.fob_point := p_fob_point_code;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf2 := l_global_attribute5;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.payment_term_id := p_payment_term_id;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf9 := l_global_attribute6;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.ship_from_warehouse_id := p_ship_from_org_id;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.ship_to_site_use_id := p_ship_to_org_id;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.bill_to_site_use_id := p_invoice_to_org_id;

    -- Columns with Default or NULL values
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.customer_trx_charge_line_id := to_number(NULL);
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.link_to_cust_trx_line_id := to_number(NULL);
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.gl_date := NULL;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_rate := to_number(NULL);
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_amount :=to_number(NULL);
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.memo_line_id := NULL;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.default_ussgl_transaction_code := NULL;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.default_ussgl_trx_code_context := NULL;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.poo_code := NULL;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.poa_code := NULL;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.ship_from_code := NULL;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.ship_to_code := NULL;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.part_no := NULL;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_line_number := to_number(null);
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.qualifier := 'ALL';
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.calculate_tax := 'Y';
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_precedence := NULL;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_exemption_id := NULL;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.item_exception_rate_id := NULL;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.vdrctrl_exempt := NULL;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf3 := NULL;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf4 := 'OE';
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf5 := NULL;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern3 := NULL;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern5 := NULL;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.trx_number := to_number(NULL);
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.previous_customer_trx_line_id := to_number(NULL);
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.previous_customer_trx_id := to_number(NULL);
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.previous_trx_number := to_number(NULL);
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.audit_flag := 'Y';
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.trx_line_type := NULL;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.division_code := NULL;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.company_code := NULL;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.vat_tax_id := to_number(NULL);
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.poo_id := to_number(NULL);
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.poa_id := to_number(NULL);
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.payment_terms_discount_percent := NULL;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf8 := NULL;
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern6 := to_number(to_char(p_tax_date, 'YYYYMMDD'));
    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern7 := 7;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Tax Category Id : ' || to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern1));
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Vat Tax Id : ' || to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern2));
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Location Id : '
                      || to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern4));
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Customer Account Site Id : '
                      || to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern8));
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Location Structure Id : '
                      || to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern9));
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Location Segment Number : '
                      || to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern10));
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Tax Rule Set : ' || ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf1);
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Contributor Type : ' || ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf6);
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Tax Type : ' || ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf7);
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Organization Class : ' || ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf10);
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Taxable Basis : ' || ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.taxable_basis);
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Tax Calculation PL/SQL Block : '
                      || ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_calculation_plsql_block);
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Amount Includes Tax Flag : '
                      || ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.amount_includes_tax_flag);
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Customer Trx Type Id : '
                      || to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.trx_type_id));
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Ship To Customer Id : '
                      || to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.ship_to_cust_id));
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Ship To Site Use Id : '
                      || to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.ship_to_site_use_id));
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Ship To Postal Code : '
                      || ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.ship_to_postal_code);
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Ship To Location Id : '
                      || to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.ship_to_location_id));
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Ship To Customer Number : '
                      || ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.ship_to_customer_number);
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Ship To Customer Name : '
                      || ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.ship_to_customer_name);
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Bill To Customer Id : '
                      || to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.bill_to_cust_id));
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Bill To Site Use Id : '
                      || to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.bill_to_site_use_id));
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Bill To Postal Code : '
                      || ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.bill_to_postal_code);
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Bill To Location Id : '
                      || to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.bill_to_location_id));
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Bill To Customer Number : '
                      || ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.bill_to_customer_number);
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Bill To Customer Name : '
                      || ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.bill_to_customer_name);
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Tax Header Level Flag : '
                      || ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_header_level_flag);
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Tax Rounding Rule : '
                      || ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_rounding_rule);
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Minimum Accountable Unit : '
                      || to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.minimum_accountable_unit));
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Precision : '
                      || to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.precision));
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Extended Amount : '
                      || to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.extended_amount));

      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','JL_ZZ_TAX_INTEGRATION_PKG.populate_om_ar_tax_struct ()-');
    END IF;

  END populate_om_ar_tax_struct;

  PROCEDURE populate_ship_bill2
       (p_ship_to_site_use_id IN NUMBER,
        p_bill_to_site_use_id IN NUMBER,
        p_ship_to_cust_id     IN NUMBER DEFAULT NULL,
        p_bill_to_cust_id     IN NUMBER DEFAULT NULL) IS

    l_site_use_id NUMBER;
    l_cust_id     hz_cust_acct_sites.cust_account_id%type;

    CURSOR ship_bill (l_site_use_code varchar2,
                      l_site_use_id number,
                      l_cust_id number) IS
      SELECT ACCT_SITE.CUST_ACCOUNT_ID CUSTOMER_ID,
             LOC.POSTAL_CODE POSTAL_CODE,
             CUST_ACCT.ACCOUNT_NUMBER CUSTOMER_NUMBER,
             PARTY.PARTY_NAME CUSTOMER_NAME,
             ACCT_SITE.CUST_ACCT_SITE_ID NUMERIC_ATTRIBUTE8,
             NVL(acct_site.global_attribute8, 'DEFAULT') ATTRIBUTE6,
             NVL(acct_site.global_attribute9, 'N') use_site_prof,
             DECODE(NVL(SYS.TAX_ROUNDING_ALLOW_OVERRIDE, 'N'),
                        'Y', NVL(SITE.TAX_HEADER_LEVEL_FLAG,
                        NVL(CUST_ACCT.TAX_HEADER_LEVEL_FLAG,
                        NVL(SYS.TAX_HEADER_LEVEL_FLAG, 'N' ))),
                        NVL(SYS.TAX_HEADER_LEVEL_FLAG, 'N')) TAX_HEADER_LEVEL_FLAG,
             DECODE(NVL(SYS.TAX_ROUNDING_ALLOW_OVERRIDE, 'N'),
                        'Y', NVL(SITE.TAX_ROUNDING_RULE,
                        NVL(CUST_ACCT.TAX_ROUNDING_RULE,
                        NVL(SYS.TAX_ROUNDING_RULE, 'NEAREST'))),
                        NVL(SYS.TAX_ROUNDING_RULE, 'NEAREST')) TAX_ROUNDING_RULE
        FROM HZ_PARTY_SITES PARTY_SITE,
             HZ_LOCATIONS LOC,
             HZ_CUST_ACCT_SITES ACCT_SITE,
             HZ_CUST_SITE_USES SITE,
             HZ_PARTIES PARTY,
             HZ_CUST_ACCOUNTS CUST_ACCT,
             AR_SYSTEM_PARAMETERS SYS
        WHERE SITE.SITE_USE_ID = l_site_use_id
        AND SITE.SITE_USE_CODE = l_site_use_code
        AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
        AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
        AND SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
        AND PARTY.PARTY_ID = CUST_ACCT.PARTY_ID
        AND CUST_ACCT.CUST_ACCOUNT_ID = NVL(l_cust_id,ACCT_SITE.CUST_ACCOUNT_ID);


  BEGIN

    g_current_runtime_level  :=  FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','JL_ZZ_TAX_INTEGRATION_PKG.populate_ship_bill2 ()+');
    END IF;

    IF p_bill_to_site_use_id IS NULL THEN
      fnd_message.set_name('AR', 'GENERIC_MESSAGE');
      fnd_message.set_token('GENERIC_TEXT',
                            'Required Parameter Missing: Bill To Site Use Id');
      g_jl_exception_type := 'E';
      app_exception.raise_exception;
    END IF;

    -- Populate Ship To Details
    IF p_ship_to_site_use_id IS NOT NULL THEN
      FOR ship_rec IN ship_bill ('SHIP_TO', p_ship_to_site_use_id,
        p_ship_to_cust_id)
      LOOP
        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.ship_to_cust_id := ship_rec.customer_id;
        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.ship_to_site_use_id := p_ship_to_site_use_id;
        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.ship_to_postal_code := ship_rec.postal_code;
        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.ship_to_location_id := NULL;
        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.ship_to_customer_number := ship_rec.customer_number;
        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.ship_to_customer_name := ship_rec.customer_name;
        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern8 := ship_rec.numeric_attribute8;

        IF ship_rec.numeric_attribute8 IS NOT NULL THEN
          ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf6 :=
                               NVL(ship_rec.attribute6, 'DEFAULT');
          ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf4 := ship_rec.use_site_prof;
        END IF;
      EXIT;
      END LOOP;
    END IF;
    -- Populate Bill To Details
    IF p_bill_to_site_use_id IS NOT NULL THEN
      FOR bill_rec IN ship_bill ('BILL_TO',
                                 p_bill_to_site_use_id,
                                 p_bill_to_cust_id)
      LOOP
        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.bill_to_cust_id := bill_rec.customer_id;
        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.bill_to_site_use_id := p_bill_to_site_use_id;
        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.bill_to_postal_code := bill_rec.postal_code;
        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.bill_to_location_id := NULL;
        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.bill_to_customer_number :=
                             bill_rec.customer_number;
        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.bill_to_customer_name := bill_rec.customer_name;

        IF ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern8 IS NULL THEN
          ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern8 := bill_rec.numeric_attribute8;
          ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf6 := NVL(bill_rec.attribute6, 'DEFAULT');
          ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf4 := bill_rec.use_site_prof;
        END IF;

        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_header_level_flag :=
                             bill_rec.tax_header_level_flag;
        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_rounding_rule := bill_rec.tax_rounding_rule;

        IF bill_rec.customer_id IS NULL THEN
           fnd_message.set_name('AR', 'GENERIC_MESSAGE');
           fnd_message.set_token('GENERIC_TEXT',
                       'Required Parameter Missing: Bill To Customer Id');
           g_jl_exception_type := 'E';
           app_exception.raise_exception;
        END IF;
        EXIT;
      END LOOP;
    END IF;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- userf4: '||ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf4);
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- userf6: '||ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf6 );
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- usern8: '||
                   to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern8));
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','JL_ZZ_TAX_INTEGRATION_PKG.populate_ship_bill2 ()-');
    END IF;

  END populate_ship_bill2;

  PROCEDURE expand_group_tax_code
       (p_org_id IN NUMBER) IS

    l_index         NUMBER := 0;
    l_line_type     ar_memo_lines.line_type%type;
    l_application   VARCHAR2(2);
    l_delimiter     zx_fc_types_b.delimiter%type;
    l_delimiter_prod_cat     zx_fc_types_b.delimiter%type;

    --Bug#5112515
    l_transaction_nature   JL_ZZ_AR_TX_GROUPS.TRANSACTION_NATURE%TYPE;
    l_establishment_type   JL_ZZ_AR_TX_GROUPS.ESTABLISHMENT_TYPE%TYPE;
    l_contributor_type     JL_ZZ_AR_TX_GROUPS.CONTRIBUTOR_TYPE%TYPE;
    l_calculate_in_oe      JL_ZZ_AR_TX_GROUPS.CALCULATE_IN_OE%TYPE;
    l_group_tax_id         JL_ZZ_AR_TX_GROUPS.GROUP_TAX_ID%TYPE;

    CURSOR c_grp_code_cus IS
      SELECT TGR.TRANSACTION_NATURE ATTRIBUTE3,--TTA.TAX_ATTRIBUTE_VALUE ATTRIBUTE3,
             TGR.ESTABLISHMENT_TYPE ATTRIBUTE5,--OTA.TAX_ATTRIBUTE_VALUE ATTRIBUTE5,
             TGR.TAX_CATEGORY_ID NUMERIC_ATTRIBUTE1,
             TGR.CONTRIBUTOR_TYPE ATTRIBUTE8,--CTA.TAX_ATTRIBUTE_VALUE ATTRIBUTE8,
             TGR.CALCULATE_IN_OE,
             TXC.TAX_CATEGORY
      FROM JL_ZZ_AR_TX_GROUPS_ALL TGR , --Bugfix 2367111
           JL_ZZ_AR_TX_CATEG TXC
      WHERE TGR.GROUP_TAX_ID = ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern2
      AND ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE <= TGR.END_DATE_ACTIVE
      AND ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE >= NVL(TGR.START_DATE_ACTIVE,
                                                ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE)
      AND TGR.TAX_CATEGORY_ID = TXC.TAX_CATEGORY_ID
      AND NVL(TXC.START_DATE_ACTIVE, ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE) <=
                      ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE
      AND TXC.END_DATE_ACTIVE >= ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE
      AND TXC.TAX_RULE_SET = ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf1
      AND EXISTS (SELECT ATC.TAX_ATTRIBUTE_VALUE
                FROM JL_ZZ_AR_TX_ATT_CLS ATC
                WHERE TGR.ESTABLISHMENT_TYPE = ATC.TAX_ATTRIBUTE_VALUE
                AND   ATC.TAX_ATTR_CLASS_TYPE = 'ORGANIZATION_CLASS'
                AND   ATC.TAX_CATEGORY_ID = TXC.TAX_CATEGORY_ID
                AND   ATC.TAX_ATTRIBUTE_TYPE = 'ORGANIZATION_ATTRIBUTE'
                AND   ATC.TAX_ATTRIBUTE_NAME = TXC.ORG_TAX_ATTRIBUTE
                AND   ATC.ENABLED_FLAG = 'Y'
                AND   ATC.TAX_ATTR_CLASS_CODE =  ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf10
               AND nvl(tgr.org_id,-99) = nvl(atc.org_id,-99)) --Bugfix 2367111)
      AND EXISTS (SELECT CTA.TAX_ATTRIBUTE_VALUE
                FROM  JL_ZZ_AR_TX_CUS_CLS CTA
                WHERE CTA.ADDRESS_ID = ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern8
                AND   CTA.TAX_ATTR_CLASS_CODE = ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf6
                AND   CTA.TAX_CATEGORY_ID = TXC.TAX_CATEGORY_ID
                AND   CTA.TAX_ATTRIBUTE_NAME = TXC.CUS_TAX_ATTRIBUTE
                AND   CTA.ENABLED_FLAG = 'Y'
                AND   TGR.CONTRIBUTOR_TYPE = CTA.TAX_ATTRIBUTE_VALUE
                AND nvl(tgr.org_id,-99) = nvl(cta.org_id,-99))  --Bugfix 2367111
      AND EXISTS (SELECT ATC.TAX_ATTRIBUTE_VALUE
                FROM JL_ZZ_AR_TX_ATT_CLS ATC
                WHERE TGR.TRANSACTION_NATURE = ATC.TAX_ATTRIBUTE_VALUE
                AND   ATC.TAX_ATTR_CLASS_TYPE = 'TRANSACTION_CLASS'
                AND   ATC.TAX_CATEGORY_ID = TXC.TAX_CATEGORY_ID
                AND   ATC.TAX_ATTRIBUTE_TYPE = 'TRANSACTION_ATTRIBUTE'
                AND   ATC.TAX_ATTRIBUTE_NAME = TXC.TXN_TAX_ATTRIBUTE
                AND   ATC.TAX_ATTR_CLASS_CODE = ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf9
                AND   ATC.ENABLED_FLAG = 'Y'
                AND nvl(tgr.org_id,-99) = nvl(atc.org_id,-99))  --Bugfix 2367111
      AND nvl(tgr.org_id,-99) = nvl(p_org_id,-99)    --Bugfix 2367111
      AND nvl(tgr.org_id,-99) = nvl(txc.org_id,-99);  --Bugfix 2367111

  --Bug#5112515

  CURSOR c_grp_code_cus_cm IS
    SELECT TGR.TRANSACTION_NATURE ATTRIBUTE3 ,
           TGR.ESTABLISHMENT_TYPE ATTRIBUTE5 ,
           TGR.CONTRIBUTOR_TYPE ATTRIBUTE8,
           TGR.CALCULATE_IN_OE
    FROM JL_ZZ_AR_TX_GROUPS TGR ,
         JL_ZZ_AR_TX_CATEG TXC
    WHERE TGR.GROUP_TAX_ID = ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern2
    AND    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE <= TGR.END_DATE_ACTIVE
    AND    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE >=
                 NVL(TGR.START_DATE_ACTIVE,
                     ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE)
    AND TGR.TAX_CATEGORY_ID = TXC.TAX_CATEGORY_ID
    AND TXC.TAX_CATEGORY_ID = ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern1
    AND TXC.TAX_RULE_SET = ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf1
    AND NVL(TXC.START_DATE_ACTIVE,
            ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE) <=
                      ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE
    AND TXC.END_DATE_ACTIVE >= ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE
    AND EXISTS (SELECT ATC.TAX_ATTRIBUTE_VALUE
                FROM JL_ZZ_AR_TX_ATT_CLS ATC
                WHERE TGR.ESTABLISHMENT_TYPE = ATC.TAX_ATTRIBUTE_VALUE
                AND   ATC.TAX_ATTR_CLASS_TYPE = 'ORGANIZATION_CLASS'
                AND   ATC.TAX_CATEGORY_ID = TXC.TAX_CATEGORY_ID
                AND   TXC.TAX_CATEGORY_ID =
                             ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern1
                AND   ATC.TAX_ATTRIBUTE_TYPE = 'ORGANIZATION_ATTRIBUTE'
                AND   ATC.TAX_ATTRIBUTE_NAME = TXC.ORG_TAX_ATTRIBUTE
                AND   ATC.ENABLED_FLAG = 'Y'
                AND   ATC.TAX_ATTR_CLASS_CODE =
                             ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf10)
    AND EXISTS (SELECT CTA.TAX_ATTRIBUTE_VALUE
                FROM  JL_ZZ_AR_TX_CUS_CLS CTA
                WHERE CTA.ADDRESS_ID =
                             ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern8
                AND   CTA.TAX_ATTR_CLASS_CODE =
                             ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf6
                AND   CTA.TAX_CATEGORY_ID = TXC.TAX_CATEGORY_ID
                AND   TXC.TAX_CATEGORY_ID =
                             ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern1
                AND   CTA.TAX_ATTRIBUTE_NAME = TXC.CUS_TAX_ATTRIBUTE
                AND   CTA.ENABLED_FLAG = 'Y'
                AND   TGR.CONTRIBUTOR_TYPE = CTA.TAX_ATTRIBUTE_VALUE )
    AND EXISTS (SELECT ATC.TAX_ATTRIBUTE_VALUE
                FROM JL_ZZ_AR_TX_ATT_CLS ATC
                WHERE TGR.TRANSACTION_NATURE = ATC.TAX_ATTRIBUTE_VALUE
                AND   ATC.TAX_ATTR_CLASS_TYPE = 'TRANSACTION_CLASS'
                AND   ATC.TAX_CATEGORY_ID = TXC.TAX_CATEGORY_ID
                AND   TXC.TAX_CATEGORY_ID =
                             ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern1
                AND   ATC.TAX_ATTRIBUTE_TYPE = 'TRANSACTION_ATTRIBUTE'
                AND   ATC.TAX_ATTRIBUTE_NAME = TXC.TXN_TAX_ATTRIBUTE
                AND   ATC.TAX_ATTR_CLASS_CODE =
                             ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf9
                AND   ATC.ENABLED_FLAG = 'Y');


    CURSOR c_grp_code_att IS
      SELECT TGR.TRANSACTION_NATURE ATTRIBUTE3,--TTA.TAX_ATTRIBUTE_VALUE ATTRIBUTE3,
             TGR.ESTABLISHMENT_TYPE ATTRIBUTE5,--OTA.TAX_ATTRIBUTE_VALUE ATTRIBUTE5,
             TGR.TAX_CATEGORY_ID NUMERIC_ATTRIBUTE1,
             TGR.CONTRIBUTOR_TYPE ATTRIBUTE8,--CTA.TAX_ATTRIBUTE_VALUE ATTRIBUTE8,
             TGR.CALCULATE_IN_OE,
             TXC.TAX_CATEGORY
      FROM JL_ZZ_AR_TX_GROUPS_ALL TGR ,  --Bugfix 2367111
           JL_ZZ_AR_TX_CATEG TXC
      WHERE TGR.GROUP_TAX_ID = ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern2
      AND ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE <= TGR.END_DATE_ACTIVE
      AND ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE >= NVL(TGR.START_DATE_ACTIVE,
                                                ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE)
      AND TGR.TAX_CATEGORY_ID = TXC.TAX_CATEGORY_ID
      AND NVL(TXC.START_DATE_ACTIVE, ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE) <=
                      ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE
      AND TXC.END_DATE_ACTIVE >= ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE
      AND TXC.TAX_RULE_SET = ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf1
      AND EXISTS ( SELECT ATC.TAX_ATTRIBUTE_VALUE
                    FROM JL_ZZ_AR_TX_ATT_CLS ATC
                    WHERE ATC.TAX_ATTR_CLASS_TYPE = 'ORGANIZATION_CLASS'
                    AND   TGR.ESTABLISHMENT_TYPE = ATC.TAX_ATTRIBUTE_VALUE
                    AND   ATC.TAX_CATEGORY_ID = TXC.TAX_CATEGORY_ID
                    AND   ATC.TAX_ATTRIBUTE_TYPE = 'ORGANIZATION_ATTRIBUTE'
                    AND   ATC.TAX_ATTRIBUTE_NAME = TXC.ORG_TAX_ATTRIBUTE
                    AND   ATC.TAX_ATTR_CLASS_CODE = ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf10
                    AND   ATC.ENABLED_FLAG = 'Y'
                    AND nvl(tgr.org_id,-99) = nvl(atc.org_id,-99)) --Bugfix 2367111
      AND    EXISTS ( SELECT ATC.TAX_ATTRIBUTE_VALUE
                    FROM JL_ZZ_AR_TX_ATT_CLS ATC
                    WHERE ATC.TAX_ATTR_CLASS_TYPE = 'CONTRIBUTOR_CLASS'
                    AND   TGR.CONTRIBUTOR_TYPE = ATC.TAX_ATTRIBUTE_VALUE
                    AND   ATC.TAX_ATTRIBUTE_TYPE = 'CONTRIBUTOR_ATTRIBUTE'
                    AND   ATC.TAX_ATTR_CLASS_CODE = ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf6
                    AND   ATC.TAX_CATEGORY_ID = TXC.TAX_CATEGORY_ID
                    AND   ATC.TAX_ATTRIBUTE_NAME = TXC.CUS_TAX_ATTRIBUTE
                    AND   ATC.ENABLED_FLAG = 'Y'
                    AND nvl(tgr.org_id,-99) = nvl(atc.org_id,-99))  --Bugfix 2367111
      AND    EXISTS ( SELECT ATC.TAX_ATTRIBUTE_VALUE
                    FROM JL_ZZ_AR_TX_ATT_CLS ATC
                    WHERE ATC.TAX_ATTR_CLASS_TYPE = 'TRANSACTION_CLASS'
                    AND   TGR.TRANSACTION_NATURE  = ATC.TAX_ATTRIBUTE_VALUE
                    AND   ATC.TAX_CATEGORY_ID = TXC.TAX_CATEGORY_ID
                    AND   ATC.TAX_ATTRIBUTE_TYPE = 'TRANSACTION_ATTRIBUTE'
                    AND   ATC.TAX_ATTRIBUTE_NAME = TXC.TXN_TAX_ATTRIBUTE
                    AND   ATC.TAX_ATTR_CLASS_CODE = ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf9
                    AND   ATC.ENABLED_FLAG = 'Y'
                    AND nvl(tgr.org_id,-99) = nvl(atc.org_id,-99))  --Bugfix 2367111
      AND nvl(tgr.org_id,-99) = nvl(p_org_id,-99)    --Bugfix 2367111
      AND nvl(tgr.org_id,-99) = nvl(txc.org_id,-99);  --Bugfix 2367111

    --Bug#5112515

  CURSOR c_grp_code_att_cm IS
    SELECT TGR.TRANSACTION_NATURE ATTRIBUTE3 ,
           TGR.ESTABLISHMENT_TYPE ATTRIBUTE5 ,
           TGR.CONTRIBUTOR_TYPE ATTRIBUTE8,
           TGR.CALCULATE_IN_OE
    FROM   JL_ZZ_AR_TX_GROUPS TGR ,
           JL_ZZ_AR_TX_CATEG TXC
    WHERE  TGR.GROUP_TAX_ID = ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern2
    AND    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE <= TGR.END_DATE_ACTIVE
    AND    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE >=
                             NVL(TGR.START_DATE_ACTIVE,
                                 ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE)
    AND    TGR.TAX_CATEGORY_ID = TXC.TAX_CATEGORY_ID
    AND    TXC.TAX_CATEGORY_ID = ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern1
    AND    NVL(TXC.START_DATE_ACTIVE,
               ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE) <=
                      ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE
    AND    TXC.END_DATE_ACTIVE >= ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE
    AND    TXC.TAX_RULE_SET = ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf1
    AND    EXISTS ( SELECT ATC.TAX_ATTRIBUTE_VALUE
                    FROM JL_ZZ_AR_TX_ATT_CLS ATC
                    WHERE ATC.TAX_ATTR_CLASS_TYPE = 'ORGANIZATION_CLASS'
                    AND   TGR.ESTABLISHMENT_TYPE = ATC.TAX_ATTRIBUTE_VALUE
                    AND   ATC.TAX_CATEGORY_ID = TXC.TAX_CATEGORY_ID
                    AND   TXC.TAX_CATEGORY_ID =
                                 ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern1
                    AND   ATC.TAX_ATTRIBUTE_TYPE = 'ORGANIZATION_ATTRIBUTE'
                    AND   ATC.TAX_ATTRIBUTE_NAME = TXC.ORG_TAX_ATTRIBUTE
                    AND   ATC.TAX_ATTR_CLASS_CODE = ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf10
                    AND   ATC.ENABLED_FLAG = 'Y')
    AND    EXISTS ( SELECT ATC.TAX_ATTRIBUTE_VALUE
                    FROM JL_ZZ_AR_TX_ATT_CLS ATC
                    WHERE ATC.TAX_ATTR_CLASS_TYPE = 'CONTRIBUTOR_CLASS'
                    AND   TGR.CONTRIBUTOR_TYPE = ATC.TAX_ATTRIBUTE_VALUE
                    AND   ATC.TAX_ATTRIBUTE_TYPE = 'CONTRIBUTOR_ATTRIBUTE'
                    AND   ATC.TAX_ATTR_CLASS_CODE =
                                 ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf6
                    AND   ATC.TAX_CATEGORY_ID = TXC.TAX_CATEGORY_ID
                    AND   TXC.TAX_CATEGORY_ID =
                                 ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern1
                    AND   ATC.TAX_ATTRIBUTE_NAME = TXC.CUS_TAX_ATTRIBUTE
                    AND   ATC.ENABLED_FLAG = 'Y' )
    AND    EXISTS ( SELECT ATC.TAX_ATTRIBUTE_VALUE
                    FROM JL_ZZ_AR_TX_ATT_CLS ATC
                    WHERE ATC.TAX_ATTR_CLASS_TYPE = 'TRANSACTION_CLASS'
                    AND   TGR.TRANSACTION_NATURE  = ATC.TAX_ATTRIBUTE_VALUE
                    AND   ATC.TAX_CATEGORY_ID = TXC.TAX_CATEGORY_ID
                    AND   TXC.TAX_CATEGORY_ID =
                                 ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern1
                    AND   ATC.TAX_ATTRIBUTE_TYPE = 'TRANSACTION_ATTRIBUTE'
                    AND   ATC.TAX_ATTRIBUTE_NAME = TXC.TXN_TAX_ATTRIBUTE
                    AND   ATC.TAX_ATTR_CLASS_CODE =
                                 ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf9
                    AND   ATC.ENABLED_FLAG = 'Y');



    CURSOR c_vat_tax (l_tax_code VARCHAR2) IS
      SELECT vat.taxable_basis,
             vat.tax_calculation_plsql_block,
             vat.tax_type,
             vat.tax_regime_code,
             vat.tax,
             vat.tax_status_code,
             vat.tax_code
      FROM ar_vat_tax_all_b vat       --Bugfix 2367111
      WHERE vat.set_of_books_id = ZX_PRODUCT_INTEGRATION_PKG.sysinfo.sysparam.set_of_books_id
      AND vat.tax_code = l_tax_code
      AND ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.trx_date BETWEEN vat.start_date AND
          NVL(vat.end_date, TO_DATE('31122199', 'DDMMYYYY'))
      AND NVL(vat.enabled_flag,'Y') = 'Y'
      AND NVL(vat.tax_class, 'O') = 'O'
      AND nvl(vat.org_id,-99) = nvl(p_org_id,-99);    --Bugfix 2367111

    CURSOR c_delimiter IS
      SELECT delimiter
      FROM   zx_fc_types_b
      WHERE  classification_type_code ='TRX_BUSINESS_CATEGORY';

    CURSOR c_delimiter_prod_cat IS
      SELECT delimiter
      FROM   zx_fc_types_b
      WHERE  classification_type_code ='PRODUCT_CATEGORY';

    l_org_id                   NUMBER;


  BEGIN


    g_current_runtime_level :=  FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    -- bug#6936808: init exception type
    g_jl_exception_type := 'N';

    IF p_org_id IS NULL THEN
      l_org_id := mo_global.get_current_org_id;
    else
      l_org_id := p_org_id;
    END IF;

    IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','JL_ZZ_TAX_INTEGRATION_PKG.expand_group_tax_code ()+');

       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Transaction Type Id: '||
                      to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_TYPE_ID));
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Ship to Site use id: '||
                      to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.SHIP_TO_SITE_USE_ID));
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Bill to Site use id: '||
                      to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.BILL_TO_SITE_USE_ID));
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Inventory Item Id: '||
                      to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.INVENTORY_ITEM_ID));
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Memo Line Id: '||
                      to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.MEMO_LINE_ID));
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Ship To Customer id: '||
                      to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.SHIP_TO_CUST_ID));
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Bill To Customer id: '||
                      to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.BILL_TO_CUST_ID));
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Tax Date: '||
                      to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE,'DD-MM-YYYY'));
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Ship From Warehouse Id: '||
                      to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.SHIP_FROM_WAREHOUSE_ID));
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Set Of Books Id: '||
                      to_char(ZX_PRODUCT_INTEGRATION_PKG.sysinfo.sysparam.set_of_books_id));
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Extended Amount: '||
                      to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.EXTENDED_AMOUNT));
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Vat Tax Id: '||
                      to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.VAT_TAX_ID));
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- userf1: '||ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf1);
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- userf2: '||ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf2);
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- userf4: '||ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf4);
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- userf6: '||ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf6 );
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- userf7: '||ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf7);
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- userf9: '||ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf9);
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- userf10 : '||ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf10 );
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- usern2: '||
                      to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern2));
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- usern3: '||
                      to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern3));
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- usern4: '||
                      to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern4));
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- usern6: '||
                      to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern6));
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- usern7: '||
                      to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern7));
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- usern8: '||
                      to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern8));
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- usern9: '||
                      to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern9));
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- usern10: '||
                      to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern10));
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- org_id  '||
                      to_char(l_org_id));
    END IF;

    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl.delete;

    -- ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf4 will contain a value 'OE'/'AR' if calling
    -- application is Order Management/Receivables respectively.
    -- Assign this value locally, so that ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf4 can be used
    -- for storing value from HZ_CUST_ACCT_SITES.GLOBAL_ATTRIBUTE9 to check if
    -- customer site profile has been overriden or not.
    IF ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern7 IN (1,2,3,4,5,8) THEN
      l_application := 'AR';
    ELSIF ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern7 IN (6,7) THEN
      l_application := 'OE';
    END IF;

    -- Populate Ship to and Bill to Details.
    populate_ship_bill2 (ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.ship_to_site_use_id,
                         ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.bill_to_site_use_id,
                         ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.ship_to_cust_id,
                         ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.bill_to_cust_id);

    -- Validate memo_line_id to AR_MEMO_LINES
    IF ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.memo_line_id IS NOT NULL and nvl(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern7,1) <> 1 THEN
      BEGIN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','Memo_lineId: '||ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.memo_line_id||
                           ' org_id: '||l_org_id);
        END IF;
        SELECT ml.line_type
        INTO   l_line_type
        FROM   ar_memo_lines_all_b ml     --Bugfix 2367111
        WHERE  ml.memo_line_id = ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.memo_line_id
        AND nvl(ml.org_id,-99) = nvl(l_org_id,-99);     --Bugfix 2367111
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('AR', 'GENERIC_MESSAGE');
          fnd_message.set_token('GENERIC_TEXT',
                                'EXCEPTION(NO_DATA_FOUND) : Memo Line');
          g_jl_exception_type := 'E';
          app_exception.raise_exception;

        WHEN OTHERS THEN
          fnd_message.set_name('AR', 'GENERIC_MESSAGE');
          fnd_message.set_token('GENERIC_TEXT',
                                'EXCEPTION(OTHERS) : Memo Line : ' || sqlerrm);
          g_jl_exception_type := 'E';
          app_exception.raise_exception;
      END;

      IF l_line_type <> 'LINE' THEN
        fnd_message.set_name('AR', 'GENERIC_MESSAGE');
        fnd_message.set_token('GENERIC_TEXT',
                              'Memo Line Type is not LINE');
        g_jl_exception_type := 'E';
        app_exception.raise_exception;
      END IF;
    END IF;

    --
    -- Bug# 3722082: Truncate event class code prefix in trx_business_category
    -- for eTax uptake
    --

    IF ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf2 IS NOT NULL THEN
     OPEN c_delimiter_prod_cat;
      FETCH c_delimiter_prod_cat INTO l_delimiter_prod_cat;
      CLOSE c_delimiter_prod_cat;

      ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf2 :=
          SUBSTR(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf2,
            INSTR(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf2,l_delimiter_prod_cat, 1) +1 );
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','
              -- Product Category after delimiter '|| ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf2);
      END IF;
    END IF;

    IF ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf9 IS NOT NULL THEN
      --
      -- get the delimiter first
      --

      OPEN c_delimiter;
      FETCH c_delimiter INTO l_delimiter;
      CLOSE c_delimiter;

      -- trunc event class code prefix
      ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf9 :=
              SUBSTR(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf9,
                INSTR(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf9, l_delimiter, 1) +1 );
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- trx_business_category: '||
                          ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf9);
      END IF;
    END IF;

    -- If Tax Type is TAX_GROUP
    IF ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf7 = 'TAX_GROUP' THEN

      -- Validate Required Parameters
      IF ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.trx_date IS NULL THEN
        fnd_message.set_name('AR', 'GENERIC_MESSAGE');
        fnd_message.set_token('GENERIC_TEXT',
                              'Required Parameter Missing: Transaction Date');
        g_jl_exception_type := 'E';
        app_exception.raise_exception;
     END IF;

     IF ZX_PRODUCT_INTEGRATION_PKG.sysinfo.sysparam.set_of_books_id IS NULL THEN
       fnd_message.set_name('AR', 'GENERIC_MESSAGE');
       fnd_message.set_token('GENERIC_TEXT',
                             'Required Parameter Missing: Set Of Books Id');
       g_jl_exception_type := 'E';
       app_exception.raise_exception;
     END IF;

     IF ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf1 IS NULL THEN
       fnd_message.set_name('AR', 'GENERIC_MESSAGE');
       fnd_message.set_token('GENERIC_TEXT',
                             'Required Parameter Missing: Tax Rule Set');
       g_jl_exception_type := 'E';
       app_exception.raise_exception;
     END IF;

     IF ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf6 IS NULL THEN
       fnd_message.set_name('AR', 'GENERIC_MESSAGE');
       fnd_message.set_token('GENERIC_TEXT',
                             'Required Parameter Missing: Contributor Condition Class ');
       g_jl_exception_type := 'E';
       app_exception.raise_exception;
     END IF;

     IF ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf9 IS NULL THEN
       fnd_message.set_name('AR', 'GENERIC_MESSAGE');
       fnd_message.set_token('GENERIC_TEXT',
                             'Required Parameter Missing: Transaction Condition Class');
       g_jl_exception_type := 'E';
       app_exception.raise_exception;
     END IF;

    IF ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf10 IS NULL THEN
      fnd_message.set_name('AR', 'GENERIC_MESSAGE');
      fnd_message.set_token('GENERIC_TEXT',
                            'Required Parameter Missing: Organization Condition Class');
      g_jl_exception_type := 'E';
      app_exception.raise_exception;
    END IF;

    IF ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern2 IS NULL THEN
      fnd_message.set_name('AR', 'GENERIC_MESSAGE');
      fnd_message.set_token('GENERIC_TEXT',
                            'Required Parameter Missing: Group Tax Id');
      g_jl_exception_type := 'E';
      app_exception.raise_exception;
    END IF;

    IF ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern8 IS NULL THEN
      fnd_message.set_name('AR', 'GENERIC_MESSAGE');
      fnd_message.set_token('GENERIC_TEXT',
                            'Required Parameter Missing: Customer Account Site Id');
      g_jl_exception_type := 'E';
      app_exception.raise_exception;
    END IF;

    -- Check if Override Customer Site Profile is set to 'Y'
    IF NVL(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf4,'N') = 'Y' THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','Using JL_ZZ_AR_TX_CUS_CLS for Contributor Class');
      END IF;

      -- Fetch Tax Group details
      FOR c_grp_code_cus_rec IN c_grp_code_cus
      LOOP

        IF (NVL(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern7,1) = 7 AND
            c_grp_code_cus_rec.calculate_in_oe = 'Y') OR
           (NVL(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern7,1) <> 7) THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN

            FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Fetching Tax Code for Tax Category: '
                             || c_grp_code_cus_rec.tax_category);
          END IF;

          l_index := l_index + 1;

          ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index) := ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec;

          ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).tax_line_number := l_index;

          ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).tax_code :=
          JL_ZZ_TAX.GET_CATEGORY_TAX_CODE (
                   c_grp_code_cus_rec.numeric_attribute1,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_TYPE_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.SHIP_TO_SITE_USE_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.BILL_TO_SITE_USE_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.INVENTORY_ITEM_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern2,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.MEMO_LINE_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.SHIP_TO_CUST_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.BILL_TO_CUST_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE,
                   l_application,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.SHIP_FROM_WAREHOUSE_ID,
                   'RATE',
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf2,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.SHIP_FROM_WAREHOUSE_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern9,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern10,
                   ZX_PRODUCT_INTEGRATION_PKG.sysinfo.sysparam.set_of_books_id,
                   c_grp_code_cus_rec.attribute3,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.EXTENDED_AMOUNT,
                   c_grp_code_cus_rec.attribute5,
                   c_grp_code_cus_rec.attribute8,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern4,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf9 );
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Tax Code: '
                                || ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).tax_code);
          END IF;

          IF ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).tax_code = 'NO_VALID_TAX_CODE' THEN
            FND_MESSAGE.SET_NAME('AR','GENERIC_MESSAGE');
            FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','No Tax Code associated to RATE level rule for Tax Category '||
			                       c_grp_code_cus_rec.tax_category ||' and Contributor Type '||c_grp_code_cus_rec.attribute8);
            g_jl_exception_type := 'E';
            app_exception.raise_exception;
          END IF;

          FOR c_vat_tax_rec IN c_vat_tax(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).tax_code)
          LOOP
            ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).taxable_basis :=
                      c_vat_tax_rec.taxable_basis;

            ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).tax_calculation_plsql_block :=
                      c_vat_tax_rec.tax_calculation_plsql_block;

            ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).userf7 :=
                      c_vat_tax_rec.tax_type;

            ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).tax_regime_code :=
                      c_vat_tax_rec.tax_regime_Code;

            ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).tax :=
                      c_vat_tax_rec.tax;

            ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).tax_status_code :=
                      c_vat_tax_rec.tax_status_code;

           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).tax_rate_code :=
                      c_vat_tax_rec.tax_code;

          exit;
          End Loop;

          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Tax Type: '
                                ||ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).userf7);
          END IF;

          IF (ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).usern3 is null) then
            ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).usern3 :=
            JL_ZZ_TAX.GET_TAX_BASE_RATE (
                   c_grp_code_cus_rec.numeric_attribute1,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_TYPE_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.SHIP_TO_SITE_USE_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.BILL_TO_SITE_USE_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.INVENTORY_ITEM_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern2,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.MEMO_LINE_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.SHIP_TO_CUST_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.BILL_TO_CUST_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE,
                   l_application,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.SHIP_FROM_WAREHOUSE_ID,
                   'BASE',
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf2,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.SHIP_FROM_WAREHOUSE_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern9,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern10,
                   c_grp_code_cus_rec.attribute3,
                   c_grp_code_cus_rec.attribute5,
                   c_grp_code_cus_rec.attribute8,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern4,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf9 );
          END IF;

          IF (g_level_statement >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Base Rate: '
                         || to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).usern3));
          END IF;

          ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).userf3 :=
                      c_grp_code_cus_rec.attribute3;

          ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).userf5 :=
                      c_grp_code_cus_rec.attribute5;

          ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).userf8 :=
                      c_grp_code_cus_rec.attribute8;

          ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).usern1 :=
                      c_grp_code_cus_rec.numeric_attribute1;

        ELSIF (NVL(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern7,1) = 7 AND
               nvl(c_grp_code_cus_rec.calculate_in_oe,'N') <> 'Y') THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Calculate In OM is not checked for '
                           || 'Tax Category '
                           || c_grp_code_cus_rec.tax_category
                           || ' With Tax Category Id '
                           || to_char(c_grp_code_cus_rec.numeric_attribute1));
          END IF;
        END IF;
      END LOOP;
    ELSE
      -- Override of Customer Site Profile is NOT set to 'Y'
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','Using JL_ZZ_AR_TX_ATT_CLS for Contributor Class');
      END IF;
      -- Fetch Tax Group details
      FOR c_grp_code_att_rec IN c_grp_code_att
      LOOP
        IF (NVL(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern7,1) = 7 AND
            c_grp_code_att_rec.calculate_in_oe = 'Y') OR
            (NVL(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern7,1) <> 7) THEN

          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Fetching Tax Code for Tax Category: '
                                || c_grp_code_att_rec.tax_category);
          END IF;

          l_index := l_index + 1;

          ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index) := ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec;

          ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).tax_line_number := l_index;

          ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).tax_code :=
          JL_ZZ_TAX.GET_CATEGORY_TAX_CODE (
                   c_grp_code_att_rec.numeric_attribute1,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_TYPE_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.SHIP_TO_SITE_USE_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.BILL_TO_SITE_USE_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.INVENTORY_ITEM_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern2,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.MEMO_LINE_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.SHIP_TO_CUST_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.BILL_TO_CUST_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE,
                   l_application,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.SHIP_FROM_WAREHOUSE_ID,
                   'RATE',
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf2,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.SHIP_FROM_WAREHOUSE_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern9,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern10,
                   ZX_PRODUCT_INTEGRATION_PKG.sysinfo.sysparam.set_of_books_id,
                   c_grp_code_att_rec.attribute3,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.EXTENDED_AMOUNT,
                   c_grp_code_att_rec.attribute5,
                   c_grp_code_att_rec.attribute8,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern4,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf9 );
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Tax Code: '
                                || ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).tax_code);
          END IF;

          IF ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).tax_code = 'NO_VALID_TAX_CODE' THEN
            FND_MESSAGE.SET_NAME('AR','GENERIC_MESSAGE');
            FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','No Tax Code associated to RATE level rule for Tax Category '||
			                       c_grp_code_att_rec.tax_category ||' and Contributor Type '||c_grp_code_att_rec.attribute8);
            g_jl_exception_type := 'E';
            app_exception.raise_exception;
          END IF;

          FOR c_vat_tax_rec IN c_vat_tax(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).tax_code)
          LOOP

            ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).taxable_basis :=
                      c_vat_tax_rec.taxable_basis;

            ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).tax_calculation_plsql_block :=
                      c_vat_tax_rec.tax_calculation_plsql_block;

            ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).userf7 :=
                      c_vat_tax_rec.tax_type;

          exit;

          End Loop;
          IF (g_level_statement >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Tax Type: '
                                ||ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).userf7);
          END IF;
          IF (ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).usern3 is null) then
            ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).usern3 :=
            JL_ZZ_TAX.GET_TAX_BASE_RATE (
                   c_grp_code_att_rec.numeric_attribute1,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_TYPE_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.SHIP_TO_SITE_USE_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.BILL_TO_SITE_USE_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.INVENTORY_ITEM_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern2,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.MEMO_LINE_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.SHIP_TO_CUST_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.BILL_TO_CUST_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE,
                   l_application,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.SHIP_FROM_WAREHOUSE_ID,
                   'BASE',
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf2,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.SHIP_FROM_WAREHOUSE_ID,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern9,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern10,
                   c_grp_code_att_rec.attribute3,
                   c_grp_code_att_rec.attribute5,
                   c_grp_code_att_rec.attribute8,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern4,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf9 );
          END IF;

          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Base Rate: '
                         || to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).usern3));
          END IF;

          ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).userf3 :=
                      c_grp_code_att_rec.attribute3;

          ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).userf5 :=
                      c_grp_code_att_rec.attribute5;

          ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).userf8 :=
                      c_grp_code_att_rec.attribute8;

          ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(l_index).usern1 :=
                      c_grp_code_att_rec.numeric_attribute1;

        ELSIF (NVL(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern7,1) = 7 AND
                  nvl(c_grp_code_att_rec.calculate_in_oe,'N') <> 'Y') THEN
               IF (g_level_statement >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Calculate In OM is not checked for '
                          || 'Tax Category '
                          || c_grp_code_att_rec.tax_category
                          || ' With Tax Category Id '
                          || to_char(c_grp_code_att_rec.numeric_attribute1));
               END IF;
        END IF;
      END LOOP;
    END IF;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','-- Number of Tax Lines for this transaction line: '||
                        to_char(l_index));
    END IF;

    IF l_index = 0 THEN

      -- Could not expand tax group successfully
      -- Log reasons for unsuccessful group expansion
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','***Reason(s) for Unsuccessful group expansion***');
      END IF;

      DECLARE
        l_tta_attrib_value jl_zz_ar_tx_att_cls.tax_attribute_value%type;
        l_ota_attrib_value jl_zz_ar_tx_att_cls.tax_attribute_value%type;
        l_cta_attrib_value jl_zz_ar_tx_cus_cls.tax_attribute_value%type;

        CURSOR c_tax_categ IS
          SELECT TGR.TAX_CATEGORY_ID,
                 TGR.CALCULATE_IN_OE,
                 TXC.TXN_TAX_ATTRIBUTE,
                 TXC.ORG_TAX_ATTRIBUTE,
                 TXC.CUS_TAX_ATTRIBUTE,
                 TGR.TRANSACTION_NATURE,
                 TGR.ESTABLISHMENT_TYPE,
                 TGR.CONTRIBUTOR_TYPE,
                 TXC.TAX_CATEGORY
          FROM JL_ZZ_AR_TX_GROUPS_ALL TGR ,    --Bugfix 2367111
               JL_ZZ_AR_TX_CATEG TXC
          WHERE  TGR.GROUP_TAX_ID = ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern2
          AND    TGR.TAX_CATEGORY_ID = TXC.TAX_CATEGORY_ID
          AND    NVL(TXC.START_DATE_ACTIVE, ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE) <=
                      ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE
          AND    TXC.END_DATE_ACTIVE >= ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE
          AND    TXC.TAX_RULE_SET = ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf1
          AND    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE <= TGR.END_DATE_ACTIVE
          AND    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE >= NVL(TGR.START_DATE_ACTIVE,
                                                ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.TRX_DATE)
          AND nvl(txc.org_id,-99) = nvl(l_org_id,-99)     --Bugfix 2367111
          AND nvl(txc.org_id,-99) = nvl(tgr.org_id,-99);  --Bugfix 2367111

        BEGIN

          FOR c_tax_categ_rec IN c_tax_categ
          LOOP

            -- Display Tax Group
            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','Tax Group : ' || ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_code);
            END IF;
            -- Match with Attribute Value of Transaction Class Type
            BEGIN
              SELECT TTA.TAX_ATTRIBUTE_VALUE
              INTO   l_tta_attrib_value
              FROM   JL_ZZ_AR_TX_ATT_CLS_ALL TTA   --Bugfix 2367111
              WHERE  TTA.TAX_ATTRIBUTE_VALUE
                        = c_tax_categ_rec.transaction_nature
              AND    TTA.TAX_ATTR_CLASS_TYPE = 'TRANSACTION_CLASS'
              AND    TTA.TAX_CATEGORY_ID = c_tax_categ_rec.tax_category_id
              AND    TTA.TAX_ATTRIBUTE_TYPE = 'TRANSACTION_ATTRIBUTE'
              AND    TTA.TAX_ATTRIBUTE_NAME = c_tax_categ_rec.txn_tax_attribute
              AND    TTA.TAX_ATTR_CLASS_CODE = ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf9
              AND    TTA.ENABLED_FLAG = 'Y'
              AND nvl(tta.org_id,-99) = nvl(l_org_id,-99);   --Bugfix 2367111

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                IF (g_level_unexpected >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_unexpected,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','Transaction Condition Class =>'
                         || ' Condition Name: '
                         || c_tax_categ_rec.txn_tax_attribute
                         || ' and Value: '
                         || c_tax_categ_rec.transaction_nature
                         || ' for Tax Category: '
                         || c_tax_categ_rec.tax_category
                         || ' does not match with values of Class Code: '
                         || ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf9);
                   END IF;

                fnd_message.set_name('JL','JL_ZZ_AR_TX_EXPAND_GROUP_TC');
                fnd_message.set_token('CATEGORY', c_tax_categ_rec.tax_category);
                fnd_message.set_token('TC_CODE', ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf9);
                fnd_message.set_token('GROUP', ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_code);
                -- Bug#6936808: set error to expected error
                g_jl_exception_type := 'E';
                app_exception.raise_exception;

              WHEN OTHERS THEN
                IF (g_level_unexpected >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_unexpected,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','EXCEPTION(OTHERS): '
                         || 'Transaction Condition Class');
                END IF;
            END;

            -- Match with Attribute Value of Organization Class Type
            BEGIN
              SELECT OTA.TAX_ATTRIBUTE_VALUE
              INTO l_ota_attrib_value
              FROM JL_ZZ_AR_TX_ATT_CLS_ALL OTA      --Bugfix 2367111
              WHERE OTA.TAX_ATTRIBUTE_VALUE = c_tax_categ_rec.establishment_type
              AND OTA.TAX_ATTR_CLASS_TYPE = 'ORGANIZATION_CLASS'
              AND OTA.TAX_CATEGORY_ID = c_tax_categ_rec.tax_category_id
              AND OTA.TAX_ATTRIBUTE_TYPE = 'ORGANIZATION_ATTRIBUTE'
              AND OTA.TAX_ATTRIBUTE_NAME = c_tax_categ_rec.org_tax_attribute
              AND OTA.TAX_ATTR_CLASS_CODE = ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf10
              AND OTA.ENABLED_FLAG = 'Y'
              AND NVL(ota.org_id,-99) = nvl(l_org_id,-99);  --Bugfix 2367111

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                IF (g_level_unexpected >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_unexpected,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','Organization Condition Class =>'
                         || ' Condition Name: '
                         || c_tax_categ_rec.org_tax_attribute
                         || ' and Value: '
                         || c_tax_categ_rec.establishment_type
                         || ' for Tax Category: '
                         || c_tax_categ_rec.tax_category
                         || ' does not match with values of Class Code: '
                         || ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf10);
                END IF;
                fnd_message.set_name('JL','JL_ZZ_AR_TX_EXPAND_GROUP_OC');
                fnd_message.set_token('CATEGORY', c_tax_categ_rec.tax_category);
                fnd_message.set_token('OC_CODE', ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf10);
                fnd_message.set_token('GROUP', ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_code);
                -- Bug#6936808: set error to expected error
                g_jl_exception_type := 'E';
                app_exception.raise_exception;

              WHEN OTHERS THEN
                IF (g_level_unexpected >= g_current_runtime_level ) THEN
                   FND_LOG.STRING(g_level_unexpected,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','EXCEPTION(OTHERS): '
                         || 'Organization Condition Class');
                END IF;
            END;

            -- Match with Attribute Value of Contributor Class
            BEGIN
              IF NVL(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf4,'N') = 'Y' THEN
                 SELECT CTA.TAX_ATTRIBUTE_VALUE
                 INTO   l_cta_attrib_value
                 FROM   JL_ZZ_AR_TX_CUS_CLS_ALL CTA     --Bugfix 2367111
                 WHERE  CTA.TAX_ATTRIBUTE_VALUE = c_tax_categ_rec.contributor_type
                 AND    CTA.ADDRESS_ID = ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern8
                 AND    CTA.TAX_CATEGORY_ID = c_tax_categ_rec.tax_category_id
                 AND    CTA.TAX_ATTRIBUTE_NAME = c_tax_categ_rec.cus_tax_attribute
                 AND    CTA.TAX_ATTR_CLASS_CODE = ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf6
                 AND    CTA.ENABLED_FLAG = 'Y'
                 AND nvl(cta.org_id,-99) = nvl(l_org_id,-99);    --Bugfix 2367111
              ELSE
                 SELECT CTA.TAX_ATTRIBUTE_VALUE
                 INTO   l_cta_attrib_value
                 FROM   JL_ZZ_AR_TX_ATT_CLS_ALL CTA --Bugfix 2367111
                 WHERE  CTA.TAX_ATTRIBUTE_VALUE = c_tax_categ_rec.contributor_type
                 AND    CTA.TAX_ATTR_CLASS_TYPE = 'CONTRIBUTOR_CLASS'
                 AND    CTA.TAX_ATTRIBUTE_TYPE = 'CONTRIBUTOR_ATTRIBUTE'
                 AND    CTA.TAX_CATEGORY_ID = c_tax_categ_rec.tax_category_id
                 AND    CTA.TAX_ATTRIBUTE_NAME = c_tax_categ_rec.cus_tax_attribute
                 AND    CTA.TAX_ATTR_CLASS_CODE = ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf6
                 AND    CTA.ENABLED_FLAG = 'Y'
                 AND nvl(cta.org_id,-99) = nvl(l_org_id,-99);  --Bugfix 2367111
              END IF;

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                IF (g_level_unexpected >= g_current_runtime_level ) THEN
                   FND_LOG.STRING(g_level_unexpected,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','Contributor Type =>'
                         || ' Condition Name: '
                         || c_tax_categ_rec.cus_tax_attribute
                         || ' and Value: '
                         || c_tax_categ_rec.contributor_type
                         || ' for Tax Category: '
                         || c_tax_categ_rec.tax_category
                         || ' does not match with values of Class Code: '
                         || ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf6);
                END IF;
                fnd_message.set_name('JL','JL_ZZ_AR_TX_EXPAND_GROUP_CC');
                fnd_message.set_token('CATEGORY', c_tax_categ_rec.tax_category);
                fnd_message.set_token('CC_CODE', ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf6);
                fnd_message.set_token('GROUP', ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_code);
                -- Bug#6936808: set error to expected error
                g_jl_exception_type := 'E';
                app_exception.raise_exception;

              WHEN OTHERS THEN
                IF (g_level_unexpected >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_unexpected,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','EXCEPTION(OTHERS): ' || 'Contributor Type');
                END IF;
            END;

          END LOOP;

        END;
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','expand_group_tax_code ()-');
        END IF;
        fnd_message.set_name('AR', 'GENERIC_MESSAGE');
        fnd_message.set_token('GENERIC_TEXT',
                              'Could not expand tax group successfully');
        g_jl_exception_type := 'E';
        app_exception.raise_exception;
      END IF;
    ELSE
      -- If Tax Type is not TAX_GROUP
      -- bug#5112515
      IF ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.credit_memo_flag = TRUE  THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                         'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG',
                         'Credit Memo and not Tax Group');
          FND_LOG.STRING(g_level_statement,
                         'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG',
                         'Previous Trx Line ID : ' ||
                         TO_CHAR(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.previous_customer_trx_line_id));
          FND_LOG.STRING(g_level_statement,
                         'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG',
                         'Tax Category ID: ' ||
                         TO_CHAR(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern1));
        END IF;

        IF ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern2 IS NULL THEN
          --
          -- obtain group tax id from previous trx line id
          -- Bug#5350983- use tax_classification_code instead of
          -- vat_tax_id and join by org_id

          BEGIN
            SELECT V.vat_tax_id
            INTO   l_group_tax_id
            FROM   RA_CUSTOMER_TRX_LINES_ALL TL,
                   AR_VAT_TAX_ALL           V
            WHERE  TL.customer_trx_line_id =
                       ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.previous_customer_trx_line_id
              AND TL.TAX_CLASSIFICATION_CODE = V.tax_code  --TL.vat_tax_id = V.vat_tax_id
              AND TL.org_id = V.org_id
              AND TL.org_id = l_org_id
              AND  V.tax_type = 'TAX_GROUP';
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                l_group_tax_id := NULL;
                IF (g_level_statement >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_statement,
                                 'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG',
                                 'No tax group id found');
                END IF;
          END;

          ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern2 := l_group_tax_id;

          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                           'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG',
                           'Tax Group ID: ' ||
                           TO_CHAR(l_group_tax_id));
          END IF;

        END IF;

        l_transaction_nature  := NULL;
        l_establishment_type  := NULL;
        l_contributor_type    := NULL;
        l_calculate_in_oe     := NULL;

        -- Check if Override Customer Site Profile is set to 'Y'
        IF NVL(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf4,'N') = 'Y' THEN

          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                           'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG',
                           'Using JL_ZZ_AR_TX_CUS_CLS for Contributor Class');
          END IF;

           OPEN c_grp_code_cus_cm;
           FETCH c_grp_code_cus_cm INTO
              l_transaction_nature,
              l_establishment_type,
              l_contributor_type,
              l_calculate_in_oe;
           CLOSE c_grp_code_cus_cm;

           IF (NVL(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern7,1) = 7 AND
               l_calculate_in_oe = 'Y')
              OR (NVL(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern7,1) <> 7) THEN
              ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf3 := l_transaction_nature;
              ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf5 := l_establishment_type;
              ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf8 := l_contributor_type;
           END IF;
        ELSE
          -- Override of Customer Site Profile is NOT set to 'Y'
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                           'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG',
                           'Using JL_ZZ_AR_TX_ATT_CLS for Contributor Class');
          END IF;

          OPEN c_grp_code_att_cm;
          FETCH c_grp_code_att_cm INTO
            l_transaction_nature,
            l_establishment_type,
            l_contributor_type,
            l_calculate_in_oe;
          CLOSE c_grp_code_att_cm;

          IF (NVL(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern7,1) = 7 AND
               l_calculate_in_oe = 'Y')
              OR (NVL(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern7,1) <> 7) THEN
              ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf3 := l_transaction_nature;
              ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf5 := l_establishment_type;
              ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf8 := l_contributor_type;
          END IF;

        END IF;  -- check Customer Site Profile

        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                         'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG',
                         'Transaction Nature: ' || l_transaction_nature);
          FND_LOG.STRING(g_level_statement,
                         'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG',
                         'Establishment Type: '|| l_establishment_type);
          FND_LOG.STRING(g_level_statement,
                         'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG',
                         'Contributor Type: '|| l_contributor_type);
        END IF;

      END IF;    -- credit_memo_flag = TRUE

      ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec_tbl(1) := ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec;
    END IF;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX_INTEGRATION_PKG','JL_ZZ_TAX_INTEGRATION_PKG.expand_group_tax_code ()-');
    END IF;

  END expand_group_tax_code;

END JL_ZZ_TAX_INTEGRATION_PKG;

/
