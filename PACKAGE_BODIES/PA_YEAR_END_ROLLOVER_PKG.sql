--------------------------------------------------------
--  DDL for Package Body PA_YEAR_END_ROLLOVER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_YEAR_END_ROLLOVER_PKG" AS
--  $Header: PABRLYRB.pls 120.13 2007/02/06 09:26:47 rshaik ship $

-------------------------------------------------------------------------------------
-- Execute the Year End Budget Rollover process
-------------------------------------------------------------------------------------
P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

-- # Forward Declaration
PROCEDURE Create_bc_balances(p_budget_version_id IN NUMBER,
                             p_last_baselined_version_id IN NUMBER,
                             p_Set_of_books_id   IN NUMBER,
                             p_return_status OUT NOCOPY VARCHAR2);

-- Procedure used to call pa_debug.write for FND logging
PROCEDURE LOG_MESSAGE(p_message in VARCHAR2);

g_procedure_name VARCHAR2(30);

-- -------------------------------------------------------------------------------------------------+
-- Re-introducing the following procedure as acct. summary needs to be build for the working budget
-- this is required to display the account level validatio/ funds check failures ..
-- -------------------------------------------------------------------------------------------------+

-------------------------------------------------------------------------------------
-- Insert/Update the Budget Summary Account details
-------------------------------------------------------------------------------------
PROCEDURE Upd_Ins_Budget_Acct_Line (
  P_Budget_Version_ID       IN   PA_Budget_Versions.Budget_Version_ID%TYPE,
  P_Period_Name             IN   GL_Periods.Period_Name%TYPE,
  P_Period_Start_Date       IN   GL_Periods.Start_Date%TYPE,
  P_Period_End_Date         IN   GL_Periods.End_Date%TYPE,
  P_Transfer_Amount         IN   NUMBER,
  P_CCID                    IN   GL_Code_Combinations.Code_Combination_ID%TYPE,
  P_Request_ID              IN   FND_Concurrent_Requests.Request_ID%TYPE,
  X_Return_Status           OUT  NOCOPY VARCHAR2,
  X_Msg_Count               OUT  NOCOPY NUMBER,
  X_Msg_Data                OUT  NOCOPY VARCHAR2
)
IS

-- Local Variables
-- l_Update_Count  NUMBER;
-- l_Error_Message VARCHAR2(200);

BEGIN

  g_procedure_name := 'Upd_Ins_Budget_Acct_Line';

  X_Return_Status := FND_API.G_RET_STS_SUCCESS;

  BEGIN
    IF P_DEBUG_MODE = 'Y' THEN
       log_message('Year_End_Rollover: ' || 'Before Update in Upd_Ins_Budget_Acct_Line');
       log_message('Year_End_Rollover: ' || 'Transfer Amount : '|| P_Transfer_Amount);
    END IF;
    ---------------------------------------------------------------------------------
    -- Update the Budget Summary Account's Current version Available Amount
    ---------------------------------------------------------------------------------
    UPDATE
      PA_Budget_Acct_Lines
    SET
      Curr_Ver_Budget_Amount    = nvl(Curr_Ver_Budget_Amount,0) + P_Transfer_Amount,
      Curr_Ver_Available_Amount = nvl(Curr_Ver_Available_Amount,0) + P_Transfer_Amount,
      Request_ID                = P_Request_ID
    WHERE
        Budget_Version_ID   = P_Budget_Version_ID
    -- AND GL_Period_Name      = P_Period_Name
    AND Start_Date          = P_Period_Start_Date
    AND Code_Combination_ID = P_CCID ;

    -- l_Update_Count := SQL%ROWCOUNT;
    --l_Error_Message := SUBSTR(SQLERRM, 1, 200);
    IF P_DEBUG_MODE = 'Y' THEN
       log_message('Year_End_Rollover: ' || SQL%ROWCOUNT || ' record(s) updated');
       log_message('Year_End_Rollover: ' || 'After Update in Upd_Ins_Budget_Acct_Line');
       --log_message('Year_End_Rollover: ' || 'Error Message : '|| l_Error_Message );
    END IF;

  END;

/* ============================================================================================== +
   -- No new records should be created in pa_budget_acct_lines as the records created for the new
   -- period will not have ccid. CCID is generated when account generator called in SUBMIT MODE.
   -- Acct. generator in SUBMIT  mode will also create data into pa_budget_acct_lines table

  IF l_Update_Count = 0 -- No Data found and no records are updated
  THEN
    ---------------------------------------------------------------------------------
    -- Create new Budget Summary Account's data for the non-existent details
    ---------------------------------------------------------------------------------
    INSERT INTO
      PA_BUDGET_ACCT_LINES (
         Budget_Acct_Line_ID,
         Budget_Version_ID,
         GL_Period_Name,
         Start_Date,
         End_Date,
         Code_Combination_ID,
         Prev_Ver_Budget_Amount,
         Prev_Ver_Available_Amount,
         Curr_Ver_Budget_Amount,
         Curr_Ver_Available_Amount,
         Accounted_Amount,
	 Creation_date,
	 Created_By,
	 Last_Update_date,
	 Last_Updated_By,
         Request_ID,
	 Last_Update_Login
      )
    VALUES (
         PA_BUDGET_ACCT_LINES_S.NextVal,
         P_Budget_Version_ID,
         P_Period_Name,
         P_Period_Start_Date,
         P_Period_End_Date,
         P_CCID,
         0,
         0,
         -- 0,
         P_Transfer_Amount,
         P_Transfer_Amount,
         0,
	 sysdate,
         FND_GLOBAL.User_ID,
	 sysdate,
         FND_GLOBAL.User_ID,
         P_Request_ID,
         FND_GLOBAL.User_ID
    ) ;
    IF P_DEBUG_MODE = 'Y' THEN
       log_message('Year_End_Rollover: ' || 'Error Step 2 : '|| SQLERRM );
    END IF;
  END IF;
 ============================================================================================== */

  RETURN;

END Upd_Ins_Budget_Acct_Line;

-- -------------------------------------------------------------------------------------------------+
PROCEDURE Year_End_Rollover (
  P_Closing_Year        IN   NUMBER, -- PA_Budget_Versions.Closing_Year%TYPE ?
  P_Organization_ID     IN   PA_Organizations_V.Organization_ID%TYPE,
  P_From_Project_Number IN   PA_Projects_All.Segment1%TYPE,
  P_To_Project_Number   IN   PA_Projects_All.Segment1%TYPE,
  P_Request_ID          IN   FND_Concurrent_Requests.Request_ID%TYPE,
  X_Return_Status       OUT  NOCOPY VARCHAR2,
  X_Msg_Count           OUT  NOCOPY NUMBER,
  X_Msg_Data            OUT  NOCOPY VARCHAR2
)
IS

-- Local Variables
l_Top_Task_ID              PA_Tasks.Task_ID%TYPE;
l_Parent_Member_ID         PA_Resource_List_Members.Parent_Member_ID%TYPE;
l_Project_Status_Code      VARCHAR2(100);
l_Change_Reason_Code       VARCHAR2(100);
l_Message_Code_Error       VARCHAR2(100);
l_Message_Name             VARCHAR2(100);
l_Rel_Lock                 NUMBER;
l_Proceed_Flag             BOOLEAN;
l_First_Time_Entry         BOOLEAN;
l_Lock_Name                VARCHAR2(200);
l_Total_Rollover_Amount    NUMBER;
l_Transfer_Amount          NUMBER;
l_UnSwept_Amount           NUMBER;
l_Funds_Chk_Rsrv_Status    VARCHAR2(1);

l_Accounted_Period_Type    GL_Sets_Of_Books.Accounted_Period_Type%TYPE;
l_New_Budget_Version_ID    PA_Budget_Versions.Budget_Version_ID%TYPE;
l_Work_Budget_Version_ID   PA_Budget_Versions.Budget_Version_ID%TYPE;
l_Work_Resource_Assign_ID  PA_Resource_Assignments.Resource_Assignment_ID%TYPE;
l_Bslnd_Budget_Version_ID  PA_Budget_Versions.Budget_Version_ID%TYPE;
l_Project_ID               PA_Projects_all.Project_ID%TYPE;
l_Project_Completion_Date  DATE;
l_Task_ID                  PA_Tasks.Task_ID%TYPE;
l_Budget_Type_Code         PA_Budget_Types.Budget_Type_Code%TYPE;
l_Encumbrance_Type_ID      GL_Encumbrance_Types.Encumbrance_Type_ID%TYPE;
l_External_Budget_Code     PA_Budgetary_Control_Options.External_Budget_Code%TYPE;
l_GL_Budget_Version_ID     PA_Budgetary_Control_Options.GL_Budget_Version_ID%TYPE;
l_Raw_Cost_Flag            PA_Budget_Entry_Methods.Raw_Cost_Flag%TYPE;
l_Burdened_Cost_Flag       PA_Budget_Entry_Methods.Burdened_Cost_Flag%TYPE;
l_Entry_Level_Code         PA_Budget_Entry_Methods.Entry_Level_Code%TYPE;
l_Resource_List_Member_ID  PA_Resource_List_Members.Resource_List_Member_ID%TYPE;
l_CCID                     GL_Code_Combinations.Code_Combination_ID%TYPE;
l_New_CCID                 GL_Code_Combinations.Code_Combination_ID%TYPE;

--
l_Set_Of_Books_ID             GL_Sets_Of_Books.Set_Of_Books_ID%TYPE;
l_Cur_Yr_Last_Prd_Name        GL_Periods.Period_Name%TYPE;
l_Cur_Yr_First_Prd_Start_Dt   GL_Periods.Start_Date%TYPE;
l_Cur_Yr_Last_Prd_Start_Dt    GL_Periods.Start_Date%TYPE;
l_Cur_Yr_Last_Prd_End_Dt      GL_Periods.End_Date%TYPE;
l_Next_Yr_First_Prd_Name      GL_Periods.Period_Name%TYPE;
l_Next_Yr_First_Prd_Start_Dt  GL_Periods.Start_Date%TYPE;
l_Next_Yr_First_Prd_End_Dt    GL_Periods.End_Date%TYPE;


l_Return_Status               VARCHAR2(100);
l_Msg_Count                   NUMBER;
l_Msg_Data                    VARCHAR2(2000);

l_Err_Code                    NUMBER;
l_Err_Stage                   VARCHAR2(200);
l_Err_Stack                   VARCHAR2(200);
l_balance_type                PA_Budgetary_Control_Options.Balance_Type%type;
l_cc_budget_type_code         PA_Budgetary_Control_Options.Budget_Type_Code%type;

-- Local Exception Variables
l_IU_Bdgt_Line_ERR            EXCEPTION;
l_Lock_Bdgt_Err               EXCEPTION;
l_Get_Res_Assign_Err          EXCEPTION;
l_PA_BC_GL_FCK_ERR            EXCEPTION;
l_PA_BC_CC_FCK_ERR            EXCEPTION;
l_SUBMIT_BASELINE_ERR         EXCEPTION;
l_IU_Bdgt_Acct_Err            EXCEPTION;
l_cbc_not_supported           EXCEPTION;

-------------------------------------------------------------------------------------
-- Cursor to fetch all the eligible Budget versions that are required to be
-- processed for Year End Budget Rollover process
-------------------------------------------------------------------------------------
CURSOR C1_BUDGET IS
  SELECT
    PROJ.project_id            Project_ID,
    PROJ.Project_Status_Code   Project_Status_Code,
    PROJ.Completion_Date       Project_Completion_Date,
    BV.budget_version_id       Budget_Version_ID,
    BV.budget_type_code        Budget_Type_Code,
    BCO.Encumbrance_Type_ID    Encumbrance_Type_ID,
    BCO.External_Budget_Code   External_Budget_Code,
    BCO.GL_Budget_Version_ID   GL_Budget_Version_ID,
    BEM.Raw_Cost_Flag          Raw_Cost_Flag,
    BEM.Burdened_Cost_Flag     Burdened_Cost_Flag,
    BEM.Entry_Level_Code       Entry_Level_Code,
    BCO.Balance_type           Balance_Type
  FROM
    PA_Budgetary_Control_Options BCO,
    PA_Projects                  PROJ,
    PA_Budget_Versions           BV,
    PA_Budget_Entry_Methods      BEM
  WHERE
      PROJ.Carrying_Out_organization_id  =
	     NVL(P_Organization_ID, PROJ.Carrying_Out_organization_id )
  AND ( P_From_Project_Number IS NULL OR PROJ.Segment1 >= P_From_Project_Number )
  AND ( P_To_Project_Number   IS NULL OR PROJ.Segment1 <= P_To_Project_Number )
  AND  nvl(PROJ.template_flag,'N') <> 'Y'
  -- AND PROJ.project_status_code    <> 'CLOSED'
  AND PROJ.Project_ID             = BV.Project_ID
  AND BV.Project_ID               = BCO.Project_ID
  AND BV.Budget_Type_Code         = BCO.Budget_Type_Code
  AND BV.Budget_Status_Code       = 'B'                      -- Baselined ONLY Budget
  AND BV.Current_Flag             = 'Y'                      -- Latest Budget Version
  AND BV.Budget_Entry_Method_Code = BEM.Budget_Entry_Method_Code
  AND BCO.Balance_Type            = 'E'
  AND nvl(BCO.Yr_End_Rollover_Year,-1) <> P_Closing_Year;

