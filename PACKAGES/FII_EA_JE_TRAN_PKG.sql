--------------------------------------------------------
--  DDL for Package FII_EA_JE_TRAN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_EA_JE_TRAN_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIEAJ1S.pls 120.1 2005/06/10 13:36:22 sajgeo noship $ */

g_fin_type	VARCHAR2(10);

PROCEDURE get_je_tran  (
        p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
        jrnl_dtl_sql            OUT NOCOPY VARCHAR2,
        jrnl_dtl_output         OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_je_line_tran  (
        p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
        jrnl_dtl_sql            OUT NOCOPY VARCHAR2,
        jrnl_dtl_output         OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
END FII_EA_JE_TRAN_PKG;

-- End of package


 

/
