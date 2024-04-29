--------------------------------------------------------
--  DDL for Package JE_AT_VAT_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JE_AT_VAT_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: jeatutils.pls 120.0 2006/06/01 17:18:49 panaraya noship $ */

P_Ledger_ID number;
P_Currency varchar2(100);
P_Legal_Entity_ID number;
P_Chart_Of_Accounts_ID number;
P_Balancing_Segment varchar2(100);
P_Tax_Registration_Number number;
P_Reporting_Entity_Identifier number;
P_Period_From varchar2(100);
P_Period_To varchar2(100);
P_Tax_Regime_Code varchar2(100);
P_Tax number;
P_Tax_Status varchar2(100);
P_Tax_Jurisdiction varchar2(100);
P_Tax_Type_Code varchar2(100);
P_Tax_Rate_Code varchar2(100);

pwhereclause varchar2(3200);
function G_APFilter(source_name varchar2) return boolean;
function G_ARFilter(source_name varchar2) return boolean;
END JE_AT_VAT_UTIL_PKG;

 

/
