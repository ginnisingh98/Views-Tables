--------------------------------------------------------
--  DDL for Package Body MSD_EOL_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_EOL_PLAN" AS
/* $Header: msdeolpb.pls 120.6 2006/05/16 03:27 amitku noship $ */

---- Public procedures
--procedure msd_eol_pre_download_hook(p_demand_plan_id number);

--procedure eol_post_archive(p_demand_plan_id number);

---- Private Functions
FUNCTION get_supply_plan_start_date( p_plan_id IN NUMBER) return DATE;

---- Private Procedures
procedure liability_preprocessor(p_plan_id IN NUMBER );

procedure msd_eol_pre_download_hook(p_demand_plan_id number)
is
l_supply_plan_id number;
l_supply_plan_start_date date;
begin
	select liab_plan_id into l_supply_plan_id
	from msd_demand_plans
	where demand_plan_id=p_demand_plan_id;

	l_supply_plan_start_date := get_supply_plan_start_date(l_supply_plan_id);

	update msd_demand_plans
	set previous_plan_start_date=plan_start_date, plan_start_date=l_supply_plan_start_date
	where demand_plan_id=p_demand_plan_id;

	liability_preprocessor(l_supply_plan_id);

	commit;

end msd_eol_pre_download_hook;

FUNCTION get_supply_plan_start_date( p_plan_id IN NUMBER) return DATE
IS
CURSOR c_plan_start_date
is
select plan_start_date
from msc_plans
where
plan_id = p_plan_id ;

x_plan_start_date DATE ;

Begin
   OPEN  c_plan_start_date  ;
   FETCH  c_plan_start_date   INTO x_plan_start_date;
   CLOSE c_plan_start_date  ;

   return x_plan_start_date ;
END get_supply_plan_start_date ;

procedure liability_preprocessor(p_plan_id IN NUMBER )
IS

CURSOR c_sup_item_org is
select
SUPPLIER_ID,
SUPPLIER_SITE_ID ,
ORGANIZATION_ID ,
SR_INSTANCE_ID,
INVENTORY_ITEM_ID,
AUTHORIZATION_CODE,
cutoff_days,
INCLUDE_LIABILITY_AGREEMENT,
ASL_LIABILITY_AGREEMENT_BASIS
from
msc_asl_auth_details
where
plan_id = -1
/* and INCLUDE_LIABILITY_AGREEMENT = 1   This filter will remove any disabled agreement */
order
by
SR_INSTANCE_ID,
SUPPLIER_ID,
SUPPLIER_SITE_ID,
ORGANIZATION_ID,
INVENTORY_ITEM_ID,
TRANSACTION_ID ;

x_start_days  NUMBER ;
x_end_days NUMBER ;
x_prv_end_days NUMBER ;
x_supplier_id NUMBER ;
x_organization_id NUMBER ;
x_inventory_item_id NUMBER ;
x_sr_instance_id   NUMBER ;
x_prv_supplier_id NUMBER ;
x_prv_organization_id NUMBER ;
x_prv_inventory_item_id NUMBER ;
x_prv_sr_instance_id   NUMBER ;

BEGIN

x_prv_end_days := 0  ;
x_end_days := 0 ;

UPDATE   msc_item_suppliers
set  INCLUDE_LIABILITY_AGREEMENT = NULL ,
ASL_LIABILITY_AGREEMENT_BASIS =NULL
where
plan_id = p_plan_id;


commit ;


FOR x_sup_item_org  in c_sup_item_org

LOOP

IF  (nvl(x_prv_supplier_id, x_sup_item_org.supplier_id )   <> x_sup_item_org.supplier_id) or
   ( nvl( x_prv_organization_id , x_organization_id )  <>  x_sup_item_org.organization_id ) or
   (nvl(x_prv_sr_instance_id  ,x_sr_instance_id) <> x_sup_item_org.sr_instance_id )or
   ( nvl( x_prv_inventory_item_id , x_inventory_item_id ) <> x_sup_item_org.inventory_item_id)

 THEN

 x_prv_end_days  := 0 ;
 x_end_days := 0 ;
 end if ;


 UPDATE msc_asl_auth_details
 set start_days = x_end_days,
       end_days =  start_days + cutoff_days-1
  where
 PLAN_ID  = -1 and
