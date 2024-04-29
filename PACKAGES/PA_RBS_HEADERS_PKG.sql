--------------------------------------------------------
--  DDL for Package PA_RBS_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RBS_HEADERS_PKG" AUTHID CURRENT_USER AS
--$Header: PARBSHTS.pls 120.1 2005/09/26 17:56:57 appldev noship $

Procedure Insert_Row(
        P_RbsHeaderId        IN Number,
        P_Name         	     IN Varchar2,
	P_Description 	     IN Varchar2,
	P_EffectiveFrom      IN Date,
	P_EffectiveTo 	     IN Date,
	P_Use_For_Alloc_Flag IN Varchar2,
        P_BusinessGroupId    IN Number);

Procedure Update_Row(
	P_RbsHeaderId         IN         Number,
        P_Name                IN         Varchar2,
        P_Description         IN         Varchar2,
        P_EffectiveFrom       IN         Date,
	P_Use_For_Alloc_Flag  IN         Varchar2,
        P_EffectiveTo         IN         Date);

Procedure Add_language;

End Pa_Rbs_Headers_Pkg;

 

/
