--------------------------------------------------------
--  DDL for Package Body ZX_AR_TAX_CLASSIFICATN_DEF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_AR_TAX_CLASSIFICATN_DEF_PKG" as
/* $Header: zxartxclsdefpkgb.pls 120.28.12010000.3 2009/04/02 13:18:20 rasarasw ship $ */

  g_current_runtime_level     NUMBER;
  g_level_statement           CONSTANT  NUMBER   := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure           CONSTANT  NUMBER   := FND_LOG.LEVEL_PROCEDURE;
  g_level_unexpected          CONSTANT  NUMBER   := FND_LOG.LEVEL_UNEXPECTED;

  -- global variable to hold org_id of PA or AR
  g_org_id                    NUMBER;

  PG_DEBUG 	              VARCHAR2(1);
  TAX_CODE_DEFAULT_EXTENSION  VARCHAR2(1) := NULL;
  c                           INTEGER;
  rows                        INTEGER;
  statement                   VARCHAR2(2000);
  dummy                       VARCHAR2(25);
  pg_tax_rate_passed          ar_vat_tax.tax_rate%TYPE;
  pg_adhoc_tax_code           VARCHAR2(1);
  curridx                     INTEGER := 1;
  buf                         VARCHAR2(2160) := NULL;

  type tab_ids is table of number index by binary_integer;
  type tab_errors is table of varchar2(2000) index by binary_integer;
  pg_error_id_tab  tab_ids;
  pg_error_msg_tab tab_errors;
  pg_err_ins_ind   binary_integer := 0;
  pg_err_get_ind   binary_integer := 0;

  type tab_num_type is table of number index by binary_integer;
  type tab_code_type is table of varchar2(15) index by binary_integer;
  pg_max_p_mau_index      INTEGER := 0;
  pg_currency_code_tab	  tab_code_type;
  pg_precision_tab        tab_num_type;
  pg_min_acct_unit_tab    tab_num_type;
  pg_batch_tax_rate_rule  ra_batch_sources.invalid_tax_rate_rule%TYPE;

  --
  -- Forward declarations
  --

  FUNCTION get_site_tax(
               p_site_use_id	  IN  hz_cust_site_uses.site_use_id%TYPE,
               p_trx_date         IN  ra_customer_trx.trx_date%TYPE)
           RETURN VARCHAR2;

  FUNCTION get_customer_tax(
               p_site_use_id     IN  hz_cust_site_uses.site_use_id%TYPE,
  	       p_customer_id     IN  hz_cust_accounts.cust_account_id%TYPE,
               p_trx_date        IN  ra_customer_trx.trx_date%TYPE )
           RETURN VARCHAR2;

  FUNCTION get_item_tax(
               p_item_id          IN  mtl_system_items.inventory_item_id%TYPE,
  	       p_organization_id  IN  mtl_system_items.organization_id%TYPE,
               p_trx_date         IN  DATE,
               p_memo_line_id     IN  ar_memo_lines.memo_line_id%TYPE default null)
           RETURN VARCHAR2;
/*******
  -- Bug#3945805
  FUNCTION get_location_tax(
               p_product           IN  VARCHAR2,
               p_site_use_id       IN  hz_cust_site_uses.site_use_id%TYPE,
               p_party_flag        IN  VARCHAR2,
               p_party_location_id IN  hz_locations.location_id%type default null)
           RETURN VARCHAR2;

******/
  FUNCTION get_natural_acct_tax (
               p_ccid                     IN NUMBER,
               p_internal_organization_id IN NUMBER,
               p_set_of_books_id          IN ar_system_parameters.set_of_books_id%TYPE,
               p_trx_date                 IN ra_customer_trx.trx_date%TYPE,
               p_check_override_only      IN VARCHAR2)
           RETURN VARCHAR2;


PROCEDURE pop_pa_tax_info(p_internal_organization_id    IN   NUMBER,
                          p_application_id              IN   NUMBER,
                          p_return_status               OUT NOCOPY VARCHAR2);

PROCEDURE pop_ar_tax_info(p_internal_organization_id    IN   NUMBER,
                          p_application_id              IN   NUMBER,
                          p_return_status               OUT NOCOPY VARCHAR2);

PROCEDURE pop_ar_system_param_info(p_internal_organization_id    IN   NUMBER,
                                   p_return_status               OUT NOCOPY VARCHAR2);

/*----------------------------------------------------------------------------*
 |Public Procedure                                                            |
 |  get_project_tax                                                           |
 |                                                                            |
 |Description                                                                 |
 |  get tax code associated with a project.                                   |
 |                                                                            |
 |Called From                                                                 |
 |  get_pa_default_classification                                             |
 |                                                                            |
 |History                                                                     |
 |  28-OCT-98   TKOSHIO       CREATED                                         |
 |  22-Jun-04   Sudhir Sekuri Bugfix 3611046                                  |
 *----------------------------------------------------------------------------*/

FUNCTION get_project_tax(p_project_id	   IN NUMBER,
                         p_trx_date        IN DATE,
			 p_retention_flag  IN BOOLEAN DEFAULT FALSE) return VARCHAR2 IS
-- Bug 2355866
  l_retention_flag varchar2(10) := NULL ;

  CURSOR tax_csr (c_project_id     NUMBER,
                  c_retention_flag VARCHAR2,
                  c_trx_date       DATE,
                  c_org_id         NUMBER)  IS
  SELECT p.output_tax_code,
	 p.retention_tax_code
--    FROM fnd_lookups l, pa_projects p   bug#4574838
     FROM zx_output_classifications_v l,
          pa_projects p
   WHERE p.project_id = c_project_id
     AND l.lookup_code = decode(c_retention_flag,'TRUE',p.retention_tax_code,p.output_tax_code)
     AND l.org_id IN (c_org_id, -99)
     AND l.enabled_flag = 'Y'
     AND (l.start_date_active <= c_trx_date OR
          l.start_date_active is null)
     AND (l.end_date_active >= c_trx_date OR
          l.end_date_active is null)
     AND rownum = 1
     ORDER BY l.org_id desc;
--     AND l.lookup_type = 'ZX_OUTPUT_CLASSIFICATIONS';

  l_tax_csr_rec                  tax_csr%rowtype;


  --l_tax_classification_code      varchar2(30) := NULL;
  -- Bug#4574838
  l_tax_classification_code      zx_lines_det_factors.output_tax_classification_code%TYPE;

BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_project_tax.BEGIN',
                   'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: get_project_tax(+)');
  END IF;

  l_tax_classification_code := NULL;

  if p_retention_flag then
    l_retention_flag := 'TRUE';
  else
    l_retention_flag := 'FALSE';
  end if;

  l_tax_csr_rec.output_tax_code := NULL;
  l_tax_csr_rec.retention_tax_code := NULL;

  --
  -- Bug#5331994- add trx_date and org_id
  --
  open tax_csr(p_project_id,
               l_retention_flag,
               p_trx_date,
               g_org_id);
  fetch tax_csr into l_tax_csr_rec;
  close tax_csr;

  if p_retention_flag then
    l_tax_classification_code := l_tax_csr_rec.retention_tax_code;
  else
    l_tax_classification_code := l_tax_csr_rec.output_tax_code;
  end if;

  IF (g_level_statement >= g_current_runtime_level ) THEN
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_project_tax',
                       'tax_classificaton_code => '||l_tax_classification_code);
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_project_tax.END',
                       'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: get_project_tax(-)');
  END IF;


  return l_tax_classification_code;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','get_project_tax- '||
                           sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_project_tax',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;
    if tax_csr%isopen then
      close tax_csr;
    end if;
    RAISE;


END get_project_tax;

/*----------------------------------------------------------------------------*
 |Public Procedure                                                            |
 |  get_expenditure_tax                                                       |
 |                                                                            |
 |Description                                                                 |
 |  get tax code associated with a expenditure.                               |
 |                                                                            |
 |Called From                                                                 |
 |  get_pa_default_classification                                             |
 |                                                                            |
 |History                                                                     |
 |  28-OCT-98   TKOSHIO       CREATED                                         |
 |  22-Jun-04   Sudhir Sekuri Bugfix 3611046                                  |
 *----------------------------------------------------------------------------*/

FUNCTION get_expenditure_tax(
           p_expenditure_item_id  IN NUMBER,
           p_trx_date             IN DATE) return VARCHAR2 IS

-- NOTE: OUTPUT_VAT_TAX_ID column in PA_EXPENDITURE_TYPE_OUS should be replaced
--       with tax classification code and the following query needs
--       to replace output_vat_tax_id with the replaced column

  --
  -- Bug#4520804
  --
  CURSOR tax_csr
    (c_expenditure_item_id  NUMBER,
     c_org_id               NUMBER,
     c_trx_date             DATE)  IS
  SELECT  l.lookup_code
    FROM  zx_output_classifications_v l,
          -- fnd_lookups l,      bug#4574838
          pa_expenditure_type_ous_all type,
          pa_expenditure_items_all item
   WHERE  item.expenditure_item_id = c_expenditure_item_id
     AND  item.expenditure_type = type.expenditure_type
     AND  item.org_id = c_org_id
     AND  item.org_id = type.org_id
     AND  l.lookup_code = type.output_tax_classification_code
     AND  l.org_id  IN (c_org_id, -99)
     AND  l.enabled_flag = 'Y'
     AND (l.start_date_active <= c_trx_date OR
          l.start_date_active is null)
     AND (l.end_date_active >= c_trx_date OR
          l.end_date_active is null)
     AND  rownum = 1
     ORDER BY l.org_id desc
;

  l_output_tax_code   zx_lines_det_factors.output_tax_classification_code%TYPE;

BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_expenditure_tax.BEGIN',
                   'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: get_expenditure_tax(+)');
  END IF;

  --
  -- Bug#5331994- add trx_date
  --
  open tax_csr(p_expenditure_item_id,
               sysinfo.pa_product_options_rec.org_id,
               p_trx_date);
  fetch tax_csr into l_output_tax_code;
  close tax_csr;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_expenditure_tax',
                   'tax_code => '||l_output_tax_code);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_expenditure_tax.END',
                   'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: get_expenditure_tax(-)');
  END IF;


  return l_output_tax_code;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','get_expenditure_tax- '||
                           sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_expenditure_tax',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;
    if tax_csr%isopen then
      close tax_csr;
    end if;
    RAISE;

END get_expenditure_tax;

/*----------------------------------------------------------------------------*
 |Public Procedure                                                            |
 |  get_event_tax                                                             |
 |                                                                            |
 |Description                                                                 |
 |  get tax code associated with a project.                                   |
 |                                                                            |
 |Called From                                                                 |
 |  get_pa_default_classification                                             |
 |                                                                            |
 |History                                                                     |
 |  28-OCT-98      TKOSHIO    CREATED                                         |
 *----------------------------------------------------------------------------*/

FUNCTION get_event_tax(p_event_id  IN NUMBER) return VARCHAR2 IS

  CURSOR tax_csr (c_event_id NUMBER)  IS
  SELECT ev.tax_code
    FROM pa_event_output_tax ev
   WHERE ev.event_id = c_event_id;


  --  l_output_tax_code varchar2(50) := NULL;  bug#4574838

  l_output_tax_code   zx_lines_det_factors.output_tax_classification_code%TYPE;
BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_event_tax.BEGIN',
                       'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: get_event_tax(+)');
  END IF;

  l_output_tax_code := NULL;

  open tax_csr(p_event_id);
  fetch tax_csr into l_output_tax_code;
  close tax_csr;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_event_tax',
                   'tax_code => '||l_output_tax_code);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_event_tax.END',
                   'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: get_event_tax(-)');
  END IF;


  return l_output_tax_code;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','get_event_tax- '||
                           sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_event_tax',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;
    if tax_csr%isopen then
      close tax_csr;
    end if;
    RAISE;


END get_event_tax;

