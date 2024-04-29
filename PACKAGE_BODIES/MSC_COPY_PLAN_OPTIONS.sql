--------------------------------------------------------
--  DDL for Package Body MSC_COPY_PLAN_OPTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_COPY_PLAN_OPTIONS" AS
/* $Header: MSCCPPOB.pls 120.8.12010000.5 2010/03/23 10:17:00 skakani ship $  */

Type tname_type is table of Varchar2(30);

L_Temp_Plan varchar2(1) default 'N';
L_Plan_id number;
L_Designator_id number;
v_prev_designator_id number;

PROCEDURE copy_plan_options(
                     p_source_plan_id     IN number,
                     p_dest_plan_name     IN varchar2,
                     p_dest_plan_desc     IN varchar2,
                     p_dest_plan_type     IN number,
                     p_dest_atp           IN number,
                     p_dest_production    IN number,
                     p_dest_notifications IN number,
                     p_dest_inactive_on   IN date,
                     p_organization_id    IN number,
                     p_sr_instance_id     IN number) IS


v_designator_id      number;
v_designator_type    number;
v_dest_plan_id       number;
v_compile_designator varchar2(75);
v_statement          varchar2(32000);
v_statement1          varchar2(32000);
l_return_status      varchar2(10);
l_msg_out    	     varchar2(200);
l_org_selection      number;
l_collected_flag     number;
l_copy_plan          number := 2;
--l_session_id number;


i number := 0;
error_getting_partition exception ;

v_col_value Copy_Plan_Options_Type;
v_tab_Sql_Stmt Copy_Plan_Source_Tables_Type ;
l_count number := 0;

BEGIN
  --msc_util.init_message;
  inti_pl_sql_table(v_tab_Sql_Stmt);
  if nvl(L_Temp_plan,'N') = 'N' Then
         v_dest_plan_id :=  MSC_MANAGE_PLAN_PARTITIONS.get_plan(
                                                    		p_dest_plan_name,
                                                    		l_return_status, l_msg_out);
        if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
             v_statement := l_msg_out;
             raise Error_getting_partition;
        end if;
        L_plan_id := v_dest_plan_id;
  else
        v_dest_plan_id := L_plan_id;
  end if;

  if NVL(L_Temp_plan,'N') = 'N' then
	  select msc_designators_s.nextval
	  into v_designator_id
	  from dual;
        L_designator_id := v_designator_id;
  else
  	v_designator_id := L_designator_id;
  end if;
  select decode(p_dest_plan_type, 1, 3,
                                  2, 2,
                                  3, 4,
                                  4, 5,
                                  5,8,
                                  6,9,
                                  7,10,
                                  8,11,
                                  9,12)
  into v_designator_type
  from dual;

  select nvl(organization_selection,3),designator_id
  into l_org_selection , v_prev_designator_id
  from msc_designators
  where designator =  (select compile_designator
                       from msc_plans
                       where plan_id = p_source_plan_id)
  and   organization_id = p_organization_id
  and   sr_instance_id =  p_sr_instance_id;


  l_collected_flag := 2;
  v_col_value(1).P_DESIGNATOR_ID		:= v_designator_id ;
  v_col_value(1).P_DEST_PLAN_ID			:= v_dest_plan_id ;
  v_col_value(1).P_DEST_PLAN_NAME		:= p_dest_plan_name ;
  v_col_value(1).P_DEST_PLAN_TYPE		:= p_dest_plan_type ;
  v_col_value(1).P_DEST_PLAN_DESC		:= p_dest_plan_desc ;
  v_col_value(1).P_SOURCE_PLAN_ID		:= p_source_plan_id ;
  v_col_value(1).P_DESIGNATOR_TYPE		:= v_designator_type ;
  v_col_value(1).P_ORGANIZATION_ID		:= p_organization_id ;
  v_col_value(1).P_MPS_RELIEF			:= 1;
  v_col_value(1).P_INVENTORY_ATP_FLAG		:= p_dest_atp ;
  v_col_value(1).P_PRODUCTION			:= p_dest_production ;
  v_col_value(1).P_LAUNCH_WORKFLOW_FLAG		:= p_dest_notifications ;
  v_col_value(1).P_DESCRIPTION			:= p_dest_plan_desc ;
  v_col_value(1).P_DISABLE_DATE			:= p_dest_inactive_on ;
  v_col_value(1).P_COLLECTED_FLAG		:= l_collected_flag ;
  v_col_value(1).P_SR_INSTANCE_ID		:= p_sr_instance_id ;
  v_col_value(1).P_REFRESH_NUMBER		:= l_org_selection ;
  v_col_value(1).P_ORGANIZATION_SELECTION	:= 2 ;
  v_col_value(1).P_COPY_PLAN			:= l_copy_plan ;
  v_col_value(1).P_LAST_UPDATE_DATE		:= sysdate ;
  v_col_value(1).P_LAST_UPDATED_BY		:= fnd_global.user_id ;
  v_col_value(1).P_CREATION_DATE		:= sysdate ;
  v_col_value(1).P_CREATED_BY			:= fnd_global.user_id ;
  v_col_value(1).P_LAST_UPDATE_LOGIN		:= fnd_global.login_id ;

  inti_pl_sql_table(v_tab_Sql_Stmt);

  for var in 1..v_tab_Sql_Stmt.count
  loop
       -- msc_util.debug_message(to_number(var) , 'Start '||v_tab_Sql_Stmt(to_number(var)).p_table_name);
	generate_sql_script(v_col_value , v_tab_Sql_Stmt(to_number(var)).p_table_name) ;
	--msc_util.debug_message(to_number(var) , 'End '||v_tab_Sql_Stmt(to_number(var)).p_table_name);

  end loop;
  commit;

  EXCEPTION
    when no_data_found
      then null;
    when others then

  raise_application_error(-20000,sqlerrm||':'||v_statement||
                    'p_source_plan_id' || p_source_plan_id||' ' ||
                     'p_dest_plan_name' ||p_dest_plan_name||' '  ||
                      'p_dest_plan_desc' ||p_dest_plan_desc||' '  ||
                      'p_dest_plan_type' ||p_dest_plan_type||' ' ||
                      'p_dest_atp' ||p_dest_atp||' ' ||
                      'p_dest_production' ||p_dest_production||' '  ||
                      'p_dest_notifications' ||p_dest_notifications||' '  ||
                      'p_dest_inactive_on' ||p_dest_inactive_on ||' ' ||
                      'p_organization_id' ||p_organization_id||' ' ||
                      'p_sr_instance_id' ||p_sr_instance_id);
