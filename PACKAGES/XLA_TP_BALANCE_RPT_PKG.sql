--------------------------------------------------------
--  DDL for Package XLA_TP_BALANCE_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_TP_BALANCE_RPT_PKG" AUTHID CURRENT_USER AS
-- $Header: xlarptpb.pkh 120.13.12010000.3 2009/06/30 13:08:30 nksurana ship $
/*===========================================================================+
|  Copyright (c) 2003 Oracle Corporation BelmFont, California, USA           |
|                          ALL rights reserved.                              |
+============================================================================+
| FILENAME                                                                   |
|     xlarptpb.pkh                                                           |
|                                                                            |
| PACKAGE NAME                                                               |
|     xla_tp_balance_rpt_pkg                                                 |
|                                                                            |
| DESCRIPTION                                                                |
|     Package specification.This provides XML extract for Third Party Balance|
|     Report                                                                 |
|                                                                            |
| HISTORY                                                                    |
|     07/20/2005  V. Kumar        Created                                    |
|     12/27/2005  V.Swapna        Modified the package to use Data template  |
|     04/26/2006  A. Wan          5162044 - add 10 custom_parameters 6-15    |
|                                                                            |
+===========================================================================*/

--
-- To be used in query as bind variable
--
P_RESP_APPLICATION_ID            NUMBER ;
P_LEDGER_ID                      NUMBER ;
P_LEDGER                         VARCHAR2(300);
P_COA_ID                         NUMBER;
P_JE_SOURCE_NAME                 VARCHAR2(240);
P_JE_SOURCE                      VARCHAR2(300);
P_LEGAL_ENTITY_ID                NUMBER;
P_LEGAL_ENTITY                   VARCHAR2(300);
P_PERIOD_FROM                    VARCHAR2(30);
P_PERIOD_TO                      VARCHAR2(30);
P_GL_DATE_FROM                   DATE ;
P_GL_DATE_TO                     DATE ;
P_INCLUDE_DRAFT_ACTIVITY_FLAG    VARCHAR2(1);
P_INCLUDE_DRAFT_ACTIVITY         VARCHAR2(20);
P_BALANCE_SIDE_CODE              VARCHAR2(80);
P_BALANCE_SIDE                   VARCHAR2(80);
P_BALANCE_AMOUNT_FROM            NUMBER;
P_BALANCE_AMOUNT_TO              NUMBER;
P_PARTY_TYPE                     VARCHAR2(30);
P_PARTY_ID                       NUMBER;
P_THIRD_PARTY_NAME               VARCHAR2(300);
P_DUMMY_PARTY                    VARCHAR2(300);
P_PARTY_SITE_ID                  NUMBER;
P_THIRD_PARTY_SITE               VARCHAR2(300);
P_PARTY_NUMBER_FROM              VARCHAR2(30); --Bug 8544794
P_PARTY_NUMBER_TO                VARCHAR2(30); --Bug 8544794
P_BALANCING_SEGMENT_FROM         VARCHAR2(25);
P_BALANCING_SEGMENT_TO           VARCHAR2(25);
P_ACCOUNT_SEGMENT_FROM           VARCHAR2(25);
P_ACCOUNT_SEGMENT_TO             VARCHAR2(25);
P_ACCOUNTING_FLEXFIELD_FROM      VARCHAR2(780);
P_ACCOUNTING_FLEXFIELD_TO        VARCHAR2(780);
P_INCLUDE_ZERO_AMT_LINES_FLAG    VARCHAR2(1);
P_INCLUDE_ZERO_AMOUNT_LINES      VARCHAR2(20);
P_INCLUDE_USER_TRX_ID_FLAG       VARCHAR2(1);
P_INCLUDE_USER_TRX_IDENTIFIERS   VARCHAR2(20);
P_INCLUDE_TAX_DETAILS_FLAG       VARCHAR2(1);
P_INCLUDE_TAX_DETAILS            VARCHAR2(20);
P_INCLUDE_LE_INFO_FLAG           VARCHAR2(30);
P_INCLUDE_LEGAL_ENTITY           VARCHAR2(30);
P_CUSTOM_PARAMETER_1             VARCHAR2(240);
P_CUSTOM_PARAMETER_2             VARCHAR2(240);
P_CUSTOM_PARAMETER_3             VARCHAR2(240);
P_CUSTOM_PARAMETER_4             VARCHAR2(240);
P_CUSTOM_PARAMETER_5             VARCHAR2(240);
P_CUSTOM_PARAMETER_6             VARCHAR2(240);
P_CUSTOM_PARAMETER_7             VARCHAR2(240);
P_CUSTOM_PARAMETER_8             VARCHAR2(240);
P_CUSTOM_PARAMETER_9             VARCHAR2(240);
P_CUSTOM_PARAMETER_10            VARCHAR2(240);
P_CUSTOM_PARAMETER_11            VARCHAR2(240);
P_CUSTOM_PARAMETER_12            VARCHAR2(240);
P_CUSTOM_PARAMETER_13            VARCHAR2(240);
P_CUSTOM_PARAMETER_14            VARCHAR2(240);
P_CUSTOM_PARAMETER_15            VARCHAR2(240);

P_LANG                           VARCHAR2(80);
P_START_PERIOD_NUM               NUMBER;
P_END_PERIOD_NUM                 NUMBER;
P_START_DATE                     DATE;
P_END_DATE                       DATE;

p_party_col                      VARCHAR2(2000):=' ';
p_party_tab                      VARCHAR2(1000):=' ';
p_party_join                     VARCHAR2(1000):=' ';
p_legal_ent_col                  VARCHAR2(2000):=' ';
p_legal_ent_from                 VARCHAR2(1000):=' ';
p_legal_ent_join                 VARCHAR2(1000):=' ';
p_qualifier_segment              VARCHAR2(4000):=' ';
p_seg_desc_from                  VARCHAR2(1000):=' ';
p_seg_desc_join                  VARCHAR2(1000):=' ';
p_other_filter                   VARCHAR2(2000):=' ';
p_commercial_query               VARCHAR2(32000);
p_vat_registration_query         VARCHAR2(32000);
p_trx_identifiers                VARCHAR2(32000):=',NULL';

  --Added for bug 7580995
   p_trx_identifiers_1                VARCHAR2(32000):= ' ';
   p_trx_identifiers_2                VARCHAR2(32000):= ' ';
   p_trx_identifiers_3                VARCHAR2(32000):= ' ';
   p_trx_identifiers_4                VARCHAR2(32000):= ' ';
   p_trx_identifiers_5                VARCHAR2(32000):= ' ';



FUNCTION beforeReport RETURN BOOLEAN;

END XLA_TP_BALANCE_RPT_PKG;

/
