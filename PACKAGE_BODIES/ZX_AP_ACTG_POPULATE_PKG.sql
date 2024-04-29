--------------------------------------------------------
--  DDL for Package Body ZX_AP_ACTG_POPULATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_AP_ACTG_POPULATE_PKG" AS
/* $Header: zxripactgpoppvtb.pls 120.6 2006/01/20 18:50:43 apai ship $ */
--Populate variables
GT_TRX_CLASS_MNG                  ZX_EXTRACT_PKG.TRX_CLASS_MNG_TBL;
GT_TAX_RATE_CODE_REG_TYPE_MNG     ZX_EXTRACT_PKG.TAX_RATE_CODE_REG_TYPE_MNG_TBL;
GT_TRX_QUANTITY_UOM_MNG           ZX_EXTRACT_PKG.TRX_QUANTITY_UOM_MNG_TBL;
GT_TAXABLE_DISC_AMT               ZX_EXTRACT_PKG.TAXABLE_DISC_AMT_TBL;
GT_TAXABLE_DISC_AMT_FUNCL_CURR    ZX_EXTRACT_PKG.TAXABLE_DISC_AMT_FUN_CURR_TBL;
GT_TAX_DISC_AMT               ZX_EXTRACT_PKG.TAX_DISC_AMT_TBL;
GT_TAX_DISC_AMT_FUNCL_CURR    ZX_EXTRACT_PKG.TAX_DISC_AMT_FUN_CURR_TBL;
GT_TAX_RATE_VAT_TRX_TYPE_DESC     ZX_EXTRACT_PKG.TAX_RATE_VAT_TRX_TYPE_DESC_TBL;
GT_BILLING_TP_NAME_ALT            ZX_EXTRACT_PKG.BILLING_TP_NAME_ALT_TBL;
GT_BILLING_TP_SIC_CODE            ZX_EXTRACT_PKG.BILLING_TP_SIC_CODE_TBL;
GT_BILLING_TP_CITY                ZX_EXTRACT_PKG.BILLING_TP_CITY_TBL;
GT_BILLING_TP_COUNTY              ZX_EXTRACT_PKG.BILLING_TP_COUNTY_TBL;
GT_BILLING_TP_STATE               ZX_EXTRACT_PKG.BILLING_TP_STATE_TBL;
GT_BILLING_TP_PROVINCE            ZX_EXTRACT_PKG.BILLING_TP_PROVINCE_TBL;
GT_BILLING_TP_ADDRESS1            ZX_EXTRACT_PKG.BILLING_TP_ADDRESS1_TBL;
GT_BILLING_TP_ADDRESS2            ZX_EXTRACT_PKG.BILLING_TP_ADDRESS2_TBL;
GT_BILLING_TP_ADDRESS3            ZX_EXTRACT_PKG.BILLING_TP_ADDRESS3_TBL;
GT_BILLING_TP_ADDR_LINES_ALT   ZX_EXTRACT_PKG.BILLING_TP_ADDR_LINES_ALT_TBL;
GT_BILLING_TP_COUNTRY             ZX_EXTRACT_PKG.BILLING_TP_COUNTRY_TBL;
GT_BILLING_TP_POSTAL_CODE         ZX_EXTRACT_PKG.BILLING_TP_POSTAL_CODE_TBL;
GT_SHIPPING_TP_CITY               ZX_EXTRACT_PKG.SHIPPING_TP_CITY_TBL;
GT_SHIPPING_TP_COUNTY             ZX_EXTRACT_PKG.SHIPPING_TP_COUNTY_TBL;
GT_SHIPPING_TP_STATE              ZX_EXTRACT_PKG.SHIPPING_TP_STATE_TBL;
GT_SHIPPING_TP_ADDRESS1           ZX_EXTRACT_PKG.SHIPPING_TP_ADDRESS1_TBL;
GT_SHIPPING_TP_ADDRESS2           ZX_EXTRACT_PKG.SHIPPING_TP_ADDRESS2_TBL;
GT_SHIPPING_TP_ADDRESS3           ZX_EXTRACT_PKG.SHIPPING_TP_ADDRESS3_TBL;
GT_SHIPPING_TP_COUNTRY            ZX_EXTRACT_PKG.SHIPPING_TP_COUNTRY_TBL;
GT_SHIPPING_TP_POSTAL_CODE        ZX_EXTRACT_PKG.SHIPPING_TP_POSTAL_CODE_TBL;
GT_BILLING_TRADING_PARTNER_ID     ZX_EXTRACT_PKG.BILLING_TRADING_PARTNER_ID_TBL;
GT_BILLING_TP_SITE_ID             ZX_EXTRACT_PKG.BILLING_TP_SITE_ID_TBL;
GT_BILLING_TP_TAX_REP_FLAG  ZX_EXTRACT_PKG.BILLING_TP_TAX_REP_FLAG_TBL;
GT_OFFICE_SITE_FLAG               ZX_EXTRACT_PKG.OFFICE_SITE_FLAG_TBL;
GT_REGISTRATION_STATUS_CODE       ZX_EXTRACT_PKG.REGISTRATION_STATUS_CODE_TBL;
GT_BILLING_TP_NUMBER              ZX_EXTRACT_PKG.BILLING_TP_NUMBER_TBL;
GT_BILLING_TP_TAX_REG_NUM         ZX_EXTRACT_PKG.BILLING_TP_TAX_REG_NUM_TBL;
GT_BILLING_TP_TAXPAYER_ID         ZX_EXTRACT_PKG.BILLING_TP_TAXPAYER_ID_TBL;
GT_BILLING_TP_SITE_NAME_ALT       ZX_EXTRACT_PKG.BILLING_TP_SITE_NAME_ALT_TBL;
GT_BILLING_TP_NAME                ZX_EXTRACT_PKG.BILLING_TP_NAME_TBL;
GT_SHIPPING_TP_NAME_ALT            ZX_EXTRACT_PKG.BILLING_TP_NAME_ALT_TBL;
GT_SHIPPING_TP_SIC_CODE            ZX_EXTRACT_PKG.BILLING_TP_SIC_CODE_TBL;
GT_GDF_PO_VENDOR_SITE_ATT17          ZX_EXTRACT_PKG.GDF_PO_VENDOR_SITE_ATT17_TBL;

--Gloabl variables to fetch detail cursor
GT_DETAIL_TAX_LINE_ID              ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL;
GT_APPLICATION_ID                  ZX_EXTRACT_PKG.APPLICATION_ID_TBL;
GT_INTERNAL_ORGANIZATION_ID        ZX_EXTRACT_PKG.INTERNAL_ORGANIZATION_ID_TBL;
GT_TRX_ID                          ZX_EXTRACT_PKG.TRX_ID_TBL;
GT_TRX_LINE_ID                ZX_EXTRACT_PKG.TRX_LINE_ID_TBL;
GT_TAX_LINE_ID                ZX_EXTRACT_PKG.TAX_LINE_ID_TBL;
GT_TRX_LINE_TYPE                     ZX_EXTRACT_PKG.TRX_LINE_TYPE_TBL;
GT_TRX_LINE_CLASS                  ZX_EXTRACT_PKG.TRX_LINE_CLASS_TBL;
GT_SHIP_TO_PARTY_TAX_PROF_ID       ZX_EXTRACT_PKG.SHIP_TO_PARTY_TAX_PROF_ID_TBL;
GT_SHIP_FROM_PTY_TAX_PROF_ID     ZX_EXTRACT_PKG.SHIP_FROM_PTY_TAX_PROF_ID_TBL;
GT_BILL_TO_PARTY_TAX_PROF_ID       ZX_EXTRACT_PKG.BILL_TO_PARTY_TAX_PROF_ID_TBL;
GT_BILL_FROM_PTY_TAX_PROF_ID     ZX_EXTRACT_PKG.BILL_FROM_PTY_TAX_PROF_ID_TBL;
GT_SHIP_TO_SITE_TAX_PROF_ID        ZX_EXTRACT_PKG.SHIP_TO_SITE_TAX_PROF_ID_TBL;
GT_BILL_TO_SITE_TAX_PROF_ID       ZX_EXTRACT_PKG.BILL_TO_SITE_TAX_PROF_ID_TBL;
GT_SHIP_FROM_SITE_TAX_PROF_ID      ZX_EXTRACT_PKG.SHIP_FROM_SITE_TAX_PROF_ID_TBL;
GT_BILL_FROM_SITE_TAX_PROF_ID      ZX_EXTRACT_PKG.BILL_FROM_SITE_TAX_PROF_ID_TBL;
GT_BILL_FROM_PARTY_ID              ZX_EXTRACT_PKG.BILL_FROM_PARTY_ID_TBL;
GT_BILL_FROM_PARTY_SITE_ID         ZX_EXTRACT_PKG.BILL_FROM_PARTY_SITE_ID_TBL;
GT_HISTORICAL_FLAG                 ZX_EXTRACT_PKG.HISTORICAL_FLAG_TBL;
      GT_ACTG_SOURCE_ID                ZX_EXTRACT_PKG.ACTG_SOURCE_ID_TBL;
      GT_AE_HEADER_ID                  ZX_EXTRACT_PKG.ACTG_HEADER_ID_TBL;
      GT_EVENT_ID                      ZX_EXTRACT_PKG.ACTG_EVENT_ID_TBL;
--      GT_ENTITY_ID                     ZX_EXTRACT_PKG.ACTG_ENTITY_ID_TBL;
      GT_LINE_CCID                     ZX_EXTRACT_PKG.ACTG_LINE_CCID_TBL;
      GT_TRX_ARAP_BALANCING_SEGMENT    ZX_EXTRACT_PKG.TRX_ARAP_BALANCING_SEG_TBL;
      GT_TRX_ARAP_NATURAL_ACCOUNT      ZX_EXTRACT_PKG.TRX_ARAP_NATURAL_ACCOUNT_TBL;
      GT_TRX_TAXABLE_BAL_SEG           ZX_EXTRACT_PKG.TRX_TAXABLE_BALANCING_SEG_TBL;
      GT_TRX_TAXABLE_NATURAL_ACCOUNT   ZX_EXTRACT_PKG.TRX_TAXABLE_NATURAL_ACCT_TBL;
      GT_TRX_TAX_BALANCING_SEGMENT     ZX_EXTRACT_PKG.TRX_TAX_BALANCING_SEG_TBL;
      GT_TRX_TAX_NATURAL_ACCOUNT       ZX_EXTRACT_PKG.TRX_TAX_NATURAL_ACCOUNT_TBL;
      GT_TAX_AMT                    ZX_EXTRACT_PKG.TAX_AMT_TBL;
      GT_TAX_AMT_FUNCL_CURR         ZX_EXTRACT_PKG.TAX_AMT_FUNCL_CURR_TBL;
      GT_TAXABLE_AMT                ZX_EXTRACT_PKG.TAXABLE_AMT_TBL;
      GT_TAXABLE_AMT_FUNCL_CURR     ZX_EXTRACT_PKG.TAXABLE_AMT_FUNCL_CURR_TBL;
-- apai GT_REP_CONTEXT_ID                  ZX_EXTRACT_PKG.REP_CONTEXT_ID_TBL;
C_LINES_PER_COMMIT      constant  number := 5000;

 G_REP_CONTEXT_ID                  NUMBER;
 g_retcode                        NUMBER := 0;
 g_current_runtime_level           NUMBER;
 g_level_statement       CONSTANT  NUMBER  := FND_LOG.LEVEL_STATEMENT;
 g_level_procedure       CONSTANT  NUMBER  := FND_LOG.LEVEL_PROCEDURE;
 g_level_event           CONSTANT  NUMBER  := FND_LOG.LEVEL_EVENT;
 g_level_unexpected      CONSTANT  NUMBER  := FND_LOG.LEVEL_UNEXPECTED;
 g_error_buffer                  VARCHAR2(100);


PROCEDURE extract_party_info(i IN BINARY_INTEGER);

