--------------------------------------------------------
--  DDL for Package PA_RBS_HEADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RBS_HEADER_PVT" AUTHID CURRENT_USER AS
--$Header: PARBSHVS.pls 120.0 2005/05/30 17:32:42 appldev noship $


PROCEDURE Insert_Header(
        P_Name          IN         Varchar2,
        P_Description   IN         Varchar2,
        P_EffectiveFrom IN         Date,
        P_EffectiveTo   IN         Date,
	P_Use_For_Alloc_Flag IN    Varchar2,
        X_RbsHeaderId   OUT NOCOPY Number,
        x_return_status OUT NOCOPY Varchar2,
        x_msg_data      OUT NOCOPY Varchar2,
        x_msg_count     OUT NOCOPY NUMBER );

PROCEDURE Insert_Versions(
        p_rbsHeaderId           IN         Number,
        p_name                  IN         Varchar2,
        p_description           IN         Varchar2 Default Null,
        p_effectiveFrom         IN         Date,
        X_Rbs_Version_Id        OUT NOCOPY Number,
        x_return_status         OUT NOCOPY Varchar2,
        x_msg_data              OUT NOCOPY Varchar2,
        x_msg_count             OUT NOCOPY Number );

Procedure Insert_Structure_Element(
	P_Rbs_Version_Id IN         Number,
	X_Rbs_Element_Id OUT NOCOPY Number,
	X_Return_Status  OUT NOCOPY Varchar2,
	X_Error_Msg_Data OUT NOCOPY Varchar2,
	X_Msg_Count      OUT NOCOPY Number);

PROCEDURE Update_Header(
	p_rbsHeaderId 	IN         Number,
	p_name 		IN         Varchar2,
	p_description 	IN         Varchar2,
	p_effectiveFrom IN         Date,
	p_effectiveTo 	IN         Date,
	p_use_for_alloc_flag IN Varchar2,
	x_return_status OUT NOCOPY Varchar2,
	x_msg_data      OUT NOCOPY Varchar2,
	x_msg_count     OUT NOCOPY Number);

PROCEDURE Update_Versions(
	p_rbsHeaderId   IN         Number,
	p_rbsVersionId  IN         Number Default Null,
	p_name 		IN         Varchar2,
	p_description   IN         Varchar2 Default Null,
	p_effectiveFrom IN         Date,
        P_Rec_Version_Num IN       Number Default Null,
	x_return_status OUT NOCOPY Varchar2,
	x_msg_data      OUT NOCOPY Varchar2,
	x_msg_count     OUT NOCOPY Number);

FUNCTION Validate_Rbs_For_Allocations( P_RBS_ID IN pa_rbs_headers_v.RBS_HEADER_ID%Type ) RETURN VARCHAR2;

END PA_RBS_HEADER_PVT;

 

/
