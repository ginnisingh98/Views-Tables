--------------------------------------------------------
--  DDL for Package Body PA_RBS_HEADER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RBS_HEADER_PUB" as
--$Header: PARBSHPB.pls 120.1 2006/01/04 17:33:47 appldev noship $

/*==============================================================================
This api Updates RBS Header. It also updates the working version of this RBS
=============================================================================*/

-- Procedure            : UPDATE_HEADER
-- Type                 : Public Procedure
-- Purpose              : This API will be used to update the RBS header for a particular rbs header id.
--                      : This API will be called from following page:
--                      : 1.Rbs Header Page

-- Note                 : This API will does all the business validations.
--                      :  -- If no errors are encounterd it updates the pa_rbs_headers table.
--                      :  -- The validations made are
--                      :  -- Rbs Header name should be unique
--                      :  -- Rbs From date cannot be null
--                      :  -- Rbs To date cannot be less than Rbs from date
--                      :  -- Rbs From date cannot be updated if there atleast one published version
--                      :  -- Rbs To date cannot be less than its versions
--                      :  -- If a Rbs is not having any published version then update is allowed on both header and versions for
--                      :  -- every attribute.
--                      :  -- If a Rbs has atleast one published version then update is not allowed on the versions table.
--			:  -- If a Rbs has rules as its elements then user cant check(setting it to 'Y') use_for_alloc_flag.
--			:  -- If a Rbs has alteast one freezed version and is used in allocation rule then user cant uncheck
--			:  -- Use_For_Alloc_Flag ( i.e setting it to 'N')

-- Assumptions          :

-- Parameters                     Type          Required        Description and Purpose
-- ---------------------------  ------          --------        --------------------------------------------------------
--  P_Commit                     Varchar2         No
--  P_Init_Msg_List              Varchar2         No
--  P_API_Version_Number         Varchar2         Yes
--  P_RbsHeaderId  	         NUMBER           Yes            The value will contain the Rbs Header id which is the
--								 unique identifier.
--  P_Name			 VARCHAR2	  Yes		 The name of the Rbs Header.
--  P_Description                VARCHAR2         NO             The description of the Rbs header
--  P_EffectiveFrom              DATE             YES            The start date of the RBS
--  P_EffectiveTo                DATE             NO             The end date of the Rbs.
--  P_Use_For_Alloc_Flag         VARCHAR2	  NO      	 This determine whether a Rbs can be used in allocation rule or not.
--  P_RecordVersionNumber        NUMBER           Yes            The record version number of the rbs header which is
--							         used to ensure syncronization.

Procedure Update_Header(
        P_Commit              IN         Varchar2 Default Fnd_Api.G_False,
        P_Init_Msg_List       IN         Varchar2 Default Fnd_Api.G_True,
        P_API_Version_Number  IN         Number,
	P_RbsHeaderId	      IN         Number,
	P_Name 		      IN         Varchar2,
	P_Description 	      IN         Varchar2,
	P_EffectiveFrom       IN         Date,
	P_EffectiveTo	      IN         Date,
	P_Use_For_Alloc_Flag  IN         Varchar2 Default 'N',
	P_RecordVersionNumber IN         Number,
        P_Process_Version     IN         Varchar2 Default Fnd_Api.G_True,
	X_Return_status       OUT NOCOPY Varchar2,
	X_Msg_Data 	      OUT NOCOPY Varchar2,
	X_Msg_Count 	      OUT NOCOPY Number )

IS

    -- This cursor selects the record version number for the header which needs to be updated
    Cursor c_Record_Ver_No Is
    Select
	   record_version_number
    From
	   pa_rbs_headers_b
    Where
	   rbs_header_id=p_rbsHeaderId
    For Update Of Effective_From_Date NoWait;

    RecInfo c_Record_Ver_No%RowType;

    l_Msg_Count 		Number := 0;
    l_Msg_Data 			Varchar2(2000) := Null;
    l_Data 			Varchar2(2000) := Null;
    l_Msg_Index_Out 		Number;
    l_Debug_Mode 		Varchar2(1) := Null;
    l_Return_Status 		Varchar2(1) := Null;
    l_Count 			Number;
    l_Name 			Varchar2(240) := Null;
    l_Error			Exception;
    l_UnExp_Error               Exception;
    l_Error_Raised		Varchar2(1) := Null;
    l_Effect_To_Date		Date;
    l_EffectiveFromDate		Date;
    l_Check 			Number := 0;
    l_use_for_alloc_flag        Varchar2(1);

    l_Api_Name              Varchar2(30)    := 'Update_Header';

