--------------------------------------------------------
--  DDL for Package Body PA_RBS_VERSIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RBS_VERSIONS_PVT" as
--$Header: PARBSVVB.pls 120.1 2005/08/25 03:50:50 sunkalya noship $

Procedure Create_Working_Version_Record(
	P_Mode                  IN         Varchar2 Default Null,
	P_Version_Number	IN	   Number,
	P_Rbs_Header_Id		IN	   Number,
	P_Record_Version_Number IN         Number,
	P_Name			IN	   Varchar2,
	P_Description		IN	   Varchar2,
	P_Version_Start_Date	IN	   Date,
	P_Version_End_Date	IN	   Date,
	P_Job_Group_Id		IN	   Number,
	P_Rule_Based_Flag	IN	   Varchar2,
	P_Validated_Flag	IN	   Varchar2,
	P_Status_Code		IN	   Varchar2,
	X_Record_Version_Number	OUT NOCOPY Number,
	X_RBS_Version_Id	OUT NOCOPY Number,
	X_Error_Msg_Data	OUT NOCOPY Varchar2 )

Is

Begin

        Pa_Debug.G_Stage := 'Entering Create_Working_Version_Record().';
        Pa_Debug.TrackPath('ADD','Create_Working_Version_Record');

	Pa_Debug.G_Stage := 'Call Pa_Rbs_Versions_Pkg.Insert_Row() procedure.';
	Pa_Rbs_Versions_Pkg.Insert_Row(
		P_Version_Number	=> P_Version_Number,
		P_Rbs_Header_Id		=> P_Rbs_Header_Id,
		P_Record_Version_Number => P_Record_Version_Number,
		P_Name			=> P_Name,
		P_Description		=> P_Description,
		P_Version_Start_Date	=> P_Version_Start_Date,
		P_Version_End_Date	=> P_Version_End_Date,
		P_Job_Group_Id		=> P_Job_Group_Id,
		P_Rule_Based_Flag	=> P_Rule_Based_Flag,
		P_Validated_Flag	=> P_Validated_Flag,
		P_Status_Code		=> P_Status_Code,
		P_Creation_Date		=> Pa_Rbs_Versions_Pvt.G_Creation_Date,
		P_Created_By		=> Pa_Rbs_Versions_Pvt.G_Created_By,
		P_Last_Update_Date	=> Pa_Rbs_Versions_Pvt.G_Last_Update_Date,
		P_Last_Updated_By	=> Pa_Rbs_Versions_Pvt.G_Last_Updated_By,
		P_Last_Update_Login	=> Pa_Rbs_Versions_Pvt.G_Last_Update_Login,
		X_Record_Version_Number => X_Record_Version_Number,
		X_Rbs_Version_Id	=> X_RBS_Version_Id,
		X_Error_Msg_Data	=> X_Error_Msg_Data);

	Pa_Debug.G_Stage := 'Check if Pa_Rbs_Versions_Pkg.Insert_Row() procedure returned error msg.';
        If X_Error_Msg_Data is Not Null And P_Mode is Null Then

		Pa_Debug.G_Stage := 'Add Message to message stack.';
                Pa_Utils.Add_Message
                        (P_App_Short_Name => 'PA',
                         P_Msg_Name       => X_Error_Msg_Data);

        End If;

        Pa_Debug.G_Stage := 'Leaving Create_Working_Version_Record()procedure.';
        Pa_Debug.TrackPath('STRIP','Create_Working_Version_Record');

Exception
	When Others Then
		Raise;

End Create_Working_Version_Record;

Procedure Update_Working_Version(
	P_RBS_Version_Id	IN	   Number,
	P_Name			IN	   Varchar2,
	P_Description		IN	   Varchar2,
	P_Version_Start_Date	IN	   Date	,
	P_Job_Group_Id		IN	   Number,
	P_Record_Version_Number	IN	   Number,
	X_Record_Version_Number OUT NOCOPY Number,
	X_Error_Msg_Data	OUT NOCOPY Varchar2 )

