--------------------------------------------------------
--  DDL for Package Body PA_RBS_HEADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RBS_HEADER_PVT" As
--$Header: PARBSHVB.pls 120.1 2005/06/15 12:55:49 ramurthy noship $

/*==========================================================================
   This api creates RBS Header. It also creates a working version of this RBS
 ============================================================================*/

-- Procedure            : INSERT_HEADER
-- Type                 : Private Procedure
-- Purpose              : This API will be used to create new RBS headers.
--                      : This API will be called from following package:
--                      : 1.PA_RBS_HEADER_PUB package,Insert_Header procedure

-- Note                 : This API will make a call to PA_RBS_HEADER_PKG.Insert_Row procedure which
--                      : inserts a record into PA_RBS_HEADERS_B and PA_RBS_HEADERS_TL table.

-- Assumptions          :

-- Parameters                     Type          Required        Description and Purpose
-- ---------------------------  ------          --------        --------------------------------------------------------
--  p_name                       VARCHAR2         Yes            The value contain the name of the Rbs header
--  p_description                VARCHAR2         NO             The description of the Rbs header
--  p_effectiveFrom              DATE             YES            The start date of the RBS
--  p_effectiveTo                DATE             NO             The end date of the Rbs.
--  x_rbsHeaderId                NUMBER           Yes            The value will contain the Rbs Header id which is the unique identifier.

Procedure Insert_Header(
	P_Name 			IN  Varchar2 ,
	P_Description 		IN  Varchar2,
	P_EffectiveFrom 	IN  Date,
	P_EffectiveTo   	IN  Date,
	P_Use_For_Alloc_Flag 	IN  Varchar2,
	X_RbsHeaderId   OUT NOCOPY Number,
	x_return_status OUT NOCOPY Varchar2,
	x_msg_data      OUT NOCOPY Varchar2,
	x_msg_count     OUT NOCOPY Number )

Is

        l_Business_Group_Id Number := Null;

        --This cursor selects the next value for rbs header id from pa_rbs_headers_s sequence
        Cursor c_Rbs_Id_Seq Is
        Select
               Pa_Rbs_Headers_S.NextVal
        From
               Sys.Dual;


Begin

x_return_status := FND_API.G_RET_STS_SUCCESS;
x_msg_data      := NULL;
x_msg_count     := 0;

        Pa_Debug.G_Stage := 'Entering Insert_Header() Pvt.';
        Pa_Debug.TrackPath('ADD','Insert_Header Pvt');

        Pa_Debug.G_Stage := 'Get next available value for the rbs header id.';
	Open c_Rbs_Id_Seq;
        Fetch c_Rbs_Id_Seq Into X_RbsHeaderId;
        Close c_Rbs_Id_Seq;

/* MOAC changes - get the BG ID from the HR Profile */
/*
        Pa_Debug.G_Stage := 'Get the business group id from pa_implementations.';
        Select
               Business_Group_Id
        Into
               l_Business_Group_Id
        From
               Pa_Implementations ;
*/
        Pa_Debug.G_Stage := 'Get the BG ID from HR Profile PER_BUSINESS_GROUP_ID';

        l_Business_Group_Id := fnd_profile.value('PER_BUSINESS_GROUP_ID');

        Pa_Debug.G_Stage := 'Calls the table handler which inserts the rbs header record into the Pa_Rbs_Header table.';
	Pa_Rbs_Headers_Pkg.Insert_Row(
               P_RbsHeaderId 	    => X_RbsHeaderId,
               P_Name		    => P_Name,
               P_Description	    => P_Description,
               P_EffectiveFrom	    => P_EffectiveFrom,
               P_EffectiveTo	    => P_EffectiveTo,
	       P_Use_For_Alloc_Flag => P_Use_For_Alloc_Flag,
               P_BusinessGroupId    => l_Business_Group_Id );

        Pa_Debug.G_Stage := 'Leaving Insert_Header() Pvt.';
        Pa_Debug.TrackPath('STRIP','Insert_Header Pvt');

Exception
        When Others Then
		X_Return_Status := 'U';
                X_Msg_Data := SqlErrm;
                X_Msg_Count := 1;
                Raise;

End Insert_Header;


/*==========================================================================
   This api creates Working Version for the RBS Header.
 ============================================================================*/


-- Procedure            : INSERT_VERSIONS
-- Type                 : Private Procedure
-- Purpose              : This API will be used to create working version for the RBS header.
--                      : This API will be called from following package:
--                      : 1.PA_RBS_HEADER_PUB package,Insert_Header procedure

