--------------------------------------------------------
--  DDL for Package Body ZX_TAX_DEFAULT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TAX_DEFAULT_PKG" as
/* $Header: zxdidefhierpvtb.pls 120.14.12010000.1 2008/07/28 13:30:31 appldev ship $ */

  g_current_runtime_level      NUMBER;
  g_level_procedure          CONSTANT  NUMBER   := FND_LOG.LEVEL_PROCEDURE;
  g_level_statement            CONSTANT NUMBER   := FND_LOG.LEVEL_STATEMENT;
  g_level_unexpected           CONSTANT NUMBER   := FND_LOG.LEVEL_UNEXPECTED;

---------------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  get_default_tax_classification
--
--  DESCRIPTION
--  This procedure is the wrapper to call the defaulting tax classification
--  code API in AR, AP or PA  depending on the application id
--  passed in
--

PROCEDURE get_default_tax_classification (
    p_definfo               IN OUT NOCOPY  ZX_API_PUB.def_tax_cls_code_info_rec_type,
    p_return_status            OUT NOCOPY  VARCHAR2,
    p_error_buffer             OUT NOCOPY  VARCHAR2) IS

 l_appl_short_name             VARCHAR2(10);
 l_memo_line_id                NUMBER;
 l_customer_id                 NUMBER;
 l_tax_calculation_flag        VARCHAR(1);

 CURSOR get_tax_calc_flag IS
 SELECT tax_calculation_flag
 FROM RA_CUST_TRX_TYPES_ALL
 WHERE org_id = p_definfo.internal_organization_id
 AND cust_trx_type_id = p_definfo.receivables_trx_type_id;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TAX_DEFAULT_PKG.get_default_tax_classification.BEGIN',
           'ZX_TAX_DEFAULT_PKG: get_default_tax_classification(+)');
  END IF;

  -- init error buffer and return status
  --
  p_return_status  := FND_API.G_RET_STS_SUCCESS;
  p_error_buffer   := NULL;

  -- bug 4395918 : Add conditions for 'PURCHASE_TRANSACTION_TAX_QUOTE' and
  --               'SALES_TRANSACTION_TAX_QUOTE'
  --
  IF p_definfo.event_class_code = 'PURCHASE_TRANSACTION_TAX_QUOTE' OR
     (p_definfo.application_id IN (200, 201, 230, 401) AND
      p_definfo.event_class_code <> 'SALES_TRANSACTION_TAX_QUOTE')
  THEN
    --
    -- determine application short name for P2P products
    --
    IF p_definfo.application_id = 200 THEN
      l_appl_short_name := 'SQLAP';
    ELSE
      l_appl_short_name := 'PO';
    END IF;

    ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification (
          p_ref_doc_application_id        => p_definfo.ref_doc_application_id,
          p_ref_doc_entity_code           => p_definfo.ref_doc_entity_code,
          p_ref_doc_event_class_code      => p_definfo.ref_doc_event_class_code,
          p_ref_doc_trx_id                => p_definfo.ref_doc_trx_id,
          p_ref_doc_line_id               => p_definfo.ref_doc_line_id,
          p_ref_doc_trx_level_type        => p_definfo.ref_doc_trx_level_type,
          p_vendor_id                     => p_definfo.ship_third_pty_acct_id,
          p_vendor_site_id                => p_definfo.ship_third_pty_acct_site_id,
          p_code_combination_id           => p_definfo.account_ccid,
          p_concatenated_segments         => p_definfo.account_string,
          p_templ_tax_classification_cd   => p_definfo.defaulting_attribute3,
          p_ship_to_location_id           => p_definfo.ship_to_location_id,
          p_ship_to_loc_org_id            => p_definfo.defaulting_attribute1,
          p_inventory_item_id             => p_definfo.product_id,
          p_item_org_id                   => p_definfo.product_org_id,
          p_tax_classification_code       => p_definfo.input_tax_classification_code,
          p_allow_tax_code_override_flag  => p_definfo.x_allow_tax_code_override_flag,
          p_tax_user_override_flag        => p_definfo.tax_user_override_flag,
          p_user_tax_name                 => p_definfo.overridden_tax_cls_code,
          p_legal_entity_id               => p_definfo.legal_entity_id,
          APPL_SHORT_NAME                 => l_appl_short_name,
          FUNC_SHORT_NAME                 => p_definfo.defaulting_attribute2,
          p_calling_sequence              => 'ZX_TAX_DEFAULT_PKG.GET_DEFAULT_TAX_CLASSIFICATION',
          p_event_class_code              => p_definfo.event_class_code,
          p_entity_code                   => p_definfo.entity_code,
          p_application_id                => p_definfo.application_id,
          p_internal_organization_id      => p_definfo.internal_organization_id);

    p_definfo.x_tax_classification_code := p_definfo.input_tax_classification_code;


  ELSIF p_definfo.event_class_code = 'SALES_TRANSACTION_TAX_QUOTE' OR
        p_definfo.application_id IN (222, 300, 660, 697)
  THEN
    -- determine application short name for O2C products
    --
    IF  p_definfo.application_id = 222 THEN
      -- detrmining the tax calculation flag value for calling defaulting
      OPEN get_tax_calc_flag;
      FETCH get_tax_calc_flag INTO l_tax_calculation_flag;
      CLOSE get_tax_calc_flag;
      l_appl_short_name := 'AR';
    ELSE
      l_appl_short_name := NULL;
    END IF;

    -- bug 4382316
    IF (p_definfo.product_id IS NOT NULL AND
        p_definfo.product_org_id IS NULL) THEN
      l_memo_line_id  := p_definfo.product_id;
    END IF;

    l_customer_id :=
      NVL(p_definfo.ship_third_pty_acct_id, p_definfo.bill_third_pty_acct_id);

    IF p_definfo.application_id <> 222 OR (p_definfo.application_id = 222 AND
                                       l_tax_calculation_flag = 'Y') THEN
      ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification (
          p_ship_to_site_use_id      => p_definfo.ship_to_cust_acct_site_use_id,
          p_bill_to_site_use_id      => p_definfo.bill_to_cust_acct_site_use_id,
          p_inventory_item_id        => p_definfo.product_id,
          p_organization_id          => p_definfo.product_org_id,
          p_set_of_books_id          => p_definfo.ledger_id,
          p_trx_date                 => p_definfo.trx_date,
          p_trx_type_id              => p_definfo.receivables_trx_type_id,
          p_tax_classification_code  => p_definfo.output_tax_classification_code,
          p_cust_trx_id              => p_definfo.trx_id,
          p_cust_trx_line_id         => p_definfo.trx_line_id,
          p_customer_id              => l_customer_id,
          p_memo_line_id             => l_memo_line_id,
          APPL_SHORT_NAME            => l_appl_short_name ,
          FUNC_SHORT_NAME            => p_definfo.defaulting_attribute3,
          p_party_flag               => p_definfo.defaulting_attribute1,
          p_party_location_id        => p_definfo.defaulting_attribute2,
          p_entity_code              => p_definfo.entity_code,
          p_event_class_code         => p_definfo.event_class_code,
          p_application_id           => p_definfo.application_id,
          p_internal_organization_id => p_definfo.internal_organization_id,
          p_ccid                     => p_definfo.account_ccid);
    END IF;

    p_definfo.x_tax_classification_code := p_definfo.output_tax_classification_code;


  ELSIF p_definfo.application_id = 275 THEN

    l_appl_short_name := 'PA';
    --
    -- PA product
    --

    ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_pa_default_classification (
          p_project_id               => p_definfo.defaulting_attribute1,
          p_project_customer_id      => p_definfo.defaulting_attribute2,
          p_ship_to_site_use_id      => p_definfo.ship_to_cust_acct_site_use_id,
          p_bill_to_site_use_id      => p_definfo.bill_to_cust_acct_site_use_id,
          p_set_of_books_id          => p_definfo.ledger_id,
          p_event_id                 => p_definfo.defaulting_attribute3,
          p_expenditure_item_id      => p_definfo.defaulting_attribute4,
          p_line_type                => p_definfo.defaulting_attribute5,
          p_request_id               => p_definfo.defaulting_attribute6,
          p_user_id                  => p_definfo.defaulting_attribute7,
          p_trx_date                 => p_definfo.trx_date,
          p_tax_classification_code  => p_definfo.output_tax_classification_code,
          p_ship_to_customer_id      => p_definfo.ship_third_pty_acct_id,
          p_bill_to_customer_id      => p_definfo.bill_third_pty_acct_id,
          p_application_id           => p_definfo.application_id,
          p_internal_organization_id => p_definfo.internal_organization_id);

    p_definfo.x_tax_classification_code := p_definfo.output_tax_classification_code;

  ELSE
    --
    -- unknown application id
    --
    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TAX_DEFAULT_PKG.get_default_tax_classification',
               'Invalid application_id to fetch default Tax Classification Code : '
               || TO_CHAR(p_definfo.application_id));
    END IF;

  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TAX_DEFAULT_PKG.get_default_tax_classification.END',
           'ZX_TAX_DEFAULT_PKG: get_default_tax_classification(-)'||
           ' tax class code: '||p_definfo.x_tax_classification_code);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    FND_MESSAGE.SET_NAME('ZX','ZX_UNEXPECTED_ERROR');
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_TAX_DEFAULT_PKG.get_default_tax_classification',
                p_error_buffer);
    END IF;

