--------------------------------------------------------
--  DDL for Package Body MSD_CS_DEFN_LOAD_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_CS_DEFN_LOAD_DATA" as
/* $Header: msdcsdfb.pls 120.0 2005/05/25 19:27:52 appldev noship $ */
    Procedure load_row (
        p_name                    in  varchar2,
        p_description             in  varchar2,
        p_plan_type             in varchar2,
        p_liability_user_flag   in varchar2,
        p_cs_classification       in  varchar2,
        p_cs_type                 in  varchar2,
        p_strict_flag             in  varchar2,
        p_system_flag             in  varchar2,
        p_multiple_stream_flag    in  varchar2,
        p_planning_server_view_name   in  varchar2,
        p_planning_server_view_name_ds   in  varchar2,
        p_stripe_flag                 in  varchar2,
        p_source_view_name            in  varchar2,
        p_collection_program_name     in  varchar2,
        p_collect_addtl_where_clause  in  varchar2,
        p_pull_addtl_where_clause     in  varchar2,
        p_valid_flag                  in  varchar2,
        p_stream_editable_flag        in  varchar2 ,
        p_aggregation_allowed_flag    in  varchar2 ,
        p_allocation_allowed_flag     in  varchar2 ,
        p_dependent_data_flag         in  varchar2,
        p_dependent_demand_code       in  varchar2,
        p_measurement_type            in  varchar2 ,
        p_enable_flag                 in  varchar2 ,
	p_cs_lov_view_name	      in  varchar2,
	p_lowest_level_flag	      in  varchar2,
        p_owner                       in  varchar2,
        p_last_update_date            in  varchar2,
        p_custom_mode                 in  varchar2) is
    Begin

         DEFN_Update_row(
            p_cs_definition_id           => null                         ,
            p_name                       => p_name                       ,
            p_plan_type             => p_plan_type ,
            p_liability_user_flag =>  p_liability_user_flag ,
            p_description                => p_description                ,
            p_cs_classification          => p_cs_classification          ,
            p_cs_type                    => p_cs_type                    ,
            p_strict_flag                => p_strict_flag                ,
            p_system_flag                => p_system_flag                ,
            p_multiple_stream_flag       => p_multiple_stream_flag       ,
            p_planning_server_view_name  => p_planning_server_view_name  ,
            p_planning_server_view_name_ds => p_planning_server_view_name_ds,
            p_stripe_flag                => p_stripe_flag,
            p_source_view_name           => p_source_view_name           ,
            p_collection_program_name    => p_collection_program_name    ,
            p_collect_addtl_where_clause => p_collect_addtl_where_clause ,
            p_pull_addtl_where_clause    => p_pull_addtl_where_clause    ,
            p_valid_flag                 => p_valid_flag                 ,
            p_stream_editable_flag       => p_stream_editable_flag       ,
            p_aggregation_allowed_flag   => p_aggregation_allowed_flag   ,
            p_allocation_allowed_flag    => p_allocation_allowed_flag    ,
            p_dependent_data_flag        => p_dependent_data_flag        ,
            p_dependent_demand_code      => p_dependent_demand_code      ,
            p_enable_flag                => p_enable_flag                ,
	    p_cs_lov_view_name	         => p_cs_lov_view_name		 ,
	    p_lowest_level_flag	         => p_lowest_level_flag		 ,
            p_measurement_type           => p_measurement_type           ,
            p_owner                      => p_owner                      ,
            p_last_update_date           => p_last_update_date           ,
            p_custom_mode                => p_custom_mode );
    Exception
    when no_data_found then
        DEFN_Insert_row(
             p_name                       => p_name                       ,
             p_description                => p_description                ,
             p_plan_type                   =>p_plan_type ,
             p_liability_user_flag   =>  p_liability_user_flag ,
             p_cs_classification          => p_cs_classification          ,
             p_cs_type                    => p_cs_type                    ,
             p_strict_flag                => p_strict_flag                ,
             p_system_flag                => p_system_flag                ,
             p_multiple_stream_flag       => p_multiple_stream_flag       ,
             p_planning_server_view_name  => p_planning_server_view_name  ,
             p_planning_server_view_name_ds => p_planning_server_view_name_ds,
             p_stripe_flag                => p_stripe_flag                ,
             p_source_view_name           => p_source_view_name           ,
             p_collection_program_name    => p_collection_program_name    ,
             p_collect_addtl_where_clause => p_collect_addtl_where_clause ,
             p_pull_addtl_where_clause    => p_pull_addtl_where_clause    ,
             p_valid_flag                 => p_valid_flag                 ,
             p_stream_editable_flag       => p_stream_editable_flag       ,
             p_aggregation_allowed_flag   => p_aggregation_allowed_flag   ,
             p_allocation_allowed_flag    => p_allocation_allowed_flag    ,
             p_dependent_data_flag        => p_dependent_data_flag        ,
             p_dependent_demand_code      => p_dependent_demand_code      ,
             p_enable_flag                => p_enable_flag                ,
             p_cs_lov_view_name	          => p_cs_lov_view_name		  ,
             p_lowest_level_flag	  => p_lowest_level_flag	  ,
             p_measurement_type           => p_measurement_type           ,
             p_owner                      => p_owner                      ,
             p_last_update_date           => p_last_update_date           );

    End;