Begin

        If P_Process_Version = 'Y' Then

             Pa_Debug.G_Path := ' ';

        End If;

        Pa_Debug.G_Stage := 'Entering Update_Header().';
        Pa_Debug.TrackPath('ADD','Update_Header');

        Pa_Debug.G_Stage := 'Check API Version compatibility by calling Fnd_Api.Compatible_API_Call() procedure.';
        If Not Fnd_Api.Compatible_API_Call (
                        Pa_Rbs_Header_Pub.G_Api_Version_Number,
                        P_Api_Version_Number,
                        l_Api_Name,
                        Pa_Rbs_Header_Pub.G_Pkg_Name) Then

                Pa_Debug.G_Stage := 'API Version compatibility failure.';
                Raise Fnd_Api.G_Exc_Unexpected_Error;

        End If;

        Pa_Debug.G_Stage := 'Check if need to initialize the error message stack.';
        If Fnd_Api.To_Boolean(nvl(P_Init_Msg_List,Fnd_Api.G_True)) Then

                Pa_Debug.G_Stage := 'Initialize the error message stack by callling Fnd_Msg_Pub.Initialize() procedure.';
                Fnd_Msg_Pub.Initialize;

        End If;

	X_Return_Status := Fnd_Api.G_Ret_Sts_Success;
        X_Msg_Count := 0;

	/* validation: Rbs name cannot be null*/
        Pa_Debug.G_Stage := 'Check if the paramter p_name is null.';
	If P_Name Is Null Then

                Pa_Debug.G_Stage := 'Rbs Name is null.  Add message to error stage.';
                Pa_Utils.Add_MessagE(
			P_App_Short_Name => 'PA',
                	P_Msg_Name       => 'PA_RBS_NAME_NULL');

		Raise l_Error;

	End If;

	/* validation: Rbs Effective From date cannot be null*/
        Pa_Debug.G_Stage := 'Check if the Effective From Date for the RBS Header is null.';
	If P_EffectiveFrom Is Null Then

                Pa_Debug.G_Stage := 'The Effective From Date for the RBS Header is null.';
                Pa_Utils.Add_Message(
			P_App_Short_Name => 'PA',
                	P_Msg_Name       => 'PA_RBS_FROM_NULL',
			P_Token1         => 'RBSNAME',
			P_Value1         => P_Name);

		l_Error_Raised := 'Y';

	End If;

	/* validation: Rbs effective From should always be less than effective to date */
        Pa_Debug.G_Stage := 'Check if the RBS Header Effective From Date is > Effective To Date.';
	If P_EffectiveFrom > P_EffectiveTo Then

                Pa_Debug.G_Stage := 'The Rbs Header Effective From Date is > Effective To Date.';
                Pa_Utils.Add_Message(
			P_App_Short_Name => 'PA',
                	P_Msg_Name       => 'PA_RBS_TO_LESS_FROM',
			P_Token1         => 'RBSNAME',
			P_value1         => P_Name);

		l_Error_Raised := 'Y';

	End If;

	/* to check the uniqueness of the RBS name*/
        Pa_Debug.G_Stage := 'Get the Rbs Name using the rbs header id.';
	Select
		Name
	Into
		l_Name
	From
		Pa_Rbs_Headers_TL
	Where
		Rbs_Header_Id = P_RbsHeaderId
        And     language = USERENV('LANG');

        Pa_Debug.G_Stage := 'Check if the p_name passed in matches the name already stored in the db for the rbs header id.';
	If l_Name <> P_Name Then

                Pa_Debug.G_Stage := 'Get the number of rbs headers that use the name passed in p_name parameter.';
		Select
			Count(*)
		Into
			l_Count
		From
                        Pa_Rbs_Headers_TL
		Where
                        Name = P_Name
                And     language = USERENV('LANG');

                Pa_Debug.G_Stage := 'Check if the number of rbs headers using the name.';
		If l_Count <> 0 Then

                        Pa_Debug.G_Stage := 'The p_name parameter for a new rbs name is already used.  Add message to message stack.';
                	Pa_Utils.Add_Message(
				P_App_Short_Name => 'PA',
                		P_Msg_Name       => 'PA_RBS_NOT_UNIQUE',
				P_Token1         => 'RBSNAME',
				P_Value1         => P_Name);

			l_Error_Raised := 'Y';

		End If;

	End If;

	/* check for locking */
        Pa_Debug.G_Stage := 'Use cursor to lock the header record for update.';
	Open c_Record_Ver_No;
	Fetch c_Record_Ver_No Into RecInfo;

        Pa_Debug.G_Stage := 'Check if header record to lock.';
	If c_Record_Ver_No%NotFound Then

		Close c_Record_Ver_No;
	End If;

	Close c_Record_Ver_No;

        Pa_Debug.G_Stage := 'Check if the record version number retrieved matches the parameter value passed in.';
	If RecInfo.Record_Version_Number = P_RecordVersionNumber Then

                Pa_Debug.G_Stage := 'The record version number matches up.';
		Null;

	Else

                Pa_Debug.G_Stage := 'The record version number does not match up.  The record has already been update ' ||
                                    'other others.  Add message to error stack.';
                Pa_Utils.Add_Message(
			P_App_Short_Name => 'PA',
                	P_Msg_Name       => 'PA_RBS_HEADER_CHANGED');

		l_Error_Raised := 'Y';

	End If;

        Pa_Debug.G_Stage := 'Check if any error were found.';
	If l_Error_Raised = 'Y' Then

                Pa_Debug.G_Stage := 'We have validation error so raising.';
		Raise l_Error;

	End If;


	--Check if Rbs has rules as its elements when use_for_alloc_flag is checked by the user.

	SELECT use_for_Alloc_Flag
	INTO l_Use_For_Alloc_Flag
	FROM pa_rbs_headers_b
	WHERE rbs_header_id=P_RbsHeaderId;


	IF(l_use_for_alloc_flag='N' and p_use_for_alloc_flag='Y') Then

		IF PA_RBS_HEADER_PVT.Validate_Rbs_For_Allocations(p_rbs_id=> P_RbsHeaderId)='Y'
		THEN
			Pa_Utils.Add_Message(
                        P_App_Short_Name => 'PA',
                        P_Msg_Name       => 'PA_RBS_HAS_RULES');

                        Pa_Debug.G_Stage := 'We have rules as elements so raising error.';
                        Raise l_Error;

                End If;
        End IF;

        Pa_Debug.G_Stage := 'See if there is a frozen rbs version for this header.';
	Begin

		l_Check := 0;

		--Checks if there is at least one published versions for the rbs.
		--If yes then l_check has not null value
		--Otherwise it is set to null

		Select
			Max(Rbs_Header_Id),
			Max(Version_End_Date)
		Into
			l_Check,
			l_Effect_To_Date
		From
			Pa_Rbs_Versions_B
		Where
			Rbs_Header_Id = P_RbsHeaderId
		And 	Status_Code <> 'WORKING';

	Exception
		When Others Then
			l_Check := 0;

	End;

        Pa_Debug.G_Stage := 'Check if a version record was found.';
	If l_Check Is Null Or l_Check = 0 Then


		Pa_Debug.G_Stage := 'No frozen version record was found.  Update the header information by calling ' ||
                                    'the Pa_Rbs_Header_Pvt.Update_Header() procedure.';

		--When user checks use_for_alloc_flag there is no need to check its usage in allocation rule.
		--The RBS has no freezed version and hence cant be used in allocation rule.

		Pa_Rbs_Header_Pvt.Update_Header(
			P_RbsHeaderId   => P_RbsHeaderId,
			P_Name          => P_Name,
			P_Description   => P_Description,
			P_EffectiveFrom => P_EFfectiveFrom,
			P_EffectiveTo   => P_EffectiveTo,
			P_Use_For_Alloc_Flag => P_Use_For_Alloc_Flag,
			X_Return_Status => X_Return_Status,
			X_Msg_Data      => X_Msg_Data,
			X_Msg_Count     => X_Msg_Count);

                Pa_Debug.G_Stage := 'Check if return status from call to Pa_Rbs_Header_Pvt.Update_Header() procedure is U.';
                If X_Return_Status = 'U' Then

                        Pa_Debug.G_Stage := 'Call to Pa_Rbs_Header_Pvt.Update_Header() procedure returned Unexpected error.  Raise.';
                        Raise l_UnExp_Error;

                End If;

                Pa_Debug.G_Stage := 'No frozen version record was found.  Check if allow to update the version record in this module.';
                If P_Process_Version = Fnd_Api.G_True Then

		        Pa_Debug.G_Stage := 'No frozen version record was found.  Update the working version record for ' ||
                                            'the Rbs header by calling the Pa_Rbs_Header_Pvt.Update_Versions procedure.';
		        Pa_Rbs_Header_Pvt.Update_Versions(
			        P_RbsHeaderId   => P_RbsHeaderId,
			        P_Name          => P_Name,
			        P_EffectiveFrom => P_EffectiveFrom,
			        X_Return_Status => X_Return_Status,
			        X_Msg_Data      => X_Msg_Data,
			        X_Msg_Count     => X_Msg_Count);

                        Pa_Debug.G_Stage := 'Check if return status from call to Pa_Rbs_Header_Pvt.Update_Versions() procedure is U.';
                        If X_Return_Status = 'U' Then

                                Pa_Debug.G_Stage := 'Call to Pa_Rbs_Header_Pvt.Update_Versions() procedure returned ' ||
                                                    'Unexpected error.  Raise.';
                                Raise l_UnExp_Error;

                        End If;

                End If;

	Else

		-- name can be updated but should not be reflected in versions. Effective to can be updated but validated such that
		-- it cannot be less than effective to date of its versions. effective from cannot be updated
		-- Also if use_for_alloc_flag is unchecked test for its usage in allocation rules. If yes raise appropriate error.

		/* validation: effective from cannot be updated*/
                Pa_Debug.G_Stage := 'Found frozen versions for the rbs.  Get the effective from date in the header.';
		Select
			Effective_From_Date
		Into
			l_EffectiveFromDate
		From
			Pa_Rbs_Headers_B
		Where
			Rbs_Header_Id = P_RbsHeaderId;

                Pa_Debug.G_Stage := 'Check if trying to change the effective from date of the header.';
		If l_EffectiveFromDate <> P_EffectiveFrom Then

                        Pa_Debug.G_Stage := 'Trying to change the effective from date of the header when have frozen ' ||
                                            'rbs versions.  Add message to error stack.';
                	Pa_Utils.Add_Message(
				P_App_Short_Name => 'PA',
                		P_Msg_Name       => 'PA_RBS_FROM_CHANGED',
				P_Token1         => 'RBSNAME',
				P_Value1         => P_Name);

       			l_Error_Raised := 'Y';

		End If;

                -- Per bug 3602821 we don't need to check the header end_date to the version end_dates
		-- VALIDATION: Effective to if being updated to a not null value for the rbs header must not be
                --             less than effective to of rbs frozen versions*/
                -- Pa_Debug.G_Stage := 'Check if the effective_to_date is being changed.  Check If not null then if < max ' ||
                --                     'version_end_date of frozen versions.';
		-- If P_EffectiveTo Is Not Null And P_EffectiveTo < l_Effect_To_Date Then

                --         Pa_Debug.G_Stage := 'Trying to change effective to date of header and it is < that ' ||
                --                             'max version_end_date of frozen versions.  Add msg to error stack.';
                --         Pa_Utils.Add_MessagE(
                --                P_App_Short_Name => 'PA',
              	--                P_Msg_Name       => 'PA_RBS_TO_LESS_THAN_VERSIONS',
		--                P_Token1         => 'RBSNAME',
		--                P_Value1         => P_Name);

       		--         l_Error_Raised := 'Y';

		-- End If;

                Pa_Debug.G_Stage := 'Check 2 if validation errors were found.';
		If l_Error_Raised ='Y' Then

                        Pa_Debug.G_Stage := 'Validation errors were found - 2.  Raise l_Error.';
			Raise l_Error;

		End If;

		        --Logic for Use For alloc Flag

		Pa_Debug.G_Stage := 'Check if use_for_alloc_flag is changed from Y to N. If so then check for its ' ||
					'usage in allocation rules.';


        	IF(l_use_for_alloc_flag='Y' and p_use_for_alloc_flag='N') Then
                	--Check if Rbs is used for allocation
                	IF PA_ALLOC_UTILS.IS_RBS_IN_RULES(p_rbs_id=> P_RbsHeaderId) = 'Y'
                	THEN
				Pa_Debug.G_Stage := 'Trying to change use_for_alloc_flag to N for Rbs used in allocation rule' ||
							'Add msg to error stack.';

                        	Pa_Utils.Add_Message(
                        	    P_App_Short_Name => 'PA',
                        	    P_Msg_Name       => 'PA_RBS_USED_IN_ALLOC',
				    P_Token1         => 'RBSNAME',
				    P_Value1         =>  P_Name);

                        	Pa_Debug.G_Stage := 'We have used in allocation error so raising.';
                        	Raise l_Error;

                	End If;
        	End IF;

		Pa_Debug.G_Stage := 'Check 3 if allocation usage error is found.';
                If l_Error_Raised ='Y' Then

                        Pa_Debug.G_Stage := 'Allcation error found - 3.  Raise l_Error.';
                        Raise l_Error;

                End If;

		--Updates the header information for the Rbs
                Pa_Debug.G_Stage := 'Update the rbs header record - 2 by calling the Pa_Rbs_Header_Pvt.Update_Header() procedure.';
		Pa_Rbs_Header_Pvt.Update_Header(
			p_rbsHeaderId,
			p_name,
			p_description,
			p_effectiveFrom,
			p_effectiveTo,
			p_use_for_alloc_flag,
			x_return_status,
			x_msg_data,
			x_msg_count);

                Pa_Debug.G_Stage := 'Check if return status from call to Pa_Rbs_Header_Pvt.Update_Header() procedure is U.';
                If X_Return_Status = 'U' Then

                        Pa_Debug.G_Stage := 'Call to Pa_Rbs_Header_Pvt.Update_Header() procedure returned Unexpected error.  Raise.';
                        Raise l_UnExp_Error;

                End If;

	End If;

        Pa_Debug.G_Stage := 'Check if need to commit data.';
        If Fnd_Api.To_Boolean(Nvl(P_Commit,Fnd_Api.G_False)) Then

                Pa_Debug.G_Stage := 'Commit inserts to db.';
                Commit;

        End If;

        Pa_Debug.G_Stage := 'Leaving Update_Header() procedure.';
        Pa_Debug.TrackPath('STRIP','Update_Header');

