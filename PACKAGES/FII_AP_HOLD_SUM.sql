--------------------------------------------------------
--  DDL for Package FII_AP_HOLD_SUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AP_HOLD_SUM" AUTHID CURRENT_USER AS
/* $Header: FIIAPS3S.pls 115.1 2003/06/24 19:54:39 djanaswa noship $ */

-- For the Holds Summary report --

PROCEDURE  get_hold_sum (
        p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
        get_hold_sum_sql        OUT NOCOPY VARCHAR2,
        get_hold_sum_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


PROCEDURE  get_hold_discount_sum (
        p_page_parameter_tbl              IN  BIS_PMV_PAGE_PARAMETER_TBL,
        get_hold_discount_sum_sql        OUT NOCOPY VARCHAR2,
        get_hold_discount_sum_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


PROCEDURE get_hold_cat_sum
     ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       get_hold_cat_sum_sql out NOCOPY VARCHAR2,
       get_hold_cat_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_hold_type_sum
     ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       get_hold_type_sum_sql out NOCOPY VARCHAR2,
       get_hold_type_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


PROCEDURE get_hold_trend (
   p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
   get_hold_trend_sql        OUT NOCOPY VARCHAR2,
   get_hold_trend_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


END fii_ap_hold_sum;

 

/