Is

Begin

        Pa_Debug.G_Stage := 'Entering Update_Working_Version() Pvt.';
        Pa_Debug.TrackPath('ADD','Update_Working_Version Pvt');

	Pa_Debug.G_Stage := 'Call Pa_Rbs_Versions_Pkg.Update_Row() procedure.';
	Pa_Rbs_Versions_Pkg.Update_Row(
		P_RBS_Version_Id        => P_RBS_Version_Id,
		P_Name                  => P_Name,
		P_Description           => P_Description,
		P_Version_Start_Date    => P_Version_Start_Date,
		P_Job_Group_Id          => P_Job_Group_Id,
		P_Record_Version_Number => P_Record_Version_Number,
		P_Last_Update_Date      => Pa_Rbs_Versions_Pvt.G_Last_Update_Date,
		P_Last_Updated_By       => Pa_Rbs_Versions_Pvt.G_Last_Updated_By,
		P_Last_Update_Login     => Pa_Rbs_Versions_Pvt.G_Last_Update_Login,
		X_Record_Version_Number => X_Record_Version_Number,
		X_Error_Msg_Data	=> X_Error_Msg_Data);

	Pa_Debug.G_Stage := 'Check if Pa_Rbs_Versions_Pkg.Update_Row() procedure returned error msg.';
	If X_Error_Msg_Data is Not Null Then

		Pa_Debug.G_Stage := 'Add Message to message stack.';
		Pa_Utils.Add_Message
                	(P_App_Short_Name => 'PA',
                 	 P_Msg_Name       => X_Error_Msg_Data);

	End If;

        Pa_Debug.G_Stage := 'Leaving Update_Working_Version() Pvt procedure.';
        Pa_Debug.TrackPath('STRIP','Update_Working_Version Pvt');

Exception
	When Others Then
		Raise;

End Update_Working_Version;

Procedure Delete_Working_Version(
	P_Mode                  IN         Varchar2 Default Null,
        P_RBS_Version_Id        IN         Number,
        P_Record_Version_Number IN         Number,
        X_Error_Msg_Data        OUT NOCOPY Varchar2)

Is


Begin

        Pa_Debug.G_Stage := 'Entering Delete_Working_Version() Pvt.';
        Pa_Debug.TrackPath('ADD','Delete_Working_Version Pvt');

        Pa_Debug.G_Stage := 'Call Pa_Rbs_Versions_Pkg.Delete_Row() procedure.';
	Pa_Rbs_Versions_Pkg.Delete_Row(
		P_RBS_Version_Id        => P_RBS_Version_Id,
		P_Record_Version_Number => P_Record_Version_Number,
		X_Error_Msg_Data        => X_Error_Msg_Data);

        Pa_Debug.G_Stage := 'Check if Pa_Rbs_Versions_Pkg.Delete_Row() procedure returned error msg.';
        If X_Error_Msg_Data is Not Null and P_Mode is Null Then

                Pa_Debug.G_Stage := 'Add Message to message stack.';
                Pa_Utils.Add_Message
                        (P_App_Short_Name => 'PA',
                         P_Msg_Name       => X_Error_Msg_Data);

        End If;

	If X_Error_Msg_Data is Null Then


		Pa_Debug.G_Stage := 'Delete the working version element/nodes.';
		Begin
			Delete
			From
				Pa_Rbs_Elements
			Where
				Rbs_Version_Id = P_Rbs_Version_Id;

		Exception
			When No_Data_Found Then
				Null;
			When Others Then
				Raise;

		End;

	End If;


        Pa_Debug.G_Stage := 'Leaving Delete_Working_Version() Pvt procedure.';
        Pa_Debug.TrackPath('STRIP','Delete_Working_Version Pvt');

Exception
	When Others Then
		Raise;

End Delete_Working_Version;

