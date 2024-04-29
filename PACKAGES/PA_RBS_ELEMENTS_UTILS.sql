--------------------------------------------------------
--  DDL for Package PA_RBS_ELEMENTS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RBS_ELEMENTS_UTILS" AUTHID CURRENT_USER AS
/* $Header: PARELEUS.pls 120.0 2005/05/29 23:40:11 appldev noship $*/

Function RbsElementExists(
                P_Element_Id IN Number) Return Varchar2;

Function GetRbsElementNameId(
                P_Resource_Type_Id IN Number,
                P_Resource_Source_Id IN Number) Return Number;

Procedure GetResSourceId(
        P_Resource_Type_Id     IN         Number,
        P_Resource_Source_Code IN         Varchar2,
        X_Resource_Source_Id   OUT NOCOPY Number);

Function GetResTypeCode(
	P_Res_Type_Id IN Number) Return Varchar2;

END Pa_Rbs_Elements_Utils;

 

/
