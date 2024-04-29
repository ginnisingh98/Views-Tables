--------------------------------------------------------
--  DDL for Package JG_ZZ_SHARED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_SHARED_PKG" AUTHID CURRENT_USER AS
/* $Header: jgzzssas.pls 120.6.12010000.2 2009/10/30 10:22:12 pakumare ship $ */

Type t_char_tbl is TABLE OF VARCHAR2(10) index by VARCHAR2(100);
p_country_tbl t_char_tbl ;
p_product_tbl t_char_tbl;
p_appl_tbl    t_char_tbl;

-----------------------------------------------------------------
-- FUNCTION Is_Globalization_enabled
-- Use this function to verify whether the globalization feature is enabled for
-- the given country.
-----------------------------------------------------------------
FUNCTION IS_GLOBALIZATION_ENABLED (p_country_code IN VARCHAR2) RETURN VARCHAR2;

-----------------------------------------------------------------
-- FUNCTION Country
-- Use this function instead of FND_PROFILE.VALUE/GET to retrieve the
-- value of country code
-----------------------------------------------------------------
FUNCTION GET_COUNTRY RETURN VARCHAR2;
-----------------------------------------------------------------
FUNCTION GET_COUNTRY (p_org_id     IN NUMBER,
                      p_ledger_id  IN NUMBER DEFAULT NULL,
                      p_inv_org_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2;

-----------------------------------------------------------------
-- FUNCTION Product
-- Use this function instead of FND_PROFILE.VALUE/GET to retrieve the
-- value of product code
-----------------------------------------------------------------
FUNCTION GET_PRODUCT RETURN VARCHAR2;
-----------------------------------------------------------------
FUNCTION GET_PRODUCT (p_org_id     IN NUMBER,
                      p_ledger_id  IN NUMBER DEFAULT NULL,
                      p_inv_org_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2;

-----------------------------------------------------------------
-- FUNCTION Application
-- Use this function instead of FND_PROFILE.VALUE/GET to retrieve the
-- value of application short name
-----------------------------------------------------------------
FUNCTION GET_APPLICATION RETURN VARCHAR2;
-----------------------------------------------------------------
FUNCTION GET_APPLICATION (p_curr_form_name IN VARCHAR2) RETURN VARCHAR2;

END JG_ZZ_SHARED_PKG;

/
