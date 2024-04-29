--------------------------------------------------------
--  DDL for Package Body JL_ZZ_TAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_TAX" AS
/* $Header: jlzzrtxb.pls 120.19.12010000.7 2010/02/05 09:18:17 ssohal ship $ */

--PG_DEBUG varchar2(1) :=  NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
-- Bugfix# 3259701
--PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

  g_current_runtime_level NUMBER;
  g_level_statement       CONSTANT  NUMBER   := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure       CONSTANT  NUMBER   := FND_LOG.LEVEL_PROCEDURE;
  g_level_event           CONSTANT  NUMBER   := FND_LOG.LEVEL_EVENT;
  g_level_exception       CONSTANT  NUMBER   := FND_LOG.LEVEL_EXCEPTION;
  g_level_unexpected      CONSTANT  NUMBER   := FND_LOG.LEVEL_UNEXPECTED;

PROCEDURE get_rule_legal_message (
              p_tax_category_id             IN     NUMBER,
              p_cust_trx_type_id            IN     NUMBER,
              p_ship_to_site_use_id         IN     NUMBER,
              p_bill_to_site_use_id         IN     NUMBER,
              p_inventory_item_id           IN     NUMBER,
              p_group_tax_id                IN     NUMBER,
              p_memo_line_id                IN     NUMBER,
              p_ship_to_customer_id         IN     NUMBER,
              p_bill_to_customer_id         IN     NUMBER,
              p_trx_date                    IN     DATE,
              p_application                 IN     VARCHAR2,
              p_ship_from_warehouse_id      IN     NUMBER,
              p_fiscal_classification_code  IN     VARCHAR2,
              p_inventory_organization_id   IN     NUMBER,
              p_location_structure_id       IN     NUMBER,
              p_location_segment_num        IN     NUMBER,
              p_set_of_books_id             IN     NUMBER,
              p_transaction_nature          IN     VARCHAR2,
              p_base_amount                 IN     NUMBER,
              p_establishment_type          IN     VARCHAR2,
              p_contributor_type            IN     VARCHAR2,
              p_warehouse_location_id       IN     NUMBER,
              p_transaction_nature_class    IN     VARCHAR2,
              p_use_legal_message           IN     VARCHAR2,
              p_base_rate                   IN     NUMBER,
              p_legal_message_exception     IN     VARCHAR2,
              o_rule_id                     IN OUT NOCOPY NUMBER,
              o_legal_message8              IN OUT NOCOPY VARCHAR2,
              o_legal_message9              IN OUT NOCOPY VARCHAR2) IS

  v_rule_id  NUMBER;
  v_tax_code VARCHAR2(50);
  v_base_rate NUMBER;
  v_rule_data_id NUMBER;
  o_tax_code VARCHAR2(50);
  o_base_rate NUMBER;
  o_rule_data_id NUMBER;


BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message()+');
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-P- Tax category passed: '||to_char(p_tax_category_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-P- Tax base rate passed: '||to_char(p_base_rate));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-P- Tax base amount passed: '||to_char(p_base_amount));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-P- Tax group passed: '||to_char(p_group_tax_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-P- Transaction Type: '||to_char(p_cust_trx_type_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-P- Inventory Item Id: '||to_char(p_inventory_item_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-P- Memo Line Id: '||to_char(p_memo_line_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-P- Ship To Cust Id: '||to_char(p_ship_to_customer_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-P- Bill To Cust Id: '||to_char(p_bill_to_customer_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-P- Application: '||p_application);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-P- Ship From Warehouse Id: '||
                                             to_char(p_ship_from_warehouse_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-P- Inventory Organization Id: '||
                                          to_char(p_inventory_organization_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-P- Fiscal Classification Code: '||
                                                  p_fiscal_classification_code);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-P- Warehouse Location Id: '||
                                              to_char(p_warehouse_location_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-P- Location Structure Id: '||
                                              to_char(p_location_structure_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-P- Location Segment Number: '||p_location_segment_num);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-P- Trx Nature: '|| p_transaction_nature);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-P- Trx Nature Class: '||p_transaction_nature_class);
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-P- Trx date: '    ||to_char(p_trx_date,'DD-MM-YYYY'));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-P- Ship to Site: '||to_char(p_ship_to_site_use_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-P- Bill to site: '||to_char(p_bill_to_site_use_id) );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-P- Establishment Type: '|| p_establishment_type);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-P- Contributor Type: '|| p_contributor_type);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-P- Set Of Books Id: '||to_char(p_set_of_books_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-P- Use Legal Message: '|| p_use_legal_message);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-P- Legal Message Exception: '|| p_legal_message_exception);
  END IF;

  get_category_tax_rule ( p_tax_category_id,
                          p_cust_trx_type_id,
                          p_ship_to_site_use_id,
                          p_bill_to_site_use_id,
                          p_inventory_item_id,
                          p_group_tax_id,
                          p_memo_line_id,
                          p_ship_to_customer_id,
                          p_bill_to_customer_id,
                          p_trx_date,
                          p_application,
                          p_ship_from_warehouse_id,
                          'RATE',
                          p_fiscal_classification_code,
                          p_inventory_organization_id,
                          p_location_structure_id,
                          p_location_segment_num,
                          p_set_of_books_id,
                          p_transaction_nature,
                          p_base_amount,
                          p_establishment_type,
                          p_contributor_type,
                          p_warehouse_location_id,
                          p_transaction_nature_class,
                          o_tax_code,
                          o_base_rate,
                          o_rule_data_id,
                          o_rule_id);

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-- Rule Id: '||to_char(o_rule_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-- Rule Data Id: '||to_char(o_rule_data_id));
  END IF;

  IF p_use_legal_message = 'Y' AND p_application = 'AR' THEN

     IF ((p_base_rate IS NOT NULL) AND (p_base_rate <= 0)) THEN

        get_category_tax_rule (
                          p_tax_category_id,
                          p_cust_trx_type_id,
                          p_ship_to_site_use_id,
                          p_bill_to_site_use_id,
                          p_inventory_item_id,
                          p_group_tax_id,
                          p_memo_line_id,
                          p_ship_to_customer_id,
                          p_bill_to_customer_id,
                          p_trx_date,
                          p_application,
                          p_ship_from_warehouse_id,
                          'BASE',
                          p_fiscal_classification_code,
                          p_inventory_organization_id,
                          p_location_structure_id,
                          p_location_segment_num,
                          p_set_of_books_id,
                          p_transaction_nature,
                          p_base_amount,
                          p_establishment_type,
                          p_contributor_type,
                          p_warehouse_location_id,
                          p_transaction_nature_class,
                          v_tax_code,
                          v_base_rate,
                          v_rule_data_id,
                          v_rule_id);

        IF (g_level_statement >= g_current_runtime_level) THEN
        	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-- Rule Id: '||to_char(v_rule_id));
        	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-- Rule Data Id: '||to_char(v_rule_data_id));
        END IF;

        o_legal_message8 := get_legal_message (v_rule_id,
                                               v_rule_data_id,
                                               'BASE_AMOUNT_REDUCTION',
                                               p_ship_from_warehouse_id);

        IF (g_level_statement >= g_current_runtime_level) THEN
        	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-- Legal Message8: '|| o_legal_message8);
        END IF;

     END IF;

     IF p_legal_message_exception IS NOT NULL AND
       (p_legal_message_exception <> 'BASE_AMOUNT_REDUCTION')
     THEN
       o_legal_message9 := get_legal_message ( o_rule_id,
                                               o_rule_data_id,
                                               p_legal_message_exception,
                                               p_ship_from_warehouse_id);

        IF (g_level_statement >= g_current_runtime_level) THEN
        	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message: ' || '-- Legal Message9: '|| o_legal_message9);
        END IF;

     END IF;

  END IF;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_rule_legal_message()-');
  END IF;
END get_rule_legal_message;

--========================================================================
-- PUBLIC PROCEDURE
--    get_rule_info
--
-- DESCRIPTION
--    The procedure returns the tax code for a given rule
--    Each rule specifies a search for the tax code in a determined table.
--    For the new tables each row has a tax code associated to a tax
--    category. For the core product tables, the tax code can be TAX_TYPE =
--    'TAX_GROUP' or 'VAT'. If the tax type is 'TAX_GROUP' the function
--    returns the tax code associated to the tax category passed to the
--    function. If the tax category is not defined in this tax group, the
--    function continues to search for the tax code in the other rules. If
--    the tax type is 'VAT' the tax code is considered to be associated to
--    the tax category of the tax code.
--
-- PARAMETERS
--    p_rule        Rule to be checked
--    o_tax_code    Tax     code corresponding to the rule
--
-- RETURNS
--    tax code
--
-- CALLED FROM
--    jl_zz_tax.get_category_tax_code
--    jl_zz_tax.get_tax_base_rate
--    jl_zz_tax.get_category_tax_rule
--
-- HISTORY
--========================================================================

PROCEDURE get_rule_info(
           p_rule                       IN     VARCHAR2,
           p_fiscal_classification_code IN     VARCHAR2,
           p_tax_category_id            IN     NUMBER,
           p_trx_date                   IN     DATE,
           p_ship_to_site_use_id        IN     NUMBER,
           p_bill_to_site_use_id        IN     NUMBER,
           p_inventory_item_id          IN     NUMBER,
           p_ship_from_warehouse_id     IN     NUMBER,
           p_group_tax_id               IN     NUMBER,
           p_contributor_type           IN     VARCHAR2,
           p_transaction_nature         IN     VARCHAR2,
           p_establishment_type         IN     VARCHAR2,
           p_transaction_nature_class   IN     VARCHAR2,
           p_inventory_organization_id  IN     NUMBER,
           p_ship_to_customer_id        IN     NUMBER,
           p_bill_to_customer_id        IN     NUMBER,
           p_warehouse_location_id      IN     NUMBER,
           p_memo_line_id               IN     NUMBER,
           p_base_amount                IN     NUMBER,
           p_application                IN     VARCHAR2,
           o_tax_code                   IN OUT NOCOPY VARCHAR2,
           o_base_rate                  IN OUT NOCOPY NUMBER,
           o_rule_data_id               IN OUT NOCOPY NUMBER ) IS

  -- Bugfix 1388703
  CURSOR c_category IS
    SELECT cat.tax_code,
           NULL,
           NULL
    FROM   jl_zz_ar_tx_cat_dtl cat
    WHERE  cat.tax_category_id = p_tax_category_id
    AND    p_trx_date <= cat.end_date_active
    AND    p_trx_date >= NVL(cat.start_date_active,p_trx_date)
    UNION
    SELECT cat.tax_code,
           NULL,
           NULL
    FROM   jl_zz_ar_tx_categ cat
    WHERE  cat.tax_category_id = p_tax_category_id
    AND    p_trx_date <= cat.end_date_active
    AND    p_trx_date >= NVL(cat.start_date_active,p_trx_date);

  -- Bugfix 1388703
  CURSOR c_item IS
    SELECT si.tax_code,
           NULL,
           si.inventory_item_id
    FROM   mtl_system_items si
    WHERE  si.inventory_item_id = p_inventory_item_id
    AND    si.organization_id   = p_inventory_organization_id
    AND    exists (select 1
                   from   ar_vat_tax vt
                   WHERE  vt.tax_code = si.tax_code
                   AND    vt.tax_type = 'VAT'
                   AND    decode(ltrim(vt.global_attribute1, '0123456789'),
                          null, to_number(vt.global_attribute1), null) =
                                    p_tax_category_id
                   AND    nvl(vt.enabled_flag,'Y') = 'Y'
                   AND    nvl(vt.tax_class,'O') = 'O'
                   AND    p_trx_date >= vt.start_date
                   AND    p_trx_date <= nvl(vt.end_date,p_trx_date))
    UNION
    SELECT tg.tax_code,
           NULL,
           si.inventory_item_id
    FROM   mtl_system_items si
          ,ar_vat_tax vt
          ,jl_zz_ar_tx_groups tg
          ,ar_vat_tax vt1
    WHERE  si.inventory_item_id = p_inventory_item_id
    AND    si.organization_id   = p_inventory_organization_id
    AND    si.tax_code = vt.tax_code
    AND    vt.tax_type = 'TAX_GROUP'
    AND    p_trx_date >= vt1.start_date
    AND    p_trx_date <= nvl(vt1.end_date,p_trx_date)
    AND    tg.group_tax_id = vt.vat_tax_id
    AND    nvl(vt1.enabled_flag,'Y') = 'Y'
    AND    nvl(vt1.tax_class,'O') = 'O'
    AND    tg.tax_category_id    = p_tax_category_id
    AND    tg.contributor_type   = p_contributor_type
    AND    tg.establishment_type = p_establishment_type
    AND    tg.transaction_nature = p_transaction_nature
    AND    tg.tax_code = vt1.tax_code
    AND    p_trx_date <= tg.end_date_active
    AND    p_trx_date >= NVL(tg.start_date_active, p_trx_date);


  -- Bugfix 1388703
  CURSOR c_customer IS
    SELECT c.tax_code,
           NULL,
           c.cust_account_id
    FROM   hz_cust_accounts c
    WHERE  c.cust_account_id = NVL(p_ship_to_customer_id,
                                   p_bill_to_customer_id)
    AND    exists (select 1
                   from   ar_vat_tax vt
                   WHERE  c.tax_code    = vt.tax_code
    		   AND    vt.tax_type   = 'VAT'
    		   AND  decode(ltrim(vt.global_attribute1,
                                     '0123456789'),
                                       null,
                        to_number(vt.global_attribute1),null) =
                                  p_tax_category_id
    		   AND    p_trx_date >= vt.start_date
    		   AND    p_trx_date <= nvl(vt.end_date,p_trx_date)
    		   AND    nvl(vt.enabled_flag,'Y') = 'Y'
    		   AND    nvl(vt.tax_class,'O') = 'O')
    UNION
    SELECT tg.tax_code,
           NULL,
           c.cust_account_id
    FROM   hz_cust_accounts c
          ,ar_vat_tax vt
          ,jl_zz_ar_tx_groups tg
          ,ar_vat_tax vt1
    WHERE  c.cust_account_id = NVL(p_ship_to_customer_id,
                                   p_bill_to_customer_id)
    AND    c.tax_code    = vt.tax_code
    AND    vt.tax_type   = 'TAX_GROUP'
    AND    tg.tax_category_id = p_tax_category_id
    AND    tg.tax_code   = vt1.tax_code
    AND    p_trx_date >= vt1.start_date
    AND    p_trx_date <= nvl(vt1.end_date,p_trx_date)
    AND    nvl(vt1.enabled_flag,'Y') = 'Y'
    AND    nvl(vt1.tax_class,'O') = 'O'
    AND    tg.group_tax_id       = vt.vat_tax_id
    AND    tg.contributor_type   = p_contributor_type
    AND    tg.transaction_nature = p_transaction_nature
    AND    tg.establishment_type = p_establishment_type
    AND    p_trx_date <= tg.end_date_active
    AND    p_trx_date >= NVL(tg.start_date_active, p_trx_date);

  -- Bugfix 1388703
  CURSOR c_bill_to IS
    SELECT su.tax_code,
           NULL,
           su.site_use_id
    FROM   hz_cust_site_uses su
    WHERE  su.site_use_id = p_bill_to_site_use_id
    AND    exists (select 1
                   from   ar_vat_tax vt
                   WHERE  su.tax_code = vt.tax_code
    		   AND    vt.tax_type = 'VAT'
    		   AND    decode(ltrim(vt.global_attribute1,
                                       '0123456789'),
               		  null,
               to_number(vt.global_attribute1),null) = p_tax_category_id
    		   AND    p_trx_date >= vt.start_date
    		   AND    p_trx_date <= nvl(vt.end_date,p_trx_date)
    		   AND    nvl(vt.enabled_flag,'Y') = 'Y'
    		   AND    nvl(vt.tax_class,'O') = 'O')
    UNION
    SELECT tg.tax_code,
           NULL,
           su.site_use_id
    FROM   hz_cust_site_uses su
          ,ar_vat_tax vt
          ,jl_zz_ar_tx_groups tg
          ,ar_vat_tax vt1
    WHERE  su.site_use_id = p_bill_to_site_use_id
    AND    su.tax_code = vt.tax_code
    AND    vt.tax_type = 'TAX_GROUP'
    AND    tg.group_tax_id = vt.vat_tax_id
    AND    tg.tax_category_id = p_tax_category_id
    AND    tg.contributor_type = p_contributor_type
    AND    tg.transaction_nature = p_transaction_nature
    AND    tg.establishment_type = p_establishment_type
    AND    tg.tax_code = vt1.tax_code
    AND    p_trx_date >= vt1.start_date
    AND    p_trx_date <= nvl(vt1.end_date,p_trx_date)
    AND    nvl(vt1.enabled_flag,'Y') = 'Y'
    AND    nvl(vt1.tax_class,'O') = 'O'
    AND    p_trx_date <= tg.end_date_active
    AND    p_trx_date >= NVL(tg.start_date_active, p_trx_date);

  -- Bugfix 1388703
  CURSOR c_ship_to IS
    SELECT su.tax_code,
           NULL,
           su.site_use_id
    FROM   hz_cust_site_uses su
    WHERE  su.site_use_id = p_ship_to_site_use_id
    AND    exists (select 1
                   from   ar_vat_tax vt
    		   WHERE  su.tax_code = vt.tax_code
    		   AND    vt.tax_type = 'VAT'
    		   AND decode(ltrim(vt.global_attribute1,
                                     '0123456789'),null,
              	           to_number(vt.global_attribute1),null)
                                   = p_tax_category_id
    		   AND    p_trx_date >= vt.start_date
    		   AND    p_trx_date <= nvl(vt.end_date,p_trx_date)
    		   AND    nvl(vt.enabled_flag,'Y') = 'Y'
    		   AND    nvl(vt.tax_class,'O') = 'O' )
    UNION
    SELECT tg.tax_code,
           NULL,
           su.site_use_id
    FROM   hz_cust_site_uses su
          ,ar_vat_tax vt
          ,jl_zz_ar_tx_groups tg
          ,ar_vat_tax vt1
    WHERE  su.site_use_id = p_ship_to_site_use_id
    AND su.tax_code = vt.tax_code
    AND vt.tax_type = 'TAX_GROUP'
    AND tg.group_tax_id = vt.vat_tax_id
    AND tg.tax_category_id = p_tax_category_id
    AND tg.contributor_type = p_contributor_type
    AND tg.transaction_nature = p_transaction_nature
    AND tg.establishment_type = p_establishment_type
    AND tg.tax_code = vt1.tax_code
    AND p_trx_date >= vt1.start_date
    AND p_trx_date <= nvl(vt1.end_date,p_trx_date)
    AND nvl(vt1.enabled_flag,'Y') = 'Y'
    AND nvl(vt1.tax_class,'O') = 'O'
    AND p_trx_date <= tg.end_date_active
    AND p_trx_date >= NVL(tg.start_date_active, p_trx_date);

  -- Bugfix 1388703
  CURSOR c_organization IS
    SELECT hrl.global_attribute6 tax_code,
           NULL,
           p_ship_from_warehouse_id
    FROM  hr_locations_all hrl
    WHERE hrl.location_id     = p_warehouse_location_id
    AND   exists (select 1
                  from ar_vat_tax vt
                  WHERE hrl.global_attribute6 = vt.tax_code
    		  AND   vt.tax_type = 'VAT'
    		  AND   decode(ltrim(vt.global_attribute1,'0123456789'),
               		 null, to_number(vt.global_attribute1),
                                         null) = p_tax_category_id
    		  AND   p_trx_date >= vt.start_date
    		  AND   p_trx_date <= nvl(vt.end_date,p_trx_date)
    		  AND   nvl(vt.enabled_flag,'Y') = 'Y'
    		  AND   nvl(vt.tax_class,'O') = 'O')
    UNION
    SELECT tg.tax_code tax_code,
           NULL,
           p_ship_from_warehouse_id
    FROM  jl_zz_ar_tx_groups tg
    WHERE tg.tax_category_id = p_tax_category_id
    AND   tg.contributor_type = p_contributor_type
    AND   tg.transaction_nature = p_transaction_nature
    AND   tg.establishment_type = p_establishment_type
    AND   p_trx_date <= tg.end_date_active
    AND   p_trx_date >= NVL(tg.start_date_active, p_trx_date)
    AND   exists (select 1
                  from   ar_vat_tax vt1,
                         ar_vat_tax vt,
                         hr_locations_all hrl
    		  WHERE  hrl.location_id = p_warehouse_location_id
    		  AND    hrl.global_attribute6 = vt.tax_code
    		  AND    vt.tax_type = 'TAX_GROUP'
    		  AND    tg.group_tax_id = vt.vat_tax_id
    		  AND    tg.tax_code = vt1.tax_code
    		  AND    nvl(vt1.enabled_flag,'Y') = 'Y'
    		  AND    nvl(vt1.tax_class,'O') = 'O'
	          AND    p_trx_date >= vt1.start_date
	          AND    p_trx_date <= NVL(vt1.end_date, p_trx_date));

  -- Bugfix 1388703
  CURSOR c_sysparam IS
    SELECT sp.tax_classification_code,
           NULL,
           NULL
    FROM   zx_product_options sp
          ,ar_vat_tax vt
    WHERE  sp.application_id = 222
    AND    sp.org_id = vt.org_id
    AND    sp.tax_classification_code = vt.tax_code
    AND    vt.tax_type = 'VAT'
    AND    decode(ltrim(vt.global_attribute1, '0123456789'), null,
               to_number(vt.global_attribute1), null) = p_tax_category_id
    AND    p_trx_date >= vt.start_date
    AND    p_trx_date <= nvl(vt.end_date,p_trx_date)
    AND    nvl(vt.enabled_flag,'Y') = 'Y'
    AND    nvl(vt.tax_class,'O') = 'O'
    UNION
    SELECT tg.tax_code,
           NULL,
           NULL
    FROM   jl_zz_ar_tx_groups tg
    WHERE  tg.tax_category_id = p_tax_category_id
    AND    tg.contributor_type = p_contributor_type
    AND    tg.transaction_nature = p_transaction_nature
    AND    tg.establishment_type = p_establishment_type
    AND    p_trx_date <= tg.end_date_active
    AND    p_trx_date >= NVL(tg.start_date_active, p_trx_date)
    AND    exists (select 1
    		   from   ar_vat_tax vt1
          		  ,ar_vat_tax vt
    		          ,zx_product_options sp
    		   WHERE  sp.tax_classification_code = vt.tax_code
                   AND    sp.application_id = 222
                   AND    sp.org_id = vt.org_id
    		   AND    vt.tax_type = 'TAX_GROUP'
    		   AND    tg.group_tax_id = vt.vat_tax_id
    		   AND    tg.tax_code = vt1.tax_code
    		   AND    nvl(vt1.enabled_flag,'Y') = 'Y'
    		   AND    nvl(vt1.tax_class,'O') = 'O'
    		   AND    p_trx_date >= vt1.start_date
    		   AND    p_trx_date <= NVL(vt1.end_date,p_trx_date));

  -- Bugfix 1388703
  CURSOR c_memo_line IS
    SELECT ml.tax_code,
           NULL,
           ml.memo_line_id
    FROM   ar_memo_lines ml
    WHERE  ml.memo_line_id = p_memo_line_id
    AND    exists (select 1
                   from   ar_vat_tax vt
                   WHERE  ml.tax_code = vt.tax_code
    		   AND    vt.tax_type = 'VAT'
    		   AND  decode(ltrim(vt.global_attribute1,
                               '0123456789'), null,
               	        to_number(vt.global_attribute1), null)
                           = p_tax_category_id
    		   AND    p_trx_date >= vt.start_date
    		   AND    p_trx_date <= nvl(vt.end_date,p_trx_date)
    		   AND    nvl(vt.enabled_flag,'Y') = 'Y'
    		   AND    nvl(vt.tax_class,'O') = 'O')
    UNION
    SELECT tg.tax_code,
           NULL,
           ml.memo_line_id
    FROM   ar_memo_lines ml
          ,ar_vat_tax vt
          ,jl_zz_ar_tx_groups tg
          ,ar_vat_tax vt1
    WHERE  memo_line_id = p_memo_line_id
    AND    ml.tax_code = vt.tax_code
    AND    vt.tax_type = 'TAX_GROUP'
    AND    tg.group_tax_id = vt.vat_tax_id
    AND    tg.tax_category_id = p_tax_category_id
    AND    tg.contributor_type = p_contributor_type
    AND    tg.transaction_nature = p_transaction_nature
    AND    tg.establishment_type = p_establishment_type
    AND    tg.tax_code = vt1.tax_code
    AND    p_trx_date >= vt1.start_date
    AND    p_trx_date <= nvl(vt1.end_date,p_trx_date)
    AND    nvl(vt1.enabled_flag,'Y') = 'Y'
    AND    nvl(vt1.tax_class,'O') = 'O'
    AND    p_trx_date <= tg.end_date_active
    AND    p_trx_date >= NVL(tg.start_date_active, p_trx_date);

  -- Bugfix 1388703
  CURSOR c_tax_schedule IS
    SELECT tax_code,
           NULL,
           NULL
    FROM   jl_zz_ar_tx_schedules
    WHERE  tax_category_id = p_tax_category_id
    AND    p_base_amount BETWEEN min_taxable_basis
                         AND     max_taxable_basis
    AND    p_trx_date <= end_date_active
    AND    p_trx_date >= NVL(start_date_active,p_trx_date);

  -- Bugfix 1388703
  CURSOR c_fiscal_classif IS
    SELECT fc.tax_code,
           fc.base_rate,
           fc.fsc_cls_id
    FROM   jl_zz_ar_tx_fsc_cls fc
    WHERE  fc.fiscal_classification_code = p_fiscal_classification_code
    AND    fc.tax_category_id = p_tax_category_id
    AND    fc.enabled_flag = 'Y'
    AND    p_trx_date <= fc.end_date_active
    AND    p_trx_date >= NVL(fc.start_date_active,p_trx_date);

  -- Bugfix 1388703
  -- Geography uptake
  CURSOR c_location IS
    SELECT loc.tax_code,
           loc.base_rate,
           loc.locn_id
    FROM   jl_zz_ar_tx_locn loc
    WHERE  loc.tax_category_id = p_tax_category_id
    AND    p_trx_date <= loc.end_date_active
    AND    p_trx_date >= NVL(loc.start_date_active, p_trx_date)
    AND    exists (select 1
                   from   hz_geographies lv
          	 	 ,hz_cust_acct_sites ad
          		 ,hz_cust_site_uses su
			 ,hz_party_sites p
                         ,hz_locations lc
          		 ,ar_system_parameters sp
          		 ,hr_locations_all hrl
    		   WHERE  hrl.location_id = p_warehouse_location_id
    		   AND    loc.ship_from_code = hrl.REGION_2
    		   AND    loc.ship_to_segment_id = lv.geography_id
    		   AND    lv.geography_type = sp.global_attribute9
       	       	   AND    UPPER(lv.geography_name) =
                          UPPER(decode(sp.global_attribute9,'STATE',lc.state,lc.province))
    		   AND    su.cust_acct_site_id  = ad.cust_acct_site_id
                   AND    ad.party_site_id =p.party_site_id
                   AND    p.location_id =lc.location_id
    		   AND    su.site_use_id = NVL(p_ship_to_site_use_id,
                                               p_bill_to_site_use_id));

  -- geography related changes..
  -- Bugfix 1388703
  CURSOR c_exc_fiscal_classif IS
    SELECT exc.tax_code,
           exc.base_rate,
           exc.exc_fsc_id
    FROM   jl_zz_ar_tx_exc_fsc exc
    WHERE exc.fiscal_classification_code = p_fiscal_classification_code
    AND   exc.tax_category_id = p_tax_category_id
    AND   p_trx_date <= exc.end_date_active
    AND   p_trx_date >= NVL(exc.start_date_active, p_trx_date)
    AND   exists (select 1
    		  from   hz_geographies lv
          		 ,hz_cust_acct_sites ad
          		 ,hz_cust_site_uses su
                         ,hz_party_sites p
                         ,hz_locations loc
          		 ,ar_system_parameters sp
          		 ,hr_locations_all hrl
    		 WHERE hrl.location_id     = p_warehouse_location_id
    		 AND   exc.ship_from_code =  hrl.REGION_2
    		 AND   exc.ship_to_segment_id = lv.geography_id
    		 AND   lv.geography_type = sp.global_attribute9
                 AND   ad.party_site_id=p.party_site_id
		 AND   p.location_id=loc.location_id
    	         AND   UPPER(lv.geography_name) = UPPER(decode(sp.global_attribute9,
                                               'STATE', loc.state, loc.province))
    		 AND   su.cust_acct_site_id = ad.cust_acct_site_id
    		 AND   su.site_use_id = NVL(p_ship_to_site_use_id, p_bill_to_site_use_id));

  -- geography changes
  -- Bugfix 1388703
  CURSOR c_exc_item IS
    SELECT exi.tax_code,
           exi.base_rate,
           exi.exc_itm_id
    FROM   jl_zz_ar_tx_exc_itm exi
    WHERE exi.inventory_item_id = p_inventory_item_id
    AND   exi.organization_id = p_ship_from_warehouse_id
    AND   exi.tax_category_id = p_tax_category_id
    AND   p_trx_date <= exi.end_date_active
    AND   p_trx_date >= NVL(exi.start_date_active, p_trx_date)
    AND   exists (select 1
    		  from   hz_geographies lv
          		 ,hz_cust_acct_sites ad
          		 ,hz_cust_site_uses su
                         ,hz_party_sites p
                         ,hz_locations loc
          		 ,ar_system_parameters sp
          		 ,hr_locations_all hrl
    		  WHERE  hrl.location_id = p_warehouse_location_id
    		  AND    exi.ship_from_code =  hrl.REGION_2
    		  AND    exi.ship_to_segment_id = lv.geography_id
    		  AND    lv.geography_type = sp.global_attribute9
                  AND    ad.party_site_id =p.party_site_id
		  AND    p.location_id=loc.location_id
                  AND    UPPER(lv.geography_name) = decode(sp.global_attribute9,
                                                'STATE', loc.state,loc.province)
                  AND    su.cust_acct_site_id = ad.cust_acct_site_id
    		  AND    su.site_use_id = NVL(p_ship_to_site_use_id,p_bill_to_site_use_id));
  -- Bugfix 1388703
  CURSOR c_exc_tax_group IS
    SELECT gt.tax_code,
           gt.base_rate,
           gt.tax_group_record_id
    FROM   jl_zz_ar_tx_groups gt
    WHERE  gt.group_tax_id = p_group_tax_id
    AND    gt.tax_category_id = p_tax_category_id
    AND    gt.contributor_type = p_contributor_type
    AND    gt.transaction_nature = p_transaction_nature
    AND    gt.establishment_type = p_establishment_type
    AND    p_trx_date <= gt.end_date_active
    AND    p_trx_date >= NVL(gt.start_date_active, p_trx_date);

  -- Bugfix 1388703
  CURSOR c_exc_trx_nature IS
    SELECT tnr.tax_code,
           tnr.base_rate,
           tnr.txn_nature_id
    FROM   jl_zz_ar_tx_nat_rat tnr,
    	   jl_zz_ar_tx_att_val tcav,
           jl_zz_ar_tx_categ tc,
           jl_zz_ar_tx_cat_att tca,
           jl_zz_ar_tx_att_cls tcac
    WHERE  tcac.tax_attr_class_code = p_transaction_nature_class
    AND    tcac.tax_category_id = p_tax_category_id
    AND    tcac.tax_attr_class_type = 'TRANSACTION_CLASS'
    AND    tcac.enabled_flag = 'Y'
    AND    tca.tax_attribute_type = 'TRANSACTION_ATTRIBUTE'
    AND    tca.tax_attribute_name = tcac.tax_attribute_name
    AND    tc.tax_category_id = tcac.tax_category_id
    AND    p_trx_date <= tc.end_date_active
    AND    p_trx_date >= NVL(tc.start_date_active,p_trx_date)
    AND    tcav.tax_category_id = tc.tax_category_id
    AND    tcav.tax_attribute_type = 'TRANSACTION_ATTRIBUTE'
    AND    tcav.tax_attribute_name = tcac.tax_attribute_name
    AND    tcav.tax_attribute_value = tcac.tax_attribute_value
    AND    tnr.tax_categ_attr_val_id = tcav.tax_categ_attr_val_id
    AND    p_trx_date <= tnr.end_date_active
    AND    p_trx_date >= NVL(tnr.start_date_active,p_trx_date)
    ORDER BY tca.priority_number;

  -- Bugfix 1388703
  CURSOR c_cust_exc IS
    SELECT tec.tax_code,
           tec.base_rate,
           tec.exc_cus_id
    FROM   jl_zz_ar_tx_exc_cus tec,
           hz_cust_site_uses su
    WHERE  tec.tax_category_id = p_tax_category_id
    AND    p_trx_date <= tec.end_date_active
    AND    p_trx_date >= NVL(tec.start_date_active,p_trx_date)
    AND    su.site_use_id = NVL(p_ship_to_site_use_id,p_bill_to_site_use_id)
    AND    su.cust_acct_site_id = tec.address_id;


BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level) then
    FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','Get_rule_info(+)');
    FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','p_rule = '||p_rule);
  END IF;

  o_base_rate    := to_number(NULL);
  o_tax_code     := NULL;
  o_rule_data_id := to_number(NULL);

  IF p_rule = 'GET_TAX_CATEGORY_TX_CODE' THEN
    OPEN  c_category;
    FETCH c_category INTO o_tax_code, o_base_rate, o_rule_data_id;
    CLOSE c_category;

  ELSIF p_rule = 'GET_ITEM_TX_CODE' THEN
    OPEN  c_item;
    FETCH c_item INTO o_tax_code, o_base_rate, o_rule_data_id;
    CLOSE c_item;

  ELSIF p_rule = 'GET_CUSTOMER_TX_CODE' THEN
    OPEN  c_customer;
    FETCH c_customer INTO o_tax_code, o_base_rate, o_rule_data_id;
    CLOSE c_customer;

  ELSIF p_rule = 'GET_BILL_TO_TX_CODE' THEN
    OPEN  c_bill_to;
    FETCH c_bill_to INTO o_tax_code, o_base_rate, o_rule_data_id;
    CLOSE c_bill_to;

  ELSIF p_rule = 'GET_SHIP_TO_TX_CODE' THEN
    OPEN  c_ship_to;
    FETCH c_ship_to INTO o_tax_code, o_base_rate, o_rule_data_id;
    CLOSE c_ship_to;

  ELSIF p_rule = 'GET_ORGANIZATION_TX_CODE' THEN
    OPEN  c_organization;
    FETCH c_organization INTO o_tax_code, o_base_rate, o_rule_data_id;
    CLOSE c_organization;

  ELSIF p_rule = 'GET_SYS_OPTIONS_TX_CODE' THEN
    OPEN  c_sysparam;
    FETCH c_sysparam INTO o_tax_code, o_base_rate, o_rule_data_id;
    CLOSE c_sysparam;

  ELSIF p_rule = 'GET_MEMO_LINE_TX_CODE' THEN
    IF (p_application = 'AR') THEN
      OPEN  c_memo_line;
      FETCH c_memo_line INTO o_tax_code, o_base_rate, o_rule_data_id;
      CLOSE c_memo_line;
    END IF;

  ELSIF p_rule = 'GET_TX_SCH_TX_CODE' THEN
    OPEN  c_tax_schedule;
    FETCH c_tax_schedule INTO o_tax_code, o_base_rate, o_rule_data_id;
    CLOSE c_tax_schedule;

  ELSIF p_rule = 'GET_FISC_CLAS_TX_CODE' THEN
    OPEN  c_fiscal_classif;
    FETCH c_fiscal_classif INTO o_tax_code, o_base_rate, o_rule_data_id;
    CLOSE c_fiscal_classif;

  ELSIF p_rule = 'GET_LOCATION_TX_CODE' THEN
    OPEN  c_location;
    FETCH c_location INTO o_tax_code, o_base_rate, o_rule_data_id;
    CLOSE c_location;

  ELSIF p_rule = 'GET_EXC_FISC_CLAS_TX_CODE' THEN
    OPEN  c_exc_fiscal_classif;
    FETCH c_exc_fiscal_classif INTO o_tax_code, o_base_rate, o_rule_data_id;
    CLOSE c_exc_fiscal_classif;

  ELSIF p_rule = 'GET_EXC_ITEM_TX_CODE' THEN
    OPEN  c_exc_item;
    FETCH c_exc_item INTO o_tax_code, o_base_rate, o_rule_data_id;
    CLOSE c_exc_item;

  ELSIF p_rule = 'GET_LATIN_TX_GRP_TX_CODE' THEN
    OPEN  c_exc_tax_group;
    FETCH c_exc_tax_group INTO o_tax_code, o_base_rate, o_rule_data_id;
    CLOSE c_exc_tax_group;

  ELSIF p_rule = 'GET_TRX_NATURE_TX_CODE' THEN
    OPEN  c_exc_trx_nature;
    FETCH c_exc_trx_nature INTO o_tax_code, o_base_rate, o_rule_data_id;
    CLOSE c_exc_trx_nature ;

  ELSIF p_rule = 'GET_CUST_EXC_TX_CODE' THEN
    OPEN  c_cust_exc;
    FETCH c_cust_exc INTO o_tax_code, o_base_rate, o_rule_data_id;
    CLOSE c_cust_exc;

  END IF;

  IF (g_level_statement >= g_current_runtime_level) then
   FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','o_tax_code = '||o_tax_code);
   FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','o_base_rate = '||o_base_rate);
   FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','o_rule_data_id = '||o_rule_data_id);
  END IF;

EXCEPTION
  WHEN TOO_MANY_ROWS THEN
       fnd_message.set_name('AR', 'GENERIC_MESSAGE');
       fnd_message.set_token('GENERIC_TEXT',
             'EXCEPTION(TOO_MANY_ROWS): jl_zz_tax.get_rule_info');
        IF (g_level_unexpected >= g_current_runtime_level) THEN
          FND_LOG.STRING(g_level_unexpected,'ZX.PLSQL.JL_ZZ_TAX','EXCEPTION(TOO_MANY_ROWS): jl_zz_tax.get_rule_info');
        END IF;
END get_rule_info;

--========================================================================
-- PUBLIC FUNCTION
--    get_category_tax_code
--
-- DESCRIPTION
--    This routine searches for a tax code according to the tax rate rules
--    for the level = 'RATE'.
--    The tax code is searched following the priorities defined in the
--    rules form for the specific tax category + contributor type +
--    transaction type.  If there is no specific tax category + contributor
--    type + transaction type combination, the routine considers contributor
--    type = 'DEFAULT' and transaction type = the one defined in system options
--    Each rule specifies a search for the tax code in a determined table.
--    For the new tables each row has a tax code associated to a tax
--    category. For the core product tables, the tax code can be TAX_TYPE =
--    'TAX_GROUP' or 'VAT'. If the tax type is 'TAX_GROUP' the function
--    returns the tax code associated to the tax category passed to the
--    function. If the tax category is not defined in this tax group, the
--    function continues to search for the tax code in the other rules. If
--    the tax type is 'VAT' the tax code is considered to be associated to
--    the tax category of the tax code.
--
-- PARAMETERS
--    The argument p_warehouse_id is for future purposes
--
-- RETURNS
--    tax_code
--
-- CALLED FROM
--    latin tax views
--
-- HISTORY
--========================================================================

FUNCTION get_category_tax_code (
  p_tax_category_id             IN NUMBER,
  p_cust_trx_type_id            IN NUMBER,
  p_ship_to_site_use_id         IN NUMBER,
  p_bill_to_site_use_id         IN NUMBER,
  p_inventory_item_id           IN NUMBER,
  p_group_tax_id                IN NUMBER,
  p_memo_line_id                IN NUMBER,
  p_ship_to_customer_id         IN NUMBER,
  p_bill_to_customer_id         IN NUMBER,
  p_trx_date                    IN DATE,
  p_application                 IN VARCHAR2,
  p_warehouse_id                IN NUMBER,
  p_level                       IN VARCHAR2,
  p_fiscal_classification_code  IN VARCHAR2,
  p_inventory_organization_id   IN NUMBER,
  p_location_structure_id       IN NUMBER,
  p_location_segment_num        IN NUMBER,
  p_set_of_books_id             IN NUMBER,
  p_transaction_nature          IN VARCHAR2,
  p_base_amount                 IN NUMBER,
  p_establishment_type          IN VARCHAR2,
  p_contributor_type            IN VARCHAR2,
  p_warehouse_location_id       IN NUMBER,
  p_transaction_nature_class    IN VARCHAR2
  ) return VARCHAR2 IS

  v_tax_code                    VARCHAR2(50) := NULL;

  -- Bugfix 1388703
  CURSOR c_rule IS
    SELECT tr.rule,
           tr.rule_id rule_id
    FROM   jl_zz_ar_tx_rules tr
    WHERE  tr.tax_rule_level   = p_level
    AND    tr.tax_category_id  = p_tax_category_id
    AND    nvl(tr.contributor_type,'~') = p_contributor_type
    AND    tr.cust_trx_type_id = p_cust_trx_type_id
    ORDER BY tr.priority,
             tr.rule;

  c_rule_rec c_rule%ROWTYPE;

  -- Bugfix 1388703
  CURSOR c_rule_default IS
    SELECT tr.rule rule,
           tr.rule_id rule_id
    FROM   jl_zz_ar_tx_rules tr,
           ar_system_parameters sp
    WHERE  tr.tax_rule_level   = p_level
    AND    tr.tax_category_id  = p_tax_category_id
    AND    tr.contributor_type = 'DEFAULT'
    AND    tr.cust_trx_type_id =
	       decode(ltrim(sp.global_attribute15, '0123456789'),
                    null, to_number(sp.global_attribute15), null)
    ORDER BY tr.priority,
             tr.rule;

  c_rule_default_rec c_rule_default%ROWTYPE;

  l_base_rate    NUMBER;
  l_rule_data_id NUMBER;


BEGIN
     g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','jl_zz_tx.get_category_tax_code()+');
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_code: ' || '-P- Tax Category: '||to_char(p_tax_category_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_code: ' || '-P- Transaction Type: '||to_char(p_cust_trx_type_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_code: ' || '-P- Ship to Site Use: '||to_char(p_ship_to_site_use_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_code: ' || '-P- Bill to Site Use: '||to_char(p_bill_to_site_use_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_code: ' || '-P- Inventory Item id: '||to_char(p_inventory_item_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_code: ' || '-P- Tax Group Id: '||to_char(p_group_tax_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_code: ' || '-P- Memo Line Id: '||to_char(p_memo_line_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_code: ' || '-P- Ship To Customer Id: '||to_char(p_ship_to_customer_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_code: ' || '-P- Bill To Customer Id: '||to_char(p_bill_to_customer_id));
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-P- Transaction Date: '||to_char(p_trx_date,'DD-MM-YYYY'));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_code: ' || '-P- Application: '||p_application);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_code: ' || '-P- Warehouse Id: '||to_char(p_warehouse_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_code: ' || '-P- Rule Level: '||p_level);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_code: ' || '-P- Fiscal Classification Code: '||p_fiscal_classification_code);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_code: ' || '-P- Inventory Organization Id: '||to_char(p_inventory_organization_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_code: ' || '-P- Location Structure Id: '||to_char(p_location_structure_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_code: ' || '-P- Location Segment Number: '||to_char(p_location_segment_num));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_code: ' || '-P- Set Of books Id: '||to_char(p_set_of_books_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_code: ' || '-P- Transaction Nature: '||p_transaction_nature);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_code: ' || '-P- Base Amount: '||to_char(p_base_amount));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_code: ' || '-P- Establishment Type: '||p_establishment_type);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_code: ' || '-P- Contributor Type: '||p_contributor_type);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_code: ' || '-P- Warehouse Location Id: '||to_char(p_warehouse_location_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_code: ' || '-P- Transaction Nature Class: '||p_transaction_nature_class);
  END IF;

  -- search tax rule to be applied
  FOR c_rule_rec in c_rule LOOP

      l_base_rate    := to_number(NULL);
      v_tax_code     := NULL;
      l_rule_data_id := to_number(NULL);

      IF (g_level_statement >= g_current_runtime_level) THEN
      	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_code: ' || '-- Processing Rule: '||c_rule_rec.rule);
      END IF;

      get_rule_info(
           c_rule_rec.rule,
           p_fiscal_classification_code,
           p_tax_category_id,
           p_trx_date,
           p_ship_to_site_use_id,
           p_bill_to_site_use_id,
           p_inventory_item_id,
           p_warehouse_id,
           p_group_tax_id,
           p_contributor_type,
           p_transaction_nature,
           p_establishment_type,
           p_transaction_nature_class,
           p_inventory_organization_id,
           p_ship_to_customer_id,
           p_bill_to_customer_id,
           p_warehouse_location_id,
           p_memo_line_id,
           p_base_amount,
           p_application,
           v_tax_code,
           l_base_rate,
           l_rule_data_id);

    IF (g_level_statement >= g_current_runtime_level) THEN
    	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_code: ' || '-- Tax Code: '||v_tax_code);
    END IF;

    IF v_tax_code IS NOT NULL
    THEN
      EXIT;
    END IF;
  END LOOP;

  IF v_tax_code IS NULL
  THEN
    FOR c_rule_default_rec in c_rule_default LOOP

      IF (g_level_statement >= g_current_runtime_level) THEN
      	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_code: ' || '-- Procesing Default Tax Rule: '||c_rule_default_rec.rule);
      END IF;

      l_base_rate    := to_number(NULL);
      v_tax_code     := NULL;
      l_rule_data_id := to_number(NULL);

      get_rule_info(
           c_rule_default_rec.rule,
           p_fiscal_classification_code,
           p_tax_category_id,
           p_trx_date,
           p_ship_to_site_use_id,
           p_bill_to_site_use_id,
           p_inventory_item_id,
           p_warehouse_id,
           p_group_tax_id,
           p_contributor_type,
           p_transaction_nature,
           p_establishment_type,
           p_transaction_nature_class,
           p_inventory_organization_id,
           p_ship_to_customer_id,
           p_bill_to_customer_id,
           p_warehouse_location_id,
           p_memo_line_id,
           p_base_amount,
           p_application,
           v_tax_code,
           l_base_rate,
           l_rule_data_id);

      IF (g_level_statement >= g_current_runtime_level) THEN
      	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_code: ' || '-- Tax Code: '||v_tax_code);
      END IF;

      IF v_tax_code IS NOT NULL
      THEN
        EXIT;
      END IF;
    END LOOP;
  END IF;

  IF v_tax_code IS NULL
  THEN
    -- as the function cannot raise an this message is passed to the
    -- user as a 'not valid tax code' within tax engine
    v_tax_code := 'NO_VALID_TAX_CODE';
  END IF;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','jl_zz_tax.get_category_tax_code()-');
  END IF;

  RETURN (v_tax_code);

END get_category_tax_code;

--========================================================================
-- PUBLIC FUNCTION
--    get_category_tax_rule
--
-- DESCRIPTION
--    Function returns the rule_id to be used to get the Legal Message
--    The rule_id is related to the rule that originated the tax code for
--    the transaction line
--
-- RETURNS
--    rule_id
--
-- CALLED FROM
--    jl_zz_tax.calculate
--
-- HISTORY
--========================================================================

PROCEDURE get_category_tax_rule (
  p_tax_category_id             IN NUMBER,
  p_cust_trx_type_id            IN NUMBER,
  p_ship_to_site_use_id         IN NUMBER,
  p_bill_to_site_use_id         IN NUMBER,
  p_inventory_item_id           IN NUMBER,
  p_group_tax_id                IN NUMBER,
  p_memo_line_id                IN NUMBER,
  p_ship_to_customer_id         IN NUMBER,
  p_bill_to_customer_id         IN NUMBER,
  p_trx_date                    IN DATE,
  p_application                 IN VARCHAR2,
  p_warehouse_id                IN NUMBER,
  p_level                       IN VARCHAR2,
  p_fiscal_classification_code  IN VARCHAR2,
  p_inventory_organization_id   IN NUMBER,
  p_location_structure_id       IN NUMBER,
  p_location_segment_num        IN NUMBER,
  p_set_of_books_id             IN NUMBER,
  p_transaction_nature          IN VARCHAR2,
  p_base_amount                 IN NUMBER,
  p_establishment_type          IN VARCHAR2,
  p_contributor_type            IN VARCHAR2,
  p_warehouse_location_id       IN NUMBER,
  p_transaction_nature_class    IN VARCHAR2,
  o_tax_code                    IN OUT NOCOPY VARCHAR2,
  o_base_rate                   IN OUT NOCOPY NUMBER,
  o_rule_data_id                IN OUT NOCOPY NUMBER,
  o_rule_id                     IN OUT NOCOPY NUMBER
  ) IS

  v_tax_code            VARCHAR2(50) := NULL;

  -- Bugfix 1388703
  CURSOR c_rule IS
    SELECT tr.rule,
           tr.rule_id rule_id
    FROM   jl_zz_ar_tx_rules tr
    WHERE  tr.tax_rule_level   = p_level
    AND    tr.tax_category_id  = p_tax_category_id
    AND    nvl(tr.contributor_type,'~') = p_contributor_type
    AND    tr.cust_trx_type_id = p_cust_trx_type_id
    ORDER BY tr.priority,
             tr.rule;

  c_rule_rec c_rule%ROWTYPE;

  -- Bugfix 1388703
  CURSOR c_rule_default IS
    SELECT tr.rule rule,
           tr.rule_id rule_id
    FROM   jl_zz_ar_tx_rules tr,
           ar_system_parameters sp
    WHERE  tr.tax_rule_level   = p_level
    AND    tr.tax_category_id  = p_tax_category_id
    AND    tr.contributor_type = 'DEFAULT'
    AND    tr.cust_trx_type_id =
	      decode(ltrim(sp.global_attribute15, '0123456789'), null,
	             to_number(sp.global_attribute15), null)
    ORDER BY tr.priority,
             tr.rule;

  c_rule_default_rec c_rule_default%ROWTYPE;

  l_base_rate    NUMBER;
  l_rule_data_id NUMBER;
  l_rule_id      NUMBER;


BEGIN
     g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_rule()+');
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_rule: ' || '-P- Tax category passed: '||to_char(p_tax_category_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_rule: ' || '-P- Transaction Type: '||to_char(p_cust_trx_type_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_rule: ' || '-P- Ship to Site: '||to_char(p_ship_to_site_use_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_rule: ' || '-P- Bill to site: '||to_char(p_bill_to_site_use_id) );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_rule: ' || '-P- Inventory Item Id: '||to_char(p_inventory_item_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_rule: ' || '-P- Tax group passed: '||to_char(p_group_tax_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_rule: ' || '-P- Memo Line Id: '||to_char(p_memo_line_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_rule: ' || '-P- Ship To Cust Id: '||to_char(p_ship_to_customer_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_rule: ' || '-P- Bill To Cust Id: '||to_char(p_bill_to_customer_id));
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-P- Trx date: '    ||to_char(p_trx_date,'DD-MM-YYYY'));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_rule: ' || '-P- Application: '||p_application);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_rule: ' || '-P- Warehouse Id: '|| to_char(p_warehouse_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_rule: ' || '-P- Rule Level: '||p_level);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_rule: ' || '-P- Fiscal Classification Code: '||
                                                  p_fiscal_classification_code);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_rule: ' || '-P- Inventory Organization Id: '||
                                          to_char(p_inventory_organization_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_rule: ' || '-P- Location Structure Id: '||
                                              to_char(p_location_structure_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_rule: ' || '-P- Location Segment Number: '||p_location_segment_num);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_rule: ' || '-P- Set Of Books Id: '||to_char(p_set_of_books_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_rule: ' || '-P- Trx Nature: '|| p_transaction_nature);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_rule: ' || '-P- Tax base amount passed: '||to_char(p_base_amount));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_rule: ' || '-P- Establishment Type: '|| p_establishment_type);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_rule: ' || '-P- Contributor Type: '|| p_contributor_type);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_rule: ' || '-P- Warehouse Location Id: '||
                                              to_char(p_warehouse_location_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_rule: ' || '-P- Trx Nature Class: '||p_transaction_nature_class);
  END IF;

  -- search tax rule to be applied
  l_rule_id      := to_number(NULL);

  FOR c_rule_rec in c_rule LOOP

    l_base_rate    := to_number(NULL);
    v_tax_code     := NULL;
    l_rule_data_id := to_number(NULL);

    get_rule_info(
           c_rule_rec.rule,
           p_fiscal_classification_code,
           p_tax_category_id,
           p_trx_date,
           p_ship_to_site_use_id,
           p_bill_to_site_use_id,
           p_inventory_item_id,
           p_warehouse_id,
           p_group_tax_id,
           p_contributor_type,
           p_transaction_nature,
           p_establishment_type,
           p_transaction_nature_class,
           p_inventory_organization_id,
           p_ship_to_customer_id,
           p_bill_to_customer_id,
           p_warehouse_location_id,
           p_memo_line_id,
           p_base_amount,
           p_application,
           v_tax_code,
           l_base_rate,
           l_rule_data_id);

    IF v_tax_code IS NOT NULL
    THEN
      IF (g_level_statement >= g_current_runtime_level) THEN
      	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- Return from get_category_tax_rule: '||
                                 to_char(c_rule_rec.rule_id));
      END IF;
      l_rule_id := c_rule_rec.rule_id;
      EXIT;
    END IF;
  END LOOP;

  IF v_tax_code IS NULL
  THEN
    FOR c_rule_default_rec in c_rule_default LOOP

      l_base_rate    := to_number(NULL);
      v_tax_code     := NULL;
      l_rule_data_id := to_number(NULL);

      get_rule_info(
           c_rule_default_rec.rule,
           p_fiscal_classification_code,
           p_tax_category_id,
           p_trx_date,
           p_ship_to_site_use_id,
           p_bill_to_site_use_id,
           p_inventory_item_id,
           p_warehouse_id,
           p_group_tax_id,
           p_contributor_type,
           p_transaction_nature,
           p_establishment_type,
           p_transaction_nature_class,
           p_inventory_organization_id,
           p_ship_to_customer_id,
           p_bill_to_customer_id,
           p_warehouse_location_id,
           p_memo_line_id,
           p_base_amount,
           p_application,
           v_tax_code,
           l_base_rate,
           l_rule_data_id);

      IF v_tax_code IS NOT NULL
      THEN
        IF (g_level_statement >= g_current_runtime_level) THEN
        	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- Return from get_category_tax_rule: '||
                                 to_char(c_rule_default_rec.rule_id));
        END IF;
        l_rule_id := c_rule_default_rec.rule_id;
        EXIT;
      END IF;
    END LOOP;
  END IF;

  o_rule_id := l_rule_id;
  o_tax_code := v_tax_code;
  o_base_rate := l_base_rate;
  o_rule_data_id := l_rule_data_id;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_rule: ' || '-O- Rule Id: '|| to_char(o_rule_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_rule: ' || '-O- Tax Code: '|| o_tax_code);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_rule: ' || '-O- Base Rate: '|| to_char(o_base_rate));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_rule: ' || '-O- Rule Data Id: '|| to_char(o_rule_data_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_category_tax_rule()-');
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    fnd_message.set_name('AR', 'GENERIC_MESSAGE');
    fnd_message.set_token('GENERIC_TEXT',
        'No valid tax code found: jl_zz_tax.get_category_tax_rule');
    IF (g_level_unexpected >= g_current_runtime_level) THEN
      FND_LOG.STRING(g_level_unexpected,'ZX.PLSQL.JL_ZZ_TAX','EXCEPTION(NO_DATA_FOUND): jl_zz_tax.get_category_tax_rule');
    END IF;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
                     ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.customer_trx_line_id;

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
                     'LINE';

    ZX_API_PUB.add_msg(
                      ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);


END get_category_tax_rule;


--========================================================================
-- This function is a wrapper for the procedure get_rule_info. The
-- function is called from the Tax Engine views. The function gets the
-- base rate tax code to modify the extended amount. For Brazilian
-- Taxes you can define a kind of exemption (to increase or decrease
-- the tax base amount) to be applied to the base amount before you
-- apply the tax rate. To increase the base rate you should define a
-- positive value to the tax code and to decrease the base rate you
-- should define a negative value to the tax code. The base rate tax
-- code is defined by the tax rules priorities. Level (Base). If there
-- is not a base rate the function returns NULL and the calculation
-- procedure uses the normal invoice line or sales order line amounts.
--    19-SEP-98  Harsh Takle    Added following parameters
--                                    p_establishment_type
--                                    p_contributor_type
--                                    p_warehouse_location_id
--                                    p_transaction_nature_class
--========================================================================

FUNCTION get_tax_base_rate (
  p_tax_category_id             IN NUMBER,
  p_cust_trx_type_id            IN NUMBER,
  p_ship_to_site_use_id         IN NUMBER,
  p_bill_to_site_use_id         IN NUMBER,
  p_inventory_item_id           IN NUMBER,
  p_group_tax_id                IN NUMBER,
  p_memo_line_id                IN NUMBER,
  p_ship_to_customer_id         IN NUMBER,
  p_bill_to_customer_id         IN NUMBER,
  p_trx_date                    IN DATE,
  p_application                 IN VARCHAR2,
  p_warehouse_id                IN NUMBER,
  p_level                       IN VARCHAR2,
  p_fiscal_classification_code  IN VARCHAR2,
  p_inventory_organization_id   IN NUMBER,
  p_location_structure_id       IN NUMBER,
  p_location_segment_num        IN NUMBER,
  p_transaction_nature          IN VARCHAR2,
  p_establishment_type          IN VARCHAR2,
  p_contributor_type            IN VARCHAR2,
  p_warehouse_location_id       IN NUMBER,
  p_transaction_nature_class    IN VARCHAR2
  ) return NUMBER IS

  v_base_rate       NUMBER := NULL;

  -- Bugfix 1388703
  CURSOR c_rule IS
    SELECT tr.rule,
           tr.rule_id rule_id
    FROM   jl_zz_ar_tx_rules tr
    WHERE  tr.tax_rule_level = p_level
    AND    tr.tax_category_id = p_tax_category_id
    AND    NVL(tr.contributor_type,'~') = p_contributor_type
    AND    tr.cust_trx_type_id = p_cust_trx_type_id
    ORDER BY tr.priority,
             tr.rule;

  c_rule_rec c_rule%ROWTYPE;

  -- Bugfix 1388703
  CURSOR c_rule_default IS
    SELECT tr.rule rule,
           tr.rule_id rule_id
    FROM   jl_zz_ar_tx_rules tr,
           ar_system_parameters sp
    WHERE  tr.tax_rule_level = p_level
    AND    tr.tax_category_id = p_tax_category_id
    AND    tr.contributor_type = 'DEFAULT'
    AND    tr.cust_trx_type_id =
	       decode(ltrim(sp.global_attribute15, '0123456789'),
		     null, to_number(sp.global_attribute15), null)
    ORDER BY tr.priority,
             tr.rule;

  c_rule_default_rec c_rule_default%ROWTYPE;

  l_tax_code     ar_vat_tax.tax_code%type;
  l_rule_data_id NUMBER;


BEGIN
     g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -- search tax rule to be applied
  FOR c_rule_rec in c_rule LOOP

    v_base_rate    := to_number(NULL);
    l_tax_code     := NULL;
    l_rule_data_id := to_number(NULL);

    get_rule_info(
           c_rule_rec.rule,
           p_fiscal_classification_code,
           p_tax_category_id,
           p_trx_date,
           p_ship_to_site_use_id,
           p_bill_to_site_use_id,
           p_inventory_item_id,
           p_warehouse_id,
           p_group_tax_id,
           p_contributor_type,
           p_transaction_nature,
           p_establishment_type,
           p_transaction_nature_class,
           p_inventory_organization_id,
           p_ship_to_customer_id,
           p_bill_to_customer_id,
           p_warehouse_location_id,
           p_memo_line_id,
           0,
           p_application,
           l_tax_code,
           v_base_rate,
           l_rule_data_id);

    IF v_base_rate IS NOT NULL
    THEN
      EXIT;
    END IF;
  END LOOP;

  IF v_base_rate IS NULL
  THEN
    FOR c_rule_default_rec in c_rule_default LOOP

        get_rule_info(
           c_rule_default_rec.rule,
           p_fiscal_classification_code,
           p_tax_category_id,
           p_trx_date,
           p_ship_to_site_use_id,
           p_bill_to_site_use_id,
           p_inventory_item_id,
           p_warehouse_id,
           p_group_tax_id,
           p_contributor_type,
           p_transaction_nature,
           p_establishment_type,
           p_transaction_nature_class,
           p_inventory_organization_id,
           p_ship_to_customer_id,
           p_bill_to_customer_id,
           p_warehouse_location_id,
           p_memo_line_id,
           0,
           p_application,
           l_tax_code,
           v_base_rate,
           l_rule_data_id);

     IF v_base_rate IS NOT NULL
     THEN
       EXIT;
     END IF;
   END LOOP;
  END IF;

  RETURN(v_base_rate);

END get_tax_base_rate;

-- Following procedure is created on 19-SEP-98 by Harsh Takle
-- Procedure will return Applicable prior base and charged tax amount
-- for current tax line
-- If grouping attribute is 'DOCUMENT' then it will sum up all previous
-- tax lines base amount and tax amount from PL/SQL table for current tax
-- category, irrespective of their grouping attribute value, otherwise it will
-- return base amount and charged tax amount for current tax category and
-- current grouping attribute value
-- This procedure is called from get_prior_base procedure

PROCEDURE get_prior_base_curr_doc (p_tax_category_id       IN     NUMBER,
                                   p_grp_attr_name         IN     VARCHAR2,
                                   p_grp_attr_value        IN     VARCHAR2,
                                   p_appl_prior_base       IN OUT NOCOPY NUMBER,
                                   p_charged_tax_amount    IN OUT NOCOPY NUMBER,
                                   p_calculated_tax_amount IN OUT NOCOPY NUMBER) IS

  l_counter NUMBER;


BEGIN
     g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','jl_zz_tax.get_prior_base_curr_doc()+');
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_prior_base_curr_doc: ' || '-P- Tax category: '||to_char(p_tax_category_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_prior_base_curr_doc: ' || '-P- Grouping Attribute Name: '||p_grp_attr_name);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_prior_base_curr_doc: ' || '-P- Grouping Attribute Value: ' ||p_grp_attr_value);
  END IF;

  p_appl_prior_base := 0;
  p_charged_tax_amount := 0;
  p_calculated_tax_amount := 0;
  l_counter := g_rel_tax_line_amounts.COUNT;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_prior_base_curr_doc: ' || '-- Rel tax Amounts PLSQL Table counter: '|| to_char(l_counter));
  END IF;

  IF p_grp_attr_name = 'DOCUMENT' THEN
     LOOP
       IF l_counter = 0 THEN
          exit;
       END IF;
       IF p_tax_category_id = g_rel_tax_line_amounts(l_counter).TaxCateg THEN
          p_appl_prior_base := p_appl_prior_base +
                                g_rel_tax_line_amounts(l_counter).ApplPriorBase;
          p_charged_tax_amount := p_charged_tax_amount +
                                   g_rel_tax_line_amounts(l_counter).ChargedTax;
          p_calculated_tax_amount := p_calculated_tax_amount +
                                   g_rel_tax_line_amounts(l_counter).CalcltdTax;
       END IF;

       IF (g_level_statement >= g_current_runtime_level) THEN
       	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_prior_base_curr_doc: ' || '-- Rel Tax category: '||
                           to_char(g_rel_tax_line_amounts(l_counter).TaxCateg));
       	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_prior_base_curr_doc: ' || '-- Applicable Prior Base: '||to_char(p_appl_prior_base));
       	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_prior_base_curr_doc: ' || '-- Charged tax Amount: '||to_char(p_charged_tax_amount));
       	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_prior_base_curr_doc: ' || '-- Calculated tax Amount: '||
                                              to_char(p_calculated_tax_amount));
       END IF;
       l_counter := l_counter - 1;
     END LOOP;
  ELSE
     LOOP
       IF l_counter = 0 THEN
          EXIT;
       END IF;
       IF p_tax_category_id = g_rel_tax_line_amounts(l_counter).TaxCateg AND
          p_grp_attr_name = g_rel_tax_line_amounts(l_counter).GrpAttrname AND
          p_grp_attr_value = g_rel_tax_line_amounts(l_counter).GrpAttrvalue THEN
          p_appl_prior_base := p_appl_prior_base +
                                g_rel_tax_line_amounts(l_counter).ApplPriorBase;
          p_charged_tax_amount := p_charged_tax_amount +
                                   g_rel_tax_line_amounts(l_counter).ChargedTax;
          p_calculated_tax_amount := p_calculated_tax_amount +
                                  g_rel_tax_line_amounts(l_counter).CalcltdTax;
          IF (g_level_statement >= g_current_runtime_level) THEN
          	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_prior_base_curr_doc: ' || '-- Applicable Prior Base: '||
                                                    to_char(p_appl_prior_base));
          	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_prior_base_curr_doc: ' || '-- Charged tax Amount: ' ||
                                                 to_char(p_charged_tax_amount));
          	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_prior_base_curr_doc: ' || '-- Calculated tax Amount: ' ||
                                              to_char(p_calculated_tax_amount));
          END IF;
       END IF;

       IF (g_level_statement >= g_current_runtime_level) THEN
       	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_prior_base_curr_doc: ' || '-- Rel Tax category: '||
                           to_char(g_rel_tax_line_amounts(l_counter).TaxCateg));
       	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_prior_base_curr_doc: ' || '-- Rel Grp attribute Name: '||
                                 g_rel_tax_line_amounts(l_counter).GrpAttrname);
       	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_prior_base_curr_doc: ' || '-- Rel Grp attribute Value: '||
                                g_rel_tax_line_amounts(l_counter).GrpAttrvalue);
       END IF;

       l_counter := l_counter - 1;
     END LOOP;
  END IF;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_prior_base_curr_doc: ' || '-O- Applicable Prior Base: '||to_char(p_appl_prior_base));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_prior_base_curr_doc: ' || '-O- Charged tax Amount: ' ||to_char(p_charged_tax_amount));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_prior_base_curr_doc: ' || '-O- Calculated tax Amount: ' ||
                                              to_char(p_calculated_tax_amount));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','jl_zz_tax.get_prior_base_curr_doc()-');
  END IF;