Exception

	When l_Error Then
                X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
                l_Msg_Count := Fnd_Msg_Pub.Count_Msg;
                If l_msg_count = 1 Then
                        Pa_Interface_Utils_Pub.Get_Messages(
                                p_encoded       => Fnd_Api.G_True,
                                p_msg_index     => 1,
                                p_msg_count     => l_msg_count,
                                p_msg_data      => l_msg_data,
                                p_data          => l_data,
                                p_msg_index_out => l_msg_index_out);

                        x_msg_data := l_data;
                        x_msg_count := l_msg_count;
                Else
                        x_msg_count := l_msg_count;
                End If;

        When l_UnExp_Error Then
                x_return_status := 'U';
                x_msg_data := Pa_Rbs_Header_Pub.G_Pkg_Name || ':::' || Pa_Debug.G_Path || '::' || Pa_Debug.G_Stage || ':' || X_Msg_Data;
                x_msg_count := 1;
                Rollback;

	When Others Then
		x_return_status := 'U';
                x_msg_data := Pa_Rbs_Header_Pub.G_Pkg_Name || ':::' || Pa_Debug.G_Path || '::' || Pa_Debug.G_Stage || ':' || SqlErrm;
                x_msg_count := 1;
                Rollback;

END Update_Header;


/*==========================================================================
   This api creates RBS Header. It also creates a working version of this RBS
 ============================================================================*/



