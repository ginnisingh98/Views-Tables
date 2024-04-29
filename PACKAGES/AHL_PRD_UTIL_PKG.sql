--------------------------------------------------------
--  DDL for Package AHL_PRD_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: AHLUPRDS.pls 120.8.12010000.2 2009/03/13 06:51:51 jkjain ship $ */
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Contains utility and helper functions used by the CMRO Execution module.
--
-- Added global constants to be used to identity techinican, Data Clerk and Line Maintenance
-- Technician roles.

G_TECH_MYWO  CONSTANT VARCHAR2(30) := 'AHL_PRD_TECH_MYWO';
G_DATA_CLERK CONSTANT VARCHAR2(30) := 'AHL_PRD_DATA_CLERK';
G_LINE_TECH  CONSTANT VARCHAR2(30) := 'AHL_PRD_TRANSIT_TECH';

    PROCEDURE validate_locators
     ( p_locator_id IN number,
       p_org_id IN number,
       p_subinventory_code IN Varchar2,
       X_Return_Status      Out NOCOPY Varchar2,
       X_Msg_Data           Out NOCOPY Varchar2
    );

procedure validate_condition
    (
        p_condition_id  In number,
        x_return_status out NOCOPY varchar2,
        x_msg_data out NOCOPY varchar2

    );

    procedure validate_reason
    (
        p_reason_id  In number,
        x_return_status out NOCOPY varchar2,
        x_msg_data out NOCOPY varchar2

    );

	 PROCEDURE VALIDATE_MATERIAL_STATUS(p_Organization_Id 	IN   NUMBER,
		  						p_Subinventory_Code IN 	 VARCHAR2,-- not null
								p_Condition_id		IN 	 NUMBER,-- null/not null
								x_return_status 	OUT  NOCOPY VARCHAR2
								);

------------------------------------------------------------------------------------------------
-- Function to test if the Unit in context is locked or not. The input to the API can be one of
-- workorder_id, mr_id, visit_id or item_instance_id.
------------------------------------------------------------------------------------------------
-- Start of Comments
-- Function name               : Is_Unit_Locked
-- Type                        : Private
-- Pre-reqs                    :
-- Parameters                  :
-- Return		       : FND_API.G_TRUE or FND_API.G_FALSE.
--
-- Standard IN  Parameters :
--	None
--
-- Standard OUT Parameters :
--	None
--
-- Is_Unit_Locked IN parameters:
--      P_workorder_id		NUMBER		Required
--	P_ue_id			NUMBER		Required
--	P_visit_id		NUMBER		Required
--	P_item_instance_id	NUMBER		Required
--
-- Is_Unit_Locked IN OUT parameters:
--      None
--
-- Is_Unit_Locked OUT parameters:
--      None.
--
-- Version :
--          Current version        1.0
--
-- End of Comments

FUNCTION Is_Unit_Locked(
	P_workorder_id		IN 	NUMBER,
	P_ue_id			IN 	NUMBER,
	P_visit_id		IN 	NUMBER,
	P_item_instance_id	IN 	NUMBER
)
RETURN VARCHAR2;

------------------------------------------------------------------------------------------------
-- Function to test if the workorder can be updated.
-- Determined based on following factors
-- 1. If the unit is quarantined then it cannot be updated.
-- 2. If the workorder status is any of 22, 12 and 7 then it cannot be updated.
------------------------------------------------------------------------------------------------
-- Start of Comments
-- Function name               : Is_Wo_Updatable
-- Type                        : Private
-- Pre-reqs                    :
-- Parameters                  :
-- Return		       : FND_API.G_TRUE or FND_API.G_FALSE.
--
-- Standard IN  Parameters :
--	None
--
-- Standard OUT Parameters :
--	None
--
-- Is_Wo_Updatable IN parameters:
--      P_workorder_id		NUMBER		Required
--
-- Is_Wo_Updatable IN OUT parameters:
--      None
--
-- Is_Wo_Updatable OUT parameters:
--      None.
--
-- Version :
--          Current version        1.0
--
-- End of Comments

