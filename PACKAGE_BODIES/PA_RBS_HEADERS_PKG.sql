--------------------------------------------------------
--  DDL for Package Body PA_RBS_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RBS_HEADERS_PKG" AS
--$Header: PARBSHTB.pls 120.1 2005/09/26 17:57:03 appldev noship $

/*===============================================================================
   This api creates RBS Header. This is a table handler for PA_RBS_HEADERS table
 ============================================================================*/

-- Procedure            : INSERT_ROW
-- Type                 : Table Handler
-- Purpose              : This API will create new RBS headers.
--                      : This API will be called from following package:
--                      : 1.PA_RBS_HEADER_PVT package,Insert_Header procedure

-- Note                 : This API will make insert into PA_RBS_HEADERS_B and PA_RBS_HEADERS_TL table

-- Assumptions          :

-- Parameters                     Type          Required        Description and Purpose
-- ---------------------------  ------          --------        --------------------------------------------------------
--  P_RbsHeaderId            	 NUMBER           Yes            The value will contain the Rbs Header id which is the unique identifier.
--  P_Name                       VARCHAR2         Yes            The value contain the name of the Rbs header
--  P_Description                VARCHAR2         NO             The description of the Rbs header
--  P_EffectiveFrom             DATE             YES            The start date of the RBS
--  P_EffectiveTo               DATE             NO             The end date of the Rbs.
--  P_BusinessGroupId          NUMBER           YES            The Business Group Id.



PROCEDURE Insert_Row(
                        P_RbsHeaderId        IN Number,
                        P_Name         	     IN Varchar2,
                        P_Description 	     IN Varchar2,
                        P_EffectiveFrom      IN Date,
                        P_EffectiveTo 	     IN Date,
		        P_Use_For_Alloc_Flag IN Varchar2,
                        P_BusinessGroupId    IN Number)
IS
BEGIN

	Insert Into Pa_Rbs_Headers_B(
		Rbs_Header_Id,
		Effective_From_Date,
		Effective_To_Date,
		Business_Group_Id,
		Use_For_Alloc_Flag,
		Creation_Date,
		Created_By,
		Last_Update_Date,
		Last_Updated_By,
		Last_Update_Login,
		Record_Version_Number )
	Values(
		P_RbsHeaderId,
		P_EffectiveFrom,
		P_EffectiveTo,
		P_BusinessGroupId,
		P_Use_For_Alloc_Flag,
		SysDate,
		Fnd_Global.User_Id,
		SysDate,
		Fnd_Global.User_Id,
		Fnd_Global.Login_Id,
		1);

       --MLS changes incorporated.
	Insert Into Pa_Rbs_Headers_TL(
		Rbs_Header_Id,
		Name,
		Description,
		Language,
		Last_Update_Date,
		Last_Updated_By,
		Creation_Date,
		Created_By,
		Last_Update_Login,
		Source_Lang )
	Select
		P_RbsHeaderId,
		P_Name,
		P_Description,
		--UserEnv('LANG'),
		L.Language_Code,
		SysDate,
		Fnd_Global.User_Id,
		SysDate,
		Fnd_Global.User_Id,
		Fnd_Global.Login_Id,
		--L.Language_Code
		UserEnv('LANG')
	From
		Fnd_Languages L
	Where L.Installed_Flag in ('I', 'B')
	And Not Exists
		(Select
			Null
		 From
			Pa_Rbs_Headers_TL T
		 WHere
			T.Rbs_Header_Id = P_RbsHeaderId
		 And 	T.Language      = L.Language_Code);

END Insert_Row;


/*==========================================================================
   This api updates RBS Header. This is a Table Handler.
 ============================================================================*/

-- Procedure            : UPDATE_ROW
-- Type                 : Table Handler
-- Purpose              : This API will be used to update RBS headers.
--                      : This API will be called from following package:
--                      : 1.PA_RBS_HEADER_PVT package,Update_Header procedure

-- Note                 : This API will updates PA_RBS_HEADER_B and PA_RBS_HEADERS_TL table

-- Assumptions          :

-- Parameters                     Type          Required        Description and Purpose
-- ---------------------------  ------          --------        --------------------------------------------------------
--  P_RbsHeaderId            	 NUMBER           Yes            The value will contain the Rbs Header id which is the unique identifier.
--  P_Name                       VARCHAR2         Yes            The value contain the name of the Rbs header
--  P_Description                VARCHAR2         NO             The description of the Rbs header
--  P_EffectiveFrom             DATE             Yes           The start date of the RBS
--  P_EffectiveTo               DATE             NO             The end date of the Rbs.

Procedure Update_Row(
	P_RbsHeaderId          IN Number,
	P_Name                 IN Varchar2,
	P_Description          IN Varchar2,
	P_EffectiveFrom        IN Date,
	P_Use_For_Alloc_Flag   IN Varchar2,
	P_EffectiveTo          IN Date)

Is

Begin

	Update Pa_Rbs_Headers_B
	Set 	Effective_From_Date   = Nvl(P_EffectiveFrom,Effective_From_Date),
	        Effective_To_Date     = P_EffectiveTo,
		Use_For_Alloc_Flag    = P_Use_For_Alloc_Flag,
        	Last_Update_Date      = SysDate,
	        Last_Updated_By       = Fnd_Global.User_Id,
        	Last_Update_Login     = Fnd_Global.Login_Id,
	        Record_Version_Number = Record_Version_Number + 1
	Where
       	 	Rbs_Header_Id         = P_RbsHeaderId;

        --MLS changes incorporated.
	Update Pa_Rbs_Headers_TL
	Set
		Name		  = P_Name,
		Description	  = P_Description,
		Last_update_date  = SysDate,
		Last_updated_by	  = Fnd_Global.User_Id,
		Last_update_login = Fnd_Global.Login_Id,
                Source_Lang        = UserEnv('LANG')
	Where
		Rbs_Header_Id	  = P_RbsHeaderId
        And     UserEnv('LANG') in (Language, Source_Lang);

Exception
	When Others Then
		Raise;

End Update_Row;

procedure ADD_LANGUAGE
is
begin
  delete from Pa_Rbs_Headers_TL T
  where not exists
    (select NULL
    from Pa_Rbs_Headers_b B
    where B.Rbs_Header_Id = T.Rbs_Header_Id
    );

  update Pa_Rbs_Headers_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from Pa_Rbs_Headers_TL b
    where B.Rbs_Header_Id = T.Rbs_Header_Id
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.Rbs_Header_Id,
      T.LANGUAGE
  ) in (select
     SUBT.Rbs_Header_Id,
      SUBT.LANGUAGE
    from Pa_Rbs_Headers_TL SUBB, Pa_Rbs_Headers_TL SUBT
    where SUBB.Rbs_Header_Id = SUBT.Rbs_Header_Id
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into Pa_Rbs_Headers_TL (
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    Rbs_Header_Id,
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
    B.Rbs_Header_Id,
    B.NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from Pa_Rbs_Headers_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from Pa_Rbs_Headers_TL T
    where T.Rbs_Header_Id = B.Rbs_Header_Id
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

END Pa_Rbs_Headers_Pkg;

/
