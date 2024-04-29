--------------------------------------------------------
--  DDL for Package Body PA_RBS_VERSIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RBS_VERSIONS_PUB" as
--$Header: PARBSVPB.pls 120.0 2005/06/03 13:50:35 appldev noship $

g_module_name   VARCHAR2(100) := 'pa.plsql.Freeze_Working_Version';

-- =======================================================================
-- Start of Comments
-- API Name      : Update_Working_Version
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure allows for the update of the current working version for a rbs header.
--
--  Parameters:
--
--  IN
--      P_Commit                - Varchar2 Default Fnd_Api.G_False
--      P_Init_Msg_List         - Varchar2 Default Fnd_Api.G_True
--      P_Api_Version_Number    - Number
--      P_RBS_Version_Id        - Number
--      P_Name                  - Varchar2(240)
--      P_Description           - Varchar2(2000)
--      P_Version_Start_Date    - Date
--      P_Job_Group_Id          - Number
--      P_Record_Version_Number - Number
--      P_Init_Debugging_Flag   - Varchar2 Default 'Y'
--  OUT
--      X_Record_Version_Number - Number
--      X_Return_Status         - Varchar2(1)
--      X_Msg_Count             - Number
--      X_Error_Msg_Data        - Varchar2(30)
/*-------------------------------------------------------------------------*/

Procedure Update_Working_Version(
        P_Commit                IN         Varchar2 Default Fnd_Api.G_False,
        P_Init_Msg_List         IN         Varchar2 Default Fnd_Api.G_True,
        P_API_Version_Number    IN         Number,
	P_RBS_Version_Id	IN	   Number,
	P_Name			IN	   Varchar2,
	P_Description		IN	   Varchar2,
	P_Version_Start_Date	IN	   Date,
	P_Job_Group_Id		IN	   Number,
	P_Record_Version_Number	IN	   Number,
        P_Init_Debugging_Flag   IN         Varchar2 Default 'Y',
	X_Record_Version_Number OUT NOCOPY Number,
        X_Return_Status         OUT NOCOPY Varchar2,
        X_Msg_Count             OUT NOCOPY Number,
        X_Error_Msg_Data        OUT NOCOPY Varchar2)

Is

        l_Api_Name Varchar2(30) := 'Update_Working_Version';
	l_Error    Exception;

        Cursor c1 (P_Rbs_Ver_Id IN Number,
                   P_Rec_Num IN Number) Is
        Select
               Status_Code,
               Job_Group_Id
        From
               Pa_Rbs_Versions_B
        Where
               Rbs_Version_Id = P_Rbs_Version_Id
        And    Status_Code = 'WORKING'
        And    Record_Version_Number = P_Rec_Num
        For Update Of Version_Start_Date NoWait;

        l_Ver_Rec  c1%RowType;

        Cursor c2 (P_Rbs_Ver_Id IN Number) Is
        Select
               H.Effective_From_Date,
               H.Effective_To_Date,
               H.Rbs_Header_Id,
               TL.Name
        From
               Pa_Rbs_Headers_B H,
               Pa_Rbs_Headers_TL TL,
               Pa_Rbs_Versions_B V
        Where
               TL.Rbs_Header_Id = H.Rbs_Header_Id
        And    UserEnv('LANG') in (TL.Language, TL.Source_Lang)
        And    H.Rbs_Header_Id = V.Rbs_Header_Id
        And    V.Rbs_Version_Id = P_Rbs_Ver_Id;

        l_Hdr_Rec c2%RowType;

        Cursor GetLatestFrozenRbsVersionId(P_Id IN Number) Is
        Select
                Max(Rbs_Version_Id)
        From
                Pa_Rbs_Versions_B
        Where
               Rbs_Header_Id = P_Id
        And    Status_Code <> 'WORKING';

        Cursor GetVersionEndDate(P_Id IN Number) Is
        Select
               Version_Start_Date,
               Version_End_Date
        From
               Pa_Rbs_Versions_B
        Where
               Rbs_Version_Id = P_Id;

        l_Prior_Rbs_Ver_Id     Number(15) := Null;
        l_Prior_Rbs_Ver_Rec    GetVersionEndDate%RowType;

        Cursor CheckJobsExist(P_Rbs_Ver_Id IN Number) Is
        Select
               Count(*)
        From
               Pa_Rbs_Elements
        Where
               Job_Id Is Not Null
        And    User_Created_Flag = 'Y'
        And    Rbs_Version_Id = P_Rbs_Ver_Id;

        l_Job_Count  Number := 0;