FUNCTION Is_Wo_Updatable(
	P_workorder_id		IN 	NUMBER,
	p_check_unit            IN      VARCHAR2 DEFAULT FND_API.G_TRUE
)
RETURN VARCHAR2;

------------------------------------------------------------------------------------------------
-- Function to test if the workorder operation can be updated.
-- Determined based on following factors
-- 1. If the unit associated with the workorder to which the operation belongs is quarantined
--    then it cannot be updated.
-- 2. If the workorder status is any of 22, 12 and 7 then it cannot be updated.
-- 3. If the operation status is 'COMPLETE' then it cannot be updated
------------------------------------------------------------------------------------------------
-- Start of Comments
-- Function name               : Is_Op_Updatable
-- Type                        : Private
-- Pre-reqs                    :
-- Parameters                  :
-- Return		       : FND_API.G_TRUE or FND_API.G_FALSE.
--
-- Standard IN  Parameters :
--	None
--
-- Standard OUT Parameters :
--	None
--
-- Is_Op_Updatable IN parameters:
--      P_workorder_id		NUMBER		Required
--	p_operation_seq_num	NUMBER		Required
--
-- Is_Op_Updatable IN OUT parameters:
--      None
--
-- Is_Op_Updatable OUT parameters:
--      None.
--
-- Version :
--          Current version        1.0
--
-- End of Comments
FUNCTION Is_Op_Updatable(
	p_workorder_id		IN	NUMBER,
	p_operation_seq_num	IN	NUMBER,
	p_check_unit            IN      VARCHAR2 DEFAULT FND_API.G_TRUE
)
RETURN VARCHAR2;

------------------------------------------------------------------------------------------------
-- Function to determine if a MR requires Quality collection to be done.
-- (Whether QA Collection is required)
-- The function returns QA Plan id or null if one is not associated with the MR.
------------------------------------------------------------------------------------------------
-- Start of Comments
-- Function name               : Is_Mr_Qa_Enabled
-- Type                        : Private
-- Pre-reqs                    :
-- Parameters                  :
-- Return		       : VARCHAR2.
--
-- Standard IN  Parameters :
--	None
--
-- Standard OUT Parameters :
--	None
--
-- Is_Mr_Qa_Enabled IN parameters:
--      P_workorder_id		NUMBER		Required
--	p_ue_id			NUMBER		Required
--
-- Is_Mr_Qa_Enabled IN OUT parameters:
--      None
--
-- Is_Mr_Qa_Enabled OUT parameters:
--      None.
--
-- Version :
--          Current version        1.0
--
-- End of Comments
FUNCTION Is_Mr_Qa_Enabled(
	p_ue_id			IN	NUMBER,
	p_check_unit            IN      VARCHAR2 DEFAULT FND_API.G_TRUE
)
RETURN NUMBER;

------------------------------------------------------------------------------------------------
-- Function to determine if parts changes are allowed for a workorder
-- 1. If the unit is quarantined then part changes are not allowed.
-- 2. If the workorder status is any of 22, 12 and 7 then part changes cannot be done.
------------------------------------------------------------------------------------------------
-- Start of Comments
-- Function name               : Is_PartChange_Enabled
-- Type                        : Private
-- Pre-reqs                    :
-- Parameters                  :
-- Return		       : FND_API.G_TRUE or FND_API.G_FALSE.
--
-- Standard IN  Parameters :
--	None
--
-- Standard OUT Parameters :
--	None
--
-- Is_PartChange_Enabled IN parameters:
--      P_workorder_id		NUMBER		Required
--
-- Is_PartChange_Enabled IN OUT parameters:
--      None
--
-- Is_PartChange_Enabled OUT parameters:
--      None.
--
-- Version :
--          Current version        1.0
--
-- End of Comments
FUNCTION Is_PartChange_Enabled(
	P_workorder_id		IN	NUMBER,
	p_check_unit            IN      VARCHAR2 DEFAULT FND_API.G_TRUE
)
RETURN VARCHAR2;

