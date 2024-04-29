--------------------------------------------------------
--  DDL for Package Body MSD_COPY_DEMAND_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_COPY_DEMAND_PLAN" AS
/* $Header: msdcpdpb.pls 120.6 2006/03/31 06:18:36 brampall noship $ */

/* Public Procedures */

function get_parameter_type(p_demand_plan_id number,
														p_parameter_id varchar2)
return varchar2
is
cursor par_type is
select parameter_type
from msd_dp_parameters
where demand_plan_id=p_demand_plan_id
and to_char(parameter_id)=rtrim(p_parameter_id);

l_par_type varchar2(300) := null;

begin

		open par_type;
		fetch par_type into l_par_type;
		close par_type;

		return l_par_type;

end get_parameter_type;

function copy_demand_plan (
p_new_dp_id in out nocopy number,
p_target_demand_plan_name in VARCHAR2,
p_target_demand_plan_descr in VARCHAR2,
p_shared_db_location in VARCHAR2,
p_source_demand_plan_id in NUMBER,
p_organization_id in number,
p_instance_id  in number,
p_errcode in out nocopy varchar2
) return NUMBER IS

lv_error_cd NUMBER;
lv_status_id NUMBER;
x_demand_plan_id number ;
x_new_scenario_id number;
x_new_document_id number;
x_new_formula_id number;
x_dp_exists number := 0 ;
No_Source_Dp EXCEPTION;

cursor cur_scenario is
   select scenario_id
   from msd_dp_scenarios
   where demand_plan_id = p_source_demand_plan_id
   and (nvl(supply_plan_flag,'N') = 'N'
   or p_source_demand_plan_id not in
   (select demand_plan_id
   from msd_demand_plans
   where template_flag = 'Y'));

cursor cur_document is
   select document_id
   from msd_dp_seeded_documents
   where demand_plan_id = p_source_demand_plan_id;

cursor cur_formula is
   select formula_id
   from msd_dp_formulas
   where demand_plan_id = p_source_demand_plan_id
   and (nvl(supply_plan_flag,'N') = 'N'
   or p_source_demand_plan_id not in
   (select demand_plan_id
   from msd_demand_plans
   where template_flag = 'Y'))
   order by creation_sequence;

cursor get_template_flag is
select template_flag
from msd_demand_plans
where demand_plan_id=p_source_demand_plan_id;

cursor get_template_id is
select template_id
from msd_demand_plans
where demand_plan_id=x_demand_plan_id;

cursor replace_equation(p_demand_plan_id number) is
select parameter_type,equation,post_calculation
from msd_dp_parameters
where demand_plan_id=p_demand_plan_id;

cursor replace_associate_param is
select scenario_id,associate_parameter
from msd_dp_scenarios
where demand_plan_id=x_demand_plan_id;

l_template_flag varchar2(3);

l_template_id number;

l_par_type varchar2(300);
BEGIN


select msc_plans_s.nextval into x_demand_plan_id
from dual ;



lv_status_id := 5;

select count(*) into x_dp_exists
from msd_demand_plans
where demand_plan_id = p_source_demand_plan_id;
if x_dp_exists = 0 then
  raise No_Source_Dp ;
end if ;


lv_status_id := 10;

INSERT INTO msd_demand_plans
(        DEMAND_PLAN_ID
        ,ORGANIZATION_ID
        ,DEMAND_PLAN_NAME
        ,DESCRIPTION
        ,CALENDAR_TYPE
        ,CALENDAR_CODE
        ,PERIOD_SET_NAME
        ,BASE_UOM
        ,AVERAGE_DISCOUNT
        ,CATEGORY_SET_ID
        ,LOWEST_PERIOD_TYPE
        ,HISTORY_START_DATE
        ,LAST_UPDATE_DATE
        ,LAST_UPDATED_BY
        ,CREATION_DATE
        ,CREATED_BY
        ,LAST_UPDATE_LOGIN
        ,REQUEST_ID
        ,PROGRAM_APPLICATION_ID
        ,PROGRAM_ID
        ,PROGRAM_UPDATE_DATE
        ,ATTRIBUTE_CATEGORY
        ,ATTRIBUTE1
        ,ATTRIBUTE2
        ,ATTRIBUTE3
        ,ATTRIBUTE4
        ,ATTRIBUTE5
        ,ATTRIBUTE6
        ,ATTRIBUTE7
        ,ATTRIBUTE8
        ,ATTRIBUTE9
        ,ATTRIBUTE10
        ,ATTRIBUTE11
        ,ATTRIBUTE12
        ,ATTRIBUTE13
        ,ATTRIBUTE14
        ,ATTRIBUTE15
        ,SR_INSTANCE_ID
        ,VALID_FLAG
        ,ENABLE_FCST_EXPLOSION
        ,USE_ORG_SPECIFIC_BOM_FLAG
	,ROUNDOFF_THREASHOLD
	,ROUNDOFF_DECIMAL_PLACES
	,AMT_THRESHOLD
	,AMT_DECIMAL_PLACES
        ,G_MIN_TIM_LVL_ID
        ,F_MIN_TIM_LVL_ID
        ,C_MIN_TIM_LVL_ID
        ,M_MIN_TIM_LVL_ID
        ,STRIPE_INSTANCE
        ,STRIPE_LEVEL_ID
        ,STRIPE_SR_LEVEL_PK
        ,STRIPE_STREAM_NAME
        ,STRIPE_STREAM_DESIG
        ,ROUNDING_LEVEL_ID
	,TEMPLATE_FLAG
        ,TEMPLATE_ID
        ,DEFAULT_TEMPLATE
        ,PLAN_TYPE
        ,LIAB_PLAN_ID
	,LIAB_PLAN_NAME
        ,PLAN_START_DATE
        ,PLAN_END_DATE
        ,PREV_LIAB_PUB_PLAN_START_DATE
        ,PREVIOUS_PLAN_START_DATE
        ,LIABILITY_REVISION_NUM
	)
