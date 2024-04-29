--------------------------------------------------------
--  DDL for Package XLA_ACCT_ANALYSIS_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_ACCT_ANALYSIS_RPT_PKG" AUTHID CURRENT_USER AS
-- $Header: xlarpaan.pkh 120.12.12010000.5 2010/01/19 09:27:02 rajose ship $
/*===========================================================================+
|  Copyright (c) 2003 Oracle Corporation BelmFont, California, USA           |
|                          ALL rights reserved.                              |
+============================================================================+
| FILENAME                                                                   |
|     xlarpaan.pkh                                                           |
|                                                                            |
| PACKAGE NAME                                                               |
|     xla_acct_analysis_rpt_pkg                                              |
|                                                                            |
| DESCRIPTION                                                                |
|     Package specification.This provides XML extract for Account Analysis   |
|     Report.                                                                |
|                                                                            |
| HISTORY                                                                    |
|     07/20/2005  V. Kumar        Created                                    |
|     12/19/2005  V. Swapna       Modifed the package to use data template   |
|     12/27/2005  S. Swapna       Added code to display TP information.      |
|     06/02/2006  V. Kumar        Added Custom Parameter                     |
|     16-Sep-2008 rajose          bug#7386068                                |
|                                 Added parameter P_INCLUDE_ACCT_WITH_NO_ACT |
|                                 to display accounts havng beginning bal and|
|                                 no activity and p_begin_balance_union_all  |
|                                 to query such records                      |
|     20-Oct-2008 rajose          bug#7489252                                |
|                                 Added parameter P_INC_ACCT_WITH_NO_ACT     |
|                                 to display in Account Analysis Report      |
|     28-DEC-2009 rajose          bug#9002134 to make Acct Analysis Rpt      |
|                                 queryable by source if source is provided  |
|                                 as input                                   |
+===========================================================================*/

