--------------------------------------------------------
--  DDL for Package Body PA_PLAN_RL_FORMATS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PLAN_RL_FORMATS_PVT" as
/* $Header: PARRFTVB.pls 120.1 2005/08/24 14:55:33 appldev noship $ */

/****************************************************
 * Procedure   : Create_Plan_RL_Format
 * Description : This is a Pvt procedure which takes in
 *               parameters from
 *               Pa_Plan_RL_Formats_Pub.Create_Plan_RL_Format
 *               proc.
 ****************************************************/
 Procedure Create_Plan_RL_Format(
	P_Res_List_Id		 IN   NUMBER,
	P_Res_Format_Id		 IN   NUMBER,
	X_Plan_RL_Format_Id 	 OUT  NOCOPY NUMBER,
	X_Record_Version_Number	 OUT  NOCOPY NUMBER,
	X_Return_Status		 OUT  NOCOPY VARCHAR2,
	X_Msg_Count		 OUT  NOCOPY NUMBER,
	X_Msg_Data		 OUT  NOCOPY VARCHAR2)

 Is

      /***************************************************
      * Bug : 3473679
      * Description : We are selecting the res_type_code as well
      *               In this cursor because, for Work_planned
      *               enabled flag being Yes, we need to be restrictive
      *               while creating Plan formats for certain
      *               res_type_code and not all.
      ********************************************************/
	Cursor c1 is
	Select
		b.res_type_code,a.Res_Type_Id, a.resource_class_id
	From
		Pa_Res_Formats_B a,pa_res_types_b b
	Where
		Res_Format_Id = P_Res_Format_Id
        AND     a.res_type_id = b.res_type_id;

        CURSOR chk_job_format(P_Res_Format_Id IN NUMBER) IS
        SELECT 'Y'
        FROM   Pa_Res_Formats_B fmt,
               pa_res_types_b   typ
        WHERE  fmt.Res_Format_Id = P_Res_Format_Id
        AND    fmt.res_type_id = typ.res_type_id
        AND    typ.res_type_code = 'JOB';

	Cursor c2 (P_Res_Type_Id IN Number,
		   P_Res_Class_Id IN Number) is
	Select 'Y'
	From   Pa_Res_Formats_b fmt
	Where  fmt.Res_Type_Id = P_Res_Type_Id
	And    fmt.Resource_Class_Id = P_Res_Class_Id
	And    exists (Select 'Y'
		       From   Pa_Plan_RL_Formats prf
                       where  prf.Resource_List_Id = P_Res_List_Id
                       and    prf.Res_Format_Id = fmt.Res_Format_Id);

        Cursor c3 (P_Resource_List_Id IN Number) Is
        Select
                Use_For_WP_Flag
        From
                pa_resource_lists_all_bg
        Where
                Resource_List_Id = P_Resource_List_Id;

        CURSOR chk_format_exists (p_resource_list_id IN Number,
				  p_res_format_id    IN Number) IS
        SELECT 'Y'
        FROM   Pa_Plan_RL_Formats
        WHERE  Resource_List_Id = p_resource_list_id
        AND    Res_Format_Id = p_res_format_id;

	l_Res_Type_Id     Number      := Null;
	l_Res_Type_code   Varchar2(30):= Null;
	l_Res_Class_Id    Number      := Null;
	l_Dummy_Flag      Varchar2(1) := Null;
	l_exists          Varchar2(1) := 'N';
	l_job_format      Varchar2(1) := 'N';
        l_jg_id           Number      := Null;
	l_WP_Enabled_Flag Varchar2(1) := Null;
	WP_ERROR          Exception;
	JOB_FMT_ERR       Exception;
	BAD_FORMAT_ID     Exception;

 Begin