Begin

        If P_Init_Debugging_Flag = 'Y' Then

                Pa_Debug.G_Path := ' ';

        End If;

        Pa_Debug.G_Stage := 'Entering Update_Working_Version() Pub.';
        Pa_Debug.TrackPath('ADD','Update_Working_Version Pub');

        Pa_Debug.G_Stage := 'Call Compatibility API.';
        If Not Fnd_Api.Compatible_API_Call (
                        Pa_Rbs_Versions_Pub.G_Api_Version_Number,
                        P_Api_Version_Number,
                        l_Api_Name,
                        Pa_Rbs_Versions_Pub.G_Pkg_Name) Then

                Raise Fnd_Api.G_Exc_Unexpected_Error;

        End If;

	Pa_Debug.G_Stage := 'Check if need to initialize message stack.';
        If Fnd_Api.To_Boolean(nvl(P_Init_Msg_List,Fnd_Api.G_True)) Then

		Pa_Debug.G_Stage := 'Initialize Message Stack.';
                Fnd_Msg_Pub.Initialize;

        End If;

        Pa_Debug.G_Stage := 'Initialize error handling variables.';
        X_Msg_Count := 0;
        X_Error_Msg_Data := Null;
        X_Return_Status := Fnd_Api.G_Ret_Sts_Success;

        Pa_Debug.G_Stage := 'Lock the version record.';
        Open c1(P_Rbs_Ver_Id => P_Rbs_Version_Id, P_Rec_Num => P_Record_Version_Number);
        Fetch c1 Into l_Ver_Rec;

        Pa_Debug.G_Stage := 'Check able to lock version rec for update.';
        If c1%NotFound Then

             Pa_Debug.G_Stage := 'Unable to lock version record for update.  ' ||
                                            'Add error message to stack.';
             Pa_Utils.Add_Message(
                  P_App_Short_Name => 'PA',
                  P_Msg_Name       => 'PA_RECORD_ALREADY_UPDATED');
             Close c1;
             Raise l_Error;

        End If;

        Open c2(P_Rbs_Ver_Id => P_Rbs_Version_Id);
        Fetch c2 Into l_Hdr_Rec;
        Close c2;

        Pa_Debug.G_Stage := 'Check if the version start date is not null.';
        If P_Version_Start_Date is not null Then

                Pa_Debug.G_Stage := 'The version start date is Null.';
                If P_Version_Start_Date < l_Hdr_Rec.Effective_From_Date Then

                     Pa_Debug.G_Stage := 'The version start date is before the header from date.';
                     Pa_Utils.Add_Message(
                          P_App_Short_Name => 'PA',
                          P_Msg_Name       => 'PA_VER_START_<_HDR_FROM_DATE',
                          P_Token1         => 'RBSNAME',
			  P_Value1         => l_Hdr_Rec.Name);

                     Raise l_Error;

                End If;

        Else

                Pa_Debug.G_Stage := 'The version start date is null.  Add error message to stack.';
                Pa_Utils.Add_Message(
                     P_App_Short_Name => 'PA',
                     P_Msg_Name       => 'PA_VER_START_DATE_IS_NULL',
                     P_Token1         => 'RBSNAME',
                     P_Value1         => l_Hdr_Rec.Name);

                Raise l_Error;

        End If;

        -- Per bug 3602821 don't need to check the end date of the header for anything.
        -- Pa_Debug.G_Stage := 'Check and see if the version start date is after the header end date.';
        -- If P_Version_Start_Date > Nvl(l_Hdr_Rec.Effective_To_Date,P_Version_Start_Date) Then

        --      Pa_Debug.G_Stage := 'The version start date is after the header end date.';
        --      Pa_Utils.Add_Message(
        --           P_App_Short_Name => 'PA',
        --           P_Msg_Name       => 'PA_VER_START_>_HDR_TO_DATE',
        --           P_Token1         => 'RBSNAME',
        --           P_Value1         => l_Hdr_Rec.Name);

        --      Raise l_Error;

        -- End If;

        Pa_Debug.G_Stage := 'Get the prior working version rbs version id if exists.';
        Open GetLatestFrozenRbsVersionId(P_Id => l_Hdr_Rec.Rbs_Header_Id);
        Fetch GetLatestFrozenRbsVersionId Into l_Prior_Rbs_Ver_Id;

        If GetLatestFrozenRbsVersionId%NotFound Then

	        Close GetLatestFrozenRbsVersionId;

        Else

                Close GetLatestFrozenRbsVersionId;

                Pa_Debug.G_Stage := 'Get the prior working version end date.';
                Open GetVersionEndDate(P_Id => l_Prior_Rbs_Ver_Id);
                Fetch GetVersionEndDate Into l_Prior_Rbs_Ver_Rec;
                Close GetVersionEndDate;

                If P_Version_Start_Date < l_Prior_Rbs_Ver_Rec.Version_Start_Date Then

                        Pa_Debug.G_Stage := 'Version Start Date less than prior version.  Add error message to stack.';
                        Pa_Utils.Add_Message(
                                P_App_Short_Name => 'PA',
                                P_Msg_Name       => 'PA_RBS_VER_DATES_OVERLAP');

                        Raise l_Error;

                End If;

        End If;

        -- Check If the job_group has changed and if it has then check to see if there are job assigned to any of the
        -- elements/nodes for the rbs.  If there are job elements then raise an error.  You can't change the job_group
        -- when there are element/nodes with jobs assigned to them.

        Pa_Debug.G_Stage := 'Check if the current working record job group is populated.';
        If l_Ver_Rec.Job_Group_Id Is Not Null Then

                Pa_Debug.G_Stage := 'Check if the current parameter job group is populated.';
                If P_Job_Group_Id Is Not Null Then

                        If P_Job_Group_Id <> l_Ver_Rec.Job_Group_Id Then

                                Open CheckJobsExist(P_Rbs_Ver_Id => P_Rbs_Version_Id);
                                Fetch CheckJobsExist Into l_Job_Count;
                                Close CheckJobsExist;

                                If l_Job_Count > 0 Then

                                        Pa_Debug.G_Stage := 'There are elements with jobs.  Cannot change job group.  Raise error.';
                                        Pa_Utils.Add_Message(
                                                P_App_Short_Name => 'PA',
                                                P_Msg_Name       => 'PA_RBS_CANT_CHANGE_JOB_GROUP');

                                        Raise l_Error;

                                End If;

                        End If;

                Else

                        Open CheckJobsExist(P_Rbs_Ver_Id => P_Rbs_Version_Id);
                        Fetch CheckJobsExist Into l_Job_Count;
                        Close CheckJobsExist;

                        If l_Job_Count > 0 Then

                                Pa_Debug.G_Stage := 'There are element with jobs.  Cannot change job group.  Raise error.';
                                Pa_Utils.Add_Message(
                                        P_App_Short_Name => 'PA',
                                        P_Msg_Name       => 'PA_RBS_CANT_CHANGE_JOB_GROUP');

                                Raise l_Error;

                        End If;

                End If;

        End If;

	Pa_Debug.G_Stage := 'Call Pa_Rbs_Versions_Pvt.Update_Working_Version() procedure.';
        Pa_Rbs_Versions_Pvt.Update_Working_Version(
                P_Rbs_Version_Id	=> P_Rbs_Version_Id,
		P_Name			=> P_Name,
		P_Description		=> P_Description,
		P_Version_Start_Date	=> P_Version_Start_Date,
		P_Job_Group_Id		=> P_Job_Group_Id,
		P_Record_Version_Number	=> P_Record_Version_Number,
		X_Record_Version_Number => X_Record_Version_Number,
		X_Error_Msg_Data	=> X_Error_Msg_Data);

	If X_Error_Msg_Data Is Not Null Then

		Raise l_Error;

	End If;

        Pa_Debug.G_Stage := 'Check to do commit(T-True,F-False) - ' || P_Commit;
        If Fnd_Api.To_Boolean(Nvl(P_Commit,Fnd_Api.G_False)) Then

                Commit;

        End If;

        Pa_Debug.G_Stage := 'Leaving Update_Working_Version() Pub procedure.';
        Pa_Debug.TrackPath('STRIP','Update_Working_Version Pub');

