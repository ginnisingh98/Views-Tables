--------------------------------------------------------
--  DDL for Package PA_RBS_VERSIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RBS_VERSIONS_PVT" AUTHID CURRENT_USER as
--$Header: PARBSVVS.pls 120.0 2005/05/30 07:09:06 appldev noship $

-- Standard Who
G_Last_Updated_By         Number(15) := Fnd_Global.User_Id;
G_Last_Update_Date        Date       := SysDate;
G_Creation_Date           Date       := SysDate;
G_Created_By              Number(15) := Fnd_Global.User_Id;
G_Last_Update_Login       Number(15) := Fnd_Global.Login_Id;

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
	X_Error_Msg_Data	OUT NOCOPY Varchar2 );

Procedure Update_Working_Version(
	P_RBS_Version_Id	IN	   Number,
	P_Name			IN	   Varchar2,
	P_Description		IN	   Varchar2,
	P_Version_Start_Date	IN	   Date	,
	P_Job_Group_Id		IN	   Number,
	P_Record_Version_Number	IN	   Number,
	X_Record_Version_Number OUT NOCOPY Number,
	X_Error_Msg_Data	OUT NOCOPY Varchar2 );

Procedure Delete_Working_Version(
	P_Mode                  IN         Varchar2 Default Null,
        P_RBS_Version_Id        IN         Number,
        P_Record_Version_Number IN         Number,
        X_Error_Msg_Data        OUT NOCOPY Varchar2);

Procedure Create_New_Working_Version(
	P_Rbs_Version_Id        IN         Number,
	P_Rbs_Header_Id         IN         Number,
	P_Record_Version_Number IN         Number,
	X_Error_Msg_Data        OUT NOCOPY Varchar2);

Procedure Copy_Frozen_Rbs_Version(
	P_Rbs_Version_Id        IN  Number,
	P_Rbs_Header_Id         IN  Number,
	P_Record_Version_Number IN  Number,
	X_Rbs_Version_Id        OUT NOCOPY Number,
	X_Error_Msg_Data        OUT NOCOPY Varchar2);

Procedure Copy_Frozen_Rbs_Elements(
	P_Rbs_Version_From_Id IN         Number,
	P_Rbs_Version_To_Id   IN         Number,
	X_Error_Msg_Data      OUT NOCOPY Varchar2);

Procedure Set_Reporting_Flag(
        p_rbs_version_id   IN  Number,
        x_return_status    OUT NOCOPY Varchar2);


END PA_RBS_VERSIONS_PVT;

 

/
