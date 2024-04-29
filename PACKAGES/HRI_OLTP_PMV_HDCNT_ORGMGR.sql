--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_HDCNT_ORGMGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_HDCNT_ORGMGR" AUTHID CURRENT_USER AS
/* $Header: hriophom.pkh 120.1 2005/08/26 07:12:06 rlpatil noship $ */

PROCEDURE GET_KPI_SQL(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql          OUT NOCOPY VARCHAR2,
                      x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_ORG_SQL(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql          OUT NOCOPY VARCHAR2,
                      x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

FUNCTION CALC_PREV_VALUE(p_supervisor_id         NUMBER,
                         p_organization_id       NUMBER,
                         p_effective_start_date  DATE,
                         p_effective_end_date    DATE,
                         p_type                  VARCHAR2 )
RETURN NUMBER ;


FUNCTION     GET_KPI_TOTALS(p_ORGMGR_ID              NUMBER,
                            p_effective_start_date   DATE,
                            p_effective_end_date     DATE,
                            p_type                   VARCHAR2
                            )
RETURN NUMBER ;

FUNCTION GET_KPI_MGR_TOTALS(p_ORGMGR_ID              NUMBER,
                            p_effective_start_date   DATE,
                            p_effective_end_date     DATE,
                            p_type                   VARCHAR2
                            )
RETURN NUMBER ;



END HRI_OLTP_PMV_HDCNT_ORGMGR;


 

/
