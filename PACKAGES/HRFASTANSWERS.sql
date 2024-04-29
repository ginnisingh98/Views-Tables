--------------------------------------------------------
--  DDL for Package HRFASTANSWERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRFASTANSWERS" AUTHID CURRENT_USER AS
/* $Header: hrfstans.pkh 120.0 2005/05/29 06:59:25 appldev noship $ */

G_REGION_SEGMENT	varchar2(100);

-- Exceptions raised when a report is run with the fast formula either
-- not existing, or existing and not being compiled.
-- mjandrew - 28-JUN-2000 - Bug 1323212 and Bug 976335
FF_Not_Compiled		Exception;
FF_Not_Exist		Exception;


TYPE LeavingReasonsType is table of Varchar2(30)
  index by Binary_Integer;

FUNCTION GetBudgetValue
  ( p_budget_metric_formula_id	IN NUMBER
  , p_assignment_id		          IN NUMBER
  , p_effective_date	          IN DATE
  , p_session_date		          IN DATE )
RETURN NUMBER;

FUNCTION GetBudgetValue
  ( p_budget_metric		          IN VARCHAR2
  , p_assignment_id		          IN NUMBER
  , p_session_date		          IN DATE		default sysdate )
RETURN NUMBER;

FUNCTION GetBudgetValue
  ( p_budget_metric_formula_id  IN NUMBER
  , p_budget_metric		          IN VARCHAR2
  , p_assignment_id		          IN NUMBER
  , p_effective_date	          IN DATE
  , p_session_date		          IN DATE )
RETURN NUMBER;

FUNCTION GetUtilHours(
 p_formula_id                   IN NUMBER
,p_assignment_id                IN NUMBER
,p_effective_date               IN DATE
,p_session_date                 IN DATE
) RETURN NUMBER;

FUNCTION Get_Hours_Worked(
 p_assign_id                    IN NUMBER
,p_earned_date                  IN DATE
,p_multiple                     IN NUMBER
) RETURN NUMBER;

PROCEDURE GetAssignmentCategory(
 p_org_param_id     		IN	NUMBER
,p_assignment_id		IN 	NUMBER
,p_period_start_date		IN	DATE
,p_period_end_date		IN 	DATE
,p_top_org                      IN      NUMBER
,p_movement_type		IN 	VARCHAR2
,p_assignment_category		OUT NOCOPY	VARCHAR2
,p_leaving_reason               OUT NOCOPY 	VARCHAR2
,p_service_band			OUT NOCOPY	VARCHAR2
);
pragma restrict_references( GetAssignmentCategory, WNPS, WNDS );

FUNCTION GetAssignmentCategory(
 p_org_param_id     		IN NUMBER
,p_assignment_id		IN NUMBER
,p_period_start_date		IN DATE
,p_period_end_date		IN DATE
,p_top_org                      IN NUMBER
,p_movement_type		IN VARCHAR2
) RETURN VARCHAR2;
pragma restrict_references( GetAssignmentCategory, WNPS, WNDS );

FUNCTION GetAssignmentCategory
  ( p_assignment_id     IN NUMBER
  , p_period_start_date IN DATE
  , p_period_end_date   IN DATE
  , p_top_org           IN NUMBER
  , p_movement_type     IN VARCHAR2 )
RETURN VARCHAR2;
pragma restrict_references( GetAssignmentCategory, WNPS, WNDS );

FUNCTION GetLeavingReason(
 p_org_param_id     		IN NUMBER
,p_assignment_id		IN NUMBER
,p_period_start_date		IN DATE
,p_period_end_date		IN DATE
,p_top_org                      IN NUMBER
,p_movement_type		IN VARCHAR2
) RETURN VARCHAR2;
pragma restrict_references( GetLeavingReason, WNPS, WNDS );

FUNCTION GetLeavingReasonMeaning(
 p_org_param_id     		IN NUMBER
,p_assignment_id		IN NUMBER
,p_period_start_date		IN DATE
,p_period_end_date		IN DATE
,p_top_org                      IN NUMBER
,p_movement_type		IN VARCHAR2
) RETURN VARCHAR2;
--pragma restrict_references( GetLeavingReasonMeaning, WNPS, WNDS );

FUNCTION Get_Service_Band_Name(
 p_org_param_id     		IN NUMBER
,p_assignment_id		IN NUMBER
,p_period_start_date		IN DATE
,p_period_end_date		IN DATE
,p_top_org                      IN NUMBER
,p_movement_type		IN VARCHAR2
) RETURN VARCHAR2;
--
-- 4365287 Comment the pragma as its not required and causes
-- compilation issues with changed FND code
--
--pragma restrict_references( Get_Service_Band_Name, WNPS, WNDS );

