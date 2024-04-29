--------------------------------------------------------
--  DDL for Package PA_RBS_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RBS_ELEMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: PARELETS.pls 120.0 2005/06/03 13:34:03 appldev noship $*/

	Procedure Insert_Row(
                P_Rbs_Element_Name_Id           IN         Number,
                P_RBS_Version_Id                IN         Number,
                P_Outline_Number                IN         Varchar2,
                P_Order_Number                  IN         Number,
                P_Resource_Type_Id              IN         Number,
		P_Resource_Source_Id		IN 	   Number,
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
                P_Creation_Date                 IN         Date,
                P_Created_By                    IN         Number,
                X_RBS_Element_Id                OUT NOCOPY Number,
                X_Error_Msg_Data                OUT NOCOPY Varchar2);

	Procedure Update_Row(
		P_RBS_Element_Id		IN	   Number,
		P_Rbs_Element_Name_Id		IN	   Number,
                P_RBS_Version_Id                IN         Number,
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
                P_Person_Type_ID                IN         Number,
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
		X_Error_Msg_Data		OUT NOCOPY Varchar2);

	Procedure Delete_Row(
		P_RBS_Element_Id		IN	Number);

END Pa_Rbs_Elements_Pkg;

 

/