/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                           |
 |    get_pa_default_classification                                           |
 |                                                                            |
 | DESCRIPTION                                                                |
 |  Returns default tax code for Project Accounting's Draft invoice.          |
 |                                                                            |
 | SCOPE: Public                                                              |
 |                                                                            |
 | CALLED FROM:                                                               |
 |  Project Accounting's Tax Defaulting api                                   |
 |                                                                            |
 | HISTORY                                                                    |
 |   28-NOV-98	TKOSHIO 	Created                                       |
 |   12-JUL-01  PLA             Bugfix# 1810878- if no tax code specified at  |
 |                              the ship to site, use tax code at the bill    |
 |                              to site                                       |
 |   12-FEB-2003 Octavio Pedregal Additional call to get_pa_default_tax_code  |
 |                                for Tax engine changes due to customer      |
 |                                relationship support in pa. Bugfix 2759960  |
 |   22-Jun-04   Sudhir Sekuri  Bugfix 3611046                                |
 *----------------------------------------------------------------------------*/

  PROCEDURE  get_pa_default_classification
       (p_project_id               IN            NUMBER
       ,p_customer_id              IN            NUMBER
       ,p_ship_to_site_use_id      IN            NUMBER
       ,p_bill_to_site_use_id      IN            NUMBER
       ,p_set_of_books_id          IN            NUMBER
       ,p_event_id                 IN            NUMBER
       ,p_expenditure_item_id      IN            NUMBER
       ,p_line_type                IN            VARCHAR2
       ,p_request_id               IN            NUMBER
       ,p_user_id                  IN            NUMBER
       ,p_trx_date                 IN            DATE
       ,p_tax_classification_code     OUT NOCOPY VARCHAR2
       ,p_application_id           IN  NUMBER
       ,p_internal_organization_id IN  NUMBER) IS

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_pa_default_classification.BEGIN',
                   'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: get_pa_default_classification(+)');
  END IF;

  get_pa_default_classification
       (p_project_id               => p_project_id
       ,p_project_customer_id      => p_customer_id
       ,p_ship_to_site_use_id      => p_ship_to_site_use_id
       ,p_bill_to_site_use_id      => p_bill_to_site_use_id
       ,p_set_of_books_id          => p_set_of_books_id
       ,p_event_id                 => p_event_id
       ,p_expenditure_item_id      => p_expenditure_item_id
       ,p_line_type                => p_line_type
       ,p_request_id               => p_request_id
       ,p_user_id                  => p_user_id
       ,p_trx_date                 => p_trx_date
       ,p_tax_classification_code  => p_tax_classification_code
       ,p_ship_to_customer_id      => NULL
       ,p_bill_to_customer_id      => NULL
       ,p_application_id           => p_application_id
       ,p_internal_organization_id => p_internal_organization_id);

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_pa_default_classification.END',
                   'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: get_pa_default_classification(-)');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','get_pa_default_classification- '||
                           sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_pa_default_classification',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;
    RAISE ;
  END get_pa_default_classification;

/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                           |
 |    get_pa_default_classification                                           |
 |                                                                            |
 | DESCRIPTION                                                                |
 |  Returns default tax classification code for Project Accounting's Draft    |
 |  invoice.                                                                  |
 |                                                                            |
 | SCOPE: Public                                                              |
 |                                                                            |
 | CALLED FROM:                                                               |
 |  Project Accounting's Tax Defaulting api                                   |
 |                                                                            |
 | HISTORY                                                                    |
 |   22-Jun094  Sudhir Sekuri   Created.                                      |
 |                                                                            |
 *----------------------------------------------------------------------------*/

PROCEDURE get_pa_default_classification (
                 p_project_id               IN     NUMBER,
                 p_project_customer_id      IN     NUMBER,
                 p_ship_to_site_use_id      IN     NUMBER,
                 p_bill_to_site_use_id      IN     NUMBER,
                 p_set_of_books_id          IN     NUMBER,
                 p_event_id                 IN     NUMBER,
                 p_expenditure_item_id      IN     NUMBER,
                 p_line_type                IN     VARCHAR2,
                 p_request_id               IN     NUMBER,
                 p_user_id                  IN     NUMBER,
                 p_trx_date                 IN     DATE,
                 p_tax_classification_code     OUT NOCOPY VARCHAR2,
                 p_ship_to_customer_id      IN     NUMBER,
                 p_bill_to_customer_id      IN     NUMBER,
                 p_application_id           IN  NUMBER,
                 p_internal_organization_id IN  NUMBER) IS

    l_site_use_id              NUMBER;
    l_default_level            VARCHAR2(30);
    --l_tax_classification_code  VARCHAR2(30);
    l_tax_classification_code zx_lines_det_factors.output_tax_classification_code%TYPE;

    l_vat_tax_id               NUMBER;
    l_count                    NUMBER;
    l_party_flag               VARCHAR2(1);
    l_return_status            VARCHAR2(80);
    l_product                  VARCHAR2(2);

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_pa_default_classification.BEGIN',
                   'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: get_pa_default_classification(+)');
  END IF;

  l_party_flag := 'N';
  l_site_use_id := nvl(p_ship_to_site_use_id, p_bill_to_site_use_id);
  l_product := 'PA';

  IF (sysinfo.pa_product_options_rec.ORG_ID is NULL OR
      sysinfo.pa_product_options_rec.ORG_ID <> p_internal_organization_id ) THEN
    pop_pa_tax_info(p_internal_organization_id,
                    p_application_id,
                    l_return_status );
    g_org_id :=  sysinfo.pa_product_options_rec.org_id;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
    END IF;
  END IF;

  IF (sysinfo.pa_product_options_rec.def_option_hier_1_code IS NOT NULL
      OR sysinfo.pa_product_options_rec.def_option_hier_2_code IS NOT NULL
      OR sysinfo.pa_product_options_rec.def_option_hier_3_code IS NOT NULL
      OR sysinfo.pa_product_options_rec.def_option_hier_4_code IS NOT NULL
      OR sysinfo.pa_product_options_rec.def_option_hier_5_code IS NOT NULL
      OR sysinfo.pa_product_options_rec.def_option_hier_6_code IS NOT NULL
      OR sysinfo.pa_product_options_rec.def_option_hier_7_code IS NOT NULL)
     AND NVL(sysinfo.pa_product_options_rec.use_tax_classification_flag,'N') = 'Y' THEN

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_pa_default_classification',

                       'Initializing PA defaulting information');
      END IF;

      sysinfo.search_pa_hierarchy_tab(1) := sysinfo.pa_product_options_rec.def_option_hier_1_code;
      sysinfo.search_pa_hierarchy_tab(2) := sysinfo.pa_product_options_rec.def_option_hier_2_code;
      sysinfo.search_pa_hierarchy_tab(3) := sysinfo.pa_product_options_rec.def_option_hier_3_code;
      sysinfo.search_pa_hierarchy_tab(4) := sysinfo.pa_product_options_rec.def_option_hier_4_code;
      sysinfo.search_pa_hierarchy_tab(5) := sysinfo.pa_product_options_rec.def_option_hier_5_code;
      sysinfo.search_pa_hierarchy_tab(6) := sysinfo.pa_product_options_rec.def_option_hier_6_code;
      sysinfo.search_pa_hierarchy_tab(7) := sysinfo.pa_product_options_rec.def_option_hier_7_code;
  ELSE
     IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_pa_default_classification',
                      'Defaulting of Tax Classification is not enabled or defaulting options are not set');
       FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_pa_default_classification.END',
                      'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: get_pa_default_classification()-' );
     END IF;
     return;
  END IF;

  l_count := sysinfo.search_pa_hierarchy_tab.COUNT;

  FOR i IN 1..l_count
  Loop
     IF (sysinfo.search_pa_hierarchy_tab(i) IS  NULL) Then
        --
        -- default hierachy options from 1 to 7 can not
        -- have gap, if the current one is NULL, the
        -- rest would be NULL, there is no need to
        -- continue looping
        --
        EXIT;
     ELSE
        --  sysinfo.search_pa_hierarchy_tab(i) IS NOT NULL

        l_default_level := rtrim(sysinfo.search_pa_hierarchy_tab(i));
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                         'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_pa_default_classification',
                         '-- Search level = '||l_default_level);
        END IF;

        IF (l_default_level = TAX_DEFAULT_CUSTOMER) THEN
           --
           -- Get Customer level tax code
           --
           -- Bill_to_site_use_id
           IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                           'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_pa_default_classification',
                           'get the customer level tax code using ship to information ...');
           END IF;

           l_tax_classification_code := get_customer_tax(p_ship_to_site_use_id,
                                                         p_ship_to_customer_id,
                                                         p_trx_date);
           -- Ship_to_site_use_id
           IF l_tax_classification_code IS NULL THEN
              IF (g_level_statement >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement,
                               'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_pa_default_classification',
                               'Cannot find tax code using ship to information. '||
                               'Using bill to information instead');
              END IF;

              l_tax_classification_code := get_customer_tax(
                                                  p_bill_to_site_use_id,
                                                  p_bill_to_customer_id,
                                                  p_trx_date);
           END IF;

        ELSIF (l_default_level = TAX_DEFAULT_SITE) THEN
              --
              -- Get Customer Site level tax code
              --
	      l_tax_classification_code := get_site_tax (l_site_use_id,
                                                         p_trx_date);

              --
              -- Bug# 1810878
              -- if tax_code is null in ship to site
              -- then get tax_code from bill to site
              --
              IF l_tax_classification_code is NULL and p_ship_to_site_use_id is NOT NULL THEN
                 l_tax_classification_code := get_site_tax (
                                                   p_bill_to_site_use_id,
                                                   p_trx_date);
              END IF;

        ELSIF (l_default_level = TAX_DEFAULT_PROJECT) THEN
	      --
	      -- Get Customer Project level tax code
	      --
              l_tax_classification_code := get_project_tax (
                                              p_project_id => p_project_id,
                                              p_trx_date   => p_trx_date);

        ELSIF (l_default_level = TAX_DEFAULT_EXP_EV) THEN
              --
              -- Get Customer Project level tax code
              --
	      IF ltrim(rtrim(p_line_type)) = 'EXPENDITURE' then
		 --
		 -- Get Expenditure Level Tax Code
		 --
        	 l_tax_classification_code :=
                   get_expenditure_tax (
                     p_expenditure_item_id => p_expenditure_item_id,
                     p_trx_date            => p_trx_date);

	      ELSIF ltrim(rtrim(p_line_type)) = 'EVENT' then
	 	 --
		 -- Get Event Level Tax Code
		 --
		 l_tax_classification_code := get_event_tax(
				                  p_event_id => p_event_id);

	      ELSIF ltrim(rtrim(p_line_type)) = 'RETENTION' then
		 --
		 -- Get Project Level Retention Tax Code
		 --
		 l_tax_classification_code := get_project_tax(
				                  p_project_id => p_project_id,
                                                  p_trx_date   => p_trx_date,
				                  p_retention_flag => TRUE);
	      END IF;

        ELSIF (l_default_level = TAX_DEFAULT_EXTENSION) THEN
      	      --
	      -- Get Client Extention Tax Code
              --

              -- NOTE: X_VAT_TAX_ID parameter should be changed to return and hold
              --       Tax Classification Code.
              --       This API internally calls PA_CLIENT_EXTN_OUTPUT_TAX and it
              --       needs to be changed for this parameter

              IF (g_level_statement >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_statement,
                                 'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_pa_default_classification',
                                 'Calling PA_TAX_CLIENT_EXTN_DRV.get_tax_code');
              END IF;

     	      PA_TAX_CLIENT_EXTN_DRV.get_tax_code(
	      		      p_project_id => p_project_id,
		      	      p_customer_id => p_project_customer_id,
			      p_bill_to_site_use_id => p_bill_to_site_use_id,
			      p_ship_to_site_use_id => p_ship_to_site_use_id,
			      p_set_of_books_id => p_set_of_books_id,
			      p_expenditure_item_id => p_expenditure_item_id,
			      p_event_id => p_event_id,
			      p_line_type => p_line_type,
			      p_request_id => p_request_id,
			      p_user_id => p_user_id,
                              X_output_Tax_code  => l_tax_classification_code);
                              -- bug#4480976
                              --x_vat_tax_id => l_vat_tax_id);


        ELSIF (l_default_level = TAX_DEFAULT_AR_PARAM) THEN
  	      --
	      -- Get AR System option level tax code
      	      --
              /* Bug 2214337: Get location based tax only if system level default tax code is null*/
