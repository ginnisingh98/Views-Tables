--------------------------------------------------------
--  DDL for Package JAI_AR_TCS_REP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AR_TCS_REP_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_tcs_repo_pkg.pls 120.1.12010000.2 2010/03/31 12:05:20 jmeena ship $ */

/***************************************************************************************************
-- #
-- # Change History -


1.  01/02/2007   CSahoo for bug#5631784. File Version 120.0

 Forward Porting of 11i BUG#4742259 (TAX COLLECTION AT SOURCE IN RECEIVABLES)

2. ssumaith - bug# 6109941 - the tcs fin year was being retreived incorrectly. This has been corrected in the
cursor get_tcs_fin_year

*******************************************************************************************************/

  PROCEDURE ar_accounting                 (  p_ract                     IN             RA_CUSTOMER_TRX_ALL%ROWTYPE       DEFAULT NULL                     ,
                                             p_ractl                    IN             RA_CUSTOMER_TRX_LINES_ALL%ROWTYPE DEFAULT NULL                     ,
                                             p_process_flag             OUT NOCOPY     VARCHAR2                                                           ,
                                             p_process_message          OUT NOCOPY     VARCHAR2
                                          );

  PROCEDURE wsh_interim_accounting        (  p_delivery_id              IN             JAI_OM_WSH_LINES_ALL.DELIVERY_ID%TYPE                            ,
                                             p_delivery_detail_id       IN             JAI_OM_WSH_LINES_ALL.DELIVERY_DETAIL_ID%TYPE                    ,
                                             p_order_header_id          IN             JAI_OM_WSH_LINES_ALL.ORDER_HEADER_ID%TYPE                        ,
                                             p_organization_id          IN             JAI_OM_WSH_LINES_ALL.ORGANIZATION_ID%TYPE                        ,
                                             p_location_id              IN             JAI_OM_WSH_LINES_ALL.LOCATION_ID%TYPE                            ,
                                             p_currency_code            IN             VARCHAR2                                                           ,
                                             p_process_flag             OUT NOCOPY     VARCHAR2                                                           ,
                                             p_process_message          OUT NOCOPY     VARCHAR2
                                          );
  PROCEDURE validate_sales_order         (  p_ooh                       IN             OE_ORDER_HEADERS_ALL%ROWTYPE                                       ,
                                            p_process_flag              OUT NOCOPY     VARCHAR2                                                           ,
                                            p_process_message           OUT NOCOPY     VARCHAR2
                                         );
  PROCEDURE validate_invoice             (  p_ract                      IN             RA_CUSTOMER_TRX_ALL%ROWTYPE                                        ,
                                            p_document_type             OUT NOCOPY     VARCHAR2                                                           ,
                                            p_process_flag              OUT NOCOPY     VARCHAR2                                                           ,
                                            p_process_message           OUT NOCOPY     VARCHAR2
                                         );

  PROCEDURE  validate_app_unapp          (  p_araa                      IN              AR_RECEIVABLE_APPLICATIONS_ALL%ROWTYPE                            ,
                                            p_document_type OUT NOCOPY VARCHAR2                                                                           ,
                                            p_item_classification       OUT NOCOPY      JAI_RGM_REFS_ALL.ITEM_CLASSIFICATION%TYPE                         ,
                                            p_process_flag              OUT NOCOPY      VARCHAR2                                                          ,
                                            p_process_message           OUT NOCOPY      VARCHAR2
                                         );

   PROCEDURE validate_receipts           (  p_acra                      IN              AR_CASH_RECEIPTS_ALL%ROWTYPE                                      ,
                                            p_document_type             IN              VARCHAR2                                                          ,
                                            p_process_flag              OUT NOCOPY      VARCHAR2                                                          ,
                                            p_process_message           OUT NOCOPY      VARCHAR2
                                         );

  PROCEDURE process_invoices             (  p_ract                      IN              RA_CUSTOMER_TRX_ALL%ROWTYPE                                       ,
                                            p_document_type             IN              VARCHAR2                                                          ,
                                            p_process_flag              OUT NOCOPY      VARCHAR2                                                          ,
                                            p_process_message           OUT NOCOPY      VARCHAR2
                                         );
  PROCEDURE  process_receipts            (  p_acra                       IN              AR_CASH_RECEIPTS_ALL%ROWTYPE                                     ,
                                            p_document_type              IN              VARCHAR2                                                         ,
                                            p_process_flag               OUT NOCOPY      VARCHAR2                                                         ,
                                            p_process_message            OUT NOCOPY      VARCHAR2
                                         );

  PROCEDURE process_applications         (  p_araa                      IN              AR_RECEIVABLE_APPLICATIONS_ALL%ROWTYPE                            ,
                                            p_document_type             IN              VARCHAR2                                                          ,
                                            p_item_classification       IN              JAI_RGM_REFS_ALL.ITEM_CLASSIFICATION%TYPE                         ,
                                            p_process_flag              OUT NOCOPY      VARCHAR2                                                          ,
                                            p_process_message           OUT NOCOPY      VARCHAR2
                                         );


  PROCEDURE process_unapp_rcpt_rev       (  p_araa                      IN              AR_RECEIVABLE_APPLICATIONS_ALL%ROWTYPE          DEFAULT NULL      ,
                                            p_acra                      IN              AR_CASH_RECEIPTS_ALL%ROWTYPE                    DEFAULT NULL      ,
                                            p_document_type             IN              VARCHAR2                                                          ,
                                            p_process_flag              OUT NOCOPY      VARCHAR2                                                          ,
                                            p_process_message           OUT NOCOPY      VARCHAR2
                                         );

  PROCEDURE insert_repository_references (  p_regime_id                 IN              JAI_RGM_DEFINITIONS.REGIME_ID%TYPE                      DEFAULT NULL      ,
                                            p_transaction_id            IN              JAI_RGM_REFS_ALL.TRANSACTION_ID%TYPE                              ,
                                            p_source_ref_document_id    IN              JAI_RGM_REFS_ALL.SOURCE_REF_DOCUMENT_ID%TYPE    DEFAULT NULL      ,
                                            p_source_ref_document_type  IN              JAI_RGM_REFS_ALL.SOURCE_REF_DOCUMENT_TYPE%TYPE                    ,
                                            p_app_from_document_id      IN              JAI_RGM_REFS_ALL.APP_FROM_DOCUMENT_ID%TYPE      DEFAULT NULL      ,
                                            p_app_from_document_type    IN              JAI_RGM_REFS_ALL.APP_FROM_DOCUMENT_TYPE%TYPE    DEFAULT NULL      ,
                                            p_app_to_document_id        IN              JAI_RGM_REFS_ALL.APP_TO_DOCUMENT_ID%TYPE        DEFAULT NULL      ,
                                            p_app_to_document_type      IN              JAI_RGM_REFS_ALL.APP_TO_DOCUMENT_TYPE%TYPE      DEFAULT NULL      ,
                                            p_parent_transaction_id     IN              JAI_RGM_REFS_ALL.parent_transaction_id%TYPE     DEFAULT NULL      ,
                                            p_org_tan_no                IN              JAI_RGM_REFS_ALL.ORG_TAN_NO%TYPE                DEFAULT NULL      ,
                                            p_document_id               IN              NUMBER                                                            ,
                                            p_document_type             IN              VARCHAR2                                                          ,
                                            p_document_line_id          IN              NUMBER                                                            ,
                                            p_document_date             IN              DATE                                                              ,
                                            p_table_name                IN              VARCHAR2                                                          ,
                                            p_line_amount               IN              NUMBER                                                            ,
                                            p_document_amount           IN              NUMBER                                                            ,
                                            p_org_id                    IN              NUMBER                                                            ,
                                            p_organization_id           IN              NUMBER                                                            ,
                                            p_party_id                  IN              NUMBER                                                            ,
                                            p_party_site_id             IN              NUMBER                                                            ,
                                            p_item_classification       IN              VARCHAR2                                                          ,
                                            p_trx_ref_id                OUT NOCOPY      JAI_RGM_REFS_ALL.TRX_REF_ID%TYPE                                  ,
                                            p_process_flag              OUT NOCOPY      VARCHAR2                                                          ,
                                            p_process_message           OUT NOCOPY      VARCHAR2
                                         );

  PROCEDURE insert_repository_taxes      (  p_trx_ref_id                                JAI_RGM_REFS_ALL.TRX_REF_ID%TYPE                                  ,
                                            p_tax_id                                    JAI_RGM_TAXES.TAX_ID%TYPE                                         ,
                                            p_tax_type                                  JAI_RGM_TAXES.TAX_TYPE%TYPE                                       ,
                                            p_tax_rate                                  JAI_RGM_TAXES.TAX_RATE%TYPE                                       ,
                                            p_tax_amount                                JAI_RGM_TAXES.TAX_AMT%TYPE                                        ,
                                            p_func_tax_amount                           JAI_RGM_TAXES.FUNC_TAX_AMT%TYPE                                   ,
                                            p_tax_modified_by                           JAI_RGM_TAXES.TAX_MODIFIED_BY%TYPE              DEFAULT NULL      ,
                                            p_currency_code                             JAI_RGM_TAXES.CURRENCY_CODE%TYPE                                  ,
                                            p_process_flag        OUT NOCOPY            VARCHAR2                                                          ,
                                            p_process_message     OUT NOCOPY            VARCHAR2
                                         );

  PROCEDURE copy_taxes_from_source       (  p_source_document_type    IN                JAI_RGM_REFS_ALL.SOURCE_DOCUMENT_TYPE%TYPE                        ,
                                            p_source_document_id      IN                JAI_RGM_REFS_ALL.SOURCE_DOCUMENT_ID%TYPE                          ,
                                            p_source_document_line_id IN                JAI_RGM_REFS_ALL.SOURCE_DOCUMENT_LINE_ID%TYPE   DEFAULT NULL      ,
                                            p_apportion_factor        IN                NUMBER                                          DEFAULT NULL      ,
                                            p_trx_ref_id              IN                JAI_RGM_REFS_ALL.TRX_REF_ID%TYPE                                  ,
                                            p_process_flag            OUT NOCOPY        VARCHAR2                                                          ,
                                            p_process_message         OUT NOCOPY        VARCHAR2
                                         );

  PROCEDURE copy_references              ( p_parent_transaction_id   IN                 JAI_RGM_REFS_ALL.PARENT_TRANSACTION_ID%TYPE     DEFAULT NULL      ,
                                           p_new_document_id         IN                 JAI_RGM_REFS_ALL.SOURCE_DOCUMENT_ID%TYPE                          ,
                                           p_new_document_type       IN                 JAI_RGM_REFS_ALL.SOURCE_DOCUMENT_TYPE%TYPE                        ,
                                           p_new_document_date       IN                 DATE                                                              ,
                                           p_apportion_factor        IN                 NUMBER                                          DEFAULT 1         ,
                                           p_process_flag            OUT NOCOPY         VARCHAR2                                                          ,
                                           p_process_message         OUT NOCOPY         VARCHAR2
                                         );

  PROCEDURE update_item_gen_docs        (  p_trx_number             IN                  RA_CUSTOMER_TRX_ALL.TRX_NUMBER%TYPE                               ,
                                           p_customer_trx_id        IN                  RA_CUSTOMER_TRX_ALL.CUSTOMER_TRX_ID%TYPE                          ,
                                           p_complete_flag          IN                  RA_CUSTOMER_TRX_ALL.COMPLETE_FLAG%TYPE                            ,
                                           p_org_id                 IN                  RA_CUSTOMER_TRX_ALL.ORG_ID%TYPE                                   ,
                                           p_process_flag           OUT NOCOPY          VARCHAR2                                                          ,
                                           p_process_message        OUT NOCOPY          VARCHAR2
                                        );
  PROCEDURE generate_document            ( p_rgm_ref                 IN                 JAI_RGM_REFS_ALL%ROWTYPE                                          ,
                                           p_total_tax_amt           IN                 NUMBER                                                            ,
                                           p_process_flag            OUT NOCOPY         VARCHAR2                                                          ,
                                           p_process_message         OUT NOCOPY         VARCHAR2
                                        );

  PROCEDURE  process_transactions       ( p_event                   IN                  VARCHAR2                                                          ,
                                          p_document_type           IN                  VARCHAR2                                DEFAULT NULL              ,
                                          p_ooh                     IN                  OE_ORDER_HEADERS_ALL%ROWTYPE            DEFAULT NULL              ,
                                          p_ract                    IN                  RA_CUSTOMER_TRX_ALL%ROWTYPE             DEFAULT NULL              ,
                                          p_acra                    IN                  AR_CASH_RECEIPTS_ALL%ROWTYPE            DEFAULT NULL              ,
                                          p_araa                    IN                  AR_RECEIVABLE_APPLICATIONS_ALL%ROWTYPE  DEFAULT NULL              ,
                                          p_process_flag            OUT NOCOPY          VARCHAR2                                                          ,
                                          p_process_message         OUT NOCOPY          VARCHAR2
                                        );

  PROCEDURE update_pan_for_tcs          ( p_return_code             OUT NOCOPY          VARCHAR2                                                          ,
                                          p_errbuf                  OUT NOCOPY          VARCHAR2                                                          ,
                                          p_party_id                IN                  JAI_RGM_REFS_ALL.PARTY_ID%TYPE                                    ,
                                          p_old_pan_no              IN                  JAI_CMN_CUS_ADDRESSES.PAN_NO%TYPE                              ,
                                          p_new_pan_no              IN                  JAI_CMN_CUS_ADDRESSES.PAN_NO%TYPE

                                        );


 /*
  | cursor modified by ssumaith for the bug 6109941
  | the fin_year value was being incorrectly coded.
  | The basic reason was was the join bwtween the hr_operating_units
  | and jai_ap_tds_years. Hence retreiving the value from the jai_ap_tds_years
  | only
 */

  CURSOR get_tcs_fin_year (  cp_org_id    NUMBER  ,
                             cp_trx_date  DATE
                          )
  IS
  SELECT
         fin_year
  FROM
         JAI_AP_TDS_YEARS  jtyi
  WHERE
         jtyi.legal_entity_id  = cp_org_id
  AND    trunc(cp_trx_date)           BETWEEN  trunc(jtyi.start_date) and trunc(nvl(jtyi.end_date,sysdate)); --Added trunc by JMEENA for bug#9538920

  CURSOR c_get_rgm_attribute (   cp_regime_code           JAI_RGM_DEFINITIONS.REGIME_CODE%TYPE               ,
                                 cp_attribute_code        JAI_RGM_REGISTRATIONS.ATTRIBUTE_CODE%TYPE          ,
                                 cp_organization_id       JAI_RGM_PARTIES.ORGANIZATION_ID%TYPE
                               )
  IS
  SELECT
         regime_id                   ,
         attribute_value org_tan_no
  FROM
         JAI_RGM_ORG_REGNS_V rgm_attr_v
  WHERE
         rgm_attr_v.regime_code         =   cp_regime_code
  AND    rgm_attr_v.attribute_code      =   cp_attribute_code
  AND    rgm_attr_v.organization_id     =   cp_organization_id;

END jai_ar_tcs_rep_pkg;

/
