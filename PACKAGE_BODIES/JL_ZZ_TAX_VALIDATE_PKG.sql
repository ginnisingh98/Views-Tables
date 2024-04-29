--------------------------------------------------------
--  DDL for Package Body JL_ZZ_TAX_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_TAX_VALIDATE_PKG" as
/* $Header: jlzzdefvalpkgb.pls 120.19.12010000.7 2009/07/06 10:02:47 ssohal ship $ */

  procedure  validate_pfc_tbc (x_return_status OUT NOCOPY VARCHAR2);

  g_current_runtime_level NUMBER;
  g_level_statement       NUMBER;
  g_level_procedure       NUMBER;
  g_level_event           NUMBER;
  g_level_exception       NUMBER;
  g_level_unexpected      NUMBER;

  g_first_pty_org_id      NUMBER;  -- Added for Bug#7530930

  g_delimiter             zx_fc_types_b.delimiter%type;

  g_tax_lines_count       NUMBER;

  l_regime_not_exists                     varchar2(2000);
  l_regime_not_effective                  varchar2(2000);
  l_regime_not_eff_in_subscr              varchar2(2000);
  l_tax_not_exists                        varchar2(2000);
  l_tax_not_live                          varchar2(2000);
  l_tax_not_effective                     varchar2(2000);
  l_tax_status_not_exists                 varchar2(2000);
  l_tax_status_not_effective              varchar2(2000);
  l_tax_rate_not_exists                   varchar2(2000);
  l_tax_rate_not_effective                varchar2(2000);
  l_tax_rate_not_active                   varchar2(2000);
--l_tax_rate_code_not_exists              varchar2(2000);
--l_tax_rate_code_not_effective           varchar2(2000);
--l_tax_rate_code_not_active              varchar2(2000);
  l_tax_rate_percentage_invalid           varchar2(2000);
  l_evnt_cls_mpg_invalid                  varchar2(2000);
  l_exchg_info_missing                    varchar2(2000);
  l_line_class_invalid                    varchar2(2000);
  l_trx_line_type_invalid                 varchar2(2000);
  l_line_amt_incl_tax_invalid             varchar2(2000);
  l_trx_biz_fc_code_not_exists            varchar2(2000);
  l_trx_biz_fc_code_not_effect            varchar2(2000);
  l_prd_fc_code_not_exists                varchar2(2000);
  l_prd_category_not_exists               varchar2(2000);
  l_ship_to_party_not_exists              varchar2(2000);
  l_ship_frm_party_not_exits              varchar2(2000);
  l_bill_to_party_not_exists              varchar2(2000);
  l_shipto_party_site_not_exists          varchar2(2000);
  l_billto_party_site_not_exists          varchar2(2000);
  l_billfrm_party_site_not_exist          varchar2(2000);
  l_tax_multialloc_to_sameln              varchar2(2000);
  l_imptax_multialloc_to_sameln           varchar2(2000);
  l_tax_incl_flag_mismatch                varchar2(2000);
  l_imp_tax_missing_in_adjust_to          varchar2(2000);
--l_product_category_na_for_lte           varchar2(2000);
  l_user_def_fc_na_for_lte                varchar2(2000);
  l_document_fc_na_for_lte                varchar2(2000);
  l_indended_use_na_for_lte               varchar2(2000);
  l_product_type_na_for_lte               varchar2(2000);
  l_tax_jur_code_na_for_lte               varchar2(2000);

PROCEDURE default_and_validate_tax_attr(
                  p_api_version      IN            NUMBER,
                  p_init_msg_list    IN            VARCHAR2,
                  p_commit           IN            VARCHAR2,
                  p_validation_level IN            VARCHAR2,
                  x_return_status       OUT NOCOPY VARCHAR2,
                  x_msg_count           OUT NOCOPY NUMBER,
                  x_msg_data            OUT NOCOPY VARCHAR2) IS

  CURSOR c_delimiter IS
  SELECT delimiter
  FROM   zx_fc_types_b
  WHERE  classification_type_code ='TRX_BUSINESS_CATEGORY';

  -- Added for Bug#7530930
  l_le_id  NUMBER;
  l_ou_id  NUMBER;
  l_return_status VARCHAR2(1);
  l_err_count NUMBER := 0;
BEGIN

/* It is assumed that TSRM will set the security context before calling this API
   So the same logic is not coded here
*/
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
     IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
                       'JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR(+)');
     END IF;

     OPEN c_delimiter;
     FETCH c_delimiter INTO g_delimiter;
     CLOSE c_delimiter;

     -- Start : Code added to get the First-Party-Org-Id  -- bug#7530930
     BEGIN
         SELECT legal_entity_id , internal_organization_id
         INTO   l_le_id, l_ou_id
         FROM   ZX_TRX_HEADERS_GT Header
         WHERE  rownum = 1;
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
             IF (g_level_exception >= g_current_runtime_level ) THEN
                 FND_LOG.STRING(g_level_exception,
                        'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
                        'First Party Org Id : Not able to fetch OU and LE');
             END IF;
         app_exception.raise_exception;
     END;

     IF ( g_level_statement >= g_current_runtime_level) THEN
       FND_LOG.STRING(g_level_statement,'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
       'Call ZX_TCM_PTP_PKG.GET_TAX_SUBSCRIBER() with OU: '||TO_CHAR(l_ou_id)||' and LE: '||TO_CHAR(l_le_id));
     END IF;

     ZX_TCM_PTP_PKG.GET_TAX_SUBSCRIBER(l_le_id,
                                       l_ou_id,
                                       g_first_pty_org_id,
                                       l_return_status);

     IF ( g_level_statement >= g_current_runtime_level) THEN
       FND_LOG.STRING(g_level_statement,'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
       'G_FIRST_PTY_ORG_ID: '||TO_CHAR(g_first_pty_org_id));
     END IF;

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF (g_level_exception >= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_exception,
                   'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
                    'Get Tax Subscriber : Returned Error Status');
       END IF;
     END IF;
     -- End : Code added to get the First-Party-Org-Id -- Bug#7530930

     -- Get the count of manual tax lines in global variable
     SELECT Count(*)
     INTO   g_tax_lines_count
     FROM   zx_import_tax_lines_gt;

     validate_pfc_tbc  (x_return_status);

     default_tax_attr  (x_return_status);

     validate_tax_attr (x_return_status);

     -- Update the validation_check_flag to N for problematic trxs
     -- so that these trxs should not be picked up for tax processing
     UPDATE zx_trx_headers_gt
     SET    validation_check_flag = 'N'
     WHERE  trx_id IN (SELECT DISTINCT trx_id FROM zx_validation_errors_gt);

     IF ( SQL%ROWCOUNT > 0 ) THEN
       g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
       IF (g_level_statement >= g_current_runtime_level) THEN
           FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
           'Updated the validation_check_flag to N in Zx_Trx_Headers_GT for '||to_char(SQL%ROWCOUNT)||' trx(s).');
       END IF;
     END IF ;

     -- Printing Error Messages in Zx_Validation_Errors_Gt
     SELECT Count(*)
     INTO   l_err_count
     FROM   zx_validation_errors_gt;

     IF l_err_count > 0 THEN
       IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,
                         'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
                         'Error Message Count : '||l_err_count);
       END IF;
       FOR rec IN (SELECT trx_id, message_text FROM ZX_VALIDATION_ERRORS_GT) LOOP
         IF (g_level_procedure >= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_procedure,
                          'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
                          'Trx_ID : '||rec.trx_id||', Error : '||rec.message_text);
         END IF;
       END LOOP;
     END IF;

     IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
                       'RETURN_STATUS : '||x_return_status);
        FND_LOG.STRING(g_level_procedure,
                       'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
                       'JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR(-)');
     END IF;

  EXCEPTION
         WHEN OTHERS THEN
              IF (g_level_unexpected >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_unexpected,
                                 'JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
                                 sqlerrm);
              END IF;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              app_exception.raise_exception;

END default_and_validate_tax_attr;

-- Validations for Product Fiscal Classification code and
-- Transaction Business Category (done before defaulting, as we would not need
-- to validate the defaulted values). This is done in a separate query as we
-- do not need to join to other unnecessary tables.

Procedure VALIDATE_PFC_TBC( x_return_status       OUT NOCOPY VARCHAR2) IS

  CURSOR c_delimiter_prod_cat IS
   SELECT delimiter
   FROM   zx_fc_types_b
   WHERE  classification_type_code ='PRODUCT_CATEGORY';

  l_delimiter_prod_cat   zx_fc_types_b.delimiter%type;

BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure,
                      'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.VALIDATE_PFC_TBC',
                      'JL_ZZ_TAX_VALIDATE_PKG.VALIDATE_PFC_TBC(+)');
    END IF;

    OPEN c_delimiter_prod_cat;
    FETCH c_delimiter_prod_cat INTO l_delimiter_prod_cat;
    CLOSE c_delimiter_prod_cat;

    INSERT ALL
    INTO ZX_VALIDATION_ERRORS_GT(
                application_id,
                entity_code,
                event_class_code,
                trx_id,
                trx_line_id,
                message_name,
                message_text,
                trx_level_type,
                interface_line_id)
     SELECT
                lines_gt.application_id,
                lines_gt.entity_code,
                lines_gt.event_class_code,
                lines_gt.trx_id,
                lines_gt.trx_line_id,
                'ZX_TRX_BIZ_FC_CODE_NOT_EXIST',
                l_trx_biz_fc_code_not_exists||'('||lines_gt.trx_business_category||')',
                lines_gt.trx_level_type,
                lines_gt.interface_line_id
     FROM       zx_transaction_lines_gt       lines_gt
     WHERE      lines_gt.trx_business_category is NOT NULL
     AND        NOT EXISTS
                (SELECT 1
                 FROM
                      zx_evnt_cls_mappings    evntmap,
                      jl_zz_ar_tx_att_cls     tac,
                      jl_zz_ar_tx_categ       tc,
                      ar_system_parameters    asp
               where
                      lines_gt.application_id    = evntmap.application_id
                 and  lines_gt.entity_code    = evntmap.entity_code
                 and  lines_gt.event_class_code  = evntmap.event_class_code
                 and  tac.TAX_ATTR_CLASS_TYPE = 'TRANSACTION_CLASS'
                 and  tac.TAX_ATTR_CLASS_CODE =  SUBSTR(lines_gt.trx_business_category,
                            INSTR(lines_gt.trx_business_category, g_delimiter, 1) +1 )
                 and  tac.tax_category_id = tc.tax_category_id
                 and  tc.tax_rule_set = asp.global_attribute13
                 and  tac.enabled_flag = 'Y'
                 and  tac.org_id = asp.org_id
                 and  tc.org_id = asp.org_id);

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.VALIDATE_PFC_TBC',
                     'Transaction Business Category Validation Errors: '|| To_Char(SQL%ROWCOUNT) );
    END IF;

    INSERT ALL
    INTO ZX_VALIDATION_ERRORS_GT(
                application_id,
                entity_code,
                event_class_code,
                trx_id,
                trx_line_id,
                message_name,
                message_text,
                trx_level_type,
                interface_line_id)
     SELECT
                lines_gt.application_id,
                lines_gt.entity_code,
                lines_gt.event_class_code,
                lines_gt.trx_id,
                lines_gt.trx_line_id,
                'ZX_PRODUCT_FC_CODE_NOT_EXIST',
                l_prd_fc_code_not_exists||'('||lines_gt.product_fisc_classification||')',
                lines_gt.trx_level_type,
                lines_gt.interface_line_id
     FROM
                zx_transaction_lines_gt       lines_gt
     WHERE      lines_gt.product_fisc_classification is NOT NULL
        AND     NOT EXISTS
                (
                SELECT 1
                FROM
                      zx_trx_headers_gt             header,
                      zx_evnt_cls_mappings          evntmap,
                      FND_LOOKUPS                   LK,
                      JL_ZZ_AR_TX_FSC_CLS           FSC
                where
                      lines_gt.application_id    = header.application_id
                  and lines_gt.entity_code       = header.entity_code
                  and lines_gt.event_class_code  = header.event_class_code
                  and lines_gt.trx_id            = header.trx_id
                  and lines_gt.application_id    = evntmap.application_id
                  and lines_gt.entity_code       = evntmap.entity_code
                  and lines_gt.event_class_code  = evntmap.event_class_code
                  and lk.lookup_type = 'JLZZ_AR_TX_FISCAL_CLASS_CODE'
                  and lk.enabled_flag = 'Y'
                  and lk.lookup_code =  lines_gt.product_fisc_classification
                  and FSC.FISCAL_CLASSIFICATION_CODE = lk.LOOKUP_CODE
                  and fsc.enabled_Flag = 'Y'
                  and nvl(lk.start_date_active,header.trx_date) <= header.trx_date
                  and NVL(lk.END_DATE_ACTIVE,header.trx_date) >= header.trx_date
                  );

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.VALIDATE_PFC_TBC',
                     'Product Fiscal Classification Validation Errors: '|| To_Char(SQL%ROWCOUNT) );
    END IF;

    INSERT ALL
    INTO ZX_VALIDATION_ERRORS_GT(
                application_id,
                entity_code,
                event_class_code,
                trx_id,
                trx_line_id,
                message_name,
                message_text,
                trx_level_type,
                interface_line_id)
     SELECT
                lines_gt.application_id,
                lines_gt.entity_code,
                lines_gt.event_class_code,
                lines_gt.trx_id,
                lines_gt.trx_line_id,
                'ZX_PRODUCT_CATEGORY_NOT_EXIST',
                l_prd_category_not_exists||'('||lines_gt.product_category||')',
                lines_gt.trx_level_type,
                lines_gt.interface_line_id
     FROM
                zx_transaction_lines_gt       lines_gt
     WHERE      lines_gt.product_category IS NOT NULL
       AND      NOT EXISTS
                (
                SELECT 1
                FROM
                      zx_trx_headers_gt             header,
                      zx_evnt_cls_mappings          evntmap,
                      FND_LOOKUPS                   LK,
                      JL_ZZ_AR_TX_FSC_CLS           FSC
                where
                      lines_gt.application_id    = header.application_id
                  and lines_gt.entity_code       = header.entity_code
                  and lines_gt.event_class_code  = header.event_class_code
                  and lines_gt.trx_id            = header.trx_id
                  and lines_gt.application_id    = evntmap.application_id
                  and lines_gt.entity_code       = evntmap.entity_code
                  and lines_gt.event_class_code  = evntmap.event_class_code
                  and lk.lookup_type = 'JLZZ_AR_TX_FISCAL_CLASS_CODE'
                  and lk.enabled_flag = 'Y'
                  and lk.lookup_code = SUBSTR(lines_gt.product_category,
                            INSTR(lines_gt.product_category, l_delimiter_prod_cat, 1) +1 )
                  and fsc.fiscal_classification_code = lk.lookup_code
                  and fsc.enabled_Flag = 'Y'
                  and nvl(lk.start_date_active,header.trx_date) <= header.trx_date
                  and NVL(lk.end_date_active,header.trx_date) >= header.trx_date
                  );

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.VALIDATE_PFC_TBC',
                     'Product Category Validation Errors: '|| To_Char(SQL%ROWCOUNT) );
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure,
                      'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.VALIDATE_PFC_TBC',
                      'JL_ZZ_TAX_VALIDATE_PKG.VALIDATE_PFC_TBC(-)');
    END IF;

  EXCEPTION
         WHEN OTHERS THEN
              IF (g_level_unexpected >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_unexpected,
                                 'JL_ZZ_TAX_VALIDATE_PKG.VALIDATE_PFC_TBC',
                                 sqlerrm);
              END IF;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              app_exception.raise_exception;

