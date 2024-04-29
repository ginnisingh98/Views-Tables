--------------------------------------------------------
--  DDL for Package Body PA_BUDGET_ACCOUNT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BUDGET_ACCOUNT_PKG" AS
--  $Header: PABDACGB.pls 120.6.12000000.3 2007/10/26 05:42:44 pvishnoi ship $

-- ## Forward Declaration
PROCEDURE Upd_Budget_Acct_Line (
  p_Budget_Type_Code         IN   PA_Budget_Types.Budget_Type_Code%TYPE,
  p_Project_ID               IN   PA_Projects_All.Project_ID%TYPE,
  p_Period_Name              IN   GL_PERIODS.period_name%TYPE,
  p_Start_Date               IN   DATE,
  p_End_Date                 IN   DATE,
  P_CCID                     IN   gl_Code_Combinations.code_Combination_Id%TYPE,
  P_Budget_Version_ID        IN   pa_Budget_versions.budget_version_Id%TYPE,
  p_Prev_Budget_Version_ID   IN   pa_Budget_versions.budget_version_Id%TYPE,
  p_Amount                   IN   NUMBER,
  X_Return_Status            OUT  NOCOPY VARCHAR2,
  X_Msg_Count                OUT  NOCOPY NUMBER,
  X_Msg_Data                 OUT  NOCOPY VARCHAR2
);

----------------------------------------------------------------------------------------+
--  Package             : PA_BUDGET_ACCOUNT_PKG
--
--  Purpose             : 1) Generate the Account Code CCID for every Budget Line
--                           depending upon the calling mode parameter.
--	                  2) Update the Budget Line Data with generated CCID
--                        3) Update the Budget Account Summary Details
--	                  4) Insert new Budget Lines which are having missed GL Periods
--	                  5) Derive the Resource and Task related Parameters
--  Parameters          :
--     P_Calling_Mode--> SUBMIT/ BASELINE / GENERATE_ACCOUNT
----------------------------------------------------------------------------------------+

PROCEDURE  Gen_Account (
  P_Budget_Version_ID        IN   PA_Budget_Versions.Budget_Version_ID%TYPE,
  P_Calling_Mode             IN   VARCHAR2,
  X_Return_Status            OUT  NOCOPY VARCHAR2,
  X_Msg_Count                OUT  NOCOPY NUMBER,
  X_Msg_Data                 OUT  NOCOPY VARCHAR2
)
AS

-- Local Parameters:
l_Budget_Type_Code           PA_Budget_Types.Budget_Type_Code%TYPE;
l_Project_ID                 PA_Projects_All.Project_ID%TYPE;
l_Budget_Entry_Level_Code    PA_Budget_Entry_Methods.Entry_Level_Code%TYPE;

l_msg_Index_out              NUMBER;
l_Return_Status              VARCHAR2(50);
l_Msg_Count                  NUMBER;
l_Msg_Data                   VARCHAR2(500);

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

PA_FCK_UTIL.debug_msg('Entering  Gen_Account ..........');
PA_FCK_UTIL.debug_msg('p_calling_mode  ..........'||p_calling_mode);
  l_Return_Status := FND_API.G_RET_STS_SUCCESS;

  -----------------------------------------------------------------+
  -- Fetch the values of Budget_type_Code and Project_ID and
  -- Also check If Budgetry Control is implemented
  -----------------------------------------------------------------+
PA_FCK_UTIL.debug_msg('Before executing  bc controls  select statement ..........');
  BEGIN
    SELECT
      BVER.Budget_Type_Code           BUDGET_TYPE_CODE,
      BVER.Project_ID                 PROJECT_ID,
      BEM.Entry_Level_Code            BUDGET_ENTRY_LEVEL_CODE
    INTO
      l_Budget_Type_Code,
      l_Project_ID,
      l_Budget_Entry_Level_Code
    FROM
      PA_Budget_versions              BVER,
      PA_Budget_Entry_Methods         BEM,
      PA_Budgetary_Control_Options    BCO
    WHERE
         BVER.Budget_Version_ID       = p_Budget_version_Id
    AND  BEM.Budget_Entry_Method_Code = BVER.Budget_Entry_Method_Code
    AND  BCO.Budget_Type_Code              = BVER.Budget_Type_Code
    AND  BCO.Project_ID               = BVER.Project_ID
    AND  BCO.External_Budget_Code IS NOT NULL ;
  END;
PA_FCK_UTIL.debug_msg('  '||to_char(SQL%ROWCOUNT)||' Rows selected/update/deleted/inserted ..........');

  -----------------------------------------------------------------+
  -- If found then call API Gen_Acct_All_Lines() to generate CCID
  --  for all its Budget Lines
  -----------------------------------------------------------------+
  PA_BUDGET_ACCOUNT_PKG.Gen_Acct_All_Lines (
         P_Budget_Version_ID,     --  Current version of the Budget
         P_Calling_Mode,          --  Input from SQL*Form
         l_Budget_Type_Code,
	 l_Budget_Entry_Level_Code,
         l_Project_ID,
         l_return_status,
	 l_Msg_Count,
	 l_Msg_Data
  );

  X_Return_Status := l_Return_Status;
  X_Msg_Count     := l_Msg_Count    ;
  X_Msg_Data      := l_Msg_Data     ;

  COMMIT;

PA_FCK_UTIL.debug_msg('Exiting  Gen_Account ..........');
  RETURN;

  EXCEPTION
    WHEN OTHERS THEN
      X_Msg_Count     := 1;
      X_Msg_Data      := SUBSTR(SQLERRM, 1, 240);
      X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_Exc_msg( P_Pkg_Name         => 'PA_BUDGET_ACCOUNT_PKG',
                               P_Procedure_Name   => 'Gen_Account');
END Gen_Account;  /* End of Gen_Account API */

PROCEDURE Gen_Acct_All_Lines (
  P_Budget_Version_ID        IN   PA_Budget_Versions.Budget_Version_ID%TYPE,
  P_Calling_Mode             IN   VARCHAR2,
  P_Budget_Type_Code         IN   PA_Budget_Types.Budget_Type_Code%TYPE,
  P_Budget_Entry_Level_Code  IN   PA_Budget_Entry_Methods.Entry_Level_Code%TYPE,
  P_Project_ID               IN   PA_projects_All.project_Id%TYPE,
  X_Return_Status            OUT  NOCOPY VARCHAR2,
  X_Msg_Count		     OUT  NOCOPY NUMBER,
  X_Msg_Data		     OUT  NOCOPY VARCHAR2
)
IS

-- Local Parameters
l_acc_gen_error                 EXCEPTION;
l_no_budgetary_control          EXCEPTION;

l_Prev_Budget_Version_ID     PA_Budget_Versions.Budget_Version_ID%TYPE;
l_Concat_Segs                VARCHAR2(500);
l_Concat_IDs                 VARCHAR2(500);
l_Concat_Descrs              VARCHAR2(500);
l_Error_Message              VARCHAR2(2000);
l_CCID                       NUMBER;
l_Error_Flag                 VARCHAR2(1);

l_ccid_gen_result_flag       VARCHAR2(1);  /* values s--> sucess, f --> failure */
l_Return_Status              VARCHAR2(50);
l_Msg_Count                  NUMBER;
l_Msg_Data                   VARCHAR2(500);

l_Max_Version_Number         NUMBER;
l_Project_Number             PA_Projects_All.Segment1%TYPE;
l_Project_Org_Name           HR_Organization_Units.Name%TYPE;
l_Project_Org_ID             HR_Organization_Units.Organization_ID %TYPE;
l_Project_Type               PA_Project_Types_All.Project_Type%TYPE;
l_Project_Class_Code         PA_Project_Classes.Class_Code%TYPE; /* Added for bug 2914197 */
l_Project_Start_Date         DATE;
l_Project_End_Date           DATE;

l_Msg_Index_Out              NUMBER;

l_balance_type                  PA_BUDGETARY_CONTROL_OPTIONS.Balance_type%TYPE ;
l_budget_amount_code            Pa_Budget_Types.Budget_Amount_Code%TYPE ;

l_is_cc_budget               varchar2(1); --Bug 6524116
-----------------------------------------------------------------------+
  -- Need cursor to fetch all the budget line details from Budget Lines
  --   for a given budget version ID
  -----------------------------------------------------------------------+
  CURSOR cur_All_Budget_Lines IS
  SELECT
    BL.Code_Combination_ID                               CCID_old,
    BL.Resource_Assignment_ID                            Resource_Assignment_ID,
    BL.Start_Date                                        Start_Date,
    BL.End_Date                                          End_Date,
    NVL(RM.Parent_Member_ID, RM.Resource_List_Member_ID) Resource_Group_ID,
    RTYPE.Resource_Type_Code                             Resource_Type,
    DECODE(RTYPE.Resource_Type_Code, NULL, 'N', 'Y')     Resource_List_Flag,
    RA.resource_list_member_id                           resource_list_member_id,
    RM.Parent_Member_ID                                  parent_resource_id,
    RM.alias                                             resource_name,
    RA.Task_ID                                           Task_ID,
    nvl(PT.Top_task_id,-99)                              Top_task_id,
    PT.task_number                                       task_number,
    RT.Person_ID                                         Person_ID,
    RT.Expenditure_Category                              Expenditure_Category,
    RT.Expenditure_Type                                  Expenditure_Type,
    RT.Job_ID                                            Job_ID,
    RT.Organization_ID                                   Organization_ID,
    RT.Vendor_ID                                         Supplier_ID,
    BL.Period_Name                                       Period_Name,
    decode(nvl(l_balance_type,'X'),
                'E', decode(NVL(BL.Burdened_Cost,0),
                            0,nvl(bl.raw_cost,0),
                            bl.burdened_cost ) ,
                'B',decode(l_Budget_Amount_Code,
                             'R',nvl(bl.revenue,0) ,
                             'C', decode(NVL(BL.Burdened_Cost,0),
                                         0,nvl(bl.raw_cost,0),
                                         bl.burdened_cost ),
                              0 ),
                 0 )                                     Total_Amount,
    BL.txn_currency_code
  FROM
    PA_Resource_Types              RTYPE,
    PA_Budget_Lines                BL,
    PA_Resources                   RS,
    PA_Resource_List_Members       RM,
    PA_Resource_Assignments        RA,
    PA_Resource_Txn_Attributes     RT,
    PA_TASKS                       PT
  WHERE
       -- ra.Budget_Version_ID       =  P_Budget_Version_ID AND
  ra.Resource_Assignment_ID  =  BL.Resource_Assignment_ID
  AND  RA.Resource_List_Member_ID =  RM.Resource_List_Member_ID
  AND  RM.Resource_ID             =  RS.Resource_ID
  AND  RM.Resource_ID             =  RT.Resource_ID (+)
  AND  RS.Resource_Type_ID        =  RTYPE.Resource_Type_ID
  AND  ra.budget_version_id       =  BL.budget_version_id
  AND  BL.Budget_Version_ID       =  P_Budget_Version_ID
  AND  PT.task_id(+)              =  RA.Task_ID ;


  -- Last 2 criteria added as part of bug 4009377: performance improvement

