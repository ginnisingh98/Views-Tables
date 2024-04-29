--------------------------------------------------------
--  DDL for Package Body PA_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_STATUS" AS
/* $Header: PAXVPS1B.pls 115.0 99/07/16 15:37:57 porting ship $  */
--================================================================
--
--
------------------------------------------------------------------------------------------------------------------
-- Functions and Procedures to Drive Project Status Inquiry Views
------------------------------------------------------------------------------------------------------------------
--

--  Derive Project Id
	FUNCTION GetProjId RETURN NUMBER
	IS
	BEGIN

		RETURN (  GlobVars.ProjectId );
	END;

--  Derive Task Id
	FUNCTION GetTaskId RETURN NUMBER
	IS
	BEGIN

		RETURN ( GlobVars.TaskId );
	END;

--  Derive Resource List Id
	FUNCTION GetRsrcListId RETURN NUMBER
	IS
	BEGIN

		RETURN ( GlobVars.RsrcListId );
	END;


--  Derive Resource List Member Id
	FUNCTION GetRsrcMemberId RETURN NUMBER
	IS
	BEGIN

		RETURN ( GlobVars.RsrcMemberId );
	END;



--  Derive Cost Budget Code
	FUNCTION GetCostBgtCode RETURN VARCHAR2
	IS
	BEGIN

		RETURN (  GlobVars.CostBgtCode  );
	END;

--  Derive Revenue Budget Code
	FUNCTION GetRevBgtCode RETURN VARCHAR2
	IS
	BEGIN

		RETURN (  GlobVars.RevBgtCode  );
	END;

--  Derive Start Date
	FUNCTION GetStartDate RETURN DATE
	IS
	BEGIN

		RETURN (  GlobVars.StartDate  );
	END;

--  Derive End Date
	FUNCTION GetEndDate RETURN DATE
	IS
	BEGIN

		RETURN (  GlobVars.EndDate  );
	END;
-- Derive Factor
        FUNCTION Get_Factor RETURN NUMBER
        IS
        BEGIN
                RETURN (  GlobVars.Get_Factor );
        END;

------------------------------------------------------------------------------------------------------------------------
	PROCEDURE  pa_status_driver (
				x_project_id			IN 	NUMBER
				, x_task_id			IN	NUMBER
				, x_resource_list_id 		IN	NUMBER
				, x_resource_list_member_id	IN 	NUMBER
				, x_cost_budget_code  		IN	VARCHAR2
				, x_rev_budget_code		IN	VARCHAR2
				, x_start_date			IN	DATE
				, x_end_date			IN	DATE
                                , x_factor                      IN      NUMBER)
	 IS  BEGIN
			GlobVars.ProjectId		:=  	x_project_id;
			GlobVars.TaskId			:=	x_task_id;
			GlobVars.RsrcListId		:=	x_resource_list_id;
			GlobVars.RsrcMemberId		:= 	x_resource_list_member_id;
			GlobVars.CostBgtCode		:=	x_cost_budget_code;
			GlobVars.RevBgtCode		:=	x_rev_budget_code;
			GlobVars.StartDate		:=	x_start_date;
			GlobVars.EndDate		:=	x_end_date;
                        GlobVars.Get_Factor             :=      x_factor;
	END pa_status_driver;

END pa_status;

/
