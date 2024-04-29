--------------------------------------------------------
--  DDL for Package AR_OBALREV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_OBALREV_PKG" AUTHID CURRENT_USER AS
-- $Header: AROBRRPS.pls 120.7 2007/12/27 11:19:41 sgudupat noship $
-- ****************************************************************************************
-- Copyright (c)  2000  Oracle Solution Services (India)     Product Development
-- All rights reserved
-- ****************************************************************************************
--
-- PROGRAM NAME
-- AROBRRPS.pls
--
-- DESCRIPTION
--  This script creates the package specification of ar_obalrev_pkg.
--  This package is used to generate AR Open balance Revaluation Report for Slovakia.
--
-- USAGE
--   To install            How to Install
--   To execute         How to Execute
--
--FUNCTION                                                 DESCRIPTION
--  beforereport        It is a public function used to intialize global variables
--                                which will be used to build the queries in the Data Template Dynamically
--
--
-- exch_rate_calc    It is a public function which returns exchange rate, by taking P_AS_OF_DATE,
--                                p_exchange_rate_type,gc_func_currency , and currency as parameter
--
--
-- amtduefilter         It is a public function which returns boolean value
--    which will be used to fetch the data in Data Template Dynamically
--
-- DEPENDENCIES
--   None.
--
--
-- LAST UPDATE DATE   16-MAR-2007
--   Date the program has been modified for the last time
--
-- HISTORY
-- =======
--
-- VERSION   DATE                      AUTHOR(S)                 DESCRIPTION
--     -------      -----------                 -------------------           ---------------------------
--       1.0    11-MAR-2007          Mallikarjun Gupta         Creation
--        1.1    24-Dec-2007          Ravi Kiran G                   Modified to pick CM details
--****************************************************************************************


--******************************************************
--Variables to Hold the Parameter Values
--******************************************************
P_ORG_ID                     NUMBER(10);
P_AS_OF_DATE                 VARCHAR2(30);
P_EXCHANGE_RATE_TYPE         VARCHAR2(150);
P_CURRENCY                   VARCHAR2(150);
P_DUMMY                      VARCHAR2(15);
P_EXCHANGE_RATE              VARCHAR2(20);
P_INCL_DOMESTIC_INV          VARCHAR2(15);
P_CUSTOMER                   VARCHAR2(30);

--*******************************************************
--Constants to obtain dynamic values
--*******************************************************

gd_date_to1                   DATE;
gd_date_to                  VARCHAR2(30);
gc_ledger_id                 VARCHAR2(30);
gc_trx_date_where            VARCHAR2(300);
gc_trx_date_where1           VARCHAR2(300);
gc_exchange_rate_type        VARCHAR2(30);
gc_func_currency             VARCHAR2(15);
gc_currency_where            VARCHAR2(300);
gc_incl_domestic_inv_where   VARCHAR2(300);
gc_customer_where            VARCHAR2(300);
gc_ou_where                  VARCHAR2(300);
gc_currency_where1           VARCHAR2(300);
gc_incl_domestic_inv_where1  VARCHAR2(300);
gc_customer_where1           VARCHAR2(300);
gc_ou_where1                 VARCHAR2(300);
gc_customer_name             VARCHAR2(30);
gc_ou_name                   VARCHAR2(300);
var2                         VARCHAR2(100) :=0;

--*******************************************************
--Public Functions
--*******************************************************

FUNCTION beforereport RETURN BOOLEAN;
FUNCTION get_rate(p_currency IN VARCHAR2) RETURN NUMBER;
FUNCTION amtduefilter(p_amt_due  IN NUMBER) RETURN BOOLEAN;
FUNCTION test(inv_num VARCHAR2 , amount NUMBER) RETURN NUMBER;


END ar_obalrev_pkg;

/