END VALIDATE_PFC_TBC;


PROCEDURE default_tax_attr (x_return_status OUT NOCOPY VARCHAR2) IS

  l_line_level_action  ZX_TRANSACTION_LINES_GT.line_level_action%type;
  l_source_trx_id      ZX_TRANSACTION_LINES_GT.source_trx_id%type;


BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure,
                      'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_TAX_ATTR',
                      'JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_TAX_ATTR(+)');
    END IF;

    -- Defaulting the taxation country
    -- Bugfix 3971179
    UPDATE ZX_TRX_HEADERS_GT Header
       SET default_taxation_country =
            (SELECT
                 decode(syspa.global_attribute13,
                            'ARGENTINA', 'AR',
                            'COLOMBIA',  'CO',
                            'BRAZIL',    'BR',
                             NULL)
             FROM ar_system_parameters_all syspa
             WHERE  org_id = Header.internal_organization_id
               AND  global_attribute_category like 'JL%')
    WHERE Header.default_taxation_country is NULL;

 -- default the tax attributes only if there is at least on tax line being imported
 IF nvl(g_tax_lines_count,0) > 0 THEN

    --Defaulting for Tax Regime Code and Tax on imported tax lines

    --In case of LTE/O2C, the tax lines imoprted are detail tax lines and
    --will always have trx_line_id information

    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_TAX_ATTR',
                'JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_TAX_ATTR:
                Defaulting for Tax Regime Code and Tax');
    END IF;

    -- Defaulting the Tax_regime_code and Tax if tax_rate_code is passed
    MERGE INTO ZX_IMPORT_TAX_LINES_GT  TaxLines_gt
    USING   (SELECT rates.tax_regime_code  tax_regime_code,
                    rates.tax              tax,
                    TaxLines.trx_id        trx_id,
                    TaxLines.summary_tax_line_number  summary_tax_line_number
             FROM
                    ZX_IMPORT_TAX_LINES_GT TaxLines,
                    ZX_TRX_HEADERS_GT Header,
                    AR_VAT_TAX rates
             WHERE
                 TaxLines.tax_rate_code    = rates.tax_code(+)
             AND TaxLines.tax_rate_code IS NOT NULL
             AND Header.trx_date between nvl(rates.start_date,Header.trx_date)
                                    and  nvl(rates.end_date,Header.trx_date)
             AND TaxLines.application_id   = Header.application_id
             AND TaxLines.entity_code      = Header.entity_code
             AND TaxLines.event_class_code = Header.event_class_code
             AND TaxLines.trx_id = Header.trx_id
               ) Temp
    ON        (  TaxLines_gt.trx_id = Temp.trx_id AND
                 TaxLines_gt.summary_tax_line_number = Temp.summary_tax_line_number )
    WHEN MATCHED THEN
        UPDATE SET
          tax_regime_code = nvl(TaxLines_gt.tax_regime_code, Temp.tax_regime_code),
          tax             = nvl(TaxLines_gt.tax, Temp.tax)
    WHEN NOT MATCHED THEN
        INSERT(tax) VALUES(NULL);

    -- Defaulting the Tax_regime_code and Tax if tax_rate_id is passed
    MERGE INTO ZX_IMPORT_TAX_LINES_GT  TaxLines_gt
    USING   (SELECT rates.tax_regime_code  tax_regime_code,
                    rates.tax              tax,
                    TaxLines.trx_id        trx_id,
                    TaxLines.summary_tax_line_number  summary_tax_line_number
             FROM
                    ZX_IMPORT_TAX_LINES_GT TaxLines,
                    ZX_TRX_HEADERS_GT Header,
                    AR_VAT_TAX rates
             WHERE
                 TaxLines.tax_rate_id    = rates.vat_tax_id(+)
             AND TaxLines.tax_rate_id IS NOT NULL
             AND (TaxLines.tax_regime_code IS NULL OR TaxLines.tax IS NULL)
             AND Header.trx_date between nvl(rates.start_date,Header.trx_date)
                                    and  nvl(rates.end_date,Header.trx_date)
             AND TaxLines.application_id   = Header.application_id
             AND TaxLines.entity_code      = Header.entity_code
             AND TaxLines.event_class_code = Header.event_class_code
             AND TaxLines.trx_id = Header.trx_id
               ) Temp
    ON        (  TaxLines_gt.trx_id = Temp.trx_id AND
                 TaxLines_gt.summary_tax_line_number = Temp.summary_tax_line_number )
    WHEN MATCHED THEN
        UPDATE SET
          tax_regime_code = nvl(TaxLines_gt.tax_regime_code, Temp.tax_regime_code),
          tax             = nvl(TaxLines_gt.tax, Temp.tax)
    WHEN NOT MATCHED THEN
        INSERT(tax) VALUES(NULL);

    --Defaulting for Tax Status Code on imported tax lines
    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_TAX_ATTR',
                'JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_TAX_ATTR:
                Defaulting for Tax Status Code');
    END IF;

    MERGE INTO ZX_IMPORT_TAX_LINES_GT  TaxLines_gt
    USING   (SELECT Rates.tax_status_code  tax_status_code,
                    TaxLines.trx_id        trx_id,
                    TaxLines.summary_tax_line_number  summary_tax_line_number
             FROM
                    ZX_IMPORT_TAX_LINES_GT TaxLines,
                    AR_VAT_TAX Rates,
                    ZX_TRX_HEADERS_GT Header
             WHERE
                    Taxlines.tax_regime_Code = Rates.tax_regime_code(+)
             AND    Taxlines.tax             = Rates.tax(+)
             AND    ((Taxlines.tax_rate_code IS NOT NULL AND Taxlines.tax_rate_code = rates.tax_code)
                    OR (Taxlines.tax_rate_id IS NOT NULL AND Taxlines.tax_rate_id = rates.vat_tax_id))
             AND    Header.trx_date BETWEEN nvl(Rates.start_date,Header.trx_date)
                                    AND  nvl(Rates.end_date,Header.trx_date)
             AND    TaxLines.application_id = Header.application_id
             AND    TaxLines.entity_code = Header.entity_code
             AND    TaxLines.event_class_code = Header.event_class_code
             AND    TaxLines.trx_id = Header.trx_id
               ) Temp
    ON        (  TaxLines_gt.trx_id = Temp.trx_id AND
                 TaxLines_gt.summary_tax_line_number = Temp.summary_tax_line_number )
    WHEN MATCHED THEN
        UPDATE SET
            tax_status_code = nvl(TaxLines_gt.tax_status_code, Temp.tax_status_code)
    WHEN NOT MATCHED THEN
        INSERT(tax) VALUES(NULL);

    -- Defaulting for Tax Rate Code, Tax Rate Id, Percentage Rate on imported tax lines
    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_TAX_ATTR',
                'JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_TAX_ATTR:
                Defaulting for Tax Rate Code, Tax Rate Id, Percentage Rate');
    END IF;

    MERGE INTO ZX_IMPORT_TAX_LINES_GT  TaxLines_gt
    USING  (SELECT Rates.tax_code,
               Rates.vat_tax_id,
               Rates.tax_rate,
               TaxLines.trx_id,
               TaxLines.summary_tax_line_number
       FROM
               AR_VAT_TAX Rates,
               ZX_IMPORT_TAX_LINES_GT  TaxLines,
               ZX_TRX_HEADERS_GT Header
       WHERE
           Taxlines.tax_regime_Code = Rates.tax_regime_code(+)
       AND Taxlines.tax             = Rates.tax(+)
       AND Taxlines.tax_status_code = Rates.tax_status_code(+)
       AND ((Taxlines.tax_rate_code IS NOT NULL AND Taxlines.tax_rate_code = rates.tax_code)
           OR (Taxlines.tax_rate_id IS NOT NULL AND Taxlines.tax_rate_id = rates.vat_tax_id))
       AND Rates.enabled_flag  = 'Y'
       AND Header.trx_date BETWEEN nvl(Rates.start_date,Header.trx_date)
                           AND nvl(Rates.end_date, Header.trx_date)
       AND TaxLines.application_id   = Header.application_id
       AND TaxLines.entity_code      = Header.entity_code
       AND TaxLines.event_class_code = Header.event_class_code
       AND TaxLines.trx_id = Header.trx_id
       ) Temp
    ON ( TaxLines_gt.trx_id = Temp.trx_id AND
         TaxLines_gt.summary_tax_line_number = Temp.summary_tax_line_number )
    WHEN MATCHED THEN
    	 UPDATE SET
    	 tax_rate_code = nvl(TaxLines_gt.tax_rate_code,Temp.tax_code),
    	 tax_rate_id   = nvl(TaxLines_gt.tax_rate_id,Temp.vat_tax_id),
    	 tax_rate      = nvl(TaxLines_gt.tax_rate,Temp.tax_rate)
    WHEN NOT MATCHED THEN
                         INSERT(tax) VALUES(NULL);

   --  Default tax amount if it is NULL and tax rate is specified
   MERGE INTO ZX_IMPORT_TAX_LINES_GT  TaxLines_gt
   USING  (SELECT
             TaxLines.tax_rate,
             TaxLines.tax_amt_included_flag,
             TaxLines.trx_id,
             Lines.line_amt,
             TaxLines.summary_tax_line_number
   FROM
          ZX_IMPORT_TAX_LINES_GT TaxLines,
          ZX_TRX_HEADERS_GT Header,
          ZX_TRANSACTION_LINES_GT Lines
   WHERE
      Taxlines.tax_line_allocation_flag  = 'N' AND
      TaxLines.tax_amt IS NULL AND
      TaxLines.tax_rate IS NOT NULL AND
      TaxLines.application_id  = Header.application_id AND
      TaxLines.entity_code  = Header.entity_code AND
      TaxLines.event_class_code  = Header.event_class_code AND
      TaxLines.trx_id = Header.trx_id AND
      Lines.application_id = Header.application_id AND
      Lines.entity_code = Header.entity_code AND
      Lines.event_class_code = Header.event_class_code AND
      Lines.trx_id = Header.trx_id AND
      Lines.trx_line_id = TaxLines.trx_line_id
     ) Temp
   ON ( TaxLines_gt.trx_id = Temp.trx_id AND
        TaxLines_gt.summary_tax_line_number = Temp.summary_tax_line_number )
       WHEN MATCHED THEN
                 UPDATE SET
                    tax_amt = CASE WHEN (temp.tax_amt_included_flag  <> 'Y')
                                     THEN  (temp.tax_rate / 100 ) * temp.line_amt
                                   WHEN (temp.tax_rate = 0 )
                                     THEN  0
                                   ELSE temp.tax_rate * temp.line_amt / ( 100 + temp.tax_rate )
                                   END
       WHEN NOT MATCHED THEN
                     INSERT(tax) VALUES(NULL);

 END IF; -- nvl(g_tax_lines_count,0) > 0

