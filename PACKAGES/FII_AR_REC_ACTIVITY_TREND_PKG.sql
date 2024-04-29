--------------------------------------------------------
--  DDL for Package FII_AR_REC_ACTIVITY_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_REC_ACTIVITY_TREND_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIARDBIRTS.pls 120.0.12000000.1 2007/02/23 02:28:56 applrt ship $ */


PROCEDURE get_rec_activity_trend (
        p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
        open_rec_sql             OUT NOCOPY VARCHAR2,
        open_rec_output          OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

FUNCTION get_label RETURN VARCHAR2;

END FII_AR_REC_ACTIVITY_TREND_PKG;

-- End of package


 

/
