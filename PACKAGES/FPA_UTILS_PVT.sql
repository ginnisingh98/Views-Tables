--------------------------------------------------------
--  DDL for Package FPA_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FPA_UTILS_PVT" AUTHID CURRENT_USER as
/* $Header: FPAVUTIS.pls 120.1.12010000.2 2009/12/11 07:22:50 jcgeorge ship $ */

--The procedure Get_Scenario_Wscore_Color is used to compare the
--scenario weighted score against the Planning Cycle From and To
--weighted score targets.
--It returns the appropriate color.
function Get_Scenario_Wscore_Color(
  p_pc_id           IN              number
 ,p_scenario_id         IN              number
) return varchar2;

--The procedure Get_Scenario_NPV_Color is used to compare the
--scenario NPV against the Planning Cycle From and To
--NPV targets.
--It returns the appropriate color.
function Get_Scenario_NPV_Color(
  p_pc_id                       IN              number
 ,p_scenario_id                 IN              number
) return varchar2;

--The procedure Get_Scenario_ROI_Color is used to compare the
--scenario ROI against the Planning Cycle From and To
--ROI targets.
--It returns the appropriate color.
function Get_Scenario_ROI_Color(
  p_pc_id                       IN              number
 ,p_scenario_id                 IN              number
) return varchar2;

--This procedure is used by the UI to determine which icon to render
--in the PC Checklist Table.
--It evaluates the Planning Cycle status and lookup code.  Depending on
--combination of these returns the appropriate value.
function Determine_PC_Checklist_status(
  p_pc_id                       IN              number
 ,p_lookup_code                 IN              varchar2
) return varchar2;

-- This function determines if an organization is member of the
-- Organization hierarchy set in the PJP Profile Option
function Is_Org_In_PJP_Org_Hier(
  p_org_id                       IN              number
) return number;

-- This function validates if a Class code can be assigned to a new Portfolio.
function Is_Class_Code_Available(
  p_class_code			IN		number
 ,p_org_id			IN		number
) return varchar2;

-- This function validates if an Organization can be assigned to a new Portfolio.
function Is_Organization_Available(
  p_org_id                  	IN              number
 ,p_class_code                  IN              number
) return varchar2;

procedure load_gl_calendar (
    p_api_version        IN NUMBER,
    p_commit             IN VARCHAR2,
    p_calendar_name 	IN VARCHAR2,
    p_period_type   	IN VARCHAR2,
    p_cal_period_type 	IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_data OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER );


-- Function call to check if one or more scenarios were recommended in this planning cycle.
-- This is one of the conditions to be met prior to enabling 'Recommend plan" icon on PC checklist page
function scenarios_recommended(
	p_planning_cycle_id	IN	NUMBER
    						  )
	return varchar2;

function scenario_approved(
	p_planning_cycle_id	IN	NUMBER
						  )
	return varchar2;

procedure get_inv_category_name(
				p_planning_cycle_id in number,
				x_inv_category_name out nocopy varchar2
			       );

procedure get_approver_name(
			   p_portfolio_id in number,
			   x_approver_names out nocopy varchar2
			   );

-- Function to retrun the Units of Measure
function Get_Fin_Metric_Unit(
p_planning_cycle_id	IN	NUMBER,
p_metric_code IN VARCHAR2
) return VARCHAR2;

/****END: Section for common API messages, exception handling and logging.******
*******************************************************************************/
-------------------------------------------------------------------
--  Utility Function to Return the Correct Number data
--  even if the decimal character is changed.
-------------------------------------------------------------------
FUNCTION GET_FORMATTED_NUM( P_INPUT_STR IN VARCHAR2 ) RETURN NUMBER ;


end FPA_Utils_PVT;

/
