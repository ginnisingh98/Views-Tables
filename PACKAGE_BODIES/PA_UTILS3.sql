--------------------------------------------------------
--  DDL for Package Body PA_UTILS3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_UTILS3" AS
/* $Header: PAXGUT3B.pls 120.8.12010000.3 2011/01/18 13:16:07 ethella ship $ */

  G_Projects_Tab  Pa_Utils3.ProjectsTab;
  G_Tasks_Tab     Pa_Utils3.TasksTab;
  G_EmpInfo_Tab   Pa_Utils3.EmpInfoTab;
  G_OrgName_Tab   Pa_Utils3.OrgNameTab;
  G_OrgId_Tab     Pa_Utils3.OrgIdTab;
/* R12 Changes Start */
  G_OUName_Tab    PA_Utils3.OUNameTab;
/* R12 Changes End */

  Function Get_System_Linkage ( P_Expenditure_Type        IN varchar2,
                                P_System_Linkage_Function IN varchar2,
                                P_System_Linkage_M        IN varchar2 ) RETURN VARCHAR2
  Is

  	l_dummy NUMBER;

  Begin

  	Select 1
	Into l_dummy
  	From   pa_expenditure_types_expend_v
  	Where  expenditure_type = p_expenditure_type
  	And    system_linkage_function <> p_system_linkage_function;

  	Return ( '-' || p_system_linkage_m);

  Exception
    When NO_DATA_FOUND Then
      RETURN(NULL);
    When TOO_MANY_ROWS Then
      RETURN( '-' || p_system_linkage_m);

  End get_system_linkage;

  Procedure GetCachedProjNum (P_Project_Id     IN NUMBER,
                              X_Project_Number OUT NOCOPY VARCHAR2)

  Is

	l_Found 	BOOLEAN 	:= FALSE;

  Begin

	-- Check if there are any records in the pl/sql table.
 	If G_Projects_Tab.COUNT > 0 Then

	    Begin

		-- Get the Project Number from the pl/sql table.
		-- If there is no index with the value of the project_id passed
		-- in then an ora-1403: no_data_found is generated.
		X_Project_Number := G_Projects_Tab(P_Project_Id).Project_Number;
		l_Found := TRUE;

	    Exception
		When No_Data_Found Then
			l_Found := FALSE;
		When Others Then
			Raise;

	    End;

	End If;

	If Not l_Found Then

		-- Since the project has not been cached yet, will need to add it.
		-- So check to see if there are already 200 records in the pl/sql table.
		If G_Projects_Tab.COUNT > 199 Then

			G_Projects_Tab.Delete;

		End If;

		-- Get the project_number.
		Select
			Segment1
		Into
			X_Project_Number
		From
			Pa_Projects_All
		Where
			Project_Id = P_Project_Id;

		-- Add the project number to the pl/sql table using the project_id
		-- as the index value.  This makes things fast.
		G_Projects_Tab(P_Project_Id).Project_Number := X_Project_Number;

	End If;

  Exception
	When Others Then
		Raise;

  End GetCachedProjNum;

  Procedure GetCachedTaskNum (P_Task_Id     IN NUMBER,
                              X_Task_Number OUT NOCOPY VARCHAR2)

  Is

	l_Found 	BOOLEAN := FALSE;

  Begin

	-- Check if there are any records in the pl/sql table.
        If G_Tasks_Tab.COUNT > 0 Then

	    Begin

                -- Get the Task Number from the pl/sql table.
                -- If there is no index with the value of the task_id passed
                -- in then an ora-1403: no_data_found is generated.
                X_Task_Number := G_Tasks_Tab(P_Task_Id).Task_Number;
                l_Found := TRUE;

	    Exception
		When No_Data_Found Then
			l_Found := FALSE;
		When Others Then
			Raise;

	    End;

        End If;

        If Not l_Found Then

                -- Since the task has not been cached yet, will need to add it.
                -- So check to see if there are already 200 records in the pl/sql table.
                If G_Tasks_Tab.COUNT > 199 Then

                        G_Tasks_Tab.Delete;

                End If;

		-- Get the task number.
                Select
			Task_Number
                Into
			X_Task_Number
                From
			Pa_Tasks
                Where
			Task_Id = P_Task_Id;

                -- Add the task number to the pl/sql table using the task_id
                -- as the index value.  This makes things fast.
                G_Tasks_Tab(P_Task_Id).Task_Number := X_Task_Number;

        End If;

  Exception
        When Others Then
                Raise;

  End GetCachedTaskNum;

  Procedure GetCachedEmpInfo (P_Inc_By_Per_Id IN NUMBER,
                                   P_exp_date       IN DATE ,    --bug 9853319
                              X_Inc_By_Per_Number OUT NOCOPY VARCHAR2,
                              X_Business_Group_Name OUT NOCOPY VARCHAR2)

  Is

        l_Found         BOOLEAN := FALSE;

  Begin

	-- Check if there are any records in the pl/sql table.
        If G_EmpInfo_Tab.COUNT > 0 Then

	    Begin

                -- Get the Employee Number and business group from the pl/sql table.
                -- If there is no index with the value of the inc by person_id passed
                -- in then an ora-1403: no_data_found is generated.
		X_Inc_By_Per_Number   := G_EmpInfo_Tab(P_Inc_By_Per_Id).Employee_Number;
		X_Business_Group_Name := G_EmpInfo_Tab(P_Inc_By_Per_Id).Business_Group_Name;
		l_Found               := TRUE;

	    Exception
		When No_Data_Found Then
			l_Found := FALSE;
		When Others Then
			Raise;

	    End;

        End If;

        If Not l_Found Then

                -- Since the employee info has not been cached yet, will need to add it.
                -- So check to see if there are already 200 records in the pl/sql table.
                If G_EmpInfo_Tab.COUNT > 199 Then

                        G_EmpInfo_Tab.Delete;

                End If;

		-- Get the employee number/npw number and business group name
		-- If the current_employee_flag is 'N' then we are dealing with contingent worker
		-- and want to grab the npw_number inplace of the employee_number.
                Select
                	Decode(P.Current_Employee_Flag,'Y',P.Employee_Number,P.Npw_Number),
                	O.Name
                Into
                	X_Inc_By_Per_Number,
                	X_Business_Group_Name
                From
                        --FP M To reduce dependency on HR, changing the per_people_x to per_all_people_f
                        --and added the date check
                	--Per_People_X P,
                	Per_All_People_F P,
                	Hr_Organization_Units O
                Where
                	P.Person_Id       = P_Inc_By_Per_Id
                and     O.Organization_Id = P.Business_Group_Id
                and     trunc(P_exp_date) between trunc(p.effective_start_date) and trunc(p.effective_end_date);

                -- Add the employee info to the pl/sql table using the P_Inc_By_Per_Id
                -- as the index value.  This makes things fast.
                G_EmpInfo_Tab(P_Inc_By_Per_Id).Employee_Number     := X_Inc_By_Per_Number;
                G_EmpInfo_Tab(P_Inc_By_Per_Id).Business_Group_Name := X_Business_Group_Name;

        End If;

  Exception
	When Others Then
		Raise;

  End GetCachedEmpInfo;

  Procedure GetCachedOrgName (P_Inc_By_Per_Id IN NUMBER,
                              P_Exp_Item_Date IN DATE,
                              X_Inc_By_Org_Name OUT NOCOPY VARCHAR2)

  Is

        l_Found         BOOLEAN := FALSE;
        l_Index         BINARY_INTEGER;

  Begin

	-- Check if there are any records in the pl/sql table.
        If G_OrgName_Tab.COUNT > 0 Then

		-- Get the Inc by Org Name if it exist by looping thru the pl/sql table.
                For i in G_OrgName_Tab.First .. G_OrgName_Tab.Last
                Loop

                        If to_char(P_Inc_By_Per_Id) || to_char(P_Exp_Item_Date) = G_OrgName_Tab(i).PersonId_Date Then

                                X_Inc_By_Org_Name := G_OrgName_Tab(i).Org_Name;
                                l_Found := TRUE;
                                Exit;

                        End If;

                End Loop;

        End If;

        If Not l_Found Then

                -- Since the employee info has not been cached yet, will need to add it.
                -- So check to see if there are already 200 records in the pl/sql table.
                If G_OrgName_Tab.COUNT > 199 Then

                        G_OrgName_Tab.Delete;

                End If;

		-- Get the organization name
                Select
                	O.Name
                Into
                	X_Inc_By_Org_Name
                From
                	Per_Assignments_F A,
                	Hr_All_Organization_Units O
                Where
                	O.Organization_id = A.Organization_Id
                And     A.person_id = P_Inc_By_Per_Id
                And     A.Primary_Flag = 'Y'
                And     A.Organization_Id is not null
                And     A.Job_Id is not null
		And     A.Assignment_Type in ('E','C')
                And     P_Exp_Item_Date between A.Effective_Start_Date
                	     	    	    and nvl(A.Effective_End_Date, P_Exp_Item_Date) ;

		-- Find the next availabe index to use.
                l_Index := G_OrgName_Tab.COUNT + 1;

		-- Insert the employee info into the pl/sql table.
                G_OrgName_Tab(l_Index).PersonId_Date := to_char(P_Inc_By_Per_Id) || to_char(P_Exp_Item_Date);
		G_OrgName_Tab(l_Index).Org_Name      := X_Inc_By_Org_Name;

        End If;

  Exception
	When Others Then
		Raise;

  End GetCachedOrgName;

  Procedure GetCachedOrgId (P_Inc_By_Per_Id IN NUMBER,
                            P_Exp_Item_Date IN DATE,
                            X_Inc_By_Org_Id OUT NOCOPY NUMBER)

  Is

        l_Found         BOOLEAN := FALSE;
        l_Index         BINARY_INTEGER;
	l_Start_Date	DATE;
	l_End_Date	DATE;

  Begin

        -- Check if there are any records in the pl/sql table.
        If G_OrgId_Tab.COUNT > 0 Then

                -- Get the Inc by Org Id if it exist by looping thru the pl/sql table.
                For i in G_OrgId_Tab.First .. G_OrgId_Tab.Last
                Loop

                        If P_Inc_By_Per_Id = G_OrgId_Tab(i).Person_Id And
			   trunc(P_Exp_Item_Date) >= trunc(G_OrgId_Tab(i).Start_Date) And
			   trunc(P_Exp_Item_Date) <= trunc(nvl(G_OrgId_Tab(i).End_Date,P_Exp_Item_Date)) Then

                                X_Inc_By_Org_Id := G_OrgId_Tab(i).Org_Id;
                                l_Found := TRUE;
                                Exit;

                        End If;

                End Loop;

        End If;

        If Not l_Found Then

                -- Since the employee info has not been cached yet, will need to add it.
                -- So check to see if there are already 200 records in the pl/sql table.
                If G_OrgId_Tab.COUNT > 199 Then

                        G_OrgId_Tab.Delete;

                End If;

                -- Get the organization Id
                Select
                        Organization_Id,
			Effective_Start_Date,
			Effective_End_Date
                Into
                        X_Inc_By_Org_Id,
			l_Start_Date,
			l_End_Date
                From
                        Per_Assignments_F
                Where
                        Person_id = P_Inc_By_Per_Id
                And     Primary_Flag = 'Y'
                And     Organization_Id is not null
                And     Job_Id is not null
                And     Assignment_Type in ('E','C')
                And     P_Exp_Item_Date between Effective_Start_Date
                                            and nvl(Effective_End_Date, P_Exp_Item_Date) ;

                -- Find the next availabe index to use.
                l_Index := G_OrgId_Tab.COUNT + 1;

                -- Insert the employee info into the pl/sql table.
                G_OrgId_Tab(l_Index).Person_Id  := to_char(P_Inc_By_Per_Id);
		G_OrgId_Tab(l_Index).Start_Date := l_Start_Date;
		G_OrgId_Tab(l_Index).End_Date   := l_End_Date;
                G_OrgId_Tab(l_Index).Org_Id     := X_Inc_By_Org_Id;

        End If;

  Exception
        When Others Then
                Raise;

  End GetCachedOrgId;

  Function GetCachedProjNum (P_Project_Id IN NUMBER) RETURN pa_projects_all.segment1%TYPE
  Is
      l_Project_Number pa_projects_all.segment1%TYPE;
  Begin

     If P_Project_Id > 0 THEN
      GetCachedProjNum(P_Project_Id     => P_Project_Id,
                       X_Project_Number => l_Project_Number);
     END IF;

      return l_Project_Number;

  End GetCachedProjNum;

  Function GetCachedTaskNum (P_Task_Id IN NUMBER) RETURN pa_tasks.task_number%TYPE
  Is
      l_Task_Number pa_tasks.task_number%TYPE;
  Begin

     If P_Task_Id > 0 THEN
      GetCachedTaskNum(P_Task_Id     => P_Task_Id,
                       X_Task_Number => l_Task_Number);
     End If;

      Return l_Task_Number;

  End GetCachedTaskNum;

  Function GetEmpNum (P_Person_Id IN NUMBER,P_ei_date  IN DATE DEFAULT sysdate ) RETURN per_people_f.employee_number%TYPE      --bug 9853319
  Is
      l_emp_Number            Per_People_F.employee_number%TYPE;
      l_Business_Group_Name   Hr_Organization_Units.Name%TYPE;
  Begin

     If P_Person_Id > 0 THEN
      GetCachedEmpInfo (P_Inc_By_Per_Id       => P_Person_id,
      	                    P_Exp_Date            =>  P_ei_date ,             --bug 9853319
                        X_Inc_By_Per_Number   => l_emp_Number,
                        X_Business_Group_Name => l_Business_Group_Name);
     End If;

      Return l_emp_Number;

  End GetEmpNum;

