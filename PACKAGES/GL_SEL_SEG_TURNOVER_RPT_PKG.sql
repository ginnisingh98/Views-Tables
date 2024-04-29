--------------------------------------------------------
--  DDL for Package GL_SEL_SEG_TURNOVER_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_SEL_SEG_TURNOVER_RPT_PKG" AUTHID CURRENT_USER AS
-- $Header: glxssegs.pls 120.0.12000000.1 2007/10/23 16:28:29 sgudupat noship $
/*=========================================
Variables to Hold the Parameter Values
=========================================*/
LEDGER_ID_PARAM                 NUMBER;
PERIOD_FROM_PARAM               VARCHAR2(30);
PERIOD_TO_PARAM	                VARCHAR2(30);
ADDITIONAL_SEGMENT_NUM1_PARAM   NUMBER;
ADDITIONAL_SEGMENT_NUM2_PARAM   NUMBER;
ACCT_FROM_PARAM                 VARCHAR2(50);
ACCT_TO_PARAM                   VARCHAR2(50);
BALANCE_TYPE_PARAM              VARCHAR2(30);
BUDGETNAME_ENCUMBRANCETYPE      NUMBER;
LEDGER_CURRENCY_PARAM           VARCHAR2(30);
CURRENCY_TYPE_PARAM             VARCHAR2(30);
ENTERED_CURRENCY_PARAM          VARCHAR2(30);
ACCESS_SET_ID_PARAM             NUMBER;
COA_ID_PARAM                    NUMBER;
PRINT_INTERNAL_DOC_NUM_PARAM    VARCHAR2(30);
PRINT_JRNL_DETAIL_PARAM         VARCHAR2(30);
USER_PARAM_1                    VARCHAR2(30);
USER_PARAM_2                    VARCHAR2(30);
USER_PARAM_3                    VARCHAR2(30);
USER_PARAM_4                    VARCHAR2(30);

/*=========================================
Lexical Variables to obtain dynamic values
=========================================*/

GC_BEGIN_DR_SELECT     VARCHAR2(1000);
GC_BEGIN_CR_SELECT     VARCHAR2(1000);
GC_PERIOD_DR_SELECT    VARCHAR2(1000);
GC_PERIOD_CR_SELECT    VARCHAR2(1000);

GC_BALANCE_WHERE       VARCHAR2(500);
GC_TRANSLATE_WHERE     VARCHAR2(500);
GC_SECURITY_WHERE      VARCHAR2(500);
GC_DAS_BAL_WHERE       VARCHAR2(500);
GC_DAS_JE_WHERE        VARCHAR2(500);
GC_CURRENCY_WHERE      VARCHAR2(500);
GC_NONZERO_WHERE       VARCHAR2(500);
GC_SUBORD_SEG_WHERE    VARCHAR2(100);
GC_RESULTING_CURRENCY  VARCHAR2(10);
GC_PER_EFF_FROM_NUM    NUMBER;
GC_PER_EFF_TO_NUM      NUMBER;
GC_INT_DOC_NUM         VARCHAR2(100);

gc_additional_segment_name1 VARCHAR2(30);
gc_additional_segment_name2 VARCHAR2(30);
gc_data_access_set_name     VARCHAR2(30);

/*=========================================
Public Functions
=========================================*/

FUNCTION beforereport  RETURN BOOLEAN;
FUNCTION int_doc_number(p_je_header_id IN NUMBER
                       ,p_je_line_num  IN NUMBER) RETURN VARCHAR2;

END GL_SEL_SEG_TURNOVER_RPT_PKG;

 

/