SUPPLIER_ID  = x_sup_item_org.SUPPLIER_ID and
SUPPLIER_SITE_ID = x_sup_item_org.SUPPLIER_SITE_ID and
ORGANIZATION_ID  = x_sup_item_org.ORGANIZATION_ID and
SR_INSTANCE_ID = x_sup_item_org.SR_INSTANCE_ID and
INVENTORY_ITEM_ID = x_sup_item_org.INVENTORY_ITEM_ID and
AUTHORIZATION_CODE  = x_sup_item_org.AUTHORIZATION_CODE ;

 x_end_days  := x_sup_item_org.cutoff_days +  x_prv_end_days ;

x_prv_supplier_id := x_sup_item_org.supplier_id ;
x_prv_organization_id :=  x_sup_item_org. organization_id ;
x_prv_sr_instance_id  :=   x_sup_item_org.sr_instance_id ;
x_prv_inventory_item_id :=   x_sup_item_org.inventory_item_id ;
 x_prv_end_days  := x_end_days ;




UPDATE   msc_item_suppliers
set  INCLUDE_LIABILITY_AGREEMENT = x_sup_item_org. INCLUDE_LIABILITY_AGREEMENT ,
ASL_LIABILITY_AGREEMENT_BASIS = x_sup_item_org.ASL_LIABILITY_AGREEMENT_BASIS
where
SUPPLIER_ID  = x_sup_item_org.SUPPLIER_ID and
/*SUPPLIER_SITE_ID = x_sup_item_org.SUPPLIER_SITE_ID and */
ORGANIZATION_ID  = x_sup_item_org.ORGANIZATION_ID and
SR_INSTANCE_ID = x_sup_item_org.SR_INSTANCE_ID and
INVENTORY_ITEM_ID = x_sup_item_org.INVENTORY_ITEM_ID and
plan_id in (p_plan_id,-1) ;

commit ;

END LOOP ;

commit ;

END liability_preprocessor ;

procedure eol_post_archive(p_demand_plan_id number)
as

cursor c1 is
select count(*)
from msd_dp_parameters
where demand_plan_id=p_demand_plan_id
and stream_type='ARCHIVED';

cursor c2 is
select distinct selection_component,selection_value,supply_plan_name
from msd_dp_doc_dim_selections
where demand_plan_id=p_demand_plan_id
and dimension_code='MEAS'
and document_id=(select document_id from msd_dp_seeded_documents where document_name='MSD_SD_EOL_LWF' and demand_plan_id=p_demand_plan_id);

cursor c3 is
select parameter_id,input_demand_plan_id, input_scenario_id
from msd_dp_parameters
where demand_plan_id=p_demand_plan_id
and stream_type='ARCHIVED';

cursor c4(p_demand_plan_id number, p_scenario_id number) is
select max(revision)
from msd_dp_scenario_revisions
where demand_plan_id=p_demand_plan_id
and scenario_id=p_scenario_id;

cursor c5(p_parameter_type varchar2,p_parameter_name varchar2) is
select parameter_id
from msd_dp_parameters
where demand_plan_id=p_demand_plan_id
and parameter_type = p_parameter_type
and nvl(parameter_name,'@#$') = nvl(p_parameter_name,'@#$');

cursor c6 is
select selection_script
from msd_dp_seeded_doc_dimensions
where demand_plan_id=p_demand_plan_id
and dimension_code='MEAS'
and document_id=(select document_id from msd_dp_seeded_documents where document_name='MSD_SD_EOL_LWF' and demand_plan_id=p_demand_plan_id);

l_archived_count number;

l_list varchar2(4000);

l_supply_plan_name varchar2(100);

p_errcode varchar2(1000);

l_revision varchar2(10);

l_selection_script varchar2(1000);

l_pos number;