Cursor c_Budget_funds is
    Select  PBCO.Balance_type,
            PBT.Budget_Amount_Code
    From    PA_BUDGETARY_CONTROL_OPTIONS    PBCO ,
            PA_BUDGET_VERSIONS              PBV  ,
            PA_BUDGET_TYPES                 PBT
    WHERE   PBCO.Project_Id = p_project_id
    AND     PBV.Budget_version_id = p_Budget_version_id
    AND     PBV.Budget_Type_Code = PBCO.Budget_Type_Code
    AND     PBV.Budget_Type_Code = PBT.Budget_Type_Code;

 l_txn_exists_against_project     varchar2(1);
 l_prev_ccid                      pa_budget_lines.code_combination_id%type;
BEGIN

PA_FCK_UTIL.debug_msg('Entering Gen_Acct_All_Lines  ..........');
  l_Return_Status := FND_API.G_RET_STS_SUCCESS;

PA_FCK_UTIL.debug_msg('p_calling_mode  ..........'||p_calling_mode);
-----------------------------------------------+
-- Get the budgetary control options
-----------------------------------------------+
 pa_fck_util.debug_msg('Opening budget_funds cursor') ;
 pa_fck_util.debug_msg('proj_id '||to_char(p_project_id)||'bver_id '
    ||to_char(p_budget_version_id ));

 OPEN c_Budget_funds ;
 FETCH c_Budget_funds
 INTO   l_balance_type,l_Budget_Amount_Code;

 IF c_Budget_funds%NOTFOUND THEN
   RAISE l_no_budgetary_control;
 END IF;

 CLOSE c_Budget_funds ;

  ---------------------------------------------------------+
  -- Get/Derive project details from Project ID parameter
  ---------------------------------------------------------+
  BEGIN
    SELECT
      PROJ.Segment1          PROJECT_NUMBER,
      ORG.Name               PROJECT_ORGANIZATION_NAME,
      ORG.Organization_ID    PROJECT_ORGANIZATION_ID,
      PROJ.Project_Type      PROJECT_TYPE,
      PROJ.Start_Date        PROJ_START_DATE,
      PROJ.Completion_Date   PROJ_END_DATE
    INTO
      l_Project_Number,
      l_Project_Org_Name,
      l_Project_Org_Id,
      l_Project_Type,
      l_Project_Start_Date,
      l_Project_End_Date
    FROM
      HR_All_Organization_Units      ORG,
      PA_Projects                    PROJ
    WHERE
         PROJ.Project_ID     =  P_Project_ID
    AND  ORG.Organization_ID =  PROJ.Carrying_Out_Organization_ID ;
  END;

PA_FCK_UTIL.debug_msg('after selecting proj org details  ..........');

/* Code addition for bug 2914197 starts */
  ---------------------------------------------------------+
  -- Get class code from Project ID parameter
  ---------------------------------------------------------+
  BEGIN
    SELECT
      CLASS.Class_Code    PROJECT_CLASS_CODE
      INTO    l_Project_Class_Code
    FROM
        PA_Project_Classes        CLASS,
	Pa_Class_Categories       CLCAT
    WHERE
	 CLCAT.Autoaccounting_Flag = 'Y' AND
	 CLCAT.Class_Category = CLASS.Class_Category AND
         CLASS.Project_ID    =  P_Project_ID;
   EXCEPTION
    WHEN NO_DATA_FOUND THEN
	l_Project_Class_Code := null;
  END;
PA_FCK_UTIL.debug_msg('after selecting class code  ..........');

/* Code addition for bug 2914197 ends */

  ----------------------------------------------------+
  -- Fetch the Latest Previous Budget Version Number
  ----------------------------------------------------+
  BEGIN
    SELECT
      MAX(Version_Number)
    INTO
      l_Max_Version_Number
    FROM
      PA_Budget_Versions
    WHERE
         Project_ID         = p_Project_ID
    AND  Budget_Status_Code = 'B'
    AND  Budget_Type_Code   = p_Budget_Type_Code ;
  END;

  IF l_Max_Version_Number <> 0
  THEN
    BEGIN
      SELECT
        Budget_Version_ID
      INTO
        l_Prev_Budget_Version_ID
      FROM
        PA_Budget_Versions
      WHERE
          Project_ID          = p_Project_ID
      AND Budget_Status_Code  = 'B'
      AND Budget_Type_Code    = p_Budget_Type_Code
      AND Version_Number      = l_Max_Version_Number - 1; --Bug 6524116
      EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
    END;
  ELSE
    l_Prev_Budget_Version_ID := NULL;
  END IF;

PA_FCK_UTIL.debug_msg('after selecting max version number  ..........'||to_char(l_max_version_number));
PA_FCK_UTIL.debug_msg('after selecting prev_budget_version_id  ..........'||to_char(l_prev_budget_version_id));
PA_FCK_UTIL.debug_msg('p_calling_mode ......'||p_calling_mode);
PA_FCK_UTIL.debug_msg('P_Budget_Version_ID ......'||P_Budget_Version_ID);
PA_FCK_UTIL.debug_msg('l_Project_Start_Date ......'||l_Project_Start_Date);
PA_FCK_UTIL.debug_msg('l_Project_End_Date ......'||l_Project_End_Date);

  IF P_Calling_Mode = 'BASELINE'
  THEN
    --------------------------------------------------+
    -- Create Budget Line records in PA_BUDGET_LINES
    --  whose GL Periods are not existing ...
    -- NOT REQUIRED TO GENERATE : 04/23/01
    --------------------------------------------------+
PA_FCK_UTIL.debug_msg(' before calling .... Insert_Into_Budget_Lines ');
    PA_BUDGET_ACCOUNT_PKG.Insert_Into_Budget_Lines (
             P_Budget_Version_ID,
             P_Project_ID,
             l_Project_Start_Date,
             l_Project_End_Date,
             l_Return_Status,
	     l_Msg_Count,
	     l_Msg_Data );
  END IF;

PA_FCK_UTIL.debug_msg('after calling insert into budget lines  ..........');
  ------------------------------------------------------------+
  --  Delete all account lines from PA_BUDGET_ACCT_LINES
  --  pertaining to a given Current Budget Version ID
  ------------------------------------------------------------+
  IF P_Calling_Mode in ('SUBMIT','GENERATE_ACCOUNT') then
    DELETE FROM PA_BUDGET_ACCT_LINES
    WHERE  Budget_Version_ID = p_Budget_Version_ID;
  END IF;

PA_FCK_UTIL.debug_msg('after deleting from budget acct lines  ..........');
  l_Error_Flag := 'N' ;
PA_FCK_UTIL.debug_msg('budget version id  '||to_char(p_budget_version_id) );


-- Following code has been added to take care of the scenario where
-- 'Account generator' is called to change the accounts
--  At this point of time, we should check whether the account on the
-- budget line can be changed ..

 l_txn_exists_against_project := 'N';

 If (P_Calling_Mode in ('SUBMIT','GENERATE_ACCOUNT') and
     nvl(l_balance_type,'B') = 'E'        and
     nvl(l_Budget_Amount_Code,'R') = 'C'  and
     l_Prev_Budget_Version_ID is not null
    ) then -- I

     PA_FCK_UTIL.debug_msg('Check if txns. exists ..');
     -- Check if txn. exists against the project
     -- This needs to be done only if its a re-baseline

      Begin -- II

       Select 'Y'
       into l_txn_exists_against_project
       from dual where exists (select 1
                               from   pa_bc_balances
                               where  budget_version_id = l_Prev_Budget_Version_ID
                               and    balance_type <> 'BGT');
      Exception
        When no_data_found then
             Begin -- III
               Select 'Y'
               into l_txn_exists_against_project
               from dual where exists (select 1
                                       from   pa_bc_packets
                                       where  budget_version_id = l_Prev_Budget_Version_ID
                                       and    status_code in ('P','Z','A','I'));
             Exception
                When no_data_found then
                     null;
             End; -- III
      End; -- II
  End If; -- I

  PA_FCK_UTIL.debug_msg('l_txn_exists_against_project:['||l_txn_exists_against_project||']');
  PA_FCK_UTIL.debug_msg('P_Budget_Entry_Level_Code:'||P_Budget_Entry_Level_Code);


  FOR bl IN cur_All_Budget_Lines  -- Loop thru every Budget Line
  LOOP

    l_Return_Status := FND_API.G_RET_STS_SUCCESS;

    ----------------------------------------------------------------------------+
    -- Call API Gen_Acct_Line to generate CCID for each Budget Line
    ----------------------------------------------------------------------------+
    IF (p_Calling_Mode IN ('BASELINE','SUBMIT') AND bl.CCID_old IS NULL ) OR
       (P_Calling_Mode = 'GENERATE_ACCOUNT')
    THEN

PA_FCK_UTIL.debug_msg('before calling gen_acct_line ..........');
        PA_BUDGET_ACCOUNT_PKG.Gen_Acct_Line (
           P_Budget_Entry_Level_Code,
           P_Budget_Type_Code,
           P_Budget_Version_ID,

           P_Project_ID,
           l_Project_Number,
           l_Project_Org_Name,
           l_Project_Org_ID,
           l_Project_Type,
	   l_Project_Class_Code, /* Added for bug 2914197 */
           bl.Task_ID,

           bl.Resource_List_Flag,
           bl.Resource_Type,
           bl.Resource_Group_ID,
           bl.Resource_Assignment_ID,
           bl.Start_Date,

           bl.Person_ID,
           bl.Expenditure_Category,
           bl.Expenditure_Type,
           bl.Job_ID,
           bl.Organization_ID,
           bl.Supplier_ID,

           l_CCID,
           l_Return_status,
	   l_Msg_Count,
	   l_Msg_Data,

           l_Concat_Segs,
           l_Concat_IDs,
           l_Concat_Descrs,
           l_Error_Message
        );

