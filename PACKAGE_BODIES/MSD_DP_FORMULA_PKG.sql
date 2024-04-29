--------------------------------------------------------
--  DDL for Package Body MSD_DP_FORMULA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DP_FORMULA_PKG" AS
/* $Header: msddpfb.pls 120.2 2005/12/22 00:02:21 amitku noship $ */

/* Public Procedures */

PROCEDURE LOAD_ROW(P_DEMAND_PLAN_NAME in varchar2
         ,P_FORMULA_NAME	in varchar2
         ,P_OWNER            in varchar2
         ,P_CREATION_SEQUENCE in varchar2
         ,P_FORMULA_DESC      in varchar2
         ,P_CUSTOM_TYPE       in varchar2
         ,P_EQUATION          in varchar2
         ,P_CUSTOM_FIELD1     in varchar2
         ,P_CUSTOM_FIELD2     in varchar2
         ,P_CUSTOM_SUBTYPE    in varchar2
         ,P_CUSTOM_ADDTLCALC  in varchar2
         ,P_ISBY              in varchar2
         ,P_VALID_FLAG        in varchar2
         ,P_NUMERATOR         in varchar2
         ,P_DENOMINATOR       in varchar2
         ,P_SUPPLY_PLAN_FLAG  in varchar2
         ,P_SUPPLY_PLAN_NAME  in varchar2
         ,P_UPLOAD_FORMULA_ID in varchar2
	 ,P_LAST_UPDATE_DATE  in varchar2
	 ,P_FORMAT            in varchar2     /* Added a new coulumn in MSD_DP_FORMULAS table (Bug#4373422)*/
	 ,P_START_PERIOD      in varchar2     /* Added a new coulumn in MSD_DP_FORMULAS table (Bug#4744717)*/
         ,P_CUSTOM_MODE       in varchar2
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
          from msd_dp_formulas
          where DEMAND_PLAN_ID = l_demand_plan_id
          and FORMULA_NAME = P_FORMULA_NAME;

	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, P_CUSTOM_MODE)) then
	    -- Update existing row
            update msd_dp_formulas
	    set  CREATION_SEQUENCE = P_CREATION_SEQUENCE
            ,FORMULA_DESC = P_FORMULA_DESC
            ,CUSTOM_TYPE = P_CUSTOM_TYPE
            ,EQUATION = P_EQUATION
            ,CUSTOM_FIELD1 = P_CUSTOM_FIELD1
            ,CUSTOM_FIELD2 = P_CUSTOM_FIELD2
            ,CUSTOM_SUBTYPE = P_CUSTOM_SUBTYPE
            ,CUSTOM_ADDTLCALC = P_CUSTOM_ADDTLCALC
            ,ISBY = P_ISBY
            ,VALID_FLAG = P_VALID_FLAG
            ,NUMERATOR = P_NUMERATOR
            ,DENOMINATOR = P_DENOMINATOR
            ,SUPPLY_PLAN_FLAG = P_SUPPLY_PLAN_FLAG
            ,SUPPLY_PLAN_NAME = P_SUPPLY_PLAN_NAME
            ,UPLOAD_FORMULA_ID = P_UPLOAD_FORMULA_ID
	    ,last_update_date = f_ludate
	    ,format = P_FORMAT                        /* Added a new coulumn in MSD_DP_FORMULAS table (Bug#4373422)*/
	    ,last_updated_by = f_luby
	    ,last_update_login = 0
	    ,START_PERIOD=P_START_PERIOD              /* Added a new coulumn in MSD_DP_FORMULAS table (Bug#4744717)*/
            where demand_plan_id = l_demand_plan_id
            and formula_name = p_formula_name;

          end if;
        exception
          when no_data_found then
            -- Record doesn't exist - insert in all cases
            insert into msd_dp_formulas
            (DEMAND_PLAN_ID
	    ,FORMULA_ID
	    ,FORMULA_NAME
	    ,CREATION_SEQUENCE
            ,FORMULA_DESC
            ,CUSTOM_TYPE
            ,EQUATION
            ,CUSTOM_FIELD1
            ,CUSTOM_FIELD2
            ,CUSTOM_SUBTYPE
            ,CUSTOM_ADDTLCALC
            ,ISBY
            ,VALID_FLAG
            ,NUMERATOR
            ,DENOMINATOR
            ,SUPPLY_PLAN_FLAG
            ,SUPPLY_PLAN_NAME
	    ,UPLOAD_FORMULA_ID
            ,CREATION_DATE
            ,CREATED_BY
            ,LAST_UPDATE_DATE
            ,FORMAT                       /* Added a new coulumn in MSD_DP_FORMULAS table (Bug#4373422)*/
            ,LAST_UPDATED_BY
            ,LAST_UPDATE_LOGIN
            ,START_PERIOD                 /* Added a new coulumn in MSD_DP_FORMULAS table (Bug#4744717)*/
            )
            values
            (l_demand_plan_id
	    			,msd_dp_parameters_s.nextval
	    			,P_FORMULA_NAME
	    			,P_CREATION_SEQUENCE
            ,P_FORMULA_DESC
            ,P_CUSTOM_TYPE
            ,P_EQUATION
            ,P_CUSTOM_FIELD1
            ,P_CUSTOM_FIELD2
            ,P_CUSTOM_SUBTYPE
            ,P_CUSTOM_ADDTLCALC
            ,P_ISBY
            ,P_VALID_FLAG
            ,P_NUMERATOR
            ,P_DENOMINATOR
            ,P_SUPPLY_PLAN_FLAG
            ,P_SUPPLY_PLAN_NAME
	    			,P_UPLOAD_FORMULA_ID
            ,f_ludate
	    			,f_luby
	    			,f_ludate
	    			,P_FORMAT              /* Added a new coulumn in MSD_DP_FORMULAS table (Bug#4373422)*/
	    			,f_luby
	    			,0
	    			,P_START_PERIOD        /* Added a new coulumn in MSD_DP_FORMULAS table (Bug#4744717)*/

	    );
        end;

END;

END msd_dp_formula_pkg ;

/