/* Defaulting for Transaction Business Category, Product Category  and
   Product Fiscal Classification on transaction lines */

   -- In case where the line is not a memo line, default the Transaction Business
   -- Category and Product Fiscal Classification from mtl_system_items / mtl_item_categories.
   -- If the line is a memo line, then populate Transaction Business Category and
   -- Product Category from ar_memo_lines.

   IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_TAX_ATTR',
                'JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_TAX_ATTR:
        Defaulting for Transaction Business Category and Product Category,
        Product Fiscal Classification');
   END IF;

   -- Bug#5639478-

   SELECT line_level_action
     INTO l_line_level_action
     FROM ZX_TRANSACTION_LINES_GT
     WHERE rownum             = 1;

  IF l_line_level_action = 'COPY_AND_CREATE' THEN

     UPDATE ZX_TRANSACTION_LINES_GT L
     SET (L.product_fisc_classification,
          L.trx_business_category,
          L.product_category,
          L.output_tax_classification_code ) =
          (SELECT D.product_fisc_classification,
                  D.trx_business_category,
                  D.product_category,
                  D.output_tax_classification_code
             FROM ZX_LINES_DET_FACTORS D
            WHERE D.event_class_code = L.source_event_class_code
              AND D.application_id   = L.source_application_id
              AND D.entity_code      = L.source_entity_code
              AND D.trx_id           = L.source_trx_id
              AND D.trx_line_id      = L.source_line_id
              AND D.trx_level_type   = L.source_trx_level_type )
     WHERE L.source_trx_id IS NOT NULL
       AND L.line_level_action = 'COPY_AND_CREATE';
  ELSE
     -- keep current logic


   MERGE INTO  ZX_TRANSACTION_LINES_GT Lines
   USING (SELECT
            fc.classification_code  product_fisc_class,
            Lines.trx_id,
            Lines.trx_line_id,
            Lines.trx_level_type
        FROM
            zx_fc_product_fiscal_v     fc,
            mtl_item_categories        mic,
            zx_transaction_lines_gt    lines ,
            zx_trx_headers_gt          header
        WHERE
           ((fc.country_code    = Header.default_taxation_country
            AND fc.country_code in ('AR', 'BR', 'CO'))
            or
            fc.country_code is NULL
            )
        AND Lines.application_id    = Header.application_id
        AND Lines.entity_code       = Header.entity_code
        AND Lines.event_class_code  = Header.event_class_code
        AND Lines.trx_id = Header.trx_id
        AND Lines.product_org_id is NOT NULL
        AND Lines.product_id = mic.inventory_item_id
        AND mic.organization_id  = Lines.Product_org_id
        AND mic.category_id = fc.category_id
        AND mic.category_set_id = fc.category_set_id
     -- AND fc.structure_name = 'Fiscal Classification'  -- Commented for Bug#7125709
        AND fc.structure_code = 'FISCAL_CLASSIFICATION'  -- Added as a fix for Bug#7125709
        AND EXISTS
               (SELECT 1
                 FROM  JL_ZZ_AR_TX_FSC_CLS
                 WHERE fiscal_classification_code = fc.classification_code
                   AND enabled_flag = 'Y')
        ) Temp
   ON   ( Lines.trx_id = Temp.trx_id AND
          Lines.trx_line_id = Temp.trx_line_id AND
          Lines.trx_level_type = Temp.trx_level_type)
   WHEN MATCHED THEN
         UPDATE SET
         product_fisc_classification = nvl(Lines.product_fisc_classification,
                                           Temp.product_fisc_class)
   WHEN NOT MATCHED THEN
                      INSERT  (LINE_AMT) VALUES(NULL);



   MERGE INTO  ZX_TRANSACTION_LINES_GT Lines
   USING (SELECT
             Event.tax_event_class_code,
             items.global_attribute2 trx_business_category,
             Lines.trx_id,
             Lines.trx_line_id,
             Lines.trx_level_type
        FROM
              ZX_TRANSACTION_LINES_GT Lines ,
              mtl_system_items        items,
              ZX_EVNT_CLS_MAPPINGS    event
        WHERE items.organization_id =  lines.Product_org_id
        AND   items.inventory_item_id = lines.product_id
        AND   lines.product_org_id is not NULL
        AND Lines.application_id    = Event.application_id
        AND Lines.entity_code       = Event.entity_code
        AND Lines.event_class_code  = Event.event_class_code
        )Temp
   ON   ( Lines.trx_id = Temp.trx_id AND
          Lines.trx_line_id = Temp.trx_line_id AND
          Lines.trx_level_type = Temp.trx_level_type)
   WHEN MATCHED THEN
     UPDATE SET
     trx_business_category     = nvl(Lines.trx_business_category,
                                     DECODE(Temp.trx_business_category,NULL,Temp.trx_business_category,
                                            Temp.tax_event_class_code||g_delimiter||Temp.trx_business_category))
   WHEN NOT MATCHED THEN
                  INSERT  (LINE_AMT) VALUES(NULL);

   -- In case where the product type is 'MEMO', default the Transaction Business Category
   -- and Product Category from ar_memo_lines.

   MERGE INTO  ZX_TRANSACTION_LINES_GT Lines
   USING (SELECT
             Event.tax_event_class_code,
             Memo.global_attribute2       trx_business_category,
             Memo.tax_product_category    product_category,
             Lines.trx_id,
             Lines.trx_line_id,
             Lines.trx_level_type
        FROM
              ZX_TRANSACTION_LINES_GT Lines ,
              ar_memo_lines           Memo,
              ZX_EVNT_CLS_MAPPINGS    event
        WHERE Memo.memo_line_id = lines.product_id
        AND   lines.product_org_id is NULL
        AND   Lines.application_id    = Event.application_id
        AND   Lines.entity_code       = Event.entity_code
        AND   Lines.event_class_code  = Event.event_class_code
        )Temp
   ON   ( Lines.trx_id = Temp.trx_id AND
          Lines.trx_line_id = Temp.trx_line_id AND
          Lines.trx_level_type = Temp.trx_level_type)
   WHEN MATCHED THEN
     UPDATE SET
     trx_business_category     = nvl(Lines.trx_business_category,
                                     DECODE(Temp.trx_business_category,NULL,Temp.trx_business_category,
                                            Temp.tax_event_class_code||g_delimiter||Temp.trx_business_category)),
     Product_category          = nvl(Lines.product_category,
                                     Temp.product_category)
   WHEN NOT MATCHED THEN
                  INSERT  (LINE_AMT) VALUES(NULL);


   -- bug#5696143- populate output_tax_classification_code

   MERGE INTO  ZX_TRANSACTION_LINES_GT Lines
   USING (SELECT CTT.global_attribute4  output_tax_classification_code,
                 H.trx_id
          FROM   ZX_TRX_HEADERS_GT H,
                 RA_CUST_TRX_TYPES CTT,
                 AR_VAT_TAX VT
          WHERE  CTT.cust_trx_type_id =  H.receivables_trx_type_id
          AND    CTT.org_id = VT.org_id
          AND    CTT.org_id = H.internal_organization_id
          AND    CTT.global_attribute4 = VT.tax_code
          AND    VT.set_of_books_id = H.ledger_id
          AND    H.trx_date between VT.start_date
                            and     NVL(VT.end_date, H.trx_date)
          AND    NVL(VT.enabled_flag,'Y') = 'Y'
          AND    NVL(VT.tax_class,'O') = 'O'
        )Temp
   ON   ( Lines.trx_id = Temp.trx_id)
   WHEN MATCHED THEN
     UPDATE SET
       output_tax_classification_code = NVL(Lines.output_tax_classification_code,
                                            Temp.output_tax_classification_code)
   WHEN NOT MATCHED THEN
                  INSERT  (output_tax_classification_code) VALUES(NULL);


 END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure,
                      'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_TAX_ATTR',
                      'JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_TAX_ATTR(-)');
    END IF;

  EXCEPTION
       WHEN OTHERS THEN
            IF (g_level_unexpected >= g_current_runtime_level ) THEN
               FND_LOG.STRING(g_level_unexpected,
                              'JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_TAX_ATTR',
                               sqlerrm);
            END IF;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            app_exception.raise_exception;

END default_tax_attr;

/* default ax attributes API for line level calls */
PROCEDURE default_tax_attr  (p_trx_line_index      IN  NUMBER,
                             x_return_status       OUT NOCOPY VARCHAR2) is

  l_organization_id  hr_organization_units.organization_id%type;
  l_product_fisc_class zx_lines_det_factors.product_fisc_classification%type;
  l_product_category   zx_lines_det_factors.product_category%type;
  l_trx_business_category zx_lines_det_factors.trx_business_category%type;

  CURSOR c_delimiter IS
  SELECT delimiter
  FROM   zx_fc_types_b
  WHERE  classification_type_code ='TRX_BUSINESS_CATEGORY';

BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure,
                      'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_TAX_ATTR',
                      'JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_TAX_ATTR(+)');
    END IF;

    -- Defaulting the taxation country
/* -- Commented out the logic that raises error when default taxation country is not available.
   -- Instead, the calling API will verify that default_taxation_country is available before
   -- calling this API.

   IF zx_global_structures_pkg.trx_line_dist_tbl.default_taxation_country(p_trx_line_index) is NULL then
    -- Check with TSRM that default_taxation_country is always populated;

           IF (g_level_unexpected >= g_current_runtime_level ) THEN
               FND_LOG.STRING(g_level_unexpected,
                              'JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_TAX_ATTR',
                               'Default taxation country is not available');
            END IF;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            app_exception.raise_exception;
   End If;
*/

