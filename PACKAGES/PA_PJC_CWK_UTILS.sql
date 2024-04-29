--------------------------------------------------------
--  DDL for Package PA_PJC_CWK_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PJC_CWK_UTILS" AUTHID CURRENT_USER AS
-- $Header: PACWKUTS.pls 120.0 2005/05/30 09:20:13 appldev noship $

--Function is_rate_based_line
--This function is wrapper around the POs API PO_PA_INTEGRATION_GRP.is_rate_based_line
Function is_rate_based_line (P_Po_Line_Id         In Number,
                             P_Po_Distribution_Id In Number) Return Varchar2;

G_PoLineIdTab PA_PLSQL_DATATYPES.IdTabTyp;
G_IsRBLineTab PA_PLSQL_DATATYPES.Char1TabTyp;

G_ExCwkRbTCOrgIdTab PA_PLSQL_DATATYPES.Char1TabTyp;

--Function Exists_Prj_Cwk_RbTC(P_Org_Id IN NUMBER)
--Called from the Project Implementations form when the value for INTERFACE_CWK_TIMECARDS is changed from Y to N or vice versa
--Returns 'Y' if there exists project related rate based POs for any of the projects in the given P_Org_Id. Else return 'N'.

Function Exists_Prj_Cwk_RbTC(P_Org_Id IN NUMBER) RETURN Varchar2;

G_CwkTCXfaceAllowedTab PA_PLSQL_DATATYPES.Char1TabTyp;

--Function Is_Cwk_TC_Xface_Allowed(P_Project_Id IN NUMBER)
--This function identifies for the given project OU if CWK tiemcard interface is allowed or not
--If enabled then costs must be interfaced as labor costs for CWK
--If disabled costs must be interfaced as supplier costs for CWK
Function Is_Cwk_TC_Xface_Allowed(P_Project_Id IN NUMBER) RETURN Varchar2;

END PA_PJC_CWK_UTILS;

 

/
