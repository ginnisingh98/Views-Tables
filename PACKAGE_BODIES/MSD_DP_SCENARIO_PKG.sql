--------------------------------------------------------
--  DDL for Package Body MSD_DP_SCENARIO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DP_SCENARIO_PKG" AS
/* $Header: msddpscb.pls 120.1 2006/03/31 07:13:26 brampall noship $ */

/* Public Procedures */

PROCEDURE LOAD_ROW(P_DEMAND_PLAN_NAME            in varchar2,
                           P_SCENARIO_NAME               in varchar2,
                           P_OWNER                       in varchar2,
                           P_DESCRIPTION                 in varchar2,
                           P_OUTPUT_PERIOD_TYPE          in varchar2,
                           P_HORIZON_START_DATE          in varchar2,
                           P_HORIZON_END_DATE            in varchar2,
                           P_FORECAST_DATE_USED          in varchar2,
                           P_FORECAST_BASED_ON           in varchar2,
                           P_SCENARIO_TYPE               in varchar2,
                           P_STATUS                      in varchar2,
                           P_HISTORY_START_DATE          in varchar2,
                           P_HISTORY_END_DATE            in varchar2,
                           P_PUBLISH_FLAG                in varchar2,
                           P_ENABLE_FLAG                 in varchar2,
                           P_PRICE_LIST_NAME             in varchar2,
                           P_LAST_REVISION               in varchar2,
                           P_PARAMETER_NAME              in varchar2,
                           P_CONSUME_FLAG                in varchar2,
                           P_ERROR_TYPE                  in varchar2,
                           P_DELETEABLE_FLAG             in varchar2,
			   P_LAST_UPDATE_DATE            in varchar2,
			   P_SUPPLY_PLAN_FLAG             in varchar2,
                           P_ENABLE_NONSEED_FLAG             in VARCHAR2,
			   P_SCENARIO_DESIGNATOR          in VARCHAR2,
               		   P_CUSTOM_MODE             in VARCHAR2,
               		   			 P_SC_TYPE										 in VARCHAR2,
               		   			 P_ASSOCIATE_PARAMETER				 in VARCHAR2
                           )
is

l_demand_plan_id number;
l_scenario_id number;
f_luby    number;  -- entity owner in file
f_ludate  date;    -- entity update date in file
db_luby   number;  -- entity owner in db
db_ludate date;    -- entity update date in db