Procedure Create_New_Working_Version(
		P_Rbs_Version_Id        IN  Number,
		P_Rbs_Header_Id         IN  Number,
		P_Record_Version_Number IN  Number,
		X_Error_Msg_Data        OUT NOCOPY Varchar2)
Is

	l_Rbs_Version_Id Number(15) := Null;
	l_Error          EXCEPTION;

Begin

        Pa_Debug.G_Stage := 'Entering Create_New_Working_Version().';
        Pa_Debug.TrackPath('ADD','Create_New_Working_Version');


        Pa_Debug.G_Stage := 'Call Pa_Rbs_Versions_Pvt.Copy_Frozen_Rbs_Version() procedure.';
	Pa_Rbs_Versions_Pvt.Copy_Frozen_Rbs_Version(
		P_Rbs_Version_Id        => P_Rbs_Version_Id,  -- the frozen version being copied
		P_Rbs_Header_Id         => P_Rbs_Header_Id,
		P_Record_Version_Number => P_Record_Version_Number,  -- This is the record_version_number of the working version
		X_Rbs_Version_Id        => l_Rbs_Version_Id,  -- The working version being copied to
		X_Error_Msg_Data        => X_Error_Msg_Data);

        Pa_Debug.G_Stage := 'Check if Pa_Rbs_Versions_Pkg.Copy_Frozen_Rbs_Version() procedure returned error msg.';
        If X_Error_Msg_Data is Not Null Then

                Pa_Debug.G_Stage := 'Add Message to message stack.';
                Pa_Utils.Add_Message
                        (P_App_Short_Name => 'PA',
                         P_Msg_Name       => X_Error_Msg_Data);

		Raise l_Error;

        End If;

	Pa_Debug.G_Stage := 'Call Pa_Rbs_Versions_Pvt.Copy_Frozen_Rbs_Elements() procedure.';


	Pa_Rbs_Versions_Pvt.Copy_Frozen_Rbs_Elements(
		P_Rbs_Version_From_Id  => P_Rbs_Version_Id,  -- this is the frozen version being copied from
		P_Rbs_Version_To_Id  => l_Rbs_Version_Id,    -- this is the working version being copied to
		X_Error_Msg_Data  => X_Error_Msg_Data);


	Pa_Debug.G_Stage := 'Check if Pa_Rbs_Versions_Pkg.Copy_Frozen_Rbs_Elements() procedure returned error msg.';
        If X_Error_Msg_Data is Not Null Then

		Pa_Debug.G_Stage := 'Add Message to message stack.';
                Pa_Utils.Add_Message
                        (P_App_Short_Name => 'PA',
                         P_Msg_Name       => X_Error_Msg_Data);

        End If;

        Pa_Debug.G_Stage := 'Leaving Create_New_Working_Version() procedure.';
        Pa_Debug.TrackPath('STRIP','Create_New_Working_Version');



Exception
	When l_Error Then
		Null;

	When Others Then
		Raise;

End Create_New_Working_Version;

Procedure Copy_Frozen_Rbs_Version(
	P_Rbs_Version_Id        IN  Number,
	P_Rbs_Header_Id		IN  Number,
	P_Record_Version_Number IN  Number,
	X_Rbs_Version_Id	OUT NOCOPY Number,
	X_Error_Msg_Data	OUT NOCOPY Varchar2)

