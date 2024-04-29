--------------------------------------------------------
--  DDL for Package FII_AR_TRAN_DETAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_TRAN_DETAIL" AUTHID CURRENT_USER AS
/* $Header: FIIARDBITDS.pls 120.0.12000000.1 2007/02/23 02:29:18 applrt ship $ */


PROCEDURE get_tran_detail (
        p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
        tran_detail_sql             OUT NOCOPY VARCHAR2,
        tran_detail_output          OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END FII_AR_TRAN_DETAIL;

-- End of package


 

/
