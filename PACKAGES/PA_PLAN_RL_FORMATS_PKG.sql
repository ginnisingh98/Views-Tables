--------------------------------------------------------
--  DDL for Package PA_PLAN_RL_FORMATS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PLAN_RL_FORMATS_PKG" AUTHID CURRENT_USER as
/* $Header: PARRFTTS.pls 120.0 2005/05/29 12:01:21 appldev noship $ */
/************************************************************
 * This is a Table Handler Procedure for inserting into
 * pa_plan_rl_formats table. It takes in parameters from
 * the Pa_Plan_RL_Formats_Pvt.Create_Plan_RL_Format procedure.
 * ********************************************************/
 Procedure Insert_Row (
 	P_Resource_List_Id		 IN Number,
 	P_Res_Format_Id			 IN Number,
 	P_Last_Update_Date		 IN Date,
 	P_Last_Updated_By		 IN Number,
 	P_Creation_Date			 IN Date,
 	P_Created_By			 IN Number,
 	P_Last_Update_Login 		 IN Number,
	X_Plan_RL_Format_Id		OUT NOCOPY Number,
	X_Record_Version_Number 	OUT NOCOPY NUMBER );

/************************************************************
 * This is a Table Handler Procedure for Deleting from
 * pa_plan_rl_formats table. It takes in parameters from
 * the Pa_Plan_RL_Formats_Pvt.Delete_Plan_RL_Format procedure.
 * ********************************************************/
 Procedure Delete_Row (
	P_Res_List_Id    		 IN Number Default Null,
	P_Res_Format_Id			 IN Number Default Null,
	P_Plan_RL_Format_Id		 IN Number Default Null );


END Pa_Plan_RL_Formats_Pkg;

 

/
