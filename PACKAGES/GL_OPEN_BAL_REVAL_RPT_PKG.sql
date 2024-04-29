--------------------------------------------------------
--  DDL for Package GL_OPEN_BAL_REVAL_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_OPEN_BAL_REVAL_RPT_PKG" AUTHID CURRENT_USER AS
-- $Header: glxobrvs.pls 120.0.12000000.1 2007/10/23 15:50:31 sgudupat noship $
--*************************************************************************
-- Copyright (c)  2000    Oracle Corporation
-- All rights reserved
--*************************************************************************
--
--
-- PROGRAM NAME
--  glxobrvs.pls
--
-- DESCRIPTION
--  This script creates the package specification of GL_OPEN_BAL_REVAL_RPT_PKG.
--  This package is used for builidng all the  necessary PL/SQL Logic for the
--  report "GL Open Balances Revaluation"
--
-- USAGE
--   To install       How to Install
--   To execute   How to Execute
--
-- PROGRAM LIST         DESCRIPTION
--  beforereport        It is a public function used to intialize global variables
--                                which will be used to build the quries in the Data Template Dynamically
-- get_reval_conversion_rate
--                      It is a public function which takes p_code_combination_id,
--                      p_account and  p_currency as input parameters and will retun
--                      the conversion rate used by the revaluation program in the period
--                      period_to_param
-- get_data_access_set_name
--                      It is public function which returns the data access set name
--                      based on the value of the parameter ACCESS_SET_ID_PARAM
-- get_ledger_name
--                      It is a public function which returns the ledger name
--                      based on the value of the parameter LEDGER_ID_PARAM
-- DEPENDENCIES
--
-- CALLED BY
--   All the public functions are used in the data template GLXOBRVR.xml
--
-- LAST UPDATE DATE   14-MAY-2007
--
-- HISTORY
-- =======
--
-- VERSION DATE        AUTHOR(S)       DESCRIPTION
-- ------- ----------- --------------- ------------------------------------
-- Draft1A 26-FEB-2007 Thirupathi Rao V  Draft Version
--Draft1B 14-May-2007  Thirupathi Rao V  Changed the name of the package as per comments from GL Team
--************************************************************************
-- Parameters in Data Template
LEDGER_ID_PARAM               NUMBER;
LEDGER_NAME_PARAM             VARCHAR2(30);
ACCESS_SET_ID_PARAM           NUMBER;
COA_ID_PARAM                  NUMBER;
PERIOD_FROM_PARAM             VARCHAR2(15);
PERIOD_TO_PARAM               VARCHAR2(15);
CURRENCY_PARAM                VARCHAR2(15);
ACCT_FROM_PARAM               VARCHAR2(300);
ACCT_TO_PARAM                 VARCHAR2(300);
-- Global Variables
gd_start_date                 DATE;
gd_end_date                   DATE;
gc_access_where               VARCHAR2(300);
gc_currency_where             VARCHAR2(300);
FUNCTION beforereport RETURN BOOLEAN;
FUNCTION get_reval_conversion_rate ( p_code_combination_id IN NUMBER
                                    ,p_account             IN VARCHAR2
                                    ,p_currency            IN VARCHAR2) RETURN NUMBER;
FUNCTION get_data_access_set_name RETURN VARCHAR2;
FUNCTION get_ledger_name		  RETURN VARCHAR2;
END GL_OPEN_BAL_REVAL_RPT_PKG;

 

/