END copy_plan_options;

-- --------------------------
-- PROCEDURE copy_firm_orders
-- --------------------------

PROCEDURE copy_firm_orders(
				errbuf 		 out NOCOPY varchar2,
				retcode 	 out NOCOPY number,
				P_source_plan_id IN  	    number,
				P_dest_plan_id   IN  	    number) is

	TYPE v_col_list_typ is table of varchar2(30);
	v_supp_col_list v_col_list_typ := v_col_list_typ('TRANSACTION_ID'
							,'ORGANIZATION_ID'
							,'SR_INSTANCE_ID'
							,'INVENTORY_ITEM_ID'
							,'SCHEDULE_DESIGNATOR_ID'
							,'REVISION'
							,'UNIT_NUMBER'
							,'NEW_SCHEDULE_DATE'
							,'OLD_SCHEDULE_DATE'
							,'NEW_WIP_START_DATE'
							,'OLD_WIP_START_DATE'
							,'FIRST_UNIT_COMPLETION_DATE'
							,'LAST_UNIT_COMPLETION_DATE'
							,'FIRST_UNIT_START_DATE'
							,'LAST_UNIT_START_DATE'
							,'DISPOSITION_ID'
							,'DISPOSITION_STATUS_TYPE'
							,'ORDER_TYPE'
							,'SUPPLIER_ID'
							,'SUPPLIER_SITE_ID'
							,'NEW_ORDER_QUANTITY'
							,'OLD_ORDER_QUANTITY'
							,'NEW_ORDER_PLACEMENT_DATE'
							,'OLD_ORDER_PLACEMENT_DATE'
							,'RESCHEDULE_DAYS'
							,'RESCHEDULE_FLAG'
							,'SCHEDULE_COMPRESS_DAYS'
							,'NEW_PROCESSING_DAYS'
							,'PURCH_LINE_NUM'
							,'QUANTITY_IN_PROCESS'
							,'IMPLEMENTED_QUANTITY'
							,'FIRM_PLANNED_TYPE'
							,'FIRM_QUANTITY'
							,'FIRM_DATE'
							,'IMPLEMENT_DEMAND_CLASS'
							,'IMPLEMENT_DATE'
							,'IMPLEMENT_QUANTITY'
							,'IMPLEMENT_FIRM'
							,'IMPLEMENT_WIP_CLASS_CODE'
							,'IMPLEMENT_JOB_NAME'
							,'IMPLEMENT_DOCK_DATE'
							,'IMPLEMENT_STATUS_CODE'
							,'IMPLEMENT_EMPLOYEE_ID'
							,'IMPLEMENT_UOM_CODE'
							,'IMPLEMENT_LOCATION_ID'
							,'IMPLEMENT_SOURCE_ORG_ID'
							,'IMPLEMENT_SR_INSTANCE_ID'
							,'IMPLEMENT_SUPPLIER_ID'
							,'IMPLEMENT_SUPPLIER_SITE_ID'
							,'IMPLEMENT_AS'
							,'RELEASE_STATUS'
							,'LOAD_TYPE'
							,'PROCESS_SEQ_ID'
							,'SCO_SUPPLY_FLAG'
							,'ALTERNATE_BOM_DESIGNATOR'
							,'ALTERNATE_ROUTING_DESIGNATOR'
							,'OPERATION_SEQ_NUM'
							,'BY_PRODUCT_USING_ASSY_ID'
							,'SOURCE_ORGANIZATION_ID'
							,'SOURCE_SR_INSTANCE_ID'
							,'SOURCE_SUPPLIER_SITE_ID'
							,'SOURCE_SUPPLIER_ID'
							,'SHIP_METHOD'
							,'WEIGHT_CAPACITY_USED'
							,'VOLUME_CAPACITY_USED'
							,'NEW_SHIP_DATE'
							,'NEW_DOCK_DATE'
							,'OLD_DOCK_DATE'
							,'LINE_ID'
							,'PROJECT_ID'
							,'TASK_ID'
							,'PLANNING_GROUP'
							,'IMPLEMENT_PROJECT_ID'
							,'IMPLEMENT_TASK_ID'
							,'IMPLEMENT_SCHEDULE_GROUP_ID'
							,'IMPLEMENT_BUILD_SEQUENCE'
							,'IMPLEMENT_ALTERNATE_BOM'
							,'IMPLEMENT_ALTERNATE_ROUTING'
							,'IMPLEMENT_UNIT_NUMBER'
							,'IMPLEMENT_LINE_ID'
							,'RELEASE_ERRORS'
							,'NUMBER1'
							,'SOURCE_ITEM_ID'
							,'ORDER_NUMBER'
							,'SCHEDULE_GROUP_ID'
							,'BUILD_SEQUENCE'
							,'WIP_ENTITY_NAME'
							,'IMPLEMENT_PROCESSING_DAYS'
							,'DELIVERY_PRICE'
							,'LATE_SUPPLY_DATE'
							,'LATE_SUPPLY_QTY'
							,'LOT_NUMBER'
							,'SUBINVENTORY_CODE'
							,'QTY_SCRAPPED'
							,'EXPECTED_SCRAP_QTY'
							,'QTY_COMPLETED'
							,'DAILY_RATE'
							,'SCHEDULE_GROUP_NAME'
							,'UPDATED'
							,'SUBST_ITEM_FLAG'
							,'STATUS'
							,'APPLIED'
							,'EXPIRATION_QUANTITY'
							,'EXPIRATION_DATE'
							,'NON_NETTABLE_QTY'
							,'IMPLEMENT_WIP_START_DATE'
							,'REFRESH_NUMBER'
							,'REQUEST_ID'
							,'PROGRAM_APPLICATION_ID'
							,'PROGRAM_ID'
							,'PROGRAM_UPDATE_DATE'
							,'IMPLEMENT_DAILY_RATE'
							,'NEED_BY_DATE'
							,'SOURCE_SUPPLY_ID'
							,'SR_MTL_SUPPLY_ID'
							,'WIP_STATUS_CODE'
							,'DEMAND_CLASS'
							,'FROM_ORGANIZATION_ID'
							,'WIP_SUPPLY_TYPE'
							,'PO_LINE_ID'
							,'LOAD_FACTOR_RATE'
							,'ROUTING_SEQUENCE_ID'
							,'BILL_SEQUENCE_ID'
							,'COPRODUCTS_SUPPLY'
							,'CFM_ROUTING_FLAG'
							,'CUSTOMER_ID'
							,'SHIP_TO_SITE_ID'
							,'OLD_NEED_BY_DATE'
							,'OLD_DAILY_RATE'
							,'OLD_FIRST_UNIT_START_DATE'
							,'OLD_LAST_UNIT_COMPLETION_DATE'
							,'OLD_NEW_SCHEDULE_DATE'
							,'OLD_QTY_COMPLETED'
							,'OLD_NEW_ORDER_QUANTITY'
							,'OLD_FIRM_QUANTITY'
							,'OLD_FIRM_DATE'
							,'PLANNING_PARTNER_SITE_ID'
							,'PLANNING_TP_TYPE'
							,'OWNING_PARTNER_SITE_ID'
							,'OWNING_TP_TYPE'
							,'VMI_FLAG'
							,'EARLIEST_START_DATE'
							,'EARLIEST_COMPLETION_DATE'
							,'MIN_START_DATE'
							,'SCHEDULED_DEMAND_ID'
							,'EXPLOSION_DATE'
							,'SCO_SUPPLY_DATE'
							,'RECORD_SOURCE'
							,'SUPPLY_IS_SHARED'
							,'ULPSD'
							,'ULPCD'
							,'UEPSD'
							,'UEPCD'
							,'EACD'
							,'ORIGINAL_NEED_BY_DATE'
							,'ORIGINAL_QUANTITY'
							,'ACCEPTANCE_REQUIRED_FLAG'
							);
	v_res_col_list v_col_list_typ :=v_col_list_typ(	'TRANSACTION_ID'
							,'SUPPLY_ID'
							,'ORGANIZATION_ID'
							,'SR_INSTANCE_ID'
							,'ROUTING_SEQUENCE_ID'
							,'OPERATION_SEQUENCE_ID'
							,'RESOURCE_SEQ_NUM'
							,'RESOURCE_ID'
							,'DEPARTMENT_ID'
							,'ALTERNATE_NUM'
							,'START_DATE'
							,'END_DATE'
							,'BKT_START_DATE'
							,'RESOURCE_HOURS'
							,'SET_UP'
							,'BKT_END_DATE'
							,'TEAR_DOWN'
							,'AGGREGATE_RESOURCE_ID'
							,'SCHEDULE_FLAG'
							,'PARENT_ID'
							,'STD_OP_CODE'
							,'WIP_ENTITY_ID'
							,'ASSIGNED_UNITS'
							,'BASIS_TYPE'
							,'OPERATION_SEQ_NUM'
							,'LOAD_RATE'
							,'DAILY_RESOURCE_HOURS'
							,'STATUS'
							,'APPLIED'
							,'UPDATED'
							,'SUBST_RES_FLAG'
							,'REFRESH_NUMBER'
							,'REQUEST_ID'
							,'PROGRAM_APPLICATION_ID'
							,'PROGRAM_ID'
							,'PROGRAM_UPDATE_DATE'
							,'SOURCE_ITEM_ID'
							,'ASSEMBLY_ITEM_ID'
							,'SUPPLY_TYPE'
							,'FIRM_START_DATE'
							,'FIRM_END_DATE'
							,'FIRM_FLAG'
							,'CUMMULATIVE_QUANTITY'
							,'YIELD'
							,'REVERSE_CUMULATIVE_YIELD'
							,'BATCH_NUMBER'
							,'MINIMUM_TRANSFER_QUANTITY'
							,'REMAINING_CAPACITY'
							,'OVERLOADED_CAPACITY'
							,'EARLIEST_START_DATE'
							,'EARLIEST_COMPLETION_DATE'
							,'SCHEDULED_DEMAND_ID'
							,'ULPSD'
							,'ULPCD'
							,'UEPSD'
							,'UEPCD'
							,'EACD'
							,'PARENT_SEQ_NUM');
        v_tname_tab tname_type := tname_type('MSC_SUPPLIES','MSC_RESOURCE_REQUIREMENTS');
	v_select_cols varchar2(8000);
	v_insert_cols varchar2(8000);
	v_from_where_supplies varchar2(8000);
	v_from_where_res_req  varchar2(8000);
	v_table_name   varchar2(30);
	v_column_name  varchar2(30);
	v_insert_who   varchar2(4000):= ',last_update_date,' ||
                            		'last_updated_by,'  ||
                            		'creation_date,'    ||
                            		'created_by,'       ||
                            		'last_update_login ';
	v_select_who   varchar2(4000):= ',sysdate,' 		||
                            		'fnd_global.user_id,'   ||
                            		'sysdate,'  		||
                            		'fnd_global.user_id,' 	||
                            		'fnd_global.user_id ';
        v_sys_yes      integer := 1;
        v_planned_order number:= 5;
	v_from_where   varchar2(2000);
	v_statement    varchar2(12000);
	v_stmt_temp    varchar2(500);
	j              integer;

