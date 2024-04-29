--------------------------------------------------------
--  DDL for Package Body MSD_DP_PARAMETER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DP_PARAMETER_PKG" AS
/* $Header: msddpipb.pls 120.1 2006/03/31 07:10:58 brampall noship $ */

/* Public Procedures */


PROCEDURE LOAD_ROW(P_DEMAND_PLAN_NAME           in VARCHAR2,
	                    P_PARAMETER_TYPE             in VARCHAR2,
                            P_PARAMETER_NAME             in VARCHAR2,
                            P_OWNER                      in VARCHAR2,
                            P_START_DATE                 in VARCHAR2,
                            P_END_DATE                   in VARCHAR2,
                            P_INPUT_SCENARIO             in VARCHAR2,
                            P_FORECAST_DATE_USED         in VARCHAR2,
                            P_FORECAST_BASED_ON          in VARCHAR2,
                            P_QUANTITY_USED              in VARCHAR2,
                            P_AMOUNT_USED                in VARCHAR2,
                            P_FORECAST_USED              in varchar2,
                            P_PERIOD_TYPE                in varchar2,
                            P_FACT_TYPE                  in varchar2,
                            P_VIEW_NAME                  in varchar2,
                            P_ALLO_AGG_BASIS_STREAM_ID   in varchar2,
                            P_NUMBER_OF_PERIOD           in varchar2,
                            P_EXCLUDE_FROM_ROLLING_CYCLE in varchar2,
                            P_ROUNDING_FLAG              in varchar2,
                            P_DELETEABLE_FLAG            in varchar2,
			    									P_LAST_UPDATE_DATE           in varchar2,
			    									P_CAPACITY_USAGE_RATIO       in VARCHAR2,
              	            P_SUPPLY_PLAN_FLAG           in VARCHAR2,
                            P_ENABLE_NONSEED_FLAG        in VARCHAR2,
			    									P_PRICE_LIST_NAME            in VARCHAR2,
 			    									P_CUSTOM_MODE                in VARCHAR2,
 			    									P_STREAM_TYPE  							 in VARCHAR2,
 			    									P_EQUATION									 in VARCHAR2,
 			    									P_CALCULATED_ORDER					 in VARCHAR2,
 			    									P_POST_CALCULATION           in VARCHAR2,
 			    									P_ARCHIVED_FOR_PARAMETER     in VARCHAR2
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

        begin

        select SCENARIO_ID
	into l_scenario_id
	from MSD_DP_SCENARIOS
	where demand_plan_id = l_demand_plan_id
	and scenario_name = P_INPUT_SCENARIO;

	exception
          when no_data_found then
	    null;
	end;

        -- Translate owner to file_last_updated_by
        f_luby := fnd_load_util.owner_id(P_OWNER);

        -- Translate char last_update_date to date
        f_ludate := nvl(to_date(P_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);
        begin
          select LAST_UPDATED_BY, LAST_UPDATE_DATE
          into db_luby, db_ludate
          from msd_dp_parameters
          where DEMAND_PLAN_ID = l_demand_plan_id
          and PARAMETER_TYPE  = P_PARAMETER_TYPE
          and (PARAMETER_NAME is null
	  or PARAMETER_NAME = P_PARAMETER_NAME);

	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, P_CUSTOM_MODE)) then
	    -- Update existing row
            update msd_dp_parameters
	    set capacity_usage_ratio = p_capacity_usage_ratio ,
            supply_plan_flag = p_supply_plan_flag ,
            last_update_date = f_ludate            ,
            start_date = to_date(P_START_DATE, 'YYYY/MM/DD'),
            end_date = to_date(P_END_DATE, 'YYYY/MM/DD'),
            input_scenario_id = l_scenario_id             ,
            forecast_date_used = P_FORECAST_DATE_USED,
            forecast_based_on = P_FORECAST_BASED_ON          ,
            quantity_used = P_QUANTITY_USED              ,
            amount_used = P_AMOUNT_USED                ,
            forecast_used = P_FORECAST_USED              ,
            period_type = P_PERIOD_TYPE                ,
            fact_type = P_FACT_TYPE                  ,
            view_name = P_VIEW_NAME                  ,
            allo_agg_basis_stream_id = P_ALLO_AGG_BASIS_STREAM_ID   ,
            number_of_period = P_NUMBER_OF_PERIOD           ,
            exclude_from_rolling_cycle = P_EXCLUDE_FROM_ROLLING_CYCLE ,
            rounding_flag = P_ROUNDING_FLAG              ,
            deleteable_flag = P_DELETEABLE_FLAG    	  ,
            enable_nonseed_flag = P_ENABLE_NONSEED_FLAG             ,
	    price_list_name = P_PRICE_LIST_NAME      ,
	    last_updated_by = f_luby             ,
	    last_update_login = 0 ,
	    			stream_type = P_STREAM_TYPE,
	    			equation = P_EQUATION,
	    			calculated_order = P_CALCULATED_ORDER,
	    			post_calculation = P_POST_CALCULATION,
	    			archived_for_parameter = P_ARCHIVED_FOR_PARAMETER
            where demand_plan_id = l_demand_plan_id
            and parameter_type  = p_parameter_type
            and (parameter_name is null
    	    or parameter_name = p_parameter_name);

	  end if;
        exception
          when no_data_found then
            -- Record doesn't exist - insert in all cases
            insert into msd_dp_parameters
            (DEMAND_PLAN_ID
	    ,PARAMETER_ID
            ,PARAMETER_TYPE
            ,PARAMETER_NAME
            ,START_DATE
            ,END_DATE
            ,INPUT_SCENARIO_ID
            ,FORECAST_DATE_USED
            ,FORECAST_BASED_ON
            ,QUANTITY_USED
            ,AMOUNT_USED
            ,FORECAST_USED
            ,PERIOD_TYPE
            ,FACT_TYPE
            ,VIEW_NAME
            ,ALLO_AGG_BASIS_STREAM_ID
            ,NUMBER_OF_PERIOD
            ,EXCLUDE_FROM_ROLLING_CYCLE
            ,ROUNDING_FLAG              ,
   	    CAPACITY_USAGE_RATIO ,
            SUPPLY_PLAN_FLAG ,
            CREATION_DATE	       ,
            CREATED_BY                  ,
            LAST_UPDATE_DATE            ,
            LAST_UPDATED_BY             ,
            LAST_UPDATE_LOGIN           ,
	    ENABLE_NONSEED_FLAG ,
	    PRICE_LIST_NAME,
	    DELETEABLE_FLAG,
	    			STREAM_TYPE,
	    			EQUATION,
	    			CALCULATED_ORDER,
	    			POST_CALCULATION,
	    			ARCHIVED_FOR_PARAMETER
            )
            values
            (l_demand_plan_id
	    ,msd_dp_parameters_s.nextval
            ,P_PARAMETER_TYPE
            ,P_PARAMETER_NAME
            ,to_date(P_START_DATE, 'YYYY/MM/DD')
            ,to_date(P_END_DATE, 'YYYY/MM/DD')
            ,l_scenario_id
            ,P_FORECAST_DATE_USED
            ,P_FORECAST_BASED_ON
            ,P_QUANTITY_USED
            ,P_AMOUNT_USED
            ,P_FORECAST_USED
            ,P_PERIOD_TYPE
            ,P_FACT_TYPE
            ,P_VIEW_NAME
            ,P_ALLO_AGG_BASIS_STREAM_ID
            ,P_NUMBER_OF_PERIOD
            ,P_EXCLUDE_FROM_ROLLING_CYCLE
            ,P_ROUNDING_FLAG              ,
 	    P_CAPACITY_USAGE_RATIO ,
            P_SUPPLY_PLAN_FLAG ,
            f_ludate	       ,
	    f_luby                  ,
	    f_ludate            ,
	    f_luby             ,
	    0           ,
	    P_ENABLE_NONSEED_FLAG ,
	    P_PRICE_LIST_NAME ,
	    P_DELETEABLE_FLAG,
	    P_STREAM_TYPE,
	    P_EQUATION,
	    P_CALCULATED_ORDER,
	    P_POST_CALCULATION,
	    P_ARCHIVED_FOR_PARAMETER
	    );
        end;

END;


END msd_dp_parameter_pkg ;

/