-------------------------------------------------------------------------------------
-- Cursor to fetch all the eligible Budget Lines that are required to be
-- processed for Year End Budget Rollover process
-------------------------------------------------------------------------------------
CURSOR C2_BUDGET_LINES IS
  SELECT
    BCBL.Resource_List_Member_ID        Resource_List_Member_ID,
    BCBL.Project_ID                     Project_ID,
    /* Commented out for bug 2838796 BCBL.Task_ID                        Task_ID, */
    RA.Task_ID                        Task_ID, --Changed to RA.Task_Id bug 2838796
    BL.Code_Combination_ID              CCID,
    SUM(BCBL.Budget_Period_To_Date -
	( BCBL.Actual_Period_To_Date + BCBL.Encumb_Period_To_Date) ) Transfer_Amount,
    MAX(BL.START_DATE) Budget_period_start_date
  FROM
    PA_Resource_Assignments RA,
    PA_Budget_Lines         BL,
    PA_BC_Balances          BCBL
  WHERE
      RA.Budget_Version_ID      = l_Bslnd_Budget_Version_ID
  AND RA.Resource_Assignment_ID = BL.Resource_Assignment_ID
  AND BCBL.Start_Date           = BL.Start_Date
  AND RA.Resource_List_Member_ID= BCBL.Resource_List_Member_ID
  AND RA.Budget_Version_ID      = BCBL.Budget_Version_ID
  AND RA.Project_ID             = BCBL.Project_ID
  -- AND NVL(RA.Task_ID, 0)        = BCBL.Task_ID   -- bug 2838796
  AND ( (BCBL.Balance_Type = 'BGT' and RA.Task_ID = BCBL.Task_ID ) --bug 2838796 added start
      OR
      ( BCBL.Balance_Type <> 'BGT' AND
        (( RA.Task_ID = Decode(l_Entry_Level_Code, 'P', 0,
                                                'T', BCBL.Top_Task_ID,
                                                'L', BCBL.Task_ID ))
          OR
         ( l_Entry_Level_Code =  'M' AND
           RA.Task_ID IN ( BCBL.Top_Task_ID, BCBL.Task_ID )
        ))
      )
      )         --bug 2838796 added ends
  AND BCBL.Start_Date BETWEEN l_Cur_Yr_First_Prd_Start_Dt
                      AND     l_Cur_Yr_Last_Prd_Start_Dt
  AND BCBL.Set_Of_Books_ID      = l_Set_Of_Books_ID
  AND BCBL.Start_Date IN ( SELECT A.Start_Date
			   FROM   GL_Period_Statuses A
                           WHERE
                               A.application_id  = 101
                           AND A.set_of_books_id = l_Set_Of_Books_ID
                           AND A.Period_Year     = P_Closing_year
                           AND A.Adjustment_Period_Flag <> 'Y'
                           AND A.Period_Type     = l_Accounted_Period_Type
			 )
  GROUP BY
     BCBL.Resource_List_Member_ID,
     BCBL.Project_ID,
    /*  BCBL.Task_ID, commented out for bug 2838796 */
     RA.Task_ID,
     BL.Code_Combination_ID
  HAVING SUM(BCBL.Budget_Period_To_Date -
	( BCBL.Actual_Period_To_Date + BCBL.Encumb_Period_To_Date) ) > 0;

BEGIN -- Begin of executing the Year End Budget Rollover process

  g_procedure_name := 'Year_End_Rollover';
  -----------------------------------------------------------------------------------+
  -- Get the Set of Books ID from PA_Implementations
  -----------------------------------------------------------------------------------+
  IF P_DEBUG_MODE = 'Y' THEN
     log_message('Year_End_Rollover: ' || 'Started the Process');
     --log_message('Year_End_Rollover: '||'DebugChange 03/17/2003 bug 2838796');
  END IF;

  -----------------------------------------------------------------------------------+
  -- Invoke the Sweeper process to sweep all the encumbrance etries
  -- from PA_BC_PACKETS to PA_BC_BALANCES
  -----------------------------------------------------------------------------------+
    PA_Sweeper.Update_Act_Enc_Balance (
      X_Return_Status              => l_Return_Status,
      X_Error_Message_Code         => l_Msg_Data
    );

    IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
      IF P_DEBUG_MODE = 'Y' THEN
         PA_Fck_Util.debug_msg('Year_End_Rollover: ' || 'Error occured while running sweeper process PA_Sweeper.Update_Act_Enc_Balance');
         PA_Fck_Util.debug_msg('Year_End_Rollover: ' || 'Action: Contact Oracle support team');
         PA_Fck_Util.debug_msg('Year_End_Rollover: ' || 'X_Error_Message_Code:'||l_Msg_Data);
      END IF;
      RETURN;
    END IF;

  -- # Get Ledger_id
    SELECT Set_Of_Books_ID
    INTO   l_Set_Of_Books_ID
    FROM   PA_Implementations;

  IF P_DEBUG_MODE = 'Y' THEN
     log_message('Year_End_Rollover: ' || 'Request ID        : '|| P_Request_ID);
     log_message('Year_End_Rollover: ' || 'Set of Books ID   : '|| l_Set_Of_Books_ID);
     log_message('Year_End_Rollover: ' || 'Organization ID   : '|| P_Organization_ID);
  END IF;

    SELECT Accounted_Period_Type
    INTO   l_Accounted_Period_Type
    FROM   GL_Sets_Of_Books
    WHERE  Set_Of_Books_ID = l_Set_Of_Books_ID ;

  IF P_DEBUG_MODE = 'Y' THEN
     log_message('Year_End_Rollover: ' || 'Accounted Period Type : ' || l_Accounted_Period_Type);
  END IF;

  -----------------------------------------------------------------------------------+
  -- Fetch the first/last period details for a given closing fiscal year and
  -- first period details of a next year
  -----------------------------------------------------------------------------------+
  Get_Period_Details (
    P_Fiscal_Year                => P_Closing_year,
    P_Set_Of_Books_ID            => l_Set_Of_Books_ID,
    P_Accounted_Period_Type      => l_Accounted_Period_Type,
    X_Cur_Yr_Last_Prd_Name       => l_Cur_Yr_Last_Prd_Name,
    X_Cur_Yr_First_Prd_Start_Dt  => l_Cur_Yr_First_Prd_Start_Dt,
    X_Cur_Yr_Last_Prd_Start_Dt   => l_Cur_Yr_Last_Prd_Start_Dt,
    X_Cur_Yr_Last_Prd_End_Dt     => l_Cur_Yr_Last_Prd_End_Dt,
    X_Next_Yr_First_Prd_Name     => l_Next_Yr_First_Prd_Name,
    X_Next_Yr_First_Prd_Start_Dt => l_Next_Yr_First_Prd_Start_Dt,
    X_Next_Yr_First_Prd_End_Dt   => l_Next_Yr_First_Prd_End_Dt,
    X_Return_Status              => l_Return_Status,
    X_Msg_Count                  => l_Msg_Count,
    X_Msg_Data                   => l_Msg_Data
  );

  IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN -- Need to test carefully
    X_Msg_Count     := l_Msg_Count;
    X_Msg_Data      := l_Msg_Data;
    X_Return_Status := l_Return_Status;

    g_procedure_name := 'Year_End_Rollover';

    log_message('Year_End_Rollover: '||'Get_Period_Details-> Error: X_Msg_Data  : ' || l_Msg_Data);

    FND_MSG_PUB.add_Exc_msg( P_Pkg_Name       => 'PA_Year_End_Rollover_PKG',
			     P_Procedure_Name => 'Get_Period_Details');
    RETURN;
  END IF;

  IF P_DEBUG_MODE = 'Y' THEN
     g_procedure_name := 'Year_End_Rollover';
     log_message('Year_End_Rollover: ' || 'Executed Get_Period_Details API');
  END IF;

  -----------------------------------------------------------------------------------+
  -- Loop thru all the eligible budget versions
  -----------------------------------------------------------------------------------+
  FOR C1 IN C1_BUDGET
  LOOP
    BEGIN

      IF P_DEBUG_MODE = 'Y' THEN
         log_message('Year_End_Rollover: ' || 'Total Count in Cursor C1 : ' || C1_Budget%ROWCOUNT );
      END IF;

      -- Fetch cursor values into local variables (Re-Initialize)
      l_Project_ID              := C1.Project_ID;
      l_Project_Status_Code     := C1.Project_Status_Code;
      l_Project_Completion_Date := C1.Project_Completion_Date;
      l_Budget_Type_Code        := C1.Budget_Type_Code;
      l_Bslnd_Budget_Version_ID := C1.Budget_Version_ID;
      l_Encumbrance_Type_ID     := C1.Encumbrance_Type_ID;
      l_External_Budget_Code    := C1.External_Budget_Code;
      l_GL_Budget_Version_ID    := C1.GL_Budget_Version_ID;
      l_Raw_Cost_Flag           := C1.Raw_Cost_Flag;
      l_Burdened_Cost_Flag      := C1.Burdened_Cost_Flag;
      l_Entry_Level_Code        := C1.Entry_Level_Code;
      l_Balance_Type            := C1.Balance_Type;

      IF P_DEBUG_MODE = 'Y' THEN
         log_message('Year_End_Rollover: ' || '--');
         log_message('Year_End_Rollover: ' || 'Budget Version Details  :');
         log_message('Year_End_Rollover: ' || '-------------------------');
         log_message('Year_End_Rollover: ' || 'Project ID              :' || l_Project_ID );
         log_message('Year_End_Rollover: ' || 'Project Status Code     :' || l_Project_Status_Code );
         log_message('Year_End_Rollover: ' || 'Project Completion Date :' || l_Project_Completion_Date );
         log_message('Year_End_Rollover: ' || 'Budget Type Code        :' || l_Budget_Type_Code );
         log_message('Year_End_Rollover: ' || 'Baselined Budget Ver ID :' || l_Bslnd_Budget_Version_ID );
         log_message('Year_End_Rollover: ' || 'Encumbrance Type ID     :' || l_Encumbrance_Type_ID );
         log_message('Year_End_Rollover: ' || 'External Budget Code    :' || l_External_Budget_Code );
         log_message('Year_End_Rollover: ' || 'GL Budget Version ID    :' || l_GL_Budget_Version_ID );
         log_message('Year_End_Rollover: ' || 'Raw Cost Flag           :' || l_Raw_Cost_Flag );
         log_message('Year_End_Rollover: ' || 'Burdened Cost Flag      :' || l_Burdened_Cost_Flag );
         log_message('Year_End_Rollover: ' || 'Budget Entry Level Code :' || l_Entry_Level_Code );
         log_message('Year_End_Rollover: ' || 'Balance Type            :' || l_Balance_Type );
      END IF;

 -----------------------------------------------+
 -- 1.1: Disabling CBC ...
 -----------------------------------------------+
 If nvl(l_Budget_Type_Code,'GL') = 'CC' then
       RAISE l_cbc_not_supported;
 End If;

 -- For GL Budget associated to a project with Dual budget enabled
 If nvl(l_balance_type,'B') = 'E' then
   Begin
     select 'CC'
     into   l_cc_budget_type_code
     from   pa_budgetary_control_options cc
     where  cc.project_id = l_Project_ID
     and    cc.external_budget_code = 'CC';
   Exception
     When no_data_found then
          l_cc_budget_type_code := null;
     When too_many_rows then
          -- This has been added to handle case if multiple
          -- budget types could be added 'cause of issue with
          -- PABDINTG form
          l_cc_budget_type_code := 'CC';
   End;

   If nvl(l_cc_budget_type_code,'GL') = 'CC' then
       RAISE l_cbc_not_supported;
   End If;
 End If;

      -- Re-Initialise user lock name
      l_lock_Name    := 'YRENDRLVR:'||l_Project_ID||':'||l_Budget_Type_Code ;
      l_First_Time_Entry := TRUE;

      l_Total_Rollover_Amount := 0 ;
      l_Proceed_Flag := FALSE;  /* 2699417 */

      log_message('Year_End_Rollover: '||'Lock Name inside C1 :' || l_lock_Name );

      FOR C2 IN C2_BUDGET_LINES
      LOOP

        log_message('Year_End_Rollover: '||'Total Count in Cursor C2 : ' ||  C2_BUDGET_LINES%ROWCOUNT );
        log_message('Year_End_Rollover: ' || '-------------------------');
        log_message('Year_End_Rollover: Resource_List_Member_ID:' || C2.Resource_List_Member_ID);
        log_message('Year_End_Rollover: Task_ID:' || C2.Task_ID);
        log_message('Year_End_Rollover: Code_Combination_ID:' || C2.ccid);
        log_message('Year_End_Rollover: Transfer_Amount:' || C2.Transfer_Amount);
        log_message('Year_End_Rollover: Budget_period_start_date:' || C2.Budget_period_start_date);
        log_message('Year_End_Rollover: ' || '-------------------------');


        l_Message_Code_Error := NULL;

	-- Check for project status
        IF (l_Project_Status_Code = 'CLOSED' OR
	   l_Project_Completion_Date < l_Next_Yr_First_Prd_Start_Dt) THEN

	  l_Message_Code_Error := 'PA_BC_PROJ_CLOSED';
	  l_Proceed_Flag       := FALSE; -- Not to proceed for further processing

	  IF P_DEBUG_MODE = 'Y' THEN
	     log_message('Year_End_Rollover: ' || 'Exiting from Inside Project Status is closed');
	  END IF;

	  EXIT;
        END IF;

        IF l_Project_Completion_Date < l_Next_Yr_First_Prd_Start_Dt THEN
	  l_Message_Code_Error := 'PA_BC_PROJ_END_DATE';
	  l_Proceed_Flag       := FALSE; -- Not to proceed for further processing

	  IF P_DEBUG_MODE = 'Y' THEN
	     log_message('Year_End_Rollover: ' || 'Exiting from Inside because of Project End Date');
	  END IF;

	  EXIT;
        END IF;

        l_Transfer_Amount := 0 ;

        BEGIN

	  IF P_DEBUG_MODE = 'Y' THEN
	     log_message('Year_End_Rollover: ' || 'Entered INTO Cursor C2');
	  END IF;

	  IF l_First_Time_Entry = TRUE THEN -- Execute only once in the begining

	    IF P_DEBUG_MODE = 'Y' THEN
	       log_message('Year_End_Rollover: ' || 'Creating / copying New Budget');
	    END IF;

            Create_Working_Budget (
                P_Project_ID             => l_Project_ID,
                P_Budget_Type_Code       => l_Budget_Type_Code,
                P_Budget_Version_ID      => l_Bslnd_Budget_Version_ID,
                P_Request_ID             => P_Request_ID,
                X_Work_Budget_Version_ID => l_Work_Budget_Version_ID,
                X_Return_Status          => l_Return_Status,
                X_Msg_Count              => l_Msg_Count,
                X_Msg_Data               => l_Msg_Data
	    );

            IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
         	 IF P_DEBUG_MODE = 'Y' THEN
                        g_procedure_name := 'Year_End_Rollover';
			log_message(g_procedure_name||':Create_Working_Budget Failed:'||l_Msg_Data);
		 END IF;

	      l_First_Time_Entry := FALSE;
      	      l_Proceed_Flag       := FALSE; /* Not to proceed for further processing in case of failure
						added for bug 2699417 */
	      EXIT; -- Exit from the inner LOOP to process the next budget version ID
	    END IF;

	    l_First_Time_Entry := FALSE; -- Make sure it won't be repeated for
                                         -- every Budget Line
          END IF;

          ---------------------------------------------------------------------------+
	  -- Re-Initialize the local variables after every fetch
          ---------------------------------------------------------------------------+
          l_Resource_List_Member_ID := C2.Resource_List_Member_ID;
          l_Task_ID                 := C2.Task_ID;
	  l_CCID                    := C2.CCID;
	  l_Transfer_Amount         := C2.Transfer_Amount;

          IF P_DEBUG_MODE = 'Y' THEN
             g_procedure_name := 'Year_End_Rollover';
             log_message('Year_End_Rollover: ' || '--------------------------------');
             log_message('Year_End_Rollover: ' || 'Budget Line Details for Budget Version '||
				   l_Work_Budget_Version_ID ||' are : ');
             log_message('Year_End_Rollover: ' || '--------------------------------');
             log_message('Year_End_Rollover: ' || 'Res List Member ID : '|| l_Resource_List_Member_ID);
             log_message('Year_End_Rollover: ' || 'Task ID            : '|| l_Task_ID);
             log_message('Year_End_Rollover: ' || 'CCID ID            : '|| l_CCID);
             log_message('Year_End_Rollover: ' || 'Transfer Amount    : '|| l_Transfer_Amount);
             log_message('Year_End_Rollover: ' || '--');
          END IF;

	  -- Calculate the unswept amounts from PA_BC_PACKETS
	  BEGIN

            -- Derive Top Task ID
            BEGIN
              SELECT Top_Task_ID
              INTO   l_Top_Task_ID
              FROM   PA_TASKS
              WHERE  Task_ID    = l_Task_ID
              AND    Project_ID = l_Project_ID ;

              IF P_DEBUG_MODE = 'Y' THEN
                 log_message('Year_End_Rollover: ' || 'PA_BC_PACKETS: Top Task ID : '|| l_Top_Task_ID );
              END IF;

            EXCEPTION
	        WHEN NO_DATA_FOUND THEN
                IF P_DEBUG_MODE = 'Y' THEN
                   log_message('Year_End_Rollover: ' || 'Top Task ID Not Found. Task : '|| l_Task_ID );
                   l_top_task_id := 0; --bug 2838796
                END IF;
            END;

            -- Derive Parent Member ID
            BEGIN
              SELECT Parent_Member_ID
              INTO   l_Parent_Member_ID
              FROM   PA_RESOURCE_LIST_MEMBERS
              WHERE  Resource_List_Member_ID = l_Resource_List_Member_ID;

                IF P_DEBUG_MODE = 'Y' THEN
                   log_message('Year_End_Rollover: ' || 'PA_BC_PACKETS: Parent Member ID : '|| l_Parent_Member_ID );
                END IF;
            EXCEPTION
	        WHEN NO_DATA_FOUND THEN
                IF P_DEBUG_MODE = 'Y' THEN
                   log_message('Year_End_Rollover: ' || 'Parent Mem ID Not Found. Res List Member ID : '||
							    l_Resource_List_Member_ID );
                END IF;
                raise; --bug 2838796
              END;

	    -- Fetch the UnSwept amount from PA_BC_PACKETS
	    l_UnSwept_Amount := 0;

	    BEGIN
              IF P_DEBUG_MODE = 'Y' THEN
                 log_message('Year_End_Rollover: ' || 'Fetching amounts from PA_BC_PACKETS');
                 log_message('Year_End_Rollover: ' || 'Budget_Version_ID : ' || l_Work_Budget_Version_ID );
                 log_message('Year_End_Rollover: ' || 'Project_ID        : ' || l_Project_ID );
                 log_message('Year_End_Rollover: ' || 'Top_Task_ID       : ' || l_Top_Task_ID );
              END IF;

	      SELECT
		SUM(Accounted_DR - Accounted_CR)
              INTO
		l_UnSwept_Amount
              FROM
		PA_BC_PACKETS
              WHERE
		  Budget_Version_ID    = l_Bslnd_Budget_Version_ID
              AND Project_ID           = l_Project_ID