SELECT
         x_demand_plan_id
        ,nvl(p_organization_id, dp.ORGANIZATION_ID)
        ,p_target_demand_plan_name
        ,p_target_demand_plan_descr
        ,dp.CALENDAR_TYPE
        ,dp.CALENDAR_CODE
        ,dp.PERIOD_SET_NAME
        ,dp.BASE_UOM
        ,dp.AVERAGE_DISCOUNT
        ,dp.CATEGORY_SET_ID
        ,dp.LOWEST_PERIOD_TYPE
        ,dp.HISTORY_START_DATE
        ,SYSDATE
        ,fnd_global.user_id
        ,SYSDATE
        ,fnd_global.user_id
        ,fnd_global.login_id
        ,NULL
        ,NULL
        ,NULL
        ,SYSDATE
        ,dp.ATTRIBUTE_CATEGORY
        ,dp.ATTRIBUTE1
        ,dp.ATTRIBUTE2
        ,dp.ATTRIBUTE3
        ,dp.ATTRIBUTE4
        ,dp.ATTRIBUTE5
        ,dp.ATTRIBUTE6
        ,dp.ATTRIBUTE7
        ,dp.ATTRIBUTE8
        ,dp.ATTRIBUTE9
        ,dp.ATTRIBUTE10
        ,dp.ATTRIBUTE11
        ,dp.ATTRIBUTE12
        ,dp.ATTRIBUTE13
        ,dp.ATTRIBUTE14
        ,dp.ATTRIBUTE15
        ,nvl(p_instance_id, dp.SR_INSTANCE_ID)
        ,1
        ,dp.ENABLE_FCST_EXPLOSION
        ,dp.USE_ORG_SPECIFIC_BOM_FLAG
	,dp.ROUNDOFF_THREASHOLD
	,dp.ROUNDOFF_DECIMAL_PLACES
	,dp.AMT_THRESHOLD
	,dp.AMT_DECIMAL_PLACES
        ,dp.G_MIN_TIM_LVL_ID
        ,dp.F_MIN_TIM_LVL_ID
        ,dp.C_MIN_TIM_LVL_ID
        ,dp.M_MIN_TIM_LVL_ID
        ,dp.STRIPE_INSTANCE
        ,dp.STRIPE_LEVEL_ID
        ,dp.STRIPE_SR_LEVEL_PK
        ,dp.STRIPE_STREAM_NAME
        ,dp.STRIPE_STREAM_DESIG
        ,dp.ROUNDING_LEVEL_ID
        ,'N'
        ,dp.TEMPLATE_ID
        ,'N'
        ,dp.PLAN_TYPE
        ,dp.LIAB_PLAN_ID
	,dp.LIAB_PLAN_NAME
        ,dp.PLAN_START_DATE
        ,dp.PLAN_END_DATE
        ,dp.PREV_LIAB_PUB_PLAN_START_DATE
        ,dp.PREVIOUS_PLAN_START_DATE
        ,dp.LIABILITY_REVISION_NUM
   FROM
        msd_demand_plans dp
  WHERE
        DEMAND_PLAN_ID  = p_source_demand_plan_id ;

 INSERT INTO msd_demand_plans_tl
        (
	DEMAND_PLAN_ID
	,DESCRIPTION
	,LANGUAGE
 	,SOURCE_LANG
 	,CREATION_DATE
 	,CREATED_BY
 	,LAST_UPDATE_DATE
 	,LAST_UPDATED_BY
 	,LAST_UPDATE_LOGIN
 	,REQUEST_ID
 	,PROGRAM_APPLICATION_ID
 	,PROGRAM_ID
 	,PROGRAM_UPDATE_DATE
	)
SELECT
         x_demand_plan_id
        ,p_target_demand_plan_descr
	,USERENV('LANG')
 	,USERENV('LANG')
        ,SYSDATE
        ,fnd_global.user_id
        ,SYSDATE
        ,fnd_global.user_id
        ,fnd_global.login_id
        ,NULL
        ,NULL
        ,NULL
        ,SYSDATE
   FROM DUAL;

lv_status_id := 20;

INSERT INTO msd_dp_dimensions
(         DEMAND_PLAN_ID
         ,DP_DIMENSION_CODE
         ,DIMENSION_CODE
         ,LAST_UPDATE_DATE
         ,LAST_UPDATED_BY
         ,CREATION_DATE
         ,CREATED_BY
         ,LAST_UPDATE_LOGIN
         ,REQUEST_ID
         ,PROGRAM_APPLICATION_ID
         ,PROGRAM_ID
         ,PROGRAM_UPDATE_DATE
	 ,DELETEABLE_FLAG)