------------------------------------------------------------------------------------------------
-- Function to check if resource assignment should be allowed. The logic is based on following
-- factors :
-- 1. The unit is quarantined.
-- 2. A user is currently logged into the resource assignment.
-- 3. Resource transactions have been posted corresponding to this resource assignment.
------------------------------------------------------------------------------------------------
-- Start of Comments
-- Function name               : IsDelAsg_Enabled
-- Type                        : Private
-- Pre-reqs                    :
-- Parameters                  :
-- Return		       : FND_API.G_TRUE or FND_API.G_FALSE.
--
-- Standard IN  Parameters :
--	None
--
-- Standard OUT Parameters :
--	None
--
-- IsDelAsg_Enabled IN parameters:
--		P_assignment_id		IN	REQUIRED
--		P_workorder_id		IN	REQUIRED
--
-- IsDelAsg_Enabled IN OUT parameters:
--      None
--
-- IsDelAsg_Enabled OUT parameters:
--      None.
--
-- Version :
--          Current version        1.0
--
-- End of Comments
FUNCTION IsDelAsg_Enabled(
		P_assignment_id		IN	NUMBER,
		P_workorder_id		IN	NUMBER,
           	p_check_unit            IN      VARCHAR2 DEFAULT FND_API.G_TRUE
)
RETURN VARCHAR2;

------------------------------------------------------------------------------------------------
-- Function to test if the workorder can be completed.
------------------------------------------------------------------------------------------------
-- Start of Comments
-- Function name               : Is_Wo_Completable
-- Type                        : Private
-- Pre-reqs                    :
-- Parameters                  :
-- Return		       : FND_API.G_TRUE or FND_API.G_FALSE.
--
-- Standard IN  Parameters :
--	None
--
-- Standard OUT Parameters :
--	None
--
-- Is_Wo_Updatable IN parameters:
--      P_workorder_id		NUMBER		Required
--
-- Is_Wo_Updatable IN OUT parameters:
--      None
--
-- Is_Wo_Updatable OUT parameters:
--      None.
--
-- Version :
--          Current version        1.0
--
-- End of Comments

FUNCTION Is_Wo_Completable(
	P_workorder_id		IN 	NUMBER
)
RETURN VARCHAR2;


------------------------------------------------------------------------------------------------
-- Function to test if resource transactions are allowed for a workorder
------------------------------------------------------------------------------------------------
-- Start of Comments
-- Function name               : Is_ResTxn_Allowed
-- Type                        : Private
-- Pre-reqs                    :
-- Parameters                  :
-- Return		       : FND_API.G_TRUE or FND_API.G_FALSE.
--
-- Standard IN  Parameters :
--	None
--
-- Standard OUT Parameters :
--	None
--
-- Is_Unit_Locked IN parameters:
--      P_workorder_id		NUMBER		Required
--
-- Is_Unit_Locked IN OUT parameters:
--      None
--
-- Is_Unit_Locked OUT parameters:
--      None.
--
-- Version :
--          Current version        1.0
--
-- End of Comments

FUNCTION Is_ResTxn_Allowed(
	P_workorder_id		IN 	NUMBER,
	p_check_unit            IN      VARCHAR2 DEFAULT FND_API.G_TRUE
)
RETURN VARCHAR2;

------------------------------------------------------------------------------------------------
-- Function to test if user has preivilages to cancel a workorder that is not un-released
------------------------------------------------------------------------------------------------
-- Start of Comments
-- Function name               : Is_Wo_Cancel_Allowed
-- Type                        : Private
-- Pre-reqs                    :
-- Parameters                  :
-- Return		       : FND_API.G_TRUE or FND_API.G_FALSE.
--
-- Standard IN  Parameters :
--	None
--
-- Standard OUT Parameters :
--	None
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments

