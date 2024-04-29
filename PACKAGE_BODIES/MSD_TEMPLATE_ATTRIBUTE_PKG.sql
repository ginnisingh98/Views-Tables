--------------------------------------------------------
--  DDL for Package Body MSD_TEMPLATE_ATTRIBUTE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_TEMPLATE_ATTRIBUTE_PKG" AS
/* $Header: msddptab.pls 120.0 2005/05/25 19:49:34 appldev noship $ */

/* Public Procedures */

PROCEDURE LOAD_ROW(P_DEMAND_PLAN_NAME in varchar2
         ,P_ATTRIBUTE_NAME	in varchar2
         ,P_ATTRIBUTE_TYPE          in varchar2
         ,P_OWNER  in varchar2
         ,P_ENABLED_FLAG      in varchar2
         ,P_DISPLAYED_FLAG     in varchar2
         ,P_ATTRIBUTE_PROMPT     in varchar2
         ,P_LOV_NAME in varchar2
         ,P_INSERT_ALLOWED_FLAG   in varchar2
	 ,P_LAST_UPDATE_DATE in varchar2
         ,P_ENABLE_NONSEED_FLAG  in VARCHAR2
         ,P_CUSTOM_MODE in varchar2
	 )
is

l_demand_plan_id number;
l_scenario_id number;
l_event_id number;
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
          from msd_template_attributes
          where TEMPLATE_ID = l_demand_plan_id
          and ATTRIBUTE_TYPE = P_ATTRIBUTE_TYPE
	  and ATTRIBUTE_NAME = P_ATTRIBUTE_NAME;

	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, P_CUSTOM_MODE)) then
	    -- Update existing row
            update msd_template_attributes
	    set  enabled_flag = p_enabled_flag
            ,displayed_flag = p_displayed_flag
            ,attribute_prompt = p_attribute_prompt
            ,lov_name = p_lov_name
            ,insert_allowed_flag = p_insert_allowed_flag ,
            enable_nonseed_flag = P_ENABLE_NONSEED_FLAG             ,
	    last_update_date = f_ludate            ,
	    last_updated_by = f_luby             ,
	    last_update_login = 0
            where template_id = l_demand_plan_id
            and attribute_type = p_attribute_type
  	    and attribute_name = p_attribute_name;

          end if;
        exception
          when no_data_found then
            -- Record doesn't exist - insert in all cases
            insert into msd_template_attributes
            (TEMPLATE_ID
            ,ATTRIBUTE_NAME
            ,ATTRIBUTE_TYPE
            ,ENABLED_FLAG
            ,DISPLAYED_FLAG
            ,ATTRIBUTE_PROMPT
            ,LOV_NAME
            ,INSERT_ALLOWED_FLAG  ,
	    ENABLE_NONSEED_FLAG ,
            CREATION_DATE	       ,
            CREATED_BY                  ,
            LAST_UPDATE_DATE            ,
            LAST_UPDATED_BY             ,
            LAST_UPDATE_LOGIN
            )
            values
            (l_demand_plan_id
           ,P_ATTRIBUTE_NAME
           ,P_ATTRIBUTE_TYPE
           ,P_ENABLED_FLAG
           ,P_DISPLAYED_FLAG
           ,P_ATTRIBUTE_PROMPT
           ,P_LOV_NAME
           ,P_INSERT_ALLOWED_FLAG  ,
	    P_ENABLE_NONSEED_FLAG ,
            f_ludate	       ,
	    f_luby                  ,
	    f_ludate            ,
	    f_luby             ,
	    0
	    );
        end;

END;

END msd_template_attribute_pkg ;

/