PA_FCK_UTIL.debug_msg(to_char(l_ccid)||' l_ccid  ..........(after calling gen_acct_line )');
PA_FCK_UTIL.debug_msg((l_error_message)||' l_error_message  ..........(after calling gen_acct_line )');
PA_FCK_UTIL.debug_msg((l_return_status)||' l_return_status  ..........(after calling gen_acct_line )');


       -- Following code added to validate the accounts that are being generated ..
       -- If txn. exists against the budget line then account change is not allowed ..
        IF (l_Return_Status = FND_API.G_RET_STS_SUCCESS  and
            l_txn_exists_against_project = 'Y' and
            P_Calling_Mode in ('SUBMIT','GENERATE_ACCOUNT')
            )  then   -- I


              --IF P_Calling_Mode = 'GENERATE_ACCOUNT' then ----------------------------------------------------+
               Begin

                  PA_FCK_UTIL.debug_msg('Retrieve ccid from latest budget version');

                  select code_combination_id
                  into   l_prev_ccid
                  from   pa_budget_lines pbl,
                         pa_resource_assignments pra
                  where  pra.budget_version_id       = l_Prev_Budget_Version_ID
                  and    pra.resource_list_member_id = bl.resource_list_member_id
                  and    pra.project_id             = p_project_id
                  and    pra.task_id                = bl.task_id
                  and    pbl.budget_version_id      = pra.budget_version_id
                  and    pbl.resource_assignment_id = pra.resource_assignment_id
                  and    pbl.start_date             = bl.start_date
                  and    pbl.txn_currency_code      = bl.txn_currency_code;

                  PA_FCK_UTIL.debug_msg('Retrieved ccid from latest budget version:'||l_prev_ccid);

              Exception
                  when no_data_found then
                       PA_FCK_UTIL.debug_msg('Retrieve ccid from latest budget version .. failed');

                       -- this can happen if the old budget version did not have data
                       l_prev_ccid := -99;

              End;
             --END IF; ---------------------------------------------------------------------------+

              If nvl(l_prev_ccid,-99) <> l_ccid then -- II

                 PA_FCK_UTIL.debug_msg('Calling pa_funds_control_utils.is_Account_change_allowed2 ..');
                 PA_FCK_UTIL.debug_msg('Period_name ['||bl.period_name||'] Task_id ['||bl.task_id||'] RLMI ['
                                        ||bl.resource_list_member_id||']');

                 IF pa_funds_control_utils.is_Account_change_allowed2
                  (p_budget_version_id       => l_Prev_Budget_Version_ID,
                   p_project_id              => p_project_id,
                   p_top_task_id             => bl.top_task_id,
                   p_task_id                 => bl.task_id,
                   p_parent_resource_id      => bl.parent_resource_id,
                   p_resource_list_member_id => bl.resource_list_member_id,
                   p_start_date              => bl.start_date,
                   p_period_name             => bl.period_name,
                   p_entry_level_code        => P_Budget_Entry_Level_Code,
                   p_mode                    => 'FORM') = 'N'
                  THEN -- III

                      PA_FCK_UTIL.debug_msg('pa_funds_control_utils.is_Account_change_allowed2 failed');
                      If nvl(l_prev_ccid,-99) <> -99 then -- IV

                         -- Basically assigning the old value back ....
                         PA_FCK_UTIL.debug_msg('Assigning old value back');
                         l_ccid := l_prev_ccid;

                      Else
                           l_Return_Status := FND_API.G_RET_STS_ERROR;
                           l_error_flag    := 'Y';

                           select description
                           into   l_Error_message
                           from   pa_lookups
                           where  lookup_type = 'FC_RESULT_CODE'
                           and lookup_code = 'F169';

                           l_Error_message := l_Error_message;

                           PA_FCK_UTIL.debug_msg('F169: ccid['||l_ccid||'] for task['||bl.task_number||'] resource ['||bl.resource_name||'] period ['||bl.period_name||']');
                           PA_FCK_UTIL.debug_msg('Failed validation: ccid['||l_ccid||'] for task_id['||bl.task_id||'] top task ['||bl.top_task_id||
                                                  '] resource ['||bl.resource_list_member_id||'] parent rlmi ['|| bl.parent_resource_id||']');

                      End If; -- IV

                  End If;  -- III

            End If; -- II

      End If; -- I

        IF l_Return_Status = FND_API.G_RET_STS_SUCCESS
        THEN
           UPDATE PA_BUDGET_LINES
           SET    Code_Combination_ID     = l_CCID,
                  CCID_Gen_Status_Code    = 'Y'
           WHERE  Resource_Assignment_ID  = bl.Resource_Assignment_ID AND
                  Start_Date              = bl.Start_Date ;
        ELSE
	   l_Error_Flag := 'Y' ;

           if ( l_Return_Status = FND_API.G_RET_STS_UNEXP_ERROR ) then

           UPDATE PA_BUDGET_LINES
           SET    CCID_Gen_Rej_Message = l_Msg_Data,
                  CCID_Gen_Status_Code    = 'N'
           WHERE  Resource_Assignment_ID  = bl.Resource_Assignment_ID AND
                  Start_Date              = bl.Start_Date ;

           else

           UPDATE PA_BUDGET_LINES
           SET    CCID_Gen_Rej_Message = l_Error_message,
                  CCID_Gen_Status_Code    = 'N'
           WHERE  Resource_Assignment_ID  = bl.Resource_Assignment_ID AND
                  Start_Date              = bl.Start_Date ;

           end if;
        END IF;
    ELSE
	-- Otherwise use the existing old CCID value available in the Bdgt Line
        l_CCID := bl.CCID_Old ;
    END IF;

    begin
      SELECT 'Y'
      INTO l_is_cc_budget
      FROM pa_budgetary_control_options
      WHERE project_id = p_Project_ID
        AND Budget_Type_Code = p_Budget_Type_Code
        AND EXTERNAL_BUDGET_CODE = 'CC'
        AND BDGT_CNTRL_FLAG = 'Y';
    exception
      WHEN NO_DATA_FOUND then
        l_is_cc_budget := 'N';
    end;

    IF (l_Return_Status = FND_API.G_RET_STS_SUCCESS and
        (P_Calling_Mode in ('SUBMIT','GENERATE_ACCOUNT')
         or (P_Calling_Mode in ('BASELINE') and l_is_cc_budget = 'Y'))) then

      -- Update the Budget and Available balance amounts
      PA_BUDGET_ACCOUNT_PKG.Upd_Budget_Acct_Line (
          p_Budget_Type_Code,
          p_Project_ID,
          bl.Period_Name,
	  bl.Start_Date,
	  bl.End_Date,
          l_CCID,
          p_Budget_Version_ID,
          l_Prev_Budget_Version_ID,
          bl.Total_Amount,
          l_Return_Status,
          l_Msg_Count,
          l_Msg_Data
      );
      IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS
      THEN
	l_Error_Flag := 'Y' ;
      END IF;
    END IF;

  END LOOP ;

  X_Msg_Count     := l_Msg_Count    ;
  X_Msg_Data      := l_Msg_Data     ;
-----------------------------------------------------------+
-- if atleast one row exists in pa_budget_lines with
-- CCID_Gen_Status_Code as 'N' then return error message
-----------------------------------------------------------+
  IF l_Error_Flag = 'Y'
  THEN
    raise l_acc_gen_error;
  END IF;

    BEGIN
      X_Return_Status := FND_API.G_RET_STS_SUCCESS ;
      IF (l_Prev_Budget_Version_ID IS NOT NULL and P_Calling_Mode in ('SUBMIT','GENERATE_ACCOUNT')) then
        INSERT INTO PA_BUDGET_ACCT_LINES (
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
          accounted_amount,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          CREATION_DATE,
          CREATED_BY
         )
         SELECT
	   PA_BUDGET_ACCT_LINES_S.nextval,
	   P_Budget_Version_ID,
	   BL1.GL_Period_Name,
	   BL1.Start_Date,
	   BL1.End_Date,
	   BL1.Code_Combination_ID,
	   BL1.Curr_Ver_Budget_Amount,
	   BL1.Curr_Ver_Available_Amount,
	   0,
	   -- Prev_Ver_Budget_Amount - Prev_Ver_Available_Amount,   -- Bug # 2008368
	   0, -- Curr_Ver_Available_Amount
	   /* -- Commented for bug 30399850 - BL1.Curr_Ver_Available_Amount, -- Accounted Amount */
           0 - BL1.Curr_Ver_Budget_Amount, /* Accounted Amount Added for bug3039985 */
	   sysdate,
	   -1,
	   -1,
	   sysdate,
	   -1
         FROM
	   PA_BUDGET_ACCT_LINES BL1
         WHERE
	     BL1.Budget_Version_ID = l_Prev_Budget_Version_ID
	 AND NOT EXISTS
		  ( SELECT 'x'
		    FROM   PA_BUDGET_ACCT_LINES BL2
		    WHERE  BL2.Code_Combination_ID = BL1.Code_Combination_ID
		    AND    BL2.Budget_Version_ID   = P_Budget_Version_ID
		    AND    BL2.Start_Date          = BL1.Start_Date ) ;
      END IF;
    END;

PA_FCK_UTIL.debug_msg('Exiting Gen_Acct_All_Lines  ..........');
  RETURN;

  EXCEPTION

    WHEN  l_no_budgetary_control THEN
      PA_UTILS.Add_Message('PA', 'PA_BC_NO_BGT_CNTL');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'PA_BC_NO_BGT_CNTL';
      x_msg_count := 1;

    WHEN  l_acc_gen_error THEN
      PA_UTILS.Add_Message('PA', 'PA_BC_ACC_GEN_ERROR');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data :=  'PA_BC_ACC_GEN_ERROR';
      x_msg_count := 1;

    WHEN OTHERS THEN
      X_Msg_Count     := 1;
      X_Msg_Data      := SUBSTR(SQLERRM, 1, 240);
      X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_Exc_msg( P_Pkg_Name         => 'PA_BUDGET_ACCOUNT_PKG',
                               P_Procedure_Name   => 'Gen_Acct_All_Lines');

