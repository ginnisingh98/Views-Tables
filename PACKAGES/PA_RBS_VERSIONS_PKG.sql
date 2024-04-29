--------------------------------------------------------
--  DDL for Package PA_RBS_VERSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RBS_VERSIONS_PKG" AUTHID CURRENT_USER AS
--$Header: PARBSVTS.pls 120.1 2005/09/26 17:57:07 appldev noship $


PROCEDURE Insert_Row(
        P_Version_Number                IN         Number,
        P_Rbs_Header_Id                 IN         Number,
	P_Record_Version_Number		IN	   Number,
        P_Name                          IN         Varchar2,
        P_Description                   IN         Varchar2,
        P_Version_Start_Date            IN         Date,
        P_Version_End_Date              IN         Date,
        P_Job_Group_Id                  IN         Number,
        P_Rule_Based_Flag               IN         Varchar2,
        P_Validated_Flag                IN         Varchar2,
        P_Status_Code                   IN         Varchar2,
        P_Creation_Date                 IN         Date,
        P_Created_By                    IN         Number,
        P_Last_Update_Date              IN         Date,
        P_Last_Updated_By               IN         Number,
        P_Last_Update_Login             IN         Number,
        X_Record_Version_Number         OUT NOCOPY Number,
        X_Rbs_Version_Id                OUT NOCOPY Number,
        X_Error_Msg_Data                OUT NOCOPY Varchar2 );

Procedure Update_Row(
	P_RBS_Version_Id		IN	   Number,
	P_Name				IN	   Varchar2,
	P_Description			IN	   Varchar2,
	P_Version_Start_Date		IN	   Date,
	P_Job_Group_Id			IN	   Number,
	P_Record_Version_Number		IN	   Number,
	P_Last_Update_Date		IN	   Date,
	P_Last_Updated_By		IN	   Number,
	P_Last_Update_Login		IN	   Number,
	X_Record_Version_Number		OUT NOCOPY Number,
	X_Error_Msg_Data		OUT NOCOPY Varchar2 );


Procedure Delete_Row (
	P_RBS_Version_Id                IN         Number,
	P_Record_Version_Number         IN         Number,
	X_Error_Msg_Data		OUT NOCOPY Varchar2);

PROCEDURE Add_language;

END PA_RBS_VERSIONS_PKG;

 

/