/**************************************************************************
* Logic:
* The below logic applies only for the foll res_type_codes
* 'NAMED_PERSON','BOM_LABOR','BOM_EQUIPMENT' 'NON_LABOR_RESOURCE',
* 'INVENTORY_ITEM'
* Suppose this resource list has 3 formats associated to it already
* (formats 1, 2 and 3).
* Now the user is trying to add a fourth format, format 4, and used for
* WP flag = Y.
* The validation is that the res_type_id of format 4 (from pa_res_formats_b)
* cannot be the
* same as the res_type_id for each of formats 1, 2 and 3.  So, first we
* have to get all the
* formats associated to the list (from pa_plan_rl_formats), and for each
* of them, we have
* to get the res_type_id from pa_res_formats_b, and compare to the
* res_type_id for the  p_format_id we are trying to add.
* If they do, then raise an error message "PA_PLAN_RL_FORMAT_WP_ERR"
**************************************************************************/
	X_Return_Status := Fnd_Api.G_Ret_Sts_Success;
	X_Msg_Count := 0;
	X_Msg_Data := Null;


	Open c3(P_Resource_List_Id => P_Res_List_Id);
	Fetch c3 Into l_WP_Enabled_Flag;
	Close c3;

	If l_WP_Enabled_Flag = 'Y' Then

		Open c1;
		Fetch c1 into l_res_type_code,l_Res_Type_Id, l_Res_Class_Id;
		Close c1;

            If l_Res_Type_Id is Not Null Then
            /***************************************************
            * Bug         : 3473679
            * Description : We need to fo the below checks
            *               only if the res_type code is any of
            *               the mentioned.
            ********************************************************/
               IF l_res_type_code IN
                  ('NAMED_PERSON','BOM_LABOR','BOM_EQUIPMENT',
                   'NON_LABOR_RESOURCE','INVENTORY_ITEM')
               THEN
			Open c2(P_Res_Type_Id      => l_Res_Type_Id,
				P_Res_Class_Id     => l_Res_Class_Id);
			Fetch c2 Into l_Dummy_Flag;

			If c2%NotFound Then

				Null;

			Else

				Raise WP_ERROR;

			End If;
			Close c2;
                END IF;

	    End If;

	End If; -- l_WP_Enabled_Flag = 'Y'

        -- Add validation to prevent the adding of Job formats
        -- to a planning resource list without Job Group specified
        -- Bug 4496596
        l_job_format := 'N';
        l_jg_id := NULL;
        OPEN chk_job_format(P_Res_Format_Id    => P_Res_Format_Id);
        FETCH chk_job_format INTO l_job_format;
        CLOSE chk_job_format;

        IF l_job_format = 'Y' THEN
           BEGIN
           SELECT job_group_id
           INTO   l_jg_id
           FROM   pa_resource_lists_all_bg
           WHERE  resource_list_id = p_res_list_id;

           EXCEPTION WHEN NO_DATA_FOUND THEN
              l_jg_id := NULL;
           END;

           IF l_jg_id IS NULL THEN
              RAISE JOB_FMT_ERR;
           END IF;
        END IF;

        l_exists := 'N';
	Open chk_format_exists(P_Resource_List_Id => P_Res_List_Id,
                               P_Res_Format_Id    => P_Res_Format_Id);
	Fetch chk_format_exists Into l_exists;
	Close chk_format_exists;

        IF l_exists <> 'Y' THEN
	   Pa_Plan_RL_Formats_Pkg.Insert_Row(
		P_Resource_List_Id	=> P_Res_List_id,
		P_Res_Format_Id		=> P_Res_Format_Id,
		P_Last_Update_Date	=> SysDate,
		P_Last_Updated_By	=> Fnd_Global.User_Id,
		P_Creation_Date		=> SysDate,
		P_Created_By		=> Fnd_Global.User_Id,
		P_Last_Update_Login 	=> Fnd_Global.Login_Id,
		X_Plan_RL_Format_Id	=> X_Plan_RL_Format_Id,
		X_Record_Version_Number => X_Record_Version_Number);
        END IF;

    /************************************************
    * Check the Commit flag. if it is true then Commit.
    ***********************************************/
 Exception
	When BAD_FORMAT_ID Then
		X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
		X_Msg_Count     	:= 1;
		X_Msg_Data		:= 'PA_PLN_RL_FORMAT_BAD_FMT_ID';
		X_Plan_RL_Format_Id	:= Null;
		X_Record_Version_Number := Null;
		Pa_Utils.Add_Message
               		(P_App_Short_Name  => 'PA',
                	 P_Msg_Name        => 'PA_PLN_RL_FORMAT_BAD_FMT_ID',
                         p_token1          => 'PLAN_RES',
                         p_value1          => NULL);

	When WP_ERROR Then
		X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
		X_Msg_Count     	:= 1;
		X_Msg_Data		:= 'PA_PLAN_RL_FORMAT_WP_ERR';
		X_Plan_RL_Format_Id	:= Null;
		X_Record_Version_Number := Null;
		Close c2;
		Pa_Utils.Add_Message
               		(P_App_Short_Name  => 'PA',
                	 P_Msg_Name        => 'PA_PLAN_RL_FORMAT_WP_ERR');

        When JOB_FMT_ERR Then
                X_Return_Status         := Fnd_Api.G_Ret_Sts_Error;
                X_Msg_Count             := 1;
                X_Msg_Data              := 'PA_PLAN_RL_FORMAT_JOB_ERR';
                X_Plan_RL_Format_Id     := Null;
                X_Record_Version_Number := Null;
                Pa_Utils.Add_Message
                        (P_App_Short_Name  => 'PA',
                         P_Msg_Name        => 'PA_PLAN_RL_FORMAT_JOB_ERR');
	When NO_DATA_FOUND Then
		X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
		X_Msg_Count     	:= 1;
		X_Msg_Data		:= 'PA_PLN_RL_FMT_NOT_CREATED';
		X_Plan_RL_Format_Id	:= Null;
		X_Record_Version_Number := Null;
		Close c2;
		Pa_Utils.Add_Message
               		(P_App_Short_Name  => 'PA',
                	 P_Msg_Name        => 'PA_PLN_RL_FMT_NOT_CREATED');

	When Others Then
		X_Return_Status 	:= Fnd_Api.G_Ret_Sts_UnExp_Error;
		X_Plan_RL_Format_Id	:= Null;
		X_Record_Version_Number := Null;
		Fnd_Msg_Pub.Add_Exc_Msg(
			P_Pkg_Name         => 'Pa_Plan_RL_Formats_Pub',
			P_Procedure_Name   => 'Create_Plan_RL_Format');

                Raise;

 End Create_Plan_RL_Format;