END Gen_Acct_All_Lines ; /* End of Gen_Acct_All_Lines API */

PROCEDURE Gen_Acct_Line (

  P_Budget_Entry_Level_Code  IN   PA_Budget_Entry_Methods.Entry_Level_Code%TYPE,
  P_Budget_Type_Code         IN   PA_Budget_Types.Budget_Type_Code%TYPE,
  P_Budget_Version_ID        IN   PA_Budget_Versions.Budget_Version_ID%TYPE,

  P_Project_ID               IN   PA_Projects_All.Project_ID%TYPE,
  P_Project_Number           IN   PA_Projects_All.Segment1%TYPE,
  P_Project_Org_Name         IN   HR_Organization_Units.Name%TYPE,
  P_project_Org_ID           IN   HR_Organization_Units.Organization_ID %TYPE,
  P_Project_Type             IN   PA_Project_Types_All.Project_Type%TYPE,
  P_Project_Class_Code       IN   PA_Project_Classes.Class_Code%TYPE,  /* added for bug 2914197 */
  P_Task_ID                  IN   PA_Tasks.Task_ID%TYPE,

  P_Resource_List_Flag       IN   VARCHAR2,
  P_Resource_Type_ID         IN   PA_Resource_Types.Resource_Type_Code%TYPE,
  P_Resource_Group_ID        IN   PA_Resource_Types.Resource_Type_ID%TYPE,
  P_Resource_Assign_ID       IN   PA_Budget_Lines.Resource_Assignment_Id%TYPE,
  P_Start_Date               IN   PA_Budget_Lines.Start_Date%TYPE,

  P_Person_ID                IN   PER_All_People_F.Person_ID%TYPE,
  P_Expenditure_Category     IN   PA_Expenditure_Categories.Expenditure_Category%TYPE,
  P_Expenditure_Type         IN   PA_Expenditure_Types.Expenditure_Type%TYPE,
  P_Job_ID                   IN   PER_Jobs.Job_ID%TYPE,
  P_Organization_ID          IN   HR_All_Organization_Units.Organization_ID%TYPE,
  P_Supplier_ID              IN   PO_Vendors.Vendor_ID%TYPE,

  X_Return_CCID              OUT  NOCOPY GL_Code_Combinations.Code_Combination_ID%TYPE,
  X_Return_Status            OUT  NOCOPY VARCHAR2,
  X_Msg_Count                OUT  NOCOPY NUMBER,
  X_Msg_Data                 OUT  NOCOPY VARCHAR2,

  X_Concat_Segs              OUT  NOCOPY VARCHAR2,
  X_Concat_IDs               OUT  NOCOPY VARCHAR2,
  X_Concat_Descrs            OUT  NOCOPY VARCHAR2,
  X_Error_Message            OUT  NOCOPY VARCHAR2
)

IS

-- Local Parameters
l_Itemtype                   CONSTANT VARCHAR2(30) := 'PABDACWF' ;
l_Itemkey                    VARCHAR2(30);
l_result                     BOOLEAN;
l_Concat_segs                VARCHAR2(200);
l_Concat_Ids                 VARCHAR2(200);
l_Concat_Descrs              VARCHAR2(500);
l_Error_message              VARCHAR2(100);
l_return_Ccid                GL_Code_Combinations.code_Combination_Id%TYPE;

l_top_task_Id                pa_tasks.task_Id%TYPE;
l_top_task_number            pa_tasks.task_number%TYPE;
l_task_org_name              hr_organization_units.name%TYPE;
l_task_org_Id                hr_organization_units.organization_Id %TYPE;
l_task_service_type          pa_tasks.service_type_Code%TYPE;

l_low_task_Id                pa_tasks.task_Id%TYPE;
l_low_task_number            pa_tasks.task_number%TYPE;

l_Employee_number            per_All_people_F.employee_number%TYPE;

-- Added in FP_M for CWK changes
l_Person_Type                PA_Employees.Person_Type%TYPE;

l_Job_name                   per_Jobs.name%TYPE;
l_Job_Group_Id               per_Jobs.job_Group_Id%TYPE;
l_Job_Group_name             per_Job_Groups.internal_name%TYPE;

l_organization_name          hr_organization_units.name%TYPE;
l_organization_type          hr_organization_units.type%TYPE;

l_supplier_name              po_vendors.vendor_name%TYPE;

l_Chart_of_Accounts_Id       NUMBER; -- Eg. 50234;

l_msg_Index_out              NUMBER;

l_Return_Status              VARCHAR2(50);
l_Msg_Count                  NUMBER;
l_Msg_Data                   VARCHAR2(500);
l_code_combination           BOOLEAN;

BEGIN

PA_FCK_UTIL.debug_msg('Entering Gen_Acct_Lines  ..........');
  l_Return_Status := FND_API.G_RET_STS_SUCCESS;

  ------------------------------------------------------------------+
  -- Derive Task Parameters only when Top Task Details are present.
  ------------------------------------------------------------------+
  IF NVL(p_Task_ID, 0) <> 0
  THEN
    ----------------------------------------------------------------------------------+
    -- Check the given task ID is whether Top task or Low Task ?
    -- If given Task_Id = Top Task id, then it is a top task budgeting, so
    -- don't need Low Task Details. In this case, Low Task ID should be NULL.
    -- OTHERWIESE if it is a low task budgeting, then derive the Low Task Details also
    ----------------------------------------------------------------------------------+
    BEGIN
      SELECT
	top_task_Id,
	DECODE(task_Id, top_task_Id, NULL, task_Id)
      INTO
	l_top_task_Id,
	l_low_task_Id
      FROM
	PA_Tasks
      WHERE
	   task_Id     = p_task_Id
      AND  project_Id  = p_project_Id ;
    END;

PA_FCK_UTIL.debug_msg(l_return_status||' gen before calling Derive_Task_Params  ..........');
    ------------------------------------------------+
    -- Now Derive Task Parameters and their Details
    ------------------------------------------------+
    PA_BUDGET_ACCOUNT_PKG.Derive_Task_Params (
       p_project_Id             => p_project_Id,
       p_top_task_Id            => l_top_task_Id,
       p_low_task_Id            => l_low_task_Id,
       x_top_task_number        => l_top_task_number,
       x_task_organization_Id   => l_task_org_Id,
       x_task_organization_name => l_task_org_name,
       x_task_service_type      => l_task_service_type,
       x_task_number            => l_low_task_number,
       X_return_status          => l_Return_Status,
       X_Msg_Count              => l_Msg_Count,
       X_Msg_Data               => l_Msg_Data
    );
PA_FCK_UTIL.debug_msg(l_return_status||' gen after calling Derive_Task_Params  ..........');
  END IF;

PA_FCK_UTIL.debug_msg(l_return_status||' gen before calling derive_res_para  ..........');
  ------------------------------------------------+
  -- Derive Resource Parameters and their Details
  ------------------------------------------------+
  PA_BUDGET_ACCOUNT_PKG.Derive_Resource_Params (
       p_person_Id              => p_person_Id,
       p_Job_Id                 => p_Job_Id,
       p_organization_Id        => p_organization_Id,
       p_supplier_Id            => p_supplier_Id,
       x_Employee_number        => l_Employee_number,
       x_Person_Type		=> l_Person_Type,  -- Added in FP_M for CWK changes
       x_Job_name               => l_Job_name,
       x_Job_Group_Id           => l_Job_Group_Id,
       x_Job_Group_name         => l_Job_Group_name,
       x_organization_type      => l_organization_type,
       x_organization_name      => l_organization_name,
       x_supplier_name          => l_supplier_name,
       X_return_status          => l_Return_Status,
       X_Msg_Count              => l_Msg_Count,
       X_Msg_Data               => l_Msg_Data
    );

PA_FCK_UTIL.debug_msg(l_return_status||' gen after calling derive_res_para  ..........');
  select sob.chart_of_accounts_id
  into    l_chart_of_accounts_id
  from  pa_implementations imp, gl_sets_of_books  sob
  where imp.set_of_books_id = sob.set_of_books_id;

PA_FCK_UTIL.debug_msg(l_return_status||' gen after getting chart of account id ..........');
  -------------------------------------+
  -- Call API FND initialize function
  -------------------------------------+
  l_Itemkey := fnd_Flex_workflow.initialize
                  (appl_short_name => 'SQLGL',
                   code            => 'GL#',
                   num             => l_Chart_of_Accounts_Id,
                   itemtype        => l_Itemtype);


PA_FCK_UTIL.debug_msg(l_return_status||' gen after calling initialize  ..........');
  ------------------------------------------------------------+
  -- BEGIN: Initialize / Set ALL the workflow item attributes
  ------------------------------------------------------------+

  wf_Engine.SetItemAttrNumber( itemtype   => l_Itemtype,
                               itemkey    => l_Itemkey,
                               aname      => 'CHART_OF_ACCOUNTS_ID',
                               avalue     => l_Chart_of_Accounts_Id);

PA_FCK_UTIL.debug_msg(l_return_status||' gen after calling set CHART_OF_ACCOUNTS_ID  ..........');
  --------------------------------------------------------+
  -- Set Item Attributes for workflow items BUDGET DETAILS
  --------------------------------------------------------+
  wf_Engine.SetItemAttrText( itemtype  => l_Itemtype,
                             itemkey   => l_Itemkey,
                             aname     => 'BUDGET_TYPE',
                             avalue    => p_Budget_type_Code);

PA_FCK_UTIL.debug_msg(l_return_status||' gen after calling set BUDGET_TYPE  ..........');
  wf_Engine.SetItemAttrText( itemtype  => l_Itemtype,
                             itemkey   => l_Itemkey,
                             aname     => 'BUDGET_ENTRY_LEVEL',
                             avalue    => p_Budget_Entry_Level_Code);
