--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_LBRCST_ORGMGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_LBRCST_ORGMGR" AUTHID CURRENT_USER AS
/* $Header: hrirplom.pkh 120.1 2005/08/24 07:19:17 rlpatil noship $ */



PROCEDURE GET_ORG_SQL(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql          OUT NOCOPY VARCHAR2,
                      x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_KPI_SQL(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql          OUT NOCOPY VARCHAR2,
                      x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

FUNCTION CALC_PREV_VALUE_ORG(p_ORGMGR_ID              NUMBER,
                             p_organization_id        NUMBER,
                             p_effective_start_date   DATE,
                             p_effective_end_date     DATE,
                             p_type                   VARCHAR2)
RETURN NUMBER;

FUNCTION CALC_PREV_VALUE_POS(p_ORGMGR_ID              NUMBER,
                             p_organization_id        NUMBER,
                             p_effective_start_date   DATE,
                             p_effective_end_date     DATE,
                             p_position_id            NUMBER )
RETURN NUMBER ;
PROCEDURE GET_POS_SQL(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql          OUT NOCOPY VARCHAR2,
                      x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_POS_DTL_SQL(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql          OUT NOCOPY VARCHAR2,
                          x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

FUNCTION CALC_PREV_VALUE_ELE(p_ORGMGR_ID             NUMBER,
                             p_organization_id       NUMBER,
                             p_position_id           NUMBER,
                             p_effective_start_date  DATE,
                             p_effective_end_date    DATE,
                             p_element_type_id       NUMBER)
RETURN NUMBER ;

PROCEDURE GET_ELE_SQL(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql          OUT NOCOPY VARCHAR2,
                      x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

FUNCTION CALC_PREV_VALUE_FSC(p_ORGMGR_ID                   NUMBER,
                             p_organization_id             NUMBER,
                             p_position_id                 NUMBER,
                             p_effective_start_date        DATE,
                             p_effective_end_date          DATE,
                             p_element_type_id             NUMBER,
                             p_cost_allocation_keyflex_id  NUMBER)
RETURN NUMBER ;
PROCEDURE GET_FSC_SQL(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql          OUT NOCOPY VARCHAR2,
                      x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

FUNCTION GET_KPI_TOTALS(p_ORGMGR_ID              NUMBER,
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

END HRI_OLTP_PMV_LBRCST_ORGMGR;


 

/