/* Defaulting for Transaction Business Category, Product Category  and
   Product Fiscal Classification on transaction lines */

   -- In case where the line is not a memo line, default the Transaction Business
   -- Category and Product Fiscal Classification from mtl_system_items / mtl_item_categories.
   -- If the line is a memo line, then populate Transaction Business Category and
   -- Product Category from ar_memo_lines.

   l_organization_id := zx_global_structures_pkg.trx_line_dist_tbl.product_org_id(p_trx_line_index);

   IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_TAX_ATTR',
                'JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_TAX_ATTR:
        Defaulting for Transaction Business Category and Product Category,
        Product Fiscal Classification');
   END IF;

  IF zx_global_structures_pkg.trx_line_dist_tbl.product_id(p_trx_line_index) IS NOT NULL
  AND zx_global_structures_pkg.trx_line_dist_tbl.product_org_id(p_trx_line_index) is NOT NULL THEN

    -- It is an inveontory item; Populate product_fisc_classification and trx_business_category
    -- from mtl_system_items.
     If zx_global_structures_pkg.trx_line_dist_tbl.trx_business_category(p_trx_line_index) is NULL then

        IF g_delimiter is NULL then
               OPEN c_delimiter;
               FETCH c_delimiter INTO g_delimiter;
               CLOSE c_delimiter;
        END IF;

        IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_TAX_ATTR',
                'Transaction Business Category is NULL. Defaulting Transaction Business Category'||
                ' Tax Event Class Code = '||zx_global_structures_pkg.trx_line_dist_tbl.tax_event_class_code(p_trx_line_index)||
                ' Delimiter = '||g_delimiter);
        END IF;


        SELECT
             DECODE(items.global_attribute2, NULL, items.global_attribute2,
                    zx_global_structures_pkg.trx_line_dist_tbl.tax_event_class_code(p_trx_line_index)
                    ||g_delimiter||items.global_attribute2) trx_business_category
        INTO
             l_trx_business_category
        FROM
              mtl_system_items   items
        WHERE organization_id =  l_organization_id
        AND   inventory_item_id = zx_global_structures_pkg.trx_line_dist_tbl.product_id(p_trx_line_index);


        IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_TAX_ATTR',
                'After defaulting: l_trx_business_category = '||l_trx_business_category);
        END IF;

       zx_global_structures_pkg.trx_line_dist_tbl.trx_business_category(p_trx_line_index) :=
                      nvl(zx_global_structures_pkg.trx_line_dist_tbl.trx_business_category(p_trx_line_index),
                                       l_trx_business_category);
     End If;

    Begin
      If zx_global_structures_pkg.trx_line_dist_tbl.product_fisc_classification(p_trx_line_index) is NULL then


         IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_TAX_ATTR',
                'Country code: '||
                zx_global_structures_pkg.trx_line_dist_tbl.default_taxation_country(p_trx_line_index));
        END IF;


        SELECT
            fc.classification_code
        INTO
            l_product_fisc_class
        FROM
            zx_fc_product_fiscal_v     fc,
            mtl_item_categories      mic
        WHERE
            ((fc.country_code    =
               zx_global_structures_pkg.trx_line_dist_tbl.default_taxation_country(p_trx_line_index)
               AND fc.country_code in ('AR', 'BR', 'CO'))
              or
              fc.country_code is NULL
             )
        AND zx_global_structures_pkg.trx_line_dist_tbl.product_id(p_trx_line_index)
                                     = mic.inventory_item_id
        AND mic.organization_id  = l_organization_id
        AND mic.category_id = fc.category_id
        AND mic.category_set_id = fc.category_set_id
     -- AND fc.structure_name = 'Fiscal Classification'  -- Commented for Bug#7125709
        AND fc.structure_code = 'FISCAL_CLASSIFICATION'  -- Added as a fix for Bug#7125709
        AND EXISTS
               (SELECT 1
                 FROM  JL_ZZ_AR_TX_FSC_CLS
                 WHERE fiscal_classification_code = fc.classification_code
                   AND enabled_flag = 'Y')
        AND rownum = 1;   -- Bug 5701599

         zx_global_structures_pkg.trx_line_dist_tbl.product_fisc_classification(p_trx_line_index) :=
                       nvl(zx_global_structures_pkg.trx_line_dist_tbl.product_fisc_classification(p_trx_line_index),
                                           l_product_fisc_class);
       End If;
     Exception
        when no_data_found then
            IF (g_level_exception >= g_current_runtime_level ) THEN
               FND_LOG.STRING(g_level_exception,
                              'JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_TAX_ATTR',
                               'Unable to default Product Fiscal Classification which is mandatory for LTE');
            END IF;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            -- app_exception.raise_exception;
     End;

  ELSIF zx_global_structures_pkg.trx_line_dist_tbl.product_id(p_trx_line_index) IS NOT NULL
  AND zx_global_structures_pkg.trx_line_dist_tbl.product_org_id(p_trx_line_index) is NULL THEN

   -- In case where the line is a memo line, default the Transaction Business Category
   -- and Product Category from ar_memo_lines.

     IF (zx_global_structures_pkg.trx_line_dist_tbl.product_fisc_classification(p_trx_line_index) IS NULL
     OR zx_global_structures_pkg.trx_line_dist_tbl.trx_business_category(p_trx_line_index) IS NULL)
     then

          Begin

             IF g_delimiter is NULL then
               OPEN c_delimiter;
               FETCH c_delimiter INTO g_delimiter;
               CLOSE c_delimiter;
             END IF;


             SELECT
                  DECODE(Memo.global_attribute2, NULL, Memo.global_attribute2,
                         zx_global_structures_pkg.trx_line_dist_tbl.tax_event_class_code(p_trx_line_index)
                         ||g_delimiter||Memo.global_attribute2) trx_business_category,
                  Memo.tax_product_category                     product_category
             INTO
                  l_trx_business_category,
                  l_product_category
             FROM
                   ar_memo_lines  Memo
             WHERE memo_line_id = zx_global_structures_pkg.trx_line_dist_tbl.product_id(p_trx_line_index);

             zx_global_structures_pkg.trx_line_dist_tbl.trx_business_category(p_trx_line_index) :=
                           nvl(zx_global_structures_pkg.trx_line_dist_tbl.trx_business_category(p_trx_line_index),
                                            l_trx_business_category);

             zx_global_structures_pkg.trx_line_dist_tbl.product_category(p_trx_line_index) :=
                           nvl(zx_global_structures_pkg.trx_line_dist_tbl.product_category(p_trx_line_index),
                                            l_product_category);

            IF (g_level_statement >= g_current_runtime_level ) THEN
                 FND_LOG.STRING(g_level_statement,
                'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_TAX_ATTR',
                ' l_trx_business_category = '||l_trx_business_category||
                ' l_product_category = '||l_product_category);
            END IF;

          Exception
             when no_data_found then
                 IF (g_level_exception >= g_current_runtime_level ) THEN
                    FND_LOG.STRING(g_level_exception,
                                   'JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_TAX_ATTR',
                                    'Unable to default Product Fiscal Classification ot Trx Business Category'||
                                    ' which is mandatory for LTE');
                 END IF;
                 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                 app_exception.raise_exception;
          End;
        End If;
  END IF;


  IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure,
                      'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_TAX_ATTR',
                      'JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_TAX_ATTR(-)');
  END IF;

EXCEPTION
       WHEN OTHERS THEN
            IF (g_level_unexpected >= g_current_runtime_level ) THEN
               FND_LOG.STRING(g_level_unexpected,
                              'JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_TAX_ATTR',
                               sqlerrm);
            END IF;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            app_exception.raise_exception;

END default_tax_attr;



