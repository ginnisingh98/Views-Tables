--------------------------------------------------------
--  DDL for Package PA_RBS_HEADER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RBS_HEADER_PUB" AUTHID CURRENT_USER AS
--$Header: PARBSHPS.pls 120.0 2005/05/29 17:02:14 appldev noship $

G_Api_Version_Number  Number       := 1;
G_Pkg_Name            Varchar2(30) := 'Pa_Rbs_Header_Pub';

Procedure Insert_Header(
        P_Commit             IN         Varchar2 Default Fnd_Api.G_False,
        P_Init_Msg_List      IN         Varchar2 Default Fnd_Api.G_True,
        P_API_Version_Number IN         Number,
	P_Name 		     IN         Varchar2,
	P_Description 	     IN         Varchar2,
	P_EffectiveFrom      IN         Date,
	P_EffectiveTo 	     IN         Date,
	P_Use_For_Alloc_Flag IN         Varchar2 Default 'N',
	X_Rbs_Header_Id      OUT NOCOPY Number,
        X_Rbs_Version_Id     OUT NOCOPY Number,
        X_Rbs_Element_Id     OUT NOCOPY Number,
	X_Return_Status      OUT NOCOPY Varchar2,
	X_Msg_Data 	     OUT NOCOPY Varchar2,
	X_Msg_Count 	     OUT NOCOPY Number);

PROCEDURE Update_Header(
        P_Commit              IN         Varchar2 Default Fnd_Api.G_False,
        P_Init_Msg_List       IN         Varchar2 Default Fnd_Api.G_True,
        P_API_Version_Number  IN         Number,
	P_RbsHeaderId	      IN         Number,
	P_Name 		      IN         Varchar2,
	P_Description 	      IN         Varchar2,
	P_EffectiveFrom       IN         Date,
	P_EffectiveTo 	      IN         Date,
	P_Use_For_Alloc_Flag  IN         Varchar2 Default 'N',
	P_RecordVersionNumber IN         Number,
	P_Process_Version     IN         Varchar2 Default Fnd_Api.G_True,
	X_Return_Status       OUT NOCOPY Varchar2,
	X_Msg_Data 	      OUT NOCOPY Varchar2,
	X_Msg_Count 	      OUT NOCOPY Number);

END PA_RBS_HEADER_PUB;

 

/