begin

		open c1;
		fetch c1 into l_archived_count;
		close c1;

		if l_archived_count <1 then

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
	 STREAM_TYPE)
        	SELECT
         p_demand_plan_id
         ,msd_dp_parameters_s.nextval
         ,par.PARAMETER_TYPE
         ,mds.supply_plan_name
         ,msd_common_utilities.get_bucket_start_date(sysdate,-23,6,'GREGORIAN')
         ,msd_common_utilities.get_bucket_start_date(sysdate,24,6,'GREGORIAN')
         ,par.OUTPUT_SCENARIO_ID
         ,mds.SCENARIO_ID
         ,mds.DEMAND_PLAN_ID
         ,nvl(mdsr.REVISION,-1)
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
	,par.STREAM_TYPE
  FROM
        msd_dp_parameters par,
        msd_dp_parameters par1,
        msd_dp_scenarios mds,
        msd_dp_scenario_revisions  mdsr
 WHERE
        par.DEMAND_PLAN_ID  = (select template_id from msd_demand_plans where demand_plan_id=p_demand_plan_id)
        and par.stream_type in ('ARCHIVED')
        and mds.demand_plan_id=mdsr.demand_plan_id(+)
        and par1.demand_plan_id=p_demand_plan_id
        and mds.demand_plan_id=p_demand_plan_id
        and par.archived_for_parameter=par1.parameter_type
        and par1.parameter_id=to_number(mds.associate_parameter)
        and mds.sc_type= 'ARCHIVED'
        and mds.scenario_id=mdsr.scenario_id(+)
        and nvl(mdsr.revision,-1)=(select nvl(max(revision),-1) from msd_dp_scenario_revisions where demand_plan_id=p_demand_plan_id
        									 and scenario_id=mdsr.scenario_id);

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
	 STREAM_TYPE)
		SELECT
         p_demand_plan_id
         ,msd_dp_parameters_s.nextval
         ,par.PARAMETER_TYPE
         ,mds.supply_plan_name
         ,msd_common_utilities.get_bucket_start_date(sysdate,-23,6,'GREGORIAN')
         ,msd_common_utilities.get_bucket_start_date(sysdate,24,6,'GREGORIAN')
         ,par.OUTPUT_SCENARIO_ID
         ,mds.SCENARIO_ID
         ,mds.DEMAND_PLAN_ID
         ,nvl(mdsr.REVISION,-1)
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
	,par.STREAM_TYPE
  FROM
        msd_dp_parameters par,
        msd_dp_parameters par1,
        msd_dp_scenario_revisions mdsr,
        msd_dp_scenarios mds
 WHERE
        par.DEMAND_PLAN_ID  = (select template_id from msd_demand_plans where demand_plan_id=p_demand_plan_id)
        and par.stream_type in ('ARCHIVED_TIM')
        and mds.demand_plan_id=mdsr.demand_plan_id(+)
        and par1.demand_plan_id=p_demand_plan_id
        and mds.demand_plan_id=p_demand_plan_id
        and par.archived_for_parameter=par1.parameter_type
        and par1.parameter_id=to_number(mds.associate_parameter)
        and mds.sc_type= 'ARCHIVED'
        and mds.scenario_id=mdsr.scenario_id(+)
        and nvl(mdsr.revision,0)>(select nvl(max(revision),-1)
                           from msd_dp_parameters mdp
        									 where mdp.demand_plan_id=p_demand_plan_id
        									 and mdp.parameter_type=par.parameter_type);

				select mp.compile_designator into l_supply_plan_name
				from msc_plans mp, msd_demand_plans mdp
				where mp.plan_id=mdp.liab_plan_id
				and mdp.demand_plan_id=p_demand_plan_id;

		else

				for c3_rec in c3
				loop
						l_revision:=null;

						open c4(c3_rec.input_demand_plan_id,c3_rec.input_scenario_id);
						fetch c4 into l_revision;
						close c4;

						update msd_dp_parameters
						set revision = nvl(l_revision,-1)
						where demand_plan_id=p_demand_plan_id
						and parameter_id=c3_rec.parameter_id;

				end loop;



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
	 STREAM_TYPE)
					SELECT
         p_demand_plan_id
         ,msd_dp_parameters_s.nextval
         ,par.PARAMETER_TYPE
         ,mds.supply_plan_name
         ,msd_common_utilities.get_bucket_start_date(sysdate,-23,6,'GREGORIAN')
         ,msd_common_utilities.get_bucket_start_date(sysdate,24,6,'GREGORIAN')
         ,par.OUTPUT_SCENARIO_ID
         ,mds.SCENARIO_ID
         ,mds.DEMAND_PLAN_ID
         ,decode(nvl(mdsr.revision,-1), nvl(mdp2.revision,-1) , -1 , mdsr.revision)
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
	,par.STREAM_TYPE
  FROM
        msd_dp_parameters par,
        msd_dp_parameters par1,
        (select mds1.demand_plan_id,mds1.scenario_id,nvl(max(mdsr1.revision),-1) revision
        from msd_dp_scenario_revisions mdsr1, msd_dp_scenarios mds1
        where mdsr1.scenario_id(+)=mds1.scenario_id
        and mdsr1.demand_plan_id(+)=mds1.demand_plan_id
        group by mds1.demand_plan_id,mds1.scenario_id) mdsr,
        msd_dp_scenarios mds,
        (select demand_plan_id,parameter_type,nvl(max(revision),-1) revision from msd_dp_parameters group by
                                                        demand_plan_id,parameter_type) mdp2
 WHERE
        par.DEMAND_PLAN_ID  = (select template_id from msd_demand_plans where demand_plan_id=p_demand_plan_id)
        and par.stream_type in ('ARCHIVED_TIM')
        and mdp2.demand_plan_id=mds.demand_plan_id
        and mdp2.parameter_type=par.parameter_type
        and mds.demand_plan_id=mdsr.demand_plan_id
        and par1.demand_plan_id=p_demand_plan_id
        and mds.demand_plan_id=p_demand_plan_id
        and par.archived_for_parameter=par1.parameter_type
        and par1.parameter_id=to_number(mds.associate_parameter)
        and mds.sc_type= 'ARCHIVED'
        and mds.scenario_id=mdsr.scenario_id;


		end if;


			select mp.compile_designator into l_supply_plan_name
				from msc_plans mp, msd_demand_plans mdp
				where mp.plan_id=mdp.liab_plan_id
				and mdp.demand_plan_id=p_demand_plan_id;



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
          p_demand_plan_id
         ,mdsd1.document_id
         ,mdds.DIMENSION_CODE
         ,mdds.ENABLED_FLAG
         ,mdds.MANDATORY_FLAG
         ,msd_archived_report_s.nextval+100
         ,mdds.SELECTION_TYPE
         ,mdds.SELECTION_COMPONENT
         ,mdds.SELECTION_VALUE
         ,mdds.SUPPLY_PLAN_FLAG
         ,l_supply_plan_name
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
         msd_dp_seeded_documents mdsd,
         msd_dp_seeded_documents mdsd1,
         msd_dp_doc_dim_selections mdds
   WHERE
   			 mdsd.document_name='MSD_SD_EOL_LWF'
   			 and mdsd.demand_plan_id= (select template_id from msd_demand_plans where demand_plan_id=p_demand_plan_id)
   			 and mdsd1.document_name=mdsd.document_name
         and mdsd1.demand_plan_id=p_demand_plan_id
         and mdds.demand_plan_id=mdsd.demand_plan_id
         and mdds.document_id=mdsd.document_id
         and mdds.dimension_code='MEAS';


	open c6;
	fetch c6 into l_selection_script;
	close c6;

	for c2_rec in c2
	loop

		for c5_rec in c5(c2_rec.selection_value,c2_rec.supply_plan_name)
		loop

					l_pos := instr(nvl(l_selection_script,'@#$'),c5_rec.parameter_id);
					if l_pos = 0 then
								update msd_dp_seeded_doc_dimensions
								set selection_script=selection_script||'V.'||c2_rec.selection_component||c5_rec.parameter_id||fnd_global.local_chr(10)
								where demand_plan_id=p_demand_plan_id
								and document_id=(select document_id from msd_dp_seeded_documents where document_name='MSD_SD_EOL_LWF' and demand_plan_id=p_demand_plan_id)
								and dimension_code='MEAS';
					end if;

		end loop;

	end loop;

	msd_apply_template_demand_plan.create_seeded_definitions(p_demand_plan_id, p_errcode);

	commit;

exception
	when others then
		null;

end eol_post_archive;

END MSD_EOL_PLAN;


/
