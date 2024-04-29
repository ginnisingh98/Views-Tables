--------------------------------------------------------
--  DDL for Package EAM_ASSIGN_EMP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ASSIGN_EMP_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPESHS.pls 120.0.12010000.3 2008/09/23 07:37:47 vmec ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMPESHS.pls
--
--  DESCRIPTION
--
--  Package Interface for returning the various employees eligible for assignment
--  to a specific workorder -operation or workorder-operation-resource context.
--  NOTES
--
--  HISTORY
--
-- 11-Mar-05    Samir Jain   Initial Creation
***************************************************************************/

TYPE Emp_Search_Result_Rec_Type IS RECORD
	(
	  person_id                   NUMBER,
	  employee_name               VARCHAR2(240),
	  employee_number             VARCHAR2(30),
	  instance_id                 NUMBER,
	  resource_id                 NUMBER,
	  department_id               NUMBER,
	  resource_code               VARCHAR2(10),
	  department_code             VARCHAR2(10),
	  assign_unassign_enable      VARCHAR2(30),
	  available_hours             NUMBER,
	  assigned_hours              NUMBER,
	  unassigned_hours            NUMBER,
	  assigned_percentage         NUMBER,
	  start_date                  DATE,
	  completion_date             DATE,
	  duration                    NUMBER,
	  wo_firm_status              VARCHAR2(1),   --1 firm, 2 non-firm
	  uom                         VARCHAR2(3)
	);

TYPE Emp_Search_Result_Tbl_Type IS TABLE OF Eam_Emp_Search_Result_Tbl%ROWTYPE;

TYPE Emp_Assignment_Rec_Type IS RECORD
	(
	  wip_entity_id                  NUMBER,
	  wo_end_dt                      DATE,
	  wo_st_dt                       DATE,
	  WorkOrderName                  VARCHAR2(240),
	  Resource_code                  VARCHAR2(10),
	  Update_Switcher                VARCHAR2(30),
	  usage                          NUMBER,
	  operation_seq_num              NUMBER,
	  resource_seq_num               NUMBER,
	  person_id                      NUMBER,
	  wo_assign_check                CHAR(1),
	  Assign_Switcher                VARCHAR2(30)	,
	  instance_id                    NUMBER,
	  organization_id                NUMBER
	);

 TYPE Emp_Assignment_Tbl_Type IS TABLE OF Eam_Emp_Assignment_Details_Tbl%ROWTYPE;


 --- Function and procedure signature to return the employee search results
/*
 * This procedure is used to get all the employees who can be assigned to a workorder.
 * Depending upon the search criteria entered, the eligible employees will be inserted into Eam_Emp_Search_Result_Tbl temporary table.
 * The API calls the required procedures and function to calculate the assigned hour,available hour,assigned percentage for each eligible employee.
 * The API requires you to enter atleast one of the following parameters: department id,resource id, person id,competence type, competence id.
 * Also, enter the relevant horizon for which the result is to be fetched.
 * In case of error ,API reports detailed and translatable error messages .
 */


PROCEDURE Get_Emp_Search_Results_Pub (
  p_horizon_start_date      IN DATE   ,
  p_horizon_end_date        IN DATE   ,
  p_organization_id         IN NUMBER,
  p_wip_entity_id           IN NUMBER ,
  p_competence_type         IN VARCHAR2 ,
  p_competence_id           IN NUMBER ,
  p_resource_id             IN NUMBER ,
  p_resource_seq_num        IN NUMBER ,
  p_operation_seq_num       IN NUMBER ,
  p_department_id           IN NUMBER ,
  p_person_id               IN NUMBER ,
  p_api_version           IN NUMBER  :=1.0 ,
  p_init_msg_list    	IN VARCHAR2:= FND_API.G_FALSE,
  p_commit 		IN VARCHAR2:= FND_API.G_FALSE ,
  p_validation_level 	IN NUMBER:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status		OUT	NOCOPY VARCHAR2	,
  x_msg_count		OUT	NOCOPY NUMBER	,
  x_msg_data		OUT	NOCOPY VARCHAR2);

 -- Function and procedure signature to return the assignment details of an employee
 /*
 * This procedure is used to get all the assignments for an employee.
 * Depending on the horizon selected the eligible employees assignments will be inserted into Eam_Emp_Assignment_Details_Tbl temporary table.
 * The API calls the required procedures and function to fetch the assignments within the given horizon.
 * In case of error ,API reports detailed and translatable error messages .
 */
 PROCEDURE Get_Emp_Assignment_Details_Pub
   (
    p_person_id             IN VARCHAR2,
    p_horizon_start_date    IN DATE,
    p_horizon_end_date      IN DATE,
    p_organization_id       IN NUMBER,
    p_api_version           IN NUMBER :=1.0  ,
    p_init_msg_list    	IN VARCHAR2:= FND_API.G_FALSE,
    p_commit 		IN VARCHAR2:= FND_API.G_FALSE ,
    p_validation_level 	IN NUMBER:= FND_API.G_VALID_LEVEL_FULL,
    x_return_status		OUT	NOCOPY VARCHAR2	,
    x_msg_count		OUT	NOCOPY NUMBER	,
    x_msg_data		OUT	NOCOPY VARCHAR2);