END get_prior_base_curr_doc;

-- Following procedure is created on 19-SEP-98 by Harsh Takle
-- Procedure will return applicable prior base amount and charged tax amount
-- Thie procedure will call get_prior_base_curr_doc procedure to get these
-- amounts.
-- Procedure is called from calculate_tax_amount procedure.

PROCEDURE get_prior_base(p_operation_level       IN     VARCHAR2,
                         p_tax_category_id       IN     NUMBER,
                         p_grp_attr_name         IN     VARCHAR2,
                         p_grp_attr_value        IN     VARCHAR2,
                         p_appl_prior_base       IN OUT NOCOPY NUMBER,
                         p_charged_tax_amount    IN OUT NOCOPY NUMBER,
                         p_calculated_tax_amount IN OUT NOCOPY NUMBER) IS



BEGIN
     g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','jl_zz_tax.get_prior_base()+');
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_prior_base: ' || '-P- Operation Level: '|| p_operation_level);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_prior_base: ' || '-P- Tax category: '||to_char(p_tax_category_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_prior_base: ' || '-P- Grouping Attribute Name: '||p_grp_attr_name);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_prior_base: ' || '-P- Grouping Attribute Value: ' ||p_grp_attr_value);
  END IF;

  IF p_operation_level = 'OPERATION' THEN
     get_prior_base_curr_doc(p_tax_category_id,p_grp_attr_name,
                             p_grp_attr_value,p_appl_prior_base,
                             p_charged_tax_amount,p_calculated_tax_amount);
  ELSIF p_operation_level = 'DOCUMENT' THEN
     IF g_first_tax_line = TRUE THEN
        p_appl_prior_base := 0;
        p_charged_tax_amount := 0;
        p_calculated_tax_amount := 0;
     ELSE
        get_prior_base_curr_doc(p_tax_category_id,p_grp_attr_name,
                                p_grp_attr_value,p_appl_prior_base,
                                p_charged_tax_amount,p_calculated_tax_amount);
     END IF;
  END IF;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_prior_base: ' || '-O- Applicable Prior Base: '||to_char(p_appl_prior_base));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_prior_base: ' || '-O- Charged tax Amount: ' ||to_char(p_charged_tax_amount));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_prior_base: ' || '-O- Calculated tax Amount: ' ||
                                              to_char(p_calculated_tax_amount));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','jl_zz_tax.get_prior_base()-');
  END IF;

END get_prior_base;

-- Following function is created on 19-SEP-98 by Harsh Takle
-- Function will check whether related tax line category of type DOCUMENT
-- is included in cuurent tax line tax group. If it is included then function
-- will return Included otherwise return an Error
-- This function is called from validate_current_tax_line function.

-- Bugfix 1388703
FUNCTION validate_rel_tax_line_category(p_tax_group                IN NUMBER,
                                        p_tax_category_id          IN NUMBER,
                                        p_trx_date                 IN DATE,
                                        p_site_use_id              IN NUMBER,
                                        p_organization_class       IN VARCHAR2,
                                        p_contributor_class        IN VARCHAR2,
                                        p_transaction_nature_class IN VARCHAR2)
RETURN VARCHAR2 IS

  l_return_code             VARCHAR2(20);
  l_curr_nature_class_value   VARCHAR2(30);
  l_establishment_type        VARCHAR2(30);
  l_contributor_type          VARCHAR2(30);
  l_dummy                     NUMBER;