SELECT
         x_demand_plan_id
         ,dim.DP_DIMENSION_CODE
         ,dim.DIMENSION_CODE
        ,SYSDATE
        ,fnd_global.user_id
        ,SYSDATE
        ,fnd_global.user_id
        ,fnd_global.login_id
        ,NULL
        ,NULL
        ,NULL
        ,SYSDATE
	,dim.DELETEABLE_FLAG
  FROM
        msd_dp_dimensions dim
  WHERE
        DEMAND_PLAN_ID  = p_source_demand_plan_id;

 INSERT INTO msd_dp_hierarchies
         ( DEMAND_PLAN_ID
          ,DP_DIMENSION_CODE
          ,HIERARCHY_ID
          ,LAST_UPDATE_DATE
          ,LAST_UPDATED_BY
          ,CREATION_DATE
          ,CREATED_BY
          ,LAST_UPDATE_LOGIN
          ,REQUEST_ID
          ,PROGRAM_APPLICATION_ID
          ,PROGRAM_ID
          ,PROGRAM_UPDATE_DATE
	  ,DELETEABLE_FLAG)

 SELECT
         x_demand_plan_id
        ,hie.DP_DIMENSION_CODE
        ,hie.HIERARCHY_ID
        ,SYSDATE
        ,fnd_global.user_id
        ,SYSDATE
        ,fnd_global.user_id
        ,fnd_global.login_id
        ,NULL
        ,NULL
        ,NULL
        ,SYSDATE
	,hie.DELETEABLE_FLAG
   FROM  msd_dp_hierarchies hie
   WHERE DEMAND_PLAN_ID  = p_source_demand_plan_id;



lv_status_id := 30;

INSERT INTO msd_dp_parameters
        (DEMAND_PLAN_ID,
         PARAMETER_ID,
         PARAMETER_TYPE,
         PARAMETER_NAME,
         START_DATE,
         END_DATE,
         OUTPUT_SCENARIO_ID,
         INPUT_SCENARIO_ID,
         INPUT_DEMAND_PLAN_ID,
         REVISION,
         FORECAST_DATE_USED,
         FORECAST_BASED_ON,
         QUANTITY_USED,
         AMOUNT_USED,
         FORECAST_USED,
         PERIOD_TYPE,
         FACT_TYPE,
         VIEW_NAME,
	 ALLO_AGG_BASIS_STREAM_ID,
	 NUMBER_OF_PERIOD,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN,
         REQUEST_ID,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         PROGRAM_UPDATE_DATE,
	 DELETEABLE_FLAG,
	 CAPACITY_USAGE_RATIO,
	 SUPPLY_PLAN_FLAG,
	 PRICE_LIST_NAME,
	 STREAM_TYPE,
	 EQUATION,
	 CALCULATED_ORDER,
	 POST_CALCULATION)
SELECT
          x_demand_plan_id
         ,msd_dp_parameters_s.nextval
         ,par.PARAMETER_TYPE
         ,par.PARAMETER_NAME
         ,par.START_DATE
         ,par.END_DATE
         ,par.OUTPUT_SCENARIO_ID
         ,par.INPUT_SCENARIO_ID
         ,par.INPUT_DEMAND_PLAN_ID
         ,par.REVISION
         ,par.FORECAST_DATE_USED
         ,par.FORECAST_BASED_ON
         ,par.QUANTITY_USED
         ,par.AMOUNT_USED
         ,par.FORECAST_USED
         ,par.PERIOD_TYPE
         ,par.FACT_TYPE
         ,par.VIEW_NAME
	 ,par.ALLO_AGG_BASIS_STREAM_ID
	 ,par.NUMBER_OF_PERIOD
         ,SYSDATE
        ,fnd_global.user_id
        ,SYSDATE
        ,fnd_global.user_id
        ,fnd_global.login_id
        ,NULL
        ,NULL
        ,NULL
        ,SYSDATE
	,par.DELETEABLE_FLAG
	,par.CAPACITY_USAGE_RATIO
	,par.SUPPLY_PLAN_FLAG
	,par.PRICE_LIST_NAME
	,par.stream_type
	,par.equation
	,par.calculated_order
	,par.post_calculation
  FROM
        msd_dp_parameters par
 WHERE
        DEMAND_PLAN_ID  = p_source_demand_plan_id
        and nvl(par.stream_type,'ABCD') not in ('ARCHIVED','ARCHIVED_TIM')
        and (nvl(supply_plan_flag,'N') = 'N'
   or p_source_demand_plan_id not in
   (select demand_plan_id
   from msd_demand_plans
   where template_flag = 'Y'));

	open get_template_flag;
	fetch get_template_flag into l_template_flag;
	close get_template_flag;

	if nvl(l_template_flag,'N') = 'N' then

			open get_template_id;
			fetch get_template_id into l_template_id;
			close get_template_id;

			for rep_rec in replace_equation(l_template_id)
			loop
					update msd_dp_parameters set equation = rep_rec.equation, post_calculation=rep_rec.post_calculation where demand_plan_id=x_demand_plan_id and parameter_type=rep_rec.parameter_type;

			end loop;
	end if;

/* Once Parameters are re-created. Update new Parameters with Allocation/Aggregation
 * Stream Id's to simulate Source Plan but point to Destination Plan.
 */

UPDATE msd_dp_parameters mdp
SET
mdp.allo_agg_basis_stream_id =
(
select mdp1.parameter_id
from
msd_dp_parameters mdp1,
(
select parameter_id,parameter_type, parameter_name
from
msd_dp_parameters
) mdp2
where
mdp2.parameter_id = mdp.allo_agg_basis_stream_id
and
mdp1.parameter_type = mdp2.parameter_type
and
 (((mdp2.parameter_name is null) and (mdp1.parameter_name is null))
   or
 ( (mdp2.parameter_name is not null)
     and
   (mdp1.parameter_name is not null)
     and
   (mdp1.parameter_name = mdp2.parameter_name)
 ))
and
mdp1.demand_plan_id = x_demand_plan_id
)
where
(mdp.allo_agg_basis_stream_id is not null)
and demand_plan_id = x_demand_plan_id;




