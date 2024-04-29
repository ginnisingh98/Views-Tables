--------------------------------------------------------
--  DDL for Package XLA_MULTIPERIOD_RPRTG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_MULTIPERIOD_RPRTG_PKG" AUTHID CURRENT_USER AS
-- $Header: xlarpmpa.pkh 120.3 2006/03/31 10:45:58 vkasina noship $
/*===========================================================================+
|  Copyright (c) 2003 Oracle Corporation BelmFont, California, USA           |
|                          ALL rights reserved.                              |
+============================================================================+
| FILENAME                                                                   |
|    xlarpmpa.pkh                                                            |
|                                                                            |
| PACKAGE NAME                                                               |
|     xla_multiperiod_rprtg_pkg                                              |
|                                                                            |
| DESCRIPTION                                                                |
|          This package calls XLA_MULTIPERIOD_ACCOUNTING_PKG.complete_       |
|          journal_entries and generates the XML extract for reporting       |
|          multiperiod recognition entries,accrual reversal entries and      |
|          their errors.                                                     |
|                                                                            |
| HISTORY                                                                    |
|     16/08/2005  VS Koushik      Created                                    |
+===========================================================================*/

p_application_id            NUMBER;
p_je_source                 gl_je_sources_tl.user_je_source_name%TYPE;
p_dummy                     VARCHAR2(240);
p_ledger_id                 NUMBER;
p_ledger                    VARCHAR2(30);
p_process_category_code     VARCHAR2(30);
p_process_category_name     VARCHAR2(80);
p_end_date                  DATE;
p_errors_only               VARCHAR2(30);
p_errors_only_flag          VARCHAR2(80);
p_dummy_param_1             VARCHAR2(240);
p_dummy_param_2             VARCHAR2(240);
p_report                    VARCHAR2(30);
p_report_style              VARCHAR2(80);
p_transfer_to_gl            VARCHAR2(30);
p_transfer_to_gl_flag       VARCHAR2(80);
p_dummy_param_3             VARCHAR2(240);
p_post_in_gl                VARCHAR2(30);
p_post_in_gl_flag           VARCHAR2(80);
p_gl_batch_name             VARCHAR2(50);
p_valuation_method_code     VARCHAR2(240);
p_security_int_1            NUMBER;
p_security_int_2            NUMBER;
p_security_int_3            NUMBER;
p_security_char_1           VARCHAR2(240);
p_security_char_2           VARCHAR2(240);
p_security_char_3           VARCHAR2(240);

C_RETURN_CODE               NUMBER;

xah_appl_filter             VARCHAR2(2000);
xae_appl_filter             VARCHAR2(2000);
ent_appl_filter             VARCHAR2(2000);
xal_appl_filter             VARCHAR2(2000);
acct_batch_filter           VARCHAR2(240);
C_SUMMARY_QUERY             VARCHAR2(4000);
C_TRANSFER_QUERY            VARCHAR2(3000);
C_GENERAL_ERRORS_QUERY      VARCHAR2(3000);
C_RECOGNITION_COLS_QUERY    VARCHAR2(8000);
C_RECOGNITION_FROM_QUERY    VARCHAR2(8000);
C_RECOGNITION_WHR_QUERY     VARCHAR2(8000);
C_ACCRUAL_RVRSL_COLS_QUERY  VARCHAR2(8000);
C_ACCRUAL_RVRSL_FROM_QUERY  VARCHAR2(8000);
C_ACCRUAL_RVRSL_WHR_QUERY   VARCHAR2(8000);
C_ERRORS_COLS_QUERY         VARCHAR2(8000);
C_ERRORS_FROM_QUERY         VARCHAR2(8000);
C_ERRORS_WHR_QUERY          VARCHAR2(8000);

p_trx_identifiers           VARCHAR2(32000):= ' ';


FUNCTION  beforeReport  RETURN BOOLEAN;

END xla_multiperiod_rprtg_pkg;
 

/