PA_FCK_UTIL.debug_msg(l_return_status||' gen after calling set BUDGET_ENTRY_LEVEL  ..........');

  wf_Engine.SetItemAttrText( itemtype  => l_Itemtype,
                             itemkey   => l_Itemkey,
                             aname     => 'BUDGET_VERSION_ID',
                             avalue    => p_Budget_version_Id);

PA_FCK_UTIL.debug_msg(l_return_status||' gen after calling set BUDGET_VERSION_ID  ..........');
  ---------------------------------------------------------+
  -- Set Item Attributes for workflow items PROJECT DETAILS
  ---------------------------------------------------------+
  wf_Engine.SetItemAttrNumber( itemtype  => l_Itemtype,
                               itemkey   => l_Itemkey,
                               aname     => 'PROJECT_ID',
                               avalue    => p_project_Id);

PA_FCK_UTIL.debug_msg(l_return_status||' gen after calling set PROJECT_ID  ..........');
  wf_Engine.SetItemAttrText( itemtype  => l_Itemtype,
                             itemkey   => l_Itemkey,
                             aname     => 'PROJECT_NUMBER',
                             avalue    => p_project_number);

PA_FCK_UTIL.debug_msg(l_return_status||' gen after calling set PROJECT_NUMBER  ..........');
  wf_Engine.SetItemAttrText( itemtype  => l_Itemtype,
                             itemkey   => l_Itemkey,
                             aname     => 'PROJECT_ORG_NAME',
                             avalue    => p_project_org_name);

  wf_Engine.SetItemAttrNumber( itemtype  => l_Itemtype,
                               itemkey   => l_Itemkey,
                               aname     => 'PROJECT_ORG_ID',
                               avalue    => p_project_org_Id);

/* Code Addition for bug 2914197 starts */
  wf_Engine.SetItemAttrText( itemtype  => l_Itemtype,
                             itemkey   => l_Itemkey,
                             aname     => 'CLASS_CODE',
                             avalue    => p_project_class_code);
/* Code Addition for bug 2914197 starts */

  wf_Engine.SetItemAttrText( itemtype  => l_Itemtype,
                             itemkey   => l_Itemkey,
                             aname     => 'PROJECT_TYPE',
                             avalue    => p_project_type);

PA_FCK_UTIL.debug_msg(l_return_status||' gen after set PROJECT DETAILS  ..........');
  ----------------------------------------------------------+
  -- Set Item Attributes for workflow items TOP TASK DETAILS
  ----------------------------------------------------------+
  wf_Engine.SetItemAttrNumber( itemtype  => l_Itemtype,
                               itemkey   => l_Itemkey,
                               aname     => 'TOP_TASK_ID',
                               avalue    => l_top_task_Id);

  wf_Engine.SetItemAttrText( itemtype  => l_Itemtype,
                             itemkey   => l_Itemkey,
                             aname     => 'TOP_TASK_NUMBER',
                             avalue    => l_top_task_number);

  wf_Engine.SetItemAttrText( itemtype  => l_Itemtype,
                             itemkey   => l_Itemkey,
                             aname     => 'TASK_SERVICE_TYPE',
                             avalue    => l_task_service_type);

  wf_Engine.SetItemAttrNumber( itemtype  => l_Itemtype,
                               itemkey   => l_Itemkey,
                               aname     => 'TASK_ORG_ID',
                               avalue    => l_task_org_Id);

  wf_Engine.SetItemAttrText( itemtype  => l_Itemtype,
                             itemkey   => l_Itemkey,
                             aname     => 'TASK_ORG_NAME',
                             avalue    => l_task_org_name);

PA_FCK_UTIL.debug_msg(l_return_status||' gen after set TOP TASK DETAILS  ..........');
  ----------------------------------------------------------+
  -- Set Item Attributes for workflow items LOW TASK DETAILS
  ----------------------------------------------------------+
PA_FCK_UTIL.debug_msg('low_task_id '||to_char(l_low_task_Id));
PA_FCK_UTIL.debug_msg('l_low_task_number *'||l_low_task_number||'*');
  wf_Engine.SetItemAttrNumber( itemtype  => l_Itemtype,
                               itemkey   => l_Itemkey,
                               aname     => 'LOW_TASK_ID',
                               avalue    => l_low_task_Id);

PA_FCK_UTIL.debug_msg(l_return_status||' gen after set LOW TASK ID  ..........');
  wf_Engine.SetItemAttrText( itemtype  => l_Itemtype,
                               itemkey   => l_Itemkey,
                               aname     => 'LOW_TASK_NUMBER',
                               avalue    => l_low_task_number);

PA_FCK_UTIL.debug_msg(l_return_status||' gen after set LOW TASK NUMBER  ..........');
  --------------------------------------------------------------------------+
  -- Set ALL resource related Item Attributes if Resource List Flag is TRUE
  --------------------------------------------------------------------------+
  IF p_resource_list_Flag = 'Y' THEN
    wf_Engine.SetItemAttrText ( itemtype  => l_Itemtype,
                                itemkey   => l_Itemkey,
                                aname     => 'RESOURCE_LIST_FLAG',
                                avalue    => 'Y');

    wf_Engine.SetItemAttrText ( itemtype  => l_Itemtype,
                                itemkey   => l_Itemkey,
                                aname     => 'RESOURCE_TYPE',
                                avalue    => p_resource_type_Id);

    wf_Engine.SetItemAttrText ( itemtype  => l_Itemtype,
                                itemkey   => l_Itemkey,
                                aname     => 'RESOURCE_GROUP_ID',
                                avalue    => p_resource_Group_Id);

    wf_Engine.SetItemAttrText ( itemtype  => l_Itemtype,
                                itemkey   => l_Itemkey,
                                aname     => 'RESOURCE_ASSIGNMENT_ID',
                                avalue    => p_resource_Assign_Id);

    wf_Engine.SetItemAttrText ( itemtype  => l_Itemtype,
                                itemkey   => l_Itemkey,
                                aname     => 'BUDGET_LINE_START_DATE',
                                avalue    => p_start_Date);

PA_FCK_UTIL.debug_msg(l_return_status||' gen after set RESOURCE LIST DETAILS  ..........');
     --------------------------------------------------------------------------+
     -- Set Item Attributes for workflow items PERSON/EMPLOYEE DETAILS (Resource Type)
     --------------------------------------------------------------------------+
     wf_Engine.SetItemAttrNumber( itemtype  => l_Itemtype,
                                  itemkey   => l_Itemkey,
                                  aname     => 'PERSON_ID',
                                  avalue    => p_person_Id);

     wf_Engine.SetItemAttrText( itemtype  => l_Itemtype,
                                itemkey   => l_Itemkey,
                                aname     => 'EMPLOYEE_NUMBER',
                                avalue    => l_Employee_number);

     -- This attribute is added for FP_M Build2 for Contingent Labor changes
     -- to get the Person Type value from WorkFlow
     wf_Engine.SetItemAttrText( itemtype  => l_Itemtype,
                                itemkey   => l_Itemkey,
                                aname     => 'PERSON_TYPE',
                                avalue    => l_Person_Type);

PA_FCK_UTIL.debug_msg(l_return_status||' gen after set PERSON/EMPLOYEE LIST DETAILS  ..........');
PA_FCK_UTIL.debug_msg(l_return_status||' p_expenditure_type ... '||p_Expenditure_type);
     -----------------------------------------------------------------------+
     -- Set Item Attributes for workflow items EXPENDITURE CATEGORY DETAILS
     -----------------------------------------------------------------------+
     wf_Engine.SetItemAttrText( itemtype  => l_Itemtype,
                                itemkey   => l_Itemkey,
                                aname     => 'EXPENDITURE_CATEGORY',
                                avalue    => p_Expenditure_Category);

     -------------------------------------------------------------------+
     -- Set Item Attributes for workflow items EXPENDITURE TYPE DETAILS
     -------------------------------------------------------------------+
     wf_Engine.SetItemAttrText( itemtype  => l_Itemtype,
                                itemkey   => l_Itemkey,
                                aname     => 'EXPENDITURE_TYPE',
                                avalue    => p_Expenditure_type);

     ----------------------------------------------------------------------+
     -- Set Item Attributes for workflow items JOB DETAILS (Resource Type)
     ----------------------------------------------------------------------+
     wf_Engine.SetItemAttrNumber( itemtype  => l_Itemtype,
                                  itemkey   => l_Itemkey,
                                  aname     => 'JOB_ID',
                                  avalue    => p_Job_Id);

     wf_Engine.SetItemAttrText( itemtype  => l_Itemtype,
                                itemkey   => l_Itemkey,
                                aname     => 'JOB_NAME',
                                avalue    => l_Job_name);

     wf_Engine.SetItemAttrNumber( itemtype  => l_Itemtype,
                                  itemkey   => l_Itemkey,
                                  aname     => 'JOB_GROUP_ID',
                                  avalue    => l_Job_Group_Id);

     wf_Engine.SetItemAttrText( itemtype  => l_Itemtype,
                                itemkey   => l_Itemkey,
                                aname     => 'JOB_GROUP_NAME',
                                avalue    => l_Job_Group_name);

PA_FCK_UTIL.debug_msg(l_return_status||' gen after set EXP CAT/DETAIL JOB DETAILS  ..........');
     ------------------------------------------------------------------------------+
     -- Set Item Attributes for workflow items ORGANIZATION DETAILS (Resource Type)
     ------------------------------------------------------------------------------+
     wf_Engine.SetItemAttrNumber( itemtype  => l_Itemtype,
                                  itemkey   => l_Itemkey,
                                  aname     => 'ORGANIZATION_ID',
                                  avalue    => p_organization_Id);

     wf_Engine.SetItemAttrText( itemtype  => l_Itemtype,
                                itemkey   => l_Itemkey,
                                aname     => 'ORGANIZATION_NAME',
                                avalue    => l_organization_name);

     wf_Engine.SetItemAttrText( itemtype  => l_Itemtype,
                                itemkey   => l_Itemkey,
                                aname     => 'ORGANIZATION_TYPE',
                                avalue    => l_organization_type);

     --------------------------------------------------------------------------+
     -- Set Item Attributes for workflow items SUPPLIER DETAILS (Resource Type)
     --------------------------------------------------------------------------+
     wf_Engine.SetItemAttrNumber( itemtype  => l_Itemtype,
                                  itemkey   => l_Itemkey,
                                  aname     => 'SUPPLIER_ID',
                                  avalue    => p_supplier_Id);

     wf_Engine.SetItemAttrText( itemtype  => l_Itemtype,
                                itemkey   => l_Itemkey,
                                aname     => 'SUPPLIER_NAME',
                                avalue    => l_supplier_name);

  END IF; -- Setting of all resource list item attributes is completed.
  ----------------------------------------------------------------------------+
  -- END: Initialize / Set ALL the workflow item attributes and Resource Types
  ----------------------------------------------------------------------------+