Exception
        When l_Error Then
                X_Return_Status := 'E';
                X_Msg_Count := 1;
                Pa_Debug.G_Stage := 'Leaving Update_Working_Version() Pub procedure.';
                Pa_Debug.TrackPath('STRIP','Update_Working_Version Pub');
        When Others Then
                X_Return_Status := 'U';
                X_Msg_Count := 1;
                X_Error_Msg_Data := Pa_Rbs_Versions_Pub.G_Pkg_Name || ':::' || Pa_Debug.G_Path || '::' || Pa_Debug.G_Stage ||
                                    ':' || SqlErrm;
                If P_Init_Debugging_Flag = 'Y' Then
                        Rollback;
                Else
                        Raise;
                End If;

End Update_Working_Version;


-- =======================================================================
-- Start of Comments
-- API Name      : Delete_Working_Version
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure deletes the working rbs version as well as it elements/nodes.
--
--  Parameters:
--
--  IN
--      P_Commit                - Varchar2 Default Fnd_Api.G_False
--      P_Init_Msg_List         - Varchar2 Default Fnd_Api.G_True
--      P_Api_Version_Number    - Number
--      P_RBS_Version_Id        - Number(15)
--      P_Record_Version_Number - Number(15)
--  OUT
--      X_Return_Status         - Varchar2(1)
--      X_Msg_Count             - Number
--      X_Error_Msg_Data        - Varchar2(30)
--
/*-------------------------------------------------------------------------*/

Procedure Delete_Working_Version(
        P_Commit                IN         Varchar2 Default Fnd_Api.G_False,
        P_Init_Msg_List         IN         Varchar2 Default Fnd_Api.G_True,
        P_Api_Version_Number    IN         Number,
        P_RBS_Version_Id        IN         Number,
        P_Record_Version_Number IN         Number,
        X_Return_Status         OUT NOCOPY Varchar2,
        X_Msg_Count             OUT NOCOPY Number,
        X_Error_Msg_Data        OUT NOCOPY Varchar2)

Is

	l_Api_Name Varchar2(30) := 'Delete_Working_Version';
	l_Error    Exception;

Begin


        Pa_Debug.G_Path := ' ';

        Pa_Debug.G_Stage := 'Entering Delete_Working_Version() Pub.';
        Pa_Debug.TrackPath('ADD','Delete_Working_Version Pub');

        Pa_Debug.G_Stage := 'Call Compatibility API.';
        If Not Fnd_Api.Compatible_API_Call (
                        Pa_Rbs_Versions_Pub.G_Api_Version_Number,
                        P_Api_Version_Number,
                        l_Api_Name,
                        Pa_Rbs_Versions_Pub.G_Pkg_Name) Then

                Raise Fnd_Api.G_Exc_Unexpected_Error;

        End If;

	Pa_Debug.G_Stage := 'Check if need to initialize message stack.';
        If Fnd_Api.To_Boolean(nvl(P_Init_Msg_List,Fnd_Api.G_True)) Then

		Pa_Debug.G_Stage := 'Initialize Message Stack.';
                Fnd_Msg_Pub.Initialize;

        End If;

        Pa_Debug.G_Stage := 'Initialize error handling variables.';
        X_Msg_Count := 0;
        X_Error_Msg_Data := Null;
        X_Return_Status := Fnd_Api.G_Ret_Sts_Success;

	Pa_Debug.G_Stage := 'Call Pa_Rbs_Versions_Pvt.Delete_Working_Version() procedure.';
	Pa_Rbs_Versions_Pvt.Delete_Working_Version(
		P_Rbs_Version_Id        => P_RBS_Version_Id,
		P_Record_Version_Number => P_Record_Version_Number,
		P_Mode                  => Null,
		X_Error_Msg_Data        => X_Error_Msg_Data);

	Pa_Debug.G_Stage := 'Check if error message data is populated.';
	If X_Error_Msg_Data Is Not Null Then

		Pa_Debug.G_Stage := 'Raise user defined error due to error msg data parameter being populated.';
		Raise l_error;

	End If;

	Pa_Debug.G_Stage := 'Check to do commit(T-True,F-False) - ' || P_Commit;
        If Fnd_Api.To_Boolean(Nvl(P_Commit,Fnd_Api.G_False)) Then

                Commit;

        End If;

        Pa_Debug.G_Stage := 'Leaving Delete_Working_Version() Pub procedure.';
        Pa_Debug.TrackPath('STRIP','Delete_Working_Version Pub');