Is

	l_Version_Number        Number(15);
	l_Name                  Varchar2(240);
	l_Description           Varchar2(2000);
	l_Version_Start_Date    Date;
	l_Job_Group_Id          Number;
	l_Rule_Based_Flag       Varchar2(1);
	l_Validated_Flag        Varchar2(1);
	l_Created_By            Number		:= Fnd_Global.User_Id;
	l_Creation_date         Date		:= SysDate;
	l_Last_Update_Date      Date		:= SysDate;
	l_Last_Updated_By       Number		:= Fnd_Global.User_Id;
	l_Last_Update_Login     Number		:= Fnd_Global.Login_Id;
	l_Working 		Varchar2(1);
	l_Record_Locked		Exception;
	l_Msg_Data		Varchar2(2000)	:= Null;
	l_Msg_Count		Number		:= 0;
	l_Data			Varchar2(2000)	:= Null;
	l_Msg_Index_Out		Number;
	l_Version_Id		Number(15);
	l_Rec_Version_Number    Number		:= Null;
        --Bug: 4537865
        l_new_Rec_Version_Number 	NUMBER  := Null;
        --Bug: 4537865
	l_Error_Msg_Data	Varchar2(30)	:= Null;

	Cursor GetDetails(P_Id IN Number) IS
	Select
		Job_Group_Id,
		Rule_Based_Flag,
                Version_End_Date
	From
		Pa_Rbs_Versions_B
	Where
		Rbs_Version_Id = P_Id;

	Cursor GetDetails2(P_Id IN Number) Is
	Select
		Description
	From
		Pa_Rbs_Versions_TL
	Where
		Rbs_Version_Id = P_Id
        --MLS changes.
	--And	Source_Lang = UserEnv('LANG');
	And	Language = UserEnv('LANG');

	GetDetails_Rec GetDetails%RowType;
	GetDetails_Rec2 GetDetails2%RowType;

	Cursor C is
	Select
		Record_Version_Number,
		Rbs_Version_Id
	From
		Pa_Rbs_Versions_B
	Where
		Rbs_Header_Id = P_Rbs_Header_Id
	And 	Status_Code = 'WORKING'
	For Update Of Status_Code NoWait;

	Cursor GetMaxFrozenRbsVersionId(P_Id IN Number) Is
        Select
        	Max(Rbs_Version_Id)
        From
                Pa_Rbs_Versions_B
        Where
                Rbs_Header_Id = P_Rbs_Header_Id
        And     Status_Code <> 'WORKING';

        Cursor c_GetHdrFromDate(P_Hdr_Id IN Number) Is
        Select
                Effective_From_Date
        From
                Pa_Rbs_Headers_B
        Where
                Rbs_Header_Id = P_Hdr_Id;

	Cursor C_GetRbsElementNameId(l_Rbs_Version_Id IN Number) is
	Select
		rbs_element_name_id
	From
		pa_rbs_elements
	Where
		rbs_version_id	= l_Rbs_Version_Id
	and	outline_number	=	'0';


	l_RVN 		        Number(15) := Null;
	l_Rbs_Version_Id        Number(15) := Null;
	l_Rbs_Version_From_Id   Number(15) := Null;
	l_Frozen_Rbs_Ver_Exists BOOLEAN    := False;
        l_Hdr_From_Date         Date;
	l_Rbs_Element_Name_Id     Number(15) := Null;