Begin

	v_from_where_supplies := ' FROM  msc_supplies ' ||
				 ' WHERE  msc_supplies.plan_id = :Source_Plan_Id'||
    				 ' and    msc_supplies.order_type = :Planned_Order' ;

  	v_from_where_res_req := ' from msc_resource_requirements  ' ||
				' where msc_resource_requirements.plan_id=:Source_Plan_Id ' ;

	for i in 1..v_tname_tab.count LOOP
		v_table_name := v_tname_tab(i);
		v_select_cols:= null;
		 if v_table_name = 'MSC_SUPPLIES' then
			for i in v_supp_col_list.first..v_supp_col_list.last loop
				if v_select_cols is null then
                        		v_select_cols := v_table_name || '.' ||v_supp_col_list(i);
                        		v_insert_cols := v_supp_col_list(i);
                      		else
                        		v_select_cols := v_select_cols||',' || v_table_name || '.' ||v_supp_col_list(i);
                        		v_insert_cols := v_insert_cols||',' || v_supp_col_list(i);
                      		end if;
			end loop;
			v_supp_col_list.delete;
		elsif  v_table_name = 'MSC_RESOURCE_REQUIREMENTS' then
			for i in v_res_col_list.first..v_res_col_list.last loop
                                if v_select_cols is null then
                                        v_select_cols := v_table_name || '.' ||v_res_col_list(i);
                                        v_insert_cols := v_res_col_list(i);
                                else
                                        v_select_cols := v_select_cols||',' || v_table_name || '.' ||v_res_col_list(i);
                                        v_insert_cols := v_insert_cols||',' || v_res_col_list(i);
                                end if;
                        end loop;
			v_res_col_list.delete;
		end if;
		if v_table_name = 'MSC_SUPPLIES' then
		    v_from_where :=  v_from_where_supplies;
		elsif v_table_name = 'MSC_RESOURCE_REQUIREMENTS' then
		    v_from_where := v_from_where_res_req;
		end if;
		v_statement := 'INSERT into '	||v_table_name ||'(plan_id, '|| v_insert_cols || v_insert_who || ')'
  						|| ' SELECT  :Dest_Plan_Id, '|| v_select_cols  || v_select_who
  						|| v_from_where;

		if v_table_name = 'MSC_SUPPLIES' then
		      EXECUTE IMMEDIATE v_statement
			USING p_dest_plan_id,p_source_plan_id, v_Planned_Order  ;
		elsif v_table_name = 'MSC_RESOURCE_REQUIREMENTS' then
		      EXECUTE IMMEDIATE v_statement
			USING p_dest_plan_id, p_source_plan_id ;
		end if;
	end loop;
	Commit;
	retcode := 0;
	errbuf  := NULL;