BEGIN
     g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','jl_zz_tax.validate_rel_tax_line_category()+');
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','validate_rel_tax_line_category: ' || '-P- Organization Class: '||p_organization_class);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','validate_rel_tax_line_category: ' || '-P- Contributor Class: '||p_contributor_class);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','validate_rel_tax_line_category: ' || '-P- Trx Nature Class: '||p_transaction_nature_class);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','validate_rel_tax_line_category: ' || '-P- Tax Group: '   ||to_char(p_tax_group));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','validate_rel_tax_line_category: ' || '-P- Tax category: '||to_char(p_tax_category_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','validate_rel_tax_line_category: ' || '-P- Site use id : '||to_char(p_site_use_id));
  END IF;

  l_curr_nature_class_value := NULL;
  BEGIN
    -- Bugfix 1388703
    SELECT ac.tax_attribute_value
    INTO   l_curr_nature_class_value
    FROM   jl_zz_ar_tx_att_cls ac
    WHERE  ac.tax_attr_class_type = 'TRANSACTION_CLASS'
    AND    ac.tax_attr_class_code = p_transaction_nature_class
    AND    ac.tax_category_id = p_tax_category_id
    AND    ac.tax_attribute_type = 'TRANSACTION_ATTRIBUTE'
    AND    ac.enabled_flag = 'Y'
    AND    exists (select 1
                   from   jl_zz_ar_tx_cat_att ca
    		   WHERE  ca.tax_category_id = ac.tax_category_id
    		   AND    ca.tax_attribute_type = 'TRANSACTION_ATTRIBUTE'
    		   AND    ca.tax_attribute_name = ac.tax_attribute_name);

  EXCEPTION
    WHEN OTHERS THEN
         l_curr_nature_class_value := NULL;
  END;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','validate_rel_tax_line_category: ' || '-- Current Nature Class value: '||l_curr_nature_class_value);
  END IF;

  l_establishment_type := NULL;
  l_contributor_type := NULL;

  BEGIN
    -- Bugfix 1783986
    IF NVL(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf4,'N') = 'Y' THEN
       select ota.tax_attribute_value,
              cta.tax_attribute_value
       into   l_establishment_type,
              l_contributor_type
       FROM   jl_zz_ar_tx_cus_cls cta,
              hz_cust_site_uses rsu,
              jl_zz_ar_tx_att_cls ota,
              jl_zz_ar_tx_categ tc
       WHERE  tc.tax_category_id = p_tax_category_id
       AND    tc.threshold_check_grp_by = 'DOCUMENT'
       AND    ota.tax_attr_class_type = 'ORGANIZATION_CLASS'
       AND    ota.tax_category_id = tc.tax_category_id
       AND    ota.tax_attribute_type = 'ORGANIZATION_ATTRIBUTE'
       AND    ota.tax_attribute_name = tc.org_tax_attribute
       AND    ota.tax_attr_class_code = p_organization_class
       AND    rsu.site_use_id =
                   decode(tc.tax_category_id, null, 0, p_site_use_id)
       AND    cta.address_id = rsu.cust_acct_site_id
       AND    cta.tax_category_id = tc.tax_category_id
       AND    cta.tax_attribute_name = tc.cus_tax_attribute
       AND    cta.tax_attr_class_code = p_contributor_class
       AND    cta.enabled_flag = 'Y';
    ELSE
       select ota.tax_attribute_value,
              cta.tax_attribute_value
       into   l_establishment_type,
              l_contributor_type
       FROM   jl_zz_ar_tx_att_cls cta,
              jl_zz_ar_tx_att_cls ota,
              jl_zz_ar_tx_categ tc
       WHERE  tc.tax_category_id = p_tax_category_id
       AND    tc.threshold_check_grp_by = 'DOCUMENT'
       AND    ota.tax_attr_class_type = 'ORGANIZATION_CLASS'
       AND    ota.tax_category_id = tc.tax_category_id
       AND    ota.tax_attribute_type = 'ORGANIZATION_ATTRIBUTE'
       AND    ota.tax_attribute_name = tc.org_tax_attribute
       AND    ota.tax_attr_class_code = p_organization_class
       AND    cta.tax_attr_class_type = 'CONTRIBUTOR_CLASS'
       AND    cta.tax_category_id = tc.tax_category_id
       AND    cta.tax_attribute_type = 'CONTRIBUTOR_ATTRIBUTE'
       AND    cta.tax_attribute_name = tc.cus_tax_attribute
       AND    cta.tax_attr_class_code = p_contributor_class
       AND    cta.enabled_flag = 'Y';
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
           l_establishment_type := NULL;
           l_contributor_type := NULL;
  END;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','validate_rel_tax_line_category: ' || '-- Establishment Type: ' || l_establishment_type);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','validate_rel_tax_line_category: ' || '-- Contributor Type: ' || l_contributor_type);
  END IF;

  l_dummy := 0;
  BEGIN
    SELECT 1
    INTO   l_dummy
    FROM   jl_zz_ar_tx_groups tg
    WHERE  tg.group_tax_id = p_tax_group
    AND    tg.tax_category_id = p_tax_category_id
    AND    tg.transaction_nature = l_curr_nature_class_value
    AND    tg.establishment_type = l_establishment_type
    AND    tg.contributor_type = l_contributor_type
    AND    p_trx_date <= tg.end_date_active
    AND    p_trx_date >= NVL(tg.start_date_active, p_trx_date);

    EXCEPTION
      WHEN OTHERS THEN
           l_dummy := 0;
  END;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','validate_rel_tax_line_category: ' || '-- Include Status: ' || to_char(l_dummy));
  END IF;
  IF l_dummy = 1 THEN
     l_return_code := 'INCLUDED';
  ELSE
     l_return_code := 'NOT INCLUDED';
  END IF;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','validate_rel_tax_line_category: ' || '-O- return_code: ' || l_return_code);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','jl_zz_tax.validate_rel_tax_line_category()-');
  END IF;

  RETURN l_return_code;
END validate_rel_tax_line_category;

-- Following function is created on 19-SEP-98 by Harsh Takle
-- Function calls validate_rel_tax_line_category function to validate related
-- tax line category of type DOCUMENT
-- Function will also check whether current tax line category of DOCUMENT is
-- included in all related invoice lines
-- Function is called from calculate_tax_amount procedure.

-- Bugfix 1388703
FUNCTION validate_current_tax_line (
                        p_rel_customer_trx_id IN NUMBER,
                        p_customer_trx_id          IN NUMBER,
                                    p_customer_trx_line_number IN NUMBER,
                                    p_operation_level          IN VARCHAR2,
                                    p_tax_group                IN NUMBER,
                                    p_tax_category_id          IN NUMBER,
                                    p_grp_attr_name            IN VARCHAR2,
    				    p_trx_date                 IN DATE,
                                    p_site_use_id              IN NUMBER,
                                    p_organization_class       IN VARCHAR2,
                                    p_contributor_class        IN VARCHAR2,
                                    p_transaction_nature_class IN VARCHAR2)
RETURN VARCHAR2 IS

  l_return_code             VARCHAR2(20);
  l_counter                 BINARY_INTEGER;
  l_include_status          VARCHAR2(20);
  l_prev_inv_line_number    NUMBER(15);
  l_tax_category_match_flag VARCHAR2(1);
  l_max_table_entries       NUMBER;
  l_prev_header_id          NUMBER;
  l_rel_trx_categ_ctr       NUMBER;
  l_tax_category_id         NUMBER;



BEGIN
     g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','jl_zz_tax.validate_current_tax_line()+');
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','validate_current_tax_line: ' || '-P- Customer Trx Id: '   ||to_char(p_customer_trx_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','validate_current_tax_line: ' || '-P- Rel Customer Trx Id: '||
                                              to_char(p_rel_customer_trx_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','validate_current_tax_line: ' || '-P- Customer trx line number: '||
                                           to_char(p_customer_trx_line_number));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','validate_current_tax_line: ' || '-P- Operation Level: '||p_operation_level);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','validate_current_tax_line: ' || '-P- Tax Group: '   ||to_char(p_tax_group));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','validate_current_tax_line: ' || '-P- Tax category: '||to_char(p_tax_category_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','validate_current_tax_line: ' || '-P- Grouping Attribute Name: '||p_grp_attr_name);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','validate_current_tax_line: ' || '-P- Trx Nature Class: '||p_transaction_nature_class);
  END IF;

  l_return_code := 'SUCCESS';
  IF g_first_tax_line = TRUE THEN
     IF p_operation_level = 'DOCUMENT' THEN
        RETURN l_return_code;
     END IF;
  END IF;

  l_counter := 1;
  l_prev_inv_line_number := Null;
  l_tax_category_match_flag := Null;
  l_max_table_entries := g_rel_trx_categ.COUNT;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','validate_current_tax_line: ' || '-- Rel lines table entries: '||to_char(l_max_table_entries));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','validate_current_tax_line: ' || '-- Tax line amounts table entries: '||
                                         to_char(g_rel_tax_line_amounts.COUNT));
  END IF;
  IF l_max_table_entries = 0 AND p_grp_attr_name = 'DOCUMENT' AND
     g_rel_tax_line_amounts.COUNT > 0 AND
     (p_customer_trx_id <> NVL(g_prev_header_id,p_customer_trx_id) OR
     p_customer_trx_line_number <>
               NVL(g_prev_cust_trx_line_number,p_customer_trx_line_number)) THEN
     l_return_code := 'ERROR';
     RETURN l_return_code;
  END IF;


 IF g_rel_trx_categ.FIRST is not null THEN

  l_tax_category_id := g_rel_trx_categ.FIRST;

  LOOP
    IF p_tax_group IS NULL THEN
       IF (g_level_statement >= g_current_runtime_level) THEN
       	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','validate_current_tax_line: ' || '-- Current tax category: '||
                                to_char(p_tax_category_id));
       	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','validate_current_tax_line: ' || '-- Related tax category: '||
                                to_char(l_tax_category_id));
       END IF;
       IF NOT g_rel_trx_categ.EXISTS(p_tax_category_id) THEN
          l_return_code := 'ERROR';
          EXIT;
       END IF;
    ELSE
       -- Tax Category from PL/SQL table g_rel_trx_categ is of type DOCUMENT
       -- So check whether it is included in current tax line tax group
       -- Bugfix 1388703
       l_include_status := validate_rel_tax_line_category(p_tax_group,
			            l_tax_category_id,
  					    p_trx_date,
                                            p_site_use_id,
                                            p_organization_class,
                                            p_contributor_class,
					    p_transaction_nature_class);
       IF l_include_status = 'NOT_INCLUDED' THEN
	  l_return_code := 'ERROR';
	  EXIT;
       END IF;
    END IF;

    IF (g_level_statement >= g_current_runtime_level) THEN
    	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','validate_current_tax_line: ' || '-- Rel tax lines table Tax category: '||
                                to_char(l_tax_category_id));
    END IF;

    IF l_tax_category_id = g_rel_trx_categ.LAST THEN
       EXIT;
    END IF;
    l_tax_category_id := g_rel_trx_categ.NEXT(l_tax_category_id);
  END LOOP;
 END IF;

  IF l_return_code = 'ERROR' THEN
    IF (g_level_statement >= g_current_runtime_level) THEN
    	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','validate_current_tax_line: ' || '-O- Return Code: '||l_return_code);
    	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','jl_zz_tax.validate_current_tax_line()-');
    END IF;

    RETURN l_return_code;
  END IF;

  IF p_grp_attr_name = 'DOCUMENT' AND
     (g_first_processed_invoice_line <> p_customer_trx_line_number) THEN

     IF g_rel_trx_categ.EXISTS(p_tax_category_id) THEN
        l_return_code := 'SUCCESS';
     ELSE
        l_return_code := 'ERROR';
     END IF;

  END IF;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','validate_current_tax_line: ' || '-- Return Code: '||l_return_code);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','validate_current_tax_line: ' || '-O- Return Code: '||l_return_code);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','jl_zz_tax.validate_current_tax_line()-');
  END IF;

  RETURN l_return_code;
END validate_current_tax_line;

-- Following prcedure is created on 19-SEP-98 by Harsh Takle
-- Procedure will return minimum thresholds for tax rate, tax amount and
-- taxable basis for current tax category and/or current tax group
-- Function is called from calculate_tax_amount procedure.

PROCEDURE get_minimum_thresholds (p_tax_group_id             IN     NUMBER,
                                  p_tax_category_id          IN     NUMBER,
                                  p_trx_date                 IN     DATE,
				  p_establishment_type       IN     VARCHAR2,
				  p_contributor_type         IN     VARCHAR2,
				  p_transaction_nature       IN     VARCHAR2,
				  p_transaction_nature_class IN     VARCHAR2,
				  p_rule_code                IN     VARCHAR2,
                                  p_min_tax_rate             IN OUT NOCOPY NUMBER,
                                  p_min_tax_amount           IN OUT NOCOPY NUMBER,
                                  p_min_taxable_basis        IN OUT NOCOPY NUMBER) IS

  l_use_tx_categ_thresholds VARCHAR2(10);
  l_nat_min_taxable_base    NUMBER;
  l_nat_min_tax_amount	    NUMBER;
  l_nat_min_tax_rate	    NUMBER;

  -- Bugfix 1388703
  CURSOR trx_nature IS
    SELECT tcav.tax_categ_attr_val_id tax_categ_attr_val_id
    FROM   jl_zz_ar_tx_att_val tcav,
           jl_zz_ar_tx_cat_att tca,
           jl_zz_ar_tx_att_cls tcac
    WHERE  tcav.tax_attribute_type = 'TRANSACTION_ATTRIBUTE'
    AND    tcav.tax_category_id = p_tax_category_id
    AND    tcac.tax_attr_class_code = p_transaction_nature_class
    AND    tcac.tax_category_id = tcav.tax_category_id
    AND    tcac.tax_attr_class_type = 'TRANSACTION_CLASS'
    AND    tcac.enabled_flag = 'Y'
    AND    tca.tax_attribute_type = 'TRANSACTION_ATTRIBUTE'
    AND    tca.tax_attribute_name = tcac.tax_attribute_name
    AND    tca.tax_attribute_name = tcav.tax_attribute_name
    AND    tcac.tax_attribute_value = tcav.tax_attribute_value
    ORDER BY tca.priority_number;



BEGIN
     g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','jl_zz_tax.get_minimum_thresholds()+');
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_minimum_thresholds: ' || '-P- Tax Group: '||to_char(p_tax_group_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_minimum_thresholds: ' || '-P- Tax category: '||to_char(p_tax_category_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_minimum_thresholds: ' || '-P- Establishment Type: '||p_establishment_type);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_minimum_thresholds: ' || '-P- Contributor Type: '||p_contributor_type);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_minimum_thresholds: ' || '-P- Transaction Nature: '||p_transaction_nature);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_minimum_thresholds: ' || '-P- Transaction Nature Class: '||p_transaction_nature_class);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_minimum_thresholds: ' || '-P- Rule Code: '||p_rule_code);
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-P- Trx Date: '||to_char(p_trx_date,'DD-MM-YYYY'));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_minimum_thresholds: ' || '-P- Minimum Tax Rate: '||to_char(p_min_tax_rate));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_minimum_thresholds: ' || '-P- Minimum Tax Amount: '||to_char(p_min_tax_amount));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_minimum_thresholds: ' || '-P- Minimum Taxable basis: '||to_char(p_min_taxable_basis));
  END IF;

  p_min_tax_rate := NULL;
  p_min_tax_amount := NULL;
  p_min_taxable_basis := NULL;
  l_use_tx_categ_thresholds := NULL;

  BEGIN
    SELECT min_percentage,
           min_amount,
           min_taxable_basis,
           use_tx_categ_thresholds
    INTO   p_min_tax_rate,
           p_min_tax_amount,
           p_min_taxable_basis,
           l_use_tx_categ_thresholds
    FROM   jl_zz_ar_tx_groups
    WHERE  group_tax_id = p_tax_group_id
    AND    tax_category_id = p_tax_category_id
    AND    establishment_type = p_establishment_type
    AND    contributor_type = p_contributor_type
    AND    transaction_nature = p_transaction_nature
    AND    p_trx_date BETWEEN NVL(start_date_active,p_trx_date)
                      AND     end_date_active;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
         p_min_tax_rate := NULL;
         p_min_tax_amount := NULL;
         p_min_taxable_basis := NULL;
         l_use_tx_categ_thresholds := NULL;
  END;
  IF NVL(p_min_tax_rate,0) = 0 AND l_use_tx_categ_thresholds = 'Y' THEN
     BEGIN
       SELECT min_percentage
       INTO   p_min_tax_rate
       FROM   jl_zz_ar_tx_cat_dtl
       WHERE  tax_category_id = p_tax_category_id
       AND    p_trx_date BETWEEN NVL(start_date_active,p_trx_date)
                         AND     end_date_active;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
            BEGIN
              SELECT min_percentage
              INTO   p_min_tax_rate
              FROM   jl_zz_ar_tx_categ
              WHERE  tax_category_id = p_tax_category_id
              AND    p_trx_date BETWEEN NVL(start_date_active,p_trx_date)
                                AND     end_date_active;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                   p_min_tax_rate := 0;
            END;
     END;
  END IF;
  IF NVL(p_min_tax_amount,0) = 0 AND l_use_tx_categ_thresholds = 'Y' THEN
     BEGIN
       SELECT min_amount
       INTO   p_min_tax_amount
       FROM   jl_zz_ar_tx_cat_dtl
       WHERE  tax_category_id = p_tax_category_id
       AND    p_trx_date BETWEEN NVL(start_date_active,p_trx_date)
                         AND     end_date_active;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
            BEGIN
              SELECT min_amount
              INTO   p_min_tax_amount
              FROM   jl_zz_ar_tx_categ
              WHERE  tax_category_id = p_tax_category_id
              AND    p_trx_date BETWEEN NVL(start_date_active,p_trx_date)
                                AND     end_date_active;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                   p_min_tax_amount := 0;
            END;
     END;
  END IF;
  IF NVL(p_min_taxable_basis,0) = 0 AND l_use_tx_categ_thresholds = 'Y' THEN
     BEGIN
       SELECT min_taxable_basis
       INTO   p_min_taxable_basis
       FROM   jl_zz_ar_tx_cat_dtl
       WHERE  tax_category_id = p_tax_category_id
       AND    p_trx_date BETWEEN NVL(start_date_active,p_trx_date)
                         AND     end_date_active;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
            BEGIN
              SELECT min_taxable_basis
              INTO   p_min_taxable_basis
              FROM   jl_zz_ar_tx_categ
              WHERE  tax_category_id = p_tax_category_id
              AND    p_trx_date BETWEEN NVL(start_date_active,p_trx_date)
                                AND     end_date_active;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                   p_min_taxable_basis := 0;
            END;
     END;
  END IF;

  IF p_rule_code = 'GET_TRX_NATURE_TX_CODE' THEN
     FOR trx_nature_rec IN trx_nature
     LOOP
       l_nat_min_tax_rate := NULL;
       l_nat_min_tax_amount := NULL;
       l_nat_min_taxable_base := NULL;
       BEGIN
         SELECT min_percentage,
                min_amount,
                min_taxable_basis
         INTO   l_nat_min_tax_rate,
                l_nat_min_tax_amount,
                l_nat_min_taxable_base
         FROM   jl_zz_ar_tx_nat_rat
         WHERE  tax_categ_attr_val_id = trx_nature_rec.tax_categ_attr_val_id
         AND    p_trx_date BETWEEN NVL(start_date_active,p_trx_date)
                           AND     end_date_active;
       EXCEPTION
         WHEN OTHERS THEN
              l_nat_min_tax_rate := NULL;
              l_nat_min_tax_amount := NULL;
              l_nat_min_taxable_base := NULL;
       END;
       IF l_nat_min_tax_rate IS NOT NULL OR
          l_nat_min_tax_amount IS NOT NULL OR
          l_nat_min_taxable_base IS NOT NULL
       THEN
         p_min_tax_rate := NVL(l_nat_min_tax_rate,p_min_tax_rate);
         p_min_tax_amount := NVL(l_nat_min_tax_amount,p_min_tax_amount);
         p_min_taxable_basis := NVL(l_nat_min_taxable_base,p_min_taxable_basis);
         EXIT;
       END IF;
     END LOOP;
  END IF;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_minimum_thresholds: ' || '-O- Minimum Tax Rate: '||to_char(p_min_tax_rate));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_minimum_thresholds: ' || '-O- Minimum Tax Amount: '||to_char(p_min_tax_amount));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_minimum_thresholds: ' || '-O- Minimum Taxable basis: '||to_char(p_min_taxable_basis));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','jl_zz_tax.get_minimum_thresholds()-');
  END IF;

end get_minimum_thresholds;

