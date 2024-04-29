--------------------------------------------------------
--  DDL for Package Body MSD_DP_CALENDAR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DP_CALENDAR_PKG" AS
/* $Header: msddpclb.pls 120.0 2005/05/25 18:16:41 appldev noship $ */

/* Public Procedures */

PROCEDURE LOAD_ROW(P_DEMAND_PLAN_NAME            in VARCHAR2,
                           P_CALENDAR_TYPE               in VARCHAR2,
                           P_CALENDAR_CODE               in VARCHAR2,
                           P_OWNER                       in VARCHAR2,
                           P_LAST_UPDATE_DATE            in VARCHAR2,
                           P_DELETEABLE_FLAG             in VARCHAR2,
                           P_ENABLE_NONSEED_FLAG             in VARCHAR2,
			   P_CUSTOM_MODE               in VARCHAR2
			   )
is

l_demand_plan_id number;
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
          from msd_dp_calendars
          where DEMAND_PLAN_ID = l_demand_plan_id
          and CALENDAR_TYPE = P_CALENDAR_TYPE
	  and CALENDAR_CODE = P_CALENDAR_CODE;

	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, P_CUSTOM_MODE)) then
	    -- Update existing row
            update msd_dp_calendars
	    set  last_update_date = f_ludate            ,
            deleteable_flag = P_DELETEABLE_FLAG             ,
            enable_nonseed_flag = P_ENABLE_NONSEED_FLAG             ,
	    last_updated_by = f_luby             ,
	    last_update_login = 0
	    where demand_plan_id = l_demand_plan_id
	    and calendar_type = p_calendar_type
	    and calendar_code = p_calendar_code;

          end if;
        exception
          when no_data_found then
            -- Record doesn't exist - insert in all cases
            insert into msd_dp_calendars
            (DEMAND_PLAN_ID            ,
            CALENDAR_TYPE               ,
            CALENDAR_CODE               ,
            CREATION_DATE	       ,
            CREATED_BY                  ,
            LAST_UPDATE_DATE            ,
            LAST_UPDATED_BY             ,
            LAST_UPDATE_LOGIN           ,
	    ENABLE_NONSEED_FLAG ,
	    DELETEABLE_FLAG
            )
            values
            (l_demand_plan_id            ,
            P_CALENDAR_TYPE               ,
            P_CALENDAR_CODE               ,
            f_ludate	       ,
	    f_luby                  ,
	    f_ludate            ,
	    f_luby             ,
	    0           ,
	    P_ENABLE_NONSEED_FLAG ,
	    P_DELETEABLE_FLAG
	    );
        end;

END;


END msd_dp_calendar_pkg ;

/