lv_status_id := 40;
for lv_cur_scenario_rec in cur_scenario LOOP


select  msd_dp_scenarios_s.nextval into x_new_scenario_id
from dual;


 INSERT INTO msd_dp_scenarios
         ( DEMAND_PLAN_ID
         ,SCENARIO_ID
         ,SCENARIO_NAME
         ,DESCRIPTION
         ,OUTPUT_PERIOD_TYPE
         ,HORIZON_START_DATE
         ,HORIZON_END_DATE
         ,FORECAST_DATE_USED
         ,FORECAST_BASED_ON
	 ,PARAMETER_NAME
         ,LAST_UPDATE_DATE
         ,LAST_UPDATED_BY
         ,CREATION_DATE
         ,CREATED_BY
         ,LAST_UPDATE_LOGIN
         ,REQUEST_ID
         ,PROGRAM_APPLICATION_ID
         ,PROGRAM_ID
         ,PROGRAM_UPDATE_DATE
         ,ATTRIBUTE_CATEGORY
         ,ATTRIBUTE1
         ,ATTRIBUTE2
         ,ATTRIBUTE3
         ,ATTRIBUTE4
         ,ATTRIBUTE5
         ,ATTRIBUTE6
         ,ATTRIBUTE7
         ,ATTRIBUTE8
         ,ATTRIBUTE9
         ,ATTRIBUTE10
         ,ATTRIBUTE11
         ,ATTRIBUTE12
         ,ATTRIBUTE13
         ,ATTRIBUTE14
         ,ATTRIBUTE15
         ,SCENARIO_TYPE
         ,STATUS
         ,HISTORY_START_DATE
         ,HISTORY_END_DATE
         ,PUBLISH_FLAG
         ,ENABLE_FLAG
         ,PRICE_LIST_NAME
         ,ERROR_TYPE
         ,CONSUME_FLAG
	 ,DELETEABLE_FLAG
         ,SUPPLY_PLAN_FLAG
	 ,SUPPLY_PLAN_ID
	 ,SUPPLY_PLAN_NAME
	 ,OLD_SUPPLY_PLAN_ID
	 ,OLD_SUPPLY_PLAN_NAME
	 ,SC_TYPE
	 , ASSOCIATE_PARAMETER
	 ,dmd_priority_scenario_id            -- Bug# 4710963
 )
 SELECT
          x_demand_plan_id
         ,x_new_scenario_id
         ,sce.SCENARIO_NAME
         ,sce.DESCRIPTION
         ,sce.OUTPUT_PERIOD_TYPE
         ,sce.HORIZON_START_DATE
         ,sce.HORIZON_END_DATE
         ,sce.FORECAST_DATE_USED
         ,sce.FORECAST_BASED_ON
         ,sce.PARAMETER_NAME
         ,SYSDATE
         ,fnd_global.user_id
         ,SYSDATE
         ,fnd_global.user_id
         ,fnd_global.login_id
         ,NULL
         ,NULL
         ,NULL
         ,SYSDATE
         ,sce.ATTRIBUTE_CATEGORY
         ,sce.ATTRIBUTE1
         ,sce.ATTRIBUTE2
         ,sce.ATTRIBUTE3
         ,sce.ATTRIBUTE4
         ,sce.ATTRIBUTE5
         ,sce.ATTRIBUTE6
         ,sce.ATTRIBUTE7
         ,sce.ATTRIBUTE8
         ,sce.ATTRIBUTE9
         ,sce.ATTRIBUTE10
         ,sce.ATTRIBUTE11
         ,sce.ATTRIBUTE12
         ,sce.ATTRIBUTE13
         ,sce.ATTRIBUTE14
         ,sce.ATTRIBUTE15
         ,sce.SCENARIO_TYPE
         ,sce.STATUS
         ,sce.HISTORY_START_DATE
         ,sce.HISTORY_END_DATE
         ,sce.PUBLISH_FLAG
         ,sce.ENABLE_FLAG
         ,sce.PRICE_LIST_NAME
         ,sce.ERROR_TYPE
         ,sce.CONSUME_FLAG
         ,sce.DELETEABLE_FLAG
         ,sce.SUPPLY_PLAN_FLAG
	 ,sce.SUPPLY_PLAN_ID
	 ,sce.SUPPLY_PLAN_NAME
	 --,sce.OLD_SUPPLY_PLAN_ID                   -- Bug# 4575137
	 --,sce.OLD_SUPPLY_PLAN_NAME		     -- Bug# 4575137
	 ,NULL
	 ,NULL
	 ,sce.SC_TYPE
	 ,sce.ASSOCIATE_PARAMETER
	 ,sce.dmd_priority_scenario_id                -- Bug# 4710963
   FROM
         msd_dp_scenarios sce
   WHERE
         scenario_id = lv_cur_scenario_rec.scenario_id AND demand_plan_id =
                       p_source_demand_plan_id;


 INSERT INTO msd_dp_scenarios_tl
         ( DEMAND_PLAN_ID
           ,SCENARIO_ID
           ,DESCRIPTION
           ,LANGUAGE
           ,SOURCE_LANG
           ,CREATION_DATE
           ,CREATED_BY
           ,LAST_UPDATE_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_LOGIN
           ,REQUEST_ID
           ,PROGRAM_APPLICATION_ID
           ,PROGRAM_ID
           ,PROGRAM_UPDATE_DATE
	   )
  SELECT
          x_demand_plan_id
         ,x_new_scenario_id
         ,sce.description
	 ,USERENV('LANG')
	 ,USERENV('LANG')
         ,SYSDATE
         ,fnd_global.user_id
         ,SYSDATE
         ,fnd_global.user_id
         ,fnd_global.login_id
         ,NULL
         ,NULL
         ,NULL
         ,SYSDATE
   FROM
         msd_dp_scenarios_tl sce
   WHERE
         scenario_id = lv_cur_scenario_rec.scenario_id
	 AND demand_plan_id = p_source_demand_plan_id
	 and USERENV('LANG') = language;