PROCEDURE validate_tax_attr (x_return_status OUT NOCOPY VARCHAR2) IS

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.VALIDATE_TAX_ATTR',
                     'JL_ZZ_TAX_VALIDATE_PKG.VALIDATE_TAX_ATTR(+)');
   END IF;

   IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.VALIDATE_TAX_ATTR',
                     'Running Line Level Validations...');
   END IF;

        INSERT ALL
        WHEN (ZX_EVNT_CLS_MPG_INVALID = 'Y')  THEN

                        INTO ZX_VALIDATION_ERRORS_GT(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                summary_tax_line_number,
                                message_name,
                                message_text,
                                trx_level_type,
                                interface_line_id
                                )
                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                NULL,
                                'ZX_EVNT_CLS_MPG_INVALID',
                                l_evnt_cls_mpg_invalid,
                                trx_level_type,
                                interface_line_id
                                 )

        WHEN (ZX_EXCHG_INFO_MISSING = 'Y')  THEN

                        INTO ZX_VALIDATION_ERRORS_GT(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                summary_tax_line_number,
                                message_name,
                                message_text,
                                trx_level_type,
                                interface_line_id
                                )
                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                NULL,
                                'ZX_EXCHG_INFO_MISSING',
                                l_exchg_info_missing,
                                trx_level_type,
                                interface_line_id
                                 )


        WHEN (ZX_LINE_CLASS_INVALID = 'Y')  THEN

                        INTO ZX_VALIDATION_ERRORS_GT(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                summary_tax_line_number,
                                message_name,
                                message_text,
                                trx_level_type,
                                interface_line_id
                                )
                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                NULL,
                                'ZX_LINE_CLASS_INVALID',
                                l_line_class_invalid,
                                trx_level_type,
                                interface_line_id
                                 )

        WHEN (ZX_TRX_LINE_TYPE_INVALID = 'Y')  THEN

                        INTO ZX_VALIDATION_ERRORS_GT(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                summary_tax_line_number,
                                message_name,
                                message_text,
                                trx_level_type,
                                interface_line_id
                                )
                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                NULL,
                                'ZX_TRX_LINE_TYPE_INVALID',
                                l_trx_line_type_invalid,
                                trx_level_type,
                                interface_line_id
                                 )

        WHEN (ZX_LINE_AMT_INCL_TAX_INVALID = 'Y')  THEN

                        INTO ZX_VALIDATION_ERRORS_GT(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                summary_tax_line_number,
                                message_name,
                                message_text,
                                trx_level_type,
                                interface_line_id
                                )
                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                NULL,
                                'ZX_LINE_AMT_INCTAX_INVALID',
                                l_line_amt_incl_tax_invalid,
                                trx_level_type,
                                interface_line_id
                                 )

        /*
        WHEN (SHIP_TO_PARTY_NOT_EXISTS = 'Y')  THEN

                                INTO ZX_VALIDATION_ERRORS_GT(
                                        application_id,
                                        entity_code,
                                        event_class_code,
                                        trx_id,
                                        trx_line_id,
                                        summary_tax_line_number,
                                        message_name,
                                        message_text,
                                        trx_level_type
                                        )
                                VALUES(
                                        application_id,
                                        entity_code,
                                        event_class_code,
                                        trx_id,
                                        trx_line_id,
                                        NULL,
                                        'ZX_SHIP_TO_PARTY_NOT_EXIST',
                                        l_ship_to_party_not_exists,
                                        trx_level_type
                                 )


        WHEN (BILL_TO_PARTY_NOT_EXISTS = 'Y')  THEN

                                INTO ZX_VALIDATION_ERRORS_GT(
                                        application_id,
                                        entity_code,
                                        event_class_code,
                                        trx_id,
                                        trx_line_id,
                                        summary_tax_line_number,
                                        message_name,
                                        message_text,
                                        trx_level_type
                                        )
                                VALUES(
                                        application_id,
                                        entity_code,
                                        event_class_code,
                                        trx_id,
                                        trx_line_id,
                                        NULL,
                                        'ZX_BILTO_PARTY_NOT_EXIST',
                                        l_bill_to_party_not_exists,
                                        trx_level_type
                                 )


        WHEN (SHIPTO_PARTY_SITE_NOT_EXISTS = 'Y')  THEN

                                INTO ZX_VALIDATION_ERRORS_GT(
                                        application_id,
                                        entity_code,
                                        event_class_code,
                                        trx_id,
                                        trx_line_id,
                                        summary_tax_line_number,
                                        message_name,
                                        message_text,
                                        trx_level_type
                                        )
                                VALUES(
                                        application_id,
                                        entity_code,
                                        event_class_code,
                                        trx_id,
                                        trx_line_id,
                                        NULL,
                                        'ZX_SHIPTO_PARTY_SITE_NOT_EXIST',
                                        l_shipto_party_site_not_exists,
                                        trx_level_type
                                 )

        WHEN (SHIPFROM_PARTY_SITE_NOT_EXISTS = 'Y')  THEN

                                INTO ZX_VALIDATION_ERRORS_GT(
                                        application_id,
                                        entity_code,
                                        event_class_code,
                                        trx_id,
                                        trx_line_id,
                                        summary_tax_line_number,
                                        message_name,
                                        message_text,
                                        trx_level_type
                                        )
                                VALUES(
                                        application_id,
                                        entity_code,
                                        event_class_code,
                                        trx_id,
                                        trx_line_id,
                                        NULL,
                                        'ZX_SHIPFROM_PARTY_SITE_NOT_EXIST',
                                        l_shipfrm_party_site_not_exits,
                                        trx_level_type
                                 )

        WHEN (BILLTO_PARTY_SITE_NOT_EXISTS = 'Y')  THEN

                                INTO ZX_VALIDATION_ERRORS_GT(
                                        application_id,
                                        entity_code,
                                        event_class_code,
                                        trx_id,
                                        trx_line_id,
                                        summary_tax_line_number,
                                        message_name,
                                        message_text,
                                        trx_level_type
                                        )
                                VALUES(
                                        application_id,
                                        entity_code,
                                        event_class_code,
                                        trx_id,
                                        trx_line_id,
                                        NULL,
                                        'ZX_BILLTO_PARTY_SITE_NOT_EXIST',
                                        l_billto_party_site_not_exists,
                                        trx_level_type
                                 )

           */

           WHEN (USER_DEF_FC_NA_FOR_LTE = 'Y') THEN
                INTO ZX_VALIDATION_ERRORS_GT(
                        application_id,
                        entity_code,
                        event_class_code,
                        trx_id,
                        trx_line_id,
                        summary_tax_line_number,
                        message_name,
                        message_text,
                        trx_level_type,
                        interface_line_id
                        )
                VALUES(
                        application_id,
                        entity_code,
                        event_class_code,
                        trx_id,
                        trx_line_id,
                        NULL,
                        'ZX_USER_DEF_FC_NA_FOR_LTE',
                        l_user_def_fc_na_for_lte,
                        trx_level_type,
                        interface_line_id
                         )

           /*
           -- Commented the validation as Product Category
           -- is a required parameter for Memo Lines
           WHEN (PRODUCT_CATEGORY_NA_FOR_LTE = 'Y') THEN
                INTO ZX_VALIDATION_ERRORS_GT(
                        application_id,
                        entity_code,
                        event_class_code,
                        trx_id,
                        trx_line_id,
                        summary_tax_line_number,
                        message_name,
                        message_text,
                        trx_level_type,
                        interface_line_id
                        )
                VALUES(
                        application_id,
                        entity_code,
                        event_class_code,
                        trx_id,
                        trx_line_id,
                        NULL,
                        'ZX_PRODUCT_CATEGORY_NA_FOR_LTE',
                        l_product_category_na_for_lte,
                        trx_level_type,
                        interface_line_id
                         )
            */

              WHEN (DOCUMENT_FC_NA_FOR_LTE = 'Y') THEN
                INTO ZX_VALIDATION_ERRORS_GT(
                        application_id,
                        entity_code,
                        event_class_code,
                        trx_id,
                        trx_line_id,
                        summary_tax_line_number,
                        message_name,
                        message_text,
                        trx_level_type,
                        interface_line_id
                        )
                VALUES(
                        application_id,
                        entity_code,
                        event_class_code,
                        trx_id,
                        trx_line_id,
                        NULL,
                        'ZX_DOCUMENT_FC_NA_FOR_LTE',
                        l_document_fc_na_for_lte,
                        trx_level_type,
                        interface_line_id
                         )

              WHEN (INTENDED_USE_NA_FOR_LTE = 'Y') THEN
                INTO ZX_VALIDATION_ERRORS_GT(
                        application_id,
                        entity_code,
                        event_class_code,
                        trx_id,
                        trx_line_id,
                        summary_tax_line_number,
                        message_name,
                        message_text,
                        trx_level_type,
                        interface_line_id
                        )
                VALUES(
                        application_id,
                        entity_code,
                        event_class_code,
                        trx_id,
                        trx_line_id,
                        NULL,
                        'ZX_INTENDED_USE_NA_FOR_LTE',
                        l_indended_use_na_for_lte,
                        trx_level_type,
                        interface_line_id
                         )

              WHEN (PRODUCT_TYPE_NA_FOR_LTE = 'Y') THEN
                INTO ZX_VALIDATION_ERRORS_GT(
                        application_id,
                        entity_code,
                        event_class_code,
                        trx_id,
                        trx_line_id,
                        summary_tax_line_number,
                        message_name,
                        message_text,
                        trx_level_type,
                        interface_line_id
                        )
                VALUES(
                        application_id,
                        entity_code,
                        event_class_code,
                        trx_id,
                        trx_line_id,
                        NULL,
                        'ZX_PRODUCT_TYPE_NA_FOR_LTE',
                        l_product_type_na_for_lte,
                        trx_level_type,
                        interface_line_id
                         )

              WHEN (TAX_RATE_CODE_NOT_EXISTS = 'Y')  THEN
                INTO ZX_VALIDATION_ERRORS_GT(
                        application_id,
                        entity_code,
                        event_class_code,
                        trx_id,
                        trx_line_id,
                        summary_tax_line_number,
                        message_name,
                        message_text,
                        trx_level_type,
                        interface_line_id
                        )
                VALUES(
                        application_id,
                        entity_code,
                        event_class_code,
                        trx_id,
                        trx_line_id,
                        NULL,
                        'ZX_TAX_RATE_NOT_EXIST',
                        l_tax_rate_not_exists,
                        trx_level_type,
                        interface_line_id
                        )

              WHEN (TAX_RATE_CODE_NOT_EXISTS = 'N' AND TAX_RATE_CODE_NOT_EFFECTIVE = 'Y')  THEN
                INTO ZX_VALIDATION_ERRORS_GT(
                        application_id,
                        entity_code,
                        event_class_code,
                        trx_id,
                        trx_line_id,
                        summary_tax_line_number,
                        message_name,
                        message_text,
                        trx_level_type,
                        interface_line_id
                        )
                VALUES(
                        application_id,
                        entity_code,
                        event_class_code,
                        trx_id,
                        trx_line_id,
                        NULL,
                        'ZX_TAX_RATE_NOT_EFFECTIVE',
                        l_tax_rate_not_effective,
                        trx_level_type,
                        interface_line_id
                        )

              WHEN (TAX_RATE_CODE_NOT_EXISTS = 'N' AND TAX_RATE_CODE_NOT_ACTIVE = 'Y')  THEN
                INTO ZX_VALIDATION_ERRORS_GT(
                        application_id,
                        entity_code,
                        event_class_code,
                        trx_id,
                        trx_line_id,
                        summary_tax_line_number,
                        message_name,
                        message_text,
                        trx_level_type,
                        interface_line_id
                        )
                VALUES(
                        application_id,
                        entity_code,
                        event_class_code,
                        trx_id,
                        trx_line_id,
                        NULL,
                        'ZX_TAX_RATE_NOT_ACTIVE',
                        l_tax_rate_not_active,
                        trx_level_type,
                        interface_line_id
                        )

              SELECT
                header.application_id,
                header.entity_code,
                header.event_class_code,
                header.trx_id,
                lines_gt.trx_line_id,
                lines_gt.trx_level_type,
                lines_gt.interface_line_id,
                -- Check for Event Class Existence
                CASE WHEN (evntmap.application_id is not null AND
                           evntmap.entity_code is not null AND
                           evntmap.event_class_code is not null)
                     THEN  NULL
                     ELSE  'Y'
                 END ZX_EVNT_CLS_MPG_INVALID,


                -- Check for existence of Exchange information
                CASE WHEN (header.ledger_id    = gsob.set_of_books_id AND
                           gsob.currency_code <> header.trx_currency_code AND
                           header.currency_conversion_rate is NULL AND
                           header.currency_conversion_date is NULL AND
                           header.currency_conversion_type is NULL
                           )
                     THEN 'Y'
                     ELSE 'N' --Note the change of yes, no value
                 END ZX_EXCHG_INFO_MISSING,

                -- Check for Validity of Transaction line class
                nvl2(lines_gt.line_class,
                     CASE WHEN (NOT EXISTS
                                (SELECT 1 FROM FND_LOOKUPS lkp
                                 WHERE lines_gt.line_class = lkp.lookup_code
                                 AND lkp.lookup_type = 'ZX_LINE_CLASS'))
                          THEN 'Y'
                          ELSE NULL
                     END,
                     NULL
                    ) ZX_LINE_CLASS_INVALID,

                -- Check for Validity of transaction line type
                CASE WHEN (lines_gt.trx_line_type NOT IN('ITEM','FREIGHT',
                                                         'MISC'))
                     THEN 'Y'
                     ELSE NULL
                END  ZX_TRX_LINE_TYPE_INVALID,

                -- Check for Validity of Line amount includes tax flag
                CASE WHEN (lines_gt.line_amt_includes_tax_flag
                           NOT IN ('A','N','S'))
                     THEN 'Y'
                     ELSE  NULL
                END  ZX_LINE_AMT_INCL_TAX_INVALID,


                /* need to add party types for O2C

                -- Check for SHIP_TO_PARTY_ID
                nvl2(lines_gt.SHIP_TO_PARTY_ID,
                     CASE WHEN (NOT EXISTS
                                (SELECT 1 FROM zx_party_tax_profile
                                 WHERE party_id =
                                       lines_gt.SHIP_TO_PARTY_ID
                                 AND  party_type_code = 'CUSTOMER'))
                           THEN 'Y'
                           ELSE NULL END,
                      NULL) SHIP_TO_PARTY_NOT_EXISTS,


                -- Check for BILL_TO_PARTY_ID
                nvl2(lines_gt.BILL_TO_PARTY_ID,
                     CASE WHEN (NOT EXISTS
                                (SELECT 1 FROM zx_party_tax_profile
                                 WHERE party_id =
                                       lines_gt.BILL_TO_PARTY_ID
                                 AND  party_type_code = 'CUSTOMER'))
                           THEN 'Y'
                           ELSE NULL END,
                      NULL) BILL_TO_PARTY_NOT_EXISTS,


                -- Check for SHIP_TO_PARTY_SITE_ID
                nvl2(lines_gt.SHIP_TO_PARTY_SITE_ID,
                     CASE WHEN (NOT EXISTS
                                (SELECT 1 FROM zx_party_tax_profile
                                 WHERE party_id =
                                       lines_gt.SHIP_TO_PARTY_SITE_ID
                                 AND  party_type_code = 'CUSTOMER_SITE'))
                           THEN 'Y'
                           ELSE NULL END,
                      NULL) SHIPTO_PARTY_SITE_NOT_EXISTS,

                -- Check for SHIP_FROM_PARTY_SITE_ID
                nvl2(lines_gt.SHIP_FROM_PARTY_SITE_ID,
                     CASE WHEN (NOT EXISTS
                                (SELECT 1 FROM zx_party_tax_profile
                                 WHERE party_id =
                                       lines_gt.SHIP_FROM_PARTY_SITE_ID
                                 AND  party_type_code = 'LEGAL_ESTABLISHMENT'))
                           THEN 'Y'
                           ELSE NULL END,
                      NULL) SHIPFROM_PARTY_SITE_NOT_EXISTS,

                -- Check for BILL_TO_PARTY_SITE_ID
                nvl2(lines_gt.BILL_TO_PARTY_SITE_ID,
                     CASE WHEN (NOT EXISTS
                                (SELECT 1 FROM zx_party_tax_profile
                                 WHERE party_id =
                                       lines_gt.BILL_TO_PARTY_SITE_ID
                                 AND  party_type_code = 'CUSTOMER_SITE'))
                           THEN 'Y'
                           ELSE NULL END,
                      NULL) BILLTO_PARTY_SITE_NOT_EXISTS
                */

                -- Check for User-Defined Fiscal Classification
                  CASE WHEN (lines_gt.USER_DEFINED_FISC_CLASS is not null)
                        THEN 'Y'
                        ELSE NULL
                  END USER_DEF_FC_NA_FOR_LTE,

                /*
                -- Commented the validation as Product Category
                -- is populated for Memo Lines
                  CASE WHEN (lines_gt.PRODUCT_CATEGORY is not null)
                        THEN 'Y'
                        ELSE NULL
                  END PRODUCT_CATEGORY_NA_FOR_LTE,
                */

                -- Check for Document Subtype
                  CASE WHEN (header.DOCUMENT_SUB_TYPE is not null)
                        THEN 'Y'
                        ELSE NULL
                  END DOCUMENT_FC_NA_FOR_LTE,

                -- Check for Line Intended Use
                  CASE WHEN (lines_gt.LINE_INTENDED_USE is not null)
                        THEN 'Y'
                        ELSE NULL
                  END INTENDED_USE_NA_FOR_LTE,

                -- Check for Product Type
                  CASE WHEN (lines_gt.PRODUCT_TYPE is not null)
                        THEN 'Y'
                        ELSE NULL
                  END PRODUCT_TYPE_NA_FOR_LTE,

                  -- Check Tax Classification Code exists
                  CASE WHEN lines_gt.output_tax_classification_code IS NOT NULL
                        AND NOT EXISTS (SELECT 1
                                        FROM zx_output_classifications_v
                                        WHERE lookup_code = lines_gt.output_tax_classification_code
                                        AND org_id in (header.internal_organization_id, -99))
                        THEN 'Y'
                        ELSE NULL
                  END TAX_RATE_CODE_NOT_EXISTS,

                  -- Check Tax Classification Code is effective
                  CASE WHEN lines_gt.output_tax_classification_code IS NOT NULL
                       AND NOT EXISTS (SELECT 1
                                        FROM zx_output_classifications_v
                                        WHERE lookup_code = lines_gt.output_tax_classification_code
                                        AND org_id in (header.internal_organization_id, -99)
                                        AND header.trx_date BETWEEN start_date_active
                                            AND nvl(end_date_active,header.trx_date))
                       THEN 'Y'
                       ELSE NULL
                  END TAX_RATE_CODE_NOT_EFFECTIVE,

                  -- Check Tax Classification Code is Active
                  CASE WHEN lines_gt.output_tax_classification_code IS NOT NULL
                       AND NOT EXISTS (SELECT 1
                                        FROM zx_output_classifications_v
                                        WHERE lookup_code = lines_gt.output_tax_classification_code
                                        AND org_id in (header.internal_organization_id, -99)
                                        AND enabled_flag = 'Y')
                       THEN 'Y'
                       ELSE NULL
                  END TAX_RATE_CODE_NOT_ACTIVE

              FROM
                  ZX_TRX_HEADERS_GT             header,
                  ZX_EVNT_CLS_MAPPINGS          evntmap,
                  ZX_TRANSACTION_LINES_GT       lines_gt,
                  GL_SETS_OF_BOOKS              gsob

              WHERE
                    lines_gt.trx_id = header.trx_id
                and gsob.set_of_books_id(+)   = header.ledger_id
                and lines_gt.application_id   = Header.application_id
                and lines_gt.entity_code      = Header.entity_code
                and lines_gt.event_class_code = Header.event_class_code
                and header.application_id     = evntmap.application_id (+)
                and header.entity_code        = evntmap.entity_code (+)
                and header.event_class_code   = evntmap.event_class_code(+);

   IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.VALIDATE_TAX_ATTR',
                     'Line Level Validation Errors : '|| To_Char(SQL%ROWCOUNT) );
   END IF;

   -- Run Tax Line Level Validation for manual tax lines (if any)
   IF nvl(g_tax_lines_count,0) > 0 THEN

      IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure,
                        'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.VALIDATE_TAX_ATTR',
                        'Running Manual Tax Line Level Validations...');
      END IF;

        INSERT ALL
        WHEN (REGIME_NOT_EXISTS = 'Y') THEN
                INTO ZX_VALIDATION_ERRORS_GT(
                        application_id,
                        entity_code,
                        event_class_code,
                        trx_id,
                        trx_line_id,
                        summary_tax_line_number,
                        message_name,
                        message_text,
                        trx_level_type,
                        interface_tax_line_id
                        )
                VALUES(
                        application_id,
                        entity_code,
                        event_class_code,
                        trx_id,
                        trx_line_id,
                        summary_tax_line_number,
                        'ZX_REGIME_NOT_EXIST',
                        l_regime_not_exists,
                        trx_level_type,
                        interface_tax_line_id
                         )

        WHEN (REGIME_NOT_EFF_IN_SUBSCR = 'Y') THEN
                INTO ZX_VALIDATION_ERRORS_GT(
                        application_id,
                        entity_code,
                        event_class_code,
                        trx_id,
                        trx_line_id,
                        summary_tax_line_number,
                        message_name,
                        message_text,
                        trx_level_type,
                        interface_tax_line_id
                        )
                VALUES(
                        application_id,
                        entity_code,
                        event_class_code,
                        trx_id,
                        trx_line_id,
                        summary_tax_line_number,
                        'ZX_REGIME_NOT_EFF_IN_SUBSCR',
                        l_regime_not_eff_in_subscr,
                        trx_level_type,
                        interface_tax_line_id
                         )
        WHEN (REGIME_NOT_EFFECTIVE = 'Y')  THEN
                INTO ZX_VALIDATION_ERRORS_GT(
                        application_id,
                        entity_code,
                        event_class_code,
                        trx_id,
                        trx_line_id,
                        summary_tax_line_number,
                        message_name,
                        message_text,
                        trx_level_type,
                        interface_tax_line_id
                        )
                VALUES(
                        application_id,
                        entity_code,
                        event_class_code,
                        trx_id,
                        trx_line_id,
                        summary_tax_line_number,
                        'ZX_REGIME_NOT_EFFECTIVE',
                        l_regime_not_effective,
                        trx_level_type,
                        interface_tax_line_id
                         )

        WHEN (TAX_NOT_EXISTS = 'Y')  THEN
                        INTO ZX_VALIDATION_ERRORS_GT(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                summary_tax_line_number,
                                message_name,
                                message_text,
                                trx_level_type,
                                interface_tax_line_id
                                )
                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                summary_tax_line_number,
                                'ZX_TAX_NOT_EXIST',
                                l_tax_not_exists,
                                trx_level_type,
                                interface_tax_line_id
                                 )

        WHEN (TAX_NOT_LIVE = 'Y')  THEN
                        INTO ZX_VALIDATION_ERRORS_GT(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                summary_tax_line_number,
                                message_name,
                                message_text,
                                trx_level_type,
                                interface_tax_line_id
                                )
                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                summary_tax_line_number,
                                'ZX_TAX_NOT_LIVE',
                                l_tax_not_live,
                                trx_level_type,
                                interface_tax_line_id
                                 )

        WHEN (TAX_NOT_EFFECTIVE = 'Y')  THEN
                        INTO ZX_VALIDATION_ERRORS_GT(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                summary_tax_line_number,
                                message_name,
                                message_text,
                                trx_level_type,
                                interface_tax_line_id
                                )
                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                summary_tax_line_number,
                                'ZX_TAX_NOT_EFFECTIVE',
                                l_tax_not_effective,
                                trx_level_type,
                                interface_tax_line_id
                                 )

        WHEN (TAX_STATUS_NOT_EXISTS = 'Y')  THEN
                        INTO ZX_VALIDATION_ERRORS_GT(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                summary_tax_line_number,
                                message_name,
                                message_text,
                                trx_level_type,
                                interface_tax_line_id
                                )
                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                summary_tax_line_number,
                                'ZX_TAX_STATUS_NOT_EXIST',
                                l_tax_status_not_exists,
                                trx_level_type,
                                interface_tax_line_id
                                 )

        WHEN (TAX_STATUS_NOT_EFFECTIVE = 'Y')  THEN
                        INTO ZX_VALIDATION_ERRORS_GT(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                summary_tax_line_number,
                                message_name,
                                message_text,
                                trx_level_type,
                                interface_tax_line_id
                                )
                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                summary_tax_line_number,
                                'ZX_TAX_STATUS_NOT_EFFECTIVE',
                                l_tax_status_not_effective,
                                trx_level_type,
                                interface_tax_line_id
                                 )

        WHEN (TAX_JUR_CODE_NA_FOR_LTE = 'Y') THEN
                        INTO ZX_VALIDATION_ERRORS_GT(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                summary_tax_line_number,
                                message_name,
                                message_text,
                                trx_level_type,
                                interface_tax_line_id
                                )
                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                summary_tax_line_number,
                                'ZX_TAX_JUR_CODE_NA_FOR_LTE',
                                l_tax_jur_code_na_for_lte,
                                trx_level_type,
                                interface_tax_line_id
                                )

                SELECT
                header.application_id,
                header.entity_code,
                header.event_class_code,
                header.trx_id,
                lines_gt.trx_line_id,
                lines_gt.trx_level_type,
                taxlines_gt.interface_tax_line_id,
                taxlines_gt.summary_tax_line_number,
                -- Check for Regime Existence
                CASE WHEN taxlines_gt.tax_regime_code IS NOT NULL AND
                          regime.tax_regime_code IS NULL
                     THEN 'Y'
                     ELSE 'N'
                END  REGIME_NOT_EXISTS,

                -- Check for Regime Effectivity in surscription detail table
                CASE WHEN taxlines_gt.tax_regime_code IS NOT NULL
                          AND regime.tax_regime_code IS NOT NULL
                     THEN
                     CASE WHEN sd_reg.tax_regime_code IS NULL
                          THEN 'Y'
                          ELSE 'N' END
                     ELSE 'N'
                END REGIME_NOT_EFF_IN_SUBSCR,

                -- Check for Regime Effectivity
                CASE WHEN taxlines_gt.tax_regime_code IS NOT NULL
                          AND regime.tax_regime_code IS NOT NULL
                          AND sd_reg.tax_regime_code IS NOT NULL
                     THEN
                     CASE WHEN header.trx_date
                               BETWEEN regime.effective_from
                               AND NVL(regime.effective_to,header.trx_date)
                          THEN 'N'
                          ELSE 'Y' END
                     ELSE 'N'
                END REGIME_NOT_EFFECTIVE,

                -- Check for Tax Existence
                nvl2(taxlines_gt.tax,
                     CASE WHEN (sd_tax.tax_regime_code IS NOT NULL AND
                                tax.tax is not null)
                          THEN 'N'
                          ELSE 'Y' END,
                     'N') TAX_NOT_EXISTS,

                -- Check for Tax Live flag
                nvl2(taxlines_gt.tax,
                     CASE WHEN (sd_tax.tax_regime_code IS NOT NULL AND
                                tax.tax is not NULL )
                          THEN
                          CASE WHEN tax.live_for_processing_flag = 'Y'
                               THEN 'N'
                               ELSE 'Y' END
                          ELSE 'N' END,
                     'N') TAX_NOT_LIVE,

                -- Check for Tax Effectivity
                nvl2(taxlines_gt.tax,
                     CASE WHEN (sd_tax.tax_regime_code IS NOT NULL AND
                                tax.tax is not null)
                          THEN
                          CASE WHEN header.trx_date
                                    BETWEEN tax.effective_from AND
                                    NVL(tax.effective_to,header.trx_date)
                               THEN 'N'
                               ELSE 'Y' END
                          ELSE 'N' END ,
                     'N')  TAX_NOT_EFFECTIVE,

                -- Check for Status Existence
                nvl2(taxlines_gt.tax_status_code,
                     CASE WHEN(sd_status.tax_regime_code IS NOT NULL AND
                               status.tax_status_code is not null)
                          THEN 'N'
                          ELSE 'Y' END,
                     'N') TAX_STATUS_NOT_EXISTS,

                -- Check for Status Effectivity
                nvl2(taxlines_gt.tax_status_code,
                     CASE WHEN(sd_status.tax_regime_code IS NOT NULL AND
                               status.tax_status_code IS NOT NULL)
                          THEN  CASE WHEN header.trx_date
                                     BETWEEN status.effective_from AND
                                     nvl(status.effective_to,header.trx_date)
                                THEN 'N'
                                ELSE 'Y' END
                          ELSE 'N' END,
                     'N') TAX_STATUS_NOT_EFFECTIVE,

                -- Check for Tax Jurisdiction
                CASE WHEN (taxlines_gt.TAX_JURISDICTION_CODE IS NOT NULL)
                     THEN 'Y'
                     ELSE 'N'
                END TAX_JUR_CODE_NA_FOR_LTE

              FROM
                     ZX_TRX_HEADERS_GT             header,
                     ZX_REGIMES_B                  regime,
                     ZX_TAXES_B                    tax,
                     ZX_STATUS_B                   status,
                     ZX_TRANSACTION_LINES_GT       lines_gt,
                     ZX_IMPORT_TAX_LINES_GT        taxlines_gt,
                     ZX_SUBSCRIPTION_DETAILS       sd_reg,
                     ZX_SUBSCRIPTION_DETAILS       sd_tax,
                     ZX_SUBSCRIPTION_DETAILS       sd_status

              WHERE
                    lines_gt.trx_id = header.trx_id
                AND taxlines_gt.trx_id  = header.trx_id
                AND taxlines_gt.application_id = Header.application_id
                AND taxlines_gt.entity_code    = Header.entity_code
                AND taxlines_gt.event_class_code
                                             = Header.event_class_code
                AND header.application_id    = lines_gt.application_id
                AND header.entity_code       = lines_gt.entity_code
                AND header.event_class_code  = lines_gt.event_class_code
                AND lines_gt.trx_line_id     = taxlines_gt.trx_line_id
               -- Regime
                AND regime.tax_regime_code(+)= taxlines_gt.tax_regime_code
                AND regime.tax_regime_code = sd_reg.tax_regime_code (+)
                AND sd_reg.first_pty_org_id(+) = g_first_pty_org_id
                AND NVL(sd_reg.view_options_code,'NONE') in ('NONE', 'VFC')
                AND (header.trx_date BETWEEN
                     nvl(regime.effective_from,header.trx_date) AND
                     nvl(regime.effective_to, header.trx_date)
                     OR
                     regime.effective_from = (select min(effective_from)
                                              from zx_regimes_b
                                              where tax_regime_code =
                                              regime.tax_regime_code)
                     )
                AND (header.trx_date between
                      nvl(sd_reg.effective_from, header.trx_date) AND
                      nvl(sd_reg.effective_to, header.trx_date)
                     )
                -- Tax
                AND tax.tax(+) = taxlines_gt.tax
                AND tax.tax_regime_code(+) = taxlines_gt.tax_regime_code
                AND tax.tax_regime_code = sd_tax.tax_regime_code (+)
                AND (tax.content_owner_id = sd_tax.parent_first_pty_org_id  or
                     sd_tax.parent_first_pty_org_id is null)
                AND sd_tax.first_pty_org_id(+) = g_first_pty_org_id
                AND (header.trx_date BETWEEN
                     nvl(tax.effective_from,header.trx_date) AND
                     nvl(tax.effective_to, header.trx_date)
                     OR
                     tax.effective_from = (select min(effective_from)
                                           from zx_taxes_b
                                           where tax = tax.tax)
                    )
                AND (header.trx_date between
                     nvl(sd_tax.effective_from,header.trx_date) AND
                     NVL(sd_tax.effective_to,header.trx_date)
                    )
                AND ( nvl(sd_tax.view_options_code,'NONE') in ('NONE', 'VFC')
                      or
                      ( nvl(sd_tax.view_options_code,'VFR') = 'VFR'
                        AND not exists
                        ( SELECT 1
                          FROM zx_taxes_b b
                          WHERE tax.tax_regime_code = b.tax_regime_code
                          AND tax.tax = b.tax
                          AND sd_tax.first_pty_org_id = b.content_owner_id )
                      )
                    )
                -- Status
                AND status.tax_status_code(+) = taxlines_gt.tax_status_code
                AND status.tax(+) = taxlines_gt.tax
                AND status.tax_regime_code(+) = taxlines_gt.tax_regime_code
                AND status.tax_regime_code = sd_status.tax_regime_code (+)
                AND (status.content_owner_id = sd_status.parent_first_pty_org_id
                     or sd_status.parent_first_pty_org_id is null)
                AND sd_status.first_pty_org_id(+) = g_first_pty_org_id
                AND (header.trx_date BETWEEN
                     nvl(status.effective_from,header.trx_date) AND
                     nvl(status.effective_to, header.trx_date)
                     OR
                     status.effective_from = (select min(effective_from)
                                              from zx_status_b
                                              where tax_status_code =
                                              status.tax_status_code)
                    )
                AND (header.trx_date between
                     nvl(sd_status.effective_from,header.trx_date) AND
                     nvl(sd_status.effective_to,header.trx_date)
                    )
                AND (nvl(sd_status.view_options_code,'NONE') in ('NONE', 'VFC')
                     or (nvl(sd_status.view_options_code,'VFR') = 'VFR'
                         AND not exists
                         (SELECT 1
                            FROM zx_status_vl b
                           WHERE b.tax_regime_code = status.tax_regime_code
                             AND b.tax = status.tax
                             AND b.tax_status_code = status.tax_status_code
                             AND b.content_owner_id = sd_status.first_pty_org_id)
                        )
                    );

      IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure,
                        'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.VALIDATE_TAX_ATTR',
                        'Regime, Tax and Status Validation Errors : '|| To_Char(SQL%ROWCOUNT) );
      END IF;

        INSERT ALL
        WHEN (TAX_RATE_CODE_NOT_EXISTS = 'Y')  THEN
                        INTO ZX_VALIDATION_ERRORS_GT(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                summary_tax_line_number,
                                message_name,
                                message_text,
                                trx_level_type,
                                interface_tax_line_id
                                )
                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                NULL,
                                summary_tax_line_number,
                                'ZX_TAX_RATE_NOT_EXIST',
                                l_tax_rate_not_exists,
                                NULL,
                                interface_tax_line_id
                                 )

        WHEN (TAX_RATE_CODE_NOT_EFFECTIVE = 'Y')  THEN
                        INTO ZX_VALIDATION_ERRORS_GT(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                summary_tax_line_number,
                                message_name,
                                message_text,
                                trx_level_type,
                                interface_tax_line_id
                                )
                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                NULL,
                                summary_tax_line_number,
                                'ZX_TAX_RATE_NOT_EFFECTIVE',
                                l_tax_rate_not_effective,
                                NULL,
                                interface_tax_line_id
                                )

        WHEN (TAX_RATE_CODE_NOT_ACTIVE = 'Y')  THEN
                        INTO ZX_VALIDATION_ERRORS_GT(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                summary_tax_line_number,
                                message_name,
                                message_text,
                                trx_level_type,
                                interface_tax_line_id
                                )
                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                NULL,
                                summary_tax_line_number,
                                'ZX_TAX_RATE_NOT_ACTIVE',
                                l_tax_rate_not_active,
                                NULL,
                                interface_tax_line_id
                                 )

        WHEN (TAX_RATE_PERCENTAGE_INVALID = 'Y')  THEN
                        INTO ZX_VALIDATION_ERRORS_GT(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                summary_tax_line_number,
                                message_name,
                                message_text,
                                trx_level_type,
                                interface_tax_line_id
                                )
                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                NULL,
                                summary_tax_line_number,
                                'ZX_TAX_RATE_PERCENTAGE_INVALID',
                                l_tax_rate_percentage_invalid,
                                NULL,
                                interface_tax_line_id
                                 )
        SELECT  application_id,
                entity_code,
                event_class_code,
                trx_id,
                summary_tax_line_number,
                interface_tax_line_id,
                interface_line_id,
                trx_line_id,
                trx_level_type,
                TAX_RATE_CODE_NOT_EXISTS,
                DECODE(TAX_RATE_CODE_NOT_EXISTS,'Y','N',TAX_RATE_CODE_NOT_EFFECTIVE) TAX_RATE_CODE_NOT_EFFECTIVE,
                DECODE(TAX_RATE_CODE_NOT_EXISTS,'Y','N',TAX_RATE_CODE_NOT_ACTIVE) TAX_RATE_CODE_NOT_ACTIVE,
                DECODE(TAX_RATE_CODE_NOT_EXISTS,'Y','N',TAX_RATE_PERCENTAGE_INVALID) TAX_RATE_PERCENTAGE_INVALID
          FROM
              (SELECT
                  header.application_id application_id,
                  header.entity_code entity_code,
                  header.event_class_code,
                  header.trx_id trx_id,
                  taxlines_gt.summary_tax_line_number summary_tax_line_number,
                  taxlines_gt.summary_tax_line_number interface_tax_line_id,
                  lines_gt.trx_line_id     interface_line_id,
                  lines_gt.trx_line_id     trx_line_id,
                  lines_gt.trx_level_type  trx_level_type,
                  -- Check for Rate Code Existence
                  nvl2(taxlines_gt.tax_rate_code,
                       CASE WHEN (sd_rates.tax_regime_code is not null and
                                  rate.tax_rate_code is not NULL )
                             THEN CASE WHEN taxlines_gt.tax_rate_id IS NOT NULL
                                            AND NOT EXISTS ( SELECT 1 FROM zx_rates_b
                                                              WHERE tax_rate_id = taxlines_gt.tax_rate_id)
                                       THEN 'Y'
                                       ELSE 'N' END
                             ELSE 'Y' END,
                       'N') TAX_RATE_CODE_NOT_EXISTS,
                  -- Check for Rate Code Effective
                  nvl2(taxlines_gt.tax_rate_code,
                       CASE WHEN header.trx_date BETWEEN rate.effective_from AND
                                 nvl(rate.effective_to, header.trx_date)
                            THEN 'N'
                            ELSE 'Y' END,
                       'N') TAX_RATE_CODE_NOT_EFFECTIVE,
                  -- Check Rate Code is Active
                  nvl2(taxlines_gt.tax_rate_code,
                       CASE WHEN rate.active_flag = 'Y'
                            THEN 'N'
                            ELSE 'Y' END,
                       'N') TAX_RATE_CODE_NOT_ACTIVE,
                  -- Check for Rate Percentage
                  nvl2(taxlines_gt.tax_rate_code,
                       CASE WHEN  taxlines_gt.tax_rate IS NOT NULL
                                  AND rate.percentage_rate <> taxlines_gt.tax_rate
                                  AND nvl(rate.allow_adhoc_tax_rate_flag,'N') <> 'Y'
                                  AND header.trx_date BETWEEN rate.effective_from AND
                                      nvl(rate.effective_to, header.trx_date)
                            THEN 'Y'
                            ELSE 'N' END,
                       'N') TAX_RATE_PERCENTAGE_INVALID
                 FROM ZX_TRX_HEADERS_GT header,
                      ZX_RATES_B rate ,
                      ZX_IMPORT_TAX_LINES_GT taxlines_gt,
                      ZX_TRANSACTION_LINES_GT lines_gt,
                      ZX_SUBSCRIPTION_DETAILS sd_rates
                WHERE taxlines_gt.trx_id = header.trx_id
                  AND taxlines_gt.application_id = Header.application_id
                  AND taxlines_gt.entity_code = Header.entity_code
                  AND taxlines_gt.event_class_code = Header.event_class_code
                  AND (taxlines_gt.tax_rate_code IS NOT NULL OR taxlines_gt.tax_rate_id IS NOT NULL)
                  AND lines_gt.application_id = header.application_id
                  AND lines_gt.entity_code = header.entity_code
                  AND lines_gt.event_class_code = header.event_class_code
                  AND lines_gt.trx_id = header.trx_id
                  AND lines_gt.trx_line_id = taxlines_gt.trx_line_id
                  AND ((taxlines_gt.tax_rate_code IS NOT NULL AND
                        rate.tax_rate_code = taxlines_gt.tax_rate_code)
                      OR
                       (taxlines_gt.tax_rate_id IS NOT NULL AND
                        rate.tax_rate_id = taxlines_gt.tax_rate_id))
                  AND (taxlines_gt.tax_status_code IS NULL OR rate.tax_status_code = taxlines_gt.tax_status_code)
                  AND (taxlines_gt.tax IS NULL OR rate.tax = taxlines_gt.tax)
                  AND (taxlines_gt.tax_regime_code IS NULL OR rate.tax_regime_code = taxlines_gt.tax_regime_code)
                  AND rate.tax_regime_code = sd_rates.tax_regime_code (+)
                  AND (rate.content_owner_id = sd_rates.parent_first_pty_org_id
                       OR sd_rates.parent_first_pty_org_id is NULL)
                  AND sd_rates.first_pty_org_id(+) = g_first_pty_org_id
                  AND (header.trx_date BETWEEN
                              nvl(sd_rates.effective_from,header.trx_date) AND
                              nvl(sd_rates.effective_to,header.trx_date)
                      )
                  AND (NVL(sd_rates.view_options_code,'NONE') IN ('NONE', 'VFC')
                       OR (NVL(sd_rates.view_options_code, 'VFR') = 'VFR'
                           AND NOT EXISTS
                           (SELECT 1
                              FROM zx_rates_b b
                             WHERE b.tax_regime_code = rate.tax_regime_code
                               AND b.tax = rate.tax
                               AND b.tax_status_code = rate.tax_status_code
                               AND b.tax_rate_code = rate.tax_rate_code
                               AND b.content_owner_id = sd_rates.first_pty_org_id
                           )
                          )
                      )
              );

      IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure,
                        'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.VALIDATE_TAX_ATTR',
                        'Tax Rate Validation Errors : '|| To_Char(SQL%ROWCOUNT) );
      END IF;

       INSERT ALL
            WHEN (SAMESUMTX_MULTIALLOC_TO_SAMELN = 'Y') THEN
              INTO zx_validation_errors_gt(
                   application_id,
                   entity_code,
                   event_class_code,
                   trx_id,
                   trx_line_id,
                   summary_tax_line_number,
                   message_name,
                   message_text,
                   trx_level_type,
                   interface_tax_line_id
                    )
              VALUES (
                   application_id,
                   entity_code,
                   event_class_code,
                   trx_id,
                   trx_line_id,
                   summary_tax_line_number,
                   'ZX_IMPTAX_MULTIALLOC_TO_SAMELN',
                   l_imptax_multialloc_to_sameln,
                   trx_level_type,
                   interface_tax_line_id
                    )

           /* bug 3698554 */

            WHEN (TAX_INCL_FLAG_MISMATCH = 'Y' ) THEN
              INTO zx_validation_errors_gt(
                   application_id,
                   entity_code,
                   event_class_code,
                   trx_id,
                   trx_line_id,
                   summary_tax_line_number,
                   message_name,
                   message_text,
                   trx_level_type,
                   interface_tax_line_id
                    )
              VALUES (
                   application_id,
                   entity_code,
                   event_class_code,
                   trx_id,
                   trx_line_id,
                   summary_tax_line_number,
                   'ZX_TAX_INCL_FLAG_MISMATCH',
                   l_tax_incl_flag_mismatch,
                   trx_level_type,
                   interface_tax_line_id
                  )

            WHEN (IMP_TAX_MISSING_IN_ADJUSTED_TO = 'Y') THEN
              INTO zx_validation_errors_gt(
                   application_id,
                   entity_code,
                   event_class_code,
                   trx_id,
                   trx_line_id,
                   summary_tax_line_number,
                   message_name,
                   message_text,
                   trx_level_type,
                   interface_tax_line_id
                    )
            VALUES (
                   application_id,
                   entity_code,
                   event_class_code,
                   trx_id,
                   trx_line_id,
                   summary_tax_line_number,
                   'IMP_TAX_MISSING_IN_ADJUSTED_TO',
                   l_imp_tax_missing_in_adjust_to,
                   trx_level_type,
                   interface_tax_line_id
                   )

            /* end bug 3698554 */

            SELECT
                   header.application_id,
                   header.entity_code,
                   header.event_class_code,
                   header.trx_id,
                   lines_gt.trx_line_id,
                   lines_gt.trx_level_type,
                   lines_gt.interface_line_id,
                   taxlines_gt.interface_tax_line_id,
                   taxlines_gt.summary_tax_line_number,
                   -- The same summary tax line cannot be allocated to the same transaction
                   -- line multi times
                   --
                   CASE
                     WHEN
                      (SELECT COUNT(*)
                         FROM zx_trx_tax_link_gt
                        WHERE application_id = taxlines_gt.application_id
                          AND entity_code = taxlines_gt.entity_code
                          AND event_class_code = taxlines_gt.event_class_code
                          AND trx_id = taxlines_gt.trx_id
                          AND trx_line_id = lines_gt.trx_line_id
                          AND trx_level_type = lines_gt.trx_level_type
                          AND summary_tax_line_number =
                                                  taxlines_gt.summary_tax_line_number
                      ) > 1
                     THEN
                         'Y'
                     ELSE
                         'N'
                   END SAMESUMTX_MULTIALLOC_TO_SAMELN,

                  /* bug 3698554 */

                  -- If the imported tax line has inclusive_flag = 'N' but the tax
                  -- is defined as inclusive in ZX_TAXES and allow inclusive override is N
                  -- or vice versa, then raise error
                  CASE
                     WHEN EXISTS
                          (
                          SELECT 1
                            FROM zx_taxes_b taxes
                           WHERE taxes.tax_regime_code = taxlines_gt.tax_regime_code
                             AND taxes.tax = taxlines_gt.tax
                             AND taxes.def_inclusive_tax_flag <> taxlines_gt.tax_amt_included_flag
                             AND taxes.tax_inclusive_override_flag = 'N'
                          )
                  THEN
                           'Y'
                     ELSE
                          'N'
                   END TAX_INCL_FLAG_MISMATCH,
                   /* end bug 3698554  */

                   CASE
                     WHEN lines_gt.adjusted_doc_application_id IS NOT NULL
                      AND NOT EXISTS
                          (SELECT 1
                             FROM zx_lines zl
                            WHERE zl.application_id = lines_gt.adjusted_doc_application_id
                              AND zl.entity_code = lines_gt.adjusted_doc_entity_code
                              AND zl.event_class_code = lines_gt.adjusted_doc_event_class_code
                              AND zl.trx_id = lines_gt.adjusted_doc_trx_id
                              AND zl.trx_line_id = lines_gt.adjusted_doc_line_id
                              AND zl.trx_level_type = lines_gt.adjusted_doc_trx_level_type
                              AND zl.tax_regime_code = taxlines_gt.tax_regime_code
                              AND zl.tax = taxlines_gt.tax
                          )
                     THEN
                         'Y'
                     ELSE
                         'N'
                   END IMP_TAX_MISSING_IN_ADJUSTED_TO
                   /* end bug 3676878  */
               FROM
                   zx_trx_headers_gt         header,
                   zx_transaction_lines_gt   lines_gt,
                   zx_import_tax_lines_gt    taxlines_gt
               WHERE
                   taxlines_gt.application_id = header.application_id
               AND taxlines_gt.entity_code = header.entity_code
               AND taxlines_gt.event_class_code = header.event_class_code
               AND taxlines_gt.trx_id = header.trx_id
               AND lines_gt.application_id = header.application_id
               AND lines_gt.entity_code = header.entity_code
               AND lines_gt.event_class_code = header.event_class_code
               AND lines_gt.trx_id = header.trx_id
               AND lines_gt.trx_line_id = taxlines_gt.trx_line_id
               AND (taxlines_gt.tax_line_allocation_flag = 'Y'
                    AND EXISTS
                    (SELECT 1
                       FROM zx_trx_tax_link_gt
                      WHERE application_id = taxlines_gt.application_id
                        AND entity_code = taxlines_gt.entity_code
                        AND event_class_code = taxlines_gt.event_class_code
                        AND trx_id = taxlines_gt.trx_id
                        AND summary_tax_line_number = taxlines_gt.summary_tax_line_number
                        AND trx_line_id = lines_gt.trx_line_id
                        AND trx_level_type = lines_gt.trx_level_type
                    ) OR
                    (taxlines_gt.tax_line_allocation_flag = 'N'
                     AND lines_gt.applied_from_application_id IS NULL
                     AND lines_gt.adjusted_doc_application_id IS NULL
                     AND lines_gt.applied_to_application_id IS NULL
                     AND lines_gt.line_level_action = 'CREATE_WITH_TAX'
                    )
                   );

      IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure,
                        'JL.PL/SQL.JL_ZZ_TAX_VALIDATE_PKG.VALIDATE_TAX_ATTR',
                        'Tax Allocation Validation Errors : '|| To_Char(SQL%ROWCOUNT) );
      END IF;

   END IF; -- IF g_tax_lines_count > 0


  EXCEPTION
         WHEN OTHERS THEN
              IF (g_level_unexpected >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_unexpected,
                                 'JL_ZZ_TAX_VALIDATE_PKG.VALIDATE_TAX_ATTR',
                                 sqlerrm);
              END IF;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              app_exception.raise_exception;