Procedure DEFN_UPDATE_row (
        p_cs_definition_id        in  number,
        p_name                    in  varchar2,
        p_plan_type              in varchar2 ,
        p_liability_user_flag  in varchar2 ,
        p_description             in  varchar2,
        p_cs_classification       in  varchar2,
        p_cs_type                 in  varchar2,
        p_strict_flag             in  varchar2,
        p_system_flag             in  varchar2,
        p_multiple_stream_flag    in  varchar2,
        p_planning_server_view_name   in  varchar2,
        p_planning_server_view_name_ds   in  varchar2,
        p_stripe_flag                 in varchar2,
        p_source_view_name            in  varchar2,
        p_collection_program_name     in  varchar2,
        p_collect_addtl_where_clause  in  varchar2,
        p_pull_addtl_where_clause     in  varchar2,
        p_valid_flag                  in  varchar2,
        p_stream_editable_flag        in  varchar2,
        p_aggregation_allowed_flag    in  varchar2,
        p_allocation_allowed_flag     in  varchar2,
        p_dependent_data_flag         in  varchar2,
        p_dependent_demand_code       in  varchar2,
        p_enable_flag                 in  varchar2,
        p_cs_lov_view_name	      in  varchar2,
        p_lowest_level_flag	      in  varchar2,
        p_measurement_type            in  varchar2,
        p_owner                       in  varchar2,
        p_last_update_date            in  varchar2,
        p_custom_mode                 in  varchar2) is


        l_user              number; -- entity owner in file
        l_definition_id     number;

        f_ludate            date;    -- entity update date in file
        db_luby             number;  -- entity owner in db
        db_ludate           date;    -- entity update date in db


    Begin

        if p_owner = 'SEED' then
            l_user  := 1;
        else
            l_user := 0;
        end if;

        -- Translate char last_update_date to date
        f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);

        if p_cs_definition_id is null then
          select cs_definition_id, last_update_date, last_updated_by
            into l_definition_id, db_ludate, db_luby
            from msd_cs_definitions
            where name = p_name;
        end if;

        if ((p_custom_mode = 'FORCE') or
              ((l_user = 0) and (db_luby = 1)) or
              ((l_user = db_luby) and (f_ludate > db_ludate))) then

        update msd_cs_definitions set
             description        = p_description,
             cs_classification  = p_cs_classification,
             plan_type = p_plan_type ,
             liability_user_flag= p_liability_user_flag,
             cs_type            = p_cs_type,
             strict_flag        = p_strict_flag,
             system_flag        = p_system_flag,
             multiple_stream_flag = p_multiple_stream_flag,
             planning_server_view_name  = p_planning_server_view_name,
             planning_server_view_name_ds  = p_planning_server_view_name_ds,
             stripe_flag                = p_stripe_flag,
             source_view_name           = p_source_view_name,
             collection_program_name    = p_collection_program_name,
             collect_addtl_where_clause = p_collect_addtl_where_clause,
             pull_addtl_where_clause    = p_pull_addtl_where_clause,
             valid_flag                 = p_valid_flag,
             stream_editable_flag       = p_stream_editable_flag,
             aggregation_allowed_flag   = p_aggregation_allowed_flag,
             allocation_allowed_flag    = p_allocation_allowed_flag,
             dependent_data_flag        = p_dependent_data_flag,
             dependent_demand_code      = p_dependent_demand_code,
             measurement_type           = p_measurement_type,
             enable_flag                = p_enable_flag,
             cs_lov_view_name	        = p_cs_lov_view_name,
             lowest_level_flag          = p_lowest_level_flag,
        --     creation_date              = p_last_update_date,
        --     created_by                 = l_user,
             last_update_date           = f_ludate,
             last_updated_by            = l_user,
             last_update_login          = fnd_global.login_id
          where
            cs_definition_id = l_definition_id;

          update msd_cs_definitions_TL set
           description       = p_description,
           LAST_UPDATE_DATE  = f_ludate,
           LAST_UPDATED_BY   = l_user,
           LAST_UPDATE_LOGIN = fnd_global.login_id,
           SOURCE_LANG       = userenv('LANG')
          where
           cs_definition_id  = l_definition_id
          and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

      else

        update msd_cs_definitions set
             cs_classification  = p_cs_classification,
             cs_type            = p_cs_type,
             plan_type = p_plan_type ,
             liability_user_flag= p_liability_user_flag,
             strict_flag        = p_strict_flag,
             system_flag        = p_system_flag,
             multiple_stream_flag = p_multiple_stream_flag,
             planning_server_view_name  = p_planning_server_view_name,
             planning_server_view_name_ds  = p_planning_server_view_name_ds,
             stripe_flag                = p_stripe_flag,
             source_view_name           = p_source_view_name,
             collection_program_name    = p_collection_program_name,
             collect_addtl_where_clause = p_collect_addtl_where_clause,
             pull_addtl_where_clause    = p_pull_addtl_where_clause,
             valid_flag                 = p_valid_flag,
          --   stream_editable_flag       = p_stream_editable_flag,
          --   aggregation_allowed_flag   = p_aggregation_allowed_flag,
          --   allocation_allowed_flag    = p_allocation_allowed_flag,
             dependent_data_flag        = p_dependent_data_flag,
             dependent_demand_code      = p_dependent_demand_code,
             measurement_type           = p_measurement_type,
             enable_flag                = p_enable_flag,
	     cs_lov_view_name	        = p_cs_lov_view_name,
          --   lowest_level_flag          = p_lowest_level_flag,
          --   creation_date              = f_ludate,
          --   created_by                 = l_user,
             last_update_date           = f_ludate,
             last_updated_by            = l_user,
             last_update_login          = fnd_global.login_id
          where
            cs_definition_id = l_definition_id;

      end if;


      if (sql%notfound) then
        raise no_data_found;
      end if;


    if (sql%notfound) then

        select cs_definition_id into l_definition_id
        from msd_cs_definitions where name = p_name;

        insert into msd_cs_definitions_TL(
           cs_definition_id,
           description,
            language,
           source_lang,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date ,
           last_update_login
        )
        Select
           l_definition_id,
           p_description,
    	   l.language_code,
	   userenv('LANG'),
           l_user,
           f_ludate,
           fnd_global.user_id,
           f_ludate,
           fnd_global.login_id
        from fnd_languages l
       where l.installed_flag in ('I','B');
