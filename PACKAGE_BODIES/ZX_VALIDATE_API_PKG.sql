--------------------------------------------------------
--  DDL for Package Body ZX_VALIDATE_API_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_VALIDATE_API_PKG" AS
/* $Header: zxapdefvalpkgb.pls 120.80.12010000.14 2010/01/28 10:15:09 msakalab ship $ */

  g_current_runtime_level           NUMBER;
  g_level_statement       CONSTANT  NUMBER := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure       CONSTANT  NUMBER := FND_LOG.LEVEL_PROCEDURE;
  g_level_event           CONSTANT  NUMBER := FND_LOG.LEVEL_EVENT;
  g_level_exception       CONSTANT  NUMBER := FND_LOG.LEVEL_EXCEPTION;
  g_level_unexpected      CONSTANT  NUMBER := FND_LOG.LEVEL_UNEXPECTED;
  g_first_pty_org_id                NUMBER;
  l_le_id                           NUMBER;
  l_ou_id                           NUMBER;
  l_regime_not_exists               VARCHAR2(2000);
  l_regime_not_effective            VARCHAR2(2000);
  l_tax_not_exists                  VARCHAR2(2000);
  l_tax_not_live                    VARCHAR2(2000);
  l_tax_not_effective               VARCHAR2(2000);
  l_tax_recov_or_offset             VARCHAR2(2000);
  l_tax_status_not_exists           VARCHAR2(2000);
  l_tax_status_not_effective        VARCHAR2(2000);
  l_tax_rate_not_exists             VARCHAR2(2000);
  l_tax_rate_not_effective          VARCHAR2(2000);
  l_tax_rate_not_active             VARCHAR2(2000);
  l_tax_rate_code_not_exists        VARCHAR2(2000);
--l_tax_rate_code_not_effective     VARCHAR2(2000);
--l_tax_rate_code_not_active        VARCHAR2(2000);
  l_tax_rate_percentage_invalid     VARCHAR2(2000);
  l_jur_code_not_exists             VARCHAR2(2000);
  l_jur_code_not_effective          VARCHAR2(2000);
  l_ref_doc_missing                 VARCHAR2(2000);
  l_rel_doc_missing                 VARCHAR2(2000);
  l_app_from_doc_missing            VARCHAR2(2000);
  l_app_to_doc_missing              VARCHAR2(2000);
  l_adj_doc_missing                 VARCHAR2(2000);
  l_source_doc_missing              VARCHAR2(2000);
  l_round_party_missing             VARCHAR2(2000);
  l_location_missing                VARCHAR2(2000);
  l_ctrl_flag_missing               VARCHAR2(2000);
  l_line_class_invalid              VARCHAR2(2000);
  l_trx_line_type_invalid           VARCHAR2(2000);
  l_line_amt_incl_tax_invalid       VARCHAR2(2000);
  l_default_status_not_exists       VARCHAR2(2000);
  l_default_rate_code_not_exists    VARCHAR2(2000);
  l_default_jur_code_not_exists     VARCHAR2(2000);
  l_taxation_country_not_exists     VARCHAR2(2000);
  l_prd_categ_not_exists            VARCHAR2(2000);
  l_prd_categ_not_effective         VARCHAR2(2000);
  l_prd_categ_country_inconsis      VARCHAR2(2000);
  l_usr_df_fc_code_not_exists       VARCHAR2(2000);
  l_usr_df_fc_code_not_effective    VARCHAR2(2000);
  l_usr_df_country_inconsis         VARCHAR2(2000);
  l_doc_fc_code_not_exists          VARCHAR2(2000);
  l_doc_fc_code_not_effective       VARCHAR2(2000);
  l_doc_fc_country_inconsis         VARCHAR2(2000);
  l_trx_biz_fc_code_not_exists      VARCHAR2(2000);
  l_trx_biz_fc_code_not_effect      VARCHAR2(2000);
  l_trx_biz_fc_country_inconsis     VARCHAR2(2000);
  l_intended_use_code_not_exists    VARCHAR2(2000);
  l_intended_use_not_effective      VARCHAR2(2000);
  l_intended_use_contry_inconsis    VARCHAR2(2000);
  l_prd_type_code_not_exists        VARCHAR2(2000);
  l_prd_type_not_effective          VARCHAR2(2000);
  l_prd_fc_code_not_exists          VARCHAR2(2000);
  l_party_not_exists                VARCHAR2(2000);
  l_ship_to_party_not_exists        VARCHAR2(2000);
  l_ship_frm_party_not_exits        VARCHAR2(2000);
  l_bill_to_party_not_exists        VARCHAR2(2000);
  l_bill_frm_party_not_exists       VARCHAR2(2000);
  l_shipto_party_site_not_exists    VARCHAR2(2000);
  l_shipfrm_party_site_not_exits    VARCHAR2(2000);
  l_billto_party_site_not_exists    VARCHAR2(2000);
  l_billfrm_party_site_not_exist    VARCHAR2(2000);
  l_tax_multialloc_to_sameln        VARCHAR2(2000);
  l_imptax_multialloc_to_sameln     VARCHAR2(2000);
  l_tax_only_line_multi_allocate    VARCHAR2(2000);
  l_pseudo_line_has_multi_taxall    VARCHAR2(2000);
  --l_tax_amt_miss_for_mul_alloc      VARCHAR2(2000);
  l_tax_amt_missing                 VARCHAR2(2000);
  --l_tax_only_ln_w_null_tax_amt      VARCHAR2(2000);
  l_tax_ln_typ_loc_not_allw_f_ar    VARCHAR2(2000);
  l_tax_incl_flag_mismatch          VARCHAR2(2000);
  l_imp_tax_missing_in_appld_frm    VARCHAR2(2000);
  l_imp_tax_missing_in_adjust_to    VARCHAR2(2000);
  l_currency_info_reqd              VARCHAR2(2000);
  l_line_ctrl_amt_invalid           VARCHAR2(2000);
  l_line_ctrl_amt_not_null          VARCHAR2(2000);
  l_unit_price_missing              VARCHAR2(2000);
  l_line_quantity_missing           VARCHAR2(2000);

  l_exemption_ctrl_flag_invalid     VARCHAR2(2000);
  l_product_type_invalid            VARCHAR2(2000);
  l_quote_flag_invalid              VARCHAR2(2000);
  l_doc_lvl_recalc_flag_invalid     VARCHAR2(2000);
  l_tax_line_alloc_flag_invalid     VARCHAR2(2000);

  l_inval_tax_lines_for_ctrl_flg    VARCHAR2(2000);
  l_invald_line_for_ctrl_tot_amt    VARCHAR2(2000);
  l_inval_tax_line_for_alloc_flg    VARCHAR2(2000);
  l_invalid_tax_only_tax_lines      VARCHAR2(2000);
  l_invalid_tax_line_alloc_flag     VARCHAR2(2000);
  l_invd_trx_line_id_in_link_gt     VARCHAR2(2000);
  l_invalid_summary_tax_line_id     VARCHAR2(2000);
  l_regime_not_eff_in_subscrptn     VARCHAR2(2000);
  l_tax_rate_id_code_missing        VARCHAR2(2000);
  l_imp_tax_rate_amt_mismatch       VARCHAR2(2000);

  l_return_status                   VARCHAR2(30);

  l_count_header                    NUMBER;
  l_count_lines                     NUMBER;
  l_count_tax_lines                 NUMBER;
  l_count_link_gt                   NUMBER;

  l_count_error                     NUMBER;

  l_count_reg_null                  NUMBER;
  l_count_status_null               NUMBER;
  l_count_jur_null                  NUMBER;
  l_count_pvr_null                  NUMBER;
  l_count_rate_id_null              NUMBER;

  l_error_rec  ZX_VALIDATION_ERRORS_GT%rowtype;

  --Declare Forward references
  PROCEDURE Validate_Other_Documents(x_return_status OUT NOCOPY VARCHAR2);
  procedure def_additional_tax_attribs;

------------ Main Procedure(Called from AP) ---------------------------

PROCEDURE Default_And_Validate_Tax_Attr(
                                p_api_version      IN NUMBER,
                                p_init_msg_list    IN VARCHAR2,
                                p_commit           IN VARCHAR2,
                                p_validation_level IN VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_count     OUT NOCOPY NUMBER,
                                x_msg_data      OUT NOCOPY VARCHAR2) IS

CURSOR  check_eror  IS
  select
         application_id,
         entity_code,
         event_class_code,
         trx_id,
         trx_line_id,
         message_name,
         message_text,
         trx_level_type,
         other_doc_application_id,
         other_doc_entity_code,
         other_doc_event_class_code,
         other_doc_trx_id,
         interface_line_entity_code,
         interface_line_id
  from  zx_validation_errors_gt;

BEGIN

     x_return_status := FND_API.G_RET_STS_SUCCESS;
     g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

     IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                'ZX.PL/SQL.ZX_VALIDATE_API_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
                'ZX_VALIDATE_API_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR(+)');
     END IF;

     SELECT count(1) INTO  l_count_header FROM zx_trx_headers_gt;

     SELECT count(1) INTO l_count_lines FROM ZX_TRANSACTION_LINES_GT;

     SELECT count(1),
            Sum(Decode(tax_regime_code||tax, NULL, 0, 1)),
            Sum(Decode(tax_status_code, NULL, 0, 1)),
            Sum(Decode(tax_jurisdiction_code, NULL, 0, 1)),
            Sum(Nvl(tax_provider_id, 0)),
            Sum(Nvl(tax_rate_id, 0))
     INTO l_count_tax_lines,
          l_count_reg_null,
          l_count_status_null,
          l_count_jur_null,
          l_count_pvr_null,
          l_count_rate_id_null
     FROM ZX_IMPORT_TAX_LINES_GT;

     SELECT count(1) INTO l_count_link_gt FROM ZX_TRX_TAX_LINK_GT;

    IF ( g_level_statement >= g_current_runtime_level) THEN
      FND_LOG.STRING(g_level_statement,'ZX_VALIDATEAPI_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
      'Count of ZX_TRX_HEADERS_GT '||to_char(l_count_header));
      FND_LOG.STRING(g_level_statement,'ZX_VALIDATEAPI_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
      'Count of ZX_TRANSACTION_LINES_GT '||to_char(l_count_lines));
            FND_LOG.STRING(g_level_statement,'ZX_VALIDATEAPI_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
      'Count of ZX_IMPORT_TAX_LINES_GT '||to_char(l_count_tax_lines));
            FND_LOG.STRING(g_level_statement,'ZX_VALIDATEAPI_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
      'Count of ZX_TRX_TAX_LINK_GT '||to_char(l_count_link_gt));
    END IF;

 ---------------------------------------------------------------------------------
    -- Select First Party Organization to be used for validations and defaulting
    -- for Imported Tax Lines

    -- Assumption: Operating Unit and Legal Entity will be same for all input
    -- transactions
---------------------------------------------------------------------------------

    BEGIN

        SELECT
                legal_entity_id , internal_organization_id
                INTO l_le_id, l_ou_id
        FROM
                ZX_TRX_HEADERS_GT Header
        WHERE rownum = 1;

    EXCEPTION

         WHEN NO_DATA_FOUND THEN
              IF (g_level_exception >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_exception,
                          'ZX_VALIDATEAPI_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR:
                                         First Party Org Id : Not able to fetch
                                         OU and LE',
                          sqlerrm);
              END IF;

         app_exception.raise_exception;

    END;

    IF ( g_level_statement >= g_current_runtime_level) THEN

      FND_LOG.STRING(g_level_statement,'ZX_VALIDATEAPI_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
      'Call ZX_TCM_PTP_PKG.GET_TAX_SUBSCRIBER() with OU: '||to_char(l_ou_id)||' and LE: '||to_char(l_le_id));
    END IF;

    ZX_TCM_PTP_PKG.GET_TAX_SUBSCRIBER(l_le_id,
                                      l_ou_id,
                                      g_first_pty_org_id,
                                      l_return_status);

    IF ( g_level_statement >= g_current_runtime_level) THEN
      FND_LOG.STRING(g_level_statement,'ZX_VALIDATEAPI_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
      'G_FIRST_PTY_ORG_ID: '||to_char(g_first_pty_org_id));
    END IF;

-- Need to verify if we need to raise a UNEXPECTED error if we fail to set first party
-- Checked with Isaac. This should not be an unexpected error, but raise one valdn error for
-- all transactions and do not proceed further => Changes yet to be implemented

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_exception >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_exception,
                  'ZX_VALIDATEAPI_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR:
                                 Get Tax Subscriber : Returned Error Status',
                          sqlerrm);
      END IF;
--      Return;
    END IF;

------------------------------------------------------------------------------------
-- End logic for getting the first party org id
------------------------------------------------------------------------------------

    IF ( g_level_event >= g_current_runtime_level) THEN
      FND_LOG.STRING(g_level_event,'ZX_VALIDATEAPI_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
      'Validating Other Documents');
    END IF;

    Validate_Other_Documents(x_return_status);

    IF ( g_level_event >= g_current_runtime_level) THEN
      FND_LOG.STRING(g_level_event,'ZX_VALIDATEAPI_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
      'Executing On the Fly Migration If Needed');
    END IF;

    zx_on_fly_trx_upgrade_pkg.upgrade_trx_on_fly_blk(x_return_status);

    -- Bug # 4697301
    delete  from ZX_VALIDATION_ERRORS_GT err where  EXISTS
    (Select  1 from  ZX_LINES_DET_FACTORS  linedet where
    linedet.application_id   = err.other_doc_application_id and
    linedet.entity_code      = err.other_doc_entity_code and
    linedet.event_class_code = err.other_doc_event_class_code and
    linedet.trx_id           = err.other_doc_trx_id and
    rownum =1);

    --Bug # 4917256
    IF ( g_level_event >= g_current_runtime_level) THEN
      FND_LOG.STRING(g_level_event,'ZX_VALIDATEAPI_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
      'Before defaulting, validate either tax_rate_id or tax_rate_code is passed in the import tax lines GT table');
    END IF;

  INSERT INTO
  ZX_VALIDATION_ERRORS_GT(
    application_id,
    entity_code,
    event_class_code,
    trx_id,
    trx_line_id,
    summary_tax_line_number,
    message_name,
    message_text,
    trx_level_type,
    interface_tax_entity_code,
    interface_tax_line_id
    )
  SELECT
    application_id,
    entity_code,
    event_class_code,
    trx_id,
    trx_line_id,
    summary_tax_line_number,
    'ZX_TAX_RATE_ID_CODE_MISSING',
    l_tax_rate_id_code_missing,
    null,
    interface_entity_code,
    interface_tax_line_id
  FROM
        ZX_IMPORT_TAX_LINES_GT
  WHERE
        tax_rate_code IS NULL AND tax_rate_id IS NULL;

    IF ( g_level_event >= g_current_runtime_level) THEN
      FND_LOG.STRING(g_level_event,'ZX_VALIDATEAPI_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
      'Defaulting Additional Tax Det Attrs and Tax Line Attrs');
    END IF;

    Default_Tax_Attr(x_return_status);

    IF ( g_level_event >= g_current_runtime_level) THEN
      FND_LOG.STRING(g_level_event,'ZX_VALIDATEAPI_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
      'After defaulting, validate either tax_rate_id or tax_rate_code is present in the import tax lines GT table');
    END IF;

    INSERT INTO
    ZX_VALIDATION_ERRORS_GT(
      application_id,
      entity_code,
      event_class_code,
      trx_id,
      trx_line_id,
      summary_tax_line_number,
      message_name,
      message_text,
      trx_level_type,
      interface_tax_entity_code,
      interface_tax_line_id
      )
    SELECT
      application_id,
      entity_code,
      event_class_code,
      trx_id,
      trx_line_id,
      summary_tax_line_number,
      'ZX_TAX_RATE_ID_CODE_MISSING',
      l_tax_rate_id_code_missing,
      null,
      interface_entity_code,
      interface_tax_line_id
    FROM
          ZX_IMPORT_TAX_LINES_GT
    WHERE
          tax_rate_code IS NULL AND tax_rate_id IS NULL;

    IF ( g_level_event >= g_current_runtime_level) THEN
      FND_LOG.STRING(g_level_event,'ZX_VALIDATEAPI_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
      'Validating Transaction and Imported tax line info');
    END IF;

    Validate_Tax_Attr(x_return_status);

    IF (g_level_statement >= g_current_runtime_level ) THEN

  OPEN check_eror;
  LOOP
    fetch check_eror into l_error_rec.application_id,
                          l_error_rec.entity_code,
                          l_error_rec.event_class_code,
                          l_error_rec.trx_id,
                          l_error_rec.trx_line_id,
                          l_error_rec.message_name,
                          l_error_rec.message_text,
                          l_error_rec.trx_level_type,
                          l_error_rec.other_doc_application_id,
                          l_error_rec.other_doc_entity_code,
                          l_error_rec.other_doc_event_class_code,
                          l_error_rec.other_doc_trx_id,
                          l_error_rec.interface_line_entity_code,
                          l_error_rec.interface_line_id;
    EXIT WHEN check_eror%NOTFOUND ; -- Added exit conditon .

                FND_LOG.STRING(g_level_statement,
    'ZX.PL/SQL.ZX_VALIDATE_API_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
    'error application_id is '||l_error_rec.application_id);
      FND_LOG.STRING(g_level_statement,
    'ZX.PL/SQL.ZX_VALIDATE_API_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
    'error entity_code is '||l_error_rec.entity_code);
      FND_LOG.STRING(g_level_statement,
    'ZX.PL/SQL.ZX_VALIDATE_API_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
    'error event_class_code is '||l_error_rec.event_class_code);
      FND_LOG.STRING(g_level_statement,
    'ZX.PL/SQL.ZX_VALIDATE_API_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
    'error trx_id is '||l_error_rec.trx_id);
      FND_LOG.STRING(g_level_statement,
    'ZX.PL/SQL.ZX_VALIDATE_API_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
    'error trx_line_id is '||l_error_rec.trx_line_id);
      FND_LOG.STRING(g_level_statement,
    'ZX.PL/SQL.ZX_VALIDATE_API_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
    'error message_name is '||l_error_rec.message_name);
      FND_LOG.STRING(g_level_statement,
    'ZX.PL/SQL.ZX_VALIDATE_API_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
    'error trx_level_type is '||l_error_rec.trx_level_type);
      FND_LOG.STRING(g_level_statement,
    'ZX.PL/SQL.ZX_VALIDATE_API_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
    'error other_doc_application_id is '||l_error_rec.other_doc_application_id);
      FND_LOG.STRING(g_level_statement,
    'ZX.PL/SQL.ZX_VALIDATE_API_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
    'error other_doc_entity_code is '||l_error_rec.other_doc_entity_code);
      FND_LOG.STRING(g_level_statement,
    'ZX.PL/SQL.ZX_VALIDATE_API_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
    'error other_doc_event_class_code is '||l_error_rec.other_doc_event_class_code);
      FND_LOG.STRING(g_level_statement,
    'ZX.PL/SQL.ZX_VALIDATE_API_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
    'error other_doc_trx_id is '||l_error_rec.other_doc_trx_id);

  END LOOP;

    END IF;

    ZX_GLOBAL_STRUCTURES_PKG.delete_trx_line_dist_tbl;

    IF (g_level_statement >= g_current_runtime_level ) THEN
  FND_LOG.STRING(g_level_statement,
    'ZX.PL/SQL.ZX_VALIDATE_API_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
    'x_return_status from Validate_Tax_Attr is '||x_return_status);
    END IF;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure,
               'ZX.PL/SQL.ZX_VALIDATE_API_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
               'ZX_VALIDATE_API_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR(-)');
    END IF;

EXCEPTION
         WHEN OTHERS THEN
              IF (g_level_unexpected >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_unexpected,
                          'ZX_VALIDATE_API_PKG.DEFAULT_AND_VALIDATE_TAX_ATTR',
                           sqlerrm);
              END IF;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              app_exception.raise_exception;
END Default_And_Validate_Tax_Attr;


------------------ Procedure For Defaulting -----------------------

PROCEDURE Default_Tax_Attr(x_return_status OUT NOCOPY VARCHAR2) IS

l_owner_table_code  ZX_FC_TYPES_B.owner_table_code%Type;
l_owner_id_num      ZX_FC_TYPES_B.owner_id_num%Type;
l_le_id             ZX_TRX_HEADERS_GT.legal_entity_id%Type;
l_org_id            ZX_TRX_HEADERS_GT.internal_organization_id%Type;
l_effective_date    Date;
l_return_status varchar2(30);

--Bug 5018766 : Added for Defaulting the Tax Dates on the Newly added columns in zx_transaction_lines_gt
c_lines_per_commit CONSTANT NUMBER := ZX_TDS_CALC_SERVICES_PUB_PKG.G_LINES_PER_COMMIT;
l_application_id_tbl         APPLICATION_ID_TBL;
l_entity_code_tbl            ENTITY_CODE_TBL;
l_event_class_code_tbl       EVENT_CLASS_CODE_TBL;
l_trx_id_tbl                 TRX_ID_TBL;
l_trx_line_id_tbl            TRX_LINE_ID_TBL;
l_trx_level_type_tbl         TRX_LEVEL_TYPE_TBL;
l_trx_date_tbl               TRX_DATE_TBL;
l_subscription_date_tb1      TRX_DATE_TBL;
L_COUNT                      NUMBER ;

cursor c_lines is
  select lines.application_id,
  lines.entity_code,
  lines.event_class_code,
  lines.trx_id,
  lines.trx_line_id,
  lines.trx_level_type,
  COALESCE(header.related_doc_date,
           header.provnl_tax_determination_date,
           Lines.adjusted_doc_date,
           Lines.trx_line_date,
           header.trx_date) Tax_Date,
  COALESCE(header.related_doc_date,
           header.provnl_tax_determination_date,
           Lines.adjusted_doc_date,
           header.trx_date) subscription_date
  from zx_trx_headers_gt header,
  zx_transaction_lines_gt lines
  where header.application_id = lines.application_id
  and header.ENTITY_CODE = lines.ENTITY_CODE
  and header.EVENT_CLASS_CODE = lines.EVENT_CLASS_CODE
  and header.TRX_ID = lines.TRX_ID ;

BEGIN

     x_return_status := FND_API.G_RET_STS_SUCCESS;
     g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
     IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                'ZX.PL/SQL.ZX_VALIDATE_API_PKG.DEFAULT_TAX_ATTR',
                'ZX_VALIDATE_API_PKG.DEFAULT_TAX_ATTR(+)');
     END IF;


--Bug 5018766 : Default the tax_date , tax_determine_date and tax_point_date for all the trx_lines
IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                'ZX.PL/SQL.ZX_VALIDATE_API_PKG.DEFAULT_TAX_ATTR',
                'ZX_VALIDATE_API_PKG.DEFAULT_TAX_ATTR:
                Stamping the Dates onto zx_transaction_lines_gt');
END IF;

OPEN c_lines;
loop
fetch c_lines bulk collect into
  l_application_id_tbl,
  l_entity_code_tbl,
  l_event_class_code_tbl,
  l_trx_id_tbl,
  l_trx_line_id_tbl,
  l_trx_level_type_tbl,
  l_trx_date_tbl,
  l_subscription_date_tb1
  LIMIT C_LINES_PER_COMMIT;

  l_count := nvl(l_trx_line_id_tbl.COUNT,0);

-- Stamp the tax_date , tax_determine_date and tax_point_date to the same value
  if ( l_count > 0 ) THEN
    FORALL i IN 1 .. l_count
      update zx_transaction_lines_gt
      set tax_date = l_trx_date_tbl(i),
      tax_determine_date = l_trx_date_tbl(i),
      tax_point_date = l_trx_date_tbl(i),
      subscription_date = l_subscription_date_tb1(i)
      where application_id = l_application_id_tbl(i)
          AND entity_code = l_entity_code_tbl(i)
          AND event_class_code = l_event_class_code_tbl(i)
          AND trx_id = l_trx_id_tbl(i)
          AND trx_line_id = l_trx_line_id_tbl(i)
          AND trx_level_type = l_trx_level_type_tbl(i);
  l_count := 0;
  else
    exit;
  end if;
end loop;

IF ( c_lines%ISOPEN ) THEN
CLOSE c_lines;
END IF ;

-- Defaulting Tax Date and Subscription Date
-- This query is split into 3 queries as suggested by Jinsoo,
-- to avoid the complex OR Conditions.


UPDATE ZX_IMPORT_TAX_LINES_GT  TaxLines
SET    (tax_date, subscription_date)  =
       (SELECT NVL(TaxLines.tax_date, qry.tax_date),
               NVL(TaxLines.subscription_date, qry.subscription_date)
          FROM (SELECT COALESCE(header.related_doc_date,
                                header.provnl_tax_determination_date,
                                Lines.adjusted_doc_date,
                                Lines.trx_line_date,
                                header.trx_date) Tax_Date,
                       COALESCE(header.related_doc_date,
                                header.provnl_tax_determination_date,
                                Lines.adjusted_doc_date,
                                header.trx_date) subscription_date,
                       TaxLines_gt.application_id application_id,
                       TaxLines_gt.entity_code entity_code,
                       TaxLines_gt.event_class_code event_class_code,
                       TaxLines_gt.trx_id trx_id,
                       TaxLines_gt.summary_tax_line_number summary_tax_line_number
                  FROM ZX_IMPORT_TAX_LINES_GT  TaxLines_gt,
                       ZX_TRX_HEADERS_GT       Header,
                       ZX_TRANSACTION_LINES_GT Lines
                 WHERE TaxLines_gt.application_id   = Header.application_id
                   AND TaxLines_gt.entity_code      = Header.entity_code
                   AND TaxLines_gt.event_class_code = Header.event_class_code
                   AND TaxLines_gt.trx_id           = Header.trx_id
                   AND Lines.application_id      = Header.application_id
                   AND Lines.entity_code         = Header.entity_code
                   AND Lines.event_class_code    = Header.event_class_code
                   AND Lines.trx_id              = Header.trx_id
                   AND -- One to One Alloc
                      lines.trx_line_id = taxlines_gt.trx_line_id
               ) qry
    where TaxLines.application_id   = qry.application_id
                   AND TaxLines.entity_code      = qry.entity_code
                   AND TaxLines.event_class_code = qry.event_class_code
                   AND TaxLines.trx_id           = qry.trx_id
                   AND TaxLines.summary_tax_line_number = qry.summary_tax_line_number
       AND ROWNUM = 1  -- To Prevent more than one row being fetched for a single row update
  );

UPDATE ZX_IMPORT_TAX_LINES_GT  TaxLines
SET    (tax_date, subscription_date)  =
       (SELECT NVL(TaxLines.tax_date, qry.tax_date),
               NVL(TaxLines.subscription_date, qry.subscription_date)
          FROM (SELECT COALESCE(header.related_doc_date,
                                header.provnl_tax_determination_date,
                                Lines.adjusted_doc_date,
                                Lines.trx_line_date,
                                header.trx_date) Tax_Date,
                       COALESCE(header.related_doc_date,
                                header.provnl_tax_determination_date,
                                Lines.adjusted_doc_date,
                                header.trx_date) subscription_date,
                       TaxLines_gt.application_id application_id,
                       TaxLines_gt.entity_code entity_code,
                       TaxLines_gt.event_class_code event_class_code,
                       TaxLines_gt.trx_id trx_id,
                       TaxLines_gt.summary_tax_line_number summary_tax_line_number
                  FROM ZX_IMPORT_TAX_LINES_GT  TaxLines_gt,
                       ZX_TRX_HEADERS_GT       Header,
                       ZX_TRANSACTION_LINES_GT Lines
                 WHERE TaxLines_gt.application_id   = Header.application_id
                   AND TaxLines_gt.entity_code      = Header.entity_code
                   AND TaxLines_gt.event_class_code = Header.event_class_code
                   AND TaxLines_gt.trx_id           = Header.trx_id
                   AND Lines.application_id      = Header.application_id
                   AND Lines.entity_code         = Header.entity_code
                   AND Lines.event_class_code    = Header.event_class_code
                   AND Lines.trx_id              = Header.trx_id
                   AND --Multi Alloc
                     (
                       taxlines_gt.trx_line_id IS NULL
                       AND taxlines_gt.tax_line_allocation_flag = 'Y'
                       AND lines.trx_line_id =
                       (
                        SELECT
                           MIN(trx_line_id)
                        FROM zx_trx_tax_link_gt link_gt
                        WHERE link_gt.TRX_ID = taxlines_gt.trx_id
                        AND link_gt.application_id = taxlines_gt.application_id
                        AND link_gt.entity_code = taxlines_gt.entity_code
                        AND link_gt.event_class_code = taxlines_gt.event_class_code
                        AND link_gt.summary_tax_line_number = taxlines_gt.summary_tax_line_number
                       )
                     )
               ) qry
    where TaxLines.application_id   = qry.application_id
                   AND TaxLines.entity_code      = qry.entity_code
                   AND TaxLines.event_class_code = qry.event_class_code
                   AND TaxLines.trx_id           = qry.trx_id
                   AND TaxLines.summary_tax_line_number = qry.summary_tax_line_number
       AND ROWNUM = 1  -- To Prevent more than one row being fetched for a single row update
  )
  WHERE (tax_date IS NULL OR subscription_date IS NULL);

UPDATE ZX_IMPORT_TAX_LINES_GT  TaxLines
SET    (tax_date, subscription_date)  =
       (SELECT NVL(TaxLines.tax_date, qry.tax_date),
               NVL(TaxLines.subscription_date, qry.subscription_date)
          FROM (SELECT COALESCE(header.related_doc_date,
                                header.provnl_tax_determination_date,
                                Lines.adjusted_doc_date,
                                Lines.trx_line_date,
                                header.trx_date) Tax_Date,
                       COALESCE(header.related_doc_date,
                                header.provnl_tax_determination_date,
                                Lines.adjusted_doc_date,
                                header.trx_date) subscription_date,
                       TaxLines_gt.application_id application_id,
                       TaxLines_gt.entity_code entity_code,
                       TaxLines_gt.event_class_code event_class_code,
                       TaxLines_gt.trx_id trx_id,
                       TaxLines_gt.summary_tax_line_number summary_tax_line_number
                  FROM ZX_IMPORT_TAX_LINES_GT  TaxLines_gt,
                       ZX_TRX_HEADERS_GT       Header,
                       ZX_TRANSACTION_LINES_GT Lines
                 WHERE TaxLines_gt.application_id   = Header.application_id
                   AND TaxLines_gt.entity_code      = Header.entity_code
                   AND TaxLines_gt.event_class_code = Header.event_class_code
                   AND TaxLines_gt.trx_id           = Header.trx_id
                   AND Lines.application_id      = Header.application_id
                   AND Lines.entity_code         = Header.entity_code
                   AND Lines.event_class_code    = Header.event_class_code
                   AND Lines.trx_id              = Header.trx_id
                   AND --All Alloc
                     (
                       taxlines_gt.trx_line_id IS NULL
                       AND taxlines_gt.tax_line_allocation_flag = 'N'
                       AND lines.trx_line_id =
                       (
                        SELECT
                           MIN(trx_line_id)
                        FROM zx_transaction_lines_gt trans_line_gt
                        WHERE trans_line_gt.trx_id = taxlines_gt.trx_id
                        AND trans_line_gt.application_id = taxlines_gt.application_id
                        AND trans_line_gt.entity_code = taxlines_gt.entity_code
                        AND trans_line_gt.event_class_code = taxlines_gt.event_class_code
                       )
                     )
               ) qry
    where TaxLines.application_id   = qry.application_id
                   AND TaxLines.entity_code      = qry.entity_code
                   AND TaxLines.event_class_code = qry.event_class_code
                   AND TaxLines.trx_id           = qry.trx_id
                   AND TaxLines.summary_tax_line_number = qry.summary_tax_line_number
       AND ROWNUM = 1  -- To Prevent more than one row being fetched for a single row update
  )
  WHERE (tax_date IS NULL OR subscription_date IS NULL);

--Defaulting for Taxation Country

IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                'ZX.PL/SQL.ZX_VALIDATE_API_PKG.DEFAULT_TAX_ATTR',
                'ZX_VALIDATE_API_PKG.DEFAULT_TAX_ATTR:
                Defaulting for Taxation Country');
END IF;

UPDATE ZX_TRX_HEADERS_GT Header
        SET default_taxation_country =
        (SELECT le.country
         FROM
                XLE_FIRSTPARTY_INFORMATION_V le
         WHERE
                le.legal_entity_id = Header.legal_entity_id
        )
WHERE default_taxation_country is NULL;

--Defaulting for Tax Regime Code and Tax Code

IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                'ZX.PL/SQL.ZX_VALIDATE_API_PKG.DEFAULT_TAX_ATTR',
                'ZX_VALIDATE_API_PKG.DEFAULT_TAX_ATTR:
                Defaulting for Tax Regime Code and Tax Code');
END IF;

  /* Default Logic based on Rate Code and Rate Id are seperated
  to accomodate defaulting when one of them is passed and the other is null.*/

-- This Update is to Ensure that the regime and tax get defaulted in case Rate Id is null and Rate Code being passed.

-- Execute this query only if tax_regime_code is null
-- If customer has populated this column in interface tables need not default it again.

IF l_count_reg_null = 0 THEN
  UPDATE ZX_IMPORT_TAX_LINES_GT  TaxLines
  SET    (tax_regime_code, tax)  =
         (SELECT NVL(TaxLines.tax_regime_code, qry.tax_regime_code),
                 NVL(TaxLines.tax, qry.tax)
          FROM (SELECT NVL(rates.tax_regime_code,
                           nvl2(to_char(taxlines_gt.tax_rate_id),null,ContDef.tax_regime_code)) tax_regime_code,
                       NVL(rates.tax, nvl2(to_char(taxlines_gt.tax_rate_id),null,ContDef.tax)) tax,
                       TaxLines_gt.application_id application_id,
                       TaxLines_gt.entity_code entity_code,
                       TaxLines_gt.event_class_code event_class_code,
                       TaxLines_gt.trx_id trx_id,
                       TaxLines_gt.summary_tax_line_number summary_tax_line_number
                  FROM ZX_FC_COUNTRY_DEFAULTS ContDef,
                       ZX_IMPORT_TAX_LINES_GT  TaxLines_gt,
                       ZX_TRX_HEADERS_GT       Header,
                       --ZX_TRANSACTION_LINES_GT Lines,
                       ZX_RATES_B              rates,
                       ZX_SUBSCRIPTION_DETAILS sd_rates
                 WHERE TaxLines_gt.tax_rate_code    = rates.tax_rate_code(+)
                   AND (Taxlines_gt.tax_rate_code IS NOT NULL OR Taxlines_gt.tax_rate_id IS NOT NULL)
                   AND Taxlines_gt.tax_date --Bug 5018766
                       BETWEEN nvl(rates.effective_from,Taxlines_gt.tax_date)
                       AND     nvl(rates.effective_to,Taxlines_gt.tax_date)
                   AND ContDef.country_code(+)   = Header.default_taxation_country
                   AND TaxLines_gt.application_id   = Header.application_id
                   AND TaxLines_gt.entity_code      = Header.entity_code
                   AND TaxLines_gt.event_class_code = Header.event_class_code
                   AND TaxLines_gt.trx_id           = Header.trx_id
                   --AND Lines.application_id      = Header.application_id
                   --AND Lines.entity_code         = Header.entity_code
                   --AND Lines.event_class_code    = Header.event_class_code
                   --AND Lines.trx_id              = Header.trx_id
                   --AND
                   --( -- One to One Alloc
                     --(
                       --lines.trx_line_id = taxlines_gt.trx_line_id
                     --)
                     --OR
                     --Multi Alloc
                     --(
                       --taxlines_gt.trx_line_id IS NULL
                       --AND taxlines_gt.tax_line_allocation_flag = 'Y'
                       --AND lines.trx_line_id =
                       --(
                        --SELECT
                           --MIN(trx_line_id)
                        --FROM zx_trx_tax_link_gt link_gt
                        --WHERE link_gt.TRX_ID = taxlines_gt.trx_id
                        --AND link_gt.application_id = taxlines_gt.application_id
                        --AND link_gt.entity_code = taxlines_gt.entity_code
                        --AND link_gt.event_class_code = taxlines_gt.event_class_code
                        --AND link_gt.summary_tax_line_number = taxlines_gt.summary_tax_line_number
                       --)
                     --)
                     --OR
                     --All Alloc
                     --(
                       --taxlines_gt.trx_line_id IS NULL
                       --AND taxlines_gt.tax_line_allocation_flag = 'N'
                       --AND lines.trx_line_id =
                       --(
                        --SELECT
                           --MIN(trx_line_id)
                        --FROM zx_transaction_lines_gt trans_line_gt
                        --WHERE trans_line_gt.trx_id = taxlines_gt.trx_id
                        --AND trans_line_gt.application_id = taxlines_gt.application_id
                        --AND trans_line_gt.entity_code = taxlines_gt.entity_code
                        --AND trans_line_gt.event_class_code = taxlines_gt.event_class_code
                       --)
                     --)
                   --)
                   AND Rates.tax_regime_code     = sd_rates.tax_regime_code(+)
                   AND Rates.rate_type_code <> 'RECOVERY'                         -- Added for Bug#7504455
                   AND
                   ( Rates.content_owner_id    = sd_rates.parent_first_pty_org_id
                     OR
                     sd_rates.parent_first_pty_org_id IS NULL )
                   --AND sd_rates.first_pty_org_id(+) = g_first_pty_org_id
                   AND sd_rates.first_pty_org_id IN (g_first_pty_org_id, -99)
                   AND ( Taxlines_gt.subscription_date
                         BETWEEN NVL(sd_rates.effective_from,
                                     Taxlines_gt.subscription_date)
                             AND NVL(sd_rates.effective_to,
                                     Taxlines_gt.subscription_date)
                        OR
                        Rates.effective_from = (SELECT MIN(effective_from)
                                                FROM zx_rates_b
                                                WHERE
                                                tax_regime_code  = Rates.tax_regime_code and
                                                tax              = Rates.tax and
                                                tax_status_code  = Rates.tax_status_code and
                                                tax_rate_code    = Rates.tax_rate_code and
                                                content_owner_id = Rates.content_owner_id and
                                                rate_type_code   = Rates.rate_type_code     -- Added for Bug#7504455
                                                )
                        )
                   AND (NVL(sd_rates.view_options_code,'NONE') in ('NONE', 'VFC') OR
                            (NVL(sd_rates.view_options_code, 'VFR') = 'VFR'
                                 AND NOT EXISTS (SELECT 1 FROM zx_rates_b b
                                                  WHERE b.tax_regime_code = Rates.tax_regime_code
                                                    AND b.tax = Rates.tax
                                                    AND b.tax_status_code = Rates.tax_status_code
                                                    AND b.tax_rate_code = Rates.tax_rate_code
                                                    AND b.content_owner_id = sd_rates.first_pty_org_id
                                                    AND b.rate_type_code = Rates.rate_type_code          -- Added for Bug#7504455
                                                 )
                             )
                        )
               ) qry
    where TaxLines.application_id   = qry.application_id
                   AND TaxLines.entity_code      = qry.entity_code
                   AND TaxLines.event_class_code = qry.event_class_code
                   AND TaxLines.trx_id           = qry.trx_id
                   AND TaxLines.summary_tax_line_number = qry.summary_tax_line_number
       AND ROWNUM = 1  -- To Prevent more than one row being fetched for a single row update
  );

-- This Update is to Ensure that the regime and tax get defaulted in case rate code is null and rate id being passed
-- If tax_rate_id is not null then execute this query
IF l_count_rate_id_null <> 0 THEN
  UPDATE ZX_IMPORT_TAX_LINES_GT  TaxLines
  SET    (tax_regime_code, tax)  =
         (SELECT NVL(TaxLines.tax_regime_code, qry.tax_regime_code),
                 NVL(TaxLines.tax, qry.tax)
          FROM (SELECT NVL(rates.tax_regime_code,
                           ContDef.tax_regime_code) tax_regime_code,
                       NVL(rates.tax, ContDef.tax) tax,
                       TaxLines_gt.application_id application_id,
                       TaxLines_gt.entity_code entity_code,
                       TaxLines_gt.event_class_code event_class_code,
                       TaxLines_gt.trx_id trx_id,
                       TaxLines_gt.summary_tax_line_number summary_tax_line_number
                  FROM ZX_FC_COUNTRY_DEFAULTS ContDef,
                       ZX_IMPORT_TAX_LINES_GT  TaxLines_gt,
                       ZX_TRX_HEADERS_GT       Header,
                       --ZX_TRANSACTION_LINES_GT Lines,
                       ZX_RATES_B              rates,
                       ZX_SUBSCRIPTION_DETAILS sd_rates
                 WHERE TaxLines_gt.tax_rate_id    = rates.tax_rate_id(+)
                   AND (Taxlines_gt.tax_rate_code IS NOT NULL OR Taxlines_gt.tax_rate_id IS NOT NULL)
                   AND Taxlines_gt.tax_date --Bug 5018766
                       BETWEEN nvl(rates.effective_from,Taxlines_gt.tax_date)
                       AND     nvl(rates.effective_to,Taxlines_gt.tax_date )

                   AND ContDef.country_code(+)   = Header.default_taxation_country
                   AND TaxLines_gt.application_id   = Header.application_id
                   AND TaxLines_gt.entity_code      = Header.entity_code
                   AND TaxLines_gt.event_class_code = Header.event_class_code
                   AND TaxLines_gt.trx_id           = Header.trx_id
                   --AND Lines.application_id      = Header.application_id
                   --AND Lines.entity_code         = Header.entity_code
                   --AND Lines.event_class_code    = Header.event_class_code
                   --AND Lines.trx_id              = Header.trx_id
                   --AND
                   --(-- One to One Alloc
                    --(
                      --lines.trx_line_id = taxlines_gt.trx_line_id
                    --)
                    --OR
                    --Multi Alloc
                    --(
                      --taxlines_gt.trx_line_id IS NULL
                      --AND taxlines_gt.tax_line_allocation_flag = 'Y'
                      --AND lines.trx_line_id =
                      --(
                       --SELECT
                        --MIN(trx_line_id)
                       --FROM zx_trx_tax_link_gt link_gt
                       --WHERE link_gt.TRX_ID = taxlines_gt.trx_id
                       --AND link_gt.application_id = taxlines_gt.application_id
                       --AND link_gt.entity_code = taxlines_gt.entity_code
                       --AND link_gt.event_class_code = taxlines_gt.event_class_code
                       --AND link_gt.summary_tax_line_number = taxlines_gt.summary_tax_line_number
                      --)
                    --)
                    --OR
                    --All Alloc
                    --(
                      --taxlines_gt.trx_line_id IS NULL
                      --AND taxlines_gt.tax_line_allocation_flag = 'N'
                      --AND lines.trx_line_id =
                      --(
                       --SELECT
                        --MIN(trx_line_id)
                       --FROM zx_transaction_lines_gt trans_line_gt
                       --WHERE trans_line_gt.trx_id = taxlines_gt.trx_id
                       --AND trans_line_gt.application_id = taxlines_gt.application_id
                       --AND trans_line_gt.entity_code = taxlines_gt.entity_code
                       --AND trans_line_gt.event_class_code = taxlines_gt.event_class_code
                      --)
                    --)
                   --)
                   AND Rates.tax_regime_code     = sd_rates.tax_regime_code(+)
                   AND Rates.rate_type_code <> 'RECOVERY'                       -- Added for Bug#7504455
                   AND
                   ( Rates.content_owner_id    = sd_rates.parent_first_pty_org_id
                     OR
                     sd_rates.parent_first_pty_org_id IS NULL )
                   --AND sd_rates.first_pty_org_id(+) = g_first_pty_org_id
                   AND sd_rates.first_pty_org_id IN (g_first_pty_org_id, -99)
                   AND (Taxlines_gt.subscription_date
                         BETWEEN NVL(sd_rates.effective_from,
                                     Taxlines_gt.subscription_date)
                             AND NVL(sd_rates.effective_to,
                                     Taxlines_gt.subscription_date)
                        OR
                        Rates.effective_from = (SELECT MIN(effective_from)
                                                FROM zx_rates_b
                                                WHERE
                                                tax_regime_code  = Rates.tax_regime_code and
                                                tax              = Rates.tax and
                                                tax_status_code  = Rates.tax_status_code and
                                                tax_rate_code    = Rates.tax_rate_code and
                                                content_owner_id = Rates.content_owner_id and
                                                rate_type_code   = Rates.rate_type_code          -- Added for Bug#7504455
                                                )
                        )
                   AND (NVL(sd_rates.view_options_code,'NONE') in ('NONE', 'VFC') OR
                            (NVL(sd_rates.view_options_code, 'VFR') = 'VFR'
                                 AND NOT EXISTS (SELECT 1 FROM zx_rates_b b
                                                  WHERE b.tax_regime_code = Rates.tax_regime_code
                                                    AND b.tax = Rates.tax
                                                    AND b.tax_status_code = Rates.tax_status_code
                                                    AND b.tax_rate_code = Rates.tax_rate_code
                                                    AND b.content_owner_id = sd_rates.first_pty_org_id
                                                    AND b.rate_type_code = Rates.rate_type_code   -- Added for Bug#7504455
                                                 )
                             )
                        )
               ) qry
    where TaxLines.application_id   = qry.application_id
                   AND TaxLines.entity_code      = qry.entity_code
                   AND TaxLines.event_class_code = qry.event_class_code
                   AND TaxLines.trx_id           = qry.trx_id
                   AND TaxLines.summary_tax_line_number = qry.summary_tax_line_number
       AND ROWNUM = 1  -- To Prevent more than one row being fetched for a single row update
  )
  WHERE TaxLines.tax_rate_code IS NULL
  AND TaxLines.tax_rate_id IS NOT NULL
  AND ( TaxLines.tax_regime_code IS NULL OR TaxLines.tax IS NULL );

 END IF;  -- IF l_count_rate_id_null <> 0
END IF;   -- IF l_count_reg_null = 0

IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                'ZX.PL/SQL.ZX_VALIDATE_API_PKG.DEFAULT_TAX_ATTR',
                'ZX_VALIDATE_API_PKG.DEFAULT_TAX_ATTR:Defaulting for Tax Status Code');
END IF;

-- Execute this query only if tax_status_code is null
-- If customer has populated the same in interface tables need not default again.

IF l_count_status_null = 0 THEN

  UPDATE ZX_IMPORT_TAX_LINES_GT TaxLines
        SET tax_status_code =
        (SELECT Status.tax_status_code
           FROM ZX_STATUS_B Status,
                ZX_TRX_HEADERS_GT Header,
                --ZX_TRANSACTION_LINES_GT Lines,
                ZX_SUBSCRIPTION_DETAILS sd_status,
                ZX_RATES_B              rates,
                ZX_SUBSCRIPTION_DETAILS sd_rates
          WHERE Status.tax_regime_code     = TaxLines.tax_regime_code
            AND Status.tax                 = TaxLines.tax
            --AND Status.default_status_flag = 'Y'
            AND (Taxlines.tax_rate_code IS NOT NULL OR Taxlines.tax_rate_id IS NOT NULL)
            AND ((Taxlines.tax_rate_code IS NOT NULL and rates.tax_rate_code = Taxlines.tax_rate_code)
            OR  (Taxlines.tax_rate_id IS NOT NULL and rates.tax_rate_id = Taxlines.tax_rate_id))
            AND rates.tax_status_code = Status.tax_status_code
            AND Taxlines.tax_date --Bug 5018766
                BETWEEN status.effective_from
                AND NVL(Status.effective_to, Taxlines.tax_date ) --Bug 5018766,6982881
            AND TaxLines.application_id    = Header.application_id
            AND TaxLines.entity_code       = Header.entity_code
            AND TaxLines.event_class_code  = Header.event_class_code
            AND TaxLines.trx_id            = Header.trx_id
            --AND Lines.application_id       = Header.application_id
      --AND Lines.entity_code          = Header.entity_code
      --AND Lines.event_class_code     = Header.event_class_code
      --AND Lines.trx_id               = Header.trx_id
      --AND
      --(-- One to One Alloc
    --(
        --lines.trx_line_id = TaxLines.trx_line_id
    --)
    --OR
    --Multi Alloc
    --(
        --TaxLines.trx_line_id IS NULL
        --AND TaxLines.tax_line_allocation_flag = 'Y'
        --AND lines.trx_line_id =
        --(
        --SELECT
      --MIN(trx_line_id)
        --FROM zx_trx_tax_link_gt link_gt
        --WHERE link_gt.TRX_ID = TaxLines.trx_id
      --AND link_gt.application_id = TaxLines.application_id
      --AND link_gt.entity_code = TaxLines.entity_code
      --AND link_gt.event_class_code = TaxLines.event_class_code
      --AND link_gt.summary_tax_line_number = TaxLines.summary_tax_line_number
        --)
    --)
    --OR
    --All Alloc
    --(
        --TaxLines.trx_line_id IS NULL
        --AND TaxLines.tax_line_allocation_flag = 'N'
        --AND lines.trx_line_id =
        --(
        --SELECT
      --MIN(trx_line_id)
        --FROM zx_transaction_lines_gt trans_line_gt
        --WHERE trans_line_gt.trx_id = TaxLines.trx_id
      --AND trans_line_gt.application_id = TaxLines.application_id
      --AND trans_line_gt.entity_code = TaxLines.entity_code
      --AND trans_line_gt.event_class_code = TaxLines.event_class_code
        --)
    --)
      --)
      AND status.tax_regime_code     = sd_status.tax_regime_code
      AND status.content_owner_id    = sd_status.parent_first_pty_org_id
      AND sd_status.first_pty_org_id = g_first_pty_org_id
      AND (Taxlines.subscription_date
            BETWEEN NVL(sd_status.effective_from,
            Taxlines.subscription_date
            )
            AND NVL(sd_status.effective_to,
        Taxlines.subscription_date
        )
                  OR  status.effective_from = (SELECT MIN(effective_from)
                         FROM ZX_STATUS_B
                        WHERE tax_regime_code  = status.tax_regime_code and
                              tax              = status.tax and
                              tax_status_code  = status.tax_status_code and
                              content_owner_id = status.content_owner_id
                       )
           )
      AND (NVL(sd_status.view_options_code,'NONE') in ('NONE', 'VFC') OR
               (NVL(sd_status.view_options_code,'VFR') = 'VFR'
               AND NOT EXISTS ( SELECT 1 FROM zx_status_vl b
                     WHERE b.tax_regime_code = status.tax_regime_code
                     AND b.tax = status.tax
                     AND b.tax_status_code = status.tax_status_code
                     AND b.content_owner_id = sd_status.first_pty_org_id
                   )
                )
           )
      AND Rates.tax_regime_code     = sd_rates.tax_regime_code(+)
      AND Rates.rate_type_code <> 'RECOVERY'                         -- Added for Bug#7504455
      AND ( Rates.content_owner_id    = sd_rates.parent_first_pty_org_id
            OR sd_rates.parent_first_pty_org_id IS NULL )
      --AND sd_rates.first_pty_org_id(+) = g_first_pty_org_id
      AND sd_rates.first_pty_org_id IN (g_first_pty_org_id, -99)
      AND (Taxlines.subscription_date
            BETWEEN NVL(sd_rates.effective_from,
                       Taxlines.subscription_date)
            AND NVL(sd_rates.effective_to,
                    Taxlines.subscription_date)
            OR
            Rates.effective_from = (SELECT MIN(effective_from)
                                    FROM zx_rates_b
                                    WHERE
                                    tax_regime_code  = Rates.tax_regime_code and
                                    tax              = Rates.tax and
                                    tax_status_code  = Rates.tax_status_code and
                                    tax_rate_code    = Rates.tax_rate_code and
                                    content_owner_id = Rates.content_owner_id and
                                    rate_type_code   = Rates.rate_type_code     -- Added for Bug#7504455
                                    )
            )
      AND (NVL(sd_rates.view_options_code,'NONE') in ('NONE', 'VFC') OR
          (NVL(sd_rates.view_options_code, 'VFR') = 'VFR'
           AND NOT EXISTS (SELECT 1 FROM zx_rates_b b
                           WHERE b.tax_regime_code = Rates.tax_regime_code
                           AND b.tax = Rates.tax
                           AND b.tax_status_code = Rates.tax_status_code
                           AND b.tax_rate_code = Rates.tax_rate_code
                           AND b.content_owner_id = sd_rates.first_pty_org_id
                           AND b.rate_type_code = Rates.rate_type_code          -- Added for Bug#7504455
                           )
          ))
      AND ROWNUM = 1 -- To Prevent more than one row being fetched for a single row update
   )
  WHERE tax_status_code is NULL AND
        (tax_rate_code IS NOT NULL OR tax_rate_id IS NOT NULL);

END IF;

IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
             'ZX.PL/SQL.ZX_VALIDATE_API_PKG.DEFAULT_TAX_ATTR',
             'ZX_VALIDATE_API_PKG.DEFAULT_TAX_ATTR:Defaulting for tax_provider_id in ZX_IMPORT_TAX_LINES_GT ');
END IF;

-- Execute this query only if provider_id is populated
-- If customer has populated the same in interface tables need not default again.

IF l_count_pvr_null = 0 THEN

--Defaulting for tax Provider Id
  Update ZX_IMPORT_TAX_LINES_GT TaxLines
  SET tax_provider_id =
          (SELECT /*+ leading (mapp) */ srvc.srvc_provider_id
             FROM ZX_SRVC_SUBSCRIPTIONS srvc,
                  ZX_REGIMES_USAGES reg,
                  ZX_TRX_HEADERS_GT Header,
                  --ZX_TRANSACTION_LINES_GT Lines,
                  ZX_EVNT_CLS_MAPPINGS mapp
            WHERE reg.tax_regime_code   =  TaxLines.tax_regime_code
              AND srvc.regime_usage_id  = reg.regime_usage_id
              AND srvc.enabled_flag = 'Y'
              AND mapp.application_id =  TaxLines.application_id
              AND mapp.entity_code =  TaxLines.entity_code
              AND mapp.event_class_code =  TaxLines.event_class_code
              AND TaxLines.application_id = Header.application_id
              AND TaxLines.entity_code = Header.entity_code
              AND TaxLines.event_class_code = Header.event_class_code
              AND TaxLines.trx_id = Header.trx_id
              AND srvc.prod_family_grp_code = mapp.prod_family_grp_code
              --AND Lines.application_id      = Header.application_id
        --AND Lines.entity_code         = Header.entity_code
        --AND Lines.event_class_code    = Header.event_class_code
        --AND Lines.trx_id              = Header.trx_id
        --AND
        --(-- One to One Alloc
    --(
        --lines.trx_line_id = TaxLines.trx_line_id
    --)
    --OR
    --Multi Alloc
    --(
        --TaxLines.trx_line_id IS NULL
        --AND TaxLines.tax_line_allocation_flag = 'Y'
        --AND lines.trx_line_id =
        --(
        --SELECT
      --MIN(trx_line_id)
        --FROM zx_trx_tax_link_gt link_gt
        --WHERE link_gt.TRX_ID = TaxLines.trx_id
      --AND link_gt.application_id = TaxLines.application_id
      --AND link_gt.entity_code = TaxLines.entity_code
      --AND link_gt.event_class_code = TaxLines.event_class_code
      --AND link_gt.summary_tax_line_number = TaxLines.summary_tax_line_number
        --)
    --)
    --OR
    --All Alloc
    --(
        --TaxLines.trx_line_id IS NULL
        --AND TaxLines.tax_line_allocation_flag = 'N'
        --AND lines.trx_line_id =
        --(
        --SELECT
      --MIN(trx_line_id)
        --FROM zx_transaction_lines_gt trans_line_gt
        --WHERE trans_line_gt.trx_id = TaxLines.trx_id
      --AND trans_line_gt.application_id = TaxLines.application_id
      --AND trans_line_gt.entity_code = TaxLines.entity_code
      --AND trans_line_gt.event_class_code = TaxLines.event_class_code
        --)
    --)
        --)
              AND Taxlines.subscription_date
                  BETWEEN(srvc.effective_from) AND
                      NVL(srvc.effective_to,
                          Taxlines.subscription_date)

              AND reg.first_pty_org_id  = g_first_pty_org_id
        AND NOT EXISTS (SELECT 1
                          FROM ZX_SRVC_SBSCRPTN_EXCLS excl
                               WHERE excl.application_id   = TaxLines.application_id
                                 AND excl.entity_code      = TaxLines.entity_code
                                 AND excl.event_class_code = TaxLines.event_class_code
                                 AND excl.srvc_subscription_id = srvc_subscription_id
                    )
      AND ROWNUM = 1 -- To Prevent more than one row being fetched for a single row update
         )
  WHERE tax_provider_id is NULL AND
        (tax_rate_code IS NOT NULL OR tax_rate_id IS NOT NULL);

END IF;

/* Bug 4703541 : Defaulting for Tax Jurisdiction Code */
/* Seperated the  Defaulting for Tax Jurisdiction Code as tax_rate_code
is defaulted based on the Jurisdiction Code */
IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                'ZX.PL/SQL.ZX_VALIDATE_API_PKG.DEFAULT_TAX_ATTR',
                'ZX_VALIDATE_API_PKG.DEFAULT_TAX_ATTR:Defaulting for Tax Jurisdiction Code ');
END IF;

-- Execute this query when tax_jurisdiction_code is null
-- If customer has populated the same in interface tables then need not default again.

IF l_count_jur_null = 0  THEN

  UPDATE ZX_IMPORT_TAX_LINES_GT TaxLines
        SET tax_jurisdiction_code =
        (SELECT jur.TAX_JURISDICTION_CODE
           FROM ZX_JURISDICTIONS_B Jur,
                ZX_TRX_HEADERS_GT Header,
                --ZX_TRANSACTION_LINES_GT Lines,
                ZX_RATES_B              rates,
                ZX_SUBSCRIPTION_DETAILS sd_rates
          WHERE
         Jur.tax                 = TaxLines.Tax
     AND Jur.tax_regime_code     = TaxLines.Tax_Regime_Code
     --AND Jur.default_jurisdiction_flag = 'Y'
     AND Jur.tax_jurisdiction_code = rates.tax_jurisdiction_code(+)
     AND (Taxlines.tax_rate_code IS NOT NULL OR Taxlines.tax_rate_id IS NOT NULL)
     AND ((Taxlines.tax_rate_code IS NOT NULL and rates.tax_rate_code = Taxlines.tax_rate_code)
         OR  (Taxlines.tax_rate_id IS NOT NULL and rates.tax_rate_id = Taxlines.tax_rate_id))
            AND  Taxlines.tax_date --Bug 5018766
           BETWEEN Jur.effective_from
           AND NVL(Jur.effective_to, Taxlines.tax_date ) --Bug 5018766
     --AND lines.tax_date --Bug 5018766
           --BETWEEN Jur.default_flg_effective_from
           --AND NVL(Jur.default_flg_effective_to,
           --    lines.tax_date)
            AND TaxLines.application_id    = Header.application_id
            AND TaxLines.entity_code       = Header.entity_code
            AND TaxLines.event_class_code  = Header.event_class_code
            AND TaxLines.trx_id            = Header.trx_id
            --AND Lines.application_id       = TaxLines.application_id
      --AND Lines.entity_code          = TaxLines.entity_code
      --AND Lines.event_class_code     = TaxLines.event_class_code
      --AND Lines.trx_id               = TaxLines.trx_id
      --AND
           --(-- One to One Alloc
    --(
        --lines.trx_line_id = TaxLines.trx_line_id
    --)
    --OR
    --Multi Alloc
    --(
        --TaxLines.trx_line_id IS NULL
        --AND TaxLines.tax_line_allocation_flag = 'Y'
        --AND lines.trx_line_id =
        --(
        --SELECT
      --MIN(trx_line_id)
        --FROM zx_trx_tax_link_gt link_gt
        --WHERE link_gt.TRX_ID = TaxLines.trx_id
      --AND link_gt.application_id = TaxLines.application_id
      --AND link_gt.entity_code = TaxLines.entity_code
      --AND link_gt.event_class_code = TaxLines.event_class_code
      --AND link_gt.summary_tax_line_number = TaxLines.summary_tax_line_number
        --)
    --)
    --OR
    --All Alloc
    --(
        --TaxLines.trx_line_id IS NULL
        --AND TaxLines.tax_line_allocation_flag = 'N'
        --AND lines.trx_line_id =
        --(
        --SELECT
      --MIN(trx_line_id)
        --FROM zx_transaction_lines_gt trans_line_gt
        --WHERE trans_line_gt.trx_id = TaxLines.trx_id
      --AND trans_line_gt.application_id = TaxLines.application_id
      --AND trans_line_gt.entity_code = TaxLines.entity_code
      --AND trans_line_gt.event_class_code = TaxLines.event_class_code
        --)
    --)
      --)
     AND Rates.tax_regime_code     = sd_rates.tax_regime_code(+)
 	   AND ( Rates.content_owner_id    = sd_rates.parent_first_pty_org_id
 	                         OR sd_rates.parent_first_pty_org_id IS NULL )
 	   --AND sd_rates.first_pty_org_id(+) = g_first_pty_org_id
 	   AND sd_rates.first_pty_org_id IN (g_first_pty_org_id, -99)
 	   AND (Taxlines.subscription_date
 	        BETWEEN NVL(sd_rates.effective_from,
 	                    Taxlines.subscription_date)
 	        AND NVL(sd_rates.effective_to,
 	                    Taxlines.subscription_date)
 	   OR
 	     Rates.effective_from = (SELECT MIN(effective_from)
 	                             FROM zx_rates_b
 	                             WHERE
 	                                  tax_regime_code  = Rates.tax_regime_code and
 	                                  tax              = Rates.tax and
 	                                  tax_status_code  = Rates.tax_status_code and
 	                                  tax_rate_code    = Rates.tax_rate_code and
 	                                  content_owner_id = Rates.content_owner_id
 	                             )
 	       )
 	   AND (NVL(sd_rates.view_options_code,'NONE') in ('NONE', 'VFC') OR
 	       (NVL(sd_rates.view_options_code, 'VFR') = 'VFR'
 	        AND NOT EXISTS (SELECT 1 FROM zx_rates_b b
 	                        WHERE b.tax_regime_code = Rates.tax_regime_code
 	                        AND b.tax = Rates.tax
 	                        AND b.tax_status_code = Rates.tax_status_code
 	                        AND b.tax_rate_code = Rates.tax_rate_code
 	                        AND b.content_owner_id = sd_rates.first_pty_org_id
 	                       )
 	   ))
      AND ROWNUM = 1 -- To Prevent more than one row being fetched for a single row update
   )
  WHERE tax_jurisdiction_code is NULL AND
       (tax_rate_code IS NOT NULL OR tax_rate_id IS NOT NULL);

END IF;

IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                'ZX.PL/SQL.ZX_VALIDATE_API_PKG.DEFAULT_TAX_ATTR',
                'ZX_VALIDATE_API_PKG.DEFAULT_TAX_ATTR:Defaulting for Tax Rate Code,
    Tax Rate Id, Percentage Rate ');
END IF;

/* Defaulting for Tax Rate Code, Tax Rate Id, Percentage Rate */
--Bug 4703541 : Seperated Logic to Default Rates and the Jurisdiction Code.
-- bug 7414628 split the query using UNION ALL based on tax_rate_code and tax_rate_id


  UPDATE zx_import_tax_lines_gt  TaxLines
  SET (tax_rate_code,
       tax_rate_id,
       tax_rate) =
    (
  SELECT NVL(TaxLines.tax_rate_code, qry.rate_code),
         NVL(TaxLines.tax_rate_id, qry.rate_id),
         NVL(TaxLines.tax_rate, qry.percnt_rate)
  FROM (
    SELECT /*+ leading ( taxlines_gt,header ) */
           NVL(taxlines_gt.tax_rate_code,Rates.tax_rate_code) rate_code,
           NVL(taxlines_gt.tax_rate_id,Rates.tax_rate_id) rate_id,
           NVL(taxlines_gt.tax_rate,Rates.percentage_rate) percnt_rate,
           TaxLines_gt.application_id application_id,
           TaxLines_gt.entity_code entity_code,
           TaxLines_gt.event_class_code event_class_code,
           TaxLines_gt.trx_id trx_id,
           TaxLines_gt.summary_tax_line_number summary_tax_line_number
    FROM zx_rates_b rates,
         zx_trx_headers_gt header,
         --zx_transaction_lines_gt lines,
         zx_subscription_details sd_rates,
         zx_import_tax_lines_gt  taxlines_gt
    WHERE TaxLines_gt.tax_regime_Code = rates.tax_regime_code(+)
--      AND (Taxlines.tax_rate_code IS NOT NULL OR Taxlines.tax_rate_id IS NOT NULL)
      AND TaxLines_gt.tax = rates.tax(+)
      AND ( TaxLines_gt.tax_jurisdiction_code = rates.tax_jurisdiction_code
            OR
            rates.tax_jurisdiction_code IS NULL
            OR
            TaxLines_gt.tax_jurisdiction_code IS NULL
          )
      --and Rates.default_rate_flag(+) = 'Y'
      AND TaxLines_gt.tax_status_code = rates.tax_status_code(+)
--                  AND ((Taxlines.tax_rate_code IS NOT NULL AND
--                                              Taxlines.tax_rate_code = rates.tax_rate_code)
--                      OR (Taxlines.tax_rate_id IS NOT NULL AND
--                                              Taxlines.tax_rate_id = rates.tax_rate_id))
      AND taxlines_gt.tax_rate_code = rates.tax_rate_code
      AND Taxlines_gt.tax_date --Bug 5018766
                   -- BETWEEN nvl(Rates.default_flg_effective_from,  -- Commented as a fix of Bug#7148665
                   -- AND NVL(Rates.default_flg_effective_to,        -- Commented as a fix of Bug#7148665
          BETWEEN NVL(Rates.effective_from, Taxlines_gt.tax_date)
              AND NVL(Rates.effective_to, Taxlines_gt.tax_date)
      AND TaxLines_gt.tax_regime_code = sd_rates.tax_regime_code(+)
      AND Rates.active_flag = 'Y'
      AND Rates.rate_type_code <> 'RECOVERY'                         -- Added for Bug#7504455
      AND ( Rates.content_owner_id = sd_rates.parent_first_pty_org_id
            OR
            sd_rates.parent_first_pty_org_id IS NULL
          )
      --AND sd_rates.first_pty_org_id(+) = g_first_pty_org_id
      AND sd_rates.first_pty_org_id IN (g_first_pty_org_id, -99)
      AND (Taxlines_gt.subscription_date
            BETWEEN NVL(sd_rates.effective_from,Taxlines_gt.subscription_date)
                AND NVL(sd_rates.effective_to,Taxlines_gt.subscription_date)
           OR
           Rates.effective_from = (SELECT MIN(effective_from)
                                     FROM zx_rates_b
                                    WHERE tax_regime_code  = Rates.tax_regime_code
                                      and tax              = Rates.tax
                                      and tax_status_code  = Rates.tax_status_code
                                      and tax_rate_code    = Rates.tax_rate_code
                                      and content_owner_id = Rates.content_owner_id
                                      and rate_type_code   = Rates.rate_type_code   -- Added for Bug#7504455
                                  )
          )
      AND ( NVL(sd_rates.view_options_code,'NONE') in ('NONE', 'VFC')
            OR
            (NVL(sd_rates.view_options_code, 'VFR') = 'VFR'
                AND NOT EXISTS (SELECT 1 FROM zx_rates_b b
                                 WHERE b.tax_regime_code  = Rates.tax_regime_code
                                   AND b.tax              = Rates.tax
                                   AND b.tax_status_code  = Rates.tax_status_code
                                   AND b.tax_rate_code    = Rates.tax_rate_code
                                   AND b.content_owner_id = sd_rates.first_pty_org_id
                                   AND b.rate_type_code   = Rates.rate_type_code    -- Added for Bug#7504455
                               )
           )
         )
      AND TaxLines_gt.application_id   = Header.application_id
      AND TaxLines_gt.entity_code      = Header.entity_code
      AND TaxLines_gt.event_class_code = Header.event_class_code
      AND TaxLines_gt.trx_id           = Header.trx_id
      --AND Lines.application_id      = Header.application_id
      --AND Lines.entity_code         = Header.entity_code
      --AND Lines.event_class_code    = Header.event_class_code
      --AND Lines.trx_id              = Header.trx_id
      --AND (
             -- One to One Alloc
             --( lines.trx_line_id = TaxLines.trx_line_id )
              --OR
             --Multi Alloc
             --(      TaxLines.trx_line_id IS NULL
                --AND TaxLines.tax_line_allocation_flag = 'Y'
                --AND lines.trx_line_id =
                       --(SELECT MIN(trx_line_id)
                          --FROM zx_trx_tax_link_gt link_gt
                         --WHERE link_gt.TRX_ID                  = TaxLines.trx_id
                           --AND link_gt.application_id          = TaxLines.application_id
                           --AND link_gt.entity_code             = TaxLines.entity_code
                           --AND link_gt.event_class_code        = TaxLines.event_class_code
                           --AND link_gt.summary_tax_line_number = TaxLines.summary_tax_line_number
                       --)
             --)
             --OR
             --All Alloc
            --(       TaxLines.trx_line_id IS NULL
                --AND TaxLines.tax_line_allocation_flag = 'N'
                --AND lines.trx_line_id =
                       --(SELECT MIN(trx_line_id)
                          --FROM zx_transaction_lines_gt trans_line_gt
                         --WHERE trans_line_gt.trx_id           = TaxLines.trx_id
                           --AND trans_line_gt.application_id   = TaxLines.application_id
                           --AND trans_line_gt.entity_code      = TaxLines.entity_code
                           --AND trans_line_gt.event_class_code = TaxLines.event_class_code
                       --)
             --)
          --)
      ) qry
  WHERE TaxLines.application_id   = qry.application_id
    AND TaxLines.entity_code      = qry.entity_code
    AND TaxLines.event_class_code = qry.event_class_code
    AND TaxLines.trx_id           = qry.trx_id
    AND TaxLines.summary_tax_line_number = qry.summary_tax_line_number
    AND ROWNUM =1  -- To Prevent more than one row being fetched for a single row update
    );

-- Execute this query only when tax_rate_id is not null

IF l_count_rate_id_null <> 0 THEN

UPDATE zx_import_tax_lines_gt  TaxLines
SET (tax_rate_code,
     tax_rate_id,
     tax_rate) =
    (
  SELECT NVL(TaxLines.tax_rate_code, qry.rate_code),
         NVL(TaxLines.tax_rate_id, qry.rate_id),
         NVL(TaxLines.tax_rate, qry.percnt_rate)
  FROM (
    SELECT NVL(taxlines_gt.tax_rate_code,Rates.tax_rate_code) rate_code,
           NVL(taxlines_gt.tax_rate_id,Rates.tax_rate_id) rate_id,
           NVL(taxlines_gt.tax_rate,Rates.percentage_rate) percnt_rate,
           TaxLines_gt.application_id application_id,
           TaxLines_gt.entity_code entity_code,
           TaxLines_gt.event_class_code event_class_code,
           TaxLines_gt.trx_id trx_id,
           TaxLines_gt.summary_tax_line_number summary_tax_line_number
    FROM zx_rates_b rates,
         zx_trx_headers_gt header,
         --zx_transaction_lines_gt lines,
         zx_subscription_details sd_rates,
         zx_import_tax_lines_gt  taxlines_gt
    WHERE TaxLines_gt.tax_regime_Code = rates.tax_regime_code(+)
--      AND (Taxlines.tax_rate_code IS NOT NULL OR Taxlines.tax_rate_id IS NOT NULL)
      AND TaxLines_gt.tax = rates.tax(+)
      AND ( TaxLines_gt.tax_jurisdiction_code = rates.tax_jurisdiction_code
            OR
            rates.tax_jurisdiction_code IS NULL
            OR
            TaxLines_gt.tax_jurisdiction_code IS NULL
          )
      --and Rates.default_rate_flag(+) = 'Y'
      AND TaxLines_gt.tax_status_code = rates.tax_status_code(+)
--                  AND ((Taxlines.tax_rate_code IS NOT NULL AND
--                                              Taxlines.tax_rate_code = rates.tax_rate_code)
--                      OR (Taxlines.tax_rate_id IS NOT NULL AND
--                                              Taxlines.tax_rate_id = rates.tax_rate_id))
      AND Taxlines_gt.tax_rate_id = rates.tax_rate_id
      AND Taxlines_gt.tax_date --Bug 5018766
                   -- BETWEEN nvl(Rates.default_flg_effective_from,  -- Commented as a fix of Bug#7148665
                   -- AND NVL(Rates.default_flg_effective_to,        -- Commented as a fix of Bug#7148665
          BETWEEN nvl(Rates.effective_from, Taxlines_gt.tax_date)
              AND NVL(Rates.effective_to, Taxlines_gt.tax_date)
      AND TaxLines_gt.tax_regime_code = sd_rates.tax_regime_code(+)
      AND Rates.active_flag = 'Y'
      AND Rates.rate_type_code <> 'RECOVERY'                         -- Added for Bug#7504455
      AND ( Rates.content_owner_id = sd_rates.parent_first_pty_org_id
            OR
            sd_rates.parent_first_pty_org_id IS NULL
          )
      --AND sd_rates.first_pty_org_id(+) = g_first_pty_org_id
      AND sd_rates.first_pty_org_id IN (g_first_pty_org_id, -99)
      AND (Taxlines_gt.subscription_date
            BETWEEN NVL(sd_rates.effective_from,Taxlines_gt.subscription_date)
                AND NVL(sd_rates.effective_to,Taxlines_gt.subscription_date)
           OR
           Rates.effective_from = (SELECT MIN(effective_from)
                                     FROM zx_rates_b
                                    WHERE tax_regime_code  = Rates.tax_regime_code
                                      and tax              = Rates.tax
                                      and tax_status_code  = Rates.tax_status_code
                                      and tax_rate_code    = Rates.tax_rate_code
                                      and content_owner_id = Rates.content_owner_id
                                      and rate_type_code   = Rates.rate_type_code  -- Added for Bug#7504455
                                  )
          )
      AND ( NVL(sd_rates.view_options_code,'NONE') in ('NONE', 'VFC')
            OR
            (NVL(sd_rates.view_options_code, 'VFR') = 'VFR'
                AND NOT EXISTS (SELECT 1 FROM zx_rates_b b
                                 WHERE b.tax_regime_code  = Rates.tax_regime_code
                                   AND b.tax              = Rates.tax
                                   AND b.tax_status_code  = Rates.tax_status_code
                                   AND b.tax_rate_code    = Rates.tax_rate_code
                                   AND b.content_owner_id = sd_rates.first_pty_org_id
                                   AND b.rate_type_code   = Rates.rate_type_code   -- Added for Bug#7504455
                               )
           )
         )
      AND TaxLines_gt.application_id   = Header.application_id
      AND TaxLines_gt.entity_code      = Header.entity_code
      AND TaxLines_gt.event_class_code = Header.event_class_code
      AND TaxLines_gt.trx_id           = Header.trx_id
      --AND Lines.application_id      = Header.application_id
      --AND Lines.entity_code         = Header.entity_code
      --AND Lines.event_class_code    = Header.event_class_code
      --AND Lines.trx_id              = Header.trx_id
      --AND (
             -- One to One Alloc
             --( lines.trx_line_id = TaxLines.trx_line_id )
          --)
      ) qry
  WHERE TaxLines.application_id   = qry.application_id
    AND TaxLines.entity_code      = qry.entity_code
    AND TaxLines.event_class_code = qry.event_class_code
    AND TaxLines.trx_id           = qry.trx_id
    AND TaxLines.summary_tax_line_number = qry.summary_tax_line_number
    AND ROWNUM =1  -- To Prevent more than one row being fetched for a single row update
    )
  WHERE (TaxLines.tax_rate_code IS NULL OR
         TaxLines.tax_rate_id IS NULL OR
         TaxLines.tax_rate IS NULL);

END IF;

/*Defaulting for Transaction Business Category and Product Category
  Product Fiscal Classification  and Assessable Value */

IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                'ZX.PL/SQL.ZX_VALIDATE_API_PKG.DEFAULT_TAX_ATTR',
        'ZX_VALIDATE_API_PKG.DEFAULT_TAX_ATTR:
        Defaulting for Transaction Business Category and Product Category,
        Product Fiscal Classification  and Assessable Value');
END IF;

IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                'ZX.PL/SQL.ZX_VALIDATE_API_PKG.DEFAULT_TAX_ATTR',
                'ZX_VALIDATE_API_PKG.DEFAULT_TAX_ATTR: Before Call to the private procedure
                 to default the additional tax attributes ');
END IF;

-- Call the private procedure to default the tax attributes.
def_additional_tax_attribs;

IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                'ZX.PL/SQL.ZX_VALIDATE_API_PKG.DEFAULT_TAX_ATTR',
                'ZX_VALIDATE_API_PKG.DEFAULT_TAX_ATTR:Defaulting tax amount if it is NULL
                 and tax rate is specified  ');
END IF;

---  CR 3275391 Default tax amount if it is NULL and tax rate is specified ----
/* Commented for the Bug 4902521
UPDATE ZX_IMPORT_TAX_LINES_GT  TaxLines
SET tax_amt = (SELECT CASE WHEN (tax_amt_included_flag  <> 'Y')
                           THEN  tax_rate * line_amt / ( 100 + sum_of_tax_rates)
                           WHEN (sum_of_tax_rates = 0 )
                           THEN  0
                           END
                 FROM (SELECT (SELECT SUM(tax_rate)
                                 FROM temp
                              GROUP BY trx_line_id) sum_of_tax_rates ,
                              TAX_AMT_INCLUDED_FLAG,
                              LINE_AMT, tax_rate
                         FROM  -- temp subqry
                              (SELECT TaxLines.tax_rate,
                                      TaxLines.tax_amt_included_flag,
                                      TaxLink.line_amt,
                                      TaxLines.trx_id,
                                      TaxLines.trx_line_id
                                 FROM ZX_TRX_TAX_LINK_GT       TaxLink,
                                      ZX_IMPORT_TAX_LINES_GT   TaxLines,
                                      ZX_TRX_HEADERS_GT        Header,
                                      ZX_TRANSACTION_LINES_GT  Lines,
                                      ZX_TAXES_B               tax,
                                      zx_rates_b               rate,
                                      zx_subscription_details  sd_tax,
                                      zx_subscription_details  sd_rates
                                WHERE Taxlines.TAX_LINE_ALLOCATION_FLAG  = 'Y'
                                  AND TaxLines.tax_amt is NULL
                                  AND TaxLines.tax_rate is not NULL
                                  AND TaxLines.application_id  = taxLink.application_id
                                  AND TaxLines.entity_code  = taxLink.entity_code
                                  AND TaxLines.event_class_code  = taxLink.event_class_code
                                  AND TaxLines.summary_tax_line_number  = taxLink.summary_tax_line_number
                                  AND TaxLines.trx_id = TaxLink.trx_id
                                  AND TaxLines.application_id   = Header.application_id
                AND TaxLines.entity_code      = Header.entity_code
                AND TaxLines.event_class_code = Header.event_class_code
                      AND TaxLines.trx_id           = Header.trx_id
                      AND Lines.application_id      = Header.application_id
          AND Lines.entity_code         = Header.entity_code
          AND Lines.event_class_code    = Header.event_class_code
          AND Lines.trx_id              = Header.trx_id
          AND
          (-- One to One Alloc
          (
              lines.trx_line_id = TaxLines.trx_line_id
          )
          OR
          --Multi Alloc
          (
              TaxLines.trx_line_id IS NULL
              AND TaxLines.tax_line_allocation_flag = 'Y'
              AND lines.trx_line_id =
              (
              SELECT
            MIN(trx_line_id)
              FROM zx_trx_tax_link_gt link_gt
              WHERE link_gt.TRX_ID = TaxLines.trx_id
            AND link_gt.application_id = TaxLines.application_id
            AND link_gt.entity_code = TaxLines.entity_code
            AND link_gt.event_class_code = TaxLines.event_class_code
            AND link_gt.summary_tax_line_number = TaxLines.summary_tax_line_number
              )
          )
          OR
          --All Alloc
          (
              TaxLines.trx_line_id IS NULL
              AND TaxLines.tax_line_allocation_flag = 'N'
              AND lines.trx_line_id =
              (
              SELECT
            MIN(trx_line_id)
              FROM zx_transaction_lines_gt trans_line_gt
              WHERE trans_line_gt.trx_id = TaxLines.trx_id
            AND trans_line_gt.application_id = TaxLines.application_id
            AND trans_line_gt.entity_code = TaxLines.entity_code
            AND trans_line_gt.event_class_code = TaxLines.event_class_code
              )
          )
          )
                                  --* for taxes
                                  AND NVL(tax.def_taxable_basis_formula,'STANDARD_TB') = 'STANDARD_TB'
                                  AND tax.tax(+)              = taxlines.tax
                                  AND tax.tax_regime_code     = sd_tax.tax_regime_code (+)
                                  AND tax.content_owner_id    = sd_tax.parent_first_pty_org_id(+)
                                  AND sd_tax.first_pty_org_id(+) = g_first_pty_org_id
                                  AND(COALESCE(header.related_doc_date,
                                               header.provnl_tax_determination_date,
                                               Lines.adjusted_doc_date,
                                               header.trx_date,
                                               SYSDATE)
                                        BETWEEN nvl(sd_tax.effective_from,
                                                    COALESCE(header.related_doc_date,
                                                             header.provnl_tax_determination_date,
                                                             Lines.adjusted_doc_date,
                                                             header.trx_date,
                                                             SYSDATE) )
                                            AND NVL(sd_tax.effective_to,
                                                    COALESCE(header.related_doc_date,
                                                             header.provnl_tax_determination_date,
                                                             Lines.adjusted_doc_date,
                                                             header.trx_date,
                                                             SYSDATE) )
                                      OR
                                          tax.effective_from = (SELECT MIN(effective_from)
                                                                  FROM ZX_TAXES_B
                                                                 WHERE
                                                                 tax_regime_code  = tax.tax_regime_code and
                                                                 tax      = tax.tax and
                                                                 content_owner_id = tax.content_owner_id
                                                                )
                                       )
                                  and (nvl(sd_tax.view_options_code,'NONE')  in ('NONE', 'VFC') OR
                                        (nvl(sd_tax.view_options_code,'VFR') = 'VFR'
                                           AND NOT EXISTS (SELECT 1 FROM zx_taxes_b b
                                                            WHERE tax.tax_regime_code = b.tax_regime_code
                                                              AND tax.tax  =  b.tax
                                                              AND sd_tax.first_pty_org_id = b.content_owner_id
                                                           )
                                             )
                                       )
                                  --* for rates
                                  AND NVL(rate.rate_type_code,'PERCENTAGE') = 'PERCENTAGE'
                                  AND rate.tax_rate_id(+)       = taxlines.tax_rate_id
                                  AND rate.tax_rate_code (+)    = taxlines.tax_rate_code
                                  AND rate.tax_regime_code      = sd_rates.tax_regime_code (+)
                                  AND rate.content_owner_id     = sd_rates.parent_first_pty_org_id (+)
                                  AND sd_rates.first_pty_org_id(+) = g_first_pty_org_id
                      AND (COALESCE(header.related_doc_date,
                                    header.provnl_tax_determination_date,
                                    Lines.adjusted_doc_date,
                                    header.trx_date,
                                    SYSDATE)
                                  BETWEEN nvl( sd_rates.effective_from,
                                               COALESCE(header.related_doc_date,
                                                        header.provnl_tax_determination_date,
                                                        Lines.adjusted_doc_date,
                                                        header.trx_date,
                                                        SYSDATE) )
                                  AND nvl(sd_rates.effective_to,
                                          COALESCE(header.related_doc_date,
                                                   header.provnl_tax_determination_date,
                                                   Lines.adjusted_doc_date,
                                                   header.trx_date,
                                                   SYSDATE) )
                                                      OR
                                   rate.effective_from = (select min(effective_from)
                                                            from ZX_RATES_B
                                                           where
                                                           tax_regime_code  = rate.tax_regime_code and
                                                           tax        = rate.tax and
                                                           tax_status_code  = rate.tax_status_code and
                                                           tax_rate_code    = rate.tax_rate_code and
                                                           content_owner_id = rate.content_owner_id
                                                          )
                                  )
                                  AND (NVL(sd_rates.view_options_code,'NONE') in ('NONE', 'VFC') OR
                                        (NVL(sd_rates.view_options_code, 'VFR') = 'VFR'
                                           AND NOT EXISTS (select 1 from zx_rates_b b
                                                            where b.tax_regime_code = rate.tax_regime_code
                                                              and b.tax             = rate.tax
                                                              and b.tax_status_code = rate.tax_status_code
                                                              and b.tax_rate_code = rate.tax_rate_code
                                                              and b.content_owner_id = sd_rates.first_pty_org_id
                                                           )
                                         )
                                       )
                       )) temp
               ); */

-- Bug#3910168
-- Defaulting for  tax classification code

IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                'ZX.PL/SQL.ZX_VALIDATE_API_PKG.DEFAULT_TAX_ATTR',
                'ZX_VALIDATE_API_PKG.DEFAULT_TAX_ATTR: Defaulting for  tax classification code -
    Call to pop_def_tax_classif_code');
END IF;

     pop_def_tax_classif_code(x_return_status);

     IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                'ZX_VALIDATE_API_PKG.DEFAULT_TAX_ATTR.END',
                'ZX_VALIDATE_API_PKG.DEFAULT_TAX_ATTR(-)');
     END IF;

EXCEPTION
                WHEN OTHERS THEN
                IF (g_level_unexpected >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_unexpected,
                          'ZX_VALIDATE_API_PKG.DEFAULT_TAX_ATTR',
                           sqlerrm);
                END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                app_exception.raise_exception;

END Default_Tax_Attr;


--------------Wrapper Procedure For Validating -----------------------

PROCEDURE Validate_Tax_Attr(x_return_status OUT NOCOPY VARCHAR2) IS

  l_trx_id_tbl                        TRX_ID_TBL;
  l_trx_line_id_tbl                   TRX_LINE_ID_TBL;
  l_trx_level_type_tbl                TRX_LEVEL_TYPE_TBL;
  l_event_class_code_tbl              EVENT_CLASS_CODE_TBL;
  l_entity_code_tbl                   ENTITY_CODE_TBL;
  l_application_id_tbl                APPLICATION_ID_TBL;
  l_summary_tax_line_number_tbl       SUMMARY_TAX_LINE_NUMBER_TBL;
  l_count                             NUMBER;
  l_error_buffer                      VARCHAR2(240);

  c_lines_per_commit CONSTANT NUMBER := ZX_TDS_CALC_SERVICES_PUB_PKG.G_LINES_PER_COMMIT;

  CURSOR get_header_and_line_info_csr
  IS
  SELECT
  header.application_id,
  header.entity_code,
  header.event_class_code,
  header.trx_id,
  lines_gt.trx_line_id,
  lines_gt.trx_level_type

  FROM
       ZX_TRX_HEADERS_GT             header,
       ZX_EVNT_CLS_MAPPINGS          evntmap,
       ZX_TRANSACTION_LINES_GT       lines_gt,
       ZX_FC_PRODUCT_CATEGORIES_V    fc_prodcat,
       ZX_FC_CODES_B                 fc_user,
       ZX_FC_DOCUMENT_FISCAL_V       fc_doc,
       ZX_FC_BUSINESS_CATEGORIES_V   fc_trx,
       ZX_FC_CODES_B                 fc_int,
       FND_LOOKUPS                   fnd,
       FND_TERRITORIES               fnd_terr,
       ZX_FC_PRODUCT_FISCAL_V        fc_product
       --ZX_RATES_B                  rates       --Commented for Bug#7504455--

  WHERE
      lines_gt.trx_id = header.trx_id
  and fc_product.classification_code(+) =
      lines_gt.product_fisc_classification
  and fc_prodcat.classification_code(+) =
      lines_gt.product_category
  and fc_user.classification_type_code(+) = 'USER_DEFINED'
  and fc_user.classification_code(+) =
      lines_gt.user_defined_fisc_class
  and fc_doc.classification_code(+) = header.document_sub_type
  and fc_trx.classification_code(+) = lines_gt.trx_business_category
  and fc_trx.application_id(+)      = lines_gt.application_id
  and fc_trx.entity_code(+)         = lines_gt.entity_code
  and fc_trx.event_class_code(+)    = lines_gt.event_class_code
  and fc_int.classification_type_code(+) = 'INTENDED_USE'
  and fc_int.classification_code(+)      =
      lines_gt.line_intended_use
  and header.application_id    = evntmap.application_id (+)
  and header.entity_code       = evntmap.entity_code (+)
  and header.event_class_code  = evntmap.event_class_code(+)
  and fnd.lookup_type(+)    = 'ZX_PRODUCT_TYPE' AND
      fnd.lookup_code(+) = lines_gt.product_type
  and fnd_terr.territory_code(+) =
      header.default_taxation_country;
  --Commented for Bug#7504455--
  --and rates.tax_rate_code(+) = NVL(lines_gt.output_tax_classification_code,
  --                                 lines_gt.input_tax_classification_code);


  CURSOR get_import_tax_line_info_csr
  IS
  SELECT /*+ leading(tax_lines_gt) */
      header.application_id,
      header.entity_code,
      header.event_class_code,
      header.trx_id,
      lines_gt.trx_line_id,
      lines_gt.trx_level_type,
      taxlines_gt.summary_tax_line_number
  FROM ZX_TRX_HEADERS_GT header,
      ZX_REGIMES_B regime ,
      ZX_TAXES_B tax ,
      ZX_STATUS_B status ,
  --    ZX_RATES_B rate ,
  --    zx_rates_b off_rate,
  --    zx_import_tax_lines_gt temp_gt,
      ZX_IMPORT_TAX_LINES_GT taxlines_gt,
      zx_transaction_lines_gt lines_gt,
      ZX_JURISDICTIONS_B jur,
      zx_subscription_details sd_reg,
      zx_subscription_details sd_tax,
      zx_subscription_details sd_status
  --    zx_subscription_details sd_rates
  WHERE taxlines_gt.trx_id = header.trx_id
      AND taxlines_gt.application_id = Header.application_id
      AND taxlines_gt.entity_code = Header.entity_code
      AND taxlines_gt.event_class_code = Header.event_class_code
            --AND (taxlines_gt.tax_rate_code IS NOT NULL OR taxlines_gt.tax_rate_id IS NOT NULL)
      AND jur.tax_jurisdiction_code(+) = taxlines_gt.tax_jurisdiction_code
      AND jur.tax_regime_code(+) = taxlines_gt.tax_regime_code
      AND jur.tax(+) = taxlines_gt.tax
      AND
      (
    lines_gt.tax_date --Bug 5018766
    BETWEEN
         nvl(jur.effective_from, lines_gt.tax_date) AND
         nvl(jur.effective_to,lines_gt.tax_date)
    /*OR jur.effective_from =
    (
    SELECT
        min(effective_from)
    FROM ZX_JURISDICTIONS_B
    WHERE tax_jurisdiction_code = jur.tax_jurisdiction_code
    ) */
      )
      AND lines_gt.application_id = header.application_id
      AND lines_gt.entity_code = header.entity_code
      AND lines_gt.event_class_code = header.event_class_code
      AND lines_gt.trx_id = header.trx_id
      AND
      (-- One to One Alloc
    (
        lines_gt.trx_line_id = taxlines_gt.trx_line_id
    )
    OR
    --Multi Alloc
    (
        taxlines_gt.trx_line_id IS NULL
        AND taxlines_gt.tax_line_allocation_flag = 'Y'
        AND lines_gt.trx_line_id =
        (
        SELECT
      MIN(trx_line_id)
        FROM zx_trx_tax_link_gt link_gt
        WHERE link_gt.TRX_ID = taxlines_gt.trx_id
      AND link_gt.application_id = taxlines_gt.application_id
      AND link_gt.entity_code = taxlines_gt.entity_code
      AND link_gt.event_class_code = taxlines_gt.event_class_code
      AND link_gt.summary_tax_line_number = taxlines_gt.summary_tax_line_number
        )
    )
    OR
    --All Alloc
    (
        taxlines_gt.trx_line_id IS NULL
        AND taxlines_gt.tax_line_allocation_flag = 'N'
        AND lines_gt.trx_line_id =
        (
        SELECT
      MIN(trx_line_id)
        FROM zx_transaction_lines_gt trans_line_gt
        WHERE trans_line_gt.trx_id = taxlines_gt.trx_id
      AND trans_line_gt.application_id = taxlines_gt.application_id
      AND trans_line_gt.entity_code = taxlines_gt.entity_code
      AND trans_line_gt.event_class_code = taxlines_gt.event_class_code
        )
    )
      )
      --* for regime
      AND regime.tax_regime_code(+) = taxlines_gt.tax_regime_code
      AND regime.TAX_REGIME_CODE = sd_reg.tax_regime_code (+)
      --AND sd_reg.first_pty_org_id(+) = g_first_pty_org_id
      AND sd_reg.first_pty_org_id IN (g_first_pty_org_id, -99)
      AND nvl(sd_reg.view_options_code,'NONE') in ('NONE', 'VFC') -- Bug 4902521
      AND (
    lines_gt.subscription_date
    BETWEEN
    NVL(sd_reg.effective_from,
        lines_gt.subscription_date
        )
    AND
    NVL(sd_reg.effective_to,
        lines_gt.subscription_date
        )
       /* OR regime.effective_from =
        (
        SELECT
      MIN(effective_from)
        FROM zx_regimes_b
        WHERE tax_regime_code = regime.tax_regime_code
        ) */
    )
      --* for taxes
      AND tax.tax(+) = taxlines_gt.tax
      AND tax.tax_regime_code(+) = taxlines_gt.tax_regime_code
      AND tax.tax_regime_code = sd_tax.tax_regime_code (+)
      AND (
     tax.content_owner_id = sd_tax.parent_first_pty_org_id
     OR
     sd_tax.parent_first_pty_org_id is NULL
    )
      --AND sd_tax.first_pty_org_id(+) = g_first_pty_org_id
      AND sd_tax.first_pty_org_id IN (g_first_pty_org_id, -99)
      AND
      (
    lines_gt.subscription_date
    BETWEEN
    nvl(sd_tax.effective_from,
        lines_gt.subscription_date
       )
        AND
        NVL(sd_tax.effective_to,
      lines_gt.subscription_date
           )
    /*OR tax.effective_from =
    (
    SELECT
        min(effective_from)
    FROM ZX_TAXES_B
    WHERE tax_regime_code = tax.tax_regime_code
        AND tax = tax.tax
        AND content_owner_id = tax.content_owner_id
    ) */
      )
      AND
      (
    nvl(sd_tax.view_options_code,'NONE') in ('NONE', 'VFC')
    OR
    (
        nvl(sd_tax.view_options_code,'VFR') = 'VFR'
        AND not exists
        (
        SELECT
      1
        FROM zx_taxes_b b
        WHERE tax.tax_regime_code = b.tax_regime_code
      AND tax.tax = b.tax
      AND sd_tax.first_pty_org_id = b.content_owner_id
        )
    )
      )
      --* for status
      AND status.tax_status_code(+) = taxlines_gt.tax_status_code
      AND status.tax(+) = taxlines_gt.tax
      AND status.tax_regime_code(+) = taxlines_gt.tax_regime_code
      AND status.tax_regime_code = sd_status.tax_regime_code (+)
      AND
         (
    status.content_owner_id = sd_status.parent_first_pty_org_id
    OR
     sd_status.parent_first_pty_org_id is NULL
         )
      --AND sd_status.first_pty_org_id(+) = g_first_pty_org_id
      AND sd_status.first_pty_org_id IN (g_first_pty_org_id, -99)
      AND
      (
    lines_gt.subscription_date
    BETWEEN
    nvl( sd_status.effective_from,
         lines_gt.subscription_date
       )
       AND
       nvl(sd_status.effective_to,
           lines_gt.subscription_date
      )
    /*OR status.effective_from =
    (
    SELECT
        min(effective_from)
    FROM ZX_STATUS_B
    WHERE tax_regime_code = status.tax_regime_code
        AND tax = status.tax
        AND tax_status_code = status.tax_status_code
        AND content_owner_id = status.content_owner_id
    ) */
      )
      AND
      (
    NVL(sd_status.view_options_code,'NONE') in ('NONE', 'VFC')
    OR
    (
        NVL(sd_status.view_options_code,'VFR') = 'VFR'
        AND not exists
        (
        SELECT
      1
        FROM zx_status_vl b
        WHERE b.tax_regime_code = status.tax_regime_code
      AND b.tax = status.tax
      AND b.tax_status_code = status.tax_status_code
      AND b.content_owner_id = sd_status.first_pty_org_id
        )
    )
      ) ;

  CURSOR get_tax_link_gt_info_csr
  IS
  SELECT
  application_id,
  entity_code,
  event_class_code,
  trx_id,
  interface_line_id,
  trx_level_type,
  summary_tax_line_number
  FROM zx_trx_tax_link_gt;

BEGIN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
        IF (g_level_procedure >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_procedure,
                        'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR.BEGIN',
                        'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR(+)');
        END IF;

        --Validations for ZX_TRX_HEADERS_GT, ZX_TRANSACTION_LINES_GT
  IF ( g_level_event >= g_current_runtime_level) THEN
    FND_LOG.STRING(g_level_event,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'Validations for zx_trx_headers_gt and zx_transaction_lines_gt');
  END IF;

  -- Select the key columns and write into fnd log for debug purpose
  IF ( g_level_statement >= g_current_runtime_level) THEN
   FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
      'Before opening the cursor - get_header_and_line_info_csr');

    OPEN get_header_and_line_info_csr;

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
      'After opening the cursor - get_header_and_line_info_csr');

    LOOP
      FETCH get_header_and_line_info_csr BULK COLLECT INTO
      l_application_id_tbl,
      l_entity_code_tbl,
      l_event_class_code_tbl,
      l_trx_id_tbl,
      l_trx_line_id_tbl,
      l_trx_level_type_tbl

        LIMIT C_LINES_PER_COMMIT;


--        EXIT WHEN get_header_and_line_info_csr%notfound;

      l_count := nvl(l_trx_line_id_tbl.COUNT,0);

    FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
             'number of rows fetched = ' || to_char(l_count));

      IF l_count > 0 THEN

        FOR i IN 1.. l_count LOOP

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'Row Number = ' || to_char(i) );

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'l_application_id = ' || to_char(l_application_id_tbl(i)) );

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'l_entity_code = ' || l_entity_code_tbl(i) );

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'l_event_class_code = ' || l_event_class_code_tbl(i) );

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'l_trx_id = ' || to_char(l_trx_id_tbl(i)) );

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'l_trx_line_id = ' || to_char(l_trx_line_id_tbl(i)) );

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'l_trx_level_type = ' || l_trx_level_type_tbl(i) );

        END LOOP;
      ELSE
         EXIT ;

      END IF; -- end of count checking

    END LOOP;

    CLOSE get_header_and_line_info_csr;

          -- Clear the records
    l_application_id_tbl.delete;
    l_entity_code_tbl.delete;
    l_event_class_code_tbl.delete;
    l_trx_id_tbl.delete;
    l_trx_line_id_tbl.delete;
    l_trx_level_type_tbl.delete;

  END IF; -- End of debug checking

  IF ( g_level_statement >= g_current_runtime_level) THEN
    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'Before insertion into ZX_VALIDATION_ERRORS_GT - zx_trx_headers_gt and zx_transaction_lines_gt');
  END IF;

/******************** Split the Header and Line Level Validations : Bug 4703541******/
  /** 1. Validations for the zx_trx_headers_gt related **/

  INSERT ALL
  WHEN (ZX_ROUND_PARTY_MISSING = 'Y')  THEN
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
    interface_line_entity_code,
    interface_line_id
    )
  VALUES(
    application_id,
    entity_code,
    event_class_code,
    trx_id,
    NULL ,--trx_line_id,
    NULL,
    'ZX_ROUND_PARTY_MISSING',
    l_round_party_missing,
    NULL ,--trx_level_type,
    NULL ,--interface_line_entity_code,
    NULL --interface_line_id
     )
  WHEN (ZX_CTRL_FLAG_MISSING = 'Y')  THEN

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
    interface_line_entity_code,
    interface_line_id
    )
  VALUES(
    application_id,
    entity_code,
    event_class_code,
    trx_id,
    NULL ,--trx_line_id,
    NULL,
    'ZX_CTRFLAG_MISSING',
    l_ctrl_flag_missing,
    NULL ,--trx_level_type,
    NULL ,--interface_line_entity_code,
    NULL --interface_line_id
   )
  WHEN (TAXATION_COUNTRY_NOT_EXISTS = 'Y')  THEN

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
    interface_line_entity_code,
    interface_line_id
  )
  VALUES(
    application_id,
    entity_code,
    event_class_code,
    trx_id,
    NULL ,--trx_line_id,
    NULL,
    'ZX_TAXATION_COUNTRY_NOT_EXIST',
    l_taxation_country_not_exists,
    NULL ,--trx_level_type,
    NULL ,--interface_line_entity_code,
    NULL --interface_line_id
   )
  WHEN (DOC_FC_CODE_NOT_EXISTS = 'Y')  THEN

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
    interface_line_entity_code,
    interface_line_id
    )
  VALUES(
    application_id,
    entity_code,
    event_class_code,
    trx_id,
    NULL ,--trx_line_id,
    NULL,
    'ZX_DOC_FC_CODE_NOT_EXIST',
    l_doc_fc_code_not_exists,
    NULL ,--trx_level_type,
    NULL ,--interface_line_entity_code,
    NULL --interface_line_id
     )

  WHEN (DOC_FC_COUNTRY_INCONSIS = 'Y')  THEN

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
    interface_line_entity_code,
    interface_line_id
    )
  VALUES(
    application_id,
    entity_code,
    event_class_code,
    trx_id,
    NULL ,--trx_line_id,
    NULL,
    'ZX_DOC_FC_COUNTRY_INCONSIS',
    l_doc_fc_country_inconsis,
    NULL ,--trx_level_type,
    NULL ,--interface_line_entity_code,
    NULL --interface_line_id
     )
  WHEN (PARTY_NOT_EXISTS = 'Y')  THEN

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
      interface_line_entity_code,
      interface_line_id
      )
    VALUES(
      application_id,
      entity_code,
      event_class_code,
      trx_id,
      NULL ,--trx_line_id,
      NULL,
      'ZX_PARTY_NOT_EXISTS',
      l_party_not_exists,
      NULL ,--trx_level_type,
      NULL ,--interface_line_entity_code,
      NULL --interface_line_id
     )
  WHEN (ZX_CURRENCY_INFO_REQD = 'Y')  THEN

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
      interface_line_entity_code,
      interface_line_id
      )
    VALUES(
      application_id,
      entity_code,
      event_class_code,
      trx_id,
      NULL ,--trx_line_id,
      NULL,
      'ZX_CURRENCY_INFO_REQD',
      l_currency_info_reqd,
      NULL ,--trx_level_type,
      NULL ,--interface_line_entity_code,
      NULL --interface_line_id
     )
  WHEN (ZX_QUOTE_FLAG_INVALID = 'Y')  THEN

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
      interface_line_entity_code,
      interface_line_id
      )
    VALUES(
      application_id,
      entity_code,
      event_class_code,
      trx_id,
      NULL ,--trx_line_id,
      NULL,
      'ZX_QUOTE_FLAG_INVALID',
      l_quote_flag_invalid,
      NULL ,--trx_level_type,
      NULL ,--interface_line_entity_code,
      NULL --interface_line_id
     )
  WHEN (ZX_DOC_LVL_RECALC_FLAG_INVALID = 'Y')  THEN
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
      interface_line_entity_code,
      interface_line_id
      )
    VALUES(
      application_id,
      entity_code,
      event_class_code,
      trx_id,
      NULL ,--trx_line_id,
      NULL,
      'ZX_DOC_LVL_RECALC_FLAG_INVALID',
      l_doc_lvl_recalc_flag_invalid,
      NULL ,--trx_level_type,
      NULL ,--interface_line_entity_code,
      NULL --interface_line_id
     )
  SELECT
  header.application_id,
  header.entity_code,
  header.event_class_code,
  header.trx_id,
  -- Check for existence of at least one rounding party
  CASE WHEN (header.rounding_ship_from_party_id is NULL AND
       header.rounding_ship_to_party_id is NULL AND
       header.rounding_bill_to_party_id is NULL AND
       header.rounding_bill_from_party_id is NULL )
        THEN 'Y'
        ELSE NULL
   END  ZX_ROUND_PARTY_MISSING,

  -- Check for existence of Control tax amount
       nvl2(header.ctrl_total_hdr_tx_amt,
       CASE WHEN ( NOT EXISTS
      (SELECT 1 FROM ZX_TRANSACTION_LINES_GT lines1
       WHERE lines1.ctrl_hdr_tx_appl_flag  = 'Y'
       AND lines1.trx_id = header.trx_id
       AND lines1.application_id = header.application_id
       AND lines1.entity_code = header.entity_code
       AND lines1.event_class_code = header.event_class_code)
           )
      THEN 'Y'
      ELSE NULL
       END,
       NULL
       ) ZX_CTRL_FLAG_MISSING,

  -- Check for Taxation Country
  nvl2(header.default_taxation_country,
       nvl(fnd_terr.territory_code,'Y'),
       NULL ) TAXATION_COUNTRY_NOT_EXISTS,

  -- Check for document subtype code exists
  nvl2(header.document_sub_type,
       nvl(fc_doc.classification_code,'Y'),
       null) DOC_FC_CODE_NOT_EXISTS,

  -- Check for document subtype code Effectivity
     /*  CASE WHEN header.document_sub_type is not null and
      fc_doc.classification_code is not null
       THEN
         CASE WHEN COALESCE(header.related_doc_date,
             header.provnl_tax_determination_date,
             lines_gt.adjusted_doc_date,
             lines_gt.trx_line_date,
             header.trx_date,
             SYSDATE)  NOT BETWEEN
         fc_doc.effective_from AND
         nvl(fc_doc.effective_to,
         COALESCE(header.related_doc_date,
            header.provnl_tax_determination_date,
            lines_gt.adjusted_doc_date,
            lines_gt.trx_line_date,
            header.trx_date,
            SYSDATE)
         )
        THEN 'Y'
        ELSE NULL END
       ELSE NULL END DOC_FC_CODE_NOT_EFFECTIVE,*/

  -- Check for document subtype code Country Consistency
  CASE WHEN (fc_doc.classification_code is not null AND
       fc_doc.country_code is not null)
       THEN CASE WHEN(fc_doc.country_code =
          header.default_taxation_country)
           THEN NULL
           ELSE 'Y' END
       ELSE NULL
   END DOC_FC_COUNTRY_INCONSIS,

  -- Check existence of PartyId in PartyTaxProfile
  --Bug 4703541
   CASE   WHEN (header.ESTABLISHMENT_ID IS NOT NULL
          AND NOT EXISTS
           (SELECT 1
      FROM   zx_party_tax_profile ptp,
             XLE_ETB_PROFILES etb
      WHERE  ptp.party_id = etb.party_id
      AND    ptp.party_type_code = 'LEGAL_ESTABLISHMENT'
      AND    header.ESTABLISHMENT_ID = etb.ESTABLISHMENT_ID)
         )
      OR
        (header.LEGAL_ENTITY_ID IS NOT NULL
         AND NOT EXISTS
          (SELECT 1
           FROM   zx_party_tax_profile ptp,
            XLE_ENTITY_PROFILES etp
           WHERE  ptp.party_id = etp.party_id
           AND    ptp.party_type_code = 'FIRST_PARTY'
           AND    header.LEGAL_ENTITY_ID = etp.LEGAL_ENTITY_ID)
         )
    THEN 'Y'
    ELSE NULL END PARTY_NOT_EXISTS,

  --If currency information is not passed at header level,
  --it should be passed on all transaction lines of that header
  --Bug 4703541
  CASE WHEN (header.TRX_CURRENCY_CODE is NULL
       AND header.precision is NULL )
       AND EXISTS
       ( SELECT 1 FROM zx_transaction_lines_gt
           WHERE application_id = header.application_id
           AND   entity_code = header.entity_code
           AND   event_class_code = header.event_class_code
           AND   trx_id = header.trx_id
           AND   ( TRX_LINE_CURRENCY_CODE is NULL
           OR trx_line_precision is NULL)
        )
       THEN 'Y'
       ELSE NULL
  END  ZX_CURRENCY_INFO_REQD,

  CASE WHEN header.quote_flag IS NOT NULL AND
        header.quote_flag NOT IN ('Y', 'N')
       THEN 'Y'
       ELSE  NULL
  END  ZX_QUOTE_FLAG_INVALID,

  CASE WHEN header.doc_level_recalc_flag IS NOT NULL AND
        header.quote_flag NOT IN ('Y', 'N')
       THEN 'Y'
       ELSE  NULL
  END  ZX_DOC_LVL_RECALC_FLAG_INVALID
  FROM
    ZX_TRX_HEADERS_GT             header,
    ZX_EVNT_CLS_MAPPINGS          evntmap,
    ZX_FC_DOCUMENT_FISCAL_V       fc_doc,
    FND_TERRITORIES               fnd_terr
  WHERE
    fc_doc.classification_code(+) = header.document_sub_type
    and header.application_id    = evntmap.application_id (+)
    and header.entity_code       = evntmap.entity_code (+)
    and header.event_class_code  = evntmap.event_class_code(+)
    and fnd_terr.territory_code(+) =
    header.default_taxation_country;

        -- Bug 4902521 : Added Message to check no. of rows inserted .
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF ( g_level_statement >= g_current_runtime_level) THEN
    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'No. of Rows inserted for Header Realted Validations '|| to_char(sql%ROWCOUNT) );
  END IF;

  /** 2. Validating for the Line Related Validations : zx_transaction_lines_gt **/
        g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF ( g_level_statement >= g_current_runtime_level) THEN
    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'Validating for the Line Related Validations : zx_transaction_lines_gt');
  END IF;

        INSERT ALL

        WHEN (ZX_LOCATION_MISSING = 'Y')  THEN

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
        interface_line_entity_code,
        interface_line_id
        )
      VALUES(
        application_id,
        entity_code,
        event_class_code,
        trx_id,
        trx_line_id,
        NULL,
        'ZX_LOCATION_MISSING',
        l_location_missing,
        trx_level_type,
        interface_line_entity_code,
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
        interface_line_entity_code,
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
        interface_line_entity_code,
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
                                interface_line_entity_code,
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
                                interface_line_entity_code,
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
                                interface_line_entity_code,
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
                                interface_line_entity_code,
                                interface_line_id
                                 )

      WHEN (PRODUCT_CATEG_NOT_EXISTS = 'Y')  THEN

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
                        interface_line_entity_code,
                        interface_line_id
                        )
                VALUES(
                        application_id,
                        entity_code,
                        event_class_code,
                        trx_id,
                        trx_line_id,
                        NULL,
                        'ZX_PRODUCT_CATEG_NOT_EXIST',
                        l_prd_categ_not_exists,
                        trx_level_type,
                        interface_line_entity_code,
                        interface_line_id
                         )

      WHEN (PRODUCT_CATEG_NOT_EFFECTIVE = 'Y')  THEN

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
                        interface_line_entity_code,
                        interface_line_id
                        )
                VALUES(
                        application_id,
                        entity_code,
                        event_class_code,
                        trx_id,
                        trx_line_id,
                        NULL,
                        'ZX_PRODUCT_CATEG_NOT_EFFECTIVE',
                        l_prd_categ_not_effective,
                        trx_level_type,
                        interface_line_entity_code,
                        interface_line_id
                         )

        WHEN (PRODUCT_CATEG_COUNTRY_INCONSIS = 'Y')  THEN

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
                                interface_line_entity_code,
                                interface_line_id
                                )
                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                NULL,
                                'ZX_PRODUCT_CATEG_COUNTRY_INCON',
                                l_prd_categ_country_inconsis,
                                trx_level_type,
                                interface_line_entity_code,
                                interface_line_id
                                 )

        WHEN (USER_DEF_FC_CODE_NOT_EXISTS = 'Y')  THEN

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
                                interface_line_entity_code,
                                interface_line_id
                                )
                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                NULL,
                                'ZX_USER_DEF_FC_CODE_NOT_EXIST',
                                l_usr_df_fc_code_not_exists,
                                trx_level_type,
                                interface_line_entity_code,
                                interface_line_id
                                 )

        WHEN (USER_DEF_FC_CODE_NOT_EFFECTIVE = 'Y')  THEN

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
                                interface_line_entity_code,
                                interface_line_id
                                )
                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                NULL,
                                'ZX_USER_DEF_FC_CODE_NOT_EFFECT',
                                l_usr_df_fc_code_not_effective,
                                trx_level_type,
                                interface_line_entity_code,
                                interface_line_id
                         )
        WHEN (USER_DEF_COUNTRY_INCONSIS = 'Y')  THEN

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
                                interface_line_entity_code,
                                interface_line_id
                                )
                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                NULL,
                                'ZX_USER_DEF_COUNTRY_INCONSIS',
                                l_usr_df_country_inconsis,
                                trx_level_type,
                                interface_line_entity_code,
                                interface_line_id
                                 )

         WHEN (DOC_FC_CODE_NOT_EFFECTIVE = 'Y')  THEN

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
                                interface_line_entity_code,
                                interface_line_id
                                )
                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                NULL,
                                'ZX_DOC_FC_CODE_NOT_EFFECTIVE',
                                l_doc_fc_code_not_effective,
                                trx_level_type,
                                interface_line_entity_code,
                                interface_line_id
                                 )

        WHEN (TRX_BIZ_FC_CODE_NOT_EXISTS = 'Y')  THEN

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
                                interface_line_entity_code,
                                interface_line_id
                                )
                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                NULL,
                                'ZX_TRX_BIZ_FC_CODE_NOT_EXIST',
                                l_trx_biz_fc_code_not_exists,
                                trx_level_type,
                                interface_line_entity_code,
                                interface_line_id
                                 )

        WHEN (TRX_BIZ_FC_CODE_NOT_EFFECTIVE = 'Y')  THEN

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
                                interface_line_entity_code,
                                interface_line_id
                                )
                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                NULL,
                                'ZX_TRX_BIZ_FC_CODE_NOT_EFFECT',
                                l_trx_biz_fc_code_not_effect,
                                trx_level_type,
                                interface_line_entity_code,
                                interface_line_id
                                 )

        WHEN (TRX_BIZ_FC_COUNTRY_INCONSIS = 'Y')  THEN

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
                                interface_line_entity_code,
                                interface_line_id
                                )
                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                NULL,
                                'ZX_TRX_BIZ_FC_COUNTRY_INCONSIS',
                                l_trx_biz_fc_country_inconsis,
                                trx_level_type,
                                interface_line_entity_code,
                                interface_line_id
                                 )



        WHEN (INTENDED_USE_CODE_NOT_EXISTS = 'Y')  THEN

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
                                        interface_line_entity_code,
                                        interface_line_id
                                        )
                                VALUES(
                                        application_id,
                                        entity_code,
                                        event_class_code,
                                        trx_id,
                                        trx_line_id,
                                        NULL,
                                        'ZX_INTENDED_USE_CODE_NOT_EXIST',
                                        l_intended_use_code_not_exists,
                                        trx_level_type,
                                        interface_line_entity_code,
                                        interface_line_id
                                         )

        WHEN (INTENDED_USE_NOT_EFFECTIVE = 'Y')  THEN

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
                                        interface_line_entity_code,
                                        interface_line_id
                                        )
                                VALUES(
                                        application_id,
                                        entity_code,
                                        event_class_code,
                                        trx_id,
                                        trx_line_id,
                                        NULL,
                                        'ZX_INTENDED_USE_NOT_EFFECTIVE',
                                        l_intended_use_not_effective,
                                        trx_level_type,
                                        interface_line_entity_code,
                                        interface_line_id
                                         )

        WHEN (INTENDED_USE_CONTRY_INCONSIS = 'Y')  THEN

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
                                        interface_line_entity_code,
                                        interface_line_id
                                        )
                                VALUES(
                                        application_id,
                                        entity_code,
                                        event_class_code,
                                        trx_id,
                                        trx_line_id,
                                        NULL,
                                        'ZX_INTENDED_USE_COUNTRY_INCON',
                                        l_intended_use_contry_inconsis,
                                        trx_level_type,
                                        interface_line_entity_code,
                                        interface_line_id
                                         )

        WHEN (PRODUCT_TYPE_CODE_NOT_EXISTS = 'Y')  THEN

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
                                        interface_line_entity_code,
                                        interface_line_id
                                        )
                                VALUES(
                                        application_id,
                                        entity_code,
                                        event_class_code,
                                        trx_id,
                                        trx_line_id,
                                        NULL,
                                        'ZX_PRODUCT_TYPE_CODE_NOT_EXIST',
                                        l_prd_type_code_not_exists,
                                        trx_level_type,
                                        interface_line_entity_code,
                                        interface_line_id
                                         )

        WHEN (PRODUCT_TYPE_NOT_EFFECTIVE = 'Y')  THEN

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
                                        interface_line_entity_code,
                                        interface_line_id
                                        )
                                VALUES(
                                        application_id,
                                        entity_code,
                                        event_class_code,
                                        trx_id,
                                        trx_line_id,
                                        NULL,
                                        'ZX_PRODUCT_TYPE_NOT_EFFECTIVE',
                                        l_prd_type_not_effective,
                                        trx_level_type,
                                        interface_line_entity_code,
                                        interface_line_id
                                         )

        WHEN (PRODUCT_FC_CODE_NOT_EXISTS = 'Y')  THEN

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
                                        interface_line_entity_code,
                                        interface_line_id
                                        )
                                VALUES(
                                        application_id,
                                        entity_code,
                                        event_class_code,
                                        trx_id,
                                        trx_line_id,
                                        NULL,
                                        'ZX_PRODUCT_FC_CODE_NOT_EXIST',
                                        l_prd_fc_code_not_exists,
                                        trx_level_type,
                            interface_line_entity_code,
                            interface_line_id
                                         )
/*      bugfix 4919842: remove party not exist and site not exist checks
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
                                        trx_level_type,
                            interface_line_entity_code,
                            interface_line_id
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
                                        trx_level_type,
                            interface_line_entity_code,
                            interface_line_id
                                 )

        WHEN (SHIP_FROM_PARTY_NOT_EXISTS = 'Y')  THEN

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
                            interface_line_entity_code,
                            interface_line_id
                                        )
                                VALUES(
                                        application_id,
                                        entity_code,
                                        event_class_code,
                                        trx_id,
                                        trx_line_id,
                                        NULL,
                                        'ZX_SHIP_FROM_PARTY_NOT_EXIST',
                                        l_ship_frm_party_not_exits,
                                        trx_level_type,
                            interface_line_entity_code,
                            interface_line_id
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
                                        trx_level_type,
                            interface_line_entity_code,
                            interface_line_id
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
                                        trx_level_type,
                            interface_line_entity_code,
                            interface_line_id
                                 )

        WHEN (BILL_FROM_PARTY_NOT_EXISTS = 'Y')  THEN

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
                            interface_line_entity_code,
                            interface_line_id
                                        )
                                VALUES(
                                        application_id,
                                        entity_code,
                                        event_class_code,
                                        trx_id,
                                        trx_line_id,
                                        NULL,
                                        'ZX_BILFROM_PARTY_NOT_EXIST',
                                        l_bill_frm_party_not_exists,
                                        trx_level_type,
                            interface_line_entity_code,
                            interface_line_id
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
                                        trx_level_type,
                            interface_line_entity_code,
                            interface_line_id
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
                                        trx_level_type,
                            interface_line_entity_code,
                            interface_line_id
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
                                        trx_level_type,
                            interface_line_entity_code,
                            interface_line_id
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
                                        trx_level_type,
                            interface_line_entity_code,
                            interface_line_id
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
                                        trx_level_type,
                            interface_line_entity_code,
                            interface_line_id
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
                                        trx_level_type,
                            interface_line_entity_code,
                            interface_line_id
                                 )

          WHEN (BILLFROM_PARTY_SITE_NOT_EXISTS = 'Y')  THEN

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
                            interface_line_entity_code,
                            interface_line_id
                                        )
                                VALUES(
                                        application_id,
                                        entity_code,
                                        event_class_code,
                                        trx_id,
                                        trx_line_id,
                                        NULL,
                                        'ZX_BILLFROM_PARTY_SITE_NOT_EXIST',
                                        l_billfrm_party_site_not_exist,
                                        trx_level_type,
                            interface_line_entity_code,
                      interface_line_id
                                 )
      bugfix 4919842: remove party not exist and site not exist checks  */
          -- bug 6915776
          /*WHEN (ZX_LINE_CTRL_AMT_INVALID = 'Y')  THEN

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
                            interface_line_entity_code,
                            interface_line_id
                                        )
                                VALUES(
                                        application_id,
                                        entity_code,
                                        event_class_code,
                                        trx_id,
                                        trx_line_id,
                                        NULL,
                                        'ZX_LINE_CTRL_AMT_INVALID',
                                        l_line_ctrl_amt_invalid,
                                        trx_level_type,
                            interface_line_entity_code,
                      interface_line_id
                                 )*/

          WHEN (ZX_LINE_CTRL_AMT_NOT_NULL = 'Y')  THEN

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
                                        interface_line_entity_code,
                                        interface_line_id
                                        )
                                VALUES(
                                        application_id,
                                        entity_code,
                                        event_class_code,
                                        trx_id,
                                        trx_line_id,
                                        NULL,
                                        'ZX_LINE_CTRL_AMT_NOT_NULL',
                                        l_line_ctrl_amt_not_null,
                                        trx_level_type,
                                        interface_line_entity_code,
                                        interface_line_id
                                 )

-- Bug 5516630: Moved unit price and quantity check to determine_recovery API

/*           WHEN (ZX_UNIT_PRICE_MISSING = 'Y')  THEN

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
                                        interface_line_entity_code,
                                        interface_line_id
                                        )
                                VALUES(
                                        application_id,
                                        entity_code,
                                        event_class_code,
                                        trx_id,
                                        trx_line_id,
                                        NULL,
                                        'ZX_UNIT_PRICE_REQD',
                                        l_unit_price_missing,
                                        trx_level_type,
                                        interface_line_entity_code,
                                        interface_line_id
                                 )

           WHEN (ZX_LINE_QUANTITY_MISSING = 'Y')  THEN

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
                                        interface_line_entity_code,
                                        interface_line_id
                                        )
                                VALUES(
                                        application_id,
                                        entity_code,
                                        event_class_code,
                                        trx_id,
                                        trx_line_id,
                                        NULL,
                                        'ZX_TRX_LINE_QUANTITY_REQD',
                                        l_line_quantity_missing,
                                        trx_level_type,
                                        interface_line_entity_code,
                                        interface_line_id
                                 )
*/
                 WHEN (ZX_EXEMPTION_CTRL_FLAG_INVALID = 'Y')  THEN

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
                                        interface_line_entity_code,
                                        interface_line_id
                                        )
                                VALUES(
                                        application_id,
                                        entity_code,
                                        event_class_code,
                                        trx_id,
                                        trx_line_id,
                                        NULL,
                                        'ZX_EXEMPTION_CTRL_FLAG_INVALID',
                                        l_exemption_ctrl_flag_invalid,
                                        trx_level_type,
                                        interface_line_entity_code,
                                        interface_line_id
                                 )
                 WHEN (ZX_PRODUCT_TYPE_INVALID = 'Y')  THEN

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
                                        interface_line_entity_code,
                                        interface_line_id
                                        )
                                VALUES(
                                        application_id,
                                        entity_code,
                                        event_class_code,
                                        trx_id,
                                        trx_line_id,
                                        NULL,
                                        'ZX_PRODUCT_TYPE_INVALID',
                                        l_product_type_invalid,
                                        trx_level_type,
                                        interface_line_entity_code,
                                        interface_line_id
                                 )

     WHEN (ZX_INVALID_TAX_LINES = 'Y')  THEN

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
                                          interface_line_entity_code,
                                          interface_line_id
                                          )
                                  VALUES(
                                          application_id,
                                          entity_code,
                                          event_class_code,
                                          trx_id,
                                          trx_line_id,
                                          NULL,
                                          'ZX_INVALID_TAX_LINES',
                                          l_inval_tax_lines_for_ctrl_flg,
                                          trx_level_type,
                                          interface_line_entity_code,
                                          interface_line_id
                                          )


             WHEN (ZX_INVALID_LINE_TAX_AMT = 'Y')  THEN

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
                                          interface_line_entity_code,
                                          interface_line_id
                                          )
                                  VALUES(
                                          application_id,
                                          entity_code,
                                          event_class_code,
                                          trx_id,
                                          trx_line_id,
                                          NULL,
                                          'ZX_INVALID_LINE_TAX_AMT',
                                          l_invald_line_for_ctrl_tot_amt,
                                          trx_level_type,
                                          interface_line_entity_code,
                                          interface_line_id
                                          )

             WHEN (ZX_INVALID_TAX_FOR_ALLOC_FLG = 'Y')  THEN

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
                                          interface_line_entity_code,
                                          interface_line_id
                                          )
                                  VALUES(
                                          application_id,
                                          entity_code,
                                          event_class_code,
                                          trx_id,
                                          trx_line_id,
                                          NULL,
                                          'ZX_INVALID_TAX_FOR_ALLOC_FLG',
                                          l_inval_tax_line_for_alloc_flg,
                                          trx_level_type,
                                          interface_line_entity_code,
                                          interface_line_id
                                          )
             WHEN (ZX_INVALID_TAX_ONLY_TAX_LINES = 'Y')  THEN

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
                                          interface_line_entity_code,
                                          interface_line_id
                                          )
                                  VALUES(
                                          application_id,
                                          entity_code,
                                          event_class_code,
                                          trx_id,
                                          trx_line_id,
                                          NULL,
                                          'ZX_INVALID_TAX_ONLY_TAX_LINES',
                                          l_invalid_tax_only_tax_lines,
                                          trx_level_type,
                                          interface_line_entity_code,
                                          interface_line_id
                                          )
              WHEN (TAX_RATE_NOT_EXISTS = 'Y')  THEN

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
                                          interface_line_entity_code,
                                          interface_line_id
                                          )
                                   VALUES(
                                          application_id,
                                          entity_code,
                                          event_class_code,
                                          trx_id,
                                          trx_line_id,
                                          NULL,
                                          'ZX_TAX_RATE_NOT_EXIST', --4703541
                                          l_tax_rate_not_exists,
                                          trx_level_type,
                                          interface_line_entity_code,
                                          interface_line_id
                                          )
             --Commented for Bug#7504455--
             /*WHEN (NVL(TAX_RATE_NOT_EXISTS,'N') <> 'Y' AND TAX_RECOV_OR_OFFSET = 'Y')  THEN
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
                                          interface_line_entity_code,
                                          interface_line_id
                                          )
                                   VALUES(
                                          application_id,
                                          entity_code,
                                          event_class_code,
                                          trx_id,
                                          trx_line_id,
                                          NULL,
                                          'ZX_TAX_RECOV_OR_OFFSET',
                                          l_tax_recov_or_offset,
                                          trx_level_type,
                                          interface_line_entity_code,
                                          interface_line_id
                                 )*/
              WHEN (NVL(TAX_RATE_NOT_EXISTS,'N') <> 'Y' AND TAX_RATE_CODE_NOT_EFFECTIVE = 'Y')  THEN

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
                                          interface_line_entity_code,
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
                                          interface_line_entity_code,
                                          interface_line_id
                                )
             WHEN (NVL(TAX_RATE_NOT_EXISTS,'N') <> 'Y' AND TAX_RATE_CODE_NOT_ACTIVE = 'Y')  THEN

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
                                          interface_line_entity_code,
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
                                          interface_line_entity_code,
                                          interface_line_id
                                 )
                SELECT
                header.application_id,
                header.entity_code,
                header.event_class_code,
                header.trx_id,
                lines_gt.trx_line_id,
                lines_gt.trx_line_id          interface_line_id  ,
                lines_gt.entity_code        interface_line_entity_code,
                lines_gt.trx_level_type,
                -- Check for existence of at least one location at line
                CASE WHEN (lines_gt.ship_from_location_id is not null OR
                           lines_gt.ship_to_location_id is not NULL OR
                           lines_gt.poa_location_id is not NULL OR
                           lines_gt.poo_location_id is not NULL OR
                           lines_gt.paying_location_id is not NULL OR
                           lines_gt.own_hq_location_id is not NULL OR
                           lines_gt.trading_hq_location_id is not NULL OR
                           lines_gt.poc_location_id is not NULL OR
                           lines_gt.poi_location_id is not NULL OR
                           lines_gt.pod_location_id is not NULL OR
                           lines_gt.bill_to_location_id is not NULL OR
                           lines_gt.bill_from_location_id is not NULL OR
                           lines_gt.title_transfer_location_id is not NULL)
                      THEN NULL
                      ELSE 'Y'
                  END ZX_LOCATION_MISSING,

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
                                                         'MISC','MISCELLANEOUS'))
                     THEN 'Y'
                     ELSE NULL
                END  ZX_TRX_LINE_TYPE_INVALID,

                -- Check for Validity of Line amount includes tax flag
                CASE WHEN (lines_gt.line_amt_includes_tax_flag IS NULL OR
                           lines_gt.line_amt_includes_tax_flag NOT IN ('A','N','S'))
                     THEN 'Y'
                     ELSE  NULL
                END  ZX_LINE_AMT_INCL_TAX_INVALID,

                -- Check Product Category exists
                nvl2(lines_gt.product_category,
                     CASE WHEN (NOT EXISTS
		                (SELECT 1
				 FROM ZX_FC_PRODUCT_CATEGORIES_V
				 WHERE classification_code = lines_gt.product_category
				 AND (country_code IS NULL
				      OR country_code = header.default_taxation_country)))
		          THEN 'Y'
			  ELSE NULL
                     END,
		     NULL
                     ) PRODUCT_CATEG_NOT_EXISTS,

             -- Check for Product Category Effectivity
       --Bug 4703541
       CASE WHEN lines_gt.product_category IS NOT NULL AND
               (EXISTS
		(SELECT 1
		 FROM ZX_FC_PRODUCT_CATEGORIES_V
		 WHERE classification_code = lines_gt.product_category
		 AND (country_code IS NULL
		      OR country_code = header.default_taxation_country))) THEN
         CASE WHEN
	      (NOT EXISTS
		 (SELECT 1
		  FROM ZX_FC_PRODUCT_CATEGORIES_V
		  WHERE classification_code = lines_gt.product_category
		  AND (country_code IS NULL
		       OR country_code = header.default_taxation_country)
		  AND nvl(lines_gt.trx_line_date, header.trx_date) BETWEEN
		      effective_from AND nvl(effective_to, nvl(lines_gt.trx_line_date, header.trx_date))))
         THEN 'Y'
         ELSE NULL END
       ELSE NULL END PRODUCT_CATEG_NOT_EFFECTIVE,

       -- Check for Country Consistency
       CASE WHEN lines_gt.product_category IS NOT NULL AND
                 (EXISTS
	          (SELECT 1
	           FROM ZX_FC_PRODUCT_CATEGORIES_V
	           WHERE classification_code = lines_gt.product_category
		   AND country_code IS NOT NULL)) THEN
                    CASE WHEN
	                 (NOT EXISTS
		           (SELECT 1
		            FROM ZX_FC_PRODUCT_CATEGORIES_V
		            WHERE classification_code = lines_gt.product_category
			    AND country_code IS NOT NULL
		            AND country_code = header.default_taxation_country))
                    THEN 'Y'
		    ELSE NULL END
       ELSE NULL END PRODUCT_CATEG_COUNTRY_INCONSIS,

       -- Check for user defined code exists
       nvl2(lines_gt.user_defined_fisc_class,
            CASE WHEN (NOT EXISTS
		        (SELECT 1
			 FROM ZX_FC_USER_DEFINED_V
			 WHERE classification_code = lines_gt.user_defined_fisc_class
			 AND (country_code IS NULL
 			      OR country_code = header.default_taxation_country)))
	          THEN 'Y'
		  ELSE NULL END,
	     NULL) USER_DEF_FC_CODE_NOT_EXISTS,

       -- Check for user defined code Effectivity
       CASE WHEN lines_gt.user_defined_fisc_class IS NOT NULL AND
               (EXISTS
		(SELECT 1
		 FROM ZX_FC_USER_DEFINED_V
		 WHERE classification_code = lines_gt.user_defined_fisc_class
		 AND (country_code IS NULL
		      OR country_code = header.default_taxation_country))) THEN
         CASE WHEN
	      (NOT EXISTS
		 (SELECT 1
		  FROM ZX_FC_USER_DEFINED_V
		  WHERE classification_code = lines_gt.user_defined_fisc_class
		  AND (country_code IS NULL
		       OR country_code = header.default_taxation_country)
		  AND nvl(lines_gt.trx_line_date, header.trx_date) BETWEEN
		     effective_from AND nvl(effective_to, nvl(lines_gt.trx_line_date, header.trx_date))))
         THEN 'Y'
         ELSE NULL END
       ELSE NULL END USER_DEF_FC_CODE_NOT_EFFECTIVE,

                -- Check for user defined code Country Consistency
                CASE WHEN lines_gt.user_defined_fisc_class IS NOT NULL AND
                 (EXISTS
	          (SELECT 1
	           FROM ZX_FC_USER_DEFINED_V
	           WHERE classification_code = lines_gt.user_defined_fisc_class
		   AND country_code IS NOT NULL)) THEN
                    CASE WHEN
	                 (NOT EXISTS
		           (SELECT 1
		            FROM ZX_FC_USER_DEFINED_V
		            WHERE classification_code = lines_gt.user_defined_fisc_class
			    AND country_code IS NOT NULL
		            AND country_code = header.default_taxation_country))
                    THEN 'Y'
		    ELSE NULL END
                ELSE NULL END USER_DEF_COUNTRY_INCONSIS,

                -- Check for document subtype code Effectivity and enter only one error for trx.
    --Bug 4703541
       CASE WHEN header.document_sub_type is not null and
        fc_doc.classification_code is not null
         THEN --Bug 5018766
           CASE WHEN ( lines_gt.tax_date
                        NOT BETWEEN
           fc_doc.effective_from AND
           nvl(fc_doc.effective_to, lines_gt.tax_date)
           AND
           (NOT EXISTS
              (SELECT 1 FROM ZX_TRANSACTION_LINES_GT
              WHERE application_id = lines_gt.application_id
              AND   entity_code = lines_gt.entity_code
              AND   event_class_code = lines_gt.event_class_code
              AND   trx_id = lines_gt.trx_id
              AND   trx_line_id < lines_gt.trx_line_id
              AND   trx_level_type = lines_gt.trx_level_type)))
          THEN 'Y'
          ELSE NULL END
         ELSE NULL END DOC_FC_CODE_NOT_EFFECTIVE,

                -- Check for Transaction Business Category fc code exists
                nvl2(lines_gt.trx_business_category,
                  CASE WHEN (NOT EXISTS
		             (SELECT 1
		              FROM ZX_FC_BUSINESS_CATEGORIES_V
			      WHERE classification_code = lines_gt.trx_business_category
			      AND (application_id IS NULL
			           OR (application_id = lines_gt.application_id
			               AND (entity_code IS NULL
				            OR (entity_code = lines_gt.entity_code
			                        AND (event_class_code IS NULL
						    OR event_class_code = lines_gt.event_class_code)))))
			      AND (country_code IS NULL
			           OR country_code = header.default_taxation_country)))
		          THEN 'Y'
			  ELSE NULL
                     END,
		     NULL
                     ) TRX_BIZ_FC_CODE_NOT_EXISTS,

                -- Check for Transaction Business Category fc code Effectivity
    --Bug 4703541
    CASE WHEN lines_gt.trx_business_category IS NOT NULL AND
               (EXISTS
		(SELECT 1
		 FROM ZX_FC_BUSINESS_CATEGORIES_V
		 WHERE classification_code = lines_gt.trx_business_category
		 AND (application_id IS NULL
			           OR (application_id = lines_gt.application_id
			               AND (entity_code IS NULL
				            OR (entity_code = lines_gt.entity_code
			                        AND (event_class_code IS NULL
						    OR event_class_code = lines_gt.event_class_code)))))
		 AND (country_code IS NOT NULL
		      OR country_code = header.default_taxation_country))) THEN
         CASE WHEN
	      (NOT EXISTS
		 (SELECT 1
		  FROM ZX_FC_BUSINESS_CATEGORIES_V
		  WHERE classification_code = lines_gt.trx_business_category
		  AND (application_id IS NULL
			           OR (application_id = lines_gt.application_id
			               AND (entity_code IS NULL
				            OR (entity_code = lines_gt.entity_code
			                        AND (event_class_code IS NULL
						    OR event_class_code = lines_gt.event_class_code)))))
		  AND (country_code IS NOT NULL
		       OR country_code = header.default_taxation_country)
		  AND nvl(lines_gt.trx_line_date, header.trx_date) BETWEEN
		     effective_from AND nvl(effective_to, nvl(lines_gt.trx_line_date, header.trx_date))))
         THEN 'Y'
         ELSE NULL END
       ELSE NULL END TRX_BIZ_FC_CODE_NOT_EFFECTIVE,

                -- Check for Transaction Business Category code Country Consistency
                CASE WHEN lines_gt.trx_business_category IS NOT NULL AND
                 (EXISTS
	          (SELECT 1
	           FROM ZX_FC_BUSINESS_CATEGORIES_V
	           WHERE classification_code = lines_gt.trx_business_category
		   AND (application_id IS NULL
			           OR (application_id = lines_gt.application_id
			               AND (entity_code IS NULL
				            OR (entity_code = lines_gt.entity_code
			                        AND (event_class_code IS NULL
						    OR event_class_code = lines_gt.event_class_code)))))
		   AND country_code IS NOT NULL)) THEN
                    CASE WHEN
	                 (NOT EXISTS
		           (SELECT 1
		            FROM ZX_FC_BUSINESS_CATEGORIES_V
		            WHERE classification_code = lines_gt.trx_business_category
			    AND (application_id IS NULL
			           OR (application_id = lines_gt.application_id
			               AND (entity_code IS NULL
				            OR (entity_code = lines_gt.entity_code
			                        AND (event_class_code IS NULL
						    OR event_class_code = lines_gt.event_class_code)))))
			    AND country_code IS NOT NULL
		            AND country_code = header.default_taxation_country))
                    THEN 'Y'
		    ELSE NULL END
               ELSE NULL END TRX_BIZ_FC_COUNTRY_INCONSIS,

                -- Check for Intended Use - eTax model FC code exists
    --Bug 4703541
           nvl2(lines_gt.line_intended_use,
            CASE WHEN (NOT EXISTS
		        (SELECT 1
			 FROM ZX_FC_INTENDED_USE_V
			 WHERE classification_code = lines_gt.line_intended_use
   		 AND (country_code IS NULL
 			      OR country_code = header.default_taxation_country)))
	          THEN 'Y'
		  ELSE NULL END,
	     NULL) INTENDED_USE_CODE_NOT_EXISTS,

                -- Check for Intended Use - eTax model FC code Effectivity
    --Bug 4703541
           CASE WHEN lines_gt.line_intended_use IS NOT NULL AND
               (EXISTS
		(SELECT 1
		 FROM ZX_FC_INTENDED_USE_V
		 WHERE classification_code = lines_gt.line_intended_use
		 AND (country_code IS NULL
		      OR country_code = header.default_taxation_country))) THEN
         CASE WHEN
	      (NOT EXISTS
		 (SELECT 1
		  FROM ZX_FC_INTENDED_USE_V
		  WHERE classification_code = lines_gt.line_intended_use
		  AND (country_code IS NULL
		       OR country_code = header.default_taxation_country)
		  AND nvl(lines_gt.trx_line_date, header.trx_date) BETWEEN
		     effective_from AND nvl(effective_to, nvl(lines_gt.trx_line_date, header.trx_date))))
         THEN 'Y'
         ELSE NULL END
       ELSE NULL END INTENDED_USE_NOT_EFFECTIVE,

             -- Check for Intended Use - eTax modelFC code Country Consistency
                CASE WHEN lines_gt.line_intended_use IS NOT NULL AND
                 (EXISTS
	          (SELECT 1
	           FROM ZX_FC_INTENDED_USE_V
	           WHERE classification_code = lines_gt.line_intended_use
		   AND country_code IS NOT NULL)) THEN
                    CASE WHEN
	                 (NOT EXISTS
		           (SELECT 1
		            FROM ZX_FC_INTENDED_USE_V
		            WHERE classification_code = lines_gt.line_intended_use
			    AND country_code IS NOT NULL
		            AND country_code = header.default_taxation_country))
                    THEN 'Y'
		    ELSE NULL END
                ELSE NULL END INTENDED_USE_CONTRY_INCONSIS,

                -- Check for product type
                -- Bug # 3438264
                nvl2(lines_gt.product_type,
                     nvl(fnd.lookup_code,'Y'),
                     NULL
                    ) PRODUCT_TYPE_CODE_NOT_EXISTS,

                -- Check for product type code Effectivity
                CASE WHEN (fnd.lookup_code is not null)
                     THEN  CASE WHEN ( lines_gt.tax_date --Bug 5018766
                                   BETWEEN fnd.start_date_active AND
                                        nvl(fnd.end_date_active,
                                            lines_gt.tax_date )
             )
                           THEN NULL
                           ELSE 'Y' END
                     ELSE NULL
                END PRODUCT_TYPE_NOT_EFFECTIVE,

                -- Check for product fiscal classification
                nvl2(lines_gt.product_fisc_classification,
                   CASE WHEN (NOT EXISTS
		        (SELECT 1
			 FROM ZX_FC_PRODUCT_FISCAL_V
			 WHERE classification_code = lines_gt.product_fisc_classification
			 AND (country_code IS NULL
 			      OR country_code = header.default_taxation_country)))
	          THEN 'Y'
		  ELSE NULL END,
	     NULL) PRODUCT_FC_CODE_NOT_EXISTS,

                   -- Check for SHIP_TO_PARTY_ID
/*
                nvl2(lines_gt.SHIP_TO_PARTY_ID,
                     CASE WHEN (NOT EXISTS
                                (SELECT 1 FROM zx_party_tax_profile
                                 WHERE party_id =
                                       lines_gt.SHIP_TO_PARTY_ID
                                 AND  party_type_code = 'THIRD_PARTY'))
                           THEN 'Y'
                           ELSE NULL END,
                      NULL) SHIP_TO_PARTY_NOT_EXISTS,

                   -- Check for SHIP_FROM_PARTY_ID
                nvl2(lines_gt.SHIP_FROM_PARTY_ID,
                     CASE WHEN (NOT EXISTS
                                (SELECT 1 FROM zx_party_tax_profile
                                 WHERE party_id =
                                       lines_gt.SHIP_FROM_PARTY_ID
                                 AND  party_type_code = 'THIRD_PARTY'))
                           THEN 'Y'
                           ELSE NULL END,
                      NULL) SHIP_FROM_PARTY_NOT_EXISTS,

                   -- Check for BILL_TO_PARTY_ID
                nvl2(lines_gt.BILL_TO_PARTY_ID,
                     CASE WHEN (NOT EXISTS
                                (SELECT 1 FROM zx_party_tax_profile
                                 WHERE party_id =
                                       lines_gt.BILL_TO_PARTY_ID
                                 AND  party_type_code = 'THIRD_PARTY'))
                           THEN 'Y'
                           ELSE NULL END,
                      NULL) BILL_TO_PARTY_NOT_EXISTS,

            -- Check for BILL_FROM_PARTY_ID
                nvl2(lines_gt.BILL_FROM_PARTY_ID,
                     CASE WHEN (NOT EXISTS
                                (SELECT 1 FROM zx_party_tax_profile
                                 WHERE party_id =
                                       lines_gt.BILL_FROM_PARTY_ID
                                 AND  party_type_code = 'THIRD_PARTY'))
                           THEN 'Y'
                           ELSE NULL END,
                      NULL) BILL_FROM_PARTY_NOT_EXISTS,

            -- Check for SHIP_TO_PARTY_SITE_ID
                nvl2(lines_gt.SHIP_TO_PARTY_SITE_ID,
                     CASE WHEN (NOT EXISTS
                                (SELECT 1 FROM zx_party_tax_profile
                                 WHERE party_id =
                                       lines_gt.SHIP_TO_PARTY_SITE_ID
                                 AND  party_type_code = 'THIRD_PARTY_SITE'))
                           THEN 'Y'
                           ELSE NULL END,
                      NULL) SHIPTO_PARTY_SITE_NOT_EXISTS,

            -- Check for SHIP_FROM_PARTY_SITE_ID
                nvl2(lines_gt.SHIP_FROM_PARTY_SITE_ID,
                     CASE WHEN (NOT EXISTS
                                (SELECT 1 FROM zx_party_tax_profile
                                 WHERE party_id =
                                       lines_gt.SHIP_FROM_PARTY_SITE_ID
                                 AND  party_type_code = 'THIRD_PARTY_SITE'))
                           THEN 'Y'
                           ELSE NULL END,
                      NULL) SHIPFROM_PARTY_SITE_NOT_EXISTS,

             -- Check for BILL_TO_PARTY_SITE_ID
                nvl2(lines_gt.BILL_TO_PARTY_SITE_ID,
                     CASE WHEN (NOT EXISTS
                                (SELECT 1 FROM zx_party_tax_profile
                                 WHERE party_id =
                                       lines_gt.BILL_TO_PARTY_SITE_ID
                                 AND  party_type_code = 'THIRD_PARTY_SITE'))
                           THEN 'Y'
                           ELSE NULL END,
                      NULL) BILLTO_PARTY_SITE_NOT_EXISTS,

             -- Check for BILL_FROM_PARTY_SITE_ID
                nvl2(lines_gt.BILL_FROM_PARTY_SITE_ID,
                     CASE WHEN (NOT EXISTS
                                (SELECT 1 FROM zx_party_tax_profile
                                 WHERE party_id =
                                       lines_gt.BILL_FROM_PARTY_SITE_ID
                                 AND  party_type_code = 'THIRD_PARTY_SITE'))
                           THEN 'Y'
                           ELSE NULL END,
                      NULL) BILLFROM_PARTY_SITE_NOT_EXISTS,
*/

                -- If the header level control total flag is 'Y', then
                -- there should not be any control amount passed at line level
                -- removing the validation to sync the behavior with manual transactions
                -- bug 6915776
                /*CASE WHEN (lines_gt.CTRL_HDR_TX_APPL_FLAG ='Y' AND
                           lines_gt.CTRL_TOTAL_LINE_TX_AMT IS NOT NULL )
                     THEN 'Y'
                     ELSE NULL
                END  ZX_LINE_CTRL_AMT_INVALID,*/

    -- Control total amount should be NULL if line_level_action is NOT 'CREATE'
                -- bug 6915776
                CASE WHEN (lines_gt.line_level_action <> 'CREATE' AND
                           lines_gt.CTRL_TOTAL_LINE_TX_AMT IS NOT NULL )
                     THEN 'Y'
                     ELSE NULL
                END  ZX_LINE_CTRL_AMT_NOT_NULL,

                -- If tax_variance_calc_flag in ZX_EVNT_CLS_MAPPINGS is set to 'Y',
                -- then unit price and trx line quantity are required
          -- bugfix 4919842:
                -- unit price and trx line quantity are only required for non-amount based
                -- PO/receipt matched invoices

/*                CASE WHEN (evntmap.tax_variance_calc_flag = 'Y'
                     and lines_gt.unit_price is null
                     and lines_gt.ref_doc_application_id IS NOT NULL
                     and lines_gt.line_class <> 'AMOUNT_MATCHED')
                     THEN  'Y'
                     ELSE  NULL
                END ZX_UNIT_PRICE_MISSING,

                CASE WHEN (evntmap.tax_variance_calc_flag = 'Y'
                     and lines_gt.trx_line_quantity is null
                     and lines_gt.ref_doc_application_id IS NOT NULL
                     and lines_gt.line_class <> 'AMOUNT_MATCHED')
                     THEN  'Y'
                     ELSE  NULL
                END ZX_LINE_QUANTITY_MISSING,
*/
                -- end Bug # 4563490

    CASE WHEN (lines_gt.exemption_control_flag IS NOT NULL AND
         lines_gt.exemption_control_flag NOT IN ('R','S','E'))
         THEN 'Y'
         ELSE  NULL
    END  ZX_EXEMPTION_CTRL_FLAG_INVALID,

    CASE WHEN (lines_gt.product_type IS NOT NULL AND
         lines_gt.product_type NOT IN ('GOODS','SERVICES'))
         THEN 'Y'
         ELSE  NULL
    END  ZX_PRODUCT_TYPE_INVALID,

                -- If the header level control total flag is 'Y', then there should not be any tax lines passed for
                -- that transaction except the tax-only tax lines
                CASE WHEN (lines_gt.ctrl_hdr_tx_appl_flag = 'Y' AND
                           lines_gt.line_level_action <> 'LINE_INFO_TAX_ONLY' AND
                           EXISTS (SELECT 1
                                     FROM zx_import_tax_lines_gt imptaxes_gt
                                    WHERE application_id = lines_gt.application_id
                                      AND entity_code = lines_gt.entity_code
                                      AND event_class_code = lines_gt.event_class_code
                                      AND trx_id = lines_gt.trx_id
                                      AND trx_line_id = lines_gt.trx_line_id)
                           )
                     THEN 'Y'
                     ELSE  NULL
                END ZX_INVALID_TAX_LINES,

                -- If control total amount at line level is passed,
                -- then no tax lines should be allocated to that line

                CASE WHEN (lines_gt.CTRL_TOTAL_LINE_TX_AMT IS NOT NULL AND
                      EXISTS (SELECT 1
                                from zx_trx_tax_link_gt
                               WHERE application_id = lines_gt.application_id
                                 AND entity_code = lines_gt.entity_code
                                 AND event_class_code = lines_gt.event_class_code
                                 AND trx_id = lines_gt.trx_id
                                 AND trx_line_id = lines_gt.trx_line_id
                                 AND trx_level_type = lines_gt.trx_level_type) )
               THEN 'Y'
               ELSE  NULL
                 END ZX_INVALID_LINE_TAX_AMT,

                -- If control total amount at line level is passed, then there should not exist a tax line
                -- that is allocated to all transaction lines (i.e. tax line with allocation flag as 'N').

                CASE WHEN (lines_gt.ctrl_total_line_tx_amt IS NOT NULL AND
                           exists(select 1
                                    from zx_import_tax_lines_gt imptaxes_gt
                                   where application_id = lines_gt.application_id
                                     AND entity_code = lines_gt.entity_code
                                     AND event_class_code = lines_gt.event_class_code
                                     AND trx_id = lines_gt.trx_id
                                     AND trx_line_id is null
                                     and imptaxes_gt.tax_line_allocation_flag = 'N') )
                     THEN 'Y'
                     ELSE  NULL
                END ZX_INVALID_TAX_FOR_ALLOC_FLG,

                -- Tax-only Tax Lines should always have the tax line allocation flag as Y

                CASE WHEN (lines_gt.line_level_action = 'LINE_INFO_TAX_ONLY' AND
               EXISTS (SELECT 1
                   FROM zx_import_tax_lines_gt imptaxes_gt
                  WHERE application_id = lines_gt.application_id
                    AND entity_code = lines_gt.entity_code
                    AND event_class_code = lines_gt.event_class_code
                    AND trx_id = lines_gt.trx_id
                    AND trx_line_id = lines_gt.trx_line_id
                    AND imptaxes_gt.tax_line_allocation_flag <> 'Y')
                           )
         THEN 'Y'
         ELSE  NULL
                END ZX_INVALID_TAX_ONLY_TAX_LINES,

            /* CASE WHEN ((lines_gt.output_tax_classification_code IS NOT NULL OR
                           lines_gt.input_tax_classification_code IS NOT NULL)
                         --Changed for Bug#7504455--
                           AND NOT EXISTS (SELECT 1
                                             FROM zx_rates_b rates,
                                                  zx_subscription_details zxsd
                                            WHERE rates.tax_rate_code = NVL(lines_gt.output_tax_classification_code,
                                                                            lines_gt.input_tax_classification_code)
                                              AND rates.tax_regime_code = zxsd.tax_regime_code
                                              AND rates.content_owner_id = zxsd.first_pty_org_id
                                              AND rates.rate_type_code <> 'RECOVERY'))
               THEN 'Y'
               ELSE NULL
             END TAX_RATE_NOT_EXISTS,

             --Commented for Bug#7504455--
             /*CASE WHEN /*(lines_gt.output_tax_classification_code IS NOT NULL OR
                          lines_gt.input_tax_classification_code IS NOT NULL)
                          AND (EXISTS (SELECT 1 FROM ZX_TAXES_B
                               WHERE TAX_TYPE_CODE = 'OFFSET'
                               AND tax IN (SELECT tax FROM ZX_RATES_B
                                           WHERE tax_rate_code = NVL(lines_gt.output_tax_classification_code,
                                                                    lines_gt.input_tax_classification_code)))
                          OR
                          rates.rate_type_code = 'RECOVERY'
             --)
             --)
                  THEN 'Y'
             ELSE NULL END TAX_RECOV_OR_OFFSET,

             CASE WHEN ((lines_gt.output_tax_classification_code IS NOT NULL OR
                         lines_gt.input_tax_classification_code IS NOT NULL) AND
                         --Changed for Bug#7504455--
                         NOT EXISTS (SELECT 1
                                       FROM zx_rates_b rates,
                                            zx_subscription_details zxsd
                                      WHERE rates.tax_rate_code = NVL(lines_gt.output_tax_classification_code,
                                                                      lines_gt.input_tax_classification_code)
                                        AND rates.tax_regime_code = zxsd.tax_regime_code
                                        AND rates.content_owner_id = zxsd.first_pty_org_id
                                        AND rates.rate_type_code <> 'RECOVERY'
                                        AND lines_gt.tax_date BETWEEN rates.effective_from AND
                                                    NVL(rates.effective_to,lines_gt.tax_date)))
                  THEN 'Y'
             ELSE NULL END TAX_RATE_CODE_NOT_EFFECTIVE,

             -- Check Rate Code is Active
             CASE WHEN ((lines_gt.output_tax_classification_code IS NOT NULL OR
                         lines_gt.input_tax_classification_code IS NOT NULL) AND
                         --Changed for Bug#7504455--
                         NOT EXISTS (SELECT 1
                                       FROM zx_rates_b rates,
                                            zx_subscription_details zxsd
                                      WHERE rates.tax_rate_code = NVL(lines_gt.output_tax_classification_code,
                                                                      lines_gt.input_tax_classification_code)
                                        AND rates.tax_regime_code = zxsd.tax_regime_code
                                        AND rates.content_owner_id = zxsd.first_pty_org_id
                                        AND rates.rate_type_code <> 'RECOVERY'
                                        AND rates.active_flag = 'Y'))
                  THEN 'Y'
             ELSE NULL END TAX_RATE_CODE_NOT_ACTIVE*/
--taniya
             CASE WHEN lines_gt.output_tax_classification_code IS NOT NULL
                        AND NOT EXISTS (SELECT 1
                                        FROM zx_output_classifications_v
                                        WHERE lookup_code = lines_gt.output_tax_classification_code
                                        AND org_id in (header.internal_organization_id, -99))
                        THEN 'Y'
                        ELSE
                           CASE WHEN lines_gt.input_tax_classification_code IS NOT NULL
                                     AND NOT EXISTS (SELECT 1
                                                     FROM zx_input_classifications_v
                                                     WHERE lookup_code = lines_gt.input_tax_classification_code
                                                     AND org_id in (header.internal_organization_id, -99))
                          THEN 'Y'
                          ELSE NULL END
             END TAX_RATE_NOT_EXISTS,

             CASE WHEN lines_gt.output_tax_classification_code IS NOT NULL
                       AND NOT EXISTS (SELECT 1
                                        FROM zx_output_classifications_v
                                        WHERE lookup_code = lines_gt.output_tax_classification_code
                                        AND org_id in (header.internal_organization_id, -99)
                                        AND lines_gt.tax_date BETWEEN start_date_active
                                            AND nvl(end_date_active,lines_gt.tax_date))
                       THEN 'Y'
                       ELSE
                         CASE WHEN lines_gt.input_tax_classification_code IS NOT NULL
                                   AND NOT EXISTS (SELECT 1
                                                     FROM zx_input_classifications_v
                                                     WHERE lookup_code = lines_gt.input_tax_classification_code
                                                     AND org_id in (header.internal_organization_id, -99)
                                                     AND lines_gt.tax_date BETWEEN start_date_active
                                                         AND nvl(end_date_active,lines_gt.tax_date))
                          THEN 'Y'
                          ELSE NULL END
             END TAX_RATE_CODE_NOT_EFFECTIVE,

             -- Check Rate Code is Active
             CASE WHEN lines_gt.output_tax_classification_code IS NOT NULL
                       AND NOT EXISTS (SELECT 1
                                        FROM zx_output_classifications_v
                                        WHERE lookup_code = lines_gt.output_tax_classification_code
                                        AND org_id in (header.internal_organization_id, -99)
                                        AND enabled_flag = 'Y')
                       THEN 'Y'
                       ELSE
                         CASE WHEN lines_gt.input_tax_classification_code IS NOT NULL
                                   AND NOT EXISTS (SELECT 1
                                                     FROM zx_input_classifications_v
                                                     WHERE lookup_code = lines_gt.input_tax_classification_code
                                                     AND org_id in (header.internal_organization_id, -99)
                                                     AND enabled_flag = 'Y')
                          THEN 'Y'
                          ELSE NULL END
             END TAX_RATE_CODE_NOT_ACTIVE
  FROM
    ZX_TRX_HEADERS_GT             header,
    ZX_EVNT_CLS_MAPPINGS          evntmap,
    ZX_TRANSACTION_LINES_GT       lines_gt,
    --ZX_FC_PRODUCT_CATEGORIES_V    fc_prodcat,
    --ZX_FC_CODES_B                 fc_user,
    ZX_FC_DOCUMENT_FISCAL_V       fc_doc,
    --ZX_FC_BUSINESS_CATEGORIES_V   fc_trx,
    --ZX_FC_CODES_B                 fc_int,
    FND_LOOKUPS                   fnd--,
    --ZX_FC_PRODUCT_FISCAL_V        fc_product
    --ZX_RATES_B                  rates       --Commented for Bug#7504455--
  WHERE
    lines_gt.trx_id = header.trx_id
    and lines_gt.application_id = header.application_id
    and lines_gt.entity_code = header.entity_code
    and lines_gt.event_class_code = header.event_class_code
    --and fc_product.classification_code(+) =    lines_gt.product_fisc_classification
    --AND fc_product.country_code(+)        =    header.default_taxation_country
    --and fc_prodcat.classification_code(+) =    lines_gt.product_category
    --and fc_user.classification_type_code(+) =  'USER_DEFINED'
    --and fc_user.classification_code(+) =       lines_gt.user_defined_fisc_class
    and fc_doc.classification_code(+) =        header.document_sub_type
    and fc_doc.country_code(+)        =        header.default_taxation_country
    --and fc_trx.classification_code(+) =        lines_gt.trx_business_category
    --and fc_trx.application_id(+)      =        lines_gt.application_id
    --and fc_trx.entity_code(+)         =        lines_gt.entity_code
    --and fc_trx.event_class_code(+)    =        lines_gt.event_class_code
    --and fc_int.classification_type_code(+) =   'INTENDED_USE'
    --and fc_int.classification_code(+)      =   lines_gt.line_intended_use
    and header.application_id    =       evntmap.application_id (+)
    and header.entity_code       =             evntmap.entity_code (+)
    and header.event_class_code  =             evntmap.event_class_code(+)
    and fnd.lookup_type(+)    =      'ZX_PRODUCT_TYPE'
    and fnd.lookup_code(+) =                   lines_gt.product_type;
    --Commented for Bug#7504455--
    --and rates.tax_rate_code(+) = NVL(lines_gt.output_tax_classification_code,
    --                                 lines_gt.input_tax_classification_code);

        -- Bug 4902521 : Added Message to check no. of rows inserted .
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF ( g_level_statement >= g_current_runtime_level) THEN
    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'No. of Rows inserted for Line Related Validations : '|| to_char(sql%ROWCOUNT) );
  END IF;

/******************** End of Logic for Header/Line Validations *************************/

        -- Validations for Imported tax Lines.
        g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    IF ( g_level_event >= g_current_runtime_level) THEN
      FND_LOG.STRING(g_level_event,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
      'Validations for Imported tax Lines.');
    END IF;

  -- Select the key columns and write into fnd log for debug purpose
  IF ( g_level_statement >= g_current_runtime_level) THEN
    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
      'Before opening the cursor - get_import_tax_line_info_csr');

    OPEN get_import_tax_line_info_csr;

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
      'After opening the cursor - get_import_tax_line_info_csr');

    LOOP
      FETCH get_import_tax_line_info_csr BULK COLLECT INTO
      l_application_id_tbl,
      l_entity_code_tbl,
      l_event_class_code_tbl,
      l_trx_id_tbl,
      l_trx_line_id_tbl,
      l_trx_level_type_tbl,
      l_summary_tax_line_number_tbl

        LIMIT C_LINES_PER_COMMIT;

--        EXIT WHEN get_import_tax_line_info_csr%notfound;

      l_count := nvl(l_trx_line_id_tbl.COUNT,0);

    FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
             'number of rows fetched = ' || to_char(l_count));

      IF l_count > 0 THEN

        FOR i IN 1.. l_count LOOP

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'Row Number = ' || to_char(i) );

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'l_application_id = ' || to_char(l_application_id_tbl(i)) );

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'l_entity_code = ' || l_entity_code_tbl(i) );

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'l_event_class_code = ' || l_event_class_code_tbl(i) );

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'l_trx_id = ' || to_char(l_trx_id_tbl(i)) );

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'l_trx_line_id = ' || to_char(l_trx_line_id_tbl(i)) );

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'l_trx_level_type = ' || l_trx_level_type_tbl(i) );

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'l_summary_tax_line_number = ' || to_char(l_summary_tax_line_number_tbl(i)) );


        END LOOP;
       ELSE
         EXIT ;

      END IF; -- end of count checking

    END LOOP;

    CLOSE get_import_tax_line_info_csr;

          -- Clear the records
    l_application_id_tbl.delete;
    l_entity_code_tbl.delete;
    l_event_class_code_tbl.delete;
    l_trx_id_tbl.delete;
    l_trx_line_id_tbl.delete;
    l_trx_level_type_tbl.delete;
    l_summary_tax_line_number_tbl.delete;

  END IF; -- End of debug checking

  IF ( g_level_statement >= g_current_runtime_level) THEN
    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'Before insertion into ZX_VALIDATION_ERRORS_GT for Imported Tax Lines Validations');
  END IF;

  IF ( g_level_statement >= g_current_runtime_level) THEN
    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'Before insertion into ZX_VALIDATION_ERRORS_GT for Regime,Tax,Status and Jurisdiction related Imported Tax Lines Validations');
  END IF;


-- Have moved the validations that are specific to an Item line to a separate query.
-- The Validations here are Tax Line related Validations only.
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
        interface_tax_entity_code,
        interface_tax_line_id
        )
      VALUES(
        application_id,
        entity_code,
        event_class_code,
        trx_id,
        NULL,
        summary_tax_line_number,
        'ZX_REGIME_NOT_EXIST',
        l_regime_not_exists,
        NULL,
        interface_tax_entity_code,
        interface_tax_line_id
         )
    WHEN (ZX_REGIME_NOT_EFF_IN_SUBSCR = 'Y') THEN

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
        interface_tax_entity_code,
        interface_tax_line_id
        )
      VALUES(
        application_id,
        entity_code,
        event_class_code,
        trx_id,
        NULL,
        summary_tax_line_number,
        'ZX_REGIME_NOT_EFF_IN_SUBSCR',
        l_regime_not_eff_in_subscrptn,
        NULL,
        interface_tax_entity_code,
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
        interface_tax_entity_code,
        interface_tax_line_id
        )
      VALUES(
        application_id,
        entity_code,
        event_class_code,
        trx_id,
        NULL,
        summary_tax_line_number,
        'ZX_REGIME_NOT_EFFECTIVE',
        l_regime_not_effective,
        NULL,
        interface_tax_entity_code,
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
          interface_tax_entity_code,
          interface_tax_line_id
          )
        VALUES(
          application_id,
          entity_code,
          event_class_code,
          trx_id,
          NULL,
          summary_tax_line_number,
          'ZX_TAX_NOT_EXIST',
          l_tax_not_exists,
          NULL,
          interface_tax_entity_code,
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
          interface_tax_entity_code,
          interface_tax_line_id
          )
        VALUES(
          application_id,
          entity_code,
          event_class_code,
          trx_id,
          NULL,
          summary_tax_line_number,
          'ZX_TAX_NOT_LIVE',
          l_tax_not_live,
          NULL,
          interface_tax_entity_code,
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
          interface_tax_entity_code,
          interface_tax_line_id
          )
        VALUES(
          application_id,
          entity_code,
          event_class_code,
          trx_id,
          NULL,
          summary_tax_line_number,
          'ZX_TAX_NOT_EFFECTIVE',
          l_tax_not_effective,
          NULL,
          interface_tax_entity_code,
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
          interface_tax_entity_code,
          interface_tax_line_id
          )
        VALUES(
          application_id,
          entity_code,
          event_class_code,
          trx_id,
          NULL,
          summary_tax_line_number,
          'ZX_TAX_STATUS_NOT_EXIST',
          l_tax_status_not_exists,
          NULL,
          interface_tax_entity_code,
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
          interface_tax_entity_code,
          interface_tax_line_id
          )
        VALUES(
          application_id,
          entity_code,
          event_class_code,
          trx_id,
          NULL,
          summary_tax_line_number,
          'ZX_TAX_STATUS_NOT_EFFECTIVE',
          l_tax_status_not_effective,
          NULL,
          interface_tax_entity_code,
          interface_tax_line_id
           )
    WHEN (JUR_CODE_NOT_EXISTS = 'Y')  THEN

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
          interface_tax_entity_code,
          interface_tax_line_id
          )
        VALUES(
          application_id,
          entity_code,
          event_class_code,
          trx_id,
          NULL,
          summary_tax_line_number,
          'ZX_JUR_CODE_NOT_EXIST',
          l_jur_code_not_exists,
          NULL,
          interface_tax_entity_code,
          interface_tax_line_id
           )

    WHEN (JUR_CODE_NOT_EFFECTIVE = 'Y')  THEN

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
          interface_tax_entity_code,
          interface_tax_line_id
          )
        VALUES(
          application_id,
          entity_code,
          event_class_code,
          trx_id,
          NULL,
          summary_tax_line_number,
          'ZX_JUR_CODE_NOT_EFFECTIVE',
          l_jur_code_not_effective,
          NULL,
          interface_tax_entity_code,
          interface_tax_line_id
           )

    WHEN (DEFAULT_STATUS_NOT_EXISTS = 'Y')  THEN

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
          interface_tax_entity_code,
          interface_tax_line_id
          )
        VALUES(
          application_id,
          entity_code,
          event_class_code,
          trx_id,
          NULL,
          summary_tax_line_number,
          'ZX_DEFAULT_STATUS_NOT_EXIST',
          l_default_status_not_exists,
          NULL,
          interface_tax_entity_code,
          interface_tax_line_id
           )

    WHEN (TAX_AMT_MISSING = 'Y') THEN

         INTO zx_validation_errors_gt(
         application_id,
         entity_code,
         event_class_code,
         trx_id,
         summary_tax_line_number,
         message_name,
         message_text,
         trx_level_type,
         interface_tax_entity_code,
         interface_tax_line_id
         )
          VALUES
        (
         application_id,
         entity_code,
         event_class_code,
         trx_id,
         summary_tax_line_number,
         'ZX_TAX_AMT_MISSING',
         l_tax_amt_missing,
         NULL,
         interface_tax_entity_code,
         interface_tax_line_id
         )

         WHEN (ZX_TAX_LINE_ALLOC_FLAG_INVALID = 'Y')  THEN

      INTO ZX_VALIDATION_ERRORS_GT(
        application_id,
        entity_code,
        event_class_code,
        trx_id,
        --trx_line_id,
        summary_tax_line_number,
        message_name,
        message_text,
        trx_level_type,
        interface_tax_entity_code,
        interface_tax_line_id
        )
      VALUES(
        application_id,
        entity_code,
        event_class_code,
        trx_id,
        --trx_line_id,
        summary_tax_line_number,
        'ZX_TAX_LINE_ALLOC_FLAG_INVALID',
        l_tax_line_alloc_flag_invalid,
        NULL,
        interface_tax_entity_code,
        interface_tax_line_id
       )
      WHEN (ZX_INVALID_TAX_ALLOC_FLAG = 'Y')  THEN

      INTO ZX_VALIDATION_ERRORS_GT(
        application_id,
        entity_code,
        event_class_code,
        trx_id,
        summary_tax_line_number,
        message_name,
        message_text,
        trx_level_type,
        interface_tax_entity_code,
        interface_tax_line_id
        )
      VALUES(
        application_id,
        entity_code,
        event_class_code,
        trx_id,
        summary_tax_line_number,
        'ZX_INVALID_TAX_ALLOC_FLAG',
        l_invalid_tax_line_alloc_flag,
        NULL,
        interface_tax_entity_code,
        interface_tax_line_id
        )
      WHEN (TAX_LN_TYP_LOC_NOT_ALLW_F_AR = 'Y' ) THEN

          INTO zx_validation_errors_gt(
         application_id,
         entity_code,
         event_class_code,
         trx_id,
         --trx_line_id,
         summary_tax_line_number,
         message_name,
         message_text,
         trx_level_type,
         interface_tax_entity_code,
         interface_tax_line_id
          )
          VALUES (
         application_id,
         entity_code,
         event_class_code,
         trx_id,
         --trx_line_id,
         summary_tax_line_number,
         'ZX_TAX_LN_TYP_LOC_N_ALLW_F_AR',
         l_tax_ln_typ_loc_not_allw_f_ar,
         --trx_level_type,
         null,
         interface_tax_entity_code,
         interface_tax_line_id
          )
      WHEN (TAX_INCL_FLAG_MISMATCH = 'Y' ) THEN

          INTO zx_validation_errors_gt(
         application_id,
         entity_code,
         event_class_code,
         trx_id,
         --trx_line_id,
         summary_tax_line_number,
         message_name,
         message_text,
         trx_level_type,
         interface_tax_entity_code,
         interface_tax_line_id
          )
          VALUES (
         application_id,
         entity_code,
         event_class_code,
         trx_id,
         --trx_line_id,
         summary_tax_line_number,
         'ZX_TAX_INCL_FLAG_MISMATCH',
         l_tax_incl_flag_mismatch,
         --trx_level_type,
         null,
         interface_tax_entity_code,
         interface_tax_line_id
        )
      WHEN (ZX_IMP_TAX_RATE_AMT_MISMATCH = 'Y') THEN

          INTO zx_validation_errors_gt(
         application_id,
         entity_code,
         event_class_code,
         trx_id,
         --trx_line_id,
         summary_tax_line_number,
         message_name,
         message_text,
         trx_level_type,
         interface_line_entity_code,
         interface_line_id,
         interface_tax_line_id
          )
          VALUES(
         application_id,
         entity_code,
         event_class_code,
         trx_id,
         --trx_line_id,
         summary_tax_line_number,
         'ZX_IMP_TAX_RATE_AMT_MISMATCH',
         l_imp_tax_rate_amt_mismatch,
         null,
         interface_line_entity_code,
         interface_line_id,
         interface_tax_line_id
         )
  SELECT /*+ leading(taxlines_gt) */ header.application_id,
      header.entity_code,
      header.event_class_code,
      header.trx_id,
      taxlines_gt.summary_tax_line_number,
      taxlines_gt.summary_tax_line_number interface_tax_line_id,
      taxlines_gt.entity_code             interface_tax_entity_code,
      --lines_gt.trx_line_id     interface_line_id,
      --lines_gt.entity_code     interface_line_entity_code,
      --lines_gt.trx_line_id,
      --lines_gt.trx_level_type,
      null     interface_line_id,
      null     interface_line_entity_code,
      null     trx_line_id,
      null     trx_level_type,

      -- Check for Regime Existence
      CASE WHEN taxlines_gt.tax_regime_code IS NOT NULL AND
          regime.tax_regime_code IS NULL
           THEN
          'Y'
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
           END ZX_REGIME_NOT_EFF_IN_SUBSCR,


      -- Check for Regime Effectivity
      CASE WHEN taxlines_gt.tax_regime_code IS NOT NULL
          AND regime.tax_regime_code IS NOT NULL
          AND sd_reg.tax_regime_code IS NOT NULL
           THEN
        CASE WHEN taxlines_gt.subscription_date
            BETWEEN regime.effective_from
                AND NVL(regime.effective_to,
                  taxlines_gt.subscription_date)
            THEN 'N'
            ELSE 'Y' END
           ELSE 'N'
           END  REGIME_NOT_EFFECTIVE,

         -- Check for Tax Existence
         nvl2(taxlines_gt.tax,
        CASE WHEN (sd_tax.tax_regime_code IS NOT NULL AND
              /*tax.tax_regime_code = regime.tax_regime_code AND*/ --Bug 4902521
              tax.tax is not null)
        THEN NULL
        ELSE 'Y' END,
        'N') TAX_NOT_EXISTS,

         -- Check for Tax Live flag
         nvl2(taxlines_gt.tax,
        CASE WHEN (sd_tax.tax_regime_code IS NOT NULL AND
             /*tax.tax_regime_code=regime.tax_regime_code AND*/ --Bug 4902521
             tax.tax is not NULL )
             THEN
           CASE WHEN tax.live_for_processing_flag = 'Y'
                THEN 'N'
                ELSE 'Y'
           END
             ELSE 'N' END,
        'N') TAX_NOT_LIVE,

      -- Check for Tax Effectivity
           nvl2(taxlines_gt.tax,
             CASE WHEN (sd_tax.tax_regime_code IS NOT NULL AND
            /*tax.tax_regime_code=regime.tax_regime_code AND*/ --Bug 4902521
            tax.tax is not null)
            THEN
              CASE WHEN taxlines_gt.tax_date --Bug 5018766
              BETWEEN tax.effective_from AND
                NVL(tax.effective_to,
              taxlines_gt.tax_date
              )
             THEN 'N'
             ELSE 'Y' END
          ELSE 'N' END ,
         'N')  TAX_NOT_EFFECTIVE,

       -- Check for Status Existence
      --Bug 4703541
      nvl2(taxlines_gt.tax_status_code,
           CASE WHEN(sd_status.tax_regime_code IS NOT NULL AND
        /*  status.tax_regime_code = regime.tax_regime_code AND
          status.tax             = tax.tax AND*/ --Bug 4902521
          status.tax_status_code is not null)
           THEN NULL
           ELSE 'Y'
           END,
           null) TAX_STATUS_NOT_EXISTS,

      -- Check for Status Effectivity
      --Bug 4703541
       CASE WHEN(taxlines_gt.tax_status_code IS NOT NULL AND
               (sd_status.tax_regime_code IS NOT NULL AND
               /*status.tax_regime_code = regime.tax_regime_code
               AND status.tax         = tax.tax AND*/ --Bug 4902521
               status.tax_status_code is not null)
          )
             THEN  CASE WHEN taxlines_gt.tax_date --Bug 5018766
            BETWEEN status.effective_from AND
              nvl(status.effective_to,
            taxlines_gt.tax_date)
              THEN 'N'
              ELSE 'Y' END
        ELSE 'N' END TAX_STATUS_NOT_EFFECTIVE,
            -- Check for Jurisdiction Code Existence
      --Bug 4703541
      nvl2(taxlines_gt.tax_jurisdiction_code,
           CASE WHEN (/*jur.tax_regime_code = regime.tax_regime_code AND
           jur.tax             = tax.tax AND*/ -- Bug 4902521
           jur.tax_jurisdiction_code is not null)
          THEN NULL
          ELSE 'Y' END,
           null) JUR_CODE_NOT_EXISTS,

      -- Check for Jurisdiction Code Effectivity
      --Bug 4703541
           CASE WHEN (taxlines_gt.tax_jurisdiction_code IS NOT NULL AND
          /*jur.tax_regime_code = regime.tax_regime_code AND
          jur.tax             = tax.tax AND*/ -- Bug 4902521
          jur.tax_jurisdiction_code is not null)
          THEN
           CASE WHEN taxlines_gt.tax_date
               BETWEEN jur.effective_from AND
                 nvl(jur.effective_to,
              taxlines_gt.tax_date
               )
          THEN 'N'
          ELSE 'Y' END
           ELSE 'N' END JUR_CODE_NOT_EFFECTIVE,

      -- Check for Default Tax Status check for partner tax lines
      CASE WHEN  (taxlines_gt.tax_provider_id is not null)
           THEN CASE WHEN
         (/*status.tax_regime_code  = regime.tax_regime_code AND
          status.tax              = tax.tax AND*/ --Bug 4902521
          status.tax_status_code is not null AND
          status.default_status_flag = 'Y' AND
          taxlines_gt.tax_date
          BETWEEN status.effective_from AND
          nvl(status.effective_to,
              taxlines_gt.tax_date))
          THEN NULL
          ELSE 'Y'
          END
            ELSE NULL
       END  DEFAULT_STATUS_NOT_EXISTS,

           -- If Tax amount is null
           -- Bug 4703541 : Changed the taxlines_gt.tax_amt to to_char(taxlines_gt.tax_amt)
        NVL(to_char(taxlines_gt.tax_amt), 'Y') TAX_AMT_MISSING,

           CASE WHEN (taxlines_gt.tax_line_allocation_flag IS NULL OR
           taxlines_gt.tax_line_allocation_flag NOT IN ('Y', 'N'))
           THEN 'Y'
           ELSE  NULL
      END  ZX_TAX_LINE_ALLOC_FLAG_INVALID ,

      -- Tax lines with Tax Line Allocation flag as Y should have at least one allocation
      -- line in the Link GTT
           CASE WHEN (taxlines_gt.tax_line_allocation_flag = 'Y' AND
           NOT EXISTS (SELECT 1
                 FROM zx_trx_tax_link_gt
                WHERE application_id = taxlines_gt.application_id
            AND entity_code = taxlines_gt.entity_code
            AND event_class_code = taxlines_gt.event_class_code
            AND trx_id = taxlines_gt.trx_id
            AND summary_tax_line_number =
               taxlines_gt.summary_tax_line_number)
           )
           THEN 'Y'
           ELSE  NULL
      END ZX_INVALID_TAX_ALLOC_FLAG,
      -- Manual tax lines of tax oode 'LOCATION' is not allowed to be imported
      -- in Receivables
      CASE
         WHEN taxlines_gt.application_id = 222 AND taxlines_gt.tax = 'LOCATION'
         THEN
        'Y'
         ELSE
        'N'
      END  TAX_LN_TYP_LOC_NOT_ALLW_F_AR,

      -- If the imported tax line has inclusive_flag = 'N' but the tax
      -- is defined as inclusive in ZX_TAXES and allow inclusive override is N
      -- or vice versa, then raise error
      CASE WHEN  tax.def_inclusive_tax_flag <> taxlines_gt.tax_amt_included_flag
           AND tax.tax_inclusive_override_flag = 'N'
           THEN
         'Y'
           ELSE
         'N'
      END TAX_INCL_FLAG_MISMATCH,
      CASE WHEN (taxlines_gt.tax_amt <> 0 AND
            taxlines_gt.tax_rate = 0
           )
           THEN 'Y'
           ELSE  NULL
      END ZX_IMP_TAX_RATE_AMT_MISMATCH

      /* end bug 3676878  */
  FROM ZX_TRX_HEADERS_GT header,
      ZX_REGIMES_B regime ,
      ZX_TAXES_B tax ,
      ZX_STATUS_B status ,
  --    ZX_RATES_B rate ,
  --    zx_rates_b off_rate,
  --    zx_import_tax_lines_gt temp_gt,
      ZX_IMPORT_TAX_LINES_GT taxlines_gt,
      --zx_transaction_lines_gt lines_gt,
      ZX_JURISDICTIONS_B jur,
      zx_subscription_details sd_reg,
      zx_subscription_details sd_tax,
      zx_subscription_details sd_status
  --    zx_subscription_details sd_rates
  WHERE taxlines_gt.trx_id = header.trx_id
      AND taxlines_gt.application_id = Header.application_id
      AND taxlines_gt.entity_code = Header.entity_code
      AND taxlines_gt.event_class_code = Header.event_class_code
            --AND (taxlines_gt.tax_rate_code IS NOT NULL OR taxlines_gt.tax_rate_id IS NOT NULL)
      AND jur.tax_jurisdiction_code(+) = taxlines_gt.tax_jurisdiction_code
      AND jur.tax_regime_code(+) = taxlines_gt.tax_regime_code  -- Bug 4902521
      AND jur.tax(+) = taxlines_gt.tax  -- Bug 4902521
      AND
      (
    taxlines_gt.tax_date
    BETWEEN
         nvl(jur.effective_from,
      taxlines_gt.tax_date
       ) AND
         nvl(jur.effective_to,
       taxlines_gt.tax_date
       )
    /*OR jur.effective_from =
    (
    SELECT
        min(effective_from)
    FROM ZX_JURISDICTIONS_B
    WHERE tax_jurisdiction_code = jur.tax_jurisdiction_code
    ) */
      )
      --AND lines_gt.application_id = header.application_id
      --AND lines_gt.entity_code = header.entity_code
      --AND lines_gt.event_class_code = header.event_class_code
      --AND lines_gt.trx_id = header.trx_id
      --AND
      --(-- One to One Alloc
    --(
        --lines_gt.trx_line_id = taxlines_gt.trx_line_id
    --)
    --OR
    --Multi Alloc
    --(
        --taxlines_gt.trx_line_id IS NULL
        --AND taxlines_gt.tax_line_allocation_flag = 'Y'
        --AND lines_gt.trx_line_id =
        --(
        --SELECT /*+ index(link_gt ZX_TRX_TAX_LINK_GT_U1) */
      --MIN(trx_line_id)
        --FROM zx_trx_tax_link_gt link_gt
        --WHERE link_gt.TRX_ID = taxlines_gt.trx_id
      --AND link_gt.application_id = taxlines_gt.application_id
      --AND link_gt.entity_code = taxlines_gt.entity_code
      --AND link_gt.event_class_code = taxlines_gt.event_class_code
      --AND link_gt.summary_tax_line_number = taxlines_gt.summary_tax_line_number
        --)
    --)
    --OR
    --All Alloc
    --(
        --taxlines_gt.trx_line_id IS NULL
        --AND taxlines_gt.tax_line_allocation_flag = 'N'
        --AND lines_gt.trx_line_id =
        --(
        --SELECT /*+ index(trans_line_gt ZX_TRANSACTION_LINES_GT_U1) */
      --MIN(trx_line_id)
        --FROM zx_transaction_lines_gt trans_line_gt
        --WHERE trans_line_gt.trx_id = taxlines_gt.trx_id
      --AND trans_line_gt.application_id = taxlines_gt.application_id
      --AND trans_line_gt.entity_code = taxlines_gt.entity_code
      --AND trans_line_gt.event_class_code = taxlines_gt.event_class_code
        --)
    --)
      --)
      --* for regime
      AND regime.tax_regime_code(+) = taxlines_gt.tax_regime_code
      AND regime.TAX_REGIME_CODE = sd_reg.tax_regime_code (+)
      --AND sd_reg.first_pty_org_id(+) = g_first_pty_org_id
      AND sd_reg.first_pty_org_id IN (g_first_pty_org_id, -99)
      AND nvl(sd_reg.view_options_code,'NONE') in ('NONE', 'VFC') -- Bug 4902521
      AND (
    taxlines_gt.subscription_date
    BETWEEN
    NVL(sd_reg.effective_from,
        taxlines_gt.subscription_date
        )
    AND
    NVL(sd_reg.effective_to,
        taxlines_gt.subscription_date
        )
       /* OR regime.effective_from =
        (
        SELECT
      MIN(effective_from)
        FROM zx_regimes_b
        WHERE tax_regime_code = regime.tax_regime_code
        ) */
    )
      --* for taxes
      AND tax.tax(+) = taxlines_gt.tax
      AND tax.tax_regime_code(+) = taxlines_gt.tax_regime_code
      AND tax.tax_regime_code = sd_tax.tax_regime_code (+)
      AND (
     tax.content_owner_id = sd_tax.parent_first_pty_org_id
     OR
     sd_tax.parent_first_pty_org_id is NULL
    )
      --AND sd_tax.first_pty_org_id(+) = g_first_pty_org_id
      AND sd_tax.first_pty_org_id IN (g_first_pty_org_id, -99)
      AND
      (
    taxlines_gt.subscription_date
    BETWEEN
    nvl(sd_tax.effective_from,
        taxlines_gt.subscription_date
       )
        AND
        NVL(sd_tax.effective_to,
      taxlines_gt.subscription_date
           )
    /*OR tax.effective_from =
    (
    SELECT
        min(effective_from)
    FROM ZX_TAXES_B
    WHERE tax_regime_code = tax.tax_regime_code
        AND tax = tax.tax
        AND content_owner_id = tax.content_owner_id
    ) */
      )
      AND
      (
    nvl(sd_tax.view_options_code,'NONE') in ('NONE', 'VFC')
    OR
    (
        nvl(sd_tax.view_options_code,'VFR') = 'VFR'
        AND not exists
        (
        SELECT
      1
        FROM zx_taxes_b b
        WHERE tax.tax_regime_code = b.tax_regime_code
      AND tax.tax = b.tax
      AND sd_tax.first_pty_org_id = b.content_owner_id
        )
    )
      )
      --* for status
      AND status.tax_status_code(+) = taxlines_gt.tax_status_code
      AND status.tax(+) = taxlines_gt.tax
      AND status.tax_regime_code(+) = taxlines_gt.tax_regime_code
      AND status.tax_regime_code = sd_status.tax_regime_code (+)
      AND
         (
    status.content_owner_id = sd_status.parent_first_pty_org_id
    OR
     sd_status.parent_first_pty_org_id is NULL
         )
      --AND sd_status.first_pty_org_id(+) = g_first_pty_org_id
      AND sd_status.first_pty_org_id IN (g_first_pty_org_id, -99)
      AND
      (
    taxlines_gt.subscription_date
    BETWEEN
    nvl( sd_status.effective_from,
         taxlines_gt.subscription_date
       )
       AND
       nvl(sd_status.effective_to,
           taxlines_gt.subscription_date
      )
    /*OR status.effective_from =
    (
    SELECT
        min(effective_from)
    FROM ZX_STATUS_B
    WHERE tax_regime_code = status.tax_regime_code
        AND tax = status.tax
        AND tax_status_code = status.tax_status_code
        AND content_owner_id = status.content_owner_id
    ) */
      )
      AND
      (
    NVL(sd_status.view_options_code,'NONE') in ('NONE', 'VFC')
    OR
    (
        NVL(sd_status.view_options_code,'VFR') = 'VFR'
        AND not exists
        (
        SELECT
      1
        FROM zx_status_vl b
        WHERE b.tax_regime_code = status.tax_regime_code
      AND b.tax = status.tax
      AND b.tax_status_code = status.tax_status_code
      AND b.content_owner_id = sd_status.first_pty_org_id
        )
    )
      ) ;


-- added 3 new quries to handle the following validations.
-- spilt the complex OR condition into 3
INSERT ALL
WHEN (SAMETAX_MULTIALLOC_TO_SAMELN = 'Y') THEN

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
         interface_tax_entity_code,
         interface_tax_line_id
          )
        VALUES (
         application_id,
         entity_code,
         event_class_code,
         trx_id,
         trx_line_id,
         summary_tax_line_number,
         'ZX_TAX_MULTIALLOC_TO_SAMELN',
         l_tax_multialloc_to_sameln,
         trx_level_type,
         interface_tax_entity_code,
         interface_tax_line_id
         )
      WHEN (TAX_ONLY_LINE_MULTI_ALLOCATED = 'Y') THEN

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
         interface_tax_entity_code,
         interface_tax_line_id
         )
        VALUES (
         application_id,
         entity_code,
         event_class_code,
         trx_id,
         trx_line_id,
         summary_tax_line_number,
         'ZX_TAX_ONLY_LINE_MULTI_ALLOCAT',
         l_tax_only_line_multi_allocate,
         trx_level_type,
         interface_tax_entity_code,
         interface_tax_line_id
         )
      WHEN (PSEUDO_LINE_HAS_MULTI_TAXALLOC = 'Y') THEN

        INTO zx_validation_errors_gt(
         application_id,
         entity_code,
         event_class_code,
         trx_id,
         trx_line_id,
         --summary_tax_line_number,
         message_name,
         message_text,
         trx_level_type,
         interface_line_entity_code,
         interface_line_id
          )
        VALUES (
         application_id,
         entity_code,
         event_class_code,
         trx_id,
         trx_line_id,
         --summary_tax_line_number,
         'ZX_PSEUDO_LINE_HAS_MULTI_TAX',
         l_pseudo_line_has_multi_taxall,
         trx_level_type,
         interface_line_entity_code,
         interface_line_id
         )
      WHEN (ZX_TAX_MISSING_IN_APPLIED_FRM = 'Y') THEN

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
         interface_tax_entity_code,
         interface_tax_line_id
          )
          VALUES(
         application_id,
         entity_code,
         event_class_code,
         trx_id,
         trx_line_id,
         summary_tax_line_number,
         'ZX_TAX_MISSING_IN_APPLIED_FRM',
         l_imp_tax_missing_in_appld_frm,
         trx_level_type,
         interface_tax_entity_code,
         interface_tax_line_id
         )

      WHEN (ZX_TAX_MISSING_IN_ADJUSTED_TO = 'Y') THEN

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
         interface_tax_entity_code,
         interface_tax_line_id
          )
          VALUES(
         application_id,
         entity_code,
         event_class_code,
         trx_id,
         trx_line_id,
         summary_tax_line_number,
         'ZX_TAX_MISSING_IN_ADJUSTED_TO',
         l_imp_tax_missing_in_adjust_to,
         trx_level_type,
         interface_tax_entity_code,
         interface_tax_line_id
         )
  SELECT /*+ leading(taxlines_gt) */ header.application_id,
      header.entity_code,
      header.event_class_code,
      header.trx_id,
      taxlines_gt.summary_tax_line_number,
      taxlines_gt.summary_tax_line_number interface_tax_line_id,
      taxlines_gt.entity_code             interface_tax_entity_code,
      lines_gt.trx_line_id     interface_line_id,
      lines_gt.entity_code     interface_line_entity_code,
      lines_gt.trx_line_id,
      lines_gt.trx_level_type,
      -- The same tax regime and tax cannot be allocated to the same
      -- transaction line multi times
      --
            CASE
        WHEN  taxlines_gt.tax_regime_code IS NOT NULL AND
         taxlines_gt.tax IS NOT NULL AND
         -- split the complex Or condition here into multiple selects with Union all.
         EXISTS
        (SELECT /*+ INDEX(imptaxes_gt1 ZX_IMPORT_TAX_LINES_GT_U1) */
                1
           FROM zx_import_tax_lines_gt imptaxes_gt1
          WHERE imptaxes_gt1.application_id= taxlines_gt.application_id
            AND imptaxes_gt1.entity_code = taxlines_gt.entity_code
            AND imptaxes_gt1.event_class_code = taxlines_gt.event_class_code
            AND imptaxes_gt1.trx_id = taxlines_gt.trx_id
            AND imptaxes_gt1.summary_tax_line_number <> taxlines_gt.summary_tax_line_number
            AND imptaxes_gt1.tax_regime_code = taxlines_gt.tax_regime_code
            AND imptaxes_gt1.tax = taxlines_gt.tax
            AND --imptaxes_gt1 is all alloc
                (imptaxes_gt1.trx_line_id IS NULL AND
                 imptaxes_gt1.tax_line_allocation_flag = 'N')
            UNION ALL
            SELECT /*+ INDEX(imptaxes_gt1 ZX_IMPORT_TAX_LINES_GT_U1) */
                   1
           FROM zx_import_tax_lines_gt imptaxes_gt1
          WHERE imptaxes_gt1.application_id= taxlines_gt.application_id
            AND imptaxes_gt1.entity_code = taxlines_gt.entity_code
            AND imptaxes_gt1.event_class_code = taxlines_gt.event_class_code
            AND imptaxes_gt1.trx_id = taxlines_gt.trx_id
            AND imptaxes_gt1.summary_tax_line_number <> taxlines_gt.summary_tax_line_number
            AND imptaxes_gt1.tax_regime_code = taxlines_gt.tax_regime_code
            AND imptaxes_gt1.tax = taxlines_gt.tax
            AND --taxlines_gt is all alloc
                (taxlines_gt.trx_line_id IS NULL AND
                 taxlines_gt.tax_line_allocation_flag = 'N')
            UNION ALL
            SELECT /*+ INDEX(imptaxes_gt1 ZX_IMPORT_TAX_LINES_GT_U1) */
                   1
           FROM zx_import_tax_lines_gt imptaxes_gt1
          WHERE imptaxes_gt1.application_id= taxlines_gt.application_id
            AND imptaxes_gt1.entity_code = taxlines_gt.entity_code
            AND imptaxes_gt1.event_class_code = taxlines_gt.event_class_code
            AND imptaxes_gt1.trx_id = taxlines_gt.trx_id
            AND imptaxes_gt1.summary_tax_line_number <> taxlines_gt.summary_tax_line_number
            AND imptaxes_gt1.tax_regime_code = taxlines_gt.tax_regime_code
            AND imptaxes_gt1.tax = taxlines_gt.tax
            AND (--imptaxes_gt1 is one to one alloc
                  ( imptaxes_gt1.trx_line_id IS NOT NULL AND
                    ( --taxlines_gt is one to one alloc
                      (imptaxes_gt1.trx_line_id = taxlines_gt.trx_line_id)
                       OR
                      --taxlines_gt is multi alloc
                      (taxlines_gt.trx_line_id IS NULL AND
                       taxlines_gt.tax_line_allocation_flag = 'Y' AND
                       EXISTS (SELECT 1
                               FROM zx_trx_tax_link_gt link_gt
                               WHERE link_gt.trx_id         = taxlines_gt.trx_id
                               AND link_gt.application_id   = taxlines_gt.application_id
                               AND link_gt.entity_code      = taxlines_gt.entity_code
                               AND link_gt.event_class_code = taxlines_gt.event_class_code
                               AND link_gt.summary_tax_line_number = taxlines_gt.summary_tax_line_number
                               AND link_gt.trx_line_id = imptaxes_gt1.trx_line_id))
                    )
                  )
                )
            UNION ALL
            SELECT /*+ INDEX(imptaxes_gt1 ZX_IMPORT_TAX_LINES_GT_U1) */
                   1
           FROM zx_import_tax_lines_gt imptaxes_gt1
          WHERE imptaxes_gt1.application_id= taxlines_gt.application_id
            AND imptaxes_gt1.entity_code = taxlines_gt.entity_code
            AND imptaxes_gt1.event_class_code = taxlines_gt.event_class_code
            AND imptaxes_gt1.trx_id = taxlines_gt.trx_id
            AND imptaxes_gt1.summary_tax_line_number <> taxlines_gt.summary_tax_line_number
            AND imptaxes_gt1.tax_regime_code = taxlines_gt.tax_regime_code
            AND imptaxes_gt1.tax = taxlines_gt.tax
            AND --imptaxes_gt1 is multi-alloc
                (imptaxes_gt1.trx_line_id IS NULL AND
                   imptaxes_gt1.tax_line_allocation_flag = 'Y' AND
                   ( --taxlines_gt is one to one alloc
                     (taxlines_gt.trx_line_id IS NOT NULL AND
                      EXISTS (SELECT 1
                              FROM zx_trx_tax_link_gt link_gt
                              WHERE link_gt.trx_id         = imptaxes_gt1.trx_id
                              AND link_gt.application_id   = imptaxes_gt1.application_id
                              AND link_gt.entity_code      = imptaxes_gt1.entity_code
                              AND link_gt.event_class_code = imptaxes_gt1.event_class_code
                              AND link_gt.summary_tax_line_number = imptaxes_gt1.summary_tax_line_number
                              AND link_gt.trx_line_id = taxlines_gt.trx_line_id))
                     )
                )
             UNION ALL
             SELECT /*+ INDEX(imptaxes_gt1 ZX_IMPORT_TAX_LINES_GT_U1) */
                    1
             FROM zx_import_tax_lines_gt imptaxes_gt1
            WHERE imptaxes_gt1.application_id= taxlines_gt.application_id
              AND imptaxes_gt1.entity_code = taxlines_gt.entity_code
              AND imptaxes_gt1.event_class_code = taxlines_gt.event_class_code
              AND imptaxes_gt1.trx_id = taxlines_gt.trx_id
              AND imptaxes_gt1.summary_tax_line_number <> taxlines_gt.summary_tax_line_number
              AND imptaxes_gt1.tax_regime_code = taxlines_gt.tax_regime_code
              AND imptaxes_gt1.tax = taxlines_gt.tax
              AND --taxlines_gt is multi alloc
                  (taxlines_gt.trx_line_id IS NULL AND
                   taxlines_gt.tax_line_allocation_flag = 'Y' AND
                   EXISTS (SELECT 1
                           FROM zx_trx_tax_link_gt link_gt1,
                                zx_trx_tax_link_gt link_gt2
                           WHERE link_gt1.trx_id = imptaxes_gt1.trx_id
                           AND link_gt1.application_id   = imptaxes_gt1.application_id
                           AND link_gt1.entity_code      = imptaxes_gt1.entity_code
                           AND link_gt1.event_class_code = imptaxes_gt1.event_class_code
                           AND link_gt1.summary_tax_line_number = imptaxes_gt1.summary_tax_line_number
                           AND link_gt1.trx_line_id = imptaxes_gt1.trx_line_id
                           AND link_gt2.trx_id = taxlines_gt.trx_id
                           AND link_gt2.application_id   = taxlines_gt.application_id
                           AND link_gt2.entity_code      = taxlines_gt.entity_code
                           AND link_gt2.event_class_code = taxlines_gt.event_class_code
                           AND link_gt2.summary_tax_line_number = taxlines_gt.summary_tax_line_number
                           AND link_gt2.trx_line_id = taxlines_gt.trx_line_id
                           AND link_gt2.trx_line_id = link_gt1.trx_line_id
                          )
                 )
          )
         THEN
             'Y'
         ELSE
             'N'
        END SAMETAX_MULTIALLOC_TO_SAMELN,

       -- Each tax only tax line can only be allocated to one pseudo trx line
       --
       CASE
         WHEN lines_gt.line_level_action = 'LINE_INFO_TAX_ONLY'
          AND EXISTS
        (SELECT /*+ INDEX(zx_trx_tax_link_gt ZX_TRX_TAX_LINK_GT_U1) */
          1
           FROM zx_trx_tax_link_gt
          WHERE application_id = taxlines_gt.application_id
            AND entity_code = taxlines_gt.entity_code
            AND event_class_code = taxlines_gt.event_class_code
            AND trx_id = taxlines_gt.trx_id
            AND summary_tax_line_number =
               taxlines_gt.summary_tax_line_number
            AND (trx_line_id <> lines_gt.trx_line_id OR
           trx_level_type <> lines_gt.trx_level_type)
        )
          THEN
        'Y'
          ELSE
        'N'
       END TAX_ONLY_LINE_MULTI_ALLOCATED,

       -- Each pseudo trx line can only be allocated with one tax_only tax line
       --
       CASE
         WHEN lines_gt.line_level_action = 'LINE_INFO_TAX_ONLY'
          AND EXISTS
        (SELECT /*+ INDEX(zx_trx_tax_link_gt ZX_TRX_TAX_LINK_GT_U1) */
          1
           FROM zx_trx_tax_link_gt
          WHERE application_id = taxlines_gt.application_id
            AND entity_code = taxlines_gt.entity_code
            AND event_class_code = taxlines_gt.event_class_code
            AND trx_id = taxlines_gt.trx_id
            AND summary_tax_line_number <>
                  taxlines_gt.summary_tax_line_number
            AND trx_line_id = lines_gt.trx_line_id
            AND trx_level_type = lines_gt.trx_level_type
        )
         THEN
            'Y'
         ELSE
            'N'
       END PSEUDO_LINE_HAS_MULTI_TAXALLOC,
      -- Bug 3676878: Imported tax lines found missing in other document
      --
      CASE
         WHEN lines_gt.applied_from_application_id IS NOT NULL
          AND NOT EXISTS
        (SELECT 1
           FROM zx_lines zl
          WHERE zl.application_id = lines_gt.applied_from_application_id
            AND zl.entity_code = lines_gt.applied_from_entity_code
            AND zl.event_class_code = lines_gt.applied_from_event_class_code
            AND zl.trx_id = lines_gt.applied_from_trx_id
            AND zl.trx_line_id = lines_gt.applied_from_line_id
            AND zl.trx_level_type = lines_gt.applied_from_trx_level_type
            AND zl.tax_regime_code = taxlines_gt.tax_regime_code
            AND zl.tax = taxlines_gt.tax
        )
          AND NOT EXISTS
          -- split the complex OR conditions into 3 queries with Union all.
        (SELECT 1
         FROM   zx_import_tax_lines_gt  tax_gt
         WHERE tax_gt.application_id = lines_gt.applied_from_application_id
         AND tax_gt.entity_code = lines_gt.applied_from_entity_code
         AND tax_gt.event_class_code = lines_gt.applied_from_event_class_code
         AND tax_gt.trx_id = lines_gt.applied_from_trx_id
         AND tax_gt.tax_regime_code = taxlines_gt.tax_regime_code
         AND tax_gt.tax = taxlines_gt.tax
         AND --One to One Alloc
              (tax_gt.trx_line_id = lines_gt.applied_from_line_id)
         UNION ALL
         SELECT 1
         FROM   zx_import_tax_lines_gt  tax_gt
         WHERE tax_gt.application_id = lines_gt.applied_from_application_id
         AND tax_gt.entity_code = lines_gt.applied_from_entity_code
         AND tax_gt.event_class_code = lines_gt.applied_from_event_class_code
         AND tax_gt.trx_id = lines_gt.applied_from_trx_id
         AND tax_gt.tax_regime_code = taxlines_gt.tax_regime_code
         AND tax_gt.tax = taxlines_gt.tax
         AND  --Multi Alloc
              (tax_gt.trx_line_id IS NULL AND
               tax_gt.tax_line_allocation_flag = 'Y' AND
               EXISTS (SELECT 1
                       FROM zx_trx_tax_link_gt link_gt
                       WHERE link_gt.trx_id = tax_gt.trx_id
                       AND link_gt.application_id   = tax_gt.application_id
                       AND link_gt.entity_code      = tax_gt.entity_code
                       AND link_gt.event_class_code = tax_gt.event_class_code
                       AND link_gt.summary_tax_line_number = tax_gt.summary_tax_line_number
                       AND link_gt.trx_level_type = lines_gt.applied_from_trx_level_type
                       AND link_gt.trx_line_id = lines_gt.applied_from_line_id)
              )
         UNION ALL
         SELECT 1
         FROM   zx_import_tax_lines_gt  tax_gt
         WHERE tax_gt.application_id = lines_gt.applied_from_application_id
         AND tax_gt.entity_code = lines_gt.applied_from_entity_code
         AND tax_gt.event_class_code = lines_gt.applied_from_event_class_code
         AND tax_gt.trx_id = lines_gt.applied_from_trx_id
         AND tax_gt.tax_regime_code = taxlines_gt.tax_regime_code
         AND tax_gt.tax = taxlines_gt.tax
         AND --All Alloc
              (tax_gt.trx_line_id IS NULL AND
               tax_gt.tax_line_allocation_flag = 'N' AND
               EXISTS (SELECT 1
                       FROM zx_transaction_lines_gt trans_line_gt
                       WHERE trans_line_gt.trx_id         = tax_gt.trx_id
                       AND trans_line_gt.application_id   = tax_gt.application_id
                       AND trans_line_gt.entity_code = tax_gt.entity_code
                       AND trans_line_gt.event_class_code = tax_gt.event_class_code
                       AND trans_line_gt.trx_level_type = lines_gt.applied_from_trx_level_type
                       AND trans_line_gt.trx_line_id = lines_gt.applied_from_line_id)
              )
        )
         THEN
             'Y'
         ELSE
             'N'
      END ZX_TAX_MISSING_IN_APPLIED_FRM,

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
	    AND zl.tax_status_code = taxlines_gt.tax_status_code
	    AND zl.tax_rate_code = taxlines_gt.tax_rate_code
	    AND NVL(zl.tax_jurisdiction_code, 'X') = NVL(taxlines_gt.tax_jurisdiction_code, 'X')
	    AND zl.tax_rate = taxlines_gt.tax_rate
        )
          AND NOT EXISTS
        (
         SELECT 1
         FROM   zx_import_tax_lines_gt  tax_gt
         WHERE tax_gt.application_id = lines_gt.adjusted_doc_application_id
         AND tax_gt.entity_code = lines_gt.adjusted_doc_entity_code
         AND tax_gt.event_class_code = lines_gt.adjusted_doc_event_class_code
         AND tax_gt.trx_id = lines_gt.adjusted_doc_trx_id
         AND tax_gt.tax_regime_code = taxlines_gt.tax_regime_code
         AND tax_gt.tax = taxlines_gt.tax
	 AND tax_gt.tax_status_code = taxlines_gt.tax_status_code
	 AND tax_gt.tax_rate_code = taxlines_gt.tax_rate_code
	 AND NVL(tax_gt.tax_jurisdiction_code, 'X') = NVL(taxlines_gt.tax_jurisdiction_code, 'X')
	 AND tax_gt.tax_rate = taxlines_gt.tax_rate
         AND --One to One Alloc
            (tax_gt.trx_line_id = lines_gt.adjusted_doc_line_id)
         UNION ALL
         SELECT 1
         FROM   zx_import_tax_lines_gt  tax_gt
         WHERE tax_gt.application_id = lines_gt.adjusted_doc_application_id
         AND tax_gt.entity_code = lines_gt.adjusted_doc_entity_code
         AND tax_gt.event_class_code = lines_gt.adjusted_doc_event_class_code
         AND tax_gt.trx_id = lines_gt.adjusted_doc_trx_id
         AND tax_gt.tax_regime_code = taxlines_gt.tax_regime_code
         AND tax_gt.tax = taxlines_gt.tax
	 AND tax_gt.tax_status_code = taxlines_gt.tax_status_code
	 AND tax_gt.tax_rate_code = taxlines_gt.tax_rate_code
	 AND NVL(tax_gt.tax_jurisdiction_code, 'X') = NVL(taxlines_gt.tax_jurisdiction_code, 'X')
	 AND tax_gt.tax_rate = taxlines_gt.tax_rate
	       AND --Multi Alloc
              (tax_gt.trx_line_id IS NULL AND
               tax_gt.tax_line_allocation_flag = 'Y' AND
               EXISTS (SELECT 1
                       FROM zx_trx_tax_link_gt link_gt
                       WHERE link_gt.trx_id = tax_gt.trx_id
                       AND link_gt.application_id   = tax_gt.application_id
                       AND link_gt.entity_code      = tax_gt.entity_code
                       AND link_gt.event_class_code = tax_gt.event_class_code
                       AND link_gt.summary_tax_line_number = tax_gt.summary_tax_line_number
                       AND link_gt.trx_level_type = lines_gt.adjusted_doc_trx_level_type
                       AND link_gt.trx_line_id = lines_gt.adjusted_doc_line_id)
              )
         UNION ALL
         SELECT 1
         FROM   zx_import_tax_lines_gt  tax_gt
         WHERE tax_gt.application_id = lines_gt.adjusted_doc_application_id
         AND tax_gt.entity_code = lines_gt.adjusted_doc_entity_code
         AND tax_gt.event_class_code = lines_gt.adjusted_doc_event_class_code
         AND tax_gt.trx_id = lines_gt.adjusted_doc_trx_id
         AND tax_gt.tax_regime_code = taxlines_gt.tax_regime_code
         AND tax_gt.tax = taxlines_gt.tax
	 AND tax_gt.tax_status_code = taxlines_gt.tax_status_code
	 AND tax_gt.tax_rate_code = taxlines_gt.tax_rate_code
	 AND NVL(tax_gt.tax_jurisdiction_code, 'X') = NVL(taxlines_gt.tax_jurisdiction_code, 'X')
	 AND tax_gt.tax_rate = taxlines_gt.tax_rate
	       AND  --All Alloc
              (tax_gt.trx_line_id IS NULL AND
               tax_gt.tax_line_allocation_flag = 'N' AND
               EXISTS (SELECT 1
                       FROM zx_transaction_lines_gt trans_line_gt
                       WHERE trans_line_gt.trx_id         = tax_gt.trx_id
                       AND trans_line_gt.application_id   = tax_gt.application_id
                       AND trans_line_gt.entity_code = tax_gt.entity_code
                       AND trans_line_gt.event_class_code = tax_gt.event_class_code
                       AND trans_line_gt.trx_level_type = lines_gt.adjusted_doc_trx_level_type
                       AND trans_line_gt.trx_line_id = lines_gt.adjusted_doc_line_id)
              )
        )
         THEN
             'Y'
         ELSE
             'N'
      END ZX_TAX_MISSING_IN_ADJUSTED_TO
FROM ZX_TRX_HEADERS_GT header,
      ZX_IMPORT_TAX_LINES_GT taxlines_gt,
      zx_transaction_lines_gt lines_gt
  WHERE taxlines_gt.trx_id = header.trx_id
      AND taxlines_gt.application_id = Header.application_id
      AND taxlines_gt.entity_code = Header.entity_code
      AND taxlines_gt.event_class_code = Header.event_class_code
      AND lines_gt.application_id = header.application_id
      AND lines_gt.entity_code = header.entity_code
      AND lines_gt.event_class_code = header.event_class_code
      AND lines_gt.trx_id = header.trx_id
      AND -- One to One Alloc
         lines_gt.trx_line_id = taxlines_gt.trx_line_id;

INSERT ALL
WHEN (SAMETAX_MULTIALLOC_TO_SAMELN = 'Y') THEN

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
         interface_tax_entity_code,
         interface_tax_line_id
          )
        VALUES (
         application_id,
         entity_code,
         event_class_code,
         trx_id,
         trx_line_id,
         summary_tax_line_number,
         'ZX_TAX_MULTIALLOC_TO_SAMELN',
         l_tax_multialloc_to_sameln,
         trx_level_type,
         interface_tax_entity_code,
         interface_tax_line_id
         )
      WHEN (TAX_ONLY_LINE_MULTI_ALLOCATED = 'Y') THEN

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
         interface_tax_entity_code,
         interface_tax_line_id
         )
        VALUES (
         application_id,
         entity_code,
         event_class_code,
         trx_id,
         trx_line_id,
         summary_tax_line_number,
         'ZX_TAX_ONLY_LINE_MULTI_ALLOCAT',
         l_tax_only_line_multi_allocate,
         trx_level_type,
         interface_tax_entity_code,
         interface_tax_line_id
         )
      WHEN (PSEUDO_LINE_HAS_MULTI_TAXALLOC = 'Y') THEN

        INTO zx_validation_errors_gt(
         application_id,
         entity_code,
         event_class_code,
         trx_id,
         trx_line_id,
         --summary_tax_line_number,
         message_name,
         message_text,
         trx_level_type,
         interface_line_entity_code,
         interface_line_id
          )
        VALUES (
         application_id,
         entity_code,
         event_class_code,
         trx_id,
         trx_line_id,
         --summary_tax_line_number,
         'ZX_PSEUDO_LINE_HAS_MULTI_TAX',
         l_pseudo_line_has_multi_taxall,
         trx_level_type,
         interface_line_entity_code,
         interface_line_id
         )
      WHEN (ZX_TAX_MISSING_IN_APPLIED_FRM = 'Y') THEN

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
         interface_tax_entity_code,
         interface_tax_line_id
          )
          VALUES(
         application_id,
         entity_code,
         event_class_code,
         trx_id,
         trx_line_id,
         summary_tax_line_number,
         'ZX_TAX_MISSING_IN_APPLIED_FRM',
         l_imp_tax_missing_in_appld_frm,
         trx_level_type,
         interface_tax_entity_code,
         interface_tax_line_id
         )

      WHEN (ZX_TAX_MISSING_IN_ADJUSTED_TO = 'Y') THEN

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
         interface_tax_entity_code,
         interface_tax_line_id
          )
          VALUES(
         application_id,
         entity_code,
         event_class_code,
         trx_id,
         trx_line_id,
         summary_tax_line_number,
         'ZX_TAX_MISSING_IN_ADJUSTED_TO',
         l_imp_tax_missing_in_adjust_to,
         trx_level_type,
         interface_tax_entity_code,
         interface_tax_line_id
         )
  SELECT /*+ leading(taxlines_gt) */ header.application_id,
      header.entity_code,
      header.event_class_code,
      header.trx_id,
      taxlines_gt.summary_tax_line_number,
      taxlines_gt.summary_tax_line_number interface_tax_line_id,
      taxlines_gt.entity_code             interface_tax_entity_code,
      lines_gt.trx_line_id     interface_line_id,
      lines_gt.entity_code     interface_line_entity_code,
      lines_gt.trx_line_id,
      lines_gt.trx_level_type,
      -- The same tax regime and tax cannot be allocated to the same
      -- transaction line multi times
      --
            CASE
        WHEN  taxlines_gt.tax_regime_code IS NOT NULL AND
         taxlines_gt.tax IS NOT NULL AND
         -- split the complex Or condition here into multiple selects with Union all.
         EXISTS
        (SELECT /*+ INDEX(imptaxes_gt1 ZX_IMPORT_TAX_LINES_GT_U1) */
                1
           FROM zx_import_tax_lines_gt imptaxes_gt1
          WHERE imptaxes_gt1.application_id= taxlines_gt.application_id
            AND imptaxes_gt1.entity_code = taxlines_gt.entity_code
            AND imptaxes_gt1.event_class_code = taxlines_gt.event_class_code
            AND imptaxes_gt1.trx_id = taxlines_gt.trx_id
            AND imptaxes_gt1.summary_tax_line_number <> taxlines_gt.summary_tax_line_number
            AND imptaxes_gt1.tax_regime_code = taxlines_gt.tax_regime_code
            AND imptaxes_gt1.tax = taxlines_gt.tax
            AND --imptaxes_gt1 is all alloc
                (imptaxes_gt1.trx_line_id IS NULL AND
                 imptaxes_gt1.tax_line_allocation_flag = 'N')
            UNION ALL
            SELECT /*+ INDEX(imptaxes_gt1 ZX_IMPORT_TAX_LINES_GT_U1) */
                   1
           FROM zx_import_tax_lines_gt imptaxes_gt1
          WHERE imptaxes_gt1.application_id= taxlines_gt.application_id
            AND imptaxes_gt1.entity_code = taxlines_gt.entity_code
            AND imptaxes_gt1.event_class_code = taxlines_gt.event_class_code
            AND imptaxes_gt1.trx_id = taxlines_gt.trx_id
            AND imptaxes_gt1.summary_tax_line_number <> taxlines_gt.summary_tax_line_number
            AND imptaxes_gt1.tax_regime_code = taxlines_gt.tax_regime_code
            AND imptaxes_gt1.tax = taxlines_gt.tax
            AND --taxlines_gt is all alloc
                (taxlines_gt.trx_line_id IS NULL AND
                 taxlines_gt.tax_line_allocation_flag = 'N')
            UNION ALL
            SELECT /*+ INDEX(imptaxes_gt1 ZX_IMPORT_TAX_LINES_GT_U1) */
                   1
           FROM zx_import_tax_lines_gt imptaxes_gt1
          WHERE imptaxes_gt1.application_id= taxlines_gt.application_id
            AND imptaxes_gt1.entity_code = taxlines_gt.entity_code
            AND imptaxes_gt1.event_class_code = taxlines_gt.event_class_code
            AND imptaxes_gt1.trx_id = taxlines_gt.trx_id
            AND imptaxes_gt1.summary_tax_line_number <> taxlines_gt.summary_tax_line_number
            AND imptaxes_gt1.tax_regime_code = taxlines_gt.tax_regime_code
            AND imptaxes_gt1.tax = taxlines_gt.tax
            AND (--imptaxes_gt1 is one to one alloc
                  ( imptaxes_gt1.trx_line_id IS NOT NULL AND
                    ( --taxlines_gt is one to one alloc
                      (imptaxes_gt1.trx_line_id = taxlines_gt.trx_line_id)
                       OR
                      --taxlines_gt is multi alloc
                      (taxlines_gt.trx_line_id IS NULL AND
                       taxlines_gt.tax_line_allocation_flag = 'Y' AND
                       EXISTS (SELECT 1
                               FROM zx_trx_tax_link_gt link_gt
                               WHERE link_gt.trx_id         = taxlines_gt.trx_id
                               AND link_gt.application_id   = taxlines_gt.application_id
                               AND link_gt.entity_code      = taxlines_gt.entity_code
                               AND link_gt.event_class_code = taxlines_gt.event_class_code
                               AND link_gt.summary_tax_line_number = taxlines_gt.summary_tax_line_number
                               AND link_gt.trx_line_id = imptaxes_gt1.trx_line_id))
                    )
                  )
                )
            UNION ALL
            SELECT /*+ INDEX(imptaxes_gt1 ZX_IMPORT_TAX_LINES_GT_U1) */
                   1
           FROM zx_import_tax_lines_gt imptaxes_gt1
          WHERE imptaxes_gt1.application_id= taxlines_gt.application_id
            AND imptaxes_gt1.entity_code = taxlines_gt.entity_code
            AND imptaxes_gt1.event_class_code = taxlines_gt.event_class_code
            AND imptaxes_gt1.trx_id = taxlines_gt.trx_id
            AND imptaxes_gt1.summary_tax_line_number <> taxlines_gt.summary_tax_line_number
            AND imptaxes_gt1.tax_regime_code = taxlines_gt.tax_regime_code
            AND imptaxes_gt1.tax = taxlines_gt.tax
            AND --imptaxes_gt1 is multi-alloc
                (imptaxes_gt1.trx_line_id IS NULL AND
                   imptaxes_gt1.tax_line_allocation_flag = 'Y' AND
                   ( --taxlines_gt is one to one alloc
                     (taxlines_gt.trx_line_id IS NOT NULL AND
                      EXISTS (SELECT 1
                              FROM zx_trx_tax_link_gt link_gt
                              WHERE link_gt.trx_id         = imptaxes_gt1.trx_id
                              AND link_gt.application_id   = imptaxes_gt1.application_id
                              AND link_gt.entity_code      = imptaxes_gt1.entity_code
                              AND link_gt.event_class_code = imptaxes_gt1.event_class_code
                              AND link_gt.summary_tax_line_number = imptaxes_gt1.summary_tax_line_number
                              AND link_gt.trx_line_id = taxlines_gt.trx_line_id))
                     )
                )
             UNION ALL
             SELECT /*+ INDEX(imptaxes_gt1 ZX_IMPORT_TAX_LINES_GT_U1) */
                    1
             FROM zx_import_tax_lines_gt imptaxes_gt1
            WHERE imptaxes_gt1.application_id= taxlines_gt.application_id
              AND imptaxes_gt1.entity_code = taxlines_gt.entity_code
              AND imptaxes_gt1.event_class_code = taxlines_gt.event_class_code
              AND imptaxes_gt1.trx_id = taxlines_gt.trx_id
              AND imptaxes_gt1.summary_tax_line_number <> taxlines_gt.summary_tax_line_number
              AND imptaxes_gt1.tax_regime_code = taxlines_gt.tax_regime_code
              AND imptaxes_gt1.tax = taxlines_gt.tax
              AND --taxlines_gt is multi alloc
                  (taxlines_gt.trx_line_id IS NULL AND
                   taxlines_gt.tax_line_allocation_flag = 'Y' AND
                   EXISTS (SELECT 1
                           FROM zx_trx_tax_link_gt link_gt1,
                                zx_trx_tax_link_gt link_gt2
                           WHERE link_gt1.trx_id = imptaxes_gt1.trx_id
                           AND link_gt1.application_id   = imptaxes_gt1.application_id
                           AND link_gt1.entity_code      = imptaxes_gt1.entity_code
                           AND link_gt1.event_class_code = imptaxes_gt1.event_class_code
                           AND link_gt1.summary_tax_line_number = imptaxes_gt1.summary_tax_line_number
                           AND link_gt1.trx_line_id = imptaxes_gt1.trx_line_id
                           AND link_gt2.trx_id = taxlines_gt.trx_id
                           AND link_gt2.application_id   = taxlines_gt.application_id
                           AND link_gt2.entity_code      = taxlines_gt.entity_code
                           AND link_gt2.event_class_code = taxlines_gt.event_class_code
                           AND link_gt2.summary_tax_line_number = taxlines_gt.summary_tax_line_number
                           AND link_gt2.trx_line_id = taxlines_gt.trx_line_id
                           AND link_gt2.trx_line_id = link_gt1.trx_line_id
                          )
                 )
          )
         THEN
             'Y'
         ELSE
             'N'
        END SAMETAX_MULTIALLOC_TO_SAMELN,

       -- Each tax only tax line can only be allocated to one pseudo trx line
       --
       CASE
         WHEN lines_gt.line_level_action = 'LINE_INFO_TAX_ONLY'
          AND EXISTS
        (SELECT /*+ INDEX(zx_trx_tax_link_gt ZX_TRX_TAX_LINK_GT_U1) */
          1
           FROM zx_trx_tax_link_gt
          WHERE application_id = taxlines_gt.application_id
            AND entity_code = taxlines_gt.entity_code
            AND event_class_code = taxlines_gt.event_class_code
            AND trx_id = taxlines_gt.trx_id
            AND summary_tax_line_number =
               taxlines_gt.summary_tax_line_number
            AND (trx_line_id <> lines_gt.trx_line_id OR
           trx_level_type <> lines_gt.trx_level_type)
        )
          THEN
        'Y'
          ELSE
        'N'
       END TAX_ONLY_LINE_MULTI_ALLOCATED,

       -- Each pseudo trx line can only be allocated with one tax_only tax line
       --
       CASE
         WHEN lines_gt.line_level_action = 'LINE_INFO_TAX_ONLY'
          AND EXISTS
        (SELECT /*+ INDEX(zx_trx_tax_link_gt ZX_TRX_TAX_LINK_GT_U1) */
          1
           FROM zx_trx_tax_link_gt
          WHERE application_id = taxlines_gt.application_id
            AND entity_code = taxlines_gt.entity_code
            AND event_class_code = taxlines_gt.event_class_code
            AND trx_id = taxlines_gt.trx_id
            AND summary_tax_line_number <>
                  taxlines_gt.summary_tax_line_number
            AND trx_line_id = lines_gt.trx_line_id
            AND trx_level_type = lines_gt.trx_level_type
        )
         THEN
            'Y'
         ELSE
            'N'
       END PSEUDO_LINE_HAS_MULTI_TAXALLOC,
      -- Bug 3676878: Imported tax lines found missing in other document
      --
      CASE
         WHEN lines_gt.applied_from_application_id IS NOT NULL
          AND NOT EXISTS
        (SELECT 1
           FROM zx_lines zl
          WHERE zl.application_id = lines_gt.applied_from_application_id
            AND zl.entity_code = lines_gt.applied_from_entity_code
            AND zl.event_class_code = lines_gt.applied_from_event_class_code
            AND zl.trx_id = lines_gt.applied_from_trx_id
            AND zl.trx_line_id = lines_gt.applied_from_line_id
            AND zl.trx_level_type = lines_gt.applied_from_trx_level_type
            AND zl.tax_regime_code = taxlines_gt.tax_regime_code
            AND zl.tax = taxlines_gt.tax
        )
          AND NOT EXISTS
          -- split the complex OR conditions into 3 queries with Union all.
        (SELECT 1
         FROM   zx_import_tax_lines_gt  tax_gt
         WHERE tax_gt.application_id = lines_gt.applied_from_application_id
         AND tax_gt.entity_code = lines_gt.applied_from_entity_code
         AND tax_gt.event_class_code = lines_gt.applied_from_event_class_code
         AND tax_gt.trx_id = lines_gt.applied_from_trx_id
         AND tax_gt.tax_regime_code = taxlines_gt.tax_regime_code
         AND tax_gt.tax = taxlines_gt.tax
         AND --One to One Alloc
              (tax_gt.trx_line_id = lines_gt.applied_from_line_id)
         UNION ALL
         SELECT 1
         FROM   zx_import_tax_lines_gt  tax_gt
         WHERE tax_gt.application_id = lines_gt.applied_from_application_id
         AND tax_gt.entity_code = lines_gt.applied_from_entity_code
         AND tax_gt.event_class_code = lines_gt.applied_from_event_class_code
         AND tax_gt.trx_id = lines_gt.applied_from_trx_id
         AND tax_gt.tax_regime_code = taxlines_gt.tax_regime_code
         AND tax_gt.tax = taxlines_gt.tax
         AND  --Multi Alloc
              (tax_gt.trx_line_id IS NULL AND
               tax_gt.tax_line_allocation_flag = 'Y' AND
               EXISTS (SELECT 1
                       FROM zx_trx_tax_link_gt link_gt
                       WHERE link_gt.trx_id = tax_gt.trx_id
                       AND link_gt.application_id   = tax_gt.application_id
                       AND link_gt.entity_code      = tax_gt.entity_code
                       AND link_gt.event_class_code = tax_gt.event_class_code
                       AND link_gt.summary_tax_line_number = tax_gt.summary_tax_line_number
                       AND link_gt.trx_level_type = lines_gt.applied_from_trx_level_type
                       AND link_gt.trx_line_id = lines_gt.applied_from_line_id)
              )
         UNION ALL
         SELECT 1
         FROM   zx_import_tax_lines_gt  tax_gt
         WHERE tax_gt.application_id = lines_gt.applied_from_application_id
         AND tax_gt.entity_code = lines_gt.applied_from_entity_code
         AND tax_gt.event_class_code = lines_gt.applied_from_event_class_code
         AND tax_gt.trx_id = lines_gt.applied_from_trx_id
         AND tax_gt.tax_regime_code = taxlines_gt.tax_regime_code
         AND tax_gt.tax = taxlines_gt.tax
         AND --All Alloc
              (tax_gt.trx_line_id IS NULL AND
               tax_gt.tax_line_allocation_flag = 'N' AND
               EXISTS (SELECT 1
                       FROM zx_transaction_lines_gt trans_line_gt
                       WHERE trans_line_gt.trx_id         = tax_gt.trx_id
                       AND trans_line_gt.application_id   = tax_gt.application_id
                       AND trans_line_gt.entity_code = tax_gt.entity_code
                       AND trans_line_gt.event_class_code = tax_gt.event_class_code
                       AND trans_line_gt.trx_level_type = lines_gt.applied_from_trx_level_type
                       AND trans_line_gt.trx_line_id = lines_gt.applied_from_line_id)
              )
        )
         THEN
             'Y'
         ELSE
             'N'
      END ZX_TAX_MISSING_IN_APPLIED_FRM,

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
	    AND zl.tax_status_code = taxlines_gt.tax_status_code
	    AND zl.tax_rate_code = taxlines_gt.tax_rate_code
	    AND NVL(zl.tax_jurisdiction_code, 'X') = NVL(taxlines_gt.tax_jurisdiction_code, 'X')
	    AND zl.tax_rate = taxlines_gt.tax_rate
        )
          AND NOT EXISTS
        (
         SELECT 1
         FROM   zx_import_tax_lines_gt  tax_gt
         WHERE tax_gt.application_id = lines_gt.adjusted_doc_application_id
         AND tax_gt.entity_code = lines_gt.adjusted_doc_entity_code
         AND tax_gt.event_class_code = lines_gt.adjusted_doc_event_class_code
         AND tax_gt.trx_id = lines_gt.adjusted_doc_trx_id
         AND tax_gt.tax_regime_code = taxlines_gt.tax_regime_code
         AND tax_gt.tax = taxlines_gt.tax
	 AND tax_gt.tax_status_code = taxlines_gt.tax_status_code
	 AND tax_gt.tax_rate_code = taxlines_gt.tax_rate_code
	 AND NVL(tax_gt.tax_jurisdiction_code, 'X') = NVL(taxlines_gt.tax_jurisdiction_code, 'X')
	 AND tax_gt.tax_rate = taxlines_gt.tax_rate
         AND --One to One Alloc
            (tax_gt.trx_line_id = lines_gt.adjusted_doc_line_id)
         UNION ALL
         SELECT 1
         FROM   zx_import_tax_lines_gt  tax_gt
         WHERE tax_gt.application_id = lines_gt.adjusted_doc_application_id
         AND tax_gt.entity_code = lines_gt.adjusted_doc_entity_code
         AND tax_gt.event_class_code = lines_gt.adjusted_doc_event_class_code
         AND tax_gt.trx_id = lines_gt.adjusted_doc_trx_id
         AND tax_gt.tax_regime_code = taxlines_gt.tax_regime_code
         AND tax_gt.tax = taxlines_gt.tax
	 AND tax_gt.tax_status_code = taxlines_gt.tax_status_code
	 AND tax_gt.tax_rate_code = taxlines_gt.tax_rate_code
	 AND NVL(tax_gt.tax_jurisdiction_code, 'X') = NVL(taxlines_gt.tax_jurisdiction_code, 'X')
	 AND tax_gt.tax_rate = taxlines_gt.tax_rate
	       AND --Multi Alloc
              (tax_gt.trx_line_id IS NULL AND
               tax_gt.tax_line_allocation_flag = 'Y' AND
               EXISTS (SELECT 1
                       FROM zx_trx_tax_link_gt link_gt
                       WHERE link_gt.trx_id = tax_gt.trx_id
                       AND link_gt.application_id   = tax_gt.application_id
                       AND link_gt.entity_code      = tax_gt.entity_code
                       AND link_gt.event_class_code = tax_gt.event_class_code
                       AND link_gt.summary_tax_line_number = tax_gt.summary_tax_line_number
                       AND link_gt.trx_level_type = lines_gt.adjusted_doc_trx_level_type
                       AND link_gt.trx_line_id = lines_gt.adjusted_doc_line_id)
              )
         UNION ALL
         SELECT 1
         FROM   zx_import_tax_lines_gt  tax_gt
         WHERE tax_gt.application_id = lines_gt.adjusted_doc_application_id
         AND tax_gt.entity_code = lines_gt.adjusted_doc_entity_code
         AND tax_gt.event_class_code = lines_gt.adjusted_doc_event_class_code
         AND tax_gt.trx_id = lines_gt.adjusted_doc_trx_id
         AND tax_gt.tax_regime_code = taxlines_gt.tax_regime_code
         AND tax_gt.tax = taxlines_gt.tax
	 AND tax_gt.tax_status_code = taxlines_gt.tax_status_code
	 AND tax_gt.tax_rate_code = taxlines_gt.tax_rate_code
	 AND NVL(tax_gt.tax_jurisdiction_code, 'X') = NVL(taxlines_gt.tax_jurisdiction_code, 'X')
	 AND tax_gt.tax_rate = taxlines_gt.tax_rate
	       AND  --All Alloc
              (tax_gt.trx_line_id IS NULL AND
               tax_gt.tax_line_allocation_flag = 'N' AND
               EXISTS (SELECT 1
                       FROM zx_transaction_lines_gt trans_line_gt
                       WHERE trans_line_gt.trx_id         = tax_gt.trx_id
                       AND trans_line_gt.application_id   = tax_gt.application_id
                       AND trans_line_gt.entity_code = tax_gt.entity_code
                       AND trans_line_gt.event_class_code = tax_gt.event_class_code
                       AND trans_line_gt.trx_level_type = lines_gt.adjusted_doc_trx_level_type
                       AND trans_line_gt.trx_line_id = lines_gt.adjusted_doc_line_id)
              )
        )
         THEN
             'Y'
         ELSE
             'N'
      END ZX_TAX_MISSING_IN_ADJUSTED_TO
FROM ZX_TRX_HEADERS_GT header,
      ZX_IMPORT_TAX_LINES_GT taxlines_gt,
      zx_transaction_lines_gt lines_gt
  WHERE taxlines_gt.trx_id = header.trx_id
      AND taxlines_gt.application_id = Header.application_id
      AND taxlines_gt.entity_code = Header.entity_code
      AND taxlines_gt.event_class_code = Header.event_class_code
      AND lines_gt.application_id = header.application_id
      AND lines_gt.entity_code = header.entity_code
      AND lines_gt.event_class_code = header.event_class_code
      AND lines_gt.trx_id = header.trx_id
      AND
      --Multi Alloc
      (
        taxlines_gt.trx_line_id IS NULL
        AND taxlines_gt.tax_line_allocation_flag = 'Y'
        AND lines_gt.trx_line_id =
        (
        SELECT /*+ index(link_gt ZX_TRX_TAX_LINK_GT_U1) */
      MIN(trx_line_id)
        FROM zx_trx_tax_link_gt link_gt
        WHERE link_gt.TRX_ID = taxlines_gt.trx_id
      AND link_gt.application_id = taxlines_gt.application_id
      AND link_gt.entity_code = taxlines_gt.entity_code
      AND link_gt.event_class_code = taxlines_gt.event_class_code
      AND link_gt.summary_tax_line_number = taxlines_gt.summary_tax_line_number
        )
      );

INSERT ALL
WHEN (SAMETAX_MULTIALLOC_TO_SAMELN = 'Y') THEN

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
         interface_tax_entity_code,
         interface_tax_line_id
          )
        VALUES (
         application_id,
         entity_code,
         event_class_code,
         trx_id,
         trx_line_id,
         summary_tax_line_number,
         'ZX_TAX_MULTIALLOC_TO_SAMELN',
         l_tax_multialloc_to_sameln,
         trx_level_type,
         interface_tax_entity_code,
         interface_tax_line_id
         )
      WHEN (TAX_ONLY_LINE_MULTI_ALLOCATED = 'Y') THEN

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
         interface_tax_entity_code,
         interface_tax_line_id
         )
        VALUES (
         application_id,
         entity_code,
         event_class_code,
         trx_id,
         trx_line_id,
         summary_tax_line_number,
         'ZX_TAX_ONLY_LINE_MULTI_ALLOCAT',
         l_tax_only_line_multi_allocate,
         trx_level_type,
         interface_tax_entity_code,
         interface_tax_line_id
         )
      WHEN (PSEUDO_LINE_HAS_MULTI_TAXALLOC = 'Y') THEN

        INTO zx_validation_errors_gt(
         application_id,
         entity_code,
         event_class_code,
         trx_id,
         trx_line_id,
         --summary_tax_line_number,
         message_name,
         message_text,
         trx_level_type,
         interface_line_entity_code,
         interface_line_id
          )
        VALUES (
         application_id,
         entity_code,
         event_class_code,
         trx_id,
         trx_line_id,
         --summary_tax_line_number,
         'ZX_PSEUDO_LINE_HAS_MULTI_TAX',
         l_pseudo_line_has_multi_taxall,
         trx_level_type,
         interface_line_entity_code,
         interface_line_id
         )
      WHEN (ZX_TAX_MISSING_IN_APPLIED_FRM = 'Y') THEN

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
         interface_tax_entity_code,
         interface_tax_line_id
          )
          VALUES(
         application_id,
         entity_code,
         event_class_code,
         trx_id,
         trx_line_id,
         summary_tax_line_number,
         'ZX_TAX_MISSING_IN_APPLIED_FRM',
         l_imp_tax_missing_in_appld_frm,
         trx_level_type,
         interface_tax_entity_code,
         interface_tax_line_id
         )

      WHEN (ZX_TAX_MISSING_IN_ADJUSTED_TO = 'Y') THEN

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
         interface_tax_entity_code,
         interface_tax_line_id
          )
          VALUES(
         application_id,
         entity_code,
         event_class_code,
         trx_id,
         trx_line_id,
         summary_tax_line_number,
         'ZX_TAX_MISSING_IN_ADJUSTED_TO',
         l_imp_tax_missing_in_adjust_to,
         trx_level_type,
         interface_tax_entity_code,
         interface_tax_line_id
         )
  SELECT /*+ leading(taxlines_gt) */ header.application_id,
      header.entity_code,
      header.event_class_code,
      header.trx_id,
      taxlines_gt.summary_tax_line_number,
      taxlines_gt.summary_tax_line_number interface_tax_line_id,
      taxlines_gt.entity_code             interface_tax_entity_code,
      lines_gt.trx_line_id     interface_line_id,
      lines_gt.entity_code     interface_line_entity_code,
      lines_gt.trx_line_id,
      lines_gt.trx_level_type,
      -- The same tax regime and tax cannot be allocated to the same
      -- transaction line multi times
      --
            CASE
        WHEN  taxlines_gt.tax_regime_code IS NOT NULL AND
         taxlines_gt.tax IS NOT NULL AND
         -- split the complex Or condition here into multiple selects with Union all.
         EXISTS
        (SELECT /*+ INDEX(imptaxes_gt1 ZX_IMPORT_TAX_LINES_GT_U1) */
                1
           FROM zx_import_tax_lines_gt imptaxes_gt1
          WHERE imptaxes_gt1.application_id= taxlines_gt.application_id
            AND imptaxes_gt1.entity_code = taxlines_gt.entity_code
            AND imptaxes_gt1.event_class_code = taxlines_gt.event_class_code
            AND imptaxes_gt1.trx_id = taxlines_gt.trx_id
            AND imptaxes_gt1.summary_tax_line_number <> taxlines_gt.summary_tax_line_number
            AND imptaxes_gt1.tax_regime_code = taxlines_gt.tax_regime_code
            AND imptaxes_gt1.tax = taxlines_gt.tax
            AND --imptaxes_gt1 is all alloc
                (imptaxes_gt1.trx_line_id IS NULL AND
                 imptaxes_gt1.tax_line_allocation_flag = 'N')
            UNION ALL
            SELECT /*+ INDEX(imptaxes_gt1 ZX_IMPORT_TAX_LINES_GT_U1) */
                   1
           FROM zx_import_tax_lines_gt imptaxes_gt1
          WHERE imptaxes_gt1.application_id= taxlines_gt.application_id
            AND imptaxes_gt1.entity_code = taxlines_gt.entity_code
            AND imptaxes_gt1.event_class_code = taxlines_gt.event_class_code
            AND imptaxes_gt1.trx_id = taxlines_gt.trx_id
            AND imptaxes_gt1.summary_tax_line_number <> taxlines_gt.summary_tax_line_number
            AND imptaxes_gt1.tax_regime_code = taxlines_gt.tax_regime_code
            AND imptaxes_gt1.tax = taxlines_gt.tax
            AND --taxlines_gt is all alloc
                (taxlines_gt.trx_line_id IS NULL AND
                 taxlines_gt.tax_line_allocation_flag = 'N')
            UNION ALL
            SELECT /*+ INDEX(imptaxes_gt1 ZX_IMPORT_TAX_LINES_GT_U1) */
                   1
           FROM zx_import_tax_lines_gt imptaxes_gt1
          WHERE imptaxes_gt1.application_id= taxlines_gt.application_id
            AND imptaxes_gt1.entity_code = taxlines_gt.entity_code
            AND imptaxes_gt1.event_class_code = taxlines_gt.event_class_code
            AND imptaxes_gt1.trx_id = taxlines_gt.trx_id
            AND imptaxes_gt1.summary_tax_line_number <> taxlines_gt.summary_tax_line_number
            AND imptaxes_gt1.tax_regime_code = taxlines_gt.tax_regime_code
            AND imptaxes_gt1.tax = taxlines_gt.tax
            AND (--imptaxes_gt1 is one to one alloc
                  ( imptaxes_gt1.trx_line_id IS NOT NULL AND
                    ( --taxlines_gt is one to one alloc
                      (imptaxes_gt1.trx_line_id = taxlines_gt.trx_line_id)
                       OR
                      --taxlines_gt is multi alloc
                      (taxlines_gt.trx_line_id IS NULL AND
                       taxlines_gt.tax_line_allocation_flag = 'Y' AND
                       EXISTS (SELECT 1
                               FROM zx_trx_tax_link_gt link_gt
                               WHERE link_gt.trx_id         = taxlines_gt.trx_id
                               AND link_gt.application_id   = taxlines_gt.application_id
                               AND link_gt.entity_code      = taxlines_gt.entity_code
                               AND link_gt.event_class_code = taxlines_gt.event_class_code
                               AND link_gt.summary_tax_line_number = taxlines_gt.summary_tax_line_number
                               AND link_gt.trx_line_id = imptaxes_gt1.trx_line_id))
                    )
                  )
                )
            UNION ALL
            SELECT /*+ INDEX(imptaxes_gt1 ZX_IMPORT_TAX_LINES_GT_U1) */
                   1
           FROM zx_import_tax_lines_gt imptaxes_gt1
          WHERE imptaxes_gt1.application_id= taxlines_gt.application_id
            AND imptaxes_gt1.entity_code = taxlines_gt.entity_code
            AND imptaxes_gt1.event_class_code = taxlines_gt.event_class_code
            AND imptaxes_gt1.trx_id = taxlines_gt.trx_id
            AND imptaxes_gt1.summary_tax_line_number <> taxlines_gt.summary_tax_line_number
            AND imptaxes_gt1.tax_regime_code = taxlines_gt.tax_regime_code
            AND imptaxes_gt1.tax = taxlines_gt.tax
            AND --imptaxes_gt1 is multi-alloc
                (imptaxes_gt1.trx_line_id IS NULL AND
                   imptaxes_gt1.tax_line_allocation_flag = 'Y' AND
                   ( --taxlines_gt is one to one alloc
                     (taxlines_gt.trx_line_id IS NOT NULL AND
                      EXISTS (SELECT 1
                              FROM zx_trx_tax_link_gt link_gt
                              WHERE link_gt.trx_id         = imptaxes_gt1.trx_id
                              AND link_gt.application_id   = imptaxes_gt1.application_id
                              AND link_gt.entity_code      = imptaxes_gt1.entity_code
                              AND link_gt.event_class_code = imptaxes_gt1.event_class_code
                              AND link_gt.summary_tax_line_number = imptaxes_gt1.summary_tax_line_number
                              AND link_gt.trx_line_id = taxlines_gt.trx_line_id))
                     )
                )
             UNION ALL
             SELECT /*+ INDEX(imptaxes_gt1 ZX_IMPORT_TAX_LINES_GT_U1) */
                    1
             FROM zx_import_tax_lines_gt imptaxes_gt1
            WHERE imptaxes_gt1.application_id= taxlines_gt.application_id
              AND imptaxes_gt1.entity_code = taxlines_gt.entity_code
              AND imptaxes_gt1.event_class_code = taxlines_gt.event_class_code
              AND imptaxes_gt1.trx_id = taxlines_gt.trx_id
              AND imptaxes_gt1.summary_tax_line_number <> taxlines_gt.summary_tax_line_number
              AND imptaxes_gt1.tax_regime_code = taxlines_gt.tax_regime_code
              AND imptaxes_gt1.tax = taxlines_gt.tax
              AND --taxlines_gt is multi alloc
                  (taxlines_gt.trx_line_id IS NULL AND
                   taxlines_gt.tax_line_allocation_flag = 'Y' AND
                   EXISTS (SELECT 1
                           FROM zx_trx_tax_link_gt link_gt1,
                                zx_trx_tax_link_gt link_gt2
                           WHERE link_gt1.trx_id = imptaxes_gt1.trx_id
                           AND link_gt1.application_id   = imptaxes_gt1.application_id
                           AND link_gt1.entity_code      = imptaxes_gt1.entity_code
                           AND link_gt1.event_class_code = imptaxes_gt1.event_class_code
                           AND link_gt1.summary_tax_line_number = imptaxes_gt1.summary_tax_line_number
                           AND link_gt1.trx_line_id = imptaxes_gt1.trx_line_id
                           AND link_gt2.trx_id = taxlines_gt.trx_id
                           AND link_gt2.application_id   = taxlines_gt.application_id
                           AND link_gt2.entity_code      = taxlines_gt.entity_code
                           AND link_gt2.event_class_code = taxlines_gt.event_class_code
                           AND link_gt2.summary_tax_line_number = taxlines_gt.summary_tax_line_number
                           AND link_gt2.trx_line_id = taxlines_gt.trx_line_id
                           AND link_gt2.trx_line_id = link_gt1.trx_line_id
                          )
                 )
          )
         THEN
             'Y'
         ELSE
             'N'
        END SAMETAX_MULTIALLOC_TO_SAMELN,

       -- Each tax only tax line can only be allocated to one pseudo trx line
       --
       CASE
         WHEN lines_gt.line_level_action = 'LINE_INFO_TAX_ONLY'
          AND EXISTS
        (SELECT /*+ INDEX(zx_trx_tax_link_gt ZX_TRX_TAX_LINK_GT_U1) */
          1
           FROM zx_trx_tax_link_gt
          WHERE application_id = taxlines_gt.application_id
            AND entity_code = taxlines_gt.entity_code
            AND event_class_code = taxlines_gt.event_class_code
            AND trx_id = taxlines_gt.trx_id
            AND summary_tax_line_number =
               taxlines_gt.summary_tax_line_number
            AND (trx_line_id <> lines_gt.trx_line_id OR
           trx_level_type <> lines_gt.trx_level_type)
        )
          THEN
        'Y'
          ELSE
        'N'
       END TAX_ONLY_LINE_MULTI_ALLOCATED,

       -- Each pseudo trx line can only be allocated with one tax_only tax line
       --
       CASE
         WHEN lines_gt.line_level_action = 'LINE_INFO_TAX_ONLY'
          AND EXISTS
        (SELECT /*+ INDEX(zx_trx_tax_link_gt ZX_TRX_TAX_LINK_GT_U1) */
          1
           FROM zx_trx_tax_link_gt
          WHERE application_id = taxlines_gt.application_id
            AND entity_code = taxlines_gt.entity_code
            AND event_class_code = taxlines_gt.event_class_code
            AND trx_id = taxlines_gt.trx_id
            AND summary_tax_line_number <>
                  taxlines_gt.summary_tax_line_number
            AND trx_line_id = lines_gt.trx_line_id
            AND trx_level_type = lines_gt.trx_level_type
        )
         THEN
            'Y'
         ELSE
            'N'
       END PSEUDO_LINE_HAS_MULTI_TAXALLOC,
      -- Bug 3676878: Imported tax lines found missing in other document
      --
      CASE
         WHEN lines_gt.applied_from_application_id IS NOT NULL
          AND NOT EXISTS
        (SELECT 1
           FROM zx_lines zl
          WHERE zl.application_id = lines_gt.applied_from_application_id
            AND zl.entity_code = lines_gt.applied_from_entity_code
            AND zl.event_class_code = lines_gt.applied_from_event_class_code
            AND zl.trx_id = lines_gt.applied_from_trx_id
            AND zl.trx_line_id = lines_gt.applied_from_line_id
            AND zl.trx_level_type = lines_gt.applied_from_trx_level_type
            AND zl.tax_regime_code = taxlines_gt.tax_regime_code
            AND zl.tax = taxlines_gt.tax
        )
          AND NOT EXISTS
          -- split the complex OR conditions into 3 queries with Union all.
        (SELECT 1
         FROM   zx_import_tax_lines_gt  tax_gt
         WHERE tax_gt.application_id = lines_gt.applied_from_application_id
         AND tax_gt.entity_code = lines_gt.applied_from_entity_code
         AND tax_gt.event_class_code = lines_gt.applied_from_event_class_code
         AND tax_gt.trx_id = lines_gt.applied_from_trx_id
         AND tax_gt.tax_regime_code = taxlines_gt.tax_regime_code
         AND tax_gt.tax = taxlines_gt.tax
         AND --One to One Alloc
              (tax_gt.trx_line_id = lines_gt.applied_from_line_id)
         UNION ALL
         SELECT 1
         FROM   zx_import_tax_lines_gt  tax_gt
         WHERE tax_gt.application_id = lines_gt.applied_from_application_id
         AND tax_gt.entity_code = lines_gt.applied_from_entity_code
         AND tax_gt.event_class_code = lines_gt.applied_from_event_class_code
         AND tax_gt.trx_id = lines_gt.applied_from_trx_id
         AND tax_gt.tax_regime_code = taxlines_gt.tax_regime_code
         AND tax_gt.tax = taxlines_gt.tax
         AND  --Multi Alloc
              (tax_gt.trx_line_id IS NULL AND
               tax_gt.tax_line_allocation_flag = 'Y' AND
               EXISTS (SELECT 1
                       FROM zx_trx_tax_link_gt link_gt
                       WHERE link_gt.trx_id = tax_gt.trx_id
                       AND link_gt.application_id   = tax_gt.application_id
                       AND link_gt.entity_code      = tax_gt.entity_code
                       AND link_gt.event_class_code = tax_gt.event_class_code
                       AND link_gt.summary_tax_line_number = tax_gt.summary_tax_line_number
                       AND link_gt.trx_level_type = lines_gt.applied_from_trx_level_type
                       AND link_gt.trx_line_id = lines_gt.applied_from_line_id)
              )
         UNION ALL
         SELECT 1
         FROM   zx_import_tax_lines_gt  tax_gt
         WHERE tax_gt.application_id = lines_gt.applied_from_application_id
         AND tax_gt.entity_code = lines_gt.applied_from_entity_code
         AND tax_gt.event_class_code = lines_gt.applied_from_event_class_code
         AND tax_gt.trx_id = lines_gt.applied_from_trx_id
         AND tax_gt.tax_regime_code = taxlines_gt.tax_regime_code
         AND tax_gt.tax = taxlines_gt.tax
         AND --All Alloc
              (tax_gt.trx_line_id IS NULL AND
               tax_gt.tax_line_allocation_flag = 'N' AND
               EXISTS (SELECT 1
                       FROM zx_transaction_lines_gt trans_line_gt
                       WHERE trans_line_gt.trx_id         = tax_gt.trx_id
                       AND trans_line_gt.application_id   = tax_gt.application_id
                       AND trans_line_gt.entity_code = tax_gt.entity_code
                       AND trans_line_gt.event_class_code = tax_gt.event_class_code
                       AND trans_line_gt.trx_level_type = lines_gt.applied_from_trx_level_type
                       AND trans_line_gt.trx_line_id = lines_gt.applied_from_line_id)
              )
        )
         THEN
             'Y'
         ELSE
             'N'
      END ZX_TAX_MISSING_IN_APPLIED_FRM,

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
	    AND zl.tax_status_code = taxlines_gt.tax_status_code
	    AND zl.tax_rate_code = taxlines_gt.tax_rate_code
	    AND NVL(zl.tax_jurisdiction_code, 'X') = NVL(taxlines_gt.tax_jurisdiction_code, 'X')
	    AND zl.tax_rate = taxlines_gt.tax_rate
        )
          AND NOT EXISTS
        (
         SELECT 1
         FROM   zx_import_tax_lines_gt  tax_gt
         WHERE tax_gt.application_id = lines_gt.adjusted_doc_application_id
         AND tax_gt.entity_code = lines_gt.adjusted_doc_entity_code
         AND tax_gt.event_class_code = lines_gt.adjusted_doc_event_class_code
         AND tax_gt.trx_id = lines_gt.adjusted_doc_trx_id
         AND tax_gt.tax_regime_code = taxlines_gt.tax_regime_code
         AND tax_gt.tax = taxlines_gt.tax
	 AND tax_gt.tax_status_code = taxlines_gt.tax_status_code
	 AND tax_gt.tax_rate_code = taxlines_gt.tax_rate_code
	 AND NVL(tax_gt.tax_jurisdiction_code, 'X') = NVL(taxlines_gt.tax_jurisdiction_code, 'X')
	 AND tax_gt.tax_rate = taxlines_gt.tax_rate
         AND --One to One Alloc
            (tax_gt.trx_line_id = lines_gt.adjusted_doc_line_id)
         UNION ALL
         SELECT 1
         FROM   zx_import_tax_lines_gt  tax_gt
         WHERE tax_gt.application_id = lines_gt.adjusted_doc_application_id
         AND tax_gt.entity_code = lines_gt.adjusted_doc_entity_code
         AND tax_gt.event_class_code = lines_gt.adjusted_doc_event_class_code
         AND tax_gt.trx_id = lines_gt.adjusted_doc_trx_id
         AND tax_gt.tax_regime_code = taxlines_gt.tax_regime_code
         AND tax_gt.tax = taxlines_gt.tax
	 AND tax_gt.tax_status_code = taxlines_gt.tax_status_code
	 AND tax_gt.tax_rate_code = taxlines_gt.tax_rate_code
	 AND NVL(tax_gt.tax_jurisdiction_code, 'X') = NVL(taxlines_gt.tax_jurisdiction_code, 'X')
	 AND tax_gt.tax_rate = taxlines_gt.tax_rate
	       AND --Multi Alloc
              (tax_gt.trx_line_id IS NULL AND
               tax_gt.tax_line_allocation_flag = 'Y' AND
               EXISTS (SELECT 1
                       FROM zx_trx_tax_link_gt link_gt
                       WHERE link_gt.trx_id = tax_gt.trx_id
                       AND link_gt.application_id   = tax_gt.application_id
                       AND link_gt.entity_code      = tax_gt.entity_code
                       AND link_gt.event_class_code = tax_gt.event_class_code
                       AND link_gt.summary_tax_line_number = tax_gt.summary_tax_line_number
                       AND link_gt.trx_level_type = lines_gt.adjusted_doc_trx_level_type
                       AND link_gt.trx_line_id = lines_gt.adjusted_doc_line_id)
              )
         UNION ALL
         SELECT 1
         FROM   zx_import_tax_lines_gt  tax_gt
         WHERE tax_gt.application_id = lines_gt.adjusted_doc_application_id
         AND tax_gt.entity_code = lines_gt.adjusted_doc_entity_code
         AND tax_gt.event_class_code = lines_gt.adjusted_doc_event_class_code
         AND tax_gt.trx_id = lines_gt.adjusted_doc_trx_id
         AND tax_gt.tax_regime_code = taxlines_gt.tax_regime_code
         AND tax_gt.tax = taxlines_gt.tax
	 AND tax_gt.tax_status_code = taxlines_gt.tax_status_code
	 AND tax_gt.tax_rate_code = taxlines_gt.tax_rate_code
	 AND NVL(tax_gt.tax_jurisdiction_code, 'X') = NVL(taxlines_gt.tax_jurisdiction_code, 'X')
	 AND tax_gt.tax_rate = taxlines_gt.tax_rate
	       AND  --All Alloc
              (tax_gt.trx_line_id IS NULL AND
               tax_gt.tax_line_allocation_flag = 'N' AND
               EXISTS (SELECT 1
                       FROM zx_transaction_lines_gt trans_line_gt
                       WHERE trans_line_gt.trx_id         = tax_gt.trx_id
                       AND trans_line_gt.application_id   = tax_gt.application_id
                       AND trans_line_gt.entity_code = tax_gt.entity_code
                       AND trans_line_gt.event_class_code = tax_gt.event_class_code
                       AND trans_line_gt.trx_level_type = lines_gt.adjusted_doc_trx_level_type
                       AND trans_line_gt.trx_line_id = lines_gt.adjusted_doc_line_id)
              )
        )
         THEN
             'Y'
         ELSE
             'N'
      END ZX_TAX_MISSING_IN_ADJUSTED_TO
FROM ZX_TRX_HEADERS_GT header,
      ZX_IMPORT_TAX_LINES_GT taxlines_gt,
      zx_transaction_lines_gt lines_gt
  WHERE taxlines_gt.trx_id = header.trx_id
      AND taxlines_gt.application_id = Header.application_id
      AND taxlines_gt.entity_code = Header.entity_code
      AND taxlines_gt.event_class_code = Header.event_class_code
      AND lines_gt.application_id = header.application_id
      AND lines_gt.entity_code = header.entity_code
      AND lines_gt.event_class_code = header.event_class_code
      AND lines_gt.trx_id = header.trx_id
      AND
    --All Alloc
    (
        taxlines_gt.trx_line_id IS NULL
        AND taxlines_gt.tax_line_allocation_flag = 'N'
        AND lines_gt.trx_line_id =
        (
        SELECT /*+ index(trans_line_gt ZX_TRANSACTION_LINES_GT_U1) */
      MIN(trx_line_id)
        FROM zx_transaction_lines_gt trans_line_gt
        WHERE trans_line_gt.trx_id = taxlines_gt.trx_id
      AND trans_line_gt.application_id = taxlines_gt.application_id
      AND trans_line_gt.entity_code = taxlines_gt.entity_code
      AND trans_line_gt.event_class_code = taxlines_gt.event_class_code
        )
    );


  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF ( g_level_statement >= g_current_runtime_level) THEN
    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'No. of Rows inserted for Import Tax Line Validations : Regime,Tax,Status '|| to_char(sql%ROWCOUNT) );
  END IF;

-- Bug 5018766
  INSERT ALL
    WHEN (REG_SUBSCR_NOT_EFFECTIVE = 'Y') THEN

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
        interface_tax_entity_code,
        interface_tax_line_id
        )
      VALUES(
        application_id,
        entity_code,
        event_class_code,
        trx_id,
        NULL,
        summary_tax_line_number,
        'ZX_REGIME_NOT_EFF_IN_SUBSCR',
        l_regime_not_eff_in_subscrptn,
        NULL,
        interface_tax_entity_code,
        interface_tax_line_id
         )
    WHEN (TAX_SUBSCR_NOT_EFFECTIVE = 'Y')  THEN
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
          interface_tax_entity_code,
          interface_tax_line_id
          )
        VALUES(
          application_id,
          entity_code,
          event_class_code,
          trx_id,
          NULL,
          summary_tax_line_number,
          'ZX_TAX_NOT_EFFECTIVE',
          l_tax_not_effective,
          NULL,
          interface_tax_entity_code,
          interface_tax_line_id
           )
    WHEN (STATUS_SUBSCR_NOT_EFFECTIVE = 'Y')  THEN

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
          interface_tax_entity_code,
          interface_tax_line_id
          )
        VALUES(
          application_id,
          entity_code,
          event_class_code,
          trx_id,
          NULL,
          summary_tax_line_number,
          'ZX_TAX_STATUS_NOT_EFFECTIVE',
          l_tax_status_not_effective,
          NULL,
          interface_tax_entity_code,
          interface_tax_line_id
           )
    SELECT /*+ leading(taxlines_gt) */
      header.application_id,
      header.entity_code,
      header.event_class_code,
      header.trx_id,
      taxlines_gt.summary_tax_line_number,
      taxlines_gt.summary_tax_line_number interface_tax_line_id,
      taxlines_gt.entity_code             interface_tax_entity_code,
      --lines_gt.trx_line_id     interface_line_id,
      --lines_gt.entity_code     interface_line_entity_code,
      --lines_gt.trx_line_id,
      --lines_gt.trx_level_type,
      null     interface_line_id,
      null     interface_line_entity_code,
      null     trx_line_id,
      null     trx_level_type,
            --regime effectivity
             CASE WHEN taxlines_gt.TAX_REGIME_CODE IS NOT NULL AND REGIME.TAX_REGIME_CODE IS NOT NULL
       THEN
          CASE WHEN (   SD_REG.TAX_REGIME_CODE IS NULL
            OR
            ( taxlines_gt.subscription_date NOT BETWEEN
                  NVL(sd_REG.effective_from,taxlines_gt.subscription_date)
                  AND NVL(sd_REG.effective_to, taxlines_gt.subscription_date)
              AND NOT EXISTS (
                SELECT 1 FROM ZX_SUBSCRIPTION_DETAILS ZSD
                  WHERE ZSD.TAX_REGIME_CODE = REGIME.TAX_REGIME_CODE
                  AND ZSD.FIRST_PTY_ORG_ID = g_first_pty_org_id
                  AND taxlines_gt.subscription_date BETWEEN
                     NVL(ZSD.effective_from,taxlines_gt.subscription_date)
                     AND NVL(ZSD.effective_to, taxlines_gt.subscription_date)

                   )
            )
              ) THEN 'Y' ELSE 'N' END
      ELSE 'N' END REG_SUBSCR_NOT_EFFECTIVE,
      --tax effectivty
             CASE WHEN taxlines_gt.tax IS NOT NULL AND TAX.TAX IS NOT NULL
       THEN
          CASE WHEN (   SD_TAX.TAX_REGIME_CODE IS NULL
            OR
            (
            taxlines_gt.subscription_date NOT BETWEEN
              NVL(sd_tax.effective_from,taxlines_gt.subscription_date)
              AND NVL(sd_tax.effective_to, taxlines_gt.subscription_date)
              AND NOT EXISTS (
                SELECT 1 FROM ZX_SUBSCRIPTION_DETAILS ZSD
                  WHERE ZSD.TAX_REGIME_CODE = tax.TAX_REGIME_CODE
                  AND ZSD.parent_first_pty_org_id = tax.content_owner_id
                  AND ZSD.FIRST_PTY_ORG_ID =  g_first_pty_org_id
                  AND taxlines_gt.subscription_date BETWEEN
                     NVL(ZSD.effective_from,taxlines_gt.subscription_date)
                     AND NVL(ZSD.effective_to, taxlines_gt.subscription_date)
                   )
            )
              ) THEN 'Y' ELSE 'N' END
      ELSE 'N' END TAX_SUBSCR_NOT_EFFECTIVE,
      --status effectivty
             CASE WHEN taxlines_gt.tax_status_code IS NOT NULL AND status.tax_status_code IS NOT NULL
       THEN
          CASE WHEN (   SD_status.TAX_REGIME_CODE IS NULL
            OR
            (
            taxlines_gt.subscription_date NOT BETWEEN
              NVL(sd_status.effective_from,taxlines_gt.subscription_date)
              AND NVL(sd_status.effective_to, taxlines_gt.subscription_date)
              AND NOT EXISTS (
                SELECT 1 FROM ZX_SUBSCRIPTION_DETAILS ZSD
                  WHERE ZSD.TAX_REGIME_CODE = status.TAX_REGIME_CODE
                  AND ZSD.parent_first_pty_org_id = status.content_owner_id
                  AND ZSD.FIRST_PTY_ORG_ID =  g_first_pty_org_id
                  AND taxlines_gt.subscription_date BETWEEN
                     NVL(ZSD.effective_from,taxlines_gt.subscription_date)
                     AND NVL(ZSD.effective_to, taxlines_gt.subscription_date)
                   )
            )
              ) THEN 'Y' ELSE 'N' END
      ELSE 'N' END STATUS_SUBSCR_NOT_EFFECTIVE
        from
      zx_trx_headers_gt header,
      --zx_transaction_lines_gt lines_gt,
      ZX_IMPORT_TAX_LINES_GT taxlines_gt,
      ZX_REGIMES_B regime ,
      ZX_TAXES_B tax ,
      ZX_STATUS_B status ,
      zx_subscription_details sd_reg,
      zx_subscription_details sd_tax,
      zx_subscription_details sd_status
    where   taxlines_gt.trx_id = header.trx_id
      AND taxlines_gt.application_id = header.application_id
      AND taxlines_gt.entity_code = header.entity_code
      AND taxlines_gt.event_class_code = header.event_class_code
      --AND lines_gt.application_id = header.application_id
      --AND lines_gt.entity_code = header.entity_code
      --AND lines_gt.event_class_code = header.event_class_code
      --AND lines_gt.trx_id = header.trx_id
      --AND
      --(-- One to One Alloc
  --  (
   --     lines_gt.trx_line_id = taxlines_gt.trx_line_id
   -- )
   -- OR
    --Multi Alloc
    --(
        --taxlines_gt.trx_line_id IS NULL
        --AND taxlines_gt.tax_line_allocation_flag = 'Y'
        --AND lines_gt.trx_line_id =
        --(
        --SELECT
      --MIN(trx_line_id)
        --FROM zx_trx_tax_link_gt link_gt
        --WHERE link_gt.TRX_ID = taxlines_gt.trx_id
      --AND link_gt.application_id = taxlines_gt.application_id
      --AND link_gt.entity_code = taxlines_gt.entity_code
      --AND link_gt.event_class_code = taxlines_gt.event_class_code
      --AND link_gt.summary_tax_line_number = taxlines_gt.summary_tax_line_number
        --)
    --)
    --OR
    --All Alloc
    --(
        --taxlines_gt.trx_line_id IS NULL
        --AND taxlines_gt.tax_line_allocation_flag = 'N'
        --AND lines_gt.trx_line_id =
        --(
        --SELECT
      --MIN(trx_line_id)
        --FROM zx_transaction_lines_gt trans_line_gt
        --WHERE trans_line_gt.trx_id = taxlines_gt.trx_id
      --AND trans_line_gt.application_id = taxlines_gt.application_id
      --AND trans_line_gt.entity_code = taxlines_gt.entity_code
      --AND trans_line_gt.event_class_code = taxlines_gt.event_class_code
        --)
    --)
      --)
      --* for regime
      AND regime.tax_regime_code(+) = taxlines_gt.tax_regime_code
      AND regime.TAX_REGIME_CODE = sd_reg.tax_regime_code (+)
      --AND sd_reg.first_pty_org_id(+) = g_first_pty_org_id
      AND sd_reg.first_pty_org_id IN (g_first_pty_org_id, -99)
      AND nvl(sd_reg.view_options_code,'NONE') in ('NONE', 'VFC')
      --* for taxes
      AND tax.tax(+) = taxlines_gt.tax
            AND tax.tax_regime_code(+) = taxlines_gt.tax_regime_code
      AND tax.tax_regime_code = sd_tax.tax_regime_code (+)
      AND (
     tax.content_owner_id = sd_tax.parent_first_pty_org_id
     OR
     sd_tax.parent_first_pty_org_id is NULL
    )
      --AND sd_tax.first_pty_org_id(+) = g_first_pty_org_id
      AND sd_tax.first_pty_org_id IN (g_first_pty_org_id, -99)
      AND
      (
    nvl(sd_tax.view_options_code,'NONE') in ('NONE', 'VFC')
    OR
    (
        nvl(sd_tax.view_options_code,'VFR') = 'VFR'
        AND not exists
        (
        SELECT
      1
        FROM zx_taxes_b b
        WHERE tax.tax_regime_code = b.tax_regime_code
      AND tax.tax = b.tax
      AND sd_tax.first_pty_org_id = b.content_owner_id
        )
    )
      )
      --* for status
      AND status.tax_status_code(+) = taxlines_gt.tax_status_code
      AND status.tax(+) = taxlines_gt.tax
      AND status.tax_regime_code(+) = taxlines_gt.tax_regime_code
      AND status.tax_regime_code = sd_status.tax_regime_code (+)
      AND
         (
    status.content_owner_id = sd_status.parent_first_pty_org_id
    OR
     sd_status.parent_first_pty_org_id is NULL
         )
      --AND sd_status.first_pty_org_id(+) = g_first_pty_org_id
      AND sd_status.first_pty_org_id IN (g_first_pty_org_id, -99)
      AND
      (
    NVL(sd_status.view_options_code,'NONE') in ('NONE', 'VFC')
    OR
    (
        NVL(sd_status.view_options_code,'VFR') = 'VFR'
        AND not exists
        (
        SELECT
      1
        FROM zx_status_vl b
        WHERE b.tax_regime_code = status.tax_regime_code
      AND b.tax = status.tax
      AND b.tax_status_code = status.tax_status_code
      AND b.content_owner_id = sd_status.first_pty_org_id
        )
    )
      );

--Bug 5018766 : Delete any duplicate rows that might get inserted for that trx_id , trx_line_id from the above insert stmt.
  DELETE FROM ZX_VALIDATION_ERRORS_GT A
  WHERE A.ROWID < ( SELECT MAX(B.ROWID) FROM ZX_VALIDATION_ERRORS_GT B
      WHERE A.APPLICATION_ID = B.APPLICATION_ID
      AND A.ENTITY_CODE = B.ENTITY_CODE
      AND A.EVENT_CLASS_CODE = B.EVENT_CLASS_CODE
      AND A.TRX_ID = B.TRX_ID
      AND A.TRX_LINE_ID = B.TRX_LINE_ID
      AND A.TRX_LEVEL_TYPE = B.TRX_LEVEL_TYPE
      AND A.SUMMARY_TAX_LINE_NUMBER = B.SUMMARY_TAX_LINE_NUMBER
      AND A.MESSAGE_NAME = B.MESSAGE_NAME );

  IF ( g_level_statement >= g_current_runtime_level) THEN
    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'Before insertion into ZX_VALIDATION_ERRORS_GT for RateCode related Imported Tax Lines Validations');
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
                                interface_tax_entity_code,
                                interface_tax_line_id
                                )
                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                NULL,
                                summary_tax_line_number,
                                'ZX_TAX_RATE_CODE_NOT_EXIST', --4703541
                                l_tax_rate_code_not_exists,
                                NULL,
                                interface_tax_entity_code,
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
                                interface_tax_entity_code,
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
                                interface_tax_entity_code,
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
                                interface_tax_entity_code,
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
                                interface_tax_entity_code,
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
                                interface_tax_entity_code,
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
                                interface_tax_entity_code,
                                interface_tax_line_id
                                 )
        WHEN (TAX_RECOV_OR_OFFSET = 'Y')  THEN
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
                                interface_tax_entity_code,
                                interface_tax_line_id
                                )
                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                NULL,
                                summary_tax_line_number,
                                'ZX_TAX_RECOV_OR_OFFSET',
                                l_tax_recov_or_offset,
                                NULL,
                                interface_tax_entity_code,
                                interface_tax_line_id
                                 )
        WHEN (DEFAULT_RATE_CODE_NOT_EXISTS = 'Y')  THEN

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
                                interface_tax_entity_code,
                                interface_tax_line_id
                                )
                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                NULL,
                                summary_tax_line_number,
                                'ZX_DEFAULT_RATE_CODE_NOT_EXIST',
                                l_default_rate_code_not_exists,
                                NULL,
                                interface_tax_entity_code,
                                interface_tax_line_id
                                 )
  SELECT
    application_id,
    entity_code,
    event_class_code,
    trx_id,
    summary_tax_line_number,
    interface_tax_line_id,
    interface_tax_entity_code,
    interface_line_id,
    interface_line_entity_code,
    trx_line_id,
    trx_level_type,
    TAX_RATE_CODE_NOT_EXISTS,
    DECODE(TAX_RATE_CODE_NOT_EXISTS,'Y','N',TAX_RATE_CODE_NOT_EFFECTIVE) TAX_RATE_CODE_NOT_EFFECTIVE,
    DECODE(TAX_RATE_CODE_NOT_EXISTS,'Y','N',TAX_RATE_CODE_NOT_ACTIVE) TAX_RATE_CODE_NOT_ACTIVE,
    DECODE(TAX_RATE_CODE_NOT_EXISTS,'Y','N',TAX_RATE_PERCENTAGE_INVALID) TAX_RATE_PERCENTAGE_INVALID,
    DECODE(TAX_RATE_CODE_NOT_EXISTS,'Y','N',TAX_RECOV_OR_OFFSET) TAX_RECOV_OR_OFFSET,
    DECODE(TAX_RATE_CODE_NOT_EXISTS,'Y','N',DEFAULT_RATE_CODE_NOT_EXISTS) DEFAULT_RATE_CODE_NOT_EXISTS
  FROM
  (SELECT /*+ leading( TAXLINES_GT  RATE OFF_RATE) */
      header.application_id application_id,
      header.entity_code entity_code,
      header.event_class_code,
      header.trx_id trx_id,
      taxlines_gt.summary_tax_line_number summary_tax_line_number,
      taxlines_gt.summary_tax_line_number interface_tax_line_id,
      taxlines_gt.entity_code             interface_tax_entity_code,
      --lines_gt.trx_line_id     interface_line_id,
      --lines_gt.entity_code     interface_line_entity_code,
      --lines_gt.trx_line_id trx_line_id,
      --lines_gt.trx_level_type trx_level_type,
      null     interface_line_id,
      null     interface_line_entity_code,
      null     trx_line_id,
      null     trx_level_type,
      -- Check for Rate Code Existence
      --Bug 4703541
      CASE WHEN (sd_rates.tax_regime_code is not null and
        rate.tax_rate_code is not NULL )
           THEN CASE WHEN taxlines_gt.tax_rate_id IS NOT NULL
           AND NOT EXISTS ( SELECT 1 FROM zx_rates_b
                WHERE tax_rate_id = taxlines_gt.tax_rate_id)
               THEN 'Y'
               ELSE 'N' END
           ELSE 'Y' END TAX_RATE_CODE_NOT_EXISTS,
      --Bug 4703541
      CASE WHEN
          taxlines_gt.tax_date
          BETWEEN rate.effective_from AND
            nvl(rate.effective_to,
           taxlines_gt.tax_date)
           THEN 'N'
           ELSE 'Y' END TAX_RATE_CODE_NOT_EFFECTIVE,
      -- Check Rate Code is Active
         CASE WHEN rate.active_flag = 'Y'
        THEN 'N'
        ELSE 'Y' END TAX_RATE_CODE_NOT_ACTIVE,
      -- Check for Rate Percentage
      CASE WHEN  taxlines_gt.tax_rate IS NOT NULL
           AND rate.percentage_rate <> taxlines_gt.tax_rate
           AND nvl(rate.allow_adhoc_tax_rate_flag,'N') <> 'Y'
           AND taxlines_gt.tax_date
           BETWEEN rate.effective_from AND
             nvl(rate.effective_to,
                 taxlines_gt.tax_date
                 )
          THEN 'Y'
          ELSE 'N' END TAX_RATE_PERCENTAGE_INVALID,
        -- Check for 'Recovery' or 'Offset' Tax
          CASE WHEN ((off_rate.tax_rate_code is not null and temp_gt.tax_rate_code is null) --Bug 4902521
                 OR
                 rate.rate_type_code = 'RECOVERY'
                )
         THEN 'Y'
         ELSE NULL END TAX_RECOV_OR_OFFSET,
      -- Check for Default Tax Rate Code check for partner tax lines
      CASE WHEN ( taxlines_gt.tax_provider_id is not NULL )
           THEN CASE WHEN
          --Bug#3600626
          rate.default_rate_flag = 'Y' AND
          taxlines_gt.tax_date
          BETWEEN
          rate.effective_from AND
          nvl(rate.effective_to,
             taxlines_gt.tax_date
              )
             THEN NULL
             ELSE 'Y' END
            ELSE NULL
       END DEFAULT_RATE_CODE_NOT_EXISTS
  FROM ZX_TRX_HEADERS_GT header,
      ZX_RATES_B rate ,
      zx_rates_b off_rate,
      zx_import_tax_lines_gt temp_gt,
      ZX_IMPORT_TAX_LINES_GT taxlines_gt,
      --zx_transaction_lines_gt lines_gt,
      zx_subscription_details sd_rates
  WHERE taxlines_gt.trx_id = header.trx_id
      AND taxlines_gt.application_id = Header.application_id
      AND taxlines_gt.entity_code = Header.entity_code
      AND taxlines_gt.event_class_code = Header.event_class_code
          AND (taxlines_gt.tax_rate_code IS NOT NULL OR taxlines_gt.tax_rate_id IS NOT NULL)
          AND (temp_gt.tax_rate_code IS NOT NULL OR temp_gt.tax_rate_id IS NOT NULL)
      --AND lines_gt.application_id = header.application_id
      --AND lines_gt.entity_code = header.entity_code
      --AND lines_gt.event_class_code = header.event_class_code
      --AND lines_gt.trx_id = header.trx_id
      --AND
      --(-- One to One Alloc
    --(
        --lines_gt.trx_line_id = taxlines_gt.trx_line_id
    --)
    --OR
    --Multi Alloc
    --(
        --taxlines_gt.trx_line_id IS NULL
        --AND taxlines_gt.tax_line_allocation_flag = 'Y'
        --AND lines_gt.trx_line_id =
        --(
        --SELECT
      --MIN(trx_line_id)
        --FROM zx_trx_tax_link_gt link_gt
        --WHERE link_gt.TRX_ID = taxlines_gt.trx_id
      --AND link_gt.application_id = taxlines_gt.application_id
      --AND link_gt.entity_code = taxlines_gt.entity_code
      --AND link_gt.event_class_code = taxlines_gt.event_class_code
      --AND link_gt.summary_tax_line_number = taxlines_gt.summary_tax_line_number
        --)
    --)
    --OR
    --All Alloc
    --(
        --taxlines_gt.trx_line_id IS NULL
        --AND taxlines_gt.tax_line_allocation_flag = 'N'
        --AND lines_gt.trx_line_id =
        --(
        --SELECT
      --MIN(trx_line_id)
        --FROM zx_transaction_lines_gt trans_line_gt
        --WHERE trans_line_gt.trx_id = taxlines_gt.trx_id
      --AND trans_line_gt.application_id = taxlines_gt.application_id
      --AND trans_line_gt.entity_code = taxlines_gt.entity_code
      --AND trans_line_gt.event_class_code = taxlines_gt.event_class_code
        --)
    --)
      --)
      --* for rates
      --AND rate.tax_rate_id(+) = taxlines_gt.tax_rate_id
      AND ( taxlines_gt.tax_rate_code IS NOT NULL AND
            rate.tax_rate_code (+) = taxlines_gt.tax_rate_code )
      AND rate.tax_status_code(+) = taxlines_gt.tax_status_code
      AND rate.tax(+) = taxlines_gt.tax
      AND rate.tax_regime_code(+) = taxlines_gt.tax_regime_code
      AND rate.tax_regime_code = sd_rates.tax_regime_code (+)
      AND (taxlines_gt.tax_jurisdiction_code = rate.tax_jurisdiction_code
           OR
           rate.tax_jurisdiction_code IS NULL
           OR
           taxlines_gt.tax_jurisdiction_code IS NULL
          )
      AND (rate.content_owner_id = sd_rates.parent_first_pty_org_id
           OR
           sd_rates.parent_first_pty_org_id is NULL
           )
      --AND sd_rates.first_pty_org_id(+) = g_first_pty_org_id
      AND sd_rates.first_pty_org_id IN (g_first_pty_org_id, -99)
      AND
      (
    taxlines_gt.subscription_date
    BETWEEN
    nvl( sd_rates.effective_from,
         taxlines_gt.subscription_date
        )
    AND
    nvl(sd_rates.effective_to,
       taxlines_gt.subscription_date
        )
         /* OR rate.effective_from =
    (
    SELECT
        min(effective_from)
    FROM ZX_RATES_B
    WHERE tax_regime_code = rate.tax_regime_code
        AND tax = rate.tax
        AND tax_status_code = rate.tax_status_code
        AND tax_rate_code = rate.tax_rate_code
        AND content_owner_id = rate.content_owner_id
    )*/
      )
      AND
      (
    NVL(sd_rates.view_options_code,'NONE') in ('NONE', 'VFC')
    OR
    (
        NVL(sd_rates.view_options_code, 'VFR') = 'VFR'
        AND NOT EXISTS
        (
        SELECT
      1
        FROM zx_rates_b b
        WHERE b.tax_regime_code = rate.tax_regime_code
      AND b.tax = rate.tax
      AND b.tax_status_code = rate.tax_status_code
      AND b.tax_rate_code = rate.tax_rate_code
      AND b.content_owner_id = sd_rates.first_pty_org_id
        )
    )
      )
      AND rate.tax_rate_code = off_rate.offset_tax_rate_code(+)
      AND off_rate.tax_rate_code = temp_gt.tax_rate_code(+)
  );

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF ( g_level_statement >= g_current_runtime_level) THEN
    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'No. of Rows inserted for Import Tax Line Validations : Rate Code '|| to_char(sql%ROWCOUNT) );
  END IF;

  IF ( g_level_statement >= g_current_runtime_level) THEN
    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'Before insertion into ZX_VALIDATION_ERRORS_GT for Rate Imported Tax Lines Validations based on tax_rate_id');
  END IF;

  INSERT ALL
        WHEN (TAX_RATE_NOT_EXISTS = 'Y')  THEN
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
                                interface_tax_entity_code,
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
                                interface_tax_entity_code,
                                interface_tax_line_id
                         )
        WHEN (TAX_RATE_NOT_EFFECTIVE = 'Y')  THEN
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
                                interface_tax_entity_code,
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
                                interface_tax_entity_code,
                                interface_tax_line_id
                                )
        WHEN (TAX_RATE_NOT_ACTIVE = 'Y')  THEN
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
                                interface_tax_entity_code,
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
                                interface_tax_entity_code,
                                interface_tax_line_id
                                )
  SELECT
    application_id,
    entity_code,
    event_class_code,
    trx_id,
    summary_tax_line_number,
    interface_tax_line_id,
    interface_tax_entity_code,
    interface_line_id,
    interface_line_entity_code,
    trx_line_id,
    trx_level_type,
    TAX_RATE_NOT_EXISTS,
    DECODE(TAX_RATE_NOT_EXISTS,'Y','N',TAX_RATE_NOT_EFFECTIVE) TAX_RATE_NOT_EFFECTIVE,
    DECODE(TAX_RATE_NOT_EXISTS,'Y','N',TAX_RATE_NOT_ACTIVE) TAX_RATE_NOT_ACTIVE
  FROM
  (SELECT
      header.application_id application_id,
      header.entity_code entity_code,
      header.event_class_code,
      header.trx_id trx_id,
      taxlines_gt.summary_tax_line_number summary_tax_line_number,
      taxlines_gt.summary_tax_line_number interface_tax_line_id,
      taxlines_gt.entity_code             interface_tax_entity_code,
      --lines_gt.trx_line_id     interface_line_id,
      --lines_gt.entity_code     interface_line_entity_code,
      --lines_gt.trx_line_id trx_line_id,
      --lines_gt.trx_level_type trx_level_type,
      null     interface_line_id,
      null     interface_line_entity_code,
      null     trx_line_id,
      null     trx_level_type,
      -- Check for Rate Code Existence
      --Bug 4703541
       CASE WHEN ( sd_rates.tax_regime_code IS NOT NULL
                   AND rate.tax_rate_id IS NOT NULL )
            THEN CASE WHEN taxlines_gt.tax_rate_code IS NOT NULL
                AND NOT EXISTS ( SELECT 1 FROM zx_rates_b
                     WHERE tax_rate_code = taxlines_gt.tax_rate_code)
          THEN 'Y'
          ELSE 'N' END
            ELSE 'Y' END TAX_RATE_NOT_EXISTS,
      -- Check for Rate Id Date Effectivity
           CASE WHEN taxlines_gt.tax_date
            BETWEEN rate.effective_from AND
              NVL(rate.effective_to,
            taxlines_gt.tax_date)
          THEN 'N'
          ELSE 'Y' END TAX_RATE_NOT_EFFECTIVE,
      -- Check Rate Code is Active
         CASE WHEN rate.tax_rate_id IS NOT NULL AND rate.active_flag = 'Y'
          THEN 'N'
          ELSE 'Y' END TAX_RATE_NOT_ACTIVE
  FROM ZX_TRX_HEADERS_GT header,
      ZX_RATES_B rate ,
      zx_rates_b off_rate,
      zx_import_tax_lines_gt temp_gt,
      ZX_IMPORT_TAX_LINES_GT taxlines_gt,
      --zx_transaction_lines_gt lines_gt,
      zx_subscription_details sd_rates
  WHERE taxlines_gt.trx_id = header.trx_id
      AND taxlines_gt.application_id = Header.application_id
      AND taxlines_gt.entity_code = Header.entity_code
      AND taxlines_gt.event_class_code = Header.event_class_code
      AND (taxlines_gt.tax_rate_code IS NOT NULL OR taxlines_gt.tax_rate_id IS NOT NULL)
      AND (temp_gt.tax_rate_code IS NOT NULL OR temp_gt.tax_rate_id IS NOT NULL)
      --AND lines_gt.application_id = header.application_id
      --AND lines_gt.entity_code = header.entity_code
      --AND lines_gt.event_class_code = header.event_class_code
      --AND lines_gt.trx_id = header.trx_id
      --AND
      --(-- One to One Alloc
    --(
        --lines_gt.trx_line_id = taxlines_gt.trx_line_id
    --)
    --OR
    --Multi Alloc
    --(
        --taxlines_gt.trx_line_id IS NULL
        --AND taxlines_gt.tax_line_allocation_flag = 'Y'
        --AND lines_gt.trx_line_id =
        --(
        --SELECT
      --MIN(trx_line_id)
        --FROM zx_trx_tax_link_gt link_gt
        --WHERE link_gt.TRX_ID = taxlines_gt.trx_id
      --AND link_gt.application_id = taxlines_gt.application_id
      --AND link_gt.entity_code = taxlines_gt.entity_code
      --AND link_gt.event_class_code = taxlines_gt.event_class_code
      --AND link_gt.summary_tax_line_number = taxlines_gt.summary_tax_line_number
        --)
    --)
    --OR
    --All Alloc
    --(
        --taxlines_gt.trx_line_id IS NULL
        --AND taxlines_gt.tax_line_allocation_flag = 'N'
        --AND lines_gt.trx_line_id =
        --(
        --SELECT
      --MIN(trx_line_id)
        --FROM zx_transaction_lines_gt trans_line_gt
        --WHERE trans_line_gt.trx_id = taxlines_gt.trx_id
      --AND trans_line_gt.application_id = taxlines_gt.application_id
      --AND trans_line_gt.entity_code = taxlines_gt.entity_code
      --AND trans_line_gt.event_class_code = taxlines_gt.event_class_code
        --)
    --)
      --)
      --* for rates
      AND ( taxlines_gt.tax_rate_id IS NOT NULL AND
            rate.tax_rate_id (+) = taxlines_gt.tax_rate_id )
      AND rate.tax_status_code(+) = taxlines_gt.tax_status_code
      AND rate.tax(+) = taxlines_gt.tax
      AND rate.tax_regime_code(+) = taxlines_gt.tax_regime_code
      AND rate.tax_regime_code = sd_rates.tax_regime_code (+)
      AND
    (
    rate.content_owner_id = sd_rates.parent_first_pty_org_id
    OR
     sd_rates.parent_first_pty_org_id is NULL
    )
      --AND sd_rates.first_pty_org_id(+) = g_first_pty_org_id
      AND sd_rates.first_pty_org_id IN (g_first_pty_org_id, -99)
      AND
      (
    taxlines_gt.subscription_date
    BETWEEN
    nvl( sd_rates.effective_from,
         taxlines_gt.subscription_date
        )
    AND
    nvl(sd_rates.effective_to,
        taxlines_gt.subscription_date
        )
         /* OR rate.effective_from =
    (
    SELECT
        min(effective_from)
    FROM ZX_RATES_B
    WHERE tax_regime_code = rate.tax_regime_code
        AND tax = rate.tax
        AND tax_status_code = rate.tax_status_code
        AND tax_rate_code = rate.tax_rate_code
        AND content_owner_id = rate.content_owner_id
    )*/
      )
      AND
      (
    NVL(sd_rates.view_options_code,'NONE') in ('NONE', 'VFC')
    OR
    (
        NVL(sd_rates.view_options_code, 'VFR') = 'VFR'
        AND NOT EXISTS
        (
        SELECT
      1
        FROM zx_rates_b b
        WHERE b.tax_regime_code = rate.tax_regime_code
      AND b.tax = rate.tax
      AND b.tax_status_code = rate.tax_status_code
      AND b.tax_rate_code = rate.tax_rate_code
      AND b.content_owner_id = sd_rates.first_pty_org_id
        )
    )
      )
      AND rate.tax_rate_code = off_rate.offset_tax_rate_code(+)
      AND off_rate.tax_rate_code = temp_gt.tax_rate_code(+)
  );

        -- Bug 4902521 : Added Message to check no. of rows inserted .
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF ( g_level_statement >= g_current_runtime_level) THEN
    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'No. of Rows inserted for Import Tax Line Validations : Rate ID '|| to_char(sql%ROWCOUNT) );
  END IF;

  -- Validations for zx_trx_tax_link_gt link_gt
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    IF ( g_level_event >= g_current_runtime_level) THEN
      FND_LOG.STRING(g_level_event,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
      'Validations for zx_trx_tax_link_gt link_gt');
    END IF;

  -- Select the key columns and write into fnd log for debug purpose
  IF ( g_level_statement >= g_current_runtime_level) THEN
    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
      'Before opening the cursor - get_tax_link_gt_info_csr');

    OPEN get_tax_link_gt_info_csr;
    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
      'After opening the cursor - get_tax_link_gt_info_csr');
    LOOP
      FETCH get_tax_link_gt_info_csr BULK COLLECT INTO
      l_application_id_tbl,
      l_entity_code_tbl,
      l_event_class_code_tbl,
      l_trx_id_tbl,
      l_trx_line_id_tbl,
      l_trx_level_type_tbl,
      l_summary_tax_line_number_tbl

        LIMIT C_LINES_PER_COMMIT;

--        EXIT WHEN get_tax_link_gt_info_csr%notfound;

      l_count := nvl(l_trx_line_id_tbl.COUNT,0);

          FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
             'number of rows fetched = ' || to_char(l_count));

      IF l_count > 0 THEN

        FOR i IN 1.. l_count LOOP

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'Row Number = ' || to_char(i) );

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'l_application_id = ' || to_char(l_application_id_tbl(i)) );

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'l_entity_code = ' || l_entity_code_tbl(i) );

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'l_event_class_code = ' || l_event_class_code_tbl(i) );

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'l_trx_id = ' || to_char(l_trx_id_tbl(i)) );

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'l_trx_line_id = ' || to_char(l_trx_line_id_tbl(i)) );

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'l_trx_level_type = ' || l_trx_level_type_tbl(i) );

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'l_summary_tax_line_number = ' || to_char(l_summary_tax_line_number_tbl(i)) );


        END LOOP;
       ELSE
         EXIT ;

      END IF; -- end of count checking

    END LOOP;

    CLOSE get_tax_link_gt_info_csr;

          -- Clear the records
    l_application_id_tbl.delete;
    l_entity_code_tbl.delete;
    l_event_class_code_tbl.delete;
    l_trx_id_tbl.delete;
    l_trx_line_id_tbl.delete;
    l_trx_level_type_tbl.delete;
    l_summary_tax_line_number_tbl.delete;

  END IF; -- End of debug checking

  IF ( g_level_statement >= g_current_runtime_level) THEN
    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'Before insertion into ZX_VALIDATION_ERRORS_GT - Validations for zx_trx_tax_link_gt link_gt');
  END IF;


        INSERT ALL
        WHEN (ZX_INVALID_TRX_LINE_ID = 'Y') THEN
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
      interface_tax_entity_code,
      interface_tax_line_id
                        )
                VALUES(
                        application_id,
                        entity_code,
                        event_class_code,
                        trx_id,
                        trx_line_id, -- Bug 4703541
                        summary_tax_line_number,
                        'ZX_INVALID_TRX_LINE_ID',
                        l_invd_trx_line_id_in_link_gt,
                        trx_level_type,
      interface_tax_entity_code,
      interface_tax_line_id
                         )
        WHEN (ZX_INVALID_SUMMARY_TAX_LINE_ID = 'Y')  THEN
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
      interface_tax_entity_code,
      interface_tax_line_id
                        )
                VALUES(
                        application_id,
                        entity_code,
                        event_class_code,
                        trx_id,
                        trx_line_id, -- Bug 4703541
                        summary_tax_line_number,
                        'ZX_INVALID_SUMMARY_TAX_LINE_ID',
                        l_invalid_summary_tax_line_id,
                        trx_level_type,
      interface_tax_entity_code,
      interface_tax_line_id
                         )
         SELECT
           application_id,
           entity_code,
           event_class_code,
           trx_id,
     trx_line_id,
           summary_tax_line_number,
           trx_level_type,
     interface_tax_entity_code,
     interface_tax_line_id,
           -- Check if the Trx Lines present in Link GTT are also present in ZX_TRANSACTION_LINES_GT or not
           CASE WHEN NOT EXISTS (SELECT 1
                                   FROM zx_transaction_lines_gt
                                  WHERE application_id = link_gt.application_id
                                    AND entity_code = link_gt.entity_code
                                    AND event_class_code = link_gt.event_class_code
                                    AND trx_id = link_gt.trx_id
                                    AND trx_line_id = link_gt.trx_line_id
                                    AND trx_level_type = link_gt.trx_level_type)
                THEN 'Y'
                  ELSE NULL
           END ZX_INVALID_TRX_LINE_ID,
           --Check if the Summary Tax Lines present in Link GTT are also present in Import Tax Lines GTT or not
           CASE WHEN NOT EXISTS (SELECT 1
                                   FROM zx_import_tax_lines_gt
                                  WHERE application_id = link_gt.application_id
                                    AND entity_code = link_gt.entity_code
                                    AND event_class_code = link_gt.event_class_code
                                    AND trx_id = link_gt.trx_id
                                    AND summary_tax_line_number = link_gt.summary_tax_line_number )
                                    /*AND trx_line_id = link_gt.trx_line_id
                                    AND trx_level_type = link_gt.trx_level_type*/  -- Bug 4703541
                THEN 'Y'
                     ELSE NULL
           END ZX_INVALID_SUMMARY_TAX_LINE_ID
         FROM zx_trx_tax_link_gt link_gt;

        -- Bug 4902521 : Added Message to check no. of rows inserted .
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF ( g_level_statement >= g_current_runtime_level) THEN
    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'No. of Rows inserted for Link_gt Realted Validations '|| to_char(sql%ROWCOUNT) );
  END IF;

  -- Bug Fix # 4184091
  -- As per the email communication from vidya, changed the flag value from Y to N
  update zx_trx_headers_gt set validation_check_flag = 'N' where
    trx_id in (select trx_id from zx_validation_errors_gt);

  IF ( SQL%ROWCOUNT > 0 ) THEN
                g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    IF ( g_level_statement >= g_current_runtime_level) THEN
      FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
      'Updated the validation_check_flag to N in zx_trx_headers_gt for '||to_char(SQL%ROWCOUNT)||' trx_ids ');
    END IF;
  END IF ;

        IF (g_level_procedure >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_procedure,
                        'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR.END',
                        'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR(-)');
        END IF;


EXCEPTION
         WHEN OTHERS THEN
              IF (g_level_unexpected >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_unexpected,
                          'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
                           sqlerrm);
              END IF;

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         app_exception.raise_exception;



END Validate_Tax_Attr;


------------------ Procedure For Validating Other Documents  -----------------

PROCEDURE Validate_Other_Documents(x_return_status  OUT NOCOPY VARCHAR2) IS

  l_trx_id_tbl                        TRX_ID_TBL;
  l_trx_line_id_tbl                   TRX_LINE_ID_TBL;
  l_trx_level_type_tbl                TRX_LEVEL_TYPE_TBL;
  l_event_class_code_tbl              EVENT_CLASS_CODE_TBL;
  l_entity_code_tbl                   ENTITY_CODE_TBL;
  l_application_id_tbl                APPLICATION_ID_TBL;
  l_summary_tax_line_number_tbl       SUMMARY_TAX_LINE_NUMBER_TBL;
  l_count                             NUMBER;
  l_error_buffer                      VARCHAR2(240);

  c_lines_per_commit CONSTANT NUMBER := ZX_TDS_CALC_SERVICES_PUB_PKG.G_LINES_PER_COMMIT;

  CURSOR get_other_doc_info_csr
  IS
  SELECT
  header.application_id,
  header.entity_code,
  header.event_class_code,
  header.trx_id,
  lines_gt.trx_line_id,
  lines_gt.trx_level_type

        FROM ZX_TRX_HEADERS_GT             header,
             ZX_TRANSACTION_LINES_GT       lines_gt

        WHERE lines_gt.application_id = header.application_id
        AND   lines_gt.entity_code = header.entity_code
        AND   lines_gt.event_class_code = header.event_class_code
        AND   lines_gt.trx_id = header.trx_id;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_event >= g_current_runtime_level ) THEN
  FND_LOG.STRING(g_level_event,
       'ZX.PLSQL.ZX_VALIDATE_API_PKG.Validate_Other_Documents.BEGIN',
       'ZX_VALIDATE_API_PKG: Validate_Other_Documents(+)');
  END IF;

  -- Select the key columns and write into fnd log for debug purpose
  IF ( g_level_statement >= g_current_runtime_level) THEN
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_VALIDATE_API_PKG.Validate_Other_Documents',
             'Before opening the cursor - get_other_doc_info_csr');

    OPEN get_other_doc_info_csr;
    FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_VALIDATE_API_PKG.Validate_Other_Documents',
             'After opening the cursor - get_other_doc_info_csr');

    LOOP
      FETCH get_other_doc_info_csr BULK COLLECT INTO
      l_application_id_tbl,
      l_entity_code_tbl,
      l_event_class_code_tbl,
      l_trx_id_tbl,
      l_trx_line_id_tbl,
      l_trx_level_type_tbl

        LIMIT C_LINES_PER_COMMIT;


--        EXIT WHEN get_other_doc_info_csr%notfound;

      l_count := nvl(l_trx_line_id_tbl.COUNT,0);

        FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_VALIDATE_API_PKG.Validate_Other_Documents',
             'number of rows fetched = ' || to_char(l_count));

      IF l_count > 0 THEN

        FOR i IN 1.. l_count LOOP

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.Validate_Other_Documents',
    'Row Number = ' || to_char(i) );

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.Validate_Other_Documents',
    'l_application_id = ' || to_char(l_application_id_tbl(i)) );

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.Validate_Other_Documents',
    'l_entity_code = ' || l_entity_code_tbl(i) );

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.Validate_Other_Documents',
    'l_event_class_code = ' || l_event_class_code_tbl(i) );

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.Validate_Other_Documents',
    'l_trx_id = ' || to_char(l_trx_id_tbl(i)) );

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.Validate_Other_Documents',
    'l_trx_line_id = ' || to_char(l_trx_line_id_tbl(i)) );

    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.Validate_Other_Documents',
    'l_trx_level_type = ' || l_trx_level_type_tbl(i) );

        END LOOP;
       ELSE
       EXIT ;
      END IF; -- end of count checking

    END LOOP;

    CLOSE get_other_doc_info_csr;

          -- Clear the records
    l_application_id_tbl.delete;
    l_entity_code_tbl.delete;
    l_event_class_code_tbl.delete;
    l_trx_id_tbl.delete;
    l_trx_line_id_tbl.delete;
    l_trx_level_type_tbl.delete;

  END IF; -- End of debug checking

  IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_VALIDATE_API_PKG.Validate_Other_Documents',
             'Before insertion into ZX_VALIDATION_ERRORS_GT for Validate_Other_Documents');
  END IF;

        INSERT ALL
        WHEN (ZX_REF_DOC_MISSING = 'Y')  THEN

                        INTO ZX_VALIDATION_ERRORS_GT(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                message_name,
                                message_text,
                                trx_level_type,
                                other_doc_application_id,
                                other_doc_entity_code,
                                other_doc_event_class_code,
                                other_doc_trx_id,
                                interface_line_entity_code,
                                interface_line_id
                                )

                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                'ZX_REF_DOC_MISSING',
                                l_ref_doc_missing,
                                trx_level_type,
                                ref_doc_application_id,
                                ref_doc_entity_code,
                                ref_doc_event_class_code,
                                ref_doc_trx_id,
                                interface_line_entity_code,
                                interface_line_id
                               )
        WHEN (ZX_REL_DOC_MISSING = 'Y')  THEN

                        INTO ZX_VALIDATION_ERRORS_GT(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                message_name,
                                message_text,
                                other_doc_application_id,
                                other_doc_entity_code,
                                other_doc_event_class_code,
                                other_doc_trx_id
                                )

                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                'ZX_REL_DOC_MISSING',
                                l_rel_doc_missing,
                                rel_doc_application_id,
                                rel_doc_entity_code,
                                rel_doc_event_class_code,
                                rel_doc_trx_id
                               )
        WHEN (ZX_APP_FROM_DOC_MISSING = 'Y')  THEN

                        INTO ZX_VALIDATION_ERRORS_GT(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                message_name,
                                message_text,
                                trx_level_type,
                                other_doc_application_id,
                                other_doc_entity_code,
                                other_doc_event_class_code,
                                other_doc_trx_id,
                                interface_line_entity_code,
                                interface_line_id
                                )

                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                'ZX_APP_FROM_DOC_MISSING',
                                l_app_from_doc_missing,
                                trx_level_type,
                                app_from_application_id,
                                app_from_entity_code,
                                app_from_event_class_code,
                                app_from_trx_id,
                                interface_line_entity_code,
                                interface_line_id
                               )

/*  Since we do not store applied to document (receipt), we should
    not check whether the doc exists in eTax repository

        WHEN (ZX_APP_TO_DOC_MISSING = 'Y')  THEN

                        INTO ZX_VALIDATION_ERRORS_GT(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                message_name,
                                message_text,
                                trx_level_type,
                                other_doc_application_id,
                                other_doc_entity_code,
                                other_doc_event_class_code,
                                other_doc_trx_id,
                                interface_line_entity_code,
                                interface_line_id
                                )

                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                'ZX_APP_TO_DOC_MISSING',
                                l_app_to_doc_missing,
                                trx_level_type,
                                app_to_application_id,
                                app_to_entity_code,
                                app_to_event_class_code,
                                app_to_trx_id,
                                interface_line_entity_code,
                                interface_line_id
                               )
*/
        WHEN (ZX_ADJ_DOC_MISSING = 'Y')  THEN

                        INTO ZX_VALIDATION_ERRORS_GT(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                message_name,
                                message_text,
                                trx_level_type,
                                other_doc_application_id,
                                other_doc_entity_code,
                                other_doc_event_class_code,
                                other_doc_trx_id,
                                interface_line_entity_code,
                                interface_line_id
                                )

                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                'ZX_ADJ_DOC_MISSING',
                                l_adj_doc_missing,
                                trx_level_type,
                                adj_doc_application_id,
                                adj_doc_entity_code,
                                adj_doc_event_class_code,
                                adj_doc_trx_id,
                                interface_line_entity_code,
                                interface_line_id
                               )
        WHEN (ZX_SOURCE_DOC_MISSING = 'Y')  THEN

                        INTO ZX_VALIDATION_ERRORS_GT(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                message_name,
                                message_text,
                                trx_level_type,
                                other_doc_application_id,
                                other_doc_entity_code,
                                other_doc_event_class_code,
                                other_doc_trx_id,
                                interface_line_entity_code,
                                interface_line_id
                                )

                        VALUES(
                                application_id,
                                entity_code,
                                event_class_code,
                                trx_id,
                                trx_line_id,
                                'ZX_SOURCE_DOC_MISSING',
                                l_source_doc_missing,
                                trx_level_type,
                                src_doc_application_id,
                                src_doc_entity_code,
                                src_doc_event_class_code,
                                src_doc_trx_id,
                                interface_line_entity_code,
                                interface_line_id
                               )
        SELECT  header.application_id                application_id,
                header.entity_code                   entity_code,
                header.event_class_code              event_class_code,
                header.trx_id                        trx_id,
                header.related_doc_application_id    rel_doc_application_id,
                header.related_doc_entity_code       rel_doc_entity_code,
                header.related_doc_event_class_code  rel_doc_event_class_code,
                header.related_doc_trx_id            rel_doc_trx_id,
                lines_gt.trx_line_id                 trx_line_id,
                lines_gt.trx_level_type              trx_level_type,
                lines_gt.interface_line_id           interface_line_id,
                lines_gt.interface_entity_code       interface_line_entity_code,
                lines_gt.source_application_id       src_doc_application_id,
                lines_gt.source_entity_code          src_doc_entity_code,
                lines_gt.source_event_class_code     src_doc_event_class_code,
                lines_gt.source_trx_id               src_doc_trx_id,
                lines_gt.ref_doc_application_id      ref_doc_application_id,
                lines_gt.ref_doc_entity_code         ref_doc_entity_code,
                lines_gt.ref_doc_event_class_code    ref_doc_event_class_code,
                lines_gt.ref_doc_trx_id              ref_doc_trx_id,
                lines_gt.applied_from_application_id app_from_application_id,
                lines_gt.applied_from_entity_code    app_from_entity_code,
                lines_gt.applied_from_event_class_code app_from_event_class_code,
                lines_gt.applied_from_trx_id         app_from_trx_id,
                lines_gt.applied_to_application_id   app_to_application_id,
                lines_gt.applied_to_entity_code      app_to_entity_code,
                lines_gt.applied_to_event_class_code app_to_event_class_code,
                lines_gt.applied_to_trx_id           app_to_trx_id,
                lines_gt.adjusted_doc_application_id adj_doc_application_id,
                lines_gt.adjusted_doc_entity_code    adj_doc_entity_code,
                lines_gt.adjusted_doc_event_class_code adj_doc_event_class_code,
                lines_gt.adjusted_doc_trx_id         adj_doc_trx_id,

                -- Check for existence of related documents in zx lines det factors table
                -- Since the Selection is at the granularity of the transaction lines, also check for existence of
                -- error record in validaiton errors gt to avoid inserting header level errors multiple times
                -- Also check in zx trx headers gt if this doc is already present
                nvl2( header.related_doc_trx_id,
                      CASE WHEN ((NOT EXISTS
                                      (SELECT 1 FROM ZX_LINES_DET_FACTORS
                                       WHERE application_id = header.related_doc_application_id
                                       AND   entity_code = header.related_doc_entity_code
                                       AND   event_class_code = header.related_doc_event_class_code
                                       AND   trx_id = header.related_doc_trx_id))
                                 AND ( NOT EXISTS
                                      (SELECT 1 FROM ZX_TRANSACTION_LINES_GT
                                       WHERE application_id = lines_gt.application_id
                                       AND   entity_code = lines_gt.entity_code
                                       AND   event_class_code = lines_gt.event_class_code
                                       AND   trx_id = lines_gt.trx_id
                                       AND   trx_line_id < lines_gt.trx_line_id
                                       AND   trx_level_type = lines_gt.trx_level_type))
                                 AND ( NOT EXISTS
                                      (SELECT 1 FROM ZX_TRX_HEADERS_GT
                                       WHERE application_id = header.related_doc_application_id
                                       AND   entity_code = header.related_doc_entity_code
                                       AND   event_class_code = header.related_doc_event_class_code
                                       AND   trx_id = header.related_doc_trx_id)))
                           THEN 'Y'
                           ELSE NULL END,
                           NULL)  ZX_REL_DOC_MISSING,

                -- Check for existence of reference documents in zx lines det factors table and zx trx lines gt
                nvl2( lines_gt.ref_doc_trx_id,
                      CASE WHEN lines_gt.ref_doc_application_id = 201
                           AND  lines_gt.ref_doc_entity_code = 'RELEASE'
                           AND  lines_gt.ref_doc_event_class_code = 'RELEASE' THEN
                           NULL
                           WHEN ((NOT EXISTS
                                      (SELECT 1 FROM ZX_LINES_DET_FACTORS
                                       WHERE application_id = lines_gt.ref_doc_application_id
                                       AND   entity_code = lines_gt.ref_doc_entity_code
                                       AND   event_class_code = lines_gt.ref_doc_event_class_code
                                       AND   trx_id = lines_gt.ref_doc_trx_id
                                       AND   trx_line_id = lines_gt.ref_doc_line_id
                                       AND   trx_level_type = lines_gt.ref_doc_trx_level_type))
                                 AND ( NOT EXISTS
                                      (SELECT 1 FROM ZX_TRANSACTION_LINES_GT
               WHERE application_id = lines_gt.ref_doc_application_id
               AND   entity_code = lines_gt.ref_doc_entity_code
               AND   event_class_code = lines_gt.ref_doc_event_class_code
               AND   trx_id = lines_gt.ref_doc_trx_id
               AND   trx_line_id = lines_gt.ref_doc_line_id
                                       AND   trx_level_type = lines_gt.ref_doc_trx_level_type)))
                           THEN 'Y'
                           ELSE NULL END,
                           NULL)  ZX_REF_DOC_MISSING,

                -- Check for applied from documents in zx lines det factors table and zx trx lines gt
                nvl2( lines_gt.applied_from_trx_id,
                      CASE WHEN ((NOT EXISTS
                                      (SELECT 1 FROM ZX_LINES_DET_FACTORS
                                       WHERE application_id = lines_gt.applied_from_application_id
                                       AND   entity_code = lines_gt.applied_from_entity_code
                                       AND   event_class_code = lines_gt.applied_from_event_class_code
                                       AND   trx_id = lines_gt.applied_from_trx_id
                                       AND   trx_line_id = lines_gt.applied_from_line_id
                                       AND   trx_level_type = lines_gt.applied_from_trx_level_type))
                                 AND ( NOT EXISTS
                                      (SELECT 1 FROM ZX_TRANSACTION_LINES_GT
               WHERE application_id = lines_gt.applied_from_application_id
               AND   entity_code = lines_gt.applied_from_entity_code
               AND   event_class_code = lines_gt.applied_from_event_class_code
               AND   trx_id = lines_gt.applied_from_trx_id
               AND   trx_line_id = lines_gt.applied_from_line_id
                                       AND   trx_level_type = lines_gt.applied_from_trx_level_type)))
                           THEN 'Y'
                           ELSE NULL END,
                           NULL) ZX_APP_FROM_DOC_MISSING,

                -- Check for adjusted document in zx lines det factors table and zx trx lines gt
                nvl2( lines_gt.adjusted_doc_trx_id,
                      CASE WHEN ((NOT EXISTS
                                      (SELECT 1 FROM ZX_LINES_DET_FACTORS
                                       WHERE application_id = lines_gt.adjusted_doc_application_id
                                       AND   entity_code = lines_gt.adjusted_doc_entity_code
                                       AND   event_class_code = lines_gt.adjusted_doc_event_class_code
                                       AND   trx_id = lines_gt.adjusted_doc_trx_id
                                       AND   trx_line_id = lines_gt.adjusted_doc_line_id
                                       AND   trx_level_type = lines_gt.adjusted_doc_trx_level_type))
                                 AND ( NOT EXISTS
                                      (SELECT 1 FROM ZX_TRANSACTION_LINES_GT
               WHERE application_id = lines_gt.adjusted_doc_application_id
               AND   entity_code = lines_gt.adjusted_doc_entity_code
               AND   event_class_code = lines_gt.adjusted_doc_event_class_code
               AND   trx_id = lines_gt.adjusted_doc_trx_id
               AND   trx_line_id = lines_gt.adjusted_doc_line_id
                                       AND   trx_level_type = lines_gt.adjusted_doc_trx_level_type)))
                           THEN 'Y'
                           ELSE NULL END,
                           NULL) ZX_ADJ_DOC_MISSING,

                -- Check for applied to documents in zx lines det factors table and zx trx lines gt

/*      Since we do not store applied to document (receipt), we should
        not check whether the doc exists in eTax repository

                nvl2( lines_gt.applied_to_trx_id,
                      CASE WHEN ((NOT EXISTS
                                      (SELECT 1 FROM ZX_LINES_DET_FACTORS
                                       WHERE application_id = lines_gt.applied_to_application_id
                                       AND   entity_code = lines_gt.applied_to_entity_code
                                       AND   event_class_code = lines_gt.applied_to_event_class_code
                                       AND   trx_id = lines_gt.applied_to_trx_id
                                       AND   trx_line_id = lines_gt.applied_to_trx_line_id
                                       AND   trx_level_type = lines_gt.applied_to_trx_level_type))
                                 AND ( NOT EXISTS
                                      (SELECT 1 FROM ZX_TRANSACTION_LINES_GT
               WHERE application_id = lines_gt.applied_to_application_id
               AND   entity_code = lines_gt.applied_to_entity_code
               AND   event_class_code = lines_gt.applied_to_event_class_code
               AND   trx_id = lines_gt.applied_to_trx_id
               AND   trx_line_id = lines_gt.applied_to_trx_line_id
                                       AND   trx_level_type = lines_gt.applied_to_trx_level_type)))
                           THEN 'Y'
                           ELSE NULL END,
                           NULL) ZX_APP_TO_DOC_MISSING,
*/

                -- Check for source documents in zx lines det factors table and zx trx lines gt
                nvl2( lines_gt.source_trx_id,
          CASE WHEN ((NOT EXISTS
              (SELECT 1
               FROM  ZX_LINES_DET_FACTORS line,
               ZX_EVNT_CLS_MAPPINGS map
               WHERE lines_gt.application_id   = map.application_id
               AND   lines_gt.entity_code      = map.entity_code
               AND   lines_gt.event_class_code = map.event_class_code
               AND   line.application_id       = decode(lines_gt.source_event_class_code,
                   'INTERCOMPANY_TRX', map.intrcmp_src_appln_id,
                   lines_gt.source_application_id)
               AND   line.entity_code          = decode(lines_gt.source_event_class_code,
                   'INTERCOMPANY_TRX', map.intrcmp_src_entity_code,
                   lines_gt.source_entity_code)
               AND   line.event_class_code     = decode(lines_gt.source_event_class_code,
                                                 'INTERCOMPANY_TRX',
                                                 decode(lines_gt.line_class,
                                                        'AP_CREDIT_MEMO', 'CREDIT_MEMO',
                                                        'AP_DEBIT_MEMO','DEBIT_MEMO',
                                                        map.intrcmp_src_evnt_cls_code),
                                                 lines_gt.source_event_class_code)
               AND   line.trx_id               = lines_gt.source_trx_id
               AND   line.trx_line_id          = lines_gt.source_line_id
               AND   line.trx_level_type       = lines_gt.source_trx_level_type))
         AND ( NOT EXISTS
              (SELECT 1 FROM ZX_TRANSACTION_LINES_GT line,
               zx_evnt_cls_mappings map
               WHERE lines_gt.application_id   = map.application_id
               AND   lines_gt.entity_code      = map.entity_code
               AND   lines_gt.event_class_code = map.event_class_code
               AND   line.application_id       = decode(lines_gt.source_event_class_code,
                   'INTERCOMPANY_TRX', map.intrcmp_src_appln_id,
                   lines_gt.source_application_id)
               AND   line.entity_code          = decode(lines_gt.source_event_class_code,
                   'INTERCOMPANY_TRX', map.intrcmp_src_entity_code,
                   lines_gt.source_entity_code)
               AND   line.event_class_code     = decode(lines_gt.source_event_class_code,
                                                 'INTERCOMPANY_TRX',
                                                 decode(lines_gt.line_class,
                                                        'AP_CREDIT_MEMO', 'CREDIT_MEMO',
                                                        'AP_DEBIT_MEMO','DEBIT_MEMO',
                                                        map.intrcmp_src_evnt_cls_code),
                                                 lines_gt.source_event_class_code)
               AND   trx_id                    = lines_gt.source_trx_id
               AND   trx_line_id               = lines_gt.source_line_id
               AND   trx_level_type            = lines_gt.source_trx_level_type)))
                           THEN 'Y'
                           ELSE NULL END,
                           NULL) ZX_SOURCE_DOC_MISSING

        FROM ZX_TRX_HEADERS_GT             header,
             ZX_TRANSACTION_LINES_GT       lines_gt

        WHERE lines_gt.application_id = header.application_id
        AND   lines_gt.entity_code = header.entity_code
        AND   lines_gt.event_class_code = header.event_class_code
        AND   lines_gt.trx_id = header.trx_id;

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF ( g_level_statement >= g_current_runtime_level) THEN
    FND_LOG.STRING(g_level_statement,'ZX_VALIDATE_API_PKG.VALIDATE_TAX_ATTR',
    'No. of Rows inserted for Header Realted Validations '|| to_char(sql%ROWCOUNT) );
  END IF;

  IF ( g_level_event >= g_current_runtime_level) THEN
    FND_LOG.STRING(g_level_event,
       'ZX.PLSQL.ZX_VALIDATE_API_PKG.Validate_Other_Documents.END',
       'ZX_VALIDATE_API_PKG: Validate_Other_Documents(-)');
  END IF;

EXCEPTION
         WHEN OTHERS THEN
              IF (g_level_unexpected >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_unexpected,
                          'ZX_VALIDATE_API_PKG.Validate_Other_Documents',
                           sqlerrm);
              END IF;

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         app_exception.raise_exception;
END Validate_Other_Documents;


------------------ Procedure For pop_def_tax_classif_code  -----------------

--  PUBLIC PROCEDURE
--  pop_def_tax_classif_code
--
--  DESCRIPTION
--  This procedure populates the parameters need to pass to
--  ZX_TAX_DEFAULT_PKG.get_default_tax_classification to get the
--  default tax classification code, and updates each transaction
--  line with the default tax classification code found
--

-- Bug#3910168

PROCEDURE pop_def_tax_classif_code(
    x_return_status            OUT NOCOPY  VARCHAR2)
IS
  l_trx_line_id_tbl                   TRX_LINE_ID_TBL;
  l_trx_level_type_tbl                TRX_LEVEL_TYPE_TBL;
  -- bug#5066122- rm ship_from_party/site id
  --l_ship_from_party_id_tbl            SHIP_FROM_PARTY_ID_TBL;
  --l_ship_from_party_site_id_tbl       SHIP_FROM_PARTY_SITE_ID_TBL;
  l_account_ccid_tbl                  ACCOUNT_CCID_TBL;
  l_account_string_tbl                ACCOUNT_STRING_TBL;
  l_ship_to_location_id_tbl           SHIP_TO_LOCATION_ID_TBL;
  l_product_id_tbl                    PRODUCT_ID_TBL;
  l_product_type_tbl                  PRODUCT_TYPE_TBL;
  l_product_org_id_tbl                PRODUCT_ORG_ID_TBL;
  l_event_class_code_tbl              EVENT_CLASS_CODE_TBL;
  l_entity_code_tbl                   ENTITY_CODE_TBL;
  l_ship_to_cust_acct_su_id_tbl       SHIPTO_CUST_ACCT_SITEUSEID_TBL;
  l_bill_to_cust_acct_su_id_tbl       BILLTO_CUST_ACCT_SITEUSEID_TBL;
  l_internal_organization_id_tbl      INTERNAL_ORGANIZATION_ID_TBL;
  l_ledger_id_tbl                     LEDGER_ID_TBL;
  l_trx_date_tbl                      TRX_DATE_TBL;
  l_receivables_trx_type_id_tbl       RECEIVABLES_TRX_TYPE_ID_TBL;
  l_trx_id_tbl                        TRX_ID_TBL;
  l_application_id_tbl                APPLICATION_ID_TBL;
  l_ship_third_pty_acct_id_tbl        SHIP_THIRD_PTY_ACCT_ID_TBL;
  l_bill_third_pty_acct_id_tbl        BILL_THIRD_PTY_ACCT_ID_TBL;
  l_defaulting_attribute1_tbl         DEFAULTING_ATTRIBUTE1_TBL;
  l_defaulting_attribute2_tbl         DEFAULTING_ATTRIBUTE2_TBL;
  l_defaulting_attribute3_tbl         DEFAULTING_ATTRIBUTE3_TBL;
  l_defaulting_attribute4_tbl         DEFAULTING_ATTRIBUTE4_TBL;
  l_defaulting_attribute5_tbl         DEFAULTING_ATTRIBUTE5_TBL;
  l_defaulting_attribute6_tbl         DEFAULTING_ATTRIBUTE6_TBL;
  l_defaulting_attribute7_tbl         DEFAULTING_ATTRIBUTE7_TBL;
  l_defaulting_attribute8_tbl         DEFAULTING_ATTRIBUTE8_TBL;
  l_defaulting_attribute9_tbl         DEFAULTING_ATTRIBUTE9_TBL;
  l_defaulting_attribute10_tbl        DEFAULTING_ATTRIBUTE10_TBL;

  l_input_tax_classif_code_tbl        INPUT_TAX_CLASSIF_CODE_TBL;
  l_output_tax_classif_code_tbl       OUTPUT_TAX_CLASSIF_CODE_TBL;

  l_ref_doc_application_id_tbl        REF_DOC_APPLICATION_ID_TBL;
  l_ref_doc_entity_code_tbl           REF_DOC_ENTITY_CODE_TBL;
  l_ref_doc_event_class_code_tbl      REF_DOC_EVENT_CLASS_CODE_TBL;
  l_ref_doc_trx_id_tbl                REF_DOC_TRX_ID_TBL;
  l_ref_doc_line_id_tbl               REF_DOC_LINE_ID_TBL;
  l_ref_doc_trx_level_type_tbl        REF_DOC_TRX_LEVEL_TYPE_TBL;

  -- Bug#4868489
  l_legal_entity_id_tbl               LEGAL_ENTITY_ID_TBL;

  -- Bug#5066122
  -- add structures here to avoid changing spec
  --
  TYPE ship_thd_pty_acct_ste_id_tbl IS TABLE OF
    ZX_TRX_HEADERS_GT.ship_third_pty_acct_site_id%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE bill_thd_pty_acct_ste_id_tbl IS TABLE OF
    ZX_TRX_HEADERS_GT.bill_third_pty_acct_site_id%TYPE
    INDEX BY BINARY_INTEGER;

  l_ship_thd_pty_acct_ste_id_tbl      SHIP_THD_PTY_ACCT_STE_ID_TBL;
  l_bill_thd_pty_acct_ste_id_tbl      BILL_THD_PTY_ACCT_STE_ID_TBL;

  l_definforec                        ZX_API_PUB.def_tax_cls_code_info_rec_type;
  l_definforec_null                   ZX_API_PUB.def_tax_cls_code_info_rec_type;
  l_count                             NUMBER;
  l_error_buffer                      VARCHAR2(240);

  c_lines_per_commit CONSTANT NUMBER := ZX_TDS_CALC_SERVICES_PUB_PKG.G_LINES_PER_COMMIT;

 CURSOR get_parm_info_for_def_tax_csr
  IS
    SELECT
      L.trx_line_id,
      L.trx_level_type,
      -- L.ship_from_party_id,        -- bug#5066122
      -- L.ship_from_party_site_id,   -- bug#5066122
      L.account_ccid,
      L.account_string,
      L.ship_to_location_id,
      L.product_id,
      L.product_type,
      L.product_org_id,
      H.event_class_code,
      H.entity_code,
      NVL(L.ship_to_cust_acct_site_use_id, H.ship_to_cust_acct_site_use_id),
      NVL(L.bill_to_cust_acct_site_use_id, H.bill_to_cust_acct_site_use_id),
      H.internal_organization_id,
      H.ledger_id,
      H.trx_date,
      NVL(L.receivables_trx_type_id, H.receivables_trx_type_id),
      H.trx_id,
      H.application_id,
      H.legal_entity_id,
      NVL(L.ship_third_pty_acct_id, H.ship_third_pty_acct_id),
      NVL(L.bill_third_pty_acct_id, H.bill_third_pty_acct_id),
      NVL(L.ship_third_pty_acct_site_id, H.ship_third_pty_acct_site_id),
      NVL(L.bill_third_pty_acct_site_id, H.bill_third_pty_acct_site_id),
      L.ref_doc_application_id,
      L.ref_doc_entity_code,
      L.ref_doc_event_class_code,
      L.ref_doc_trx_id,
      L.ref_doc_line_id,
      L.ref_doc_trx_level_type,
      L.defaulting_attribute1,
      L.defaulting_attribute2,
      L.defaulting_attribute3,
      L.defaulting_attribute4,
      L.defaulting_attribute5,
      L.defaulting_attribute6,
      L.defaulting_attribute7,
      L.defaulting_attribute8,
      L.defaulting_attribute9,
      L.defaulting_attribute10
     -- L.input_tax_classification_code, --Bug 4919842
--      L.output_tax_classification_code --Bug 4919842
  FROM ZX_TRX_HEADERS_GT H,
       ZX_TRANSACTION_LINES_GT L
  WHERE L.application_id = H.application_id
    AND L.entity_code = H.entity_code
    AND L.event_class_code = H.event_class_code
    AND L.trx_id = H.trx_id
    AND L.line_level_action = 'CREATE'
    AND L.input_tax_classification_code IS NULL
    AND L.output_tax_classification_code IS NULL ;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_VALIDATE_API_PKG.pop_def_tax_classif_code.BEGIN',
                   'ZX_VALIDATE_API_PKG: pop_def_tax_classif_code(+)');
  END IF;

  --
  -- init error buffer and return status
  --
  x_return_status  := FND_API.G_RET_STS_SUCCESS;
  l_error_buffer   := NULL;

  OPEN get_parm_info_for_def_tax_csr;

  IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
     'ZX.PLSQL.ZX_VALIDATE_API_PKG.Validate_Other_Documents',
     'After opening the cursor - get_parm_info_for_def_tax_csr');
  END IF;

  LOOP
    FETCH get_parm_info_for_def_tax_csr BULK COLLECT INTO
                l_trx_line_id_tbl,
                l_trx_level_type_tbl,
                -- l_ship_from_party_id_tbl,     -- bug#5066122
                -- l_ship_from_party_site_id_tbl,-- bug#5066122
                l_account_ccid_tbl,
                l_account_string_tbl,
                l_ship_to_location_id_tbl,
                l_product_id_tbl,
                l_product_type_tbl,
                l_product_org_id_tbl,
                l_event_class_code_tbl,
                l_entity_code_tbl,
                l_ship_to_cust_acct_su_id_tbl,
                l_bill_to_cust_acct_su_id_tbl,
                l_internal_organization_id_tbl,
                l_ledger_id_tbl,
                l_trx_date_tbl,
                l_receivables_trx_type_iD_tbl,
                l_trx_id_tbl,
                l_application_id_tbl,
                l_legal_entity_id_tbl,
                l_ship_third_pty_acct_id_tbl,
                l_bill_third_pty_acct_id_tbl,
                l_ship_thd_pty_acct_ste_id_tbl,
                l_bill_thd_pty_acct_ste_id_tbl,
                l_ref_doc_application_id_tbl,
                l_ref_doc_entity_code_tbl,
                l_ref_doc_event_class_code_tbl,
                l_ref_doc_trx_id_tbl,
                l_ref_doc_line_id_tbl,
                l_ref_doc_trx_level_type_tbl,
                l_defaulting_attribute1_tbl,
                l_defaulting_attribute2_tbl,
                l_defaulting_attribute3_tbl,
                l_defaulting_attribute4_tbl,
                l_defaulting_attribute5_tbl,
                l_defaulting_attribute6_tbl,
                l_defaulting_attribute7_tbl,
                l_defaulting_attribute8_tbl,
                l_defaulting_attribute9_tbl,
                l_defaulting_attribute10_tbl
--    l_input_tax_classif_code_tbl,  --Bug 4919842
--    l_output_tax_classif_code_tbl  --Bug 4919842
      LIMIT C_LINES_PER_COMMIT;


    l_count := l_trx_line_id_tbl.COUNT;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_VALIDATE_API_PKG.pop_def_tax_classif_code',
                       'number of rows fetched = ' || to_char(l_count));
    END IF;

    IF l_count > 0 THEN

      FOR i IN 1.. l_count LOOP

        --
        -- init l_definforec
        --
        l_definforec := l_definforec_null;

        --
        -- populate fields in the record with values
        -- from zx_trx_headers_gt and zx_transaction_lines_gt
        --
        -- Bug#4310278- replace line_location_id with
        -- ref_doc columns

        l_definforec.ref_doc_application_id := l_ref_doc_application_id_tbl(i);
        l_definforec.ref_doc_entity_code := l_ref_doc_entity_code_tbl(i);
        l_definforec.ref_doc_event_class_code := l_ref_doc_event_class_code_tbl(i);
        l_definforec.ref_doc_trx_id := l_ref_doc_trx_id_tbl(i);
        l_definforec.ref_doc_line_id := l_ref_doc_line_id_tbl(i);
        l_definforec.ref_doc_trx_level_type := l_ref_doc_trx_level_type_tbl(i);

        -- bug#5066122
        --l_definforec.ship_third_pty_acct_id := l_ship_from_party_id_tbl(i);
        --l_definforec.ship_third_pty_acct_site_id :=  l_ship_from_party_site_id_tbl(i);

        l_definforec.account_ccid := l_account_ccid_tbl(i);

        l_definforec.account_string := l_account_string_tbl(i);
        l_definforec.ship_to_location_id := l_ship_to_location_id_tbl(i);
        l_definforec.product_id :=  l_product_id_tbl(i);
        l_definforec.product_org_id := l_product_org_id_tbl(i);
        l_definforec.application_id := l_application_id_tbl(i);
        l_definforec.internal_organization_id := l_internal_organization_id_tbl(i);
        l_definforec.event_class_code := l_event_class_code_tbl(i);
        l_definforec.entity_code := l_entity_code_tbl(i);
        l_definforec.ship_to_cust_acct_site_use_id := l_ship_to_cust_acct_su_id_tbl(i);
        l_definforec.bill_to_cust_acct_site_use_id := l_bill_to_cust_acct_su_id_tbl(i);
        l_definforec.ledger_id := l_ledger_id_tbl(i);
        l_definforec.trx_date := l_trx_date_tbl(i);
        l_definforec.receivables_trx_type_id := l_receivables_trx_type_id_tbl(i);
        l_definforec.trx_id := l_trx_id_tbl(i);
        l_definforec.trx_line_id := l_trx_line_id_tbl(i);
        l_definforec.ship_third_pty_acct_id := l_ship_third_pty_acct_id_tbl(i);
        l_definforec.bill_third_pty_acct_id :=  l_bill_third_pty_acct_id_tbl(i);
        --
        -- Bug#5066122- added ship/bill third_pty_acct_site_id
        --
        l_definforec.ship_third_pty_acct_site_id := l_ship_thd_pty_acct_ste_id_tbl(i);
        l_definforec.bill_third_pty_acct_site_id := l_bill_thd_pty_acct_ste_id_tbl(i);
        -- Bug#4868489-  add legal_entity_id
        l_definforec.legal_entity_id := l_legal_entity_id_tbl(i);

        --
        -- Bug#4868489- remove call to map_parm_for_def_tax_classif
        --
        l_definforec.defaulting_attribute1  :=  l_defaulting_attribute1_tbl(i);
        l_definforec.defaulting_attribute2  :=  l_defaulting_attribute2_tbl(i);
        l_definforec.defaulting_attribute3  :=  l_defaulting_attribute3_tbl(i);
        l_definforec.defaulting_attribute4  :=  l_defaulting_attribute4_tbl(i);
        l_definforec.defaulting_attribute5  :=  l_defaulting_attribute5_tbl(i);
        l_definforec.defaulting_attribute6  :=  l_defaulting_attribute6_tbl(i);
        l_definforec.defaulting_attribute7  :=  l_defaulting_attribute7_tbl(i);
        l_definforec.defaulting_attribute8  :=  l_defaulting_attribute8_tbl(i);
        l_definforec.defaulting_attribute9  :=  l_defaulting_attribute9_tbl(i);
        l_definforec.defaulting_attribute10 :=  l_defaulting_attribute10_tbl(i);

        --
        -- get default tax classification code
        --
    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
       'ZX.PLSQL.ZX_VALIDATE_API_PKG.pop_def_tax_classif_code',
       'Calling ZX_TAX_DEFAULT_PKG.get_default_tax_classification for record '||to_char(i));
    END IF;
        /* Bug 4919842 : Conditionally Call ZX_TAX_DEFAULT_PKG.get_default_tax_classification if both input
  AND output tax classification codes are passed as null */

       /* Removed the conditional check and included in the 'get_parm_info_for_def_tax_csr' cursor itself
       IF ( l_input_tax_classif_code_tbl(i) IS NULL AND
       l_output_tax_classif_code_tbl(i) IS NULL ) THEN */
    ZX_TAX_DEFAULT_PKG.get_default_tax_classification(
            l_definforec,
            x_return_status,
            l_error_buffer);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      EXIT;
    END IF;

    --
    -- store returned tax classification code for update to
    -- zx_transaction_lines_gt later
    --
    l_input_tax_classif_code_tbl(i)  := l_definforec.input_tax_classification_code;
    l_output_tax_classif_code_tbl(i) := l_definforec.output_tax_classification_code;
       -- END IF ; -- end if for the conditional call
      END LOOP;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        EXIT;
      END IF;

      --
      -- update zx_transaction_lines_gt with the default
      -- tax classification code found
      --
    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
       'ZX.PLSQL.ZX_VALIDATE_API_PKG.pop_def_tax_classif_code',
       'update zx_transaction_lines_gt with the default tax classification code found ');
    END IF;

      FORALL i IN 1 .. l_count
        UPDATE ZX_TRANSACTION_LINES_GT
          SET input_tax_classification_code =
                    l_input_tax_classif_code_tbl(i),
              output_tax_classification_code =
                    l_output_tax_classif_code_tbl(i)
          WHERE application_id = l_application_id_tbl(i)
            AND entity_code = l_entity_code_tbl(i)
            AND event_class_code = l_event_class_code_tbl(i)
            AND trx_id = l_trx_id_tbl(i)
            AND trx_line_id = l_trx_line_id_tbl(i)
            AND trx_level_type = l_trx_level_type_tbl(i);

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_VALIDATE_API_PKG.pop_def_tax_classif_code',
                       'fetch next set of records for defaulting ....');
      END IF;
    ELSE
      --
      -- no more records to process
      --
      CLOSE get_parm_info_for_def_tax_csr;
      EXIT;
    END IF;
  END LOOP;

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    CLOSE get_parm_info_for_def_tax_csr;
    RETURN;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_VALIDATE_API_PKG.pop_def_tax_classif_code',
                   'x_return_status = ' || x_return_status);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_VALIDATE_API_PKG.pop_def_tax_classif_code',
                   'l_error_buffer  = ' || l_error_buffer);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_VALIDATE_API_PKG.pop_def_tax_classif_code.END',
                   'ZX_VALIDATE_API_PKG: pop_def_tax_classif_code(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF get_parm_info_for_def_tax_csr%ISOPEN THEN
      CLOSE get_parm_info_for_def_tax_csr;
    END IF;
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','pop_def_tax_classif_code- '|| l_error_buffer);
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_VALIDATE_API_PKG.pop_def_tax_classif_code',
                      l_error_buffer);
    END IF;

END pop_def_tax_classif_code;


/* This procedure is used to default the additional tax attributes
   Internally we are calling the default automation api to populate the values.
*/

PROCEDURE def_additional_tax_attribs IS

   c_lines_per_commit CONSTANT NUMBER := ZX_TDS_CALC_SERVICES_PUB_PKG.G_LINES_PER_COMMIT;

   CURSOR gtt_to_glb_strctr_csr
   IS

  SELECT

  INTERNAL_ORGANIZATION_ID ,
  header.APPLICATION_ID APPLICATION_ID,
  header.ENTITY_CODE    ENTITY_CODE,
  header.EVENT_CLASS_CODE EVENT_CLASS_CODE,
  EVENT_TYPE_CODE               ,
  header.TRX_ID    TRX_ID       ,
  TRX_LEVEL_TYPE                ,
  TRX_LINE_ID                   ,
  LINE_LEVEL_ACTION             ,
  LINE_CLASS                    ,
  TRX_DATE                      ,
  TRX_DOC_REVISION              ,
  LEDGER_ID                     ,
  TRX_CURRENCY_CODE             ,
  CURRENCY_CONVERSION_DATE      ,
  CURRENCY_CONVERSION_RATE      ,
  CURRENCY_CONVERSION_TYPE      ,
  MINIMUM_ACCOUNTABLE_UNIT      ,
  PRECISION                     ,
  TRX_SHIPPING_DATE             ,
  TRX_RECEIPT_DATE              ,
  LEGAL_ENTITY_ID               ,
  ROUNDING_SHIP_TO_PARTY_ID     ,
  ROUNDING_SHIP_FROM_PARTY_ID   ,
  ROUNDING_BILL_TO_PARTY_ID     ,
  ROUNDING_BILL_FROM_PARTY_ID   ,
  RNDG_SHIP_TO_PARTY_SITE_ID    ,
  RNDG_SHIP_FROM_PARTY_SITE_ID  ,
  RNDG_BILL_TO_PARTY_SITE_ID    ,
  RNDG_BILL_FROM_PARTY_SITE_ID  ,
  ESTABLISHMENT_ID              ,
  TRX_LINE_TYPE                 ,
  TRX_LINE_DATE                 ,
  TRX_BUSINESS_CATEGORY         ,
  LINE_INTENDED_USE             ,
  USER_DEFINED_FISC_CLASS       ,
  LINE_AMT                      ,
  TRX_LINE_QUANTITY             ,
  UNIT_PRICE                    ,
  EXEMPT_CERTIFICATE_NUMBER     ,
  EXEMPT_REASON                 ,
  CASH_DISCOUNT                 ,
  VOLUME_DISCOUNT               ,
  TRADING_DISCOUNT              ,
  TRANSFER_CHARGE               ,
  TRANSPORTATION_CHARGE         ,
  INSURANCE_CHARGE              ,
  OTHER_CHARGE                  ,
  PRODUCT_ID                    ,
  PRODUCT_FISC_CLASSIFICATION,
  PRODUCT_ORG_ID             ,
  UOM_CODE                   ,
  PRODUCT_TYPE               ,
  PRODUCT_CODE               ,
  PRODUCT_CATEGORY           ,
  TRX_SIC_CODE               ,
  FOB_POINT                  ,
  SHIP_TO_PARTY_ID           ,
  SHIP_FROM_PARTY_ID         ,
  POA_PARTY_ID               ,
  POO_PARTY_ID               ,
  BILL_TO_PARTY_ID           ,
  BILL_FROM_PARTY_ID         ,
  MERCHANT_PARTY_ID          ,
  SHIP_TO_PARTY_SITE_ID      ,
  SHIP_FROM_PARTY_SITE_ID    ,
  POA_PARTY_SITE_ID          ,
  POO_PARTY_SITE_ID          ,
  BILL_TO_PARTY_SITE_ID      ,
  BILL_FROM_PARTY_SITE_ID    ,
  SHIP_TO_LOCATION_ID        ,
  SHIP_FROM_LOCATION_ID      ,
  POA_LOCATION_ID            ,
  POO_LOCATION_ID            ,
  BILL_TO_LOCATION_ID        ,
  BILL_FROM_LOCATION_ID      ,
  ACCOUNT_CCID               ,
  ACCOUNT_STRING             ,
  MERCHANT_PARTY_COUNTRY     ,
  NVL(lines.RECEIVABLES_TRX_TYPE_ID, header.RECEIVABLES_TRX_TYPE_ID),
  REF_DOC_APPLICATION_ID     ,
  REF_DOC_ENTITY_CODE        ,
  REF_DOC_EVENT_CLASS_CODE   ,
  REF_DOC_TRX_ID             ,
  -- REF_DOC_HDR_TRX_USER_KEY1  ,
  -- REF_DOC_HDR_TRX_USER_KEY2  ,
  -- REF_DOC_HDR_TRX_USER_KEY3  ,
  -- REF_DOC_HDR_TRX_USER_KEY4  ,
  -- REF_DOC_HDR_TRX_USER_KEY5  ,
  -- REF_DOC_HDR_TRX_USER_KEY6  ,
  REF_DOC_LINE_ID            ,
  -- REF_DOC_LIN_TRX_USER_KEY1  ,
  -- REF_DOC_LIN_TRX_USER_KEY2  ,
  -- REF_DOC_LIN_TRX_USER_KEY3  ,
  -- REF_DOC_LIN_TRX_USER_KEY4  ,
  -- REF_DOC_LIN_TRX_USER_KEY5  ,
  -- REF_DOC_LIN_TRX_USER_KEY6  ,
  REF_DOC_LINE_QUANTITY      ,
  RELATED_DOC_APPLICATION_ID ,
  RELATED_DOC_ENTITY_CODE    ,
  RELATED_DOC_EVENT_CLASS_CODE,
  RELATED_DOC_TRX_ID         ,
  -- REL_DOC_HDR_TRX_USER_KEY1  ,
  -- REL_DOC_HDR_TRX_USER_KEY2  ,
  -- REL_DOC_HDR_TRX_USER_KEY3  ,
  -- REL_DOC_HDR_TRX_USER_KEY4  ,
  -- REL_DOC_HDR_TRX_USER_KEY5  ,
  -- REL_DOC_HDR_TRX_USER_KEY6  ,
  RELATED_DOC_NUMBER         ,
  RELATED_DOC_DATE           ,
  APPLIED_FROM_APPLICATION_ID,
  APPLIED_FROM_ENTITY_CODE   ,
  APPLIED_FROM_EVENT_CLASS_CODE,
  APPLIED_FROM_TRX_ID        ,
  -- APP_FROM_HDR_TRX_USER_KEY1 ,
  -- APP_FROM_HDR_TRX_USER_KEY2 ,
  -- APP_FROM_HDR_TRX_USER_KEY3 ,
  -- APP_FROM_HDR_TRX_USER_KEY4 ,
  -- APP_FROM_HDR_TRX_USER_KEY5 ,
  -- APP_FROM_HDR_TRX_USER_KEY6 ,
  APPLIED_FROM_LINE_ID       ,
  APPLIED_FROM_TRX_NUMBER    ,
  -- APP_FROM_LIN_TRX_USER_KEY1 ,
  -- APP_FROM_LIN_TRX_USER_KEY2 ,
  -- APP_FROM_LIN_TRX_USER_KEY3 ,
  -- APP_FROM_LIN_TRX_USER_KEY4 ,
  -- APP_FROM_LIN_TRX_USER_KEY5 ,
  -- APP_FROM_LIN_TRX_USER_KEY6 ,
  ADJUSTED_DOC_APPLICATION_ID,
  ADJUSTED_DOC_ENTITY_CODE   ,
  ADJUSTED_DOC_EVENT_CLASS_CODE,
  ADJUSTED_DOC_TRX_ID        ,
  -- ADJ_DOC_HDR_TRX_USER_KEY1  ,
  -- ADJ_DOC_HDR_TRX_USER_KEY2  ,
  -- ADJ_DOC_HDR_TRX_USER_KEY3  ,
  -- ADJ_DOC_HDR_TRX_USER_KEY4  ,
  -- ADJ_DOC_HDR_TRX_USER_KEY5  ,
  -- ADJ_DOC_HDR_TRX_USER_KEY6  ,
  ADJUSTED_DOC_LINE_ID       ,
  -- ADJ_DOC_LIN_TRX_USER_KEY1  ,
  -- ADJ_DOC_LIN_TRX_USER_KEY2  ,
  -- ADJ_DOC_LIN_TRX_USER_KEY3  ,
  -- ADJ_DOC_LIN_TRX_USER_KEY4  ,
  -- ADJ_DOC_LIN_TRX_USER_KEY5  ,
  -- ADJ_DOC_LIN_TRX_USER_KEY6  ,
  ADJUSTED_DOC_NUMBER        ,
  ADJUSTED_DOC_DATE          ,
  APPLIED_TO_APPLICATION_ID  ,
  APPLIED_TO_ENTITY_CODE     ,
  APPLIED_TO_EVENT_CLASS_CODE,
  APPLIED_TO_TRX_ID          ,
  -- APP_TO_HDR_TRX_USER_KEY1   ,
  -- APP_TO_HDR_TRX_USER_KEY2   ,
  -- APP_TO_HDR_TRX_USER_KEY3   ,
  -- APP_TO_HDR_TRX_USER_KEY4   ,
  -- APP_TO_HDR_TRX_USER_KEY5   ,
  -- APP_TO_HDR_TRX_USER_KEY6   ,
  APPLIED_TO_TRX_LINE_ID     ,
  -- APP_TO_LIN_TRX_USER_KEY1   ,
  -- APP_TO_LIN_TRX_USER_KEY2   ,
  -- APP_TO_LIN_TRX_USER_KEY3   ,
  -- APP_TO_LIN_TRX_USER_KEY4   ,
  -- APP_TO_LIN_TRX_USER_KEY5   ,
  -- APP_TO_LIN_TRX_USER_KEY6   ,
  TRX_ID_LEVEL2              ,
  TRX_ID_LEVEL3              ,
  TRX_ID_LEVEL4              ,
  TRX_ID_LEVEL5              ,
  TRX_ID_LEVEL6              ,
  -- header.HDR_TRX_USER_KEY1       HDR_TRX_USER_KEY1 ,
  -- header.HDR_TRX_USER_KEY2       HDR_TRX_USER_KEY2 ,
  -- header.HDR_TRX_USER_KEY3       HDR_TRX_USER_KEY3 ,
  -- header.HDR_TRX_USER_KEY4       HDR_TRX_USER_KEY4 ,
  -- header.HDR_TRX_USER_KEY5       HDR_TRX_USER_KEY5 ,
  -- header.HDR_TRX_USER_KEY6       HDR_TRX_USER_KEY6 ,
  -- LINE_TRX_USER_KEY1         ,
  -- LINE_TRX_USER_KEY2         ,
  -- LINE_TRX_USER_KEY3         ,
  -- LINE_TRX_USER_KEY4         ,
  -- LINE_TRX_USER_KEY5         ,
  -- LINE_TRX_USER_KEY6         ,
  TRX_NUMBER                 ,
  TRX_DESCRIPTION            ,
  TRX_LINE_NUMBER            ,
  TRX_LINE_DESCRIPTION       ,
  PRODUCT_DESCRIPTION        ,
  TRX_WAYBILL_NUMBER         ,
  TRX_COMMUNICATED_DATE      ,
  TRX_LINE_GL_DATE           ,
  BATCH_SOURCE_ID            ,
  BATCH_SOURCE_NAME          ,
  DOC_SEQ_ID                 ,
  DOC_SEQ_NAME               ,
  DOC_SEQ_VALUE              ,
  TRX_DUE_DATE               ,
  TRX_TYPE_DESCRIPTION       ,
  MERCHANT_PARTY_NAME        ,
  MERCHANT_PARTY_DOCUMENT_NUMBER,
  MERCHANT_PARTY_REFERENCE   ,
  MERCHANT_PARTY_TAXPAYER_ID ,
  MERCHANT_PARTY_TAX_REG_NUMBER,
  PAYING_PARTY_ID            ,
  OWN_HQ_PARTY_ID            ,
  TRADING_HQ_PARTY_ID        ,
  POI_PARTY_ID               ,
  POD_PARTY_ID               ,
  TITLE_TRANSFER_PARTY_ID    ,
  PAYING_PARTY_SITE_ID       ,
  OWN_HQ_PARTY_SITE_ID       ,
  TRADING_HQ_PARTY_SITE_ID   ,
  POI_PARTY_SITE_ID          ,
  POD_PARTY_SITE_ID          ,
  TITLE_TRANSFER_PARTY_SITE_ID,
  PAYING_LOCATION_ID         ,
  OWN_HQ_LOCATION_ID         ,
  TRADING_HQ_LOCATION_ID     ,
  POC_LOCATION_ID            ,
  POI_LOCATION_ID            ,
  POD_LOCATION_ID            ,
  TITLE_TRANSFER_LOCATION_ID ,
  ASSESSABLE_VALUE           ,
  ASSET_FLAG                 ,
  ASSET_NUMBER               ,
  ASSET_ACCUM_DEPRECIATION   ,
  ASSET_TYPE                 ,
  ASSET_COST                 ,
  -- NUMERIC1                   ,
  -- NUMERIC2                   ,
  -- NUMERIC3                   ,
  -- NUMERIC4                   ,
  -- NUMERIC5                   ,
  -- NUMERIC6                   ,
  -- NUMERIC7                   ,
  -- NUMERIC8                   ,
  -- NUMERIC9                   ,
  -- NUMERIC10                  ,
  -- CHAR1                      ,
  -- CHAR2                      ,
  -- CHAR3                      ,
  -- CHAR4                      ,
  -- CHAR5                      ,
  -- CHAR6                      ,
  -- CHAR7                      ,
  -- CHAR8                      ,
  -- CHAR9                      ,
  -- CHAR10                     ,
  -- DATE1                      ,
  -- DATE2                      ,
  -- DATE3                      ,
  -- DATE4                      ,
  -- DATE5                      ,
  -- DATE6                      ,
  -- DATE7                      ,
  -- DATE8                      ,
  -- DATE9                      ,
  -- DATE10                     ,
  FIRST_PTY_ORG_ID           ,
  TAX_EVENT_CLASS_CODE       ,
  TAX_EVENT_TYPE_CODE        ,
  DOC_EVENT_STATUS               ,
  -- RDNG_SHIP_TO_PTY_TX_PROF_ID    ,
  -- RDNG_SHIP_FROM_PTY_TX_PROF_ID  ,
  -- RDNG_BILL_TO_PTY_TX_PROF_ID    ,
  -- RDNG_BILL_FROM_PTY_TX_PROF_ID  ,
  -- RDNG_SHIP_TO_PTY_TX_P_ST_ID    ,
  -- RDNG_SHIP_FROM_PTY_TX_P_ST_ID  ,
  -- RDNG_BILL_TO_PTY_TX_P_ST_ID    ,
  -- RDNG_BILL_FROM_PTY_TX_P_ST_ID  ,
  SHIP_TO_PARTY_TAX_PROF_ID      ,
  SHIP_FROM_PARTY_TAX_PROF_ID    ,
  POA_PARTY_TAX_PROF_ID          ,
  POO_PARTY_TAX_PROF_ID          ,
  PAYING_PARTY_TAX_PROF_ID       ,
  OWN_HQ_PARTY_TAX_PROF_ID       ,
  TRADING_HQ_PARTY_TAX_PROF_ID   ,
  POI_PARTY_TAX_PROF_ID          ,
  POD_PARTY_TAX_PROF_ID          ,
  BILL_TO_PARTY_TAX_PROF_ID      ,
  BILL_FROM_PARTY_TAX_PROF_ID    ,
  TITLE_TRANS_PARTY_TAX_PROF_ID  ,
  SHIP_TO_SITE_TAX_PROF_ID       ,
  SHIP_FROM_SITE_TAX_PROF_ID     ,
  POA_SITE_TAX_PROF_ID           ,
  POO_SITE_TAX_PROF_ID           ,
  PAYING_SITE_TAX_PROF_ID        ,
  OWN_HQ_SITE_TAX_PROF_ID        ,
  TRADING_HQ_SITE_TAX_PROF_ID    ,
  POI_SITE_TAX_PROF_ID           ,
  POD_SITE_TAX_PROF_ID           ,
  BILL_TO_SITE_TAX_PROF_ID       ,
  BILL_FROM_SITE_TAX_PROF_ID     ,
  TITLE_TRANS_SITE_TAX_PROF_ID   ,
  MERCHANT_PARTY_TAX_PROF_ID     ,
  HQ_ESTB_PARTY_TAX_PROF_ID      ,
  DOCUMENT_SUB_TYPE              ,
  SUPPLIER_TAX_INVOICE_NUMBER    ,
  SUPPLIER_TAX_INVOICE_DATE      ,
  SUPPLIER_EXCHANGE_RATE         ,
  TAX_INVOICE_DATE               ,
  TAX_INVOICE_NUMBER             ,
  LINE_AMT_INCLUDES_TAX_FLAG     ,
  QUOTE_FLAG                     ,
  DEFAULT_TAXATION_COUNTRY       ,
  HISTORICAL_FLAG                ,
  INTERNAL_ORG_LOCATION_ID       ,
  CTRL_HDR_TX_APPL_FLAG          ,
  CTRL_TOTAL_HDR_TX_AMT          ,
  CTRL_TOTAL_LINE_TX_AMT         ,
  --NULL DIST_LEVEL_ACTION       ,
  --NULL APPLIED_FROM_TAX_DIST_ID,
  --NULL ADJUSTED_DOC_TAX_DIST_ID,
  --NULL TASK_ID,
  --NULL AWARD_ID,
  --NULL PROJECT_ID,
  --NULL EXPENDITURE_TYPE,
  --NULL EXPENDITURE_ORGANIZATION_ID,
  --NULL EXPENDITURE_ITEM_DATE,
  --NULL TRX_LINE_DIST_AMT,
  --NULL TRX_LINE_DIST_QUANTITY,
  --NULL REF_DOC_CURR_CONV_RATE,
  --NULL ITEM_DIST_NUMBER,
  --NULL REF_DOC_DIST_ID,
  --NULL TRX_LINE_DIST_TAX_AMT,
  --NULL TRX_LINE_DIST_ID ,
  --NULL DIST_TRX_USER_KEY1,
  --NULL DIST_TRX_USER_KEY2,
  --NULL DIST_TRX_USER_KEY3,
  --NULL DIST_TRX_USER_KEY4,
  --NULL DIST_TRX_USER_KEY5,
  --NULL DIST_TRX_USER_KEY6,
  --NULL APPLIED_FROM_DIST_ID,
  --NULL APP_FROM_DST_TRX_USER_KEY1 ,
  --NULL APP_FROM_DST_TRX_USER_KEY2,
  --NULL APP_FROM_DST_TRX_USER_KEY3,
  --NULL APP_FROM_DST_TRX_USER_KEY4,
  --NULL APP_FROM_DST_TRX_USER_KEY5,
  --NULL APP_FROM_DST_TRX_USER_KEY6,
  --NULL ADJUSTED_DOC_DIST_ID,
  --NULL ADJ_DOC_DST_TRX_USER_KEY1,
  --NULL ADJ_DOC_DST_TRX_USER_KEY2,
  --NULL ADJ_DOC_DST_TRX_USER_KEY3,
  --NULL ADJ_DOC_DST_TRX_USER_KEY4,
  --NULL ADJ_DOC_DST_TRX_USER_KEY5,
  --NULL ADJ_DOC_DST_TRX_USER_KEY6,
  INPUT_TAX_CLASSIFICATION_CODE   ,
  OUTPUT_TAX_CLASSIFICATION_CODE  ,
  PORT_OF_ENTRY_CODE              ,
  TAX_REPORTING_FLAG              ,
  --NULL TAX_AMT_INCLUDED_FLAG    ,
  --NULL COMP0UNDING_TAX_FLAG     ,
  NVL(lines.SHIP_THIRD_PTY_ACCT_SITE_ID, header.SHIP_THIRD_PTY_ACCT_SITE_ID),
  NVL(lines.BILL_THIRD_PTY_ACCT_SITE_ID, header.BILL_THIRD_PTY_ACCT_SITE_ID),
  NVL(lines.SHIP_TO_CUST_ACCT_SITE_USE_ID, header.SHIP_TO_CUST_ACCT_SITE_USE_ID),
  NVL(lines.BILL_TO_CUST_ACCT_SITE_USE_ID, header.BILL_TO_CUST_ACCT_SITE_USE_ID),
  PROVNL_TAX_DETERMINATION_DATE   ,
  NVL(lines.SHIP_THIRD_PTY_ACCT_ID, header.SHIP_THIRD_PTY_ACCT_ID),
  NVL(lines.BILL_THIRD_PTY_ACCT_ID, header.BILL_THIRD_PTY_ACCT_ID),
  SOURCE_APPLICATION_ID           ,
  SOURCE_ENTITY_CODE              ,
  SOURCE_EVENT_CLASS_CODE         ,
  SOURCE_TRX_ID                   ,
  SOURCE_LINE_ID                  ,
  SOURCE_TRX_LEVEL_TYPE           ,
  --NULL INSERT_UPDATE_FLAG       ,
  header.APPLIED_TO_TRX_NUMBER     APPLIED_TO_TRX_NUMBER        ,
  START_EXPENSE_DATE              ,
  TRX_BATCH_ID                    ,
  --NULL RECORD_TYPE_CODE         ,
  REF_DOC_TRX_LEVEL_TYPE          ,
  APPLIED_FROM_TRX_LEVEL_TYPE     ,
  APPLIED_TO_TRX_LEVEL_TYPE       ,
  ADJUSTED_DOC_TRX_LEVEL_TYPE     ,
  DEFAULTING_ATTRIBUTE1           ,
  DEFAULTING_ATTRIBUTE2           ,
  DEFAULTING_ATTRIBUTE3           ,
  DEFAULTING_ATTRIBUTE4           ,
  DEFAULTING_ATTRIBUTE5           ,
  DEFAULTING_ATTRIBUTE6           ,
  DEFAULTING_ATTRIBUTE7           ,
  DEFAULTING_ATTRIBUTE8           ,
  DEFAULTING_ATTRIBUTE9           ,
  DEFAULTING_ATTRIBUTE10          ,
  --NULL TAX_PROCESSING_COMPLETED_FLAG,
  APPLICATION_DOC_STATUS          ,
  --NULL OVERRIDE_RECOVERY_RATE   ,
  --NULL TAX_CALCULATION_DONE_FLAG,
  SOURCE_TAX_LINE_ID              ,
  --NULL REVERSED_APPLN_ID        ,
  --NULL REVERSED_ENTITY_CODE,
  --NULL REVERSED_EVNT_CLS_CODE,
  --NULL REVERSED_TRX_ID,
  --NULL REVERSED_TRX_LEVEL_TYPE,
  --NULL REVERSED_TRX_LINE_ID,
  EXEMPTION_CONTROL_FLAG          ,
  EXEMPT_REASON_CODE              ,
  INTERFACE_ENTITY_CODE           ,
  INTERFACE_LINE_ID               ,
  HISTORICAL_TAX_CODE_ID    ,
  USER_UPD_DET_FACTORS_FLAG -- Bug 4703541
  FROM
     ZX_TRANSACTION_LINES_GT Lines,
     ZX_TRX_HEADERS_GT Header

  WHERE

      Lines.application_id = Header.application_id
  AND Lines.entity_code = Header.entity_code
  AND Lines.event_class_code = Header.event_class_code
  AND Lines.trx_id = Header.trx_id;

  x_return_status       VARCHAR2(20);
  l_error_buffer        VARCHAR2(240);
  l_event_class_rec     ZX_API_PUB.event_class_rec_type;

        l_prev_trx_id             ZX_TRX_HEADERS_GT.TRX_ID%TYPE;
        l_prev_application_id     ZX_TRX_HEADERS_GT.APPLICATION_ID%TYPE;
        l_prev_entity_code        ZX_TRX_HEADERS_GT.ENTITY_CODE%TYPE;
        l_prev_event_class_code   ZX_TRX_HEADERS_GT.EVENT_CLASS_CODE%TYPE;

        l_cur_trx_id              ZX_TRX_HEADERS_GT.TRX_ID%TYPE;
        l_cur_application_id      ZX_TRX_HEADERS_GT.APPLICATION_ID%TYPE;
        l_cur_entity_code         ZX_TRX_HEADERS_GT.ENTITY_CODE%TYPE;
        l_cur_event_class_code    ZX_TRX_HEADERS_GT.EVENT_CLASS_CODE%TYPE;

--   Bug 4703541
--  global_structure_rec  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_rec_type;


BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_event >= g_current_runtime_level ) THEN
  FND_LOG.STRING(g_level_event,
       'ZX.PLSQL.ZX_VALIDATE_API_PKG.def_additional_tax_attribs.BEGIN',
       'ZX_VALIDATE_API_PKG: def_additional_tax_attribs(+)');
  END IF;

/** Bug 4703541 :
Change Made : Replace global_structure_rec with ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl
as this is being directly referred in ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS **/
    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
       'ZX.PLSQL.ZX_VALIDATE_API_PKG.def_additional_tax_attribs',
       'Before opening the cursor - gtt_to_glb_strctr_csr');
    END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;
  OPEN gtt_to_glb_strctr_csr;

    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
       'ZX.PLSQL.ZX_VALIDATE_API_PKG.def_additional_tax_attribs',
       'After opening the cursor - gtt_to_glb_strctr_csr');
    END IF;

    LOOP
  FETCH gtt_to_glb_strctr_csr
  BULK COLLECT INTO
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INTERNAL_ORGANIZATION_ID,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLICATION_ID,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ENTITY_CODE,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EVENT_CLASS_CODE,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EVENT_TYPE_CODE ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LEVEL_TYPE,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_ID ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_LEVEL_ACTION,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_CLASS ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_DATE,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_DOC_REVISION,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LEDGER_ID,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_CURRENCY_CODE,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_DATE,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_RATE ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_TYPE,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.MINIMUM_ACCOUNTABLE_UNIT,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRECISION,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_SHIPPING_DATE ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_RECEIPT_DATE,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LEGAL_ENTITY_ID ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_SHIP_TO_PARTY_ID,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_SHIP_FROM_PARTY_ID,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_BILL_TO_PARTY_ID,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_BILL_FROM_PARTY_ID,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_SHIP_TO_PARTY_SITE_ID,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_SHIP_FROM_PARTY_SITE_ID,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_BILL_TO_PARTY_SITE_ID,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_BILL_FROM_PARTY_SITE_ID ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ESTABLISHMENT_ID ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_TYPE ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_DATE,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_BUSINESS_CATEGORY,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_INTENDED_USE,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.USER_DEFINED_FISC_CLASS,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_AMT,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_QUANTITY  ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.UNIT_PRICE,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EXEMPT_CERTIFICATE_NUMBER,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EXEMPT_REASON,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CASH_DISCOUNT,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.VOLUME_DISCOUNT,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRADING_DISCOUNT,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRANSFER_CHARGE,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRANSPORTATION_CHARGE,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INSURANCE_CHARGE,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OTHER_CHARGE,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_ID ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_FISC_CLASSIFICATION,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_ORG_ID             ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.UOM_CODE,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_TYPE ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_CODE,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_CATEGORY,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_SIC_CODE ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.FOB_POINT,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_TO_PARTY_ID,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_FROM_PARTY_ID,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POA_PARTY_ID ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POO_PARTY_ID,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_TO_PARTY_ID,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_FROM_PARTY_ID,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.MERCHANT_PARTY_ID,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_TO_PARTY_SITE_ID,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_FROM_PARTY_SITE_ID ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POA_PARTY_SITE_ID ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POO_PARTY_SITE_ID,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_TO_PARTY_SITE_ID,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_FROM_PARTY_SITE_ID,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_TO_LOCATION_ID ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_FROM_LOCATION_ID,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POA_LOCATION_ID ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POO_LOCATION_ID  ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_TO_LOCATION_ID,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_FROM_LOCATION_ID,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ACCOUNT_CCID  ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ACCOUNT_STRING   ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.MERCHANT_PARTY_COUNTRY ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RECEIVABLES_TRX_TYPE_ID ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_APPLICATION_ID ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_ENTITY_CODE,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_EVENT_CLASS_CODE,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_TRX_ID  ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY1,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY2,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY3,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY4,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY5,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_HDR_TRX_USER_KEY6,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_LINE_ID   ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY1,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY2,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY3,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY4,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY5,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_LIN_TRX_USER_KEY6,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_LINE_QUANTITY,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RELATED_DOC_APPLICATION_ID ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RELATED_DOC_ENTITY_CODE ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RELATED_DOC_EVENT_CLASS_CODE,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RELATED_DOC_TRX_ID,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REL_DOC_HDR_TRX_USER_KEY1 ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REL_DOC_HDR_TRX_USER_KEY2 ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REL_DOC_HDR_TRX_USER_KEY3 ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REL_DOC_HDR_TRX_USER_KEY4 ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REL_DOC_HDR_TRX_USER_KEY5 ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REL_DOC_HDR_TRX_USER_KEY6 ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RELATED_DOC_NUMBER,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RELATED_DOC_DATE  ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_FROM_APPLICATION_ID,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_FROM_ENTITY_CODE   ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_FROM_EVENT_CLASS_CODE,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_FROM_TRX_ID        ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY1 ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY2 ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY3 ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY4 ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY5 ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_HDR_TRX_USER_KEY6 ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_FROM_LINE_ID ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_FROM_TRX_NUMBER    ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY1 ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY2 ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY3 ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY4 ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY5 ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_FROM_LIN_TRX_USER_KEY6 ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJUSTED_DOC_APPLICATION_ID,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJUSTED_DOC_ENTITY_CODE   ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJUSTED_DOC_EVENT_CLASS_CODE,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJUSTED_DOC_TRX_ID        ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY1  ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY2  ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY3  ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY4  ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY5  ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_HDR_TRX_USER_KEY6  ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJUSTED_DOC_LINE_ID       ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY1  ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY2  ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY3  ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY4  ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY5  ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJ_DOC_LIN_TRX_USER_KEY6  ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJUSTED_DOC_NUMBER        ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJUSTED_DOC_DATE          ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_TO_APPLICATION_ID  ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_TO_ENTITY_CODE     ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_TO_EVENT_CLASS_CODE,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_TO_TRX_ID          ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY1   ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY2   ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY3   ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY4   ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY5   ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_HDR_TRX_USER_KEY6   ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_TO_TRX_LINE_ID     ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY1   ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY2   ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY3   ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY4   ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY5   ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APP_TO_LIN_TRX_USER_KEY6   ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID_LEVEL2              ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID_LEVEL3              ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID_LEVEL4              ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID_LEVEL5              ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID_LEVEL6              ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_TRX_USER_KEY1 ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_TRX_USER_KEY2 ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_TRX_USER_KEY3 ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_TRX_USER_KEY4 ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_TRX_USER_KEY5 ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HDR_TRX_USER_KEY6 ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_TRX_USER_KEY1,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_TRX_USER_KEY2,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_TRX_USER_KEY3,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_TRX_USER_KEY4,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_TRX_USER_KEY5,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_TRX_USER_KEY6,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_NUMBER,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_DESCRIPTION,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_NUMBER            ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_DESCRIPTION       ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_DESCRIPTION        ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_WAYBILL_NUMBER         ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_COMMUNICATED_DATE      ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_GL_DATE           ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BATCH_SOURCE_ID            ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BATCH_SOURCE_NAME          ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DOC_SEQ_ID                 ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DOC_SEQ_NAME               ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DOC_SEQ_VALUE              ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_DUE_DATE               ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_TYPE_DESCRIPTION       ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.MERCHANT_PARTY_NAME        ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.MERCHANT_PARTY_DOCUMENT_NUMBER,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.MERCHANT_PARTY_REFERENCE   ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.MERCHANT_PARTY_TAXPAYER_ID ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.MERCHANT_PARTY_TAX_REG_NUMBER,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PAYING_PARTY_ID            ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OWN_HQ_PARTY_ID            ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRADING_HQ_PARTY_ID        ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POI_PARTY_ID               ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POD_PARTY_ID               ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TITLE_TRANSFER_PARTY_ID    ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PAYING_PARTY_SITE_ID       ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OWN_HQ_PARTY_SITE_ID       ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRADING_HQ_PARTY_SITE_ID   ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POI_PARTY_SITE_ID          ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POD_PARTY_SITE_ID          ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TITLE_TRANSFER_PARTY_SITE_ID,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PAYING_LOCATION_ID         ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OWN_HQ_LOCATION_ID         ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRADING_HQ_LOCATION_ID     ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POC_LOCATION_ID            ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POI_LOCATION_ID            ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POD_LOCATION_ID            ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TITLE_TRANSFER_LOCATION_ID ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ASSESSABLE_VALUE           ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ASSET_FLAG                 ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ASSET_NUMBER               ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ASSET_ACCUM_DEPRECIATION   ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ASSET_TYPE                 ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ASSET_COST                 ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.NUMERIC1                   ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.NUMERIC2                   ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.NUMERIC3                   ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.NUMERIC4                   ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.NUMERIC5                   ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.NUMERIC6                   ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.NUMERIC7                   ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.NUMERIC8                   ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.NUMERIC9                   ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.NUMERIC10                   ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CHAR1                      ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CHAR2                      ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CHAR3                      ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CHAR4                      ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CHAR5                      ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CHAR6                      ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CHAR7                      ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CHAR8                      ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CHAR9                      ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CHAR10                      ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DATE1                      ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DATE2                      ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DATE3                      ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DATE4                     ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DATE5                      ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DATE6                      ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DATE7                      ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DATE8                      ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DATE9                      ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DATE10                      ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.FIRST_PTY_ORG_ID           ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_EVENT_CLASS_CODE       ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_EVENT_TYPE_CODE        ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DOC_EVENT_STATUS               ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RDNG_SHIP_TO_PTY_TX_PROF_ID    ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RDNG_SHIP_FROM_PTY_TX_PROF_ID  ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RDNG_BILL_TO_PTY_TX_PROF_ID    ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RDNG_BILL_FROM_PTY_TX_PROF_ID  ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RDNG_SHIP_TO_PTY_TX_P_ST_ID    ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RDNG_SHIP_FROM_PTY_TX_P_ST_ID  ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RDNG_BILL_TO_PTY_TX_P_ST_ID    ,
--  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RDNG_BILL_FROM_PTY_TX_P_ST_ID  ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_TO_PARTY_TAX_PROF_ID      ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_FROM_PARTY_TAX_PROF_ID    ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POA_PARTY_TAX_PROF_ID          ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POO_PARTY_TAX_PROF_ID          ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PAYING_PARTY_TAX_PROF_ID       ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OWN_HQ_PARTY_TAX_PROF_ID       ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRADING_HQ_PARTY_TAX_PROF_ID   ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POI_PARTY_TAX_PROF_ID          ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POD_PARTY_TAX_PROF_ID          ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_TO_PARTY_TAX_PROF_ID      ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_FROM_PARTY_TAX_PROF_ID    ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TITLE_TRANS_PARTY_TAX_PROF_ID  ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_TO_SITE_TAX_PROF_ID       ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_FROM_SITE_TAX_PROF_ID     ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POA_SITE_TAX_PROF_ID           ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POO_SITE_TAX_PROF_ID           ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PAYING_SITE_TAX_PROF_ID        ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OWN_HQ_SITE_TAX_PROF_ID        ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRADING_HQ_SITE_TAX_PROF_ID    ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POI_SITE_TAX_PROF_ID           ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POD_SITE_TAX_PROF_ID           ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_TO_SITE_TAX_PROF_ID       ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_FROM_SITE_TAX_PROF_ID     ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TITLE_TRANS_SITE_TAX_PROF_ID   ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.MERCHANT_PARTY_TAX_PROF_ID     ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HQ_ESTB_PARTY_TAX_PROF_ID      ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DOCUMENT_SUB_TYPE              ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SUPPLIER_TAX_INVOICE_NUMBER    ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SUPPLIER_TAX_INVOICE_DATE      ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SUPPLIER_EXCHANGE_RATE         ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_INVOICE_DATE               ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_INVOICE_NUMBER             ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_AMT_INCLUDES_TAX_FLAG     ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.QUOTE_FLAG                     ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULT_TAXATION_COUNTRY       ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HISTORICAL_FLAG                ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INTERNAL_ORG_LOCATION_ID       ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CTRL_HDR_TX_APPL_FLAG          ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CTRL_TOTAL_HDR_TX_AMT          ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CTRL_TOTAL_LINE_TX_AMT         ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INPUT_TAX_CLASSIFICATION_CODE   ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OUTPUT_TAX_CLASSIFICATION_CODE  ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PORT_OF_ENTRY_CODE              ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_REPORTING_FLAG              ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_THIRD_PTY_ACCT_SITE_ID     ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_THIRD_PTY_ACCT_SITE_ID     ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_TO_CUST_ACCT_SITE_USE_ID   ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_TO_CUST_ACCT_SITE_USE_ID   ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PROVNL_TAX_DETERMINATION_DATE   ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_THIRD_PTY_ACCT_ID          ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_THIRD_PTY_ACCT_ID          ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SOURCE_APPLICATION_ID           ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SOURCE_ENTITY_CODE              ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SOURCE_EVENT_CLASS_CODE         ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SOURCE_TRX_ID                   ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SOURCE_LINE_ID                  ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SOURCE_TRX_LEVEL_TYPE           ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_TO_TRX_NUMBER        ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.START_EXPENSE_DATE              ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_BATCH_ID                    ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.REF_DOC_TRX_LEVEL_TYPE          ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_FROM_TRX_LEVEL_TYPE     ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_TO_TRX_LEVEL_TYPE       ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJUSTED_DOC_TRX_LEVEL_TYPE     ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE1           ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE2           ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE3           ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE4           ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE5           ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE6           ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE7           ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE8           ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE9           ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE10           ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLICATION_DOC_STATUS          ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SOURCE_TAX_LINE_ID              ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EXEMPTION_CONTROL_FLAG          ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EXEMPT_REASON_CODE              ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INTERFACE_ENTITY_CODE           ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INTERFACE_LINE_ID               ,
  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HISTORICAL_TAX_CODE_ID    ,
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.USER_UPD_DET_FACTORS_FLAG -- Bug 4703541
        LIMIT C_LINES_PER_COMMIT;

  FOR i in 1..nvl(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INTERNAL_ORGANIZATION_ID.last,0)

  LOOP

            l_cur_trx_id             := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID(i);
            l_cur_application_id     := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLICATION_ID(i);
            l_cur_entity_code        := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ENTITY_CODE(i);
            l_cur_event_class_code   := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EVENT_CLASS_CODE(i);

            -- If current document Information is different from previous document information
            -- then store it in the event class rec.
            IF ( i = 1 ) OR  NOT ( l_prev_trx_id = l_cur_trx_id AND l_prev_application_id = l_cur_application_id AND
                     l_prev_entity_code = l_cur_entity_code AND l_prev_event_class_code = l_cur_event_class_code ) THEN

              l_prev_trx_id             := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID(i);
              l_prev_application_id     := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLICATION_ID(i);
              l_prev_entity_code        := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ENTITY_CODE(i);
              l_prev_event_class_code   := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EVENT_CLASS_CODE(i);

    l_event_class_rec.INTERNAL_ORGANIZATION_ID     :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INTERNAL_ORGANIZATION_ID(i) ;
    l_event_class_rec.LEGAL_ENTITY_ID              :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LEGAL_ENTITY_ID(i) ;
    l_event_class_rec.LEDGER_ID                    :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LEDGER_ID(i) ;
    l_event_class_rec.APPLICATION_ID               :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLICATION_ID(i) ;
    l_event_class_rec.ENTITY_CODE                  :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ENTITY_CODE(i) ;
    l_event_class_rec.EVENT_CLASS_CODE             :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EVENT_CLASS_CODE(i) ;
    l_event_class_rec.EVENT_TYPE_CODE              :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EVENT_TYPE_CODE(i) ;
    l_event_class_rec.CTRL_TOTAL_HDR_TX_AMT        :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CTRL_TOTAL_HDR_TX_AMT(i) ;
    l_event_class_rec.TRX_ID                       :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID(i) ;
    l_event_class_rec.TRX_DATE                     :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_DATE(i) ;
    l_event_class_rec.REL_DOC_DATE                 :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RELATED_DOC_DATE(i) ;
    l_event_class_rec.TRX_CURRENCY_CODE            :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_CURRENCY_CODE(i) ;
    l_event_class_rec.CURRENCY_CONVERSION_TYPE     :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_TYPE(i) ;
    l_event_class_rec.CURRENCY_CONVERSION_RATE     :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_RATE(i) ;
    l_event_class_rec.CURRENCY_CONVERSION_DATE     :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_DATE(i) ;
    l_event_class_rec.ROUNDING_SHIP_TO_PARTY_ID    :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_SHIP_TO_PARTY_ID(i) ;
    l_event_class_rec.ROUNDING_SHIP_FROM_PARTY_ID  :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_SHIP_FROM_PARTY_ID(i) ;
    l_event_class_rec.ROUNDING_BILL_TO_PARTY_ID    :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_BILL_TO_PARTY_ID(i) ;
    l_event_class_rec.ROUNDING_BILL_FROM_PARTY_ID  :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_BILL_FROM_PARTY_ID(i) ;
    l_event_class_rec.RNDG_SHIP_TO_PARTY_SITE_ID   :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_SHIP_TO_PARTY_SITE_ID(i) ;
    l_event_class_rec.RNDG_SHIP_FROM_PARTY_SITE_ID :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_SHIP_FROM_PARTY_SITE_ID(i) ;
    l_event_class_rec.RNDG_BILL_TO_PARTY_SITE_ID   :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_BILL_TO_PARTY_SITE_ID(i) ;
    l_event_class_rec.RNDG_BILL_FROM_PARTY_SITE_ID :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_BILL_FROM_PARTY_SITE_ID(i) ;


          IF ( G_LEVEL_EVENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_EVENT,
                        'ZX.PLSQL.ZX_VALIDATE_API_PKG.def_additional_tax_attribs',
                  'Validating Transaction: '||
                  to_char(l_event_class_rec.trx_id)||
                  ' of Application: '||
                  to_char(l_event_class_rec.application_id) ||
                  ' and Event Class: '||
                  l_event_class_rec.event_class_code
                  );
          END IF;
          -- Bug # 5094766. This procedure validates the parameter and populate the tax event class info.
          ZX_VALID_INIT_PARAMS_PKG.get_default_tax_det_attrs(
                                    p_event_class_rec => l_event_class_rec,
                        x_return_status   => l_return_status
                   );

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure,
       'ZX.PLSQL.ZX_VALIDATE_API_PKG.def_additional_tax_attribs',
       'x_return_status = ' || x_return_status);
         FND_LOG.STRING(g_level_procedure,
       'ZX.PLSQL.ZX_VALIDATE_API_PKG.def_additional_tax_attribs',
       'l_error_buffer  = ' || l_error_buffer);
         FND_LOG.STRING(g_level_procedure,
       'ZX.PLSQL.ZX_VALIDATE_API_PKG.def_additional_tax_attribs.END',
       'ZX_VALIDATE_API_PKG: def_additional_tax_attribs(-)');
       END IF;

       RETURN;

     END IF;
         END IF;


          IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
       'ZX.PLSQL.ZX_VALIDATE_API_PKG.def_additional_tax_attribs',
       'Before Calling ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS for record '||to_char(i));
    END IF;

     ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS
     (
       i,
       l_event_class_rec,
       NULL, --p_taxation_country
       NULL, --p_document_sub_type
       x_return_status
     );

    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
       'ZX.PLSQL.ZX_VALIDATE_API_PKG.def_additional_tax_attribs',
       'Before Calling ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_REPORTING_ATTRIBS for record '||to_char(i));
    END IF;

     ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_REPORTING_ATTRIBS
     (
       i,
       NULL, --p_tax_invoice_number
       NULL, --p_tax_invoice_date
       x_return_status
     );

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure,
       'ZX.PLSQL.ZX_VALIDATE_API_PKG.def_additional_tax_attribs',
       'x_return_status = ' || x_return_status);
         FND_LOG.STRING(g_level_procedure,
       'ZX.PLSQL.ZX_VALIDATE_API_PKG.def_additional_tax_attribs',
       'l_error_buffer  = ' || l_error_buffer);
         FND_LOG.STRING(g_level_procedure,
       'ZX.PLSQL.ZX_VALIDATE_API_PKG.def_additional_tax_attribs.END',
       'ZX_VALIDATE_API_PKG: def_additional_tax_attribs(-)');
       END IF;

       RETURN;

     END IF;

        END LOOP;
        -- update zx_transaction_lines_gt with the default
        -- tax attributes found

    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
       'ZX.PLSQL.ZX_VALIDATE_API_PKG.def_additional_tax_attribs',
       'updating zx_transaction_lines_gt with tax attributes found');
    END IF;

        FORALL i IN 1..nvl(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INTERNAL_ORGANIZATION_ID.last,0)

          UPDATE /*+ INDEX (z,ZX_TRANSACTION_LINES_GT_U1) */ ZX_TRANSACTION_LINES_GT z
          SET trx_business_category =
                    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_business_category(i),
              product_category =
                    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_category(i),
              product_fisc_classification =
                    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_fisc_classification(i),
              assessable_value =
                    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.assessable_value(i),
              product_type =
                    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_TYPE(i),
              user_defined_fisc_class =
                    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.USER_DEFINED_FISC_CLASS(i),
              line_intended_use =
                    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_intended_use(i),
              product_id =
                    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_id(i),
              product_org_id =
                    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_org_id(i),
              input_tax_classification_code =
                    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.input_tax_classification_code(i),
              output_tax_classification_code =
                    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.output_tax_classification_code(i)

           WHERE z.application_id    = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLICATION_ID(i)
            AND z.entity_code       = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ENTITY_CODE(i)
            AND z.event_class_code  = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EVENT_CLASS_CODE(i)
            AND z.trx_id            = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID(i)
            AND z.trx_line_id       = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_ID(i);

        FORALL i IN 1..nvl(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INTERNAL_ORGANIZATION_ID.last,0)
          UPDATE ZX_TRX_HEADERS_GT
          SET TAX_INVOICE_NUMBER =
                    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_INVOICE_NUMBER(i),
              TAX_INVOICE_DATE =
                    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_INVOICE_DATE(i),
              DEFAULT_TAXATION_COUNTRY =
                    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULT_TAXATION_COUNTRY(i),
              DOCUMENT_SUB_TYPE =
                    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DOCUMENT_SUB_TYPE(i)

           WHERE application_id   = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLICATION_ID(i)
            AND entity_code       = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ENTITY_CODE(i)
            AND event_class_code  = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EVENT_CLASS_CODE(i)
            AND trx_id            = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID(i);

            EXIT WHEN gtt_to_glb_strctr_csr%NOTFOUND;

      END LOOP;
      CLOSE gtt_to_glb_strctr_csr;

      IF (g_level_event >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_event,
       'ZX.PLSQL.ZX_VALIDATE_API_PKG.def_additional_tax_attribs.END',
       'ZX_VALIDATE_API_PKG: def_additional_tax_attribs(-)');
      END IF;

EXCEPTION

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF gtt_to_glb_strctr_csr%ISOPEN THEN
      CLOSE gtt_to_glb_strctr_csr;
    END IF;
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','def_additional_tax_attribs- '|| l_error_buffer);
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_VALIDATE_API_PKG.def_additional_tax_attribs',
                      l_error_buffer);
    END IF;

END def_additional_tax_attribs;



--Constructor
BEGIN

  l_regime_not_exists           :=fnd_message.get_string('ZX','ZX_REGIME_NOT_EXIST' );
  l_regime_not_effective        :=fnd_message.get_string('ZX','ZX_REGIME_NOT_EFFECTIVE' );
  l_tax_not_exists              :=fnd_message.get_string('ZX','ZX_TAX_NOT_EXIST' );
  l_tax_not_live                :=fnd_message.get_string('ZX','ZX_TAX_NOT_LIVE' );
  l_tax_not_effective           :=fnd_message.get_string('ZX','ZX_TAX_NOT_EFFECTIVE' );
  l_tax_recov_or_offset         :=fnd_message.get_string('ZX','ZX_TAX_RECOV_OR_OFFSET' );
  l_tax_status_not_exists       :=fnd_message.get_string('ZX','ZX_TAX_STATUS_NOT_EXIST' );
  l_tax_status_not_effective    :=fnd_message.get_string('ZX','ZX_TAX_STATUS_NOT_EFFECTIVE' );
  l_tax_rate_not_exists         :=fnd_message.get_string('ZX','ZX_TAX_RATE_NOT_EXIST' );
  l_tax_rate_not_effective      :=fnd_message.get_string('ZX','ZX_TAX_RATE_NOT_EFFECTIVE' );
  l_tax_rate_not_active         :=fnd_message.get_string('ZX','ZX_TAX_RATE_NOT_ACTIVE' );
--l_tax_rate_code_not_effective :=fnd_message.get_string('ZX','ZX_TAX_RATE_NOT_EFFECTIVE' );
--l_tax_rate_code_not_active    :=fnd_message.get_string('ZX','ZX_TAX_RATE_NOT_ACTIVE' );
  l_tax_rate_percentage_invalid :=fnd_message.get_string('ZX','ZX_TAX_RATE_PERCENTAGE_INVALID' );
  l_jur_code_not_exists         :=fnd_message.get_string('ZX','ZX_JUR_CODE_NOT_EXIST' );
  l_jur_code_not_effective      :=fnd_message.get_string('ZX','ZX_JUR_CODE_NOT_EFFECTIVE' );
  l_ref_doc_missing             :=fnd_message.get_string('ZX','ZX_REF_DOC_MISSING' );
  l_rel_doc_missing             :=fnd_message.get_string('ZX','ZX_REL_DOC_MISSING' );
  l_app_from_doc_missing        :=fnd_message.get_string('ZX','ZX_APP_FROM_DOC_MISSING' );
--l_app_to_doc_missing          :=fnd_message.get_string('ZX','ZX_APP_TO_DOC_MISSING' );
  l_adj_doc_missing             :=fnd_message.get_string('ZX','ZX_ADJ_DOC_MISSING' );
  l_source_doc_missing          :=fnd_message.get_string('ZX','ZX_SOURCE_DOC_MISSING' );
  l_round_party_missing         :=fnd_message.get_string('ZX','ZX_ROUND_PARTY_MISSING' );
  l_location_missing            :=fnd_message.get_string('ZX','ZX_LOCATION_MISSING' );
  l_ctrl_flag_missing           :=fnd_message.get_string('ZX','ZX_CTRFLAG_MISSING' );
  l_line_class_invalid          :=fnd_message.get_string('ZX','ZX_LINE_CLASS_INVALID' );
  l_trx_line_type_invalid       :=fnd_message.get_string('ZX','ZX_TRX_LINE_TYPE_INVALID' );
  l_line_amt_incl_tax_invalid   :=fnd_message.get_string('ZX','ZX_LINE_AMT_INCTAX_INVALID' );
  l_default_status_not_exists   :=fnd_message.get_string('ZX','ZX_DEFAULT_STATUS_NOT_EXIST' );
  l_default_rate_code_not_exists:=fnd_message.get_string('ZX','ZX_DEFAULT_RATE_CODE_NOT_EXIST' );
  l_taxation_country_not_exists :=fnd_message.get_string('ZX','ZX_TAXATION_COUNTRY_NOT_EXIST' );
  l_prd_categ_not_exists        :=fnd_message.get_string('ZX','ZX_PRODUCT_CATEG_NOT_EXIST' );
  l_prd_categ_not_effective     :=fnd_message.get_string('ZX','ZX_PRODUCT_CATEG_NOT_EFFECTIVE' );
  l_prd_categ_country_inconsis  :=fnd_message.get_string('ZX','ZX_PRODUCT_CATEG_COUNTRY_INCON' );
  l_usr_df_fc_code_not_exists   :=fnd_message.get_string('ZX','ZX_USER_DEF_FC_CODE_NOT_EXIST' );
  l_usr_df_fc_code_not_effective:=fnd_message.get_string('ZX','ZX_USER_DEF_FC_CODE_NOT_EFFECT' );
  l_usr_df_country_inconsis     :=fnd_message.get_string('ZX','ZX_USER_DEF_COUNTRY_INCONSIS' );
  l_doc_fc_code_not_exists      :=fnd_message.get_string('ZX','ZX_DOC_FC_CODE_NOT_EXIST' );
  l_doc_fc_code_not_effective   :=fnd_message.get_string('ZX','ZX_DOC_FC_CODE_NOT_EFFECTIVE' );
  l_doc_fc_country_inconsis     :=fnd_message.get_string('ZX','ZX_DOC_FC_COUNTRY_INCONSIS' );
  l_trx_biz_fc_code_not_exists  :=fnd_message.get_string('ZX','ZX_TRX_BIZ_FC_CODE_NOT_EXIST' );
  l_trx_biz_fc_code_not_effect  :=fnd_message.get_string('ZX','ZX_TRX_BIZ_FC_CODE_NOT_EFFECT' );
  l_trx_biz_fc_country_inconsis :=fnd_message.get_string('ZX','ZX_TRX_BIZ_FC_COUNTRY_INCONSIS' );
  l_intended_use_code_not_exists:=fnd_message.get_string('ZX','ZX_INTENDED_USE_CODE_NOT_EXIST' );
  l_intended_use_not_effective  :=fnd_message.get_string('ZX','ZX_INTENDED_USE_NOT_EFFECTIVE' );
  l_intended_use_contry_inconsis:=fnd_message.get_string('ZX','ZX_INTENDED_USE_COUNTRY_INCON' );
  l_prd_type_code_not_exists    :=fnd_message.get_string('ZX','ZX_PRODUCT_TYPE_CODE_NOT_EXIST' );
  l_prd_type_not_effective      :=fnd_message.get_string('ZX','ZX_PRODUCT_TYPE_NOT_EFFECTIVE' );
  l_prd_fc_code_not_exists      :=fnd_message.get_string('ZX','ZX_PRODUCT_FC_CODE_NOT_EXIST' );
  l_party_not_exists            :=fnd_message.get_string('ZX','ZX_PARTY_NOT_EXISTS' );
  l_ship_to_party_not_exists    :=fnd_message.get_string('ZX','ZX_SHIP_TO_PARTY_NOT_EXIST' );
  l_ship_frm_party_not_exits    :=fnd_message.get_string('ZX','ZX_SHIP_FROM_PARTY_NOT_EXIST' );
  l_bill_to_party_not_exists    :=fnd_message.get_string('ZX','ZX_BILTO_PARTY_NOT_EXIST' );
  l_bill_frm_party_not_exists   :=fnd_message.get_string('ZX','ZX_BILFROM_PARTY_NOT_EXIST' );
  l_shipto_party_site_not_exists:=fnd_message.get_string('ZX','ZX_SHIPTO_PARTY_SITE_NOT_EXIST' );
  l_shipfrm_party_site_not_exits:=fnd_message.get_string('ZX','ZX_SHIPFROM_PARTYSITE_NOTEXIST' );
  l_billto_party_site_not_exists:=fnd_message.get_string('ZX','ZX_BILLTO_PARTY_SITE_NOT_EXIST' );
  l_billfrm_party_site_not_exist:=fnd_message.get_string('ZX','ZX_BILLFROM_PARTYSITE_NOTEXIST' );
  l_tax_multialloc_to_sameln    :=fnd_message.get_string('ZX','ZX_TAX_MULTIALLOC_TO_SAMELN' );
  l_imptax_multialloc_to_sameln :=fnd_message.get_string('ZX','ZX_IMPTAX_MULTIALLOC_TO_SAMELN' );
  l_tax_only_line_multi_allocate:=fnd_message.get_string('ZX','ZX_TAX_ONLY_LINE_MULTI_ALLOCAT' );
  l_pseudo_line_has_multi_taxall:=fnd_message.get_string('ZX','ZX_PSEUDO_LINE_HAS_MULTI_TAX' );
  l_tax_amt_missing             :=fnd_message.get_string('ZX','ZX_TAX_AMT_MISSING' );
  l_tax_ln_typ_loc_not_allw_f_ar:=fnd_message.get_string('ZX','ZX_TAX_LN_TYP_LOC_N_ALLW_F_AR' );
  l_tax_incl_flag_mismatch      :=fnd_message.get_string('ZX','ZX_TAX_INCL_FLAG_MISMATCH' );
  l_imp_tax_missing_in_appld_frm:=fnd_message.get_string('ZX','ZX_TAX_MISSING_IN_APPLIED_FRM');
  l_imp_tax_missing_in_adjust_to:=fnd_message.get_string('ZX','ZX_TAX_MISSING_IN_ADJUSTED_TO');
  l_currency_info_reqd          :=fnd_message.get_string('ZX','ZX_CURRENCY_INFO_REQD' );
  l_line_ctrl_amt_invalid       :=fnd_message.get_string('ZX','ZX_LINE_CTRL_AMT_INVALID' );
  l_line_ctrl_amt_not_null      :=fnd_message.get_string('ZX','ZX_LINE_CTRL_AMT_NOT_NULL' );
  l_unit_price_missing          :=fnd_message.get_string('ZX','ZX_UNIT_PRICE_REQD' );
  l_line_quantity_missing       :=fnd_message.get_string('ZX','ZX_TRX_LINE_QUANTITY_REQD' );
  l_exemption_ctrl_flag_invalid :=fnd_message.get_string('ZX','ZX_EXEMPTION_CTRL_FLAG_INVALID' );
  l_product_type_invalid        :=fnd_message.get_string('ZX','ZX_PRODUCT_TYPE_INVALID' );
  l_quote_flag_invalid          :=fnd_message.get_string('ZX','ZX_QUOTE_FLAG_INVALID' );
  l_doc_lvl_recalc_flag_invalid :=fnd_message.get_string('ZX','ZX_DOC_LVL_RECALC_FLAG_INVALID' );
  l_tax_line_alloc_flag_invalid :=fnd_message.get_string('ZX','ZX_TAX_LINE_ALLOC_FLAG_INVALID' );
  l_inval_tax_lines_for_ctrl_flg:=fnd_message.get_string('ZX','ZX_INVALID_TAX_LINES' );
  l_invald_line_for_ctrl_tot_amt:=fnd_message.get_string('ZX','ZX_INVALID_LINE_TAX_AMT' );
  l_inval_tax_line_for_alloc_flg:=fnd_message.get_string('ZX','ZX_INVALID_TAX_FOR_ALLOC_FLG' );
  l_invalid_tax_only_tax_lines  :=fnd_message.get_string('ZX','ZX_INVALID_TAX_ONLY_TAX_LINES' );
  l_invalid_tax_line_alloc_flag :=fnd_message.get_string('ZX','ZX_INVALID_TAX_ALLOC_FLAG' );
  l_invd_trx_line_id_in_link_gt :=fnd_message.get_string('ZX','ZX_INVALID_TRX_LINE_ID' );
  l_invalid_summary_tax_line_id :=fnd_message.get_string('ZX','ZX_INVALID_SUMMARY_TAX_LINE_ID' );
  l_regime_not_eff_in_subscrptn :=fnd_message.get_string('ZX','ZX_REGIME_NOT_EFF_IN_SUBSCR' );
  l_tax_rate_code_not_exists    :=fnd_message.get_string('ZX','ZX_TAX_RATE_CODE_NOT_EXIST' ); -- 4703541
  l_tax_rate_id_code_missing    :=fnd_message.get_string('ZX','ZX_TAX_RATE_ID_CODE_MISSING' ); -- 4917256
  l_imp_tax_rate_amt_mismatch   :=fnd_message.get_string('ZX','ZX_IMP_TAX_RATE_AMT_MISMATCH');


END Zx_Validate_Api_Pkg;

/