--
-- To be used in query as bind variable
--
  P_RESP_APPLICATION_ID           NUMBER;
  P_LEDGER_ID                     NUMBER;
  P_LEDGER                        VARCHAR2(300);
  P_COA_ID                        NUMBER;
  P_LEGAL_ENTITY_ID               NUMBER;
  P_LEGAL_ENTITY                  VARCHAR2(300);
  P_PERIOD_FROM                   VARCHAR2(15);
  P_PERIOD_TO                     VARCHAR2(15);
  P_GL_DATE_FROM                  DATE;
  P_GL_DATE_TO                    DATE;
  P_BALANCE_TYPE_CODE             VARCHAR2(1);
  P_BALANCE_TYPE                  VARCHAR2(300);
  P_DUMMY_BUDGET_VERSION          VARCHAR2(300);
  P_BUDGET_VERSION_ID             NUMBER;
  P_BUDGET_NAME                   VARCHAR2(300);
  P_DUMMY_ENCUMBRANCE_TYPE        VARCHAR2(300);
  P_ENCUMBRANCE_TYPE_ID           NUMBER;
  P_ENCUMBRANCE_TYPE              VARCHAR2(300);
  P_BALANCE_SIDE_CODE             VARCHAR2(300);
  P_BALANCE_SIDE                  VARCHAR2(300);
  P_BALANCE_AMOUNT_FROM           NUMBER;
  P_BALANCE_AMOUNT_TO             NUMBER;
  P_BALANCING_SEGMENT_FROM        VARCHAR2(300);
  P_BALANCING_SEGMENT_TO          VARCHAR2(300);
  P_ACCOUNT_SEGMENT_FROM          VARCHAR2(80);
  P_ACCOUNT_SEGMENT_TO            VARCHAR2(80);
  P_ACCOUNT_FLEXFIELD_FROM        VARCHAR2(780);
  P_ACCOUNT_FLEXFIELD_TO          VARCHAR2(780);
  P_INCLUDE_ZERO_AMOUNT_LINES     VARCHAR2(1);
  P_INCLUDE_ZERO_AMT_LINES        VARCHAR2(20);
  P_INCLUDE_USER_TRX_ID_FLAG      VARCHAR2(1);
  P_INCLUDE_USER_TRX_ID           VARCHAR2(20);
  P_INCLUDE_TAX_DETAILS_FLAG      VARCHAR2(1);
  P_INCLUDE_TAX_DETAILS           VARCHAR2(20);
  P_INCLUDE_LE_INFO_FLAG          VARCHAR2(30);
  P_INCLUDE_LEGAL_ENTITY          VARCHAR2(30);
  P_CUSTOM_PARAMETER_1            VARCHAR2(240);
  P_CUSTOM_PARAMETER_2            VARCHAR2(240);
  P_CUSTOM_PARAMETER_3            VARCHAR2(240);
  P_CUSTOM_PARAMETER_4            VARCHAR2(240);
  P_CUSTOM_PARAMETER_5            VARCHAR2(240);
  P_CUSTOM_PARAMETER_6            VARCHAR2(240);
  P_CUSTOM_PARAMETER_7            VARCHAR2(240);
  P_CUSTOM_PARAMETER_8            VARCHAR2(240);
  P_CUSTOM_PARAMETER_9            VARCHAR2(240);
  P_CUSTOM_PARAMETER_10           VARCHAR2(240);
  P_CUSTOM_PARAMETER_11           VARCHAR2(240);
  P_CUSTOM_PARAMETER_12           VARCHAR2(240);
  P_CUSTOM_PARAMETER_13           VARCHAR2(240);
  P_CUSTOM_PARAMETER_14           VARCHAR2(240);
  P_CUSTOM_PARAMETER_15           VARCHAR2(240);
  P_INCLUDE_STAT_AMOUNT_LINES     VARCHAR2(1);
  P_INCLUDE_STAT_AMT_LINES        VARCHAR2(20);
  P_INCLUDE_ACCT_WITH_NO_ACT      VARCHAR2(1);  --bug#7386068
  P_INC_ACCT_WITH_NO_ACT          VARCHAR2(30); --bug#7489252


  p_party_col                     VARCHAR2(2000):=',NULL,NULL,NULL,NULL,NULL,NULL';
  p_party_tab                     VARCHAR2(2000):='';
  p_party_join                    VARCHAR2(2000):='';
  p_legal_ent_col                 VARCHAR2(2000):='';
  p_legal_ent_from                VARCHAR2(2000):='';
  p_legal_ent_join                VARCHAR2(2000):='';
  p_qualifier_segment             VARCHAR2(4000):='';
  p_seg_desc_from                 VARCHAR2(2000):='';
  p_seg_desc_join                 VARCHAR2(2000):='';
  p_trx_identifiers                VARCHAR2(32000):=',NULL';
  p_sla_other_filter              VARCHAR2(2000):='';
  p_gl_other_filter               VARCHAR2(2000):='';
  p_party_columns                 VARCHAR2(4000):=' ';
  p_ledger_filters                    VARCHAR2(4000):=' ';
--bug#9002134
  p_application_id                  NUMBER;
  p_je_source_name                  VARCHAR2(300);
  p_je_source_period                VARCHAR2(32000) := ' ';
  p_sla_application_id_filter       VARCHAR2(4000):=' ';
  p_gl_application_id_filter        VARCHAR2(4000):=' ';
--bug#9002134


  p_commercial_query                  VARCHAR2(32000);
  p_vat_registration_query                  VARCHAR2(32000);
  p_tax_query                         VARCHAR2(32000); --bug9011171,8762703

  p_begin_balance_union_all        VARCHAR2(32000) := ' '; --bug#7386068

   --Added for bug 7580995
     p_trx_identifiers_1                VARCHAR2(32000):= ' ';
     p_trx_identifiers_2                VARCHAR2(32000):= ' ';
     p_trx_identifiers_3                VARCHAR2(32000):= ' ';
     p_trx_identifiers_4                VARCHAR2(32000):= ' ';
     p_trx_identifiers_5                VARCHAR2(32000):= ' ';


FUNCTION beforeReport RETURN BOOLEAN;


END XLA_ACCT_ANALYSIS_RPT_PKG;

/
