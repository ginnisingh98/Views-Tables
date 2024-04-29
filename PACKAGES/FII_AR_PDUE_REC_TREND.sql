--------------------------------------------------------
--  DDL for Package FII_AR_PDUE_REC_TREND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_PDUE_REC_TREND" AUTHID CURRENT_USER AS
/* $Header: FIIARDBIPTS.pls 120.0.12000000.1 2007/02/23 02:28:33 applrt ship $ */


PROCEDURE get_pdue_rec_trend (
        p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
        open_rec_sql             OUT NOCOPY VARCHAR2,
        open_rec_output          OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END FII_AR_PDUE_REC_TREND;

-- End of package


 

/