PROCEDURE Get_Emp_Search_Results_Pvt (
  p_horizon_start_date      IN DATE   ,
  p_horizon_end_date        IN DATE   ,
  p_organization_id         IN NUMBER,
  p_wip_entity_id           IN NUMBER ,
  p_competence_type         IN VARCHAR2 ,
  p_competence_id           IN NUMBER ,
  p_resource_id             IN NUMBER ,
  p_resource_seq_num        IN NUMBER ,
  p_operation_seq_num       IN NUMBER ,
  p_department_id           IN NUMBER ,
  p_person_id               IN NUMBER ,
  p_api_version           IN NUMBER :=1.0  ,
  p_init_msg_list    	IN VARCHAR2:= FND_API.G_FALSE,
  p_commit 		IN VARCHAR2:= FND_API.G_FALSE ,
  p_validation_level 	IN NUMBER:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status		OUT	NOCOPY VARCHAR2	,
  x_msg_count		OUT	NOCOPY NUMBER	,
  x_msg_data		OUT	NOCOPY VARCHAR2);

 -- Function and procedure signature to return the assignment details of an employee
 PROCEDURE Get_Emp_Assignment_Details_Pvt
   (
    p_person_id             IN VARCHAR2,
    p_horizon_start_date    IN DATE,
    p_horizon_end_date      IN DATE,
    p_organization_id       IN NUMBER,
    p_api_version           IN NUMBER  :=1.0 ,
    p_init_msg_list    	IN VARCHAR2:= FND_API.G_FALSE,
    p_commit 		IN VARCHAR2:= FND_API.G_FALSE ,
    p_validation_level 	IN NUMBER:= FND_API.G_VALID_LEVEL_FULL,
    x_return_status		OUT	NOCOPY VARCHAR2	,
    x_msg_count		OUT	NOCOPY NUMBER	,
    x_msg_data		OUT	NOCOPY VARCHAR2);


 -- Function to get the assignment status of a workordder.

FUNCTION Get_Emp_Assignment_Status
 (
   p_wip_entity_id    IN NUMBER,
   p_organization_id  IN NUMBER
 )
 RETURN VARCHAR2;

--Helper Functions--------------------------

FUNCTION Competence_Type_Check
 (
    p_person_id        IN NUMBER,
    p_competence_type  IN VARCHAR2
  )
  RETURN VARCHAR2;

FUNCTION Competence_Check
  (
    p_person_id        IN NUMBER,
    p_competence_id    IN NUMBER
  )
  RETURN VARCHAR2;

FUNCTION Cal_Assigned_Hours
  (p_wo_st_dt            IN DATE,
   p_wo_end_dt           IN DATE,
   p_horizon_start_date  IN DATE,
   p_horizon_end_date    IN DATE
  )
  RETURN NUMBER;

FUNCTION Cal_Available_Hour(
  p_resource_id        IN NUMBER,
  p_dept_id            IN NUMBER,
  p_calendar_code      IN VARCHAR2,
  p_horizon_start_date IN DATE,
  p_horizon_end_date   IN DATE
  )
  RETURN NUMBER;

FUNCTION Cal_Hr_Sys_Between_Horizon
  (p_wo_st_dt            IN DATE,
   p_wo_end_dt           IN DATE,
   p_horizon_start_date  IN DATE,
   p_horizon_end_date    IN DATE
  )
  RETURN NUMBER;

FUNCTION Cal_Hr_Sys_Before_Horizon
  (p_wo_st_dt            IN DATE,
   p_wo_end_dt           IN DATE,
   p_horizon_start_date  IN DATE,
   p_horizon_end_date    IN DATE
  )
  RETURN NUMBER;


FUNCTION Date_Exception
 (
   p_date IN DATE,
   p_calendar_code IN VARCHAR2
 )
 RETURN CHAR;


PROCEDURE Cal_Extra_Hour_Start_Dt
 (
   l_start_date IN DATE,
   l_previous   IN BOOLEAN,
   l_calendar_code IN VARCHAR2,
   l_dept_id     IN NUMBER,
   l_resource_id IN NUMBER,
   x_start_date OUT NOCOPY DATE,
   x_extra_hour OUT NOCOPY NUMBER
 );

 PROCEDURE Cal_Extra_Hour_End_Dt
 (
   l_end_date IN DATE,
   l_previous   IN BOOLEAN,
   l_calendar_code IN VARCHAR2,
   l_dept_id     IN NUMBER,
   l_resource_id IN NUMBER,
   x_end_date OUT NOCOPY DATE,
   x_extra_hour OUT NOCOPY NUMBER
 );

procedure cal_extra_24_hr_end_dt
 (
   p_end_date IN DATE,
   p_calendar_code IN VARCHAR2,
   x_end_date OUT NOCOPY DATE,
   x_extra_hour OUT NOCOPY NUMBER
 );
  procedure cal_extra_24_hr_st_dt
 (
   p_start_date IN DATE,
   p_calendar_code IN VARCHAR2,
   x_end_date OUT NOCOPY DATE,
   x_extra_hour OUT NOCOPY NUMBER
 );

 PROCEDURE Cal_Extra_Hour_Same_Dt
 (
   l_start_date IN DATE,
   l_end_date IN DATE,
   l_calendar_code IN VARCHAR2,
   l_dept_id     IN NUMBER,
   l_resource_id IN NUMBER,
   x_extra_hour OUT NOCOPY NUMBER
 );

 PROCEDURE Cal_Extra_Hour_Generic
 (
   l_start_date IN DATE,
   l_end_date IN DATE,
   l_calendar_code IN VARCHAR2,
   l_dept_id     IN NUMBER,
   l_resource_id IN NUMBER,
   x_extra_hour OUT NOCOPY NUMBER
 );

 FUNCTION Fetch_Details
 (
   p_op_res_end_dt    IN DATE
 )
 RETURN VARCHAR2;



END EAM_ASSIGN_EMP_PUB;

/