EXCEPTION
	when others then
		retcode := 2;
	        errbuf := sqlerrm;
END Copy_Firm_Orders;

PROCEDURE delete_temp_plan( 	errbuf 	   out NOCOPY varchar2,
				retcode    out NOCOPY number,
				P_desig_id IN  	      number,
				p_childreq IN 	      boolean default false) is

	v_request_id       number;
	ods_plan exception;

Begin

  if p_desig_id = -1 then
    raise ods_plan;
  end if;
  v_request_id := Fnd_Request.Submit_Request
  			     (	'MSC', 'MSCPRG', '', '', p_childreq,
				P_desig_id, chr(0),
				'','','','','','','','','','','','','','','','','','','','',
				'','','','','','','','','','','','','','','','','','','','',
				'','','','','','','','','','','','','','','','','','','','',
				'','','','','','','','','','','','','','','','','','','','',
				'','','','','','','','','','','','','','','','','','');
  if v_request_id <> 0 then
	if p_childreq then
        	fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
                                     request_data => to_char(v_request_id)) ;
	end if;
 	msc_util.msc_debug('Submitted request for plan deletion '||v_request_id);
  end if;
	retcode := 0;
	errbuf := NULL;

EXCEPTION
    when  ODS_PLAN then
	retcode := 2;
        errbuf := 'desig id is -1';
    when others then
	retcode := 2;
        errbuf := sqlerrm;
