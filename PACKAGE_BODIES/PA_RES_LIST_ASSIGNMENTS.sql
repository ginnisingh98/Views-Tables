--------------------------------------------------------
--  DDL for Package Body PA_RES_LIST_ASSIGNMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RES_LIST_ASSIGNMENTS" AS
/* $Header: PARLASMB.pls 120.2.12010000.2 2008/11/03 11:08:44 rballamu ship $ */

 Procedure Create_Rl_Assgmt (X_Project_id  In Number,
                             X_Resource_list_id  In Number,
                             X_Resource_list_Assgmt_id Out NOCOPY Number, --File.Sql.39 bug 4440895
                             X_err_code  IN  Out NOCOPY Number, --File.Sql.39 bug 4440895
                             X_err_stage IN  Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                             x_err_stack IN  Out NOCOPY Varchar2 ) Is --File.Sql.39 bug 4440895
W_Assgmt_Id Number := 0;
W_num       Number := 0;
Old_stack varchar2(630);
W_End_Date Date;
W_User_id   Number := 0;
W_Login_id  Number := 0;
Cursor Proj_Cur is
        Select Project_Id from Pa_Projects_all -- changed for bug 6743458
        where Project_id = X_Project_Id;
Cursor Res_List_Cur is
        Select End_Date_Active  from PA_RESOURCE_LISTS
        where Resource_list_Id = X_Resource_List_id;
 Begin
        X_Resource_list_Assgmt_id := 0;
        W_User_id := To_Number(FND_PROFILE.VALUE('USER_ID'));
        W_login_id := To_Number(FND_PROFILE.VALUE('LOGIN_ID'));
        X_err_code := 0;
        Old_Stack := X_Err_Stack;
       X_err_stack := X_err_stack ||'->PA_RES_LIST_ASSIGNMENTS.Create_Rl_Asgmt';
        x_err_stage := 'Select Project_id from Pa_Projects '||
                       To_Char(X_project_id);
        Open Proj_Cur;
        Fetch Proj_Cur into W_Num;
        If Proj_Cur%NOTFOUND Then
           x_err_code := 10;
           x_err_stage := 'PA_RE_PROJ_NOT_FOUND';
           Close Proj_Cur;
           Return;
        End If;
        Close Proj_Cur;
        x_err_stage := 'Select End_date_Active from Pa_Resource_lists '||
                       To_Char(X_resource_list_id);
        Open Res_List_Cur;
        Fetch Res_List_Cur into W_End_Date;
        If Res_list_Cur%NOTFOUND Then
           x_err_code := 11;
           x_err_stage := 'PA_RE_RL_NOT_FOUND';
           Close Res_list_Cur;
           Return;
       End If;
       If W_End_Date is not Null Then
          If Trunc(W_End_date) < Trunc(Sysdate) Then
             x_err_code := 12;
             x_err_stage := 'PA_RE_RL_INACTIVE';
             Close Res_list_Cur;
             Return;
          End If;
       End If;
       Close Res_List_Cur;
       x_err_stage := ' Get_Rl_assgmt ';
       Get_Rl_Assgmt (X_Project_id,
                      X_Resource_list_id,
                      W_Assgmt_Id,
                      X_err_code,
                      X_err_stage,
                      x_err_stack);
       If W_Assgmt_Id = 0 Then
          x_err_stage := 'Select pa_resource_list_assignments_s.nextval';
          Select Pa_Resource_list_Assignments_s.nextval into W_num
          from Dual;
          x_err_stage := 'Insert into Pa_Resource_list_assignments ';
          Insert into Pa_Resource_list_Assignments
          (RESOURCE_LIST_ASSIGNMENT_ID,RESOURCE_LIST_ID,PROJECT_ID,
           RESOURCE_LIST_CHANGED_FLAG,LAST_UPDATED_BY,LAST_UPDATE_DATE,
           CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN,
           RESOURCE_LIST_ACCUMULATED_FLAG) Values
           (W_Num,X_Resource_list_id,X_project_id,'N',Nvl(W_user_id,-1),
           Trunc(Sysdate),Trunc(Sysdate),
           Nvl(W_user_id ,-1),Nvl(W_login_id,-1),'N');
           X_Resource_list_Assgmt_id := W_num;
       Else
           X_Resource_list_Assgmt_id := W_Assgmt_Id;
       End If;
       X_err_stack  := Old_Stack;

  Exception
     When Others then
          X_err_code := SQLCODE;
          return;

 End ;

 Procedure   Get_Rl_Assgmt (X_Project_id  In Number,
                            X_Resource_list_id  In Number,
                            X_Resource_list_Assgmt_id Out NOCOPY Number, --File.Sql.39 bug 4440895
                            X_err_code  IN  Out NOCOPY Number, --File.Sql.39 bug 4440895
                            X_err_stage IN  Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                            x_err_stack IN  Out NOCOPY Varchar2 ) Is --File.Sql.39 bug 4440895
W_Num Number := 0;
Old_stack varchar2(630);
Cursor Res_List_Asgmt_Cur is
        Select Resource_list_Assignment_Id  from PA_RESOURCE_LIST_ASSIGNMENTS
        where Resource_list_Id = X_Resource_List_id and
              Project_id       = X_Project_id;