--            AND nvl(Top_Task_ID,0)   = l_Top_Task_ID             --bug 2838796 start change
              AND (( nvl(l_Task_ID,0) = Decode(l_Entry_Level_Code, 'P', 0,
                                                'T', Top_Task_ID,
                                                'L', Task_ID ))
                OR
               ( l_Entry_Level_Code =  'M' AND
                 l_Task_ID IN ( Top_Task_ID, Task_ID )))            --bug 2838796 end  change
	      AND Status_Code          = 'A'        -- Approved Transactions
	      AND Balance_Posted_Flag  = 'N'        -- Not yet posted/swept
	      AND Result_Code          like 'P%'    -- Pass Code series
	      AND Resource_List_Member_ID = l_Resource_List_Member_ID
	      AND Parent_Resource_ID   = l_Parent_Member_ID ;
	    END;

            IF P_DEBUG_MODE = 'Y' THEN
               log_message('Year_End_Rollover: ' || 'l_UnSwept_Amount = '|| l_UnSwept_Amount );
            END IF;

	  END;

	  --
	  -- Add the unswept amounts to the original transferred amount
	  --
	  l_Transfer_Amount := NVL(l_Transfer_Amount,0) - NVL(l_UnSwept_Amount,0);

          ---------------------------------------------------------------------------+
          -- Get the Resource Assignment ID for the working Budget Version
          ---------------------------------------------------------------------------+
          IF P_DEBUG_MODE = 'Y' THEN
             log_message('Year_End_Rollover: ' || 'Work Budget Ver ID  : '|| l_Work_Budget_Version_ID);
          END IF;

          BEGIN
            SELECT
              RA.Resource_Assignment_ID
            INTO
              l_Work_Resource_Assign_ID
            FROM
	      PA_Budget_Versions      BV,
              PA_Resource_Assignments RA
            WHERE
                RA.resource_list_member_id = l_Resource_List_Member_ID
            AND RA.Budget_Version_ID       = l_Work_Budget_Version_ID
            AND RA.Project_ID              = l_Project_ID
            AND RA.Task_ID                 = l_Task_ID
	    AND BV.Budget_Status_Code      = 'W'
	    AND BV.Budget_Version_ID    = RA.Budget_Version_ID
	    AND BV.Project_ID           = RA.Project_ID
	    AND BV.Project_ID           = l_Project_ID;
            EXCEPTION
	      WHEN NO_DATA_FOUND THEN
                IF P_DEBUG_MODE = 'Y' THEN
                   log_message('Year_End_Rollover: ' || 'Res Assignment ID Not Found');
                END IF;
	        RAISE l_Get_Res_Assign_ERR;
          END;

          IF P_DEBUG_MODE = 'Y' THEN
             log_message('Year_End_Rollover: ' || 'Res Assignment ID  : '|| l_Work_Resource_Assign_ID);
             log_message('Year_End_Rollover: ' || '--');
          END IF;

          ------------------------------------------------------------------------------------+
          -- Update the last period (where the account exists) of closing year budget line for
	  -- the fetched Budget Version ID
          ------------------------------------------------------------------------------------+
          IF P_DEBUG_MODE = 'Y' THEN
             log_message('Year_End_Rollover: ' || 'API Executing : Upd_Ins_Budget_Line ');
             log_message('Year_End_Rollover: ' || '--');
          END IF;

          l_new_ccid := null;

          Upd_Ins_Budget_Line (
              P_Budget_Version_ID       => l_Work_Budget_Version_ID,
              P_Budget_Type_Code        => l_Budget_Type_Code,
              P_Resource_Assignment_ID  => l_Work_Resource_Assign_ID,
              P_Period_Name             => NULL,
              P_Period_Start_Date       => C2.Budget_Period_Start_Date,
              P_Period_End_Date         => NULL,
              P_Transfer_Amount         => (-1)*l_Transfer_Amount,
              P_Project_ID              => l_Project_ID,
              P_Task_ID                 => l_Task_ID,
              P_Resource_List_Member_ID => l_Resource_List_Member_ID,
              P_Raw_Cost_Flag           => l_Raw_Cost_Flag,
              P_Burdened_Cost_Flag      => l_Burdened_Cost_Flag,
              P_CCID                    => l_CCID,
	      P_Request_ID              => P_Request_ID,
	      P_Period_New_or_Closing   => 'CLOSING',
              P_New_CCID                => l_new_ccid,
              X_Return_Status           => l_Return_Status,
              X_Msg_Count               => l_Msg_Count,
              X_Msg_Data                => l_Msg_Data
          );

          IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
             log_message('Year_End_Rollover: Old period: Upd_Ins_Budget_Line failed:'||l_Msg_Data);
            g_procedure_name := 'Year_End_Rollover';
	    RAISE l_IU_Bdgt_Line_ERR;
          END IF;

          IF P_DEBUG_MODE = 'Y' THEN
             g_procedure_name := 'Year_End_Rollover';
             log_message('Year_End_Rollover: ' || 'API Executing : Upd_Ins_Budget_Line - SUCCESSFUL');
             log_message('Year_End_Rollover: ' || '--');
          END IF;
	  -- End of Updating the last period Budget Line Record

         ---------------------------------------------------------------------------
          -- Update the last period of closing year budget account line
	  -- for all the fetched Budget Version IDs
          ---------------------------------------------------------------------------
          IF P_DEBUG_MODE = 'Y' THEN
             log_message('Year_End_Rollover: ' || 'API Executing : Upd_Ins_Budget_Acct_Line ');
             log_message('Year_End_Rollover: ' || '--');
          END IF;
          Upd_Ins_Budget_Acct_Line (
              P_Budget_Version_ID  => l_Work_Budget_Version_ID,
              P_Period_Name        => NULL,
              P_Period_Start_Date  => C2.Budget_Period_Start_Date,
              P_Period_End_Date    => NULL,
              P_Transfer_Amount    => (-1)*l_Transfer_Amount,
              P_CCID               => l_CCID,
	      P_Request_ID         => P_Request_ID,
              X_Return_Status      => l_Return_Status,
              X_Msg_Count          => l_Msg_Count,
              X_Msg_Data           => l_Msg_Data
          );

          IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS
          THEN
            log_message('Year_End_Rollover: Old period: Upd_Ins_Budget_Acct_Line failed:'||l_Msg_Data);
            g_procedure_name := 'Year_End_Rollover';
            RAISE l_IU_Bdgt_Acct_ERR;
          END IF ;

          IF P_DEBUG_MODE = 'Y' THEN
             g_procedure_name := 'Year_End_Rollover';
             log_message('Year_End_Rollover: ' || 'API Executing : Upd_Ins_Budget_Acct_Line - SUCCESSFUL');
             log_message('Year_End_Rollover: ' || '--');
          END IF;
	  -- End of Updating the last period Budget Account Line Record

          ---------------------------------------------------------------------------+
          -- Update the first period of next year budget line for all
	  -- the fetched Budget Version IDs
          ---------------------------------------------------------------------------+
          IF P_DEBUG_MODE = 'Y' THEN
             log_message('Year_End_Rollover: ' || 'API Executing : Upd_Ins_Budget_Line ');
             log_message('Year_End_Rollover: ' || '--');
          END IF;

          l_new_ccid := null;

          Upd_Ins_Budget_Line (
              P_Budget_Version_ID       => l_Work_Budget_Version_ID,
              P_Budget_Type_Code        => l_Budget_Type_Code,
              P_Resource_Assignment_ID  => l_Work_Resource_Assign_ID,
              P_Period_Name             => l_Next_Yr_First_Prd_Name,
              P_Period_Start_Date       => l_Next_Yr_First_Prd_Start_Dt,
              P_Period_End_Date         => l_Next_Yr_First_Prd_End_Dt,
              P_Transfer_Amount         => l_Transfer_Amount,
              P_Project_ID              => l_Project_ID,
              P_Task_ID                 => l_Task_ID,
              P_Resource_List_Member_ID => l_Resource_List_Member_ID,
              P_Raw_Cost_Flag           => l_Raw_Cost_Flag,
              P_Burdened_Cost_Flag      => l_Burdened_Cost_Flag,
              P_CCID                    => l_CCID,
	      P_Request_ID              => P_Request_ID,
	      P_Period_New_Or_Closing   => 'NEW',
              P_New_CCID                => l_new_ccid,
              X_Return_Status           => l_Return_Status,
              X_Msg_Count               => l_Msg_Count,
              X_Msg_Data                => l_Msg_Data
          );

          IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
            log_message('Year_End_Rollover: New period: Upd_Ins_Budget_Line failed:'||l_Msg_Data);
             g_procedure_name := 'Year_End_Rollover';
	    RAISE l_IU_Bdgt_Line_ERR;
          END IF;

          IF P_DEBUG_MODE = 'Y' THEN
             g_procedure_name := 'Year_End_Rollover';
             log_message('Year_End_Rollover: ' || 'API Executing : Upd_Ins_Budget_Line - SUCCESSFUL');
             log_message('Year_End_Rollover: ' || '--');
          END IF;
	  -- End of Updating the first period Budget Line Record

         ---------------------------------------------------------------------------
         -- Update the first period of next year budget account line
	     -- for all the fetched Budget Version IDs
         ---------------------------------------------------------------------------
          If l_new_ccid is not null and l_new_ccid <> l_CCID then
              -- This can happen if there is a line already existing
              -- for RAID/Start Date/Currency combo with a diff CCID
             l_CCID := l_new_ccid;
          End If;

         ---------------------------------------------------------------------------
          -- Update the first period of next year budget account line
	  -- for all the fetched Budget Version IDs
          ---------------------------------------------------------------------------
          Upd_Ins_Budget_Acct_Line (
              P_Budget_Version_ID => l_Work_Budget_Version_ID,
              P_Period_Name       => l_Next_Yr_First_Prd_Name,
              P_Period_Start_Date => l_Next_Yr_First_Prd_Start_Dt,
              P_Period_End_Date   => l_Next_Yr_First_Prd_End_Dt,
              P_Transfer_Amount   => l_Transfer_Amount,
              P_CCID              => l_CCID,
	      P_Request_ID        => P_Request_ID,
              X_Return_Status     => l_Return_Status,
              X_Msg_Count         => l_Msg_Count,
              X_Msg_Data          => l_Msg_Data
          );

          IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS
          THEN
            log_message('Year_End_Rollover: New period: Upd_Ins_Budget_Acct_Line failed:'||l_Msg_Data);
             g_procedure_name := 'Year_End_Rollover';
	    RAISE l_IU_Bdgt_Acct_ERR;
          END IF;

          IF P_DEBUG_MODE = 'Y' THEN
             g_procedure_name := 'Year_End_Rollover';
             log_message('Year_End_Rollover: ' || 'API : Upd_Ins_Budget_Acct_Line - SUCCESSFUL');
             log_message('Year_End_Rollover: ' || '--');
          END IF;
	  -- End of Updating the last period Budget Account Line Record

          -- Accumulate the Rollover Amount
          l_Total_Rollover_Amount := nvl(l_Total_Rollover_Amount,0) + nvl(l_Transfer_Amount,0) ;

	  IF P_DEBUG_MODE = 'Y' THEN
	     log_message ('Year_End_Rollover: ' ||  'Cumulative Amount : ' || l_Total_Rollover_Amount );
	  END IF;

	  l_Proceed_Flag := TRUE;

        EXCEPTION
	  WHEN l_Get_Res_Assign_Err THEN
	    l_Proceed_Flag := FALSE;
            Year_End_Rollover_Log (
                 P_Budget_Version_ID => l_Work_Budget_Version_Id,
                 P_Message_Name      => 'PA_BC_GET_RES_ASSIGN_ERR',
                 P_Request_ID        => P_Request_ID,
                 P_Lock_Name         => l_Lock_Name );

           WHEN l_IU_Bdgt_Line_Err   THEN
	    l_Proceed_Flag := FALSE;
            Year_End_Rollover_Log (
                 P_Budget_Version_ID => l_Work_Budget_Version_Id,
                 P_Message_Name      => 'PA_BC_IU_BDGT_LINE_ERR',
                 P_Request_ID        => P_Request_ID,
                 P_Lock_Name         => l_Lock_Name );

           WHEN l_IU_Bdgt_Acct_Err   THEN
	    l_Proceed_Flag := FALSE;
            Year_End_Rollover_Log (
                 P_Budget_Version_ID => l_Work_Budget_Version_Id,
                 P_Message_Name      => upper('pa_bc_IU_Bdgt_Acct_Err'),
                 P_Request_ID        => P_Request_ID,
                 P_Lock_Name         => l_Lock_Name );

        END; -- End of processing one set (Last/First period) of Budget Line
      END LOOP ; -- End of reading all the Budget Lines, end of loop C2;

    IF l_Proceed_Flag = TRUE THEN

         COMMIT;
         -- # This commit is required so that the following call to account generator which is an
         -- # autonomous procedure will be able to query the working budget's budget lines ..

         -- # Call Account generator to generate accounts on all the new lines
         -- # that were created, calling it in 'Submit Mode'
         -- # This call is being made so that the working budget will also have all ccid's

       PA_BUDGET_ACCOUNT_PKG.Gen_Account (
       P_Budget_Version_ID     => l_Work_Budget_Version_Id,
       P_Calling_Mode          => 'SUBMIT',
       X_Return_Status         => l_return_status,
       X_Msg_Count             => l_msg_count,
       X_Msg_Data              => l_msg_data) ;

       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
          l_Proceed_Flag := FALSE;
          Year_End_Rollover_Log (
                 P_Budget_Version_ID => l_Work_Budget_Version_Id,
                 P_Message_Name      => 'PA_BC_GEN_FAI_ACCT',
                 P_Request_ID        => P_Request_ID,
                 P_Lock_Name         => l_Lock_Name );
       END IF;

	-- Commit the working budget
	COMMIT;

        -- ## Submit Budget
        IF P_DEBUG_MODE = 'Y' THEN
           log_message('Year_End_Rollover: ' || 'API Executing : PA_Budget_Utils2.Submit_Budget');
           log_message('Year_End_Rollover: ' || '--');
        END IF;

        PA_Budget_Utils2.Submit_Budget (
            X_Budget_Version_ID => l_Work_Budget_Version_ID,
            X_Err_Code          => l_Err_Code,
            X_Err_Stage         => l_Err_Stage,
            X_Err_Stack         => l_Err_Stack
        );

        IF l_Err_Code <> 0 THEN
          log_message('Year_End_Rollover: Submit Budget failed: l_Err_Code['||l_Err_Code||'] l_Err_Stage['||l_Err_Stage||']');
          log_message('Year_End_Rollover: Submit Budget failed: l_Err_Stack['||l_Err_Stack||']');
          ROLLBACK;
	  l_Message_Name := 'PA_BC_SBMT_BDGT_ERR';
	  RAISE l_SUBMIT_BASELINE_ERR;
        END IF;

        IF P_DEBUG_MODE = 'Y' THEN
           log_message('Year_End_Rollover: ' || 'API : PA_Budget_Utils2.Submit_Budget - SUCCESSFUL');
           log_message('Year_End_Rollover: ' || '--');
        END IF;
	-- End of submitting the modified Budget Version

        -- # Baseline the draft budget
        IF P_DEBUG_MODE = 'Y' THEN
           log_message('Year_End_Rollover: ' || 'API Executing : PA_Budget_Core.Baseline');
           log_message('Year_End_Rollover: ' || '--');
        END IF;

        PA_Budget_Core.Baseline(
            X_Draft_Version_ID    => l_Work_Budget_Version_ID,
            X_Mark_as_Original    => 'N',
            X_Verify_Budget_Rules => 'N',
            X_Err_Code            => l_Err_Code,
            X_Err_Stage           => l_Err_Stage,
            X_Err_Stack           => l_Err_Stack
        );

        IF l_Err_Code <> 0 THEN
          log_message('Year_End_Rollover: Baseline Budget failed: l_Err_Code['||l_Err_Code||'] l_Err_Stage['||l_Err_Stage||']');
          log_message('Year_End_Rollover: Baseline Budget failed: l_Err_Stack['||l_Err_Stack||']');
          ROLLBACK;
	  l_Message_Name := 'PA_BC_BASLN_BDGT_ERR';
	  RAISE l_SUBMIT_BASELINE_ERR;
        END IF;

        IF P_DEBUG_MODE = 'Y' THEN
           log_message('Year_End_Rollover: ' || 'API Executing : PA_Budget_Core.Baseline - SUCCESSFUL');
           log_message('Year_End_Rollover: ' || '--');
        END IF;
	-- End of Baselining the submitted Budget Version

	-- Get the latest Baselined Budget Version ID
	BEGIN
	  SELECT Budget_Version_ID
          INTO   l_New_Budget_Version_ID
          FROM   PA_Budget_Versions
          WHERE Project_ID         = l_Project_ID
          AND Budget_Type_Code   = l_Budget_Type_Code
	  AND Current_Flag       = 'Y'
	  AND Budget_Status_Code = 'B';

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
	    ROLLBACK;
	    l_Message_Name := 'PA_BC_BASLN_BDGT_ERR';
	    RAISE l_SUBMIT_BASELINE_ERR;
	END;

       -- ## Call Budget account generator ..to insert the zero $ budget lines (for missed GL periods)
       -- ## and generate the acccount for these lines
       -- ## Note: Use Gen_Acct_All_Lines which is a non-autonomous procedure as the
       -- ## baselined budget is not saved yet.

       PA_BUDGET_ACCOUNT_PKG.Gen_Acct_All_Lines (
                P_Budget_Version_ID       => l_New_Budget_Version_ID,
                P_Calling_Mode            => 'BASELINE' ,
                P_Budget_Type_Code        => l_Budget_Type_Code,
                P_Budget_Entry_Level_Code => l_Entry_Level_Code,
                P_Project_ID              => l_Project_ID,
                X_Return_Status           => l_return_status,
                X_Msg_Count               => l_msg_count,
                X_Msg_Data                => l_msg_data) ;

       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
          ROLLBACK;
          l_Message_Name := 'PA_BC_GEN_FAI_ACCT';
          RAISE l_SUBMIT_BASELINE_ERR;
       END IF;

        ---------------------------------------------------------------------------+
        -- Rework the budget to bring the updated budget details in Working mode
        ---------------------------------------------------------------------------+
        IF P_DEBUG_MODE = 'Y' THEN
           log_message('Year_End_Rollover: ' || 'API Executing : PA_Budget_Utils2.Rework_Budget');
           log_message('Year_End_Rollover: ' || '--');
        END IF;

        PA_Budget_Utils2.Rework_Budget (
            X_Budget_Version_ID   => l_Work_Budget_Version_Id,
            X_Err_Code            => l_Err_Code,
            X_Err_Stage           => l_Err_Stage,
            X_Err_Stack           => l_Err_Stack
        );

        IF l_Err_Code <> 0 THEN
          log_message('Year_End_Rollover: Rework Budget failed: l_Err_Code['||l_Err_Code||'] l_Err_Stage['||l_Err_Stage||']');
          log_message('Year_End_Rollover: Rework Budget failed: l_Err_Stack['||l_Err_Stack||']');
          ROLLBACK;
	  l_Message_Name := 'PA_BC_RWRK_BDGT_ERR';
	  RAISE l_SUBMIT_BASELINE_ERR;
        END IF;

        IF P_DEBUG_MODE = 'Y' THEN
           log_message('Year_End_Rollover: ' || 'API : PA_Budget_Utils2.Rework_Budget - SUCCESSFUL');
           log_message('Year_End_Rollover: ' || '--');
        END IF;
	-- End of Updating the modified Baselined Budget Version

        l_Return_Status := null;

        -- # Create bc balances record for the baselined version ..
        IF P_DEBUG_MODE = 'Y' THEN
           log_message('Year_End_Rollover: ' || ' Calling create_bc_balances');
        END IF;

        CREATE_BC_BALANCES(p_budget_version_id => l_New_Budget_Version_ID,
                           p_last_baselined_version_id => l_Bslnd_Budget_Version_ID,
                           p_Set_of_books_id => l_Set_Of_Books_ID,
                           p_return_status   => l_Return_Status);

        IF P_DEBUG_MODE = 'Y' THEN
            g_procedure_name := 'Year_End_Rollover';
           log_message('Year_End_Rollover: ' || ' After Calling create_bc_balances,l_Return_Status:'||l_Return_Status);
        END IF;

        IF l_Return_Status = 'E' THEN -- API returns 'S' for Success and 'E' for Failure

           ROLLBACK;

           l_Message_Name := 'PA_BC_IU_BC_BAL_ERR';
           RAISE l_SUBMIT_BASELINE_ERR;

        END IF;

        l_Return_Status := null;

        -- ## Create Accounting events and funds check
        -- Following call will do both
        IF P_DEBUG_MODE = 'Y' THEN
           log_message('Year_End_Rollover: ' || ' Calling pa_budget_fund_pkg.create_events_and_fundscheck');
           log_message('Year_End_Rollover: ' || ' Parameters: l_External_Budget_Code:'||l_External_Budget_Code||';l_New_Budget_Version_ID:'||l_New_Budget_Version_ID);
        END IF;

	PA_BUDGET_FUND_PKG.CREATE_EVENTS_AND_FUNDSCHECK
	    (P_calling_module       => 'Year_End_Rollover',
	     P_mode                 => 'Force',
	     P_External_Budget_Code => l_External_Budget_Code,
             P_budget_version_id    => l_New_Budget_Version_ID,
             P_cc_budget_version_id => NULL,
             P_result_code          => l_Return_Status );

        IF P_DEBUG_MODE = 'Y' THEN
           log_message('Year_End_Rollover: ' || ' After Calling pa_budget_fund_pkg.create_events_and_fundscheck,l_Return_Status:'||l_Return_Status);
        END IF;

	IF l_Return_Status = 'E' THEN -- API returns 'S' for Success and 'E' for Failure

          ROLLBACK;

	    IF l_External_Budget_Code = 'GL' THEN
	       l_Message_Name := 'PA_BC_GL_FCK_ERR';
	       RAISE l_PA_BC_GL_FCK_ERR;
	    ELSIF l_External_Budget_Code = 'CC' THEN
	       l_Message_Name := 'PA_BC_CC_FCK_ERR';
	       RAISE l_PA_BC_CC_FCK_ERR;
	    END IF;

	END IF;

        IF P_DEBUG_MODE = 'Y' THEN
           log_message('Year_End_Rollover: ' || 'API:pa_budget_fund_pkg.create_events_and_fundscheck- SUCCESSFUL');
        END IF;
        -- End of executing "create accounting events and funds checking"

	-- Replace the Working Budget with Baselined Budget on pa_bc_commitments
        IF P_DEBUG_MODE = 'Y' THEN
           log_message('Year_End_Rollover: ' || 'Replace the Working Budget with Baselined Budget on pa_bc_commitments');
        END IF;

        UPDATE PA_BC_COMMITMENTS
        SET    Budget_Version_ID = l_New_Budget_Version_ID,
	       Request_ID        = P_Request_ID
        WHERE  Project_ID        = l_Project_ID
          AND    Budget_Version_ID = l_Bslnd_Budget_Version_ID ;

        -- Bug 5206537 : Procedure to stamp latest budget version id and budget line id on CDL and bc commitments
        PA_FUNDS_CONTROL_UTILS.Update_bvid_blid_on_cdl_bccom ( p_bud_ver_id   => l_New_Budget_Version_ID,
                                                               p_calling_mode => 'YEAR END ROLLOVER');


    END IF; -- If Proceed_flg = TRUE

        -----------------------------------------------------------------------------+
        -- Mark (update) the Budget Version as successfully carried out the
        -- Year End Budget Rollover process
        -----------------------------------------------------------------------------+
        IF P_DEBUG_MODE = 'Y' THEN
           log_message('Year_End_Rollover: ' || 'Updating amounts and flag to Budget Version');
           log_message('Year_End_Rollover: ' || '--');
        END IF;

	IF (l_Proceed_Flag = FALSE AND l_Message_Code_Error IS NOT NULL) THEN

            IF P_DEBUG_MODE = 'Y' THEN
               log_message('Year_End_Rollover: ' || 'This Project is Closed / End Date problem');
               log_message('Total Rollover amount='||l_Total_Rollover_Amount); /* added for bug 2699417 */
               log_message('P_Closing_Year='||P_Closing_Year);		/* added for bug 2699417 */
               log_message('l_Project_ID='||l_Project_ID);			/* added for bug 2699417 */
               log_message('l_Budget_Type_Code='||l_Budget_Type_Code);	/* added for bug 2699417 */
            END IF;

            UPDATE PA_Budgetary_Control_Options
            SET
  	      Yr_End_Rollover_Message = l_Message_Code_Error,
              Yr_End_Rollover_Year   = -1,
              Yr_End_Rollover_Flag   = 'E',
              Request_ID             = P_Request_ID
            WHERE
                Project_ID         = l_Project_ID
            AND Budget_Type_Code   = l_Budget_Type_Code ;

            IF SQL%ROWCOUNT = 0 THEN

	        IF P_DEBUG_MODE = 'Y' THEN
			log_message('Doing ROLLBACK after update PA_Budgetary_Control_Options');
		END IF;

	        ROLLBACK;
	        l_Message_Name := 'PA_BC_UPD_CNT_OPTN_ERR';
	        RAISE l_SUBMIT_BASELINE_ERR;
	    END IF;

            IF P_DEBUG_MODE = 'Y' THEN
               log_message('Year_End_Rollover: ' || 'Updated as Project Closed / End Date problem');
               log_message('Year_End_Rollover: ' || '--');
            END IF;

        ELSIF l_Proceed_Flag = TRUE THEN

          IF P_DEBUG_MODE = 'Y' THEN
             log_message('Year_End_Rollover: ' || 'Processing correctly');
          END IF;

            UPDATE PA_Budgetary_Control_Options
            SET
  	      Yr_End_Rollover_Amount = l_Total_Rollover_Amount,
              Yr_End_Rollover_Year   = P_Closing_Year,
              Yr_End_Rollover_Flag   = 'S',                -- successfully done
              Request_ID             = P_Request_ID,
              Yr_End_Rollover_Message= NULL
            WHERE
                Project_ID         = l_Project_ID
            AND Budget_Type_Code   = l_Budget_Type_Code ;

            IF SQL%ROWCOUNT = 0 THEN
	      ROLLBACK;
	      l_Message_Name := 'PA_BC_UPD_CNT_OPTN_ERR';
	      RAISE l_SUBMIT_BASELINE_ERR;
	    END IF;

            IF P_DEBUG_MODE = 'Y' THEN
               log_message('Year_End_Rollover: ' || 'Updated SUCCESSFULLY');
               log_message('Year_End_Rollover: ' || '--');
            END IF;
  	    -- End of updating the success result for Budget Version

	  -- Updating Change Reason for new Baselined Budget Version
          IF P_DEBUG_MODE = 'Y' THEN
             log_message('Year_End_Rollover: ' || 'Updated Budget Version Record');
          END IF;

	    l_Change_Reason_Code := 'YEAR END BUDGET ROLLOVER';
            UPDATE PA_Budget_Versions
            SET    Change_Reason_Code = l_Change_Reason_Code
            WHERE  Budget_Version_ID = l_New_Budget_Version_ID ;

            IF SQL%ROWCOUNT = 0 THEN
	      ROLLBACK;
	      l_Message_Name := 'PA_BC_UPD_BDGT_VER_ERR';
	      RAISE l_SUBMIT_BASELINE_ERR;
	    END IF;
	  -- End of updating the success result for Budget Version