BEGIN

        Pa_Debug.G_Stage := 'Entering Copy_Frozen_Rbs_Version() procedure.';
        Pa_Debug.TrackPath('ADD','Copy_Frozen_Rbs_Version');

        Pa_Debug.G_Stage := 'Check if the rbs_version_id to copy from parameter is populated.';
	If P_Rbs_Version_Id is Null Then

		Pa_Debug.G_Stage := 'Get the max rbs version id for the rbs header as the copy from rbs version.';
		Open GetMaxFrozenRbsVersionId(P_Rbs_Header_Id);
		Fetch GetMaxFrozenRbsVersionId Into l_Rbs_Version_From_Id;
		Close GetMaxFrozenRbsVersionId;

	Else

		Pa_Debug.G_Stage := 'Using the rbs version id passed in as the copy from rbs version.';
		l_Rbs_Version_From_Id := P_Rbs_Version_Id;

	End If;

        Pa_Debug.G_Stage := 'Get details from record in pa_rbs_versions_b to copy from.';
        /* To get the details of selected version*/
	Open GetDetails(l_Rbs_Version_From_Id);
	Fetch GetDetails Into GetDetails_Rec;
	If GetDetails%NotFound Then

                Pa_Debug.G_Stage := 'No frozen version record found.';
		l_Frozen_Rbs_Ver_Exists := False;
		Close GetDetails;

	Else

		l_Frozen_Rbs_Ver_Exists := True;
		Close GetDetails;

		Pa_Debug.G_Stage := 'Get details from record in pa_rbs_versions_tl to copy from.';
		Open GetDetails2(l_Rbs_Version_From_Id);
		Fetch GetDetails2 Into GetDetails_Rec2;
		Close GetDetails2;

	End If;

	Pa_Debug.G_Stage := 'Get working version record data from pa_rbs_versions_b.';
	Open C;
	Fetch C Into l_rvn, l_Rbs_Version_Id;
	Close C;

	Open C_GetRbsElementNameId(l_Rbs_Version_Id);
	Fetch C_GetRbsElementNameId Into l_Rbs_Element_Name_Id;
	Close C_GetRbsElementNameId;

	Pa_Debug.G_Stage := 'Check if there is a working version record or not.';
	If l_RVN <> 0 or l_RVN is Not Null Then


		Pa_Debug.G_Stage := 'Check if the record version parameter matches with the record ' ||
					       'version number from working version..';
		If l_Rvn = P_Record_Version_Number Then


			-- Delete the current working rbs version and its element/node records
			Pa_Debug.G_Stage := 'Call Pa_Rbs_Versions_Pvt.Delete_Working_Version() procedure.';
			Pa_Rbs_Versions_Pvt.Delete_Working_Version(
				P_Mode                  => 'COPYING_FROZEN_VERSION',
				P_Rbs_Version_Id        => l_Rbs_Version_Id,
				P_Record_Version_Number => P_Record_Version_Number,
				X_Error_Msg_Data        => X_Error_Msg_Data);

			Pa_Debug.G_Stage := 'Delete the record in pa_rbs_element_names table corresponding to that ' ||
						'of top most element in pa_rbs_elements table.';
			If X_Error_Msg_Data is null then

				Begin

					Delete
                        		From
                                		Pa_Rbs_Element_names_tl
                        		Where
                                		Rbs_Element_Name_Id = l_Rbs_Element_Name_Id;

                        		Delete
                        		From
                                		Pa_Rbs_Element_names_b
                        		Where
                                		Rbs_Element_Name_Id = l_Rbs_Element_Name_Id;

                		Exception
                        		When No_Data_Found Then
                                		Null;
                        		When Others Then
                                		Raise;
                		End;
			Else

				Pa_Debug.G_Stage := 'Add Message to message stack.';
                		Pa_Utils.Add_Message
                        		(P_App_Short_Name => 'PA',
                         		P_Msg_Name       => X_Error_Msg_Data);
			End If;

		Else

			Pa_Debug.G_Stage := 'Unable to lock record.  Raise user defined error.';
			Raise l_Record_Locked;

		End If;

	End If ;  --  end of if l_rvn <>0

        Pa_Debug.G_Stage := 'Increment the record version number based on the value passed in.';
	l_Rec_Version_Number := Nvl(P_Record_Version_number,0) + 1;

	Pa_Debug.G_Stage := 'Derived next available version number for use in creating new working version record.';
	Select
		Nvl(Max(Version_Number),0) + 1
	Into
		l_Version_Number
	From
		Pa_Rbs_Versions_B
	Where
		Rbs_Header_Id = P_Rbs_Header_Id;

	Pa_Debug.G_Stage := 'Get the Rbs Name from pa_rbs_headers_tl.';
	Select
		Name
	Into
		l_Name
	From
		Pa_Rbs_Headers_TL
	Where
		Rbs_Header_Id = P_Rbs_Header_Id
        --MLS Changes
	--And	Source_lang = UserEnv('LANG');
	And	Language = UserEnv('LANG');

	Pa_Debug.G_Stage := 'Create new version name based on the header name and avaliable version number.';
	l_name := l_name || ' ' || to_char(l_Version_Number);

	If l_Frozen_Rbs_Ver_Exists Then

                Pa_Debug.G_Stage := 'Use the version end date of last frozen version to derive new start date adding 1 to it.';
                GetDetails_Rec.Version_End_Date := GetDetails_Rec.Version_End_Date + 1;

		Pa_Debug.G_Stage := 'Call Pa_Rbs_Versions_Pkg.Insert_Row() procedure from existing .';
		Pa_Rbs_Versions_Pvt.Create_Working_Version_Record(
			P_Mode			=> 'COPYING_FROZEN_VERSION',
			P_Version_Number        => l_Version_Number,
			P_Rbs_Header_Id         => P_Rbs_Header_Id,
			P_Record_Version_Number => l_Rec_Version_Number,
			P_Name                  => l_Name,
			P_Description           => GetDetails_Rec2.Description,
			P_Version_Start_Date    => GetDetails_Rec.Version_End_Date,
			P_Version_End_Date      => Null,
			P_Job_Group_Id          => GetDetails_Rec.Job_Group_Id,
			P_Rule_Based_Flag       => GetDetails_Rec.Rule_Based_Flag,
			P_Validated_Flag        => 'N',
			P_Status_Code           =>'WORKING',
		      --X_Record_Version_Number => l_Rec_Version_Number,	--Bug: 4537865
			X_Record_Version_Number => l_new_Rec_Version_Number,	--Bug: 4537865
			X_RBS_Version_Id        => X_Rbs_Version_Id,
			X_Error_Msg_Data        => X_Error_Msg_Data);
	--Bug: 4537865
	l_Rec_Version_Number := l_new_Rec_Version_Number;
	--Bug: 4537865

	Else

                Pa_Debug.G_Stage := 'This is the first version and the start date must match the header from date, so get from header.';
                Open c_GetHdrFromDate(P_Hdr_Id => P_Rbs_Header_Id);
                Fetch c_GetHdrFromDate Into l_Hdr_From_Date;
                Close c_GetHdrFromDate;

                Pa_Debug.G_Stage := 'Call Pa_Rbs_Versions_Pkg.Insert_Row() procedure brand new.';
                Pa_Rbs_Versions_Pvt.Create_Working_Version_Record(
                        P_Mode                  => 'COPYING_FROZEN_VERSION',
                        P_Version_Number        => l_Version_Number,
                        P_Rbs_Header_Id         => P_Rbs_Header_Id,
		        P_Record_Version_Number => l_Rec_Version_Number,
                        P_Name                  => l_Name,
                        P_Description           => Null,
                        P_Version_Start_Date    => l_Hdr_From_Date,
                        P_Version_End_Date      => Null,
                        P_Job_Group_Id          => Null,
                        P_Rule_Based_Flag       => 'N',
                        P_Validated_Flag        => 'N',
                        P_Status_Code           =>'WORKING',
                      --X_Record_Version_Number => l_Rec_Version_Number,	--Bug: 4537865
			X_Record_Version_Number => l_new_Rec_Version_Number,	--Bug: 4537865
                        X_RBS_Version_Id        => X_Rbs_Version_Id,
                        X_Error_Msg_Data        => X_Error_Msg_Data);
	-- Bug: 4537865
	l_Rec_Version_Number := l_new_Rec_Version_Number;
	-- Bug: 4537865

	End If;

        Pa_Debug.G_Stage := 'Leaving Copy_Frozen_Rbs_Version() procedure.';
        Pa_Debug.TrackPath('STRIP','Copy_Frozen_Rbs_Version');

