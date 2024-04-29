--------------------------------------------------------
--  DDL for Package XLA_MPA_ACCRUAL_RPRTG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_MPA_ACCRUAL_RPRTG_PKG" AUTHID CURRENT_USER AS
-- $Header: xlarpmpb.pkh 120.1 2006/03/31 10:44:11 vkasina noship $
/*===========================================================================+
|  Copyright (c) 2003 Oracle Corporation BelmFont, California, USA           |
|                          ALL rights reserved.                              |
+============================================================================+
| FILENAME                                                                   |
|    xlarpmpb.pkh                                                            |
|                                                                            |
| PACKAGE NAME                                                               |
|     xla_mpa_accrual_rprtg_pkg                                              |
|                                                                            |
| DESCRIPTION                                                                |
|          This package is called by the Create Accounting program through   |
|          a concurrent request and generates a report if there are mpa      |
|          entries. The report consists of a list of all those mpa,          |
|          recognition, accrual and accrual reversal entries.                |
|                                                                            |
| HISTORY                                                                    |
|     26/08/2005  VS Koushik      Created                                    |
+===========================================================================*/

p_source_application_id     NUMBER;
p_source_application        gl_je_sources_tl.user_je_source_name%TYPE;
p_application_id            NUMBER;
p_je_source                 gl_je_sources_tl.user_je_source_name%TYPE;
p_dummy                     VARCHAR2(240);
p_ledger_id                 NUMBER;
p_ledger                    VARCHAR2(30);
p_process_category_code     VARCHAR2(30);
p_process_category_name     VARCHAR2(80);
p_end_date                  DATE;
p_create_accounting         VARCHAR2(30);
p_create_accounting_flag    VARCHAR2(80);
p_dummy_param_1             VARCHAR2(240);
p_accounting_mode           VARCHAR2(30);
p_dummy_param_2             VARCHAR2(240);
p_errors_only               VARCHAR2(30);
p_errors_only_flag          VARCHAR2(80);
p_dummy_param_3             VARCHAR2(240);
p_report                    VARCHAR2(30);
p_report_style              VARCHAR2(80);
p_transfer_to_gl            VARCHAR2(30);
p_transfer_to_gl_flag       VARCHAR2(80);
p_dummy_param_4             VARCHAR2(240);
p_post_in_gl                VARCHAR2(30);
p_post_in_gl_flag           VARCHAR2(80);
p_gl_batch_name             VARCHAR2(50);
p_accounting_batch_id       NUMBER;

xah_appl_filter             VARCHAR2(2000);
xae_appl_filter             VARCHAR2(2000);
ent_appl_filter             VARCHAR2(2000);
xal_appl_filter             VARCHAR2(2000);
acct_batch_filter           VARCHAR2(240);
C_SUMMARY_QUERY             VARCHAR2(4000);
C_TRANSFER_QUERY            VARCHAR2(4000);
C_GENERAL_ERRORS_QUERY      VARCHAR2(3000);
C_MPA_COLS_QUERY            VARCHAR2(8000);
C_MPA_FROM_QUERY            VARCHAR2(8000);
C_MPA_WHR_QUERY             VARCHAR2(8000);
C_ACCRUAL_RVRSL_COLS_QUERY  VARCHAR2(8000);
C_ACCRUAL_RVRSL_FROM_QUERY  VARCHAR2(8000);
C_ACCRUAL_RVRSL_WHR_QUERY   VARCHAR2(8000);
C_ERRORS_COLS_QUERY         VARCHAR2(8000);
C_ERRORS_FROM_QUERY         VARCHAR2(8000);
C_ERRORS_WHR_QUERY          VARCHAR2(8000);

p_trx_identifiers           VARCHAR2(32000):= ' ';

FUNCTION  beforeReport  RETURN BOOLEAN;

FUNCTION run_report
       (p_source_application_id           IN NUMBER
       ,p_application_id                  IN NUMBER
       ,p_ledger_id                       IN NUMBER
       ,p_process_category                IN VARCHAR2
       ,p_end_date                        IN DATE
       ,p_accounting_flag                 IN VARCHAR2
       ,p_accounting_mode                 IN VARCHAR2
       ,p_errors_only_flag                IN VARCHAR2
       ,p_transfer_flag                   IN VARCHAR2
       ,p_gl_posting_flag                 IN VARCHAR2
       ,p_gl_batch_name                   IN VARCHAR2
       ,p_accounting_batch_id             IN NUMBER) RETURN NUMBER;

END xla_mpa_accrual_rprtg_pkg;
 

/
