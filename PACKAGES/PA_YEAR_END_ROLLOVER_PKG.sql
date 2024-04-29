--------------------------------------------------------
--  DDL for Package PA_YEAR_END_ROLLOVER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_YEAR_END_ROLLOVER_PKG" AUTHID CURRENT_USER AS
--  $Header: PABRLYRS.pls 120.5 2007/02/06 09:27:01 rshaik ship $

--------------------------------------------------------------------------------------
--  Package           : PA_BUDGET_ACCOUNT_PKG
--  Purpose           : To execute the Year End Budget Rollover process
--  Parameters        :
--------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------
--  Procedure         : Year_End_Rollover
--  Purpose           : To execute the Year End Budget Rollover process
--                      for a giver fiscal year and Project Range
--  Parameters        :
--------------------------------------------------------------------------------------

PROCEDURE Year_End_Rollover (
  P_Closing_Year        IN   NUMBER, -- PA_Budget_Versions.Closing_Year%TYPE ?
  P_Organization_ID     IN   PA_Organizations_V.Organization_ID%TYPE,
  P_From_Project_Number IN   PA_Projects_All.Segment1%TYPE,
  P_To_Project_Number   IN   PA_Projects_All.Segment1%TYPE,
  P_Request_ID          IN   FND_Concurrent_Requests.Request_ID%TYPE,
  X_Return_Status       OUT  NOCOPY VARCHAR2,
  X_Msg_Count           OUT  NOCOPY NUMBER,
  X_Msg_Data            OUT  NOCOPY VARCHAR2
);

--------------------------------------------------------------------------------------
--  Procedure         : Get_Period_Details
--  Purpose           : To fetch the required period details
--  Parameters        :
--------------------------------------------------------------------------------------
PROCEDURE Get_Period_Details (
  P_Fiscal_Year                IN   NUMBER,
  P_Set_Of_Books_ID            IN   GL_Sets_Of_Books.Set_Of_Books_ID%TYPE,
  P_Accounted_Period_Type      IN   GL_Sets_Of_Books.Accounted_Period_Type%TYPE,
  X_Cur_Yr_Last_Prd_Name       OUT  NOCOPY GL_Periods.Period_Name%TYPE,
  X_Cur_Yr_First_Prd_Start_Dt  OUT  NOCOPY GL_Periods.Start_Date%TYPE,
  X_Cur_Yr_Last_Prd_Start_Dt   OUT  NOCOPY GL_Periods.Start_Date%TYPE,
  X_Cur_Yr_Last_Prd_End_Dt     OUT  NOCOPY GL_Periods.End_Date%TYPE,
  X_Next_Yr_First_Prd_Name     OUT  NOCOPY GL_Periods.Period_Name%TYPE,
  X_Next_Yr_First_Prd_Start_Dt OUT  NOCOPY GL_Periods.Start_Date%TYPE,
  X_Next_Yr_First_Prd_End_Dt   OUT  NOCOPY GL_Periods.End_Date%TYPE,
  X_Return_Status              OUT  NOCOPY VARCHAR2,
  X_Msg_Count                  OUT  NOCOPY NUMBER,
  X_Msg_Data                   OUT  NOCOPY VARCHAR2
);


--------------------------------------------------------------------------------------
--  Procedure         : Upd_Ins_Budget_Line
--  Purpose           : To update/insert budget line data into PA_BUDGET_LINES
--  Parameters        :
--------------------------------------------------------------------------------------
PROCEDURE Upd_Ins_Budget_Line (
  P_Budget_Version_ID       IN   PA_Budget_Versions.Budget_Version_ID%TYPE,
  P_Budget_Type_Code        IN   PA_Budget_Types.Budget_Type_Code%TYPE,
  P_Resource_Assignment_ID  IN out   NOCOPY PA_Resource_Assignments.Resource_Assignment_ID%TYPE,
  P_Period_Name             IN   GL_Periods.Period_Name%TYPE,
  P_Period_Start_Date       IN   GL_Periods.Start_Date%TYPE,
  P_Period_End_Date         IN   GL_Periods.End_Date%TYPE,
  P_Transfer_Amount         IN   NUMBER,
  P_Project_ID              IN   PA_Projects_all.Project_ID%TYPE,
  P_Task_ID                 IN   PA_Tasks.Task_ID%TYPE,
  P_Resource_List_Member_ID IN   PA_Resource_List_Members.Resource_List_Member_ID%TYPE,
  P_Raw_Cost_Flag           IN   PA_Budget_Entry_Methods.Raw_Cost_Flag%TYPE,
  P_Burdened_Cost_Flag      IN   PA_Budget_Entry_Methods.Burdened_Cost_Flag%TYPE,
  P_CCID                    IN   GL_Code_Combinations.Code_Combination_ID%TYPE,
  P_Request_ID              IN   FND_Concurrent_Requests.Request_ID%TYPE,
  P_Period_New_Or_Closing   IN   VARCHAR2,
  P_New_CCID                OUT  NOCOPY GL_Code_Combinations.Code_Combination_ID%TYPE,
  X_Return_Status           OUT  NOCOPY VARCHAR2,
  X_Msg_Count               OUT  NOCOPY NUMBER,
  X_Msg_Data                OUT  NOCOPY VARCHAR2
);