Exception
	When l_Record_Locked Then
		X_Error_Msg_Data := 'PA_RECORD_ALREADY_UPDATED';

	When Others Then
		Raise;

End Copy_Frozen_Rbs_Version;


Procedure Copy_Frozen_Rbs_Elements(
	P_Rbs_Version_From_Id IN         Number,
	P_Rbs_Version_To_Id   IN         Number,
	X_Error_Msg_Data      OUT NOCOPY Varchar2)

Is

        --Bug 3592145
        l_new_element_name_id Number;
        l_dummy_error_status  Varchar2(10);
        l_Error               Exception;

Begin

        Pa_Debug.G_Stage := 'Entering Copy_Frozen_Rbs_Elements() procedure.';
        Pa_Debug.TrackPath('ADD','Copy_Frozen_Rbs_Elements');

	Pa_Debug.G_Stage := 'Delete all records from Pa_Rbs_Elements_Temp.';
	Begin

		Delete
		From Pa_Rbs_Elements_Temp;

	Exception
		When No_Data_Found Then
			null;

	End;

	Pa_Debug.G_Stage := 'Insert into Pa_Rbs_Elements_Temp that are to be copied.';
        /*******************************************************
         * Bug - 3591534
         * Desc - while inserting into Pa_Rbs_Elements_Temp elements that
         *        are to be copied, we should only select elements where
         *        user_created flag = 'Y'.
         ******************************************************/
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
		Rbs_Version_Id = P_Rbs_Version_From_Id
         and    user_created_flag = 'Y' );

	Pa_Debug.G_Stage := 'Update Pa_Rbs_Elements_Temp records with the correct parent element id.';
	Update Pa_Rbs_Elements_Temp Tmp1
	Set New_Parent_Element_Id =
        	(Select
			New_Element_Id
                 From
			Pa_Rbs_Elements_Temp Tmp2
                 Where
			Tmp1.Old_Parent_Element_Id = Tmp2.Old_Element_Id);

	Pa_Debug.G_Stage := 'Insert into Pa_Rbs_Elements new records.';

               /*Bug 4377886 : Included explicitly the column names in the INSERT statement
                to remove the GSCC Warning File.Sql.33 */
	Insert Into Pa_Rbs_Elements
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
                RECORD_VERSION_NUMBER
        )
        --For perf bug 4045542
        Select /*+ ORDERED */
		Tmp.New_Element_Id,
		Rbs_Elements.Rbs_Element_Name_Id,
		P_Rbs_Version_To_Id,
		Rbs_Elements.Outline_Number,
		Rbs_Elements.Order_Number,
		Rbs_Elements.Resource_Type_Id,
		Rbs_Elements.Resource_Source_Id,
		Rbs_Elements.Person_Id,
		Rbs_Elements.Job_Id,
		Rbs_Elements.Organization_Id,
		Rbs_Elements.Expenditure_Type_Id,
		Rbs_Elements.Event_Type_Id,
		Rbs_Elements.Expenditure_Category_Id,
		Rbs_Elements.Revenue_Category_Id,
		Rbs_Elements.Inventory_Item_Id,
		Rbs_Elements.Item_Category_Id,
		Rbs_Elements.Bom_Labor_Id,
		Rbs_Elements.Bom_Equipment_Id,
		Rbs_Elements.Non_Labor_Resource_Id,
		Rbs_Elements.Role_Id,
		Rbs_Elements.Person_Type_Id,
		Rbs_Elements.Resource_Class_Id,
		Rbs_Elements.Supplier_Id,
		Rbs_Elements.Rule_Flag,
		Tmp.New_Parent_Element_Id,
                Rbs_Elements.Rbs_Level,
                Rbs_Elements.Element_Identifier,
		Rbs_Elements.User_Defined_Custom1_Id,
		Rbs_Elements.User_Defined_Custom2_Id,
		Rbs_Elements.User_Defined_Custom3_Id,
		Rbs_Elements.User_Defined_Custom4_Id,
		Rbs_Elements.User_Defined_Custom5_Id,
		Rbs_Elements.User_Created_Flag,
		Pa_Rbs_Versions_Pvt.G_Last_Update_Date,
		Pa_Rbs_Versions_Pvt.G_Last_Updated_By,
		Pa_Rbs_Versions_Pvt.G_Creation_Date,
		Pa_Rbs_Versions_Pvt.G_Created_By,
		Pa_Rbs_Versions_Pvt.G_Last_Update_Login,
		1
	From
        	Pa_Rbs_Elements_Temp Tmp,
                Pa_Rbs_Elements Rbs_Elements
	Where
		Tmp.Old_Element_Id = Rbs_Elements.Rbs_Element_Id;

        --Bug 3592145
        --Deriving the element_name_id
        Pa_Debug.G_Stage := 'Now getting a new rbs_element_name_id for the root element since it is based on rbs_version_id.';
        Pa_Rbs_Utils.Populate_RBS_Element_Name (
               P_Resource_Source_Id  => P_Rbs_Version_To_Id,
               P_Resource_Type_Id    => -1,
               X_Rbs_Element_Name_Id => l_new_element_name_id,
               X_Return_Status       => l_Dummy_Error_Status);

        Pa_Debug.G_Stage := 'Check Pa_Rbs_Utils.Populate_RBS_Element_Name() returns error or not for getting ' ||
                            'root element element_name_id.';
        If l_Dummy_Error_Status = Fnd_Api.G_Ret_Sts_Success Then

               Pa_Debug.G_Stage := 'Updating the root element rbs record with the new element_name_id.';
               Update Pa_Rbs_Elements
               Set Rbs_Element_Name_Id = l_New_Element_Name_Id,
                   Resource_Source_Id  = P_Rbs_Version_To_Id
               Where Rbs_Version_Id = P_Rbs_Version_To_Id
               And Resource_Type_Id = -1
               And Rbs_Level = 1;

        Else

               Raise l_Error;

        End If;

        Pa_Debug.G_Stage := 'Leaving Copy_Frozen_Rbs_Elements() procedure.';
        Pa_Debug.TrackPath('STRIP','Copy_Frozen_Rbs_Elements');

