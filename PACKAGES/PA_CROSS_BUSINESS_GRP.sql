--------------------------------------------------------
--  DDL for Package PA_CROSS_BUSINESS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CROSS_BUSINESS_GRP" 
--  $Header: PAXCBGAS.pls 120.1 2005/08/19 17:11:04 mwasowic noship $
AUTHID CURRENT_USER AS

G_MasterGroupId		NUMBER ;
G_CrossBGProfile        VARCHAR2(1) ;

FUNCTION IsMappedToJob	(P_From_Job_Id IN NUMBER,
			 P_To_Job_Group_Id IN NUMBER ) RETURN NUMBER;
pragma RESTRICT_REFERENCES ( IsMappedToJob, WNDS );

PROCEDURE GetMappedToJob (
			P_From_Job_Id IN NUMBER,
			P_To_Job_Group_Id IN NUMBER,
			X_To_Job_Id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
			X_Status_Code OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			X_Error_Stage OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			X_Error_Code OUT NOCOPY NUMBER ) ; --File.Sql.39 bug 4440895


PROCEDURE GetMappedToJobs (
		P_From_Job_Id_Tab IN PA_PLSQL_DATATYPES.IdTabTyp,
		P_To_Job_Group_Id_Tab IN PA_PLSQL_DATATYPES.IdTabTyp,
		X_To_Job_Id_Tab OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp, --File.Sql.39 bug 4440895
		X_StatusTab OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp, --File.Sql.39 bug 4440895
		X_Error_Stage OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		X_Error_Code OUT NOCOPY NUMBER ) ; --File.Sql.39 bug 4440895


FUNCTION IsCrossBGProfile RETURN VARCHAR2 ;
pragma RESTRICT_REFERENCES ( IsCrossBGProfile, WNDS);


PROCEDURE GetMasterGrpId  (
			P_Business_Group_Id IN NUMBER DEFAULT NULL,
			X_Master_Grp_Id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
			X_Status_Code OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			X_Error_Stage OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			X_Error_Code OUT NOCOPY NUMBER ) ; --File.Sql.39 bug 4440895

PROCEDURE GetGlobalHierarchy (
			P_Org_Structure_Id IN NUMBER,
			X_Global_Hierarchy OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			X_Status_Code OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			X_Error_Stage OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			X_Error_Code OUT NOCOPY NUMBER ) ; --File.Sql.39 bug 4440895


PROCEDURE GetJobIds (	P_HR_Job_Id IN NUMBER,
			P_Project_Id IN NUMBER,
			X_Bill_Job_Id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
			X_Bill_Job_Grp_Id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
			X_Cost_Job_Id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
			X_Cost_Job_Grp_Id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
			X_PP_Bill_Job_Id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
			X_Status_Code OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			X_Error_Stage OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			X_Error_Code OUT NOCOPY NUMBER ) ; --File.Sql.39 bug 4440895

FUNCTION GetDefProjJobGrpId ( P_Project_Id IN NUMBER,
			      P_Group_Type IN VARCHAR2 ) RETURN NUMBER ;
pragma RESTRICT_REFERENCES ( GetDefProjJobGrpId, WNDS, WNPS) ;

FUNCTION FindJobIndex ( P_From_Job_To_Grp IN VARCHAR2 ) RETURN BINARY_INTEGER;
pragma RESTRICT_REFERENCES ( FindJobIndex, WNDS ) ;

FUNCTION HRJobGroupIs (P_Business_Group_Id IN NUMBER ) RETURN NUMBER;
pragma RESTRICT_REFERENCES ( HRJobGroupIs, WNDS, WNPS ) ;

PROCEDURE ErrorStage(P_Message IN VARCHAR2,
                     X_Stage OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


End;

 

/
