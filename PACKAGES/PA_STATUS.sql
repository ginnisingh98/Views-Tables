--------------------------------------------------------
--  DDL for Package PA_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_STATUS" AUTHID CURRENT_USER as
/* $Header: PAXVPS1S.pls 115.0 99/07/16 15:38:02 porting ship $   */
--==============================================================

--
-- Define Global Variables, Functions and Procedure
--

-- Define Global Variables
-- Global Record
	TYPE GlobalVars IS RECORD
	(	ProjectId			NUMBER(15)
		, TaskId				NUMBER(15)
		, RsrcListId			NUMBER(15)
		, RsrcMemberId			NUMBER(15)
		, CostBgtCode			VARCHAR2(30)
		, RevBgtCode			VARCHAR2(30)
		, StartDate			DATE
		, EndDate			DATE
                , Get_Factor                    NUMBER

	);

GlobVars	GlobalVars;

--
------------------------------------------------------------------------------------------
-- Define Functions to help pass Global Variables from to Views
------------------------------------------------------------------------------------------
--

--  Derive Project Id
	FUNCTION GetProjId RETURN NUMBER;
	pragma RESTRICT_REFERENCES  ( GetProjId, WNDS, WNPS );

--  Derive Task Id
	FUNCTION GetTaskId RETURN NUMBER;
	pragma RESTRICT_REFERENCES  ( GetTaskId, WNDS, WNPS );

--  Derive Resource List Id
	FUNCTION GetRsrcListId RETURN NUMBER;
	pragma RESTRICT_REFERENCES  ( GetRsrcListId, WNDS, WNPS );

--  Derive Resource List Member Id
	FUNCTION GetRsrcMemberId RETURN NUMBER;
	pragma RESTRICT_REFERENCES  (GetRsrcMemberId , WNDS, WNPS );

--  Derive Cost Budget Code
	FUNCTION GetCostBgtCode RETURN VARCHAR2;
	pragma RESTRICT_REFERENCES  ( GetCostBgtCode, WNDS, WNPS );

--  Derive Revenue Budget Code
	FUNCTION GetRevBgtCode RETURN VARCHAR2;
	pragma RESTRICT_REFERENCES  ( GetRevBgtCode, WNDS, WNPS );

--  Derive Start Date
	FUNCTION GetStartDate RETURN DATE;
	pragma RESTRICT_REFERENCES  ( GetStartDate, WNDS, WNPS );

--  Derive End Date
	FUNCTION GetEndDate RETURN DATE;
	pragma RESTRICT_REFERENCES  ( GetEndDate, WNDS, WNPS );

--  Derive Get_Factor
        FUNCTION Get_Factor RETURN NUMBER;
	pragma RESTRICT_REFERENCES  ( Get_Factor, WNDS, WNPS );

--
--  Define Procedure to Set Global Variables for Aforementioned Functions
--

	PROCEDURE  pa_status_driver (
				x_project_id			IN 	NUMBER
				, x_task_id			IN	NUMBER
				, x_resource_list_id 		IN	NUMBER
				, x_resource_list_member_id	IN	NUMBER
				, x_cost_budget_code  		IN	VARCHAR2
				, x_rev_budget_code		IN	VARCHAR2
				, x_start_date			IN	DATE
				, x_end_date			IN	DATE
                                , x_factor                      IN      NUMBER);


END pa_status;

 

/