/* Commenting for Bug 5726535
          -----------------------------------------------------------------------------+
          -- UnLock/Release the Budget version record that was acquired in the begining
          -----------------------------------------------------------------------------+
          IF P_DEBUG_MODE = 'Y' THEN
             log_message('Year_End_Rollover: ' || 'Releasing the lock '|| l_Lock_Name );
             log_message('Year_End_Rollover: ' || '--');
          END IF;

          l_Rel_Lock := PA_Debug.Release_User_Lock(l_Lock_Name);

          IF P_DEBUG_MODE = 'Y' THEN
             log_message('Year_End_Rollover: ' || 'Value of Release Lock '|| l_Rel_Lock );
          END IF;

          IF l_Rel_Lock <> 0 THEN
            RAISE l_Lock_Bdgt_ERR;
          END IF;
*/

        END IF; --  IF (l_Proceed_Flag = FALSE AND l_Message .....

    EXCEPTION
     WHEN l_cbc_not_supported THEN
          l_Proceed_Flag := FALSE;
           Year_End_Rollover_Log (
                P_Budget_Version_ID => l_Bslnd_Budget_Version_ID,
                P_Message_Name      => 'PA_CBC_NOT_SUPPORTED',
                P_Request_ID        => P_Request_ID,
                P_Lock_Name         => l_Lock_Name );

      WHEN l_Lock_Bdgt_Err     THEN
        X_Msg_Count     := 1;
        X_Msg_Data      := SUBSTR(SQLERRM, 1, 240);
        X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        Year_End_Rollover_Log (
              P_Budget_Version_ID => l_Work_Budget_Version_Id,
              P_Message_Name      => 'PA_BC_LOCK_BDGT_ERR',
              P_Request_ID        => P_Request_ID,
              P_Lock_Name         => l_Lock_Name );

      WHEN l_SUBMIT_BASELINE_ERR THEN
        X_Msg_Count     := 1;
        X_Msg_Data      := SUBSTR(SQLERRM, 1, 240);
        X_Return_Status := FND_API.G_RET_STS_ERROR;
        Year_End_Rollover_Log (
            P_Budget_Version_ID => l_Work_Budget_Version_Id,
            P_Message_Name      => l_Message_Name,
            P_Request_ID        => P_Request_ID,
            P_Lock_Name         => l_Lock_Name
	);

      -- Added these exceptions for Bug 2699417
      WHEN l_PA_BC_GL_FCK_ERR THEN
        Year_End_Rollover_Log (
            P_Budget_Version_ID => l_Work_Budget_Version_Id,
            P_Message_Name      => l_Message_Name,
            P_Request_ID        => P_Request_ID,
            P_Lock_Name         => l_Lock_Name
	);
      WHEN l_PA_BC_CC_FCK_ERR THEN
        Year_End_Rollover_Log (
            P_Budget_Version_ID => l_Work_Budget_Version_Id,
            P_Message_Name      => l_Message_Name,
            P_Request_ID        => P_Request_ID,
            P_Lock_Name         => l_Lock_Name
	);
	-- End of Bug fix 2699417

    END; -- End of processing single Budget Version

    COMMIT; -- Commit the all processed project budget versions

      /* added for bug 2699417 */
      l_Project_ID := null;
      l_Project_Status_Code := null;
      l_Project_Completion_Date := null;
      l_Budget_Type_Code := null;
      l_Bslnd_Budget_Version_ID := null;
      l_Encumbrance_Type_ID := null;
      l_External_Budget_Code := null;
      l_GL_Budget_Version_ID := null;
      l_Raw_Cost_Flag := null;
      l_Burdened_Cost_Flag := null;
      l_Entry_Level_Code := null;
      l_Balance_Type  := null;
      l_cc_budget_type_code := null;

  END LOOP ; -- End of reading all the Budget Versions

  COMMIT; -- Commit the whole process

  IF P_DEBUG_MODE = 'Y' THEN
     log_message('Year_End_Rollover: ' || 'X_Msg_Count : '|| X_Msg_Count );
     log_message('Year_End_Rollover: ' || 'X_Msg_Data  : '|| X_Msg_Data );
     log_message('Year_End_Rollover: ' || 'X_Return_Status  : '|| X_Return_Status );
  END IF;

  RETURN;

  EXCEPTION
    WHEN OTHERS THEN
      IF P_DEBUG_MODE = 'Y' THEN
         log_message('Year_End_Rollover: ' || 'In When Others. End');
      END IF;
/* Commenting for Bug 5726535
      l_Rel_Lock := PA_Debug.Release_User_Lock(l_Lock_Name);
*/
/* Bug 5726535 - The Year End Rollover Flag is updated to 'E' here in an autonomous transaction if an
   unhandled exception occurs */
      Upd_Yr_End_Rollover_Flag_To_E (
          P_Request_ID => P_Request_ID);
/* Bug 5726535 - End */
      X_Msg_Count     := 1;
      X_Msg_Data      := SUBSTR(SQLERRM, 1, 240);
      X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
      log_message('Year_End_Rollover: ' ||'In When Others. End->X_Msg_Data :'||X_Msg_Data);
      ROLLBACK;
  RETURN;

END Year_End_Rollover; -- End of executing the Year End Budget Rollover process

-------------------------------------------------------------------------------------
-- To fetch all the necessary Period details for executing Year End Rollover process
--
-- Fetch the first/last period details for a given closing fiscal year and
-- first period details of a next year
-------------------------------------------------------------------------------------
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
)
IS

