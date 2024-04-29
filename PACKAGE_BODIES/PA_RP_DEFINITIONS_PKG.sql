--------------------------------------------------------
--  DDL for Package Body PA_RP_DEFINITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RP_DEFINITIONS_PKG" AS
/*$Header: PARPDFKB.pls 120.0.12010000.1 2010/03/25 07:09:36 vgovvala noship $*/

/*===============================================================================
   This api creates Reporting pack definition. This is a table handler for PA_RP_DEFINITIONS table
 ============================================================================*/

-- Procedure            : INSERT_ROW
-- Type                 : Table Handler
-- Purpose              : This API will create new Reporting pack definition.

-- Note                 : This API will make insert into PA_RP_DEFINITIONS_B and PA_RP_DEFINITIONS_TL table
PROCEDURE Insert_Row(
                        P_RP_ID                IN  NUMBER,
						P_RP_NAME              IN  VARCHAR2,
						P_EMAIL_TITLE          IN  VARCHAR2,
						P_EMAIL_BODY           IN  VARCHAR2,
						P_DESCRIPTIONS         IN  VARCHAR2,
						P_RP_TYPE_ID            IN NUMBER,
						P_DT_PROCESS_DATE       IN DATE,
						P_RP_FILE_ID            IN NUMBER,
						P_TEMPLATE_START_DATE   IN DATE,
						P_TEMPLATE_END_DATE     IN DATE,
						P_OBSOLETE_FLAG         IN VARCHAR2 )
IS
BEGIN

	Insert Into PA_RP_DEFINITIONS_B(
		RP_ID                 ,
		RP_TYPE_ID            ,
		DT_PROCESS_DATE       ,
		RP_FILE_ID            ,
		OBJECT_VERSION_NUMBER ,
		TEMPLATE_START_DATE   ,
		TEMPLATE_END_DATE     ,
		OBSOLETE_FLAG         ,
		CREATION_DATE         ,
		LAST_UPDATE_DATE      ,
		LAST_UPDATED_BY       ,
		CREATED_BY            ,
		LAST_UPDATE_LOGIN     )
	Values(
		P_RP_ID                 ,
		P_RP_TYPE_ID            ,
		P_DT_PROCESS_DATE       ,
		P_RP_FILE_ID            ,
		1                       ,
		P_TEMPLATE_START_DATE   ,
		P_TEMPLATE_END_DATE     ,
		P_OBSOLETE_FLAG         ,
		SysDate        			,
		SysDate      			,
		Fnd_Global.User_Id      ,
		Fnd_Global.User_Id      ,
		Fnd_Global.Login_Id     );

       --MLS changes incorporated.
	Insert Into PA_RP_DEFINITIONS_TL(
		RP_ID             ,
		RP_NAME           ,
		EMAIL_TITLE       ,
		EMAIL_BODY        ,
		DESCRIPTIONS      ,
		LANGUAGE          ,
		SOURCE_LANG       ,
		CREATION_DATE     ,
		CREATED_BY        ,
		LAST_UPDATE_DATE  ,
		LAST_UPDATED_BY   ,
		LAST_UPDATE_LOGIN )
	Select
		P_RP_ID,
		P_RP_NAME,
		P_EMAIL_TITLE,
		P_EMAIL_BODY,
		P_DESCRIPTIONS,
		L.Language_Code,
		UserEnv('LANG'),
		SysDate,
		Fnd_Global.User_Id,
		SysDate,
		Fnd_Global.User_Id,
		Fnd_Global.Login_Id
	From
		Fnd_Languages L
	Where L.Installed_Flag in ('I', 'B')
	And Not Exists
		(Select
			Null
		 From
			PA_RP_DEFINITIONS_TL T
		 WHere
			 T.RP_ID = RP_ID
		 And T.Language = L.Language_Code);

END Insert_Row;


/*==========================================================================
   This api updates RBS Header. This is a Table Handler.
 ============================================================================*/

-- Procedure            : UPDATE_ROW
-- Type                 : Table Handler
-- Purpose              : This API will be used to update Reporting pack definition.
-- Note                 : This API will updates PA_RP_DEFINITIONS_B and PA_RP_DEFINITIONS_TL table