-- Bugfix 1388703
-- Following procedure is created on 19-SEP-98 by Harsh Takle
-- Procedure will populate following PL/SQL tables
-- Table g_all_tax_grp will be populated with all tax groups and associated
-- tax categories of type DOCUMENT and determining attribute values
-- Function is called from calculate_tax_amount procedure.
-- 22-FEB-99 Changed cursor to consider
--        Credit transactions of related transactions
--        Related transactions of Main transaction for current credit
--         Transaction
--        Credit transactions of main transaction for current credit
--         Transaction
--        Credit Transactions of other related transaction for
--         current related transaction
--        Credit Transactions of main transaction for
--         current related transaction
PROCEDURE populate_plsql_tables (p_rel_cust_trx_id   IN NUMBER,
                                 p_prev_cust_trx_id  IN NUMBER,
                                 p_curr_cust_trx_id  IN NUMBER,
                                 p_trx_date	     IN DATE) IS

  l_rel_tax_lines_ctr 	          BINARY_INTEGER;
  l_rel_tax_line_amount_ctr 	  BINARY_INTEGER;
  l_count                         NUMBER;
  l_rel_trx_categ_ctr             BINARY_INTEGER;

  -- Bugfix 1388703
  CURSOR prev_tax_lines IS
        --Main Transaction of current credit transaction
        SELECT tc1.tax_category_id tax_category_id
	      ,tc1.threshold_check_grp_by grp_attr_name
	      ,tcl1.tax_attribute_value grp_attr_value
	      ,nvl(rlt1.global_attribute11,0) appl_prior_base
	      ,nvl(rlt1.global_attribute19,0) charged_tax
	      ,nvl(rlt1.global_attribute20,0) calculated_tax
	      ,rl1.customer_trx_line_id inv_line_number
	      ,r1.customer_trx_id header_trx_id
	FROM   ra_customer_trx r1
	      ,ra_customer_trx_lines rl1
	      ,ra_customer_trx_lines rlt1
	      ,ar_vat_tax v1
	      ,jl_zz_ar_tx_att_cls tcl1
	      ,jl_zz_ar_tx_categ tc1
	WHERE r1.customer_trx_id = rl1.customer_trx_id
	AND   r1.customer_trx_id = p_prev_cust_trx_id
	AND   rl1.line_type = 'LINE'
	AND   r1.customer_trx_id = rlt1.customer_trx_id
	AND   rl1.customer_trx_line_id = rlt1.link_to_cust_trx_line_id
	AND   rlt1.line_type= 'TAX'
	AND   rlt1.vat_tax_id = v1.vat_tax_id
	AND   p_trx_date >= nvl(v1.start_date,to_date( '01011900', 'ddmmyyyy'))
	AND   p_trx_date <= nvl(v1.end_date, p_trx_date)
	AND   v1.tax_type = 'VAT'
	AND   v1.global_attribute1 = tc1.tax_category_id
	AND   rl1.global_attribute3 = tcl1.tax_attr_class_code
	AND   tcl1.tax_category_id = tc1.tax_category_id
	AND   tcl1.tax_attr_class_type = 'TRANSACTION_CLASS'
	AND   tc1.txn_tax_attribute = tcl1.tax_attribute_name
	AND   p_trx_date <= tc1.end_date_active
	AND   p_trx_date >= NVL(tc1.start_date_active,p_trx_date)
        UNION --Related transactions of main transaction for current credit
              --Transaction
        SELECT tc1.tax_category_id tax_category_id
	      ,tc1.threshold_check_grp_by grp_attr_name
	      ,tcl1.tax_attribute_value grp_attr_value
	      ,nvl(rlt1.global_attribute11,0) appl_prior_base
	      ,nvl(rlt1.global_attribute19,0) charged_tax
	      ,nvl(rlt1.global_attribute20,0) calculated_tax
	      ,rl1.customer_trx_line_id inv_line_number
	      ,r1.customer_trx_id header_trx_id
	FROM   ra_customer_trx r1
	      ,ra_customer_trx_lines rl1
	      ,ra_customer_trx_lines rlt1
	      ,ar_vat_tax v1
	      ,jl_zz_ar_tx_att_cls tcl1
	      ,jl_zz_ar_tx_categ tc1
	WHERE r1.customer_trx_id = rl1.customer_trx_id
	AND   r1.related_customer_trx_id = p_prev_cust_trx_id
	AND   rl1.line_type = 'LINE'
	AND   r1.customer_trx_id = rlt1.customer_trx_id
	AND   rl1.customer_trx_line_id = rlt1.link_to_cust_trx_line_id
	AND   rlt1.line_type= 'TAX'
	AND   rlt1.vat_tax_id = v1.vat_tax_id
	AND   p_trx_date >= nvl(v1.start_date,to_date( '01011900', 'ddmmyyyy'))
	AND   p_trx_date <= nvl(v1.end_date, p_trx_date)
	AND   v1.tax_type = 'VAT'
	AND   v1.global_attribute1 = tc1.tax_category_id
	AND   rl1.global_attribute3 = tcl1.tax_attr_class_code
	AND   tcl1.tax_category_id = tc1.tax_category_id
	AND   tcl1.tax_attr_class_type = 'TRANSACTION_CLASS'
	AND   tc1.txn_tax_attribute = tcl1.tax_attribute_name
	AND   p_trx_date <= tc1.end_date_active
	AND   p_trx_date >= NVL(tc1.start_date_active,p_trx_date)
        UNION --Credit transactions of main transaction for current credit
              --Transaction
        SELECT tc1.tax_category_id tax_category_id
	      ,tc1.threshold_check_grp_by grp_attr_name
	      ,tcl1.tax_attribute_value grp_attr_value
	      ,nvl(rlt1.global_attribute11,0) appl_prior_base
	      ,nvl(rlt1.global_attribute19,0) charged_tax
	      ,nvl(rlt1.global_attribute20,0) calculated_tax
	      ,rl1.customer_trx_line_id inv_line_number
	      ,r1.customer_trx_id header_trx_id
	FROM   ra_customer_trx r1
	      ,ra_customer_trx_lines rl1
	      ,ra_customer_trx_lines rlt1
	      ,ar_vat_tax v1
	      ,jl_zz_ar_tx_att_cls tcl1
	      ,jl_zz_ar_tx_categ tc1
	WHERE r1.customer_trx_id = rl1.customer_trx_id
	AND   r1.previous_customer_trx_id = p_prev_cust_trx_id
        AND   r1.customer_trx_id <> p_curr_cust_trx_id
	AND   rl1.line_type = 'LINE'
	AND   r1.customer_trx_id = rlt1.customer_trx_id
	AND   rl1.customer_trx_line_id = rlt1.link_to_cust_trx_line_id
	AND   rlt1.line_type= 'TAX'
	AND   rlt1.vat_tax_id = v1.vat_tax_id
	AND   p_trx_date >= nvl(v1.start_date,to_date( '01011900', 'ddmmyyyy'))
	AND   p_trx_date <= nvl(v1.end_date, p_trx_date)
	AND   v1.tax_type = 'VAT'
	AND   v1.global_attribute1 = tc1.tax_category_id
	AND   rl1.global_attribute3 = tcl1.tax_attr_class_code
	AND   tcl1.tax_category_id = tc1.tax_category_id
	AND   tcl1.tax_attr_class_type = 'TRANSACTION_CLASS'
	AND   tc1.txn_tax_attribute = tcl1.tax_attribute_name
	AND   p_trx_date <= tc1.end_date_active
	AND   p_trx_date >= NVL(tc1.start_date_active,p_trx_date)
        UNION --Credit transactions of related transactions
        SELECT tc1.tax_category_id tax_category_id
	      ,tc1.threshold_check_grp_by grp_attr_name
	      ,tcl1.tax_attribute_value grp_attr_value
	      ,nvl(rlt1.global_attribute11,0) appl_prior_base
	      ,nvl(rlt1.global_attribute19,0) charged_tax
	      ,nvl(rlt1.global_attribute20,0) calculated_tax
	      ,rl1.customer_trx_line_id inv_line_number
	      ,r1.customer_trx_id header_trx_id
	FROM   ra_customer_trx r1
	      ,ra_customer_trx r2
	      ,ra_customer_trx_lines rl1
	      ,ra_customer_trx_lines rlt1
	      ,ar_vat_tax v1
	      ,jl_zz_ar_tx_att_cls tcl1
	      ,jl_zz_ar_tx_categ tc1
	WHERE r2.related_customer_trx_id = p_prev_cust_trx_id
        AND   r2.customer_trx_id = r1.previous_customer_trx_id
	AND   r1.customer_trx_id = rl1.customer_trx_id
	AND   rl1.line_type = 'LINE'
	AND   r1.customer_trx_id = rlt1.customer_trx_id
	AND   rl1.customer_trx_line_id = rlt1.link_to_cust_trx_line_id
	AND   rlt1.line_type= 'TAX'
	AND   rlt1.vat_tax_id = v1.vat_tax_id
	AND   p_trx_date >= nvl(v1.start_date,to_date( '01011900', 'ddmmyyyy'))
	AND   p_trx_date <= nvl(v1.end_date, p_trx_date)
	AND   v1.tax_type = 'VAT'
	AND   v1.global_attribute1 = tc1.tax_category_id
	AND   rl1.global_attribute3 = tcl1.tax_attr_class_code
	AND   tcl1.tax_category_id = tc1.tax_category_id
	AND   tcl1.tax_attr_class_type = 'TRANSACTION_CLASS'
	AND   tc1.txn_tax_attribute = tcl1.tax_attribute_name
	AND   p_trx_date <= tc1.end_date_active
	AND   p_trx_date >= NVL(tc1.start_date_active,p_trx_date)
	ORDER BY 7, 6, 1;

  -- Bugfix 1388703
  CURSOR rel_tax_lines IS
        -- Main transaction of current related transaction
	SELECT tc1.tax_category_id tax_category_id
	      ,tc1.threshold_check_grp_by grp_attr_name
	      ,tcl1.tax_attribute_value grp_attr_value
	      ,nvl(rlt1.taxable_amount,0) appl_prior_base
	      ,fnd_number.canonical_to_number(nvl(rlt1.global_attribute19,0))
                                          charged_tax
	      ,fnd_number.canonical_to_number(nvl(rlt1.global_attribute20,0))
                                          calculated_tax
	      ,rl1.customer_trx_line_id inv_line_number
	      ,r1.customer_trx_id header_trx_id
	FROM   ra_customer_trx r1
	      ,ra_customer_trx_lines rl1
	      ,ra_customer_trx_lines rlt1
	      ,ar_vat_tax v1
	      ,jl_zz_ar_tx_att_cls tcl1
	      ,jl_zz_ar_tx_categ tc1
	WHERE r1.customer_trx_id = rl1.customer_trx_id
	AND   r1.customer_trx_id = p_rel_cust_trx_id
	AND   rl1.line_type = 'LINE'
	AND   r1.customer_trx_id = rlt1.customer_trx_id
	AND   rl1.customer_trx_line_id = rlt1.link_to_cust_trx_line_id
	AND   rlt1.line_type= 'TAX'
	AND   rlt1.vat_tax_id = v1.vat_tax_id
	AND   v1.tax_type = 'VAT'
	AND   v1.global_attribute1 = tc1.tax_category_id
	AND   rl1.global_attribute3 = tcl1.tax_attr_class_code
	AND   tcl1.tax_category_id = tc1.tax_category_id
	AND   tcl1.tax_attr_class_type = 'TRANSACTION_CLASS'
	AND   tc1.txn_tax_attribute = tcl1.tax_attribute_name
	AND   p_trx_date <= tc1.end_date_active
	AND   p_trx_date >= NVL(tc1.start_date_active,p_trx_date)
	UNION --Related Transactions of main transaction of
              --current related transaction
	SELECT tc1.tax_category_id tax_category_id
	      ,tc1.threshold_check_grp_by grp_attr_name
	      ,tcl1.tax_attribute_value grp_attr_value
	      ,nvl(rlt1.taxable_amount,0) appl_prior_base
	      ,fnd_number.canonical_to_number(nvl(rlt1.global_attribute19,0))
                                          charged_tax
	      ,fnd_number.canonical_to_number(nvl(rlt1.global_attribute20,0))
                                          calculated_tax
	      ,rl1.customer_trx_line_id inv_line_number
	      ,r1.customer_trx_id header_trx_id
	FROM   ra_customer_trx r1
	      ,ra_customer_trx_lines rl1
	      ,ra_customer_trx_lines rlt1
	      ,ar_vat_tax v1
	      ,jl_zz_ar_tx_att_cls tcl1
	      ,jl_zz_ar_tx_categ tc1
	WHERE r1.customer_trx_id = rl1.customer_trx_id
	AND   r1.related_customer_trx_id = p_rel_cust_trx_id
	AND   rl1.line_type = 'LINE'
	AND   r1.customer_trx_id = rlt1.customer_trx_id
	AND   rl1.customer_trx_line_id = rlt1.link_to_cust_trx_line_id
	AND   rlt1.line_type= 'TAX'
	AND   rlt1.vat_tax_id = v1.vat_tax_id
	AND   v1.tax_type = 'VAT'
	AND   v1.global_attribute1 = tc1.tax_category_id
	AND   rl1.global_attribute3 = tcl1.tax_attr_class_code
	AND   tcl1.tax_category_id = tc1.tax_category_id
	AND   tcl1.tax_attr_class_type = 'TRANSACTION_CLASS'
	AND   tc1.txn_tax_attribute = tcl1.tax_attribute_name
	AND   p_trx_date <= tc1.end_date_active
	AND   p_trx_date >= NVL(tc1.start_date_active,p_trx_date)
        UNION --Credit Transactions of main transaction for
              -- current related transaction
	SELECT tc1.tax_category_id tax_category_id
	      ,tc1.threshold_check_grp_by grp_attr_name
	      ,tcl1.tax_attribute_value grp_attr_value
	      ,nvl(rlt1.taxable_amount,0) appl_prior_base
	      ,fnd_number.canonical_to_number(nvl(rlt1.global_attribute19,0))
                                          charged_tax
	      ,fnd_number.canonical_to_number(nvl(rlt1.global_attribute20,0))
                                          calculated_tax
	      ,rl1.customer_trx_line_id inv_line_number
	      ,r1.customer_trx_id header_trx_id
	FROM   ra_customer_trx r1
	      ,ra_customer_trx_lines rl1
	      ,ra_customer_trx_lines rlt1
	      ,ar_vat_tax v1
	      ,jl_zz_ar_tx_att_cls tcl1
	      ,jl_zz_ar_tx_categ tc1
	WHERE r1.customer_trx_id = rl1.customer_trx_id
	AND   r1.previous_customer_trx_id = p_rel_cust_trx_id
	AND   rl1.line_type = 'LINE'
	AND   r1.customer_trx_id = rlt1.customer_trx_id
	AND   rl1.customer_trx_line_id = rlt1.link_to_cust_trx_line_id
	AND   rlt1.line_type= 'TAX'
	AND   rlt1.vat_tax_id = v1.vat_tax_id
	AND   v1.tax_type = 'VAT'
	AND   v1.global_attribute1 = tc1.tax_category_id
	AND   rl1.global_attribute3 = tcl1.tax_attr_class_code
	AND   tcl1.tax_category_id = tc1.tax_category_id
	AND   tcl1.tax_attr_class_type = 'TRANSACTION_CLASS'
	AND   tc1.txn_tax_attribute = tcl1.tax_attribute_name
	AND   p_trx_date <= tc1.end_date_active
	AND   p_trx_date >= NVL(tc1.start_date_active,p_trx_date)
        UNION -- Credit Transactions of other related transaction for
              -- current related transactions
	SELECT tc1.tax_category_id tax_category_id
	      ,tc1.threshold_check_grp_by grp_attr_name
	      ,tcl1.tax_attribute_value grp_attr_value
	      ,nvl(rlt1.taxable_amount,0) appl_prior_base
	      ,fnd_number.canonical_to_number(nvl(rlt1.global_attribute19,0))
                                          charged_tax
	      ,fnd_number.canonical_to_number(nvl(rlt1.global_attribute20,0))
                                          calculated_tax
	      ,rl1.customer_trx_line_id inv_line_number
	      ,r1.customer_trx_id header_trx_id
	FROM   ra_customer_trx r1
              ,ra_customer_trx r2
	      ,ra_customer_trx_lines rl1
	      ,ra_customer_trx_lines rlt1
	      ,ar_vat_tax v1
	      ,jl_zz_ar_tx_att_cls tcl1
	      ,jl_zz_ar_tx_categ tc1
	WHERE r2.related_customer_trx_id = p_rel_cust_trx_id
	AND   r2.customer_trx_id = r1.previous_customer_trx_id
        AND   r1.customer_trx_id = rl1.customer_trx_id
	AND   rl1.line_type = 'LINE'
	AND   r1.customer_trx_id = rlt1.customer_trx_id
	AND   rl1.customer_trx_line_id = rlt1.link_to_cust_trx_line_id
	AND   rlt1.line_type= 'TAX'
	AND   rlt1.vat_tax_id = v1.vat_tax_id
	AND   v1.tax_type = 'VAT'
	AND   v1.global_attribute1 = tc1.tax_category_id
	AND   rl1.global_attribute3 = tcl1.tax_attr_class_code
	AND   tcl1.tax_category_id = tc1.tax_category_id
	AND   tcl1.tax_attr_class_type = 'TRANSACTION_CLASS'
	AND   tc1.txn_tax_attribute = tcl1.tax_attribute_name
	AND   p_trx_date <= tc1.end_date_active
	AND   p_trx_date >= NVL(tc1.start_date_active,p_trx_date)
        ORDER BY 7, 6, 1;

   -- Bugfix 1388703
   CURSOR curr_tax_lines IS
	SELECT tc1.tax_category_id tax_category_id
	      ,tc1.threshold_check_grp_by grp_attr_name
	      ,tcl1.tax_attribute_value grp_attr_value
	      ,nvl(rlt1.global_attribute11,0) appl_prior_base
	      ,nvl(rlt1.global_attribute19,0) charged_tax
	      ,nvl(rlt1.global_attribute20,0) calculated_tax
	      ,rl1.customer_trx_line_id inv_line_number
	      ,r1.customer_trx_id header_trx_id
	FROM   ra_customer_trx r1
	      ,ra_customer_trx_lines rl1
	      ,ra_customer_trx_lines rlt1
	      ,ar_vat_tax v1
	      ,jl_zz_ar_tx_att_cls tcl1
	      ,jl_zz_ar_tx_categ tc1
	WHERE r1.customer_trx_id = rl1.customer_trx_id
        AND   r1.customer_trx_id = p_curr_cust_trx_id
	AND   rl1.line_type = 'LINE'
	AND   r1.customer_trx_id = rlt1.customer_trx_id
	AND   rl1.customer_trx_line_id = rlt1.link_to_cust_trx_line_id
	AND   rlt1.line_type= 'TAX'
	AND   rlt1.vat_tax_id = v1.vat_tax_id
	AND   p_trx_date >= nvl(v1.start_date,to_date( '01011900', 'ddmmyyyy'))
	AND   p_trx_date <= nvl(v1.end_date,p_trx_date)
	AND   v1.tax_type = 'VAT'
	AND   v1.global_attribute1 = tc1.tax_category_id
	AND   rl1.global_attribute3 = tcl1.tax_attr_class_code
	AND   tcl1.tax_category_id = tc1.tax_category_id
	AND   tcl1.tax_attr_class_type = 'TRANSACTION_CLASS'
	AND   tc1.txn_tax_attribute = tcl1.tax_attribute_name
	AND   p_trx_date <= tc1.end_date_active
	AND   p_trx_date >= NVL(tc1.start_date_active,p_trx_date)
	ORDER BY 7, 6, 1;

   cursor rel_trx_categ is
        SELECT tc1.tax_category_id tax_category_id
        FROM  ra_customer_trx_lines rlt1
              ,ar_vat_tax v1
              ,jl_zz_ar_tx_categ tc1
        WHERE rlt1.customer_trx_id = p_rel_cust_trx_id
        AND   rlt1.line_type= 'TAX'
        AND   rlt1.vat_tax_id = v1.vat_tax_id
        AND   v1.tax_type = 'VAT'
        AND   v1.global_attribute1 = tc1.tax_category_id
        AND   tc1.threshold_check_grp_by = 'DOCUMENT';

   cursor cur_trx_categ is
        SELECT tc1.tax_category_id tax_category_id
        FROM  ra_customer_trx_lines rlt1
              ,ar_vat_tax v1
              ,jl_zz_ar_tx_categ tc1
        WHERE rlt1.customer_trx_id = p_curr_cust_trx_id
        AND   rlt1.line_type= 'TAX'
        AND   rlt1.vat_tax_id = v1.vat_tax_id
        AND   v1.tax_type = 'VAT'
        AND   v1.global_attribute1 = tc1.tax_category_id
        AND   tc1.threshold_check_grp_by = 'DOCUMENT';



 l_jlzz_ar_tx_use_whole_operatn ar_system_parameters_all.global_attribute19%type;

BEGIN
     g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','jl_zz_tax.populate_plsql_tables()+');
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','populate_plsql_tables: ' || '-P- Related Customer Trx Id: '||to_char(p_rel_cust_trx_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','populate_plsql_tables: ' || '-P- Previous Customer Trx Id: '||to_char(p_prev_cust_trx_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','populate_plsql_tables: ' || '-P- Current Customer Trx Id: '||to_char(p_curr_cust_trx_id));
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-P- Trx Date: '||to_char(p_trx_date,'DD-MM-YYYY'));
  END IF;

  g_rel_tax_line_amounts.DELETE;
  g_rel_trx_categ.DELETE;

  l_jlzz_ar_tx_use_whole_operatn :=
        JL_ZZ_SYS_OPTIONS_PKG.get_ar_tx_use_whole_operation(mo_global.get_current_org_id);

  IF NVL(l_jlzz_ar_tx_use_whole_operatn,'N') = 'Y' THEN

     IF (g_level_statement >= g_current_runtime_level) THEN
     	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','populate_plsql_tables: ' || '-- Use Whole Operation ');
     END IF;

     l_rel_tax_lines_ctr := 1;
     l_rel_tax_line_amount_ctr := 1;
     l_rel_trx_categ_ctr := 1;

    IF p_rel_cust_trx_id IS NOT NULL THEN

     FOR rel_tax_lines_rec IN rel_tax_lines
     LOOP

       IF (g_level_statement >= g_current_runtime_level) THEN
       	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','populate_plsql_tables: ' || '-- Rel tax line categ: ' ||
                                to_char(rel_tax_lines_rec.tax_category_id));
       	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','populate_plsql_tables: ' || '-- Rel tax line grouping attribute name: ' ||
                                rel_tax_lines_rec.grp_attr_name);
       END IF;

       g_rel_tax_line_amounts(l_rel_tax_line_amount_ctr).TaxCateg :=
                                              rel_tax_lines_rec.tax_category_id;
       g_rel_tax_line_amounts(l_rel_tax_line_amount_ctr).GrpAttrName :=
                                                rel_tax_lines_rec.grp_attr_name;
       g_rel_tax_line_amounts(l_rel_tax_line_amount_ctr).GrpAttrValue :=
                                               rel_tax_lines_rec.grp_attr_value;
       g_rel_tax_line_amounts(l_rel_tax_line_amount_ctr).ApplPriorBase :=
                                              rel_tax_lines_rec.appl_prior_base;
       g_rel_tax_line_amounts(l_rel_tax_line_amount_ctr).ChargedTax :=
                                                  rel_tax_lines_rec.charged_tax;
       g_rel_tax_line_amounts(l_rel_tax_line_amount_ctr).CalcltdTax :=
                                               rel_tax_lines_rec.calculated_tax;

       l_rel_tax_line_amount_ctr := l_rel_tax_line_amount_ctr + 1;
       g_prev_cust_trx_line_number := rel_tax_lines_rec.inv_line_number;
       g_prev_invoice_line_number := rel_tax_lines_rec.inv_line_number;
       g_prev_header_id := rel_tax_lines_rec.header_trx_id;

     END LOOP;

     FOR rel_trx_categ_rec IN rel_trx_categ
     LOOP

       IF (g_level_statement >= g_current_runtime_level) THEN
       	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','populate_plsql_tables: ' || '-- Rel tax line categ: ' ||
                                to_char(rel_trx_categ_rec.tax_category_id));
       END IF;

       g_rel_trx_categ(rel_trx_categ_rec.tax_category_id).ExistFlag := 'Y';

     END LOOP;

    END IF;

    IF p_prev_cust_trx_id IS NOT NULL THEN

     FOR prev_tax_lines_rec IN prev_tax_lines
     LOOP

       IF (g_level_statement >= g_current_runtime_level) THEN
       	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','populate_plsql_tables: ' || '-- Prev tax line categ: ' ||
                                 to_char(prev_tax_lines_rec.tax_category_id));
       	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','populate_plsql_tables: ' || '-- Prev tax line grouping attribute name: ' ||
                                 prev_tax_lines_rec.grp_attr_name);
       END IF;

       g_rel_tax_line_amounts(l_rel_tax_line_amount_ctr).TaxCateg :=
                                              prev_tax_lines_rec.tax_category_id;
       g_rel_tax_line_amounts(l_rel_tax_line_amount_ctr).GrpAttrName :=
                                                prev_tax_lines_rec.grp_attr_name;
       g_rel_tax_line_amounts(l_rel_tax_line_amount_ctr).GrpAttrValue :=
                                               prev_tax_lines_rec.grp_attr_value;
       g_rel_tax_line_amounts(l_rel_tax_line_amount_ctr).ApplPriorBase :=
                                              prev_tax_lines_rec.appl_prior_base;
       g_rel_tax_line_amounts(l_rel_tax_line_amount_ctr).ChargedTax :=
                                                  prev_tax_lines_rec.charged_tax;
       g_rel_tax_line_amounts(l_rel_tax_line_amount_ctr).CalcltdTax :=
                                               prev_tax_lines_rec.calculated_tax;

       l_rel_tax_line_amount_ctr := l_rel_tax_line_amount_ctr + 1;
       g_prev_cust_trx_line_number := prev_tax_lines_rec.inv_line_number;
       g_prev_invoice_line_number := prev_tax_lines_rec.inv_line_number;
       g_prev_header_id := prev_tax_lines_rec.header_trx_id;

     END LOOP;
    END IF;

       IF (g_level_statement >= g_current_runtime_level) THEN
          FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- Related Tax lines total entries: ' ||
                             to_char( l_rel_tax_lines_ctr - 1));
          FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- Related Tax line amounts total entries: ' ||
                             to_char( l_rel_tax_line_amount_ctr - 1));
       END IF;

    FOR curr_tax_lines_rec IN curr_tax_lines
    LOOP

       IF (g_level_statement >= g_current_runtime_level) THEN
       	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','populate_plsql_tables: ' || '-- Curr tax line categ: ' ||
                                to_char(curr_tax_lines_rec.tax_category_id));
       	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','populate_plsql_tables: ' || '-- Curr tax line grouping attribute name: ' ||
                                curr_tax_lines_rec.grp_attr_name);
       END IF;

       g_rel_tax_line_amounts(l_rel_tax_line_amount_ctr).TaxCateg :=
                                              curr_tax_lines_rec.tax_category_id;
       g_rel_tax_line_amounts(l_rel_tax_line_amount_ctr).GrpAttrName :=
                                                curr_tax_lines_rec.grp_attr_name;
       g_rel_tax_line_amounts(l_rel_tax_line_amount_ctr).GrpAttrValue :=
                                               curr_tax_lines_rec.grp_attr_value;
       g_rel_tax_line_amounts(l_rel_tax_line_amount_ctr).ApplPriorBase :=
                                              curr_tax_lines_rec.appl_prior_base;
       g_rel_tax_line_amounts(l_rel_tax_line_amount_ctr).ChargedTax :=
                                                  curr_tax_lines_rec.charged_tax;
       g_rel_tax_line_amounts(l_rel_tax_line_amount_ctr).CalcltdTax :=
                                               curr_tax_lines_rec.calculated_tax;

       l_rel_tax_line_amount_ctr := l_rel_tax_line_amount_ctr + 1;
       g_prev_cust_trx_line_number := curr_tax_lines_rec.inv_line_number;
       g_prev_invoice_line_number := curr_tax_lines_rec.inv_line_number;
       g_prev_header_id := curr_tax_lines_rec.header_trx_id;

     END LOOP;

     FOR cur_trx_categ_rec IN cur_trx_categ
     LOOP

       IF (g_level_statement >= g_current_runtime_level) THEN
       	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','populate_plsql_tables: ' || '-- cur tax line categ: ' ||
                                to_char(cur_trx_categ_rec.tax_category_id));
       END IF;

       g_rel_trx_categ(cur_trx_categ_rec.tax_category_id).ExistFlag := 'Y';

     END LOOP;

       IF (g_level_statement >= g_current_runtime_level) THEN
         FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- Related Tax lines total entries: ' ||
                             to_char( l_rel_trx_categ_ctr - 1));
         FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- Related Tax line amounts total entries: ' ||
                             to_char( l_rel_tax_line_amount_ctr - 1));
       END IF;

  END IF;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','jl_zz_tax.populate_plsql_tables()-');
  END IF;

