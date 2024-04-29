--------------------------------------------------------
--  DDL for Package PA_RBS_ELEMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RBS_ELEMENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: PARELEVS.pls 120.0 2005/05/31 05:56:21 appldev noship $*/

-- Standard Who
G_Last_Updated_By         Number(15) := Fnd_Global.User_Id;
G_Last_Update_Date        Date       := SysDate;
G_Creation_Date           Date       := SysDate;
G_Created_By              Number(15) := Fnd_Global.User_Id;
G_Last_Update_Login       Number(15) := Fnd_Global.Login_Id;

/* -------------------------------------------------------------------------------
 * Procedure: Process_RBS_Elements
 * Function: Entry point for the insert/update/delete of elements/nodes
 * ------------------------------------------------------------------------------- */

Procedure Process_RBS_Element (
        P_RBS_Version_Id        IN         Number,
        P_Parent_Element_Id     IN         Number,
        P_Element_Id            IN         Number,
        P_Resource_Type_Id      IN         Number,
        P_Resource_Source_Id    IN         Number,
        P_Order_Number          IN         Number,
        P_Process_Type          IN         Varchar2,
        X_RBS_Element_id        OUT NOCOPY Number,
        X_Error_Msg_Data        OUT NOCOPY Varchar2);

Procedure DeleteRbsElement(
	P_RBS_Version_Id     IN         Number,
	P_Element_Id         IN         Number,
	X_Error_Msg_Data     OUT NOCOPY Varchar2);

Procedure UpdateExisingRbsElement(
	P_Rbs_Version_Id      IN         Number,
        P_Parent_Element_Id   IN         Number,
        P_Rbs_Element_Id      IN         Number,
        P_Resource_Type_Id    IN         Number,
        P_Resource_Source_Id  IN         Number,
        P_Order_Number        IN         Number,
        X_Error_Msg_Data      OUT NOCOPY Varchar2);

Procedure CreateNewRbsElement(
	P_Rbs_Version_Id     IN Number,
	P_Parent_Element_Id  IN Number,
	P_Rbs_Element_Id     IN Number,
	P_Resource_Type_Id   IN Number,
	P_Resource_Source_Id IN Number,
	P_Order_Number       IN Number,
	X_RBS_Element_id     OUT NOCOPY Number,
	X_Error_Msg_Data     OUT NOCOPY Varchar2);

Procedure ValidateAndBuildElement(
        P_Mode                IN         Varchar2,
        P_Rbs_Version_Id      IN         Number,
        P_Parent_Element_Id   IN         Number,
        P_Rbs_Element_Id      IN         Number,
        P_Resource_Type_Id    IN         Number,
        P_Resource_Source_Id  IN         Number,
        P_Order_Number        IN         Number,
        X_Person_Id           OUT NOCOPY Number,
        X_Job_Id              OUT NOCOPY Number,
        X_Organization_Id     OUT NOCOPY Number,
        X_Exp_Type_Id         OUT NOCOPY Number,
        X_Event_Type_Id       OUT NOCOPY Number,
        X_Exp_Cat_Id          OUT NOCOPY Number,
        X_Rev_Cat_Id          OUT NOCOPY Number,
        X_Inv_Item_Id         OUT NOCOPY Number,
        X_Item_Cat_Id         OUT NOCOPY Number,
        X_BOM_Labor_Id        OUT NOCOPY Number,
        X_BOM_Equip_Id        OUT NOCOPY Number,
        X_Non_Labor_Res_Id    OUT NOCOPY Number,
        X_Role_Id             OUT NOCOPY Number,
        X_Person_Type_Id      OUT NOCOPY Number,
        X_User_Def_Custom1_Id OUT NOCOPY Number,
        X_User_Def_Custom2_Id OUT NOCOPY Number,
        X_User_Def_Custom3_Id OUT NOCOPY Number,
        X_User_Def_Custom4_Id OUT NOCOPY Number,
        X_User_Def_Custom5_Id OUT NOCOPY Number,
        X_Res_Class_Id        OUT NOCOPY Number,
        X_Supplier_Id         OUT NOCOPY Number,
        X_Rbs_Level           OUT NOCOPY Number,
        X_Rule_Based_Flag     OUT NOCOPY Varchar2,
        X_Rbs_Element_Name_Id OUT NOCOPY Number,
        X_Order_Number        OUT NOCOPY Number,
        X_Element_Identifier  OUT NOCOPY Number,
	X_Outline_Number      OUT NOCOPY Varchar2,
        X_Error_Msg_Data      OUT NOCOPY Varchar2);

Procedure ValidateRbsElement(
        P_Mode                    IN         Varchar2,
        P_Rbs_Version_Id          IN         Number,
        P_Parent_Element_Id       IN         Number,
        P_Rbs_Element_Id          IN         Number,
        P_Old_Resource_Type_Id    IN         Number,
        P_Old_Resource_Source_Id  IN         Number,
        P_Resource_Type_Id        IN         Number,
        P_Resource_Source_Id      IN         Number,
        X_Resource_Type           OUT NOCOPY Varchar2,
        X_Error_Msg_Data          OUT NOCOPY Varchar2);

Procedure ValidateResource(
        P_Resource_Type_Id   IN Number,
        P_Resource_Source_Id IN Number,
        P_Resource_Type      IN Varchar2,
        X_Error_Msg_Data     OUT NOCOPY Varchar2);

Procedure GetParentRbsData(
        P_Parent_Element_Id   IN         Number,
        X_Person_Id           OUT NOCOPY Number,
        X_Job_Id              OUT NOCOPY Number,
        X_Organization_Id     OUT NOCOPY Number,
        X_Exp_Type_Id         OUT NOCOPY Number,
        X_Event_Type_Id       OUT NOCOPY Number,
        X_Exp_Cat_Id          OUT NOCOPY Number,
        X_Rev_Cat_Id          OUT NOCOPY Number,
        X_Inv_Item_Id         OUT NOCOPY Number,
        X_Item_Cat_Id         OUT NOCOPY Number,
        X_BOM_Labor_Id        OUT NOCOPY Number,
        X_BOM_Equip_Id        OUT NOCOPY Number,
        X_Non_Labor_Res_Id    OUT NOCOPY Number,
        X_Role_Id             OUT NOCOPY Number,
        X_Person_Type_Id      OUT NOCOPY Number,
        X_User_Def_Custom1_Id OUT NOCOPY Number,
        X_User_Def_Custom2_Id OUT NOCOPY Number,
        X_User_Def_Custom3_Id OUT NOCOPY Number,
        X_User_Def_Custom4_Id OUT NOCOPY Number,
        X_User_Def_Custom5_Id OUT NOCOPY Number,
        X_Res_Class_Id        OUT NOCOPY Number,
        X_Supplier_Id         OUT NOCOPY Number,
        X_Rbs_Level           OUT NOCOPY Number,
        X_Outline_Number      OUT NOCOPY Varchar2);

Procedure UpdateOrderOutlineNumber(
	P_Parent_Element_Id_Tbl IN         System.Pa_Num_Tbl_Type,
	X_Error_Msg_Data        OUT NOCOPY Varchar2 );

Procedure Update_Children_Data(
        P_Rbs_Element_Id IN         Number,
        X_Error_Msg_Data OUT NOCOPY Varchar2);



END Pa_Rbs_Elements_Pvt;

 

/