End delete_temp_plan;

PROCEDURE delete_plan_options(  errbuf    out NOCOPY varchar2,
				retcode   out NOCOPY number,
				P_plan_id IN  	     number) is

	v_statement varchar2(1000);
	v_tname_tab tname_type :=tname_type(
					'MSC_PLANS',
					'MSC_SUB_INVENTORIES',
					'MSC_PLAN_SCHEDULES',
					'MSC_PLAN_ORGANIZATIONS'	);
	v_tab_name varchar2(30);
	ods_plan exception;
Begin

  delete msc_designators
  where (designator, organization_id, sr_instance_id) in (select
         compile_designator, organization_id, sr_instance_id
         from msc_plans
         where plan_id=P_PLAN_ID);

  if P_plan_id = -1 then
    raise ods_plan;
  end if;

  FOR i in 1..v_tname_tab.count LOOP
	v_tab_name:= v_tname_tab(i);
	v_statement := 'delete from ' || v_tab_name || ' where plan_id=' || ':p_plan_id';

	EXECUTE IMMEDIATE v_statement USING p_plan_id;

   end loop;
   retcode := 0;
   errbuf  := NULL;
EXCEPTION
    when  ods_plan then
	retcode := 2;
	errbuf := 'plan_id is -1';
    when others then
        retcode := 2;
        errbuf := sqlerrm||' '||v_statement;

End Delete_plan_options;

PROCEDURE link_plans(
			errbuf		out NOCOPY varchar2,
			retcode		out NOCOPY number,
			p_src_plan_id   in  	   number,
			p_src_Desg_id   in  	   number,
			p_plan_id 	out NOCOPY number,
			p_designator_id out NOCOPY number) is

	NULL_PLAN_ID EXCEPTION;
Begin
	if L_PLAN_ID IS NULL
	   or  L_Designator_id is null then
	   raise NULL_PLAN_ID;
	end if;
	p_plan_id := l_plan_id;
	p_designator_id := l_designator_id;

	update MSC_PLANS
	set copy_plan_id = p_src_Plan_id
	where plan_id = p_plan_id;

	update MSC_DESIGNATORS
	set   copy_Designator_id = p_src_Desg_id
	Where designator_id = p_designator_id;
        retcode := 0;
	errbuf  := NULL;