Exception
	When l_Error Then
		X_Return_Status := 'E';
		X_Msg_Count := 1;
	When Others Then
		X_Return_Status := 'U';
		X_Msg_Count := 1;
		X_Error_Msg_Data := Pa_Rbs_Versions_Pub.G_Pkg_Name || ':::' || Pa_Debug.G_Path || '::' || Pa_Debug.G_Stage ||
                                    ':' || SqlErrm;
		Rollback;

End Delete_Working_Version;


-- =======================================================================
-- Start of Comments
-- API Name      : Create_Working_Version
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure create a new working rbs version based on a previously frozen rbs version.
--
--  Parameters:
--
--  IN
--      P_Commit                - Varchar2 Default Fnd_Api.G_False,
--      P_Init_Msg_List         - Varchar2 Default Fnd_Api.G_True,
--      P_Api_Version_Number    - Number
--      P_RBS_Version_Id        - Number(15) is the frozen version id to copy from(should not be null copying)
--      P_Rbs_Header_Id         - Number(15) is Header for the frozen and the working version
--      P_Rec_Version_Number    - Number(15) is for the current working version
-- OUT
--      X_Return_Status         - Varchar2(1)
--      X_Msg_Count             - Number
--      X_Error_Msg_Data        - Varchar2(30)
--
/*-------------------------------------------------------------------------*/

Procedure Create_Working_Version (
	P_Commit		IN	   Varchar2 Default Fnd_Api.G_False,
	P_Init_Msg_List		IN	   Varchar2 Default Fnd_Api.G_True,
	P_Api_Version_Number	IN	   Number,
	P_RBS_Version_Id	IN	   Number Default Null,
	P_Rbs_Header_Id		IN	   Number,
	P_Rec_Version_Number	IN	   Number Default Null,
        P_Init_Debugging_Flag   IN         Varchar2 Default 'Y',
	X_Return_Status		OUT NOCOPY Varchar2,
	X_Msg_Count		OUT NOCOPY Number,
	X_Error_Msg_Data	OUT NOCOPY Varchar2 )

Is

	l_Api_Name Varchar2(30) := 'Create_Working_Version';
	l_Error    Exception;

Begin

        If P_Init_Debugging_Flag = 'Y' Then
                Pa_Debug.G_Path := ' ';
        End If;

        Pa_Debug.G_Stage := 'Entering Create_Working_Version().';
        Pa_Debug.TrackPath('ADD','Create_Working_Version');

        Pa_Debug.G_Stage := 'Call Compatibility API.';
        If Not Fnd_Api.Compatible_API_Call (
                        Pa_Rbs_Versions_Pub.G_Api_Version_Number,
                        P_Api_Version_Number,
                        l_Api_Name,
                        Pa_Rbs_Versions_Pub.G_Pkg_Name) Then

                Raise Fnd_Api.G_Exc_Unexpected_Error;

        End If;

        Pa_Debug.G_Stage := 'Check if need to initialize message stack.';
        If Fnd_Api.To_Boolean(nvl(P_Init_Msg_List,Fnd_Api.G_True)) Then

                Pa_Debug.G_Stage := 'Initialize Message Stack.';
                Fnd_Msg_Pub.Initialize;

        End If;

        Pa_Debug.G_Stage := 'Initialize error handling variables.';
        X_Msg_Count := 0;
        X_Error_Msg_Data := Null;
        X_Return_Status := Fnd_Api.G_Ret_Sts_Success;

	Pa_Debug.G_Stage := 'Call Pa_Rbs_Versions_Pvt.Create_New_Working_Version() procedure.';
        Pa_Rbs_Versions_Pvt.Create_New_Working_Version(
        	P_RBS_Version_Id        => P_RBS_Version_Id,
       	 	P_Rbs_Header_Id     	=> P_Rbs_Header_Id,
        	P_Record_Version_Number => P_Rec_Version_Number,
        	X_Error_Msg_Data        => X_Error_Msg_Data);

        Pa_Debug.G_Stage := 'Check if error message data is populated.';
        If X_Error_Msg_Data Is Not Null Then

                Pa_Debug.G_Stage := 'Raise user defined error due to error msg data parameter being populated.';
                Raise l_error;

        End If;

        Pa_Debug.G_Stage := 'Check to do commit(T-True,F-False) - ' || P_Commit;
        If Fnd_Api.To_Boolean(Nvl(P_Commit,Fnd_Api.G_False)) Then

                Commit;

        End If;

        Pa_Debug.G_Stage := 'Leaving Create_Working_Version() procedure.';
        Pa_Debug.TrackPath('STRIP','Create_Working_Version');