-- Procedure            : INSERT_HEADER
-- Type                 : Public Procedure
-- Purpose              : This API will be used to create new RBS headers.
--                      : This API will be called from following page:
--                      : 1.Rbs Header Page

-- Note                 : This API will does all the business validations.
--                      :  -- If no errors are encounterd it inserts the Rbs header into pa_rbs_headers_b and pa_rbs_headers_tl table.
--                      :  -- The validations made are
--                      :  -- Rbs Header name should be unique
--                      :  -- Rbs Header name should not be null
--                      :  -- Rbs From date cannot be null
--                      :  -- Rbs To date cannot be less than Rbs from date
-- 			:  -- Use_For_Alloc_Flag is set to either Y or N and no check is made coz this RBS when created will
--			:  -- have no freezed version to associate to allocation rule and will have no elements to check for rules
--			:  -- as its elements.

-- Assumptions          :

-- Parameters                     Type          Required        Description and Purpose
-- ---------------------------  ------          --------        --------------------------------------------------------
--  P_Commit                     Varchar2         No
--  P_Init_Msg_List              Varchar2         No
--  P_API_Version_Number         Varchar2         Yes
--  p_name		         NUMBER           Yes            The name of the Rbs Header id which is unique.
--  p_description                VARCHAR2         NO             The description of the Rbs header
--  p_effectiveFrom              DATE             YES            The start date of the RBS
--  p_effectiveTo                DATE             NO             The end date of the Rbs.
--  P_Use_For_alloc_Flag         VARCHAR2         NO  		 The field which determines Rbs usage in allocation rule