exception
when null_plan_id then
	retcode := 2;
	errbuf  := 'plan id is null';
when others then
retcode := 2;
errbuf  := sqlerrm;

end link_plans;

PROCEDURE init_plan_id(p_temp_plan in varchar2, p_plan_id in number, p_designator_id in number) is
Begin

	-- ---------------------------------
	-- Re-set Pvt. Package variables.
	-- ---------------------------------
	l_temp_plan := p_temp_plan;
	l_plan_id := p_plan_id;
        l_designator_id := p_designator_id;

end init_plan_id;

PROCEDURE inti_pl_sql_table(p_source_table in out NOCOPY Copy_Plan_Source_Tables_Type )
is
l_count number;
Begin
l_count := p_source_table.count;

if nvl(l_count , 0) > 0 then
	p_source_table.delete;
end if;

p_source_table(nvl(p_source_table.count , 0) + 1).p_table_name := 'MSC_DESIGNATORS';
p_source_table(nvl(p_source_table.count , 0) + 1).p_table_name := 'MSC_PLANS';
p_source_table(nvl(p_source_table.count , 0) + 1).p_table_name := 'MSC_PLAN_ORGANIZATIONS';
p_source_table(nvl(p_source_table.count , 0) + 1).p_table_name := 'MSC_PLAN_SCHEDULES';
p_source_table(nvl(p_source_table.count , 0) + 1).p_table_name := 'MSC_SUB_INVENTORIES';
p_source_table(nvl(p_source_table.count , 0) + 1).p_table_name := 'MSC_PLANS_OTHER';
p_source_table(nvl(p_source_table.count , 0) + 1).p_table_name := 'MSC_PLAN_CATEGORIES';
p_source_table(nvl(p_source_table.count , 0) + 1).p_table_name := 'MSC_SOLVER_GROUPS';
p_source_table(nvl(p_source_table.count , 0) + 1).p_table_name := 'MSC_SOL_GRP_RES';
p_source_table(nvl(p_source_table.count , 0) + 1).p_table_name := 'MSC_WRK_ORD_BD_STRUCTURE';

End inti_pl_sql_table;

FUNCTION get_column_name(p_bind_var_col in Copy_Plan_Options_Type
			 , p_source_table in varchar2
                         , p_column_name varchar2)
return varchar2  is
l_temp varchar2(4000);
l_count number ;
begin
if p_source_table = 'MSC_DESIGNATORS' then

select decode(p_column_name ,'DESIGNATOR_ID' ,  nvl(to_char(p_bind_var_col(1).P_DESIGNATOR_ID ) , 'null')
                                    ,'DESIGNATOR' , ''''||p_bind_var_col(1).P_DEST_PLAN_NAME||''''
				      ,'DESIGNATOR_TYPE' , nvl(to_char( p_bind_var_col(1).P_DESIGNATOR_TYPE),'null')
				      ,'ORGANIZATION_ID' , nvl(to_char(p_bind_var_col(1).P_ORGANIZATION_ID) , 'null')
				      ,'MPS_RELIEF' , nvl(to_char(p_bind_var_col(1).P_MPS_RELIEF),'null')
				      ,'INVENTORY_ATP_FLAG' , nvl(to_char(p_bind_var_col(1).P_INVENTORY_ATP_FLAG),'null')
				      ,'PRODUCTION' , nvl(to_char(p_bind_var_col(1).P_PRODUCTION), 'null')
				      ,'LAUNCH_WORKFLOW_FLAG' , nvl(to_char(p_bind_var_col(1).P_LAUNCH_WORKFLOW_FLAG) ,'null')
				      ,'DESCRIPTION' , ':DESCRIPTION' --''''||p_bind_var_col(1).P_DESCRIPTION||''''
				      ,'DISABLE_DATE' , ''''||decode(p_bind_var_col(1).P_DISABLE_DATE , null ,
				       p_bind_var_col(1).P_DISABLE_DATE
				      ,to_char(p_bind_var_col(1).P_DISABLE_DATE , 'DD-MON-RRRR'))||''''
				      ,'SR_INSTANCE_ID' , nvl(to_char(p_bind_var_col(1).P_SR_INSTANCE_ID),'null')
				      ,'REFRESH_NUMBER' , nvl(to_char( p_bind_var_col(1).P_REFRESH_NUMBER) , 'null')
				      ,'ORGANIZATION_SELECTION' , nvl(to_char( p_bind_var_col(1).P_ORGANIZATION_SELECTION) , 'null')
				      ,'LAST_UPDATE_DATE' ,''''||to_char(p_bind_var_col(1).P_LAST_UPDATE_DATE , 'DD-MON-RRRR')||''''
				      ,'LAST_UPDATED_BY' , nvl(to_char( p_bind_var_col(1).P_LAST_UPDATED_BY) ,'null')
				      ,'CREATION_DATE' , ''''||to_char(p_bind_var_col(1).P_CREATION_DATE , 'DD-MON-RRRR')||''''
				      ,'CREATED_BY' ,  nvl(to_char(p_bind_var_col(1).P_CREATED_BY),'null')
				      , p_column_name /* 'null' */ ) into l_temp from dual;