/*************************
  -- Bug#3945805
              IF (
                  NVL(sysinfo.pa_product_options_rec.home_country_default_flag,'N') = 'Y') THEN
                  --
                  -- Look for tax code of type 'LOCATION'
                  --
                  l_tax_classification_code := get_location_tax(l_product,
                                                                l_site_use_id,
                                                                l_party_flag);

              ELSE
****************************/

                  l_tax_classification_code := sysinfo.pa_product_options_rec.tax_classification_code;
--              END IF;

        END IF;

        /* Bug Fix 2101493 Exit when tax code or tax id is found (when the
           level is TAX_DEFAULT_EXTENSION  tax id is returned,unlike other levels where
           tax code is returned. Therefore if tax code or tax id is not null then stop
           looping through the hierarchy */

        IF (l_tax_classification_code IS NOT NULL) THEN
           p_tax_classification_code := l_tax_classification_code;
	   EXIT;		-- Exit search when tax code found.
        END IF;
     END IF;
  END LOOP;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_pa_default_classification.END',
                   'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: get_pa_default_classification(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','get_pa_default_classification- '||
                           sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_pa_default_classification',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;
	RAISE ;
END get_pa_default_classification;


/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE
 |    get_default_tax_classification
 |
 | DESCRIPTION
 | In Release 11i, the defaulting hierarchy was used as a means to define
 |  Tax applicability. In order to support backward compatible behaviour of
 |  the defaulting hierarchy, the defaulted tax code will be passed to eTax
 |  as 'TAX_CLASSIFICATION_CODE', and in eTax, there will be rules created
 |  based on 'TAX_CLASSIFICATION_CODE' - for 'Direct Rate Determination'
 |  process, which will provide Tax, Tax Regime, Tax Status and Tax Rate
 | code as a result.
 |
 |  For example, if a tax code of  'VAT10' represents Tax Regime 'UK VAT',
 |  tax 'VAT', Tax Status Code 'STANDARD', and tax rate code of 'VAT10',
 | and if defaulting hierarchy is designed to default this tax code on the
 |  transaction, then after defaulting, 'VAT10' would be passed to eTax as
 |  Tax Classification Code, and there will be a rule for Direct Rate
 |  Determination in eTax as follows:
 |
 |   IF TAX_CLASSICATION_CODE = 'VAT10' THEN
 |   The result of Direct Rate Determination process is:
 |       Tax Regime Code 'UKVAT', Tax: 'VAT', Tax Status Code: 'STANDARD'
 |       and Tax Rate Code 'VAT10' are applicable'
 |
 |  In order to pass the Tax classification Code to eTax, there should be a
 |  new API: get_default_Tax_classification, which will look at the Event
 |  Class defaulting options for Receivables and based on the defaulting
 |  hierarchy in event class mapping for AR, will provide default tax
 |  classification - from customer, customer site, item, product or system,
 |  and returns the tax classification.
 |
 |  Bug 3517888 - For supporting customized views (The user may be currently
 |  using customized views to pass tax code to GTE), we will provide user
 |  definable PL/SQL function to default tax classification, which will be
 |  called from this new defaulting API. This pl/sql function name needs to
 |  be defined in TSRM at the same place where we are planning to define
 |  defaulting hierarchy options. We will call this function during defaulting
 |  api of the tax classification field, considering it as one of the
 |  defaulting hierarchy option. This API will also use the user-defined
 |  functions, defined in eTax Event Class Mappings to default Tax
 |  Classification Code (which is to support custom views that the user
 |  can define in AR today. For details, please refer bug 3517888).
 |
 |  Need to find out the event class options being introduced through bug
 |  3525184. Unless this bug is scoped in / resolved, we cannot code the
 |  new API - get_Default_Tax_Classification
 |
 |  This API needs to be called inside validate n default API when Tax
 |  Classification Code is NULL.
 |
 |    If the Tax Extension Service: TAX_CODE_DEFAULT has been implemented
 |    any call to this stored procedure will be implemented by a callout to
 |    A PL/SQL User Exit which a site can implement.
 |
 |    Tax Code search hierarchy: Search ends when a tax code is found.
 |
 | PARAMETERS
 |      ship_to_site_use_id  NUMBER
 |      bill_to_site_use_id  NUMBER
 |      inventory_item_id    NUMBER
 |      organization_id      NUMBER
 |      -- warehouse_id         NUMBER
 |      set_of_books_id      NUMBER
 |      trx_date             DATE
 |      trx_type_id          NUMBER                -- GL tax/Latin America
 |      memo_line_id         NUMBER default null
 |      customer_id          NUMBER default null
 |      cust_trx_id          NUMBER default null   -- GL tax for AR
 |      cust_trx_line_id     NUMBER default null   -- GL tax for AR
 |
 |      APPL_SHORT_NAME      VARCHAR2 default 'SO'
 |       Valid values:
 |       ------------
 |         OE - Order Entry; Tax code will not be defaulted from GL.
 |         AR - Receivables; GL Natural accounts for Revenue will also be used
 |			     to default tax code.
 |      FUNC_SHORT_NAME      VARCHAR2 default 'OE'
 |       Valid values:
 |       ------------
 |         OE            - Future use.
 |         ACCT_RULES    - Use Autoaccounting rules to default tax code from
 |			   GL (E.g. Trx line Insert)
 |         ACCT_DIST     - Use Accounting Distribution lines to default tax
 |			   code from GL. (E.g. Trx Line Update)
 |         GL_ACCT_FIXUP - If tax code should be enforced from Natural Account
 |                         Ignore hierarchy and default tax code from GL only
 |                         using Revenue Account distributions that do NOT
 |                         allow override of tax code.
 |                         (E.g. Tax code fixup on Transaction completion)
 |         GL_ACCT_FIRST - If tax code should be enforced from Natural Account
 |                         FIRST default tax code from GL using Revenue
 |			   Account distributions that do NOT allow override
 |			   of tax code.
 |		  	   If not found, default thru the hierarchy using
 |			   Accounting distributions.
 |			   (E.g. Autoinvoice and Recurring Invoice)
 |
 | RETURNS
 |    tax_code - if there is a valid active one
 |    vat_tax_id - Used by AR
 |    amount_includes_tax_flag     - Used by AR Trx Workbench
 |    amount_includes_tax_override - Used by AR Trx Workbench
 |    exception NO_DATA_FOUND when no tax code found
 |
 | EXAMPLE PL/SQL BLOCK
 |    Calling get_default_tax_classification() the procedure will return tax
 |    classification code or an exception
 |
 | HISTORY
 |    21-Jun-04   Sudhir Sekuri    Created.
 |
 *----------------------------------------------------------------------------*/