END populate_plsql_tables;

FUNCTION get_functional_curr_amount(p_amount IN NUMBER,
                                    p_exchange_rate IN NUMBER) RETURN NUMBER IS
  l_functional_amount NUMBER;
BEGIN

  l_functional_amount := ZX_PRODUCT_INTEGRATION_PKG.tax_curr_round (
                              p_amount * p_exchange_rate,
                              ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.trx_currency_code,
                              ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.precision,
                              ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.minimum_accountable_unit,
                              ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_rounding_rule,
                              'Y');

  RETURN l_functional_amount;

END get_functional_curr_amount;

--========================================================================
-- PRIVATE PROCEDURE
--    calculate_tax_amount
--
-- DESCRIPTION
--    The procedure calculates the tax amount from a given tax rate.
--
-- CALLED FROM
--    jl_zz_tax.calculate_latin_tax
--
-- HISTORY
--    25-SEP-98  Harsh Takle    Created
--
--========================================================================
-- Bugfix 1388703
PROCEDURE calculate_tax_amount (p_transaction_nature       IN     VARCHAR2,
                                p_transaction_nature_class IN     VARCHAR2,
                                p_organization_class       IN     VARCHAR2,
                                p_base_amount	           IN     NUMBER,
                                p_tax_group	           IN     NUMBER,
                                p_tax_category_id	   IN     NUMBER,
                                p_trx_date	           IN     DATE,
                                p_rule_id	           IN     NUMBER,
                                p_ship_to_site_use_id      IN     NUMBER,
                                p_bill_to_site_use_id      IN     NUMBER,
                                p_establishment_type       IN     VARCHAR2,
                                p_contributor_type         IN     VARCHAR2,
                                p_customer_trx_id          IN     NUMBER,
                                p_customer_trx_line_id     IN     NUMBER,
                                p_related_customer_trx_id  IN     NUMBER,
                                p_previous_customer_trx_id IN     NUMBER,
                                p_location_id              IN     NUMBER,
                                p_contributor_class        IN     VARCHAR2,
                                p_set_of_books_id          IN     NUMBER,
                                p_latin_return_code        IN OUT NOCOPY VARCHAR,
                                p_tax_amount	           IN OUT NOCOPY NUMBER,
                                p_tax_rate	           IN OUT NOCOPY NUMBER,
                                p_calculated_tax_amount    IN OUT NOCOPY NUMBER,
                                p_exchange_rate            IN     NUMBER) IS

  l_rel_tax_line_amt_ctr  BINARY_INTEGER;
  l_rel_tax_lines_ctr     BINARY_INTEGER;
  l_rule_code 		  jl_zz_ar_tx_rules.rule%type;
  l_tax_code		  ar_vat_tax.tax_code%type;
  l_grp_attr_name 	  VARCHAR2(30);
  l_grp_attr_val	  VARCHAR2(30);
  l_operation_level	  VARCHAR2(30);
  l_func_curr_taxable_base NUMBER;
  l_min_taxable_base	  NUMBER;
  l_min_tax_amount	  NUMBER;
  l_min_tax_rate	  NUMBER;
  l_applicable_prior_base NUMBER;
  l_tot_calculated_tax_amt NUMBER;
  l_taxable_base	  NUMBER;
  l_sch_tax_rate	  NUMBER;
  l_sch_tax_amount	  NUMBER;
  l_charged_tax_amount	  NUMBER;
  l_return_status	  VARCHAR2(20);
  l_error_message	  VARCHAR2(250);
  ERROR_FROM_FUNCTION     EXCEPTION;
  err_num                 NUMBER;
  err_msg                 NUMBER;
  l_tax_category_match_flag VARCHAR2(1);
  l_rel_trx_categ_ctr       NUMBER;

  CURSOR tax_schedule IS
    SELECT tax_code,
           min_taxable_basis,
           max_taxable_basis
    FROM   jl_zz_ar_tx_schedules
    WHERE  tax_category_id = p_tax_category_id
    AND    p_trx_date BETWEEN NVL(start_date_active,p_trx_date)
                      AND     end_date_active;



BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','jl_zz_tax.calculate_tax_amount()+');
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-P- Trx Nature: '|| p_transaction_nature);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-P- Trx Nature Class: '||p_transaction_nature_class);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-P- Organization Class: '||p_organization_class);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-P- Base Amount: ' ||to_char(p_base_amount));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-P- Tax Group: '   ||to_char(p_tax_group));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-P- Tax category: '||to_char(p_tax_category_id));
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-P- Trx date: '    ||to_char(p_trx_date,'DD-MM-YYYY'));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-P- Rule Id: '     ||to_char(p_rule_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-P- Ship to Site: '||to_char(p_ship_to_site_use_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-P- Bill to site: '||to_char(p_bill_to_site_use_id) );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-P- Establishment Type: '|| p_establishment_type);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-P- Contributor Type: '|| p_contributor_type);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-P- Customer Trx Id: '||to_char(p_customer_trx_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-P- Customer Trx Line Id: '||to_char(p_customer_trx_line_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-P- Related customer Trx Id: '||
                                            to_char(p_related_customer_trx_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-P- Previous Customer Trx Id: '||
                                           to_char(p_previous_customer_trx_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-P- Location Id: '||to_char(p_location_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-P- Contributor Class: '||p_contributor_class);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-P- Set Of Books Id: '||to_char(p_set_of_books_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-P- Calculated Tax Amount: '||
                                              to_char(p_calculated_tax_amount));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-P- Tax Amount: '  ||to_char(p_tax_amount));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-P- Tax Rate: '    ||to_char(p_tax_rate));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-P- Exchange Rate: '    ||to_char(p_exchange_rate));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-P- Last Header Id: '||to_char(g_prev_header_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-P- Prev invoice line number: '||
                                          to_char(g_prev_invoice_line_number));
  END IF;

  g_first_tax_line := FALSE;
  p_latin_return_code := 'SUCCESS';
  IF p_customer_trx_id <> NVL(g_prev_header_id,0) OR
     g_prev_invoice_line_number IS NULL OR
     p_customer_trx_line_id < g_prev_invoice_line_number OR
     (g_first_processed_invoice_line = p_customer_trx_line_id AND
      g_first_processed_category_id = p_tax_category_id) THEN

     g_first_tax_line := TRUE;

     populate_plsql_tables(p_related_customer_trx_id,
                           p_previous_customer_trx_id,
                           p_customer_trx_id,
                           p_trx_date);

     g_first_processed_invoice_line := p_customer_trx_line_id;
     g_first_processed_category_id := p_tax_category_id;

     IF (g_level_statement >= g_current_runtime_level) THEN
     	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Last customer trx line number: '||
                                      to_char(g_prev_cust_trx_line_number));
     	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Last invoice line number: ' ||
                                           to_char(g_prev_invoice_line_number));
     	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Last header id: '||to_char(g_prev_header_id));
     END IF;
  END IF;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- First Processed line: '||
                                       to_char(g_first_processed_invoice_line));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- First Processed category id: '||
                                        to_char(g_first_processed_category_id));
  END IF;

  l_rule_code := NULL;
  -- Bugfix 1388703
  BEGIN
    SELECT rule
    INTO   l_rule_code
    FROM   jl_zz_ar_tx_rules
    WHERE  rule_id = p_rule_id;
    EXCEPTION
      WHEN OTHERS THEN
           l_rule_code := NULL;
  END;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Rule code: '||l_rule_code);
  END IF;

  get_minimum_thresholds(p_tax_group, p_tax_category_id, p_trx_date,
		         p_establishment_type, p_contributor_type,
			 p_transaction_nature,
			 p_transaction_nature_class,
                         l_rule_code,
                         l_min_tax_rate, l_min_tax_amount, l_min_taxable_base);

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Minimum Tax rate: '||to_char(l_min_tax_rate));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Minimum Tax Amount: '||to_char(l_min_tax_amount));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Minimum Taxable base: '||to_char(l_min_taxable_base));
  END IF;

  l_grp_attr_name := Null;
  l_operation_level := Null;
  BEGIN
    SELECT threshold_check_grp_by,
           threshold_check_level
    INTO   l_grp_attr_name,
           l_operation_level
    FROM   jl_zz_ar_tx_categ
    WHERE  tax_category_id = p_tax_category_id
    AND    p_trx_date BETWEEN NVL(start_date_active,p_trx_date)
                      AND     end_date_active;
  EXCEPTION
    WHEN OTHERS THEN
       If (g_level_statement >= g_current_runtime_level) then
         FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','Exception when getting threshold_check_level: '||SQLCODE||SQLERRM);
       END IF;
         l_grp_attr_name := Null;
         l_operation_level := Null;
        --++ nipatel added for LTE healthcheck testing
        -- l_grp_attr_name := 'LINE';
        -- l_operation_level := 'LINE';
  END;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Grouping Attr Name: '||l_grp_attr_name);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Operation Level: '||l_operation_level);
  END IF;

  IF l_grp_attr_name = 'LINE' THEN
     l_grp_attr_val := 'LINE';
  ELSIF l_grp_attr_name = 'DOCUMENT' THEN
     l_grp_attr_val := 'DOCUMENT';
  ELSE
     BEGIN
       SELECT tax_attribute_value
       INTO   l_grp_attr_val
       FROM   jl_zz_ar_tx_att_cls ac
       WHERE  tax_attr_class_type = 'TRANSACTION_CLASS'
       AND    tax_attr_class_code = p_transaction_nature_class
       AND    enabled_flag = 'Y'
       AND    tax_category_id = p_tax_category_id
       AND    tax_attribute_type = 'TRANSACTION_ATTRIBUTE'
       AND    tax_attribute_name = l_grp_attr_name;
     EXCEPTION
       WHEN OTHERS THEN
            l_grp_attr_val := NULL;
     END;
  END IF;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Grouping attribute Value: '||l_grp_attr_val);
  END IF;

  l_return_status := validate_current_tax_line(
                                      p_related_customer_trx_id,
                                      p_customer_trx_id,
    				      p_customer_trx_line_id,
                                      l_operation_level,
                                      p_tax_group,
                                      p_tax_category_id,
                                      l_grp_attr_name,
				      p_trx_date,
                               nvl(p_ship_to_site_use_id,p_bill_to_site_use_id),
				      p_organization_class,
                                      ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf6,
                                      p_transaction_nature_class);

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- validate current tax line return status: '||
                                                               l_return_status);
  END IF;

  IF l_return_status = 'ERROR' THEN
     RAISE ERROR_FROM_FUNCTION;
  END IF;

 IF (g_level_statement >= g_current_runtime_level) THEN
   FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','l_operation_level = '||l_operation_level);
 END IF;

  IF l_operation_level = 'LINE' THEN
     l_applicable_prior_base := 0;
     l_charged_tax_amount := 0;
     l_tot_calculated_tax_amt := 0;
  ELSE
     get_prior_base(l_operation_level, p_tax_category_id,
                    l_grp_attr_name, l_grp_attr_val,
                    l_applicable_prior_base, l_charged_tax_amount,
                    l_tot_calculated_tax_amt);
  END IF;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Appl Prior Base: '||to_char(l_applicable_prior_base));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Charged Tax Amount: '||to_char(l_charged_tax_amount));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Total Calculated Tax Amount: '||
                                             to_char(l_tot_calculated_tax_amt));
  END IF;
  IF (g_level_statement >= g_current_runtime_level) THEN
   FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.trx_currency_code = '||
                         ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.trx_currency_code);
   FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.precision = '||
                         ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.precision);
   FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.minimum_accountable_unit = '||
                        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.minimum_accountable_unit);
   FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_rounding_rule ='||
                         ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_rounding_rule);
  END IF;

  p_calculated_tax_amount := ZX_PRODUCT_INTEGRATION_PKG.tax_curr_round (
                                  p_base_amount * (p_tax_rate / 100),
                                  ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.trx_currency_code,
                                  ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.precision,
                                  ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.minimum_accountable_unit,
                                  ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_rounding_rule,
                                  'Y');
  p_tax_amount := 0;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Current Calculated Tax Amount (rounded): '||
                                             to_char(p_calculated_tax_amount));
  END IF;

  IF get_functional_curr_amount(abs(l_applicable_prior_base + p_base_amount),
                                p_exchange_rate) >=
                                                  nvl(l_min_taxable_base,0) THEN
     l_taxable_base := l_applicable_prior_base + p_base_amount;

     IF (g_level_statement >= g_current_runtime_level) THEN
     	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Taxable base: '  ||to_char(l_taxable_base));
     END IF;

     l_func_curr_taxable_base :=
          get_functional_curr_amount(l_taxable_base,p_exchange_rate);

     IF (g_level_statement >= g_current_runtime_level) THEN
     	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Taxable base in functional currency: '||
                                             to_char(l_func_curr_taxable_base));
     END IF;

     l_sch_tax_amount := 0;
     IF l_rule_code = 'GET_TX_SCH_TX_CODE' THEN
        p_tax_rate := 0;
        l_sch_tax_rate := NULL;
        FOR tax_schedule_rec IN tax_schedule
        LOOP
          l_sch_tax_rate := NULL;
          BEGIN
            SELECT tax_rate
            INTO   l_sch_tax_rate
            FROM   ar_vat_tax
            WHERE  tax_code = tax_schedule_rec.tax_code
            AND    set_of_books_id = p_set_of_books_id
            AND    start_date <= p_trx_date
            AND    NVL(end_date,p_trx_date) >= p_trx_date
            AND    nvl(enabled_flag,'Y') = 'Y'
            AND    nvl(tax_class,'O') = 'O';
          EXCEPTION
            WHEN OTHERS THEN
                 l_sch_tax_rate := 0;
          END;
          IF l_func_curr_taxable_base
                            BETWEEN tax_schedule_rec.min_taxable_basis
                            AND     tax_schedule_rec.max_taxable_basis THEN
             p_tax_rate := l_sch_tax_rate;
             l_sch_tax_amount := l_sch_tax_amount + ((l_func_curr_taxable_base -
                    tax_schedule_rec.min_taxable_basis) * (l_sch_tax_rate/100));
          ELSIF l_func_curr_taxable_base > tax_schedule_rec.max_taxable_basis
             THEN
               l_sch_tax_amount := l_sch_tax_amount +
                            ((tax_schedule_rec.max_taxable_basis -
                              tax_schedule_rec.min_taxable_basis) *
                                     (l_sch_tax_rate/100));
          END IF;
          IF (g_level_statement >= g_current_runtime_level) THEN
          	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Tax Schedule Tax Rate: '||to_char(l_sch_tax_rate));
          	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Tax Schedule Tax Amount: '||
                                                     to_char(l_sch_tax_amount));
          END IF;
        END LOOP;

        IF (g_level_statement >= g_current_runtime_level) THEN
        	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Tax Schedule Tax Rate: '||to_char(p_tax_rate));
        	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Tax Schedule Tax Amount in functional currency: '||
                                                     to_char(l_sch_tax_amount));
        END IF;

        p_calculated_tax_amount :=
                        ZX_PRODUCT_INTEGRATION_PKG.tax_curr_round (
                             (l_sch_tax_amount / p_exchange_rate),
                             ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.trx_currency_code,
                             ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.precision,
                             ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.minimum_accountable_unit,
                             ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_rounding_rule,
                             'Y');
     END IF;

     IF (g_level_statement >= g_current_runtime_level) THEN
     	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Tax Rate after checking SCH method: '||
                                                           to_char(p_tax_rate));
     	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Taxable base: '  ||to_char(l_taxable_base));
     	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Calculated Tax Amount (rounded): '  ||
                                              to_char(p_calculated_tax_amount));
     END IF;

     IF l_min_tax_rate IS NOT NULL AND p_tax_rate < l_min_tax_rate THEN
        IF (g_level_statement >= g_current_runtime_level) THEN
        	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Reverse charged tax : '||
                                                 to_char(l_charged_tax_amount));
        END IF;
        p_tax_amount := l_charged_tax_amount * -1;
     ELSE
        IF get_functional_curr_amount(
               abs(p_calculated_tax_amount+l_tot_calculated_tax_amt),
               p_exchange_rate) >= nvl(l_min_tax_amount,0) THEN

           IF (g_level_statement >= g_current_runtime_level) THEN
           	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Calculated Tax Amount is greater than minimum'||
                          ' tax amount');
           END IF;

           p_tax_amount := p_calculated_tax_amount + l_tot_calculated_tax_amt
                                           - l_charged_tax_amount;
        ELSE
           IF (g_level_statement >= g_current_runtime_level) THEN
           	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Reverse charged tax : '||
                                                 to_char(l_charged_tax_amount));
           END IF;
           p_tax_amount := l_charged_tax_amount * -1;
        END IF;
     END IF;

  ELSE
     IF (g_level_statement >= g_current_runtime_level) THEN
     	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Reverse charged tax : '||
                                                 to_char(l_charged_tax_amount));
     END IF;
     p_tax_amount := l_charged_tax_amount * -1;
  END IF;

  IF l_rule_code = 'GET_TX_SCH_TX_CODE' THEN
     p_calculated_tax_amount := p_tax_amount;
  END IF;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- New Tax Amount: '||p_tax_amount);
  END IF;

  l_rel_tax_line_amt_ctr := g_rel_tax_line_amounts.COUNT + 1;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Insert PLSQL rel tax line amounts table entry: '||
			      to_char(l_rel_tax_line_amt_ctr));
  END IF;

  g_rel_tax_line_amounts(l_rel_tax_line_amt_ctr).ApplPriorBase := p_base_amount;
  g_rel_tax_line_amounts(l_rel_tax_line_amt_ctr).ChargedTax := p_tax_amount;
  g_rel_tax_line_amounts(l_rel_tax_line_amt_ctr).CalcltdTax :=
					               p_calculated_tax_amount;
  g_rel_tax_line_amounts(l_rel_tax_line_amt_ctr).TaxCateg := p_tax_category_id;
  g_rel_tax_line_amounts(l_rel_tax_line_amt_ctr).GrpAttrName := l_grp_attr_name;
  g_rel_tax_line_amounts(l_rel_tax_line_amt_ctr).GrpAttrValue := l_grp_attr_val;

  IF l_grp_attr_name = 'DOCUMENT' THEN

     g_rel_trx_categ(p_tax_category_id).ExistFlag := 'Y';

  END IF;

  IF g_prev_cust_trx_line_number <> p_customer_trx_line_id AND
     g_prev_invoice_line_number <> p_customer_trx_line_id AND
     g_prev_invoice_line_number IS NOT NULL THEN

     g_prev_cust_trx_line_number := g_prev_invoice_line_number;
  END IF;

  g_prev_header_id := p_customer_trx_id;
  g_prev_invoice_line_number := p_customer_trx_line_id;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Last customer trx line number: '||
                                      to_char(g_prev_cust_trx_line_number));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Last invoice line number: ' ||
                                           to_char(g_prev_invoice_line_number));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- Last header id: '||to_char(g_prev_header_id));

        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- p_tax_amount(out): '||p_tax_amount);
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- p_tax_rate(out): '||p_tax_rate);
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_tax_amount: ' || '-- p_calculated_tax_amount(out): '||p_calculated_tax_amount);

  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','jl_zz_tax.calculate_tax_amount()-');



  END IF;

EXCEPTION
  WHEN ERROR_FROM_FUNCTION THEN
       FND_MESSAGE.SET_NAME('JL','JL_ZZ_AR_TX_INVALID_TAX_GROUP');
       p_latin_return_code := FND_MESSAGE.GET;
       ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
                     p_customer_trx_line_id;

       ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
                     'LINE';

       ZX_API_PUB.add_msg(
                      ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);


  WHEN OTHERS THEN
       err_num := SQLCODE;
       p_latin_return_code := SUBSTR(SQLERRM,1,100);

END calculate_tax_amount;

--========================================================================
-- PRIVATE PROCEDURE
--    calculate_latin_tax
--
-- DESCRIPTION
--    This routine calculates the tax amount for the transaction line or
--    sales order line that is recorded in the global structure
--    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec
--
-- PARAMETERS
--  p_tax_category_id
--  p_tax_rate
--  p_base_rate
--  p_base_amount (with NULL)
--
-- RETURNS
--  p_base_amount
--  o_aux_tax_amount
--  o_latin_return_code
--
-- CALLED FROM
--    jl_zz_tax.calculate
--
-- HISTORY
--    09-JAN-98  A.Chiromatzo   bug #608814 replaced the occurrences of
--                              extended_amount to entered_amount (tax_info_rec)
--
--========================================================================
PROCEDURE calculate_latin_tax (p_tax_category_id            IN     NUMBER,
                               p_rule_id                    IN     NUMBER,
                               p_group_tax_id               IN     NUMBER,
                               p_trx_date                   IN     DATE,
                               p_contributor_type           IN     VARCHAR2,
                               p_transaction_nature         IN     VARCHAR2,
                               p_establishment_type         IN     VARCHAR2,
                               p_trx_type_id                IN     NUMBER,
                               p_ship_to_site_use_id        IN     NUMBER,
                               p_bill_to_site_use_id        IN     NUMBER,
                               p_inventory_item_id          IN     NUMBER,
                               p_memo_line_id               IN     NUMBER,
                               p_ship_to_cust_id            IN     NUMBER,
                               p_bill_to_cust_id            IN     NUMBER,
                               p_application                IN     VARCHAR2,
                               p_ship_from_warehouse_id     IN     NUMBER,
                               p_fiscal_classification_code IN     VARCHAR2,
                               p_warehouse_location_id      IN     NUMBER,
                               p_transaction_nature_class   IN     VARCHAR2,
                               p_set_of_books_id            IN     NUMBER,
                               p_location_structure_id      IN     NUMBER,
                               p_location_segment_num       IN     VARCHAR2,
                               p_entered_amount             IN     NUMBER,
                               p_customer_trx_id            IN     NUMBER,
                               p_customer_trx_line_id       IN     NUMBER,
                               p_related_customer_trx_id    IN     NUMBER,
                               p_previous_customer_trx_id   IN     NUMBER,
                               p_contributor_class          IN     VARCHAR2,
                               p_organization_class         IN     VARCHAR2,
                               p_tax_rate                   IN OUT NOCOPY NUMBER,
                               p_base_rate                  IN     NUMBER,
                               p_base_amount                IN OUT NOCOPY NUMBER,
                               o_tax_amount                 IN OUT NOCOPY NUMBER,
                               o_latin_return_code          IN OUT NOCOPY VARCHAR,
                               p_calculated_tax_amount      IN OUT NOCOPY NUMBER,
                               p_exchange_rate              IN     NUMBER) IS

v_tributary_substitution    VARCHAR2(1);
v_aux_transaction_nature    VARCHAR2(30);
v_aux_establishment_type    VARCHAR2(30);
v_aux_contributor_type      VARCHAR2(30);
l_rule_id                   NUMBER;
l_rule_data_id              NUMBER;
l_tax_code                  VARCHAR(50);
v_aux_tax_code              VARCHAR(50);
v_aux_latin_return_code     VARCHAR2(30);
v_calculate_return_code     VARCHAR2(2000);
v_tax_category_to_reduce_id NUMBER;
v_aux_rule_id               NUMBER;
v_aux_rule_data_id          NUMBER;
v_aux_tax_rate              NUMBER;
v_aux_base_rate             NUMBER;
v_aux_base_amount           NUMBER;
v_aux_tax_amount            NUMBER := NULL;
v_aux_calculated_tax_amount NUMBER := NULL;
v_location_structure_id     NUMBER;
v_location_segment_num      NUMBER;
v_set_of_books_id           NUMBER;
err_num                     NUMBER;
err_msg                     NUMBER;
ERROR_FROM_FUNCTION         EXCEPTION;
ERROR_FROM_CAL_TAX_AMT      EXCEPTION;