BEGIN

        -- translate values to IDs
        select DEMAND_PLAN_ID
        into l_demand_plan_id
        from MSD_DEMAND_PLANS
        where DEMAND_PLAN_NAME = P_DEMAND_PLAN_NAME;


        -- Translate owner to file_last_updated_by
        f_luby := fnd_load_util.owner_id(P_OWNER);

        -- Translate char last_update_date to date
        f_ludate := nvl(to_date(P_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);
        begin
          select LAST_UPDATED_BY, LAST_UPDATE_DATE
          into db_luby, db_ludate
          from msd_dp_scenarios
          where DEMAND_PLAN_ID = l_demand_plan_id
          and SCENARIO_NAME = P_SCENARIO_NAME;

	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, P_CUSTOM_MODE)) then
	    -- Update existing row
            update msd_dp_scenarios
	    set supply_plan_flag = p_supply_plan_flag,
	    output_period_type = p_output_period_type
	    ,description = p_description
            ,horizon_start_date = to_date(p_horizon_start_date, 'YYYY/MM/DD')
            ,horizon_end_date = to_date(p_horizon_end_date, 'YYYY/MM/DD')
            ,forecast_date_used = p_forecast_date_used
            ,forecast_based_on = p_forecast_based_on
            ,scenario_type = p_scenario_type
            ,status = p_status
            ,history_start_date = to_date(p_history_start_date, 'YYYY/MM/DD')
            ,history_end_date = to_date(p_history_end_date, 'YYYY/MM/DD')
            ,publish_flag = p_publish_flag
            ,enable_flag = p_enable_flag
            ,price_list_name = p_price_list_name
            ,last_revision = p_last_revision
            ,parameter_name = parameter_name
            ,consume_flag = p_consume_flag
            ,error_type = p_error_type ,
	    last_update_date = f_ludate            ,
            deleteable_flag = P_DELETEABLE_FLAG             ,
            enable_nonseed_flag = P_ENABLE_NONSEED_FLAG             ,
            scenario_designator  = p_scenario_designator,
	    last_updated_by = f_luby             ,
	    last_update_login = 0,
	          sc_type = P_SC_TYPE,
	          associate_parameter = P_ASSOCIATE_PARAMETER
            where DEMAND_PLAN_ID = l_demand_plan_id
            and SCENARIO_NAME = P_SCENARIO_NAME;

	    begin

            select SCENARIO_ID
	    into l_scenario_id
	    from msd_dp_scenarios
	    where demand_plan_id = l_demand_Plan_id
	    and scenario_name = p_scenario_name;

	    -- Update existing row
	    update msd_dp_scenarios_tl
	    set description       = p_description,
            last_update_date  = f_ludate,
            last_updated_by   = f_luby,
            last_update_login = 0,
            source_lang       = userenv('LANG')
            where DEMAND_PLAN_ID = l_demand_plan_id
            and SCENARIO_ID = l_scenario_id
	    and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

	     exception
               when no_data_found then
               -- Record doesn't exist - insert in all cases
               insert into msd_dp_scenarios_tl
	       (
               demand_plan_id,
	       scenario_id,
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
               l_demand_plan_id,
	       l_scenario_id,
               p_description,
               l.language_code,
   	       userenv('LANG'),
               f_luby,
               f_ludate,
               f_luby,
               f_ludate,
               0
               from fnd_languages l
               where l.installed_flag in ('I','B');

	    end;

          end if;
        exception
          when no_data_found then

	    select msd_dp_scenarios_s.nextval into l_scenario_id from dual;

            -- Record doesn't exist - insert in all cases
            insert into msd_dp_scenarios
            (DEMAND_PLAN_ID
	    ,SCENARIO_ID
            ,SCENARIO_NAME
            ,DESCRIPTION
            ,OUTPUT_PERIOD_TYPE
            ,HORIZON_START_DATE
            ,HORIZON_END_DATE
            ,FORECAST_DATE_USED
            ,FORECAST_BASED_ON
            ,SCENARIO_TYPE
            ,STATUS
            ,HISTORY_START_DATE
            ,HISTORY_END_DATE
            ,PUBLISH_FLAG
            ,ENABLE_FLAG
            ,PRICE_LIST_NAME
            ,LAST_REVISION
            ,PARAMETER_NAME
            ,CONSUME_FLAG
            ,ERROR_TYPE        ,
	    SUPPLY_PLAN_FLAG    ,
            CREATION_DATE	       ,
            CREATED_BY                  ,
            LAST_UPDATE_DATE            ,
            LAST_UPDATED_BY             ,
            LAST_UPDATE_LOGIN           ,
	    ENABLE_NONSEED_FLAG ,
	    SCENARIO_DESIGNATOR ,
	    DELETEABLE_FLAG,
	    		  SC_TYPE,
	    		  ASSOCIATE_PARAMETER
            )
            values
            (l_demand_plan_id
	    ,l_scenario_id
            ,P_SCENARIO_NAME
            ,P_DESCRIPTION
            ,P_OUTPUT_PERIOD_TYPE
            ,to_date(P_HORIZON_START_DATE, 'YYYY/MM/DD')
            ,to_date(P_HORIZON_END_DATE, 'YYYY/MM/DD')
            ,P_FORECAST_DATE_USED
            ,P_FORECAST_BASED_ON
            ,P_SCENARIO_TYPE
            ,P_STATUS
            ,to_date(P_HISTORY_START_DATE, 'YYYY/MM/DD')
            ,to_date(P_HISTORY_END_DATE, 'YYYY/MM/DD')
            ,P_PUBLISH_FLAG
            ,P_ENABLE_FLAG
            ,P_PRICE_LIST_NAME
            ,P_LAST_REVISION
            ,P_PARAMETER_NAME
            ,P_CONSUME_FLAG
            ,P_ERROR_TYPE        ,
            P_SUPPLY_PLAN_FLAG   ,
	    f_ludate	       ,
	    f_luby                  ,
	    f_ludate            ,
	    f_luby             ,
	    0           ,
	    P_ENABLE_NONSEED_FLAG ,
	    P_SCENARIO_DESIGNATOR ,
	    P_DELETEABLE_FLAG,
	    		P_SC_TYPE,
	    		P_ASSOCIATE_PARAMETER
	    );

               insert into msd_dp_scenarios_tl
	       (
               demand_plan_id,
	       scenario_id,
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
               l_demand_plan_id,
	       l_scenario_id,
               p_description,
               l.language_code,
   	       userenv('LANG'),
               f_luby,
               f_ludate,
               f_luby,
               f_ludate,
               0
               from fnd_languages l
               where l.installed_flag in ('I','B');

        end;

END;

PROCEDURE TRANSLATE_ROW(P_DEMAND_PLAN_NAME in varchar2,
                        P_SCENARIO_NAME in varchar2,
                        P_DESCRIPTION in varchar2,
			P_OWNER  in varchar2)

IS

f_luby    number;  -- entity owner in file

BEGIN

        -- Translate owner to file_last_updated_by
        f_luby := fnd_load_util.owner_id(P_OWNER);


     update msd_dp_scenarios_tl set
        description       = p_description,
        LAST_UPDATE_DATE  = sysdate,
        LAST_UPDATED_BY   = f_luby,
        LAST_UPDATE_LOGIN = 0,
        SOURCE_LANG       = userenv('LANG')
      where
          demand_plan_id    =   (select demand_plan_id from msd_demand_plans where demand_plan_name = p_demand_plan_name)
	  and scenario_id = (select scenario_id from msd_dp_scenarios where scenario_name = p_scenario_name
	  and demand_plan_id    =   (select demand_plan_id from msd_demand_plans where demand_plan_name = p_demand_plan_name))
          and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
END;

Procedure ADD_LANGUAGE
is
begin
  delete from MSD_DP_SCENARIOS_TL T
  where not exists
    (select NULL
    from MSD_DP_SCENARIOS B
    where B.DEMAND_PLAN_ID = T.DEMAND_PLAN_ID
    and B.SCENARIO_ID = T.SCENARIO_ID
    );

  update MSD_DP_SCENARIOS_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from MSD_DP_SCENARIOS_TL B
    where B.DEMAND_PLAN_ID = T.DEMAND_PLAN_ID
    and B.SCENARIO_ID = T.SCENARIO_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DEMAND_PLAN_ID,
      T.LANGUAGE
  ) in (select
      SUBT.DEMAND_PLAN_ID,
      SUBT.LANGUAGE
    from MSD_DP_SCENARIOS_TL SUBB, MSD_DP_SCENARIOS_TL SUBT
    where SUBB.DEMAND_PLAN_ID = SUBT.DEMAND_PLAN_ID
    and SUBB.SCENARIO_ID = SUBT.SCENARIO_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into MSD_DP_SCENARIOS_TL (
    DEMAND_PLAN_ID,
    SCENARIO_ID,
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
    B.DEMAND_PLAN_ID,
    B.SCENARIO_ID,
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
  from MSD_DP_SCENARIOS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from MSD_DP_SCENARIOS_TL T
    where T.DEMAND_PLAN_ID = B.DEMAND_PLAN_ID
    and T.SCENARIO_ID = B.SCENARIO_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

End ADD_LANGUAGE;


END msd_dp_scenario_pkg ;

/