--
-- OE/OSM/AR Tax code defaulting API
--
PROCEDURE get_default_tax_classification (
              p_ship_to_site_use_id     IN     NUMBER,
  	      p_bill_to_site_use_id     IN     NUMBER,
              p_inventory_item_id       IN     NUMBER,
  	      p_organization_id         IN     NUMBER,
	      -- p_warehouse_id	        IN     NUMBER,
  	      p_set_of_books_id         IN     NUMBER,
  	      p_trx_date	        IN     DATE,
  	      p_trx_type_id	        IN     NUMBER,
  	      p_tax_classification_code    OUT NOCOPY VARCHAR2 ,
              -- p_vat_tax_id                 OUT NOCOPY NUMBER,
              -- p_amt_incl_tax_flag          OUT NOCOPY VARCHAR2,
  	      -- p_amt_incl_tax_override      OUT NOCOPY VARCHAR2,
  	      p_cust_trx_id  	        IN     NUMBER default null,
  	      p_cust_trx_line_id        IN     NUMBER default null,
  	      p_customer_id	        IN     NUMBER default null,
  	      p_memo_line_id	        IN     NUMBER default null,
	      APPL_SHORT_NAME           IN     VARCHAR2 default null,
	      FUNC_SHORT_NAME           IN     VARCHAR2 default null,
              p_party_flag              IN     VARCHAR2 default null,
              p_party_location_id       IN     VARCHAR2 default null,
              p_entity_code             IN     VARCHAR2,
              p_event_class_code        IN     VARCHAR2,
              p_application_id          IN     NUMBER,
              p_internal_organization_id IN    NUMBER,
              p_ccid                    IN NUMBER  default null
              ) IS

  -- v_tax_classification_code VARCHAR2(50) := NULL;
  v_tax_classification_code  zx_lines_det_factors.output_tax_classification_code%TYPE;
  l_use_acct_line_flag      BOOLEAN;

  l_default_level	VARCHAR2(30);
  l_site_use_id         NUMBER;
  l_first_pty_org_id    NUMBER;
  l_count               NUMBER;
  l_return_status       VARCHAR2(80);
  l_product             VARCHAR2(2);

  CURSOR sel_tax_code_info (c_tax_code        VARCHAR2,
                            c_set_of_books_id NUMBER,
                            c_trx_date        DATE) IS
  SELECT t.tax_code,
         t.vat_tax_id,
         amount_includes_tax_flag,
         amount_includes_tax_override
    FROM AR_VAT_TAX T
   WHERE t.tax_code = c_tax_code
     AND t.set_of_books_id = c_set_of_books_id
     AND c_trx_date between t.start_date and
                        nvl(t.end_date, c_trx_date)
     AND nvl(t.enabled_flag, 'Y') = 'Y'
     AND nvl(t.tax_class, 'O') = 'O';

  CURSOR c_evnt_cls_options (c_org_id           NUMBER,
                             c_application_id   NUMBER,
                             c_entity_code      VARCHAR2,
                             c_event_class_code VARCHAR2,
                             c_trx_date         DATE) IS
  select enforce_tax_from_acct_flag
    from zx_evnt_cls_options
   where application_id = c_application_id
     and entity_code = c_entity_code
     and event_class_code = c_event_class_code
     and first_pty_org_id = (Select party_tax_profile_id
                               From zx_party_tax_profile
                              where party_id = c_org_id
                                and party_type_code = 'OU')
     and c_trx_date >= effective_from
     and c_trx_date <= nvl(effective_to,c_trx_date)
     and enabled_flag = 'Y';

  cursor c_chk_tax_classif_code( c_tax_code in VARCHAR2,
                                 c_org_id in NUMBER,
                                 c_trx_date  DATE) is
         select lookup_code
         from   zx_output_classifications_v
         where  lookup_code = c_tax_code
           AND  org_id  IN (c_org_id, -99)
           AND  enabled_flag = 'Y'
           AND (start_date_active <= c_trx_date OR
                start_date_active is null)
           AND (end_date_active >= c_trx_date OR
                end_date_active is null)
           AND  rownum = 1
         ORDER BY org_id desc;





 l_tax_enforce_account_flag zx_evnt_cls_options.enforce_tax_from_acct_flag%type;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification.BEGIN',
                   'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: get_default_tax_classification(+)');
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                   'p_ship_to_site_use_id: '||to_char(p_ship_to_site_use_id));
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                   'p_bill_to_site_use_id: '||to_char(p_bill_to_site_use_id));
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                   'p_inventory_item_id: '||to_char(p_inventory_item_id));
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                   'p_organization_id: '||to_char(p_organization_id));
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                   'p_set_of_books_id: '||to_char(p_set_of_books_id));
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                   'p_trx_date: '||to_char(p_trx_date,'DD-MON-YYYY'));
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                   'p_trx_type_id: '||to_char(p_trx_type_id));
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                   'p_cust_trx_id: '||to_char(p_cust_trx_id));
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                   'p_cust_trx_line_id: '||to_char(p_cust_trx_line_id));
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                   'p_customer_id: '||to_char(p_customer_id));
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                   'p_memo_line_id: '||to_char(p_memo_line_id));
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                   'APPL_SHORT_NAME: '||APPL_SHORT_NAME);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                   'FUNC_SHORT_NAME: '||FUNC_SHORT_NAME );
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                   'p_party_flag: '||p_party_flag);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                   'p_party_location_id: '||p_party_location_id );
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                   'p_application_id == >'||TO_CHAR(p_application_id));
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                   'p_internal_organization_id == >'||TO_CHAR(p_internal_organization_id));
   END IF;

  v_tax_classification_code := NULL;
  l_product                 := 'AR';

  IF (sysinfo.ar_product_options_rec.ORG_ID is NULL OR
      sysinfo.ar_product_options_rec.ORG_ID <> p_internal_organization_id) THEN
    pop_ar_tax_info(p_internal_organization_id,
                    p_application_id,
                    l_return_status );
    g_org_id := sysinfo.ar_product_options_rec.ORG_ID;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
    END IF;
  END IF;

  IF profinfo.so_organization_id is NULL then
      profinfo.so_organization_id := oe_sys_parameters.value('MASTER_ORGANIZATION_ID', g_org_id);
  END IF;

  /*************************************************************************/
  /* If installed, the Tax Vendor Extension will be called to determine if */
  /* the Tax Code Defaulting from Order Entry has been implemented         */
  /*************************************************************************/
  IF sysinfo.sysparam.tax_method = MTHD_LATIN  THEN
     v_tax_classification_code := JG_ZZ_TAX.get_default_tax_code(
                                            p_set_of_books_id,
                                            p_trx_date,
                                            p_trx_type_id);

     IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                      'Tax_method is LATIN and Tax code is '|| v_tax_classification_code);
       FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification.END',
                      'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: get_default_tax_classification()-' );
     END IF;
     --
     -- Bug#5024478- return output to caller
     --
     p_tax_classification_code := v_tax_classification_code;
     RETURN;
  END IF;

  -- Get Receivables default tax code.
  -- Search: Site, Customer, Product, Account, Tax type LOCATION and
  -- System option
  -- The search ends when a tax code is found.
  --

  IF NVL(sysinfo.ar_product_options_rec.use_tax_classification_flag,'N') = 'N' THEN
    --
    -- if use_tax_classification_flag is no, no need to
    -- search the default hierachy
    --
    p_tax_classification_code := NULL;
    RETURN;
  END IF;

  -- Fetch Tax Enforce Account Flag
  -- Bug#4090842- use org_id passed in
  --  OPEN c_evnt_cls_options (to_number(substrb(userenv('CLIENT_INFO'),1,10)),

  IF sysinfo.tax_enforce_account_flag is NULL then
    BEGIN
       OPEN c_evnt_cls_options (
                           p_internal_organization_id,
                           222,
                           p_entity_code,
                           p_event_class_code,
                           p_trx_date);
       FETCH c_evnt_cls_options into l_tax_enforce_account_flag;

       if c_evnt_cls_options%NOTFOUND then
            IF (g_level_statement >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                   'c_evnt_cls_options cursor not found !! Setting sysinfo.tax_enforce_account_flag  to N');
            END IF;

            sysinfo.tax_enforce_account_flag := 'N';
       end if;

       IF (g_level_statement >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                   'c_evnt_cls_options.tax_enforce_account_flag = '||l_tax_enforce_account_flag);
       END IF;

       sysinfo.tax_enforce_account_flag := l_tax_enforce_account_flag;

       if c_evnt_cls_options%ISOPEN then
                close c_evnt_cls_options;
       end if;

     EXCEPTION
       when others then

            IF (g_level_statement >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                   'Exception: '||SQLCODE||' ; '||SQLERRM||' Setting sysinfo.tax_enforce_account_flag  to N');
            END IF;
            sysinfo.tax_enforce_account_flag := 'N';
            if c_evnt_cls_options%ISOPEN then
                close c_evnt_cls_options;
            end if;
     END;
  END IF;

  -- If function called to fixup GL Acct Tax Code, Get Override
  -- protected Natural Acct tax code using Revenue account lines and
  -- exit.
  -- E.g.: Trx Workbench - Invoice Completion
  --
  IF ( NVL(appl_short_name, 'SO')  = 'AR' AND
       NVL(func_short_name, 'OE')  = 'GL_ACCT_FIXUP' AND
       nvl(sysinfo.tax_enforce_account_flag,'N') = 'Y' ) THEN

       v_tax_classification_code := get_natural_acct_tax(
                                        p_ccid => p_ccid,
                                        p_internal_organization_id => p_internal_organization_id,
		                	p_set_of_books_id=>p_set_of_books_id,
		                	p_trx_date=>p_trx_date,
		                	p_check_override_only=>'Y');

       IF v_tax_classification_code IS NOT NULL THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                           'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                           'Tax Classification code is '|| v_tax_classification_code);
            FND_LOG.STRING(g_level_statement,
                           'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification.END',
                           'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: get_default_tax_classification()-' );
          END IF;

          p_tax_classification_code := v_tax_classification_code;
          RETURN;
       ELSE
          RAISE NO_DATA_FOUND;
       END IF;
  END IF;

  -- If function called to look for tax codes at Natural Account first
  -- Get Override protected natural Account tax code using Revenue
  -- account lines. If tax code not found, Search thru the hierarchy.
  -- E.g.: Autoinvoice and Recurring tax code defaulting.
  --
  IF ( NVL(func_short_name, 'OE')  = 'GL_ACCT_FIRST' AND
         nvl(sysinfo.tax_enforce_account_flag,'N') = 'Y' ) THEN

       v_tax_classification_code := get_natural_acct_tax(
                                        p_ccid => p_ccid,
                                        p_internal_organization_id => p_internal_organization_id,
       				        p_set_of_books_id=>p_set_of_books_id,
       			                p_trx_date=>p_trx_date,
       				        p_check_override_only=>'Y');
       IF v_tax_classification_code IS NOT NULL THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                           'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                           'Tax Classification code is '|| v_tax_classification_code);
            FND_LOG.STRING(g_level_statement,
                           'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification.END',
                           'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: get_default_tax_classification()-' );
          END IF;

          p_tax_classification_code := v_tax_classification_code;
          RETURN;
       END IF;

  END IF;

  /*----------------------------------------------------------------*/
  /*  Defaulting Hierarchy:                 			    */
  /*    Site, Customer, Item/Memo, Revenue Account, System Options  */
  /*----------------------------------------------------------------*/
  l_site_use_id := nvl(p_ship_to_site_use_id, p_bill_to_site_use_id);

  IF (sysinfo.ar_product_options_rec.def_option_hier_1_code IS NOT NULL
      OR sysinfo.ar_product_options_rec.def_option_hier_2_code IS NOT NULL
      OR sysinfo.ar_product_options_rec.def_option_hier_3_code IS NOT NULL
      OR sysinfo.ar_product_options_rec.def_option_hier_4_code IS NOT NULL
      OR sysinfo.ar_product_options_rec.def_option_hier_5_code IS NOT NULL
      OR sysinfo.ar_product_options_rec.def_option_hier_6_code IS NOT NULL
      OR sysinfo.ar_product_options_rec.def_option_hier_7_code IS NOT NULL) THEN

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                       'Initializing AR defaulting information');
      END IF;

      sysinfo.search_hierarchy_tab(1) := sysinfo.ar_product_options_rec.def_option_hier_1_code;
      sysinfo.search_hierarchy_tab(2) := sysinfo.ar_product_options_rec.def_option_hier_2_code;
      sysinfo.search_hierarchy_tab(3) := sysinfo.ar_product_options_rec.def_option_hier_3_code;
      sysinfo.search_hierarchy_tab(4) := sysinfo.ar_product_options_rec.def_option_hier_4_code;
      sysinfo.search_hierarchy_tab(5) := sysinfo.ar_product_options_rec.def_option_hier_5_code;
      sysinfo.search_hierarchy_tab(6) := sysinfo.ar_product_options_rec.def_option_hier_6_code;
      sysinfo.search_hierarchy_tab(7) := sysinfo.ar_product_options_rec.def_option_hier_7_code;
  ELSE
     IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                      'Defaulting of Tax Classification is not enabled or defaulting options are not set');
       FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification.END',
                      'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: get_default_tax_classification()-' );
     END IF;
     return;
  END IF;

  l_count := sysinfo.search_hierarchy_tab.COUNT;

  FOR i IN 1..l_count
  Loop
     IF (sysinfo.search_hierarchy_tab(i) IS NULL) Then
         --
         -- default hierachy options from 1 to 7 can not
         -- have gap, if the current one is NULL, the
         -- rest would be NULL, there is no need to
         -- continue looping
         --
         EXIT;
     ELSE
       -- sysinfo.search_hierarchy_tab(i) IS NOT NULL
         IF ( v_tax_classification_code IS NOT NULL ) THEN
            EXIT;
	 END IF;

	 l_default_level := rtrim(sysinfo.search_hierarchy_tab(i));
   	 IF (g_level_statement >= g_current_runtime_level ) THEN
   	   FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                          '-- Search level = '||l_default_level);
   	 END IF;
--crm
	 IF  (nvl(p_party_flag, 'N') = 'N') AND
             ( l_default_level = TAX_DEFAULT_SITE ) THEN
	     --
	     -- Get Customer Site level tax code
	     --
	     v_tax_classification_code := get_site_tax(l_site_use_id,
                                                       p_trx_date);
             -- Bug# 1810878
             -- if tax_classification_code is null in ship to site
             -- then get tax_classification_code from bill to site
             --
             IF v_tax_classification_code is NULL and p_ship_to_site_use_id is NOT NULL THEN
               v_tax_classification_code := get_site_tax(p_bill_to_site_use_id,
                                                         p_trx_date);
             END IF;

	 END IF;
--crm
	 IF ( nvl(p_party_flag, 'N') = 'N') AND
            ( l_default_level = TAX_DEFAULT_CUSTOMER ) THEN
            --
            -- Get Customer level tax code
	    --

      IF p_customer_id is NOT NULL AND l_site_use_id is NOT NULL THEN -- Bug 8201987

      v_tax_classification_code := get_customer_tax(l_site_use_id,
                                           p_customer_id,
                                           p_trx_date);

            IF v_tax_classification_code is NULL and
               p_ship_to_site_use_id is NOT NULL THEN
             v_tax_classification_code := get_customer_tax(
                                           p_bill_to_site_use_id,
                                           p_customer_id,
                                           p_trx_date);
           END IF;
        END IF;  -- Bug 8201987
   END IF;

	 IF ( l_default_level = TAX_DEFAULT_PRODUCT ) THEN
	    --
	    -- Get item level tax code
	    --

	        -- ER #1683780. Call get_item_tax using warehouse_id first
                IF p_organization_id is not NULL then
                      v_tax_classification_code :=
                              get_item_tax(p_inventory_item_id,
                                           p_organization_id,
                                           p_trx_date,
                                           p_memo_line_id);
                END IF;

                -- If warehouse_id is NULL or tax classification code is not found using warehouse_id
                -- then use item validation organization
                IF v_tax_classification_code is NULL then

                       v_tax_classification_code :=
                              get_item_tax(p_inventory_item_id,
                                           profinfo.so_organization_id,
                                           p_trx_date,
                                           p_memo_line_id);
                END IF;

	 END IF;

	 --
	 -- If Application is AR, Look at Natural account
	 --
         IF ( NVL(appl_short_name, 'SO' )  = 'AR' AND
	     l_default_level = TAX_DEFAULT_ACCOUNT ) THEN

	    IF NVL(func_short_name, 'OE')  IN ('ACCT_DIST', 'GL_ACCT_FIRST') THEN
	       l_use_acct_line_flag := TRUE;   -- Use Revenue account lines
	    ELSE
	       l_use_acct_line_flag := FALSE;  -- Use AutoAccounting rules
	    END IF;

            v_tax_classification_code := get_natural_acct_tax(
                                p_ccid => p_ccid,
                                p_internal_organization_id => p_internal_organization_id,
        			p_set_of_books_id=>p_set_of_books_id,
        			p_trx_date=>p_trx_date,
        			p_check_override_only=>'N');
         END IF;


	 IF ( l_default_level = TAX_DEFAULT_SYSTEM ) THEN

	      /* Bugfix 558633: System Option level always enabled for Sales Tax */
	      /* Bugfix 1139131: Only if tax code is null, use the location based tax */
              /* Bugfix 3711248: Only if home country default flag is enabled */
       /************************
        |-- Bug#3945805
	|      IF (
        |          NVL(sysinfo.ar_product_options_rec.home_country_default_flag,'N') = 'Y') THEN
	|	  --
	|	  -- Look for tax code of type 'LOCATION'
	|	  --
	|	  v_tax_classification_code := get_location_tax(
        |                                         l_product,
        |                                         site_use_id,
        |                                         p_party_flag,
        |                                         p_party_location_id);
        |      ELSE
       ***************************/

                  IF sysinfo.ar_product_options_rec.tax_classification_code is NOT NULL then


                       IF (g_level_statement >= g_current_runtime_level ) THEN
    				FND_LOG.STRING(g_level_statement,
                   			'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                  			 'defaulting tax classification from system ');
                       END IF;

                    -- check if this tax calssification code is valid for the current
                    -- transaction date

                       open c_chk_tax_classif_code(sysinfo.ar_product_options_rec.tax_classification_code,
                                                   p_internal_organization_id,
                                                   p_trx_date);
                       fetch c_chk_tax_classif_code
                         into v_tax_classification_code;
                       close c_chk_tax_classif_code;

                       IF (g_level_statement >= g_current_runtime_level ) THEN
    				FND_LOG.STRING(g_level_statement,
                   			'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                  			 'Tax classification defaulted from system is: v_tax_classification_code');
                       END IF;


                  END IF;


	     -- END IF;
	 END IF;
     END IF;
  END LOOP;	-- Search tax defaulting hierarchy

/*****************
  IF ( v_tax_classification_code IS NULL ) THEN
     --
     -- Look for tax code of type 'LOCATION'
     --
     v_tax_classification_code := get_location_tax(site_use_id,
                                      p_party_flag,
                                      p_party_location_id);
  END IF;
***************/

  p_tax_classification_code := v_tax_classification_code;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                   'default_tax_classification: '||v_tax_classification_code);
  END IF;

/* Bug#4406011
  --
  -- If tax classification code is not found and use tax_classification_flag is enabled,
  -- raise NO_DATA_FOUND error
  --
  IF (v_tax_classification_code IS NULL) THEN
     RAISE NO_DATA_FOUND;
  END IF;
*/

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification.END',
                   'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: get_default_tax_classification()-' );
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;
	RAISE;
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','get_default_tax_classification- '||
                           sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;
	RAISE ;