PROCEDURE get_accounting_info(P_TRX_ID                IN NUMBER,
                              P_TRX_LINE_ID           IN NUMBER,
                              P_TAX_LINE_ID           IN NUMBER,
                              P_EVENT_ID              IN NUMBER,
                              P_AE_HEADER_ID          IN NUMBER,
                              P_TAX_DIST_ID           IN NUMBER,
                              P_BALANCING_SEGMENT     IN VARCHAR2,
                              P_ACCOUNTING_SEGMENT    IN VARCHAR2,
                              P_SUMMARY_LEVEL         IN VARCHAR2,
                              P_INCLUDE_DISCOUNTS     IN VARCHAR2,
                              P_ORG_ID                IN NUMBER,
                              i                       IN binary_integer);

PROCEDURE get_accounting_amounts(P_TRX_ID                IN NUMBER,
                                 P_TRX_LINE_ID           IN NUMBER,
                                 P_TAX_LINE_ID           IN NUMBER,
                           --      P_ENTITY_ID             IN NUMBER,
                                 P_EVENT_ID              IN NUMBER,
                                 P_AE_HEADER_ID          IN NUMBER,
                                 P_TAX_DIST_ID           IN NUMBER,
                                 P_SUMMARY_LEVEL         IN VARCHAR2,
                                 P_LEDGER_ID             IN NUMBER,
                                 i                       IN binary_integer);

PROCEDURE get_discount_info
                ( j                      IN BINARY_INTEGER,
                 P_TRX_ID                       IN    NUMBER,
                 P_TAX_LINE_ID                       IN    NUMBER,
                 P_SUMMARY_LEVEL                IN    VARCHAR2,
                 P_DIST_ID                      IN    NUMBER,
                 P_TRX_LINE_ID                  IN    NUMBER,
                 P_DISC_DISTRIBUTION_METHOD     IN    VARCHAR2,
                 P_LIABILITY_POST_LOOKUP_CODE   IN    VARCHAR2
                 );

PROCEDURE populate_meaning(
            P_TRL_GLOBAL_VARIABLES_REC  IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE,
            i IN BINARY_INTEGER);

PROCEDURE initialize_variables (
          p_count   IN         NUMBER);

PROCEDURE update_zx_rep_detail_t(
           P_COUNT IN BINARY_INTEGER);

PROCEDURE update_rep_actg_t(p_count IN NUMBER);

PROCEDURE update_additional_info(
          P_TRL_GLOBAL_VARIABLES_REC  IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE,
           P_MRC_SOB_TYPE IN VARCHAR2) IS

 l_count number;
 l_reporting_ledger_id   NUMBER(15);
 l_primary_ledger_id     NUMBER(15);


 CURSOR rep_detail_cursor(c_request_id IN number) IS
 SELECT zx_dtl.DETAIL_TAX_LINE_ID,
        zx_dtl.APPLICATION_ID,
        zx_dtl.INTERNAL_ORGANIZATION_ID,
        zx_dtl.TRX_ID,
        zx_dtl.TRX_LINE_ID ,
        zx_dtl.TAX_LINE_ID ,
        zx_dtl.TRX_LINE_TYPE,
        zx_dtl.TRX_LINE_CLASS,
        zx_dtl.BILL_FROM_PARTY_TAX_PROF_ID,
        zx_dtl.BILL_FROM_SITE_TAX_PROF_ID,
        zx_dtl.SHIP_TO_SITE_TAX_PROF_ID,
        zx_dtl.SHIP_FROM_SITE_TAX_PROF_ID,
        zx_dtl.SHIP_TO_PARTY_TAX_PROF_ID,
        zx_dtl.SHIP_FROM_PARTY_TAX_PROF_ID,
        zx_dtl.BILL_FROM_PARTY_ID,
        zx_dtl.BILL_FROM_PARTY_SITE_ID,
        zx_dtl.HISTORICAL_FLAG,
        ZX_ACTG.ACTG_SOURCE_ID,
        ZX_ACTG.ACTG_HEADER_ID,
        ZX_ACTG.ACTG_EVENT_ID,
   --     ZX_ACTG.ACTG_ENTITY_ID,
        ZX_ACTG.ACTG_LINE_CCID
 FROM  zx_rep_trx_detail_t zx_dtl,
       zx_rep_actg_ext_t zx_actg
 WHERE zx_dtl.request_id = c_request_id
   AND zx_dtl.extract_source_ledger = 'AP'
   AND zx_dtl.detail_tax_line_id = zx_actg.detail_tax_line_id;

    l_balancing_segment         VARCHAR2(25);
    l_accounting_segment         VARCHAR2(25);
    l_ledger_id                NUMBER(15);
BEGIN

     g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.update_additional_info.BEGIN',
                                      'update_additional_info(+)');
    END IF;

    l_ledger_id  := NVL(P_TRL_GLOBAL_VARIABLES_REC.REPORTING_LEDGER_ID, P_TRL_GLOBAL_VARIABLES_REC.LEDGER_ID);

  OPEN rep_detail_cursor(P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID);
  LOOP
    FETCH rep_detail_cursor BULK COLLECT INTO
        GT_DETAIL_TAX_LINE_ID,
        GT_APPLICATION_ID,
        GT_INTERNAL_ORGANIZATION_ID,
        GT_TRX_ID,
        GT_TRX_LINE_ID,
        GT_TAX_LINE_ID,
        GT_TRX_LINE_TYPE,
        GT_TRX_LINE_CLASS,
        GT_BILL_FROM_PTY_TAX_PROF_ID,
        GT_BILL_FROM_SITE_TAX_PROF_ID,
        GT_SHIP_TO_SITE_TAX_PROF_ID,
        GT_SHIP_FROM_SITE_TAX_PROF_ID,
        GT_SHIP_TO_PARTY_TAX_PROF_ID,
        GT_SHIP_FROM_PTY_TAX_PROF_ID,
        GT_BILL_FROM_PARTY_ID,
        GT_BILL_FROM_PARTY_SITE_ID,
        GT_HISTORICAL_FLAG,
        GT_ACTG_SOURCE_ID,
        GT_AE_HEADER_ID,
        GT_EVENT_ID,
--      GT_ENTITY_ID,
        GT_LINE_CCID
        LIMIT C_LINES_PER_COMMIT;

       l_count := GT_DETAIL_TAX_LINE_ID.count;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.update_additional_info',
                                      'Rows fetched by rep_detail_cursor :'||to_char(l_count));
    END IF;

       IF l_count > 0 THEN
           initialize_variables(l_count);
           G_REP_CONTEXT_ID := ZX_EXTRACT_PKG.GET_REP_CONTEXT_ID(P_TRL_GLOBAL_VARIABLES_REC.LEGAL_ENTITY_ID,
                                                                 P_TRL_GLOBAL_VARIABLES_REC.request_id);

          FOR i in 1..l_count
          LOOP
          /* apai
              GT_REP_CONTEXT_ID(i) := ZX_EXTRACT_PKG.GET_REP_CONTEXT_ID(GT_INTERNAL_ORGANIZATION_ID(i),
                                                                          P_TRL_GLOBAL_VARIABLES_REC.legal_entity_level,
                                                                          P_TRL_GLOBAL_VARIABLES_REC.LEGAL_ENTITY_ID,
                                                                          P_TRL_GLOBAL_VARIABLES_REC.request_id);
          */
         IF (g_level_procedure >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.update_additional_info',
                                      ' GT_BILL_FROM_PTY_TAX_PROF_ID(i) :'||to_char(GT_DETAIL_TAX_LINE_ID(i)));
         END IF;

              extract_party_info(i);
              populate_meaning(P_TRL_GLOBAL_VARIABLES_REC,i);

         get_accounting_info(GT_TRX_ID(i),
                              GT_TRX_LINE_ID(i),
                              GT_TAX_LINE_ID(i),
                              GT_EVENT_ID(i),
                              GT_AE_HEADER_ID(i),
                              GT_ACTG_SOURCE_ID(i),
                              l_balancing_segment,
                              l_accounting_segment,
                              P_TRL_GLOBAL_VARIABLES_REC.SUMMARY_LEVEL,
                              P_TRL_GLOBAL_VARIABLES_REC.INCLUDE_DISCOUNTS,
                              GT_INTERNAL_ORGANIZATION_ID(i),
                     --         l_ledger_id,
                              i) ;

         get_accounting_amounts(GT_TRX_ID(i),
                              GT_TRX_LINE_ID(i),
                              GT_TAX_LINE_ID(i),
                    --          GT_ENTITY_ID(i),
                              GT_EVENT_ID(i),
                              GT_AE_HEADER_ID(i),
                              GT_ACTG_SOURCE_ID(i),
                              P_TRL_GLOBAL_VARIABLES_REC.SUMMARY_LEVEL,
                              l_ledger_id,
                              i) ;
          END LOOP;
       ELSE
          EXIT;
       END IF;

       EXIT WHEN rep_detail_cursor%NOTFOUND
            OR rep_detail_cursor%NOTFOUND IS NULL;

   END LOOP;

        update_zx_rep_detail_t(l_count);
           UPDATE_REP_ACTG_T(l_count);

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.update_additional_info.END',
                                      'update_additional_info(-)');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.update_additional_info',
                      g_error_buffer);
    END IF;

       P_TRL_GLOBAL_VARIABLES_REC.RETCODE := g_retcode;

END update_additional_info;


PROCEDURE extract_party_info( i IN BINARY_INTEGER) IS

   l_party_id          zx_rep_trx_detail_t.bill_from_party_id%TYPE;
   l_party_site_id     zx_rep_trx_detail_t.bill_from_party_site_id%TYPE;
   l_party_profile_id  zx_rep_trx_detail_t.BILL_FROM_PARTY_TAX_PROF_ID%TYPE;
   l_site_profile_id   zx_rep_trx_detail_t.BILL_FROM_SITE_TAX_PROF_ID%TYPE;

   l_tbl_index_party      BINARY_INTEGER;
   l_tbl_index_site       BINARY_INTEGER;

-- If party_id is NULL and Historical flag 'N' then get the party ID from zx_party_tax_profile

  CURSOR party_id_cur
       (c_bill_from_ptp_id zx_rep_trx_detail_t.BILL_FROM_PARTY_TAX_PROF_ID%TYPE) IS
    SELECT party_id
      FROM zx_party_tax_profile
     WHERE PARTY_TAX_PROFILE_ID = c_bill_from_ptp_id
       AND party_type_code = 'THIRD_PARTY';

  CURSOR party_site_id_cur
      (c_bill_from_stp_id zx_rep_trx_detail_t.BILL_FROM_SITE_TAX_PROF_ID%TYPE) IS
    SELECT party_id
      FROM zx_party_tax_profile
     WHERE PARTY_TAX_PROFILE_ID = c_bill_from_stp_id
       AND party_type_code = 'THIRD_PARTY_SITE';
-- If party_id is NOT NULL and Historical flag 'Y' then get the party tax profile ID from zx_party_tax_profile

  CURSOR party_profile_id_cur
      (c_bill_from_party_id zx_rep_trx_detail_t.bill_from_party_id%TYPE) IS
    SELECT party_tax_profile_id
      FROM zx_party_tax_profile
     WHERE party_id = c_bill_from_party_id
       AND party_type_code = 'THIRD_PARTY';

  CURSOR site_profile_id_cur
       (c_bill_from_site_id zx_rep_trx_detail_t.bill_from_party_site_id%TYPE) IS
    SELECT party_tax_profile_id
      FROM zx_party_tax_profile
     WHERE party_id = c_bill_from_site_id
       AND party_type_code = 'THIRD_PARTY_SITE';

  CURSOR party_cur
       (c_bill_from_party_id zx_rep_trx_detail_t.bill_from_party_id%TYPE) IS
    SELECT SEGMENT1,
           VAT_REGISTRATION_NUM,
           NUM_1099,
           VENDOR_NAME,
           VENDOR_NAME_ALT,
           STANDARD_INDUSTRY_CLASS
     FROM ap_suppliers
    WHERE party_id = c_bill_from_party_id;

  CURSOR party_site_cur
       (c_bill_from_site_id zx_rep_trx_detail_t.bill_from_party_site_id%TYPE) IS
    SELECT CITY,
           COUNTY,
           STATE,
           PROVINCE,
           ADDRESS_LINE1,
           ADDRESS_LINE2,
           ADDRESS_LINE3,
           ADDRESS_LINES_ALT,
           COUNTRY,
           ZIP,
      --     VENDOR_ID,
       --    VENDOR_SITE_ID,
        --   TAX_REPORTING_SITE_FLAG,
           GLOBAL_ATTRIBUTE17,
           VENDOR_SITE_CODE_ALT
     FROM ap_supplier_sites_all
    WHERE party_site_id = c_bill_from_site_id;


BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.extract_party_info.BEGIN',
                                      'extract_party_info(+) '||to_char(i));
    END IF;

    IF NVL(gt_historical_flag(i),'N') = 'N'  AND GT_BILL_FROM_PTY_TAX_PROF_ID(i) IS NOT NULL THEN
       OPEN party_id_cur(GT_BILL_FROM_PTY_TAX_PROF_ID(i));
       FETCH party_id_cur INTO l_party_id;

       OPEN party_site_id_cur(GT_BILL_FROM_SITE_TAX_PROF_ID(i));
       FETCH party_site_id_cur INTO l_party_site_id;
    ELSE
       OPEN party_profile_id_cur (GT_BILL_FROM_PARTY_ID(i));
       FETCH party_profile_id_cur into l_party_profile_id;

       OPEN site_profile_id_cur(GT_BILL_FROM_PARTY_SITE_ID(i));
       FETCH site_profile_id_cur INTO l_site_profile_id;

       l_party_id := GT_BILL_FROM_PARTY_ID(i);
       l_party_site_id := GT_BILL_FROM_PARTY_SITE_ID(i);

     END IF;
        IF (g_level_procedure >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.extract_party_info',
                                      ' l_party_id :'||to_char(l_party_id)||' '||to_char(GT_BILL_FROM_PTY_TAX_PROF_ID(i)));
             FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.extract_party_info',
                                      ' GT_DETAIL_TAX_LINE_ID :'||to_char(l_party_id)||' '||to_char(GT_DETAIL_TAX_LINE_ID(i)));
         END IF;

     IF l_party_id IS NOT NULL THEN
        l_tbl_index_party  := dbms_utility.get_hash_value(to_char(l_party_id), 1,8192);

        IF g_party_info_ap_tbl.EXISTS(l_tbl_index_party) THEN

           GT_BILLING_TP_NUMBER(i) := g_party_info_ap_tbl(l_tbl_index_party).BILLING_TP_NUMBER  ;
           GT_BILLING_TP_TAX_REG_NUM(i) :=g_party_info_ap_tbl(l_tbl_index_party).BILLING_TP_TAX_REG_NUM;
           GT_BILLING_TP_TAXPAYER_ID(i) :=g_party_info_ap_tbl(l_tbl_index_party).BILLING_TP_TAXPAYER_ID;
           GT_BILLING_TP_NAME(i) :=g_party_info_ap_tbl(l_tbl_index_party).BILLING_TP_NAME;
           GT_BILLING_TP_NAME_ALT(i) :=g_party_info_ap_tbl(l_tbl_index_party).BILLING_TP_NAME_ALT;
           GT_BILLING_TP_SIC_CODE(i) :=g_party_info_ap_tbl(l_tbl_index_party).BILLING_TP_SIC_CODE;

        ELSE

          OPEN party_cur (l_party_id);
          FETCH party_cur INTO
                GT_BILLING_TP_NUMBER(i),
                GT_BILLING_TP_TAX_REG_NUM(i),
                GT_BILLING_TP_TAXPAYER_ID(i),
                GT_BILLING_TP_NAME(i),
                GT_BILLING_TP_NAME_ALT(i),
                GT_BILLING_TP_SIC_CODE(i);

               g_party_info_ap_tbl(l_tbl_index_party).BILLING_TP_NUMBER := GT_BILLING_TP_NUMBER(i);
               g_party_info_ap_tbl(l_tbl_index_party).BILLING_TP_TAX_REG_NUM := GT_BILLING_TP_TAX_REG_NUM(i);
               g_party_info_ap_tbl(l_tbl_index_party).BILLING_TP_TAXPAYER_ID := GT_BILLING_TP_TAXPAYER_ID(i);
               g_party_info_ap_tbl(l_tbl_index_party).BILLING_TP_NAME := GT_BILLING_TP_NAME(i);
               g_party_info_ap_tbl(l_tbl_index_party).BILLING_TP_NAME_ALT := GT_BILLING_TP_NAME_ALT(i);
               g_party_info_ap_tbl(l_tbl_index_party).BILLING_TP_SIC_CODE := GT_BILLING_TP_SIC_CODE(i);

                 IF (g_level_procedure >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.extract_party_info',
                                      ' GT_BILLING_TP_NUMBER(i) :'||GT_BILLING_TP_NUMBER(i));
         END IF;

          END IF;
     END IF;

     IF l_party_site_id IS NOT NULL THEN
        l_tbl_index_site := dbms_utility.get_hash_value(to_char(l_party_site_id), 1,8192);

        IF g_party_site_tbl.EXISTS(l_tbl_index_site) THEN

           GT_BILLING_TP_CITY(i) := g_party_site_tbl(l_tbl_index_site).BILLING_TP_CITY;
           GT_BILLING_TP_COUNTY(i) := g_party_site_tbl(l_tbl_index_site).BILLING_TP_COUNTY;
           GT_BILLING_TP_COUNTY(i) := g_party_site_tbl(l_tbl_index_site).BILLING_TP_COUNTY;
           GT_BILLING_TP_STATE(i) := g_party_site_tbl(l_tbl_index_site).BILLING_TP_STATE;
           GT_BILLING_TP_PROVINCE(i) := g_party_site_tbl(l_tbl_index_site).BILLING_TP_PROVINCE;
           GT_BILLING_TP_ADDRESS1(i) := g_party_site_tbl(l_tbl_index_site).BILLING_TP_ADDRESS1;
           GT_BILLING_TP_ADDRESS2(i) := g_party_site_tbl(l_tbl_index_site).BILLING_TP_ADDRESS2;
           GT_BILLING_TP_ADDRESS3(i) := g_party_site_tbl(l_tbl_index_site).BILLING_TP_ADDRESS3;
           GT_BILLING_TP_ADDR_LINES_ALT(i) := g_party_site_tbl(l_tbl_index_site).BILLING_TP_ADDR_LINES_ALT;
           GT_BILLING_TP_COUNTRY(i) := g_party_site_tbl(l_tbl_index_site).BILLING_TP_COUNTRY;
           GT_BILLING_TP_POSTAL_CODE(i) := g_party_site_tbl(l_tbl_index_site).BILLING_TP_POSTAL_CODE;
           GT_GDF_PO_VENDOR_SITE_ATT17(i) := g_party_site_tbl(l_tbl_index_site).GDF_PO_VENDOR_SITE_ATT17;
           GT_BILLING_TP_SITE_NAME_ALT(i) :=g_party_site_tbl(l_tbl_index_site).BILLING_TP_SITE_NAME_ALT;

        ELSE

          OPEN  party_site_cur (l_party_site_id);
          FETCH party_site_cur INTO
                GT_BILLING_TP_CITY(i),
                GT_BILLING_TP_COUNTY(i),
                GT_BILLING_TP_STATE(i),
                GT_BILLING_TP_PROVINCE(i),
                GT_BILLING_TP_ADDRESS1(i),
                GT_BILLING_TP_ADDRESS2(i),
                GT_BILLING_TP_ADDRESS3(i),
                GT_BILLING_TP_ADDR_LINES_ALT(i),
                GT_BILLING_TP_COUNTRY(i),
                GT_BILLING_TP_POSTAL_CODE(i),
                GT_GDF_PO_VENDOR_SITE_ATT17(i),
                GT_BILLING_TP_SITE_NAME_ALT(i);

           g_party_site_tbl(l_tbl_index_site).BILLING_TP_CITY :=  GT_BILLING_TP_CITY(i);
           g_party_site_tbl(l_tbl_index_site).BILLING_TP_COUNTY := GT_BILLING_TP_COUNTY(i);
           g_party_site_tbl(l_tbl_index_site).BILLING_TP_COUNTY := GT_BILLING_TP_COUNTY(i);
           g_party_site_tbl(l_tbl_index_site).BILLING_TP_PROVINCE := GT_BILLING_TP_STATE(i);
           g_party_site_tbl(l_tbl_index_site).BILLING_TP_PROVINCE := GT_BILLING_TP_PROVINCE(i);
           g_party_site_tbl(l_tbl_index_site).BILLING_TP_ADDRESS1 := GT_BILLING_TP_ADDRESS1(i);
           g_party_site_tbl(l_tbl_index_site).BILLING_TP_ADDRESS2 := GT_BILLING_TP_ADDRESS2(i);
           g_party_site_tbl(l_tbl_index_site).BILLING_TP_ADDRESS3 := GT_BILLING_TP_ADDRESS3(i);
           g_party_site_tbl(l_tbl_index_site).BILLING_TP_ADDR_LINES_ALT := GT_BILLING_TP_ADDR_LINES_ALT(i);
           g_party_site_tbl(l_tbl_index_site).BILLING_TP_COUNTRY := GT_BILLING_TP_COUNTRY(i);
           g_party_site_tbl(l_tbl_index_site).BILLING_TP_POSTAL_CODE := GT_BILLING_TP_POSTAL_CODE(i);
           g_party_site_tbl(l_tbl_index_site).GDF_PO_VENDOR_SITE_ATT17 := GT_GDF_PO_VENDOR_SITE_ATT17(i);
           g_party_site_tbl(l_tbl_index_site).BILLING_TP_SITE_NAME_ALT := GT_BILLING_TP_SITE_NAME_ALT(i);

       END IF;
     END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.extract_party_info.END',
                                      'extract_party_info(-)');
    END IF;


EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.extract_party_info',
                      g_error_buffer);
    END IF;
    g_retcode := 2;
END extract_party_info;


PROCEDURE get_accounting_info(P_TRX_ID                IN NUMBER,
                              P_TRX_LINE_ID           IN NUMBER,
                              P_TAX_LINE_ID           IN NUMBER,
                   --           P_ENTITY_ID             IN NUMBER,
                              P_EVENT_ID              IN NUMBER,
                              P_AE_HEADER_ID          IN NUMBER,
                              P_TAX_DIST_ID           IN NUMBER,
                              P_BALANCING_SEGMENT     IN VARCHAR2,
                              P_ACCOUNTING_SEGMENT    IN VARCHAR2,
                              P_SUMMARY_LEVEL         IN VARCHAR2,
                              P_INCLUDE_DISCOUNTS     IN VARCHAR2,
                              P_ORG_ID                IN NUMBER,
                    --          P_LEDGER_ID             IN NUMBER,
                              i                       IN BINARY_INTEGER) IS

     CURSOR get_system_info_cur(c_org_id NUMBER) IS
     SELECT discount_distribution_method,
            disc_is_inv_less_tax_flag,
            liability_post_lookup_code
       FROM ap_system_parameters_all
      WHERE org_id = c_org_id;

    CURSOR trx_ccid (c_trx_id number, c_event_id number, c_ae_header_id number) IS
                  SELECT
                         ael.code_combination_id
                    FROM zx_rec_nrec_dist zx_dist,
                         xla_distribution_links lnk,
                         xla_ae_lines              ael
                   WHERE zx_dist.trx_id = c_trx_id
                     AND lnk.application_id = 200
                     AND lnk.source_distribution_type = 'AP_INVOICE_DISTRIBUTIONS'
                     AND lnk.source_distribution_id_num_1 = zx_dist.trx_line_dist_id
                     AND lnk.ae_header_id   = ael.ae_header_id
                     AND lnk.ae_line_num    = ael.ae_line_num
                     AND lnk.event_id       = c_event_id
                     AND lnk.ae_header_id   = c_ae_header_id
                     AND rownum =1;


            CURSOR trx_line_ccid (c_trx_id NUMBER,
                                  c_trx_line_id NUMBER,
                                  c_event_id NUMBER,
                                  c_ae_header_id NUMBER) IS
                  SELECT
                         ael.code_combination_id
                    FROM zx_rec_nrec_dist zx_dist,
                         xla_distribution_links lnk,
                         xla_ae_lines              ael
                   WHERE zx_dist.trx_id = c_trx_id
                     AND zx_dist.trx_line_id = c_trx_line_id
                     AND lnk.application_id = 200
                     AND lnk.source_distribution_type = 'AP_INVOICE_DISTRIBUTIONS'
                     AND lnk.source_distribution_id_num_1 = zx_dist.trx_line_dist_id
                     AND lnk.ae_header_id   = ael.ae_header_id
                     AND lnk.ae_line_num    = ael.ae_line_num
                     AND lnk.event_id       = c_event_id
                     AND lnk.ae_header_id   = c_ae_header_id
                     AND rownum =1;