-- Function to get the project and Task details of the Ei.
-- In case of adjusted Ei, the function returns the Project/Task
-- info of the new EI(Transferred To). And for the new Ei, it
-- returns the Project/Task info of the adj Ei(Transferred From).

  Function GetEiProjTask (P_exp_item_id   IN NUMBER,
                          P_Net_Zero_Flag IN VARCHAR2,
                          P_Transferred_from_exp_id IN NUMBER)
      RETURN VARCHAR2
        Is
     l_proj_task_info  VARCHAR2(100);
  Begin

    IF (P_Net_Zero_Flag = 'Y')
        OR ( P_Net_Zero_Flag = 'N' AND P_Transferred_from_exp_id >0) THEN
      IF P_Transferred_from_exp_id >0 THEN
      -- Transferred from project and Task Details.
       BEGIN
        SELECT proj.segment1||'/'||TASK.task_number
        INTO   l_proj_task_info
        FROM   pa_expenditure_items ei
              ,pa_projects_all proj
              ,pa_tasks task
        WHERE  ei.expenditure_item_id = P_Transferred_from_exp_id
        AND    ei.task_id = task.task_id
        AND    proj.project_id = task.project_id;
       EXCEPTION
        WHEN OTHERS THEN
         NULL;
       END;
      ELSE
      -- Transferred To project and Task Details.
       BEGIN
        SELECT proj.segment1||'/'||TASK.task_number
        INTO   l_proj_task_info
        FROM   pa_expenditure_items ei
              ,pa_projects_all proj
              ,pa_tasks task
        WHERE  ei.transferred_from_exp_item_id = P_exp_item_id
        AND    ei.task_id = task.task_id
        AND    proj.project_id = task.project_id;
       EXCEPTION
        WHEN OTHERS THEN
         NULL;
       END;
      END IF;
    END IF;
      RETURN  l_proj_task_info;
  End GetEiProjTask;