/**********************************/
/****************************************************
 * Procedure   : Delete_Plan_RL_Format
 * Description : This is a Pvt procedure which takes in
 *               parameters from
 *               Pa_Plan_RL_Formats_Pub.Delete_Plan_RL_Format
 *               proc.
 ****************************************************/
 Procedure Delete_Plan_RL_Format (
	P_Res_List_Id    	IN   NUMBER DEFAULT NULL,
	P_Res_Format_Id		IN   NUMBER DEFAULT NULL,
	P_Plan_RL_Format_Id	IN   NUMBER DEFAULT NULL,
	X_Return_Status		OUT  NOCOPY VARCHAR2,
	X_Msg_Count		OUT  NOCOPY NUMBER,
	X_Msg_Data		OUT  NOCOPY VARCHAR2)

 Is

	Cursor c1 (P_Resource_Format_Id IN Number,
		   P_Resource_List_Id IN Number) is
	Select
		'Y'
	From
		Dual
	Where Exists (
	Select
		'Y'
	From
		Pa_Resource_List_Members
	Where
		Res_Format_Id = P_Resource_Format_Id
	And	Resource_List_Id = P_Resource_List_Id);

	Cursor c2 is
	Select
		Res_Format_Id,
		Resource_List_Id
	From
		Pa_Plan_RL_Formats
	Where
		Plan_RL_Format_Id = P_Plan_RL_Format_Id;

	l_Dummy_Flag 		Varchar2(1) := 'N';
	l_Res_Format_Id		Number      := Null;
	l_Res_List_Id		Number	    := Null;
	DEL_ERROR 		Exception;
	NULL_FORMAT_ID 		Exception;
	NULL_LIST_ID   		Exception;
	BAD_PLAN_RL_FORMAT_ID	Exception;
        FMTUSED_ERROR           Exception;

 Begin
	-- Checks whether there are any planning resources for this format before it can be deleted.
	-- Check from pa_resource_list_members where res_format_id = p_res_format_id.
	-- You need to check if any exists, and if so, raise an error:

	 Fnd_Msg_Pub.Initialize;

	X_Return_Status := Fnd_Api.G_Ret_Sts_Success;
	X_Msg_Count     	:= 0;
	X_Msg_Data		:= Null;

	If P_Res_Format_Id is Null and P_Plan_RL_Format_Id is Null Then

		Raise NULL_FORMAT_ID;

	End If;

	If P_Res_List_Id is Null and P_Plan_RL_Format_Id is Null Then

		Raise NULL_LIST_ID;

	End If;

	If P_Res_Format_Id is Null and P_Res_List_Id is Null Then


		Open c2;
		Fetch c2 Into l_Res_Format_Id, l_Res_List_Id;
		Close c2;

		If l_Res_Format_Id is Null Then

			Raise BAD_PLAN_RL_FORMAT_ID;

		End If;

	Else

		l_Res_Format_Id := P_Res_Format_Id;
		l_Res_List_Id   := P_Res_List_Id;

	End If;

        -- For bug 3747114
        IF (pa_assignment_utils.Check_Res_Format_Used_For_TR(
                   p_res_format_id    => l_Res_Format_Id,
                   p_resource_list_id => l_Res_List_Id)) = 'Y' Then

                Raise FMTUSED_ERROR;

        End If;  --End of bug 3747114

	Open c1(P_Resource_Format_Id => l_Res_Format_Id,
		P_Resource_List_Id   => l_Res_List_Id);
	Fetch c1 Into l_Dummy_Flag;
	Close c1;

	If l_dummy_Flag = 'Y' Then

		Raise DEL_ERROR;

	Else

		Pa_Plan_RL_Formats_Pkg.Delete_Row (
			P_Res_List_Id    	=> P_Res_List_Id,
			P_Res_Format_Id		=> P_Res_Format_Id,
			P_Plan_RL_Format_Id	=> P_Plan_RL_Format_Id);

	End If;