lv_status_id := 50;


INSERT INTO msd_dp_scenario_events

        ( DEMAND_PLAN_ID
         ,SCENARIO_ID
         ,EVENT_ID
         ,LAST_UPDATE_DATE
         ,LAST_UPDATED_BY
         ,CREATION_DATE
         ,CREATED_BY
         ,LAST_UPDATE_LOGIN
         ,REQUEST_ID
         ,PROGRAM_APPLICATION_ID
         ,PROGRAM_ID
         ,PROGRAM_UPDATE_DATE
         ,EVENT_ASSOCIATION_PRIORITY
	 ,DELETEABLE_FLAG
        )

 SELECT
         x_demand_plan_id
         ,x_new_scenario_id
         ,scev.EVENT_ID
         ,LAST_UPDATE_DATE
         ,LAST_UPDATED_BY
         ,CREATION_DATE
         ,CREATED_BY
         ,LAST_UPDATE_LOGIN
         ,REQUEST_ID
         ,PROGRAM_APPLICATION_ID
         ,PROGRAM_ID
         ,PROGRAM_UPDATE_DATE
         ,scev.EVENT_ASSOCIATION_PRIORITY
	 ,scev.DELETEABLE_FLAG
   FROM
         msd_dp_scenario_events scev
   WHERE
         scenario_id = lv_cur_scenario_rec.scenario_id AND demand_plan_id
                     = p_source_demand_plan_id;

lv_status_id := 60;
INSERT INTO  msd_dp_scenario_output_levels
        (DEMAND_PLAN_ID
         ,SCENARIO_ID
         ,LEVEL_ID
         ,LAST_UPDATE_DATE
         ,LAST_UPDATED_BY
         ,CREATION_DATE
         ,CREATED_BY
         ,LAST_UPDATE_LOGIN
         ,REQUEST_ID
         ,PROGRAM_APPLICATION_ID
         ,PROGRAM_ID
         ,PROGRAM_UPDATE_DATE
	 ,DELETEABLE_FLAG
 )

SELECT
         x_demand_plan_id
         ,x_new_scenario_id
         ,sceol.LEVEL_ID
         ,SYSDATE
         ,fnd_global.user_id
         ,SYSDATE
         ,fnd_global.user_id
         ,fnd_global.login_id
         ,NULL
         ,NULL
         ,NULL
         ,SYSDATE
	 ,sceol.DELETEABLE_FLAG
   FROM
         msd_dp_scenario_output_levels sceol
   WHERE
         scenario_id = lv_cur_scenario_rec.scenario_id AND demand_plan_id
                     = p_source_demand_plan_id;

END LOOP;


if nvl(l_template_flag,'N') = 'N' then

		for rep_assoc in replace_associate_param
		loop
				l_par_type := get_parameter_type(p_source_demand_plan_id,rep_assoc.associate_parameter);

				update msd_dp_scenarios set associate_parameter = l_par_type where demand_plan_id=x_demand_plan_id and scenario_id=rep_assoc.scenario_id;
		end loop;

		msd_apply_template_demand_plan.replace_associate_parameters(x_demand_plan_id);

end if;

lv_status_id := 65;



INSERT INTO msd_dp_events
	( DP_EVENT_ID,
 	  EVENT_ID,
          DEMAND_PLAN_ID,
          CREATION_DATE,
          CREATED_BY,
 	  LAST_UPDATE_DATE,
	  LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          REQUEST_ID,
          PROGRAM_APPLICATION_ID,
 	  PROGRAM_ID,
          PROGRAM_UPDATE_DATE,
	  DELETEABLE_FLAG
	)
SELECT
	 msd_dp_events_s.nextval
         ,dpev.event_id
         ,x_demand_plan_id
	 ,SYSDATE
         ,fnd_global.user_id
         ,SYSDATE
         ,fnd_global.user_id
         ,fnd_global.login_id
         ,NULL
         ,NULL
         ,NULL
         ,SYSDATE
	 ,dpev.DELETEABLE_FLAG
FROM
	msd_dp_events dpev
WHERE
	demand_plan_id = p_source_demand_plan_id;

INSERT INTO msd_dp_price_lists
	( DP_PRICE_LIST_ID,
          DEMAND_PLAN_ID,
	  PRICE_LIST_NAME,
          CREATION_DATE,
          CREATED_BY,
 	  LAST_UPDATE_DATE,
	  LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          REQUEST_ID,
          PROGRAM_APPLICATION_ID,
 	  PROGRAM_ID,
          PROGRAM_UPDATE_DATE,
	  DELETEABLE_FLAG
	)