Exception
        When l_Error Then
                X_Return_Status := 'E';
                X_Msg_Count := 1;
        When Others Then
                X_Return_Status := 'U';
                X_Msg_Count := 1;
                X_Error_Msg_Data := Pa_Rbs_Versions_Pub.G_Pkg_Name || ':::' || Pa_Debug.G_Path || '::' || Pa_Debug.G_Stage ||
                                    ':' || SqlErrm;
                If P_Init_Debugging_Flag = 'Y' Then
                        Rollback;
                Else
                        Raise;
                End If;

End Create_Working_Version;


-- =======================================================================
-- Start of Comments
-- API Name      : Freeze_Working_Version
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure freezes working version and creates a new working version based on this frozen rbs version.
--		   If the RBS has no rules as its element then a copy of the version hierarchy is created with user_created_flag=N
--		   for RBS usage in allocation rules.
--
--  Parameters:
--
--  IN
--      P_Commit                                - Varchar2 Default Fnd_Api.G_False,
--      P_Init_Msg_List                         - Varchar2 Default Fnd_Api.G_True,
--      P_Rbs_Version_Id                        - Number(15) is the version id of the version to be freezed
--      P_Rbs_Version_Record_Ver_Num            - Number(15) is record version number of the version to be freezed
--      P_Init_Debugging_Flag                   - Vachar2(1)
-- OUT
--      X_Return_Status                         - Varchar2(1)
--      X_Msg_Count                             - Number
--      X_Error_Msg_Data                        - Varchar2(30)
--

PROCEDURE Freeze_Working_Version(
        P_Commit                     IN         Varchar2 Default Fnd_Api.G_False,
        P_Init_Msg_List              IN         Varchar2 Default Fnd_Api.G_True,
        P_Rbs_Version_Id             IN         Number,
        P_Rbs_Version_Record_Ver_Num IN         Number Default Null,
        P_Init_Debugging_Flag        IN         Varchar2 Default 'Y',
        X_Return_Status              OUT NOCOPY Varchar2,
        X_Msg_Count                  OUT NOCOPY Number,
        X_Error_Msg_Data             OUT NOCOPY Varchar2)
IS

        l_version_start_date            Date;
	l_end_date			Date   := Null;
        l_latest_freezed_version_id     Number;
        l_Error                         Exception;
	l_Rbs_Header_Id                 Number := Null;
        l_Rec_Version_Number            Number := Null;

        l_msg_count                     Number := 0;
        l_data                          Varchar2(2000);
        l_msg_data                      Varchar2(2000);
        l_msg_index_out                 Number;
	l_old_rbs_version_id		Number := Null;
	l_new_rbs_version_id		Number := Null;
  	l_project_id                    Number := Null;
        l_count                         Number := Null;
        l_assoc_count                   Number := Null;
        --This cursor gets the latest frozen versions Rbs_version_id
        Cursor GetLatestFrozenRbsVersionId(l_Rbs_Header_Id IN Number) Is
        Select
                Max(Rbs_Version_Id)
        From
                Pa_Rbs_Versions_B
        Where
               Rbs_Header_Id = l_Rbs_Header_Id
        And    Status_Code <> 'WORKING';

        Cursor c_GetVersionDates(P_Rbs_Ver_Id IN Number) Is
        Select
               Version_Start_Date,
               Nvl(Version_End_Date,SysDate) Version_End_Date
        From
               Pa_Rbs_Versions_B
        Where
               Rbs_Version_Id = P_Rbs_Ver_Id;

        l_Ver_Dates_Rec c_GetVersionDates%RowType;

        Cursor c_Record_Ver_No is
        Select
               Record_Version_Number
        From
               Pa_Rbs_Versions_B
        Where
               Rbs_Version_Id = P_Rbs_Version_Id
        For Update Of Version_Start_Date NoWait;

        RecInfo c_Record_Ver_No%RowType;

        l_Api_Name Varchar2(30) := 'Freeze_Working_Version';
        l_Api_Version_Number   Number := Null;
	--l_use_for_alloc_flag VARCHAR2(1);

