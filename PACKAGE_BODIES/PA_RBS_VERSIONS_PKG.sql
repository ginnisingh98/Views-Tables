--------------------------------------------------------
--  DDL for Package Body PA_RBS_VERSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RBS_VERSIONS_PKG" AS
--$Header: PARBSVTB.pls 120.2 2005/09/28 18:10:11 ramurthy noship $




PROCEDURE Insert_Row(
	P_Version_Number		IN	   Number,
	P_Rbs_Header_Id			IN	   Number,
	P_Record_Version_Number		IN	   Number,
	P_Name				IN	   Varchar2,
	P_Description			IN	   Varchar2,
	P_Version_Start_Date		IN	   Date,
	P_Version_End_Date		IN	   Date,
	P_Job_Group_Id			IN	   Number,
	P_Rule_Based_Flag		IN	   Varchar2,
	P_Validated_Flag		IN	   Varchar2,
	P_Status_Code			IN	   Varchar2,
	P_Creation_Date			IN	   Date,
	P_Created_By			IN	   Number,
	P_Last_Update_Date		IN	   Date,
	P_Last_Updated_By		IN	   Number,
	P_Last_Update_Login		IN	   Number,
	X_Record_Version_Number		OUT NOCOPY Number,
	X_Rbs_Version_Id		OUT NOCOPY Number,
	X_Error_Msg_Data		OUT NOCOPY Varchar2 )

Is

       	UNABLE_TO_CREATE_REC Exception;
       	l_RowId           RowId  := Null;

       	Cursor Return_RowId(P_Id IN Number) is
       	Select
       		RowId
       	From
       		Pa_RBS_Versions_B
       	Where
       		RBS_Version_Id = P_Id;

	Cursor GetNextId is
	Select
		Pa_Rbs_Versions_S.NextVal
	From
		Dual;


Begin

	If P_Record_Version_Number Is Not Null Then

		X_Record_Version_Number := P_Record_Version_Number;

	Else

		X_Record_Version_Number := 1;

	End If;

	Open GetNextId;
	Fetch GetNextId Into X_Rbs_Version_Id;
	Close GetNextId;

	Insert Into Pa_Rbs_Versions_B (
		Rbs_Version_Id,
		Version_Number,
		Rbs_Header_Id,
		Version_Start_Date,
		Version_End_Date,
		Job_Group_Id,
		Rule_Based_Flag,
		Validated_Flag,
		Status_Code,
		Last_Update_Date,
		Last_Updated_By,
		Creation_Date,
		Created_By,
		Last_Update_Login,
		Record_Version_Number )
	Values (
                X_Rbs_Version_Id,
                P_Version_Number,
                P_Rbs_Header_Id,
                P_Version_Start_Date,
                P_Version_End_Date,
                P_Job_Group_Id,
                P_Rule_Based_Flag,
                P_Validated_Flag,
                P_Status_Code,
                P_Last_Update_Date,
                P_Last_Updated_By,
                P_Creation_Date,
                P_Created_By,
                P_Last_Update_Login,
                X_Record_Version_Number );

  	Insert Into Pa_Rbs_Versions_TL (
		Rbs_Version_Id,
		Name,
		Description,
		Creation_Date,
		Created_By,
		Last_Update_Date,
		Last_Updated_By,
		Last_Update_Login,
		Language,
		Source_Lang )
	select
		X_Rbs_Version_Id,
		P_Name,
		P_Description,
		P_Creation_Date,
		P_Created_By,
		P_Last_Update_Date,
		P_Last_Updated_By,
		P_Last_Update_Login,
		L.Language_Code,
		UserEnv('LANG')
  	From
		Fnd_Languages L
  	Where
		L.Installed_Flag in ('I', 'B')
  	And Not Exists
		(select
			Null
		 From
			Pa_Rbs_Versions_TL T
		 Where
			T.Rbs_Version_Id = X_Rbs_Version_Id
		and 	T.Language = L.Language_Code);

        Open Return_RowId (P_Id => X_RBS_Version_Id);
        Fetch Return_RowId Into l_RowId;

        If Return_RowId%NotFound Then

                Close Return_RowId;
                X_Record_Version_Number := Null;
                X_RBS_Version_Id := Null;
                Raise UNABLE_TO_CREATE_REC;

        End If;
        Close Return_RowId;