PROCEDURE Insert_Header(
        P_Commit              IN         Varchar2 Default Fnd_Api.G_False,
        P_Init_Msg_List       IN         Varchar2 Default Fnd_Api.G_True,
        P_API_Version_Number  IN         Number,
	P_Name 		      IN         Varchar2,
	P_Description 	      IN         Varchar2,
	P_EffectiveFrom       IN         Date,
	P_EffectiveTo         IN         Date,
	P_Use_For_Alloc_Flag  IN         Varchar2 Default 'N',
        X_Rbs_Header_Id       OUT NOCOPY Number,
        X_Rbs_Version_Id      OUT NOCOPY Number,
        X_Rbs_Element_Id      OUT NOCOPY Number,
	X_Return_Status       OUT NOCOPY Varchar2,
	X_Msg_Data 	      OUT NOCOPY Varchar2,
	X_Msg_Count 	      OUT NOCOPY Number )

Is

	l_Rbs_Header_Id	 	Number(15) := Null;
	l_Rbs_Version_Id        Number(15) := Null;
	l_Rbs_Element_Id        Number(15) := Null;

	l_Api_Name              Varchar2(30)  := 'Insert_Header';

	l_msg_count 		Number := 0;
	l_msg_data 		Varchar2(2000) := Null;
	l_data 			Varchar2(2000) := Null;
	l_msg_index_out 	Number;
	l_return_status 	Varchar2(1) := Null;
	l_count 		Number;
	l_error_raised 		Varchar2(1) := Null;
	l_Error 		Exception;
        l_UnExp_Error           Exception;