BEGIN

  IF P_DEBUG_MODE = 'Y' THEN
     g_procedure_name := 'Get_Period_Details';
     log_message('Year_End_Rollover: ' || '------------------------------' );
     log_message('Year_End_Rollover: ' || 'Start API : Get_Period_Details' );
     log_message('Year_End_Rollover: ' || '------------------------------' );
     log_message('Year_End_Rollover: ' || 'Fiscal Closing Year : ' || P_Fiscal_year);
     log_message('Year_End_Rollover: ' || 'Set Of Books ID     : ' || P_Set_Of_Books_ID);
  END IF;

  -----------------------------------------------------------------------------------+
  -- Fetch the first and last period dates for the given closing year
  -----------------------------------------------------------------------------------+
  BEGIN
    SELECT
      MIN(PSTS.Start_Date),
      MAX(PSTS.start_date),
      MAX(PSTS.end_date)
    INTO
      X_Cur_Yr_First_Prd_Start_Dt,
      X_Cur_Yr_Last_Prd_Start_Dt,
      X_Cur_Yr_Last_Prd_End_Dt
    FROM
      GL_Period_Statuses  PSTS
    WHERE
        PSTS.application_id  = 101
    AND PSTS.set_of_books_id = P_Set_Of_Books_ID
    AND PSTS.Period_Year     = P_Fiscal_year
    AND PSTS.Adjustment_Period_Flag <> 'Y'
    AND PSTS.Period_Type     = P_Accounted_Period_Type ;
  END;
  IF P_DEBUG_MODE = 'Y' THEN
     log_message('Year_End_Rollover: ' || 'Cur Yr First Prd Start Date  : '|| to_char(X_Cur_Yr_First_Prd_Start_Dt, 'DD-MON-YYYY'));
     log_message('Year_End_Rollover: ' || 'Cur Yr Last Prd Start Date   : '|| to_char(X_Cur_Yr_Last_Prd_Start_Dt, 'DD-MON-YYYY'));
     log_message('Year_End_Rollover: ' || 'Cur Yr Last Prd End Date     : '|| to_char(X_Cur_Yr_Last_Prd_End_Dt, 'DD-MON-YYYY'));  END IF;
  -----------------------------------------------------------------------------------+
  -- Fetch the First period dates for the next fiscal year w.r.t. given closing year
  -----------------------------------------------------------------------------------+
  BEGIN
    SELECT
      MIN(PSTS.Start_Date),
      MIN(PSTS.End_Date)
    INTO
      X_Next_Yr_First_Prd_Start_Dt,
      X_Next_Yr_First_Prd_End_Dt
    FROM
      GL_Period_Statuses  PSTS
    WHERE
        PSTS.application_id  = 101 -- = 8721 ?
    AND PSTS.set_of_books_id = P_Set_Of_Books_ID
    AND PSTS.Period_Year     = P_Fiscal_year + 1
    AND PSTS.Adjustment_Period_Flag <> 'Y'
    AND PSTS.Period_Type     = P_Accounted_Period_Type ;
  END;
  IF P_DEBUG_MODE = 'Y' THEN
     log_message('Year_End_Rollover: ' || 'Next Yr First Prd Start Date : '|| to_char(X_Next_Yr_First_Prd_Start_Dt, 'DD-MON-YYYY'));
     log_message('Year_End_Rollover: ' || 'Next Yr First Prd End Date   : '|| to_char(X_Next_Yr_First_Prd_End_Dt, 'DD-MON-YYYY'));
  END IF;
  -----------------------------------------------------------------------------------+
  -- Fetch the Last Period Name for a given closing year
  -----------------------------------------------------------------------------------+
  BEGIN
    SELECT
      GS.Period_Name
    INTO
      X_Cur_Yr_Last_Prd_Name
    FROM
      GL_Period_Statuses GS
    WHERE
        GS.Set_Of_Books_ID = P_Set_Of_Books_ID
    AND GS.Application_ID  = 101
    AND GS.Closing_Status  = 'O'
    AND GS.Start_Date      = X_Cur_Yr_Last_Prd_Start_Dt
    AND GS.End_Date        = X_Cur_Yr_Last_Prd_End_Dt
    AND GS.Period_Type     = P_Accounted_Period_Type ;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
      IF P_DEBUG_MODE = 'Y' THEN
         log_message('Year_End_Rollover: ' || 'ERRORS encountered in API : Get_Period_Details' );
         log_message('Year_End_Rollover: ' || 'Last Period Closing Fiscal Year is NOT open');
      END IF;

      X_Msg_Count     := 9998;
      X_Msg_Data      := SUBSTR(SQLERRM, 1, 240);
      X_Return_Status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.add_Exc_msg( P_Pkg_Name       => 'PA_Year_End_Rollover_PKG',
                               P_Procedure_Name => 'Get_Period_Details');
      RETURN;
  END;

  IF P_DEBUG_MODE = 'Y' THEN
     log_message('Year_End_Rollover: ' || 'Cur Yr Last Prd Name : '|| X_Cur_Yr_Last_Prd_Name );
  END IF;
  -----------------------------------------------------------------------------------+
  -- Fetch the First Period Name of a next year w.r.t. a given closing year
  -----------------------------------------------------------------------------------+
  BEGIN
    SELECT
      GS.Period_Name
    INTO
      X_Next_Yr_First_Prd_Name
    FROM
      GL_Period_Statuses GS
    WHERE
        GS.Set_Of_Books_ID = P_Set_Of_Books_ID
    AND GS.Application_ID  = 101
    AND GS.Closing_Status  IN ('O', 'F')
    AND GS.Start_Date      = X_Next_Yr_First_Prd_Start_Dt
    AND GS.End_Date        = X_Next_Yr_First_Prd_End_Dt
    AND GS.Period_Type     = P_Accounted_Period_Type ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      IF P_DEBUG_MODE = 'Y' THEN
         log_message('Year_End_Rollover: ' || 'ERRORS encountered in API : Get_Period_Details' );
         log_message('Year_End_Rollover: ' || 'First Period of next year is NOT open');
      END IF;

      X_Msg_Count     := 9999;
      X_Msg_Data      := SUBSTR(SQLERRM, 1, 240);
      X_Return_Status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.add_Exc_msg( P_Pkg_Name       => 'PA_Year_End_Rollover_PKG',
                               P_Procedure_Name => 'Get_Period_Details');
      RETURN;
  END;
  IF P_DEBUG_MODE = 'Y' THEN
     log_message('Year_End_Rollover: ' || 'Next Yr First Prd Name : '|| X_Next_Yr_First_Prd_Name );
     log_message('Year_End_Rollover: ' || '------------------------------' );
     log_message('Year_End_Rollover: ' || 'End API   : Get_Period_Details' );
     log_message('Year_End_Rollover: ' || '------------------------------' );
  END IF;

  RETURN;

  EXCEPTION
    WHEN OTHERS THEN
    IF P_DEBUG_MODE = 'Y' THEN
       log_message('Year_End_Rollover: ' || 'ERRORS encountered in API : Get_Period_Details' );
    END IF;
    X_Msg_Count     := 1;
    X_Msg_Data      := SUBSTR(SQLERRM, 1, 240);
    X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.add_Exc_msg( P_Pkg_Name       => 'PA_Year_End_Rollover_PKG',
                             P_Procedure_Name => 'Get_Period_Details');
