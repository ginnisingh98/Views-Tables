--------------------------------------------------------
--  DDL for Package XLA_TB_AP_REPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_TB_AP_REPORT_PVT" AUTHID CURRENT_USER AS
/* $Header: xlatbapt.pkh 120.3.12010000.4 2009/12/07 06:52:13 vgopiset noship $ */

--+=====================================================================+
--|                                                                     |
--|                                                                     |
--| Global Variables  referenced in XLAAPRPT.xml                        |
--|                                                                     |
--|                                                                     |
--+=====================================================================+

--======================================================================+
--                                                                      |
-- Report Lexical Parameters                                            |
--                                                                      |
--======================================================================+
P_SQL_STATEMENT             VARCHAR2(32000);
p_app_sql_statement         VARCHAR2(32000);

--======================================================================+
--                                                                      |
-- Report Input Parameters                                              |
--                                                                      |
--======================================================================+
p_journal_source            VARCHAR2(80);
p_definition_code           VARCHAR2(30);
p_start_date                DATE;
p_as_of_date                DATE;
p_third_party_id            VARCHAR2(30);
p_show_trx_detail_flag      VARCHAR2(1);
p_incl_write_off_flag       VARCHAR2(1);
p_coa_id                    NUMBER(15);
p_account_from              VARCHAR2(240);
p_account_to                VARCHAR2(240);
p_acct_balance              VARCHAR2(30);
p_security_flag             VARCHAR2(30);
p_custom_param_1            VARCHAR2(80);
p_custom_param_2            VARCHAR2(80);
p_custom_param_3            VARCHAR2(80);
p_valuation_method          xla_transaction_entities.valuation_method%TYPE;
p_security_id_int_1         xla_transaction_entities.security_id_int_1%TYPE;
p_security_id_char_1        xla_transaction_entities.security_id_char_1%TYPE;

--======================================================================+
--                                                                      |
-- Displayed Parameter Values                                           |
--                                                                      |
--======================================================================+
p_journal_source_dsp        VARCHAR2(80);
p_report_definition_dsp     VARCHAR2(80);
p_third_party_name          VARCHAR2(360);
p_show_trx_detail_dsp       VARCHAR2(80);
p_incl_write_off_dsp        VARCHAR2(80);
p_acct_balance_dsp          VARCHAR2(80);

P_INCLUDE_SLA_MANUALS_UNPOSTED  VARCHAR2(1);
P_INC_SLA_MANUALS_UNPOSTED      VARCHAR2(30); --bug#7489252

/* parameters added for bug#8773522 */
P_SUMMARY_SQL_STATEMENT         VARCHAR2(32000);
P_REPORT_STYLE              	VARCHAR2(80);
P_REPORT         		VARCHAR2(30);
P_REPORT_MODE_DSP               VARCHAR2(80);
/* end for  bug#8773522 */


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| BeforeReport                                                          |
|                                                                       |
| Logic for Before Report Trigger                                       |
|                                                                       |
+======================================================================*/
FUNCTION before_report
RETURN BOOLEAN;

END xla_tb_ap_report_pvt;

/
