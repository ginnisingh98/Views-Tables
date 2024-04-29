--------------------------------------------------------
--  DDL for Package Body ZX_GLOBAL_STRUCTURES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_GLOBAL_STRUCTURES_PKG" AS
/* $Header: zxifgblparampkgb.pls 120.27.12010000.2 2009/10/12 18:40:25 tsen ship $ */

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'ZX_GLOBAL_STRUCTURES_PKG';
G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME           CONSTANT VARCHAR2(80) := 'ZX.PLSQL.ZX_GLOBAL_STRUCTURES_PKG.';

  PROCEDURE init_tax_regime_tbl IS
  BEGIN
    ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl.DELETE;
  END init_tax_regime_tbl;

  PROCEDURE init_detail_tax_regime_tbl IS
  BEGIN
    ZX_GLOBAL_STRUCTURES_PKG.detail_tax_regime_tbl.DELETE;
  END init_detail_tax_regime_tbl;

  PROCEDURE init_trx_line_app_regime_tbl IS
    l_api_name         CONSTANT VARCHAR2(30):= 'INIT_TRX_LINE_APP_REGIME_TBL';

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
    END IF;

    ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.APPLICATION_ID.delete;
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.ENTITY_CODE.delete;
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.EVENT_CLASS_CODE.delete;
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.TRX_ID.delete;
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.TRX_LINE_ID.delete;
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.TRX_LEVEL_TYPE.delete;
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.TAX_REGIME_CODE.delete;
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.TAX_REGIME_ID.delete;
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.TAX_PROVIDER_ID.delete;
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.ALLOW_TAX_CALCULATION_FLAG.delete;
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
    END IF;

  END init_trx_line_app_regime_tbl;

  PROCEDURE init_trx_headers_gt IS
  BEGIN
    delete from ZX_TRX_HEADERS_GT;
  END;

  PROCEDURE  get_product_options_info
                      (p_application_id IN NUMBER,
                       p_org_id         IN NUMBER,
                       x_product_options_rec OUT NOCOPY zx_product_options_rec_type,
                       x_return_status       OUT NOCOPY VARCHAR2) is

    l_tbl_index binary_integer;
    Cursor c_product_options(c_application_id IN NUMBER,
                             c_org_id         IN NUMBER)
    is
    select
           APPLICATION_ID,
           ORG_ID,
           TAX_METHOD_CODE,
           DEF_OPTION_HIER_1_CODE,
           DEF_OPTION_HIER_2_CODE,
           DEF_OPTION_HIER_3_CODE,
           DEF_OPTION_HIER_4_CODE,
           DEF_OPTION_HIER_5_CODE,
           DEF_OPTION_HIER_6_CODE,
           DEF_OPTION_HIER_7_CODE,
           TAX_CLASSIFICATION_CODE,
           INCLUSIVE_TAX_USED_FLAG,
           TAX_USE_CUSTOMER_EXEMPT_FLAG,
           TAX_USE_PRODUCT_EXEMPT_FLAG,
           TAX_USE_LOC_EXC_RATE_FLAG,
           TAX_ALLOW_COMPOUND_FLAG,
           USE_TAX_CLASSIFICATION_FLAG,
           ALLOW_TAX_ROUNDING_OVRD_FLAG,
           HOME_COUNTRY_DEFAULT_FLAG,
           TAX_ROUNDING_RULE,
           TAX_PRECISION,
           TAX_MINIMUM_ACCOUNTABLE_UNIT,
           TAX_CURRENCY_CODE
    from zx_product_options_all
    where
         application_id = c_application_id
     and org_id = c_org_id;
  BEGIN

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||'get_product_options_info'||'.BEGIN','ZX_GLOBAL_STRUCTURES_PKG: get_product_options_info()+ ');
     END IF;

     l_tbl_index :=  dbms_utility.get_hash_value(to_char(p_application_id)||to_char(p_org_id), 1, 8192);
     IF g_zx_proudct_options_tbl.exists(l_tbl_index) then
           x_product_options_rec := g_zx_proudct_options_tbl(l_tbl_index);

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||'get_product_options_info','Found product options info in cache.');
           END IF;
     ELSE
        BEGIN
           open c_product_options(p_application_id, p_org_id);
           fetch c_product_options into x_product_options_rec;
           g_zx_proudct_options_tbl(l_tbl_index) := x_product_options_rec;
           close c_product_options;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               IF c_product_options%isopen then
                    close c_product_options;
               END IF;
               IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                     FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||'get_product_options_info','Exception:No Data Found');
               END IF;
        END;
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||'get_product_options_info'||'.END','ZX_GLOBAL_STRUCTURES_PKG: get_product_options_info()-');
     END IF;

  EXCEPTION
     when others then
        If c_product_options%isopen then
            close c_product_options;
        end if;
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||'get_product_options_info','Exception: '||SQLCODE||' ; '||SQLERRM);
        END IF;
  END get_product_options_info;

  -- bug 8969799:
  --
  PROCEDURE get_product_options_info(
    p_application_id         IN            NUMBER,
    p_org_id                 IN            NUMBER,
    p_event_class_mapping_id IN            zx_lines_det_factors.EVENT_CLASS_MAPPING_ID%TYPE,
    x_product_options_rec       OUT NOCOPY zx_product_options_rec_type,
    x_return_status             OUT NOCOPY VARCHAR2) is

    l_tbl_index binary_integer;

    CURSOR c_product_options(c_application_id         IN NUMBER,
                             c_org_id                 IN NUMBER,
                             c_event_class_mapping_id IN NUMBER) IS
    SELECT APPLICATION_ID,
           ORG_ID,
           TAX_METHOD_CODE,
           DEF_OPTION_HIER_1_CODE,
           DEF_OPTION_HIER_2_CODE,
           DEF_OPTION_HIER_3_CODE,
           DEF_OPTION_HIER_4_CODE,
           DEF_OPTION_HIER_5_CODE,
           DEF_OPTION_HIER_6_CODE,
           DEF_OPTION_HIER_7_CODE,
           TAX_CLASSIFICATION_CODE,
           INCLUSIVE_TAX_USED_FLAG,
           TAX_USE_CUSTOMER_EXEMPT_FLAG,
           TAX_USE_PRODUCT_EXEMPT_FLAG,
           TAX_USE_LOC_EXC_RATE_FLAG,
           TAX_ALLOW_COMPOUND_FLAG,
           USE_TAX_CLASSIFICATION_FLAG,
           ALLOW_TAX_ROUNDING_OVRD_FLAG,
           HOME_COUNTRY_DEFAULT_FLAG,
           TAX_ROUNDING_RULE,
           TAX_PRECISION,
           TAX_MINIMUM_ACCOUNTABLE_UNIT,
           TAX_CURRENCY_CODE
      FROM zx_product_options_all
     WHERE application_id = c_application_id
       AND org_id = c_org_id
       AND (event_class_mapping_id IS NULL OR
            event_class_mapping_id = c_event_class_mapping_id
            )
     ORDER BY event_class_mapping_id NULLS LAST;

  BEGIN

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||'get_product_options_info'||'.BEGIN','ZX_GLOBAL_STRUCTURES_PKG: get_product_options_info()+ ');
     END IF;

     IF p_event_class_mapping_id IS NOT NULL THEN
       l_tbl_index :=  dbms_utility.get_hash_value(
                       TO_CHAR(p_application_id) || TO_CHAR(p_org_id) || '-' ||
                       TO_CHAR(p_event_class_mapping_id),
                       1, 8192);
     ELSE
       l_tbl_index :=  dbms_utility.get_hash_value(
                       TO_CHAR(p_application_id) || TO_CHAR(p_org_id),
                       1, 8192);
     END IF;

     IF g_zx_proudct_options_tbl.exists(l_tbl_index) then
           x_product_options_rec := g_zx_proudct_options_tbl(l_tbl_index);

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||'get_product_options_info','Found product options info in cache.');
           END IF;
     ELSE
        BEGIN
           open c_product_options(p_application_id, p_org_id, p_event_class_mapping_id);
           fetch c_product_options into x_product_options_rec;
           g_zx_proudct_options_tbl(l_tbl_index) := x_product_options_rec;
           close c_product_options;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               IF c_product_options%isopen then
                    close c_product_options;
               END IF;
               IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                     FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||'get_product_options_info','Exception:No Data Found');
               END IF;
        END;
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||'get_product_options_info'||'.END','ZX_GLOBAL_STRUCTURES_PKG: get_product_options_info()-');
     END IF;

  EXCEPTION
     when others then
        If c_product_options%isopen then
            close c_product_options;
        end if;
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||'get_product_options_info','Exception: '||SQLCODE||' ; '||SQLERRM);
        END IF;
  END get_product_options_info;

  PROCEDURE get_regimes_usages_info(p_tax_regime_code IN 	VARCHAR2,
                                   p_first_pty_org_id IN 	NUMBER,
                                   x_regime_usage_id  OUT NOCOPY NUMBER,
                                   x_return_status    OUT NOCOPY VARCHAR2) is

    l_tbl_index binary_integer;
    l_tax_regime_id zx_regimes_b.tax_regime_id%TYPE;
    l_regime_usage_id NUMBER;

    CURSOR c_regimes_usasges (c_tax_Regime_code IN NUMBER,
                              c_first_pty_org_id IN NUMBER)
    IS
    SELECT tax_regime_id, regime_usage_id
    FROM   zx_regimes_usages
    WHERE  tax_regime_code = c_tax_regime_code
    AND    first_pty_org_id = c_first_pty_org_id;


  BEGIN

     --IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     --     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||'get_regimes_usages_info'||'.BEGIN','ZX_GLOBAL_STRUCTURES_PKG: get_regimes_usages_info()+ ');
     --END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_tbl_index :=  dbms_utility.get_hash_value(p_tax_regime_code||to_char(p_first_pty_org_id), 1, 8192);

    IF G_REGIMES_USAGES_TBL.exists(l_tbl_index) then
        x_regime_usage_id := G_REGIMES_USAGES_TBL(l_tbl_index).regime_usage_id;
    ELSE
        open c_regimes_usasges(p_tax_regime_code, p_first_pty_org_id);
        fetch c_regimes_usasges into l_tax_regime_id, l_regime_usage_id;
        close c_regimes_usasges;

        G_REGIMES_USAGES_TBL(l_tbl_index).tax_regime_code := p_tax_regime_code;
        G_REGIMES_USAGES_TBL(l_tbl_index).tax_regime_id := l_tax_regime_id;
        G_REGIMES_USAGES_TBL(l_tbl_index).first_pty_org_id := p_first_pty_org_id;
        G_REGIMES_USAGES_TBL(l_tbl_index).regime_usage_id := l_regime_usage_id;
        x_regime_usage_id := l_regime_usage_id;

    END IF;

    -- IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    --      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||'get_regimes_usages_info'||'.END','ZX_GLOBAL_STRUCTURES_PKG: get_regimes_usages_info()- ');
    -- END IF;

  EXCEPTION
      WHEN OTHERS THEN
          IF c_regimes_usasges%ISOPEN then
              close c_regimes_usasges;
          END IF;

          IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||'get_regimes_usages_info','Exception in ZX_GLOBAL_STRUCTURES_PKG.get_regimes_usages_info:'
                            ||SQLCODE||' ; '||SQLERRM);
          END IF;
  END get_regimes_usages_info;


  PROCEDURE init_trx_lines_gt IS
  BEGIN
    delete from ZX_TRANSACTION_LINES_GT;
  END;

  PROCEDURE delete_trx_line_dist_tbl IS
  BEGIN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||'DELETE_TRX_LINE_DIST_TBL'||'.BEGIN','ZX_GLOBAL_STRUCTURES_PKG: delete_trx_line_dist_tbl()+');
        END IF;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INTERNAL_ORGANIZATION_ID.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLICATION_ID.DELETE                ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ENTITY_CODE.DELETE                   ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EVENT_CLASS_CODE.DELETE              ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EVENT_TYPE_CODE.DELETE               ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID.DELETE                        ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LEVEL_TYPE.DELETE                ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_ID.DELETE                   ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_LEVEL_ACTION.DELETE             ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_CLASS.DELETE                    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_DATE.DELETE                      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_DOC_REVISION.DELETE              ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LEDGER_ID.DELETE                     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_CURRENCY_CODE.DELETE             ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_DATE.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_RATE.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_TYPE.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.MINIMUM_ACCOUNTABLE_UNIT.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRECISION.DELETE                     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_CURRENCY_CODE.DELETE        ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_CURRENCY_CONV_DATE.DELETE   ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_CURRENCY_CONV_RATE.DELETE   ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_CURRENCY_CONV_TYPE.DELETE   ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_MAU.DELETE                  ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_PRECISION.DELETE            ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_SHIPPING_DATE.DELETE             ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_RECEIPT_DATE.DELETE              ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LEGAL_ENTITY_ID.DELETE               ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_SHIP_TO_PARTY_ID.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_SHIP_FROM_PARTY_ID.DELETE   ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_BILL_TO_PARTY_ID.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_BILL_FROM_PARTY_ID.DELETE   ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_SHIP_TO_PARTY_SITE_ID.DELETE    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_SHIP_FROM_PARTY_SITE_ID.DELETE  ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_BILL_TO_PARTY_SITE_ID.DELETE    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_BILL_FROM_PARTY_SITE_ID.DELETE  ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ESTABLISHMENT_ID.DELETE              ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_TYPE.DELETE                 ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_DATE.DELETE                 ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_BUSINESS_CATEGORY.DELETE         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_INTENDED_USE.DELETE             ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.USER_DEFINED_FISC_CLASS.DELETE       ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_AMT.DELETE                      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_QUANTITY.DELETE             ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.UNIT_PRICE.DELETE                    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EXEMPT_CERTIFICATE_NUMBER.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EXEMPT_REASON.DELETE                 ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CASH_DISCOUNT.DELETE                 ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.VOLUME_DISCOUNT.DELETE               ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRADING_DISCOUNT.DELETE              ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRANSFER_CHARGE.DELETE               ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRANSPORTATION_CHARGE.DELETE         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INSURANCE_CHARGE.DELETE              ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OTHER_CHARGE.DELETE                  ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_ID.DELETE                    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_FISC_CLASSIFICATION.DELETE   ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_ORG_ID.DELETE                ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.UOM_CODE.DELETE                      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_TYPE.DELETE                  ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_CODE.DELETE                  ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_CATEGORY.DELETE              ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_SIC_CODE.DELETE                  ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.FOB_POINT.DELETE                     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_TO_PARTY_ID.DELETE              ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_FROM_PARTY_ID.DELETE            ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POA_PARTY_ID.DELETE                  ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POO_PARTY_ID.DELETE                  ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_TO_PARTY_ID.DELETE              ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_FROM_PARTY_ID.DELETE            ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.MERCHANT_PARTY_ID.DELETE             ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_TO_PARTY_SITE_ID.DELETE         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_FROM_PARTY_SITE_ID.DELETE       ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POA_PARTY_SITE_ID.DELETE             ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POO_PARTY_SITE_ID.DELETE             ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_TO_PARTY_SITE_ID.DELETE         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_FROM_PARTY_SITE_ID.DELETE       ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_TO_LOCATION_ID.DELETE           ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_FROM_LOCATION_ID.DELETE         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POA_LOCATION_ID.DELETE               ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POO_LOCATION_ID.DELETE               ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_TO_LOCATION_ID.DELETE           ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_FROM_LOCATION_ID.DELETE         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ACCOUNT_CCID.DELETE                  ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ACCOUNT_STRING.DELETE                ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.MERCHANT_PARTY_COUNTRY.DELETE        ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RECEIVABLES_TRX_TYPE_ID.DELETE       ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_APPLICATION_ID.DELETE        ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_ENTITY_CODE.DELETE           ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_EVENT_CLASS_CODE.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_TRX_ID.DELETE                ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY1.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY2.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY3.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY4.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY5.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY6.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_LINE_ID.DELETE               ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY1.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY2.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY3.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY4.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY5.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY6.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_LINE_QUANTITY.DELETE         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RELATED_DOC_APPLICATION_ID.DELETE    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RELATED_DOC_ENTITY_CODE.DELETE       ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RELATED_DOC_EVENT_CLASS_CODE.DELETE  ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RELATED_DOC_TRX_ID.DELETE            ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REL_DOC_HDR_TRX_USER_KEY1.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REL_DOC_HDR_TRX_USER_KEY2.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REL_DOC_HDR_TRX_USER_KEY3.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REL_DOC_HDR_TRX_USER_KEY4.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REL_DOC_HDR_TRX_USER_KEY5.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REL_DOC_HDR_TRX_USER_KEY6.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RELATED_DOC_NUMBER.DELETE            ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RELATED_DOC_DATE.DELETE              ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_FROM_APPLICATION_ID.DELETE   ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_FROM_ENTITY_CODE.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_FROM_EVENT_CLASS_CODE.DELETE ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_FROM_TRX_ID.DELETE           ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY1.DELETE    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY2.DELETE    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY3.DELETE    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY4.DELETE    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY5.DELETE    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY6.DELETE    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_FROM_LINE_ID.DELETE          ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_FROM_TRX_NUMBER.DELETE       ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY1.DELETE    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY2.DELETE    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY3.DELETE    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY4.DELETE    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY5.DELETE    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY6.DELETE    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJUSTED_DOC_APPLICATION_ID.DELETE   ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJUSTED_DOC_ENTITY_CODE.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJUSTED_DOC_EVENT_CLASS_CODE.DELETE ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJUSTED_DOC_TRX_ID.DELETE           ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY1.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY2.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY3.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY4.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY5.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY6.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJUSTED_DOC_LINE_ID.DELETE          ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY1.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY2.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY3.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY4.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY5.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY6.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJUSTED_DOC_NUMBER.DELETE           ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJUSTED_DOC_DATE.DELETE             ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_TO_APPLICATION_ID.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_TO_ENTITY_CODE.DELETE        ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_TO_EVENT_CLASS_CODE.DELETE   ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_TO_TRX_ID.DELETE             ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY1.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY2.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY3.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY4.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY5.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY6.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_TO_TRX_LINE_ID.DELETE        ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY1.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY2.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY3.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY4.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY5.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY6.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID_LEVEL2.DELETE                 ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID_LEVEL3.DELETE                 ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID_LEVEL4.DELETE                 ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID_LEVEL5.DELETE                 ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID_LEVEL6.DELETE                 ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_TRX_USER_KEY1.DELETE             ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_TRX_USER_KEY2.DELETE             ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_TRX_USER_KEY3.DELETE             ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_TRX_USER_KEY4.DELETE             ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_TRX_USER_KEY5.DELETE             ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_TRX_USER_KEY6.DELETE             ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_TRX_USER_KEY1.DELETE            ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_TRX_USER_KEY2.DELETE            ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_TRX_USER_KEY3.DELETE            ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_TRX_USER_KEY4.DELETE            ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_TRX_USER_KEY5.DELETE            ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_TRX_USER_KEY6.DELETE            ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_NUMBER.DELETE                    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_DESCRIPTION.DELETE               ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_NUMBER.DELETE               ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_DESCRIPTION.DELETE          ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_DESCRIPTION.DELETE           ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_WAYBILL_NUMBER.DELETE            ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_COMMUNICATED_DATE.DELETE         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_GL_DATE.DELETE              ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BATCH_SOURCE_ID.DELETE               ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BATCH_SOURCE_NAME.DELETE             ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DOC_SEQ_ID.DELETE                    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DOC_SEQ_NAME.DELETE                  ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DOC_SEQ_VALUE.DELETE                 ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_DUE_DATE.DELETE                  ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_TYPE_DESCRIPTION.DELETE          ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.MERCHANT_PARTY_NAME.DELETE           ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.MERCHANT_PARTY_DOCUMENT_NUMBER.DELETE;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.MERCHANT_PARTY_REFERENCE.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.MERCHANT_PARTY_TAXPAYER_ID.DELETE    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.MERCHANT_PARTY_TAX_REG_NUMBER.DELETE ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PAYING_PARTY_ID.DELETE               ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OWN_HQ_PARTY_ID.DELETE               ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRADING_HQ_PARTY_ID.DELETE           ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POI_PARTY_ID.DELETE                  ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POD_PARTY_ID.DELETE                  ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TITLE_TRANSFER_PARTY_ID.DELETE       ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PAYING_PARTY_SITE_ID.DELETE          ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OWN_HQ_PARTY_SITE_ID.DELETE          ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRADING_HQ_PARTY_SITE_ID.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POI_PARTY_SITE_ID.DELETE             ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POD_PARTY_SITE_ID.DELETE             ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TITLE_TRANSFER_PARTY_SITE_ID.DELETE  ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PAYING_LOCATION_ID.DELETE            ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OWN_HQ_LOCATION_ID.DELETE            ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRADING_HQ_LOCATION_ID.DELETE        ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POC_LOCATION_ID.DELETE               ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POI_LOCATION_ID.DELETE               ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POD_LOCATION_ID.DELETE               ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TITLE_TRANSFER_LOCATION_ID.DELETE    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ASSESSABLE_VALUE.DELETE              ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ASSET_FLAG.DELETE                    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ASSET_NUMBER.DELETE                  ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ASSET_ACCUM_DEPRECIATION.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ASSET_TYPE.DELETE                    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ASSET_COST.DELETE                    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.NUMERIC1.DELETE                      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.NUMERIC2.DELETE                      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.NUMERIC3.DELETE                      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.NUMERIC4.DELETE                      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.NUMERIC5.DELETE                      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.NUMERIC6.DELETE                      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.NUMERIC7.DELETE                      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.NUMERIC8.DELETE                      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.NUMERIC9.DELETE                      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.NUMERIC10.DELETE                     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CHAR1.DELETE                         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CHAR2.DELETE                         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CHAR3.DELETE                         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CHAR4.DELETE                         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CHAR5.DELETE                         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CHAR6.DELETE                         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CHAR7.DELETE                         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CHAR8.DELETE                         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CHAR9.DELETE                         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CHAR10.DELETE                        ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DATE1.DELETE                         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DATE2.DELETE                         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DATE3.DELETE                         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DATE4.DELETE                         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DATE5.DELETE                         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DATE6.DELETE                         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DATE7.DELETE                         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DATE8.DELETE                         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DATE9.DELETE                         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DATE10.DELETE                        ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.FIRST_PTY_ORG_ID.DELETE              ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_EVENT_CLASS_CODE.DELETE          ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_EVENT_TYPE_CODE.DELETE           ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DOC_EVENT_STATUS.DELETE              ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RDNG_SHIP_TO_PTY_TX_PROF_ID.DELETE   ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RDNG_SHIP_FROM_PTY_TX_PROF_ID.DELETE ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RDNG_BILL_TO_PTY_TX_PROF_ID.DELETE   ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RDNG_BILL_FROM_PTY_TX_PROF_ID.DELETE ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RDNG_SHIP_TO_PTY_TX_P_ST_ID.DELETE   ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RDNG_SHIP_FROM_PTY_TX_P_ST_ID.DELETE ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RDNG_BILL_TO_PTY_TX_P_ST_ID.DELETE   ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RDNG_BILL_FROM_PTY_TX_P_ST_ID.DELETE ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_TO_PARTY_TAX_PROF_ID.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_FROM_PARTY_TAX_PROF_ID.DELETE   ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POA_PARTY_TAX_PROF_ID.DELETE         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POO_PARTY_TAX_PROF_ID.DELETE         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PAYING_PARTY_TAX_PROF_ID.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OWN_HQ_PARTY_TAX_PROF_ID.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRADING_HQ_PARTY_TAX_PROF_ID.DELETE  ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POI_PARTY_TAX_PROF_ID.DELETE         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POD_PARTY_TAX_PROF_ID.DELETE         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_TO_PARTY_TAX_PROF_ID.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_FROM_PARTY_TAX_PROF_ID.DELETE   ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TITLE_TRANS_PARTY_TAX_PROF_ID.DELETE ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_TO_SITE_TAX_PROF_ID.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_FROM_SITE_TAX_PROF_ID.DELETE    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POA_SITE_TAX_PROF_ID.DELETE          ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POO_SITE_TAX_PROF_ID.DELETE          ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PAYING_SITE_TAX_PROF_ID.DELETE       ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OWN_HQ_SITE_TAX_PROF_ID.DELETE       ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRADING_HQ_SITE_TAX_PROF_ID.DELETE   ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POI_SITE_TAX_PROF_ID.DELETE          ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POD_SITE_TAX_PROF_ID.DELETE          ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_TO_SITE_TAX_PROF_ID.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_FROM_SITE_TAX_PROF_ID.DELETE    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TITLE_TRANS_SITE_TAX_PROF_ID.DELETE  ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.MERCHANT_PARTY_TAX_PROF_ID.DELETE    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HQ_ESTB_PARTY_TAX_PROF_ID.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DOCUMENT_SUB_TYPE.DELETE             ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SUPPLIER_TAX_INVOICE_NUMBER.DELETE   ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SUPPLIER_TAX_INVOICE_DATE.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SUPPLIER_EXCHANGE_RATE.DELETE        ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_INVOICE_DATE.DELETE              ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_INVOICE_NUMBER.DELETE            ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_AMT_INCLUDES_TAX_FLAG.DELETE    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.QUOTE_FLAG.DELETE                    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULT_TAXATION_COUNTRY.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HISTORICAL_FLAG.DELETE               ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INTERNAL_ORG_LOCATION_ID.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CTRL_HDR_TX_APPL_FLAG.DELETE         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CTRL_TOTAL_HDR_TX_AMT.DELETE         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CTRL_TOTAL_LINE_TX_AMT.DELETE        ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DIST_LEVEL_ACTION.DELETE             ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_FROM_TAX_DIST_ID.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJUSTED_DOC_TAX_DIST_ID.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TASK_ID.DELETE                       ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.AWARD_ID.DELETE                      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PROJECT_ID.DELETE                    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EXPENDITURE_TYPE.DELETE              ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EXPENDITURE_ORGANIZATION_ID.DELETE   ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EXPENDITURE_ITEM_DATE.DELETE         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_DIST_AMT.DELETE             ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_DIST_QUANTITY.DELETE        ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_CURR_CONV_RATE.DELETE        ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ITEM_DIST_NUMBER.DELETE              ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_DIST_ID.DELETE               ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_DIST_TAX_AMT.DELETE         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_DIST_ID.DELETE              ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DIST_TRX_USER_KEY1.DELETE            ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DIST_TRX_USER_KEY2.DELETE            ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DIST_TRX_USER_KEY3.DELETE            ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DIST_TRX_USER_KEY4.DELETE            ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DIST_TRX_USER_KEY5.DELETE            ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DIST_TRX_USER_KEY6.DELETE            ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_FROM_DIST_ID.DELETE          ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_DST_TRX_USER_KEY1.DELETE    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_DST_TRX_USER_KEY2.DELETE    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_DST_TRX_USER_KEY3.DELETE    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_DST_TRX_USER_KEY4.DELETE    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_DST_TRX_USER_KEY5.DELETE    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_DST_TRX_USER_KEY6.DELETE    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJUSTED_DOC_DIST_ID.DELETE          ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_DST_TRX_USER_KEY1.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_DST_TRX_USER_KEY2.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_DST_TRX_USER_KEY3.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_DST_TRX_USER_KEY4.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_DST_TRX_USER_KEY5.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_DST_TRX_USER_KEY6.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INPUT_TAX_CLASSIFICATION_CODE.DELETE ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OUTPUT_TAX_CLASSIFICATION_CODE.DELETE;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PORT_OF_ENTRY_CODE.DELETE            ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_REPORTING_FLAG.DELETE            ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_AMT_INCLUDED_FLAG.DELETE         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.COMPOUNDING_TAX_FLAG.DELETE          ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PROVNL_TAX_DETERMINATION_DATE.DELETE ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_THIRD_PTY_ACCT_SITE_ID.DELETE   ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_THIRD_PTY_ACCT_SITE_ID.DELETE   ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_TO_CUST_ACCT_SITE_USE_ID.DELETE ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_TO_CUST_ACCT_SITE_USE_ID.DELETE ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_THIRD_PTY_ACCT_ID.DELETE        ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_THIRD_PTY_ACCT_ID.DELETE        ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SOURCE_APPLICATION_ID.DELETE         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SOURCE_ENTITY_CODE.DELETE            ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SOURCE_EVENT_CLASS_CODE.DELETE       ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SOURCE_TRX_ID.DELETE                 ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SOURCE_LINE_ID.DELETE                ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SOURCE_TRX_LEVEL_TYPE.DELETE         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INSERT_UPDATE_FLAG.DELETE            ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_TO_TRX_NUMBER.DELETE         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.START_EXPENSE_DATE.DELETE            ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_BATCH_ID.DELETE                  ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RECORD_TYPE_CODE.DELETE              ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_TRX_LEVEL_TYPE.DELETE        ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_FROM_TRX_LEVEL_TYPE.DELETE   ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_TO_TRX_LEVEL_TYPE.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJUSTED_DOC_TRX_LEVEL_TYPE.DELETE   ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE1.DELETE         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE2.DELETE         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE3.DELETE         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE4.DELETE         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE5.DELETE         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE6.DELETE         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE7.DELETE         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE8.DELETE         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE9.DELETE         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE10.DELETE        ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_PROCESSING_COMPLETED_FLAG.DELETE ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLICATION_DOC_STATUS.DELETE        ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OVERRIDING_RECOVERY_RATE.DELETE      ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_CALCULATION_DONE_FLAG.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SOURCE_TAX_LINE_ID.DELETE            ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REVERSED_APPLN_ID.DELETE             ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REVERSED_ENTITY_CODE.DELETE          ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REVERSED_EVNT_CLS_CODE.DELETE        ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REVERSED_TRX_ID.DELETE               ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REVERSED_TRX_LEVEL_TYPE.DELETE       ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REVERSED_TRX_LINE_ID.DELETE          ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EXEMPTION_CONTROL_FLAG.DELETE        ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EXEMPT_REASON_CODE.DELETE            ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INTERFACE_ENTITY_CODE.DELETE         ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INTERFACE_LINE_ID.DELETE             ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HISTORICAL_TAX_CODE_ID.DELETE        ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.USER_UPD_DET_FACTORS_FLAG.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ICX_SESSION_ID.DELETE                ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_SHIP_THIRD_PTY_ACCT_ST_ID.DELETE ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_BILL_THIRD_PTY_ACCT_ST_ID.DELETE ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_BILL_TO_CST_ACCT_ST_USE_ID.DELETE;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_SHIP_TO_CST_ACCT_ST_USE_ID.DELETE;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_SHIP_THIRD_PTY_ACCT_ID.DELETE    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_BILL_THIRD_PTY_ACCT_ID.DELETE    ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_RECEIVABLES_TRX_TYPE_ID.DELETE   ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.GLOBAL_ATTRIBUTE1.DELETE             ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.GLOBAL_ATTRIBUTE_CATEGORY.DELETE     ;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TOTAL_INC_TAX_AMT.DELETE     ;
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||'DELETE_TRX_LINE_DIST_TBL'||'.END','ZX_GLOBAL_STRUCTURES_PKG: delete_trx_line_dist_tbl()-');
        END IF;
 END delete_trx_line_dist_tbl;

  PROCEDURE init_trx_line_dist_tbl(l_trx_line_index IN NUMBER) IS
  BEGIN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||'INIT_TRX_LINE_DIST_TBL'||'.BEGIN','ZX_GLOBAL_STRUCTURES_PKG: init_trx_line_dist_tbl()+');
        END IF;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INTERNAL_ORGANIZATION_ID(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLICATION_ID(l_trx_line_index)                := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ENTITY_CODE(l_trx_line_index)                   := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EVENT_CLASS_CODE(l_trx_line_index)              := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EVENT_TYPE_CODE(l_trx_line_index)               := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID(l_trx_line_index)                        := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LEVEL_TYPE(l_trx_line_index)                := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_ID(l_trx_line_index)                   := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_LEVEL_ACTION(l_trx_line_index)             := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_CLASS(l_trx_line_index)                    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_DATE(l_trx_line_index)                      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_DOC_REVISION(l_trx_line_index)              := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LEDGER_ID(l_trx_line_index)                     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_CURRENCY_CODE(l_trx_line_index)             := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_DATE(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_RATE(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_TYPE(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.MINIMUM_ACCOUNTABLE_UNIT(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRECISION(l_trx_line_index)                     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_CURRENCY_CODE(l_trx_line_index)        := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_CURRENCY_CONV_DATE(l_trx_line_index)   := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_CURRENCY_CONV_RATE(l_trx_line_index)   := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_CURRENCY_CONV_TYPE(l_trx_line_index)   := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_MAU(l_trx_line_index)                  := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_PRECISION(l_trx_line_index)            := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_SHIPPING_DATE(l_trx_line_index)             := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_RECEIPT_DATE(l_trx_line_index)              := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LEGAL_ENTITY_ID(l_trx_line_index)               := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_SHIP_TO_PARTY_ID(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_SHIP_FROM_PARTY_ID(l_trx_line_index)   := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_BILL_TO_PARTY_ID(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_BILL_FROM_PARTY_ID(l_trx_line_index)   := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_SHIP_TO_PARTY_SITE_ID(l_trx_line_index)    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_SHIP_FROM_PARTY_SITE_ID(l_trx_line_index)  := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_BILL_TO_PARTY_SITE_ID(l_trx_line_index)    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_BILL_FROM_PARTY_SITE_ID(l_trx_line_index)  := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ESTABLISHMENT_ID(l_trx_line_index)              := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_TYPE(l_trx_line_index)                 := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_DATE(l_trx_line_index)                 := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_BUSINESS_CATEGORY(l_trx_line_index)         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_INTENDED_USE(l_trx_line_index)             := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.USER_DEFINED_FISC_CLASS(l_trx_line_index)       := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_AMT(l_trx_line_index)                      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_QUANTITY(l_trx_line_index)             := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.UNIT_PRICE(l_trx_line_index)                    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EXEMPT_CERTIFICATE_NUMBER(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EXEMPT_REASON(l_trx_line_index)                 := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CASH_DISCOUNT(l_trx_line_index)                 := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.VOLUME_DISCOUNT(l_trx_line_index)               := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRADING_DISCOUNT(l_trx_line_index)              := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRANSFER_CHARGE(l_trx_line_index)               := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRANSPORTATION_CHARGE(l_trx_line_index)         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INSURANCE_CHARGE(l_trx_line_index)              := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OTHER_CHARGE(l_trx_line_index)                  := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_ID(l_trx_line_index)                    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_FISC_CLASSIFICATION(l_trx_line_index)   := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_ORG_ID(l_trx_line_index)                := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.UOM_CODE(l_trx_line_index)                      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_TYPE(l_trx_line_index)                  := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_CODE(l_trx_line_index)                  := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_CATEGORY(l_trx_line_index)              := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_SIC_CODE(l_trx_line_index)                  := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.FOB_POINT(l_trx_line_index)                     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_TO_PARTY_ID(l_trx_line_index)              := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_FROM_PARTY_ID(l_trx_line_index)            := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POA_PARTY_ID(l_trx_line_index)                  := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POO_PARTY_ID(l_trx_line_index)                  := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_TO_PARTY_ID(l_trx_line_index)              := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_FROM_PARTY_ID(l_trx_line_index)            := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.MERCHANT_PARTY_ID(l_trx_line_index)             := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_TO_PARTY_SITE_ID(l_trx_line_index)         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_FROM_PARTY_SITE_ID(l_trx_line_index)       := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POA_PARTY_SITE_ID(l_trx_line_index)             := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POO_PARTY_SITE_ID(l_trx_line_index)             := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_TO_PARTY_SITE_ID(l_trx_line_index)         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_FROM_PARTY_SITE_ID(l_trx_line_index)       := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_TO_LOCATION_ID(l_trx_line_index)           := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_FROM_LOCATION_ID(l_trx_line_index)         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POA_LOCATION_ID(l_trx_line_index)               := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POO_LOCATION_ID(l_trx_line_index)               := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_TO_LOCATION_ID(l_trx_line_index)           := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_FROM_LOCATION_ID(l_trx_line_index)         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ACCOUNT_CCID(l_trx_line_index)                  := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ACCOUNT_STRING(l_trx_line_index)                := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.MERCHANT_PARTY_COUNTRY(l_trx_line_index)        := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RECEIVABLES_TRX_TYPE_ID(l_trx_line_index)       := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_APPLICATION_ID(l_trx_line_index)        := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_ENTITY_CODE(l_trx_line_index)           := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_EVENT_CLASS_CODE(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_TRX_ID(l_trx_line_index)                := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY1(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY2(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY3(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY4(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY5(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY6(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_LINE_ID(l_trx_line_index)               := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY1(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY2(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY3(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY4(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY5(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY6(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_LINE_QUANTITY(l_trx_line_index)         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RELATED_DOC_APPLICATION_ID(l_trx_line_index)    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RELATED_DOC_ENTITY_CODE(l_trx_line_index)       := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RELATED_DOC_EVENT_CLASS_CODE(l_trx_line_index)  := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RELATED_DOC_TRX_ID(l_trx_line_index)            := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REL_DOC_HDR_TRX_USER_KEY1(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REL_DOC_HDR_TRX_USER_KEY2(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REL_DOC_HDR_TRX_USER_KEY3(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REL_DOC_HDR_TRX_USER_KEY4(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REL_DOC_HDR_TRX_USER_KEY5(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REL_DOC_HDR_TRX_USER_KEY6(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RELATED_DOC_NUMBER(l_trx_line_index)            := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RELATED_DOC_DATE(l_trx_line_index)              := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_FROM_APPLICATION_ID(l_trx_line_index)   := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_FROM_ENTITY_CODE(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_FROM_EVENT_CLASS_CODE(l_trx_line_index) := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_FROM_TRX_ID(l_trx_line_index)           := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY1(l_trx_line_index)    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY2(l_trx_line_index)    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY3(l_trx_line_index)    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY4(l_trx_line_index)    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY5(l_trx_line_index)    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY6(l_trx_line_index)    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_FROM_LINE_ID(l_trx_line_index)          := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_FROM_TRX_NUMBER(l_trx_line_index)       := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY1(l_trx_line_index)    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY2(l_trx_line_index)    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY3(l_trx_line_index)    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY4(l_trx_line_index)    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY5(l_trx_line_index)    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY6(l_trx_line_index)    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJUSTED_DOC_APPLICATION_ID(l_trx_line_index)   := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJUSTED_DOC_ENTITY_CODE(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJUSTED_DOC_EVENT_CLASS_CODE(l_trx_line_index) := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJUSTED_DOC_TRX_ID(l_trx_line_index)           := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY1(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY2(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY3(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY4(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY5(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY6(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJUSTED_DOC_LINE_ID(l_trx_line_index)          := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY1(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY2(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY3(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY4(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY5(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY6(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJUSTED_DOC_NUMBER(l_trx_line_index)           := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJUSTED_DOC_DATE(l_trx_line_index)             := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_TO_APPLICATION_ID(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_TO_ENTITY_CODE(l_trx_line_index)        := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_TO_EVENT_CLASS_CODE(l_trx_line_index)   := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_TO_TRX_ID(l_trx_line_index)             := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY1(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY2(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY3(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY4(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY5(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY6(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_TO_TRX_LINE_ID(l_trx_line_index)        := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY1(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY2(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY3(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY4(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY5(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY6(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID_LEVEL2(l_trx_line_index)                 := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID_LEVEL3(l_trx_line_index)                 := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID_LEVEL4(l_trx_line_index)                 := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID_LEVEL5(l_trx_line_index)                 := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID_LEVEL6(l_trx_line_index)                 := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_TRX_USER_KEY1(l_trx_line_index)             := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_TRX_USER_KEY2(l_trx_line_index)             := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_TRX_USER_KEY3(l_trx_line_index)             := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_TRX_USER_KEY4(l_trx_line_index)             := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_TRX_USER_KEY5(l_trx_line_index)             := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_TRX_USER_KEY6(l_trx_line_index)             := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_TRX_USER_KEY1(l_trx_line_index)            := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_TRX_USER_KEY2(l_trx_line_index)            := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_TRX_USER_KEY3(l_trx_line_index)            := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_TRX_USER_KEY4(l_trx_line_index)            := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_TRX_USER_KEY5(l_trx_line_index)            := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_TRX_USER_KEY6(l_trx_line_index)            := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_NUMBER(l_trx_line_index)                    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_DESCRIPTION(l_trx_line_index)               := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_NUMBER(l_trx_line_index)               := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_DESCRIPTION(l_trx_line_index)          := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_DESCRIPTION(l_trx_line_index)           := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_WAYBILL_NUMBER(l_trx_line_index)            := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_COMMUNICATED_DATE(l_trx_line_index)         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_GL_DATE(l_trx_line_index)              := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BATCH_SOURCE_ID(l_trx_line_index)               := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BATCH_SOURCE_NAME(l_trx_line_index)             := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DOC_SEQ_ID(l_trx_line_index)                    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DOC_SEQ_NAME(l_trx_line_index)                  := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DOC_SEQ_VALUE(l_trx_line_index)                 := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_DUE_DATE(l_trx_line_index)                  := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_TYPE_DESCRIPTION(l_trx_line_index)          := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.MERCHANT_PARTY_NAME(l_trx_line_index)           := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.MERCHANT_PARTY_DOCUMENT_NUMBER(l_trx_line_index):= null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.MERCHANT_PARTY_REFERENCE(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.MERCHANT_PARTY_TAXPAYER_ID(l_trx_line_index)    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.MERCHANT_PARTY_TAX_REG_NUMBER(l_trx_line_index) := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PAYING_PARTY_ID(l_trx_line_index)               := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OWN_HQ_PARTY_ID(l_trx_line_index)               := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRADING_HQ_PARTY_ID(l_trx_line_index)           := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POI_PARTY_ID(l_trx_line_index)                  := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POD_PARTY_ID(l_trx_line_index)                  := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TITLE_TRANSFER_PARTY_ID(l_trx_line_index)       := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PAYING_PARTY_SITE_ID(l_trx_line_index)          := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OWN_HQ_PARTY_SITE_ID(l_trx_line_index)          := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRADING_HQ_PARTY_SITE_ID(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POI_PARTY_SITE_ID(l_trx_line_index)             := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POD_PARTY_SITE_ID(l_trx_line_index)             := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TITLE_TRANSFER_PARTY_SITE_ID(l_trx_line_index)  := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PAYING_LOCATION_ID(l_trx_line_index)            := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OWN_HQ_LOCATION_ID(l_trx_line_index)            := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRADING_HQ_LOCATION_ID(l_trx_line_index)        := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POC_LOCATION_ID(l_trx_line_index)               := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POI_LOCATION_ID(l_trx_line_index)               := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POD_LOCATION_ID(l_trx_line_index)               := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TITLE_TRANSFER_LOCATION_ID(l_trx_line_index)    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ASSESSABLE_VALUE(l_trx_line_index)              := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ASSET_FLAG(l_trx_line_index)                    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ASSET_NUMBER(l_trx_line_index)                  := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ASSET_ACCUM_DEPRECIATION(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ASSET_TYPE(l_trx_line_index)                    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ASSET_COST(l_trx_line_index)                    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.NUMERIC1(l_trx_line_index)                      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.NUMERIC2(l_trx_line_index)                      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.NUMERIC3(l_trx_line_index)                      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.NUMERIC4(l_trx_line_index)                      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.NUMERIC5(l_trx_line_index)                      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.NUMERIC6(l_trx_line_index)                      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.NUMERIC7(l_trx_line_index)                      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.NUMERIC8(l_trx_line_index)                      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.NUMERIC9(l_trx_line_index)                      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.NUMERIC10(l_trx_line_index)                     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CHAR1(l_trx_line_index)                         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CHAR2(l_trx_line_index)                         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CHAR3(l_trx_line_index)                         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CHAR4(l_trx_line_index)                         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CHAR5(l_trx_line_index)                         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CHAR6(l_trx_line_index)                         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CHAR7(l_trx_line_index)                         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CHAR8(l_trx_line_index)                         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CHAR9(l_trx_line_index)                         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CHAR10(l_trx_line_index)                        := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DATE1(l_trx_line_index)                         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DATE2(l_trx_line_index)                         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DATE3(l_trx_line_index)                         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DATE4(l_trx_line_index)                         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DATE5(l_trx_line_index)                         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DATE6(l_trx_line_index)                         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DATE7(l_trx_line_index)                         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DATE8(l_trx_line_index)                         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DATE9(l_trx_line_index)                         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DATE10(l_trx_line_index)                        := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.FIRST_PTY_ORG_ID(l_trx_line_index)              := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_EVENT_CLASS_CODE(l_trx_line_index)          := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_EVENT_TYPE_CODE(l_trx_line_index)           := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DOC_EVENT_STATUS(l_trx_line_index)              := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RDNG_SHIP_TO_PTY_TX_PROF_ID(l_trx_line_index)   := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RDNG_SHIP_FROM_PTY_TX_PROF_ID(l_trx_line_index) := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RDNG_BILL_TO_PTY_TX_PROF_ID(l_trx_line_index)   := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RDNG_BILL_FROM_PTY_TX_PROF_ID(l_trx_line_index) := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RDNG_SHIP_TO_PTY_TX_P_ST_ID(l_trx_line_index)   := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RDNG_SHIP_FROM_PTY_TX_P_ST_ID(l_trx_line_index) := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RDNG_BILL_TO_PTY_TX_P_ST_ID(l_trx_line_index)   := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RDNG_BILL_FROM_PTY_TX_P_ST_ID(l_trx_line_index) := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_TO_PARTY_TAX_PROF_ID(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_FROM_PARTY_TAX_PROF_ID(l_trx_line_index)   := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POA_PARTY_TAX_PROF_ID(l_trx_line_index)         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POO_PARTY_TAX_PROF_ID(l_trx_line_index)         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PAYING_PARTY_TAX_PROF_ID(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OWN_HQ_PARTY_TAX_PROF_ID(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRADING_HQ_PARTY_TAX_PROF_ID(l_trx_line_index)  := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POI_PARTY_TAX_PROF_ID(l_trx_line_index)         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POD_PARTY_TAX_PROF_ID(l_trx_line_index)         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_TO_PARTY_TAX_PROF_ID(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_FROM_PARTY_TAX_PROF_ID(l_trx_line_index)   := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TITLE_TRANS_PARTY_TAX_PROF_ID(l_trx_line_index) := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_TO_SITE_TAX_PROF_ID(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_FROM_SITE_TAX_PROF_ID(l_trx_line_index)    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POA_SITE_TAX_PROF_ID(l_trx_line_index)          := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POO_SITE_TAX_PROF_ID(l_trx_line_index)          := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PAYING_SITE_TAX_PROF_ID(l_trx_line_index)       := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OWN_HQ_SITE_TAX_PROF_ID(l_trx_line_index)       := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRADING_HQ_SITE_TAX_PROF_ID(l_trx_line_index)   := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POI_SITE_TAX_PROF_ID(l_trx_line_index)          := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POD_SITE_TAX_PROF_ID(l_trx_line_index)          := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_TO_SITE_TAX_PROF_ID(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_FROM_SITE_TAX_PROF_ID(l_trx_line_index)    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TITLE_TRANS_SITE_TAX_PROF_ID(l_trx_line_index)  := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.MERCHANT_PARTY_TAX_PROF_ID(l_trx_line_index)    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HQ_ESTB_PARTY_TAX_PROF_ID(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DOCUMENT_SUB_TYPE(l_trx_line_index)             := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SUPPLIER_TAX_INVOICE_NUMBER(l_trx_line_index)   := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SUPPLIER_TAX_INVOICE_DATE(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SUPPLIER_EXCHANGE_RATE(l_trx_line_index)        := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_INVOICE_DATE(l_trx_line_index)              := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_INVOICE_NUMBER(l_trx_line_index)            := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_AMT_INCLUDES_TAX_FLAG(l_trx_line_index)    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.QUOTE_FLAG(l_trx_line_index)                    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULT_TAXATION_COUNTRY(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HISTORICAL_FLAG(l_trx_line_index)               := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INTERNAL_ORG_LOCATION_ID(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CTRL_HDR_TX_APPL_FLAG(l_trx_line_index)         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CTRL_TOTAL_HDR_TX_AMT(l_trx_line_index)         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CTRL_TOTAL_LINE_TX_AMT(l_trx_line_index)        := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DIST_LEVEL_ACTION(l_trx_line_index)             := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_FROM_TAX_DIST_ID(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJUSTED_DOC_TAX_DIST_ID(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TASK_ID(l_trx_line_index)                       := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.AWARD_ID(l_trx_line_index)                      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PROJECT_ID(l_trx_line_index)                    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EXPENDITURE_TYPE(l_trx_line_index)              := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EXPENDITURE_ORGANIZATION_ID(l_trx_line_index)   := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EXPENDITURE_ITEM_DATE(l_trx_line_index)         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_DIST_AMT(l_trx_line_index)             := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_DIST_QUANTITY(l_trx_line_index)        := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_CURR_CONV_RATE(l_trx_line_index)        := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ITEM_DIST_NUMBER(l_trx_line_index)              := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_DIST_ID(l_trx_line_index)               := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_DIST_TAX_AMT(l_trx_line_index)         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_DIST_ID(l_trx_line_index)              := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DIST_TRX_USER_KEY1(l_trx_line_index)            := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DIST_TRX_USER_KEY2(l_trx_line_index)            := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DIST_TRX_USER_KEY3(l_trx_line_index)            := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DIST_TRX_USER_KEY4(l_trx_line_index)            := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DIST_TRX_USER_KEY5(l_trx_line_index)            := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DIST_TRX_USER_KEY6(l_trx_line_index)            := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_FROM_DIST_ID(l_trx_line_index)          := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_DST_TRX_USER_KEY1(l_trx_line_index)    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_DST_TRX_USER_KEY2(l_trx_line_index)    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_DST_TRX_USER_KEY3(l_trx_line_index)    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_DST_TRX_USER_KEY4(l_trx_line_index)    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_DST_TRX_USER_KEY5(l_trx_line_index)    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_DST_TRX_USER_KEY6(l_trx_line_index)    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJUSTED_DOC_DIST_ID(l_trx_line_index)          := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_DST_TRX_USER_KEY1(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_DST_TRX_USER_KEY2(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_DST_TRX_USER_KEY3(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_DST_TRX_USER_KEY4(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_DST_TRX_USER_KEY5(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_DST_TRX_USER_KEY6(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INPUT_TAX_CLASSIFICATION_CODE(l_trx_line_index) := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OUTPUT_TAX_CLASSIFICATION_CODE(l_trx_line_index):= null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PORT_OF_ENTRY_CODE(l_trx_line_index)            := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_REPORTING_FLAG(l_trx_line_index)            := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_AMT_INCLUDED_FLAG(l_trx_line_index)         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.COMPOUNDING_TAX_FLAG(l_trx_line_index)          := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PROVNL_TAX_DETERMINATION_DATE(l_trx_line_index) := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_THIRD_PTY_ACCT_SITE_ID(l_trx_line_index)   := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_THIRD_PTY_ACCT_SITE_ID(l_trx_line_index)   := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_TO_CUST_ACCT_SITE_USE_ID(l_trx_line_index) := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_TO_CUST_ACCT_SITE_USE_ID(l_trx_line_index) := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_THIRD_PTY_ACCT_ID(l_trx_line_index)        := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_THIRD_PTY_ACCT_ID(l_trx_line_index)        := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SOURCE_APPLICATION_ID(l_trx_line_index)         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SOURCE_ENTITY_CODE(l_trx_line_index)            := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SOURCE_EVENT_CLASS_CODE(l_trx_line_index)       := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SOURCE_TRX_ID(l_trx_line_index)                 := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SOURCE_LINE_ID(l_trx_line_index)                := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SOURCE_TRX_LEVEL_TYPE(l_trx_line_index)         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INSERT_UPDATE_FLAG(l_trx_line_index)            := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_TO_TRX_NUMBER(l_trx_line_index)         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.START_EXPENSE_DATE(l_trx_line_index)            := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_BATCH_ID(l_trx_line_index)                  := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RECORD_TYPE_CODE(l_trx_line_index)              := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_TRX_LEVEL_TYPE(l_trx_line_index)        := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_FROM_TRX_LEVEL_TYPE(l_trx_line_index)   := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_TO_TRX_LEVEL_TYPE(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJUSTED_DOC_TRX_LEVEL_TYPE(l_trx_line_index)   := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE1(l_trx_line_index)         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE2(l_trx_line_index)         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE3(l_trx_line_index)         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE4(l_trx_line_index)         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE5(l_trx_line_index)         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE6(l_trx_line_index)         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE7(l_trx_line_index)         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE8(l_trx_line_index)         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE9(l_trx_line_index)         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE10(l_trx_line_index)        := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_PROCESSING_COMPLETED_FLAG(l_trx_line_index) := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLICATION_DOC_STATUS(l_trx_line_index)        := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OVERRIDING_RECOVERY_RATE(l_trx_line_index)      := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_CALCULATION_DONE_FLAG(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SOURCE_TAX_LINE_ID(l_trx_line_index)            := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REVERSED_APPLN_ID(l_trx_line_index)             := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REVERSED_ENTITY_CODE(l_trx_line_index)          := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REVERSED_EVNT_CLS_CODE(l_trx_line_index)        := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REVERSED_TRX_ID(l_trx_line_index)               := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REVERSED_TRX_LEVEL_TYPE(l_trx_line_index)       := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REVERSED_TRX_LINE_ID(l_trx_line_index)          := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EXEMPTION_CONTROL_FLAG(l_trx_line_index)        := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EXEMPT_REASON_CODE(l_trx_line_index)            := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INTERFACE_ENTITY_CODE(l_trx_line_index)         := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INTERFACE_LINE_ID(l_trx_line_index)             := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HISTORICAL_TAX_CODE_ID(l_trx_line_index)        := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.USER_UPD_DET_FACTORS_FLAG(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ICX_SESSION_ID(l_trx_line_index)                := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_SHIP_THIRD_PTY_ACCT_ST_ID(l_trx_line_index) := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_BILL_THIRD_PTY_ACCT_ST_ID(l_trx_line_index) := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_BILL_TO_CST_ACCT_ST_USE_ID(l_trx_line_index):= null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_SHIP_TO_CST_ACCT_ST_USE_ID(l_trx_line_index):= null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_SHIP_THIRD_PTY_ACCT_ID(l_trx_line_index)    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_BILL_THIRD_PTY_ACCT_ID(l_trx_line_index)    := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_RECEIVABLES_TRX_TYPE_ID(l_trx_line_index)   := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.GLOBAL_ATTRIBUTE1(l_trx_line_index)             := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.GLOBAL_ATTRIBUTE_CATEGORY(l_trx_line_index)     := null;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TOTAL_INC_TAX_AMT(l_trx_line_index)             := null;
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||' INIT_TRX_LINE_DIST_TBL'||'.END','ZX_GLOBAL_STRUCTURES_PKG: init_trx_line_dist_tbl()-');
        END IF;
  END init_trx_line_dist_tbl;
END ZX_GLOBAL_STRUCTURES_PKG;

/