FUNCTION Is_Wo_Cancel_Allowed(
	P_workorder_id		IN 	  NUMBER := NULL
)
RETURN VARCHAR2;

--------------------------------------------------------------------------------------------
-- Start of Comments --
--  Function name : Get_Op_TotalHours_Assigned
--
--  Parameters  :
--
--                  p_employee_id    --  Optional Input Employee Id.
--                  p_workorder_id   --  Mandatory Workorder ID.
--                  p_operation_seq_num -- Mandatory Operation Seq Number
--                  p_fnd_function_name   -- Mandatory fnd_function to identify User role.
--
--
--  Description   : This function returns the total hours assigned to an operation.
--                  If the user role is technician or line maintenance technician, then the
--                  total hours are calculated for that particular employee resource,
--                  otherwise the total hours are calculated for all the person type
--                  resources in the operation. If the employee id is not passed to the
--                  function then the calculations are done for the user who is currently
--                  logged into the application.
--

FUNCTION Get_Op_TotalHours_Assigned (p_employee_id       IN NUMBER := NULL,
                                     p_workorder_id      IN NUMBER,
                                     p_operation_seq_num IN NUMBER,
                                     p_fnd_function_name IN VARCHAR2)
RETURN NUMBER;
--------------------------------------------------------------------------------------------


-- Start of Comments --
--  Function name : Get_Res_TotalHours_Assigned
--
--  Parameters  :
--
--                  p_employee_id    --  Optional Input Employee Id.
--                  p_workorder_id   --  Mandatory Workorder ID.
--                  p_operation_seq_num -- Mandatory Operation Seq Number
--                  p_resource_id       -- Mandatory resource ID.
--                  p_resource_seq_num  -- Mandatory resource ID.
--                  p_fnd_function_name   -- Mandatory fnd_function to identify User role.
--
--
--  Description   : This function returns the total hours assigned for a specific resource
--                  within an operation. If the employee id passed to the function is null,
--                  then the calculations are done for the user who is currently logged
--                  into the application.

FUNCTION Get_Res_TotalHours_Assigned (p_employee_id       IN NUMBER := NULL,
                                      p_workorder_id      IN NUMBER,
                                      p_operation_seq_num IN NUMBER,
                                      p_resource_id       IN NUMBER,
				      p_resource_seq_num  IN NUMBER,
                                      p_fnd_function_name IN VARCHAR2)
RETURN NUMBER;


--------------------------------------------------------------------------------------------
-- Start of Comments --
--  Function name : Get_Op_Transacted_Hours
--
--  Parameters  :
--                  p_employee_id    --  Optional Input Employee Id.
--                  p_wip_entity_id   --  Mandatory Workorder ID.
--                  p_operation_seq_num -- Mandatory Operation Seq Number
--                  p_fnd_function_name   -- Mandatory fnd_function to identify User role.
--
--  Description   : This function returns the number of hours transacted by an employee
--                  accross all resources within an operation. If the employee id passed to the
--                  function is null then the calculations are based on the user currently logged
--                  into the application.

FUNCTION Get_Op_Transacted_Hours (p_employee_id       IN NUMBER := NULL,
                                  p_wip_entity_id     IN NUMBER,
                                  p_operation_seq_num IN NUMBER,
                                  p_fnd_function_name IN VARCHAR2)
RETURN NUMBER;


--------------------------------------------------------------------------------------------
-- Start of Comments --
--  Function name : Get_Res_Transacted_Hours
--
--  Parameters  :
--                  p_employee_id    --  Optional Input Employee Id.
--                  p_wip_entity_id   --  Mandatory Workorder ID.
--                  p_operation_seq_num -- Mandatory Operation Seq Number
--                  p_resource_seq_num  -- Mandatory Resource ID.
--                  p_fnd_function_name  -- Mandatory fnd_function to identify user role.
--
--  Description   : This function returns the number of hours transacted by an employee
--                  for a particular resource requirement within an operation if the user is
--                  has a role of a technician or line maintenance technician. It returns the
--                  number of hours transacted by all employees for a resource requirement
--                  within an operation if the user is a data clerk.
--

