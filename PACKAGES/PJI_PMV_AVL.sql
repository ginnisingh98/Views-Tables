--------------------------------------------------------
--  DDL for Package PJI_PMV_AVL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_PMV_AVL" AUTHID CURRENT_USER AS
-- $Header: PJIRR01S.pls 120.1 2005/05/31 08:18:27 appldev  $

PROCEDURE Get_SQL_PJI_REP_RA1 (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                             , x_PMV_Sql OUT NOCOPY  VARCHAR2
                             , x_PMV_Output OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL);
PROCEDURE Get_SQL_PJI_REP_RA2 (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                             , x_PMV_Sql OUT NOCOPY  VARCHAR2
                             , x_PMV_Output OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL);
PROCEDURE Get_SQL_PJI_REP_RA3 (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                             , x_PMV_Sql OUT NOCOPY  VARCHAR2
                             , x_PMV_Output OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL);
PROCEDURE Get_SQL_PJI_REP_RA4 (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                             , x_PMV_Sql OUT NOCOPY  VARCHAR2
                             , x_PMV_Output OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL);
PROCEDURE Get_SQL_PJI_REP_RA5 (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                             , x_PMV_Sql OUT NOCOPY  VARCHAR2
                             , x_PMV_Output OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL);


FUNCTION PLSQLDriver_RA1 (
   p_operating_unit        IN VARCHAR2 DEFAULT NULL,
   p_organization          IN VARCHAR2,
   p_threshold             IN NUMBER,
   p_As_Of_Date            IN NUMBER,
   p_period_type           IN VARCHAR2,
   p_view_by               IN VARCHAR2
)  RETURN PJI_REP_RA1_TBL;

FUNCTION PLSQLDriver_RA2 (
   p_operating_unit        IN VARCHAR2 DEFAULT NULL,
   p_organization          IN VARCHAR2,
   p_threshold             IN NUMBER,
   p_as_of_date            IN NUMBER,
   p_view_by               IN VARCHAR2
)  RETURN PJI_REP_RA2_TBL;

FUNCTION PLSQLDriver_RA3 (
   p_operating_unit        IN VARCHAR2 DEFAULT NULL,
   p_organization          IN VARCHAR2,
   p_threshold             IN NUMBER,
   p_avl_type              IN VARCHAR2,
   p_as_of_date            IN NUMBER,
   p_period_type           IN VARCHAR2,
   p_view_by               IN VARCHAR2
)  RETURN PJI_REP_RA3_TBL;

FUNCTION PLSQLDriver_RA4 (
   p_operating_unit        IN VARCHAR2 DEFAULT NULL,
   p_organization          IN VARCHAR2,
   p_threshold             IN NUMBER,
   p_as_of_date            IN NUMBER,
   p_period_type           IN VARCHAR2,
   p_view_by               IN VARCHAR2
)  RETURN PJI_REP_RA4_TBL;

FUNCTION PLSQLDriver_RA5 (
   p_operating_unit        IN VARCHAR2 DEFAULT NULL,
   p_organization          IN VARCHAR2,
   p_threshold             IN NUMBER,
   p_avl_days              IN NUMBER,
   p_as_of_date            IN NUMBER,
   p_period_type           IN VARCHAR2,
   p_view_by               IN VARCHAR2
)  RETURN PJI_REP_RA5_TBL;

END PJI_PMV_AVL;


 

/