END Get_Period_Details;

-------------------------------------------------------------------------------------
-- Update / Insert into PA_BUDGET_LINES
-------------------------------------------------------------------------------------
PROCEDURE Upd_Ins_Budget_Line (
  P_Budget_Version_ID       IN   PA_Budget_Versions.Budget_Version_ID%TYPE,
  P_Budget_Type_Code        IN   PA_Budget_Types.Budget_Type_Code%TYPE,
  P_Resource_Assignment_ID  IN OUT   NOCOPY PA_Resource_Assignments.Resource_Assignment_ID%TYPE,
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
)
IS

-- Local Variables
l_RowID          ROWID;
l_Update_Count   NUMBER;
l_Raw_Cost       NUMBER := 0;
l_Burdened_Cost  NUMBER := 0;
l_Quantity       NUMBER;
l_revenue        NUMBER;
l_Burdened_Transfer_Amount NUMBER;
l_Raw_Transfer_Amount      NUMBER;

/* FPB2: MRC */

-- Bug Fix: 4569365. Removed MRC code.
-- l_Mrc_Exception   EXCEPTION;
l_Txn_Curr_Code   PA_BUDGET_LINES.TXN_CURRENCY_CODE%type;
--l_Budget_Line_Id  PA_BUDGET_LINES.BUDGET_LINE_ID%type;

BEGIN
  X_Return_Status := FND_API.G_RET_STS_SUCCESS;

  -----------------------------------------------------------------------------------+
  -- Update the Budget line for a required res. assignment and period
  -----------------------------------------------------------------------------------+
  IF P_DEBUG_MODE = 'Y' THEN
     g_procedure_name := 'Upd_Ins_Budget_Line';
     log_message('Year_End_Rollover: ' || 'R Flag : '|| P_Raw_Cost_Flag ||' and B Flag : '|| P_Burdened_Cost_Flag);
  END IF;

  IF P_Burdened_Cost_Flag = 'Y'    AND P_Raw_Cost_Flag = 'N'
  THEN
     l_Burdened_Transfer_Amount := P_Transfer_Amount;
     l_Raw_Transfer_Amount      := 0;
  ELSIF P_Burdened_Cost_Flag = 'N' AND P_Raw_Cost_Flag = 'Y'
  THEN
     l_Burdened_Transfer_Amount := 0;
     l_Raw_Transfer_Amount      := P_Transfer_Amount;
  ELSIF P_Burdened_Cost_Flag = 'Y' AND P_Raw_Cost_Flag = 'Y'
  THEN
     l_Burdened_Transfer_Amount := P_Transfer_Amount;
     l_Raw_Transfer_Amount      := 0; -- P_Transfer_Amount;
  END IF;

 /* FPB2: MRC related changes
           - Changes done under the assumption that this code is used only in the old model
           - Txn_currency_code will always be the projfunc_currency_code
           - Adding txn_currency_code in update for more clarity to indicate the update will
             always update just one record. We get the budget_line_id of the updated record
             and pass to mrc api */

   BEGIN
     SELECT Projfunc_Currency_Code
     INTO   l_Txn_Curr_Code
     FROM   PA_Projects_All a, PA_Budget_Versions b, PA_Resource_Assignments c
     WHERE  a.Project_Id = b.Project_Id
     AND    b.Budget_Version_Id = c.Budget_Version_Id
     AND    c.Resource_Assignment_Id = P_Resource_Assignment_Id;
  EXCEPTION
      WHEN OTHERS THEN
         /* May be the resource assignment id passed is not correct ! */
        l_Txn_Curr_Code := NULL;
   END;

  UPDATE
    PA_Budget_Lines
  SET
    Burdened_Cost = NVL(Burdened_Cost,0) + l_Burdened_Transfer_Amount,
    Raw_Cost      = NVL(Raw_Cost,0)      + l_Raw_Transfer_Amount,
    Request_ID    = P_Request_ID
  WHERE
      Resource_Assignment_ID = P_Resource_Assignment_ID
  AND Start_Date             = P_Period_Start_Date
  AND Txn_Currency_Code      = l_Txn_Curr_Code /* FPB2: MRC */
  AND Code_Combination_ID    = P_CCID;
  --RETURNING Budget_Line_Id into l_Budget_Line_Id;

  l_Update_Count := SQL%ROWCOUNT;

    IF P_DEBUG_MODE = 'Y' THEN
       log_message('Year_End_Rollover: ' || 'New/Closing,Records updated:'
        ||P_Period_New_Or_Closing||';'||l_Update_Count);
    END IF;

  If l_Update_Count = 0 and P_Period_New_Or_Closing = 'NEW' then

    -- Update without using code combination_id ...
    -- Case: Where there is a line that is already existing with
-- a diff. code combination ..
    UPDATE
      PA_Budget_Lines
    SET
      Burdened_Cost = NVL(Burdened_Cost,0) + l_Burdened_Transfer_Amount,
      Raw_Cost      = NVL(Raw_Cost,0)      + l_Raw_Transfer_Amount,
      Request_ID    = P_Request_ID
    WHERE
        Resource_Assignment_ID = P_Resource_Assignment_ID
    AND Start_Date             = P_Period_Start_Date
    AND Txn_Currency_Code      = l_Txn_Curr_Code
    RETURNING Code_Combination_ID into P_New_CCID;

    l_Update_Count := SQL%ROWCOUNT;

    IF P_DEBUG_MODE = 'Y' THEN
        log_message('Year_End_Rollover: ' || '2nd Update - New/Closing,Records updated,new CCID:'
        ||P_Period_New_Or_Closing||';'||p_new_ccid||';'||l_Update_Count);
    END IF;

  End If;

  IF l_Update_Count = 0 -- No Data Found ie. NO record are updated
  THEN
    IF P_DEBUG_MODE = 'Y' THEN
       log_message('Year_End_Rollover: ' || 'Inserting into PA_BUDGET_LINES');
    END IF;
    ---------------------------------------------------------------------------------+
    -- Insert a new Budget Lines data
    ---------------------------------------------------------------------------------+
    IF P_DEBUG_MODE = 'Y' THEN
       log_message('Year_End_Rollover: ' || 'Raw Cost: '|| l_Raw_Cost ||' and Burdened Cost: '|| l_Burdened_Cost );
    END IF;
    PA_BUDGET_LINES_V_PKG.Insert_Row (
          X_ROWID                       => l_RowID,
          X_Resource_Assignment_Id      => P_Resource_Assignment_ID,
          X_Budget_Version_Id           => P_Budget_Version_ID,
          X_Project_Id                  => P_Project_ID,
          X_Task_Id                     => P_Task_ID,
          X_Resource_List_Member_Id     => P_Resource_List_Member_Id,
          X_Description                 => NULL,
          X_Start_Date                  => P_Period_Start_Date,
          X_End_Date                    => P_Period_End_Date,
          X_Period_Name                 => P_Period_Name,
          X_Quantity                    => l_quantity,
          X_Unit_Of_Measure             => NULL,
          X_Track_As_Labor_Flag         => NULL,
          X_Raw_Cost                    => l_Raw_Transfer_Amount,
          X_Burdened_Cost               => l_Burdened_Transfer_Amount,
          X_Revenue                     => l_revenue,
          X_Change_Reason_Code          => NULL,
          X_Last_Update_Date            => SYSDATE,
          X_Last_Updated_By             => FND_GLOBAL.User_ID,
          X_Creation_Date               => SYSDATE,
          X_Created_By                  => FND_GLOBAL.User_ID,
          X_Last_Update_Login           => FND_GLOBAL.User_ID,
          X_Attribute_Category          => NULL,
          X_Attribute1                  => NULL,
          X_Attribute2                  => NULL,
          X_Attribute3                  => NULL,
          X_Attribute4                  => NULL,
          X_Attribute5                  => NULL,
          X_Attribute6                  => NULL,
          X_Attribute7                  => NULL,
          X_Attribute8                  => NULL,
          X_Attribute9                  => NULL,
          X_Attribute10                 => NULL,
          X_Attribute11                 => NULL,
          X_Attribute12                 => NULL,
          X_Attribute13                 => NULL,
          X_Attribute14                 => NULL,
          X_Attribute15                 => NULL,
          -- Bug Fix: 4569365. Removed MRC code.
          -- X_Mrc_Flag                    => 'Y', /* FPB2: MRC */
          X_Calling_Process             => 'PR',
          X_Pm_Product_Code             => NULL,
          X_Pm_Budget_Line_Reference    => NULL,
          X_raw_Cost_source             => 'M',
          X_Burdened_Cost_source        => 'M',
          X_quantity_source             => 'M',
          X_revenue_source              => 'M',
          X_standard_Bill_rate          => NULL,
          X_Average_Bill_rate           => NULL,
          X_Average_Cost_rate           => NULL,
          X_project_Assignment_Id       => -1,
          X_plan_Error_Code             => NULL,
          X_total_plan_revenue          => NULL,
          X_total_plan_raw_Cost         => NULL,
          X_total_plan_Burdened_Cost    => NULL,
          X_total_plan_quantity         => NULL,
          X_Average_Discount_percentage => NULL,
          X_Cost_rejection_Code         => NULL,
          X_Burden_rejection_Code       => NULL,
          X_revenue_rejection_Code      => NULL,
          X_other_rejection_Code        => NULL);

    ---------------------------------------------------------------------------------+
    -- Update the CCID for the newly inserted Budget Lines record
    ---------------------------------------------------------------------------------+

    /* FPB2: As of now amounts are not part of the below update and hence MRC need
       not be called. If amount fields are added to the below update, MRC apis need
       to be called to maintain MRC in budgets */

    -- Updating Budget Version Amounts
    UPDATE
      PA_Budget_Versions
    SET
      Raw_Cost      = NVL(Raw_Cost,0)      - l_Raw_Transfer_Amount,
      Burdened_Cost = NVL(Burdened_Cost,0) - l_Burdened_Transfer_Amount
    WHERE
      Budget_Version_ID = P_Budget_Version_ID;
  END IF;   -- End of inserting a new record into PA_BUDGET_LINES

  RETURN;