PA_FCK_UTIL.debug_msg(l_return_status||' gen before calling generate  ..........');
  --------------------------------------------------------------------------------+
  -- Call the workflow Generate function to trigger off the w/f account generation
  --------------------------------------------------------------------------------+
/*Modified the call to generate function to resolve bug 2266072.Added
parameter TRUE to insert_if_new argument */

  l_result := fnd_Flex_workflow.generate( l_Itemtype,
                                          l_Itemkey,
                                          TRUE,
                                          l_return_Ccid,
                                          l_Concat_segs,
                                          l_Concat_Ids,
                                          l_Concat_Descrs,
                                          l_Error_message,
                                          l_code_combination);

if l_result then
PA_FCK_UTIL.debug_msg(' gen success  ..........');
else
PA_FCK_UTIL.debug_msg(' gen failure  ..........');
end if;
PA_FCK_UTIL.debug_msg(to_char(l_return_ccid)||' gen l_ccid  ..........');
PA_FCK_UTIL.debug_msg((l_error_message)||' gen l_error_message  ..........');
  ------------------------------------------------------------------+
  -- Copy the return values to the corresponding output parameters
  ------------------------------------------------------------------+

  x_Concat_segs    := l_Concat_segs;
  x_Concat_Ids     := l_Concat_Ids;
  x_Concat_Descrs  := l_Concat_Descrs;
  x_Error_message  := l_Error_message;
  x_return_Ccid    := l_return_ccid;

  X_Msg_Count     := l_Msg_Count    ;
  X_Msg_Data      := l_Msg_Data     ;
  X_Return_Status := l_Return_Status;

  -------------------------------------------------+
  -- Set the value for x_return_status accordingly
  -------------------------------------------------+

  IF l_result
  THEN
      x_return_status := 'S';
  ELSE
      x_return_status := 'E';
  END IF;

PA_FCK_UTIL.debug_msg('Exiting Gen_Acct_Lines  ..........');
  RETURN;

  EXCEPTION
    WHEN OTHERS THEN
PA_FCK_UTIL.debug_msg(' Unexpected Error ..........');
PA_FCK_UTIL.debug_msg(SUBSTR(SQLERRM, 1, 240));
      X_Msg_Count     := 1;
      X_Msg_Data      := SUBSTR(SQLERRM, 1, 240);
      X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.add_Exc_msg( P_Pkg_Name         => 'PA_BUDGET_ACCOUNT_PKG',
                               P_Procedure_Name   => 'Gen_Acct_Line');

    ------------------------------------------------------------------------------+
    -- W/F related Error:
    -- Record error using generic error message routine for debugging and raise it
    ------------------------------------------------------------------------------+
    wf_Core.context( pkg_name   => 'PA_BUDGET_ACCOUNT_PKG',
                     proc_name  => 'Gen_Acct_Line',
                     arg1       =>  'Budget Version ID : '|| p_Budget_version_Id,
                     arg2       =>  'Project ID        : '|| p_project_Id,
                     arg3       =>  null,
                     arg4       =>  null,
                     arg5       =>  null );

END Gen_Acct_Line ; /* End API Gen_Acct_Line */

PROCEDURE Upd_Budget_Acct_Line (
  p_Budget_Type_Code         IN   PA_Budget_Types.Budget_Type_Code%TYPE,
  p_Project_ID               IN	  PA_Projects_All.Project_ID%TYPE,
  p_Period_Name       	     IN   GL_PERIODS.period_name%TYPE,
  p_Start_Date		     IN   DATE,
  p_End_Date		     IN   DATE,
  P_CCID                     IN   gl_Code_Combinations.code_Combination_Id%TYPE,
  P_Budget_Version_ID        IN   pa_Budget_versions.budget_version_Id%TYPE,
  p_Prev_Budget_Version_ID   IN   pa_Budget_versions.budget_version_Id%TYPE,
  p_Amount                   IN   NUMBER,
  X_Return_Status            OUT  NOCOPY VARCHAR2,
  X_Msg_Count                OUT  NOCOPY NUMBER,
  X_Msg_Data                 OUT  NOCOPY VARCHAR2
)
AS

-- Local Parameters
l_Prev_Ver_Budget_Amount     NUMBER := 0;
l_Prev_Ver_Available_Amount  NUMBER := 0;

l_Budget_Acct_Line_ID	     NUMBER ;
l_update_count	     NUMBER ;

l_msg_Index_out              NUMBER;
l_Return_Status              VARCHAR2(50);
l_Msg_Count                  NUMBER;
l_Msg_Data                   VARCHAR2(500);

BEGIN

  l_Return_Status := FND_API.G_RET_STS_SUCCESS;

PA_FCK_UTIL.debug_msg('Entering Upd_Budget_Acct_Line ...... ');
  -------------------------------------------------------------------------------+
  -- Update a record for a combination of ( Budget_Verison, GL_Period and CCID )
  -- If No_Data_Found then create a new record
  -------------------------------------------------------------------------------+

PA_FCK_UTIL.debug_msg(' bdg_ver, p_start_date, p_ccid .. '||to_char(p_Budget_Version_ID)||' , '||to_char(p_Start_Date,'DD-MON-YYYY')||' , '||to_char(p_CCID));
  BEGIN
    UPDATE
       PA_BUDGET_ACCT_LINES
    SET
       Curr_Ver_Budget_Amount    = Curr_Ver_Budget_Amount    + p_Amount,
       Curr_Ver_Available_Amount = Curr_Ver_Available_Amount + p_Amount,
       accounted_amount          = accounted_amount + p_Amount
    WHERE
        Budget_Version_ID      = p_Budget_Version_ID
    AND Start_Date	       = p_Start_Date
    AND	Code_Combination_ID    = p_CCID ;

  l_update_count := SQL%ROWCOUNT;

PA_FCK_UTIL.debug_msg('updated pa_budget_acct_line ......row  '||to_char(l_update_count));
PA_FCK_UTIL.debug_msg('previous budget version id ......row  '||to_char(p_prev_budget_version_id));

    IF l_update_count = 0 THEN
PA_FCK_UTIL.debug_msg(' record not found ');
      -- Check the prev. Baselined budget record in PA_BUDGET_ACCT_LINES table
      IF p_Prev_Budget_Version_ID IS NOT NULL
      THEN
        BEGIN
          SELECT
            Curr_Ver_Budget_Amount,
            Curr_Ver_Available_Amount
          INTO
            l_Prev_Ver_Budget_Amount,
            l_Prev_Ver_Available_Amount
          FROM
            PA_BUDGET_ACCT_LINES
          WHERE
               Budget_Version_ID	= p_Prev_Budget_Version_ID
          AND  Start_Date		= p_Start_Date
          AND  Code_Combination_ID	= p_CCID;
          EXCEPTION WHEN NO_DATA_FOUND THEN
            l_Prev_Ver_Budget_Amount    := 0;
            l_Prev_Ver_Available_Amount := 0;
        END;
      ELSE
        l_Prev_Ver_Budget_Amount    := 0;
        l_Prev_Ver_Available_Amount := 0;
      END IF;

PA_FCK_UTIL.debug_msg(' p_b_amt, p_av_amt '||to_char(l_Prev_Ver_Budget_Amount)||','||to_char(l_Prev_Ver_Budget_Amount) );

      INSERT INTO PA_BUDGET_ACCT_LINES (
	     Budget_Acct_Line_ID,
      	     Budget_Version_ID,
      	     GL_Period_Name,
	     Start_Date,
	     End_Date,
      	     Code_Combination_ID,
	     Prev_Ver_Budget_Amount,
	     Prev_ver_Available_Amount,
	     Curr_Ver_Budget_Amount,
	     Curr_ver_Available_Amount,
	     Accounted_Amount,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          CREATION_DATE,
          CREATED_BY
           )
       VALUES (
	     PA_BUDGET_ACCT_LINES_S.nextval,
      	     p_Budget_Version_ID,
      	     p_Period_Name,
	     p_Start_Date,
	     p_End_Date,
      	     p_CCID,
	     l_Prev_Ver_Budget_Amount,
	     l_Prev_Ver_Available_Amount,
	     p_Amount,
	     -- p_Amount - (l_Prev_Ver_Budget_Amount-l_Prev_Ver_Available_Amount),
	     p_Amount,  -- Bug # 2008368 Curr_ver_Available_Amount
	     p_Amount - l_Prev_Ver_Available_Amount, -- Accounted Amount
          sysdate,
          -1,
          -1,
          sysdate,
          -1
           );
    END IF;
  END;

  X_Msg_Count     := l_Msg_Count    ;
  X_Msg_Data      := l_Msg_Data     ;
  X_Return_Status := l_Return_Status;

  RETURN;

  EXCEPTION
  WHEN OTHERS THEN
PA_FCK_UTIL.debug_msg(' failed with the error '||SUBSTR(SQLERRM, 1, 240));
      X_Msg_Count     := 1;
      X_Msg_Data      := SUBSTR(SQLERRM, 1, 240);
      X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.add_Exc_msg( P_Pkg_Name         => 'PA_BUDGET_ACCOUNT_PKG',
                               P_Procedure_Name   => 'Upd_Budget_Acct_Line');

END Upd_Budget_Acct_Line; /* End API UPD_Budget_Acct_Line */

PROCEDURE Insert_Into_Budget_Lines (
  P_Budget_Version_ID        IN   PA_Budget_Versions.Budget_Version_ID%TYPE,
  P_Project_ID               IN   PA_projects_All.project_Id%TYPE,
  P_Project_Start_Date       IN   DATE,
  P_Project_End_Date         IN   DATE,
  X_Return_Status            OUT  NOCOPY VARCHAR2,
  X_Msg_Count                OUT  NOCOPY NUMBER,
  X_Msg_Data                 OUT  NOCOPY VARCHAR2
)
IS

