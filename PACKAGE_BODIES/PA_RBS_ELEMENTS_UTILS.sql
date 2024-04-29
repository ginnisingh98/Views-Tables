--------------------------------------------------------
--  DDL for Package Body PA_RBS_ELEMENTS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RBS_ELEMENTS_UTILS" AS
/* $Header: PARELEUB.pls 120.0 2005/05/30 02:23:48 appldev noship $*/

-- When checking that parent element exists for element you are working to udpate/add
-- Returns 'Y' for exists and 'N' for not exists
Function RbsElementExists(
	P_Element_Id IN Number) Return Varchar2

Is

	l_dummy Varchar2(1) := 'Y';

Begin

        Select
                'Y'
	Into
		l_dummy
        From
                Pa_Rbs_Elements
        Where
                Rbs_Element_Id = P_Element_Id;


        Return 'Y';

Exception
        When No_Data_Found Then
                Return 'N';
        When Others Then
                Raise;

End RbsElementExists;

Function GetRbsElementNameId(
	P_Resource_Type_Id IN Number,
	P_Resource_Source_Id IN Number) Return Number

Is

	l_Rbs_Element_Name_Id Number(15) := Null;

Begin

	Select
		Rbs_Element_Name_Id
	Into
		l_Rbs_Element_Name_Id
	From
		Pa_Rbs_Element_Names_B
	Where
		Resource_Type_id = P_Resource_Type_Id
	And	Resource_Source_Id = P_Resource_Source_Id;

	Return l_Rbs_Element_Name_Id;

Exception
	When No_Data_Found Then
		Return Null;

End GetRbsElementNameId;

Procedure GetResSourceId(
	P_Resource_Type_Id     IN         Number,
        P_Resource_Source_Code IN         Varchar2,
        X_Resource_Source_Id   OUT NOCOPY Number)

Is

	l_res_type_code  Varchar2(30) := Null;
	l_Dummy_Msg_Data Varchar2(30) := Null;
	l_Dummy_Status   Varchar2(1)  := Null;

Begin

	-- Make sure the type is in user-defined, named_role, revenue_cat
	l_Res_Type_Code := Pa_Rbs_Elements_Utils.GetResTypeCode(P_Resource_Type_Id);

	If l_Res_Type_Code is Null Then

		Raise No_Data_Found;

	End If;

	--Changes for Bug 3780201: Added PERSON_TYPE in the If check.
	If l_res_type_code in ('USER_DEFINED','REVENUE_CATEGORY','PERSON_TYPE') Then

		-- A procedure is provided which will create records for these
                -- resources types and if needed create a record first.
		If P_Resource_Source_Code is Null then

                  Raise No_Data_Found;

		Else

                  Pa_Rbs_Mapping.Create_Res_Type_Numeric_Id(
                        P_Resource_Name    => P_Resource_Source_Code,
                        P_Resource_Type_Id => P_Resource_Type_Id,
                        X_Resource_Id      => X_Resource_Source_Id,
                        X_Return_Status    => l_Dummy_Status,
                        X_Msg_Data         => l_Dummy_Msg_Data );

                  If X_Resource_Source_Id is Null Then
                           Raise No_Data_Found;
                  End If;
		End If;

	End If;

Exception
	When Others Then
		Raise;

End GetResSourceId;

Function GetResTypeCode(
        P_Res_Type_Id IN Number) Return Varchar2

Is

	l_Res_Type_Code Varchar2(30) := Null;

Begin


	Select
		Res_Type_Code
	Into
		l_Res_Type_Code
	From
		Pa_Res_Types_B
	Where
		Res_Type_Id = P_Res_Type_Id;

	Return l_Res_Type_Code;

Exception
	When No_Data_Found Then
		Return Null;
	When Others Then
		Raise;

End GetResTypeCode;

END Pa_Rbs_Elements_Utils;

/