/*             and not exists (select null
                     from msd_cs_definitions_TL
                       and rtl.language    = l.language_code );
*/
    end if;

End;

Procedure DEFN_Insert_row (
        p_name                    in  varchar2,
        p_description             in  varchar2,
        p_plan_type  in varchar2 ,
        p_liability_user_flag  in varchar2,
        p_cs_classification       in  varchar2,
        p_cs_type                 in  varchar2,
        p_strict_flag             in  varchar2,
        p_system_flag             in  varchar2,
        p_multiple_stream_flag    in  varchar2,
        p_planning_server_view_name   in  varchar2,
        p_planning_server_view_name_ds   in  varchar2,
        p_stripe_flag                 in varchar2,
        p_source_view_name            in  varchar2,
        p_collection_program_name     in  varchar2,
        p_collect_addtl_where_clause  in  varchar2,
        p_pull_addtl_where_clause     in  varchar2,
        p_valid_flag                  in  varchar2,
        p_stream_editable_flag        in  varchar2,
        p_aggregation_allowed_flag    in  varchar2,
        p_allocation_allowed_flag     in  varchar2,
        p_dependent_data_flag         in  varchar2,
        p_dependent_demand_code       in  varchar2,
        p_enable_flag                 in  varchar2,
        p_cs_lov_view_name	      in  varchar2,
        p_lowest_level_flag	      in  varchar2,
        p_measurement_type            in  varchar2,
        p_owner                       in  varchar2,
        p_last_update_date            in  varchar2) is



        l_user              number;
        l_definition_id     number;
        f_ludate            date;    -- entity update date in file

    Begin

        if p_owner = 'SEED' then
            l_user  := 1;
        else
            l_user := 0;
        end if;

        -- Translate char last_update_date to date
        f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);

        select msd_cs_definitions_s.nextval into l_definition_id from dual;

        insert into msd_cs_definitions
            (
             cs_definition_id,
             name,
             description,
             plan_type ,
             liability_user_flag,
             cs_classification,
             cs_type,
             lowest_level_flag,
             strict_flag,
             system_flag,
             local_stream_flag,
             multiple_stream_flag,
             planning_server_view_name,
             planning_server_view_name_ds,
             stripe_flag,
             source_view_name,
             collection_program_name,
             collect_addtl_where_clause,
             pull_addtl_where_clause,
             valid_flag,
/* New Fields */
             stream_editable_flag       ,
             aggregation_allowed_flag   ,
             allocation_allowed_flag    ,
             dependent_data_flag        ,
             dependent_demand_code      ,
             measurement_type           ,
             enable_flag                ,
             cs_lov_view_name	        ,
/* */
             creation_date,
             created_by,
             last_update_date,
             last_updated_by,
             last_update_login
          )
          values
          (
             l_definition_id,
             p_name,
             p_description,
             p_plan_type,
             p_liability_user_flag,
             p_cs_classification,
             p_cs_type,

/** Replaced 'N' with p_lowest_level_flag for Allocation Floor,  **/
             p_lowest_level_flag,
             p_strict_flag,
             p_system_flag,
            'N',
             p_multiple_stream_flag,
             p_planning_server_view_name,
             p_planning_server_view_name_ds,
             p_stripe_flag,
             p_source_view_name,
             p_collection_program_name,
             p_collect_addtl_where_clause,
             p_pull_addtl_where_clause,
             p_valid_flag,
/* New Fields */
             p_stream_editable_flag       ,
             p_aggregation_allowed_flag   ,
             p_allocation_allowed_flag    ,
             p_dependent_data_flag        ,
             p_dependent_demand_code      ,
             p_measurement_type           ,
             p_enable_flag                ,
	     p_cs_lov_view_name	        ,
/* */
             f_ludate,
             l_user,
             f_ludate,
             l_user,
             fnd_global.login_id
          );

        insert into msd_cs_definitions_TL(
           cs_definition_id,
           description,
    	   language,
	       source_lang,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date ,
           last_update_login
        )
        Select
           l_definition_id,
           p_description,
           l.language_code,
           userenv('LANG'),
           fnd_global.user_id,
           f_ludate,
           fnd_global.user_id,
           f_ludate,
           fnd_global.login_id
        from fnd_languages l
       where l.installed_flag in ('I','B');
