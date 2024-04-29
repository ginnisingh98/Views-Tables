--------------------------------------------------------
--  DDL for Package Body JG_ZZ_TAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_TAX" AS
/* $Header: jgzzrtxb.pls 120.10.12010000.1 2008/07/28 07:58:21 appldev ship $ */

g_current_runtime_level     NUMBER;
g_level_statement           CONSTANT  NUMBER   := FND_LOG.LEVEL_STATEMENT;
g_level_procedure           CONSTANT  NUMBER   := FND_LOG.LEVEL_PROCEDURE;
g_level_unexpected          CONSTANT  NUMBER   := FND_LOG.LEVEL_UNEXPECTED;

FUNCTION recalculate_tax RETURN VARCHAR2 IS
--
  l_return_code  VARCHAR2(1);
  l_country_code VARCHAR2(2);
  --l_tax_method   zx_product_options.tax_method_code%type;
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'JG.PLSQL.JG_ZZ_TAX.recalculate_tax.BEGIN',
                   'JG_ZZ_TAX: recalculate_tax(+)');
  END IF;

  l_country_code := NULL;
  --l_tax_method   := NULL;
  l_return_code  := 'N';

  --Bug 2354736
  l_country_code := JG_ZZ_SHARED_PKG.GET_COUNTRY(
                        ZX_PRODUCT_INTEGRATION_PKG.old_line_rec.org_id,
                        null);
  --l_country_code := FND_PROFILE.VALUE('JGZZ_COUNTRY_CODE');

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'JG.PLSQL.JG_ZZ_TAX.recalculate_tax',
                   'l_country_code = ' || l_country_code);
  END IF;

  IF NVL(l_country_code,'$') IN ('BR','AR','CO') THEN

  -- Bug 5015952- remove as it is redundant
  /******
     l_tax_method := NULL;

     BEGIN
       SELECT tax_method_code
       INTO   l_tax_method
       FROM   zx_product_options;
     EXCEPTION
       WHEN OTHERS THEN
            l_tax_method := NULL;
            IF (g_level_unexpected >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_unexpected,
                             'JG.PLSQL.JG_ZZ_TAX.recalculate_tax',
                              sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
            END IF;
     END;

     IF NVL(l_tax_method,'$') = 'LTE' THEN
   ****/

     -- reverted back the change for product category, product fiscal classification
     -- and tranasction business category as these columns will not be added to
     -- receivables transaction tables.

        IF (NVL(ZX_PRODUCT_INTEGRATION_PKG.old_line_rec.global_attribute2,'$') <>
            NVL(ZX_PRODUCT_INTEGRATION_PKG.new_line_rec.global_attribute2,'$')) OR
           (NVL(ZX_PRODUCT_INTEGRATION_PKG.old_line_rec.global_attribute3,'$') <>
            NVL(ZX_PRODUCT_INTEGRATION_PKG.new_line_rec.global_attribute3,'$')) OR
           (NVL(ZX_PRODUCT_INTEGRATION_PKG.old_line_rec.warehouse_id,'$') <>
	    NVL(ZX_PRODUCT_INTEGRATION_PKG.new_line_rec.warehouse_id,'$')) THEN
           l_return_code := 'Y';
        END IF;
    -- END IF;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'JG.PLSQL.JG_ZZ_TAX.recalculate_tax',
                   'l_return_code = ' || l_return_code);
    FND_LOG.STRING(g_level_statement,
                   'JG.PLSQL.JG_ZZ_TAX.recalculate_tax.END',
                   'JG_ZZ_TAX: recalculate_tax(-)');
  END IF;

  RETURN l_return_code;
END recalculate_tax;