END get_default_tax_classification;


/*----------------------------------------------------------------------------*
 | PRIVATE FUNCTION                                                           |
 |    get_site_tax                               			      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This function will look for any tax code that is specified at the site  |
 |    level if the system options allow use of tax codes at site level. It    |
 |    will return the tax code if one is found for the Site id.               |
 |									      |
 | PARAMETERS                                                                 |
 |      site_use_id                       in NUMBER                           |
 |                                                                            |
 | RETURNS                                                                    |
 |      tax code if one is found at the site level and valid for the trx date.|
 |      null if a valid tax classification is not found.                      |
 |                                                                            |
 | CALLED FROM                                                                |
 |    get_default_tax_classification()                                        |
 |                                                                            |
 | HISTORY                                                                    |
 |    27-NOV-95  Mahesh Sabapathy  Created.                                   |
 |    06-Jan-98  Mahesh Sabapathy  Bugfix 604453: Exclude members of Tax Group|
 |    21-Jun-04  Sudhir Sekuri     Bug 3611046                                |
 *----------------------------------------------------------------------------*/

FUNCTION  get_site_tax (
  p_site_use_id         IN  hz_cust_site_uses.site_use_id%TYPE,
  p_trx_date            IN  ra_customer_trx.trx_date%TYPE)
RETURN VARCHAR2 IS

  l_cust_acct_site_id        HZ_CUST_ACCT_SITES.CUST_ACCT_SITE_ID%TYPE;
  l_party_tax_profile_id     ZX_PARTY_TAX_PROFILE.PARTY_TAX_PROFILE_ID%TYPE;
  l_zx_registration_rec      ZX_TCM_CONTROL_PKG.ZX_REGISTRATION_INFO_REC;
  l_tax_classification_code  HZ_CUST_SITE_USES.tax_code%TYPE;
  l_ret_record_level         VARCHAR2(30);
  l_return_status            VARCHAR2(80);
  l_error_buffer             VARCHAR2(100);

  l_parent_ptp_id            ZX_PARTY_TAX_PROFILE.PARTY_TAX_PROFILE_ID%TYPE;
  l_cust_account_id          HZ_CUST_ACCT_SITES.CUST_ACCOUNT_ID%TYPE;

  CURSOR get_site_tax_info
    (c_site_use_id      hz_cust_site_uses.site_use_id%TYPE,
     c_org_id           NUMBER,
     c_trx_date         date)
  IS
    SELECT su.tax_code
      FROM HZ_CUST_SITE_USES_ALL su, ZX_OUTPUT_CLASSIFICATIONS_V  l
      WHERE su.site_use_id = c_site_use_id
        AND su.org_id      = c_org_id
        AND l.lookup_code = su.tax_code
        AND l.org_id  IN (c_org_id, -99)
        AND l.enabled_flag = 'Y'
        AND (l.start_date_active <= c_trx_date OR
             l.start_date_active is null)
        AND (l.end_date_active >= c_trx_date OR
             l.end_date_active is null)
       AND rownum = 1
      ORDER BY l.org_id desc;
      -- rownum is added because there could be two potnetial rows returned, one for org_id -99
      -- and one for c_org_id




BEGIN

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_site_tax.BEGIN',
                   'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: get_site_tax(+)');
  END IF;

  l_tax_classification_code := NULL;

--  IF ( sysinfo.sysparam.tax_use_site_exc_rate_flag = 'Y' ) THEN


    OPEN get_site_tax_info(p_site_use_id,
                           g_org_id,
                           p_trx_date);
    FETCH get_site_tax_info INTO l_tax_classification_code;
    CLOSE get_site_tax_info;


  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_site_tax',
                   'tax_classification_code = ' ||
                    l_tax_classification_code);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_site_tax',
                   'l_return_status = ' || l_return_status);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_site_tax.END',
                   'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: get_site_tax(-)');
  END IF;

    RETURN l_tax_classification_code;

EXCEPTION
  WHEN OTHERS THEN
    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','get_site_tax- '|| l_error_buffer);
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_site_tax',
                      l_error_buffer);
    END IF;


	RAISE ;

END get_site_tax;

/*----------------------------------------------------------------------------*
 | PRIVATE FUNCTION                                                           |
 |    get_customer_tax                           			      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This function will look for any tax code that is specified at the       |
 |    customer level if the system options allow use of tax codes at the      |
 |    customer level. The function returns the tax code if one is found for   |
 |    the Customer id. It returns null if a default tax code is not found.    |
 |									      |
 | PARAMETERS                                                                 |
 |      site_use_id                       in NUMBER                           |
 |      customer_id                       in NUMBER default null              |
 |                                                                            |
 | RETURNS                                                                    |
 |      tax code - if one is found at the Customer level,valid for the 	      |
 |		   trx date						      |
 |      null - if a valid tax code is not found.                              |
 |                                                                            |
 | CALLED FROM                                                                |
 |    get_default_tax_classification()                                        |
 |                                                                            |
 | HISTORY                                                                    |
 |    27-NOV-95   Mahesh Sabapathy  Created.                                  |
 |    06-Jan-98   Mahesh Sabapathy Bugfix 604453: Exclude members of Tax Group|
 |    29-Feb-2000 Wei Feng, Bugfix 1205682: by changing the order of the FROM |
 |                          clause to have RA_CUSTORMER preceding AR_VAT_TAX. |
 *----------------------------------------------------------------------------*/

FUNCTION  get_customer_tax (
  p_site_use_id		IN  hz_cust_site_uses.site_use_id%TYPE,
  p_customer_id		IN  hz_cust_accounts.cust_account_id%TYPE,
  p_trx_date            IN  ra_customer_trx.trx_date%TYPE)
RETURN VARCHAR2 IS

  l_customer_id		     hz_cust_accounts.cust_account_id%TYPE;
  l_tax_classification_code  HZ_CUST_ACCOUNTS.tax_code%TYPE;

  l_ret_record_level      VARCHAR2(30);
  l_return_status         VARCHAR2(80);
  l_error_buffer          VARCHAR2(100);


  CURSOR get_customer_id
    (c_site_use_id      HZ_CUST_SITE_USES.site_use_id%TYPE)
  IS
    SELECT CUST_ACCT.cust_account_id
      FROM HZ_CUST_ACCOUNTS CUST_ACCT,
           HZ_CUST_ACCT_SITES CUST_ACCT_SITES,
      	   HZ_CUST_SITE_USES CUST_SITE_USES
     WHERE CUST_ACCT.cust_account_id = CUST_ACCT_SITES.cust_account_id
       AND CUST_ACCT_SITES.cust_acct_site_id = CUST_SITE_USES.cust_acct_site_id
       AND CUST_SITE_USES.site_use_id = c_site_use_id;


  CURSOR sel_customer_tax
    (c_customer_id              HZ_CUST_ACCOUNTS.cust_account_id%TYPE,
     c_org_id                   NUMBER,
     c_trx_date                 DATE)
  IS
    SELECT  c.tax_code
      FROM  HZ_CUST_ACCOUNTS_ALL c, ZX_OUTPUT_CLASSIFICATIONS_V  l
      WHERE c.cust_account_id = c_customer_id
        AND c.org_id = c_org_id
        AND l.lookup_code = c.tax_code
        AND l.org_id  IN (c_org_id, -99)
        AND l.enabled_flag = 'Y'
        AND (l.start_date_active <= c_trx_date OR
             l.start_date_active is null)
        AND (l.end_date_active >= c_trx_date OR
             l.end_date_active is null)
       AND rownum = 1
      ORDER BY l.org_id desc;


BEGIN

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_customer_tax.BEGIN',
                   'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: get_customer_tax(+)');
  END IF;

  l_tax_classification_code := NULL;

--  IF ( sysinfo.sysparam.tax_use_cust_exc_rate_flag = 'Y' ) THEN
    --
    -- If customer_id is not passed, then get customer_id using site_use_id
    --
    IF ( p_customer_id IS NOT NULL ) THEN
      l_customer_id := p_customer_id;
    ELSE
      --
      -- Get customer_id
      --
      OPEN get_customer_id(p_site_use_id);
      FETCH get_customer_id INTO l_customer_id;
      CLOSE get_customer_id;

    END IF;			-- Customer_id passed?

    IF l_customer_id IS NOT NULL THEN
      OPEN  sel_customer_tax(l_customer_id,
                             g_org_id,
                             p_trx_date);
      FETCH sel_customer_tax INTO l_tax_classification_code;
      CLOSE sel_customer_tax;
    END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_customer_tax',
                   'tax_classification_code = ' ||
                    l_tax_classification_code);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_customer_tax',
                   'l_return_status = ' || l_return_status);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_customer_tax.END',
                   'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: get_customer_tax(-)');
  END IF;

    RETURN l_tax_classification_code;

EXCEPTION
  WHEN OTHERS THEN
    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','get_customer_tax- '|| l_error_buffer);
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_customer_tax',
                     l_error_buffer);
    END IF;

	RAISE ;

END get_customer_tax;

/*----------------------------------------------------------------------------*
 | PRIVATE FUNCTION                                                           |
 |    get_item_tax                               			      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This function will look for any tax code that is specified at the       |
 |    item level if the system options allow use of tax codes at the item     |
 |    level. The function first looks at memo lines if a memo line id is      |
 |    passed and will look at items if a tax code was not found for memo lines|
 |    The function returns the tax code if one is valid and returns null if   |
 |    one is not found.                                                       |
 |									      |
 | PARAMETERS                                                                 |
 |      organization_id                   in NUMBER                           |
 |      item_id                           in NUMBER                           |
 |      memo_line_id                      in NUMBER                           |
 |									      |
 |                                                                            |
 | RETURNS                                                                    |
 |      tax code - if one is found at the Item or Memo line level,valid for   |
 |		   the trx date   					      |
 |      null - if a valid tax code is not found.                              |
 |                                                                            |
 | CALLED FROM                                                                |
 |    get_default_tax_classification()                                        |
 |                                                                            |
 | HISTORY                                                                    |
 |    27-NOV-95  Mahesh Sabapathy Created.                                    |
 |    06-Jan-98  Mahesh Sabapathy Bugfix 604453: Exclude members of Tax Group |
 |    23-Jun-04  Sudhir Sekuri    Bugfix 3611046                              |
 *----------------------------------------------------------------------------*/