-- Note                 : This API will insert a record into PA_RBS_VERSIONS_B and PA_RBS_VERSIONS_TL table which is the working version.

-- Assumptions          :

-- Parameters                     Type          Required        Description and Purpose
-- ---------------------------  ------          --------        --------------------------------------------------------
--  p_rbsHeaderId 	         NUMBER           Yes            The value will contain the Rbs Header id which is the unique identifier.
--  p_name                       VARCHAR2         Yes            The value contain the name of the Rbs header
--  p_effectiveFrom              DATE             YES           The start date of the RBS


Procedure Insert_Versions(
	P_RbsHeaderId	        IN         Number,
	P_Name                  IN         Varchar2,
        P_Description           IN         Varchar2 Default Null,
	P_EffectiveFrom         IN         Date,
	X_Rbs_Version_Id        OUT NOCOPY Number,
	X_Return_Status 	OUT NOCOPY Varchar2,
	X_Msg_Data      	OUT NOCOPY Varchar2,
	X_Msg_Count     	OUT NOCOPY Number )


Is

	l_Created_By 		Number := Fnd_Global.User_Id;
	l_Creation_Date 	Date := SysDate;
	l_Last_Update_Date 	Date := SysDate;
	l_Last_Updated_By 	Number := Fnd_Global.User_Id;
	l_Last_Update_Login 	Number := Fnd_Global.Login_Id;

	 --This cursor sets the value for rbs_version_id from pa_rbs_versions_s sequence
        Cursor c_Rbs_Version_Id_Seq Is
        Select
               Pa_Rbs_Versions_S.NextVal
        From
               Sys.Dual;

Begin
x_return_status := FND_API.G_RET_STS_SUCCESS;
x_msg_data      := NULL;
x_msg_count     := 0;


        Pa_Debug.G_Stage := 'Entering Insert_Versions() Pvt.';
        Pa_Debug.TrackPath('ADD','Insert_Versions Pvt');

        Pa_Debug.G_Stage := 'Get the next available sequence for the rbs version table.';
        Open c_Rbs_Version_Id_Seq;
        Fetch c_Rbs_Version_Id_Seq Into X_Rbs_Version_Id;
        Close c_Rbs_Version_Id_Seq;

        Pa_Debug.G_Stage := 'Insert a working version into Pa_Rbs_Versions_B table directly here.';
	Insert Into Pa_Rbs_Versions_B(
				Rbs_Header_Id,
				Rbs_Version_Id,
				Version_Number,
				Version_Start_Date,
				Status_Code,
				Rule_Based_Flag,
				Validated_Flag,
				Creation_Date,
				Created_By,
				Last_Update_Date,
				Last_Updated_By,
				Last_Update_Login,
				Record_Version_Number )
	Values(
				P_RbsHeaderId,
				X_Rbs_Version_Id,
				1,
				P_EffectiveFrom,
				'WORKING',
				'N',
				'N',
				l_Creation_Date,
				l_Created_By,
				l_Last_Update_Date,
				l_Last_Updated_By,
				l_Last_Update_Login,
				1 );

        Pa_Debug.G_Stage := 'Insert working versions into Pa_Rbs_Versions_TL table directly here.';
	Insert Into Pa_Rbs_Versions_TL(
				Rbs_Version_Id,
				Name,
				Description,
				Language,
				Last_Update_Date,
				Last_Updated_By,
				Creation_Date,
				Created_By,
				Last_Update_Login,
				Source_Lang )
	Select
				X_Rbs_Version_Id,
				P_Name,
				P_Description,
				L.Language_Code ,
				l_Last_Update_Date,
				l_Last_Updated_By,
				l_Creation_Date,
				l_Created_By,
				l_Last_Update_Login,
				UserEnv('LANG')
        From
                                Fnd_Languages L

        Where
                                L.Installed_Flag in ('I', 'B')
	And Not Exists
				(Select
                                         Null
				 From
                                         Pa_Rbs_Versions_TL T
				 Where
                                         T.Rbs_Version_Id=X_Rbs_Version_Id
				 And
                                         T.Language=L.Language_Code);

        Pa_Debug.G_Stage := 'Entering Insert_Versions() Pvt.';
        Pa_Debug.TrackPath('STRIP','Insert_Versions Pvt');

Exception
        When Others Then
		X_Return_Status := 'U';
                X_Msg_Data := SqlErrm;
                X_Msg_Count := 1;
                Raise;

End Insert_Versions;

Procedure Insert_Structure_Element(
	P_Rbs_Version_Id IN         Number,
	X_Rbs_Element_Id OUT NOCOPY Number,
	X_Return_Status  OUT NOCOPY Varchar2,
	X_Error_Msg_Data OUT NOCOPY Varchar2,
	X_Msg_Count      OUT NOCOPY Number )