SELECT
	 msd_dp_price_lists_s.nextval
         ,x_demand_plan_id
 	 ,dppl.price_list_name
	 ,SYSDATE
         ,fnd_global.user_id
         ,SYSDATE
         ,fnd_global.user_id
         ,fnd_global.login_id
         ,NULL
         ,NULL
         ,NULL
         ,SYSDATE
	 ,dppl.DELETEABLE_FLAG
FROM
	msd_dp_price_lists dppl
WHERE
	demand_plan_id = p_source_demand_plan_id;


lv_status_id := 70;

INSERT INTO msd_dp_express_setup
        ( DEMAND_PLAN_ID
         ,ORGANIZATION_ID
         ,SHARED_DB_PREFIX
         ,CODE_LOCATION
         ,SHARED_DB_LOCATION
         ,EXPRESS_MACHINE_PORT
         ,OWA_VIRTUAL_PATH_NAME
         ,EAD_NAME
         ,EXPRESS_CONNECT_STRING
         ,SETUP1
         ,SETUP2
         ,SETUP3
         ,SETUP4
         ,SETUP5
        )
SELECT
         x_demand_plan_id
         ,nvl(p_organization_id, exp.ORGANIZATION_ID)
         ,'MSD' || to_char(x_demand_plan_id)
         ,null
         ,null
         ,null
         ,null
         ,null
         ,null
         ,null
         ,null
         ,null
         ,null
         ,null
   FROM
         msd_dp_express_setup exp
   WHERE
         DEMAND_PLAN_ID  = p_source_demand_plan_id;

/** Added for Multiple Time Hierarchies **/
lv_status_id := 80;

INSERT INTO MSD_DP_CALENDARS
       (  DEMAND_PLAN_ID
        , CALENDAR_CODE
        , CALENDAR_TYPE
        , LAST_UPDATE_DATE
        , LAST_UPDATED_BY
        , CREATION_DATE
        , CREATED_BY
        , LAST_UPDATE_LOGIN
        , REQUEST_ID
        , PROGRAM_APPLICATION_ID
        , PROGRAM_ID
        , PROGRAM_UPDATE_DATE
	,DELETEABLE_FLAG
       )
SELECT
         x_demand_plan_id
         ,cal.calendar_code
         ,cal.calendar_type
	 ,SYSDATE
         ,fnd_global.user_id
         ,SYSDATE
         ,fnd_global.user_id
         ,fnd_global.login_id
         ,NULL
         ,NULL
         ,NULL
         ,SYSDATE
	 ,DELETEABLE_FLAG
FROM
	msd_dp_calendars cal
WHERE
	cal.demand_plan_id = p_source_demand_plan_id;


for lv_cur_formula_rec in cur_formula LOOP


select  msd_dp_parameters_s.nextval into x_new_formula_id
from dual;


 INSERT INTO msd_dp_formulas
         ( DEMAND_PLAN_ID
           ,FORMULA_ID
           ,CREATION_SEQUENCE
           ,FORMULA_NAME
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
          ,LAST_UPDATE_DATE
          ,FORMAT              /*----NEW COLUMN ADDED--BUG#4373422-----*/
          ,LAST_UPDATED_BY
          ,CREATION_DATE
          ,CREATED_BY
          ,LAST_UPDATE_LOGIN
          ,REQUEST_ID
          ,PROGRAM_APPLICATION_ID
          ,PROGRAM_ID
          ,PROGRAM_UPDATE_DATE
	  ,UPLOAD_FORMULA_ID
	  			,START_PERIOD       /*----NEW COLUMN ADDED--BUG#4744717-----*/
 )
 SELECT
          x_demand_plan_id
         ,x_new_formula_id
         ,CREATION_SEQUENCE
         ,FORMULA_NAME
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
         ,SYSDATE
         ,FORMAT                         /*----NEW COLUMN ADDED--BUG#4373422-----*/
         ,fnd_global.user_id
         ,SYSDATE
         ,fnd_global.user_id
         ,fnd_global.login_id
         ,NULL
         ,NULL
         ,NULL
         ,SYSDATE
	 ,UPLOAD_FORMULA_ID
	 			 ,START_PERIOD									/*----NEW COLUMN ADDED--BUG#4744717-----*/
  FROM
         msd_dp_formulas mdf
   WHERE
         formula_id = lv_cur_formula_rec.formula_id AND demand_plan_id =
                       p_source_demand_plan_id;



lv_status_id := 190;


INSERT INTO msd_dp_formula_parameters
        (  DEMAND_PLAN_ID
          ,FORMULA_ID
          ,WHERE_USED
          ,PARAMETER_SEQUENCE
          ,ENABLED_FLAG
          ,MANDATORY_FLAG
          ,PARAMETER_TYPE
          ,PARAMETER_COMPONENT
          ,PARAMETER_VALUE
          ,SUPPLY_PLAN_FLAG
          ,SUPPLY_PLAN_NAME
	  ,LAST_UPDATE_DATE
          ,LAST_UPDATED_BY
          ,CREATION_DATE
          ,CREATED_BY
          ,LAST_UPDATE_LOGIN
          ,REQUEST_ID
          ,PROGRAM_APPLICATION_ID
          ,PROGRAM_ID
          ,PROGRAM_UPDATE_DATE
        )

 SELECT
            x_demand_plan_id
          ,x_new_formula_id
          ,WHERE_USED
          ,PARAMETER_SEQUENCE
          ,ENABLED_FLAG
          ,MANDATORY_FLAG
          ,PARAMETER_TYPE
          ,PARAMETER_COMPONENT
          ,PARAMETER_VALUE
          ,SUPPLY_PLAN_FLAG
          ,SUPPLY_PLAN_NAME
          ,SYSDATE
          ,fnd_global.user_id
          ,SYSDATE
          ,fnd_global.user_id
          ,fnd_global.login_id
          ,NULL
          ,NULL
          ,NULL
          ,SYSDATE
	    FROM
         msd_dp_formula_parameters mfp
   WHERE
         formula_id = lv_cur_formula_rec.formula_id AND demand_plan_id
                     = p_source_demand_plan_id;