FUNCTION  get_item_tax (
  p_item_id		IN  mtl_system_items.inventory_item_id%TYPE,
  p_organization_id	IN  mtl_system_items.organization_id%TYPE,
  p_trx_date            IN  DATE,
  p_memo_line_id	IN  ar_memo_lines.memo_line_id%TYPE default null
				) RETURN VARCHAR2 IS

--  l_tax_classification_code    varchar2(30);
  l_tax_classification_code zx_lines_det_factors.output_tax_classification_code%TYPE;

  CURSOR sel_memo_line_tax(
    c_memo_line_id   AR_MEMO_LINES.memo_line_id%type,
    c_trx_date       DATE,
    c_org_id         NUMBER)
  IS
  SELECT m.tax_code
    -- FROM fnd_lookups l, AR_MEMO_LINES M   bug#4574838
     FROM zx_output_classifications_v l, AR_MEMO_LINES m
   WHERE m.memo_line_id = c_memo_line_id
     AND l.lookup_code = m.tax_code
     AND l.org_id IN (c_org_id, -99)
     AND l.enabled_flag = 'Y'
     AND (l.start_date_active <= c_trx_date OR
          l.start_date_active is null)
     AND (l.end_date_active >= c_trx_date OR
          l.end_date_active is null)
     --AND l.lookup_type = 'ZX_OUTPUT_CLASSIFICATIONS'
     AND rownum = 1
     ORDER BY l.org_id desc;

  CURSOR sel_item_tax
    (c_item_id         MTL_SYSTEM_ITEMS.inventory_item_id%type,
     c_organization_id MTL_SYSTEM_ITEMS.organization_id%type,
     c_trx_date        DATE,
     c_org_id          NUMBER)
 IS
  SELECT i.tax_code
    -- FROM fnd_lookups l, MTL_SYSTEM_ITEMS    bug#4574838
     FROM zx_output_classifications_v  l, MTL_SYSTEM_ITEMS i
   WHERE i.inventory_item_id = c_item_id
     AND i.organization_id = c_organization_id
     AND l.lookup_code = i.tax_code
     AND l.org_id  IN (c_org_id, -99)
     AND l.enabled_flag = 'Y'
     AND (l.start_date_active <= c_trx_date OR
          l.start_date_active is null)
     AND (l.end_date_active >= c_trx_date OR
          l.end_date_active is null)
     -- AND l.lookup_type = 'ZX_OUTPUT_CLASSIFICATIONS'
     AND rownum = 1
     ORDER BY l.org_id desc;

BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_item_tax.BEGIN',
                   'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: get_item_tax()+' );
  END IF;

--  IF ( sysinfo.sysparam.tax_use_prod_exc_rate_flag = 'Y' ) THEN
	--
	-- If Memo line id passed, look for memo line tax code and if notfound
	-- then look for item tax code.
	--
	IF (p_memo_line_id IS NOT NULL) THEN
          --
          -- Bug#5331994- add trx_date and org_id
          --
	  OPEN sel_memo_line_tax(
                   p_memo_line_id,
                   p_trx_date,
                   g_org_id);
	  FETCH sel_memo_line_tax INTO l_tax_classification_code;
	  CLOSE sel_memo_line_tax;
	END IF;			-- Memo line info passed?

	IF (l_tax_classification_code IS NULL AND
            p_item_id IS NOT NULL) THEN
	  --
	  -- Couldn't find tax code for Memo lines, look for Item tax code
	  --
          --
          -- Bug#5331994- add trx_date and org_id
          --
	  OPEN sel_item_tax(
                   p_item_id,
                   p_organization_id,
                   p_trx_date,
                   g_org_id);

	  FETCH sel_item_tax INTO l_tax_classification_code;
	  CLOSE sel_item_tax;
	END IF;			-- Tax code not found and item_id passed?
--  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_item_tax',
                       '>>> O : Tax_classification_code = '||l_tax_classification_code);
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_item_tax.END',
                       'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: get_item_tax()-' );
  END IF;

  RETURN (l_tax_classification_code);

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','get_item_tax- '||
                           sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_item_tax',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;
    IF (sel_memo_line_tax%ISOPEN) THEN
      CLOSE sel_memo_line_tax;
    END IF;
    IF (sel_item_tax%ISOPEN) THEN
      CLOSE sel_item_tax;
    END IF;
    RAISE ;

END get_item_tax;

/*----------------------------------------------------------------------------*
 | PRIVATE FUNCTION                                                           |
 |    get_location_tax                               			      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This function will look for a valid tax code of type 'LOCATION' when    |
 |    the tax method is of type 'SALES TAX'                                   |
 |    The function returns the tax code if one is valid and returns null if   |
 |    one is not found.                                                       |
 |									      |
 | PARAMETERS                                                                 |
 |      set_of_books_id                   in NUMBER                           |
 |                                                                            |
 | RETURNS                                                                    |
 |      tax code - if a tax code of type 'LOCATION' valid for the trx date    |
 |                 is found.                                                  |
 |      null - if a valid tax code of type 'LOCATION' is not found.           |
 |                                                                            |
 | CALLED FROM                                                                |
 |    get_default_tax_classification()                                        |
 |                                                                            |
 | HISTORY                                                                    |
 |    27-NOV-95  Mahesh Sabapathy  Created.                                   |
 |    23-Jun-04  Sudhir Sekuri     Bugfix 3611046                             |
 |    22-Sep-05  Phong La          Bugfix 4625479: pass in p_product          |
 |    30-Sep-05  Phong La          Bugfix 3945805: do not this function       |
 *----------------------------------------------------------------------------*/
-- Bug#3945805
/******************************
FUNCTION  get_location_tax (
  p_product             IN VARCHAR2,
  p_site_use_id         IN  hz_cust_site_uses.site_use_id%TYPE,
  p_party_flag          IN  VARCHAR2,
  p_party_location_id   IN  hz_locations.location_id%type) RETURN VARCHAR2 IS

  l_country		hz_locations.country%TYPE := null;
  -- l_tax_classification_code		ar_vat_tax.tax_code%TYPE := null;

  l_tax_classification_code   zx_lines_det_factors.output_tax_classification_code%TYPE;

  CURSOR sel_addr_country(
    c_site_use_id  HZ_CUST_SITE_USES.site_use_id%TYPE)
  IS
  SELECT loc.country
   FROM HZ_CUST_ACCT_SITES acct_site,
        HZ_PARTY_SITES party_site,
        HZ_LOCATIONS loc,
        HZ_CUST_SITE_USES site_uses
  WHERE site_uses.site_use_id = c_site_use_id
    AND acct_site.cust_acct_site_id = site_uses.cust_acct_site_id
    AND acct_site.party_site_id = party_site.party_site_id
    AND loc.location_id = party_site.location_id;

--crm
  CURSOR sel_loc_country (
    c_party_location_id HZ_LOCATIONS.location_id%TYPE)
  IS
  SELECT country
    FROM HZ_LOCATIONS
   WHERE location_id = c_party_location_id;

BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_location_tax.BEGIN',
                       'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: get_location_tax()+' );
   	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_location_tax',
                       'p_site_use_id: '||to_char(p_site_use_id));
   	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_location_tax',
                       'p_party_flag: '||p_party_flag);
   	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_location_tax',
                       'p_party_location_id: '||p_party_location_id);
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_location_tax',
                       'p_product: '||p_product);
  END IF;

  l_tax_classification_code := NULL;

--crm
  IF (nvl(p_party_flag, 'N') = 'Y') THEN
    --
    -- Get Country code for party site location
    --
    OPEN sel_loc_country(p_party_location_id);
    FETCH sel_loc_country INTO l_country;
    CLOSE sel_loc_country;
  ELSE
    --
    -- Get Country code for the site
    --
    OPEN sel_addr_country(p_site_use_id);
    FETCH sel_addr_country INTO l_country;
    CLOSE sel_addr_country;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_location_tax',
                       'Country code is : '||l_country);
  END IF;

  --
  -- If tax method = 'Sales Tax' and Address is in the Home Country, then look
  -- for a valid tax code of type 'LOCATION'.
  --
  IF ( sysinfo.sysparam.default_country = l_country ) THEN
    IF p_product = 'AR' THEN
      l_tax_classification_code := sysinfo.ar_product_options_rec.tax_classification_code;
    ELSIF  p_product = 'PA' THEN
      l_tax_classification_code := sysinfo.pa_product_options_rec.tax_classification_code;
    END IF;

  END IF;	-- Tax method is 'Sales Tax'?

  IF (g_level_statement >= g_current_runtime_level ) THEN
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_location_tax',
                       '>>> O : Tax_classification_code = '||l_tax_classification_code);
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_location_tax.END',
                       'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: get_location_tax()-' );
  END IF;

  RETURN (l_tax_classification_code);

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','get_location_tax- '||
                           sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_location_tax',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;

	RAISE ;

END get_location_tax;
***************************/

/*----------------------------------------------------------------------------*
 | PRIVATE FUNCTION                                                           |
 |    get_natural_acct_tax                       			      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This function will look for any tax code that is specified at the       |
 |    natural account segment of the Revenue account of a transaction line.   |
 |    The tax code, If specified for the natural account must be valid for    |
 |    the trx date and set of books id. The function will return a valid      |
 |    tax code if one is found.                                               |
 |									      |
 |    If multiple revenue lines exist for the transaction line, All the       |
 |    Revenue account lines must have the same tax code(if any). The          |
 |    function will NOT return a tax code if multiple tax codes are found     |
 |    for the revenue lines.                                                  |
 |									      |
 | PARAMETERS                                                                 |
 |      customer_trx_line_id              in NUMBER                           |
 |      set_of_books_id                   in NUMBER                           |
 |      trx_date                          in DATE                             |
 |									      |
 |                                                                            |
 | RETURNS                                                                    |
 |      tax code if one is found at the natural account level and is valid for|
 |      the trx date and set of books id.                                     |
 |      null if a valid tax code is not found.                                |
 |                                                                            |
 | CALLED FROM                                                                |
 |    get_default_tax_classification()                                        |
 |                                                                            |
 | HISTORY                                                                    |
 |    25-Jul-97  Mahesh Sabapathy  Created.                                   |
 *----------------------------------------------------------------------------*/

FUNCTION get_natural_acct_tax (
   p_ccid                     IN NUMBER
  ,p_internal_organization_id IN NUMBER
  ,p_set_of_books_id          IN ar_system_parameters.set_of_books_id%TYPE
  ,p_trx_date                 IN ra_customer_trx.trx_date%TYPE
  ,p_check_override_only      IN VARCHAR2 ) RETURN VARCHAR2 IS


--  l_tax_classification_code	varchar2(30);
  l_tax_classification_code zx_lines_det_factors.output_tax_classification_code%TYPE;

  l_dummy			CHAR;

BEGIN
  IF (g_level_statement >= g_current_runtime_level ) THEN
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_natural_acct_tax.BEGIN',
                       'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: get_natural_acct_tax(+)');
  END IF;


  -- Get tax code from GL
  get_gl_tax_info ( p_ccid                     => p_ccid
                   ,p_internal_organization_id => p_internal_organization_id
  		   ,p_trx_date                 => p_trx_date
  		   ,p_set_of_books_id          => p_set_of_books_id
  		   ,p_check_override_only      => p_check_override_only
  		   ,p_tax_classification_code  => l_tax_classification_code
  		   ,p_override_flag	       => l_dummy );

  IF (g_level_statement >= g_current_runtime_level ) THEN
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_natural_acct_tax',
                       '>>> O : Tax_classification_code = '||l_tax_classification_code);
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_natural_acct_tax',
                       '>>> O : Override_flag = '||l_dummy);
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_natural_acct_tax.END',
                       'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: get_natural_acct_tax()-' );
  END IF;

  RETURN l_tax_classification_code;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','get_natural_acct_tax- '||
                           sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_natural_acct_tax',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;
	RAISE ;

