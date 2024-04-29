--------------------------------------------------------
--  DDL for Package Body MSD_DP_HIERARCHY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DP_HIERARCHY_PKG" AS
/* $Header: msddphrb.pls 120.0 2005/05/25 19:57:37 appldev noship $ */

/* Public Procedures */

PROCEDURE LOAD_ROW(P_DEMAND_PLAN_NAME          in varchar2,
                   P_DP_DIMENSION_CODE         in varchar2,
                   P_HIERARCHY_ID              in varchar2,
                   P_OWNER                     in varchar2,
                   P_DELETEABLE_FLAG           in varchar2,
                   P_LAST_UPDATE_DATE          in varchar2,
                   P_ENABLE_NONSEED_FLAG             in VARCHAR2,
      		   P_CUSTOM_MODE             in VARCHAR2
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
          from msd_dp_hierarchies
          where DEMAND_PLAN_ID = l_demand_plan_id
          and HIERARCHY_ID = P_HIERARCHY_ID;

	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, P_CUSTOM_MODE)) then
	    -- Update existing row
            update msd_dp_hierarchies
	    set  last_update_date = f_ludate            ,
            deleteable_flag = P_DELETEABLE_FLAG             ,
            enable_nonseed_flag = P_ENABLE_NONSEED_FLAG             ,
	    last_updated_by = f_luby             ,
	    last_update_login = 0
	    where demand_plan_id = l_demand_plan_id
	    and hierarchy_id = p_hierarchy_id
	    and dp_dimension_code  = p_dp_dimension_code;

          end if;
        exception
          when no_data_found then
            -- Record doesn't exist - insert in all cases
            insert into msd_dp_hierarchies
            (DEMAND_PLAN_ID            ,
            DP_DIMENSION_CODE               ,
            HIERARCHY_ID               ,
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
            P_DP_DIMENSION_CODE               ,
            P_HIERARCHY_ID               ,
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

END msd_dp_hierarchy_pkg ;

/