BEGIN

        If P_Init_Debugging_Flag = 'Y' Then
                Pa_Debug.G_Path := ' ';
        End If;

        Pa_Debug.G_Stage := 'Entering Freeze_Working_Version().';
        Pa_Debug.TrackPath('ADD','Freeze_Working_Version');

        --Initialize the message stack if not initialized
        Pa_Debug.G_Stage := 'Check if need to initialize the error message stack.';
        If Fnd_Api.To_Boolean(nvl(P_Init_Msg_List,Fnd_Api.G_True)) Then

                Pa_Debug.G_Stage := 'Initialize the error message stack by calling Fnd_Msg_Pub.Initialize().';
                Fnd_Msg_Pub.Initialize;

        End If;

	Pa_Debug.G_Stage := 'Initialize error handling variables.';
        X_Msg_Count := 0;
        X_Error_Msg_Data := Null;
        X_Return_Status := Fnd_Api.G_Ret_Sts_Success;


        Pa_Debug.G_Stage := 'Check if the version record is locked.';
        Open c_record_ver_no;
        Fetch c_record_ver_no Into recinfo;

        If (c_Record_Ver_No%NotFound) Then
                Close c_Record_Ver_No;
        End If;

        Close c_record_ver_no;

        Pa_Debug.G_Stage := 'Check if Rbs Version record_version_number matches.';
        IF RecInfo.Record_Version_Number = P_Rbs_Version_Record_Ver_Num Then

                Null;

        Else

                Pa_Debug.G_Stage := 'Rbs Version record_version_number does not match.  Add error to message stack.';
                x_return_status := Fnd_Api.G_Ret_Sts_Error;

                Pa_Utils.Add_Message(
                        P_App_Short_Name => 'FND', /* Bug 3819654: Changed short name from PA to FND */
                        P_Msg_Name       => 'FND_LOCK_RECORD_ERROR');

                l_msg_count := Fnd_Msg_Pub.Count_Msg;
                If l_Msg_Count = 1 Then

                        Pa_Interface_Utils_Pub.Get_Messages(
                                P_Encoded      => Fnd_Api.G_True,
                                P_Msg_Index     => 1,
                                P_Msg_Count     => l_Msg_Count,
                                P_Msg_Data      => l_Msg_Data,
                                P_Data          => l_Data,
				P_Msg_Index_Out => l_Msg_Index_Out);

                        X_Error_Msg_Data := l_Data;
                        X_Msg_Count := l_Msg_Count;

                Else

                        X_Msg_Count := l_Msg_Count;

                End If;

                Raise l_error;

        END IF;

        Pa_Debug.G_Stage := 'Get the Version_Start_Date and Rbs_Header_Id of working version.';
        Select
                Version_Start_Date,
                Rbs_Header_Id
        Into
                l_Version_Start_Date,
                l_Rbs_Header_Id
        From
                Pa_Rbs_Versions_B
        Where
                Rbs_Version_Id = P_Rbs_Version_Id;

	--commented out since checking of this flag is not needed to copy hierarchy of elements when we freeze a version
	-- For bug 3659078
	--SELECT
	--	USE_FOR_ALLOC_FLAG
	--INTO
	--	l_use_for_alloc_flag
	--FROM
	--	Pa_Rbs_Headers_b
	--Where
	--	Rbs_Header_Id=l_Rbs_Header_Id;

        Pa_Debug.G_Stage:= 'Getting version id of the latest freezed version';
        Open GetLatestFrozenRbsVersionId(l_Rbs_Header_Id);
        Fetch GetLatestFrozenRbsVersionId Into l_latest_freezed_version_id;
	Close GetLatestFrozenRbsVersionId;

        --If either resource type id or resource source id is different for each element of working version compared to latest,
        --freezed version,give them new element identifiers.

        Pa_Debug.G_Stage:= 'Updating element identifiers of the rbs elements for the working version which do not match latest freeze.';
        -- Bug 3635614 changed the update statement by removing the start with and connect by prior clause and used where clause instead
        Update pa_rbs_elements
        Set
              Element_Identifier = Pa_Rbs_Element_Identifier_S.NextVal
        Where
              Rbs_Element_Id IN (
                                Select
                                       Distinct a.Rbs_Element_Id
                                From
                                       Pa_Rbs_Elements a,
                                       Pa_Rbs_Elements b
                                Where
                                       a.Element_Identifier = b.Element_Identifier
                                And    a.Rbs_Version_Id = P_Rbs_Version_Id
                                And    b.Rbs_Version_Id = l_Latest_Freezed_Version_Id
                                And    a.Resource_Type_Id <> -1
                                And    b.Resource_Type_id <> -1
                                And  ( a.Resource_Source_Id <> b.Resource_Source_Id Or
                                       a.Resource_Type_Id <> b.Resource_Type_Id) );

	-- For Bug 3659078
	--Description
	--When the RBS is frozen, we will create a copy of that
	--hierarchy with "user_created_flag = 'N' if use_for_alloc_flag is set to Y.

	--The above logic is changed. We copy hierarchy only when we freeze a RBS having no rules as its elements
	--irrespective of the use_for_alloc_flag value.

	IF PA_RBS_HEADER_PVT.Validate_Rbs_For_Allocations(p_rbs_id=>l_Rbs_Header_Id)='N' Then --When RBS has no rules as its element
	--If l_use_for_alloc_flag='Y' Then

		Pa_Debug.G_Stage:= 'Copying All Elements With user_created_Flag = N';

		Pa_Debug.G_Stage:= 'Delete All Records From Pa_Rbs_Elements_Temp';
		Begin

                	Delete
                	From Pa_Rbs_Elements_Temp;

        	Exception
                	When No_Data_Found Then
                        	null;

        	End;

		Pa_Debug.G_Stage:= 'Insert Pa_Rbs_Elements_Temp table with new element_ids';

        	Insert Into Pa_Rbs_Elements_Temp(
                	New_Element_Id,
                	Old_Element_Id,
                	Old_Parent_Element_Id,
                	New_Parent_Element_Id )
        	(Select
                	Pa_Rbs_Elements_S.NextVal,
                	Rbs_Element_Id,
                	Parent_Element_Id,
                	Null
         	From
                	Pa_Rbs_Elements
         	Where
                	Rbs_Version_Id = P_Rbs_Version_Id
         	and    user_created_flag = 'Y' );

		Update Pa_Rbs_Elements_Temp Tmp1
        	Set New_Parent_Element_Id =
                	(Select
                        	New_Element_Id
                 	From
                        	Pa_Rbs_Elements_Temp Tmp2
                 	Where
                        	Tmp1.Old_Parent_Element_Id = Tmp2.Old_Element_Id);

		Pa_Debug.G_Stage:= 'Insert all records with user_created_flag=N with new element ids updated with new parent element ids';

		/*Bug 4377886 : Included explicitly the column names in the INSERT statement
				to remove the GSCC Warning File.Sql.33 */
		Insert Into pa_rbs_elements
                (
                RBS_ELEMENT_ID,
	 	RBS_ELEMENT_NAME_ID,
		RBS_VERSION_ID,
		OUTLINE_NUMBER,
		ORDER_NUMBER,
		RESOURCE_TYPE_ID,
		RESOURCE_SOURCE_ID,
		PERSON_ID,
		JOB_ID,
		ORGANIZATION_ID,
		EXPENDITURE_TYPE_ID,
		EVENT_TYPE_ID,
		EXPENDITURE_CATEGORY_ID,
		REVENUE_CATEGORY_ID,
		inventory_item_id,
		item_category_id,
		bom_labor_id,
		bom_equipment_id,
		non_labor_resource_id,
		role_id,
		person_type_id,
		resource_class_id,
		supplier_id,
		rule_flag,
		PARENT_ELEMENT_ID,
		rbs_level,
		element_identifier,
		user_defined_custom1_id,
		user_defined_custom2_id,
		user_defined_custom3_id,
		user_defined_custom4_id,
		user_defined_custom5_id,
		USER_CREATED_FLAG,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN,
		RECORD_VERSION_NUMBER)
		SELECT
			Tmp.New_Element_Id,
			Ele.rbs_element_name_id,
			P_Rbs_Version_Id,
			Ele.outline_number,
			Ele.order_Number,
			Ele.resource_type_id,
			Ele.resource_source_id,
			Ele.person_id,
			Ele.job_id,
			Ele.organization_id,
			Ele.Expenditure_Type_Id,
			Ele.Event_Type_Id,
			Ele.expenditure_category_id,
			Ele.revenue_category_id,
			Ele.inventory_item_id,
			Ele.item_category_id,
			Ele.bom_labor_id,
			Ele.bom_equipment_id,
			Ele.non_labor_resource_id,
			Ele.role_id,
			Ele.person_type_id,
			Ele.resource_class_id,
			Ele.supplier_id,
			Ele.rule_flag,
			Tmp.New_parent_element_id,
			Ele.rbs_level,
			Ele.element_identifier,
			Ele.user_defined_custom1_id,
			Ele.user_defined_custom2_id,
			Ele.user_defined_custom3_id,
			Ele.user_defined_custom4_id,
			Ele.user_defined_custom5_id,
			'N',
			sysdate,
			fnd_global.user_id,
			sysdate,
			fnd_global.user_id,
			fnd_global.login_id,
			1
		FROM
			Pa_Rbs_Elements Ele,
			Pa_Rbs_Elements_Temp Tmp
		WHERE
			Tmp.Old_Element_Id=Ele.Rbs_Element_Id;

	End IF; --End of changes made for bug 3659078. modified for bug 3703364

        Pa_Debug.G_Stage := 'Mark the working version as frozen.';
        Update Pa_Rbs_Versions_B
        Set
                Status_code = 'FROZEN'
        Where
                Rbs_Version_Id = P_Rbs_Version_Id;


        Open c_GetVersionDates(P_Rbs_Ver_Id => l_Latest_Freezed_Version_Id);
        Fetch c_GetVersionDates Into l_Ver_Dates_Rec;
        Close c_GetVersionDates;


	Pa_Debug.G_Stage := 'Set the version end date of latest freezed version to 1 minus start date of version being freezed,';
	Pa_Debug.G_Stage := 'if they are not equal';

	Pa_Debug.G_Stage := 'Set the version end date of latest freezed version to start date of version being freezed,';
        Pa_Debug.G_Stage := 'if they are equal';

	If ((l_version_start_date-1)<(l_ver_dates_rec.Version_start_date)) Then

		  l_end_date := l_version_start_date;
	Else

		  l_end_date := l_version_start_date-1;

	End If;


        Update Pa_Rbs_Versions_B
        Set
                Version_End_Date = l_end_date
        Where
                Rbs_Version_Id = l_Latest_Freezed_Version_Id;

        /***********************************************************
         * Bug - 3617050
         * Desc - we are getting the count of the versions associated
         *        with the header id.
         *        If the count is one, only then we will set the current
         *        reporting flag as Null.
         *        because more than 1 version for a header cannot have
         *        current_reporting_flag set. so we are only setting it
         *        for the 1st frozen version.
         ******************************************************************/
         BEGIN
            SELECT count(*)
            INTO l_count
            FROM pa_rbs_versions_b
            where rbs_header_id = l_rbs_header_id;
         EXCEPTION
         WHEN OTHERS THEN
            l_count := 0;
         END;

         IF l_count = 1 THEN
            Update pa_rbs_versions_b
            Set current_reporting_flag = 'Y'
            where rbs_version_id = p_rbs_version_id;
         END IF;

        -- Bug 3987478 - If RBS is not associated to any projects, the
        -- PJI push will not pick it up.  We still need to set the current
	-- reporting flag as Yes for the latest frozen version.

        -- Check any associations exist for the RBS Header.
        SELECT count(*)
          INTO l_assoc_count
          FROM pa_rbs_prj_assignments
         WHERE rbs_header_id = l_rbs_header_id;

        IF l_assoc_count = 0 THEN
           UPDATE pa_rbs_versions_b
           SET    current_reporting_flag = 'Y'
           WHERE  rbs_version_id = p_rbs_version_id;

           UPDATE pa_rbs_versions_b
           SET    current_reporting_flag = NULL
           WHERE  rbs_header_id = l_rbs_header_id
           AND    rbs_version_id <> p_rbs_version_id;

           -- Similarly, if an RBS is used in allocations but not projects,
           -- need to update the latest version to allocations.
           PA_ALLOC_UTILS.ASSOCIATE_RBS_TO_ALLOC_RULE(
             p_rbs_header_id  => l_rbs_header_id,
             p_rbs_version_id => p_rbs_version_id,
             x_return_status  => x_return_status,
             x_error_code     => x_error_msg_data);

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              pa_debug.G_Stage := 'Error in API PA_ALLOC_UTILS.ASSOCIATE_RBS_TO_ALLOC_RULE';
              Raise l_error;
           END IF;

        END IF; /* End of Bug 3987478 changes */

        Pa_Debug.G_Stage := 'Check if we have a error message populated.';
	If X_Error_Msg_Data Is Not Null Then

                Pa_Debug.G_Stage := 'We have a error message populated.  Raise error.';
                Raise l_error;

	Else

                Pa_Debug.G_Stage := 'Prepare to call Pji_FM_Xbs_Accum_Maint.Rbs_Push() procedure.';
		l_Old_Rbs_Version_Id := l_latest_freezed_version_id;
		l_New_Rbs_Version_Id := P_Rbs_Version_Id;

                Pa_Debug.G_Stage := 'Call Pji_FM_Xbs_Accum_Maint.Rbs_Push() procedure.';
		Pji_FM_Xbs_Accum_Maint.Rbs_Push(
		        P_Old_Rbs_Version_Id => l_Old_Rbs_Version_Id,
		        P_New_Rbs_Version_Id => l_New_Rbs_Version_Id,
		        P_Project_Id         => l_Project_Id,
		        X_Return_Status      => X_Return_Status,
		        X_Msg_Code           => X_Error_Msg_Data);

	End If;

	--For Bug 3678165
	If X_Error_Msg_Data Is Not Null Then
		Pa_Debug.G_Stage := 'We have a error message populated.  Raise error.';
                Raise l_error;

        Else

                Pa_Debug.G_Stage := 'Prepare to call pa_rbs_mapping.create_mapping_rules() procedure.';
		Pa_Rbs_Mapping.Create_Mapping_Rules(
			P_Rbs_Version_Id    => P_Rbs_Version_Id,
			X_Return_Status     => X_Return_Status,
			X_Msg_Count         => X_Msg_Count,
			X_Msg_Data          => X_Error_Msg_Data);
	End If;

        l_Api_Version_Number := 1;

        Pa_Debug.G_Stage := 'Create a copy of the version being freezed which will be the working version for this header.';
        Pa_Rbs_Versions_Pub.Create_Working_Version(
                P_Commit              => Fnd_Api.G_False,
                P_Init_Msg_List       => Fnd_Api.G_False,
                P_Api_Version_Number  => l_Api_Version_Number,
                P_RBS_Version_Id      => P_RBS_Version_Id,
                P_Rbs_Header_Id       => l_Rbs_Header_Id,
                P_Rec_Version_Number  => l_Rec_Version_Number,
                P_Init_Debugging_Flag => 'N',
                X_Return_Status       => X_Return_Status,
                X_Msg_Count           => X_Msg_Count,
                X_Error_Msg_Data      => X_Error_Msg_Data);

        Pa_Debug.G_Stage := 'Check if Pa_Rbs_Versions_Pub.Create_Working_Version() procedure return error.';
        IF X_Error_Msg_Data Is Not Null Then

                Pa_Debug.G_Stage := 'Check if Pa_Rbs_Versions_Pub.Create_Working_Version() procedure return error.';
                Raise l_error;

        END IF;

        Pa_Debug.G_Stage := 'Check if need to do commit.';
        If Fnd_Api.To_Boolean(Nvl(P_Commit,Fnd_Api.G_False)) Then

                Pa_Debug.G_Stage := 'Commit changes to the db.';
                Commit;

        End If;

        Pa_Debug.G_Stage := 'Leaving Freeze_Working_Version() procedure.';
        Pa_Debug.TrackPath('STRIP','Freeze_Working_Version');

Exception
        When l_Error Then
                X_Return_Status := 'E';
                X_Msg_Count := 1;

        When Others Then
                X_Return_Status := 'E';
                X_Msg_Count := 1;
                X_Error_Msg_Data := Pa_Rbs_Versions_Pub.G_Pkg_Name || ':::' || Pa_Debug.G_Path || '::' || Pa_Debug.G_Stage ||
                                    ':' || SqlErrm;
                If P_Init_Debugging_Flag = 'Y' Then
                       Rollback;
                Else
                       Raise;
                End If;

END Freeze_Working_Version;

End Pa_Rbs_Versions_Pub;

/
