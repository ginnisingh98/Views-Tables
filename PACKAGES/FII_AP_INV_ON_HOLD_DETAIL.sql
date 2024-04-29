--------------------------------------------------------
--  DDL for Package FII_AP_INV_ON_HOLD_DETAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AP_INV_ON_HOLD_DETAIL" AUTHID CURRENT_USER AS
/* $Header: FIIAPD3S.pls 115.1 2003/06/24 19:46:19 djanaswa noship $ */

-- For the Holds Summary report --

PROCEDURE  get_inv_detail (
        p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
        get_inv_detail_sql        OUT NOCOPY VARCHAR2,
        get_inv_detail_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


END fii_ap_inv_on_hold_detail;

 

/
