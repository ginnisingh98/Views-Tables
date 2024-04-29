--------------------------------------------------------
--  DDL for Package XLA_TP_SUMMARY_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_TP_SUMMARY_RPT_PKG" 
-- $Header: XLA_TPSUMRPT_PS.pls 120.3.12000000.1 2007/10/23 12:57:06 sgudupat noship $
/*===========================================================================+
|  Copyright (c) 2003 Oracle Corporation BelmFont, California, USA           |
|                          ALL rights reserved.                              |
+============================================================================+
| FILENAME                                                                   |
|     XLA_TPSUMRPT_PS.pls                                                    |
|                                                                            |
| PACKAGE NAME                                                               |
|     XLA_TP_SUMMARY_RPT_PKG                                                 |
|                                                                            |
| DESCRIPTION                                                                |
|     Package specification.This provides XML extract for Trading Partner    |
|     Summary Report                                                         |
|                                                                            |
| HISTORY                                                                    |
|     05/06/2007  Rakesh Pulla        Created                                |
|     18/09/2007  Rakesh Pulla        Modified the code AUTHID CURRENT_USER as it has an impact  |
|                                     on the new parameter added             |
|                                     (Third Party type)                     |
|     12/10/2007  Rakesh Pulla        Added the functions min_period         |
|                                                       & max_period         |
|                                                                            |
+===========================================================================*/
AS

  P_RESP_APPLICATION_ID         NUMBER;
  P_LEDGER_ID                   NUMBER;
  P_LEDGER                      VARCHAR2(300);
  P_COA_ID                      NUMBER(15);
  P_JE_SOURCE_NAME              VARCHAR2(240);
  P_PERIOD_FROM                 VARCHAR2(30);
  P_PERIOD_TO                   VARCHAR2(30);
  P_ACCOUNT_DATE_FROM           DATE;
  P_ACCOUNT_DATE_TO             DATE;
  P_THIRD_PARTY_FROM            VARCHAR2(300);
  P_THIRD_PARTY_TO              VARCHAR2(300);
  P_ACCOUNTING_FLEXFIELD_FROM   VARCHAR2(285);
  P_ACCOUNTING_FLEXFIELD_TO     VARCHAR2(285);
  P_PARTY_TYPE                  VARCHAR2(30);
  P_PARTY_TYPE_DUMMY            VARCHAR2(80);
  P_THIRD_PARTY_TYPE            VARCHAR2(80);
  P_THIRD_PARTY_TYPE_DUMMY      VARCHAR2(80);
  P_INCLUDE_SUBS_DETAIL         VARCHAR2(10);
  P_INCLUDE_SUBS_DUMMY          VARCHAR2(15);
  P_PERIOD_START_DATE           DATE;
  P_PERIOD_END_DATE             DATE;
  P_LEDGER_CURRENCY             VARCHAR2(100);
  P_BEG_DATE_RANGE              VARCHAR2(3000);
  P_PER_DATE_RANGE              VARCHAR2(3000);
  P_PERIOD_NUM_FROM             NUMBER;
  P_PERIOD_NUM_TO               NUMBER;

  /* Commented the variables in order to fix the Bug # 6401736  */

  /* To fetch the actual periods which are present in the xla_control_balances table.
  P_AC_PERIOD_FROM              VARCHAR2(30);
  P_AC_PERIOD_TO                VARCHAR2(30); */

  /* Lexical variables used in the query */
  p_party_col                   VARCHAR2(2000);
  p_party_group                 VARCHAR2(2000);
  p_party_tab                   VARCHAR2(2000);
  p_party_join                  VARCHAR2(1000);
  p_party_name_join             VARCHAR2(1000);


	FUNCTION beforeReport RETURN BOOLEAN;
	FUNCTION min_period( p_period_num IN NUMBER) RETURN NUMBER;
	FUNCTION max_period( p_period_num IN NUMBER) RETURN NUMBER;

END XLA_TP_SUMMARY_RPT_PKG;

 

/