End;

Procedure translate_row (
        p_name                    in  varchar2,
        p_description             in  varchar2,
        p_owner                   in  varchar2) is

    l_user number:= 1;
Begin

        if p_owner = 'SEED' then
            l_user  := 1;
        else
            l_user := 0;
        end if;

     update msd_cs_definitions_TL set
        description       = p_description,
        LAST_UPDATE_DATE  = sysdate,
        LAST_UPDATED_BY   = l_user,
        LAST_UPDATE_LOGIN = fnd_global.login_id,
        SOURCE_LANG       = userenv('LANG')
      where
          cs_definition_id    =   (select cs_definition_id from msd_cs_definitions where name = p_name)
      and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

End;

Procedure ADD_LANGUAGE
is
begin
  delete from MSD_CS_DEFINITIONS_TL T
  where not exists
    (select NULL
    from MSD_CS_DEFINITIONS B
    where B.CS_DEFINITION_ID = T.CS_DEFINITION_ID
    );

  update MSD_CS_DEFINITIONS_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from MSD_CS_DEFINITIONS_TL B
    where B.CS_DEFINITION_ID = T.CS_DEFINITION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CS_DEFINITION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CS_DEFINITION_ID,
      SUBT.LANGUAGE
    from MSD_CS_DEFINITIONS_TL SUBB, MSD_CS_DEFINITIONS_TL SUBT
    where SUBB.CS_DEFINITION_ID = SUBT.CS_DEFINITION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into MSD_CS_DEFINITIONS_TL (
    CS_DEFINITION_ID,
    DESCRIPTION,
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
    B.CS_DEFINITION_ID,
    B.DESCRIPTION,
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
  from MSD_CS_DEFINITIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from MSD_CS_DEFINITIONS_TL T
    where T.CS_DEFINITION_ID = B.CS_DEFINITION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
End ADD_LANGUAGE;

End;

/