lv_status_id := 200;

END LOOP;

if nvl(l_template_flag,'N') <> 'N' then

	insert into	msd_dp_formula_parameters

	(

	demand_plan_id

	,formula_id

	,where_used

	,parameter_sequence

	,enabled_flag

	,mandatory_flag

	,parameter_type

	,parameter_component

	,parameter_value

	,supply_plan_flag

	,supply_plan_name

	,last_update_date

	,last_updated_by

	,creation_date

	,created_by

	,last_update_login

	,request_id

	,program_application_id

	,program_id

	,program_update_date

	)

	(select

	x_demand_plan_id

	,mdp1.parameter_id

	,mdfp.where_used

	,mdfp.parameter_sequence

	,mdfp.enabled_flag

	,mdfp.mandatory_flag

	,mdfp.parameter_type

	,mdfp.parameter_component

	,mdfp.parameter_value

	,mdfp.supply_plan_flag

	,mdfp.supply_plan_name													-- Bug 4729854

	,SYSDATE

	,fnd_global.user_id

	,SYSDATE

	,fnd_global.user_id

	,fnd_global.login_id

	,NULL

	,NULL

	,NULL

	,SYSDATE

	from msd_dp_formula_parameters mdfp,
	msd_dp_parameters mdp,
	msd_dp_parameters mdp1

	where	mdfp.demand_plan_id	in

		(select	demand_plan_id

		from msd_demand_plans

		where	plan_type	=	'EOL'

		and	template_flag	=	'Y'

		and	default_template = 'Y')
		and mdp.demand_plan_id=mdfp.demand_plan_id
		and mdp.parameter_id=mdfp.formula_id
		and mdp1.demand_plan_id=x_demand_plan_id
		and mdp1.parameter_type=mdp.parameter_type);

else
			insert into	msd_dp_formula_parameters

	(

	demand_plan_id

	,formula_id

	,where_used

	,parameter_sequence

	,enabled_flag

	,mandatory_flag

	,parameter_type

	,parameter_component

	,parameter_value

	,supply_plan_flag

	,supply_plan_name

	,last_update_date

	,last_updated_by

	,creation_date

	,created_by

	,last_update_login

	,request_id

	,program_application_id

	,program_id

	,program_update_date

	)

	(select

	x_demand_plan_id

	,mdp1.parameter_id

	,mdfp.where_used

	,mdfp.parameter_sequence

	,mdfp.enabled_flag

	,mdfp.mandatory_flag

	,mdfp.parameter_type

	,mdfp.parameter_component

	,mdfp.parameter_value

	,mdfp.supply_plan_flag

	,mdfp.supply_plan_name													-- Bug 4729854

	,SYSDATE

	,fnd_global.user_id

	,SYSDATE

	,fnd_global.user_id

	,fnd_global.login_id

	,NULL

	,NULL

	,NULL

	,SYSDATE

	from msd_dp_formula_parameters mdfp,
	msd_dp_parameters mdp,
	msd_dp_parameters mdp1

	where	mdfp.demand_plan_id	= p_source_demand_plan_id
		and mdp.demand_plan_id=mdfp.demand_plan_id
		and mdp.parameter_id=mdfp.formula_id
		and mdp1.demand_plan_id=x_demand_plan_id
		and mdp1.parameter_type=mdp.parameter_type);
end if;

for lv_cur_document_rec in cur_document LOOP



if nvl(l_template_flag,'N') = 'N' then

		msd_apply_template_demand_plan.replace_parameter_tokens(x_demand_plan_id);

end if;

select  msd_dp_seeded_doc_s.nextval into x_new_document_id
from dual;


 INSERT INTO msd_dp_seeded_documents
         (  DEMAND_PLAN_ID
          ,DOCUMENT_ID
	  ,DOCUMENT_NAME
          ,DESCRIPTION
          ,TYPE
          ,OPEN_ON_STARTUP
          ,SCRIPT_CLEANUP
          ,SCRIPT_INIT
          ,SCRIPT_PREPAGE
          ,SCRIPT_POSTPAGE
          ,VALID_FLAG
          ,LAST_UPDATE_DATE
          ,LAST_UPDATED_BY
          ,CREATION_DATE
          ,CREATED_BY
          ,LAST_UPDATE_LOGIN
          ,REQUEST_ID
          ,PROGRAM_APPLICATION_ID
          ,PROGRAM_ID
          ,PROGRAM_UPDATE_DATE
	  ,SUB_TYPE
 )
 SELECT
          x_demand_plan_id
         ,x_new_document_id
	 ,msd.DOCUMENT_NAME
	 ,msd.DESCRIPTION
         ,msd.TYPE
         ,msd.OPEN_ON_STARTUP
         ,msd.SCRIPT_CLEANUP
         ,msd.SCRIPT_INIT
         ,msd.SCRIPT_PREPAGE
         ,msd.SCRIPT_POSTPAGE
         ,msd.VALID_FLAG
         ,SYSDATE
         ,fnd_global.user_id
         ,SYSDATE
         ,fnd_global.user_id
         ,fnd_global.login_id
         ,NULL
         ,NULL
         ,NULL
         ,SYSDATE
	 ,msd.SUB_TYPE
   FROM
         msd_dp_seeded_documents msd
   WHERE
         document_id = lv_cur_document_rec.document_id AND demand_plan_id =
                       p_source_demand_plan_id;