--------------------------------------------------------------------------------------
--  Procedure         : Create_Working_Budget
--  Purpose           : Create a Draft version of a Baselined Budget
--  Parameters        :
--------------------------------------------------------------------------------------
PROCEDURE Create_Working_Budget (
  P_Project_ID              IN   PA_Projects_all.Project_ID%TYPE,
  P_Budget_Type_Code        IN   PA_Budget_Types.Budget_Type_Code%TYPE,
  P_Budget_Version_ID       IN   PA_Budget_Versions.Budget_Version_ID%TYPE,
  P_Request_ID              IN   FND_Concurrent_Requests.Request_ID%TYPE,
  X_Work_Budget_Version_ID  OUT  NOCOPY PA_Budget_Versions.Budget_Version_ID%TYPE,
  X_Return_Status           OUT  NOCOPY VARCHAR2,
  X_Msg_Count               OUT  NOCOPY NUMBER,
  X_Msg_Data                OUT  NOCOPY VARCHAR2
);

--------------------------------------------------------------------------------------
--  Procedure         : Year_End_Rollover_Log
--  Purpose           : To stamp a log message into PA_BUDGET_VERSIONS
--  Parameters        :
--------------------------------------------------------------------------------------
PROCEDURE Year_End_Rollover_Log (
  P_Budget_Version_ID       IN   PA_Budget_Versions.Budget_Version_ID%TYPE,
  P_Message_Name            IN   FND_New_Messages.Message_Name%TYPE,
  P_Request_ID              IN   FND_Concurrent_Requests.Request_ID%TYPE,
  P_Lock_Name               IN   VARCHAR2
);

/* Bug 5726535 - Start */
--------------------------------------------------------------------------------------
--  Function          : Is_Yr_End_Rollover_Running
--  Purpose           : Checks if PA_Budgetary_Control_Options.Yr_End_Rollover_Flag
--                      is already set to 'P' for the given Project and Budget Type
--                      combination.If yes, the function returns TRUE. Otherwise, the
--                      function returns FALSE
--  Parameters        :
--------------------------------------------------------------------------------------
FUNCTION Is_Yr_End_Rollover_Running (
  P_Project_ID IN PA_Projects_all.Project_ID%TYPE,
  P_Budget_Type_Code IN PA_Budget_Types.Budget_Type_Code%TYPE
) RETURN BOOLEAN;

--------------------------------------------------------------------------------------
--  Procedure         : Upd_Yr_End_Rollover_Flag_To_P
--  Purpose           : Updates PA_Budgetary_Control_Options.Yr_End_Rollover_Flag to
--                      'P' in an autonomous transaction for the given Project and
--                      Budget Type combination.
--  Parameters        :
--------------------------------------------------------------------------------------
PROCEDURE Upd_Yr_End_Rollover_Flag_To_P (
  P_Request_ID IN FND_Concurrent_Requests.Request_ID%TYPE,
  P_Project_ID IN PA_Projects_all.Project_ID%TYPE,
  P_Budget_Type_Code IN PA_Budget_Types.Budget_Type_Code%TYPE
);

--------------------------------------------------------------------------------------
--  Procedure         : Upd_Yr_End_Rollover_Flag_To_E
--  Purpose           : Updates PA_Budgetary_Control_Options.Yr_End_Rollover_Flag to
--                      'E' in an autonomous transaction for the given Request ID
--  Parameters        :
--------------------------------------------------------------------------------------
PROCEDURE Upd_Yr_End_Rollover_Flag_To_E (
  P_Request_ID IN FND_Concurrent_Requests.Request_ID%TYPE
);
/* Bug 5726535 - End */

END PA_YEAR_END_ROLLOVER_PKG; /* End Package Specifications PA_YEAR_END_ROLLOVER_PKG */

/
