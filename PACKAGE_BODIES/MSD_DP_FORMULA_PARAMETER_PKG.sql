--------------------------------------------------------
--  DDL for Package Body MSD_DP_FORMULA_PARAMETER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DP_FORMULA_PARAMETER_PKG" AS
/* $Header: msddpfpb.pls 120.1 2006/03/31 08:32:45 brampall noship $ */

/* Public Procedures */

PROCEDURE LOAD_ROW(P_DEMAND_PLAN_NAME in varchar2
         ,P_FORMULA_NAME	in varchar2
         ,P_WHERE_USED          in varchar2
         ,P_PARAMETER_SEQUENCE  in varchar2
         ,P_OWNER             in varchar2
         ,P_ENABLED_FLAG       in varchar2
         ,P_MANDATORY_FLAG     in varchar2
         ,P_PARAMETER_TYPE     in varchar2
         ,P_PARAMETER_COMPONENT in varchar2
         ,P_PARAMETER_VALUE    in varchar2
         ,P_SUPPLY_PLAN_FLAG   in varchar2
         ,P_SUPPLY_PLAN_NAME   in varchar2
	 ,P_LAST_UPDATE_DATE in varchar2
         ,P_CUSTOM_MODE in varchar2
	 )
is

l_demand_plan_id number;
l_formula_id number;
l_plan_type varchar2(10);
f_luby    number;  -- entity owner in file
f_ludate  date;    -- entity update date in file
db_luby   number;  -- entity owner in db
db_ludate date;    -- entity update date in db


BEGIN

        -- translate values to IDs
        select DEMAND_PLAN_ID, PLAN_TYPE
        into l_demand_plan_id, l_plan_type
        from MSD_DEMAND_PLANS
        where DEMAND_PLAN_NAME = P_DEMAND_PLAN_NAME;


				if l_plan_type = 'EOL' then
				select PARAMETER_ID
				into l_formula_id
				from MSD_DP_PARAMETERS
				where demand_plan_id = l_demand_plan_id
				and parameter_type = p_formula_name;
				else
				select FORMULA_ID
				into l_formula_id
				from MSD_DP_FORMULAS
				where demand_plan_id = l_demand_plan_id
				and formula_name = p_formula_name;
 				end if;

        -- Translate owner to file_last_updated_by
        f_luby := fnd_load_util.owner_id(P_OWNER);

        -- Translate char last_update_date to date
        f_ludate := nvl(to_date(P_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);
        begin
          select LAST_UPDATED_BY, LAST_UPDATE_DATE
          into db_luby, db_ludate
          from msd_dp_formula_parameters
          where DEMAND_PLAN_ID = l_demand_plan_id
          and formula_id = l_formula_id
	  and where_used = p_where_used
	  and parameter_sequence = p_parameter_sequence;

	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, P_CUSTOM_MODE)) then
	    -- Update existing row
            update msd_dp_formula_parameters
	    set  enabled_flag = p_enabled_flag
            ,mandatory_flag = p_mandatory_flag
            ,parameter_type = p_parameter_type
            ,parameter_component = p_parameter_component
            ,parameter_value = p_parameter_value
            ,supply_plan_flag = p_supply_plan_flag
            ,supply_plan_name = p_supply_plan_name
	    ,last_update_date = f_ludate            ,
	    last_updated_by = f_luby             ,
	    last_update_login = 0
            where DEMAND_PLAN_ID = l_demand_plan_id
            and formula_id = l_formula_id
	    and where_used = p_where_used
	    and parameter_sequence = p_parameter_sequence;

          end if;
        exception
          when no_data_found then
            -- Record doesn't exist - insert in all cases
            insert into msd_dp_formula_parameters
            (DEMAND_PLAN_ID
	    ,FORMULA_ID
	    ,WHERE_USED
	    ,PARAMETER_SEQUENCE
            ,ENABLED_FLAG
            ,MANDATORY_FLAG
            ,PARAMETER_TYPE
            ,PARAMETER_COMPONENT
            ,PARAMETER_VALUE
            ,SUPPLY_PLAN_FLAG
            ,SUPPLY_PLAN_NAME          ,
            CREATION_DATE	       ,
            CREATED_BY                  ,
            LAST_UPDATE_DATE            ,
            LAST_UPDATED_BY             ,
            LAST_UPDATE_LOGIN
            )
            values
            (l_demand_plan_id
	    ,l_formula_id
	    ,P_WHERE_USED
	    ,P_PARAMETER_SEQUENCE
            ,P_ENABLED_FLAG
            ,P_MANDATORY_FLAG
            ,P_PARAMETER_TYPE
            ,P_PARAMETER_COMPONENT
            ,P_PARAMETER_VALUE
            ,P_SUPPLY_PLAN_FLAG
            ,P_SUPPLY_PLAN_NAME ,
            f_ludate	       ,
	    f_luby                  ,
	    f_ludate            ,
	    f_luby             ,
	    0
	    );
        end;


END;

END msd_dp_formula_parameter_pkg ;

/
