--------------------------------------------------------
--  DDL for Package JE_IT_XML_LISTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JE_IT_XML_LISTING_PKG" 
/*$Header: jeitxlsts.pls 120.1 2007/12/31 11:35:00 spasupun noship $*/
AUTHID CURRENT_USER AS

P_VAT_REPORTING_ENTITY_ID NUMBER;
P_YEAR_OF_DECLARATION NUMBER;
P_REPORT_MODE VARCHAR2(10);
P_PROG_NUM    NUMBER;
P_REPORT_TYPE VARCHAR2(10);

FUNCTION validate_vat_reg_num (p_vat_reg_num VARCHAR2, p_party_type_code VARCHAR2) RETURN VARCHAR2;
FUNCTION validate_taxpayer_id (pv_taxpayer_id VARCHAR2, p_party_type_code VARCHAR2) RETURN VARCHAR2;

FUNCTION beforeReport RETURN BOOLEAN;

END;

/