-- For transavtion distribution level code combination id select in the build SQL
-- The following query can be removed ----

  CURSOR trx_dist_ccid (c_trx_id NUMBER, c_trx_line_id NUMBER, c_event_id NUMBER, c_ae_header_id NUMBER) IS
                  SELECT
                         ael.code_combination_id
                    FROM zx_rec_nrec_dist zx_dist,
                         xla_distribution_links lnk,
                         xla_ae_lines            ael
                   WHERE zx_dist.trx_id = c_trx_id
                     AND zx_dist.trx_line_id = c_trx_line_id
                     AND lnk.application_id = 200
                     AND lnk.source_distribution_type = 'AP_INVOICE_DISTRIBUTIONS'
                     AND lnk.source_distribution_id_num_1 = zx_dist.trx_line_dist_id
                     AND lnk.ae_header_id   = ael.ae_header_id
                     AND lnk.ae_line_num    = ael.ae_line_num
                     AND lnk.event_id       = c_event_id
                     AND lnk.ae_header_id   = c_ae_header_id
                     AND rownum =1;



    CURSOR tax_ccid (c_trx_id number, c_event_id number, c_ae_header_id number) IS
                  SELECT
                         ael.code_combination_id
                    FROM zx_rec_nrec_dist zx_dist,
                         xla_distribution_links lnk,
                         xla_ae_lines              ael
                   WHERE zx_dist.trx_id = c_trx_id
                     AND lnk.application_id = 200
                     AND lnk.source_distribution_type = 'AP_INVOICE_DISTRIBUTIONS'
                     AND lnk.tax_rec_nrec_dist_ref_id = zx_dist.rec_nrec_tax_dist_id
                     AND lnk.ae_header_id   = ael.ae_header_id
                     AND lnk.ae_line_num    = ael.ae_line_num
                     AND lnk.event_id       = c_event_id
                     AND lnk.ae_header_id   = c_ae_header_id
                     AND rownum =1;


    CURSOR tax_line_ccid (c_trx_id number, c_tax_line_id NUMBER, c_event_id number, c_ae_header_id number) IS
                  SELECT
                         ael.code_combination_id
                    FROM zx_rec_nrec_dist zx_dist,
                         xla_distribution_links lnk,
                         xla_ae_lines              ael
                   WHERE zx_dist.trx_id = c_trx_id
                     AND zx_dist.tax_line_id = c_tax_line_id
                     AND lnk.application_id = 200
                     AND lnk.source_distribution_type = 'AP_INVOICE_DISTRIBUTIONS'
                     AND lnk.tax_rec_nrec_dist_ref_id = zx_dist.rec_nrec_tax_dist_id
                     AND lnk.ae_header_id   = ael.ae_header_id
                     AND lnk.ae_line_num    = ael.ae_line_num
                     AND lnk.event_id       = c_event_id
                     AND lnk.ae_header_id   = c_ae_header_id
                     AND rownum =1;


-- For transaction distribution level code combination id select in the build SQL
-- The following query can be removed ----

  CURSOR tax_dist_ccid (c_trx_id NUMBER, c_tax_line_id NUMBER, c_tax_line_dist_id NUMBER,
                                      c_event_id number, c_ae_header_id number) IS
                 SELECT
                         ael.code_combination_id
                    FROM zx_rec_nrec_dist zx_dist,
                         xla_distribution_links lnk,
                         xla_ae_lines              ael
                   WHERE zx_dist.trx_id = c_trx_id
                     AND zx_dist.tax_line_id = c_tax_line_id
                     AND zx_dist.REC_NREC_TAX_DIST_ID = c_tax_line_dist_id
                     AND lnk.application_id = 200
                     AND lnk.source_distribution_type = 'AP_INVOICE_DISTRIBUTIONS'
                     AND lnk.tax_rec_nrec_dist_ref_id = zx_dist.rec_nrec_tax_dist_id
                     AND lnk.ae_header_id   = ael.ae_header_id
                     AND lnk.ae_line_num    = ael.ae_line_num
                     AND lnk.event_id       = c_event_id
                     AND lnk.ae_header_id   = c_ae_header_id
                     AND rownum =1;


  l_disc_is_inv_less_tax_flag         VARCHAR2(1);
  l_disc_distribution_method          VARCHAR2(30);
  l_liability_post_lookup_code        VARCHAR2(30);

  L_BAL_SEG_VAL                       VARCHAR2(240);
  L_ACCT_SEG_VAL                      VARCHAR2(240);
  L_SQL_STATEMENT1                    VARCHAR2(1000);
  L_SQL_STATEMENT2                    VARCHAR2(1000);
  l_ccid number;

BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.get_accounting_info.BEGIN',
                                      'get_accounting_info(+)');
    END IF;

  GT_TRX_ARAP_BALANCING_SEGMENT(i)    := NULL;
  GT_TRX_ARAP_NATURAL_ACCOUNT(i)      := NULL;
  GT_TRX_TAXABLE_BAL_SEG(i)           := NULL;
  GT_TRX_TAXABLE_NATURAL_ACCOUNT(i)   := NULL;
  GT_TRX_TAX_BALANCING_SEGMENT(i)     := NULL;
  GT_TRX_TAX_NATURAL_ACCOUNT(i)       := NULL;


  L_BAL_SEG_VAL := '';
  L_ACCT_SEG_VAL := '';

  L_SQL_STATEMENT1 := ' SELECT '||P_BALANCING_SEGMENT ||
                      ' FROM GL_CODE_COMBINATIONS '||
                      ' WHERE CODE_COMBINATION_ID = :L_CCID ';

  L_SQL_STATEMENT2 := ' SELECT '||P_ACCOUNTING_SEGMENT ||
                      ' FROM GL_CODE_COMBINATIONS '||
                      ' WHERE CODE_COMBINATION_ID = :L_CCID ';

    OPEN get_system_info_cur(p_org_id);
  FETCH get_system_info_cur
   INTO l_disc_distribution_method,
        l_disc_is_inv_less_tax_flag,
        l_liability_post_lookup_code;
  CLOSE get_system_info_cur;


   IF NVL(l_disc_is_inv_less_tax_flag, 'N') = 'N' AND
      NVL(l_disc_distribution_method, 'SYSTEM') <> 'SYSTEM' THEN

     IF P_INCLUDE_DISCOUNTS = 'Y' THEN
        get_discount_info(i,
                          P_TRX_ID,
                          P_TAX_LINE_ID,
                          P_SUMMARY_LEVEL,
                          P_TAX_DIST_ID,
                          P_TRX_LINE_ID,
                          l_disc_distribution_method,
                          l_liability_post_lookup_code);
    END IF;
   END IF;


  IF P_SUMMARY_LEVEL = 'TRANSACTION' THEN
      OPEN trx_ccid (p_trx_id, p_event_id, p_ae_header_id);
      LOOP
      FETCH trx_ccid INTO l_ccid;
      EXIT WHEN trx_ccid%NOTFOUND;

        EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL
                                          USING l_ccid;

        EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                          USING l_ccid;

        IF GT_TRX_TAXABLE_BAL_SEG(i) IS NULL then
            GT_TRX_TAXABLE_BAL_SEG(i) := L_BAL_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_BAL_SEG(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_BAL_SEG(i)  := GT_TRX_TAXABLE_BAL_SEG(i)
                                             ||','||L_BAL_SEG_VAL;
            END IF;
        END IF;


        IF GT_TRX_TAXABLE_NATURAL_ACCOUNT(i) IS NULL then
            GT_TRX_TAXABLE_NATURAL_ACCOUNT(i) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_NATURAL_ACCOUNT(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_NATURAL_ACCOUNT(i)  := GT_TRX_TAXABLE_NATURAL_ACCOUNT(i)
                                             ||','||L_ACCT_SEG_VAL;
            END IF;
        END IF;

        GT_TRX_ARAP_BALANCING_SEGMENT(i) := GT_TRX_TAXABLE_BAL_SEG(i);
        GT_TRX_ARAP_NATURAL_ACCOUNT(i)   := GT_TRX_TAXABLE_NATURAL_ACCOUNT(i);
    END LOOP;


      OPEN tax_ccid (p_trx_id, p_event_id, p_ae_header_id);
      LOOP
      FETCH tax_ccid INTO l_ccid;
      EXIT WHEN tax_ccid%NOTFOUND;

        EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL
                                          USING l_ccid;

        EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                          USING l_ccid;

        IF GT_TRX_TAX_BALANCING_SEGMENT(i) IS NULL then
            GT_TRX_TAX_BALANCING_SEGMENT(i) := L_BAL_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_BALANCING_SEGMENT(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_BALANCING_SEGMENT(i)  := GT_TRX_TAX_BALANCING_SEGMENT(i)
                                             ||','||L_BAL_SEG_VAL;
            END IF;
        END IF;


        IF GT_TRX_TAX_NATURAL_ACCOUNT(i) IS NULL then
            GT_TRX_TAX_NATURAL_ACCOUNT(i) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_NATURAL_ACCOUNT(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_NATURAL_ACCOUNT(i)  := GT_TRX_TAX_NATURAL_ACCOUNT(i)
                                             ||','||L_ACCT_SEG_VAL;
            END IF;
        END IF;

    END LOOP;

  ELSIF P_SUMMARY_LEVEL = 'TRANSACTION_LINE' THEN
      OPEN trx_line_ccid (p_trx_id, p_trx_line_id, p_event_id, p_ae_header_id);
      LOOP
      FETCH trx_line_ccid INTO l_ccid;
      EXIT WHEN trx_line_ccid%NOTFOUND;

        EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL
                                          USING l_ccid;

        EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                          USING l_ccid;

        IF GT_TRX_TAXABLE_BAL_SEG(i) IS NULL then
            GT_TRX_TAXABLE_BAL_SEG(i) := L_BAL_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_BAL_SEG(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_BAL_SEG(i)  := GT_TRX_TAXABLE_BAL_SEG(i)
                                             ||','||L_BAL_SEG_VAL;
            END IF;
        END IF;


        IF GT_TRX_TAXABLE_NATURAL_ACCOUNT(i) IS NULL then
            GT_TRX_TAXABLE_NATURAL_ACCOUNT(i) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_NATURAL_ACCOUNT(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_NATURAL_ACCOUNT(i)  := GT_TRX_TAXABLE_NATURAL_ACCOUNT(i)
                                             ||','||L_ACCT_SEG_VAL;
            END IF;
        END IF;

        GT_TRX_ARAP_BALANCING_SEGMENT(i) := GT_TRX_TAXABLE_BAL_SEG(i);
        GT_TRX_ARAP_NATURAL_ACCOUNT(i)   := GT_TRX_TAXABLE_NATURAL_ACCOUNT(i);
    END LOOP;


      OPEN tax_line_ccid (p_trx_id, p_trx_line_id, p_event_id, p_ae_header_id);
      LOOP
      FETCH tax_line_ccid INTO l_ccid;
      EXIT WHEN tax_line_ccid%NOTFOUND;

        EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL
                                          USING l_ccid;

        EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                          USING l_ccid;

        IF GT_TRX_TAX_BALANCING_SEGMENT(i) IS NULL then
            GT_TRX_TAX_BALANCING_SEGMENT(i) := L_BAL_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_BALANCING_SEGMENT(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_BALANCING_SEGMENT(i)  := GT_TRX_TAX_BALANCING_SEGMENT(i)
                                             ||','||L_BAL_SEG_VAL;
            END IF;
        END IF;


        IF GT_TRX_TAX_NATURAL_ACCOUNT(i) IS NULL then
            GT_TRX_TAX_NATURAL_ACCOUNT(i) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_NATURAL_ACCOUNT(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_NATURAL_ACCOUNT(i)  := GT_TRX_TAX_NATURAL_ACCOUNT(i)
                                             ||','||L_ACCT_SEG_VAL;
            END IF;
        END IF;

    END LOOP;


  ELSIF P_SUMMARY_LEVEL = 'TRANSACTION_DISTRIBUTION' THEN
      OPEN trx_dist_ccid (p_trx_id, p_trx_line_id, p_event_id, p_ae_header_id);
      LOOP
      FETCH trx_dist_ccid INTO l_ccid;
      EXIT WHEN trx_dist_ccid%NOTFOUND;

        EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL
                                          USING l_ccid;

        EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                          USING l_ccid;

        IF GT_TRX_TAXABLE_BAL_SEG(i) IS NULL then
            GT_TRX_TAXABLE_BAL_SEG(i) := L_BAL_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_BAL_SEG(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_BAL_SEG(i)  := GT_TRX_TAXABLE_BAL_SEG(i)
                                             ||','||L_BAL_SEG_VAL;
            END IF;
        END IF;


        IF GT_TRX_TAXABLE_NATURAL_ACCOUNT(i) IS NULL then
            GT_TRX_TAXABLE_NATURAL_ACCOUNT(i) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAXABLE_NATURAL_ACCOUNT(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAXABLE_NATURAL_ACCOUNT(i)  := GT_TRX_TAXABLE_NATURAL_ACCOUNT(i)
                                             ||','||L_ACCT_SEG_VAL;
            END IF;
        END IF;

        GT_TRX_ARAP_BALANCING_SEGMENT(i) := GT_TRX_TAXABLE_BAL_SEG(i);
        GT_TRX_ARAP_NATURAL_ACCOUNT(i)   := GT_TRX_TAXABLE_NATURAL_ACCOUNT(i);
    END LOOP;


      OPEN tax_dist_ccid (p_trx_id, p_tax_line_id, p_tax_dist_id, p_event_id, p_ae_header_id);
      LOOP
      FETCH tax_ccid INTO l_ccid;
      EXIT WHEN tax_ccid%NOTFOUND;

        EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL
                                          USING l_ccid;

        EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                          USING l_ccid;

        IF GT_TRX_TAX_BALANCING_SEGMENT(i) IS NULL then
            GT_TRX_TAX_BALANCING_SEGMENT(i) := L_BAL_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_BALANCING_SEGMENT(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_BALANCING_SEGMENT(i)  := GT_TRX_TAX_BALANCING_SEGMENT(i)
                                             ||','||L_BAL_SEG_VAL;
            END IF;
        END IF;


        IF GT_TRX_TAX_NATURAL_ACCOUNT(i) IS NULL then
            GT_TRX_TAX_NATURAL_ACCOUNT(i) := L_ACCT_SEG_VAL;
        ELSE
            IF INSTRB(GT_TRX_TAX_NATURAL_ACCOUNT(i),L_BAL_SEG_VAL) > 0 THEN
                NULL;
            ELSE
                GT_TRX_TAX_NATURAL_ACCOUNT(i)  := GT_TRX_TAX_NATURAL_ACCOUNT(i)
                                             ||','||L_ACCT_SEG_VAL;
            END IF;
        END IF;

    END LOOP;
END IF; -- Summary Level

  IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.get_accounting_info.END',
                                      'get_accounting_info(-)');
    END IF;

END get_accounting_info;


PROCEDURE get_accounting_amounts(P_TRX_ID                IN NUMBER,
                                 P_TRX_LINE_ID           IN NUMBER,
                                 P_TAX_LINE_ID           IN NUMBER,
                  --               P_ENTITY_ID             IN NUMBER,
                                 P_EVENT_ID              IN NUMBER,
                                 P_AE_HEADER_ID          IN NUMBER,
                                 P_TAX_DIST_ID           IN NUMBER,
                                 P_SUMMARY_LEVEL         IN VARCHAR2,
                                 P_LEDGER_ID             IN NUMBER,
                                 i                       IN binary_integer) IS
-- Transaction Header Level

   CURSOR taxable_amount_hdr (c_trx_id NUMBER, c_ae_header_id NUMBER, c_event_id NUMBER, c_ledger_id NUMBER) IS
        SELECT sum(lnk.DOC_ROUNDING_ENTERED_AMT), sum(lnk.DOC_ROUNDING_ACCTD_AMT)
         FROM zx_rec_nrec_dist zx_dist,
              xla_distribution_links lnk,
              xla_ae_headers         aeh,
              xla_ae_lines           ael
        WHERE zx_dist.trx_id = c_trx_id
          AND lnk.application_id = 200
          AND lnk.source_distribution_type = 'AP_INVOICE_DISTRIBUTIONS'
          AND lnk.source_distribution_id_num_1 = zx_dist.trx_line_id
          AND lnk.ae_header_id   = c_ae_header_id
          AND lnk.event_id = c_event_id
          AND lnk.ae_line_num    = ael.ae_line_num
          AND lnk.ae_header_id   = ael.ae_header_id
          AND aeh.ae_header_id   = ael.ae_header_id
          AND aeh.ledger_id = c_ledger_id;


   CURSOR tax_amount_hdr (c_trx_id NUMBER, c_ae_header_id NUMBER,  c_event_id NUMBER,c_ledger_id NUMBER) IS
        SELECT sum(lnk.DOC_ROUNDING_ENTERED_AMT), sum(lnk.DOC_ROUNDING_ACCTD_AMT)
         FROM zx_rec_nrec_dist zx_dist,
              xla_distribution_links lnk,
              xla_ae_headers         aeh,
              xla_ae_lines              ael
        WHERE zx_dist.trx_id = c_trx_id
          AND lnk.application_id = 200
          AND lnk.source_distribution_type = 'AP_INVOICE_DISTRIBUTIONS'
          AND lnk.tax_rec_nrec_dist_ref_id = zx_dist.rec_nrec_tax_dist_id
          AND lnk.ae_header_id   = c_ae_header_id
          AND lnk.event_id = c_event_id
          AND lnk.ae_line_num    = ael.ae_line_num
          AND aeh.ae_header_id   = ael.ae_header_id
          AND aeh.ledger_id = c_ledger_id;


-- Transaction Line Level

 CURSOR taxable_amount_line (c_trx_id NUMBER,c_trx_line_id NUMBER, c_ae_header_id NUMBER,
                            c_event_id NUMBER, c_ledger_id NUMBER) IS
        SELECT sum(lnk.DOC_ROUNDING_ENTERED_AMT), sum(lnk.DOC_ROUNDING_ACCTD_AMT)
         FROM zx_rec_nrec_dist zx_dist,
              xla_distribution_links lnk,
              xla_ae_headers         aeh,
              xla_ae_lines              ael
        WHERE zx_dist.trx_id = c_trx_id
          AND zx_dist.trx_line_id = c_trx_line_id
          AND lnk.application_id = 200
          AND lnk.source_distribution_type = 'AP_INVOICE_DISTRIBUTIONS'
          AND lnk.source_distribution_id_num_1 = zx_dist.trx_line_id
          AND lnk.ae_header_id   = c_ae_header_id
          AND lnk.event_id       = c_event_id
          AND lnk.ae_line_num    = ael.ae_line_num
          AND aeh.ae_header_id   = ael.ae_header_id
          AND aeh.ledger_id      = c_ledger_id;


CURSOR tax_amount_line (c_trx_id NUMBER,c_tax_line_id NUMBER, c_ae_header_id NUMBER,
                       c_event_id NUMBER, c_ledger_id NUMBER) IS
        SELECT sum(lnk.DOC_ROUNDING_ENTERED_AMT), sum(lnk.DOC_ROUNDING_ACCTD_AMT)
         FROM zx_rec_nrec_dist zx_dist,
              xla_distribution_links lnk,
              xla_ae_headers         aeh,
              xla_ae_lines              ael
        WHERE zx_dist.trx_id = c_trx_id
          AND zx_dist.tax_line_id = c_tax_line_id
          AND lnk.application_id = 200
          AND lnk.source_distribution_type = 'AP_INVOICE_DISTRIBUTIONS'
          AND lnk.tax_rec_nrec_dist_ref_id = zx_dist.rec_nrec_tax_dist_id
          AND lnk.ae_header_id   = c_ae_header_id
          AND lnk.event_id       = c_event_id
          AND lnk.ae_line_num    = ael.ae_line_num
          AND aeh.ae_header_id   = ael.ae_header_id
          AND aeh.ledger_id      = c_ledger_id;


-- Transaction Distribution Level



CURSOR tax_amount_dist ( c_trx_id NUMBER,c_tax_line_id NUMBER, c_tax_dist_id NUMBER, c_ae_header_id NUMBER,
                        c_event_id NUMBER, c_ledger_id NUMBER) IS
        SELECT sum(lnk.DOC_ROUNDING_ENTERED_AMT), sum(lnk.DOC_ROUNDING_ACCTD_AMT)
         FROM zx_rec_nrec_dist zx_dist,
              xla_distribution_links lnk,
              xla_ae_headers         aeh,
              xla_ae_lines              ael
        WHERE zx_dist.trx_id = c_trx_id
          AND zx_dist.tax_line_id = c_tax_line_id
          AND zx_dist.rec_nrec_tax_dist_id = c_tax_dist_id
          AND lnk.application_id = 200
          AND lnk.source_distribution_type = 'AP_INVOICE_DISTRIBUTIONS'
          AND lnk.tax_rec_nrec_dist_ref_id = zx_dist.rec_nrec_tax_dist_id
          AND lnk.ae_header_id   = c_ae_header_id
          AND lnk.event_id       = c_event_id
          AND lnk.ae_line_num    = ael.ae_line_num
          AND aeh.ae_header_id   = ael.ae_header_id
          AND aeh.ledger_id      = c_ledger_id;


 CURSOR taxable_amount_dist (c_trx_id NUMBER,c_trx_line_id NUMBER, c_ae_header_id NUMBER,
                             c_event_id NUMBER, c_ledger_id NUMBER) IS
        SELECT sum(lnk.DOC_ROUNDING_ENTERED_AMT), sum(lnk.DOC_ROUNDING_ACCTD_AMT)
         FROM zx_rec_nrec_dist zx_dist,
              xla_distribution_links lnk,
              xla_ae_headers         aeh,
              xla_ae_lines              ael
        WHERE zx_dist.trx_id = c_trx_id
          AND zx_dist.trx_line_id  = c_trx_line_id
    --      AND zx_dist.trx_line_dist_id  = c_trx_line_dist_id
          AND lnk.application_id = 200
          AND lnk.source_distribution_type = 'AP_INVOICE_DISTRIBUTIONS'
          AND lnk.source_distribution_id_num_1 = zx_dist.trx_line_dist_id
          AND lnk.ae_header_id   = c_ae_header_id
          AND lnk.event_id = c_event_id
          AND lnk.ae_line_num    = ael.ae_line_num
          AND aeh.ae_header_id   = ael.ae_header_id
          AND aeh.ledger_id      = c_ledger_id;



BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.get_accounting_amounts.BEGIN',
                                      'get_accounting_amounts(+)');
    END IF;

   IF p_summary_level = 'TRANSACTION' THEN
      OPEN taxable_amount_hdr(p_trx_id , p_ae_header_id , p_event_id, p_ledger_id);
      FETCH taxable_amount_hdr INTO GT_TAXABLE_AMT(i),GT_TAXABLE_AMT_FUNCL_CURR(i);
       --    EXIT WHEN taxable_amount_hdr%NOTFOUND;
       CLOSE taxable_amount_hdr;

      OPEN tax_amount_hdr(p_trx_id , p_ae_header_id , p_event_id, p_ledger_id);
      FETCH tax_amount_hdr INTO GT_TAX_AMT(i),GT_TAX_AMT_FUNCL_CURR(i);
--      EXIT WHEN tax_amount_hdr%NOTFOUND;
     CLOSE tax_amount_hdr;
  ELSIF p_summary_level = 'TRANSACTION_LINE' THEN
           OPEN taxable_amount_line(p_trx_id ,p_trx_line_id, p_ae_header_id , p_event_id, p_ledger_id);
      FETCH taxable_amount_line INTO GT_TAXABLE_AMT(i),GT_TAXABLE_AMT_FUNCL_CURR(i);
  --        EXIT WHEN taxable_amount_line%NOTFOUND;
        CLOSE taxable_amount_line;

      OPEN tax_amount_line(p_trx_id , p_trx_line_id, p_ae_header_id , p_event_id, p_ledger_id);
      FETCH tax_amount_line INTO GT_TAX_AMT(i),GT_TAX_AMT_FUNCL_CURR(i);
--      EXIT WHEN tax_amount_line%NOTFOUND;
      CLOSE tax_amount_line;

  ELSIF p_summary_level = 'TRANSACTION_DISTRIBUTION' THEN
      OPEN taxable_amount_dist(p_tax_dist_id ,p_trx_line_id,p_ae_header_id , p_event_id, p_ledger_id);
      FETCH taxable_amount_dist INTO GT_TAXABLE_AMT(i),GT_TAXABLE_AMT_FUNCL_CURR(i);
--         EXIT WHEN taxable_amount_dist%NOTFOUND;
        CLOSE taxable_amount_dist;

      OPEN tax_amount_dist(p_trx_id,p_tax_line_id, p_tax_dist_id, p_ae_header_id , p_event_id, p_ledger_id);
      FETCH tax_amount_dist INTO GT_TAX_AMT(i),GT_TAX_AMT_FUNCL_CURR(i);
 --     EXIT WHEN tax_amount_dist%NOTFOUND;
     CLOSE tax_amount_dist;
 END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.get_accounting_amounts.END',
                                      'get_accounting_amounts(-)');
    END IF;

 END get_accounting_amounts;


/*PROCEDURE get_discount_info
                ( i                      IN BINARY_INTEGER,
                 P_TRX_ID                       IN    NUMBER,
                 --  P_TAX_ID                       IN    NUMBER,
                 P_SUMMARY_LEVEL                IN    VARCHAR2,
                 P_DIST_ID                      IN    NUMBER,
                 P_TRX_LINE_ID                  IN    NUMBER,
                 P_DISC_DISTRIBUTION_METHOD     IN    VARCHAR2,
                 P_LIABILITY_POST_LOOKUP_CODE   IN    VARCHAR2
                 )
*/
PROCEDURE get_discount_info
                ( j                      IN BINARY_INTEGER,
                 P_TRX_ID                       IN    NUMBER,
                 P_TAX_LINE_ID                       IN    NUMBER,
                 P_SUMMARY_LEVEL                IN    VARCHAR2,
                 P_DIST_ID                      IN    NUMBER,
                 P_TRX_LINE_ID                  IN    NUMBER,
                 P_DISC_DISTRIBUTION_METHOD     IN    VARCHAR2,
                 P_LIABILITY_POST_LOOKUP_CODE   IN    VARCHAR2
                 )
IS

  CURSOR  taxable_hdr_csr IS
  SELECT sum(aphd.amount), -- discount amount (entered)
         sum(aphd.paid_base_amount) -- discount amount (accounted)
    FROM ap_invoice_distributions_all aid,
         ap_invoices_all ai,
         ap_invoice_payments_all aip,
         ap_payment_hist_dists aphd,
         ap_payment_history_all aph
   WHERE aid.invoice_id = ai.invoice_id
     AND aid.invoice_id = aip.invoice_id
     AND aid.distribution_line_number
                IN (SELECT distribution_line_number
                      FROM ap_invoice_distributions_all
                     WHERE invoice_id = p_trx_id
                       AND line_type_lookup_code = 'ITEM')
     AND aip.invoice_payment_id = aphd.invoice_payment_id
     AND aphd.PAY_DIST_LOOKUP_CODE = 'DISCOUNT'
     AND aphd.invoice_distribution_id = aid.invoice_distribution_id
     AND nvl(aph.historical_flag, 'N') = 'N'
     AND aph.check_id = aip.check_id
 UNION
  SELECT xal.entered_dr - xal.entered_cr ,
                -- discount entered amount (replace this with new xla colum names)
         xal.accounted_dr -xal.entered_cr
                -- discount entered amount (replace this with new xla colum names)
    FROM ap_invoice_distributions_all aid,
         ap_invoices_all ai,
         ap_invoice_payments_all aip,
         ap_payment_history_all aph,
         xla_ae_lines    xal
   WHERE aid.invoice_id = ai.invoice_id
     AND aid.invoice_id = aip.invoice_id
     AND aid.distribution_line_number
                IN (SELECT distribution_line_number
                      FROM ap_invoice_distributions_all
                     WHERE invoice_id = p_trx_id
                       AND line_type_lookup_code = 'ITEM')
     AND aip.invoice_payment_id = xal.Upg_Tax_Reference_ID3
     AND aid.old_dist_line_number = xal.Upg_Tax_Reference_ID2
     AND xal.accounting_class_code = 'DISCOUNT'
     AND aph.check_id = aip.check_id
     AND nvl(aph.historical_flag, 'N') = 'Y';

  CURSOR tax_hdr_csr IS
    SELECT sum(aphd.amount), -- discount amount (entered)
           sum(aphd.paid_base_amount) -- discount amount (accounted)
      FROM ap_invoice_distributions_all aid,
           ap_invoices_all ai,
           ap_invoice_payments_all aip,
           ap_payment_hist_dists aphd,
           ap_payment_history_all aph
     WHERE aid.invoice_id = ai.invoice_id
       AND aid.invoice_id = aip.invoice_id
       AND aid.distribution_line_number
                  IN (SELECT distribution_line_number
                        FROM ap_invoice_distributions_all
                       WHERE invoice_id = p_trx_id
                         AND line_type_lookup_code = 'TAX')
       AND aip.invoice_payment_id = aphd.invoice_payment_id
       AND aphd.PAY_DIST_LOOKUP_CODE = 'DISCOUNT'
       AND aphd.invoice_distribution_id = aid.invoice_distribution_id
       AND nvl(aph.historical_flag, 'N') = 'N'
       AND aph.check_id = aip.check_id
   UNION
    SELECT xal.entered_dr - xal.entered_cr ,
                  -- discount entered amount (replace this with new xla colum names)
           xal.accounted_dr -xal.entered_cr
                  -- discount entered amount (replace this with new xla colum names)
      FROM ap_invoice_distributions_all aid,
           ap_invoices_all ai,
           ap_invoice_payments_all aip,
           ap_payment_history_all aph,
           xla_ae_lines    xal
     WHERE aid.invoice_id = ai.invoice_id
       AND aid.invoice_id = aip.invoice_id
       AND aid.distribution_line_number
                  IN (SELECT distribution_line_number
                        FROM ap_invoice_distributions_all
                       WHERE invoice_id = p_trx_id
                         AND line_type_lookup_code = 'TAX')
       AND aip.invoice_payment_id = xal.Upg_Tax_Reference_ID3
       AND aid.old_dist_line_number = xal.Upg_Tax_Reference_ID2
       AND xal.accounting_class_code = 'DISCOUNT'
       AND aph.check_id = aip.check_id
       AND nvl(aph.historical_flag, 'N') = 'Y';

    CURSOR taxable_line_csr IS
    SELECT sum(aphd.amount), -- discount amount (entered)
           sum(aphd.paid_base_amount) -- discount amount (accounted)
      FROM ap_invoice_distributions_all aid,
           ap_invoices_all ai,
           ap_invoice_payments_all aip,
           ap_payment_hist_dists aphd,
           ap_payment_history_all aph
     WHERE aid.invoice_id = ai.invoice_id
       AND aid.invoice_id = aip.invoice_id
--       AND aid.distribution_line_number
       AND aid.invoice_distribution_id = p_trx_line_id
       AND aip.invoice_payment_id = aphd.invoice_payment_id
       AND aphd.PAY_DIST_LOOKUP_CODE = 'DISCOUNT'
       AND aphd.invoice_distribution_id = aid.invoice_distribution_id
       AND nvl(aph.historical_flag, 'N') = 'N'
       AND aph.check_id = aip.check_id
   UNION
       SELECT xal.entered_dr - xal.entered_cr ,
                     -- discount entered amount (replace this with new xla colum names)
              xal.accounted_dr -xal.entered_cr
                     -- discount entered amount (replace this with new xla colum names)
         FROM ap_invoice_distributions_all aid,
              ap_invoices_all ai,
              ap_invoice_payments_all aip,
              ap_payment_history_all aph,
              xla_ae_lines    xal
        WHERE aid.invoice_id = ai.invoice_id
          AND aid.invoice_id = aip.invoice_id
--          AND aid.distribution_line_number
          AND aid.invoice_distribution_id = p_trx_line_id
          AND aip.invoice_payment_id = xal.Upg_Tax_Reference_ID3
          AND aid.old_dist_line_number = xal.Upg_Tax_Reference_ID2
          AND xal.accounting_class_code = 'DISCOUNT'
          AND aph.check_id = aip.check_id
          AND nvl(aph.historical_flag, 'N') = 'Y';


CURSOR tax_line_csr IS
    SELECT sum(aphd.amount), -- discount amount (entered)
           sum(aphd.paid_base_amount) -- discount amount (accounted)
      FROM ap_invoice_distributions_all aid,
           ap_invoices_all ai,
           ap_invoice_payments_all aip,
           ap_payment_hist_dists aphd,
           ap_payment_history_all aph
     WHERE aid.invoice_id = ai.invoice_id
       AND aid.invoice_id = aip.invoice_id
--      AND aid.distribution_line_number
       AND aid.invoice_distribution_id = p_tax_line_id
       AND aip.invoice_payment_id = aphd.invoice_payment_id
       AND aphd.PAY_DIST_LOOKUP_CODE = 'DISCOUNT'
       AND aphd.invoice_distribution_id = aid.invoice_distribution_id
       AND nvl(aph.historical_flag, 'N') = 'N'
       AND aph.check_id = aip.check_id
   UNION
       SELECT xal.entered_dr - xal.entered_cr ,
                     -- discount entered amount (replace this with new xla colum names)
              xal.accounted_dr -xal.entered_cr
                     -- discount entered amount (replace this with new xla colum names)
         FROM ap_invoice_distributions_all aid,
              ap_invoices_all ai,
              ap_invoice_payments_all aip,
              ap_payment_history_all aph,
              xla_ae_lines    xal
        WHERE aid.invoice_id = ai.invoice_id
          AND aid.invoice_id = aip.invoice_id
--          AND aid.distribution_line_number
          AND aid.invoice_distribution_id = p_tax_line_id
          AND aip.invoice_payment_id = xal.Upg_Tax_Reference_ID3
          AND aid.old_dist_line_number = xal.Upg_Tax_Reference_ID2
          AND xal.accounting_class_code = 'DISCOUNT'
          AND aph.check_id = aip.check_id
          AND nvl(aph.historical_flag, 'N') = 'Y';


    CURSOR taxable_dist_csr IS
    SELECT sum(aphd.amount), -- discount amount (entered)
           sum(aphd.paid_base_amount) -- discount amount (accounted)
      FROM ap_invoice_distributions_all aid,
           ap_invoices_all ai,
           ap_invoice_payments_all aip,
           ap_payment_hist_dists aphd,
           ap_payment_history_all aph
     WHERE aid.invoice_id = ai.invoice_id
       AND aid.invoice_id = aip.invoice_id
--       AND aid.distribution_line_number
       AND aid.invoice_distribution_id = p_trx_line_id
       AND aip.invoice_payment_id = aphd.invoice_payment_id
       AND aphd.PAY_DIST_LOOKUP_CODE = 'DISCOUNT'
       AND aphd.invoice_distribution_id = aid.invoice_distribution_id
       AND nvl(aph.historical_flag, 'N') = 'N'
       AND aph.check_id = aip.check_id
   UNION
       SELECT xal.entered_dr - xal.entered_cr ,
                     -- discount entered amount (replace this with new xla colum names)
              xal.accounted_dr -xal.entered_cr
                     -- discount entered amount (replace this with new xla colum names)
         FROM ap_invoice_distributions_all aid,
              ap_invoices_all ai,
              ap_invoice_payments_all aip,
              ap_payment_history_all aph,
              xla_ae_lines    xal
        WHERE aid.invoice_id = ai.invoice_id
          AND aid.invoice_id = aip.invoice_id
--          AND aid.distribution_line_number
          AND aid.invoice_distribution_id = p_trx_line_id
          AND aip.invoice_payment_id = xal.Upg_Tax_Reference_ID3
          AND aid.old_dist_line_number = xal.Upg_Tax_Reference_ID2
          AND xal.accounting_class_code = 'DISCOUNT'
          AND aph.check_id = aip.check_id
          AND nvl(aph.historical_flag, 'N') = 'Y';


CURSOR tax_dist_csr IS
    SELECT sum(aphd.amount), -- discount amount (entered)
           sum(aphd.paid_base_amount) -- discount amount (accounted)
      FROM ap_invoice_distributions_all aid,
           ap_invoices_all ai,
           ap_invoice_payments_all aip,
           ap_payment_hist_dists aphd,
           ap_payment_history_all aph
     WHERE aid.invoice_id = ai.invoice_id
       AND aid.invoice_id = aip.invoice_id
--       AND aid.distribution_line_number
       AND aid.invoice_distribution_id = p_tax_line_id
       AND aip.invoice_payment_id = aphd.invoice_payment_id
       AND aphd.PAY_DIST_LOOKUP_CODE = 'DISCOUNT'
       AND aphd.invoice_distribution_id = aid.invoice_distribution_id
       AND nvl(aph.historical_flag, 'N') = 'N'
       AND aph.check_id = aip.check_id
   UNION
       SELECT xal.entered_dr - xal.entered_cr ,
                     -- discount entered amount (replace this with new xla colum names)
              xal.accounted_dr -xal.entered_cr
                     -- discount entered amount (replace this with new xla colum names)
         FROM ap_invoice_distributions_all aid,
              ap_invoices_all ai,
              ap_invoice_payments_all aip,
              ap_payment_history_all aph,
              xla_ae_lines    xal
        WHERE aid.invoice_id = ai.invoice_id
          AND aid.invoice_id = aip.invoice_id
--          AND aid.distribution_line_number
          AND aid.invoice_distribution_id = p_tax_line_id
          AND aip.invoice_payment_id = xal.Upg_Tax_Reference_ID3
          AND aid.old_dist_line_number = xal.Upg_Tax_Reference_ID2
          AND xal.accounting_class_code = 'DISCOUNT'
          AND aph.check_id = aip.check_id
          AND nvl(aph.historical_flag, 'N') = 'Y';



   l_tax_entered_disc_amt             NUMBER;
   l_tax_acct_disc_amt             NUMBER;
  -- l_tax1_entered_disc_amt             NUMBER;
  -- l_tax1_accounted_disc_amt             NUMBER;
  -- l_tax2_entered_disc_amt            NUMBER;
  -- l_tax2_accounted_disc_amt:= 0;
  -- l_tax3_entered_disc_amt:= 0;
  -- l_tax3_accounted_disc_amt:= 0;
  -- l_tax4_entered_disc_amt:= 0;
  -- l_tax4_accounted_disc_amt:= 0;
   l_0_taxable_entered_disc_amt            NUMBER;
   l_0_taxable_accounted_disc_amt           NUMBER;
   l_taxable_entered_disc_amt           NUMBER;
   l_taxable_acct_disc_amt           NUMBER;
   i                                    BINARY_INTEGER;

 BEGIN

/*   IF PG_DEBUG = 'Y' THEN
   	arp_util_tax.debug('AP_TAX_POPULATE.get_discount_info_ap(+) ');
   	arp_util_tax.debug('P_TRX_ID =   ' || P_TRX_ID);
   	arp_util_tax.debug('P_TAX_ID =   ' || P_TAX_ID);
   	arp_util_tax.debug('P_SUMMARY_LEVEL =   ' || P_SUMMARY_LEVEL);
   	arp_util_tax.debug('P_DISC_DISTRIBUTION_METHOD =  ' || P_DISC_DISTRIBUTION_METHOD);
   	arp_util_tax.debug('P_LIABILITY_POST_LOOKUP_CODE =   ' || P_LIABILITY_POST_LOOKUP_CODE);
   END IF;
*/
  i          := j;
--P_INDEX_TO_GLOBAL_TABLES;
  --l_tax_type := P_SUB_ITF_REC.tax_code_type_code;

  -- get discount tax amount;


   l_tax_entered_disc_amt:= 0;
   l_tax_acct_disc_amt:= 0;
 --  l_tax1_entered_disc_amt:= 0;
--   l_tax1_accounted_disc_amt:= 0;
 --  l_tax2_entered_disc_amt:= 0;
  -- l_tax2_accounted_disc_amt:= 0;
  -- l_tax3_entered_disc_amt:= 0;
  -- l_tax3_accounted_disc_amt:= 0;
  -- l_tax4_entered_disc_amt:= 0;
  -- l_tax4_accounted_disc_amt:= 0;
 l_0_taxable_entered_disc_amt:= 0;
   l_0_taxable_accounted_disc_amt:= 0;
   l_taxable_entered_disc_amt:= 0;
   l_taxable_acct_disc_amt:= 0;


   IF P_DISC_DISTRIBUTION_METHOD = 'EXPENSE' OR
      P_LIABILITY_POST_LOOKUP_CODE IS NOT NULL  THEN

   IF P_SUMMARY_LEVEL = 'TRANSACTION_DISTRIBUTION' THEN


      OPEN taxable_dist_csr;
--(p_trx_line_id);
         FETCH taxable_line_csr INTO l_taxable_entered_disc_amt, l_taxable_acct_disc_amt;

         IF taxable_dist_csr%NOTFOUND THEN
		-- Message
                NULL;
         END IF;  -- tax_discount_cur


      CLOSE taxable_dist_csr;

   ELSIF P_SUMMARY_LEVEL = 'TRANSACTION_LINE' THEN

           OPEN taxable_line_csr;
--(p_trx_line_id);
          FETCH taxable_line_csr INTO l_taxable_entered_disc_amt, l_taxable_acct_disc_amt;

    IF taxable_line_csr%NOTFOUND THEN
	  NULL;
		-- Message
    END IF;  -- tax_discount_cur

    ELSIF P_SUMMARY_LEVEL = 'TRANSACTION' THEN

           OPEN taxable_hdr_csr;
--(p_trx_line_id);
              FETCH taxable_hdr_csr INTO l_taxable_entered_disc_amt, l_taxable_acct_disc_amt;

        IF taxable_hdr_csr%NOTFOUND THEN
    	  NULL;
		-- Message
    END IF;  -- tax_discount_cur

   END IF; --summary level


--   GT_TAXABLE_ENT_DISC_AMT_TBL(i):=   l_taxable_entered_disc_amt;
--   G_TAXABLE_ACCT_DISC_AMT_TBL(i):= l_taxable_acct_disc_amt;

        GT_TAXABLE_DISC_AMT(i)     :=  l_taxable_entered_disc_amt;
         GT_TAXABLE_DISC_AMT_FUNCL_CURR(i)  := l_taxable_acct_disc_amt;

  ELSE      -- P_DISC_DISTRIBUTION_METHOD = 'TAX' AND P_LIABILITY_POST_LOOKUP_CODE IS NULL
           NULL;
         -- 	arp_util_tax.debug('Taxable discount amount are stored in one account in accounting table ...');
  END IF;

   IF P_SUMMARY_LEVEL = 'TRANSACTION_DISTRIBUTION' THEN


      OPEN tax_dist_csr;
--(p_trx_line_id);
         FETCH tax_line_csr INTO l_tax_entered_disc_amt, l_tax_acct_disc_amt;

         IF tax_dist_csr%NOTFOUND THEN
                -- Message
             NULL;
         END IF;  -- tax_discount_cur


      CLOSE tax_dist_csr;

   ELSIF P_SUMMARY_LEVEL = 'TRANSACTION_LINE' THEN

           OPEN tax_line_csr;
--(p_trx_line_id);
          FETCH tax_line_csr INTO l_tax_entered_disc_amt, l_tax_acct_disc_amt;

    IF tax_line_csr%NOTFOUND THEN
       NULL; -- Message
    END IF;  -- tax_discount_cur

    ELSIF P_SUMMARY_LEVEL = 'TRANSACTION' THEN

           OPEN tax_hdr_csr;
--(p_trx_line_id);
              FETCH tax_hdr_csr INTO l_tax_entered_disc_amt, l_tax_acct_disc_amt;

        IF tax_hdr_csr%NOTFOUND THEN
           NULL; -- Message
        END IF;  -- tax_discount_cur

   END IF; --summary level


        GT_TAX_DISC_AMT(i)            := l_tax_entered_disc_amt;
        GT_TAX_DISC_AMT_FUNCL_CURR(i) := l_tax_acct_disc_amt;

 EXCEPTION

  WHEN NO_DATA_FOUND THEN
--      arp_util_tax.debug('Exception No data found exception in GET_DISCOUNT_INFO_AP..'||
--               SQLCODE||' ; '||SQLERRM);
         NULL;

    WHEN OTHERS THEN

        --arp_util_tax.debug('When others Exception in GET_DISCOUNT_INFO_AP..'||
        --       SQLCODE||' ; '||SQLERRM);
      NULL;


 END get_discount_info;

PROCEDURE update_zx_rep_detail_t(
  P_COUNT IN BINARY_INTEGER)
 IS

BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.update_zx_rep_detail_t.BEGIN',
                                      'update_zx_rep_detail_t(+)');
    END IF;

  FORALL  i IN 1 .. p_count
      UPDATE zx_rep_trx_detail_t SET
             REP_CONTEXT_ID            =     G_REP_CONTEXT_ID,
             BILLING_TP_NUMBER         =     GT_BILLING_TP_NUMBER(i),
             BILLING_TP_TAX_REG_NUM    =     GT_BILLING_TP_TAX_REG_NUM(i),
             BILLING_TP_TAXPAYER_ID    =     GT_BILLING_TP_TAXPAYER_ID(i),
             BILLING_TP_SITE_NAME_ALT  =     GT_BILLING_TP_SITE_NAME_ALT(i),
             BILLING_TP_NAME           =     GT_BILLING_TP_NAME(i),
             BILLING_TP_NAME_ALT       =     GT_BILLING_TP_NAME_ALT(i),
             BILLING_TP_SIC_CODE       =     GT_BILLING_TP_SIC_CODE(i),
             BILLING_TP_CITY           =     GT_BILLING_TP_CITY(i),
             BILLING_TP_COUNTY         =     GT_BILLING_TP_COUNTY(i),
             BILLING_TP_STATE          =     GT_BILLING_TP_STATE(i),
             BILLING_TP_PROVINCE       =     GT_BILLING_TP_PROVINCE(i),
             BILLING_TP_ADDRESS1       =     GT_BILLING_TP_ADDRESS1(i),
             BILLING_TP_ADDRESS2       =     GT_BILLING_TP_ADDRESS2(i),
             BILLING_TP_ADDRESS3       =     GT_BILLING_TP_ADDRESS3(i),
             BILLING_TP_ADDRESS_LINES_ALT =  GT_BILLING_TP_ADDR_LINES_ALT(i),
             BILLING_TP_COUNTRY        =     GT_BILLING_TP_COUNTRY(i),
             BILLING_TP_POSTAL_CODE    =     GT_BILLING_TP_POSTAL_CODE(i),
             GDF_PO_VENDOR_SITE_ATT17  =     GT_GDF_PO_VENDOR_SITE_ATT17(i),
             TRX_CLASS_MNG             =     GT_TRX_CLASS_MNG(i),
             TAX_RATE_CODE_REG_TYPE_MNG  =   GT_TAX_RATE_CODE_REG_TYPE_MNG(i),
             TAXABLE_DISC_AMT          =     GT_TAXABLE_DISC_AMT(i),
             TAXABLE_DISC_AMT_FUNCL_CURR =   GT_TAXABLE_DISC_AMT_FUNCL_CURR(i),
             TAX_DISC_AMT              =     GT_TAX_DISC_AMT(i),
             TAX_DISC_AMT_FUNCL_CURR     =   GT_TAX_DISC_AMT_FUNCL_CURR(i)
      WHERE  DETAIL_TAX_LINE_ID = GT_DETAIL_TAX_LINE_ID(i);

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.update_zx_rep_detail_t.END',
                                      'update_zx_rep_detail_t(-)');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.update_zx_rep_detail_t',
                      g_error_buffer);
    END IF;
    g_retcode := 2;

END update_zx_rep_detail_t;

PROCEDURE update_rep_actg_t(p_count IN NUMBER) IS
i number;
BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.UPDATE_REP_ACTG_T.BEGIN',
                                      'ZX_AR_ACTG_POPULATE_PKG: UPDATE_REP_ACTG_T(+)');
    END IF;

FORALL i in 1..p_count
UPDATE zx_rep_actg_ext_t SET
       TRX_ARAP_BALANCING_SEGMENT    =  GT_TRX_ARAP_BALANCING_SEGMENT(i),
       TRX_ARAP_NATURAL_ACCOUNT      =  GT_TRX_ARAP_NATURAL_ACCOUNT(i),
       TRX_TAXABLE_BALANCING_SEGMENT = GT_TRX_TAXABLE_BAL_SEG(i),
       TRX_TAXABLE_NATURAL_ACCOUNT   =  GT_TRX_TAXABLE_NATURAL_ACCOUNT(i),
       TRX_TAX_BALANCING_SEGMENT     =  GT_TRX_TAX_BALANCING_SEGMENT(i),
       TRX_TAX_NATURAL_ACCOUNT       =  GT_TRX_TAX_NATURAL_ACCOUNT(i)
   WHERE DETAIL_TAX_LINE_ID = GT_DETAIL_TAX_LINE_ID(i);

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.UPDATE_REP_ACTG__T.END',
                                      'ZX_AR_ACTG_POPULATE_PKG: UPDATE_REP_ACTG_T(-)');
    END IF;


EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AR_ACTG_POPULATE_PKG.UPDATE_REP_ACTG_T',
                      g_error_buffer);
    END IF;

        G_RETCODE := 2;

END UPDATE_REP_ACTG_T;


PROCEDURE initialize_variables (
          p_count   IN         NUMBER) IS
i number;

BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.initialize_variables.BEGIN',
                                      'initialize_variables(+)');
    END IF;

  FOR i IN 1.. p_count LOOP
/*
      GT_DETAIL_TAX_LINE_ID(i)              :=  NULL;
      GT_APPLICATION_ID(i)                  :=  NULL;
      GT_INTERNAL_ORGANIZATION_ID(i)        :=  NULL;
      GT_TRX_ID(i)                          :=  NULL;
      GT_TRX_LINE_TYPE(i)                   :=  NULL;
      GT_TRX_LINE_CLASS(i)                   :=  NULL;
      GT_SHIP_TO_PARTY_TAX_PROF_ID(i)       :=  NULL;
      GT_SHIP_FROM_PTY_TAX_PROF_ID(i)       :=  NULL;
      GT_BILL_TO_PARTY_TAX_PROF_ID(i)       :=  NULL;
      GT_BILL_FROM_PTY_TAX_PROF_ID(i)       :=  NULL;
      GT_SHIP_TO_SITE_TAX_PROF_ID(i)        :=  NULL;
      GT_BILL_TO_SITE_TAX_PROF_ID(i)        :=  NULL;
      GT_SHIP_FROM_SITE_TAX_PROF_ID(i)      :=  NULL;
      GT_BILL_FROM_SITE_TAX_PROF_ID(i)      :=  NULL;
      GT_BILL_FROM_PARTY_ID(i)              :=  NULL;
      GT_BILL_FROM_PARTY_SITE_ID(i)         :=  NULL;
      GT_HISTORICAL_FLAG(i)                :=  NULL;
      GT_REP_CONTEXT_ID(i)                  :=  NULL;
      GT_TRX_CLASS_MNG(i)                   :=  NULL;
      GT_TAX_RATE_CODE_REG_TYPE_MNG(i)      := NULL;
*/
-- apai      GT_REP_CONTEXT_ID(i)               := NULL;
      GT_BILLING_TP_NUMBER(i)            := NULL;
      GT_BILLING_TP_TAX_REG_NUM(i)       := NULL;
      GT_BILLING_TP_TAXPAYER_ID(i)       := NULL;
      GT_BILLING_TP_SITE_NAME_ALT(i)     := NULL;
      GT_BILLING_TP_NAME(i)              := NULL;
      GT_BILLING_TP_NAME_ALT(i)          := NULL;
      GT_BILLING_TP_SIC_CODE(i)          := NULL;
      GT_BILLING_TP_CITY(i)              := NULL;
      GT_BILLING_TP_COUNTY(i)            := NULL;
      GT_BILLING_TP_STATE(i)             := NULL;
      GT_BILLING_TP_PROVINCE(i)          := NULL;
      GT_BILLING_TP_ADDRESS1(i)          := NULL;
      GT_BILLING_TP_ADDRESS2(i)          := NULL;
      GT_BILLING_TP_ADDRESS3(i)          := NULL;
      GT_BILLING_TP_ADDR_LINES_ALT(i)    := NULL;
      GT_BILLING_TP_COUNTRY(i)           := NULL;
      GT_BILLING_TP_POSTAL_CODE(i)       := NULL;
      GT_GDF_PO_VENDOR_SITE_ATT17(i)     := NULL;
      GT_TRX_CLASS_MNG(i)                := NULL;
      GT_TAX_RATE_CODE_REG_TYPE_MNG(i)   := NULL;
      GT_TAXABLE_DISC_AMT(i)             := NULL;
      GT_TAXABLE_DISC_AMT_FUNCL_CURR(i)  := NULL;
      GT_TAX_DISC_AMT(i)                 := NULL;
      GT_TAX_DISC_AMT_FUNCL_CURR(i)      := NULL;
   END LOOP;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.initialize_variables.END',
                                      'initialize_variables(-)');
    END IF;


EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.initialize_variables',
                      g_error_buffer);
    END IF;
    g_retcode := 2;

END initialize_variables ;


PROCEDURE populate_meaning(
           P_TRL_GLOBAL_VARIABLES_REC  IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE,
           i BINARY_INTEGER)
IS
   l_description      VARCHAR2(240);
   l_meaning          VARCHAR2(80);
BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.populate_meaning.BEGIN',
                                      'populate_meaning(+)');
    END IF;

     IF GT_TRX_LINE_CLASS(i) IS NOT NULL THEN
        lookup_desc_meaning('ZX_TRANSACTION_CLASS_TYPE',
                             GT_TRX_LINE_CLASS(i),
                             l_meaning,
                             l_description);
        GT_TRX_CLASS_MNG(i) := l_meaning;
     END IF;

     IF  P_TRL_GLOBAL_VARIABLES_REC.REGISTER_TYPE IS NOT NULL THEN
         lookup_desc_meaning('ZX_REGISTER_TYPE',
                              P_TRL_GLOBAL_VARIABLES_REC.REGISTER_TYPE,
                             l_meaning,
                             l_description);

         GT_TAX_RATE_CODE_REG_TYPE_MNG(i) := l_meaning;
     END IF;

   IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.populate_meaning.END',
                                      'populate_meaning(-)' ||GT_TAX_RATE_CODE_REG_TYPE_MNG(i));
    END IF;
EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_meaning- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.populate_meaning',
                      g_error_buffer);
    END IF;


END populate_meaning;



PROCEDURE lookup_desc_meaning(p_lookup_type IN  VARCHAR2,
                              P_LOOKUP_CODE IN  VARCHAR2,
                              p_meaning     OUT NOCOPY  VARCHAR2,
                              p_description OUT  NOCOPY VARCHAR2) IS

  CURSOR lookup_cur (c_lookup_type VARCHAR2,
                       c_lookup_code VARCHAR2) IS
    SELECT meaning, description
      FROM fnd_lookups
     WHERE lookup_type = c_lookup_type
       AND lookup_code = c_lookup_code;

   l_tbl_index_lookup      BINARY_INTEGER;
BEGIN

   IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.lookup_desc_meaning.BEGIN',
                                      'lookup_desc_meaning(+)');
    END IF;

     IF p_lookup_type IS NOT NULL AND p_lookup_code IS NOT NULL THEN
    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.lookup_desc_meaning',
                                      'Lookup Type and Lookup code are not null '||p_lookup_type||'-'||P_LOOKUP_CODE);
     END IF;

        l_tbl_index_lookup  := dbms_utility.get_hash_value(p_lookup_type||p_lookup_code, 1,8192);

     IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.lookup_desc_meaning',
                                      'Meaning Alredy existed in the Cache');
     END IF;

        IF g_lookup_info_tbl.EXISTS(l_tbl_index_lookup) THEN

           p_meaning := g_lookup_info_tbl(l_tbl_index_lookup).lookup_meaning;
           p_description := g_lookup_info_tbl(l_tbl_index_lookup).lookup_description;

        ELSE

   IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.lookup_desc_meaning',
                                      'Before Open lookup_cur');
    END IF;

            OPEN lookup_cur (p_lookup_type, p_lookup_code);
           FETCH lookup_cur
            INTO p_meaning,
                 p_description;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.lookup_desc_meaning',
                                      'p_meaning p_description'||p_meaning||' '||p_description);
     END IF;

                g_lookup_info_tbl(l_tbl_index_lookup).lookup_meaning := p_meaning;
                g_lookup_info_tbl(l_tbl_index_lookup).lookup_description := p_description;
          END IF;
     END IF;

     IF lookup_cur%ISOPEN THEN
        CLOSE lookup_cur;
     END IF;
   IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.lookup_desc_meaning.END',
                                      'lookup_desc_meaning(-)');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_AP_ACTG_POPULATE_PKG.lookup_desc_meaning',
                      g_error_buffer);
    END IF;
    g_retcode := 2;

END lookup_desc_meaning;

END ZX_AP_ACTG_POPULATE_PKG;

/