/***************************************************************************
   Procedure        : get_asset_addition_flag
   Purpose          : When Expense Reports are sent to AP from PA,
                      the intermediate tables ap_expense_report_headers_all
                      and ap_expense_report_lines_all are populated. A Process
                      process in AP then populates the
                      Invoice Distribution tables. As there is no way in the
                      intermediate tables, to find out if the expense report is
                      associated with a 'Capital Project', which should not be
                      interfaced from AP to FA, unlike Invoice Distribution line
                      table, where asset_addition_flag is used. This API is to
                      find out if the given project_id is a 'CAPITAL' project
                      and if so, populate the 'out' vairable to 'P', else 'U'.
   Arguments        : p_project_id            IN - project id
                      x_asset_addition_flag  OUT - asset addition flag
****************************************************************************/


PROCEDURE get_asset_addition_flag
             (p_project_id           IN  pa_projects_all.project_id%TYPE,
              x_asset_addition_flag  OUT NOCOPY ap_invoice_distributions_all.assets_addition_flag%TYPE)
IS

   l_project_type_class_code  pa_project_types_all.project_type_class_code%TYPE;

BEGIN

  /* For Given Project Id, Get the Project_Type_Class_Code depending on the Project_Type */
  SELECT  ptype.project_type_class_code
    INTO  l_project_type_class_code
    FROM  pa_project_types_all ptype,
          pa_projects_all      proj
   WHERE  ptype.project_type     = proj.project_type
     AND  NVL(ptype.org_id, -99) = NVL(proj.org_id, -99)
     AND  proj.project_id        = p_project_id;

   /* IF Project is CAPITAL then set asset_addition_flag to 'P' else 'U' */

   IF (l_project_type_class_code = 'CAPITAL') THEN

     x_asset_addition_flag  := 'P';

   ELSE

     x_asset_addition_flag  := 'U';

   END IF;