BEGIN
     g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','jl_zz_tax.calculate_latin_tax()+');
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Tax category passed: '||to_char(p_tax_category_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Tax rate passed: '||to_char(p_tax_rate));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Rule Id: '||to_char(p_rule_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Tax base rate passed: '||to_char(p_base_rate));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Tax base amount passed: '||to_char(p_base_amount));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Tax amount passed: '||to_char(o_tax_amount));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Tax group passed: '||to_char(p_group_tax_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Transaction Type: '||to_char(p_trx_type_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Inventory Item Id: '||to_char(p_inventory_item_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Memo Line Id: '||to_char(p_memo_line_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Ship To Cust Id: '||to_char(p_ship_to_cust_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Bill To Cust Id: '||to_char(p_bill_to_cust_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Application: '||p_application);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Ship From Warehouse Id: '||
                                             to_char(p_ship_from_warehouse_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Fiscal Classification Code: '||
                                                  p_fiscal_classification_code);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Warehouse Location Id: '||
                                              to_char(p_warehouse_location_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Location Structure Id: '||
                                              to_char(p_location_structure_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Location Segment Number: '||p_location_segment_num);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Entered Amount: '||to_char(p_entered_amount));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Trx Nature: '|| p_transaction_nature);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Trx Nature Class: '||p_transaction_nature_class);
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-P- Trx date: '    ||to_char(p_trx_date,'DD-MM-YYYY'));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Rule Id: '     ||to_char(p_rule_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Ship to Site: '||to_char(p_ship_to_site_use_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Bill to site: '||to_char(p_bill_to_site_use_id) );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Establishment Type: '|| p_establishment_type);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Contributor Type: '|| p_contributor_type);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Customer Trx Id: '||to_char(p_customer_trx_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Customer Trx Line Id: '||to_char(p_customer_trx_line_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Related customer Trx Id: '||
                                            to_char(p_related_customer_trx_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Previous Customer Trx Id: '||
                                           to_char(p_previous_customer_trx_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Contributor Class: '||p_contributor_class);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Organization Class: '||p_organization_class);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Set Of Books Id: '||to_char(p_set_of_books_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Exchange Rate: '||to_char(p_exchange_rate));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-P- Calculated Tax Amount: '||
                                              to_char(p_calculated_tax_amount));
  END IF;

  -- Check if the tax code passed in the line is not a group
  IF p_group_tax_id IS NULL THEN
    -- get attributes from the Latin tax category to check
    -- tax_categ_to_reduce_id and Tributary Substitution
    -- Bugfix 1388703
    SELECT tc.tributary_substitution,
           tc.tax_categ_to_reduce_id,
           sp.location_structure_id,
           decode(ltrim(sp.global_attribute10, '0123456789'),
                    null, to_number(sp.global_attribute10), null),
           sp.set_of_books_id
    INTO   v_tributary_substitution,
           v_tax_category_to_reduce_id,
	   v_location_structure_id,
	   v_location_segment_num,
	   v_set_of_books_id
    FROM   jl_zz_ar_tx_categ tc,
           ar_system_parameters_all sp
    WHERE  tc.tax_category_id = p_tax_category_id
    AND    p_trx_date <= tc.end_date_active
    AND    p_trx_date >= NVL(tc.start_date_active, p_trx_date)
    AND    nvl(tc.org_id,-99) = nvl(sp.org_id,-99)
    AND    tc.org_id = zx_product_integration_pkg.sysinfo.sysparam.org_id;

  -- Tax code passed in the line is a group
  ELSE
    -- get attributes from the Latin tax group to check
    -- tax_category_to_reduce_id and Tributary Substitution
    -- Bugfix 1388703
    SELECT tg.tributary_substitution,
           tg.tax_category_to_reduce_id,
           sp.location_structure_id,
           decode(ltrim(sp.global_attribute10, '0123456789'),
                        null, to_number(sp.global_attribute10), null),
           sp.set_of_books_id
    INTO   v_tributary_substitution,
           v_tax_category_to_reduce_id,
	   v_location_structure_id,
	   v_location_segment_num,
	   v_set_of_books_id
    FROM   jl_zz_ar_tx_groups tg,
           ar_system_parameters_all sp
    WHERE  tg.tax_category_id    = p_tax_category_id
    AND    tg.group_tax_id       = p_group_tax_id
    AND    tg.contributor_type   = p_contributor_type
    AND    tg.transaction_nature = p_transaction_nature
    AND    tg.establishment_type = p_establishment_type
    AND    p_trx_date <= tg.end_date_active
    AND    p_trx_date >= NVL(tg.start_date_active, p_trx_date)
    AND    nvl(tg.org_id,-99) = nvl(sp.org_id,-99)
    AND     tg.org_id = zx_product_integration_pkg.sysinfo.sysparam.org_id;

  END IF;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-- Tributary Substitution: '|| v_tributary_substitution);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-- Auxiliary Set of Books Id: '||
            to_char(v_set_of_books_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-- Auxiliary Location Structure Id: '||
            to_char(v_location_structure_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-- Auxiliary Location Segment Number: '||
            to_char(v_location_segment_num));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-- Auxiliary tax category: '||
            to_char(v_tax_category_to_reduce_id));
  END IF;

  -- check need to calculate the auxiliary tax category before
  IF v_tax_category_to_reduce_id IS NOT NULL THEN

    v_aux_establishment_type := NULL;
    begin
      -- Bugfix 1388703
      select ac.tax_attribute_value
      into   v_aux_establishment_type
      from   jl_zz_ar_tx_att_cls ac
      where  ac.tax_attr_class_code = p_organization_class
      and    ac.tax_category_id = v_tax_category_to_reduce_id
      and    ac.tax_attribute_type = 'ORGANIZATION_ATTRIBUTE'
      and    ac.tax_attr_class_type = 'ORGANIZATION_CLASS'
      and    ac.enabled_flag = 'Y'
      and    exists (select 1
                     from   jl_zz_ar_tx_categ cat
                     where  cat.tax_category_id = ac.tax_category_id
      		     and    ac.tax_attribute_name = cat.org_tax_attribute
      		     and    p_trx_date <= cat.end_date_active
      		     and    p_trx_date >= NVL(cat.start_date_active, p_trx_date));
    exception
      when others then
           v_aux_establishment_type := NULL;
    end;

    IF (g_level_statement >= g_current_runtime_level) THEN
    	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-- Auxiliary establishment type: '||
                                                    v_aux_establishment_type);
    END IF;

    v_aux_transaction_nature := NULL;
    begin
      -- Bugfix 1388703
      select ac.tax_attribute_value
      into   v_aux_transaction_nature
      from   jl_zz_ar_tx_att_cls ac
      where  ac.tax_attr_class_code = p_transaction_nature_class
      and    ac.tax_category_id = v_tax_category_to_reduce_id
      and    ac.tax_attribute_type = 'TRANSACTION_ATTRIBUTE'
      and    ac.tax_attr_class_type = 'TRANSACTION_CLASS'
      and    ac.enabled_flag = 'Y'
      and    exists (select 1
                     from   jl_zz_ar_tx_categ cat
                     where  cat.tax_category_id = ac.tax_category_id
      		     and    ac.tax_attribute_name = cat.txn_tax_attribute
      		     and    p_trx_date <= cat.end_date_active
      		     and    p_trx_date >= NVL(cat.start_date_active, p_trx_date));
    exception
      when others then
           v_aux_transaction_nature := NULL;
    end;

    IF (g_level_statement >= g_current_runtime_level) THEN
    	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-- Auxiliary transaction nature: '||
                                                    v_aux_transaction_nature);
    END IF;

    v_aux_contributor_type := NULL;
    begin
      -- Bugfix 1388703

      -- Bugfix 1783986. Added if and else conditions
      IF NVL(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf4,'N') = 'Y' THEN
         select ac.tax_attribute_value
         into   v_aux_contributor_type
         from   jl_zz_ar_tx_cus_cls ac,
                hz_cust_site_uses su,
                jl_zz_ar_tx_categ cat
         where  ac.tax_attr_class_code = p_contributor_class
         and    ac.tax_category_id = v_tax_category_to_reduce_id
         and    ac.enabled_flag = 'Y'
         and    cat.tax_category_id = ac.tax_category_id
         and    ac.tax_attribute_name = cat.cus_tax_attribute
         and    su.cust_acct_site_id = ac.address_id
         and    su.site_use_id =
                    NVL(p_ship_to_site_use_id, p_bill_to_site_use_id)
         and    p_trx_date <= cat.end_date_active
         and    p_trx_date >= NVL(cat.start_date_active, p_trx_date);
      ELSE
         select ac.tax_attribute_value
         into   v_aux_contributor_type
         from   jl_zz_ar_tx_att_cls ac,
                jl_zz_ar_tx_categ cat
         where  ac.tax_attr_class_code = p_contributor_class
         and    ac.tax_category_id = v_tax_category_to_reduce_id
         and    ac.enabled_flag = 'Y'
         and    ac.tax_attr_class_type = 'CONTRIBUTOR_CLASS'
         and    cat.tax_category_id = ac.tax_category_id
         and    ac.tax_attribute_type = 'CONTRIBUTOR_ATTRIBUTE'
         and    ac.tax_attribute_name = cat.cus_tax_attribute
         and    p_trx_date <= cat.end_date_active
         and    p_trx_date >= NVL(cat.start_date_active, p_trx_date);
      END IF;

    exception
      when others then
           v_aux_contributor_type := NULL;
    end;

    IF (g_level_statement >= g_current_runtime_level) THEN
    	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-- Auxiliary contributor type: '||v_aux_contributor_type);
    END IF;

    -- get tax code, base rate, tax rate for the auxiliary tax category

    v_aux_rule_data_id := NULL;
    v_aux_rule_id := NULL;
    v_aux_tax_code := NULL;
  IF (g_level_statement >= g_current_runtime_level) then
     FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','Calling get_category_tax_rule');
  END If;

    get_category_tax_rule (v_tax_category_to_reduce_id,
            p_trx_type_id,
            p_ship_to_site_use_id,
            p_bill_to_site_use_id,
            p_inventory_item_id,
            p_group_tax_id,
            p_memo_line_id,
            p_ship_to_cust_id,
            p_bill_to_cust_id,
            p_trx_date,
            p_application,
            p_ship_from_warehouse_id,
            'RATE',
            p_fiscal_classification_code,
            p_ship_from_warehouse_id,
            v_location_structure_id,
            v_location_segment_num,
            v_set_of_books_id,
            v_aux_transaction_nature,
            p_base_amount,
            v_aux_establishment_type,
            v_aux_contributor_type,
            p_warehouse_location_id,
            p_transaction_nature_class,
            v_aux_tax_code,
            v_aux_base_rate,
            v_aux_rule_data_id,
            v_aux_rule_id);

    IF v_aux_tax_code IS NULL THEN
       v_aux_tax_code := 'NO_VALID_TAX_CODE';
       RAISE ERROR_FROM_FUNCTION;
    ELSE
       SELECT vt.tax_rate
       INTO   v_aux_tax_rate
       FROM   ar_vat_tax vt
       WHERE  vt.tax_code = v_aux_tax_code
       AND    vt.set_of_books_id = v_set_of_books_id
       AND    vt.start_date <= trunc(p_trx_date)
       AND    nvl(vt.end_date, trunc(p_trx_date)) >= trunc(p_trx_date)
       AND    nvl(vt.enabled_flag,'Y') = 'Y'
       AND    nvl(vt.tax_class,'O') = 'O';
    END IF;

    IF (g_level_statement >= g_current_runtime_level) THEN
    	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-- Auxiliary tax code: '||v_aux_tax_code);
    	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-- Auxiliary rule id: '||to_char(v_aux_rule_id));
    	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-- Auxiliary tax rate: '||to_char(v_aux_tax_rate));
    END IF;

    v_aux_base_rate := NULL;

    IF (g_level_statement >= g_current_runtime_level) then
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','Calling get_category_tax_rule for v_tax_category_to_reduce_id:'
                 ||v_tax_category_to_reduce_id);
    END IF;
    get_category_tax_rule (v_tax_category_to_reduce_id,
            p_trx_type_id,
            p_ship_to_site_use_id,
            p_bill_to_site_use_id,
            p_inventory_item_id,
            p_group_tax_id,
            p_memo_line_id,
            p_ship_to_cust_id,
            p_bill_to_cust_id,
            p_trx_date,
            p_application,
            p_ship_from_warehouse_id,
            'BASE',
            p_fiscal_classification_code,
            p_ship_from_warehouse_id,
            v_location_structure_id,
            v_location_segment_num,
            v_set_of_books_id,
            v_aux_transaction_nature,
            p_base_amount,
            v_aux_establishment_type,
            v_aux_contributor_type,
            p_warehouse_location_id,
            p_transaction_nature_class,
            l_tax_code,
            v_aux_base_rate,
            l_rule_data_id,
            l_rule_id);

    IF l_tax_code IS NULL THEN
      RAISE ERROR_FROM_FUNCTION;
    end if;

    IF (g_level_statement >= g_current_runtime_level) THEN
    	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-- Auxiliary base rate: '||to_char(v_aux_base_rate));
    END IF;

    -- calculate the auxiliary tax category
    calculate_latin_tax (v_tax_category_to_reduce_id,
                         v_aux_rule_id,
                         p_group_tax_id,
                         p_trx_date,
                         v_aux_contributor_type,
                         v_aux_transaction_nature,
                         v_aux_establishment_type,
                         p_trx_type_id,
                         p_ship_to_site_use_id,
                         p_bill_to_site_use_id,
                         p_inventory_item_id,
                         p_memo_line_id,
                         p_ship_to_cust_id,
                         p_bill_to_cust_id,
                         p_application,
                         p_ship_from_warehouse_id,
                         p_fiscal_classification_code,
                         p_warehouse_location_id,
                         p_transaction_nature_class,
                         p_set_of_books_id,
                         p_location_structure_id,
                         p_location_segment_num,
                         p_entered_amount,
                         p_customer_trx_id,
                         p_customer_trx_line_id,
                         p_related_customer_trx_id,
                         p_previous_customer_trx_id,
                         p_contributor_class,
                         p_organization_class,
                         v_aux_tax_rate,
                         v_aux_base_rate,
                         v_aux_base_amount,
                         v_aux_tax_amount,
                         v_aux_latin_return_code,
                         v_aux_calculated_tax_amount,
                         p_exchange_rate);

    IF v_aux_latin_return_code  <> ZX_PRODUCT_INTEGRATION_PKG.TAX_SUCCESS THEN
      RAISE ERROR_FROM_FUNCTION;
    END IF;

    -- add the tax amount to the base amount if needed
    IF v_tributary_substitution = 'N' THEN
      p_base_amount := v_aux_tax_amount;
    ELSE
      -- base amount used in the tax category to compound base
      p_base_amount := v_aux_base_amount - p_entered_amount;
    END IF;

    p_calculated_tax_amount := v_aux_calculated_tax_amount;

    IF (g_level_statement >= g_current_runtime_level) THEN
    	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-- Auxiliary tributary substitution: '||
            v_tributary_substitution);
    	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-- Auxiliary base amount: '||to_char(p_base_amount));
    END IF;

  END IF; -- end of steps for the auxiliary tax category

  -- get base amount
  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-- Base amount before apply base rate: '||
                  to_char(p_base_amount));
  END IF;

  -- CR 3571797. Assign Unrounded Taxable Amount in tax_info_rec for E-Business Tax
  -- requirement on LTE Tax Lines to simplify migration process of LTE.
  ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.unrounded_taxable_amt := (nvl(p_base_amount,0) + p_entered_amount)
                                                     * (1 + (nvl(p_base_rate,0)/100));

  p_base_amount := ZX_PRODUCT_INTEGRATION_PKG.tax_curr_round (
                        (nvl(p_base_amount,0) + p_entered_amount)
 		            * (1 + (nvl(p_base_rate,0)/100)),
                        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.trx_currency_code,
                        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.precision,
                        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.minimum_accountable_unit,
                        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_rounding_rule,
                        'Y');

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-- Base amount after apply base rate (rounded): '||
                  to_char(p_base_amount));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-- Call calculate_tax_amount - Regular');
  END IF;
  -- get tax amount
  calculate_tax_amount (p_transaction_nature,
                        p_transaction_nature_class,
                        p_organization_class,
                        p_base_amount,
                        p_group_tax_id,
                        p_tax_category_id,
                        p_trx_date,
                        p_rule_id,
                        p_ship_to_site_use_id,
                        p_bill_to_site_use_id,
                        p_establishment_type,
                        p_contributor_type,
                        p_customer_trx_id,
                        p_customer_trx_line_id,
                        p_related_customer_trx_id,
                        p_previous_customer_trx_id,
                        p_warehouse_location_id,
                        p_contributor_class,
                        p_set_of_books_id,
                        v_calculate_return_code,
                        o_tax_amount,
                        p_tax_rate,
                        p_calculated_tax_amount,
                        p_exchange_rate);

  IF v_calculate_return_code <> 'SUCCESS' THEN
     RAISE ERROR_FROM_CAL_TAX_AMT;
  END IF;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-- After call calculate_tax_amount'||
                           'o_tax_amount = '||o_tax_amount);
  END IF;

  -- get reduced tax amount for tributary substitution
  IF v_tributary_substitution = 'Y' THEN
    o_tax_amount := o_tax_amount - v_aux_tax_amount;
    IF (g_level_statement >= g_current_runtime_level) THEN
    	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || '-- Tax category tributary substitution tax amount: '||
            to_char(o_tax_amount));
    END IF;
  END IF;

  -- return success
  o_latin_return_code := ZX_PRODUCT_INTEGRATION_PKG.TAX_SUCCESS;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','jl_zz_tax.calculate_latin_tax()-');
  END IF;

EXCEPTION
  WHEN ERROR_FROM_CAL_TAX_AMT THEN
       IF (g_level_statement >= g_current_runtime_level) THEN
       	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || 'EXCEPTION(ERROR_FROM_FUNCTION): '||
             'jl_zz_tax.calculate_latin_tax ' ||v_calculate_return_code);
       END IF;
       fnd_message.set_name('AR', 'GENERIC_MESSAGE');
       fnd_message.set_token('GENERIC_TEXT',
          'EXCEPTION(ERROR_FROM_FUNCTION): jl_zz_tax.calculate_latin_tax '||
          v_calculate_return_code);
       o_latin_return_code := ZX_PRODUCT_INTEGRATION_PKG.TAX_RC_OERR;
       ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
                     p_customer_trx_line_id;

       ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
                     'LINE';

       ZX_API_PUB.add_msg(
                      ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);



  WHEN ERROR_FROM_FUNCTION THEN
       fnd_message.set_name('AR', 'GENERIC_MESSAGE');
       fnd_message.set_token('GENERIC_TEXT',
          'EXCEPTION(ERROR_FROM_FUNCTION): jl_zz_tax.calculate_latin_tax');
       o_latin_return_code := ZX_PRODUCT_INTEGRATION_PKG.TAX_RC_OERR;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
                     p_customer_trx_line_id;

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
                     'LINE';

        ZX_API_PUB.add_msg(
                      ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

       IF (g_level_statement >= g_current_runtime_level) THEN
       	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || 'EXCEPTION(ERROR_FROM_FUNCTION): '||
                 'jl_zz_tax.calculate_latin_tax');
       END IF;

  WHEN NO_DATA_FOUND THEN
       fnd_message.set_name('AR', 'GENERIC_MESSAGE');
       fnd_message.set_token('GENERIC_TEXT',
          'EXCEPTION(NO_DATA_FOUND): jl_zz_tax.calculate_latin_tax');
       o_latin_return_code := ZX_PRODUCT_INTEGRATION_PKG.TAX_RC_OERR;
       IF (g_level_statement >= g_current_runtime_level) THEN
       	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || 'EXCEPTION(NO_DATA_FOUND): '||
          'jl_zz_tax.calculate_latin_tax');
       END IF;

  WHEN TOO_MANY_ROWS THEN
       fnd_message.set_name('AR', 'GENERIC_MESSAGE');
       fnd_message.set_token('GENERIC_TEXT',
          'EXCEPTION(TOO_MANY_ROWS): jl_zz_tax.calculate_latin_tax');
       o_latin_return_code := ZX_PRODUCT_INTEGRATION_PKG.TAX_RC_OERR;
       IF (g_level_statement >= g_current_runtime_level) THEN
       	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','calculate_latin_tax: ' || 'EXCEPTION(TOO_MANY_ROWS): '||
          'jl_zz_tax.calculate_latin_tax');
       END IF;

  WHEN OTHERS THEN
       err_num := SQLCODE;
       err_msg := SUBSTR(SQLERRM,1,100);
       fnd_message.set_name('AR', 'GENERIC_MESSAGE');
       fnd_message.set_token('GENERIC_TEXT',
                 'EXCEPTION(OTHERS): jl_zz_tax.calculate_latin_tax '||
                  to_char(err_num)||' '||err_msg);
       o_latin_return_code := ZX_PRODUCT_INTEGRATION_PKG.TAX_RC_OERR;
       IF (g_level_statement >= g_current_runtime_level) THEN
       	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','EXCEPTION(OTHERS): jl_zz_tax.calculate_latin_tax '||
                    to_char(err_num)||' '||err_msg);
       END IF;

END calculate_latin_tax;


--========================================================================
-- PUBLIC FUNCTION
--    calculate
--
-- DESCRIPTION
--    This routine calculates the tax amount for the transaction line or
--    sales order line that is recorded in the global structure
--    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec
--
-- PARAMETERS
--    tax_info_rec
--
-- RETURNS
--    tax_info_rec updated with tax_rate, amount, global_attributes and
--    other information
--
-- CALLED FROM
--    ZX_PRODUCT_INTEGRATION_PKG.calculate
--
-- HISTORY
--    02-OCT-97  A. Chiromatzo  Return values for global flexfield just
--              for AR
--    09-SEP-97  A. Chiromatzo  in calculate function, first check
--          if ZX_PRODUCT_INTEGRATION_PKG.TAX_INFO_REC.TAX_AMOUNT is not null, if
--          it's not null then does not perform anything as it
--          does not use the audit trail, avoiding error
--          during delete
--    20-NOV-97  A.Chiromatzo   debug messages
--    22-APR-98  I. William     bug #660025 reset the value of global_attribute8
--                              and global_attribute9 to null in the beginning
--                              of the calculate_latin_tax procedure. Also,
--                              for base amount reduction, <= 0 condition
--                              replaced with < 0.
--    08-FEB-99  H. Takle       Used ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern7 to determine
--                              the calling view name. Changed for bug number
--                              807588. Following is the mapping for usern7.
--                                   1  TAX_LINES_DELETE_VBR
--                                   2  TAX_LINES_CREATE_VBR
--                                   3  TAX_LINES_INVOICE_IMPORT_VBR
--                                   4  TAX_LINES_RECURR_INVOICE_VBR
--                                   5  TAX_ADJUSTMENTS_VBR
--                                   6  SO_TAX_LINES_CREDIT_CHECK_VBR
--                                   7  SO_TAX_LINES_SUMMARY_VBR
--                                   8  TAX_LINES_RMA_IMPORT_VBR
--========================================================================

  --Bug fix 2367111
  FUNCTION calculate
       (p_org_id IN NUMBER) RETURN VARCHAR2 IS

    err_num                    NUMBER;
    err_msg                    NUMBER;
    v_rule_id                  NUMBER;
    v_tax_amount               NUMBER;
    v_base_amount              NUMBER      := NULL;
    v_calculated_tax_amount    NUMBER      := NULL;
    l_vat_tax_id               NUMBER;
    v_use_legal_message        VARCHAR2(1);
    l_application              VARCHAR2(2);
    v_latin_tax_return_code    VARCHAR2(30);
    l_organization_class       VARCHAR2(30);
    v_legal_message_exception  VARCHAR2(30);
    l_legal_message8           VARCHAR2(150);
    l_legal_message9           VARCHAR2(150);
    l_exchange_rate            NUMBER;
    ERROR_FROM_FUNCTION        EXCEPTION;
    l_org_id                   NUMBER;
    l_country_code             varchar2(2);

    -- bug#6834705
    l_trx_type_id              RA_CUSTOMER_TRX_ALL.CUST_TRX_TYPE_ID%TYPE;
    l_cust_trx_type_id         RA_CUSTOMER_TRX_ALL.CUST_TRX_TYPE_ID%TYPE;


    CURSOR get_orig_trx_type_id_c
    (c_org_id                  RA_CUSTOMER_TRX_ALL.org_id%TYPE,
     c_customer_trx_id         RA_CUSTOMER_TRX_ALL.customer_trx_id%TYPE)
    IS
    SELECT  cust_trx_type_id
      FROM  RA_CUSTOMER_TRX_ALL
      WHERE org_id = c_org_id
        AND customer_trx_id = c_customer_trx_id ;