-- Local Parameters

l_Return_Status              VARCHAR2(50);
l_Msg_Count                  NUMBER;
l_Msg_Data                   VARCHAR2(500);

l_Gl_period_name             GL_PERIODS.period_name%TYPE;
l_Gl_start_Date              DATE;
l_Gl_End_Date                DATE;

t_Gl_start_Date              DATE;
t_Gl_End_Date                DATE;

l_Task_ID                    NUMBER;
l_Resource_Assignment_ID     NUMBER;
l_Count                      NUMBER := 0;
l_quantity                   NUMBER := 0;
l_raw_Cost                   NUMBER := 0;
l_Burdened_Cost              NUMBER := 0;
l_revenue                    NUMBER := 0;
l_rowid                      VARCHAR2(50);

l_msg_Index_out              NUMBER;

l_BL_Max_Date                DATE;
l_Boundary_Code              VARCHAR2(1);
l_Set_Of_Books_Id            pa_implementations_all.set_of_books_id%type;

  ------------------------------------------------------------------------------+
  -- Cursor to fetch all missed GL Periods for a given Res. Assign ID and Start Date
  ------------------------------------------------------------------------------+
  CURSOR cur_GL_Periods IS
  SELECT
    RA1.Resource_Assignment_ID    RESOURCE_ASSIGNMENT_ID,
    nvl(RA1.Task_ID, -1)          TASK_ID,
    RA1.Resource_List_Member_ID   RESOURCE_LIST_MEMBER_ID,
    GLPRD.Period_Name             PERIOD_NAME,
    GLPRD.Start_Date              START_DATE,
    GLPRD.End_Date                END_DATE
  FROM
    GL_Period_Statuses            GLPRD,
    PA_Implementations            IMP,
    PA_Resource_Assignments       RA1
  WHERE
       GLPRD.Application_ID       = PA_Period_Process_Pkg.Application_ID -- 101
  AND  GLPRD.Set_Of_Books_ID      = IMP.Set_Of_Books_ID
  AND  GLPRD.Closing_status IN ('O','F')
  AND  ( l_GL_Start_Date  BETWEEN GLPRD.Start_Date AND GLPRD.End_Date OR
         l_GL_End_Date    BETWEEN GLPRD.Start_Date AND GLPRD.End_Date OR
         GLPRD.Start_Date BETWEEN l_GL_Start_Date  AND l_GL_End_Date )
  AND  GLPRD.Adjustment_Period_Flag <> 'Y' -- Bug #1891179
  AND  RA1.Project_ID             = P_Project_ID
  AND  RA1.Budget_Version_ID      = p_Budget_Version_ID
  MINUS
  SELECT
    BL2.Resource_Assignment_ID    RESOURCE_ASSIGNMENT_ID,
    nvl(RA2.Task_ID, -1)          TASK_ID,
    RA2.Resource_List_Member_ID   RESOURCE_LIST_MEMBER_ID,
    BL2.Period_Name               PERIOD_NAME,
    BL2.Start_Date                START_DATE,
    BL2.End_Date                  END_DATE
  FROM
    PA_Budget_Lines               BL2,
    PA_Resource_Assignments       RA2,
    GL_Period_Statuses            GLPRD2,
    PA_Implementations            IMP2
  WHERE
       RA2.Resource_Assignment_ID = BL2.Resource_Assignment_ID
  AND  RA2.Project_ID             = P_Project_ID
  AND  RA2.Budget_Version_ID      = p_Budget_Version_ID
  AND  GLPRD2.Period_Name         = BL2.Period_Name
  AND  GLPRD2.Application_ID      = PA_Period_Process_Pkg.Application_ID -- 101
  AND  GLPRD2.Closing_status      IN ('O','F')
  AND  GLPRD2.Adjustment_Period_Flag <> 'Y' -- Bug #1891179
  AND  GLPRD2.Set_Of_Books_ID     = IMP2.Set_Of_Books_ID ;

BEGIN

PA_FCK_UTIL.debug_msg(' Entering Insert_Into_Budget_Lines ');
  l_Return_Status := FND_API.G_RET_STS_SUCCESS;

PA_FCK_UTIL.debug_msg('P_Budget_Version_ID ......'||P_Budget_Version_ID);
PA_FCK_UTIL.debug_msg('P_Project_Id ......'||P_Project_Id);
PA_FCK_UTIL.debug_msg('p_Project_Start_Date ......'||P_Project_Start_Date);
PA_FCK_UTIL.debug_msg('p_Project_End_Date ......'||p_Project_End_Date);

  IF P_Project_Start_Date IS NULL OR
     P_Project_End_Date   IS NULL
  THEN

    SELECT  PBCO.boundary_code
    INTO    l_boundary_code
    FROM    PA_BUDGETARY_CONTROL_OPTIONS   PBCO,
            PA_BUDGET_VERSIONS             PBV
    WHERE   PBV.Project_Id        = p_project_id
    AND     PBV.Budget_version_id = p_Budget_version_id
    AND     PBCO.Project_id       = PBV.Project_id
    AND     PBCO.Budget_Type_Code = PBV.Budget_Type_Code;


    IF nvl(l_boundary_code,'P') = 'Y' then
       PA_FCK_UTIL.debug_msg(' Boundary code is Year');

       SELECT MAX(BL.End_Date)
       INTO   l_BL_Max_Date
       FROM   PA_Budget_Lines  BL
       WHERE  BL.Budget_Version_ID = p_Budget_Version_ID;

       PA_FCK_UTIL.debug_msg(' Max. end date is:'||l_BL_Max_Date);

       Select set_of_books_id into l_set_of_books_id from pa_implementations;

       PA_FCK_UTIL.debug_msg(' SOB ID:' ||l_set_of_books_id);

       SELECT gps.year_start_date,
              ADD_MONTHS (gps.year_start_date, 12 ) - 1
       INTO   t_GL_Start_Date,
              t_GL_End_Date
       FROM   gl_period_statuses gps
       WHERE  gps.application_id   = PA_Period_Process_Pkg.Application_ID
       AND    gps.set_of_books_id  = l_set_of_books_id
       AND    l_BL_Max_Date BETWEEN gps.start_date AND gps.end_date
       AND    gps.adjustment_period_flag = 'N';

    ELSE
       PA_FCK_UTIL.debug_msg(' Boundary code is not Year');

        SELECT
          MIN(BL.start_Date),  -- decode(p_Start_Date, NULL, MIN(BL.start_Date), p_Start_Date)
          MAX(BL.End_Date)     -- decode(p_End_Date, NULL, MAX(BL.End_Date), p_End_Date)
        INTO
          t_GL_Start_Date,
          t_GL_End_Date
        FROM
          PA_Budget_Lines           BL,
          PA_Resource_Assignments   RA
        WHERE
	  RA.Budget_Version_ID      = p_Budget_Version_ID
        AND RA.Resource_Assignment_ID = BL.Resource_Assignment_ID ;

    END IF;

    PA_FCK_UTIL.debug_msg(' selected max bl start and end date ');

    IF p_Project_Start_Date IS NULL
    THEN
      l_GL_Start_Date := t_GL_Start_Date ;
      else
      l_GL_Start_Date := p_Project_Start_Date ;
    END IF;
    IF p_Project_End_Date IS NULL
    THEN
      l_Gl_End_Date := t_Gl_End_Date ;
      else
      l_Gl_End_Date := p_Project_End_Date ;
    End IF;
  ELSE
     l_GL_Start_Date := P_Project_Start_Date;
     l_GL_End_Date := P_Project_End_Date;
  END IF;

PA_FCK_UTIL.debug_msg(' start_date '||to_char(l_GL_Start_Date)||' end date '||to_char(l_Gl_End_Date));
  FOR GlPrds IN cur_GL_Periods -- For every missed GL Periods
  LOOP

    l_Resource_Assignment_ID := GlPrds.Resource_Assignment_ID ;
    ----------------------------------------------------------------------+
    -- Call table handler for inserting into PA_BUDGET_LINES with amount=0
    ----------------------------------------------------------------------+
    BEGIN

PA_FCK_UTIL.debug_msg(' res_id  '||to_char(l_Resource_Assignment_ID)||' start date '||to_char(GlPrds.Start_Date));
PA_FCK_UTIL.debug_msg(' P_Budget_Version_ID  '||P_Budget_Version_ID);
PA_FCK_UTIL.debug_msg(' GlPrds.Period_Name  '||GlPrds.Period_Name);

      IF GlPrds.Task_ID = -1 then
	 l_Task_ID  := NULL;
      ELSE
	 l_Task_ID  := GlPrds.Task_ID ;
      END IF;

      PA_BUDGET_LINES_V_PKG.Insert_Row(
	 X_ROWID                       => l_rowid,
	 X_Resource_Assignment_Id      => l_Resource_Assignment_ID,
	 X_Budget_Version_Id           => P_Budget_Version_ID,
	 X_Project_Id                  => P_Project_ID,
         X_Task_Id                     => l_Task_ID,
         X_Resource_List_Member_Id     => GlPrds.Resource_List_Member_Id,
         X_Description                 => NULL,
	 X_Start_Date                  => GlPrds.Start_Date,
	 X_End_Date                    => GlPrds.End_Date,
	 X_Period_Name                 => GlPrds.Period_Name,
         X_Quantity                    => l_quantity,
         X_Unit_Of_Measure             => NULL,
         X_Track_As_Labor_Flag         => NULL,
         X_Raw_Cost                    => l_raw_Cost,
         X_Burdened_Cost               => l_Burdened_Cost,
         X_Revenue                     => l_revenue,
         X_Change_Reason_Code          => NULL,
         X_Last_Update_Date            => SYSDATE,
         X_Last_Updated_By             => -1,
         X_Creation_Date               => SYSDATE,
         X_Created_By                  => -1,
         X_Last_Update_Login           => -1,
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
         X_Calling_Process             => 'PR',
	 X_Pm_Product_Code             => NULL,
	 X_Pm_Budget_Line_Reference    => NULL,
         X_raw_Cost_source             => 'M',
	 X_Burdened_Cost_source        => 'M',
	 X_quantity_source             => 'M',
	 X_revenue_source              => 'M',
         x_standard_Bill_rate          => NULL,
         x_Average_Bill_rate           => NULL,
         x_Average_Cost_rate           => NULL,
         x_project_Assignment_Id       => -1,
         x_plan_Error_Code             => NULL,
         x_total_plan_revenue          => NULL,
         x_total_plan_raw_Cost         => NULL,
         x_total_plan_Burdened_Cost    => NULL,
         x_total_plan_quantity         => NULL,
         x_Average_Discount_percentage => NULL,
         x_Cost_rejection_Code         => NULL,
         x_Burden_rejection_Code       => NULL,
         x_revenue_rejection_Code      => NULL,
         x_other_rejection_Code        => NULL);
		 -- Bug Fix: 4569365. Removed MRC code.
		 -- ,x_mrc_flag                    => 'Y'   /* FPB2 MRC */
         -- );

