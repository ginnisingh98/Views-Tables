--------------------------------------------------------
--  DDL for Package PA_PLAN_RL_FORMATS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PLAN_RL_FORMATS_PVT" AUTHID CURRENT_USER as
/* $Header: PARRFTVS.pls 120.0 2005/05/31 02:48:45 appldev noship $ */
/****************************************************
 * Procedure   : Create_Plan_RL_Format
 * Description : This is a Pvt procedure which takes in
 *               parameters from
 *               Pa_Plan_RL_Formats_Pub.Create_Plan_RL_Format
 *               proc.
 *               Details present in the Body.
 ***************************************************/
 Procedure Create_Plan_RL_Format(
	P_Res_List_id		   IN   NUMBER,
	P_Res_Format_Id		   IN   NUMBER,
	X_Plan_RL_Format_Id	   OUT  NOCOPY NUMBER,
	X_Record_Version_Number	   OUT  NOCOPY NUMBER,
	X_Return_Status		   OUT  NOCOPY VARCHAR2,
	X_Msg_Count		   OUT  NOCOPY NUMBER,
	X_Msg_Data		   OUT  NOCOPY VARCHAR2);


/****************************************************
 * Procedure   : Delete_Plan_RL_Format
 * Description : This is a Pvt procedure which takes in
 *               parameters from
 *               Pa_Plan_RL_Formats_Pub.Create_Plan_RL_Format
 *               proc.
 *               Details present in the Body.
 ***************************************************/
Procedure Delete_Plan_RL_Format (
        P_Res_List_Id    	 IN   NUMBER   DEFAULT Null,
	P_Res_Format_Id		 IN   NUMBER   DEFAULT Null,
	P_Plan_RL_Format_Id	 IN   NUMBER   DEFAULT Null,
	X_Return_Status		 OUT  NOCOPY   VARCHAR2,
	X_Msg_Count		 OUT  NOCOPY   NUMBER,
	X_Msg_Data		 OUT  NOCOPY   VARCHAR2);

END Pa_Plan_RL_Formats_Pvt;

 

/