elsif p_source_table = 'MSC_PLANS' then

select decode(p_column_name ,'LAST_UPDATE_DATE' , ''''||to_char(p_bind_var_col(1).P_LAST_UPDATE_DATE , 'DD-MON-RRRR')||''''
				      ,'LAST_UPDATED_BY' , nvl(to_char( p_bind_var_col(1).P_LAST_UPDATED_BY) ,'null')
				      ,'CREATION_DATE' , ''''||to_char(p_bind_var_col(1).P_CREATION_DATE , 'DD-MON-RRRR')||''''
				      ,'CREATED_BY' ,  nvl(to_char(p_bind_var_col(1).P_CREATED_BY),'null')
				      ,'LAST_UPDATE_LOGIN' ,nvl(to_char( p_bind_var_col(1).P_LAST_UPDATE_LOGIN),'null')
				      ,'COPY_PLAN' , nvl(to_char( p_bind_var_col(1).P_COPY_PLAN ) ,'null')
				      ,'PLAN_ID' , nvl(to_char(p_bind_var_col(1).P_DEST_PLAN_ID ) ,'null')
				      ,'COMPILE_DESIGNATOR' ,''''||p_bind_var_col(1).P_DEST_PLAN_NAME||''''
				      ,'CURR_PLAN_TYPE' , nvl(to_char( p_bind_var_col(1).P_DEST_PLAN_TYPE) , 'null')
				      ,'PLAN_TYPE' ,  nvl(to_char(p_bind_var_col(1).P_DEST_PLAN_TYPE),'null')
				      ,'DESCRIPTION' , ':DESCRIPTION' --''''||p_bind_var_col(1).P_DEST_PLAN_DESC||''''
				      ,'PLAN_COMPLETION_DATE' , 'null'
				      ,'PLAN_START_DATE' , 'null'
				      ,'DATA_COMPLETION_DATE' , 'null'
				      ,'PLAN_RUN_DATE' , 'null'
				      ,'ORGANIZATION_SELECTION' , nvl(to_char(p_bind_var_col(1).P_REFRESH_NUMBER),'null')
				      , p_column_name) into l_temp from dual;

elsif p_source_table in ('MSC_PLAN_SCHEDULES', 'MSC_PLAN_ORGANIZATIONS', 'MSC_SUB_INVENTORIES', 'MSC_PLANS_OTHER', 'MSC_PLAN_CATEGORIES','MSC_SOLVER_GROUPS','MSC_SOL_GRP_RES','MSC_WRK_ORD_BD_STRUCTURE' ) then

select decode(p_column_name ,'LAST_UPDATE_DATE' ,''''||to_char(p_bind_var_col(1).P_LAST_UPDATE_DATE , 'DD-MON-RRRR')||''''
				      ,'LAST_UPDATED_BY' , nvl(to_char(p_bind_var_col(1).P_LAST_UPDATED_BY),'null')
				      ,'CREATION_DATE' ,''''||to_char( p_bind_var_col(1).P_CREATION_DATE , 'DD-MON-RRRR')||''''
				      ,'CREATED_BY' ,  nvl(to_char(p_bind_var_col(1).P_CREATED_BY),'null')
				      ,'LAST_UPDATE_LOGIN' , nvl(to_char(p_bind_var_col(1).P_LAST_UPDATE_LOGIN),'null')
				      ,'PLAN_ID' , nvl(to_char(p_bind_var_col(1).P_DEST_PLAN_ID),'null')
				      , p_column_name) into l_temp from dual;

end if;

return l_temp ;
end;


PROCEDURE generate_sql_script(p_bind_var_col in Copy_Plan_Options_Type
			     , p_table_name varchar2)
is
l_count number ;
i number := 0;
v_statement varchar2(32000);
v_statement1 varchar2(32000);
l_col_value varchar2(2000);

v_msc_schema     VARCHAR2(32);
lv_retval        boolean;
lv_dummy1        varchar2(32);
lv_dummy2        varchar2(32);


cursor cur_design(l_table_name varchar2 , l_owner varchar2) is
select column_name , data_type , data_length
from all_tab_cols
where table_name = l_table_name
and owner = l_owner
and (VIRTUAL_COLUMN = 'NO'
     AND HIDDEN_COLUMN='NO');