PA_FCK_UTIL.debug_msg(' after insert res_id  '||to_char(l_Resource_Assignment_ID)||' start date '||to_char(GlPrds.Start_Date));
    END;

  END LOOP; -- End of cursor Missed GL Periods

  X_Msg_Count     := l_Msg_Count    ;
  X_Msg_Data      := l_Msg_Data     ;
  X_Return_Status := l_Return_Status;

  RETURN;

  EXCEPTION
  WHEN OTHERS THEN
PA_FCK_UTIL.debug_msg(' ERROR INSERT_INTO_BUDGET_LINES '||SQLERRM);
      X_Msg_Count     := 1;
      X_Msg_Data      := SUBSTR(SQLERRM, 1, 240);
      X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.add_Exc_msg( P_Pkg_Name         => 'PA_BUDGET_ACCOUNT_PKG',
                               P_Procedure_Name   => 'Insert_Into_Budget_Lines');
END Insert_Into_Budget_Lines ; /* End API Insert_Into_Budget_Lines */

PROCEDURE Derive_Resource_Params (
  p_person_Id                IN   per_All_people_F.person_Id%TYPE,
  p_Job_Id                   IN   per_Jobs.job_Id%TYPE,
  p_organization_Id          IN   hr_All_organization_units.organization_Id%TYPE,
  p_supplier_Id              IN   po_vendors.vendor_Id%TYPE,
  x_Employee_number          OUT  NOCOPY per_All_people_F.employee_number%TYPE,
  x_Person_Type		     OUT  NOCOPY PA_Employees.Person_Type%TYPE,
  x_Job_name                 OUT  NOCOPY per_Jobs.name%TYPE,
  x_Job_Group_Id             OUT  NOCOPY per_Jobs.job_Group_Id%TYPE,
  x_Job_Group_name           OUT  NOCOPY per_Job_Groups.internal_name%TYPE,
  x_organization_type        OUT  NOCOPY hr_All_organization_units.type%TYPE,
  x_organization_name        OUT  NOCOPY hr_All_organization_units.name%TYPE,
  x_supplier_name            OUT  NOCOPY po_vendors.vendor_name%TYPE,
  X_Return_Status            OUT  NOCOPY VARCHAR2,
  X_Msg_Count                OUT  NOCOPY NUMBER,
  X_Msg_Data                 OUT  NOCOPY VARCHAR2
)
AS

--Local Parameters
l_msg_Index_out              NUMBER;

l_Return_Status              VARCHAR2(50);
l_Msg_Count                  NUMBER;
l_Msg_Data                   VARCHAR2(500);

BEGIN

  l_Return_Status := FND_API.G_RET_STS_SUCCESS;

  -----------------------------------------------------------------------+
  -- Derive Employee/Person Parameters if Resource Type: EMPLOYEE
  -----------------------------------------------------------------------+
  -- Here logic has been modified for FP_M Build 2 changes to incorporate
  -- the Person Type value for validating the person as Employee or Contractor
  -- These changes are for Contingent Labor
  IF P_Person_ID IS NOT NULL THEN
    BEGIN
      SELECT
	Decode(Current_NPW_Flag, 'Y', NPW_Number, Employee_Number),
	Decode(Current_NPW_Flag, 'Y', 'CWK', 'EMP') Person_Type  -- FP_M changes
      INTO
	X_Employee_Number,
	X_Person_Type	-- FP_M changes
      FROM
	PER_All_People_F
      WHERE
	Person_ID  =  P_Person_ID
      AND (Current_Employee_Flag = 'Y' OR Current_NPW_Flag = 'Y');  -- FP_M changes
    END;
  END IF;

  -----------------------------------------------------------------------+
  -- Derive Job Parameters if Resource Type: JOB
  -----------------------------------------------------------------------+
  IF p_Job_ID IS NOT NULL THEN
    BEGIN
      SELECT
	JOB.Name            JOB_NAME,
        JOB.Job_Group_ID    JOB_GROUP_ID,
        JBGRP.Internal_Name JOB_GROUP_NAME
      INTO
	X_Job_Name,
        X_Job_Group_ID,
        X_Job_Group_Name
      FROM
	PER_Jobs            JOB,
        PER_Job_Groups      JBGRP
      WHERE
	   JOB.job_Id       = p_Job_Id
      AND  JOB.job_Group_Id = JBGRP.job_Group_Id ;
    END;
  END IF;

  -----------------------------------------------------------------------+
  -- Derive organization name if Resource Type: ORGANIZATION
  -----------------------------------------------------------------------+
  IF p_organization_Id IS NOT NULL THEN
    BEGIN
      SELECT
	ORG.name                   ORG_NAME,
        ORG.Type                   ORG_TYPE
      INTO
	x_organization_name,
        x_organization_type
      FROM
	HR_All_organization_units  ORG
      WHERE
	   ORG.organization_Id     = P_Organization_ID;
    END;
  END IF;

  -----------------------------------------------------------------------+
  -- Derive Supplier/vendor information for Resource Type : SUPPLIER
  -----------------------------------------------------------------------+
  IF p_supplier_Id IS NOT NULL THEN
    BEGIN
      SELECT
	SUP.Vendor_Name SUPPLIER_NAME
      INTO
	X_Supplier_Name
      FROM
	PO_Vendors      SUP
      WHERE
	SUP.Vendor_ID   = P_Supplier_ID;
     END;
  END IF;

  X_Msg_Count     := l_Msg_Count    ;
  X_Msg_Data      := l_Msg_Data     ;
  X_Return_Status := l_Return_Status;

  RETURN;

  EXCEPTION
  WHEN OTHERS THEN
      x_msg_Count     := 1;
      x_msg_Data      := substr(SQLERRM, 1, 240);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.add_Exc_msg( p_pkg_name         => 'PA_BUDGET_ACCOUNT_PKG',
                               p_procedure_name   => 'Derive_Resource_Params');

END Derive_Resource_Params ; /* End API Derive_Resource_Params */

PROCEDURE Derive_Task_Params (
  p_project_Id               IN   pa_projects_All.project_Id%TYPE,
  p_top_task_Id              IN   pa_tasks.task_Id%TYPE,
  p_low_task_Id              IN   pa_tasks.task_Id%TYPE,
  x_top_task_number          OUT  NOCOPY pa_tasks.task_number%TYPE,
  x_task_organization_Id     OUT  NOCOPY hr_organization_units.organization_Id%TYPE,
  x_task_organization_name   OUT  NOCOPY hr_organization_units.name%TYPE,
  x_task_service_type        OUT  NOCOPY pa_tasks.service_type_Code%TYPE,
  x_task_number              OUT  NOCOPY pa_tasks.task_number%TYPE,
  X_Return_Status            OUT  NOCOPY VARCHAR2,
  X_Msg_Count                OUT  NOCOPY NUMBER,
  X_Msg_Data                 OUT  NOCOPY VARCHAR2
)
AS

--Local Parameters
l_msg_Index_out              NUMBER;

l_Return_Status              VARCHAR2(50);
l_Msg_Count                  NUMBER;
l_Msg_Data                   VARCHAR2(500);

BEGIN

  l_Return_Status := FND_API.G_RET_STS_SUCCESS;

  --------------------------------------------------------------------+
  -- Derive Top Task parameters if Top Task ID is passed
  --------------------------------------------------------------------+
  IF P_Top_Task_ID IS NOT NULL THEN
    BEGIN
      SELECT
	TOP_TASK.task_number         TASK_NUMBER,
        ORG.Organization_Id          TASK_ORGANIZATION_ID,
        ORG.Name                     TASK_ORGANIZATION_NAME,
        TOP_TASK.Service_Type_Code   TASK_SERVICE_TYPE
      INTO
	X_Top_Task_Number,
        X_Task_Organization_ID,
        X_Task_Organization_Name,
        X_Task_Service_Type
      FROM
	HR_All_Organization_Units    ORG,
        PA_Tasks                     TOP_TASK
      WHERE
	   TOP_TASK.task_Id     =  p_top_task_Id
      AND  TOP_TASK.Top_Task_ID =  TOP_TASK.Task_ID
      AND  TOP_TASK.Project_ID  =  p_project_Id
      AND  ORG.organization_Id  =  TOP_TASK.carrying_out_organization_Id;
    END;
  END IF;

  --------------------------------------------------------------------+
  -- Derive Low Task parameters if Low task id is passed
  --------------------------------------------------------------------+
  IF p_low_task_Id IS NOT NULL THEN
    BEGIN
      SELECT
	TASK.task_number  TASK_NUMBER
      INTO
	x_task_number
      FROM
	PA_Tasks          TASK
      WHERE
	   TASK.task_Id      =  p_low_task_Id;
    END;
  END IF;

  X_Msg_Count     := l_Msg_Count    ;
  X_Msg_Data      := l_Msg_Data     ;
  X_Return_Status := l_Return_Status;

  RETURN;

  EXCEPTION
  WHEN OTHERS THEN
      x_msg_Count     := 1;
      x_msg_Data      := substr(SQLERRM, 1, 240);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.add_Exc_msg( p_pkg_name         => 'PA_BUDGET_ACCOUNT_PKG',
                               p_procedure_name   => 'Derive_Task_Params');

END Derive_Task_Params ; /* End API Derive_Task_Params */

END PA_BUDGET_ACCOUNT_PKG ; /* End Package Body PA_BUDGET_ACCOUNT_PKG */

/
