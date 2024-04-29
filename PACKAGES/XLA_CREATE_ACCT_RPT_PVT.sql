--------------------------------------------------------
--  DDL for Package XLA_CREATE_ACCT_RPT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_CREATE_ACCT_RPT_PVT" AUTHID CURRENT_USER AS
-- $Header: xlaaprpt.pkh 120.5.12010000.3 2009/02/16 07:10:25 nksurana ship $
/*===========================================================================+
|  Copyright (c) 2003 Oracle Corporation BelmFont, California, USA           |
|                          ALL rights reserved.                              |
+============================================================================+
| FILENAME                                                                   |
|                                                                            |
|                                                                            |
| PACKAGE NAME                                                               |
|     xla_create_acct_rpt_pvt                                                |
|                                                                            |
| DESCRIPTION                                                                |
|     Package specification.This provides XML extract for Create Accounting. |
|                                                                            |
| HISTORY                                                                    |
|     01/27/2006  V. Swapna       Created                                    |
|     02/16/2009  N. K. Surana    Added new parameters to handle more than   |
|                                 50 event classes per application for FSAH. |
+===========================================================================*/



--
-- To be used in query as bind variables
--
        p_conc_request_id              NUMBER;
        p_application_id               NUMBER;
        p_ledger_id                    NUMBER;
        p_process_category_code        VARCHAR2(30);
        p_end_date                     DATE;
        p_create_accounting_flag       VARCHAR2(1);
        p_accounting_mode              VARCHAR2(1);
        p_errors_only_flag             VARCHAR2(1);
        p_report_style                 VARCHAR2(1);
        p_transfer_to_gl_flag          VARCHAR2(1);
        p_post_in_gl_flag              VARCHAR2(1);
        p_gl_batch_name                VARCHAR2(240);
        p_min_precision                NUMBER;
        p_valuation_method_code        VARCHAR2(30);
        p_security_int_1               NUMBER;
        p_security_int_2               NUMBER;
        p_security_int_3               NUMBER;
        p_security_char_1              VARCHAR2(30);
        p_security_char_2              VARCHAR2(30);
        p_security_char_3              VARCHAR2(30);
        p_request_id                   NUMBER;
        p_entity_id                    NUMBER;
        p_source_application_id        NUMBER;
        p_dummy_param_1                VARCHAR2(240);
        p_dummy_param_2                VARCHAR2(240);
        p_dummy_param_3                VARCHAR2(240);
        p_dummy                        VARCHAR2(240);
        p_ledger_name                  VARCHAR2(240);
        p_application_name             VARCHAR2(240);
        p_source_application_name      VARCHAR2(240);
        p_accounting_mode_name         VARCHAR2(240);
        p_process_category_name        VARCHAR2(240);
        p_accounting_report_level      VARCHAR2(80);
        p_create_accounting            VARCHAR2(15);
        p_errors_only                  VARCHAR2(15);
        p_transfer_to_gl               VARCHAR2(15);
        p_post_in_gl                   VARCHAR2(15);
        p_req_id                       NUMBER;
        p_include_zero_amount_lines    VARCHAR2(1);
        p_include_zero_amt_lines       VARCHAR2(15);
        p_zero_amt_filter              VARCHAR2(240) := ' ';
        p_trx_identifiers              VARCHAR2(32000) := ',NULL';
        p_user_id                      NUMBER;
        p_event_filter                 VARCHAR2(240)  := ' ';
        C_ACCT_PROG_RETURN_CODE        NUMBER;
        p_include_user_trx_id_flag     VARCHAR2(1);
        p_include_user_trx_identifiers VARCHAR2(15);
        p_application_query            VARCHAR2(2000);
	p_group_id_str                 VARCHAR2(32000);

        FUNCTION BeforeReport RETURN BOOLEAN  ;
        FUNCTION AfterReport  RETURN BOOLEAN  ;

--Added for bug 7580995
	p_trx_identifiers_1                VARCHAR2(32000):= ' ';
	p_trx_identifiers_2                VARCHAR2(32000):= ' ';
	p_trx_identifiers_3                VARCHAR2(32000):= ' ';
	p_trx_identifiers_4                VARCHAR2(32000):= ' ';
	p_trx_identifiers_5                VARCHAR2(32000):= ' ';

END XLA_CREATE_ACCT_RPT_PVT;

/