END get_natural_acct_tax;

/*----------------------------------------------------------------------------*
 | PUBLIC  FUNCTION                                                           |
 |    get_gl_tax_info                            			      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Given a table of Revenue Account CCIDs,  Set_of_books_id and trx_date   |
 |    A distinct tax code if specified for the natural account of the         |
 |    Revenue accounts is found and is valid for the set_of_books_id and the  |
 |    trx_date, This function will return the tax_code and a status stating   |
 |    if the tax code is overrideable.                                        |
 |									      |
 |    If multiple revenue lines exist for the transaction line, All the       |
 |    Revenue account lines must have the same tax code(if any). The          |
 |    function will NOT return a tax code if multiple tax codes are found     |
 |    for the revenue lines.                                                  |
 |									      |
 | PARAMETERS                                                                 |
 |      CCID_table                        in NUMBER                           |
 |      set_of_books_id                   in NUMBER                           |
 |      trx_date                          in DATE                             |
 |      check_override_only               in DATE                             |
 |									      |
 |                                                                            |
 | RETURNS                                                                    |
 |      Tax_Code: If a distinct tax code is found for the natural account and |
 |                and is valid for the set_of_books_id and trx_date.          |
 |      Override_flag: Y, If the GL setup allows override of tax code, else N.|
 |                                                                            |
 | CALLED FROM                                                                |
 |    ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_natural_acct_tax()                   |
 |    ARP_PROCESS_TAX.Validate_tax_info()                                     |
 |                                                                            |
 | HISTORY                                                                    |
 |    25-Jul-97  Mahesh Sabapathy  Created.                                   |
 |    06-Jan-98  Mahesh Sabapathy Bugfix 604453: Exclude members of Tax Group |
 *----------------------------------------------------------------------------*/


PROCEDURE get_gl_tax_info (
   p_ccid        	 	IN NUMBER
  ,p_internal_organization_id   IN NUMBER
  ,p_trx_date            	IN DATE
  ,p_set_of_books_id     	IN NUMBER
  ,p_check_override_only 	IN CHAR
  ,p_tax_classification_code    OUT NOCOPY VARCHAR2
  ,p_override_flag       	OUT NOCOPY CHAR
  ,p_validate_tax_code_flag     IN BOOLEAN default TRUE) IS

  l_tax_classification_code  zx_lines_det_factors.output_tax_classification_code%TYPE;

  l_override_flag	     CHAR;
  statement                  varchar2(2000);

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_gl_tax_info.BEGIN',
                       'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: get_gl_tax_info()+' );
  END IF;

  l_override_flag           := NULL;
  l_tax_classification_code := NULL;

  -- bug fix 3783241 begin
  /*----------------------------------------------------------------------+
   | Build IN clause for the Revenue Account(s) CCIDs. E.g.:( 1000, 1001 )|
   +----------------------------------------------------------------------*/

   statement :=
   'Declare
      b_tax_code	VARCHAR2(50);
      b_override_flag	CHAR;
    Begin
      :b_tax_code := NULL;
      :b_override_flag := NULL;
      Begin
        -- See if accounts with Override tax code flag N have
        -- distinct tax codes.
        Select distinct tax_classification_code into :b_tax_code
          from gl_code_combinations gcc,
	       zx_acct_tx_cls_defs_all gtoa
         where code_combination_id =  :l_ccid ' ||
           ' and gcc.'||tax_gbl_rec.natural_acct_column||
				' = gtoa.account_segment_value
           and gtoa.ledger_id = :l_set_of_books_id
             and gtoa.org_id = :l_org_id
             and gtoa.tax_class  = ''OUTPUT''
	      and nvl(gtoa.allow_tax_code_override_flag, ''Y'') = ''N'';
	  :b_override_flag := ''N'';   -- Override protected tax code found
     Exception
       When TOO_MANY_ROWS then
	  :b_override_flag := ''N'';   -- Override protected distinct tax code
				       -- NOT found
       When NO_DATA_FOUND then
	  :b_override_flag := ''Y'';   -- Override protected accounts not found
     End;

     --
     -- Distinct tax code with override flag N NOT found.
     --
     If ( :b_tax_code IS NULL and :b_check_override_only = ''N'' ) Then
 	 Begin
           Select distinct tax_classification_code into :b_tax_code
             from gl_code_combinations gcc,
                  zx_acct_tx_cls_defs_all gtoa
            where code_combination_id = :l_ccid '||
            'and gcc.'||tax_gbl_rec.natural_acct_column||
				' = gtoa.account_segment_value
            and gtoa.ledger_id = :l_set_of_books_id
            and gtoa.org_id = :l_org_id
            and gtoa.tax_class  = ''OUTPUT'';
        Exception
          When TOO_MANY_ROWS OR NO_DATA_FOUND Then
		null;		-- Distinct Tax code not found
        End;
     End If;
   End;';

   IF (g_level_statement >= g_current_runtime_level ) THEN
   	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_gl_tax_info',
                       '-- statement = '||statement);
   END IF;

-- BugFix 936377
-- Bug Fix 3254621 add in p_set_of_books_id, nvl(sysinfo.sysparam.org_id, -1)
   EXECUTE IMMEDIATE statement USING IN OUT l_tax_classification_code,
                                     IN OUT l_override_flag,
                                            p_ccid,
                                            p_set_of_books_id,
                                            p_internal_organization_id,
                                            p_check_override_only ;

   IF (g_level_statement >= g_current_runtime_level ) THEN
   	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_gl_tax_info',
                       'l_tax_classification_code '||l_tax_classification_code);
   END IF;

  p_tax_classification_code := l_tax_classification_code;
  p_override_flag := l_override_flag;

  IF (g_level_statement >= g_current_runtime_level ) THEN
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_gl_tax_info',
                       '>>> O : Tax_classification_code = '||l_tax_classification_code);
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_gl_tax_info',
                       '>>> O : Override_flag = '||l_override_flag);
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_gl_tax_info.END',
                       'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: get_gl_tax_info()-' );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','get_gl_tax_info- '||
                           sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_gl_tax_info',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;
	RAISE;

END get_gl_tax_info;

-- Bug#4090842- new procedure
/*----------------------------------------------------------------------------*
 | PROCEDURE  pop_ar_tax_info                                                 |
 |                                                                            |
 | DESCRIPTION                                                                |
 |   This procedure populates AR tax default option hierachies from           |
 |   zx_product_options                                                       |
 |                                                                            |
 | RETURNS                                                                    |
 |                                                                            |
 | HISTORY                                                                    |
 |                                                                            |
 *----------------------------------------------------------------------------*/


PROCEDURE pop_ar_tax_info(p_internal_organization_id    IN   NUMBER,
                          p_application_id              IN   NUMBER,
                          p_return_status               OUT NOCOPY VARCHAR2)
IS
 l_chart_of_accounts_id  gl_sets_of_books.chart_of_accounts_id%type;
 l_functional_currency   gl_sets_of_books.currency_code%type;
 l_base_precision        fnd_currencies.precision%type;
 l_base_min_acc_unit     fnd_currencies.minimum_accountable_unit%type;
 l_master_org_id         oe_system_parameters_all.master_organization_id%type;
 l_sob_test              gl_sets_of_books.set_of_books_id%type;

 CURSOR c_ar_product_options (c_org_id         NUMBER,
                              c_application_id NUMBER) IS
 SELECT org_id,
        def_option_hier_1_code,
        def_option_hier_2_code,
        def_option_hier_3_code,
        def_option_hier_4_code,
        def_option_hier_5_code,
        def_option_hier_6_code,
        def_option_hier_7_code,
        home_country_default_flag,
        tax_classification_code,
        tax_method_code,
        inclusive_tax_used_flag,
        tax_use_customer_exempt_flag,
        tax_use_product_exempt_flag,
        tax_use_loc_exc_rate_flag,
        tax_allow_compound_flag,
        tax_rounding_rule,
        tax_precision,
        tax_minimum_accountable_unit,
        use_tax_classification_flag,
        allow_tax_rounding_ovrd_flag
   FROM zx_product_options_all
  WHERE org_id = c_org_id
    AND application_id = c_application_id
    AND event_class_mapping_id IS NULL;

BEGIN

  --
  -- Get tax default Info
  --
  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.pop_ar_tax_info.BEGIN',
                   'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: pop_ar_tax_info()+');
  END IF;

  -- init return status
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Fetch AR Application Product Options
  --    OPEN c_product_options (to_number(substrb(userenv('CLIENT_INFO'),1,10)), 222);

  OPEN c_ar_product_options (p_internal_organization_id, 222);
  FETCH c_ar_product_options
     INTO sysinfo.ar_product_options_rec.org_id,
          sysinfo.ar_product_options_rec.def_option_hier_1_code,
          sysinfo.ar_product_options_rec.def_option_hier_2_code,
          sysinfo.ar_product_options_rec.def_option_hier_3_code,
          sysinfo.ar_product_options_rec.def_option_hier_4_code,
          sysinfo.ar_product_options_rec.def_option_hier_5_code,
          sysinfo.ar_product_options_rec.def_option_hier_6_code,
          sysinfo.ar_product_options_rec.def_option_hier_7_code,
          sysinfo.ar_product_options_rec.home_country_default_flag,
          sysinfo.ar_product_options_rec.tax_classification_code,
          sysinfo.ar_product_options_rec.tax_method_code,
          sysinfo.ar_product_options_rec.inclusive_tax_used_flag,
          sysinfo.ar_product_options_rec.tax_use_customer_exempt_flag,
          sysinfo.ar_product_options_rec.tax_use_product_exempt_flag,
          sysinfo.ar_product_options_rec.tax_use_loc_exc_rate_flag,
          sysinfo.ar_product_options_rec.tax_allow_compound_flag,
          sysinfo.ar_product_options_rec.tax_rounding_rule,
	  sysinfo.ar_product_options_rec.tax_precision,
	  sysinfo.ar_product_options_rec.tax_minimum_accountable_unit,
	  sysinfo.ar_product_options_rec.use_tax_classification_flag,
	  sysinfo.ar_product_options_rec.allow_tax_rounding_ovrd_flag;
    CLOSE c_ar_product_options;


   sysinfo.sysparam.TAX_METHOD
                    :=sysinfo.ar_product_options_rec.TAX_METHOD_CODE ;
   sysinfo.sysparam.ORG_ID
                    :=sysinfo.ar_product_options_rec.ORG_ID ;
   sysinfo.sysparam.INCLUSIVE_TAX_USED
                    :=sysinfo.ar_product_options_rec.INCLUSIVE_TAX_USED_FLAG ;
   sysinfo.sysparam.TAX_USE_CUSTOMER_EXEMPT_FLAG
                    :=sysinfo.ar_product_options_rec.TAX_USE_CUSTOMER_EXEMPT_FLAG ;
   sysinfo.sysparam.TAX_USE_PRODUCT_EXEMPT_FLAG
                    :=sysinfo.ar_product_options_rec.TAX_USE_PRODUCT_EXEMPT_FLAG ;
   sysinfo.sysparam.TAX_USE_LOC_EXC_RATE_FLAG
                    :=sysinfo.ar_product_options_rec.TAX_USE_LOC_EXC_RATE_FLAG ;
   sysinfo.sysparam.TAX_ALLOW_COMPOUND_FLAG
                    :=sysinfo.ar_product_options_rec.TAX_ALLOW_COMPOUND_FLAG ;
   sysinfo.sysparam.TAX_ROUNDING_RULE
                    :=sysinfo.ar_product_options_rec.TAX_ROUNDING_RULE ;
   sysinfo.sysparam.TAX_MINIMUM_ACCOUNTABLE_UNIT
                    :=sysinfo.ar_product_options_rec.TAX_MINIMUM_ACCOUNTABLE_UNIT ;
   sysinfo.sysparam.TAX_PRECISION
                    :=sysinfo.ar_product_options_rec.TAX_PRECISION ;
   sysinfo.sysparam.TAX_ROUNDING_ALLOW_OVERRIDE
                    := sysinfo.ar_product_options_rec.allow_tax_rounding_ovrd_flag;

  --
  -- Bug#4625479- get default country code from ar_system_parameters
  --
  pop_ar_system_param_info(p_internal_organization_id,
                           p_return_status);

  IF (g_level_statement >= g_current_runtime_level ) THEN
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.pop_ar_tax_info.END',
                       'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: pop_ar_tax_info()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF c_ar_product_options%ISOPEN THEN
      CLOSE c_ar_product_options;
    END IF;
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', 'pop_ar_tax_info- '||
                          sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.pop_ar_tax_info',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;
