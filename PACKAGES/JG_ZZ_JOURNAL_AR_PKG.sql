--------------------------------------------------------
--  DDL for Package JG_ZZ_JOURNAL_AR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_JOURNAL_AR_PKG" 
/*  $Header: jgzzjournalars.pls 120.7.12010000.3 2009/12/29 09:45:03 vspuli ship $ */
AUTHID CURRENT_USER AS
  P_VAT_REP_ENTITY_ID            NUMBER;
--  P_PERIOD                       VARCHAR2(10);
  P_PERIOD                       JG_ZZ_VAT_REP_STATUS.TAX_CALENDAR_PERIOD%TYPE;
  P_PERIOD_TO                    JG_ZZ_VAT_REP_STATUS.TAX_CALENDAR_PERIOD%TYPE; -- Bug8267272
  P_DOCUMENT_SEQUENCE_NAME_FROM  NUMBER;
  P_DOCUMENT_SEQUENCE_NAME_TO    NUMBER;
  P_CUSTOMER_NAME_FROM           VARCHAR2(360);
  P_CUSTOMER_NAME_TO             VARCHAR2(360);
  P_DETAIL_SUMMARY               VARCHAR2(10);
  P_TAX_TYPE                     VARCHAR2(100);
  P_TAX_REGISTER_TYPE            VARCHAR2(100);
  P_SEQUENCE                     VARCHAR2(10);
  P_VAT_REGISTER_ID              NUMBER;
  P_REPORT_NAME                  VARCHAR2(10);
  P_BALANCING_SEGMENT            VARCHAR2(100);
  P_CHART_OF_ACCOUNT_ID	         NUMBER;
  P_FIRST_PAGE_NUM	         NUMBER;
  l_err_msg                      VARCHAR2(5000);

  FUNCTION beforeReport RETURN BOOLEAN;
  FUNCTION get_sequence_number RETURN NUMBER;
  PROCEDURE jebedv07(p_vat_rep_entity_id            IN   NUMBER
                     ,p_period                      IN   VARCHAR2
                     ,p_document_sequence_name_from IN   NUMBER
                     ,p_document_sequence_name_to   IN   NUMBER
                     ,p_customer_name_from          IN   VARCHAR2
                     ,p_customer_name_to            IN   VARCHAR2
                     ,p_detail_summary              IN   VARCHAR2
                     ,x_err_msg                     OUT  NOCOPY VARCHAR2);
  PROCEDURE jeitarsv(p_vat_rep_entity_id   IN    NUMBER
                     ,p_period             IN    VARCHAR2
                     ,p_vat_register_id    IN    NUMBER
                     ,x_err_msg            OUT   NOCOPY VARCHAR2);
  PROCEDURE jeitrdvr(p_vat_rep_entity_id   IN    NUMBER
                     ,p_period             IN    VARCHAR2
                     ,p_vat_register_id    IN    NUMBER
                     ,x_err_msg            OUT   NOCOPY VARCHAR2);
  PROCEDURE jeesrrvr(p_vat_rep_entity_id   IN    NUMBER
                     ,p_period             IN    VARCHAR2
					 ,p_period_to          IN    VARCHAR2 -- Bug8267272 Start
                     ,p_tax_type           IN    VARCHAR2
                     ,p_tax_register_type  IN    VARCHAR2
                     ,p_sequence           IN    VARCHAR2
                     ,x_err_msg            OUT   NOCOPY VARCHAR2);

  g_jeitrdvr_prel_alert_1 VARCHAR2(500) := 'The register has selected one or more transactions with dates earlier than '
                                  || 'the last committed through-date of this register ';
  g_jeitrdvr_prel_alert_2 VARCHAR2(500) := '. Please review those transactions before the final run to verify that they are '
                                || 'reported properly on the current register.';
  g_jeitarsv_prel_alert_1 VARCHAR2(500) := 'The register has selected one or more transactions with dates earlier than '
                                || 'the last committed through-date of this register ';
  g_jeitarsv_prel_alert_2 VARCHAR2(500) := '. Please review those transactions before the final run to verify that they are '
                          || 'reported properly on the current register.';

END JG_ZZ_JOURNAL_AR_PKG;

/