Begin
       X_err_code := 0;
       Old_Stack := X_Err_Stack;
       X_err_stack := X_err_stack ||'->PA_RES_LIST_ASSIGNMENTS.Get_Rl_Asgmt';
       x_err_stage := ' Select Resource_List_Assignment_id from '||
                      ' PA_RESOURCE_LIST_ASSIGNMENTS '||
                        To_Char(X_Resource_List_Id);
       Open Res_List_Asgmt_Cur;
       Fetch Res_List_Asgmt_Cur into W_Num;
       If Res_List_Asgmt_Cur%NOTFOUND Then
          X_Resource_list_Assgmt_id := 0;
       Else
          X_Resource_list_Assgmt_id := W_num;

       End If;
       Close Res_List_Asgmt_Cur;
       X_err_stack  := Old_Stack;
  Exception
     When Others then
          X_err_code := SQLCODE;
          return;
End ;


 Procedure Create_Rl_Uses  (X_Project_id              In Number,
                            X_Resource_list_Assgmt_id In  Number,
                            X_Use_Code                In Varchar2,
                            X_err_code  IN  Out NOCOPY Number, --File.Sql.39 bug 4440895
                            X_err_stage IN  Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                            x_err_stack IN  Out NOCOPY Varchar2 ) Is --File.Sql.39 bug 4440895
W_Assgmt_Id Number := 0;
W_Asgmt_Res_list_id Number := 0;
W_usage_Res_list_id Number := 0;
W_project_id Number := 0;
W_Row_id    Varchar2(19);
W_num       Number := 0;
W_budget_Type_Yn  Varchar2(1);
Old_stack varchar2(630);
W_User_id   Number := 0;
W_Login_id  Number := 0;
W_insert_Flag  Char(1) := 'N';
W_Update_Flag  Char(1) := 'N';
W_Found_Flag   Char(1) := 'N';
X_row_id    Varchar2(19);
Cursor Res_List_Asgmt_Cur is
        Select Project_id,Resource_list_Id  from
        PA_RESOURCE_LIST_ASSIGNMENTS
        Where  Resource_list_Assignment_Id = X_Resource_list_Assgmt_id;
Cursor Res_List_Use_Code_Cur is
        Select Budget_Type_Yn from PA_RESOURCE_LIST_USE_CODES_V where
        List_Use_Code = X_Use_Code;
Cursor Res_list_uses_cur is
       Select Row_id,Resource_List_Id
       from Pa_Resource_list_uses_v where Project_id = X_Project_id and
       Use_Code = X_Use_Code ;

 Begin
        W_User_id := To_Number(FND_PROFILE.VALUE('USER_ID'));
        W_login_id := To_Number(FND_PROFILE.VALUE('LOGIN_ID'));
        X_err_code := 0;
        Old_Stack := X_Err_Stack;
        X_err_stack := X_err_stack ||'->PA_RES_LIST_ASSIGNMENTS.Create_Rl_Uses';
        x_err_stage := 'Select Project_id,Resource_list_Id '||
                       ' from Pa_Resource_list_Assignments  '||
                       To_Char(X_Resource_list_Assgmt_id);
        Open Res_List_Asgmt_Cur;
        Fetch Res_List_Asgmt_Cur into W_Project_id,W_Asgmt_Res_list_id;
        If Res_List_Asgmt_Cur%NOTFOUND Then
           x_err_code := 10;
           x_err_stage := 'PA_RE_ASSGMT_NOT_FOUND';
           Close Res_List_Asgmt_Cur;
           Return;
        End If;
        Close Res_List_Asgmt_Cur;
        x_err_stage := 'Select  Budget_Type_Yn from  '||
                       ' PA_RESOURCE_LIST_USE_CODES_V '||
                       To_Char(W_Asgmt_Res_list_id);
        Open Res_List_Use_Code_Cur;
        Fetch Res_List_Use_Code_Cur into W_Budget_type_yn;
        If Res_List_Use_Code_Cur%NOTFOUND Then
           x_err_code := 11;
           x_err_stage := 'PA_RE_USE_CODE_NOT_FOUND';
           Close Res_List_Use_Code_Cur;
           Return;
       End If;
       Close Res_List_Use_Code_Cur;
       x_err_stage := ' Select Row_id,Resource_List_id from '||
                      ' PA_RESOURCE_LIST_ASSIGNMENTS '||
                        To_Char(X_Project_Id);
       Open Res_list_uses_cur;
       Fetch Res_list_uses_cur into W_Row_id,W_usage_Res_list_id;
       If Res_list_uses_cur%NOTFOUND Then
          Close Res_list_uses_cur;
          W_insert_flag := 'Y';
          GoTo Ins_para;
      End If;
           If W_usage_Res_list_id <> W_Asgmt_Res_list_id Then
              If W_Budget_type_yn = 'Y' Then
                 x_err_stage := ' Update Pa_Resource_List_Uses ';
                 Update Pa_Resource_List_uses
                 Set Resource_list_Assignment_id  =
                 X_Resource_list_Assgmt_id
                 Where RowId = W_Row_Id;
                 Close Res_list_uses_cur;
                 Return;
              Else
                 W_Insert_Flag := 'Y';
              End If;
           Else
              Close Res_list_uses_cur;
              Return;
           End If;
      Close Res_list_uses_cur;
      <<Ins_para>>
      If W_Insert_Flag = 'Y' Then
         x_err_stage := ' Insert into Pa_Resource_List_Uses ';
         Insert into Pa_Resource_list_uses
         (RESOURCE_LIST_ASSIGNMENT_ID,USE_CODE,DEFAULT_FLAG,
         LAST_UPDATED_BY,LAST_UPDATE_DATE,
         CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN) Values
         (X_Resource_list_Assgmt_id,X_Use_Code,'N',
          Nvl(W_user_id,-1), Trunc(Sysdate),
          Trunc(Sysdate),Nvl(W_user_id,-1),Nvl(W_login_id,-1));
       End If;
       X_err_stack  := Old_Stack;
  Exception
     When Others then
          X_err_code := SQLCODE;
          return;
  End ;
 Procedure Delete_Rl_Uses  (X_Resource_list_Assgmt_id In Number,
                            X_Use_Code      IN Varchar2,
                            X_err_code  IN  Out NOCOPY Number, --File.Sql.39 bug 4440895
                            X_err_stage IN  Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                            x_err_stack IN  Out NOCOPY Varchar2 ) Is --File.Sql.39 bug 4440895