Begin
lv_retval := FND_INSTALLATION.GET_APP_INFO ('MSC', lv_dummy1, lv_dummy2,v_msc_schema);
if p_table_name = 'MSC_DESIGNATORS' then
 v_statement := 'INSERT INTO '||p_table_name||' (DESIGNATOR ,DESCRIPTION '  ;
 v_statement1 := ' SELECT :DESIGNATOR , :DESCRIPTION ' ;
 for var in cur_design(p_table_name , v_msc_schema)
  loop
              if  var.column_name not in ('DESIGNATOR' ,'DESCRIPTION')  then
		v_statement := v_statement||' , '||var.column_name ;
		v_statement1 := v_statement1||' , '||Get_Column_Value(p_bind_var_col ,var.column_name , var.data_type ,	p_table_name );
              end if;
  end loop;
	  v_statement := v_statement||' ) ' ;
	  --msc_util.debug_message(1 ,v_statement);
	  v_statement1 := v_statement1||' FROM '||p_table_name||' where designator_id = '||v_prev_designator_id  ;
	  --msc_util.debug_message(2 ,v_statement1);
	  v_statement := v_statement||' '||v_statement1;
	  --msc_util.debug_message(1 ,'Start '|| p_table_name);
	  --msc_util.debug_message(1 ,v_statement);

	  EXECUTE IMMEDIATE v_statement using p_bind_var_col(1).P_DEST_PLAN_NAME ,p_bind_var_col(1).P_DESCRIPTION ;

	  --msc_util.debug_message(1 ,'End '|| p_table_name);
elsif p_table_name = 'MSC_PLANS' then
      v_statement := 'INSERT INTO '||p_table_name||' (COMPILE_DESIGNATOR ,DESCRIPTION '  ;
      v_statement1 := ' SELECT :COMPILE_DESIGNATOR , :DESCRIPTION ' ;
--6028814
       for var in cur_design(p_table_name , v_msc_schema)
	loop
	  if  var.column_name not in ('COMPILE_DESIGNATOR' ,'DESCRIPTION',
                                      'REQUEST_ID', 'PUBLISH_FCST_VERSION')  then
	        v_statement  := v_statement||' , '||var.column_name ;
		v_statement1 := v_statement1||' , '||Get_Column_Value(p_bind_var_col ,var.column_name , var.data_type ,p_table_name );

	  end if;
	end loop;
	  v_statement  := v_statement||' ) ';
	  v_statement1 := v_statement1||'  FROM  '||p_table_name||' where plan_id = '||p_bind_var_col(1).P_SOURCE_PLAN_ID ;
          v_statement := v_statement||' '||v_statement1;

	 -- msc_util.debug_message(2 ,'Start '|| p_table_name);

	  EXECUTE IMMEDIATE v_statement using p_bind_var_col(1).P_DEST_PLAN_NAME ,p_bind_var_col(1).P_DEST_PLAN_DESC ;

	 -- msc_util.debug_message(2 ,'End '|| p_table_name);

elsif p_table_name not in ( 'MSC_PLANS' ,'MSC_DESIGNATORS' ) then
     -- msc_util.debug_message(2 ,'Start '|| p_table_name);
      for var in cur_design(p_table_name , v_msc_schema)
	loop
	  i := i + 1;
	  if i = 1 then
		v_statement  := 'INSERT INTO '||p_table_name||'  (' ||var.column_name  ;
	  else
		v_statement  := v_statement||' , '||var.column_name ;
	  end if;
	end loop;
	  v_statement := v_statement||' ) ' ;

       i := 0;
      -- msc_util.debug_message(2 ,v_statement);
       for var in cur_design(p_table_name , v_msc_schema)
	loop
	  i := i + 1;
	  if i = 1 then
		v_statement1 := ' SELECT ' ||Get_Column_Value(p_bind_var_col ,var.column_name , var.data_type ,	p_table_name );
	  else
		v_statement1 := v_statement1||' , '||Get_Column_Value(p_bind_var_col ,var.column_name , var.data_type ,p_table_name );

	  end if;
	end loop;
	  v_statement1 := v_statement1||'  FROM  '||p_table_name||' where plan_id = '||p_bind_var_col(1).P_SOURCE_PLAN_ID ;
          v_statement := v_statement||' '||v_statement1;
         -- msc_util.debug_message(3 ,v_statement);
	  EXECUTE IMMEDIATE v_statement;


end if;
End generate_sql_script;

FUNCTION Convert_to_String(p_value varchar2)
return varchar2
is
l_return varchar2(4000);
begin
 if p_value is not null and p_value <> 'null' then
   l_return := ''''||p_value||'''';
 else
   l_return := 'null' ;
 end if;
  return l_return;
end Convert_to_String;

FUNCTION Get_Column_Value(p_bind_var_col1 in Copy_Plan_Options_Type ,
			p_column_name varchar2,
			p_data_type  varchar2 ,
			p_table_name varchar2 )
return varchar2
is
l_return varchar2(4000);
Begin
	l_return := get_column_name(p_bind_var_col1 , p_table_name ,p_column_name) ;
return l_return ;
End Get_Column_Value;

end msc_copy_plan_options;

/
