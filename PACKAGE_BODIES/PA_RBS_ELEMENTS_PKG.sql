--------------------------------------------------------
--  DDL for Package Body PA_RBS_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RBS_ELEMENTS_PKG" AS
/* $Header: PARELETB.pls 120.0 2005/05/29 20:40:20 appldev noship $*/

	Procedure Insert_Row(
		P_Rbs_Element_Name_Id		IN	   Number,
		P_RBS_Version_Id 		IN	   Number,
		P_Outline_Number 		IN 	   Varchar2,
		P_Order_Number		        IN 	   Number,
		P_Resource_Type_Id		IN 	   Number,
		P_Resource_Source_Id		IN	   Number,
		P_Person_Id			IN 	   Number,
		P_Job_Id			IN 	   Number,
		P_Organization_Id		IN 	   Number,
		P_Expenditure_Type_Id		IN 	   Number,
		P_Event_Type_Id			IN 	   Number,
		P_Expenditure_Category_Id	IN 	   Number,
		P_Revenue_Category_Id		IN	   Number,
		P_Inventory_Item_Id		IN	   Number,
		P_Item_Category_Id		IN	   Number,
		P_BOM_Labor_Id			IN	   Number,
		P_BOM_Equipment_Id		IN	   Number,
		P_Non_Labor_Resource_Id		IN	   Number,
		P_Role_Id			IN	   Number,
		P_Person_Type_Id		IN	   Number,
		P_Resource_Class_Id		IN	   Number,
		P_Supplier_Id			IN	   Number,
		P_Rule_Flag			IN	   Varchar2,
		P_Parent_Element_Id		IN	   Number,
                P_Rbs_Level                     IN         Number,
                P_Element_Identifier            IN         Number,
                P_User_Created_Flag             IN         Varchar2,
                P_User_Defined_Custom1_Id       IN         Number,
                P_User_Defined_Custom2_Id       IN         Number,
                P_User_Defined_Custom3_Id       IN         Number,
                P_User_Defined_Custom4_Id       IN         Number,
                P_User_Defined_Custom5_Id       IN         Number,
		P_Last_Update_Date		IN	   Date,
		P_Last_Updated_By		IN	   Number,
		P_Last_Update_Login             IN         Number,
		P_Creation_Date			IN	   Date,
		P_Created_By			IN	   Number,
		X_RBS_Element_Id		OUT NOCOPY Number,
		X_Error_Msg_Data		OUT NOCOPY Varchar2)

	Is

		UNABLE_TO_CREATE_REC Exception;
		l_RowId		  RowId  := Null;

        	Cursor Return_RowId(P_Id IN Number) is
        	Select
                	RowId
        	From
                	Pa_RBS_Elements
        	Where
                	RBS_Element_Id = P_Id;

		Cursor GetNextId is
		Select
			Pa_Rbs_Elements_S.NextVal
		From
			Dual;

	Begin

		Open GetNextId;
		Fetch GetNextId Into X_RBS_Element_Id;
		Close GetNextId;

		Insert Into Pa_RBS_Elements (
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
			X_RBS_Element_Id,
			P_Rbs_Element_Name_Id,
                	P_RBS_Version_Id,
                	P_Outline_Number,
                	P_Order_Number,
                	P_Resource_Type_Id,
			P_Resource_Source_Id,
                	P_Person_Id,
                	P_Job_Id,
                	P_Organization_Id,
                	P_Expenditure_Type_Id,
                	P_Event_Type_Id,
                	P_Expenditure_Category_Id,
                	P_Revenue_Category_Id,
                	P_Inventory_Item_Id,
                	P_Item_Category_Id,
                	P_BOM_Labor_Id,
                	P_BOM_Equipment_Id,
                	P_Non_Labor_Resource_Id,
                	P_Role_Id,
                	P_Person_Type_Id,
                	P_Resource_Class_Id,
                	P_Supplier_Id,
                	P_Rule_Flag,
                	P_Parent_Element_Id,
                	P_Rbs_Level,
                	P_Element_Identifier,
                	P_User_Created_Flag,
                        P_User_Defined_Custom1_Id,
                        P_User_Defined_Custom2_Id,
                        P_User_Defined_Custom3_Id,
                        P_User_Defined_Custom4_Id,
                        P_User_Defined_Custom5_Id,
                	P_Last_Update_Date,
                	P_Last_Updated_By,
                	P_Creation_Date,
                	P_Created_By,
                	P_Last_Update_Login,
                	1);

		Open Return_RowId (P_Id => X_RBS_Element_Id);
		Fetch Return_RowId Into l_RowId;

		If Return_RowId%NotFound Then

			Close Return_RowId;
			X_RBS_Element_Id := Null;
			Raise UNABLE_TO_CREATE_REC;

		End If;

		Close Return_RowId;

	Exception
		When UNABLE_TO_CREATE_REC Then
			-- System Error for sys admin information needed
			X_Error_Msg_Data := 'PA_UNABLE_TO_CREATE_REC';
		When others Then
			Raise;

	End Insert_Row;

	Procedure Update_Row(
		P_Rbs_Element_Id		IN	   Number,
		P_Rbs_Element_Name_Id		IN	   Number,
                P_Rbs_Version_Id                IN         Number,
                P_Outline_Number                IN         Varchar2,
                P_Order_Number                  IN         Number,
                P_Resource_Type_Id              IN         Number,
		P_Resource_Source_Id		IN	   Number,
                P_Person_Id                     IN         Number,
                P_Job_Id                        IN         Number,
                P_Organization_Id               IN         Number,
                P_Expenditure_Type_Id           IN         Number,
                P_Event_Type_Id                 IN         Number,
                P_Expenditure_Category_Id       IN         Number,
                P_Revenue_Category_Id           IN         Number,
                P_Inventory_Item_Id             IN         Number,
                P_Item_Category_Id              IN         Number,
                P_BOM_Labor_Id                  IN         Number,
                P_BOM_Equipment_Id              IN         Number,
                P_Non_Labor_Resource_Id         IN         Number,
                P_Role_Id                       IN         Number,
                P_Person_Type_Id                IN         Number,
                P_Resource_Class_Id             IN         Number,
                P_Supplier_Id                   IN         Number,
                P_Rule_Flag                     IN         Varchar2,
                P_Parent_Element_Id             IN         Number,
                P_Rbs_Level                     IN         Number,
                P_Element_Identifier            IN         Number,
                P_User_Created_Flag             IN         Varchar2,
                P_User_Defined_Custom1_Id       IN         Number,
                P_User_Defined_Custom2_Id       IN         Number,
                P_User_Defined_Custom3_Id       IN         Number,
                P_User_Defined_Custom4_Id       IN         Number,
                P_User_Defined_Custom5_Id       IN         Number,
                P_Last_Update_Date              IN         Date,
                P_Last_Updated_By               IN         Number,
                P_Last_Update_Login             IN         Number,
		X_Error_Msg_Data		OUT NOCOPY Varchar2)

	Is

		REC_VER_NUM_MISMATCH Exception;

	Begin

		Update PA_RBS_Elements
                Set
			RBS_Version_Id		 = P_Rbs_Version_Id,
			Rbs_Element_Name_Id	 = P_Rbs_Element_Name_Id,
			Outline_Number		 = P_Outline_Number,
                    	Order_Number		 = P_Order_Number,
                    	Resource_Type_Id	 = P_Resource_Type_Id,
			Resource_Source_Id	 = P_Resource_Source_Id,
                    	Person_Id                = P_Person_Id,
                    	Job_Id                   = P_Job_Id,
                    	Organization_Id          = P_Organization_Id,
                    	Expenditure_Type_Id      = P_Expenditure_Type_Id,
                    	Event_Type_Id            = P_Event_Type_Id,
                    	Expenditure_Category_Id  = P_Expenditure_Category_Id,
                    	Revenue_Category_Id      = P_Revenue_Category_Id,
                    	Inventory_Item_Id        = P_Inventory_Item_Id,
                    	Item_Category_Id         = P_Item_Category_Id,
                    	BOM_Labor_Id             = P_BOM_Labor_Id,
                    	BOM_Equipment_Id         = P_BOM_Equipment_Id,
                    	Non_Labor_Resource_Id    = P_Non_Labor_Resource_Id,
                    	Role_Id                  = P_Role_Id,
                    	Person_Type_Id           = P_Person_Type_Id,
                    	Resource_Class_Id        = P_Resource_Class_Id,
                    	Supplier_Id              = P_Supplier_Id,
                    	Rule_Flag                = P_Rule_Flag,
                    	Parent_Element_Id        = P_Parent_Element_Id,
                	Rbs_Level		 = P_Rbs_Level,
                	Element_Identifier	 = P_Element_Identifier,
                	User_Created_Flag	 = P_User_Created_Flag,
                	User_Defined_Custom1_Id  = P_User_Defined_Custom1_Id,
                	User_Defined_Custom2_Id  = P_User_Defined_Custom2_Id,
                	User_Defined_Custom3_Id  = P_User_Defined_Custom3_Id,
                	User_Defined_Custom4_Id  = P_User_Defined_Custom4_Id,
                	User_Defined_Custom5_Id  = P_User_Defined_Custom5_Id,
                    	Last_Update_Date         = P_Last_Update_Date,
                    	Last_Updated_By          = P_Last_Updated_By,
                    	Last_Update_Login        = P_Last_Update_Login,
                    	Record_Version_Number    = Record_Version_Number + 1
		Where
			Rbs_Element_Id 	      = P_Rbs_Element_Id;

		If Sql%NotFound Then

			Raise REC_VER_NUM_MISMATCH;

		End If;


	Exception
		When REC_VER_NUM_MISMATCH Then
			X_Error_Msg_Data := 'PA_RECORD_ALREADY_UPDATED';
		When Others Then
			Raise;

	End Update_Row;

	Procedure Delete_Row(
		P_RBS_Element_Id		IN	Number)

	Is


	Begin

		Delete
		From
			Pa_Rbs_Elements
		Where
			Rbs_Element_Id = P_Rbs_Element_Id;

	Exception
		When Others Then
			Raise;

	End Delete_Row;

End Pa_Rbs_Elements_Pkg;

/