END get_default_tax_classification;

---------------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  map_parm_for_def_tax_classif
--
--  DESCRIPTION
--  This procedure maps products specific parameters to the columns
--  defined in default tax classification info record

-- Bug#4868489- This procedure is no longer used but keep
-- it here just for the mapping reference
--
--PROCEDURE map_parm_for_def_tax_classif(
--    p_definfo                IN OUT NOCOPY  DEFINFO%TYPE,
--    p_defaulting_attribute1  IN             VARCHAR2,
--    p_defaulting_attribute2  IN             VARCHAR2,
--    p_defaulting_attribute3  IN             VARCHAR2,
--    p_defaulting_attribute4  IN             VARCHAR2,
--    p_defaulting_attribute5  IN             VARCHAR2,
--    p_defaulting_attribute6  IN             VARCHAR2,
--    p_defaulting_attribute7  IN             VARCHAR2,
--    p_defaulting_attribute8  IN             VARCHAR2,
--    p_defaulting_attribute9  IN             VARCHAR2,
--    p_defaulting_attribute10 IN             VARCHAR2,
--    p_return_status             OUT NOCOPY  VARCHAR2,
--    p_error_buffer              OUT NOCOPY  VARCHAR2)
--IS
--BEGIN
--
--  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
--
--  IF (g_level_statement >= g_current_runtime_level ) THEN
--    FND_LOG.STRING(g_level_statement,
--                   'ZX.PLSQL.ZX_TAX_DEFAULT_PKG.map_parm_for_def_tax_classif.BEGIN',
--                   'ZX_TAX_DEFAULT_PKG: map_parm_for_def_tax_classif(+)');
--  END IF;
--
--  --
--  -- init error buffer and return status
--  --
--  p_return_status  := FND_API.G_RET_STS_SUCCESS;
--  p_error_buffer   := NULL;
--
--  --
--  -- map parameters for each product
--  --
--  IF p_definfo.application_id IN (200, 201, 230, 401) THEN
--    --
--    -- P2P
--    --
--    p_definfo.ship_to_loc_org_id            := p_defaulting_attribute1;
--    p_definfo.func_short_name               := p_defaulting_attribute2;
--    p_definfo.templ_tax_classification_code := p_defaulting_attribute3;
--
--  ELSIF p_definfo.application_id IN (222, 300, 660, 697) THEN
--    --
--    -- O2C
--    --
--    p_definfo.party_flag        := p_defaulting_attribute1;
--    p_definfo.party_location_id := p_defaulting_attribute2;
--    p_definfo.func_short_name   := p_defaulting_attribute3;
--
--  ELSIF p_definfo.application_id = 275 THEN
--    --
--    -- PA
--    --
--    p_definfo.project_id          := p_defaulting_attribute1;
--    p_definfo.project_customer_id := p_defaulting_attribute2;
--    p_definfo.event_id            := p_defaulting_attribute3;
--    p_definfo.expenditure_item_id := p_defaulting_attribute4;
--    p_definfo.line_type           := p_defaulting_attribute5;
--    p_definfo.request_id          := p_defaulting_attribute6;
--    p_definfo.user_id             := p_defaulting_attribute7;
--  END IF;
--
--  IF (g_level_statement >= g_current_runtime_level ) THEN
--    FND_LOG.STRING(g_level_statement,
--                   'ZX.PLSQL.ZX_TAX_DEFAULT_PKG.map_parm_for_def_tax_classif.END',
--                   'ZX_TAX_DEFAULT_PKG: map_parm_for_def_tax_classif(-)');
--  END IF;
--
--  EXCEPTION
--    WHEN OTHERS THEN
--    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
--
--    FND_MESSAGE.SET_NAME('ZX','ZX_UNEXPECTED_ERROR');
--    FND_MSG_PUB.Add;
--
--    IF (g_level_unexpected >= g_current_runtime_level ) THEN
--        FND_LOG.STRING(g_level_unexpected,
--                      'ZX.PLSQL.ZX_TAX_DEFAULT_PKG.map_parm_for_def_tax_classif',
--                      p_error_buffer);
--    END IF;
--END map_parm_for_def_tax_classif;

END ZX_TAX_DEFAULT_PKG;

/
