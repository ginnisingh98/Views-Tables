--------------------------------------------------------
--  DDL for Package Body MSD_CS_IDEN_LOAD_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_CS_IDEN_LOAD_DATA" as
/* $Header: msdcsidb.pls 115.5 2004/08/26 10:32:54 sudekuma ship $ */

    Procedure load_row (
        p_column_identifier       in  varchar2,
	p_system_flag		  in  varchar2,
        p_description             in  varchar2,
        p_identifier_type         in  varchar2,
        p_user_prompt             in  varchar2,
        p_owner                   in  varchar2
       ) is
    Begin

         Update_row(
            p_column_identifier,
	    p_system_flag      ,
            p_description      ,
            p_identifier_type  ,
            p_user_prompt      ,
            p_owner            );

    Exception
    when no_data_found then
        Insert_row(
            p_column_identifier,
	    p_system_flag      ,
            p_description      ,
            p_identifier_type  ,
            p_user_prompt      ,
            p_owner);
    End;


    Procedure Update_row (
        p_column_identifier       in  varchar2,
	p_system_flag		  in  varchar2,
        p_description             in  varchar2,
        p_identifier_type         in  varchar2,
        p_user_prompt             in  varchar2,
        p_owner                   in  varchar2
       )  is


        l_user              number;
        l_definition_id     number;
    Begin
        if p_owner = 'SEED' then
            l_user  := 1;
        else
            l_user := 0;
        end if;

        update msd_cs_clmn_identifiers set
            identifier_type  = p_identifier_type,
	    system_flag      = p_system_flag,
            last_update_date  = sysdate,
            last_updated_by   = l_user,
            last_update_login = fnd_global.login_id
          where
            column_identifier = p_column_identifier;

      if (sql%notfound) then
        raise no_data_found;
      end if;

      update msd_cs_clmn_identifiers_TL set
        description      = p_description,
        user_prompt      = p_user_prompt,
        LAST_UPDATE_DATE  = sysdate,
        LAST_UPDATED_BY   = l_user,
        LAST_UPDATE_LOGIN = fnd_global.login_id,
        SOURCE_LANG       = userenv('LANG')
      where
          column_identifier = p_column_identifier
      and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

    if (sql%notfound) then

        insert into msd_cs_clmn_identifiers_TL(
           column_identifier,
           description,
           user_prompt,
    	   language,
           source_lang,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date ,
           last_update_login
        )
        Select
           p_column_identifier,
           p_description,
           p_user_prompt,
    	   l.language_code,
	   userenv('LANG'),
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.login_id
        from fnd_languages l
       where l.installed_flag in ('I','B');
/*             and not exists (select null
                     from msd_cs_definitions_TL
                       and rtl.language    = l.language_code );
*/
    end if;

End;

Procedure Insert_row (
        p_column_identifier       in  varchar2,
	p_system_flag		  in  varchar2,
        p_description             in  varchar2,
        p_identifier_type         in  varchar2,
        p_user_prompt             in  varchar2,
        p_owner                   in  varchar2
       ) is


       l_user              number;
       l_definition_id     number;
Begin
        if p_owner = 'SEED' then
            l_user  := 1;
        else
            l_user := 0;
        end if;


        insert into msd_cs_clmn_identifiers(
           column_identifier,
	   system_flag,
           identifier_type,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date ,
           last_update_login
        )
        values
          (
           p_column_identifier,
	   p_system_flag,
           p_identifier_type,
           l_user,
           sysdate,
           l_user,
           sysdate,
           fnd_global.login_id
        );

        insert into msd_cs_clmn_identifiers_TL(
           column_identifier,
           description,
           user_prompt,
    	   language,
           source_lang,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date ,
           last_update_login
        )
        Select
           p_column_identifier,
           p_description,
           p_user_prompt,
    	   l.language_code,
	       userenv('LANG'),
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.login_id
        from fnd_languages l
       where l.installed_flag in ('I','B');
End;

Procedure translate_row (
        p_column_identifier       in  varchar2,
        p_description             in  varchar2,
        p_user_prompt             in  varchar2,
        p_owner                   in  varchar2) is

    l_user number:= 1;
Begin
        if p_owner = 'SEED' then
            l_user  := 1;
        else
            l_user := 0;
        end if;

     update msd_cs_clmn_identifiers_TL set
        description       = p_description,
        user_prompt       = p_user_prompt,
        LAST_UPDATE_DATE  = sysdate,
        LAST_UPDATED_BY   = l_user,
        LAST_UPDATE_LOGIN = fnd_global.login_id,
        SOURCE_LANG       = userenv('LANG')
      where
          column_identifier =   p_column_identifier
      and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

End;

Procedure ADD_LANGUAGE
is
begin
  delete from msd_cs_clmn_identifiers_TL T
  where not exists
    (select NULL
    from msd_cs_clmn_identifiers B
    where B.column_identifier = T.column_identifier
    );

  update msd_cs_clmn_identifiers_TL T set (
      DESCRIPTION,user_prompt
    ) = (select
      B.DESCRIPTION, b.user_prompt
    from msd_cs_clmn_identifiers_TL B
    where B.column_identifier = T.column_identifier
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.column_identifier,
      T.LANGUAGE
  ) in (select
      SUBT.column_identifier,
      SUBT.LANGUAGE
    from msd_cs_clmn_identifiers_TL SUBB, msd_cs_clmn_identifiers_TL SUBT
    where SUBB.column_identifier = SUBT.column_identifier
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
         OR SUBB.USER_PROMPT <> SUBT.USER_PROMPT -- sudekuma bug # 3845894
  ));

  insert into msd_cs_clmn_identifiers_TL (
    column_identifier,
    description,
    user_prompt,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    b.column_identifier,
    b.description,
    b.user_prompt,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.REQUEST_ID,
    B.PROGRAM_APPLICATION_ID,
    B.PROGRAM_ID,
    B.PROGRAM_UPDATE_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from msd_cs_clmn_identifiers_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from msd_cs_clmn_identifiers_TL T
    where T.column_identifier = B.column_identifier
    and T.LANGUAGE = L.LANGUAGE_CODE);

End ADD_LANGUAGE;


End;

/
