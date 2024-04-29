--------------------------------------------------------
--  DDL for Package FII_PSI_JE_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_PSI_JE_DTL_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIPSIJEDTLS.pls 120.0 2005/07/04 10:49:53 hpoddar noship $ */

PROCEDURE get_encum_jrnl  (
        p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
        jrnl_dtl_sql            OUT NOCOPY VARCHAR2,
        jrnl_dtl_output         OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_budget_jrnl  (
        p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
        jrnl_dtl_sql            OUT NOCOPY VARCHAR2,
        jrnl_dtl_output         OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END FII_PSI_JE_DTL_PKG;

-- End of package


 

/