BEGIN

        Pa_Debug.G_Stage := 'Entering Insert_Header().';
        Pa_Debug.TrackPath('ADD','Insert_Header');

        Pa_Debug.G_Stage := 'Check API Version compatibility by calling Fnd_Api.Compatible_API_Call() procedure.';
        If Not Fnd_Api.Compatible_API_Call (
                        Pa_Rbs_Elements_Pub.G_Api_Version_Number,
                        P_Api_Version_Number,
                        l_Api_Name,
                        Pa_Rbs_Elements_Pub.G_Pkg_Name) Then

                Pa_Debug.G_Stage := 'API Version compatibility failure.';
                Raise Fnd_Api.G_Exc_Unexpected_Error;

        End If;

        Pa_Debug.G_Stage := 'Check if need to initialize the message error stack.';
        If Fnd_Api.To_Boolean(nvl(P_Init_Msg_List,Fnd_Api.G_True)) Then

                Pa_Debug.G_Stage := 'Initilize the message error stack by calling the Fnd_Msg_Pub.Initialize() procedure.';
                Fnd_Msg_Pub.Initialize;

        End If;

	X_Return_Status := Fnd_Api.G_Ret_Sts_Success;
        X_Msg_Count := 0;

	/* validation: Rbs name cannot be null */
        Pa_Debug.G_Stage := 'Check if the paramter p_name is null.';
	If P_Name Is Null Then

                Pa_Debug.G_Stage := 'Rbs Name is null.  Add message to error stage.';
                Pa_Utils.Add_Message(
			P_App_Short_Name => 'PA',
			P_Msg_Name       => 'PA_RBS_NAME_NULL');

		Raise l_Error;

	End If;

        /* validation:Rbs effective From date cannot be null */
        Pa_Debug.G_Stage := 'Check if the effective from date is null.';
        If P_EffectiveFrom Is Null Then

                Pa_Debug.G_Stage := 'The Effective from date is null.  Add message to error stack.';
                Pa_Utils.Add_Message(
                        P_App_Short_Name => 'PA',
                        P_Msg_Name       => 'PA_RBS_FROM_NULL',
                        P_Token1         => 'RBSNAME',
                        P_Value1         => P_Name);

                l_Error_Raised := 'Y';

        Else

	        /* validation: Rbs effective From should always be less than Rbs effective to */
                Pa_Debug.G_Stage := 'Check if the rbs header effective from date > effective to date.';
	        If P_EffectiveFrom > Nvl(P_EffectiveTo,P_EffectiveFrom) Then

                        Pa_Debug.G_Stage := 'The rbs header effective from date > effective to date.  Add message to error stack.';
                        Pa_Utils.Add_Message(
			        P_App_Short_Name => 'PA',
                	        P_Msg_Name       => 'PA_RBS_TO_LESS_FROM',
			        P_Token1         => 'RBSNAME',
			        P_Value1         => P_Name);

                        l_Error_Raised := 'Y';

	        End If;

        End If;

	/* validation: Rbs name should be unique*/
        Pa_Debug.G_Stage := 'Get a count of the number of rbs headers using the p_name parameter passed in.';
	Select
		Count(*)
	Into
		l_Count
	From
		Pa_Rbs_Headers_TL
	Where
		Name = P_Name
        And     language = USERENV('LANG');

        Pa_Debug.G_Stage := 'Check if the count of rbs headers using the p_name parameter is <> 0.';
	IF l_count <> 0 THEN

                Pa_Debug.G_Stage := 'When create rbs the header name must be unique.  Add message to error stack.';
                Pa_Utils.Add_Message(
			P_App_Short_Name => 'PA',
                	P_Msg_Name       => 'PA_RBS_NOT_UNIQUE',
			P_Token1         => 'RBSNAME',
			P_Value1         => P_Name);

                l_Error_Raised := 'Y';

	End If;

        Pa_Debug.G_Stage := 'Check if any validation error occured.';
	If l_Error_Raised = 'Y' Then

                Pa_Debug.G_Stage := 'Validation errors occured.  Raise l_Error.';
		Raise l_Error;

	End If;

	--Inserts into pa_rbs_header table.
        Pa_Debug.G_Stage := 'Insert header record by calling the Pa_Rbs_Header_Pvt.Insert_Header() procedure.';
	Pa_Rbs_Header_Pvt.Insert_Header(
		P_Name               => P_Name,
		P_Description        => P_Description,
		P_EffectiveFrom      => P_EffectiveFrom,
		P_EffectiveTo        => P_EffectiveTo,
		P_Use_For_Alloc_Flag => P_Use_For_Alloc_Flag,
		X_RbsHeaderId        => X_Rbs_Header_Id,
		X_Return_Status      => X_Return_Status,
		X_Msg_Data           => X_Msg_Data,
		X_Msg_Count          => X_Msg_Count);

        If X_Return_Status ='U' Then

               Pa_Debug.G_Stage := 'Calling to Pa_Rbs_Header_Pvt.Insert_Header() procedure returned error.  Raise.';
               Raise l_UnExp_Error;

        End If;

        Pa_Debug.G_Stage := 'Insert the version record by calling the Pa_Rbs_Header_Pvt.Insert_Versions() procedure.';
	Pa_Rbs_Header_Pvt.Insert_Versions(
		P_RbsHeaderId    => X_Rbs_Header_Id,
		P_Name           => P_Name,
		P_Description    => P_Description,
		P_EffectiveFrom  => P_EffectiveFrom,
		X_Rbs_Version_Id => X_Rbs_Version_Id,
		X_Return_Status  => X_Return_Status,
		X_Msg_Data       => X_Msg_Data,
		X_Msg_Count      => X_Msg_Count );

        If X_Return_Status ='U' Then

               Pa_Debug.G_Stage := 'Calling to Pa_Rbs_Header_Pvt.Insert_Versions() procedure returned error.  Raise.';
               Raise l_UnExp_Error;

        End If;

        Pa_Debug.G_Stage := 'Insert the root element node for the rbs by callling the Pa_Rbs_Header_Pvt.Insert_Structure_Element() procedure.';
	Pa_Rbs_Header_Pvt.Insert_Structure_Element(
		P_Rbs_Version_Id => X_Rbs_Version_Id,
		X_Rbs_Element_Id => X_Rbs_Element_Id,
		X_Return_Status  => X_Return_Status,
		X_Error_Msg_Data => X_Msg_Data,
		X_Msg_Count      => X_Msg_Count);

        If X_Return_Status ='U' Then

               Pa_Debug.G_Stage := 'Calling to Pa_Rbs_Header_Pvt.Insert_Structure_Element() procedure returned error.  Raise.';
               Raise l_UnExp_Error;

        End If;

        Pa_Debug.G_Stage := 'Check if need to commit data.';
        If Fnd_Api.To_Boolean(Nvl(P_Commit,Fnd_Api.G_False)) Then

                Pa_Debug.G_Stage := 'Commit inserts to db.';
                Commit;

       End If;

        Pa_Debug.G_Stage := 'Leaving Insert_Header() procedure.';
        Pa_Debug.TrackPath('STRIP','Insert_Header');

