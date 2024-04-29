--------------------------------------------------------
--  DDL for Package AP_OPEN_BAL_REV_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_OPEN_BAL_REV_RPT_PKG" 
-- $Header: APOBRRPS.pls 120.4 2008/01/25 11:22:04 sgudupat noship $
   -- ****************************************************************************************
   -- Copyright (c)  2000  Oracle Corporation    Product Development
   -- All rights reserved
   -- ****************************************************************************************
   --
   -- PROGRAM NAME
   -- APOBRRPS.pls
   --
   -- DESCRIPTION
   --  This script creates the package specification of AP_OPEN_BAL_REV_RPT_PKG.
   --  This package AUTHID CURRENT_USER is used to generate AP Open Balances Revaluation Report.
   --
   -- USAGE
   --   To install        How to Install
   --   To execute        How to Execute
   --
   -- DEPENDENCIES
   --   None.
   --
   --  beforereport     It is a public function used to intialize global variables
   --                   which will be used to build the quries in the Data Template Dynamically
   --
   --
   -- exch_rate_calc    It is a public function which returns exchange rate, by taking P_AS_OF_DATE,
   --                   p_exchange_rate_type,gc_func_currency , and currency as parameter
   --
   --
   -- amtduefilter      It is a public function which returns boolean value
   --                   which will be used to fetch the data in Data Template Dynamically
   --
   --
   -- LAST UPDATE DATE   25-JAN-2008
   --   Date the program has been modified for the last time
   --
   -- HISTORY
   -- =======
   --
   -- VERSION DATE        AUTHOR(S)         DESCRIPTION
   -- ------- ----------- ---------------   ------------------------------------
   -- 1.0    21-FEB-2007 Praveen Gollu      Creation
   -- 1.1    25-JAN-2008 Sandeep G          Fix for Bug #6773558
   --****************************************************************************************
   /*=========================================

Variables to Hold the Parameter Values

=========================================*/
AS
   p_as_of_date             DATE;
   p_exchange_rate_type     VARCHAR2 (30);
   p_currency               VARCHAR2 (15);
   p_exchange_rate          VARCHAR2 (15);
   p_include_domestic_inv   VARCHAR2 (1);
   p_supplier               VARCHAR2 (240);
   p_org_id                 NUMBER;
/*=========================================

Global Variables

=========================================*/
   gc_func_currency         VARCHAR2 (15);
   gc_ledger_id             VARCHAR2 (30);
   gc_include_dom_inv       VARCHAR2 (500);
   gc_supplier              VARCHAR2 (100);
   gc_currency              VARCHAR2 (100);
   gc_ou_where              VARCHAR2 (30);
   gc_supplier_name         VARCHAR2 (100);
   gc_operating_name        VARCHAR2 (100);

/*=========================================

Public Functions

=========================================*/
   FUNCTION beforereport
      RETURN BOOLEAN;

   FUNCTION exch_rate_calc (currency IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION amtduefilter (p_amt_due IN NUMBER)
      RETURN BOOLEAN;

   FUNCTION amtduereval (
      func_curr_amt   IN   NUMBER,
      exch_rate       IN   NUMBER,
      tran_curr       IN   VARCHAR
   )
      RETURN NUMBER;

   FUNCTION vat_calc_amt (
      prepay_amt_app   IN   NUMBER,
      tax_amt          IN   NUMBER,
      inv_amt          IN   NUMBER
   )
      RETURN NUMBER;
END ap_open_bal_rev_rpt_pkg;

/
