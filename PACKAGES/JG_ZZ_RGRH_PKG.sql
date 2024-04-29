--------------------------------------------------------
--  DDL for Package JG_ZZ_RGRH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_RGRH_PKG" 
-- $Header: jgzzrgrhs.pls 120.2 2006/06/06 09:35:59 samalhot ship $
AUTHID CURRENT_USER AS
 P_REPORT_NAME_LOV varchar2(80);
 P_ADDRESS1 varchar2(100);
 P_ADDRESS2 varchar2(100);
 P_ADDRESS3 varchar2(100);
 P_ADDRESS4 varchar2(100);
 P_VAT_REG varchar2(100);
 P_FISCAL_CODE varchar2(100);
 P_CONC_REQUEST_ID number;
 P_year varchar2(4);
 P_START_PAGE_NUMBER number;
 P_PAGES_REQUIRED number;
 P_TOTAL_PAGES_REQUIRED varchar2(10);
 P_GR_FISCAL_COMPANY_VALUE varchar2(100);
 P_GR_VAT_NUMBER varchar2(100);
 P_GR_ADDRESS varchar2(300);
 P_GR_TAX_OFFICE varchar2(100);
 P_GR_CITY varchar2(100);
 P_GR_POSTAL_CODE varchar2(100);
 P_GR_TAX_AREA varchar2(100);
 P_COUNTRY_CODE varchar2(20);
 P_REPORT_NAME_FREE varchar2(50);
 P_DEBUG_FLAG varchar2(1);
 P_REPORT_NAME varchar2(80);
 P_FISCAL_COMPANY_NAME varchar2(100);
 P_LEGAL_ENTITY_ID number;
 C_GR_TAX_OFFICE varchar2(60);
 C_GR_TAX_AREA varchar2(80);
 C_GR_COMPANY_ACTIVITY  varchar2(150);
 C_TOTAL_PAGES VARCHAR2(30);
 C_COUNTRY_NAME VARCHAR2(100);
 function BEFOREREPORT_006 return boolean  ;
 function AfterReport return boolean  ;
 Function C_GR_TAX_OFFICE_formula return varchar2;
 Function C_GR_COMPANY_ACTIVITY_formula return varchar2;
 Function C_GR_TAX_AREA_formula return varchar2;
 Function C_TOTAL_PAGES_formula return varchar2;
 Function C_COUNTRY_NAME_formula return VARCHAR2;
END JG_ZZ_RGRH_PKG;

 

/