Exception
        When UNABLE_TO_CREATE_REC Then
                -- System Error for sys admin information needed
                X_Error_Msg_Data := 'PA_UNABLE_TO_CREATE_REC';

		-- 4537865  RESET OUT PARAMS
	        X_Record_Version_Number := NULL ;
	        X_Rbs_Version_Id        := NULL ;

        When others Then

                -- 4537865  RESET OUT PARAMS
                X_Record_Version_Number := NULL ;
                X_Rbs_Version_Id        := NULL ;
                X_Error_Msg_Data        := SQLERRM ;

                Raise;

End Insert_Row;

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
	X_Record_Version_Number		OUT NOCOPY	   Number, -- 4537865
	X_Error_Msg_Data		OUT NOCOPY Varchar2 )

Is

	REC_VER_NUM_MISMATCH Exception;

Begin

	Update Pa_RBS_Versions_B
	Set Version_Start_Date	  = P_Version_Start_Date,
	    Job_Group_Id	  = P_Job_Group_Id,
	    Record_Version_Number = Record_Version_Number + 1,
	    Last_Update_Date	  = P_Last_Update_Date,
	    Last_Updated_By	  = P_Last_Updated_By,
	    Last_Update_Login	  = P_Last_Update_Login
	Where
		Rbs_Version_Id 	      = P_RBS_Version_Id
	And	Record_Version_Number = P_Record_Version_Number;

	If Sql%NotFound Then
		Raise REC_VER_NUM_MISMATCH;
	End If;

	Update Pa_Rbs_Versions_TL
	Set Name               = P_Name,
	    Description        = P_Description,
	    Last_Update_Date   = P_Last_Update_Date,
	    Last_Updated_By    = P_Last_Updated_By,
	    Last_Update_Login  = P_Last_Update_Login,
	    Source_Lang        = UserEnv('LANG')
	Where
		Rbs_Version_Id = P_Rbs_Version_Id
	And	UserEnv('LANG') in (Language, Source_Lang);

	If Sql%NotFound Then
                Raise REC_VER_NUM_MISMATCH;
        End If;

	X_Record_Version_Number := P_Record_Version_Number + 1;

Exception
	When REC_VER_NUM_MISMATCH Then
		X_Error_Msg_Data := 'PA_RECORD_ALREADY_UPDATED';

		-- 4537865 RESET OUT PARAMS
		X_Record_Version_Number := NULL ;

	When Others Then
		-- 4537865 RESET OUT PARAMS
                X_Record_Version_Number := NULL ;
		X_Error_Msg_Data := SQLERRM ;

		Raise;

End Update_Row;


Procedure Delete_Row (
	P_RBS_Version_Id        IN         Number,
	P_Record_Version_Number IN         Number,
	X_Error_Msg_Data        OUT NOCOPY Varchar2)

Is

	REC_VER_NUM_MISMATCH Exception;

Begin

	Delete
	From
		Pa_Rbs_Versions_B
	Where
		RBS_Version_Id = P_RBS_Version_Id
	And	Record_Version_Number = P_Record_Version_Number;

	If Sql%NotFound Then
		Raise REC_VER_NUM_MISMATCH;
        End If;


        Delete
        From
                Pa_Rbs_Versions_TL
        Where
                Rbs_Version_Id = P_Rbs_Version_Id;

Exception
        When REC_VER_NUM_MISMATCH Then
                X_Error_Msg_Data := 'PA_RECORD_ALREADY_UPDATED';
	When Others Then
	 -- 4537865 RESET OUT PARAMS
	X_Error_Msg_Data := SQLERRM ;
	Raise;

End Delete_Row;

procedure ADD_LANGUAGE
is
begin
  delete from pa_rbs_versions_tl T
  where not exists
    (select NULL
    from pa_rbs_versions_b B
    where B.RBS_VERSION_ID = T.RBS_VERSION_ID
    );

  update pa_rbs_versions_tl T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from pa_rbs_versions_tl b
    where B.RBS_VERSION_ID = T.RBS_VERSION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RBS_VERSION_ID,
      T.LANGUAGE
  ) in (select
     SUBT.RBS_VERSION_ID,
      SUBT.LANGUAGE
    from pa_rbs_versions_tl SUBB, pa_rbs_versions_tl SUBT
    where SUBB.RBS_VERSION_ID = SUBT.RBS_VERSION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into pa_rbs_versions_tl (
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    RBS_VERSION_ID,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
 ) select
    B.LAST_UPDATE_LOGIN,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.RBS_VERSION_ID,
    B.NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from pa_rbs_versions_tl B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from pa_rbs_versions_tl T
    where T.RBS_VERSION_ID = B.RBS_VERSION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

END PA_RBS_VERSIONS_PKG;

/