FUNCTION get_default_tax_code (p_set_of_books_id     IN NUMBER,
                               p_trx_date            IN DATE,
                               p_trx_type_id         IN NUMBER) RETURN VARCHAR2 IS

  l_tax_code 	 VARCHAR2(50);
  l_org_id       NUMBER;
  l_country_code VARCHAR2(2);
  --l_tax_method   zx_product_options.tax_method_code%type;
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'JG.PLSQL.JG_ZZ_TAX.get_default_tax_code.BEGIN',
                   'JG_ZZ_TAX: get_default_tax_code(+)');
  END IF;

  l_country_code := NULL;
  --l_tax_method   := NULL;
  l_tax_code 	 := NULL;

  --Bug 2354736
  --l_country_code := JG_ZZ_SHARED_PKG.GET_COUNTRY(arp_tax.old_line_rec.org_id, null);
  --l_country_code := FND_PROFILE.VALUE('JGZZ_COUNTRY_CODE');

  --IF NVL(l_country_code,'$') IN ('BR','AR','CO') THEN

  -- Bug 5015952- remove as this is redundant
  /****
     l_tax_method := NULL;

     BEGIN
       SELECT tax_method_code,
              org_id
       INTO   l_tax_method,
              l_org_id
       FROM   zx_product_options;
     EXCEPTION
       WHEN OTHERS THEN
            l_tax_method := NULL;
            IF (g_level_unexpected >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_unexpected,
                             'JG.PLSQL.JG_ZZ_TAX.get_default_tax_code',
                              sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
            END IF;

     END;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'JG.PLSQL.JG_ZZ_TAX.get_default_tax_code',
                     'l_tax_method = ' || l_tax_method);
      FND_LOG.STRING(g_level_statement,
                     'JG.PLSQL.JG_ZZ_TAX.get_default_tax_code',
                     'l_org_id = ' || TO_CHAR(l_org_id));
    END IF;

     IF NVL(l_tax_method,'$') = 'LTE' THEN

******/

     l_org_id := ZX_AR_TAX_CLASSIFICATN_DEF_PKG.sysinfo.ar_product_options_rec.org_id;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'JG.PLSQL.JG_ZZ_TAX.get_default_tax_code'
,
                     'l_org_id = ' || TO_CHAR(l_org_id));
    END IF;

    -- bug#5601977- execute sql below only if org_id
    -- is available
    --
    IF l_org_id IS NOT NULL THEN
        BEGIN
          SELECT ctt.global_attribute4
          INTO   l_tax_code
          FROM   ra_cust_trx_types_all ctt,
                 ar_vat_tax_all vt
          WHERE  ctt.cust_trx_type_id = p_trx_type_id
          AND    ctt.org_id = vt.org_id
          AND    ctt.org_id = l_org_id
          AND    ctt.global_attribute4 = vt.tax_code
          AND    vt.set_of_books_id = p_set_of_books_id
          AND    p_trx_date between vt.start_date
                            and     nvl(vt.end_date,p_trx_date)
          AND    nvl(vt.enabled_flag,'Y') = 'Y'
          AND    nvl(vt.tax_class,'O') = 'O';
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
               l_tax_code := NULL;
          WHEN OTHERS THEN
               l_tax_code := NULL;
               IF (g_level_unexpected >= g_current_runtime_level ) THEN
                 FND_LOG.STRING(g_level_unexpected,
                                'JG.PLSQL.JG_ZZ_TAX.get_default_tax_code',
                                 sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
               END IF;
        END;
    END IF;

 -- END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'JG.PLSQL.JG_ZZ_TAX.get_default_tax_code',
                   'l_tax_code = ' || l_tax_code);
    FND_LOG.STRING(g_level_statement,
                   'JG.PLSQL.JG_ZZ_TAX.get_default_tax_code.END',
                   'JG_ZZ_TAX: get_default_tax_code(-)');
  END IF;

  RETURN (l_tax_code);

END get_default_tax_code;

FUNCTION get_default_tax_code (
                            p_ship_to_site_use_id IN NUMBER
                           ,p_bill_to_site_use_id IN NUMBER
                           ,p_inventory_item_id   IN NUMBER
                           ,p_organization_id     IN NUMBER
                           ,p_warehouse_id        IN NUMBER
                           ,p_set_of_books_id     IN NUMBER
                           ,p_trx_date            IN DATE
                           ,p_trx_type_id         IN NUMBER
                           ,p_cust_trx_id         IN NUMBER
                           ,p_cust_trx_line_id    IN NUMBER
                           ,APPL_SHORT_NAME       IN VARCHAR2
                           ,FUNC_SHORT_NAME       IN VARCHAR2)
RETURN VARCHAR2 IS

  l_tax_code 	 VARCHAR2(50);

BEGIN

  l_tax_code := get_default_tax_code (p_set_of_books_id => p_set_of_books_id,
                               p_trx_date => p_trx_date,
                               p_trx_type_id  => p_trx_type_id);


  RETURN (l_tax_code);

END get_default_tax_code;

END JG_ZZ_TAX;

/