Is

	l_Rbs_Element_Id      Number(15)  := Null;
	NO_RBS_ELEMENT_NAME   Exception;
	l_Rbs_Element_Name_Id Number(15)  := Null;
	l_Error_Status        Varchar2(1) := Null;

	Cursor c1 Is
        Select
                Pa_Rbs_Elements_S.NextVal
        From
                Sys.Dual;

Begin
x_return_status := FND_API.G_RET_STS_SUCCESS;
X_Error_Msg_Data      := NULL;
x_msg_count     := 0;

        Pa_Debug.G_Stage := 'Entering Insert_Structure_Element() Pvt.';
        Pa_Debug.TrackPath('ADD','Insert_Structure_Element Pvt');

	-- pass in the version name to create rbs_element_name.
        Pa_Debug.G_Stage := 'Get the element_name_id by calling Pa_Rbs_Utils.Populate_Rbs_Element_Name() procedure.';
	Pa_Rbs_Utils.Populate_Rbs_Element_Name(
		P_Resource_Source_Id  => P_Rbs_Version_Id,
		P_Resource_Type_Id    => -1,
		X_Rbs_Element_Name_Id => l_Rbs_Element_Name_Id,
		X_Return_Status       => l_Error_Status);

        Pa_Debug.G_Stage := 'Check if the calling to Pa_Rbs_Utils.Populate_Rbs_Element_Name() procedure returned status of U.';
        If l_Error_Status = 'U' Then

             Pa_Debug.G_Stage := 'The call to Pa_Rbs_Utils.Populate_Rbs_Element_Name() procedure returned status Unexpected Error.';
             Raise NO_RBS_ELEMENT_NAME;

        End If;

        Pa_Debug.G_Stage := 'Get the next available sequence for tabpel pa_rbs_elements.';
        Open c1;
        Fetch c1 Into l_Rbs_Element_Id;
        Close c1;

        Pa_Debug.G_Stage := 'Insert record directly into table pa_rbs_elements,';
	Insert Into Pa_Rbs_Elements(
		RBS_Element_Id,
		Rbs_Element_Name_Id,
		RBS_Version_Id,
		Outline_Number,
		Order_Number,
		Resource_Type_Id,
		Resource_Source_Id,
		Person_Id,
		Job_Id,
		Organization_Id,
		Expenditure_Type_Id,
		Event_Type_Id,
		Expenditure_Category_Id,
		Revenue_Category_Id,
		Inventory_Item_Id,
		Item_Category_Id,
		BOM_Labor_Id,
		BOM_Equipment_Id,
		Non_Labor_Resource_Id,
		Role_Id,
		Person_Type_Id,
		Resource_Class_Id,
		Supplier_Id,
		Rule_Flag,
		Parent_Element_Id,
		Rbs_Level,
		Element_Identifier,
		User_Created_Flag,
		User_Defined_Custom1_Id,
		User_Defined_Custom2_Id,
		User_Defined_Custom3_Id,
		User_Defined_Custom4_Id,
		User_Defined_Custom5_Id,
		Last_Update_Date,
		Last_Updated_By,
		Creation_Date,
		Created_By,
		Last_Update_Login,
		Record_Version_Number )
	Values (
		l_Rbs_Element_Id,
		l_Rbs_Element_Name_Id,
		P_RBS_Version_Id,
		'0',
		0,
		-1,
		P_RBS_Version_Id,
		Null,
		Null,
		Null,
		Null,
		Null,
		Null,
		Null,
		Null,
		Null,
		Null,
		Null,
		Null,
		Null,
		Null,
		Null,
		Null,
		'N',
		Null,
		1,
		Pa_Rbs_Element_Identifier_S.NextVal,
		'Y',
		Null,
		Null,
		Null,
		Null,
		Null,
		SysDate,
		Fnd_Global.User_Id,
		SysDate,
		Fnd_Global.User_Id,
		Fnd_Global.Login_Id,
		1);

        X_Rbs_Element_Id := l_Rbs_Element_Id;

        Pa_Debug.G_Stage := 'Leaving Insert_Structure_Element() Pvt.';
        Pa_Debug.TrackPath('STRIP','Insert_Structure_Element Pvt');

Exception
	When Others Then
                X_Return_Status := 'U';
                X_Error_Msg_Data := sqlerrm;
                X_Msg_Count := 1;
                Raise;

End Insert_Structure_Element;


/*==========================================================================
   This api updates RBS Header.
 ============================================================================*/



