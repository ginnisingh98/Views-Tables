--------------------------------------------------------
--  DDL for Package JG_ZZ_JOURNAL_AP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_JOURNAL_AP_PKG" 
-- $Header: jgzzjournalaps.pls 120.7.12010000.3 2009/04/28 15:27:35 pakumare ship $
 AUTHID CURRENT_USER AS
    P_VAT_REP_ENTITY_ID             NUMBER ;
  --  P_PERIOD                        VARCHAR2(10);
    P_PERIOD                        JG_ZZ_VAT_REP_STATUS.TAX_CALENDAR_PERIOD%TYPE;
	P_PERIOD_TO                     JG_ZZ_VAT_REP_STATUS.TAX_CALENDAR_PERIOD%TYPE; -- Bug8267272
    P_DOCUMENT_SEQUENCE_NAME_FROM   VARCHAR2(100);
    P_DOCUMENT_SEQUENCE_NAME_TO     VARCHAR2(100);
    P_VENDOR_NAME_FROM              VARCHAR2(100);
    P_VENDOR_NAME_TO                VARCHAR2(100);
    P_DETAIL_SUMMARY                VARCHAR2(100);
    P_VAT_REGISTER_ID               NUMBER ;
    P_BALANCING_SEGMENT             VARCHAR2(100);
    P_TAX_TYPE                      VARCHAR2(100);
    P_REGISTER_TYPE                 VARCHAR2(100);
    P_START_INV_SEQUENCE            NUMBER ;
    P_REPORT_NAME                   VARCHAR2(100);
    P_FIRST_PAGE_NUM                NUMBER;
    l_err_msg                       VARCHAR2(5000);
    l_rec_count                     NUMBER;
    p_debug_flag                    VARCHAR2(1) ;
    g_precision                     NUMBER;   --Bug8201935

    FUNCTION beforeReport RETURN BOOLEAN;
    FUNCTION afterReport  RETURN BOOLEAN;
    FUNCTION get_current_date RETURN VARCHAR2;
    FUNCTION get_sequence_number RETURN NUMBER;
    PROCEDURE jebedv08(p_vat_rep_entity_id           IN    NUMBER
                      ,p_period                      IN    VARCHAR2
                      ,p_document_sequence_name_from IN    VARCHAR2
                      ,p_document_sequence_name_to   IN    VARCHAR2
                      ,p_vendor_name_from            IN    VARCHAR2
                      ,p_vendor_name_to              IN    VARCHAR2
                      ,p_detail_summary              IN    VARCHAR2
                      ,x_err_msg                     OUT NOCOPY  VARCHAR2);
    PROCEDURE jeitapsr(p_vat_rep_entity_id   IN    NUMBER
                      ,p_period              IN    VARCHAR2
                      ,p_vat_register_id     IN    VARCHAR2
                      ,x_err_msg             OUT NOCOPY  VARCHAR2);
    PROCEDURE jeitappv(p_vat_rep_entity_id   IN    NUMBER
                      ,p_period              IN    VARCHAR2
                      ,p_vat_register_id     IN    VARCHAR2
                      ,x_err_msg             OUT NOCOPY  VARCHAR2);
    PROCEDURE jeesrvar(p_vat_rep_entity_id   IN    NUMBER
                      ,p_period              IN    VARCHAR2
					  ,p_period_to           IN    VARCHAR2 -- Bug8267272
                      ,p_tax_type            IN    VARCHAR2
                      ,p_balancing_segment   IN    VARCHAR2
                      ,p_start_inv_sequence  IN    VARCHAR2
                      ,x_err_msg             OUT NOCOPY  VARCHAR2);
    PROCEDURE jeesrpvp(p_vat_rep_entity_id   IN    NUMBER
                      ,p_period              IN    VARCHAR2
					  ,p_period_to           IN    VARCHAR2 -- Bug8267272
                      ,p_tax_type            IN    VARCHAR2
                      ,p_register_type       IN    VARCHAR2
                      ,p_balancing_segment   IN    VARCHAR2
                      ,p_start_inv_sequence  IN    VARCHAR2
                      ,x_err_msg             OUT NOCOPY  VARCHAR2);
    PROCEDURE journal_ap(p_vat_rep_entity_id IN    NUMBER
                         ,p_period           IN    VARCHAR2
                         ,x_err_msg          OUT NOCOPY  VARCHAR2);
    FUNCTION lcu_trans_line_tax_taxable_amt (p_trx_id IN NUMBER) RETURN NUMBER;
    FUNCTION lcu_trans_line_tax_amt         (p_trx_id IN NUMBER) RETURN NUMBER;
END jg_zz_journal_ap_pkg;

/