--  Bug Fix: 4569365. Removed MRC code.
/* EXCEPTION
WHEN l_Mrc_Exception THEN
  IF P_DEBUG_MODE = 'Y' THEN
     log_message('Year_End_Rollover: ' || 'In Upd_Ins_Budget_Line : '|| SQLERRM );
  END IF;
  Raise;
*/
END Upd_Ins_Budget_Line;

-----------------------------------------------------------------------------------
-- Create a Draft version of a Baselined Budget
-----------------------------------------------------------------------------------
PROCEDURE Create_Working_Budget (
  P_Project_ID              IN   PA_Projects_all.Project_ID%TYPE,
  P_Budget_Type_Code        IN   PA_Budget_Types.Budget_Type_Code%TYPE,
  P_Budget_Version_ID       IN   PA_Budget_Versions.Budget_Version_ID%TYPE,
  P_Request_ID              IN   FND_Concurrent_Requests.Request_ID%TYPE,
  X_Work_Budget_Version_ID  OUT  NOCOPY PA_Budget_Versions.Budget_Version_ID%TYPE,
  X_Return_Status           OUT  NOCOPY VARCHAR2,
  X_Msg_Count               OUT  NOCOPY NUMBER,
  X_Msg_Data                OUT  NOCOPY VARCHAR2
)
IS

-- Local Variables
l_Work_Budget_Version_ID      PA_Budget_Versions.Budget_Version_ID%TYPE;
l_Lock_Name                   VARCHAR2(100);

l_Exist_Flag   NUMBER;

l_Err_Code                    NUMBER;
l_Err_Stage                   VARCHAR2(200);
l_Err_Stack                   VARCHAR2(200);

-- Local Exception Variables
l_Lock_Bdgt_Err               EXCEPTION;
l_Get_Work_Bdgt_Err           EXCEPTION;
l_Copy_Bdgt_Err               EXCEPTION;
l_IU_Bdgt_Acct_Err            EXCEPTION;
BEGIN

  IF P_DEBUG_MODE = 'Y' THEN
     g_procedure_name := 'Create_Working_Budget';
     log_message('Create_Working_Budget: Start');
  END IF;

  -- Generate a lock name
  l_lock_Name    := 'YRENDRLVR:'||P_Project_ID||':'||P_Budget_Type_Code ;

  -------------------------------------------------------------------------------+
  -- Check for the working version of the fetched baselined Budget Version
  -------------------------------------------------------------------------------+
  BEGIN
    Select
      1
    INTO
      l_Exist_Flag
    FROM
      PA_Budget_Versions
    WHERE
        Project_ID         = P_Project_ID
    AND Budget_Type_Code   = P_Budget_Type_Code
    AND Budget_Status_Code = 'W' ;
    IF P_DEBUG_MODE = 'Y' THEN
       log_message('Year_End_Rollover: ' || '--');
       log_message('Year_End_Rollover: ' || 'Working Version of the Budget is existing');
       log_message('Year_End_Rollover: ' || '--');
    END IF;
    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  l_Work_Budget_Version_Id := P_Budget_Version_ID;  /* added for bug 2699417 */
	  RAISE l_Get_Work_Bdgt_ERR;
  END;
  -- End of checking the working version of Budget Version

/* Commenting for Bug 5726535
  -------------------------------------------------------------------------------+
  -- Create (acquire) a lock for the Budget version record
  -------------------------------------------------------------------------------+
  IF PA_Debug.Acquire_User_Lock(l_Lock_Name) <> 0
  THEN
        l_Work_Budget_Version_Id := P_Budget_Version_ID;
	RAISE l_Lock_Bdgt_ERR;
  END IF;
  IF P_DEBUG_MODE = 'Y' THEN
     log_message('Year_End_Rollover: ' || '--');
     log_message('Year_End_Rollover: ' || 'Acquired Lock : '|| l_lock_name );
     log_message('Year_End_Rollover: ' || '--');
     log_message('Year_End_Rollover: Calling PA_Budget_Core.Copy');
  END IF;
  -- End of acquiring the user lock
*/

/* Bug 5726535 - Start */
  -------------------------------------------------------------------------------+
  -- Check if Year End Rollover program is already running for this Project and
  -- Budget Type
  -------------------------------------------------------------------------------+
  IF Is_Yr_End_Rollover_Running(P_Project_ID, P_Budget_Type_Code) THEN
    l_Work_Budget_Version_Id := P_Budget_Version_ID;  /* added for bug 2699417 */
    RAISE l_Lock_Bdgt_ERR;
  END IF;
  IF P_DEBUG_MODE = 'Y' THEN
     log_message('Year_End_Rollover: ' || '--');
     log_message('Year_End_Rollover: ' || 'No Year End Rollover program running for Project_ID: '|| P_Project_ID
                                       || ' and Budget_Type_Code: ' || P_Budget_Type_Code);
     log_message('Year_End_Rollover: ' || '--');
     log_message('Year_End_Rollover: Calling Update_Yr_End_Rollover_Flag'); /* Bug 5726535 */
  END IF;
  -- End of checking if Year End Rollover program is already running for this
  -- Project and Budget Type

  -------------------------------------------------------------------------------+
  -- Update PA_Budgetary_Control_Options.Yr_End_Rollover_Flag to 'P' indicating
  -- to other processes that this program is running
  -------------------------------------------------------------------------------+
  Upd_Yr_End_Rollover_Flag_To_P(
    P_Request_ID => P_Request_ID,
    P_Project_ID => P_Project_ID,
    P_Budget_Type_Code => P_Budget_Type_Code);
  IF P_DEBUG_MODE = 'Y' THEN
     log_message('Year_End_Rollover: ' || '--');
     log_message('Year_End_Rollover: ' || 'Updated PA_Budgetary_Control_Options.Yr_End_Rollover_Flag to ''P''');
     log_message('Year_End_Rollover: ' || '--');
     log_message('Year_End_Rollover: Calling PA_Budget_Core.Copy');
  END IF;
  -- End of updating PA_Budgetary_Control_Options.Yr_End_Rollover_Flag to 'P'
/* Bug 5726535 - End */

  -------------------------------------------------------------------------------+
  -- Create (using PA_Budget_Core.Copy API) a new Draft Budget Version
  -- along with its Res. Assignment IDs and Budget Lines.
  -------------------------------------------------------------------------------+
  PA_Budget_Core.Copy (
     X_Src_Version_ID        => P_Budget_Version_ID,
     X_Amount_Change_Pct     => 1,
     X_Shift_days            => 5,
     X_Rounding_Precision    => null, -- Need to verify
     X_Dest_Project_ID       => P_Project_ID,
     X_Dest_Budget_Type_Code => P_Budget_Type_Code,
     X_Err_Code              => l_Err_Code,
     X_Err_Stage             => l_Err_Stage,
     X_Err_Stack             => l_Err_Stack
  );

  IF l_Err_Code <> 0
  THEN
        log_message('Year_End_Rollover: PA_Budget_Core.Copy failed');
        log_message('Year_End_Rollover: X_Err_Stage['||l_Err_Stage||'] X_Err_Code ['||l_Err_Code||']');
        log_message('Year_End_Rollover: X_Err_Stack['||l_Err_Stack||']');
  	l_Work_Budget_Version_Id := P_Budget_Version_ID;  /* added for bug 2699417 */
	RAISE l_Copy_Bdgt_ERR;
  END IF;
  IF P_DEBUG_MODE = 'Y' THEN
     log_message('Year_End_Rollover: ' || '--');
     log_message('Year_End_Rollover: ' || 'Budget successfully copied using API PA_Budget_Core.Copy');
     log_message('Year_End_Rollover: ' || '--');
  END IF;
  -- End of copying the Budget

  -------------------------------------------------------------------------------+
  -- Get the working Budget Version ID for the above copied Budget
  -------------------------------------------------------------------------------+
  BEGIN
    SELECT
      Budget_Version_ID
    INTO
      X_Work_Budget_Version_ID
    FROM
      PA_BUDGET_VERSIONS
    WHERE
        Project_ID         = P_Project_ID
    AND Budget_Type_Code   = P_Budget_Type_Code
    AND Budget_Status_Code = 'W';
    IF P_DEBUG_MODE = 'Y' THEN
       log_message('Year_End_Rollover: ' || '--');
       log_message('Year_End_Rollover: ' || 'Working Version of the copied Budget is found');
       log_message('Year_End_Rollover: ' || '--');
    END IF;
    l_Work_Budget_Version_ID := X_Work_Budget_Version_ID ;
    EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	    l_Work_Budget_Version_Id := P_Budget_Version_ID;  /* added for bug 2699417 */
	    RAISE l_Get_Work_Bdgt_ERR;
  END;
  -- End of Checking the working version of Budget Version

  -- Update all the CCIDs
  BEGIN
    FOR i IN ( SELECT RA.Resource_List_Member_ID,
		      RA.Resource_Assignment_ID,
		      RA.Project_ID,
		      RA.Task_ID,
		      BL.Code_Combination_ID,
		      BL.Start_Date
               FROM   PA_Resource_Assignments RA,
		      PA_Budget_Lines         BL
	       WHERE  RA.Resource_Assignment_ID = BL.Resource_Assignment_ID
	       AND    RA.Budget_Version_ID      = P_Budget_Version_ID )
    LOOP

    /* FPB2: As of now amounts are not part of the below update and hence MRC need
       not be called. If amount fields are added to the below update, MRC apis need
       to be called to maintain MRC in budgets */

      UPDATE
	PA_Budget_Lines BL
      SET
	BL.Code_Combination_ID = i.Code_Combination_ID
      WHERE
	  BL.Start_Date              = i.Start_Date
      AND BL.Resource_Assignment_ID  = (
	    SELECT RA.Resource_Assignment_ID
	    FROM   PA_Resource_Assignments RA
	    WHERE  RA.Budget_Version_ID        = l_Work_Budget_Version_ID
	    AND    RA.Resource_List_Member_ID  = i.Resource_List_Member_ID
            AND    RA.Project_ID               = i.Project_ID
	    AND    RA.Task_ID                  = i.Task_ID );

    END LOOP;
  END;
 -------------------------------------------------------------------------------
  -- Delete if account lines exist ..
 -------------------------------------------------------------------------------
  Delete from PA_Budget_Acct_Lines where Budget_version_ID = l_Work_Budget_Version_ID;

  -------------------------------------------------------------------------------
  -- Insert new Account Lines
  -------------------------------------------------------------------------------
  IF P_DEBUG_MODE = 'Y' THEN
     log_message('Year_End_Rollover: ' || '--');
     log_message('Year_End_Rollover: ' || 'Inserting new records into PA_Budget_Acct_Lines for newly created Draft Budget Version = '|| l_Work_Budget_Version_ID );
     log_message('Year_End_Rollover: ' || '--');
  END IF;

  BEGIN
    INSERT INTO PA_Budget_Acct_Lines (
      Budget_Acct_Line_ID,
      Budget_version_ID,
      GL_Period_Name,
      Start_Date,
      End_Date,
      Code_Combination_ID,
      Prev_Ver_Budget_Amount,
      Prev_Ver_Available_Amount,
      Curr_Ver_Budget_Amount,
      Curr_Ver_Available_Amount,
      Accounted_Amount,
      Last_Update_Date,
      Last_Updated_By,
      Creation_Date,
      Created_By,
      Last_Update_Login,
      Request_ID
    )
    SELECT
      PA_Budget_Acct_Lines_S.NEXTVAL,
      l_Work_Budget_Version_ID, -- Should be working Budget Version
      GL_Period_Name,
      Start_Date,
      End_Date,
      Code_Combination_ID,
      Curr_Ver_Budget_Amount,
      Curr_Ver_Available_Amount,
      Curr_Ver_Budget_Amount,
      Curr_Ver_Available_Amount,
      0,
      sysdate,
      1234,
      sysdate,
      1234,
      1234,
      P_Request_ID
    FROM
      PA_Budget_Acct_Lines
    WHERE
      Budget_Version_ID = P_Budget_Version_ID ;

    IF SQL%ROWCOUNT = 0
    THEN
      RAISE l_IU_Bdgt_Acct_ERR;
    END IF;

  END; -- End of inserting New Budget Account Lines

  RETURN;

  EXCEPTION
    WHEN l_Lock_Bdgt_Err     THEN
      X_Msg_Count     := 1;
      X_Msg_Data      := SUBSTR(SQLERRM, 1, 240);
      X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
      Year_End_Rollover_Log (
            P_Budget_Version_ID => l_Work_Budget_Version_Id,
            P_Message_Name      => 'PA_BC_LOCK_BDGT_ERR',
            P_Request_ID        => P_Request_ID,
            P_Lock_Name         => l_Lock_Name );

    WHEN l_Get_Work_Bdgt_Err THEN
      X_Msg_Count     := 1;
      X_Msg_Data      := SUBSTR(SQLERRM, 1, 240);
      X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
      Year_End_Rollover_Log (
            P_Budget_Version_ID => l_Work_Budget_Version_Id,
            P_Message_Name      => 'PA_BC_WORK_BDGT_ERR',
            P_Request_ID        => P_Request_ID,
            P_Lock_Name         => l_Lock_Name );
    WHEN l_Copy_Bdgt_Err     THEN
      X_Msg_Count     := 1;
      X_Msg_Data      := SUBSTR(SQLERRM, 1, 240);
      X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
      Year_End_Rollover_Log (
            P_Budget_Version_ID => l_Work_Budget_Version_Id,
            P_Message_Name      => 'PA_BC_COPY_BDGT_ERR',
            P_Request_ID        => P_Request_ID,
            P_Lock_Name         => l_Lock_Name );
    WHEN l_IU_Bdgt_Acct_Err  THEN
      X_Msg_Count     := 1;
      X_Msg_Data      := SUBSTR(SQLERRM, 1, 240);
      X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
      Year_End_Rollover_Log (
            P_Budget_Version_ID => l_Work_Budget_Version_Id,
            P_Message_Name      => upper('PA_BC_IU_Bdgt_Acct_Err'),
            P_Request_ID        => P_Request_ID,
            P_Lock_Name         => l_Lock_Name );