-- Procedure            : UPDATE_HEADER
-- Type                 : Private Procedure
-- Purpose              : This API will be used to update RBS headers.
--                      : This API will be called from following package:
--                      : 1.PA_RBS_HEADER_PUB package,Update_Header procedure

-- Note                 : This API will make a call to PA_RBS_HEADER_PKG.Update_Row procedure which
--                      : Updates record into PA_RBS_HEADERS_B and PA_RBS_HEADERS_TL table.

-- Assumptions          :

-- Parameters                     Type          Required        Description and Purpose
-- ---------------------------  ------          --------        --------------------------------------------------------
--  p_rbsHeaderId 	         NUMBER           Yes            The value will contain the Rbs Header id which is the unique identifier.
--  p_name                       VARCHAR2         Yes            The value contain the name of the Rbs header
--  p_description                VARCHAR2         NO             The description of the Rbs header
--  p_effectiveFrom              DATE             YES           The start date of the RBS
--  p_effectiveTo                DATE             NO             The end date of the Rbs.


Procedure Update_Header(
                P_RbsHeaderId 	  IN Number,
                P_Name            IN Varchar2 ,
                P_Description     IN Varchar2 ,
                P_EffectiveFrom   IN Date ,
                P_EffectiveTo     IN Date,
		P_Use_For_Alloc_Flag IN Varchar2,
                X_return_Status   OUT NOCOPY Varchar2,
                X_Msg_Data        OUT NOCOPY Varchar2,
                X_Msg_Count       OUT NOCOPY Number)

Is

Begin
x_return_status := FND_API.G_RET_STS_SUCCESS;
x_msg_data      := NULL;
x_msg_count     := 0;

        Pa_Debug.G_Stage := 'Entering Update_Header() Pvt.';
        Pa_Debug.TrackPath('ADD','Update_Header Pvt');

        --Updates Rbs header information
        Pa_Debug.G_Stage := 'Call the table handler procedure Pa_Rbs_Headers_Pkg.Update_Row to update the header record.';
        Pa_Rbs_Headers_Pkg.Update_Row(
                P_RbsHeaderId	=> P_RbsHeaderId,
                P_Name          => P_Name,
                P_Description   => P_Description,
                P_EffectiveFrom => P_EffectiveFrom,
		P_Use_For_Alloc_Flag => P_Use_For_Alloc_Flag,
                P_EffectiveTo   => P_EffectiveTo);

        Pa_Debug.G_Stage := 'Leaving Update_Header() Pvt.';
        Pa_Debug.TrackPath('STRIP','Update_Header Pvt');

Exception
        When Others Then
		X_Return_Status := 'U';
                X_Msg_Data := sqlerrm;
                X_Msg_Count := 1;
                Raise;

End Update_Header;


/*==========================================================================
   This api updates Working Version for the RBS Header.
 ============================================================================*/


-- Procedure            : UPDATE_VERSIONS
-- Type                 : Private Procedure
-- Purpose              : This API will be used to update working version for the RBS header.
--                      : This API will be called from following package:
--                      : 1.PA_RBS_HEADER_PUB package,Update_Header procedure

-- Note                 : This API will Updates working version for Rbs header in PA_RBS_VERSIONS_B and PA_RBS_VERSIONS_TL table.

-- Assumptions          :

-- Parameters                     Type          Required        Description and Purpose
-- ---------------------------  ------          --------        --------------------------------------------------------
--  p_rbsHeaderId                NUMBER           Yes            The value will contain the Rbs Header id which is the unique identifier.
--  p_name                       VARCHAR2         Yes            The value contain the name of the Rbs header
--  p_effectiveFrom              DATE             YES           The start date of the RBS


Procedure Update_Versions(
                P_RbsHeaderId     IN         Number,
                P_RbsVersionId 	  IN         Number Default Null,
                P_Name            IN         Varchar2,
                P_Description     IN         Varchar2 Default Null,
                P_EffectiveFrom   IN         Date,
                P_Rec_Version_Num IN         Number Default Null,
                X_Return_Status   OUT NOCOPY Varchar2,
                X_msg_Data        OUT NOCOPY Varchar2,
                X_Msg_Count       OUT NOCOPY Number )