FUNCTION Get_Service_Band_Order(
 p_org_param_id     		IN NUMBER
,p_assignment_id		IN NUMBER
,p_period_start_date		IN DATE
,p_period_end_date		IN DATE
,p_top_org                      IN NUMBER
,p_movement_type		IN VARCHAR2
) RETURN NUMBER;
pragma restrict_references( Get_Service_Band_Order, WNPS, WNDS );

procedure LoadOrgHierarchy
  ( p_organization_id        IN   Number
  , p_org_struct_version_id  IN   Number );

procedure LoadOrgHierarchy
  ( p_organization_id        IN   Number );

procedure LoadOrgHierarchy
  ( p_organization_id        IN   Number
  , p_org_struct_version_id  IN   Number
  , p_organization_process   IN   Varchar2
  , p_org_list               OUT NOCOPY  Varchar2 );

function OrgInHierarchy
  ( p_organization_id  Number )
return Number;
pragma restrict_references (OrgInHierarchy, WNPS, WNDS);
--
function OrgInHierarchy
  ( p_organization_id_group  Number
  , p_organization_id_child  Number )
return Number;
pragma restrict_references (OrgInHierarchy, WNPS, WNDS);
--
FUNCTION GetOrgStructElement RETURN NUMBER;
--pragma restrict_references( GetOrgStructElement, WNPS, WNDS );
--
FUNCTION GetOrgStructVersion RETURN NUMBER;
--pragma restrict_references( GetOrgStructVersion, WNPS, WNDS );
--
PROCEDURE Initialize(p_user_id 			IN NUMBER
                    ,p_resp_id 			IN NUMBER
                    ,p_resp_appl_id 		IN NUMBER
                    ,p_business_group_id 	OUT NOCOPY NUMBER
                    ,p_org_structure_version_id OUT NOCOPY NUMBER
                    ,p_sec_group_id             IN NUMBER  default 0);

PROCEDURE ClearLeavingReasons;
--
FUNCTION GetLeavingReasons RETURN LeavingReasonsType;
--
PROCEDURE SetLeavingReasons(
 p_index	IN NUMBER
,p_value	IN VARCHAR2 );
--
FUNCTION get_poplist(p_select_statement VARCHAR2
                    ,p_parameter_list   VARCHAR2
                    ,p_parameter_name   VARCHAR2
                    ,p_parameter_value  VARCHAR2
                    ,p_report_name      VARCHAR2
                    ,p_report_link VARCHAR2) RETURN VARCHAR2;

function business_group_id return NUMBER;
pragma restrict_references (business_group_id, WNPS, WNDS);
function org_structure_version_id return NUMBER;
pragma restrict_references (org_structure_version_id, WNPS, WNDS);
--
  function ConvertToHours
    ( p_formula_id      in Number
    , p_assignment_id   in Number
    , p_screen_value    in Varchar2
    , p_uom             in Varchar2
    , p_effective_date  in Date
    , p_session_date    in Date )
  return Number;
--
  function TrainingConvertDuration
    ( p_formula_id             In Number
    , p_from_duration          In Number
    , p_from_units             In Varchar2
    , p_to_units               In Varchar2
    , p_activity_version_name  In Varchar2
    , p_event_name             In Varchar2
    , p_session_date           In Date )
  return Number;
--
  function GetLocationId
    ( p_level              IN Number
    , p_location_id        IN Number
    , p_position_id        IN Number
    , p_organization_id    IN Number
    , p_business_group_id  IN Number )
  return Number;
--
  function GetGeographyDimension
    ( p_level              IN Number
    , p_location_id        IN Number
    , p_position_id        IN Number
    , p_organization_id    IN Number
    , p_business_group_id  IN Number )
  return Varchar2;

  function GetReportingHierarchy
  return Number;
--  pragma restrict_references( GetReportingHierarchy, WNPS, WNDS );

  function Get_Region_Segment
  return varchar2;

--

  PROCEDURE Raise_FF_Not_Exist
    ( p_bgttyp        in VarChar2  );

  PROCEDURE Raise_FF_Not_Compiled
    ( p_formula_id    in Number );

  PROCEDURE CheckFastFormulaCompiled
    ( p_formula_id    in Number
    , p_bgttyp        in VarChar2  );

--

END HrFastAnswers;

 

/