END pop_ar_tax_info;

-- Bug#4090842- new procedure
/*----------------------------------------------------------------------------*
 | PROCEDURE  pop_pa_tax_info                                                 |
 |                                                                            |
 | DESCRIPTION                                                                |
 |   This procedure populates PA tax default option hierachies from           |
 |   zx_product_options                                                       |
 |                                                                            |
 | RETURNS                                                                    |
 |                                                                            |
 | HISTORY                                                                    |
 |                                                                            |
 *----------------------------------------------------------------------------*/

PROCEDURE pop_pa_tax_info(p_internal_organization_id    IN   NUMBER,
                          p_application_id     IN   NUMBER,
                          p_return_status      OUT NOCOPY VARCHAR2)
IS
 l_chart_of_accounts_id  gl_sets_of_books.chart_of_accounts_id%type;
 l_functional_currency   gl_sets_of_books.currency_code%type;
 l_base_precision        fnd_currencies.precision%type;
 l_base_min_acc_unit     fnd_currencies.minimum_accountable_unit%type;
 l_master_org_id         oe_system_parameters_all.master_organization_id%type;
 l_sob_test              gl_sets_of_books.set_of_books_id%type;

 CURSOR c_pa_product_options (c_org_id         NUMBER,
                              c_application_id NUMBER) IS
 SELECT org_id,
        def_option_hier_1_code,
        def_option_hier_2_code,
        def_option_hier_3_code,
        def_option_hier_4_code,
        def_option_hier_5_code,
        def_option_hier_6_code,
        def_option_hier_7_code,
        home_country_default_flag,
        tax_classification_code,
        tax_method_code,
        inclusive_tax_used_flag,
        tax_use_customer_exempt_flag,
        tax_use_product_exempt_flag,
        tax_use_loc_exc_rate_flag,
        tax_allow_compound_flag,
        tax_rounding_rule,
        tax_precision,
        tax_minimum_accountable_unit,
        use_tax_classification_flag,
        allow_tax_rounding_ovrd_flag
   FROM zx_product_options_all
  WHERE org_id = c_org_id
    AND application_id = c_application_id
    AND event_class_mapping_id IS NULL;

BEGIN

  --
  -- Get System Info
  --

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.pop_pa_tax_info.BEGIN',
                     'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: pop_pa_tax_info()+');
    END IF;

  -- init return status
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Fetch AR Application Product Options
  --    OPEN c_product_options (to_number(substrb(userenv('CLIENT_INFO'),1,10)), 275);

  OPEN c_pa_product_options (p_internal_organization_id, 275);
  FETCH c_pa_product_options
     INTO sysinfo.pa_product_options_rec.org_id,
          sysinfo.pa_product_options_rec.def_option_hier_1_code,
          sysinfo.pa_product_options_rec.def_option_hier_2_code,
          sysinfo.pa_product_options_rec.def_option_hier_3_code,
          sysinfo.pa_product_options_rec.def_option_hier_4_code,
          sysinfo.pa_product_options_rec.def_option_hier_5_code,
          sysinfo.pa_product_options_rec.def_option_hier_6_code,
          sysinfo.pa_product_options_rec.def_option_hier_7_code,
          sysinfo.pa_product_options_rec.home_country_default_flag,
          sysinfo.pa_product_options_rec.tax_classification_code,
          sysinfo.pa_product_options_rec.tax_method_code,
          sysinfo.pa_product_options_rec.inclusive_tax_used_flag,
          sysinfo.pa_product_options_rec.tax_use_customer_exempt_flag,
          sysinfo.pa_product_options_rec.tax_use_product_exempt_flag,
          sysinfo.pa_product_options_rec.tax_use_loc_exc_rate_flag,
          sysinfo.pa_product_options_rec.tax_allow_compound_flag,
          sysinfo.pa_product_options_rec.tax_rounding_rule,
	  sysinfo.pa_product_options_rec.tax_precision,
	  sysinfo.pa_product_options_rec.tax_minimum_accountable_unit,
	  sysinfo.pa_product_options_rec.use_tax_classification_flag,
	  sysinfo.pa_product_options_rec.allow_tax_rounding_ovrd_flag;
    CLOSE c_pa_product_options;



   sysinfo.sysparam.TAX_METHOD
                    :=sysinfo.pa_product_options_rec.TAX_METHOD_CODE ;
   sysinfo.sysparam.ORG_ID
                    :=sysinfo.pa_product_options_rec.ORG_ID ;
   sysinfo.sysparam.INCLUSIVE_TAX_USED
                    :=sysinfo.pa_product_options_rec.INCLUSIVE_TAX_USED_FLAG ;
   sysinfo.sysparam.TAX_USE_CUSTOMER_EXEMPT_FLAG
                    :=sysinfo.pa_product_options_rec.TAX_USE_CUSTOMER_EXEMPT_FLAG ;
   sysinfo.sysparam.TAX_USE_PRODUCT_EXEMPT_FLAG
                    :=sysinfo.pa_product_options_rec.TAX_USE_PRODUCT_EXEMPT_FLAG ;
   sysinfo.sysparam.TAX_USE_LOC_EXC_RATE_FLAG
                    :=sysinfo.pa_product_options_rec.TAX_USE_LOC_EXC_RATE_FLAG ;
   sysinfo.sysparam.TAX_ALLOW_COMPOUND_FLAG
                    :=sysinfo.pa_product_options_rec.TAX_ALLOW_COMPOUND_FLAG ;
   sysinfo.sysparam.TAX_ROUNDING_RULE
                    :=sysinfo.pa_product_options_rec.TAX_ROUNDING_RULE ;
   sysinfo.sysparam.TAX_MINIMUM_ACCOUNTABLE_UNIT
                    :=sysinfo.pa_product_options_rec.TAX_MINIMUM_ACCOUNTABLE_UNIT ;
   sysinfo.sysparam.TAX_PRECISION
                    :=sysinfo.pa_product_options_rec.TAX_PRECISION ;
   sysinfo.sysparam.TAX_ROUNDING_ALLOW_OVERRIDE
                    := sysinfo.pa_product_options_rec.allow_tax_rounding_ovrd_flag;

  --
  -- Bug#4625479- get default country code from ar_system_parameters
  --
  pop_ar_system_param_info(p_internal_organization_id,
                           p_return_status);

  IF (g_level_statement >= g_current_runtime_level ) THEN
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.pop_pa_tax_info.END',
                       'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: pop_pa_tax_info()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF c_pa_product_options%ISOPEN THEN
      CLOSE c_pa_product_options;
    END IF;
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', 'pop_pa_tax_info- '||
                          sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.pop_pa_tax_info',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;
END pop_pa_tax_info;




-- Bug#4625479- new procedure
/*----------------------------------------------------------------------------*
 | PROCEDURE  pop_ar_system_param_info                                        |
 |                                                                            |
 | DESCRIPTION                                                                |
 |   This procedure populates default country from ar_system_parameters       |
 |                                                                            |
 | RETURNS                                                                    |
 |                                                                            |
 | HISTORY                                                                    |
 |                                                                            |
 *----------------------------------------------------------------------------*/


PROCEDURE pop_ar_system_param_info(p_internal_organization_id    IN   NUMBER,
                                   p_return_status               OUT NOCOPY VARCHAR2)
IS
 CURSOR c_ar_system_param(c_org_id         NUMBER)
 IS
 SELECT default_country
   FROM ar_system_parameters_all
  WHERE org_id = c_org_id;

BEGIN

  --
  -- Get default country Info
  --
  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.pop_ar_system_param_info.BEGIN',
                   'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: pop_ar_system_param_info()+');
  END IF;

  -- init return status
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Fetch AR system parameters
  --
  OPEN c_ar_system_param(p_internal_organization_id);
  FETCH c_ar_system_param
    INTO sysinfo.sysparam.default_country;
  CLOSE c_ar_system_param;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.pop_ar_system_param_info',
                   'default country: ' || sysinfo.sysparam.default_country);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.pop_ar_system_param_info.END',
                   'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: pop_ar_system_param_info()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF c_ar_system_param%ISOPEN THEN
      CLOSE c_ar_system_param;
    END IF;
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', 'pop_ar_tax_info- '||
                          sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.pop_ar_system_param_info',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;
END pop_ar_system_param_info;




-- Bug#4090842- change and split initialize to pop_ar_tax_info
-- and pop_pa_tax_info
/*----------------------------------------------------------------------------*
 | PROCEDURE  INITIALIZE                                                        |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    The Initialize will set System and Profile options required by the     |
 |    Tax Entity Handler and other functions in the global records sysinfo    |
 |    and profinfo. It will also the Tax Account Qualifier Segment and the    |
 |    Location tax code count in the global record tax_gbl_rec.               |
 |                                                                            |
 | RETURNS                                                                    |
 |                                                                            |
 | HISTORY                                                                    |
 |                                                                            |
 *----------------------------------------------------------------------------*/


PROCEDURE initialize is

 l_master_org_id         oe_system_parameters_all.master_organization_id%type;
 l_sob_test              gl_sets_of_books.set_of_books_id%type;

BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.Initialize.BEGIN',
                     'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: Initialize()+');
    END IF;

    sysinfo.pa_product_options_rec.ORG_ID  := NULL;
    sysinfo.ar_product_options_rec.ORG_ID  := NULL;

  --
  -- Get Profile Info
  --
  -- bug 5120920 - use oe_sys_parameters.value();

  g_org_id := mo_global.get_current_org_id;

  IF g_org_id is not NULL then

      l_master_org_id := oe_sys_parameters.value('MASTER_ORGANIZATION_ID', g_org_id);

      if l_master_org_id is NULL then
               IF (g_level_procedure  >= g_current_runtime_level ) THEN
               	FND_LOG.STRING(g_level_procedure,
                                   'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.initialize',
                                   'Error Getting OE MASTER_ORGANIZATION ID using mo_global.get_current_org_id');
               END IF;
               FND_MESSAGE.set_name('AR','AR_NO_OM_MASTER_ORG');  -- Bug 3151551
               APP_EXCEPTION.raise_exception;
      end if;
      profinfo.so_organization_id := l_master_org_id;

  END IF;

  --
  -- GL Natural Account info
  --
  BEGIN
        tax_gbl_rec.natural_acct_column := arp_flex.expand(arp_flex.gl,
                                            'GL_ACCOUNT', ',', '%COLUMN%');
  EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',
                          'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.initialize- '||
                           sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.initialize',                               'Error Getting GL Natural Account Segment');
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.initialize',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;

    /******* Bug#4655710
    WHEN OTHERS THEN
        IF (g_level_unexpected >= g_current_runtime_level ) THEN
        	FND_LOG.STRING(g_level_unexpected,
                               'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.initialize',
                               'Error Getting GL Natural Account Segment');
        END IF;

        RAISE;

    **********/
  END;

  IF (g_level_statement >= g_current_runtime_level ) THEN
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.initialize.END',
                       'ZX_AR_TAX_CLASSIFICATN_DEF_PKG: Initialize()-');
  END IF;

END initialize;

/*----------------------------------------------------------------------------*
 | PACKAGE CONSTRUCTOR                                                        |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    The constructor will set System and Profile options required by the     |
 |    Tax Entity Handler and other functions in the global records sysinfo    |
 |    and profinfo. It will also the Tax Account Qualifier Segment and the    |
 |    Location tax code count in the global record tax_gbl_rec.               |
 |                                                                            |
 | RETURNS                                                                    |
 |                                                                            |
 | HISTORY                                                                    |
 |                                                                            |
 *----------------------------------------------------------------------------*/
--
-- Constructor code
--
BEGIN

  initialize;

END ZX_AR_TAX_CLASSIFICATN_DEF_PKG;


/