Is

        l_Last_Update_Date      Date    := SysDate;
        l_Last_Updated_By       Number  := Fnd_Global.User_Id;
        l_Last_Update_Login     Number  := Fnd_Global.Login_Id;
        l_Rbs_Version_Id        Number  := Null;

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;
x_msg_data      := NULL;
x_msg_count     := 0;

        Pa_Debug.G_Stage := 'Leaving Update_Versions() Pvt.';
        Pa_Debug.TrackPath('ADD','Update_Versions Pvt');

        Pa_Debug.G_Stage := 'Check if parameter P_RbsVersionId is null.';
        If P_RbsVersionId is Null Then

                Pa_Debug.G_Stage := 'Since we do not have the rbs version id we need to get it.';
                Select
                        Rbs_Version_Id
                Into
                        l_Rbs_Version_Id
                From
                        Pa_Rbs_Versions_B
                Where
                        Rbs_Header_Id = P_RbsHeaderId
                And     Status_Code = 'WORKING';

        Else

                Pa_Debug.G_Stage := 'We have the rbs version id via the parameters passed in assign to local variable for use.';
                l_Rbs_Version_Id := P_RbsVersionId;

        End If;

        Pa_Debug.G_Stage := 'Directly update the rbs working version.';
        Update Pa_Rbs_Versions_B
        Set
                Version_Start_Date      = P_EffectiveFrom,
                Last_Update_Date        = l_Last_Update_Date,
                Last_Updated_By         = l_Last_Updated_By,
                Last_Update_Login       = l_Last_Update_Login,
                Record_Version_Number   = Record_Version_Number + 1
        Where
                Rbs_Version_Id 	     	= l_Rbs_Version_Id
        And     Status_Code             = 'WORKING'
        And     Record_Version_Number   = Nvl(P_Rec_Version_Num,Record_Version_Number);


        Pa_Debug.G_Stage := 'Check if the update took place.';
	If Sql%NotFound Then

                Pa_Debug.G_Stage := 'Unable to update the rbs version because already updated.  Raising error.';
		Raise No_Data_Found;

	End If;

        Pa_Debug.G_Stage := 'Directly update the pa_rbs_versions_tl table.';
	Update Pa_Rbs_Versions_TL
	Set
		Name			= P_Name,
		Description             = Nvl(Description,P_Description),
		Last_Update_Date	= l_Last_Update_Date,
		Last_Updated_By		= l_Last_Updated_By,
		Last_Update_Login	= l_Last_Update_Login
	Where
		Rbs_Version_Id		= l_Rbs_Version_Id;

Exception
        When Others Then
		X_Return_Status := 'U';
                X_Msg_Data := SqlErrm;
                X_Msg_Count := 1;
                Raise;

END Update_Versions;


/*==========================================================================
   This Function checks if Rbs has rules as its elements or not.
 ============================================================================*/


-- Function             : Validate_Rbs_For_Allocations
-- Type                 : Private Function
-- Purpose              : This Function is used to check if RBS has rules as its elements or not.
--                      : This API will be called from following package:
--                      : 1.PA_RBS_HEADER_PUB package,Update_Header procedure

-- Note                 : This Function is called to check for Rbs having rules as its elements.
--			: This function is called whenever user modifies use_for_alloc_flag(i.e when sets to Y from N)
--			: This change is allowed only when RBS has no rules as its elements.

-- Assumptions          :

-- Parameters                     Type          Required        Description and Purpose
-- ---------------------------  ------          --------        --------------------------------------------------------
--  P_Rbs_ID                     NUMBER           Yes            The value will contain the Rbs Header id which is the unique identifier.

-- Returns either
--		'Y' -When Rbs has rules as its elements.
--		'N' -When Rbs has no elements which are rules.



FUNCTION Validate_Rbs_For_Allocations( P_RBS_ID IN pa_rbs_headers_v.RBS_HEADER_ID%Type ) RETURN VARCHAR2
IS
        l_exists Varchar2(1) := 'N';
	l_count Number ;
BEGIN

	Pa_Debug.G_Stage := 'Inside Validate_Rbs_For_Allocations().';
        Pa_Debug.TrackPath('ADD','Validate_Rbs_For_Allocations Pvt');

        /* Checking PA_RBS_ELEMENTS */

	Select count(*) INTO l_count
	From
		Pa_Rbs_Versions_b Verb,
		Pa_Rbs_Elements ele
	Where
		Verb.rbs_header_id=P_RBS_ID
	And
		verb.Rbs_Version_Id=Ele.Rbs_Version_Id
	And
		Ele.resource_source_id=-1;

	Pa_Debug.G_Stage := 'Check if rbs has rules as its elements. If so return Y';

	If l_count<>0  Then
		l_exists := 'Y';
	Else
		l_exists := 'N';
	End If;

	Pa_Debug.G_Stage := 'Leaving Validate_Rbs_For_Allocations().';

                   Return l_exists ;

END Validate_Rbs_For_Allocations;

End Pa_Rbs_Header_Pvt;

/