Procedure Update_Row(
						P_RP_ID                IN  NUMBER,
						P_RP_NAME              IN  VARCHAR2,
						P_EMAIL_TITLE          IN  VARCHAR2,
						P_EMAIL_BODY           IN  VARCHAR2,
						P_DESCRIPTIONS         IN  VARCHAR2,
						P_RP_TYPE_ID            IN NUMBER,
						P_DT_PROCESS_DATE       IN DATE,
						P_RP_FILE_ID            IN NUMBER,
						P_TEMPLATE_START_DATE   IN DATE,
						P_TEMPLATE_END_DATE     IN DATE,
						P_OBSOLETE_FLAG         IN VARCHAR2 )

Is

Begin

	Update PA_RP_DEFINITIONS_B
	Set 	RP_TYPE_ID   = P_RP_TYPE_ID,
	        DT_PROCESS_DATE     = P_DT_PROCESS_DATE,
			RP_FILE_ID    = P_RP_FILE_ID,
        	TEMPLATE_START_DATE = P_TEMPLATE_START_DATE,
	        TEMPLATE_END_DATE = P_TEMPLATE_END_DATE,
        	OBSOLETE_FLAG = P_OBSOLETE_FLAG,
        	LAST_UPDATE_DATE = SysDate,
        	LAST_UPDATED_BY = Fnd_Global.User_Id,
        	LAST_UPDATE_LOGIN = Fnd_Global.Login_Id,
	        OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
	Where
       	 	RP_ID         = P_RP_ID;

        --MLS changes incorporated.
	Update PA_RP_DEFINITIONS_TL
	Set
		RP_NAME		  = P_RP_NAME,
		EMAIL_TITLE	  = P_EMAIL_TITLE,
		EMAIL_BODY    = P_EMAIL_BODY,
		DESCRIPTIONS  = P_DESCRIPTIONS,
		Last_update_date  = SysDate,
		Last_updated_by	  = Fnd_Global.User_Id,
		Last_update_login = Fnd_Global.Login_Id,
        Source_Lang        = UserEnv('LANG')
	Where
		RP_ID	  = P_RP_ID
        And     UserEnv('LANG') in (Language, Source_Lang);

Exception
	When Others Then
		Raise;

End Update_Row;

procedure ADD_LANGUAGE
is
begin
  delete from PA_RP_DEFINITIONS_TL T
  where not exists
    (select NULL
    from PA_RP_DEFINITIONS_B B
    where B.RP_ID = T.RP_ID
    );

  update PA_RP_DEFINITIONS_TL T set (
      RP_NAME,
      DESCRIPTIONS
    ) = (select
      B.RP_NAME,
      B.DESCRIPTIONS
    from PA_RP_DEFINITIONS_TL b
    where B.RP_ID = T.RP_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RP_ID,
      T.LANGUAGE
  ) in (select
     SUBT.RP_ID,
      SUBT.LANGUAGE
    from PA_RP_DEFINITIONS_TL SUBB, PA_RP_DEFINITIONS_TL SUBT
    where SUBB.RP_ID = SUBT.RP_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.RP_NAME <> SUBT.RP_NAME
      or SUBB.DESCRIPTIONS <> SUBT.DESCRIPTIONS
      or (SUBB.DESCRIPTIONS is null and SUBT.DESCRIPTIONS is not null)
      or (SUBB.DESCRIPTIONS is not null and SUBT.DESCRIPTIONS is null)
  ));

  insert into PA_RP_DEFINITIONS_TL (
    	RP_ID             ,
		RP_NAME           ,
		EMAIL_TITLE       ,
		EMAIL_BODY        ,
		DESCRIPTIONS      ,
		LANGUAGE          ,
		SOURCE_LANG       ,
		CREATION_DATE     ,
		CREATED_BY        ,
		LAST_UPDATE_DATE  ,
		LAST_UPDATED_BY   ,
		LAST_UPDATE_LOGIN )
 select
    	B.RP_ID             ,
		B.RP_NAME           ,
		B.EMAIL_TITLE       ,
		B.EMAIL_BODY        ,
		B.DESCRIPTIONS      ,
		B.LANGUAGE          ,
		B.SOURCE_LANG       ,
		B.CREATION_DATE     ,
		B.CREATED_BY        ,
		B.LAST_UPDATE_DATE  ,
		B.LAST_UPDATED_BY   ,
		B.LAST_UPDATE_LOGIN
  from PA_RP_DEFINITIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PA_RP_DEFINITIONS_TL T
    where T.RP_ID = B.RP_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

end ADD_LANGUAGE;

END PA_RP_DEFINITIONS_PKG;

/