Exception
        When l_Error Then
                X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
                l_Msg_Count := Fnd_Msg_Pub.Count_Msg;
                If l_msg_count = 1 Then
                        Pa_Interface_Utils_Pub.Get_Messages(
                                p_encoded       => Fnd_Api.G_True,
                                p_msg_index     => 1,
                                p_msg_count     => l_msg_count,
                                p_msg_data      => l_msg_data,
                                p_data          => l_data,
                                p_msg_index_out => l_msg_index_out);

                        x_msg_data := l_data;
                        x_msg_count := l_msg_count;
                Else
                        x_msg_count := l_msg_count;
                End If;

        When l_UnExp_Error Then
                X_Return_Status := 'U';
                X_Msg_Data := Pa_Rbs_Header_Pub.G_Pkg_Name || ':::' || Pa_Debug.G_Path || '::' || Pa_Debug.G_Stage || ':' || X_Msg_Data;
                X_Msg_Count := 1;
                Rollback;

        When Others Then
                X_Return_Status := 'U';
                X_Msg_Data := Pa_Rbs_Header_Pub.G_Pkg_Name || ':::' || Pa_Debug.G_Path || '::' || Pa_Debug.G_Stage || ':' || SqlErrm;
                X_Msg_Count := 1;
                Rollback;

END Insert_Header;

END Pa_Rbs_Header_Pub;

/