W_Assgmt_Id Number := 0;
Old_stack varchar2(630);
Cursor Res_List_Asgmt_Cur is
        Select Resource_list_Assignment_Id  from PA_RESOURCE_LIST_USES_V
        where Resource_list_Assignment_id = X_Resource_list_Assgmt_id;

 Begin
        X_err_code := 0;
        Old_Stack := X_Err_Stack;
        X_err_stack := X_err_stack ||'->PA_RES_LIST_ASSIGNMENTS.Delete_Rl_Uses';
        x_err_stage := ' Delete from PA_RESOURCE_LIST_USES';
        Delete from PA_RESOURCE_LIST_USES Where
        Resource_List_Assignment_id = X_Resource_list_Assgmt_id and
        Use_Code                    = X_Use_Code;
        If SQL%NOTFOUND Then
           X_err_stage := 'PA_RE_ASSGMT_NOT_FOUND' ;
           x_err_code  := 10;
           Return;
        End If;
        x_err_stage :=
        ' Select Resource_list_Assignment_Id from PA_RESOURCE_LIST_USES_V '
        || To_Char(X_Resource_list_Assgmt_id);
       Open Res_List_Asgmt_Cur;
       Fetch Res_List_Asgmt_Cur into W_Assgmt_Id;
       If Res_List_Asgmt_Cur%NOTFOUND Then
          x_err_stage := 'Delete from Pa_Resource_list_assignments ';
          Delete from PA_RESOURCE_LIST_ASSIGNMENTS where
          RESOURCE_LIST_ASSIGNMENT_ID = X_Resource_list_Assgmt_id;
       End If;
       Close Res_List_Asgmt_Cur;
       X_err_stack  := Old_Stack;
  Exception
     When Others then
          X_err_code := SQLCODE;
          return;
  End ;

 Procedure Delete_Rl_Assgmt(X_Resource_list_Assgmt_id In Number,
                            X_err_code  IN  Out NOCOPY Number, --File.Sql.39 bug 4440895
                            X_err_stage IN  Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                            x_err_stack IN  Out NOCOPY Varchar2 ) Is --File.Sql.39 bug 4440895

W_Assgmt_Id Number := 0;
Old_stack varchar2(630);
Cursor Res_List_Asgmt_Cur is
        Select Resource_list_Assignment_Id  from PA_RESOURCE_LIST_USES
        where Resource_list_Assignment_id = X_Resource_list_Assgmt_id;

 Begin
        X_err_code := 0;
        Old_Stack := X_Err_Stack;
       X_err_stack := X_err_stack ||'->PA_RES_LIST_ASSIGNMENTS.Delete_Rl_Asgmt';
        x_err_stage :=
        ' Select Resource_list_Assignment_Id from PA_RESOURCE_LIST_USES '
        || To_Char(X_Resource_list_Assgmt_id);
       Open Res_List_Asgmt_Cur;
       Fetch Res_List_Asgmt_Cur into W_Assgmt_Id;
       If Res_List_Asgmt_Cur%NOTFOUND Then
          x_err_stage := 'Delete from Pa_Resource_list_assignments ';
          Delete from PA_RESOURCE_LIST_ASSIGNMENTS where
          RESOURCE_LIST_ASSIGNMENT_ID = X_Resource_list_Assgmt_id;
       Else
          x_err_code := 10;
          x_err_stage := 'PA_RE_RL_USES_FOUND';
          Close Res_List_Asgmt_Cur;
          return;
       End If;
       Close Res_List_Asgmt_Cur;
       X_err_stack  := Old_Stack;
  Exception
     When Others then
          X_err_code := SQLCODE;
          return;
  End ;
END;

/
