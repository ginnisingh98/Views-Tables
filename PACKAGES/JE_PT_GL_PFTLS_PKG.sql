--------------------------------------------------------
--  DDL for Package JE_PT_GL_PFTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JE_PT_GL_PFTLS_PKG" AUTHID CURRENT_USER AS
-- $Header: jeptglps.pls 120.0.12000000.1 2007/10/24 09:50:01 sgudupat noship $
--
-- Parameters defined in the data template
--
P_ACCESS_SET_ID                  NUMBER ;
P_LEDGER_ID                      NUMBER ;
P_LEDGER                         VARCHAR2(300);
P_COA_ID                         NUMBER;
P_NATURAL_ACCOUNT                VARCHAR2(30);
P_BALANCE_SEGMENT                VARCHAR2(25);
P_BAL_SEG_VALUE                  VARCHAR2(25);
P_START_PERIOD                   VARCHAR2(30);
P_END_PERIOD                     VARCHAR2(30);
P_IRC_TAX                        NUMBER;
P_CURR_UNIT                      VARCHAR2(10);
P_CURR_UNIT_VALUE                VARCHAR2(10);
P_CUSTOM_PARAMETER_1             VARCHAR2(20);
P_CUSTOM_PARAMETER_2             VARCHAR2(20);

-- Global Variables
GN_CUR_AMT                       NUMBER(20);
GN_PRE_AMT                       NUMBER(20);
GN_CURR_YEAR                     VARCHAR2(10);
GN_PREV_YEAR                     VARCHAR2(10);
GC_ACCESS_WHERE                  VARCHAR2(1000);
GD_START_DATE                    DATE;
GD_END_DATE                      DATE;
GD_PRIOR_START_DATE              DATE;
GD_PRIOR_END_DATE                DATE;
GN_PRE_TAX_AMT                   NUMBER(20);
GN_CUR_TAX_AMT                   NUMBER(20);
GN_FLEX_VALUE_SET_ID             NUMBER(10);
GC_NATURAL_ACCOUNT               VARCHAR2(30);
GC_BAL_SEG_FILTER                VARCHAR2(120);
GC_DEBUG_VAR                     VARCHAR2(1000);
GN_ITERATION                     NUMBER :=0;

TYPE parent_tab_type IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

 parent_value_rec parent_tab_type;

FUNCTION beforeReport RETURN BOOLEAN;

END JE_PT_GL_PFTLS_PKG;

 

/
