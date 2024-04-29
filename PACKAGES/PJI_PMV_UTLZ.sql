--------------------------------------------------------
--  DDL for Package PJI_PMV_UTLZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_PMV_UTLZ" AUTHID CURRENT_USER AS
-- $Header: PJIRR02S.pls 120.1 2005/06/16 05:15:05 appldev  $

PROCEDURE Get_SQL_PJI_REP_UAP1 (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                             , x_PMV_Sql OUT NOCOPY VARCHAR2
                             , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE Get_SQL_PJI_REP_U1 (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                             , x_PMV_Sql OUT NOCOPY VARCHAR2
                             , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE Get_SQL_PJI_REP_U2 (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                             , x_PMV_Sql OUT NOCOPY VARCHAR2
                             , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE Get_SQL_PJI_REP_U3 (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                             , x_PMV_Sql OUT NOCOPY VARCHAR2
                             , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE Get_SQL_PJI_REP_U4 (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                             , x_PMV_Sql OUT NOCOPY VARCHAR2
                             , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE Get_SQL_PJI_REP_U5 (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                             , x_PMV_Sql OUT NOCOPY VARCHAR2
                             , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE Get_SQL_PJI_REP_U6 (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                             , x_PMV_Sql OUT NOCOPY VARCHAR2
                             , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE Get_SQL_PJI_REP_U7 (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                             , x_PMV_Sql OUT NOCOPY VARCHAR2
                             , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE Get_SQL_PJI_REP_U8 (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                             , x_PMV_Sql OUT NOCOPY VARCHAR2
                             , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


FUNCTION PLSQLDriver_U1 (
   p_operating_unit        IN VARCHAR2 DEFAULT NULL,
   p_organization          IN VARCHAR2,
   p_as_of_date            IN NUMBER,
   p_period_type           IN VARCHAR2,
   p_comparator_type       IN VARCHAR2,
   p_view_by               IN VARCHAR2,
   p_utilization_category  IN VARCHAR2 DEFAULT NULL,
   p_work_type             IN VARCHAR2 DEFAULT NULL,
   p_job_level             IN VARCHAR2 DEFAULT NULL)
RETURN PJI_REP_U1_TBL;

FUNCTION PLSQLDriver_U2 (
   p_operating_unit        IN VARCHAR2 DEFAULT NULL,
   p_organization          IN VARCHAR2,
   p_as_of_date            IN NUMBER,
   p_period_type           IN VARCHAR2,
   p_view_by               IN VARCHAR2
)  RETURN PJI_REP_U2_TBL;

FUNCTION PLSQLDriver_U3 (
   p_operating_unit        IN VARCHAR2 DEFAULT NULL,
   p_organization          IN VARCHAR2,
   p_as_of_date            IN NUMBER,
   p_period_type           IN VARCHAR2,
   p_view_by               IN VARCHAR2,
   p_utilization_category  IN VARCHAR2 DEFAULT NULL,
   p_work_type             IN VARCHAR2 DEFAULT NULL,
   p_job_level             IN VARCHAR2 DEFAULT NULL)
RETURN PJI_REP_U3_TBL;

FUNCTION PLSQLDriver_U4 (
   p_operating_unit        IN VARCHAR2 DEFAULT NULL,
   p_organization          IN VARCHAR2,
   p_as_of_date            IN NUMBER,
   p_period_type           IN VARCHAR2,
   p_view_by               IN VARCHAR2,
   p_utilization_category  IN VARCHAR2 DEFAULT NULL,
   p_work_type             IN VARCHAR2 DEFAULT NULL,
   p_job_level             IN VARCHAR2 DEFAULT NULL,
   p_flag                  IN VARCHAR2 DEFAULT NULL)
RETURN PJI_REP_U4_TBL;


FUNCTION PLSQLDriver_PJI_REP_U6
 (
    p_operating_unit		IN VARCHAR2 DEFAULT NULL
  , p_organization		IN VARCHAR2
  , p_as_of_date		IN NUMBER
  , p_Period_Type 		IN VARCHAR2
  , p_util_categories 		IN VARCHAR2 DEFAULT NULL
  , p_work_type                 IN VARCHAR2 DEFAULT NULL
  , p_job_level 		IN VARCHAR2 DEFAULT NULL
  , p_view_by                   IN VARCHAR2 DEFAULT NULL
  )RETURN PJI_REP_U6_TBL ;


FUNCTION PLSQLDriver_PJI_REP_U7
 (
    p_operating_unit		IN VARCHAR2 DEFAULT NULL
  , p_organization		IN VARCHAR2
  , p_as_of_date		IN NUMBER
  , p_Period_Type 		IN VARCHAR2
  , p_util_categories 		IN VARCHAR2 DEFAULT NULL
  , p_work_type                 IN VARCHAR2 DEFAULT NULL
  , p_job_level 		IN VARCHAR2 DEFAULT NULL
  , p_view_by                   IN VARCHAR2 DEFAULT NULL
  )RETURN PJI_REP_U7_TBL ;


FUNCTION PLSQLDriver_PJI_REP_U8
 (
    p_operating_unit		IN VARCHAR2 DEFAULT NULL
  , p_organization		IN VARCHAR2
  , p_as_of_date		IN NUMBER
  , p_Period_Type 		IN VARCHAR2
  , p_util_categories 		IN VARCHAR2 DEFAULT NULL
  , p_work_type                 IN VARCHAR2 DEFAULT NULL
  , p_job_level 		IN VARCHAR2 DEFAULT NULL
  , p_view_by                   IN VARCHAR2 DEFAULT NULL
  )RETURN PJI_REP_U8_TBL ;


END PJI_PMV_UTLZ;

 

/