FUNCTION Get_Res_Transacted_Hours (p_employee_id      IN NUMBER := NULL,
                                   p_wip_entity_id     IN NUMBER,
                                   p_operation_seq_num IN NUMBER,
                                   p_resource_seq_num  IN NUMBER,
                                   p_fnd_function_name IN VARCHAR2)
RETURN NUMBER;

--------------------------------------------------------------------------------------------

-- Start of Comments --
--  Function name : Get_Op_Assigned_Start_Date
--
--  Parameters  :
--
--                  p_employee_id    --  Optional Input Employee Id.
--                  p_workorder_id   --  Mandatory Workorder ID.
--                  p_operation_seq_num -- Mandatory Operation Seq Number
--                  p_fnd_function_name   -- Mandatory fnd_function to identify User role.
--
--
--  Description   : This function will be used to retrieve the Assigned Start Date for an
--                  operation as displayed on the Operations subtab of the Update Workorders
--                  page. The logic for retrieving the correct date is as follows:
--                      1. If the user is a technician, then assigned start time is the
--                         assign_start_date for the employee if he is assigned to only
--                         one resource within the operation.
--                         If the employee is assigned to more than one resource within
--                         the operation, then the assigned start date is the earliest
--                         of all the assignment dates for the employee.
--                      2. If the user is a data clerk or a line maintenance technician,
--                         then the assigned start date is the scheduled start date for the operation.
--
FUNCTION Get_Op_Assigned_Start_Date(p_employee_id       IN NUMBER := NULL,
                                    p_workorder_id      IN NUMBER,
                                    p_operation_seq_num IN NUMBER,
                                    p_fnd_function_name IN VARCHAR2)
RETURN DATE;


-- Start of Comments --
--  Function name : Get_Op_Assigned_End_Date
--
--  Parameters  :
--
--                  p_employee_id    --  Optional Input Employee Id.
--                  p_workorder_id   --  Mandatory Workorder ID.
--                  p_operation_seq_num -- Mandatory Operation Seq Number
--                  p_fnd_function_name   -- Mandatory fnd_function to identify User role.
--
--
--  Description   : This function will be used to retrieve the Assigned End Date for an
--                  operation as displayed on the Operations subtab of the Update Workorders
--                  page. The logic for retrieving the correct date is as follows:
--                      1. If the user is a technician, then assigned end time is the
--                         assign_end_date for the employee if he is assigned to only
--                         one resource within the operation.
--                         If the employee is assigned to more than one resource within
--                         the operation, then the assigned end date is the latest
--                         of all the assignment dates for the employee.
---                     2. If the user is a data clerk or a line maintenance technician, then
--                         the assigned end date is the scheduled start date for the operation.
--

FUNCTION Get_Op_Assigned_End_Date(p_employee_id       IN NUMBER := NULL,
                                  p_workorder_id      IN NUMBER,
                                  p_operation_seq_num IN NUMBER,
                                  p_fnd_function_name IN VARCHAR2)
RETURN DATE;

 -- Start of Comments --
 	 -- Function name : Hr_To_Duration
 	 -- Created by JKJ on 9th Jan 2009 for Bug No. 7658562. Fp Bug 8241923
 	 -- Parameters  :
 	 -- p_hr   --  Mandatory Input : Total Hours in Decimal Format.
 	 -- Description  :
 	 -- This function returns a String in Hours:Minutes:Seconds format when given hours as input in decimal format.
 	 --
 	 FUNCTION Hr_To_Duration(
 	 p_hr  IN        NUMBER
 	 )
 	 RETURN VARCHAR2 ;

END AHL_PRD_UTIL_PKG; -- Package Specification AHL_PRD_UTIL_PKG

/
