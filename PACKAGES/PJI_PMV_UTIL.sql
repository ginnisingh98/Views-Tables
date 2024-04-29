--------------------------------------------------------
--  DDL for Package PJI_PMV_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_PMV_UTIL" AUTHID CURRENT_USER AS
-- $Header: PJIRX04S.pls 120.10 2007/11/16 15:07:06 vvjoshi ship $

FUNCTION Get_Labor_Unit
RETURN VARCHAR2;

FUNCTION Get_Projects ( p_person_id    IN  NUMBER
                       ,p_exp_org_id   IN  NUMBER
                       ,p_date         IN  DATE)
RETURN VARCHAR2;


FUNCTION Get_Available_From (p_person_id    IN  NUMBER
                            ,p_exp_org_id   IN  NUMBER
                            ,p_from_date    IN  NUMBER
                            ,p_as_of_date   IN  NUMBER
                            ,p_threshold    IN  NUMBER)
RETURN VARCHAR2;

FUNCTION Get_Next_Asgmt_Date (p_person_id    IN  NUMBER
                             ,p_exp_org_id   IN  NUMBER
                             ,p_to_date      IN  NUMBER
                             ,p_as_of_date   IN  NUMBER
                             ,p_threshold    IN  NUMBER)
RETURN VARCHAR2;

-- Table added by V Gautam
TYPE   Measure_Label_Code_Tbl IS   TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE   Measure_Label_Tbl      IS   TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;

-- Function Added by V Gautam
FUNCTION GetTimeLevelLabel( p_page_parameter_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL
                            , p_Label_Code         VARCHAR2    DEFAULT NULL
                            , p_Bit_Mode           VARCHAR2    DEFAULT '1')
RETURN VARCHAR2;

FUNCTION GetPriorLabel( p_page_parameter_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL)
RETURN VARCHAR2;

-- Procedure added by adabdull
PROCEDURE Redirect_RA2_RA5 (p_date           IN VARCHAR2,
                            p_week           IN VARCHAR2,
                            p_organization   IN VARCHAR2,
                            p_operating_unit IN VARCHAR2,
                            p_threshold      IN VARCHAR2
);

PROCEDURE Redirect_RA1_RA4 (p_organization   IN VARCHAR2,
                            p_operating_unit IN VARCHAR2 DEFAULT NULL,
                            p_threshold      IN VARCHAR2,
                            p_period_type    IN VARCHAR2,
                            p_start_time     IN VARCHAR2
);

PROCEDURE Redirect_RA4_RA5 (p_week           IN VARCHAR2,
                            p_organization   IN VARCHAR2,
                            p_operating_unit IN VARCHAR2,
                            p_threshold      IN VARCHAR2
);

FUNCTION PJI_ORGANIZATION_LOV RETURN PJI_ORGANIZATION_LIST_TBL;

PROCEDURE Redirect_RA1_RA5 (p_organization   IN VARCHAR2,
                            p_operating_unit IN VARCHAR2 DEFAULT NULL,
                            p_threshold      IN VARCHAR2,
                            p_period_type    IN VARCHAR2,
                            p_start_time     IN VARCHAR2,
                            p_end_time       IN VARCHAR2
);

PROCEDURE SEED_PJI_STATS;

FUNCTION GET_JOB_LEVEL ( p_person_id  NUMBER,
                         p_as_of_date DATE )
RETURN NUMBER;


FUNCTION RA2_RA5_URL  (p_date           IN NUMBER,
                       p_week           IN VARCHAR2,
                       p_organization   IN VARCHAR2,
                       p_operating_unit IN VARCHAR2,
                       p_threshold      IN NUMBER)

RETURN VARCHAR;


FUNCTION RA4_RA5_URL  (p_week           IN VARCHAR2,
		       p_organization   IN VARCHAR2,
                       p_operating_unit IN VARCHAR2,
                       p_threshold      IN NUMBER,
                       p_period_type    IN VARCHAR2)

RETURN VARCHAR;

FUNCTION Drill_To_Proj_Perf_URL( PROJECT_ID              IN NUMBER
                                ,p_Currency_Record_Type  IN NUMBER
                                ,p_As_of_Date            IN NUMBER
                                ,p_Period_Type    IN VARCHAR2)
RETURN VARCHAR2;

PROCEDURE INIT;

PROCEDURE hide_parameter (
                        p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                        hide    OUT NOCOPY VARCHAR2);

FUNCTION PJI_ORGANIZATION_EXISTS(p_org_id IN NUMBER) RETURN NUMBER;

PROCEDURE get_top_org_details
(x_top_org_id           OUT  nocopy    per_security_profiles.organization_id%TYPE,
 x_top_org_name         OUT  nocopy    hr_all_organization_units_tl.name%TYPE,
 x_user_assmt_flag      OUT  nocopy   VARCHAR2,
 x_insert_top_org_flag  OUT  nocopy   VARCHAR2 ); -- Added for bug#6623113

END PJI_PMV_UTIL;

/