END Create_Working_Budget;

-- -------------------------------------------------------------------+
-- This procedure will create budget data in pa_bc_balances (from
-- pa_budget_lines, pa_resource_assignments)
-- -------------------------------------------------------------------+

PROCEDURE Create_bc_balances(p_budget_version_id IN NUMBER,
                             p_last_baselined_version_id IN NUMBER,
                             p_Set_of_books_id   IN NUMBER,
                             p_return_status OUT NOCOPY VARCHAR2)
IS
 l_date DATE;
 l_user NUMBER;
 l_request_id NUMBER;
BEGIN
   p_return_status := 'S';
   l_date := SYSDATE;
   l_user := FND_GLOBAL.LOGIN_ID;
   l_request_id := FND_GLOBAL.conc_request_id;

      IF P_DEBUG_MODE = 'Y' THEN
         log_message('Create_bc_balances: Create pa_bc_balances - BGT');
      END IF;

            -- Budget lines from pa_budget_lines
            insert into pa_bc_balances(
                PROJECT_ID,
                TASK_ID,
                TOP_TASK_ID,
                RESOURCE_LIST_MEMBER_ID,
                BALANCE_TYPE,
                SET_OF_BOOKS_ID,
                BUDGET_VERSION_ID,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATE_LOGIN,
                PERIOD_NAME,
                START_DATE,
                END_DATE,
                PARENT_MEMBER_ID,
                BUDGET_PERIOD_TO_DATE,
                ACTUAL_PERIOD_TO_DATE,
                ENCUMB_PERIOD_TO_DATE,
                REQUEST_ID)
         select pa.project_id,
                pa.task_id,
                pt.top_task_id,
                pa.resource_list_member_id,
                'BGT',
                p_set_of_books_id,
                pbv.budget_version_id,
                l_date,
                l_user,
                l_user,
                l_date,
                l_user,
                pb.PERIOD_NAME,
                pb.START_DATE,
                pb.END_DATE,
                rm.PARENT_MEMBER_ID,
                pb.burdened_cost,
                0,
                0,
                l_request_id
           from pa_budget_lines pb,
                pa_resource_assignments pa,
                pa_tasks pt,
                pa_resource_list_members rm,
                pa_budget_versions pbv
         where pbv.budget_version_id = p_budget_version_id
         and   pa.resource_assignment_id = pb.resource_assignment_id
         and   pa.task_id = pt.task_id (+)
         and   pa.budget_version_id = pbv.budget_version_id
         and   rm.resource_list_member_id = pa.resource_list_member_id;

      IF P_DEBUG_MODE = 'Y' THEN
         log_message('Create_bc_balances: Create pa_bc_balances - Transaction data');
      END IF;

   -- Transaction data from the last baselined version ..
    INSERT INTO
      PA_BC_Balances (
	 Project_ID,
	 Task_ID,
	 Resource_List_Member_ID,
	 Set_Of_Books_ID,
         Budget_Version_ID,
	 Balance_Type,
         Start_Date,
	 End_Date,
	 Created_By,
	 Creation_date,
	 Last_Updated_By,
	 Last_Update_date,
	 Last_Update_Login,
	 Top_Task_ID,
	 Parent_Member_ID,
         Request_ID,
	 Program_ID,
	 Program_Application_ID,
	 Program_Update_Date,
         Period_Name,
	 Actual_Period_To_Date,
	 Budget_period_To_Date,
	 Encumb_Period_To_Date
      )
      SELECT
	Project_ID,
	Task_ID,
	Resource_List_Member_ID,
	Set_Of_Books_ID,
	p_budget_version_id,
	Balance_Type,
	Start_Date,
	End_Date,
        l_user,
	l_date,          -- Creation_Date
        l_user,
	l_date,          -- Last_Update_Date
        l_user,
	Top_Task_ID,
	Parent_Member_ID,
	Request_ID,
        Program_ID,
	Program_Application_ID,
	Program_Update_Date,
	Period_Name,
	Actual_Period_To_Date,
	Budget_period_To_Date,
	Encumb_Period_To_Date
      FROM
        PA_BC_BALANCES
      WHERE
        Budget_Version_ID = p_last_baselined_version_id
      AND Balance_Type <> 'BGT' ;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := 'E';
END Create_bc_balances;


-------------------------------------------------------------------------------------
-- Update the message name for a Budget Version that was failed due to some reason
-------------------------------------------------------------------------------------
PROCEDURE Year_End_Rollover_Log (
  P_Budget_Version_ID       IN   PA_Budget_Versions.Budget_Version_ID%TYPE,
  P_Message_Name            IN   FND_New_Messages.Message_Name%TYPE,
  P_Request_ID              IN   FND_Concurrent_Requests.Request_ID%TYPE,
  P_Lock_Name               IN   VARCHAR2
)
IS

-- Local Values
l_Lock_Result              NUMBER;
l_Project_ID               PA_Projects_all.Project_ID%TYPE;
l_Budget_Type_Code         PA_Budget_Types.Budget_Type_Code%TYPE;

BEGIN

/* Commenting for Bug 5726535
  -- Release the lock
  IF P_DEBUG_MODE = 'Y' THEN
     log_message('In Year_End_Rollover_Log API. Releasing Lock Name = '|| P_Lock_Name );
  END IF;
  l_Lock_Result := PA_Debug.Release_User_Lock(P_Lock_Name);
  IF P_DEBUG_MODE = 'Y' THEN
     log_message('Year_End_Rollover: ' || 'Lock Result : '|| l_Lock_Result );
  END IF;
*/
/* Bug 5726535 - Start */
  IF P_DEBUG_MODE = 'Y' THEN
     log_message('In Year_End_Rollover_Log API.');
  END IF;
/* Bug 5726535 - End */
  BEGIN
    SELECT distinct
      Project_ID,
      Budget_Type_Code
    INTO
      l_Project_ID,
      l_Budget_Type_Code
    FROM
      PA_Budget_Versions
    WHERE
      Budget_Version_ID = P_Budget_Version_ID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      IF P_DEBUG_MODE = 'Y' THEN
         log_message('Year_End_Rollover: ' || 'No Data Found in PA_Budget_Versions');
      END IF;
  END;

  -- Update the Budget Version record
  IF P_DEBUG_MODE = 'Y' THEN
     log_message('Year_End_Rollover: ' || 'Updating with Error in PA_Budgetary_Control_Options');
     log_message ('l_Project_ID = '|| l_Project_ID ); /* 2699417 */
     log_message ('l_Budget_Type_Code = '|| l_Budget_Type_Code ); /* 2699417 */
     log_message ('P_Message_Name = '|| P_Message_Name ); /* 2699417 */
  END IF;
  UPDATE
    PA_Budgetary_Control_Options
  SET
    Yr_End_Rollover_Message = P_Message_Name,
    Yr_End_Rollover_Flag    = 'E',
    Yr_End_Rollover_Year    = -1,
    Request_ID              = P_Request_ID
  WHERE
      Project_ID       = l_Project_ID
  AND Budget_Type_Code = l_Budget_Type_Code;

END Year_End_Rollover_Log;

-- Procedure used to call pa_debug.write for FND logging
PROCEDURE LOG_MESSAGE(p_message in VARCHAR2)
IS
BEGIN
-- IF g_debug_mode = 'Y' then

  IF p_message is NOT NULL then
    pa_debug.g_err_stage := 'Debug Msg :'||substr(p_message,1,250);

    -- Following to write to request log
    pa_debug.write_file(pa_debug.g_err_stage);
    -- for fnd log
    PA_DEBUG.write
             (x_Module       => 'pa.plsql.PA_YEAR_END_ROLLOVER_PKG.'||g_procedure_name
             ,x_Msg          => substr(p_message,1,240)
             ,x_Log_Level    => 3);
  END IF;
 --END IF;

END LOG_MESSAGE;

/* Bug 5726535 - Start */
/* This function checks if PA_Budgetary_Control_Options.Yr_End_Rollover_Flag
   is already set to 'P' for the given Project and Budget Type combination.
   If yes, the function returns TRUE. Otherwise, the function returns FALSE */
FUNCTION Is_Yr_End_Rollover_Running(
  P_Project_ID IN PA_Projects_all.Project_ID%TYPE,
  P_Budget_Type_Code IN PA_Budget_Types.Budget_Type_Code%TYPE
) RETURN BOOLEAN
IS
l_Yr_End_Rollover_Flag PA_Budgetary_Control_Options.Yr_End_Rollover_Flag%TYPE := NULL;
BEGIN
  SELECT Yr_End_Rollover_Flag
  INTO l_Yr_End_Rollover_Flag
  FROM PA_Budgetary_Control_Options
  WHERE Project_ID = p_Project_ID
  AND Budget_Type_Code = p_Budget_Type_Code;

  IF l_Yr_End_Rollover_Flag = 'P' THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END Is_Yr_End_Rollover_Running;

/* This procedure updates PA_Budgetary_Control_Options.Yr_End_Rollover_Flag to 'P'
   in an autonomous transaction */
PROCEDURE Upd_Yr_End_Rollover_Flag_To_P(
  P_Request_ID IN FND_Concurrent_Requests.Request_ID%TYPE,
  P_Project_ID IN PA_Projects_all.Project_ID%TYPE,
  P_Budget_Type_Code IN PA_Budget_Types.Budget_Type_Code%TYPE
)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  UPDATE PA_Budgetary_Control_Options
  SET Yr_End_Rollover_Flag = 'P',
    Request_ID = P_Request_ID
  WHERE Project_ID = P_Project_ID
  AND Budget_Type_Code = P_Budget_Type_Code;
  COMMIT;
END Upd_Yr_End_Rollover_Flag_To_P;

/* This procedure updates PA_Budgetary_Control_Options.Yr_End_Rollover_Flag to 'E'
   in an autonomous transaction */
PROCEDURE Upd_Yr_End_Rollover_Flag_To_E(
  P_Request_ID IN FND_Concurrent_Requests.Request_ID%TYPE
)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  UPDATE PA_Budgetary_Control_Options
  SET Yr_End_Rollover_Flag = 'E'
  WHERE Request_ID = P_Request_ID;
  COMMIT;
END Upd_Yr_End_Rollover_Flag_To_E;
/* Bug 5726535 - End */

END PA_Year_End_Rollover_PKG ; /* End of package PA_Year_End_Rollover_PKG */

/