END validate_tax_attr;

--Constructor
BEGIN

  g_level_statement       := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure       := FND_LOG.LEVEL_PROCEDURE;
  g_level_event           := FND_LOG.LEVEL_EVENT;
  g_level_exception       := FND_LOG.LEVEL_EXCEPTION;
  g_level_unexpected      := FND_LOG.LEVEL_UNEXPECTED;
  l_regime_not_exists           :=fnd_message.get_string('ZX','ZX_REGIME_NOT_EXIST' );
  l_regime_not_effective        :=fnd_message.get_string('ZX','ZX_REGIME_NOT_EFFECTIVE' );
  l_regime_not_eff_in_subscr    :=fnd_message.get_string('ZX','ZX_REGIME_NOT_EFF_IN_SUBSCR' );
  l_tax_not_exists              :=fnd_message.get_string('ZX','ZX_TAX_NOT_EXIST' );
  l_tax_not_live                :=fnd_message.get_string('ZX','ZX_TAX_NOT_LIVE' );
  l_tax_not_effective           :=fnd_message.get_string('ZX','ZX_TAX_NOT_EFFECTIVE' );
  l_tax_status_not_exists       :=fnd_message.get_string('ZX','ZX_TAX_STATUS_NOT_EXIST' );
  l_tax_status_not_effective    :=fnd_message.get_string('ZX','ZX_TAX_STATUS_NOT_EFFECTIVE' );
  l_tax_rate_not_exists         :=fnd_message.get_string('ZX','ZX_TAX_RATE_NOT_EXIST' );
  l_tax_rate_not_effective      :=fnd_message.get_string('ZX','ZX_TAX_RATE_NOT_EFFECTIVE' );
  l_tax_rate_not_active         :=fnd_message.get_string('ZX','ZX_TAX_RATE_NOT_ACTIVE' );
  l_tax_rate_percentage_invalid :=fnd_message.get_string('ZX','ZX_TAX_RATE_PERCENTAGE_INVALID' );
  l_evnt_cls_mpg_invalid        :=fnd_message.get_string('ZX','ZX_EVNT_CLS_MPG_INVALID' );
  l_exchg_info_missing          :=fnd_message.get_string('ZX','ZX_EXCHG_INFO_MISSING' );
  l_line_class_invalid          :=fnd_message.get_string('ZX','ZX_LINE_CLASS_INVALID' );
  l_trx_line_type_invalid       :=fnd_message.get_string('ZX','ZX_TRX_LINE_TYPE_INVALID' );
  l_line_amt_incl_tax_invalid   :=fnd_message.get_string('ZX','ZX_LINE_AMT_INCTAX_INVALID' );
  l_trx_biz_fc_code_not_exists  :=fnd_message.get_string('ZX','ZX_TRX_BIZ_FC_CODE_NOT_EXIST' );
  l_trx_biz_fc_code_not_effect  :=fnd_message.get_string('ZX','ZX_TRX_BIZ_FC_CODE_NOT_EFFECT' );
  l_prd_fc_code_not_exists      :=fnd_message.get_string('ZX','ZX_PRODUCT_FC_CODE_NOT_EXIST' );
  l_prd_category_not_exists     :=fnd_message.get_string('ZX','ZX_PRODUCT_CATEGORY_NOT_EXIST' );
  l_ship_to_party_not_exists    :=fnd_message.get_string('ZX','ZX_SHIP_TO_PARTY_NOT_EXIST' );
  l_ship_frm_party_not_exits    :=fnd_message.get_string('ZX','ZX_SHIP_FROM_PARTY_NOT_EXIST' );
  l_bill_to_party_not_exists    :=fnd_message.get_string('ZX','ZX_BILTO_PARTY_NOT_EXIST' );
  l_shipto_party_site_not_exists:=fnd_message.get_string('ZX','ZX_SHIPTO_PARTY_SITE_NOT_EXIST' );
  l_billto_party_site_not_exists:=fnd_message.get_string('ZX','ZX_BILLTO_PARTY_SITE_NOT_EXIST' );
  l_billfrm_party_site_not_exist:=fnd_message.get_string('ZX','ZX_BILLFROM_PARTYSITE_NOTEXIST' );
  l_tax_multialloc_to_sameln    :=fnd_message.get_string('ZX','ZX_TAX_MULTIALLOC_TO_SAMELN' );
  l_imptax_multialloc_to_sameln :=fnd_message.get_string('ZX','ZX_IMPTAX_MULTIALLOC_TO_SAMELN' );
--l_tax_only_ln_w_null_tax_amt  :=fnd_message.get_string('ZX','ZX_TAX_ONLY_LN_W_NULL_TAX_AMT' );
  l_tax_incl_flag_mismatch      :=fnd_message.get_string('ZX','ZX_TAX_INCL_FLAG_MISMATCH' );
--l_product_category_na_for_lte :=fnd_message.get_string('ZX','ZX_PRODUCT_CATEGORY_NA_FOR_LTE' );
  l_user_def_fc_na_for_lte      :=fnd_message.get_string('ZX','ZX_USER_DEF_FC_NA_FOR_LTE' );
  l_document_fc_na_for_lte      :=fnd_message.get_string('ZX','ZX_DOCUMENT_FC_NA_FOR_LTE' );
  l_indended_use_na_for_lte     :=fnd_message.get_string('ZX','ZX_INTENDED_USE_NA_FOR_LTE' );
  l_product_type_na_for_lte     :=fnd_message.get_string('ZX','ZX_PRODUCT_TYPE_NA_FOR_LTE' );
  l_tax_jur_code_na_for_lte     :=fnd_message.get_string('ZX','ZX_TAX_JUR_CODE_NA_FOR_LTE' );

END jl_zz_tax_validate_pkg;

/