lv_status_id := 90;


INSERT INTO msd_dp_seeded_doc_dimensions
        ( DEMAND_PLAN_ID
          ,DOCUMENT_ID
          ,DIMENSION_CODE
          ,SEQUENCE_NUMBER
          ,AXIS
          ,HIERARCHY_ID
          ,SELECTION_TYPE
          ,SELECTION_SCRIPT
          ,ENABLED_FLAG
          ,MANDATORY_FLAG
	  ,LAST_UPDATE_DATE
          ,LAST_UPDATED_BY
          ,CREATION_DATE
          ,CREATED_BY
          ,LAST_UPDATE_LOGIN
          ,REQUEST_ID
          ,PROGRAM_APPLICATION_ID
          ,PROGRAM_ID
          ,PROGRAM_UPDATE_DATE
        )

 SELECT
           x_demand_plan_id
          ,X_NEW_DOCUMENT_ID
          ,DIMENSION_CODE
          ,SEQUENCE_NUMBER
          ,AXIS
          ,HIERARCHY_ID
          ,SELECTION_TYPE
          ,SELECTION_SCRIPT
          ,ENABLED_FLAG
          ,MANDATORY_FLAG
          ,SYSDATE
          ,fnd_global.user_id
          ,SYSDATE
          ,fnd_global.user_id
          ,fnd_global.login_id
          ,NULL
          ,NULL
          ,NULL
          ,SYSDATE
	    FROM
         MSD_DP_SEEDED_DOC_DIMENSIONS MDD
   WHERE
         document_id = lv_cur_document_rec.document_id AND demand_plan_id
                     = p_source_demand_plan_id;

lv_status_id := 100;

INSERT INTO  msd_dp_doc_dim_selections
        (DEMAND_PLAN_ID
         ,DOCUMENT_ID
         ,DIMENSION_CODE
         ,ENABLED_FLAG
         ,MANDATORY_FLAG
         ,SELECTION_SEQUENCE
         ,SELECTION_TYPE
         ,SELECTION_COMPONENT
         ,SELECTION_VALUE
         ,SUPPLY_PLAN_FLAG
         ,SUPPLY_PLAN_NAME
         ,LAST_UPDATE_DATE
         ,LAST_UPDATED_BY
         ,CREATION_DATE
         ,CREATED_BY
         ,LAST_UPDATE_LOGIN
         ,REQUEST_ID
         ,PROGRAM_APPLICATION_ID
         ,PROGRAM_ID
         ,PROGRAM_UPDATE_DATE
 )

SELECT
          x_demand_plan_id
         ,x_new_document_id
         ,DIMENSION_CODE
         ,ENABLED_FLAG
         ,MANDATORY_FLAG
         ,SELECTION_SEQUENCE
         ,SELECTION_TYPE
         ,SELECTION_COMPONENT
         ,SELECTION_VALUE
         ,SUPPLY_PLAN_FLAG
         ,SUPPLY_PLAN_NAME
         ,SYSDATE
         ,fnd_global.user_id
         ,SYSDATE
         ,fnd_global.user_id
         ,fnd_global.login_id
         ,NULL
         ,NULL
         ,NULL
         ,SYSDATE
   FROM
         msd_dp_doc_dim_selections mdds
   WHERE
         document_id = lv_cur_document_rec.document_id
	 and demand_plan_id = p_source_demand_plan_id
         and (nvl(supply_plan_flag,'N') = 'N'
         or p_source_demand_plan_id not in
         (select demand_plan_id
         from msd_demand_plans
         where template_flag = 'Y'));

END LOOP;

/*----------bug 4615390---------------*/

insert into MSD_DP_ISO_ORGANIZATIONS
		(DEMAND_PLAN_ID,
 		SR_INSTANCE_ID,
        	SR_ORGANIZATION_ID,
		--ATTACHED_FLAG ,
		--BUILT_FLAG ,
		LAST_UPDATED_BY,
                CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN,
		REQUEST_ID,
		PROGRAM_APPLICATION_ID,
		PROGRAM_ID,
		PROGRAM_UPDATE_DATE,
 		LAST_UPDATE_DATE )
select
                X_DEMAND_PLAN_ID,
 		SR_INSTANCE_ID,
        	SR_ORGANIZATION_ID,
		--ATTACHED_FLAG ,
		--BUILT_FLAG ,
		LAST_UPDATED_BY,
                CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN,
		REQUEST_ID,
		PROGRAM_APPLICATION_ID,
		PROGRAM_ID,
		PROGRAM_UPDATE_DATE,
 		LAST_UPDATE_DATE
 from MSD_DP_ISO_ORGANIZATIONS
 where demand_plan_id = p_source_demand_plan_id;
  -- and attached_flag='Y';



p_new_dp_id := x_demand_plan_id ;

return 0;

EXCEPTION

        when No_Source_Dp then
        p_new_dp_id := null ;
        p_errcode := 'Demand Plan Does not Exist' ;
        return 1;


        WHEN OTHERS THEN
        p_new_dp_id := null ;
        p_errcode := substr(SQLERRM,1,150);
        return 1;


END copy_demand_plan;

END MSD_COPY_DEMAND_PLAN;

/