BEGIN
    v_use_legal_message := 'N';

     g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    IF p_org_id IS NULL THEN
      l_org_id := TO_NUMBER(FND_PROFILE.VALUE('ORG_ID'));
    ELSE
      l_org_id := p_org_id;
    END IF;

    IF (g_level_statement >= g_current_runtime_level) THEN
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','jl_zz_tax.calculate()+');
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-P- Tax category tax amount: '||
                  to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_amount));
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-P- Tax category tax code: '||ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_code);
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-P- Tax category tax rate: '||ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_rate);
    END IF;

    v_latin_tax_return_code := ZX_PRODUCT_INTEGRATION_PKG.TAX_SUCCESS;

    -- Following code added for the bug number 1019748++

    IF ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern7 IN (1,2,3,4,5,8) THEN
      l_application := 'AR';
    ELSIF ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern7 IN (6,7) THEN
      l_application := 'OE';
    END IF;

    -- Above code added for the bug number 1019748--
    IF (g_level_statement >= g_current_runtime_level) THEN
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- Application: '||l_application);
    END IF;
    -- Following code added for the bug number 807588++

    IF ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern7 = 1 THEN
      -- Set following variable to populate_plsql_tables to execute before
      -- the first tax line processing
      g_prev_invoice_line_number := NULL;
    END IF;

    -- Above code added for the bug number 807588--

    -- bug#6834705
    -- if the invoice is credit memo, need to get
    -- cust_trx_type_id from the original invoice
    -- in order to get the correct rule defined from
    -- jl_zz_ar_tx_rules table
    --

    IF ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.credit_memo_flag = TRUE THEN
      OPEN get_orig_trx_type_id_c
      (l_org_id,
       ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.previous_customer_trx_id);
      FETCH get_orig_trx_type_id_c INTO l_cust_trx_type_id;
      CLOSE get_orig_trx_type_id_c;

      l_trx_type_id := l_cust_trx_type_id;
    ELSE
      -- not credit memo
      l_trx_type_id :=  ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.trx_type_id;
    END IF;


    -- The view did not get the default tax code
    IF ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_code IS NULL THEN
      -- Raise the message populated in get_category_tax_code
      v_latin_tax_return_code := ZX_PRODUCT_INTEGRATION_PKG.TAX_RC_OERR;

    ELSIF ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_amount IS NULL THEN
      SELECT NVL(vt.amount_includes_tax_flag,'N'),
             sp.global_attribute14,
             vt.global_attribute3,
             decode(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.trx_currency_code,
                           ZX_PRODUCT_INTEGRATION_PKG.sysinfo.base_currency_code, 1,
                           decode(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.trx_exchange_rate,
                                    NULL, 1,
                                    0, 1,
                                    ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.trx_exchange_rate))
      INTO ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.amount_includes_tax_flag,
           v_use_legal_message,
           v_legal_message_exception,
           l_exchange_rate
      FROM   ar_vat_tax  vt,
            ar_system_parameters_all sp
      WHERE  vt.vat_tax_id = ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.vat_tax_id
        AND  nvl(vt.org_id,-99) = nvl(sp.org_id,-99);

      --BugFix 2180174 commented the Following IF condition.
      /*
      IF ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern2 IS NULL AND
         ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.amount_includes_tax_flag <> 'N' THEN
        IF (g_level_statement >= g_current_runtime_level) THEN
          FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- Amount Includes flag should be N');
        END IF;
        fnd_message.set_name('AR', 'GENERIC_MESSAGE');
        fnd_message.set_token('GENERIC_TEXT',
                             'Amount Includes flag should be N');
        app_exception.raise_exception;
      END IF;
      */
      IF (g_level_statement >= g_current_runtime_level) THEN

        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- Use Legal Message: '||v_use_legal_message);
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- Exchange Rate: '||to_char(l_exchange_rate));
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- Amount Includes tax flag: '||
                                 ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.amount_includes_tax_flag);
      END IF;

      SELECT NVL(global_attribute1,'DEFAULT')
      INTO   l_organization_class
      FROM   hr_locations_all
      where  location_id = ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern4;

      IF (g_level_statement >= g_current_runtime_level) THEN
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- Organization Class: '||l_organization_class);
      END IF;


      IF ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern2 is NOT NULL THEN
        IF (g_level_statement >= g_current_runtime_level) THEN

          FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- Trx Type Id: '||
                                     to_char(l_trx_type_id));
          FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- Tax Category Id: '||
                                     to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern1));
          FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- Contributor Type: '||ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf8);
        END IF;

        l_legal_message8 := NULL;
        l_legal_message9 := NULL;
        IF ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern3 IS NULL THEN
           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern3 :=
              JL_ZZ_TAX.GET_TAX_BASE_RATE (
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern1,
                   l_trx_type_id,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.ship_to_site_use_id,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.bill_to_site_use_id,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.inventory_item_id,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern2,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.memo_line_id,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.ship_to_cust_id,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.bill_to_cust_id,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.trx_date,
                   l_application,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.ship_from_warehouse_id,
                   'BASE',
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf2,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.ship_from_warehouse_id,
                   ZX_PRODUCT_INTEGRATION_PKG.sysinfo.sysparam.location_structure_id,
                   ZX_PRODUCT_INTEGRATION_PKG.sysinfo.sysparam.global_attribute10,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf3,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf5,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf8,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern4,
                   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf9 );
        END IF;

        IF (g_level_statement >= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- Base Rate: '
                        || to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern3));
        END IF;

        get_rule_legal_message (ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern1,
                         --ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.trx_type_id,
                         l_trx_type_id,
                         ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.ship_to_site_use_id,
                         ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.bill_to_site_use_id,
                         ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.inventory_item_id,
                         ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern2,
                         ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.memo_line_id,
                         ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.ship_to_cust_id,
                         ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.bill_to_cust_id,
                         ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.trx_date,
                         l_application,
                         ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.ship_from_warehouse_id,
                         ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf2,
                         ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.ship_from_warehouse_id,
                         ZX_PRODUCT_INTEGRATION_PKG.sysinfo.sysparam.location_structure_id,
                         to_number(ZX_PRODUCT_INTEGRATION_PKG.sysinfo.sysparam.global_attribute10),
                         ZX_PRODUCT_INTEGRATION_PKG.sysinfo.sysparam.set_of_books_id,
                         ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf3,
                         ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.entered_amount *
                             (1 + (nvl(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern3,0)/100)),
                         ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf5,
                         ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf8,
                         ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern4,
                         ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf9,
                         v_use_legal_message,
                         ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern3,
                         v_legal_message_exception,
                         v_rule_id,
                         l_legal_message8,
                         l_legal_message9);

        IF (g_level_statement >= g_current_runtime_level) THEN
          FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- Rule Id: '|| to_char(v_rule_id));
          FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- Legal Message 1: '|| l_legal_message8);
          FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- Legal Message 2: '|| l_legal_message9);
        END IF;

        IF l_legal_message8 = 'ERROR' OR l_legal_message9 = 'ERROR' THEN
           JL_ZZ_TAX_INTEGRATION_PKG.g_jl_exception_type := 'E';
           RETURN(ZX_PRODUCT_INTEGRATION_PKG.TAX_RC_OERR);
        ELSE
           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.global_attribute8 := l_legal_message8;
           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.global_attribute9 := l_legal_message9;
        END IF;
      END IF;


      calculate_latin_tax (ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern1,
                           v_rule_id,
                           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern2,
                           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.trx_date,
                           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf8,
                           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf3,
                           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf5,
                           l_trx_type_id, --ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.trx_type_id,
                           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.ship_to_site_use_id,
                           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.bill_to_site_use_id,
                           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.inventory_item_id,
                           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.memo_line_id,
                           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.ship_to_cust_id,
                           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.bill_to_cust_id,
                           l_application,
                           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.ship_from_warehouse_id,
                           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf2,
                           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern4,
                           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf9,
                           ZX_PRODUCT_INTEGRATION_PKG.sysinfo.sysparam.set_of_books_id,
                           ZX_PRODUCT_INTEGRATION_PKG.sysinfo.sysparam.location_structure_id,
                           ZX_PRODUCT_INTEGRATION_PKG.sysinfo.sysparam.global_attribute10,
                           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.entered_amount,
                           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.customer_trx_id,
                           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.customer_trx_line_id,
                           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern5,
                           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.previous_customer_trx_id,
                           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf6,
                           l_organization_class,
                           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_rate,
                           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern3,
                           v_base_amount,
                           v_tax_amount,
                           v_latin_tax_return_code,
                           v_calculated_tax_amount,
                           l_exchange_rate);

      IF v_latin_tax_return_code <> ZX_PRODUCT_INTEGRATION_PKG.TAX_SUCCESS THEN
        RAISE ERROR_FROM_FUNCTION;
      END IF;

      IF (g_level_statement >= g_current_runtime_level) THEN
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- Base amount (rounded): ' || to_char(v_base_amount));
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- Tax amount: '|| to_char(v_tax_amount));
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- Calculated Tax amount: '||
                                              to_char(v_calculated_tax_amount));
      END IF;

      -- CR 3571797. Assign Unrounded Tax Amount to tax_info_rec for E-Business Tax
      -- requirement on LTE Tax Lines to simplify migration process of LTE.
      ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.unrounded_tax_amt     := v_tax_amount;

      -- associate values in tax_info_rec and in global_attributes
      -- original rounding procedure
      ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_amount := ZX_PRODUCT_INTEGRATION_PKG.tax_curr_round
			   (v_tax_amount,
			   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.trx_currency_code,
			   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.precision,
			   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.minimum_accountable_unit,
			   ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_rounding_rule,
                           'Y');

      IF (g_level_statement >= g_current_runtime_level) THEN
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- Tax category tax amount after rounding: '||
                           to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_amount));
      END IF;
      -- set the global flexfield context according to product 'AR'
      IF l_application = 'AR' THEN
        l_country_code := JG_ZZ_SHARED_PKG.GET_COUNTRY(l_org_id, null);

        IF (g_level_statement >= g_current_runtime_level) THEN
              FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- l_country_code: '||l_country_code);
        END IF;

        IF l_country_code = 'BR' THEN              --Bug 2367111
          --IF fnd_profile.value_wnps('JGZZ_COUNTRY_CODE') = 'BR' THEN
          ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.global_attribute_category :=
               'JL.BR.ARXTWMAI.Additional Info';
        ELSIF l_country_code IN ('AR','CO') THEN    --Bug 2367111
        --ELSIF fnd_profile.value_wnps('JGZZ_COUNTRY_CODE') IN ('AR','CO') THEN
          ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.global_attribute_category :=
             'J'||'L.'||JG_ZZ_SHARED_PKG.GET_COUNTRY(l_org_id, null)||                --Bug 2367111
             --'J'||'L.'||fnd_profile.value_wnps('JGZZ_COUNTRY_CODE')||
               '.ARXTWMAI.LINES';
        END IF;

        -- set the default global attributes for the tax lines
        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.global_attribute2  := ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf2;
        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.global_attribute3  := ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.userf9;

        -- Bugfix 1062149 fnd_number.number_to_canonical added in following lines
        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.global_attribute11 :=
                fnd_number.number_to_canonical (v_base_amount);
        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.global_attribute12 :=
                fnd_number.number_to_canonical(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern3);

        -- Added following 2 lines to take care of bug# 660025
        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.global_attribute8 := null;
        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.global_attribute9 := null;
        -- Bugfix 1062149 fnd_number.number_to_canonical added in following lines
        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.global_attribute19 :=
                fnd_number.number_to_canonical(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_amount);
        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.global_attribute20 :=
                fnd_number.number_to_canonical( v_calculated_tax_amount);

        -- Added following 1 line to take care of bug# 787259
        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.taxable_amount := v_base_amount;
      END IF;

    END IF;

    -- Following code added for Bug Number 803394++

    IF ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern5 IS NOT NULL THEN
      l_vat_tax_id := NULL;
      BEGIN
        SELECT vat_tax_id
        INTO   l_vat_tax_id
        FROM   ar_vat_tax
        WHERE  tax_code = ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_code
        AND    set_of_books_id = ZX_PRODUCT_INTEGRATION_PKG.sysinfo.sysparam.set_of_books_id
        AND    tax_type = 'VAT'
        AND    to_date(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern6,'YYYYMMDD') >= start_date
        AND    to_date(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern6,'YYYYMMDD') <=
                  nvl(end_date,to_date(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern6,'YYYYMMDD'))
        AND    nvl(enabled_flag,'Y') = 'Y'
        AND    nvl(tax_class,'O') = 'O';
      EXCEPTION
        WHEN OTHERS THEN
          l_vat_tax_id := NULL;
      END;
      IF (g_level_statement >= g_current_runtime_level) THEN
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- Original Vat Tax Id '||
                                      to_char(ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.vat_tax_id));
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- New Vat Tax Id '||to_char(l_vat_tax_id));
      END IF;
        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.vat_tax_id :=
                              NVL(l_vat_tax_id,ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.vat_tax_id);
    END IF;

  -- 11.6 Bug 3571797. Following code would populate missing columns of Tax Lines
  -- that are required for E-Business Tax solution and simplifies migration of LTE
  -- tax lines.
  --IF ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_regime_code IS NULL THEN

      IF (g_level_statement >= g_current_runtime_level) THEN
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- populating tix information for tax_regime_code: '||
                                      ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_regime_code);
      END IF;

     BEGIN
       SELECT rate.tax_rate_id,
              rate.tax_rate_code,
              regime.tax_regime_id,
              regime.tax_regime_code,
              tax.tax_id,
              tax.tax,
              status.tax_status_id,
              status.tax_status_code
         INTO ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_rate_id,
              ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_rate_code,
              ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_regime_id,
              ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_regime_code,
              ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_id,
              ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax,
              ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_status_id,
              ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_status_code
         FROM zx_rates_b rate,
              zx_regimes_b regime,
              zx_taxes_b tax,
              zx_status_b status
        WHERE rate.tax_rate_id = ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.vat_tax_id
          and rate.tax_regime_code = regime.tax_regime_code
          and rate.tax = tax.tax
          and tax.tax_regime_code = rate.tax_regime_code
          and tax.content_owner_id = rate.content_owner_id
          and rate.tax_status_code = status.tax_status_code
          and status.tax_regime_code = rate.tax_regime_code
          and status.tax = rate.tax
          and status.content_owner_id = rate.content_owner_id;

       IF (g_level_statement >= g_current_runtime_level) THEN
          FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- EBTAX- Tax Rate Code: ' ||
                             ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_rate_code);
          FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- EBTAX- Tax Regime Code: ' ||
                             ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_regime_code);
          FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- EBTAX- Tax: ' ||
                             ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax);
          FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','-- EBTAX- Tax Status: ' ||
                             ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_status_code);
       END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN

              SELECT  rate.tax_rate_id,
                      rate.tax_rate_code,
                      rate.tax_regime_code,
                      rate.tax,
                      rate.tax_status_code
                 INTO ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_rate_id,
                      ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_rate_code,
                      ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_regime_code,
                      ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax,
                      ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_status_code
                 FROM zx_rates_b rate
                WHERE rate.tax_rate_id = ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.vat_tax_id;

        WHEN OTHERS THEN
          IF (g_level_statement >= g_current_runtime_level) THEN
            FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','EXCEPTION(EBTAX): jl_zz_tax.calculate '||
                                            SQLCODE||' '||SQLERRM);
          END IF;

      END;
    --END IF;  -- End Bug 3571797

    -- Populate the eBTax related columns here:
	ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.legal_justification_text1 :=
                           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.GLOBAL_ATTRIBUTE8;
	ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.legal_justification_text2 :=
                           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.GLOBAL_ATTRIBUTE9;
	ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.legal_justification_text3 :=
                           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.GLOBAL_ATTRIBUTE10;
	ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_base_modifier_rate :=
	               ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.usern3;
                  -- same as  ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.GLOBAL_ATTRIBUTE12;
	ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.cal_tax_amt := v_calculated_tax_amount;
                  -- Same as ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.GLOBAL_ATTRIBUTE20;
        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.unrounded_taxable_amt :=
                           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.taxable_Amount;
        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_date :=
                           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.trx_date;
        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_determine_date :=
                           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.trx_date;
        ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.tax_point_date :=
                           ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.trx_date;

    -- Code added for Bug Number 803394--

    IF (g_level_statement >= g_current_runtime_level) THEN
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','jl_zz_tax.calculate()-');
    END IF;
    RETURN (v_latin_tax_return_code);

  EXCEPTION
    WHEN ERROR_FROM_FUNCTION THEN
      fnd_message.set_name('AR', 'GENERIC_MESSAGE');
      fnd_message.set_token('GENERIC_TEXT',
                            'EXCEPTION(ERROR_FROM_FUNCTION): jl_zz_tax.calculate');
      IF (g_level_unexpected >= g_current_runtime_level) THEN
        FND_LOG.STRING(g_level_unexpected,'ZX.PLSQL.JL_ZZ_TAX','EXCEPTION(ERROR_FROM_FUNCTION): jl_zz_tax.calculate');
      END IF;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
                     ZX_PRODUCT_INTEGRATION_PKG.tax_info_rec.customer_trx_line_id;

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
                     'LINE';

      ZX_API_PUB.add_msg(
                      ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);


      RETURN (ZX_PRODUCT_INTEGRATION_PKG.TAX_RC_OERR);

    WHEN NO_DATA_FOUND THEN
      fnd_message.set_name('AR', 'GENERIC_MESSAGE');
      fnd_message.set_token('GENERIC_TEXT',
                            'EXCEPTION(NO_DATA_FOUND): jl_zz_tax.calculate');
      IF (g_level_unexpected >= g_current_runtime_level) THEN
        FND_LOG.STRING(g_level_unexpected,'ZX.PLSQL.JL_ZZ_TAX','EXCEPTION(NO_DATA_FOUND): jl_zz_tax.calculate');
      END IF;
      RETURN (ZX_PRODUCT_INTEGRATION_PKG.TAX_RC_OERR);

    WHEN TOO_MANY_ROWS THEN
      fnd_message.set_name('AR', 'GENERIC_MESSAGE');
      fnd_message.set_token('GENERIC_TEXT',
                            'EXCEPTION(TOO_MANY_ROWS): jl_zz_tax.calculate');
      IF (g_level_unexpected >= g_current_runtime_level) THEN
        FND_LOG.STRING(g_level_unexpected,'ZX.PLSQL.JL_ZZ_TAX','EXCEPTION(TOO_MANY_ROWS): jl_zz_tax.calculate');
      END IF;
      RETURN (ZX_PRODUCT_INTEGRATION_PKG.TAX_RC_OERR);

    WHEN OTHERS THEN
      err_num := SQLCODE;
      err_msg := SUBSTR(SQLERRM,1,100);
      fnd_message.set_name('AR', 'GENERIC_MESSAGE');
      fnd_message.set_token('GENERIC_TEXT',
                            'EXCEPTION(OTHERS): jl_zz_tax.calculate '||
                            to_char(err_num)||' '
                            ||err_msg);
      IF (g_level_unexpected >= g_current_runtime_level) THEN
        FND_LOG.STRING(g_level_unexpected,'ZX.PLSQL.JL_ZZ_TAX','EXCEPTION(OTHERS): jl_zz_tax.calculate '||
                       SQLCODE||' ; '||SQLERRM);
      END IF;
      RETURN (ZX_PRODUCT_INTEGRATION_PKG.TAX_RC_OERR);

  END calculate;

FUNCTION get_legal_message (
             p_rule_id                    IN NUMBER,
             p_rule_data_id               IN NUMBER,
             p_legal_message_exception    IN VARCHAR2,
             p_ship_from_warehouse_id     IN NUMBER)
RETURN VARCHAR2 IS

v_message_text          VARCHAR2(150) := NULL;
v_rule                  jl_zz_ar_tx_rules.rule%type;



BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','jl_zz_tax.get_legal_message()+');
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_legal_message: ' || '-P- Rule Id: '||to_char(p_rule_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_legal_message: ' || '-P- Rule Data Id: '||to_char(p_rule_data_id));
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_legal_message: ' || '-P- Exception Code: '||p_legal_message_exception);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_legal_message: ' || '-P- Ship from warehouse Id: '||
                                             to_char(p_ship_from_warehouse_id));
  END IF;

  SELECT r.rule
  INTO   v_rule
  FROM   jl_zz_ar_tx_rules r
  WHERE  r.rule_id = p_rule_id;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_legal_message: ' || '-- Rule Code: '||v_rule);
  END IF;

  IF v_rule IN ('GET_ITEM_TX_CODE',         'GET_MEMO_LINE_TX_CODE',
                'GET_CUSTOMER_TX_CODE',     'GET_BILL_TO_TX_CODE',
                'GET_SHIP_TO_TX_CODE',      'GET_ORGANIZATION_TX_CODE',
                'GET_FISC_CLAS_TX_CODE',    'GET_LOCATION_TX_CODE',
                'GET_CUST_EXC_TX_CODE',     'GET_TRX_NATURE_TX_CODE',
                'GET_LATIN_TX_GRP_TX_CODE', 'GET_EXC_FISC_CLAS_TX_CODE',
                'GET_EXC_ITEM_TX_CODE')
  THEN

    IF v_rule IN ('GET_ITEM_TX_CODE', 'GET_EXC_ITEM_TX_CODE')
    THEN
      SELECT substr(st.text,1,150)
      INTO   v_message_text
      FROM   jl_zz_ar_tx_lgl_msg lm,
             ar_standard_text_vl st
      WHERE  st.standard_text_id = lm.message_id
      AND    lm.rule_data_id =  p_rule_data_id
      AND    lm.inventory_organization_id = p_ship_from_warehouse_id
      AND    lm.rule_id = p_rule_id
      AND    lm.exception_code = p_legal_message_exception;
    ELSE
      SELECT substr(st.text,1,150)
      INTO   v_message_text
      FROM   jl_zz_ar_tx_lgl_msg lm,
             ar_standard_text_vl st
      WHERE  st.standard_text_id = lm.message_id
      AND    lm.rule_data_id =  p_rule_data_id
      AND    lm.rule_id = p_rule_id
      AND    lm.exception_code = p_legal_message_exception;
    END IF;

  END IF;

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','get_legal_message: ' || '-O- Legal Message: '||v_message_text);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.JL_ZZ_TAX','jl_zz_tax.get_legal_message()-');
  END IF;

  RETURN(v_message_text);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    fnd_message.set_name('JL', 'JL_LEGAL_MESSAGE_NOT_FOUND');
    fnd_message.set_token('RULE_CODE',v_rule);
    fnd_message.set_token('EXCEPTION_CODE',p_legal_message_exception);
    RETURN ('ERROR');

END get_legal_message;


END JL_ZZ_TAX;

/