EXCEPTION
	When NULL_FORMAT_ID Then
		X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
		X_Msg_Count     	:= 1;
		X_Msg_Data		:= 'PA_PLN_RL_FORMAT_NULL_FMT_ID';
		Pa_Utils.Add_Message
               		(P_App_Short_Name  => 'PA',
                	 P_Msg_Name        => 'PA_PLN_RL_FORMAT_NULL_FMT_ID');

	When NULL_LIST_ID Then
		X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
		X_Msg_Count     	:= 1;
		X_Msg_Data		:= 'PA_PLN_RL_FORMAT_NULL_LST_ID';
		Pa_Utils.Add_Message
               		(P_App_Short_Name  => 'PA',
                	 P_Msg_Name        => 'PA_PLN_RL_FORMAT_NULL_LST_ID');

	When BAD_PLAN_RL_FORMAT_ID Then
		X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
		X_Msg_Count     	:= 1;
		X_Msg_Data		:= 'PA_PLN_RL_FORMAT_BAD_FMT_ID';
		Pa_Utils.Add_Message
               		(P_App_Short_Name  => 'PA',
                	 P_Msg_Name        => 'PA_PLN_RL_FORMAT_BAD_FMT_ID',
                         p_token1          => 'PLAN_RES',
                         p_value1          => NULL);

	When DEL_ERROR Then
		X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
		X_Msg_Count     	:= 1;
		X_Msg_Data		:= 'PA_PLAN_RL_FORMAT_DEL_ERR';
		Pa_Utils.Add_Message
               		(P_App_Short_Name  => 'PA',
                	 P_Msg_Name        => 'PA_PLAN_RL_FORMAT_DEL_ERR');

        When FMTUSED_ERROR Then
                X_Return_Status         := Fnd_Api.G_Ret_Sts_Error;
                X_Msg_Count             := 1;
                X_Msg_Data              := 'PA_PLAN_RL_FORMAT_USED_ERR';
                Pa_Utils.Add_Message
                        (P_App_Short_Name  => 'PA',
                         P_Msg_Name        => 'PA_PLAN_RL_FORMAT_USED_ERR');

	When Others Then
		X_Return_Status := Fnd_Api.G_Ret_Sts_UnExp_Error;
		Fnd_Msg_Pub.Add_Exc_Msg(
			P_Pkg_Name         => 'Pa_Plan_RL_Formats_Pvt',
			P_Procedure_Name   => 'Delete_Plan_RL_Format');

                Raise;

 End Delete_Plan_RL_Format;

END Pa_Plan_RL_Formats_Pvt ;

/