Exception
	When Others Then
		Raise;

End Copy_Frozen_Rbs_Elements;


/***************************************************
 * Procedure : Set_Reporting_Flag
 * Description : This procedure is used to set the
 *               current reporting flag for the version
 *               passed in as 'Y'. All other versions
 *               belonging to the same header will then
 *               have the current reporting flag set to
 *               Null.
 ***************************************************/
Procedure Set_Reporting_Flag(
        p_rbs_version_id   IN  Number,
        x_return_status    OUT NOCOPY Varchar2)
Is

  l_rbs_header_id Number;

Begin


   x_Return_Status := Fnd_Api.G_Ret_Sts_Success;
   /*******************************************************
    * First select the header_id that corresponds to this version.
    * If multiple or no rows found then just set the x_return_status
    * as Unexpected error and return.
    ******************************************************/

   Begin

      Select
            Rbs_Header_Id
      Into
            l_Rbs_Header_Id
      From
            Pa_Rbs_Versions_B
      Where
            Rbs_Version_Id = P_Rbs_Version_Id;

   Exception
      When Others Then
            x_Return_Status := Fnd_Api.G_Ret_Sts_UnExp_Error;
            Return;
   End;

   Update
         Pa_Rbs_Versions_B
   Set
         Current_Reporting_Flag = Null
   Where
         Rbs_Header_Id = l_Rbs_Header_Id;

   Update
         Pa_Rbs_Versions_B
   Set
         Current_Reporting_Flag = 'Y'
   Where
         Rbs_Header_Id = l_Rbs_Header_Id
   And   Rbs_Version_Id = P_Rbs_Version_Id;

Exception
   When Others Then
       X_Return_Status := Fnd_Api.G_Ret_Sts_UnExp_Error;
       Return;

End Set_Reporting_Flag;


END Pa_Rbs_Versions_Pvt;

/
