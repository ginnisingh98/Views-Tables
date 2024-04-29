--------------------------------------------------------
--  DDL for Package FII_CURRENCY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_CURRENCY_API" AUTHID CURRENT_USER AS
/* $Header: FIICAC1S.pls 120.3 2005/10/30 05:07:43 appldev noship $  */

-- -------------------------------------------------------------------
-- Name: get_display_name
-- Desc: Returns the display name of a currency code in a specific format.
--       Info is cached after initial access
-- Output: Display name of a given currency at the given rate type. e.g. given USD
--         as the currency code and Corporate Rate as the rate type, it returns
--         USD at Corporate Rate
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function get_display_name(currency_code varchar2, rate varchar2) return varchar2;
Function get_prim_curr_name return varchar2;
Function get_sec_curr_name return varchar2;
Function get_annualized_curr_name return varchar2; --enh#3659270

PRAGMA RESTRICT_REFERENCES (get_display_name, WNDS);

end;

 

/
