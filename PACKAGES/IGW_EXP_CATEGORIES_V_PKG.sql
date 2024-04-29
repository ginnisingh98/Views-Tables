--------------------------------------------------------
--  DDL for Package IGW_EXP_CATEGORIES_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_EXP_CATEGORIES_V_PKG" AUTHID CURRENT_USER as
--$Header: igwstexs.pls 115.2 2002/03/28 19:14:01 pkm ship    $
 FUNCTION get_description_from_pa (p_expenditure_category  VARCHAR2)
 RETURN  varchar2;

 PRAGMA restrict_references( get_description_from_pa, WNDS );

 FUNCTION get_start_date_active_from_pa (p_expenditure_category  VARCHAR2)
 RETURN  varchar2;

 PRAGMA restrict_references( get_start_date_active_from_pa, WNDS );

 FUNCTION get_end_date_active_from_pa (p_expenditure_category  VARCHAR2)
 RETURN  varchar2;

 PRAGMA restrict_references( get_end_date_active_from_pa, WNDS );


END IGW_EXP_CATEGORIES_V_PKG;

 

/
