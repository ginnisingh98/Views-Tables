--------------------------------------------------------
--  DDL for Package FII_AP_INV_ACTIVITY_DETAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AP_INV_ACTIVITY_DETAIL" AUTHID CURRENT_USER AS
/* $Header: FIIAPD4S.pls 115.1 2003/06/24 21:36:26 djanaswa noship $ */

-- To show the as-of-date in the report title --
FUNCTION get_report_title(
	p_page_parameter_tbl    BIS_PMV_PAGE_PARAMETER_TBL) RETURN VARCHAR2;

-- For the Invoice Activity Detail report --
PROCEDURE get_inv_activity_detail (
        p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
        inv_dtl_sql             OUT NOCOPY VARCHAR2,
        inv_dtl_output          OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END FII_AP_INV_ACTIVITY_DETAIL;

-- End of package


 

/
