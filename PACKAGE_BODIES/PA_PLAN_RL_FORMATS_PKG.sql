--------------------------------------------------------
--  DDL for Package Body PA_PLAN_RL_FORMATS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PLAN_RL_FORMATS_PKG" as
/* $Header: PARRFTTB.pls 120.0 2005/05/30 03:13:25 appldev noship $ */
/************************************************************
 * This is a Table Handler Procedure for Inserting into
 * pa_plan_rl_formats table. It takes in parameters from
 * the Pa_Plan_RL_Formats_Pvt.Create_Plan_RL_Format procedure.
 *********************************************************/
 Procedure Insert_Row (
 	P_Resource_List_Id		 IN Number,
 	P_Res_Format_Id			 IN Number,
 	P_Last_Update_Date		 IN Date,
 	P_Last_Updated_By		 IN Number,
 	P_Creation_Date			 IN Date,
 	P_Created_By			 IN Number,
 	P_Last_Update_Login 		 IN Number,
	X_Plan_RL_Format_Id	        OUT NOCOPY Number,
	X_Record_Version_Number 	OUT NOCOPY NUMBER  )

 Is

	Cursor Return_RowId(P_Plan_RL_Format_Ident IN Number) is
  	Select
		RowId
	From
		Pa_Plan_RL_Formats
	Where
		Plan_RL_Format_Id = P_Plan_RL_Format_Ident;

	Cursor Get_ItemId is
	Select
		Pa_Plan_RL_Formats_S.nextval
	From
		Dual;

	l_Plan_RL_Format_id NUMBER := Null;
	l_RowId 	    ROWID  := Null;

 Begin

	-- Get next available id from sequence
	Open Get_ItemId;
	Fetch Get_ItemId Into l_Plan_RL_Format_Id;
	Close Get_ItemId;

	Insert Into Pa_Plan_RL_Formats (
 		Plan_RL_Format_Id ,
	 	Resource_List_Id ,
	 	Res_Format_Id ,
		Record_Version_Number ,
	 	Last_Update_Date ,
	 	Last_Updated_By ,
	 	Creation_Date ,
	 	Created_By ,
	 	Last_Update_Login)
	Values (
		l_Plan_RL_Format_Id ,
	 	P_Resource_List_Id ,
	 	P_Res_Format_Id	,
		1 , -- record_version_number always starts with 1
	 	P_Last_Update_Date ,
		P_Last_Updated_By ,
	 	P_Creation_Date ,
	 	P_Created_By ,
	 	P_Last_Update_Login );

	-- Verify that the row was created
	Open Return_RowId(P_Plan_RL_Format_Ident => l_Plan_RL_Format_Id);
	Fetch Return_RowId Into l_RowId;

	If (Return_RowId%NotFound) Then

		Close Return_RowId;
		Raise No_Data_Found;

	End If;

	Close Return_RowId;
	X_Plan_RL_Format_Id := l_Plan_RL_Format_Id;
	X_Record_Version_Number := 1;

 End Insert_Row;
/********************/

/************************************************************
 * This is a Table Handler Procedure for Deleting from
 * pa_plan_rl_formats table. It takes in parameters from
 * the Pa_Plan_RL_Formats_Pvt.Delete_Plan_RL_Format procedure.
 *********************************************************/
 Procedure Delete_Row (
	P_Res_List_Id    	IN Number Default Null,
	P_Res_Format_Id		IN Number Default Null,
	P_Plan_RL_Format_Id	IN Number Default Null )

 Is

 Begin

	If P_Plan_RL_Format_Id is Null Then

		Delete from Pa_Plan_RL_Formats
		where
			Resource_List_Id = P_Res_List_Id
		and   	Res_Format_Id = P_Res_Format_Id;

	Else

		Delete from Pa_Plan_RL_Formats
		Where
			Plan_RL_Format_Id = P_Plan_RL_Format_Id;

	End If;

 End Delete_Row;
/*******************/

END Pa_Plan_RL_Formats_Pkg ;

/