EXCEPTION

   WHEN OTHERS THEN
     RAISE;

END get_asset_addition_flag;

/***************************************************************************
   Function         : Get_Project_Type
   Purpose          : This function will check if the project id passed to this
                      is a 'CAPITAL' Project.If it is then this will return
                      'P' otherwise 'U'
   Arguments        : p_project_id            IN           - project id
                      Returns 'P' if the project is Capital otherwise 'U'
****************************************************************************/

FUNCTION Get_Project_Type
       (p_project_id IN pa_projects_all.project_id%TYPE)RETURN VARCHAR2 IS
l_project_type VARCHAR2(1);

BEGIN

/* For Given Project Id, Get the Project_Type_Class_Code depending on the Project_Type */

 SELECT decode(ptype.project_type_class_code,'CAPITAL','P','U')
  INTO  l_project_type
  FROM  pa_project_types_all ptype,
        pa_projects_all      proj
 WHERE proj.project_type = ptype.project_type
/* AND   NVL(ptype.org_id, -99) = NVL(proj.org_id, -99) commented and removed nvl to make use of the index also in R12, org is populated --Bug 5912873*/
   AND ptype.org_id = proj.org_id
 AND   proj.project_id   = p_project_id ;

 RETURN l_project_type;

 EXCEPTION
    WHEN OTHERS THEN
        RAISE;
  END Get_Project_Type;


/* R12 Changes Start */
/***************************************************************************
   Function         : GetPastEmpNum
   Purpose          : This function will get Past Employee Number.
   Arguments        : P_Person_Id IN Person_Id
                      P_ei_date  IN EXPENDITURE_ITEM_DATE DEFAULT sysdate
                      Returns Employee Number
****************************************************************************/

FUNCTION GetPastEmpNum
  ( P_Person_Id IN NUMBER,
    P_ei_date  IN DATE DEFAULT sysdate)
    RETURN  per_people_f.employee_number%TYPE IS

    l_emp_Number            Per_People_F.employee_number%TYPE;

  BEGIN

      IF P_Person_Id > 0 THEN
                Select
                	MAX(P.Employee_Number)
                Into
                	l_emp_Number
                From
                	Per_All_People_F P,
                	Hr_Organization_Units O
                Where
                	P.Person_Id       = P_Person_Id
                and     O.Organization_Id = P.Business_Group_Id
                and     trunc(P_ei_date) > = trunc(p.effective_start_date)
                AND     P.Employee_Number IS NOT NULL;

     END IF;

    RETURN l_emp_Number ;

EXCEPTION
   WHEN Others THEN
       Raise;
END GetPastEmpNum;
/* R12 Changes End */

/***************************************************************************
   Function         : GetCachedOUName
   Purpose          : This function caches Operating Unit Identifier and names
                      in a PL/SQL table and retrieves the OU Name using the
                      Org ID passedas a input parameter.
   Arguments        : P_Org_ID - Organization Identifier
   Return           : Operating Unit Name
 ***************************************************************************/
  FUNCTION GetCachedOUName (P_Org_ID HR_ALL_ORGANIZATION_UNITS_TL.ORGANIZATION_ID%TYPE)
  RETURN HR_ALL_ORGANIZATION_UNITS_TL.NAME%TYPE IS
    l_OU_Name HR_ALL_ORGANIZATION_UNITS_TL.NAME%TYPE;

    CURSOR C_GetOUName_Cur(P_Org_ID HR_ALL_ORGANIZATION_UNITS_TL.ORGANIZATION_ID%TYPE) IS
    SELECT Name
      FROM HR_ALL_ORGANIZATION_UNITS_TL
     WHERE Organization_ID = P_Org_ID
       AND Language = USERENV('LANG');
  BEGIN
    IF  G_OUName_Tab.COUNT > 0 THEN

      FOR i IN G_OUName_Tab.FIRST..G_OUName_Tab.LAST LOOP

        IF G_OUName_Tab(i).Org_ID = P_Org_ID THEN

          l_OU_Name := G_OUName_Tab(i).OU_Name;
          EXIT;

        END IF;

      END LOOP;

    END IF;

    IF l_OU_Name IS NULL THEN

      OPEN C_GetOUName_Cur(P_Org_ID);
      FETCH C_GetOUName_Cur INTO l_OU_Name;
      CLOSE C_GetOUName_Cur;

      G_OUName_Tab(NVL(G_OUName_Tab.LAST+1,0)).OU_Name := l_OU_Name;
      G_OUName_Tab(NVL(G_OUName_Tab.LAST+1,0)).Org_ID := P_Org_ID;

    END IF;

    RETURN l_OU_Name;

  END GetCachedOUName;

END pa_utils3;

/
